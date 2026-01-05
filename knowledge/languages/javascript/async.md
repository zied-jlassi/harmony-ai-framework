# JavaScript Async Patterns

> Asynchronous programming in JavaScript.

---

## Promises

### Creating Promises

```javascript
// Promise constructor
const promise = new Promise((resolve, reject) => {
  const success = doSomething();
  if (success) {
    resolve(result);
  } else {
    reject(new Error('Operation failed'));
  }
});

// Static methods
Promise.resolve(value);   // Immediately resolved
Promise.reject(error);    // Immediately rejected
```

### Consuming Promises

```javascript
// then/catch chain
fetchUser(id)
  .then(user => fetchPosts(user.id))
  .then(posts => renderPosts(posts))
  .catch(error => handleError(error))
  .finally(() => hideLoader());

// Error handling in chain
promise
  .then(result => {
    if (!result.valid) {
      throw new Error('Invalid result');
    }
    return result.data;
  })
  .catch(error => {
    // Catches both promise rejection AND thrown errors
    console.error(error);
  });
```

### Promise Combinators

```javascript
// Promise.all - wait for all (fails fast)
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments()
]);

// Promise.allSettled - wait for all (no fail fast)
const results = await Promise.allSettled([
  fetchA(),
  fetchB(),
  fetchC()
]);
// results: [{status: 'fulfilled', value}, {status: 'rejected', reason}]

// Promise.race - first to settle
const result = await Promise.race([
  fetchData(),
  timeout(5000)
]);

// Promise.any - first to fulfill (ignores rejections)
const fastest = await Promise.any([
  fetchFromServer1(),
  fetchFromServer2(),
  fetchFromServer3()
]);
```

---

## Async/Await

### Basic Usage

```javascript
async function fetchUserData(userId) {
  try {
    const user = await fetchUser(userId);
    const posts = await fetchPosts(user.id);
    const comments = await fetchComments(posts.map(p => p.id));

    return { user, posts, comments };
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    throw error;
  }
}
```

### Parallel Execution

```javascript
// Sequential (slow) - each awaits before next
async function sequential() {
  const a = await fetchA();  // wait
  const b = await fetchB();  // then wait
  const c = await fetchC();  // then wait
  return [a, b, c];
}

// Parallel (fast) - all start immediately
async function parallel() {
  const [a, b, c] = await Promise.all([
    fetchA(),
    fetchB(),
    fetchC()
  ]);
  return [a, b, c];
}

// Hybrid - some parallel, some sequential
async function hybrid() {
  // These can run in parallel
  const [user, config] = await Promise.all([
    fetchUser(),
    fetchConfig()
  ]);

  // This depends on user
  const posts = await fetchPosts(user.id);

  return { user, config, posts };
}
```

### Error Handling Patterns

```javascript
// Try-catch (explicit)
async function withTryCatch() {
  try {
    return await riskyOperation();
  } catch (error) {
    return defaultValue;
  }
}

// Catch wrapper (reusable)
async function safe(promise, defaultValue = null) {
  try {
    return await promise;
  } catch {
    return defaultValue;
  }
}

const user = await safe(fetchUser(id), { name: 'Guest' });

// Result tuple pattern
async function safeResult(promise) {
  try {
    const data = await promise;
    return [null, data];
  } catch (error) {
    return [error, null];
  }
}

const [error, user] = await safeResult(fetchUser(id));
if (error) {
  handleError(error);
}
```

---

## Async Iteration

### For-await-of

```javascript
// Async generator
async function* fetchPages(url) {
  let page = 1;
  let hasMore = true;

  while (hasMore) {
    const response = await fetch(`${url}?page=${page}`);
    const data = await response.json();

    yield data.items;

    hasMore = data.hasMore;
    page++;
  }
}

// Consuming async iterator
async function processAllPages() {
  for await (const items of fetchPages('/api/users')) {
    for (const item of items) {
      processItem(item);
    }
  }
}
```

### Async Array Methods

```javascript
// Sequential processing
async function processSequential(items) {
  const results = [];
  for (const item of items) {
    results.push(await processItem(item));
  }
  return results;
}

// Parallel processing
async function processParallel(items) {
  return Promise.all(items.map(item => processItem(item)));
}

// Parallel with concurrency limit
async function processWithLimit(items, limit = 5) {
  const results = [];
  const executing = new Set();

  for (const item of items) {
    const promise = processItem(item).then(result => {
      executing.delete(promise);
      return result;
    });

    executing.add(promise);
    results.push(promise);

    if (executing.size >= limit) {
      await Promise.race(executing);
    }
  }

  return Promise.all(results);
}
```

---

## Common Patterns

### Retry Pattern

```javascript
async function withRetry(fn, maxRetries = 3, delay = 1000) {
  let lastError;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      console.warn(`Attempt ${attempt} failed:`, error.message);

      if (attempt < maxRetries) {
        await sleep(delay * attempt);  // Exponential backoff
      }
    }
  }

  throw lastError;
}

const data = await withRetry(() => fetchData(url));
```

### Timeout Pattern

```javascript
function withTimeout(promise, ms) {
  const timeout = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Timeout')), ms);
  });

  return Promise.race([promise, timeout]);
}

try {
  const data = await withTimeout(fetchData(), 5000);
} catch (error) {
  if (error.message === 'Timeout') {
    handleTimeout();
  }
}
```

### Debounce Async

```javascript
function debounceAsync(fn, ms) {
  let timeoutId;
  let pendingPromise;

  return async function(...args) {
    clearTimeout(timeoutId);

    return new Promise((resolve, reject) => {
      timeoutId = setTimeout(async () => {
        try {
          const result = await fn.apply(this, args);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      }, ms);
    });
  };
}

const debouncedSearch = debounceAsync(searchAPI, 300);
```

### Queue Pattern

```javascript
class AsyncQueue {
  constructor(concurrency = 1) {
    this.concurrency = concurrency;
    this.running = 0;
    this.queue = [];
  }

  async add(fn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject });
      this.process();
    });
  }

  async process() {
    if (this.running >= this.concurrency || this.queue.length === 0) {
      return;
    }

    this.running++;
    const { fn, resolve, reject } = this.queue.shift();

    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.running--;
      this.process();
    }
  }
}

const queue = new AsyncQueue(3);
urls.forEach(url => queue.add(() => fetch(url)));
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `await` in loop | Sequential when parallel possible | Use `Promise.all()` |
| Forgotten `await` | Promise not awaited | Add `await` or return promise |
| `.then()` in async | Mixing styles | Use `await` consistently |
| No error handling | Unhandled rejections | Add try-catch or .catch() |
| Async IIFE everywhere | Unnecessary wrapper | Use top-level await (ESM) |
