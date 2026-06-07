#!/usr/bin/env bash
# ============================================================================
# file-watcher.sh - File Change Detection for Harmony Framework
# ============================================================================
# Inspired by Aider's watch mode for automatic linting and context updates
# Provides file monitoring, change detection, and event hooks
#
# Usage: source file-watcher.sh
#
# Functions:
#   - watch_files            : Watch files for changes
#   - detect_changes         : Detect file changes since last check
#   - get_modified_files     : Get recently modified files
#   - register_hook          : Register callback for file changes
#   - on_file_change         : Trigger registered hooks
# ============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# ============================================================================
# CONFIGURATION
# ============================================================================
WATCH_INTERVAL="${WATCH_INTERVAL:-2}"  # seconds between checks
WATCH_STATE_FILE="${WATCH_STATE_FILE:-/tmp/harmony-watch-state}"
WATCH_LOG_FILE="${WATCH_LOG_FILE:-/tmp/harmony-watch.log}"
WATCH_MAX_EVENTS="${WATCH_MAX_EVENTS:-100}"

# File patterns to watch
declare -a WATCH_PATTERNS=(
    "*.ts" "*.tsx" "*.js" "*.jsx"
    "*.py"
    "*.sh" "*.bash"
    "*.go"
    "*.rs"
    "*.json" "*.yaml" "*.yml"
    "*.md"
)

# Patterns to ignore
declare -a WATCH_IGNORE=(
    "node_modules"
    ".git"
    "dist"
    "build"
    "coverage"
    "__pycache__"
    ".cache"
    "*.log"
    "*.tmp"
    "*.swp"
    "*~"
)

# Registered hooks (function names to call on changes)
declare -a CHANGE_HOOKS=()

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

# Initialize watch state file
init_watch_state() {
    local dir="${1:-.}"

    mkdir -p "$(dirname "$WATCH_STATE_FILE")"

    # Store file mtimes
    find "$dir" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.sh" -o -name "*.go" \) 2>/dev/null | while read -r file; do
        if ! should_ignore_watch "$file"; then
            local mtime
            mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "0")
            echo "$file:$mtime"
        fi
    done > "$WATCH_STATE_FILE"

    echo "Watch state initialized for $dir"
}

# Save current file states
save_watch_state() {
    local dir="${1:-.}"
    local temp_file
    temp_file=$(mktemp)

    find "$dir" -type f 2>/dev/null | while read -r file; do
        if ! should_ignore_watch "$file" && is_watchable "$file"; then
            local mtime
            mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "0")
            echo "$file:$mtime"
        fi
    done > "$temp_file"

    mv "$temp_file" "$WATCH_STATE_FILE"
}

# Check if file should be ignored
should_ignore_watch() {
    local file="$1"
    for pattern in "${WATCH_IGNORE[@]}"; do
        case "$file" in
            *$pattern*) return 0 ;;
        esac
    done
    return 1
}

# Check if file matches watch patterns
is_watchable() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        ts|tsx|js|jsx|py|sh|bash|go|rs|json|yaml|yml|md|c|cpp|h|hpp|java|rb|php)
            return 0
            ;;
    esac
    return 1
}

# ============================================================================
# CHANGE DETECTION
# ============================================================================

# Detect files changed since last state save
# Usage: detect_changes [directory] -> outputs changed files
detect_changes() {
    local dir="${1:-.}"
    local changes=()

    if [[ ! -f "$WATCH_STATE_FILE" ]]; then
        init_watch_state "$dir"
        return 0
    fi

    # Load previous state
    declare -A prev_state
    while IFS=: read -r file mtime; do
        prev_state["$file"]="$mtime"
    done < "$WATCH_STATE_FILE"

    # Check current files
    while IFS= read -r file; do
        if should_ignore_watch "$file" || ! is_watchable "$file"; then
            continue
        fi

        local current_mtime
        current_mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "0")

        local prev_mtime="${prev_state[$file]:-0}"

        if [[ "$current_mtime" != "$prev_mtime" ]]; then
            if [[ "$prev_mtime" == "0" ]]; then
                echo "added:$file"
            else
                echo "modified:$file"
            fi
            changes+=("$file")
        fi

        # Mark as seen
        unset "prev_state[$file]"
    done < <(find "$dir" -type f 2>/dev/null)

    # Check for deleted files
    for file in "${!prev_state[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "deleted:$file"
        fi
    done
}

