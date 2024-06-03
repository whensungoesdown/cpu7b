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
	
	addi.w   $r6, $r0, 0xff          # r6 = ff
	csrwr    $r6, 0x1                # 0x0 PRMD     PRMD only has pplv and pie, should be writen in 3'b111
#	nop
	addi.w   $r5, $r0, 0x66
	addi.w   $r7, $r0, 0xf0
	csrxchg  $r5, $r7, 0x1           # mask 11110000, nothing will be write in, PRMD remains 0x7, r5 should be the old PRMD value, 0x7
	csrrd    $r8, 0x1                # r8 should be 0x7
	addi.w   $r6, $r0, 0x66
	addi.w   $r7, $r0, 0x0f
	csrxchg  $r6, $r7, 0x1           # mask 00001111, 0x06 should be write in, r6 should have the old PRMD value, 0x7
	csrrd    $r9, 0x1                # r9 should be 0x6
	nop
	nop
	nop
	nop
	nop
