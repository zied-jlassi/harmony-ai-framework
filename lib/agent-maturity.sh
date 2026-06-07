#!/bin/bash
# =============================================================================
# Harmony Framework - Agent Maturity Levels (L1-L4)
# =============================================================================
# A maturity model tracking agent capability levels, from basic (L1) to
# self-optimizing (L4). Based on Agentic AI Maturity Model research.
#
# Levels:
#   L1 - Basic: Single-task execution
#   L2 - Coordinated: Multi-agent collaboration
#   L3 - Autonomous: Self-correction capability
#   L4 - Self-Optimizing: Continuous improvement
#
# Usage:
#   source "${HARMONY_DIR}/lib/agent-maturity.sh"
#
#   # Get agent maturity level
#   level=$(maturity_get_level "developer")
#
#   # Record capability
#   maturity_record_capability "developer" "self_correction"
#
#   # Check if agent can perform action
#   if maturity_can_perform "developer" "autonomous_decision"; then
#       ...
#   fi
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${AGENT_MATURITY_LOADED:-}" == "true" ]]; then
    return 0
fi
AGENT_MATURITY_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

MATURITY_CONFIG="${HARMONY_DIR}/local/maturity-config.json"
MATURITY_SCORES="${HARMONY_DIR}/local/memory/maturity-scores.json"

# Colors
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_BLUE='\033[0;34m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# Source date utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/date_utils.sh" ]]; then
    source "${SCRIPT_DIR}/date_utils.sh"
fi

# Maturity level definitions
declare -A MATURITY_LEVELS=(
    [1]="L1_BASIC"
    [2]="L2_COORDINATED"
    [3]="L3_AUTONOMOUS"
    [4]="L4_SELF_OPTIMIZING"
)

declare -A LEVEL_NAMES=(
    ["L1_BASIC"]="Basic"
    ["L2_COORDINATED"]="Coordinated"
    ["L3_AUTONOMOUS"]="Autonomous"
    ["L4_SELF_OPTIMIZING"]="Self-Optimizing"
)

# Capabilities by level
declare -A LEVEL_CAPABILITIES=(
    ["L1_BASIC"]="task_execution,follow_instructions,basic_output"
    ["L2_COORDINATED"]="multi_agent_collaboration,handoff,shared_context,delegation"
    ["L3_AUTONOMOUS"]="self_correction,error_recovery,adaptive_planning,decision_making"
    ["L4_SELF_OPTIMIZING"]="continuous_improvement,meta_learning,self_evaluation,prompt_evolution"
)

# KPIs by level
declare -A LEVEL_KPIS=(
    ["L1_BASIC"]="task_completion_rate"
    ["L2_COORDINATED"]="collaboration_success_rate,handoff_accuracy"
    ["L3_AUTONOMOUS"]="self_correction_rate,error_recovery_rate"
    ["L4_SELF_OPTIMIZING"]="improvement_rate,optimization_score"
)

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

# Get ISO timestamp
_maturity_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

# Initialize scores file
_maturity_init_scores() {
    if [[ ! -f "$MATURITY_SCORES" ]]; then
        mkdir -p "$(dirname "$MATURITY_SCORES")"
        cp "${HARMONY_DIR}/templates/memory/maturity-scores.template.json" "$MATURITY_SCORES"
        local ts
        ts=$(_maturity_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"
    fi
}

# Load config value
_maturity_config_get() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "$MATURITY_CONFIG" ]]; then
        local value
        value=$(jq -r ".$key // empty" "$MATURITY_CONFIG" 2>/dev/null)
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
            return
        fi
    fi
    echo "$default"
}

# Initialize agent if not exists
_maturity_init_agent() {
    local agent="$1"

    _maturity_init_scores

    local exists
    exists=$(jq -r --arg agent "$agent" '.agents[$agent] // empty' "$MATURITY_SCORES")

    if [[ -z "$exists" || "$exists" == "null" ]]; then
        local ts
        ts=$(_maturity_timestamp)

        local tmp_file
        tmp_file=$(mktemp)
        jq --arg agent "$agent" --arg ts "$ts" \
           '.agents[$agent] = {
              "current_level": "L1_BASIC",
              "level_number": 1,
              "capabilities": [],
              "kpis": {},
              "assessment_history": [],
              "created": $ts,
              "last_updated": $ts
            }' "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"
    fi
}

