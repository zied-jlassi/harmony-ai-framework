# Working Memory - Sprint & Backlog Tracking

> **🌐 Language:** English · [Français](fr/working-memory.md)

> **AI-Agnostic**: Works with Claude, Cursor, Windsurf, Cody, Continue, or any AI assistant.

The Working Memory system provides persistent sprint and backlog tracking that survives session crashes and enables seamless context handoff between sessions.

## Memory Location (IDE-Specific)

Memory files are stored in **IDE-specific locations**, NOT in `.harmony/`:

| IDE | Memory Location |
|-----|-----------------|
| Claude Code | `.harmony/local/memory/` |
| Cursor | `.cursor/harmony-memory/` |
| Windsurf | `.windsurf/harmony-memory/` |
| Continue | `.continue/harmony-memory/` |
| Cody | `.cody/harmony-memory/` |
| Generic | `.harmony-local/memory/` |

> **Why?** Core framework (`.harmony/`) stays read-only and shareable. Project-specific data stays local.

The path is configured in `.harmony/config/paths.json` during installation.

## Overview

```
+-------------------------------------------------------------------+
|                    WORKING MEMORY SYSTEM                            |
+-------------------------------------------------------------------+
|                                                                   |
|  ${MEMORY_DIR}/working.json       ← Central state file           |
|  ${MEMORY_DIR}/.action-log.jsonl  ← Action journal               |
|  ${MEMORY_DIR}/.checkpoint.json   ← Crash recovery               |
|  ${MEMORY_DIR}/.backups/          ← Automatic backups            |
|                                                                   |
|  .harmony/lib/sprint-tracker.sh   ← CRUD operations              |
|  .harmony/lib/recovery.sh         ← Crash recovery               |
|                                                                   |
|  Example (Claude Code):                                           |
|  .harmony/local/memory/working.json                                      |
|  .harmony/local/memory/.action-log.jsonl                                 |
+-------------------------------------------------------------------+
```

## Why Working Memory?

### The Problem

Without persistent state:
- AI loses context when session ends or crashes
- User must re-explain sprint status, current story, blockers
- Risk of duplicate work or forgotten tasks
- No velocity tracking across sprints

### The Solution

With Working Memory:
- State persists across sessions
- AI reads `working.json` at session start → knows exactly where to resume
- Automatic backups every 5 actions
- Action log enables crash recovery

## Quick Start

### 1. Initialize Working Memory

```bash
# From your project root
source .harmony/lib/sprint-tracker.sh
init_working_memory "My Project"
```

### 2. Start a Sprint

```bash
start_sprint "SPRINT-001" "MVP Sprint" 30 "Deliver core features"
```

### 3. Work on Stories

```bash
start_story "STORY-001" "User login" 5 "EPIC-AUTH"
# ... do work ...
complete_story
```

### 4. View Dashboard

```bash
show_sprint_dashboard
```

## File Structure

### working.json

```json
{
  "version": "2.0.0",
  "type": "working_memory",
  "created": "2025-01-01",
  "last_updated": "2025-01-01T14:30:00+00:00",

  "project": {
    "name": "My Project",
    "language": "en"
  },

  "current_sprint": {
    "id": "SPRINT-001",
    "name": "MVP Sprint",
    "started": "2025-01-01",
    "status": "IN_PROGRESS",
    "velocity_target": 30,
    "velocity_achieved": 15,
    "sprint_goal": "Deliver core features",
    "stories": ["STORY-001", "STORY-002"],
    "blockers": []
  },

  "current_story": {
    "id": "STORY-002",
    "title": "User registration",
    "status": "IN_PROGRESS",
    "points": 5,
    "tasks_completed": 2,
    "tasks_total": 4
  },

  "velocity": {
    "average_3_sprints": 25,
    "trend": "improving",
    "recommended_capacity": 28
  },

  "blockers": [],

  "recent_decisions": [
    {
      "date": "2025-01-01",
      "decision": "Use JWT for authentication",
      "reason": "Stateless, scalable"
    }
  ],

  "next_steps": [
    "Complete STORY-002 tasks 3-4",
    "Start STORY-003"
  ]
}
```

## Sprint Tracker Library

### Sprint Operations

```bash
source .harmony/lib/sprint-tracker.sh

# Start new sprint
start_sprint "SPRINT-ID" "Sprint Name" target_velocity "Sprint Goal"

# Complete current sprint (moves to history)
complete_sprint

# Add axis to sprint (for multi-epic sprints)
add_sprint_axis "A_Backend" "EPIC-001" 20 "Backend implementation"

# Update axis status
update_axis_status "A_Backend" "DONE"

# Add velocity points
add_velocity 15
```

