#!/bin/bash

# Configuration
TOTAL_RUNS=20
SEARCH_PATTERNS="PASS|FAIL|RANDOM"

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
    
    # Execute simulate.sh and filter output
    # -E: extended regex, --color=auto: highlight matches
    ./simulate.sh 2>&1 | grep -E --color=auto "$SEARCH_PATTERNS"
    #./simulate.sh
    
    # Get exit status of the pipeline
    PIPESTATUS=(${PIPESTATUS[@]})
    
    # Check if simulate.sh failed
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo "Warning: simulate.sh exited with code ${PIPESTATUS[0]}"
    fi
    
    # Add separator between runs
    if [ $i -lt $TOTAL_RUNS ]; then
        echo "----------------------------------------"
    fi
done

echo "========================================"
echo "All $TOTAL_RUNS runs completed successfully!"
