#!/usr/bin/env bash
# ============================================================================
# ui-library.sh - Bibliothèque UI Unifiée pour Harmony Framework
# ============================================================================
# Fournit une interface utilisateur cohérente et professionnelle pour tous
# les scripts d'installation et de configuration.
#
# Usage: source ui-library.sh
#
# Fonctions disponibles:
#   - ui_init                    : Initialiser l'UI (calculer centrage)
#   - ui_welcome                 : Écran d'accueil avec logo
#   - ui_confirm                 : Dialogue de confirmation Yes/No/Quit
#   - ui_menu                    : Menu à choix multiples
#   - ui_progress                : Barre de progression
#   - ui_box_*                   : Fonctions de dessin de boîtes
#   - ui_status                  : Afficher un statut avec icône
#   - ui_tip                     : Afficher un tip formaté
#   - ui_section                 : Afficher une section
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly UI_VERSION="1.0.0"
readonly UI_BOX_WIDTH=70
readonly UI_INNER_WIDTH=66

# ============================================================================
# DÉTECTION TERMINAL
# ============================================================================
_UI_TERM_WIDTH=80
_UI_PADDING=""
_UI_HAS_COLOR=false
_UI_INTERACTIVE=false

# ============================================================================
# COULEURS (automatiquement désactivées si non-TTY)
# ============================================================================
_ui_setup_colors() {
    if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
        _UI_HAS_COLOR=true
        # Couleurs de base
        UI_RED='\033[0;31m'
        UI_GREEN='\033[0;32m'
        UI_YELLOW='\033[1;33m'
        UI_BLUE='\033[0;34m'
        UI_PURPLE='\033[0;35m'
        UI_CYAN='\033[0;36m'
        UI_WHITE='\033[1;37m'
        UI_BLACK='\033[0;30m'
        UI_GRAY='\033[0;90m'
        # Couleurs de fond
        UI_BG_GREEN='\033[42m'
        UI_BG_RED='\033[41m'
        UI_BG_BLUE='\033[44m'
        UI_BG_YELLOW='\033[43m'
        # Styles
        UI_BOLD='\033[1m'
        UI_DIM='\033[2m'
        UI_UNDERLINE='\033[4m'
        UI_RESET='\033[0m'
    else
        _UI_HAS_COLOR=false
        UI_RED='' UI_GREEN='' UI_YELLOW='' UI_BLUE=''
        UI_PURPLE='' UI_CYAN='' UI_WHITE='' UI_BLACK='' UI_GRAY=''
        UI_BG_GREEN='' UI_BG_RED='' UI_BG_BLUE='' UI_BG_YELLOW=''
        UI_BOLD='' UI_DIM='' UI_UNDERLINE='' UI_RESET=''
    fi
}

# ============================================================================
# INITIALISATION
# ============================================================================
ui_init() {
    _ui_setup_colors

    # Détecter largeur terminal
    if command -v tput &>/dev/null && [[ -t 1 ]]; then
        _UI_TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
    fi

    # Calculer padding pour centrage
    local pad_size=$(( (_UI_TERM_WIDTH - UI_BOX_WIDTH) / 2 ))
    [[ $pad_size -lt 0 ]] && pad_size=0
    _UI_PADDING=$(printf '%*s' "$pad_size" '')

    # Vérifier si interactif
    if [[ -t 0 ]] && [[ -t 1 ]]; then
        _UI_INTERACTIVE=true
    fi
}

# ============================================================================
# FONCTIONS DE DESSIN DE BOÎTES
# ============================================================================

