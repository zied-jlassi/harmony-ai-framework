---
name: "/hf:agent:ucv"
description: "UCV Coordinator - verification workflow"
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
Read `${HARMONY_DIR}/agents/ucv.md`
Args: $ARGUMENTS
