#!/bin/bash
#
# ARIA Context Detection Hook
# Automatic Runtime Intent Analyzer for Harmony Framework
#
# Triggers:
#   - Session start (via settings.json)
#   - Before start_story
#   - On /harmony context command
#
# Usage: bash aria-detect.sh "$TOOL_INPUT"
#   or: bash aria-detect.sh --detect "user request text"
#

set -e

# Must set HARMONY_DIR first, then derive paths
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi
FRAMEWORK_LIB="${HARMONY_DIR}/lib"
WORKFLOW_STATE="${HARMONY_DIR}/memory/workflow-state.json"
TOOL_INPUT="${1:-{}}"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# =============================================================================
# SOURCE DEPENDENCIES
# =============================================================================

source_libs() {
    if [[ -f "${FRAMEWORK_LIB}/aria-detector.sh" ]]; then
        source "${FRAMEWORK_LIB}/aria-detector.sh"
    else
        echo "[ARIA] ERROR: aria-detector.sh not found" >&2
        exit 1
    fi

    if [[ -f "${FRAMEWORK_LIB}/routing-parser.sh" ]]; then
        source "${FRAMEWORK_LIB}/routing-parser.sh"
    fi
}

# =============================================================================
# WORKFLOW STATE FUNCTIONS
# =============================================================================

# Update workflow-state.json with ARIA detection results
update_workflow_state() {
    local detection_result="$1"

    if [[ ! -f "$WORKFLOW_STATE" ]]; then
        echo "[ARIA] WARNING: workflow-state.json not found" >&2
        return 1
    fi

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Extract values from detection result
    local context_flags triggered_agents suggested_agent primary_intent confidence source is_blocking last_request
    context_flags=$(echo "$detection_result" | jq -c '.context_flags // []')
    triggered_agents=$(echo "$detection_result" | jq -c '.triggered_agents // []')
    suggested_agent=$(echo "$detection_result" | jq -r '.suggested_agent // null')
    primary_intent=$(echo "$detection_result" | jq -r '.primary_intent // null')
    confidence=$(echo "$detection_result" | jq -r '.confidence // 0')
    source=$(echo "$detection_result" | jq -r '.source // "pattern"')
    is_blocking=$(echo "$detection_result" | jq -r '.is_blocking // false')

    # Update aria_context
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg ts "$timestamp" \
       --argjson flags "$context_flags" \
       --argjson triggers "$triggered_agents" \
       --arg agent "$suggested_agent" \
       --arg intent "$primary_intent" \
       --argjson conf "$confidence" \
       --arg src "$source" \
       --argjson blocking "$is_blocking" \
       '.aria_context = {
           detected_at: $ts,
           context_flags: $flags,
           triggered_agents: $triggers,
           suggested_agent: $agent,
           primary_intent: $intent,
           confidence: $conf,
           source: $src,
           is_blocking: $blocking,
           last_request: null
       }' "$WORKFLOW_STATE" > "$tmp_file" && mv "$tmp_file" "$WORKFLOW_STATE"

    # Update project_context flags
    local flags_str
    flags_str=$(echo "$context_flags" | jq -r '.[]' | tr '\n' ' ')

    tmp_file=$(mktemp)
    jq --argjson has_ui "$(contains_flag "$flags_str" "has_ui")" \
       --argjson has_auth "$(contains_flag "$flags_str" "has_auth")" \
       --argjson personal_data "$(contains_flag "$flags_str" "personal_data")" \
       --argjson has_minors "$(contains_flag "$flags_str" "has_minors")" \
       --argjson has_media "$(contains_flag "$flags_str" "has_media")" \
       --argjson has_social "$(contains_flag "$flags_str" "has_social")" \
       --argjson security_critical "$(contains_flag "$flags_str" "security_critical")" \
       --argjson legal_compliance "$(contains_flag "$flags_str" "legal_compliance")" \
       --argjson has_db_schema "$(contains_flag "$flags_str" "has_db_schema")" \
       --argjson is_mobile "$(contains_flag "$flags_str" "is_mobile")" \
       --argjson is_web "$(contains_flag "$flags_str" "is_web")" \
       --argjson is_game "$(contains_flag "$flags_str" "is_game")" \
       --argjson is_api "$(contains_flag "$flags_str" "is_api")" \
       --argjson is_cli "$(contains_flag "$flags_str" "is_cli")" \
       --argjson needs_docs "$(contains_flag "$flags_str" "needs_docs")" \
       --argjson needs_prd "$(contains_flag "$flags_str" "needs_prd")" \
       '.project_context = {
           has_ui: $has_ui,
           has_auth: $has_auth,
           personal_data: $personal_data,
           has_minors: $has_minors,
           has_media: $has_media,
           has_social: $has_social,
           security_critical: $security_critical,
           legal_compliance: $legal_compliance,
           has_db_schema: $has_db_schema,
           is_mobile: $is_mobile,
           is_web: $is_web,
           is_game: $is_game,
           is_api: $is_api,
           is_cli: $is_cli,
           needs_docs: $needs_docs,
           needs_prd: $needs_prd
       }' "$WORKFLOW_STATE" > "$tmp_file" && mv "$tmp_file" "$WORKFLOW_STATE"
}

