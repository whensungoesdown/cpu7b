# Test: invtlb op6 (clear entries with (G=1 OR ASID==rj) AND VA==rk,
#                   in TLB selected by TLBIDX.I_D)
# Targeting DTLB (I_D=1)
# Steps:
# 1) Write ITLB entries (control, will remain unaffected):
#    - index0: G=1, ASID=0x123, VPPN=0x10000000
#    - index1: G=0, ASID=0x123, VPPN=0x20000000
#    - index2: G=0, ASID=0x356, VPPN=0x30000000
# 2) Write DTLB entries (target):
#    - index0: G=1, ASID=0x123, VPPN=0x10000000  (VA mismatch, will remain)
#    - index1: G=1, ASID=0x200, VPPN=0x40000000  (G=1 and VA match with second invtlb, will be cleared)
#    - index2: G=0, ASID=0x123, VPPN=0x20000000  (ASID match and VA match with first invtlb, will be cleared)
#    - index3: G=0, ASID=0x356, VPPN=0x30000000  (VA mismatch, will remain)
# 3) Verify all entries are present using tlbsrch
# 4) Set TLBIDX.I_D=1 (select DTLB)
# 5) Load ASID=0x123 into $t8
# 6) Execute invtlb 6, $t8, $t7 with rk=0x20000000 (clears DTLB index2)
# 7) Execute invtlb 6, $t8, $t7 with rk=0x40000000 (clears DTLB index1)
# 8) Verify DTLB index0 and index3 remain, index1 and index2 cleared
# 9) Verify all ITLB entries remain unaffected
# On success: r5 = 0x5a, on failure: r5 = 0

#define LOONGARCH_CSR_ASID 0x18

.text
.globl _start
_start:
    # ---- Set ASID to 0x123 for writing entries with that ASID ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Write ITLB entries (I_D=0) ----
    # ITLB entry 0: G=1, VPPN=0x10000000, INDEX=0
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043      # G=1, valid, D=1, V=1, PPN=0x1C000
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00143      # G=1, valid, D=1, V=1, PPN=0x1C001
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000000     # I_D=0, PS=12, INDEX=0
    csrwr   $t2, 0x10
    tlbwr

    # ITLB entry 1: G=0, ASID=0x123, VPPN=0x20000000, INDEX=1
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000001     # INDEX=1
    csrwr   $t2, 0x10
    tlbwr

    # ITLB entry 2: G=0, ASID=0x356, VPPN=0x30000000, INDEX=2
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
    # Set ASID back to 0x123
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # DTLB entry 0: G=1, VPPN=0x10000000, INDEX=0
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043      # G=1
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00143      # G=1
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010000     # I_D=1, PS=12, INDEX=0
    csrwr   $t2, 0x10
    tlbwr

    # DTLB entry 1: G=1, ASID=0x200, VPPN=0x40000000, INDEX=1
    li.w    $t0, 0x00000200
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t0, 0x40000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043      # G=1
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00143      # G=1
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010001     # I_D=1, INDEX=1
    csrwr   $t2, 0x10
    tlbwr

    # DTLB entry 2: G=0, ASID=0x123, VPPN=0x20000000, INDEX=2
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010002     # I_D=1, INDEX=2
    csrwr   $t2, 0x10
    tlbwr

    # DTLB entry 3: G=0, ASID=0x356, VPPN=0x30000000, INDEX=3
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00203      # G=0
    csrwr   $t1, 0x12
    li.w    $t1, 0x1C00303      # G=0
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C010003     # I_D=1, INDEX=3
    csrwr   $t2, 0x10
    tlbwr

    # ---- Set ASID back to 0x123 for verification ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Verify ITLB entries are present ----
    # Set I_D=0 to search ITLB
    li.w    $t2, 0x0C000000
    csrwr   $t2, 0x10

    # ITLB entry 0
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

    # ITLB entry 1
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

    # ITLB entry 2
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

    # ---- Verify DTLB entries are present ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID
    # Set I_D=1 to search DTLB
    li.w    $t2, 0x0C010000
    csrwr   $t2, 0x10

    # DTLB entry 0
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

    # DTLB entry 1 (G=1 so ASID doesn't matter)
    li.w    $t0, 0x40000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 1
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # DTLB entry 2
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 2
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # DTLB entry 3
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 3
    bne     $t4, $t5, fail
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Set ASID back to 0x123 for invtlb ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Select DTLB for invtlb ----
    li.w    $t2, 0x0C010000     # I_D=1 (DTLB)
    csrwr   $t2, 0x10

    # ---- Load ASID=0x123 into $t8 ----
    li.w    $t8, 0x00000123

    # ---- First invtlb: clear entries with VPPN=0x20000000 (DTLB index2) ----
    li.w    $t7, 0x20000000
    invtlb  6, $t8, $t7

    # ---- Second invtlb: clear entries with VPPN=0x40000000 (DTLB index1) ----
    li.w    $t7, 0x40000000
    invtlb  6, $t8, $t7

    # ---- Verify ITLB entries remain unaffected ----
    li.w    $t2, 0x0C000000     # I_D=0
    csrwr   $t2, 0x10

    # ITLB entry 0
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ITLB entry 1
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ITLB entry 2
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # ---- Verify DTLB entries ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t2, 0x0C010000     # I_D=1
    csrwr   $t2, 0x10

    # DTLB entry 0 (G=1, VPPN mismatch) should remain
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail

    # DTLB entry 1 (G=1, VPPN=0x40000000) should be cleared
    li.w    $t0, 0x40000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail

    # DTLB entry 2 (G=0, ASID=0x123, VPPN=0x20000000) should be cleared
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail

    # DTLB entry 3 (G=0, ASID=0x356, VPPN mismatch) should remain
    li.w    $t0, 0x00000356
    csrwr   $t0, LOONGARCH_CSR_ASID
    li.w    $t0, 0x30000000
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
