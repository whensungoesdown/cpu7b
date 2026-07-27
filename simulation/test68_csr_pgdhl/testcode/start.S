# Test PGDL (CSR 0x19) PDGL (CSR 0x1a)
# Field: BASE[31:12] (20 bits), low 12 bits reserved (read as 0)
# Steps:
#   1) csrwr write pattern (BASE=0x12345), read back and verify.
#   2) csrwr write zero, verify.
#   3) csrxchg modify BASE (set to 0xABCDE), verify old and new.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # --------------------------------------------------------------
    # Step 1: Write BASE=0x12345 (value = 0x12345 << 12 = 0x12345000)
    # --------------------------------------------------------------
    li.w    $t0, 0x12345000          # new value
    move    $t2, $t0                 # save new value
    csrwr   $t0, 0x19                # write to PGDL, t0 = old (ignored)
    csrrd   $t1, 0x19                # read back

    # Verify entire register equals written value (low 12 bits are 0)
    bne     $t1, $t2, fail

    # --------------------------------------------------------------
    # Step 2: Write all zeros
    # --------------------------------------------------------------
    li.w    $t0, 0x00000000
    move    $t2, $t0
    csrwr   $t0, 0x19
    csrrd   $t1, 0x19
    bne     $t1, $t2, fail

    # --------------------------------------------------------------
    # Step 3: csrxchg on BASE (set to 0xABCDE << 12 = 0xABCDE000)
    # --------------------------------------------------------------
    li.w    $t4, 0xABCDE000          # new BASE value
    li.w    $t0, 0xABCDE000          # rd = new value
    li.w    $t1, 0xFFFFF000          # rj = mask for BASE bits (20 bits)
    csrxchg $t0, $t1, 0x19           # t0 = old value (should be 0)
    bne     $t0, $zero, fail         # old must be 0

    csrrd   $t3, 0x19                # read back new value
    bne     $t3, $t4, fail


    #
    #  PGDH (0x1a)
    #

    # --------------------------------------------------------------
    # Step 1: Write BASE=0x12345 (value = 0x12345 << 12 = 0x12345000)
    # --------------------------------------------------------------
    li.w    $t0, 0x12345000          # new value
    move    $t2, $t0                 # save new value
    csrwr   $t0, 0x19                # write to PGDL, t0 = old (ignored)
    csrrd   $t1, 0x19                # read back

    # Verify entire register equals written value (low 12 bits are 0)
    bne     $t1, $t2, fail

    # --------------------------------------------------------------
    # Step 2: Write all zeros
    # --------------------------------------------------------------
    li.w    $t0, 0x00000000
    move    $t2, $t0
    csrwr   $t0, 0x19
    csrrd   $t1, 0x19
    bne     $t1, $t2, fail

    # --------------------------------------------------------------
    # Step 3: csrxchg on BASE (set to 0xABCDE << 12 = 0xABCDE000)
    # --------------------------------------------------------------
    li.w    $t4, 0xABCDE000          # new BASE value
    li.w    $t0, 0xABCDE000          # rd = new value
    li.w    $t1, 0xFFFFF000          # rj = mask for BASE bits (20 bits)
    csrxchg $t0, $t1, 0x19           # t0 = old value (should be 0)
    bne     $t0, $zero, fail         # old must be 0

    csrrd   $t3, 0x19                # read back new value
    bne     $t3, $t4, fail

    # --------------------------------------------------------------
    # All tests passed
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
    b       success
