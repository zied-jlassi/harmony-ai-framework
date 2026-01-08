#!/usr/bin/env bash
# ============================================================================
# model-manager.sh - Model Resolution for Harmony Framework
# ============================================================================
# Simple architecture:
#   1. Models have aliases (opus, sonnet, haiku, chatgpt, etc.)
#   2. model_keys map constants to aliases (model_1 -> opus)
#   3. Agents use model_keys or aliases directly
#
# Usage: source model-manager.sh
#
# Functions:
#   - resolve_model_key   : model_1 -> opus -> claude-opus-4-20250514
#   - get_model_by_alias  : opus -> {name, provider, api_base, ...}
#   - list_models         : Show all available models
#   - list_model_keys     : Show model_keys mapping
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIG LOADING
# ============================================================================

declare -g _LLM_CONFIG_CACHE=""
declare -g _LLM_CONFIG_PATH=""

# Load llm-defaults.yaml configuration
load_llm_config() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_path="${script_dir}/../config/llm-defaults.yaml"

    # Check for user override
    local user_config="${HARMONY_DIR:-.harmony}/local/llm-config.yaml"
    if [[ -f "$user_config" ]]; then
        config_path="$user_config"
    fi

    # Return cached if same file
    if [[ "$_LLM_CONFIG_PATH" == "$config_path" ]] && [[ -n "$_LLM_CONFIG_CACHE" ]]; then
        echo "$_LLM_CONFIG_CACHE"
        return 0
    fi

    if [[ ! -f "$config_path" ]]; then
        echo "{}"
        return 1
    fi

    # Convert YAML to JSON
    if command -v yq &>/dev/null; then
        _LLM_CONFIG_CACHE=$(yq eval -o=json "$config_path" 2>/dev/null || echo "{}")
    elif command -v python3 &>/dev/null; then
        _LLM_CONFIG_CACHE=$(python3 -c "
import yaml, json
try:
    with open('$config_path', 'r') as f:
        data = yaml.safe_load(f)
    print(json.dumps(data or {}))
except:
    print('{}')
" 2>/dev/null || echo "{}")
    else
        echo "{}"
        return 1
    fi

    _LLM_CONFIG_PATH="$config_path"
    echo "$_LLM_CONFIG_CACHE"
}

# ============================================================================
# MODEL RESOLUTION
# ============================================================================

# Get model info by alias
# Usage: get_model_by_alias "opus" -> JSON with name, provider, etc.
get_model_by_alias() {
    local alias="$1"
    local config
    config=$(load_llm_config)

    # Search in models array
    local model_info
    model_info=$(echo "$config" | jq -r ".models[] | select(.alias == \"$alias\")" 2>/dev/null)

    if [[ -n "$model_info" ]] && [[ "$model_info" != "null" ]]; then
        echo "$model_info"
        return 0
    fi

    # Fallback for built-in Claude models
    case "$alias" in
        opus)
            echo '{"name":"claude-opus-4-20250514","alias":"opus","description":"Most powerful"}'
            ;;
        sonnet)
            echo '{"name":"claude-sonnet-4-20250514","alias":"sonnet","description":"Balanced"}'
            ;;
        haiku)
            echo '{"name":"claude-3-haiku-20240307","alias":"haiku","description":"Fast"}'
            ;;
        *)
            echo "{}"
            return 1
            ;;
    esac
}

