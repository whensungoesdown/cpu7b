# Test: CSR TLBIDX (0x10)
# Steps for each register:
#   1) csrwr write a pattern, read back and verify each field.
#   2) csrwr write zero, read back and verify.
#   3) csrxchg modify a specific field with mask, verify old and new values.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # --------------------------------------------------------------
    # Test TLBIDX (CSR 0x10)
    # Fields: NE[31], PS[29:24], INDEX[4:0]
    # --------------------------------------------------------------

    # ---- Write NE=1, PS=0x0F, INDEX=0x1F ----
    li.w    $t0, 0x8F00001F          # NE=1, PS=0x0F (bits29:24), INDEX=0x1F
    move    $t2, $t0
    csrwr   $t0, 0x10                # t0 = old (ignored)
    csrrd   $t1, 0x10

    # Check INDEX
    andi    $t3, $t1, 0x1F
    li.w    $t4, 0x1F
    bne     $t3, $t4, fail

    # Check PS (29:24)
    srli.w  $t3, $t1, 24
    andi    $t3, $t3, 0x3F
    li.w    $t4, 0x0F
    bne     $t3, $t4, fail

    # Check NE (31)
    srli.w  $t3, $t1, 31
    li.w    $t4, 0x1
    bne     $t3, $t4, fail

    # ---- Write all zeros ----
    li.w    $t0, 0x00000000
    move    $t2, $t0
    csrwr   $t0, 0x10
    csrrd   $t1, 0x10
    bne     $t1, $t2, fail

    # ---- csrxchg on INDEX (set to 0xA) ----
    li.w    $t0, 0x0000000A          # new INDEX
    li.w    $t1, 0x0000001F          # mask
    csrxchg $t0, $t1, 0x10           # t0 = old value
    bne     $t0, $zero, fail         # old must be 0
    csrrd   $t3, 0x10
    andi    $t3, $t3, 0x1F
    li.w    $t5, 0xA
    bne     $t3, $t5, fail

    # ---- csrxchg on PS (set to 0x10) ----
    li.w    $t0, 0x10000000          # new PS = 0x10
    li.w    $t1, 0x3F000000
    csrxchg $t0, $t1, 0x10
    csrrd   $t3, 0x10
    srli.w  $t3, $t3, 24
    andi    $t3, $t3, 0x3F
    li.w    $t5, 0x10
    bne     $t3, $t5, fail


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
