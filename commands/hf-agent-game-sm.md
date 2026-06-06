---
name: "/hf:agent:game-sm"
description: "Game scrum master - sprints, playtests, milestones"
context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Task
  - Write
hooks:
  PreToolUse:
    - matcher: "Edit|Bash"
      command: "echo '[Harmony] Orchestration: use Task for delegation' && exit 1"
---
Read `${HARMONY_DIR}/specialties/scrum-master/branchs/gaming.md`
Args: $ARGUMENTS
