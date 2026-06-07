#!/bin/bash
# =============================================================================
# Harmony Framework - Agent Mesh Networks
# =============================================================================
# Local agent networks for tactical execution while orchestrators handle
# strategic coordination. Hybrid approach for 2025-2026 best practices.
#
# Usage:
#   source "${HARMONY_DIR}/lib/mesh-network.sh"
#
#   # Create a mesh for a task
#   mesh_create "feature-implementation" "developer" "tester" "reviewer"
#
#   # Send message in mesh
#   mesh_send "developer" "Code complete, ready for review"
#
#   # Coordinate handoff
#   mesh_handoff "developer" "tester"
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${MESH_NETWORK_LOADED:-}" == "true" ]]; then
    return 0
fi
MESH_NETWORK_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

MESH_CONFIG="${HARMONY_DIR}/local/mesh-topology.json"
MESH_STATE="${HARMONY_DIR}/local/memory/mesh-state.json"

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

# Current mesh tracking
_MESH_CURRENT_ID=""
_MESH_CURRENT_AGENT=""

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

_mesh_generate_id() {
    echo "MESH-$(date +%s%N | sha256sum | head -c 8)"
}

_mesh_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

_mesh_init_state() {
    if [[ ! -f "$MESH_STATE" ]]; then
        mkdir -p "$(dirname "$MESH_STATE")"
        cp "${HARMONY_DIR}/templates/memory/mesh-state.template.json" "$MESH_STATE"
        local ts
        ts=$(_mesh_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"
    fi
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Create a new mesh network
# Usage: mesh_create name coordinator agents...
mesh_create() {
    local name="$1"
    local coordinator="$2"
    shift 2
    local agents=("$@")

    _mesh_init_state

    local mesh_id
    mesh_id=$(_mesh_generate_id)
    _MESH_CURRENT_ID="$mesh_id"

    local ts
    ts=$(_mesh_timestamp)

    # Create agents JSON array
    local agents_json
    agents_json=$(printf '%s\n' "${agents[@]}" | jq -R . | jq -s .)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$mesh_id" \
       --arg name "$name" \
       --arg coord "$coordinator" \
       --argjson agents "$agents_json" \
       --arg ts "$ts" \
       '.meshes[$id] = {
          "id": $id,
          "name": $name,
          "coordinator": $coord,
          "agents": $agents,
          "status": "active",
          "created": $ts,
          "messages": [],
          "handoffs": [],
          "current_agent": $coord
        } |
        .statistics.total_meshes += 1' \
        "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"

    echo -e "${C_GREEN}Mesh created: ${C_CYAN}$mesh_id${C_NC} ($name)" >&2
    echo -e "  Coordinator: ${C_WHITE}$coordinator${C_NC}" >&2
    echo -e "  Agents: ${C_WHITE}${agents[*]}${C_NC}" >&2

    echo "$mesh_id"
}

# Join an existing mesh
# Usage: mesh_join mesh_id agent
mesh_join() {
    local mesh_id="$1"
    local agent="$2"

    _mesh_init_state

    _MESH_CURRENT_ID="$mesh_id"
    _MESH_CURRENT_AGENT="$agent"

    local ts
    ts=$(_mesh_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$mesh_id" --arg agent "$agent" --arg ts "$ts" \
       'if .meshes[$id].agents | index($agent) then .
        else .meshes[$id].agents += [$agent]
        end |
        .meshes[$id].messages += [{
          "timestamp": $ts,
          "from": "system",
          "to": "all",
          "type": "join",
          "content": "\($agent) joined the mesh"
        }]' \
        "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"

    echo -e "${C_GREEN}$agent joined mesh $mesh_id${C_NC}"
}

# Send message within mesh
# Usage: mesh_send to content [mesh_id]
mesh_send() {
    local to="$1"
    local content="$2"
    local mesh_id="${3:-$_MESH_CURRENT_ID}"
    local from="${_MESH_CURRENT_AGENT:-system}"

    _mesh_init_state

    local ts
    ts=$(_mesh_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$mesh_id" \
       --arg from "$from" \
       --arg to "$to" \
       --arg content "$content" \
       --arg ts "$ts" \
       '.meshes[$id].messages += [{
          "timestamp": $ts,
          "from": $from,
          "to": $to,
          "type": "message",
          "content": $content
        }] |
        .statistics.total_messages += 1' \
        "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"
}

# Handoff between agents
# Usage: mesh_handoff from to [context]
mesh_handoff() {
    local from="$1"
    local to="$2"
    local context="${3:-}"
    local mesh_id="${_MESH_CURRENT_ID}"

    _mesh_init_state

    local ts
    ts=$(_mesh_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$mesh_id" \
       --arg from "$from" \
       --arg to "$to" \
       --arg context "$context" \
       --arg ts "$ts" \
       '.meshes[$id].handoffs += [{
          "timestamp": $ts,
          "from": $from,
          "to": $to,
          "context": $context
        }] |
        .meshes[$id].current_agent = $to |
        .statistics.total_handoffs += 1' \
        "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"

    echo -e "${C_CYAN}Handoff: ${C_WHITE}$from${C_NC} → ${C_WHITE}$to${C_NC}"
}

