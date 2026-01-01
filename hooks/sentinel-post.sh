#!/bin/bash
#
# Sentinel Post-Operation Hook
# Records operation results and updates circuit breaker
#
# Usage: Called by AI assistant after operations
# Arguments: $1 = tool_name, $2 = tool_input, $3 = tool_output, $4 = exit_code
#

set -e

HARMONY_DIR=".harmony"
ERROR_JOURNAL="${HARMONY_DIR}/memory/error-journal.json"
CIRCUIT_BREAKER="${HARMONY_DIR}/memory/circuit-breaker.json"
TOOL_NAME="${1:-unknown}"
TOOL_INPUT="${2:-{}}"
TOOL_OUTPUT="${3:-}"
EXIT_CODE="${4:-0}"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure memory directory exists
ensure_memory_dir() {
    mkdir -p "${HARMONY_DIR}/memory"
}

# Initialize error journal if needed
init_error_journal() {
    if [[ ! -f "$ERROR_JOURNAL" ]]; then
        cat > "$ERROR_JOURNAL" << 'EOF'
{
  "version": "1.0",
  "last_updated": "",
  "errors": [],
  "statistics": {
    "total_errors": 0,
    "resolved": 0,
    "recurring": 0,
    "by_category": {}
  }
}
EOF
    fi
}

# Initialize circuit breaker if needed
init_circuit_breaker() {
    if [[ ! -f "$CIRCUIT_BREAKER" ]]; then
        cat > "$CIRCUIT_BREAKER" << 'EOF'
{
  "version": "1.0",
  "state": "CLOSED",
  "consecutive_failures": 0,
  "last_failure": null,
  "last_success": null,
  "max_failures": 3,
  "cooldown_minutes": 5,
  "history": []
}
EOF
    fi
}

# Get current timestamp
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Generate error ID
generate_error_id() {
    local count
    count=$(jq '.statistics.total_errors // 0' "$ERROR_JOURNAL" 2>/dev/null || echo "0")
    count=$((count + 1))
    printf "ERR-%03d" "$count"
}

# Detect error category from output
detect_category() {
    local output="$1"

    if echo "$output" | grep -qiE "typescript|ts[0-9]+|type.*error"; then
        echo "typescript"
    elif echo "$output" | grep -qiE "cannot find module|import.*error|require"; then
        echo "imports"
    elif echo "$output" | grep -qiE "docker|container|image"; then
        echo "docker"
    elif echo "$output" | grep -qiE "prisma|database|sql|migration"; then
        echo "database"
    elif echo "$output" | grep -qiE "test.*fail|jest|vitest|expect"; then
        echo "tests"
    elif echo "$output" | grep -qiE "build.*fail|compile|webpack|vite"; then
        echo "build"
    elif echo "$output" | grep -qiE "permission|access denied|EACCES"; then
        echo "permissions"
    else
        echo "general"
    fi
}

# Detect error severity
detect_severity() {
    local output="$1"

    if echo "$output" | grep -qiE "critical|fatal|crash|segfault"; then
        echo "critical"
    elif echo "$output" | grep -qiE "error|fail|exception"; then
        echo "high"
    elif echo "$output" | grep -qiE "warning|warn|deprecated"; then
        echo "medium"
    else
        echo "low"
    fi
}

# Extract error title from output
extract_title() {
    local output="$1"

    # Try to extract first error line
    local title
    title=$(echo "$output" | grep -iE "^(error|Error|ERROR|fail|FAIL)" | head -1 | cut -c1-100)

    if [[ -z "$title" ]]; then
        title=$(echo "$output" | head -1 | cut -c1-100)
    fi

    echo "${title:-Unknown error}"
}

