# Test: CSR.ASID (0x18) read/write/exchange
# Fields:
#   [31:24] reserved (0)
#   [23:16] ASIDBits (read-only, fixed 8'd10)
#   [15:10] reserved (0)
#   [9:0]   ASID (10 bits, writable)
# Steps:
# 1) csrwr: Write ASID=0x123, read back and verify.
# 2) csrwr: Write ASID=0x2AB, read back and verify.
# 3) csrxchg: Use mask=0x3FF (full ASID field), new value=0x345,
#    verify old value=0x2AB and new value=0x345.
# 4) csrxchg with mask=0x00F (only low 4 bits), new value=0x00A,
#    verify new ASID = 0x34A (high bits unchanged, low 4 bits = A).
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # ---- Step 1: Write ASID=0x123 ----
    li.w    $t0, 0x00000123
    csrwr   $t0, 0x18

    csrrd   $t1, 0x18
    andi    $t2, $t1, 0x3FF
    li.w    $t3, 0x123
    bne     $t2, $t3, fail

    # Check ASIDBits = 10
    srli.w  $t2, $t1, 16
    andi    $t2, $t2, 0xFF
    li.w    $t3, 10
    bne     $t2, $t3, fail

    # ---- Step 2: Write ASID=0x2AB ----
    li.w    $t0, 0x000002AB
    csrwr   $t0, 0x18

    csrrd   $t1, 0x18
    andi    $t2, $t1, 0x3FF
    li.w    $t3, 0x2AB
    bne     $t2, $t3, fail

    srli.w  $t2, $t1, 16
    andi    $t2, $t2, 0xFF
    li.w    $t3, 10
    bne     $t2, $t3, fail

    # ---- Step 3: csrxchg with mask 0x3FF (full ASID field) ----
    li.w    $t0, 0x00000345          # new value
    li.w    $t1, 0x000003FF          # mask: full 10 bits
    csrxchg $t0, $t1, 0x18           # $t0 = old value (should be 0x2AB)

    andi    $t3, $t0, 0x3FF
    li.w    $t4, 0x2AB
    bne     $t3, $t4, fail

    csrrd   $t3, 0x18
    andi    $t4, $t3, 0x3FF
    li.w    $t5, 0x345
    bne     $t4, $t5, fail

    # ---- Step 4: csrxchg with mask 0x00F (low 4 bits) ----
    # Current ASID = 0x345, set low 4 bits to 0xA, expected 0x34A
    li.w    $t0, 0x0000000A          # new low 4 bits
    li.w    $t1, 0x0000000F          # mask: only lower 4 bits
    csrxchg $t0, $t1, 0x18           # $t0 = old value

    # Old value should be 0x345
    andi    $t3, $t0, 0x3FF
    li.w    $t4, 0x345
    bne     $t3, $t4, fail

    csrrd   $t3, 0x18
    andi    $t4, $t3, 0x3FF
    li.w    $t5, 0x34A               # 0x345 with low 4 bits = 0xA
    bne     $t4, $t5, fail

    # ---- All checks passed ----
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
    b       success
