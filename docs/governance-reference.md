# Governance Modules Reference

> **🌐 Language:** English · [Français](fr/governance-reference.md)

> 15 advanced governance concepts for enterprise-grade AI agents.
> Version 1.1.0 | Harmony Framework

---

## Overview

The governance architecture is organized into 4 layers:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     GOVERNANCE LAYER                                 │
│  ┌──────────────┐  ┌───────────────────┐                            │
│  │ Audit Trail  │  │ Compliance Reporter│                           │
│  │  (Traçabilité)│  │  (Conformité)      │                           │
│  └──────────────┘  └───────────────────┘                            │
├─────────────────────────────────────────────────────────────────────┤
│                     INTELLIGENCE LAYER                               │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐              │
│  │ Confidence    │  │ Agent Maturity │  │ A/B Testing │             │
│  │ Scorer        │  │ (L1-L4)       │  │ (Expériences)│             │
│  └───────────────┘  └───────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────────┤
│                     CONTEXT LAYER                                    │
│  ┌───────────────┐  ┌───────────────┐                               │
│  │ Context Filter│  │ Mesh Network  │                               │
│  │ (FILCO)       │  │ (Peer-to-Peer)│                               │
│  └───────────────┘  └───────────────┘                               │
├─────────────────────────────────────────────────────────────────────┤
│                     SAFETY LAYER                                     │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────┐          │
│  │ Data Sandbox  │  │ Security Gates│  │ Anomaly Detector│          │
│  │ (Isolation)   │  │ (Permissions) │  │ (Détection)     │          │
│  └───────────────┘  └───────────────┘  └─────────────────┘          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Governance Layer

### Audit Trail (`lib/audit-trail.sh`)

Complete audit trail with rollback support.

**Main functions:**

| Function | Description |
|----------|-------------|
| `audit_start_session` | Starts an audit session |
| `audit_record_decision` | Records a decision with metadata |
| `audit_record_file_change` | Captures file changes |
| `audit_create_checkpoint` | Creates a checkpoint |
| `audit_rollback_to` | Restores to a checkpoint |
| `audit_export` | Exports the history (JSON/CSV) |

**Usage:**

```bash
source .harmony/lib/audit-trail.sh

# Démarrer une session
session_id=$(audit_start_session "feature-login")

# Enregistrer une décision
entry_id=$(audit_record_decision "developer" "create" "auth.ts" "Implementing OAuth")

# Créer un checkpoint
checkpoint=$(audit_create_checkpoint "manual" "Before refactoring")

# Rollback si nécessaire
audit_rollback_to "$checkpoint" --force
```

**Configuration:** `.harmony/local/audit-config.json`

---

### Compliance Reporter (`lib/compliance-reporter.sh`)

Generation of compliance evidence for audits.

**Main functions:**

| Function | Description |
|----------|-------------|
| `compliance_add_check` | Adds a check result |
| `compliance_generate_report` | Generates a complete report |
| `compliance_get_status` | Gets the compliance score |
| `compliance_export_markdown` | Exports to Markdown |
| `compliance_run_standard_checks` | Runs the standard checks |

**Supported standards:**

- OWASP Top 10
- Code Coverage (configurable thresholds)
- Security Gates
- Documentation

**Usage:**

```bash
source .harmony/lib/compliance-reporter.sh

compliance_add_check "security" "OWASP-1" "passed" "Injection: No vulnerabilities"
compliance_add_check "quality" "Coverage" "passed" "Coverage: 87%"

compliance_generate_report "release-1.0"
```

---

## Intelligence Layer

### Confidence Scorer (`lib/confidence-scorer.sh`)

Uncertainty quantification with automatic escalation.

**Confidence levels:**

| Score | Level | Action |
|-------|--------|--------|
| 85-100 | CONFIDENT | Autonomous execution |
| 60-84 | UNCERTAIN | Optional validation request |
| 40-59 | LOW | Escalation recommended |
| 0-39 | VERY_LOW | Human-in-the-loop required |

**Main functions:**

| Function | Description |
|----------|-------------|
| `confidence_calculate` | Calculates the score (0-100) |
| `confidence_get_level` | Returns the textual level |
| `confidence_needs_review` | Determines whether review is needed |
| `confidence_escalate` | Escalates to a human |
| `confidence_calibrate` | Calibrates on feedback |

**Usage:**

```bash
source .harmony/lib/confidence-scorer.sh

score=$(confidence_calculate "$context" "$decision")
level=$(confidence_get_level "$score")

if confidence_needs_review "$score"; then
    confidence_escalate "$decision_id" "Complex authentication logic"
fi
```

**Configuration:** `.harmony/local/confidence-config.json`

---

### Agent Maturity (`lib/agent-maturity.sh`)

A 4-level maturity model for agents.

**Levels:**

| Level | Name | Capabilities |
|--------|-----|-----------|
| L1 | BASIC | Task execution, instructions |
| L2 | COORDINATED | Multi-agent collaboration, handoff |
| L3 | AUTONOMOUS | Self-correction, error recovery |
| L4 | SELF_OPTIMIZING | Meta-learning, continuous improvement |

