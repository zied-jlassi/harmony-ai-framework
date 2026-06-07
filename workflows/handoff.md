# Workflow: Session Handoff

> **Preserve context for session continuity.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-HANDOFF |
| **Phase** | Any |
| **Agent** | Any (typically current active agent) |
| **Trigger** | Session end, context limits, user request |

---

## Purpose

The Handoff workflow ensures:
- No work is lost between sessions
- Context is preserved for resumption
- Next steps are clear
- State is properly saved

---

## Trigger

```yaml
triggers:
  - command: "create handoff"
  - command: "save session"
  - event: "context_limit_approaching"
  - event: "session_ending"
  - event: "user_requests_break"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    HANDOFF WORKFLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TRIGGER: Session ending or context limit                       │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Assess Current State        │                       │
│  │ • Current task status                │                       │
│  │ • Open todos                         │                       │
│  │ • Modified files                     │                       │
│  │ • Pending decisions                  │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Document Accomplishments    │                       │
│  │ • Completed tasks                    │                       │
│  │ • Commits made                       │                       │
│  │ • Decisions finalized                │                       │
│  │ • Problems solved                    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Document In-Progress Work   │                       │
│  │ • Current task details               │                       │
│  │ • Progress percentage                │                       │
│  │ • Partially modified files           │                       │
│  │ • Current approach                   │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: Capture Critical Context    │                       │
│  │ • Patterns discovered                │                       │
│  │ • Blockers found                     │                       │
│  │ • Decisions made                     │                       │
│  │ • Errors resolved                    │                       │
│  │ • Open questions                     │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: Define Next Steps           │                       │
│  │ • Immediate actions                  │                       │
│  │ • Follow-up tasks                    │                       │
│  │ • Resumption instructions            │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 6: Save Memory State           │                       │
│  │ • Update workflow-state.json         │                       │
│  │ • Save error journal                 │                       │
│  │ • Update learned patterns            │                       │
│  │ • Save circuit breaker state         │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 7: Create Handoff Document     │                       │
│  │ • Use handoff template               │                       │
│  │ • Include all sections               │                       │
│  │ • Save to memory directory           │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  HANDOFF COMPLETE - Ready for resumption                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Assess Current State

**Gather:**
- Current phase
- Active story (if any)
- Todo list status
- Modified files (uncommitted)
- Circuit breaker state

**Questions:**
- What was I doing?
- How far did I get?
- What's still pending?

---

### Step 2: Document Accomplishments

**Capture:**
- Tasks marked complete
- Files created/modified/deleted
- Commits made
- Decisions finalized
- Problems solved

**Format:**
```markdown
## Accomplished

### Completed Tasks
- [x] Task 1 completed
- [x] Task 2 completed

### Files Modified
| File | Change | Description |
|------|--------|-------------|
| `path/file.ts` | Added | New service |

### Commits Made
| Hash | Message |
|------|---------|
| `abc123` | feat: Add user service |
```

---

### Step 3: Document In-Progress Work

**Capture:**
- Current task description
- Progress percentage
- Current approach/strategy
- Partial work location

**Format:**
```markdown
## In Progress

### Current Task
**Title:** Implement user authentication

- Status: 60% complete
- Approach: Using JWT with refresh tokens
- Next step: Add token refresh endpoint

### Partially Modified Files
| File | Status | Notes |
|------|--------|-------|
| `auth.ts` | 80% done | Missing error handling |
```

---

### Step 4: Capture Critical Context

**Capture:**
- New patterns discovered
- Blockers encountered
- Key decisions made
- Errors resolved (and solutions)
- Open questions needing answers

**Format:**
```markdown
## Critical Context

### Patterns Discovered
- **API Response Pattern**: All endpoints return `{ data, error }`

### Blockers Found
| Blocker | Impact | Resolution |
|---------|--------|------------|
| Missing env var | Can't test auth | Add to .env |

### Decisions Made
| Decision | Rationale |
|----------|-----------|
| Use Prisma | Team familiarity |

### Errors Resolved
| Error | Solution | Pattern |
|-------|----------|---------|
| Import error | Add @ alias | P-LEARN-001 |
```

---

### Step 5: Define Next Steps

**Capture:**
- Immediate actions (must do first)
- Follow-up tasks (normal priority)
- Backlog items (lower priority)
- Commands to run on resumption

**Format:**
```markdown
## Next Steps

### Immediate (High Priority)
1. Complete token refresh endpoint
2. Add error handling to auth.ts

### Follow-up (Normal Priority)
1. Add unit tests for auth service
2. Update API documentation

### Resumption Commands
```bash
cd /project/path
npm run test:watch
```
```

---

### Step 6: Save Memory State

**Update Files:**

1. **workflow-state.json:**
```json
{
  "current_phase": 4,
  "active_story": "STORY-042",
  "session": {
    "id": "session-xxx",
    "last_activity": "2025-01-15T10:30:00Z"
  }
}
```

2. **error-journal.json:** Add any new errors

3. **learned-patterns.json:** Add any new patterns

4. **circuit-breaker.json:** Save current state

---

### Step 7: Create Handoff Document

**Template:** `templates/handoff.md`

**Location:** `${MEMORY_DIR}/session-handoff.md` (e.g., `.harmony/local/memory/`)

**Also save dated version:** `${MEMORY_DIR}/handoffs/YYYY-MM-DD-HHMMSS.md`

---

## Resumption Process

When resuming a session:

1. **Read handoff document:**
   ```bash
   # Use your IDE's memory path (configured in .harmony/config/paths.json)
   cat .harmony/local/memory/session-handoff.md  # Claude Code example
   ```

2. **Check memory state:**
   ```bash
   cat .harmony/local/memory/workflow-state.json   # Claude Code example
   cat .harmony/local/memory/circuit-breaker.json
   ```

3. **Review in-progress files:**
   Listed in handoff document

4. **Continue with next steps:**
   Defined in handoff document

---

## Automatic Triggers

The system should create handoffs automatically when:

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Context usage | > 80% | Warn, offer handoff |
| Session duration | > 4 hours | Suggest handoff |
| Task completion | Significant milestone | Offer handoff |
| Error streak | 3+ consecutive | Force handoff |

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| Handoff Document | `${MEMORY_DIR}/session-handoff.md` | Required |
| Dated Archive | `${MEMORY_DIR}/handoffs/YYYY-MM-DD.md` | Required |
| Updated Memory | `${MEMORY_DIR}/*.json` | Required |

---

## Success Criteria

- [ ] All accomplishments documented
- [ ] In-progress work clearly described
- [ ] Critical context captured
- [ ] Next steps defined
- [ ] Memory state saved
- [ ] Handoff document created

---

## Related

- [Handoff Template](../templates/handoff.md)
- [P-002: Three-Tier Memory](../patterns/P-002-three-tier-memory.md)
- [Sentinel Agent](../agents/sentinel.md)

