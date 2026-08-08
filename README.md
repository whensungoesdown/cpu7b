# CPU7B (LoongArch32r ISA)


More blogs are kept at:
- https://whensungoesdown.github.io

## Pipeline

- Single-issue, in-order core

- Main pipeline: `bf → f → d → e → m(ex2) → w`

- LSU pipeline: `ls1 → ls2 → ls3`

- 16KB 2-way set-associative L1 instruction cache: `ic1 → ic2`

## Modules

`````c
 +-CPU7B-----------------------------------------------------------------------------------+
 | +-----------------------------+     +----------------------------------------------+    |
 | |IFU                          |     | EXU               +--------+    +-------+    |    |
 | |  +------------+  +--------+ |     |     +---------+   |        |    |  alu  |    |    |
 | |  |            |  |        | |     |     |         |   |        |    |       |    |    |
 | |  |    fcl     |  |        | |     |     |   csr   |   |        |    +-------+    |    |
 | |  |            |->| decode | | ->  |     |         |   |        |    +-------+    |    |
 | |  |   instr Q  |  |        | |     |     +---------+   |        |    |  bru  |    |    |
 | |  |            |  |        | |     |     +---------+   |  ecl   |    |       |    |    |
 | |  +------------+  +--------+ |     |     |         |   |   &    |    +-------+    |    |
 | +----| |--- | |---------------+     |     | regfile |   |  byp   |    +-------+    |    |
 |      | |    | |                     |     |         |   |        |    |  mul  |    |    |
 |      | |  +-----------------+       |     +-------- +   |        |    |       |    |    |
 |      | |  |                 |       |                   |        |    +-------+    |    |
 |      | |  | L1 icache       |       |  +-----------+    |        |    +-------+    |    |
 |      | |  +--------+        |       |  |   lsu     |    |        |    |  div  |    |    |
 |      | |  |  itlb  |        |       |  +------+    |    |        |    |       |    |    |
 |      | |  +--------+--------+       |  | dtlb |    |    +--------+    +-------+    |    |
 |      | |    | |                     |  +------+-----                               |    |
 |      | |    | |                     +-----|------|---------------------------------+    |
 |      | |    | |                           |      |                                      |
 |  +-------------------------------------------------+                                    |
 |  |                                                 |                                    |
 |  |                       BIU                       |                                    |
 |  |                                                 |                                    |
 |  +-------------------------------------------------+                                    |
 |                  |      |                                                               |
 +------------------|      |---------------------------------------------------------------+
                    |      |


`````


---

## LoongArch32r Instruction Set

### Integer Arithmetic


`````assembly

  ADD.W SUB.W ADDI.W 

  LU12I.W PCADDU12I 

  SLT[U] SLT[U]I 

  AND OR NOR XOR

  ANDI ORI XORI

  NOP
`````
	
### Bit-Shift

`````assembly
  SLL.W SRL.W SRA.W SLL.W SRL.W SRA.W

  SLLI.W SRLI.W SRAI.W
`````

### Branch and Jump

`````assembly
  BEQ BNE BLT[U] BGE[U]

  B BL

  JIRL
`````

### Integer Multiply

`````assembly
  MUL.W MULH.W[U]
`````

### Integer Divide

`````assembly
  DIV.W[U]  MOD.W[U]
`````

### Memory Access

`````assembly
  LD.B LD.H LD.W LD.BU LD.HU LD.HU

  ST.B ST.H ST.W
`````

### CSR Access

`````assembly
  CSRRD CSRWR CSRXCHG
`````

### Atomic Memory Access

`````assembly
  LL.W SC.W
`````

### Barrier

`````assembly
  DBAR IBAR
`````

### TLB

`````assembly
  TLBSRCH TLBRD TLBWR TLBFILL INVTLB
`````

### Miscellaneous


`````assembly
  ERTN SYSCALL BREAK RDCNTV{L/H}.W
`````

## To Do

