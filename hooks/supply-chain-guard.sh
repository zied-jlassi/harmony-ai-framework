#!/bin/bash
#
# Supply Chain Guard — Harmony Framework
#
# Intercepte les commandes d'installation de packages et vérifie :
#   1. Vulnérabilités connues (audit local + registry officiel)
#   2. Typosquatting (noms proches de packages populaires)
#   3. Packages non publiés (install depuis git/local sans vérification)
#
# Triggered by: PreToolUse on Bash (toutes les commandes)
# Performance: exit rapide si commande non pertinente (< 1ms)
#              audit local si package manager détecté (2-5s)
#              vérification online si nouveau package (3-8s)
#
# Exit codes:
#   0 = OK, laisser passer
#   2 = BLOQUER (vulnérabilité critique ou commande dangereuse)
#

set -uo pipefail

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Switch : exit rapide si guard désactivé ───────────────────────────────────
HARMONY_DIR="${HARMONY_DIR:-.harmony}"
# Override env instantané
[[ "${HARMONY_GUARDS:-}" == "off" ]] && exit 0
# Config file — lecture brute (éviter le piège `// true` de jq sur false)
if [[ -f "${HARMONY_DIR}/local/security-guards.json" ]]; then
    _scg_on=$(jq -r '.supply_chain_guard.enabled' "${HARMONY_DIR}/local/security-guards.json" 2>/dev/null || echo "null")
    [[ "$_scg_on" == "false" ]] && exit 0
fi

# ── Lecture de la commande depuis stdin (JSON Claude Code hook) ───────────────
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

[[ -z "$CMD" ]] && exit 0

# Visible-status helper (proof the guard triggered)
[[ -f "${HARMONY_DIR}/lib/hook-ui.sh" ]] && source "${HARMONY_DIR}/lib/hook-ui.sh"
type hook_status &>/dev/null || hook_status() { :; }

# ── Exit rapide si commande non pertinente ────────────────────────────────────
is_install_cmd() {
    echo "$CMD" | grep -qiE \
        '(npm|npx|pnpm|yarn|bun)[[:space:]]+(install|add|i[[:space:]]|ci[[:space:]])' \
        || echo "$CMD" | grep -qiE \
        '(pip|pip3|uv|poetry)[[:space:]]+(install|add)' \
        || echo "$CMD" | grep -qiE \
        'composer[[:space:]]+(install|require|update)' \
        || echo "$CMD" | grep -qiE \
        'cargo[[:space:]]+(install|add)' \
        || echo "$CMD" | grep -qiE \
        'gem[[:space:]]+(install|update)' \
        || echo "$CMD" | grep -qiE \
        'go[[:space:]]+(get|install)' \
        || echo "$CMD" | grep -qiE \
        'apt(-get)?[[:space:]]+(install|upgrade)' \
        || echo "$CMD" | grep -qiE \
        'brew[[:space:]]+(install|upgrade)' \
        || echo "$CMD" | grep -qiE \
        'npx[[:space:]]+(-y[[:space:]]+|--yes[[:space:]]+)?(@modelcontextprotocol/|[^[:space:]]*mcp-server-|[^[:space:]]*-mcp([[:space:]@]|$))' \
        || echo "$CMD" | grep -qiE \
        'npx[[:space:]]+-y[[:space:]]'
}

is_install_cmd || exit 0

# ── Mode (block|warn) lu depuis la config ─────────────────────────────────────
if [[ -f "${HARMONY_DIR}/local/security-guards.json" ]]; then
    SCG_MODE=$(jq -r '.supply_chain_guard.mode // "block"' "${HARMONY_DIR}/local/security-guards.json" 2>/dev/null || echo "block")
else
    SCG_MODE="block"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
