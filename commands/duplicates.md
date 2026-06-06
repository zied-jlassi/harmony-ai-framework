# Harmony Duplicates - Detection and Comparison

> Detect and compare duplicate files by checksum and diff.

---

## What It Checks

### Phase 1: Similar Names

| Detection | Threshold |
|-----------|-----------|
| Levenshtein distance | < 3 |
| Same base name | Different extensions |
| Different prefixes/suffixes | dev.md vs hf-dev.md |

### Phase 2: Similar Content

| Check | Result |
|-------|--------|
| SHA256 checksum identical | DUPLICATE_EXACT |
| Content > 80% similar | DUPLICATE_PARTIAL |
| Content < 80% similar | SIMILAR_FILE |

---

## Output

```
HARMONY DUPLICATES CHECK
────────────────────────

Phase 1: Scanning names...
  Found: 3 potential duplicates

Phase 2: Comparing content...

| Fichier 1 | Fichier 2 | Type | Checksum Match | Diff Lines |
|-----------|-----------|------|----------------|------------|
| dev.md | hf-dev.md | PARTIAL | NO | 45 lines |
| sm.md | scrum-master.md | EXACT | YES | 0 lines |
| qa.md | exploratory-qa.md | PARTIAL | NO | 120 lines |

Recommendations:
├── EXACT duplicates: Consider removing one
└── PARTIAL duplicates: Review diff and merge
```

---

## Merge Workflow

```
DUPLICATE HANDLING (MANDATORY)

1. IF checksum identical:
   → Propose deletion of oldest file
   → WAIT for human approval

2. IF checksum different:
   a. Generate full diff
   b. Identify unique content in each file
   c. Propose merge to most complete file
   d. WAIT for human approval
   e. Archive other file (don't delete)

3. NEVER delete without approval
```

---

## Usage

```bash
/harmony duplicates
```

---

## See Also

- [Full Audit](full.md) - Complete scan including duplicates
- [Quick Check](quick.md) - Fast orphan detection
- [Fix](fix.md) - Propose corrections
