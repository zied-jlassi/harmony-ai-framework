---
name: "/hf:agent:narrative"
description: "Narrative designer - game storytelling"
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
Read `${HARMONY_DIR}/agents/narrative-designer.md`
Args: $ARGUMENTS
