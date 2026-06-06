---
name: "/hf:agent:ucv-qa"
description: "UCV QA - manual browser validation (HQVF)"
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
Read `${HARMONY_DIR}/specialties/ucv/branchs/qa.md`
Args: $ARGUMENTS
