#!/bin/bash
# ============================================================================
# Harmony Framework - Analysis Tracker
# ============================================================================
# Tracks analysis sessions for continuity across compacting.
# Ensures the reasoning chain is preserved for decision-making.
#
# Features:
#   - Automatic tracking of analysis/research sessions
#   - Reasoning chain preservation (steps, findings, comparisons)
#   - Auto-save to /tmp for recovery
#   - Export to research/ for permanent storage
#   - Session resume capability
# ============================================================================

set -euo pipefail

# Configuration
HARMONY_DIR="${HARMONY_DIR:-.harmony}"
ANALYSIS_DIR="${HARMONY_DIR}/local/tmp/sessions"  # Project-specific, within .harmony
ANALYSIS_FILE=""  # Set dynamically per session
CONFIG_FILE="${HARMONY_DIR}/local/session-config.json"

# Default rotation settings (can be overridden by CONFIG_FILE)
MAX_SESSIONS=5              # Keep max 5 sessions
MAX_AGE_DAYS=7              # Delete sessions older than 7 days
MAX_DISK_MB=50              # Max 50MB for sessions
CLEANUP_ON_EXPORT=true      # Delete from /tmp after export to research/

# Load local config if exists
load_session_config() {
    if [[ -f "$CONFIG_FILE" ]] && command -v jq &>/dev/null; then
        local config=$(cat "$CONFIG_FILE")
        MAX_SESSIONS=$(echo "$config" | jq -r '.max_sessions // 5')
        MAX_AGE_DAYS=$(echo "$config" | jq -r '.max_age_days // 7')
        MAX_DISK_MB=$(echo "$config" | jq -r '.max_disk_mb // 50')
        CLEANUP_ON_EXPORT=$(echo "$config" | jq -r '.cleanup_on_export // true')
    fi
}

# Create default config if not exists
init_session_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
        cat > "$CONFIG_FILE" << 'EOF'
{
    "max_sessions": 5,
    "max_age_days": 7,
    "max_disk_mb": 50,
    "cleanup_on_export": true,
    "_comment": "Configuration locale pour la rotation des sessions d'analyse"
}
EOF
        echo -e "${DIM}[Config créée: $CONFIG_FILE]${NC}" >&2
    fi
}

# Initialize config on source
load_session_config

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================================
# Rotation & Cleanup
# ============================================================================

cleanup_old_sessions() {
    # Delete sessions older than MAX_AGE_DAYS
    if [[ -d "$ANALYSIS_DIR" ]]; then
        local deleted=0
        find "$ANALYSIS_DIR" -maxdepth 1 -type d -mtime +${MAX_AGE_DAYS} 2>/dev/null | while read -r old_dir; do
            if [[ "$old_dir" != "$ANALYSIS_DIR" ]]; then
                rm -rf "$old_dir"
                deleted=$((deleted + 1))
            fi
        done
        if [[ $deleted -gt 0 ]]; then
            echo -e "${DIM}[Rotation: $deleted sessions > ${MAX_AGE_DAYS}j supprimées]${NC}" >&2
        fi
    fi
}

cleanup_excess_sessions() {
    # Keep only MAX_SESSIONS most recent
    if [[ -d "$ANALYSIS_DIR" ]]; then
        local count=$(find "$ANALYSIS_DIR" -maxdepth 1 -type d ! -path "$ANALYSIS_DIR" 2>/dev/null | wc -l)
        if [[ $count -gt $MAX_SESSIONS ]]; then
            local to_delete=$((count - MAX_SESSIONS))
            # Sort by modification time, oldest first, delete excess
            find "$ANALYSIS_DIR" -maxdepth 1 -type d ! -path "$ANALYSIS_DIR" -printf '%T+ %p\n' 2>/dev/null | \
                sort | head -n $to_delete | cut -d' ' -f2- | while read -r old_dir; do
                rm -rf "$old_dir"
            done
            echo -e "${DIM}[Rotation: $to_delete sessions excédentaires supprimées (max: $MAX_SESSIONS)]${NC}" >&2
        fi
    fi
}

