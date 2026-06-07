#!/bin/bash
#
# LLM Output Sanitizer — Harmony Framework
#
# Filtre les sorties de commandes LLM/API pour détecter :
#   1. Artifacts d'injection de prompt (DAN, jailbreak, override)
#   2. Injection shell dans les réponses (reverse shells, destructeurs)
#   3. Exfiltration de données (URLs ngrok, webhook, DNS exfil)
#   4. Secrets & credentials exposés (API keys, private keys)
#   5. Stéganographie Unicode (zero-width, ASCII smuggling)
#   6. Supply chain dans le code suggéré (postinstall, typosquats)
#
# Triggered by: PostToolUse on Bash
# Performance: exit rapide si commande non-LLM (< 1ms)
#              analyse légère bash-only sur sortie LLM (< 10ms)
#
# Exit codes:
#   0 = OK
#   2 = Sortie suspecte — bloquer et alerter
#

set -uo pipefail

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
ORANGE='\033[0;33m'
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
    _los_on=$(jq -r '.llm_output_sanitizer.enabled' "${HARMONY_DIR}/local/security-guards.json" 2>/dev/null || echo "null")
    [[ "$_los_on" == "false" ]] && exit 0
fi

# ── Lecture du résultat depuis stdin (JSON Claude Code hook) ──────────────────
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
OUTPUT=$(echo "$INPUT" | jq -r '.tool_response.output // .tool_response // ""' 2>/dev/null || echo "")

# ── Mode d'activation ─────────────────────────────────────────────────────────
#   external-only (défaut) : seulement le contenu externe (WebFetch, curl, LLM)
#   strict                 : ajoute Read (fichiers téléchargés/externes)
# Priorité : env HARMONY_SANITIZER_MODE > config file > défaut
if [[ -n "${HARMONY_SANITIZER_MODE:-}" ]]; then
    MODE="$HARMONY_SANITIZER_MODE"
elif [[ -f "${HARMONY_DIR}/local/security-guards.json" ]]; then
    MODE=$(jq -r '.llm_output_sanitizer.mode // "external-only"' "${HARMONY_DIR}/local/security-guards.json" 2>/dev/null || echo "external-only")
else
    MODE="external-only"
fi

# ── Détermine si la source est "externe" (non-native Claude) ─────────────────
is_external_source() {
    # WebFetch : toujours externe (contenu web)
    [[ "$TOOL_NAME" == "WebFetch" ]] && return 0
    [[ "$TOOL_NAME" == "WebSearch" ]] && return 0

    # Bash : externe si curl/wget vers URL, ou appel LLM
    if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$CMD" ]]; then
        echo "$CMD" | grep -qiE 'ollama[[:space:]]+(run|generate|chat)' && return 0
        echo "$CMD" | grep -qiE 'curl[^|#]*https?://' && return 0
        echo "$CMD" | grep -qiE 'wget[^|#]*https?://' && return 0
        echo "$CMD" | grep -qiE '(litellm|aichat|jan|lmstudio)[[:space:]]' && return 0
        echo "$CMD" | grep -qiE 'python[23]?[[:space:]].*\.(ask|chat|generate|complete|invoke)\(' && return 0
    fi

    # Read : externe uniquement en mode strict (fichiers potentiellement téléchargés)
    if [[ "$MODE" == "strict" ]] && [[ "$TOOL_NAME" == "Read" ]]; then
        return 0
    fi

    return 1
}

is_external_source || exit 0

[[ -z "$OUTPUT" ]] && exit 0

# ── Helpers ───────────────────────────────────────────────────────────────────
BLOCKED=0
WARNED=0

# ADR-010: LLM-layer security log (separate from app-layer local/logs/security/security.log)
LLM_LOG="${HARMONY_DIR}/local/logs/security/llm-security.log"
log_llm() {  # $1=level (BLOCKED|WARNING) $2=message
    mkdir -p "$(dirname "$LLM_LOG")" 2>/dev/null || return 0
    printf '[%s] [%s] [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "${TOOL_NAME:-?}" "${2:0:300}" >> "$LLM_LOG"
}

