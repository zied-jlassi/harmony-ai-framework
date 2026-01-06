#!/usr/bin/env bash
# ============================================================================
# repomap.sh - Repository Map Generator for Harmony Framework
# ============================================================================
# Inspired by Aider's repomap feature for codebase context
# Generates structured maps of repository for AI context
#
# Usage: source repomap.sh
#
# Functions:
#   - generate_repomap       : Generate complete repository map
#   - get_file_tree          : Get directory tree structure
#   - find_key_files         : Identify important files
#   - get_file_summary       : Get summary of a file
#   - analyze_dependencies   : Analyze project dependencies
#   - get_symbols            : Extract symbols from file
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
REPOMAP_MAX_DEPTH="${REPOMAP_MAX_DEPTH:-4}"
REPOMAP_MAX_FILES="${REPOMAP_MAX_FILES:-100}"
REPOMAP_CACHE_DIR="${REPOMAP_CACHE_DIR:-/tmp/harmony-repomap}"

# Key file patterns (regex)
declare -a KEY_FILE_PATTERNS=(
    "README"
    "CHANGELOG"
    "CONTRIBUTING"
    "package\.json"
    "Cargo\.toml"
    "go\.mod"
    "requirements\.txt"
    "pyproject\.toml"
    "Makefile"
    "Dockerfile"
    "docker-compose"
    "\.env\.example"
    "tsconfig\.json"
    "\.eslintrc"
    "jest\.config"
    "vite\.config"
    "webpack\.config"
)

# Important directories
declare -a IMPORTANT_DIRS=(
    "src"
    "lib"
    "app"
    "api"
    "core"
    "components"
    "services"
    "utils"
    "helpers"
    "models"
    "controllers"
    "views"
    "routes"
    "middleware"
    "tests"
    "test"
    "__tests__"
    "spec"
)

# Ignore patterns
declare -a IGNORE_PATTERNS=(
    "node_modules"
    "vendor"
    ".git"
    "dist"
    "build"
    "coverage"
    ".cache"
    "__pycache__"
    ".pytest_cache"
    ".next"
    ".nuxt"
    "target"
    ".idea"
    ".vscode"
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if path should be ignored
should_ignore() {
    local path="$1"
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$path" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

# Get relative path
get_relative_path() {
    local file="$1"
    local base="${2:-.}"
    realpath --relative-to="$base" "$file" 2>/dev/null || echo "$file"
}

# ============================================================================
# FILE TREE GENERATION
# ============================================================================

# Generate file tree structure
# Usage: get_file_tree [directory] [max_depth]
get_file_tree() {
    local dir="${1:-.}"
    local max_depth="${2:-$REPOMAP_MAX_DEPTH}"

    if command -v tree &>/dev/null; then
        tree -L "$max_depth" --noreport -I "$(IFS='|'; echo "${IGNORE_PATTERNS[*]}")" "$dir" 2>/dev/null
    else
        # Fallback to find + awk
        find "$dir" -maxdepth "$max_depth" -type f -o -type d 2>/dev/null | while read -r path; do
            if should_ignore "$path"; then
                continue
            fi

            local rel
            rel=$(get_relative_path "$path" "$dir")
            local depth
            depth=$(echo "$rel" | tr -cd '/' | wc -c)

            if [[ -d "$path" ]]; then
                printf "%*s%s/\n" $((depth * 2)) "" "$(basename "$path")"
            else
                printf "%*s%s\n" $((depth * 2)) "" "$(basename "$path")"
            fi
        done
    fi
}

# ============================================================================
# KEY FILE DETECTION
# ============================================================================

# Find key/important files in repository
# Usage: find_key_files [directory]
find_key_files() {
    local dir="${1:-.}"
    local found_files=()

    # Build regex pattern
    local pattern_regex
    pattern_regex=$(IFS='|'; echo "${KEY_FILE_PATTERNS[*]}")

    while IFS= read -r file; do
        if should_ignore "$file"; then
            continue
        fi
        found_files+=("$file")
    done < <(find "$dir" -maxdepth 3 -type f 2>/dev/null | grep -iE "$pattern_regex" | head -n 20)

    # Print found files
    for file in "${found_files[@]}"; do
        echo "$(get_relative_path "$file" "$dir")"
    done
}

# Find entry point files
# Usage: find_entry_points [directory]
find_entry_points() {
    local dir="${1:-.}"
    local entries=()

    # Common entry point patterns
    local -a entry_patterns=(
        "index.js" "index.ts" "index.tsx"
        "main.js" "main.ts" "main.py" "main.go" "main.rs"
        "app.js" "app.ts" "app.py"
        "server.js" "server.ts"
        "src/index" "src/main" "src/app"
        "lib/index" "lib/main"
        "bin/*"
    )

    for pattern in "${entry_patterns[@]}"; do
        while IFS= read -r file; do
            if [[ -f "$file" ]] && ! should_ignore "$file"; then
                entries+=("$(get_relative_path "$file" "$dir")")
            fi
        done < <(find "$dir" -path "*$pattern*" -type f 2>/dev/null | head -n 5)
    done

    # Unique entries
    printf '%s\n' "${entries[@]}" | sort -u
}

# ============================================================================
# FILE ANALYSIS
# ============================================================================

# Get summary of a file (first N lines, comments, exports)
# Usage: get_file_summary "path/to/file.ts" [lines]
get_file_summary() {
    local file="$1"
    local lines="${2:-10}"

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file" >&2
        return 1
    fi

    local ext="${file##*.}"

    echo "=== $(basename "$file") ==="
    echo ""

    # Line count and size
    local line_count size
    line_count=$(wc -l < "$file" 2>/dev/null || echo "0")
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    echo "Lines: $line_count | Size: $size bytes"
    echo ""

    # Extract key info based on language
    case "$ext" in
        ts|tsx|js|jsx)
            echo "Exports:"
            grep -E "^export|^module\.exports" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            echo ""
            echo "Imports:"
            grep -E "^import|^const.*require" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            ;;
        py)
            echo "Imports:"
            grep -E "^import|^from.*import" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            echo ""
            echo "Classes/Functions:"
            grep -E "^class|^def|^async def" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            ;;
        go)
            echo "Package:"
            grep "^package" "$file" 2>/dev/null | head -n 1 | sed 's/^/  /'
            echo ""
            echo "Functions:"
            grep -E "^func" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            ;;
        rs)
            echo "Modules:"
            grep -E "^mod|^use|^pub" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            ;;
        sh|bash)
            echo "Functions:"
            grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$file" 2>/dev/null | head -n 10 | sed 's/^/  /'
            ;;
        *)
            echo "First $lines lines:"
            head -n "$lines" "$file" | sed 's/^/  /'
            ;;
    esac
}