cleanup_exported_session() {
    local session_id="$1"
    if [[ "$CLEANUP_ON_EXPORT" == true && -d "$ANALYSIS_DIR/$session_id" ]]; then
        rm -rf "$ANALYSIS_DIR/$session_id"
        echo -e "${DIM}[Session $session_id supprimée de /tmp (exportée)]${NC}" >&2
    fi
}

cleanup_all_sessions() {
    if [[ -d "$ANALYSIS_DIR" ]]; then
        local count=$(find "$ANALYSIS_DIR" -maxdepth 1 -type d ! -path "$ANALYSIS_DIR" 2>/dev/null | wc -l)
        rm -rf "$ANALYSIS_DIR"/*
        echo -e "${GREEN}$count sessions supprimées de $ANALYSIS_DIR${NC}"
    else
        echo -e "${YELLOW}Aucune session à supprimer${NC}"
    fi
}

cleanup_session() {
    local session_id="$1"
    if [[ -d "$ANALYSIS_DIR/$session_id" ]]; then
        rm -rf "$ANALYSIS_DIR/$session_id"
        echo -e "${GREEN}Session $session_id supprimée${NC}"
    else
        echo -e "${YELLOW}Session $session_id non trouvée${NC}"
    fi
}

cleanup_by_disk_usage() {
    # Delete oldest sessions if over MAX_DISK_MB
    if [[ -d "$ANALYSIS_DIR" ]]; then
        local current_kb=$(du -sk "$ANALYSIS_DIR" 2>/dev/null | cut -f1)
        local max_kb=$((MAX_DISK_MB * 1024))

        while [[ $current_kb -gt $max_kb ]]; do
            # Find and delete oldest session
            local oldest=$(find "$ANALYSIS_DIR" -maxdepth 1 -type d ! -path "$ANALYSIS_DIR" -printf '%T+ %p\n' 2>/dev/null | sort | head -1 | cut -d' ' -f2-)
            if [[ -n "$oldest" && -d "$oldest" ]]; then
                rm -rf "$oldest"
                echo -e "${DIM}[Rotation disque: $(basename "$oldest") supprimée (>${MAX_DISK_MB}MB)]${NC}" >&2
                current_kb=$(du -sk "$ANALYSIS_DIR" 2>/dev/null | cut -f1)
            else
                break
            fi
        done
    fi
}

run_rotation() {
    # Run all cleanup strategies
    cleanup_old_sessions      # Delete > MAX_AGE_DAYS
    cleanup_excess_sessions   # Keep only MAX_SESSIONS
    cleanup_by_disk_usage     # Keep under MAX_DISK_MB
}

get_sessions_disk_usage() {
    if [[ -d "$ANALYSIS_DIR" ]]; then
        du -sh "$ANALYSIS_DIR" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

list_sessions_with_size() {
    if [[ -d "$ANALYSIS_DIR" ]]; then
        echo -e "${CYAN}Sessions en cours:${NC}"
        echo ""
        for session_dir in "$ANALYSIS_DIR"/*/; do
            if [[ -d "$session_dir" ]]; then
                local size=$(du -sh "$session_dir" 2>/dev/null | cut -f1)
                local session_id=$(basename "$session_dir")
                local age_days=$(( ($(date +%s) - $(stat -c %Y "$session_dir" 2>/dev/null || stat -f %m "$session_dir" 2>/dev/null)) / 86400 ))

                local title="Sans titre"
                if [[ -f "${session_dir}analysis.json" ]]; then
                    title=$(jq -r '.title // "Sans titre"' "${session_dir}analysis.json" 2>/dev/null | head -c 40)
                fi

                echo -e "  ${WHITE}[$session_id]${NC} $size | ${age_days}j | $title"
            fi
        done
        echo ""
        echo -e "${CYAN}Total: $(get_sessions_disk_usage)${NC}"
    else
        echo "Aucune session"
    fi
}

# ============================================================================
# Session Management
# ============================================================================

generate_session_id() {
    if command -v uuidgen &>/dev/null; then
        uuidgen | cut -d'-' -f1
    else
        date +%s | sha256sum | head -c 8
    fi
}

