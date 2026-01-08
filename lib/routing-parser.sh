#!/bin/bash
# =============================================================================
# Harmony Framework - Routing Rules Parser
# =============================================================================
#
# Parses routing-rules.yaml and provides functions to:
#   - Get triggered agents for context flags
#   - Check if a flag is blocking (priority 0)
#   - Get warning messages for flags
#   - Load detection patterns for agents
#
# FALLBACK: If yq not available, uses hardcoded mappings from aria-detector.sh
#
# USAGE:
#   source "${HARMONY_DIR}/lib/routing-parser.sh"
#   agents=$(routing_get_agents_for_flag "has_minors")
#   is_blocking=$(routing_is_blocking_flag "has_minors")
#
# =============================================================================

set -euo pipefail

# Don't re-source if already loaded
if [[ "${ROUTING_PARSER_LOADED:-}" == "true" ]]; then
    return 0
fi
ROUTING_PARSER_LOADED=true

# =============================================================================
# CONFIGURATION
# =============================================================================

ROUTING_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROUTING_RULES_FILE="${ROUTING_RULES_FILE:-${SCRIPT_DIR}/../config/routing-rules.yaml}"

# Cache
declare -A ROUTING_CACHE_FLAGS
declare -A ROUTING_CACHE_AGENTS
declare -A ROUTING_CACHE_PRIORITY
declare -A ROUTING_CACHE_MESSAGES
ROUTING_CACHE_LOADED=false

# =============================================================================
# YAML PARSING (with fallback)
# =============================================================================

# Check if yq is available
_has_yq() {
    command -v yq &>/dev/null
}

# Load routing rules from YAML
_load_from_yaml() {
    if [[ ! -f "$ROUTING_RULES_FILE" ]]; then
        echo "[ROUTING] WARNING: Rules file not found: $ROUTING_RULES_FILE" >&2
        return 1
    fi

    if ! _has_yq; then
        echo "[ROUTING] WARNING: yq not installed, using fallback mappings" >&2
        return 1
    fi

    # Parse context_flag_triggers (use _f to avoid clobbering caller's variables)
    local _flags _f _agents _priority _message
    _flags=$(yq eval '.auto_detection.context_flag_triggers | keys | .[]' "$ROUTING_RULES_FILE" 2>/dev/null) || return 1

    for _f in $_flags; do
        _agents=$(yq eval ".auto_detection.context_flag_triggers.$_f.agents | join(\",\")" "$ROUTING_RULES_FILE" 2>/dev/null) || true
        _priority=$(yq eval ".auto_detection.context_flag_triggers.$_f.priority" "$ROUTING_RULES_FILE" 2>/dev/null) || true
        _message=$(yq eval ".auto_detection.context_flag_triggers.$_f.message" "$ROUTING_RULES_FILE" 2>/dev/null) || true

        ROUTING_CACHE_FLAGS[$_f]=1
        ROUTING_CACHE_AGENTS[$_f]="$_agents"
        ROUTING_CACHE_PRIORITY[$_f]="${_priority:-3}"
        ROUTING_CACHE_MESSAGES[$_f]="$_message"
    done

    ROUTING_CACHE_LOADED=true
    return 0
}

