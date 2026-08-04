# Test: invtlb op5 (clear G=0 entries with ASID equal to rj AND VA equal to rk,
#                   in TLB selected by TLBIDX.I_D)
# Steps:
# 1) Write ITLB entries:
#    - index0: G=1, ASID=0x123, VPPN=0x10000000
#    - index1: G=0, ASID=0x123, VPPN=0x20000000  (target for invtlb op5)
#    - index2: G=0, ASID=0x356, VPPN=0x30000000
# 2) Write DTLB entries (independent index space, starting from 0):
#    - index0: G=1, ASID=0x123, VPPN=0x50000000
#    - index1: G=0, ASID=0x123, VPPN=0x60000000
#    - index2: G=0, ASID=0x356, VPPN=0x70000000
# 3) Verify all entries are present using tlbsrch
# 4) Set TLBIDX.I_D=0 (select ITLB)
# 5) Load ASID=0x123 into $t8 and VPPN=0x20000000 into $t7
# 6) Execute invtlb 5, $t8, $t7  (clear G=0 entries with matching ASID and VA in ITLB)
# 7) Verify ITLB target entry (index1, VPPN=0x20000000) is cleared
# 8) Verify ITLB other entries (index0, index2) remain
# 9) Verify all DTLB entries remain unaffected
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

    # ---- Write DTLB entries (I_D=1, independent index space) ----
    # Set ASID back to 0x123 for DTLB entries with that ASID
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Write DTLB entry 0: G=1, VPPN=0x50000000, INDEX=0 ----
    li.w    $t0, 0x50000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043      # G=1
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00143      # G=1
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010000     # I_D=1, PS=12, INDEX=0
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write DTLB entry 1: G=0, ASID=0x123, VPPN=0x60000000, INDEX=1 ----
    li.w    $t0, 0x60000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010001     # I_D=1, INDEX=1
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write DTLB entry 2: G=0, ASID=0x356, VPPN=0x70000000, INDEX=2 ----
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x70000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010002     # I_D=1, INDEX=2
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

    # ---- Verify ITLB entry 1 (G=0, ASID=0x123, VPPN=0x20000000) exists ----
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

    # ---- Verify ITLB entry 2 (G=0, ASID=0x356, VPPN=0x30000000) exists ----
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

    # ---- Verify DTLB entry 0 (G=1, ASID=0x123) exists ----
    li.w    $t0, 0x50000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 0
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify DTLB entry 1 (G=0, ASID=0x123) exists ----
    li.w    $t0, 0x60000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 1
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify DTLB entry 2 (G=0, ASID=0x356) exists ----
    # Need to set ASID to 0x356 for this search
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID

    li.w    $t0, 0x70000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 2
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

    # ---- Load VPPN=0x20000000 into $t7 for invtlb rk ----
    li.w    $t7, 0x20000000

    # ---- Execute invtlb op5 (clear G=0 entries with ASID=$t8 and VA=$t7 in ITLB) ----
    invtlb  5, $t8, $t7

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

    # ---- ITLB entry 1 (G=0, ASID=0x123, VPPN=0x20000000) should be cleared ----
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail           # NE should be 1 for miss

    # ---- ITLB entry 2 (G=0, ASID=0x356, VPPN=0x30000000) should remain ----
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

    # ---- DTLB entry 0 (G=1) should remain (unaffected) ----
    li.w    $t0, 0x50000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- DTLB entry 1 (G=0, ASID=0x123) should remain (unaffected) ----
    li.w    $t0, 0x60000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- DTLB entry 2 (G=0, ASID=0x356) should remain (unaffected) ----
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
