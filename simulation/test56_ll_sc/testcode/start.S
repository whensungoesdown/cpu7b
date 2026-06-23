# Test the validity of ll.w/sc.w instructions (atomic load-linked/store-conditional)
# On success: r5 = 0x5a, on failure: r5 = 0
# No exception handling required, fully self-contained

.data
var:    .word   0x20               # 待测试的共享变量，初始值 0x20

.text
.globl  _start
.globl  start

_start:
start:
    # 1) 加载变量地址到 t0
    la      $t0, var

    # 2) 原子递增：使用 LL/SC 实现
retry:
    ll.w    $t1, $t0, 0         # 加载链接：t1 = *var
    addi.w  $t2, $t1, 1         # t2 = t1 + 1
    sc.w    $t2, $t0, 0         # 条件存储：若 LL 保留未失效，则 *var = t2，并 t2 = 1；否则 t2 = 0
    beq     $t2, $zero, retry   # 若 sc.w 失败（t2 == 0），则重试

    # 3) 校验最终值是否确实为 0x21
    ld.w    $t4, $t0, 0         # 重新读回 var
    addi.w  $t5, $zero, 0x21    # 期望值 0x21
    bne     $t4, $t5, fail      # 若结果不是 0x21，跳转失败

    # 4) 成功：r5 = 0x5a
    addi.w  $r5, $zero, 0x5a
    b       success

fail:
    # 失败：r5 = 0
    addi.w  $r5, $zero, 0

success:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
