# Harmony Quick - Fast Check

> Rapid verification of orphans and broken references (~30s).

---

## What It Checks

| Check | Time |
|-------|------|
| Orphan files | 5s |
| Broken links | 10s |
| Missing files | 5s |
| Syntax errors | 10s |

---

## Output

```
HARMONY QUICK CHECK
───────────────────

✅ Orphan files: 0
✅ Broken links: 0
⚠️ Missing files: 2
   ├── profiles/backend/django/knowledge/views.md
   └── profiles/backend/django/knowledge/models.md

Overall: PASS with warnings
```

---

## Usage

```bash
harmony quick
```

---

## See Also

- [Full Audit](full.md) - Complete scan
- [Fix](fix.md) - Propose corrections