# Ligne horizontale (haut, milieu, bas)
ui_box_line() {
    local type="${1:-mid}"
    case "$type" in
        top)  echo -e "${_UI_PADDING}${UI_BOLD}╔══════════════════════════════════════════════════════════════════════╗${UI_RESET}" ;;
        mid)  echo -e "${_UI_PADDING}${UI_BOLD}╠══════════════════════════════════════════════════════════════════════╣${UI_RESET}" ;;
        bot)  echo -e "${_UI_PADDING}${UI_BOLD}╚══════════════════════════════════════════════════════════════════════╝${UI_RESET}" ;;
        thin) echo -e "${_UI_PADDING}${UI_BOLD}╟──────────────────────────────────────────────────────────────────────╢${UI_RESET}" ;;
    esac
}

# Ligne avec contenu centré
ui_box_title() {
    local text="$1"
    local text_len=${#text}
    local pad_left=$(( (UI_INNER_WIDTH - text_len) / 2 ))
    local pad_right=$(( UI_INNER_WIDTH - text_len - pad_left ))
    printf "${_UI_PADDING}${UI_BOLD}║%*s%s%*s║${UI_RESET}\n" "$((pad_left + 2))" "" "$text" "$((pad_right + 2))" ""
}

# Ligne avec contenu aligné à gauche
ui_box_text() {
    local text="$1"
    printf "${_UI_PADDING}║  %-68s║\n" "$text"
}

# Ligne vide
ui_box_empty() {
    echo -e "${_UI_PADDING}║                                                                      ║"
}

# Ligne avec icône de statut
ui_box_status() {
    local icon="$1"    # ok, warn, error, info
    local label="$2"
    local value="$3"

    local icon_char color
    case "$icon" in
        ok)    icon_char="✓"; color="$UI_GREEN" ;;
        warn)  icon_char="!"; color="$UI_YELLOW" ;;
        error) icon_char="✗"; color="$UI_RED" ;;
        info)  icon_char="i"; color="$UI_CYAN" ;;
        *)     icon_char="·"; color="$UI_RESET" ;;
    esac

    printf "${_UI_PADDING}║  ${color}[${icon_char}]${UI_RESET} %-64s║\n" "${label}: ${value}"
}

# ============================================================================
# ÉCRAN D'ACCUEIL
# ============================================================================
ui_welcome() {
    local version="${1:-1.0.0}"
    local tagline="${2:-Self-Improving AI Development}"

    clear 2>/dev/null || true
    echo ""

    ui_box_line top
    ui_box_empty

    # Logo ASCII Art (simplifié pour compatibilité)
    printf "${_UI_PADDING}║    ${UI_PURPLE}${UI_BOLD}██╗  ██╗ █████╗ ██████╗ ███╗   ███╗ ██████╗ ███╗   ██╗██╗   ██╗${UI_RESET}    ║\n"
    printf "${_UI_PADDING}║    ${UI_PURPLE}${UI_BOLD}██║  ██║██╔══██╗██╔══██╗████╗ ████║██╔═══██╗████╗  ██║╚██╗ ██╔╝${UI_RESET}    ║\n"
    printf "${_UI_PADDING}║    ${UI_PURPLE}${UI_BOLD}███████║███████║██████╔╝██╔████╔██║██║   ██║██╔██╗ ██║ ╚████╔╝${UI_RESET}     ║\n"
    printf "${_UI_PADDING}║    ${UI_PURPLE}${UI_BOLD}██╔══██║██╔══██║██╔══██╗██║╚██╔╝██║██║   ██║██║╚██╗██║  ╚██╔╝${UI_RESET}      ║\n"
    printf "${_UI_PADDING}║    ${UI_PURPLE}${UI_BOLD}██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║   ██║${UI_RESET}       ║\n"
    printf "${_UI_PADDING}║    ${UI_PURPLE}${UI_BOLD}╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝${UI_RESET}       ║\n"

    ui_box_empty
    ui_box_title "F R A M E W O R K"
    ui_box_empty
    ui_box_title "$tagline"
    ui_box_empty
    printf "${_UI_PADDING}║                          ${UI_CYAN}Version ${version}${UI_RESET}                             ║\n"
    ui_box_empty
    ui_box_line thin
    ui_box_empty
    printf "${_UI_PADDING}║       ${UI_DIM}\"${UI_RESET}${UI_WHITE}Built by developers, for developers — with performance in mind${UI_RESET}${UI_DIM}\"${UI_RESET}       ║\n"
    ui_box_empty
    ui_box_line mid

    # Trois piliers
    ui_box_empty
    printf "${_UI_PADDING}║    ${UI_GREEN}◆${UI_RESET} ${UI_BOLD}Guardian${UI_RESET}   │  Intent detection, agent routing, protection     ║\n"
    printf "${_UI_PADDING}║    ${UI_YELLOW}◆${UI_RESET} ${UI_BOLD}Sentinel${UI_RESET}   │  Error memory, circuit breaker, auto-learning    ║\n"
    printf "${_UI_PADDING}║    ${UI_CYAN}◆${UI_RESET} ${UI_BOLD}HQVF${UI_RESET}       │  Use Case Verifiables, triple validation         ║\n"
    ui_box_empty

    ui_box_line bot
    echo ""
}

