#!/usr/bin/env bash
# ============================================================================
# model-manager.sh - Model Aliases and Resolution for Harmony Framework
# ============================================================================
# Inspired by Aider's multi-model support system
# Provides model aliasing, tier resolution, and cost-aware routing
#
# Usage: source model-manager.sh
#
# Functions:
#   - resolve_model          : Convert alias to full model name
#   - get_model_tier         : Get model tier (main, weak, editor)
#   - get_model_for_task     : Get appropriate model for task type
#   - estimate_model_cost    : Estimate cost for token count
#   - list_models            : List available models and aliases
# ============================================================================

set -euo pipefail

# ============================================================================
# MODEL ALIASES - Convenience names for common models
# ============================================================================
declare -A MODEL_ALIASES=(
    # Anthropic
    ["opus"]="anthropic/claude-opus-4"
    ["opus4"]="anthropic/claude-opus-4"
    ["opus-4.5"]="anthropic/claude-opus-4-5-20251101"
    ["sonnet"]="anthropic/claude-sonnet-4"
    ["sonnet4"]="anthropic/claude-sonnet-4"
    ["haiku"]="anthropic/claude-3-5-haiku"
    ["haiku3.5"]="anthropic/claude-3-5-haiku"

    # OpenAI
    ["gpt4"]="openai/gpt-4"
    ["gpt4o"]="openai/gpt-4o"
    ["gpt4-turbo"]="openai/gpt-4-turbo"
    ["o1"]="openai/o1"
    ["o1-mini"]="openai/o1-mini"
    ["o3-mini"]="openai/o3-mini"

    # DeepSeek
    ["deepseek"]="deepseek/deepseek-chat"
    ["deepseek-coder"]="deepseek/deepseek-coder"
    ["deepseek-r1"]="deepseek/deepseek-reasoner"

    # Google
    ["gemini"]="google/gemini-pro"
    ["gemini-pro"]="google/gemini-pro"
    ["gemini-ultra"]="google/gemini-ultra"

    # Meta/Ollama (local)
    ["llama"]="ollama/llama3.1"
    ["llama3"]="ollama/llama3.1"
    ["codellama"]="ollama/codellama"
    ["mistral"]="ollama/mistral"
)

# ============================================================================
# MODEL TIERS - Cost and capability classification
# ============================================================================
# Tier 1: Main model (expensive, most capable)
# Tier 2: Weak model (cheap, for summarization/simple tasks)
# Tier 3: Editor model (specialized for code editing)
declare -A MODEL_TIERS=(
    # Anthropic
    ["anthropic/claude-opus-4"]="main"
    ["anthropic/claude-opus-4-5-20251101"]="main"
    ["anthropic/claude-sonnet-4"]="editor"
    ["anthropic/claude-3-5-haiku"]="weak"

    # OpenAI
    ["openai/gpt-4"]="main"
    ["openai/gpt-4o"]="editor"
    ["openai/gpt-4-turbo"]="main"
    ["openai/o1"]="main"
    ["openai/o1-mini"]="editor"
    ["openai/o3-mini"]="editor"

    # DeepSeek
    ["deepseek/deepseek-chat"]="weak"
    ["deepseek/deepseek-coder"]="editor"
    ["deepseek/deepseek-reasoner"]="main"

    # Local/Ollama (all weak by default)
    ["ollama/llama3.1"]="weak"
    ["ollama/codellama"]="editor"
    ["ollama/mistral"]="weak"
)

# ============================================================================
# MODEL PRICING - Cost per 1K tokens (input/output)
# ============================================================================
declare -A MODEL_COST_INPUT=(
    ["anthropic/claude-opus-4"]="0.015"
    ["anthropic/claude-opus-4-5-20251101"]="0.015"
    ["anthropic/claude-sonnet-4"]="0.003"
    ["anthropic/claude-3-5-haiku"]="0.00025"
    ["openai/gpt-4"]="0.03"
    ["openai/gpt-4o"]="0.0025"
    ["openai/gpt-4-turbo"]="0.01"
    ["openai/o1"]="0.015"
    ["openai/o1-mini"]="0.003"
    ["deepseek/deepseek-chat"]="0.00014"
    ["deepseek/deepseek-coder"]="0.00014"
    ["deepseek/deepseek-reasoner"]="0.00055"
    ["ollama/llama3.1"]="0"
    ["ollama/codellama"]="0"
    ["ollama/mistral"]="0"
)

