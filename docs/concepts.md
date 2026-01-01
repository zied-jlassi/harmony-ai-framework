# Core Concepts

Understanding the philosophy and architecture behind Harmony Framework.

---

## Philosophy

### The Fundamental Principle

> **"Improvement through Prompts and Memory, not model weight modification."**

Harmony is built on the belief that:

1. **The LLM remains intact** - No fine-tuning required
2. **Intelligence emerges from architecture** - Structure creates capability
3. **Performance is guaranteed** - No degradation from modifications
4. **Learning is persistent** - Knowledge survives sessions

This means Harmony works with ANY LLM provider (Claude, GPT, Gemini, local models) without modification.

---

## The Three Pillars

### 1. Guardian Protocol

The Guardian is the **workflow protector**. It ensures the right agent handles the right task at the right time.

```
┌─────────────────────────────────────────────────────────────────┐
│                    GUARDIAN PROTOCOL                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: User message                                            │
│         "develop the login feature"                             │
│                                                                  │
│  STEP 1: Intent Detection                                       │
│          Keywords: "develop" → Intent: IMPLEMENT                │
│                                                                  │
│  STEP 2: Context Detection                                      │
│          Keywords: "login" → Context: Authentication            │
│                                                                  │
│  STEP 3: Prerequisites Check                                    │
│          ├── Phase 4? ✅                                        │
│          ├── Story exists? ✅                                   │
│          └── UCV approved? ✅                                   │
│                                                                  │
│  STEP 4: Agent Routing                                          │
│          Route to: Developer (Developer)                           │
│                                                                  │
│  STEP 5: Context Activation                                     │
│          Set active_story: STORY-XXX                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Intent Types

| Intent | Trigger Keywords | Target Agent |
|--------|-----------------|--------------|
| IMPLEMENT | develop, code, implement, build | Developer |
| FIX | fix, bug, error, debug, repair | Developer |
| PLAN_STORY | story, sprint, backlog, plan | SM |
| TEST | test, TDD, coverage | Tester |
| EXPLORE_QA | explore, Exploratory QA, QA, UX check | Exploratory QA |
| ANALYZE | analyze, requirement, need | Analyst |
| DESIGN | architecture, design, ADR | Architect |
| CREATE_UCV | UCV, use case, verification | UCV Writer |
| VALIDATE_UCV | validate UCV, verify | UCV Validator |
| SECURITY | security audit, pentest | Security Agent |
| COMPLIANCE | RGPD, GDPR, privacy | RGPD Agent |
| ACCESSIBILITY | a11y, WCAG, RGAA | Accessibility Agent |

---

### 2. Sentinel System

The Sentinel is the **memory guardian**. It remembers errors and prevents repeating them.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SENTINEL SYSTEM                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │  ERROR JOURNAL  │    │ CIRCUIT BREAKER │                    │
│  ├─────────────────┤    ├─────────────────┤                    │
│  │ ERR-001: ...    │    │ State: CLOSED   │                    │
│  │ ERR-002: ...    │    │ Failures: 0/3   │                    │
│  │ ERR-003: ...    │    │ Last: success   │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ LEARNED PATTERNS│    │  ANTI-PATTERNS  │                    │
│  ├─────────────────┤    ├─────────────────┤                    │
│  │ P-001: Always...│    │ AP-001: Never...│                    │
│  │ P-002: Use...   │    │ AP-002: Avoid...│                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Circuit Breaker States

| State | Meaning | Action |
|-------|---------|--------|
| **CLOSED** | Normal operation | Allow all operations |
| **OPEN** | 3+ failures detected | Block operations, require diagnosis |
| **HALF-OPEN** | Testing recovery | Allow one operation to test |

#### Error Journal Structure

```json
{
  "id": "ERR-001",
  "timestamp": "2025-01-15T10:30:00Z",
  "category": "typescript",
  "severity": "high",
  "title": "Import path not found",
  "context": {
    "module": "backend",
    "file": "src/auth/auth.service.ts"
  },
  "symptom": "Cannot find module '@/shared/utils'",
  "root_cause": "tsconfig.json missing paths configuration",
  "solution": "Add paths: {'@/*': ['*']} to tsconfig.json",
  "prevention_rule": "Always check tsconfig.json when seeing @ import errors",
  "tags": ["typescript", "imports", "config"]
}
```

---

### 3. HQVF (Harmony Quality Verification Framework)

HQVF ensures quality through **verifiable use cases** (UCV).

```
┌─────────────────────────────────────────────────────────────────┐
│                    HQVF WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 3: Story Created                                         │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │  UCV Writer (Writer) │ ─── Creates STORY-XXX-UCV.md              │
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
│           ├──► Tester marks:    [x] test                        │
│           └──► Exploratory QA marks:      [x] qa                          │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │ UCV Validator (Validator)│ ─── Verifies 100% coverage              │
│  └─────────────────┘                                            │
│           │                                                      │
│           ▼                                                      │
│  Story DONE (100% verified)                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### UCV Structure

