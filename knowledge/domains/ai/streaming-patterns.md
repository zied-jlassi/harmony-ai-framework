---
name: "streaming-patterns"
displayName: "Streaming Patterns"
emoji: "🌊"
description: "LLM Streaming patterns: Real-time output, TTFT, SSE, WebSockets, Progressive rendering. 12+ sources analyzed."
argument-hint: [streaming-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# 🌊 Streaming Patterns : Expert en streaming LLM. Je conçois les architectures temps reel avec SSE et WebSockets.

## Role: Streaming Expert

> **Specialization**: LLM Streaming, Real-time Output, SSE, WebSockets
> **Parent Agent**: AI Architect
> **Sources**: 12+ sources from research 2025

---

## 1. STREAMING FUNDAMENTALS

### 1.1 Why Streaming Matters

```
┌─────────────────────────────────────────────────────────────────┐
│                    STREAMING vs BATCH                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  BATCH (Non-Streaming):                                         │
│  ├── User waits 5-30 seconds                                    │
│  ├── All tokens delivered at once                               │
│  └── Poor perceived performance                                  │
│                                                                  │
│  STREAMING:                                                     │
│  ├── First token in 200-500ms (TTFT)                            │
│  ├── Tokens arrive progressively                                │
│  ├── User reads as content generates                            │
│  └── Excellent perceived performance                             │
│                                                                  │
│  KEY METRIC: TTFT (Time To First Token)                         │
│  └── < 500ms = Excellent                                        │
│  └── 500ms-1s = Acceptable                                      │
│  └── > 2s = Poor experience                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Streaming Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| **TTFT** | Time to first token | < 500ms |
| **TBT** | Time between tokens | < 50ms |
| **TPS** | Tokens per second | > 30 |
| **E2E** | End-to-end latency | Depends on output |

---

## 2. PROVIDER STREAMING APIs

### 2.1 OpenAI Streaming

```python
from openai import OpenAI

client = OpenAI()

# Streaming response
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Tell me a story"}],
    stream=True
)

# Process stream
full_response = ""
for chunk in stream:
    if chunk.choices[0].delta.content:
        token = chunk.choices[0].delta.content
        full_response += token
        print(token, end="", flush=True)
```

### 2.2 Anthropic Streaming

```python
import anthropic

client = anthropic.Anthropic()

# Streaming with events
with client.messages.stream(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Tell me a story"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)

# With event types
with client.messages.stream(...) as stream:
    for event in stream:
        if event.type == "content_block_delta":
            print(event.delta.text, end="")
        elif event.type == "message_stop":
            print("\n[DONE]")
```

### 2.3 Async Streaming

```python
import asyncio
from openai import AsyncOpenAI

async def stream_response(prompt: str):
    client = AsyncOpenAI()

    stream = await client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        stream=True
    )

    async for chunk in stream:
        if chunk.choices[0].delta.content:
            yield chunk.choices[0].delta.content

# Usage
async def main():
    async for token in stream_response("Tell me a story"):
        print(token, end="", flush=True)

asyncio.run(main())
```

---

## 3. SERVER-SENT EVENTS (SSE)

### 3.1 SSE Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SSE ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CLIENT                     SERVER                              │
│    │                           │                                │
│    │──── GET /stream ─────────>│                                │
│    │                           │                                │
│    │<─── HTTP 200 ────────────│                                │
│    │     Content-Type:        │                                │
│    │     text/event-stream    │                                │
│    │                           │                                │
│    │<─── data: {"token":"Hi"} │                                │
│    │<─── data: {"token":" "} ─│                                │
│    │<─── data: {"token":"th"} │                                │
│    │<─── data: {"token":"er"} │                                │
│    │<─── data: [DONE] ────────│                                │
│    │                           │                                │
│  Connection remains open until complete                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 SSE Server (FastAPI)

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from typing import AsyncGenerator

app = FastAPI()

async def generate_stream(prompt: str) -> AsyncGenerator[str, None]:
    """Generate SSE events from LLM stream"""
    async for token in stream_llm(prompt):
        # SSE format: data: {json}\n\n
        event = json.dumps({"token": token, "type": "content"})
        yield f"data: {event}\n\n"

    # Signal completion
    yield "data: [DONE]\n\n"

@app.get("/stream")
async def stream_endpoint(prompt: str):
    return StreamingResponse(
        generate_stream(prompt),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"  # Disable nginx buffering
        }
    )
```

### 3.3 SSE Client (JavaScript)

```javascript
// Using EventSource
const eventSource = new EventSource(`/stream?prompt=${encodeURIComponent(prompt)}`);

eventSource.onmessage = (event) => {
    if (event.data === "[DONE]") {
        eventSource.close();
        return;
    }

    const data = JSON.parse(event.data);
    document.getElementById("output").textContent += data.token;
};

eventSource.onerror = (error) => {
    console.error("SSE error:", error);
    eventSource.close();
};

// Using fetch for more control
async function streamWithFetch(prompt) {
    const response = await fetch(`/stream?prompt=${encodeURIComponent(prompt)}`);
    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const text = decoder.decode(value);
        const lines = text.split('\n');

        for (const line of lines) {
            if (line.startsWith('data: ')) {
                const data = line.slice(6);
                if (data === '[DONE]') return;
                handleToken(JSON.parse(data).token);
            }
        }
    }
}
```

