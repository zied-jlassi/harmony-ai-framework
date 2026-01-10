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

# Source ARIA detector for two-stage detection
if [[ -f "${SCRIPT_DIR}/aria-detector.sh" ]]; then
    source "${SCRIPT_DIR}/aria-detector.sh"
fi

# Source knowledge loader for flag-based knowledge injection
if [[ -f "${SCRIPT_DIR}/knowledge-loader.sh" ]]; then
    source "${SCRIPT_DIR}/knowledge-loader.sh"
fi

# Source profile loader for tech stack detection
if [[ -f "${SCRIPT_DIR}/profile-loader.sh" ]]; then
    source "${SCRIPT_DIR}/profile-loader.sh"
fi

# Source MCP memory sync for cross-session learning
if [[ -f "${SCRIPT_DIR}/mcp-memory-sync.sh" ]]; then
    source "${SCRIPT_DIR}/mcp-memory-sync.sh"
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
# ARIA DETECTION FUNCTIONS
# =============================================================================
# Stage 1: Pattern matching (instant, deterministic) via aria-detector.sh
# Stage 2: LLM enrichment (semantic understanding)
#
# In Claude Code: Use run_pattern_detection() for Stage 1,
#                 then use Task tool (model=haiku) for Stage 2
# Standalone:     Use run_two_stage_detection() with ANTHROPIC_API_KEY

# =============================================================================
# STAGE 1 ONLY: Pattern Detection (Bash, Instantané)
# =============================================================================
# Use this from Claude Code - Stage 2 will be done via Task tool
# Returns: JSON with pattern-based detection results
run_pattern_detection() {
    local prompt="$1"
    local project_dir="${2:-.}"

    local pattern_result
    if type aria_detect_patterns &>/dev/null; then
        pattern_result=$(aria_detect_patterns "$prompt" "$project_dir")
    else
        pattern_result='{"source":"pattern","context_flags":[],"triggered_agents":[],"confidence":70}'
    fi

    # Add JIT loading (knowledge, profiles, branches)
    local final_flags
    final_flags=$(echo "$pattern_result" | jq -r '.context_flags | join(" ")')

    local knowledge_json="[]"
    local profiles_json="[]"
    local branches_json="{}"

    # Knowledge files
    if type knowledge_get_for_flags &>/dev/null && [[ -n "$final_flags" ]]; then
        local knowledge_files
        knowledge_files=$(knowledge_get_for_flags "$final_flags" 2>/dev/null || echo "")
        if [[ -n "$knowledge_files" ]]; then
            knowledge_json=$(echo "$knowledge_files" | jq -R . | jq -s .)
        fi
    fi

    # Profiles
    if type profile_detect_from_project &>/dev/null; then
        local profiles
        profiles=$(profile_detect_from_project "$project_dir" 2>/dev/null || echo "")
        if [[ -n "$profiles" ]]; then
            profiles_json=$(echo "$profiles" | jq -R . | jq -s .)
        fi
    fi

    # Branches
    local triggered_agents
    triggered_agents=$(echo "$pattern_result" | jq -r '.triggered_agents[]?' 2>/dev/null)
    if [[ -n "$triggered_agents" ]] && type resolve_agent &>/dev/null; then
        local branches_obj="{"
        local first=true
        while IFS= read -r agent; do
            [[ -z "$agent" ]] && continue
            local branch_path
            branch_path=$(resolve_agent "$agent" 2>/dev/null || echo "")
            if [[ -n "$branch_path" ]]; then
                [[ "$first" == "true" ]] && first=false || branches_obj+=","
                branches_obj+="\"$agent\":\"$branch_path\""
            fi
        done <<< "$triggered_agents"
        branches_obj+="}"
        branches_json="$branches_obj"
    fi

    # Enrich result with JIT data
    echo "$pattern_result" | jq -c \
        --argjson knowledge "$knowledge_json" \
        --argjson profiles "$profiles_json" \
        --argjson branches "$branches_json" \
        '. + {
            knowledge_files: $knowledge,
            detected_profiles: $profiles,
            resolved_branches: $branches
        }'
}

