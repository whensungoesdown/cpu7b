# Test: Paging with TLBR fill V=1, D=0, then PME exception, fix by tlbsrch + tlbwr
# Exception handlers are mapped to 0xa000_xxxx via DMW0 (0xa000->0x1c00)
# Steps:
# 1) Set EENTRY and TLBRENTRY to handlers at 0xa0xxxxxx.
# 2) Configure DMW0 to map 0xa0000000 -> 0x1c000000.
# 3) Enable paging (PG=1, DA=0).
# 4) Access unmapped VA -> TLBR exception (handler at 0xa0... works via DMW0).
#    TLBR handler checks subcode: ITLB -> V=1, D=1; DTLB -> V=1, D=0.
# 5) Store to same VA -> PME exception (ECODE=0x04).
#    General handler (at 0xa0...) uses tlbsrch to find entry, sets D=1, tlbwr.
# 6) Store succeeds, set r5=0x5a.
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
#define LOONGARCH_CSR_KS0            0x30
#define LOONGARCH_CSR_KS1            0x31

#define EXC_PME                      0x04   /* Page modification exception */

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

    # ----- Trigger TLB miss on unmapped VA (data access -> DTLB) -----
    li.w    $t0, 0x20001000          # Test VA
    li.w    $t8, 0x12345678          # Data to store
    st.w    $t8, $t0, 0              # Store -> will cause TLBR (V=1, D=0), then PME

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
    nop
    b       success

# ============================================================
# TLBR (TLB Refill) exception handler (virtual at 0xa000_xxxx)
# ============================================================
tlbr_handler:
    csrwr   $t0, LOONGARCH_CSR_KS0
    csrwr   $t1, LOONGARCH_CSR_KS1

    # Get subcode from ESTAT bits [30:22]
    csrrd   $t0, LOONGARCH_CSR_STAT
    srli.w  $t0, $t0, 22
    andi    $t0, $t0, 0x1ff
    beqz    $t0, itlb_refill

    # ---- DTLB refill (subcode == 1) ----
    # Set TLBIDX.I_D = 1
    csrrd   $t1, LOONGARCH_CSR_TLBIDX
    li.w    $t0, 0x10000
    or      $t1, $t1, $t0
    csrwr   $t1, LOONGARCH_CSR_TLBIDX

    csrrd   $t1, LOONGARCH_CSR_BADV
    csrwr   $t1, LOONGARCH_CSR_TLBEHI

    # V=1, G=1, D=0, PPN=0x1c0001
    li.w    $t0, 0x1c000141          # (0x1c0001<<8) | (1<<6) | (1<<0)
    csrwr   $t0, LOONGARCH_CSR_TLBELO0
    li.w    $t0, 0x1c000141
    csrwr   $t0, LOONGARCH_CSR_TLBELO1

    tlbfill
    b       restore_and_ertn

itlb_refill:
    # ---- ITLB refill (subcode == 0) ----
    # Set TLBIDX.I_D = 0
    csrrd   $t1, LOONGARCH_CSR_TLBIDX
    li.w    $t0, ~0x10000
    and     $t1, $t1, $t0
    csrwr   $t1, LOONGARCH_CSR_TLBIDX

    csrrd   $t1, LOONGARCH_CSR_BADV
    csrwr   $t1, LOONGARCH_CSR_TLBEHI

    li.w    $t0, 0x1c00043           # V=1, G=1, D=1, PPN=0x1c000
    csrwr   $t0, LOONGARCH_CSR_TLBELO0
    li.w    $t0, 0x1c00043
    csrwr   $t0, LOONGARCH_CSR_TLBELO1

    tlbfill

restore_and_ertn:
    csrrd   $t0, LOONGARCH_CSR_KS0
    csrrd   $t1, LOONGARCH_CSR_KS1
    ertn

# ============================================================
# General exception handler (virtual at 0xa000_xxxx)
# ============================================================
except_handler:
    # Save only general-purpose registers ($t0, $t1) to KSCRATCH
    csrwr   $t0, LOONGARCH_CSR_KS0
    csrwr   $t1, LOONGARCH_CSR_KS1

    # Check if it's a PME exception (ECODE == 0x04)
    csrrd   $t0, LOONGARCH_CSR_STAT
    srli.w  $t1, $t0, 16
    andi    $t1, $t1, 0x3f
    li.w    $t2, EXC_PME
    bne     $t1, $t2, fail

    # Check if it's a DTLB fault (subcode == 1)
    srli.w  $t1, $t0, 22
    andi    $t1, $t1, 0x1ff
    li.w    $t2, 1
    bne     $t1, $t2, fail

    # Set TLBIDX.I_D = 1 to select DTLB (no need to preserve old value)
    csrrd   $t0, LOONGARCH_CSR_TLBIDX
    li.w    $t1, 0x10000
    or      $t0, $t0, $t1
    csrwr   $t0, LOONGARCH_CSR_TLBIDX

    # Locate TLB entry via tlbsrch
    csrrd   $t0, LOONGARCH_CSR_BADV
    csrwr   $t0, LOONGARCH_CSR_TLBEHI
    tlbsrch

    # Check NE bit (0 = found)
    csrrd   $t0, LOONGARCH_CSR_TLBIDX
    srli.w  $t1, $t0, 31
    andi    $t1, $t1, 0x1
    bnez    $t1, fail

    # Update entry: V=1, G=1, D=1, same PPN (0x1c0001)
    li.w    $t1, 0x1c00043          # V=1, D=1, G=1, PPN=0x1c000
    csrwr   $t1, LOONGARCH_CSR_TLBELO0
    li.w    $t1, 0x1c00043
    csrwr   $t1, LOONGARCH_CSR_TLBELO1
    tlbwr

    # Restore general-purpose registers
    csrrd   $t0, LOONGARCH_CSR_KS0
    csrrd   $t1, LOONGARCH_CSR_KS1
    ertn
