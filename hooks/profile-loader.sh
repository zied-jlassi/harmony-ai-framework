#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# HARMONY PROFILE LOADER
# ═══════════════════════════════════════════════════════════════════════════════
# Loads profile sections conditionally based on detected intent
# Supports 2-level override system: local (team) > framework
#
# Version: 2.0.0
# Date: 2026-01-05
#
# Usage:
#   bash profile-loader.sh load <profile>           # Load sections based on intent
#   bash profile-loader.sh preview <profile>        # Dry-run, show what would load
#   bash profile-loader.sh sections <profile>       # List available sections
#   bash profile-loader.sh overrides [profile]      # Show override status
#   bash profile-loader.sh resolve <profile> <file> # Show file resolution
#   bash profile-loader.sh help                     # Show help
#
# Override System (ADR-PROFILE-OVERRIDES):
#   1. .harmony/local/profiles/...  → Team overrides (committed)
#   2. .harmony/profiles/...        → Framework defaults (read-only)
#
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"

# Project directories (relative to where command is run)
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Harmony directory in project (installed framework)
HARMONY_DIR="${PROJECT_DIR}/.harmony"

# Profile directories - 2 level override system
FRAMEWORK_PROFILES="${HARMONY_DIR}/profiles"
LOCAL_OVERRIDES="${HARMONY_DIR}/local/profiles"

# Legacy support (will warn if used)
LEGACY_LOCAL="${FRAMEWORK_DIR}/local/profiles"

# For development/testing: use framework directly if .harmony doesn't exist
if [[ ! -d "$HARMONY_DIR" ]]; then
    HARMONY_DIR="$FRAMEWORK_DIR"
    FRAMEWORK_PROFILES="${FRAMEWORK_DIR}/profiles"
    LOCAL_OVERRIDES="${FRAMEWORK_DIR}/local/profiles"
fi

# Backward compatibility aliases
PROFILES_DIR="$FRAMEWORK_PROFILES"
LOCAL_PROFILES_DIR="$LOCAL_OVERRIDES"

# Memory directories (ADR-010: user data in .harmony/local/memory/)
HARMONY_MEMORY_DIR="${PROJECT_DIR}/.harmony/local/memory"
WORKFLOW_STATE="${HARMONY_MEMORY_DIR}/workflow-state.json"

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

