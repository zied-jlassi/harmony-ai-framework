#!/bin/bash
# =============================================================================
# Hook: rules-enforcer.sh
# Description: Harmony Framework - Bloque les opérations dangereuses
# Trigger: PreToolUse (Bash, Write, Edit)
# Version: 1.0.0
# =============================================================================
#
# INTERDICTIONS APPLIQUÉES:
#
#   🔴 CRITICAL (BLOQUANT - exit 2):
#   - Destruction fichiers: rm -rf /, rm -rf *, rm -rf ~
#   - SQL destructif: DROP DATABASE, DROP TABLE, TRUNCATE
#   - Permissions dangereuses: chmod 777, chmod -R 777
#   - Pipe vers shell: curl|bash, wget|sh
#   - Fork bomb: :(){ :|:& };:
#   - Écriture destructive: > /dev/sda, dd if=/dev/zero
#   - Git destructif: git push --force origin main/master
#
#   🟠 HIGH (BLOQUANT si Docker requis):
#   - Package managers locaux sans Docker
#   - Secrets/credentials dans le code
#
#   🟡 MEDIUM (WARNING - non bloquant):
#   - Docker rm/rmi (demande confirmation)
#   - chmod sur projet
#   - git push --force (hors main/master)
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------

readonly HARMONY_DIR="${HARMONY_DIR:-.harmony}"
readonly LOG_FILE="${HARMONY_DIR}/local/memory/.security.log"
readonly DEBUG="${HARMONY_HOOK_DEBUG:-0}"

# Paramètres d'entrée Claude Code
readonly TOOL_NAME="${1:-unknown}"
readonly TOOL_INPUT="${2:-{}}"

# Couleurs
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# -----------------------------------------------------------------------------
# LOAD CONFIG (with backward compatibility)
# -----------------------------------------------------------------------------

# Source config loader if available, otherwise use fallbacks
if [[ -f "${HARMONY_DIR}/lib/config-loader.sh" ]]; then
    source "${HARMONY_DIR}/lib/config-loader.sh"
else
    # Fallback functions for backward compatibility
    get_config() {
        local key="$1"
        local default="${2:-}"
        echo "$default"
    }
    get_config_bool() {
        local key="$1"
        local default="${2:-false}"
        [[ "$default" == "true" ]]
    }
    get_config_array() {
        echo ""
    }
fi

# -----------------------------------------------------------------------------
# ENVIRONMENT DETECTION (with config fallbacks)
# -----------------------------------------------------------------------------

detect_docker_environment() {
    # Check config first (with fallback)
    if get_config_bool "docker.required" false; then
        echo "required"
        return
    fi

    # Détecter via docker-compose.yml
    if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
        echo "available"
        return
    fi

    echo "none"
}

get_container_prefix() {
    get_config "docker.container_prefix" "app"
}

readonly DOCKER_ENV=$(detect_docker_environment)
readonly CONTAINER_PREFIX=$(get_container_prefix)

# -----------------------------------------------------------------------------
# PATTERNS DANGEREUX - CRITICAL (BLOQUANT)
# -----------------------------------------------------------------------------

