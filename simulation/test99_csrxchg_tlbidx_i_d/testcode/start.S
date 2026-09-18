// Test program for csrxchg on TLBIDX (CSR 0x10) bit 16
// Initial TLBIDX value: PS field = all ones (0x3f), other bits zero.
// Steps:
//   1. Write 0x3f to TLBIDX.
//   2. Set bit 16 to 1 using csrxchg (mask 0x00010000).
//   3. Read back and verify it equals (0x3f | 0x00010000).
//   4. Clear bit 16 to restore original value.
//   5. Read back and verify it equals 0x3f.
// Returns: $r5 = 0x5a on success, 0 on failure.

.section .text
.globl _start
_start:

    // ----- Step 1: Write initial value 0x3 to TLBIDX -----
    li.w    $t0, 0x3                 // Initial value
    csrwr   $t0, 0x10                // TLBIDX = 0x3

    // ----- Step 2: Set bit 16 to 1 using csrxchg -----
    li.w    $t1, 0x00010000          // Value to write (set bit16)
    li.w    $t2, 0x00010000          // Mask: only bit16
    csrxchg $t1, $t2, 0x10           // CSR[0x10] = (CSR & ~mask) | (t1 & mask)
                                     // t1 gets old value (0x3f)
    // Now TLBIDX should be 0x3 | 0x00010000 = 0x00010003

    // ----- Step 3: Read back and verify -----
    csrrd   $t8, 0x10                // t8 = current TLBIDX
    li.w    $t0, 0x00010003          // Expected value after setting bit16
    bne     $t8, $t0, fail           // If not equal, fail

    // ----- Step 4: Clear bit 16 (restore original) -----
    li.w    $t4, 0x00000000          // Value to write (clear bit16)
    li.w    $t2, 0x00010000          // Same mask
    csrxchg $t4, $t2, 0x10           // t4 gets old value (0x0001003f)
                                     // TLBIDX now should be 0x3f again

    // ----- Step 5: Final verification -----
    csrrd   $t8, 0x10                // t8 = restored TLBIDX
    li.w    $t0, 0x03                // Expected final value
    bne     $t8, $t0, fail           // If not equal, fail

    // ----- Success -----
    li.w    $r5, 0x5a                // Return success code
    b       success

fail:
    li.w    $r5, 0                   // Return failure code

success:
    nop
    nop
    nop
    nop
    nop
    nop
    b       success                  // Infinite loop for inspection
