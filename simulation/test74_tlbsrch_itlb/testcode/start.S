# Test: tlbwr and tlbsrch with ASID and Global bit
# Steps:
# 1) Set ASID = 0x123
# 2) Write TLB entry with G=0, VPPN=0x1C000000, index=5
# 3) tlbsrch with same VPPN and ASID -> hit, verify NE=0, INDEX=5
# 4) tlbsrch with same VPPN but different ASID (0x456) -> miss, verify NE=1
# 5) Reset TLBIDX.INDEX=5, PS=12, NE=0
# 6) Modify entry to set G=1, keep other fields
# 7) tlbwr to overwrite entry with G=1
# 8) tlbsrch with same VPPN and different ASID (0x456) -> hit, verify NE=0, INDEX=5
# On success: r5 = 0x5a, on failure: r5 = 0

.text
.globl _start
_start:
    # ---- Set initial ASID ----
    li.w    $t0, 0x00000123
    csrwr   $t0, 0x18                # ASID = 0x123

    # ---- Write TLBEHI ----
    li.w    $t0, 0x1C000000
    csrwr   $t0, 0x11

    # ---- Write TLBELO0 (G=0, valid) ----
    li.w    $t1, 0x1C00003           # G=0, V=1, D=1, PLV=0, MAT=0, PPN=0x1C000
    csrwr   $t1, 0x12

    # ---- Write TLBELO1 (G=0) ----
    li.w    $t1, 0x1C00003
    csrwr   $t1, 0x13

    # ---- Set TLBIDX.INDEX = 5, PS = 12 ----
    li.w    $t2, 0x0C000005
    csrwr   $t2, 0x10

    # ---- tlbwr (write entry at index 5) ----
    tlbwr

    # ---- Test 1: tlbsrch with matching ASID (should hit) ----
    # TLBEHI already 0x1C000000, ASID is 0x123
    tlbsrch

    # Verify hit: NE=0, INDEX=5
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 0x5
    bne     $t4, $t5, fail

    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail                # NE must be 0 for hit

    # ---- Test 2: tlbsrch with different ASID (G=0, should miss) ----
    li.w    $t0, 0x00000456
    csrwr   $t0, 0x18                # ASID = 0x456 (different)

    tlbsrch

    # Verify miss: NE must be 1
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail                # NE must be 1 for miss

    # ---- Step 5: Reset TLBIDX (INDEX=5, PS=12, NE=0) ----
    li.w    $t2, 0x0C000005          # NE=0, PS=12, INDEX=5
    csrwr   $t2, 0x10

    # ---- Step 6 & 7: Modify entry to G=1 and tlbwr ----
    li.w    $t1, 0x1C00043           # G=1, V=1, D=1, PLV=0, MAT=0, PPN=0x1C000
    csrwr   $t1, 0x12                # write TLBELO0
    li.w    $t1, 0x1C00043           # reload
    csrwr   $t1, 0x13                # write TLBELO1

    tlbwr                             # overwrite entry at index 5 with G=1

    # ---- Test 3: tlbsrch with different ASID (G=1, should hit) ----
    # ASID is still 0x456 from previous step
    tlbsrch

    # Verify hit: NE=0, INDEX=5
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 0x5
    bne     $t4, $t5, fail

    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail                # NE must be 0 for hit

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
