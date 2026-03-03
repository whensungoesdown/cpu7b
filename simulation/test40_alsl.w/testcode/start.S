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
        addi.w  $r23, $r0, 0xa 	
        addi.w  $r10, $r0, 0xa 	
        alsl.w  $r5,$r23,$r10,0x3
        nop
        nop
        nop
        nop
        nop
        nop
        nop
