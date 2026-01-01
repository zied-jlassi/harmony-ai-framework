# Harmony Rules

> **Enforcement rules that define the framework's behavior.**

---

## Overview

Rules are YAML-based configurations that define:
- What is enforced (story requirement, UCV approval, etc.)
- When enforcement happens (phases, contexts)
- How violations are handled (warn, block)

---

## Rule Categories

| Category | Description | Files |
|----------|-------------|-------|
| **Workflow** | Development workflow rules | R-001, R-002 |
| **Quality** | Code and verification quality | R-003, R-004 |
| **Memory** | Memory management rules | R-005 |
| **Agents** | Agent behavior rules | R-006 |
| **Phase** | Phase-specific rules | R-007 |

---

## Rule Files

```
rules/
├── README.md           # This file
├── R-001-story-required.yaml
├── R-002-ucv-approval.yaml
├── R-003-circuit-breaker.yaml
├── R-004-test-coverage.yaml
├── R-005-memory-management.yaml
├── R-006-agent-separation.yaml
└── R-007-phase-gates.yaml
```

---

## Rule Structure

```yaml
rule:
  id: R-XXX
  name: "Rule Name"
  category: workflow|quality|memory|agents|phase
  severity: info|warning|error|critical

enforcement:
  mode: warn|block
  phases: [1, 2, 3, 4, 5]
  contexts: ["development", "testing"]

conditions:
  - type: prerequisite|state|pattern
    check: "condition expression"

actions:
  on_violation:
    message: "User-facing message"
    suggestion: "How to fix"
  on_success:
    message: "Confirmation message"
```

---

## Loading Rules

Rules are loaded by the Guardian at startup:

```typescript
function loadRules(): Rule[] {
  const rulesDir = '.harmony/rules';
  const files = glob.sync(`${rulesDir}/R-*.yaml`);

  return files.map(file => {
    const content = readFileSync(file, 'utf8');
    return yaml.parse(content);
  });
}
```

---

## Enforcement Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    RULE ENFORCEMENT FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  OPERATION REQUESTED                                             │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │   Load Rules    │                                            │
│  └────────┬────────┘                                            │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │ Filter by Phase │ ─── Only rules for current phase          │
│  └────────┬────────┘                                            │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐                                            │
│  │ Check Conditions│ ─── Evaluate each rule                    │
│  └────────┬────────┘                                            │
│           │                                                      │
│     ┌─────┴─────┐                                               │
│     ▼           ▼                                               │
│  PASS        VIOLATION                                          │
│     │           │                                               │
│     │     ┌─────┴─────┐                                         │
│     │     ▼           ▼                                         │
│     │   WARN        BLOCK                                       │
│     │     │           │                                         │
│     └─────┴─────┬─────┘                                         │
│                 ▼                                               │
│           CONTINUE/HALT                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Related

- [Guardian Agent](../agents/guardian.md)
- [P-007: Story-Based Development](../patterns/P-007-story-based.md)