### Story Operations

```bash
# Start working on a story
start_story "STORY-001" "Story Title" 5 "EPIC-001" "Developer"

# Update progress
update_story_progress 3 5  # 3 of 5 tasks done

# Update UCV status
update_ucv_status "APPROVED"

# Complete story (adds points to velocity)
complete_story
```

### Blocker Operations

```bash
# Add a blocker
add_blocker "BLK-001" "API not ready" "STORY-001" "high" "DevOps"

# Resolve a blocker
resolve_blocker "BLK-001"

# View open blockers
get_blockers
```

### Decision & Next Steps

```bash
# Record a decision
add_decision "Use Redis for caching" "Better performance" "Architect"

# Add next step
add_next_step "Finalize API contract"

# Remove completed step
remove_next_step "Finalize API contract"

# View recent decisions
get_recent_decisions
```

### Getters

```bash
get_current_sprint    # Sprint info
get_current_story     # Story info
get_velocity          # Velocity stats
get_backlog_summary   # Backlog counts
get_blockers          # Open blockers
get_next_steps        # Pending next steps
```

### Display

```bash
# Full dashboard
show_sprint_dashboard

# Export for AI consumption (JSON)
export_for_ai
```

## Recovery System

### Automatic Recovery

The recovery system handles crashes gracefully:

1. **Checkpoints**: Before each action, state is saved
2. **Action Log**: Every action is logged to `.action-log.jsonl`
3. **Backups**: Automatic backup every 5 actions
4. **Recovery**: On session start, incomplete actions are detected

### Using Recovery

```bash
source .harmony/lib/recovery.sh

# Check state at session start
recover_state

# If issues found:
fix_state              # Auto-fix common issues
list_backups           # Show available backups
restore_backup "file"  # Restore from backup

# View action history
show_action_log 20     # Last 20 actions

# Manual backup
create_backup "manual" "Before major refactor"
```

### Crash Detection

When you start a session, `recover_state` checks:

1. Is `working.json` valid JSON?
2. Is there an incomplete checkpoint (`_checkpoint.pending_action`)?
3. Are there state inconsistencies?

If issues are found, you'll see recovery options.

## AI Integration

### For AI Assistants

At the start of each session, the AI should:

1. **Read** `${MEMORY_DIR}/working.json` (e.g., `.harmony/local/memory/working.json`)
2. **Check** for incomplete actions
3. **Display** current state summary
4. **Continue** from where the last session left off

### Example AI Workflow

```markdown
# Session Start

AI reads working.json and says:

"I see you're in Sprint SPRINT-005 (15/30 pts achieved).
Current story: STORY-042 (3/5 tasks done).
Open blockers: None.
Next steps:
- Finish task 4/5 of STORY-042
- Run E2E tests

Shall I continue with the current story?"
```

### After Each Action

AI should update `working.json`:

```python
# Pseudo-code
after_action = lambda action: {
    update_working_json(action.changes),
    log_action(action.description),
    maybe_create_backup()
}
```

## Best Practices

### 1. Always Update working.json

After any significant action:
- Story created/started/completed
- Sprint started/completed
- Blocker added/resolved
- Decision made

### 2. Use next_steps for Continuity

Before ending a session:
```bash
add_next_step "Continue implementing validation"
add_next_step "Review PR #123"
```

### 3. Regular Backups

For critical milestones:
```bash
create_backup "manual" "Sprint 5 complete"
```

### 4. Check State on Start

Always run at session start:
```bash
recover_state
show_sprint_dashboard
```

## Configuration

### Override Defaults

In `.harmony/config/overrides.yaml`:

```yaml
working_memory:
  backup_interval: 5      # Actions between backups
  max_backups: 10         # Keep last N backups
  auto_recovery: true     # Auto-recover on start
```

## Troubleshooting

### Corrupted working.json

```bash
# Check if valid JSON (use your IDE's memory path)
jq empty .harmony/local/memory/working.json  # Claude Code example

# If corrupted, recover from backup
list_backups
restore_backup "working_20250101_120000_auto.json"
```

### Missing State

```bash
# Re-initialize
init_working_memory "Project Name"

# Or reset with backup
reset_working_memory "Project Name"
```

### Inconsistent State

```bash
# Auto-fix common issues
fix_state

# Or view action log to understand what happened
show_action_log 50
```

## Related Documentation

- [Scrum Master Agent](../agents/scrum-master.md) - Uses Working Memory
- [Overrides](./overrides.md) - Configuration options
