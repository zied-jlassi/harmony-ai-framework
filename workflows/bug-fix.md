# Workflow: Bug Fix

> **Structured approach to fixing reported bugs.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Workflow ID** | WF-BUG-FIX |
| **Phase** | 4 (Implementation) |
| **Primary Agent** | Developer |
| **Trigger** | Bug reported |

---

## Purpose

The Bug Fix workflow provides a structured approach to:
- Reproduce and understand reported bugs
- Identify root cause (not just symptoms)
- Implement targeted fixes
- Verify fix without regressions
- Document for future prevention

---

## Difference: Bug-Fix vs Incident

| Aspect | Bug-Fix | Incident |
|--------|---------|----------|
| **Trigger** | User reports issue | System detects error |
| **Source** | Feature doesn't work as expected | Operation failed |
| **Agent** | Developer | Sentinel |
| **Output** | Code fix | Pattern + prevention |
| **Example** | "Login button doesn't work" | "TypeError in login.ts:42" |

---

## Trigger

```yaml
triggers:
  - user_report: "bug"
  - user_report: "doesn't work"
  - user_report: "broken"
  - command: "fix bug"
  - command: "bugfix"
  - intent: FIX
```

---

## Flow Diagram

```
+-------------------------------------------------------------------+
|                    BUG-FIX WORKFLOW                                  |
+-------------------------------------------------------------------+
|                                                                   |
|  BUG REPORTED                                                     |
|    |                                                              |
|    v                                                              |
|  +---------------------------------------------+                  |
|  | STEP 1: Story/Ticket Creation               |                  |
|  | Agent: SM (Scrum Master)                             |                  |
|  |                                              |                  |
|  | - Create BUGFIX-XXX story                    |                  |
|  | - Document reported behavior                 |                  |
|  | - Set priority based on severity             |                  |
|  | - Assign to sprint                           |                  |
|  +----------------------+----------------------+                  |
|                         |                                          |
|                         v                                          |
|  +---------------------------------------------+                  |
|  | STEP 2: Reproduction                        |                  |
|  | Agent: Developer                            |                  |
|  |                                              |                  |
|  | - Follow reported steps                      |                  |
|  | - Verify bug exists                          |                  |
|  | - Document exact reproduction steps          |                  |
|  | - Capture error messages/logs                |                  |
|  +----------------------+----------------------+                  |
|             |                    |                                 |
|             v                    v                                 |
|       REPRODUCED          NOT REPRODUCED                           |
|             |                    |                                 |
|             |                    +---> Request more info from user |
|             v                                                      |
|  +---------------------------------------------+                  |
|  | STEP 3: Root Cause Analysis                 |                  |
|  | Agent: Developer                            |                  |
|  |                                              |                  |
|  | - Debug and trace code path                  |                  |
|  | - Identify actual cause (not symptom)        |                  |
|  | - Document root cause                        |                  |
|  | - Check for related issues                   |                  |
|  +----------------------+----------------------+                  |
|                         |                                          |
|                         v                                          |
|  +---------------------------------------------+                  |
|  | STEP 4: Fix Implementation                  |                  |
|  | Agent: Developer                            |                  |
|  |                                              |                  |
|  | - Write failing test FIRST (TDD red)         |                  |
|  | - Implement minimal fix                      |                  |
|  | - Make test pass (TDD green)                 |                  |
|  | - Refactor if needed                         |                  |
|  +----------------------+----------------------+                  |
|                         |                                          |
|                         v                                          |
|  +---------------------------------------------+                  |
|  | STEP 5: Verification                        |                  |
|  | Agent: Developer + Tester                   |                  |
|  |                                              |                  |
|  | - Run all related tests                      |                  |
|  | - Run regression tests                       |                  |
|  | - Verify fix in browser/app                  |                  |
|  | - Check for side effects                     |                  |
|  +----------------------+----------------------+                  |
|             |                    |                                 |
|             v                    v                                 |
|         VERIFIED            REGRESSIONS                            |
|             |                    |                                 |
|             |                    +---> Return to Step 4            |
|             v                                                      |
|  +---------------------------------------------+                  |
|  | STEP 6: Documentation                       |                  |
|  | Agent: Developer                            |                  |
|  |                                              |                  |
|  | - Update story with fix details              |                  |
|  | - Document root cause for future ref         |                  |
|  | - Add to ops-issues if relevant              |                  |
|  | - Commit with bug reference                  |                  |
|  +----------------------+----------------------+                  |
|                         |                                          |
|                         v                                          |
|  BUG FIXED - Story marked DONE                                    |
|                                                                   |
+-------------------------------------------------------------------+
```

---

## Steps Detail

