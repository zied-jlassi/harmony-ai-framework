---
name: javascript-testing-patterns
displayName: "JavaScript Testing Patterns"
category: javascript-typescript
tier: 2
model: inherit
triggers:
  - "jest"
  - "vitest"
  - "unit test"
  - "javascript test"
  - "mock"
---

# JavaScript Testing Patterns

> Implement comprehensive JavaScript/TypeScript testing with Jest/Vitest.

## Test Structure

```typescript
// user.service.test.ts
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';

describe('UsersService', () => {
  let service: UsersService;
  let mockRepository: vi.Mocked<UsersRepository>;

  beforeEach(() => {
    mockRepository = {
      findById: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    } as any;

    service = new UsersService(mockRepository);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      // Arrange
      const mockUser = { id: '1', name: 'John', email: 'john@test.com' };
      mockRepository.findById.mockResolvedValue(mockUser);

      // Act
      const result = await service.findById('1');

      // Assert
      expect(result).toEqual(mockUser);
      expect(mockRepository.findById).toHaveBeenCalledWith('1');
      expect(mockRepository.findById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundError when user not found', async () => {
      // Arrange
      mockRepository.findById.mockResolvedValue(null);

      // Act & Assert
      await expect(service.findById('999'))
        .rejects
        .toThrow(NotFoundError);
    });
  });
});
```

## Mocking Patterns

### Module Mocking
```typescript
// Mock entire module
vi.mock('./users.repository', () => ({
  UsersRepository: vi.fn().mockImplementation(() => ({
    findById: vi.fn(),
    create: vi.fn(),
  })),
}));

// Mock specific exports
vi.mock('./utils', async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    sendEmail: vi.fn(), // Only mock sendEmail
  };
});
```

### Spy Functions
```typescript
// Spy on existing method
const consoleSpy = vi.spyOn(console, 'log');
service.doSomething();
expect(consoleSpy).toHaveBeenCalledWith('expected message');

// Spy and mock implementation
vi.spyOn(service, 'validate').mockReturnValue(true);
```

### Mock Implementations
```typescript
// Simple return value
mockFn.mockReturnValue('value');
mockFn.mockReturnValueOnce('first').mockReturnValue('default');

// Async return
mockFn.mockResolvedValue({ data: 'async value' });
mockFn.mockRejectedValue(new Error('failed'));

// Custom implementation
mockFn.mockImplementation((id) => {
  if (id === '1') return { id: '1', name: 'John' };
  return null;
});
```

## Testing Async Code

```typescript
// Async/await
it('should fetch user asynchronously', async () => {
  const user = await service.findById('1');
  expect(user).toBeDefined();
});

// Promises
it('should resolve with user', () => {
  return expect(service.findById('1')).resolves.toEqual(expectedUser);
});

it('should reject with error', () => {
  return expect(service.findById('999')).rejects.toThrow();
});

// Callbacks (legacy)
it('should call callback with result', (done) => {
  service.findByIdCallback('1', (err, user) => {
    expect(err).toBeNull();
    expect(user).toBeDefined();
    done();
  });
});

// Timers
it('should debounce calls', async () => {
  vi.useFakeTimers();

  const callback = vi.fn();
  const debounced = debounce(callback, 100);

  debounced();
  debounced();
  debounced();

  expect(callback).not.toHaveBeenCalled();

  vi.advanceTimersByTime(100);

  expect(callback).toHaveBeenCalledTimes(1);

  vi.useRealTimers();
});
```

## Snapshot Testing

```typescript
// Component snapshot
it('should match snapshot', () => {
  const component = render(<UserCard user={mockUser} />);
  expect(component).toMatchSnapshot();
});

// Inline snapshot
it('should format user correctly', () => {
  const formatted = formatUser(mockUser);
  expect(formatted).toMatchInlineSnapshot(`
    {
      "displayName": "John Doe",
      "email": "john@test.com",
    }
  `);
});

// Update snapshots: vitest -u
```

## Testing HTTP Requests

```typescript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    const { id } = req.params;
    if (id === '1') {
      return res(ctx.json({ id: '1', name: 'John' }));
    }
    return res(ctx.status(404));
  }),

  rest.post('/api/users', async (req, res, ctx) => {
    const body = await req.json();
    return res(ctx.status(201), ctx.json({ id: '2', ...body }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it('should fetch user from API', async () => {
  const user = await api.getUser('1');
  expect(user.name).toBe('John');
});

it('should handle API errors', async () => {
  server.use(
    rest.get('/api/users/:id', (req, res, ctx) => {
      return res(ctx.status(500));
    })
  );

  await expect(api.getUser('1')).rejects.toThrow();
});
```

## Test Fixtures

```typescript
// fixtures/users.ts
export const createMockUser = (overrides = {}): User => ({
  id: '1',
  name: 'John Doe',
  email: 'john@test.com',
  createdAt: new Date('2025-01-01'),
  ...overrides,
});

export const mockUsers = [
  createMockUser({ id: '1', name: 'John' }),
  createMockUser({ id: '2', name: 'Jane', email: 'jane@test.com' }),
];

// Usage
it('should process user', () => {
  const user = createMockUser({ role: 'admin' });
  // ...
});
```

## Coverage Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'test/',
        '**/*.d.ts',
        '**/*.test.ts',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **AAA Pattern** | Arrange, Act, Assert |
| **One assertion focus** | Test one thing per test |
| **Descriptive names** | "should X when Y" |
| **Avoid test interdependence** | Each test isolated |
| **Mock external deps** | DB, API, filesystem |
| **Test edge cases** | Empty, null, error states |
| **Fast tests** | Mock I/O, parallelize |
| **Coverage thresholds** | Enforce minimum coverage |
