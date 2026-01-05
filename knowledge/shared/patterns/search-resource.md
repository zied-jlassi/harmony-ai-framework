# search-resource

> **Version**: 1.0.0
> **Date**: 2025-12-23
> **Status**: OBLIGATOIRE
> **Scope**: Tous les endpoints avec filtres, pagination, tri

---

## Principe Fondamental

```
┌─────────────────────────────────────────────────────────────────┐
│                    RÈGLE ABSOLUE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ZÉRO paramètre dans l'URL (sauf :id dans le path)             │
│                                                                  │
│   Tous les filtres, pagination, tri → POST body                 │
│                                                                  │
│   Routes restent identiques (seule la méthode HTTP change)      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Pourquoi ce Pattern?

| Problème GET + Query Params | Solution POST + Body |
|-----------------------------|----------------------|
| Paramètres visibles dans URL | Paramètres masqués dans body |
| Stockés dans logs serveur | Non loggés par défaut |
| Historique navigateur exposé | Pas d'historique |
| Limite taille URL (2048 chars) | Pas de limite body |
| Bookmarkable (problème sécurité) | Non bookmarkable |
| Cacheable (problème données sensibles) | Contrôle cache explicite |

---

## Règles Obligatoires

| # | Règle | Description |
|---|-------|-------------|
| **R1** | ZÉRO `@Query()` | Aucun paramètre dans l'URL pour filtres/pagination |
| **R2** | POST + `@Body()` | Tous les paramètres dans le body de la requête |
| **R3** | Routes intactes | `/api/users` reste `/api/users` (pas `/api/users/search`) |
| **R4** | DTO obligatoire | Utiliser `class-validator` pour validation |
| **R5** | Swagger annoté | `@ApiBody()` pour documentation OpenAPI |

---

## Implémentation NestJS

### AVANT (INTERDIT)

```typescript
// ❌ INTERDIT - GET avec @Query
@Get()
@ApiQuery({ name: 'page', required: false })
@ApiQuery({ name: 'limit', required: false })
async getUsers(
  @Query('page') page = 1,
  @Query('limit') limit = 20,
  @Query('role') role?: string,
) {
  // URL: GET /api/users?page=1&limit=20&role=admin
  return this.usersService.findAll({ page, limit, role });
}
```

### APRÈS (OBLIGATOIRE)

```typescript
// ✅ OBLIGATOIRE - POST avec @Body
@Post()
@ApiBody({ type: UserSearchDto })
@ApiOperation({ summary: 'Search users with filters' })
async getUsers(@Body() filters: UserSearchDto) {
  // URL: POST /api/users
  // Body: { "page": 1, "limit": 20, "filters": { "role": "admin" } }
  return this.usersService.findAll(filters);
}
```

### DTO Standard

```typescript
// search.dto.ts - DTO générique réutilisable
import { IsOptional, IsInt, Min, Max, IsIn, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class PaginationDto {
  @ApiPropertyOptional({ default: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20, minimum: 1, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ enum: ['asc', 'desc'], default: 'desc' })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  sortOrder?: 'asc' | 'desc' = 'desc';

  @ApiPropertyOptional()
  @IsOptional()
  sortBy?: string;
}

// Exemple DTO spécifique
export class UserSearchDto extends PaginationDto {
  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UserFiltersDto)
  filters?: UserFiltersDto;
}

export class UserFiltersDto {
  @ApiPropertyOptional()
  @IsOptional()
  role?: string;

  @ApiPropertyOptional()
  @IsOptional()
  status?: string;

  @ApiPropertyOptional()
  @IsOptional()
  search?: string;
}
```

---

## Implémentation Frontend (React/TypeScript)

### AVANT (INTERDIT)

```typescript
// ❌ INTERDIT - GET avec params URL
const fetchUsers = async (page: number, limit: number, role?: string) => {
  const params = new URLSearchParams({
    page: String(page),
    limit: String(limit)
  });
  if (role) params.append('role', role);

  // URL visible: /api/users?page=1&limit=20&role=admin
  return api.get(`/users?${params}`);
};
```

### APRÈS (OBLIGATOIRE)

```typescript
// ✅ OBLIGATOIRE - POST avec body
interface UserSearchRequest {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  filters?: {
    role?: string;
    status?: string;
    search?: string;
  };
}