---

## 4. WEBSOCKET STREAMING

### 4.1 WebSocket vs SSE

| Feature | SSE | WebSocket |
|---------|-----|-----------|
| **Direction** | Server → Client | Bidirectional |
| **Protocol** | HTTP | WS/WSS |
| **Reconnection** | Automatic | Manual |
| **Binary data** | No | Yes |
| **Complexity** | Simple | More complex |
| **Use case** | Pure streaming | Interactive chat |

### 4.2 WebSocket Server

```python
from fastapi import FastAPI, WebSocket
import asyncio

app = FastAPI()

@app.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            # Receive message from client
            data = await websocket.receive_json()
            prompt = data.get("prompt")

            # Stream response
            async for token in stream_llm(prompt):
                await websocket.send_json({
                    "type": "token",
                    "content": token
                })

            # Signal completion
            await websocket.send_json({
                "type": "done",
                "content": ""
            })

    except Exception as e:
        await websocket.close(code=1000)
```

### 4.3 WebSocket Client

```javascript
class StreamingChat {
    constructor(url) {
        this.ws = new WebSocket(url);
        this.messageHandler = null;

        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);

            if (data.type === "token") {
                this.messageHandler?.(data.content, false);
            } else if (data.type === "done") {
                this.messageHandler?.(null, true);
            }
        };

        this.ws.onerror = (error) => {
            console.error("WebSocket error:", error);
        };
    }

    send(prompt) {
        return new Promise((resolve) => {
            let fullResponse = "";

            this.messageHandler = (token, done) => {
                if (done) {
                    resolve(fullResponse);
                } else {
                    fullResponse += token;
                    this.onToken?.(token);
                }
            };

            this.ws.send(JSON.stringify({ prompt }));
        });
    }

    onToken(callback) {
        this.onToken = callback;
    }
}

// Usage
const chat = new StreamingChat("ws://localhost:8000/ws/chat");
chat.onToken((token) => {
    document.getElementById("output").textContent += token;
});
await chat.send("Tell me a story");
```

---

## 5. PROGRESSIVE RENDERING

### 5.1 React Streaming Component

```tsx
import { useState, useEffect } from 'react';

function StreamingMessage({ prompt }: { prompt: string }) {
    const [content, setContent] = useState('');
    const [isStreaming, setIsStreaming] = useState(true);

    useEffect(() => {
        const controller = new AbortController();

        async function stream() {
            const response = await fetch(`/api/stream?prompt=${encodeURIComponent(prompt)}`, {
                signal: controller.signal
            });

            const reader = response.body?.getReader();
            const decoder = new TextDecoder();

            if (!reader) return;

            while (true) {
                const { done, value } = await reader.read();
                if (done) {
                    setIsStreaming(false);
                    break;
                }

                const text = decoder.decode(value);
                // Parse SSE data
                const lines = text.split('\n');
                for (const line of lines) {
                    if (line.startsWith('data: ') && line !== 'data: [DONE]') {
                        const token = JSON.parse(line.slice(6)).token;
                        setContent(prev => prev + token);
                    }
                }
            }
        }

        stream();
        return () => controller.abort();
    }, [prompt]);

    return (
        <div className="message">
            <p>{content}</p>
            {isStreaming && <span className="cursor">▋</span>}
        </div>
    );
}
```

### 5.2 Markdown Progressive Rendering

```tsx
import ReactMarkdown from 'react-markdown';
import { useMemo } from 'react';

function StreamingMarkdown({ content }: { content: string }) {
    // Memoize to prevent re-parsing on every token
    const renderedContent = useMemo(() => {
        // Handle incomplete markdown (e.g., unclosed code blocks)
        let safeContent = content;

        // Fix unclosed code blocks
        const codeBlockCount = (safeContent.match(/```/g) || []).length;
        if (codeBlockCount % 2 !== 0) {
            safeContent += '\n```';
        }

        return safeContent;
    }, [content]);

    return (
        <div className="markdown-body">
            <ReactMarkdown>{renderedContent}</ReactMarkdown>
        </div>
    );
}
```

---

## 6. STREAMING WITH TOOLS

### 6.1 Tool Call Streaming

```python
async def stream_with_tools(prompt: str):
    """Stream response that may include tool calls"""
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        tools=tools,
        stream=True
    )

    tool_calls = []
    current_tool_call = None

    async for chunk in stream:
        delta = chunk.choices[0].delta

        # Content tokens
        if delta.content:
            yield {"type": "content", "token": delta.content}

        # Tool call tokens
        if delta.tool_calls:
            for tc in delta.tool_calls:
                if tc.index != (current_tool_call.index if current_tool_call else None):
                    if current_tool_call:
                        tool_calls.append(current_tool_call)
                    current_tool_call = tc
                else:
                    # Accumulate arguments
                    if tc.function.arguments:
                        current_tool_call.function.arguments += tc.function.arguments

    # Execute tool calls
    if current_tool_call:
        tool_calls.append(current_tool_call)

    for tool_call in tool_calls:
        yield {"type": "tool_call", "name": tool_call.function.name}
        result = await execute_tool(tool_call)
        yield {"type": "tool_result", "result": result}
