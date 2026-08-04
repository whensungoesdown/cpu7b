# Test: tlbwr and tlbrd instructions
# According to LoongArch manual:
#   - Valid entry: tlbrd sets TLBIDX.NE = 0
#   - Invalid entry: tlbrd sets TLBIDX.NE = 1
# Steps:
# 1) Set TLBEHI = 0x1C000000
# 2) Set TLBELO0 = 0x1C00043 (V=1, valid)
# 3) Set TLBELO1 = 0x1C00043 (V=1, valid)
# 4) Set TLBIDX.INDEX = 5, TLBIDX.PS=12 (4KB Page), TLBIDX.I_D = 1 (dtlb)
# 5) tlbwr -> write valid entry at index 5
# 6) tlbrd -> read back index 5
# 7) Verify TLBEHI, TLBELO0, TLBELO1 match, and TLBIDX.NE == 0
# On success: r5 = 0x5a, on failure: r5 = 0

.text
.globl _start
_start:
    # ---- Step 1: Write TLBEHI ----
    li.w    $t0, 0x1C000000
    csrwr   $t0, 0x11

    # ---- Step 2: Write TLBELO0 (valid) ----
    li.w    $t1, 0x1C00043           # V=1, D=1, PLV=0, MAT=0, G=1, PPN=0x1C000
    csrwr   $t1, 0x12

    # ---- Step 3: Write TLBELO1 (reload, then write) ----
    li.w    $t1, 0x1C00043
    csrwr   $t1, 0x13

    # ---- Step 4: Set TLBIDX.INDEX = 5, PS = 12, I_D = 1 (DTLB) ----
    # PS = 12 (0xC) at bits [29:24], I_D = 1 at bit 16, INDEX = 5 at bits [4:0]
    li.w    $t2, 0x0C010005          # 0x0C000005 | (1 << 16)
    csrwr   $t2, 0x10

    # ---- Step 5: tlbwr ----
    tlbwr

    # ---- Step 6: tlbrd ----
    tlbrd

    # ---- Step 7: Verify ----
    # Verify TLBEHI
    csrrd   $t3, 0x11
    li.w    $t4, 0x1C000000
    bne     $t3, $t4, fail

    # Verify TLBELO0
    csrrd   $t3, 0x12
    li.w    $t4, 0x1C00043
    bne     $t3, $t4, fail

    # Verify TLBELO1
    csrrd   $t3, 0x13
    li.w    $t4, 0x1C00043
    bne     $t3, $t4, fail

    # Verify TLBIDX.NE == 0 (valid entry)
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail                # NE must be 0 for valid entry

    #
    # Test invalid entry
    #
    li.w    $t2, 0x00010010          # INDEX=16 (never written), I_D=1 (dtlb)
    csrwr   $t2, 0x10
    tlbrd
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail                # NE must be 1 for invalid entry
    
    csrrd   $t3, 0x11
    bnez    $t3, fail                # TLBEHI must be 0

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
