#!/bin/bash
#
# Harmony Framework Benchmark
# Compare performance WITH vs WITHOUT Harmony
#
# Usage: ./benchmark.sh [task_description]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

BENCHMARK_DIR=".harmony/local/benchmarks"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_FILE="${BENCHMARK_DIR}/.current"

# Get current benchmark file (or create new)
get_benchmark_file() {
    if [[ -f "$CURRENT_FILE" ]]; then
        cat "$CURRENT_FILE"
    else
        echo "${BENCHMARK_DIR}/benchmark-${TIMESTAMP}.json"
    fi
}

BENCHMARK_FILE=$(get_benchmark_file)

# Ensure directory exists
mkdir -p "$BENCHMARK_DIR"

# Initialize benchmark file
init_benchmark() {
    BENCHMARK_FILE="${BENCHMARK_DIR}/benchmark-${TIMESTAMP}.json"
    echo "$BENCHMARK_FILE" > "$CURRENT_FILE"
    cat > "$BENCHMARK_FILE" << EOF
{
  "id": "${TIMESTAMP}",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "task": "$1",
  "measurements": []
}
EOF
}

# Start measurement
start_measurement() {
    local name="$1"
    local start_time=$(date +%s%3N 2>/dev/null || date +%s)

    # Get initial token count if available
    local initial_tokens=0
    if [[ -f ".claude/memory/token-usage.json" ]]; then
        initial_tokens=$(jq -r '[.sessions[].total_tokens] | add // 0' .claude/memory/token-usage.json 2>/dev/null || echo "0")
    fi

    echo "${start_time}|${initial_tokens}|${name}"
}

# End measurement
end_measurement() {
    local start_data="$1"
    local start_time=$(echo "$start_data" | cut -d'|' -f1)
    local initial_tokens=$(echo "$start_data" | cut -d'|' -f2)
    local name=$(echo "$start_data" | cut -d'|' -f3)

    local end_time=$(date +%s%3N 2>/dev/null || date +%s)
    local duration=$((end_time - start_time))

    # Get final token count
    local final_tokens=0
    if [[ -f ".claude/memory/token-usage.json" ]]; then
        final_tokens=$(jq -r '[.sessions[].total_tokens] | add // 0' .claude/memory/token-usage.json 2>/dev/null || echo "0")
    fi
    local tokens_used=$((final_tokens - initial_tokens))

    # Append to benchmark file
    local temp_file=$(mktemp)
    jq --arg name "$name" \
       --argjson duration "$duration" \
       --argjson tokens "$tokens_used" \
       --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.measurements += [{
           name: $name,
           duration_ms: $duration,
           tokens_used: $tokens,
           completed_at: $ts
       }]' "$BENCHMARK_FILE" > "$temp_file" 2>/dev/null && mv "$temp_file" "$BENCHMARK_FILE"

    echo "${duration}|${tokens_used}"
}

# Display results
display_results() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                   ${WHITE}📊 HARMONY BENCHMARK RESULTS${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    local task=$(jq -r '.task' "$BENCHMARK_FILE" 2>/dev/null)
    printf "${CYAN}║${NC}  Task: ${DIM}%-60s${NC}   ${CYAN}║${NC}\n" "$task"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"

    # Get measurements
    local without_duration=$(jq -r '.measurements[] | select(.name == "without_hf") | .duration_ms // 0' "$BENCHMARK_FILE" 2>/dev/null)
    local without_tokens=$(jq -r '.measurements[] | select(.name == "without_hf") | .tokens_used // 0' "$BENCHMARK_FILE" 2>/dev/null)
    local with_duration=$(jq -r '.measurements[] | select(.name == "with_hf") | .duration_ms // 0' "$BENCHMARK_FILE" 2>/dev/null)
    local with_tokens=$(jq -r '.measurements[] | select(.name == "with_hf") | .tokens_used // 0' "$BENCHMARK_FILE" 2>/dev/null)

    echo -e "${CYAN}║${NC}  ${WHITE}Comparison:${NC}                                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}─────────────────────────────────────────────────────────────────${NC}     ${CYAN}║${NC}"
    printf "${CYAN}║${NC}     %-20s %15s %15s                   ${CYAN}║${NC}\n" "" "Duration (ms)" "Tokens"
    printf "${CYAN}║${NC}     ${RED}%-20s${NC} %15s %15s                   ${CYAN}║${NC}\n" "WITHOUT Harmony" "${without_duration:-N/A}" "${without_tokens:-N/A}"
    printf "${CYAN}║${NC}     ${GREEN}%-20s${NC} %15s %15s                   ${CYAN}║${NC}\n" "WITH Harmony" "${with_duration:-N/A}" "${with_tokens:-N/A}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"

    # Calculate differences if both measurements exist
    if [[ -n "$without_duration" && -n "$with_duration" && "$without_duration" != "0" ]]; then
        local time_diff=$((with_duration - without_duration))
        local time_pct=$(( (time_diff * 100) / without_duration ))

        local token_diff=$((with_tokens - without_tokens))
        local token_pct=0
        if [[ "$without_tokens" != "0" ]]; then
            token_pct=$(( (token_diff * 100) / without_tokens ))
        fi

        echo -e "${CYAN}║${NC}  ${WHITE}Difference:${NC}                                                             ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${DIM}─────────────────────────────────────────────────────────────────${NC}     ${CYAN}║${NC}"

        local time_color="$GREEN"
        [[ $time_diff -gt 0 ]] && time_color="$RED"
        local token_color="$GREEN"
        [[ $token_diff -gt 0 ]] && token_color="$RED"

        printf "${CYAN}║${NC}     Time:   ${time_color}%+d ms (%+d%%)${NC}                                          ${CYAN}║${NC}\n" "$time_diff" "$time_pct"
        printf "${CYAN}║${NC}     Tokens: ${token_color}%+d (%+d%%)${NC}                                             ${CYAN}║${NC}\n" "$token_diff" "$token_pct"
    fi

    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC}  Report saved: ${DIM}%-52s${NC}  ${CYAN}║${NC}\n" "$BENCHMARK_FILE"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Manual recording mode
