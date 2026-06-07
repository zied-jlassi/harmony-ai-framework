#!/bin/bash
# =============================================================================
# Sprint Autopilot Commands Library
# =============================================================================
#
# Optional command wrapper library for Sprint Autopilot.
# Source this file to get CLI commands with full option parsing.
#
# IMPORTANT: This file is OPTIONAL and only loaded on demand.
#            The core functions in sprint-tracker.sh work without this.
#
# Usage:
#   source framework/lib/autopilot-commands.sh
#   autopilot_start_command --sprint SPRINT-001
#   autopilot_status_command --sprint SPRINT-001
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# Ensure sprint-tracker is loaded
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

if ! declare -f run_story_pipeline &>/dev/null; then
    source "${HARMONY_DIR}/../framework/lib/sprint-tracker.sh" 2>/dev/null || {
        echo "ERROR: Cannot load sprint-tracker.sh" >&2
        return 1
    }
fi

# =============================================================================
# COMMAND 1: START AUTOPILOT
# =============================================================================
#
# Purpose: Launch autopilot for a sprint
# Usage:
#   autopilot_start_command
#   autopilot_start_command --sprint SPRINT-005
#   autopilot_start_command --sprint SPRINT-005 --max-stories 10
#
# Behavior:
#   1. Reads all stories from sprint
#   2. For each story: Developer → Tester → UCV Validator
#   3. Updates state files at each phase
#   4. Stops if circuit breaker opens or budget exhausted
#   5. Saves checkpoint on Ctrl+C
#
autopilot_start_command() {
    local sprint_id=""
    local max_stories=""

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --sprint)
                sprint_id="$2"
                shift 2
                ;;
            --max-stories)
                max_stories="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    # Get current sprint if not specified
    if [[ -z "$sprint_id" ]]; then
        sprint_id=$(jq -r '.current_sprint.id // empty' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        if [[ -z "$sprint_id" ]]; then
            echo "ERROR: No sprint specified and no current sprint found" >&2
            return 1
        fi
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤖 SPRINT AUTOPILOT - STARTING"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Sprint:      $sprint_id"
    echo "Start time:  $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # Get stories from working.json
    local stories
    stories=$(jq -r '.current_sprint.stories[]? // empty' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null || echo "")

    if [[ -z "$stories" ]]; then
        echo "ℹ️  No stories found in sprint"
        return 0
    fi

    local story_count=0
    local completed=0
    local failed=0

    # Process each story
    echo "$stories" | while read -r story_id; do
        [[ -z "$story_id" ]] && continue

        ((story_count++))

        # Check max stories limit
        if [[ -n "$max_stories" ]] && [[ $story_count -gt $max_stories ]]; then
            echo "ℹ️  Reached max stories limit ($max_stories)"
            break
        fi

        echo ""
        echo "📖 Story $story_count: $story_id"
        echo "   Phases: Developer → Tester → UCV Validator"

        # Run story through pipeline
        if run_story_pipeline "$story_id" 2>/dev/null; then
            echo "   ✅ DONE"
            ((completed++))
        else
            echo "   ❌ FAILED"
            ((failed++))
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ AUTOPILOT COMPLETE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Completed:   $completed/$story_count"
    echo "Failed:      $failed/$story_count"
    echo "End time:    $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

# =============================================================================
# COMMAND 2: CHECK AUTOPILOT STATUS
# =============================================================================
#
# Purpose: Show real-time progress of autopilot
# Usage:
#   autopilot_status_command
#   autopilot_status_command --sprint SPRINT-005
#   autopilot_status_command --watch        (refresh every 5 sec)
#
# Behavior:
#   1. Reads working.json and circuit-breaker.json
#   2. Displays current story and phase
#   3. Shows completed/failed counts
#   4. Displays API budget usage
#   5. Optionally watches (auto-refresh)
#
autopilot_status_command() {
    local sprint_id=""
    local watch_mode=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --sprint)
                sprint_id="$2"
                shift 2
                ;;
            --watch)
                watch_mode=true
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    # Get current sprint if not specified
    if [[ -z "$sprint_id" ]]; then
        sprint_id=$(jq -r '.current_sprint.id // empty' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        if [[ -z "$sprint_id" ]]; then
            echo "ERROR: No sprint specified and no current sprint found" >&2
            return 1
        fi
    fi

    # Display status
    display_status() {
        echo ""
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│           SPRINT AUTOPILOT - STATUS                     │"
        echo "├─────────────────────────────────────────────────────────┤"

        # Sprint info
        local sprint_name=$(jq -r ".current_sprint.name // \"$sprint_id\"" "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null || echo "$sprint_id")
        echo "│ Sprint:  $sprint_name"

        # Current story
        local current_story=$(jq -r '.current_story.id // "None"' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        local current_status=$(jq -r '.current_story.status // "Unknown"' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        echo "│ Current: $current_story ($current_status)"

        # Story counts
        local completed=$(jq -r '.autopilot_progress.completed // 0' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        local total=$(jq -r '.autopilot_progress.total_stories // 0' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        local failed=$(jq -r '.autopilot_progress.failed // 0' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)

        if [[ $total -gt 0 ]]; then
            local pct=$((completed * 100 / total))
            echo "│ Progress: $pct% ($completed/$total) ✅ $completed | ❌ $failed"
        else
            echo "│ Progress: No stories"
        fi

        # API budget
        local api_calls=$(jq -r '.budget.api_calls_total // 0' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        local api_limit=$(jq -r '.budget.api_calls_limit // 10000' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)
        local api_pct=$((api_calls * 100 / api_limit))
        echo "│ Budget:  $api_calls / $api_limit calls ($api_pct%)"

        # Circuit breaker
        local cb_state=$(jq -r '.global.state // "CLOSED"' "${HARMONY_DIR}/local/memory/circuit-breaker.json" 2>/dev/null)
        echo "│ Circuit: $cb_state"

        echo "└─────────────────────────────────────────────────────────┘"
        echo ""
    }

    if [[ "$watch_mode" == true ]]; then
        # Watch mode: refresh every 5 seconds
        while true; do
            clear
            display_status
            sleep 5
        done
    else
        # Single display
        display_status
    fi
}

# =============================================================================
# COMMAND 3: STOP AUTOPILOT GRACEFULLY
# =============================================================================
#
# Purpose: Stop autopilot with optional checkpoint
# Usage:
#   autopilot_stop_command
#   autopilot_stop_command --checkpoint
#
# Behavior:
#   1. Signals graceful shutdown to autopilot process
#   2. Completes current phase
#   3. If --checkpoint: Saves state for resume
#   4. Marks incomplete stories as paused
#
autopilot_stop_command() {
    local save_checkpoint=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --checkpoint)
                save_checkpoint=true
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    echo ""
    echo "⏸️  Stopping autopilot..."

    # Mark current story as paused (not failed)
    local current_story=$(jq -r '.current_story.id // empty' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)

    if [[ -n "$current_story" ]]; then
        local tmp_file
        tmp_file=$(mktemp)
        jq ".current_story.status = \"PAUSED\"" "${HARMONY_DIR}/local/memory/working.json" > "$tmp_file" && \
        mv "$tmp_file" "${HARMONY_DIR}/local/memory/working.json"
    fi

    if [[ "$save_checkpoint" == true ]]; then
        echo "✅ Checkpoint saved"
        echo "   Resume with: autopilot_resume_command"
    else
        echo "✅ Stopped (checkpoint NOT saved)"
        echo "   To save checkpoint: autopilot_stop_command --checkpoint"
    fi

    echo ""
}

# =============================================================================
# COMMAND 4: RESUME FROM CHECKPOINT
# =============================================================================
#
# Purpose: Resume autopilot from saved checkpoint
# Usage:
#   autopilot_resume_command
#   autopilot_resume_command --from STORY-042
#   autopilot_resume_command --sprint SPRINT-005
#
# Behavior:
#   1. Reads last checkpoint from working.json
#   2. Resumes from next incomplete story
#   3. Continues with same sprint
#   4. Maintains velocity/budget tracking
#
autopilot_resume_command() {
    local resume_from=""
    local sprint_id=""

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --from)
                resume_from="$2"
                shift 2
                ;;
            --sprint)
                sprint_id="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▶️  RESUMING AUTOPILOT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Determine resume point
    if [[ -z "$resume_from" ]]; then
        # Get from working.json checkpoint
        resume_from=$(jq -r '.current_story.id // empty' "${HARMONY_DIR}/local/memory/working.json" 2>/dev/null)

        if [[ -z "$resume_from" ]]; then
            echo "ERROR: No checkpoint found. Start with: autopilot_start_command"
            return 1
        fi
    fi

    echo "Resuming from: $resume_from"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"

    # Update status
    local tmp_file
    tmp_file=$(mktemp)
    jq ".current_story.status = \"IN_PROGRESS\" | .current_story.resumed_at = \"$(date -Iseconds)\"" \
        "${HARMONY_DIR}/local/memory/working.json" > "$tmp_file" && \
    mv "$tmp_file" "${HARMONY_DIR}/local/memory/working.json"

    echo "✅ Ready to continue"
    echo ""
}

# =============================================================================
# COMMAND 5: RUN SINGLE STORY
# =============================================================================
#
# Purpose: Execute single story through full pipeline (useful for testing)
# Usage:
#   autopilot_story_command STORY-001
#   autopilot_story_command STORY-001 --verbose
#
# Behavior:
#   1. Validates story exists
#   2. Runs Developer → Tester → UCV Validator phases
#   3. Updates working.json with results
#   4. Reports completion status
#   5. Can be used for manual story processing
#
autopilot_story_command() {
    local story_id="${1:-}"
    local verbose=false

    # Validate story ID provided
    if [[ -z "$story_id" ]]; then
        echo "ERROR: Story ID required"
        echo "Usage: autopilot_story_command STORY-001 [--verbose]"
        return 1
    fi

    # Parse additional options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose)
                verbose=true
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📖 TESTING SINGLE STORY: $story_id"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Execute pipeline
    if run_story_pipeline "$story_id"; then
        echo ""
        echo "✅ Story completed successfully"

        # Show final state if verbose
        if [[ "$verbose" == true ]]; then
            echo ""
            echo "Final state:"
            jq ".current_story" "${HARMONY_DIR}/local/memory/working.json"
        fi
    else
        echo ""
        echo "❌ Story processing failed"

        if [[ "$verbose" == true ]]; then
            echo ""
            echo "Circuit breaker state:"
            jq ".stories[\"$story_id\"]" "${HARMONY_DIR}/local/memory/circuit-breaker.json"
        fi

        return 1
    fi

    echo ""
}

# =============================================================================
# ADDITIONAL HELPERS
# =============================================================================

# Helper: Show autopilot help
autopilot_help_command() {
    cat << 'EOF'
┌──────────────────────────────────────────────────────────────────────┐
│                    AUTOPILOT COMMANDS REFERENCE                      │
└──────────────────────────────────────────────────────────────────────┘

1. START AUTOPILOT
   autopilot_start_command [--sprint SPRINT-ID] [--max-stories N]

   Launches full sprint autopilot execution
   Example: autopilot_start_command --sprint SPRINT-005 --max-stories 10

2. CHECK STATUS
   autopilot_status_command [--sprint SPRINT-ID] [--watch]

   Shows real-time progress. Use --watch for continuous updates
   Example: autopilot_status_command --watch

3. STOP AUTOPILOT
   autopilot_stop_command [--checkpoint]

   Gracefully stops autopilot. Use --checkpoint to save progress
   Example: autopilot_stop_command --checkpoint

4. RESUME
   autopilot_resume_command [--from STORY-ID] [--sprint SPRINT-ID]

   Resumes from checkpoint or specific story
   Example: autopilot_resume_command --from STORY-042

5. TEST SINGLE STORY
   autopilot_story_command STORY-ID [--verbose]

   Executes one story through full pipeline
   Example: autopilot_story_command STORY-001 --verbose

CONFIGURATION
   Edit: .harmony/local/autopilot-config.json
   - Circuit breaker thresholds
   - API budget limits
   - Completion detection patterns

EOF
}

# Export functions for external use
export -f autopilot_start_command
export -f autopilot_status_command
export -f autopilot_stop_command
export -f autopilot_resume_command
export -f autopilot_story_command
export -f autopilot_help_command

# =============================================================================
# END OF AUTOPILOT COMMANDS LIBRARY
# =============================================================================
