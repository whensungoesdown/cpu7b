#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.data

var1:	.word	0x00000033

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:
    addi.w  $r6, $r0, 0
    lu12i.w $r6, 0x1c000
    addi.w  $r6, $r6, 0x24 
#    la $r7, var1
    
    addi.w $r7, $r0, 0x5a
# rd is the data to be stored
    st.w $r7, $r6, 0x0
#    nop
    ld.w $r5, $r6, 0x0
    addi.w $r0, $r0, 0x0
    nop
    nop
