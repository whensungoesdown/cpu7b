# Test: CSR DMW0 and DMW1 fields with csrwr and csrxchg.
# Only PLV0 and PLV3 are tested (PLV1, PLV2 not implemented).
# Steps:
# 1) csrwr: Write DMW0=0xA0000011 (VSEG=5, PSEG=0, MAT=1, PLV0=1)
# 2) csrwr: Write DMW1=0x82000028 (VSEG=4, PSEG=1, MAT=2, PLV3=1)
# 3) csrxchg: Mask 0xFFFFFFFF, new value 0xA4000039 => old DMW0=0xA0000011,
#    new DMW0=0xA4000039 (VSEG=5, PSEG=2, MAT=3, PLV0=1, PLV3=1)
# 4) csrxchg: Mask 0x00000001, new value 0x1 => only PLV0 set to 1,
#    old DMW1=0x82000028, new DMW1=0x82000029 (PLV0=1, PLV3=1)
# Verify old and new values.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # --------------------------------------------------------------
    # Step 1: csrwr -> DMW0 = 0xA0000011
    # --------------------------------------------------------------
    li.w    $t0, 0xA0000011
    csrwr   $t0, 0x180

    # Read back and verify
    csrrd   $t1, 0x180

    # VSEG (31:29) = 5
    srli.w  $t2, $t1, 29
    andi    $t2, $t2, 0x7
    li.w    $t3, 0x5
    bne     $t2, $t3, fail

    # PSEG (27:25) = 0
    srli.w  $t2, $t1, 25
    andi    $t2, $t2, 0x7
    bnez    $t2, fail

    # MAT (5:4) = 1
    srli.w  $t2, $t1, 4
    andi    $t2, $t2, 0x3
    li.w    $t3, 0x1
    bne     $t2, $t3, fail

    # PLV0 = 1
    andi    $t2, $t1, 0x1
    beqz    $t2, fail

    # PLV3 = 0
    srli.w  $t2, $t1, 3
    andi    $t2, $t2, 0x1
    bnez    $t2, fail

    # PLV1, PLV2 = 0
    srli.w  $t2, $t1, 1
    andi    $t2, $t2, 0x3
    bnez    $t2, fail

    # --------------------------------------------------------------
    # Step 2: csrwr -> DMW1 = 0x82000028
    # --------------------------------------------------------------
    li.w    $t0, 0x82000028
    csrwr   $t0, 0x181

    csrrd   $t1, 0x181

    # VSEG = 4
    srli.w  $t2, $t1, 29
    andi    $t2, $t2, 0x7
    li.w    $t3, 0x4
    bne     $t2, $t3, fail

    # PSEG = 1
    srli.w  $t2, $t1, 25
    andi    $t2, $t2, 0x7
    li.w    $t3, 0x1
    bne     $t2, $t3, fail

    # MAT = 2
    srli.w  $t2, $t1, 4
    andi    $t2, $t2, 0x3
    li.w    $t3, 0x2
    bne     $t2, $t3, fail

    # PLV0 = 0
    andi    $t2, $t1, 0x1
    bnez    $t2, fail

    # PLV3 = 1
    srli.w  $t2, $t1, 3
    andi    $t2, $t2, 0x1
    beqz    $t2, fail

    # PLV1, PLV2 = 0
    srli.w  $t2, $t1, 1
    andi    $t2, $t2, 0x3
    bnez    $t2, fail

    # --------------------------------------------------------------
    # Step 3: csrxchg on DMW0 with full mask (0xFFFFFFFF)
    #         new value 0xA4000039, old value should be 0xA0000011
    # --------------------------------------------------------------
    li.w    $t0, 0xA4000039          # new value to write (rd)
    li.w    $t1, 0xFFFFFFFF          # mask (rj) - all bits updated
    csrxchg $t0, $t1, 0x180          # $t0 = old DMW0, DMW0 = new value

    # Verify old value
    li.w    $t2, 0xA0000011
    bne     $t0, $t2, fail

    # Verify new value
    csrrd   $t3, 0x180
    li.w    $t4, 0xA4000039
    bne     $t3, $t4, fail

    # --------------------------------------------------------------
    # Step 4: csrxchg on DMW1 with mask 0x00000001 (only PLV0 bit)
    #         new value 0x1, old DMW1=0x82000028,
    #         new DMW1=0x82000029 (PLV0 becomes 1, others unchanged)
    # --------------------------------------------------------------
    li.w    $t0, 0x00000001          # new value for PLV0 (rd)
    li.w    $t1, 0x00000001          # mask (rj) - only bit0
    csrxchg $t0, $t1, 0x181          # $t0 = old DMW1, DMW1 = old | (new & mask)

    # Verify old value
    li.w    $t2, 0x82000028
    bne     $t0, $t2, fail

    # Verify new value (expect 0x82000029)
    csrrd   $t3, 0x181
    li.w    $t4, 0x82000029
    bne     $t3, $t4, fail

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
    b       success
