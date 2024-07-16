add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_req
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/inst_busy

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_bf
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_f
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_d
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_e
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_m
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/fdp/pc_w

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/csr/timer_intr
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/exu_ifu_except
add wave -position end  result:/top_tb/u_top/u_cpu/cpu/exu/csr/era_reg/q


add wave -divider

add wave -position end  result:/top_tb/u_top/ram_raddr
add wave -position end  result:/top_tb/u_top/ram_rdata
add wave -position end  result:/top_tb/u_top/ram_ren
add wave -position end  result:/top_tb/u_top/ram_waddr
add wave -position end  result:/top_tb/u_top/ram_wdata
add wave -position end  result:/top_tb/u_top/ram_wen

add wave -divider

add wave -position end  result:/top_tb/u_top/u_cpu/cpu/ifu/inst_req
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/araddr
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/arvalid
add wave -position end  result:/top_tb/u_top/u_cpu/u_axi_interface/arready

add wave -divider
