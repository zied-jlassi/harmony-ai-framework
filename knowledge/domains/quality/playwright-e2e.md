---
name: "playwright-e2e"
description: "Playwright E2E testing patterns"
version: "2.0"
auto_invoke: true
activate_when:
  file_matches:
    - "*.spec.ts"
    - "e2e/**"
  keywords:
    - "e2e"
    - "playwright"
    - "test"
agents:
  - tester
  - qa
  - dev
---

# Playwright E2E Patterns

> Patterns Playwright pour tests E2E

## Locator Strategies (Priority Order)

```typescript
// 1. Role-based (PREFERRED)
page.getByRole('button', { name: 'Submit' });

// 2. Label-based (ACCESSIBLE)
page.getByLabel('Email');

// 3. Text-based
page.getByText('Welcome');

// 4. TestId (LAST RESORT)
page.getByTestId('submit-btn');

// FORBIDDEN - Never use CSS selectors
page.locator('.btn-submit');  // NO
page.locator('#submit');      // NO
```

## Page Object Model (POM)

```typescript
// e2e/pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  readonly emailInput = () => this.page.getByLabel('Email');
  readonly passwordInput = () => this.page.getByLabel('Mot de passe');
  readonly submitButton = () => this.page.getByRole('button', { name: 'Connexion' });

  async login(email: string, password: string) {
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
    await this.submitButton().click();
  }
}
```

## Test Structure (AAA)

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'director');
  });

  test('should display list', async ({ page }) => {
    // Arrange
    await page.goto('/features');

    // Act
    await page.getByRole('button', { name: 'Filter' }).click();

    // Assert
    await expect(page.getByRole('heading')).toBeVisible();
  });
});
```

## Test Accounts (9 Roles)

```typescript
const TEST_ACCOUNTS = {
  SUPER_ADMIN:  { identifier: 'SA000001', password: 'Azerty123+++' },
  DIRECTOR:     { identifier: 'DR000001', password: 'Azerty123+++' },
  ADMIN:        { identifier: 'AD000001', password: 'Azerty123+++' },
  COORDINATOR:  { identifier: 'CO000001', password: 'Azerty123+++' },
  TEACHER:      { identifier: 'TE000001', password: 'Azerty123+++' },
  TUTOR:        { identifier: 'TU000001', password: 'Azerty123+++' },
  SECRETARIAT:  { identifier: 'SE000001', password: 'Azerty123+++' },
  PARENT:       { identifier: 'PA000001', password: 'Azerty123+++' },
  STUDENT:      { identifier: 'ST000001', password: 'Azerty123+++' },
};
```

## Assertions

```typescript
await expect(page.getByText('Title')).toBeVisible();
await expect(page).toHaveURL('/dashboard');
await expect(page.getByRole('row')).toHaveCount(6);
```

## Commands

```bash
cd frontend-admin && npx playwright test
npx playwright test --ui
npx playwright show-report
```

## References

- Config: `frontend-admin/playwright.config.ts`
- Tests: `frontend-admin/e2e/`
