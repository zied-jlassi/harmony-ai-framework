#!/bin/bash

# ============================================================
# Harmony Framework - Installation Script
# ============================================================
# This script installs the Harmony Framework into a project.
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

# Print success
print_success() {
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
  git clone https://github.com/harmony-ai/harmony-framework
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

  https://github.com/harmony-ai/harmony-framework

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

# Detect IDE and set memory directory
detect_ide_and_memory_path() {
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

    # Set memory directory based on IDE
    case "$detected_ide" in
        claude-code)
            MEMORY_DIR="$PROJECT_DIR/.claude/memory"
            IDE_CONFIG_DIR="$PROJECT_DIR/.claude"
            ;;
        cursor)
            MEMORY_DIR="$PROJECT_DIR/.cursor/harmony-memory"
            IDE_CONFIG_DIR="$PROJECT_DIR/.cursor"
            ;;
        windsurf)
            MEMORY_DIR="$PROJECT_DIR/.windsurf/harmony-memory"
            IDE_CONFIG_DIR="$PROJECT_DIR/.windsurf"
            ;;
        continue)
            MEMORY_DIR="$PROJECT_DIR/.continue/harmony-memory"
            IDE_CONFIG_DIR="$PROJECT_DIR/.continue"
            ;;
        cody)
            MEMORY_DIR="$PROJECT_DIR/.cody/harmony-memory"
            IDE_CONFIG_DIR="$PROJECT_DIR/.cody"
            ;;
        generic|*)
            MEMORY_DIR="$PROJECT_DIR/.harmony-local/memory"
            IDE_CONFIG_DIR="$PROJECT_DIR/.harmony-local"
            ;;
    esac

    print_message "$CYAN" "  IDE detected: $detected_ide"
    print_message "$CYAN" "  Memory path: $MEMORY_DIR"

    # Save config for Harmony to know where memory is
    mkdir -p "$PROJECT_DIR/.harmony/config"
    cat > "$PROJECT_DIR/.harmony/config/paths.json" << EOF
{
  "ide": "$detected_ide",
  "memory_dir": "$MEMORY_DIR",
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

    print_success "Prerequisites check passed"
    # Show source directory for debugging
    print_message "$CYAN" "  IDE detected: $IDE_TARGET"
    print_message "$CYAN" "  Source: $SCRIPT_DIR"
    print_message "$CYAN" "  Target: $PROJECT_DIR"
}

# Create directory structure
create_directory_structure() {
    print_step "2/6" "Creating directory structure..."

    local dirs=(
        ".harmony"
        ".harmony/agents"
        ".harmony/agents/cognitive"
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
        ".harmony/specialties/compliance/knowledge"
        ".harmony/specialties/i18n/knowledge"
        ".harmony/profiles/mobile/flutter"
        ".harmony/profiles/backend/nestjs/knowledge/templates"
        ".harmony/profiles/backend/nestjs/knowledge/cheatsheets"
        ".harmony/profiles/backend/nestjs/knowledge/integrations"
        ".harmony/profiles/backend/nestjs/knowledge/pitfalls"
        # Local directories (project-specific)
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
        local dirs_to_copy=(
            "agents"
            "commands"
            "config"
            "docs"
            "error-library"
            "hooks"
            "knowledge"
            "lib"
            "local"
            "memory"
            "patterns"
            "profiles"
            "rules"
            "specialties"
            "templates"
            "tips"
            "workflows"
        )

        for dir in "${dirs_to_copy[@]}"; do
            if [[ -d "$SCRIPT_DIR/$dir" ]]; then
                # Use cp -r source/. dest/ to copy contents (not just subdirs)
                mkdir -p "$PROJECT_DIR/.harmony/$dir"
                cp -r "$SCRIPT_DIR/$dir/." "$PROJECT_DIR/.harmony/$dir/"
            else
                print_warning "Directory not found: $SCRIPT_DIR/$dir"
            fi
        done

        # Copy essential files (exclude npm artifacts like package.json, bin/, .npmrc)
        local essential_missing=0
        for file in README.md LICENSE harmony.manifest.json; do
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

        if [[ -f "$settings_file" ]]; then
            # Backup existing settings
            cp "$settings_file" "${settings_file}.backup"
            print_warning "Existing settings backed up to settings.json.backup"
        fi

        # Create settings with hooks configuration
        cat > "$settings_file" << 'EOF'
{
  "hooks": {
    "PreToolUse": [
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
      }
    ]
  }
}
EOF
        print_success "Claude Code hooks configured"
    else
        print_warning "Hooks not configured. Use --hooks to enable."
    fi
}

