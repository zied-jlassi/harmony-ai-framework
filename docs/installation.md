# Installation Guide

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

### Method 1: NPM (Recommended)

```bash
# Install globally
npm install -g harmony-ai

# Or install locally in your project
npm install harmony-ai

# Initialize
npx harmony init
```

### Method 2: Yarn

```bash
yarn add harmony-ai
npx harmony init
```

### Method 3: PNPM

```bash
pnpm add harmony-ai
npx harmony init
```

### Method 4: Manual Installation

```bash
# Clone the repository
git clone https://github.com/zied-jlassi/harmony-ai-framework.git

# Run the installer
cd harmony-framework
./bin/install.sh /path/to/your/project
```

---

## Post-Installation Setup

### 1. Configure Your AI Assistant

#### For Claude Code

Add the hooks to your `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".harmony/hooks/rules-enforcer.sh \"$TOOL_NAME\" \"$TOOL_INPUT\"",
            "statusMessage": "🛡️ Rules: Checking interdictions..."
          },
          {
            "type": "command",
            "command": ".harmony/hooks/sentinel-pre.sh \"$TOOL_NAME\" \"$TOOL_INPUT\"",
            "statusMessage": "🛡️ Sentinel: Checking error history..."
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".harmony/hooks/guardian-checkpoint.sh \"$TOOL_NAME\" \"$TOOL_INPUT\"",
            "statusMessage": "🛡️ Guardian: Checking story context..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".harmony/hooks/sentinel-post.sh \"$TOOL_NAME\" \"$TOOL_INPUT\" \"$TOOL_OUTPUT\" \"$EXIT_CODE\"",
            "statusMessage": "🛡️ Sentinel: Recording result..."
          }
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
├── .claude/                     # PROJECT DATA (Claude Code)
│   └── memory/                  # IDE-specific memory location
│       ├── error-journal.json
│       ├── circuit-breaker.json
│       ├── workflow-state.json
│       ├── working.json
│       └── learned-patterns.json
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

### Check Installation

```bash
npx harmony doctor
```

Expected output:

```
🏥 Harmony Health Check
━━━━━━━━━━━━━━━━━━━━━━━

✅ Harmony Framework v1.0.0
✅ Node.js v20.10.0 (>=18.0.0 required)
✅ Configuration: .harmony/config/harmony.config.js
✅ Memory directory: .harmony/local/memory/  (IDE-specific)
✅ Hooks installed: 3/3
✅ Agents available: 10 core, 4 specialists, 4 compliance
✅ Patterns loaded: 8
✅ Rules loaded: 7

📊 Current State:
   Phase: 1 (Discovery)
   Circuit Breaker: CLOSED
   Error Count: 0
   Patterns Learned: 0

🎉 Harmony is ready!
```

### Test Guardian Protocol

```bash
npx harmony test guardian
```

### Test Sentinel System

```bash
npx harmony test sentinel
```

---

## Uninstallation

```bash
# Remove Harmony from project
npx harmony uninstall

# Or manually
rm -rf .harmony
npm uninstall harmony-ai
```

---

## Upgrading

```bash
# Upgrade to latest version
npm update harmony-ai

# Run migrations
npx harmony migrate
```

---

## Troubleshooting

### Installation fails with permission error

```bash
# Try with sudo (not recommended)
sudo npm install -g harmony-ai

# Better: Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
```

### Hooks not triggering

1. Verify hooks are executable:
```bash
chmod +x .harmony/hooks/*.sh
```

2. Check settings.local.json syntax
3. Restart your AI assistant

### Memory files corrupted

```bash
# Reset memory to clean state
npx harmony memory reset
```

---

## Next Steps

- [Getting Started](getting-started.md) - Your first workflow
- [Core Concepts](concepts.md) - Understand Harmony's architecture
- [Agents Guide](../agents/INDEX.md) - Configure agents

