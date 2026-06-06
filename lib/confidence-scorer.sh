#!/bin/bash
# =============================================================================
# Harmony Framework - Confidence Quantification
# =============================================================================
# Systematic confidence scoring for agent outputs, enabling human-in-the-loop
# when uncertainty is detected. Based on Bayesian meta-learning research.
#
# Usage:
#   source "${HARMONY_DIR}/lib/confidence-scorer.sh"
#
#   # Calculate confidence for a decision
#   score=$(confidence_calculate "context info" "decision to make")
#   level=$(confidence_get_level "$score")
#
#   # Check if human review needed
#   if confidence_needs_review "$score"; then
#       confidence_escalate "$decision_id"
#   fi
#
#   # Add metadata to results
#   result_with_confidence=$(confidence_add_metadata "$result" "$score")
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${CONFIDENCE_SCORER_LOADED:-}" == "true" ]]; then
    return 0
fi
CONFIDENCE_SCORER_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

CONFIDENCE_CONFIG="${HARMONY_DIR}/local/confidence-config.json"
CONFIDENCE_HISTORY="${HARMONY_DIR}/local/memory/confidence-history.json"

# Default thresholds
CONFIDENCE_THRESHOLD_HIGH="${CONFIDENCE_THRESHOLD_HIGH:-85}"
CONFIDENCE_THRESHOLD_MEDIUM="${CONFIDENCE_THRESHOLD_MEDIUM:-60}"
CONFIDENCE_THRESHOLD_LOW="${CONFIDENCE_THRESHOLD_LOW:-40}"

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

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

# Generate unique ID
_confidence_generate_id() {
    echo "CNF-$(date +%s%N | sha256sum | head -c 8)"
}

# Get ISO timestamp
_confidence_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

# Initialize history file
_confidence_init_history() {
    if [[ ! -f "$CONFIDENCE_HISTORY" ]]; then
        mkdir -p "$(dirname "$CONFIDENCE_HISTORY")"
        cp "${HARMONY_DIR}/templates/memory/confidence-history.template.json" "$CONFIDENCE_HISTORY"
        local ts
        ts=$(_confidence_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$CONFIDENCE_HISTORY" > "$tmp_file" && mv "$tmp_file" "$CONFIDENCE_HISTORY"
    fi
}

# Load config value
_confidence_config_get() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "$CONFIDENCE_CONFIG" ]]; then
        local value
        value=$(jq -r ".$key // empty" "$CONFIDENCE_CONFIG" 2>/dev/null)
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
            return
        fi
    fi
    echo "$default"
}

