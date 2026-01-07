#!/bin/bash
# =============================================================================
# Harmony Framework - Configuration Loader
# =============================================================================
#
# Centralized configuration loading with:
#   - Backward compatibility (fallbacks for missing keys)
#   - Version checking
#   - Override merging (framework + project)
#   - Deprecation warnings
#
# Usage in hooks:
#   source "${HARMONY_DIR}/lib/config-loader.sh"
#   load_config
#
#   # Access values with fallbacks
#   docker_required=$(get_config "docker.required" "false")
#   patterns=$(get_config_array "rules_enforcer.add_dangerous_patterns")
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------

# Don't redeclare if already set (avoid readonly conflict)
if [[ -z "${HARMONY_DIR:-}" ]]; then
    readonly HARMONY_DIR=".harmony"
fi

# These are safe to redeclare
FRAMEWORK_VERSION="1.0.0"
MIN_CONFIG_VERSION="1.0.0"

# Config files (order of precedence: last wins)
FRAMEWORK_CONFIG="${HARMONY_DIR}/config/harmony.config.json"
OVERRIDE_CONFIG="${HARMONY_DIR}/config/overrides.yaml"
LOCAL_CONFIG="${HARMONY_DIR}/local/config.yaml"

# Cached merged config
MERGED_CONFIG=""

# Branch cache for specialty resolution (built once, O(1) lookup)
# Maps "specialty-branch" → file path (e.g., "ucv-qa" → "specialties/ucv/branchs/qa.md")
declare -A BRANCH_CACHE
BRANCH_CACHE_BUILT=false

# Colors (avoid readonly to prevent conflicts when sourced multiple times)
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'
C_NC='\033[0m'

# -----------------------------------------------------------------------------
# VERSION UTILITIES
# -----------------------------------------------------------------------------

# Compare semantic versions: returns 0 if v1 >= v2
version_gte() {
    local v1="$1"
    local v2="$2"

    # Split into major.minor.patch
    local v1_major v1_minor v1_patch
    local v2_major v2_minor v2_patch

    IFS='.' read -r v1_major v1_minor v1_patch <<< "$v1"
    IFS='.' read -r v2_major v2_minor v2_patch <<< "$v2"

    # Default to 0 if missing
    v1_major=${v1_major:-0}
    v1_minor=${v1_minor:-0}
    v1_patch=${v1_patch:-0}
    v2_major=${v2_major:-0}
    v2_minor=${v2_minor:-0}
    v2_patch=${v2_patch:-0}

    if (( v1_major > v2_major )); then return 0; fi
    if (( v1_major < v2_major )); then return 1; fi
    if (( v1_minor > v2_minor )); then return 0; fi
    if (( v1_minor < v2_minor )); then return 1; fi
    if (( v1_patch >= v2_patch )); then return 0; fi
    return 1
}

# Check config version compatibility
check_config_version() {
    local config_version
    config_version=$(get_config "version" "1.0.0")

    if ! version_gte "$config_version" "$MIN_CONFIG_VERSION"; then
        echo -e "${C_YELLOW}⚠️  Config version $config_version is older than minimum $MIN_CONFIG_VERSION${C_NC}" >&2
        echo -e "${C_YELLOW}   Run: npx harmony migrate${C_NC}" >&2
    fi
}

# -----------------------------------------------------------------------------
# DEPRECATION WARNINGS
# -----------------------------------------------------------------------------

# Map of deprecated keys to their replacements
declare -A DEPRECATED_KEYS=(
    ["docker_required"]="docker.required"
    ["container_prefix"]="docker.container_prefix"
    ["guardian_mode"]="guardian.mode"
    ["sentinel_enabled"]="sentinel.enabled"
    # Add more as needed
)

check_deprecated_keys() {
    local config_content="$1"

    for old_key in "${!DEPRECATED_KEYS[@]}"; do
        if echo "$config_content" | grep -q "\"$old_key\"" 2>/dev/null; then
            local new_key="${DEPRECATED_KEYS[$old_key]}"
            echo -e "${C_YELLOW}⚠️  Deprecated: '$old_key' → use '$new_key' instead${C_NC}" >&2
        fi
    done
}

# -----------------------------------------------------------------------------
# CONFIG LOADING
# -----------------------------------------------------------------------------

# Load and merge all config files
load_config() {
    # Start with empty object
    MERGED_CONFIG="{}"

    # 1. Load framework defaults
    if [[ -f "$FRAMEWORK_CONFIG" ]]; then
        local framework_content
        framework_content=$(cat "$FRAMEWORK_CONFIG" 2>/dev/null || echo "{}")
        MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$framework_content") 2>/dev/null || echo "$MERGED_CONFIG")
    fi

    # 2. Load override config (YAML → JSON)
    if [[ -f "$OVERRIDE_CONFIG" ]]; then
        local override_content
        if command -v yq &> /dev/null; then
            override_content=$(yq -o=json "$OVERRIDE_CONFIG" 2>/dev/null || echo "{}")
        else
            # Fallback: basic YAML parsing (limited)
            override_content="{}"
        fi
        MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$override_content") 2>/dev/null || echo "$MERGED_CONFIG")
        check_deprecated_keys "$override_content"
    fi

    # 3. Load local config (highest priority)
    if [[ -f "$LOCAL_CONFIG" ]]; then
        local local_content
        if command -v yq &> /dev/null; then
            local_content=$(yq -o=json "$LOCAL_CONFIG" 2>/dev/null || echo "{}")
        else
            local_content="{}"
        fi
        MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$local_content") 2>/dev/null || echo "$MERGED_CONFIG")
    fi

    # Check version
    check_config_version
}

