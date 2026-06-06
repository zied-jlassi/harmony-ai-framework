---
name: "/hf:agent:security-auditor"
description: "Security auditor - vulnerability assessment, compliance"
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
Read `${HARMONY_DIR}/specialties/security/branchs/auditor.md`
Args: $ARGUMENTS
