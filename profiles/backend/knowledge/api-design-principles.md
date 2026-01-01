---
name: api-design-principles
displayName: "API Design Principles"
category: backend-development
tier: 2
model: inherit
triggers:
  - "REST API"
  - "API design"
  - "endpoint"
  - "HTTP methods"
  - "API versioning"
---

# API Design Principles

> Master REST and GraphQL API design for scalable, maintainable APIs.

## REST Fundamentals

### Resource Naming
```
# Good - Nouns, plural, lowercase
GET    /users                 # List users
GET    /users/123             # Get user 123
POST   /users                 # Create user
PUT    /users/123             # Update user 123
DELETE /users/123             # Delete user 123

# Nested resources
GET    /users/123/orders      # User's orders
POST   /users/123/orders      # Create order for user

# Bad - Verbs, actions in URL
GET    /getUsers              ❌
POST   /createUser            ❌
GET    /users/123/delete      ❌
```

### HTTP Methods

| Method | Idempotent | Safe | Use Case |
|--------|------------|------|----------|
| GET | Yes | Yes | Read resource |
| POST | No | No | Create resource |
| PUT | Yes | No | Replace resource |
| PATCH | No | No | Partial update |
| DELETE | Yes | No | Delete resource |

### Status Codes

```typescript
// 2xx Success
200 OK                  // GET, PUT, PATCH success
201 Created             // POST success (return Location header)
204 No Content          // DELETE success

// 3xx Redirection
301 Moved Permanently   // Resource moved
304 Not Modified        // Cached response valid

// 4xx Client Error
400 Bad Request         // Validation error
401 Unauthorized        // Missing/invalid auth
403 Forbidden           // Authenticated but not allowed
404 Not Found           // Resource doesn't exist
409 Conflict            // Duplicate, state conflict
422 Unprocessable       // Semantic validation error
429 Too Many Requests   // Rate limited

// 5xx Server Error
500 Internal Error      // Unexpected server error
502 Bad Gateway         // Upstream service error
503 Service Unavailable // Temporarily unavailable
```

## Response Format

### Success Response
```json
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2025-01-15T10:30:00Z"
  }
}
```

### List Response with Pagination
```json
{
  "data": [
    { "id": "1", "name": "Item 1" },
    { "id": "2", "name": "Item 2" }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "perPage": 20,
    "totalPages": 5
  },
  "links": {
    "self": "/items?page=1",
    "next": "/items?page=2",
    "last": "/items?page=5"
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address"
      },
      {
        "field": "password",
        "message": "Must be at least 8 characters"
      }
    ]
  }
}
```

## Versioning Strategies

```typescript
// 1. URL Path (Recommended)
GET /api/v1/users
GET /api/v2/users

// 2. Query Parameter
GET /api/users?version=1

// 3. Header
GET /api/users
Accept: application/vnd.api+json; version=1

// 4. Content Negotiation
GET /api/users
Accept: application/vnd.company.v1+json
```

## Filtering, Sorting, Pagination

```typescript
// Filtering
GET /users?status=active&role=admin
GET /users?createdAt[gte]=2025-01-01

// Sorting
GET /users?sort=name           // Ascending
GET /users?sort=-createdAt     // Descending
GET /users?sort=role,-name     // Multiple

// Pagination
GET /users?page=2&limit=20     // Offset-based
GET /users?cursor=abc123&limit=20  // Cursor-based (recommended)

// Field Selection
GET /users?fields=id,name,email

// Combined
GET /users?status=active&sort=-createdAt&page=1&limit=20&fields=id,name
```

## Authentication & Security

### JWT Authentication
```typescript
// Request
POST /auth/login
{ "email": "user@example.com", "password": "secret" }

// Response
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJl...",
    "expiresIn": 3600
  }
}

// Authenticated Request
GET /users
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### Rate Limiting Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
Retry-After: 60  // When 429
```

## NestJS Implementation

```typescript
// Controller
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiTags('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'List all users' })
  @ApiResponse({ status: 200, type: UserListDto })
  async findAll(
    @Query() query: ListUsersQueryDto
  ): Promise<PaginatedResponse<UserDto>> {
    return this.usersService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiResponse({ status: 200, type: UserDto })
  @ApiResponse({ status: 404, description: 'User not found' })
  async findOne(@Param('id') id: string): Promise<UserDto> {
    const user = await this.usersService.findOne(id);
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  @Post()
  @ApiOperation({ summary: 'Create user' })
  @ApiResponse({ status: 201, type: UserDto })
  async create(@Body() dto: CreateUserDto): Promise<UserDto> {
    return this.usersService.create(dto);
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateUserDto
  ): Promise<UserDto> {
    return this.usersService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string): Promise<void> {
    await this.usersService.remove(id);
  }
}
```

## OpenAPI Documentation

```typescript
// DTO with Swagger decorators
export class CreateUserDto {
  @ApiProperty({ example: 'john@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'John Doe', minLength: 2 })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: 'password123', minLength: 8 })
  @IsString()
  @MinLength(8)
  password: string;
}
```

## Best Practices Checklist

- [ ] Use nouns, not verbs in URLs
- [ ] Use plural resource names
- [ ] Return proper status codes
- [ ] Consistent response format
- [ ] Version your API
- [ ] Implement pagination for lists
- [ ] Document with OpenAPI/Swagger
- [ ] Rate limiting
- [ ] CORS configuration
- [ ] Input validation
- [ ] Meaningful error messages