# -----------------------------------------------------------------------------
# BRANCH CACHE (for specialty resolution)
# -----------------------------------------------------------------------------

# Build the branch cache by scanning all specialties
# Called once at initialization, provides O(1) lookup for resolve_agent
# Usage: build_branch_cache
build_branch_cache() {
    # Skip if already built
    if [[ "$BRANCH_CACHE_BUILT" == "true" ]]; then
        return 0
    fi

    # Scan all specialty manifests
    for specialty_dir in "${HARMONY_DIR}"/specialties/*/; do
        if [[ -d "$specialty_dir" ]]; then
            local specialty
            specialty=$(basename "$specialty_dir")

            # Scan all branch files in this specialty
            for branch_file in "${specialty_dir}"branchs/*.md; do
                if [[ -f "$branch_file" ]]; then
                    local branch
                    branch=$(basename "$branch_file" .md)

                    # Add to cache: "specialty-branch" → full path
                    BRANCH_CACHE["${specialty}-${branch}"]="$branch_file"
                fi
            done
        fi
    done

    BRANCH_CACHE_BUILT=true
}

# Get branch cache entry count (for debugging)
# Usage: count=$(get_branch_cache_count)
get_branch_cache_count() {
    if [[ -v BRANCH_CACHE ]]; then
        echo "${#BRANCH_CACHE[@]}"
    else
        echo "0"
    fi
}

# List all cached branches (for debugging)
# Usage: list_branch_cache
list_branch_cache() {
    for key in "${!BRANCH_CACHE[@]}"; do
        echo "$key → ${BRANCH_CACHE[$key]}"
    done | sort
}

# -----------------------------------------------------------------------------
# CONFIG ACCESS (with fallbacks)
# -----------------------------------------------------------------------------

# Get a config value with fallback
# Usage: get_config "docker.required" "false"
get_config() {
    local key="$1"
    local default="${2:-}"

    if [[ -z "$MERGED_CONFIG" ]]; then
        load_config
    fi

    local value
    value=$(echo "$MERGED_CONFIG" | jq -r ".$key // empty" 2>/dev/null || echo "")

    if [[ -z "$value" ]] || [[ "$value" == "null" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Get a config array as newline-separated values
# Usage: get_config_array "rules_enforcer.add_dangerous_patterns"
get_config_array() {
    local key="$1"

    if [[ -z "$MERGED_CONFIG" ]]; then
        load_config
    fi

    echo "$MERGED_CONFIG" | jq -r ".$key // [] | .[]" 2>/dev/null || echo ""
}

# Check if a config key exists
# Usage: if has_config "docker.required"; then ...
has_config() {
    local key="$1"

    if [[ -z "$MERGED_CONFIG" ]]; then
        load_config
    fi

    local value
    value=$(echo "$MERGED_CONFIG" | jq -r ".$key // \"__NOT_FOUND__\"" 2>/dev/null || echo "__NOT_FOUND__")

    [[ "$value" != "__NOT_FOUND__" ]] && [[ "$value" != "null" ]]
}

# Get boolean config with fallback
# Usage: if get_config_bool "docker.required" false; then ...
get_config_bool() {
    local key="$1"
    local default="${2:-false}"

    local value
    value=$(get_config "$key" "$default")

    [[ "$value" == "true" ]] || [[ "$value" == "1" ]] || [[ "$value" == "yes" ]]
}

# -----------------------------------------------------------------------------
# PATTERN MERGING
# -----------------------------------------------------------------------------

# Merge framework patterns with project overrides
# Usage: merged_patterns=$(merge_patterns "DANGEROUS_PATTERNS" "rules_enforcer.add_dangerous_patterns" "rules_enforcer.disable_patterns")
merge_patterns() {
    local array_name="$1"
    local add_key="$2"
    local disable_key="$3"

    # Get framework patterns (from calling script's array)
    local -n framework_array="$array_name"
    local patterns=("${framework_array[@]}")

    # Add project patterns
    while IFS= read -r pattern; do
        if [[ -n "$pattern" ]]; then
            patterns+=("$pattern")
        fi
    done < <(get_config_array "$add_key")

    # Remove disabled patterns
    local disabled_patterns=()
    while IFS= read -r pattern; do
        if [[ -n "$pattern" ]]; then
            disabled_patterns+=("$pattern")
        fi
    done < <(get_config_array "$disable_key")

    # Filter out disabled
    local final_patterns=()
    for pattern in "${patterns[@]}"; do
        local is_disabled=false
        for disabled in "${disabled_patterns[@]}"; do
            if [[ "$pattern" == "$disabled" ]]; then
                is_disabled=true
                break
            fi
        done
        if ! $is_disabled; then
            final_patterns+=("$pattern")
        fi
    done

    # Return as newline-separated
    printf '%s\n' "${final_patterns[@]}"
}

# -----------------------------------------------------------------------------
# HOOK RESOLUTION
# -----------------------------------------------------------------------------

# Check if a local override exists for a hook
# Usage: hook_path=$(resolve_hook "rules-enforcer")
resolve_hook() {
    local hook_name="$1"

    local local_hook="${HARMONY_DIR}/local/hooks/${hook_name}.sh"
    local framework_hook="${HARMONY_DIR}/hooks/${hook_name}.sh"

    if [[ -f "$local_hook" ]]; then
        echo "$local_hook"
    elif [[ -f "$framework_hook" ]]; then
        echo "$framework_hook"
    else
        echo ""
    fi
}

# Check if a hook is disabled
# Usage: if is_hook_disabled "guardian-checkpoint"; then skip
is_hook_disabled() {
    local hook_name="$1"

    local disabled
    while IFS= read -r disabled_hook; do
        if [[ "$disabled_hook" == "$hook_name" ]]; then
            return 0
        fi
    done < <(get_config_array "hooks.disabled_hooks")

    return 1
}

# -----------------------------------------------------------------------------
# AGENT RESOLUTION
# -----------------------------------------------------------------------------

# Resolve agent with aliases, branch cache, and overrides
# Supports specialty-branch pattern (e.g., "ucv-qa" → specialties/ucv/branchs/qa.md)
# Usage: agent_path=$(resolve_agent "developer")
# Usage: agent_path=$(resolve_agent "ucv-qa")  # → specialty branch
resolve_agent() {
    local agent_name="$1"

    # Ensure branch cache is built
    if [[ "$BRANCH_CACHE_BUILT" != "true" ]]; then
        build_branch_cache
    fi

    # 1. Check branch cache first (O(1) lookup for specialty-branch patterns)
    #    e.g., "ucv-qa" → "specialties/ucv/branchs/qa.md"
    if [[ -n "${BRANCH_CACHE[$agent_name]:-}" ]]; then
        echo "${BRANCH_CACHE[$agent_name]}"
        return
    fi

    # 2. Check alias (e.g., "dev" → "developer")
    local alias_value
    alias_value=$(get_config "agents.aliases.$agent_name" "")
    if [[ -n "$alias_value" ]]; then
        agent_name="$alias_value"

        # Re-check branch cache with aliased name
        if [[ -n "${BRANCH_CACHE[$agent_name]:-}" ]]; then
            echo "${BRANCH_CACHE[$agent_name]}"
            return
        fi
    fi

    # 3. Check if disabled
    while IFS= read -r disabled_agent; do
        if [[ "$disabled_agent" == "$agent_name" ]]; then
            echo ""
            return
        fi
    done < <(get_config_array "agents.disabled")

    # 4. Check local override (flat structure)
    local local_agent="${HARMONY_DIR}/local/agents/${agent_name}.md"
    if [[ -f "$local_agent" ]]; then
        echo "$local_agent"
        return
    fi

    # 5. Check framework agent
    local framework_agent="${HARMONY_DIR}/agents/${agent_name}.md"
    if [[ -f "$framework_agent" ]]; then
        echo "$framework_agent"
        return
    fi

    # 6. Fallback: specialty with same-name branch (e.g., "devops" → "devops/branchs/devops.md")
    local same_name_branch="${HARMONY_DIR}/specialties/${agent_name}/branchs/${agent_name}.md"
    if [[ -f "$same_name_branch" ]]; then
        echo "$same_name_branch"
        return
    fi

    # 7. Check cognitive pattern
    local cognitive_pattern="${HARMONY_DIR}/patterns/cognitive/${agent_name}.md"
    if [[ -f "$cognitive_pattern" ]]; then
        echo "$cognitive_pattern"
        return
    fi

    # Not found
    echo ""
}

# -----------------------------------------------------------------------------
# TEMPLATE RESOLUTION
# -----------------------------------------------------------------------------

# Resolve template with overrides
# Usage: template_path=$(resolve_template "story")
resolve_template() {
    local template_name="$1"

    # Check config override
    local config_path
    config_path=$(get_config "templates.paths.$template_name" "")
    if [[ -n "$config_path" ]] && [[ -f "$config_path" ]]; then
        echo "$config_path"
        return
    fi

    # Check local override
    local local_template="${HARMONY_DIR}/local/templates/${template_name}.md"
    local framework_template="${HARMONY_DIR}/templates/${template_name}.md"

    if [[ -f "$local_template" ]]; then
        echo "$local_template"
    elif [[ -f "$framework_template" ]]; then
        echo "$framework_template"
    else
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# INITIALIZATION
# -----------------------------------------------------------------------------

# Auto-load config when sourced (can be disabled)
if [[ "${HARMONY_NO_AUTOLOAD:-0}" != "1" ]]; then
    load_config 2>/dev/null || true
fi
