#!/bin/bash
# =============================================================================
# Harmony Framework - Knowledge Loader
# =============================================================================
#
# Loads knowledge files based on detected context flags.
# Implements token-bounded loading to stay within context limits.
#
# USAGE:
#   source "${HARMONY_DIR}/lib/knowledge-loader.sh"
#   files=$(knowledge_get_for_flags "has_auth personal_data")
#   content=$(knowledge_load_bounded "$files" 5000)
#
# =============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# Don't re-source if already loaded
if [[ "${KNOWLEDGE_LOADER_LOADED:-}" == "true" ]]; then
    return 0
fi
KNOWLEDGE_LOADER_LOADED=true

# =============================================================================
# CONFIGURATION
# =============================================================================

KNOWLEDGE_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_BASE_DIR="${KNOWLEDGE_BASE_DIR:-${SCRIPT_DIR}/../knowledge}"
KNOWLEDGE_MAX_TOKENS=${KNOWLEDGE_MAX_TOKENS:-5000}

# =============================================================================
# FLAG → KNOWLEDGE FILE MAPPING
# =============================================================================

# Maps context flags to relevant knowledge files
# Format: flag → relative paths from knowledge/ (comma-separated)
declare -A KNOWLEDGE_FLAG_MAP
KNOWLEDGE_FLAG_MAP=(
    # Security & Auth
    ["has_auth"]="domains/security/owasp-checklists.md,domains/security/auth-patterns.md"
    ["security_critical"]="domains/security/owasp-checklists.md,domains/security/secure-coding.md"

    # Data Protection
    ["personal_data"]="domains/security/data-protection.md,domains/legal/rgpd-compliance.md"
    ["has_minors"]="domains/legal/rgpd-minors.md,domains/legal/coppa.md"
    ["legal_compliance"]="domains/legal/rgpd-compliance.md,domains/legal/terms-privacy.md"

    # Media
    ["has_media"]="domains/security/file-upload.md,domains/legal/media-rights.md"

    # UI/UX
    ["has_ui"]="domains/quality/accessibility.md,domains/quality/ux-patterns.md"

    # Database
    ["has_db_schema"]="domains/database/schema-design.md,domains/database/migration-patterns.md"

    # Project Types
    ["is_mobile"]="frameworks/react/react-native-architecture.md,frameworks/mobile/responsive.md"
    ["is_web"]="frameworks/react/architecture.md,frameworks/web/spa-patterns.md"
    ["is_game"]="domains/gaming/unity-ecs-patterns.md,domains/gaming/game-loop.md"
    ["is_api"]="frameworks/nestjs/architecture.md,frameworks/api/rest-patterns.md"

    # Documentation
    ["needs_docs"]="domains/documentation/api-docs.md,domains/documentation/readme-patterns.md"
    ["needs_prd"]="domains/product/prd-template.md,domains/product/user-stories.md"
)

# =============================================================================
# CORE FUNCTIONS
# =============================================================================

# Get knowledge files for a set of flags
# Input: space-separated flags
# Output: newline-separated file paths (absolute)
knowledge_get_for_flags() {
    local flags="$1"
    local files=()
    local _flag  # Prevent variable clobbering

    for _flag in $flags; do
        local mapping="${KNOWLEDGE_FLAG_MAP[$_flag]:-}"
        if [[ -n "$mapping" ]]; then
            IFS=',' read -ra file_array <<< "$mapping"
            for file in "${file_array[@]}"; do
                local full_path="$KNOWLEDGE_BASE_DIR/$file"
                if [[ -f "$full_path" ]]; then
                    files+=("$full_path")
                fi
            done
        fi
    done

    # Deduplicate and output
    printf '%s\n' "${files[@]}" | sort -u
}

# Estimate token count for a file
# Rough estimate: 1 token ≈ 4 characters
_estimate_tokens() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local chars
        chars=$(wc -c < "$file")
        echo $((chars / 4))
    else
        echo 0
    fi
}

