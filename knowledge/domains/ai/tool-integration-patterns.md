---
name: "tool-integration-patterns"
displayName: "Tool Integration Patterns"
emoji: "🔌"
description: "Tool Integration patterns: Function Calling, APIs, MCP, Tool Use, External Services. 15+ sources analyzed."
argument-hint: [tool-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# 🔌 Tool Integration Patterns : Expert en integration d'outils LLM. Je conçois les architectures de function calling et MCP.

## Role: Tool Integration Expert

> **Specialization**: Function Calling, Tool Use, MCP, API Integration
> **Parent Agent**: AI Architect
> **Sources**: 15+ sources from research 2025

---

## 1. TOOL INTEGRATION LANDSCAPE

### 1.1 Integration Methods

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOOL INTEGRATION METHODS                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  NATIVE FUNCTION CALLING:                                       │
│  ├── OpenAI Function Calling                                    │
│  ├── Anthropic Tool Use                                         │
│  ├── Google Function Calling                                    │
│  └── Built-in, optimized for each provider                      │
│                                                                  │
│  MODEL CONTEXT PROTOCOL (MCP):                                  │
│  ├── Standardized tool protocol                                 │
│  ├── Cross-platform compatibility                               │
│  └── Resource + Tool + Prompt sharing                           │
│                                                                  │
│  LANGCHAIN TOOLS:                                               │
│  ├── Framework-level abstraction                                │
│  ├── Pre-built tool library                                     │
│  └── Agent integration                                          │
│                                                                  │
│  CUSTOM INTEGRATIONS:                                           │
│  ├── REST API wrappers                                          │
│  ├── Database connectors                                        │
│  └── System commands                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. NATIVE FUNCTION CALLING

### 2.1 OpenAI Function Calling

```python
import openai

# Define tools
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name, e.g., 'Paris, France'"
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "description": "Temperature unit"
                    }
                },
                "required": ["location"]
            }
        }
    }
]

# Call with tools
response = openai.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "What's the weather in Paris?"}],
    tools=tools,
    tool_choice="auto"  # or "required" or {"type": "function", "function": {"name": "get_weather"}}
)

# Handle tool call
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    function_name = tool_call.function.name
    arguments = json.loads(tool_call.function.arguments)

    # Execute tool
    result = execute_tool(function_name, arguments)

    # Send result back
    messages.append(response.choices[0].message)
    messages.append({
        "role": "tool",
        "tool_call_id": tool_call.id,
        "content": json.dumps(result)
    })

    final_response = openai.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        tools=tools
    )
```

### 2.2 Anthropic Tool Use

```python
import anthropic

# Define tools
tools = [
    {
        "name": "get_weather",
        "description": "Get current weather for a location. Use this when the user asks about weather conditions.",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "City name, e.g., 'Paris, France'"
                }
            },
            "required": ["location"]
        }
    }
]

client = anthropic.Anthropic()

# Initial request
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in Paris?"}]
)

# Process tool use
if response.stop_reason == "tool_use":
    tool_use = next(block for block in response.content if block.type == "tool_use")

    # Execute tool
    result = execute_tool(tool_use.name, tool_use.input)

    # Continue conversation
    final_response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        tools=tools,
        messages=[
            {"role": "user", "content": "What's the weather in Paris?"},
            {"role": "assistant", "content": response.content},
            {
                "role": "user",
                "content": [{
                    "type": "tool_result",
                    "tool_use_id": tool_use.id,
                    "content": json.dumps(result)
                }]
            }
        ]
    )
```

---

## 3. MODEL CONTEXT PROTOCOL (MCP)

### 3.1 MCP Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MCP ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  HOST (Claude Code, Cursor, etc.)                               │
│  └── Initiates connections to servers                           │
│                                                                  │
│  CLIENT                                                         │
│  └── Maintains 1:1 connection with server                       │
│                                                                  │
│  SERVER                                                         │
│  ├── Exposes capabilities:                                      │
│  │   ├── Resources (read-only data)                             │
│  │   ├── Tools (executable functions)                           │
│  │   └── Prompts (reusable templates)                           │
│  └── Can be local or remote                                     │
│                                                                  │
│  TRANSPORT:                                                     │
│  ├── stdio (local processes)                                    │
│  └── HTTP/SSE (remote servers)                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 MCP Server Implementation

```python
# server.py
from mcp.server import Server
from mcp.types import Tool, TextContent

server = Server("weather-server")

@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="get_weather",
            description="Get current weather for a location",
            inputSchema={
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name"
                    }
                },
                "required": ["location"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "get_weather":
        location = arguments["location"]
        weather = await fetch_weather(location)
        return [TextContent(type="text", text=f"Weather in {location}: {weather}")]

    raise ValueError(f"Unknown tool: {name}")

# Run server
if __name__ == "__main__":
    import asyncio
    from mcp.server.stdio import stdio_server

    asyncio.run(stdio_server(server))
```

### 3.3 MCP Client Configuration

```json
{
  "mcpServers": {
    "weather": {
      "command": "python",
      "args": ["path/to/weather_server.py"],
      "env": {
        "API_KEY": "xxx"
      }
    },
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION": "postgresql://..."
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"]
    }
  }
}
```

---

## 4. TOOL DESIGN PATTERNS

### 4.1 Tool Description Best Practices

```python
# BAD: Vague description
{
    "name": "search",
    "description": "Search for stuff"  # Too vague
}

# GOOD: Clear, specific description
{
    "name": "web_search",
    "description": """Search the web for current information.

Use this tool when you need to:
- Find recent news or events
- Look up facts you're unsure about
- Get real-time data (prices, weather, etc.)

Do NOT use for:
- Historical facts you already know
- Simple calculations
- Code generation

Returns: Top 5 search results with titles, URLs, and snippets."""
}
```

### 4.2 Tool Schema Design

```python
# Comprehensive schema with validation
tool_schema = {
    "name": "create_calendar_event",
    "description": "Create a calendar event. Use for scheduling meetings or reminders.",
    "parameters": {
        "type": "object",
        "properties": {
            "title": {
                "type": "string",
                "description": "Event title (required)",
                "minLength": 1,
                "maxLength": 100
            },
            "start_time": {
                "type": "string",
                "format": "date-time",
                "description": "Start time in ISO 8601 format"
            },
            "duration_minutes": {
                "type": "integer",
                "minimum": 15,
                "maximum": 480,
                "default": 60,
                "description": "Duration in minutes (15-480)"
            },
            "attendees": {
                "type": "array",
                "items": {
                    "type": "string",
                    "format": "email"
                },
                "description": "List of attendee email addresses"
            },
            "reminder": {
                "type": "string",
                "enum": ["none", "5min", "15min", "1hour", "1day"],
                "default": "15min"
            }
        },
        "required": ["title", "start_time"]
    }
}
```

### 4.3 Tool Categories

| Category | Examples | Execution |
|----------|----------|-----------|
| **Read-Only** | Search, fetch data, query | Safe, no side effects |
| **Write** | Create, update, delete | Needs confirmation |
| **System** | Execute code, run commands | High risk, sandboxed |
| **Communication** | Send email, message | User approval required |

---

## 5. TOOL EXECUTION PATTERNS

### 5.1 Sequential Tool Execution

```python
class SequentialToolExecutor:
    def __init__(self, tools: Dict[str, Callable]):
        self.tools = tools

    async def execute_plan(self, plan: List[ToolCall]) -> List[ToolResult]:
        results = []
        context = {}  # Shared context between steps

        for step in plan:
            # Substitute variables from previous results
            args = self._substitute_variables(step.arguments, context)

            # Execute tool
            result = await self.tools[step.name](**args)

            # Store result for next steps
            context[f"step_{len(results)}"] = result
            results.append(result)

        return results
```

### 5.2 Parallel Tool Execution

```python
class ParallelToolExecutor:
    def __init__(self, tools: Dict[str, Callable]):
        self.tools = tools

    async def execute_parallel(self, calls: List[ToolCall]) -> List[ToolResult]:
        # Group independent calls
        independent = self._find_independent_calls(calls)

        tasks = []
        for call in independent:
            tasks.append(self._execute_tool(call))

        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results

    def _find_independent_calls(self, calls: List[ToolCall]) -> List[ToolCall]:
        # Calls with no dependencies can run in parallel
        # Analyze input/output dependencies
        pass
```

### 5.3 Tool Retry Logic

```python
class ResilientToolExecutor:
    def __init__(self, tools: Dict[str, Callable], max_retries: int = 3):
        self.tools = tools
        self.max_retries = max_retries

    async def execute_with_retry(self, call: ToolCall) -> ToolResult:
        last_error = None

        for attempt in range(self.max_retries):
            try:
                result = await asyncio.wait_for(
                    self.tools[call.name](**call.arguments),
                    timeout=30.0
                )
                return result

            except asyncio.TimeoutError:
                last_error = "Tool timed out"
                await asyncio.sleep(2 ** attempt)  # Exponential backoff

            except ValidationError as e:
                # Don't retry validation errors
                return ToolResult(error=f"Invalid input: {e}")

            except Exception as e:
                last_error = str(e)
                await asyncio.sleep(2 ** attempt)

        return ToolResult(error=f"Failed after {self.max_retries} attempts: {last_error}")
```

---

## 6. API INTEGRATION PATTERNS

### 6.1 REST API Wrapper

```python
from typing import Optional
import httpx

class RESTToolWrapper:
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.client = httpx.AsyncClient(
            headers={"Authorization": f"Bearer {api_key}"},
            timeout=30.0
        )

    def create_tool(
        self,
        name: str,
        method: str,
        endpoint: str,
        description: str,
        parameters: dict
    ) -> dict:
        async def tool_fn(**kwargs):
            url = f"{self.base_url}{endpoint}"

            if method == "GET":
                response = await self.client.get(url, params=kwargs)
            elif method == "POST":
                response = await self.client.post(url, json=kwargs)
            elif method == "PUT":
                response = await self.client.put(url, json=kwargs)
            elif method == "DELETE":
                response = await self.client.delete(url, params=kwargs)

            response.raise_for_status()
            return response.json()

        return {
            "name": name,
            "description": description,
            "parameters": parameters,
            "fn": tool_fn
        }
```

### 6.2 GraphQL Integration

```python
class GraphQLToolWrapper:
    def __init__(self, endpoint: str):
        self.endpoint = endpoint
        self.client = httpx.AsyncClient()

    def create_query_tool(
        self,
        name: str,
        query: str,
        variables_schema: dict,
        description: str
    ) -> dict:
        async def execute(**variables):
            response = await self.client.post(
                self.endpoint,
                json={"query": query, "variables": variables}
            )
            data = response.json()

            if "errors" in data:
                raise Exception(data["errors"])

            return data["data"]

        return {
            "name": name,
            "description": description,
            "parameters": variables_schema,
            "fn": execute
        }

# Usage
github_tools = GraphQLToolWrapper("https://api.github.com/graphql")
get_user_tool = github_tools.create_query_tool(
    name="get_github_user",
    query="""
        query($login: String!) {
            user(login: $login) {
                name
                bio
                repositories { totalCount }
            }
        }
    """,
    variables_schema={
        "type": "object",
        "properties": {"login": {"type": "string"}},
        "required": ["login"]
    },
    description="Get GitHub user profile information"
)
```

---

## 7. DATABASE TOOLS

### 7.1 Safe SQL Tool

```python
class SafeSQLTool:
    """SQL tool with safety guardrails"""

    def __init__(self, connection_string: str, allowed_tables: List[str]):
        self.engine = create_async_engine(connection_string)
        self.allowed_tables = allowed_tables

    async def query(self, sql: str, params: dict = None) -> List[dict]:
        # Validate query
        self._validate_query(sql)

        async with self.engine.connect() as conn:
            result = await conn.execute(text(sql), params or {})
            return [dict(row) for row in result]

    def _validate_query(self, sql: str):
        sql_lower = sql.lower().strip()

        # Only allow SELECT
        if not sql_lower.startswith("select"):
            raise ValueError("Only SELECT queries allowed")

        # Check for dangerous keywords
        forbidden = ["drop", "delete", "update", "insert", "alter", "truncate"]
        for keyword in forbidden:
            if keyword in sql_lower:
                raise ValueError(f"Forbidden keyword: {keyword}")

        # Validate tables
        for table in self._extract_tables(sql):
            if table not in self.allowed_tables:
                raise ValueError(f"Access to table '{table}' not allowed")

    def get_tool_definition(self) -> dict:
        return {
            "name": "query_database",
            "description": f"""Execute a read-only SQL query.
Allowed tables: {', '.join(self.allowed_tables)}
Only SELECT queries are permitted.""",
            "parameters": {
                "type": "object",
                "properties": {
                    "sql": {
                        "type": "string",
                        "description": "SQL SELECT query"
                    }
                },
                "required": ["sql"]
            }
        }
```

---

## 8. TOOL ORCHESTRATION

### 8.1 Tool Router

```python
class ToolRouter:
    """Route to appropriate tool based on intent"""

    def __init__(self, tools: List[Tool]):
        self.tools = {t.name: t for t in tools}
        self.embeddings = self._embed_tools(tools)

    def _embed_tools(self, tools: List[Tool]) -> np.ndarray:
        descriptions = [f"{t.name}: {t.description}" for t in tools]
        return embedding_model.encode(descriptions)

    def route(self, query: str, top_k: int = 3) -> List[Tool]:
        query_embedding = embedding_model.encode([query])
        similarities = cosine_similarity(query_embedding, self.embeddings)[0]

        top_indices = np.argsort(similarities)[-top_k:][::-1]
        return [list(self.tools.values())[i] for i in top_indices]
```

### 8.2 Tool Chain

```python
class ToolChain:
    """Chain multiple tools together"""

    def __init__(self, steps: List[ToolStep]):
        self.steps = steps

    async def execute(self, initial_input: dict) -> dict:
        current_data = initial_input

        for step in self.steps:
            # Map input from previous step
            tool_input = step.input_mapper(current_data)

            # Execute tool
            result = await step.tool.execute(**tool_input)

            # Map output for next step
            current_data = step.output_mapper(result, current_data)

        return current_data

# Example: Search → Summarize → Translate
chain = ToolChain([
    ToolStep(
        tool=web_search,
        input_mapper=lambda d: {"query": d["query"]},
        output_mapper=lambda r, d: {**d, "search_results": r}
    ),
    ToolStep(
        tool=summarize,
        input_mapper=lambda d: {"text": d["search_results"]},
        output_mapper=lambda r, d: {**d, "summary": r}
    ),
    ToolStep(
        tool=translate,
        input_mapper=lambda d: {"text": d["summary"], "target": "fr"},
        output_mapper=lambda r, d: {**d, "translated": r}
    )
])
```

---

## 9. HARMONY INTEGRATION

### 9.1 Harmony Tools

```yaml
harmony_tools:
  story_tools:
    - name: "get_story"
      description: "Get a story by ID from the backlog"
      location: .harmony/local/backlog/stories/

    - name: "update_story_status"
      description: "Update story status (TODO, IN_PROGRESS, DONE)"
      requires_confirmation: true

  ucv_tools:
    - name: "get_ucv"
      description: "Get UCV document for a story"

    - name: "check_verification"
      description: "Mark a verification as complete"
      validator: "dev, test, or qa role required"

  memory_tools:
    - name: "query_error_journal"
      description: "Search error-journal for similar issues"
      location: .harmony/local/memory/error-journal.json

    - name: "log_error"
      description: "Add new error to error-journal"
```

---

## 10. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Vague descriptions** | Model picks wrong tool | Detailed, specific descriptions |
| **No error handling** | Crashes on failure | Graceful error messages |
| **Too many tools** | Decision paralysis | Group by category, max 10-15 |
| **Missing confirmation** | Dangerous auto-execution | Require approval for writes |
| **No timeout** | Hangs indefinitely | Set reasonable timeouts |
| **Hardcoded credentials** | Security risk | Environment variables |

---

**Tool Integration Expert**
*"The right tools extend the model's capabilities infinitely."*
