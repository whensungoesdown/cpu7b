add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_req

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_bf
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_w

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/axi_rdata
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/inst_rdata_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/dec/fdp_dec_inst_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/ifu_exu_valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_exu_valid_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/ifu_fdp_valid_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_kill_vld_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_kill_vld_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_f

add wave -divider

add wave -position end  result:/top_tb/u_top/ram_raddr
add wave -position end  result:/top_tb/u_top/ram_rdata
add wave -position end  result:/top_tb/u_top/ram_ren
add wave -position end  result:/top_tb/u_top/ram_waddr
add wave -position end  result:/top_tb/u_top/ram_wdata
add wave -position end  result:/top_tb/u_top/ram_wen

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/axi_ar_ready
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_valid
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/arb_rd_val
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/arb_rd_addr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/inst_rdata_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/inst_valid_f

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/inst_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/exu_ifu_stall_req

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/biu_busy
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_ack
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/inst_valid_f

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/ext_biu_ar_ready
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_addr
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_burst
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_cache
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_id
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_len
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_lock
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_prot
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_size
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_ext_ar_valid

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_lsu_data
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/biu_lsu_data_valid

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/ifu_biu_rd_addr
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/ifu_biu_rd_req
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/lsu_biu_rd_addr
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/lsu_biu_rd_req
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/lsu_biu_wr_addr
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/lsu_biu_wr_data
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/lsu_biu_wr_last
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/lsu_biu_wr_strb

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/u_read_arbiter/arb_rd_val
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/u_read_arbiter/biu_ifu_rd_ack
add wave -position end  result:/top_tb/u_top/u_cpu/u_biu/u_read_arbiter/biu_lsu_rd_ack

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/biu_lsu_rd_ack
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/lsu_biu_rd_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/biu_rd_busy
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/valid_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/lsu_ale_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/lsu/addr

add wave -divider

add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARADDR
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARBURST
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARID
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARLEN
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARLOCK
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARQOS
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARREADY
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARREADY_S0
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARREADY_S1
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARREADY_S2
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARREADY_SD
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARREGION
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARSIZE
add wave -position end  result:/top_tb/u_top/u_amba_axi_m2s3/M0_ARVALID

