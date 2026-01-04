---
# HARMONY WORKFLOW FRONTMATTER - Execution Chaining
id: WF-PLANNING
name: Planning Workflow
phase: 2
description: "Define what to build based on discovered needs"

# Execution Configuration
primary_agents:
  - analyst
  - sm
agent_files:
  analyst: "{harmony_root}/agents/analyst.md"
  sm: "{harmony_root}/agents/scrum-master.md"

# Prerequisites (Phase Gate)
prerequisite:
  workflow: "discovery"
  gate: "Brief Approval"
  status: "APPROVED"

# Step Chaining
steps:
  - step: 1
    name: "Requirements Elicitation"
    agent: analyst
    description: "Deep dive on pain points, functional/non-functional requirements"
  - step: 2
    name: "Feature Definition"
    agent: analyst
    description: "Define feature set, map to requirements"
  - step: 3
    name: "Prioritization"
    agent: analyst
    description: "MoSCoW prioritization, define MVP scope"
  - step: 4
    name: "PRD Creation"
    agent: analyst
    description: "Draft PRD document"
  - step: 5
    name: "Roadmap Creation"
    agent: sm
    description: "Create high-level roadmap"

# Template References
templates:
  prd: "{harmony_root}/templates/prd.md"
  roadmap: "{harmony_root}/templates/roadmap.md"

# Output Paths
outputs:
  prd: "docs/prd/{project_name}-prd.md"
  roadmap: "docs/roadmap.md"

# Workflow Chaining
prev_workflow: "discovery"
prev_workflow_file: "{harmony_root}/workflows/discovery.md"
next_workflow: "solutioning"
next_workflow_file: "{harmony_root}/workflows/solutioning.md"

# Gate Requirements
gate:
  name: "PRD Approval"
  criteria:
    - "All requirements documented"
    - "Features prioritized with MoSCoW"
    - "MVP scope defined"
    - "Roadmap created"
    - "User explicitly approves PRD"

# State Tracking
state:
  steps_completed: []
  current_step: null
  status: "NOT_STARTED"
---

# Workflow: Planning (Phase 2)

> **Define what to build based on discovered needs.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-PLANNING |
| **Phase** | 2 - Planning |
| **Primary Agents** | Analyst (Analyst), SM (Scrum Master) |
| **Prerequisite** | Product Brief approved |

---

## Purpose

The Planning workflow transforms discovery insights into:
- Detailed requirements (PRD)
- Feature prioritization
- High-level roadmap
- Initial epic structure

---

## Trigger

```yaml
triggers:
  - command: "start planning"
  - condition: "phase 1 complete AND brief approved"
  - event: "phase_transition from 1 to 2"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    PLANNING WORKFLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: Approved Product Brief                                  │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Requirements Elicitation    │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Deep dive on each pain point       │                       │
│  │ • Functional requirements            │                       │
│  │ • Non-functional requirements        │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Feature Definition          │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Define feature set                 │                       │
│  │ • Map features to requirements       │                       │
│  │ • Identify dependencies              │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Prioritization              │                       │
│  │ Agent: Analyst + User               │                       │
│  │ • MoSCoW prioritization              │                       │
│  │ • Define MVP scope                   │                       │
│  │ • Identify quick wins                │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: PRD Creation                │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Draft PRD document                 │                       │
│  │ • Include all requirements           │                       │
│  │ • Define success criteria            │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: Epic Structure              │                       │
│  │ Agent: SM                            │                       │
│  │ • Group features into epics          │                       │
│  │ • Define epic dependencies           │                       │
│  │ • Create epic files                  │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ GATE: PRD Approved?                 │                       │
│  │ • User reviews PRD                   │                       │
│  │ • Validates priorities               │                       │
│  │ • Approves or requests changes       │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│         APPROVED          CHANGES                               │
│            │              NEEDED                                │
│            │                 │                                  │
│            ▼                 └──► Return to relevant step       │
│         COMPLETE                                                │
│            │                                                    │
│            ▼                                                    │
│  Advance to Phase 3 (Solutioning)                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Requirements Elicitation

**Agent:** Analyst (Analyst)

**Activities:**
- Deep dive into each problem area
- Extract functional requirements
- Identify non-functional requirements

**EARS Format for Requirements:**
| Pattern | Template |
|---------|----------|
| Ubiquitous | The system shall [action] |
| Event-Driven | WHEN [trigger] the system shall [action] |
| State-Driven | WHILE [state] the system shall [action] |
| Optional | WHERE [condition] the system shall [action] |
| Unwanted | IF [condition] THEN the system shall [action] |

**Output:** Requirements list

---

### Step 2: Feature Definition

**Agent:** Analyst (Analyst)

**Activities:**
- Define discrete features
- Map each feature to requirements
- Identify feature dependencies

**Feature Template:**
```yaml
feature:
  id: F-001
  name: "Feature Name"
  requirements:
    - REQ-001
    - REQ-002
  dependencies:
    - F-002
  priority: must_have | should_have | could_have | wont_have
```

**Output:** Feature list

---

### Step 3: Prioritization

**Agent:** Analyst (Analyst) + User

**Activities:**
- Apply MoSCoW method
- Define MVP scope
- Identify quick wins for early value

**MoSCoW Categories:**
| Priority | Meaning | Criteria |
|----------|---------|----------|
| Must Have | Critical | MVP cannot launch without |
| Should Have | Important | High value, can wait |
| Could Have | Nice to have | If time permits |
| Won't Have | Out of scope | Future consideration |

**Output:** Prioritized feature list

---

### Step 4: PRD Creation

**Agent:** Analyst (Analyst)

**Activities:**
- Draft comprehensive PRD
- Use PRD template
- Include all sections

**Template:** `templates/prd.md`

**Output:** Product Requirements Document (draft)

---

### Step 5: Epic Structure

**Agent:** SM (Scrum Master)

**Activities:**
- Group related features into epics
- Define epic dependencies
- Create epic files

**Template:** `templates/epic.md`

**Output:** Epic files

---

## Gate: PRD Approval

**Approval Criteria:**
- [ ] All requirements documented
- [ ] Features clearly defined
- [ ] Priorities agreed upon
- [ ] MVP scope defined
- [ ] User explicitly approves

**Actions:**
- If approved → Advance to Phase 3
- If changes needed → Iterate on PRD

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| PRD | `docs/prd/[name]-prd.md` | Required |
| Epic files | `.harmony/local/backlog/epics/EPIC-XXX.md` | Required |
| Roadmap | `docs/roadmap.md` | Optional |

---

## Success Criteria

- [ ] PRD complete with all sections
- [ ] At least one epic defined
- [ ] MVP scope clearly identified
- [ ] User has approved the PRD

---

## Related

- [Analyst Agent](../agents/analyst.md)
- [Scrum Master](../agents/scrum-master.md)
- [PRD Template](../templates/prd.md)
- [Epic Template](../templates/epic.md)