# ============================================================================
# DIALOGUE DE CONFIRMATION
# ============================================================================

# Afficher le sélecteur Oui/Non
_ui_draw_selector() {
    local sel=$1
    printf "\r${_UI_PADDING}  "
    if [[ $sel -eq 0 ]]; then
        printf "${UI_BG_GREEN}${UI_BLACK} ▶ Oui ${UI_RESET}    "
        printf "${UI_DIM}   Non ${UI_RESET}"
    else
        printf "${UI_DIM}   Oui ${UI_RESET}    "
        printf "${UI_BG_RED}${UI_WHITE} ▶ Non ${UI_RESET}"
    fi
    printf "   ${UI_DIM}(←/→ ou Tab pour changer, Entrée pour valider)${UI_RESET}"
}

ui_confirm() {
    local question="${1:-Voulez-vous continuer ?}"
    local default="${2:-yes}"  # yes, no

    ui_box_line top
    ui_box_empty
    ui_box_title "$question"
    ui_box_empty
    ui_box_line thin

    ui_box_line bot
    echo ""

    # Vérifier si on peut accéder à /dev/tty (test réel d'ouverture)
    if ! { exec 3>/dev/tty; } 2>/dev/null; then
        # Pas d'accès au terminal, utiliser défaut silencieusement
        printf "${_UI_PADDING}  ${UI_DIM}(Mode non-interactif: défaut = %s)${UI_RESET}\n" "$default"
        [[ "$default" == "yes" ]] && return 0 || return 1
    fi
    exec 3>&- 2>/dev/null  # Fermer le descripteur de test

    # Sélecteur interactif avec flèches/tab
    local selected=0  # 0=Oui, 1=Non
    [[ "$default" != "yes" ]] && selected=1

    # Sauvegarder et configurer le terminal via /dev/tty
    local old_stty
    old_stty=$(stty -g </dev/tty 2>/dev/null) || {
        # stty a échoué, mode non-interactif
        printf "${_UI_PADDING}  ${UI_DIM}(Mode non-interactif: défaut = %s)${UI_RESET}\n" "$default"
        [[ "$default" == "yes" ]] && return 0 || return 1
    }

    stty -echo -icanon min 1 </dev/tty 2>/dev/null || {
        # Configuration échouée, mode non-interactif
        [[ -n "$old_stty" ]] && stty "$old_stty" </dev/tty 2>/dev/null
        printf "${_UI_PADDING}  ${UI_DIM}(Mode non-interactif: défaut = %s)${UI_RESET}\n" "$default"
        [[ "$default" == "yes" ]] && return 0 || return 1
    }

    # Affichage initial
    _ui_draw_selector $selected

    # Lecture des touches depuis /dev/tty
    local key char
    while true; do
        # Lire un caractère depuis /dev/tty
        IFS= read -rsn1 key </dev/tty 2>/dev/null || {
            # Lecture échouée, restaurer et retourner défaut
            [[ -n "$old_stty" ]] && stty "$old_stty" </dev/tty 2>/dev/null
            echo ""
            [[ "$default" == "yes" ]] && return 0 || return 1
        }

        case "$key" in
            $'\x1b')  # Début séquence escape (flèches)
                # Lire les 2 caractères suivants
                IFS= read -rsn1 -t 0.1 char </dev/tty 2>/dev/null || char=""
                if [[ "$char" == "[" ]]; then
                    IFS= read -rsn1 -t 0.1 char </dev/tty 2>/dev/null || char=""
                    case "$char" in
                        'D'|'C')  # Gauche ou Droite
                            selected=$(( (selected + 1) % 2 ))
                            ;;
                    esac
                fi
                ;;
            $'\t')  # Tab
                selected=$(( (selected + 1) % 2 ))
                ;;
            '')  # Entrée
                # Restaurer le terminal
                [[ -n "$old_stty" ]] && stty "$old_stty" </dev/tty 2>/dev/null
                echo ""
                [[ $selected -eq 0 ]] && return 0 || return 1
                ;;
        esac
        _ui_draw_selector $selected
    done

    # Restaurer le terminal en cas de break (ne devrait pas arriver)
    [[ -n "$old_stty" ]] && stty "$old_stty" </dev/tty 2>/dev/null
    echo ""
    [[ "$default" == "yes" ]] && return 0 || return 1
}

