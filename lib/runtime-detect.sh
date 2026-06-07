#!/usr/bin/env bash
# ============================================================================
# runtime-detect.sh - Détection Runtime et Recommandations Performance
# Harmony Framework
# ============================================================================
# SÉCURITÉ: Ce script ne modifie RIEN - détection et affichage uniquement
# ============================================================================

# Only set strict mode when running as standalone (not when sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi
fi

# ============================================================================
# DÉTECTION OS
# ============================================================================
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

detect_linux_distro() {
    [[ -f /etc/os-release ]] && { . /etc/os-release; echo "${ID:-unknown}"; return; }
    [[ -f /etc/debian_version ]] && echo "debian" && return
    [[ -f /etc/redhat-release ]] && echo "rhel" && return
    [[ -f /etc/arch-release ]] && echo "arch" && return
    echo "unknown"
}

detect_distro_family() {
    local distro="${1:-$(detect_linux_distro)}"
    case "$distro" in
        ubuntu|debian|mint|pop|kali|raspbian) echo "debian" ;;
        rhel|centos|fedora|rocky|alma|amazon) echo "redhat" ;;
        arch|manjaro|endeavouros) echo "arch" ;;
        opensuse*|suse) echo "suse" ;;
        alpine) echo "alpine" ;;
        *) echo "unknown" ;;
    esac
}

detect_os_version() {
    local os=$(detect_os)
    case "$os" in
        linux) [[ -f /etc/os-release ]] && { . /etc/os-release; echo "${VERSION_ID:-}"; } ;;
        macos) sw_vers -productVersion 2>/dev/null ;;
    esac
}

detect_package_manager() {
    local os=$(detect_os)
    case "$os" in
        linux)
            case "$(detect_distro_family)" in
                debian) echo "apt" ;;
                redhat) command -v dnf &>/dev/null && echo "dnf" || echo "yum" ;;
                arch) echo "pacman" ;;
                suse) echo "zypper" ;;
                alpine) echo "apk" ;;
                *) echo "unknown" ;;
            esac ;;
        macos) command -v brew &>/dev/null && echo "brew" || echo "none" ;;
        windows) echo "manual" ;;
    esac
}

# ============================================================================
# DÉTECTION VERSIONS
# ============================================================================
detect_bash_version() { bash --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1; }
detect_node_version() { command -v node &>/dev/null && node --version 2>/dev/null | sed 's/v//'; }
detect_bun_version() { command -v bun &>/dev/null && bun --version 2>/dev/null; }
detect_jq_version() { command -v jq &>/dev/null && jq --version 2>/dev/null | sed 's/jq-//'; }
detect_yq_version() { command -v yq &>/dev/null && yq --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1; }

detect_best_runtime() {
    [[ -n "$(detect_bun_version)" ]] && echo "bun" && return
    [[ -n "$(detect_node_version)" ]] && echo "node" && return
    echo "bash"
}

detect_performance_level() {
    [[ -n "$(detect_bun_version)" ]] && echo "turbo" && return
    [[ -n "$(detect_node_version)" && -n "$(detect_jq_version)" ]] && echo "enhanced" && return
    [[ -n "$(detect_node_version)" ]] && echo "standard" && return
    echo "basic"
}

# ============================================================================
# SORTIE JSON
# ============================================================================
detect_system_info() {
    cat <<EOF
{
  "os": "$(detect_os)",
  "distro": "$(detect_linux_distro)",
  "family": "$(detect_distro_family)",
  "version": "$(detect_os_version)",
  "package_manager": "$(detect_package_manager)",
  "bash": "$(detect_bash_version)",
  "node": "$(detect_node_version)",
  "bun": "$(detect_bun_version)",
  "jq": "$(detect_jq_version)",
  "yq": "$(detect_yq_version)",
  "best_runtime": "$(detect_best_runtime)",
  "performance_level": "$(detect_performance_level)"
}
EOF
}

# ============================================================================
# COMMANDES D'INSTALLATION (PAS D'EXÉCUTION - AFFICHAGE SEULEMENT)
# ============================================================================
get_install_cmd() {
    local tool="$1"
    local family=$(detect_distro_family)
    local os=$(detect_os)

    case "$os" in
        macos)
            case "$tool" in
                node) echo "brew install node" ;;
                bun) echo "brew install bun" ;;
                jq) echo "brew install jq" ;;
                yq) echo "brew install yq" ;;
            esac ;;
        linux)
            case "$family" in
                debian)
                    case "$tool" in
                        node) echo "sudo apt install -y nodejs npm" ;;
                        bun) echo "curl -fsSL https://bun.sh/install | bash" ;;
                        jq) echo "sudo apt install -y jq" ;;
                        yq) echo "sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq" ;;
                    esac ;;
                redhat)
                    case "$tool" in
                        node) echo "sudo dnf install -y nodejs npm" ;;
                        bun) echo "curl -fsSL https://bun.sh/install | bash" ;;
                        jq) echo "sudo dnf install -y jq" ;;
                        yq) echo "sudo dnf install -y yq  # Or: snap install yq" ;;
                    esac ;;
                arch)
                    case "$tool" in
                        node) echo "sudo pacman -S nodejs npm" ;;
                        bun) echo "curl -fsSL https://bun.sh/install | bash" ;;
                        jq) echo "sudo pacman -S jq" ;;
                        yq) echo "sudo pacman -S yq  # AUR: yay -S yq-bin" ;;
                    esac ;;
            esac ;;
    esac
}

# ============================================================================
# EXÉCUTION DIRECTE
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --json) detect_system_info ;;
        --os) detect_os ;;
        --distro) detect_linux_distro ;;
        --family) detect_distro_family ;;
        --pm) detect_package_manager ;;
        --runtime) detect_best_runtime ;;
        --level) detect_performance_level ;;
        --bash) detect_bash_version ;;
        --node) detect_node_version ;;
        --bun) detect_bun_version ;;
        --jq) detect_jq_version ;;
        --yq) detect_yq_version ;;
        --install)
            [[ -z "${2:-}" ]] && echo "Usage: $0 --install <node|bun|jq|yq>" && exit 1
            get_install_cmd "$2"
            ;;
        *) detect_system_info ;;
    esac
fi
