---
name: "/hf:agent:security-engineer"
description: "Security engineer - secure coding, hardening"
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
Read `${HARMONY_DIR}/specialties/security/branchs/engineer.md`
Args: $ARGUMENTS
