# Test TLBELO0 (CSR 0x12) TLBELO1 (CSR 0x13)
# Fields: V[0], D[1], PLV[3:2], MAT[5:4], G[6], PPN[27:8]
# Write value = (PPN<<8) | (G<<6) | (MAT<<4) | (PLV<<2) | (D<<1) | V
# PPN test value: 0xABCD (fits in 16 bits, still within 20-bit field)
# Steps: csrwr write pattern, verify; write zero; csrxchg fields.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # ---- Write PPN=0x12345, G=1, MAT=3, PLV=3, D=1, V=1 ----
    li.w    $t0, 0x123457F           # PPN=0x12345
    move    $t2, $t0
    csrwr   $t0, 0x12
    csrrd   $t1, 0x12
    bne     $t1, $t2, fail

    # ---- Write all zeros ----
    li.w    $t0, 0x00000000
    move    $t2, $t0
    csrwr   $t0, 0x12
    csrrd   $t1, 0x12
    bne     $t1, $t2, fail

    # ---- csrxchg on V ----
    li.w    $t0, 0x00000001
    li.w    $t1, 0x00000001
    csrxchg $t0, $t1, 0x12
    bne     $t0, $zero, fail
    csrrd   $t3, 0x12
    andi    $t3, $t3, 0x1
    li.w    $t5, 0x1
    bne     $t3, $t5, fail

    # ---- csrxchg on PLV (set PLV=2) ----
    li.w    $t0, 0x00000008          # PLV=2 << 2 = 0x8
    li.w    $t1, 0x0000000C
    csrxchg $t0, $t1, 0x12
    csrrd   $t3, 0x12
    srli.w  $t3, $t3, 2
    andi    $t3, $t3, 0x3
    li.w    $t5, 0x2
    bne     $t3, $t5, fail

    # ---- csrxchg on PPN (set PPN=0xABCD) ----
    li.w    $t4, 0x0ABCD00           # 0xABCD << 8 = 0x0ABCD00
    li.w    $t0, 0x0ABCD00
    li.w    $t1, 0x0FFFFF00          # mask for PPN bits (27:8)
    csrxchg $t0, $t1, 0x12
    csrrd   $t3, 0x12
    srli.w  $t3, $t3, 8
    li.w    $t5, 0xFFFFF
    and     $t3, $t3, $t5
    li.w    $t5, 0xABCD
    bne     $t3, $t5, fail


    // TLBELO1 (CSR 0x13)

    # ---- Write PPN=0x12345, G=1, MAT=3, PLV=3, D=1, V=1 ----
    li.w    $t0, 0x123457F           # PPN=0x12345
    move    $t2, $t0
    csrwr   $t0, 0x12
    csrrd   $t1, 0x12
    bne     $t1, $t2, fail

    # ---- Write all zeros ----
    li.w    $t0, 0x00000000
    move    $t2, $t0
    csrwr   $t0, 0x12
    csrrd   $t1, 0x12
    bne     $t1, $t2, fail

    # ---- csrxchg on V ----
    li.w    $t0, 0x00000001
    li.w    $t1, 0x00000001
    csrxchg $t0, $t1, 0x12
    bne     $t0, $zero, fail
    csrrd   $t3, 0x12
    andi    $t3, $t3, 0x1
    li.w    $t5, 0x1
    bne     $t3, $t5, fail

    # ---- csrxchg on PLV (set PLV=2) ----
    li.w    $t0, 0x00000008          # PLV=2 << 2 = 0x8
    li.w    $t1, 0x0000000C
    csrxchg $t0, $t1, 0x12
    csrrd   $t3, 0x12
    srli.w  $t3, $t3, 2
    andi    $t3, $t3, 0x3
    li.w    $t5, 0x2
    bne     $t3, $t5, fail

    # ---- csrxchg on PPN (set PPN=0xABCD) ----
    li.w    $t4, 0x0ABCD00           # 0xABCD << 8 = 0x0ABCD00
    li.w    $t0, 0x0ABCD00
    li.w    $t1, 0x0FFFFF00          # mask for PPN bits (27:8)
    csrxchg $t0, $t1, 0x12
    csrrd   $t3, 0x12
    srli.w  $t3, $t3, 8
    li.w    $t5, 0xFFFFF
    and     $t3, $t3, $t5
    li.w    $t5, 0xABCD
    bne     $t3, $t5, fail

    # ---- Success ----
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
