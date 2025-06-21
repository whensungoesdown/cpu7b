
./obj/main.elf:     file format elf32-loongarch
./obj/main.elf


Disassembly of section .text:

1c000000 <_start>:
kernel_entry():
1c000000:	14380006 	lu12i.w	$r6,114688(0x1c000)
1c000004:	0281c0c6 	addi.w	$r6,$r6,112(0x70)
1c000008:	04003026 	csrwr	$r6,0xc
1c00000c:	02801006 	addi.w	$r6,$r0,4(0x4)
1c000010:	04000026 	csrwr	$r6,0x0
1c000014:	14380007 	lu12i.w	$r7,114688(0x1c000)
1c000018:	288080e8 	ld.w	$r8,$r7,32(0x20)
1c00001c:	288090e9 	ld.w	$r9,$r7,36(0x24)
1c000020:	02800000 	addi.w	$r0,$r0,0
1c000024:	02800000 	addi.w	$r0,$r0,0
1c000028:	02800000 	addi.w	$r0,$r0,0
1c00002c:	02800000 	addi.w	$r0,$r0,0
1c000030:	02800000 	addi.w	$r0,$r0,0
1c000034:	02800000 	addi.w	$r0,$r0,0
1c000038:	02800000 	addi.w	$r0,$r0,0
1c00003c:	02800000 	addi.w	$r0,$r0,0
1c000040:	02800000 	addi.w	$r0,$r0,0
1c000044:	02800000 	addi.w	$r0,$r0,0
1c000048:	02800000 	addi.w	$r0,$r0,0
1c00004c:	02800000 	addi.w	$r0,$r0,0
1c000050:	02800000 	addi.w	$r0,$r0,0
1c000054:	02800000 	addi.w	$r0,$r0,0
1c000058:	02816806 	addi.w	$r6,$r0,90(0x5a)

1c00005c <loop>:
loop():
1c00005c:	5c0000a6 	bne	$r5,$r6,0 # 1c00005c <loop>
1c000060:	02800000 	addi.w	$r0,$r0,0
1c000064:	02800000 	addi.w	$r0,$r0,0
1c000068:	02800000 	addi.w	$r0,$r0,0
1c00006c:	02800000 	addi.w	$r0,$r0,0

1c000070 <fault_handler>:
fault_handler():
1c000070:	0400140b 	csrrd	$r11,0x5
1c000074:	0280400c 	addi.w	$r12,$r0,16(0x10)
1c000078:	5c00096c 	bne	$r11,$r12,8(0x8) # 1c000080 <skip>
1c00007c:	02816805 	addi.w	$r5,$r0,90(0x5a)

1c000080 <skip>:
skip():
1c000080:	02800000 	addi.w	$r0,$r0,0

1c000084 <wait_for_ext_intr_low>:
wait_for_ext_intr_low():
1c000084:	0400140b 	csrrd	$r11,0x5
1c000088:	5ffffd60 	bne	$r11,$r0,-4(0x3fffc) # 1c000084 <wait_for_ext_intr_low>
1c00008c:	06483800 	ertn
1c000090:	02800000 	addi.w	$r0,$r0,0
1c000094:	02800000 	addi.w	$r0,$r0,0
1c000098:	02800000 	addi.w	$r0,$r0,0

Disassembly of section .data:

1c00009c <var1>:
var1():
1c00009c:	0000002a 	0x0000002a
