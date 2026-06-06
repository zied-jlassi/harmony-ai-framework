---
name: traceability-patterns
displayName: "Traceability Patterns"
description: "Requirements to tests traceability matrix patterns"
version: "1.0"
auto_invoke: true
activate_when:
  keywords:
    - "traceability"
    - "coverage matrix"
    - "requirements mapping"
    - "test coverage"
    - "quality gate"
agents:
  - ucv-validator
  - tester
---

# Traceability Matrix Patterns

> Map requirements to tests and make quality gate decisions

## Traceability Concept

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRACEABILITY CHAIN                            │
│                                                                  │
│  Requirement ──► Acceptance Criteria ──► Test Case ──► Result   │
│       │                   │                  │            │      │
│    PRD/Story           UCV/AC            E2E/API       PASS/FAIL │
└─────────────────────────────────────────────────────────────────┘
```

---

## Coverage Status

| Status | Definition | Action |
|--------|------------|--------|
| **FULL** | All test levels covered | Ready for release |
| **PARTIAL** | Some coverage exists | Add missing tests |
| **UNIT-ONLY** | Only unit tests | Add integration/E2E |
| **INTEGRATION-ONLY** | No E2E tests | Add E2E for critical paths |
| **NONE** | No tests exist | Block - write tests first |

---

## Coverage Matrix Template

| Req ID | Description | Priority | E2E | API | Unit | Status |
|--------|-------------|----------|-----|-----|------|--------|
| AC-1 | User can login | P0 | ✅ | ✅ | ✅ | FULL |
| AC-2 | Invalid password error | P1 | ❌ | ✅ | ✅ | PARTIAL |
| AC-3 | Account lockout | P1 | ❌ | ❌ | ✅ | UNIT-ONLY |
| AC-4 | Password reset | P2 | ❌ | ❌ | ❌ | NONE |

---

## Priority-Based Gate Rules

### Story Gate

| Priority | Required Coverage | Gate Status |
|----------|------------------|-------------|
| P0 | 100% at E2E or API | BLOCKING |
| P1 | 100% at any level | BLOCKING |
| P2 | 80% recommended | WARNING |
| P3 | Optional | INFO |

### Epic Gate

- All P0 criteria: FULL coverage required
- All P1 criteria: At least PARTIAL
- Overall: > 90% coverage

### Release Gate

- All epic gates passed
- NFR assessment passed
- No NONE coverage on P0/P1

---

## Quality Gate Decision

```
┌──────────────────────────────────────────────────────────────┐
│                  GATE DECISION RULES                          │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  P0 coverage = 100% AND P1 coverage >= 90%  → PASS ✅        │
│                                                               │
│  P0 coverage = 100% AND P1 coverage < 90%   → CONCERNS ⚠️   │
│  (Plan remediation for missing P1)                            │
│                                                               │
│  P0 coverage < 100%                         → FAIL ❌        │
│  (Block until P0 fully covered)                               │
│                                                               │
│  Business waiver documented                 → WAIVED 📋      │
│  (Risk accepted by stakeholder)                               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Test Discovery Patterns

### By Test ID

```typescript
// Test files should include requirement ID
// tests/e2e/auth/login.spec.ts

test('AC-1: User can login with valid credentials', ...);
test('AC-2: Invalid password shows error', ...);
```

### By Describe Block

```typescript
describe('Login Feature [STORY-123]', () => {
  test('AC-1: ...', ...);
  test('AC-2: ...', ...);
});
```

### By Tags

```typescript
test('User login', { tag: ['@P0', '@auth', '@AC-1'] }, async () => {
  // ...
});
```

---

## Gap Analysis

When coverage gaps exist:

1. **Identify** - Which requirements lack tests?
2. **Prioritize** - P0 first, then P1
3. **Assign** - Who will write the tests?
4. **Track** - Add to sprint backlog
5. **Verify** - Re-run traceability after

---

## Report Output

```markdown
## Traceability Report - STORY-123

**Coverage Summary:**
- Total Requirements: 8
- FULL Coverage: 5 (62.5%)
- PARTIAL Coverage: 2 (25%)
- NO Coverage: 1 (12.5%)

**Gate Decision: CONCERNS ⚠️**

**Action Required:**
- AC-4: Add E2E test for password reset
- AC-7: Add API test for rate limiting

**Deadline:** Before merge to main
```

---

## See Also

- [Traceability Matrix Template](../../templates/quality/traceability-matrix.md)
- [ATDD Patterns](atdd-patterns.md)
- [UCV Workflow](../../../agents/ucv.md)
