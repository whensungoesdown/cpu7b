#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"


##s0, number
##s1, number adress 
##s2, exception use
##s3, score
##s4, exception pc

.data

#var1:	.word	0x00000033

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:

	# setup fault handler
	lu12i.w  $r6, 0x1c000
	addi.w   $r6, $r6, 0x30          # fault_handler 
	csrwr    $r6, 0xc                # EENTRY
	
	addi.w   $r5, $r0, 0xa

	addi.w   $r6, $r0, 0x4           # 
	csrwr    $r6, 0x0                # CRMD.ie = 1
	addi.w   $r6, $r0, 0x23          # 3'b100011   initval=1000  periodic=1 en=1
	csrwr    $r6, 0x41               # TCFG


	# loop until r5 becomes 0x5a
loop:
	addi.w   $r6, $r0, 0x5a
	bne      $r5, $r6, loop
	nop
	nop

fault_handler:
	
	# read out BADV
	#csrrd    $r5, 0x7

	# write 1'b1 to TICLR (0x44)
	addi.w   $r11, $r0, 0x1
	csrwr    $r11, 0x44

	addi.w   $r5, $r5, 0x10
	ertn

	nop
	nop
	nop