# Initialize memory files (in IDE-specific location for project isolation)
initialize_memory() {
    print_step "5/6" "Initializing project memory files..."

    # IMPORTANT: Memory files go in IDE-specific location NOT .harmony/memory/
    # This separates:
    #   - .harmony/ = Core framework (read-only, shareable, PR-able)
    #   - $MEMORY_DIR = Project-specific data (local, never committed to Harmony)
    #
    # Memory paths by IDE:
    #   - Claude Code: .claude/memory/
    #   - Cursor: .cursor/harmony-memory/
    #   - Windsurf: .windsurf/harmony-memory/
    #   - Continue: .continue/harmony-memory/
    #   - Cody: .cody/harmony-memory/
    #   - Generic: .harmony-local/memory/

    local memory_dir="$MEMORY_DIR"
    mkdir -p "$memory_dir"

    # Initialize workflow state (unified schema v1.0)
    cat > "$memory_dir/workflow-state.json" << 'EOF'
{
  "version": "1.0",
  "last_updated": null,
  "harmony": {
    "version": "1.0.0",
    "initialized": true,
    "project_name": null,
    "language": "en"
  },
  "phase": {
    "current": 1,
    "name": "Discovery",
    "started": null,
    "gates_passed": []
  },
  "guardian": {
    "enabled": true,
    "mode": "warn",
    "require_story": true,
    "require_ucv": true,
    "allowed_directories": [
      ".harmony/",
      ".claude/",
      "docs/",
      "*.md",
      "*.json",
      "*.yaml"
    ]
  },
  "sentinel": {
    "enabled": true,
    "error_memory": true,
    "pattern_learning": true
  },
  "hqvf": {
    "enabled": true,
    "require_approval": true,
    "coverage_target": 100
  },
  "active_context": {
    "current_story": null,
    "current_sprint": null,
    "current_epic": null,
    "active_agent": null,
    "last_handoff": null
  },
  "sprint": {
    "id": null,
    "name": null,
    "start_date": null,
    "end_date": null,
    "stories": [],
    "velocity": 0
  },
  "statistics": {
    "stories_completed": 0,
    "ucvs_created": 0,
    "errors_recorded": 0,
    "patterns_learned": 0
  }
}
EOF

    # Initialize error journal
    cat > "$memory_dir/error-journal.json" << 'EOF'
{
  "version": "1.0.0",
  "errors": [],
  "patterns": [],
  "statistics": {
    "total_errors": 0,
    "resolved_errors": 0,
    "patterns_extracted": 0
  }
}
EOF

    # Initialize circuit breaker
    cat > "$memory_dir/circuit-breaker.json" << 'EOF'
{
  "version": "1.0.0",
  "state": "CLOSED",
  "consecutive_failures": 0,
  "max_failures": 3,
  "last_failure": null,
  "last_success": null,
  "history": []
}
EOF

    # Initialize learned patterns
    cat > "$memory_dir/learned-patterns.json" << 'EOF'
{
  "version": "1.0.0",
  "patterns": [],
  "anti_patterns": [],
  "statistics": {
    "total_patterns": 0,
    "applied_count": 0,
    "prevented_errors": 0
  }
}
EOF

    # Initialize user preferences
    cat > "$memory_dir/user-preferences.json" << 'EOF'
{
  "version": "1.0.0",
  "user": {
    "name": null,
    "skill_level": "intermediate",
    "communication_language": "en",
    "document_language": "en"
  },
  "guardian": {
    "mode": "warn",
    "allowed_skip_phases": false
  },
  "agents": {
    "preferred_personas": true,
    "verbose_output": false
  },
  "learned_habits": [],
  "shortcuts": {}
}
EOF

    # Initialize working memory (sprint/story tracking)
    cat > "$memory_dir/working.json" << 'EOF'
{
  "_meta": {
    "version": "1.0.0",
    "description": "Working memory for sprint and story tracking",
    "last_updated": null,
    "updated_by": null
  },
  "current_sprint": {
    "id": null,
    "name": null,
    "goal": null,
    "started": null,
    "ends": null,
    "velocity_target": 0,
    "velocity_achieved": 0,
    "stories": []
  },
  "current_story": {
    "id": null,
    "title": null,
    "points": 0,
    "status": null,
    "assigned_to": null,
    "started_at": null,
    "tasks_completed": 0,
    "tasks_total": 0
  },
  "sprint_history": [],
  "backlog": {
    "total_stories": 0,
    "ready_stories": 0,
    "blocked_stories": 0
  },
  "velocity": {
    "last_3_sprints": [],
    "average": 0,
    "trend": "stable"
  },
  "blockers": [],
  "recent_decisions": [],
  "next_steps": [],
  "statistics": {
    "stories_completed_total": 0,
    "points_delivered_total": 0,
    "bugs_found": 0,
    "tech_debt_ratio": 0
  },
  "_checkpoint": {
    "pending_action": null,
    "pending_since": null,
    "recovery_hint": null
  }
}
EOF

    print_success "Memory files initialized"
}