# ============================================================================
# AFFICHAGE DE TIP
# ============================================================================
ui_tip() {
    local tip_num="$1"
    local tip_total="$2"
    local tip_title="$3"
    local tip_content="$4"

    ui_box_line top
    printf "${_UI_PADDING}║  ${UI_CYAN}💡 TIP ${tip_num}/${tip_total}${UI_RESET}                                                       ║\n"
    ui_box_title "$tip_title"
    ui_box_line thin
    ui_box_empty

    # Afficher le contenu ligne par ligne
    while IFS= read -r line; do
        # Tronquer si trop long
        if [[ ${#line} -gt 66 ]]; then
            line="${line:0:63}..."
        fi
        printf "${_UI_PADDING}║  %-68s║\n" "$line"
    done <<< "$tip_content"

    ui_box_empty
    ui_box_line bot

    if [[ "$_UI_INTERACTIVE" == true ]]; then
        printf "\n${_UI_PADDING}  ${UI_DIM}Appuyez sur Entrée pour continuer...${UI_RESET}"
        read -r </dev/tty 2>/dev/null || sleep 2
    else
        sleep 2
    fi
}

# ============================================================================
# SECTION D'INSTALLATION
# ============================================================================
ui_section() {
    local step="$1"
    local title="$2"
    local status="${3:-running}"  # running, done, skip

    local icon color
    case "$status" in
        running) icon="⟳"; color="$UI_CYAN" ;;
        done)    icon="✓"; color="$UI_GREEN" ;;
        skip)    icon="–"; color="$UI_GRAY" ;;
        error)   icon="✗"; color="$UI_RED" ;;
    esac

    printf "${_UI_PADDING}${color}[${step}]${UI_RESET} ${icon} ${title}\n"
}