```yaml
story_id: STORY-042
title: "User Profile Update"
status: APPROVED

use_cases:
  - id: UC-001
    title: "Open edit modal"
    gherkin: |
      Given I am logged in as a user
      And I am on my profile page
      When I click the "Edit" button
      Then a modal should appear centered on screen
      And the form should be pre-filled with my data

    verifications:
      - id: V-001-1
        description: "Modal appears centered"
        dev: false    # ☐ Developer
        test: false   # ☐ Tester
        qa: false     # ☐ Exploratory QA

      - id: V-001-2
        description: "Form pre-filled with user data"
        dev: false
        test: false
        qa: false

summary:
  total_use_cases: 5
  total_verifications: 15
  coverage_target: 100%
```

---

## Memory Architecture

### 3-Tier Memory Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    3-TIER MEMORY                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TIER 1: WORKING MEMORY                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Location: In-context window                              │   │
│  │ Size: ~2000 tokens (10-20% of context)                   │   │
│  │ Persistence: Current message only                        │   │
│  │ Content:                                                 │   │
│  │   • Current task definition                              │   │
│  │   • Active agent persona                                 │   │
│  │   • Immediate constraints                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ▲                                     │
│                           │ Refresh every message               │
│                           ▼                                     │
│  TIER 2: SESSION MEMORY                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Location: External storage (compressed)                  │   │
│  │ Size: Unlimited                                          │   │
│  │ Persistence: Current session                             │   │
│  │ Content:                                                 │   │
│  │   • Conversation history (summarized)                    │   │
│  │   • Recent decisions                                     │   │
│  │   • Current sprint context                               │   │
│  │ Compression: Auto-summarize after 10 messages            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ▲                                     │
│                           │ Semantic retrieval                  │
│                           ▼                                     │
│  TIER 3: LONG-TERM MEMORY                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Location: Persistent storage (JSON files)                │   │
│  │ Size: Unlimited                                          │   │
│  │ Persistence: Permanent (versioned)                       │   │
│  │ Content:                                                 │   │
│  │   • Error journal                                        │   │
│  │   • Learned patterns                                     │   │
│  │   • User preferences                                     │   │
│  │   • Architecture decisions                               │   │
│  │   • Anti-patterns                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Agent Architecture

### Agent Definition Structure

Each agent in Harmony follows this structure:

```yaml
# Agent Definition
name: "developer"
displayName: "Developer"
persona: "Developer"
description: "Implements features and fixes bugs"
version: "1.0"

# Activation
phase: [4]                    # Which phases this agent can be invoked
triggers:                     # Keywords for intent detection
  - "develop"
  - "implement"
  - "code"
  - "build"

# Capabilities
capabilities:
  - "Write production code"
  - "Implement features"
  - "Fix bugs"
  - "Refactor code"
  - "Mark UCV verifications"

# Restrictions
restrictions:
  - "Cannot create stories (SM's job)"
  - "Cannot design architecture (Architect's job)"
  - "Cannot approve UCVs (User's job)"

# Prerequisites
prerequisites:
  - story_exists: true
  - ucv_approved: true

# Handoff Protocol
handoff:
  to: ["tester", "exploratory-qa"]
  format: |
    HANDOFF: Developer → {destination}
    Story: {story_id}
    Changes: {summary}
    Tests needed: {list}
```

### Agent Categories

