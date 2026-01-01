# Workflow: Release (Phase 5)

> **Deploy the solution and learn from the experience.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-RELEASE |
| **Phase** | 5 - Release |
| **Primary Agents** | Developer (Developer), SM (Scrum Master) |
| **Prerequisite** | All stories DONE, Tests passing |

---

## Purpose

The Release workflow handles:
- Deployment preparation
- Release execution
- Post-release monitoring
- Retrospective (REX)

---

## Trigger

```yaml
triggers:
  - command: "start release"
  - command: "deploy"
  - condition: "all sprint stories DONE"
  - event: "phase_transition from 4 to 5"
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    RELEASE WORKFLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: All Stories DONE, Tests Passing                         │
│    │                                                            │
│    ▼                                                            │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 1: Pre-Release Checklist       │                       │
│  │ Agent: Developer + SM               │                       │
│  │ • Verify all stories complete        │                       │
│  │ • Run final test suite               │                       │
│  │ • Review open issues                 │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 2: Exploratory QA Final Validation       │                       │
│  │ Agent: Exploratory QA                          │                       │
│  │ • Full exploratory session           │                       │
│  │ • Critical path validation           │                       │
│  │ • Go/No-Go decision                  │                       │
│  └──────────────────┬──────────────────┘                       │
│            ┌────────┴────────┐                                  │
│            ▼                 ▼                                  │
│           GO              NO-GO                                 │
│            │                 │                                  │
│            │                 └──► Fix blockers, retry           │
│            ▼                                                    │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 3: Release Preparation         │                       │
│  │ Agent: Developer                     │                       │
│  │ • Create release branch              │                       │
│  │ • Update version numbers             │                       │
│  │ • Generate changelog                 │                       │
│  │ • Create release notes               │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 4: Deployment                  │                       │
│  │ Agent: Developer                     │                       │
│  │ • Deploy to staging                  │                       │
│  │ • Smoke test staging                 │                       │
│  │ • Deploy to production               │                       │
│  │ • Verify production                  │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 5: Post-Release Monitoring     │                       │
│  │ Agent: Developer                     │                       │
│  │ • Monitor error rates                │                       │
│  │ • Check performance metrics          │                       │
│  │ • Validate key flows                 │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 6: Retrospective (REX)         │                       │
│  │ Agent: SM                            │                       │
│  │ • What went well                     │                       │
│  │ • What didn't go well                │                       │
│  │ • Improvements                       │                       │
│  │ • Extract patterns                   │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────┐                       │
│  │ STEP 7: Close Sprint/Epic           │                       │
│  │ Agent: SM                            │                       │
│  │ • Update sprint status               │                       │
│  │ • Close completed epics              │                       │
│  │ • Archive completed work             │                       │
│  │ • Plan next iteration                │                       │
│  └──────────────────┬──────────────────┘                       │
│                     │                                           │
│                     ▼                                           │
│  CYCLE COMPLETE - Return to Phase 1 or 4                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Steps

### Step 1: Pre-Release Checklist

**Agents:** Developer + SM

**Checklist:**
- [ ] All sprint stories status = DONE
- [ ] All tests passing (unit, integration, e2e)
- [ ] No critical bugs open
- [ ] Documentation updated
- [ ] No security vulnerabilities
- [ ] Performance acceptable

---

### Step 2: Exploratory QA Final Validation

**Agent:** Exploratory QA

**Activities:**
- Full exploratory session (60-90 min)
- Critical user paths validated
- Edge cases tested
- Accessibility verified

**Go/No-Go Decision:**
| Criteria | Status | Blocker |
|----------|--------|---------|
| Critical paths work | ✅/❌ | Yes |
| No major UX issues | ✅/❌ | Yes |
| Performance acceptable | ✅/❌ | No |
| Accessibility OK | ✅/❌ | Depends |

---

### Step 3: Release Preparation

**Agent:** Developer

**Activities:**
- Create release branch from main
- Update version numbers
- Generate changelog from commits
- Write release notes

**Version Format:** `vX.Y.Z`
- X = Major (breaking changes)
- Y = Minor (new features)
- Z = Patch (bug fixes)

---

### Step 4: Deployment

**Agent:** Developer

**Deployment Steps:**
1. Deploy to staging
2. Run smoke tests on staging
3. Wait for approval
4. Deploy to production
5. Run smoke tests on production

**Rollback Plan:**
- Keep previous version tagged
- Document rollback procedure
- Test rollback capability

---

### Step 5: Post-Release Monitoring

**Agent:** Developer

**Monitor for:**
- Error rates (should not spike)
- Response times (should not degrade)
- Key metrics (should not drop)
- User feedback (new issues)

**Duration:** At least 30 minutes active monitoring

---

### Step 6: Retrospective (REX)

**Agent:** SM (Scrum Master)

**See:** [REX Workflow](./rex.md)

**Quick Summary:**
- What went well (keep doing)
- What didn't go well (stop doing)
- What to improve (start doing)
- Patterns to preserve

---

### Step 7: Close Sprint/Epic

**Agent:** SM (Scrum Master)

**Activities:**
- Set sprint status to COMPLETED
- Close completed epics
- Archive sprint artifacts
- Calculate velocity
- Plan next iteration

---

## Outputs

| Output | Location | Status |
|--------|----------|--------|
| Release Notes | `releases/vX.Y.Z.md` | Required |
| Changelog | `CHANGELOG.md` | Required |
| REX Document | `docs/rex/REX-XXX.md` | Required |
| Velocity Report | Sprint status | Required |

---

## Success Criteria

- [ ] Deployment successful
- [ ] No critical issues in production
- [ ] Retrospective completed
- [ ] Patterns extracted and saved
- [ ] Next iteration planned

---

## Related

- [Developer Agent](../agents/developer.md)
- [SM Agent](../agents/specialists/sm.md)
- [Exploratory QA Agent 🔍](../agents/specialists/exploratory-qa.md)
- [REX Workflow](./rex.md)
- [Retrospective Template](../templates/retrospective.md)

