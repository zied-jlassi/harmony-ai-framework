---
name: "/hf:agent:innovation-scout"
description: "Innovation scout - emerging tech, trends analysis"
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
Read `${HARMONY_DIR}/specialties/creative/branchs/innovation-scout.md`
Args: $ARGUMENTS
