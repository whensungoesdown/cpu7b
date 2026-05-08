

.data

.text
.globl _start
.globl start
.globl __main
_start:
start:

    # ========== 测试 SAVE0 (地址 0x30) ==========
    li.w    $r6, 0x12345678
    csrwr   $r6, 0x30               # SAVE0 = 0x12345678
    csrrd   $r7, 0x30               # r7 = SAVE0
    li.w    $r8, 0x12345678
    bne     $r7, $r8, test_fail

    li.w    $r6, 0x0000AAAA
    li.w    $r7, 0x0000FFFF
    csrxchg $r6, $r7, 0x30          # 低16位写0xAAAA，高16位不变 -> SAVE0=0x1234AAAA，r6得到旧值0x12345678
    li.w    $r8, 0x12345678
    bne     $r6, $r8, test_fail
    csrrd   $r7, 0x30
    li.w    $r8, 0x1234AAAA
    bne     $r7, $r8, test_fail

    # ========== 测试 SAVE1 (地址 0x31) ==========
    li.w    $r6, 0x9ABCDEF0
    csrwr   $r6, 0x31
    csrrd   $r7, 0x31
    li.w    $r8, 0x9ABCDEF0
    bne     $r7, $r8, test_fail

    li.w    $r6, 0x55555555
    li.w    $r7, 0xFFFFFFFF
    csrxchg $r6, $r7, 0x31          # 全部写0x55555555，r6得到旧值
    li.w    $r8, 0x9ABCDEF0
    bne     $r6, $r8, test_fail
    csrrd   $r7, 0x31
    li.w    $r8, 0x55555555
    bne     $r7, $r8, test_fail

    # ========== 测试 SAVE2 (地址 0x32) ==========
    li.w    $r6, 0xDEADBEEF
    csrwr   $r6, 0x32
    csrrd   $r7, 0x32
    li.w    $r8, 0xDEADBEEF
    bne     $r7, $r8, test_fail

    li.w    $r6, 0x0000FFFF
    li.w    $r7, 0x0000FFFF
    csrxchg $r6, $r7, 0x32          # 低16位写0xFFFF，高16位不变 -> SAVE2=0xDEADFFFF
    csrrd   $r7, 0x32
    li.w    $r8, 0xDEADFFFF
    bne     $r7, $r8, test_fail

    # ========== 测试 SAVE3 (地址 0x33) ==========
    li.w    $r6, 0xCAFEBABE
    csrwr   $r6, 0x33
    csrrd   $r7, 0x33
    li.w    $r8, 0xCAFEBABE
    bne     $r7, $r8, test_fail

    li.w    $r6, 0x00000000
    li.w    $r7, 0xFFFFFFFF
    csrxchg $r6, $r7, 0x33          # 全部清零，r6得到旧值
    li.w    $r8, 0xCAFEBABE
    bne     $r6, $r8, test_fail
    csrrd   $r7, 0x33
    li.w    $r8, 0x00000000
    bne     $r7, $r8, test_fail

    # ========== 所有测试通过 ==========
    li.w    $r5, 0x5a
    b       test_pass

test_fail:
    #b       test_fail

test_pass:
    nop
    nop
    nop
    nop
    nop
