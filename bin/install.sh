#!/bin/bash

# ============================================================
# Harmony Framework - Installation Script
# ============================================================
# This script installs the Harmony Framework into a project.
#
# PREREQUISITES (MANDATORY):
#   - Node.js 18+    : Runtime for npx
#   - jq             : JSON processing (apt install jq / brew install jq)
#   - yq             : YAML processing (apt install yq / brew install yq)
#   - MCP Servers    : Official Anthropic MCP servers (via npx)
#     - @modelcontextprotocol/server-memory          : Cross-session memory
#     - @modelcontextprotocol/server-sequentialthinking : Structured reasoning
#
#   Why jq and yq?
#   - Performance: Native JSON/YAML parsing is 10-100x faster than shell
#   - Reliability: Robust config handling without regex hacks
#   - Features: Deep merge, path queries, format conversion
#
#   Why MCP servers?
#   - server-memory: Cross-session learning, Sentinel error patterns
#   - server-sequentialthinking: Complex problem decomposition
#
#   Installation will FAIL if jq, yq, or MCP servers are not available.
#
# Usage:
#   ./install.sh [options]
#
# Options:
#   --project-dir PATH    Target project directory (default: current)
#   --full                Install full framework WITH hooks (recommended)
#   --minimal             Install minimal configuration (no hooks)
#   --hooks               Enable hooks (included in --full)
#   --no-hooks            Disable hooks (use with --full to skip hooks)
#   --ide TYPE            Target IDE: auto, claude-code, cursor, windsurf, continue, cody
#   --force               Overwrite existing files
#   --help                Show this help message
# ============================================================

set -e

# =============================================================================
# CROSS-PLATFORM COMPATIBILITY
# =============================================================================

# SHA256 checksum command (sha256sum on Linux, shasum -a 256 on macOS)
sha256_cmd() {
    if command -v sha256sum &>/dev/null; then
        sha256sum "$@"
    elif command -v shasum &>/dev/null; then
        shasum -a 256 "$@"
    else
        echo "WARNING: No SHA256 tool found" >&2
        return 1
    fi
}

# Verify checksums (cross-platform)
verify_checksums() {
    local checksum_file="$1"
    if command -v sha256sum &>/dev/null; then
        sha256sum -c "$checksum_file" --quiet 2>/dev/null
    elif command -v shasum &>/dev/null; then
        shasum -a 256 -c "$checksum_file" --quiet 2>/dev/null
    else
        echo "WARNING: Cannot verify checksums - no SHA256 tool" >&2
        return 0  # Don't fail if no tool available
    fi
}

# Fallback colors (always define before any output)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Default values
PROJECT_DIR="."
INSTALL_MODE="full"
CONFIGURE_HOOKS=false
FORCE=false
IDE_TARGET="auto"  # auto, claude-code, cursor, windsurf, continue, cody, generic
UI_LIBRARY_LOADED=false

# Resolve symlinks to get the real script location
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")/.." && pwd)"

# Validate SCRIPT_DIR points to the framework root
if [[ ! -f "$SCRIPT_DIR/harmony.manifest.json" ]]; then
    # Try alternative resolution methods
    if [[ -f "$(dirname "$0")/../harmony.manifest.json" ]]; then
        SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    elif [[ -f "${BASH_SOURCE[0]%/*}/../harmony.manifest.json" ]]; then
        SCRIPT_DIR="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
    else
        echo -e "${RED}ERROR: Cannot locate framework source directory${NC}" >&2
        echo -e "${RED}SCRIPT_DIR resolved to: $SCRIPT_DIR${NC}" >&2
        echo -e "${RED}Expected harmony.manifest.json not found${NC}" >&2
        exit 1
    fi
fi

# Source UI Library for professional interface (AFTER SCRIPT_DIR is resolved)
if [[ -f "$SCRIPT_DIR/lib/ui-library.sh" ]]; then
    source "$SCRIPT_DIR/lib/ui-library.sh"
    UI_LIBRARY_LOADED=true
fi

# Get version from package.json
VERSION=$(grep '"version"' "$SCRIPT_DIR/package.json" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/' || echo "unknown")

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header (using UI library if available)
print_header() {
    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        ui_init
        ui_welcome "$VERSION" "Self-Improving AI Development"
    else
        echo ""
        print_message "$PURPLE" "╔══════════════════════════════════════════════════════════╗"
        print_message "$PURPLE" "║                  HARMONY FRAMEWORK                        ║"
        print_message "$PURPLE" "║            Self-Improving AI Development                  ║"
        printf "${PURPLE}║                    Version: %-29s ║${NC}\n" "$VERSION"
        print_message "$PURPLE" "╚══════════════════════════════════════════════════════════╝"
        echo ""
    fi
}

# Ask for installation confirmation
ask_install_confirmation() {
    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        if ! ui_confirm "Voulez-vous installer Harmony Framework ?" "yes"; then
            echo ""
            print_message "$YELLOW" "Installation annulée."
            exit 0
        fi
    else
        # Fallback simple prompt
        echo ""
        read -rp "Installer Harmony Framework ? [Y/n] " choice
        case "${choice,,}" in
            n|no|non) echo "Installation annulée."; exit 0 ;;
        esac
    fi
}

# Print step (hidden when UI library is loaded - we use show_install_progress instead)
print_step() {
    local step=$1
    local message=$2
    # Only show old-style steps when UI library is not loaded
    if [[ "$UI_LIBRARY_LOADED" != true ]]; then
        print_message "$CYAN" "[$step] $message"
    fi
}

# Print success (hidden when UI library loaded - UI boxes handle it)
print_success() {
    # Skip if UI library handles the display
    [[ "$UI_LIBRARY_LOADED" == true ]] && return
    print_message "$GREEN" "✓ $1"
}

# Print warning
print_warning() {
    print_message "$YELLOW" "⚠ $1"
}

# Print error
print_error() {
    print_message "$RED" "✗ $1"
}

# Detect if running via npx
is_npx() {
    [[ "$0" == *"node_modules"* ]] || [[ "$0" == *"npx"* ]] || [[ -n "$npm_execpath" ]]
}

# Show help
show_help() {
    cat << EOF
Harmony Framework - Installation Script v$VERSION

INSTALLATION METHODS:

  Method 1: NPM (Recommended)
  ─────────────────────────────
  npm install harmony-ai-framework
  npx harmony-init [options]

  Method 2: Direct Script
  ─────────────────────────────
  # If already in a project with Harmony installed:
  ./node_modules/harmony-ai-framework/bin/install.sh [options]

  # Or clone the repo:
  git clone https://github.com/harmony-ai-framework/framework
  ./harmony-framework/bin/install.sh --project-dir /your/project

OPTIONS:

  --project-dir PATH    Target project directory (default: current)
  --full                Install full framework WITH hooks (recommended)
  --minimal             Install minimal configuration (no hooks)
  --hooks               Enable hooks (included in --full)
  --no-hooks            Disable hooks (use with --full to skip hooks)
  --ide TYPE            Target IDE: auto, claude-code, cursor, windsurf, continue, cody
  --force               Overwrite existing files
  --help                Show this help message

EXAMPLES:

  # Full installation with hooks (recommended)
  npx harmony-init --full

  # Full installation for Cursor IDE
  npx harmony-init --full --ide cursor

  # Full installation WITHOUT hooks
  npx harmony-init --full --no-hooks

  # Minimal installation (core files only, no hooks)
  npx harmony-init --minimal

  # Force reinstall
  npx harmony-init --full --force

AFTER INSTALLATION:

  .harmony/             Core framework (read-only)
  .claude/memory/       Project data (Claude Code)
  .harmony/agents/      Agent definitions
  .harmony/workflows/   Workflow definitions

DOCUMENTATION:

  https://github.com/harmony-ai-framework/framework

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --project-dir)
                PROJECT_DIR="$2"
                shift 2
                ;;
            --hooks)
                CONFIGURE_HOOKS=true
                shift
                ;;
            --no-hooks)
                CONFIGURE_HOOKS=false
                shift
                ;;
            --minimal)
                INSTALL_MODE="minimal"
                shift
                ;;
            --full)
                INSTALL_MODE="full"
                CONFIGURE_HOOKS=true  # --full includes hooks
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --ide)
                IDE_TARGET="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Global variable for detected IDE (used in print_summary)