# Record error to journal
record_error() {
    local timestamp
    timestamp=$(get_timestamp)

    local error_id
    error_id=$(generate_error_id)

    local category
    category=$(detect_category "$TOOL_OUTPUT")

    local severity
    severity=$(detect_severity "$TOOL_OUTPUT")

    local title
    title=$(extract_title "$TOOL_OUTPUT")

    local file_path
    file_path=$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // ""' 2>/dev/null || echo "")

    # Create error entry
    local error_entry
    error_entry=$(jq -n \
        --arg id "$error_id" \
        --arg ts "$timestamp" \
        --arg cat "$category" \
        --arg sev "$severity" \
        --arg title "$title" \
        --arg file "$file_path" \
        --arg tool "$TOOL_NAME" \
        --arg symptom "${TOOL_OUTPUT:0:500}" \
        '{
            id: $id,
            timestamp: $ts,
            category: $cat,
            severity: $sev,
            title: $title,
            context: {
                file: $file,
                tool: $tool
            },
            symptom: $symptom,
            root_cause: "To be determined",
            solution: "To be determined",
            prevention_rule: "",
            tags: [$cat, $tool],
            status: "open",
            recurrence_count: 0
        }')

    # Add to journal
    local temp_file
    temp_file=$(mktemp)

    jq --argjson entry "$error_entry" \
        --arg ts "$timestamp" \
        '.errors += [$entry] | .last_updated = $ts | .statistics.total_errors += 1 | .statistics.by_category[$entry.category] = ((.statistics.by_category[$entry.category] // 0) + 1)' \
        "$ERROR_JOURNAL" > "$temp_file" && mv "$temp_file" "$ERROR_JOURNAL"

    echo "$error_id"
}

# Update circuit breaker on failure
update_circuit_failure() {
    local timestamp
    timestamp=$(get_timestamp)

    local temp_file
    temp_file=$(mktemp)

    # Increment failures
    jq --arg ts "$timestamp" \
        '.consecutive_failures += 1 | .last_failure = $ts |
        if .consecutive_failures >= .max_failures then .state = "OPEN" else . end |
        .history += [{timestamp: $ts, event: "failure", count: .consecutive_failures}]' \
        "$CIRCUIT_BREAKER" > "$temp_file" && mv "$temp_file" "$CIRCUIT_BREAKER"

    # Check if circuit just opened
    local state
    state=$(jq -r '.state' "$CIRCUIT_BREAKER")
    local failures
    failures=$(jq -r '.consecutive_failures' "$CIRCUIT_BREAKER")

    if [[ "$state" == "OPEN" ]]; then
        echo -e "${RED}🛑 CIRCUIT BREAKER OPENED${NC}"
        echo -e "${RED}${failures} consecutive failures detected.${NC}"
        echo -e "${YELLOW}Diagnosis required before continuing.${NC}"
    else
        echo -e "${YELLOW}⚠️  Failure recorded (${failures}/3)${NC}"
    fi
}

# Update circuit breaker on success
update_circuit_success() {
    local timestamp
    timestamp=$(get_timestamp)

    local temp_file
    temp_file=$(mktemp)

    # Reset failures on success
    jq --arg ts "$timestamp" \
        '.consecutive_failures = 0 | .last_success = $ts | .state = "CLOSED" |
        .history += [{timestamp: $ts, event: "success"}]' \
        "$CIRCUIT_BREAKER" > "$temp_file" && mv "$temp_file" "$CIRCUIT_BREAKER"
}

# Print success message
print_success() {
    echo -e "${GREEN}✅ Operation successful${NC}"
}

# Print failure message
print_failure() {
    local error_id="$1"
    echo -e "${RED}❌ Operation failed${NC}"
    echo -e "${YELLOW}Error recorded: ${error_id}${NC}"
}

# Main logic
main() {
    ensure_memory_dir
    init_error_journal
    init_circuit_breaker

    # Check if operation succeeded
    if [[ "$EXIT_CODE" == "0" ]]; then
        # Check if output contains error indicators
        if echo "$TOOL_OUTPUT" | grep -qiE "error|fail|exception|fatal" && \
           ! echo "$TOOL_OUTPUT" | grep -qiE "0 error|no error|error.*0|passed"; then
            # Looks like an error despite exit code 0
            local error_id
            error_id=$(record_error)
            update_circuit_failure
            print_failure "$error_id"
        else
            update_circuit_success
            # Only print success for potentially risky operations
            case "$TOOL_NAME" in
                Bash|Write|Edit)
                    print_success
                    ;;
            esac
        fi
    else
        # Definite failure
        local error_id
        error_id=$(record_error)
        update_circuit_failure
        print_failure "$error_id"
    fi

    exit 0
}

main "$@"
