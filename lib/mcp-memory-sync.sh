#!/bin/bash
# =============================================================================
# Harmony Framework - MCP Memory Sync Module
# =============================================================================
#
# ROLE: Synchronize Sentinel error-journal.json to MCP server-memory
#       for cross-session learning and semantic retrieval.
#
# ARCHITECTURE:
#   error-journal.json (source of truth) → server-memory (cross-session)
#
# USAGE:
#   source "${HARMONY_DIR}/lib/mcp-memory-sync.sh"
#   mcp_sync_all_errors           # Sync all errors
#   mcp_search_errors "bash"      # Search errors by keyword
#
# DEPENDENCIES:
#   - jq (JSON processing)
#   - MCP server-memory must be configured in client
#
# NOTE: This module READS from error-journal.json. It does NOT modify it.
#       error-journal.json remains the single source of truth.
#
# =============================================================================

set -euo pipefail

# Don't re-source if already loaded
if [[ "${MCP_MEMORY_SYNC_LOADED:-}" == "true" ]]; then
    return 0
fi
MCP_MEMORY_SYNC_LOADED=true

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_MEMORY_PREFIX="${MCP_MEMORY_PREFIX:-harmony}"
MCP_MEMORY_ENABLED="${MCP_MEMORY_ENABLED:-true}"

# Entity types for knowledge graph
MCP_ENTITY_ERROR="HarmonyError"
MCP_ENTITY_PATTERN="HarmonyPattern"
MCP_ENTITY_MODULE="HarmonyModule"
MCP_ENTITY_CATEGORY="ErrorCategory"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Check if MCP memory is available (conceptual - actual check done by client)
_mcp_available() {
    [[ "$MCP_MEMORY_ENABLED" == "true" ]]
}

# Get error journal path
_get_error_journal_path() {
    local harmony_dir="${HARMONY_DIR:-.harmony}"
    echo "${harmony_dir}/memory/error-journal.json"
}

# Log with prefix
_mcp_log() {
    local level="$1"
    local message="$2"
    echo "[MCP-SYNC] [$level] $message" >&2
}

# =============================================================================
# ERROR TO ENTITY CONVERSION
# =============================================================================

# Convert a single error from error-journal.json to MCP entity format
# Input: JSON error object
# Output: JSON entity object for mcp__memory__create_entities
error_to_entity() {
    local error_json="$1"

    local id category severity title symptom root_cause solution prevention tags

    id=$(echo "$error_json" | jq -r '.id // "unknown"')
    category=$(echo "$error_json" | jq -r '.category // "general"')
    severity=$(echo "$error_json" | jq -r '.severity // "medium"')
    title=$(echo "$error_json" | jq -r '.title // ""')
    symptom=$(echo "$error_json" | jq -r '.symptom // ""')
    root_cause=$(echo "$error_json" | jq -r '.root_cause // ""')
    solution=$(echo "$error_json" | jq -r '.correct_solution // ""')
    prevention=$(echo "$error_json" | jq -r '.prevention_rule // ""')

    # Build observations array (what the entity "knows")
    local observations=()
    [[ -n "$title" ]] && observations+=("Title: $title")
    [[ -n "$symptom" ]] && observations+=("Symptom: $symptom")
    [[ -n "$root_cause" ]] && observations+=("Root cause: $root_cause")
    [[ -n "$solution" ]] && observations+=("Solution: $solution")
    [[ -n "$prevention" ]] && observations+=("Prevention: $prevention")
    observations+=("Severity: $severity")
    observations+=("Category: $category")

    # Add tags as observations
    local tags_str
    tags_str=$(echo "$error_json" | jq -r '.tags[]? // empty' | tr '\n' ',' | sed 's/,$//')
    [[ -n "$tags_str" ]] && observations+=("Tags: $tags_str")

    # Build observations JSON array
    local obs_json="[]"
    for obs in "${observations[@]}"; do
        obs_json=$(echo "$obs_json" | jq --arg o "$obs" '. + [$o]')
    done

    # Return entity JSON
    jq -n -c \
        --arg name "$id" \
        --arg entityType "$MCP_ENTITY_ERROR" \
        --argjson observations "$obs_json" \
        '{
            name: $name,
            entityType: $entityType,
            observations: $observations
        }'
}

# =============================================================================
# RELATION BUILDING
# =============================================================================

