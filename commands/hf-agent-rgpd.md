---
name: "/hf:agent:rgpd"
description: "RGPD/GDPR compliance auditor"
context: fork
agent: opus
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
Read `${HARMONY_DIR}/agents/rgpd.md`
Args: $ARGUMENTS
