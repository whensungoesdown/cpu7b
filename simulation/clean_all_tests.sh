#!/bin/bash
echo clean tests
echo

cd test0
echo "test0"
./clean.sh
echo ""
cd ..


cd test1_ld.w
echo "test1_ld.w"
./clean.sh
echo ""
cd ..


cd test1_1_ld.w
echo "test1_1_ld.w"
./clean.sh
echo ""
cd ..




cd test3_st.w
echo "test3_st.w"
./clean.sh
echo ""
cd ..


cd test3_1_st.w
echo "test3_1_st.w"
./clean.sh
echo ""
cd ..


cd test4_beq
echo "test4_beq"
./clean.sh
echo ""
cd ..


cd test5_jirl
echo "test5_jirl"
./clean.sh
echo ""
cd ..


cd test6_beq_testbyp
echo "test6_beq_testbyp"
./clean.sh
echo ""
cd ..






cd test8_mulw
echo "test8_mulw"
./clean.sh
echo ""
cd ..


cd test9_mulhwu
echo "test9_mulhwu"
./clean.sh
echo ""
cd ..


cd test10_mulhw
echo "test10_mulhw"
./clean.sh
echo ""
cd ..


cd test11_csrrd
echo "test11_csrrd"
./clean.sh
echo ""
cd ..


cd test12_csrwr
echo "test12_csrwr"
./clean.sh
echo ""
cd ..


cd test13_csrxchg
echo "test13_csrxchg"
./clean.sh
echo ""
cd ..


cd test14_csr_crmd
echo "test14_csr_crmd"
./clean.sh
echo ""
cd ..


cd test15_csr_prmd
echo "test15_csr_prmd"
./clean.sh
echo ""
cd ..


cd test16_ale_exception
echo "test16_ale_exception"
./clean.sh
echo ""
cd ..


cd test17_exception_crmd_prmd
echo "test17_exception_crmd_prmd"
./clean.sh
echo ""
cd ..


cd test18_csr_badv
echo "test18_csr_badv"
./clean.sh
echo ""
cd ..


cd test19_csr_tcfg
echo "test19_csr_tcfg"
./clean.sh
echo ""
cd ..


cd test20_csr_tcfg_periodic
echo "test20_csr_tcfg_periodic"
./clean.sh
echo ""
cd ..


cd test21_timer_intr_right_after_branch
echo "test21_timer_intr_right_after_branch"
./clean.sh
echo ""
cd ..


cd test22_timer_intr_on_pipeline_bubble
echo "test22_timer_intr_on_pipeline_bubble"
./clean.sh
echo ""
cd ..


cd test23_lsu_stall_ifu_at_e
echo "test23_lsu_stall_ifu_at_e"
./clean.sh
echo ""
cd ..


cd test24_beq_ld.w
echo "test24_beq_ld.w"
./clean.sh
echo ""
cd ..


cd test25_lsu_stall
echo "test25_lsu_stall"
./clean.sh
echo ""
cd ..


cd test26_illinstr_exception
echo "test26_illinstr_exception"
./clean.sh
echo ""
cd ..


cd test27_estat
echo "test27_estat"
./clean.sh
echo ""
cd ..


cd test28_ld.b.bu.h.hu
echo "test28_ld.b.bu.h.hu"
./clean.sh
echo ""
cd ..


cd test29_st.b.h 
echo "test29_st.b.h"
./clean.sh
echo ""
cd ..


cd test30_ext_intr
echo "test30_ext_intr"
./clean.sh
echo ""
cd ..


cd test31_andi
echo "test31_andi"
./clean.sh
echo ""
cd ..


cd test32_ext_intr_during_ld
echo "test32_ext_intr_during_ld"
./clean.sh
echo ""
cd ..


cd test33_icache_smoke
echo "test33_icache_smoke"
./clean.sh
echo ""
cd ..


cd test34_ext_intr_on_branch
echo "test34_ext_intr_on_branch"
./clean.sh
echo ""
cd ..


cd test35_ext_intr_random
echo "test35_ext_intr_random"
./clean.sh
echo ""
cd ..


cd test36_ext_intr_on_alu_inst_random
echo "test36_ext_intr_on_alu_inst_random"
./clean.sh
echo ""
cd ..


cd test37_ext_intr_on_lsu_inst_random
echo "test37_ext_intr_on_lsu_inst_random"
./clean.sh
echo ""
cd ..


cd test38_ext_intr_on_2lsu_inst_random
echo "test38_ext_intr_on_2lsu_inst_random"
./clean.sh
echo ""
cd ..


cd test39_ic_en
echo "test39_ic_en"
./clean.sh
echo ""
cd ..


cd test40_alsl.w
echo "test40_alsl.w"
./clean.sh
echo ""
cd ..


cd test41_div.w
echo "test41_div.w"
./clean.sh
echo ""
cd ..


cd test42_mod.w
echo "test42_mod.w"
./clean.sh
echo ""
cd ..


cd test43_div.wu
echo "test43_div.wu"
./clean.sh
echo ""
cd ..


cd test44_mod.wu
echo "test44_mod.wu"
./clean.sh
echo ""
cd ..


cd test45_break_exception
echo "test45_break_exception"
./clean.sh
echo ""
cd ..


cd test46_syscall_exception
echo "test46_syscall_exception"
./clean.sh
echo ""
cd ..


cd test47_timer_intr_pending
echo "test47_timer_intr_pending"
./clean.sh
echo ""
cd ..


