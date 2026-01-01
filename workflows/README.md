# Harmony Workflows

> **Structured processes for consistent project execution.**

---

## Overview

Workflows are multi-step processes that guide agents through complex tasks.
They ensure consistency, quality, and proper handoffs between agents.

---

## Available Workflows

| Workflow | Purpose | Key Agents |
|----------|---------|------------|
| `discovery.md` | Phase 1: Understand the problem | Analyst |
| `planning.md` | Phase 2: Define requirements | Analyst, SM |
| `solutioning.md` | Phase 3: Design the solution | Architect, Nova |
| `implementation.md` | Phase 4: Build the solution | Developer, Tester |
| `release.md` | Phase 5: Deploy and review | Developer, SM |
| `rex.md` | Retrospective workflow | SM, All |
| `story-lifecycle.md` | Story creation to completion | SM, Developer, Tester |
| `ucv-lifecycle.md` | UCV creation to validation | Clara, Victor |
| `incident.md` | Error handling and learning | Sentinel |
| `bug-fix.md` | Bug reproduction and fixing | Developer |
| `handoff.md` | Session continuity | Any |

---

## Workflow Structure

```
workflows/
├── README.md            # This file
├── discovery.md         # Phase 1 workflow
├── planning.md          # Phase 2 workflow
├── solutioning.md       # Phase 3 workflow
├── implementation.md    # Phase 4 workflow
├── release.md           # Phase 5 workflow
├── rex.md               # Retrospective (REX)
├── story-lifecycle.md   # Full story lifecycle
├── ucv-lifecycle.md     # UCV lifecycle
├── incident.md          # Incident handling
├── bug-fix.md           # Bug reproduction and fixing
└── handoff.md           # Session handoff
```

---

## Workflow Format

Each workflow defines:
- Trigger conditions
- Steps with agents
- Success criteria
- Error handling
- Outputs

```yaml
workflow:
  id: WF-001
  name: "Workflow Name"
  trigger: "condition or command"

steps:
  - step: 1
    name: "Step Name"
    agent: agent_name
    inputs: []
    outputs: []
    success_criteria: []

transitions:
  - from: step_1
    to: step_2
    condition: "success_criteria_met"

error_handling:
  on_failure: "action"
  retry: 3
```

---

## Phase Workflows

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE WORKFLOW OVERVIEW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 1: DISCOVERY                                             │
│  └── discovery.md                                               │
│      ├── Stakeholder interviews                                 │
│      ├── Problem analysis                                       │
│      └── Output: Product Brief                                  │
│                                                                  │
│  Phase 2: PLANNING                                              │
│  └── planning.md                                                │
│      ├── Requirements elicitation                               │
│      ├── PRD creation                                           │
│      └── Output: PRD, Roadmap                                   │
│                                                                  │
│  Phase 3: SOLUTIONING                                           │
│  └── solutioning.md                                             │
│      ├── Architecture design                                    │
│      ├── ADRs                                                   │
│      ├── Epic/Story creation                                    │
│      └── Output: Architecture, Stories                          │
│                                                                  │
│  Phase 4: IMPLEMENTATION                                        │
│  └── implementation.md                                          │
│      ├── Story execution                                        │
│      ├── Testing                                                │
│      ├── UCV validation                                         │
│      └── Output: Working code                                   │
│                                                                  │
│  Phase 5: RELEASE                                               │
│  └── release.md                                                 │
│      ├── Deployment                                             │
│      ├── Monitoring                                             │
│      ├── Retrospective                                          │
│      └── Output: Released product, REX                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Running Workflows

### Manual Invocation

```bash
# Start a workflow
"run discovery workflow"
"execute implementation workflow for STORY-042"
"run retrospective for Sprint 5"
```

### Automatic Triggers

Workflows can be triggered automatically:
- Phase change
- Story status change
- Error threshold reached
- Session handoff needed

---

## Related

- [Agents](../agents/)
- [Templates](../templates/)
- [Rules](../rules/)

