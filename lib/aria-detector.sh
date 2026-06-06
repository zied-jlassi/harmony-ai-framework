#!/bin/bash
# =============================================================================
# Harmony Framework - ARIA Detector (Automatic Runtime Intent Analyzer)
# =============================================================================
#
# TWO-STAGE DETECTION SYSTEM:
#   Stage 1: Pattern Matching (instant, deterministic) - THIS FILE
#   Stage 2: Haiku Enrichment (via context-preloader.sh)
#
# GUARANTEES:
#   - Pattern matching is always fast (0ms overhead)
#   - Compliance triggers fire immediately (enfant → rgpd, security)
#   - No API calls in this module (pure pattern matching)
#   - Reusable from multiple entry points (hooks, pipeline, CLI)
#
# USAGE:
#   source "${HARMONY_DIR}/lib/aria-detector.sh"
#   result=$(aria_detect_patterns "user request text" "/project/dir")
#   # Returns JSON with context_flags, triggered_agents
#
# =============================================================================

set -euo pipefail

# Don't re-source if already loaded
if [[ "${ARIA_DETECTOR_LOADED:-}" == "true" ]]; then
    return 0
fi
ARIA_DETECTOR_LOADED=true

# =============================================================================
# CONFIGURATION
# =============================================================================

ARIA_VERSION="1.0.0"
ARIA_DEFAULT_CONFIDENCE=70

# =============================================================================
# COMPLIANCE KEYWORD PATTERNS (CRITICAL - ORDER MATTERS)
# =============================================================================
# These patterns trigger compliance agents IMMEDIATELY
# Priority 0 = BLOCKING (must validate before proceeding)
# NOTE: Using declare -g to make arrays global even when sourced from a function

declare -g -A ARIA_COMPLIANCE_PATTERNS
ARIA_COMPLIANCE_PATTERNS=(
    # Priority 0: BLOCKING - Minors detection (RGPD Article 8)
    ["has_minors"]="enfant|mineur|âge|age|child|children|minor|kid|teen|adolescent|jeune|élève|pupil|student|école|school"

    # Priority 1: Personal data (RGPD Article 4)
    ["personal_data"]="prénom|prenom|nom|email|e-mail|adresse|address|téléphone|telephone|phone|mobile|birthday|naissance|identité|identity|ssn|numéro|social|photo|avatar"

    # Priority 1: Authentication/Security
    ["has_auth"]="mot.de.passe|password|auth|login|connexion|session|token|jwt|oauth|cookie|credential|signin|signup|register|account|compte"

    # Priority 0: Security Critical
    ["security_critical"]="paiement|payment|carte|card|bancaire|bank|credit|stripe|paypal|checkout|transaction|financial|chiffrement|encryption|ssl|tls|xss|csrf|injection|vulnerability"

    # Priority 1: Media handling
    ["has_media"]="photo|image|video|audio|media|upload|camera|galerie|gallery|fichier|file|attachment|document|pdf"

    # Priority 1: Social features
    ["has_social"]="friend|ami|follow|like|comment|share|partage|message|chat|notification|profile|profil|social|community|communauté"

    # Priority 0: Legal compliance
    ["legal_compliance"]="cgu|cgv|terms|conditions|privacy|politique|policy|consent|consentement|gdpr|rgpd|droit|right|legal|law|regulation|compliance"

    # Priority 2: Internationalization
    ["has_i18n"]="i18n|translation|traduction|multilingual|multilingue|language|langue|locale|localization|localisation|intl"

    # Priority 2: New dependencies (security review needed)
    ["new_dependencies"]="install|installer|package|paquet|npm|yarn|pnpm|library|librairie|dependency|dépendance|add.package|new.package"
)

# =============================================================================
# UI/UX PATTERNS
# =============================================================================

