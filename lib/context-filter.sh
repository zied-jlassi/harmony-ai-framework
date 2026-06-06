#!/bin/bash
# =============================================================================
# Harmony Framework - FILCO Context Filtering
# =============================================================================
# Pre-filters irrelevant context spans before LLM injection to improve
# precision and reduce token waste. Based on FILCO research.
#
# Usage:
#   source "${HARMONY_DIR}/lib/context-filter.sh"
#
#   # Filter context for a query
#   filtered=$(filco_filter "$context" "$query")
#
#   # Score context relevance
#   score=$(filco_score_chunk "$chunk" "$task")
#
#   # Compact to budget
#   compact=$(filco_compact "$context" 5000)
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${CONTEXT_FILTER_LOADED:-}" == "true" ]]; then
    return 0
fi
CONTEXT_FILTER_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

FILCO_CONFIG="${HARMONY_DIR}/local/filco-config.json"
FILCO_CACHE="${HARMONY_DIR}/local/memory/filter-cache.json"

# Default settings
FILCO_MAX_TOKENS="${FILCO_MAX_TOKENS:-15000}"
FILCO_MIN_RELEVANCE="${FILCO_MIN_RELEVANCE:-20}"
FILCO_CHUNK_SIZE="${FILCO_CHUNK_SIZE:-500}"

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

# Estimate token count (rough: 1 token ≈ 4 chars)
_filco_estimate_tokens() {
    local text="$1"
    local chars=${#text}
    echo $(( (chars + 3) / 4 ))
}

# Get ISO timestamp
_filco_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

# Initialize cache
_filco_init_cache() {
    if [[ ! -f "$FILCO_CACHE" ]]; then
        mkdir -p "$(dirname "$FILCO_CACHE")"
        cp "${HARMONY_DIR}/templates/memory/filter-cache.template.json" "$FILCO_CACHE"
        local ts
        ts=$(_filco_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$FILCO_CACHE" > "$tmp_file" && mv "$tmp_file" "$FILCO_CACHE"
    fi
}

# Load config value
_filco_config_get() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "$FILCO_CONFIG" ]]; then
        local value
        value=$(jq -r ".$key // empty" "$FILCO_CONFIG" 2>/dev/null)
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
            return
        fi
    fi
    echo "$default"
}

# Extract keywords from query
_filco_extract_keywords() {
    local query="$1"

    # Remove common stop words and extract significant terms
    local stop_words="the|a|an|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|could|should|may|might|must|shall|can|need|dare|ought|used|to|of|in|for|on|with|at|by|from|as|into|through|during|before|after|above|below|between|under|again|further|then|once|here|there|when|where|why|how|all|each|few|more|most|other|some|such|no|nor|not|only|own|same|so|than|too|very|just|and|but|if|or|because|until|while|this|that|these|those|what|which|who|whom"

    echo "$query" | tr '[:upper:]' '[:lower:]' | \
        tr -cs '[:alpha:]' '\n' | \
        grep -vwE "^($stop_words)$" | \
        sort -u | \
        head -20
}

# Calculate keyword overlap score
_filco_keyword_score() {
    local chunk="$1"
    local keywords="$2"

    local chunk_lower="${chunk,,}"
    local score=0
    local keyword_count=0

    while IFS= read -r keyword; do
        if [[ -n "$keyword" ]]; then
            ((keyword_count++)) || true
            if [[ "$chunk_lower" == *"$keyword"* ]]; then
                # Count occurrences
                local count
                count=$(echo "$chunk_lower" | grep -o "$keyword" | wc -l)
                score=$((score + count * 5))
            fi
        fi
    done <<< "$keywords"

    # Normalize by keyword count
    if (( keyword_count > 0 )); then
        score=$((score * 100 / keyword_count / 5))
    fi

    # Cap at 100
    if (( score > 100 )); then
        score=100
    fi

    echo "$score"
}

