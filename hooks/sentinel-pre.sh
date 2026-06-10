#!/bin/bash
#
# Sentinel Pre-Operation Hook
# Checks error history before risky operations
#
# Usage: Called by AI assistant before operations
# Input: Claude Code hook JSON on stdin (.tool_name, .tool_input)
#

set -e

HARMONY_DIR=".harmony"
ERROR_JOURNAL="${HARMONY_DIR}/local/memory/error-journal.json"
CIRCUIT_BREAKER="${HARMONY_DIR}/local/memory/circuit-breaker.json"
LEARNED_PATTERNS="${HARMONY_DIR}/local/memory/learned-patterns.json"

# Claude Code hook contract: event data arrives as JSON on stdin.
INPUT=$(cat 2>/dev/null || true)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null || echo '{}')

# Visible-status helper (proof the guard triggered)
[[ -f "${HARMONY_DIR}/lib/hook-ui.sh" ]] && source "${HARMONY_DIR}/lib/hook-ui.sh"
type hook_status &>/dev/null || hook_status() { :; }
type hook_debug  &>/dev/null || hook_debug()  { printf '%b\n' "$*" >&2; }

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Extract relevant info from tool input
get_file_path() {
    echo "$TOOL_INPUT" | jq -r '.file_path // .path // ""' 2>/dev/null || echo ""
}

get_command() {
    echo "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null || echo ""
}

# Check circuit breaker state
check_circuit_breaker() {
    if [[ ! -f "$CIRCUIT_BREAKER" ]]; then
        echo "CLOSED"
        return
    fi

    jq -r '.state // "CLOSED"' "$CIRCUIT_BREAKER" 2>/dev/null || echo "CLOSED"
}

# Get consecutive failures
get_failures() {
    if [[ ! -f "$CIRCUIT_BREAKER" ]]; then
        echo "0"
        return
    fi

    jq -r '.consecutive_failures // 0' "$CIRCUIT_BREAKER" 2>/dev/null || echo "0"
}

# Find similar past errors
find_similar_errors() {
    local file_path="$1"
    local command="$2"

    if [[ ! -f "$ERROR_JOURNAL" ]]; then
        return
    fi

    local errors=""

    # Search by file path
    if [[ -n "$file_path" ]]; then
        errors=$(jq -r --arg file "$file_path" \
            '[.errors[] | select(.context.file == $file)] | .[0:3] | .[] | "- \(.title): \(.prevention_rule)"' \
            "$ERROR_JOURNAL" 2>/dev/null || echo "")
    fi

    # Search by command keywords
    if [[ -n "$command" ]] && [[ -z "$errors" ]]; then
        # Extract keywords from command
        local keywords
        keywords=$(echo "$command" | grep -oE '\b(npm|prisma|docker|build|test|deploy)\b' | head -1)

        if [[ -n "$keywords" ]]; then
            errors=$(jq -r --arg kw "$keywords" \
                '[.errors[] | select(.tags[]? | contains($kw))] | .[0:3] | .[] | "- \(.title): \(.prevention_rule)"' \
                "$ERROR_JOURNAL" 2>/dev/null || echo "")
        fi
    fi

    echo "$errors"
}

# Find relevant patterns
find_relevant_patterns() {
    local file_path="$1"
    local command="$2"

    if [[ ! -f "$LEARNED_PATTERNS" ]]; then
        return
    fi

    local patterns=""

    # Search patterns by category
    if [[ -n "$file_path" ]]; then
        # Detect category from file extension
        local ext="${file_path##*.}"
        local category=""

        case "$ext" in
            ts|tsx) category="typescript" ;;
            js|jsx) category="javascript" ;;
            py) category="python" ;;
            sql) category="database" ;;
            sh|bash) category="bash-scripting" ;;
            docker*|Dockerfile) category="docker" ;;
        esac

        if [[ -n "$category" ]]; then
            patterns=$(jq -r --arg cat "$category" \
                '[.patterns[] | select(.category == $cat)] | .[0:2] | .[] | "💡 \(.trigger) → \(.action)"' \
                "$LEARNED_PATTERNS" 2>/dev/null || echo "")
        fi
    fi

    echo "$patterns"
}