_DETECTED_IDE="generic"

# Detect IDE (for hooks/settings configuration)
# ADR-010: Memory is always in .harmony/memory/ (IDE-independent)
detect_ide() {
    local detected_ide="generic"

    # Auto-detection based on existing files
    if [[ "$IDE_TARGET" == "auto" ]]; then
        if [[ -d "$PROJECT_DIR/.claude" ]] || command -v claude &> /dev/null; then
            detected_ide="claude-code"
        elif [[ -d "$PROJECT_DIR/.cursor" ]]; then
            detected_ide="cursor"
        elif [[ -d "$PROJECT_DIR/.windsurf" ]]; then
            detected_ide="windsurf"
        elif [[ -d "$PROJECT_DIR/.continue" ]]; then
            detected_ide="continue"
        elif [[ -d "$PROJECT_DIR/.cody" ]]; then
            detected_ide="cody"
        fi
    else
        detected_ide="$IDE_TARGET"
    fi

    # Store globally for print_summary
    _DETECTED_IDE="$detected_ide"

    # IDE config directory (for hooks, settings, etc.)
    case "$detected_ide" in
        claude-code)  IDE_CONFIG_DIR="$PROJECT_DIR/.claude" ;;
        cursor)       IDE_CONFIG_DIR="$PROJECT_DIR/.cursor" ;;
        windsurf)     IDE_CONFIG_DIR="$PROJECT_DIR/.windsurf" ;;
        continue)     IDE_CONFIG_DIR="$PROJECT_DIR/.continue" ;;
        cody)         IDE_CONFIG_DIR="$PROJECT_DIR/.cody" ;;
        generic|*)    IDE_CONFIG_DIR="$PROJECT_DIR/.harmony-local" ;;
    esac

    # Debug info (hidden in UI mode - UI boxes show this)
    if [[ "$UI_LIBRARY_LOADED" != true ]]; then
        print_message "$CYAN" "  IDE detected: $detected_ide"
    fi

    # Save config for Harmony - memory is in .harmony/local/memory/
    mkdir -p "$PROJECT_DIR/.harmony/config"
    cat > "$PROJECT_DIR/.harmony/config/paths.json" << EOF
{
  "ide": "$detected_ide",
  "memory_dir": ".harmony/local/memory",
  "ide_config_dir": "$IDE_CONFIG_DIR",
  "core_dir": "$PROJECT_DIR/.harmony"
}
EOF
}