# ============================================================================
# BARRE DE PROGRESSION
# ============================================================================
ui_progress() {
    local current="$1"
    local total="$2"
    local label="${3:-Progression}"

    local percent=$((current * 100 / total))
    local filled=$((percent / 2))  # 50 chars max
    local empty=$((50 - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    printf "\r${_UI_PADDING}  ${label}: [${UI_CYAN}${bar}${UI_RESET}] ${percent}%%"

    [[ $current -eq $total ]] && echo ""
}

# ============================================================================
# MESSAGE FINAL
# ============================================================================
ui_success() {
    local title="${1:-Installation réussie !}"
    local message="${2:-}"

    echo ""
    ui_box_line top
    ui_box_empty
    printf "${_UI_PADDING}║                    ${UI_GREEN}${UI_BOLD}✓ SUCCESS${UI_RESET}                                 ║\n"
    ui_box_empty
    ui_box_title "$title"
    ui_box_empty

    if [[ -n "$message" ]]; then
        ui_box_line thin
        ui_box_empty
        while IFS= read -r line; do
            printf "${_UI_PADDING}║  %-68s║\n" "$line"
        done <<< "$message"
        ui_box_empty
    fi

    ui_box_line bot
    echo ""
}

ui_error() {
    local title="${1:-Une erreur est survenue}"
    local message="${2:-}"

    echo ""
    ui_box_line top
    ui_box_empty
    printf "${_UI_PADDING}║                    ${UI_RED}${UI_BOLD}✗ ERROR${UI_RESET}                                   ║\n"
    ui_box_empty
    ui_box_title "$title"
    ui_box_empty

    if [[ -n "$message" ]]; then
        ui_box_line thin
        ui_box_empty
        while IFS= read -r line; do
            printf "${_UI_PADDING}║  ${UI_RED}%-68s${UI_RESET}║\n" "$line"
        done <<< "$message"
        ui_box_empty
    fi

    ui_box_line bot
    echo ""
}

# ============================================================================
# PAUSE INTERACTIVE (Appuyez sur Entrée pour continuer)
# ============================================================================
ui_continue() {
    local message="${1:-Appuyez sur Entrée pour continuer...}"

    if [[ "$_UI_INTERACTIVE" == true ]]; then
        echo ""
        printf "${_UI_PADDING}  ${UI_DIM}${message}${UI_RESET}"
        read -r </dev/tty 2>/dev/null || sleep 1
        echo ""
    else
        # Non-interactif: petite pause
        sleep 1
    fi
}

# ============================================================================
# ÉTAPE D'INSTALLATION AVEC PAUSE
# ============================================================================
ui_step() {
    local step_num="$1"
    local step_total="$2"
    local title="$3"
    local status="${4:-running}"  # running, done, skip

    local icon color
    case "$status" in
        running) icon="⟳"; color="$UI_CYAN" ;;
        done)    icon="✓"; color="$UI_GREEN" ;;
        skip)    icon="–"; color="$UI_GRAY" ;;
        error)   icon="✗"; color="$UI_RED" ;;
    esac

    ui_box_line top
    printf "${_UI_PADDING}║  ${color}[${step_num}/${step_total}]${UI_RESET} ${icon} %-58s║\n" "$title"
    ui_box_line bot
}

# ============================================================================
# EXPORT POUR SOURCING
# ============================================================================
export -f ui_init ui_box_line ui_box_title ui_box_text ui_box_empty ui_box_status
export -f ui_welcome ui_confirm ui_tip ui_section ui_progress ui_success ui_error
export -f ui_continue ui_step

# ============================================================================
# TEST SI EXÉCUTÉ DIRECTEMENT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ui_init
    ui_welcome "1.0.22" "Self-Improving AI Development"

    if ui_confirm "Voulez-vous installer Harmony Framework ?" "yes"; then
        ui_section "1/3" "Vérification des prérequis" "running"
        sleep 1
        ui_section "1/3" "Vérification des prérequis" "done"

        ui_section "2/3" "Installation des fichiers" "running"
        for i in {1..10}; do
            ui_progress $i 10 "Installation"
            sleep 0.2
        done
        ui_section "2/3" "Installation des fichiers" "done"

        ui_section "3/3" "Configuration" "running"
        sleep 1
        ui_section "3/3" "Configuration" "done"

        ui_success "Harmony Framework installé !" "Prochaines étapes:
1. Exécutez /go pour démarrer
2. Consultez .harmony/docs/
3. Happy coding!"
    else
        echo "Installation annulée."
    fi
fi
