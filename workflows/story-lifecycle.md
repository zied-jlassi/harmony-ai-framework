# Workflow: Story Lifecycle

> **Complete journey from story creation to completion.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-STORY-LIFECYCLE |
| **Phase** | 3-4 (Solutioning to Implementation) |
| **Agents** | SM, UCV Writer, Developer, Tester, Exploratory QA, UCV Validator |

---

## Purpose

Defines the complete lifecycle of a user story:
- Creation by SM
- UCV generation by UCV Writer
- Approval by user
- Implementation by Developer
- Testing by Tester
- Validation by Exploratory QA
- Verification by UCV Validator
- Closure by SM

---

## Story States

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORY STATE MACHINE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────┐                                                    │
│  │  DRAFT  │ ← Story created, awaiting UCV                     │
│  └────┬────┘                                                    │
│       │ [UCV created]                                           │
│       ▼                                                         │
│  ┌─────────────┐                                                │
│  │ UCV_PENDING │ ← Awaiting user UCV approval                  │
│  └──────┬──────┘                                                │
│         │ [User approves]                                       │
│         ▼                                                       │
│  ┌─────────┐                                                    │
│  │   TODO  │ ← Ready for development                           │
│  └────┬────┘                                                    │
│       │ [Dev starts]                                            │
│       ▼                                                         │
│  ┌─────────────┐                                                │
│  │ IN_PROGRESS │ ← Active development                          │
│  └──────┬──────┘                                                │
│         │ [Dev complete, testing done]                          │
│         ▼                                                       │
│  ┌──────────┐                                                   │
│  │  REVIEW  │ ← UCV Validator validates 100% UCV                      │
│  └─────┬────┘                                                   │
│        │ [100% coverage confirmed]                              │
│        ▼                                                        │
│  ┌─────────┐                                                    │
│  │  DONE   │ ← Story complete                                  │
│  └─────────┘                                                    │
│                                                                  │
│  Alternative paths:                                             │
│  ─────────────────                                              │
│  UCV_PENDING → [Rejected] → DRAFT (revise)                     │
│  IN_PROGRESS → [Blocked] → BLOCKED (external dependency)       │
│  REVIEW → [Gaps found] → IN_PROGRESS (fix gaps)                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORY LIFECYCLE FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 1: CREATION                   │                       │
│  │ Agent: SM (Scrum Master)                     │                       │
│  │                                      │                       │
│  │ • Extract from epic/request          │                       │
│  │ • Write user story format            │                       │
│  │ • Define acceptance criteria         │                       │
│  │ • Create STORY-XXX.md               │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 2: UCV GENERATION             │                       │
│  │ Agent: UCV Writer                        │                       │
│  │                                      │                       │
│  │ • Analyze story requirements         │                       │
│  │ • Write Gherkin scenarios            │                       │
│  │ • Define verifications               │                       │
│  │ • Create STORY-XXX-UCV.md           │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 3: APPROVAL                   │                       │
│  │ Actor: User                         │                       │
│  │                                      │                       │
│  │ • Review story and UCV               │                       │
│  │ • Validate completeness              │                       │
│  │ • Approve or request changes         │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│        APPROVED           CHANGES                               │
│            │                 │                                  │
│            │                 └──► Return to Phase 2             │
│            ▼                                                    │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 4: IMPLEMENTATION             │                       │
│  │ Agent: Developer (Developer)           │                       │
│  │                                      │                       │
│  │ • Set story IN_PROGRESS              │                       │
│  │ • Implement each verification        │                       │
│  │ • Mark [dev] checkboxes              │                       │
│  │ • Commit with story reference        │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 5: TESTING                    │                       │
│  │ Agent: Tester (Tester)                │                       │
│  │                                      │                       │
│  │ • Write tests for each verification  │                       │
│  │ • Run tests                          │                       │
│  │ • Mark [test] checkboxes             │                       │
│  │ • Ensure coverage                    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 6: QA VALIDATION              │                       │
│  │ Agent: Exploratory QA                         │                       │
│  │                                      │                       │
│  │ • Exploratory testing                │                       │
│  │ • Visual verification                │                       │
│  │ • Mark [qa] checkboxes               │                       │
│  │ • Report issues                      │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 7: VERIFICATION               │                       │
│  │ Agent: UCV Validator                       │                       │
│  │                                      │                       │
│  │ • Check all [dev] marked             │                       │
│  │ • Check all [test] marked            │                       │
│  │ • Check all [qa] marked              │                       │
│  │ • Confirm 100% coverage              │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│          100%             GAPS                                  │
│            │                 │                                  │
│            │                 └──► Return to relevant phase      │
│            ▼                                                    │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 8: CLOSURE                    │                       │
│  │ Agent: SM (Scrum Master)                     │                       │
│  │                                      │                       │
│  │ • Set story to DONE                  │                       │
│  │ • Update sprint status               │                       │
│  │ • Archive story                      │                       │
│  └─────────────────────────────────────┘                       │
│                                                                  │
│  STORY COMPLETE                                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase Details

