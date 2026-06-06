---
name: "/hf:agent:game-designer"
description: "Game designer - GDD, mechanics, core loops"
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
Read `${HARMONY_DIR}/specialties/designer/branchs/gaming.md`
Args: $ARGUMENTS
