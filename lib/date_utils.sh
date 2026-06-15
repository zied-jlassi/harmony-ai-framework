#!/usr/bin/env bash

# date_utils.sh - Cross-platform date/time helpers for the Harmony Framework
#
# Provides consistent timestamps and time arithmetic across GNU coreutils
# (Linux) and BSD date (macOS). When GNU `gdate` is installed on macOS
# (Homebrew coreutils), it is used automatically. The date implementation is
# detected once per shell and cached. See pattern P-011 (bash cross-platform).

# --- Implementation detection (resolved once, cached) -----------------------
# _DATE_IMPL_BIN : date binary to invoke (date or gdate)
# _DATE_IMPL_GNU : "1" when GNU-style flags (-d, --version) are available
_date_detect_impl() {
    [[ -n "${_DATE_IMPL_BIN:-}" ]] && return 0

    if command -v gdate >/dev/null 2>&1; then
        _DATE_IMPL_BIN="gdate"; _DATE_IMPL_GNU=1
    elif date --version >/dev/null 2>&1; then
        # GNU date understands --version; BSD date does not.
        _DATE_IMPL_BIN="date"; _DATE_IMPL_GNU=1
    else
        _DATE_IMPL_BIN="date"; _DATE_IMPL_GNU=0
    fi
    export _DATE_IMPL_BIN _DATE_IMPL_GNU
}

# Get current UTC timestamp in ISO 8601 format with seconds precision.
# Returns: YYYY-MM-DDTHH:MM:SS+00:00
# Note: with -u the offset is always +00:00, so it can be appended literally,
# which makes the format identical on GNU and BSD without branching.
get_iso_timestamp() {
    _date_detect_impl
    "$_DATE_IMPL_BIN" -u +"%Y-%m-%dT%H:%M:%S+00:00"
}

# Get the time component (HH:MM:SS) one hour from now (local time).
# Returns: HH:MM:SS
get_next_hour_time() {
    _date_detect_impl
    if [[ "$_DATE_IMPL_GNU" == "1" ]]; then
        "$_DATE_IMPL_BIN" -d '+1 hour' '+%H:%M:%S'
    else
        "$_DATE_IMPL_BIN" -v+1H '+%H:%M:%S'
    fi
}

# Get current local timestamp in a basic, human-friendly format.
# Returns: YYYY-MM-DD HH:MM:SS
get_basic_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get the Unix epoch timestamp (seconds since 1970-01-01 UTC).
# Returns: integer seconds
get_epoch_timestamp() {
    date '+%s'
}

# Convert an ISO 8601 timestamp to Unix epoch seconds (internal helper).
# Tolerates a trailing timezone designator (Z or +/-HH:MM), which BSD's
# strptime cannot parse; the value is interpreted as UTC.
_date_iso_to_epoch() {
    local ts="$1"
    [[ -z "$ts" ]] && { echo 0; return; }
    # Strip a trailing timezone suffix: Z, +00:00, -0500, etc.
    local naive="${ts%%+*}"; naive="${naive%%Z}"
    _date_detect_impl
    if [[ "$_DATE_IMPL_GNU" == "1" ]]; then
        "$_DATE_IMPL_BIN" -u -d "$ts" '+%s' 2>/dev/null || echo 0
    else
        "$_DATE_IMPL_BIN" -j -u -f "%Y-%m-%dT%H:%M:%S" "$naive" '+%s' 2>/dev/null || echo 0
    fi
}

# Calculate the difference in seconds between two ISO 8601 timestamps.
# Usage: get_time_diff_seconds "start" "end"
# Returns: integer seconds (end - start)
get_time_diff_seconds() {
    local start_epoch end_epoch
    start_epoch=$(_date_iso_to_epoch "$1")
    end_epoch=$(_date_iso_to_epoch "$2")
    echo $((end_epoch - start_epoch))
}

# Format a number of seconds into a human-readable duration.
# Usage: format_duration 3661  ->  "1h 1m 1s"
# Returns: string ("Xh Ym Zs", "Ym Zs" or "Zs")
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
export -f _date_detect_impl
export -f get_iso_timestamp
export -f get_next_hour_time
export -f get_basic_timestamp
export -f get_epoch_timestamp
export -f _date_iso_to_epoch
export -f get_time_diff_seconds
export -f format_duration
