#!/bin/bash
./clean.sh > /dev/null

cd testcode
make
cd ..

vlib work
vmap work work

vlib altera_mf_ver
vmap altera_mf_ver altera_mf_ver

#vlog -work altera_mf_ver -f soc1.f
#vlog +incdir+../../rtl -f files.f
vlog +incdir+../../rtl +incdir+../../rtl/c7bbiu -f ../../flist/sim.files ../../tb/test11_csrrd_top_tb.v

#vlog -reportprogress 300 -work altera_mf_ver ~/intelFPGA_lite/19.1/quartus/eda/sim_lib/altera_mf.v -f soc1.f

vsim -c -do sim.do top_tb -wlf result.wlf
