# Harmony Command Center

> **The unified command interface for the Harmony Framework.**

---

## Interactive Menu

When invoked without arguments, display this menu:

```
╔════════════════════════════════════════════════════════════════════════════════╗
║                         HARMONY - Framework Orchestrator                        ║
║                           INTERACTIVE COMMAND CENTER                            ║
╠════════════════════════════════════════════════════════════════════════════════╣
║  Project: {project_name}                                                        ║
║  Phase: {phase_number} - {phase_name}        Status: {phase_status}             ║
║  Circuit Breaker: {cb_state}                 Failures: {failures}/3             ║
╚════════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                 ║
║   🔍 VALIDATION FRAMEWORK                                                       ║
║   ───────────────────────                                                       ║
║    1  Audit complet       Scan exhaustif de toutes les ressources (~2-5 min)   ║
║    2  Check rapide        Verification orphelins + refs cassees (~30s)         ║
║    3  Duplications        Detection et comparaison duplicats (checksum+diff)   ║
║    4  Proposer fixes      Generer corrections (validation humaine requise)     ║
║    5  Watch mode          Hook pre-commit validation                           ║
║                                                                                 ║
║   📊 RAPPORTS                                                                   ║
║   ──────────                                                                    ║
║    6  Matrice coherence   Rapport complet avec scores par categorie            ║
║    7  Tokens Report       Cout tokens par agent (auto vs manuel)               ║
║    8  API Costs           Suivi couts API par session/agent/modele (USD/EUR)   ║
║                                                                                 ║
║   🎯 VALIDATION SPECIFIQUE                                                      ║
║   ────────────────────────                                                      ║
║    9  Pipeline            Coherence pipeline config vs documentation           ║
║   10  Hooks               Validation hooks Claude (executable, refs)           ║
║   11  Patterns            Validation patterns (manifest, orphelins)            ║
║                                                                                 ║
║   🔄 SYNCHRONISATION                                                            ║
║   ─────────────────                                                             ║
║   12  Memory Sync         Sync regles MCP memory <-> CLAUDE.md                 ║
║   13  Claude Compliance   Validation config Claude Code officielle             ║
║   13u Claude Update       MAJ regles conformite (+ pattern GADER)              ║
║                                                                                 ║
║   📏 REGLES APPLICATION                                                         ║
║   ─────────────────────                                                         ║
║   14  Rules Audit         Scanner et valider toutes les regles                 ║
║   15  Rules Usage         Verifier utilisation des regles dans le code         ║
║   16  Rules Report        Generer rapport de conformite par categorie          ║
║                                                                                 ║
║   🛡️ HARMONY SENTINEL (Auto-Learning)                                           ║
║   ───────────────────────────────────                                           ║
║   17  Sentinel Status     Dashboard sante: circuit breaker, erreurs, patterns  ║
║   18  Sentinel Learn      Documenter une erreur dans error-journal             ║
║   19  Sentinel Reset      Reinitialiser circuit breaker apres analyse          ║
║   20  Sentinel Check      Verification complete du systeme memoire             ║
║   21  Sentinel Report     Rapport detaille erreurs et patterns                 ║
║                                                                                 ║
║   📚 KNOWLEDGE & PROFILES                                                       ║
║   ───────────────────────                                                       ║
║   22  Learn               Apprendre depuis URL/recherche (sources 2025)        ║
║   23  Profiles            Lister/activer tech profiles (nestjs, angular...)    ║
║   24  Specialties         Lister/activer specialties (gaming, medical...)      ║
║                                                                                 ║
║   🔌 INTEGRATIONS (LLM/IDE)                                                     ║
║   ─────────────────────────                                                     ║
║   25  Install             Deployer Harmony vers IDE (cursor, windsurf...)      ║
║   26  Install Status      Afficher integrations installees                     ║
║                                                                                 ║
║   ✅ QUALITE (HQVF)                                                             ║
║   ─────────────────                                                             ║
║   27  UCV Create          Creer UCVs pour une story                            ║
║   28  UCV Validate        Verifier couverture 100% UCVs                        ║
║                                                                                 ║
║   🆕 FRAMEWORK                                                                  ║
║   ────────────                                                                  ║
║   29  Init                Initialiser Harmony dans un nouveau projet           ║
║   30  Upgrade             Mettre a jour le framework                           ║
║   31  Export              Exporter configuration pour backup                   ║
║                                                                                 ║
║   📈 MONITORING                                                                 ║
║   ─────────────                                                                 ║
║   32  Costs               Suivi couts API par session/agent/modele             ║
║   33  Monitor             Team Learning Journal - Prompt effectiveness         ║
║                                                                                 ║
╠════════════════════════════════════════════════════════════════════════════════╣
║   Tapez le numero (1-33) ou 13u pour update:                                    ║
╚════════════════════════════════════════════════════════════════════════════════╝


📊 Current Status

┌────────────────────────┬──────────────┬────────────────────────┐
│ Guardian Protocol      │ {guardian}   │ {guardian_status}      │
│ Sentinel System        │ {sentinel}   │ {sentinel_failures}    │
│ HQVF Quality           │ {hqvf}       │ {hqvf_approval}        │
│ Current Sprint         │ {sprint}     │ {sprint_status}        │
│ Current Story          │ {story}      │ {story_status}         │
└────────────────────────┴──────────────┴────────────────────────┘


⚡ Quick Actions

- Start Session: Run /go to initialize session context
- Health Check: Run harmony quick for rapid status
- View Errors: Run harmony sentinel for error journal
- Learning Journal: Run harmony monitor start for prompt analytics


---
Select a mode by entering its number or command (e.g., 2 or harmony quick)
```

