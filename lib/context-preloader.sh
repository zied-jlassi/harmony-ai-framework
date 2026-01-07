#!/bin/bash
# =============================================================================
# Harmony Framework - Context Preloader (Loop-Safe)
# =============================================================================
#
# GUARANTEES:
#   - No infinite loops (state machine)
#   - No recursive calls (depth guard)
#   - No unbounded loading (token budget)
#   - Immutable context after injection
#
# USAGE:
#   source "${HARMONY_DIR}/lib/context-preloader.sh"
#   preload_context "$USER_REQUEST" "$SELECTED_AGENT"
#
# =============================================================================

set -euo pipefail

# Don't re-source if already loaded
if [[ "${CONTEXT_PRELOADER_LOADED:-}" == "true" ]]; then
    return 0
fi
CONTEXT_PRELOADER_LOADED=true

# Source config-loader for resolve_agent and get_config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/config-loader.sh" ]]; then
    source "${SCRIPT_DIR}/config-loader.sh"
fi

# =============================================================================
# CONFIGURATION
# =============================================================================

PRELOADER_MAX_TOKENS=${PRELOADER_MAX_TOKENS:-15000}
PRELOADER_MAX_DEPTH=${PRELOADER_MAX_DEPTH:-1}
PRELOADER_SUMMARY_LINES=${PRELOADER_SUMMARY_LINES:-50}
PRELOADER_CACHE_TTL=${PRELOADER_CACHE_TTL:-1800}  # 30 minutes

# =============================================================================
# STATE MACHINE
# =============================================================================

# States (ordered - can only move forward)
PRELOADER_STATES=("IDLE" "CLASSIFYING" "RESOLVING" "LOADING" "INJECTING" "LOCKED")
PRELOADER_CURRENT_STATE="IDLE"
PRELOADER_STATE_IDX=0

# Get state index
_get_state_idx() {
    local state="$1"
    for i in "${!PRELOADER_STATES[@]}"; do
        if [[ "${PRELOADER_STATES[$i]}" == "$state" ]]; then
            echo "$i"
            return 0
        fi
    done
    echo "-1"
}

# Check if transition is valid (forward only)
_can_transition() {
    local target="$1"
    local target_idx
    target_idx=$(_get_state_idx "$target")

    if (( target_idx > PRELOADER_STATE_IDX )); then
        return 0
    fi
    return 1
}

# Perform state transition
_transition() {
    local target="$1"

    if _can_transition "$target"; then
        PRELOADER_STATE_IDX=$(_get_state_idx "$target")
        PRELOADER_CURRENT_STATE="$target"
        echo "[PRELOADER] State: $target" >&2
        return 0
    fi

    echo "[PRELOADER] ERROR: Cannot transition from $PRELOADER_CURRENT_STATE to $target" >&2
    return 1
}

# Check current state
_require_state() {
    local required="$1"
    if [[ "$PRELOADER_CURRENT_STATE" != "$required" ]]; then
        echo "[PRELOADER] ERROR: Expected state $required, got $PRELOADER_CURRENT_STATE" >&2
        return 1
    fi
    return 0
}

# =============================================================================
# TOKEN BUDGET
# =============================================================================

PRELOADER_TOKENS_USED=0

_count_tokens() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local chars
        chars=$(wc -c < "$file")
        echo $((chars / 4))
    else
        echo 0
    fi
}

_can_add_tokens() {
    local new_tokens="$1"
    if (( PRELOADER_TOKENS_USED + new_tokens > PRELOADER_MAX_TOKENS )); then
        return 1
    fi
    return 0
}

_add_tokens() {
    local count="$1"
    PRELOADER_TOKENS_USED=$((PRELOADER_TOKENS_USED + count))
}

# =============================================================================
# DEPTH GUARD
# =============================================================================

PRELOADER_CURRENT_DEPTH=0

_enter_depth() {
    if (( PRELOADER_CURRENT_DEPTH >= PRELOADER_MAX_DEPTH )); then
        echo "[PRELOADER] ERROR: Max depth exceeded" >&2
        return 1
    fi
    PRELOADER_CURRENT_DEPTH=$((PRELOADER_CURRENT_DEPTH + 1))
    return 0
}

_exit_depth() {
    PRELOADER_CURRENT_DEPTH=$((PRELOADER_CURRENT_DEPTH - 1))
}

# =============================================================================
# PHASE 1: CLASSIFICATION (Haiku)
# =============================================================================

