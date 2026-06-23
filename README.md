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
 |      | |  |                 |       |  |           |    |        |    |  div  |    |    |
 |      | |  |                 |       |  |    lsu    |    |        |    |       |    |    |
 |      | |  +-----------------+       |  |           |    +--------+    +-------+    |    |
 |      | |    | |                     |  +------------                               |    |
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

### Miscellaneous


`````assembly
  ERTN SYSCALL BREAK RDCNTV{L/H}.W
`````

## To Do

- [ ] Memory access: `PRELD`
- [ ] Floating-point instructions
- [ ] Cache and TLB instructions
- [ ] Miscellaneous: `RDCNTID`, `IDLE`

---

## CSR Registers

| Address | Register | Description          |
|---------|----------|----------------------|
| 0x0     | CRMD     | Current Mode Information |
| 0x1     | PRMD     | Pre-exception Mode Information |
| 0x5     | ESTAT    | Exception Status     |
| 0x6     | ERA      | Exception Return Address |
| 0x7     | BADV     | Bad Virtual Address |
| 0xc     | EENTRY   | Exception Entry Base Address |
| 0x30~0x33| SAVE0~SAVE3 | Data Save Register |
| 0x41    | TCFG     | Timer Configuration  |
| 0x42    | TVAL     | Timer Value          |
| 0x43    | TICLR    | Timer Interrupt Clearing |
| 0x60    | LLBCTL   | LLBit Controller     |

---

## Exceptions

- 0x8 ADdress error Exception for Fetching instructions (ADEF)
- 0x8 ADdress error Exception for Memory access instructions (ADEM)
- 0x9 Address aLignment fault Exception (ALE)
- 0xB SYStem call exception (SYS)
- 0xC BReaKpoint exception (BRK)
- 0xD Instruction Non-defined Exception (INE)
- 0x0 Timer Interrupt
- 0x0 Ext Interrupt
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


