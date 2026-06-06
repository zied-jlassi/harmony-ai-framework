#!/bin/bash
#
# Harmony Token Monitor
# Tracks estimated token usage per session
#
# Cross-platform: Linux, macOS, Windows (Git Bash/WSL)
#
# Usage: Called by AI assistant to track token consumption
# Arguments: $1 = event_type (load|unload|tool|dashboard), $2 = component, $3 = size_bytes
#

# NOTE: No 'set -e' to avoid arithmetic exit code issues (PAT-BASH-001)
# Each command handles its own errors explicitly

# Framework dir (fixed, read-only except local/)
HARMONY_DIR=".harmony"
# Runtime memory dir (ADR-010: user data in .harmony/local/memory/)
HARMONY_MEMORY_DIR=".harmony/local/memory"
TOKEN_LOG="${HARMONY_MEMORY_DIR}/token-usage.json"
# Historical logs dir (by day, with rotation)
LOGS_DIR="${HARMONY_DIR}/local/logs"
TODAY=$(date +%Y-%m-%d)
DAILY_LOG="${LOGS_DIR}/tokens-${TODAY}.json"
SESSION_ID="${HARMONY_SESSION_ID:-$(date +%Y%m%d_%H%M%S)}"

# Log rotation settings
MAX_LOG_SIZE_KB=1024  # 1MB max per file
MAX_LOG_FILES=8       # Keep 8 days of history

# Colors (portable)
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# Token estimation constants
CHARS_PER_TOKEN=4
TOKENS_WARNING_THRESHOLD=50000
TOKENS_CRITICAL_THRESHOLD=80000
TOKENS_MAX_RECOMMENDED=100000

# Cross-platform: Ensure jq is available
check_dependencies() {
    if ! command -v jq &>/dev/null; then
        echo -e "${RED}Error: jq is required but not installed${NC}" >&2
        echo "Install with: brew install jq (macOS) or apt install jq (Linux)" >&2
        return 1
    fi
    return 0
}

# Ensure directories exist (runtime dirs only)
ensure_dirs() {
    mkdir -p "${HARMONY_MEMORY_DIR}" 2>/dev/null || true
    mkdir -p "${LOGS_DIR}" 2>/dev/null || true
}

# Log rotation - remove old files if too many
rotate_logs() {
    local count
    count=$(find "${LOGS_DIR}" -name "tokens-*.json" 2>/dev/null | wc -l) || count=0

    if [[ $count -gt $MAX_LOG_FILES ]]; then
        # Remove oldest files
        find "${LOGS_DIR}" -name "tokens-*.json" -type f 2>/dev/null | \
            sort | head -n $((count - MAX_LOG_FILES)) | \
            xargs rm -f 2>/dev/null || true
        echo -e "${DIM}Log rotation: removed $((count - MAX_LOG_FILES)) old files${NC}"
    fi
}

# Append to daily log
append_daily_log() {
    local event_type="$1"
    local details="$2"
    local tokens="$3"
    local timestamp
    timestamp=$(get_timestamp)

    # Initialize daily log if needed
    if [[ ! -f "$DAILY_LOG" ]]; then
        cat > "$DAILY_LOG" << EOF
{
  "date": "${TODAY}",
  "events": []
}
EOF
    fi

    # Append event
    local temp_file
    temp_file=$(mktemp)

    if jq --arg ts "$timestamp" \
       --arg type "$event_type" \
       --arg details "$details" \
       --argjson tokens "$tokens" \
       '.events += [{timestamp: $ts, type: $type, details: $details, tokens: $tokens}]' \
       "$DAILY_LOG" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$DAILY_LOG"
    else
        rm -f "$temp_file" 2>/dev/null || true
    fi
}

# Initialize token log if needed
init_token_log() {
    if [[ ! -f "$TOKEN_LOG" ]]; then
        cat > "$TOKEN_LOG" << 'EOF'
{
  "version": "1.0",
  "sessions": {}
}
EOF
    fi
}

