#!/bin/bash
# =============================================================================
# json-ops.sh - Unified JSON/YAML operations with automatic fallback
# =============================================================================
#
# Usage: source json-ops.sh
#
# Strategy:
#   1. Use jq/yq if available (fastest)
#   2. Fall back to json-helper.mjs if jq/yq not installed
#
# This allows the framework to work on systems without jq/yq installed
# while still providing optimal performance when they are available.
#

# Detect available tools
_detect_json_tools() {
    if command -v jq &>/dev/null; then
        JSON_TOOL="jq"
    elif command -v node &>/dev/null; then
        JSON_TOOL="node"
    else
        echo "ERROR: Neither jq nor Node.js found. Install one of them." >&2
        return 1
    fi

    if command -v yq &>/dev/null; then
        YAML_TOOL="yq"
    elif command -v node &>/dev/null; then
        YAML_TOOL="node"
    else
        YAML_TOOL="none"
    fi

    export JSON_TOOL YAML_TOOL
}

# Get JSON helper path
_get_helper_path() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$script_dir/json-helper.mjs"
}

# =============================================================================
# JSON Operations
# =============================================================================

# Read value from JSON file
# Usage: json_read <file> <path>
# Example: json_read config.json "user.name"
json_read() {
    local file="$1"
    local path="$2"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r ".$path // empty" "$file" 2>/dev/null
            ;;
        node)
            node "$(_get_helper_path)" read "$file" "$path"
            ;;
        *)
            echo "ERROR: No JSON tool available" >&2
            return 1
            ;;
    esac
}

# Write value to JSON file
# Usage: json_write <file> <path> <value>
# Example: json_write config.json "user.name" "John"
json_write() {
    local file="$1"
    local path="$2"
    local value="$3"

    case "$JSON_TOOL" in
        jq)
            local tmp
            tmp=$(mktemp)
            if [[ -f "$file" ]]; then
                jq ".$path = $value" "$file" > "$tmp" && mv "$tmp" "$file"
            else
                echo "{}" | jq ".$path = $value" > "$file"
            fi
            ;;
        node)
            node "$(_get_helper_path)" write "$file" "$path" "$value"
            ;;
        *)
            echo "ERROR: No JSON tool available" >&2
            return 1
            ;;
    esac
}

# Filter array in JSON file
# Usage: json_filter <file> <array_path> <key> <value>
# Example: json_filter data.json "stories" "status" "TODO"
json_filter() {
    local file="$1"
    local array_path="$2"
    local key="$3"
    local value="$4"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq "[.$array_path[] | select(.$key == \"$value\")]" "$file"
            ;;
        node)
            node "$(_get_helper_path)" filter "$file" "$array_path" "$key" "$value"
            ;;
        *)
            echo "ERROR: No JSON tool available" >&2
            return 1
            ;;
    esac
}

# Count items in array
# Usage: json_count <file> <array_path> [key] [value]
# Example: json_count data.json "stories"
# Example: json_count data.json "stories" "status" "TODO"
json_count() {
    local file="$1"
    local array_path="$2"
    local key="${3:-}"
    local value="${4:-}"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            if [[ -n "$key" && -n "$value" ]]; then
                jq "[.$array_path[] | select(.$key == \"$value\")] | length" "$file"
            else
                jq ".$array_path | length" "$file"
            fi
            ;;
        node)
            node "$(_get_helper_path)" count "$file" "$array_path" "$key" "$value"
            ;;
        *)
            echo "ERROR: No JSON tool available" >&2
            return 1
            ;;
    esac
}

# Validate JSON file
# Usage: json_validate <file>
json_validate() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            if jq empty "$file" 2>/dev/null; then
                echo "valid"
            else
                echo "invalid"
                return 1
            fi
            ;;
        node)
            node "$(_get_helper_path)" validate "$file"
            ;;
        *)
            echo "ERROR: No JSON tool available" >&2
            return 1
            ;;
    esac
}

# Merge two JSON files
# Usage: json_merge <file1> <file2>
json_merge() {
    local file1="$1"
    local file2="$2"

    if [[ ! -f "$file1" || ! -f "$file2" ]]; then
        echo "ERROR: One or both files not found" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq -s '.[0] * .[1]' "$file1" "$file2"
            ;;
        node)
            node "$(_get_helper_path)" merge "$file1" "$file2"
            ;;
        *)
            echo "ERROR: No JSON tool available" >&2
            return 1
            ;;
    esac
}

# Raw jq command with fallback warning
# Usage: json_raw <jq_expression> <file>
# Note: Complex expressions require jq
json_raw() {
    local expr="$1"
    local file="$2"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq "$expr" "$file"
            ;;
        node)
            echo "WARNING: Complex jq expression requires jq: $expr" >&2
            echo "Install: apt install jq / brew install jq" >&2
            return 1
            ;;
    esac
}

