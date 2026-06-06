---
name: "/hf:agent:backlog"
description: "Backlog dashboard - visualization, kanban, priorities"
context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Task
  - Write
hooks:
  PreToolUse:
    - matcher: "Edit|Bash"
      command: "echo '[Harmony] Orchestration: use Task for delegation' && exit 1"
---
Read `${HARMONY_DIR}/agents/backlog.md`
Args: $ARGUMENTS
