# P-003: JIT Context Loading

> **Load context on-demand based on current task needs.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-003 |
| **Category** | Memory |
| **Complexity** | Medium |
| **Applicability** | Context-limited LLMs |

---

## Problem

Loading all available context wastes tokens:
- 90% of loaded context may be irrelevant
- Important context gets pushed out
- Increased latency and cost

---

## Solution

Extract topics from current message and load only relevant context:

```
┌─────────────────────────────────────────────────────────────────┐
│                    JIT CONTEXT LOADING                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: "Fix the authentication bug in login"                   │
│                                                                  │
│  STEP 1: TOPIC EXTRACTION                                       │
│          ├── Keywords: ["authentication", "bug", "login"]       │
│          ├── Intent: FIX                                        │
│          └── Domain: Auth                                       │
│                                                                  │
│  STEP 2: SEMANTIC QUERY                                         │
│          ├── Error journal: AUTH errors only                    │
│          ├── Patterns: Auth patterns only                       │
│          └── History: Auth-related messages                     │
│                                                                  │
│  STEP 3: CONTEXT ASSEMBLY                                       │
│          ├── Relevant errors: 3 (not 50)                        │
│          ├── Relevant patterns: 2 (not 20)                      │
│          └── Total tokens: 500 (not 5000)                       │
│                                                                  │
│  STEP 4: INJECT                                                 │
│          └── Add to working memory                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation

```typescript
interface ContextRequest {
  message: string;
  currentStory?: string;
  currentPhase: number;
}

interface LoadedContext {
  relevantErrors: Error[];
  relevantPatterns: Pattern[];
  relevantHistory: Message[];
  totalTokens: number;
}

async function loadContext(req: ContextRequest): Promise<LoadedContext> {
  // Step 1: Extract topics
  const topics = extractTopics(req.message);

  // Step 2: Query each memory tier
  const [errors, patterns, history] = await Promise.all([
    queryErrorJournal(topics, limit=5),
    queryPatterns(topics, limit=3),
    queryHistory(topics, limit=5)
  ]);

  // Step 3: Assemble and return
  return {
    relevantErrors: errors,
    relevantPatterns: patterns,
    relevantHistory: history,
    totalTokens: countTokens(errors, patterns, history)
  };
}

function extractTopics(message: string): string[] {
  // Simple keyword extraction
  const stopWords = ['the', 'a', 'an', 'is', 'are', 'was', 'were'];
  const words = message.toLowerCase().split(/\s+/);
  return words.filter(w => !stopWords.includes(w) && w.length > 3);
}
```

---

## Query Strategies

### By Similarity

```typescript
// Semantic search using embeddings
const results = await vectorStore.query({
  embedding: embed(message),
  topK: 5,
  filter: { category: detectedDomain }
});
```

### By Tags

```typescript
// Direct tag matching
const results = await errorJournal.find({
  tags: { $in: topics }
}).limit(5);
```

### By Recency

```typescript
// Recent + relevant
const results = await history.find({
  $or: topics.map(t => ({ content: { $regex: t, $options: 'i' } }))
}).sort({ timestamp: -1 }).limit(5);
```

---

## When to Refresh

| Trigger | Action |
|---------|--------|
| New message | Load relevant context |
| Topic change | Clear stale, load new |
| Error detected | Load error patterns |
| Story activated | Load story context |
| Agent switch | Load agent persona |

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Token efficiency** | 80-90% reduction in context size |
| **Relevance** | Only useful information loaded |
| **Speed** | Faster responses |
| **Cost** | Lower API costs |

---

## Related Patterns

- [P-002: Three-Tier Memory](P-002-three-tier-memory.md)
- [P-006: Intent Detection](P-006-intent-detection.md)

