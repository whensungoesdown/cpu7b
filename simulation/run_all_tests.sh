#!/bin/bash
echo run tests
echo

cd test0
echo "test0"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test1_ld.w
echo "test1_ld.w"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test1_1_ld.w
echo "test1_1_ld.w"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..



cd test3_st.w
echo "test3_st.w"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..



cd test3_1_st.w
echo "test3_1_st.w"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..



cd test4_beq
echo "test4_beq"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test5_jirl
echo "test5_jirl"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test6_beq_testbyp
echo "test6_beq_testbyp"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..






cd test8_mulw
echo "test8_mulw"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test9_mulhwu
echo "test9_mulhwu"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test10_mulhw
echo "test10_mulhw"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test11_csrrd
echo "test11_csrrd"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test12_csrwr
echo "test12_csrwr"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test13_csrxchg
echo "test13_csrxchg"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test14_csr_crmd
echo "test14_csr_crmd"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test15_csr_prmd
echo "test15_csr_prmd"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test16_ale_exception
echo "test16_ale_exception"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test17_exception_crmd_prmd
echo "test17_exception_crmd_prmd"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test18_csr_badv
echo "test18_csr_badv"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test19_csr_tcfg
echo "test19_csr_tcfg"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test20_csr_tcfg_periodic
echo "test20_csr_tcfg_periodic"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test21_timer_intr_right_after_branch
echo "test21_timer_intr_right_after_branch"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test22_timer_intr_on_pipeline_bubble
echo "test22_timer_intr_on_pipeline_bubble"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test23_lsu_stall_ifu_at_e
echo "test23_lsu_stall_ifu_at_e"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test24_beq_ld.w
echo "test24_beq_ld.w"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test25_lsu_stall
echo "test25_lsu_stall"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test26_illinstr_exception
echo "test26_illinstr_exception"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test27_estat
echo "test27_estat"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test28_ld.b.bu.h.hu
echo "test28_ld.b.bu.h.hu"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test29_st.b.h
echo "test29_st.b.h"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test30_ext_intr
echo "test30_ext_intr"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test31_andi
echo "test31_andi"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test32_ext_intr_during_ld
echo "test32_ext_intr_during_ld"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test33_icache_smoke
echo "test33_icache_smoke"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test34_ext_intr_on_branch
echo "test34_ext_intr_on_branch"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test35_ext_intr_random
echo "test35_ext_intr_random"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..
