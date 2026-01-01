# Session Handoff - {date}

> **Context preservation for session continuity.**

---

## Session Info

| Field | Value |
|-------|-------|
| **Date** | {date} |
| **Session ID** | {session_id} |
| **Duration** | {duration} |
| **Agent** | {agent_name} |
| **Phase** | Phase {phase} - {phase_name} |

---

## Accomplished

### Completed Tasks

- [x] {completed_task_1}
- [x] {completed_task_2}
- [x] {completed_task_3}

### Files Modified

| File | Change Type | Description |
|------|-------------|-------------|
| `{file_1}` | {change_type_1} | {change_desc_1} |
| `{file_2}` | {change_type_2} | {change_desc_2} |

### Commits Made

| Hash | Message |
|------|---------|
| `{commit_1_hash}` | {commit_1_message} |
| `{commit_2_hash}` | {commit_2_message} |

---

## In Progress

### Current Task

**{current_task_title}**

- Status: {current_task_status}
- Progress: {current_task_progress}%
- Next step: {current_task_next_step}

### Partially Modified Files

| File | Status | Notes |
|------|--------|-------|
| `{partial_file_1}` | {partial_status_1} | {partial_notes_1} |

---

## Next Steps

### Immediate (High Priority)

1. {immediate_step_1}
2. {immediate_step_2}

### Follow-up (Normal Priority)

1. {followup_step_1}
2. {followup_step_2}

### Backlog (Low Priority)

1. {backlog_step_1}

---

## Critical Context

### Patterns Discovered

- **{pattern_1_name}**: {pattern_1_desc}
- **{pattern_2_name}**: {pattern_2_desc}

### Blockers Found

| Blocker | Impact | Resolution |
|---------|--------|------------|
| {blocker_1} | {blocker_1_impact} | {blocker_1_resolution} |

### Decisions Made

| Decision | Rationale | Reference |
|----------|-----------|-----------|
| {decision_1} | {decision_1_rationale} | {decision_1_ref} |
| {decision_2} | {decision_2_rationale} | {decision_2_ref} |

### Errors Resolved

| Error | Solution | Pattern Created |
|-------|----------|-----------------|
| {error_1} | {error_1_solution} | {error_1_pattern} |

---

## Relevant Files

### Key Implementation Files

- `{key_file_1}` - {key_file_1_desc}
- `{key_file_2}` - {key_file_2_desc}

### Test Files

- `{test_file_1}` - {test_file_1_desc}

### Documentation

- `{doc_file_1}` - {doc_file_1_desc}

---

## Memory State

### Active Story

```json
{
  "story_id": "{active_story_id}",
  "title": "{active_story_title}",
  "status": "{active_story_status}",
  "ucv_coverage": {
    "dev": {dev_coverage}%,
    "test": {test_coverage}%,
    "qa": {qa_coverage}%
  }
}
```

### Circuit Breaker

```json
{
  "state": "{circuit_state}",
  "consecutive_failures": {consecutive_failures},
  "last_operation": "{last_operation}"
}
```

### Open Questions

- {open_question_1}
- {open_question_2}

---

## Resumption Instructions

### To Resume This Work

1. Read this handoff document
2. Check the memory state files:
   - `${MEMORY_DIR}/workflow-state.json`
   - `${MEMORY_DIR}/error-journal.json`
3. Review in-progress files listed above
4. Continue with "Immediate" next steps

### Commands to Run First

```bash
{resume_command_1}
{resume_command_2}
```

---

## Related

- Story: [STORY-{story_id}](../backlog/stories/STORY-{story_id}.md)
- Previous Handoff: [{previous_handoff_date}](./{previous_handoff_file})

