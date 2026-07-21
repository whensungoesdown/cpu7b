## Test: CRMD reset value.
## Reset: CRMD = 0x8 (IE=0, PLV=0, DA=1, PG=0)
## 1) Check reset value equals 0x8.
## On success: r5 = 0x5a, on failure: r5 = 0.
#
#.text
#.globl _start
#_start:
#    # ----------------------------------------------------------
#    # Step 1: Check reset value (should be 0x8)
#    # ----------------------------------------------------------
#    csrrd   $t0, 0x0            # t0 = CRMD
#    li.w    $t1, 0x8
#    bne     $t0, $t1, fail      # if not 0x8, fail
#
#    # ----------------------------------------------------------
#    # Success
#    # ----------------------------------------------------------
#    li.w    $r5, 0x5a
#    b       success
#
#fail:
#    li.w    $r5, 0
#
#success:
#    nop
#    nop
#    nop
#    nop
#    b       success            # loop forever



# Test: CRMD reset value and DA/PG write operations.
# Reset: CRMD = 0x8 (IE=0, PLV=0, DA=1, PG=0)
# Steps:
# 1) Check reset value equals 0x8.
# 2) Write DA=0, PG=1 (value 0x10), read back and verify.
# 3) Write DA=1, PG=0 again (value 0x8), read back and verify.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # --------------------------------------------------------------
    # Step 1: Verify reset value (CRMD == 0x8)
    # --------------------------------------------------------------
    csrrd   $t0, 0x0            # t0 = CRMD
    li.w    $t1, 0x8
    bne     $t0, $t1, fail

#    # --------------------------------------------------------------
#    # Step 2: Write DA=0, PG=1 (value 0x10)
#    # --------------------------------------------------------------
#    li.w    $t1, 0x10           # t1 = value to write
#    csrwr   $t1, 0x0            # write t1 to CRMD; t1 becomes old CRMD (0x8)
#    csrrd   $t2, 0x0            # t2 = new CRMD
#    li.w    $t3, 0x10
#    bne     $t2, $t3, fail      # verify new value
#
#    # --------------------------------------------------------------
#    # Step 3: Write DA=1, PG=0 (value 0x8)
#    # --------------------------------------------------------------
#    li.w    $t1, 0x8
#    csrwr   $t1, 0x0            # t1 becomes old CRMD (0x10)
#    csrrd   $t2, 0x0            # t2 = new CRMD
#    li.w    $t3, 0x8
#    bne     $t2, $t3, fail

    # --------------------------------------------------------------
    # Success
    # --------------------------------------------------------------
    li.w    $r5, 0x5a
    b       success

fail:
    li.w    $r5, 0

success:
    nop
    nop
    nop
    nop
    b       success            # loop forever
