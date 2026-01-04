# NestJS Controllers

> Core concept - Always loaded

## Overview

Controllers handle incoming requests and return responses to the client.

```typescript
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll(): Promise<User[]> {
    return this.usersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findOne(id);
  }

  @Post()
  create(@Body() createUserDto: CreateUserDto): Promise<User> {
    return this.usersService.create(createUserDto);
  }
}
```

## Route Decorators

| Decorator | HTTP Method |
|-----------|-------------|
| `@Get()` | GET |
| `@Post()` | POST |
| `@Put()` | PUT |
| `@Patch()` | PATCH |
| `@Delete()` | DELETE |

## Parameter Decorators

| Decorator | Description |
|-----------|-------------|
| `@Param()` | Route parameters |
| `@Query()` | Query parameters |
| `@Body()` | Request body |
| `@Headers()` | Request headers |
| `@Req()` | Request object |
| `@Res()` | Response object |

## Best Practices

1. **Thin controllers** - Delegate logic to services
2. **DTOs** - Use class-validator for validation
3. **Versioning** - Use `@Controller({ version: '1' })`
4. **Swagger** - Document with `@ApiTags()`, `@ApiOperation()`

---
*Populated via /harmony learn - Last update: 2026-01-04*
