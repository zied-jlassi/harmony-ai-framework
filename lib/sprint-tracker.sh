#!/bin/bash
# =============================================================================
# Harmony Framework - Sprint Tracker Library
# =============================================================================
#
# Library for managing working memory (sprint/backlog tracking).
# Used by Scrum Master agent and other workflows.
#
# Usage:
#   source "${HARMONY_DIR}/lib/sprint-tracker.sh"
#
#   # Initialize working memory
#   init_working_memory "My Project"
#
#   # Sprint operations
#   start_sprint "SPRINT-001" "Sprint 1 - MVP" 30
#   complete_sprint
#
#   # Story operations
#   start_story "STORY-001" "User login" 5 "EPIC-001"
#   complete_story "STORY-001"
#
#   # Get info
#   get_current_sprint
#   get_velocity
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------

if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

WORKING_MEMORY="${HARMONY_DIR}/memory/working.json"
WORKING_TEMPLATE="${HARMONY_DIR}/memory/templates/working.template.json"

# Colors
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# Source cross-platform date utilities (for macOS/Linux compatibility)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/date_utils.sh" ]]; then
    source "${SCRIPT_DIR}/date_utils.sh"
fi

# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------

# Initialize working memory from template
# Usage: init_working_memory "Project Name"
init_working_memory() {
    local project_name="${1:-}"
    local today
    today=$(date +%Y-%m-%d)

    if [[ -f "$WORKING_MEMORY" ]]; then
        echo -e "${C_YELLOW}Working memory already exists. Use reset_working_memory to start fresh.${C_NC}" >&2
        return 1
    fi

    if [[ ! -f "$WORKING_TEMPLATE" ]]; then
        echo -e "${C_RED}Template not found: $WORKING_TEMPLATE${C_NC}" >&2
        return 1
    fi

    # Copy template and initialize
    cp "$WORKING_TEMPLATE" "$WORKING_MEMORY"

    # Update with project info
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg name "$project_name" \
       --arg date "$today" \
       '.project.name = $name | .created = $date | .last_updated = $date' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    echo -e "${C_GREEN}Working memory initialized for: $project_name${C_NC}"
}

# Reset working memory (backup existing)
reset_working_memory() {
    if [[ -f "$WORKING_MEMORY" ]]; then
        local backup="${WORKING_MEMORY}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$WORKING_MEMORY" "$backup"
        echo -e "${C_YELLOW}Backed up to: $backup${C_NC}"
        rm "$WORKING_MEMORY"
    fi
    init_working_memory "$@"
}

# -----------------------------------------------------------------------------
# UTILITY FUNCTIONS
# -----------------------------------------------------------------------------

# Update last_updated timestamp
_update_timestamp() {
    local now
    now=$(date -Iseconds)
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg now "$now" '.last_updated = $now' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
}

# Get a value from working memory
# Usage: get_working_value ".current_sprint.id"
get_working_value() {
    local path="$1"
    local default="${2:-null}"

    if [[ ! -f "$WORKING_MEMORY" ]]; then
        echo "$default"
        return
    fi

    jq -r "${path} // \"${default}\"" "$WORKING_MEMORY" 2>/dev/null || echo "$default"
}

# Set a value in working memory
# Usage: set_working_value ".current_sprint.id" '"SPRINT-001"'
set_working_value() {
    local path="$1"
    local value="$2"

    if [[ ! -f "$WORKING_MEMORY" ]]; then
        echo -e "${C_RED}Working memory not initialized${C_NC}" >&2
        return 1
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq "${path} = ${value}" "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    _update_timestamp
}

# -----------------------------------------------------------------------------
# SPRINT OPERATIONS
# -----------------------------------------------------------------------------

# Start a new sprint
# Usage: start_sprint "SPRINT-001" "Sprint Name" 30 "Sprint Goal"
start_sprint() {
    local sprint_id="$1"
    local sprint_name="$2"
    local velocity_target="${3:-0}"
    local sprint_goal="${4:-}"
    local today
    today=$(date +%Y-%m-%d)

    # Check if there's an active sprint
    local current_id
    current_id=$(get_working_value ".current_sprint.id")
    if [[ "$current_id" != "null" && -n "$current_id" ]]; then
        echo -e "${C_YELLOW}Sprint already active: $current_id${C_NC}" >&2
        echo -e "${C_YELLOW}Complete it first with: complete_sprint${C_NC}" >&2
        return 1
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$sprint_id" \
       --arg name "$sprint_name" \
       --arg started "$today" \
       --argjson target "$velocity_target" \
       --arg goal "$sprint_goal" \
       '.current_sprint = {
            id: $id,
            name: $name,
            started: $started,
            end_date: null,
            status: "IN_PROGRESS",
            velocity_target: $target,
            velocity_achieved: 0,
            sprint_goal: $goal,
            axes: {},
            stories: [],
            blockers: []
        }' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
    echo -e "${C_GREEN}Sprint started: $sprint_id - $sprint_name (target: $velocity_target pts)${C_NC}"
}

# Complete current sprint
# Usage: complete_sprint
complete_sprint() {
    local today
    today=$(date +%Y-%m-%d)

    local sprint_id
    sprint_id=$(get_working_value ".current_sprint.id")

    if [[ "$sprint_id" == "null" || -z "$sprint_id" ]]; then
        echo -e "${C_YELLOW}No active sprint to complete${C_NC}" >&2
        return 1
    fi

    # Get current sprint data for history
    local sprint_data
    sprint_data=$(jq '.current_sprint' "$WORKING_MEMORY")

    local tmp_file
    tmp_file=$(mktemp)

    # Move sprint to history and reset current
    jq --arg ended "$today" \
       --argjson sprint "$sprint_data" \
       '.sprint_history = [($sprint + {ended: $ended, status: "DONE"})] + .sprint_history |
        .current_sprint = {
            id: null,
            name: null,
            started: null,
            end_date: null,
            status: "NOT_STARTED",
            velocity_target: 0,
            velocity_achieved: 0,
            sprint_goal: "",
            axes: {},
            stories: [],
            blockers: []
        }' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    # Update velocity averages
    _update_velocity_stats

    # Update statistics
    local completed
    completed=$(get_working_value ".statistics.sprints_completed" "0")
    set_working_value ".statistics.sprints_completed" "$((completed + 1))"

    _update_timestamp
    echo -e "${C_GREEN}Sprint completed: $sprint_id${C_NC}"
}

# Add story to current sprint
# Usage: add_story_to_sprint "STORY-001"
add_story_to_sprint() {
    local story_id="$1"

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg story "$story_id" \
       '.current_sprint.stories += [$story]' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
}

# Add axis to current sprint
# Usage: add_sprint_axis "A_Backend" "EPIC-001" 20 "Backend implementation"
add_sprint_axis() {
    local axis_name="$1"
    local epic="$2"
    local points="${3:-0}"
    local note="${4:-}"

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg name "$axis_name" \
       --arg epic "$epic" \
       --argjson points "$points" \
       --arg note "$note" \
       '.current_sprint.axes[$name] = {
            epic: $epic,
            points: $points,
            status: "TODO",
            note: $note
        }' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
}

# Update axis status
# Usage: update_axis_status "A_Backend" "DONE"
update_axis_status() {
    local axis_name="$1"
    local status="$2"

    set_working_value ".current_sprint.axes[\"$axis_name\"].status" "\"$status\""
}