record_manual() {
    local phase="$1"
    local tokens="$2"
    local duration="$3"

    if [[ -z "$tokens" || -z "$duration" ]]; then
        echo "Usage: benchmark.sh record <without_hf|with_hf> <tokens> <duration_ms>"
        exit 1
    fi

    # Get current benchmark file
    BENCHMARK_FILE=$(get_benchmark_file)

    # Create if not exists
    if [[ ! -f "$BENCHMARK_FILE" ]]; then
        init_benchmark "Manual benchmark"
        BENCHMARK_FILE=$(get_benchmark_file)
    fi

    local temp_file=$(mktemp)
    jq --arg name "$phase" \
       --argjson duration "$duration" \
       --argjson tokens "$tokens" \
       --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.measurements += [{
           name: $name,
           duration_ms: $duration,
           tokens_used: $tokens,
           completed_at: $ts
       }]' "$BENCHMARK_FILE" > "$temp_file" 2>/dev/null && mv "$temp_file" "$BENCHMARK_FILE"

    echo -e "${GREEN}✓${NC} Recorded: $phase - ${tokens} tokens, ${duration}ms"
}

# Show last benchmark
show_last() {
    local last_file=$(ls -t "${BENCHMARK_DIR}"/benchmark-*.json 2>/dev/null | head -1)
    if [[ -n "$last_file" ]]; then
        BENCHMARK_FILE="$last_file"
        display_results
    else
        echo "No benchmarks found"
    fi
}

# List all benchmarks
list_benchmarks() {
    echo -e "${CYAN}Benchmark History:${NC}"
    echo ""
    for f in $(ls -t "${BENCHMARK_DIR}"/benchmark-*.json 2>/dev/null | head -10); do
        local id=$(jq -r '.id' "$f" 2>/dev/null)
        local task=$(jq -r '.task' "$f" 2>/dev/null | cut -c1-40)
        local count=$(jq -r '.measurements | length' "$f" 2>/dev/null)
        printf "  %s  %-40s  (%d measurements)\n" "$id" "$task" "$count"
    done
}

# Main
case "${1:-help}" in
    init)
        init_benchmark "${2:-Benchmark task}"
        echo -e "${GREEN}✓${NC} Benchmark initialized: $BENCHMARK_FILE"
        ;;
    record)
        record_manual "$2" "$3" "$4"
        ;;
    show|results)
        show_last
        ;;
    list)
        list_benchmarks
        ;;
    compare)
        display_results
        ;;
    help|--help|-h)
        echo ""
        echo -e "${WHITE}Harmony Benchmark Tool${NC}"
        echo ""
        echo "Usage: benchmark.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  init <task>                    Initialize new benchmark"
        echo "  record <phase> <tokens> <ms>   Record measurement manually"
        echo "                                 phase: without_hf | with_hf"
        echo "  show                           Show last benchmark results"
        echo "  list                           List all benchmarks"
        echo "  compare                        Compare current benchmark"
        echo ""
        echo "Example workflow:"
        echo "  1. benchmark.sh init 'Create CRUD endpoint'"
        echo "  2. Run task WITHOUT Harmony, note tokens/time"
        echo "  3. benchmark.sh record without_hf 5000 120000"
        echo "  4. Run task WITH Harmony, note tokens/time"
        echo "  5. benchmark.sh record with_hf 3500 90000"
        echo "  6. benchmark.sh compare"
        echo ""
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'benchmark.sh help' for usage"
        exit 1
        ;;
esac