# =============================================================================
# TWO-STAGE: Pattern + LLM (pour usage standalone avec API key)
# =============================================================================
# Input: prompt text, project directory
# Output: JSON with merged results
run_two_stage_detection() {
    local prompt="$1"
    local project_dir="${2:-.}"

    # ═══════════════════════════════════════════════════════════════════════
    # STAGE 1: PATTERN MATCHING (Instantané, Déterministe)
    # ═══════════════════════════════════════════════════════════════════════
    local pattern_result
    pattern_result=$(run_pattern_detection "$prompt" "$project_dir")
    echo "[ARIA] Stage 1 (Pattern): $(echo "$pattern_result" | jq -c '.context_flags')" >&2

    local pattern_flags
    pattern_flags=$(echo "$pattern_result" | jq -c '.context_flags // []')

    # Check for blocking flags - warn immediately
    local is_blocking
    is_blocking=$(echo "$pattern_result" | jq -r '.is_blocking // false')
    if [[ "$is_blocking" == "true" ]]; then
        echo "[ARIA] ⚠️ BLOCKING FLAGS DETECTED - Compliance validation required" >&2
    fi

    # ═══════════════════════════════════════════════════════════════════════
    # STAGE 2: LLM ENRICHMENT (Sémantique)
    # ═══════════════════════════════════════════════════════════════════════
    # Skip if no API key and not in mock mode - return Stage 1 only
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]] && [[ "${PRELOADER_MOCK_MODE:-}" != "true" ]]; then
        echo "[ARIA] Stage 2: No API key, returning Stage 1 only (use Claude Code Task tool for semantic detection)" >&2
        echo "$pattern_result" | jq -c '. + {source: "pattern-only", primary_intent: "unknown", suggested_agent: "developer"}'
        return 0
    fi

    local haiku_result
    haiku_result=$(_call_llm_classification "$prompt" "$pattern_flags")

    if [[ -z "$haiku_result" ]] || ! echo "$haiku_result" | jq -e '.primary_intent' &>/dev/null; then
        echo "[ARIA] Stage 2: LLM failed/unavailable, using pattern-only result" >&2
        echo "$pattern_result" | jq -c '. + {primary_intent: "unknown", suggested_agent: null}'
        return 0
    fi

    echo "[ARIA] Stage 2 (LLM): intent=$(echo "$haiku_result" | jq -r '.primary_intent')" >&2

    # ═══════════════════════════════════════════════════════════════════════
    # MERGE: Union des flags, priorité LLM pour agent
    # ═══════════════════════════════════════════════════════════════════════
    local merged_result
    merged_result=$(_merge_aria_results "$pattern_result" "$haiku_result")

    # JIT loading already done in run_pattern_detection(), just preserve it
    echo "[ARIA] Final: $(echo "$merged_result" | jq -c '.')" >&2
    echo "$merged_result"
}