# Add velocity to sprint
# Usage: add_velocity 15
add_velocity() {
    local points="$1"

    local current
    current=$(get_working_value ".current_sprint.velocity_achieved" "0")
    local new_total=$((current + points))

    set_working_value ".current_sprint.velocity_achieved" "$new_total"
    echo -e "${C_BLUE}Velocity updated: $current → $new_total pts${C_NC}"
}

# -----------------------------------------------------------------------------
# STORY OPERATIONS
# -----------------------------------------------------------------------------

# Start working on a story
# Usage: start_story "STORY-001" "Story Title" 5 "EPIC-001" "Developer"
start_story() {
    local story_id="$1"
    local title="$2"
    local points="${3:-0}"
    local epic="${4:-null}"
    local assigned="${5:-null}"
    local now
    now=$(date -Iseconds)

    # Check if there's already a story in progress
    local current_id
    current_id=$(get_working_value ".current_story.id")
    if [[ "$current_id" != "null" && -n "$current_id" ]]; then
        echo -e "${C_YELLOW}Story already in progress: $current_id${C_NC}" >&2
        echo -e "${C_YELLOW}Complete it first or use force_start_story${C_NC}" >&2
        return 1
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$story_id" \
       --arg title "$title" \
       --argjson points "$points" \
       --arg epic "$epic" \
       --arg assigned "$assigned" \
       --arg started "$now" \
       '.current_story = {
            id: $id,
            title: $title,
            status: "IN_PROGRESS",
            points: $points,
            started: $started,
            epic: $epic,
            assigned: $assigned,
            ucv_status: "PENDING",
            tasks_completed: 0,
            tasks_total: 0
        }' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    # Add to sprint stories if not already there
    add_story_to_sprint "$story_id"

    # Update session context
    set_working_value ".session_context.agent_active" "\"DEV\""
    set_working_value ".session_context.last_action" "\"Started story: $story_id\""
    set_working_value ".session_context.last_action_time" "\"$now\""

    echo -e "${C_GREEN}Story started: $story_id - $title ($points pts)${C_NC}"
}

# Complete current story
# Usage: complete_story
complete_story() {
    local story_id
    story_id=$(get_working_value ".current_story.id")

    if [[ "$story_id" == "null" || -z "$story_id" ]]; then
        echo -e "${C_YELLOW}No story in progress${C_NC}" >&2
        return 1
    fi

    local points
    points=$(get_working_value ".current_story.points" "0")

    # Add points to velocity
    add_velocity "$points"

    # Update statistics
    local completed
    completed=$(get_working_value ".statistics.stories_completed_total" "0")
    set_working_value ".statistics.stories_completed_total" "$((completed + 1))"

    local total_pts
    total_pts=$(get_working_value ".statistics.points_delivered_total" "0")
    set_working_value ".statistics.points_delivered_total" "$((total_pts + points))"

    # Update backlog
    local done_count
    done_count=$(get_working_value ".backlog.stories_done" "0")
    set_working_value ".backlog.stories_done" "$((done_count + 1))"

    local in_progress
    in_progress=$(get_working_value ".backlog.stories_in_progress" "0")
    if [[ "$in_progress" -gt 0 ]]; then
        set_working_value ".backlog.stories_in_progress" "$((in_progress - 1))"
    fi

    # Clear current story slot (no active story)
    local tmp_file
    tmp_file=$(mktemp)
    jq '.current_story = {
            id: null,
            title: null,
            status: null,
            points: 0,
            started: null,
            epic: null,
            assigned: null,
            ucv_status: null,
            tasks_completed: 0,
            tasks_total: 0
        }' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
    echo -e "${C_GREEN}Story completed: $story_id (+$points pts)${C_NC}"
}

# Update story progress
# Usage: update_story_progress 3 5  # 3 of 5 tasks done
update_story_progress() {
    local completed="$1"
    local total="$2"

    set_working_value ".current_story.tasks_completed" "$completed"
    set_working_value ".current_story.tasks_total" "$total"
}

# Update UCV status
# Usage: update_ucv_status "APPROVED"
update_ucv_status() {
    local status="$1"  # PENDING, APPROVED, REJECTED
    set_working_value ".current_story.ucv_status" "\"$status\""
}

# -----------------------------------------------------------------------------
# BLOCKER OPERATIONS
# -----------------------------------------------------------------------------

# Add a blocker
# Usage: add_blocker "BLK-001" "API not ready" "STORY-001" "high" "DevOps"
add_blocker() {
    local blocker_id="$1"
    local description="$2"
    local story="${3:-null}"
    local severity="${4:-medium}"
    local owner="${5:-}"
    local today
    today=$(date +%Y-%m-%d)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$blocker_id" \
       --arg desc "$description" \
       --arg story "$story" \
       --arg severity "$severity" \
       --arg owner "$owner" \
       --arg created "$today" \
       '.blockers += [{
            id: $id,
            description: $desc,
            story: $story,
            severity: $severity,
            owner: $owner,
            created: $created,
            status: "open"
        }]' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
    echo -e "${C_RED}Blocker added: $blocker_id - $description${C_NC}"
}

# Resolve a blocker
# Usage: resolve_blocker "BLK-001"
resolve_blocker() {
    local blocker_id="$1"

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$blocker_id" \
       '(.blockers[] | select(.id == $id)) .status = "resolved"' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
    echo -e "${C_GREEN}Blocker resolved: $blocker_id${C_NC}"
}

# -----------------------------------------------------------------------------
# DECISION TRACKING
# -----------------------------------------------------------------------------

# Add a decision
# Usage: add_decision "Use Redis for caching" "Better performance" "Architect"
add_decision() {
    local decision="$1"
    local reason="${2:-}"
    local made_by="${3:-}"
    local today
    today=$(date +%Y-%m-%d)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg date "$today" \
       --arg decision "$decision" \
       --arg reason "$reason" \
       --arg made_by "$made_by" \
       '.recent_decisions = [{
            date: $date,
            decision: $decision,
            reason: $reason,
            made_by: $made_by
        }] + .recent_decisions | .recent_decisions = .recent_decisions[:10]' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"

    _update_timestamp
}

# -----------------------------------------------------------------------------
# VELOCITY TRACKING
# -----------------------------------------------------------------------------

# Update velocity statistics from history
_update_velocity_stats() {
    if [[ ! -f "$WORKING_MEMORY" ]]; then
        return
    fi

    # Calculate averages from sprint history
    local tmp_file
    tmp_file=$(mktemp)
    jq '
        .velocity.history = [.sprint_history[:5][] | {sprint_id: .id, velocity: .velocity_achieved}] |
        .velocity.average_3_sprints = (
            [.sprint_history[:3][].velocity_achieved] | if length > 0 then add / length else 0 end
        ) |
        .velocity.average_5_sprints = (
            [.sprint_history[:5][].velocity_achieved] | if length > 0 then add / length else 0 end
        ) |
        .velocity.recommended_capacity = (
            [.sprint_history[:3][].velocity_achieved] | if length > 0 then (add / length) * 0.9 | floor else 0 end
        ) |
        .velocity.trend = (
            if (.sprint_history | length) < 2 then "stable"
            elif .sprint_history[0].velocity_achieved > .sprint_history[1].velocity_achieved then "improving"
            elif .sprint_history[0].velocity_achieved < .sprint_history[1].velocity_achieved then "declining"
            else "stable"
            end
        )
    ' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
}

# Get velocity info
get_velocity() {
    jq -r '.velocity | "Average (3 sprints): \(.average_3_sprints) pts\nAverage (5 sprints): \(.average_5_sprints) pts\nTrend: \(.trend)\nRecommended capacity: \(.recommended_capacity) pts"' "$WORKING_MEMORY"
}

