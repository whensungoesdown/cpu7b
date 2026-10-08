#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.data

var1:	.word	0x000000cc
var2:	.word	0x0000005a

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:
    lu12i.w $r13, 0x1c000
    addi.w  $r12, $r0, 0x2c

    add.w   $r12,$r13,$r12
    ld.w    $r12,$r12,0 

    addi.w    $r5, $r12, 0
    nop
    nop
    nop
    nop
    nop
//addi.w  $r12, $r0, 0
//lu12i.w $r13, 0x7fb5e
//ori     $r13,$r13,0xa40

