#!/usr/bin/env bash
# ============================================================================
# history-summarizer.sh - History and Context Summarization for Harmony Framework
# ============================================================================
# Inspired by Aider's chat history compression and context management
# Provides history tracking, summarization, and context compression
#
# Usage: source history-summarizer.sh
#
# Functions:
#   - add_history_entry      : Add entry to history
#   - summarize_history      : Generate summary of history
#   - compress_context       : Compress context for long sessions
#   - get_git_history        : Summarize git commit history
#   - get_session_summary    : Get current session summary
# ============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# ============================================================================
# CONFIGURATION
# ============================================================================
HISTORY_DIR="${HARMONY_DIR:-$HOME/.harmony}/history"
HISTORY_FILE="${HISTORY_FILE:-$HISTORY_DIR/session-history.jsonl}"
SUMMARY_FILE="${SUMMARY_FILE:-$HISTORY_DIR/summary.json}"
MAX_HISTORY_ENTRIES="${MAX_HISTORY_ENTRIES:-1000}"
COMPRESS_THRESHOLD="${COMPRESS_THRESHOLD:-500}"  # Entries before compression

# ============================================================================
# INITIALIZATION
# ============================================================================

# Initialize history directory and files
init_history() {
    mkdir -p "$HISTORY_DIR"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        touch "$HISTORY_FILE"
    fi

    if [[ ! -f "$SUMMARY_FILE" ]]; then
        cat > "$SUMMARY_FILE" <<'EOF'
{
  "session_id": "",
  "started_at": "",
  "entries_count": 0,
  "compressed_count": 0,
  "key_topics": [],
  "files_modified": [],
  "commands_used": [],
  "errors_encountered": []
}
EOF
    fi
}

# ============================================================================
# HISTORY MANAGEMENT
# ============================================================================

