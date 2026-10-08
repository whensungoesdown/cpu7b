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
#define LOONGARCH_CSR_ESTAT          0x5
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
#define LOONGARCH_CSR_KS3            0x33

#define EXCEPTION_KS0                   LOONGARCH_CSR_KS0
#define EXCEPTION_KS1                   LOONGARCH_CSR_KS1
#define EXCEPTION_KS2                   LOONGARCH_CSR_KS2

#define PERCPU_BASE_KS                  LOONGARCH_CSR_KS3

#define LOONGARCH_CSR_PGDL              0x19    /* Page table base address when VA[47] = 0 */
#define LOONGARCH_CSR_PGDH              0x1a    /* Page table base address when VA[47] = 1 */
#define LOONGARCH_CSR_PGD               0x1b    /* Page table base */


#define EXC_PIS                      0x02   /* Store page invalid */

#define _PAGE_VALID_SHIFT       0
#define _PAGE_DIRTY_SHIFT       1
#define _PAGE_PLV_SHIFT         2  /* 2~3, two bits */
#define _CACHE_SHIFT            4  /* 4~5, two bits */
#define _PAGE_GLOBAL_SHIFT      6
#define _PAGE_HUGE_SHIFT        6  /* HUGE is a PMD bit */
#define _PAGE_PRESENT_SHIFT     7
#define _PAGE_WRITE_SHIFT       8
#define _PAGE_PROTNONE_SHIFT    9
#define _PAGE_SPECIAL_SHIFT     10
#define _PAGE_HGLOBAL_SHIFT     12 /* HGlobal is a PMD bit */
#define _PAGE_PFN_SHIFT         12
#define _PAGE_PFN_END_SHIFT     31

#define _ULCAST_

#define _PAGE_VALID             (_ULCAST_(1) << _PAGE_VALID_SHIFT)
#define _PAGE_DIRTY             (_ULCAST_(1) << _PAGE_DIRTY_SHIFT)
#define _PAGE_PLV               (_ULCAST_(3) << _PAGE_PLV_SHIFT)
#define _PAGE_GLOBAL            (_ULCAST_(1) << _PAGE_GLOBAL_SHIFT)
#define _PAGE_HUGE              (_ULCAST_(1) << _PAGE_HUGE_SHIFT)
#define _PAGE_HGLOBAL           (_ULCAST_(1) << _PAGE_HGLOBAL_SHIFT)
#define _CACHE_MASK             (_ULCAST_(3) << _CACHE_SHIFT)


#define _PAGE_PRESENT           (_ULCAST_(1) << _PAGE_PRESENT_SHIFT)
#define _PAGE_WRITE             (_ULCAST_(1) << _PAGE_WRITE_SHIFT)
#define _PAGE_MODIFIED          (_ULCAST_(1) << _PAGE_DIRTY_SHIFT) //it may be useless
#define _PAGE_SPECIAL           (_ULCAST_(1)<<_PAGE_SPECIAL_SHIFT)
#define _PAGE_PROTNONE          (_ULCAST_(1) << _PAGE_PROTNONE_SHIFT)

#define PTR             .word


#define LONG_ADDU       add.w
#define LONG_ADDIU      addi.w
#define LONG_SUBU       sub.w
#define LONG_L          ld.w
#define LONG_S          st.w
#define LONG_SP         swp
#define LONG_SLL        slli.w
#define LONG_SLLV       sll.w
#define LONG_SRL        srli.w
#define LONG_SRLV       srl.w
#define LONG_SRA        srai.w
#define LONG_SRAV       sra.w



        .macro BACKUP_T0T1
        csrwr   $t0, EXCEPTION_KS0
        csrwr   $t1, EXCEPTION_KS1
        .endm

#define x0 $r21

        .macro  CLI
        li.w    $t0, 0x7
        csrxchg $zero, $t0, LOONGARCH_CSR_CRMD
        csrrd   x0, PERCPU_BASE_KS
        .endm



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


        // Macro: Set bit 16 (I/D flag) in TLBIDX CSR
        // Usage: set_tlbidx_i_d t0, t1
        // The macro uses two temporary registers (overwritten).
        .macro set_tlbidx_i_d tmp0, tmp1
            li.w    \tmp0, 0x00010000          // Value to write: bit16 = 1
            li.w    \tmp1, 0x00010000          // Mask: only bit16 is affected
            csrxchg \tmp0, \tmp1, 0x10         // Atomic update of TLBIDX (CSR address 0x10)
        .endm

        // Macro: Clear bit 16 (I/D flag) in TLBIDX CSR
        // Usage: clear_tlbidx_i_d t0, t1
        // The macro uses two temporary registers (overwritten).
        .macro clear_tlbidx_i_d tmp0, tmp1
            li.w    \tmp0, 0x00000000          // Value to write: bit16 = 0
            li.w    \tmp1, 0x00010000          // Mask: only bit16 is affected
            csrxchg \tmp0, \tmp1, 0x10         // Atomic update of TLBIDX (CSR address 0x10)
        .endm



