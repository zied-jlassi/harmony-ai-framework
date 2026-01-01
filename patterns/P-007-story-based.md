# P-007: Story-Based Development

> **No development without a story - enforced workflow discipline.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-007 |
| **Category** | Workflow |
| **Complexity** | Low |
| **Applicability** | All development |

---

## Problem

Without stories:
- Work is undocumented
- No acceptance criteria
- No traceability
- No UCV coverage
- "Cowboy coding"

---

## Solution

Enforce that all code changes must be tied to a story:

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORY-BASED DEVELOPMENT                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  USER: "implement user profile editing"                         │
│                                                                  │
│  GUARDIAN CHECK:                                                │
│  ├── Story exists? ───────────────────────────────────────┐    │
│  │                                                        │    │
│  │   ❌ NO                                    ✅ YES      │    │
│  │   │                                           │        │    │
│  │   ▼                                           ▼        │    │
│  │   ┌─────────────────┐              ┌─────────────────┐│    │
│  │   │ BLOCK/WARN      │              │ UCV approved?   ││    │
│  │   │                 │              │                 ││    │
│  │   │ "Create story   │              │ ❌ NO   ✅ YES  ││    │
│  │   │  first"         │              │   │       │     ││    │
│  │   └─────────────────┘              │   ▼       ▼     ││    │
│  │                                    │ BLOCK   ALLOW   ││    │
│  │                                    └─────────────────┘│    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  RESULT: Only proceed if story + UCV exist and approved        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Story Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORY LIFECYCLE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────┐                                                     │
│  │ DRAFT  │  ← SM creates story from epic/request              │
│  └───┬────┘                                                     │
│      │                                                          │
│      ▼                                                          │
│  ┌────────┐                                                     │
│  │ UCV    │  ← UCV Writer creates use case verifications            │
│  │PENDING │                                                     │
│  └───┬────┘                                                     │
│      │                                                          │
│      ▼                                                          │
│  ┌────────┐                                                     │
│  │  UCV   │  ← User approves UCVs                              │
│  │APPROVED│                                                     │
│  └───┬────┘                                                     │
│      │                                                          │
│      ▼                                                          │
│  ┌────────┐                                                     │
│  │  TODO  │  ← Ready for development                           │
│  └───┬────┘                                                     │
│      │                                                          │
│      ▼                                                          │
│  ┌────────────┐                                                 │
│  │IN_PROGRESS │  ← Developer working                           │
│  └─────┬──────┘                                                 │
│        │                                                        │
│        ├── Dev marks verifications [x] dev                     │
│        ├── Tester marks [x] test                               │
│        └── Exploratory QA marks [x] qa                                   │
│        │                                                        │
│        ▼                                                        │
│  ┌────────┐                                                     │
│  │ REVIEW │  ← UCV Validator validates 100% coverage                  │
│  └───┬────┘                                                     │
│      │                                                          │
│      ▼                                                          │
│  ┌────────┐                                                     │
│  │  DONE  │  ← SM closes story                                 │
│  └────────┘                                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Story Template

```markdown
# STORY-[NUMBER]: [Title]

## Metadata
- **Epic**: EPIC-[NUMBER]
- **Status**: TODO | IN_PROGRESS | DONE
- **Priority**: HIGH | MEDIUM | LOW
- **Sprint**: Sprint [NUMBER]

## Description
As a [role],
I want to [action],
So that [benefit].

## Acceptance Criteria
1. [Criterion 1]
2. [Criterion 2]

## UCV Reference
- File: `STORY-[NUMBER]-UCV.md`
- Status: PENDING | APPROVED
```

---

## Enforcement Modes

### WARN Mode

```
🛡️ GUARDIAN CHECKPOINT - WARNING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ No active story detected

RECOMMENDATION:
Create a story before implementing:
  "create story for [your feature]"

Continuing anyway (WARN mode)...
```

### BLOCK Mode

```
🛡️ GUARDIAN CHECKPOINT - VIOLATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚫 BLOCKED: Code modification without active story

REQUIRED ACTIONS:
1. Create or activate a story first
2. Ensure UCV is approved
3. Try again

Commands:
  "create story for [feature]"
  "activate STORY-XXX"
```

---

## Implementation

```typescript
interface GuardianConfig {
  requireStory: boolean;
  requireUCV: boolean;
  mode: 'warn' | 'block';
}

function checkStoryRequirement(
  config: GuardianConfig,
  context: WorkflowState
): CheckResult {
  if (!config.requireStory) {
    return { allowed: true };
  }

  if (!context.activeStory) {
    return {
      allowed: config.mode === 'warn',
      message: 'No active story',
      suggestion: 'Create a story first'
    };
  }

  if (config.requireUCV && !context.activeStory.ucvApproved) {
    return {
      allowed: config.mode === 'warn',
      message: 'UCV not approved',
      suggestion: 'Get UCV approval before development'
    };
  }

  return { allowed: true };
}
```

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Traceability** | All changes linked to stories |
| **Quality** | UCVs define acceptance |
| **Documentation** | Stories document intent |
| **Metrics** | Track velocity, completion |

---

## Related Patterns

- [P-008: UCV Quality Gate](P-008-ucv-gate.md)
- [P-006: Intent Detection](P-006-intent-detection.md)

