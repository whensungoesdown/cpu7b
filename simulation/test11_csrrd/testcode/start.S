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
	
	lu12i.w  $r5, 0x1c000            # r5 = 1c000000
	addi.w   $r5, $r5, 0x7ff         # r5 = 1c000000
	csrrd    $r5, 0x0                # crmd
	addi.w   $r5, $r5, 0x5a     
	nop
	nop
	nop
	nop
	nop
