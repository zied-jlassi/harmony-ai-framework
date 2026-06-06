#!/bin/bash
# ============================================================================
# Harmony Framework - Pre-Compacting Warning Hook
# ============================================================================
# This hook warns the user when approaching context limits during analysis
# sessions, giving them a chance to save important research/insights.
#
# Features:
#   - Detects analysis mode (architecture, research, comparison)
#   - Auto-saves to /tmp before warning (safety net)
#   - Offers options: save to research/, continue, ignore
#   - Integrates with analysis-tracker.sh for continuity
#
# Triggers on: user_prompt_submit (via Claude Code hooks)
# ============================================================================

set -euo pipefail

# Configuration
HARMONY_DIR="${HARMONY_DIR:-.harmony}"
SESSION_FILE="${HARMONY_DIR}/local/memory/session-tracker.json"
ANALYSIS_DIR="${HARMONY_DIR}/local/tmp/sessions"  # Project-specific
WARNING_THRESHOLD_MESSAGES=50
WARNING_THRESHOLD_MINUTES=45
AUTO_SAVE_INTERVAL_MESSAGES=10
MAX_SESSIONS_WARNING=4      # Alert when reaching this many sessions
ANALYSIS_KEYWORDS="analyse|analysis|research|compare|benchmark|study|evaluate|architecture|design|trade-off|decision|adr|investigation|decide|choisir|comparer"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================================
# Session Tracking
# ============================================================================

init_session_tracker() {
    local now=$(date +%s)

    if [[ ! -f "$SESSION_FILE" ]]; then
        mkdir -p "$(dirname "$SESSION_FILE")"
        cat > "$SESSION_FILE" << EOF
{
    "session_start": $now,
    "message_count": 0,
    "analysis_mode": false,
    "analysis_topics": [],
    "analysis_session_id": null,
    "last_warning": 0,
    "last_auto_save": 0,
    "warnings_shown": 0,
    "auto_save_count": 0
}
EOF
    fi
}

get_session_value() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "$SESSION_FILE" ]] && command -v jq &>/dev/null; then
        jq -r ".$key // \"$default\"" "$SESSION_FILE" 2>/dev/null || echo "$default"
    else
        echo "$default"
    fi
}

update_session() {
    local key="$1"
    local value="$2"

    if [[ -f "$SESSION_FILE" ]] && command -v jq &>/dev/null; then
        local tmp=$(mktemp)
        jq ".$key = $value" "$SESSION_FILE" > "$tmp" && mv "$tmp" "$SESSION_FILE"
    fi
}

increment_message_count() {
    if [[ -f "$SESSION_FILE" ]] && command -v jq &>/dev/null; then
        local tmp=$(mktemp)
        jq ".message_count += 1" "$SESSION_FILE" > "$tmp" && mv "$tmp" "$SESSION_FILE"
    fi
}

# ============================================================================
# Analysis Detection
# ============================================================================

detect_analysis_mode() {
    local user_input="$1"
    local input_lower=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

    if echo "$input_lower" | grep -qiE "$ANALYSIS_KEYWORDS"; then
        return 0
    fi

    return 1
}

extract_analysis_topic() {
    local user_input="$1"

    # Extract key topic from input (first 50 chars, cleaned)
    echo "$user_input" | head -c 50 | tr -d '\n"' | sed 's/[^a-zA-Z0-9 éèàùâêîôûç-]//g'
}

add_analysis_topic() {
    local topic="$1"

    if [[ -f "$SESSION_FILE" ]] && command -v jq &>/dev/null; then
        local tmp=$(mktemp)
        jq --arg topic "$topic" '.analysis_topics += [$topic] | .analysis_topics = (.analysis_topics | unique | .[-5:])' "$SESSION_FILE" > "$tmp" && mv "$tmp" "$SESSION_FILE"
    fi
}

# ============================================================================
# /clear Detection - Clears all sessions when user triggers /clear
# ============================================================================

detect_clear_command() {
    local user_input="$1"

    # Detect /clear command (Claude Code's built-in)
    if echo "$user_input" | grep -qE '^/clear$|^/clear\s'; then
        return 0
    fi

    return 1
}

