#!/bin/bash
echo run tests
echo



run_test() {
    local test_dir="$1"
    
    echo "Running: $test_dir"
    cd "$test_dir"
    
    # Run test and capture output
    output=$(./run_simulate.sh 2>&1)
    echo "$output"
    echo ""
    
    # Check for PASS indicator
    if [[ "$output" != *"All runs contained PASS!"* ]]; then
        echo "Test FAILED: '$test_dir'"
        exit 1
    fi
    
    cd ..
}

echo "Starting RANDOM test suite..."
echo ""

run_test "test35_ext_intr_random"
run_test "test36_ext_intr_on_alu_inst_random"
run_test "test37_ext_intr_on_lsu_inst_random"
run_test "test38_ext_intr_on_2lsu_inst_random"

echo "All RANDOM tests PASSED successfully!"
