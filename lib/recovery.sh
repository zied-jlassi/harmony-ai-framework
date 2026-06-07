#!/bin/bash
# =============================================================================
# Harmony Framework - Recovery & Resilience System
# =============================================================================
#
# Ensures working memory survives crashes and session interruptions.
# Features:
#   - Automatic checkpoints every N actions
#   - Action journal for recovery
#   - State validation on startup
#   - Automatic repair of corrupted state
#
# Usage:
#   source "${HARMONY_DIR}/lib/recovery.sh"
#
#   # At session start
#   recover_state
#
#   # Before any action
#   checkpoint_before "action description"
#
#   # After any action
#   checkpoint_after "result"
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------

if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

WORKING_MEMORY="${HARMONY_DIR}/local/memory/working.json"
ACTION_LOG="${HARMONY_DIR}/local/memory/.action-log.jsonl"
CHECKPOINT_FILE="${HARMONY_DIR}/local/memory/.checkpoint.json"
BACKUP_DIR="${HARMONY_DIR}/local/memory/.backups"

# Colors
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'
C_NC='\033[0m'

# Checkpoint every N actions
CHECKPOINT_INTERVAL=5

# Keep last N backups
MAX_BACKUPS=10

# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------

# Lazy init: create dirs/files ONLY when a write operation runs, never at source
# time (sourcing a library must have no side effects — would pollute the cwd when
# HARMONY_DIR is unset). Called by the checkpoint/backup writers below.
_recovery_init() {
    mkdir -p "$BACKUP_DIR"
    [[ -f "$ACTION_LOG" ]] || touch "$ACTION_LOG"
}

# -----------------------------------------------------------------------------
# CHECKPOINTING
# -----------------------------------------------------------------------------

# Create a checkpoint before an action
# Usage: checkpoint_before "Starting story STORY-001"
checkpoint_before() {
    local action="$1"
    local now
    now=$(date -Iseconds)

    # Log the action
    _recovery_init
    echo "{\"time\":\"$now\",\"type\":\"start\",\"action\":\"$action\",\"status\":\"pending\"}" >> "$ACTION_LOG"

    # Create checkpoint
    if [[ -f "$WORKING_MEMORY" ]]; then
        jq --arg action "$action" \
           --arg time "$now" \
           '. + {
               _checkpoint: {
                   pending_action: $action,
                   started_at: $time,
                   completed: false
               }
           }' "$WORKING_MEMORY" > "$CHECKPOINT_FILE"
    fi
}

# Complete a checkpoint after successful action
# Usage: checkpoint_after "Story STORY-001 started successfully"
checkpoint_after() {
    local result="${1:-success}"
    local now
    now=$(date -Iseconds)

    # Log completion
    _recovery_init
    echo "{\"time\":\"$now\",\"type\":\"end\",\"result\":\"$result\",\"status\":\"completed\"}" >> "$ACTION_LOG"

    # Clear pending checkpoint
    if [[ -f "$WORKING_MEMORY" ]]; then
        local tmp_file
        tmp_file=$(mktemp)
        jq 'del(._checkpoint) | .last_updated = "'"$now"'"' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    fi

    # Check if we need a backup
    _maybe_create_backup
}

# Record a failed action
# Usage: checkpoint_failed "Error: API timeout"
checkpoint_failed() {
    local error="$1"
    local now
    now=$(date -Iseconds)

    # Log failure
    _recovery_init
    echo "{\"time\":\"$now\",\"type\":\"error\",\"error\":\"$error\",\"status\":\"failed\"}" >> "$ACTION_LOG"

    # Mark checkpoint as failed but don't clear it (for recovery)
    if [[ -f "$WORKING_MEMORY" ]]; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg error "$error" \
           --arg time "$now" \
           '._checkpoint.failed = true |
            ._checkpoint.error = $error |
            ._checkpoint.failed_at = $time' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    fi
}

# -----------------------------------------------------------------------------
# BACKUP MANAGEMENT
# -----------------------------------------------------------------------------

# Maybe create a backup (every N actions)
_maybe_create_backup() {
    # Count completed actions since last backup
    local action_count
    action_count=$(tail -n "$CHECKPOINT_INTERVAL" "$ACTION_LOG" 2>/dev/null | grep -c '"status":"completed"' || echo "0")

    if [[ "$action_count" -ge "$CHECKPOINT_INTERVAL" ]]; then
        create_backup "auto"
    fi
}

# Create a backup
# Usage: create_backup "auto" | create_backup "manual" "description"
create_backup() {
    local type="${1:-manual}"
    local description="${2:-}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    if [[ ! -f "$WORKING_MEMORY" ]]; then
        return 1
    fi

    _recovery_init
    local backup_file="${BACKUP_DIR}/working_${timestamp}_${type}.json"
    cp "$WORKING_MEMORY" "$backup_file"

    # Add metadata
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg type "$type" \
       --arg desc "$description" \
       --arg time "$(date -Iseconds)" \
       '. + {_backup_meta: {type: $type, description: $desc, created: $time}}' \
       "$backup_file" > "$tmp_file" && mv "$tmp_file" "$backup_file"

    echo -e "${C_CYAN}Backup created: $backup_file${C_NC}" >&2

    # Cleanup old backups
    _cleanup_old_backups
}