# Check prerequisites
check_prerequisites() {
    print_step "1/6" "Checking prerequisites..."

    # Check if target directory exists
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_error "Project directory does not exist: $PROJECT_DIR"
        exit 1
    fi

    # Check for existing .harmony directory
    if [[ -d "$PROJECT_DIR/.harmony" ]] && [[ "$FORCE" != true ]]; then
        print_warning "Harmony already installed in this project."
        print_message "$YELLOW" "Use --force to overwrite or remove .harmony directory first."
        exit 1
    fi

    # Load runtime info for dependency checks
    _load_runtime_info

    # Check optional performance dependencies: jq and yq
    # These are recommended for 10-100x faster JSON/YAML parsing but not required
    local missing_perf=()
    if [[ -z "$_RUNTIME_JQ" ]]; then
        missing_perf+=("jq")
    fi
    if [[ -z "$_RUNTIME_YQ" ]]; then
        missing_perf+=("yq")
    fi

    if [[ ${#missing_perf[@]} -gt 0 ]]; then
        echo ""
        print_warning "OUTILS PERFORMANCE NON INSTALLES: ${missing_perf[*]}"
        echo ""
        print_message "$YELLOW" "jq et yq sont RECOMMANDES pour des performances optimales."
        print_message "$YELLOW" "Ils permettent un parsing JSON/YAML 10-100x plus rapide."
        echo ""
        print_message "$CYAN" "Installation (optionnel):"
        for dep in "${missing_perf[@]}"; do
            local install_cmd=$(get_install_cmd "$dep")
            if [[ -n "$install_cmd" ]]; then
                print_message "$CYAN" "  $dep: $install_cmd"
            else
                case "$dep" in
                    jq) print_message "$CYAN" "  jq: https://stedolan.github.io/jq/download/" ;;
                    yq) print_message "$CYAN" "  yq: https://github.com/mikefarah/yq#install" ;;
                esac
            fi
        done
        echo ""
        print_message "$CYAN" "Installation continue sans ces outils..."
    fi

    # Note: MCP servers verification is done at ÉCRAN 0 (CLAUDE.md check)
    # If we reach here, Claude Code is already initialized

    print_success "Prerequisites check passed"
}

# Create directory structure
create_directory_structure() {
    print_step "2/6" "Creating directory structure..."

    local dirs=(
        ".harmony"
        ".harmony/agents"
        ".harmony/docs"
        ".harmony/hooks"
        ".harmony/memory"
        ".harmony/patterns"
        ".harmony/rules"
        ".harmony/templates"
        ".harmony/tips"
        ".harmony/workflows"
        ".harmony/specialties"
        ".harmony/specialties/ai"
        ".harmony/specialties/ai/knowledge"
        # TODO: en attente de la nouvelle architecture de profiles
        ".harmony/specialties/ai/agents"
        ".harmony/specialties/accessibility/knowledge"
        ".harmony/specialties/mobile/knowledge"
        ".harmony/specialties/legal/knowledge"
        ".harmony/specialties/i18n/knowledge"
        ".harmony/profiles/mobile/flutter"
        ".harmony/profiles/backend/nestjs/knowledge/templates"
        ".harmony/profiles/backend/nestjs/knowledge/cheatsheets"
        ".harmony/profiles/backend/nestjs/knowledge/integrations"
        ".harmony/profiles/backend/nestjs/knowledge/pitfalls"
        # Local directories (project-specific)
        ".harmony/local/config"
        ".harmony/local/tmp/qa"
        ".harmony/local/reports/qa"
        ".harmony/local/metrics"
        ".harmony/local/backlog/epics"
        ".harmony/local/backlog/themes"
        ".harmony/local/docs/briefs"
        ".harmony/local/docs/prd"
        ".harmony/local/docs/architecture"
        ".harmony/local/logs"
        # Sprint Autopilot configuration and state
        ".harmony/local/autopilot"
        # Override directories (team customizations - committed)
        ".harmony/local/profiles"
        ".harmony/local/specialties"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$PROJECT_DIR/$dir"
    done

    print_success "Directory structure created"
}

# Copy framework files
copy_framework_files() {
    print_step "3/6" "Copying framework files..."

    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        # Minimal installation - core files only
        local files=(
            "README.md"
            "package.json"
            "harmony.manifest.json"
            "LICENSE"
            "agents/guardian.md"
            "agents/sentinel.md"
            "memory/workflow-state.json"
            "memory/error-journal.json"
            "memory/circuit-breaker.json"
            "hooks/guardian-checkpoint.sh"
            "hooks/sentinel-pre.sh"
            "hooks/sentinel-post.sh"
        )
    else
        # Full installation - all files
        # Copy only framework directories (exclude npm artifacts)
        # ADR-010: memory/ removed - initialize_memory() handles it with merge from templates/
        local dirs_to_copy=(
            "agents"
            "commands"
            "config"
            "docs"
            "error-library"
            "hooks"
            "integrations"
            "knowledge"
            "lib"
            "local"
            "patterns"
            "profiles"
            "routing"
            "rules"
            "shared"
            "specialties"
            "templates"
            "tips"
            "tools"
            "workflows"
        )

        for dir in "${dirs_to_copy[@]}"; do
            if [[ -d "$SCRIPT_DIR/$dir" ]]; then
                # ADR-007: Protect user data in .harmony/local/ during reinstall
                # Only preserve if local/memory/ contains actual user data (JSON files)
                if [[ "$dir" == "local" ]]; then
                    local has_user_data=false
                    if [[ -d "$PROJECT_DIR/.harmony/local/memory" ]]; then
                        if [[ -n "$(find "$PROJECT_DIR/.harmony/local/memory" -name "*.json" 2>/dev/null | head -1)" ]]; then
                            has_user_data=true
                        fi
                    fi
                    if [[ "$has_user_data" == "true" ]]; then
                        print_message "$CYAN" "Preserving existing .harmony/local/ (user data detected in memory/)"
                        continue
                    fi
                fi
                # Use cp -r source/. dest/ to copy contents (not just subdirs)
                mkdir -p "$PROJECT_DIR/.harmony/$dir"
                cp -r "$SCRIPT_DIR/$dir/." "$PROJECT_DIR/.harmony/$dir/"
            else
                print_warning "Directory not found: $SCRIPT_DIR/$dir"
            fi
        done

        # Copy essential files (exclude npm artifacts like package.json, bin/, .npmrc)
        # ADR-007: INSTRUCTIONS.md and AGENTS.md are now essential for instruction resilience
        local essential_missing=0
        for file in README.md LICENSE harmony.manifest.json INSTRUCTIONS.md AGENTS.md; do
            if [[ -f "$SCRIPT_DIR/$file" ]]; then
                cp "$SCRIPT_DIR/$file" "$PROJECT_DIR/.harmony/"
            else
                print_error "Essential file not found in source: $file"
                print_error "  Expected at: $SCRIPT_DIR/$file"
                essential_missing=$((essential_missing + 1))
            fi
        done

        # Fail immediately if essential files are missing from source
        if [[ $essential_missing -gt 0 ]]; then
            print_error "Installation aborted: $essential_missing essential file(s) missing from source"
            print_error "Source directory: $SCRIPT_DIR"
            print_error "Please verify framework integrity or re-download."
            exit 1
        fi

        # Double-check harmony.manifest.json was copied successfully
        if [[ ! -f "$PROJECT_DIR/.harmony/harmony.manifest.json" ]]; then
            print_error "harmony.manifest.json copy failed unexpectedly"
            print_error "  Source: $SCRIPT_DIR/harmony.manifest.json"
            print_error "  Target: $PROJECT_DIR/.harmony/harmony.manifest.json"
            exit 1
        fi

        # Verify installation - minimum expected files
        local MIN_FILES=100
        local file_count=$(find "$PROJECT_DIR/.harmony" -type f | wc -l)

        if [[ $file_count -lt $MIN_FILES ]]; then
            print_error "Installation failed! Only $file_count files copied (expected $MIN_FILES+)"
            print_error "Source directory: $SCRIPT_DIR"
            print_error "Please report this issue."
            exit 1
        fi

        # Verify checksums of critical files
        if [[ -f "$SCRIPT_DIR/checksums.sha256" ]]; then
            cp "$SCRIPT_DIR/checksums.sha256" "$PROJECT_DIR/.harmony/"
            cd "$PROJECT_DIR/.harmony"
            if verify_checksums checksums.sha256; then
                print_success "All framework files copied ($file_count files, checksums verified)"
            else
                print_error "Checksum verification failed! Files may be corrupted."
                # Show failed files (cross-platform)
                if command -v sha256sum &>/dev/null; then
                    sha256sum -c checksums.sha256 2>&1 | grep -v ": OK" || true
                elif command -v shasum &>/dev/null; then
                    shasum -a 256 -c checksums.sha256 2>&1 | grep -v ": OK" || true
                fi
                exit 1
            fi
            cd - > /dev/null
        else
            # Fallback: just verify critical files exist
            local critical_files=(
                "agents/harmony.md"
                "agents/developer.md"
                "agents/guardian.md"
                "agents/sentinel.md"
                "harmony.manifest.json"
            )
            local missing=0

            for cf in "${critical_files[@]}"; do
                if [[ ! -f "$PROJECT_DIR/.harmony/$cf" ]]; then
                    print_error "Critical file missing: $cf"
                    missing=$((missing + 1))
                fi
            done

            if [[ $missing -gt 0 ]]; then
                print_error "Installation incomplete! $missing critical files missing."
                exit 1
            fi

            print_success "All framework files copied ($file_count files)"
        fi
        return
    fi

    # Copy individual files for minimal install
    for file in "${files[@]}"; do
        local src="$SCRIPT_DIR/$file"
        local dst="$PROJECT_DIR/.harmony/$file"

        if [[ -f "$src" ]]; then
            cp "$src" "$dst"
        fi
    done

    print_success "Framework files copied (${INSTALL_MODE} mode)"
}

# Make hooks executable
configure_hooks() {
    print_step "4/6" "Configuring hooks..."

    # Make all hook scripts executable
    chmod +x "$PROJECT_DIR/.harmony/hooks/"*.sh 2>/dev/null || true

    if [[ "$CONFIGURE_HOOKS" == true ]]; then
        # Create .claude/settings.json if it doesn't exist
        local claude_dir="$PROJECT_DIR/.claude"
        local settings_file="$claude_dir/settings.json"

        mkdir -p "$claude_dir"

        local had_existing=false
        if [[ -f "$settings_file" ]]; then
            # Backup existing settings
            cp "$settings_file" "${settings_file}.backup"
            had_existing=true
        fi

        # Create settings with hooks configuration
        # NOTE: Prompt Monitor hooks are disabled by default.
        # To enable: see .harmony/docs/prompt-monitor.md
        cat > "$settings_file" << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .harmony/hooks/aria-detect.sh \"$TOOL_INPUT\""
          }
        ]
      },
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .harmony/hooks/guardian-checkpoint.sh \"$TOOL_INPUT\""
          },
          {
            "type": "command",
            "command": "bash .harmony/hooks/sentinel-pre.sh \"$TOOL_NAME\" \"$TOOL_INPUT\""
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .harmony/hooks/supply-chain-guard.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .harmony/hooks/sentinel-post.sh \"$TOOL_NAME\" \"$TOOL_RESULT\""
          }
        ]
      },
      {
        "matcher": "Bash|WebFetch|WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "bash .harmony/hooks/llm-output-sanitizer.sh"
          }
        ]
      }
    ]
  }
}
EOF
        # Check if backup is identical to new file (same checksum = no changes)
        if [[ "$had_existing" == true ]]; then
            local old_checksum new_checksum
            old_checksum=$(sha256_cmd "${settings_file}.backup" 2>/dev/null | cut -d' ' -f1)
            new_checksum=$(sha256_cmd "$settings_file" 2>/dev/null | cut -d' ' -f1)

            if [[ "$old_checksum" == "$new_checksum" ]]; then
                # Files identical, remove unnecessary backup
                rm -f "${settings_file}.backup"
            else
                print_warning "Existing settings backed up to settings.json.backup"
            fi
        fi
        print_success "Claude Code hooks configured"
    else
        print_warning "Hooks not configured. Use --hooks to enable."
    fi
}

# Deep merge JSON using jq
_merge_with_jq() {
    local template_content="$1"
    local target_file="$2"

    echo "$template_content" | jq -s --slurpfile existing "$target_file" '
        # Deep merge: template as base, existing overwrites
        def deepmerge(a; b):
            if (a | type) == "object" and (b | type) == "object" then
                a * b
            elif (b | type) == "null" then
                a
            else
                b
            end;
        deepmerge(.[0]; $existing[0])
    ' 2>/dev/null
}

# Deep merge JSON using Node.js (fallback)
_merge_with_node() {
    local template_content="$1"
    local target_file="$2"

    node -e "
        const template = JSON.parse(process.argv[1]);
        const existing = JSON.parse(require('fs').readFileSync(process.argv[2], 'utf8'));

        function deepMerge(base, override) {
            const result = { ...base };
            for (const key of Object.keys(override)) {
                if (override[key] !== null &&
                    typeof override[key] === 'object' &&
                    !Array.isArray(override[key]) &&
                    typeof result[key] === 'object' &&
                    !Array.isArray(result[key])) {
                    result[key] = deepMerge(result[key] || {}, override[key]);
                } else if (override[key] !== null) {
                    result[key] = override[key];
                }
            }
            return result;
        }

        console.log(JSON.stringify(deepMerge(template, existing), null, 2));
    " "$template_content" "$target_file" 2>/dev/null
}

