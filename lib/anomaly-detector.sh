#!/bin/bash
# =============================================================================
# Harmony Framework - Anomaly Detection
# =============================================================================
# Detects unusual agent behavior patterns that may indicate hallucination,
# looping, or degraded performance.
#
# Usage:
#   source "${HARMONY_DIR}/lib/anomaly-detector.sh"
#
#   # Check for anomalies in agent behavior
#   anomaly_check "developer" "$output"
#
#   # Record behavior for baseline
#   anomaly_record_baseline "developer" "task_completion" 95
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${ANOMALY_DETECTOR_LOADED:-}" == "true" ]]; then
    return 0
fi
ANOMALY_DETECTOR_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

ANOMALY_CONFIG="${HARMONY_DIR}/local/anomaly-config.json"
ANOMALY_BASELINES="${HARMONY_DIR}/local/anomaly-baselines.json"
ANOMALY_EVENTS="${HARMONY_DIR}/local/memory/anomaly-events.json"

# Colors
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# Source date utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/date_utils.sh" ]]; then
    source "${SCRIPT_DIR}/date_utils.sh"
fi

# Anomaly types
declare -A ANOMALY_SEVERITY=(
    ["loop_detected"]=3
    ["hallucination"]=4
    ["performance_degradation"]=2
    ["unusual_output"]=2
    ["repetitive_errors"]=3
    ["context_drift"]=2
    ["resource_abuse"]=4
)

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

_anomaly_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

