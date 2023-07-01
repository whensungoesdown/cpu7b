#!/bin/bash
echo run tests
echo

cd test0
echo "test0"
./simulate.sh | grep PASS
echo ""
cd ..