# Merge memory file: keeps user data, adds new template keys
# Usage: merge_memory_file <target_file> <template_content>
# Returns: 0=merged, 1=preserved (merge failed), 2=created
merge_memory_file() {
    local target_file="$1"
    local template_content="$2"

    if [[ -f "$target_file" ]]; then
        # File exists - merge template with existing (existing values win)
        local merged=""

        # Try jq first (faster), fallback to Node.js
        if command -v jq &>/dev/null; then
            merged=$(_merge_with_jq "$template_content" "$target_file")
        elif command -v node &>/dev/null; then
            merged=$(_merge_with_node "$template_content" "$target_file")
        fi

        # Validate and write merged content
        if [[ -n "$merged" ]]; then
            # Validate JSON before writing
            if echo "$merged" | jq empty 2>/dev/null || node -e "JSON.parse(process.argv[1])" "$merged" 2>/dev/null; then
                echo "$merged" > "$target_file"
                return 0  # merged
            fi
        fi

        # Merge failed, keep existing file unchanged
        return 1  # preserved
    else
        # File doesn't exist - create from template
        echo "$template_content" > "$target_file"
        return 2  # created
    fi
}

# Initialize memory files in .harmony/local/memory/ (centralized, user data)
initialize_memory() {
    print_step "5/6" "Initializing project memory files..."

    # ADR-010: Memory files are in .harmony/local/memory/
    # - User data belongs in local/ (mutable, project-specific)
    # - Templates are in .harmony/templates/memory/ (read-only, from framework)
    # - Merge strategy: preserve user data + add new template keys

    local memory_dir="$PROJECT_DIR/.harmony/local/memory"
    local template_dir="$PROJECT_DIR/.harmony/templates/memory"

    mkdir -p "$memory_dir"

    local merged_count=0
    local created_count=0
    local skipped_count=0

    # Helper to process each memory file with merge
    process_memory_file() {
        local filename="$1"
        local template_file="$template_dir/${filename%.json}.template.json"
        local target="$memory_dir/$filename"

        # Check if template file exists
        if [[ ! -f "$template_file" ]]; then
            print_warning "Template not found: $template_file"
            skipped_count=$((skipped_count + 1))
            return 0  # Don't fail with set -e, just skip
        fi

        # Read template content
        local template_content
        template_content=$(cat "$template_file")

        # Use || true to prevent set -e from triggering on non-zero return codes (1=preserved, 2=created)
        local result=0
        merge_memory_file "$target" "$template_content" || result=$?

        case $result in
            0) merged_count=$((merged_count + 1)) ;;   # merged
            2) created_count=$((created_count + 1)) ;; # created
            # 1 = preserved (merge failed), counted as merged
            1) merged_count=$((merged_count + 1)) ;;
        esac
    }

    # Process all memory files from templates
    # Core memory files
    process_memory_file "workflow-state.json"
    process_memory_file "error-journal.json"
    process_memory_file "circuit-breaker.json"
    process_memory_file "learned-patterns.json"
    process_memory_file "user-preferences.json"
    process_memory_file "working.json"

    # Session and tracking
    process_memory_file "session-tracker.json"
    process_memory_file "ab-results.json"
    process_memory_file "maturity-scores.json"

    # Anomaly and audit
    process_memory_file "anomaly-events.json"
    process_memory_file "audit-journal.json"
    process_memory_file "compliance-proofs.json"

    # Confidence and filtering
    process_memory_file "confidence-history.json"
    process_memory_file "filter-cache.json"

    # Sandbox
    process_memory_file "sandbox-quarantine.json"
    process_memory_file "sandbox-log.json"

    # Network and security
    process_memory_file "mesh-state.json"
    process_memory_file "security-log.json"

    # Report what happened
    if [[ $merged_count -gt 0 ]]; then
        print_message "$CYAN" "Memory files merged: $merged_count (user data preserved + new fields added)"
    fi
    if [[ $created_count -gt 0 ]]; then
        print_success "Memory files created: $created_count"
    fi
    if [[ $skipped_count -gt 0 ]]; then
        print_warning "Memory files skipped: $skipped_count (templates not found)"
    fi
    if [[ $merged_count -eq 0 ]] && [[ $created_count -eq 0 ]] && [[ $skipped_count -eq 0 ]]; then
        print_success "Memory files initialized"
    fi
}

# Initialize local configurations
initialize_autopilot_config() {
    print_step "5.7/6" "Initializing local configurations..."

    local local_dir="$PROJECT_DIR/.harmony/local"
    mkdir -p "$local_dir"

    # List of config files to copy from framework/local/
    local config_files=(
        "autopilot-config.json"
        "audit-config.json"
        "confidence-config.json"
        "sandbox-config.json"
    )

    for config_name in "${config_files[@]}"; do
        local config_file="$local_dir/$config_name"
        if [[ ! -f "$config_file" ]]; then
            # Copy template from framework/local/
            if [[ -f "$SCRIPT_DIR/local/$config_name" ]]; then
                cp "$SCRIPT_DIR/local/$config_name" "$config_file"
                print_success "Created .harmony/local/$config_name"
            fi
        fi
    done

    # Fallback for autopilot-config.json if template doesn't exist
    local autopilot_config="$local_dir/autopilot-config.json"
    if [[ ! -f "$autopilot_config" ]]; then
        cat > "$autopilot_config" << 'EOF'
{
  "_comment": "Sprint Autopilot Configuration - Local Override",
  "circuit_breaker": {
    "max_failures_per_story": 10,
    "max_failures_per_phase": 5
  },
  "api_budget": {
    "api_calls_limit": 10000,
    "warning_threshold_percent": 80
  },
  "completion_signals": {
    "developer": ["Implementation complete", "Code ready", "Tests written"],
    "tester": ["All tests passing", "Coverage: 100%", "Validation complete"],
    "ucv_validator": ["Coverage: 100%", "All verified", "Verification complete"]
  }
}
EOF
        print_success "Autopilot configuration created (default)"
    fi

    print_success "Local configurations initialized"
}

# Initialize user config with examples
initialize_user_config() {
    print_step "5.8/6" "Initializing user configuration..."

    local config_dir="$PROJECT_DIR/.harmony/local/config"
    mkdir -p "$config_dir"

    local config_file="$config_dir/overrides.yaml"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# =============================================================================
# Harmony Framework - User Configuration (Personal Overrides)
# =============================================================================
#
# This file contains YOUR personal settings that override the team config.
# It is NOT versioned (in .gitignore) - each developer has their own.
#
# Team config is at: .harmony/config/overrides.yaml (shared, versioned)
# This file mirrors that structure for personal overrides.
#
# Tip: Use `/harmony config` command for natural language configuration!
#      Example: "Bloquer DROP DATABASE sur la production"
#
# =============================================================================

# --- Project Settings ---
# project:
#   name: "my-project"
#   language: "fr"              # Response language: en, fr, es, de, it, pt

# --- Docker Settings ---
# docker:
#   required: true              # Block local npm/yarn, require Docker
#   container_prefix: "myapp"   # Prefix for container suggestions

# --- Rules Enforcer (Security) ---
# rules_enforcer:
#   add_dangerous_patterns:     # Patterns to BLOCK (regex)
#     - 'DROP DATABASE.*prod'
#     - 'rm -rf /data'
#   add_warning_patterns:       # Patterns for WARNING only
#     - 'sudo'
#   add_allowed_patterns:       # Docker exceptions
#     - 'docker exec myapp npm'
#   disable_patterns:           # Framework patterns to DISABLE
#     - 'prisma migrate reset'

# --- Guardian (Story Verification) ---
# guardian:
#   enabled: true
#   mode: "warn"                # "warn" | "block"
#   add_allowed_directories:    # Skip verification for these dirs
#     - "scripts/"
#     - "tools/"
#   add_allowed_extensions:     # Skip verification for these extensions
#     - ".sql"
#     - ".test.ts"

# --- Sentinel (Circuit Breaker) ---
# sentinel:
#   enabled: true
#   circuit_breaker:
#     enabled: true
#     max_failures: 5           # Default: 3
#     cooldown_minutes: 10      # Default: 5

# --- Agents ---
# agents:
#   disabled:                   # Agents to disable
#     - "pentest"
#   aliases:                    # Custom aliases
#     dev: "developer"
#     qa: "exploratory-qa"

# --- Hooks ---
# hooks:
#   disabled_hooks:             # Hooks to skip
#     - "guardian-checkpoint"
#   additional_pre_hooks:       # Custom hooks to run
#     - ".harmony/local/hooks/my-check.sh"
EOF
        print_success "User configuration template created at .harmony/local/config/overrides.yaml"
    else
        print_success "User configuration already exists"
    fi
}

