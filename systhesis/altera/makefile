###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

PROJECT = soc_top
SOURCE_FILES =  ../../rtl/alu.v \
                ../../rtl/atom_alu.v \
                ../../rtl/branch.v \
                ../../rtl/cache_interface.v \
                ../../rtl/cache.vh \
                ../../rtl/common.vh \
                ../../rtl/core_top.v \
                ../../rtl/cpu7_csr_byplog.v \
                ../../rtl/cpu7_csr.v \
                ../../rtl/cpu7_exu_eclbyplog_rs1.v \
                ../../rtl/cpu7_exu_eclbyplog.v \
                ../../rtl/cpu7_exu_ecl.v \
                ../../rtl/cpu7_exu.v \
                ../../rtl/cpu7_ifu_dec.v \
                ../../rtl/cpu7_ifu_fdp.v \
                ../../rtl/cpu7_ifu_imd.v \
                ../../rtl/cpu7_ifu_incr30.v \
                ../../rtl/cpu7_ifu.v \
                ../../rtl/cpu7_lsu.v \
                ../../rtl/cpu7.v \
                ../../rtl/dcache.v \
                ../../rtl/decoded.vh \
                ../../rtl/decoder.v \
                ../../rtl/frontend_rams.vh \
                ../../rtl/icache.v \
                ../../rtl/lru_unit.v \
                ../../rtl/mul32x32.v \
                ../../rtl/mul64x64.v \
                ../../rtl/mycpu_top.v \
                ../../rtl/prefetch_d.v \
                ../../rtl/ram_wrapper.v \
                ../../rtl/reg_file.v \
                ../../rtl/swrvr_clib.v \
                ../../rtl/swrvr_dlib.v \
                ../../rtl/tlb_defines.vh \
		../../chip/soc_demo/sim/config.vh \
		../../chip/soc_demo/sim/soc_top.v


SOURCE_FILES_PARAMETER = $(addprefix --source=, $(SOURCE_FILES))
ASSIGNMENT_FILES = soc_top.qpf soc_top.qsf 


FAMILY = "Cyclone IV E"
PART = EP4CE6E22C8
BOARD = c4e6e10pins
###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt 

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

# Quartus 19.1 Prime lite doesn't support CycloneII
# To compile, put CycloneIV here
#MAP_ARGS = --family=CycloneII $(SOURCE_FILES_PARAMETER)
#FIT_ARGS = --part=EP2C5T144C8i
MAP_ARGS = --family=$(FAMILY) $(SOURCE_FILES_PARAMETER)
FIT_ARGS = --part=$(PART)
ASM_ARGS =
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES) 
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT) 

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT)
	-cat $(BOARD) >> $(PROJECT).qsf

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg
