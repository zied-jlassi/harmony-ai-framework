---
name: "/hf:agent:exploratory-qa"
description: "Exploratory QA - manual testing, UX validation"
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
Read `${HARMONY_DIR}/agents/exploratory-qa.md`
Args: $ARGUMENTS
