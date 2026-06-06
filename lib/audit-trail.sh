#!/bin/bash
# =============================================================================
# Harmony Framework - Audit Trail with Rollback
# =============================================================================
# Complete audit logging system for all agent decisions with checkpoint/rollback
# capability. Meets 2026 enterprise AI governance requirements (Forrester).
#
# Usage:
#   source "${HARMONY_DIR}/lib/audit-trail.sh"
#
#   # Start session and record decisions
#   audit_start_session "feature-implementation"
#   audit_record_decision "developer" "create_file" "src/app.ts" "Implementing feature X"
#   audit_record_file_change "$entry_id" "src/app.ts" "" "$(cat src/app.ts)"
#
#   # Checkpoints and rollback
#   audit_create_checkpoint "manual" "Before refactoring"
#   audit_rollback_to "CKP-xxx"
#
#   # Export and analytics
#   audit_export "json" "./audit-report.json"
#   audit_get_stats
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${AUDIT_TRAIL_LOADED:-}" == "true" ]]; then
    return 0
fi
AUDIT_TRAIL_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

AUDIT_CONFIG="${HARMONY_DIR}/local/audit-config.json"
AUDIT_JOURNAL="${HARMONY_DIR}/local/memory/audit-journal.json"
AUDIT_CHECKPOINTS_DIR="${HARMONY_DIR}/local/memory/checkpoints"

# Environment variables with defaults
AUDIT_ENABLED="${AUDIT_ENABLED:-true}"
AUDIT_RETENTION_DAYS="${AUDIT_RETENTION_DAYS:-90}"
AUDIT_MAX_ENTRIES="${AUDIT_MAX_ENTRIES:-10000}"
AUDIT_CHECKPOINT_INTERVAL="${AUDIT_CHECKPOINT_INTERVAL:-10}"

# Colors (match sprint-tracker.sh)
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

# Current session tracking
_AUDIT_CURRENT_SESSION=""
_AUDIT_ENTRY_COUNT=0

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

# Generate unique ID with prefix
_audit_generate_id() {
    local prefix="${1:-AUD}"
    echo "${prefix}-$(date +%s%N | sha256sum | head -c 8)"
}

# Get ISO timestamp
_audit_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

# Initialize journal if not exists
_audit_init_journal() {
    if [[ ! -f "$AUDIT_JOURNAL" ]]; then
        mkdir -p "$(dirname "$AUDIT_JOURNAL")"
        cp "${HARMONY_DIR}/templates/memory/audit-journal.template.json" "$AUDIT_JOURNAL"
        local ts
        ts=$(_audit_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"
    fi

    # Ensure checkpoints directory exists
    mkdir -p "$AUDIT_CHECKPOINTS_DIR"
}

# Load config value with default
_audit_config_get() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "$AUDIT_CONFIG" ]]; then
        local value
        value=$(jq -r ".$key // empty" "$AUDIT_CONFIG" 2>/dev/null)
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
            return
        fi
    fi
    echo "$default"
}

# Redact sensitive data from content
_audit_redact_sensitive() {
    local content="$1"
    local result="$content"

    if [[ -f "$AUDIT_CONFIG" ]]; then
        # Get sensitive field names
        local fields
        fields=$(jq -r '.sensitive_fields[]? // empty' "$AUDIT_CONFIG" 2>/dev/null)

        for field in $fields; do
            # Redact JSON fields: "field": "value" -> "field": "[REDACTED]"
            # Use simple pattern to avoid locale issues
            result=$(echo "$result" | sed "s/\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"$field\": \"[REDACTED]\"/g" 2>/dev/null) || result="$content"
        done

        # Get redact patterns - apply them as-is without modification
        # These patterns are stored as regexes in config, apply directly
        local patterns
        patterns=$(jq -r '.redact_patterns[]? // empty' "$AUDIT_CONFIG" 2>/dev/null)

        while IFS= read -r pattern; do
            # Skip empty patterns
            [[ -z "$pattern" ]] && continue
            # Try to apply pattern, preserve result on failure
            local new_result
            new_result=$(echo "$result" | sed -E "s/$pattern/[REDACTED]/g" 2>/dev/null) || continue
            [[ -n "$new_result" ]] && result="$new_result"
        done <<< "$patterns"
    fi

    echo "$result"
}