# Raw jq command with raw output (-r flag)
# Usage: json_raw_r <jq_expression> <file>
json_raw_r() {
    local expr="$1"
    local file="$2"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r "$expr" "$file"
            ;;
        node)
            echo "WARNING: Complex jq expression requires jq: $expr" >&2
            return 1
            ;;
    esac
}

# Update JSON with jq expression (in-place)
# Usage: json_update <file> <jq_expression>
json_update() {
    local file="$1"
    local expr="$2"

    case "$JSON_TOOL" in
        jq)
            local tmp
            tmp=$(mktemp)
            jq "$expr" "$file" > "$tmp" && mv "$tmp" "$file"
            ;;
        node)
            echo "WARNING: Complex jq update requires jq: $expr" >&2
            return 1
            ;;
    esac
}

# Update JSON with jq expression and arguments
# Usage: json_update_arg <file> <jq_expression> <arg_name> <arg_value> [<arg_name2> <arg_value2> ...]
json_update_arg() {
    local file="$1"
    local expr="$2"
    shift 2

    case "$JSON_TOOL" in
        jq)
            local args=()
            while [[ $# -ge 2 ]]; do
                args+=(--arg "$1" "$2")
                shift 2
            done
            local tmp
            tmp=$(mktemp)
            jq "${args[@]}" "$expr" "$file" > "$tmp" && mv "$tmp" "$file"
            ;;
        node)
            echo "WARNING: Complex jq update requires jq" >&2
            return 1
            ;;
    esac
}

# Check if jq is available (for conditional logic in scripts)
# Usage: if json_has_jq; then ... fi
json_has_jq() {
    [[ "${JSON_TOOL:-}" == "jq" ]]
}

# Check if yq is available
# Usage: if json_has_yq; then ... fi
json_has_yq() {
    [[ "${YAML_TOOL:-}" == "yq" ]]
}

# Require jq for current operation (fail with helpful message if not available)
# Usage: json_require_jq "operation name"
json_require_jq() {
    local operation="${1:-this operation}"
    if ! json_has_jq; then
        echo "ERROR: $operation requires jq to be installed" >&2
        echo "Install: apt install jq OR brew install jq" >&2
        return 1
    fi
}

# =============================================================================
# High-Level Operations (Common Patterns)
# =============================================================================

# Read value with default fallback
# Usage: json_read_default <file> <path> <default>
# Example: json_read_default config.json "user.name" "unknown"
json_read_default() {
    local file="$1"
    local path="$2"
    local default="$3"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return 0
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r ".${path} // \"${default}\"" "$file" 2>/dev/null || echo "$default"
            ;;
        node)
            local result
            result=$(node "$(_get_helper_path)" read "$file" "$path" 2>/dev/null)
            if [[ -z "$result" || "$result" == "null" ]]; then
                echo "$default"
            else
                echo "$result"
            fi
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Count items in array with optional filter
# Usage: json_count_where <file> <array_path> <key> <value>
# Example: json_count_where data.json "stories" "status" "DONE"
json_count_where() {
    local file="$1"
    local array_path="$2"
    local key="$3"
    local value="$4"

    if [[ ! -f "$file" ]]; then
        echo "0"
        return 0
    fi

    case "$JSON_TOOL" in
        jq)
            jq "[.${array_path}[]? | select(.${key} == \"${value}\")] | length" "$file" 2>/dev/null || echo "0"
            ;;
        node)
            node "$(_get_helper_path)" count "$file" "$array_path" "$key" "$value" 2>/dev/null || echo "0"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Get array length
# Usage: json_array_length <file> <array_path>
# Example: json_array_length data.json "stories"
json_array_length() {
    local file="$1"
    local array_path="$2"

    if [[ ! -f "$file" ]]; then
        echo "0"
        return 0
    fi

    case "$JSON_TOOL" in
        jq)
            jq ".${array_path} | length // 0" "$file" 2>/dev/null || echo "0"
            ;;
        node)
            node "$(_get_helper_path)" count "$file" "$array_path" 2>/dev/null || echo "0"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Get first item from array matching condition
# Usage: json_first_where <file> <array_path> <key> <value>
# Example: json_first_where data.json "stories" "status" "TODO"
json_first_where() {
    local file="$1"
    local array_path="$2"
    local key="$3"
    local value="$4"

    if [[ ! -f "$file" ]]; then
        echo "null"
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq "[.${array_path}[]? | select(.${key} == \"${value}\")] | first // null" "$file" 2>/dev/null
            ;;
        node)
            # Filter and take first
            local result
            result=$(node "$(_get_helper_path)" filter "$file" "$array_path" "$key" "$value" 2>/dev/null)
            echo "$result" | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log(JSON.stringify(d[0]||null))" 2>/dev/null || echo "null"
            ;;
        *)
            echo "null"
            return 1
            ;;
    esac
}

