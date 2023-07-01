# list all signals in decimal format
add list -decimal *

#change radix to symbolic
radix -symbolic

#add wave *
#add wave u_top.clk
#add wave u_top.resetn

add wave -position end  sim:/top_tb/clk
add wave -position end  sim:/top_tb/resetn
#add wave -position end  sim:/top_tb/u_top/fake_cpu/araddr

run 500ns

# read in stimulus
#do stim.do

# output results
write list test.lst

# quit the simulation
quit -f
