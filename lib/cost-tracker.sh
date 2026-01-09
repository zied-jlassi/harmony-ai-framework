#!/bin/bash
# ============================================================================
# cost-tracker.sh - API Cost Tracking Module
# Harmony Framework
# ============================================================================
# Track API costs per session, agent, and model
# Provides cost estimation based on token usage
# ============================================================================

# Only set strict mode when running as standalone (not when sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
fi

# ============================================================================
# MODEL COST DEFINITIONS (per 1K tokens, USD)
# ============================================================================
# Source: Anthropic pricing (January 2026)
# https://www.anthropic.com/pricing

declare -gA MODEL_COSTS_INPUT=(
    ["claude-sonnet-4"]="0.003"
    ["claude-opus-4"]="0.015"
    ["claude-opus-4-5"]="0.015"
    ["claude-haiku"]="0.00025"
    ["claude-3-5-sonnet"]="0.003"
    ["claude-3-opus"]="0.015"
    ["claude-3-haiku"]="0.00025"
    # Aliases
    ["sonnet"]="0.003"
    ["opus"]="0.015"
    ["haiku"]="0.00025"
)

declare -gA MODEL_COSTS_OUTPUT=(
    ["claude-sonnet-4"]="0.015"
    ["claude-opus-4"]="0.075"
    ["claude-opus-4-5"]="0.075"
    ["claude-haiku"]="0.00125"
    ["claude-3-5-sonnet"]="0.015"
    ["claude-3-opus"]="0.075"
    ["claude-3-haiku"]="0.00125"
    # Aliases
    ["sonnet"]="0.015"
    ["opus"]="0.075"
    ["haiku"]="0.00125"
)

# Default costs for unknown models
DEFAULT_INPUT_COST="0.003"
DEFAULT_OUTPUT_COST="0.015"

# ============================================================================
# CURRENCY SUPPORT
# ============================================================================

# Default currency display
DEFAULT_CURRENCY="USD"

# Get user's preferred currency from local config
# Reads from: .harmony/local/autopilot-config.json -> cost_tracking.currency
# Or: .harmony/local/config/overrides.yaml -> cost_tracking.currency
get_preferred_currency() {
    local harmony_dir="${HARMONY_DIR:-${PWD}/.harmony}"
    local config_file="$harmony_dir/local/autopilot-config.json"
    local overrides_file="$harmony_dir/local/config/overrides.yaml"

    # Try JSON config first
    if [[ -f "$config_file" ]]; then
        local currency
        currency=$(jq -r '.cost_tracking.currency // empty' "$config_file" 2>/dev/null)
        if [[ -n "$currency" ]]; then
            echo "$currency"
            return
        fi
    fi

    # Try YAML overrides
    if [[ -f "$overrides_file" ]] && command -v yq &>/dev/null; then
        local currency
        currency=$(cat "$overrides_file" | yq -r '.cost_tracking.currency // empty' 2>/dev/null) || \
        currency=$(yq -r '.cost_tracking.currency // empty' "$overrides_file" 2>/dev/null) || true
        if [[ -n "$currency" && "$currency" != "null" ]]; then
            echo "$currency"
            return
        fi
    fi

    # Default
    echo "$DEFAULT_CURRENCY"
}

# Exchange rate cache file (refreshed daily)
EXCHANGE_RATE_CACHE="${HARMONY_MEMORY:-${PWD}/.harmony/memory}/.exchange-rate-cache.json"

# Fallback EUR/USD rate if fetch fails
FALLBACK_EUR_RATE="0.92"

