---
name: "/hf:agent:guardian"
description: "Workflow Protector - intent detection, routing"
context: fork
agent: haiku
allowed-tools:
  - Read
  - Grep
  - Glob
  - Task
hooks:
  PreToolUse:
    - matcher: "Write|Edit|Bash"
      command: "echo '[Harmony] System agent: monitoring only' && exit 1"
---
Read `${HARMONY_DIR}/agents/guardian.md`
Args: $ARGUMENTS