| Category | Agents | Purpose |
|----------|--------|---------|
| **Core** | Guardian, Sentinel, Analyst, Architect, Developer, Tester | Essential development workflow |
| **Specialists** | AI Architect, Exploratory QA, UCV Writer, UCV Validator | Advanced capabilities |
| **Compliance** | Security, RGPD, Accessibility, Pentest | Regulatory and quality |
| **AI Sub-agents** | Riley, Milo, Oscar, Olivia, Grace, Sage | AI/LLM specialization |

---

## Workflow Phases

### Phase Progression

```
 ┌────────────────────────────────────────────────────────────────┐
 │                                                                │
 │  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   │
 │  │ PHASE 1  │──►│ PHASE 2  │──►│ PHASE 3  │──►│ PHASE 4  │   │
 │  │Discovery │   │ Planning │   │Solutioning   │Implementation│
 │  └──────────┘   └──────────┘   └──────────┘   └──────────┘   │
 │       │              │              │              │          │
 │       ▼              ▼              ▼              ▼          │
 │   Brief          PRD           Architecture    Code          │
 │   Approved       Approved      + Stories       + Tests       │
 │                                + UCVs          + QA          │
 │                                                               │
 │  ┌─────────────────────────────────────────────────────────┐ │
 │  │                    GATES                                 │ │
 │  ├─────────────────────────────────────────────────────────┤ │
 │  │ 1→2: Brief approved by stakeholders                     │ │
 │  │ 2→3: PRD approved, roadmap defined                      │ │
 │  │ 3→4: Architecture approved, stories created, UCVs ready │ │
 │  │ 4→5: All UCVs validated, Exploratory QA approved                  │ │
 │  └─────────────────────────────────────────────────────────┘ │
 │                                                                │
 └────────────────────────────────────────────────────────────────┘
```

### Phase Details

| Phase | Name | Purpose | Key Artifacts | Agents |
|-------|------|---------|---------------|--------|
| 1 | Discovery | Understanding needs | Brief | Analyst |
| 2 | Planning | Defining scope | PRD, Roadmap | Analyst, PM |
| 3 | Solutioning | Designing solution | Architecture, Stories, UCVs | Architect, SM, UX, UCV Writer |
| 4 | Implementation | Building product | Code, Tests, Validations | Developer, Tester, Exploratory QA, UCV Validator |
| 5 | Release | Deploying product | Deployment, Monitoring | DevOps, Olivia |

---

## Closed-Loop Learning

### The Learning Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLOSED-LOOP LEARNING                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│                    ┌─────────────┐                              │
│                    │   EXECUTE   │                              │
│                    │  (Action)   │                              │
│                    └──────┬──────┘                              │
│                           │                                      │
│            ┌──────────────┼──────────────┐                      │
│            ▼              ▼              ▼                      │
│       ┌────────┐    ┌────────┐    ┌────────┐                   │
│       │SUCCESS │    │ FAILURE│    │ PARTIAL│                   │
│       └───┬────┘    └───┬────┘    └───┬────┘                   │
│           │             │             │                         │
│           ▼             ▼             ▼                         │
│    ┌─────────────────────────────────────────┐                 │
│    │              EVALUATE                    │                 │
│    │  • What worked?                          │                 │
│    │  • What failed?                          │                 │
│    │  • Why?                                  │                 │
│    └─────────────────┬───────────────────────┘                 │
│                      │                                          │
│                      ▼                                          │
│    ┌─────────────────────────────────────────┐                 │
│    │              REFLECT                     │                 │
│    │  • Extract pattern/anti-pattern          │                 │
│    │  • Document in error journal             │                 │
│    │  • Create prevention rule                │                 │
│    └─────────────────┬───────────────────────┘                 │
│                      │                                          │
│                      ▼                                          │
│    ┌─────────────────────────────────────────┐                 │
│    │               STORE                      │                 │
│    │  • Save to long-term memory              │                 │
│    │  • Update pattern library                │                 │
│    │  • Commit to version control             │                 │
│    └─────────────────┬───────────────────────┘                 │
│                      │                                          │
│                      ▼                                          │
│                 NEXT EXECUTION                                  │
│          (Now informed by learning)                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Next Steps

- [Agents Guide](agents/README.md) - Deep dive into each agent
- [Patterns Reference](patterns/README.md) - Design patterns library
- [Rules Reference](rules/README.md) - Rules engine documentation
- [API Reference](api-reference.md) - CLI and programmatic API