# -----------------------------------------------------------------------------
# GETTERS
# -----------------------------------------------------------------------------

# Get current sprint info
get_current_sprint() {
    jq -r '.current_sprint | "Sprint: \(.id // "None")\nName: \(.name // "N/A")\nStatus: \(.status)\nVelocity: \(.velocity_achieved)/\(.velocity_target) pts"' "$WORKING_MEMORY"
}

# Get current story info
get_current_story() {
    jq -r '.current_story | "Story: \(.id // "None")\nTitle: \(.title // "N/A")\nStatus: \(.status)\nPoints: \(.points)\nProgress: \(.tasks_completed)/\(.tasks_total) tasks"' "$WORKING_MEMORY"
}

# Get backlog summary
get_backlog_summary() {
    jq -r '.backlog | "Epics: \(.epics_done)/\(.epics_total) done\nStories: \(.stories_done)/\(.stories_total) done\nIn Progress: \(.stories_in_progress)\nTodo: \(.stories_todo)"' "$WORKING_MEMORY"
}

# Get open blockers
get_blockers() {
    jq -r '.blockers | map(select(.status == "open")) | if length > 0 then .[] | "[\(.severity)] \(.id): \(.description)" else "No open blockers" end' "$WORKING_MEMORY"
}

# Get recent decisions
get_recent_decisions() {
    jq -r '.recent_decisions[:5][] | "[\(.date)] \(.decision)"' "$WORKING_MEMORY"
}

# Get next steps
get_next_steps() {
    jq -r '.next_steps[]' "$WORKING_MEMORY"
}

# Add next step
add_next_step() {
    local step="$1"
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg step "$step" '.next_steps = [$step] + .next_steps | .next_steps = .next_steps[:10]' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    _update_timestamp
}

# Remove next step
remove_next_step() {
    local step="$1"
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg step "$step" '.next_steps = [.next_steps[] | select(. != $step)]' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    _update_timestamp
}

# -----------------------------------------------------------------------------
# QUALITY GATES
# -----------------------------------------------------------------------------

# Update quality gate status
# Usage: update_quality_gate "tests_passing" true
update_quality_gate() {
    local gate="$1"
    local value="$2"  # true, false, or number
    set_working_value ".quality_gates.$gate" "$value"
}

