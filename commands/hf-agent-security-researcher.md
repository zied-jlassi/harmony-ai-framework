---
name: "/hf:agent:security-researcher"
description: "Security researcher - threat analysis, CVE research"
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
Read `${HARMONY_DIR}/specialties/security/branchs/researcher.md`
Args: $ARGUMENTS