.text
.globl _start
_start:
    # ----- Set exception vectors to virtual addresses (0xa000_xxxx) -----
    la      $t0, except_handler      # $t0 = 0x1c00_xxxx  0x3c00_xxxx
    //li.w    $t1, 0xa0000000        # 3c00 + 8000 - a000 = 1c00
    //li.w    $t1, 0x80000000          # try to make the except_handler landing on 0x1c00_ physical memory  
    add.w   $t0, $t0, $t1            #
    csrwr   $t0, LOONGARCH_CSR_EENTRY

    la      $t0, tlbr_handler        # $t0 = 0x1c00_xxxx
    //li.w    $t1, 0xa0000000
    //li.w    $t1, 0x80000000
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

    # ----- 新增：PGD[510] = PMD 表基址 -----
    # 用于 VA 0x7f800000 - 0x7fc00000
    # 偏移 = 510 * 4 = 2040 = 0x7F8
    li.w    $t0, 0xbc005000
    addi.w  $t0, $t0, 2040           # 0x7F8
    li.w    $t1, 0xbc006000          # 复用同一个 PMD 表
    st.w    $t1, $t0, 0


    # PMD[0] = phys 0x1c000000 | V | D   (对应虚拟地址 0x3c000000)
    li.w    $t0, 0xbc006000
    //li.w    $t1, 0x1c000003
    li.w    $t1, 0x0
    st.w    $t1, $t0, 0

    # PMD[1] = phys 0x1c001000 | V | D   (对应虚拟地址 0x3c001000)
    //li.w    $t1, 0x1c001003
    li.w    $t1, 0x0
    st.w    $t1, $t0, 4

    # PMD[2] = phys 0x1c002000 | V | D   (对应虚拟地址 0x3c002000)
    //li.w    $t1, 0x1c002003
    li.w    $t1, 0x0
    st.w    $t1, $t0, 8

    # PMD[3], need to initialize this, since it is paired with PMD[2]
    li.w    $t1, 0x0
    st.w    $t1, $t0, 0xc

    # ----- 新增：PMD[862] = phys 0x1c00a000 | _PAGE_PRESENT | _PAGE_WRITE，V=0 -----
    # 对应 VA 0x7fb5ea40，PMD 索引 = 862
    # 偏移 = 862 * 4 = 3448 = 0xD78
    # PTE 值 = 0x1c00a000 | 0x80 | 0x100 = 0x1c00a180
    li.w    $t0, 0xbc006000
    li.w    $t1, 3448                # 0xD78
    add.w   $t0, $t0, $t1
    #li.w    $t1, 0x1c00a180          # V=0, PRESENT=1, WRITE=1
    li.w    $t1, 0x0                 # write 0
    st.w    $t1, $t0, 0
    li.w    $t1, 0x0                 # Clear the other pte
    st.w    $t1, $t0, 4              # 

    # Set PGDL to PGD physical address
    li.w    $t0, 0xbc005000
    csrwr   $t0, LOONGARCH_CSR_PGDL



	// 14ff6bc3        lu12i.w $r3,523102(0x7fb5e)
	// 03a90063        ori     $r3,$r3,0xa40
	// 14246897        lu12i.w $r23,74564(0x12344)
	// 0399e2f7        ori     $r23,$r23,0x678
	// 2981e077        st.w    $r23,$r3,120(0x78)

    // li.w    $t0, 0x1c001000        # 目标物理页起始地址
    // li.w    $t1, 0x14ff6bc3         
    // st.w    $t1, $t0, 0            # 写入一条

    // li.w    $t0, 0x1c001004
    // li.w    $t1, 0x03a90063         
    // st.w    $t1, $t0, 0            # 写入一条

    // li.w    $t0, 0x1c001008
    // li.w    $t1, 0x14246897         
    // st.w    $t1, $t0, 0            # 写入一条

    // li.w    $t0, 0x1c00100c
    // li.w    $t1, 0x0399e2f7         
    // st.w    $t1, $t0, 0            # 写入一条

    // li.w    $t0, 0x1c001010
    // li.w    $t1, 0x2981e077         
    // st.w    $t1, $t0, 0            # 写入一条



    // 0280000c        addi.w  $r12,$r0,0

    // 14ff6bcd        lu12i.w $r13,523102(0x7fb5e)
    // 03a901ad        ori     $r13,$r13,0xa40
    // 001031ac        add.w   $r12,$r13,$r12
    // 2880018c        ld.w    $r12,$r12,0

    li.w    $t0, 0x1c001000        # 目标物理页起始地址
    li.w    $t1, 0x0280000c         
    st.w    $t1, $t0, 0            # 写入一条

    li.w    $t0, 0x1c001004
    li.w    $t1, 0x14ff6bcd         
    st.w    $t1, $t0, 0            # 写入一条

    li.w    $t0, 0x1c001008
    li.w    $t1, 0x03a901ad         
    st.w    $t1, $t0, 0            # 写入一条

    li.w    $t0, 0x1c00100c
    li.w    $t1, 0x001031ac         
    st.w    $t1, $t0, 0            # 写入一条

    li.w    $t0, 0x1c001010
    li.w    $t1, 0x2880018c         
    st.w    $t1, $t0, 0            # 写入一条


    # ----- Fill physical page 0x1c001000 with NOP instructions -----
    li.w    $t0, 0x1c001014        # 目标物理页起始地址
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
    //li.w    $t0, 0x3c002008          # Test VA
    li.w    $t0, 0x7fb5ea40          # Test VA                 FIRST ACCESS
    li.w    $t8, 0x12344678          # Data to store
    //st.w    $t8, $t0, 0x00           # Store -> will cause TLBR (V=0), then PIS

    li.w    $t0, 0x7fb5fa40          # Test VA                 access the OTHER page of the PTE pair
    li.w    $t8, 0x12344678          # Data to store
    //st.w    $t8, $t0, 0x74           # Store -> will cause TLBR (V=0), then PIS
    //nop