**Main functions:**

| Function | Description |
|----------|-------------|
| `maturity_get_level` | Gets the current level |
| `maturity_record_capability` | Records a demonstrated capability |
| `maturity_can_perform` | Checks whether the agent can do X |
| `maturity_assess` | Assesses the overall level |
| `maturity_promote` | Promotes to the next level |

**Usage:**

```bash
source .harmony/lib/agent-maturity.sh

level=$(maturity_get_level "developer")
# → L2_COORDINATED

maturity_record_capability "developer" "self_correction"
maturity_assess "developer"
# → L3_AUTONOMOUS (si critères remplis)
```

---

### A/B Testing (`lib/ab-testing.sh`)

Structured experimentation for agent configurations.

**Main functions:**

| Function | Description |
|----------|-------------|
| `ab_create_experiment` | Creates an experiment |
| `ab_add_variant` | Adds a variant |
| `ab_select_variant` | Selects a variant (weighted random) |
| `ab_record_result` | Records a result |
| `ab_get_winner` | Determines the statistical winner |

**Usage:**

```bash
source .harmony/lib/ab-testing.sh

exp_id=$(ab_create_experiment "prompt-style" "Test formal vs casual" 50)

ab_add_variant "formal" '{"style":"formal","tone":"professional"}' "prompt-style"
ab_add_variant "casual" '{"style":"casual","tone":"friendly"}' "prompt-style"

variant=$(ab_select_variant "prompt-style")
# → "formal" ou "casual"

ab_record_result "$variant" 85 "prompt-style"
```

---

## Context Layer

### Context Filter - FILCO (`lib/context-filter.sh`)

Intelligent context filtering to reduce noise.

**Algorithm:**

1. **CHUNK**: Splits into semantic units (~500 chars)
2. **SCORE**: Combined score (keyword 60% + structural 40%)
3. **RANK**: Sort by descending score
4. **SELECT**: Selection within the token budget

**Main functions:**

| Function | Description |
|----------|-------------|
| `filco_filter` | Filters the context according to a query |
| `filco_score_chunk` | Scores a chunk (0-100) |
| `filco_compact` | Compacts within a token budget |
| `filco_rank_chunks` | Returns the sorted chunks |

**Usage:**

```bash
source .harmony/lib/context-filter.sh

# Filtrer le contexte pour une tâche
filtered=$(filco_filter "$large_context" "implement user authentication")

# Compacter dans un budget
compacted=$(filco_compact "$context" 5000)  # max 5000 tokens
```

**Impact:**

| Metric | Before FILCO | After FILCO |
|----------|-------------|-------------|
| Context size | 15,000 tokens | 5,000 tokens |
| Response accuracy | 75% | 85% |
| Token cost | $0.15/req | $0.05/req |

**Related pattern:** [P-024-context-filtering](../patterns/P-024-context-filtering.md)

---

### Mesh Network (`lib/mesh-network.sh`)

Mesh networks for peer-to-peer collaboration between agents.

**Mesh types:**

| Type | Coordinator | Agents | Usage |
|------|-------------|--------|-------|
| Feature | architect | developer, tester, reviewer | Feature development |
| Quality | qa-lead | tester, security, perf | Quality validation |
| Incident | commander | developer, devops, analyst | Incident resolution |

**Main functions:**

| Function | Description |
|----------|-------------|
| `mesh_create` | Creates a network |
| `mesh_join` | Joins a network |
| `mesh_send` | Sends a P2P message |
| `mesh_handoff` | Transfers responsibility |
| `mesh_escalate` | Escalates to the coordinator |
| `mesh_status` | Displays the status |

**Usage:**

```bash
source .harmony/lib/mesh-network.sh

mesh_id=$(mesh_create "login-feature" "architect" "developer" "tester")

# Communication P2P
mesh_send "tester" "Code ready for testing"

# Handoff
mesh_handoff "developer" "tester" "All unit tests pass"

# Escalation
mesh_escalate "Blocked: Need architecture decision"
```

**Related pattern:** [P-023-mesh-networks](../patterns/P-023-mesh-networks.md)

---

## Safety Layer

### Data Sandbox (`lib/data-sandbox.sh`)

Isolation of untrusted data.

**Detected threat types:**

| Type | Patterns | Examples |
|------|----------|----------|
| Prompt Injection | `ignore previous`, `disregard`, `new instructions` | LLM attacks |
| Code Injection | `$()`, backticks, `eval` | Shell injection |
| Path Traversal | `../`, `..\\` | File access |
| SQL Injection | `'; DROP`, `UNION SELECT` | DB attacks |
| XSS | `<script>`, `onerror=` | Web attacks |

**Main functions:**

