---
name: test-framework-setup
displayName: "Test Framework Setup"
description: "Patterns for setting up Playwright or Cypress test frameworks"
version: "1.0"
auto_invoke: true
activate_when:
  keywords:
    - "playwright"
    - "cypress"
    - "test setup"
    - "e2e setup"
    - "test framework"
    - "configurer tests"
agents:
  - tester
  - developer
---

# Test Framework Setup Patterns

> Scaffolding production-ready test infrastructure (Playwright/Cypress)

## Framework Selection

### Playwright (Recommended for)

- Large repositories (100+ files)
- Performance-critical applications
- Multi-browser support needed
- Complex user flows requiring video/trace debugging
- Projects requiring worker parallelism

### Cypress (Recommended for)

- Small teams prioritizing developer experience
- Component testing focus
- Real-time reloading during test development
- Simpler setup requirements

**Default**: Playwright if uncertain

---

## Directory Structure

```
{project-root}/
├── tests/
│   ├── e2e/                      # E2E test files
│   ├── api/                      # API tests (optional)
│   ├── component/                # Component tests (optional)
│   ├── support/                  # Framework infrastructure
│   │   ├── fixtures/             # Test fixtures (data, mocks)
│   │   │   ├── index.ts          # Fixture composition
│   │   │   └── factories/        # Data factories
│   │   ├── helpers/              # Utility functions
│   │   └── page-objects/         # Page Object Models
│   └── README.md
├── playwright.config.ts          # or cypress.config.ts
├── .env.example                  # Environment variables
└── .nvmrc                        # Node version
```

---

## Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  // Timeouts
  timeout: 60 * 1000,           // Test: 60s
  expect: { timeout: 15 * 1000 }, // Assertion: 15s

  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15 * 1000,     // Action: 15s
    navigationTimeout: 30 * 1000, // Navigation: 30s
  },

  reporter: [
    ['html', { outputFolder: 'test-results/html' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
    ['list']
  ],

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
```

---

## Cypress Configuration

```typescript
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: process.env.BASE_URL || 'http://localhost:3000',
    specPattern: 'tests/e2e/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'tests/support/e2e.ts',
    video: false,
    screenshotOnRunFailure: true,
  },

  retries: { runMode: 2, openMode: 0 },

  // Timeouts
  defaultCommandTimeout: 15000,
  requestTimeout: 30000,
  responseTimeout: 30000,
  pageLoadTimeout: 60000,
});
```

---

## Fixture Architecture (Playwright)

```typescript
// tests/support/fixtures/index.ts
import { test as base } from '@playwright/test';
import { UserFactory } from './factories/user-factory';

type TestFixtures = {
  userFactory: UserFactory;
};

export const test = base.extend<TestFixtures>({
  userFactory: async ({}, use) => {
    const factory = new UserFactory();
    await use(factory);
    await factory.cleanup(); // Auto-cleanup
  },
});

export { expect } from '@playwright/test';
```

---

## Data Factory Pattern

```typescript
// tests/support/fixtures/factories/user-factory.ts
import { faker } from '@faker-js/faker';

export class UserFactory {
  private createdUsers: string[] = [];

  async createUser(overrides = {}) {
    const user = {
      email: faker.internet.email(),
      name: faker.person.fullName(),
      password: faker.internet.password({ length: 12 }),
      ...overrides,
    };

    const response = await fetch(`${process.env.API_URL}/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    const created = await response.json();
    this.createdUsers.push(created.id);
    return created;
  }

  async cleanup() {
    for (const userId of this.createdUsers) {
      await fetch(`${process.env.API_URL}/users/${userId}`, {
        method: 'DELETE',
      });
    }
    this.createdUsers = [];
  }
}
```

---

## Environment Configuration

```bash
# .env.example
TEST_ENV=local
BASE_URL=http://localhost:3000
API_URL=http://localhost:3001/api

# Authentication
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=

# Feature Flags
FEATURE_FLAG_NEW_UI=true
```

---

## Package.json Scripts

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:headed": "playwright test --headed",
    "test:e2e:debug": "playwright test --debug",
    "test:report": "playwright show-report"
  }
}
```

---

## Best Practices

| Practice | Description |
|----------|-------------|
| **Selectors** | Use `data-testid` attributes, avoid CSS selectors |
| **Isolation** | Each test independent, with setup/teardown |
| **Artifacts** | Capture on failure only (screenshots, videos, traces) |
| **Parallelism** | Enable for CI, limit workers in CI environment |
| **Retries** | 2 retries in CI, 0 locally |

---

## See Also

- [Playwright E2E Patterns](playwright-e2e.md)
- [E2E Testing Patterns](e2e-testing-patterns.md)
- [TDD Workflow](../../shared/patterns/tdd-workflow.md)
- [CI Templates](../../templates/ci/)
