# Harmony Sentinel - Auto-Learning Error Memory

> **"The framework that learns from your mistakes."**
>
> Sentinel is Harmony's unique error memory and circuit breaker system.
> No other AI framework offers this capability.

---

## What Makes Sentinel Unique

| Feature | Traditional AI | Harmony Sentinel |
|---------|----------------|------------------|
| Error handling | Forget after session | Remember forever |
| Repeated bugs | Same fix, different day | One fix, never again |
| Failure protection | None | Circuit breaker (3 strikes) |
| Pattern learning | Manual | Automatic |

---

## Memory Files

```
${MEMORY_DIR}/              # IDE-specific (e.g., .claude/memory/)
├── error-journal.json      # All errors with solutions
├── circuit-breaker.json    # Circuit state (CLOSED/OPEN)
├── learned-patterns.json   # Validated patterns
└── anti-patterns.json      # Things to avoid
```

> Path configured in `.harmony/config/paths.json` during installation.

---

## Modes

### 1. Dashboard (`harmony sentinel`)

Shows system health:

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    🛡️ HARMONY SENTINEL - Dashboard                            ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Circuit Breaker: 🟢 CLOSED                                                  ║
║   Consecutive failures: 0/3                                                   ║
║                                                                               ║
║   Error Journal:                                                              ║
║   ├── Total documented: 45                                                    ║
║   ├── This week: 3                                                            ║
║   └── Recurring: 0                                                            ║
║                                                                               ║
║   Learned Patterns:                                                           ║
║   ├── Prevention rules: 12                                                    ║
║   ├── Anti-patterns: 5                                                        ║
║   └── Applied: 34 times                                                       ║
║                                                                               ║
║   Last activity: 2 hours ago                                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

**Actions:**
1. Read `memory/circuit-breaker.json`
2. Read `memory/error-journal.json`
3. Display formatted dashboard

---

### 2. Learn (`harmony sentinel --learn`)

Document a new error in the journal:

**Step 1: Collect information**
```markdown
1. What error occurred?
2. What module was affected?
3. What was the root cause?
4. What solution was applied?
5. What prevention rule?
```

**Step 2: Create JSON entry**
```json
{
  "id": "ERR-XXX",
  "date": "YYYY-MM-DD",
  "category": "[typescript|build|test|api|database|security|accessibility|performance|architecture]",
  "severity": "[low|medium|high|critical]",
  "title": "[short title]",
  "context": {
    "module": "[module]",
    "file": "[file]"
  },
  "symptom": "[observable description]",
  "root_cause": "[root cause]",
  "correct_solution": "[applied solution]",
  "prevention_rule": "[rule to avoid]",
  "tags": ["tag1", "tag2"]
}
```

**Step 3: Update quick_lookup**

Index for fast retrieval by module, category, and tags.

---

### 3. Reset (`harmony sentinel --reset`)

Reset circuit breaker after analysis:

**Prerequisites:**
1. Root cause analysis MUST be completed
2. Error SHOULD be documented in journal
3. Prevention rule SHOULD be defined

**Process:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER RESET                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Verify root cause analysis done                        │
│          └─ Ask: "What was learned from this failure?"          │
│                                                                  │
│  Step 2: Propose error-journal entry if not done                │
│          └─ Run: harmony sentinel --learn                       │
│                                                                  │
│  Step 3: Reset circuit breaker                                  │
│          └─ Set state: CLOSED, failure_count: 0                 │
│                                                                  │
│  Step 4: Log reset in history                                   │
│          └─ Record: timestamp, reason, related error            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Result:**
```json
{
  "state": "CLOSED",
  "failure_count": 0,
  "last_reset": "[timestamp]",
  "reset_reason": "[provided reason]"
}
```

---

### 4. Check (`harmony sentinel --check`)

Complete system verification:

| Check | Description |
|-------|-------------|
| Files exist | All memory files present |
| JSON valid | Valid JSON structure |
| 24h errors | Count errors last 24h |
| Risk modules | Modules with > 2 errors |
| Recommendations | Suggested actions |

