#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.text
.globl _start
.globl start
.globl __main

_start:
start:
    # ========== mod.w 测试用例 ==========
    
    addi.w  $r5, $r0, 0

    # 测试1: 正数取模，普通情况
    # 10 % 3 = 1
    addi.w  $r10, $r0, 10
    addi.w  $r11, $r0, 3
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试2: 正数取模，整除情况
    # 20 % 5 = 0
    addi.w  $r10, $r0, 20
    addi.w  $r11, $r0, 5
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试3: 正数取模，除数大于被除数
    # 5 % 10 = 5
    addi.w  $r10, $r0, 5
    addi.w  $r11, $r0, 10
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 5
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试4: 正数取模，除数为1
    # 0x12345678 % 1 = 0
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 1
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试5: 正数取模，最大边界值
    # 0x7fffffff % 16 = 15
    lu12i.w $r10, 0x7ffff
    ori     $r10, $r10, 0xfff
    addi.w  $r11, $r0, 16
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 15
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试6: 正数取模，被除数为0
    # 0 % 5 = 0
    addi.w  $r10, $r0, 0
    addi.w  $r11, $r0, 5
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试7: 负数取模，被除数为负
    # -10 % 3 = -1
    addi.w  $r10, $r0, -10
    addi.w  $r11, $r0, 3
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, -1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试8: 负数取模，除数为负
    # 10 % -3 = 1
    addi.w  $r10, $r0, 10
    addi.w  $r11, $r0, -3
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试9: 负数取模，两者都为负
    # -10 % -3 = -1
    addi.w  $r10, $r0, -10
    addi.w  $r11, $r0, -3
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, -1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试10: 负数取模，除数绝对值大于被除数绝对值
    # -5 % 7 = -5
    addi.w  $r10, $r0, -5
    addi.w  $r11, $r0, 7
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, -5
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试11: 负数取模，最小负数边界
    # -2147483648 % 1 = 0
    lu12i.w $r10, 0x7ffff
    ori     $r10, $r10, 0xfff
    addi.w  $r10, $r10, 1
    addi.w  $r11, $r0, 1
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试12: 负数取模，最小负数除以-1
    # -2147483648 % -1 = 0
    lu12i.w $r10, 0x7ffff
    ori     $r10, $r10, 0xfff
    addi.w  $r10, $r10, 1
    addi.w  $r11, $r0, -1
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试13: 大数取模
    # 0xdeadbeef % 0x1000 = 0xef
    # −559038737 ÷ 4096 = −136484
    # −559038737 % 4096 = −273 (FFFFFEEF)
    li.w    $r10, 0xdeadbeef
    li.w    $r11, 0x1000
    mod.w   $r6, $r10, $r11
    li.w    $r7, 0xfffffeef
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试14: 被除数等于除数
    # 0x234 % 0x234 = 0
    addi.w  $r10, $r0, 0x234
    addi.w  $r11, $r0, 0x234
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试15: 除数为2的幂
    # 0x12345678 % 0x20 = 0x18
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 32
    mod.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0x18
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
