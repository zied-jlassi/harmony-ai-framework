---
name: "/hf:agent:sentinel"
description: "Memory Guardian - error learning, circuit breaker"
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
Read `${HARMONY_DIR}/agents/sentinel.md`
Args: $ARGUMENTS