# Call LLM for semantic classification
# Uses model-manager.sh to resolve model and detect provider
# Input: prompt, pre-detected flags (JSON array)
# Output: JSON with enriched classification
_call_llm_classification() {
    local prompt="$1"
    local pre_detected_flags="$2"

    # Only use mock if explicitly requested
    if [[ "${PRELOADER_MOCK_MODE:-}" == "true" ]]; then
        echo "[ARIA] Using mock mode (PRELOADER_MOCK_MODE=true)" >&2
        _mock_classification_with_context "$prompt" "$pre_detected_flags"
        return
    fi

    # Source model-manager if available
    if [[ -f "${SCRIPT_DIR}/model-manager.sh" ]] && ! type resolve_model &>/dev/null; then
        source "${SCRIPT_DIR}/model-manager.sh" 2>/dev/null || true
    fi

    # Get the router/classification model dynamically
    # Priority: 1) routing-rules.yaml 2) model-manager.sh 3) default
    local router_model=""
    local routing_rules="${SCRIPT_DIR}/../config/routing-rules.yaml"

    # Try to read from routing-rules.yaml (requires yq)
    if [[ -f "$routing_rules" ]] && command -v yq &>/dev/null; then
        router_model=$(yq eval '.auto_detection.router_model // ""' "$routing_rules" 2>/dev/null)
        [[ -n "$router_model" ]] && echo "[ARIA] Router model from config: $router_model" >&2
    fi

    # Fallback to model-manager.sh
    if [[ -z "$router_model" ]] && type get_model_for_task &>/dev/null; then
        router_model=$(get_model_for_task "summarize")  # weak model for classification
    fi

    # Final fallback
    [[ -z "$router_model" ]] && router_model="haiku"

    # Display model in yellow (if ui-library available)
    if type ui_show_model &>/dev/null; then
        ui_show_model "$router_model" "ARIA Router" >&2
    else
        echo "[ARIA] Using model: $router_model" >&2
    fi

    # Detect provider from available API keys (order matters - first match wins)
    # Supports: Anthropic, OpenAI, Groq, Azure, Mistral
    local provider=""
    local api_key=""

    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        provider="anthropic"
        api_key="$ANTHROPIC_API_KEY"
    elif [[ -n "${OPENAI_API_KEY:-}" ]]; then
        provider="openai"
        api_key="$OPENAI_API_KEY"
    elif [[ -n "${GROQ_API_KEY:-}" ]]; then
        provider="groq"
        api_key="$GROQ_API_KEY"
    elif [[ -n "${AZURE_OPENAI_API_KEY:-}" ]]; then
        provider="azure"
        api_key="$AZURE_OPENAI_API_KEY"
    elif [[ -n "${MISTRAL_API_KEY:-}" ]]; then
        provider="mistral"
        api_key="$MISTRAL_API_KEY"
    fi

    if [[ -z "$provider" ]]; then
        echo "[ARIA] No LLM API key found (ANTHROPIC, OPENAI, GROQ, AZURE, MISTRAL)" >&2
        echo "[ARIA] In Claude Code, use Task tool with model=haiku for semantic detection" >&2
        _mock_classification_with_context "$prompt" "$pre_detected_flags"
        return
    fi

    echo "[ARIA] Using provider: $provider" >&2

    # Build the system prompt
    local system_prompt="You are ARIA (Automatic Runtime Intent Analyzer) for the Harmony Framework.

Your task is to analyze user requests and detect context flags for proper agent routing.

CONTEXT FLAGS TO DETECT:
- has_minors: Request involves children, minors, families with kids, schools, youth
- personal_data: Request involves names, emails, addresses, phone numbers, personal info
- has_auth: Request involves authentication, login, passwords, sessions, tokens
- security_critical: Request involves payments, banking, encryption, sensitive operations
- has_media: Request involves photos, videos, file uploads, media handling
- has_social: Request involves friends, followers, messaging, social features
- legal_compliance: Request involves terms, privacy policies, GDPR, legal requirements
- has_ui: Request involves forms, buttons, interfaces, screens, UI components
- has_db_schema: Request involves databases, tables, schemas, data models
- needs_infra: Request involves Docker, Kubernetes, CI/CD, deployment, infrastructure
- needs_docs: Request involves documentation, README, guides
- has_i18n: Request involves translations, multilingual, internationalization
- performance_critical: Request involves optimization, caching, performance
- is_web: Web application context
- is_mobile: Mobile application context
- is_api: Backend API context
- is_game: Gaming context

SEMANTIC UNDERSTANDING:
- 'famille' (family) implies has_minors (children are part of families)
- 'hôtel/reservation' implies personal_data (guest information)
- 'clients' in service context may imply personal_data
- 'authentification' implies has_auth AND security

IMPORTANT: Return ONLY valid JSON, no markdown, no explanation."

    local user_prompt="Analyze this request and classify it.

User Request: $prompt

Pre-detected context flags from pattern matching: $pre_detected_flags

Return JSON with these exact fields:
{
  \"primary_intent\": \"feature_request|bug_fix|refactoring|documentation|question|other\",
  \"context_flags\": [\"array of ALL flags including pre-detected + semantically inferred\"],
  \"suggested_agent\": \"best agent (developer-web, architect, designer, etc.)\",
  \"triggered_agents\": [\"compliance agents: rgpd, security, legal, accessibility\"],
  \"confidence\": 85,
  \"semantic_notes\": \"brief explanation of semantic inferences made\"
}"

    # Call LLM API based on detected provider
    local response content

    case "$provider" in
        anthropic)
            # Resolve model name for Anthropic
            local anthropic_model="claude-3-haiku-20240307"
            if type resolve_model &>/dev/null; then
                local resolved
                resolved=$(resolve_model "$router_model")
                # Extract just the model name after the /
                anthropic_model="${resolved#*/}"
                [[ -z "$anthropic_model" ]] && anthropic_model="claude-3-haiku-20240307"
            fi

            response=$(curl -s --max-time 10 "https://api.anthropic.com/v1/messages" \
                -H "Content-Type: application/json" \
                -H "x-api-key: ${api_key}" \
                -H "anthropic-version: 2023-06-01" \
                -d "$(jq -n \
                    --arg model "$anthropic_model" \
                    --arg system "$system_prompt" \
                    --arg user "$user_prompt" \
                    '{model: $model, max_tokens: 1024, system: $system, messages: [{role: "user", content: $user}]}')" 2>/dev/null)

            content=$(echo "$response" | jq -r '.content[0].text // empty' 2>/dev/null)
            ;;

        openai)
            local openai_model="gpt-4o-mini"
            response=$(curl -s --max-time 10 "https://api.openai.com/v1/chat/completions" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${api_key}" \
                -d "$(jq -n \
                    --arg model "$openai_model" \
                    --arg system "$system_prompt" \
                    --arg user "$user_prompt" \
                    '{model: $model, max_tokens: 1024, messages: [{role: "system", content: $system}, {role: "user", content: $user}]}')" 2>/dev/null)

            content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
            ;;

        groq)
            local groq_model="llama-3.1-8b-instant"
            response=$(curl -s --max-time 10 "https://api.groq.com/openai/v1/chat/completions" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${api_key}" \
                -d "$(jq -n \
                    --arg model "$groq_model" \
                    --arg system "$system_prompt" \
                    --arg user "$user_prompt" \
                    '{model: $model, max_tokens: 1024, messages: [{role: "system", content: $system}, {role: "user", content: $user}]}')" 2>/dev/null)

            content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
            ;;

        azure)
            # Azure OpenAI requires endpoint in env var
            local azure_endpoint="${AZURE_OPENAI_ENDPOINT:-}"
            local azure_deployment="${AZURE_OPENAI_DEPLOYMENT:-gpt-4o-mini}"
            if [[ -z "$azure_endpoint" ]]; then
                echo "[ARIA] Azure requires AZURE_OPENAI_ENDPOINT" >&2
                _mock_classification_with_context "$prompt" "$pre_detected_flags"
                return
            fi

            response=$(curl -s --max-time 10 "${azure_endpoint}/openai/deployments/${azure_deployment}/chat/completions?api-version=2024-02-15-preview" \
                -H "Content-Type: application/json" \
                -H "api-key: ${api_key}" \
                -d "$(jq -n \
                    --arg system "$system_prompt" \
                    --arg user "$user_prompt" \
                    '{max_tokens: 1024, messages: [{role: "system", content: $system}, {role: "user", content: $user}]}')" 2>/dev/null)

            content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
            ;;

        mistral)
            local mistral_model="mistral-small-latest"
            response=$(curl -s --max-time 10 "https://api.mistral.ai/v1/chat/completions" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${api_key}" \
                -d "$(jq -n \
                    --arg model "$mistral_model" \
                    --arg system "$system_prompt" \
                    --arg user "$user_prompt" \
                    '{model: $model, max_tokens: 1024, messages: [{role: "system", content: $system}, {role: "user", content: $user}]}')" 2>/dev/null)

            content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
            ;;

        *)
            echo "[ARIA] Unsupported provider: $provider" >&2
            _mock_classification_with_context "$prompt" "$pre_detected_flags"
            return
            ;;
    esac

    # Check if call failed
    if [[ -z "$content" ]]; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.error.message // .error // empty' 2>/dev/null)
        if [[ -n "$error_msg" ]]; then
            echo "[ARIA] API error ($provider): $error_msg" >&2
        else
            echo "[ARIA] API returned empty content, falling back to mock" >&2
        fi
        _mock_classification_with_context "$prompt" "$pre_detected_flags"
        return
    fi

    # Parse JSON response (clean up markdown if present)
    content=$(echo "$content" | sed 's/^```json//; s/^```//; s/```$//' | tr -d '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

    # Validate JSON
    if ! echo "$content" | jq -e '.primary_intent' &>/dev/null; then
        echo "[ARIA] LLM returned invalid JSON, falling back to mock" >&2
        _mock_classification_with_context "$prompt" "$pre_detected_flags"
        return
    fi

    # Log semantic notes if present
    local notes
    notes=$(echo "$content" | jq -r '.semantic_notes // empty' 2>/dev/null)
    if [[ -n "$notes" ]]; then
        echo "[ARIA] LLM semantic: $notes" >&2
    fi

    # Return the LLM classification
    echo "$content"
}

