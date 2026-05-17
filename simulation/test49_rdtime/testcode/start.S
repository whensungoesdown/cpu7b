.data

.text
.globl _start
.globl start
.globl __main
_start:
start:

    # ========== 测试 rdcntvl.w 和 rdcntvh.w ==========
    # 第一次读取计数器
    rdcntvl.w $r6          # 低32位 -> r6
    rdcntvh.w $r7          # 高32位 -> r7
    # 保存第一次的64位值 (高: r10, 低: r9)
    or        $r9, $r6, $zero
    or        $r10, $r7, $zero

    # 延时循环，确保计数器明显增加
    li.w      $r12, 100
1:
    addi.w    $r12, $r12, -1
    bnez      $r12, 1b

    # 第二次读取计数器
    rdcntvl.w $r6          # 低32位 -> r6
    rdcntvh.w $r7          # 高32位 -> r7

    # 比较第二次是否大于第一次（64位无符号比较）
    # 先比较多高32位
    sltu      $t0, $r10, $r7      # t0 = (r10 < r7)
    beq       $r10, $r7, check_low
    bnez      $t0, inc_ok
    b         test_fail

check_low:
    sltu      $t0, $r9, $r6       # t0 = (r9 < r6)
    bnez      $t0, inc_ok
    beq       $r9, $r6, same_fail
    b         test_fail

same_fail:
    b         test_fail

inc_ok:
    # 所有测试通过
    li.w      $r5, 0x5a
    b         test_pass

test_fail:
    #b         test_fail

test_pass:
    nop
    nop
    nop
    nop
    nop
