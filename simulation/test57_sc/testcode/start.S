# Test: sc.w without preceding ll.w should fail (return 0) and not write.
# On success (sc.w fails as expected): r5 = 0x5a
# On failure (sc.w unexpectedly succeeds or memory modified): r5 = 0
# No exception handling required, fully self-contained.

.data
var:    .word   0x35            # initial value, should remain 0x35 after sc.w

.text
.globl  _start
.globl  start

_start:
start:
    la      $t0, var            # load address of var

    # Use normal load (not ll.w) to read var
    ld.w    $t1, $t0, 0         # t1 = *var (LLbit remains 0)

    # Compute new value
    addi.w  $t2, $t1, 1         # t2 = 0x35 + 1 = 0x36

    # Attempt sc.w without a preceding ll.w
    # This should fail because LLbit is 0. sc.w returns 0 in t2.
    sc.w    $t2, $t0, 0         # store fails, t2 = 0

    # Check sc.w result: if t2 != 0, sc.w unexpectedly succeeded
    bnez    $t2, sc_success

    # Verify memory was NOT modified: should still be 0x35
    ld.w    $t3, $t0, 0
    li.w    $t4, 0x35
    bne     $t3, $t4, fail      # if memory changed, fail

    # All good: sc.w failed and memory unchanged -> test passes
    li.w    $r5, 0x5a
    b       success

sc_success:
    # sc.w returned 1 (unexpected) -> test fails
    li.w    $r5, 0
    b       success

fail:
    # memory was modified unexpectedly -> test fails
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
