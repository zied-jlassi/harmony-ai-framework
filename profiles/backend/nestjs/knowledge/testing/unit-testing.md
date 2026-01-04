# NestJS Unit Testing

> Testing pattern - Loaded on intent: TEST, TDD

## Overview

NestJS uses Jest for testing with a testing module for dependency injection.

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repository: MockType<Repository<User>>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useFactory: repositoryMockFactory
        }
      ]
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get(getRepositoryToken(User));
  });

  it('should find all users', async () => {
    const users = [{ id: '1', email: 'test@test.com' }];
    repository.find.mockReturnValue(users);

    expect(await service.findAll()).toEqual(users);
  });
});
```

## Mocking Patterns

```typescript
// Repository mock factory
const repositoryMockFactory = jest.fn(() => ({
  find: jest.fn(),
  findOne: jest.fn(),
  save: jest.fn(),
  delete: jest.fn()
}));

// Service mock
const mockUsersService = {
  findAll: jest.fn().mockResolvedValue([]),
  findOne: jest.fn().mockResolvedValue(null),
  create: jest.fn().mockImplementation(dto => ({ id: '1', ...dto }))
};
```

## Controller Testing

```typescript
describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        { provide: UsersService, useValue: mockUsersService }
      ]
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
  });

  it('should return all users', async () => {
    const result = await controller.findAll();
    expect(service.findAll).toHaveBeenCalled();
  });
});
```

## Best Practices

1. **Isolate tests** - Mock all dependencies
2. **Test behavior** - Not implementation details
3. **Coverage** - Aim for 80%+ on critical paths
4. **Naming** - `should [action] when [condition]`

---
*Populated via /harmony learn - Last update: 2026-01-04*
