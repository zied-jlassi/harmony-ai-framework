# Workflow: Implementation (Phase 4)

> **Build the solution according to the design.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-IMPLEMENTATION |
| **Phase** | 4 - Implementation |
| **Primary Agents** | Developer (Developer), Tester (Tester), Exploratory QA |
| **Prerequisite** | Architecture approved, Stories ready, UCVs approved |

---

## Purpose

The Implementation workflow executes development:
- Story-by-story implementation
- Test coverage
- UCV verification
- Quality assurance

---

## Trigger

```yaml
triggers:
  - command: "start implementation"
  - command: "develop STORY-XXX"
  - condition: "phase 3 complete AND stories ready"
  - event: "phase_transition from 3 to 4"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    IMPLEMENTATION WORKFLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: Ready Story with Approved UCV                           │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Story Activation            │                       │
│  │ Agent: Guardian                      │                       │
│  │ • Verify story exists                │                       │
│  │ • Check UCV approved                 │                       │
│  │ • Set story IN_PROGRESS              │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Implementation              │                       │
│  │ Agent: Developer                     │                       │
│  │ • Code implementation                │                       │
│  │ • Mark UCV [dev] checkboxes          │                       │
│  │ • Commit with story reference        │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Testing                     │                       │
│  │ Agent: Tester                        │                       │
│  │ • Write unit tests                   │                       │
│  │ • Write integration tests            │                       │
│  │ • Mark UCV [test] checkboxes         │                       │
│  │ • Ensure coverage targets            │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: Build & Verify              │                       │
│  │ Agent: Developer + Tester           │                       │
│  │ • Run build                          │                       │
│  │ • Run all tests                      │                       │
│  │ • Fix any failures                   │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: QA Validation               │                       │
│  │ Agent: Exploratory QA                          │                       │
│  │ • Exploratory testing                │                       │
│  │ • Visual verification                │                       │
│  │ • Mark UCV [qa] checkboxes           │                       │
│  │ • Report issues found                │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 6: UCV Validation              │                       │
│  │ Agent: UCV Validator                        │                       │
│  │ • Check 100% coverage                │                       │
│  │ • Verify all columns checked         │                       │
│  │ • Generate coverage report           │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ GATE: Story Complete?               │                       │
│  │ • UCV 100% coverage                  │                       │
│  │ • Tests passing                      │                       │
│  │ • Build successful                   │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│         COMPLETE          INCOMPLETE                            │
│            │                 │                                  │
│            │                 └──► Fix issues, retry             │
│            ▼                                                    │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 7: Story Closure               │                       │
│  │ Agent: SM                            │                       │
│  │ • Mark story DONE                    │                       │
│  │ • Update sprint status               │                       │
│  │ • Notify stakeholders                │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  Next Story (or Phase 5 if all done)                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Story Activation

**Agent:** Guardian

**Prerequisites Check:**
- [ ] Story file exists
- [ ] Story status is TODO
- [ ] UCV file exists
- [ ] UCV status is APPROVED

**Actions:**
- Set story status to IN_PROGRESS
- Record in workflow state
- Notify developer

---

### Step 2: Implementation

**Agent:** Developer (Developer)

**Activities:**
- Read story and UCV carefully
- Implement each verification
- Mark [dev] checkbox as each is implemented
- Commit with story reference

**Commit Format:**
```
feat(STORY-XXX): Implement [feature description]

- [Detail 1]
- [Detail 2]

Refs: STORY-XXX
```

**UCV Marking:**
```markdown
| V-001-1 | Modal centered | [x] | [ ] | [ ] |
```

---

### Step 3: Testing

**Agent:** Tester (Tester)

**Activities:**
- Write unit tests for new code
- Write integration tests
- Mark [test] checkbox for each verification with tests
- Ensure coverage meets threshold

**Test Mapping:**
```typescript
// V-001-1: Modal centered
describe('Modal', () => {
  it('should be centered on screen', () => {
    // Test implementation
  });
});
```

---

### Step 4: Build & Verify

**Agents:** Developer + Tester

**Activities:**
- Run full build
- Run all tests (unit, integration, e2e)
- Fix any failures
- Ensure no regressions

**Commands:**
```bash
npm run build
npm run test
npm run test:e2e
```

---

### Step 5: QA Validation

**Agent:** Exploratory QA

**Activities:**
- Exploratory testing session
- Visual verification of each UCV
- Mark [qa] checkbox after validation
- Report any issues found

**Session Types:**
- Smoke test (quick)
- Full exploratory (thorough)
- Edge case hunt
- Accessibility check

---

### Step 6: UCV Validation

**Agent:** UCV Validator

**Activities:**
- Calculate coverage percentages
- Verify all three columns checked
- Generate coverage report
- Block if not 100%

**Coverage Report:**
```
STORY-XXX Coverage:
  Dev:  14/14 (100%) ✅
  Test: 14/14 (100%) ✅
  QA:   14/14 (100%) ✅

Overall: 100% - READY FOR CLOSURE
```

---

### Step 7: Story Closure

**Agent:** SM (Scrum Master)

**Activities:**
- Set story status to DONE
- Update sprint status
- Record completion metrics
- Prepare for next story

---

## Gate: Story Completion

**Completion Criteria:**
- [ ] All UCV verifications marked [dev]
- [ ] All UCV verifications marked [test]
- [ ] All UCV verifications marked [qa]
- [ ] All tests passing
- [ ] Build successful

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| Implementation | Source code | Required |
| Tests | Test files | Required |
| Updated UCV | `STORY-XXX-UCV.md` | Required |
| Updated Story | `STORY-XXX.md` | Required |

---

## Error Handling

**Circuit Breaker Integration:**
- Track consecutive failures
- Open circuit after 3 failures
- Force diagnosis before continuing

**Error Recording:**
- Log errors to error journal
- Extract patterns when resolved
- Update learned patterns

---

## Related

- [Developer Agent](../agents/developer.md)
- [Tester Agent](../agents/tester.md)
- [Exploratory QA Agent 🔍](../agents/exploratory-qa.md)
- [UCV Validator Agent ✅](../specialties/ucv/branchs/validator.md)
- [P-008: UCV Quality Gate](../patterns/P-008-ucv-gate.md)