# Calculate structural importance
_filco_structural_score() {
    local chunk="$1"

    local score=50  # Base score

    # Code indicators (high importance)
    if [[ "$chunk" == *"function"* || "$chunk" == *"class"* || "$chunk" == *"def "* ]]; then
        ((score += 20))
    fi

    # API/interface indicators
    if [[ "$chunk" == *"export"* || "$chunk" == *"public"* || "$chunk" == *"interface"* ]]; then
        ((score += 15))
    fi

    # Documentation
    if [[ "$chunk" == *"@param"* || "$chunk" == *"@return"* || "$chunk" == *"/**"* ]]; then
        ((score += 10))
    fi

    # Error handling
    if [[ "$chunk" == *"try"* || "$chunk" == *"catch"* || "$chunk" == *"error"* ]]; then
        ((score += 10))
    fi

    # Test code (lower importance for non-test tasks)
    if [[ "$chunk" == *"test("* || "$chunk" == *"describe("* || "$chunk" == *"it("* ]]; then
        ((score -= 10))
    fi

    # Comments only (lower importance)
    if [[ "$chunk" =~ ^[[:space:]]*[#//\*] ]]; then
        ((score -= 5))
    fi

    # Normalize
    if (( score < 0 )); then
        score=0
    elif (( score > 100 )); then
        score=100
    fi

    echo "$score"
}

# Split content into chunks
_filco_chunk_content() {
    local content="$1"
    local chunk_size="${2:-$FILCO_CHUNK_SIZE}"

    # Try to split on logical boundaries (functions, classes, blank lines)
    local chunks=()
    local current_chunk=""
    local line_count=0
    local max_lines=$((chunk_size / 40))  # Approx 40 chars per line

    while IFS= read -r line; do
        current_chunk+="$line"$'\n'
        ((line_count++))

        # Split on logical boundaries
        if (( line_count >= max_lines )) || \
           [[ "$line" =~ ^[[:space:]]*$ ]] || \
           [[ "$line" =~ ^(function|class|def|export|module) ]] || \
           [[ "$line" == "}" || "$line" == "};" ]]; then

            if [[ -n "${current_chunk// }" ]]; then
                echo "---CHUNK_BOUNDARY---"
                echo "$current_chunk"
            fi
            current_chunk=""
            line_count=0
        fi
    done <<< "$content"

    # Last chunk
    if [[ -n "${current_chunk// }" ]]; then
        echo "---CHUNK_BOUNDARY---"
        echo "$current_chunk"
    fi
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Filter irrelevant context spans
# Usage: filco_filter context query
filco_filter() {
    local context="$1"
    local query="$2"

    local keywords
    keywords=$(_filco_extract_keywords "$query")

    local min_relevance
    min_relevance=$(_filco_config_get "min_relevance" "$FILCO_MIN_RELEVANCE")

    local filtered=""
    local current_chunk=""

    # Process chunks
    while IFS= read -r line; do
        if [[ "$line" == "---CHUNK_BOUNDARY---" ]]; then
            if [[ -n "$current_chunk" ]]; then
                # Score the chunk
                local keyword_score
                keyword_score=$(_filco_keyword_score "$current_chunk" "$keywords")

                local structural_score
                structural_score=$(_filco_structural_score "$current_chunk")

                # Combined score (weighted average)
                local total_score=$(( (keyword_score * 60 + structural_score * 40) / 100 ))

                if (( total_score >= min_relevance )); then
                    filtered+="$current_chunk"$'\n'
                fi
            fi
            current_chunk=""
        else
            current_chunk+="$line"$'\n'
        fi
    done <<< "$(_filco_chunk_content "$context")"

    # Handle last chunk
    if [[ -n "$current_chunk" ]]; then
        local keyword_score
        keyword_score=$(_filco_keyword_score "$current_chunk" "$keywords")

        local structural_score
        structural_score=$(_filco_structural_score "$current_chunk")

        local total_score=$(( (keyword_score * 60 + structural_score * 40) / 100 ))

        if (( total_score >= min_relevance )); then
            filtered+="$current_chunk"
        fi
    fi

    # Update stats
    _filco_init_cache
    local original_tokens
    original_tokens=$(_filco_estimate_tokens "$context")
    local filtered_tokens
    filtered_tokens=$(_filco_estimate_tokens "$filtered")
    local saved=$((original_tokens - filtered_tokens))

    local tmp_file
    tmp_file=$(mktemp)
    jq --argjson saved "$saved" \
       '.statistics.total_filtered += 1 |
        .statistics.tokens_saved += $saved' \
        "$FILCO_CACHE" > "$tmp_file" && mv "$tmp_file" "$FILCO_CACHE"

    echo "$filtered"
}

# Score context relevance for a chunk
# Usage: filco_score_chunk chunk task
filco_score_chunk() {
    local chunk="$1"
    local task="$2"

    local keywords
    keywords=$(_filco_extract_keywords "$task")

    local keyword_score
    keyword_score=$(_filco_keyword_score "$chunk" "$keywords")

    local structural_score
    structural_score=$(_filco_structural_score "$chunk")

    # Combined score
    local total_score=$(( (keyword_score * 60 + structural_score * 40) / 100 ))

    echo "$total_score"
}

# Compact context to token budget
# Usage: filco_compact context max_tokens
filco_compact() {
    local context="$1"
    local max_tokens="${2:-$FILCO_MAX_TOKENS}"

    local current_tokens
    current_tokens=$(_filco_estimate_tokens "$context")

    if (( current_tokens <= max_tokens )); then
        echo "$context"
        return
    fi

    # Score and rank all chunks
    local chunks_with_scores=()
    local current_chunk=""

    while IFS= read -r line; do
        if [[ "$line" == "---CHUNK_BOUNDARY---" ]]; then
            if [[ -n "$current_chunk" ]]; then
                local score
                score=$(_filco_structural_score "$current_chunk")
                chunks_with_scores+=("$score:$current_chunk")
            fi
            current_chunk=""
        else
            current_chunk+="$line"$'\n'
        fi
    done <<< "$(_filco_chunk_content "$context")"

    # Sort by score (descending)
    local sorted_chunks
    sorted_chunks=$(printf '%s\n' "${chunks_with_scores[@]}" | sort -t: -k1 -rn)

    # Select chunks until budget
    local result=""
    local used_tokens=0

    while IFS= read -r scored_chunk; do
        local chunk="${scored_chunk#*:}"
        local chunk_tokens
        chunk_tokens=$(_filco_estimate_tokens "$chunk")

        if (( used_tokens + chunk_tokens <= max_tokens )); then
            result+="$chunk"$'\n'
            used_tokens=$((used_tokens + chunk_tokens))
        fi
    done <<< "$sorted_chunks"

    echo "$result"
}

# Rank context chunks by relevance
# Usage: filco_rank_chunks context query
filco_rank_chunks() {
    local context="$1"
    local query="$2"

    local keywords
    keywords=$(_filco_extract_keywords "$query")

    local results="[]"
    local chunk_index=0
    local current_chunk=""

    while IFS= read -r line; do
        if [[ "$line" == "---CHUNK_BOUNDARY---" ]]; then
            if [[ -n "$current_chunk" ]]; then
                local keyword_score
                keyword_score=$(_filco_keyword_score "$current_chunk" "$keywords")

                local structural_score
                structural_score=$(_filco_structural_score "$current_chunk")

                local total_score=$(( (keyword_score * 60 + structural_score * 40) / 100 ))

                # Truncate chunk for JSON
                local preview="${current_chunk:0:200}"

                results=$(echo "$results" | jq \
                    --argjson idx "$chunk_index" \
                    --argjson score "$total_score" \
                    --argjson kscore "$keyword_score" \
                    --argjson sscore "$structural_score" \
                    --arg preview "$preview" \
                    '. += [{
                      "index": $idx,
                      "total_score": $score,
                      "keyword_score": $kscore,
                      "structural_score": $sscore,
                      "preview": $preview
                    }]')

                ((chunk_index++)) || true
            fi
            current_chunk=""
        else
            current_chunk+="$line"$'\n'
        fi
    done <<< "$(_filco_chunk_content "$context")"

    # Sort by score
    echo "$results" | jq 'sort_by(-.total_score)'
}

# Extract essential context (most important chunks)
# Usage: filco_extract_essential context [count]
filco_extract_essential() {
    local context="$1"
    local count="${2:-5}"

    local essential=""
    local current_chunk=""
    local chunks_with_scores=()

    while IFS= read -r line; do
        if [[ "$line" == "---CHUNK_BOUNDARY---" ]]; then
            if [[ -n "$current_chunk" ]]; then
                local score
                score=$(_filco_structural_score "$current_chunk")
                chunks_with_scores+=("$score|$current_chunk")
            fi
            current_chunk=""
        else
            current_chunk+="$line"$'\n'
        fi
    done <<< "$(_filco_chunk_content "$context")"

    # Sort and take top N
    printf '%s\n' "${chunks_with_scores[@]}" | \
        sort -t'|' -k1 -rn | \
        head -n "$count" | \
        while IFS='|' read -r score chunk; do
            echo "$chunk"
            echo ""
        done
}

# Get filter statistics
# Usage: filco_get_stats
filco_get_stats() {
    _filco_init_cache

    local stats
    stats=$(jq '.statistics' "$FILCO_CACHE")

    echo -e "${C_CYAN}=== FILCO Filter Statistics ===${C_NC}"
    echo -e "Total Filtered:  ${C_WHITE}$(echo "$stats" | jq -r '.total_filtered')${C_NC}"
    echo -e "Tokens Saved:    ${C_WHITE}$(echo "$stats" | jq -r '.tokens_saved')${C_NC}"
    echo -e "Cache Hits:      ${C_WHITE}$(echo "$stats" | jq -r '.cache_hits')${C_NC}"
}

# Clear filter cache
# Usage: filco_clear_cache
filco_clear_cache() {
    if [[ -f "$FILCO_CACHE" ]]; then
        rm "$FILCO_CACHE"
    fi
    _filco_init_cache
    echo -e "${C_GREEN}FILCO cache cleared${C_NC}"
}

# Display filter summary
# Usage: filco_display_summary original_size filtered_size
filco_display_summary() {
    local original="$1"
    local filtered="$2"

    local original_tokens
    original_tokens=$(_filco_estimate_tokens "$original")
    local filtered_tokens
    filtered_tokens=$(_filco_estimate_tokens "$filtered")

    local saved=$((original_tokens - filtered_tokens))
    local percent=0
    if (( original_tokens > 0 )); then
        percent=$((saved * 100 / original_tokens))
    fi

    echo -e "${C_CYAN}Context Filter Summary:${C_NC}"
    echo -e "  Original: ${C_WHITE}$original_tokens${C_NC} tokens"
    echo -e "  Filtered: ${C_WHITE}$filtered_tokens${C_NC} tokens"
    echo -e "  Saved:    ${C_GREEN}$saved${C_NC} tokens (${percent}%)"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_context_filter_self_test() {
    echo -e "${C_CYAN}=== Context Filter (FILCO) Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    # Create minimal config
    cat > "$HARMONY_DIR/local/filco-config.json" << 'EOF'
{
  "max_tokens": 1000,
  "min_relevance": 20,
  "chunk_size": 200
}
EOF

    local passed=0
    local failed=0

    # Test context
    local test_context="
function authenticateUser(username, password) {
    // Validate credentials
    const user = findUser(username);
    if (user && checkPassword(password, user.hash)) {
        return generateToken(user);
    }
    return null;
}

function formatDate(date) {
    return date.toISOString();
}

class UserService {
    constructor(db) {
        this.db = db;
    }

    async getUser(id) {
        return this.db.users.findById(id);
    }
}

// Helper utilities
const utils = {
    capitalize: (s) => s.charAt(0).toUpperCase() + s.slice(1),
    lowercase: (s) => s.toLowerCase()
};
"

    # Test 1: Extract keywords
    echo -n "Test 1: Extract keywords... "
    local keywords
    keywords=$(_filco_extract_keywords "authenticate user login")
    if [[ "$keywords" == *"authenticate"* && "$keywords" == *"user"* ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Keyword score
    echo -n "Test 2: Keyword score... "
    local score
    score=$(_filco_keyword_score "authenticate user password" "authenticate"$'\n'"user")
    if (( score > 0 )); then
        echo -e "${C_GREEN}PASS${C_NC} (score: $score)"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Structural score (function)
    echo -n "Test 3: Structural score (function)... "
    score=$(_filco_structural_score "function test() { return true; }")
    if (( score > 50 )); then
        echo -e "${C_GREEN}PASS${C_NC} (score: $score)"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 4: Filter context
    echo -n "Test 4: Filter context... "
    local filtered
    filtered=$(filco_filter "$test_context" "authenticate user")
    if [[ "$filtered" == *"authenticateUser"* ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Score chunk
    echo -n "Test 5: Score chunk... "
    score=$(filco_score_chunk "function authenticateUser()" "authentication")
    if (( score > 0 )); then
        echo -e "${C_GREEN}PASS${C_NC} (score: $score)"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 6: Compact context
    echo -n "Test 6: Compact context... "
    local compacted
    compacted=$(filco_compact "$test_context" 200)
    local compacted_tokens
    compacted_tokens=$(_filco_estimate_tokens "$compacted")
    if (( compacted_tokens <= 250 )); then  # Allow some margin
        echo -e "${C_GREEN}PASS${C_NC} (tokens: $compacted_tokens)"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (tokens: $compacted_tokens)"
        ((failed++))
    fi

    # Test 7: Rank chunks
    echo -n "Test 7: Rank chunks... "
    local ranked
    ranked=$(filco_rank_chunks "$test_context" "user service")
    if echo "$ranked" | jq -e '.[0].total_score' &>/dev/null; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 8: Token estimation
    echo -n "Test 8: Token estimation... "
    local tokens
    tokens=$(_filco_estimate_tokens "This is a test string with some words.")
    if (( tokens > 5 && tokens < 20 )); then
        echo -e "${C_GREEN}PASS${C_NC} (tokens: $tokens)"
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
    _context_filter_self_test
    exit $?
fi
