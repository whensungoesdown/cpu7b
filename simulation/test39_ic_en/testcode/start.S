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
	
        addi.w   $r5, $r0, 0x0a
        addi.w   $r5, $r5, 0x10
        addi.w   $r5, $r5, 0x10
	addi.w   $r6, $r0, 0x1           # r6 = 0x1
	csrwr    $r6, 0x101              # 
        addi.w   $r5, $r5, 0x1
        addi.w   $r5, $r5, 0x2
        addi.w   $r5, $r5, 0x3
        addi.w   $r5, $r5, 0x4
        addi.w   $r5, $r5, 0x6
        addi.w   $r5, $r5, 0x1
        addi.w   $r5, $r5, 0x2
        addi.w   $r5, $r5, 0x3
        addi.w   $r5, $r5, 0x4
        addi.w   $r5, $r5, 0x6
        addi.w   $r5, $r5, 0x1
        addi.w   $r5, $r5, 0x2
        addi.w   $r5, $r5, 0x3
        addi.w   $r5, $r5, 0x4
        addi.w   $r5, $r5, 0x6
        nop