declare -g -A ARIA_UI_PATTERNS
ARIA_UI_PATTERNS=(
    ["has_ui"]="formulaire|form|bouton|button|interface|ui|ux|écran|screen|page|modal|dialog|menu|navbar|sidebar|footer|header|layout|composant|component|widget|input|select|checkbox|radio|dropdown"

    ["has_db_schema"]="database|base.de.données|table|schema|entity|relation|migration|model|orm|prisma|typeorm|sequelize|mongodb|postgres|mysql|sqlite|redis|query"

    ["needs_docs"]="documentation|readme|doc|guide|tutorial|comment|jsdoc|tsdoc|markdown|wiki|changelog"

    ["needs_prd"]="prd|product|requirement|specification|spec|feature|story|user.story|epic|roadmap|backlog"

    # Sprint/Scrum management
    ["needs_sprint_mgmt"]="sprint|velocity|burndown|standup|daily|retro|retrospective|planning|backlog|scrum|kanban|story.suivante|next.story|qu.est.ce.qu.il.reste|what.remains|blocked|bloqué|escalat|impediment"

    # Priority 2: Infrastructure/DevOps
    ["needs_infra"]="deploy|deploiement|docker|kubernetes|k8s|ci|cd|pipeline|jenkins|github.actions|gitlab|aws|azure|gcp|cloud|infra|infrastructure|container|helm|terraform"

    # Priority 2: Performance critical
    ["performance_critical"]="performance|optimization|optimisation|benchmark|latency|latence|cache|caching|speed|vitesse|slow|lent|bottleneck|goulot|profiling|memory|mémoire"

    # Priority 2: Testing patterns
    ["needs_test_setup"]="playwright|cypress|jest|vitest|mocha|test.setup|test.framework|e2e.setup|configurer.tests|setup.tests"

    # Priority 2: TDD/ATDD patterns
    ["needs_tdd"]="tdd|test.driven|red.green|refactor|test.first|atdd|bdd|acceptance.test|test.avant|tests.d.abord"

    # Priority 2: CI/CD Pipeline for tests
    ["needs_ci_tests"]="ci.test|pipeline.test|github.actions.test|gitlab.ci.test|continuous.testing|test.automation|automatiser.tests"

    # Priority 2: Coverage and traceability
    ["needs_coverage"]="coverage|couverture|traceability|traçabilité|requirements.mapping|matrice.couverture|test.coverage"

    # Priority 2: NFR Assessment
    ["needs_nfr_audit"]="nfr|non.functional|audit.performance|audit.security|quality.gate|release.readiness|pre.release"
)

# =============================================================================
# PROJECT TYPE PATTERNS (from package.json / project files)
# =============================================================================

declare -g -A ARIA_PROJECT_PATTERNS
ARIA_PROJECT_PATTERNS=(
    ["is_mobile"]="react-native|expo|flutter|ionic|capacitor|cordova|xamarin|kotlin|swift|android|ios"

    ["is_game"]="phaser|pixi|three|unity|godot|unreal|gamedev|game|sprite|physics|collision|level|score"

    ["is_web"]="react|vue|angular|svelte|next|nuxt|gatsby|vite|webpack|html|css|dom|browser"

    ["is_api"]="express|fastify|nestjs|koa|hapi|rest|graphql|api|endpoint|controller|route|middleware"

    ["is_cli"]="commander|yargs|inquirer|chalk|ora|cli|terminal|command.line|argv"
)

# =============================================================================
# FLAG → AGENT MAPPING (from routing-rules.yaml context_flag_triggers)
# =============================================================================

declare -g -A ARIA_FLAG_AGENTS
ARIA_FLAG_AGENTS=(
    # Compliance triggers (Priority 0-1)
    ["has_minors"]="rgpd,security,legal"
    ["personal_data"]="rgpd,security"
    ["has_media"]="rgpd"
    ["security_critical"]="security,pentest"
    ["legal_compliance"]="legal,rgpd"
    ["has_auth"]="security,database"
    ["has_social"]="rgpd,security,legal"

    # UI/UX triggers
    ["has_ui"]="ux-designer,accessibility"
    ["has_db_schema"]="database,architect"
    ["needs_docs"]="tech-writer"
    ["needs_prd"]="analyst,scrum-master"
    ["needs_sprint_mgmt"]="scrum-master"

    # Infrastructure triggers
    ["needs_infra"]="devops"
    ["performance_critical"]="performance"

    # i18n and dependencies
    ["has_i18n"]="i18n"
    ["new_dependencies"]="dependency,security"

    # Project type triggers
    ["is_mobile"]="developer-mobile,designer-mobile"
    ["is_game"]="developer-gaming,designer-gaming,architect-gaming"
    ["is_web"]="developer-web,designer-web"
    ["is_api"]="developer-software,architect-software"
    ["is_cli"]="developer-software"

    # Testing triggers
    ["needs_test_setup"]="tester-web,tester-software"
    ["needs_tdd"]="tester-software,developer"
    ["needs_ci_tests"]="devops,tester"
    ["needs_coverage"]="ucv-validator,tester"
    ["needs_nfr_audit"]="performance,security,tester"
)

