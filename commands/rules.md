# Harmony Rules - Validation

> Validate framework and project rules (.harmony/rules/).

---

## What It Checks

| Check | Description |
|-------|-------------|
| Framework rules | `.harmony/rules/R-*.yaml` valid |
| Project rules | `.harmony/local/rules/*.yaml` valid |
| Rule syntax | YAML structure correct |
| References | Referenced files exist |
| No conflicts | No contradictory rules |

---

## Rule Sources

| Source | Path | Priority |
|--------|------|----------|
| Framework | `.harmony/rules/` | Base |
| Local/Project | `.harmony/local/rules/` | Override |

---

## Framework Rules (Built-in)

| Rule | File | Description |
|------|------|-------------|
| R-001 | story-required.yaml | Story must exist before dev |
| R-002 | ucv-approval.yaml | UCV approval gate |
| R-003 | circuit-breaker.yaml | Error protection |
| R-004 | test-coverage.yaml | Minimum test coverage |
| R-005 | memory-management.yaml | Memory file handling |
| R-006 | agent-separation.yaml | Role isolation |
| R-007 | phase-gates.yaml | Phase prerequisites |

---

## Output

```
HARMONY RULES AUDIT
───────────────────

Scanning rules...

Framework Rules (.harmony/rules/):
  ✅ R-001-story-required.yaml      Valid
  ✅ R-002-ucv-approval.yaml        Valid
  ✅ R-003-circuit-breaker.yaml     Valid
  ✅ R-004-test-coverage.yaml       Valid
  ✅ R-005-memory-management.yaml   Valid
  ✅ R-006-agent-separation.yaml    Valid
  ✅ R-007-phase-gates.yaml         Valid

Project Rules (.harmony/local/rules/):
  ✅ No local rules defined

Summary:
├── Framework rules:  7
├── Project rules:    0
├── Conflicts:        0
└── Syntax errors:    0

Rules health: 100%
```

---

## Usage Mode: --usage

Check how rules are enforced in the current context:

```
HARMONY RULES USAGE
───────────────────

Checking rule enforcement...

Current Phase: 4 (Implementation)

| Rule | Mode | Status | Last Check |
|------|------|--------|------------|
| R-001 Story Required | BLOCK | Active | 2025-12-30 |
| R-002 UCV Approval | BLOCK | Active | 2025-12-30 |
| R-003 Circuit Breaker | WARN | Active | 2025-12-30 |
| R-004 Test Coverage | WARN | Inactive (Phase 4) | - |
| R-005 Memory Mgmt | WARN | Active | 2025-12-30 |
| R-006 Agent Separation | BLOCK | Active | 2025-12-30 |
| R-007 Phase Gates | BLOCK | Active | 2025-12-30 |

Active rules: 6/7
Enforcement mode: WARN (from overrides.yaml)
```

---

## Usage Mode: --report

Generate detailed compliance report by category:

```
HARMONY RULES REPORT
────────────────────

=== COMPLIANCE REPORT ===

Category: Workflow Rules
├── R-001 Story Required           ✅ Enforced
│   └── Violations: 0
├── R-006 Agent Separation         ✅ Enforced
│   └── Violations: 0
└── R-007 Phase Gates              ✅ Enforced
    └── Violations: 0

Category: Quality Rules
├── R-002 UCV Approval             ✅ Enforced
│   └── Violations: 0
└── R-004 Test Coverage            ✅ Enforced
    └── Violations: 0

Category: Protection Rules
├── R-003 Circuit Breaker          ✅ Enforced
│   └── Triggers: 0
└── R-005 Memory Management        ✅ Enforced
    └── Violations: 0

Overall Compliance: 100%
```

---

## Rule Schema

Each rule file follows this structure:

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

## Usage

```bash
/harmony rules                  # 13 - Audit regles
/harmony rules --usage          # 14 - Usage dans le code
/harmony rules --report         # 15 - Rapport conformite
```

---

## See Also

- [Guardian Agent](../agents/guardian.md) - Rule enforcement
- [Overrides](../docs/overrides.md) - Project customization
- [Full Audit](full.md) - Complete validation