# Get current timestamp (portable - no %N)
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Estimate tokens from bytes
estimate_tokens() {
    local bytes="${1:-0}"
    echo $(( bytes / CHARS_PER_TOKEN ))
}

# Get current session data (with error handling)
get_session_tokens() {
    local result
    result=$(jq -r ".sessions[\"$SESSION_ID\"].total_tokens // 0" "$TOKEN_LOG" 2>/dev/null) || result="0"
    echo "$result"
}

# Initialize session if needed
init_session() {
    local timestamp
    timestamp=$(get_timestamp)

    local exists
    exists=$(jq -r ".sessions[\"$SESSION_ID\"] // empty" "$TOKEN_LOG" 2>/dev/null) || exists=""

    if [[ -z "$exists" ]]; then
        local temp_file
        temp_file=$(mktemp)

        if jq --arg sid "$SESSION_ID" --arg ts "$timestamp" \
            '.sessions[$sid] = {
                started_at: $ts,
                total_tokens: 0,
                components: {},
                tools: {},
                timeline: []
            }' "$TOKEN_LOG" > "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$TOKEN_LOG"
        else
            rm -f "$temp_file" 2>/dev/null || true
        fi
    fi
}

# Record component load
record_load() {
    local component="$1"
    local size_bytes="${2:-0}"
    local tokens
    tokens=$(estimate_tokens "$size_bytes")

    local timestamp
    timestamp=$(get_timestamp)

    local temp_file
    temp_file=$(mktemp)

    if jq --arg sid "$SESSION_ID" \
       --arg comp "$component" \
       --arg ts "$timestamp" \
       --argjson tokens "$tokens" \
       --argjson bytes "$size_bytes" \
       '.sessions[$sid].total_tokens = ((.sessions[$sid].total_tokens // 0) + $tokens) |
        .sessions[$sid].components[$comp] = {
            tokens: $tokens,
            bytes: $bytes,
            loaded_at: $ts
        } |
        .sessions[$sid].timeline = ((.sessions[$sid].timeline // []) + [{
            timestamp: $ts,
            event: "load",
            component: $comp,
            tokens: $tokens
        }])' "$TOKEN_LOG" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$TOKEN_LOG"
    else
        rm -f "$temp_file" 2>/dev/null || true
    fi

    echo "$tokens"
}