# Calculate level from capabilities
_maturity_calculate_level() {
    local agent="$1"

    _maturity_init_agent "$agent"

    local capabilities
    capabilities=$(jq -r --arg agent "$agent" '.agents[$agent].capabilities | join(",")' "$MATURITY_SCORES")

    local level=1

    # Check L2 capabilities
    local l2_caps="${LEVEL_CAPABILITIES[L2_COORDINATED]}"
    local l2_count=0
    local l2_required=0
    IFS=',' read -ra l2_arr <<< "$l2_caps"
    for cap in "${l2_arr[@]}"; do
        ((l2_required++))
        if [[ "$capabilities" == *"$cap"* ]]; then
            ((l2_count++))
        fi
    done
    if (( l2_count >= l2_required / 2 )); then
        level=2
    fi

    # Check L3 capabilities
    local l3_caps="${LEVEL_CAPABILITIES[L3_AUTONOMOUS]}"
    local l3_count=0
    local l3_required=0
    IFS=',' read -ra l3_arr <<< "$l3_caps"
    for cap in "${l3_arr[@]}"; do
        ((l3_required++))
        if [[ "$capabilities" == *"$cap"* ]]; then
            ((l3_count++))
        fi
    done
    if (( level >= 2 && l3_count >= l3_required / 2 )); then
        level=3
    fi

    # Check L4 capabilities
    local l4_caps="${LEVEL_CAPABILITIES[L4_SELF_OPTIMIZING]}"
    local l4_count=0
    local l4_required=0
    IFS=',' read -ra l4_arr <<< "$l4_caps"
    for cap in "${l4_arr[@]}"; do
        ((l4_required++))
        if [[ "$capabilities" == *"$cap"* ]]; then
            ((l4_count++))
        fi
    done
    if (( level >= 3 && l4_count >= l4_required / 2 )); then
        level=4
    fi

    echo "$level"
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Get agent maturity level
# Usage: maturity_get_level agent
maturity_get_level() {
    local agent="$1"

    _maturity_init_agent "$agent"

    jq -r --arg agent "$agent" '.agents[$agent].current_level' "$MATURITY_SCORES"
}

# Get level number (1-4)
# Usage: maturity_get_level_number agent
maturity_get_level_number() {
    local agent="$1"

    _maturity_init_agent "$agent"

    jq -r --arg agent "$agent" '.agents[$agent].level_number' "$MATURITY_SCORES"
}

# Record a capability for an agent
# Usage: maturity_record_capability agent capability
maturity_record_capability() {
    local agent="$1"
    local capability="$2"

    _maturity_init_agent "$agent"

    local ts
    ts=$(_maturity_timestamp)

    # Add capability if not exists
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg agent "$agent" --arg cap "$capability" --arg ts "$ts" \
       'if (.agents[$agent].capabilities | index($cap)) then .
        else .agents[$agent].capabilities += [$cap] |
             .agents[$agent].last_updated = $ts
        end' "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"

    # Recalculate level
    local new_level
    new_level=$(_maturity_calculate_level "$agent")

    local level_name="${MATURITY_LEVELS[$new_level]}"

    tmp_file=$(mktemp)
    jq --arg agent "$agent" --arg level "$level_name" --argjson num "$new_level" \
       '.agents[$agent].current_level = $level |
        .agents[$agent].level_number = $num' \
        "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"

    echo "$level_name"
}

# Record KPI value
# Usage: maturity_record_kpi agent kpi_name value
maturity_record_kpi() {
    local agent="$1"
    local kpi_name="$2"
    local value="$3"

    _maturity_init_agent "$agent"

    local ts
    ts=$(_maturity_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg agent "$agent" --arg kpi "$kpi_name" --argjson val "$value" --arg ts "$ts" \
       '.agents[$agent].kpis[$kpi] = {
          "value": $val,
          "updated": $ts
        } |
        .agents[$agent].last_updated = $ts' \
        "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"
}

# Check if agent can perform an action
# Usage: maturity_can_perform agent capability
# Returns: 0 if can, 1 if cannot
maturity_can_perform() {
    local agent="$1"
    local capability="$2"

    _maturity_init_agent "$agent"

    local capabilities
    capabilities=$(jq -r --arg agent "$agent" '.agents[$agent].capabilities | join(",")' "$MATURITY_SCORES")

    if [[ "$capabilities" == *"$capability"* ]]; then
        return 0
    fi

    # Check if it's a base capability for their level
    local level
    level=$(maturity_get_level "$agent")

    local level_caps="${LEVEL_CAPABILITIES[$level]:-}"
    if [[ "$level_caps" == *"$capability"* ]]; then
        return 0
    fi

    return 1
}

# Assess agent maturity
# Usage: maturity_assess agent
maturity_assess() {
    local agent="$1"

    _maturity_init_agent "$agent"

    local ts
    ts=$(_maturity_timestamp)

    # Calculate current level
    local level_num
    level_num=$(_maturity_calculate_level "$agent")

    local level_name="${MATURITY_LEVELS[$level_num]}"

    # Get capabilities
    local capabilities
    capabilities=$(jq -r --arg agent "$agent" '.agents[$agent].capabilities' "$MATURITY_SCORES")

    # Get KPIs
    local kpis
    kpis=$(jq -r --arg agent "$agent" '.agents[$agent].kpis' "$MATURITY_SCORES")

    # Update assessment history
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg agent "$agent" --arg level "$level_name" --argjson num "$level_num" --arg ts "$ts" \
       '.agents[$agent].assessment_history += [{
          "timestamp": $ts,
          "level": $level,
          "level_number": $num
        }] |
        .agents[$agent].current_level = $level |
        .agents[$agent].level_number = $num |
        .agents[$agent].last_updated = $ts |
        .global_stats.total_assessments += 1' \
        "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"

    # Output assessment
    echo -e "${C_CYAN}=== Agent Maturity Assessment ===${C_NC}"
    echo -e "Agent:        ${C_WHITE}$agent${C_NC}"
    echo -e "Level:        ${C_WHITE}$level_name${C_NC} (${LEVEL_NAMES[$level_name]})"
    echo -e "Capabilities: ${C_WHITE}$(echo "$capabilities" | jq -r 'join(", ")')${C_NC}"
    echo ""

    # Show level-specific info
    case "$level_name" in
        "L1_BASIC")
            echo -e "${C_YELLOW}Next Level Requirements (L2 - Coordinated):${C_NC}"
            echo "  - Multi-agent collaboration"
            echo "  - Handoff capability"
            echo "  - Shared context management"
            ;;
        "L2_COORDINATED")
            echo -e "${C_YELLOW}Next Level Requirements (L3 - Autonomous):${C_NC}"
            echo "  - Self-correction capability"
            echo "  - Error recovery"
            echo "  - Adaptive planning"
            ;;
        "L3_AUTONOMOUS")
            echo -e "${C_YELLOW}Next Level Requirements (L4 - Self-Optimizing):${C_NC}"
            echo "  - Continuous improvement"
            echo "  - Meta-learning"
            echo "  - Self-evaluation"
            ;;
        "L4_SELF_OPTIMIZING")
            echo -e "${C_GREEN}Maximum maturity level achieved!${C_NC}"
            ;;
    esac

    echo "$level_name"
}

