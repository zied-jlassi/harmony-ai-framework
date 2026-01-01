# P-001: Hybrid Orchestration Pattern

> **Combining Supervisor, Sequential, and Parallel patterns for intelligent agent coordination.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-001 |
| **Category** | Orchestration |
| **Complexity** | High |
| **Applicability** | Multi-agent systems |

---

## Problem

Traditional orchestration patterns each have limitations:
- **Supervisor only**: Single point of failure, routing overhead
- **Sequential only**: No parallelism, slow for independent tasks
- **Parallel only**: No coordination, can't handle dependencies

---

## Solution

Combine all three patterns intelligently based on task characteristics:

```
┌─────────────────────────────────────────────────────────────────┐
│                    HYBRID ORCHESTRATION                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│                    ┌─────────────┐                              │
│                    │  SUPERVISOR │  ← Intelligent routing       │
│                    │  (Guardian) │                              │
│                    └──────┬──────┘                              │
│                           │                                      │
│         ┌─────────────────┼─────────────────┐                   │
│         │                 │                 │                   │
│         ▼                 ▼                 ▼                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  SEQUENTIAL  │  │  PARALLEL    │  │  SEQUENTIAL  │          │
│  │              │  │              │  │              │          │
│  │ Analyst ───► │  │ Dev ════ Test  │ Clara ───►  │          │
│  │ Architect    │  │      ↓       │  │ Victor      │          │
│  │              │  │    Luna      │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  Phase 1-2            Phase 4            Phase 3               │
│  (Planning)         (Implementation)     (Quality)             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## When to Use Each Sub-Pattern

### Supervisor (Guardian)
- Initial request routing
- Phase gate enforcement
- Agent selection based on intent
- Error escalation

### Sequential
- Dependent tasks (A must complete before B)
- Handoff chains (Analyst → Architect → SM)
- Quality gates (Clara → User Approval → Dev)

### Parallel
- Independent subtasks
- Dev and Test working simultaneously
- Multiple code reviews

---

## Implementation

```typescript
interface Task {
  id: string;
  dependencies: string[];
  agent: string;
}

class HybridOrchestrator {
  async execute(tasks: Task[]): Promise<void> {
    // Group by dependencies
    const independent = tasks.filter(t => t.dependencies.length === 0);
    const dependent = tasks.filter(t => t.dependencies.length > 0);

    // Run independent tasks in parallel
    await Promise.all(independent.map(t => this.runTask(t)));

    // Run dependent tasks sequentially
    for (const task of this.topologicalSort(dependent)) {
      await this.runTask(task);
    }
  }
}
```

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Efficiency** | Parallel where possible, sequential where needed |
| **Flexibility** | Adapts to task characteristics |
| **Reliability** | Single point of control for routing |
| **Scalability** | Handles complex workflows |

---

## Related Patterns

- [P-002: Three-Tier Memory](P-002-three-tier-memory.md)
- [P-006: Intent Detection](P-006-intent-detection.md)