# Build relations for an error
# Returns: JSON array of relations
error_to_relations() {
    local error_json="$1"

    local id category related_pattern context_module

    id=$(echo "$error_json" | jq -r '.id')
    category=$(echo "$error_json" | jq -r '.category // "general"')
    related_pattern=$(echo "$error_json" | jq -r '.related_pattern // ""')
    context_module=$(echo "$error_json" | jq -r '.context.module // ""')

    local relations="[]"

    # Error → Category relation
    relations=$(echo "$relations" | jq -c \
        --arg from "$id" \
        --arg to "CAT-$category" \
        '. + [{from: $from, to: $to, relationType: "belongs_to"}]')

    # Error → Pattern relation (if exists)
    if [[ -n "$related_pattern" ]]; then
        relations=$(echo "$relations" | jq -c \
            --arg from "$id" \
            --arg to "$related_pattern" \
            '. + [{from: $from, to: $to, relationType: "caused_by"}]')

        # Pattern → Error (prevents)
        relations=$(echo "$relations" | jq -c \
            --arg from "$related_pattern" \
            --arg to "$id" \
            '. + [{from: $from, to: $to, relationType: "prevents"}]')
    fi

    # Error → Module relation (if exists)
    if [[ -n "$context_module" ]]; then
        relations=$(echo "$relations" | jq -c \
            --arg from "$id" \
            --arg to "MOD-$context_module" \
            '. + [{from: $from, to: $to, relationType: "occurred_in"}]')
    fi

    echo "$relations"
}

# =============================================================================
# SYNC OPERATIONS
# =============================================================================

# Generate sync commands for all errors (for use by AI agent)
# Outputs commands that can be executed via MCP tools
generate_sync_commands() {
    local journal_path
    journal_path=$(_get_error_journal_path)

    if [[ ! -f "$journal_path" ]]; then
        _mcp_log "ERROR" "Error journal not found: $journal_path"
        return 1
    fi

    local errors
    errors=$(jq -c '.errors[]?' "$journal_path" 2>/dev/null)

    if [[ -z "$errors" ]]; then
        # Output valid empty JSON
        echo '{"action":"sync_to_mcp_memory","entities":[],"relations":[],"summary":{"total_errors":0,"total_categories":0,"total_relations":0}}'
        return 0
    fi

    local all_entities="[]"
    local all_relations="[]"
    local categories=()

    while IFS= read -r error; do
        [[ -z "$error" ]] && continue

        # Convert error to entity
        local entity
        entity=$(error_to_entity "$error")
        all_entities=$(echo "$all_entities" | jq -c --argjson e "$entity" '. + [$e]')

        # Get relations
        local relations
        relations=$(error_to_relations "$error")
        all_relations=$(echo "$all_relations" | jq -c --argjson r "$relations" '. + $r')

        # Track category for entity creation
        local category
        category=$(echo "$error" | jq -r '.category // "general"')
        if [[ ! " ${categories[*]} " =~ " $category " ]]; then
            categories+=("$category")
        fi
    done <<< "$errors"

    # Add category entities
    for cat in "${categories[@]}"; do
        local cat_entity
        cat_entity=$(jq -n -c \
            --arg name "CAT-$cat" \
            --arg entityType "$MCP_ENTITY_CATEGORY" \
            --arg desc "Error category: $cat" \
            '{
                name: $name,
                entityType: $entityType,
                observations: [$desc]
            }')
        all_entities=$(echo "$all_entities" | jq -c --argjson e "$cat_entity" '. + [$e]')
    done

    # Output commands as JSON for AI agent to execute
    echo "{"
    echo "  \"action\": \"sync_to_mcp_memory\","
    echo "  \"entities\": $all_entities,"
    echo "  \"relations\": $all_relations,"
    echo "  \"summary\": {"
    echo "    \"total_errors\": $(echo "$all_entities" | jq '[.[] | select(.entityType == "HarmonyError")] | length'),"
    echo "    \"total_categories\": ${#categories[@]},"
    echo "    \"total_relations\": $(echo "$all_relations" | jq 'length')"
    echo "  }"
    echo "}"
}

# Generate search query for context preloader
# Input: keywords (space-separated)
# Output: JSON with search parameters
generate_search_query() {
    local keywords="$1"

    # Build search query
    jq -n -c \
        --arg query "$MCP_MEMORY_PREFIX $keywords" \
        '{
            action: "search_mcp_memory",
            query: $query,
            note: "Use mcp__memory__search_nodes with this query to find relevant errors"
        }'
}

# =============================================================================
# CONTEXT PRELOADER INTEGRATION
# =============================================================================