# Escalate to coordinator
# Usage: mesh_escalate reason
mesh_escalate() {
    local reason="$1"
    local mesh_id="${_MESH_CURRENT_ID}"
    local from="${_MESH_CURRENT_AGENT:-unknown}"

    _mesh_init_state

    local coordinator
    coordinator=$(jq -r --arg id "$mesh_id" '.meshes[$id].coordinator' "$MESH_STATE")

    local ts
    ts=$(_mesh_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$mesh_id" \
       --arg from "$from" \
       --arg to "$coordinator" \
       --arg reason "$reason" \
       --arg ts "$ts" \
       '.meshes[$id].messages += [{
          "timestamp": $ts,
          "from": $from,
          "to": $to,
          "type": "escalation",
          "content": $reason
        }] |
        .meshes[$id].current_agent = $to' \
        "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"

    echo -e "${C_YELLOW}Escalated to coordinator: $coordinator${C_NC}"
}

# Get mesh status
# Usage: mesh_status [mesh_id]
mesh_status() {
    local mesh_id="${1:-$_MESH_CURRENT_ID}"

    _mesh_init_state

    local mesh
    mesh=$(jq -r --arg id "$mesh_id" '.meshes[$id]' "$MESH_STATE")

    if [[ "$mesh" == "null" ]]; then
        echo -e "${C_RED}Mesh not found: $mesh_id${C_NC}"
        return 1
    fi

    echo -e "${C_CYAN}=== Mesh Status ===${C_NC}"
    echo -e "ID:          ${C_WHITE}$(echo "$mesh" | jq -r '.id')${C_NC}"
    echo -e "Name:        ${C_WHITE}$(echo "$mesh" | jq -r '.name')${C_NC}"
    echo -e "Status:      ${C_WHITE}$(echo "$mesh" | jq -r '.status')${C_NC}"
    echo -e "Coordinator: ${C_WHITE}$(echo "$mesh" | jq -r '.coordinator')${C_NC}"
    echo -e "Current:     ${C_WHITE}$(echo "$mesh" | jq -r '.current_agent')${C_NC}"
    echo -e "Agents:      ${C_WHITE}$(echo "$mesh" | jq -r '.agents | join(", ")')${C_NC}"
    echo -e "Messages:    ${C_WHITE}$(echo "$mesh" | jq '.messages | length')${C_NC}"
    echo -e "Handoffs:    ${C_WHITE}$(echo "$mesh" | jq '.handoffs | length')${C_NC}"
}

# Get mesh messages
# Usage: mesh_messages [limit] [mesh_id]
mesh_messages() {
    local limit="${1:-10}"
    local mesh_id="${2:-$_MESH_CURRENT_ID}"

    _mesh_init_state

    jq -r --arg id "$mesh_id" --argjson limit "$limit" \
        '.meshes[$id].messages[-$limit:]' "$MESH_STATE"
}

