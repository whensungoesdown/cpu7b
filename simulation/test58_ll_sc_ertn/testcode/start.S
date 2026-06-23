# Test: ll.w + syscall + sc.w sequence.
# The syscall causes an exception; ERTN in the handler clears LLbit.
# Then sc.w should fail (return 0) and not write memory.
# On success: r5 = 0x5a, on failure: r5 = 0.

.data
var:    .word   0x35            # initial value, should remain unchanged

.text
.globl  _start
.globl  start

_start:
start:
    # 1) Set exception entry point (EENTRY) to fault_handler
    la      $r6, fault_handler
    csrwr   $r6, 0xc            # EENTRY

    # 2) Load address of var into s0
    la      $s0, var

    # 3) LL/SC sequence with syscall in between
retry:                          # (not really a retry, just label)
    ll.w    $s1, $s0, 0         # s1 = *var (load-linked)
    addi.w  $s2, $s1, 1         # s2 = s1 + 1 (new value)
    syscall 8                   # trigger a syscall exception
    sc.w    $s2, $s0, 0         # conditional store; should fail because LLbit cleared

    # 4) Check sc.w result
    bnez    $s2, fail           # if sc.w returned 1 (success), test fails

    # 5) Verify memory was NOT modified (should still be 0x35)
    ld.w    $s3, $s0, 0
    li.w    $s4, 0x35
    bne     $s3, $s4, fail

    # 6) Success
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
# It skips the syscall instruction and returns via ERTN.
# ERTN clears the LLbit, causing the subsequent sc.w to fail.
# -------------------------------------------------------------------
fault_handler:
    # (Optional) Check that this is a syscall exception.
    # LoongArch ESTAT bit for syscall is 0x000b0000 (exception code 0xb).
    csrrd   $r11, 0x5           # ESTAT
    li.w    $r6,  0x000b0000    # syscall exception code
    bne     $r11, $r6, not_syscall

    # Skip the syscall instruction (4 bytes) by advancing ERA
    csrrd   $r11, 0x6           # ERA (exception return address)
    addi.w  $r11, $r11, 4       # skip 4-byte syscall
    csrwr   $r11, 0x6           # update ERA

    ertn                        # return; this clears LLbit

not_syscall:
    # If not syscall, just loop forever (should not happen)
    b       not_syscall