---

## Command Mapping

> **Note:** This table lists **36 command entries** mapping to **29 command files**. Some entries are **variants** (subcommands with flags) that share the same documentation file. Variants are indicated by suffixes like `-update`, `-usage`, `-learn`, etc.

| # | Command | Syntax | File |
|---|---------|--------|------|
| 1 | full | `harmony full` | [full.md](full.md) |
| 2 | quick | `harmony quick` | [quick.md](quick.md) |
| 3 | duplicates | `harmony duplicates` | [duplicates.md](duplicates.md) |
| 4 | fix | `harmony fix` | [fix.md](fix.md) |
| 5 | watch | `harmony watch` | [watch.md](watch.md) |
| 6 | report | `harmony report` | [report.md](report.md) |
| 7 | tokens | `harmony tokens` | [tokens.md](tokens.md) |
| 8 | pipeline | `harmony pipeline` | [pipeline.md](pipeline.md) |
| 9 | hooks | `harmony hooks` | [hooks.md](hooks.md) |
| 10 | patterns | `harmony patterns` | [patterns.md](patterns.md) |
| 11 | memory | `harmony memory` | [memory.md](memory.md) |
| 12 | claude | `harmony claude` | [claude.md](claude.md) |
| 12u | claude-update | `harmony claude --update` | [claude.md](claude.md) |
| 13 | rules | `harmony rules` | [rules.md](rules.md) |
| 14 | rules-usage | `harmony rules --usage` | [rules.md](rules.md) |
| 15 | rules-report | `harmony rules --report` | [rules.md](rules.md) |
| 16 | sentinel | `harmony sentinel` | [sentinel.md](sentinel.md) |
| 17 | sentinel-learn | `harmony sentinel --learn` | [sentinel.md](sentinel.md) |
| 18 | sentinel-reset | `harmony sentinel --reset` | [sentinel.md](sentinel.md) |
| 19 | sentinel-check | `harmony sentinel --check` | [sentinel.md](sentinel.md) |
| 20 | sentinel-report | `harmony sentinel --report` | [sentinel.md](sentinel.md) |
| 21 | learn | `harmony learn <url>` | [learn.md](learn.md) |
| 22 | profiles | `harmony profiles` | [profiles.md](profiles.md) |
| 23 | specialties | `harmony specialties` | [specialties.md](specialties.md) |
| 24 | install | `harmony install <ide>` | [install.md](install.md) |
| 25 | install-status | `harmony install --status` | [install.md](install.md) |
| 26 | ucv | `harmony ucv <story>` | [ucv.md](ucv.md) |
| 27 | ucv-validate | `harmony ucv --validate <story>` | [ucv.md](ucv.md) |
| 28 | init | `harmony init` | [init.md](init.md) |
| 29 | upgrade | `harmony upgrade` | [upgrade.md](upgrade.md) |
| 30 | export | `harmony export` | [export.md](export.md) |
| 31 | go | `harmony go` | [go.md](go.md) |
| 32 | config | `harmony config` | [config.md](config.md) |
| 33 | coverage | `harmony coverage` | [coverage.md](coverage.md) |
| 34 | matrix | `harmony matrix` | [matrix.md](matrix.md) |
| 35 | test-book | `harmony test-book` | [test-book.md](test-book.md) |
| 36 | monitor | `harmony monitor` | [monitor.md](monitor.md) |