# Close mesh
# Usage: mesh_close [mesh_id]
mesh_close() {
    local mesh_id="${1:-$_MESH_CURRENT_ID}"

    _mesh_init_state

    local ts
    ts=$(_mesh_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$mesh_id" --arg ts "$ts" \
       '.meshes[$id].status = "closed" |
        .meshes[$id].closed = $ts' \
        "$MESH_STATE" > "$tmp_file" && mv "$tmp_file" "$MESH_STATE"

    echo -e "${C_GREEN}Mesh closed: $mesh_id${C_NC}"
    _MESH_CURRENT_ID=""
}

# Get mesh statistics
# Usage: mesh_get_stats
mesh_get_stats() {
    _mesh_init_state

    local stats
    stats=$(jq '.statistics' "$MESH_STATE")

    local active_count
    active_count=$(jq '[.meshes[] | select(.status == "active")] | length' "$MESH_STATE")

    echo -e "${C_CYAN}=== Mesh Network Statistics ===${C_NC}"
    echo -e "Total Meshes:   ${C_WHITE}$(echo "$stats" | jq -r '.total_meshes')${C_NC}"
    echo -e "Active Meshes:  ${C_GREEN}$active_count${C_NC}"
    echo -e "Total Messages: ${C_WHITE}$(echo "$stats" | jq -r '.total_messages')${C_NC}"
    echo -e "Total Handoffs: ${C_WHITE}$(echo "$stats" | jq -r '.total_handoffs')${C_NC}"
}

# List active meshes
# Usage: mesh_list
mesh_list() {
    _mesh_init_state

    echo -e "${C_CYAN}=== Active Meshes ===${C_NC}"
    jq -r '.meshes | to_entries[] | select(.value.status == "active") |
        "\(.value.id): \(.value.name) [\(.value.current_agent)]"' "$MESH_STATE"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_mesh_network_self_test() {
    echo -e "${C_CYAN}=== Mesh Network Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    local passed=0
    local failed=0

    # Test 1: Create mesh
    echo -n "Test 1: Create mesh... "
    local mesh_id
    mesh_id=$(mesh_create "test-mesh" "architect" "developer" "tester" 2>/dev/null)
    if [[ "$mesh_id" =~ ^MESH- ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Join mesh
    echo -n "Test 2: Join mesh... "
    _MESH_CURRENT_ID="$mesh_id"
    mesh_join "$mesh_id" "reviewer" &>/dev/null
    local agents
    agents=$(jq -r --arg id "$mesh_id" '.meshes[$id].agents | length' "$MESH_STATE")
    if (( agents >= 3 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Send message
    echo -n "Test 3: Send message... "
    _MESH_CURRENT_AGENT="developer"
    mesh_send "tester" "Ready for testing"
    local msg_count
    msg_count=$(jq -r --arg id "$mesh_id" '.meshes[$id].messages | length' "$MESH_STATE")
    if (( msg_count >= 1 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Handoff
    echo -n "Test 4: Handoff... "
    mesh_handoff "developer" "tester" "Code complete" &>/dev/null
    local current
    current=$(jq -r --arg id "$mesh_id" '.meshes[$id].current_agent' "$MESH_STATE")
    if [[ "$current" == "tester" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Status
    echo -n "Test 5: Status... "
    local status_output
    status_output=$(mesh_status "$mesh_id" 2>&1)
    if [[ "$status_output" == *"test-mesh"* ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 6: Close mesh
    echo -n "Test 6: Close mesh... "
    mesh_close "$mesh_id" &>/dev/null
    local status
    status=$(jq -r --arg id "$mesh_id" '.meshes[$id].status' "$MESH_STATE")
    if [[ "$status" == "closed" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Cleanup
    rm -rf "$test_dir"
    unset HARMONY_DIR
    _MESH_CURRENT_ID=""
    _MESH_CURRENT_AGENT=""

    echo ""
    echo -e "Results: ${C_GREEN}$passed passed${C_NC}, ${C_RED}$failed failed${C_NC}"

    [[ $failed -eq 0 ]]
}

if [[ "${1:-}" == "--test" ]]; then
    _mesh_network_self_test
    exit $?
fi
