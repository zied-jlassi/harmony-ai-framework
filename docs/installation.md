# Installation Guide

> **🌐 Language:** English · [Français](fr/installation.md)

Complete guide for installing Harmony Framework in your project.

## Prerequisites (Mandatory)

Harmony Framework requires these tools to be installed **before** installation:

| Tool | Version | Purpose | Installation |
|------|---------|---------|--------------|
| **Node.js** | 18+ | Runtime for npx | [nodejs.org](https://nodejs.org/) |
| **jq** | 1.6+ | JSON processing & config parsing | See below |
| **yq** | any | YAML processing & config loading | See below |

### Why jq and yq?

- **Performance**: Native JSON/YAML parsing is 10-100x faster than shell alternatives
- **Reliability**: Robust config file handling without regex hacks
- **Features**: Deep merge, path queries, format conversion

### Installation by OS

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install -y jq yq
```

**macOS:**
```bash
brew install jq yq
```

**Fedora/RHEL:**
```bash
sudo dnf install -y jq yq
```

**Arch Linux:**
```bash
sudo pacman -S jq yq
```

**Windows (WSL2 recommended):**
```bash
# In WSL2 Ubuntu:
sudo apt update && sudo apt install -y jq yq
```

### Verify Installation

```bash
# All three must succeed
node --version   # v18.0.0 or higher
jq --version     # jq-1.6 or higher
yq --version     # any version works
```

> ⚠️ **Installation will fail** if jq or yq are not found in your PATH.

---

## Installation Methods

Harmony installs itself **into your project** with a single `npx` command — there is no
global install and no separate `init` step. Run it from your project root.

### Method 1: npx (Recommended)

```bash
# Full installation WITH hooks (recommended)
npx harmony-ai --full
```

That's it. The installer creates `.harmony/` in your project, configures Claude Code
hooks automatically (into `.claude/settings.json`), and prints a summary.

#### Options

| Flag | Effect |
|------|--------|
| `--full` | Full framework **with** hooks (recommended) |
| `--minimal` | Core files only, **no** hooks |
| `--hooks` | Enable hooks (already included in `--full`) |
| `--no-hooks` | Use with `--full` to install everything except hooks |
| `--ide TYPE` | Target IDE: `auto` (default), `claude-code`, `cursor`, `windsurf`, `continue`, `cody` |
| `--project-dir PATH` | Target project directory (must already exist; default: current directory) |
| `--force` | Overwrite an existing installation |
| `--help` | Show all options |

```bash
# Full installation for Cursor
npx harmony-ai --full --ide cursor

# Full installation without hooks
npx harmony-ai --full --no-hooks

# Minimal installation (no hooks)
npx harmony-ai --minimal

# Force reinstall / restore
npx harmony-ai --full --force
```

### Method 2: Manual Installation (from a clone)

```bash
# Clone the repository
git clone https://github.com/zied-jlassi/harmony-ai-framework.git

# Run the installer against your project (the target dir must already exist)
./harmony-ai-framework/bin/install.sh --full --project-dir /path/to/your/project
```

> **Note**: The published npm package is **`harmony-ai`**. There is no `harmony init`,
> `harmony doctor`, or other `harmony <subcommand>` CLI — once installed, you drive
> Harmony through slash commands (`/go`, `/harmony`) inside your AI assistant.

---

## Post-Installation Setup

### 1. Configure Your AI Assistant

#### For Claude Code

**Hooks are configured automatically** when you install with `--full`. The installer
writes them to `.claude/settings.json` (backing up any existing file). You normally
don't need to touch anything.

The installation wires seven hooks:

| Phase | Matcher | Hook | Role |
|-------|---------|------|------|
| `PreToolUse` | `Edit\|Write` | `aria-detect.sh` | Accessibility detection on edits |
| `PreToolUse` | `Edit\|Write\|Bash` | `rules-enforcer.sh` | **Block destructive commands** (`rm -rf /`, fork bombs, `curl\|bash`, secrets…) — runs first |
| `PreToolUse` | `Edit\|Write\|Bash` | `guardian-checkpoint.sh` | Story-context guard |
| `PreToolUse` | `Edit\|Write\|Bash` | `sentinel-pre.sh` | Check error history |
| `PreToolUse` | `Bash` | `supply-chain-guard.sh` | Screen package installs |
| `PostToolUse` | `Edit\|Write\|Bash` | `sentinel-post.sh` | Record result / learn patterns |
| `PostToolUse` | `Bash\|WebFetch\|WebSearch` | `llm-output-sanitizer.sh` | Sanitize external output |

If you installed with `--no-hooks` and want to enable them later, re-run
`npx harmony-ai --full --force`, or add the block manually to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/aria-detect.sh" }
        ]
      },
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/rules-enforcer.sh" },
          { "type": "command", "command": "bash .harmony/hooks/guardian-checkpoint.sh" },
          { "type": "command", "command": "bash .harmony/hooks/sentinel-pre.sh" }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/supply-chain-guard.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/sentinel-post.sh" }
        ]
      },
      {
        "matcher": "Bash|WebFetch|WebSearch",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/llm-output-sanitizer.sh" }
        ]
      }
    ]
  }
}
```

#### For Cursor

Add to `.cursor/settings.json`:

```json
{
  "harmony": {
    "enabled": true,
    "configPath": ".harmony"
  }
}
```

#### For Windsurf

Add to `.windsurf/config.json`:

```json
{
  "extensions": {
    "harmony": {
      "path": ".harmony"
    }
  }
}
```

### 2. Add to Your CLAUDE.md (or AI instructions)

Add the following to your project's AI instruction file:

```markdown
## Harmony Framework

This project uses the Harmony Framework for structured AI development.

### Guardian Protocol (Always Active)

Before any action, check:
1. What is the user's intent?
2. Consult `.harmony/config/intent-router.json`
3. Verify prerequisites in `${MEMORY_DIR}/workflow-state.json`
4. Route to the appropriate agent

> **Note**: Memory files are stored in IDE-specific locations:
> - Claude Code: `.harmony/local/memory/`
> - Cursor: `.cursor/harmony-memory/`
> - See `.harmony/config/paths.json` for configured path

### Sentinel System (Always Active)

Before risky operations:
1. Check `${MEMORY_DIR}/error-journal.json` for past errors
2. Check `${MEMORY_DIR}/circuit-breaker.json` state
3. Apply learned patterns from `${MEMORY_DIR}/learned-patterns.json`

### HQVF Quality (Phase 4)

Before development:
1. Story must exist
2. UCV must be approved
3. Mark verifications as you implement
```

---

## Directory Structure

After installation, your project will have:

```
your-project/
├── .harmony/                    # CORE FRAMEWORK (Read-Only, Shareable)
│   ├── agents/
│   │   ├── guardian.md
│   │   ├── sentinel.md
│   │   ├── analyst.md
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   ├── ai-architect.md
│   │   ├── exploratory-qa.md
│   │   ├── ucv-writer.md
│   │   ├── ucv-validator.md
│   │   ├── ucv-qa.md
│   │   ├── security.md
│   │   ├── rgpd.md
│   │   ├── accessibility.md
│   │   └── pentest.md
│   ├── patterns/
│   │   ├── P-XXX-*.md           # System patterns
│   │   └── cognitive/           # Reasoning patterns
│   │       ├── react.md
│   │       └── reflection.md
│   ├── config/
│   │   ├── harmony.config.js
│   │   ├── intent-router.json
│   │   └── paths.json           # IDE-specific paths configuration
│   ├── docs/
│   │   └── ...
│   ├── hooks/
│   │   ├── guardian-checkpoint.sh
│   │   ├── sentinel-pre.sh
│   │   └── sentinel-post.sh
│   ├── memory/
│   │   └── templates/           # Memory file templates only
│   ├── patterns/
│   │   └── ...
│   ├── rules/
│   │   └── ...
│   ├── templates/
│   │   ├── story.md
│   │   ├── ucv.md
│   │   ├── adr.md
│   │   └── handoff.md
│   └── workflows/
│       └── ...
│
│   └── local/                   # PROJECT DATA (mutable, not read-only)
│       └── memory/              # IDE-specific memory location (Claude Code)
│           ├── error-journal.json
│           ├── circuit-breaker.json
│           ├── workflow-state.json
│           ├── working.json
│           └── learned-patterns.json
│
├── .claude/                     # IDE config (Claude Code)
│   └── settings.json            # Hooks configuration (written by --full)
│
├── docs/
│   └── backlog/
│       ├── epics/
│       └── stories/
└── package.json
```

> **Architecture Note**: Core framework (`.harmony/`) is read-only and can be shared/committed.
> Project-specific memory goes in IDE-specific locations (`.harmony/local/memory/` for Claude Code).

---

## Configuration

### Basic Configuration

Create or edit `.harmony/config/harmony.config.js`:

```javascript
module.exports = {
  // Project settings
  project: {
    name: 'my-awesome-project',
    language: 'en',        // 'en' | 'fr'
    timezone: 'UTC',
  },

  // Phase settings
  workflow: {
    currentPhase: 1,       // 1-5
    autoAdvance: false,    // Auto-advance phases when gates pass
  },

  // Guardian Protocol
  guardian: {
    enabled: true,
    mode: 'warn',          // 'warn' | 'block'
    requireStory: true,    // Require story before coding
    requireUcv: true,      // Require UCV before coding
  },

  // Sentinel System
  sentinel: {
    enabled: true,
    errorMemory: true,
    circuitBreaker: {
      enabled: true,
      maxFailures: 3,
      cooldownMinutes: 5,
      autoReset: false,
    },
    patternLearning: true,
  },

  // HQVF Quality
  hqvf: {
    enabled: true,
    requireApproval: true,
    coverageTarget: 100,   // Percentage
    validators: ['dev', 'test', 'qa'],
  },

  // Memory (path is auto-configured per IDE, see .harmony/config/paths.json)
  memory: {
    // path: auto-detected based on IDE (Claude: .harmony/local/memory/, Cursor: .cursor/harmony-memory/)
    compress: true,
    retention: {
      errors: 90,          // Days to keep errors
      patterns: -1,        // -1 = forever
      sessions: 7,         // Days to keep session data
    },
  },

  // Agents
  agents: {
    core: ['guardian', 'sentinel', 'analyst', 'architect', 'developer', 'tester'],
    specialists: ['ai-architect', 'exploratory-qa', 'ucv-writer', 'ucv-validator'],
    compliance: ['security', 'rgpd', 'accessibility', 'pentest'],
    custom: [],            // Add your custom agents here
  },
};
```

---

## Verification

The installer prints a system check and a success summary at the end of the run. To
verify after the fact, confirm the framework tree and hooks exist:

```bash
# Core framework installed (read-only)
ls .harmony/agents .harmony/hooks .harmony/local/memory

# Hooks wired into Claude Code (only with --full)
cat .claude/settings.json
```

Then, inside your AI assistant, run the live health checks:

```bash
/go                 # Session kickoff — loads context and reports state
/harmony            # Interactive menu (30 commands)
/harmony quick      # Fast validation (~30s)
```

> There is no `npx harmony doctor` / `npx harmony test` CLI. Verification and day-to-day
> operation happen through slash commands inside the assistant.

---

## Uninstallation

```bash
# Remove the framework and its project data
rm -rf .harmony

# Remove the hooks Harmony added to Claude Code
#   (restore a backup if the installer made one, otherwise delete the file)
rm -f .claude/settings.json
mv .claude/settings.json.backup .claude/settings.json 2>/dev/null || true
```

> Harmony is installed *into* the project by `npx`; nothing is added to your
> `package.json` dependencies, so there is no `npm uninstall` step.

---

## Upgrading

```bash
# Reinstall the latest version over the existing one
npx harmony-ai@latest --full --force
```

`--force` overwrites the read-only framework files while preserving your project data
in `.harmony/local/memory/` (existing JSON memory is detected and kept).

---

## Troubleshooting

### `jq`/`yq` not found — installation aborts

Install the prerequisites (see top of this guide) and confirm they are on your PATH:

```bash
jq --version && yq --version
```

### Checksum verification failed

The framework verifies file integrity at install time. If it reports a checksum
mismatch, the download/clone is incomplete or corrupted — re-run the install, or for a
clone do `git pull` to refresh, then retry with `--force`.

### Hooks not triggering

1. Make sure you installed with `--full` (not `--minimal` / `--no-hooks`).
2. Verify hooks are executable:
   ```bash
   chmod +x .harmony/hooks/*.sh
   ```
3. Check that `.claude/settings.json` is valid JSON and contains the hook entries.
4. Restart your AI assistant so it reloads settings.

### Memory files corrupted

```bash
# Remove the runtime memory; it is re-initialized from templates on next /go
rm -rf .harmony/local/memory
```

---

## Next Steps

- [Getting Started](getting-started.md) - Your first workflow
- [Core Concepts](concepts.md) - Understand Harmony's architecture
- [Agents Guide](../agents/INDEX.md) - Configure agents