# Create Claude Code slash commands
create_slash_commands() {
    # Always create slash commands for full install or if hooks requested
    if [[ "$INSTALL_MODE" != "full" ]] && [[ "$CONFIGURE_HOOKS" != true ]]; then
        return
    fi

    print_step "5.5/6" "Creating Claude Code slash commands..."

    local commands_dir="$PROJECT_DIR/.claude/commands"
    mkdir -p "$commands_dir"

    # Generate ALL commands using generate-commands.sh
    # Creates compact format with name + description:
    #   - Core: /go, /harmony, /sentinel
    #   - Agents: /hf:agent:* (18 agents)
    #   - Workflows: /hf:workflow:* (8 workflows)
    #   - TestArch: /hf:testarch:* (8 commands)
    #   - Diagrams: /hf:diagram:* (4 commands)
    if [[ -x "$SCRIPT_DIR/bin/generate-commands.sh" ]]; then
        "$SCRIPT_DIR/bin/generate-commands.sh" "$commands_dir" > /dev/null 2>&1
        local total_count=$(ls -1 "$commands_dir"/*.md 2>/dev/null | wc -l)
        print_success "Generated $total_count slash commands in .claude/commands/"
        # Note: Commands now include Claude Code v2.1.0 features (context: fork, allowed-tools, hooks)
        # for compliance agents (rgpd, security, pentest, etc.)
    else
        print_warning "generate-commands.sh not found. Creating minimal commands..."

        # Fallback: create minimal core commands manually
        cat > "$commands_dir/go.md" << 'EOF'
---
name: "/go"
description: "GO - Session Kickoff - Initialize session with project context"
---
Load and execute the go command from `${HARMONY_DIR}/commands/go.md`.

Arguments: $ARGUMENTS
EOF

        cat > "$commands_dir/harmony.md" << 'EOF'
---
name: "/harmony"
description: "Harmony Framework - 30 commands: validation, sentinel, profiles, ucv..."
---
If no arg: Read `${HARMONY_DIR}/commands/index.md`
If arg: Read `${HARMONY_DIR}/commands/$ARGUMENTS.md`
EOF

        cat > "$commands_dir/sentinel.md" << 'EOF'
---
name: "/sentinel"
description: "Harmony Sentinel - Auto-Learning Error Memory"
---
Read `${HARMONY_DIR}/commands/sentinel.md`
Args: $ARGUMENTS
EOF
        print_success "Created 3 core slash commands (fallback mode)"
    fi
}

# Create or update CLAUDE.md with Harmony Framework
create_claude_md() {
    local claude_md="$PROJECT_DIR/CLAUDE.md"
    # Resolve to absolute path to get proper project name (basename "." returns ".")
    local abs_project_dir=$(cd "$PROJECT_DIR" && pwd)
    local project_name=$(basename "$abs_project_dir")
    local harmony_version="$VERSION"
    local template_file="$SCRIPT_DIR/integrations/claude-code/templates/CLAUDE.md.template"

    print_step "5.6/6" "Configuring CLAUDE.md..."

    # Harmony header block - MINIMAL version (ADR-007: Instruction Resilience)
    # Full instructions are in .harmony/INSTRUCTIONS.md (protected, checksummed)
    # Note: read -r -d '' returns 1 at EOF, so we use || true to prevent set -e exit
    local harmony_header
    read -r -d '' harmony_header << 'HARMONY_HEADER' || true
## 🛡️ HARMONY FRAMEWORK (ACTIVE)

> **INSTRUCTIONS**: Read `.harmony/INSTRUCTIONS.md` for all framework protocols (P-010 Agent Announcement, Guardian, Sentinel).

> **CONFIG**: `HARMONY_DIR=.harmony` - All framework files are in `.harmony/`

> **COMMANDS**: `/go` (session start) • `/harmony` (30 commands) • `/harmony status`

> **READ-ONLY**: This section is auto-generated. Reinstall with `npx harmony-ai-framework --force` to restore.

---

HARMONY_HEADER

    # Case 1: CLAUDE.md doesn't exist → Create from template
    if [[ ! -f "$claude_md" ]]; then
        if [[ -f "$template_file" ]]; then
            sed -e "s/{{PROJECT_NAME}}/${project_name}/g" \
                -e "s/{{PROJECT_DESCRIPTION}}/A new project (Discovery phase)/g" \
                -e "s/{{HARMONY_VERSION}}/${harmony_version}/g" \
                -e '/{{#if /d' -e '/{{#each /d' -e '/{{\/if}}/d' -e '/{{\/each}}/d' \
                -e '/{{name}}/d' -e '/{{version}}/d' \
                "$template_file" > "$claude_md"
            print_success "Created CLAUDE.md from template"
        else
            echo "# ${project_name}" > "$claude_md"
            echo "" >> "$claude_md"
            echo "$harmony_header" >> "$claude_md"
            print_success "Created CLAUDE.md (minimal)"
        fi
        return
    fi

    # Case 2: CLAUDE.md exists with Harmony → Skip
    if grep -q "HARMONY FRAMEWORK" "$claude_md"; then
        print_success "CLAUDE.md already configured with Harmony"
        return
    fi

    # Case 3: CLAUDE.md exists without Harmony → Prepend at TOP (after first # header)
    print_message "$YELLOW" "Adding Harmony section to existing CLAUDE.md..."

    local tmp_file=$(mktemp)
    local header_found=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        echo "$line" >> "$tmp_file"
        # Insert Harmony header right after the first # heading
        if [[ "$header_found" == false ]] && [[ "$line" =~ ^#[[:space:]] ]]; then
            echo "" >> "$tmp_file"
            echo "$harmony_header" >> "$tmp_file"
            header_found=true
        fi
    done < "$claude_md"

    # If no header found, prepend at very top
    if [[ "$header_found" == false ]]; then
        echo "$harmony_header" | cat - "$claude_md" > "$tmp_file"
    fi

    mv "$tmp_file" "$claude_md"
    print_success "Added Harmony section to CLAUDE.md (at top)"
}

# Legacy template below (kept for backward compatibility)
_create_claude_md_legacy() {
    local claude_md="$PROJECT_DIR/CLAUDE.md"
    # Resolve to absolute path to get proper project name (basename "." returns ".")
    local abs_project_dir=$(cd "$PROJECT_DIR" && pwd)
    local project_name=$(basename "$abs_project_dir")

    cat > "$claude_md" << CLAUDE_MD_EOF
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**${project_name}** - A new project (in Discovery phase).

Uses the **Harmony AI Framework** with:
- **Guardian Protocol** - Intent detection, agent routing, workflow protection
- **Sentinel System** - Error memory, circuit breaker (3 failures = stop), pattern learning
- **HQVF** - Use Case Verifiables (UCVs), triple validation (Dev+Test+QA)

## Essential Commands

\`\`\`bash
/go                               # Session kickoff
/harmony                          # Menu interactif (30 commandes)

# 🔍 VALIDATION FRAMEWORK (1-5)
/harmony full                     # 1 - Audit complet (~2-5 min)
/harmony quick                    # 2 - Check rapide (~30s)
/harmony duplicates               # 3 - Detection duplicats
/harmony fix                      # 4 - Proposer corrections
/harmony fix --apply              #   - Appliquer avec confirmation
/harmony watch                    # 5 - Pre-commit hook
/harmony watch --install          #   - Installer hook
/harmony watch --status           #   - Status hook

# 📊 RAPPORTS (6-7)
/harmony report                   # 6 - Matrice coherence
/harmony report --json            #   - Export JSON
/harmony report --verbose         #   - Details complets
/harmony tokens                   # 7 - Token usage
/harmony tokens --breakdown       #   - Par fichier
/harmony tokens --optimize        #   - Optimisations

# 🎯 VALIDATION SPECIFIQUE (8-10)
/harmony pipeline                 # 8 - Coherence pipeline
/harmony pipeline --verbose       #   - Details complets
/harmony pipeline --fix           #   - Proposer corrections
/harmony hooks                    # 9 - Validation hooks
/harmony hooks --install          #   - Installer hooks
/harmony hooks --status           #   - Status hooks
/harmony patterns                 # 10 - Validation patterns
/harmony patterns --fix           #   - Proposer corrections

# 🔄 SYNCHRONISATION (11-12)
/harmony memory                   # 11 - Sync MCP <-> CLAUDE.md
/harmony memory --diff            #   - Afficher differences
/harmony claude                   # 12 - Validation Claude Code
/harmony claude --update          # 12u - MAJ regles conformite
/harmony claude --fix             #   - Proposer corrections

# 📏 REGLES APPLICATION (13-15)
/harmony rules                    # 13 - Audit regles
/harmony rules --usage            # 14 - Usage dans le code
/harmony rules --report           # 15 - Rapport conformite

# 🛡️ HARMONY SENTINEL (16-20)
/harmony sentinel                 # 16 - Status (defaut): Dashboard
/harmony sentinel --status        # 16 - Status: Dashboard
/harmony sentinel --learn         # 17 - Learn: Documenter erreur
/harmony sentinel --reset         # 18 - Reset: Circuit breaker
/harmony sentinel --check         # 19 - Check: Verification systeme
/harmony sentinel --report        # 20 - Report: Rapport detaille

# 📚 KNOWLEDGE & PROFILES (21-23)
/harmony learn <url>              # 21 - Apprendre depuis URL
/harmony learn --refresh          #   - Rafraichir knowledge
/harmony profiles                 # 22 - Lister profiles
/harmony profiles --active        #   - Profiles actifs
/harmony profiles --add <name>    #   - Activer profile
/harmony profiles --remove <name> #   - Desactiver profile
/harmony specialties              # 23 - Lister specialties
/harmony specialties --active     #   - Specialties actives
/harmony specialties --add <name> #   - Activer specialty
/harmony specialties --remove <n> #   - Desactiver specialty

# 🔌 INTEGRATIONS (24-25)
/harmony install <ide>            # 24 - Deployer vers IDE
/harmony install --status         # 25 - Status integrations
/harmony install --list           #   - Lister IDEs supportes

# ✅ QUALITE HQVF (26-27)
/harmony ucv <story>              # 26 - Creer UCVs
/harmony ucv --validate <story>   # 27 - Valider couverture UCVs

# 🆕 FRAMEWORK (28-30)
/harmony init                     # 28 - Initialiser Harmony
/harmony init --minimal           #   - Installation minimale
/harmony upgrade                  # 29 - Mettre a jour
/harmony upgrade --check          #   - Verifier updates
/harmony export                   # 30 - Exporter config
/harmony export --full            #   - Export complet
\`\`\`

## Before Starting Work

1. Check \`.claude/memory/workflow-state.json\` for current phase (1-5)
2. Check \`.claude/memory/working.json\` for active story and blockers
3. Check \`.claude/memory/circuit-breaker.json\` - if OPEN, run \`/harmony sentinel --reset\` (option 18)

## Workflow Rules (Must Follow)

| Rule | Description |
|------|-------------|
| R-001 | Create a story before coding |
| R-002 | Get UCV approved before implementation |
| R-003 | 3 consecutive failures = circuit breaker OPEN (auto-stop) |
| R-007 | Complete current phase before advancing |

Current phase: **Discovery (Phase 1)**

## Development Phases

| Phase | Name | Key Artifacts | Next Gate |
|-------|------|---------------|-----------|
| 1 | Discovery | Brief | Brief approved |
| 2 | Planning | PRD, Roadmap | PRD approved |
| 3 | Solutioning | Architecture, Stories, UCVs | UCVs ready |
| 4 | Implementation | Code, Tests | UCVs 100% validated |
| 5 | Release | Deployment | Retrospective done |

## Architecture

\`\`\`
.harmony/                    # Core framework (read-only)
├── agents/                  # Agent definitions (Guardian, Sentinel, etc.)
├── workflows/               # Phase-specific processes (discovery.md, planning.md, etc.)
├── profiles/                # Tech stack knowledge (50+ templates)
├── templates/               # Story, epic, UCV templates
├── rules/                   # R-001 to R-008 rule definitions
└── docs/                    # Framework documentation

.claude/                     # Project-specific (local data)
├── memory/                  # Sprint/story tracking, error journal
├── commands/                # Slash commands (/harmony, /go, /sentinel)
└── settings.json            # Hooks configuration
\`\`\`

## Agent Routing

Guardian auto-routes based on intent keywords:

| Keywords | Routes To |
|----------|-----------|
| "develop", "create", "build", "code" | Developer |
| "fix", "bug", "error", "broken" | Developer + Sentinel |
| "test", "verify", "validate" | Tester |
| "plan", "design", "architect" | Architect |
| "analyze", "requirements" | Analyst |
| "UCV", "use case" | UCV Writer |

## UCV Pattern

Stories require UCVs with triple validation (story is DONE when all UCVs = 100%):

\`\`\`yaml
use_case:
  id: UC-001
  verifications:
    - id: V-001-1
      description: "What to verify"
      dev: [ ]    # Developer confirms
      test: [ ]   # Tester confirms
      qa: [ ]     # QA validates
\`\`\`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Circuit breaker OPEN | \`/harmony sentinel --reset\` (option 18) after analysis |
| Wrong agent activated | Use explicit keywords from Agent Routing table |
| Missing context | Check \`.claude/memory/working.json\` for active story |
CLAUDE_MD_EOF

    print_success "Created CLAUDE.md with Harmony instructions"
}

# Show a single tip with centered UI style
show_tip() {
    local tip_file=$1
    local tip_num=$2
    local tip_total=$3
    local tip_title=$4

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        ui_box_line top
        ui_box_title "💡 TIP $tip_num/$tip_total: $tip_title"
        ui_box_line mid

        # Display tip content (skip markdown headers)
        if [[ -f "$tip_file" ]]; then
            while IFS= read -r line; do
                # Skip empty lines and headers
                [[ -z "$line" || "$line" =~ ^# ]] && continue
                # Truncate long lines
                [[ ${#line} -gt 60 ]] && line="${line:0:57}..."
                ui_box_text "$line"
            done < "$tip_file"
        fi

        ui_box_line bot
        ui_continue
    else
        echo ""
        print_message "$PURPLE" "╔══════════════════════════════════════════════════════════╗"
        printf "${PURPLE}║  💡 TIP %d/%d: %-43s ║${NC}\n" "$tip_num" "$tip_total" "$tip_title"
        print_message "$PURPLE" "╠══════════════════════════════════════════════════════════╣"
        echo ""

        # Display tip content (skip markdown headers)
        if [[ -f "$tip_file" ]]; then
            grep -v "^#" "$tip_file" 2>/dev/null | grep -v "^$" | head -20 || true
        fi

        echo ""
        print_message "$PURPLE" "╚══════════════════════════════════════════════════════════╝"
        echo ""

        # Check if TTY is available for interactive input
        if (exec </dev/tty) 2>/dev/null; then
            read -rp "Appuyez sur Entrée pour continuer..." </dev/tty || true
        else
            sleep 2 || true
        fi
    fi
}

# Show all onboarding tips
show_onboarding_tips() {
    local tips_dir="$SCRIPT_DIR/tips"
    local tip_total=8
    local tip_num=0

    # Check if tips directory exists
    if [[ ! -d "$tips_dir" ]]; then
        print_warning "Tips directory not found. Skipping onboarding."
        return
    fi

    # Intro with centered UI
    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        ui_box_line top
        ui_box_title "📚 ONBOARDING - Découvrez Harmony"
        ui_box_line mid
        ui_box_text "Ces tips vous aideront à bien démarrer."
        ui_box_text "Appuyez sur Entrée après chaque tip."
        ui_box_line bot
        ui_continue "Appuyez sur Entrée pour commencer..."
    else
        echo ""
        print_message "$CYAN" "╔══════════════════════════════════════════════════════════╗"
        print_message "$CYAN" "║           📚 ONBOARDING - Découvrez Harmony              ║"
        print_message "$CYAN" "╚══════════════════════════════════════════════════════════╝"
        echo ""
        if (exec </dev/tty) 2>/dev/null; then
            read -rp "Appuyez sur Entrée pour commencer..." </dev/tty || true
        else
            sleep 2 || true
        fi
    fi

    # Tip 1: Welcome
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/01-welcome.md" $tip_num $tip_total "Bienvenue dans Harmony"

    # Tip 2: Sandbox (Linux only)
    tip_num=$((tip_num + 1))
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        show_tip "$tips_dir/07-sandbox.md" $tip_num $tip_total "Sandbox Claude Code (Recommandé)"
    else
        show_tip "$tips_dir/07-sandbox.md" $tip_num $tip_total "Sandbox (Linux uniquement)"
    fi

    # Tip 3: /go
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/02-go.md" $tip_num $tip_total "Commande /go"

    # Tip 4: /harmony
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/03-harmony.md" $tip_num $tip_total "Menu /harmony"

    # Tip 5: Sentinel
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/04-sentinel.md" $tip_num $tip_total "Protection Sentinel"

    # Tip 6: Agents
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/05-agents.md" $tip_num $tip_total "Invoquer les agents"

    # Tip 7: Profiles
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/06-profiles.md" $tip_num $tip_total "Votre boîte à outils"

    # Tip 8: RouteLLM (Auto-detection)
    tip_num=$((tip_num + 1))
    show_tip "$tips_dir/08-routellm.md" $tip_num $tip_total "Detection automatique (RouteLLM)"

    # Conclusion with centered UI
    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        ui_box_line top
        ui_box_title "✅ ONBOARDING TERMINÉ"
        ui_box_line mid
        ui_box_text "Vous êtes prêt à utiliser Harmony!"
        ui_box_line bot
    else
        echo ""
        print_message "$GREEN" "╔══════════════════════════════════════════════════════════╗"
        print_message "$GREEN" "║         ✅ ONBOARDING TERMINÉ - Vous êtes prêt !         ║"
        print_message "$GREEN" "╚══════════════════════════════════════════════════════════╝"
        echo ""
    fi
}

# Print summary
print_summary() {
    # Determine startup command based on IDE
    # ADR-010: Memory is in .harmony/local/memory/ (user data)
    local start_cmd
    local memory_path=".harmony/local/memory/"

    case "$_DETECTED_IDE" in
        claude-code)  start_cmd="/init puis /go" ;;
        cursor)       start_cmd="Ouvrir Cursor et utiliser @harmony" ;;
        windsurf)     start_cmd="Ouvrir Windsurf et utiliser /harmony" ;;
        continue)     start_cmd="Utiliser l'assistant Harmony dans Continue" ;;
        cody)         start_cmd="Utiliser le prompt Harmony dans Cody" ;;
        *)            start_cmd="Consulter .harmony/docs/getting-started.md" ;;
    esac

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        local hooks_status
        [[ "$CONFIGURE_HOOKS" == true ]] && hooks_status="activés" || hooks_status="désactivés"

        ui_success "Harmony Framework v$VERSION installé !" \
"IDE: $_DETECTED_IDE | Hooks: $hooks_status

Prochaine étape:
  → $start_cmd

Données: $memory_path
Docs: .harmony/docs/getting-started.md

Happy coding with Harmony! 🎵"
    else
        print_step "6/6" "Installation complete!"
        echo ""
        print_message "$GREEN" "╔══════════════════════════════════════════════════════════╗"
        print_message "$GREEN" "║              INSTALLATION SUCCESSFUL                      ║"
        print_message "$GREEN" "╚══════════════════════════════════════════════════════════╝"
        echo ""
        print_message "$CYAN" "Version: $VERSION"
        print_message "$CYAN" "IDE: $_DETECTED_IDE"
        print_message "$CYAN" "Hooks: $([ "$CONFIGURE_HOOKS" == true ] && echo "enabled" || echo "disabled")"
        echo ""
        print_message "$YELLOW" "Next step:"
        echo "  → $start_cmd"
        echo ""
        print_message "$CYAN" "Optional: Start Prompt Monitor for team learning"
        echo "  → harmony monitor install && harmony monitor start"
        echo ""
        print_message "$CYAN" "Data: $memory_path"
        print_message "$PURPLE" "Happy coding with Harmony! 🎵"
    fi
}

# Runtime detection variables (shared between écran 2 and 3)
_RUNTIME_OS=""
_RUNTIME_OS_NAME=""
_RUNTIME_PM=""
_RUNTIME_BASH=""
_RUNTIME_NODE=""
_RUNTIME_BUN=""
_RUNTIME_JQ=""
_RUNTIME_YQ=""
_RUNTIME_PERF=""

# Load runtime info (called once, results cached)
_load_runtime_info() {
    local lib_dir="$SCRIPT_DIR/lib"
    if [[ -f "$lib_dir/runtime-detect.sh" ]] && [[ -z "$_RUNTIME_OS" ]]; then
        source "$lib_dir/runtime-detect.sh"
        _RUNTIME_OS=$(detect_os)
        local distro=$(detect_linux_distro)
        local version=$(detect_os_version)
        _RUNTIME_PM=$(detect_package_manager)
        _RUNTIME_BASH=$(detect_bash_version || echo "")
        _RUNTIME_NODE=$(detect_node_version || echo "")
        _RUNTIME_BUN=$(detect_bun_version || echo "")
        _RUNTIME_JQ=$(detect_jq_version || echo "")
        _RUNTIME_YQ=$(detect_yq_version || echo "")
        _RUNTIME_PERF=$(detect_performance_level || echo "basic")

        # Construire nom OS
        _RUNTIME_OS_NAME="$_RUNTIME_OS"
        [[ "$_RUNTIME_OS" == "linux" ]] && _RUNTIME_OS_NAME="Linux ($distro $version)"
        [[ "$_RUNTIME_OS" == "macos" ]] && _RUNTIME_OS_NAME="macOS $version"
    fi
    return 0
}

# =============================================================================
# ÉCRAN 2: 🔧 Vérification Système
# =============================================================================
show_runtime_status_system_only() {
    _load_runtime_info

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        ui_box_line top
        ui_box_title "🔧 Vérification Système"
        ui_box_line mid
        ui_box_text "OS: $_RUNTIME_OS_NAME"
        ui_box_text "Package Manager: $_RUNTIME_PM"
        ui_box_line mid
        ui_box_title "Runtimes Détectés"

        # Bash - Requis
        if [[ -n "$_RUNTIME_BASH" ]]; then
            ui_box_text "[✓] Bash: $_RUNTIME_BASH (requis - scripts core)"
        else
            ui_box_text "[✗] Bash: non trouvé (REQUIS)"
        fi

        # Node - +30% performance
        if [[ -n "$_RUNTIME_NODE" ]]; then
            ui_box_text "[✓] Node: $_RUNTIME_NODE (+30% - async, JSON natif)"
        else
            ui_box_text "[!] Node: non installé (+30% performance)"
        fi

        # Bun - +80% performance (turbo)
        if [[ -n "$_RUNTIME_BUN" ]]; then
            ui_box_text "[✓] Bun: $_RUNTIME_BUN (+80% - runtime ultra-rapide)"
        else
            ui_box_text "[!] Bun: non installé (+80% TURBO mode)"
        fi

        # jq - +50% JSON streaming performance
        if [[ -n "$_RUNTIME_JQ" ]]; then
            ui_box_text "[✓] jq: $_RUNTIME_JQ (+50% - JSON streaming natif)"
        else
            ui_box_text "[!] jq: non installé (+50% JSON parsing)"
        fi

        # yq - +40% YAML parsing performance
        if [[ -n "$_RUNTIME_YQ" ]]; then
            ui_box_text "[✓] yq: $_RUNTIME_YQ (+40% - YAML parsing natif)"
        else
            ui_box_text "[!] yq: non installé (+40% YAML parsing)"
        fi

        ui_box_line mid

        local perf_label=""
        case "$_RUNTIME_PERF" in
            turbo) perf_label="TURBO 🚀" ;;
            enhanced) perf_label="ENHANCED ⚡" ;;
            standard) perf_label="STANDARD" ;;
            *) perf_label="BASIC" ;;
        esac
        ui_box_text "Performance: $perf_label"
        ui_box_line bot

        ui_continue
    else
        echo ""
        print_message "$CYAN" "Système: $_RUNTIME_OS_NAME ($_RUNTIME_PM)"
        [[ -n "$_RUNTIME_BASH" ]] && print_success "Bash: $_RUNTIME_BASH" || print_warning "Bash: non trouvé"
        [[ -n "$_RUNTIME_NODE" ]] && print_success "Node: $_RUNTIME_NODE" || print_warning "Node: non installé"
        [[ -n "$_RUNTIME_BUN" ]] && print_success "Bun: $_RUNTIME_BUN" || print_warning "Bun: non installé"
        [[ -n "$_RUNTIME_JQ" ]] && print_success "jq: $_RUNTIME_JQ (+50% JSON)" || print_warning "jq: non installé (+50% JSON)"
        [[ -n "$_RUNTIME_YQ" ]] && print_success "yq: $_RUNTIME_YQ (+40% YAML)" || print_warning "yq: non installé (+40% YAML)"
    fi
}

# =============================================================================
# ÉCRAN 3: 📦 Recommandations Performance + Sécurité
# =============================================================================
show_runtime_status_recommendations() {
    _load_runtime_info

    # Check if sandbox tools are installed (Linux only)
    local has_bubblewrap=false
    local has_socat=false
    command -v bwrap &>/dev/null && has_bubblewrap=true
    command -v socat &>/dev/null && has_socat=true

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        local has_recommendations=false

        # Check if any recommendations needed
        [[ -z "$_RUNTIME_NODE" || -z "$_RUNTIME_BUN" || -z "$_RUNTIME_JQ" || -z "$_RUNTIME_YQ" ]] && has_recommendations=true
        if [[ "$_RUNTIME_OS" == "linux" ]]; then
            [[ "$has_bubblewrap" == false || "$has_socat" == false ]] && has_recommendations=true
        fi

        if [[ "$has_recommendations" == true ]]; then
            ui_box_line top
            ui_box_title "📦 Recommandations"
            ui_box_line mid

            # Performance recommendations (optional)
            if [[ -z "$_RUNTIME_NODE" || -z "$_RUNTIME_BUN" || -z "$_RUNTIME_JQ" || -z "$_RUNTIME_YQ" ]]; then
                ui_box_text ""
                ui_box_text "Optionnel (performance):"
                [[ -z "$_RUNTIME_NODE" ]] && ui_box_text "  Node.js: $(get_install_cmd node)"
                [[ -z "$_RUNTIME_BUN" ]] && ui_box_text "  Bun:     $(get_install_cmd bun)"
                [[ -z "$_RUNTIME_JQ" ]] && ui_box_text "  jq:      $(get_install_cmd jq)"
                [[ -z "$_RUNTIME_YQ" ]] && ui_box_text "  yq:      $(get_install_cmd yq)"
            fi

            # Security recommendations (Linux sandbox)
            if [[ "$_RUNTIME_OS" == "linux" ]] && [[ "$has_bubblewrap" == false || "$has_socat" == false ]]; then
                ui_box_empty
                ui_box_text "Sécurité (Sandbox Claude Code):"
                [[ "$has_bubblewrap" == false ]] && ui_box_text "  bubblewrap: sudo apt install bubblewrap"
                [[ "$has_socat" == false ]] && ui_box_text "  socat:      sudo apt install socat"
                ui_box_text "  → Isole l'exécution des commandes"
            fi

            ui_box_empty
            ui_box_line bot
        else
            ui_box_line top
            ui_box_title "✓ Configuration optimale détectée"
            ui_box_empty
            ui_box_text "Tous les outils sont installés!"
            ui_box_empty
            ui_box_line bot
        fi
        ui_continue
    fi
}

# =============================================================================
# UI STEP DISPLAY - Affiche une étape dans un cadre UI simple
# =============================================================================
ui_show_step() {
    local icon="$1"
    local title="$2"
    local status="${3:-}"  # ok, warn, error, info, or empty

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        # Status replaces icon
        local display_icon="$icon"
        case "$status" in
            ok)    display_icon="✓" ;;
            warn)  display_icon="⚠" ;;
            error) display_icon="✗" ;;
            info)  display_icon="ℹ" ;;
        esac

        ui_box_line top
        ui_box_title "${display_icon} ${title}"
        ui_box_line bot
    else
        echo ""
        print_message "$CYAN" "=== ${icon} ${title} ==="
    fi
}

# Main function - 13 écrans UI step-by-step
main() {
    parse_args "$@"

    # =========================================================================
    # ÉCRAN 1: Accueil + Confirmation
    # =========================================================================
    print_header
    ask_install_confirmation

    # =========================================================================
    # ÉCRAN 2: 🔧 Vérification Système
    # =========================================================================
    show_runtime_status_system_only

    # =========================================================================
    # ÉCRAN 2.5: 🔌 MCP Servers (OBLIGATOIRES)
    # =========================================================================
    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        ui_box_line top
        ui_box_title "🔌 MCP Servers (OBLIGATOIRES)"
        ui_box_line mid
        ui_box_text "Les MCP servers Anthropic sont requis pour Harmony:"
        ui_box_text "  • memory: Cross-session learning, Sentinel patterns"
        ui_box_text "  • sequentialthinking: Structured problem decomposition"
        ui_box_empty
        ui_box_text "Configuration à ajouter dans votre client MCP:"
        ui_box_text '  {'
        ui_box_text '    "mcpServers": {'
        ui_box_text '      "memory": {'
        ui_box_text '        "command": "npx",'
        ui_box_text '        "args": ["-y", "@modelcontextprotocol/server-memory"]'
        ui_box_text '      },'
        ui_box_text '      "sequentialthinking": {'
        ui_box_text '        "command": "npx",'
        ui_box_text '        "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]'
        ui_box_text '      }'
        ui_box_text '    }'
        ui_box_text '  }'
        ui_box_empty
        ui_box_line bot
        ui_continue
    else
        echo ""
        print_message "$WHITE" "🔌 MCP Servers (OBLIGATOIRES)"
        print_message "$YELLOW" "Les MCP servers Anthropic sont requis pour Harmony."
        print_message "$CYAN" "Ajoutez dans votre client MCP (Claude Desktop/Cursor/VS Code):"
        echo '  {"mcpServers": {"memory": {...}, "sequentialthinking": {...}}}'
    fi

    # =========================================================================
    # ÉCRAN 3: 📦 Recommandations Performance
    # =========================================================================
    show_runtime_status_recommendations

    # =========================================================================
    # ÉCRAN 4: Prerequisites check
    # =========================================================================
    check_prerequisites
    detect_ide
    ui_show_step "✓" "Prerequisites check passed" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 5: Directory structure created
    # =========================================================================
    create_directory_structure
    ui_show_step "📁" "Directory structure created" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 6: Framework files copied
    # =========================================================================
    copy_framework_files
    ui_show_step "📄" "All framework files copied" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 7: Hooks configured
    # =========================================================================
    configure_hooks
    ui_show_step "🔗" "Claude Code hooks configured" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 8: Memory initialized
    # =========================================================================
    initialize_memory
    ui_show_step "🧠" "Memory files initialized" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 9: Autopilot config
    # =========================================================================
    initialize_autopilot_config
    ui_show_step "🤖" "Autopilot configuration ready" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 9.5: User config
    # =========================================================================
    initialize_user_config
    ui_show_step "👤" "User configuration template ready" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 10: Slash commands
    # =========================================================================
    create_slash_commands
    ui_show_step "⚡" "Slash commands generated" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 11: CLAUDE.md created
    # =========================================================================
    create_claude_md
    ui_show_step "📝" "CLAUDE.md created from template" "ok"
    [[ "$UI_LIBRARY_LOADED" == true ]] && ui_continue

    # =========================================================================
    # ÉCRAN 12: Onboarding tips
    # =========================================================================
    show_onboarding_tips

    # =========================================================================
    # ÉCRAN 13: SUCCESS final
    # =========================================================================
    print_summary
}

# Run main
main "$@"