# Resolve model_key to alias (supports arrays for fallback)
# Usage: resolve_model_key_to_alias "model_1" -> "opus"
#        resolve_model_key_to_alias "model_1" 1 -> "chatgpt" (second in fallback list)
#        resolve_model_key_to_alias "inherit" -> "sonnet" (via model_2)
resolve_model_key_to_alias() {
    local key="$1"
    local index="${2:-0}"  # Index in fallback array (0 = first/primary)
    local depth="${3:-0}"  # Prevent infinite recursion

    # Max recursion depth
    if [[ "$depth" -gt 3 ]]; then
        echo "sonnet"
        return 0
    fi

    local config
    config=$(load_llm_config)

    local value
    value=$(echo "$config" | jq -r ".model_keys.${key}" 2>/dev/null)

    if [[ -n "$value" ]] && [[ "$value" != "null" ]]; then
        # Check if it's an array
        local is_array
        is_array=$(echo "$config" | jq -r ".model_keys.${key} | if type == \"array\" then \"yes\" else \"no\" end" 2>/dev/null)

        if [[ "$is_array" == "yes" ]]; then
            # Get element at index
            local alias
            alias=$(echo "$config" | jq -r ".model_keys.${key}[$index] // \"\"" 2>/dev/null)
            if [[ -n "$alias" ]] && [[ "$alias" != "null" ]]; then
                echo "$alias"
                return 0
            fi
            # If index out of bounds, return last element
            alias=$(echo "$config" | jq -r ".model_keys.${key}[-1]" 2>/dev/null)
            echo "$alias"
            return 0
        fi

        # If value is another model_key (e.g., inherit -> model_2), resolve it
        if [[ "$value" =~ ^model_[0-9]+$ ]]; then
            resolve_model_key_to_alias "$value" "$index" $((depth + 1))
        else
            echo "$value"
        fi
        return 0
    fi

    # Fallback defaults
    case "$key" in
        model_1) echo "opus" ;;
        model_2) echo "sonnet" ;;
        model_3) echo "haiku" ;;
        inherit) echo "sonnet" ;;
        *)       echo "$key" ;;  # Assume it's already an alias
    esac
}

# Get all fallback aliases for a model_key
# Usage: get_model_fallbacks "model_1" -> ["opus", "chatgpt"]
get_model_fallbacks() {
    local key="$1"

    local config
    config=$(load_llm_config)

    local value
    value=$(echo "$config" | jq -r ".model_keys.${key}" 2>/dev/null)

    if [[ -n "$value" ]] && [[ "$value" != "null" ]]; then
        # Check if it's an array
        local is_array
        is_array=$(echo "$config" | jq -r ".model_keys.${key} | if type == \"array\" then \"yes\" else \"no\" end" 2>/dev/null)

        if [[ "$is_array" == "yes" ]]; then
            echo "$config" | jq -c ".model_keys.${key}"
            return 0
        fi

        # Single value - return as single-element array
        echo "[\"$value\"]"
        return 0
    fi

    # Fallback defaults
    case "$key" in
        model_1) echo '["opus"]' ;;
        model_2) echo '["sonnet"]' ;;
        model_3) echo '["haiku"]' ;;
        *)       echo "[\"$key\"]" ;;
    esac
}

