---
name: atdd-patterns
displayName: "ATDD Patterns"
description: "Acceptance Test-Driven Development patterns and workflows"
version: "1.0"
auto_invoke: true
activate_when:
  keywords:
    - "atdd"
    - "tdd"
    - "acceptance test"
    - "test first"
    - "red green"
    - "test driven"
agents:
  - tester
  - developer
---

# ATDD Patterns (Acceptance Test-Driven Development)

> Generate failing acceptance tests BEFORE implementation (Red-Green-Refactor)

## Core Principle

```
┌─────────────────────────────────────────────────────────────┐
│                    TDD CYCLE                                 │
│                                                              │
│     RED ──────► GREEN ──────► REFACTOR ──────► RED          │
│      │           │              │                            │
│   Write test   Write code    Improve code                    │
│   that FAILS   to PASS       keep tests GREEN                │
└─────────────────────────────────────────────────────────────┘
```

---

## Test Level Selection

| Level | When to Use | Speed | Confidence |
|-------|-------------|-------|------------|
| **E2E** | Critical user journeys, multi-system | Slow | Highest |
| **API** | Business logic, contracts, integrations | Fast | High |
| **Component** | UI behavior, interactions | Fast | Medium |
| **Unit** | Pure logic, algorithms, edge cases | Fastest | Targeted |

### Decision Matrix

```
┌──────────────────────────────────────────────────────────────┐
│ Does it involve user interaction through UI?                 │
│   YES → E2E or Component                                     │
│   NO  → API or Unit                                          │
│                                                              │
│ Does it cross system boundaries (DB, API, services)?         │
│   YES → E2E or API                                           │
│   NO  → Component or Unit                                    │
│                                                              │
│ Is it critical path (login, checkout, core feature)?         │
│   YES → E2E (at least one happy path)                        │
│   NO  → Lower level is sufficient                            │
└──────────────────────────────────────────────────────────────┘
```

---

## Priority Classification (P0-P3)

| Priority | Definition | Run When |
|----------|------------|----------|
| **P0** | Critical - Security, data integrity, core paths | Every commit |
| **P1** | High - Main features, business logic | PR checks |
| **P2** | Medium - Edge cases, integrations | Daily/Nightly |
| **P3** | Low - Nice-to-have, exploratory | Weekly |

---

## ATDD Workflow

### Step 1: Extract Acceptance Criteria

From story:
```markdown
## Acceptance Criteria
- [ ] User can login with valid credentials
- [ ] Invalid password shows error message
- [ ] Account locks after 3 failed attempts
```

### Step 2: Write Failing Tests (RED)

```typescript
// tests/e2e/auth/login.spec.ts
import { test, expect } from '../../support/fixtures';

test.describe('Login Feature', () => {
  test('AC-1: User can login with valid credentials', async ({ page }) => {
    // Arrange
    await page.goto('/login');

    // Act
    await page.getByLabel('Email').fill('valid@test.com');
    await page.getByLabel('Password').fill('validPassword123');
    await page.getByRole('button', { name: 'Sign in' }).click();

    // Assert
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
  });

  test('AC-2: Invalid password shows error message', async ({ page }) => {
    await page.goto('/login');

    await page.getByLabel('Email').fill('valid@test.com');
    await page.getByLabel('Password').fill('wrongPassword');
    await page.getByRole('button', { name: 'Sign in' }).click();

    await expect(page.getByRole('alert')).toContainText('Invalid credentials');
    await expect(page).toHaveURL('/login'); // Still on login page
  });

  test('AC-3: Account locks after 3 failed attempts', async ({ page }) => {
    await page.goto('/login');

    // Attempt 1-3
    for (let i = 0; i < 3; i++) {
      await page.getByLabel('Email').fill('valid@test.com');
      await page.getByLabel('Password').fill('wrongPassword');
      await page.getByRole('button', { name: 'Sign in' }).click();
      await page.waitForTimeout(500); // Brief wait between attempts
    }

    await expect(page.getByRole('alert')).toContainText('Account locked');
  });
});
```

### Step 3: Implement Code (GREEN)

Write minimal code to pass each test.

### Step 4: Refactor

Improve code quality while keeping tests green.

---

## Test Structure (AAA Pattern)

```typescript
test('should do X when Y', async ({ page }) => {
  // Arrange - Setup preconditions
  const user = await userFactory.createUser();
  await page.goto('/dashboard');

  // Act - Perform the action
  await page.getByRole('button', { name: 'Delete' }).click();
  await page.getByRole('button', { name: 'Confirm' }).click();

  // Assert - Verify outcomes
  await expect(page.getByText('Deleted successfully')).toBeVisible();
  await expect(page.getByTestId('user-list')).not.toContainText(user.name);
});
```

---

## Avoid Duplicate Coverage

```
WRONG: Same test at multiple levels
┌─────────────────────────────────────────────────────────────┐
│ E2E:  Login with valid credentials → Dashboard              │
│ API:  POST /auth/login → 200 + token                        │
│ Unit: validateCredentials() returns true                    │
│                                                              │
│ Problem: Testing same thing 3 times                         │
└─────────────────────────────────────────────────────────────┘

RIGHT: Different aspects at each level
┌─────────────────────────────────────────────────────────────┐
│ E2E:  Happy path only - User logs in, sees dashboard        │
│ API:  Error cases - 401, 403, rate limiting, token format   │
│ Unit: Edge cases - null email, special chars, whitespace    │
└─────────────────────────────────────────────────────────────┘
```

---

## Checklist Before Implementation

- [ ] All acceptance criteria have corresponding tests
- [ ] Tests are written at appropriate level (E2E/API/Component/Unit)
- [ ] Tests follow AAA pattern (Arrange/Act/Assert)
- [ ] Tests are isolated (no shared state)
- [ ] Tests have meaningful names (`should_X_when_Y`)
- [ ] Fixtures and factories created for test data
- [ ] All tests FAIL before implementation (Red phase)

---

## See Also

- [TDD Workflow](../../shared/patterns/tdd-workflow.md)
- [Test Framework Setup](test-framework-setup.md)
- [E2E Testing Patterns](e2e-testing-patterns.md)
- [ATDD Checklist Template](../../templates/quality/atdd-checklist.md)
