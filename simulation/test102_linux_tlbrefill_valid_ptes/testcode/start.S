# Test: Paging with TLBR fill V=0, then PIS exception, fix by tlbsrch + tlbwr
# Exception handlers are mapped to 0xa000_xxxx via DMW0 (0xa000->0x1c00)
# Steps:
# 1) Set EENTRY and TLBRENTRY to handlers at 0xa0xxxxxx.
# 2) Configure DMW0 to map 0xa0000000 -> 0x1c000000.
# 3) Enable paging (PG=1, DA=0).
# 4) Access unmapped VA -> TLBR exception (handler at 0xa0... works via DMW0).
#    TLBR handler checks subcode: ITLB -> V=1, DTLB -> V=0.
# 5) Store to same VA -> PIS exception (ECODE=0x02).
#    General handler (at 0xa0...) uses tlbsrch to find entry, sets V=1, tlbwr.
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
#define LOONGARCH_CSR_KS2            0x32

#define EXCEPTION_KS2                   LOONGARCH_CSR_KS2

#define LOONGARCH_CSR_PGDL              0x19    /* Page table base address when VA[47] = 0 */
#define LOONGARCH_CSR_PGDH              0x1a    /* Page table base address when VA[47] = 1 */
#define LOONGARCH_CSR_PGD               0x1b    /* Page table base */


#define EXC_PIS                      0x02   /* Store page invalid */


       .macro set_tlbidx_by_esubcode tmp0, tmp1
            csrrd   \tmp1, 0x5                // Read ESTAT
            srli.w  \tmp1, \tmp1, 22
            andi    \tmp1, \tmp1, 0x1ff

            li.w    \tmp0, 1
            bne     \tmp1, \tmp0, .Lnot_esubcode1_\@
            li.w    \tmp0, 0x00010000         // rd: value to write (set bit16)
            b       .Ldone_\@
        .Lnot_esubcode1_\@:
            li.w    \tmp0, 0x00000000         // rd: value to write (clear bit16)
        .Ldone_\@:
            li.w    \tmp1, 0x00010000         // rj: mask (only bit16)
            csrxchg \tmp0, \tmp1, 0x10        // Now tmp0 = old TLBIDX, CSR updated
        .endm



.text
.globl _start
_start:
    # ----- Set exception vectors to virtual addresses (0xa000_xxxx) -----
    la      $t0, except_handler      # $t0 = 0x1c00_xxxx  0x3c00_xxxx
    //li.w    $t1, 0xa0000000        # 3c00 + 8000 - a000 = 1c00
    li.w    $t1, 0x80000000          # try to make the except_handler landing on 0x1c00_ physical memory  
    add.w   $t0, $t0, $t1            #
    csrwr   $t0, LOONGARCH_CSR_EENTRY

    la      $t0, tlbr_handler        # $t0 = 0x1c00_xxxx
    //li.w    $t1, 0xa0000000
    li.w    $t1, 0x80000000
    add.w   $t0, $t0, $t1
    csrwr   $t0, LOONGARCH_CSR_TLBRENTRY

    # ----- Configure DMW0:
    li.w    $t0, 0xa0000011
    csrwr   $t0, LOONGARCH_CSR_DMW0
    li.w    $t0, 0xa0000011
    csrwr   $t0, LOONGARCH_CSR_DMW1


    # ----- Setup 2-level page tables (4KB pages, 高10位/中10位) -----
    # PGD phys = 0xbc005000
    # PMD phys = 0xbc006000

    # PGD[240] = PMD | V   (偏移 = 240 * 4 = 960 = 0x3C0)
    li.w    $t0, 0xbc005000
    addi.w  $t0, $t0, 960            # 0x3C0
    li.w    $t1, 0xbc006000          # PMD phys | V   no V
    st.w    $t1, $t0, 0

    # PMD[0] = phys 0x1c000000 | V | D   (对应虚拟地址 0x3c000000)
    li.w    $t0, 0xbc006000
    li.w    $t1, 0x1c000003
    st.w    $t1, $t0, 0

    # PMD[1] = phys 0x1c001000 | V | D   (对应虚拟地址 0x3c001000)
    li.w    $t1, 0x1c001003
    st.w    $t1, $t0, 4

    # PMD[2] = phys 0x1c002000 | V | D   (对应虚拟地址 0x3c002000)
    li.w    $t1, 0x1c002003
    st.w    $t1, $t0, 8

    # Set PGDL to PGD physical address
    li.w    $t0, 0xbc005000
    csrwr   $t0, LOONGARCH_CSR_PGDL



    # ----- Fill physical page 0x1c001000 with NOP instructions -----
    li.w    $t0, 0x1c001000        # 目标物理页起始地址
    li.w    $t1, 4                 # 4 条 NOP
    li.w    $t2, 0x03400000        # LoongArch NOP 机器码
