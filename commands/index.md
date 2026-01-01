# Harmony Command Center

> **The unified command interface for the Harmony Framework.**

---

## Interactive Menu

When invoked without arguments, display this menu:

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                      HARMONY FRAMEWORK - Command Center                        ║
║                     "Learn. Protect. Deliver." v2.0                           ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔍 VALIDATION                                                               ║
║   ─────────────                                                               ║
║    1  full           Complete audit of all framework resources (~2-5 min)    ║
║    2  quick          Fast check: orphans + broken refs (~30s)                ║
║    3  duplicates     Detect and compare duplicates (checksum+diff)           ║
║    4  fix            Propose fixes (human validation required)               ║
║    5  watch          Pre-commit hook validation                              ║
║                                                                               ║
║   📊 REPORTS                                                                  ║
║   ──────────                                                                  ║
║    6  report         Complete coherence matrix with scores                   ║
║    7  tokens         Token cost per agent (auto vs manual)                   ║
║                                                                               ║
║   🎯 SPECIFIC VALIDATION                                                      ║
║   ─────────────────────                                                       ║
║    8  pipeline       Pipeline config vs documentation coherence              ║
║    9  hooks          Claude hooks validation (executable, refs)              ║
║   10  patterns       Patterns validation (manifest, orphans)                 ║
║                                                                               ║
║   🔄 SYNCHRONIZATION                                                          ║
║   ──────────────────                                                          ║
║   11  memory         Sync rules MCP memory <-> CLAUDE.md                     ║
║   12  claude         Claude Code official config validation                  ║
║   12u claude-update  Update compliance rules (+ GADER pattern)               ║
║                                                                               ║
║   📏 APPLICATION RULES                                                        ║
║   ────────────────────                                                        ║
║   13  rules          Scan and validate all rules (66+ rules)                 ║
║   14  rules-usage    Check rules usage in codebase                           ║
║   15  rules-report   Generate compliance report by category                  ║
║                                                                               ║
║   🛡️ SENTINEL (Auto-Learning System)                                          ║
║   ─────────────────────────────────                                           ║
║   16  sentinel       Health dashboard: circuit breaker, errors, patterns     ║
║   17  sentinel-learn Document an error in error-journal                      ║
║   18  sentinel-reset Reset circuit breaker after analysis                    ║
║   19  sentinel-check Complete system memory verification                     ║
║   20  sentinel-report Detailed errors and patterns report                    ║
║                                                                               ║
║   📚 KNOWLEDGE & PROFILES                                                      ║
║   ───────────────────────                                                      ║
║   21  learn          Learn from URL/search (2025 sources)                    ║
║   22  profiles       List/activate tech profiles (nestjs, angular...)        ║
║   23  specialties    List/activate specialties (gaming, medical...)          ║
║                                                                               ║
║   🔌 INTEGRATIONS (LLM/IDE)                                                    ║
║   ─────────────────────────                                                    ║
║   24  install        Deploy Harmony to IDE (cursor, windsurf...)             ║
║   25  status         Show installed integrations                             ║
║                                                                               ║
║   ✅ QUALITY (HQVF)                                                            ║
║   ─────────────────                                                            ║
║   26  ucv            Manage UCVs for a story (create, view)                  ║
║   27  ucv-validate   Verify 100% UCV coverage                                ║
║                                                                               ║
║   🆕 FRAMEWORK                                                                 ║
║   ────────────                                                                 ║
║   28  init           Initialize Harmony in a new project                     ║
║   29  upgrade        Upgrade framework to latest version                     ║
║   30  export         Export configuration for backup                         ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║   Type number (1-30) or command name:                                         ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Command Mapping

| Selection | Command | Description | File |
|-----------|---------|-------------|------|
| 1 | `harmony full` | Complete audit | [full.md](full.md) |
| 2 | `harmony quick` | Quick check | [quick.md](quick.md) |
| 3 | `harmony duplicates` | Duplication detection | [duplicates.md](duplicates.md) |
| 4 | `harmony fix` | Propose fixes | [fix.md](fix.md) |
| 5 | `harmony watch` | Pre-commit hook | [watch.md](watch.md) |
| 6 | `harmony report` | Coherence matrix | [report.md](report.md) |
| 7 | `harmony tokens` | Token report | [tokens.md](tokens.md) |
| 8 | `harmony pipeline` | Pipeline validation | [pipeline.md](pipeline.md) |
| 9 | `harmony hooks` | Hooks validation | [hooks.md](hooks.md) |
| 10 | `harmony patterns` | Patterns validation | [patterns.md](patterns.md) |
| 11 | `harmony memory` | Memory sync | [memory.md](memory.md) |
| 12 | `harmony claude` | Claude compliance | [claude.md](claude.md) |
| 12u | `harmony claude --update` | Update rules | [claude.md](claude.md) |
| 13 | `harmony rules` | Rules audit | [rules.md](rules.md) |
| 14 | `harmony rules --usage` | Rules usage | [rules.md](rules.md) |
| 15 | `harmony rules --report` | Rules report | [rules.md](rules.md) |
| 16 | `harmony sentinel` | Sentinel dashboard | [sentinel.md](sentinel.md) |
| 17 | `harmony sentinel --learn` | Learn error | [sentinel.md](sentinel.md) |
| 18 | `harmony sentinel --reset` | Reset circuit | [sentinel.md](sentinel.md) |
| 19 | `harmony sentinel --check` | System check | [sentinel.md](sentinel.md) |
| 20 | `harmony sentinel --report` | Detailed report | [sentinel.md](sentinel.md) |
| 21 | `harmony learn <url>` | Web learning | [learn.md](learn.md) |
| 22 | `harmony profiles` | Profiles list | [profiles.md](profiles.md) |
| 23 | `harmony specialties` | Specialties list | [specialties.md](specialties.md) |
| 24 | `harmony install <ide>` | Install to IDE | [install.md](install.md) |
| 25 | `harmony install --status` | Install status | [install.md](install.md) |
| 26 | `harmony ucv <story>` | Create UCVs | [ucv.md](ucv.md) |
| 27 | `harmony ucv --validate <story>` | Validate UCVs | [ucv.md](ucv.md) |
| 28 | `harmony init` | Initialize project | [init.md](init.md) |
| 29 | `harmony upgrade` | Upgrade framework | [upgrade.md](upgrade.md) |
| 30 | `harmony export` | Export config | [export.md](export.md) |

---

## CLI Usage

```bash
# Interactive menu
harmony

# Direct command
harmony <command> [options]

# Examples
harmony full                    # Complete audit
harmony quick                   # Quick check
harmony sentinel                # Sentinel dashboard
harmony learn https://...       # Learn from URL
harmony install cursor          # Deploy to Cursor
harmony ucv STORY-042           # Create UCVs
```

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
│  Show Menu      Load Command                                    │
│       │          File (.md)                                      │
│       ▼               │                                          │
│  Wait Input           ▼                                          │
│       │          Execute                                         │
│       └───────────────┘                                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Related Documentation

- [Architecture](../docs/architecture.md)
- [Getting Started](../docs/getting-started.md)
- [Sentinel System](sentinel.md)
- [HQVF Quality](ucv.md)