warn()  {
    WARNED=1
    echo -e "${ORANGE}${BOLD}[LOS-WARN]${NC}  $*" >&2
    log_llm "WARNING" "$*"
}
block() {
    BLOCKED=1
    echo -e "${RED}${BOLD}[LOS-BLOCK]${NC} $*" >&2
    log_llm "BLOCKED" "$*"
}
info()  { echo -e "${CYAN}[LOS]${NC} $*" >&2; }

info "Analyse contenu externe — source: ${TOOL_NAME} (mode: ${MODE})"

# ── COUCHE 1 : Stéganographie Unicode ────────────────────────────────────────
# Zero-width characters
if echo "$OUTPUT" | grep -qP '[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{00AD}\x{2060}]' 2>/dev/null; then
    block "Caractères zero-width détectés (possible stéganographie)"
fi

# Unicode Tags block (ASCII smuggling U+E0000-U+E007F)
if echo "$OUTPUT" | grep -qP '[\x{E0000}-\x{E007F}]' 2>/dev/null; then
    block "Unicode Tags détectés (ASCII smuggling potentiel)"
fi

# ── COUCHE 2 : Artifacts injection de prompt ─────────────────────────────────
INJECTION_PATTERNS=(
    'ignore (all )?(previous|prior|above) instructions'
    'disregard (your|all) (training|guidelines|instructions|safety)'
    'you are now in (DAN|jailbreak|developer|god|unrestricted) mode'
    'SUDO MODE (ACTIVATED|ENABLED|ON)'
    'DEVELOPER MODE (ON|ENABLED)'
    'jailbreak (successful|complete|activated)'
    '\[SYSTEM\][[:space:]]*(override|new instructions|admin)'
    '\[ADMIN\][[:space:]]*(access granted|override|mode)'
    'pretend (there are )?no (safety|content|ethical) (guidelines|filters|restrictions)'
    'from now on you (must|will|shall) (ignore|bypass|disregard)'
    'new persona:[[:space:]]*(unrestricted|evil|jailbreak)'
    'act as (an? )?(unrestricted|unaligned|evil|jailbroken) (AI|model|assistant)'
)

for pat in "${INJECTION_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qiE "$pat" 2>/dev/null; then
        block "Artifact injection prompt : ${pat:0:60}"
    fi
done

# ── COUCHE 3 : Injection shell dans le code suggéré ──────────────────────────
SHELL_PATTERNS=(
    'bash[[:space:]]+-i[[:space:]]+>&[[:space:]]*/dev/tcp/'
    '/dev/tcp/[0-9]{1,3}\.[0-9]{1,3}'
    'nc[[:space:]]+.*(bash|sh|-e|--exec)'
    'python[23]?[[:space:]]+-c[[:space:]]+"[^"]*socket[^"]*connect'
    ':\(\){:\|:&};:'
    'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f[[:space:]]+(\/[^a-zA-Z]|\*|~[^/])'
    'dd[[:space:]]+if=/dev/(zero|random)[[:space:]]+of=/dev/(sd|hd|nvme|disk)'
    'curl[^|#\n]{0,60}\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh)'
    'wget[^|#\n]{0,60}\|[[:space:]]*(bash|sh)'
    'chmod[[:space:]]+(4755|6755|u\+s|777)[[:space:]]'
    'nohup[[:space:]]+.*(curl|wget|nc|ncat)[[:space:]]'
    'LD_PRELOAD[[:space:]]*='
    'echo[^|]{0,40}>>[[:space:]]*/etc/cron'
)

for pat in "${SHELL_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qiE "$pat" 2>/dev/null; then
        block "Shell injection dans réponse LLM : ${pat:0:60}"
    fi
done