# Detect bash context and show pitfalls
detect_bash_context() {
    local file_path="$1"
    local ext="${file_path##*.}"

    if [[ "$ext" == "sh" ]] || [[ "$ext" == "bash" ]]; then
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}🐚 BASH CONTEXT DETECTED${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  Quick reminders (set -e):${NC}"
        echo -e "   • ${RED}((var++))${NC} → ${GREEN}var=\$((var + 1))${NC}"
        echo -e "   • ${RED}grep pattern file${NC} → ${GREEN}grep pattern file || true${NC}"
        echo -e "${YELLOW}⚠️  macOS compatibility:${NC}"
        echo -e "   • ${RED}sha256sum${NC} → ${GREEN}shasum -a 256${NC}"
        echo -e "   • ${RED}readlink -f${NC} → ${GREEN}manual loop${NC}"
        echo -e "   • ${RED}sed -i 'cmd'${NC} → ${GREEN}sed -i'' 'cmd'${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
}

# Print circuit breaker warning
print_circuit_warning() {
    local state="$1"
    local failures="$2"

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🛡️  SENTINEL CHECK${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [[ "$state" == "OPEN" ]]; then
        echo -e "${RED}🛑 CIRCUIT BREAKER OPEN${NC}"
        echo ""
        echo -e "${RED}Too many consecutive failures detected.${NC}"
        echo -e "${RED}Diagnosis required before continuing.${NC}"
        echo ""
        echo -e "${YELLOW}ACTIONS:${NC}"
        echo -e "1. Review error journal: \${MEMORY_DIR}/error-journal.json"
        echo -e "2. Fix the root cause"
        echo -e "3. Reset circuit: npx harmony sentinel reset"
        echo ""
    elif [[ "$state" == "HALF_OPEN" ]]; then
        echo -e "${YELLOW}⚠️  CIRCUIT BREAKER HALF-OPEN${NC}"
        echo ""
        echo -e "${YELLOW}Testing recovery. One operation allowed.${NC}"
        echo ""
    else
        echo -e "${CYAN}Circuit: CLOSED (${failures}/3 failures)${NC}"
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Print error history warning
print_error_history() {
    local errors="$1"
    local patterns="$2"

    if [[ -z "$errors" ]] && [[ -z "$patterns" ]]; then
        return
    fi

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🛡️  SENTINEL MEMORY${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [[ -n "$errors" ]]; then
        echo -e "${YELLOW}⚠️  Past errors for this context:${NC}"
        echo "$errors"
        echo ""
    fi

    if [[ -n "$patterns" ]]; then
        echo -e "${CYAN}Learned patterns:${NC}"
        echo "$patterns"
        echo ""
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Main logic
main() {
    # Check circuit breaker state
    local state
    state=$(check_circuit_breaker)

    local failures
    failures=$(get_failures)

    # If circuit is OPEN, block (exit 2 per hook contract; reason on stderr).
    if [[ "$state" == "OPEN" ]]; then
        print_circuit_warning "$state" "$failures" >&2
        exit 2
    fi

    # All decorative/debug output → stderr (keeps stdout JSON-clean for systemMessage)
    {
        if [[ "$failures" -gt 0 ]]; then
            print_circuit_warning "$state" "$failures"
        fi

        local file_path command errors patterns
        file_path=$(get_file_path)
        command=$(get_command)
        errors=$(find_similar_errors "$file_path" "$command")
        patterns=$(find_relevant_patterns "$file_path" "$command")

        if [[ -n "$errors" ]] || [[ -n "$patterns" ]]; then
            print_error_history "$errors" "$patterns"
        fi
        if [[ -n "$file_path" ]]; then
            detect_bash_context "$file_path"
        fi
    } >&2

    # User-visible proof: circuit status on EVERY run (stdout JSON systemMessage)
    local mark=""
    [[ "$failures" -gt 0 ]] && mark=" ⚠️"
    hook_status "🧠 Sentinel: circuit ${state} (${failures}/3 failures)${mark}"
    exit 0
}

main "$@"
