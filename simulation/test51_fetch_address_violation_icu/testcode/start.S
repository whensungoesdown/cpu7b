.text
.globl  _start
.globl  start
_start:
start:
    # 设置异常入口 EENTRY (CSR 0xc) 指向 fault_handler
    lu12i.w $r6, 0x1c000
    addi.w  $r6, $r6, 0x30          # fault_handler 地址
    csrwr   $r6, 0xc                # EENTRY = fault_handler

    # Trun on icache
    addi.w   $r6, $r0, 0x1           # r6 = 0x1
    csrwr    $r6, 0x101              # 

    # 跳转到未映射地址 0x70000000
    lu12i.w $r8, 0x70000            # r8 = 0x70000000
    jirl    $zero, $r8, 0           # 触发指令地址错异常

loop:
    nop
    nop
    nop
    nop
    b       loop

# -------------------------------------------------------------------
# 异常处理函数 (单出口)
fault_handler:
    # 默认失败标志
    addi.w  $r5, $zero, 0x0

    # 检查 ExcCode = 8
    csrrd   $r11, 0x5
    srli.w  $r11, $r11, 16
    andi    $r11, $r11, 0x3f
    addi.w  $r12, $zero, 0x8
    bne     $r11, $r12, check_done

    # 检查 BADV = 0x70000000
    csrrd   $r13, 0x7
    lu12i.w $r14, 0x70000
    bne     $r13, $r14, check_done

    # 全部正确：设置成功标志
    addi.w  $r5, $zero, 0x5a

check_done:
    # 统一出口：执行几条 nop 供 testbench 检测 r5，然后 ertn
    nop
    nop
    nop
    ertn
