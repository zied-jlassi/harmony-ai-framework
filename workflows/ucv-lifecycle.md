# Workflow: UCV Lifecycle

> **From creation to 100% verification coverage.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-UCV-LIFECYCLE |
| **Phase** | 3-4 (Solutioning to Implementation) |
| **Primary Agents** | UCV Writer (Writer), UCV Validator (Validator) |

---

## Purpose

The UCV Lifecycle ensures:
- Complete verification coverage for every story
- Clear, unambiguous acceptance criteria
- Three-column validation (Dev, Test, QA)
- Objective story completion

---

## UCV States

```
┌─────────────────────────────────────────────────────────────────┐
│                    UCV STATE MACHINE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────┐                                                    │
│  │ PENDING │ ← Created, awaiting approval                      │
│  └────┬────┘                                                    │
│       │ [User reviews]                                          │
│       ▼                                                         │
│  ┌──────────────┐                                               │
│  │ UNDER_REVIEW │ ← User reviewing UCVs                        │
│  └──────┬───────┘                                               │
│         │                                                       │
│    ┌────┴────┐                                                  │
│    ▼         ▼                                                  │
│ APPROVED  REJECTED                                              │
│    │         │                                                  │
│    │         └──► Return to PENDING (revise)                    │
│    ▼                                                            │
│  ┌────────────┐                                                 │
│  │ VALIDATING │ ← Implementation phase                         │
│  └─────┬──────┘                                                 │
│        │ [Dev marks] [Test marks] [QA marks]                    │
│        ▼                                                        │
│  ┌────────────┐                                                 │
│  │ COMPLETE   │ ← 100% coverage achieved                       │
│  └────────────┘                                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    UCV LIFECYCLE FLOW                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: Story with acceptance criteria                          │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 1: UCV CREATION               │                       │
│  │ Agent: UCV Writer                        │                       │
│  │                                      │                       │
│  │ • Analyze story requirements         │                       │
│  │ • Create use cases (UC-XXX)          │                       │
│  │ • Write Gherkin scenarios            │                       │
│  │ • Define verifications (V-XXX-X)     │                       │
│  │ • Include edge cases                 │                       │
│  │ • Add non-functional requirements    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 2: STAKEHOLDER REVIEW         │                       │
│  │ Optional Agents:                    │                       │
│  │ • Architect (technical feasibility)  │                       │
│  │ • Security (security verifications)  │                       │
│  │ • Accessibility (a11y verifications) │                       │
│  │ • RGPD (data protection)             │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 3: USER APPROVAL              │                       │
│  │ Actor: User                         │                       │
│  │                                      │                       │
│  │ • Review all use cases               │                       │
│  │ • Validate verifications             │                       │
│  │ • Check edge cases                   │                       │
│  │ • Explicit approval                  │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│        APPROVED           CHANGES                               │
│            │              REQUESTED                             │
│            │                 │                                  │
│            │                 └──► Return to Phase 1             │
│            ▼                                                    │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 4: DEVELOPMENT MARKING        │                       │
│  │ Agent: Developer                    │                       │
│  │                                      │                       │
│  │ • Implement each verification        │                       │
│  │ • Mark [x] in DEV column             │                       │
│  │ • One at a time as implemented       │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 5: TEST MARKING               │                       │
│  │ Agent: Tester                       │                       │
│  │                                      │                       │
│  │ • Write test for each verification   │                       │
│  │ • Mark [x] in TEST column            │                       │
│  │ • Ensure test covers the scenario    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 6: QA MARKING                 │                       │
│  │ Agent: Exploratory QA                         │                       │
│  │                                      │                       │
│  │ • Visually verify each item          │                       │
│  │ • Mark [x] in QA column              │                       │
│  │ • Report any issues found            │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ PHASE 7: VALIDATION                 │                       │
│  │ Agent: UCV Validator                       │                       │
│  │                                      │                       │
│  │ • Calculate coverage percentages     │                       │
│  │ • Check all columns complete         │                       │
│  │ • Generate coverage report           │                       │
│  │ • Block if < 100%                    │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│          100%              GAPS                                 │
│            │                 │                                  │
│            │                 └──► Return to relevant phase      │
│            ▼                                                    │
│  UCV COMPLETE - Story can be closed                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## UCV Structure

### Use Case (UC)

```yaml
- id: UC-001
  title: "Open edit form"
  gherkin: |
    Given I am logged in as admin
    And I am on the users list page
    When I click the edit icon for "john@test.com"
    Then a modal dialog appears centered on screen
    And the email field contains "john@test.com"
