#!/usr/bin/env bash
#
# sync-mcp.sh - Sync error-library to MCP Memory
#
# Usage: ./sync-mcp.sh [category]
#
# This script outputs JSON that can be used with mcp__memory__create_entities
# Claude can read this output and execute the MCP calls
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_DIR="$(dirname "$SCRIPT_DIR")"
ERRORS_DIR="$LIBRARY_DIR/errors"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

category="${1:-all}"

echo "{"
echo '  "action": "sync_to_mcp_memory",'
echo '  "instructions": "Use mcp__memory__create_entities with these entities",'
echo '  "entities": ['

first=true

# Function to process a single error file
process_error() {
    local file="$1"
    local id=$(jq -r '.id' "$file")
    local title=$(jq -r '.title' "$file")
    local error=$(jq -r '.error' "$file")
    local solution=$(jq -r '.solution' "$file")
    local example_bad=$(jq -r '.example_bad // ""' "$file")
    local example_good=$(jq -r '.example_good // ""' "$file")
    local severity=$(jq -r '.severity' "$file")

    if [[ "$first" != "true" ]]; then
        echo ","
    fi
    first=false

    cat << EOF
    {
      "name": "Error_${id}",
      "entityType": "ErrorSolution",
      "observations": [
        "ID: ${id}",
        "Title: ${title}",
        "Severity: ${severity}",
        "Error: ${error}",
        "Solution: ${solution}",
        "Bad: ${example_bad}",
        "Good: ${example_good}"
      ]
    }
EOF
}

# Process errors
if [[ "$category" == "all" ]]; then
    for cat_dir in "$ERRORS_DIR"/*/; do
        if [[ -d "$cat_dir" ]]; then
            for error_file in "$cat_dir"/*.json; do
                [[ "$(basename "$error_file")" == "index.json" ]] && continue
                [[ -f "$error_file" ]] && process_error "$error_file"
            done
        fi
    done
else
    cat_dir="$ERRORS_DIR/$category"
    if [[ -d "$cat_dir" ]]; then
        for error_file in "$cat_dir"/*.json; do
            [[ "$(basename "$error_file")" == "index.json" ]] && continue
            [[ -f "$error_file" ]] && process_error "$error_file"
        done
    else
        echo "Category not found: $category" >&2
        exit 1
    fi
fi

echo ""
echo "  ]"
echo "}"
