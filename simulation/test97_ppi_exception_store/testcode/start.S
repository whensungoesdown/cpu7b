# Test: Store triggers DTLB miss, TLBR fills PLV=0, then PPI exception, fix PLV=3
# Exception handlers are mapped to 0xa000_xxxx via DMW0 (0xa000->0x1c00)
# Steps:
# 1) Set CRMD.PLV=3 (user mode).
# 2) Configure DMW0 to map 0xa0000000 -> 0x1c000000.
# 3) Enable paging (PG=1, DA=0), keep PLV=3.
# 4) Store to 0x20001000 -> DTLB miss -> TLBR fills with PLV=0.
# 5) Return -> store triggers PPI (ECODE=0x07) due to PLV mismatch.
# 6) Handler detects PPI/DTLB, updates TLB PLV=3, ertn.
# 7) Store succeeds (writes 0xcc). Read back and verify.
# 8) If verified, r5=0x5a.
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

#define EXC_PPI                      0x07   /* Privilege violation */

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

    # ----- Set CRMD.PLV = 3 (user mode) while keeping DA=0, PG=0 -----
    csrrd   $t0, LOONGARCH_CSR_CRMD
    li.w    $t1, ~0x3               # Clear PLV bits
    and     $t0, $t0, $t1
    ori     $t0, $t0, 0x3           # Set PLV=3
    csrwr   $t0, LOONGARCH_CSR_CRMD

    # ----- Configure DMW0: map 0xa000_0000 -> 0x1c00_0000 -----
    li.w    $t0, 0xa0000011
    csrwr   $t0, LOONGARCH_CSR_DMW0
    li.w    $t0, 0xa0000011
    csrwr   $t0, LOONGARCH_CSR_DMW1

    # ----- Filler instructions (will be executed after PPI fix) -----
    addi.w  $t0, $r0, 1
    addi.w  $t0, $r0, 2
    addi.w  $t0, $r0, 3

    # ----- Enable paging (PG=1, DA=0), keep PLV=3 -----
    csrrd   $t1, LOONGARCH_CSR_CRMD
    li.w    $t2, ~0x18              # Clear DA (bit3) and PG (bit4)
    and     $t3, $t1, $t2
    ori     $t4, $t3, 0x10          # Set PG=1
    csrwr   $t4, LOONGARCH_CSR_CRMD

    # ----- After enabling paging, the next few instructions will execute
    #       (ITLB entries filled by tlbr_handler with PLV=3 to avoid PPI).

    # ----- Trigger DTLB miss & PPI: store to unmapped VA -----
    li.w    $t0, 0x20001000          # Test VA
    li.w    $t7, 0xcc                # Data to store (use t7, not t9)
    st.w    $t7, $t0, 0              # This will cause DTLB miss -> TLBR (PLV=0) -> PPI -> fix -> retry

    # ----- Now read back and verify -----
    ld.w    $t8, $t0, 0              # Read back the value
    li.w    $t0, 0xcc
    bne     $t8, $t0, fail

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

    # PLV=0, V=1, G=1, D=1, PPN=0x1c0001
    li.w    $t0, 0x1c000143          # V=1, D=1, G=1, PLV=0 (bits 3:2=00)
    csrwr   $t0, LOONGARCH_CSR_TLBELO0
    li.w    $t0, 0x1c000143          # V=1, D=1, G=1, PLV=0 (bits 3:2=00)
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

    # PLV=3 (matches user mode), V=1, G=1, D=1, PPN=0x1c000
    li.w    $t0, 0x1c0004f           # V=1, D=1, G=1, PLV=3 (bits 3:2=11)
    csrwr   $t0, LOONGARCH_CSR_TLBELO0
    li.w    $t0, 0x1c0004f           # V=1, D=1, G=1, PLV=3 (bits 3:2=11)
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
    csrwr   $t0, LOONGARCH_CSR_KS0
    csrwr   $t1, LOONGARCH_CSR_KS1

    # Check if it's a PPI exception (ECODE == 0x07)
    csrrd   $t0, LOONGARCH_CSR_STAT
    srli.w  $t1, $t0, 16
    andi    $t1, $t1, 0x3f
    li.w    $t2, EXC_PPI
    bne     $t1, $t2, fail

    # Check if it's a DTLB fault (subcode == 1)
    srli.w  $t1, $t0, 22
    andi    $t1, $t1, 0x1ff
    li.w    $t2, 1
    bne     $t1, $t2, fail

    # Set TLBIDX.I_D = 1 to select DTLB
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

    # Update entry: change PLV from 0 to 3 (keep V=1, G=1, D=1, PPN=0x1c0001)
    li.w    $t1, 0x1c0004f           # V=1, D=1, G=1, PLV=3
    csrwr   $t1, LOONGARCH_CSR_TLBELO0
    li.w    $t1, 0x1c0004f           # V=1, D=1, G=1, PLV=3
    csrwr   $t1, LOONGARCH_CSR_TLBELO1
    tlbwr

    csrrd   $t0, LOONGARCH_CSR_KS0
    csrrd   $t1, LOONGARCH_CSR_KS1
    ertn
