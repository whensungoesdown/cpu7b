# Test the validity of the ibar instruction (instruction barrier)
# On success: r5 = 0x5a, on failure: r5 = 0
# No exception handling required, fully self-contained

# NOTE: This is not a real test for ibar 0. Should use a self-modified code to
#       test it. This test only makes sure that ibar 0 will not cause an illegal
#       instruction exception.

.data
var1:   .word   0x00000033        # initial value irrelevant, will be overwritten

.text
.globl  _start
.globl  start

_start:
start:
    # load address of var1 into t0
    lu12i.w $t0, 0x1c000
    addi.w  $t0, $t0, 0x58

    # write test value 0x12345678
    lu12i.w $t1, 0x12345
    addi.w  $t1, $r0, 0x678
    st.w    $t1, $t0, 0

    # execute instruction barrier (ibar)
    ibar 0

    # read back the value just written
    ld.w    $t2, $t0, 0

    # compare
    lu12i.w $t3, 0x12345
    addi.w  $t3, $r0, 0x678
    bne     $t2, $t3, fail

    # success: r5 = 0x5a
    addi.w  $r5, $r0, 0x5a
    b       success

fail:
    # failure: r5 = 0
    addi.w  $r5, $r0, 0x0

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
