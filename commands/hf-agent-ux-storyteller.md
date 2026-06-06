---
name: "/hf:agent:ux-storyteller"
description: "UX storyteller - user journeys, narratives"
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
Read `${HARMONY_DIR}/specialties/creative/branchs/ux-storyteller.md`
Args: $ARGUMENTS
