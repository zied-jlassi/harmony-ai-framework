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
LOCAL_CONFIG="${HARMONY_DIR}/local/config/overrides.yaml"
LOCAL_CONFIG_LEGACY="${HARMONY_DIR}/local/config.yaml"  # Backward compat

# Cached merged config
MERGED_CONFIG=""

# Branch cache for specialty resolution (lazy-loaded, O(1) lookup)
# Maps "specialty-branch" → file path (e.g., "ucv-qa" → "specialties/ucv/branchs/qa.md")
# Note: Using declare -g -A for global scope even when sourced from functions
declare -g -A BRANCH_CACHE
BRANCH_CACHE_BUILT=false  # For backward compatibility with full cache

# Track which specialties have been loaded (lazy loading)
declare -g -A SPECIALTY_LOADED

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
declare -g -A DEPRECATED_KEYS=(
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
# BASIC YAML PARSING (fallback when yq not available)
# -----------------------------------------------------------------------------

# Parse simple YAML to JSON (handles nested objects up to 3 levels)
# Limitations: No arrays, no multiline strings
# Usage: json=$(_basic_yaml_to_json "file.yaml")
_basic_yaml_to_json() {
    local yaml_file="$1"
    local result="{"
    local first_l0=true
    local first_l1=true
    local first_l2=true
    local current_l0=""      # Level 0 section (e.g., "sentinel")
    local current_l1=""      # Level 1 subsection (e.g., "circuit_breaker")
    local in_l1_object=false # Are we inside a level 1 nested object?

    # Helper to format a value
    _format_value() {
        local val="$1"
        # Remove quotes
        val="${val#\"}"
        val="${val%\"}"
        val="${val#\'}"
        val="${val%\'}"
        # Detect type
        if [[ "$val" == "true" ]] || [[ "$val" == "false" ]]; then
            echo "$val"
        elif [[ "$val" =~ ^-?[0-9]+$ ]]; then
            echo "$val"
        else
            val="${val//\\/\\\\}"
            val="${val//\"/\\\"}"
            echo "\"$val\""
        fi
    }

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        # Skip array items (not supported)
        [[ "$line" =~ ^[[:space:]]*-[[:space:]] ]] && continue

        # Count leading spaces
        local stripped="${line#"${line%%[![:space:]]*}"}"
        local indent=$(( ${#line} - ${#stripped} ))

        # Level 0: No indentation, section header (key:)
        if [[ $indent -eq 0 ]] && [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*):[[:space:]]*$ ]]; then
            # Close previous structures
            if [[ "$in_l1_object" == "true" ]]; then
                result+="}"
                in_l1_object=false
            fi
            if [[ -n "$current_l0" ]]; then
                result+="},"
            fi
            current_l0="${BASH_REMATCH[1]}"
            current_l1=""
            first_l1=true
            first_l2=true
            [[ "$first_l0" == "true" ]] && first_l0=false
            result+="\"$current_l0\":{"

        # Level 0: Top-level key-value (key: value)
        elif [[ $indent -eq 0 ]] && [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*):[[:space:]]*(.+)$ ]]; then
            # Close previous structures
            if [[ "$in_l1_object" == "true" ]]; then
                result+="}"
                in_l1_object=false
            fi
            if [[ -n "$current_l0" ]]; then
                result+="},"
                current_l0=""
            fi
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            [[ "$first_l0" == "true" ]] && first_l0=false || result+=","
            result+="\"$key\":$(_format_value "$value")"

        # Level 1: 2 spaces, subsection header (  key:)
        elif [[ $indent -eq 2 ]] && [[ "$stripped" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*):[[:space:]]*$ ]]; then
            # Close previous L1 object
            if [[ "$in_l1_object" == "true" ]]; then
                result+="}"
                in_l1_object=false
            fi
            current_l1="${BASH_REMATCH[1]}"
            first_l2=true
            [[ "$first_l1" == "true" ]] && first_l1=false || result+=","
            result+="\"$current_l1\":{"
            in_l1_object=true

        # Level 1: 2 spaces, key-value (  key: value)
        elif [[ $indent -eq 2 ]] && [[ "$stripped" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*):[[:space:]]*(.+)$ ]]; then
            # Close previous L1 object if exists
            if [[ "$in_l1_object" == "true" ]]; then
                result+="}"
                in_l1_object=false
            fi
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            [[ "$first_l1" == "true" ]] && first_l1=false || result+=","
            result+="\"$key\":$(_format_value "$value")"

        # Level 2: 4 spaces, key-value (    key: value)
        elif [[ $indent -eq 4 ]] && [[ "$stripped" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*):[[:space:]]*(.+)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            [[ "$first_l2" == "true" ]] && first_l2=false || result+=","
            result+="\"$key\":$(_format_value "$value")"
        fi
    done < "$yaml_file"

    # Close any open structures
    if [[ "$in_l1_object" == "true" ]]; then
        result+="}"
    fi
    if [[ -n "$current_l0" ]]; then
        result+="}"
    fi

    result+="}"
    echo "$result"
}