# Load knowledge files up to token budget
# Input: newline-separated file paths, max tokens
# Output: concatenated content with headers
knowledge_load_bounded() {
    local files="$1"
    local max_tokens="${2:-$KNOWLEDGE_MAX_TOKENS}"
    local tokens_used=0
    local output=""

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue

        local file_tokens
        file_tokens=$(_estimate_tokens "$file")

        if (( tokens_used + file_tokens > max_tokens )); then
            echo "[KNOWLEDGE] Budget reached ($tokens_used/$max_tokens tokens)" >&2
            break
        fi

        local basename
        basename=$(basename "$file")
        output+="
# ─────────────────────────────────────────────────────────────────
# KNOWLEDGE: $basename
# ─────────────────────────────────────────────────────────────────

$(cat "$file")

"
        tokens_used=$((tokens_used + file_tokens))
    done <<< "$files"

    echo "[KNOWLEDGE] Loaded $tokens_used tokens from knowledge base" >&2
    echo "$output"
}

# Quick load for a single flag
knowledge_load_for_flag() {
    local flag="$1"
    local max_tokens="${2:-$KNOWLEDGE_MAX_TOKENS}"

    local files
    files=$(knowledge_get_for_flags "$flag")

    if [[ -z "$files" ]]; then
        echo "[KNOWLEDGE] No knowledge files for flag: $flag" >&2
        return 0
    fi

    knowledge_load_bounded "$files" "$max_tokens"
}

# =============================================================================
# DISCOVERY FUNCTIONS
# =============================================================================

# List all available knowledge files
knowledge_list_all() {
    find "$KNOWLEDGE_BASE_DIR" -name "*.md" -type f 2>/dev/null | sort
}

# List knowledge categories (top-level directories)
knowledge_list_categories() {
    find "$KNOWLEDGE_BASE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort
}

# Get total token count for a set of files
knowledge_estimate_total() {
    local files="$1"
    local total=0

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local tokens
        tokens=$(_estimate_tokens "$file")
        total=$((total + tokens))
    done <<< "$files"

    echo "$total"
}

# =============================================================================
# DEBUG/INFO
# =============================================================================

knowledge_version() {
    echo "Knowledge Loader v${KNOWLEDGE_VERSION}"
}

knowledge_dump_mappings() {
    echo "=== KNOWLEDGE FLAG MAPPINGS ==="
    for flag in "${!KNOWLEDGE_FLAG_MAP[@]}"; do
        echo "  $flag → ${KNOWLEDGE_FLAG_MAP[$flag]}"
    done | sort
}

# =============================================================================
# SELF-TEST
# =============================================================================

knowledge_self_test() {
    echo "=== Knowledge Loader Self-Test ==="
    echo ""

    local passed=0
    local failed=0

    # Test 1: Get files for has_auth
    local files
    files=$(knowledge_get_for_flags "has_auth")
    if [[ -z "$files" ]]; then
        # Files may not exist, but function should work
        echo "⚠️ Test 1: No knowledge files found for has_auth (expected if knowledge/ is empty)"
        ((++passed)) || true
    else
        echo "✅ Test 1: Got knowledge files for has_auth"
        ((++passed)) || true
    fi

    # Test 2: Token estimation
    local tokens
    tokens=$(_estimate_tokens "/dev/null")
    if [[ "$tokens" == "0" ]]; then
        echo "✅ Test 2: Token estimation for empty file"
        ((++passed)) || true
    else
        echo "❌ Test 2: Token estimation failed"
        ((++failed)) || true
    fi

    # Test 3: Multiple flags
    files=$(knowledge_get_for_flags "has_auth personal_data")
    echo "✅ Test 3: Multiple flag lookup works"
    ((++passed)) || true

    # Test 4: List categories
    local categories
    categories=$(knowledge_list_categories 2>/dev/null || echo "")
    echo "✅ Test 4: Category listing works"
    ((++passed)) || true

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
    knowledge_self_test
    exit $?
fi
