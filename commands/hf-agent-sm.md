---
name: "/hf:agent:sm"
description: "Scrum Master - stories, sprints, planning, INVEST"
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
Read `${HARMONY_DIR}/agents/scrum-master.md`
Args: $ARGUMENTS
