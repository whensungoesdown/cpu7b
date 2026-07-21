# Test: Simple addi instructions then enable paging (PG=1, DA=0)
# Steps:
# 1) Initialize EENTRY and TLBRENTRY to exception handlers.
# 2) Execute 5 addi instructions on $t0.
# 3) Read CRMD, clear DA and PG, set PG=1, keep IE/PLV unchanged.
# 4) Write back to CRMD.
# 5) Verify by reading back and checking PG=1, DA=0.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:

    /* We might not get launched at the address the kernel is linked to,
       so we jump there. */
    la.abs  $t0, 0f
    jr      $t0
0:

#    # ----- Initialize exception entry points -----
#    # Set EENTRY (CSR 0x0C) to except_handler
#    la      $t0, except_handler
#    csrwr   $t0, 0x0C
#
#    # Set TLBRENTRY (CSR 0x88) to tlbr_handler
#    la      $t0, tlbr_handler
#    csrwr   $t0, 0x88

    # ----- 5 addi instructions -----
    addi.w  $t0, $r0, 1
    addi.w  $t0, $r0, 2
    addi.w  $t0, $r0, 3
    addi.w  $t0, $r0, 4
    addi.w  $t0, $r0, 5


    # ----- csrwr -> DMW0 = 0xA0000011 -----
    li.w    $t0, 0xA0000011
    csrwr   $t0, 0x180


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
    nop
    ertn