# Flag priorities (0 = BLOCKING, 1-3 = WARNING levels)
declare -g -A ARIA_FLAG_PRIORITY
ARIA_FLAG_PRIORITY=(
    # Priority 0: BLOCKING - Must validate before proceeding
    ["has_minors"]=0
    ["security_critical"]=0
    ["legal_compliance"]=0

    # Priority 1: HIGH - Requires validation
    ["personal_data"]=1
    ["has_media"]=1
    ["has_social"]=1
    ["new_dependencies"]=1  # Security review for new deps

    # Priority 2: MEDIUM - Advisory
    ["has_auth"]=2
    ["has_db_schema"]=2
    ["has_i18n"]=2
    ["needs_infra"]=2
    ["performance_critical"]=2

    # Priority 3: LOW - Informational
    ["has_ui"]=3
    ["needs_docs"]=3
    ["needs_prd"]=3
    ["is_mobile"]=3
    ["is_game"]=3
    ["is_web"]=3
    ["is_api"]=3
    ["is_cli"]=3
)

# =============================================================================
# CORE DETECTION FUNCTIONS
# =============================================================================

# Detect compliance-related context flags from text
# Returns: space-separated list of flags
aria_detect_compliance_flags() {
    local text="$1"
    local text_lower
    text_lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')

    local flags=()

    for flag in "${!ARIA_COMPLIANCE_PATTERNS[@]}"; do
        local pattern="${ARIA_COMPLIANCE_PATTERNS[$flag]}"
        if [[ "$text_lower" =~ ($pattern) ]]; then
            flags+=("$flag")
        fi
    done

    echo "${flags[*]}"
}

# Detect UI/UX context flags from text
aria_detect_ui_flags() {
    local text="$1"
    local text_lower
    text_lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')

    local flags=()

    for flag in "${!ARIA_UI_PATTERNS[@]}"; do
        local pattern="${ARIA_UI_PATTERNS[$flag]}"
        if [[ "$text_lower" =~ ($pattern) ]]; then
            flags+=("$flag")
        fi
    done

    echo "${flags[*]}"
}

# Detect project type from package.json or project files
aria_detect_project_type() {
    local project_dir="${1:-.}"
    local flags=()

    # Check package.json
    if [[ -f "$project_dir/package.json" ]]; then
        local pkg_content
        pkg_content=$(cat "$project_dir/package.json" 2>/dev/null | tr '[:upper:]' '[:lower:]')

        for flag in "${!ARIA_PROJECT_PATTERNS[@]}"; do
            local pattern="${ARIA_PROJECT_PATTERNS[$flag]}"
            if [[ "$pkg_content" =~ ($pattern) ]]; then
                flags+=("$flag")
            fi
        done
    fi

    # Check pubspec.yaml (Flutter)
    if [[ -f "$project_dir/pubspec.yaml" ]]; then
        flags+=("is_mobile")
    fi

    # Check Cargo.toml (Rust)
    if [[ -f "$project_dir/Cargo.toml" ]]; then
        flags+=("is_cli")
    fi

    # Check go.mod (Go)
    if [[ -f "$project_dir/go.mod" ]]; then
        flags+=("is_api")
    fi

    echo "${flags[*]}"
}

# Get triggered agents for a set of flags
aria_get_triggered_agents() {
    local flags="$1"
    local agents=()

    for flag in $flags; do
        local agent_list="${ARIA_FLAG_AGENTS[$flag]:-}"
        if [[ -n "$agent_list" ]]; then
            IFS=',' read -ra agent_array <<< "$agent_list"
            agents+=("${agent_array[@]}")
        fi
    done

    # Deduplicate
    printf '%s\n' "${agents[@]}" | sort -u | tr '\n' ' '
}

# Check if any blocking flags are present
aria_has_blocking_flags() {
    local flags="$1"

    for flag in $flags; do
        local priority="${ARIA_FLAG_PRIORITY[$flag]:-3}"
        if [[ "$priority" == "0" ]]; then
            return 0
        fi
    done

    return 1
}

