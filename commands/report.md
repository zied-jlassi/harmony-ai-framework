# Harmony Report - Coherence Matrix

> Complete coherence report with scores by category.

---

## Framework Source Validation

| Category | Source Path | Validation |
|----------|-------------|------------|
| **Agents** | `framework/agents/**/*.md` | Frontmatter, structure, references |
| **Commands** | `framework/commands/*.md` | Syntax, completeness |
| **Config** | `framework/config/*.yaml` | Schema, references |
| **Core** | `framework/core/**/*.md` | Knowledge, protocols |
| **Docs** | `framework/docs/**/*.md` | ADRs, design docs |
| **Hooks** | `framework/hooks/*.sh` | Executable, syntax |
| **Integrations** | `framework/integrations/*/templates/` | Per-IDE templates |
| **Memory** | `framework/memory/templates/*.json` | Schema templates |
| **Patterns** | `framework/patterns/*.md` | Structure, references |
| **Profiles** | `framework/profiles/*/*/` | Manifest, knowledge |
| **Rules** | `framework/rules/*.yaml` | Schema, IDs |
| **Shared** | `framework/shared/**/*` | Protocols |
| **Specialties** | `framework/specialties/*/` | Agents, knowledge |
| **Workflows** | `framework/workflows/**/*.yaml` | Steps, references |

---

## Installed Project Validation

| Category | Installed Path | Validation |
|----------|----------------|------------|
| **Config** | `.harmony/config/*.yaml` | Valid YAML, coherence |
| **Memory** | `.claude/memory/*.json` | Schema, state |
| **Commands** | `.claude/commands/*.md` | /harmony present |
| **Hooks** | `.claude/hooks/*.sh` | Executable |
| **CLAUDE.md** | `CLAUDE.md` | References valid |

---

## Output Example

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    HARMONY COHERENCE MATRIX                                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   FRAMEWORK SOURCE                                                            ║
║   ────────────────                                                            ║
║   Agents             18/18    ✅ All valid                                    ║
║   Commands           30/30    ✅ All valid                                    ║
║   Profiles           50/50    ✅ All complete                                 ║
║   Specialties        10/10    ✅ All complete                                 ║
║   Workflows          25/25    ✅ All valid                                    ║
║   Patterns            8/8     ✅ All valid                                    ║
║   Integrations        5/5     ✅ All templates present                        ║
║                                                                               ║
║   CROSS-REFERENCES                                                            ║
║   ────────────────                                                            ║
║   Agent → Agent      42/42    ✅ All valid                                    ║
║   Command → Command  15/15    ✅ All valid                                    ║
║   Workflow → Agent   30/30    ✅ All valid                                    ║
║   Profile → Knowledge 50/50   ✅ All valid                                    ║
║   Specialty → Agent  20/20    ✅ All valid                                    ║
║                                                                               ║
║   INSTALLED PROJECT                                                           ║
║   ─────────────────                                                           ║
║   .harmony/config    3/3      ✅ Valid                                        ║
║   .claude/memory     4/4      ✅ Valid                                        ║
║   .claude/commands   1/1      ✅ /harmony present                             ║
║   .claude/hooks      2/2      ✅ Executable                                   ║
║   CLAUDE.md          1/1      ✅ References valid                             ║
║                                                                               ║
║   ─────────────────────────────────────────────────────                        ║
║   OVERALL           100/100   ✅ HEALTHY                                      ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Cross-Reference Validation

### Agent References

| Check | Description |
|-------|-------------|
| See Also links | Links to other agents exist |
| Related agents | Referenced agents exist |
| AI Knowledge refs | Knowledge files exist in specialties/ai/knowledge/ |
| Specialty agents | Specialty agents in specialties/*/agents/ |

### Profile References

| Check | Description |
|-------|-------------|
| Manifest → Knowledge | All knowledge files exist |
| Dependencies | Required profiles exist |
| Registry sync | Listed in profiles-registry.yaml |

### Workflow References

| Check | Description |
|-------|-------------|
| Step files | All steps/*.md exist |
| Agent invocations | Referenced agents exist |
| Templates | Template files exist |

### Integration References

| Check | Description |
|-------|-------------|
| Templates exist | Per-IDE templates present |
| Variables valid | Template variables documented |
| Paths correct | IDE-specific paths valid |

---

## Scoring

| Category | Weight | Calculation |
|----------|--------|-------------|
| Agents | 20% | valid / total × 100 |
| Commands | 15% | valid / total × 100 |
| Profiles | 15% | (manifest + knowledge) / total × 100 |
| Specialties | 15% | (agents + knowledge) / total × 100 |
| Workflows | 15% | valid steps / total × 100 |
| Cross-refs | 20% | valid refs / total × 100 |

---

## Usage

```bash
/harmony report              # Display in terminal
/harmony report --json       # Export as JSON
/harmony report --verbose    # Show all details
```

---

## See Also

- [Full Audit](full.md) - Detailed scan
- [Quick](quick.md) - Fast health check
- [Tokens](tokens.md) - Token usage report
