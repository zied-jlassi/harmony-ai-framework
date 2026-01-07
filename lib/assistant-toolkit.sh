#!/usr/bin/env bash
# ============================================================================
# assistant-toolkit.sh - Unified Assistant Toolkit for Harmony Framework
# ============================================================================
# Orchestrates all assistant modules:
#   - model-manager.sh    : Model aliases, tiers, cost estimation
#   - auto-linter.sh      : Automatic linting and code quality
#   - repomap.sh          : Repository structure and analysis
#   - file-watcher.sh     : File change detection and hooks
#   - history-summarizer.sh : Session history and context compression
#
# Usage: source assistant-toolkit.sh
#
# Main Functions:
#   - assistant_init           : Initialize all toolkit modules
#   - assistant_status         : Show status of all modules
#   - assistant_workflow       : Run complete assistant workflow
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
ASSISTANT_TOOLKIT_VERSION="1.0.0"
ASSISTANT_TOOLKIT_DIR="${ASSISTANT_TOOLKIT_DIR:-${HARMONY_DIR:-$HOME/.harmony}/assistant-toolkit}"

# Module paths (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Module files
declare -A ASSISTANT_MODULES=(
    ["model-manager"]="$SCRIPT_DIR/model-manager.sh"
    ["auto-linter"]="$SCRIPT_DIR/auto-linter.sh"
    ["repomap"]="$SCRIPT_DIR/repomap.sh"
    ["file-watcher"]="$SCRIPT_DIR/file-watcher.sh"
    ["history-summarizer"]="$SCRIPT_DIR/history-summarizer.sh"
)

# Module status
declare -A MODULE_LOADED=()

# ============================================================================
# MODULE LOADING
# ============================================================================

# Load a single module
# Usage: load_module "model-manager"
load_module() {
    local module="$1"
    local module_path="${ASSISTANT_MODULES[$module]:-}"

    if [[ -z "$module_path" ]]; then
        echo "Unknown module: $module" >&2
        return 1
    fi

    if [[ ! -f "$module_path" ]]; then
        echo "Module not found: $module_path" >&2
        return 1
    fi

    if [[ "${MODULE_LOADED[$module]:-}" == "true" ]]; then
        return 0  # Already loaded
    fi

    # shellcheck source=/dev/null
    source "$module_path"
    MODULE_LOADED["$module"]="true"

    return 0
}

# Load all modules
# Usage: load_all_modules
load_all_modules() {
    local failed=0

    for module in "${!ASSISTANT_MODULES[@]}"; do
        if load_module "$module" 2>/dev/null; then
            echo "  ✓ $module"
        else
            echo "  ✗ $module (failed)"
            ((++failed)) || true
        fi
    done

    return $failed
}