# Fallback mappings (synced with aria-detector.sh)
_load_fallback() {
    # Flag → Agents
    ROUTING_CACHE_AGENTS=(
        ["has_minors"]="rgpd,security,legal"
        ["personal_data"]="rgpd,security"
        ["has_media"]="rgpd"
        ["security_critical"]="security,pentest"
        ["legal_compliance"]="legal,rgpd"
        ["has_auth"]="security,database"
        ["has_social"]="rgpd,security,legal"
        ["has_ui"]="ux-designer,accessibility"
        ["has_db_schema"]="database,architect"
        ["needs_docs"]="tech-writer"
        ["needs_prd"]="product-manager"
    )

    # Flag → Priority (0 = BLOCKING)
    ROUTING_CACHE_PRIORITY=(
        ["has_minors"]=0
        ["security_critical"]=0
        ["legal_compliance"]=0
        ["personal_data"]=1
        ["has_media"]=1
        ["has_social"]=1
        ["has_auth"]=2
        ["has_db_schema"]=2
        ["has_ui"]=3
        ["needs_docs"]=3
        ["needs_prd"]=2
    )

    # Flag → Messages
    ROUTING_CACHE_MESSAGES=(
        ["has_minors"]="🚨 MINEURS DÉTECTÉS - Validation obligatoire RGPD/Sécurité/Légal"
        ["personal_data"]="⚠️ Données personnelles - Validation RGPD requise"
        ["has_media"]="📷 Médias détectés - Vérification droits/consentement"
        ["security_critical"]="🔒 Sécurité critique - Audit obligatoire"
        ["legal_compliance"]="⚖️ Conformité légale requise"
        ["has_auth"]="🔐 Authentification - Sécurité DB requise"
        ["has_social"]="👥 Fonctionnalités sociales - Triple validation"
        ["has_ui"]="🎨 Interface utilisateur - Validation UX/A11y"
        ["has_db_schema"]="🗃️ Schéma DB - Validation architecture"
        ["needs_docs"]="📝 Documentation requise"
        ["needs_prd"]="📋 PRD requis"
    )

    # Mark all flags (use _f to avoid clobbering caller's variables)
    local _f
    for _f in "${!ROUTING_CACHE_AGENTS[@]}"; do
        ROUTING_CACHE_FLAGS[$_f]=1
    done

    ROUTING_CACHE_LOADED=true
}

# Ensure cache is loaded
_ensure_loaded() {
    if [[ "$ROUTING_CACHE_LOADED" == "true" ]]; then
        return 0
    fi

    # Try YAML first, fallback if fails
    if ! _load_from_yaml; then
        _load_fallback
    fi
}

# =============================================================================
# PUBLIC API
# =============================================================================

# Get agents for a flag
# Returns: comma-separated list of agents
routing_get_agents_for_flag() {
    local flag="$1"
    _ensure_loaded

    echo "${ROUTING_CACHE_AGENTS[$flag]:-}"
}

# Get agents for multiple flags
# Input: space-separated flags
# Returns: deduplicated comma-separated agents
routing_get_agents_for_flags() {
    local flags="$1"
    _ensure_loaded

    local all_agents=()

    for flag in $flags; do
        local agents="${ROUTING_CACHE_AGENTS[$flag]:-}"
        if [[ -n "$agents" ]]; then
            IFS=',' read -ra agent_array <<< "$agents"
            all_agents+=("${agent_array[@]}")
        fi
    done

    # Deduplicate and return
    printf '%s\n' "${all_agents[@]}" | sort -u | tr '\n' ',' | sed 's/,$//'
}

# Check if flag is blocking (priority 0)
routing_is_blocking_flag() {
    local flag="$1"
    _ensure_loaded

    local priority="${ROUTING_CACHE_PRIORITY[$flag]:-3}"
    [[ "$priority" == "0" ]]
}

# Check if any flag in list is blocking
routing_has_blocking_flag() {
    local flags="$1"
    _ensure_loaded

    for flag in $flags; do
        if routing_is_blocking_flag "$flag"; then
            return 0
        fi
    done

    return 1
}

# Get priority for flag (0 = highest/blocking, 3 = lowest)
routing_get_priority() {
    local flag="$1"
    _ensure_loaded

    echo "${ROUTING_CACHE_PRIORITY[$flag]:-3}"
}

# Get warning message for flag
routing_get_message() {
    local flag="$1"
    _ensure_loaded

    echo "${ROUTING_CACHE_MESSAGES[$flag]:-}"
}

# Get all warning messages for flags
routing_get_messages() {
    local flags="$1"
    _ensure_loaded

    for flag in $flags; do
        local message="${ROUTING_CACHE_MESSAGES[$flag]:-}"
        if [[ -n "$message" ]]; then
            echo "$message"
        fi
    done
}

# Get all known flags
routing_list_flags() {
    _ensure_loaded

    for flag in "${!ROUTING_CACHE_FLAGS[@]}"; do
        echo "$flag"
    done | sort
}