const fetchUsers = async (request: UserSearchRequest) => {
  // URL: POST /api/users
  // Body envoyé, rien dans l'URL
  return api.post('/users', {
    page: request.page ?? 1,
    limit: request.limit ?? 20,
    sortBy: request.sortBy,
    sortOrder: request.sortOrder ?? 'desc',
    filters: request.filters,
  });
};

// Utilisation
const users = await fetchUsers({
  page: 1,
  limit: 20,
  filters: { role: 'admin' }
});
```

### Service API Complet

```typescript
// services/api/users.service.ts
import { api } from './api.client';

export interface SearchRequest<T = Record<string, unknown>> {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  filters?: T;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export const usersService = {
  search: (request: SearchRequest<UserFilters>): Promise<PaginatedResponse<User>> =>
    api.post('/users', request),

  getById: (id: string): Promise<User> =>
    api.get(`/users/${id}`),  // GET autorisé pour :id dans path
};
```

---

## Cas Particuliers

### GET Autorisés (Exceptions)

| Cas | Exemple | Raison |
|-----|---------|--------|
| ID dans path | `GET /users/:id` | Identifiant unique, pas de filtre |
| Health check | `GET /health` | Pas de paramètres |
| Ressource unique | `GET /me` | Utilisateur courant |
| Configuration | `GET /config` | Données statiques |

### POST Obligatoires

| Cas | Avant | Après |
|-----|-------|-------|
| Liste avec pagination | `GET /users?page=1` | `POST /users` |
| Liste avec filtres | `GET /logs?severity=HIGH` | `POST /logs` |
| Liste avec tri | `GET /products?sort=price` | `POST /products` |
| Export | `GET /export?format=csv` | `POST /export` |
| Recherche | `GET /search?q=test` | `POST /search` |

---

## Checklist Validation

### Backend (NestJS)

```
□ Aucun @Query() pour pagination/filtres
□ @Post() au lieu de @Get() pour les listings
□ @Body() avec DTO class-validator
□ @ApiBody() pour documentation Swagger
□ ValidationPipe activé globalement
□ Tests E2E mis à jour (POST au lieu de GET)
```

### Frontend (React)

```
□ api.post() au lieu de api.get() avec params
□ Interface TypeScript pour le body
□ Aucun URLSearchParams pour filtres
□ Service API utilise POST
□ Tests mis à jour
```

### Tests E2E

```typescript
// ✅ Test correct
it('should return paginated users', async () => {
  const response = await request(app.getHttpServer())
    .post('/api/users')  // POST, pas GET
    .send({ page: 1, limit: 10, filters: { role: 'admin' } })
    .expect(200);

  expect(response.body.data).toHaveLength(10);
  expect(response.body.meta.page).toBe(1);
});
```

---

## Migration Guide

### Étape 1: Créer SearchDto générique
Fichier: `src/common/dto/search.dto.ts`

### Étape 2: Modifier le Controller
```diff
- @Get()
- async getItems(@Query() filters: FilterDto) {
+ @Post()
+ async getItems(@Body() filters: FilterDto) {
```

### Étape 3: Mettre à jour les tests
```diff
- .get('/api/items?page=1&limit=20')
+ .post('/api/items')
+ .send({ page: 1, limit: 20 })
```

### Étape 4: Mettre à jour le frontend
```diff
- api.get('/items', { params: { page, limit } })
+ api.post('/items', { page, limit })
```

---

## Références

- [REST API Design - Moesif](https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/)
- [API Security Best Practices 2025](https://group107.com/blog/rest-api-security-best-practices/)
---

*Search Resource Pattern - Harmony Framework*
