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







cd test3_st.w
echo "test3_st.w"
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
