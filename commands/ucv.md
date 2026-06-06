# Harmony HQVF - Use Case Verifiables

> **"Quality you can prove, not assume."**
>
> HQVF (Harmony Quality Verification Framework) ensures every feature
> is verified through explicit Use Case Verifiables (UCVs).

---

## The Problem HQVF Solves

| Scenario | Without HQVF | With HQVF |
|----------|--------------|-----------|
| Developer builds feature | "I think it works" | ✓ DEV verified |
| Tester writes tests | "Tests pass" | ✓ TEST verified |
| QA reviews | "Looks good" | ✓ QA verified |
| User receives | "Not what I wanted!" | "Exactly what I specified" |

**Root cause:** Gap between what user wants and what team delivers.

**Solution:** Explicit, verifiable acceptance criteria BEFORE development.

---

## HQVF Rules (Blocking)

| Rule | Description | Consequence |
|------|-------------|-------------|
| **HQVF-1** | Never develop without approved UCV | Story blocked |
| **HQVF-2** | Every story MUST have UCV file | Not startable |
| **HQVF-3** | User MUST approve UCVs before dev | Gate blocking |
| **HQVF-4** | DEV marks each verification | Progress tracked |
| **HQVF-5** | TEA writes 1+ test per verification | 100% coverage |
| **HQVF-6** | Exploratory QA validates each UCV | Final validation |
| **HQVF-7** | Story DONE = 100% UCVs valid | Objective, not subjective |

---

## Commands

### Create UCVs (`harmony ucv <story-id>`)

Generates UCV file for a story:

```bash
harmony ucv STORY-042
```

**Process:**
1. Read story requirements
2. Generate Use Cases with Gherkin format
3. Create verification checklist
4. Save to `.harmony/local/backlog/stories/STORY-XXX-UCV.md`

---

### Validate UCVs (`harmony ucv --validate <story-id>`)

Verify 100% coverage:

```bash
harmony ucv --validate STORY-042
```

**Output:**
```
UCV Validation - STORY-042
──────────────────────────

Use Cases: 5
Verifications: 20

Coverage:
├── DEV:  18/20 (90%)
├── TEST: 15/20 (75%)
└── QA:   12/20 (60%)

Overall: 75% ⚠️ NOT READY

Missing:
├── V-003-2: Password validation test
├── V-004-1: Error message QA check
└── ...
```

---

## UCV File Format

```markdown
# UCV - STORY-042

> **Title:** Modify user via modal
> **Status:** PENDING | APPROVED | REJECTED

---

## Approval

| Reviewer | Status | Date |
|----------|--------|------|
| User | PENDING | - |
| Architect | APPROVED | 2025-01-15 |

---

## Use Cases

### UC-001: Open modification form

**Gherkin:**
```gherkin
Given I am logged in as admin
And I am on the users list page
When I click the edit icon for "john@test.com"
Then a modal popup appears centered
And the email field contains "john@test.com"
```

**Verifications:**

| ID | Description | DEV | TEST | QA |
|----|-------------|:---:|:----:|:--:|
| V-001-1 | Modal visible and centered | ☐ | ☐ | ☐ |
| V-001-2 | Email pre-filled | ☐ | ☐ | ☐ |
| V-001-3 | Close button works | ☐ | ☐ | ☐ |

---

### UC-002: Submit modifications

**Gherkin:**
```gherkin
Given the modal is open with user data
When I modify the name to "Jane Doe"
And I click "Save"
Then the modal closes
And the list shows "Jane Doe"
And a success toast appears
```

**Verifications:**

| ID | Description | DEV | TEST | QA |
|----|-------------|:---:|:----:|:--:|
| V-002-1 | Form submission works | ☐ | ☐ | ☐ |
| V-002-2 | List updates immediately | ☐ | ☐ | ☐ |
| V-002-3 | Success toast visible | ☐ | ☐ | ☐ |

---

## Summary

| Metric | Value |
|--------|-------|
| Total Use Cases | 5 |
| Total Verifications | 20 |
| Coverage Target | 100% |
| Current Coverage | 0% |
```

---

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    HQVF WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: ELABORATION                                           │
│  ─────────────────────                                          │
│  SM (Scrum Master) creates story                                         │
│       ↓                                                         │
│  Harmony → UCV Writer (UCV Writer) generates UCVs                    │
│       ↓                                                         │
│  UCVs file created                                              │
│                                                                  │
│  PHASE 2: VALIDATION                                            │
│  ───────────────────                                            │
│  Architect reviews tech feasibility                             │
│  UX Designer reviews if UI involved                             │
│  User APPROVES UCVs (blocking gate)                             │
│       ↓                                                         │
│  Story marked READY                                             │
│                                                                  │
│  PHASE 3: IMPLEMENTATION                                        │
│  ────────────────────────                                       │
│  Developer implements + marks DEV ✓                          │
│  TEA (Tester) tests + marks TEST ✓                                │
│  Exploratory QA (QA) explores + marks QA ✓                                │
│                                                                  │
│  PHASE 4: CLOSURE                                               │
│  ─────────────────                                              │
│  Harmony → UCV Validator (Validator) verifies 100%                     │
│       ↓                                                         │
│  Story marked DONE                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Agents Involved

| Agent | Persona | Role |
|-------|---------|------|
| **UCV Writer** | UCV Writer | Generate exhaustive UCVs |
| **UCV Validator** | UCV Validator | Verify 100% coverage |
| **Developer** | Developer | Implement + mark DEV |
| **Tester** | Tester | Test + mark TEST |
| **QA Explorer** | Exploratory QA | Explore + mark QA |

---

## Example: Before vs After

### Before HQVF (Frustration)

```
Story: "Create user modification form"
→ DEV makes an inline form
→ USER wanted a MODAL
→ Redo everything
→ Time wasted, frustration
```

### After HQVF (Clarity)

```
UC-001 explicitly states:
  "Then a modal popup appears centered"
  V-001-1: "Modal visible and centered" ☐

→ Impossible to forget the modal
→ It's in the CONTRACT
→ Approved BEFORE development
```

---

## Configuration

```yaml
hqvf:
  enabled: true
  require_approval: true
  minimum_coverage:
    dev: 100
    test: 90
    qa: 80
  gate_blocking: true
```

---

## Why HQVF is Unique

| Framework | Acceptance Criteria | Verifiable | Triple-Check |
|-----------|---------------------|------------|--------------|
| Jira | Free text | No | No |
| Azure DevOps | Acceptance tests | Partial | No |
| CrewAI | None | No | No |
| LangChain | None | No | No |
| **Harmony** | **UCV** | **Yes** | **DEV+TEST+QA** |

**HQVF is exclusive to Harmony.**

---

## UCV Types

UCVs are classified into 3 types for complete coverage:

| Type | Description | Priority |
|------|-------------|----------|
| **Fonctionnel** | Happy path, nominal behavior | P0 |
| **Edge Case** | Limits, errors, exceptions | P1 |
| **Non-fonctionnel** | Performance, security, accessibility | P1/P2 |

**[Complete UCV Types Guide →](../docs/ucv-types.md)**
