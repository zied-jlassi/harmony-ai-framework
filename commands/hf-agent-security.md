---
name: "/hf:agent:security"
description: "Security auditor - OWASP Top 10"
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
Read `${HARMONY_DIR}/agents/security.md`
Args: $ARGUMENTS
