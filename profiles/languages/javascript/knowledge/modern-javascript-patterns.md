---
name: modern-javascript-patterns
displayName: "Modern JavaScript Patterns"
category: javascript-typescript
tier: 2
model: inherit
triggers:
  - "ES6"
  - "javascript modern"
  - "destructuring"
  - "async await"
  - "ESM"
---

# Modern JavaScript Patterns

> Master ES6+ features for clean, efficient JavaScript code.

## Destructuring

```javascript
// Object destructuring
const user = { name: 'John', age: 30, city: 'NYC' };
const { name, age } = user;
const { name: userName, ...rest } = user; // Rename + rest

// Default values
const { role = 'user' } = user;

// Nested destructuring
const company = {
  name: 'Acme',
  address: { city: 'NYC', zip: '10001' }
};
const { address: { city } } = company;

// Array destructuring
const [first, second, ...others] = [1, 2, 3, 4, 5];
const [, , third] = [1, 2, 3]; // Skip elements

// Function parameters
function createUser({ name, email, role = 'user' }) {
  return { name, email, role };
}

// Swap variables
let a = 1, b = 2;
[a, b] = [b, a];
```

## Spread & Rest

```javascript
// Array spread
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5]; // [1, 2, 3, 4, 5]
const copy = [...arr1]; // Shallow copy

// Object spread
const defaults = { theme: 'light', lang: 'en' };
const userPrefs = { theme: 'dark' };
const settings = { ...defaults, ...userPrefs }; // Merge

// Rest parameters
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}
sum(1, 2, 3, 4); // 10

// Rest in destructuring
const { id, ...userData } = user;
```

## Arrow Functions

```javascript
// Basic syntax
const add = (a, b) => a + b;
const square = x => x * x;
const greet = () => 'Hello!';

// With body
const process = (data) => {
  const result = transform(data);
  return result;
};

// Returning objects (wrap in parentheses)
const createUser = (name) => ({ name, createdAt: new Date() });

// IIFE (Immediately Invoked)
const result = (() => {
  // Private scope
  return computeValue();
})();

// Lexical this (no own this binding)
class Counter {
  count = 0;
  increment = () => {
    this.count++; // 'this' refers to Counter instance
  };
}
```

## Async/Await

```javascript
// Basic async function
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new Error('User not found');
  return response.json();
}

// Error handling
async function fetchData() {
  try {
    const data = await fetchUser(1);
    return data;
  } catch (error) {
    console.error('Failed:', error);
    throw error;
  }
}

// Parallel execution
async function fetchAll() {
  const [users, posts] = await Promise.all([
    fetch('/api/users').then(r => r.json()),
    fetch('/api/posts').then(r => r.json()),
  ]);
  return { users, posts };
}

// Sequential with for...of
async function processItems(items) {
  const results = [];
  for (const item of items) {
    const result = await processItem(item);
    results.push(result);
  }
  return results;
}

// Parallel with map
async function processAllParallel(items) {
  return Promise.all(items.map(item => processItem(item)));
}
```

## Optional Chaining & Nullish Coalescing

```javascript
// Optional chaining (?.)
const city = user?.address?.city;
const firstItem = arr?.[0];
const result = obj?.method?.();

// Nullish coalescing (??)
const value = input ?? 'default'; // Only null/undefined
const count = data.count ?? 0;

// Combining
const theme = user?.settings?.theme ?? 'light';

// Logical assignment
user.name ??= 'Anonymous';  // Assign if null/undefined
user.count ||= 0;           // Assign if falsy
user.data &&= process(user.data); // Assign if truthy
```

## Template Literals

```javascript
// Basic interpolation
const greeting = `Hello, ${name}!`;

// Multi-line strings
const html = `
  <div class="card">
    <h2>${title}</h2>
    <p>${description}</p>
  </div>
`;

// Tagged templates
function sql(strings, ...values) {
  // Escape values for SQL safety
  const escaped = values.map(v => escape(v));
  return strings.reduce((acc, str, i) =>
    acc + str + (escaped[i] || ''), '');
}

const query = sql`SELECT * FROM users WHERE id = ${userId}`;

// Styled-components pattern
const Button = styled.button`
  background: ${props => props.primary ? 'blue' : 'gray'};
  color: white;
  padding: 10px 20px;
`;
```

## Classes & Private Fields

```javascript
class User {
  // Public field
  name;

  // Private field (truly private)
  #password;

  // Static field
  static count = 0;

  constructor(name, password) {
    this.name = name;
    this.#password = password;
    User.count++;
  }

  // Getter
  get displayName() {
    return this.name.toUpperCase();
  }

  // Setter
  set displayName(value) {
    this.name = value.toLowerCase();
  }

  // Private method
  #hashPassword() {
    return hash(this.#password);
  }

  // Public method
  validatePassword(input) {
    return this.#hashPassword() === hash(input);
  }

  // Static method
  static getCount() {
    return User.count;
  }
}
```

## Modules (ESM)

```javascript
// Named exports
export const PI = 3.14159;
export function calculateArea(r) {
  return PI * r * r;
}
export class Circle { /* ... */ }

// Default export
export default class User { /* ... */ }

// Named imports
import { PI, calculateArea } from './math.js';

// Default import
import User from './user.js';

// Mixed
import User, { validateUser } from './user.js';

// Rename imports
import { calculateArea as area } from './math.js';

// Import all
import * as math from './math.js';
math.calculateArea(5);

// Dynamic import
const module = await import('./heavy-module.js');
module.doSomething();
```

## Useful Array Methods

```javascript
// Find
const user = users.find(u => u.id === '1');
const index = users.findIndex(u => u.id === '1');

// Filter & Map
const activeNames = users
  .filter(u => u.active)
  .map(u => u.name);

// Reduce
const total = items.reduce((sum, item) => sum + item.price, 0);

// Some & Every
const hasAdmin = users.some(u => u.role === 'admin');
const allActive = users.every(u => u.active);

// Flat & FlatMap
const nested = [[1, 2], [3, 4]];
const flat = nested.flat(); // [1, 2, 3, 4]

const userPosts = users.flatMap(u => u.posts);

// At (negative indexing)
const last = arr.at(-1);
const secondLast = arr.at(-2);

// Object methods
const keys = Object.keys(obj);
const values = Object.values(obj);
const entries = Object.entries(obj);
const fromEntries = Object.fromEntries(entries);
```

## Best Practices

| Pattern | Use Case |
|---------|----------|
| **const by default** | Use let only when reassignment needed |
| **Arrow functions** | Callbacks, short functions |
| **Destructuring** | Extract multiple values |
| **Template literals** | String interpolation |
| **Optional chaining** | Safe property access |
| **Nullish coalescing** | Default values |
| **Async/await** | Async code (over .then) |
| **ESM** | Module system |
