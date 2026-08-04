# Test: invtlb op0 (clear entire ITLB)
# Steps:
# 1) Write three TLB entries with different VPPN, ASID=0x123, valid
# 2) Verify they are found by tlbsrch
# 3) Execute invtlb 0, r0
# 4) Verify they are not found (tlbsrch returns NE=1)
# On success: r5 = 0x5a, on failure: r5 = 0

#define LOONGARCH_CSR_ASID 0x18

.text
.globl _start
_start:
    # ---- Set ASID ----
    li.w    $t0, 0x00000123
    csrwr   $t0, LOONGARCH_CSR_ASID

    # ---- Write TLB entry 0: VPPN=0x10000000 ----
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11           # TLBEHI
    li.w    $t1, 0x1C00043      # valid, G=0, D=1, V=1, PPN=0x1C000
    csrwr   $t1, 0x12           # TLBELO0
    csrwr   $t1, 0x13           # TLBELO1
    li.w    $t2, 0x0C000000     # INDEX=0, PS=12
    csrwr   $t2, 0x10           # TLBIDX
    tlbwr

    # ---- Write TLB entry 1: VPPN=0x20000000 ----
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043
    csrwr   $t1, 0x12
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000001     # INDEX=1, PS=12
    csrwr   $t2, 0x10
    tlbwr

    # ---- Write TLB entry 2: VPPN=0x30000000 ----
    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    li.w    $t1, 0x1C00043
    csrwr   $t1, 0x12
    csrwr   $t1, 0x13
    li.w    $t2, 0x0C000002     # INDEX=2, PS=12
    csrwr   $t2, 0x10
    tlbwr

    # ---- Verify entry 0 exists ----
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    andi    $t4, $t3, 0x1F
    li.w    $t5, 0
    bne     $t4, $t5, fail      # INDEX should be 0
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    bnez    $t4, fail           # NE should be 0

    # ---- Verify entry 1 exists ----
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

    # ---- Verify entry 2 exists ----
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

    # ---- Execute invtlb op0 (clear ITLB) ----
    invtlb  0, $r0, $r0

    # ---- Verify entry 0 is cleared ----
    li.w    $t0, 0x10000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail           # NE should be 1 for miss

    # ---- Verify entry 1 is cleared ----
    li.w    $t0, 0x20000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail

    # ---- Verify entry 2 is cleared ----
    li.w    $t0, 0x30000000
    csrwr   $t0, 0x11
    tlbsrch
    csrrd   $t3, 0x10
    srli.w  $t4, $t3, 31
    andi    $t4, $t4, 0x1
    beqz    $t4, fail

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
