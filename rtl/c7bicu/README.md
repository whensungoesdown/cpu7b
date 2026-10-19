# c7bicu — L1 Instruction Cache of cpu7b

c7bicu is the L1 instruction cache of the cpu7b LA32R core. It takes one
physical fetch address at a time from the IFU, looks it up in a 2-way
set-associative cache and returns one 64-bit block. On a miss it fetches
the whole 32-byte line from the BIU with a 4-beat burst, writes it into
the cache and returns the requested block when the burst completes.

```
                 ifu_icu_req_ic1 / ifu_icu_addr_ic1
                              |
                              v
  +-------------------------------------------------------------+
  | c7bicu                                                      |
  |   IC1: RAM read  --> IC2: tag compare --hit--> data to IFU  |
  |                              |                              |
  |                             miss                            |
  |                              v                              |
  |   linefill request --> linefill buffer (4 x 64) ------------+--> data to IFU
  |                              |                              |    (last beat)
  |                     data / tag RAM write                    |
  +-----------|----------------------------------|--------------+
              v                                  v
     c7b_cache_rams (tag x2, data x2)       c7bbiu (burst read)
```

## Files

| File | Module | Purpose |
|---|---|---|
| `c7bicu.v` | `c7bicu` | Lookup, hit/miss, linefill, way allocation, RAM control |
| `c7b_cache_rams.v` | `c7b_cache_rams` | Tag and data RAMs for both ways |
| `../models/ram22.v`, `ram22_way1.v` | `ram22`, `ram22_way1` | Tag RAM, 256 x 22 (altsyncram) |
| `../models/ram64.v`, `ram64_way1.v` | `ram64`, `ram64_way1` | Data RAM, 1024 x 64 (altsyncram) |

## Organisation

| | |
|---|---|
| Capacity | 16 KB = 2 ways x 256 sets x 32 bytes |
| Line | 32 bytes = 4 x 64-bit words |
| Tag RAM | 256 x 22 per way: `[21]` valid, `[20:0]` = PA`[31:11]` |
| Data RAM | 1024 x 64 per way, address = {set, word} |
| Replacement | Way 1 if way 0 is valid and way 1 is not, else way 0 |
| Enable | `COMPEN.IC` (CSR 0x101), switched in c7bifu (`ic_en`) |

### Address use

```
 31                 11 10         5 4   3 2   0
 +--------------------+------------+-----+-----+
 |  tag  PA[31:11]    | set (RAM)  |word | -   |
 +--------------------+------------+-----+-----+
```

| Signal | Bits driven by c7bicu | Bits used by the RAMs |
|---|---|---|
| `icu_ram_tag_addr` | `addr[14:5]` (10 bits) | `[7:0]` → set = `addr[12:5]` |
| `icu_ram_data_addr0/1` | `{addr[14:5], word}` (12 bits) | `[9:0]` → `{addr[12:5], word}` |

c7bicu drives 10/12 address bits, but `c7b_cache_rams` uses only the
low 8/10, so the set index is `addr[12:5]`. The stored tag starts at bit 11,
so bits 12:11 are both index and tag bits; this is redundant but correct.

### RAM timing

The RAMs register the read address (`rdcontrol_reg_b = CLOCK0`) and do
not register the output (`outdata_reg_b = UNREGISTERED`): data for an
address presented in cycle t is available in cycle t+1. The read is
enabled only in IC1 (`icu_ram_tag_en = icu_ram_data_en = {2{ic_lu_ic1}}`),
so the output holds the last lookup's data in the other cycles.
Read-during-write returns old data.

## Pipeline stages

| Stage | Where | What happens |
|---|---|---|
| IC1 | `ic_lu_ic1 = ifu_icu_req_ic1 & icu_ifu_ack_ic1` | Accept the address, start the tag and data RAM reads |
| IC2 | `ic_lu_ic2`, `ic_lu_addr_ic2` | Compare both tags; hit returns data, miss starts a linefill |
| LF | `lf_inprog_q` | Linefill burst in progress, beats written into the RAMs and the linefill buffer |

Only one lookup is in progress at a time. `lu_inprog_q` is set by IC1 and
cleared by `data_valid_ic2`, and the next request is acked only when it is
clear:

```verilog
assign icu_ifu_ack_ic1 = ifu_icu_req_ic1 & ~lu_inprog_q;
assign lu_inprog_in    = (lu_inprog_q & ~data_valid_ic2) | ic_lu_ic1;
```

## Lookup and hit