# Find profile path by ID (searches in category directories)
# Usage: find_profile_path <profile_id>
# Returns: full path to profile directory
find_profile_path() {
    local profile_id="$1"

    # Search in category directories
    for category in backend frontend languages runtimes databases styling tools mobile; do
        local path="${FRAMEWORK_PROFILES}/${category}/${profile_id}"
        if [[ -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

# Get profile relative path (category/profile_id)
# Usage: get_profile_rel <profile_id>
# Returns: e.g., "backend/nestjs"
get_profile_rel() {
    local profile_id="$1"
    local full_path=$(find_profile_path "$profile_id")

    if [[ -n "$full_path" ]]; then
        echo "${full_path#$FRAMEWORK_PROFILES/}"
    else
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────────
# OVERRIDE SYSTEM (2 levels: local > framework)
# ─────────────────────────────────────────────────────────────────────────────────

# Check if file is disabled via .disabled marker
# Usage: is_file_disabled <profile_rel> <rel_file>
is_file_disabled() {
    local profile_rel="$1"
    local rel_file="$2"

    local disabled_marker="${LOCAL_OVERRIDES}/${profile_rel}/${rel_file}.disabled"
    [[ -f "$disabled_marker" ]]
}

# Resolve a file with override priority
# Usage: resolve_profile_file <profile_rel> <rel_file>
# Returns: path to file (local if exists, else framework)
resolve_profile_file() {
    local profile_rel="$1"  # e.g., "backend/nestjs"
    local rel_file="$2"     # e.g., "knowledge/core/architecture.md"

    local local_file="${LOCAL_OVERRIDES}/${profile_rel}/${rel_file}"
    local framework_file="${FRAMEWORK_PROFILES}/${profile_rel}/${rel_file}"

    # Check disabled marker
    if is_file_disabled "$profile_rel" "$rel_file"; then
        return 1  # File disabled
    fi

    # Priority resolution: local > framework
    if [[ -f "$local_file" ]]; then
        echo "$local_file"
    elif [[ -f "$framework_file" ]]; then
        echo "$framework_file"
    else
        return 1  # Not found
    fi
}

# List all files in a section (merged: framework + local overrides)
# Usage: list_section_files <profile_rel> <section>
# Returns: list of resolved file paths
list_section_files() {
    local profile_rel="$1"
    local section="$2"
    local section_path="knowledge/${section}"

    declare -A files  # Associative array: filename -> source_path

    # 1. Framework files (lower priority)
    local fw_dir="${FRAMEWORK_PROFILES}/${profile_rel}/${section_path}"
    if [[ -d "$fw_dir" ]]; then
        for f in "$fw_dir"/*.md; do
            [[ -f "$f" ]] && files[$(basename "$f")]="$f"
        done
    fi

    # 2. Local overrides (higher priority - overwrites framework)
    local local_dir="${LOCAL_OVERRIDES}/${profile_rel}/${section_path}"
    if [[ -d "$local_dir" ]]; then
        for f in "$local_dir"/*.md; do
            [[ -f "$f" ]] && files[$(basename "$f")]="$f"
        done
    fi

    # Remove disabled files
    for name in "${!files[@]}"; do
        if is_file_disabled "$profile_rel" "${section_path}/${name}"; then
            unset "files[$name]"
        fi
    done

    # Output file paths
    for path in "${files[@]}"; do
        echo "$path"
    done
}

# Check if profile has local overrides
# Usage: has_local_overrides <profile_rel>
has_local_overrides() {
    local profile_rel="$1"
    local local_path="${LOCAL_OVERRIDES}/${profile_rel}"

    [[ -d "$local_path" ]] && [[ -n "$(ls -A "$local_path" 2>/dev/null)" ]]
}

# Get override status as JSON
# Usage: get_override_status <profile_rel>
get_override_status() {
    local profile_rel="$1"

    local has_overrides=false
    local override_count=0
    local disabled_count=0

    if has_local_overrides "$profile_rel"; then
        has_overrides=true
        override_count=$(find "${LOCAL_OVERRIDES}/${profile_rel}" -name "*.md" 2>/dev/null | wc -l)
        disabled_count=$(find "${LOCAL_OVERRIDES}/${profile_rel}" -name "*.disabled" 2>/dev/null | wc -l)
    fi

    cat <<EOF
{
  "profile": "${profile_rel}",
  "has_overrides": ${has_overrides},
  "override_files": ${override_count},
  "disabled_files": ${disabled_count},
  "local_path": "${LOCAL_OVERRIDES}/${profile_rel}",
  "framework_path": "${FRAMEWORK_PROFILES}/${profile_rel}"
}
EOF
}

# ─────────────────────────────────────────────────────────────────────────────────
# AUTO-SCAN LOCAL KNOWLEDGE
# ─────────────────────────────────────────────────────────────────────────────────

# Auto-scan all knowledge files from local overrides (Option B)
# Returns all .md files from .harmony/local/profiles/<profile>/knowledge/
# Usage: get_local_knowledge <profile_rel>
# Example: get_local_knowledge "backend/nestjs"
get_local_knowledge() {
    local profile_rel="$1"
    local knowledge_dir="${LOCAL_OVERRIDES}/${profile_rel}/knowledge"

    if [[ ! -d "$knowledge_dir" ]]; then
        return 0
    fi

    # Find all .md files recursively, excluding .disabled
    find "$knowledge_dir" -type f -name "*.md" 2>/dev/null | while read -r file; do
        # Check if disabled
        if [[ ! -f "${file}.disabled" ]]; then
            echo "$file"
        fi
    done
}

# Get all knowledge for a profile (framework + local auto-scan)
# Usage: get_all_profile_knowledge <profile_rel>
# Example: get_all_profile_knowledge "backend/nestjs"
get_all_profile_knowledge() {
    local profile_rel="$1"
    local manifest="${FRAMEWORK_PROFILES}/${profile_rel}/manifest.yaml"

    # 1. Parse manifest for declared knowledge (core, shared, on_intent)
    if [[ -f "$manifest" ]]; then
        # Extract base_path
        local base_path=$(grep "base_path:" "$manifest" 2>/dev/null | awk '{print $2}' | tr -d '"')
        base_path="${base_path:-knowledge/}"

        # Extract core files
        local in_core=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*core: ]]; then
                in_core=true
                continue
            fi
            if [[ "$in_core" == true ]]; then
                if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
                    local file="${BASH_REMATCH[1]}"
                    local full_path="${HARMONY_DIR}/${base_path}${file}"
                    if [[ -f "$full_path" ]]; then
                        echo "$full_path"
                    fi
                elif [[ "$line" =~ ^[[:space:]]*[a-z_]+: ]]; then
                    in_core=false
                fi
            fi
        done < "$manifest"
    fi

    # 2. Auto-scan local overrides (always loaded)
    get_local_knowledge "$profile_rel"
}

# Load knowledge content for a profile
# Usage: load_profile_knowledge <profile_rel> [intent]
# Returns: Concatenated content of all knowledge files
load_profile_knowledge() {
    local profile_rel="$1"
    local intent="${2:-}"

    echo "# Knowledge for profile: ${profile_rel}"
    echo ""

    # Get all knowledge files
    get_all_profile_knowledge "$profile_rel" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "<!-- Source: $file -->"
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────────
# LEGACY COMPATIBILITY
# ─────────────────────────────────────────────────────────────────────────────────

# Legacy function - wraps new resolve_profile_file
# Usage: get_profile_file <base_profile_path> <relative_file_path>
get_profile_file() {
    local base_path="$1"
    local rel_file="$2"

    # Extract profile_rel from base path
    local profile_rel="${base_path#$FRAMEWORK_PROFILES/}"

    resolve_profile_file "$profile_rel" "$rel_file"
}

# Legacy function - wraps new list functions
# Usage: list_profile_files <base_path> [subdir]
list_profile_files() {
    local base_path="$1"
    local subdir="${2:-.}"

    local profile_rel="${base_path#$FRAMEWORK_PROFILES/}"
    local section_path="${subdir}"

    # Collect all relative file paths
    local all_files=""

    # Framework files
    local fw_dir="${FRAMEWORK_PROFILES}/${profile_rel}/${section_path}"
    if [[ -d "$fw_dir" ]]; then
        all_files=$(find "$fw_dir" -type f \( -name "*.md" -o -name "*.yaml" \) 2>/dev/null | \
            sed "s|^$fw_dir/||" | sort)
    fi

    # Local override files (merge)
    local local_dir="${LOCAL_OVERRIDES}/${profile_rel}/${section_path}"
    if [[ -d "$local_dir" ]]; then
        local local_files=$(find "$local_dir" -type f \( -name "*.md" -o -name "*.yaml" \) 2>/dev/null | \
            sed "s|^$local_dir/||" | sort)
        all_files=$(echo -e "${all_files}\n${local_files}" | sort -u)
    fi

    # Filter out disabled
    while IFS= read -r file; do
        if [[ -n "$file" ]] && ! is_file_disabled "$profile_rel" "${section_path}/${file}"; then
            echo "$file"
        fi
    done <<< "$all_files"
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

# ─────────────────────────────────────────────────────────────────────────────────
# OVERRIDE COMMANDS
# ─────────────────────────────────────────────────────────────────────────────────

cmd_overrides() {
    local profile_id="$1"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               PROFILE OVERRIDES STATUS                        ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    echo "║  Override Path: .harmony/local/profiles/                      ║"
    echo "║                                                               ║"

    if [[ -n "$profile_id" ]]; then
        # Show specific profile
        local profile_rel=$(get_profile_rel "$profile_id")
        if [[ -z "$profile_rel" ]]; then
            echo "║  ERROR: Profile not found: $profile_id"
            echo "╚═══════════════════════════════════════════════════════════════╝"
            return 1
        fi

        echo "║  Profile: $profile_id ($profile_rel)"
        echo "║"

        if has_local_overrides "$profile_rel"; then
            echo "║  ✅ Has local overrides"
            echo "║"
            echo "║  Override files:"

            local local_dir="${LOCAL_OVERRIDES}/${profile_rel}"
            find "$local_dir" -type f \( -name "*.md" -o -name "*.disabled" \) 2>/dev/null | while read -r file; do
                local rel="${file#$local_dir/}"
                if [[ "$file" == *.disabled ]]; then
                    echo "║    🚫 $rel"
                else
                    echo "║    📄 $rel"
                fi
            done
        else
            echo "║  ❌ No local overrides"
            echo "║"
            echo "║  To create overrides:"
            echo "║    mkdir -p .harmony/local/profiles/${profile_rel}/knowledge/core/"
            echo "║    # Add your .md files there"
        fi
    else
        # Show all profiles with overrides
        echo "║  Profiles with overrides:"
        echo "║"

        local found=false
        if [[ -d "$LOCAL_OVERRIDES" ]]; then
            for category_dir in "$LOCAL_OVERRIDES"/*/; do
                [[ -d "$category_dir" ]] || continue
                local category=$(basename "$category_dir")

                for profile_dir in "$category_dir"*/; do
                    [[ -d "$profile_dir" ]] || continue
                    local profile=$(basename "$profile_dir")
                    local count=$(find "$profile_dir" -name "*.md" 2>/dev/null | wc -l)
                    local disabled=$(find "$profile_dir" -name "*.disabled" 2>/dev/null | wc -l)

                    if [[ $count -gt 0 ]] || [[ $disabled -gt 0 ]]; then
                        found=true
                        echo "║    📁 ${category}/${profile}: $count files, $disabled disabled"
                    fi
                done
            done
        fi

        if [[ "$found" == "false" ]]; then
            echo "║    (none)"
            echo "║"
            echo "║  To create overrides:"
            echo "║    mkdir -p .harmony/local/profiles/backend/nestjs/knowledge/core/"
        fi
    fi

    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

cmd_resolve() {
    local profile_id="$1"
    local rel_file="$2"

    if [[ -z "$profile_id" ]] || [[ -z "$rel_file" ]]; then
        log_error "Usage: resolve <profile> <relative_file_path>"
        log_error "Example: resolve nestjs knowledge/core/architecture.md"
        return 1
    fi

    local profile_rel=$(get_profile_rel "$profile_id")
    if [[ -z "$profile_rel" ]]; then
        log_error "Profile not found: $profile_id"
        return 1
    fi

    local local_file="${LOCAL_OVERRIDES}/${profile_rel}/${rel_file}"
    local framework_file="${FRAMEWORK_PROFILES}/${profile_rel}/${rel_file}"
    local disabled_marker="${local_file}.disabled"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               FILE RESOLUTION                                 ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    echo "║  Profile: $profile_id ($profile_rel)"
    echo "║  File:    $rel_file"
    echo "║                                                               ║"
    echo "║  Resolution:"

    # Check disabled
    if [[ -f "$disabled_marker" ]]; then
        echo "║    🚫 DISABLED (${disabled_marker})"
        echo "║"
        echo "║  Result: File will NOT be loaded"
    # Check local
    elif [[ -f "$local_file" ]]; then
        echo "║    ├── Local:     ✅ ${local_file}"
        echo "║    └── Framework: ⏭️  (skipped)"
        echo "║"
        echo "║  Result: ${local_file}"
    # Check framework
    elif [[ -f "$framework_file" ]]; then
        echo "║    ├── Local:     ❌ (not found)"
        echo "║    └── Framework: ✅ ${framework_file}"
        echo "║"
        echo "║  Result: ${framework_file}"
    else
        echo "║    ├── Local:     ❌ (not found)"
        echo "║    └── Framework: ❌ (not found)"
        echo "║"
        echo "║  Result: FILE NOT FOUND"
    fi

    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

cmd_help() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               HARMONY PROFILE LOADER v2.0                     ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    echo "║  Loads profile knowledge with 2-level override system         ║"
    echo "║                                                               ║"
    echo "║  OVERRIDE PRIORITY:                                           ║"
    echo "║  ─────────────────                                            ║"
    echo "║    1. .harmony/local/profiles/...  (team - committed)         ║"
    echo "║    2. .harmony/profiles/...        (framework - read-only)    ║"
    echo "║                                                               ║"
    echo "║  COMMANDS:                                                    ║"
    echo "║  ─────────                                                    ║"
    echo "║    load <profile>              Load sections for profile      ║"
    echo "║    load <profile> --sections   Force specific sections        ║"
    echo "║    preview <profile>           Show what would be loaded      ║"
    echo "║    sections <profile>          List available sections        ║"
    echo "║    overrides [profile]         Show override status           ║"
    echo "║    resolve <profile> <file>    Show file resolution           ║"
    echo "║    help                        Show this help                 ║"
    echo "║                                                               ║"
    echo "║  EXAMPLES:                                                    ║"
    echo "║  ──────────                                                   ║"
    echo "║    profile-loader.sh load nestjs                              ║"
    echo "║    profile-loader.sh overrides                                ║"
    echo "║    profile-loader.sh overrides nestjs                         ║"
    echo "║    profile-loader.sh resolve nestjs knowledge/core/arch.md    ║"
    echo "║                                                               ║"
    echo "║  OVERRIDE TYPES:                                              ║"
    echo "║  ───────────────                                              ║"
    echo "║    Same filename  → Replaces framework file                   ║"
    echo "║    New filename   → Added to section                          ║"
    echo "║    .disabled      → Prevents loading (e.g., file.md.disabled) ║"
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
    local arg3="$4"

    # Parse --sections flag
    local force_sections=""
    if [[ "$arg2" == "--sections" ]] && [[ -n "$arg3" ]]; then
        force_sections="$arg3"
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
        overrides)
            cmd_overrides "$arg1"
            ;;
        resolve)
            cmd_resolve "$arg1" "$arg2"
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
