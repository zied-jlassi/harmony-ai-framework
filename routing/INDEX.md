# Routing Module Index

> **Quick Reference**: Agent detection, routing, and orchestration

---

## Files

| File | Description | Status |
|------|-------------|--------|
| [README.md](README.md) | Overview and architecture | Active |
| [detection-patterns.yaml](detection-patterns.yaml) | Keywords, regex, scores | Active |
| [routing-algorithm.yaml](routing-algorithm.yaml) | Thresholds and weights | Active |
| [disambiguation-prompt.yaml](disambiguation-prompt.yaml) | LLM classification | Active |
| [parallel-groups.yaml](parallel-groups.yaml) | Pipeline concurrency | Active |
| [handoff-protocol.yaml](handoff-protocol.yaml) | Agent handoffs | Active |
| [contextual-routing.yaml](contextual-routing.yaml) | Specialty routing | Active |

---

## Quick Reference

### Scoring Formula

```
score = 0.5 * keyword + 0.3 * context + 0.2 * regex
```

### Decision Thresholds

| Check | Threshold |
|-------|-----------|
| Confident | score >= 0.85 AND delta >= 0.30 |
| LLM Fallback | confidence >= 0.70 |
| Ask User | confidence < 0.50 |

### Agent Commands

| Agent | Command | When |
|-------|---------|------|
| scrum-master | `/scrum-master create-story` | Phase 3 |
| ucv-writer | `/ucv-writer STORY-XXX` | Phase 3 |
| developer | `/developer STORY-XXX` | Phase 4 |
| tester | `/tester STORY-XXX` | Phase 4 |
| ucv-qa | `/ucv-qa STORY-XXX` | After dev+test |
| exploratory-qa | `/exploratory-qa [module]` | Before closure |
| ucv-validator | `/ucv-validator STORY-XXX` | Final gate |
| accessibility | `/accessibility [module]` | UI changes |
| security | `/security [module]` | Before release |
| rgpd | `/rgpd [module]` | PII handling |

---

## Story Lifecycle Pipeline

```
scrum-master → ucv-writer → [USER] → developer → tester
     ↓              ↓          ↓          ↓          ↓
  STORY.md     UCV.md      APPROVE    [dev]✓     [test]✓
                                         ↓
                              ucv-qa → exploratory-qa → ucv-validator
                                 ↓           ↓               ↓
                              [qa]✓       Go/No-Go        DONE
```