# Get capabilities for a level
# Usage: maturity_get_level_capabilities level
maturity_get_level_capabilities() {
    local level="$1"

    echo "${LEVEL_CAPABILITIES[$level]:-}" | tr ',' '\n'
}

# Get required KPIs for a level
# Usage: maturity_get_level_kpis level
maturity_get_level_kpis() {
    local level="$1"

    echo "${LEVEL_KPIS[$level]:-}" | tr ',' '\n'
}

# List all agents with their levels
# Usage: maturity_list_agents
maturity_list_agents() {
    _maturity_init_scores

    echo -e "${C_CYAN}=== Agent Maturity Levels ===${C_NC}"
    echo ""

    jq -r '.agents | to_entries[] |
        "\(.key): \(.value.current_level) (\(.value.capabilities | length) capabilities)"' \
        "$MATURITY_SCORES"
}

# Get maturity statistics
# Usage: maturity_get_stats
maturity_get_stats() {
    _maturity_init_scores

    local stats
    stats=$(jq '.global_stats' "$MATURITY_SCORES")

    local agent_count
    agent_count=$(jq '.agents | length' "$MATURITY_SCORES")

    echo -e "${C_CYAN}=== Maturity Statistics ===${C_NC}"
    echo -e "Total Agents:      ${C_WHITE}$agent_count${C_NC}"
    echo -e "Total Assessments: ${C_WHITE}$(echo "$stats" | jq -r '.total_assessments')${C_NC}"
    echo ""
    echo -e "${C_WHITE}Level Distribution:${C_NC}"

    # Count agents at each level
    for level in "${MATURITY_LEVELS[@]}"; do
        local count
        count=$(jq -r --arg level "$level" '[.agents[] | select(.current_level == $level)] | length' "$MATURITY_SCORES")
        local bar=""
        for ((i=0; i<count; i++)); do
            bar+="█"
        done
        printf "  %-20s %s (%d)\n" "${LEVEL_NAMES[$level]}" "$bar" "$count"
    done
}

