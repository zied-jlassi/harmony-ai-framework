# P-020: Parallel Execution Pattern

> **Guide for parallel task execution using Claude Code's Task tool.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Pattern ID** | P-020 |
| **Category** | Performance / Orchestration |
| **Status** | Active |
| **Added** | v1.1.0 (Harmony+) |

---

## Problem

Sequential task execution is slow for independent subtasks. When multiple subtasks have no dependencies between them, executing them one-by-one wastes time.

---

## Solution

Identify parallelizable work and execute concurrently via the Task tool with multiple subagents.

---

## When to Parallelize

### Good Candidates

| Scenario | Example |
|----------|---------|
| Multiple independent files | Implementing 3 separate components |
| Parallel test suites | Running unit, integration, e2e simultaneously |
| Research across areas | Exploring auth, caching, and logging patterns |
| Generating similar items | Creating multiple API endpoints |
| Verification tasks | Linting, type-checking, security scan |

### Bad Candidates

| Scenario | Why |
|----------|-----|
| Sequential dependencies | Task B needs Task A's output |
| Database migrations | Must run in order |
| State-dependent operations | Each step modifies shared state |
| Small quick tasks | Overhead exceeds benefit |
| Tasks requiring shared context | Subagents have isolated context |

---

## Implementation

### In implementation_plan.json

Use `parallel_group` to indicate which subtasks can run together:

```json
{
    "subtasks": [
        {"id": "1", "title": "Create user API", "parallel_group": 1, "depends_on": []},
        {"id": "2", "title": "Create product API", "parallel_group": 1, "depends_on": []},
        {"id": "3", "title": "Create order API", "parallel_group": 1, "depends_on": []},
        {"id": "4", "title": "Wire up frontend", "parallel_group": 2, "depends_on": ["1", "2", "3"]}
    ]
}
```

Execution:
1. Execute all group 1 tasks concurrently (3 parallel)
2. Wait for all group 1 to complete
3. Execute group 2 tasks (blocked until deps met)

### Using Task Tool

```markdown
# Spawn multiple subagents in parallel
Use Task tool with multiple invocations in a single message:

Task 1: "Implement user API in api/users.ts"
Task 2: "Implement product API in api/products.ts"
Task 3: "Implement order API in api/orders.ts"
```

### Subagent Best Practices

| Practice | Rationale |
|----------|-----------|
| Let Claude decide parallelism level | Don't force batch sizes |
| Use for disjoint tasks | Different files/modules work best |
| Each subagent has isolated context | Use this for large codebases |
| Maximum ~10 concurrent subagents | Practical limit |
| Use `run_in_background: true` | For long-running tasks |

---

## Detection Criteria

Subtasks are parallelizable when:

1. **No `depends_on`** - Subtask has empty or no dependency array
2. **Same `parallel_group`** - Multiple subtasks share the same group
3. **Different files** - Subtasks modify different files
4. **Independent services** - Subtasks target different services

---

## Example Workflow

```
Story: "Add analytics dashboard"
Complexity: STANDARD

Subtasks:
  Group 1 (parallel):
    - [1] Backend: Create analytics API
    - [2] Backend: Create aggregation service
    - [3] Frontend: Create chart components

  Group 2 (depends on Group 1):
    - [4] Integration: Wire dashboard to API

Execution:
  1. Spawn 3 subagents for Group 1
  2. Wait for all to complete
  3. Execute [4] after deps satisfied
```

---

## Anti-Patterns

| Anti-Pattern | Problem |
|--------------|---------|
| Parallel DB migrations | Order matters, data integrity at risk |
| Parallel file modifications | Same file by multiple agents = conflicts |
| Ignoring `depends_on` | Later task may fail without prerequisite |
| Too many subagents | Context fragmentation, coordination overhead |

---

## Harmony Integration

- **ARIA Detection**: Flags like `is_api`, `is_web` suggest parallelizable patterns
- **Complexity Level**: COMPLEX tasks more likely to benefit from parallelism
- **Circuit Breaker**: Monitor failures across parallel tasks
- **Sprint Tracker**: `can_run_parallel()` checks dependency satisfaction

---

## References

- Claude Code Task tool documentation
- P-001-hybrid-orchestration (agent coordination)
- P-004-circuit-breaker (failure monitoring)
