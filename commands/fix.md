# Harmony Fix - Propose Corrections

> Generate correction proposals for detected issues (requires human validation).

---

## What It Does

Analyzes issues found by `harmony full` or `harmony quick` and proposes fixes.

| Issue Type | Proposed Fix |
|------------|--------------|
| Orphan file | Add to manifest or delete |
| Broken reference | Update link or remove |
| Missing file | Create from template |
| Duplicate | Merge or archive |
| Naming violation | Rename following convention |

---

## Output

```
HARMONY FIX PROPOSALS
─────────────────────

Found 5 issues, proposing 5 fixes:

1. [ORPHAN] agents/old-agent.md
   → Propose: Add to routing-rules.yaml
   → Alternative: Archive to .archive/

2. [BROKEN_REF] architect.md:145 → missing-file.md
   → Propose: Remove link (file doesn't exist)

3. [DUPLICATE] dev.md ≈ bmm-dev.md (87% similar)
   → Propose: Merge to bmm-dev.md, archive dev.md

4. [MISSING] profiles/python/manifest.yaml
   → Propose: Create from template

5. [NAMING] QA-agent.md → qa-agent.md
   → Propose: Rename to lowercase

Apply fixes? (y/n/select)
```

---

## Important Rules

```
⚠️ HUMAN VALIDATION REQUIRED

1. NEVER auto-apply fixes
2. ALWAYS show diff before applying
3. ALWAYS ask confirmation
4. PREFER archive over delete
5. LOG all applied fixes
```

---

## Usage

```bash
/harmony fix         # Show all proposals
/harmony fix --apply # Apply with confirmation
```

---

## See Also

- [Full Audit](full.md) - Detect issues
- [Duplicates](duplicates.md) - Handle duplicates
- [Quick](quick.md) - Fast detection