# Check if module is loaded
# Usage: is_module_loaded "model-manager"
is_module_loaded() {
    local module="$1"
    [[ "${MODULE_LOADED[$module]:-}" == "true" ]]
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Initialize toolkit
# Usage: assistant_init [directory]
assistant_init() {
    local dir="${1:-.}"

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           ASSISTANT TOOLKIT INITIALIZATION                     ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Version: $ASSISTANT_TOOLKIT_VERSION"
    echo "║ Directory: $dir"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    # Create toolkit directory
    mkdir -p "$ASSISTANT_TOOLKIT_DIR"

    # Load all modules
    echo "Loading modules:"
    load_all_modules

    echo ""

    # Initialize each module
    echo "Initializing modules:"

    # History
    if is_module_loaded "history-summarizer"; then
        init_history 2>/dev/null && echo "  ✓ History initialized" || echo "  ✗ History init failed"
    fi

    # Repomap cache
    if is_module_loaded "repomap"; then
        mkdir -p "${REPOMAP_CACHE_DIR:-/tmp/harmony-repomap}"
        echo "  ✓ Repomap cache ready"
    fi

    # File watcher state
    if is_module_loaded "file-watcher"; then
        init_watch_state "$dir" 2>/dev/null && echo "  ✓ File watcher initialized" || echo "  ✗ Watcher init failed"
    fi

    echo ""
    echo "Toolkit ready!"
}

# ============================================================================
# STATUS AND INFO
# ============================================================================

# Show toolkit status
# Usage: assistant_status
assistant_status() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║               ASSISTANT TOOLKIT STATUS                         ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Version: $ASSISTANT_TOOLKIT_VERSION"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    echo "=== Module Status ==="
    for module in "${!ASSISTANT_MODULES[@]}"; do
        local status="not loaded"
        local path="${ASSISTANT_MODULES[$module]}"

        if [[ "${MODULE_LOADED[$module]:-}" == "true" ]]; then
            status="loaded"
        elif [[ -f "$path" ]]; then
            status="available"
        else
            status="missing"
        fi

        printf "  %-20s %s\n" "$module:" "$status"
    done

    echo ""

    # Model Manager status
    if is_module_loaded "model-manager"; then
        echo "=== Model Configuration ==="
        echo "  Main:   ${HARMONY_MAIN_MODEL:-not set}"
        echo "  Weak:   ${HARMONY_WEAK_MODEL:-not set}"
        echo "  Editor: ${HARMONY_EDITOR_MODEL:-not set}"
        echo ""
    fi

    # File Watcher status
    if is_module_loaded "file-watcher"; then
        echo "=== File Watcher ==="
        watch_status 2>/dev/null || echo "  Not running"
        echo ""
    fi

    # History status
    if is_module_loaded "history-summarizer"; then
        echo "=== Session History ==="
        if [[ -f "${HISTORY_FILE:-}" ]]; then
            local count
            count=$(wc -l < "$HISTORY_FILE" 2>/dev/null || echo "0")
            echo "  Entries: $count"
            echo "  Session: ${HARMONY_SESSION_ID:-none}"
        else
            echo "  No history file"
        fi
        echo ""
    fi
}

# ============================================================================
# INTEGRATED WORKFLOWS
# ============================================================================

# Run assistant workflow on a file
# Usage: assistant_workflow "file.ts" [--fix]
assistant_workflow() {
    local file="$1"
    local fix_flag="${2:-}"

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file" >&2
        return 1
    fi

    echo "=== Assistant Workflow: $file ==="
    echo ""

    # 1. Detect language
    local language="unknown"
    if is_module_loaded "auto-linter"; then
        language=$(detect_language "$file" 2>/dev/null) || language="unknown"
        echo "Language: $language"
    fi

    # 2. Get file summary
    if is_module_loaded "repomap"; then
        echo ""
        get_file_summary "$file" 5
    fi

    # 3. Select appropriate model
    local model="${HARMONY_EDITOR_MODEL:-anthropic/claude-sonnet-4}"
    if is_module_loaded "model-manager"; then
        model=$(get_model_for_task "edit" 2>/dev/null) || model="$HARMONY_EDITOR_MODEL"
        echo ""
        echo "Model: $model"
    fi

    # 4. Run linting
    if is_module_loaded "auto-linter"; then
        echo ""
        echo "=== Linting ==="
        run_lint_check "$file" "$fix_flag" 2>/dev/null || true
    fi

    # 5. Log to history
    if is_module_loaded "history-summarizer"; then
        add_history_entry "workflow" "Assistant workflow on $file" "{\"file\":\"$file\",\"language\":\"$language\"}" 2>/dev/null || true
    fi

    echo ""
    echo "Workflow complete!"
}

# Run workflow on changed files
# Usage: assistant_workflow_changed [--fix]
assistant_workflow_changed() {
    local fix_flag="${1:-}"

    if ! is_module_loaded "file-watcher"; then
        echo "File watcher module not loaded" >&2
        return 1
    fi

    local changes
    changes=$(detect_changes "." 2>/dev/null) || changes=""

    if [[ -z "$changes" ]]; then
        echo "No changes detected"
        return 0
    fi

    echo "=== Processing Changed Files ==="
    echo ""

    while IFS=: read -r event file; do
        if [[ "$event" != "deleted" && -f "$file" ]]; then
            assistant_workflow "$file" "$fix_flag"
            echo ""
        fi
    done <<< "$changes"
}

