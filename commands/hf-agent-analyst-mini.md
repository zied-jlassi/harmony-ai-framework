---
name: "/hf:agent:analyst-mini"
description: "Lightweight analyst - quick clarification for unclear requests"
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
Read `${HARMONY_DIR}/agents/analyst-mini.md`
Args: $ARGUMENTS
