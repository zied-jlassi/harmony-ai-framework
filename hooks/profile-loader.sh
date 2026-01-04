#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# HARMONY PROFILE LOADER
# ═══════════════════════════════════════════════════════════════════════════════
# Loads profile sections conditionally based on detected intent
# Version: 1.0.0
# Date: 2026-01-04
#
# Usage:
#   bash profile-loader.sh load <profile>           # Load sections based on intent
#   bash profile-loader.sh preview <profile>        # Dry-run, show what would load
#   bash profile-loader.sh sections <profile>       # List available sections
#   bash profile-loader.sh help                     # Show help
#
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"
PROFILES_DIR="${FRAMEWORK_DIR}/profiles"
LOCAL_PROFILES_DIR="${FRAMEWORK_DIR}/local/profiles"

# Project directories (relative to where command is run)
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
CLAUDE_MEMORY_DIR="${PROJECT_DIR}/.claude/memory"
WORKFLOW_STATE="${CLAUDE_MEMORY_DIR}/workflow-state.json"

# Defaults
MAX_SECTIONS=2
MAX_TOTAL_TOKENS=5000
DEFAULT_SECTION="core"

# ─────────────────────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────────

log_info() {
    echo "[PROFILE-LOADER] $1"
}

log_warn() {
    echo "[PROFILE-LOADER] WARNING: $1" >&2
}

log_error() {
    echo "[PROFILE-LOADER] ERROR: $1" >&2
}

# Estimate tokens (4 chars per token)
estimate_tokens() {
    local content="$1"
    local chars=${#content}
    echo $((chars / 4))
}

# Read JSON field using grep/sed (no jq dependency)
json_get() {
    local file="$1"
    local field="$2"
    grep -o "\"${field}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" 2>/dev/null | \
        sed 's/.*: *"\([^"]*\)".*/\1/' | head -1
}

# Check if string contains substring (case insensitive)
contains_keyword() {
    local text="$1"
    local keyword="$2"
    echo "$text" | grep -qi "$keyword"
}

# ─────────────────────────────────────────────────────────────────────────────────
# PROFILE DISCOVERY
# ─────────────────────────────────────────────────────────────────────────────────

find_profile_path() {
    local profile_id="$1"

    # Search in category directories
    for category in backend frontend languages runtimes databases styling tools; do
        local path="${PROFILES_DIR}/${category}/${profile_id}"
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

# Get file with local override priority
# Usage: get_profile_file <base_profile_path> <relative_file_path>
# Returns: local file if exists, else base file
get_profile_file() {
    local base_path="$1"
    local rel_file="$2"

    # Extract category/profile from base path (e.g., backend/nestjs)
    local profile_rel="${base_path#$PROFILES_DIR/}"
    local local_file="${LOCAL_PROFILES_DIR}/${profile_rel}/${rel_file}"
    local base_file="${base_path}/${rel_file}"

    # Local prioritaire
    if [ -f "$local_file" ]; then
        echo "$local_file"
    elif [ -f "$base_file" ]; then
        echo "$base_file"
    else
        return 1
    fi
}

# List all files from profile (merged: base + local overrides)
# Returns unique list with local files taking priority
list_profile_files() {
    local base_path="$1"
    local subdir="${2:-.}"  # Optional subdirectory (e.g., "knowledge")

    local profile_rel="${base_path#$PROFILES_DIR/}"
    local local_path="${LOCAL_PROFILES_DIR}/${profile_rel}/${subdir}"
    local base_full="${base_path}/${subdir}"

    # Collect all relative file paths
    local all_files=""

    # First, list base files
    if [ -d "$base_full" ]; then
        all_files=$(find "$base_full" -type f -name "*.md" -o -name "*.yaml" 2>/dev/null | \
            sed "s|^$base_full/||" | sort)
    fi

    # Then, list local files (will override in final selection)
    if [ -d "$local_path" ]; then
        local local_files=$(find "$local_path" -type f -name "*.md" -o -name "*.yaml" 2>/dev/null | \
            sed "s|^$local_path/||" | sort)
        all_files=$(echo -e "${all_files}\n${local_files}" | sort -u)
    fi

    echo "$all_files"
}

# Check if profile has local overrides
has_local_overrides() {
    local base_path="$1"
    local profile_rel="${base_path#$PROFILES_DIR/}"
    local local_path="${LOCAL_PROFILES_DIR}/${profile_rel}"

    [ -d "$local_path" ] && [ "$(ls -A "$local_path" 2>/dev/null)" ]
}

# ─────────────────────────────────────────────────────────────────────────────────
# INTENT & STATE READING
# ─────────────────────────────────────────────────────────────────────────────────

get_current_intent() {
    if [ -f "$WORKFLOW_STATE" ]; then
        json_get "$WORKFLOW_STATE" "current_intent"
    else
        echo ""
    fi
}

get_user_message() {
    # Try to get from environment or state
    if [ -n "$USER_MESSAGE" ]; then
        echo "$USER_MESSAGE"
    elif [ -f "$WORKFLOW_STATE" ]; then
        json_get "$WORKFLOW_STATE" "last_message"
    else
        echo ""
    fi
}

# ─────────────────────────────────────────────────────────────────────────────────
# SECTION SELECTION (Hardcoded Logic - Phase 2)
# ─────────────────────────────────────────────────────────────────────────────────

# Intent to sections mapping
get_sections_for_intent() {
    local intent="$1"
    local message="$2"

    # Always include core
    local sections="core"

    # Intent-based sections
    case "$intent" in
        TEST|TDD|COVERAGE|SPEC)
            sections="$sections testing"
            ;;
        SECURITY|AUTH|AUDIT|PENTEST)
            sections="$sections security"
            ;;
        IMPLEMENT|FIX|DEV)
            # Check keywords for advanced patterns
            if contains_keyword "$message" "guard" || \
               contains_keyword "$message" "interceptor" || \
               contains_keyword "$message" "pipe" || \
               contains_keyword "$message" "filter" || \
               contains_keyword "$message" "middleware"; then
                sections="$sections advanced"
            fi
            ;;
        DESIGN|ARCHITECTURE)
            sections="$sections advanced"
            ;;
    esac

    # Keyword-based additions (regardless of intent)
    if contains_keyword "$message" "test" || contains_keyword "$message" "jest"; then
        if ! echo "$sections" | grep -q "testing"; then
            sections="$sections testing"
        fi
    fi

    if contains_keyword "$message" "auth" || contains_keyword "$message" "jwt" || \
       contains_keyword "$message" "passport" || contains_keyword "$message" "role"; then
        if ! echo "$sections" | grep -q "security"; then
            sections="$sections security"
        fi
    fi

    echo "$sections"
}

