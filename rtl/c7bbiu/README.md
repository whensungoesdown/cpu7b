# c7bbiu — Bus Interface Unit of cpu7b

c7bbiu connects the cpu7b LA32R core to one AXI master port (64-bit
data, 4-bit IDs). It serves three read requesters (ICU linefill, LSU
load, IFU uncached fetch) and one write requester (LSU store). A
combinational fixed-priority arbiter picks one read at a time, and only
one read transaction is in flight. AR, AW and W each have one output
register slice. R and B responses are not registered: they are decoded
by ID and passed straight to the requesters. `rready` and `bready` are
tied to 1.

```
  IFU rd_req/addr --+
  LSU rd_req/addr --+-->+-------------+ arb_rd_*  +----------------------+
  ICU req/addr/   --+   | c7bbiu      |---------->| c7bbiu_axi_interface |
      single            | _rd_arb     |<----------|                      |
  <-- *_rd_ack, icu_ack | LSU>IFU>ICU | ar_ready, |  AR slice ---------->|--> AR
                        | busy_q      | r_last    |  R decode  <---------|<-- R
                        +-------------+           |                      |
  LSU wr_aw_req,  ----->+-------------+ arb_wr_*  |  AW slice ---------->|--> AW
      wr_w_req, addr,   | c7bbiu      |---------->|  W  slice ---------->|--> W
      data/strb/last    | _wr_arb     |<----------|  B decode  <---------|<-- B
  <-- wr_aw_ack/w_ack   | (LSU only)  | aw/w_ready|                      |
                        +-------------+           +----------------------+
                                                     |
  <-- biu_{ifu,lsu,icu}_data_valid / data / fault / fault_code
  <-- biu_icu_data_last, biu_lsu_write_done / write_fault / write_fault_code
```

## Files

