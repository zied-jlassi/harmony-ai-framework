# Getting Started with Harmony

Welcome to Harmony Framework! This guide will help you get up and running in minutes.

## Prerequisites

- **Node.js** 18.0.0 or higher
- **AI Assistant**: Claude Code, Cursor, Windsurf, or similar
- **Git** (for version control)
- **Docker** (optional, for containerized development)

## Quick Start

### Step 1: Install Harmony

```bash
# Create a new project or navigate to existing one
mkdir my-project && cd my-project

# Install Harmony
npm install harmony-ai-framework

# Initialize Harmony in your project
npx harmony init
```

### Step 2: Choose Your Configuration

During initialization, you'll be asked:

```
? Project name: my-project
? Language: English / Français
? Enable Guardian Protocol? Yes
? Enable Sentinel System? Yes
? Enable HQVF Quality? Yes
? Starting phase: Discovery (Phase 1)
```

### Step 3: Verify Installation

```bash
npx harmony doctor
```

Expected output:
```
✅ Harmony Framework v1.0.0
✅ Configuration valid
✅ Memory system initialized
✅ Hooks installed
✅ Agents available: 6 core, 4 specialists
✅ Ready to go!
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
- [Agents Guide](agents/README.md) - Learn about all available agents
- [Patterns Reference](patterns/README.md) - Design patterns library
- [Prompt Monitor](../commands/monitor.md) - Track and improve your prompts
- [Examples](examples/README.md) - Real-world examples

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
TENTATIVE: Code modification without active story
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
1. Check the error journal: `npx harmony memory show errors`
2. Fix the root cause
3. Reset the circuit: `npx harmony sentinel reset`

### "Agent not available for current phase"

**Solution**: Check your current phase:
```
npx harmony status
```

Move to the appropriate phase or use an agent allowed in your current phase.

---

<p align="center">
  <strong>Need help?</strong><br>
  Open an issue on GitHub or join our Discord community.
</p>
