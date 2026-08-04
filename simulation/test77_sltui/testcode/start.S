# Test: sltui instruction
# sltui rd, rj, si12 : rd = (unsigned(rj) < unsigned(sign_extend(si12))) ? 1 : 0
# Test cases:
# 1) 0 < 1 -> 1
# 2) 1 < 0 -> 0
# 3) 0xFFFFFFFF < 2047 -> 0
# 4) 2047 < -1 -> 1 (0x7FF < 0xFFFFFFFF)
# 5) 0x80000000 < 2047 -> 0
# 6) 2047 < -2048 -> 1 (0x7FF < 0xFFFFF800)
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # Test 1: 0 < 1 => 1
    li.w    $t0, 0
    sltui   $t1, $t0, 1
    li.w    $t2, 1
    bne     $t1, $t2, fail

    # Test 2: 1 < 0 => 0
    li.w    $t0, 1
    sltui   $t1, $t0, 0
    bnez    $t1, fail

    # Test 3: 0xFFFFFFFF < 2047 => 0
    li.w    $t0, 0xFFFFFFFF
    sltui   $t1, $t0, 2047
    bnez    $t1, fail

    # Test 4: 2047 < -1 => 1 (si12 = -1)
    li.w    $t0, 2047
    sltui   $t1, $t0, -1
    li.w    $t2, 1
    bne     $t1, $t2, fail

    # Test 5: 0x80000000 < 2047 => 0
    li.w    $t0, 0x80000000
    sltui   $t1, $t0, 2047
    bnez    $t1, fail

    # Test 6: 2047 < -2048 => 1 (si12 = -2048)
    li.w    $t0, 2047
    sltui   $t1, $t0, -2048
    li.w    $t2, 1
    bne     $t1, $t2, fail

    # ----- Success -----
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
