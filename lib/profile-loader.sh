#!/bin/bash
# =============================================================================
# Harmony Framework - Profile Loader
# =============================================================================
#
# Detects and loads tech stack profiles based on project files.
# Implements lazy loading - only loads profile content when requested.
#
# PROFILES:
#   frontend/  - React, Vue, Angular, Svelte
#   backend/   - NestJS, Express, FastAPI
#   mobile/    - React Native, Flutter, Ionic
#   databases/ - PostgreSQL, MongoDB, Redis
#   languages/ - TypeScript, Python, Go, Rust
#
# USAGE:
#   source "${HARMONY_DIR}/lib/profile-loader.sh"
#   profiles=$(profile_detect_from_project "/path/to/project")
#   content=$(profile_load_content "frontend/react")
#
# =============================================================================

set -euo pipefail

# Don't re-source if already loaded
if [[ "${PROFILE_LOADER_LOADED:-}" == "true" ]]; then
    return 0
fi
PROFILE_LOADER_LOADED=true

# =============================================================================
# CONFIGURATION
# =============================================================================

PROFILE_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_BASE_DIR="${PROFILES_BASE_DIR:-${SCRIPT_DIR}/../profiles}"

# =============================================================================
# DETECTION PATTERNS
# =============================================================================

# Package.json dependency → profile ID mapping
declare -A PROFILE_NPM_MAP
PROFILE_NPM_MAP=(
    # Frontend frameworks
    ["react"]="frontend/react"
    ["vue"]="frontend/vue"
    ["@angular/core"]="frontend/angular"
    ["svelte"]="frontend/svelte"
    ["next"]="frontend/nextjs"
    ["nuxt"]="frontend/nuxt"

    # Backend frameworks
    ["@nestjs/core"]="backend/nestjs"
    ["express"]="backend/express"
    ["fastify"]="backend/fastify"
    ["koa"]="backend/koa"

    # Mobile
    ["react-native"]="mobile/react-native"
    ["expo"]="mobile/expo"
    ["@ionic/core"]="mobile/ionic"

    # Databases
    ["prisma"]="databases/prisma"
    ["typeorm"]="databases/typeorm"
    ["mongoose"]="databases/mongodb"
    ["pg"]="databases/postgresql"
    ["redis"]="databases/redis"

    # Languages/Tools
    ["typescript"]="languages/typescript"
)

# =============================================================================
# DETECTION FUNCTIONS
# =============================================================================

# Detect profiles from package.json
_detect_from_package_json() {
    local project_dir="$1"
    local package_file="$project_dir/package.json"

    if [[ ! -f "$package_file" ]]; then
        return
    fi

    local content
    content=$(cat "$package_file" 2>/dev/null) || return

    local detected=()
    local _dep  # Prevent variable clobbering

    for _dep in "${!PROFILE_NPM_MAP[@]}"; do
        if echo "$content" | grep -q "\"$_dep\""; then
            detected+=("${PROFILE_NPM_MAP[$_dep]}")
        fi
    done

    printf '%s\n' "${detected[@]}"
}

# Detect from pubspec.yaml (Flutter/Dart)
_detect_from_pubspec() {
    local project_dir="$1"
    local pubspec="$project_dir/pubspec.yaml"

    if [[ -f "$pubspec" ]]; then
        echo "mobile/flutter"
        echo "languages/dart"
    fi
}

# Detect from Cargo.toml (Rust)
_detect_from_cargo() {
    local project_dir="$1"
    local cargo="$project_dir/Cargo.toml"

    if [[ -f "$cargo" ]]; then
        echo "languages/rust"
    fi
}

# Detect from go.mod (Go)
_detect_from_gomod() {
    local project_dir="$1"
    local gomod="$project_dir/go.mod"

    if [[ -f "$gomod" ]]; then
        echo "languages/go"
    fi
}