# Check if action should be tracked
_audit_should_track() {
    local agent="$1"
    local action="$2"

    if [[ "$AUDIT_ENABLED" != "true" ]]; then
        return 1
    fi

    if [[ -f "$AUDIT_CONFIG" ]]; then
        # Check if agent is in tracking list
        local track_agents
        track_agents=$(jq -r '.agents_to_track | length' "$AUDIT_CONFIG" 2>/dev/null)
        if [[ "$track_agents" -gt 0 ]]; then
            if ! jq -e ".agents_to_track | index(\"$agent\")" "$AUDIT_CONFIG" &>/dev/null; then
                return 1
            fi
        fi

        # Check if action is in tracking list
        local track_actions
        track_actions=$(jq -r '.actions_to_track | length' "$AUDIT_CONFIG" 2>/dev/null)
        if [[ "$track_actions" -gt 0 ]]; then
            if ! jq -e ".actions_to_track | index(\"$action\")" "$AUDIT_CONFIG" &>/dev/null; then
                return 1
            fi
        fi
    fi

    return 0
}

# Auto-checkpoint if interval reached
_audit_check_auto_checkpoint() {
    local auto_enabled
    auto_enabled=$(_audit_config_get "auto_checkpoint" "true")

    if [[ "$auto_enabled" == "true" ]]; then
        local interval
        interval=$(_audit_config_get "checkpoint_interval" "$AUDIT_CHECKPOINT_INTERVAL")

        local entry_count
        entry_count=$(jq '.entries | length' "$AUDIT_JOURNAL" 2>/dev/null || echo "0")

        local last_checkpoint_at
        last_checkpoint_at=$(jq '.checkpoints[-1].at_entry // 0' "$AUDIT_JOURNAL" 2>/dev/null || echo "0")

        if (( entry_count - last_checkpoint_at >= interval )); then
            audit_create_checkpoint "auto" "Auto-checkpoint at entry $entry_count"
        fi
    fi
}