# Get recently modified files (within N seconds)
# Usage: get_modified_files [directory] [seconds]
get_modified_files() {
    local dir="${1:-.}"
    local seconds="${2:-60}"

    find "$dir" -type f -mmin "-$(( seconds / 60 + 1 ))" 2>/dev/null | while read -r file; do
        if ! should_ignore_watch "$file" && is_watchable "$file"; then
            echo "$file"
        fi
    done
}

# Get files modified since a timestamp
# Usage: get_files_since [directory] [timestamp]
get_files_since() {
    local dir="${1:-.}"
    local since="${2:-$(date +%s)}"

    find "$dir" -type f 2>/dev/null | while read -r file; do
        if should_ignore_watch "$file" || ! is_watchable "$file"; then
            continue
        fi

        local mtime
        mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "0")

        if [[ "$mtime" -gt "$since" ]]; then
            echo "$file"
        fi
    done
}

# ============================================================================
# HOOK SYSTEM
# ============================================================================

# Register a hook function to be called on file changes
# Usage: register_hook "function_name"
register_hook() {
    local func="$1"

    if declare -f "$func" &>/dev/null; then
        CHANGE_HOOKS+=("$func")
        echo "Registered hook: $func"
    else
        echo "Warning: Function $func not found" >&2
        return 1
    fi
}

# Trigger all registered hooks
# Usage: trigger_hooks "event_type" "file_path"
trigger_hooks() {
    local event="$1"
    local file="$2"

    for hook in "${CHANGE_HOOKS[@]}"; do
        if declare -f "$hook" &>/dev/null; then
            "$hook" "$event" "$file" || true
        fi
    done
}

# Default file change handler
on_file_change() {
    local event="$1"
    local file="$2"

    log_watch_event "$event" "$file"

    # Auto-lint if available
    if declare -f run_lint_check &>/dev/null && [[ "$event" != "deleted" ]]; then
        run_lint_check "$file" --fix 2>/dev/null || true
    fi
}

# Log watch event
log_watch_event() {
    local event="$1"
    local file="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] $event: $file" >> "$WATCH_LOG_FILE"

    # Rotate log if too large
    if [[ -f "$WATCH_LOG_FILE" ]]; then
        local lines
        lines=$(wc -l < "$WATCH_LOG_FILE")
        if [[ "$lines" -gt "$WATCH_MAX_EVENTS" ]]; then
            tail -n "$((WATCH_MAX_EVENTS / 2))" "$WATCH_LOG_FILE" > "$WATCH_LOG_FILE.tmp"
            mv "$WATCH_LOG_FILE.tmp" "$WATCH_LOG_FILE"
        fi
    fi
}

# ============================================================================
# WATCH LOOP
# ============================================================================

# Start watching files for changes
# Usage: watch_files [directory] [--daemon]
watch_files() {
    local dir="${1:-.}"
    local daemon=false

    if [[ "${2:-}" == "--daemon" ]]; then
        daemon=true
    fi

    echo "Starting file watcher for: $dir"
    echo "Interval: ${WATCH_INTERVAL}s"
    echo "Press Ctrl+C to stop"
    echo ""

    # Initialize state
    init_watch_state "$dir"

    # Register default hook
    register_hook "on_file_change"

    # Watch loop
    while true; do
        local changes
        changes=$(detect_changes "$dir")

        if [[ -n "$changes" ]]; then
            echo "=== Changes detected ==="
            while IFS=: read -r event file; do
                echo "  $event: $file"
                trigger_hooks "$event" "$file"
            done <<< "$changes"
            echo ""

            # Update state after processing
            save_watch_state "$dir"
        fi

        sleep "$WATCH_INTERVAL"
    done
}

# Start watcher in background
# Usage: start_watch_daemon [directory]
start_watch_daemon() {
    local dir="${1:-.}"
    local pid_file="/tmp/harmony-watch.pid"

    if [[ -f "$pid_file" ]]; then
        local old_pid
        old_pid=$(cat "$pid_file")
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "Watcher already running (PID: $old_pid)"
            return 1
        fi
    fi

    # Start in background
    watch_files "$dir" --daemon &>/dev/null &
    echo $! > "$pid_file"
    echo "Watcher started (PID: $!)"
}

# Stop background watcher
# Usage: stop_watch_daemon
stop_watch_daemon() {
    local pid_file="/tmp/harmony-watch.pid"

    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$pid_file"
            echo "Watcher stopped (PID: $pid)"
        else
            rm -f "$pid_file"
            echo "Watcher was not running"
        fi
    else
        echo "No watcher PID file found"
    fi
}

