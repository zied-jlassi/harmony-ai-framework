# TS-{XXX}: [{LAYER}] {title}

> **{summary}**
>
> **Layer**: `[FE]` Frontend | `[BE]` Backend | `[DB]` Database | `[DO]` DevOps | `[TEST]` Tests

---

## Metadata

| Field | Value |
|-------|-------|
| **Task ID** | TS-{XXX} |
| **Layer** | {LAYER} - [FE] \| [BE] \| [DB] \| [DO] \| [TEST] |
| **Story** | [US-{story_id}](../stories/US-{story_id}.md) |
| **Epic** | [EP-{epic_id}](../epics/EP-{epic_id}.md) |
| **Status** | TODO \| IN_PROGRESS \| BLOCKED \| DONE |
| **Assignee** | {agent_name} |
| **Estimated** | {hours}h |
| **Actual** | -h |

---

## Description

{detailed_description}

---

## Acceptance Criteria

- [ ] {criterion_1}
- [ ] {criterion_2}
- [ ] {criterion_3}

---

## Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `{path/to/file1}` | CREATE | {description} |
| `{path/to/file2}` | MODIFY | {description} |
| `{path/to/file3}` | DELETE | {description} |

---

## Implementation

### Approach

{implementation_approach}

### Code Structure

```{language}
// Example implementation
{code_example}
```

### Database Changes (if applicable)

```sql
-- Migration example
{sql_changes}
```

---

## Dependencies

### Blocked By

| Task | Status | ETA |
|------|--------|-----|
| TS-{blocking_id} | {status} | {eta} |

### Blocks

| Task | Description |
|------|-------------|
| TS-{blocked_id} | {description} |

---

## Testing

### Unit Tests

- [ ] `{test_file_1}.spec.ts` - {test_description}
- [ ] `{test_file_2}.spec.ts` - {test_description}

### Manual Testing Steps

1. {step_1}
2. {step_2}
3. {step_3}

---

## UCV Mapping

| UCV ID | Description | Status |
|--------|-------------|--------|
| V-{ucv_1} | {ucv_desc} | TODO |
| V-{ucv_2} | {ucv_desc} | TODO |

---

## Completion Checklist

- [ ] Code implemented
- [ ] Build passing
- [ ] Tests written and passing
- [ ] UCV criteria marked
- [ ] Code reviewed
- [ ] Documentation updated

---

## Notes & Decisions

| Date | Note |
|------|------|
| {YYYY-MM-DD} | {note} |

---

## Related

- Story: [US-{story_id}](../stories/US-{story_id}.md)
- Epic: [EP-{epic_id}](../epics/EP-{epic_id}.md)
- UCV: [US-{story_id}-UCV](../stories/US-{story_id}-UCV.md)