# Prune old entries based on retention
_audit_prune_old_entries() {
    local retention_days
    retention_days=$(_audit_config_get "retention_days" "$AUDIT_RETENTION_DAYS")

    local cutoff_date
    if [[ "$(uname)" == "Darwin" ]]; then
        cutoff_date=$(date -v-${retention_days}d +%Y-%m-%dT%H:%M:%S)
    else
        cutoff_date=$(date -d "$retention_days days ago" +%Y-%m-%dT%H:%M:%S)
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg cutoff "$cutoff_date" '
        .entries = [.entries[] | select(.timestamp >= $cutoff)]
    ' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Start a new audit session
# Usage: audit_start_session [session_name]
audit_start_session() {
    local session_name="${1:-session}"

    _audit_init_journal

    local session_id
    session_id=$(_audit_generate_id "SES")
    _AUDIT_CURRENT_SESSION="$session_id"
    _AUDIT_ENTRY_COUNT=0

    local ts
    ts=$(_audit_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg sid "$session_id" \
       --arg ts "$ts" \
       --arg name "$session_name" \
       '.session_id = $sid |
        .last_entry = $ts |
        .statistics.sessions_started += 1 |
        .entries += [{
          "id": ("SES-START-" + $sid),
          "timestamp": $ts,
          "session_id": $sid,
          "agent": "system",
          "action": "session_start",
          "target": $name,
          "rationale": "New audit session started",
          "context": {},
          "rollback_possible": false
        }]' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"

    echo -e "${C_GREEN}Audit session started: ${C_CYAN}$session_id${C_NC}" >&2
    echo "$session_id"
}

# Record an agent decision
# Usage: audit_record_decision agent action target rationale [context_json]
audit_record_decision() {
    local agent="$1"
    local action="$2"
    local target="$3"
    local rationale="$4"
    local context="${5:-{}}"

    if ! _audit_should_track "$agent" "$action"; then
        return 0
    fi

    _audit_init_journal

    local entry_id
    entry_id=$(_audit_generate_id "AUD")

    local ts
    ts=$(_audit_timestamp)

    local session_id="${_AUDIT_CURRENT_SESSION:-unknown}"

    # Redact sensitive data
    local safe_rationale
    safe_rationale=$(_audit_redact_sensitive "$rationale")
    local safe_context
    safe_context=$(_audit_redact_sensitive "$context")

    # Validate context is valid JSON, fallback to empty object
    if ! echo "$safe_context" | jq empty 2>/dev/null; then
        safe_context="{}"
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$entry_id" \
       --arg ts "$ts" \
       --arg sid "$session_id" \
       --arg agent "$agent" \
       --arg action "$action" \
       --arg target "$target" \
       --arg rationale "$safe_rationale" \
       --argjson context "$safe_context" \
       '.entries += [{
          "id": $id,
          "timestamp": $ts,
          "session_id": $sid,
          "agent": $agent,
          "action": $action,
          "target": $target,
          "rationale": $rationale,
          "context": $context,
          "rollback_possible": true,
          "file_changes": []
        }] |
        .last_entry = $ts |
        .statistics.total_decisions += 1' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"

    (( _AUDIT_ENTRY_COUNT++ )) || true

    # Check for auto-checkpoint
    _audit_check_auto_checkpoint

    # Enforce max entries
    local max_entries
    max_entries=$(_audit_config_get "max_entries" "$AUDIT_MAX_ENTRIES")
    local current_count
    current_count=$(jq '.entries | length' "$AUDIT_JOURNAL")

    if (( current_count > max_entries )); then
        local to_remove=$((current_count - max_entries))
        tmp_file=$(mktemp)
        jq --argjson n "$to_remove" '.entries = .entries[$n:]' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"
    fi

    echo "$entry_id"
}

# Record file change for an entry (enables rollback)
# Usage: audit_record_file_change entry_id file_path before_content after_content
audit_record_file_change() {
    local entry_id="$1"
    local file_path="$2"
    local before_content="$3"
    local after_content="$4"

    _audit_init_journal

    # Store file backup
    local backup_dir="${AUDIT_CHECKPOINTS_DIR}/file_backups"
    mkdir -p "$backup_dir"

    local backup_file="${backup_dir}/${entry_id}_$(basename "$file_path").backup"
    echo "$before_content" > "$backup_file"

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$entry_id" \
       --arg path "$file_path" \
       --arg backup "$backup_file" \
       '(.entries[] | select(.id == $id) | .file_changes) += [{
          "path": $path,
          "backup_file": $backup,
          "operation": "modify"
        }]' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"
}