# Cleanup old backups
_cleanup_old_backups() {
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -name "working_*.json" | wc -l)

    if [[ "$backup_count" -gt "$MAX_BACKUPS" ]]; then
        # Remove oldest backups
        find "$BACKUP_DIR" -name "working_*.json" -type f | \
            sort | head -n -$MAX_BACKUPS | xargs rm -f
    fi
}

# List available backups
list_backups() {
    echo -e "${C_CYAN}Available backups:${C_NC}"
    find "$BACKUP_DIR" -name "working_*.json" -type f | sort -r | while read -r backup; do
        local meta
        meta=$(jq -r '._backup_meta | "\(.type) - \(.description // "no description")"' "$backup" 2>/dev/null || echo "unknown")
        echo "  $(basename "$backup"): $meta"
    done
}

# Restore from backup
# Usage: restore_backup "working_20250101_120000_auto.json"
restore_backup() {
    local backup_name="$1"
    local backup_file="${BACKUP_DIR}/${backup_name}"

    if [[ ! -f "$backup_file" ]]; then
        echo -e "${C_RED}Backup not found: $backup_file${C_NC}" >&2
        return 1
    fi

    # Backup current state first
    if [[ -f "$WORKING_MEMORY" ]]; then
        create_backup "pre_restore" "Before restore from $backup_name"
    fi

    # Restore (remove backup metadata)
    jq 'del(._backup_meta)' "$backup_file" > "$WORKING_MEMORY"

    echo -e "${C_GREEN}Restored from: $backup_name${C_NC}"
}

# -----------------------------------------------------------------------------
# RECOVERY
# -----------------------------------------------------------------------------

# Recover state after crash/session end
# Call this at the start of each session
recover_state() {
    echo -e "${C_CYAN}Checking state integrity...${C_NC}" >&2

    # Check if working memory exists
    if [[ ! -f "$WORKING_MEMORY" ]]; then
        echo -e "${C_YELLOW}No working memory found. Use init_working_memory to create.${C_NC}" >&2
        return 0
    fi

    # Validate JSON
    if ! jq empty "$WORKING_MEMORY" 2>/dev/null; then
        echo -e "${C_RED}Working memory is corrupted. Attempting recovery...${C_NC}" >&2
        _recover_from_backup
        return $?
    fi

    # Check for incomplete checkpoint (crash during action)
    local pending
    pending=$(jq -r '._checkpoint.pending_action // empty' "$WORKING_MEMORY" 2>/dev/null)

    if [[ -n "$pending" ]]; then
        echo -e "${C_YELLOW}Found incomplete action: $pending${C_NC}" >&2

        local failed
        failed=$(jq -r '._checkpoint.failed // false' "$WORKING_MEMORY" 2>/dev/null)

        if [[ "$failed" == "true" ]]; then
            echo -e "${C_YELLOW}Action had failed. Clearing checkpoint.${C_NC}" >&2
            _clear_checkpoint
        else
            echo -e "${C_YELLOW}Action was interrupted. State may be inconsistent.${C_NC}" >&2
            _show_recovery_options
            return 1
        fi
    fi

    # Validate state consistency
    _validate_state

    echo -e "${C_GREEN}State OK${C_NC}" >&2
    return 0
}

# Recover from backup
_recover_from_backup() {
    local latest_backup
    latest_backup=$(find "$BACKUP_DIR" -name "working_*.json" -type f | sort -r | head -1)

    if [[ -n "$latest_backup" ]]; then
        echo -e "${C_YELLOW}Recovering from: $(basename "$latest_backup")${C_NC}" >&2
        jq 'del(._backup_meta)' "$latest_backup" > "$WORKING_MEMORY"
        return 0
    else
        echo -e "${C_RED}No backups available. Working memory lost.${C_NC}" >&2
        return 1
    fi
}

# Clear incomplete checkpoint
_clear_checkpoint() {
    local tmp_file
    tmp_file=$(mktemp)
    jq 'del(._checkpoint)' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
}

# Show recovery options
_show_recovery_options() {
    echo ""
    echo -e "${C_YELLOW}Recovery options:${C_NC}"
    echo "  1. clear_checkpoint    - Clear the incomplete action and continue"
    echo "  2. restore_backup      - Restore from a backup"
    echo "  3. show_action_log     - View recent actions"
    echo ""
}

