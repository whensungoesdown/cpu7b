# Test: invtlb op4 (clear G=0 entries with ASID equal to rj, in TLB selected by TLBIDX.I_D)
# Steps:
# 1) Write ITLB entries:
#    - index0: G=1, ASID=0x123 (irrelevant), VPPN=0x10000000
#    - index1: G=0, ASID=0x123, VPPN=0x20000000
#    - index2: G=0, ASID=0x356, VPPN=0x30000000
# 2) Write DTLB entries (similar, but with different VPPN to avoid conflict):
#    - index3: G=1, ASID=0x123, VPPN=0x50000000
#    - index4: G=0, ASID=0x123, VPPN=0x60000000
#    - index5: G=0, ASID=0x356, VPPN=0x70000000
# 3) Verify all entries are present using tlbsrch
# 4) Set TLBIDX.I_D=0 (select ITLB)
# 5) Execute invtlb 4, $t8, $r0  (rj=ASID=0x123) to clear G=0 entries with ASID=0x123 in ITLB
# 6) Verify ITLB G=0 entry with ASID=0x123 (index1) is cleared
# 7) Verify ITLB G=0 entry with ASID=0x356 (index2) remains
# 8) Verify ITLB G=1 entry (index0) remains
# 9) Verify DTLB entries (both G=1 and G=0) remain unaffected
# On success: r5 = 0x5a, on failure: r5 = 0

#define LOONGARCH_CSR_ASID 0x18

.text
.globl _start
_start:
    # ---- Set ASID to 0x123 for writing entries with that ASID ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Write ITLB entry 0: G=1, VPPN=0x10000000, INDEX=0 ----
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043      # G=1, valid, D=1, V=1, PPN=0x1C000
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00143      # G=1, valid, D=1, V=1, PPN=0x1C001
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000000     # I_D=0 (ITLB), PS=12, INDEX=0
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write ITLB entry 1: G=0, ASID=0x123, VPPN=0x20000000, INDEX=1 ----
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000001     # INDEX=1
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write ITLB entry 2: G=0, ASID=0x356, VPPN=0x30000000, INDEX=2 ----
    # Change ASID to 0x356
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000002     # INDEX=2
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write DTLB entries (I_D=1) ----
    # Set ASID back to 0x123 for DTLB entries with that ASID
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Write DTLB entry 3: G=1, VPPN=0x50000000, INDEX=3 ----
    li.w    $t0, 0x50000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043      # G=1
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00143      # G=1
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010003     # I_D=1, INDEX=3
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write DTLB entry 4: G=0, ASID=0x123, VPPN=0x60000000, INDEX=4 ----
    li.w    $t0, 0x60000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010004     # I_D=1, INDEX=4
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write DTLB entry 5: G=0, ASID=0x356, VPPN=0x70000000, INDEX=5 ----
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x70000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010005     # I_D=1, INDEX=5
    csrwr   $t2, 0x10
    tlbwr

    # ---- Set ASID back to 0x123 for verification ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Set I_D=0 to search ITLB ----
    li.w    $t2, 0x0C000000     # I_D=0, PS=12, INDEX don't care
    csrwr   $t2, 0x10

    # ---- Verify ITLB entry 0 (G=1, ASID=0x123) exists ----
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 0
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify ITLB entry 1 (G=0, ASID=0x123) exists ----
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 1
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify ITLB entry 2 (G=0, ASID=0x356) exists ----
    # Need to set ASID to 0x356 for this search
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 2
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Set ASID back to 0x123 for DTLB verification ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Set I_D=1 to search DTLB ----
    li.w    $t2, 0x0C010000     # I_D=1
    csrwr   $t2, 0x10

    # ---- Verify DTLB entry 3 (G=1, ASID=0x123) exists ----
    li.w    $t0, 0x50000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 3
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify DTLB entry 4 (G=0, ASID=0x123) exists ----
    li.w    $t0, 0x60000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 4
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify DTLB entry 5 (G=0, ASID=0x356) exists ----
    # Need to set ASID to 0x356 for this search
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x70000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 5
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Set ASID back to 0x123 for invtlb ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Set I_D=0 to select ITLB for invtlb ----
    li.w    $t2, 0x0C000000     # I_D=0 (ITLB)
    csrwr   $t2, 0x10

    # ---- Load ASID=0x123 into $t8 for invtlb rj ----
    li.w    $t8, 0x00000123

    # ---- Execute invtlb op4 (clear G=0 entries with ASID=$t8 in ITLB) ----
    invtlb  4, $t8, $r0

    # ---- Set I_D=0 to search ITLB ----
    li.w    $t2, 0x0C000000
    csrwr   $t2, 0x10

    # ---- ITLB entry 0 (G=1) should remain ----
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail           # NE should be 0 for hit

    # ---- ITLB entry 1 (G=0, ASID=0x123) should be cleared ----
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail           # NE should be 1 for miss

    # ---- ITLB entry 2 (G=0, ASID=0x356) should remain ----
    # Need to set ASID to 0x356 for this search
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail           # NE should be 0 for hit

    # ---- Set ASID back to 0x123 for DTLB verification ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Set I_D=1 to search DTLB ----
    li.w    $t2, 0x0C010000
    csrwr   $t2, 0x10

    # ---- DTLB entry 3 (G=1) should remain (unaffected) ----
    li.w    $t0, 0x50000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- DTLB entry 4 (G=0, ASID=0x123) should remain (unaffected) ----
    li.w    $t0, 0x60000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- DTLB entry 5 (G=0, ASID=0x356) should remain (unaffected) ----
    # Need to set ASID to 0x356 for this search
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x70000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

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