# Get highest priority (lowest number) among flags
aria_get_max_priority() {
    local flags="$1"
    local max_priority=999

    for flag in $flags; do
        local priority="${ARIA_FLAG_PRIORITY[$flag]:-3}"
        if (( priority < max_priority )); then
            max_priority=$priority
        fi
    done

    echo "$max_priority"
}

# =============================================================================
# MAIN DETECTION API
# =============================================================================

# Full pattern detection - Stage 1 of Two-Stage Detection
# Input: request text, project directory
# Output: JSON with context_flags, triggered_agents, source, confidence
aria_detect_patterns() {
    local request_text="$1"
    local project_dir="${2:-.}"

    # Collect all flags
    local compliance_flags
    compliance_flags=$(aria_detect_compliance_flags "$request_text")

    local ui_flags
    ui_flags=$(aria_detect_ui_flags "$request_text")

    local project_flags
    project_flags=$(aria_detect_project_type "$project_dir")

    # Merge all flags
    local all_flags
    all_flags=$(echo "$compliance_flags $ui_flags $project_flags" | tr ' ' '\n' | grep -v '^$' | sort -u | tr '\n' ' ')
    all_flags="${all_flags% }"  # Trim trailing space

    # Get triggered agents
    local triggered_agents
    triggered_agents=$(aria_get_triggered_agents "$all_flags")
    triggered_agents="${triggered_agents% }"  # Trim trailing space

    # Check for blocking
    local is_blocking="false"
    if aria_has_blocking_flags "$all_flags"; then
        is_blocking="true"
    fi

    # Get priority
    local max_priority
    max_priority=$(aria_get_max_priority "$all_flags")

    # Build JSON output
    local flags_json="[]"
    local triggers_json="[]"

    if [[ -n "$all_flags" ]]; then
        flags_json=$(echo "$all_flags" | tr ' ' '\n' | grep -v '^$' | jq -R . | jq -s .)
    fi

    if [[ -n "$triggered_agents" ]]; then
        triggers_json=$(echo "$triggered_agents" | tr ' ' '\n' | grep -v '^$' | jq -R . | jq -s .)
    fi

    jq -n \
        --argjson flags "$flags_json" \
        --argjson triggers "$triggers_json" \
        --arg blocking "$is_blocking" \
        --argjson priority "$max_priority" \
        --argjson confidence "$ARIA_DEFAULT_CONFIDENCE" \
        '{
            source: "pattern",
            primary_intent: "unknown",
            suggested_agent: null,
            context_flags: $flags,
            triggered_agents: $triggers,
            is_blocking: ($blocking == "true"),
            priority: $priority,
            confidence: $confidence
        }'
}

# Quick check for specific flag
aria_has_flag() {
    local flags="$1"
    local target="$2"

    [[ " $flags " == *" $target "* ]]
}

# Get compliance warning message for flags
aria_get_warning_message() {
    local flags="$1"
    local messages=()

    for flag in $flags; do
        case "$flag" in
            # Blocking (Priority 0)
            has_minors)
                messages+=("🚨 MINEURS DÉTECTÉS - Validation RGPD/Sécurité/Légal obligatoire")
                ;;
            security_critical)
                messages+=("🔒 Sécurité critique - Audit obligatoire")
                ;;
            legal_compliance)
                messages+=("⚖️ Conformité légale requise")
                ;;
            # High priority (Priority 1)
            personal_data)
                messages+=("⚠️ Données personnelles - Validation RGPD requise")
                ;;
            has_media)
                messages+=("📷 Médias détectés - Vérification droits/consentement")
                ;;
            has_social)
                messages+=("👥 Fonctionnalités sociales - Triple validation")
                ;;
            new_dependencies)
                messages+=("📦 Nouvelles dépendances - Revue sécurité requise")
                ;;
            # Medium priority (Priority 2)
            has_auth)
                messages+=("🔐 Authentification - Sécurité DB requise")
                ;;
            has_i18n)
                messages+=("🌍 Internationalisation - Expert i18n recommandé")
                ;;
            needs_infra)
                messages+=("🏗️ Infrastructure - DevOps requis")
                ;;
            performance_critical)
                messages+=("⚡ Performance critique - Profiling recommandé")
                ;;
            # Low priority (Priority 3) - Informational
            has_db_schema)
                messages+=("🗄️ Schéma DB détecté - Architecte recommandé")
                ;;
            is_mobile)
                messages+=("📱 Projet mobile détecté")
                ;;
            is_game)
                messages+=("🎮 Projet gaming détecté")
                ;;
        esac
    done

    printf '%s\n' "${messages[@]}"
}

