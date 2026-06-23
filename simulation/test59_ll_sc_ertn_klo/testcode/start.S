# Test: KLO prevents ERTN from clearing LLbit.
# ll.w -> set KLO -> syscall -> ERTN (KLO auto-cleared) -> sc.w should succeed.
# After sc.w, read LLBCTL to verify:
#   - KLO is 0 (auto-cleared)
#   - ROLLB is 0 (cleared by successful sc.w)
# On success: r5 = 0x5a, on failure: r5 = 0.

.data
var:    .word   0x35            # initial value, should become 0x36

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
    ll.w    $s1, $s0, 0         # s1 = *var (load-linked, LLbit = 1)
    addi.w  $s2, $s1, 1         # s2 = s1 + 1 (new value)

    # 4) Set KLO bit (bit 2) in LLBCTL (CSR 0x60)
    li.w    $t0, 0x4            # KLO bit mask (1 << 2)
    csrwr   $t0, 0x60           # LLBCTL = KLO (other bits 0)

    syscall 8                   # trigger syscall exception

    sc.w    $s2, $s0, 0         # conditional store; should SUCCEED (s2 = 1)

    # 5) Check sc.w result
    beqz    $s2, fail           # if sc.w returned 0, test fails

    # 6) Verify memory was modified to 0x36
    ld.w    $s3, $s0, 0
    li.w    $s4, 0x36
    bne     $s3, $s4, fail

    # 7) Read LLBCTL to verify KLO auto-cleared and ROLLB cleared by sc.w
    csrrd   $t0, 0x60           # t0 = LLBCTL

    # Extract KLO (bit2)
    srli.w  $t1, $t0, 2         # t1 = t0 >> 2  (was srl, fixed)
    andi    $t1, $t1, 0x1       # t1 = KLO
    bnez    $t1, fail           # KLO should be 0 (auto-cleared)

    # Extract ROLLB (bit0)
    andi    $t2, $t0, 0x1       # t2 = ROLLB
    bnez    $t2, fail           # ROLLB should be 0 (cleared by successful sc.w)

    # 8) Success
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
# Skips the syscall instruction and returns via ERTN.
# With KLO=1, ERTN does NOT clear LLbit; KLO itself is auto-cleared.
# -------------------------------------------------------------------
fault_handler:
    # (Optional) Check that this is a syscall exception (code 0xb)
    csrrd   $r11, 0x5           # ESTAT
    li.w    $r6,  0x000b0000    # syscall exception code
    bne     $r11, $r6, not_syscall

    # Skip the syscall instruction (4 bytes) by advancing ERA
    csrrd   $r11, 0x6           # ERA (exception return address)
    addi.w  $r11, $r11, 4       # skip 4-byte syscall
    csrwr   $r11, 0x6           # update ERA

    ertn                        # return; KLO=1 so LLbit is NOT cleared

not_syscall:
    b       not_syscall
