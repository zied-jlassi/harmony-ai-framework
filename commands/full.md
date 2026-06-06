# Harmony Full - Complete Coherence Audit

> Exhaustive scan of all 18 framework categories with broken link detection.

---

## Usage

```bash
/harmony full
```

---

## What It Checks (18 Categories)

| # | Category | Description |
|---|----------|-------------|
| 1 | COMMANDS | Index, files, orphans |
| 2 | AGENTS | Frontmatter, required fields, triggers |
| 3 | SPECIALTIES | Manifests, branches, references |
| 4 | PROFILES | Registry, categories, knowledge refs |
| 5 | KNOWLEDGE | Structure, markdown files, orphans |
| 6 | CONFIG | Required configs, YAML validity |
| 7 | MEMORY | JSON files, circuit breaker state |
| 8 | MCP | Server availability |
| 9 | BIN | Entry point scripts, shell syntax |
| 10 | HOOKS | Hook scripts, state paths |
| 11 | INTEGRATIONS | Registry, IDE manifests |
| 12 | PATTERNS | P-XXX format, registry, case studies |
| 13 | ROUTING | YAML validity, agent refs, phases |
| 14 | RULES | R-XXX format, YAML validity |
| 15 | WORKFLOWS | Structure, cross-references |
| 16 | ERROR-LIBRARY | JSON schema, ID format |
| 17 | TIPS | Sequential naming, markdown |
| 18 | TOOLS | Shell syntax, Docker, deps |
| - | LINKS | Broken link detection |

---

## Execution

1. **Read template**: `templates/audit/full-audit.template.md`
2. **Run script**: `lib/harmony-audit.sh` (if available)
3. **Generate output** following template format
4. **Calculate score**: (valid / total) per category
5. **Show recommendations** based on findings

---

## Output Template

See: `templates/audit/full-audit.template.md`

---

## See Also

- [Quick](quick.md) - Fast validation (~30s)
- [Fix](fix.md) - Auto-repair issues
- [Report](report.md) - Export coherence matrix
