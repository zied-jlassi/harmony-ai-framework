# NestJS Guards

> Advanced pattern - Loaded on keyword: guard

## Overview

Guards determine if a request should be handled by the route handler.

```typescript
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) return false;

    try {
      const payload = await this.jwtService.verifyAsync(token);
      request.user = payload;
      return true;
    } catch {
      return false;
    }
  }
}
```

## Usage

```typescript
// Controller level
@UseGuards(AuthGuard)
@Controller('users')
export class UsersController {}

// Method level
@UseGuards(RolesGuard)
@Get('admin')
getAdminData() {}

// Global
app.useGlobalGuards(new AuthGuard());
```

## Role-based Guard

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!roles) return true;

    const request = context.switchToHttp().getRequest();
    const user = request.user;
    return roles.some(role => user.roles?.includes(role));
  }
}

// Decorator
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// Usage
@Roles('admin')
@UseGuards(RolesGuard)
@Get('admin')
adminOnly() {}
```

---
*Populated via /harmony learn - Last update: 2026-01-04*
