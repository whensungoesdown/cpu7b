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
	addi.w $r3, $r0, -0x01
	addi.w $r4, $r0, -0x01
	mul.w  $r5, $r3, $r4          # r5 = 0x01
	addi.w $r4, $r0, 0x10
	mul.w  $r5, $r5, $r4          # r5 = 0x10
	addi.w $r4, $r0, 0x5
	mul.w  $r5, $r5, $r4          # r5 = 0x50
	addi.w $r5, $r5, 0xa          # r5 = 0x5a
	nop
	nop
	nop
	nop
	nop