// if not store data to 0x7fb5fa40, then data here should be the default 0xaaaabbbb from sram.mif

    # ----- Success -----
    li.w    $r5, 0x5a
    b       success

fail:
    li.w    $r5, 0
success:
#    b       success
    li.w      $t8, 0x3c001000
    jr      $t8
#    li.w    $r3, 0x7fb5ea40
#    li.w    $r23, 0x12344678
#    st.w    $r23, $r3, 0x78                         # SECOND TIME ACCESS
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


tlb_do_page_fault_0:
tlb_do_page_fault_1:

        csrrd   $t0, LOONGARCH_CSR_BADV     # $t0 = BADV
        li.w    $t1, 0xfffff000
        and     $t0, $t0, $t1               # 页对齐，清低 12 位

        li.w    $t1, 0x3c000000
        beq     $t0, $t1, 1f
        li.w    $t1, 0x3c001000
        beq     $t0, $t1, 2f
        li.w    $t1, 0x3c002000
        beq     $t0, $t1, 3f
        li.w    $t1, 0x7fb5e000
        beq     $t0, $t1, 4f
        li.w    $t1, 0x7fb5f000
        beq     $t0, $t1, 5f

        b       9f                          # 其他地址，直接返回

1:      # BADV == 0x3c000000，PMD[0] 偏移 0
        li.w    $t0, 0xbc006000
        li.w    $t1, 0x1c000080
        st.w    $t1, $t0, 0
        b       9f

2:      # BADV == 0x3c001000，PMD[1] 偏移 4
        li.w    $t0, 0xbc006000
        li.w    $t1, 0x1c001080
        st.w    $t1, $t0, 4
        b       9f

3:      # BADV == 0x3c002000，PMD[2] 偏移 8
        li.w    $t0, 0xbc006000
        li.w    $t1, 0x1c002180
        st.w    $t1, $t0, 8
        b       9f

4:      # BADV == 0x7fb5e000，PMD[862] 偏移 0xD78
        li.w    $t0, 0xbc006000
        li.w    $t1, 3448                # 0xD78
        add.w   $t0, $t0, $t1

        li.w    $t1, 0x1c00a180          # V=0, PRESENT=1, WRITE=1
        st.w    $t1, $t0, 0
        b       9f