# Extract symbols (functions, classes, exports) from file
# Usage: get_symbols "path/to/file.ts"
get_symbols() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "[]"
        return 1
    fi

    local ext="${file##*.}"
    local symbols=()

    case "$ext" in
        ts|tsx|js|jsx)
            # Functions and classes
            while IFS= read -r line; do
                symbols+=("$line")
            done < <(grep -oE "(function|class|const|let|var)\s+[a-zA-Z_][a-zA-Z0-9_]*" "$file" 2>/dev/null | awk '{print $2}' | sort -u)
            ;;
        py)
            # Functions and classes
            while IFS= read -r line; do
                symbols+=("$line")
            done < <(grep -oE "(class|def)\s+[a-zA-Z_][a-zA-Z0-9_]*" "$file" 2>/dev/null | awk '{print $2}' | sort -u)
            ;;
        go)
            while IFS= read -r line; do
                symbols+=("$line")
            done < <(grep -oE "func\s+(\([^)]*\)\s+)?[a-zA-Z_][a-zA-Z0-9_]*" "$file" 2>/dev/null | awk '{print $NF}' | sort -u)
            ;;
        sh|bash)
            while IFS= read -r line; do
                symbols+=("$line")
            done < <(grep -oE "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$file" 2>/dev/null | tr -d '()' | sort -u)
            ;;
    esac

    # Output as JSON array
    if [[ ${#symbols[@]} -eq 0 ]]; then
        echo "[]"
    else
        printf '['
        for i in "${!symbols[@]}"; do
            if [[ $i -gt 0 ]]; then printf ','; fi
            printf '"%s"' "${symbols[$i]}"
        done
        printf ']'
    fi
}

# ============================================================================
# DEPENDENCY ANALYSIS
# ============================================================================

# Analyze project dependencies
# Usage: analyze_dependencies [directory]
analyze_dependencies() {
    local dir="${1:-.}"

    echo "=== Dependency Analysis ==="
    echo ""

    # Node.js
    if [[ -f "$dir/package.json" ]]; then
        echo "Node.js (package.json):"
        echo "  Dependencies:"
        jq -r '.dependencies // {} | keys[]' "$dir/package.json" 2>/dev/null | head -n 15 | sed 's/^/    /'
        echo "  DevDependencies:"
        jq -r '.devDependencies // {} | keys[]' "$dir/package.json" 2>/dev/null | head -n 10 | sed 's/^/    /'
        echo ""
    fi

    # Python
    if [[ -f "$dir/requirements.txt" ]]; then
        echo "Python (requirements.txt):"
        grep -v "^#" "$dir/requirements.txt" 2>/dev/null | head -n 15 | sed 's/^/  /'
        echo ""
    fi

    if [[ -f "$dir/pyproject.toml" ]]; then
        echo "Python (pyproject.toml):"
        grep -E "^\[project\]|^dependencies|^name\s*=" "$dir/pyproject.toml" 2>/dev/null | head -n 10 | sed 's/^/  /'
        echo ""
    fi

    # Go
    if [[ -f "$dir/go.mod" ]]; then
        echo "Go (go.mod):"
        grep -E "^module|require" "$dir/go.mod" 2>/dev/null | head -n 15 | sed 's/^/  /'
        echo ""
    fi

    # Rust
    if [[ -f "$dir/Cargo.toml" ]]; then
        echo "Rust (Cargo.toml):"
        grep -E "^\[dependencies\]|^name\s*=|^\[package\]" "$dir/Cargo.toml" 2>/dev/null | head -n 10 | sed 's/^/  /'
        echo ""
    fi
}

# ============================================================================
# REPOMAP GENERATION
# ============================================================================

# Generate complete repository map
# Usage: generate_repomap [directory] [output_format]
generate_repomap() {
    local dir="${1:-.}"
    local format="${2:-text}"

    case "$format" in
        json)
            generate_repomap_json "$dir"
            ;;
        markdown|md)
            generate_repomap_markdown "$dir"
            ;;
        *)
            generate_repomap_text "$dir"
            ;;
    esac
}

