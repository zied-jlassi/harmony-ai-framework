---
# HARMONY WORKFLOW FRONTMATTER - Execution Chaining
id: WF-DISCOVERY
name: Discovery Workflow
phase: 1
description: "Understand the problem space before defining solutions"

# Execution Configuration
primary_agent: analyst
agent_file: "{harmony_root}/agents/analyst.md"

# Step Chaining (Execution)
steps:
  - step: 1
    name: "Problem Elicitation"
    description: "Ask probing questions, identify pain points"
  - step: 2
    name: "Stakeholder Analysis"
    description: "Identify stakeholders, map interests"
  - step: 3
    name: "Context Gathering"
    description: "Document constraints, success metrics"
  - step: 4
    name: "Brief Creation"
    description: "Draft product brief, review with user"

# Template References
templates:
  brief: "{harmony_root}/templates/brief.md"
  stakeholders: "{harmony_root}/templates/stakeholders.md"
  personas: "{harmony_root}/templates/personas.md"

# Output Paths
outputs:
  brief: "docs/briefs/{project_name}-brief.md"
  stakeholders: "docs/briefs/stakeholders.md"
  personas: "docs/briefs/personas.md"

# Workflow Chaining
next_workflow: "planning"
next_workflow_file: "{harmony_root}/workflows/planning.md"

# Gate Requirements
gate:
  name: "Brief Approval"
  criteria:
    - "Problem clearly stated"
    - "Target users identified"
    - "Success metrics defined"
    - "Constraints documented"
    - "User explicitly approves"

# State Tracking
state:
  steps_completed: []
  current_step: null
  status: "NOT_STARTED"
---

# Workflow: Discovery (Phase 1)

> **Understand the problem space before defining solutions.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-DISCOVERY |
| **Phase** | 1 - Discovery |
| **Primary Agent** | Analyst (Analyst) |
| **Duration** | Variable |

---

## Purpose

The Discovery workflow ensures thorough understanding of:
- The problem being solved
- Who has this problem
- Why it matters now
- What success looks like

---

## Trigger

```yaml
triggers:
  - command: "start discovery"
  - command: "new project"
  - condition: "no product brief exists"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    DISCOVERY WORKFLOW                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  START                                                          │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Problem Elicitation         │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Ask probing questions              │                       │
│  │ • Identify pain points               │                       │
│  │ • Document problem statement         │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Stakeholder Analysis        │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Identify stakeholders              │                       │
│  │ • Map interests and influence        │                       │
│  │ • Document personas                  │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Context Gathering           │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Current solutions                  │                       │
│  │ • Constraints                        │                       │
│  │ • Success metrics                    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: Brief Creation              │                       │
│  │ Agent: Analyst                       │                       │
│  │ • Draft product brief                │                       │
│  │ • Review with user                   │                       │
│  │ • Finalize and approve              │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ GATE: Brief Approved?               │                       │
│  │ • User reviews brief                 │                       │
│  │ • Approves or requests changes       │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│         APPROVED          CHANGES                               │
│            │              NEEDED                                │
│            │                 │                                  │
│            ▼                 └──► Return to Step 4              │
│         COMPLETE                                                │
│            │                                                    │
│            ▼                                                    │
│  Advance to Phase 2 (Planning)                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Problem Elicitation

**Agent:** Analyst (Analyst)

**Activities:**
- Ask open-ended questions about the problem
- Identify root causes vs symptoms
- Understand impact and urgency

**Questions to Ask:**
1. What problem are we trying to solve?
2. Who is experiencing this problem?
3. How are they currently handling it?
4. What happens if we don't solve it?
5. Why is now the right time?

**Output:** Problem statement draft

---

### Step 2: Stakeholder Analysis

**Agent:** Analyst (Analyst)

**Activities:**
- Identify all stakeholders
- Map their interests and concerns
- Create user personas

**Stakeholder Matrix:**

| Stakeholder | Interest | Influence | Engagement |
|-------------|----------|-----------|------------|
| [Name] | [What they care about] | High/Med/Low | [Strategy] |

**Output:** Stakeholder analysis, Personas

---

### Step 3: Context Gathering

**Agent:** Analyst (Analyst)

**Activities:**
- Document current solutions
- Identify constraints (technical, business, regulatory)
- Define success metrics

**Constraint Categories:**
- Technical constraints
- Business constraints
- Time constraints
- Regulatory constraints
- Resource constraints

**Output:** Context document

---

### Step 4: Brief Creation

**Agent:** Analyst (Analyst)

**Activities:**
- Synthesize findings into product brief
- Use brief template
- Review with user

**Template:** `templates/brief.md`

**Output:** Product Brief (draft)

---

## Gate: Brief Approval

**Approval Criteria:**
- [ ] Problem clearly stated
- [ ] Target users identified
- [ ] Success metrics defined
- [ ] Constraints documented
- [ ] User explicitly approves

**Actions:**
- If approved → Advance to Phase 2
- If changes needed → Iterate on brief

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| Product Brief | `docs/briefs/[name]-brief.md` | Required |
| Stakeholder Analysis | `docs/briefs/stakeholders.md` | Required |
| User Personas | `docs/briefs/personas.md` | Optional |

---

## Success Criteria

- [ ] Problem statement is clear and specific
- [ ] At least one user persona defined
- [ ] Success metrics are measurable
- [ ] User has approved the brief

---

## Related

- [Analyst Agent](../agents/analyst.md)
- [Brief Template](../templates/brief.md)
- [P-007: Story-Based Development](../patterns/P-007-story-based.md)

