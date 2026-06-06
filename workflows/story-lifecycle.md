# Workflow: Story Lifecycle

> **Complete journey from story creation to completion.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-STORY-LIFECYCLE |
| **Phase** | 3-4 (Solutioning to Implementation) |
| **Agents** | Scrum Master, UCV Writer, Developer, Tester, UCV QA, UCV Validator, Exploratory QA (optional) |
| **Version** | 2.0 |
| **Updated** | 2026-01-03 |

---

## Purpose

Defines the complete lifecycle of a user story from creation to completion.

### Agents Involved

| Agent | Role | Checkpoint |
|-------|------|------------|
| **Scrum Master** | Creates story from epic | STORY-XXX.md |
| **UCV Writer** | Generates use case verifications | UCV section in STORY-XXX.md |
| **User** | Approves UCVs (GATE) | status: APPROVED |
| **Developer** | Implements each verification | [dev] ✓ |
| **Tester** | Writes automated tests | [test] ✓ |
| **UCV QA** | Manually validates each UCV | [qa] ✓ |
| **UCV Validator** | Verifies 100% coverage | Go/No-Go |
| **Exploratory QA** | Free exploration (MANDATORY) | Go/No-Go |

### Key Distinction

| Agent | What they do | Type |
|-------|--------------|------|
| **UCV QA** | Tests EACH UCV systematically in browser | Structured |
| **Exploratory QA** | Free exploration to find unexpected bugs | Unstructured |

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
│  │ • Define verifications (V1, V2...)   │                       │
│  │ • Fill <!-- UCV_SECTION --> in story │                       │
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
│  │ Agent: Tester                       │                       │
│  │                                      │                       │
│  │ • Write tests for each verification  │                       │
│  │ • Run tests                          │                       │
│  │ • Mark [test] checkboxes             │                       │
│  │ • Ensure coverage                    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 6: UCV QA VALIDATION          │                       │
│  │ Agent: UCV QA                       │                       │
│  │                                      │                       │
│  │ • Test EACH UCV in browser          │                       │
│  │ • Follow Gherkin scenarios          │                       │
│  │ • Take screenshots as evidence      │                       │
│  │ • Mark [qa] checkboxes              │                       │
│  │ • Report failures if any            │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 6b: EXPLORATORY QA            │                       │
│  │ Agent: Exploratory QA               │                       │
│  │                                      │                       │
│  │ • Free exploration testing           │                       │
│  │ • Find unexpected bugs               │                       │
│  │ • UX/Usability issues               │                       │
│  │ • Edge cases discovery              │                       │
│  │ • Go/No-Go decision                 │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 7: VERIFICATION               │                       │
│  │ Agent: UCV Validator                │                       │
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

**Output:** `${HARMONY_DIR}/local/backlog/stories/STORY-XXX.md`

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

**Template:** `templates/story.md` (section `<!-- UCV_SECTION_START -->`)

**Output:** UCV section filled in `STORY-XXX.md` (inline, not separate file)

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

### Phase 6: UCV QA Validation

**Agent:** UCV QA

**Prerequisites:**
- All `[dev]` checkboxes marked
- All `[test]` checkboxes marked
- Application running and accessible

**Activities:**
- Read UCV section in STORY-XXX.md
- For each verification:
  - Navigate to the relevant page
  - Execute the Gherkin scenario
  - Verify expected behavior
  - Take screenshot as evidence
  - Mark `[x] qa` if PASS
  - Document issue if FAIL

**Output:**
- Story file with `[qa]` marks in UCV section
- Screenshots in `${HARMONY_DIR}/local/docs/qa/STORY-XXX/`
- QA report

---

### Phase 6b: Exploratory QA (MANDATORY)

**Agent:** Exploratory QA

**Purpose:**
Session timeboxee d'exploration libre avant release.
Obligatoire pour toute story avant validation finale.

**Activities:**
- Free exploration testing session (60-90 min)
- Find unexpected bugs
- Discover edge cases
- UX/Usability issues
- Go/No-Go decision

**Output:**
- Bug reports (if issues found)
- UX improvement suggestions
- Go/No-Go recommendation

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

### Agents

| Agent | File | Role |
|-------|------|------|
| Scrum Master | [scrum-master.md](../agents/scrum-master.md) | Story creation |
| UCV Writer | [writer.md](../specialties/ucv/branchs/writer.md) | UCV generation |
| Developer | [developer.md](../agents/developer.md) | Implementation |
| Tester | [tester.md](../agents/tester.md) | Automated tests |
| **UCV QA** | [qa.md](../specialties/ucv/branchs/qa.md) | Manual UCV validation |
| Exploratory QA | [exploratory-qa.md](../agents/exploratory-qa.md) | Free exploration |
| UCV Validator | [validator.md](../specialties/ucv/branchs/validator.md) | 100% verification |

### Templates

- [Story Template](../templates/story.md) - Includes UCV section inline (v2.0)

### Commands

```bash
# Story creation
/scrum-master create-story EPIC-XXX

# UCV generation
/ucv-writer STORY-XXX

# Implementation
/developer STORY-XXX

# Testing
/tester STORY-XXX

# UCV QA validation
/ucv-qa STORY-XXX

# Exploratory QA (optional)
/exploratory-qa [module]

# Final verification
/ucv-validator STORY-XXX
```