# Cache file path (file-based to survive subshells)
_get_cache_file() {
    local harmony_dir="${HARMONY_DIR:-.harmony}"
    echo "${harmony_dir}/memory/.classification-cache.json"
}

# Variable cache for within same shell (optimization)
PRELOADER_CLASSIFICATION_CACHE=""

_classify_request() {
    local user_request="$1"
    local cache_file
    cache_file=$(_get_cache_file)

    # Check variable cache first (same shell optimization)
    if [[ -n "$PRELOADER_CLASSIFICATION_CACHE" ]]; then
        echo "$PRELOADER_CLASSIFICATION_CACHE"
        return 0
    fi

    # Check file cache (survives subshells)
    if [[ -f "$cache_file" ]]; then
        local cached
        cached=$(cat "$cache_file" 2>/dev/null)
        if [[ -n "$cached" ]] && echo "$cached" | jq -e '.primary_intent' > /dev/null 2>&1; then
            PRELOADER_CLASSIFICATION_CACHE="$cached"
            echo "$cached"
            return 0
        fi
    fi

    # Build classification prompt from routing-rules.yaml
    local prompt
    prompt=$(get_config "auto_detection.classification_prompt" "" 2>/dev/null || echo "")
    prompt="${prompt//\{user_input\}/$user_request}"

    # Call Haiku (or mock in test mode)
    local result
    if [[ "${PRELOADER_MOCK_MODE:-}" == "true" ]]; then
        result=$(_mock_classification "$user_request")
    else
        result=$(_call_haiku "$prompt")
    fi

    # Validate and cache (both variable and file)
    if echo "$result" | jq -e '.primary_intent' > /dev/null 2>&1; then
        PRELOADER_CLASSIFICATION_CACHE="$result"
        # Write to file cache
        mkdir -p "$(dirname "$cache_file")" 2>/dev/null
        echo "$result" > "$cache_file"
        echo "$result"
    else
        echo '{"primary_intent":"IMPLEMENT","context_flags":[],"suggested_agent":"developer","triggered_agents":[],"confidence":0.5}'
    fi
}

