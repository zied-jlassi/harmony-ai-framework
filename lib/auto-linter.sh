#!/usr/bin/env bash
# ============================================================================
# auto-linter.sh - Automatic Linting and Code Quality for Harmony Framework
# ============================================================================
# Lint-on-save and auto-fix for the Harmony developer workflow.
# Provides language detection, linting, and integration with circuit breaker
#
# Usage: source auto-linter.sh
#
# Functions:
#   - detect_language        : Detect file language from extension
#   - run_lint_check         : Run appropriate linter for file
#   - lint_files             : Lint multiple files
#   - get_lint_command       : Get linter command for language
#   - check_linter_available : Check if linter is installed
#   - lint_staged_files      : Lint git staged files
# ============================================================================

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# ============================================================================
# LANGUAGE DETECTION - Map extensions to languages
# ============================================================================
declare -A EXTENSION_TO_LANGUAGE=(
    # JavaScript/TypeScript
    ["js"]="javascript"
    ["mjs"]="javascript"
    ["cjs"]="javascript"
    ["jsx"]="javascript"
    ["ts"]="typescript"
    ["tsx"]="typescript"

    # Python
    ["py"]="python"
    ["pyw"]="python"
    ["pyi"]="python"

    # Shell
    ["sh"]="bash"
    ["bash"]="bash"
    ["zsh"]="zsh"

    # Web
    ["html"]="html"
    ["htm"]="html"
    ["css"]="css"
    ["scss"]="scss"
    ["sass"]="sass"
    ["less"]="less"

    # Data
    ["json"]="json"
    ["yaml"]="yaml"
    ["yml"]="yaml"
    ["toml"]="toml"
    ["xml"]="xml"

    # Systems
    ["go"]="go"
    ["rs"]="rust"
    ["c"]="c"
    ["cpp"]="cpp"
    ["h"]="c"
    ["hpp"]="cpp"

    # Other
    ["rb"]="ruby"
    ["php"]="php"
    ["java"]="java"
    ["kt"]="kotlin"
    ["swift"]="swift"
    ["md"]="markdown"
    ["sql"]="sql"
)

# ============================================================================
# LINTER COMMANDS - Default linter for each language
# ============================================================================
declare -A LANGUAGE_LINTER=(
    ["javascript"]="eslint"
    ["typescript"]="eslint"
    ["python"]="ruff"
    ["bash"]="shellcheck"
    ["zsh"]="shellcheck"
    ["go"]="golangci-lint"
    ["rust"]="cargo clippy"
    ["ruby"]="rubocop"
    ["php"]="phpcs"
    ["css"]="stylelint"
    ["scss"]="stylelint"
    ["json"]="jsonlint"
    ["yaml"]="yamllint"
    ["markdown"]="markdownlint"
    ["sql"]="sqlfluff"
)

# ============================================================================
# LINTER FIX COMMANDS - Auto-fix command for each linter
# ============================================================================
declare -A LINTER_FIX_FLAG=(
    ["eslint"]="--fix"
    ["ruff"]="check --fix"
    ["prettier"]="--write"
    ["rubocop"]="-a"
    ["phpcs"]="--fix"  # Actually phpcbf
    ["stylelint"]="--fix"
    ["golangci-lint"]="--fix"
    ["black"]=""  # black auto-fixes by default
    ["sqlfluff"]="fix"
)

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
HARMONY_LINT_AUTO_FIX="${HARMONY_LINT_AUTO_FIX:-false}"
HARMONY_LINT_STRICT="${HARMONY_LINT_STRICT:-false}"
HARMONY_LINT_IGNORE_PATTERNS="${HARMONY_LINT_IGNORE_PATTERNS:-node_modules,vendor,.git,dist,build}"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Detect language from file extension
# Usage: detect_language "path/to/file.ts" -> "typescript"
detect_language() {
    local file="$1"
    local ext="${file##*.}"

    # Handle files without extension
    if [[ "$ext" == "$file" ]]; then
        # Try shebang detection
        if [[ -f "$file" ]]; then
            local shebang
            shebang=$(head -1 "$file" 2>/dev/null || echo "")
            case "$shebang" in
                *bash*|*sh*) echo "bash"; return 0 ;;
                *python*) echo "python"; return 0 ;;
                *node*) echo "javascript"; return 0 ;;
                *ruby*) echo "ruby"; return 0 ;;
                *php*) echo "php"; return 0 ;;
            esac
        fi
        echo "unknown"
        return 1
    fi

    # Convert to lowercase
    ext="${ext,,}"

    if [[ -n "${EXTENSION_TO_LANGUAGE[$ext]:-}" ]]; then
        echo "${EXTENSION_TO_LANGUAGE[$ext]}"
        return 0
    else
        echo "unknown"
        return 1
    fi
}

