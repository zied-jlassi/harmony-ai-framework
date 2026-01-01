# Workflow: Incident Handling

> **Structured response to errors and failures.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-INCIDENT |
| **Phase** | Any (reactive) |
| **Primary Agent** | Sentinel |
| **Trigger** | Error detected |

---

## Purpose

The Incident workflow manages:
- Error detection and logging
- Circuit breaker management
- Pattern extraction
- Prevention for future

---

## Trigger

```yaml
triggers:
  - event: "error_detected"
  - event: "operation_failed"
  - event: "circuit_breaker_triggered"
  - command: "diagnose error"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    INCIDENT WORKFLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ERROR DETECTED                                                  │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Error Capture               │                       │
│  │ Agent: Sentinel                      │                       │
│  │ • Capture error details              │                       │
│  │ • Record context                     │                       │
│  │ • Log to error journal               │                       │
│  │ • Increment failure counter          │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Circuit Breaker Check       │                       │
│  │ Agent: Sentinel                      │                       │
│  │ • Check consecutive failures         │                       │
│  │ • Update circuit state               │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│     UNDER THRESHOLD    THRESHOLD REACHED                        │
│            │                 │                                  │
│            │                 ▼                                  │
│            │         ┌──────────────────┐                      │
│            │         │ CIRCUIT OPEN     │                      │
│            │         │ Operations blocked│                      │
│            │         └────────┬─────────┘                      │
│            │                  │                                 │
│            ▼                  ▼                                 │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Similar Error Check         │                       │
│  │ Agent: Sentinel                      │                       │
│  │ • Search error journal               │                       │
│  │ • Find similar past errors           │                       │
│  │ • Retrieve solutions if exist        │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│     SOLUTION FOUND     NO SOLUTION                              │
│            │                 │                                  │
│            ▼                 ▼                                  │
│      ┌──────────┐     ┌──────────────┐                         │
│      │ Apply    │     │ Diagnose     │                         │
│      │ Solution │     │ Root Cause   │                         │
│      └────┬─────┘     └──────┬───────┘                         │
│           │                  │                                  │
│           └────────┬─────────┘                                  │
│                    ▼                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: Resolution                  │                       │
│  │ • Apply fix                          │                       │
│  │ • Test fix                           │                       │
│  │ • Verify resolution                  │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│         RESOLVED         UNRESOLVED                             │
│            │                 │                                  │
│            │                 └──► Request human help            │
│            ▼                                                    │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: Pattern Extraction          │                       │
│  │ Agent: Sentinel                      │                       │
│  │ • Extract prevention pattern         │                       │
│  │ • Update learned patterns            │                       │
│  │ • Link to error record               │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 6: Circuit Reset (if needed)   │                       │
│  │ Agent: Sentinel                      │                       │
│  │ • Reset failure counter              │                       │
│  │ • Set circuit to HALF-OPEN          │                       │
│  │ • Allow test operation               │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  INCIDENT RESOLVED - Pattern Saved                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Error Capture

**Agent:** Sentinel

**Capture Details:**
```json
{
  "id": "ERR-YYYYMMDD-HHMMSS",
  "timestamp": "ISO-8601",
  "category": "category",
  "severity": "low|medium|high|critical",
  "symptom": "Error message or behavior",
  "context": {
    "file": "file path",
    "operation": "what was being done",
    "phase": "current phase",
    "story": "active story if any"
  },
  "stack_trace": "if available",
  "related_errors": []
}
```

**Storage:** `memory/error-journal.json`

---

### Step 2: Circuit Breaker Check

**Agent:** Sentinel

**Logic:**
```
IF consecutive_failures >= max_failures (3)
THEN
  circuit_state = OPEN
  block_operations = true
  require_diagnosis = true
ELSE
  increment consecutive_failures
  continue with diagnosis
```

**Circuit States:**
| State | Meaning | Action |
|-------|---------|--------|
| CLOSED | Normal | Allow operations |
| OPEN | Blocked | Require diagnosis |
| HALF-OPEN | Testing | Allow one operation |

---

### Step 3: Similar Error Check

**Agent:** Sentinel

**Search Criteria:**
- Same error category
- Similar symptom text
- Same file/component
- Same operation type

**If Found:**
- Retrieve past solution
- Calculate confidence based on similarity
- Suggest applying solution

**If Not Found:**
- Proceed to root cause diagnosis

---

### Step 4: Resolution

**Activities:**
- Apply identified fix
- Test the fix works
- Verify error is resolved
- Check for side effects

**Resolution Verification:**
```
1. Apply fix
2. Re-run failed operation
3. Confirm success
4. Run related tests
5. Mark as resolved
```

---

### Step 5: Pattern Extraction

**Agent:** Sentinel

**Pattern Format:**
```json
{
  "id": "P-LEARN-XXX",
  "type": "prevention",
  "category": "error category",
  "trigger": "What indicates this might happen",
  "action": "What to do to prevent/fix",
  "confidence": 0.0-1.0,
  "source_errors": ["ERR-XXX"],
  "applied_count": 0
}
```

**Storage:** `memory/learned-patterns.json`

---

### Step 6: Circuit Reset

**Agent:** Sentinel

**Reset Conditions:**
- Error resolved
- Solution verified
- Tests passing

**Reset Actions:**
1. Set circuit to HALF-OPEN
2. Allow one test operation
3. On success: set to CLOSED
4. On failure: return to OPEN

---

## Severity Levels

| Severity | Description | Response |
|----------|-------------|----------|
| **Low** | Minor, doesn't block work | Log, continue |
| **Medium** | Inconvenient, workaround exists | Log, suggest fix |
| **High** | Blocks current task | Stop, diagnose, fix |
| **Critical** | Data loss risk, security issue | Immediate attention |

---

## Error Categories

| Category | Examples |
|----------|----------|
| `typescript` | Type errors, import errors |
| `runtime` | Null reference, undefined |
| `build` | Compilation, bundling |
| `test` | Test failures |
| `network` | API errors, timeouts |
| `database` | Query errors, connection |
| `config` | Missing config, invalid values |

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| Error Record | `memory/error-journal.json` | Required |
| Learned Pattern | `memory/learned-patterns.json` | If resolved |
| Circuit State | `memory/circuit-breaker.json` | Updated |

---

## Success Criteria

- [ ] Error captured with full context
- [ ] Circuit breaker updated correctly
- [ ] Similar errors checked
- [ ] Resolution applied and verified
- [ ] Pattern extracted for future
- [ ] Circuit reset if applicable

---

## Related

- [Sentinel Agent](../agents/sentinel.md)
- [P-004: Circuit Breaker](../patterns/P-004-circuit-breaker.md)
- [P-005: Closed-Loop Learning](../patterns/P-005-closed-loop.md)