# ─────────────────────────────────────────────────────────────────────────────────
# FILE LOADING
# ─────────────────────────────────────────────────────────────────────────────────

load_section_files() {
    local profile_path="$1"
    local section="$2"
    local section_dir="${profile_path}/knowledge/${section}"

    if [ ! -d "$section_dir" ]; then
        log_warn "Section directory not found: $section_dir"
        return 1
    fi

    local content=""
    local file_count=0

    for file in "$section_dir"/*.md; do
        if [ -f "$file" ]; then
            content="${content}$(cat "$file")\n\n"
            file_count=$((file_count + 1))
        fi
    done

    if [ $file_count -eq 0 ]; then
        log_warn "No .md files found in section: $section"
        return 1
    fi

    echo -e "$content"
}

# ─────────────────────────────────────────────────────────────────────────────────
# STATE UPDATE
# ─────────────────────────────────────────────────────────────────────────────────

update_state_sections() {
    local sections="$1"
    local tokens="$2"

    if [ ! -f "$WORKFLOW_STATE" ]; then
        log_warn "Workflow state not found, skipping update"
        return 1
    fi

    # Create sections array string
    local sections_json=""
    for section in $sections; do
        if [ -n "$sections_json" ]; then
            sections_json="${sections_json}, "
        fi
        sections_json="${sections_json}\"${section}\""
    done

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Read current state
    local current_state=$(cat "$WORKFLOW_STATE")

    # Check if profile_loader section exists
    if echo "$current_state" | grep -q "profile_loader"; then
        # Update existing
        log_info "Updating existing profile_loader state"
    else
        # Add new section (simplified - just log for now)
        log_info "Would add profile_loader to state: sections=[$sections_json], tokens=$tokens"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────────
# COMMANDS
# ─────────────────────────────────────────────────────────────────────────────────

cmd_load() {
    local profile_id="$1"
    local force_sections="$2"

    if [ -z "$profile_id" ]; then
        log_error "Profile ID required"
        return 1
    fi

    # Find profile
    local profile_path=$(find_profile_path "$profile_id")
    if [ -z "$profile_path" ]; then
        log_error "Profile not found: $profile_id"
        return 1
    fi

    log_info "Loading profile: $profile_id from $profile_path"

    # Get intent
    local intent=$(get_current_intent)
    local message=$(get_user_message)

    log_info "Current intent: ${intent:-NONE}"

    # Determine sections
    local sections
    if [ -n "$force_sections" ]; then
        sections=$(echo "$force_sections" | tr ',' ' ')
        log_info "Using forced sections: $sections"
    else
        sections=$(get_sections_for_intent "$intent" "$message")
        log_info "Selected sections: $sections"
    fi

    # Load content
    local total_content=""
    local total_tokens=0
    local loaded_sections=""

    for section in $sections; do
        local content=$(load_section_files "$profile_path" "$section")
        if [ -n "$content" ]; then
            local tokens=$(estimate_tokens "$content")
            total_tokens=$((total_tokens + tokens))

            if [ $total_tokens -le $MAX_TOTAL_TOKENS ]; then
                total_content="${total_content}${content}"
                loaded_sections="${loaded_sections} ${section}"
                log_info "Loaded section: $section (~$tokens tokens)"
            else
                log_warn "Token budget exceeded, skipping: $section"
                break
            fi
        fi
    done

    # Update state
    update_state_sections "$loaded_sections" "$total_tokens"

    # Output content
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo " PROFILE: $profile_id"
    echo " SECTIONS:$loaded_sections"
    echo " TOKENS: ~$total_tokens"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "$total_content"
}

cmd_preview() {
    local profile_id="$1"

    if [ -z "$profile_id" ]; then
        log_error "Profile ID required"
        return 1
    fi

    # Find profile
    local profile_path=$(find_profile_path "$profile_id")
    if [ -z "$profile_path" ]; then
        log_error "Profile not found: $profile_id"
        return 1
    fi

    # Get intent
    local intent=$(get_current_intent)
    local message=$(get_user_message)

    # Determine sections
    local sections=$(get_sections_for_intent "$intent" "$message")

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               PROFILE LOADER - PREVIEW                        ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    echo "║  Profile:  $profile_id"
    echo "║  Path:     $profile_path"
    echo "║                                                               ║"
    echo "║  Current Intent: ${intent:-NONE}"
    echo "║  User Message:   ${message:-NONE}"
    echo "║                                                               ║"
    echo "║  Sections to load:                                            ║"

    local total_estimate=0
    for section in $sections; do
        local section_dir="${profile_path}/knowledge/${section}"
        if [ -d "$section_dir" ]; then
            local file_count=$(find "$section_dir" -name "*.md" 2>/dev/null | wc -l)
            echo "║    - $section ($file_count files)"
        else
            echo "║    - $section (NOT FOUND)"
        fi
    done

    echo "║                                                               ║"
    echo "║  Max tokens: $MAX_TOTAL_TOKENS                                ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

cmd_sections() {
    local profile_id="$1"

    if [ -z "$profile_id" ]; then
        log_error "Profile ID required"
        return 1
    fi

    # Find profile
    local profile_path=$(find_profile_path "$profile_id")
    if [ -z "$profile_path" ]; then
        log_error "Profile not found: $profile_id"
        return 1
    fi

    local knowledge_dir="${profile_path}/knowledge"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               PROFILE SECTIONS: $profile_id"
    echo "╠═══════════════════════════════════════════════════════════════╣"

    if [ ! -d "$knowledge_dir" ]; then
        echo "║  No knowledge directory found                                 ║"
        echo "║  Expected: $knowledge_dir"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        return 1
    fi

    echo "║                                                               ║"
    echo "║  Available sections:                                          ║"

    for section_dir in "$knowledge_dir"/*/; do
        if [ -d "$section_dir" ]; then
            local section=$(basename "$section_dir")
            local file_count=$(find "$section_dir" -name "*.md" 2>/dev/null | wc -l)

            # Estimate total size
            local total_size=0
            for file in "$section_dir"/*.md; do
                if [ -f "$file" ]; then
                    local size=$(wc -c < "$file")
                    total_size=$((total_size + size))
                fi
            done
            local tokens=$((total_size / 4))

            echo "║    $section"
            echo "║      Files: $file_count"
            echo "║      Tokens: ~$tokens"
            echo "║"
        fi
    done

    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

cmd_help() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               HARMONY PROFILE LOADER                          ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    echo "║  Loads profile knowledge sections based on detected intent    ║"
    echo "║                                                               ║"
    echo "║  COMMANDS:                                                    ║"
    echo "║  ─────────                                                    ║"
    echo "║    load <profile>              Load sections for profile      ║"
    echo "║    load <profile> --sections   Force specific sections        ║"
    echo "║    preview <profile>           Show what would be loaded      ║"
    echo "║    sections <profile>          List available sections        ║"
    echo "║    help                        Show this help                 ║"
    echo "║                                                               ║"
    echo "║  EXAMPLES:                                                    ║"
    echo "║  ──────────                                                   ║"
    echo "║    bash profile-loader.sh load nestjs                         ║"
    echo "║    bash profile-loader.sh load nestjs --sections core,testing ║"
    echo "║    bash profile-loader.sh preview react                       ║"
    echo "║    bash profile-loader.sh sections django                     ║"
    echo "║                                                               ║"
    echo "║  ENVIRONMENT:                                                 ║"
    echo "║  ─────────────                                                ║"
    echo "║    USER_MESSAGE    Override detected message                  ║"
    echo "║    PROJECT_DIR     Override project directory                 ║"
    echo "║                                                               ║"
    echo "║  SECTION TYPES:                                               ║"
    echo "║  ───────────────                                              ║"
    echo "║    core      Always loaded                                    ║"
    echo "║    advanced  Loaded for patterns (guard, pipe, etc.)          ║"
    echo "║    testing   Loaded for TEST/TDD intents                      ║"
    echo "║    security  Loaded for SECURITY/AUTH intents                 ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────────

main() {
    local command="${1:-help}"
    local arg1="$2"
    local arg2="$3"

    # Parse --sections flag
    local force_sections=""
    if [ "$arg2" = "--sections" ] && [ -n "$4" ]; then
        force_sections="$4"
    fi

    case "$command" in
        load)
            cmd_load "$arg1" "$force_sections"
            ;;
        preview)
            cmd_preview "$arg1"
            ;;
        sections)
            cmd_sections "$arg1"
            ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            log_error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
