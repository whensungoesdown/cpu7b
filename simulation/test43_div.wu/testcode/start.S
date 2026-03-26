#include "asm.h"
#include "regdef.h"
#include "cpu_cde.h"

.text
.globl _start
.globl start
.globl __main

_start:
start:
    # ========== div.wu 测试用例 ==========
    
    addi.w  $r5, $r0, 0

    # 测试1: 无符号除法，普通情况
    # 10 / 3 = 3
    addi.w  $r10, $r0, 10
    addi.w  $r11, $r0, 3
    div.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 3
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试2: 无符号除法，整除情况
    # 20 / 5 = 4
    addi.w  $r10, $r0, 20
    addi.w  $r11, $r0, 5
    div.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 4
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试3: 无符号除法，除数大于被除数
    # 5 / 10 = 0
    addi.w  $r10, $r0, 5
    addi.w  $r11, $r0, 10
    div.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试4: 无符号除法，除数为1
    # 0x12345678 / 1 = 0x12345678
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 1
    div.wu  $r6, $r10, $r11
    lu12i.w $r7, 0x12345
    ori     $r7, $r7, 0x678
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试5: 无符号除法，最大边界值
    # 0xffffffff / 16 = 0x0fffffff
    li.w    $r10, 0xffffffff
    addi.w  $r11, $r0, 16
    div.wu  $r6, $r10, $r11
    li.w    $r7, 0x0fffffff
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试6: 无符号除法，被除数为0
    # 0 / 5 = 0
    addi.w  $r10, $r0, 0
    addi.w  $r11, $r0, 5
    div.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试7: 无符号除法，大数除以小数
    # 0xffffffff / 0x1234 = 0xe1042
    li.w    $r10, 0xffffffff
    li.w    $r11, 0x1234
    div.wu  $r6, $r10, $r11
    li.w    $r7, 0xe1042
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试8: 无符号除法，除数为2的幂
    # 0x12345678 / 0x20 = 0x91a2b3
    lu12i.w $r10, 0x12345
    ori     $r10, $r10, 0x678
    addi.w  $r11, $r0, 32
    div.wu  $r6, $r10, $r11
    lu12i.w $r7, 0x91a
    ori     $r7, $r7, 0x2b3
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试9: 无符号除法，被除数等于除数
    # 0x234 / 0x234 = 1
    addi.w  $r10, $r0, 0x234
    addi.w  $r11, $r0, 0x234
    div.wu  $r6, $r10, $r11
    addi.w  $r7, $r0, 1
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试10: 无符号除法，高32位为0的低32位大数
    # 0x80000000 / 0x2000 = 0x40000
    li.w    $r10, 0x80000000
    li.w    $r11, 0x2000
    div.wu  $r6, $r10, $r11
    li.w    $r7, 0x40000
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试11: 无符号除法，被除数高位非零
    # 0xffffffff / 0xffff = 0x10001
    li.w    $r10, 0xffffffff
    li.w    $r11, 0xffff
    div.wu  $r6, $r10, $r11
    li.w    $r7, 0x10001
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试12: 无符号除法，被除数接近最大值，除数为大数
    # 0xfffffffe / 0x7fffffff = 2
    li.w    $r10, 0xfffffffe
    li.w    $r11, 0x7fffffff
    div.wu  $r6, $r10, $r11
    li.w    $r7, 2
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试13: 无符号除法，被除数小于除数
    # 0x1000 / 0x2000 = 0
    li.w    $r10, 0x1000
    li.w    $r11, 0x2000
    div.wu  $r6, $r10, $r11
    li.w    $r7, 0
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试14: 无符号除法，大数除以2的幂
    # 0xdeadbeef / 0x1000 = 0xdeadb
    li.w    $r10, 0xdeadbeef
    li.w    $r11, 0x1000
    div.wu  $r6, $r10, $r11
    li.w    $r7, 0xdeadb
    addi.w  $r5, $r5, 1
    bne     $r6, $r7, test_fail
    
    # 测试15: 无符号除法，被除数为全1，除数为自身
    # 0xffffffff / 0xffffffff = 1
    li.w    $r10, 0xffffffff
    li.w    $r11, 0xffffffff
    div.wu  $r6, $r10, $r11
    li.w    $r7, 1
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