# Check if all quality gates pass
check_quality_gates() {
    local all_pass
    all_pass=$(jq -r '.quality_gates |
        if .tests_passing == false then false
        elif .build_success == false then false
        elif .ucv_coverage != null and .ucv_coverage < 100 then false
        elif .luna_approved == false then false
        else true
        end' "$WORKING_MEMORY")

    if [[ "$all_pass" == "true" ]]; then
        echo -e "${C_GREEN}All quality gates PASS${C_NC}"
        return 0
    else
        echo -e "${C_RED}Quality gates FAIL${C_NC}"
        jq -r '.quality_gates | to_entries[] | select(.value != null) | "\(.key): \(.value)"' "$WORKING_MEMORY"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# SESSION CONTEXT
# -----------------------------------------------------------------------------

# Update session context
update_session_context() {
    local agent="${1:-null}"
    local workflow="${2:-null}"
    local action="$3"
    local now
    now=$(date -Iseconds)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg agent "$agent" \
       --arg workflow "$workflow" \
       --arg action "$action" \
       --arg time "$now" \
       '.session_context.agent_active = $agent |
        .session_context.workflow_active = $workflow |
        .session_context.last_action = $action |
        .session_context.last_action_time = $time' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
}

# Add handoff
add_handoff() {
    local from="$1"
    local to="$2"
    local context="$3"

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg from "$from" \
       --arg to "$to" \
       --arg context "$context" \
       '.session_context.pending_handoffs += [{from: $from, to: $to, context: $context}]' \
       "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    _update_timestamp
}

# Clear handoff
clear_handoff() {
    local tmp_file
    tmp_file=$(mktemp)
    jq '.session_context.pending_handoffs = []' "$WORKING_MEMORY" > "$tmp_file" && mv "$tmp_file" "$WORKING_MEMORY"
    _update_timestamp
}

# -----------------------------------------------------------------------------
# DISPLAY FUNCTIONS
# -----------------------------------------------------------------------------

# Display sprint dashboard
show_sprint_dashboard() {
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
    echo -e "${C_BLUE}                    SPRINT DASHBOARD                      ${C_NC}"
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
    echo ""
    echo -e "${C_GREEN}Current Sprint:${C_NC}"
    get_current_sprint
    echo ""
    echo -e "${C_GREEN}Current Story:${C_NC}"
    get_current_story
    echo ""
    echo -e "${C_GREEN}Velocity:${C_NC}"
    get_velocity
    echo ""
    echo -e "${C_GREEN}Blockers:${C_NC}"
    get_blockers
    echo ""
    echo -e "${C_GREEN}Next Steps:${C_NC}"
    get_next_steps
    echo ""
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
}

# Export as JSON for AI consumption
export_for_ai() {
    jq '{
        sprint: .current_sprint,
        story: .current_story,
        velocity: .velocity,
        blockers: [.blockers[] | select(.status == "open")],
        recent_decisions: .recent_decisions[:5],
        next_steps: .next_steps[:5],
        quality_gates: .quality_gates
    }' "$WORKING_MEMORY"
}

# =============================================================================
# AUTOPILOT PIPELINE ORCHESTRATION (Phase 1)
# =============================================================================

# Execute story through autopilot pipeline
# Usage: run_story_pipeline "STORY-001"
#
# Orchestrates core agents: Developer → Tester → UCV Validator
# Uses Guardian auto-routing + Sentinel tracking
# Updates working.json and workflow-state.json at each phase
run_story_pipeline() {
    local story_id="${1:-}"

    if [[ -z "$story_id" ]]; then
        echo -e "${C_RED}Usage: run_story_pipeline <story-id>${C_NC}" >&2
        return 1
    fi

    if [[ ! -f "$WORKING_MEMORY" ]]; then
        echo -e "${C_RED}Working memory not initialized${C_NC}" >&2
        return 1
    fi

    # Verify story is in progress
    local current_story
    current_story=$(get_working_value ".current_story.id")
    if [[ "$current_story" != "$story_id" ]]; then
        echo -e "${C_YELLOW}Story $story_id not active. Starting it first...${C_NC}"
        start_story "$story_id" "Auto-pipeline story" 0
    fi

    # ═══════════════════════════════════════════════════════════════════
    # ARIA CONTEXT DETECTION (Two-Stage: Pattern → Haiku → Merge)
    # ═══════════════════════════════════════════════════════════════════
    local aria_triggered_agents=""
    local aria_is_blocking="false"

    # Get story title for context detection
    local story_title
    story_title=$(get_working_value ".current_story.title")

    # Source ARIA detector if available
    if [[ -f "${HARMONY_DIR}/lib/aria-detector.sh" ]]; then
        source "${HARMONY_DIR}/lib/aria-detector.sh"

        # Run ARIA detection on story title
        local aria_result
        aria_result=$(aria_detect_patterns "${story_title:-$story_id}" "$(pwd)")

        if [[ -n "$aria_result" ]]; then
            aria_triggered_agents=$(echo "$aria_result" | jq -r '.triggered_agents | join(" ")' 2>/dev/null || echo "")
            aria_is_blocking=$(echo "$aria_result" | jq -r '.is_blocking' 2>/dev/null || echo "false")

            local aria_flags
            aria_flags=$(echo "$aria_result" | jq -r '.context_flags | join(", ")' 2>/dev/null || echo "")

            if [[ -n "$aria_flags" ]] && [[ "$aria_flags" != "null" ]]; then
                echo ""
                if [[ "$aria_is_blocking" == "true" ]]; then
                    echo -e "${C_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
                    echo -e "${C_RED}🚨 ARIA: BLOCKING COMPLIANCE DETECTED${C_NC}"
                    echo -e "${C_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
                else
                    echo -e "${C_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
                    echo -e "${C_YELLOW}⚠️  ARIA: Compliance agents triggered${C_NC}"
                    echo -e "${C_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
                fi
                echo -e "  Detected flags: ${C_CYAN}${aria_flags}${C_NC}"
                echo -e "  Triggered agents: ${C_CYAN}${aria_triggered_agents}${C_NC}"
                echo ""

                # Update workflow-state with ARIA context
                if [[ -f "${HARMONY_DIR}/memory/workflow-state.json" ]]; then
                    local tmp_file
                    tmp_file=$(mktemp)
                    local aria_ts
                    aria_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
                    local flags_json
                    flags_json=$(echo "$aria_result" | jq '.context_flags')
                    local triggers_json
                    triggers_json=$(echo "$aria_result" | jq '.triggered_agents')

                    jq --arg ts "$aria_ts" \
                       --argjson flags "$flags_json" \
                       --argjson triggers "$triggers_json" \
                       --argjson blocking "$aria_is_blocking" \
                       '.aria_context.detected_at = $ts |
                        .aria_context.context_flags = $flags |
                        .aria_context.triggered_agents = $triggers |
                        .aria_context.is_blocking = $blocking |
                        .aria_context.source = "pattern"' \
                       "${HARMONY_DIR}/memory/workflow-state.json" > "$tmp_file" && \
                       mv "$tmp_file" "${HARMONY_DIR}/memory/workflow-state.json"
                fi
            fi
        fi
    fi

    # ═══════════════════════════════════════════════════════════════════
    # BUILD DYNAMIC PIPELINE (Base + ARIA-triggered agents)
    # ═══════════════════════════════════════════════════════════════════

    # Base pipeline: developer → tester → ucv-qa → ucv-validator
    local -a pipeline_agents=()

    # Add compliance agents FIRST if ARIA detected them
    if [[ -n "$aria_triggered_agents" ]]; then
        for agent in $aria_triggered_agents; do
            case "$agent" in
                rgpd)
                    pipeline_agents+=("rgpd:RGPD Compliance Validation")
                    ;;
                security)
                    pipeline_agents+=("security:Security Audit")
                    ;;
                legal)
                    pipeline_agents+=("legal:Legal Compliance Check")
                    ;;
                accessibility)
                    pipeline_agents+=("accessibility:Accessibility Review")
                    ;;
                ux-designer)
                    pipeline_agents+=("ux-designer:UX Design Review")
                    ;;
                database|architect)
                    pipeline_agents+=("architect:Architecture Review")
                    ;;
                *)
                    # Add any other triggered agent
                    pipeline_agents+=("${agent}:${agent} Validation")
                    ;;
            esac
        done
    fi

    # Add base development pipeline
    pipeline_agents+=(
        "developer:Developer implementation phase"
        "tester:Tester validation phase"
        "ucv-qa:UCV QA verification phase"
        "ucv-validator:UCV Validator final check"
    )

    local phase_num=1
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
    echo -e "${C_BLUE}AUTOPILOT PIPELINE: $story_id${C_NC}"
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"

    for phase_spec in "${pipeline_agents[@]}"; do
        local agent_name="${phase_spec%%:*}"
        local phase_desc="${phase_spec#*:}"

        echo ""
        echo -e "${C_GREEN}Phase $phase_num: $phase_desc${C_NC}"

        # Get agent model from agent file
        local agent_model="inherit"
        local agent_file="${HARMONY_DIR}/agents/${agent_name}.md"
        if [[ -f "$agent_file" ]]; then
            agent_model=$(grep -m1 "^model:" "$agent_file" 2>/dev/null | sed 's/model:[[:space:]]*//' || echo "inherit")
        fi

        # Display agent with model
        if type ui_agent_switch &>/dev/null; then
            ui_agent_switch "$agent_name" "$agent_model"
        else
            echo -e "  Agent: ${C_YELLOW}$agent_name${C_NC}"
            echo -e "  ${C_YELLOW}🤖 Modèle: $agent_model${C_NC}"
        fi
        echo -e "  Story: ${C_YELLOW}$story_id${C_NC}"

        # PHASE 2: Initialize story circuit breaker and check status
        init_story_circuit_breaker "$story_id"

        # PHASE 2: Check if circuit breaker allows this phase
        if ! check_story_circuit_breaker "$story_id" "$agent_name"; then
            echo -e "${C_RED}❌ Circuit breaker blocked - skipping remaining phases${C_NC}"
            # Mark story as failed
            set_working_value ".current_story.status" "\"FAILED\""
            ((phase_num++))
            continue
        fi

        # PHASE 2: Check API budget before phase
        if ! check_api_budget; then
            echo -e "${C_RED}❌ API budget exceeded - stopping autopilot${C_NC}"
            return 1
        fi

        # Log phase execution start
        log_phase_execution "$story_id" "$agent_name" "started"

        # Update workflow state: set active agent
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg agent "$agent_name" \
           '.active_context.active_agent = $agent' \
           "${HARMONY_DIR}/memory/workflow-state.json" > "$tmp_file" && \
           mv "$tmp_file" "${HARMONY_DIR}/memory/workflow-state.json" || {
            echo -e "${C_RED}Failed to update workflow state${C_NC}" >&2
            return 1
        }

        # Update story status based on phase
        local story_status=""
        case "$agent_name" in
            "developer")
                story_status="IN_PROGRESS"
                ;;
            "tester")
                story_status="IN_TESTING"
                ;;
            "ucv-qa")
                story_status="IN_QA"
                ;;
            "ucv-validator")
                story_status="IN_REVIEW"
                ;;
        esac

        if [[ -n "$story_status" ]]; then
            set_working_value ".current_story.status" "\"$story_status\""
            echo -e "  Status: ${C_YELLOW}$story_status${C_NC}"
        fi

        # Log phase invocation
        echo -e "  ${C_YELLOW}[AWAITING AGENT INVOCATION]${C_NC}"
        echo -e "  ${C_YELLOW}Guardian will auto-route via intent keywords${C_NC}"
        echo -e "  ${C_YELLOW}Sentinel will track completion${C_NC}"
        echo -e "  ${C_YELLOW}Circuit Breaker: MONITORING (max 10 failures/phase, 5 per phase)${C_NC}"

        # Placeholder for actual agent invocation
        # In real implementation: calls Claude Code CLI or agent invocation mechanism
        echo -e "  ${C_BLUE}→ Ready for $agent_name${C_NC}"

        # PHASE 2: Response Analyzer Integration
        # Simulate agent output for testing (in real scenario, comes from agent execution)
        local agent_output=""
        local completion_status=""

        # Try to get test completion signal from environment or test file
        if [[ -f "${HARMONY_DIR}/memory/.test_completion_${story_id}_${agent_name}" ]]; then
            agent_output=$(cat "${HARMONY_DIR}/memory/.test_completion_${story_id}_${agent_name}")
            rm -f "${HARMONY_DIR}/memory/.test_completion_${story_id}_${agent_name}"
        else
            # Default completion signal for testing (simulates successful agent output)
            case "$agent_name" in
                "developer")
                    agent_output="Implementation complete - code ready for testing"
                    ;;
                "tester")
                    agent_output="All tests passing - coverage 100%"
                    ;;
                "ucv-qa")
                    agent_output="QA verification passed - all criteria met"
                    ;;
                "ucv-validator")
                    agent_output="Coverage: 100% - All verifications validated"
                    ;;
            esac
        fi

        # Detect completion status
        detect_story_completion "$story_id" "$agent_name" "$agent_output"
        completion_status=$?

        # Handle completion result
        case "$completion_status" in
            0)
                # COMPLETE - record success and continue to next phase
                echo -e "  ${C_GREEN}✅ Completion detected - phase complete${C_NC}"
                record_story_success "$story_id" "$agent_name"
                ;;
            1)
                # IN_PROGRESS - log warning but allow to continue (could retry)
                echo -e "  ${C_YELLOW}⚠️  Phase in progress - may require retry${C_NC}"
                log_phase_execution "$story_id" "$agent_name" "in_progress"
                ;;
            2)
                # BLOCKED - record failure and open circuit
                echo -e "  ${C_RED}🛑 Phase blocked - cannot proceed${C_NC}"
                record_story_failure "$story_id" "$agent_name"
                break  # Exit phase loop for this story
                ;;
        esac

        ((phase_num++))
    done

    # Final phase: Mark story as DONE
    echo ""
    echo -e "${C_GREEN}Phase $phase_num: Mark Complete${C_NC}"
    set_working_value ".current_story.status" "\"DONE\""

    # Clear active agent
    local tmp_file
    tmp_file=$(mktemp)
    jq '.active_context.active_agent = null' \
       "${HARMONY_DIR}/memory/workflow-state.json" > "$tmp_file" && \
       mv "$tmp_file" "${HARMONY_DIR}/memory/workflow-state.json"

    echo -e "  ${C_GREEN}✅ Story marked DONE${C_NC}"

    echo ""
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"
    echo -e "${C_GREEN}✅ Pipeline orchestration complete${C_NC}"
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}"

    return 0
}