# =============================================================================
# COMPLEXITY LEVEL FUNCTIONS (Harmony+ v1.1.0)
# =============================================================================
# Aggregate detected flags into complexity level for pipeline depth adjustment

aria_get_complexity_level() {
    local flags_json="${1:-[]}"

    # Handle empty or invalid input
    if [[ -z "$flags_json" ]] || [[ "$flags_json" == "null" ]]; then
        echo "SIMPLE"
        return 0
    fi

    # Count blocking flags (priority 0 - require special handling)
    local blocking
    blocking=$(echo "$flags_json" | jq '[.[] | select(
        . == "has_minors" or
        . == "security_critical" or
        . == "legal_compliance"
    )] | length' 2>/dev/null || echo "0")

    # Count total flags
    local total
    total=$(echo "$flags_json" | jq 'length' 2>/dev/null || echo "0")

    # Determine complexity level
    if [[ "$blocking" -gt 0 ]] || [[ "$total" -gt 5 ]]; then
        echo "COMPLEX"
    elif [[ "$total" -gt 2 ]]; then
        echo "STANDARD"
    else
        echo "SIMPLE"
    fi
}

aria_get_pipeline_depth() {
    local complexity="${1:-SIMPLE}"

    case "$complexity" in
        SIMPLE)
            echo "CONTEXT,IMPLEMENT"
            ;;
        STANDARD)
            echo "CONTEXT,SPEC,IMPLEMENT,VALIDATE"
            ;;
        COMPLEX)
            echo "DISCOVERY,REQUIREMENTS,CONTEXT,SPEC,PLANNING,IMPLEMENT,CRITIQUE,VALIDATE"
            ;;
        *)
            echo "CONTEXT,IMPLEMENT"
            ;;
    esac
}

aria_get_complexity_config() {
    local complexity="${1:-SIMPLE}"

    case "$complexity" in
        SIMPLE)
            echo '{"phases":["CONTEXT","IMPLEMENT"],"critique":false,"full_ucv":false}'
            ;;
        STANDARD)
            echo '{"phases":["CONTEXT","SPEC","IMPLEMENT","VALIDATE"],"critique":"light","full_ucv":true}'
            ;;
        COMPLEX)
            echo '{"phases":["DISCOVERY","REQUIREMENTS","CONTEXT","SPEC","PLANNING","IMPLEMENT","CRITIQUE","VALIDATE"],"critique":"full","full_ucv":true}'
            ;;
        *)
            echo '{"phases":["CONTEXT","IMPLEMENT"],"critique":false,"full_ucv":false}'
            ;;
    esac
}

# =============================================================================
# DEBUG/INFO FUNCTIONS
# =============================================================================

aria_version() {
    echo "ARIA Detector v${ARIA_VERSION}"
}

aria_list_patterns() {
    echo "=== COMPLIANCE PATTERNS ==="
    for flag in "${!ARIA_COMPLIANCE_PATTERNS[@]}"; do
        echo "  $flag: ${ARIA_COMPLIANCE_PATTERNS[$flag]:0:50}..."
    done

    echo ""
    echo "=== UI PATTERNS ==="
    for flag in "${!ARIA_UI_PATTERNS[@]}"; do
        echo "  $flag: ${ARIA_UI_PATTERNS[$flag]:0:50}..."
    done

    echo ""
    echo "=== PROJECT PATTERNS ==="
    for flag in "${!ARIA_PROJECT_PATTERNS[@]}"; do
        echo "  $flag: ${ARIA_PROJECT_PATTERNS[$flag]:0:50}..."
    done
}

# =============================================================================
# SELF-TEST (run with: bash aria-detector.sh --test)
# =============================================================================