5:      # BADV == 0x7fb5f000，PMD[862] 偏移 0xD7c
        li.w    $t0, 0xbc006000
        li.w    $t1, 3452                # 0xD7c
        add.w   $t0, $t0, $t1

        li.w    $t1, 0x1c00b180          # V=0, PRESENT=1, WRITE=1
        st.w    $t1, $t0, 0
        b       9f


9:
        csrrd   $t0, LOONGARCH_CSR_KS0
        csrrd   $t1, LOONGARCH_CSR_KS1
        csrrd   $ra, EXCEPTION_KS2
        ertn


handle_tlb_fetch:
        csrwr   $ra, EXCEPTION_KS2


        // uty: test
        //set_tlbidx_by_esubcode $t0, $t1
        clear_tlbidx_i_d   $t0, $t1
        //csrwr   $t0, 0x10

        lu12i.w $ra, 0xc
        slli.w  $ra, $ra, 0x10
        csrrd   $t0, LOONGARCH_CSR_BADV
        bgeu    $t0, $ra, vmalloc_fetch

        csrrd   $t1, LOONGARCH_CSR_PGD

vmalloc_done_fetch:
        /* Get PGD offset in bytes */
        srli.w  $t0, $t0, 0x16
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 0x2
        add.w   $t1, $t1, $t0
        csrrd   $t0, LOONGARCH_CSR_BADV
        ld.w    $t1, $t1, 0
        srli.w  $t0, $t0, 0xc
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 0x2
        add.w   $t0, $t0, $t1

label_smp_pgtable_fetch:
        ld.w    $t1, $t0, 0
        tlbsrch

        srli.w  $ra, $t1, _PAGE_PRESENT_SHIFT
        andi    $ra, $ra, 1
        beq     $ra, $zero, nopage_tlb_fetch


        #ori    $t1, $t1, _PAGE_VALID
        ori     $t1, $t1, 0x1
        st.w    $t1, $t0, 0

        ori     $t0, $t0, 0x4
        xori    $t0, $t0, 0x4

        ld.w    $t1, $t0, 0
        srli.w  $ra, $t1, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t1, $t1, 0xff
        add.w   $t1, $t1, $ra
        csrwr   $t1, LOONGARCH_CSR_TLBELO0

        ld.w    $t0, $t0, 0x4
        srli.w  $ra, $t0, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t0, $t0, 0xff
        add.w   $t0, $t0, $ra
        csrwr   $t0, LOONGARCH_CSR_TLBELO1

        tlbwr

        csrrd   $t0, LOONGARCH_CSR_KS0
        csrrd   $t1, LOONGARCH_CSR_KS1
        csrrd   $ra, EXCEPTION_KS2
        ertn

vmalloc_fetch:
        //la.abs  $t1, swapper_pg_dir
        b       vmalloc_done_fetch

        /*
         * This is the entry point when build_tlbchange_handler_head
         * spots a huge page.
         */

nopage_tlb_fetch:
        dbar    0
        csrrd   $ra, EXCEPTION_KS2
        //la.abs  $t0, tlb_do_page_fault_0
        //jirl    $r0, $t0, 0
        beq	$zero, $zero, tlb_do_page_fault_0


handle_tlb_load:
        csrwr   $ra, EXCEPTION_KS2

        // uty: test
        //set_tlbidx_by_esubcode $t0, $t1
        set_tlbidx_i_d   $t0, $t1

        lu12i.w $ra, 0xc
        slli.w  $ra, $ra, 0x10
        csrrd   $t0, LOONGARCH_CSR_BADV
        bgeu    $t0, $ra, vmalloc_load

        csrrd   $t1, LOONGARCH_CSR_PGD

vmalloc_done_load:
        /* Get PGD offset in bytes */
        srli.w  $t0, $t0, 0x16
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 0x2
        add.w   $t1, $t1, $t0
        csrrd   $t0, LOONGARCH_CSR_BADV
        ld.w    $t1, $t1, 0
        srli.w  $t0, $t0, 0xc
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 0x2
        add.w   $t0, $t0, $t1