# Record tool usage
record_tool() {
    local tool_name="$1"
    local input_size="${2:-0}"
    local output_size="${3:-0}"

    local input_tokens
    input_tokens=$(estimate_tokens "$input_size")
    local output_tokens
    output_tokens=$(estimate_tokens "$output_size")
    local total_tokens=$((input_tokens + output_tokens))

    local timestamp
    timestamp=$(get_timestamp)

    local temp_file
    temp_file=$(mktemp)

    if jq --arg sid "$SESSION_ID" \
       --arg tool "$tool_name" \
       --arg ts "$timestamp" \
       --argjson in_tok "$input_tokens" \
       --argjson out_tok "$output_tokens" \
       --argjson total "$total_tokens" \
       '.sessions[$sid].total_tokens = ((.sessions[$sid].total_tokens // 0) + $total) |
        .sessions[$sid].tools[$tool].calls = ((.sessions[$sid].tools[$tool].calls // 0) + 1) |
        .sessions[$sid].tools[$tool].tokens = ((.sessions[$sid].tools[$tool].tokens // 0) + $total) |
        .sessions[$sid].timeline = ((.sessions[$sid].timeline // []) + [{
            timestamp: $ts,
            event: "tool",
            tool: $tool,
            input_tokens: $in_tok,
            output_tokens: $out_tok
        }])' "$TOKEN_LOG" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$TOKEN_LOG"
    else
        rm -f "$temp_file" 2>/dev/null || true
    fi

    echo "$total_tokens"
}

# Get status color based on usage
get_status_color() {
    local tokens="${1:-0}"

    if [[ $tokens -ge $TOKENS_CRITICAL_THRESHOLD ]]; then
        echo "$RED"
    elif [[ $tokens -ge $TOKENS_WARNING_THRESHOLD ]]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

# Get status emoji based on usage
get_status_emoji() {
    local tokens="${1:-0}"

    if [[ $tokens -ge $TOKENS_CRITICAL_THRESHOLD ]]; then
        echo "🔴"
    elif [[ $tokens -ge $TOKENS_WARNING_THRESHOLD ]]; then
        echo "🟡"
    else
        echo "🟢"
    fi
}

# Calculate percentage (avoid division by zero)
calc_percentage() {
    local current="${1:-0}"
    local max="${2:-1}"
    if [[ $max -eq 0 ]]; then
        max=1
    fi
    echo $(( (current * 100) / max ))
}

# Generate progress bar
progress_bar() {
    local current="${1:-0}"
    local max="${2:-100000}"
    local width=30

    local percentage
    percentage=$(calc_percentage "$current" "$max")

    # Clamp percentage to 100
    if [[ $percentage -gt 100 ]]; then
        percentage=100
    fi

    local filled=$(( (percentage * width) / 100 ))
    local empty=$(( width - filled ))

    local bar=""
    local color
    color=$(get_status_color "$current")

    # Build bar (portable loop - no ((i++)))
    local i=0
    while [[ $i -lt $filled ]]; do
        bar="${bar}█"
        i=$((i + 1))
    done
    i=0
    while [[ $i -lt $empty ]]; do
        bar="${bar}░"
        i=$((i + 1))
    done

    echo -e "${color}${bar}${NC} ${percentage}%"
}

# Display mini dashboard (inline)
display_mini() {
    local tokens
    tokens=$(get_session_tokens)
    local emoji
    emoji=$(get_status_emoji "$tokens")
    local color
    color=$(get_status_color "$tokens")

    echo -e "${DIM}${emoji} Tokens: ${color}${tokens}${NC}${DIM}/${TOKENS_MAX_RECOMMENDED}${NC}"
}

# Record agent activation
record_agent() {
    local agent_name="$1"
    local size_bytes="${2:-0}"
    local tokens
    tokens=$(estimate_tokens "$size_bytes")

    local timestamp
    timestamp=$(get_timestamp)

    local temp_file
    temp_file=$(mktemp)

    if jq --arg sid "$SESSION_ID" \
       --arg agent "$agent_name" \
       --arg ts "$timestamp" \
       --argjson tokens "$tokens" \
       '.sessions[$sid].total_tokens = ((.sessions[$sid].total_tokens // 0) + $tokens) |
        .sessions[$sid].agents[$agent].activations = ((.sessions[$sid].agents[$agent].activations // 0) + 1) |
        .sessions[$sid].agents[$agent].tokens = ((.sessions[$sid].agents[$agent].tokens // 0) + $tokens) |
        .sessions[$sid].agents[$agent].last_used = $ts |
        .sessions[$sid].timeline = ((.sessions[$sid].timeline // []) + [{
            timestamp: $ts,
            event: "agent",
            agent: $agent,
            tokens: $tokens
        }])' "$TOKEN_LOG" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$TOKEN_LOG"
    else
        rm -f "$temp_file" 2>/dev/null || true
    fi

    echo "$tokens"
}

# Record command/workflow usage
record_command() {
    local command_name="$1"
    local size_bytes="${2:-0}"
    local tokens
    tokens=$(estimate_tokens "$size_bytes")

    local timestamp
    timestamp=$(get_timestamp)

    local temp_file
    temp_file=$(mktemp)

    if jq --arg sid "$SESSION_ID" \
       --arg cmd "$command_name" \
       --arg ts "$timestamp" \
       --argjson tokens "$tokens" \
       '.sessions[$sid].total_tokens = ((.sessions[$sid].total_tokens // 0) + $tokens) |
        .sessions[$sid].commands[$cmd].calls = ((.sessions[$sid].commands[$cmd].calls // 0) + 1) |
        .sessions[$sid].commands[$cmd].tokens = ((.sessions[$sid].commands[$cmd].tokens // 0) + $tokens) |
        .sessions[$sid].timeline = ((.sessions[$sid].timeline // []) + [{
            timestamp: $ts,
            event: "command",
            command: $cmd,
            tokens: $tokens
        }])' "$TOKEN_LOG" > "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$TOKEN_LOG"
    else
        rm -f "$temp_file" 2>/dev/null || true
    fi

    echo "$tokens"
}

# Display full dashboard
display_dashboard() {
    local tokens
    tokens=$(get_session_tokens)

    local emoji
    emoji=$(get_status_emoji "$tokens")
    local color
    color=$(get_status_color "$tokens")

    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                   ${WHITE}🔢 HARMONY TOKEN MONITOR${NC}                               ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    printf "${CYAN}║${NC}  Session: ${DIM}%-60s${NC}  ${CYAN}║${NC}\n" "$SESSION_ID"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${emoji} Current Usage:                                                       ${CYAN}║${NC}"
    printf "${CYAN}║${NC}     %s                              ${CYAN}║${NC}\n" "$(progress_bar "$tokens" "$TOKENS_MAX_RECOMMENDED")"
    printf "${CYAN}║${NC}     ${color}%-8s${NC} / ${TOKENS_MAX_RECOMMENDED} tokens                                         ${CYAN}║${NC}\n" "$tokens"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"

    # Thresholds legend
    echo -e "${CYAN}║${NC}  Thresholds:                                                              ${CYAN}║${NC}"
    printf "${CYAN}║${NC}     ${GREEN}🟢 OK${NC}        < %-8s                                            ${CYAN}║${NC}\n" "$TOKENS_WARNING_THRESHOLD"
    printf "${CYAN}║${NC}     ${YELLOW}🟡 Warning${NC}  %-8s - %-8s                                    ${CYAN}║${NC}\n" "$TOKENS_WARNING_THRESHOLD" "$TOKENS_CRITICAL_THRESHOLD"
    printf "${CYAN}║${NC}     ${RED}🔴 Critical${NC} > %-8s                                            ${CYAN}║${NC}\n" "$TOKENS_CRITICAL_THRESHOLD"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    # AGENTS breakdown
    echo -e "${CYAN}║${NC}  ${MAGENTA}👤 AGENTS${NC}                                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}───────────────────────────────────────────────────────────────────${NC}  ${CYAN}║${NC}"

    local agents
    agents=$(jq -r ".sessions[\"$SESSION_ID\"].agents // {} | to_entries[] | \"\\(.key)|\\(.value.activations)|\\(.value.tokens)\"" "$TOKEN_LOG" 2>/dev/null) || agents=""

    if [[ -n "$agents" ]]; then
        printf "${CYAN}║${NC}     ${DIM}%-30s %10s %12s${NC}                ${CYAN}║${NC}\n" "Agent" "Activations" "Tokens"
        while IFS='|' read -r name activations tok; do
            printf "${CYAN}║${NC}     %-30s %10s %12s                ${CYAN}║${NC}\n" "$name" "$activations" "$tok"
        done <<< "$agents"
    else
        echo -e "${CYAN}║${NC}     ${DIM}No agents tracked yet${NC}                                              ${CYAN}║${NC}"
    fi

    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    # COMMANDS breakdown
    echo -e "${CYAN}║${NC}  ${BLUE}⚡ COMMANDS / WORKFLOWS${NC}                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}───────────────────────────────────────────────────────────────────${NC}  ${CYAN}║${NC}"

    local commands
    commands=$(jq -r ".sessions[\"$SESSION_ID\"].commands // {} | to_entries[] | \"\\(.key)|\\(.value.calls)|\\(.value.tokens)\"" "$TOKEN_LOG" 2>/dev/null) || commands=""

    if [[ -n "$commands" ]]; then
        printf "${CYAN}║${NC}     ${DIM}%-30s %10s %12s${NC}                ${CYAN}║${NC}\n" "Command" "Calls" "Tokens"
        while IFS='|' read -r name calls tok; do
            printf "${CYAN}║${NC}     %-30s %10s %12s                ${CYAN}║${NC}\n" "$name" "$calls" "$tok"
        done <<< "$commands"
    else
        echo -e "${CYAN}║${NC}     ${DIM}No commands tracked yet${NC}                                            ${CYAN}║${NC}"
    fi

    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    # COMPONENTS breakdown
    echo -e "${CYAN}║${NC}  ${GREEN}📦 COMPONENTS / FILES${NC}                                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}───────────────────────────────────────────────────────────────────${NC}  ${CYAN}║${NC}"

    local components
    components=$(jq -r ".sessions[\"$SESSION_ID\"].components // {} | to_entries[] | \"\\(.key)|\\(.value.bytes)|\\(.value.tokens)\"" "$TOKEN_LOG" 2>/dev/null) || components=""

    if [[ -n "$components" ]]; then
        printf "${CYAN}║${NC}     ${DIM}%-35s %8s %10s${NC}             ${CYAN}║${NC}\n" "Component" "Bytes" "Tokens"
        while IFS='|' read -r name bytes tok; do
            printf "${CYAN}║${NC}     %-35s %8s %10s             ${CYAN}║${NC}\n" "$name" "$bytes" "$tok"
        done <<< "$components"
    else
        echo -e "${CYAN}║${NC}     ${DIM}No components tracked yet${NC}                                          ${CYAN}║${NC}"
    fi

    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"

    # TOOLS breakdown
    echo -e "${CYAN}║${NC}  ${YELLOW}🔧 TOOLS${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}───────────────────────────────────────────────────────────────────${NC}  ${CYAN}║${NC}"

    local tools
    tools=$(jq -r ".sessions[\"$SESSION_ID\"].tools // {} | to_entries[] | \"\\(.key)|\\(.value.calls)|\\(.value.tokens)\"" "$TOKEN_LOG" 2>/dev/null) || tools=""

    if [[ -n "$tools" ]]; then
        printf "${CYAN}║${NC}     ${DIM}%-20s %10s %12s${NC}                        ${CYAN}║${NC}\n" "Tool" "Calls" "Tokens"
        while IFS='|' read -r name calls tok; do
            printf "${CYAN}║${NC}     %-20s %10s %12s                        ${CYAN}║${NC}\n" "$name" "$calls" "$tok"
        done <<< "$tools"
    else
        echo -e "${CYAN}║${NC}     ${DIM}No tools tracked yet${NC}                                               ${CYAN}║${NC}"
    fi

    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Recommendations
    if [[ $tokens -ge $TOKENS_CRITICAL_THRESHOLD ]]; then
        echo -e "${RED}⚠️  CRITICAL: Consider summarizing context or starting new session${NC}"
    elif [[ $tokens -ge $TOKENS_WARNING_THRESHOLD ]]; then
        echo -e "${YELLOW}⚠️  WARNING: Token usage is high. Monitor closely.${NC}"
    fi
}

# Export session report
export_report() {
    local report_file="${LOGS_DIR}/token-report-${SESSION_ID}.md"

    local tokens
    tokens=$(get_session_tokens)
    local timestamp
    timestamp=$(get_timestamp)

    local components_md
    components_md=$(jq -r ".sessions[\"$SESSION_ID\"].components | to_entries[] | \"- **\\(.key)**: \\(.value.tokens) tokens (\\(.value.bytes) bytes)\"" "$TOKEN_LOG" 2>/dev/null) || components_md="No components loaded"

    local tools_md
    tools_md=$(jq -r ".sessions[\"$SESSION_ID\"].tools | to_entries[] | \"- **\\(.key)**: \\(.value.calls) calls, \\(.value.tokens) tokens\"" "$TOKEN_LOG" 2>/dev/null) || tools_md="No tools used"

    local timeline_md
    timeline_md=$(jq -r ".sessions[\"$SESSION_ID\"].timeline[] | \"| \\(.timestamp) | \\(.event) | \\(.component // .tool // \"-\") | \\(.tokens // (.input_tokens + .output_tokens)) |\"" "$TOKEN_LOG" 2>/dev/null) || timeline_md="| - | - | - | - |"

    cat > "$report_file" << EOF
# Token Usage Report

**Session:** ${SESSION_ID}
**Generated:** ${timestamp}
**Total Tokens:** ${tokens}

## Components

${components_md}

## Tool Usage

${tools_md}

## Timeline

| Time | Event | Details | Tokens |
|------|-------|---------|--------|
${timeline_md}

---
*Generated by Harmony Token Monitor*
EOF

    echo "$report_file"
}

# Main logic
main() {
    local event_type="${1:-dashboard}"
    local component="${2:-}"
    local size="${3:-0}"

    # Check dependencies first
    if ! check_dependencies; then
        return 1
    fi

    ensure_dirs
    init_token_log
    init_session
    rotate_logs

    case "$event_type" in
        load)
            local tokens
            tokens=$(record_load "$component" "$size")
            append_daily_log "load" "$component" "$tokens"
            display_mini
            ;;
        tool)
            local output_size="${4:-0}"
            local tokens
            tokens=$(record_tool "$component" "$size" "$output_size")
            append_daily_log "tool" "$component" "$tokens"
            # Silent for tools, only show on dashboard
            ;;
        agent)
            local tokens
            tokens=$(record_agent "$component" "$size")
            append_daily_log "agent" "$component" "$tokens"
            display_mini
            ;;
        command|cmd)
            local tokens
            tokens=$(record_command "$component" "$size")
            append_daily_log "command" "$component" "$tokens"
            display_mini
            ;;
        dashboard|status)
            display_dashboard
            ;;
        mini)
            display_mini
            ;;
        report)
            local file
            file=$(export_report)
            echo "Report exported: $file"
            ;;
        reset)
            rm -f "$TOKEN_LOG" 2>/dev/null || true
            init_token_log
            init_session
            echo -e "${GREEN}✅ Token counter reset for session${NC}"
            ;;
        reset-all)
            rm -f "$TOKEN_LOG" 2>/dev/null || true
            rm -f "${LOGS_DIR}"/tokens-*.json 2>/dev/null || true
            init_token_log
            init_session
            echo -e "${GREEN}✅ All token logs reset${NC}"
            ;;
        history)
            echo -e "${CYAN}Token History (last 7 days):${NC}"
            echo ""
            for f in $(find "${LOGS_DIR}" -name "tokens-*.json" -type f 2>/dev/null | sort -r | head -7); do
                local day
                day=$(basename "$f" .json | sed 's/tokens-//')
                local count
                count=$(jq '.events | length' "$f" 2>/dev/null || echo "0")
                local total
                total=$(jq '[.events[].tokens] | add // 0' "$f" 2>/dev/null || echo "0")
                printf "  %s: %5d events, %8d tokens\n" "$day" "$count" "$total"
            done
            echo ""
            ;;
        help|--help|-h)
            echo ""
            echo -e "${WHITE}Harmony Token Monitor${NC}"
            echo ""
            echo "Usage: token-monitor.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  dashboard     Full dashboard with all breakdowns"
            echo "  mini          Inline compact display"
            echo "  history       Show last 7 days summary"
            echo "  report        Export markdown report"
            echo "  reset         Reset current session counter"
            echo "  reset-all     Reset all logs (session + history)"
            echo ""
            echo "Tracking:"
            echo "  load <name> <bytes>           Track component load"
            echo "  tool <name> <in> <out>        Track tool usage"
            echo "  agent <name> <bytes>          Track agent activation"
            echo "  command <name> <bytes>        Track command/workflow"
            echo ""
            ;;
        *)
            display_dashboard
            ;;
    esac
}

main "$@"
