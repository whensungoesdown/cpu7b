# Test TLBEHI (CSR 0x11)
# Field: VPPN[31:13] (19 bits). Low 13 bits are reserved, read as 0.
# Steps: csrwr write pattern, verify; write zero; csrxchg modify.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # ---- Write VPPN=0x12345(0x12345 << 13 = 0x2468a000) ----
    li.w    $t0, 0x2468a000
    move    $t2, $t0
    csrwr   $t0, 0x11
    csrrd   $t1, 0x11
    bne     $t1, $t2, fail

    # ---- Write zero ----
    li.w    $t0, 0x00000000
    move    $t2, $t0
    csrwr   $t0, 0x11
    csrrd   $t1, 0x11
    bne     $t1, $t2, fail

    # ---- csrxchg on VPPN (set to 0x55555 << 13 = 0xAAAAA000) ----
    li.w    $t4, 0xAAAAA000
    li.w    $t0, 0xAAAAA000
    li.w    $t1, 0xFFFFE000          # mask for VPPN bits
    csrxchg $t0, $t1, 0x11
    bne     $t0, $zero, fail         # old should be 0
    csrrd   $t3, 0x11
    bne     $t3, $t4, fail

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
