# Code Standards - TypeScript

> **Usage**: Developer Agent - Standards obligatoires
> **Stack**: TypeScript, NestJS, React
> **CRITIQUE**: Code coverage 100% + Test coverage 100% = OBLIGATOIRE

---

## Coverage 100% - NON NÉGOCIABLE

```
┌─────────────────────────────────────────────────────┐
│     CODE COVERAGE = 100%                            │
│     TEST COVERAGE = 100%                            │
│                                                     │
│     AUCUNE EXCEPTION.                               │
│     AUCUN MERGE SANS 100%.                          │
│     UNE SEULE FAILLE = BUGS EN PRODUCTION.          │
└─────────────────────────────────────────────────────┘
```

| Metric | Required | Blocker if |
|--------|----------|------------|
| Statements | 100% | < 100% |
| Branches | 100% | < 100% |
| Functions | 100% | < 100% |
| Lines | 100% | < 100% |

---

## Clean Code Principles

| Principle | Practice |
|-----------|----------|
| **Single Responsibility** | One function = one purpose |
| **DRY** | Don't Repeat Yourself |
| **KISS** | Keep It Simple, Stupid |
| **YAGNI** | You Aren't Gonna Need It |
| **Boy Scout** | Leave code cleaner than you found it |

---

## TypeScript Guidelines

### OBLIGATOIRE: ZERO `any`

```typescript
// INTERDIT
function process(data: any) { ... }

// CORRECT
function process(data: UserDto) { ... }
function process<T extends BaseEntity>(data: T) { ... }
```

### Types Stricts

```typescript
// GOOD: Typed, clear
interface UserUpdateDto {
  email: string;
  name?: string;
  role?: UserRole;
}

async function updateUser(
  id: string,
  data: UserUpdateDto
): Promise<User> {
  if (!isValidEmail(data.email)) {
    throw new ValidationError('Invalid email format');
  }
  return this.userRepository.update(id, data);
}

// BAD: Untyped
async function update(id, data) {
  return this.repo.update(id, data);
}
```

---

## File Size Limits

| Type | Max Lines | Action si Dépassé |
|------|-----------|-------------------|
| Component | 300 | Split en sub-components |
| Service | 300 | Extract specialized services |
| Function | 50 | Extract helper functions |
| Test file | 500 | Split par feature |

---

## Performance Patterns

### Frontend

```typescript
// 1. Lazy Loading Routes (OBLIGATOIRE)
const GameSession = lazy(() => import('./pages/GameSession'));

// 2. Memoization
const MemoizedScoreBoard = memo(ScoreBoard);

// 3. Optimistic Updates
const mutation = useMutation({
  mutationFn: saveScore,
  onMutate: async (newScore) => {
    await queryClient.cancelQueries(['scores']);
    const previous = queryClient.getQueryData(['scores']);
    queryClient.setQueryData(['scores'], (old) => [...old, newScore]);
    return { previous };
  },
});
```

### Backend

```typescript
// 1. Pagination (TOUJOURS)
async findAll(page = 1, limit = 50) {
  const safeLimit = Math.min(limit, 100); // Cap at 100
  return this.prisma.entity.findMany({
    skip: (page - 1) * safeLimit,
    take: safeLimit,
  });
}

// 2. Avoid N+1 with Include
const items = await this.prisma.entity.findMany({
  include: {
    relation: true,
    otherRelation: { select: { id: true, name: true } },
  }
});

// 3. Parallel Queries
const [a, b, c] = await Promise.all([
  this.getA(),
  this.getB(),
  this.getC(),
]);
```

---

## Security Patterns

### Input Validation (OBLIGATOIRE)

```typescript
// Always validate with Zod or class-validator
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  password: z.string().min(8).regex(/[A-Z]/).regex(/[0-9]/),
});
```

### Guard Usage

```typescript
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  @Get(':id')
  @Roles('admin', 'user')
  async getUser(@Param('id') id: string) {
    // ...
  }
}
```

### RGPD Compliance

```typescript
// Chiffrer données personnelles
const encryptedEmail = encrypt(user.email);

// Log accès aux données sensibles
await this.auditLog.record({
  action: 'READ_PERSONAL_DATA',
  userId: currentUser.id,
  targetId: user.id,
  timestamp: new Date(),
});

// Permettre suppression (droit à l'oubli)
async deleteUser(id: string) {
  await this.anonymizeRelatedData(id);
  await this.userRepository.delete(id);
}
```

---

## Accessibility Patterns (WCAG 2.1 AA)

### ARIA Labels

```typescript
// Interactive elements
<Button
  aria-label="Save changes"
  onClick={handleSave}
>
  <SaveIcon />
</Button>

// Status announcements
<div role="status" aria-live="polite">
  {message}
</div>

// Form fields
<Input
  aria-label="Email address"
  aria-describedby="email-hint"
  aria-invalid={!!errors.email}
/>
```

### Keyboard Navigation

```typescript
// Focus management in modals
useEffect(() => {
  if (isOpen) {
    firstInputRef.current?.focus();
  }
}, [isOpen]);

// Escape to close
useEffect(() => {
  const handleEscape = (e: KeyboardEvent) => {
    if (e.key === 'Escape') onClose();
  };
  document.addEventListener('keydown', handleEscape);
  return () => document.removeEventListener('keydown', handleEscape);
}, [onClose]);
```

### Contraste et Visibilité

```css
/* Minimum contrast ratios */
/* Text: 4.5:1 */
/* Large text/UI: 3:1 */
/* Focus indicator: visible */

:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}
```

---

## Commit Message Format

```
feat(users): implement edit modal (STORY-042)

- Add UserEditModal component with centered positioning
- Implement form pre-fill with user data
- Add validation and error handling

UCVs completed:
- [x] V-001-1: Modal centered
- [x] V-001-2: Form pre-filled

Generated with Harmony Framework
```