```

### Verification (V)

```yaml
verifications:
  - id: V-001-1
    description: "Modal is visible and centered"
    dev: false   # ☐ Developer marks when implemented
    test: false  # ☐ Tester marks when test exists
    qa: false    # ☐ QA marks when visually verified
```

---

## UCV Writer: UCV Writer

### Responsibilities

- Analyze story requirements thoroughly
- Create comprehensive use cases
- Write clear Gherkin scenarios
- Define specific, measurable verifications
- Include edge cases and error scenarios
- Add non-functional requirements when relevant

### Good Verifications

```yaml
# ✅ Specific, measurable, unambiguous
- id: V-001-1
  description: "Modal is centered horizontally and vertically on viewport"

- id: V-001-2
  description: "Email field contains current user's email 'john@test.com'"

- id: V-001-3
  description: "Error message 'Invalid email format' appears for input 'abc@'"
```

### Bad Verifications

```yaml
# ❌ Vague, subjective, hard to verify
- id: V-001-1
  description: "Modal looks good"

- id: V-001-2
  description: "Form works correctly"

- id: V-001-3
  description: "User experience is smooth"
```

---

## UCV Validator: UCV Validator

### Responsibilities

- Calculate coverage percentages
- Verify all three columns are checked
- Generate coverage reports
- Block story closure if < 100%
- Report specific gaps

### Coverage Report

```
┌─────────────────────────────────────────────────────────────────┐
│                    UCV COVERAGE REPORT                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Story: STORY-042                                               │
│  Date: 2025-01-15                                               │
│                                                                  │
│  SUMMARY                                                        │
│  ───────                                                        │
│  │ Validator │ Complete │ Total │ Coverage │                   │
│  ├───────────┼──────────┼───────┼──────────┤                   │
│  │ Dev       │ 14       │ 14    │ 100% ✅  │                   │
│  │ Test      │ 12       │ 14    │  86% ⚠️  │                   │
│  │ QA        │ 10       │ 14    │  71% ❌  │                   │
│  └───────────┴──────────┴───────┴──────────┘                   │
│                                                                  │
│  MISSING VERIFICATIONS                                          │
│  ─────────────────────                                          │
│                                                                  │
│  Test (2 missing):                                              │
│  • V-002-3: Email duplicate check                               │
│  • V-003-4: Data persistence                                    │
│                                                                  │
│  QA (4 missing):                                                │
│  • V-001-4: Close button visible                                │
│  • V-001-5: Click outside closes modal                          │
│  • V-002-3: Email duplicate check                               │
│  • V-003-4: Data persistence                                    │
│                                                                  │
│  RECOMMENDATION                                                 │
│  ──────────────                                                 │
│  Complete missing verifications before closing story.           │
│                                                                  │
│  STATUS: BLOCKED (100% required)                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| UCV File | `STORY-XXX-UCV.md` | Required |
| Coverage Report | In UCV file footer | Required |

---

## Success Criteria

- [ ] All use cases defined
- [ ] All verifications specific and measurable
- [ ] User has approved UCV
- [ ] Dev column 100%
- [ ] Test column 100%
- [ ] QA column 100%
- [ ] UCV Validator confirms 100% coverage

---

## Related

- [UCV Writer Agent 📝](../specialties/ucv/branchs/writer.md)
- [UCV Validator Agent ✅](../specialties/ucv/branchs/validator.md)
- [UCV Template](../templates/ucv.md)
- [P-008: UCV Quality Gate](../patterns/P-008-ucv-gate.md)

