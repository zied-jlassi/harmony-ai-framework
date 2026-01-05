---
name: typescript-advanced-types
displayName: "TypeScript Advanced Types"
category: frontend-development
tier: 2
model: inherit
triggers:
  - "typescript"
  - "generic"
  - "type inference"
  - "utility types"
  - "type guard"
---

# TypeScript Advanced Types

> Master TypeScript's advanced type system for safer, more expressive code.

## Utility Types

### Built-in Utilities
```typescript
interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
  createdAt: Date;
}

// Partial - all properties optional
type UpdateUser = Partial<User>;
// { id?: string; name?: string; ... }

// Required - all properties required
type RequiredUser = Required<Partial<User>>;

// Pick - select properties
type UserPreview = Pick<User, 'id' | 'name'>;
// { id: string; name: string }

// Omit - exclude properties
type UserWithoutDates = Omit<User, 'createdAt'>;

// Record - key-value mapping
type RolePermissions = Record<User['role'], string[]>;
// { admin: string[]; user: string[] }

// Readonly - immutable
type ImmutableUser = Readonly<User>;

// ReturnType - infer function return
type GetUserResult = ReturnType<typeof getUser>;

// Parameters - infer function params
type GetUserParams = Parameters<typeof getUser>;
```

## Generics

### Basic Generics
```typescript
// Generic function
function identity<T>(value: T): T {
  return value;
}

// Generic with constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Generic interface
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

// Generic class
class Container<T> {
  private items: T[] = [];

  add(item: T): void {
    this.items.push(item);
  }

  get(index: number): T | undefined {
    return this.items[index];
  }
}
```

### Advanced Generics
```typescript
// Multiple type parameters
function merge<T, U>(obj1: T, obj2: U): T & U {
  return { ...obj1, ...obj2 };
}

// Default type parameter
interface PaginatedResponse<T = unknown> {
  items: T[];
  total: number;
  page: number;
}

// Conditional types
type IsArray<T> = T extends any[] ? true : false;
type Test1 = IsArray<string[]>; // true
type Test2 = IsArray<string>;   // false

// Infer keyword
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
type Result = UnwrapPromise<Promise<string>>; // string

// Distributive conditional types
type ToArray<T> = T extends any ? T[] : never;
type StringOrNumberArray = ToArray<string | number>;
// string[] | number[]
```

## Type Guards

### Built-in Type Guards
```typescript
function process(value: string | number | null) {
  if (typeof value === 'string') {
    return value.toUpperCase(); // value is string
  }
  if (typeof value === 'number') {
    return value.toFixed(2); // value is number
  }
  return null; // value is null
}

// instanceof
if (error instanceof ValidationError) {
  console.log(error.field); // ValidationError type
}

// in operator
interface Dog { bark(): void; }
interface Cat { meow(): void; }

function speak(animal: Dog | Cat) {
  if ('bark' in animal) {
    animal.bark(); // Dog
  } else {
    animal.meow(); // Cat
  }
}
```

### Custom Type Guards
```typescript
// Type predicate
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj &&
    typeof (obj as User).id === 'string'
  );
}

// Usage
function processData(data: unknown) {
  if (isUser(data)) {
    console.log(data.name); // data is User
  }
}

// Assertion function
function assertIsUser(obj: unknown): asserts obj is User {
  if (!isUser(obj)) {
    throw new Error('Not a user');
  }
}

// Usage
function getUser(data: unknown): string {
  assertIsUser(data);
  return data.name; // data is User after assertion
}
```

## Template Literal Types

```typescript
// Basic template literal
type Greeting = `Hello, ${string}!`;
const valid: Greeting = 'Hello, World!'; // OK

// With union
type EventName = 'click' | 'focus' | 'blur';
type EventHandler = `on${Capitalize<EventName>}`;
// 'onClick' | 'onFocus' | 'onBlur'

// Dynamic property names
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number }
```

## Mapped Types

```typescript
// Make all properties optional
type Optional<T> = {
  [K in keyof T]?: T[K];
};

// Make all properties readonly
type Immutable<T> = {
  readonly [K in keyof T]: T[K];
};

// Transform property types
type Stringify<T> = {
  [K in keyof T]: string;
};

// Filter properties by type
type FilterByType<T, U> = {
  [K in keyof T as T[K] extends U ? K : never]: T[K];
};

type StringProps = FilterByType<User, string>;
// { id: string; name: string; email: string }

// Remove readonly
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];
};

// Remove optional
type Concrete<T> = {
  [K in keyof T]-?: T[K];
};
```

## Discriminated Unions

```typescript
// Define discriminated union
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: Error };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data); // data exists
  } else {
    console.error(result.error); // error exists
  }
}

// Action types (Redux pattern)
type Action =
  | { type: 'INCREMENT' }
  | { type: 'DECREMENT' }
  | { type: 'SET'; payload: number };

function reducer(state: number, action: Action): number {
  switch (action.type) {
    case 'INCREMENT':
      return state + 1;
    case 'DECREMENT':
      return state - 1;
    case 'SET':
      return action.payload; // payload exists
  }
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Prefer interfaces** | For object shapes, use interfaces |
| **Use generics** | Don't use `any`, parameterize types |
| **Type guards** | Narrow types safely |
| **Const assertions** | Use `as const` for literals |
| **Strict mode** | Enable all strict options |
| **Avoid type assertions** | Let TS infer when possible |