# Get current EUR/USD exchange rate (cached daily)
get_eur_rate() {
    local cache_file="$EXCHANGE_RATE_CACHE"
    local cache_dir
    cache_dir=$(dirname "$cache_file")
    [[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"

    local current_date
    current_date=$(date +%Y-%m-%d)

    # Check cache validity
    if [[ -f "$cache_file" ]]; then
        local cached_date cached_rate
        cached_date=$(jq -r '.date // ""' "$cache_file" 2>/dev/null)
        cached_rate=$(jq -r '.eur_rate // ""' "$cache_file" 2>/dev/null)

        if [[ "$cached_date" == "$current_date" && -n "$cached_rate" ]]; then
            echo "$cached_rate"
            return
        fi
    fi

    # Fetch new rate
    local new_rate=""

    # Try exchangerate-api (free, no key required)
    if command -v curl &>/dev/null; then
        new_rate=$(curl -s --max-time 5 "https://api.exchangerate-api.com/v4/latest/USD" 2>/dev/null | \
                   jq -r '.rates.EUR // empty' 2>/dev/null) || true
    fi

    # Fallback to backup API
    if [[ -z "$new_rate" ]] && command -v curl &>/dev/null; then
        new_rate=$(curl -s --max-time 5 "https://open.er-api.com/v6/latest/USD" 2>/dev/null | \
                   jq -r '.rates.EUR // empty' 2>/dev/null) || true
    fi

    # Use fallback if fetch failed
    if [[ -z "$new_rate" ]]; then
        new_rate="$FALLBACK_EUR_RATE"
    fi

    # Cache the rate
    cat > "$cache_file" << EOF
{
  "date": "$current_date",
  "eur_rate": $new_rate,
  "source": "exchangerate-api.com",
  "fetched_at": "$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)"
}
EOF

    echo "$new_rate"
}

# Convert USD to EUR
usd_to_eur() {
    local usd_amount="${1:-0}"
    local rate
    rate=$(get_eur_rate)
    echo "scale=6; $usd_amount * $rate" | bc -l
}

# Format cost with currency symbol
format_cost() {
    local amount="${1:-0}"
    local currency="${2:-USD}"

    case "$currency" in
        EUR|eur)
            local eur_amount
            eur_amount=$(usd_to_eur "$amount")
            printf "%.4f €" "$eur_amount"
            ;;
        USD|usd|*)
            printf "\$%.4f" "$amount"
            ;;
    esac
}

# Format cost in both currencies
format_cost_dual() {
    local usd_amount="${1:-0}"
    local eur_amount
    eur_amount=$(usd_to_eur "$usd_amount")
    printf "\$%.4f (%.4f €)" "$usd_amount" "$eur_amount"
}

# ============================================================================
# PATHS
# ============================================================================

# Costs file location
COSTS_FILE="${HARMONY_MEMORY:-${PWD}/.harmony/memory}/session-costs.json"

# ============================================================================
# INITIALIZATION
# ============================================================================

# Initialize cost tracking for a new session
# Creates session-costs.json with initial structure
init_cost_tracking() {
    local costs_dir
    costs_dir=$(dirname "$COSTS_FILE")

    # Create directory if needed
    [[ -d "$costs_dir" ]] || mkdir -p "$costs_dir"

    # Create new session file if doesn't exist
    if [[ ! -f "$COSTS_FILE" ]]; then
        _create_new_session
    fi
}

# Internal: Create a new session structure
_create_new_session() {
    local session_id
    local timestamp

    session_id="session-$(date +%Y%m%d-%H%M%S)-$$-$RANDOM"
    timestamp=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)

    cat > "$COSTS_FILE" << EOF
{
  "session_id": "$session_id",
  "started_at": "$timestamp",
  "total_cost": 0,
  "total_input_tokens": 0,
  "total_output_tokens": 0,
  "sessions": []
}
EOF
}

# ============================================================================
# TRACKING
# ============================================================================

# Track API usage
# Usage: track_usage <model> <input_tokens> <output_tokens> <agent>
track_usage() {
    local model="${1:-unknown}"
    local input_tokens="${2:-0}"
    local output_tokens="${3:-0}"
    local agent="${4:-unknown}"

    # Ensure initialized
    init_cost_tracking

    # Get costs for model (use defaults if unknown)
    local input_cost_per_k="${MODEL_COSTS_INPUT[$model]:-$DEFAULT_INPUT_COST}"
    local output_cost_per_k="${MODEL_COSTS_OUTPUT[$model]:-$DEFAULT_OUTPUT_COST}"

    # Calculate cost
    local cost
    cost=$(echo "scale=8; ($input_cost_per_k * $input_tokens / 1000) + ($output_cost_per_k * $output_tokens / 1000)" | bc -l)

    # Get timestamp
    local timestamp
    timestamp=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)

    # Update JSON file
    local tmp_file="${COSTS_FILE}.tmp"
    jq --arg agent "$agent" \
       --arg model "$model" \
       --argjson input_tokens "$input_tokens" \
       --argjson output_tokens "$output_tokens" \
       --argjson cost "$cost" \
       --arg timestamp "$timestamp" \
       '.sessions += [{
         "timestamp": $timestamp,
         "agent": $agent,
         "model": $model,
         "input_tokens": $input_tokens,
         "output_tokens": $output_tokens,
         "cost": $cost
       }] |
       .total_cost = (.total_cost + $cost) |
       .total_input_tokens = (.total_input_tokens + $input_tokens) |
       .total_output_tokens = (.total_output_tokens + $output_tokens)' \
       "$COSTS_FILE" > "$tmp_file" && mv "$tmp_file" "$COSTS_FILE"
}