- [ ] Memory access: `PRELD`
- [ ] Floating-point instructions
- [ ] Miscellaneous: `RDCNTID`, `IDLE`

---

## CSR Registers

| Address     | Register    | Description                         |
|-------------|-------------|-------------------------------------|
| 0x0         | CRMD        | Current Mode Information            |
| 0x1         | PRMD        | Pre-exception Mode Information      |
| 0x5         | ESTAT       | Exception Status                    |
| 0x6         | ERA         | Exception Return Address            |
| 0x7         | BADV        | Bad Virtual Address                 |
| 0xc         | EENTRY      | Exception Entry Base Address        |
| 0x10        | TLBIDX      | TLB InDeX                           | 
| 0x11        | TLBEHI      | TLB Entry HIgh-order bits           |
| 0x12        | TLBELO0     | TLB Entry LOw-order bits 0          |
| 0x13        | TLBELO1     | TLB Entry LOw-order bits 1          |
| 0x18        | ASID        | Address Space IDentifier            |
| 0x19        | PGDL        | Page Global Directory base address for Lower half address space  |
| 0x1a        | PGDH        | Page Global Directory base address for Higher half address space |
| 0x1b        | PGD         | Page Global Directory base address  |
| 0x30~0x33   | SAVE0~SAVE3 | Data Save Register                  |
| 0x41        | TCFG        | Timer Configuration                 |
| 0x42        | TVAL        | Timer Value                         |
| 0x43        | TICLR       | Timer Interrupt Clearing            |
| 0x60        | LLBCTL      | LLBit Controller                    |
| 0x88        | TLBRENTRY   | TLB Refill exception ENTRY address  |
| 0x180~0x181 | DMW0~DMW1   | Direct Mapping configuration Window |

---

## Exceptions

- 0x0 Timer Interrupt, Ext Interrupt
- 0x1 Page Invalid exception for Load operation (PIL)
- 0x2 Page Invalid exception for Store operation (PIS)
- 0x3 Page Invalid exception for Fetch operation (PIF)
- 0x4 Page Modification Exception (PME)
- 0x7 Page Privilege level Illegal exception (PPI)
- 0x8 ADdress error Exception for Fetching instructions (ADEF)
- 0x8 ADdress error Exception for Memory access instructions (ADEM)
- 0x9 Address aLignment fault Exception (ALE)
- 0xB SYStem call exception (SYS)
- 0xC BReaKpoint exception (BRK)
- 0xD Instruction Non-defined Exception (INE)
---

## L1 Instruction Cache

The L1 instruction cache is organized as a 2-way set-associative structure with a 32-byte (256-bit) line size. It consists of 256 sets, each containing two ways, for a total capacity of 16KB (32 bytes × 256 sets × 2 ways). Linefill buffer is also 32-byte, fetched from memory using AXI burst transactions of four 64-bit quadwords per access.

Each way contains a 22-bit tag ram and 4 64-bit data ram.


`````c
 32-bit address

    |____________________|___________|
   31       tag        11 10         0
`````


`````c

 8-bit index, 256 sets   (10-bit address in the code, but only 8 bits are actually used)

 tag ram index

 ifu_icu_addr_ic1[14:5]


 data ram index, last 2-bit addresses ram line

 {ic_lu_addr_ic2[14:5], al_cnt_q[1:0]}
`````

````c

 tag ram 22-bit, [21] v, [20:0] tag

   v
  |_|____________________|
 21 20      tag          0


 data ram 64-bit

    |______________________________________________________________________|
   63                                data                                  0
`````

## TLB (itlb & dtlb)

- 32 entries per TLB, 5-bit index (0..31).                           

- Independent iTLB and dTLB, selected by TLBIDX.I_D (bit 16).        

- Software-managed: all operations (TLBWR, TLBFILL, TLBSRCH, INVTLB) 
  are performed by software. No hardware page table walk.            

`````c


