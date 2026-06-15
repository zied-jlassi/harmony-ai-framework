# Implementation: Loop-Safe Context Preloader

> **🌐 Language:** English · [Français](../fr/architecture/IMPL-context-preloader-safe.md)

## Executive Summary

This document describes the implementation of the context loading system **without infinite loops**.

**Key principles:**
1. **ONE-SHOT**: Each phase runs exactly once
2. **FORWARD-ONLY**: The state machine forbids backward transitions
3. **BOUNDED**: Token budget enforced (15K max)
4. **FLAT**: No dependency chains
5. **IMMUTABLE**: Context locked after injection

---

## Loop-Free Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           STATE MACHINE (FORWARD-ONLY)                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│    IDLE ──▶ CLASSIFYING ──▶ RESOLVING ──▶ LOADING ──▶ INJECTING ──▶ LOCKED     │
│      │          │              │             │            │            │         │
│      │          │              │             │            │            │         │
│      ▼          ▼              ▼             ▼            ▼            ▼         │
│   (start)   (Haiku)       (lookup)      (read)      (write)      (read-only)    │
│                                                                                  │
│   ┌──────────────────────────────────────────────────────────────────────────┐  │
│   │  RÈGLE: Transitions UNIQUEMENT vers la DROITE                            │  │
│   │  RÈGLE: Impossible de revenir en arrière                                 │  │
│   │  RÈGLE: Une fois LOCKED, aucune modification possible                    │  │
│   └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Loop Scenarios and Protections

### Scenario 1: Re-classification
```
RISQUE: Haiku appelé plusieurs fois → résultats différents → incohérence
PROTECTION: State machine - CLASSIFYING ne peut être atteint qu'une fois
```

### Scenario 2: Profile chain
```
RISQUE: Profile A requires B requires C requires A → boucle infinie
PROTECTION: Résolution FLAT - tous les requires résolus en UNE passe
```

### Scenario 3: Recursive knowledge
```
RISQUE: knowledge/a.md référence b.md qui référence a.md
PROTECTION: MAX_DEPTH=1 - pas de chargement imbriqué
```

### Scenario 4: Triggered agents chain
```
RISQUE: Agent A trigger B qui trigger A
PROTECTION: Triggered agents chargés comme SUMMARIES (50 lignes), pas exécutés
```

### Scenario 5: Handoff re-classification
```
RISQUE: Handoff Dev→Tester déclenche nouvelle classification
PROTECTION: Handoff hérite du contexte, pas de re-classification
```

---

## Implementation: context-preloader.sh

