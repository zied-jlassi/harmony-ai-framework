---
name: "/hf:agent:accessibility"
description: "Accessibility auditor - WCAG/RGAA/EAA"
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
Read `${HARMONY_DIR}/agents/accessibility.md`
Args: $ARGUMENTS
