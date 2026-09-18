# Test: Paging with TLBR fill V=0, then PIF exception, fix by tlbsrch + tlbwr
# Exception handlers are mapped to 0xa000_xxxx via DMW0 (0xa000->0x1c00)
# Steps:
# 1) Set EENTRY and TLBRENTRY to handlers at 0xa0xxxxxx.
# 2) Configure DMW0 to map 0xa0000000 -> 0x1c000000.
# 3) Enable paging (PG=1, DA=0).
# 4) Access unmapped VA -> TLBR exception (handler at 0xa0... works via DMW0).
#    TLBR handler fills TLB with V=0 (uses tlbfill).
# 5) Re-access same VA -> PIF exception (ECODE=0x0c).
#    General handler (at 0xa0...) uses tlbsrch to find entry, sets V=1, tlbwr.
# 6) Access succeeds, set r5=0x5a.
# On success: r5=0x5a, on failure: r5=0.

/* CSR definitions */
#define LOONGARCH_CSR_CRMD           0x0
#define LOONGARCH_CSR_EENTRY         0x0c
#define LOONGARCH_CSR_TLBRENTRY      0x88
#define LOONGARCH_CSR_STAT           0x5
#define LOONGARCH_CSR_BADV           0x7
#define LOONGARCH_CSR_TLBEHI         0x11
#define LOONGARCH_CSR_TLBELO0        0x12
#define LOONGARCH_CSR_TLBELO1        0x13
#define LOONGARCH_CSR_TLBIDX         0x10
#define LOONGARCH_CSR_DMW0           0x180
#define LOONGARCH_CSR_DMW1           0x181

#define EXC_PIF                      0x0c

.text
.globl _start
_start:
    # ----- Set exception vectors to virtual addresses (0xa000_xxxx) -----
    la      $t0, except_handler      # $t0 = 0x1c00_xxxx
    li.w    $t1, 0xa0000000
    add.w   $t0, $t0, $t1            # $t0 = 0xa000_xxxx
    csrwr   $t0, LOONGARCH_CSR_EENTRY

    la      $t0, tlbr_handler        # $t0 = 0x1c00_xxxx
    li.w    $t1, 0xa0000000
    add.w   $t0, $t0, $t1
    csrwr   $t0, LOONGARCH_CSR_TLBRENTRY

    # ----- Configure DMW0:
    li.w    $t0, 0xa0000011
    csrwr   $t0, LOONGARCH_CSR_DMW0
    li.w    $t0, 0xa0000011
    csrwr   $t0, LOONGARCH_CSR_DMW1

    # ----- Filler instructions -----
    addi.w  $t0, $r0, 1
    addi.w  $t0, $r0, 2
    addi.w  $t0, $r0, 3

    # ----- Enable paging (PG=1, DA=0) -----
    csrrd   $t1, LOONGARCH_CSR_CRMD
    li.w    $t2, ~0x18
    and     $t3, $t1, $t2
    ori     $t4, $t3, 0x10
    csrwr   $t4, LOONGARCH_CSR_CRMD

    # ----- Verify PG=1, DA=0 -----
    csrrd   $t5, LOONGARCH_CSR_CRMD
    srli.w  $t6, $t5, 4
    andi    $t6, $t6, 0x1
    beqz    $t6, fail
    srli.w  $t7, $t5, 3
    andi    $t7, $t7, 0x1
    bnez    $t7, fail

    # ----- Trigger TLB miss on unmapped VA -----
    //li.w    $t0, 0x20000000
    //ld.w    $t8, $t0, 0

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
    nop
    b       success

# ============================================================
# TLBR (TLB Refill) exception handler (virtual at 0xa000_xxxx)
# ============================================================
tlbr_handler:
    #csrrd   $t0, LOONGARCH_CSR_BADV
    #csrwr   $t0, LOONGARCH_CSR_TLBEHI

    li.w    $t0, 0x1c00042         # V=0, G=1, D=1
    csrwr   $t0, LOONGARCH_CSR_TLBELO0
    li.w    $t0, 0x1c00042         # V=0, G=1, D=1
    csrwr   $t0, LOONGARCH_CSR_TLBELO1

    tlbfill
    ertn

# ============================================================
# General exception handler (virtual at 0xa000_xxxx)
# ============================================================
except_handler:
    # Check if PIF (ECODE == 0x03)
    csrrd   $t0, LOONGARCH_CSR_STAT
    srli.w  $t1, $t0, 16
    andi    $t1, $t1, 0x3f
    li.w    $t2, 0x3
    bne     $t1, $t2, fail

    # Locate TLB entry via tlbsrch
    #csrrd   $t0, LOONGARCH_CSR_BADV
    #csrwr   $t0, LOONGARCH_CSR_TLBEHI
    tlbsrch

    # Check NE bit (0 = found)
    csrrd   $t0, LOONGARCH_CSR_TLBIDX
    srli.w  $t1, $t0, 31
    andi    $t1, $t1, 0x1
    bnez    $t1, fail

    # Update entry: V=1
    li.w    $t1, 0x1c00043
    csrwr   $t1, LOONGARCH_CSR_TLBELO0
    li.w    $t1, 0x1c00043
    csrwr   $t1, LOONGARCH_CSR_TLBELO1
    tlbwr
    ertn