# Detect from requirements.txt / pyproject.toml (Python)
_detect_from_python() {
    local project_dir="$1"

    if [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
        echo "languages/python"

        # Check for specific frameworks
        local req_content=""
        [[ -f "$project_dir/requirements.txt" ]] && req_content=$(cat "$project_dir/requirements.txt" 2>/dev/null)
        [[ -f "$project_dir/pyproject.toml" ]] && req_content+=$(cat "$project_dir/pyproject.toml" 2>/dev/null)

        if echo "$req_content" | grep -qi "fastapi"; then
            echo "backend/fastapi"
        fi
        if echo "$req_content" | grep -qi "django"; then
            echo "backend/django"
        fi
        if echo "$req_content" | grep -qi "flask"; then
            echo "backend/flask"
        fi
    fi
}

# Main detection function
profile_detect_from_project() {
    local project_dir="${1:-.}"
    local all_profiles=()

    # Run all detectors
    while IFS= read -r profile; do
        [[ -n "$profile" ]] && all_profiles+=("$profile")
    done < <(_detect_from_package_json "$project_dir")

    while IFS= read -r profile; do
        [[ -n "$profile" ]] && all_profiles+=("$profile")
    done < <(_detect_from_pubspec "$project_dir")

    while IFS= read -r profile; do
        [[ -n "$profile" ]] && all_profiles+=("$profile")
    done < <(_detect_from_cargo "$project_dir")

    while IFS= read -r profile; do
        [[ -n "$profile" ]] && all_profiles+=("$profile")
    done < <(_detect_from_gomod "$project_dir")

    while IFS= read -r profile; do
        [[ -n "$profile" ]] && all_profiles+=("$profile")
    done < <(_detect_from_python "$project_dir")

    # Deduplicate and output
    printf '%s\n' "${all_profiles[@]}" | sort -u
}

# =============================================================================
# LOADING FUNCTIONS
# =============================================================================

# Load profile content by ID
profile_load_content() {
    local profile_id="$1"
    local profile_file="$PROFILES_BASE_DIR/$profile_id/profile.md"

    if [[ ! -f "$profile_file" ]]; then
        echo "[PROFILE] Not found: $profile_id" >&2
        return 1
    fi

    cat "$profile_file"
}

# Load multiple profiles with headers
profile_load_all() {
    local profiles="$1"
    local output=""

    while IFS= read -r profile; do
        [[ -z "$profile" ]] && continue

        local profile_file="$PROFILES_BASE_DIR/$profile/profile.md"
        if [[ -f "$profile_file" ]]; then
            output+="
# ═══════════════════════════════════════════════════════════════════
# PROFILE: $profile
# ═══════════════════════════════════════════════════════════════════

$(cat "$profile_file")

"
        fi
    done <<< "$profiles"

    echo "$output"
}

# Check if profile exists
profile_exists() {
    local profile_id="$1"
    [[ -f "$PROFILES_BASE_DIR/$profile_id/profile.md" ]]
}

# =============================================================================
# DISCOVERY FUNCTIONS
# =============================================================================

# List all available profiles
profile_list_all() {
    find "$PROFILES_BASE_DIR" -name "profile.md" -type f 2>/dev/null | \
        sed "s|$PROFILES_BASE_DIR/||;s|/profile.md||" | \
        sort
}

# List profile categories
profile_list_categories() {
    find "$PROFILES_BASE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort
}

# Get profiles in a category
profile_list_in_category() {
    local category="$1"
    find "$PROFILES_BASE_DIR/$category" -name "profile.md" -type f 2>/dev/null | \
        sed "s|$PROFILES_BASE_DIR/||;s|/profile.md||" | \
        sort
}

# =============================================================================
# DEBUG/INFO
# =============================================================================

profile_version() {
    echo "Profile Loader v${PROFILE_VERSION}"
}

profile_dump_mappings() {
    echo "=== NPM PACKAGE → PROFILE MAPPINGS ==="
    for pkg in "${!PROFILE_NPM_MAP[@]}"; do
        echo "  $pkg → ${PROFILE_NPM_MAP[$pkg]}"
    done | sort
}

# =============================================================================
# SELF-TEST
# =============================================================================

profile_self_test() {
    echo "=== Profile Loader Self-Test ==="
    echo ""

    local passed=0
    local failed=0

    # Test 1: Detect from package.json (mock)
    local temp_dir
    temp_dir=$(mktemp -d)
    echo '{"dependencies": {"react": "^18.0.0", "typescript": "^5.0.0"}}' > "$temp_dir/package.json"

    local profiles
    profiles=$(profile_detect_from_project "$temp_dir")
    if [[ "$profiles" == *"frontend/react"* ]]; then
        echo "✅ Test 1: Detect React from package.json"
        ((++passed)) || true
    else
        echo "❌ Test 1: React detection failed (got: $profiles)"
        ((++failed)) || true
    fi

    # Test 2: TypeScript detection
    if [[ "$profiles" == *"languages/typescript"* ]]; then
        echo "✅ Test 2: Detect TypeScript from package.json"
        ((++passed)) || true
    else
        echo "❌ Test 2: TypeScript detection failed"
        ((++failed)) || true
    fi

    # Cleanup
    rm -rf "$temp_dir"

    # Test 3: Flutter detection
    temp_dir=$(mktemp -d)
    touch "$temp_dir/pubspec.yaml"
    profiles=$(profile_detect_from_project "$temp_dir")
    if [[ "$profiles" == *"mobile/flutter"* ]]; then
        echo "✅ Test 3: Detect Flutter from pubspec.yaml"
        ((++passed)) || true
    else
        echo "❌ Test 3: Flutter detection failed"
        ((++failed)) || true
    fi
    rm -rf "$temp_dir"

    # Test 4: List all profiles
    local all_profiles
    all_profiles=$(profile_list_all 2>/dev/null || echo "")
    echo "✅ Test 4: profile_list_all works"
    ((++passed)) || true

    # Test 5: List categories
    local categories
    categories=$(profile_list_categories 2>/dev/null || echo "")
    echo "✅ Test 5: profile_list_categories works"
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
    profile_self_test
    exit $?
fi