# Check if a linter is available
# Usage: check_linter_available "eslint" -> 0 if available
check_linter_available() {
    local linter="$1"

    # Handle compound commands (e.g., "cargo clippy")
    local cmd="${linter%% *}"

    if command -v "$cmd" &>/dev/null; then
        return 0
    fi

    # Check for npx-available packages
    if command -v npx &>/dev/null; then
        case "$linter" in
            eslint|prettier|stylelint|markdownlint|jsonlint)
                # These might be available via npx even if not globally installed
                if npx --no-install "$linter" --version &>/dev/null 2>&1; then
                    return 0
                fi
                ;;
        esac
    fi

    return 1
}

# Get the linter command for a language
# Usage: get_lint_command "typescript" -> "eslint" or fallback
get_lint_command() {
    local language="$1"
    local linter="${LANGUAGE_LINTER[$language]:-}"

    if [[ -z "$linter" ]]; then
        echo ""
        return 1
    fi

    # Check if primary linter is available
    if check_linter_available "$linter"; then
        echo "$linter"
        return 0
    fi

    # Try fallbacks for common languages
    case "$language" in
        python)
            # Try: ruff -> flake8 -> pylint
            for alt in flake8 pylint pyflakes; do
                if command -v "$alt" &>/dev/null; then
                    echo "$alt"
                    return 0
                fi
            done
            ;;
        javascript|typescript)
            # Try: eslint -> jshint -> standard
            for alt in jshint standard; do
                if command -v "$alt" &>/dev/null; then
                    echo "$alt"
                    return 0
                fi
            done
            ;;
        bash|zsh)
            # shellcheck is the only good option
            ;;
    esac

    echo ""
    return 1
}

# Should this file be ignored?
# Usage: should_ignore_file "node_modules/foo.js" -> 0 if should ignore
should_ignore_file() {
    local file="$1"
    local patterns
    IFS=',' read -ra patterns <<< "$HARMONY_LINT_IGNORE_PATTERNS"

    for pattern in "${patterns[@]}"; do
        if [[ "$file" == *"$pattern"* ]]; then
            return 0
        fi
    done

    return 1
}

# Run lint check on a single file
# Usage: run_lint_check "path/to/file.ts" [--fix]
# Returns: 0 = pass, 1 = fail, 2 = skipped
run_lint_check() {
    local file="$1"
    local auto_fix="${2:-}"

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo "File not found: $file" >&2
        return 2
    fi

    # Check if should ignore
    if should_ignore_file "$file"; then
        return 2
    fi

    # Detect language
    local language
    language=$(detect_language "$file") || {
        echo "Unknown language for: $file" >&2
        return 2
    }

    # Get linter command
    local linter
    linter=$(get_lint_command "$language") || {
        echo "No linter available for $language" >&2
        return 2
    }

    # Build command
    local cmd="$linter"
    local use_npx=false

    # Use npx if linter not globally installed
    if ! command -v "${linter%% *}" &>/dev/null && command -v npx &>/dev/null; then
        cmd="npx --no-install $linter"
        use_npx=true
    fi

    # Add fix flag if requested
    if [[ "$auto_fix" == "--fix" || "$HARMONY_LINT_AUTO_FIX" == "true" ]]; then
        local fix_flag="${LINTER_FIX_FLAG[$linter]:-}"
        if [[ -n "$fix_flag" ]]; then
            cmd="$cmd $fix_flag"
        fi
    fi

    # Special handling for different linters
    case "$linter" in
        shellcheck)
            cmd="$cmd -x"  # Follow sourced files
            ;;
        eslint)
            cmd="$cmd --max-warnings 0"
            [[ "$HARMONY_LINT_STRICT" == "true" ]] && cmd="$cmd --max-warnings 0"
            ;;
        ruff)
            [[ "$auto_fix" != "--fix" && "$HARMONY_LINT_AUTO_FIX" != "true" ]] && cmd="$cmd check"
            ;;
        golangci-lint)
            cmd="$cmd run"
            ;;
    esac

    # Run linter
    local output
    local exit_code

    if output=$($cmd "$file" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi

    # Output results
    if [[ $exit_code -eq 0 ]]; then
        echo "✓ $file"
        return 0
    else
        echo "✗ $file"
        echo "$output" | sed 's/^/  /'

        # Record failure if circuit breaker is available
        if declare -f record_story_failure &>/dev/null && [[ -n "${CURRENT_STORY:-}" ]]; then
            record_story_failure "$CURRENT_STORY" "lint" "$file: $linter failed"
        fi

        return 1
    fi
}