# ── COUCHE 4 : Exfiltration réseau ───────────────────────────────────────────
EXFIL_PATTERNS=(
    'https?://(ngrok\.io|ngrok\.app|[a-z0-9-]+\.ngrok-free\.app)'
    'https?://(requestbin\.(com|net)|webhook\.site|pipedream\.net|hookbin\.com)'
    'https?://(interactsh\.|canarytokens\.|burpcollaborator\.net)'
    'curl[^#\n]+https?://[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
    '(cat|tar|base64)[^|]*\|[^|]*(nc|ncat|netcat|socat)[[:space:]]'
    'data:text/html[^,]*base64'
    'javascript:[[:space:]]*(alert|eval|document|window)'
)

for pat in "${EXFIL_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qiE "$pat" 2>/dev/null; then
        block "Exfiltration réseau dans réponse LLM : ${pat:0:60}"
    fi
done

# ── COUCHE 5 : Secrets & credentials dans le code suggéré ────────────────────
SECRET_PATTERNS=(
    '-----BEGIN[[:space:]]+(RSA[[:space:]]+|EC[[:space:]]+|OPENSSH[[:space:]]+)?PRIVATE[[:space:]]+KEY'
    'sk-[a-zA-Z0-9]{40,}'
    'sk-ant-[a-zA-Z0-9_-]{30,}'
    'ghp_[a-zA-Z0-9]{36}'
    'AKIA[0-9A-Z]{16}'
    'AIza[0-9A-Za-z_-]{35}'
    'ya29\.[0-9A-Za-z_-]{50,}'
)

for pat in "${SECRET_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qiE "$pat" 2>/dev/null; then
        block "Secret/credential dans réponse LLM : ${pat:0:60}"
    fi
done

# ── COUCHE 6 : Supply chain dans le code suggéré ─────────────────────────────
SC_PATTERNS=(
    'pip[[:space:]]install[^|#\n]*--index-url[[:space:]]+http://'
    '"(postinstall|install)"[[:space:]]*:[[:space:]]*"[^"]*(curl|wget|bash|sh)[[:space:]]'
    'npm[[:space:]]+install[^|#\n]*(requets|urllib4|openssl2|crypt0)'
    'pip[[:space:]]+install[^|#\n]*(request[^s]|bs4s|numpay|pandaas)'
)

for pat in "${SC_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qiE "$pat" 2>/dev/null; then
        warn "Supply chain suspect dans réponse LLM : ${pat:0:60}"
    fi
done

# ── COUCHE 7 : Static analysis du code (mode strict, si Semgrep dispo) ────────
# Recommandation 2026 : analyse statique du code généré par LLM avant utilisation
if [[ "$MODE" == "strict" ]] && command -v semgrep &>/dev/null; then
    # Extraire les blocs de code markdown et les scanner
    code_blocks=$(echo "$OUTPUT" | awk '/```/{f=!f; next} f' 2>/dev/null || echo "")
    if [[ -n "$code_blocks" ]]; then
        tmp_code=$(mktemp /tmp/los_code_XXXXXX)
        printf '%s\n' "$code_blocks" > "$tmp_code"
        semgrep_out=$(semgrep --config=auto --quiet --error "$tmp_code" 2>/dev/null || true)
        rm -f "$tmp_code"
        if [[ -n "$semgrep_out" ]]; then
            warn "Semgrep a détecté des problèmes dans le code suggéré (mode strict) — réviser avant usage"
        fi
    fi
fi

# ── VERDICT ───────────────────────────────────────────────────────────────────
if [[ $BLOCKED -eq 1 ]]; then
    echo -e "${RED}${BOLD}[LOS] RÉPONSE BLOQUÉE — contenu dangereux détecté.${NC}" >&2
    echo '{"decision":"block","reason":"Réponse LLM bloquée par LLM Output Sanitizer — contenu dangereux détecté."}'
    exit 2
fi

if [[ $WARNED -eq 1 ]]; then
    echo -e "${ORANGE}${BOLD}[LOS] Réponse suspecte — validation humaine requise avant utilisation.${NC}" >&2
fi

exit 0
