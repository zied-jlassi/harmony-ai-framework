---
name: "/hf:agent:dependency"
description: "Dependency auditor - npm audit, vulnerabilities, licenses"
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
Read `${HARMONY_DIR}/specialties/quality/branchs/dependency.md`
Args: $ARGUMENTS
