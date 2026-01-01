# Harmony Full - Complete Audit

> Exhaustive scan of all framework resources (~2-5 min).

---

## What It Checks

### 1. Agents Coherence

| Check | Description |
|-------|-------------|
| Frontmatter | Valid YAML metadata |
| Required fields | name, displayName, description |
| File existence | Referenced files exist |
| Cross-references | Links valid |

### 2. Profiles Validation

| Check | Description |
|-------|-------------|
| Registry sync | profiles-registry.yaml accurate |
| Dependencies | Required profiles exist |
| Knowledge files | Valid markdown structure |
| Orphans | No unused knowledge files |

### 3. Specialties Validation

| Check | Description |
|-------|-------------|
| Manifest valid | manifest.yaml structure |
| Agents complete | All declared agents exist |
| Patterns valid | Pattern files complete |

### 4. Integrations Check

| Check | Description |
|-------|-------------|
| Templates exist | All templates present |
| Syntax valid | Target IDE syntax correct |

### 5. Memory State

| Check | Description |
|-------|-------------|
| Files exist | All memory files present |
| JSON valid | Parseable structure |
| Circuit breaker | State consistent |

---

## Output

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    HARMONY FULL AUDIT                                          ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   AGENTS           ████████████████████  100%  ✅ 18/18 valid                 ║
║   PROFILES         ████████████████░░░░   80%  ⚠️ 16/20 complete              ║
║   SPECIALTIES      ████████████████████  100%  ✅ 2/2 valid                   ║
║   INTEGRATIONS     ████████████████████  100%  ✅ 5/5 valid                   ║
║   MEMORY           ████████████████████  100%  ✅ 4/4 valid                   ║
║                                                                               ║
║   OVERALL SCORE: 96%                                                          ║
║                                                                               ║
║   Issues Found:                                                               ║
║   ├── 4 profiles missing knowledge files                                      ║
║   └── Run: harmony learn --refresh <profile>                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Usage

```bash
harmony full
```

---

## See Also

- [Quick Check](quick.md) - Fast validation (~30s)
- [Fix](fix.md) - Propose corrections
- [Report](report.md) - Coherence matrix
