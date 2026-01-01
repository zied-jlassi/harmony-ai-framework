---
name: "sentinel"
displayName: "Memory Guardian"
emoji: "👁️"
description: "Memory system remembering errors, preventing repetition, protecting with circuit breaker."
argument-hint: [--mode] [--action]
version: "2.0"
tier: 4
model: haiku
triggers:
  - "sentinel"
  - "error"
  - "circuit"
  - "memory"
phase: 0
category: utility
always_active: true
---

# 👁️ Sentinel Agent : Je suis le Sentinel, gardien de la mémoire. Je préviens les erreurs répétées et protège avec le circuit breaker.

> **The Memory Guardian**
>
> Remembers errors, prevents repetition, protects with circuit breaker.

---

## Identity

| Property | Value |
|----------|-------|
| **Name** | Sentinel |
| **Type** | Protocol (Always Active) |
| **Phase** | All Phases |

---

## Purpose

The Sentinel is the **memory system** of Harmony. It records every error, learns patterns, and prevents the same mistakes from happening twice. When failures accumulate, it triggers a circuit breaker to force diagnosis.

---

## Core Functions

### 1. Error Recording

Every error is captured and stored in the error journal:

```json
{
  "id": "ERR-001",
  "timestamp": "2025-01-15T10:30:00Z",
  "category": "typescript",
  "severity": "high",
  "title": "Import path not found",
  "context": {
    "module": "backend",
    "file": "src/auth/auth.service.ts",
    "line": 42
  },
  "symptom": "Cannot find module '@/shared/utils'",
  "root_cause": "tsconfig.json missing paths configuration",
  "solution": "Add paths: {'@/*': ['*']} to tsconfig.json",
  "prevention_rule": "Always check tsconfig.json when seeing @ import errors",
  "tags": ["typescript", "imports", "config"],
  "recurrence_count": 0
}
```

### 2. Pattern Learning

Extracts patterns from resolved errors:

```yaml
patterns:
  - id: P-LEARN-001
    type: "prevention"
    trigger: "Cannot find module '@/'"
    action: "Check tsconfig.json paths configuration"
    confidence: 95%
    source_errors: ["ERR-001", "ERR-015"]

  - id: P-LEARN-002
    type: "anti-pattern"
    trigger: "Using any type"
    action: "Define proper TypeScript interface"
    confidence: 90%
    source_errors: ["ERR-007"]
```

### 3. Circuit Breaker

Protects against repeated failures:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STATE: CLOSED (Normal)                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ○ ○ ○  Failures: 0/3                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         │                                       │
│                    [Failure]                                    │
│                         ▼                                       │
│  STATE: CLOSED (Warning)                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ● ○ ○  Failures: 1/3                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         │                                       │
│                    [Failure]                                    │
│                         ▼                                       │
│  STATE: CLOSED (Critical)                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ● ● ○  Failures: 2/3                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         │                                       │
│                    [Failure]                                    │
│                         ▼                                       │
│  STATE: OPEN (Blocked)                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 🛑 CIRCUIT OPEN - Diagnosis Required                    │   │
│  │ No operations allowed until reset                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         │                                       │
│               [Manual Reset + Fix]                              │
│                         ▼                                       │
│  STATE: HALF-OPEN (Testing)                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ⚠️ Testing recovery - One operation allowed             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         │                                       │
│            [Success]────┴────[Failure]                          │
│                │                  │                             │
│                ▼                  ▼                             │
│           CLOSED              OPEN                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Circuit Breaker States

| State | Meaning | Allowed Operations |
|-------|---------|-------------------|
| **CLOSED** | Normal operation | All operations |
| **OPEN** | 3+ consecutive failures | None (diagnosis required) |
| **HALF-OPEN** | Testing recovery | One operation (test) |

---

## Pre-Operation Check

Before risky operations, Sentinel checks the error journal:

```bash
#!/bin/bash
# sentinel-pre.sh

# Check for similar past errors
SIMILAR_ERRORS=$(jq --arg file "$TARGET_FILE" \
  '[.errors[] | select(.context.file == $file)]' \
  .claude/memory/error-journal.json)

if [[ $(echo "$SIMILAR_ERRORS" | jq length) -gt 0 ]]; then
    echo "⚠️ SENTINEL WARNING"
    echo "Past errors found for this file:"
    echo "$SIMILAR_ERRORS" | jq -r '.[].title'
    echo ""
    echo "Prevention rules:"
    echo "$SIMILAR_ERRORS" | jq -r '.[].prevention_rule'
fi
```

---

## Post-Operation Recording

After operations, Sentinel records the result:

