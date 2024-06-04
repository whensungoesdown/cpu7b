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
	addi.w   $r6, $r6, 0x40          # fault_handler 
	csrwr    $r6, 0xc                # EENTRY
	
	# set crmd.plv crmd.ie to all 1s
	addi.w   $r6, $r0, 0xff
	csrwr    $r6, 0x0
	
	# trigger ale exception
	lu12i.w  $r5, 0x1c000            # r5 = 1c000000
	addi.w   $r5, $r5, 0x51          # r5 = 1c000051
	st.w     $r7, $r5, 0x0

	# read CRMD, should remains 0x7
	csrrd    $r6, 0x0
	
	# after this, r5 should be 0xe
	add.w    $r5, $r5, $r6

	addi.w   $r5, $r5, 0x4c     

	nop
	nop
	nop
	nop
	nop

fault_handler:
	
	# read PRMD, should be 0x7
	csrrd    $r11, 0x1
	
	# r5 should be 0x7
	addi.w   $r5, $r11, 0x0

	# set CRMD to all 0s. crmd should be restored when ertn returns
	addi.w   $r11, $r0, 0x0
	csrwr    $r11, 0x0

	# skip faulting instruction
	csrrd    $r11, 0x6               # 0x6 ERA
	addi.w   $r11, $r11, 0x4
	csrwr    $r11, 0x6
	ertn

	nop
	nop
	nop
