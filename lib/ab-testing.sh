#!/bin/bash
# =============================================================================
# Harmony Framework - A/B Testing for Agents
# =============================================================================
# Structured experimentation framework to compare agent configurations
# and measure improvement.
#
# Usage:
#   source "${HARMONY_DIR}/lib/ab-testing.sh"
#
#   # Create experiment
#   ab_create_experiment "prompt-style" "Test formal vs casual prompts"
#
#   # Add variants
#   ab_add_variant "formal" '{"style": "formal"}'
#   ab_add_variant "casual" '{"style": "casual"}'
#
#   # Record result
#   ab_record_result "formal" 85
#
#   # Get winner
#   ab_get_winner "prompt-style"
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${AB_TESTING_LOADED:-}" == "true" ]]; then
    return 0
fi
AB_TESTING_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

AB_CONFIG="${HARMONY_DIR}/local/ab-experiments.json"
AB_RESULTS="${HARMONY_DIR}/local/memory/ab-results.json"

# Colors
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# Source date utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/date_utils.sh" ]]; then
    source "${SCRIPT_DIR}/date_utils.sh"
fi

# Current experiment
_AB_CURRENT_EXPERIMENT=""

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

_ab_generate_id() {
    echo "EXP-$(date +%s%N | sha256sum | head -c 8)"
}

_ab_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

