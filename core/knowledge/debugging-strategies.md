---
name: debugging-strategies
displayName: "Debugging Strategies"
category: developer-essentials
tier: 2
model: inherit
triggers:
  - "debug"
  - "console.log"
  - "breakpoint"
  - "stack trace"
  - "bug investigation"
---

# Debugging Strategies

> Master systematic debugging techniques for efficient problem solving.

## The Scientific Method

```
1. OBSERVE    → What exactly is happening?
2. HYPOTHESIZE → What could cause this?
3. PREDICT    → If hypothesis X, then Y should happen
4. TEST       → Validate prediction
5. CONCLUDE   → Fix or form new hypothesis
```

## Console Techniques

### Beyond console.log
```typescript
// Formatted output
console.log('%c Important!', 'color: red; font-size: 20px');

// Table format
console.table(users);

// Grouped logs
console.group('User Loading');
console.log('Fetching...');
console.log('Received:', data);
console.groupEnd();

// Timing
console.time('API Call');
await fetchData();
console.timeEnd('API Call'); // API Call: 234ms

// Stack trace
console.trace('How did we get here?');

// Conditional logging
console.assert(user.age > 0, 'Age should be positive', user);
```

### Debug Utility
```typescript
// Only logs in development
const debug = (namespace: string) => {
  const enabled = process.env.DEBUG?.includes(namespace);
  return (...args: any[]) => {
    if (enabled) console.log(`[${namespace}]`, ...args);
  };
};

const log = debug('api');
log('Request:', url); // Only if DEBUG=api
```

## Browser DevTools

### Breakpoints
| Type | Use Case |
|------|----------|
| **Line** | Stop at specific code line |
| **Conditional** | Stop only when condition true |
| **DOM** | Stop on element modification |
| **XHR/Fetch** | Stop on network request |
| **Event Listener** | Stop on specific events |
| **Exception** | Stop on errors |

### Network Tab
```
1. Filter by XHR/Fetch
2. Check request payload
3. Verify response data
4. Check timing waterfall
5. Copy as cURL for testing
```

### Performance Profiling
```
1. Start recording
2. Perform slow action
3. Stop recording
4. Analyze flame chart
5. Find long tasks (>50ms)
```

## Node.js Debugging

### Inspector
```bash
# Start with inspector
node --inspect src/index.js

# Break on first line
node --inspect-brk src/index.js

# In VS Code: Attach to Node.js
```

### Memory Debugging
```typescript
// Check memory usage
console.log(process.memoryUsage());

// Heap snapshot
const v8 = require('v8');
v8.writeHeapSnapshot();
```

## Common Bug Patterns

### 1. Race Condition
```typescript
// BUG: Order not guaranteed
const [users, posts] = await Promise.all([
  fetchUsers(),
  fetchPosts()
]);
// posts might reference users not yet loaded

// FIX: Ensure order when dependent
const users = await fetchUsers();
const posts = await fetchPosts(users.map(u => u.id));
```

### 2. Stale Closure
```typescript
// BUG: Always logs initial value
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    setInterval(() => {
      console.log(count); // Always 0!
    }, 1000);
  }, []);
}

// FIX: Use ref or include in deps
const countRef = useRef(count);
countRef.current = count;
// Now use countRef.current in interval
```

### 3. Null Reference
```typescript
// BUG: Crashes if user is null
const name = user.profile.name;

// FIX: Optional chaining + default
const name = user?.profile?.name ?? 'Anonymous';
```

### 4. Off-by-One
```typescript
// BUG: Misses last element
for (let i = 0; i < arr.length - 1; i++) {}

// FIX: Check boundary
for (let i = 0; i < arr.length; i++) {}
// Or use forEach/map
```

## Debugging Checklist

### Before Debugging
- [ ] Can I reproduce it consistently?
- [ ] What changed recently?
- [ ] Is it environment-specific?
- [ ] Check error logs/stack trace

### During Debugging
- [ ] Isolate the problem (binary search)
- [ ] Add strategic logging
- [ ] Check assumptions with assertions
- [ ] Rubber duck explain the problem

### After Fixing
- [ ] Understand root cause
- [ ] Add regression test
- [ ] Document if non-obvious
- [ ] Check for similar bugs elsewhere

## Quick Wins

```typescript
// 1. Stringify circular objects
JSON.stringify(obj, null, 2);

// 2. Copy to clipboard in browser
copy(obj); // In DevTools console

// 3. Monitor function calls
monitor(functionName); // In DevTools

// 4. Pretty print objects
console.dir(obj, { depth: null });

// 5. Debug specific module
DEBUG=app:api node server.js
```