# Create a checkpoint for rollback
# Usage: audit_create_checkpoint type description
audit_create_checkpoint() {
    local checkpoint_type="${1:-manual}"
    local description="${2:-Checkpoint}"

    _audit_init_journal

    local checkpoint_id
    checkpoint_id=$(_audit_generate_id "CKP")

    local ts
    ts=$(_audit_timestamp)

    local entry_count
    entry_count=$(jq '.entries | length' "$AUDIT_JOURNAL")

    # Create snapshot of current state
    local snapshot_file="${AUDIT_CHECKPOINTS_DIR}/${checkpoint_id}.snapshot.json"

    # Snapshot working memory and workflow state
    local snapshot="{}"
    if [[ -f "${HARMONY_DIR}/local/memory/working.json" ]]; then
        snapshot=$(jq -n --slurpfile working "${HARMONY_DIR}/local/memory/working.json" \
            '{working: $working[0]}')
    fi
    if [[ -f "${HARMONY_DIR}/local/memory/workflow-state.json" ]]; then
        snapshot=$(echo "$snapshot" | jq --slurpfile workflow "${HARMONY_DIR}/local/memory/workflow-state.json" \
            '. + {workflow: $workflow[0]}')
    fi
    echo "$snapshot" > "$snapshot_file"

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$checkpoint_id" \
       --arg ts "$ts" \
       --arg type "$checkpoint_type" \
       --arg desc "$description" \
       --argjson at "$entry_count" \
       --arg snapshot "$snapshot_file" \
       '.checkpoints += [{
          "id": $id,
          "timestamp": $ts,
          "type": $type,
          "description": $desc,
          "at_entry": $at,
          "snapshot_file": $snapshot
        }] |
        .statistics.checkpoints_created += 1' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"

    if [[ "$checkpoint_type" == "manual" ]]; then
        echo -e "${C_GREEN}Checkpoint created: ${C_CYAN}$checkpoint_id${C_NC} - $description" >&2
    fi

    echo "$checkpoint_id"
}

# Rollback to a checkpoint
# Usage: audit_rollback_to checkpoint_id [--force]
audit_rollback_to() {
    local checkpoint_id="$1"
    local force="${2:-}"

    _audit_init_journal

    # Check if rollback is enabled
    local rollback_enabled
    rollback_enabled=$(_audit_config_get "rollback.enabled" "true")

    if [[ "$rollback_enabled" != "true" ]]; then
        echo -e "${C_RED}Rollback is disabled in configuration${C_NC}" >&2
        return 1
    fi

    # Find checkpoint
    local checkpoint
    checkpoint=$(jq -r --arg id "$checkpoint_id" '.checkpoints[] | select(.id == $id)' "$AUDIT_JOURNAL")

    if [[ -z "$checkpoint" || "$checkpoint" == "null" ]]; then
        echo -e "${C_RED}Checkpoint not found: $checkpoint_id${C_NC}" >&2
        return 1
    fi

    local snapshot_file
    snapshot_file=$(echo "$checkpoint" | jq -r '.snapshot_file')
    local at_entry
    at_entry=$(echo "$checkpoint" | jq -r '.at_entry')

    # Require confirmation unless --force
    local require_confirm
    require_confirm=$(_audit_config_get "rollback.require_confirmation" "true")

    if [[ "$require_confirm" == "true" && "$force" != "--force" ]]; then
        echo -e "${C_YELLOW}WARNING: This will rollback to checkpoint $checkpoint_id${C_NC}"
        echo -e "${C_YELLOW}All changes after entry $at_entry will be reverted.${C_NC}"
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Rollback cancelled."
            return 1
        fi
    fi

    echo -e "${C_CYAN}Rolling back to checkpoint: $checkpoint_id${C_NC}"

    # Restore snapshot
    if [[ -f "$snapshot_file" ]]; then
        local snapshot
        snapshot=$(cat "$snapshot_file")

        if echo "$snapshot" | jq -e '.working' &>/dev/null; then
            echo "$snapshot" | jq '.working' > "${HARMONY_DIR}/local/memory/working.json"
            echo -e "${C_GREEN}  ✓ Restored working.json${C_NC}"
        fi

        if echo "$snapshot" | jq -e '.workflow' &>/dev/null; then
            echo "$snapshot" | jq '.workflow' > "${HARMONY_DIR}/local/memory/workflow-state.json"
            echo -e "${C_GREEN}  ✓ Restored workflow-state.json${C_NC}"
        fi
    fi

    # Revert file changes (in reverse order)
    local entries_to_revert
    entries_to_revert=$(jq -r --argjson at "$at_entry" \
        '[.entries[$at:] | reverse | .[]]' "$AUDIT_JOURNAL")

    echo "$entries_to_revert" | jq -c '.[]' 2>/dev/null | while read -r entry; do
        local file_changes
        file_changes=$(echo "$entry" | jq -r '.file_changes[]?' 2>/dev/null)

        if [[ -n "$file_changes" ]]; then
            echo "$file_changes" | jq -c '.' 2>/dev/null | while read -r change; do
                local path
                path=$(echo "$change" | jq -r '.path')
                local backup
                backup=$(echo "$change" | jq -r '.backup_file')

                if [[ -f "$backup" ]]; then
                    cp "$backup" "$path"
                    echo -e "${C_GREEN}  ✓ Restored: $path${C_NC}"
                fi
            done
        fi
    done

    # Remove entries after checkpoint
    local tmp_file
    tmp_file=$(mktemp)
    jq --argjson at "$at_entry" \
       '.entries = .entries[:$at] |
        .statistics.rollbacks_performed += 1' "$AUDIT_JOURNAL" > "$tmp_file" && mv "$tmp_file" "$AUDIT_JOURNAL"

    # Record rollback action
    audit_record_decision "system" "rollback" "$checkpoint_id" "Rolled back to checkpoint"

    echo -e "${C_GREEN}Rollback complete to checkpoint: $checkpoint_id${C_NC}"
}

