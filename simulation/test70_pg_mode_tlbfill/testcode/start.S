# Test: Simple addi instructions then enable paging (PG=1, DA=0)
# Steps:
# 1) Initialize EENTRY and TLBRENTRY to exception handlers.
# 2) Execute 5 addi instructions on $t0.
# 3) Read CRMD, clear DA and PG, set PG=1, keep IE/PLV unchanged.
# 4) Write back to CRMD.
# 5) Verify by reading back and checking PG=1, DA=0.
# On success: r5 = 0x5a, on failure: r5 = 0.

/* Kscratch registers */
#define LOONGARCH_CSR_KS0               0x30
#define LOONGARCH_CSR_KS1               0x31
#define LOONGARCH_CSR_KS2               0x32
#define LOONGARCH_CSR_KS3               0x33

/* Exception allocated KS0, KS1 and KS2 statically */
#define EXCEPTION_KS0                   LOONGARCH_CSR_KS0
#define EXCEPTION_KS1                   LOONGARCH_CSR_KS1
#define EXCEPTION_KS2                   LOONGARCH_CSR_KS2

#define LOONGARCH_CSR_BADV              0x7     /* Bad virtual address */

#define LOONGARCH_CSR_TLBELO0           0x12    /* TLB EntryLo0 */
#define LOONGARCH_CSR_TLBELO1           0x13    /* TLB EntryLo1 */

#define LOONGARCH_CSR_PGD               0x1b    /* Page table base */


.text
.globl _start
_start:
    # ----- Initialize exception entry points -----
    # Set EENTRY (CSR 0x0C) to except_handler
    la      $t0, except_handler
    csrwr   $t0, 0x0C

    # Set TLBRENTRY (CSR 0x88) to tlbr_handler
    la      $t0, tlbr_handler
    csrwr   $t0, 0x88

    # ----- 5 addi instructions -----
    addi.w  $t0, $r0, 1
    addi.w  $t0, $r0, 2
    addi.w  $t0, $r0, 3
    addi.w  $t0, $r0, 4
    addi.w  $t0, $r0, 5

    # ----- csrwr -> DMW0 = 0xA0000011 -----
    li.w    $t0, 0xA0000011
    csrwr   $t0, 0x180

    # ----- csrwr -> DMW1 = 0x90000001 -----
    li.w    $t0, 0xA0000011
    csrwr   $t0, 0x181

    # ----- Enable paging mode (PG=1, DA=0) -----
    csrrd   $t1, 0x0              # t1 = current CRMD

    # Clear DA (bit3) and PG (bit4) while keeping other bits
    li.w    $t2, ~0x18            # mask: ~(1<<3 | 1<<4) = ~0x18
    and     $t3, $t1, $t2         # t3 = CRMD with DA=0, PG=0

    # Set PG=1 (bit4), DA stays 0
    ori     $t4, $t3, 0x10        # set bit4 (PG=1)

    # Write back to CRMD (the instruction overwrites $t4 with old value)
    csrwr   $t4, 0x0

    # ----- Verify the write -----
    csrrd   $t5, 0x0              # t5 = new CRMD

    # Check PG == 1
    srli.w  $t6, $t5, 4
    andi    $t6, $t6, 0x1
    beqz    $t6, fail

    # Check DA == 0
    srli.w  $t7, $t5, 3
    andi    $t7, $t7, 0x1
    bnez    $t7, fail

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
    b       success               # loop forever

# ----- Exception handlers -----
except_handler:
    nop
    ertn

tlbr_handler:
        #li.w    $t0, 0x1C000000  # 将值 0x1C000000 加载到通用寄存器 $t0
        #csrwr   $t0, 0x11        # 将 $t0 的值写入 CSR 0x11 (TLBEHI)

	# G=1, PLV=0, V=1, D=1, PPN=1c000
	li.w    $t0, 0x1c00043
	csrwr   $t0, LOONGARCH_CSR_TLBELO0

	# G=1, PLV=0, V=1, D=1, PPN=1c000
	li.w    $t0, 0x1c00043
        csrwr   $t0, LOONGARCH_CSR_TLBELO1
        
        tlbfill

        nop
	
        #csrwr   $t0, LOONGARCH_CSR_KS0
        #csrwr   $t1, LOONGARCH_CSR_KS1
        #csrwr   $ra, EXCEPTION_KS2

        #csrrd   $t0, LOONGARCH_CSR_PGD
        #csrrd   $t1, LOONGARCH_CSR_BADV
        #srli.w  $t1, $t1, 0x16
        #slli.w  $t1, $t1, 0x2
        #add.w   $t0, $t0, $t1
        #li.w    $ra, 0xfffffff
        #and     $t0, $t0, $ra
        #ld.w    $t0, $t0, 0

        #csrrd   $t1, LOONGARCH_CSR_BADV
        #srli.w  $t1, $t1, 0xa
        #andi    $t1, $t1, 0xff8
        #add.w   $t0, $t0, $t1
        #and     $t0, $t0, $ra

        #ld.w    $t1, $t0, 0
        #srli.w  $ra, $t1, 0xc
        #slli.w  $ra, $ra, 0x8
        #andi    $t1, $t1, 0xff
        #add.w   $t1, $t1, $ra
        #csrwr   $t1, LOONGARCH_CSR_TLBELO0

        #ld.w    $t1, $t0, 0x4
        #srli.w  $ra, $t1, 0xc
        #slli.w  $ra, $ra, 0x8
        #andi    $t1, $t1, 0xff
        #add.w   $t1, $t1, $ra
        #csrwr   $t1, LOONGARCH_CSR_TLBELO1

        #tlbfill
        #csrrd   $t0, LOONGARCH_CSR_KS0
        #csrrd   $t1, LOONGARCH_CSR_KS1
        #csrrd   $ra, EXCEPTION_KS2
        ertn

