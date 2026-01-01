---
description: "GO - Session Kickoff - Initialize session with project context"
---

# GO - Session Kickoff

Initialize a new working session with Harmony.

## Behavior

1. Read `.claude/memory/workflow-state.json` to get current phase
2. Read `.claude/memory/working.json` to get active story/sprint
3. Read `.claude/memory/circuit-breaker.json` to check health
4. Display session context summary

## Output Format

```
🚀 Harmony Session Started

📊 Current State:
- Phase: [1-5] [Name]
- Active Story: [ID] or None
- Circuit Breaker: [CLOSED/OPEN]

📋 Recent Context:
- Last activity: [timestamp]
- Pending tasks: [count]

💡 Quick Actions:
- /harmony quick            # Health check
- /harmony sentinel         # Sentinel Status (default): Dashboard
- /harmony sentinel --reset # Reset circuit breaker if stuck
```

## Execution

Load workflow-state.json and display formatted summary.

Arguments: $ARGUMENTS
