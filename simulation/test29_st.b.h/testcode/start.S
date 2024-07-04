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
    addi.w  $r6, $r6, 0xb4 

    addi.w  $r5, $r0, 0x0
#    la $r7, var1
    
    addi.w $r7, $r0, 0x255

# rd is the data to be stored
    st.b $r7, $r6, 0x0
    ld.w $r8, $r6, 0x0

    addi.w $r9, $r0, 0x55
    bne $r9, $r8, skip0

    addi.w $r5, $r5, 0x10

skip0:
    st.h $r7, $r6, 0x0
    nop
    nop
    nop
    nop
    ld.w $r8, $r6, 0x0

    addi.w $r9, $r0, 0x255
    bne $r9, $r8, skip1

    addi.w $r5, $r5, 0x18
skip1:
    st.b $r7, $r6, 0x1
    nop
    nop
    nop
    nop
    ld.w $r8, $r6, 0x0

    lu12i.w $r9, 0x00005
    addi.w $r9, $r9, 0x555    # r9=0x00005555
    bne $r9, $r8, skip2

    addi.w $r5, $r5, 0x28
skip2:
    st.h $r7, $r6, 0x2
    nop
    nop
    nop
    nop
    ld.w $r8, $r6, 0x0

    lu12i.w $r9, 0x02555
    addi.w $r9, $r9, 0x555    # r9=0x02555555
    bne $r9, $r8, skip3

    addi.w $r5, $r5, 0x0a
skip3:
    nop
    nop
    nop
    nop
    nop
    nop
