#!/bin/bash
#
# Security Guards Engine — Harmony Framework
#
# Gère l'activation/désactivation des hooks de sécurité :
#   - supply-chain-guard   : vérifie les installations de packages
#   - llm-output-sanitizer : filtre le contenu externe (WebFetch, curl, LLM)
#
# Source de vérité : .harmony/local/security-guards.json
# Override rapide  : variable d'env HARMONY_GUARDS=off (désactive tout, 0ms)
#
# Usage:
#   security-guards status
#   security-guards on  [guard]
#   security-guards off [guard]
#   security-guards mode <guard> <mode>
#
# Guards: supply-chain | llm-sanitizer | all
# Modes : supply-chain  → block | warn
#         llm-sanitizer → external-only | strict
#

set -uo pipefail

HARMONY_DIR="${HARMONY_DIR:-.harmony}"
CONFIG_FILE="${HARMONY_DIR}/local/security-guards.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Config par défaut ─────────────────────────────────────────────────────────
DEFAULT_CONFIG='{
  "supply_chain_guard": {
    "enabled": true,
    "mode": "block"
  },
  "llm_output_sanitizer": {
    "enabled": true,
    "mode": "external-only"
  }
}'

# ── Init config si absente ────────────────────────────────────────────────────
ensure_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
    fi
}

# ── Lecture rapide pour les hooks : "guard_enabled <key>" → 0 si actif ────────
# Utilisé par les hooks eux-mêmes. Respecte l'override env HARMONY_GUARDS=off.
guard_enabled() {
    local key="$1"  # supply_chain_guard | llm_output_sanitizer

    # Override env (le plus rapide, 0ms)
    [[ "${HARMONY_GUARDS:-}" == "off" ]] && return 1

    # Pas de config = défaut activé
    [[ ! -f "$CONFIG_FILE" ]] && return 0

    # NOTE: ne PAS utiliser `// true` — l'opérateur // de jq traite `false`
    # comme vide et renverrait `true`. On lit la valeur brute et on teste "false".
    local enabled
    enabled=$(jq -r ".${key}.enabled" "$CONFIG_FILE" 2>/dev/null || echo "null")
    [[ "$enabled" == "false" ]] && return 1 || return 0
}

# ── Lecture du mode d'un guard ────────────────────────────────────────────────
guard_mode() {
    local key="$1"
    [[ ! -f "$CONFIG_FILE" ]] && { echo ""; return; }
    jq -r ".${key}.mode // \"\"" "$CONFIG_FILE" 2>/dev/null || echo ""
}

# ── Mapping nom-court → clé JSON ──────────────────────────────────────────────
guard_key() {
    case "$1" in
        supply-chain|supply|scg)  echo "supply_chain_guard" ;;
        llm-sanitizer|llm|los)    echo "llm_output_sanitizer" ;;
        *)                        echo "" ;;
    esac
}

# ── Set enabled ───────────────────────────────────────────────────────────────
set_enabled() {
    local key="$1" value="$2"
    ensure_config
    local tmp
    tmp=$(mktemp)
    jq ".${key}.enabled = ${value}" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
}

set_mode() {
    local key="$1" mode="$2"
    ensure_config
    local tmp
    tmp=$(mktemp)
    jq ".${key}.mode = \"${mode}\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
}

# ── Affichage du statut ───────────────────────────────────────────────────────
show_status() {
    ensure_config
    echo ""
    echo -e "${BOLD}${CYAN}═══ Harmony Security Guards ═══${NC}"
    echo ""

    if [[ "${HARMONY_GUARDS:-}" == "off" ]]; then
        echo -e "  ${YELLOW}⚠ HARMONY_GUARDS=off — tous les guards désactivés par env${NC}"
        echo ""
    fi

    local scg_on scg_mode los_on los_mode
    # Lecture brute (éviter le piège `// true` sur les booléens false)
    scg_on=$(jq -r '.supply_chain_guard.enabled' "$CONFIG_FILE" 2>/dev/null)
    scg_mode=$(jq -r '.supply_chain_guard.mode // "block"' "$CONFIG_FILE" 2>/dev/null)
    los_on=$(jq -r '.llm_output_sanitizer.enabled' "$CONFIG_FILE" 2>/dev/null)
    los_mode=$(jq -r '.llm_output_sanitizer.mode // "external-only"' "$CONFIG_FILE" 2>/dev/null)

    if [[ "$scg_on" != "false" ]]; then
        echo -e "  supply-chain-guard:   ${GREEN}✅ ON${NC}  (${scg_mode})"
    else
        echo -e "  supply-chain-guard:   ${RED}⛔ OFF${NC}"
    fi

    if [[ "$los_on" != "false" ]]; then
        echo -e "  llm-output-sanitizer: ${GREEN}✅ ON${NC}  (${los_mode})"
    else
        echo -e "  llm-output-sanitizer: ${RED}⛔ OFF${NC}"
    fi

    echo ""
    echo -e "  ${CYAN}Config:${NC} ${CONFIG_FILE}"
    echo ""
}

# ── Dispatcher CLI ────────────────────────────────────────────────────────────
main() {
    local action="${1:-status}"
    local target="${2:-all}"

    case "$action" in
        status|"")
            show_status
            ;;

        on|enable)
            if [[ "$target" == "all" ]]; then
                set_enabled "supply_chain_guard" "true"
                set_enabled "llm_output_sanitizer" "true"
                echo -e "${GREEN}✅ Tous les guards activés${NC}"
            else
                local key; key=$(guard_key "$target")
                [[ -z "$key" ]] && { echo -e "${RED}Guard inconnu: $target${NC}"; exit 1; }
                set_enabled "$key" "true"
                echo -e "${GREEN}✅ $target activé${NC}"
            fi
            show_status
            ;;

        off|disable)
            if [[ "$target" == "all" ]]; then
                set_enabled "supply_chain_guard" "false"
                set_enabled "llm_output_sanitizer" "false"
                echo -e "${YELLOW}⛔ Tous les guards désactivés${NC}"
            else
                local key; key=$(guard_key "$target")
                [[ -z "$key" ]] && { echo -e "${RED}Guard inconnu: $target${NC}"; exit 1; }
                set_enabled "$key" "false"
                echo -e "${YELLOW}⛔ $target désactivé${NC}"
            fi
            show_status
            ;;

        mode)
            local key; key=$(guard_key "$target")
            local new_mode="${3:-}"
            [[ -z "$key" ]] && { echo -e "${RED}Guard inconnu: $target${NC}"; exit 1; }
            [[ -z "$new_mode" ]] && { echo -e "${RED}Mode manquant${NC}"; exit 1; }
            set_mode "$key" "$new_mode"
            echo -e "${GREEN}✅ $target → mode: $new_mode${NC}"
            show_status
            ;;

        *)
            echo "Usage: security-guards {status|on|off|mode} [guard] [mode]"
            echo "  Guards : supply-chain | llm-sanitizer | all"
            echo "  Modes  : supply-chain → block|warn   llm-sanitizer → external-only|strict"
            exit 1
            ;;
    esac
}

# Exécuter seulement si appelé directement (pas si sourcé par un hook)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