get_current_session_dir() {
    local session_id="${1:-}"

    if [[ -z "$session_id" ]]; then
        # Find most recent session
        if [[ -d "$ANALYSIS_DIR" ]]; then
            ls -td "$ANALYSIS_DIR"/*/ 2>/dev/null | head -1
        fi
    else
        echo "$ANALYSIS_DIR/$session_id"
    fi
}

init_analysis_session() {
    local title="${1:-Untitled Analysis}"
    local type="${2:-general}"  # architecture_decision, research, comparison, investigation

    # Run rotation before creating new session
    run_rotation

    local session_id=$(generate_session_id)
    local session_dir="$ANALYSIS_DIR/$session_id"

    mkdir -p "$session_dir"

    ANALYSIS_FILE="$session_dir/analysis.json"

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    cat > "$ANALYSIS_FILE" << EOF
{
    "session_id": "$session_id",
    "title": "$title",
    "type": "$type",
    "status": "in_progress",
    "created_at": "$now",
    "updated_at": "$now",
    "project_dir": "$(pwd)",

    "reasoning_chain": [],
    "findings": [],
    "comparisons": [],
    "decisions": [],
    "files_context": {
        "read": [],
        "modified": [],
        "created": []
    },
    "open_questions": [],
    "next_steps": [],
    "conclusion": null
}
EOF

    echo "$session_id"
}

# ============================================================================
# Reasoning Chain
# ============================================================================

add_reasoning_step() {
    local thought="$1"
    local evidence="${2:-}"
    local conclusion="${3:-}"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        echo "No active analysis session" >&2
        return 1
    fi

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    local step_num=$(jq '.reasoning_chain | length + 1' "$ANALYSIS_FILE")

    local step_json=$(cat << EOF
{
    "step": $step_num,
    "thought": $(echo "$thought" | jq -Rs .),
    "evidence": $(echo "$evidence" | jq -Rs .),
    "conclusion": $(echo "$conclusion" | jq -Rs .),
    "timestamp": "$now"
}
EOF
)

    local tmp=$(mktemp)
    jq --argjson step "$step_json" '.reasoning_chain += [$step] | .updated_at = "'"$now"'"' "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"

    echo "Step $step_num added"
}

add_finding() {
    local key="$1"
    local value="$2"
    local source="${3:-observation}"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        return 1
    fi

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    local finding_json=$(cat << EOF
{
    "key": $(echo "$key" | jq -Rs .),
    "value": $(echo "$value" | jq -Rs .),
    "source": "$source",
    "timestamp": "$now"
}
EOF
)

    local tmp=$(mktemp)
    jq --argjson finding "$finding_json" '.findings += [$finding] | .updated_at = "'"$now"'"' "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"
}

add_comparison() {
    local item_a="$1"
    local item_b="$2"
    local criteria="$3"
    local winner="${4:-}"
    local notes="${5:-}"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        return 1
    fi

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    local comparison_json=$(cat << EOF
{
    "item_a": $(echo "$item_a" | jq -Rs .),
    "item_b": $(echo "$item_b" | jq -Rs .),
    "criteria": $(echo "$criteria" | jq -Rs .),
    "winner": $(echo "$winner" | jq -Rs .),
    "notes": $(echo "$notes" | jq -Rs .),
    "timestamp": "$now"
}
EOF
)

    local tmp=$(mktemp)
    jq --argjson comp "$comparison_json" '.comparisons += [$comp] | .updated_at = "'"$now"'"' "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"
}

mark_decision() {
    local decision="$1"
    local rationale="$2"
    local actions_taken="${3:-}"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        return 1
    fi

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    local decision_json=$(cat << EOF
{
    "decision": $(echo "$decision" | jq -Rs .),
    "rationale": $(echo "$rationale" | jq -Rs .),
    "actions_taken": $(echo "$actions_taken" | jq -Rs .),
    "timestamp": "$now"
}
EOF
)

    local tmp=$(mktemp)
    jq --argjson dec "$decision_json" '.decisions += [$dec] | .updated_at = "'"$now"'"' "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"
}

add_file_context() {
    local action="$1"  # read, modified, created
    local file="$2"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        return 1
    fi

    local tmp=$(mktemp)
    jq --arg file "$file" ".files_context.$action += [\$file] | .files_context.$action = (.files_context.$action | unique)" "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"
}

set_conclusion() {
    local conclusion="$1"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        return 1
    fi

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    local tmp=$(mktemp)
    jq --arg conc "$conclusion" '.conclusion = $conc | .status = "completed" | .updated_at = "'"$now"'"' "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"
}

# ============================================================================
# Export Functions
# ============================================================================

export_to_markdown() {
    local output_file="${1:-}"

    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        echo "No active analysis session" >&2
        return 1
    fi

    local data=$(cat "$ANALYSIS_FILE")
    local title=$(echo "$data" | jq -r '.title')
    local type=$(echo "$data" | jq -r '.type')
    local status=$(echo "$data" | jq -r '.status')
    local session_id=$(echo "$data" | jq -r '.session_id')
    local created_at=$(echo "$data" | jq -r '.created_at')

    if [[ -z "$output_file" ]]; then
        local date_str=$(date +%Y%m%d-%H%M)
        local safe_title=$(echo "$title" | tr ' ' '-' | tr -cd '[:alnum:]-' | head -c 30)
        output_file="research/SESSION-${date_str}-${safe_title}.md"
    fi

    mkdir -p "$(dirname "$output_file")"

    cat > "$output_file" << EOF
# $title

**Session:** $session_id | **Date:** $created_at | **Status:** $status | **Type:** $type

---

## Fil de raisonnement

EOF

    # Add reasoning steps
    echo "$data" | jq -r '.reasoning_chain[] | "### Étape \(.step): \(.thought)\n\(.evidence | if . != "" then "- Evidence: \(.)" else "" end)\n\(.conclusion | if . != "" then "**Conclusion:** \(.)" else "" end)\n"' >> "$output_file"

    # Add findings
    local findings_count=$(echo "$data" | jq '.findings | length')
    if [[ "$findings_count" -gt 0 ]]; then
        echo -e "\n## Découvertes\n" >> "$output_file"
        echo "| Clé | Valeur | Source |" >> "$output_file"
        echo "|-----|--------|--------|" >> "$output_file"
        echo "$data" | jq -r '.findings[] | "| \(.key) | \(.value) | \(.source) |"' >> "$output_file"
    fi

    # Add comparisons
    local comparisons_count=$(echo "$data" | jq '.comparisons | length')
    if [[ "$comparisons_count" -gt 0 ]]; then
        echo -e "\n## Comparaisons\n" >> "$output_file"
        echo "| Item A | Item B | Critère | Gagnant | Notes |" >> "$output_file"
        echo "|--------|--------|---------|---------|-------|" >> "$output_file"
        echo "$data" | jq -r '.comparisons[] | "| \(.item_a) | \(.item_b) | \(.criteria) | \(.winner) | \(.notes) |"' >> "$output_file"
    fi

    # Add decisions
    local decisions_count=$(echo "$data" | jq '.decisions | length')
    if [[ "$decisions_count" -gt 0 ]]; then
        echo -e "\n## Décisions prises\n" >> "$output_file"
        echo "$data" | jq -r '.decisions[] | "### \(.decision)\n**Rationale:** \(.rationale)\n**Actions:** \(.actions_taken)\n"' >> "$output_file"
    fi

    # Add files context
    echo -e "\n## Fichiers concernés\n" >> "$output_file"
    echo "**Lus:** $(echo "$data" | jq -r '.files_context.read | join(", ")')" >> "$output_file"
    echo "**Modifiés:** $(echo "$data" | jq -r '.files_context.modified | join(", ")')" >> "$output_file"
    echo "**Créés:** $(echo "$data" | jq -r '.files_context.created | join(", ")')" >> "$output_file"

    # Add conclusion
    local conclusion=$(echo "$data" | jq -r '.conclusion // empty')
    if [[ -n "$conclusion" ]]; then
        echo -e "\n## Conclusion\n" >> "$output_file"
        echo "$conclusion" >> "$output_file"
    fi

    # Add next steps
    local next_steps=$(echo "$data" | jq -r '.next_steps | if length > 0 then .[] else empty end')
    if [[ -n "$next_steps" ]]; then
        echo -e "\n## Prochaines étapes\n" >> "$output_file"
        echo "$data" | jq -r '.next_steps[] | "- [ ] \(.)"' >> "$output_file"
    fi

    echo -e "\n---\n*Auto-généré par Harmony Analysis Tracker*" >> "$output_file"

    # Cleanup from /tmp if exported to research/ (permanent storage)
    if [[ "$output_file" == research/* && "$CLEANUP_ON_EXPORT" == true ]]; then
        cleanup_exported_session "$session_id"
    fi

    echo "$output_file"
}

# ============================================================================
# Session Resume
# ============================================================================

list_pending_sessions() {
    if [[ ! -d "$ANALYSIS_DIR" ]]; then
        return 0
    fi

    local found=0
    for session_dir in "$ANALYSIS_DIR"/*/; do
        if [[ -f "${session_dir}analysis.json" ]]; then
            local data=$(cat "${session_dir}analysis.json")
            local status=$(echo "$data" | jq -r '.status')

            if [[ "$status" == "in_progress" ]]; then
                local title=$(echo "$data" | jq -r '.title')
                local session_id=$(echo "$data" | jq -r '.session_id')
                local updated=$(echo "$data" | jq -r '.updated_at')
                local steps=$(echo "$data" | jq '.reasoning_chain | length')

                if [[ $found -eq 0 ]]; then
                    echo ""
                    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════════╗${NC}"
                    echo -e "${YELLOW}║${WHITE}  Sessions d'analyse en cours détectées                            ${YELLOW}║${NC}"
                    echo -e "${YELLOW}╠════════════════════════════════════════════════════════════════════╣${NC}"
                fi

                echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
                echo -e "${YELLOW}║${NC}  ${CYAN}[$session_id]${NC} $title"
                echo -e "${YELLOW}║${NC}  ${DIM}Étapes: $steps | Dernière MAJ: $updated${NC}"

                found=$((found + 1))
            fi
        fi
    done

    if [[ $found -gt 0 ]]; then
        echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
        echo -e "${YELLOW}╠════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${YELLOW}║${NC}  ${WHITE}Pour reprendre:${NC} \"Reprends l'analyse $session_id\"                    ${YELLOW}║${NC}"
        echo -e "${YELLOW}║${NC}  ${WHITE}Pour exporter:${NC} \"Exporte l'analyse dans research/\"                   ${YELLOW}║${NC}"
        echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
    fi

    return $found
}