1:
    st.w    $t2, $t0, 0            # 写入一条 NOP
    addi.w  $t0, $t0, 4            # 地址 +4
    addi.w  $t1, $t1, -1           # 计数 -1
    bnez    $t1, 1b                # 未写完则继续


    # ----- Filler instructions -----
    addi.w  $t0, $r0, 1
    addi.w  $t0, $r0, 2
    addi.w  $t0, $r0, 3


    la.abs          $t0, 0f
    jirl            $zero, $t0, 0
0:

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
    li.w    $t0, 0x3c002000          # Test VA
    li.w    $t8, 0x12344678          # Data to store
    st.w    $t8, $t0, 0              # Store -> will cause TLBR (V=0), then PIS

    # ----- Success -----
    li.w    $r5, 0x5a
    b       success

fail:
    li.w    $r5, 0
success:
#    b       success
    li.w      $t8, 0x3c001000
    jr      $t8
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

# ============================================================
# TLBR (TLB Refill) exception handler (virtual at 0xa000_xxxx)
# ============================================================
tlbr_handler:
        csrwr   $t0, LOONGARCH_CSR_KS0
        csrwr   $t1, LOONGARCH_CSR_KS1
        csrwr   $ra, EXCEPTION_KS2


        set_tlbidx_by_esubcode $t0, $t1

        csrrd   $t0, LOONGARCH_CSR_PGD
        csrrd   $t1, LOONGARCH_CSR_BADV
        srli.w  $t1, $t1, 0x16
        andi    $t1, $t1, 0x3ff
        slli.w  $t1, $t1, 0x2
        add.w   $t0, $t0, $t1
        li.w    $ra, 0x1fffffff
        and     $t0, $t0, $ra
        ld.w    $t0, $t0, 0

        csrrd   $t1, LOONGARCH_CSR_BADV
        srli.w  $t1, $t1, 12
        andi    $t1, $t1, 0x3ff
        slli.w  $t1, $t1, 2
        add.w   $t0, $t0, $t1
        and     $t0, $t0, $ra

        // uty: test
        // clear bit[2]
        ori     $t0, $t0, 0x4
        xori    $t0, $t0, 0x4


        ld.w    $t1, $t0, 0
        srli.w  $ra, $t1, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t1, $t1, 0xff
        add.w   $t1, $t1, $ra
        csrwr   $t1, LOONGARCH_CSR_TLBELO0

        ld.w    $t1, $t0, 0x4
        srli.w  $ra, $t1, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t1, $t1, 0xff
        add.w   $t1, $t1, $ra
        csrwr   $t1, LOONGARCH_CSR_TLBELO1

        tlbfill

        csrrd   $t0, LOONGARCH_CSR_KS0
        csrrd   $t1, LOONGARCH_CSR_KS1
        csrrd   $ra, EXCEPTION_KS2

        ertn

# ============================================================
# General exception handler (virtual at 0xa000_xxxx)
# ============================================================
except_handler:
    # Save only general-purpose registers ($t0, $t1) to KSCRATCH
    csrwr   $t0, LOONGARCH_CSR_KS0
    csrwr   $t1, LOONGARCH_CSR_KS1

    # Check if it's a PIS exception (ECODE == 0x02)
    csrrd   $t0, LOONGARCH_CSR_STAT
    srli.w  $t1, $t0, 16
    andi    $t1, $t1, 0x3f
    li.w    $t2, EXC_PIS
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
    #csrrd   $t0, LOONGARCH_CSR_BADV
    #csrwr   $t0, LOONGARCH_CSR_TLBEHI
    tlbsrch

    # Check NE bit (0 = found)
    csrrd   $t0, LOONGARCH_CSR_TLBIDX
    srli.w  $t1, $t0, 31
    andi    $t1, $t1, 0x1
    bnez    $t1, fail

    # Update entry: V=1, G=1, D=1, same PPN (0x1c0001)
    li.w    $t1, 0x1c00043
    csrwr   $t1, LOONGARCH_CSR_TLBELO0
    li.w    $t1, 0x1c00043
    csrwr   $t1, LOONGARCH_CSR_TLBELO1
    tlbwr

    # Restore general-purpose registers
    csrrd   $t0, LOONGARCH_CSR_KS0
    csrrd   $t1, LOONGARCH_CSR_KS1
    ertn