# Calculate context completeness score (0-25)
_confidence_score_context() {
    local context="$1"

    local score=0
    local context_len=${#context}

    # Length-based scoring
    if (( context_len > 1000 )); then
        score=15
    elif (( context_len > 500 )); then
        score=12
    elif (( context_len > 200 )); then
        score=8
    elif (( context_len > 50 )); then
        score=5
    else
        score=2
    fi

    # Check for structured data indicators
    if [[ "$context" == *"{"* && "$context" == *"}"* ]]; then
        ((score += 3))
    fi

    # Check for code indicators
    if [[ "$context" == *"function"* || "$context" == *"class"* || "$context" == *"def "* ]]; then
        ((score += 4))
    fi

    # Check for documentation
    if [[ "$context" == *"@param"* || "$context" == *"@return"* || "$context" == *"#"* ]]; then
        ((score += 3))
    fi

    # Cap at 25
    if (( score > 25 )); then
        score=25
    fi

    echo "$score"
}

# Calculate pattern match strength (0-25)
_confidence_score_pattern() {
    local decision="$1"

    local score=10  # Base score

    # Check for common patterns in decision
    local pattern_keywords=("implement" "create" "fix" "update" "refactor" "add" "remove" "test")

    for keyword in "${pattern_keywords[@]}"; do
        if [[ "${decision,,}" == *"$keyword"* ]]; then
            ((score += 2))
        fi
    done

    # Check for specificity
    if [[ "$decision" == *"file"* || "$decision" == *"function"* || "$decision" == *"class"* ]]; then
        ((score += 3))
    fi

    # Check for uncertainty words (reduce score)
    local uncertainty_words=("maybe" "perhaps" "might" "could" "possibly" "unclear" "unsure")

    for word in "${uncertainty_words[@]}"; do
        if [[ "${decision,,}" == *"$word"* ]]; then
            ((score -= 5))
        fi
    done

    # Cap between 0-25
    if (( score < 0 )); then
        score=0
    elif (( score > 25 )); then
        score=25
    fi

    echo "$score"
}

# Calculate previous success rate (0-25)
_confidence_score_history() {
    _confidence_init_history

    local calibration
    calibration=$(jq '.calibration' "$CONFIDENCE_HISTORY" 2>/dev/null)

    local total
    total=$(echo "$calibration" | jq -r '.total_decisions // 0')

    if (( total < 5 )); then
        # Not enough data, return neutral score
        echo "12"
        return
    fi

    local correct
    correct=$(echo "$calibration" | jq -r '.correct_predictions // 0')

    local rate
    rate=$(echo "scale=2; $correct / $total * 25" | bc 2>/dev/null || echo "12")

    # Round to integer
    printf "%.0f" "$rate"
}

# Calculate complexity assessment (0-25)
_confidence_score_complexity() {
    local context="$1"
    local decision="$2"

    local score=20  # Start optimistic

    # Reduce for complexity indicators
    local complexity_words=("complex" "complicated" "multiple" "various" "many" "several" "integration" "migration")

    for word in "${complexity_words[@]}"; do
        if [[ "${context,,}" == *"$word"* || "${decision,,}" == *"$word"* ]]; then
            ((score -= 3))
        fi
    done

    # Reduce for risk indicators
    local risk_words=("security" "authentication" "payment" "database" "production" "deploy" "delete" "remove")

    for word in "${risk_words[@]}"; do
        if [[ "${context,,}" == *"$word"* || "${decision,,}" == *"$word"* ]]; then
            ((score -= 2))
        fi
    done

    # Increase for simple indicators
    local simple_words=("simple" "basic" "straightforward" "minor" "small" "quick")

    for word in "${simple_words[@]}"; do
        if [[ "${context,,}" == *"$word"* || "${decision,,}" == *"$word"* ]]; then
            ((score += 2))
        fi
    done

    # Cap between 0-25
    if (( score < 0 )); then
        score=0
    elif (( score > 25 )); then
        score=25
    fi

    echo "$score"
}

# Get uncertainty factors
_confidence_get_factors() {
    local context="$1"
    local decision="$2"

    local factors=()

    # Check context issues
    if (( ${#context} < 100 )); then
        factors+=("Limited context provided")
    fi

    # Check for uncertainty words
    if [[ "${decision,,}" == *"maybe"* || "${decision,,}" == *"perhaps"* ]]; then
        factors+=("Decision contains uncertainty language")
    fi

    # Check for complexity
    if [[ "${context,,}" == *"complex"* || "${decision,,}" == *"complex"* ]]; then
        factors+=("Task involves complex operations")
    fi

    # Check for risk
    if [[ "${context,,}" == *"security"* || "${context,,}" == *"production"* ]]; then
        factors+=("High-risk domain detected")
    fi

    # Check for missing patterns
    if ! [[ "$decision" == *"file"* || "$decision" == *"function"* || "$decision" == *"class"* ]]; then
        factors+=("No specific target identified")
    fi

    # Check calibration
    _confidence_init_history
    local accuracy
    accuracy=$(jq -r '.calibration.correct_predictions / (.calibration.total_decisions + 0.001) * 100' "$CONFIDENCE_HISTORY" 2>/dev/null || echo "50")

    if (( $(echo "$accuracy < 70" | bc -l 2>/dev/null || echo 0) )); then
        factors+=("Historical accuracy below 70%")
    fi

    # Output as JSON array
    printf '%s\n' "${factors[@]}" | jq -R . | jq -s .
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Calculate confidence score for a decision
# Usage: confidence_calculate context decision
# Returns: score 0-100
confidence_calculate() {
    local context="${1:-}"
    local decision="${2:-}"

    # Calculate component scores
    local context_score
    context_score=$(_confidence_score_context "$context")

    local pattern_score
    pattern_score=$(_confidence_score_pattern "$decision")

    local history_score
    history_score=$(_confidence_score_history)

    local complexity_score
    complexity_score=$(_confidence_score_complexity "$context" "$decision")

    # Sum scores (0-100)
    local total=$((context_score + pattern_score + history_score + complexity_score))

    # Ensure bounds
    if (( total < 0 )); then
        total=0
    elif (( total > 100 )); then
        total=100
    fi

    echo "$total"
}

# Get confidence level from score
# Usage: confidence_get_level score
# Returns: CONFIDENT | UNCERTAIN | LOW | VERY_LOW
confidence_get_level() {
    local score="$1"

    local high
    high=$(_confidence_config_get "thresholds.confident" "$CONFIDENCE_THRESHOLD_HIGH")
    local medium
    medium=$(_confidence_config_get "thresholds.uncertain" "$CONFIDENCE_THRESHOLD_MEDIUM")
    local low
    low=$(_confidence_config_get "thresholds.low" "$CONFIDENCE_THRESHOLD_LOW")

    if (( score >= high )); then
        echo "CONFIDENT"
    elif (( score >= medium )); then
        echo "UNCERTAIN"
    elif (( score >= low )); then
        echo "LOW"
    else
        echo "VERY_LOW"
    fi
}

# Check if human review is needed
# Usage: confidence_needs_review score
# Returns: 0 (true) or 1 (false)
confidence_needs_review() {
    local score="$1"

    local threshold
    threshold=$(_confidence_config_get "review_threshold" "$CONFIDENCE_THRESHOLD_LOW")

    if (( score < threshold )); then
        return 0
    else
        return 1
    fi
}

# Get uncertainty factors for context/decision
# Usage: confidence_get_factors context decision
confidence_get_factors() {
    local context="${1:-}"
    local decision="${2:-}"

    _confidence_get_factors "$context" "$decision"
}

# Escalate decision for human review
# Usage: confidence_escalate decision_id [reason]
confidence_escalate() {
    local decision_id="$1"
    local reason="${2:-Low confidence score}"

    _confidence_init_history

    local escalation_id
    escalation_id=$(_confidence_generate_id)

    local ts
    ts=$(_confidence_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$escalation_id" \
       --arg did "$decision_id" \
       --arg ts "$ts" \
       --arg reason "$reason" \
       '.escalations += [{
          "id": $id,
          "decision_id": $did,
          "timestamp": $ts,
          "reason": $reason,
          "status": "pending",
          "resolved_at": null,
          "resolution": null
        }]' "$CONFIDENCE_HISTORY" > "$tmp_file" && mv "$tmp_file" "$CONFIDENCE_HISTORY"

    echo -e "${C_YELLOW}Decision escalated for review: $decision_id${C_NC}" >&2
    echo "$escalation_id"
}

# Add confidence metadata to a result
# Usage: confidence_add_metadata result score [factors_json]
confidence_add_metadata() {
    local result="$1"
    local score="$2"
    local factors="${3:-[]}"

    local level
    level=$(confidence_get_level "$score")

    local needs_review="false"
    if confidence_needs_review "$score"; then
        needs_review="true"
    fi

    # If result is valid JSON, merge; otherwise wrap
    if echo "$result" | jq -e '.' &>/dev/null; then
        echo "$result" | jq \
            --argjson score "$score" \
            --arg level "$level" \
            --argjson review "$needs_review" \
            --argjson factors "$factors" \
            '. + {
              confidence: {
                score: $score,
                level: $level,
                needs_human_review: $review,
                uncertainty_factors: $factors
              }
            }'
    else
        jq -n \
            --arg result "$result" \
            --argjson score "$score" \
            --arg level "$level" \
            --argjson review "$needs_review" \
            --argjson factors "$factors" \
            '{
              result: $result,
              confidence: {
                score: $score,
                level: $level,
                needs_human_review: $review,
                uncertainty_factors: $factors
              }
            }'
    fi
}

# Record a decision for calibration
# Usage: confidence_record decision_id score actual_outcome
confidence_record() {
    local decision_id="$1"
    local score="$2"
    local actual_outcome="${3:-unknown}"

    _confidence_init_history

    local level
    level=$(confidence_get_level "$score")

    local ts
    ts=$(_confidence_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$decision_id" \
       --argjson score "$score" \
       --arg level "$level" \
       --arg outcome "$actual_outcome" \
       --arg ts "$ts" \
       '.entries += [{
          "decision_id": $id,
          "score": $score,
          "level": $level,
          "outcome": $outcome,
          "timestamp": $ts
        }]' "$CONFIDENCE_HISTORY" > "$tmp_file" && mv "$tmp_file" "$CONFIDENCE_HISTORY"

    echo "$decision_id"
}

# Calibrate confidence based on actual outcome
# Usage: confidence_calibrate decision_id was_correct
confidence_calibrate() {
    local decision_id="$1"
    local was_correct="$2"  # true or false

    _confidence_init_history

    # Find the entry
    local entry
    entry=$(jq -r --arg id "$decision_id" '.entries[] | select(.decision_id == $id)' "$CONFIDENCE_HISTORY" 2>/dev/null)

    if [[ -z "$entry" || "$entry" == "null" ]]; then
        echo -e "${C_YELLOW}Decision not found: $decision_id${C_NC}" >&2
        return 1
    fi

    local level
    level=$(echo "$entry" | jq -r '.level')

    local tmp_file
    tmp_file=$(mktemp)

    if [[ "$was_correct" == "true" ]]; then
        jq --arg level "$level" \
           '.calibration.total_decisions += 1 |
            .calibration.correct_predictions += 1 |
            .calibration.accuracy_by_level[$level].total += 1 |
            .calibration.accuracy_by_level[$level].correct += 1' \
            "$CONFIDENCE_HISTORY" > "$tmp_file" && mv "$tmp_file" "$CONFIDENCE_HISTORY"
    else
        jq --arg level "$level" \
           '.calibration.total_decisions += 1 |
            .calibration.accuracy_by_level[$level].total += 1' \
            "$CONFIDENCE_HISTORY" > "$tmp_file" && mv "$tmp_file" "$CONFIDENCE_HISTORY"
    fi

    echo -e "${C_GREEN}Calibration updated for: $decision_id${C_NC}"
}

# Get calibration statistics
# Usage: confidence_get_calibration
confidence_get_calibration() {
    _confidence_init_history

    local calibration
    calibration=$(jq '.calibration' "$CONFIDENCE_HISTORY")

    local total
    total=$(echo "$calibration" | jq -r '.total_decisions')
    local correct
    correct=$(echo "$calibration" | jq -r '.correct_predictions')

    local accuracy="N/A"
    if (( total > 0 )); then
        accuracy=$(echo "scale=1; $correct / $total * 100" | bc 2>/dev/null || echo "N/A")
    fi

    echo -e "${C_CYAN}=== Confidence Calibration ===${C_NC}"
    echo -e "Total Decisions:    ${C_WHITE}$total${C_NC}"
    echo -e "Correct:            ${C_WHITE}$correct${C_NC}"
    echo -e "Overall Accuracy:   ${C_WHITE}${accuracy}%${C_NC}"
    echo ""
    echo -e "${C_CYAN}By Level:${C_NC}"
    echo "$calibration" | jq -r '.accuracy_by_level | to_entries[] |
        "  \(.key): \(.value.correct)/\(.value.total)"'
}

# Get pending escalations
# Usage: confidence_get_escalations [status]
confidence_get_escalations() {
    local status="${1:-pending}"

    _confidence_init_history

    jq -r --arg status "$status" \
        '[.escalations[] | select(.status == $status)]' "$CONFIDENCE_HISTORY"
}

# Resolve an escalation
# Usage: confidence_resolve_escalation escalation_id resolution
confidence_resolve_escalation() {
    local escalation_id="$1"
    local resolution="$2"

    _confidence_init_history

    local ts
    ts=$(_confidence_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$escalation_id" \
       --arg ts "$ts" \
       --arg res "$resolution" \
       '(.escalations[] | select(.id == $id)) |= . + {
          status: "resolved",
          resolved_at: $ts,
          resolution: $res
        }' "$CONFIDENCE_HISTORY" > "$tmp_file" && mv "$tmp_file" "$CONFIDENCE_HISTORY"

    echo -e "${C_GREEN}Escalation resolved: $escalation_id${C_NC}"
}

# Display confidence with color coding
# Usage: confidence_display score
confidence_display() {
    local score="$1"
    local level
    level=$(confidence_get_level "$score")

    local color
    case "$level" in
        "CONFIDENT") color="$C_GREEN" ;;
        "UNCERTAIN") color="$C_YELLOW" ;;
        "LOW") color="$C_RED" ;;
        "VERY_LOW") color="$C_RED" ;;
        *) color="$C_NC" ;;
    esac

    echo -e "${color}[$level] Score: $score/100${C_NC}"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_confidence_scorer_self_test() {
    echo -e "${C_CYAN}=== Confidence Scorer Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    # Create minimal config
    cat > "$HARMONY_DIR/local/confidence-config.json" << 'EOF'
{
  "thresholds": {
    "confident": 85,
    "uncertain": 60,
    "low": 40
  },
  "review_threshold": 40
}
EOF

    local passed=0
    local failed=0

    # Test 1: Calculate confidence
    echo -n "Test 1: Calculate confidence... "
    local score
    score=$(confidence_calculate "This is a complex function with authentication" "Implement login feature")
    if [[ "$score" =~ ^[0-9]+$ ]] && (( score >= 0 && score <= 100 )); then
        echo -e "${C_GREEN}PASS${C_NC} (score: $score)"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Get level - CONFIDENT
    echo -n "Test 2: Get level (high)... "
    local level
    level=$(confidence_get_level 90)
    if [[ "$level" == "CONFIDENT" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $level)"
        ((failed++))
    fi

    # Test 3: Get level - VERY_LOW
    echo -n "Test 3: Get level (very low)... "
    level=$(confidence_get_level 20)
    if [[ "$level" == "VERY_LOW" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $level)"
        ((failed++))
    fi

    # Test 4: Needs review (low score)
    echo -n "Test 4: Needs review (low score)... "
    if confidence_needs_review 30; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: No review (high score)
    echo -n "Test 5: No review (high score)... "
    if ! confidence_needs_review 90; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 6: Add metadata
    echo -n "Test 6: Add metadata... "
    local result
    result=$(confidence_add_metadata '{"action": "test"}' 75 '["factor1"]')
    if echo "$result" | jq -e '.confidence.score == 75' &>/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 7: Record decision
    echo -n "Test 7: Record decision... "
    local decision_id
    decision_id=$(confidence_record "DEC-001" 80 "success")
    if [[ "$decision_id" == "DEC-001" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 8: Escalate
    echo -n "Test 8: Escalate decision... "
    local escalation_id
    escalation_id=$(confidence_escalate "DEC-002" "Test escalation" 2>/dev/null)
    if [[ "$escalation_id" =~ ^CNF- ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Cleanup
    rm -rf "$test_dir"
    unset HARMONY_DIR

    echo ""
    echo -e "Results: ${C_GREEN}$passed passed${C_NC}, ${C_RED}$failed failed${C_NC}"

    [[ $failed -eq 0 ]]
}

# Run self-test if called with --test
if [[ "${1:-}" == "--test" ]]; then
    _confidence_scorer_self_test
    exit $?
fi
