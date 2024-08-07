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
          |                    |      +----------+
          |                    |      |          |
      ----|                    |------|          |
 (DMA)    |     axi_matrix     |      | VGA RAM  |
      ----|        2x2         |------|          |
          |                    |      |          |
          |                    |      +----------+
          +--------------------+
                 |      |
                 |      |
               +----------+              
               |          |
               |          |
               |   SRAM   |
               |          |
               |          |
               +----------+


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

## CSR registers

`````
  0x0  CRMD.ie CRMD.plv
  
  0x1  PRMD.pie PRMD.pplv

  0x5  ESTAT

  0x6  ERA
  
  0x7  BADV

  0xc  EENTRY

  0x41 TCFG

  0x42 TVAL
  
  0x43 TICLR
`````

## Exceptions

- Load/Store Address Misaligned

- Illegal Instruction

- TIMER INTERRUPT

-----------------------------------------


### To do ...

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






## Build and Test



### Build cpu7b


`````shell
u@uu:~/prjs/cpu7b$ cd systhesis/altera/
u@uu:~/prjs/cpu7b/systhesis/altera$ make
`````

`````

### Run all the tests

`````shell
u@unamed:~/prjs/cpu7b/simulation$ ./run_all_tests.sh 
run tests

test0
# PASS!

test1_ld.w
# PASS!

test3_st.w
# PASS!

test4_beq
# PASS!

test5_jirl
# PASS!

test6_beq_testbyp
# PASS!

test8_mulw
# PASS!

test9_mulhwu
# PASS!

test10_mulhw
# PASS!

test11_csrrd
# PASS!

test12_csrwr
# PASS!

test13_csrxchg
# PASS!

test14_csr_crmd
# PASS!

test15_csr_prmd
# PASS!

test16_ale_exception
# PASS!

test17_exception_crmd_prmd
# PASS!

test18_csr_badv
# PASS!

test19_csr_tcfg
# PASS!

test20_csr_tcfg_periodic
# PASS!

test21_timer_intr_right_after_branch
# PASS!

test22_timer_intr_on_pipeline_bubble
# PASS!

test23_lsu_stall_ifu_at_e
# PASS!

test24_beq_ld.w
# PASS!

test25_lsu_stall
# PASS!

test26_illinstr_exception
# PASS!

test27_estat
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

---------------------------
---------------------------
---------------------------


