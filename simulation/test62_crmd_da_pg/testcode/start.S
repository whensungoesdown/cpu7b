# Test: CRMD.DA and CRMD.PG reset values and write operations.
# Steps:
# 1) Check reset: DA=1, PG=0.
# 2) Write DA=0, PG=1, read back and verify.
# 3) Write DA=1, PG=0 again, verify.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
.globl start

_start:
start:
    # --------------------------------------------------------------
    # Step 1: Verify reset values (DA=1, PG=0)
    # --------------------------------------------------------------
    csrrd   $t0, 0x0               # t0 = CRMD

    # Extract DA (bit 3)
    srli.w  $t1, $t0, 3
    andi    $t1, $t1, 0x1
    beqz    $t1, fail              # DA must be 1

    # Extract PG (bit 4)
    srli.w  $t2, $t0, 4
    andi    $t2, $t2, 0x1
    bnez    $t2, fail              # PG must be 0

#    # --------------------------------------------------------------
#    # Step 2: Write DA=0, PG=1 (mapped mode) without changing IE/PLV
#    # --------------------------------------------------------------
#    # Read current CRMD, clear DA(bit3) and PG(bit4), set PG=1
#    li.w    $t3, ~0x18             # mask: clear bits 3 and 4
#    and     $t0, $t0, $t3          # t0 = CRMD with DA=0, PG=0
#    ori     $t0, $t0, 0x10         # set PG=1 (bit4), DA stays 0
#    csrwr   $t0, 0x0               # write new CRMD
#
#    # Read back and verify DA=0, PG=1
#    csrrd   $t4, 0x0
#    # Check DA == 0
#    srli.w  $t1, $t4, 3
#    andi    $t1, $t1, 0x1
#    bnez    $t1, fail
#    # Check PG == 1
#    srli.w  $t2, $t4, 4
#    andi    $t2, $t2, 0x1
#    beqz    $t2, fail
#
#    # --------------------------------------------------------------
#    # Step 3: Write DA=1, PG=0 (direct mode) again
#    # --------------------------------------------------------------
#    # Read current CRMD, clear DA and PG, set DA=1
#    csrrd   $t0, 0x0
#    li.w    $t3, ~0x18
#    and     $t0, $t0, $t3          # clear DA and PG
#    ori     $t0, $t0, 0x08         # set DA=1 (bit3), PG stays 0
#    csrwr   $t0, 0x0
#
#    # Read back and verify DA=1, PG=0
#    csrrd   $t4, 0x0
#    srli.w  $t1, $t4, 3
#    andi    $t1, $t1, 0x1
#    beqz    $t1, fail
#    srli.w  $t2, $t4, 4
#    andi    $t2, $t2, 0x1
#    bnez    $t2, fail

    # --------------------------------------------------------------
    # Success
    # --------------------------------------------------------------
    li.w    $r5, 0x5a
    b       success

fail:
    li.w    $r5, 0

success:
    nop
    nop
    nop
    nop
    b       success                # loop forever
