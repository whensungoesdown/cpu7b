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
	
	addi.w   $r6, $r0, 0x5a          # r5 = 5a
	csrwr    $r6, 0xc                # 0xc EENTRY
#	nop
	csrrd    $r5, 0xc                # 
	nop
	nop
	nop
	nop
	nop