```verilog
assign ic_tag_way0_match_ic2 = (ram_icu_tag_rdata0[20:0] == ic_lu_addr_ic2[31:11]) & ram_icu_tag_rdata0[21];
assign ic_tag_way1_match_ic2 = (ram_icu_tag_rdata1[20:0] == ic_lu_addr_ic2[31:11]) & ram_icu_tag_rdata1[21];

assign ic_hit_ic2  = ic_lu_ic2 & (way0_match | way1_match);
assign ic_miss_ic2 = ic_lu_ic2 & ~way0_match & ~way1_match;

assign data_valid_ic2 = ic_hit_ic2 | ic_lfb_hit_data_valid | biu_icu_fault;

assign icu_ifu_data_ic2 = ram_icu_data_rdata0 & {64{way0_match}} |
                          ram_icu_data_rdata1 & {64{way1_match}} |
                          ic_lfb_hit_data     & {64{ic_lfb_hit_data_valid}};
```

Both ways are read in IC1 (data RAM address `addr[12:3]`), and the
matching way is selected in IC2.

### Timeline: hit

```
cycle              t      t+1    t+2    t+3
ifu_icu_req_ic1    1      0/1    1      0
icu_ifu_ack_ic1    1      0      1      0
ic_lu_ic1          1      0      1      0
RAM read           A      -      B      -
ic_lu_ic2          0      1      0      1
ic_hit_ic2         0      1      0      1
lu_inprog_q        0      1      0      1
data_valid_ic2     0      1(A)   0      1(B)
```

- t: address A accepted, RAMs read.
- t+1: tag compare, data A returned. `lu_inprog_q`=1 blocks the ack.
- t+2: next lookup can be accepted.

The cache accepts one lookup every two cycles. In practice c7bifu issues
its next request later (it needs a TLB cycle for a new address), so this
is not the limit on fetch bandwidth.

## Miss and linefill

On a miss in IC2 the cache requests the 32-byte-aligned line from the BIU:

```verilog
assign icu_biu_addr = {ic_lu_addr_ic2[31:5], 2'b00};   // [31:3], line aligned
assign icu_biu_req  = (lf_req_q | ic_miss_ic2) & ~biu_rd_busy;

// lf_req_q holds the request until the BIU has accepted it
wire lf_req_en  = ic_miss_ic2 | biu_rd_busy | biu_icu_fault;
wire lf_req_din = biu_icu_fault ? 1'b0 : ic_miss_ic2;

// linefill in progress: from ack to the last beat or a fault
assign lf_inprog_in = (lf_inprog_q & ~last_valid & ~biu_icu_fault) |
                      (biu_icu_ack & ~biu_icu_fault);
assign biu_rd_busy  = lf_inprog_q;
```

The burst starts at word 0 of the line; the BIU returns 4 beats
(`biu_icu_data_valid`), the last one with `biu_icu_data_last`.

Each beat is written in the same cycle to:

- **the data RAM** of the allocated way, at `{ic_lu_addr_ic2[12:5], al_cnt_q}`.
  `al_cnt_q` is cleared by `icu_biu_req` and increments on every beat.
- **the linefill buffer**: `lfb0..lfb3`, selected by the one-hot counter
  `lfb_cnt_q` (set to `0001` by `icu_biu_req`, shifted on every beat).

On the last beat the tag of the allocated way is written with
`{1'b1, ic_lu_addr_ic2[31:11]}`, and the requested word is returned to the
IFU from the linefill buffer:

```verilog
assign ic_lfb_hit_data_valid = biu_icu_data_last & biu_icu_data_valid;
assign ic_lfb_hit_data = addr[4:3] == 2'b00 ? lfb0_q :
                         addr[4:3] == 2'b01 ? lfb1_q :
                         addr[4:3] == 2'b10 ? lfb2_q :
                                              lfb3_in;   // last beat, not yet registered
```

The way is chosen in the miss cycle from the IC2 tag outputs and held in
`ic_al_way01_ic2_q` until the last beat:

```verilog
din = (ic_tag_way0_v_ic2 & ~ic_tag_way1_v_ic2) & ~last_valid;   // 1 = way 1
en  = ic_al_ic2 | last_valid;                                    // ic_al_ic2 = ic_miss_ic2
```

### Timeline: miss, BIU accepts immediately

```
cycle               t     t+1   t+2   t+3   t+4   t+5   t+6   ...
ic_lu_ic1           1     0     0     0     0     0     0
ic_miss_ic2         0     1     0     0     0     0     0
icu_biu_req         0     1     0     0     0     0     0
biu_icu_ack         0     1     0     0     0     0     0
lf_inprog_q         0     0     1     1     1     1     0
biu_icu_data_valid  0     0     d0    d1    d2    d3    0      (example)
biu_icu_data_last   0     0     0     0     0     1     0
al_cnt_q            x     x     0     1     2     3     0
data RAM write      -     -     w0    w1    w2    w3    -
tag RAM write       -     -     -     -     -     1     -
data_valid_ic2      0     0     0     0     0     1     0
```