# ============================================================================
# GETTERS
# ============================================================================

# Get total session cost
# Returns: cost as string (e.g., "0.0234")
get_session_cost() {
    init_cost_tracking
    jq -r '.total_cost | tostring | .[0:8]' "$COSTS_FILE" 2>/dev/null || echo "0"
}

# Get costs grouped by agent
# Returns: JSON object {"agent": cost, ...}
get_agent_costs() {
    init_cost_tracking
    jq -r '[.sessions | group_by(.agent)[] | {(.[0].agent): ([.[].cost] | add)}] | add // {}' "$COSTS_FILE" 2>/dev/null || echo "{}"
}

# Get cost for specific agent
# Usage: get_agent_cost <agent>
# Returns: cost as string
get_agent_cost() {
    local agent="${1:-}"

    if [[ -z "$agent" ]]; then
        echo "0"
        return
    fi

    init_cost_tracking
    jq -r --arg agent "$agent" '[.sessions[] | select(.agent == $agent) | .cost] | add // 0 | tostring | .[0:8]' "$COSTS_FILE" 2>/dev/null || echo "0"
}

# Get number of API calls
get_call_count() {
    init_cost_tracking
    jq -r '.sessions | length' "$COSTS_FILE" 2>/dev/null || echo "0"
}

# Get total tokens
get_total_tokens() {
    init_cost_tracking
    local input output
    input=$(jq -r '.total_input_tokens' "$COSTS_FILE" 2>/dev/null || echo "0")
    output=$(jq -r '.total_output_tokens' "$COSTS_FILE" 2>/dev/null || echo "0")
    echo "$input:$output"
}

# ============================================================================
# RESET
# ============================================================================

# Reset session costs (start new session)
reset_session_costs() {
    _create_new_session
}

# ============================================================================
# EXPORT
# ============================================================================

