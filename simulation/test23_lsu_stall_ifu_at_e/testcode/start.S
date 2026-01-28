#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"


##s0, number
##s1, number adress 
##s2, exception use
##s3, score
##s4, exception pc

.data

var1:	.word	0x0000002a

.text
	.globl	_start
	.globl	start
	.globl	__main
_start:
start:

	# setup fault handler
	lu12i.w  $r6, 0x1c000
	addi.w   $r6, $r6, 0x88          # fault_handler 
	csrwr    $r6, 0xc                # EENTRY
	
	addi.w   $r5, $r0, 0xa

	addi.w   $r6, $r0, 0x4           # 
	csrwr    $r6, 0x0                # CRMD.ie = 1
	addi.w   $r6, $r0, 0x11          # 3'b10001   initval=100  periodic=0 en=1
	csrwr    $r6, 0x41               # TCFG


#wait for timer intr to trigger
        addi.w   $r5, $r0, 0x0	
	nop
	nop
	nop
	nop
	nop

	lu12i.w  $r6, 0x1c000
	addi.w   $r6, $r6, 0xa8          # <--- timer interrupt here 
	ld.w     $r7, $r6, 0x0            
	bne      $r0, $r0, dst           # useless, just for interrupts on BRU could happen, to bypass this case temporarily

	nop                              
	nop                              
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
dst:
        add.w   $r5, $r5, $r7	
	nop
	nop
	nop
	nop

fault_handler:
	
	# read out BADV
	#csrrd    $r5, 0x7

	# write 1'b1 to TICLR (0x44)
	addi.w   $r11, $r0, 0x1
	csrwr    $r11, 0x44

	addi.w   $r5, $r5, 0x30
	ertn

	nop
	nop
	nop
	nop