# Get audit history
# Usage: audit_get_history [session_id] [limit]
audit_get_history() {
    local session_id="${1:-}"
    local limit="${2:-50}"

    _audit_init_journal

    if [[ -n "$session_id" ]]; then
        jq -r --arg sid "$session_id" --argjson limit "$limit" \
            '[.entries[] | select(.session_id == $sid)] | .[-$limit:]' "$AUDIT_JOURNAL"
    else
        jq -r --argjson limit "$limit" '.entries[-$limit:]' "$AUDIT_JOURNAL"
    fi
}

# Get history by agent
# Usage: audit_get_by_agent agent [limit]
audit_get_by_agent() {
    local agent="$1"
    local limit="${2:-50}"

    _audit_init_journal

    jq -r --arg agent "$agent" --argjson limit "$limit" \
        '[.entries[] | select(.agent == $agent)] | .[-$limit:]' "$AUDIT_JOURNAL"
}

# Export audit log
# Usage: audit_export format output_file
audit_export() {
    local format="${1:-json}"
    local output_file="$2"

    _audit_init_journal

    case "$format" in
        json)
            cp "$AUDIT_JOURNAL" "$output_file"
            ;;
        csv)
            echo "id,timestamp,session_id,agent,action,target,rationale" > "$output_file"
            jq -r '.entries[] | [.id, .timestamp, .session_id, .agent, .action, .target, .rationale] | @csv' \
                "$AUDIT_JOURNAL" >> "$output_file"
            ;;
        *)
            echo -e "${C_RED}Unknown format: $format. Use 'json' or 'csv'.${C_NC}" >&2
            return 1
            ;;
    esac

    echo -e "${C_GREEN}Exported audit log to: $output_file${C_NC}"
}

# List checkpoints
# Usage: audit_list_checkpoints [limit]
audit_list_checkpoints() {
    local limit="${1:-10}"

    _audit_init_journal

    echo -e "${C_CYAN}=== Audit Checkpoints ===${C_NC}"
    jq -r --argjson limit "$limit" \
        '.checkpoints[-$limit:] | reverse | .[] |
         "[\(.type)] \(.id) - \(.description) (entry \(.at_entry)) @ \(.timestamp)"' \
        "$AUDIT_JOURNAL"
}