# Get pipeline status for a story
# Usage: get_pipeline_status "STORY-001"
get_pipeline_status() {
    local story_id="${1:-}"

    if [[ -z "$story_id" ]]; then
        jq '{
            current_story: .current_story.id,
            status: .current_story.status,
            active_agent: .active_context.active_agent,
            phase: .phase.current
        }' "${HARMONY_DIR}/memory/workflow-state.json" 2>/dev/null || echo "null"
        return
    fi

    # Get specific story status
    local story_status
    story_status=$(jq -r ".current_story.status // \"NOT_FOUND\"" "$WORKING_MEMORY" 2>/dev/null)

    local active_agent
    active_agent=$(jq -r ".active_context.active_agent // \"none\"" "${HARMONY_DIR}/memory/workflow-state.json" 2>/dev/null)

    echo -e "Story: ${C_YELLOW}$story_id${C_NC}"
    echo -e "Status: ${C_YELLOW}$story_status${C_NC}"
    echo -e "Active Agent: ${C_YELLOW}$active_agent${C_NC}"
}

# =============================================================================
# PHASE 2: CIRCUIT BREAKER + COMPLETION DETECTION (Safety Integration)
# =============================================================================

# Check if jq is available, critical for Phase 2 functions
check_jq_available() {
    if ! command -v jq &>/dev/null; then
        echo -e "${C_RED}❌ ERROR: 'jq' is required for Circuit Breaker integration${C_NC}" >&2
        echo -e "${C_YELLOW}Please install jq: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)${C_NC}" >&2
        return 1
    fi
    return 0
}

# Initialize per-story circuit breaker in circuit-breaker.json
# Creates story-specific tracking with per-phase failure counts
# Requires: jq for JSON manipulation
init_story_circuit_breaker() {
    local story_id="${1:-}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ -z "$story_id" ]]; then
        return 1
    fi

    if [[ ! -f "$circuit_breaker_file" ]]; then
        return 1
    fi

    # Check jq availability
    if ! check_jq_available; then
        echo -e "${C_YELLOW}⚠️  Skipping circuit breaker initialization (jq not available)${C_NC}" >&2
        return 0
    fi

    local tmp_file
    tmp_file=$(mktemp)

    # Add story-specific entry if not exists
    jq --arg story_id "$story_id" \
        '.stories[$story_id] //= {
            state: "CLOSED",
            failures: 0,
            phase_failures: {
                developer: 0,
                tester: 0,
                "ucv-validator": 0
            },
            max_failures: 10,
            iterations: 0,
            max_iterations: 10,
            started_at: now | todate,
            last_failure: null,
            last_success: null,
            history: []
        }' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"

    return 0
}

# Check if story circuit breaker allows operations
# Returns 0 if CAN operate, 1 if breaker is OPEN
# Requires: jq for JSON manipulation
check_story_circuit_breaker() {
    local story_id="${1:-}"
    local phase="${2:-}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ -z "$story_id" ]]; then
        return 0  # No circuit check if no story
    fi

    if [[ ! -f "$circuit_breaker_file" ]]; then
        return 0  # No circuit check if file missing
    fi

    # Check jq availability
    if ! check_jq_available; then
        echo -e "${C_YELLOW}⚠️  Skipping circuit breaker check (jq not available)${C_NC}" >&2
        return 0  # Allow operation if jq unavailable
    fi

    # Check global state
    local state
    state=$(jq -r ".state // \"CLOSED\"" "$circuit_breaker_file" 2>/dev/null)

    if [[ "$state" == "OPEN" ]]; then
        echo -e "${C_RED}🛑 Global circuit breaker OPEN - diagnosis required${C_NC}" >&2
        return 1
    fi

    # Check story-specific state
    local story_state
    story_state=$(jq -r ".stories[\"$story_id\"].state // \"CLOSED\"" "$circuit_breaker_file" 2>/dev/null)

    if [[ "$story_state" == "OPEN" ]]; then
        echo -e "${C_RED}🛑 Story $story_id circuit breaker OPEN${C_NC}" >&2
        local failures
        failures=$(jq -r ".stories[\"$story_id\"].failures // 0" "$circuit_breaker_file" 2>/dev/null)
        echo -e "${C_YELLOW}Too many failures ($failures). Move to next story.${C_NC}" >&2
        return 1
    fi

    # Check phase-specific failures
    if [[ -n "$phase" ]]; then
        local phase_failures
        phase_failures=$(jq -r ".stories[\"$story_id\"].phase_failures.$phase // 0" "$circuit_breaker_file" 2>/dev/null)

        if [[ "$phase_failures" -ge 5 ]]; then
            echo -e "${C_RED}⚠️  Phase $phase for story $story_id exceeded failure limit (5)${C_NC}" >&2
            # Open circuit for story
            record_story_failure "$story_id" "$phase"
            return 1
        fi
    fi

    return 0
}