# Check watcher status
# Usage: watch_status
watch_status() {
    local pid_file="/tmp/harmony-watch.pid"

    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Watcher running (PID: $pid)"

            # Show recent events
            if [[ -f "$WATCH_LOG_FILE" ]]; then
                echo ""
                echo "Recent events:"
                tail -n 10 "$WATCH_LOG_FILE" | sed 's/^/  /'
            fi
            return 0
        fi
    fi

    echo "Watcher not running"
    return 1
}

# ============================================================================
# GIT INTEGRATION
# ============================================================================

# Get files changed in git (staged + unstaged)
# Usage: get_git_changes
get_git_changes() {
    if ! command -v git &>/dev/null; then
        return 1
    fi

    {
        git diff --name-only 2>/dev/null
        git diff --cached --name-only 2>/dev/null
    } | sort -u
}

# Watch only git-tracked files
# Usage: watch_git_files [--staged-only]
watch_git_files() {
    local staged_only="${1:-}"

    if ! command -v git &>/dev/null; then
        echo "Git not available" >&2
        return 1
    fi

    echo "Watching git changes..."

    local prev_changes=""

    while true; do
        local current_changes
        if [[ "$staged_only" == "--staged-only" ]]; then
            current_changes=$(git diff --cached --name-only 2>/dev/null | sort)
        else
            current_changes=$(get_git_changes | sort)
        fi

        if [[ "$current_changes" != "$prev_changes" ]]; then
            if [[ -n "$current_changes" ]]; then
                echo "=== Git changes ==="
                while IFS= read -r file; do
                    if [[ -f "$file" ]]; then
                        echo "  modified: $file"
                        trigger_hooks "modified" "$file"
                    fi
                done <<< "$current_changes"
            fi
            prev_changes="$current_changes"
        fi

        sleep "$WATCH_INTERVAL"
    done
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Get watch statistics
get_watch_stats() {
    echo "=== Watch Statistics ==="

    if [[ -f "$WATCH_STATE_FILE" ]]; then
        local file_count
        file_count=$(wc -l < "$WATCH_STATE_FILE")
        echo "Files tracked: $file_count"
    fi

    if [[ -f "$WATCH_LOG_FILE" ]]; then
        local event_count
        event_count=$(wc -l < "$WATCH_LOG_FILE")
        echo "Events logged: $event_count"

        echo ""
        echo "Event breakdown:"
        grep -oE "^\[[^]]+\] [a-z]+" "$WATCH_LOG_FILE" 2>/dev/null | awk '{print $2}' | sort | uniq -c | sed 's/^/  /'
    fi

    echo ""
    echo "Registered hooks: ${#CHANGE_HOOKS[@]}"
    for hook in "${CHANGE_HOOKS[@]}"; do
        echo "  - $hook"
    done
}

# Clear watch state and logs
clear_watch_state() {
    rm -f "$WATCH_STATE_FILE" "$WATCH_LOG_FILE"
    echo "Watch state cleared"
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f watch_files detect_changes get_modified_files get_files_since
export -f register_hook trigger_hooks on_file_change log_watch_event
export -f start_watch_daemon stop_watch_daemon watch_status
export -f get_git_changes watch_git_files get_watch_stats
export -f init_watch_state save_watch_state clear_watch_state
export -f should_ignore_watch is_watchable

# ============================================================================
# CLI MODE - Run directly for testing
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        watch)
            watch_files "${2:-.}"
            ;;
        changes)
            detect_changes "${2:-.}"
            ;;
        modified)
            get_modified_files "${2:-.}" "${3:-60}"
            ;;
        start)
            start_watch_daemon "${2:-.}"
            ;;
        stop)
            stop_watch_daemon
            ;;
        status)
            watch_status
            ;;
        git)
            watch_git_files "${2:-}"
            ;;
        stats)
            get_watch_stats
            ;;
        clear)
            clear_watch_state
            ;;
        init)
            init_watch_state "${2:-.}"
            ;;
        *)
            echo "Usage: file-watcher.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  watch [dir]        - Start watching directory"
            echo "  changes [dir]      - Show changed files since last check"
            echo "  modified [dir] [s] - Show files modified in last N seconds"
            echo "  start [dir]        - Start watcher daemon"
            echo "  stop               - Stop watcher daemon"
            echo "  status             - Show watcher status"
            echo "  git [--staged-only] - Watch git changes"
            echo "  stats              - Show watch statistics"
            echo "  clear              - Clear watch state"
            echo "  init [dir]         - Initialize watch state"
            ;;
    esac
fi
