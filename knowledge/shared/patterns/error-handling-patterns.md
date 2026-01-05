---
name: error-handling-patterns
displayName: "Error Handling Patterns"
category: developer-essentials
tier: 2
model: inherit
triggers:
  - "error handling"
  - "exception"
  - "try catch"
  - "error boundary"
  - "graceful degradation"
---

# Error Handling Patterns

> Implement robust error handling for resilient applications.

## Principles

1. **Fail Fast**: Detect errors early
2. **Fail Gracefully**: Provide meaningful feedback
3. **Never Swallow**: Always log or handle
4. **Be Specific**: Use typed errors
5. **Recover When Possible**: Retry, fallback

## TypeScript/JavaScript Patterns

### Custom Error Classes
```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public field?: string) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404);
  }
}
```

### Result Pattern (No Exceptions)
```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function parseUser(data: unknown): Result<User, ValidationError> {
  if (!isValidUser(data)) {
    return { success: false, error: new ValidationError('Invalid user') };
  }
  return { success: true, data: data as User };
}

// Usage
const result = parseUser(input);
if (result.success) {
  console.log(result.data);
} else {
  console.error(result.error);
}
```

### Async Error Handling
```typescript
// Wrapper for async route handlers
const asyncHandler = (fn: AsyncHandler) =>
  (req: Request, res: Response, next: NextFunction) =>
    Promise.resolve(fn(req, res, next)).catch(next);

// Usage
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.findById(req.params.id);
  if (!user) throw new NotFoundError('User');
  res.json(user);
}));
```

### Global Error Handler (Express)
```typescript
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError && err.isOperational) {
    return res.status(err.statusCode).json({
      error: { code: err.code, message: err.message }
    });
  }

  // Unexpected error - log and return generic message
  logger.error('Unexpected error:', err);
  res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' }
  });
});
```

## React Error Boundaries
```tsx
class ErrorBoundary extends React.Component<Props, State> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    logger.error('React error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}

// Usage
<ErrorBoundary fallback={<ErrorPage />}>
  <App />
</ErrorBoundary>
```

## Retry Pattern
```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxRetries: number; delay: number; backoff?: number }
): Promise<T> {
  const { maxRetries, delay, backoff = 2 } = options;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries) throw error;

      const waitTime = delay * Math.pow(backoff, attempt);
      await new Promise(r => setTimeout(r, waitTime));
    }
  }
  throw new Error('Unreachable');
}

// Usage
const data = await withRetry(
  () => fetchFromAPI('/data'),
  { maxRetries: 3, delay: 1000 }
);
```

## Circuit Breaker
```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailure: Date | null = null;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';

  constructor(
    private threshold: number = 5,
    private timeout: number = 30000
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailure!.getTime() > this.timeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit is OPEN');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }

  private onFailure() {
    this.failures++;
    this.lastFailure = new Date();
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
    }
  }
}
```

## Best Practices Checklist

- [ ] Use typed custom errors
- [ ] Never swallow errors silently
- [ ] Log with context (user, request, etc.)
- [ ] Return user-friendly messages
- [ ] Implement retry for transient failures
- [ ] Use circuit breaker for external services
- [ ] Add error boundaries in React
- [ ] Monitor error rates in production