resume_session() {
    local session_id="$1"

    local session_dir="$ANALYSIS_DIR/$session_id"

    if [[ ! -f "$session_dir/analysis.json" ]]; then
        echo "Session not found: $session_id" >&2
        return 1
    fi

    ANALYSIS_FILE="$session_dir/analysis.json"

    # Generate resume context
    local data=$(cat "$ANALYSIS_FILE")
    local title=$(echo "$data" | jq -r '.title')
    local steps=$(echo "$data" | jq '.reasoning_chain | length')
    local last_step=$(echo "$data" | jq -r '.reasoning_chain[-1].thought // "Aucune étape"')

    echo ""
    echo -e "${GREEN}Session reprise: $title${NC}"
    echo -e "${CYAN}Étapes précédentes: $steps${NC}"
    echo -e "${CYAN}Dernière réflexion: $last_step${NC}"
    echo ""

    # Return context for injection
    export_to_markdown "/tmp/harmony-resume-context.md" >/dev/null
    cat "/tmp/harmony-resume-context.md"
}

# ============================================================================
# Auto-save
# ============================================================================

auto_save() {
    if [[ -z "$ANALYSIS_FILE" || ! -f "$ANALYSIS_FILE" ]]; then
        return 0
    fi

    local now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    local tmp=$(mktemp)
    jq '.updated_at = "'"$now"'"' "$ANALYSIS_FILE" > "$tmp"
    mv "$tmp" "$ANALYSIS_FILE"

    echo -e "${DIM}[Auto-saved: $(basename $(dirname "$ANALYSIS_FILE"))]${NC}" >&2
}