declare -A MODEL_COST_OUTPUT=(
    ["anthropic/claude-opus-4"]="0.075"
    ["anthropic/claude-opus-4-5-20251101"]="0.075"
    ["anthropic/claude-sonnet-4"]="0.015"
    ["anthropic/claude-3-5-haiku"]="0.00125"
    ["openai/gpt-4"]="0.06"
    ["openai/gpt-4o"]="0.01"
    ["openai/gpt-4-turbo"]="0.03"
    ["openai/o1"]="0.06"
    ["openai/o1-mini"]="0.012"
    ["deepseek/deepseek-chat"]="0.00028"
    ["deepseek/deepseek-coder"]="0.00028"
    ["deepseek/deepseek-reasoner"]="0.0022"
    ["ollama/llama3.1"]="0"
    ["ollama/codellama"]="0"
    ["ollama/mistral"]="0"
)

# ============================================================================
# ENVIRONMENT VARIABLES - Override defaults
# ============================================================================
HARMONY_MAIN_MODEL="${HARMONY_MAIN_MODEL:-${AIDER_MODEL:-anthropic/claude-sonnet-4}}"
HARMONY_WEAK_MODEL="${HARMONY_WEAK_MODEL:-${AIDER_WEAK_MODEL:-anthropic/claude-3-5-haiku}}"
HARMONY_EDITOR_MODEL="${HARMONY_EDITOR_MODEL:-${AIDER_EDITOR_MODEL:-anthropic/claude-sonnet-4}}"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Resolve model alias to full name
# Usage: resolve_model "sonnet" -> "anthropic/claude-sonnet-4"
resolve_model() {
    local alias="$1"

    # Check if it's an alias
    if [[ -n "${MODEL_ALIASES[$alias]:-}" ]]; then
        echo "${MODEL_ALIASES[$alias]}"
    else
        # Return as-is (assume it's already a full model name)
        echo "$alias"
    fi
}

# Get model tier (main, weak, editor)
# Usage: get_model_tier "anthropic/claude-sonnet-4" -> "editor"
get_model_tier() {
    local model="$1"
    local resolved
    resolved=$(resolve_model "$model")

    echo "${MODEL_TIERS[$resolved]:-unknown}"
}

# Get the appropriate model for a task type
# Usage: get_model_for_task "summarize" -> weak model
#        get_model_for_task "architect" -> main model
#        get_model_for_task "edit" -> editor model
get_model_for_task() {
    local task_type="$1"

    case "$task_type" in
        # Main model tasks (complex reasoning)
        architect|design|plan|review|analyze|debug-complex)
            echo "$HARMONY_MAIN_MODEL"
            ;;

        # Weak model tasks (simple, cost-sensitive)
        summarize|translate|format|lint-explain|simple-fix)
            echo "$HARMONY_WEAK_MODEL"
            ;;

        # Editor model tasks (code editing)
        edit|implement|refactor|test|fix|code)
            echo "$HARMONY_EDITOR_MODEL"
            ;;

        # Default to editor model
        *)
            echo "$HARMONY_EDITOR_MODEL"
            ;;
    esac
}

# Estimate cost for a given model and token count
# Usage: estimate_model_cost "sonnet" 1000 500 -> cost in USD
estimate_model_cost() {
    local model="$1"
    local input_tokens="${2:-0}"
    local output_tokens="${3:-0}"

    local resolved
    resolved=$(resolve_model "$model")

    local input_cost="${MODEL_COST_INPUT[$resolved]:-0}"
    local output_cost="${MODEL_COST_OUTPUT[$resolved]:-0}"

    # Calculate cost (tokens / 1000 * cost_per_1k)
    local total_cost
    total_cost=$(echo "scale=6; ($input_tokens / 1000 * $input_cost) + ($output_tokens / 1000 * $output_cost)" | bc 2>/dev/null || echo "0")

    echo "$total_cost"
}

