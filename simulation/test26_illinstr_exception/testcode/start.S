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
	lu12i.w  $r6, 0x1c000
	addi.w   $r6, $r6, 0x30          # fault_handler 
	csrwr    $r6, 0xc                # EENTRY
	lu12i.w  $r5, 0x1c000            # r5 = 1c000000
	addi.w   $r5, $r5, 0x51          # r5 = 1c000051
#	st.w     $r7, $r5, 0x0
	.word    0xffffffff
	addi.w   $r5, $r0, 0x2a     
	nop
	nop
	nop
	nop
	nop
fault_handler:
	# skip faulting instruction 
	lu12i.w  $r6, 0x000d0
	csrrd    $r11, 0x5               # 0x5 ESTAT
        bne      $r11, $r6, exit     
        addi.w   $r5, $r0, 0x5a
exit:
	csrrd    $r11, 0x6               # 0x6 ERA
	addi.w   $r11, $r11, 0x8
	csrwr    $r11, 0x6
	ertn
	nop
	nop
	nop
