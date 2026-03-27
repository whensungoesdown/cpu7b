# CPU7B (LoongArch32 ISA)


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

### Miscellaneous


`````assembly
  ERTN
`````

## To Do

- [ ] Memory access: `PRELD`
- [ ] Atomic memory access: `LL.W`, `SC.W`
- [ ] Barrier instructions: `DBAR`, `IBAR`
- [ ] Floating-point instructions
- [ ] Cache and TLB instructions
- [ ] Miscellaneous: `SYSCALL`, `BREAK`, `RDCNTV{L/H}.W`, `RDCNTID`, `IDLE`

---

## CSR Registers

| Address | Register | Description          |
|---------|----------|----------------------|
| 0x0     | CRMD     | ie, plv              |
| 0x1     | PRMD     | pie, pplv            |
| 0x5     | ESTAT    | exception status     |
| 0x6     | ERA      | exception return address |
| 0x7     | BADV     | bad address          |
| 0xc     | EENTRY   | exception entry      |
| 0x41    | TCFG     | timer configuration  |
| 0x42    | TVAL     | timer value          |
| 0x43    | TICLR    | timer clear          |

---

## Exceptions

- Load/Store Address Misaligned
- Illegal Instruction
- Timer Interrupt
- Ext Interrupt
---




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


