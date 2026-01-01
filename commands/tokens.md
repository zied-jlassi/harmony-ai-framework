# Harmony Tokens - Token Usage Report

> Analyze token cost per agent (auto vs manual context).

---

## What It Shows

| Metric | Description |
|--------|-------------|
| Agent context | Base tokens loaded per agent |
| Knowledge | Additional tokens from profiles/specialties |
| Session | Tokens used in active session |
| Auto-loaded | Context automatically injected |
| Manual | User-requested context |

---

## Output

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    HARMONY TOKEN REPORT                                        ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   AGENT CONTEXT COSTS (base)                                                  ║
║   ──────────────────────────                                                  ║
║   | Agent          | Tokens  | Tier  | Auto-Load |                           ║
║   |----------------|---------|-------|-----------|                           ║
║   | Harmony        |  2,500  | T1    | Always    |                           ║
║   | Developer      |  4,200  | T2    | On dev    |                           ║
║   | Architect      |  3,800  | T1    | On design |                           ║
║   | Tester         |  2,100  | T2    | On test   |                           ║
║   | SM             |  1,800  | T3    | On sprint |                           ║
║   | Sentinel       |    800  | T4    | Always    |                           ║
║                                                                               ║
║   SESSION SUMMARY                                                             ║
║   ───────────────                                                             ║
║   Auto-loaded:     8,500 tokens                                              ║
║   User-requested:  2,400 tokens                                              ║
║   Total context:  10,900 tokens                                              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Usage

```bash
/harmony tokens              # 7 - Token usage
/harmony tokens --breakdown  # Par fichier
/harmony tokens --optimize   # Suggestions d'optimisation
```

---

## See Also

- [Report](report.md) - Full coherence report
- [Profiles](profiles.md) - Manage profiles