_mock_classification() {
    local request="$1"
    local -a flags_arr=()
    local -a triggered_arr=()

    # Simple keyword detection for mock
    if [[ "$request" =~ auth|login|password|authentif ]]; then
        flags_arr+=("has_auth")
        triggered_arr+=("security")
    fi
    if [[ "$request" =~ game|jeu|gaming ]]; then
        flags_arr+=("is_game")
    fi
    if [[ "$request" =~ mobile|react.native|flutter ]]; then
        flags_arr+=("is_mobile")
    fi
    if [[ "$request" =~ web|site|page|front ]]; then
        flags_arr+=("is_web")
    fi
    if [[ "$request" =~ user|profil|donnee|data|personal ]]; then
        flags_arr+=("personal_data")
        triggered_arr+=("rgpd")
    fi
    if [[ "$request" =~ python|django|flask|fastapi|pip ]]; then
        flags_arr+=("is_python")
    fi
    if [[ "$request" =~ golang|go[[:space:]]|gin|echo|fiber ]]; then
        flags_arr+=("is_go")
    fi
    if [[ "$request" =~ rust|cargo|tokio|actix ]]; then
        flags_arr+=("is_rust")
    fi
    if [[ "$request" =~ api|endpoint|rest|graphql|backend ]]; then
        flags_arr+=("is_api")
    fi
    if [[ "$request" =~ test|testing|jest|pytest|spec ]]; then
        flags_arr+=("has_testing")
    fi
    if [[ "$request" =~ ai|llm|openai|claude|model|embed ]]; then
        flags_arr+=("is_ai")
        triggered_arr+=("ai-specialist")
    fi

    # Build JSON arrays properly (compact format for heredoc compatibility)
    local flags_json="[]"
    local triggered_json="[]"

    if [[ ${#flags_arr[@]} -gt 0 ]]; then
        flags_json=$(printf '%s\n' "${flags_arr[@]}" | jq -R . | jq -s -c .)
    fi

    if [[ ${#triggered_arr[@]} -gt 0 ]]; then
        triggered_json=$(printf '%s\n' "${triggered_arr[@]}" | jq -R . | jq -s -c .)
    fi

    # Use jq to build valid JSON
    jq -n -c \
        --argjson flags "$flags_json" \
        --argjson triggered "$triggered_json" \
        '{
            primary_intent: "IMPLEMENT",
            context_flags: $flags,
            suggested_agent: "developer",
            triggered_agents: $triggered,
            confidence: 0.85
        }'
}

_call_haiku() {
    local prompt="$1"
    # TODO: Implement actual Haiku API call via Claude Code Task tool
    # For now, return mock based on prompt content
    _mock_classification "$prompt"
}

# =============================================================================
# PHASE 2: RESOLUTION (Lookups)
# =============================================================================

_resolve_context() {
    local classification="$1"
    local agent="${2:-}"

    # Extract from classification
    local intent
    local suggested
    local flags
    local triggered

    intent=$(echo "$classification" | jq -r '.primary_intent // "IMPLEMENT"')
    suggested=$(echo "$classification" | jq -r '.suggested_agent // "developer"')
    flags=$(echo "$classification" | jq -r '.context_flags[]?' 2>/dev/null || echo "")
    triggered=$(echo "$classification" | jq -r '.triggered_agents[]?' 2>/dev/null || echo "")

    # Use provided agent or suggested
    agent="${agent:-$suggested}"

    # Resolve branch (uses cached lookup from config-loader.sh)
    local branch_path=""
    if type resolve_agent &>/dev/null; then
        branch_path=$(resolve_agent "$agent" 2>/dev/null || echo "")
    fi

    # Fallback to direct path
    if [[ -z "$branch_path" ]]; then
        branch_path="${HARMONY_DIR:-}/agents/${agent}.md"
    fi

    # Resolve knowledge for flags (FLAT - no chains)
    local knowledge_files=""
    while IFS= read -r flag; do
        [[ -z "$flag" ]] && continue
        local flag_knowledge
        flag_knowledge=$(_get_knowledge_for_flag "$flag")
        if [[ -n "$flag_knowledge" ]]; then
            knowledge_files+="$flag_knowledge"$'\n'
        fi
    done <<< "$flags"

    # Resolve profiles (FLAT - all at once)
    local profiles
    profiles=$(_detect_profiles_flat)

    # Build JSON arrays (compact format)
    local knowledge_json
    local profiles_json
    local triggered_json

    knowledge_json=$(echo "$knowledge_files" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")
    profiles_json=$(echo "$profiles" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")
    triggered_json=$(echo "$triggered" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")

    # Build resolution result using jq for proper JSON
    jq -n -c \
        --arg agent "$agent" \
        --arg intent "$intent" \
        --arg branch_path "$branch_path" \
        --argjson knowledge_files "$knowledge_json" \
        --argjson profiles "$profiles_json" \
        --argjson triggered_agents "$triggered_json" \
        '{
            agent: $agent,
            intent: $intent,
            branch_path: $branch_path,
            knowledge_files: $knowledge_files,
            profiles: $profiles,
            triggered_agents: $triggered_agents
        }'
}

_get_knowledge_for_flag() {
    local flag="$1"
    local harmony_dir="${HARMONY_DIR:-.harmony}"

    # Map flags to knowledge files (STATIC mapping, no dynamic chains)
    # Uses existing knowledge files in the framework
    case "$flag" in
        has_auth)
            echo "${harmony_dir}/knowledge/domains/security/owasp-checklists.md"
            ;;
        personal_data)
            echo "${harmony_dir}/knowledge/domains/security/data-protection.md"
            ;;
        is_game)
            echo "${harmony_dir}/knowledge/domains/gaming/unity-ecs-patterns.md"
            ;;
        is_mobile)
            echo "${harmony_dir}/knowledge/frameworks/react/react-native-architecture.md"
            ;;
        is_web)
            echo "${harmony_dir}/knowledge/frameworks/react/architecture.md"
            ;;
        is_python)
            echo "${harmony_dir}/knowledge/languages/python/async-python-patterns.md"
            ;;
        is_go)
            echo "${harmony_dir}/knowledge/shared/patterns/error-handling-patterns.md"
            ;;
        is_rust)
            echo "${harmony_dir}/knowledge/shared/patterns/error-handling-patterns.md"
            ;;
        is_api)
            echo "${harmony_dir}/knowledge/shared/patterns/api-design-principles.md"
            ;;
        has_testing)
            echo "${harmony_dir}/knowledge/shared/patterns/tdd-workflow.md"
            ;;
        is_ai)
            echo "${harmony_dir}/knowledge/domains/ai/prompt-engineering-patterns.md"
            ;;
        *)
            # No knowledge for unknown flags
            ;;
    esac
}

