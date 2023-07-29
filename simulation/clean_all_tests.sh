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
