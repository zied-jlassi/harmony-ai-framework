---
name: "/hf:agent:atlas"
description: "Architecture validator - clean architecture, layer boundaries"
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
Read `${HARMONY_DIR}/agents/atlas.md`
Args: $ARGUMENTS
