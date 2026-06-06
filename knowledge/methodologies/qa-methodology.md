# QA Methodology

> Quality assurance practices for validating implementations before sign-off.

---

## Core Principle

**You are the last line of defense. If you approve, the feature ships. Be thorough.**

---

## What QA Catches

The implementation may have:
- Completed all subtasks but missed edge cases
- Written code without creating necessary migrations
- Implemented features without adequate tests
- Left browser console errors
- Introduced security vulnerabilities
- Broken existing functionality

---

## Phase 0: Load Context

```bash
# 1. Read the requirements (source of truth)
cat .harmony/memory/working.json | jq '.current_story'

# 2. See what files were changed
git diff main...HEAD --name-status

# 3. Check acceptance criteria
# Read UCVs for the story
```

---

## Phase 1: Verify Completion

```bash
# All subtasks must be completed
cat .harmony/memory/working.json | jq '.current_story.subtasks[] | select(.status != "completed")'
```

**STOP if subtasks are not all completed.**

---

## Phase 2: Automated Tests

### Unit Tests

```bash
# Run all unit tests for affected services
npm test  # or pytest, etc.
```

**Document:**
```
UNIT TESTS:
- [service-name]: PASS/FAIL (X/Y tests)
```

### Integration Tests

```bash
# Run integration test suite
npm run test:integration
```

**Document:**
```
INTEGRATION TESTS:
- [test-name]: PASS/FAIL
```

### E2E Tests

```bash
# Run E2E test suite (Playwright, Cypress, etc.)
npm run test:e2e
```

**Document:**
```
E2E TESTS:
- [flow-name]: PASS/FAIL
```

---

## Phase 3: Browser Verification (Frontend)

### Console Error Check

**CRITICAL**: Check for JavaScript errors in the browser console.

```
Check browser console for:
- Errors (red) - MUST be zero
- Warnings (yellow) - Document if present
- Network failures - MUST be zero
```

### Visual Verification

1. Navigate to each affected page
2. Verify visual elements match design
3. Test interactions work correctly
4. Check responsive behavior

---

## Phase 4: Security Verification

### Input Validation
- [ ] All user inputs validated server-side
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CSRF tokens present

### Authentication/Authorization
- [ ] Protected routes require auth
- [ ] Role checks enforced
- [ ] Session handling secure

### Data Protection
- [ ] Sensitive data not exposed in logs
- [ ] HTTPS enforced
- [ ] Secrets not in code

---

## Phase 5: Performance Check

### Response Times
- [ ] API responses < 200ms for simple queries
- [ ] Page loads < 3s
- [ ] No N+1 queries

### Resource Usage
- [ ] No memory leaks detected
- [ ] Database queries optimized
- [ ] Caching implemented where appropriate

---

## Phase 6: Documentation

### Code Documentation
- [ ] Complex logic commented
- [ ] API endpoints documented
- [ ] Type definitions complete

### User Documentation
- [ ] README updated if needed
- [ ] Changelog entry added
- [ ] Migration guide if breaking changes

---

## QA Report Template

```markdown
## QA Validation Report

**Story:** [story-id]
**Date:** [date]
**Validator:** [name/agent]

### Test Results
| Category | Status | Notes |
|----------|--------|-------|
| Unit Tests | PASS/FAIL | X/Y tests |
| Integration | PASS/FAIL | |
| E2E | PASS/FAIL | |
| Security | PASS/FAIL | |
| Performance | PASS/FAIL | |

### Issues Found
1. [Issue description] - Severity: HIGH/MEDIUM/LOW

### Recommendations
1. [Recommendation]

### Verdict
**APPROVED / REJECTED**

**Confidence:** High/Medium/Low
**Reason:** [Brief explanation]
```

---

## Harmony Integration

In Harmony Framework:
- Use `/harmony ucv-qa` for UCV validation
- Use `/harmony ucv-validator` for final check
- Circuit breaker tracks QA failures
- HQVF ensures triple validation (Dev + Test + QA)
