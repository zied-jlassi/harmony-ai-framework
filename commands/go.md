---
description: "GO - Session Kickoff - Initialize session with project context"
---

# GO - Session Kickoff

Initialize a new working session with Harmony.

## Behavior

1. Check if `.harmony/harmony.manifest.json` exists
2. Read `.harmony/memory/workflow-state.json` to get current phase
3. Read `.harmony/memory/working.json` to get active story/sprint
4. Read `.harmony/memory/circuit-breaker.json` to check health
5. Display session context summary

## Output Format

### IF NEW PROJECT (harmony.manifest.json NOT FOUND)

```
🚀 Harmony Session - NEW PROJECT

📊 Status:
- Framework: ✅ Installed
- Project: ⚠️ Not configured

🎯 You're in Phase 1 - Discovery

Since this is a new project, start with:

1️⃣  Analyze Requirements (Recommended)
    → @.harmony/agents/analyst.md

2️⃣  Create Product Brief
    → /harmony workflow product-brief

3️⃣  Research First
    → /harmony workflow research

4️⃣  Skip to Init (if you know your stack)
    → /harmony init

Which would you like to start with?

💡 Quick Actions:
- /harmony quick            # Health check
- /harmony sentinel         # Sentinel Status (default): Dashboard
- /harmony sentinel --reset # Reset circuit breaker if stuck
```

### IF CONFIGURED PROJECT (harmony.manifest.json EXISTS)

```
🚀 Harmony Session Started

📊 Current State:
- Phase: [1-5] [Name]
- Active Story: [ID] or None
- Circuit Breaker: [CLOSED/OPEN]

📋 Recent Context:
- Last activity: [timestamp]
- Pending tasks: [count]

🎯 Actions for Current Phase:
- Phase 1: @.harmony/agents/analyst.md
- Phase 2: @.harmony/agents/product-manager.md
- Phase 3: @.harmony/agents/architect.md
- Phase 4: @.harmony/agents/developer.md STORY-XXX
- Phase 5: /harmony workflow incident

💡 Quick Actions:
- /harmony quick            # Health check
- /harmony sentinel         # Sentinel Status (default): Dashboard
- /harmony sentinel --reset # Reset circuit breaker if stuck
```

## Execution

Load workflow-state.json and display formatted summary.

Arguments: $ARGUMENTS