# Initialize autopilot configuration
initialize_autopilot_config() {
    print_step "5.7/6" "Initializing autopilot configuration..."

    local local_dir="$PROJECT_DIR/.harmony/local"
    mkdir -p "$local_dir"

    # Create autopilot-config.json if it doesn't exist
    local config_file="$local_dir/autopilot-config.json"
    if [[ ! -f "$config_file" ]]; then
        # Copy template from framework/local/autopilot-config.json
        if [[ -f "$SCRIPT_DIR/local/autopilot-config.json" ]]; then
            cp "$SCRIPT_DIR/local/autopilot-config.json" "$config_file"
            print_success "Autopilot configuration created at .harmony/local/autopilot-config.json"
        else
            # Fallback: create default config inline
            cat > "$config_file" << 'EOF'
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
    else
        print_success "Autopilot configuration already exists"
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
    #   - TestArch: /hf:testarch:* (4 commands)
    #   - Diagrams: /hf:diagram:* (4 commands)
    if [[ -x "$SCRIPT_DIR/bin/generate-commands.sh" ]]; then
        "$SCRIPT_DIR/bin/generate-commands.sh" "$commands_dir" > /dev/null 2>&1
        local total_count=$(ls -1 "$commands_dir"/*.md 2>/dev/null | wc -l)
        print_success "Generated $total_count slash commands in .claude/commands/"
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

    # Harmony header block (must be at TOP for Claude to see it first)
    # Note: read -r -d '' returns 1 at EOF, so we use || true to prevent set -e exit
    local harmony_header
    read -r -d '' harmony_header << 'HARMONY_HEADER' || true
## 🛡️ HARMONY FRAMEWORK (ACTIVE)

> **IMPORTANT**: This project uses the Harmony AI Framework. Read `.harmony/docs/` for full documentation.

| Pillar | Role |
|--------|------|
| **Guardian** | Intent detection, agent routing, workflow protection |
| **Sentinel** | Error memory, circuit breaker (3 failures = stop) |
| **HQVF** | Use Case Verifiables, triple validation (Dev+Test+QA) |

**Essential:** `/go` (session start) • `/harmony` (30 commands) • `/harmony quick` (validation)

**Data:** `.harmony/` (framework) • `.claude/memory/` (project data)

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

# Show a single tip with Space+Enter confirmation
show_tip() {
    local tip_file=$1
    local tip_num=$2
    local tip_total=$3
    local tip_title=$4

    echo ""
    print_message "$PURPLE" "╔══════════════════════════════════════════════════════════╗"
    printf "${PURPLE}║  💡 TIP %d/%d: %-43s ║${NC}\n" "$tip_num" "$tip_total" "$tip_title"
    print_message "$PURPLE" "╠══════════════════════════════════════════════════════════╣"
    echo ""

    # Display tip content (skip markdown headers)
    if [[ -f "$tip_file" ]]; then
        # Use || true to prevent set -e exit if grep finds no matches
        grep -v "^#" "$tip_file" 2>/dev/null | grep -v "^$" | head -20 || true
    fi

    echo ""
    print_message "$PURPLE" "╚══════════════════════════════════════════════════════════╝"
    echo ""

    # Check if TTY is available for interactive input (test in subshell)
    if (exec </dev/tty) 2>/dev/null; then
        # Interactive mode: wait for Space + Enter
        printf "${YELLOW}[ ] J'ai lu ce tip (Espace puis Entrée pour continuer)${NC}"

        while true; do
            # Use || true to prevent set -e exit on read failure
            read -rsn1 key </dev/tty 2>/dev/null || true
            if [[ "$key" == " " ]]; then
                printf "\r${GREEN}[✓] J'ai lu ce tip                                  ${NC}\n"
                read -r </dev/tty 2>/dev/null || true
                break
            elif [[ -z "$key" ]]; then
                # EOF or error - break out
                printf "\r${YELLOW}[→] Continué automatiquement                       ${NC}\n"
                break
            fi
        done
    else
        # Non-interactive: auto-advance with delay
        printf "${CYAN}[⏳ Lecture auto dans 3s...]${NC}"
        sleep 3 || true
        printf "\r${GREEN}[✓] Tip lu                                          ${NC}\n"
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

    echo ""
    print_message "$CYAN" "╔══════════════════════════════════════════════════════════╗"
    print_message "$CYAN" "║           📚 ONBOARDING - Découvrez Harmony              ║"
    print_message "$CYAN" "║                                                          ║"
    print_message "$CYAN" "║   Ces tips vous aideront à bien démarrer.                ║"
    print_message "$CYAN" "║   Appuyez sur ESPACE puis ENTRÉE après chaque tip.       ║"
    print_message "$CYAN" "╚══════════════════════════════════════════════════════════╝"
    echo ""

    # Check if TTY is available for interactive input
    if (exec </dev/tty) 2>/dev/null; then
        read -rp "Appuyez sur Entrée pour commencer..." </dev/tty || true
    else
        echo "Mode non-interactif détecté. Affichage automatique des tips (3s par tip)..."
        sleep 2 || true
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

    echo ""
    print_message "$GREEN" "╔══════════════════════════════════════════════════════════╗"
    print_message "$GREEN" "║         ✅ ONBOARDING TERMINÉ - Vous êtes prêt !         ║"
    print_message "$GREEN" "╚══════════════════════════════════════════════════════════╝"
    echo ""
}

# Print summary
print_summary() {
    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        local hooks_status
        [[ "$CONFIGURE_HOOKS" == true ]] && hooks_status="activés" || hooks_status="désactivés"

        ui_success "Harmony Framework v$VERSION installé !" \
"Installation: $PROJECT_DIR/.harmony
Mode: $INSTALL_MODE | Hooks: $hooks_status

Prochaines étapes:
  1. Consultez .harmony/docs/getting-started.md
  2. Exécutez /go pour démarrer votre session
  3. Données projet dans .claude/memory/

Happy coding with Harmony! 🎵"
    else
        print_step "6/6" "Installation complete!"
        echo ""
        print_message "$GREEN" "╔══════════════════════════════════════════════════════════╗"
        print_message "$GREEN" "║              INSTALLATION SUCCESSFUL                      ║"
        print_message "$GREEN" "╚══════════════════════════════════════════════════════════╝"
        echo ""
        print_message "$CYAN" "Version: $VERSION"
        print_message "$CYAN" "Installed to: $PROJECT_DIR/.harmony"
        print_message "$CYAN" "Mode: $INSTALL_MODE"
        print_message "$CYAN" "Hooks: $([ "$CONFIGURE_HOOKS" == true ] && echo "enabled" || echo "disabled")"
        echo ""
        print_message "$YELLOW" "Next steps:"
        echo "  1. Review .harmony/docs/getting-started.md"
        echo "  2. Run /go to start your session"
        echo "  3. Memory files are in .claude/memory/ (project-specific data)"
        echo ""
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

        [[ -n "$_RUNTIME_BASH" ]] && ui_box_status ok "Bash" "$_RUNTIME_BASH" || ui_box_status error "Bash" "non trouvé"
        [[ -n "$_RUNTIME_NODE" ]] && ui_box_status ok "Node" "$_RUNTIME_NODE" || ui_box_status warn "Node" "non installé"
        [[ -n "$_RUNTIME_BUN" ]] && ui_box_status ok "Bun" "$_RUNTIME_BUN" || ui_box_status warn "Bun" "non installé"
        [[ -n "$_RUNTIME_JQ" ]] && ui_box_status ok "jq" "$_RUNTIME_JQ" || ui_box_status warn "jq" "non installé"

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
        [[ -n "$_RUNTIME_JQ" ]] && print_success "jq: $_RUNTIME_JQ" || print_warning "jq: non installé"
    fi
}

# =============================================================================
# ÉCRAN 3: 📦 Recommandations Performance
# =============================================================================
show_runtime_status_recommendations() {
    _load_runtime_info

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        if [[ -z "$_RUNTIME_NODE" || -z "$_RUNTIME_BUN" || -z "$_RUNTIME_JQ" ]]; then
            ui_box_line top
            ui_box_title "📦 Recommandations Performance"
            ui_box_line mid
            ui_box_text "Pour de meilleures performances, installez:"
            ui_box_empty
            [[ -z "$_RUNTIME_NODE" ]] && ui_box_text "  Node.js: $(get_install_cmd node)"
            [[ -z "$_RUNTIME_BUN" ]] && ui_box_text "  Bun:     $(get_install_cmd bun)"
            [[ -z "$_RUNTIME_JQ" ]] && ui_box_text "  jq:      $(get_install_cmd jq)"
            ui_box_empty
            ui_box_line bot
        else
            ui_box_line top
            ui_box_title "✓ Configuration optimale détectée"
            ui_box_empty
            ui_box_text "Tous les outils de performance sont installés!"
            ui_box_empty
            ui_box_line bot
        fi
        ui_continue
    fi
}

# =============================================================================
# UI STEP DISPLAY - Affiche une étape dans un cadre UI
# =============================================================================
ui_show_step() {
    local icon="$1"
    local title="$2"
    local status="${3:-}"  # ok, warn, error, info, or empty

    if [[ "$UI_LIBRARY_LOADED" == true ]]; then
        echo ""
        ui_box_line top
        if [[ -n "$status" ]]; then
            local status_icon status_color
            case "$status" in
                ok)    status_icon="✓"; status_color="$UI_GREEN" ;;
                warn)  status_icon="!"; status_color="$UI_YELLOW" ;;
                error) status_icon="✗"; status_color="$UI_RED" ;;
                info)  status_icon="i"; status_color="$UI_CYAN" ;;
            esac
            ui_box_title "${icon} ${title}"
            ui_box_line thin
            printf "${_UI_PADDING}║                    ${status_color}${status_icon} ${title}${UI_RESET}                        ║\n"
        else
            ui_box_title "${icon} ${title}"
        fi
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
    # ÉCRAN 3: 📦 Recommandations Performance
    # =========================================================================
    show_runtime_status_recommendations

    # =========================================================================
    # ÉCRAN 4: Prerequisites check
    # =========================================================================
    check_prerequisites
    detect_ide_and_memory_path
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