# Promote agent to next level (if eligible)
# Usage: maturity_promote agent
maturity_promote() {
    local agent="$1"

    _maturity_init_agent "$agent"

    local current_level
    current_level=$(maturity_get_level_number "$agent")

    if (( current_level >= 4 )); then
        echo -e "${C_YELLOW}Agent already at maximum level (L4)${C_NC}"
        return 1
    fi

    local next_level=$((current_level + 1))
    local next_level_name="${MATURITY_LEVELS[$next_level]}"

    # Check if agent has required capabilities
    local required_caps="${LEVEL_CAPABILITIES[$next_level_name]}"
    local capabilities
    capabilities=$(jq -r --arg agent "$agent" '.agents[$agent].capabilities | join(",")' "$MATURITY_SCORES")

    local has_all=true
    local missing=()

    IFS=',' read -ra req_arr <<< "$required_caps"
    for cap in "${req_arr[@]}"; do
        if [[ "$capabilities" != *"$cap"* ]]; then
            has_all=false
            missing+=("$cap")
        fi
    done

    if [[ "$has_all" == "false" ]]; then
        echo -e "${C_RED}Cannot promote: Missing capabilities${C_NC}"
        echo "Required: ${missing[*]}"
        return 1
    fi

    local ts
    ts=$(_maturity_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg agent "$agent" --arg level "$next_level_name" --argjson num "$next_level" --arg ts "$ts" \
       '.agents[$agent].current_level = $level |
        .agents[$agent].level_number = $num |
        .agents[$agent].last_updated = $ts |
        .agents[$agent].assessment_history += [{
          "timestamp": $ts,
          "level": $level,
          "level_number": $num,
          "action": "promoted"
        }]' \
        "$MATURITY_SCORES" > "$tmp_file" && mv "$tmp_file" "$MATURITY_SCORES"

    echo -e "${C_GREEN}Agent promoted to $next_level_name${C_NC}"
}

# Display level badge
# Usage: maturity_display_badge agent
maturity_display_badge() {
    local agent="$1"

    _maturity_init_agent "$agent"

    local level
    level=$(maturity_get_level "$agent")

    local color
    case "$level" in
        "L1_BASIC") color="$C_WHITE" ;;
        "L2_COORDINATED") color="$C_BLUE" ;;
        "L3_AUTONOMOUS") color="$C_YELLOW" ;;
        "L4_SELF_OPTIMIZING") color="$C_GREEN" ;;
        *) color="$C_NC" ;;
    esac

    echo -e "${color}[$level]${C_NC} $agent"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_agent_maturity_self_test() {
    echo -e "${C_CYAN}=== Agent Maturity Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    # Create minimal config
    cat > "$HARMONY_DIR/local/maturity-config.json" << 'EOF'
{
  "auto_assess": true,
  "assessment_interval": 10
}
EOF

    local passed=0
    local failed=0

    # Test 1: Get initial level (L1)
    echo -n "Test 1: Initial level is L1... "
    local level
    level=$(maturity_get_level "test_agent")
    if [[ "$level" == "L1_BASIC" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $level)"
        ((failed++))
    fi

    # Test 2: Record capability
    echo -n "Test 2: Record capability... "
    maturity_record_capability "test_agent" "task_execution" >/dev/null
    local caps
    caps=$(jq -r '.agents.test_agent.capabilities | length' "$MATURITY_SCORES")
    if (( caps >= 1 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Can perform capability
    echo -n "Test 3: Can perform recorded capability... "
    if maturity_can_perform "test_agent" "task_execution"; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Cannot perform unrecorded capability
    echo -n "Test 4: Cannot perform unrecorded capability... "
    if ! maturity_can_perform "test_agent" "meta_learning"; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Record L2 capabilities and level up
    echo -n "Test 5: Level up to L2... "
    maturity_record_capability "test_agent" "multi_agent_collaboration" >/dev/null
    maturity_record_capability "test_agent" "handoff" >/dev/null
    maturity_record_capability "test_agent" "shared_context" >/dev/null
    level=$(maturity_get_level "test_agent")
    if [[ "$level" == "L2_COORDINATED" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $level)"
        ((failed++))
    fi

    # Test 6: Record KPI
    echo -n "Test 6: Record KPI... "
    maturity_record_kpi "test_agent" "task_completion_rate" 95
    local kpi_val
    kpi_val=$(jq -r '.agents.test_agent.kpis.task_completion_rate.value' "$MATURITY_SCORES")
    if [[ "$kpi_val" == "95" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 7: Level number
    echo -n "Test 7: Level number... "
    local level_num
    level_num=$(maturity_get_level_number "test_agent")
    if [[ "$level_num" == "2" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $level_num)"
        ((failed++))
    fi

    # Test 8: Assess agent
    echo -n "Test 8: Assess agent... "
    local assessment
    assessment=$(maturity_assess "test_agent" 2>&1)
    if [[ "$assessment" == *"L2_COORDINATED"* ]]; then
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

# Run self-test if called with --test
if [[ "${1:-}" == "--test" ]]; then
    _agent_maturity_self_test
    exit $?
fi