# List all available models
# Usage: list_models [--aliases] [--tiers] [--costs]
list_models() {
    local show_aliases=false
    local show_tiers=false
    local show_costs=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --aliases) show_aliases=true ;;
            --tiers) show_tiers=true ;;
            --costs) show_costs=true ;;
            --all) show_aliases=true; show_tiers=true; show_costs=true ;;
            *) ;;
        esac
        shift
    done

    echo "=== Harmony Model Manager ==="
    echo ""

    if [[ "$show_aliases" == true ]]; then
        echo "Model Aliases:"
        for alias in "${!MODEL_ALIASES[@]}"; do
            printf "  %-15s -> %s\n" "$alias" "${MODEL_ALIASES[$alias]}"
        done | sort
        echo ""
    fi

    if [[ "$show_tiers" == true ]]; then
        echo "Model Tiers:"
        echo "  Main:   $HARMONY_MAIN_MODEL"
        echo "  Weak:   $HARMONY_WEAK_MODEL"
        echo "  Editor: $HARMONY_EDITOR_MODEL"
        echo ""
    fi

    if [[ "$show_costs" == true ]]; then
        echo "Model Costs (per 1K tokens):"
        printf "  %-40s %10s %10s\n" "Model" "Input" "Output"
        printf "  %-40s %10s %10s\n" "-----" "-----" "------"
        for model in "${!MODEL_COST_INPUT[@]}"; do
            printf "  %-40s \$%8s \$%8s\n" "$model" "${MODEL_COST_INPUT[$model]}" "${MODEL_COST_OUTPUT[$model]}"
        done | sort
        echo ""
    fi

    if [[ "$show_aliases" == false && "$show_tiers" == false && "$show_costs" == false ]]; then
        echo "Current Configuration:"
        echo "  Main Model:   $HARMONY_MAIN_MODEL"
        echo "  Weak Model:   $HARMONY_WEAK_MODEL"
        echo "  Editor Model: $HARMONY_EDITOR_MODEL"
        echo ""
        echo "Use --aliases, --tiers, --costs, or --all for more details"
    fi
}

# Set model for a tier
# Usage: set_model "main" "opus"
set_model() {
    local tier="$1"
    local model="$2"

    local resolved
    resolved=$(resolve_model "$model")

    case "$tier" in
        main)
            export HARMONY_MAIN_MODEL="$resolved"
            ;;
        weak)
            export HARMONY_WEAK_MODEL="$resolved"
            ;;
        editor)
            export HARMONY_EDITOR_MODEL="$resolved"
            ;;
        *)
            echo "Unknown tier: $tier (use main, weak, or editor)" >&2
            return 1
            ;;
    esac

    echo "Set $tier model to: $resolved"
}

# Check if a model is available (basic connectivity check)
# Usage: check_model_available "sonnet" -> 0 if available, 1 if not
check_model_available() {
    local model="$1"
    local resolved
    resolved=$(resolve_model "$model")

    # Check if model is in our known list
    if [[ -n "${MODEL_TIERS[$resolved]:-}" ]]; then
        return 0
    else
        return 1
    fi
}

# Get recommended model based on context window size
# Usage: get_model_for_context 50000 -> suggests appropriate model
get_model_for_context() {
    local context_size="$1"

    # Models sorted by context window (approximate)
    if [[ "$context_size" -gt 128000 ]]; then
        echo "anthropic/claude-sonnet-4"  # 200K context
    elif [[ "$context_size" -gt 32000 ]]; then
        echo "openai/gpt-4-turbo"  # 128K context
    else
        echo "$HARMONY_EDITOR_MODEL"
    fi
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f resolve_model get_model_tier get_model_for_task estimate_model_cost
export -f list_models set_model check_model_available get_model_for_context

# ============================================================================
# CLI MODE - Run directly for testing
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        resolve)
            resolve_model "${2:-sonnet}"
            ;;
        tier)
            get_model_tier "${2:-sonnet}"
            ;;
        task)
            get_model_for_task "${2:-edit}"
            ;;
        cost)
            estimate_model_cost "${2:-sonnet}" "${3:-1000}" "${4:-500}"
            ;;
        list)
            shift
            list_models "$@"
            ;;
        set)
            set_model "${2:-editor}" "${3:-sonnet}"
            ;;
        *)
            list_models --all
            ;;
    esac
fi