# Text format repomap
generate_repomap_text() {
    local dir="${1:-.}"
    local project_name
    project_name=$(basename "$(realpath "$dir")")

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                     REPOSITORY MAP                             ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Project: $project_name"
    echo "║ Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    echo "=== Project Structure ==="
    get_file_tree "$dir" 3
    echo ""

    echo "=== Key Files ==="
    find_key_files "$dir"
    echo ""

    echo "=== Entry Points ==="
    find_entry_points "$dir"
    echo ""

    analyze_dependencies "$dir"

    echo "=== Important Directories ==="
    for d in "${IMPORTANT_DIRS[@]}"; do
        if [[ -d "$dir/$d" ]]; then
            local count
            count=$(find "$dir/$d" -type f 2>/dev/null | wc -l)
            printf "  %-15s %d files\n" "$d/" "$count"
        fi
    done
}

# JSON format repomap
generate_repomap_json() {
    local dir="${1:-.}"
    local project_name
    project_name=$(basename "$(realpath "$dir")")

    # Get key files
    local key_files_json
    key_files_json=$(find_key_files "$dir" | jq -R -s 'split("\n") | map(select(length > 0))')

    # Get entry points
    local entry_points_json
    entry_points_json=$(find_entry_points "$dir" | jq -R -s 'split("\n") | map(select(length > 0))')

    # Get directories
    local dirs_json="["
    local first=true
    for d in "${IMPORTANT_DIRS[@]}"; do
        if [[ -d "$dir/$d" ]]; then
            local count
            count=$(find "$dir/$d" -type f 2>/dev/null | wc -l)
            if [[ "$first" != true ]]; then dirs_json+=","; fi
            dirs_json+="{\"name\":\"$d\",\"files\":$count}"
            first=false
        fi
    done
    dirs_json+="]"

    cat <<EOF
{
  "project": "$project_name",
  "generated_at": "$(date -Iseconds)",
  "key_files": $key_files_json,
  "entry_points": $entry_points_json,
  "directories": $dirs_json
}
EOF
}

# Markdown format repomap
generate_repomap_markdown() {
    local dir="${1:-.}"
    local project_name
    project_name=$(basename "$(realpath "$dir")")

    cat <<EOF
# Repository Map: $project_name

Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Project Structure

\`\`\`
$(get_file_tree "$dir" 3)
\`\`\`

## Key Files

$(find_key_files "$dir" | sed 's/^/- /')

## Entry Points

$(find_entry_points "$dir" | sed 's/^/- /')

## Dependencies

$(analyze_dependencies "$dir" | sed 's/^/> /')

EOF
}

# ============================================================================
# CACHING
# ============================================================================

# Cache repomap for faster access
cache_repomap() {
    local dir="${1:-.}"
    local cache_file="$REPOMAP_CACHE_DIR/$(echo "$dir" | md5sum | cut -d' ' -f1).json"

    mkdir -p "$REPOMAP_CACHE_DIR"
    generate_repomap_json "$dir" > "$cache_file"
    echo "$cache_file"
}

# Get cached repomap if valid
get_cached_repomap() {
    local dir="${1:-.}"
    local max_age="${2:-3600}"  # 1 hour default
    local cache_file="$REPOMAP_CACHE_DIR/$(echo "$dir" | md5sum | cut -d' ' -f1).json"

    if [[ -f "$cache_file" ]]; then
        local cache_age
        cache_age=$(( $(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0) ))

        if [[ $cache_age -lt $max_age ]]; then
            cat "$cache_file"
            return 0
        fi
    fi

    return 1
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f generate_repomap get_file_tree find_key_files find_entry_points
export -f get_file_summary get_symbols analyze_dependencies
export -f cache_repomap get_cached_repomap should_ignore

# ============================================================================
# CLI MODE - Run directly for testing
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        tree)
            get_file_tree "${2:-.}" "${3:-4}"
            ;;
        keys)
            find_key_files "${2:-.}"
            ;;
        entries)
            find_entry_points "${2:-.}"
            ;;
        summary)
            get_file_summary "${2:-README.md}" "${3:-10}"
            ;;
        symbols)
            get_symbols "${2:-}"
            ;;
        deps)
            analyze_dependencies "${2:-.}"
            ;;
        map)
            generate_repomap "${2:-.}" "${3:-text}"
            ;;
        json)
            generate_repomap "${2:-.}" "json"
            ;;
        md)
            generate_repomap "${2:-.}" "markdown"
            ;;
        cache)
            cache_repomap "${2:-.}"
            ;;
        *)
            generate_repomap "${1:-.}" "text"
            ;;
    esac
fi
