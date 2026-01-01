# P-008: UCV Quality Gate

> **100% verification coverage required for story completion.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-008 |
| **Category** | Quality |
| **Complexity** | Medium |
| **Applicability** | All stories |

---

## Problem

Traditional acceptance criteria are:
- Vague ("it should work well")
- Subjective ("user-friendly")
- Not verifiable ("performant")
- Easy to miss items

---

## Solution

Use Case Verifications (UCVs) with explicit checkboxes for each validator:

```
┌─────────────────────────────────────────────────────────────────┐
│                    UCV QUALITY GATE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  VERIFICATION MATRIX                                            │
│  ────────────────────────────────────────────────               │
│                                                                  │
│  │ Verification           │ Dev │ Test │ QA  │ Complete │      │
│  ├────────────────────────┼─────┼──────┼─────┼──────────┤      │
│  │ V-001-1: Modal centered│ ✅  │  ✅  │ ✅  │   ✅     │      │
│  │ V-001-2: Form prefilled│ ✅  │  ✅  │ ❌  │   ❌     │      │
│  │ V-001-3: Close button  │ ✅  │  ❌  │ ❌  │   ❌     │      │
│  │ V-002-1: Email valid.  │ ✅  │  ✅  │ ✅  │   ✅     │      │
│  └────────────────────────┴─────┴──────┴─────┴──────────┘      │
│                                                                  │
│  COVERAGE: 2/4 = 50%                                            │
│                                                                  │
│  STORY STATUS: IN_PROGRESS (100% required for DONE)             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## UCV Structure

```yaml
story_id: STORY-042
title: "Modifier utilisateur via popin"
status: APPROVED

use_cases:
  - id: UC-001
    title: "Ouvrir formulaire modification"
    gherkin: |
      Given je suis connecté en tant qu'admin
      When je clique sur l'icône crayon
      Then une popin modale s'affiche au centre

    verifications:
      - id: V-001-1
        description: "Popin visible et centrée"
        dev: false    # ☐ Developer
        test: false   # ☐ Tester
        qa: false     # ☐ QA (Exploratory QA)

      - id: V-001-2
        description: "Email pré-rempli"
        dev: false
        test: false
        qa: false

summary:
  total_verifications: 14
  coverage_target: 100%
```

---

## Validation Rules

### Story Completion

| Condition | Status |
|-----------|--------|
| All dev = true | Dev complete |
| All test = true | Test complete |
| All qa = true | QA complete |
| **All three = true** | **STORY DONE** |

### Gate Enforcement

```typescript
function canCloseStory(story: Story): ValidationResult {
  const ucv = loadUCV(story.id);
  const verifications = ucv.flatMap(uc => uc.verifications);

  const devComplete = verifications.every(v => v.dev);
  const testComplete = verifications.every(v => v.test);
  const qaComplete = verifications.every(v => v.qa);

  if (!devComplete || !testComplete || !qaComplete) {
    return {
      canClose: false,
      devCoverage: calcCoverage(verifications, 'dev'),
      testCoverage: calcCoverage(verifications, 'test'),
      qaCoverage: calcCoverage(verifications, 'qa'),
      missing: findMissing(verifications)
    };
  }

  return { canClose: true };
}
```

---

## Workflow Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                    UCV WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 3: Story Created                                         │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │  UCV Writer     │ ─── Creates STORY-XXX-UCV.md              │
│  └─────────────────┘                                            │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │  User Approval  │ ─── Reviews and approves UCVs              │
│  └─────────────────┘                                            │
│           │                                                      │
│           ▼                                                      │
│  PHASE 4: Development                                           │
│           │                                                      │
│           ├──► Developer marks: [x] dev                         │
│           │    (as implementing each verification)              │
│           │                                                      │
│           ├──► Tester marks:    [x] test                        │
│           │    (as writing tests for each)                      │
│           │                                                      │
│           └──► Exploratory QA marks: [x] qa                     │
│                (as validating visually)                         │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │ UCV Validator   │ ─── Verifies 100% coverage                │
│  └─────────────────┘                                            │
│           │                                                      │
│           ▼                                                      │
│  Story DONE (100% verified)                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Good vs Bad Verifications

### Good Verifications

```yaml
# ✅ Specific, measurable, unambiguous
- id: V-001-1
  description: "Modal is centered horizontally and vertically"

- id: V-001-2
  description: "Email field contains current user's email address"

- id: V-001-3
  description: "Error message 'Invalid email format' appears for 'abc@'"
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

## Coverage Report

```markdown
# UCV COVERAGE REPORT

## Story: STORY-042
## Date: 2025-01-15

## Summary
| Validator | Complete | Total | Coverage |
|-----------|----------|-------|----------|
| Dev       | 14       | 14    | 100% ✅  |
| Test      | 12       | 14    | 86% ⚠️   |
| QA        | 10       | 14    | 71% ❌   |

## Missing Verifications

### Test (2 missing)
- V-002-3: Email duplicate check
- V-003-4: Data persistence

### QA (4 missing)
- V-001-4: Close button visible
- V-001-5: Click outside closes
- V-002-3: Email duplicate check
- V-003-4: Data persistence

## Recommendation
Complete missing verifications before closing story.
```

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Objectivity** | Clear pass/fail criteria |
| **Traceability** | Each feature verified |
| **Accountability** | Who verified what |
| **Quality** | Nothing slips through |

---

## Related Patterns

- [P-007: Story-Based Development](P-007-story-based.md)
- [P-001: Hybrid Orchestration](P-001-hybrid-orchestration.md)

