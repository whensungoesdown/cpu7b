#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.data

var1:	.word	0xfffff250

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:

    addi.w $r5, $r0, 0x0

    lu12i.w $r6, 0x1c000
    addi.w  $r6, $r6, 0x70 
#    la $r7, var1

    ld.b $r7, $r6, 0x0
    addi.w $r8,$r0, 0x50 
    
    bne $r8, $r7, skip0
    addi.w $r5, $r5, 0x10

skip0:
    ld.bu $r7, $r6, 0x0
    bne $r8, $r7, skip1
    addi.w $r5, $r5, 0x18
skip1:
    ld.h $r7, $r6, 0x0
    lu12i.w $r8, 0x7ffff
    add.w   $r8, $r8, $r8
    lu12i.w $r9, 0x1
    add.w   $r8, $r8, $r9 
    addi.w  $r8, $r8, 0x250          #r8 = 0xfffff250
    bne $r8, $r7, skip2
    addi.w $r5, $r5, 0x28
skip2:
    ld.hu $r7, $r6, 0x0
    lu12i.w $r8, 0xf
    addi.w  $r8, $r8, 0x250 
    bne $r8, $r7, skip3
    addi.w $r5, $r5, 0xa
skip3:
    nop
    nop
    nop
    nop
    nop