DANGEROUS_PATTERNS=(
    # ═══════════════════════════════════════════════════════════
    # DESTRUCTION FICHIERS SYSTÈME
    # ═══════════════════════════════════════════════════════════
    'rm\s+(-[a-zA-Z]*)?-rf\s+/'
    'rm\s+(-[a-zA-Z]*)?-rf\s+\*'
    'rm\s+(-[a-zA-Z]*)?-rf\s+~'
    'rm\s+(-[a-zA-Z]*)?-rf\s+\$HOME'
    'rm\s+(-[a-zA-Z]*)?-rf\s+\.'

    # ═══════════════════════════════════════════════════════════
    # SQL DESTRUCTIF
    # ═══════════════════════════════════════════════════════════
    'DROP\s+DATABASE'
    'DROP\s+TABLE'
    'DROP\s+SCHEMA'
    'TRUNCATE\s+TABLE'
    'TRUNCATE\s+[a-zA-Z_]+'
    'DELETE\s+FROM\s+[a-zA-Z_]+\s*;?\s*$'      # DELETE sans WHERE
    'DELETE\s+FROM\s+[a-zA-Z_]+\s+WHERE\s+1=1'  # DELETE WHERE 1=1
    'DELETE\s+FROM\s+[a-zA-Z_]+\s+WHERE\s+true' # DELETE WHERE true
    'prisma\s+migrate\s+reset'
    'prisma\s+db\s+push\s+--force'

    # ═══════════════════════════════════════════════════════════
    # PERMISSIONS DANGEREUSES
    # ═══════════════════════════════════════════════════════════
    'chmod\s+(-R\s+)?777\s+/'
    'chmod\s+(-R\s+)?777\s+\.'
    'chown\s+(-R\s+)?root:root\s+/'

    # ═══════════════════════════════════════════════════════════
    # EXÉCUTION ARBITRAIRE
    # ═══════════════════════════════════════════════════════════
    'curl\s+.*\|\s*(ba)?sh'
    'wget\s+.*\|\s*(ba)?sh'
    'curl\s+.*\|.*bash'
    'wget\s+.*\|.*bash'

    # ═══════════════════════════════════════════════════════════
    # FORK BOMB
    # ═══════════════════════════════════════════════════════════
    ':\(\)\s*\{\s*:\|:&\s*\};:'
    'fork\s*bomb'

    # ═══════════════════════════════════════════════════════════
    # ÉCRITURE DESTRUCTIVE SYSTÈME
    # ═══════════════════════════════════════════════════════════
    '>\s*/dev/sd[a-z]'
    'dd\s+if=/dev/(zero|random)\s+of=/dev/sd[a-z]'
    'mkfs\s+'
    'fdisk\s+/dev/'

    # ═══════════════════════════════════════════════════════════
    # GIT DESTRUCTIF (branches protégées)
    # ═══════════════════════════════════════════════════════════
    'git\s+push\s+--force\s+origin\s+(main|master)'
    'git\s+push\s+-f\s+origin\s+(main|master)'
    'git\s+reset\s+--hard\s+origin/(main|master)'
    'git\s+filter-branch'
    'git\s+reflog\s+expire.*--all'

    # ═══════════════════════════════════════════════════════════
    # DOCKER DESTRUCTIF MASSIF
    # ═══════════════════════════════════════════════════════════
    'docker\s+system\s+prune\s+-a\s+--volumes'
    'docker\s+rm\s+-f\s+\$\(docker\s+ps'

    # ═══════════════════════════════════════════════════════════
    # SYSTÈME
    # ═══════════════════════════════════════════════════════════
    'shutdown\s+'
    'reboot'
    'init\s+0'
    'init\s+6'
    'echo\s+.*>\s*/etc/'
    '>\s*/etc/passwd'
    '>\s*/etc/shadow'
)

# -----------------------------------------------------------------------------
# PATTERNS PACKAGE MANAGERS LOCAUX (BLOQUÉS si Docker requis)
# -----------------------------------------------------------------------------

LOCAL_PKG_MANAGER_PATTERNS=(
    # npm/npx direct
    '^npm\s+'
    '^npx\s+'
    '^\./node_modules/.bin/'

    # yarn direct
    '^yarn\s+'

    # pnpm direct
    '^pnpm\s+'

    # bun direct
    '^bun\s+'

    # ts-node/tsx direct
    '^ts-node\s+'
    '^tsx\s+'

    # node direct avec fichiers projet
    '^node\s+.*\.(ts|js)$'
    '^node\s+src/'
    '^node\s+dist/'

    # prisma direct
    '^prisma\s+'

    # nest CLI direct
    '^nest\s+'

    # vite/next direct
    '^vite\s+'
    '^next\s+'

    # sudo bloqué
    '^sudo\s+'
    '\|\s*sudo'
)

# Exceptions Docker
ALLOWED_PKG_PATTERNS=(
    'docker\s+exec.*npm'
    'docker\s+exec.*npx'
    'docker\s+exec.*yarn'
    'docker\s+exec.*pnpm'
    'docker\s+exec.*bun'
    'docker\s+exec.*prisma'
    'docker\s+exec.*nest'
    'docker\s+exec.*node'
    'docker\s+exec.*ts-node'
    'docker\s+exec.*vite'
    'docker\s+exec.*next'
    'docker\s+compose.*run'
    'docker-compose.*run'
    # MCP servers exception
    '/home/.*npx.*@modelcontextprotocol'
)

# -----------------------------------------------------------------------------
# PATTERNS SECRETS (BLOQUÉS dans fichiers)
# -----------------------------------------------------------------------------