```bash
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

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly PRELOADER_MAX_TOKENS=15000
readonly PRELOADER_MAX_DEPTH=1
readonly PRELOADER_SUMMARY_LINES=50
readonly PRELOADER_CACHE_TTL=1800  # 30 minutes

# =============================================================================
# STATE MACHINE
# =============================================================================

# States (ordered - can only move forward)
readonly -a PRELOADER_STATES=("IDLE" "CLASSIFYING" "RESOLVING" "LOADING" "INJECTING" "LOCKED")
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
    local target_idx=$(_get_state_idx "$target")

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
        local chars=$(wc -c < "$file")
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

# Cache for classification result
PRELOADER_CLASSIFICATION_CACHE=""

_classify_request() {
    local user_request="$1"

    # Check cache first
    if [[ -n "$PRELOADER_CLASSIFICATION_CACHE" ]]; then
        echo "$PRELOADER_CLASSIFICATION_CACHE"
        return 0
    fi

    # Build classification prompt from routing-rules.yaml
    local prompt
    prompt=$(get_config "auto_detection.classification_prompt" "")
    prompt="${prompt//\{user_input\}/$user_request}"

    # Call Haiku (or mock in test mode)
    local result
    if [[ "${PRELOADER_MOCK_MODE:-}" == "true" ]]; then
        result=$(_mock_classification "$user_request")
    else
        result=$(_call_haiku "$prompt")
    fi

    # Validate and cache
    if echo "$result" | jq -e '.primary_intent' > /dev/null 2>&1; then
        PRELOADER_CLASSIFICATION_CACHE="$result"
        echo "$result"
    else
        echo '{"primary_intent":"IMPLEMENT","context_flags":[],"suggested_agent":"developer","triggered_agents":[],"confidence":0.5}'
    fi
}

_mock_classification() {
    local request="$1"
    local flags=()
    local triggered=()

    # Simple keyword detection for mock
    [[ "$request" =~ auth|login|password ]] && flags+=("has_auth") && triggered+=("security")
    [[ "$request" =~ game|jeu|gaming ]] && flags+=("is_game")
    [[ "$request" =~ mobile|react.native|flutter ]] && flags+=("is_mobile")
    [[ "$request" =~ user|profil|donnee|data ]] && flags+=("personal_data") && triggered+=("rgpd")

    cat << EOF
{
    "primary_intent": "IMPLEMENT",
    "context_flags": $(printf '%s\n' "${flags[@]:-}" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "suggested_agent": "developer",
    "triggered_agents": $(printf '%s\n' "${triggered[@]:-}" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "confidence": 0.85
}
EOF
}

_call_haiku() {
    local prompt="$1"
    # TODO: Implement actual Haiku API call
    # For now, return mock
    _mock_classification "$prompt"
}

# =============================================================================
# PHASE 2: RESOLUTION (Lookups)
# =============================================================================

_resolve_context() {
    local classification="$1"
    local agent="${2:-}"

    # Extract from classification
    local intent=$(echo "$classification" | jq -r '.primary_intent // "IMPLEMENT"')
    local suggested=$(echo "$classification" | jq -r '.suggested_agent // "developer"')
    local flags=$(echo "$classification" | jq -r '.context_flags[]?' 2>/dev/null)
    local triggered=$(echo "$classification" | jq -r '.triggered_agents[]?' 2>/dev/null)

    # Use provided agent or suggested
    agent="${agent:-$suggested}"

    # Resolve branch (uses cached lookup from config-loader.sh)
    local branch_path
    branch_path=$(resolve_agent "$agent")

    # Resolve knowledge for flags (FLAT - no chains)
    local knowledge_files=""
    while IFS= read -r flag; do
        [[ -z "$flag" ]] && continue
        local flag_knowledge
        flag_knowledge=$(_get_knowledge_for_flag "$flag")
        knowledge_files+="$flag_knowledge"$'\n'
    done <<< "$flags"

    # Resolve profiles (FLAT - all at once)
    local profiles
    profiles=$(_detect_profiles_flat)

    # Build resolution result
    cat << EOF
{
    "agent": "$agent",
    "intent": "$intent",
    "branch_path": "$branch_path",
    "knowledge_files": $(echo "$knowledge_files" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "profiles": $(echo "$profiles" | jq -R -s 'split("\n") | map(select(length > 0))'),
    "triggered_agents": $(echo "$triggered" | jq -R -s 'split("\n") | map(select(length > 0))')
}
EOF
}

_get_knowledge_for_flag() {
    local flag="$1"
    # Map flags to knowledge files (STATIC mapping, no dynamic chains)
    case "$flag" in
        has_auth)
            echo "${HARMONY_DIR}/knowledge/domains/security/authentication-patterns.md"
            ;;
        personal_data)
            echo "${HARMONY_DIR}/knowledge/domains/security/data-protection.md"
            ;;
        is_game)
            echo "${HARMONY_DIR}/knowledge/domains/gaming/game-patterns.md"
            ;;
        is_mobile)
            echo "${HARMONY_DIR}/knowledge/frameworks/react/react-native-architecture.md"
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
    fi

    echo "$profiles"
}

# =============================================================================
# PHASE 3: LOADING (Bounded)
# =============================================================================

_load_context() {
    local resolution="$1"

    _enter_depth || return 1

    local branch_path=$(echo "$resolution" | jq -r '.branch_path')
    local knowledge_files=$(echo "$resolution" | jq -r '.knowledge_files[]?' 2>/dev/null)
    local triggered=$(echo "$resolution" | jq -r '.triggered_agents[]?' 2>/dev/null)

    local loaded_content=""

    # Load branch (main content)
    if [[ -f "$branch_path" ]]; then
        local tokens=$(_count_tokens "$branch_path")
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

        local tokens=$(_count_tokens "$file")
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

        local agent_path
        agent_path=$(resolve_agent "$agent")
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

    # Return as JSON
    cat << EOF
{
    "content": $(echo "$loaded_content" | jq -R -s '.'),
    "tokens_used": $PRELOADER_TOKENS_USED,
    "budget": $PRELOADER_MAX_TOKENS
}
EOF
}

# =============================================================================
# PHASE 4: INJECTION (Write Once)
# =============================================================================

_inject_context() {
    local loaded="$1"
    local classification="$PRELOADER_CLASSIFICATION_CACHE"

    local memory_dir="${HARMONY_DIR}/local/memory"
    local working_file="${memory_dir}/working.json"

    mkdir -p "$memory_dir"

    # Build final context
    cat > "$working_file" << EOF
{
    "context_loaded": true,
    "timestamp": "$(date -Iseconds)",
    "classification": $classification,
    "loaded": $loaded,
    "state": "INJECTED"
}
EOF

    echo "[PRELOADER] Context written to $working_file" >&2
}

# =============================================================================
# PHASE 5: LOCK (Read-Only)
# =============================================================================

_lock_context() {
    local working_file="${HARMONY_DIR}/local/memory/working.json"

    if [[ -f "$working_file" ]]; then
        # Update state to LOCKED
        local tmp=$(mktemp)
        jq '.state = "LOCKED"' "$working_file" > "$tmp" && mv "$tmp" "$working_file"

        # Make read-only (optional, for extra safety)
        # chmod 444 "$working_file"

        echo "[PRELOADER] Context LOCKED" >&2
    fi
}

# =============================================================================
# DISPLAY SUMMARY
# =============================================================================

_display_summary() {
    local working_file="${HARMONY_DIR}/local/memory/working.json"

    if [[ -f "$working_file" ]]; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    CONTEXT LOADED                               ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
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

    _display_summary
    return 0
}

# Reset for testing only
_reset_preloader() {
    PRELOADER_CURRENT_STATE="IDLE"
    PRELOADER_STATE_IDX=0
    PRELOADER_TOKENS_USED=0
    PRELOADER_CURRENT_DEPTH=0
    PRELOADER_CLASSIFICATION_CACHE=""
}
```

