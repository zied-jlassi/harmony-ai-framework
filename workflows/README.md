# Harmony Workflows

> **Structured processes for consistent project execution.**

---

## Overview

Workflows are multi-step processes that guide agents through complex tasks.
They ensure consistency, quality, and proper handoffs between agents.

---

## Phase Overview with UCV Integration

```
WORKFLOW PHASES WITH UCV INTEGRATION

Phase 1: ANALYSIS
├── product-brief/          → Product Brief
└── research/               → Domain Research

Phase 2: PLANNING
├── prd/                    → PRD Document
└── ux-design/              → UX Design

Phase 3: SOLUTIONING
├── architecture/           → Architecture Document
├── epics-stories/          → Epics & Stories
│   └── ⭐ UCV GENERATION   → UCV Writer (UCV Writer) generates UCVs
│                            → User APPROVES before dev starts
└── readiness/              → Implementation Readiness Check

Phase 4: IMPLEMENTATION
├── sprint-planning/        → Sprint Planning
├── create-story/           → Story Creation from Epic
│   └── ⭐ UCV CHECK        → Story must have approved UCVs
├── dev-story/              → Story Development
│   └── ⭐ DEV MARKS UCVs   → Developer marks UCV checkboxes
├── code-review/            → Code Review
└── retrospective/          → Sprint Retrospective

Phase 5: VALIDATION (UCV-Driven)
├── testarch/               → Test Architecture
│   └── ⭐ TEA TESTS UCVs   → Tester writes tests per UCV
└── ucv-lifecycle.md        → UCV Validation
    └── ⭐ UCV VALIDATOR    → UCV Validator validates 100% coverage
```

---

## UCV Workflow (HQVF)

> **HQVF** = Harmony Quality Verification Framework
> UCVs (Use Case Verifiables) ensure complete requirements coverage

```
UCV LIFECYCLE

1. STORY CREATED (SM)
   └── Story without UCVs = NOT READY

2. UCV GENERATION (UCV Writer - UCV Writer)
   └── /harmony ucv STORY-XXX
   └── Generates: STORY-XXX-UCV.md

3. USER APPROVAL (GATE)
   └── User reviews UCVs
   └── Approves or requests changes
   └── Story status: READY only after approval

4. DEVELOPMENT (DEV)
   └── Developer implements
   └── Marks checkboxes: [x] DEV for each UCV

5. TESTING (TEA)
   └── Writes tests per UCV
   └── Marks checkboxes: [x] TEST for each UCV

6. QA VALIDATION (Exploratory QA)
   └── Exploratory testing
   └── Marks checkboxes: [x] QA for each UCV

7. FINAL VALIDATION (UCV Validator - UCV Validator)
   └── /harmony ucv-validate STORY-XXX
   └── Checks 100% coverage: DEV + TEST + QA
   └── Story status: DONE only if 100%
```

---

## Detailed Structure

```
workflows/
├── README.md                    # This file
│
├── # High-Level Phase Workflows
├── discovery.md                 # Phase 1 overview
├── planning.md                  # Phase 2 overview
├── solutioning.md               # Phase 3 overview
├── implementation.md            # Phase 4 overview
├── release.md                   # Phase 5 overview
│
├── # UCV Workflows
├── ucv-lifecycle.md             # Complete UCV lifecycle
│
├── # Detailed Phase Workflows
├── 1-analysis/
│   ├── product-brief/
│   └── research/
├── 2-planning/
│   ├── prd/
│   └── ux-design/
├── 3-solutioning/
│   ├── architecture/
│   ├── epics-stories/           # ← UCV Generation here
│   └── readiness/
├── 4-implementation/
│   ├── sprint-planning/
│   ├── create-story/            # ← UCV Check required
│   ├── dev-story/               # ← DEV marks UCVs
│   ├── code-review/
│   └── retrospective/
│
├── # Test Workflows (UCV-Driven)
├── testarch/
│   ├── atdd/                    # ← TEST marks UCVs
│   ├── test-design/
│   └── ...
│
├── # Core Workflows
├── core/
│   ├── brainstorming/
│   └── party-mode/
│
├── # Utility Workflows
├── diagrams/
├── quick-flow/
├── document-project/
├── generate-project-context/
└── workflow-status/
```

---

## Key Workflows

| Workflow | Purpose | Key Agents |
|----------|---------|------------|
| `ucv-lifecycle.md` | UCV creation to validation | UCV Writer, UCV Validator |
| `story-lifecycle.md` | Story creation to completion | SM, DEV, TEA |
| `dev-story/` | Story development with UCV marking | Developer |
| `testarch/atdd/` | Test per UCV | Tester |

---

## UCV Integration Points

| Phase | Workflow | UCV Action |
|-------|----------|------------|
| 3 | epics-stories | UCV Writer generates UCVs |
| 3 | readiness | Check UCVs approved |
| 4 | create-story | Verify UCV exists |
| 4 | dev-story | DEV marks UCVs |
| 4 | testarch/atdd | TEST writes tests per UCV |
| 4 | (Exploratory QA QA) | QA marks UCVs |
| 4 | (validation) | UCV Validator validates 100% |

---

## Related

- [UCV Template](../templates/ucv.md)
- [UCV Writer Agent](../specialties/ucv/branchs/writer.md)
- [UCV Validator Agent](../specialties/ucv/branchs/validator.md)
- [UCV Gate Rule](../rules/R-002-ucv-approval.yaml)
- [UCV Pattern](../patterns/P-008-ucv-gate.md)
