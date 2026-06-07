#!/bin/bash
# =============================================================================
# Harmony Framework - Security Gates (Superagent-Style)
# =============================================================================
# Security gates at each agent transition. Implements safety checks before
# allowing agents to proceed with sensitive operations.
#
# Usage:
#   source "${HARMONY_DIR}/lib/security-gates.sh"
#
#   # Check if operation is allowed
#   if security_check_gate "file_write" "/etc/passwd"; then
#       # Operation allowed
#   fi
#
#   # Record security event
#   security_record_event "blocked" "Attempted write to system file"
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${SECURITY_GATES_LOADED:-}" == "true" ]]; then
    return 0
fi
SECURITY_GATES_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

SECURITY_CONFIG="${HARMONY_DIR}/local/security-gates.json"
SECURITY_LOG="${HARMONY_DIR}/local/memory/security-log.json"

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

# Gate definitions
declare -A GATE_LEVELS=(
    ["file_read"]=1
    ["file_write"]=2
    ["file_delete"]=3
    ["command_execute"]=2
    ["network_request"]=2
    ["database_read"]=2
    ["database_write"]=3
    ["database_delete"]=4
    ["config_read"]=1
    ["config_write"]=3
    ["deploy"]=4
    ["git_push"]=3
    ["secret_access"]=4
)

# Blocked paths
BLOCKED_PATHS=(
    "/etc/"
    "/root/"
    "/var/log/"
    "/sys/"
    "/proc/"
    "~/.ssh/"
    "~/.aws/"
    "~/.config/"
    ".env"
    "credentials"
    "secrets"
    "private_key"
)

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

# Get ISO timestamp
_security_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

# Initialize log
_security_init_log() {
    if [[ ! -f "$SECURITY_LOG" ]]; then
        mkdir -p "$(dirname "$SECURITY_LOG")"
        cp "${HARMONY_DIR}/templates/memory/security-log.template.json" "$SECURITY_LOG"
        local ts
        ts=$(_security_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$SECURITY_LOG" > "$tmp_file" && mv "$tmp_file" "$SECURITY_LOG"
    fi
}

# Load config
_security_config_get() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "$SECURITY_CONFIG" ]]; then
        local value
        value=$(jq -r ".$key // empty" "$SECURITY_CONFIG" 2>/dev/null)
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
            return
        fi
    fi
    echo "$default"
}

