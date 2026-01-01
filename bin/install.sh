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

# Colors for output
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
# Resolve symlinks to get the real script location
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")/.." && pwd)"

# Get version from package.json
VERSION=$(grep '"version"' "$SCRIPT_DIR/package.json" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/' || echo "unknown")

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo ""
    print_message "$PURPLE" "╔══════════════════════════════════════════════════════════╗"
    print_message "$PURPLE" "║                  HARMONY FRAMEWORK                        ║"
    print_message "$PURPLE" "║            Self-Improving AI Development                  ║"
    printf "${PURPLE}║                    Version: %-29s ║${NC}\n" "$VERSION"
    print_message "$PURPLE" "╚══════════════════════════════════════════════════════════╝"
    echo ""
}

# Print step
print_step() {
    local step=$1
    local message=$2
    print_message "$CYAN" "[$step] $message"
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
}

# Create directory structure
create_directory_structure() {
    print_step "2/6" "Creating directory structure..."

    local dirs=(
        ".harmony"
        ".harmony/agents"
        ".harmony/agents/specialists"
        ".harmony/agents/specialists/sub-agents"
        ".harmony/agents/compliance"
        ".harmony/docs"
        ".harmony/hooks"
        ".harmony/memory"
        ".harmony/patterns"
        ".harmony/rules"
        ".harmony/templates"
        ".harmony/workflows"
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
            "hooks"
            "lib"
            "memory"
            "patterns"
            "profiles"
            "rules"
            "specialties"
            "templates"
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
        for file in README.md LICENSE harmony.manifest.json; do
            if [[ -f "$SCRIPT_DIR/$file" ]]; then
                cp "$SCRIPT_DIR/$file" "$PROJECT_DIR/.harmony/"
            fi
        done

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
            if sha256sum -c checksums.sha256 --quiet 2>/dev/null; then
                print_success "All framework files copied ($file_count files, checksums verified)"
            else
                print_error "Checksum verification failed! Files may be corrupted."
                sha256sum -c checksums.sha256 2>&1 | grep -v ": OK"
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
            )
            local missing=0

            for cf in "${critical_files[@]}"; do
                if [[ ! -f "$PROJECT_DIR/.harmony/$cf" ]]; then
                    print_error "Critical file missing: $cf"
                    ((missing++))
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

    # Initialize workflow state
    cat > "$memory_dir/workflow-state.json" << 'EOF'
{
  "version": "1.0.0",
  "current_phase": 1,
  "phase_name": "Discovery",
  "active_story": null,
  "active_epic": null,
  "guardian": {
    "mode": "warn",
    "require_story": true,
    "require_ucv": true
  },
  "session": {
    "id": null,
    "started_at": null,
    "last_activity": null
  },
  "context": {
    "active_files": [],
    "recent_operations": [],
    "pending_tasks": []
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

# Create Claude Code slash commands
create_slash_commands() {
    # Always create slash commands for full install or if hooks requested
    if [[ "$INSTALL_MODE" != "full" ]] && [[ "$CONFIGURE_HOOKS" != true ]]; then
        return
    fi

    print_step "5.5/6" "Creating Claude Code slash commands..."

    local commands_dir="$PROJECT_DIR/.claude/commands"
    mkdir -p "$commands_dir"

    # Create harmony.md slash command
    cat > "$commands_dir/harmony.md" << 'HARMONY_CMD_EOF'
---
description: "Harmony - Modes: full | quick | duplicates | fix | tokens | report | pipeline | claude | rules | sentinel | learn | ucv | profiles | specialties"
---

# Harmony - Framework Orchestrator

Active l'agent Harmony pour orchestrer le framework Harmony.

## Comportement

**Si aucun argument fourni:**
Afficher le menu interactif et attendre la selection.

**Si argument fourni:**
Executer directement le mode specifie: `$ARGUMENTS`

## Modes Disponibles

```bash
/harmony                        # Menu interactif
/harmony --mode full            # Audit complet
/harmony --mode quick           # Check rapide
/harmony --mode duplicates      # Analyser duplications
/harmony --mode fix             # Proposer corrections
/harmony --mode tokens          # Rapport tokens
/harmony --mode report          # Matrice coherence
/harmony --mode pipeline        # Validation pipeline
/harmony --mode hooks           # Validation hooks Claude
/harmony --mode patterns        # Validation patterns
/harmony --mode memory          # Sync MCP memory
/harmony --mode claude          # Validation config Claude Code
/harmony --mode rules           # Audit complet des regles
/harmony --mode sentinel        # Dashboard sante systeme memoire
/harmony --mode sentinel --learn   # Documenter une erreur
/harmony --mode sentinel --reset   # Reinitialiser circuit breaker
/harmony --mode learn <url>        # Apprendre depuis URL
/harmony --mode profiles           # Lister tech profiles disponibles
/harmony --mode specialties        # Lister specialties disponibles
/harmony --mode ucv STORY-XXX      # Creer UCVs pour une story
/harmony --mode ucv --validate STORY-XXX  # Verifier couverture 100%
```

## Documentation

| Mode | Fichiers Reference |
|------|--------------------|
| full, quick, duplicates, fix | `.harmony/agents/harmony.md` |
| sentinel | `.harmony/memory/` |
| ucv | `.harmony/agents/specialists/ucv-writer.md` |
| ucv --validate | `.harmony/agents/specialists/ucv-validator.md` |
| rules | `.harmony/rules/` |
| profiles | `.harmony/profiles/` |
| specialties | `.harmony/specialties/` |

## Execution

Charger l'agent depuis `.harmony/agents/harmony.md` et executer selon le mode.

Arguments: $ARGUMENTS
HARMONY_CMD_EOF

    # Copy additional slash commands from .harmony/commands/
    local additional_commands=("go" "sentinel" "atlas")
    for cmd in "${additional_commands[@]}"; do
        if [[ -f "$PROJECT_DIR/.harmony/commands/${cmd}.md" ]]; then
            # Extract description and create simplified slash command
            local desc=$(grep -m1 "^description:" "$PROJECT_DIR/.harmony/commands/${cmd}.md" 2>/dev/null | sed 's/description: *"//' | sed 's/"$//')
            if [[ -n "$desc" ]]; then
                cat > "$commands_dir/${cmd}.md" << CMD_EOF
---
description: "${desc}"
---

Load and execute the ${cmd} command from \`.harmony/commands/${cmd}.md\`.

Arguments: \$ARGUMENTS
CMD_EOF
            else
                cp "$PROJECT_DIR/.harmony/commands/${cmd}.md" "$commands_dir/${cmd}.md"
            fi
        fi
    done

    local cmd_count=$(ls -1 "$commands_dir"/*.md 2>/dev/null | wc -l)
    print_success "Created $cmd_count slash commands in .claude/commands/"
}

# Create CLAUDE.md if it doesn't exist
create_claude_md() {
    local claude_md="$PROJECT_DIR/CLAUDE.md"

    # Don't overwrite existing CLAUDE.md
    if [[ -f "$claude_md" ]] && [[ "$FORCE" != true ]]; then
        print_warning "CLAUDE.md already exists. Skipping (use --force to overwrite)."
        return
    fi

    print_step "5.6/6" "Creating CLAUDE.md..."

    # Get project name from directory
    local project_name=$(basename "$PROJECT_DIR")

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
/go                               # Session kickoff - show current context
/harmony                          # Interactive menu
/harmony --mode quick             # Quick health check
/harmony --mode sentinel          # Error memory dashboard
/harmony --mode sentinel --reset  # Reset circuit breaker if stuck
/harmony --mode ucv STORY-XXX     # Create UCVs for a story
\`\`\`

## Before Starting Work

1. Check \`.claude/memory/workflow-state.json\` for current phase (1-5)
2. Check \`.claude/memory/working.json\` for active story and blockers
3. Check \`.claude/memory/circuit-breaker.json\` - if OPEN, run \`/harmony --mode sentinel --reset\`

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
| Circuit breaker OPEN | \`/harmony --mode sentinel --reset\` after analysis |
| Wrong agent activated | Use explicit keywords from Agent Routing table |
| Missing context | Check \`.claude/memory/working.json\` for active story |
CLAUDE_MD_EOF

    print_success "Created CLAUDE.md with Harmony instructions"
}

# Print summary
print_summary() {
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
    echo "  2. Configure user preferences in .harmony/memory/user-preferences.json"
    echo "  3. Start using Harmony in your AI assistant"
    echo ""
    print_message "$PURPLE" "Happy coding with Harmony! 🎵"
}

# Main function
main() {
    print_header
    parse_args "$@"
    check_prerequisites
    detect_ide_and_memory_path
    create_directory_structure
    copy_framework_files
    configure_hooks
    initialize_memory
    create_slash_commands
    create_claude_md
    print_summary
}

# Run main
main "$@"
