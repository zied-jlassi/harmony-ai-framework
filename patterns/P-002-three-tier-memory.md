# P-002: Three-Tier Memory Hierarchy

> **Optimal memory architecture for LLM context management.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-002 |
| **Category** | Memory |
| **Complexity** | Medium |
| **Applicability** | All LLM applications |

---

## Problem

LLMs have limited context windows. Naive approaches either:
- Fill context with irrelevant history
- Lose important information from past interactions
- Have no persistence across sessions

---

## Solution

Three-tier memory hierarchy with different scopes and lifetimes:

```
┌─────────────────────────────────────────────────────────────────┐
│                    3-TIER MEMORY HIERARCHY                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ╔═══════════════════════════════════════════════════════════╗ │
│  ║              TIER 1: WORKING MEMORY                        ║ │
│  ║                   (In-Context)                             ║ │
│  ╠═══════════════════════════════════════════════════════════╣ │
│  ║  • Size: 10-20% of context window (~2000 tokens)          ║ │
│  ║  • Lifetime: Current message only                         ║ │
│  ║  • Content: Persona, task, immediate context              ║ │
│  ║  • Refresh: Every message                                 ║ │
│  ╚═══════════════════════════════════════════════════════════╝ │
│                           ▲                                     │
│                           │ JIT Loading                         │
│                           ▼                                     │
│  ╔═══════════════════════════════════════════════════════════╗ │
│  ║              TIER 2: SESSION MEMORY                        ║ │
│  ║               (External, Compressed)                       ║ │
│  ╠═══════════════════════════════════════════════════════════╣ │
│  ║  • Size: Unlimited (compressed)                           ║ │
│  ║  • Lifetime: Current session                              ║ │
│  ║  • Content: Summarized history, decisions                 ║ │
│  ║  • Access: Semantic retrieval                             ║ │
│  ╚═══════════════════════════════════════════════════════════╝ │
│                           ▲                                     │
│                           │ Semantic Retrieval                  │
│                           ▼                                     │
│  ╔═══════════════════════════════════════════════════════════╗ │
│  ║              TIER 3: LONG-TERM MEMORY                      ║ │
│  ║                  (Persistent)                              ║ │
│  ╠═══════════════════════════════════════════════════════════╣ │
│  ║  • Size: Unlimited                                        ║ │
│  ║  • Lifetime: Permanent (versioned)                        ║ │
│  ║  • Content: Errors, patterns, preferences, ADRs           ║ │
│  ║  • Access: Indexed, queryable                             ║ │
│  ╚═══════════════════════════════════════════════════════════╝ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tier Details

### Tier 1: Working Memory

```json
{
  "persona": "Developer (Developer)",
  "current_task": "Implement user profile editing",
  "active_story": "STORY-042",
  "constraints": ["TypeScript strict", "No any types"],
  "recent_context": "Last 5 messages"
}
```

### Tier 2: Session Memory

```json
{
  "session_id": "sess-2025-01-15",
  "summary": "Working on user management feature...",
  "decisions": [
    "Using modal instead of inline form",
    "Email validation with zod"
  ],
  "current_sprint": "Sprint-5"
}
```

### Tier 3: Long-Term Memory

```json
{
  "error_journal": [...],
  "learned_patterns": [...],
  "user_preferences": {...},
  "architecture_decisions": [...]
}
```

---

## Memory Operations

### Load (JIT)

```typescript
function loadWorkingMemory(message: string): WorkingMemory {
  const topics = extractTopics(message);

  return {
    persona: getCurrentAgent(),
    task: parseTask(message),
    relevantPatterns: tier3.query(topics),
    relevantHistory: tier2.retrieve(topics, limit=5)
  };
}
```

### Compress (Session → Long-term)

```typescript
function compressSession(messages: Message[]): void {
  const summary = llm.summarize(messages);
  tier2.save({ summary, timestamp: now() });

  // Extract learnings for long-term
  const patterns = extractPatterns(messages);
  tier3.save(patterns);
}
```

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Context efficiency** | Only load what's needed |
| **Persistence** | Knowledge survives sessions |
| **Learning** | Patterns extracted and reused |
| **Scalability** | Handles unlimited history |

---

## Related Patterns

- [P-003: JIT Context Loading](P-003-jit-context.md)
- [P-005: Closed-Loop Learning](P-005-closed-loop.md)

