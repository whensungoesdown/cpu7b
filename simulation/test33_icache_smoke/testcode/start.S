#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"


##s0, number
##s1, number adress 
##s2, exception use
##s3, score
##s4, exception pc

.data

var1:	.word	0x0000002a

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:

	# setup fault handler
	lu12i.w  $r6, 0x1c000
	addi.w   $r6, $r6, 0x70          # fault_handler 
	csrwr    $r6, 0xc                # EENTRY
	
	addi.w   $r6, $r0, 0x4           # 
	csrwr    $r6, 0x0                # CRMD.ie = 1
	
	lu12i.w  $r7, 0x1c000
	ld.w $r8, $r7, 0x20
	ld.w $r9, $r7, 0x24

	# do not enable timer
	#addi.w   $r6, $r0, 0x11          # 3'b10001   initval=100  periodic=0 en=1
	#csrwr    $r6, 0x41               # TCFG


	nop
	nop
	nop
	nop

	nop                              
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	addi.w  $r6, $r0, 0x5a
loop:
	bne $r5, $r6, loop

	nop
	nop
	nop
	nop

fault_handler:
	
	# read out BADV
	#csrrd    $r5, 0x7

	# write 1'b1 to TICLR (0x44)
	#addi.w   $r11, $r0, 0x1
	#csrwr    $r11, 0x44

	csrrd    $r11, 0x5          # estat
        addi.w   $r12, $r0, 0x10    # estat.is.HWI0 should be 1
	bne      $r11, $r12, skip

	addi.w   $r5, $r0, 0x5a

skip:
	nop

# ext_intr is pulled by testbench
# it should write some register to let ext_intr go low, instead, wait for ext_intr becoming low

wait_for_ext_intr_low:
	csrrd    $r11, 0x5          # estat
	bne      $r11, $r0, wait_for_ext_intr_low

	ertn

	nop
	nop
	nop