# ADR-010: supply chain is an app/workstation concern → app-layer security log.
SEC_LOG="${HARMONY_DIR}/local/logs/security/security.log"
log_sec() {  # $1=level $2=message
    mkdir -p "$(dirname "$SEC_LOG")" 2>/dev/null || return 0
    printf '[%s] [%s] [SUPPLY] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "${2:0:300}" >> "$SEC_LOG"
}
warn()  { echo -e "${ORANGE}${BOLD}[SCG-WARN]${NC} $*" >&2; log_sec "WARNING" "$*"; }
block() {
    if [[ "$SCG_MODE" == "warn" ]]; then
        echo -e "${ORANGE}${BOLD}[SCG-WARN]${NC} (mode warn) $*" >&2
        log_sec "WARNING" "$*"
        return 0
    fi
    echo -e "${RED}${BOLD}[SCG-BLOCK]${NC} $*" >&2
    log_sec "BLOCKED" "$*"
    echo '{"decision":"block","reason":"'"$*"'"}'
    exit 2
}
ok()    { echo -e "${GREEN}[SCG-OK]${NC} $*" >&2; }
info()  { echo -e "${CYAN}[SCG]${NC} $*" >&2; }

info "Commande d'installation détectée : ${CMD:0:80}"

# ── LAYER 1 : Patterns dangereux immédiats ────────────────────────────────────
# Audit install depuis URLs : autoriser uniquement les registries officiels
if echo "$CMD" | grep -qiE '(npm|pip|gem|cargo)[[:space:]]+(install|add)[[:space:]]+https?://'; then
    if ! echo "$CMD" | grep -qiE 'https?://(registry\.npmjs\.org|pypi\.org|files\.pythonhosted\.org|rubygems\.org|crates\.io|github\.com)'; then
        block "Installation depuis URL non-officielle détectée"
    fi
fi

# Install depuis fichier local non signé
if echo "$CMD" | grep -qiE \
    '(npm|pip3?)[[:space:]]+(install|add)[[:space:]]+\./[^[:space:]]+\.(whl|tgz|tar\.gz)'; then
    warn "Installation depuis archive locale — vérifier l'intégrité de la source"
fi

# postinstall script suspect dans la commande (-- évite l'interprétation comme option)
if echo "$CMD" | grep -qiE -- '--ignore-scripts[[:space:]]*false'; then
    warn "--ignore-scripts désactivé — les scripts post-install vont s'exécuter"
fi
if echo "$CMD" | grep -qiE 'install[^;]*&&[[:space:]]*(curl|wget|bash|sh)[[:space:]]'; then
    block "Script post-install suspect chaîné à l'installation"
fi

# Pip install depuis index non sécurisé
if echo "$CMD" | grep -qiE 'pip[[:space:]].*index-url[[:space:]]+http://'; then
    block "pip install via HTTP non-sécurisé (utiliser HTTPS)"
fi

# ── LAYER 2 : Typosquatting — packages populaires connus ─────────────────────
# Liste des typosquats connus, enrichie avec les incidents réels 2026
# (Microsoft 2026-05-28 : 14 packages typosquattés OpenSearch/ElasticSearch
#  volant secrets AWS/Vault/CI ; Axios mars 2026 : RAT via post-install)
TYPOSQUATS=(
    # npm — classiques
    'requets' 'reqeusts' 'expres[[:space:]]' 'reacts[[:space:]]' 'lodahs' 'mongoos[^e]'
    'axio[^s]' 'moment[^js]' 'webpakc' 'babbel' 'eslint2' 'jquerys'
    # npm — incidents 2026 (OpenSearch/ElasticSearch/DevOps targeting)
    'opensearh' 'opensearch' 'elasticsearh' 'elastic-search[^j]' 'elasticseach'
    'kubernets' 'terrafrom' 'ansibel' 'prometeus' 'grafan[^a]'
    # pip
    'urllib4' 'request[^s]' 'bs4s' 'numpay' 'pandaas' 'flaskk' 'djang[^o]'
    'openssl2' 'crypt0' 'boto[^3]' 'pyyamll' 'tensorflwo' 'scikit-lern'
    # composer/gem/cargo
    'laravell' 'symfonny' 'raills' 'tokio2' 'serde2'
)

