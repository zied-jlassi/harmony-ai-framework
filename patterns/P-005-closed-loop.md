# P-005: Closed-Loop Learning

> **Extract patterns from resolved errors to prevent recurrence.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-005 |
| **Category** | Learning |
| **Complexity** | Medium |
| **Applicability** | Self-improving systems |

---

## Problem

Without learning:
- Same errors repeat across sessions
- Knowledge lost when context resets
- No improvement over time
- Frustration from déjà vu

---

## Solution

Closed-loop learning cycle that extracts, stores, and applies patterns:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLOSED-LOOP LEARNING                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│                    ┌─────────────┐                              │
│                    │   EXECUTE   │                              │
│                    │  (Action)   │                              │
│                    └──────┬──────┘                              │
│                           │                                      │
│            ┌──────────────┼──────────────┐                      │
│            ▼              ▼              ▼                      │
│       ┌────────┐    ┌────────┐    ┌────────┐                   │
│       │SUCCESS │    │ FAILURE│    │ PARTIAL│                   │
│       └───┬────┘    └───┬────┘    └───┬────┘                   │
│           │             │             │                         │
│           └──────────────┴─────────────┘                        │
│                          │                                      │
│                          ▼                                      │
│    ┌─────────────────────────────────────────┐                 │
│    │              EVALUATE                    │                 │
│    │  • What worked?                          │                 │
│    │  • What failed?                          │                 │
│    │  • Why?                                  │                 │
│    └─────────────────┬───────────────────────┘                 │
│                      │                                          │
│                      ▼                                          │
│    ┌─────────────────────────────────────────┐                 │
│    │              REFLECT                     │                 │
│    │  • Extract pattern/anti-pattern          │                 │
│    │  • Document in error journal             │                 │
│    │  • Create prevention rule                │                 │
│    └─────────────────┬───────────────────────┘                 │
│                      │                                          │
│                      ▼                                          │
│    ┌─────────────────────────────────────────┐                 │
│    │               STORE                      │                 │
│    │  • Save to long-term memory              │                 │
│    │  • Update pattern library                │                 │
│    │  • Version control                       │                 │
│    └─────────────────┬───────────────────────┘                 │
│                      │                                          │
│                      ▼                                          │
│                 NEXT EXECUTION                                  │
│          (Now informed by learning)                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Learning Artifacts

### Error Record

```json
{
  "id": "ERR-001",
  "timestamp": "2025-01-15T10:30:00Z",
  "category": "typescript",
  "severity": "high",
  "title": "Import path not found",
  "symptom": "Cannot find module '@/shared/utils'",
  "root_cause": "tsconfig.json missing paths configuration",
  "solution": "Add paths: {'@/*': ['*']} to tsconfig.json",
  "prevention_rule": "Always check tsconfig.json when seeing @ import errors",
  "tags": ["typescript", "imports", "config"]
}
```

### Learned Pattern

```json
{
  "id": "P-LEARN-001",
  "type": "prevention",
  "category": "typescript",
  "trigger": "Cannot find module '@/'",
  "action": "Check tsconfig.json paths configuration",
  "confidence": 0.95,
  "source_errors": ["ERR-001", "ERR-015"],
  "applied_count": 12
}
```

### Anti-Pattern

```json
{
  "id": "AP-001",
  "pattern": "Using 'any' type for complex objects",
  "consequence": "Type safety lost, bugs slip through",
  "alternative": "Define proper interface or use 'unknown'",
  "source_errors": ["ERR-007", "ERR-022"]
}
```

---

## Implementation

```typescript
interface LearningService {
  // After error resolution
  extractPattern(error: Error, solution: Solution): Pattern;

  // Before new operation
  findRelevantPatterns(context: Context): Pattern[];

  // Apply patterns proactively
  applyPrevention(patterns: Pattern[], operation: Operation): void;
}

class LearningServiceImpl implements LearningService {
  extractPattern(error: Error, solution: Solution): Pattern {
    return {
      id: generateId(),
      type: 'prevention',
      category: error.category,
      trigger: error.symptom,
      action: solution.description,
      confidence: calculateConfidence(error, solution),
      sourceErrors: [error.id],
      appliedCount: 0
    };
  }

  findRelevantPatterns(context: Context): Pattern[] {
    const topics = extractTopics(context);
    return this.patterns.filter(p =>
      topics.some(t => p.trigger.includes(t) || p.category === t)
    );
  }

  applyPrevention(patterns: Pattern[], operation: Operation): void {
    for (const pattern of patterns) {
      if (matches(pattern.trigger, operation)) {
        warn(`💡 Remember: ${pattern.action}`);
        pattern.appliedCount++;
      }
    }
  }
}
```

---

## Learning Cycle

1. **Error occurs** → Record in error journal
2. **Error resolved** → Document solution
3. **Pattern extracted** → Create prevention rule
4. **Pattern stored** → Save to long-term memory
5. **Similar context** → Pattern retrieved via JIT
6. **Prevention applied** → Warning shown before error
7. **Error prevented** → Pattern confidence increases

---

## Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| **Recurrence rate** | Same error happening again | <10% |
| **Pattern application** | Patterns applied proactively | >80% |
| **Prevention success** | Errors prevented by patterns | >70% |
| **Pattern confidence** | Reliability of pattern | >90% |

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Self-improvement** | Gets smarter over time |
| **No repeat errors** | Learns from mistakes |
| **Knowledge persistence** | Survives sessions |
| **Proactive prevention** | Warns before errors |

---

## Related Patterns

- [P-004: Circuit Breaker](P-004-circuit-breaker.md)
- [P-002: Three-Tier Memory](P-002-three-tier-memory.md)