aria_self_test() {
    echo "=== ARIA Detector Self-Test ==="
    echo ""

    local passed=0
    local failed=0
    local result=""
    local agents=""
    local blocking=""

    # Test 1: Minors detection
    result=$(aria_detect_compliance_flags "Créer un formulaire pour les enfants") || true
    if [[ "$result" == *"has_minors"* ]]; then
        echo "✅ Test 1: Minors detection (enfants)"
        ((++passed)) || true
    else
        echo "❌ Test 1: Minors detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 2: Personal data detection
    result=$(aria_detect_compliance_flags "Stocker l'email et le prénom") || true
    if [[ "$result" == *"personal_data"* ]]; then
        echo "✅ Test 2: Personal data detection (email, prénom)"
        ((++passed)) || true
    else
        echo "❌ Test 2: Personal data detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 3: Auth detection
    result=$(aria_detect_compliance_flags "Add password reset functionality") || true
    if [[ "$result" == *"has_auth"* ]]; then
        echo "✅ Test 3: Auth detection (password)"
        ((++passed)) || true
    else
        echo "❌ Test 3: Auth detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 4: UI detection
    result=$(aria_detect_ui_flags "Créer un formulaire avec bouton submit") || true
    if [[ "$result" == *"has_ui"* ]]; then
        echo "✅ Test 4: UI detection (formulaire, bouton)"
        ((++passed)) || true
    else
        echo "❌ Test 4: UI detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 5: Full detection JSON
    result=$(aria_detect_patterns "Créer un formulaire d'inscription pour les enfants avec email" ".") || true
    if echo "$result" | jq -e '.context_flags | index("has_minors")' > /dev/null 2>&1; then
        echo "✅ Test 5: Full JSON detection"
        ((++passed)) || true
    else
        echo "❌ Test 5: Full JSON detection FAILED"
        ((++failed)) || true
    fi

    # Test 6: Triggered agents
    result=$(aria_detect_patterns "Traitement de données personnelles d'enfants" ".") || true
    agents=$(echo "$result" | jq -r '.triggered_agents | join(",")') || true
    if [[ "$agents" == *"rgpd"* ]] && [[ "$agents" == *"security"* ]]; then
        echo "✅ Test 6: Triggered agents (rgpd, security)"
        ((++passed)) || true
    else
        echo "❌ Test 6: Triggered agents FAILED (got: $agents)"
        ((++failed)) || true
    fi

    # Test 7: Blocking detection
    result=$(aria_detect_patterns "Payment processing for minors" ".") || true
    blocking=$(echo "$result" | jq -r '.is_blocking') || true
    if [[ "$blocking" == "true" ]]; then
        echo "✅ Test 7: Blocking flag detection"
        ((++passed)) || true
    else
        echo "❌ Test 7: Blocking flag detection FAILED (got: $blocking)"
        ((++failed)) || true
    fi

    # Test 8: i18n detection
    result=$(aria_detect_compliance_flags "Add multilingual support with translations") || true
    if [[ "$result" == *"has_i18n"* ]]; then
        echo "✅ Test 8: i18n detection (multilingual, translations)"
        ((++passed)) || true
    else
        echo "❌ Test 8: i18n detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 9: Infrastructure detection
    result=$(aria_detect_ui_flags "Deploy to kubernetes with docker") || true
    if [[ "$result" == *"needs_infra"* ]]; then
        echo "✅ Test 9: Infrastructure detection (kubernetes, docker)"
        ((++passed)) || true
    else
        echo "❌ Test 9: Infrastructure detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 10: Performance detection
    result=$(aria_detect_ui_flags "Optimize performance and add caching") || true
    if [[ "$result" == *"performance_critical"* ]]; then
        echo "✅ Test 10: Performance detection (performance, caching)"
        ((++passed)) || true
    else
        echo "❌ Test 10: Performance detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 11: New dependencies detection
    result=$(aria_detect_compliance_flags "Install npm package for image processing") || true
    if [[ "$result" == *"new_dependencies"* ]]; then
        echo "✅ Test 11: Dependencies detection (install, npm, package)"
        ((++passed)) || true
    else
        echo "❌ Test 11: Dependencies detection FAILED (got: $result)"
        ((++failed)) || true
    fi

    # Test 12: Agent mapping for project type
    agents=$(aria_get_triggered_agents "is_game") || true
    if [[ "$agents" == *"developer-gaming"* ]]; then
        echo "✅ Test 12: Game project triggers gaming agents"
        ((++passed)) || true
    else
        echo "❌ Test 12: Game project agents FAILED (got: $agents)"
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
    aria_self_test
    exit $?
fi
