# NestJS Architecture - Best Practices Industrie

> Sources: FreeCodeCamp, NestJS Official Docs, Context7
> Dernière mise à jour: 2026-01-04

---

## Principes Architecturaux

### Modularité First

> "Everything lives in a module (`AppModule`, `UsersModule`, etc), which can import other modules or export providers."

```typescript
// Un module = un domaine métier
@Module({
  imports: [DatabaseModule],
  providers: [UsersService],
  controllers: [UsersController],
  exports: [UsersService],
})
export class UsersModule {}
```

### Injection de Dépendances

Le container IoC intégré élimine le câblage manuel. Services marqués `@Injectable()` sont automatiquement résolus.

```typescript
@Injectable()
export class UsersService {
  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {}
}
```

---

## Organisation des Fichiers (Domain-Driven)

> Source: NestJS Official - "Entity files should be organized near their domain"

```
src/
├── users/                    # Module = Domaine
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── entities/
│   │   └── user.entity.ts
│   └── dto/
│       ├── create-user.dto.ts
│       └── update-user.dto.ts
├── auth/
│   ├── auth.module.ts
│   ├── auth.service.ts
│   ├── guards/
│   │   └── jwt-auth.guard.ts
│   └── strategies/
│       └── jwt.strategy.ts
└── common/                   # Shared across modules
    ├── interceptors/
    ├── filters/
    └── pipes/
```

---

## Séparation des Responsabilités

| Couche | Responsabilité | Ce qu'elle ne fait PAS |
|--------|----------------|------------------------|
| **Controller** | Routing, params extraction | Business logic |
| **Service** | Business logic, data access | HTTP concerns |
| **DTO** | Validation, transformation | Business logic |
| **Entity** | Domain model | Database specifics |

```typescript
// Controller = THIN (HTTP only)
@Controller('users')
export class UsersController {
  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.findOne(id);  // Delegate to service
  }
}

// Service = Business logic
@Injectable()
export class UsersService {
  async findOne(id: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }
}
```

---

## Request Lifecycle

```
Request → Middleware → Guards → Interceptors (pre) → Pipes → Handler → Interceptors (post) → Filters → Response
```

| Stage | Usage |
|-------|-------|
| **Middleware** | Logging, CORS, body parsing |
| **Guards** | Authentication, authorization |
| **Interceptors** | Transform response, timing, caching |
| **Pipes** | Validation, transformation |
| **Filters** | Error handling |

---

## Configuration Management

> "Stores config in the environment" - 12-Factor App

```typescript
// TOUJOURS utiliser ConfigService, JAMAIS process.env direct
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        DATABASE_URL: Joi.string().required(),
        JWT_SECRET: Joi.string().required(),
      }),
    }),
  ],
})
export class AppModule {}

// Injection
constructor(private configService: ConfigService) {
  const secret = this.configService.get<string>('JWT_SECRET');
}
```

---

## Testing

> "DI makes unit testing straightforward—mock dependencies by providing test doubles."

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let prisma: DeepMockProxy<PrismaClient>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: mockDeep<PrismaClient>() },
      ],
    }).compile();

    service = module.get(UsersService);
    prisma = module.get(PrismaService);
  });
});
```

---

*Source: Compilé depuis FreeCodeCamp, NestJS Official, Context7*
*Enrichi via /harmony learn*
