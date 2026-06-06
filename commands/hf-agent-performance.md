---
name: "/hf:agent:performance"
description: "Performance auditor - optimization, benchmarks, profiling"
context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebFetch
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      command: "echo '[Harmony] Quality agent: analysis only' && exit 1"
---
Read `${HARMONY_DIR}/specialties/quality/branchs/performance.md`
Args: $ARGUMENTS