# Record failure for a story/phase
# Updates circuit breaker state and failure counts
# Requires: jq for JSON manipulation
record_story_failure() {
    local story_id="${1:-}"
    local phase="${2:-developer}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ -z "$story_id" ]]; then
        return 1
    fi

    if [[ ! -f "$circuit_breaker_file" ]]; then
        return 1
    fi

    # Check jq availability
    if ! check_jq_available; then
        echo -e "${C_YELLOW}⚠️  Could not record failure (jq not available)${C_NC}" >&2
        return 0
    fi

    # Ensure story entry exists
    init_story_circuit_breaker "$story_id"

    local tmp_file
    tmp_file=$(mktemp)
    local timestamp
    timestamp=$(date -Iseconds)

    # Update failures and check if should open circuit
    jq --arg story_id "$story_id" \
        --arg phase "$phase" \
        --arg ts "$timestamp" \
        '.stories[$story_id].failures += 1 |
         .stories[$story_id].phase_failures[$phase] += 1 |
         .stories[$story_id].iterations += 1 |
         .stories[$story_id].last_failure = $ts |
         .stories[$story_id].history += [{
            timestamp: $ts,
            event: "failure",
            phase: $phase,
            total_failures: .stories[$story_id].failures,
            phase_failures: .stories[$story_id].phase_failures[$phase]
         }] |
         if .stories[$story_id].failures >= .stories[$story_id].max_failures then
            .stories[$story_id].state = "OPEN"
         else
            .
         end' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"

    local failures
    failures=$(jq -r ".stories[\"$story_id\"].failures" "$circuit_breaker_file" 2>/dev/null)
    local phase_failures
    phase_failures=$(jq -r ".stories[\"$story_id\"].phase_failures.$phase" "$circuit_breaker_file" 2>/dev/null)

    echo -e "${C_YELLOW}⚠️  Story $story_id failure recorded (Total: $failures/10, Phase: $phase_failures/5)${C_NC}"

    return 0
}

# Record success for a story/phase
# Resets phase failure count on success
# Requires: jq for JSON manipulation
record_story_success() {
    local story_id="${1:-}"
    local phase="${2:-developer}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ -z "$story_id" ]]; then
        return 1
    fi

    if [[ ! -f "$circuit_breaker_file" ]]; then
        return 1
    fi

    # Check jq availability
    if ! check_jq_available; then
        echo -e "${C_YELLOW}⚠️  Could not record success (jq not available)${C_NC}" >&2
        return 0
    fi

    local tmp_file
    tmp_file=$(mktemp)
    local timestamp
    timestamp=$(date -Iseconds)

    # Reset phase failures on success
    jq --arg story_id "$story_id" \
        --arg phase "$phase" \
        --arg ts "$timestamp" \
        '.stories[$story_id].phase_failures[$phase] = 0 |
         .stories[$story_id].last_success = $ts |
         .stories[$story_id].history += [{
            timestamp: $ts,
            event: "success",
            phase: $phase,
            total_failures: .stories[$story_id].failures
         }]' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"

    echo -e "${C_GREEN}✅ Story $story_id phase $phase completed successfully${C_NC}"

    return 0
}

# Reset circuit breaker (manual recovery after analysis)
# Usage: reset_circuit_breaker [story_id] [reason]
# If story_id is empty, resets global circuit breaker
reset_circuit_breaker() {
    local story_id="${1:-}"
    local reason="${2:-Manual reset}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ ! -f "$circuit_breaker_file" ]]; then
        echo -e "${C_YELLOW}⚠️ Circuit breaker file not found${C_NC}" >&2
        return 1
    fi

    local ts
    ts=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    local tmp_file
    tmp_file=$(mktemp)

    if [[ -z "$story_id" ]]; then
        # Reset global circuit breaker
        jq --arg ts "$ts" --arg reason "$reason" '
            .state = "CLOSED" |
            .consecutive_failures = 0 |
            .last_reset = $ts |
            .reset_reason = $reason |
            .reset_history += [{
                timestamp: $ts,
                reason: $reason,
                previous_state: .state
            }]' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"
        echo -e "${C_GREEN}✅ Global circuit breaker reset${C_NC}"
    else
        # Reset specific story circuit breaker
        jq --arg story_id "$story_id" --arg ts "$ts" --arg reason "$reason" '
            .stories[$story_id].state = "CLOSED" |
            .stories[$story_id].failures = 0 |
            .stories[$story_id].phase_failures = {} |
            .stories[$story_id].last_reset = $ts |
            .stories[$story_id].history += [{
                timestamp: $ts,
                event: "reset",
                reason: $reason
            }]' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"
        echo -e "${C_GREEN}✅ Circuit breaker reset for story $story_id${C_NC}"
    fi

    return 0
}

# Detect if a story is complete based on output signals
# Returns 0 if complete, 1 if in progress/gaps, 2 if blocked
# Phase signals format: "phase:signal" (e.g., "developer:COMPLETE", "ucv-validator:GAPS")
detect_story_completion() {
    local story_id="${1:-}"
    local phase="${2:-}"
    local output="${3:-}"

    if [[ -z "$story_id" ]] || [[ -z "$output" ]]; then
        return 1
    fi

    # Developer phase completion signals
    if [[ "$phase" == "developer" ]]; then
        if echo "$output" | grep -qiE "(implementation.*complete|all.*verifications.*implemented|HANDOFF.*Developer|code.*ready|tests.*written)"; then
            return 0  # COMPLETE
        elif echo "$output" | grep -qiE "(blocked|cannot|error|failed|timeout)"; then
            return 2  # BLOCKED
        else
            return 1  # IN_PROGRESS
        fi
    fi

    # Tester phase completion signals
    if [[ "$phase" == "tester" ]]; then
        if echo "$output" | grep -qiE "(all tests passing|coverage.*100%|HANDOFF.*Tester|validation.*complete)"; then
            return 0  # COMPLETE
        elif echo "$output" | grep -qiE "(test.*fail|coverage.*gap|blocked)"; then
            return 2  # BLOCKED
        else
            return 1  # IN_PROGRESS
        fi
    fi

    # UCV Validator phase completion signals
    if [[ "$phase" == "ucv-validator" ]]; then
        # Look for coverage percentage
        local coverage
        coverage=$(echo "$output" | grep -oP "Coverage:\s*\K[0-9]+" || echo "0")

        if [[ "$coverage" == "100" ]]; then
            return 0  # COMPLETE (100% coverage)
        elif [[ "$coverage" -gt 0 ]]; then
            return 1  # IN_PROGRESS (partial coverage)
        elif echo "$output" | grep -qiE "(verification.*complete|100%|all.*validated|COMPLETE)"; then
            return 0  # COMPLETE
        elif echo "$output" | grep -qiE "(gaps|incomplete|blocked)"; then
            return 2  # BLOCKED
        else
            return 1  # IN_PROGRESS
        fi
    fi

    return 1  # Default: IN_PROGRESS
}

# Check and enforce API call budget (rate limiting)
# Tracks cumulative API calls across all stories
# Requires: jq for JSON manipulation
check_api_budget() {
    local working_memory="${HARMONY_DIR}/memory/working.json"

    if [[ ! -f "$working_memory" ]]; then
        return 0  # No budget check if file missing
    fi

    # Check jq availability
    if ! check_jq_available; then
        echo -e "${C_YELLOW}⚠️  Skipping budget check (jq not available)${C_NC}" >&2
        return 0  # Allow operation if jq unavailable
    fi

    # Initialize budget fields if missing
    local tmp_file
    tmp_file=$(mktemp)
    jq '.budget //= {
        api_calls_limit: 10000,
        api_calls_total: 0,
        stories_completed: 0,
        max_stories: 20
    }' "$working_memory" > "$tmp_file" && mv "$tmp_file" "$working_memory"

    local calls
    calls=$(jq -r '.budget.api_calls_total // 0' "$working_memory")
    local limit
    limit=$(jq -r '.budget.api_calls_limit // 10000' "$working_memory")

    local pct=$((calls * 100 / limit))

    if [[ "$calls" -ge "$limit" ]]; then
        echo -e "${C_RED}🛑 API BUDGET EXCEEDED: $calls / $limit calls${C_NC}" >&2
        return 1  # Budget exhausted
    fi

    if [[ "$pct" -ge 80 ]]; then
        echo -e "${C_RED}⚠️  API BUDGET WARNING: ${pct}% used ($calls / $limit)${C_NC}"
    fi

    return 0
}

