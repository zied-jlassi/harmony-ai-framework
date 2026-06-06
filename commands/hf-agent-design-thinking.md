---
name: "/hf:agent:design-thinking"
description: "Design thinking lead - user-centered innovation"
context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - WebSearch
hooks:
  PreToolUse:
    - matcher: "Edit|Bash"
      command: "echo '[Harmony] Creative agent: create new, dont modify' && exit 1"
---
Read `${HARMONY_DIR}/specialties/creative/branchs/design-thinking-lead.md`
Args: $ARGUMENTS