# Get field from first matching item
# Usage: json_first_field <file> <array_path> <filter_key> <filter_value> <field>
# Example: json_first_field data.json "stories" "status" "TODO" "id"
json_first_field() {
    local file="$1"
    local array_path="$2"
    local filter_key="$3"
    local filter_value="$4"
    local field="$5"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r "[.${array_path}[]? | select(.${filter_key} == \"${filter_value}\")] | first | .${field} // empty" "$file" 2>/dev/null
            ;;
        node)
            local result
            result=$(json_first_where "$file" "$array_path" "$filter_key" "$filter_value")
            if [[ "$result" != "null" && -n "$result" ]]; then
                echo "$result" | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log(d?.${field}||'')" 2>/dev/null
            fi
            ;;
    esac
}

# Set nested value (creates intermediate objects if needed)
# Usage: json_set <file> <path> <value>
# Example: json_set config.json "database.host" "localhost"
json_set() {
    local file="$1"
    local path="$2"
    local value="$3"

    case "$JSON_TOOL" in
        jq)
            local tmp
            tmp=$(mktemp)
            if [[ -f "$file" ]]; then
                # Try to parse value as JSON, otherwise use string
                if echo "$value" | jq empty 2>/dev/null; then
                    jq ".${path} = ${value}" "$file" > "$tmp" && mv "$tmp" "$file"
                else
                    jq ".${path} = \"${value}\"" "$file" > "$tmp" && mv "$tmp" "$file"
                fi
            else
                mkdir -p "$(dirname "$file")"
                echo "{}" | jq ".${path} = \"${value}\"" > "$file"
            fi
            ;;
        node)
            node "$(_get_helper_path)" write "$file" "$path" "$value"
            ;;
    esac
}

# =============================================================================
# YAML Operations
# =============================================================================

# Read value from YAML file
# Usage: yaml_read <file> <path>
# Example: yaml_read config.yaml "database.host"
yaml_read() {
    local file="$1"
    local path="$2"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    case "$YAML_TOOL" in
        yq)
            yq -r ".$path" "$file" 2>/dev/null
            ;;
        node)
            node "$(_get_helper_path)" yaml-read "$file" "$path"
            ;;
        *)
            echo "ERROR: No YAML tool available. Install yq or yaml npm package." >&2
            return 1
            ;;
    esac
}

# Write value to YAML file
# Usage: yaml_write <file> <path> <value>
yaml_write() {
    local file="$1"
    local path="$2"
    local value="$3"

    case "$YAML_TOOL" in
        yq)
            local tmp
            tmp=$(mktemp)
            if [[ -f "$file" ]]; then
                yq ".$path = \"$value\"" "$file" > "$tmp" && mv "$tmp" "$file"
            else
                echo "---" | yq ".$path = \"$value\"" > "$file"
            fi
            ;;
        node)
            node "$(_get_helper_path)" yaml-write "$file" "$path" "$value"
            ;;
        *)
            echo "ERROR: No YAML tool available" >&2
            return 1
            ;;
    esac
}

# Convert YAML file to JSON
# Usage: yaml_to_json <file>
# Returns JSON on stdout
yaml_to_json() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "{}"
        return 1
    fi

    case "$YAML_TOOL" in
        yq)
            # Try python-yq syntax first, then mikefarah syntax
            cat "$file" | yq '.' 2>/dev/null || \
            yq -o=json '.' "$file" 2>/dev/null || \
            echo "{}"
            ;;
        node)
            # Node.js with yaml package
            node "$(_get_helper_path)" yaml-to-json "$file" 2>/dev/null || echo "{}"
            ;;
        *)
            echo "{}"
            return 1
            ;;
    esac
}

# =============================================================================
# Status and Info
# =============================================================================

# Show which tools are being used
# Usage: json_status
json_status() {
    echo "JSON Operations:"
    echo "  Tool: $JSON_TOOL"
    if [[ "$JSON_TOOL" == "jq" ]]; then
        echo "  Version: $(jq --version 2>/dev/null)"
        echo "  Status: OPTIMAL (native)"
    else
        echo "  Status: FALLBACK (Node.js)"
        echo "  Tip: Install jq for 7x faster performance"
    fi

    echo ""
    echo "YAML Operations:"
    echo "  Tool: $YAML_TOOL"
    if [[ "$YAML_TOOL" == "yq" ]]; then
        echo "  Version: $(yq --version 2>/dev/null)"
        echo "  Status: OPTIMAL (native)"
    elif [[ "$YAML_TOOL" == "node" ]]; then
        echo "  Status: FALLBACK (Node.js with yaml package)"
    else
        echo "  Status: NOT AVAILABLE"
    fi
}

# =============================================================================
# Initialize
# =============================================================================

# Auto-detect tools when sourced
_detect_json_tools