- t+1: miss, request goes out with the line address.
- t+2 .. t+5: beats arrive (spacing depends on the bus); each is written
  into the data RAM and the linefill buffer.
- t+5: last beat; the tag is written valid and the requested word is
  returned to the IFU. `lu_inprog_q` is cleared, so the next lookup can be
  accepted at t+6.

If the BIU is busy, `lf_req_q` keeps `icu_biu_req` high until
`biu_icu_ack`; the timeline shifts by the wait.

The requested word is returned only after the whole line has arrived;
there is no critical-word-first return and no hit-under-fill.

## Bus fault

`biu_icu_fault` on a beat:

- ends the lookup (`data_valid_ic2`) and is passed to the IFU as
  `icu_ifu_fault_ic2` / `icu_ifu_fault_code_ic2`, which raises ADEF;
- clears `lf_inprog_q`, `lf_req_q`, `lfb_cnt_q` and `al_cnt_q`;
- blocks the data RAM write of that beat and the tag write, so the line
  is not marked valid.

## Cancel

`ifu_icu_cancel` sets `ifu_cancel_q`, which hides the next
`data_valid_ic2` from the IFU. In `c7b.v` it is tied to 0; the IFU drops
data from a flushed fetch itself (`data_cancel_q` in c7bifu_fcl).

## Notes / limitations

- **No invalidation.** There is no CACOP and IBAR does not touch the
  cache. Changing `COMPEN.IC` does not invalidate it. Code that is
  modified in memory (for example a reused page frame) can be served stale
  from the cache.
- **Tag valid bits are not reset.** They rely on the RAM power-up value.
  `ram22` is initialised from `ram22.mif`; `ram22_way1` has no
  `init_file` (`rtl/models/ram22_way1.v`).
- **Fill signals are not qualified with `lf_inprog_q`.** `biu_icu_data_valid`,
  `biu_icu_data_last` and `biu_icu_fault` are used directly
  (`c7bicu.v:194-197, 351, 394-395, 436-437`). Beats that arrive after a
  fault (the BIU does not end a burst early) are still written into the
  data RAM, and the last one writes the tag valid and raises
  `data_valid_ic2` with no lookup in progress. Any such signal not
  belonging to this cache would have the same effect.
- **Way data is not gated by `ic_lu_ic2`** (`c7bicu.v:200-202`). In the
  last-beat cycle a stale matching tag output can be ORed into the
  linefill-buffer data.
- **`ifu_cancel_q` can be set with no lookup in progress**
  (`c7bicu.v:169-175`), which would drop the next valid response. Unused
  while `ifu_icu_cancel` is tied to 0.
- **Replacement** always evicts way 0 once both ways are valid.
- **Unused address bits.** `icu_ram_tag_addr[9:8]` and
  `icu_ram_data_addr*[11:10]` are ignored by `c7b_cache_rams`; the comment
  "8-bit index" in the top-level README refers to this.

## Interface summary

| Signal | Dir | Description |
|---|---|---|
| `ifu_icu_req_ic1` / `ifu_icu_addr_ic1[31:3]` | in | Fetch request, physical address |
| `icu_ifu_ack_ic1` | out | Request accepted (no lookup in progress) |
| `ifu_icu_cancel` | in | Ignore the next response (tied 0 in c7b.v) |
| `icu_ifu_data_valid_ic2` / `icu_ifu_data_ic2[63:0]` | out | 64-bit fetch data |
| `icu_ifu_fault_ic2` / `icu_ifu_fault_code_ic2` | out | Bus error on the linefill |
| `icu_ram_tag_en/wr/addr/wdata0/1` | out | Tag RAM control |
| `ram_icu_tag_rdata0/1` | in | Tag RAM read data |
| `icu_ram_data_en/wr/addr0/1/wdata0/1` | out | Data RAM control |
| `ram_icu_data_rdata0/1` | in | Data RAM read data |
| `icu_biu_req` / `icu_biu_addr[31:3]` | out | Linefill request, line-aligned address |
| `icu_biu_single` | out | 0, always a line fill |
| `biu_icu_ack` | in | Linefill request accepted |
| `biu_icu_data_valid` / `biu_icu_data_last` / `biu_icu_data[63:0]` | in | Burst data beats |
| `biu_icu_fault` / `biu_icu_fault_code` | in | Bus error response |
