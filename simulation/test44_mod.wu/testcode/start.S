#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.text
.globl _start
.globl start
.globl __main

_start:
start:
    # ========== mod.wu 测试用例 ==========
    
    addi.w  $r5, $r0, 0

    # 测试1: 无符号取模，普通情况
    # 10 % 3 = 1
    addi.w  $r10, $r0, 10
    addi.w  $r11, $r0, 3
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试2: 无符号取模，整除情况
    # 20 % 5 = 0
    addi.w  $r10, $r0, 20
    addi.w  $r11, $r0, 5
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试3: 无符号取模，除数大于被除数
    # 5 % 10 = 5
    addi.w  $r10, $r0, 5
    addi.w  $r11, $r0, 10
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 5
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试4: 无符号取模，除数为1
    # 0x12345678 % 1 = 0
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 1
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试5: 无符号取模，最大边界值
    # 0xffffffff % 16 = 15
    li.w    $r10, 0xffffffff
    addi.w  $r11, $r0, 16
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 15
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试6: 无符号取模，被除数为0
    # 0 % 5 = 0
    addi.w  $r10, $r0, 0
    addi.w  $r11, $r0, 5
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试7: 无符号取模，大数取模
    # 0xdeadbeef % 0x1000 = 0xeef
    li.w    $r10, 0xdeadbeef
    li.w    $r11, 0x1000
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 0xeef
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试8: 无符号取模，被除数等于除数
    # 0x234 % 0x234 = 0
    addi.w  $r10, $r0, 0x234
    addi.w  $r11, $r0, 0x234
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试9: 无符号取模，除数为2的幂
    # 0x12345678 % 0x20 = 0x18
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 32
    mod.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0x18
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试10: 无符号取模，被除数为全1，除数为大数
    # 0xffffffff % 0x7fffffff = 1
    li.w    $r10, 0xffffffff
    li.w    $r11, 0x7fffffff
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试11: 无符号取模，被除数为大数，除数为小数的2次幂
    # 0xffffffff % 0x2000 = 0x1fff
    li.w    $r10, 0xffffffff
    li.w    $r11, 0x2000
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 0x1fff
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试12: 无符号取模，除数接近被除数
    # 0x10000000 % 0x10000001 = 0x10000000
    li.w    $r10, 0x10000000
    li.w    $r11, 0x10000001
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 0x10000000
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试13: 无符号取模，被除数为大数，除数为2的幂减1
    # 0x12345678 % 0xff = 0x15
    li.w    $r10, 0x12345678
    li.w    $r11, 0xff
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 0x15
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试14: 无符号取模，被除数为最大值，除数为最大值
    # 0xffffffff % 0xffffffff = 0
    li.w    $r10, 0xffffffff
    li.w    $r11, 0xffffffff
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试15: 无符号取模，被除数低位有值，除数较小
    # 0xdeadbeef % 0x1234 = 0xbeef % 0x1234 = 0xbeef
    li.w    $r10, 0xdeadbeef
    li.w    $r11, 0x1234
    mod.wu  $r6, $r10, $r11
    li.w    $r7, 0x76b
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # ========== 所有测试通过 ==========
    addi.w  $r5, $r0, 0x5a    # r5 = 0x5a
    b       test_end
    
test_fail:
    # 测试失败，r5 = 0x0
    # addi.w  $r5, $r0, 0x0
    
test_end:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
