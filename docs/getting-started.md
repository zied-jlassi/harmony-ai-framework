# Getting Started with Harmony

> **🌐 Language:** English · [Français](fr/getting-started.md)

Welcome to Harmony Framework! This guide will help you get up and running in minutes.

## Prerequisites

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| **Node.js 18+** | Runtime for npx | [nodejs.org](https://nodejs.org/) |
| **jq** | JSON processing | `sudo apt install jq` / `brew install jq` |
| **yq** | YAML processing | `sudo apt install yq` / `brew install yq` |
| **Git** | Version control | Pre-installed on most systems |

### Required MCP Servers (Official Anthropic)

Harmony Framework requires these official MCP servers for cross-session learning and structured reasoning:

| MCP Server | Package | Purpose |
|------------|---------|---------|
| **server-memory** | `@modelcontextprotocol/server-memory` | Cross-session memory, Sentinel error patterns |
| **server-sequentialthinking** | `@modelcontextprotocol/server-sequentialthinking` | Structured problem decomposition |

**MCP Client configuration** (Claude Desktop / Cursor / VS Code):

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]
    }
  }
}
```

### Optional

- **AI Assistant**: Claude Code, Cursor, Windsurf, or similar
- **Docker** (for containerized development)

## Quick Start

### Step 1: Install Harmony

```bash
# Create a new project or navigate to an existing one
mkdir my-project && cd my-project

# Install Harmony into the project (one command, no separate init)
npx harmony-ai --full
```

### Step 2: What `--full` sets up

The installer is non-interactive (it uses sensible defaults). It:

- creates `.harmony/` (the read-only framework core) in your project;
- wires the 7 Claude Code hooks into `.claude/settings.json`;
- seeds project memory in `.harmony/local/memory/`;
- prints a system check and a success summary.

Guardian, Sentinel and HQVF are enabled by default; the project starts in
**Discovery (Phase 1)**.

### Step 3: Verify Installation

```bash
# Framework tree + hooks present
ls .harmony/agents .harmony/hooks .harmony/local/memory
cat .claude/settings.json

# Then, inside your AI assistant:
/go            # Session kickoff — loads context and reports state
```

## Your First Workflow

### 1. Start with Discovery (Phase 1)

Open your AI assistant and type naturally:

```
"analyze the requirements for a user authentication system"
```

Harmony's Guardian will:
1. Detect intent: **ANALYZE**
2. Route to: **Analyst (Analyst)**
3. Create a brief document

### 2. Move to Planning (Phase 2)

```
"create the PRD for authentication"
```

Guardian detects: **PLAN** → Routes to **PM**

### 3. Design Architecture (Phase 3)

```
"design the authentication architecture"
```

Guardian detects: **DESIGN** → Routes to **Architect**

### 4. Create Stories

```
"create stories for the login feature"
```

Guardian detects: **PLAN_STORY** → Routes to **SM**

### 5. Generate UCVs

```
"create UCVs for STORY-001"
```

Guardian detects: **CREATE_UCV** → Routes to **UCV Writer**

### 6. Implement (Phase 4)

```
"implement STORY-001"
```

Guardian:
1. Checks if story exists ✅
2. Checks if UCV is approved ✅
3. Routes to **Developer (Developer)**

## Understanding the Workflow

```
┌────────────────────────────────────────────────────────────────┐
│                    HARMONY WORKFLOW                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  You say: "develop the login feature"                          │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      GUARDIAN PROTOCOL          │                           │
│  │  ┌───────────────────────────┐  │                           │
│  │  │ 1. Detect Intent          │  │                           │
│  │  │    → IMPLEMENT            │  │                           │
│  │  │                           │  │                           │
│  │  │ 2. Check Prerequisites    │  │                           │
│  │  │    → Story exists? ✅     │  │                           │
│  │  │    → UCV approved? ✅     │  │                           │
│  │  │                           │  │                           │
│  │  │ 3. Route to Agent         │  │                           │
│  │  │    → Developer (Developer)   │  │                           │
│  │  └───────────────────────────┘  │                           │
│  └─────────────────────────────────┘                           │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      SENTINEL SYSTEM            │                           │
│  │  • Monitors for errors          │                           │
│  │  • Records in error journal     │                           │
│  │  • Triggers circuit breaker     │                           │
│  └─────────────────────────────────┘                           │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      DEVELOPMENT                │                           │
│  │  • Code implementation          │                           │
│  │  • UCV checkboxes marked        │                           │
│  │  • Tests written                │                           │
│  └─────────────────────────────────┘                           │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      QUALITY GATE               │                           │
│  │  • Exploratory QA explores               │                           │
│  │  • UCV Validator validates UCVs        │                           │
│  │  • Story marked DONE            │                           │
│  └─────────────────────────────────┘                           │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## Natural Language Commands

Harmony understands natural language. No need to memorize commands!

| You say... | Harmony understands... | Agent activated |
|------------|------------------------|-----------------|
| "develop the login" | IMPLEMENT | Developer |
| "fix the bug" | FIX | Developer |
| "create a story" | PLAN_STORY | SM |
| "test the API" | TEST | Tester |
| "explore the UI" | EXPLORE_QA | Exploratory QA |
| "analyze requirements" | ANALYZE | Analyst |
| "design architecture" | DESIGN | Architect |
| "create UCVs" | CREATE_UCV | UCV Writer |
| "validate UCVs" | VALIDATE_UCV | UCV Validator |

## Multi-language Support

Harmony understands both English and French:

```
English: "develop the scoring system"
French:  "développe le système de scoring"

Both → Intent: IMPLEMENT → Developer Agent
```

## What's Next?

- [Installation Guide](installation.md) - Detailed installation options
- [Core Concepts](concepts.md) - Deep dive into Harmony's architecture
- [Agents Guide](../agents/INDEX.md) - Learn about all available agents
- [Patterns Reference](../patterns/INDEX.md) - Design patterns library
- [Prompt Monitor](../commands/monitor.md) - Track and improve your prompts
- [Examples](examples/) - Real-world examples

### Optional: Enable Prompt Monitor

Track your interactions and learn to write better prompts:

```bash
# Install Python dependencies (one-time)
pip3 install -r .harmony/tools/prompt-monitor/requirements.txt

# Start the dashboard
harmony monitor start

# Open in browser
harmony monitor open   # → http://localhost:8080
```

---

## Troubleshooting

### "Guardian blocked my operation"

```
🛡️ GUARDIAN CHECKPOINT - VIOLATION
ATTEMPT: Code modification without active story
```

**Solution**: Create or activate a story first:
```
"create a story for [your feature]"
```

### "Circuit breaker is OPEN"

```
🛑 SENTINEL: Circuit Breaker OPEN
3 consecutive failures detected
```

**Solution**:
1. Check the error journal: `.harmony/local/memory/error-journal.json`
2. Fix the root cause
3. Reset the circuit: `/harmony sentinel --reset`

### "Agent not available for current phase"

**Solution**: Check your current phase (inside your assistant):
```
/harmony            # interactive menu / status
```

Move to the appropriate phase or use an agent allowed in your current phase.

---

<p align="center">
  <strong>Need help?</strong><br>
  Open an issue on GitHub or join our Discord community.
</p>