# Generate project context for AI
# Usage: assistant_context [directory]
assistant_context() {
    local dir="${1:-.}"

    echo "=== AI Context for $dir ==="
    echo ""

    # Repomap
    if is_module_loaded "repomap"; then
        generate_repomap "$dir" "text" 2>/dev/null
    fi

    # Git history
    if is_module_loaded "history-summarizer" && command -v git &>/dev/null; then
        echo ""
        get_git_history 10 2>/dev/null || true
    fi

    # Available models
    if is_module_loaded "model-manager"; then
        echo ""
        list_models --tiers 2>/dev/null || true
    fi
}

# ============================================================================
# QUICK COMMANDS
# ============================================================================

# Quick lint all changed files
# Usage: assistant_lint [--fix]
assistant_lint() {
    local fix_flag="${1:-}"

    if ! is_module_loaded "auto-linter"; then
        load_module "auto-linter"
    fi

    if command -v git &>/dev/null; then
        lint_changed_files "$fix_flag"
    else
        echo "Git not available for change detection" >&2
        return 1
    fi
}

# Quick model info
# Usage: assistant_model [alias]
assistant_model() {
    local alias="${1:-}"

    if ! is_module_loaded "model-manager"; then
        load_module "model-manager"
    fi

    if [[ -n "$alias" ]]; then
        local resolved
        resolved=$(resolve_model "$alias")
        echo "Alias: $alias"
        echo "Model: $resolved"
        echo "Tier:  $(get_model_tier "$resolved")"
        echo "Cost:  $(estimate_model_cost "$resolved" 1000 500) USD (1K in / 0.5K out)"
    else
        list_models --all
    fi
}

# Quick repomap
# Usage: assistant_map [directory] [format]
assistant_map() {
    local dir="${1:-.}"
    local format="${2:-text}"

    if ! is_module_loaded "repomap"; then
        load_module "repomap"
    fi

    generate_repomap "$dir" "$format"
}

# Quick history
# Usage: assistant_history [count]
assistant_history() {
    local count="${1:-20}"

    if ! is_module_loaded "history-summarizer"; then
        load_module "history-summarizer"
    fi

    get_history "$count"
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f assistant_init assistant_status assistant_workflow assistant_workflow_changed assistant_context
export -f assistant_lint assistant_model assistant_map assistant_history
export -f load_module load_all_modules is_module_loaded

# ============================================================================
# AUTO-LOAD ON SOURCE
# ============================================================================

# Automatically load all modules when sourced
if [[ "${ASSISTANT_TOOLKIT_AUTOLOAD:-true}" == "true" ]]; then
    for module in "${!ASSISTANT_MODULES[@]}"; do
        load_module "$module" 2>/dev/null || true
    done
fi

# ============================================================================
# CLI MODE - Run directly for testing
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        init)
            assistant_init "${2:-.}"
            ;;
        status)
            assistant_status
            ;;
        workflow)
            assistant_workflow "${2:-}" "${3:-}"
            ;;
        changed)
            assistant_workflow_changed "${2:-}"
            ;;
        context)
            assistant_context "${2:-.}"
            ;;
        lint)
            assistant_lint "${2:-}"
            ;;
        model)
            assistant_model "${2:-}"
            ;;
        map)
            assistant_map "${2:-.}" "${3:-text}"
            ;;
        history)
            assistant_history "${2:-20}"
            ;;
        load)
            load_module "${2:-}"
            echo "Module ${2:-} loaded"
            ;;
        *)
            echo "Assistant Toolkit v$ASSISTANT_TOOLKIT_VERSION"
            echo ""
            echo "Usage: assistant-toolkit.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  init [dir]              - Initialize toolkit"
            echo "  status                  - Show toolkit status"
            echo "  workflow <file> [--fix] - Run workflow on file"
            echo "  changed [--fix]         - Process changed files"
            echo "  context [dir]           - Generate AI context"
            echo "  lint [--fix]            - Lint changed files"
            echo "  model [alias]           - Show model info"
            echo "  map [dir] [format]      - Generate repomap"
            echo "  history [count]         - Show history"
            echo "  load <module>           - Load specific module"
            ;;
    esac
fi