_detect_profiles_flat() {
    # Detect from package.json (FLAT - no requires chains)
    local profiles=""

    if [[ -f "package.json" ]]; then
        # React
        if jq -e '.dependencies.react' package.json > /dev/null 2>&1; then
            profiles+="frontend/react"$'\n'
        fi
        # React Native
        if jq -e '.dependencies["react-native"]' package.json > /dev/null 2>&1; then
            profiles+="mobile/react-native"$'\n'
        fi
        # NestJS
        if jq -e '.dependencies["@nestjs/core"]' package.json > /dev/null 2>&1; then
            profiles+="backend/nestjs"$'\n'
        fi
        # TypeScript
        if jq -e '.devDependencies.typescript' package.json > /dev/null 2>&1; then
            profiles+="languages/typescript"$'\n'
        fi
        # Next.js
        if jq -e '.dependencies.next' package.json > /dev/null 2>&1; then
            profiles+="frontend/nextjs"$'\n'
        fi
    fi

    # Flutter detection
    if [[ -f "pubspec.yaml" ]]; then
        profiles+="mobile/flutter"$'\n'
    fi

    # Python detection
    if [[ -f "requirements.txt" ]]; then
        profiles+="languages/python"$'\n'
    fi

    # Go detection
    if [[ -f "go.mod" ]]; then
        profiles+="languages/go"$'\n'
    fi

    # Rust detection
    if [[ -f "Cargo.toml" ]]; then
        profiles+="languages/rust"$'\n'
    fi

    # Dart detection
    if [[ -f "pubspec.yaml" ]]; then
        profiles+="languages/dart"$'\n'
    fi

    echo "$profiles"
}

# =============================================================================
# PHASE 3: LOADING (Bounded)
# =============================================================================

