#!/usr/bin/env bash

# date_utils.sh - Cross-platform date utility functions
# Provides consistent date formatting and arithmetic across GNU (Linux) and BSD (macOS) systems
# Source: Adapted from ralph-claude-code for Harmony Framework Phase 2

# Get current timestamp in ISO 8601 format with seconds precision
# Returns: YYYY-MM-DDTHH:MM:SS+00:00 format
get_iso_timestamp() {
    local os_type
    os_type=$(uname)

    if [[ "$os_type" == "Darwin" ]]; then
        # macOS (BSD date)
        # Use manual formatting and add colon to timezone offset
        date -u +"%Y-%m-%dT%H:%M:%S%z" | sed 's/\(..\)$/:\1/'
    else
        # Linux (GNU date) - use -u flag for UTC
        date -u -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

# Get time component (HH:MM:SS) for one hour from now
# Returns: HH:MM:SS format
get_next_hour_time() {
    local os_type
    os_type=$(uname)

    if [[ "$os_type" == "Darwin" ]]; then
        # macOS (BSD date) - use -v flag for date arithmetic
        date -v+1H '+%H:%M:%S'
    else
        # Linux (GNU date) - use -d flag for date arithmetic
        date -d '+1 hour' '+%H:%M:%S' 2>/dev/null || date '+%H:%M:%S'
    fi
}

# Get current timestamp in a basic format (fallback)
# Returns: YYYY-MM-DD HH:MM:SS format
get_basic_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get Unix epoch timestamp (seconds since 1970)
# Returns: Integer seconds
get_epoch_timestamp() {
    date '+%s'
}

# Calculate time difference in seconds
# Usage: get_time_diff_seconds "start_timestamp" "end_timestamp"
# Returns: Integer seconds difference
get_time_diff_seconds() {
    local start_ts="$1"
    local end_ts="$2"
    local os_type
    os_type=$(uname)

    if [[ "$os_type" == "Darwin" ]]; then
        # macOS
        local start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$start_ts" '+%s' 2>/dev/null || echo "0")
        local end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$end_ts" '+%s' 2>/dev/null || echo "0")
    else
        # Linux
        local start_epoch=$(date -d "$start_ts" '+%s' 2>/dev/null || echo "0")
        local end_epoch=$(date -d "$end_ts" '+%s' 2>/dev/null || echo "0")
    fi

    echo $((end_epoch - start_epoch))
}

# Format seconds into human-readable duration
# Usage: format_duration 3661
# Returns: "1h 1m 1s"
format_duration() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [[ $hours -gt 0 ]]; then
        echo "${hours}h ${minutes}m ${secs}s"
    elif [[ $minutes -gt 0 ]]; then
        echo "${minutes}m ${secs}s"
    else
        echo "${secs}s"
    fi
}

# Export functions for use in other scripts
export -f get_iso_timestamp
export -f get_next_hour_time
export -f get_basic_timestamp
export -f get_epoch_timestamp
export -f get_time_diff_seconds
export -f format_duration