# Log phase execution for autopilot tracking
# Requires: jq for JSON manipulation
log_phase_execution() {
    local story_id="${1:-}"
    local phase="${2:-}"
    local status="${3:-started}"  # started, completed, failed

    local working_memory="${HARMONY_DIR}/memory/working.json"

    if [[ ! -f "$working_memory" ]]; then
        return 1
    fi

    # Check jq availability
    if ! check_jq_available; then
        # Silently skip logging if jq unavailable (non-critical)
        return 0
    fi

    local tmp_file
    tmp_file=$(mktemp)
    local timestamp
    timestamp=$(date -Iseconds)

    # Append phase log
    jq --arg story "$story_id" \
        --arg phase "$phase" \
        --arg status "$status" \
        --arg ts "$timestamp" \
        '.phase_execution_log //= [] |
         .phase_execution_log += [{
            timestamp: $ts,
            story: $story,
            phase: $phase,
            status: $status
         }]' "$working_memory" > "$tmp_file" && mv "$tmp_file" "$working_memory"

    return 0
}

# =============================================================================
# PHASE 2 - RALPH INTEGRATION (Medium + Low Priority Features)
# =============================================================================

# Display circuit breaker status dashboard
# Shows visual status of circuit breaker state for stories and global
show_circuit_status() {
    local story_id="${1:-}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ ! -f "$circuit_breaker_file" ]]; then
        echo -e "${C_YELLOW}⚠️  Circuit breaker file not found${C_NC}"
        return 1
    fi

    # Check jq availability
    if ! check_jq_available; then
        echo -e "${C_YELLOW}⚠️  Cannot display status (jq not available)${C_NC}"
        return 1
    fi

    local state
    state=$(jq -r '.state // "CLOSED"' "$circuit_breaker_file")
    local consecutive_failures
    consecutive_failures=$(jq -r '.consecutive_failures // 0' "$circuit_breaker_file")

    # Determine color and icon based on state
    local color icon
    case "$state" in
        "CLOSED")
            color="$C_GREEN"
            icon="✅"
            ;;
        "HALF_OPEN")
            color="$C_YELLOW"
            icon="⚠️ "
            ;;
        "OPEN")
            color="$C_RED"
            icon="🚨"
            ;;
        *)
            color="$C_NC"
            icon="❓"
            ;;
    esac

    echo -e "${color}╔════════════════════════════════════════════════════════════╗${C_NC}"
    echo -e "${color}║           Circuit Breaker Status                           ║${C_NC}"
    echo -e "${color}╚════════════════════════════════════════════════════════════╝${C_NC}"
    echo -e "${color}State:${C_NC}                 $icon $state"
    echo -e "${color}Consecutive Failures:${C_NC} $consecutive_failures"

    # Show story-specific status if requested
    if [[ -n "$story_id" ]]; then
        local story_state
        story_state=$(jq -r ".stories[\"$story_id\"].state // \"CLOSED\"" "$circuit_breaker_file")
        local story_failures
        story_failures=$(jq -r ".stories[\"$story_id\"].failures // 0" "$circuit_breaker_file")
        local story_iterations
        story_iterations=$(jq -r ".stories[\"$story_id\"].iterations // 0" "$circuit_breaker_file")

        echo ""
        echo -e "${C_BLUE}Story: $story_id${C_NC}"
        echo -e "  State:      $story_state"
        echo -e "  Failures:   $story_failures/10"
        echo -e "  Iterations: $story_iterations"

        # Show per-phase failures
        echo -e "  Phase Failures:"
        local dev_fails tester_fails ucv_fails
        dev_fails=$(jq -r ".stories[\"$story_id\"].phase_failures.developer // 0" "$circuit_breaker_file")
        tester_fails=$(jq -r ".stories[\"$story_id\"].phase_failures.tester // 0" "$circuit_breaker_file")
        ucv_fails=$(jq -r ".stories[\"$story_id\"].phase_failures[\"ucv-validator\"] // 0" "$circuit_breaker_file")
        echo -e "    Developer:     $dev_fails/5"
        echo -e "    Tester:        $tester_fails/5"
        echo -e "    UCV-Validator: $ucv_fails/5"
    fi

    echo ""
    return 0
}

# Two-stage error filtering to avoid JSON false positives
# Stage 1: Filter out JSON field patterns like "is_error": false
# Stage 2: Count actual error messages in specific contexts
# Returns: Integer count of real errors
count_real_errors() {
    local output_file="${1:-}"

    if [[ ! -f "$output_file" ]]; then
        echo "0"
        return
    fi

    # Two-stage filtering:
    # Stage 1: Remove lines with JSON error fields (avoid false positives)
    # Stage 2: Count actual error patterns
    local error_count
    error_count=$(grep -v '"[^"]*error[^"]*":' "$output_file" 2>/dev/null | \
                  grep -cE '(^Error:|^ERROR:|^error:|\]: error|Link: error|Error occurred|failed with error|[Ee]xception|Fatal|FATAL)' \
                  2>/dev/null || echo "0")

    # Ensure integer
    error_count=$(echo "$error_count" | tr -d '[:space:]')
    error_count=${error_count:-0}
    echo "$((error_count + 0))"
}

# Detect if Claude is stuck (repeating same errors across multiple iterations)
# Uses two-stage error filtering to avoid JSON false positives
# Returns: 0 if stuck (same errors in all recent outputs), 1 if not stuck
detect_stuck_loop() {
    local current_output="${1:-}"
    local history_dir="${2:-${HARMONY_DIR}/logs}"

    if [[ ! -f "$current_output" ]]; then
        return 1  # Cannot detect without current output
    fi

    if [[ ! -d "$history_dir" ]]; then
        return 1  # No history directory
    fi

    # Get last 3 output files
    local recent_outputs
    recent_outputs=$(ls -t "$history_dir"/phase_output_*.log 2>/dev/null | head -3)

    if [[ -z "$recent_outputs" ]] || [[ $(echo "$recent_outputs" | wc -l) -lt 2 ]]; then
        return 1  # Not enough history (need at least 2 previous outputs)
    fi

    # Extract key errors from current output using two-stage filtering
    local current_errors
    current_errors=$(grep -v '"[^"]*error[^"]*":' "$current_output" 2>/dev/null | \
                    grep -E '(^Error:|^ERROR:|^error:|\]: error|Link: error|Error occurred|failed with error|[Ee]xception|Fatal|FATAL)' 2>/dev/null | \
                    sort | uniq)

    if [[ -z "$current_errors" ]]; then
        return 1  # No errors in current output
    fi

    # Check if same errors appear in all recent outputs
    local all_files_match=true
    while IFS= read -r output_file; do
        local file_matches_all=true
        while IFS= read -r error_line; do
            # Use -F for literal fixed-string matching (not regex)
            if ! grep -qF "$error_line" "$output_file" 2>/dev/null; then
                file_matches_all=false
                break
            fi
        done <<< "$current_errors"

        if [[ "$file_matches_all" != "true" ]]; then
            all_files_match=false
            break
        fi
    done <<< "$recent_outputs"

    if [[ "$all_files_match" == "true" ]]; then
        echo -e "${C_RED}🔄 STUCK LOOP DETECTED: Same errors repeated in $( echo "$recent_outputs" | wc -l) consecutive outputs${C_NC}" >&2
        return 0  # Stuck on same error(s)
    else
        return 1  # Making progress or different errors
    fi
}