### Step 1: Story/Ticket Creation

**Agent:** SM (Scrum Master)

**Story Format:**
```markdown
# BUGFIX-{id}: {short_description}

## Reported Behavior
{what_user_reported}

## Expected Behavior
{what_should_happen}

## Severity
- [ ] Critical (app unusable, data loss)
- [ ] High (major feature broken)
- [ ] Medium (feature impaired, workaround exists)
- [ ] Low (minor issue, cosmetic)

## Reported By
{user_or_source}

## Reproduction Steps (if provided)
1. {step_1}
2. {step_2}
3. {step_3}
```

---

### Step 2: Reproduction

**Agent:** Developer

**Checklist:**
```markdown
## Reproduction Attempt

- [ ] Followed reported steps exactly
- [ ] Bug reproduced: YES / NO
- [ ] Environment: {dev/staging/prod}
- [ ] Browser/Device: {details}

## Reproduction Steps (verified)
1. {verified_step_1}
2. {verified_step_2}
3. {verified_step_3}

## Error Messages
{exact_error_or_behavior}

## Screenshots/Logs
{attached}
```

**If NOT reproduced:**
- Request additional info from reporter
- Check different environments
- Check different user roles
- Check data conditions

---

### Step 3: Root Cause Analysis

**Agent:** Developer

**Analysis Template:**
```markdown
## Root Cause Analysis

### Symptom
{what_user_sees}

### Actual Cause
{technical_root_cause}

### Code Location
{file}:{line_number}

### Why It Happened
{explanation}

### Related Code
- {related_file_1}
- {related_file_2}

### Other Occurrences
- [ ] Check if same bug exists elsewhere
- Found in: {list}
```

---

### Step 4: Fix Implementation

**Agent:** Developer

**TDD Approach (MANDATORY):**

```markdown
## Fix Implementation

### 1. Failing Test First
```typescript
// test/bugfix-XXX.spec.ts
it('should [expected behavior]', () => {
  // Arrange
  // ...
  // Act
  // ...
  // Assert - this should FAIL before fix
});
```

### 2. Minimal Fix
{description_of_fix}

### 3. Test Passes
[ ] Test now passes

### 4. Refactor
[ ] Code cleaned up (if needed)
```

---

### Step 5: Verification

**Agents:** Developer + Tester

**Verification Checklist:**
```markdown
## Verification

### Direct Fix
- [ ] Original bug no longer occurs
- [ ] Failing test now passes

### Regression Check
- [ ] Related tests pass
- [ ] Full test suite passes
- [ ] No new warnings

### Manual Verification
- [ ] Tested in browser/app
- [ ] Tested different scenarios
- [ ] No side effects observed

### Build Check
- [ ] Build succeeds
- [ ] No type errors
- [ ] No lint errors
```

---

### Step 6: Documentation

**Agent:** Developer

**Commit Message Format:**
```
fix(module): {short_description}

BUGFIX-{id}

Root cause: {brief_explanation}

- {change_1}
- {change_2}

Test: {test_name}
```

**Story Update:**
```markdown
## Resolution

### Fix Applied
{description}

### Root Cause
{explanation}

### Prevention
{how_to_prevent_in_future}

### Related Commits
- {commit_hash}
```

---

## Priority Matrix

| Severity | Response Time | Fix Deadline |
|----------|---------------|--------------|
| Critical | Immediate | Same day |
| High | < 4 hours | End of sprint |
| Medium | < 24 hours | Next sprint |
| Low | When available | Backlog |

---

## Bug Categories

| Category | Examples |
|----------|----------|
| **Functional** | Feature doesn't work |
| **UI/UX** | Display issues, layout broken |
| **Performance** | Slow, unresponsive |
| **Security** | Vulnerability found |
| **Data** | Wrong data, corruption |
| **Integration** | API issues, third-party |

---

## Outputs

| Output | Location | Required |
|--------|----------|----------|
| Bug Story | `docs/backlog/stories/BUGFIX-XXX.md` | Yes |
| Fix Commit | Git history | Yes |
| Test Case | `test/` directory | Yes |
| Ops Issue | `docs/operations/issues/` | If systemic |

---

## Success Criteria

- [ ] Bug reproduced and documented
- [ ] Root cause identified (not just symptom)
- [ ] Test written BEFORE fix
- [ ] Fix implemented and test passes
- [ ] No regressions introduced
- [ ] Documentation updated
- [ ] Story marked DONE

---

## Related

- [Developer Agent](../agents/developer.md)
- [Incident Workflow](incident.md) - For system errors
- [Story Lifecycle](story-lifecycle.md)
- [P-004: Circuit Breaker](../patterns/P-004-circuit-breaker.md)
