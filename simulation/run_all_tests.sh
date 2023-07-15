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