# Lint multiple files
# Usage: lint_files [--fix] file1 file2 ...
lint_files() {
    local auto_fix=""
    local files=()
    local passed=0
    local failed=0
    local skipped=0

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix)
                auto_fix="--fix"
                shift
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files specified" >&2
        return 1
    fi

    echo "=== Linting ${#files[@]} file(s) ==="
    echo ""

    for file in "${files[@]}"; do
        local result
        run_lint_check "$file" "$auto_fix" && result=0 || result=$?

        case $result in
            0) ((++passed)) || true ;;
            1) ((++failed)) || true ;;
            2) ((++skipped)) || true ;;
        esac
    done

    echo ""
    echo "=== Results: $passed passed, $failed failed, $skipped skipped ==="

    [[ $failed -eq 0 ]] && return 0 || return 1
}

# Lint git staged files
# Usage: lint_staged_files [--fix]
lint_staged_files() {
    local auto_fix="${1:-}"

    if ! command -v git &>/dev/null; then
        echo "Git not available" >&2
        return 1
    fi

    # Get staged files
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null) || {
        echo "Not in a git repository" >&2
        return 1
    }

    if [[ -z "$staged_files" ]]; then
        echo "No staged files to lint"
        return 0
    fi

    echo "=== Linting staged files ==="

    local files_array=()
    while IFS= read -r file; do
        files_array+=("$file")
    done <<< "$staged_files"

    lint_files "$auto_fix" "${files_array[@]}"
}

# Lint changed files (unstaged)
# Usage: lint_changed_files [--fix]
lint_changed_files() {
    local auto_fix="${1:-}"

    if ! command -v git &>/dev/null; then
        echo "Git not available" >&2
        return 1
    fi

    # Get changed files
    local changed_files
    changed_files=$(git diff --name-only --diff-filter=ACMR 2>/dev/null) || {
        echo "Not in a git repository" >&2
        return 1
    }

    if [[ -z "$changed_files" ]]; then
        echo "No changed files to lint"
        return 0
    fi

    echo "=== Linting changed files ==="

    local files_array=()
    while IFS= read -r file; do
        files_array+=("$file")
    done <<< "$changed_files"

    lint_files "$auto_fix" "${files_array[@]}"
}

# Get available linters
# Usage: list_available_linters
list_available_linters() {
    echo "=== Available Linters ==="
    echo ""

    for language in "${!LANGUAGE_LINTER[@]}"; do
        local linter="${LANGUAGE_LINTER[$language]}"
        local status

        if check_linter_available "$linter"; then
            status="✓ installed"
        else
            status="✗ not found"
        fi

        printf "  %-12s %-20s %s\n" "$language" "$linter" "$status"
    done | sort
}

# Quick lint report for a directory
# Usage: lint_report [directory]
lint_report() {
    local dir="${1:-.}"

    echo "=== Lint Report for $dir ==="
    echo ""

    local total=0
    local by_language=()

    # Find all source files
    while IFS= read -r file; do
        if should_ignore_file "$file"; then
            continue
        fi

        local lang
        lang=$(detect_language "$file" 2>/dev/null) || continue

        if [[ "$lang" != "unknown" ]]; then
            ((++total)) || true
            by_language+=("$lang")
        fi
    done < <(find "$dir" -type f 2>/dev/null)

    echo "Total files: $total"
    echo ""
    echo "By language:"
    printf '%s\n' "${by_language[@]}" | sort | uniq -c | sort -rn | while read -r count lang; do
        printf "  %-12s %d files\n" "$lang" "$count"
    done
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================
export -f detect_language check_linter_available get_lint_command
export -f run_lint_check lint_files lint_staged_files lint_changed_files
export -f should_ignore_file list_available_linters lint_report

# ============================================================================
# CLI MODE - Run directly for testing
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        detect)
            detect_language "${2:-test.js}"
            ;;
        check)
            shift
            run_lint_check "$@"
            ;;
        lint)
            shift
            lint_files "$@"
            ;;
        staged)
            lint_staged_files "${2:-}"
            ;;
        changed)
            lint_changed_files "${2:-}"
            ;;
        linters)
            list_available_linters
            ;;
        report)
            lint_report "${2:-.}"
            ;;
        *)
            echo "Usage: auto-linter.sh <command> [args]"
            echo ""
            echo "Commands:"
            echo "  detect <file>      - Detect language of file"
            echo "  check <file>       - Run lint check on file"
            echo "  lint [--fix] <files> - Lint multiple files"
            echo "  staged [--fix]     - Lint git staged files"
            echo "  changed [--fix]    - Lint git changed files"
            echo "  linters            - List available linters"
            echo "  report [dir]       - Lint report for directory"
            ;;
    esac
fi
