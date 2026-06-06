---
name: "/hf:agent:ux"
description: "UX Designer - wireframes, user flows"
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
Read `${HARMONY_DIR}/agents/ux-designer.md`
Args: $ARGUMENTS