_anomaly_init_events() {
    if [[ ! -f "$ANOMALY_EVENTS" ]]; then
        mkdir -p "$(dirname "$ANOMALY_EVENTS")"
        cp "${HARMONY_DIR}/templates/memory/anomaly-events.template.json" "$ANOMALY_EVENTS"
        local ts
        ts=$(_anomaly_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$ANOMALY_EVENTS" > "$tmp_file" && mv "$tmp_file" "$ANOMALY_EVENTS"
    fi
}

_anomaly_init_baselines() {
    if [[ ! -f "$ANOMALY_BASELINES" ]]; then
        mkdir -p "$(dirname "$ANOMALY_BASELINES")"
        cat > "$ANOMALY_BASELINES" << 'EOF'
{
  "version": "1.0.0",
  "agents": {},
  "global": {
    "avg_response_length": 500,
    "avg_task_duration": 60,
    "error_rate": 0.05,
    "repetition_threshold": 3
  }
}
EOF
    fi
}

# Detect repetitive patterns (looping)
_anomaly_check_loop() {
    local output="$1"
    local threshold="${2:-3}"

    # Split into lines and check for repetition
    local lines
    lines=$(echo "$output" | head -100)

    local prev_line=""
    local repeat_count=0
    local max_repeat=0

    while IFS= read -r line; do
        if [[ "$line" == "$prev_line" && -n "$line" ]]; then
            ((repeat_count++))
            if (( repeat_count > max_repeat )); then
                max_repeat=$repeat_count
            fi
        else
            repeat_count=0
        fi
        prev_line="$line"
    done <<< "$lines"

    if (( max_repeat >= threshold )); then
        echo "loop_detected:$max_repeat"
        return 0
    fi

    return 1
}

# Detect hallucination patterns
_anomaly_check_hallucination() {
    local output="$1"
    local output_lower="${output,,}"

    # Common hallucination indicators
    local indicators=(
        "as an ai"
        "i cannot"
        "i don't have access"
        "i apologize"
        "i'm sorry, but"
        "hypothetically"
        "in theory"
        "it's possible that"
        "i believe"
        "i think"
    )

    local indicator_count=0
    for indicator in "${indicators[@]}"; do
        if [[ "$output_lower" == *"$indicator"* ]]; then
            ((indicator_count++))
        fi
    done

    # Check for fabricated file paths
    if echo "$output" | grep -qE '/fake/|/imaginary/|/nonexistent/' 2>/dev/null; then
        ((indicator_count += 2))
    fi

    if (( indicator_count >= 3 )); then
        echo "hallucination:$indicator_count"
        return 0
    fi

    return 1
}

# Detect unusual output length
_anomaly_check_output_length() {
    local output="$1"
    local agent="$2"

    _anomaly_init_baselines

    local baseline
    baseline=$(jq -r --arg agent "$agent" '.agents[$agent].avg_response_length // .global.avg_response_length' "$ANOMALY_BASELINES")

    local length=${#output}

    # Flag if more than 5x or less than 0.1x baseline
    if (( length > baseline * 5 )); then
        echo "unusual_output:too_long:$length"
        return 0
    elif (( length < baseline / 10 && length < 50 )); then
        echo "unusual_output:too_short:$length"
        return 0
    fi

    return 1
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Check for anomalies in agent output
# Usage: anomaly_check agent output
anomaly_check() {
    local agent="$1"
    local output="$2"

    _anomaly_init_events

    local anomalies=()

    # Run all checks
    local loop_result
    if loop_result=$(_anomaly_check_loop "$output"); then
        anomalies+=("$loop_result")
    fi

    local hallucination_result
    if hallucination_result=$(_anomaly_check_hallucination "$output"); then
        anomalies+=("$hallucination_result")
    fi

    local length_result
    if length_result=$(_anomaly_check_output_length "$output" "$agent"); then
        anomalies+=("$length_result")
    fi

    # Record check
    local ts
    ts=$(_anomaly_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq '.statistics.total_checks += 1' "$ANOMALY_EVENTS" > "$tmp_file" && mv "$tmp_file" "$ANOMALY_EVENTS"

    # Record any anomalies found
    if (( ${#anomalies[@]} > 0 )); then
        for anomaly in "${anomalies[@]}"; do
            local atype="${anomaly%%:*}"
            local details="${anomaly#*:}"

            local severity="${ANOMALY_SEVERITY[$atype]:-2}"

            tmp_file=$(mktemp)
            jq --arg ts "$ts" \
               --arg agent "$agent" \
               --arg type "$atype" \
               --arg details "$details" \
               --argjson severity "$severity" \
               '.events += [{
                  "timestamp": $ts,
                  "agent": $agent,
                  "type": $type,
                  "details": $details,
                  "severity": $severity
                }] |
                .statistics.anomalies_detected += 1 |
                .statistics.by_type[$type] = ((.statistics.by_type[$type] // 0) + 1) |
                .statistics.by_agent[$agent] = ((.statistics.by_agent[$agent] // 0) + 1)' \
                "$ANOMALY_EVENTS" > "$tmp_file" && mv "$tmp_file" "$ANOMALY_EVENTS"

            echo -e "${C_YELLOW}Anomaly detected: $atype ($details)${C_NC}" >&2
        done

        # Return highest severity
        local max_sev=0
        for anomaly in "${anomalies[@]}"; do
            local atype="${anomaly%%:*}"
            local sev="${ANOMALY_SEVERITY[$atype]:-2}"
            if (( sev > max_sev )); then
                max_sev=$sev
            fi
        done

        return "$max_sev"
    fi

    return 0
}

# Record baseline for agent
# Usage: anomaly_record_baseline agent metric value
anomaly_record_baseline() {
    local agent="$1"
    local metric="$2"
    local value="$3"

    _anomaly_init_baselines

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg agent "$agent" --arg metric "$metric" --argjson value "$value" \
       '.agents[$agent][$metric] = $value' \
       "$ANOMALY_BASELINES" > "$tmp_file" && mv "$tmp_file" "$ANOMALY_BASELINES"
}

# Get recent anomalies
# Usage: anomaly_get_recent [limit]
anomaly_get_recent() {
    local limit="${1:-20}"

    _anomaly_init_events

    jq -r --argjson limit "$limit" '.events[-$limit:]' "$ANOMALY_EVENTS"
}

# Get anomaly statistics
# Usage: anomaly_get_stats
anomaly_get_stats() {
    _anomaly_init_events

    local stats
    stats=$(jq '.statistics' "$ANOMALY_EVENTS")

    echo -e "${C_CYAN}=== Anomaly Detection Statistics ===${C_NC}"
    echo -e "Total Checks:      ${C_WHITE}$(echo "$stats" | jq -r '.total_checks')${C_NC}"
    echo -e "Anomalies Found:   ${C_RED}$(echo "$stats" | jq -r '.anomalies_detected')${C_NC}"
    echo ""
    echo -e "${C_WHITE}By Type:${C_NC}"
    echo "$stats" | jq -r '.by_type | to_entries[] | "  \(.key): \(.value)"'
}

# Clear anomaly history
# Usage: anomaly_clear
anomaly_clear() {
    if [[ -f "$ANOMALY_EVENTS" ]]; then
        rm "$ANOMALY_EVENTS"
    fi
    _anomaly_init_events
    echo -e "${C_GREEN}Anomaly history cleared${C_NC}"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_anomaly_detector_self_test() {
    echo -e "${C_CYAN}=== Anomaly Detector Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    local passed=0
    local failed=0

    # Test 1: Detect loop
    echo -n "Test 1: Detect loop... "
    local loopy_output="line1
line1
line1
line1
line2"
    if _anomaly_check_loop "$loopy_output" 3 >/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: No loop in normal output
    echo -n "Test 2: No loop in normal... "
    local normal_output="line1
line2
line3
line4"
    if ! _anomaly_check_loop "$normal_output" 3 >/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Detect hallucination
    echo -n "Test 3: Detect hallucination... "
    local hallu_output="As an AI, I cannot access files. I apologize, but I believe this might work. I'm sorry, but I think this is hypothetically possible."
    if _anomaly_check_hallucination "$hallu_output" >/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Normal output passes
    echo -n "Test 4: Normal output passes... "
    local good_output="Created file src/app.ts with the login function implementation."
    if ! _anomaly_check_hallucination "$good_output" >/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Full anomaly check
    echo -n "Test 5: Full anomaly check... "
    anomaly_check "test_agent" "This is a normal response" 2>/dev/null
    local result=$?
    if (( result == 0 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Cleanup
    rm -rf "$test_dir"
    unset HARMONY_DIR

    echo ""
    echo -e "Results: ${C_GREEN}$passed passed${C_NC}, ${C_RED}$failed failed${C_NC}"

    [[ $failed -eq 0 ]]
}

if [[ "${1:-}" == "--test" ]]; then
    _anomaly_detector_self_test
    exit $?
fi