# ============================================================================
# CLI
# ============================================================================

show_help() {
    cat << 'EOF'
Harmony Analysis Tracker - Continuité des analyses

Usage: analysis-tracker.sh <command> [args]

Commands:
  init <title> [type]     Démarre une nouvelle analyse (+ rotation auto)
  step <thought> [evidence] [conclusion]  Ajoute une étape de raisonnement
  finding <key> <value> [source]          Ajoute une découverte
  compare <a> <b> <criteria> [winner] [notes]  Ajoute une comparaison
  decide <decision> <rationale> [actions]      Marque une décision
  conclude <conclusion>   Finalise l'analyse
  export [file]           Exporte en Markdown vers research/ (+ cleanup /tmp)
  list                    Liste les sessions en cours
  resume <session_id>     Reprend une session
  status                  Affiche l'état de la session courante

Cleanup & Rotation:
  cleanup                 Supprime TOUTES les sessions
  cleanup <session_id>    Supprime une session spécifique
  rotate                  Force la rotation (age, count, disk)
  disk                    Affiche l'espace disque utilisé
  config                  Affiche/crée la config locale
  config set <key> <val>  Modifie une valeur de config

Types d'analyse:
  architecture_decision   Décision architecturale (ADR)
  research                Recherche/Investigation
  comparison              Comparaison d'options
  investigation           Investigation de bug/problème

Rotation automatique:
  - À chaque 'init': supprime sessions >7 jours et garde max 5
  - À chaque 'export' vers research/: supprime la session de /tmp

Examples:
  analysis-tracker.sh init "Migration jq vers Node.js" architecture_decision
  analysis-tracker.sh step "Problème identifié" "417 usages jq"
  analysis-tracker.sh compare "jq" "Node.js" "performance" "jq" "5-10x faster"
  analysis-tracker.sh decide "jq recommandé" "Portabilité > Performance"
  analysis-tracker.sh export
  analysis-tracker.sh cleanup              # Nettoie tout
  analysis-tracker.sh disk                 # Voir espace utilisé
EOF
}