SECRETS_PATTERNS=(
    '\.env$'
    '\.env\.local$'
    '\.env\.production$'
    '\.env\.development$'
    'credentials\.json$'
    '\.pem$'
    '\.key$'
    'id_rsa'
    '\.secrets'
    'PASSWORD\s*=\s*["\047][^"\047]{8,}["\047]'
    'API_KEY\s*=\s*["\047][^"\047]{20,}["\047]'
    'SECRET\s*=\s*["\047][^"\047]{10,}["\047]'
    'PRIVATE_KEY\s*='
    'aws_secret_access_key'
    'GITHUB_TOKEN\s*='
)

# -----------------------------------------------------------------------------
# PATTERNS WARNING (non bloquants)
# -----------------------------------------------------------------------------

WARNING_PATTERNS=(
    # chmod sur répertoire courant/projet
    'chmod\s+[0-7]{3}\s+\.$'
    'chmod\s+[0-7]{3}\s+\./'
    'chmod\s+(-R\s+)?[0-7]{3}\s+src/'
    'chmod\s+(-R\s+)?[0-7]{3}\s+app/'

    # Docker containers/images
    'docker\s+rm\s+'
    'docker\s+rmi\s+'
    'docker\s+container\s+rm'
    'docker\s+image\s+rm'

    # git push force (hors main/master)
    'git\s+push\s+--force'
    'git\s+push\s+-f'

    # pip install user
    'pip\s+install\s+--user'
)

# -----------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
# -----------------------------------------------------------------------------

log_security() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

log_debug() {
    if [[ "$DEBUG" == "1" ]]; then
        log_security "DEBUG" "$*"
    fi
}

get_command() {
    echo "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null || echo ""
}

get_file_path() {
    echo "$TOOL_INPUT" | jq -r '.file_path // .path // ""' 2>/dev/null || echo ""
}

get_content() {
    echo "$TOOL_INPUT" | jq -r '.content // .new_string // ""' 2>/dev/null || echo ""
}

# -----------------------------------------------------------------------------
# FONCTIONS D'AFFICHAGE
# -----------------------------------------------------------------------------

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🛡️  HARMONY RULES ENFORCER${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_blocked() {
    local category="$1"
    local severity="$2"
    local pattern="$3"
    local command="$4"
    local explanation="$5"
    local alternatives="$6"

    print_header
    echo ""
    echo -e "${RED}🚫 INTERDICTION - ${category}${NC}"
    echo -e "${MAGENTA}Sévérité:${NC} ${severity}"
    echo ""
    echo -e "${YELLOW}Pattern détecté:${NC} ${pattern}"
    echo -e "${YELLOW}Commande:${NC} ${command:0:100}..."
    echo ""
    echo -e "${CYAN}Explication:${NC}"
    echo -e "${explanation}"
    echo ""
    if [[ -n "$alternatives" ]]; then
        echo -e "${GREEN}Alternatives sûres:${NC}"
        echo -e "${alternatives}"
        echo ""
    fi
    echo -e "${MAGENTA}Pour forcer (si vraiment nécessaire):${NC}"
    echo -e "  \"Je confirme vouloir exécuter cette opération dangereuse\""
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_docker_required() {
    local command="$1"
    local prefix="$2"

    print_header
    echo ""
    echo -e "${RED}🐳 DOCKER REQUIS${NC}"
    echo ""
    echo -e "${YELLOW}❌ INTERDIT:${NC} $command"
    echo ""
    echo -e "${GREEN}✅ CORRECT: Utiliser Docker exec:${NC}"
    echo -e "   docker exec ${prefix}-backend npm install"
    echo -e "   docker exec ${prefix}-backend npx prisma generate"
    echo -e "   docker exec ${prefix}-frontend npm run build"
    echo ""
    echo -e "${CYAN}Règle: Tout doit passer par Docker, RIEN en local!${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_warning() {
    local message="$1"
    echo ""
    echo -e "${YELLOW}⚠️  [SECURITY WARNING]${NC} $message"
    echo ""
}

# -----------------------------------------------------------------------------
# FONCTIONS DE VÉRIFICATION
# -----------------------------------------------------------------------------

check_dangerous_patterns() {
    local command="$1"

    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if echo "$command" | grep -qiE "$pattern"; then
            echo "$pattern"
            return 0
        fi
    done

    return 1
}

check_local_pkg_manager() {
    local command="$1"

    # Vérifier les exceptions Docker d'abord
    for pattern in "${ALLOWED_PKG_PATTERNS[@]}"; do
        if echo "$command" | grep -qE "$pattern"; then
            return 1  # Exception, OK
        fi
    done

    # Vérifier les package managers locaux
    for pattern in "${LOCAL_PKG_MANAGER_PATTERNS[@]}"; do
        if echo "$command" | grep -qE "$pattern"; then
            echo "$pattern"
            return 0
        fi
    done

    return 1
}

check_secrets_in_content() {
    local file_path="$1"
    local content="$2"

    # Vérifier le chemin du fichier
    for pattern in "${SECRETS_PATTERNS[@]}"; do
        if echo "$file_path" | grep -qiE "$pattern"; then
            echo "file:$pattern"
            return 0
        fi
    done

    # Vérifier le contenu
    for pattern in "${SECRETS_PATTERNS[@]}"; do
        if echo "$content" | grep -qiE "$pattern"; then
            echo "content:$pattern"
            return 0
        fi
    done

    return 1
}

check_warning_patterns() {
    local command="$1"

    for pattern in "${WARNING_PATTERNS[@]}"; do
        if echo "$command" | grep -qiE "$pattern"; then
            return 0
        fi
    done

    return 1
}

# -----------------------------------------------------------------------------
# EXPLICATIONS PAR CATÉGORIE
# -----------------------------------------------------------------------------

get_explanation() {
    local pattern="$1"

    case "$pattern" in
        *DROP*DATABASE*|*DROP*TABLE*|*TRUNCATE*)
            echo "Cette opération DÉTRUIT des données de manière IRRÉVERSIBLE.
Assurez-vous d'avoir une sauvegarde avant de continuer."
            ;;
        *rm*-rf*)
            echo "Cette commande peut supprimer des fichiers système critiques
de manière IRRÉVERSIBLE."
            ;;
        *git*push*force*|*git*-f*)
            echo "Force push réécrit l'historique Git.