# Get audit statistics
# Usage: audit_get_stats
audit_get_stats() {
    _audit_init_journal

    local stats
    stats=$(jq '.statistics' "$AUDIT_JOURNAL")

    local entry_count
    entry_count=$(jq '.entries | length' "$AUDIT_JOURNAL")

    local checkpoint_count
    checkpoint_count=$(jq '.checkpoints | length' "$AUDIT_JOURNAL")

    local agents
    agents=$(jq -r '[.entries[].agent] | unique | join(", ")' "$AUDIT_JOURNAL")

    echo -e "${C_CYAN}=== Audit Statistics ===${C_NC}"
    echo -e "Total Entries:      ${C_WHITE}$entry_count${C_NC}"
    echo -e "Total Decisions:    ${C_WHITE}$(echo "$stats" | jq -r '.total_decisions')${C_NC}"
    echo -e "Checkpoints:        ${C_WHITE}$checkpoint_count${C_NC}"
    echo -e "Rollbacks:          ${C_WHITE}$(echo "$stats" | jq -r '.rollbacks_performed')${C_NC}"
    echo -e "Sessions:           ${C_WHITE}$(echo "$stats" | jq -r '.sessions_started')${C_NC}"
    echo -e "Agents Tracked:     ${C_WHITE}$agents${C_NC}"
    echo -e "Current Session:    ${C_WHITE}${_AUDIT_CURRENT_SESSION:-none}${C_NC}"
}

# Prune old audit entries
# Usage: audit_prune [days]
audit_prune() {
    local days="${1:-$AUDIT_RETENTION_DAYS}"

    _audit_init_journal

    local before_count
    before_count=$(jq '.entries | length' "$AUDIT_JOURNAL")

    AUDIT_RETENTION_DAYS="$days"
    _audit_prune_old_entries

    local after_count
    after_count=$(jq '.entries | length' "$AUDIT_JOURNAL")

    local removed=$((before_count - after_count))
    echo -e "${C_GREEN}Pruned $removed entries older than $days days${C_NC}"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_audit_trail_self_test() {
    echo -e "${C_CYAN}=== Audit Trail Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    # Create minimal config
    cat > "$HARMONY_DIR/local/audit-config.json" << 'EOF'
{
  "retention_days": 90,
  "max_entries": 100,
  "checkpoint_interval": 5,
  "auto_checkpoint": true,
  "sensitive_fields": ["password", "token"],
  "redact_patterns": [],
  "rollback": {"enabled": true, "require_confirmation": false}
}
EOF

    local passed=0
    local failed=0

    # Test 1: Start session
    echo -n "Test 1: Start session... "
    local session_id
    session_id=$(audit_start_session "test-session" 2>/dev/null)
    if [[ "$session_id" =~ ^SES- ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Record decision
    echo -n "Test 2: Record decision... "
    local entry_id
    entry_id=$(audit_record_decision "developer" "create_file" "test.ts" "Test rationale")
    if [[ "$entry_id" =~ ^AUD- ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Create checkpoint
    echo -n "Test 3: Create checkpoint... "
    local checkpoint_id
    checkpoint_id=$(audit_create_checkpoint "manual" "Test checkpoint" 2>/dev/null)
    if [[ "$checkpoint_id" =~ ^CKP- ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Get history
    echo -n "Test 4: Get history... "
    local history
    history=$(audit_get_history)
    if [[ $(echo "$history" | jq 'length') -ge 1 ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Get stats
    echo -n "Test 5: Get stats... "
    local stats_output
    stats_output=$(audit_get_stats 2>&1)
    if [[ "$stats_output" == *"Total Entries"* ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 6: Export JSON
    echo -n "Test 6: Export JSON... "
    audit_export "json" "$test_dir/export.json" &>/dev/null
    if [[ -f "$test_dir/export.json" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 7: Export CSV
    echo -n "Test 7: Export CSV... "
    audit_export "csv" "$test_dir/export.csv" &>/dev/null
    if [[ -f "$test_dir/export.csv" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 8: Redact sensitive data
    echo -n "Test 8: Redact sensitive data... "
    local redacted
    redacted=$(_audit_redact_sensitive '{"password": "secret123", "user": "test"}')
    if [[ "$redacted" == *"[REDACTED]"* && "$redacted" == *"test"* ]]; then
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
    _audit_trail_self_test
    exit $?
fi
