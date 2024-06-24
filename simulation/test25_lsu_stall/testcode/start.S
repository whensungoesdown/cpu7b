#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

#
# to test if stall makes subsequent instruction executed incorrectly 
#

.data

var1:	.word	0x0000002a

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:
    lu12i.w $r6, 0x1c000
    addi.w  $r6, $r6, 0x20 
#    la $r7, var1
    addi.w $r5, $r0, 0x10
    addi.w $r5, $r5, 0x10
    ld.w $r7, $r6, 0x0
    nop
exit:
    addi.w $r5, $r5, 0x3a
    nop
    nop