---

## Dynamic Values

The menu header displays dynamic values read from memory files:

| Placeholder | Source | Default |
|-------------|--------|---------|
| `{project_name}` | `.harmony/project.yaml` → name | "Unnamed Project" |
| `{phase_number}` | `.harmony/local/memory/workflow-state.json` → phase.current | 1 |
| `{phase_name}` | `.harmony/local/memory/workflow-state.json` → phase.name | "Discovery" |
| `{phase_status}` | Derived from phase progress | "Not started" |
| `{cb_state}` | `.harmony/local/memory/circuit-breaker.json` → state | "CLOSED" |
| `{failures}` | `.harmony/local/memory/circuit-breaker.json` → consecutive_failures | 0 |
| `{guardian}` | `.harmony/local/memory/workflow-state.json` → guardian.mode | "WARN mode" |
| `{guardian_status}` | `.harmony/local/memory/workflow-state.json` → guardian.enabled | "Active" |
| `{sentinel}` | `.harmony/local/memory/circuit-breaker.json` → state | "CLOSED" |
| `{sentinel_failures}` | `.harmony/local/memory/circuit-breaker.json` → consecutive_failures | "0 failures" |
| `{hqvf}` | `.harmony/local/memory/workflow-state.json` → hqvf.enabled | "Enabled" |
| `{hqvf_approval}` | `.harmony/local/memory/workflow-state.json` → hqvf.require_approval | "Requires approval" |
| `{sprint}` | `.harmony/local/memory/workflow-state.json` → active_context.current_sprint | "None" |
| `{sprint_status}` | Derived from sprint data | "--" |
| `{story}` | `.harmony/local/memory/workflow-state.json` → active_context.current_story | "None" |
| `{story_status}` | Derived from story file | "--" |

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    HARMONY COMMAND FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User Input                                                      │
│      │                                                           │
│      ▼                                                           │
│  ┌──────────────────────────┐                                   │
│  │   Parse Command/Number   │                                   │
│  └────────────┬─────────────┘                                   │
│               │                                                  │
│       ┌───────┴───────┐                                         │
│       │               │                                          │
│       ▼               ▼                                          │
│  [No args]        [Has args]                                    │
│       │               │                                          │
│       ▼               ▼                                          │
│  Read Memory      Parse Mode                                    │
│  Files            from Args                                      │
│       │               │                                          │
│       ▼               ▼                                          │
│  Display Menu     Load Command                                  │
│  with Status      File (.md)                                     │
│       │               │                                          │
│       ▼               ▼                                          │
│  Wait for         Execute                                        │
│  Selection        Command                                        │
│       │               │                                          │
│       └───────────────┘                                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## CLI Usage Examples

```bash
# Interactive menu (shows status + all options)
harmony

# Direct commands
harmony full                    # Complete audit
harmony quick                   # Quick check
harmony sentinel                # Sentinel dashboard
harmony sentinel --learn        # Document an error
harmony sentinel --reset        # Reset circuit breaker
harmony learn https://...       # Learn from URL
harmony install cursor          # Deploy to Cursor
harmony ucv STORY-042           # Create UCVs
```

---

## Related Documentation

- [Architecture](../docs/architecture.md)
- [Getting Started](../docs/getting-started.md)
- [Sentinel System](sentinel.md)
- [HQVF Quality](ucv.md)