# Check if path is blocked
_security_is_path_blocked() {
    local path="$1"

    for blocked in "${BLOCKED_PATHS[@]}"; do
        if [[ "$path" == *"$blocked"* ]]; then
            return 0
        fi
    done

    # Check config for additional blocked paths
    if [[ -f "$SECURITY_CONFIG" ]]; then
        local custom_blocked
        custom_blocked=$(jq -r '.blocked_paths[]? // empty' "$SECURITY_CONFIG" 2>/dev/null)

        while IFS= read -r blocked; do
            if [[ -n "$blocked" && "$path" == *"$blocked"* ]]; then
                return 0
            fi
        done <<< "$custom_blocked"
    fi

    return 1
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Check security gate
# Usage: security_check_gate gate_type target [agent]
# Returns: 0 if allowed, 1 if blocked
security_check_gate() {
    local gate_type="$1"
    local target="${2:-}"
    local agent="${3:-unknown}"

    _security_init_log

    local ts
    ts=$(_security_timestamp)

    local allowed=true
    local reason=""

    # Check gate level
    local gate_level="${GATE_LEVELS[$gate_type]:-1}"
    local max_level
    max_level=$(_security_config_get "max_auto_level" "2")

    if (( gate_level > max_level )); then
        allowed=false
        reason="Gate level $gate_level exceeds max auto-approve level $max_level"
    fi

    # Check blocked paths for file operations
    if [[ "$allowed" == "true" && "$gate_type" == file_* ]]; then
        if _security_is_path_blocked "$target"; then
            allowed=false
            reason="Path is in blocked list: $target"
        fi
    fi

    # Check for dangerous commands
    if [[ "$allowed" == "true" && "$gate_type" == "command_execute" ]]; then
        local dangerous_cmds="rm -rf|sudo|chmod 777|curl.*\|.*sh|wget.*\|.*sh|eval|exec"
        if echo "$target" | grep -qE "$dangerous_cmds"; then
            allowed=false
            reason="Dangerous command pattern detected"
        fi
    fi

    # Record event
    local result="allowed"
    if [[ "$allowed" == "false" ]]; then
        result="blocked"
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg ts "$ts" \
       --arg gate "$gate_type" \
       --arg target "$target" \
       --arg agent "$agent" \
       --arg result "$result" \
       --arg reason "$reason" \
       '.events += [{
          "timestamp": $ts,
          "gate": $gate,
          "target": $target,
          "agent": $agent,
          "result": $result,
          "reason": $reason
        }] |
        .statistics.total_checks += 1 |
        if $result == "allowed" then .statistics.allowed += 1 else .statistics.blocked += 1 end |
        .statistics.by_gate[$gate] = ((.statistics.by_gate[$gate] // 0) + 1) |
        .statistics.by_agent[$agent] = ((.statistics.by_agent[$agent] // 0) + 1)' \
        "$SECURITY_LOG" > "$tmp_file" && mv "$tmp_file" "$SECURITY_LOG"

    if [[ "$allowed" == "true" ]]; then
        return 0
    else
        echo -e "${C_RED}Security gate blocked: $gate_type - $reason${C_NC}" >&2
        return 1
    fi
}

# Record security event
# Usage: security_record_event type description [details_json]
security_record_event() {
    local event_type="$1"
    local description="$2"
    local details="${3:-{}}"

    _security_init_log

    local ts
    ts=$(_security_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg ts "$ts" \
       --arg type "$event_type" \
       --arg desc "$description" \
       --argjson details "$details" \
       '.events += [{
          "timestamp": $ts,
          "type": $type,
          "description": $desc,
          "details": $details
        }]' "$SECURITY_LOG" > "$tmp_file" && mv "$tmp_file" "$SECURITY_LOG"
}

# Request approval for high-level operation
# Usage: security_request_approval gate_type target reason
security_request_approval() {
    local gate_type="$1"
    local target="$2"
    local reason="$3"

    echo -e "${C_YELLOW}=== Security Approval Required ===${C_NC}"
    echo -e "Gate:   ${C_WHITE}$gate_type${C_NC}"
    echo -e "Target: ${C_WHITE}$target${C_NC}"
    echo -e "Reason: ${C_WHITE}$reason${C_NC}"
    echo ""

    local gate_level="${GATE_LEVELS[$gate_type]:-1}"
    echo -e "Risk Level: ${C_RED}$gate_level/4${C_NC}"

    # Return pending - actual approval would be handled by UI
    echo "PENDING_APPROVAL"
}

# Add allowed path
# Usage: security_allow_path path
security_allow_path() {
    local path="$1"

    if [[ ! -f "$SECURITY_CONFIG" ]]; then
        mkdir -p "$(dirname "$SECURITY_CONFIG")"
        echo '{"allowed_paths": [], "blocked_paths": [], "max_auto_level": 2}' > "$SECURITY_CONFIG"
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg path "$path" '.allowed_paths += [$path] | .allowed_paths |= unique' \
        "$SECURITY_CONFIG" > "$tmp_file" && mv "$tmp_file" "$SECURITY_CONFIG"

    echo -e "${C_GREEN}Path added to allowed list: $path${C_NC}"
}

# Block path
# Usage: security_block_path path
security_block_path() {
    local path="$1"

    if [[ ! -f "$SECURITY_CONFIG" ]]; then
        mkdir -p "$(dirname "$SECURITY_CONFIG")"
        echo '{"allowed_paths": [], "blocked_paths": [], "max_auto_level": 2}' > "$SECURITY_CONFIG"
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg path "$path" '.blocked_paths += [$path] | .blocked_paths |= unique' \
        "$SECURITY_CONFIG" > "$tmp_file" && mv "$tmp_file" "$SECURITY_CONFIG"

    echo -e "${C_RED}Path added to blocked list: $path${C_NC}"
}

# Get security statistics
# Usage: security_get_stats
security_get_stats() {
    _security_init_log

    local stats
    stats=$(jq '.statistics' "$SECURITY_LOG")

    echo -e "${C_CYAN}=== Security Gate Statistics ===${C_NC}"
    echo -e "Total Checks:  ${C_WHITE}$(echo "$stats" | jq -r '.total_checks')${C_NC}"
    echo -e "Allowed:       ${C_GREEN}$(echo "$stats" | jq -r '.allowed')${C_NC}"
    echo -e "Blocked:       ${C_RED}$(echo "$stats" | jq -r '.blocked')${C_NC}"
    echo ""
    echo -e "${C_WHITE}By Gate:${C_NC}"
    echo "$stats" | jq -r '.by_gate | to_entries[] | "  \(.key): \(.value)"'
}

# Get recent security events
# Usage: security_get_events [limit]
security_get_events() {
    local limit="${1:-20}"

    _security_init_log

    jq -r --argjson limit "$limit" '.events[-$limit:]' "$SECURITY_LOG"
}

# Check if agent is trusted
# Usage: security_is_trusted agent
security_is_trusted() {
    local agent="$1"

    local trusted_agents
    trusted_agents=$(_security_config_get "trusted_agents" "[]")

    if echo "$trusted_agents" | jq -e "index(\"$agent\")" &>/dev/null; then
        return 0
    fi

    return 1
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_security_gates_self_test() {
    echo -e "${C_CYAN}=== Security Gates Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    cat > "$HARMONY_DIR/local/security-gates.json" << 'EOF'
{
  "max_auto_level": 2,
  "allowed_paths": ["/tmp/"],
  "blocked_paths": ["/secret/"],
  "trusted_agents": ["developer"]
}
EOF

    local passed=0
    local failed=0

    # Test 1: Allow low-level operation
    echo -n "Test 1: Allow file_read... "
    if security_check_gate "file_read" "/tmp/test.txt" "developer" 2>/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Block high-level operation
    echo -n "Test 2: Block deploy... "
    if ! security_check_gate "deploy" "production" "developer" 2>/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Block system path
    echo -n "Test 3: Block /etc/ path... "
    if ! security_check_gate "file_write" "/etc/passwd" "developer" 2>/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Block dangerous command
    echo -n "Test 4: Block dangerous command... "
    if ! security_check_gate "command_execute" "rm -rf /" "developer" 2>/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Trusted agent check
    echo -n "Test 5: Trusted agent... "
    if security_is_trusted "developer"; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 6: Untrusted agent
    echo -n "Test 6: Untrusted agent... "
    if ! security_is_trusted "unknown_agent"; then
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
    _security_gates_self_test
    exit $?
fi
