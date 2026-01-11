#!/bin/bash
# ============================================================================
# Harmony Framework - Session Resume Hook
# ============================================================================
# Checks for pending analysis sessions at startup and proposes to resume.
# Works with analysis-tracker.sh and compacting-warning.sh.
#
# Triggers on: First user prompt of session (via startup detection)
# ============================================================================

set -euo pipefail

# Configuration
HARMONY_DIR="${HARMONY_DIR:-.harmony}"
ANALYSIS_DIR="${HARMONY_DIR}/local/tmp/sessions"  # Project-specific
SESSION_FLAG_FILE="/tmp/harmony-session-resume-shown-$$"
GLOBAL_FLAG_DIR="/tmp/harmony-resume-flags"
MAX_FLAG_AGE_HOURS=2  # Only show resume prompt every 2 hours

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================================
# Flag Management (avoid showing multiple times per session)
# ============================================================================

get_flag_file() {
    local project_hash=$(pwd | sha256sum | head -c 8)
    mkdir -p "$GLOBAL_FLAG_DIR"
    echo "$GLOBAL_FLAG_DIR/resume-shown-$project_hash"
}

should_show_resume_prompt() {
    local flag_file=$(get_flag_file)

    # Never shown for this project in this shell session
    if [[ -f "$SESSION_FLAG_FILE" ]]; then
        return 1
    fi

    # Check global flag (throttle to MAX_FLAG_AGE_HOURS)
    if [[ -f "$flag_file" ]]; then
        local flag_age=$(( $(date +%s) - $(stat -c %Y "$flag_file" 2>/dev/null || stat -f %m "$flag_file" 2>/dev/null) ))
        local max_age_seconds=$((MAX_FLAG_AGE_HOURS * 3600))

        if [[ $flag_age -lt $max_age_seconds ]]; then
            return 1
        fi
    fi

    return 0
}

mark_resume_shown() {
    local flag_file=$(get_flag_file)
    touch "$flag_file"
    touch "$SESSION_FLAG_FILE"
}

# ============================================================================
# Session Detection
# ============================================================================