# Helper: check if flag is in list
contains_flag() {
    local flags="$1"
    local target="$2"
    if [[ " $flags " == *" $target "* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# =============================================================================
# OUTPUT FUNCTIONS
# =============================================================================

# Display compliance warnings
display_warnings() {
    local detection_result="$1"

    local is_blocking
    is_blocking=$(echo "$detection_result" | jq -r '.is_blocking')

    local triggered_agents
    triggered_agents=$(echo "$detection_result" | jq -r '.triggered_agents | join(", ")')

    local context_flags
    context_flags=$(echo "$detection_result" | jq -r '.context_flags | join(", ")')

    if [[ "$is_blocking" == "true" ]]; then
        echo ""
        echo -e "${RED}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${RED}${BOLD}│  🚨 ARIA: BLOCKING COMPLIANCE FLAGS DETECTED               │${NC}"
        echo -e "${RED}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo -e "${RED}Flags:${NC} $context_flags"
        echo -e "${RED}Required agents:${NC} $triggered_agents"
        echo ""
        echo -e "${YELLOW}Pipeline will include compliance validation before development.${NC}"
        echo ""
    elif [[ -n "$triggered_agents" ]] && [[ "$triggered_agents" != "null" ]]; then
        echo ""
        echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}${BOLD}│  ⚠️  ARIA: Compliance agents will be triggered             │${NC}"
        echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo -e "${CYAN}Flags:${NC} $context_flags"
        echo -e "${CYAN}Agents:${NC} $triggered_agents"
        echo ""
    else
        echo -e "${GREEN}[ARIA]${NC} Context analyzed: $context_flags"
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    # Handle --detect flag for explicit detection
    if [[ "${1:-}" == "--detect" ]]; then
        shift
        local request_text="$*"

        source_libs

        local result
        result=$(aria_detect_patterns "$request_text" ".")

        display_warnings "$result"
        update_workflow_state "$result"

        echo "$result"
        exit 0
    fi

    # Handle tool input from hook
    if [[ -n "$TOOL_INPUT" ]] && [[ "$TOOL_INPUT" != "{}" ]]; then
        # Extract text from tool input (could be file content or command)
        local text_to_analyze=""

        # Try to get content from common fields
        text_to_analyze=$(echo "$TOOL_INPUT" | jq -r '.content // .command // .file_path // .prompt // ""' 2>/dev/null)

        if [[ -z "$text_to_analyze" ]]; then
            # Use full input as text
            text_to_analyze="$TOOL_INPUT"
        fi

        source_libs

        local result
        result=$(aria_detect_patterns "$text_to_analyze" ".")

        # Only show warnings if significant flags detected
        local flag_count
        flag_count=$(echo "$result" | jq '.context_flags | length')

        if (( flag_count > 0 )); then
            display_warnings "$result"
            update_workflow_state "$result"
        fi
    fi

    exit 0
}

main "$@"