# Get next fallback model (for token limit errors)
# Usage: get_next_fallback "model_1" "opus" -> "chatgpt"
get_next_fallback() {
    local key="$1"
    local current_alias="$2"

    local fallbacks
    fallbacks=$(get_model_fallbacks "$key")

    # Find current index and return next
    local next_alias
    next_alias=$(echo "$fallbacks" | jq -r --arg current "$current_alias" '
        to_entries |
        map(select(.value == $current)) |
        .[0].key as $idx |
        if $idx != null then .[$idx + 1].value // null else null end
    ' 2>/dev/null)

    if [[ -n "$next_alias" ]] && [[ "$next_alias" != "null" ]]; then
        echo "$next_alias"
    else
        echo ""  # No more fallbacks
    fi
}

# Full resolution: model_key or alias -> model name
# Usage: resolve_model "model_1" -> "claude-opus-4-20250514"
#        resolve_model "opus" -> "claude-opus-4-20250514"
#        resolve_model "chatgpt" -> "gpt-4o"
resolve_model() {
    local input="$1"

    # If it's a model_key (model_1, model_2, etc.), resolve to alias first
    local alias
    if [[ "$input" =~ ^model_[0-9]+$ ]] || [[ "$input" == "inherit" ]]; then
        alias=$(resolve_model_key_to_alias "$input")
    else
        alias="$input"
    fi

    # Get model info by alias
    local model_info
    model_info=$(get_model_by_alias "$alias")

    # Extract model name
    local model_name
    model_name=$(echo "$model_info" | jq -r '.name // ""' 2>/dev/null)

    if [[ -n "$model_name" ]] && [[ "$model_name" != "null" ]]; then
        echo "$model_name"
    else
        echo "$alias"  # Return alias as-is if not found
    fi
}

# Get full model config for API calls
# Usage: get_model_config "model_1" -> JSON with name, provider, api_base, api_key_env
get_model_config() {
    local input="$1"

    # Resolve to alias
    local alias
    if [[ "$input" =~ ^model_[0-9]+$ ]] || [[ "$input" == "inherit" ]]; then
        alias=$(resolve_model_key_to_alias "$input")
    else
        alias="$input"
    fi

    # Get full model info
    get_model_by_alias "$alias"
}

# ============================================================================
# LISTING FUNCTIONS
# ============================================================================

# List all available models
list_models() {
    local config
    config=$(load_llm_config)

    echo "=== Available Models ==="
    echo ""
    printf "%-15s %-35s %s\n" "ALIAS" "MODEL NAME" "DESCRIPTION"
    printf "%-15s %-35s %s\n" "-----" "----------" "-----------"

    # List from config
    echo "$config" | jq -r '.models[]? | "\(.alias)\t\(.name)\t\(.description // "")"' 2>/dev/null | \
    while IFS=$'\t' read -r alias name desc; do
        printf "%-15s %-35s %s\n" "$alias" "$name" "$desc"
    done

    # If no models in config, show defaults
    if ! echo "$config" | jq -e '.models[0]' &>/dev/null; then
        printf "%-15s %-35s %s\n" "opus" "claude-opus-4-20250514" "Most powerful"
        printf "%-15s %-35s %s\n" "sonnet" "claude-sonnet-4-20250514" "Balanced"
        printf "%-15s %-35s %s\n" "haiku" "claude-3-haiku-20240307" "Fast"
    fi
}

# List model_keys mapping
list_model_keys() {
    local config
    config=$(load_llm_config)

    echo "=== Model Keys ==="
    echo ""
    printf "%-10s %-25s %-35s\n" "KEY" "ALIASES (fallback order)" "PRIMARY MODEL"
    printf "%-10s %-25s %-35s\n" "---" "------------------------" "-------------"

    for key in model_1 model_2 model_3; do
        local fallbacks primary model
        fallbacks=$(get_model_fallbacks "$key")
        primary=$(resolve_model_key_to_alias "$key")
        model=$(resolve_model "$key")

        # Format fallbacks for display
        local fallback_str
        fallback_str=$(echo "$fallbacks" | jq -r 'join(" → ")' 2>/dev/null || echo "$primary")

        printf "%-10s %-25s %-35s\n" "$key" "$fallback_str" "$model"
    done
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f load_llm_config get_model_by_alias resolve_model_key_to_alias
export -f resolve_model get_model_config list_models list_model_keys
export -f get_model_fallbacks get_next_fallback

# ============================================================================
# CLI MODE
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        resolve)
            # Usage: ./model-manager.sh resolve model_1
            resolve_model "${2:-model_2}"
            ;;
        config)
            # Usage: ./model-manager.sh config model_1
            get_model_config "${2:-model_2}"
            ;;
        alias)
            # Usage: ./model-manager.sh alias model_1
            resolve_model_key_to_alias "${2:-model_1}"
            ;;
        models|list)
            list_models
            ;;
        keys)
            list_model_keys
            ;;
        help|--help|-h)
            echo "Usage: model-manager.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  resolve <key|alias>   Resolve to model name"
            echo "  config <key|alias>    Get full model config (JSON)"
            echo "  alias <model_key>     Get alias for model_key"
            echo "  models                List all available models"
            echo "  keys                  List model_keys mapping"
            echo ""
            echo "Examples:"
            echo "  ./model-manager.sh resolve model_1"
            echo "    -> claude-opus-4-20250514"
            echo ""
            echo "  ./model-manager.sh resolve opus"
            echo "    -> claude-opus-4-20250514"
            echo ""
            echo "  ./model-manager.sh keys"
            echo "    -> model_1 = opus = claude-opus-4-20250514"
            echo "    -> model_2 = sonnet = claude-sonnet-4-20250514"
            echo "    -> model_3 = haiku = claude-3-haiku-20240307"
            ;;
        *)
            list_model_keys
            echo ""
            list_models
            ;;
    esac
fi