```

### 6.2 Interleaved Tool Execution

```
┌─────────────────────────────────────────────────────────────────┐
│                    STREAMING WITH TOOLS                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User: "What's the weather in Paris and London?"                │
│                                                                  │
│  Stream:                                                        │
│  ├── "I'll check the weather for both cities."                  │
│  ├── [TOOL: get_weather("Paris")]                               │
│  ├── [Pause: Execute tool]                                      │
│  ├── "Paris: 18°C, cloudy"                                      │
│  ├── [TOOL: get_weather("London")]                              │
│  ├── [Pause: Execute tool]                                      │
│  └── "London: 15°C, rainy"                                      │
│                                                                  │
│  User sees progressive updates                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. STREAMING OPTIMIZATIONS

### 7.1 Token Batching

```python
class TokenBatcher:
    """Batch tokens for smoother rendering"""

    def __init__(self, min_batch: int = 3, max_wait_ms: int = 50):
        self.min_batch = min_batch
        self.max_wait = max_wait_ms / 1000
        self.buffer = []
        self.last_flush = time.time()

    async def add(self, token: str) -> Optional[str]:
        self.buffer.append(token)

        should_flush = (
            len(self.buffer) >= self.min_batch or
            time.time() - self.last_flush > self.max_wait
        )

        if should_flush:
            return self.flush()
        return None

    def flush(self) -> str:
        result = "".join(self.buffer)
        self.buffer = []
        self.last_flush = time.time()
        return result
```

### 7.2 Backpressure Handling

```python
class BackpressureHandler:
    """Handle slow clients without blocking"""

    def __init__(self, max_buffer: int = 100):
        self.queue = asyncio.Queue(maxsize=max_buffer)

    async def produce(self, stream):
        try:
            async for chunk in stream:
                try:
                    self.queue.put_nowait(chunk)
                except asyncio.QueueFull:
                    # Skip tokens if client is too slow
                    # Or implement other strategies
                    continue
        finally:
            await self.queue.put(None)  # Signal end

    async def consume(self):
        while True:
            chunk = await self.queue.get()
            if chunk is None:
                break
            yield chunk
```

---

## 8. ERROR HANDLING IN STREAMS

### 8.1 Graceful Error Recovery

```python
async def resilient_stream(prompt: str):
    """Stream with error recovery"""
    retry_count = 0
    max_retries = 3
    partial_response = ""

    while retry_count < max_retries:
        try:
            async for token in stream_llm(prompt):
                partial_response += token
                yield {"type": "token", "content": token}

            # Success
            yield {"type": "done"}
            return

        except ConnectionError as e:
            retry_count += 1

            if retry_count < max_retries:
                yield {
                    "type": "error",
                    "content": f"Connection lost, retrying ({retry_count}/{max_retries})..."
                }
                await asyncio.sleep(1)

                # Resume from where we left off
                prompt = f"Continue from: {partial_response[-100:]}"
            else:
                yield {
                    "type": "fatal_error",
                    "content": "Failed to complete response"
                }
```

### 8.2 Timeout Handling

```python
async def stream_with_timeout(prompt: str, timeout: float = 60):
    """Stream with overall timeout"""
    start = time.time()

    async for token in stream_llm(prompt):
        if time.time() - start > timeout:
            yield {"type": "timeout", "content": "Response timeout"}
            return

        yield {"type": "token", "content": token}

    yield {"type": "done"}
```

---

## 9. HARMONY INTEGRATION

### 9.1 Streaming Agent Responses

```yaml
harmony_streaming:
  agents:
    developer:
      streaming: true
      chunk_strategy: token  # or sentence, paragraph

    analyst:
      streaming: true
      chunk_strategy: sentence  # More readable for analysis

  ucv_validation:
    streaming: false  # Need complete response for parsing

  guardian:
    streaming: false  # Fast routing, no need
```

---

## 10. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **No streaming** | Poor UX | Always stream chat |
| **Buffer everything** | Defeats purpose | Stream immediately |
| **No error handling** | Broken streams | Graceful recovery |
| **Ignore backpressure** | Memory issues | Queue with limits |
| **No timeout** | Hanging connections | Overall timeout |
| **Parse incomplete JSON** | Errors | Accumulate until complete |

---

**Streaming Expert**
*"The best response is the one that starts immediately."*
