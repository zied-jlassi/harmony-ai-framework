---
name: "owasp-top10"
description: "OWASP Top 10 security patterns"
version: "1.1"
auto_invoke: true
activate_when:
  file_matches:
    - "*.guard.ts"
    - "*.controller.ts"
    - "*auth*"
  keywords:
    - "security"
    - "owasp"
    - "vulnerability"
agents:
  - security
  - review
  - dev
---

# OWASP Top 10

> Patterns de sécurité OWASP pour applications NestJS

## A01: Broken Access Control -> SEC-1

```typescript
// TOUJOURS: 3 guards
@UseGuards(JwtAuthGuard, RolesGuard, SchoolGuard)
@Controller('resource')
export class ResourceController {}

// Multi-tenant
@SchoolCheck({ entityType: 'student' })
async findOne(@Param('id') id: string) {}
```

## A03: Injection -> SEC-2

```typescript
// Prisma parameterized (safe)
const user = await prisma.user.findUnique({ where: { id } });

// Zod validation
const schema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
});
```

## A07: Authentication Failures

```typescript
// Password policy
const PasswordSchema = z.string()
  .min(12)
  .regex(/[A-Z]/)
  .regex(/[a-z]/)
  .regex(/[0-9]/)
  .regex(/[^A-Za-z0-9]/);

// JWT short expiration
const token = jwt.sign(payload, secret, { expiresIn: '15m' });
```

## Quick Reference

| OWASP | Rule | Pattern |
|-------|-----------------|---------|
| A01 | SEC-1 | 3 guards obligatoires |
| A03 | SEC-2 | Zod validation |
| A03 | SEC-2 | Prisma parameterized |
| - | SEC-3 | No hardcoded secrets |
| - | SEC-4 | POST body for filters |

## References

- [OWASP Top 10](https://owasp.org/Top10/)
- Guards: `backend/src/common/guards/`