# Check if there are errors relevant to current context
# Used by context-preloader.sh to inject warnings
check_relevant_errors() {
    local context_flags="$1"
    local journal_path
    journal_path=$(_get_error_journal_path)

    if [[ ! -f "$journal_path" ]]; then
        echo "[]"
        return 0
    fi

    # Map context flags to error categories
    # This mapping is extensible - add new languages/contexts as needed
    local search_categories=()

    # Scripting languages
    if [[ "$context_flags" =~ is_bash|bash|shell ]]; then
        search_categories+=("bash-scripting")
    fi
    if [[ "$context_flags" =~ is_python|python|django|flask|pip ]]; then
        search_categories+=("python")
    fi
    if [[ "$context_flags" =~ is_php|php|laravel|symfony|composer ]]; then
        search_categories+=("php")
    fi
    if [[ "$context_flags" =~ is_ruby|ruby|rails|gem ]]; then
        search_categories+=("ruby")
    fi

    # Compiled languages
    if [[ "$context_flags" =~ is_go|golang|go[[:space:]] ]]; then
        search_categories+=("golang")
    fi
    if [[ "$context_flags" =~ is_rust|rust|cargo ]]; then
        search_categories+=("rust")
    fi
    if [[ "$context_flags" =~ is_java|java|maven|gradle|spring ]]; then
        search_categories+=("java")
    fi
    if [[ "$context_flags" =~ is_csharp|csharp|dotnet|\.net ]]; then
        search_categories+=("csharp")
    fi

    # Web/Frontend
    if [[ "$context_flags" =~ typescript|ts[[:space:]] ]]; then
        search_categories+=("typescript")
    fi
    if [[ "$context_flags" =~ javascript|js[[:space:]]|node ]]; then
        search_categories+=("javascript")
    fi
    if [[ "$context_flags" =~ react|vue|angular|svelte ]]; then
        search_categories+=("frontend")
    fi
    if [[ "$context_flags" =~ css|scss|tailwind|style ]]; then
        search_categories+=("css")
    fi

    # Package managers / Build
    if [[ "$context_flags" =~ npm|package|publish|yarn|pnpm ]]; then
        search_categories+=("npm-packaging")
    fi
    if [[ "$context_flags" =~ build|compile|webpack|vite|rollup ]]; then
        search_categories+=("build-system")
    fi

    # Infrastructure
    if [[ "$context_flags" =~ docker|container|k8s|kubernetes ]]; then
        search_categories+=("docker")
    fi
    if [[ "$context_flags" =~ ci|cd|github.actions|gitlab|jenkins ]]; then
        search_categories+=("ci-cd")
    fi
    if [[ "$context_flags" =~ database|sql|postgres|mysql|mongo ]]; then
        search_categories+=("database")
    fi

    # Security
    if [[ "$context_flags" =~ auth|security|oauth|jwt ]]; then
        search_categories+=("security")
    fi

    if [[ ${#search_categories[@]} -eq 0 ]]; then
        echo "[]"
        return 0
    fi

    # Search error journal for matching categories
    local matching_errors="[]"
    for cat in "${search_categories[@]}"; do
        local errors
        errors=$(jq -c --arg cat "$cat" '.errors[] | select(.category == $cat)' "$journal_path" 2>/dev/null)
        while IFS= read -r error; do
            [[ -z "$error" ]] && continue
            matching_errors=$(echo "$matching_errors" | jq -c --argjson e "$error" '. + [$e]')
        done <<< "$errors"
    done

    echo "$matching_errors"
}

# Format errors for context injection (human-readable)
format_errors_for_context() {
    local errors_json="$1"

    local count
    count=$(echo "$errors_json" | jq 'length')

    if [[ "$count" -eq 0 ]]; then
        return 0
    fi

    echo ""
    echo "=== SENTINEL WARNINGS: Known Errors Relevant to This Context ==="
    echo ""

    echo "$errors_json" | jq -r '.[] | "⚠️ \(.id) [\(.severity)]: \(.title)\n   Prevention: \(.prevention_rule)\n"'

    echo "=== Use these learnings to avoid repeating past mistakes ==="
    echo ""
}

# =============================================================================
# STATUS AND REPORTING
# =============================================================================

# Show sync status
mcp_sync_status() {
    local journal_path
    journal_path=$(_get_error_journal_path)

    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    MCP MEMORY SYNC STATUS                       ║"
    echo "╠════════════════════════════════════════════════════════════════╣"

    if [[ ! -f "$journal_path" ]]; then
        echo "║  ⚠️  Error journal not found                                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        return 1
    fi

    local total_errors categories
    total_errors=$(jq '.errors | length' "$journal_path" 2>/dev/null || echo "0")
    categories=$(jq -r '.errors[].category' "$journal_path" 2>/dev/null | sort -u | tr '\n' ', ' | sed 's/,$//')

    printf "║  📊 Errors in journal: %-40s ║\n" "$total_errors"
    printf "║  📂 Categories: %-47s ║\n" "${categories:-none}"
    printf "║  🔗 MCP Memory: %-47s ║\n" "${MCP_MEMORY_ENABLED:-false}"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║  To sync to MCP memory, the AI agent should execute:           ║"
    echo "║    1. generate_sync_commands (this module)                     ║"
    echo "║    2. mcp__memory__create_entities (MCP tool)                  ║"
    echo "║    3. mcp__memory__create_relations (MCP tool)                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# =============================================================================
# SELF-TEST
# =============================================================================

mcp_memory_sync_self_test() {
    echo "=== MCP Memory Sync Self-Test ==="
    echo ""

    local passed=0
    local failed=0

    # Test 1: Error to entity conversion
    echo "Test 1: Error to entity conversion..."
    local test_error='{"id":"ERR-TEST","category":"test","severity":"low","title":"Test error","symptom":"Test symptom","root_cause":"Test cause","correct_solution":"Test solution","prevention_rule":"Test prevention","tags":["test","unit"]}'
    local entity
    entity=$(error_to_entity "$test_error")

    if echo "$entity" | jq -e '.name == "ERR-TEST"' > /dev/null 2>&1; then
        echo "  ✅ Entity name correct"
        ((++passed)) || true
    else
        echo "  ❌ Entity name incorrect"
        ((++failed)) || true
    fi

    if echo "$entity" | jq -e '.entityType == "HarmonyError"' > /dev/null 2>&1; then
        echo "  ✅ Entity type correct"
        ((++passed)) || true
    else
        echo "  ❌ Entity type incorrect"
        ((++failed)) || true
    fi

    if echo "$entity" | jq -e '.observations | length > 0' > /dev/null 2>&1; then
        echo "  ✅ Observations populated"
        ((++passed)) || true
    else
        echo "  ❌ Observations empty"
        ((++failed)) || true
    fi

    # Test 2: Relation building
    echo ""
    echo "Test 2: Relation building..."
    local test_error_with_pattern='{"id":"ERR-TEST","category":"bash","related_pattern":"P-011","context":{"module":"install.sh"}}'
    local relations
    relations=$(error_to_relations "$test_error_with_pattern")

    local rel_count
    rel_count=$(echo "$relations" | jq 'length')

    if [[ "$rel_count" -ge 3 ]]; then
        echo "  ✅ Relations count correct: $rel_count"
        ((++passed)) || true
    else
        echo "  ❌ Relations count incorrect: $rel_count (expected >= 3)"
        ((++failed)) || true
    fi

    if echo "$relations" | jq -e '.[] | select(.relationType == "caused_by")' > /dev/null 2>&1; then
        echo "  ✅ caused_by relation present"
        ((++passed)) || true
    else
        echo "  ❌ caused_by relation missing"
        ((++failed)) || true
    fi

    # Test 3: Search query generation
    echo ""
    echo "Test 3: Search query generation..."
    local query
    query=$(generate_search_query "bash set-e arithmetic")

    if echo "$query" | jq -e '.action == "search_mcp_memory"' > /dev/null 2>&1; then
        echo "  ✅ Search query action correct"
        ((++passed)) || true
    else
        echo "  ❌ Search query action incorrect"
        ((++failed)) || true
    fi

    # Test 4: Context checking
    echo ""
    echo "Test 4: Context-based error lookup..."
    local relevant
    relevant=$(check_relevant_errors "is_bash npm")

    # Should return JSON array
    if echo "$relevant" | jq -e 'type == "array"' > /dev/null 2>&1; then
        echo "  ✅ Returns valid JSON array"
        ((++passed)) || true
    else
        echo "  ❌ Does not return valid JSON array"
        ((++failed)) || true
    fi

    echo ""
    echo "=== Results: $passed passed, $failed failed ==="

    if [[ $failed -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Run self-test if called directly with --test
if [[ "${1:-}" == "--test" ]]; then
    mcp_memory_sync_self_test
    exit $?
fi

# Show status if called directly with --status
if [[ "${1:-}" == "--status" ]]; then
    mcp_sync_status
    exit $?
fi

# Generate sync commands if called directly with --sync
if [[ "${1:-}" == "--sync" ]]; then
    generate_sync_commands
    exit $?
fi