# Add entry to history
# Usage: add_history_entry "type" "content" ["metadata"]
add_history_entry() {
    local entry_type="$1"
    local content="$2"
    local metadata="${3:-"{}"}"

    init_history

    local timestamp
    timestamp=$(date -Iseconds)

    local session_id="${HARMONY_SESSION_ID:-$(date +%Y%m%d%H%M%S)}"

    # Create JSON entry (escape quotes in content)
    local escaped_content
    escaped_content=$(echo "$content" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')

    cat >> "$HISTORY_FILE" <<EOF
{"timestamp":"$timestamp","session_id":"$session_id","type":"$entry_type","content":"$escaped_content","metadata":$metadata}
EOF

    # Update entry count in summary
    if command -v jq &>/dev/null; then
        local current_count
        current_count=$(jq -r '.entries_count // 0' "$SUMMARY_FILE" 2>/dev/null || echo "0")
        jq --argjson count "$((current_count + 1))" '.entries_count = $count' "$SUMMARY_FILE" > "$SUMMARY_FILE.tmp" && mv "$SUMMARY_FILE.tmp" "$SUMMARY_FILE"
    fi

    # Check if compression needed
    local entry_count
    entry_count=$(wc -l < "$HISTORY_FILE" 2>/dev/null || echo "0")
    if [[ "$entry_count" -gt "$COMPRESS_THRESHOLD" ]]; then
        compress_history
    fi
}

# Get history entries
# Usage: get_history [count] [type_filter]
get_history() {
    local count="${1:-50}"
    local type_filter="${2:-}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo "[]"
        return
    fi

    if [[ -n "$type_filter" ]] && command -v jq &>/dev/null; then
        tail -n "$count" "$HISTORY_FILE" | jq -s --arg type "$type_filter" '[.[] | select(.type == $type)]'
    elif command -v jq &>/dev/null; then
        tail -n "$count" "$HISTORY_FILE" | jq -s '.'
    else
        tail -n "$count" "$HISTORY_FILE"
    fi
}

# Search history
# Usage: search_history "pattern" [type_filter]
search_history() {
    local pattern="$1"
    local type_filter="${2:-}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo "[]"
        return
    fi

    if command -v jq &>/dev/null; then
        local filter=".content | test(\"$pattern\"; \"i\")"
        if [[ -n "$type_filter" ]]; then
            filter="($filter) and (.type == \"$type_filter\")"
        fi
        cat "$HISTORY_FILE" | jq -s "[.[] | select($filter)]"
    else
        grep -i "$pattern" "$HISTORY_FILE"
    fi
}

# ============================================================================
# SUMMARIZATION
# ============================================================================

# Generate summary of history
# Usage: summarize_history [session_id]
summarize_history() {
    local session_id="${1:-}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo "No history to summarize"
        return
    fi

    init_history

    # Extract key information
    local total_entries
    total_entries=$(wc -l < "$HISTORY_FILE" 2>/dev/null || echo "0")

    if ! command -v jq &>/dev/null; then
        echo "=== History Summary (jq not available) ==="
        echo "Total entries: $total_entries"
        echo ""
        echo "Entry types:"
        awk -F'"type":"' '{print $2}' "$HISTORY_FILE" | awk -F'"' '{print $1}' | sort | uniq -c
        return
    fi

    # Get entry type distribution
    local type_dist
    type_dist=$(cat "$HISTORY_FILE" | jq -s 'group_by(.type) | map({type: .[0].type, count: length}) | sort_by(-.count)')

    # Get unique files modified
    local files_modified
    files_modified=$(cat "$HISTORY_FILE" | jq -s '[.[] | select(.type == "file_edit" or .type == "file_create") | .metadata.file // .content] | unique | .[:20]')

    # Get commands used
    local commands_used
    commands_used=$(cat "$HISTORY_FILE" | jq -s '[.[] | select(.type == "command") | .content] | unique | .[:20]')

    # Get error count
    local error_count
    error_count=$(cat "$HISTORY_FILE" | jq -s '[.[] | select(.type == "error")] | length')

    # Get time range
    local first_entry last_entry
    first_entry=$(head -1 "$HISTORY_FILE" | jq -r '.timestamp // "unknown"' 2>/dev/null || echo "unknown")
    last_entry=$(tail -1 "$HISTORY_FILE" | jq -r '.timestamp // "unknown"' 2>/dev/null || echo "unknown")

    # Build summary JSON
    cat <<EOF
{
  "total_entries": $total_entries,
  "time_range": {
    "start": "$first_entry",
    "end": "$last_entry"
  },
  "entry_types": $type_dist,
  "files_modified": $files_modified,
  "commands_used": $commands_used,
  "error_count": $error_count
}
EOF
}

# Generate human-readable summary
# Usage: get_session_summary
get_session_summary() {
    local summary
    summary=$(summarize_history)

    if ! command -v jq &>/dev/null; then
        echo "$summary"
        return
    fi

    local total errors
    total=$(echo "$summary" | jq -r '.total_entries // 0')
    errors=$(echo "$summary" | jq -r '.error_count // 0')

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                     SESSION SUMMARY                            ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Total entries: $total"
    echo "║ Errors: $errors"
    echo "║"
    echo "║ Activity by type:"
    echo "$summary" | jq -r '.entry_types[] | "║   \(.type): \(.count)"'
    echo "║"
    echo "║ Files modified:"
    echo "$summary" | jq -r '.files_modified[:10][] | "║   - \(.)"' 2>/dev/null || echo "║   (none)"
    echo "╚════════════════════════════════════════════════════════════════╝"
}

# ============================================================================
# COMPRESSION
# ============================================================================

# Compress old history entries
# Usage: compress_history [keep_recent]
compress_history() {
    local keep_recent="${1:-100}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        return
    fi

    local entry_count
    entry_count=$(wc -l < "$HISTORY_FILE" 2>/dev/null || echo "0")

    if [[ "$entry_count" -le "$keep_recent" ]]; then
        echo "History below threshold, no compression needed"
        return
    fi

    echo "Compressing history ($entry_count entries)..."

    # Generate summary of old entries
    local summary_file="$HISTORY_DIR/compressed-$(date +%Y%m%d%H%M%S).json"
    summarize_history > "$summary_file"

    # Keep only recent entries
    local temp_file
    temp_file=$(mktemp)
    tail -n "$keep_recent" "$HISTORY_FILE" > "$temp_file"
    mv "$temp_file" "$HISTORY_FILE"

    # Update summary file
    if command -v jq &>/dev/null; then
        local compressed_count
        compressed_count=$(jq -r '.compressed_count // 0' "$SUMMARY_FILE" 2>/dev/null || echo "0")
        jq --argjson count "$((compressed_count + entry_count - keep_recent))" '.compressed_count = $count' "$SUMMARY_FILE" > "$SUMMARY_FILE.tmp" && mv "$SUMMARY_FILE.tmp" "$SUMMARY_FILE"
    fi

    echo "Compressed $((entry_count - keep_recent)) entries"
    echo "Summary saved to: $summary_file"
}

# Compress context for AI consumption
# Usage: compress_context "long_context" [max_length]
compress_context() {
    local context="$1"
    local max_length="${2:-4000}"

    local current_length=${#context}

    if [[ "$current_length" -le "$max_length" ]]; then
        echo "$context"
        return
    fi

    echo "=== COMPRESSED CONTEXT ==="
    echo ""
    echo "Original length: $current_length characters"
    echo "Target length: $max_length characters"
    echo ""

    # Extract key parts
    echo "=== KEY SECTIONS ==="

    # First 500 chars (introduction)
    echo "${context:0:500}..."
    echo ""
    echo "[... content compressed ...]"
    echo ""
    # Last 500 chars (conclusion/recent)
    echo "...${context: -500}"
}

# ============================================================================
# GIT HISTORY
# ============================================================================

# Get summarized git commit history
# Usage: get_git_history [count] [since]
get_git_history() {
    local count="${1:-20}"
    local since="${2:-}"

    if ! command -v git &>/dev/null; then
        echo "Git not available" >&2
        return 1
    fi

    local git_args=("log" "--oneline" "-n" "$count" "--pretty=format:%h|%s|%an|%ar")

    if [[ -n "$since" ]]; then
        git_args+=("--since=$since")
    fi

    echo "=== Git History ==="
    echo ""

    git "${git_args[@]}" 2>/dev/null | while IFS='|' read -r hash subject author date; do
        printf "%-8s %-50s (%s, %s)\n" "$hash" "${subject:0:50}" "$author" "$date"
    done
}

# Get git history as JSON
# Usage: get_git_history_json [count]
get_git_history_json() {
    local count="${1:-20}"

    if ! command -v git &>/dev/null; then
        echo "[]"
        return
    fi

    echo "["
    local first=true
    git log --oneline -n "$count" --pretty=format:'%h|%s|%an|%ar|%at' 2>/dev/null | while IFS='|' read -r hash subject author date timestamp; do
        if [[ "$first" != true ]]; then echo ","; fi
        first=false
        # Escape subject for JSON
        subject=$(echo "$subject" | sed 's/\\/\\\\/g; s/"/\\"/g')
        echo "  {\"hash\":\"$hash\",\"subject\":\"$subject\",\"author\":\"$author\",\"date\":\"$date\",\"timestamp\":$timestamp}"
    done
    echo ""
    echo "]"
}

# Summarize changes between two commits
# Usage: summarize_commits [from] [to]
summarize_commits() {
    local from="${1:-HEAD~10}"
    local to="${2:-HEAD}"

    if ! command -v git &>/dev/null; then
        echo "Git not available" >&2
        return 1
    fi

    echo "=== Commit Summary: $from..$to ==="
    echo ""

    # Commit count
    local commit_count
    commit_count=$(git rev-list --count "$from..$to" 2>/dev/null || echo "0")
    echo "Commits: $commit_count"

    # Files changed
    echo ""
    echo "Files changed:"
    git diff --stat "$from..$to" 2>/dev/null | tail -n 5

    # Authors
    echo ""
    echo "Contributors:"
    git log "$from..$to" --format="%an" 2>/dev/null | sort | uniq -c | sort -rn | head -5 | sed 's/^/  /'
}

# ============================================================================
# TOPIC EXTRACTION
# ============================================================================

# Extract topics from history content
# Usage: extract_topics [count]
extract_topics() {
    local count="${1:-10}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo "[]"
        return
    fi

    # Extract common words (simple approach)
    grep -oE '"content":"[^"]*"' "$HISTORY_FILE" 2>/dev/null | \
        sed 's/"content":"//; s/"$//' | \
        tr ' ' '\n' | \
        grep -E '^[a-zA-Z]{4,}$' | \
        tr '[:upper:]' '[:lower:]' | \
        sort | uniq -c | sort -rn | \
        head -n "$count" | \
        awk '{print $2}'
}

# ============================================================================
# SESSION MANAGEMENT
# ============================================================================

# Start new session
# Usage: start_session [session_name]
start_session() {
    local name="${1:-$(date +%Y%m%d%H%M%S)}"

    export HARMONY_SESSION_ID="$name"

    init_history

    add_history_entry "session_start" "Session started: $name" "{\"session_name\":\"$name\"}"

    echo "Session started: $name"
}

# End session
# Usage: end_session
end_session() {
    local session_id="${HARMONY_SESSION_ID:-unknown}"

    add_history_entry "session_end" "Session ended: $session_id" "{}"

    # Generate final summary
    local summary_output="$HISTORY_DIR/session-$session_id-summary.json"
    summarize_history > "$summary_output"

    echo "Session ended: $session_id"
    echo "Summary saved to: $summary_output"

    unset HARMONY_SESSION_ID
}

# List sessions
# Usage: list_sessions
list_sessions() {
    echo "=== Sessions ==="

    if [[ -d "$HISTORY_DIR" ]]; then
        ls -la "$HISTORY_DIR"/*.json 2>/dev/null | while read -r line; do
            echo "  $line"
        done
    else
        echo "No sessions found"
    fi
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f add_history_entry get_history search_history
export -f summarize_history get_session_summary compress_history compress_context
export -f get_git_history get_git_history_json summarize_commits
export -f extract_topics start_session end_session list_sessions
export -f init_history

# ============================================================================
# CLI MODE - Run directly for testing
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        add)
            add_history_entry "${2:-note}" "${3:-Test entry}" "${4:-{}}"
            ;;
        get)
            get_history "${2:-50}" "${3:-}"
            ;;
        search)
            search_history "${2:-}" "${3:-}"
            ;;
        summary)
            get_session_summary
            ;;
        compress)
            compress_history "${2:-100}"
            ;;
        git)
            get_git_history "${2:-20}" "${3:-}"
            ;;
        git-json)
            get_git_history_json "${2:-20}"
            ;;
        commits)
            summarize_commits "${2:-HEAD~10}" "${3:-HEAD}"
            ;;
        topics)
            extract_topics "${2:-10}"
            ;;
        start)
            start_session "${2:-}"
            ;;
        end)
            end_session
            ;;
        sessions)
            list_sessions
            ;;
        init)
            init_history
            echo "History initialized at: $HISTORY_DIR"
            ;;
        *)
            echo "Usage: history-summarizer.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  add <type> <content> [meta] - Add history entry"
            echo "  get [count] [type]          - Get history entries"
            echo "  search <pattern> [type]     - Search history"
            echo "  summary                     - Show session summary"
            echo "  compress [keep]             - Compress old history"
            echo "  git [count] [since]         - Show git history"
            echo "  git-json [count]            - Git history as JSON"
            echo "  commits [from] [to]         - Summarize commits"
            echo "  topics [count]              - Extract common topics"
            echo "  start [name]                - Start new session"
            echo "  end                         - End current session"
            echo "  sessions                    - List sessions"
            echo "  init                        - Initialize history"
            ;;
    esac
fi
