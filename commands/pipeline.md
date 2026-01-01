# Harmony Pipeline - Coherence Validation

> Validate pipeline configuration vs documentation.

---

## What It Checks

| Source | Validation |
|--------|------------|
| `config/pipeline-orchestration.yaml` | Agents declared exist |
| `config/routing-rules.yaml` | Steps coherent |
| `config/model-tiers.yaml` | Tiers match agent frontmatter |
| `docs/architecture/` | Documentation reflects config |

---

## Output

```
HARMONY PIPELINE VALIDATION
───────────────────────────

Checking pipeline coherence...

✅ pipeline-orchestration.yaml   18 agents defined
✅ routing-rules.yaml            45 routing patterns
✅ model-tiers.yaml              4 tiers configured

Cross-validation:
✅ All agents in pipeline exist in agents/
✅ All steps coherent between routing and orchestration
✅ All tiers match agent frontmatter declarations
✅ Documentation up to date

Pipeline health: 100%
```

---

## Alerts

| Alert | Description |
|-------|-------------|
| PIPELINE_AGENT_MISSING | Agent declared but file absent |
| PIPELINE_STEP_MISMATCH | Step in routing ≠ orchestration |
| PIPELINE_TIER_MISMATCH | Tier in config ≠ agent frontmatter |
| PIPELINE_DOC_OUTDATED | Schema docs ≠ actual config |

---

## Usage

```bash
/harmony pipeline            # 8 - Coherence pipeline
/harmony pipeline --verbose  # Details complets
/harmony pipeline --fix      # Proposer corrections
```

---

## See Also

- [Full Audit](full.md) - Complete validation
- [Report](report.md) - Coherence matrix
