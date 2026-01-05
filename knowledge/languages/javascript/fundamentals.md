# JavaScript Fundamentals

> Core JavaScript concepts and patterns.

---

## Variables and Types

### Declaration

```javascript
// const - immutable binding (preferred)
const API_URL = 'https://api.example.com';

// let - mutable binding (when needed)
let counter = 0;

// var - function scoped (avoid in modern JS)
var legacy = 'avoid';
```

### Primitive Types

| Type | Example | Notes |
|------|---------|-------|
| `string` | `'hello'`, `"world"`, `` `template` `` | Immutable |
| `number` | `42`, `3.14`, `NaN`, `Infinity` | IEEE 754 float |
| `bigint` | `9007199254740991n` | Arbitrary precision |
| `boolean` | `true`, `false` | |
| `undefined` | `undefined` | Uninitialized |
| `null` | `null` | Intentional absence |
| `symbol` | `Symbol('id')` | Unique identifier |

### Reference Types

```javascript
// Object
const user = { name: 'John', age: 30 };

// Array
const items = [1, 2, 3];

// Function
const greet = (name) => `Hello, ${name}!`;

// Map (key-value, any key type)
const map = new Map([['key', 'value']]);

// Set (unique values)
const set = new Set([1, 2, 3]);
```

---

## Functions

### Declaration Styles

```javascript
// Function declaration (hoisted)
function add(a, b) {
  return a + b;
}

// Function expression
const multiply = function(a, b) {
  return a * b;
};

// Arrow function (lexical this)
const divide = (a, b) => a / b;

// Arrow with body
const process = (data) => {
  const result = transform(data);
  return result;
};
```

### Parameters

```javascript
// Default parameters
function greet(name = 'World') {
  return `Hello, ${name}!`;
}

// Rest parameters
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}

// Destructuring parameters
function createUser({ name, email, role = 'user' }) {
  return { name, email, role, createdAt: new Date() };
}
```

---

## Closures and Scope

### Lexical Scope

```javascript
function outer() {
  const message = 'Hello';

  function inner() {
    // inner has access to outer's variables
    console.log(message);
  }

  return inner;
}

const fn = outer();
fn(); // 'Hello' - closure retains access
```

### Common Patterns

```javascript
// Module pattern (encapsulation)
const counter = (() => {
  let count = 0;  // private

  return {
    increment: () => ++count,
    decrement: () => --count,
    getCount: () => count
  };
})();

// Factory with closure
function createLogger(prefix) {
  return (message) => console.log(`[${prefix}] ${message}`);
}

const apiLogger = createLogger('API');
apiLogger('Request received'); // [API] Request received
```

---

## Object Operations

### Destructuring

```javascript
// Object destructuring
const { name, age, role = 'user' } = user;

// Array destructuring
const [first, second, ...rest] = items;

// Nested destructuring
const { address: { city, country } } = user;

// Rename during destructure
const { name: userName } = user;
```

### Spread Operator

```javascript
// Object spread (shallow copy)
const updated = { ...user, age: 31 };

// Array spread
const combined = [...arr1, ...arr2];

// Function arguments
Math.max(...numbers);
```

### Optional Chaining

```javascript
// Safe property access
const city = user?.address?.city;

// Safe method call
const result = obj?.method?.();

// Safe array access
const first = arr?.[0];
```

### Nullish Coalescing

```javascript
// Default only for null/undefined (not falsy)
const value = input ?? 'default';

// Compared to OR (catches all falsy)
const value2 = input || 'default';  // catches '', 0, false too
```

---

## Arrays

### Transformation Methods

```javascript
// map - transform each element
const doubled = numbers.map(n => n * 2);

// filter - keep matching elements
const evens = numbers.filter(n => n % 2 === 0);

// reduce - accumulate to single value
const sum = numbers.reduce((acc, n) => acc + n, 0);

// flatMap - map + flatten
const words = sentences.flatMap(s => s.split(' '));
```

### Search Methods

```javascript
// find - first match
const user = users.find(u => u.id === targetId);

// findIndex - index of first match
const index = users.findIndex(u => u.id === targetId);

// some - any match exists
const hasAdmin = users.some(u => u.role === 'admin');

// every - all match
const allActive = users.every(u => u.active);

// includes - value exists
const hasItem = items.includes(target);
```

### Mutation Methods (use carefully)

```javascript
// push/pop - end of array
arr.push(item);     // add to end
arr.pop();          // remove from end

// unshift/shift - start of array
arr.unshift(item);  // add to start
arr.shift();        // remove from start

// splice - remove/insert at index
arr.splice(index, deleteCount, ...newItems);

// sort - in place (mutates!)
arr.sort((a, b) => a - b);  // ascending numbers
```

---

## Error Handling

### Try-Catch

```javascript
try {
  const data = JSON.parse(input);
  processData(data);
} catch (error) {
  if (error instanceof SyntaxError) {
    console.error('Invalid JSON:', error.message);
  } else {
    throw error;  // Re-throw unknown errors
  }
} finally {
  cleanup();  // Always runs
}
```

### Custom Errors

```javascript
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

function validate(data) {
  if (!data.email) {
    throw new ValidationError('Email is required', 'email');
  }
}
```

---

## Best Practices

| Practice | Description |
|----------|-------------|
| Use `const` by default | Only `let` when rebinding needed |
| Prefer arrow functions | Except when `this` binding needed |
| Use template literals | For string interpolation |
| Destructure early | Extract needed properties |
| Use optional chaining | Avoid null checks chains |
| Immutable operations | Prefer map/filter over mutation |
| Early returns | Reduce nesting |
| Named exports | Over default exports |
