#!/bin/bash
# =============================================================================
# Harmony Framework - Test Environment Cleanup
# Pattern: P-013 Test Environment Isolation
# =============================================================================
#
# Cleans up old test environments, keeping the most recent N runs.
#
# Usage:
#   ./cleanup-test-env.sh [keep_count]
#
# Arguments:
#   keep_count - Number of recent runs to keep (default: 5)
#
# =============================================================================

TEST_ROOT="/tmp/harmony-framework"
KEEP_RUNS="${1:-5}"

echo "========================================"
echo "Harmony Test Environment Cleanup"
echo "========================================"
echo ""
echo "Location:  $TEST_ROOT"
echo "Keeping:   $KEEP_RUNS most recent runs"
echo ""

# Check if directory exists
if [[ ! -d "$TEST_ROOT" ]]; then
    echo "No test directory found at $TEST_ROOT"
    echo "Nothing to clean."
    exit 0
fi

# Get runs sorted by name (timestamp = chronological order)
# Only match directories with 12-digit timestamp names
RUNS=$(ls -1 "$TEST_ROOT" 2>/dev/null | grep -E '^[0-9]{12}$' | sort -r)

if [[ -z "$RUNS" ]]; then
    echo "No test runs found."
    exit 0
fi

# Count and clean
COUNT=0
REMOVED=0
KEPT=0

echo "Test runs found:"
for run in $RUNS; do
    ((COUNT++))
    RUN_PATH="$TEST_ROOT/$run"

    # Calculate size
    SIZE=$(du -sh "$RUN_PATH" 2>/dev/null | cut -f1)

    if [[ $COUNT -gt $KEEP_RUNS ]]; then
        echo "  [REMOVE] $run ($SIZE)"
        rm -rf "$RUN_PATH"
        ((REMOVED++))
    else
        echo "  [KEEP]   $run ($SIZE)"
        ((KEPT++))
    fi
done

# Summary
echo ""
echo "========================================"
echo "Cleanup Complete"
echo "========================================"
echo "  Kept:    $KEPT runs"
echo "  Removed: $REMOVED runs"
echo ""

# Show remaining disk usage
if [[ -d "$TEST_ROOT" ]]; then
    TOTAL_SIZE=$(du -sh "$TEST_ROOT" 2>/dev/null | cut -f1)
    echo "Total size: $TOTAL_SIZE"
fi