Les commits d'autres développeurs peuvent être perdus."
            ;;
        *chmod*777*)
            echo "chmod 777 donne accès complet à TOUS les utilisateurs.
C'est une faille de sécurité majeure."
            ;;
        *curl*bash*|*wget*sh*)
            echo "Exécuter du code téléchargé directement est TRÈS DANGEREUX.
Le script pourrait contenir du code malveillant."
            ;;
        *)
            echo "Cette opération est considérée dangereuse et nécessite confirmation."
            ;;
    esac
}

get_alternatives() {
    local pattern="$1"

    case "$pattern" in
        *DROP*DATABASE*)
            echo "- Faire un backup: pg_dump database > backup.sql
- Utiliser une transaction avec ROLLBACK
- Renommer la table/database au lieu de supprimer"
            ;;
        *DROP*TABLE*|*TRUNCATE*)
            echo "- Faire un backup: pg_dump -t table database > backup.sql
- DELETE avec WHERE spécifique
- Soft delete (colonne deleted_at)"
            ;;
        *git*push*force*)
            echo "- git push --force-with-lease (plus sûr)
- git revert (au lieu de reset)
- Créer une branche backup avant"
            ;;
        *rm*-rf*)
            echo "- Lister d'abord: ls -la
- Utiliser trash-cli (corbeille)
- rm interactif: rm -ri"
            ;;
        *)
            echo ""
            ;;
    esac
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

