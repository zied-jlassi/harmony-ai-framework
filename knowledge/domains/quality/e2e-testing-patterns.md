---
name: e2e-testing-patterns
displayName: "E2E Testing Patterns"
category: developer-essentials
tier: 2
model: inherit
triggers:
  - "e2e test"
  - "playwright"
  - "cypress"
  - "integration test"
  - "end to end"
---

# E2E Testing Patterns

> Build reliable end-to-end test suites with Playwright.

## Project Structure
```
e2e/
├── fixtures/           # Test fixtures and data
│   ├── auth.fixture.ts
│   └── test-data.ts
├── helpers/            # Utility functions
│   ├── api.helper.ts
│   └── auth.helper.ts
├── pages/              # Page Object Models
│   ├── login.page.ts
│   └── dashboard.page.ts
├── specs/              # Test specifications
│   ├── auth/
│   │   └── login.spec.ts
│   └── dashboard/
│       └── widgets.spec.ts
└── playwright.config.ts
```

## Page Object Model
```typescript
// pages/login.page.ts
export class LoginPage {
  constructor(private page: Page) {}

  // Locators
  private emailInput = () => this.page.getByLabel('Email');
  private passwordInput = () => this.page.getByLabel('Password');
  private submitButton = () => this.page.getByRole('button', { name: 'Sign in' });
  private errorMessage = () => this.page.getByRole('alert');

  // Actions
  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
    await this.submitButton().click();
  }

  // Assertions
  async expectError(message: string) {
    await expect(this.errorMessage()).toContainText(message);
  }

  async expectLoggedIn() {
    await expect(this.page).toHaveURL(/\/dashboard/);
  }
}
```

## Test Fixtures
```typescript
// fixtures/auth.fixture.ts
import { test as base, expect } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { DashboardPage } from '../pages/dashboard.page';

type Fixtures = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  authenticatedPage: Page;
};

export const test = base.extend<Fixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },

  dashboardPage: async ({ page }, use) => {
    await use(new DashboardPage(page));
  },

  authenticatedPage: async ({ page }, use) => {
    // Setup: Login via API (faster than UI)
    await page.request.post('/api/auth/login', {
      data: { email: 'test@test.com', password: 'password' }
    });
    await page.goto('/dashboard');
    await use(page);
  },
});

export { expect };
```

## Test Patterns

### Happy Path
```typescript
test.describe('Login Flow', () => {
  test('successful login redirects to dashboard', async ({ loginPage }) => {
    await loginPage.goto();
    await loginPage.login('user@example.com', 'password123');
    await loginPage.expectLoggedIn();
  });
});
```

### Error Cases
```typescript
test.describe('Login Errors', () => {
  test('shows error for invalid credentials', async ({ loginPage }) => {
    await loginPage.goto();
    await loginPage.login('user@example.com', 'wrongpassword');
    await loginPage.expectError('Invalid credentials');
  });

  test('validates required fields', async ({ loginPage, page }) => {
    await loginPage.goto();
    await page.getByRole('button', { name: 'Sign in' }).click();
    await expect(page.getByText('Email is required')).toBeVisible();
  });
});
```

### API Mocking
```typescript
test('handles API error gracefully', async ({ page }) => {
  // Mock failed API response
  await page.route('**/api/users', route =>
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Server error' })
    })
  );

  await page.goto('/users');
  await expect(page.getByText('Failed to load users')).toBeVisible();
});
```

### Visual Regression
```typescript
test('dashboard matches snapshot', async ({ authenticatedPage }) => {
  await expect(authenticatedPage).toHaveScreenshot('dashboard.png', {
    maxDiffPixels: 100,
  });
});
```

### Accessibility Testing
```typescript
import AxeBuilder from '@axe-core/playwright';

test('page has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Use data-testid** | Stable selectors: `data-testid="submit-btn"` |
| **API for setup** | Login via API, test UI flows |
| **Isolate tests** | Each test independent |
| **Avoid sleeps** | Use `waitFor` and assertions |
| **Retry flaky tests** | Configure retries in CI |
| **Parallel execution** | Speed up test suite |

## Configuration
```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './e2e/specs',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['junit', { outputFile: 'results/junit.xml' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'mobile', use: { ...devices['iPhone 13'] } },
  ],
});
```

## Checklist

- [ ] Use Page Object Model
- [ ] Setup authentication via API
- [ ] Mock external services
- [ ] Add accessibility checks
- [ ] Configure CI retries
- [ ] Run tests in parallel
- [ ] Generate HTML reports
