# CPU7B (LoongArch32 ISA)


More blogs are kept at:
- https://whensungoesdown.github.io

## Pipeline

Single issue, in order, 5-stage pipeline

_f _d _e _m _w


## Modules

`````c

                                    +----------------------------------------------+                               
                                    | EXU               +--------+    +-------+    |
                                    |     +---------+   |        |    |       |    |
                                    |     |         |   |        |    |  alu  |    |
 +-----------------------------+    |     |   csr   |   |        |    +-------+    |
 |IFU                          |    |     |         |   |        |    +-------+    |
 |    +----------+  +------+   |    |     +---------+   |        |    |  bru  |    |
 |    |          |  |      |   |    |     +---------+   |  ecl   |    |       |    |
 |    | ifu_fdp  |->|decode|.. | -> |     |         |   |   &    |    +-------+    |
 |    |          |  |      |   |    |     | regfile |   |  byp   |    +-------+    |
 |    +----------+  +------+   |    |     |         |   |        |    |       |    |
 |      |    |                 |    |     +-------- +   |        |    |  mul  |    |
 |      |    |                 |    |                   |        |    +-------+    |
 +------|----|-----------------+    |  +-----------+    |        |    +-------+    |          
        |    |                      |  |           |    |        |    |  div  |    |
        |    |                      |  |    lsu    |    |        |    |       |    |
        |    |                      |  |           |    +--------+    +-------+    |
        |    |                      |  +------------                               |
        |    |                      +-----|------|---------------------------------+
        |    |                            |      |
    +----------------------------------------------+
    |              axi interface                   |
    +----------------------------------------------+ 
                 |      |
                 |      |
          +--------------------+
          |                    |
          |      axi-sram      |
          |                    |
          +--------------------+

`````

## LA32 Instructions

### Implemented

- Integer Arithmetic Instructions

`````

  ADD.W SUB.W ADDI.W 

  LU12I.W PCADDU12I 

  SLT[U] SLT[U]I 

  AND OR NOR XOR

  ANDI ORI XORI

  NOP
`````
	
- Bit-Shift Instructions

`````
  SLL.W SRL.W SRA.W SLL.W SRL.W SRA.W

  SLLI.W SRLI.W SRAI.W
`````

- Branch Instructions

`````
  BEQ BNE BLT[U] BGE[U]

  B BL

  JIRL
`````

- Integer Multiply

`````
  MUL.W MULH.W[U]
`````

- Common Memory Access Instructions

`````
  LD.B LD.H LD.W LD.BU LD.HU LD.HU

  ST.B ST.H ST.W
`````

- CSR Access Instructions

`````
  CSRRD CSRWR CSRXCHG
`````

- Misc

`````
  ERTN
`````

### Implementing...

- Integer Divide Instructions

`````
  DIV.W[U]  MOD.W[U]
`````

- Common Memory Access Instructions

`````
  PRELD
`````

- Atomic Memory Access Instructions

`````
  LL.W SC.W
`````

- Barrier Instructions

`````
  DBAR IBAR
`````

- Floating-point Instructions

- Cache and TLB Instructions

- Misc

`````
  SYSCALL BREAK

  RDCNTV{L/H}.W RDCNTID

  IDLE
`````

## CSR registers

`````
  CRMD.ie CRMD.plv
  
  PRMD.pie PRMD.pplv

  EENTRY

  ERA
`````

## Exceptions

- Load/Store Address Misaligned

- Illegal Instruction





## Build and Test



### Build cpu7


`````shell
u@uu:~/prjs/cpu7b$ cd systhesis/altera/
u@uu:~/prjs/cpu7b/systhesis/altera$ make
`````

`````

### Run all the tests

`````shell
u@uu:~/prjs/cpu7b/simulation$ ./run_all_tests.sh 
run tests

test0
# PASS!

test1_ld.w
# PASS!

test3_st.w
# PASS!

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