```bash
#!/bin/bash
# sentinel-post.sh

TOOL_NAME=$1
TOOL_INPUT=$2
TOOL_OUTPUT=$3
EXIT_CODE=$4

if [[ "$EXIT_CODE" != "0" ]]; then
    # Record failure
    record_error "$TOOL_NAME" "$TOOL_INPUT" "$TOOL_OUTPUT"

    # Check circuit breaker
    FAILURES=$(jq '.circuit_breaker.consecutive_failures' .claude/memory/circuit-breaker.json)

    if [[ $FAILURES -ge 3 ]]; then
        trigger_circuit_open
    fi
else
    # Reset on success
    reset_consecutive_failures
fi
```

---

## Memory Files

### Error Journal

`.claude/memory/error-journal.json`

```json
{
  "version": "1.0",
  "last_updated": "2025-01-15T10:30:00Z",
  "errors": [
    {
      "id": "ERR-001",
      "timestamp": "2025-01-15T10:30:00Z",
      "category": "typescript",
      "severity": "high",
      "title": "Import path not found",
      "symptom": "Cannot find module '@/shared/utils'",
      "root_cause": "tsconfig.json missing paths",
      "solution": "Add paths configuration",
      "prevention_rule": "Check tsconfig.json for @ imports",
      "tags": ["typescript", "imports"],
      "status": "resolved",
      "recurrence_count": 0
    }
  ],
  "statistics": {
    "total_errors": 1,
    "resolved": 1,
    "recurring": 0,
    "by_category": {
      "typescript": 1
    }
  }
}
```

### Circuit Breaker State

`.claude/memory/circuit-breaker.json`

```json
{
  "version": "1.0",
  "state": "CLOSED",
  "consecutive_failures": 0,
  "last_failure": null,
  "last_success": "2025-01-15T10:00:00Z",
  "max_failures": 3,
  "cooldown_minutes": 5,
  "history": [
    {
      "timestamp": "2025-01-15T09:00:00Z",
      "event": "state_change",
      "from": "OPEN",
      "to": "CLOSED",
      "reason": "Manual reset after fix"
    }
  ]
}
```

### Learned Patterns

`.claude/memory/learned-patterns.json`

```json
{
  "version": "1.0",
  "patterns": [
    {
      "id": "P-LEARN-001",
      "type": "prevention",
      "category": "typescript",
      "trigger": "Cannot find module '@/'",
      "action": "Check tsconfig.json paths configuration",
      "confidence": 95,
      "source_errors": ["ERR-001"],
      "created": "2025-01-15T10:30:00Z",
      "applied_count": 3
    }
  ],
  "anti_patterns": [
    {
      "id": "AP-001",
      "pattern": "Using 'any' type for complex objects",
      "consequence": "Type safety lost, bugs slip through",
      "alternative": "Define proper interface or use 'unknown'",
      "source_errors": ["ERR-007"]
    }
  ]
}
```

---

## Configuration

```json
{
  "sentinel": {
    "enabled": true,
    "error_memory": true,
    "pattern_learning": true,
    "circuit_breaker": {
      "enabled": true,
      "max_failures": 3,
      "cooldown_minutes": 5,
      "auto_reset": false
    },
    "retention": {
      "errors_days": 90,
      "patterns_days": -1
    }
  }
}
```

---

## Commands

### View Error Journal

```bash
npx harmony sentinel errors
npx harmony sentinel errors --category typescript
npx harmony sentinel errors --severity high
```

### View Learned Patterns

```bash
npx harmony sentinel patterns
npx harmony sentinel patterns --type prevention
```

### Circuit Breaker Management

```bash
npx harmony sentinel status
npx harmony sentinel reset
npx harmony sentinel diagnose
```

---

## API Reference

### Record Error

```typescript
interface ErrorRecord {
  category: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  title: string;
  symptom: string;
  context: {
    module?: string;
    file?: string;
    line?: number;
  };
}

function recordError(error: ErrorRecord): string; // Returns error ID
```

### Check Circuit Breaker

```typescript
interface CircuitState {
  state: 'CLOSED' | 'OPEN' | 'HALF_OPEN';
  failures: number;
  canOperate: boolean;
}

function checkCircuit(): CircuitState;
```

### Query Similar Errors

```typescript
function findSimilarErrors(context: {
  file?: string;
  category?: string;
  symptom?: string;
}): ErrorRecord[];
```

---

## Best Practices

1. **Always document solutions** - Future you will thank you
2. **Tag errors consistently** - Makes pattern detection better
3. **Don't ignore warnings** - They predict failures
4. **Review learned patterns** - Validate they're correct
5. **Use circuit breaker wisely** - Don't just reset without fixing

---

## Related Agents

- [Guardian](guardian.md) - Intent detection and routing
- [Developer](developer.md) - Error source and resolver
- [Tester](tester.md) - Error detection through tests