clear_all_sessions() {
    # Clear session tracker
    if [[ -f "$SESSION_FILE" ]]; then
        rm -f "$SESSION_FILE"
    fi

    # Clear all saved sessions
    if [[ -d "$ANALYSIS_DIR" ]]; then
        rm -rf "$ANALYSIS_DIR"/*
        echo -e "${CYAN}[Harmony] Sessions effacées avec /clear${NC}" >&2
    fi

    # Re-initialize fresh tracker
    init_session_tracker
}

# ============================================================================
# Auto-Save Integration
# ============================================================================

perform_auto_save() {
    local message_count="$1"

    mkdir -p "$ANALYSIS_DIR"

    local session_id=$(get_session_value "analysis_session_id" "")

    if [[ -z "$session_id" || "$session_id" == "null" ]]; then
        # Create new session
        session_id=$(date +%s | sha256sum | head -c 8)
        update_session "analysis_session_id" "\"$session_id\""
    fi

    local session_dir="$ANALYSIS_DIR/$session_id"
    mkdir -p "$session_dir"

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    local topics=$(get_session_value "analysis_topics" "[]")

    # Save session state
    cat > "$session_dir/session-state.json" << EOF
{
    "session_id": "$session_id",
    "saved_at": "$now",
    "message_count": $message_count,
    "topics": $topics,
    "project_dir": "$(pwd)",
    "status": "in_progress"
}
EOF

    update_session "last_auto_save" "$(date +%s)"
    update_session "auto_save_count" "$(($(get_session_value auto_save_count 0) + 1))"

    echo -e "${DIM}[Auto-saved: $session_id]${NC}" >&2

    # Check for too many sessions and alert
    check_sessions_limit
}

check_sessions_limit() {
    if [[ -d "$ANALYSIS_DIR" ]]; then
        local count=$(find "$ANALYSIS_DIR" -maxdepth 1 -type d ! -path "$ANALYSIS_DIR" 2>/dev/null | wc -l)
        local disk_usage=$(du -sh "$ANALYSIS_DIR" 2>/dev/null | cut -f1)

        if [[ $count -ge $MAX_SESSIONS_WARNING ]]; then
            echo "" >&2
            echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${NC}" >&2
            echo -e "${RED}║${WHITE}  ⚠️  ALERTE: $count sessions sauvegardées ($disk_usage)              ${RED}║${NC}" >&2
            echo -e "${RED}╠══════════════════════════════════════════════════════════════════╣${NC}" >&2
            echo -e "${RED}║${NC}  Pensez à nettoyer avec:                                        ${RED}║${NC}" >&2
            echo -e "${RED}║${NC}    ${GREEN}\"Exporte et nettoie les sessions\"${NC}                            ${RED}║${NC}" >&2
            echo -e "${RED}║${NC}    ${GREEN}\"Nettoie les anciennes sessions\"${NC}                             ${RED}║${NC}" >&2
            echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${NC}" >&2
            echo "" >&2
        fi
    fi
}

should_auto_save() {
    local message_count="$1"
    local last_auto_save="$2"

    local now=$(date +%s)
    local since_last=$((now - last_auto_save))

    # Auto-save every 10 messages OR every 5 minutes
    if [[ $((message_count % AUTO_SAVE_INTERVAL_MESSAGES)) -eq 0 ]]; then
        return 0
    fi

    if [[ $since_last -ge 300 && $last_auto_save -gt 0 ]]; then
        return 0
    fi

    return 1
}

# ============================================================================
# Warning Display
# ============================================================================

show_compacting_warning() {
    local message_count="$1"
    local session_minutes="$2"
    local topics="$3"
    local session_id="$4"

    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${WHITE}  ⚠️  APPROCHE LIMITE DE CONTEXTE - Risque de compacting             ${YELLOW}║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ${CYAN}Session:${NC} ${message_count} messages | ${session_minutes} minutes | Mode: analyse         ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"

    if [[ -n "$topics" && "$topics" != "[]" && "$topics" != "null" ]]; then
        echo -e "${YELLOW}║${NC}  ${CYAN}Sujets analysés:${NC}                                                   ${YELLOW}║${NC}"
        # Format topics nicely
        local topic_list=$(echo "$topics" | jq -r '.[]' 2>/dev/null | head -3 | while read t; do echo "     • $t"; done)
        echo -e "${YELLOW}║${NC}${DIM}$topic_list${NC}"
        echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    fi

    echo -e "${YELLOW}║${NC}  ${GREEN}✓ État auto-sauvé:${NC} .harmony/local/tmp/sessions/${session_id}/        ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║${NC}  ${WHITE}Le compacting va bientôt résumer cette conversation.${NC}                ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ${WHITE}Les analyses détaillées et le fil de raisonnement${NC}                   ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ${WHITE}risquent d'être simplifiés.${NC}                                         ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║${NC}  ${CYAN}Options:${NC}                                                             ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ${WHITE}1.${NC} \"${GREEN}Sauvegarde dans research/${NC}\"                                     ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}     → Fichier permanent avec fil de raisonnement                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ${WHITE}2.${NC} \"${CYAN}Continue${NC}\" (ou ignorer ce message)                              ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}     → Reprendra depuis /tmp si compacting survient                  ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}  ${WHITE}3.${NC} \"${DIM}Crée un ADR pour cette décision${NC}\"                               ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}     → Architecture Decision Record formel                           ${YELLOW}║${NC}"
    echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Main Hook Logic
# ============================================================================

should_show_warning() {
    local message_count="$1"
    local session_start="$2"
    local last_warning="$3"
    local analysis_mode="$4"

    local now=$(date +%s)
    local session_duration=$((now - session_start))
    local session_minutes=$((session_duration / 60))
    local since_last_warning=$((now - last_warning))

    # Don't warn too frequently (minimum 10 minutes between warnings)
    if [[ $since_last_warning -lt 600 && $last_warning -gt 0 ]]; then
        return 1
    fi

    # Only warn if in analysis mode
    if [[ "$analysis_mode" != "true" ]]; then
        return 1
    fi

    # Check thresholds
    if [[ $message_count -ge $WARNING_THRESHOLD_MESSAGES ]]; then
        return 0
    fi

    if [[ $session_minutes -ge $WARNING_THRESHOLD_MINUTES ]]; then
        return 0
    fi

    return 1
}

main() {
    local user_input="${1:-}"

    # Initialize tracker if needed
    init_session_tracker

    # Detect /clear command - clears all sessions immediately
    if detect_clear_command "$user_input"; then
        clear_all_sessions
        return 0
    fi

    # Increment message count
    increment_message_count

    # Detect analysis mode
    if detect_analysis_mode "$user_input"; then
        update_session "analysis_mode" "true"

        # Extract and add topic
        local topic=$(extract_analysis_topic "$user_input")
        if [[ -n "$topic" ]]; then
            add_analysis_topic "$topic"
        fi
    fi

    # Get session metrics
    local message_count=$(get_session_value "message_count" "0")
    local session_start=$(get_session_value "session_start" "$(date +%s)")
    local last_warning=$(get_session_value "last_warning" "0")
    local last_auto_save=$(get_session_value "last_auto_save" "0")
    local analysis_mode=$(get_session_value "analysis_mode" "false")
    local topics=$(get_session_value "analysis_topics" "[]")
    local session_id=$(get_session_value "analysis_session_id" "")

    local now=$(date +%s)
    local session_minutes=$(( (now - session_start) / 60 ))

    # Auto-save if in analysis mode and threshold reached
    if [[ "$analysis_mode" == "true" ]]; then
        if should_auto_save "$message_count" "$last_auto_save"; then
            perform_auto_save "$message_count"
        fi
    fi

    # Check if we should show warning
    if should_show_warning "$message_count" "$session_start" "$last_warning" "$analysis_mode"; then
        # Ensure we have a session ID for the warning
        if [[ -z "$session_id" || "$session_id" == "null" ]]; then
            perform_auto_save "$message_count"
            session_id=$(get_session_value "analysis_session_id" "unknown")
        fi

        show_compacting_warning "$message_count" "$session_minutes" "$topics" "$session_id"
        update_session "last_warning" "$now"
        update_session "warnings_shown" "$(($(get_session_value warnings_shown 0) + 1))"
    fi
}

# ============================================================================
# CLI Commands
# ============================================================================

reset_session() {
    if [[ -f "$SESSION_FILE" ]]; then
        rm -f "$SESSION_FILE"
        echo -e "${CYAN}Session tracker reset.${NC}"
    fi
    init_session_tracker
    echo -e "${CYAN}New session started.${NC}"
}

show_session_status() {
    init_session_tracker

    local message_count=$(get_session_value "message_count" "0")
    local session_start=$(get_session_value "session_start" "$(date +%s)")
    local analysis_mode=$(get_session_value "analysis_mode" "false")
    local topics=$(get_session_value "analysis_topics" "[]")
    local warnings_shown=$(get_session_value "warnings_shown" "0")
    local auto_save_count=$(get_session_value "auto_save_count" "0")
    local session_id=$(get_session_value "analysis_session_id" "null")

    local now=$(date +%s)
    local session_minutes=$(( (now - session_start) / 60 ))

    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}  Session Tracker Status                                        ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  Messages:       $message_count"
    echo -e "${CYAN}║${NC}  Duration:       ${session_minutes} minutes"
    echo -e "${CYAN}║${NC}  Analysis Mode:  $analysis_mode"
    echo -e "${CYAN}║${NC}  Session ID:     $session_id"
    echo -e "${CYAN}║${NC}  Auto-saves:     $auto_save_count"
    echo -e "${CYAN}║${NC}  Warnings Shown: $warnings_shown"
    echo -e "${CYAN}║${NC}  Topics:         $topics"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Show saved session if exists
    if [[ -n "$session_id" && "$session_id" != "null" && -d "$ANALYSIS_DIR/$session_id" ]]; then
        echo -e "${GREEN}Saved session: $ANALYSIS_DIR/$session_id/${NC}"
        ls -la "$ANALYSIS_DIR/$session_id/" 2>/dev/null || true
    fi
}

list_saved_sessions() {
    echo ""
    echo -e "${CYAN}Sessions sauvegardées dans .harmony/local/tmp/sessions/:${NC}"
    echo ""

    if [[ -d "$ANALYSIS_DIR" ]]; then
        for session_dir in "$ANALYSIS_DIR"/*/; do
            if [[ -f "${session_dir}session-state.json" ]]; then
                local data=$(cat "${session_dir}session-state.json")
                local sid=$(echo "$data" | jq -r '.session_id')
                local saved=$(echo "$data" | jq -r '.saved_at')
                local msgs=$(echo "$data" | jq -r '.message_count')
                local topics=$(echo "$data" | jq -r '.topics | join(", ") | .[0:40]')

                echo -e "  ${WHITE}[$sid]${NC} $msgs msgs | $saved"
                echo -e "  ${DIM}Topics: $topics${NC}"
                echo ""
            fi
        done
    else
        echo "  Aucune session sauvegardée"
    fi
}

# Run if called directly (for testing or CLI)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --reset)
            reset_session
            ;;
        --clear)
            clear_all_sessions
            echo -e "${GREEN}Toutes les sessions ont été supprimées.${NC}"
            ;;
        --status)
            show_session_status
            ;;
        --list)
            list_saved_sessions
            ;;
        --test-warning)
            show_compacting_warning "55" "50" '["architecture jq/yq", "benchmark performance"]' "abc12345"
            ;;
        --help)
            echo "Usage: compacting-warning.sh [options] [user_prompt]"
            echo ""
            echo "Options:"
            echo "  --reset        Reset session tracker"
            echo "  --clear        Clear all saved sessions (like /clear)"
            echo "  --status       Show session status"
            echo "  --list         List saved sessions"
            echo "  --test-warning Show warning (for testing)"
            echo "  --help         Show this help"
            echo ""
            echo "Without options, tracks the user prompt and shows warning if needed."
            ;;
        *)
            main "$@"
            ;;
    esac
fi
