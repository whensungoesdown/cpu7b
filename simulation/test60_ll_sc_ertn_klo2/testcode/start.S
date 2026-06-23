# Test: KLO auto-clears after ERTN.
# Phase 1: Set KLO=1, do ll.w + syscall + sc.w -> sc.w succeeds (KLO protects LLbit).
# Phase 2: Do ll.w + syscall + sc.w again (without setting KLO) -> sc.w fails (KLO already 0).
# On success: r5 = 0x5a, on failure: r5 = 0.

.data
var:    .word   0x35            # initial value

.text
.globl  _start
.globl  start

_start:
start:
    # Set exception entry
    la      $r6, fault_handler
    csrwr   $r6, 0xc            # EENTRY

    la      $s0, var            # s0 = address of var

    # ============ Phase 1: with KLO ============
    # Set KLO bit (bit 2) in LLBCTL (CSR 0x60)
    li.w    $t0, 0x4            # KLO mask
    csrwr   $t0, 0x60           # LLBCTL = KLO

    ll.w    $s1, $s0, 0         # s1 = *var (LLbit = 1)
    addi.w  $s2, $s1, 1         # s2 = new value
    syscall 8                   # trigger exception
    sc.w    $s2, $s0, 0         # should succeed (s2 = 1)

    beqz    $s2, fail           # if sc.w returned 0, phase 1 failed

    # Check memory updated to 0x36
    ld.w    $s3, $s0, 0
    li.w    $s4, 0x36
    bne     $s3, $s4, fail

    # Phase 1 passed. Now verify KLO is auto-cleared.
    # (We can read LLBCTL to check KLO=0, but we'll use functional test.)

    # ============ Phase 2: without KLO ============
    # Do not set KLO this time. KLO should already be 0.

    # Reset var to 0x35 for a fresh start (optional)
    li.w    $s3, 0x35
    st.w    $s3, $s0, 0

phase2_retry:
    ll.w    $s1, $s0, 0         # s1 = *var (LLbit = 1)
    addi.w  $s2, $s1, 1         # s2 = new value
    syscall 8                   # trigger exception
    sc.w    $s2, $s0, 0         # should FAIL (s2 = 0) because KLO=0

    bnez    $s2, fail           # if sc.w returned 1, phase 2 failed

    # Verify memory was NOT modified (still 0x35)
    ld.w    $s3, $s0, 0
    li.w    $s4, 0x35
    bne     $s3, $s4, fail

    # All tests passed
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
    nop

# -------------------------------------------------------------------
# Exception handler for syscall
# Skips syscall and returns via ERTN.
# -------------------------------------------------------------------
fault_handler:
    # Check for syscall exception (code 0xb)
    csrrd   $r11, 0x5           # ESTAT
    li.w    $r6,  0x000b0000
    bne     $r11, $r6, not_syscall

    # Skip the syscall instruction (4 bytes)
    csrrd   $r11, 0x6           # ERA
    addi.w  $r11, $r11, 4
    csrwr   $r11, 0x6

    ertn                        # ERTN: if KLO=1, LLbit preserved; if KLO=0, LLbit cleared

not_syscall:
    b       not_syscall
