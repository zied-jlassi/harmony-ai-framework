---
name: nodejs-backend-patterns
displayName: "Node.js Backend Patterns"
category: javascript-typescript
tier: 2
model: inherit
triggers:
  - "node.js"
  - "express"
  - "fastify"
  - "backend node"
  - "server node"
---

# Node.js Backend Patterns

> Build production-ready Node.js backend services.

## Project Structure

```
src/
├── config/                 # Configuration
│   ├── index.ts
│   ├── database.ts
│   └── env.ts
├── modules/                # Feature modules
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.repository.ts
│   │   ├── users.routes.ts
│   │   ├── users.dto.ts
│   │   └── users.test.ts
│   └── auth/
├── shared/                 # Shared utilities
│   ├── middleware/
│   ├── errors/
│   ├── utils/
│   └── types/
├── infrastructure/         # External services
│   ├── database/
│   ├── cache/
│   └── queue/
├── app.ts                  # Express app setup
└── server.ts               # Server entry point
```

## Express Setup

```typescript
// app.ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import { errorHandler } from './shared/middleware/error-handler';
import { requestLogger } from './shared/middleware/request-logger';
import { rateLimiter } from './shared/middleware/rate-limiter';
import { routes } from './routes';

export function createApp() {
  const app = express();

  // Security middleware
  app.use(helmet());
  app.use(cors({ origin: process.env.CORS_ORIGIN }));
  app.use(rateLimiter);

  // Parsing middleware
  app.use(express.json({ limit: '10kb' }));
  app.use(express.urlencoded({ extended: true }));
  app.use(compression());

  // Logging
  app.use(requestLogger);

  // Health check
  app.get('/health', (req, res) => res.json({ status: 'ok' }));

  // API routes
  app.use('/api/v1', routes);

  // Error handling (must be last)
  app.use(errorHandler);

  return app;
}
```

## Dependency Injection

```typescript
// Container setup with tsyringe
import 'reflect-metadata';
import { container } from 'tsyringe';

// Register dependencies
container.register('Database', { useClass: PrismaDatabase });
container.register('Cache', { useClass: RedisCache });
container.register('Logger', { useClass: WinstonLogger });

// Service with injection
@injectable()
export class UsersService {
  constructor(
    @inject('Database') private db: Database,
    @inject('Cache') private cache: Cache,
    @inject('Logger') private logger: Logger
  ) {}

  async findById(id: string): Promise<User | null> {
    // Try cache first
    const cached = await this.cache.get(`user:${id}`);
    if (cached) return JSON.parse(cached);

    // Fetch from DB
    const user = await this.db.user.findUnique({ where: { id } });
    if (user) {
      await this.cache.set(`user:${id}`, JSON.stringify(user), 300);
    }

    return user;
  }
}
```

## Error Handling

```typescript
// Custom error classes
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR',
    public isOperational: boolean = true
  ) {
    super(message);
    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public errors?: any[]) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

// Error handler middleware
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (err instanceof AppError && err.isOperational) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        ...(err instanceof ValidationError && { errors: err.errors }),
      },
    });
  }

  // Unexpected error
  logger.error('Unexpected error:', err);
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
  });
}
```

## Validation with Zod

```typescript
import { z } from 'zod';

// Schema definition
export const createUserSchema = z.object({
  body: z.object({
    email: z.string().email(),
    name: z.string().min(2).max(100),
    password: z.string().min(8),
    role: z.enum(['user', 'admin']).default('user'),
  }),
});

// Validation middleware
export function validate<T extends z.ZodSchema>(schema: T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        next(new ValidationError('Validation failed', error.errors));
      }
      next(error);
    }
  };
}

// Usage
router.post('/users', validate(createUserSchema), usersController.create);
```

## Graceful Shutdown

```typescript
// server.ts
import { createApp } from './app';

const app = createApp();
const server = app.listen(process.env.PORT || 3000);

// Graceful shutdown
const shutdown = async (signal: string) => {
  console.log(`${signal} received, shutting down gracefully`);

  server.close(async () => {
    console.log('HTTP server closed');

    // Close database connections
    await prisma.$disconnect();

    // Close Redis
    await redis.quit();

    // Close other resources
    process.exit(0);
  });

  // Force shutdown after timeout
  setTimeout(() => {
    console.error('Forced shutdown');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Unhandled errors
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  console.error('Unhandled Rejection:', reason);
  process.exit(1);
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **12-Factor App** | Config in env, stateless processes |
| **Health Checks** | /health and /ready endpoints |
| **Structured Logging** | JSON logs with correlation IDs |
| **Graceful Shutdown** | Handle SIGTERM/SIGINT |
| **Input Validation** | Validate all inputs (Zod/Joi) |
| **Error Handling** | Operational vs programmer errors |
| **Rate Limiting** | Protect against abuse |
| **Security Headers** | Use Helmet.js |
