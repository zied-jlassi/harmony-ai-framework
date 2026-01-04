# NestJS Providers (Services)

> Core concept - Always loaded

## Overview

Providers are classes annotated with `@Injectable()` that can be injected as dependencies.

```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>
  ) {}

  async findAll(): Promise<User[]> {
    return this.userRepo.find();
  }

  async findOne(id: string): Promise<User> {
    return this.userRepo.findOneBy({ id });
  }

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.userRepo.create(dto);
    return this.userRepo.save(user);
  }
}
```

## Injection Scopes

| Scope | Description |
|-------|-------------|
| `DEFAULT` | Singleton (shared instance) |
| `REQUEST` | New instance per request |
| `TRANSIENT` | New instance per injection |

```typescript
@Injectable({ scope: Scope.REQUEST })
export class RequestScopedService {}
```

## Custom Providers

```typescript
// Value provider
{ provide: 'API_KEY', useValue: 'secret123' }

// Factory provider
{
  provide: 'ASYNC_SERVICE',
  useFactory: async (configService: ConfigService) => {
    return new AsyncService(await configService.get('DB_URL'));
  },
  inject: [ConfigService]
}

// Class provider
{ provide: AbstractService, useClass: ConcreteService }
```

## Best Practices

1. **Single responsibility** - One service, one concern
2. **Interface segregation** - Small, focused interfaces
3. **Async/await** - Use for I/O operations
4. **Error handling** - Throw NestJS exceptions

---
*Populated via /harmony learn - Last update: 2026-01-04*