| Function | Description |
|----------|-------------|
| `sandbox_validate` | Validates an input |
| `sandbox_is_suspicious` | Detects whether suspicious |
| `sandbox_detect_injection` | Identifies the injection type |
| `sandbox_quarantine` | Quarantines |
| `sandbox_sanitize` | Sanitizes the input |

**Usage:**

```bash
source .harmony/lib/data-sandbox.sh

if sandbox_is_suspicious "$user_input"; then
    injection_type=$(sandbox_detect_injection "$user_input")
    sandbox_quarantine "$user_input" "Detected: $injection_type"
else
    clean_input=$(sandbox_sanitize "$user_input")
fi
```

**Configuration:** `.harmony/local/sandbox-config.json`

---

### Security Gates (`lib/security-gates.sh`)

Security gates for access control.

**Security levels:**

| Level | Operations | Authorization |
|--------|------------|--------------|
| 1 | file_read | Auto |
| 2 | file_write, api_call | Review |
| 3 | deploy, config_change | Approval |
| 4 | production, database | Explicit |

**Blocked paths:**

- `/etc/*`, `/usr/*`, `/bin/*` (system)
- `~/.ssh/*`, `~/.gnupg/*` (secrets)
- `node_modules/` (dependencies)

**Main functions:**

| Function | Description |
|----------|-------------|
| `security_check_gate` | Checks the authorization |
| `security_record_event` | Records an event |
| `security_request_approval` | Requests approval |

**Usage:**

```bash
source .harmony/lib/security-gates.sh

if security_check_gate "file_write" "/path/to/file" "developer"; then
    echo "Écriture autorisée"
else
    echo "Accès refusé - niveau insuffisant"
fi
```

---

### Anomaly Detector (`lib/anomaly-detector.sh`)

Behavioral anomaly detection.

**Detected anomalies:**

| Type | Indicators | Severity |
|------|-------------|----------|
| Loop | Repeated lines (>3x) | 2-3 |
| Hallucination | Nonexistent files/classes | 2-3 |
| Performance | Time > 2x baseline | 1-2 |
| Unusual | Output > 2x normal | 1-2 |

**Main functions:**

| Function | Description |
|----------|-------------|
| `anomaly_check` | Checks an agent's output |
| `anomaly_record_baseline` | Establishes a baseline |

**Usage:**

```bash
source .harmony/lib/anomaly-detector.sh

severity=$(anomaly_check "developer" "$agent_output")

if [[ $severity -gt 2 ]]; then
    echo "Anomalie sévère détectée!"
    # Activer circuit breaker
fi
```

---

## Cognitive Patterns

### Emotional Prompting (`patterns/cognitive/emotional-prompting.md`)

Psychological techniques to improve engagement:

- **Positive Framing**: "The team is counting on you"
- **Stakes Communication**: "This is critical for the release"
- **Empathy Injection**: Acknowledging the difficulty

### Meta-Prompting (`patterns/cognitive/meta-prompting.md`)

Dynamic prompt generation based on context:

- Adapted template selection
- JIT knowledge injection
- Adaptation to the complexity level

**Related pattern:** [P-021-meta-prompting](../patterns/P-021-meta-prompting.md)

### Self-Evolving (`patterns/cognitive/self-evolving.md`)

Continuous improvement loop:

```
Execute → Evaluate → LLM-as-Judge → Feedback → Meta-prompt → Execute
```

---

## Configuration

### Configuration files

| File | Description |
|---------|-------------|
| `.harmony/local/audit-config.json` | Retention, sensitive fields |
| `.harmony/local/confidence-config.json` | Thresholds, scoring weights |
| `.harmony/local/sandbox-config.json` | Blocked patterns, schemas |

### Environment variables

| Variable | Default | Description |
|----------|--------|-------------|
| `HARMONY_DIR` | `.harmony` | Framework directory |
| `FILCO_CHUNK_SIZE` | 500 | Chunk size |
| `PRELOADER_MAX_TOKENS` | 15000 | Max token budget |

---

## Tests

### Quick validation

```bash
./tests/e2e/scripts/test.sh /path/to/project governance
```

### Full scenario

```bash
./tests/e2e/scripts/test.sh /path/to/project scenario governance
```

### Module self-tests

Each module includes a `_self_test()` function:

```bash
source .harmony/lib/audit-trail.sh
audit_trail_self_test  # ou appel direct avec --test
```

---

## References

| Pattern | Description |
|---------|-------------|
| [P-021-meta-prompting](../patterns/P-021-meta-prompting.md) | Dynamic prompt generation |
| [P-022-agent-maturity](../patterns/P-022-agent-maturity.md) | Maturity model L1-L4 |
| [P-023-mesh-networks](../patterns/P-023-mesh-networks.md) | P2P collaboration |
| [P-024-context-filtering](../patterns/P-024-context-filtering.md) | FILCO algorithm |

---

## Changelog

- **v1.1.0**: Initial implementation of the 15 concepts
  - 10 bash modules (lib/)
  - 3 cognitive patterns
  - 4 system patterns (P-021 to P-024)
  - Complete E2E tests