find_pending_sessions() {
    local project_dir=$(pwd)
    local sessions=()

    if [[ ! -d "$ANALYSIS_DIR" ]]; then
        return 0
    fi

    for session_dir in "$ANALYSIS_DIR"/*/; do
        if [[ -f "${session_dir}analysis.json" ]]; then
            local data=$(cat "${session_dir}analysis.json")
            local status=$(jq -r '.status // "unknown"' <<< "$data" 2>/dev/null)
            local session_project=$(jq -r '.project_dir // ""' <<< "$data" 2>/dev/null)

            # Only show sessions for THIS project or sessions without project_dir (old format)
            if [[ "$status" == "in_progress" ]]; then
                if [[ -z "$session_project" || "$session_project" == "$project_dir" ]]; then
                    sessions+=("${session_dir}analysis.json")
                fi
            fi
        fi
    done

    # Also check session-tracker.json from compacting-warning
    local session_file="$HARMONY_DIR/memory/session-tracker.json"
    if [[ -f "$session_file" ]]; then
        local analysis_mode=$(jq -r '.analysis_mode // false' "$session_file" 2>/dev/null)
        local session_id=$(jq -r '.analysis_session_id // empty' "$session_file" 2>/dev/null)

        if [[ "$analysis_mode" == "true" && -n "$session_id" && "$session_id" != "null" ]]; then
            if [[ -d "$ANALYSIS_DIR/$session_id" ]]; then
                # Avoid duplicates
                local found=0
                for s in "${sessions[@]:-}"; do
                    if [[ "$s" == *"$session_id"* ]]; then
                        found=1
                        break
                    fi
                done
                if [[ $found -eq 0 ]]; then
                    sessions+=("$ANALYSIS_DIR/$session_id/session-state.json")
                fi
            fi
        fi
    fi

    echo "${sessions[@]:-}"
}

# ============================================================================
# Display Functions
# ============================================================================

show_session_resume_prompt() {
    local sessions=($@)
    local count=${#sessions[@]}

    if [[ $count -eq 0 ]]; then
        return 0
    fi

    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}  🔄 Sessions d'analyse précédentes détectées                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"

    local shown=0
    for session_file in "${sessions[@]}"; do
        if [[ $shown -ge 3 ]]; then
            echo -e "${CYAN}║${NC}  ${DIM}... et $((count - 3)) autres sessions${NC}"
            break
        fi

        local data=""
        local title=""
        local session_id=""
        local updated=""
        local steps=0
        local type=""

        if [[ "$session_file" == *"analysis.json" ]]; then
            data=$(cat "$session_file" 2>/dev/null || echo "{}")
            title=$(jq -r '.title // "Sans titre"' <<< "$data")
            session_id=$(jq -r '.session_id // "unknown"' <<< "$data")
            updated=$(jq -r '.updated_at // ""' <<< "$data")
            steps=$(jq '.reasoning_chain | length' <<< "$data" 2>/dev/null || echo 0)
            type=$(jq -r '.type // "general"' <<< "$data")
        elif [[ "$session_file" == *"session-state.json" ]]; then
            data=$(cat "$session_file" 2>/dev/null || echo "{}")
            session_id=$(jq -r '.session_id // "unknown"' <<< "$data")
            updated=$(jq -r '.saved_at // ""' <<< "$data")
            local topics=$(jq -r '.topics | join(", ") | .[0:40]' <<< "$data" 2>/dev/null || echo "")
            title="Session: $topics"
            type="compacting-save"
        fi

        # Format timestamp
        local time_ago=""
        if [[ -n "$updated" ]]; then
            local update_epoch=$(date -d "$updated" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$updated" +%s 2>/dev/null || echo 0)
            local now_epoch=$(date +%s)
            local diff=$((now_epoch - update_epoch))

            if [[ $diff -lt 3600 ]]; then
                time_ago="il y a $((diff / 60)) min"
            elif [[ $diff -lt 86400 ]]; then
                time_ago="il y a $((diff / 3600))h"
            else
                time_ago="il y a $((diff / 86400))j"
            fi
        fi

        echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}►${NC} ${WHITE}[$session_id]${NC} $(printf '%-40s' "${title:0:40}")"

        if [[ "$type" == "compacting-save" ]]; then
            echo -e "${CYAN}║${NC}    ${DIM}Sauvegarde auto-compacting | $time_ago${NC}"
        else
            echo -e "${CYAN}║${NC}    ${DIM}$steps étapes | Type: $type | $time_ago${NC}"
        fi

        shown=$((shown + 1))
    done

    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}Pour reprendre une session:${NC}                                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${GREEN}\"Reprends l'analyse [session_id]\"${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${GREEN}\"Continue l'analyse précédente\"${NC}                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}Pour exporter et archiver:${NC}                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${YELLOW}\"Exporte l'analyse dans research/\"${NC}                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}Ignorer ce message pour continuer normalement${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Context Injection for Resume
# ============================================================================

generate_resume_context() {
    local session_id="$1"
    local session_file="$ANALYSIS_DIR/$session_id/analysis.json"

    if [[ ! -f "$session_file" ]]; then
        # Try session-state.json
        session_file="$ANALYSIS_DIR/$session_id/session-state.json"
    fi

    if [[ ! -f "$session_file" ]]; then
        echo "Session not found: $session_id" >&2
        return 1
    fi

    local data=$(cat "$session_file")

    echo "# Contexte de reprise de session"
    echo ""
    echo "**Session ID:** $session_id"
    echo "**Fichier:** $session_file"
    echo ""

    if [[ "$session_file" == *"analysis.json" ]]; then
        local title=$(jq -r '.title' <<< "$data")
        local type=$(jq -r '.type' <<< "$data")
        echo "**Titre:** $title"
        echo "**Type:** $type"
        echo ""

        echo "## Fil de raisonnement"
        echo ""
        jq -r '.reasoning_chain[] | "**Étape \(.step):** \(.thought)\n- Conclusion: \(.conclusion)\n"' <<< "$data" 2>/dev/null || true

        echo "## Découvertes"
        jq -r '.findings[] | "- **\(.key):** \(.value)"' <<< "$data" 2>/dev/null || true
        echo ""

        echo "## Décisions en attente"
        local decisions=$(jq -r '.decisions | length' <<< "$data")
        if [[ "$decisions" -eq 0 ]]; then
            echo "- Aucune décision prise encore"
        else
            jq -r '.decisions[] | "- **\(.decision):** \(.rationale)"' <<< "$data" 2>/dev/null || true
        fi
        echo ""

        echo "## Prochaines étapes suggérées"
        local next_steps=$(jq -r '.next_steps | length' <<< "$data" 2>/dev/null || echo 0)
        if [[ "$next_steps" -eq 0 ]]; then
            echo "- Continuer l'analyse"
        else
            jq -r '.next_steps[] | "- [ ] \(.)"' <<< "$data" 2>/dev/null || true
        fi
    else
        # session-state.json format
        local topics=$(jq -r '.topics | join(", ")' <<< "$data" 2>/dev/null)
        local msg_count=$(jq -r '.message_count' <<< "$data" 2>/dev/null)

        echo "**Sujets analysés:** $topics"
        echo "**Messages dans la session:** $msg_count"
        echo ""
        echo "Cette session a été sauvegardée automatiquement avant compacting."
        echo "Pour continuer, référez-vous aux sujets ci-dessus."
    fi
}

# ============================================================================
# Main Hook Logic
# ============================================================================

main() {
    local user_input="${1:-}"

    # Check if this is a resume request
    if echo "$user_input" | grep -qiE "reprend|resume|continue.*analyse|continue.*session"; then
        # Extract session ID if provided
        local session_id=$(echo "$user_input" | grep -oE '[a-f0-9]{8}' | head -1)

        if [[ -n "$session_id" ]]; then
            generate_resume_context "$session_id"
            return 0
        else
            # Find most recent session
            local sessions=($(find_pending_sessions))
            if [[ ${#sessions[@]} -gt 0 ]]; then
                local most_recent="${sessions[0]}"
                local sid=$(jq -r '.session_id' "$most_recent" 2>/dev/null)
                generate_resume_context "$sid"
                return 0
            fi
        fi
    fi

    # Check if we should show the resume prompt
    if ! should_show_resume_prompt; then
        return 0
    fi

    # Find pending sessions
    local sessions=($(find_pending_sessions))

    if [[ ${#sessions[@]} -gt 0 ]]; then
        show_session_resume_prompt "${sessions[@]}"
        mark_resume_shown
    fi
}

# ============================================================================
# CLI Commands
# ============================================================================

case "${1:-}" in
    --list)
        sessions=($(find_pending_sessions))
        if [[ ${#sessions[@]} -gt 0 ]]; then
            show_session_resume_prompt "${sessions[@]}"
        else
            echo "Aucune session en cours"
        fi
        ;;
    --resume)
        if [[ -n "${2:-}" ]]; then
            generate_resume_context "$2"
        else
            echo "Usage: session-resume.sh --resume <session_id>" >&2
            exit 1
        fi
        ;;
    --clear-flags)
        rm -rf "$GLOBAL_FLAG_DIR"
        rm -f "$SESSION_FLAG_FILE"
        echo "Flags cleared"
        ;;
    --help)
        echo "Usage: session-resume.sh [options] [user_prompt]"
        echo ""
        echo "Options:"
        echo "  --list         List pending sessions"
        echo "  --resume ID    Generate resume context for session"
        echo "  --clear-flags  Clear shown flags (force re-display)"
        echo "  --help         Show this help"
        echo ""
        echo "Without options, runs as hook and shows prompt if needed."
        ;;
    *)
        main "$@"
        ;;
esac
