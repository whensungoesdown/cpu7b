#!/bin/bash
echo run tests
echo

cd test0
echo "test0"
./simulate.sh | grep PASS
echo ""
cd ..


cd test1_ld.w
echo "test1_ld.w"
./simulate.sh | grep PASS
echo ""
cd ..





cd test3_st.w
echo "test3_st.w"
./simulate.sh | grep PASS
echo ""
cd ..


cd test4_beq
echo "test4_beq"
./simulate.sh | grep PASS
echo ""
cd ..


cd test5_jirl
echo "test5_jirl"
./simulate.sh | grep PASS
echo ""
cd ..


cd test6_beq_testbyp
echo "test6_beq_testbyp"
./simulate.sh | grep PASS
echo ""
cd ..






cd test8_mulw
echo "test8_mulw"
./simulate.sh | grep PASS
echo ""
cd ..


cd test9_mulhwu
echo "test9_mulhwu"
./simulate.sh | grep PASS
echo ""
cd ..


cd test10_mulhw
echo "test10_mulhw"
./simulate.sh | grep PASS
echo ""
cd ..


cd test11_csrrd
echo "test11_csrrd"
./simulate.sh | grep PASS
echo ""
cd ..


cd test12_csrwr
echo "test12_csrwr"
./simulate.sh | grep PASS
echo ""
cd ..


cd test13_csrxchg
echo "test13_csrxchg"
./simulate.sh | grep PASS
echo ""
cd ..


cd test14_csr_crmd
echo "test14_csr_crmd"
./simulate.sh | grep PASS
echo ""
cd ..


cd test15_csr_prmd
echo "test15_csr_prmd"
./simulate.sh | grep PASS
echo ""
cd ..


cd test16_ale_exception
echo "test16_ale_exception"
./simulate.sh | grep PASS
echo ""
cd ..


cd test17_exception_crmd_prmd
echo "test17_exception_crmd_prmd"
./simulate.sh | grep PASS
echo ""
cd ..