### Phase 1: Creation

**Agent:** SM (Scrum Master)

**Inputs:**
- Epic requirements
- User request
- PRD sections

**Activities:**
- Write story in standard format
- Define clear acceptance criteria
- Set initial estimates

**Template:** `templates/story.md`

**Output:** `docs/backlog/stories/STORY-XXX.md`

---

### Phase 2: UCV Generation

**Agent:** UCV Writer

**Inputs:**
- Story file
- Epic context
- PRD reference

**Activities:**
- Create use cases from requirements
- Write Gherkin scenarios
- Define specific verifications
- Include edge cases

**Template:** `templates/ucv.md`

**Output:** `docs/backlog/stories/STORY-XXX-UCV.md`

---

### Phase 3: Approval

**Actor:** User

**Gate Criteria:**
- [ ] Story is clear and complete
- [ ] UCVs cover all requirements
- [ ] No ambiguity in verifications
- [ ] Edge cases covered

**Status Change:** UCV_PENDING → TODO

---

### Phase 4: Implementation

**Agent:** Developer (Developer)

**Prerequisites:**
- Story status = TODO
- UCV status = APPROVED

**Activities:**
- Implement each verification
- Mark `[x] dev` as implemented
- Commit with `Refs: STORY-XXX`

---

### Phase 5: Testing

**Agent:** Tester (Tester)

**Activities:**
- Write unit tests per verification
- Write integration tests
- Mark `[x] test` as tested
- Ensure coverage thresholds

---

### Phase 6: QA Validation

**Agent:** Exploratory QA

**Activities:**
- Exploratory testing session
- Visual verification
- Mark `[x] qa` as validated
- Report any issues found

---

### Phase 7: Verification

**Agent:** UCV Validator

**Verification Matrix:**
```
┌────────────┬─────┬──────┬─────┬──────────┐
│ Verification│ Dev │ Test │ QA  │ Complete │
├────────────┼─────┼──────┼─────┼──────────┤
│ V-001-1    │ ✅  │  ✅  │ ✅  │   ✅     │
│ V-001-2    │ ✅  │  ✅  │ ✅  │   ✅     │
│ V-002-1    │ ✅  │  ✅  │ ✅  │   ✅     │
└────────────┴─────┴──────┴─────┴──────────┘

Coverage: 3/3 = 100% ✅
```

**Gate:** 100% required for closure

---

### Phase 8: Closure

**Agent:** SM (Scrum Master)

**Activities:**
- Set story status = DONE
- Update sprint status
- Calculate velocity impact
- Archive completed story

---

## Related

- [Scrum Master](../agents/scrum-master.md)
- [UCV Writer Agent 📝](../agents/specialists/ucv-writer.md)
- [UCV Validator Agent ✅](../agents/specialists/ucv-validator.md)
- [Developer Agent](../agents/developer.md)
- [Tester Agent](../agents/tester.md)
- [Exploratory QA Agent 🔍](../agents/specialists/exploratory-qa.md)
- [Story Template](../templates/story.md)
- [UCV Template](../templates/ucv.md)

