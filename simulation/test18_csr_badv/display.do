add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider


add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_bf
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_w


add wave -divider

add wave -position end  result:/top_tb/u_top/ram_raddr
add wave -position end  result:/top_tb/u_top/ram_rdata
add wave -position end  result:/top_tb/u_top/ram_ren
add wave -position end  result:/top_tb/u_top/ram_waddr
add wave -position end  result:/top_tb/u_top/ram_wdata
add wave -position end  result:/top_tb/u_top/ram_wen

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_valid_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_icu_addr_ic1
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_icu_cancel
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_icu_req_ic1
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/icu_ifu_ack_ic1
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/exu_ifu_stall_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/br_taken
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/biu_busy
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/icu_ifu_data_ic2
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/icu_ifu_data_valid_ic2

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/u_iq/instr_2nd
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/iq_not_empty
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/u_iq/iq_not_empty_q
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/u_iq/inst_rdata_q
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/u_iq/flush_iq

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/csr_stall_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/csr_stall_req_next
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ifu_exu_csr_wen_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/csr_wen_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/ifu_exu_csr_valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_exu_valid_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_exu_valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/fdp_dec_inst_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/csr/csr_eentry
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/csr_wen_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/csr_wen_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/csr_valid_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/csr_valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/none_dispatch_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/ifu_exu_csr_raddr_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/ifu_exu_csr_rdwen_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/ifu_exu_csr_valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/ifu_exu_csr_waddr_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/ifu_exu_csr_wen_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/ifu_exu_csr_xchg_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/csr_byp_rdata_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/byp_csr_wdata_m

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/wen_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/wen_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/op_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_brpc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_ertnpc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_excpc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_init_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_old_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_pcinc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_usemux1_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/exu_ifu_except
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/exception_all_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ifu_exu_exception_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/exception_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/exception_d2e_in
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/exception_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/fdp_dec_exception_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/exccode_d

add wave -divider
