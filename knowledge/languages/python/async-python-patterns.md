---
name: async-python-patterns
displayName: "Async Python Patterns"
category: python-development
tier: 3
model: sonnet
triggers:
  - "asyncio"
  - "async python"
  - "await"
  - "concurrent python"
  - "aiohttp"
---

# Async Python Patterns

> Master Python asyncio and concurrency patterns.

## Asyncio Basics

```python
import asyncio

# Basic async function
async def fetch_data(url: str) -> dict:
    await asyncio.sleep(1)  # Simulate I/O
    return {"url": url, "data": "..."}

# Running async code
async def main():
    result = await fetch_data("https://api.example.com")
    print(result)

# Entry point
asyncio.run(main())
```

## Concurrent Execution

### gather (run concurrently)
```python
async def main():
    # Run all concurrently, wait for all
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        fetch_data("url3"),
    )
    # results = [result1, result2, result3]

    # With exception handling
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        return_exceptions=True  # Don't fail on first exception
    )
```

### TaskGroup (Python 3.11+)
```python
async def main():
    async with asyncio.TaskGroup() as tg:
        task1 = tg.create_task(fetch_data("url1"))
        task2 = tg.create_task(fetch_data("url2"))
        task3 = tg.create_task(fetch_data("url3"))

    # All tasks complete when exiting context
    print(task1.result(), task2.result(), task3.result())
```

### as_completed (process as ready)
```python
async def main():
    tasks = [
        fetch_data("url1"),
        fetch_data("url2"),
        fetch_data("url3"),
    ]

    for coro in asyncio.as_completed(tasks):
        result = await coro
        print(f"Got result: {result}")  # Process as each completes
```

### wait (with timeout/conditions)
```python
async def main():
    tasks = [
        asyncio.create_task(fetch_data("url1")),
        asyncio.create_task(fetch_data("url2")),
    ]

    # Wait with timeout
    done, pending = await asyncio.wait(
        tasks,
        timeout=5.0,
        return_when=asyncio.FIRST_COMPLETED
    )

    for task in pending:
        task.cancel()
```

## Semaphores (Rate Limiting)

```python
async def fetch_with_limit(url: str, semaphore: asyncio.Semaphore):
    async with semaphore:  # Limit concurrent requests
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                return await response.json()

async def main():
    semaphore = asyncio.Semaphore(10)  # Max 10 concurrent

    urls = ["url1", "url2", ...]  # 100 URLs
    tasks = [fetch_with_limit(url, semaphore) for url in urls]
    results = await asyncio.gather(*tasks)
```

## Queues

```python
async def producer(queue: asyncio.Queue):
    for i in range(10):
        await queue.put(f"item_{i}")
        await asyncio.sleep(0.1)
    await queue.put(None)  # Signal completion

async def consumer(queue: asyncio.Queue, name: str):
    while True:
        item = await queue.get()
        if item is None:
            queue.task_done()
            break
        print(f"{name} processing {item}")
        await asyncio.sleep(0.5)
        queue.task_done()

async def main():
    queue = asyncio.Queue(maxsize=5)

    # Start producer and consumers
    await asyncio.gather(
        producer(queue),
        consumer(queue, "consumer1"),
        consumer(queue, "consumer2"),
    )
```

## Async Context Managers

```python
class AsyncDatabase:
    async def __aenter__(self):
        self.connection = await create_connection()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.connection.close()

    async def query(self, sql: str):
        return await self.connection.execute(sql)

# Usage
async with AsyncDatabase() as db:
    results = await db.query("SELECT * FROM users")
```

## Async Iterators

```python
class AsyncPaginator:
    def __init__(self, url: str, page_size: int = 10):
        self.url = url
        self.page_size = page_size
        self.page = 0

    def __aiter__(self):
        return self

    async def __anext__(self):
        self.page += 1
        data = await fetch_page(self.url, self.page, self.page_size)
        if not data:
            raise StopAsyncIteration
        return data

# Usage
async for page in AsyncPaginator("https://api.example.com/items"):
    for item in page:
        process(item)
```

## HTTP Client (aiohttp)

```python
import aiohttp

async def fetch_all(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = []
        for url in urls:
            tasks.append(fetch_one(session, url))
        return await asyncio.gather(*tasks)

async def fetch_one(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url) as response:
        response.raise_for_status()
        return await response.json()

# With retry
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=1, max=10))
async def fetch_with_retry(session: aiohttp.ClientSession, url: str):
    async with session.get(url) as response:
        response.raise_for_status()
        return await response.json()
```

## Async Testing

```python
import pytest

@pytest.mark.asyncio
async def test_fetch_data():
    result = await fetch_data("https://api.example.com")
    assert result is not None
    assert "data" in result

# With fixtures
@pytest.fixture
async def db_connection():
    conn = await create_connection()
    yield conn
    await conn.close()

@pytest.mark.asyncio
async def test_query(db_connection):
    result = await db_connection.query("SELECT 1")
    assert result == 1
```

## Common Patterns

### Timeout Wrapper
```python
async def with_timeout(coro, timeout: float):
    try:
        return await asyncio.wait_for(coro, timeout=timeout)
    except asyncio.TimeoutError:
        raise TimeoutError(f"Operation timed out after {timeout}s")
```

### Retry with Backoff
```python
async def retry_async(coro_func, max_retries=3, base_delay=1):
    for attempt in range(max_retries):
        try:
            return await coro_func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            await asyncio.sleep(delay)
```

### Background Tasks
```python
class BackgroundTaskManager:
    def __init__(self):
        self.tasks: set[asyncio.Task] = set()

    def add_task(self, coro):
        task = asyncio.create_task(coro)
        self.tasks.add(task)
        task.add_done_callback(self.tasks.discard)

    async def shutdown(self):
        for task in self.tasks:
            task.cancel()
        await asyncio.gather(*self.tasks, return_exceptions=True)
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Don't block** | Use async libraries for I/O |
| **Use TaskGroup** | Python 3.11+ for structured concurrency |
| **Limit concurrency** | Semaphores for rate limiting |
| **Handle cancellation** | Catch CancelledError when needed |
| **Timeout everything** | Use wait_for with timeouts |
| **Reuse sessions** | Share aiohttp sessions |
| **Test async code** | Use pytest-asyncio |