**Output:**
```
Sentinel System Check
─────────────────────
✅ error-journal.json     Valid (45 entries)
✅ circuit-breaker.json   Valid (CLOSED)
✅ learned-patterns.json  Valid (12 patterns)
✅ anti-patterns.json     Valid (5 patterns)

⚠️ High-risk modules:
   └─ authentication (3 errors this week)

Recommendations:
   1. Review authentication module patterns
   2. Add integration tests for auth flow
```

---

### 5. Report (`harmony sentinel --report`)

Detailed analytics report:

```markdown
# Sentinel Report - [DATE]

## Global Statistics

| Category | Count | Trend |
|----------|-------|-------|
| Total errors | 45 | +3 this week |
| Resolved | 42 | 93% |
| Recurring | 0 | ✅ |

## By Category

| Category | Errors | Top Issue |
|----------|--------|-----------|
| TypeScript | 15 | Type inference |
| API | 12 | Validation |
| Database | 8 | Connection pool |

## Top 5 Most Frequent

1. **Type mismatch** (8x) - Solved: Use strict mode
2. **Connection timeout** (5x) - Solved: Increase pool
3. ...

## Problematic Modules

| Module | Errors | Recommendation |
|--------|--------|----------------|
| auth | 12 | Add E2E tests |
| api/users | 8 | Refactor validation |

## Recently Learned Patterns

1. PATTERN-012: Use DTOs for all inputs
2. PATTERN-011: Validate before transform

## Recommendations

1. Focus on authentication module
2. Add validation layer to user API
3. Consider TypeScript strict mode
```

---

## Circuit Breaker Protocol

```
┌─────────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER STATES                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🟢 CLOSED (Normal)                                              │
│  ├── Operations allowed                                          │
│  ├── Failure counter: 0/3                                        │
│  └── On failure: increment counter                               │
│                                                                  │
│  🟡 HALF-OPEN (Testing)                                          │
│  ├── Limited operations                                          │
│  ├── On success: → CLOSED                                        │
│  └── On failure: → OPEN                                          │
│                                                                  │
│  🔴 OPEN (Protection)                                            │
│  ├── Operations BLOCKED                                          │
│  ├── Mandatory diagnosis                                         │
│  └── Reset: harmony sentinel --reset                             │
│                                                                  │
│  Transition: CLOSED → [3 failures] → OPEN                        │
│              OPEN → [manual reset] → CLOSED                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Automatic Hooks

Sentinel integrates with Claude Code hooks:

### Pre-Tool-Use (Before Write/Edit/Bash)

```bash
# .harmony/hooks/harmony-sentinel.sh
# Checks error-journal for related errors
# Warns if similar error was seen before
```

### Post-Tool-Use (After Write/Edit/Bash)

```bash
# .harmony/hooks/harmony-post-tool.sh
# Detects failures
# Increments failure_count
# Opens circuit if 3 failures
```

---

## Configuration

```json
{
  "sentinel": {
    "enabled": true,
    "max_retries": 3,
    "cooldown_minutes": 5,
    "auto_reset": false,
    "tracked_operations": [
      "file_write",
      "code_implementation",
      "test_execution",
      "build",
      "deploy"
    ]
  }
}
```

---

## Error Journal Schema

```json
{
  "version": "1.0.0",
  "stats": {
    "total_errors": 0,
    "resolved": 0,
    "patterns_learned": 0
  },
  "errors": [
    {
      "id": "ERR-001",
      "date": "2025-01-15",
      "category": "typescript",
      "severity": "medium",
      "title": "Type mismatch in user service",
      "context": {
        "module": "users",
        "file": "src/users/users.service.ts"
      },
      "symptom": "TS2322: Type 'string' is not assignable",
      "root_cause": "Missing DTO transformation",
      "correct_solution": "Add class-transformer",
      "prevention_rule": "Always use DTOs with @Transform",
      "tags": ["dto", "validation"]
    }
  ],
  "quick_lookup": {
    "by_module": {
      "users": ["ERR-001"]
    },
    "by_category": {
      "typescript": ["ERR-001"]
    }
  }
}
```

---

## Why This Matters

> **"The definition of insanity is doing the same thing over and over and expecting different results."**
> — Albert Einstein

Traditional AI assistants:
- Forget errors after each session
- Repeat the same mistakes
- No learning curve

Harmony Sentinel:
- Remembers every error forever
- Applies learned patterns automatically
- Continuously improves

**This is what makes Harmony unique.**
