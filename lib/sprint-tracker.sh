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

    # Clear current story
    local tmp_file
    tmp_file=$(mktemp)
    jq '.current_story = {
            id: null,
            title: null,
            status: "TODO",
            points: 0,
            started: null,
            epic: null,
            assigned: null,
            ucv_status: "PENDING",
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
