---
name: "/hf:agent:brainstorm"
description: "Brainstorm facilitator - ideation, creative sessions"
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
Read `${HARMONY_DIR}/specialties/creative/branchs/brainstorm-facilitator.md`
Args: $ARGUMENTS
