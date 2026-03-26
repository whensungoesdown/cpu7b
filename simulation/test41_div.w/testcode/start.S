#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.text
.globl _start
.globl start
.globl __main

_start:
start:
    # ========== div.w 测试用例 ==========
    
    addi.w  $r5, $r0, 0

    # 测试1: 正数除法，普通情况
    # 10 / 3 = 3
    addi.w  $r10, $r0, 10
    addi.w  $r11, $r0, 3
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 3
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试2: 正数除法，整除情况
    # 20 / 5 = 4
    addi.w  $r10, $r0, 20
    addi.w  $r11, $r0, 5
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 4
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试3: 正数除法，除数大于被除数
    # 5 / 10 = 0
    addi.w  $r10, $r0, 5
    addi.w  $r11, $r0, 10
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试4: 正数除法，除数为1
    # 0x12345678 / 1 = 0x12345678
    # 0x12345678 = 0x12345 << 12 | 0x678 (0x12345 = 74565 > 524287? 74565 < 524287，合法)
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 1
    div.w   $r6, $r10, $r11
    lu12i.w $r7, 0x12345
    ori     $r7, $r7, 0x678
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试5: 正数除法，最大边界值
    # 0x7fffffff / 16 = 0x7ffffff
    # 0x7fffffff = 0x7ffff << 12 | 0xfff (0x7ffff = 524287，合法)
    lu12i.w $r10, 0x7ffff
    ori     $r10, $r10, 0xfff
    addi.w  $r11, $r0, 16
    div.w   $r6, $r10, $r11
    lu12i.w $r7, 0x7ffff
    ori     $r7, $r7, 0xfff
    srli.w  $r7, $r7, 4
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试6: 正数除法，被除数为0
    # 0 / 5 = 0
    addi.w  $r10, $r0, 0
    addi.w  $r11, $r0, 5
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试7: 负数除法，被除数为负
    # -10 / 3 = -3
    addi.w  $r10, $r0, -10
    addi.w  $r11, $r0, 3
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, -3
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试8: 负数除法，除数为负
    # 10 / -3 = -3
    addi.w  $r10, $r0, 10
    addi.w  $r11, $r0, -3
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, -3
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试9: 负数除法，两者都为负
    # -10 / -3 = 3
    addi.w  $r10, $r0, -10
    addi.w  $r11, $r0, -3
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 3
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试10: 负数除法，除数绝对值大于被除数绝对值
    # -5 / 7 = 0
    addi.w  $r10, $r0, -5
    addi.w  $r11, $r0, 7
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试11: 负数除法，最小负数边界
    # -2147483648 / 1 = -2147483648
    # 0x80000000 = 0x7fffffff + 1
    lu12i.w $r10, 0x7ffff
    ori     $r10, $r10, 0xfff
    addi.w  $r10, $r10, 1
    addi.w  $r11, $r0, 1
    div.w   $r6, $r10, $r11
    lu12i.w $r7, 0x7ffff
    ori     $r7, $r7, 0xfff
    addi.w  $r7, $r7, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
# -->
    # 测试12: 负数除法，最小负数除以-1
    # -2147483648 / -1 = 2147483648
    # 0x80000000 / -1 = 0x80000000  结果应该为?
    lu12i.w $r10, 0x7ffff
    ori     $r10, $r10, 0xfff
    addi.w  $r10, $r10, 1
    addi.w  $r11, $r0, -1
    div.w   $r6, $r10, $r11
    li.w    $r7, 0x80000000
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试13: 大数除法
    # 0xdeadbeef / 0x1000 = 0xfffdeadc
    # −559038737 ÷ 4096 = −136484
    li.w    $r10, 0xdeadbeef
    li.w    $r11, 0x1000
    div.w   $r6, $r10, $r11
    li.w    $r7, 0xfffdeadc
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试14: 被除数等于除数
    # 0x234 / 0x234 = 1
    addi.w  $r10, $r0, 0x234
    addi.w  $r11, $r0, 0x234
    div.w   $r6, $r10, $r11
    addi.w  $r7, $r0, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试15: 除数为2的幂
    # 0x12345678 / 0x20 = 0x91a2b3
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 32
    div.w   $r6, $r10, $r11
    lu12i.w $r7, 0x91a
    ori     $r7, $r7, 0x2b3
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
