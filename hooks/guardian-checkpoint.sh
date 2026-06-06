#!/bin/bash
#
# Guardian Checkpoint Hook
# Enforces story-based development in Harmony Framework
#
# Usage: Called by AI assistant before code modifications
# Arguments: $1 = tool_name, $2 = tool_input (JSON)
#

set -e

HARMONY_DIR=".harmony"
WORKFLOW_STATE="${HARMONY_DIR}/local/memory/workflow-state.json"
TOOL_NAME="${1:-unknown}"
TOOL_INPUT="${2:-{}}"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Extract file path from tool input
get_file_path() {
    echo "$TOOL_INPUT" | jq -r '.file_path // .path // ""' 2>/dev/null || echo ""
}

# Check if path is in allowed directories (safe from Guardian)
is_allowed_directory() {
    local file_path="$1"

    # Fixed paths that are always allowed (use grep -F for literal matching)
    local allowed_fixed=(
        ".harmony/"
        ".claude/"
        "node_modules/"
        ".git/"
    )

    for pattern in "${allowed_fixed[@]}"; do
        if echo "$file_path" | grep -qF "$pattern"; then
            return 0
        fi
    done

    # Regex patterns for allowed files
    local allowed_regex=(
        '\.md"?$'
        '\.json"?$'
        '\.yaml"?$'
        '\.yml"?$'
    )

    for pattern in "${allowed_regex[@]}"; do
        if echo "$file_path" | grep -qE "$pattern"; then
            return 0
        fi
    done

    return 1
}

# Check if Guardian is enabled
check_guardian_enabled() {
    if [[ ! -f "$WORKFLOW_STATE" ]]; then
        return 1  # If no state file, Guardian is disabled
    fi

    local enabled
    enabled=$(jq -r '.guardian.enabled // true' "$WORKFLOW_STATE" 2>/dev/null || echo "true")
    [[ "$enabled" == "true" ]]
}

# Get Guardian mode (warn or block)
get_guardian_mode() {
    if [[ ! -f "$WORKFLOW_STATE" ]]; then
        echo "warn"
        return
    fi

    jq -r '.guardian.mode // "warn"' "$WORKFLOW_STATE" 2>/dev/null || echo "warn"
}

# Check if there's an active story
check_active_story() {
    if [[ ! -f "$WORKFLOW_STATE" ]]; then
        return 1
    fi

    local story
    story=$(jq -r '.active_context.current_story // null' "$WORKFLOW_STATE" 2>/dev/null || echo "null")

    [[ "$story" != "null" && "$story" != "" ]]
}

# Get active story ID
get_active_story() {
    if [[ ! -f "$WORKFLOW_STATE" ]]; then
        echo ""
        return
    fi

    jq -r '.active_context.current_story // ""' "$WORKFLOW_STATE" 2>/dev/null || echo ""
}

# Print Guardian header
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🛡️  GUARDIAN CHECKPOINT${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Print warning message
print_warning() {
    local message="$1"
    echo ""
    print_header
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    echo ""
    echo -e "${YELLOW}$message${NC}"
    echo ""
    echo -e "Continuing in WARN mode..."
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Print violation message
print_violation() {
    local message="$1"
    echo ""
    print_header
    echo -e "${RED}🚫 VIOLATION${NC}"
    echo ""
    echo -e "${RED}$message${NC}"
    echo ""
    echo -e "${YELLOW}REQUIRED ACTIONS:${NC}"
    echo -e "1. Create or activate a story first"
    echo -e "2. Ensure UCV is approved (if required)"
    echo -e "3. Try again"
    echo ""
    echo -e "${YELLOW}COMMANDS:${NC}"
    echo -e '  "create story for [feature]"'
    echo -e '  "activate STORY-XXX"'
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Print success message
print_success() {
    local story="$1"
    echo -e "${GREEN}✅ Guardian: Active story ${story}${NC}"
}

# Main logic
main() {
    # Skip if not a modifying tool
    case "$TOOL_NAME" in
        Write|Edit|MultiEdit|Bash)
            ;;
        *)
            # Not a modifying tool, allow
            exit 0
            ;;
    esac

    # Get file path
    local file_path
    file_path=$(get_file_path)

    # Skip if no file path (e.g., bash command)
    if [[ -z "$file_path" ]] && [[ "$TOOL_NAME" != "Bash" ]]; then
        exit 0
    fi

    # For Bash, check if it's a code-modifying command
    if [[ "$TOOL_NAME" == "Bash" ]]; then
        # Allow most bash commands, only block obvious code creation
        local command
        command=$(echo "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null || echo "")

        # Skip git, npm, docker, test commands
        if echo "$command" | grep -qE "^(git|npm|npx|pnpm|yarn|docker|make|test|pytest|jest)"; then
            exit 0
        fi

        # Skip if not creating/editing files
        if ! echo "$command" | grep -qE "(cat.*>|echo.*>|sed -i|tee|touch.*\.(ts|js|tsx|jsx|py))"; then
            exit 0
        fi
    fi

    # Check if path is allowed (documentation, config, etc.)
    if [[ -n "$file_path" ]] && is_allowed_directory "$file_path"; then
        exit 0
    fi

    # Check if Guardian is enabled
    if ! check_guardian_enabled; then
        exit 0
    fi

    # Get mode
    local mode
    mode=$(get_guardian_mode)

    # Check for active story
    if check_active_story; then
        local story
        story=$(get_active_story)
        print_success "$story"
        exit 0
    fi

    # No active story - handle based on mode
    if [[ "$mode" == "block" ]]; then
        print_violation "Code modification without active story"
        exit 1
    else
        print_warning "No active story detected.\n\nRECOMMENDATION:\nCreate a story before implementing:\n  \"create story for [your feature]\""
        exit 0
    fi
}

main "$@"
