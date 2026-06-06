---
name: "/hf:agent:problem-solver"
description: "Problem solver - root cause analysis, solutions"
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
Read `${HARMONY_DIR}/specialties/creative/branchs/problem-solver.md`
Args: $ARGUMENTS