# Check if flag is known
routing_is_known_flag() {
    local flag="$1"
    _ensure_loaded

    [[ -n "${ROUTING_CACHE_FLAGS[$flag]:-}" ]]
}

# =============================================================================
# INTENT → AGENT MAPPING
# =============================================================================

declare -A ROUTING_INTENT_MAP
ROUTING_INTENT_MAP=(
    ["ANALYZE"]="analyst"
    ["DESIGN"]="architect"
    ["PRODUCT"]="product-manager"
    ["PLAN"]="scrum-master"
    ["IMPLEMENT"]="developer"
    ["TEST"]="tester"
    ["REVIEW"]="review"
    ["DOCUMENT"]="tech-writer"
    ["FIX"]="developer"
    ["DEPLOY"]="devops"
    ["EXPLORE_QA"]="exploratory-qa"
)

# Get agent for intent
routing_get_agent_for_intent() {
    local intent="$1"
    local intent_upper
    intent_upper=$(echo "$intent" | tr '[:lower:]' '[:upper:]')

    echo "${ROUTING_INTENT_MAP[$intent_upper]:-developer}"
}

# =============================================================================
# DEBUG/INFO
# =============================================================================

routing_version() {
    echo "Routing Parser v${ROUTING_VERSION}"
}

routing_dump_cache() {
    _ensure_loaded

    echo "=== ROUTING CACHE ==="
    echo ""
    echo "Flags:"
    for flag in $(routing_list_flags); do
        local agents="${ROUTING_CACHE_AGENTS[$flag]:-}"
        local priority="${ROUTING_CACHE_PRIORITY[$flag]:-3}"
        local blocking=""
        [[ "$priority" == "0" ]] && blocking=" [BLOCKING]"
        echo "  $flag → $agents (P$priority)$blocking"
    done
}

# =============================================================================
# SELF-TEST
# =============================================================================

routing_self_test() {
    echo "=== Routing Parser Self-Test ==="
    echo ""

    local passed=0
    local failed=0

    # Test 1: Get agents for has_minors
    local agents
    agents=$(routing_get_agents_for_flag "has_minors")
    if [[ "$agents" == *"rgpd"* ]] && [[ "$agents" == *"security"* ]] && [[ "$agents" == *"legal"* ]]; then
        echo "✅ Test 1: Get agents for has_minors (rgpd, security, legal)"
        ((++passed)) || true
    else
        echo "❌ Test 1: FAILED (got: $agents)"
        ((++failed)) || true
    fi

    # Test 2: Check blocking flag
    if routing_is_blocking_flag "has_minors"; then
        echo "✅ Test 2: has_minors is blocking"
        ((++passed)) || true
    else
        echo "❌ Test 2: has_minors should be blocking"
        ((++failed)) || true
    fi

    # Test 3: Check non-blocking flag
    if ! routing_is_blocking_flag "has_ui"; then
        echo "✅ Test 3: has_ui is NOT blocking"
        ((++passed)) || true
    else
        echo "❌ Test 3: has_ui should NOT be blocking"
        ((++failed)) || true
    fi

    # Test 4: Get message
    local message
    message=$(routing_get_message "has_minors")
    if [[ "$message" == *"MINEURS"* ]]; then
        echo "✅ Test 4: Get warning message"
        ((++passed)) || true
    else
        echo "❌ Test 4: FAILED (got: $message)"
        ((++failed)) || true
    fi

    # Test 5: Get agents for multiple flags
    agents=$(routing_get_agents_for_flags "has_minors personal_data")
    if [[ "$agents" == *"rgpd"* ]] && [[ "$agents" == *"legal"* ]]; then
        echo "✅ Test 5: Get agents for multiple flags"
        ((++passed)) || true
    else
        echo "❌ Test 5: FAILED (got: $agents)"
        ((++failed)) || true
    fi

    # Test 6: Intent to agent
    local agent
    agent=$(routing_get_agent_for_intent "implement")
    if [[ "$agent" == "developer" ]]; then
        echo "✅ Test 6: Intent IMPLEMENT → developer"
        ((++passed)) || true
    else
        echo "❌ Test 6: FAILED (got: $agent)"
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
    routing_self_test
    exit $?
fi
