# Test PGD (CSR 0x1B) selection based on BADV[31]
# PGDL (0x19) and PGDH (0x1A) are set to different known values.
# When BADV[31]=0, PGD should equal PGDL.
# When BADV[31]=1, PGD should equal PGDH.
# On success: r5 = 0x5a, on failure: r5 = 0.

.text
.globl _start
_start:
    # --------------------------------------------------------------
    # Step 1: Set PGDL = 0x12345000 (BASE=0x12345)
    # --------------------------------------------------------------
    li.w    $t0, 0x12345000
    csrwr   $t0, 0x19

    # --------------------------------------------------------------
    # Step 2: Set PGDH = 0xABCDE000 (BASE=0xABCDE)
    # --------------------------------------------------------------
    li.w    $t0, 0xABCDE000
    csrwr   $t0, 0x1A

    # --------------------------------------------------------------
    # Test Case 1: BADV[31] = 0  (address < 0x80000000)
    # --------------------------------------------------------------
    li.w    $t0, 0x12345678          # BADV with MSB = 0
    csrwr   $t0, 0x7                 # write BADV

    csrrd   $t1, 0x1B                # read PGD
    csrrd   $t2, 0x19                # read PGDL
    bne     $t1, $t2, fail           # PGD must equal PGDL

    # --------------------------------------------------------------
    # Test Case 2: BADV[31] = 1  (address >= 0x80000000)
    # --------------------------------------------------------------
    li.w    $t0, 0x87654321          # BADV with MSB = 1
    csrwr   $t0, 0x7

    csrrd   $t1, 0x1B                # read PGD
    csrrd   $t2, 0x1A                # read PGDH
    bne     $t1, $t2, fail           # PGD must equal PGDH

    # --------------------------------------------------------------
    # All tests passed
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
    b       success