# Validate state consistency
_validate_state() {
    local errors=0

    # Check current sprint consistency
    local sprint_id
    sprint_id=$(jq -r '.current_sprint.id // empty' "$WORKING_MEMORY")
    local sprint_status
    sprint_status=$(jq -r '.current_sprint.status // "NOT_STARTED"' "$WORKING_MEMORY")

    if [[ -n "$sprint_id" && "$sprint_status" == "NOT_STARTED" ]]; then
        echo -e "${C_YELLOW}Warning: Sprint has ID but status is NOT_STARTED${C_NC}" >&2
        ((errors++))
    fi

    # Check current story consistency
    local story_id
    story_id=$(jq -r '.current_story.id // empty' "$WORKING_MEMORY")
    local story_status
    story_status=$(jq -r '.current_story.status // "TODO"' "$WORKING_MEMORY")

    if [[ -n "$story_id" && "$story_status" == "TODO" ]]; then
        echo -e "${C_YELLOW}Warning: Story has ID but status is TODO${C_NC}" >&2
        ((errors++))
    fi

    # Check velocity consistency
    local velocity_achieved
    velocity_achieved=$(jq -r '.current_sprint.velocity_achieved // 0' "$WORKING_MEMORY")
    local stories_count
    stories_count=$(jq -r '.current_sprint.stories | length' "$WORKING_MEMORY")

    if [[ "$velocity_achieved" -gt 0 && "$stories_count" -eq 0 ]]; then
        echo -e "${C_YELLOW}Warning: Velocity > 0 but no stories in sprint${C_NC}" >&2
        ((errors++))
    fi

    if [[ "$errors" -gt 0 ]]; then
        echo -e "${C_YELLOW}Found $errors inconsistencies. Consider running fix_state${C_NC}" >&2
    fi

    return 0
}

# Fix common state issues
fix_state() {
    echo -e "${C_CYAN}Fixing state issues...${C_NC}" >&2

    local tmp_file
    tmp_file=$(mktemp)

    jq '
        # Fix sprint status if it has ID
        if .current_sprint.id != null and .current_sprint.status == "NOT_STARTED" then
            .current_sprint.status = "IN_PROGRESS"
        else . end |

        # Fix story status if it has ID
        if .current_story.id != null and .current_story.status == "TODO" then
            .current_story.status = "IN_PROGRESS"
        else . end |

        # Clear checkpoint if exists
        del(._checkpoint)
    ' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    echo -e "${C_GREEN}State fixed${C_NC}" >&2
}

# -----------------------------------------------------------------------------
# ACTION LOG
# -----------------------------------------------------------------------------

# Show recent actions from log
show_action_log() {
    local count="${1:-20}"

    echo -e "${C_CYAN}Recent actions (last $count):${C_NC}"
    tail -n "$count" "$ACTION_LOG" | while read -r line; do
        local time type status
        time=$(echo "$line" | jq -r '.time // "?"')
        type=$(echo "$line" | jq -r '.type // "?"')
        status=$(echo "$line" | jq -r '.status // "?"')

        case "$type" in
            start)
                local action
                action=$(echo "$line" | jq -r '.action')
                echo -e "  ${C_YELLOW}→${C_NC} $time: $action"
                ;;
            end)
                local result
                result=$(echo "$line" | jq -r '.result')
                echo -e "  ${C_GREEN}✓${C_NC} $time: $result"
                ;;
            error)
                local error
                error=$(echo "$line" | jq -r '.error')
                echo -e "  ${C_RED}✗${C_NC} $time: $error"
                ;;
        esac
    done
}

# Clear action log
clear_action_log() {
    echo "" > "$ACTION_LOG"
    echo -e "${C_GREEN}Action log cleared${C_NC}" >&2
}

# -----------------------------------------------------------------------------
# SESSION SUMMARY
# -----------------------------------------------------------------------------

# Generate session summary for handoff
generate_session_summary() {
    local now
    now=$(date -Iseconds)

    echo "# Session Summary - $now"
    echo ""

    # Current state
    echo "## Current State"
    jq -r '
        "Sprint: \(.current_sprint.id // "None") (\(.current_sprint.status // "N/A"))\n" +
        "Story: \(.current_story.id // "None") (\(.current_story.status // "N/A"))\n" +
        "Velocity: \(.current_sprint.velocity_achieved // 0)/\(.current_sprint.velocity_target // 0) pts"
    ' "$WORKING_MEMORY"
    echo ""

    # Recent actions
    echo "## Recent Actions"
    show_action_log 5
    echo ""

    # Blockers
    echo "## Open Blockers"
    jq -r '.blockers | map(select(.status == "open")) | if length > 0 then .[] | "- [\(.severity)] \(.description)" else "None" end' "$WORKING_MEMORY"
    echo ""

    # Next steps
    echo "## Next Steps"
    jq -r '.next_steps | if length > 0 then .[:5][] | "- \(.)" else "None defined" end' "$WORKING_MEMORY"
}

# Save session summary to handoff file
save_session_summary() {
    generate_session_summary > "${HARMONY_DIR}/local/memory/session-handoff.md"
    echo -e "${C_GREEN}Session summary saved to session-handoff.md${C_NC}" >&2
}
