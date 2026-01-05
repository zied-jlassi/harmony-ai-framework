#!/usr/bin/env bash
#
# error-library-loader.sh - Load and search error-library
#
# Part of Harmony Framework
# Integrates error-library with framework and MCP Memory
#

# Get library path
_get_error_library_path() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(dirname "$script_dir")/error-library"
}

ERROR_LIBRARY_PATH="$(_get_error_library_path)"

# =============================================================================
# SEARCH FUNCTIONS
# =============================================================================

# Search errors by keyword
# Usage: search_errors "set -e"
search_errors() {
    local keyword="$1"
    local results=()

    for error_file in "$ERROR_LIBRARY_PATH"/errors/*/*.json; do
        [[ "$(basename "$error_file")" == "index.json" ]] && continue
        [[ ! -f "$error_file" ]] && continue

        if grep -qi "$keyword" "$error_file" 2>/dev/null; then
            local id=$(jq -r '.id' "$error_file")
            local title=$(jq -r '.title' "$error_file")
            echo "$id: $title"
        fi
    done
}

# Get error by ID
# Usage: get_error "BASH-001"
get_error() {
    local error_id="$1"
    local category="${error_id%%-*}"
    category=$(echo "$category" | tr '[:upper:]' '[:lower:]')

    local error_file="$ERROR_LIBRARY_PATH/errors/$category/$error_id.json"

    if [[ -f "$error_file" ]]; then
        cat "$error_file"
    else
        echo "Error not found: $error_id" >&2
        return 1
    fi
}

# Get error solution (short format)
# Usage: get_error_solution "BASH-001"
get_error_solution() {
    local error_id="$1"
    local error_json=$(get_error "$error_id" 2>/dev/null)

    if [[ -n "$error_json" ]]; then
        echo "$error_json" | jq -r '"Problem: " + .error + "\nSolution: " + .solution + "\nExample: " + .example_good'
    fi
}

# =============================================================================
# LIST FUNCTIONS
# =============================================================================

# List all errors
# Usage: list_errors [category]
list_errors() {
    local category="${1:-all}"

    if [[ "$category" == "all" ]]; then
        for index_file in "$ERROR_LIBRARY_PATH"/errors/*/index.json; do
            [[ -f "$index_file" ]] || continue
            local cat=$(jq -r '.category' "$index_file")
            echo "=== $cat ==="
            jq -r '.errors[] | "  " + .id + ": " + .title + " [" + .severity + "]"' "$index_file"
        done
    else
        local index_file="$ERROR_LIBRARY_PATH/errors/$category/index.json"
        if [[ -f "$index_file" ]]; then
            jq -r '.errors[] | .id + ": " + .title + " [" + .severity + "]"' "$index_file"
        else
            echo "Category not found: $category" >&2
            return 1
        fi
    fi
}

# List categories
# Usage: list_error_categories
list_error_categories() {
    jq -r '.categories[] | .name + " (" + (.count|tostring) + " errors)"' \
        "$ERROR_LIBRARY_PATH/index.json"
}

# =============================================================================
# MCP MEMORY SYNC
# =============================================================================

# Generate MCP entities JSON
# Usage: generate_mcp_entities [category]
generate_mcp_entities() {
    local category="${1:-all}"
    bash "$ERROR_LIBRARY_PATH/tools/sync-mcp.sh" "$category"
}

# Check if error exists in MCP memory (requires mcp tools)
# Usage: check_error_in_memory "BASH-001"
# Returns: 0 if exists, 1 if not
check_error_in_memory() {
    local error_id="$1"
    # This would need MCP tools - placeholder for now
    # mcp__memory__search_nodes "Error_$error_id"
    echo "MCP check not implemented in bash - use Claude tools"
    return 1
}

# =============================================================================
# STATS
# =============================================================================

# Get library stats
# Usage: error_library_stats
error_library_stats() {
    local index="$ERROR_LIBRARY_PATH/index.json"
    if [[ -f "$index" ]]; then
        echo "Error Library v$(jq -r '.version' "$index")"
        echo "Total errors: $(jq -r '.stats.total_errors' "$index")"
        echo "Categories: $(jq -r '.stats.categories' "$index")"
        echo "Last updated: $(jq -r '.stats.last_updated' "$index")"
    fi
}

# =============================================================================
# AUTO-LOAD ON ERROR (for hooks)
# =============================================================================

# Suggest solution for detected error pattern
# Usage: suggest_solution "error message"
suggest_solution() {
    local error_msg="$1"

    # Pattern matching for common errors
    if [[ "$error_msg" == *"((VAR++))"* ]] || [[ "$error_msg" == *"bad math"* ]]; then
        get_error_solution "BASH-001"
        return 0
    fi

    if [[ "$error_msg" == *"quantifier"* ]] || [[ "$error_msg" == *"{4}"* ]]; then
        get_error_solution "BASH-002"
        return 0
    fi

    if [[ "$error_msg" == *"exit code"* ]] || [[ "$error_msg" == *"set -e"* ]]; then
        get_error_solution "BASH-003"
        return 0
    fi

    # No match - search
    local results=$(search_errors "$error_msg" 2>/dev/null | head -3)
    if [[ -n "$results" ]]; then
        echo "Possible matches:"
        echo "$results"
    else
        echo "No matching error found in library"
    fi
}