# -----------------------------------------------------------------------------
# CONFIG LOADING
# -----------------------------------------------------------------------------

# Load and merge all config files
load_config() {
    # Start with empty object
    MERGED_CONFIG="{}"

    # Check for yq once
    local has_yq=false
    command -v yq &> /dev/null && has_yq=true

    # 1. Load framework defaults
    if [[ -f "$FRAMEWORK_CONFIG" ]]; then
        local framework_content
        framework_content=$(cat "$FRAMEWORK_CONFIG" 2>/dev/null || echo "{}")
        MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$framework_content") 2>/dev/null || echo "$MERGED_CONFIG")
    fi

    # 2. Load override config (YAML → JSON)
    if [[ -f "$OVERRIDE_CONFIG" ]]; then
        local override_content
        if [[ "$has_yq" == "true" ]]; then
            # Try python-yq syntax first (apt install yq), then mikefarah syntax
            override_content=$(cat "$OVERRIDE_CONFIG" | yq '.' 2>/dev/null) || \
            override_content=$(yq -o=json '.' "$OVERRIDE_CONFIG" 2>/dev/null) || \
            override_content="{}"
        else
            # Fallback: basic YAML parsing
            override_content=$(_basic_yaml_to_json "$OVERRIDE_CONFIG" 2>/dev/null || echo "{}")
        fi
        MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$override_content") 2>/dev/null || echo "$MERGED_CONFIG")
        check_deprecated_keys "$override_content"
    fi

    # 3. Load local config (highest priority)
    # Check new path first, then legacy for backward compatibility
    local local_config_file=""
    if [[ -f "$LOCAL_CONFIG" ]]; then
        local_config_file="$LOCAL_CONFIG"
    elif [[ -f "$LOCAL_CONFIG_LEGACY" ]]; then
        local_config_file="$LOCAL_CONFIG_LEGACY"
        echo -e "${C_YELLOW}⚠️  Legacy config path detected: $LOCAL_CONFIG_LEGACY${C_NC}" >&2
        echo -e "${C_YELLOW}   Consider moving to: $LOCAL_CONFIG${C_NC}" >&2
    fi

    if [[ -n "$local_config_file" ]]; then
        local local_content
        if [[ "$has_yq" == "true" ]]; then
            # Try python-yq syntax first (apt install yq), then mikefarah syntax
            local_content=$(cat "$local_config_file" | yq '.' 2>/dev/null) || \
            local_content=$(yq -o=json '.' "$local_config_file" 2>/dev/null) || \
            local_content="{}"
        else
            # Fallback: basic YAML parsing
            local_content=$(_basic_yaml_to_json "$local_config_file" 2>/dev/null || echo "{}")
        fi
        MERGED_CONFIG=$(echo "$MERGED_CONFIG" | jq -s '.[0] * .[1]' - <(echo "$local_content") 2>/dev/null || echo "$MERGED_CONFIG")
    fi

    # Check version
    check_config_version
}

# -----------------------------------------------------------------------------
# BRANCH CACHE (for specialty resolution) - LAZY LOADING
# -----------------------------------------------------------------------------

