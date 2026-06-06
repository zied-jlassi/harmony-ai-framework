---
name: "/hf:agent:ucv-validator"
description: "UCV Validator - validates 100% UCV coverage"
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
Read `${HARMONY_DIR}/specialties/ucv/branchs/validator.md`
Args: $ARGUMENTS
