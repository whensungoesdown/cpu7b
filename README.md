# CPU7B — a LoongArch32r processor core

CPU7B is a single-issue, in-order processor core that implements the
integer subset of the LoongArch32 Reduced (LA32R) ISA. It has a 16 KB L1
instruction cache, separate software-managed instruction and data TLBs,
two direct-mapping windows and an AXI4 master interface. It boots
Linux 5.14 in the [SoC2](https://github.com/whensungoesdown) FPGA system.

| | |
|---|---|
| ISA | LA32R integer subset, PLV0 / PLV3 |
| Pipeline | Single issue, in order: `bf → f → d → e → m → w` |
| LSU | `ls1 → ls2 → ls3`, one access in flight, no data cache |
| L1 I-cache | 16 KB, 2-way set associative, 32-byte lines, `ic1 → ic2` |
| MMU | 32-entry iTLB and 32-entry dTLB, 4 KB pages, DMW0 / DMW1 |
| Bus | AXI4 master, 64-bit data |
| Interrupts | Timer, one external interrupt line |

More notes and articles: https://whensungoesdown.github.io

---

## Contents

- [Block Diagram](#block-diagram)
- [Modules](#modules)
- [Instruction Set](#instruction-set)
- [CSR Registers](#csr-registers)
- [Exceptions and Interrupts](#exceptions-and-interrupts)
- [Memory Management](#memory-management)
- [L1 Instruction Cache](#l1-instruction-cache)
- [Repository Layout](#repository-layout)
- [Build and Test](#build-and-test)

---

## Block Diagram

```text
 +-CPU7B-------------------------------------------------------------------+
 |  +-IFU (c7bifu)-----------------+     +-EXU (c7bexu)------------------+ |
 |  |  fcl -> instr Q -> decode    | --> |  regfile  bypass  ecl         | |
 |  |  itlb (c7btlb)               |     |  alu  bru  mul  div           | |
 |  +------------------------------+     |  csr (c7bcsr)                 | |
 |  +-ICU (c7bicu)-----------------+     |  lsu (c7blsu)  dtlb (c7btlb)  | |
 |  |  L1 I-cache 16 KB, 2-way     |     +-------------------------------+ |
 |  +------------------------------+                   |                   |
 |           |                                         |                   |
 |  +-BIU (c7bbiu)--------------------------------------------------------+ |
 |  |  read arbiter (LSU > IFU > ICU)   write arbiter   AXI interface     | |
 |  +---------------------------------------------------------------------+ |
 +------------------------------------|------------------------------------+
                                      | AXI4 master
```

---

## Modules

Each module directory has its own design document with pipeline
timelines, signal equations and a list of known limitations.

| Module | Directory | Description | Design notes |
|---|---|---|---|
| IFU | `rtl/c7bifu` | Fetch control, ITLB lookup, instruction queue, decode | [README](rtl/c7bifu/README.md) |
| ICU | `rtl/c7bicu` | L1 instruction cache and linefill buffer | see [below](#l1-instruction-cache) |
| EXU | `rtl/c7bexu` | Issue, bypass, ALU/BRU/MUL/DIV, stall and flush control, exception pipeline, interrupts | [README](rtl/c7bexu/README.md) |
| LSU | `rtl/c7blsu` | Address generation, DTLB lookup, loads/stores, LL/SC, barriers | [README](rtl/c7blsu/README.md) |
| TLB | `rtl/c7btlb` | 32-entry TLB, instantiated as ITLB and DTLB | [README](rtl/c7btlb/README.md) |
| CSR | `rtl/c7bcsr` | Control and status registers, timer, counter | [README](rtl/c7bcsr/README.md) |
| BIU | `rtl/c7bbiu` | Read/write arbitration and AXI4 interface | [README](rtl/c7bbiu/README.md) |
| Top | `rtl/c7b.v`, `rtl/c7bcore.v` | Core top level and interconnect between units | |

---

## Instruction Set

| Group | Instructions |
|---|---|
| Integer arithmetic | `ADD.W` `SUB.W` `ADDI.W` `LU12I.W` `PCADDU12I` `SLT[U]` `SLT[U]I` `AND` `OR` `NOR` `XOR` `ANDI` `ORI` `XORI` `NOP` |
| Shift | `SLL.W` `SRL.W` `SRA.W` `SLLI.W` `SRLI.W` `SRAI.W` |
| Branch and jump | `BEQ` `BNE` `BLT[U]` `BGE[U]` `B` `BL` `JIRL` |
| Multiply | `MUL.W` `MULH.W[U]` |
| Divide | `DIV.W[U]` `MOD.W[U]` |
| Load / store | `LD.B` `LD.H` `LD.W` `LD.BU` `LD.HU` `ST.B` `ST.H` `ST.W` |
| Atomic | `LL.W` `SC.W` |
| Barrier | `DBAR` `IBAR` |
| CSR | `CSRRD` `CSRWR` `CSRXCHG` |
| TLB | `TLBSRCH` `TLBRD` `TLBWR` `TLBFILL` `INVTLB` |
| Miscellaneous | `ERTN` `SYSCALL` `BREAK` `RDCNTVL.W` `RDCNTVH.W` |
| Cache hint | `PRELD` (executes as a NOP) |

### Not yet implemented

- [ ] Floating-point instructions
- [ ] `CACOP`
- [ ] `RDCNTID`, `IDLE`

---

## CSR Registers

| Address | Register | Description |
|---|---|---|
| 0x0 | CRMD | Current mode information |
| 0x1 | PRMD | Pre-exception mode information |
| 0x4 | ECFG | Exception configuration (local interrupt enables) |
| 0x5 | ESTAT | Exception status |
| 0x6 | ERA | Exception return address |
| 0x7 | BADV | Bad virtual address |
| 0xC | EENTRY | Exception entry base address |
| 0x10 | TLBIDX | TLB index |
| 0x11 | TLBEHI | TLB entry high-order bits |
| 0x12 | TLBELO0 | TLB entry low-order bits, even page |
| 0x13 | TLBELO1 | TLB entry low-order bits, odd page |
| 0x18 | ASID | Address space identifier |
| 0x19 | PGDL | Page global directory base, lower half address space |
| 0x1A | PGDH | Page global directory base, higher half address space |
| 0x1B | PGD | Page global directory base (read only) |
| 0x30–0x33 | SAVE0–SAVE3 | Data save registers |
| 0x41 | TCFG | Timer configuration |
| 0x42 | TVAL | Timer value |
| 0x44 | TICLR | Timer interrupt clear |
| 0x60 | LLBCTL | LLBit control |
| 0x88 | TLBRENTRY | TLB refill exception entry address |
| 0x100 | BSEC | Implementation specific |
| 0x101 | COMPEN | Implementation specific: bit 0 enables the I-cache |
| 0x180–0x181 | DMW0–DMW1 | Direct mapping configuration windows |

Implementation-specific behaviour:

- `TLBIDX.I_D` (bit 16) selects the target of `TLBRD`, `TLBWR`, `TLBFILL`,
  `TLBSRCH` and `INVTLB`: 0 = iTLB, 1 = dTLB. The two TLBs are maintained
  separately by software.
- `ESTAT.IS`: the timer interrupt is bit 3 and the external interrupt is
  bit 4 (the LA32R manual uses bits 11 and 2).
- `ECFG.LIE` uses the same bit positions as `ESTAT.IS`, and resets to
  0x18 (timer and external interrupt enabled) instead of 0, so software
  that never writes ECFG still receives interrupts. `ECFG.VS` is not
  implemented.
- EUEN, CPUID, TID, CNTC and the TLB refill save registers (0x89–0x8F)
  are not implemented and read as 0.

Field-level details and reset values are in
[rtl/c7bcsr/README.md](rtl/c7bcsr/README.md).

---

## Exceptions and Interrupts

| Ecode | Name | Description |
|---|---|---|
| 0x0 | INT | Interrupt (timer, external) |
| 0x1 | PIL | Page invalid, load |
| 0x2 | PIS | Page invalid, store |
| 0x3 | PIF | Page invalid, instruction fetch |
| 0x4 | PME | Page modification |
| 0x7 | PPI | Page privilege illegal |
| 0x8 | ADEF | Address error, instruction fetch (subcode 0) |
| 0x8 | ADEM | Address error, memory access (subcode 1) |
| 0x9 | ALE | Address alignment fault |
| 0xB | SYS | System call |
| 0xC | BRK | Breakpoint |
| 0xD | INE | Instruction not defined |
| 0x3F | TLBR | TLB refill, enters at `TLBRENTRY` |

Exceptions are taken at the W stage. ERA is the PC of the faulting
instruction; for fetch exceptions ERA and BADV are both the faulting fetch
address. Interrupts are gated by `CRMD.IE` and `ECFG.LIE` and inserted on the instruction
in decode.

---

## Memory Management

- **Address modes:** direct address (`CRMD.DA`=1) and mapped
  (`CRMD.PG`=1).
- **Direct mapping windows:** DMW0 and DMW1 map a 512 MB virtual segment
  (`VSEG`) to a physical segment (`PSEG`).
- **TLB:** separate iTLB and dTLB, 32 entries each. Each entry maps an
  even/odd pair of 4 KB pages, with ASID and global bit, and per-page V, D,
  PLV and MAT fields.
- **Software managed:** TLB misses raise TLBR; the refill handler fills the
  TLB with `TLBFILL` or `TLBWR`. There is no hardware page table walker.
- **TLB search latency:** one cycle. See
  [rtl/c7btlb/README.md](rtl/c7btlb/README.md) for the entry format,
  `INVTLB` operations and timing.

---

## L1 Instruction Cache

| | |
|---|---|
| Capacity | 16 KB |
| Organisation | 2-way set associative, 256 sets |
| Line size | 32 bytes, filled by a 4-beat 64-bit AXI burst |
| Tag RAM | 22 bits per way: `[21]` valid, `[20:0]` address `[31:11]` |
| Data RAM | 64 bits per word, 4 words per line |
| Enable | `COMPEN.IC` (CSR 0x101) |

```text
 tag RAM index    ifu_icu_addr_ic1[14:5]
 data RAM index   {ic_lu_addr_ic2[14:5], al_cnt_q[1:0]}

   tag RAM                            data RAM
   +---+----------------------+       +----------------------------------+
   | V |       tag [31:11]    |       |            data [63:0]           |
   +---+----------------------+       +----------------------------------+
    21  20                   0         63                               0
```

The index is 10 bits wide in the RTL, of which 8 select the 256 sets.

---

## Repository Layout

```text
cpu7b/
├── rtl/
│   ├── c7b.v, c7bcore.v     Core top level
│   ├── c7bifu/              Instruction fetch unit
│   ├── c7bicu/              L1 instruction cache
│   ├── c7bexu/              Execution unit
│   ├── c7blsu/              Load/store unit
│   ├── c7btlb/              TLB
│   ├── c7bcsr/              Control and status registers
│   ├── c7bbiu/              Bus interface unit
│   ├── alu.v, branch.v,
│   │   mul64x64.v, div.v    Functional units
│   └── defines.vh           Shared definitions
├── flist/                   File lists
├── tb/                      Test benches
├── simulation/              Directed and random tests (100+)
└── systhesis/altera/        Quartus project
```

---

## Build and Test

### Synthesis

```shell
cd systhesis/altera
make
```

### Regression

```shell
cd simulation
./run_all_tests.sh           # all directed tests
./run_all_random_cases.sh    # random tests
./clean_all_tests.sh         # remove build outputs
```

### Single test

```shell
cd simulation/test0
vim testcode/start.S         # test program
./simulate.sh                # build and simulate
./viewwave.sh                # open the waveform
```
