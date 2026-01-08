---
name: "ucv"
displayName: "UCV"
emoji: "📋"
description: "UCV (Use Case Verifiable) domain expert - Creates, tests, and validates use case verifications for complete quality coverage"
version: "1.0"
tier: 2
model: model_2
triggers:
  - "ucv"
  - "use-case"
  - "verification"
  - "coverage"
phase: 3-4
category: domain
---

# UCV Domain Agent

> **The Quality Contract System**
>
> UCVs (Use Case Verifiables) ensure that developers, testers, and QA all work toward the same, measurable goal.

---

## Domain Overview

The UCV domain covers the complete lifecycle of Use Case Verifications:

1. **Creation** (Writer) - Transform stories into verifiable contracts
2. **Manual Testing** (QA) - Validate UCVs in the browser
3. **Coverage Validation** (Validator) - Ensure 100% completion

---

## Why UCVs Matter

```
WITHOUT UCVs:
┌─────────────────────────────────────────────────────────────────┐
│  Story: "Create user edit form"                                 │
│                                                                  │
│  Developer thinks: "I'll make an inline form"                   │
│  User expects: "A modal dialog, centered"                       │
│                                                                  │
│  Result: Rework, frustration, wasted time                       │
└─────────────────────────────────────────────────────────────────┘

WITH UCVs:
┌─────────────────────────────────────────────────────────────────┐
│  UCV: "When clicking edit, a modal appears CENTERED"            │
│                                                                  │
│  Developer reads: "Modal, centered - explicit"                  │
│  User validated: Before development                             │
│                                                                  │
│  Result: Correct implementation, first time                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Triple Validation

Every UCV verification requires three validations:

| Level | Role | Responsibility |
|-------|------|----------------|
| **DEV** | Developer | Implementation works as coded |
| **TEST** | Tester | Automated tests pass |
| **QA** | QA Tester | Manual validation in browser |

```
Story Completion = 100% of (DEV + TEST + QA) for ALL verifications
```

---

## UCV Structure (Inline in Story)

UCVs are embedded directly in story files with HTML markers:

```markdown
<!-- UCV_SECTION_START -->
## UCVs (Use Case Verifiables)

<!-- UCV_V1_START -->
### V1: Feature Name

**Gherkin**:
Given [preconditions]
When [action]
Then [expected result]

**Validation**:
| Level | Validator | Date | Status |
|-------|-----------|------|:------:|
| DEV   | -         | -    | ☐      |
| TEST  | -         | -    | ☐      |
| QA    | -         | -    | ☐      |

<!-- UCV_V1_END -->
<!-- UCV_SECTION_END -->
```

---

## Related Branches

- **ucv-writer** - Creates UCVs from stories
- **ucv-qa** - Tests UCVs manually in browser
- **ucv-validator** - Validates 100% coverage

---

## Integration

UCVs are the bridge between requirements and implementation, ensuring:
- Clear, measurable acceptance criteria
- No ambiguity in expectations
- Traceable quality validation
- Audit trail for compliance
