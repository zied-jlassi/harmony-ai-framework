# Workflow: REX (Retrospective)

> **Retour d'Expérience - Learn from every iteration.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-REX |
| **Phase** | 5 - Release (end of iteration) |
| **Primary Agent** | SM (Bob) |
| **Participants** | All agents involved in iteration |

---

## Purpose

REX (Retour d'Expérience / Retrospective) is a structured reflection process that:
- Captures what worked well
- Identifies what didn't work
- Defines improvements for next iteration
- Extracts patterns for long-term memory

---

## Trigger

```yaml
triggers:
  - command: "run retrospective"
  - command: "start REX"
  - event: "sprint_completed"
  - event: "epic_completed"
  - event: "release_completed"
```

---

## REX Types

| Type | Scope | Duration | When |
|------|-------|----------|------|
| **Sprint REX** | Single sprint | 30-60 min | End of sprint |
| **Epic REX** | Full epic/feature | 60-90 min | Epic completion |
| **Release REX** | Major release | 90-120 min | After deployment |
| **Incident REX** | Post-mortem | 30-60 min | After incident resolution |

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    REX WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TRIGGER: Sprint/Epic/Release Complete                          │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Data Gathering              │                       │
│  │ Agent: SM                            │                       │
│  │ • Collect metrics                    │                       │
│  │ • Review completed stories           │                       │
│  │ • Gather error journal               │                       │
│  │ • Note key events                    │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: What Went Well              │                       │
│  │ • Identify successes                 │                       │
│  │ • Recognize effective practices      │                       │
│  │ • Note patterns that worked          │                       │
│  │ → Keep doing these                   │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: What Didn't Go Well         │                       │
│  │ • Identify challenges                │                       │
│  │ • Analyze root causes                │                       │
│  │ • Note anti-patterns                 │                       │
│  │ → Stop doing these                   │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: What to Improve             │                       │
│  │ • Brainstorm improvements            │                       │
│  │ • Define experiments                 │                       │
│  │ • Prioritize actions                 │                       │
│  │ → Start doing these                  │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: Extract Patterns            │                       │
│  │ Agent: Sentinel                      │                       │
│  │ • Identify reusable patterns         │                       │
│  │ • Document anti-patterns             │                       │
│  │ • Update learned-patterns.json       │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 6: Create Action Items         │                       │
│  │ • Define specific actions            │                       │
│  │ • Assign owners                      │                       │
│  │ • Set deadlines                      │                       │
│  │ • Schedule follow-up                 │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 7: Document REX                │                       │
│  │ • Create REX document                │                       │
│  │ • Use retrospective template         │                       │
│  │ • Archive for future reference       │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  REX COMPLETE - Learnings Preserved                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Data Gathering

**Agent:** SM (Bob)

**Data Sources:**
- Sprint/Epic metrics (velocity, bugs, etc.)
- Completed stories and their UCVs
- Error journal entries
- Circuit breaker history
- Session handoffs
- Key decisions made

**Metrics to Collect:**
| Metric | Source | Purpose |
|--------|--------|---------|
| Stories completed | Sprint status | Velocity |
| Bugs found | Issue tracker | Quality |
| UCV coverage | Victor reports | Verification |
| Error count | Error journal | Resilience |
| Pattern applications | Learned patterns | Learning |

---

### Step 2: What Went Well (Keep Doing)

**Focus Areas:**
- Practices that improved productivity
- Patterns that prevented errors
- Tools that helped
- Collaboration that worked
- Decisions that paid off

**Questions to Ask:**
1. What are we proud of?
2. What practices should we continue?
3. What made development smoother?
4. Which patterns proved valuable?

**Output:** List of successes with evidence

---

### Step 3: What Didn't Go Well (Stop Doing)

**Focus Areas:**
- Challenges faced
- Time wasters
- Recurring problems
- Process bottlenecks
- Decisions that backfired

**Questions to Ask:**
1. What frustrated us?
2. What caused delays?
3. What would we do differently?
4. What anti-patterns emerged?

**Output:** List of challenges with root causes

---

### Step 4: What to Improve (Start Doing)

**Focus Areas:**
- Process improvements
- Tool adoptions
- New practices to try
- Skills to develop
- Changes to implement

**Questions to Ask:**
1. What experiments should we try?
2. What's missing from our process?
3. How can we prevent past issues?
4. What would make us faster/better?

**Prioritization:**
| Impact | Effort | Priority |
|--------|--------|----------|
| High | Low | Do First |
| High | High | Plan Carefully |
| Low | Low | Quick Wins |
| Low | High | Skip |

**Output:** Prioritized improvement list

---

### Step 5: Extract Patterns

**Agent:** Sentinel

**Pattern Types:**
- **Prevention patterns**: How to avoid errors
- **Resolution patterns**: How to fix common issues
- **Process patterns**: Effective workflows
- **Anti-patterns**: What to avoid

**Pattern Format:**
```json
{
  "id": "P-LEARN-XXX",
  "type": "prevention",
  "category": "development",
  "trigger": "When X happens",
  "action": "Do Y instead",
  "confidence": 0.85,
  "source": "REX-YYYY-MM-DD",
  "applied_count": 0
}
```

**Output:** New patterns added to `learned-patterns.json`

---

### Step 6: Create Action Items

**Action Item Format:**
| Field | Description |
|-------|-------------|
| Action | Specific, actionable task |
| Owner | Who is responsible |
| Due Date | When it should be done |
| Success Criteria | How we know it's done |
| Follow-up | When to check progress |

**Example Actions:**
- "Add pre-commit hook for linting" - Developer - Next sprint
- "Create checklist for story creation" - SM - 1 week
- "Document API authentication flow" - Architect - 2 weeks

---

### Step 7: Document REX

**Agent:** SM (Bob)

**Template:** `templates/retrospective.md`

**Document Sections:**
1. Metadata (date, scope, participants)
2. Context (what was delivered)
3. What went well (with evidence)
4. What didn't go well (with root causes)
5. What to improve (with priorities)
6. Learnings to preserve (patterns)
7. Action items (with owners)
8. Follow-up plan

**Storage:** `docs/rex/REX-YYYY-MM-DD.md`

---

## Memory Integration

### Update Long-Term Memory

The REX workflow updates these memory files:
- `learned-patterns.json` - New patterns extracted
- `error-journal.json` - Patterns linked to errors
- `workflow-state.json` - Process improvements

### Knowledge Transfer

Patterns extracted during REX become available for:
- JIT context loading
- Error prevention suggestions
- Process guidance

---

## REX Facilitation Tips

**Do:**
- Focus on process, not people
- Use data to support observations
- Be specific with examples
- Generate actionable improvements
- Follow up on action items

**Don't:**
- Blame individuals
- Ignore uncomfortable topics
- Leave with vague "we should do better"
- Skip the pattern extraction
- Forget previous REX learnings

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| REX Document | `docs/rex/REX-YYYY-MM-DD.md` | Required |
| Action Items | In REX document | Required |
| Patterns | `memory/learned-patterns.json` | Required |
| Metrics | In REX document | Required |

---

## Success Criteria

- [ ] Data gathered from iteration
- [ ] What went well documented
- [ ] What didn't go well analyzed
- [ ] Improvements prioritized
- [ ] Patterns extracted and saved
- [ ] Action items assigned with owners
- [ ] REX document archived

---

## Related

- [SM Agent](../agents/specialists/sm.md)
- [Sentinel Agent](../agents/sentinel.md)
- [Retrospective Template](../templates/retrospective.md)
- [P-005: Closed-Loop Learning](../patterns/P-005-closed-loop.md)

