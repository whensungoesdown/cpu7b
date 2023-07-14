add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -position end  result:/top_tb/u_top/ram_raddr
add wave -position end  result:/top_tb/u_top/ram_rdata
add wave -position end  result:/top_tb/u_top/ram_ren
add wave -position end  result:/top_tb/u_top/ram_waddr
add wave -position end  result:/top_tb/u_top/ram_wdata
add wave -position end  result:/top_tb/u_top/ram_wen


add wave -position end  result:/top_tb/u_top/cpu_araddr
add wave -position end  result:/top_tb/u_top/cpu_arvalid
add wave -position end  result:/top_tb/u_top/cpu_arready

add wave -position end  result:/top_tb/u_top/cpu_rdata
add wave -position end  result:/top_tb/u_top/cpu_rvalid
add wave -position end  result:/top_tb/u_top/cpu_rready

add wave -position end  result:/top_tb/u_top/u_cpu/inst_req
add wave -position end  result:/top_tb/u_top/u_cpu/inst_addr
add wave -position end  result:/top_tb/u_top/u_cpu/inst_rdata_f
add wave -position end  result:/top_tb/u_top/u_cpu/inst_valid_f

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_addr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pcinc_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/br_target
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/exu_ifu_eentry
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/exu_ifu_era
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pcbf_btwn_mux
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_init_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_old_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_pcinc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_brpc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_usemux1_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_excpc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_ertnpc_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/br_taken
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/m_arready
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/busy
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/busy_din
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/busy_en
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/aw_busy
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/aw_enter
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/b_retire
add wave -position end  result:/top_tb/u_top/u_axi_sram_bridge/aresetn

add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/arvalid_nxt
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/araddr_nxt
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_addr
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/inst_addr

add wave -position end  result:/top_tb/u_top/ram/rdaddress
add wave -position end  result:/top_tb/u_top/ram/rden
add wave -position end  result:/top_tb/u_top/ram/q

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/registers/regs


add wave -position end  result:/top_tb/u_top/u_cpu/cpu/inst_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/data_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/data_addr
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/ifu_fetch
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_read
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/data_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/data_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/lsu_ale_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/am_addr_align_exc
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/align_check
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/cm_addr_align_exc
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/addr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/base
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/offset
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byp_rs1_data_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/alu_a_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/rd_data_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_irf_rd_data_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_byp_rs1_mux_sel_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_byp_rs1_mux_sel_rf
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_byp_rs1_mux_sel_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/use_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/use_rf
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/use_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/rd_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/rd_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/rs_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/rf_target_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_rd_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_finish_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/data_data_ok_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/lsu_ale_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/valid_m
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rready
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rvalid
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_read
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_req
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_dispatch_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_finish_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/exu_ifu_stall_req


add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_pcbf_sel_old_bf_l
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_valid_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/br_taken
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/exu_ifu_ertn_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/exu_ifu_stall_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_stall_req_next
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/csr_stall_req_next
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_dispatch_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_stall_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_finish_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/lsu_finish_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/data_data_ok_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/lsu_ale_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/valid_m
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_read
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_read_m
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write_m
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rready
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rvalid
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rvalid
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_req
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write


add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/ifu_fetch
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_read
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/ifu_fetch_f
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_read_m
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/lsu_write_m
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rvalid
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/rready
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_req

add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_data_ok_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_rdata_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_finish_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/exu_ifu_except
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/lsu_ecl_ale_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_csr_illinst_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_rdata_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/fdp_dec_inst
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/ifu_fetch
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/ifu_fetch_f


add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_req
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_wr
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/wdata
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/wdata_nxt
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_wdata

add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/awready
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/awvalid
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/awaddr

add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/data_addr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/data_addr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/addr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/base
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/offset
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_lsu_base_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byp_rs1_data_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_byp_rs1_mux_sel_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_byp_rs1_mux_sel_rf
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/ecl_byp_rs1_mux_sel_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/rs1_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/rd_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/rd_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/wen_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/wen_w
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/rs_is_nonzero
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/bypass
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/use_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ecl/byplog_rs1/use_w