# Export costs to CSV
# Usage: export_costs_csv [output_file]
# If no file provided, outputs to stdout
export_costs_csv() {
    local output_file="${1:-}"

    init_cost_tracking

    local csv_content
    csv_content=$(jq -r '
        ["timestamp","agent","model","input_tokens","output_tokens","cost"],
        (.sessions[] | [.timestamp, .agent, .model, .input_tokens, .output_tokens, .cost])
        | @csv
    ' "$COSTS_FILE" 2>/dev/null)

    if [[ -n "$output_file" ]]; then
        echo "$csv_content" > "$output_file"
    else
        echo "$csv_content"
    fi
}

# ============================================================================
# SUMMARY
# ============================================================================

# Get human-readable session summary
get_session_summary() {
    init_cost_tracking

    local total_cost call_count total_input total_output
    total_cost=$(get_session_cost)
    call_count=$(get_call_count)
    total_input=$(jq -r '.total_input_tokens' "$COSTS_FILE" 2>/dev/null || echo "0")
    total_output=$(jq -r '.total_output_tokens' "$COSTS_FILE" 2>/dev/null || echo "0")

    # Get EUR conversion
    local total_eur eur_rate
    eur_rate=$(get_eur_rate)
    total_eur=$(echo "scale=4; $total_cost * $eur_rate" | bc -l 2>/dev/null || echo "0")

    # Get preferred currency
    local pref_currency
    pref_currency=$(get_preferred_currency)

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " Session Cost Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Total Cost:    \$${total_cost} USD (${total_eur} €)"
    echo "  Exchange Rate: 1 USD = ${eur_rate} EUR"
    echo "  API Calls:     ${call_count}"
    echo "  Input Tokens:  ${total_input}"
    echo "  Output Tokens: ${total_output}"
    echo ""
    echo "  By Agent:"

    # Get per-agent costs with EUR
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local agent_name agent_cost agent_calls agent_eur
            agent_name=$(echo "$line" | cut -d'|' -f1)
            agent_cost=$(echo "$line" | cut -d'|' -f2)
            agent_calls=$(echo "$line" | cut -d'|' -f3)
            agent_eur=$(echo "scale=4; $agent_cost * $eur_rate" | bc -l 2>/dev/null || echo "0")
            echo "    ${agent_name}: \$${agent_cost} (${agent_eur} €) - ${agent_calls} calls"
        fi
    done < <(jq -r '.sessions | group_by(.agent) | .[] | "\(.[0].agent)|\([.[].cost] | add | tostring | .[0:8])|\(length)"' "$COSTS_FILE" 2>/dev/null)

    if [[ $(jq -r '.sessions | length' "$COSTS_FILE" 2>/dev/null) -eq 0 ]]; then
        echo "    (no data)"
    fi

    echo ""
    echo "  By Model:"
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local model_name model_cost model_eur
            model_name=$(echo "$line" | cut -d'|' -f1)
            model_cost=$(echo "$line" | cut -d'|' -f2)
            model_eur=$(echo "scale=4; $model_cost * $eur_rate" | bc -l 2>/dev/null || echo "0")
            echo "    ${model_name}: \$${model_cost} (${model_eur} €)"
        fi
    done < <(jq -r '.sessions | group_by(.model) | .[] | "\(.[0].model)|\([.[].cost] | add | tostring | .[0:8])"' "$COSTS_FILE" 2>/dev/null)

    if [[ $(jq -r '.sessions | length' "$COSTS_FILE" 2>/dev/null) -eq 0 ]]; then
        echo "    (no data)"
    fi
    echo ""
    echo "  Currency preference: ${pref_currency}"
    echo "  Config: .harmony/local/autopilot-config.json"
    echo ""
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Estimate cost before making a call
# Usage: estimate_cost <model> <estimated_input_tokens> <estimated_output_tokens>
estimate_cost() {
    local model="${1:-sonnet}"
    local input_tokens="${2:-1000}"
    local output_tokens="${3:-500}"

    local input_cost_per_k="${MODEL_COSTS_INPUT[$model]:-$DEFAULT_INPUT_COST}"
    local output_cost_per_k="${MODEL_COSTS_OUTPUT[$model]:-$DEFAULT_OUTPUT_COST}"

    echo "scale=6; ($input_cost_per_k * $input_tokens / 1000) + ($output_cost_per_k * $output_tokens / 1000)" | bc -l
}

# Get model tier (budget/standard/premium)
get_model_tier() {
    local model="${1:-}"
    local input_cost="${MODEL_COSTS_INPUT[$model]:-$DEFAULT_INPUT_COST}"

    if (( $(echo "$input_cost < 0.001" | bc -l) )); then
        echo "budget"
    elif (( $(echo "$input_cost < 0.01" | bc -l) )); then
        echo "standard"
    else
        echo "premium"
    fi
}

# ============================================================================
# STANDALONE EXECUTION
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --init)
            init_cost_tracking
            echo "Cost tracking initialized: $COSTS_FILE"
            ;;
        --track)
            shift
            track_usage "$@"
            echo "Usage tracked"
            ;;
        --cost)
            get_session_cost
            ;;
        --summary)
            get_session_summary
            ;;
        --agents)
            get_agent_costs
            ;;
        --export)
            export_costs_csv "${2:-}"
            ;;
        --reset)
            reset_session_costs
            echo "Session reset"
            ;;
        --estimate)
            shift
            estimate_cost "$@"
            ;;
        *)
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  --init                          Initialize cost tracking"
            echo "  --track <model> <in> <out> <agent>  Track usage"
            echo "  --cost                          Get session cost"
            echo "  --summary                       Get session summary"
            echo "  --agents                        Get per-agent costs"
            echo "  --export [file]                 Export to CSV"
            echo "  --reset                         Reset session"
            echo "  --estimate <model> <in> <out>   Estimate cost"
            ;;
    esac
fi