label_smp_pgtable_load:
        ld.w    $t1, $t0, 0
        tlbsrch

        srli.w  $ra, $t1, _PAGE_PRESENT_SHIFT
        andi    $ra, $ra, 1
        beq     $ra, $zero, nopage_tlb_load


        ori     $t1, $t1, _PAGE_VALID
        st.w    $t1, $t0, 0

        ori     $t0, $t0, 0x4
        xori    $t0, $t0, 0x4

        ld.w    $t1, $t0, 0
        srli.w  $ra, $t1, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t1, $t1, 0xff
        add.w   $t1, $t1, $ra
        csrwr   $t1, LOONGARCH_CSR_TLBELO0

        ld.w    $t0, $t0, 0x4
        srli.w  $ra, $t0, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t0, $t0, 0xff
        add.w   $t0, $t0, $ra
        csrwr   $t0, LOONGARCH_CSR_TLBELO1

        tlbwr

        csrrd   $t0, LOONGARCH_CSR_KS0
        csrrd   $t1, LOONGARCH_CSR_KS1
        csrrd   $ra, EXCEPTION_KS2
        ertn

vmalloc_load:
        //la.abs  $t1, swapper_pg_dir
        b       vmalloc_done_load

        /*
         * This is the entry point when build_tlbchange_handler_head
         * spots a huge page.
         */

nopage_tlb_load:
        dbar    0
        csrrd   $ra, EXCEPTION_KS2
        la.abs  $t0, tlb_do_page_fault_0
        jirl    $r0, $t0, 0



handle_tlb_store:
        csrwr   $ra, EXCEPTION_KS2


        // uty: test
        //set_tlbidx_by_esubcode $t0, $t1
        set_tlbidx_i_d   $t0, $t1   // dtlb

        lu12i.w $ra, 0xc
        slli.w  $ra, $ra, 0x10
        csrrd   $t0, LOONGARCH_CSR_BADV
        bgeu    $t0, $ra, vmalloc_store

        csrrd   $t1, LOONGARCH_CSR_PGD

vmalloc_done_store:
        /* Get PGD offset in bytes */
        srli.w  $t0, $t0, 0x16
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 2
        add.w   $t1, $t1, $t0
        csrrd   $t0, LOONGARCH_CSR_BADV
        ld.w    $t1, $t1, 0
        srli.w  $t0, $t0, 0xc
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 0x2
        add.w   $t1, $t1, $t0

label_smp_pgtable_store:
        ld.w    $t0, $t1, 0
        tlbsrch

        srli.w  $ra, $t0, _PAGE_PRESENT_SHIFT
        andi    $ra, $ra, ((_PAGE_PRESENT | _PAGE_WRITE) >> _PAGE_PRESENT_SHIFT)
        xori    $ra, $ra, ((_PAGE_PRESENT | _PAGE_WRITE) >> _PAGE_PRESENT_SHIFT)
        bne     $ra, $r0, nopage_tlb_store

        ori     $t0, $t0, (_PAGE_VALID | _PAGE_DIRTY)
        st.w    $t0, $t1, 0

        ori     $t1, $t1, 4
        xori    $t1, $t1, 4

        ld.w    $t0, $t1, 0
        srli.w  $ra, $t0, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t0, $t0, 0xff
        add.w   $t0, $t0, $ra
        csrwr   $t0, LOONGARCH_CSR_TLBELO0

        ld.w    $t1, $t1, 4
        srli.w  $ra, $t1, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t1, $t1, 0xff
        add.w   $t1, $t1, $ra
        csrwr   $t1, LOONGARCH_CSR_TLBELO1


// uty: test
// take a lot of cycles to emulate how much time uart debug msgs cost

//    li.w    $t0, 3000
//    li.w    $t1, 0
//loop:
//    addi.w  $t0, $t0, -1
//    bne     $t0, $t1, loop


        tlbwr


        csrrd   $t0, LOONGARCH_CSR_KS0
        csrrd   $t1, LOONGARCH_CSR_KS1
        csrrd   $ra, EXCEPTION_KS2
        ertn

vmalloc_store:
        //la.abs  $t1, swapper_pg_dir
        b       vmalloc_done_store

        /*
         * This is the entry point when build_tlbchange_handler_head
         * spots a huge page.
         */

nopage_tlb_store:
        dbar    0
        csrrd   $ra, EXCEPTION_KS2
        la.abs  $t0, tlb_do_page_fault_1
        jirl    $r0, $t0, 0


handle_tlb_modify:
        csrwr   $ra, EXCEPTION_KS2


        // uty: test
        //set_tlbidx_by_esubcode $t0, $t1
        set_tlbidx_i_d   $t0, $t1   // dtlb


        /*
         * The vmalloc handling is not in the hotpath.
         */
        lu12i.w $ra, 0xc
        slli.w  $ra, $ra, 0x10
        csrrd   $t0, LOONGARCH_CSR_BADV
        bgeu    $t0, $ra, vmalloc_modify

        csrrd   $t1, LOONGARCH_CSR_PGD