| File | Module | Purpose |
|---|---|---|
| `c7bbiu.v` | `c7bbiu` | Top: instantiates the arbiters and the AXI interface, fans R/B results out to IFU, LSU and ICU |
| `c7bbiu_rd_arb.v` | `c7bbiu_rd_arb` | Read arbiter: priority LSU > IFU > ICU, `busy_q` (single outstanding read), AR payload per requester |
| `c7bbiu_wr_arb.v` | `c7bbiu_wr_arb` | Write arbiter with one requester (LSU): AW/W payload and acks |
| `c7bbiu_axi_interface.v` | `c7bbiu_axi_interface` | AR/AW/W register slices, R and B decode into per-requester valid/fault |
| `axi_types.v` | | `localparam`s (`` `include``d in the sub-modules): AXI IDs, sizes, burst types |

Flops come from `models/swrvr_clib.v`: `dffrl_ns` (synchronous
active-low reset to 0) and `dffrle_ns` (the same with an enable).

## Read path

### Arbitration (c7bbiu_rd_arb)

```verilog
lsu_select     = lsu_biu_rd_req;
ifu_select     = ~lsu_biu_rd_req & ifu_biu_rd_req;
icu_select     = ~lsu_biu_rd_req & ~ifu_biu_rd_req & icu_biu_req;

biu_ifu_rd_ack = axi_ar_ready & ifu_select & ~busy_q;
biu_lsu_rd_ack = axi_ar_ready & lsu_select & ~busy_q;
biu_icu_ack    = axi_ar_ready & icu_select & ~busy_q;
arb_rd_val     = biu_ifu_rd_ack | biu_lsu_rd_ack | biu_icu_ack;

busy_in        = (busy_q & ~ext_biu_r_last) | arb_rd_val;
```

The ack is combinational, in the same cycle as the request. `busy_q` is
1 from the cycle after the ack up to and including the cycle in which
`rlast` is seen. The next ack can come one cycle after `rlast`, so only
one read is outstanding.

AR payload (`c7bbiu_rd_arb.v:114-117`):

| Requester | ARID | ARADDR | ARLEN | ARSIZE | ARBURST |
|---|---|---|---|---|---|
| IFU | 0 | `ifu_biu_rd_addr` | 0 | 8 B | `2'b00` (FIXED) |
| LSU | 1 | `lsu_biu_rd_addr` | 0 | 8 B | `2'b00` (FIXED) |
| ICU, `single`=0 | 2 | `{icu_biu_addr[31:3], 3'b0}` | 3 (4 beats) | 8 B | `2'b01` (INCR) |
| ICU, `single`=1 | 2 | `{icu_biu_addr[31:3], 3'b0}` | 0 | 8 B | `2'b00` (FIXED) |

ARLOCK, ARCACHE and ARPROT are always 0. An ICU linefill is 4 x 64 bits
= 32 bytes. The ICU drives `icu_biu_single` = 0 (`c7bicu/c7bicu.v:275`).
The BIU passes IFU/LSU addresses through without aligning them.

### AR register slice (c7bbiu_axi_interface)

```verilog
ar_valid_in      = (ar_valid_q & ~ext_biu_ar_ready) | arb_rd_val;
biu_ext_ar_valid = ar_valid_q;
axi_ar_ready     = ~(biu_ext_ar_valid & ~ext_biu_ar_ready);
ar_enable        = axi_ar_ready & arb_rd_val;   // loads the 57-bit AR payload
```

`arvalid` and the payload come out of flops one cycle after the ack.
They are held until `arready`. AW and W use the same structure
(`c7bbiu_axi_interface.v:309-437`).

### R decode

```verilog
biu_ext_r_ready   = 1'b1;
rdata_val         = ext_biu_r_valid & biu_ext_r_ready & ~(|ext_biu_r_resp);

axi_rdata_ifu_val = rdata_val & ext_biu_r_last & (ext_biu_r_id == AXI_RID_IFU);
axi_rdata_lsu_val = rdata_val & ext_biu_r_last & (ext_biu_r_id == AXI_RID_LSU);
axi_rdata_icu_val = rdata_val &                  (ext_biu_r_id == AXI_RID_ICU);

axi_rdata         = ext_biu_r_data;   // shared by IFU, LSU, ICU
axi_rdata_last    = ext_biu_r_last;   // -> biu_icu_data_last

axi_rdata_*_fault      = (ext_biu_r_id == AXI_RID_*) & (|ext_biu_r_resp);
axi_rdata_*_fault_code = ext_biu_r_resp;
```

IFU/LSU data valid needs `rlast`. ICU data valid fires on every beat.
`biu_*_data` is `rdata` in the same cycle.

## Write path

### Write arbiter (c7bbiu_wr_arb)

```verilog
lsu_select        = lsu_biu_wr_aw_req;
biu_lsu_wr_aw_ack = axi_aw_ready & lsu_select;
biu_lsu_wr_w_ack  = axi_w_ready  & lsu_select;
arb_wr_aw_val     = biu_lsu_wr_aw_ack;
arb_wr_w_val      = biu_lsu_wr_w_ack;
```

| Channel | Payload |
|---|---|
| AW | AWID=1, AWADDR=`lsu_biu_wr_addr`, AWLEN=0, AWSIZE=`3'b010` (4 B), AWBURST=`2'b00`, lock/cache/prot=0 |
| W | WID=1, WDATA=`lsu_biu_wr_data`, WSTRB=`lsu_biu_wr_strb`, WLAST=`lsu_biu_wr_last` |

In `c7b.v`:

- `lsu_biu_wr_aw_req` and `lsu_biu_wr_w_req` are both driven by
  `lsu_biu_wr_req` (`c7b.v:282,284`).
- `lsu_biu_wr_last` is tied to 1 (`c7b.v:287`).
- The LSU gets `biu_lsu_wr_ack = biu_lsu_wr_aw_ack & biu_lsu_wr_aw_ack`
  (`c7b.v:177`).

Writes have no busy flag. A new write is accepted whenever the AW and W
slices are free, even if earlier B responses are still pending. The
requester must drop its request the cycle after the ack, otherwise the
same write is issued again. The LSU does this: the ack clears
`biu_wr_req_q` (`c7blsu/rtl/c7blsu.v:559`).

### B decode

```verilog
biu_ext_b_ready          = 1'b1;
axi_write_lsu_val        = ext_biu_b_valid & (ext_biu_b_id == AXI_WID_LSU) & ~(|ext_biu_b_resp);
axi_write_lsu_fault      = (ext_biu_b_id == AXI_WID_LSU) & (|ext_biu_b_resp);
axi_write_lsu_fault_code = ext_biu_b_resp;
```

`biu_lsu_write_done` = `axi_write_lsu_val`.

## Timelines

The slave latencies below (ready in the first cycle that valid is up,
first R beat two cycles after the AR handshake) are example values. The
BIU-side behaviour follows from the equations above.

### Timeline: ICU linefill (single = 0)

```
cycle               t     t+1    t+2    t+3    t+4    t+5    t+6    t+7
icu_biu_req         1     0      0      0      0      0      0      0
biu_icu_ack         1     0      0      0      0      0      0      0
busy_q              0     1      1      1      1      1      1      0
arvalid             0     1      0      0      0      0      0      0
arready             x     1      x      x      x      x      x      x
arid/arlen/arburst  -     2/3/INCR -    -      -      -      -      -
rvalid (rid=2)      0     0      0      1      1      1      1      0
rlast               0     0      0      0      0      0      1      0
biu_icu_data_valid  0     0      0      1      1      1      1      0
biu_icu_data_last   0     0      0      0      0      0      1      0
```

- t: request and ack in the same cycle. `ar_enable` loads the AR payload.
- t+1: `arvalid` out of the flop. If `arready` were 0, `arvalid` and the
  payload would hold and `axi_ar_ready` would be 0.
- t+3..t+6: each beat goes straight through to the ICU.
- t+6: `rlast` clears `busy_in`. At t+7 `busy_q`=0 and a new read can be
  acked.

### Timeline: LSU single read

```
cycle               t     t+1    t+2    t+3    t+4
lsu_biu_rd_req      1     0      0      0      0
biu_lsu_rd_ack      1     0      0      0      0
busy_q              0     1      1      1      0
arvalid             0     1      0      0      0      (arid=1, arlen=0, arsize=8 B)
arready             x     1      x      x      x
rvalid/rlast (rid=1) 0    0      0      1/1    0
biu_lsu_data_valid  0     0      0      1      0
biu_lsu_data        -     -      -      rdata  -
```

### Timeline: uncached IFU read

This is the same as the LSU read except that ARID=0 and the IFU port
names are used. `c7b.v:261` marks the port "for ifu uncache fetch, not
used yet".

```
cycle                  t     t+1    t+2    t+3    t+4
ifu_biu_rd_req         1     0      0      0      0      (lsu_biu_rd_req=0)
biu_ifu_rd_ack         1     0      0      0      0
busy_q                 0     1      1      1      0
arvalid                0     1      0      0      0      (arid=0, arlen=0)
rvalid/rlast (rid=0)   0     0      0      1/1    0
biu_ifu_data_valid     0     0      0      1      0
```

### Timeline: LSU write (AW, W, B)

```
cycle                  t     t+1    t+2    t+3    t+4
lsu_biu_wr_req         1     0      0      0      0      (aw_req = w_req)
wr_aw_ack/wr_w_ack     1/1   0      0      0      0
awvalid                0     1      0      0      0      (awid=1, awlen=0, awsize=4 B)
awready                x     1      x      x      x
wvalid                 0     1      0      0      0      (wid=1, wlast=1)
wready                 x     1      x      x      x
bvalid (bid=1, bresp=0) 0    0      0      1      0
biu_lsu_write_done     0     0      0      1      0
```

- AW and W are separate slices. If `wready` is 0 at t+1, `wvalid` holds
  and `axi_w_ready` is 0, while AW can still complete at t+1.
- Reads and writes use separate paths and can overlap. The BIU does not
  order a read against an earlier write.

### Timeline: ICU and LSU request in the same cycle

```
cycle             t     t+1    t+2    t+3    t+4    t+5    ...    t+n    t+n+1
lsu_biu_rd_req    1     0      0      0      0      0             0      0
icu_biu_req       1     1      1      1      1      0             0      0
busy_q            0     1      1      1      0      1             1      0
biu_lsu_rd_ack    1     0      0      0      0      0             0      0
biu_icu_ack       0     0      0      0      1      0             0      0
arvalid / arid    0     1/1    0      0      0      1/2           0      0
rvalid/rlast/rid  0     0      0      1/1/1  0      0      beats  1/1/2  0
```

- t: `lsu_select`=1 forces `icu_select`=0, so the LSU wins.
- t+1..t+3: `busy_q`=1 blocks every ack, even though `axi_ar_ready` is 1
  again from t+2.
- t+4: `busy_q`=0 and the ICU is still requesting, so the ICU is acked.
  If the LSU or IFU also requested at t+4, it would win again because
  the priority is fixed.

### Timeline: error responses

A non-zero `rresp`/`bresp` suppresses the data valid / write done and
raises the requester's fault with `fault_code` = resp.

LSU read with SLVERR:

```
cycle                     t+3
rvalid/rlast/rid/rresp    1/1/1/2'b10
biu_lsu_data_valid        0
biu_lsu_fault/fault_code  1/2'b10
busy_in                   0       (busy_q clears at t+4)
```

ICU linefill with an error on the second beat:

```
cycle               t+3    t+4    t+5    t+6    t+7
rvalid (rid=2)      1      1      1      1      0
rresp               00     10     00     00     -
rlast               0      0      0      1      0
biu_icu_data_valid  1      0      1      1      0
biu_icu_fault       0      1      0      0      0
busy_q              1      1      1      1      0
```

- The BIU does not end the burst early. `busy_q` still waits for `rlast`
  and later beats are still forwarded. The ICU ends its linefill on
  `biu_icu_fault` (`c7bicu/c7bicu.v:224-225`).
- LSU write with `bresp` != 0 (bid=1): `biu_lsu_write_done`=0,
  `biu_lsu_write_fault`=1, `biu_lsu_write_fault_code`=`bresp`.

## AXI ID usage

| ID | Name (`axi_types.v`) | Channel | Used by |
|---|---|---|---|
| 0 | `AXI_RID_IFU` | AR/R | IFU uncached read |
| 1 | `AXI_RID_LSU` | AR/R | LSU read |
| 2 | `AXI_RID_ICU` | AR/R | ICU linefill |
| 1 | `AXI_WID_LSU` | AW/W/B | LSU write |
| 0 | `AXI_WID_IFU` | - | defined, not used |

R and B are routed by ID compare only. With one read outstanding, read
responses never interleave.

## Interface summary

| Signal | Dir | Description |
|---|---|---|
| `ifu_biu_rd_req` / `ifu_biu_rd_addr` | in | Uncached fetch request |
| `biu_ifu_rd_ack` | out | Request accepted (same cycle) |
| `biu_ifu_data_valid` / `biu_ifu_data` | out | 64-bit data (rid=0, rlast, rresp=0) |
| `biu_ifu_fault` / `biu_ifu_fault_code` | out | rid=0 with rresp != 0; code = rresp |
| `lsu_biu_rd_req` / `lsu_biu_rd_addr` | in | Load request |
| `biu_lsu_rd_ack` | out | Request accepted |
| `biu_lsu_data_valid` / `biu_lsu_data` | out | 64-bit data (rid=1, rlast, rresp=0) |
| `biu_lsu_fault` / `biu_lsu_fault_code` | out | rid=1 with rresp != 0 |
| `lsu_biu_wr_aw_req` / `lsu_biu_wr_addr` | in | Store address request |
| `lsu_biu_wr_w_req` | in | Store data request (unused, see notes) |
| `lsu_biu_wr_data` / `_strb` / `_last` | in | Store data (64 / 8 / 1 bits) |
| `biu_lsu_wr_aw_ack` / `biu_lsu_wr_w_ack` | out | AW / W accepted |
| `biu_lsu_write_done` | out | B with bid=1, bresp=0 |
| `biu_lsu_write_fault` / `_fault_code` | out | bid=1 with bresp != 0 |
| `icu_biu_req` / `icu_biu_addr[31:3]` / `icu_biu_single` | in | Linefill (4-beat INCR) or single-beat read |
| `biu_icu_ack` | out | Request accepted |
| `biu_icu_data_valid` / `biu_icu_data` | out | Every beat with rid=2, rresp=0 |
| `biu_icu_data_last` | out | Raw `rlast` (not qualified) |
| `biu_icu_fault` / `biu_icu_fault_code` | out | rid=2 with rresp != 0 |
| `biu_ext_ar_*` / `ext_biu_ar_ready` | out/in | AXI AR (registered) |
| `ext_biu_r_*` / `biu_ext_r_ready` | in/out | AXI R, `rready`=1 |
| `biu_ext_aw_*` / `ext_biu_aw_ready` | out/in | AXI AW (registered) |
| `biu_ext_w_*` / `ext_biu_w_ready` | out/in | AXI W with WID (registered) |
| `ext_biu_b_*` / `biu_ext_b_ready` | in/out | AXI B, `bready`=1 |

## Notes / limitations

1. Only one read is outstanding. `busy_q` blocks all read acks from the
   ack until `rlast` (`c7bbiu_rd_arb.v:61,98-100`).
2. Fault outputs only decode `rid`/`rresp` and `bid`/`bresp`. They do
   not check `rvalid`/`bvalid` (`c7bbiu_axi_interface.v:274-276,449`).
   A non-zero resp driven while valid is low raises a fault. IFU uses
   ID 0, so an idle bus with `rid`=0 and `rresp`!=0 raises
   `biu_ifu_fault`.
3. `rlast` is not qualified by `rvalid`. `busy_in` uses raw
   `ext_biu_r_last` (`c7bbiu_rd_arb.v:61`), and `biu_icu_data_last` is
   raw `rlast` (`c7bbiu_axi_interface.v:272`, `c7bbiu.v:364`). The ICU
   compensates with `biu_icu_data_last & biu_icu_data_valid`
   (`c7bicu/c7bicu.v:66-67`). `busy_q` is not qualified. It also does
   not check `rid`, which only works because one read is outstanding.
4. An error beat does not end a burst. It only suppresses that beat's
   data valid and raises fault, and `busy_q` still waits for `rlast`
   (`c7bbiu_axi_interface.v:262-268`).
5. `lsu_biu_wr_w_req` is unused. The AW and W acks and payloads are all
   gated by `lsu_biu_wr_aw_req` (`c7bbiu_wr_arb.v:160,178,181`). In
   `c7b.v` both requests are the same signal, so this has no effect
   there.
6. The LSU write ack is the AW ack only: `c7b.v:177` connects
   `biu_lsu_wr_aw_ack & biu_lsu_wr_aw_ack`, so `biu_lsu_wr_w_ack` is not
   used. If W is stalled (`axi_w_ready`=0) while AW is free, the LSU sees
   an ack and drops the request. The AW goes out, but the W beat for
   that store is never loaded (`w_enable`=0,
   `c7bbiu_axi_interface.v:401`).
7. Writes have no outstanding tracking. A new write is accepted while
   earlier B responses are pending. A request held high after the ack
   issues a duplicate write (`c7bbiu_wr_arb.v:180-184`). The BIU does
   not order reads against writes.
8. AWSIZE is fixed to 4 bytes (`AXI_SIZE_WORD`,
   `c7bbiu_wr_arb.v:173`), while WDATA/WSTRB are 64/8 bits and the
   strobe comes straight from the LSU. Reads always use 8 bytes. Single
   transfers use burst type `2'b00` (FIXED).
9. The priority is fixed (LSU > IFU > ICU, `c7bbiu_rd_arb.v:44-51`).
   Back-to-back LSU/IFU requests can starve the ICU.
10. `rdata`, `rlast`, `rresp` and `bresp` reach the requesters without a
    register stage (`c7bbiu_axi_interface.v:227`).
11. The comment at `c7bbiu_axi_interface.v:190-194` says the AR payload
    is buffered for one cycle only ("WRONG!"). The register is enabled by
    `ar_enable = axi_ar_ready & arb_rd_val`, so it holds while `arvalid`
    is stalled. The comment is out of date.