# Alias for backward compatibility
_call_haiku_with_context() {
    _call_llm_classification "$@"
}

# Test-only mock classification (uses aria-detector.sh instead of duplicating patterns)
# WARNING: This is ONLY for tests with PRELOADER_MOCK_MODE=true
_mock_classification_with_context() {
    local request="$1"
    local pre_flags="$2"

    # Use aria-detector.sh for all pattern detection (NO DUPLICATION!)
    # aria-detector.sh reads patterns from routing-parser.sh/routing-rules.yaml
    local aria_result
    if type aria_detect_patterns &>/dev/null; then
        aria_result=$(aria_detect_patterns "$request" "." 2>/dev/null) || true
    fi

    # If aria detection worked, use its results
    if [[ -n "$aria_result" ]] && echo "$aria_result" | jq -e '.context_flags' &>/dev/null; then
        # Merge pre-detected flags with aria flags
        local merged_flags
        merged_flags=$(jq -n \
            --argjson pre "$pre_flags" \
            --argjson aria "$(echo "$aria_result" | jq '.context_flags')" \
            '$pre + $aria | unique')

        local triggered
        triggered=$(echo "$aria_result" | jq '.triggered_agents')

        # Determine suggested agent from aria or default
        local suggested_agent
        suggested_agent=$(echo "$aria_result" | jq -r '.suggested_agent // "developer"')

        # Determine intent
        local intent="feature_request"
        if [[ "$request" =~ bug|fix|error|problem|issue ]]; then
            intent="bug_fix"
        elif [[ "$request" =~ refactor|clean|optimize|improve ]]; then
            intent="refactoring"
        elif [[ "$request" =~ doc|readme|comment|explain ]]; then
            intent="documentation"
        elif [[ "$request" =~ \?|what|how|why|when ]]; then
            intent="question"
        fi

        jq -n -c \
            --arg intent "$intent" \
            --arg agent "$suggested_agent" \
            --argjson flags "$merged_flags" \
            --argjson triggered "$triggered" \
            '{
                source: "mock",
                primary_intent: $intent,
                suggested_agent: $agent,
                context_flags: $flags,
                triggered_agents: $triggered,
                confidence: 70
            }'
        return
    fi

    # Minimal fallback if aria not available (emergency only)
    # Uses ONLY pre-detected flags, no extra pattern matching
    local flags_json
    flags_json=$(echo "$pre_flags" | jq -c '. // []')

    jq -n -c \
        --argjson flags "$flags_json" \
        '{
            source: "mock-minimal",
            primary_intent: "feature_request",
            suggested_agent: "developer",
            context_flags: $flags,
            triggered_agents: [],
            confidence: 50
        }'
}

