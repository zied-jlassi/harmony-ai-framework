# P-004: Circuit Breaker Protection

> **Prevent cascade failures by halting operations after repeated errors.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-004 |
| **Category** | Resilience |
| **Complexity** | Low |
| **Applicability** | Error-prone operations |

---

## Problem

When errors occur repeatedly:
- Same mistake gets repeated
- Context wasted on failed attempts
- No forcing function for diagnosis
- Frustration increases

---

## Solution

Circuit breaker that opens after N consecutive failures:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER STATES                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐                                            │
│  │     CLOSED      │  ← Normal operation                        │
│  │   (0 failures)  │                                            │
│  └────────┬────────┘                                            │
│           │                                                      │
│       [Failure]                                                  │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │     CLOSED      │  ← Warning                                 │
│  │  (1/3 failures) │                                            │
│  └────────┬────────┘                                            │
│           │                                                      │
│       [Failure]                                                  │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │     CLOSED      │  ← Critical                                │
│  │  (2/3 failures) │                                            │
│  └────────┬────────┘                                            │
│           │                                                      │
│       [Failure]                                                  │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │      OPEN       │  ← Blocked!                                │
│  │  Diagnosis req. │                                            │
│  └────────┬────────┘                                            │
│           │                                                      │
│     [Manual Reset]                                               │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │   HALF-OPEN     │  ← Testing                                 │
│  │  (1 attempt)    │                                            │
│  └────────┬────────┘                                            │
│           │                                                      │
│   [Success]───────[Failure]                                      │
│       │                │                                         │
│       ▼                ▼                                         │
│    CLOSED            OPEN                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## States

| State | Meaning | Operations Allowed |
|-------|---------|-------------------|
| **CLOSED** | Normal | All |
| **OPEN** | Blocked | None (diagnosis required) |
| **HALF-OPEN** | Testing | One (to test recovery) |

---

## Implementation

```typescript
interface CircuitBreaker {
  state: 'CLOSED' | 'OPEN' | 'HALF_OPEN';
  consecutiveFailures: number;
  maxFailures: number;
  lastFailure: Date | null;
  lastSuccess: Date | null;
}

class CircuitBreakerService {
  private breaker: CircuitBreaker;

  constructor(maxFailures: number = 3) {
    this.breaker = {
      state: 'CLOSED',
      consecutiveFailures: 0,
      maxFailures,
      lastFailure: null,
      lastSuccess: null
    };
  }

  canOperate(): boolean {
    return this.breaker.state !== 'OPEN';
  }

  recordSuccess(): void {
    this.breaker.consecutiveFailures = 0;
    this.breaker.state = 'CLOSED';
    this.breaker.lastSuccess = new Date();
  }

  recordFailure(): void {
    this.breaker.consecutiveFailures++;
    this.breaker.lastFailure = new Date();

    if (this.breaker.consecutiveFailures >= this.breaker.maxFailures) {
      this.breaker.state = 'OPEN';
      this.notifyCircuitOpen();
    }
  }

  reset(): void {
    this.breaker.state = 'HALF_OPEN';
  }

  private notifyCircuitOpen(): void {
    console.error(`
      🛑 CIRCUIT BREAKER OPEN
      ${this.breaker.maxFailures} consecutive failures detected.
      Diagnosis required before continuing.
    `);
  }
}
```

---

## Usage

```typescript
const circuit = new CircuitBreakerService(3);

async function executeOperation(op: Operation): Promise<Result> {
  // Check circuit state
  if (!circuit.canOperate()) {
    throw new Error('Circuit open - diagnosis required');
  }

  try {
    const result = await op.execute();
    circuit.recordSuccess();
    return result;
  } catch (error) {
    circuit.recordFailure();
    throw error;
  }
}
```

---

## Configuration

```json
{
  "circuit_breaker": {
    "enabled": true,
    "max_failures": 3,
    "cooldown_minutes": 5,
    "auto_reset": false
  }
}
```

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Prevents loops** | Forces stop after failures |
| **Forces diagnosis** | Can't continue without fixing |
| **Saves context** | No wasted attempts |
| **Learning trigger** | Errors lead to patterns |

---

## Related Patterns

- [P-005: Closed-Loop Learning](P-005-closed-loop.md)
- [P-002: Three-Tier Memory](P-002-three-tier-memory.md)