# ============================================================================
# Main
# ============================================================================

main() {
    local cmd="${1:-}"
    shift || true

    case "$cmd" in
        init)
            init_analysis_session "$@"
            ;;
        step)
            add_reasoning_step "$@"
            ;;
        finding)
            add_finding "$@"
            ;;
        compare)
            add_comparison "$@"
            ;;
        decide)
            mark_decision "$@"
            ;;
        conclude)
            set_conclusion "$@"
            ;;
        file)
            add_file_context "$@"
            ;;
        export)
            export_to_markdown "$@"
            ;;
        list)
            list_pending_sessions
            ;;
        resume)
            resume_session "$@"
            ;;
        save)
            auto_save
            ;;
        cleanup)
            if [[ -n "${1:-}" ]]; then
                cleanup_session "$1"
            else
                cleanup_all_sessions
            fi
            ;;
        rotate)
            run_rotation
            ;;
        disk)
            list_sessions_with_size
            ;;
        config)
            if [[ "${1:-}" == "set" && -n "${2:-}" && -n "${3:-}" ]]; then
                # Update config value
                init_session_config
                local key="$2"
                local value="$3"
                local tmp=$(mktemp)
                jq ".$key = $value" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
                echo -e "${GREEN}Config: $key = $value${NC}"
                load_session_config
            else
                # Show config
                init_session_config
                echo -e "${CYAN}Configuration locale: $CONFIG_FILE${NC}"
                echo ""
                cat "$CONFIG_FILE" | jq '.'
                echo ""
                echo -e "${DIM}Modifier: analysis-tracker.sh config set <key> <value>${NC}"
                echo -e "${DIM}Exemple: analysis-tracker.sh config set max_sessions 10${NC}"
            fi
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown command: $cmd" >&2
            show_help
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