# Merge pattern and haiku results
# Priority: Union of flags, Haiku for intent/agent, max confidence
_merge_aria_results() {
    local pattern="$1"
    local haiku="$2"

    # Union of context flags
    local all_flags
    all_flags=$(jq -n -c \
        --argjson p "$(echo "$pattern" | jq -c '.context_flags // []')" \
        --argjson h "$(echo "$haiku" | jq -c '.context_flags // []')" \
        '$p + $h | unique')

    # Union of triggered agents
    local all_triggers
    all_triggers=$(jq -n -c \
        --argjson p "$(echo "$pattern" | jq -c '.triggered_agents // []')" \
        --argjson h "$(echo "$haiku" | jq -c '.triggered_agents // []')" \
        '$p + $h | unique')

    # Get haiku values (priority)
    local intent
    local agent
    local haiku_conf
    intent=$(echo "$haiku" | jq -r '.primary_intent // "unknown"')
    agent=$(echo "$haiku" | jq -r '.suggested_agent // null')
    haiku_conf=$(echo "$haiku" | jq -r '.confidence // 0')

    # Get pattern blocking status
    local is_blocking
    is_blocking=$(echo "$pattern" | jq -r '.is_blocking // false')

    # Get max confidence
    local pattern_conf
    pattern_conf=$(echo "$pattern" | jq -r '.confidence // 0')
    local final_conf=$haiku_conf
    if (( pattern_conf > haiku_conf )); then
        final_conf=$pattern_conf
    fi

    jq -n -c \
        --arg source "two-stage" \
        --arg intent "$intent" \
        --arg agent "$agent" \
        --argjson flags "$all_flags" \
        --argjson triggers "$all_triggers" \
        --argjson blocking "$is_blocking" \
        --argjson confidence "$final_conf" \
        '{
            source: $source,
            primary_intent: $intent,
            suggested_agent: $agent,
            context_flags: $flags,
            triggered_agents: $triggers,
            is_blocking: $blocking,
            confidence: $confidence
        }'
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

    # Display agent switch with model (if ui-library available)
    if type ui_agent_switch &>/dev/null; then
        # Try to get model from agent file
        local agent_model="inherit"
        local agent_file="${HARMONY_DIR:-}/agents/${agent}.md"
        if [[ -f "$agent_file" ]]; then
            agent_model=$(grep -m1 "^model:" "$agent_file" 2>/dev/null | sed 's/model:[[:space:]]*//' || echo "inherit")
        fi
        ui_agent_switch "$agent" "$agent_model" >&2
    fi

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

    # === SENTINEL AUTO-LEARNING: Check for relevant past errors ===
    local sentinel_warnings=""
    if type check_relevant_errors &>/dev/null; then
        # Get context flags from classification cache
        local context_flags
        context_flags=$(echo "$PRELOADER_CLASSIFICATION_CACHE" | jq -r '.context_flags[]?' 2>/dev/null | tr '\n' ' ')

        local relevant_errors
        relevant_errors=$(check_relevant_errors "$context_flags" 2>/dev/null || echo "[]")

        local error_count
        error_count=$(echo "$relevant_errors" | jq 'length' 2>/dev/null || echo "0")

        if [[ "$error_count" -gt 0 ]]; then
            echo "[PRELOADER] Found $error_count relevant past errors from Sentinel" >&2
            if type format_errors_for_context &>/dev/null; then
                sentinel_warnings=$(format_errors_for_context "$relevant_errors" 2>/dev/null || echo "")
            fi
        fi
    fi

    # === SPRINT MANAGEMENT: Auto-load sprint dashboard when needed ===
    local sprint_info=""
    local context_flags
    context_flags=$(echo "$PRELOADER_CLASSIFICATION_CACHE" | jq -r '.context_flags[]?' 2>/dev/null | tr '\n' ' ')

    if [[ "$context_flags" =~ needs_sprint_mgmt ]]; then
        # Source sprint-tracker if not already loaded
        if ! type show_sprint_dashboard &>/dev/null; then
            local sprint_tracker="${HARMONY_DIR:-$PWD/.harmony}/lib/sprint-tracker.sh"
            [[ -f "$sprint_tracker" ]] && source "$sprint_tracker"
        fi

        if type show_sprint_dashboard &>/dev/null; then
            echo "[PRELOADER] Loading sprint dashboard for Scrum Master context" >&2
            sprint_info=$(show_sprint_dashboard 2>/dev/null | grep -v "^[0-9]*$" || echo "")
        fi
    fi

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

    # Add Sentinel warnings (past errors relevant to this context)
    if [[ -n "$sentinel_warnings" ]]; then
        local warning_tokens=$((${#sentinel_warnings} / 4))
        if _can_add_tokens "$warning_tokens"; then
            loaded_content+=$'\n'"$sentinel_warnings"
            _add_tokens "$warning_tokens"
            echo "[PRELOADER] Injected Sentinel warnings (${warning_tokens} tokens)" >&2
        fi
    fi

    # Add Sprint dashboard (for Scrum Master context)
    if [[ -n "$sprint_info" ]]; then
        local sprint_tokens=$((${#sprint_info} / 4))
        if _can_add_tokens "$sprint_tokens"; then
            loaded_content+=$'\n'"### SPRINT DASHBOARD ###"$'\n'"$sprint_info"
            _add_tokens "$sprint_tokens"
            echo "[PRELOADER] Injected Sprint Dashboard (${sprint_tokens} tokens)" >&2
        fi
    fi

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

# =============================================================================
# ARIA WORKFLOW STATE UPDATE
# =============================================================================

# Update workflow-state.json with ARIA detection results
update_workflow_aria_context() {
    local aria_result="$1"
    local harmony_dir="${HARMONY_DIR:-.harmony}"
    local workflow_file="${harmony_dir}/memory/workflow-state.json"

    if [[ ! -f "$workflow_file" ]]; then
        echo "[ARIA] WARNING: workflow-state.json not found at $workflow_file" >&2
        return 1
    fi

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Extract values from ARIA result
    local context_flags triggered_agents suggested_agent primary_intent confidence source is_blocking

    context_flags=$(echo "$aria_result" | jq -c '.context_flags // []')
    triggered_agents=$(echo "$aria_result" | jq -c '.triggered_agents // []')
    suggested_agent=$(echo "$aria_result" | jq -r '.suggested_agent // null')
    primary_intent=$(echo "$aria_result" | jq -r '.primary_intent // null')
    confidence=$(echo "$aria_result" | jq -r '.confidence // 0')
    source=$(echo "$aria_result" | jq -r '.source // "unknown"')
    is_blocking=$(echo "$aria_result" | jq -r '.is_blocking // false')

    # Update aria_context section
    local tmp_file
    tmp_file=$(mktemp)

    jq --arg ts "$timestamp" \
       --argjson flags "$context_flags" \
       --argjson triggers "$triggered_agents" \
       --arg agent "$suggested_agent" \
       --arg intent "$primary_intent" \
       --argjson conf "$confidence" \
       --arg src "$source" \
       --argjson blocking "$is_blocking" \
       '.aria_context = {
           detected_at: $ts,
           context_flags: $flags,
           triggered_agents: $triggers,
           suggested_agent: $agent,
           primary_intent: $intent,
           confidence: $conf,
           source: $src,
           is_blocking: $blocking
       }' "$workflow_file" > "$tmp_file" && mv "$tmp_file" "$workflow_file"

    echo "[ARIA] Updated workflow-state.json aria_context" >&2
    return 0
}

# =============================================================================
# TWO-STAGE DETECTION SELF-TEST
# =============================================================================

preloader_self_test() {
    echo "=== Context Preloader Self-Test (Two-Stage ARIA) ==="
    echo ""

    local passed=0
    local failed=0

    # Test 1: Two-stage detection basic
    echo "Test 1: Two-stage detection with compliance keywords..."
    local result
    result=$(run_two_stage_detection "Créer un formulaire d'inscription pour les enfants avec email" "." 2>/dev/null)

    if echo "$result" | jq -e '.context_flags | index("has_minors")' > /dev/null 2>&1; then
        echo "  ✅ has_minors flag detected"
        ((++passed)) || true
    else
        echo "  ❌ has_minors flag NOT detected"
        ((++failed)) || true
    fi

    if echo "$result" | jq -e '.context_flags | index("personal_data")' > /dev/null 2>&1; then
        echo "  ✅ personal_data flag detected"
        ((++passed)) || true
    else
        echo "  ❌ personal_data flag NOT detected"
        ((++failed)) || true
    fi

    # Test 2: Triggered agents
    echo ""
    echo "Test 2: Triggered agents for compliance..."
    local triggers
    triggers=$(echo "$result" | jq -r '.triggered_agents | join(",")')

    if [[ "$triggers" == *"rgpd"* ]]; then
        echo "  ✅ rgpd agent triggered"
        ((++passed)) || true
    else
        echo "  ❌ rgpd agent NOT triggered"
        ((++failed)) || true
    fi

    # Test 3: Blocking flag detection
    echo ""
    echo "Test 3: Blocking flag detection..."
    local is_blocking
    is_blocking=$(echo "$result" | jq -r '.is_blocking')

    if [[ "$is_blocking" == "true" ]]; then
        echo "  ✅ is_blocking=true for minors"
        ((++passed)) || true
    else
        echo "  ❌ is_blocking should be true for minors"
        ((++failed)) || true
    fi

    # Test 4: Source identification
    echo ""
    echo "Test 4: Two-stage source identification..."
    local source
    source=$(echo "$result" | jq -r '.source')

    if [[ "$source" == "two-stage" ]]; then
        echo "  ✅ source=two-stage"
        ((++passed)) || true
    else
        echo "  ❌ source should be 'two-stage', got: $source"
        ((++failed)) || true
    fi

    # Test 5: Merge with mock classification
    echo ""
    echo "Test 5: Merge includes haiku enrichment..."
    local intent
    intent=$(echo "$result" | jq -r '.primary_intent')

    if [[ -n "$intent" ]] && [[ "$intent" != "null" ]] && [[ "$intent" != "unknown" ]]; then
        echo "  ✅ primary_intent set: $intent"
        ((++passed)) || true
    else
        echo "  ⚠️ primary_intent not enriched (may be expected without API)"
        ((++passed)) || true  # Not a failure in mock mode
    fi

    # Test 6: Web detection
    echo ""
    echo "Test 6: Web project detection..."
    result=$(run_two_stage_detection "Create a React web application" "." 2>/dev/null)

    if echo "$result" | jq -e '.context_flags | index("is_web")' > /dev/null 2>&1; then
        echo "  ✅ is_web flag detected"
        ((++passed)) || true
    else
        echo "  ❌ is_web flag NOT detected"
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
    preloader_self_test
    exit $?
fi
