# Workflow: Solutioning (Phase 3)

> **Design how to build what was planned.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-SOLUTIONING |
| **Phase** | 3 - Solutioning |
| **Primary Agents** | Architect, AI Architect, SM (Scrum Master) |
| **Prerequisite** | PRD approved |

---

## Purpose

The Solutioning workflow designs the technical solution:
- Architecture decisions
- Technology choices
- Story breakdown
- UCV creation

---

## Trigger

```yaml
triggers:
  - command: "start solutioning"
  - condition: "phase 2 complete AND prd approved"
  - event: "phase_transition from 2 to 3"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    SOLUTIONING WORKFLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: Approved PRD + Epics                                    │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Architecture Design         │                       │
│  │ Agent: Architect (+ AI Architect if AI)     │                       │
│  │ • High-level architecture            │                       │
│  │ • Component breakdown                │                       │
│  │ • Integration points                 │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Technology Decisions        │                       │
│  │ Agent: Architect                     │                       │
│  │ • Evaluate options                   │                       │
│  │ • Create ADRs                        │                       │
│  │ • Document trade-offs                │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Story Breakdown             │                       │
│  │ Agent: SM                            │                       │
│  │ • Break epics into stories           │                       │
│  │ • Define acceptance criteria         │                       │
│  │ • Estimate complexity                │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: UCV Creation                │                       │
│  │ Agent: UCV Writer                         │                       │
│  │ • Create UCVs for each story         │                       │
│  │ • Write Gherkin scenarios            │                       │
│  │ • Define verifications               │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: Compliance Review           │                       │
│  │ Agents: Security, RGPD, A11y        │                       │
│  │ • Security audit (if needed)         │                       │
│  │ • RGPD compliance (if data)          │                       │
│  │ • Accessibility (if UI)              │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ GATE: Ready for Implementation?     │                       │
│  │ • Architecture approved              │                       │
│  │ • Stories ready                      │                       │
│  │ • UCVs approved                      │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│         READY            NOT READY                              │
│            │                 │                                  │
│            ▼                 └──► Return to relevant step       │
│         COMPLETE                                                │
│            │                                                    │
│            ▼                                                    │
│  Advance to Phase 4 (Implementation)                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Architecture Design

**Agent:** Architect, AI Architect (if AI system)

**Activities:**
- Design high-level architecture
- Define components and their responsibilities
- Identify integration points
- Create architecture diagrams

**Diagram Types:**
- System context diagram
- Container diagram
- Component diagram
- Sequence diagrams (key flows)

**Output:** Architecture document

---

### Step 2: Technology Decisions

**Agent:** Architect

**Activities:**
- Evaluate technology options
- Make key decisions
- Document in ADRs

**ADR for each decision:**
- Database choice
- Framework selection
- Authentication approach
- Hosting/deployment
- Key libraries

**Template:** `templates/adr.md`

**Output:** ADR documents

---

### Step 3: Story Breakdown

**Agent:** SM (Scrum Master)

**Activities:**
- Break each epic into user stories
- Write clear acceptance criteria
- Assign complexity estimates
- Define dependencies

**Story Sizing:**
| Size | Complexity | Typical Duration |
|------|------------|------------------|
| XS | Trivial | Hours |
| S | Simple | 1 day |
| M | Moderate | 2-3 days |
| L | Complex | 1 week |
| XL | Very complex | Split required |

**Template:** `templates/story.md`

**Output:** Story files

---

### Step 4: UCV Creation

**Agent:** UCV Writer

**Activities:**
- Create UCV for each story
- Write Gherkin scenarios
- Define specific verifications
- Include edge cases

**Template:** `templates/ucv.md`

**Output:** UCV files

---

### Step 5: Compliance Review

**Agents:** Security, RGPD, Accessibility (as needed)

**Activities:**
- Security audit if sensitive data/operations
- RGPD review if personal data
- Accessibility review if UI components

**Output:** Compliance notes in stories

---

## Gate: Implementation Readiness

**Readiness Criteria:**
- [ ] Architecture document approved
- [ ] Key ADRs documented
- [ ] All stories for first sprint created
- [ ] UCVs created and approved
- [ ] Compliance review complete (if applicable)

**Actions:**
- If ready → Advance to Phase 4
- If not ready → Complete missing items

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| Architecture Doc | `docs/architecture/architecture.md` | Required |
| ADRs | `docs/architecture/adr/ADR-XXX.md` | Required |
| Stories | `.harmony/local/backlog/stories/STORY-XXX.md` | Required |
| UCVs | `.harmony/local/backlog/stories/STORY-XXX-UCV.md` | Required |

---

## Success Criteria

- [ ] Architecture clearly documented
- [ ] Technology decisions in ADRs
- [ ] Stories ready for development
- [ ] UCVs approved for first sprint stories

---

## Related

- [Architect Agent](../agents/architect.md)
- [AI Architect Agent 🧠](../agents/ai-architect.md)
- [Scrum Master](../agents/scrum-master.md)
- [UCV Writer Agent 📝](../specialties/ucv/branchs/writer.md)
- [Story Template](../templates/story.md)
- [UCV Template](../templates/ucv.md)
- [ADR Template](../templates/adr.md)

