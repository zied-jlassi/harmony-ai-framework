# Implementation Methodology

> Best practices for autonomous code implementation with quality gates.

---

## Step 1: Get Your Bearings (MANDATORY)

Before implementing, understand the current state:

```bash
# 1. Current directory
pwd && ls -la

# 2. Find implementation plan
cat .harmony/memory/working.json

# 3. Recent git history
git log --oneline -10

# 4. Check current story progress
cat .harmony/memory/working.json | jq '.current_story'
```

---

## Step 2: Pre-Implementation Checklist

**CRITICAL**: Before writing any code, generate a predictive bug prevention checklist.

### Checklist Categories

1. **Predicted Issues** based on work type:
   - API work → CORS, auth middleware, validation
   - Frontend → Loading states, error boundaries, accessibility
   - Database → Migrations, indexes, N+1 queries
   - Security → Input validation, auth, secrets

2. **Known Gotchas** from project memory:
   - Past failures in similar contexts
   - Project-specific pitfalls

3. **Patterns to Follow**:
   - Reference files to study
   - Code conventions to match

### Document Your Review

```markdown
## Pre-Implementation Checklist Review

**Subtask:** [subtask-id]

**Predicted Issues Reviewed:**
- [Issue 1]: Will prevent by [action]
- [Issue 2]: Will prevent by [action]

**Reference Files to Study:**
- [file 1]: Will check for [pattern to follow]

**Ready to implement:** YES
```

---

## Step 3: Implementation Rules

1. **Match patterns exactly** - Use the same style as reference files
2. **Modify only listed files** - Stay within scope
3. **One service only** - Each subtask is scoped to one service
4. **No console errors** - Clean implementation
5. **Verify your location** - Always `pwd` before file operations

### Path Confusion Prevention (Monorepos)

```bash
# WRONG - Path gets doubled after cd
cd ./apps/frontend
git add apps/frontend/src/file.ts  # Looks for apps/frontend/apps/frontend/...

# CORRECT - Use relative path from current directory
cd ./apps/frontend
pwd  # Shows: /path/to/project/apps/frontend
git add src/file.ts  # Correct!
```

---

## Step 4: Using Subagents (Task Tool)

### When to Use Subagents

- Multiple independent files to implement
- Research/exploration of different codebase parts
- Running different verifications in parallel
- Large subtasks that can be logically divided

### When NOT to Use

- Sequential dependencies between tasks
- Small, quick tasks
- Tasks requiring shared context

### Best Practices

```markdown
Use the Task tool to spawn subagents:
- "Implement the database schema changes in models.py"
- "Research how authentication is handled in the existing codebase"
- "Run tests for the API endpoints while I work on the frontend"

Rules:
- Let Claude decide the parallelism level
- Subagents work best on disjoint tasks (different files/modules)
- Each subagent has its own context window
- Up to 10 concurrent subagents possible
```

---

## Step 5: Self-Critique (MANDATORY)

**Before marking a subtask complete, run through the self-critique checklist.**

### Code Quality Check

**Pattern Adherence:**
- [ ] Follows patterns from reference files exactly
- [ ] Variable naming matches codebase conventions
- [ ] Imports organized correctly
- [ ] Code style consistent with existing files

**Error Handling:**
- [ ] Try-catch blocks where operations can fail
- [ ] Meaningful error messages
- [ ] Proper error propagation
- [ ] Edge cases considered

**Code Cleanliness:**
- [ ] No console.log/print statements for debugging
- [ ] No commented-out code blocks
- [ ] No TODO comments without context
- [ ] No hardcoded values that should be configurable

**Best Practices:**
- [ ] Functions are focused and single-purpose
- [ ] No code duplication
- [ ] Appropriate use of constants
- [ ] Documentation where needed

### Implementation Completeness

- [ ] All files_to_modify were actually modified
- [ ] No unexpected files were modified
- [ ] Changes match subtask scope
- [ ] All acceptance criteria considered

### Critique Flow

```
Implement Subtask
    ↓
Run Self-Critique Checklist
    ↓
Issues Found?
    ↓ YES → Fix Issues → Re-Run Critique
    ↓ NO
Verdict = PROCEED: YES?
    ↓ YES
Move to Verification
```

### Document Your Critique

```markdown
## Self-Critique Results

**Subtask:** [subtask-id]

**Checklist Status:**
- Pattern adherence: ✓
- Error handling: ✓
- Code cleanliness: ✓
- All files modified: ✓
- Requirements met: ✓

**Issues Identified:**
1. [List issues, or "None"]

**Improvements Made:**
1. [List fixes, or "No fixes needed"]

**Verdict:** PROCEED: YES
**Confidence:** High
```

---

## Step 6: Verification

Every subtask must be verified before completion.

### Verification Types

**Command Verification:**
```bash
[verification.command]
# Compare output to expected
```

**API Verification:**
```bash
curl -X [method] [url] -H "Content-Type: application/json" -d '[body]'
# Check response matches expected_status
```

**Test Verification:**
```bash
npm test  # or pytest, etc.
# All tests must pass
```

### If Verification Fails

**FIX IT NOW.** Don't defer to later.

---

## Step 7: Session Insights

Before ending a session, document learnings:

### Codebase Map
What files do what (for future sessions)

### Patterns Discovered
Code patterns that worked well

### Gotchas
Pitfalls to avoid in future

---

## Harmony Integration

In Harmony Framework:
- Use Reflection pattern (`patterns/cognitive/reflection.md`) for self-critique
- Circuit breaker monitors failures automatically
- UCVs provide acceptance criteria verification
- MCP memory stores patterns and gotchas across sessions