_ab_init_results() {
    if [[ ! -f "$AB_RESULTS" ]]; then
        mkdir -p "$(dirname "$AB_RESULTS")"
        cp "${HARMONY_DIR}/templates/memory/ab-results.template.json" "$AB_RESULTS"
        local ts
        ts=$(_ab_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$AB_RESULTS" > "$tmp_file" && mv "$tmp_file" "$AB_RESULTS"
    fi
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Create new experiment
# Usage: ab_create_experiment name description [min_trials]
ab_create_experiment() {
    local name="$1"
    local description="$2"
    local min_trials="${3:-10}"

    _ab_init_results

    local exp_id
    exp_id=$(_ab_generate_id)
    _AB_CURRENT_EXPERIMENT="$name"

    local ts
    ts=$(_ab_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$exp_id" \
       --arg name "$name" \
       --arg desc "$description" \
       --argjson min "$min_trials" \
       --arg ts "$ts" \
       '.experiments[$name] = {
          "id": $id,
          "name": $name,
          "description": $desc,
          "status": "active",
          "min_trials": $min,
          "created": $ts,
          "variants": {},
          "results": [],
          "winner": null
        } |
        .statistics.total_experiments += 1' \
        "$AB_RESULTS" > "$tmp_file" && mv "$tmp_file" "$AB_RESULTS"

    echo -e "${C_GREEN}Experiment created: ${C_CYAN}$name${C_NC}" >&2
    echo "$exp_id"
}

# Add variant to experiment
# Usage: ab_add_variant variant_name config_json [experiment]
ab_add_variant() {
    local variant_name="$1"
    local config="$2"
    local experiment="${3:-$_AB_CURRENT_EXPERIMENT}"

    _ab_init_results

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg exp "$experiment" \
       --arg var "$variant_name" \
       --argjson config "$config" \
       '.experiments[$exp].variants[$var] = {
          "name": $var,
          "config": $config,
          "trials": 0,
          "total_score": 0,
          "avg_score": 0,
          "scores": []
        }' \
        "$AB_RESULTS" > "$tmp_file" && mv "$tmp_file" "$AB_RESULTS"

    echo -e "Added variant: ${C_WHITE}$variant_name${C_NC}"
}

# Record trial result
# Usage: ab_record_result variant score [experiment]
ab_record_result() {
    local variant="$1"
    local score="$2"
    local experiment="${3:-$_AB_CURRENT_EXPERIMENT}"

    _ab_init_results

    local ts
    ts=$(_ab_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg exp "$experiment" \
       --arg var "$variant" \
       --argjson score "$score" \
       --arg ts "$ts" \
       '.experiments[$exp].variants[$var].trials += 1 |
        .experiments[$exp].variants[$var].total_score += $score |
        .experiments[$exp].variants[$var].scores += [$score] |
        .experiments[$exp].variants[$var].avg_score =
          (.experiments[$exp].variants[$var].total_score /
           .experiments[$exp].variants[$var].trials) |
        .experiments[$exp].results += [{
          "timestamp": $ts,
          "variant": $var,
          "score": $score
        }] |
        .statistics.total_trials += 1' \
        "$AB_RESULTS" > "$tmp_file" && mv "$tmp_file" "$AB_RESULTS"

    # Check if experiment can be concluded
    ab_check_conclusion "$experiment"
}

# Select variant for trial (random or weighted)
# Usage: ab_select_variant [experiment]
ab_select_variant() {
    local experiment="${1:-$_AB_CURRENT_EXPERIMENT}"

    _ab_init_results

    local variants
    variants=$(jq -r --arg exp "$experiment" \
        '.experiments[$exp].variants | keys[]' "$AB_RESULTS")

    # Simple random selection
    local count
    count=$(echo "$variants" | wc -l)

    if (( count == 0 )); then
        echo ""
        return 1
    fi

    local index=$((RANDOM % count + 1))
    echo "$variants" | sed -n "${index}p"
}

# Check if experiment should conclude
# Usage: ab_check_conclusion experiment
ab_check_conclusion() {
    local experiment="$1"

    _ab_init_results

    local exp_data
    exp_data=$(jq -r --arg exp "$experiment" '.experiments[$exp]' "$AB_RESULTS")

    local status
    status=$(echo "$exp_data" | jq -r '.status')

    if [[ "$status" != "active" ]]; then
        return
    fi

    local min_trials
    min_trials=$(echo "$exp_data" | jq -r '.min_trials')

    # Check if all variants have min trials
    local all_ready=true
    local variants
    variants=$(echo "$exp_data" | jq -r '.variants | to_entries[]')

    while IFS= read -r variant; do
        local trials
        trials=$(echo "$variant" | jq -r '.value.trials')
        if (( trials < min_trials )); then
            all_ready=false
            break
        fi
    done <<< "$(echo "$exp_data" | jq -c '.variants | to_entries[]')"

    if [[ "$all_ready" == "true" ]]; then
        # Find winner
        local winner
        winner=$(echo "$exp_data" | jq -r \
            '.variants | to_entries | max_by(.value.avg_score) | .key')

        local tmp_file
        tmp_file=$(mktemp)
        jq --arg exp "$experiment" --arg winner "$winner" \
           '.experiments[$exp].status = "concluded" |
            .experiments[$exp].winner = $winner |
            .statistics.concluded_experiments += 1' \
            "$AB_RESULTS" > "$tmp_file" && mv "$tmp_file" "$AB_RESULTS"

        echo -e "${C_GREEN}Experiment concluded! Winner: ${C_WHITE}$winner${C_NC}"
    fi
}

# Get experiment winner
# Usage: ab_get_winner experiment
ab_get_winner() {
    local experiment="$1"

    _ab_init_results

    jq -r --arg exp "$experiment" '.experiments[$exp].winner // "none"' "$AB_RESULTS"
}

# Get experiment status
# Usage: ab_get_status experiment
ab_get_status() {
    local experiment="$1"

    _ab_init_results

    local exp_data
    exp_data=$(jq -r --arg exp "$experiment" '.experiments[$exp]' "$AB_RESULTS")

    if [[ "$exp_data" == "null" ]]; then
        echo -e "${C_RED}Experiment not found: $experiment${C_NC}"
        return 1
    fi

    echo -e "${C_CYAN}=== Experiment: $experiment ===${C_NC}"
    echo -e "Status:    ${C_WHITE}$(echo "$exp_data" | jq -r '.status')${C_NC}"
    echo -e "Min Trials: ${C_WHITE}$(echo "$exp_data" | jq -r '.min_trials')${C_NC}"

    local winner
    winner=$(echo "$exp_data" | jq -r '.winner')
    if [[ "$winner" != "null" ]]; then
        echo -e "Winner:    ${C_GREEN}$winner${C_NC}"
    fi

    echo ""
    echo -e "${C_WHITE}Variants:${C_NC}"
    echo "$exp_data" | jq -r '.variants | to_entries[] |
        "  \(.key): \(.value.trials) trials, avg score: \(.value.avg_score | . * 100 | floor / 100)"'
}

# List all experiments
# Usage: ab_list_experiments
ab_list_experiments() {
    _ab_init_results

    echo -e "${C_CYAN}=== A/B Experiments ===${C_NC}"
    jq -r '.experiments | to_entries[] |
        "[\(.value.status)] \(.key): \(.value.description)"' "$AB_RESULTS"
}

# Get variant config
# Usage: ab_get_config variant [experiment]
ab_get_config() {
    local variant="$1"
    local experiment="${2:-$_AB_CURRENT_EXPERIMENT}"

    _ab_init_results

    jq -r --arg exp "$experiment" --arg var "$variant" \
        '.experiments[$exp].variants[$var].config' "$AB_RESULTS"
}

# Get experiment statistics
# Usage: ab_get_stats
ab_get_stats() {
    _ab_init_results

    local stats
    stats=$(jq '.statistics' "$AB_RESULTS")

    echo -e "${C_CYAN}=== A/B Testing Statistics ===${C_NC}"
    echo -e "Total Experiments: ${C_WHITE}$(echo "$stats" | jq -r '.total_experiments')${C_NC}"
    echo -e "Concluded:         ${C_WHITE}$(echo "$stats" | jq -r '.concluded_experiments')${C_NC}"
    echo -e "Total Trials:      ${C_WHITE}$(echo "$stats" | jq -r '.total_trials')${C_NC}"
}

# Delete experiment
# Usage: ab_delete_experiment experiment
ab_delete_experiment() {
    local experiment="$1"

    _ab_init_results

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg exp "$experiment" 'del(.experiments[$exp])' \
        "$AB_RESULTS" > "$tmp_file" && mv "$tmp_file" "$AB_RESULTS"

    echo -e "${C_GREEN}Experiment deleted: $experiment${C_NC}"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_ab_testing_self_test() {
    echo -e "${C_CYAN}=== A/B Testing Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    local passed=0
    local failed=0

    # Test 1: Create experiment
    echo -n "Test 1: Create experiment... "
    local exp_id
    exp_id=$(ab_create_experiment "test-exp" "Test experiment" 3 2>/dev/null)
    if [[ "$exp_id" =~ ^EXP- ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Add variants
    echo -n "Test 2: Add variants... "
    ab_add_variant "variant-a" '{"param": "a"}' "test-exp" >/dev/null
    ab_add_variant "variant-b" '{"param": "b"}' "test-exp" >/dev/null
    local var_count
    var_count=$(jq '.experiments["test-exp"].variants | length' "$AB_RESULTS")
    if (( var_count == 2 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Record results
    echo -n "Test 3: Record results... "
    ab_record_result "variant-a" 80 "test-exp"
    ab_record_result "variant-b" 70 "test-exp"
    local trials
    trials=$(jq '.statistics.total_trials' "$AB_RESULTS")
    if (( trials >= 2 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Select variant
    echo -n "Test 4: Select variant... "
    local selected
    selected=$(ab_select_variant "test-exp")
    if [[ "$selected" == "variant-a" || "$selected" == "variant-b" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Complete experiment and get winner
    echo -n "Test 5: Get winner after completion... "
    ab_record_result "variant-a" 90 "test-exp"
    ab_record_result "variant-a" 85 "test-exp"
    ab_record_result "variant-b" 65 "test-exp"
    ab_record_result "variant-b" 75 "test-exp"
    local winner
    winner=$(ab_get_winner "test-exp")
    if [[ "$winner" == "variant-a" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $winner)"
        ((failed++))
    fi

    # Cleanup
    rm -rf "$test_dir"
    unset HARMONY_DIR
    _AB_CURRENT_EXPERIMENT=""

    echo ""
    echo -e "Results: ${C_GREEN}$passed passed${C_NC}, ${C_RED}$failed failed${C_NC}"

    [[ $failed -eq 0 ]]
}

if [[ "${1:-}" == "--test" ]]; then
    _ab_testing_self_test
    exit $?
fi