for typo in "${TYPOSQUATS[@]}"; do
    if echo "$CMD" | grep -qiE "[[:space:]]${typo}([[:space:]]|$|@|==|>=|~>)"; then
        block "Typosquat potentiel détecté : '${typo}' — vérifier le nom exact sur le registry officiel"
    fi
done

# ── LAYER 3 : Audit local (si outils disponibles) ────────────────────────────

# npm / pnpm / yarn / bun → npm audit
if echo "$CMD" | grep -qiE '(npm|pnpm|yarn|bun)[[:space:]]+(install|add|i[[:space:]]|ci)'; then
    if command -v npm &>/dev/null && [[ -f "package.json" ]]; then
        info "Lancement npm audit (pré-vérification)..."
        audit_out=$(npm audit --json 2>/dev/null || true)
        if [[ -n "$audit_out" ]]; then
            critical=$(echo "$audit_out" | jq -r '.metadata.vulnerabilities.critical // 0' 2>/dev/null || echo "0")
            high=$(echo "$audit_out" | jq -r '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo "0")
            if [[ "$critical" -gt 0 ]]; then
                block "npm audit: $critical vulnérabilité(s) CRITIQUE(S) dans les dépendances existantes. Corriger avec 'npm audit fix' avant d'ajouter de nouveaux packages."
            elif [[ "$high" -gt 0 ]]; then
                warn "npm audit: $high vulnérabilité(s) HIGH existante(s). Vérifier avec 'npm audit' avant de continuer."
            else
                ok "npm audit: aucune vulnérabilité critique/haute."
            fi
        fi
    fi
fi

# pip / pip3 / uv / poetry → pip-audit ou safety
if echo "$CMD" | grep -qiE '(pip3?|uv|poetry)[[:space:]]+(install|add)'; then
    if command -v pip-audit &>/dev/null; then
        info "Lancement pip-audit (pré-vérification)..."
        audit_out=$(pip-audit --format json 2>/dev/null || true)
        if [[ -n "$audit_out" ]]; then
            vuln_count=$(echo "$audit_out" | jq '[.[] | select(.vulns | length > 0)] | length' 2>/dev/null || echo "0")
            if [[ "$vuln_count" -gt 0 ]]; then
                warn "pip-audit: $vuln_count package(s) vulnérable(s) dans l'environnement actuel."
            else
                ok "pip-audit: aucune vulnérabilité détectée."
            fi
        fi
    elif command -v safety &>/dev/null; then
        info "Lancement safety check..."
        safety check --json 2>/dev/null | jq -r '.[0] | if length > 0 then "VULN:\(length) vulnérabilités" else "OK" end' >&2 || true
    fi
fi

# composer → composer audit
if echo "$CMD" | grep -qiE 'composer[[:space:]]+(install|require|update)'; then
    if command -v composer &>/dev/null; then
        info "Lancement composer audit..."
        if composer audit --no-interaction 2>&1 | grep -qi "found [1-9]"; then
            warn "composer audit: des vulnérabilités ont été détectées. Vérifier avant d'installer."
        else
            ok "composer audit: aucune vulnérabilité."
        fi
    fi
fi

# cargo → cargo audit
if echo "$CMD" | grep -qiE 'cargo[[:space:]]+(install|add)'; then
    if command -v cargo-audit &>/dev/null; then
        info "Lancement cargo audit..."
        if ! cargo audit --quiet 2>/dev/null; then
            warn "cargo audit: des vulnérabilités ont été détectées dans les dépendances Rust."
        else
            ok "cargo audit: aucune vulnérabilité."
        fi
    fi
fi

# ── LAYER 4 : Vérification online des nouveaux packages ──────────────────────
# Extrait le nom du/des package(s) depuis la commande
extract_npm_pkg() {
    echo "$CMD" | grep -oiE '(npm|pnpm|yarn|bun)[[:space:]]+(install|add|i)[[:space:]]+([^-][^[:space:]]*)' \
        | awk '{print $NF}' | grep -v '^-' | head -3
}

extract_pip_pkg() {
    echo "$CMD" | grep -oiE 'pip3?[[:space:]]install[[:space:]]+([^-][^[:space:]]*)' \
        | awk '{print $NF}' | grep -v '^-' | head -3
}

# Période de quarantaine : un package publié très récemment est plus risqué
# (Microsoft 2026 : 14 packages malveillants publiés et exploités en 4h).
# Seuil configurable via HARMONY_PKG_COOLING_DAYS (défaut 14 jours).
COOLING_DAYS="${HARMONY_PKG_COOLING_DAYS:-14}"

days_since() {
    # $1 = date ISO8601 → nombre de jours écoulés
    local iso="$1" then now
    then=$(date -d "$iso" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${iso%%.*}" +%s 2>/dev/null || echo "0")
    [[ "$then" == "0" ]] && { echo "999"; return; }
    now=$(date +%s)
    echo $(( (now - then) / 86400 ))
}

# npm registry check
if echo "$CMD" | grep -qiE '(npm|pnpm|yarn)[[:space:]]+(install|add)' && command -v curl &>/dev/null; then
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        pkg_name=$(echo "$pkg" | sed 's/@[^@]*$//')  # strip version
        info "Vérification npm registry: $pkg_name"
        registry_resp=$(curl -sf --max-time 5 \
            "https://registry.npmjs.org/${pkg_name}" 2>/dev/null || echo "")
        if [[ -z "$registry_resp" ]]; then
            warn "Package '$pkg_name' introuvable sur npm registry — vérifier le nom exact (typosquat ?)"
        else
            deprecated=$(echo "$registry_resp" | jq -r '.deprecated // ""' 2>/dev/null || echo "")
            if [[ -n "$deprecated" ]]; then
                warn "Package '$pkg_name' est DÉPRÉCIÉ sur npm: $deprecated"
            fi
            # Cooling period : âge de la dernière publication
            last_pub=$(echo "$registry_resp" | jq -r '.time.modified // ""' 2>/dev/null || echo "")
            if [[ -n "$last_pub" ]]; then
                age=$(days_since "$last_pub")
                if [[ "$age" -lt "$COOLING_DAYS" ]]; then
                    warn "Package '$pkg_name' publié il y a ${age}j (< ${COOLING_DAYS}j quarantaine) — risque supply chain élevé, vérifier le mainteneur"
                else
                    ok "Package '$pkg_name' OK (dernière publi: ${age}j)"
                fi
            fi
        fi
    done < <(extract_npm_pkg)
fi

# PyPI check
if echo "$CMD" | grep -qiE 'pip3?[[:space:]]install' && command -v curl &>/dev/null; then
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        pkg_name=$(echo "$pkg" | sed 's/[>=<!].*//')
        info "Vérification PyPI: $pkg_name"
        pypi_resp=$(curl -sf --max-time 5 \
            "https://pypi.org/pypi/${pkg_name}/json" 2>/dev/null || echo "")
        if [[ -z "$pypi_resp" ]]; then
            warn "Package '$pkg_name' introuvable sur PyPI — vérifier le nom exact (typosquat ?)"
        else
            # Cooling period : date de release de la dernière version
            last_pub=$(echo "$pypi_resp" | jq -r '.urls[0].upload_time_iso_8601 // ""' 2>/dev/null || echo "")
            if [[ -n "$last_pub" ]]; then
                age=$(days_since "$last_pub")
                if [[ "$age" -lt "$COOLING_DAYS" ]]; then
                    warn "Package '$pkg_name' publié il y a ${age}j (< ${COOLING_DAYS}j quarantaine) — risque supply chain élevé"
                else
                    ok "Package '$pkg_name' OK (dernière publi: ${age}j)"
                fi
            fi
        fi
    done < <(extract_pip_pkg)
fi

# ── LAYER 5 : Lock file awareness ─────────────────────────────────────────────
# Un install sans lock file ne garantit pas les versions/hash (recommandation 2026)
if echo "$CMD" | grep -qiE 'npm[[:space:]]+install' && [[ -f "package.json" ]]; then
    if [[ ! -f "package-lock.json" ]] && [[ ! -f "npm-shrinkwrap.json" ]]; then
        warn "Pas de package-lock.json — versions/hash non verrouillés. Préférer 'npm ci' avec lock file commité."
    fi
fi
if echo "$CMD" | grep -qiE 'pip3?[[:space:]]install' && ! echo "$CMD" | grep -qiE '\-r[[:space:]]'; then
    warn "pip install sans requirements.txt — préférer un fichier avec versions pinées et hash (--require-hashes)"
fi

# ── LAYER 6 : Vérification des serveurs MCP ───────────────────────────────────
# Les serveurs MCP installés via `npx -y` tirent la DERNIÈRE version sans pin
# ni hash → une version compromise serait auto-installée (supply chain).
# Recommandation : pinner la version exacte + vérifier l'intégrité.
is_mcp_install() {
    echo "$CMD" | grep -qiE '@modelcontextprotocol/server-' \
        || echo "$CMD" | grep -qiE 'npx[^|]*mcp-server-' \
        || echo "$CMD" | grep -qiE 'npx[^|]*server-mcp' \
        || echo "$CMD" | grep -qiE 'npx[^|]*-mcp([[:space:]@]|$)'
}

if is_mcp_install; then
    info "Serveur MCP détecté dans la commande"

    # Version pinnée ? (présence de @x.y.z après le nom du package)
    if echo "$CMD" | grep -qiE '@modelcontextprotocol/server-[a-z-]+@[0-9]'; then
        ok "Serveur MCP avec version pinnée."
    elif echo "$CMD" | grep -qiE '(@modelcontextprotocol/server-[a-z-]+|mcp-server-[a-z-]+)([[:space:]"]|$)'; then
        block "Serveur MCP sans version pinnée (npx -y tire 'latest' sans hash). Pinner la version exacte : '@modelcontextprotocol/server-xxx@VERSION' et vérifier l'intégrité avant installation."
    fi

    # npx -y bypasse la confirmation → exécution silencieuse du dernier code publié
    if echo "$CMD" | grep -qiE 'npx[[:space:]]+-y[[:space:]]'; then
        warn "npx -y exécute le package sans confirmation. Pour un serveur MCP, préférer une installation locale pinnée avec hash (package-lock.json)."
    fi
fi

# Vérification statique du fichier de config MCP s'il existe (.mcp.json)
for mcp_cfg in ".mcp.json" ".claude/mcp.json" ".cursor/mcp.json"; do
    [[ -f "$mcp_cfg" ]] || continue
    # Cherche les serveurs npx sans version pinnée dans la config
    unpinned=$(jq -r '
        (.mcpServers // {}) | to_entries[]
        | select(.value.args != null)
        | select([.value.args[] | test("@[0-9]+\\.")] | any | not)
        | select([.value.args[] | test("@modelcontextprotocol/|mcp-server-|-mcp$")] | any)
        | .key
    ' "$mcp_cfg" 2>/dev/null || echo "")
    if [[ -n "$unpinned" ]]; then
        while IFS= read -r srv; do
            [[ -z "$srv" ]] && continue
            warn "MCP '$srv' dans $mcp_cfg sans version pinnée — risque d'auto-update vers une version vulnérable"
        done <<< "$unpinned"
    fi
done

info "Supply chain check terminé — commande autorisée à s'exécuter."
# User-visible proof the package screening ran and passed
hook_status "📦 Supply-chain: clean — install screened"
exit 0