vmalloc_done_modify:
        /* Get PGD offset in bytes */
        srli.w  $t0, $t0, 0x16
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 2
        add.w   $t1, $t1, $t0
        csrrd   $t0, LOONGARCH_CSR_BADV
        ld.w    $t1, $t1, 0
        srli.w  $t0, $t0, 0xc
        andi    $t0, $t0, 0x3ff
        slli.w  $t0, $t0, 0x2
        add.w   $t1, $t1, $t0

label_smp_pgtable_modify:
        ld.w    $t0, $t1, 0
        tlbsrch

        srli.w  $ra, $t0, _PAGE_WRITE_SHIFT
        andi    $ra, $ra, 1
        beq     $ra, $r0, nopage_tlb_modify

        ori     $t0, $t0, (_PAGE_VALID | _PAGE_DIRTY)
        st.w    $t0, $t1, 0

        ori     $t1, $t1, 4
        xori    $t1, $t1, 4

        ld.w    $t0, $t1, 0
        srli.w  $ra, $t0, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t0, $t0, 0xff
        add.w   $t0, $t0, $ra
        csrwr   $t0, LOONGARCH_CSR_TLBELO0

        ld.w    $t1, $t1, 0x4
        srli.w  $ra, $t1, 0xc
        slli.w  $ra, $ra, 0x8
        andi    $t1, $t1, 0xff
        add.w   $t1, $t1, $ra
        csrwr   $t1, LOONGARCH_CSR_TLBELO1

        tlbwr


        csrrd   $t0, LOONGARCH_CSR_KS0
        csrrd   $t1, LOONGARCH_CSR_KS1
        csrrd   $ra, EXCEPTION_KS2
        ertn

vmalloc_modify:
        //la.abs  $t1, swapper_pg_dir
        b       vmalloc_done_modify


nopage_tlb_modify:
        dbar    0
        csrrd   $ra, EXCEPTION_KS2
        la.abs  $t0, tlb_do_page_fault_1
        jirl    $r0, $t0, 0


handle_reserved:         
	nop
	nop
	nop
	nop
	nop
	nop
	nop



excp_handlers:
        PTR     handle_reserved         /* 0: External interrupt, handled separately */
        PTR     handle_tlb_load         /* 1: TLB miss on a load */
        PTR     handle_tlb_store        /* 2: TLB miss on a store */
        PTR     handle_tlb_fetch        /* 3: TLB miss on a ifetch */
        PTR     handle_tlb_modify       /* 4: TLB modified fault */
        PTR     handle_reserved         /* 5: Reserved */
        PTR     handle_reserved         /* 6: Reserved */
        PTR     handle_reserved         /* 7: TLB Privilege Error */
        PTR     handle_reserved         /* 8: Address error exception */
        PTR     handle_reserved         /* 9: Unaligned access exception */
        PTR     handle_reserved         /* a: Reserved */
        PTR     handle_reserved         /* b: Syscall */
        PTR     handle_reserved         /* c: Breakpoint exception (break) */
        PTR     handle_reserved         /* d: Illegal instruction exception */
        /* Fill remaining 14~63 with do_reserved */
        .rept   50
        PTR     handle_reserved
        .endr

# ============================================================
# General exception handler (virtual at 0xa000_xxxx)
# ============================================================
except_handler:
        BACKUP_T0T1

        // uty: test
        CLI

        csrrd   $t0, LOONGARCH_CSR_ESTAT                                  
        srli.w  $t1, $t0, 0x10   /* get Ecode */                           
        andi    $t1, $t1, 0x3f
        //beq     $t1, $zero, 1f    /* if irq */                             
        beq     $t1, $zero, fail    /* if irq */                             

        /* ----------------- Exception handling ----------------- */     
        /* Ensure ECODE index is within valid range (0~63) */            
        slli.w  $t0, $t1, 2               /* $t0 = ECODE * 4 */             
        la.abs  $t1, excp_handlers                                        
        add.w   $t1, $t1, $t0
        LONG_L  $t0, $t1, 0               /* $t0 = handler function address */
                                                                         

        /* Call C handler*/                                              
        // code wont return here, do not use $ra before SAVE_SOME         
        //jirl  $ra, $t0, 0     
        jirl    $r0, $t0, 0

	//beq	$zero, $zero, handle_tlb_fetch