# Lazy load branches for a single specialty (on-demand)
# Usage: _lazy_load_specialty "ucv"
_lazy_load_specialty() {
    local specialty="$1"

    # Skip if already loaded
    if [[ "${SPECIALTY_LOADED[$specialty]:-}" == "true" ]]; then
        return 0
    fi

    local specialty_dir="${HARMONY_DIR}/specialties/${specialty}"

    if [[ -d "$specialty_dir" ]]; then
        # Scan all branch files in this specialty
        for branch_file in "${specialty_dir}"/branchs/*.md; do
            if [[ -f "$branch_file" ]]; then
                local branch
                branch=$(basename "$branch_file" .md)

                # Add to cache: "specialty-branch" → full path
                BRANCH_CACHE["${specialty}-${branch}"]="$branch_file"
            fi
        done
    fi

    SPECIALTY_LOADED[$specialty]=true
}

# Try to resolve an agent using lazy loading
# Input: agent-name (e.g., "ucv-qa")
# Output: file path if found, empty string otherwise
_lazy_resolve_branch() {
    local agent_name="$1"

    # Check if already in cache
    if [[ -n "${BRANCH_CACHE[$agent_name]:-}" ]]; then
        echo "${BRANCH_CACHE[$agent_name]}"
        return 0
    fi

    # Try to extract specialty from agent name (e.g., "ucv-qa" → "ucv")
    if [[ "$agent_name" == *"-"* ]]; then
        local specialty="${agent_name%%-*}"  # First part before dash

        # Lazy load that specialty
        _lazy_load_specialty "$specialty"

        # Check cache again
        if [[ -n "${BRANCH_CACHE[$agent_name]:-}" ]]; then
            echo "${BRANCH_CACHE[$agent_name]}"
            return 0
        fi
    fi

    # Not found
    echo ""
}

# Build the FULL branch cache by scanning all specialties (backward compatibility)
# DEPRECATED: Prefer lazy loading via _lazy_load_specialty
# Only use when you need to list ALL available branches
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

            # Use lazy load function for consistency
            _lazy_load_specialty "$specialty"
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
# Uses LAZY LOADING - only loads specialty on-demand
# Priority: local > specialty > framework
# Usage: agent_path=$(resolve_agent "developer")
# Usage: agent_path=$(resolve_agent "ucv-qa")  # → specialty branch
resolve_agent() {
    local agent_name="$1"
    local original_name="$agent_name"

    # 1. Check alias FIRST (e.g., "dev" → "developer")
    local alias_value
    alias_value=$(get_config "agents.aliases.$agent_name" "")
    if [[ -n "$alias_value" ]]; then
        agent_name="$alias_value"
    fi

    # 2. Check if disabled
    while IFS= read -r disabled_agent; do
        if [[ "$disabled_agent" == "$agent_name" ]] || [[ "$disabled_agent" == "$original_name" ]]; then
            echo ""
            return
        fi
    done < <(get_config_array "agents.disabled")

    # 3. Check local override FIRST (highest priority)
    local local_agent="${HARMONY_DIR}/local/agents/${agent_name}.md"
    if [[ -f "$local_agent" ]]; then
        echo "$local_agent"
        return
    fi

    # Also check with original name if aliased
    if [[ "$agent_name" != "$original_name" ]]; then
        local_agent="${HARMONY_DIR}/local/agents/${original_name}.md"
        if [[ -f "$local_agent" ]]; then
            echo "$local_agent"
            return
        fi
    fi

    # 4. Try lazy branch resolution (specialty)
    #    e.g., "ucv-qa" → "specialties/ucv/branchs/qa.md"
    local lazy_result
    lazy_result=$(_lazy_resolve_branch "$agent_name")
    if [[ -n "$lazy_result" ]]; then
        echo "$lazy_result"
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

# Resolve agent alias directly
# Usage: real_name=$(resolve_agent_alias "dev")  # → "developer"
resolve_agent_alias() {
    local alias_name="$1"
    get_config "agents.aliases.$alias_name" ""
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