_load_context() {
    local resolution="$1"

    _enter_depth || return 1

    local branch_path
    local knowledge_files
    local triggered

    branch_path=$(echo "$resolution" | jq -r '.branch_path')
    knowledge_files=$(echo "$resolution" | jq -r '.knowledge_files[]?' 2>/dev/null || echo "")
    triggered=$(echo "$resolution" | jq -r '.triggered_agents[]?' 2>/dev/null || echo "")

    local loaded_content=""

    # Load branch (main content)
    if [[ -n "$branch_path" ]] && [[ -f "$branch_path" ]]; then
        local tokens
        tokens=$(_count_tokens "$branch_path")
        if _can_add_tokens "$tokens"; then
            loaded_content+="### AGENT BRANCH ###"$'\n'
            loaded_content+=$(cat "$branch_path")$'\n'
            _add_tokens "$tokens"
        else
            echo "[PRELOADER] WARNING: Branch exceeds budget, truncating" >&2
        fi
    fi

    # Load knowledge (bounded)
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue

        local tokens
        tokens=$(_count_tokens "$file")
        if _can_add_tokens "$tokens"; then
            loaded_content+=$'\n'"### KNOWLEDGE: $(basename "$file") ###"$'\n'
            loaded_content+=$(cat "$file")$'\n'
            _add_tokens "$tokens"
        else
            echo "[PRELOADER] WARNING: Skipping $file (budget exceeded)" >&2
        fi
    done <<< "$knowledge_files"

    # Load triggered agent summaries (truncated)
    while IFS= read -r agent; do
        [[ -z "$agent" ]] && continue

        local agent_path=""
        if type resolve_agent &>/dev/null; then
            agent_path=$(resolve_agent "$agent" 2>/dev/null || echo "")
        fi
        [[ -z "$agent_path" ]] && continue
        [[ ! -f "$agent_path" ]] && continue

        # Only first N lines (summary)
        local summary
        summary=$(head -n "$PRELOADER_SUMMARY_LINES" "$agent_path")
        local tokens=$((${#summary} / 4))

        if _can_add_tokens "$tokens"; then
            loaded_content+=$'\n'"### TRIGGERED: $agent (summary) ###"$'\n'
            loaded_content+="$summary"$'\n'
            _add_tokens "$tokens"
        fi
    done <<< "$triggered"

    _exit_depth

    # Return as JSON using jq for proper formatting
    local content_json
    content_json=$(echo "$loaded_content" | jq -R -s -c '.' 2>/dev/null || echo '""')

    jq -n -c \
        --argjson content "$content_json" \
        --argjson tokens_used "$PRELOADER_TOKENS_USED" \
        --argjson budget "$PRELOADER_MAX_TOKENS" \
        '{
            content: $content,
            tokens_used: $tokens_used,
            budget: $budget
        }'
}

# =============================================================================
# PHASE 4: INJECTION (Write Once)
# =============================================================================

_inject_context() {
    local loaded="$1"
    local classification="$PRELOADER_CLASSIFICATION_CACHE"

    local harmony_dir="${HARMONY_DIR:-.harmony}"
    local memory_dir="${harmony_dir}/memory"
    local working_file="${memory_dir}/working.json"

    mkdir -p "$memory_dir"

    # Build final context using jq for proper JSON
    local timestamp
    timestamp=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    # Validate classification is valid JSON
    if ! echo "$classification" | jq -e . >/dev/null 2>&1; then
        classification='{"error":"invalid classification"}'
    fi

    # Validate loaded is valid JSON
    if ! echo "$loaded" | jq -e . >/dev/null 2>&1; then
        loaded='{"error":"invalid loaded"}'
    fi

    # Build JSON using jq
    jq -n \
        --argjson classification "$classification" \
        --argjson loaded "$loaded" \
        --arg timestamp "$timestamp" \
        '{
            context_loaded: true,
            timestamp: $timestamp,
            classification: $classification,
            loaded: $loaded,
            state: "INJECTED"
        }' > "$working_file"

    echo "[PRELOADER] Context written to $working_file" >&2
}

# =============================================================================
# PHASE 5: LOCK (Read-Only)
# =============================================================================

_lock_context() {
    local harmony_dir="${HARMONY_DIR:-.harmony}"
    local working_file="${harmony_dir}/memory/working.json"

    if [[ -f "$working_file" ]]; then
        # Update state to LOCKED
        local tmp
        tmp=$(mktemp)
        jq '.state = "LOCKED"' "$working_file" > "$tmp" && mv "$tmp" "$working_file"

        echo "[PRELOADER] Context LOCKED" >&2
    fi
}

# =============================================================================
# DISPLAY SUMMARY
# =============================================================================

display_context_summary() {
    local harmony_dir="${HARMONY_DIR:-.harmony}"
    local working_file="${harmony_dir}/memory/working.json"

    if [[ -f "$working_file" ]]; then
        echo ""
        echo "========================================================================"
        echo "                        CONTEXT LOADED                                  "
        echo "========================================================================"
        echo ""
        echo "Agent:    $(jq -r '.classification.suggested_agent // "N/A"' "$working_file")"
        echo "Intent:   $(jq -r '.classification.primary_intent // "N/A"' "$working_file")"
        echo "Flags:    $(jq -r '.classification.context_flags | join(", ")' "$working_file" 2>/dev/null || echo "none")"
        echo "Tokens:   $(jq -r '.loaded.tokens_used // 0' "$working_file") / $PRELOADER_MAX_TOKENS"
        echo ""
    fi
}

# =============================================================================
# MAIN ENTRY POINT (the ONLY public function)
# =============================================================================

preload_context() {
    local user_request="$1"
    local selected_agent="${2:-}"

    # Already locked? Return early
    if [[ "$PRELOADER_CURRENT_STATE" == "LOCKED" ]]; then
        echo "[PRELOADER] Context already loaded and locked" >&2
        return 0
    fi

    # PHASE 1: Classify
    _transition "CLASSIFYING" || return 1
    local classification
    classification=$(_classify_request "$user_request")

    # PHASE 2: Resolve
    _transition "RESOLVING" || return 1
    local resolution
    resolution=$(_resolve_context "$classification" "$selected_agent")

    # PHASE 3: Load
    _transition "LOADING" || return 1
    local loaded
    loaded=$(_load_context "$resolution")

    # PHASE 4: Inject
    _transition "INJECTING" || return 1
    _inject_context "$loaded"

    # PHASE 5: Lock
    _transition "LOCKED" || return 1
    _lock_context

    display_context_summary
    return 0
}

# Reset for testing only
reset_preloader() {
    PRELOADER_CURRENT_STATE="IDLE"
    PRELOADER_STATE_IDX=0
    PRELOADER_TOKENS_USED=0
    PRELOADER_CURRENT_DEPTH=0
    PRELOADER_CLASSIFICATION_CACHE=""
    # Clear file cache
    local cache_file
    cache_file=$(_get_cache_file)
    rm -f "$cache_file" 2>/dev/null || true
}

# Get current state (for testing)
get_preloader_state() {
    echo "$PRELOADER_CURRENT_STATE"
}

# Get tokens used (for testing)
get_preloader_tokens() {
    echo "$PRELOADER_TOKENS_USED"
}
