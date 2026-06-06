---
name: "/hf:agent:lint"
description: "Code quality linter - ESLint, Prettier, code style"
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
Read `${HARMONY_DIR}/specialties/quality/branchs/lint.md`
Args: $ARGUMENTS
