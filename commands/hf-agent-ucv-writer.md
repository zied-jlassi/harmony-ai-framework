---
name: "/hf:agent:ucv-writer"
description: "UCV Writer - creates Use Case Verifiables"
context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      command: "echo '[Harmony] Compliance agent: read-only mode' && exit 1"
---
Read `${HARMONY_DIR}/specialties/ucv/branchs/writer.md`
Args: $ARGUMENTS
