# Harmony Patterns - Validation

> Validate design patterns (manifest, orphans, structure).

---

## What It Checks

| Check | Description |
|-------|-------------|
| Manifest valid | patterns-manifest.yaml structure |
| Files exist | All declared patterns have files |
| Structure valid | Required sections present |
| References valid | Cross-references work |
| No orphans | No undeclared pattern files |

---

## Critical Patterns

| Pattern | Purpose |
|---------|---------|
| document-enrichment.md | GADER - Anti-overwrite pattern |
| search-resource.md | POST body for all filters |
| circuit-breaker.md | Error protection protocol |

---

## Output

```
HARMONY PATTERNS VALIDATION
───────────────────────────

Checking patterns coherence...

✅ patterns-manifest.yaml     8 patterns declared
✅ All pattern files exist
✅ No orphan patterns
✅ Cross-references valid

Pattern health: 100%
```

---

## Usage

```bash
/harmony patterns            # 10 - Validation patterns
/harmony patterns --fix      # Proposer corrections
```

---

## See Also

- [Full Audit](full.md) - Complete validation
- [Report](report.md) - Coherence matrix