cd test48_csr_save0_3
echo "test48_csr_save0_3"
./clean.sh
echo ""
cd ..


cd test49_rdtime
echo "test49_rdtime"
./clean.sh
echo ""
cd ..


cd test50_fetch_address_violation
echo "test50_fetch_address_violation"
./clean.sh
echo ""
cd ..


cd test51_fetch_address_violation_icu
echo "test51_fetch_address_violation_icu"
./clean.sh
echo ""
cd ..


cd test52_ld_access_violation
echo "test52_ld_access_violation"
./clean.sh
echo ""
cd ..


cd test53_st_access_violation
echo "test53_st_access_violation"
./clean.sh
echo ""
cd ..


cd test54_dbar
echo "test54_dbar"
./clean.sh
echo ""
cd ..


cd test55_ibar
echo "test55_ibar"
./clean.sh
echo ""
cd ..


cd test56_ll_sc
echo "test56_ll_sc"
./clean.sh
echo ""
cd ..


cd test57_sc
echo "test57_sc"
./clean.sh
echo ""
cd ..


cd test58_ll_sc_ertn
echo "test58_ll_sc_ertn"
./clean.sh
echo ""
cd ..


cd test59_ll_sc_ertn_klo
echo "test59_ll_sc_ertn_klo"
./clean.sh
echo ""
cd ..


cd test60_ll_sc_ertn_klo2
echo "test60_ll_sc_ertn_klo2"
./clean.sh
echo ""
cd ..


cd test61_ll_sc_rollb_wcllb
echo "test61_ll_sc_rollb_wcllb"
./clean.sh
echo ""
cd ..


cd test62_crmd_da_pg
echo "test62_crmd_da_pg"
./clean.sh
echo ""
cd ..


cd test63_csr_dmw
echo "test63_csr_dmw"
./clean.sh
echo ""
cd ..


cd test64_pg_mode_dmw
echo "test64_pg_mode_dmw"
./clean.sh
echo ""
cd ..


cd test65_csr_tlbidx
echo "test65_csr_tlbidx"
./clean.sh
echo ""
cd ..


cd test66_csr_tlbehi
echo "test66_csr_tlbehi"
./clean.sh
echo ""
cd ..


cd test67_csr_tlbelo
echo "test67_csr_tlbelo"
./clean.sh
echo ""
cd ..


cd test68_csr_pgdhl
echo "test68_csr_pgdhl"
./clean.sh
echo ""
cd ..


cd test69_csr_pgd
echo "test69_csr_pgd"
./clean.sh
echo ""
cd ..


cd test70_pg_mode_tlbfill
echo "test70_pg_mode_tlbfill"
./clean.sh
echo ""
cd ..


cd test71_tlbwr_tlbrd_itlb
echo "test71_tlbwr_tlbrd_itlb"
./clean.sh
echo ""
cd ..


cd test72_tlbwr_tlbrd_dtlb
echo "test72_tlbwr_tlbrd_dtlb"
./clean.sh
echo ""
cd ..


cd test73_csr_asid
echo "test73_csr_asid"
./clean.sh
echo ""
cd ..


cd test74_tlbsrch_itlb
echo "test74_tlbsrch_itlb"
./clean.sh
echo ""
cd ..


cd test75_tlbsrch_dtlb
echo "test75_tlbsrch_dtlb"
./clean.sh
echo ""
cd ..


cd test76_pg_mode_tlbfill_dtlb
echo "test76_pg_mode_tlbfill_dtlb"
./clean.sh
echo ""
cd ..


cd test77_sltui
echo "test77_sltui"
./clean.sh
echo ""
cd ..


cd test78_invtlb_op0_itlb
echo "test78_invtlb_op0_itlb"
./clean.sh
echo ""
cd ..


cd test79_invtlb_op0_dtlb
echo "test79_invtlb_op0_dtlb"
./clean.sh
echo ""
cd ..


cd test80_invtlb_op1_itlb
echo "test80_invtlb_op1_itlb"
./clean.sh
echo ""
cd ..


cd test81_invtlb_op1_dtlb
echo "test81_invtlb_op1_dtlb"
./clean.sh
echo ""
cd ..


cd test82_invtlb_op2_itlb
echo "test82_invtlb_op2_itlb"
./clean.sh
echo ""
cd ..


cd test83_invtlb_op2_dtlb
echo "test83_invtlb_op2_dtlb"
./clean.sh
echo ""
cd ..


cd test84_invtlb_op3_itlb
echo "test84_invtlb_op3_itlb"
./clean.sh
echo ""
cd ..


cd test85_invtlb_op3_dtlb
echo "test85_invtlb_op3_dtlb"
./clean.sh
echo ""
cd ..


cd test86_invtlb_op4_itlb
echo "test86_invtlb_op4_itlb"
./clean.sh
echo ""
cd ..


cd test87_invtlb_op4_dtlb
echo "test87_invtlb_op4_dtlb"
./clean.sh
echo ""
cd ..


cd test88_invtlb_op5_itlb
echo "test88_invtlb_op5_itlb"
./clean.sh
echo ""
cd ..


cd test89_invtlb_op5_dtlb
echo "test89_invtlb_op5_dtlb"
./clean.sh
echo ""
cd ..


cd test90_invtlb_op6_itlb
echo "test90_invtlb_op6_itlb"
./clean.sh
echo ""
cd ..


cd test91_invtlb_op6_dtlb
echo "test91_invtlb_op6_dtlb"
./clean.sh
echo ""
cd ..
