#!/bin/bash

# Configuration
TOTAL_RUNS=20
SEARCH_PATTERNS="PASS|FAIL|RANDOM"
NO_PASS_COUNT=0
NO_PASS_RUNS=()

# Function to display usage
usage() {
    echo "Usage: $0"
    echo "Runs simulate.sh 100 times and filters for PASS/FAIL/RANDOM patterns"
    echo "Prerequisites: simulate.sh must exist and be executable in current directory"
}

# Check if simulate.sh exists and is executable
if [ ! -f "simulate.sh" ]; then
    echo "Error: simulate.sh not found in current directory"
    usage
    exit 1
fi

if [ ! -x "simulate.sh" ]; then
    echo "Error: simulate.sh is not executable"
    echo "Try: chmod +x simulate.sh"
    exit 1
fi

echo "Starting $TOTAL_RUNS runs of simulate.sh..."
echo "Searching for patterns: $SEARCH_PATTERNS"
echo "========================================"

# Run simulation multiple times
for ((i=1; i<=TOTAL_RUNS; i++))
do
    echo "Run $i/$TOTAL_RUNS:"
    
    # Execute simulate.sh and capture output
    OUTPUT=$(./simulate.sh 2>&1)
    EXIT_STATUS=$?
    
    # Check if simulate.sh failed
    if [ $EXIT_STATUS -ne 0 ]; then
        echo "Warning: simulate.sh exited with code $EXIT_STATUS"
    fi
    
    # Get matching lines
    MATCHING_LINES=$(echo "$OUTPUT" | grep -E "$SEARCH_PATTERNS")
    
    # Check if PASS appears in the matching lines
    if echo "$MATCHING_LINES" | grep -q "PASS"; then
        # If PASS found, highlight PASS in green
        echo "$MATCHING_LINES" | sed -E 's/(PASS)/\x1b[32m\1\x1b[0m/g'
    else
        # If no PASS found, check if there are any matching lines
        if [ -n "$MATCHING_LINES" ]; then
            # If there are other matches (like FAIL, RANDOM), show them
            echo "$MATCHING_LINES"
        fi
        # Output red FAIL
        ((NO_PASS_COUNT++))
        NO_PASS_RUNS+=("Run $i")
        echo -e "\x1b[31mFAIL\x1b[0m"
    fi
    
    # Add separator between runs
    if [ $i -lt $TOTAL_RUNS ]; then
        echo "----------------------------------------"
    fi
done

echo "========================================"
echo "All $TOTAL_RUNS runs completed!"

# Display statistics
if [ $NO_PASS_COUNT -eq 0 ]; then
    echo -e "\x1b[32m All runs contained PASS!\x1b[0m"
else
    echo -e "\x1b[31m Found $NO_PASS_COUNT run(s) without PASS:\x1b[0m"
    for run in "${NO_PASS_RUNS[@]}"; do
        echo "  - $run"
    done
fi
