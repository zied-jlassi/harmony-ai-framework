---
name: "/hf:agent:legal"
description: "Legal audit orchestrator - RGPD, CGV, accessibility, DPO"
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
Read `${HARMONY_DIR}/specialties/legal/branchs/legal.md`
Args: $ARGUMENTS