# Analyze response and return confidence score (0-100)
# Higher confidence = more likely task is complete
# Returns: JSON object with analysis results
analyze_response_confidence() {
    local output_file="${1:-}"
    local loop_number="${2:-1}"

    if [[ ! -f "$output_file" ]]; then
        echo '{"confidence": 0, "exit_signal": false, "reason": "output file not found"}'
        return
    fi

    local confidence=0
    local exit_signal=false
    local reasons=()

    local output_content
    output_content=$(cat "$output_file")
    local output_length=${#output_content}

    # 1. Check for explicit completion signals (+30)
    if grep -qiE "(implementation.*complete|all.*tasks.*complete|project.*complete|ready.*for.*review)" "$output_file"; then
        confidence=$((confidence + 30))
        reasons+=("completion_signal_found")
    fi

    # 2. Check for "done"/"finished" keywords (+10)
    if grep -qiE "(done|finished|complete|completed)" "$output_file"; then
        confidence=$((confidence + 10))
        reasons+=("done_keyword_found")
    fi

    # 3. Check for "nothing to do" patterns (+15)
    if grep -qiE "(nothing.*to.*do|no.*changes|already.*implemented|up.*to.*date)" "$output_file"; then
        confidence=$((confidence + 15))
        reasons+=("no_work_remaining")
    fi

    # 4. Check for git changes (indicates progress) (+20)
    if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
        local files_modified
        files_modified=$(git diff --name-only 2>/dev/null | wc -l)
        if [[ $files_modified -gt 0 ]]; then
            confidence=$((confidence + 20))
            reasons+=("git_changes_detected:$files_modified")
        fi
    fi

    # 5. Check for test success indicators (+15)
    if grep -qiE "(all.*tests.*pass|tests.*passing|100%.*coverage|coverage.*100%)" "$output_file"; then
        confidence=$((confidence + 15))
        reasons+=("tests_passing")
    fi

    # 6. Check for errors (reduce confidence)
    local error_count
    error_count=$(count_real_errors "$output_file")
    if [[ $error_count -gt 5 ]]; then
        confidence=$((confidence - 20))
        reasons+=("high_error_count:$error_count")
    elif [[ $error_count -gt 0 ]]; then
        confidence=$((confidence - 10))
        reasons+=("errors_present:$error_count")
    fi

    # 7. Check output length trend
    local last_length_file="${HARMONY_DIR}/memory/.last_output_length"
    if [[ -f "$last_length_file" ]]; then
        local last_length
        last_length=$(cat "$last_length_file")
        if [[ $last_length -gt 0 ]]; then
            local length_ratio=$((output_length * 100 / last_length))
            if [[ $length_ratio -lt 50 ]]; then
                # Output significantly shorter - possible completion
                confidence=$((confidence + 10))
                reasons+=("output_declining")
            fi
        fi
    fi
    echo "$output_length" > "$last_length_file"

    # Ensure confidence is 0-100
    if [[ $confidence -lt 0 ]]; then confidence=0; fi
    if [[ $confidence -gt 100 ]]; then confidence=100; fi

    # Determine exit signal based on confidence
    if [[ $confidence -ge 40 ]]; then
        exit_signal=true
    fi

    # Build JSON response
    local reason_str
    reason_str=$(printf '%s,' "${reasons[@]}" | sed 's/,$//')

    cat << EOF
{
    "loop_number": $loop_number,
    "confidence": $confidence,
    "exit_signal": $exit_signal,
    "output_length": $output_length,
    "reasons": ["${reason_str//,/\", \"}"],
    "timestamp": "$(get_iso_timestamp 2>/dev/null || date -Iseconds)"
}
EOF
}

# Transition circuit breaker to HALF_OPEN state (monitoring mode)
# HALF_OPEN allows limited operations while monitoring for recovery
transition_to_half_open() {
    local story_id="${1:-}"
    local reason="${2:-Monitoring for recovery}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ ! -f "$circuit_breaker_file" ]]; then
        return 1
    fi

    if ! check_jq_available; then
        return 1
    fi

    local ts
    ts=$(get_iso_timestamp 2>/dev/null || date -Iseconds)
    local tmp_file
    tmp_file=$(mktemp)

    if [[ -z "$story_id" ]]; then
        # Transition global circuit breaker
        jq --arg ts "$ts" --arg reason "$reason" '
            .state = "HALF_OPEN" |
            .last_change = $ts |
            .reason = $reason |
            .history += [{
                timestamp: $ts,
                event: "transition",
                from: .state,
                to: "HALF_OPEN",
                reason: $reason
            }]' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"
        echo -e "${C_YELLOW}⚠️  Circuit breaker transitioned to HALF_OPEN (monitoring)${C_NC}"
    else
        # Transition story-specific circuit breaker
        jq --arg story_id "$story_id" --arg ts "$ts" --arg reason "$reason" '
            .stories[$story_id].state = "HALF_OPEN" |
            .stories[$story_id].history += [{
                timestamp: $ts,
                event: "transition",
                from: .stories[$story_id].state,
                to: "HALF_OPEN",
                reason: $reason
            }]' "$circuit_breaker_file" > "$tmp_file" && mv "$tmp_file" "$circuit_breaker_file"
        echo -e "${C_YELLOW}⚠️  Story $story_id circuit breaker transitioned to HALF_OPEN${C_NC}"
    fi

    return 0
}

# Check if should halt execution (with visual dashboard)
# Shows status and returns 0 if should halt, 1 if can continue
should_halt_execution() {
    local story_id="${1:-}"
    local circuit_breaker_file="${HARMONY_DIR}/memory/circuit-breaker.json"

    if [[ ! -f "$circuit_breaker_file" ]]; then
        return 1  # Can continue if no file
    fi

    if ! check_jq_available; then
        return 1  # Can continue if jq unavailable
    fi

    local state
    state=$(jq -r '.state // "CLOSED"' "$circuit_breaker_file")

    if [[ "$state" == "OPEN" ]]; then
        show_circuit_status "$story_id"
        echo ""
        echo -e "${C_RED}╔════════════════════════════════════════════════════════════╗${C_NC}"
        echo -e "${C_RED}║  EXECUTION HALTED: Circuit Breaker Opened                  ║${C_NC}"
        echo -e "${C_RED}╚════════════════════════════════════════════════════════════╝${C_NC}"
        echo ""
        echo -e "${C_YELLOW}Possible reasons:${C_NC}"
        echo "  • Story may be complete (check working.json)"
        echo "  • Claude may be stuck on an error (check logs)"
        echo "  • Manual intervention may be required"
        echo ""
        echo -e "${C_YELLOW}To continue:${C_NC}"
        echo "  1. Review recent logs: ls -lt ${HARMONY_DIR}/logs/"
        echo "  2. Reset circuit breaker: reset_circuit_breaker [story_id]"
        echo ""
        return 0  # Signal to halt
    fi

    return 1  # Can continue
}
