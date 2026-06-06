---
name: "/hf:agent:security-dpo"
description: "Data Protection Officer - RGPD implementation, privacy"
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
Read `${HARMONY_DIR}/specialties/security/branchs/dpo.md`
Args: $ARGUMENTS
