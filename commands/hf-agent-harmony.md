---
name: "/hf:agent:harmony"
description: "Framework coherence auditor - orphans, duplicates, manifests"
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
Read `${HARMONY_DIR}/agents/harmony.md`
Args: $ARGUMENTS