main() {
    mkdir -p "$(dirname "$LOG_FILE")"
    log_debug "=== Rules Enforcer started ==="
    log_debug "Tool: $TOOL_NAME"
    log_debug "Docker env: $DOCKER_ENV"

    # ═══════════════════════════════════════════════════════════
    # MERGE PROJECT OVERRIDES (backward compatible)
    # ═══════════════════════════════════════════════════════════

    # Add project-specific dangerous patterns
    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] && DANGEROUS_PATTERNS+=("$pattern")
    done < <(get_config_array "rules_enforcer.add_dangerous_patterns" 2>/dev/null || echo "")

    # Add project-specific warning patterns
    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] && WARNING_PATTERNS+=("$pattern")
    done < <(get_config_array "rules_enforcer.add_warning_patterns" 2>/dev/null || echo "")

    # Add project-specific allowed patterns (Docker exceptions)
    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] && ALLOWED_PKG_PATTERNS+=("$pattern")
    done < <(get_config_array "rules_enforcer.add_allowed_patterns" 2>/dev/null || echo "")

    # Add project-specific secrets patterns
    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] && SECRETS_PATTERNS+=("$pattern")
    done < <(get_config_array "rules_enforcer.add_secrets_patterns" 2>/dev/null || echo "")

    # Remove disabled patterns (from framework defaults)
    local disabled_patterns=()
    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] && disabled_patterns+=("$pattern")
    done < <(get_config_array "rules_enforcer.disable_patterns" 2>/dev/null || echo "")

    if [[ ${#disabled_patterns[@]} -gt 0 ]]; then
        local filtered_dangerous=()
        for pattern in "${DANGEROUS_PATTERNS[@]}"; do
            local is_disabled=false
            for disabled in "${disabled_patterns[@]}"; do
                if [[ "$pattern" == "$disabled" ]]; then
                    is_disabled=true
                    log_debug "Pattern disabled by config: $pattern"
                    break
                fi
            done
            $is_disabled || filtered_dangerous+=("$pattern")
        done
        DANGEROUS_PATTERNS=("${filtered_dangerous[@]}")
    fi

    local command=""
    local file_path=""
    local content=""

    # Extraire les données selon le type d'outil
    case "$TOOL_NAME" in
        Bash)
            command=$(get_command)
            ;;
        Write|Edit|MultiEdit)
            file_path=$(get_file_path)
            content=$(get_content)
            ;;
        *)
            exit 0
            ;;
    esac

    log_debug "Command: ${command:0:100}"
    log_debug "File: $file_path"

    # ═══════════════════════════════════════════════════════════
    # CHECK 1: Patterns dangereux (BLOQUANT)
    # ═══════════════════════════════════════════════════════════
    if [[ -n "$command" ]]; then
        local matched_pattern
        if matched_pattern=$(check_dangerous_patterns "$command"); then
            local explanation=$(get_explanation "$matched_pattern")
            local alternatives=$(get_alternatives "$matched_pattern")

            print_blocked \
                "OPÉRATION DANGEREUSE" \
                "🔴 CRITICAL" \
                "$matched_pattern" \
                "$command" \
                "$explanation" \
                "$alternatives"

            log_security "BLOCKED" "Pattern: $matched_pattern | Command: ${command:0:200}"
            exit 2
        fi
    fi

    # ═══════════════════════════════════════════════════════════
    # CHECK 2: Package managers locaux (BLOQUANT si Docker requis)
    # ═══════════════════════════════════════════════════════════
    if [[ "$DOCKER_ENV" == "required" ]] && [[ -n "$command" ]]; then
        local pkg_pattern
        if pkg_pattern=$(check_local_pkg_manager "$command"); then
            print_docker_required "$command" "$CONTAINER_PREFIX"
            log_security "BLOCKED" "Local pkg manager: $pkg_pattern | Command: ${command:0:200}"
            exit 2
        fi
    fi

    # ═══════════════════════════════════════════════════════════
    # CHECK 3: Secrets dans le contenu (BLOQUANT)
    # ═══════════════════════════════════════════════════════════
    if [[ -n "$file_path" ]] || [[ -n "$content" ]]; then
        local secret_pattern
        if secret_pattern=$(check_secrets_in_content "$file_path" "$content"); then
            print_blocked \
                "SECRETS DÉTECTÉS" \
                "🟠 HIGH" \
                "$secret_pattern" \
                "File: $file_path" \
                "Ce fichier/contenu semble contenir des secrets.
Ne JAMAIS commiter des credentials, API keys, mots de passe." \
                "- Utiliser des variables d'environnement
- Ajouter au .gitignore
- Utiliser un gestionnaire de secrets (Vault, etc.)"

            log_security "BLOCKED" "Secrets: $secret_pattern | File: $file_path"
            exit 2
        fi
    fi

    # ═══════════════════════════════════════════════════════════
    # CHECK 4: Patterns warning (non bloquant)
    # ═══════════════════════════════════════════════════════════
    if [[ -n "$command" ]] && check_warning_patterns "$command"; then
        print_warning "Commande sensible détectée - vérification recommandée"
        log_security "WARNING" "Command: ${command:0:200}"
    fi

    log_debug "=== Rules Enforcer passed ==="
    exit 0
}

main "$@"