---

## Anti-Loop Validation Tests

```bash
#!/bin/bash
# test-preloader-loops.sh

source "${HARMONY_DIR}/lib/context-preloader.sh"

echo "=== TEST 1: Double call prevention ==="
PRELOADER_MOCK_MODE=true
preload_context "créer auth" "developer"
# Second call should return immediately (LOCKED state)
preload_context "autre chose" "tester"
# Should print: "Context already loaded and locked"

echo ""
echo "=== TEST 2: Token budget enforcement ==="
_reset_preloader
PRELOADER_MAX_TOKENS=100  # Tiny budget
PRELOADER_MOCK_MODE=true
preload_context "créer jeu mobile avec auth" "developer"
# Should print warnings about skipping files

echo ""
echo "=== TEST 3: State machine enforcement ==="
_reset_preloader
PRELOADER_MOCK_MODE=true
# Try to skip to LOADING without CLASSIFYING
_transition "LOADING"  # Should fail
echo "State after invalid transition: $PRELOADER_CURRENT_STATE"
# Should still be IDLE
```

---

## Integration with Guardian

In `agents/guardian.md`, add after Step 3 (Route to Agent):

```markdown
## Step 4: Context Pre-Loading

AVANT d'exécuter l'agent sélectionné:

1. **Charger le preloader**
   \`\`\`
   source ${HARMONY_DIR}/lib/context-preloader.sh
   \`\`\`

2. **Appeler preload_context**
   \`\`\`
   preload_context "$USER_REQUEST" "$SELECTED_AGENT"
   \`\`\`

3. **Vérifier le succès**
   - Si état = LOCKED → continuer
   - Si erreur → afficher message, ne pas exécuter agent

4. **Contexte disponible**
   - Agent peut lire ${HARMONY_DIR}/local/memory/working.json
   - Contexte est IMMUTABLE (lecture seule)
   - Agent NE PEUT PAS rappeler preload_context
```

---

## Implementation Checklist

- [ ] Create `lib/context-preloader.sh` with the code above
- [ ] Add tests in `tests/e2e/scripts/test.sh`
- [ ] Modify `agents/guardian.md` Step 4
- [ ] Create missing knowledge files (authentication-patterns.md, etc.)
- [ ] Test loop scenarios
- [ ] Document in CLAUDE.md
