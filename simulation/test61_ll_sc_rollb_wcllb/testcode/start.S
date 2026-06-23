# Test: WCLLB clears LLbit.
# 1) ll.w sets LLbit -> read ROLLB verify 1
# 2) Write WCLLB=1 -> read ROLLB verify 0
# 3) sc.w should fail (return 0)
# On success: r5 = 0x5a, on failure: r5 = 0.

.data
var:    .word   0x35            # initial value

.text
.globl  _start
.globl  start

_start:
start:
    la      $s0, var            # s0 = address of var

    # 1) LL: load var, set LLbit (ROLLB becomes 1)
    ll.w    $s1, $s0, 0         # s1 = *var, LLbit = 1

    # --- Verify ROLLB is 1 after ll.w ---
    csrrd   $t0, 0x60           # t0 = LLBCTL
    andi    $t0, $t0, 0x1       # extract ROLLB (bit0)
    beqz    $t0, fail           # if ROLLB == 0, ll.w failed to set LLbit

    # 2) Compute new value
    addi.w  $s2, $s1, 1         # s2 = s1 + 1

    # 3) Write WCLLB (bit1) to LLBCTL CSR to clear LLbit
    li.w    $t0, 0x2            # WCLLB mask (1 << 1)
    csrwr   $t0, 0x60           # LLBCTL = WCLLB

    # --- Verify ROLLB is 0 after WCLLB write ---
    csrrd   $t0, 0x60           # t0 = LLBCTL
    andi    $t0, $t0, 0x1       # extract ROLLB
    bnez    $t0, fail           # if ROLLB still 1, WCLLB failed to clear

    # 4) SC: should fail because LLbit was cleared
    sc.w    $s2, $s0, 0         # conditional store; should return 0 in s2

    # 5) Check sc.w result
    bnez    $s2, fail           # if s2 != 0, sc.w succeeded unexpectedly

    # 6) Verify memory was NOT modified (still 0x35)
    ld.w    $s3, $s0, 0
    li.w    $s4, 0x35
    bne     $s3, $s4, fail

    # All tests passed
    li.w    $r5, 0x5a
    b       success

fail:
    li.w    $r5, 0

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