+==============================================================================+
|                             TLB Entry                                        |
+==============================================================================+
| VPPN  | Virtual Paired Page Number (19 bits). Each entry maps two adjacent   |
|       | pages (odd/even). Effective VPN = VPPN << 1. Page offset is taken    |
|       | from the faulting address (BADV).                                    |
+-------+----------------------------------------------------------------------+
| ASID  | Address Space ID (10 bits). Used to distinguish processes to avoid   |
|       | TLB flushes on context switches. Ignored when G=1.                   |
+-------+----------------------------------------------------------------------+
| MAT   | Memory Access Type (2 bits). Controls cache attributes (e.g.,        |
|       | strongly ordered, cached, write-back, etc.).                         |
+-------+----------------------------------------------------------------------+
| PLV   | Privilege Level (2 bits). Compared with current CRMD.PLV to detect   |
|       | PPI (Privilege Violation). 0 = kernel, 3 = user.                     |
+-------+----------------------------------------------------------------------+
| G     | Global (1 bit). If 1, the ASID is ignored during lookup. Used for    |
|       | kernel mappings that are shared across all address spaces.           |
+-------+----------------------------------------------------------------------+
| D     | Dirty (1 bit). Indicates the page has been written to. Used for      |
|       | PME (Page Modification Exception) and swapping optimizations.        |
+-------+----------------------------------------------------------------------+
| V     | Valid (1 bit). If 0, the entry is invalid; accesses cause PIF/PIL/PIS|
|       | exceptions (page invalid faults).                                    |
+-------+----------------------------------------------------------------------+
| E     | Entry Valid (1 bit). Software-maintained validity flag for the TLB   |
|       | entry itself. Cleared by invalidation operations.                    |
+-------+----------------------------------------------------------------------+
| PPN   | Physical Page Number (20 bits). Combined with page offset from the   |
|       | virtual address to form the physical address.                        |
+-------+----------------------------------------------------------------------+

+==============================================================================+
|                          TLBIDX CONTROL REGISTER                             |
+==============================================================================+
|    Field    |  Bits  | Width | Description                                   |
+-------------+--------+-------+-----------------------------------------------+
| NE          |   31   |   1   | 0 = found/hit, 1 = not found (search result)  |
| PS          |  29:24 |   6   | Page size (e.g., 12 for 4KB)                  |
| I_D         |   16   |   1   | 0 = iTLB, 1 = dTLB                            |
| INDEX       |   4:0  |   5   | Entry index (0..31) for read/write            |
+-------------+--------+-------+-----------------------------------------------+

+==============================================================================+
|                         EXAMPLE: DTLB ENTRY                                  |
+==============================================================================+
| Virtual address:     0x20001000 (page offset 0x000)                          |
| VPPN = 0x10008 (0x20001000 >> 13)                                            |
| ASID = 0x123                                                                 |
| MAT  = 0x3                                                                   |
| PLV  = 0x0                                                                   |
| G    = 1                                                                     |
| D    = 1                                                                     |
| V    = 0          ← invalid → PIS exception on store                         |
| E    = 1                                                                     |
| PPN  = 0x1c0001                                                              |
| TLBIDX.I_D = 1 (dTLB), INDEX selected by TLBFILL.                            |
+==============================================================================+
`````

----------

## Build and Test



### Build cpu7b


`````shell
u@uu:~/prjs/cpu7b$ cd systhesis/altera/
u@uu:~/prjs/cpu7b/systhesis/altera$ make
`````

### Run tests

`````shell
u@unamed:~/prjs/cpu7b/simulation$ ./run_all_tests.sh 

`````

## Debug

#### Test code

`````shell
u@uu:~/prjs/cpu7b/simulation/test0$ vim testcode/start.S
`````

#### Compile and Simulate

`````shell
u@uu:~/prjs/cpu7b/simulation/test0$ ./simulate.sh 
`````

#### View the Signals 

`````shell
u@uu:~/prjs/cpu7b/simulation/test0$ ./viewwave.sh
`````


