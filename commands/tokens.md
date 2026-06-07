# Harmony Tokens - Token Usage Report

> Analyze token cost per agent + real-time session monitoring.

---

## What It Shows

| Metric | Description |
|--------|-------------|
| Agent context | Base tokens loaded per agent |
| Knowledge | Additional tokens from profiles/specialties |
| Session | Tokens used in active session |
| Auto-loaded | Context automatically injected |
| Manual | User-requested context |
| **Live usage** | Real-time consumption with progress bar |

---

## 1. Agent Cost Report (Static Analysis)

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
/harmony --mode tokens              # Dashboard complet (rapport + live)
/harmony --mode tokens --breakdown  # Cout par fichier charge
/harmony --mode tokens --optimize   # Suggestions d'optimisation
```

---

## 2. Live Session Monitor (Real-time)

```
╔════════════════════════════════════════════════════════════════╗
║            🔢 HARMONY TOKEN MONITOR                            ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Session: 20260104_143052                                      ║
║                                                                ║
║  🟢 Current Usage:                                             ║
║     ████████░░░░░░░░░░░░░░░░░░░░ 25%                           ║
║     25000 / 100000 tokens                                      ║
║                                                                ║
║  Thresholds:                                                   ║
║     🟢 OK        < 50000                                       ║
║     🟡 Warning   50000 - 80000                                 ║
║     🔴 Critical  > 80000                                       ║
║                                                                ║
║  Components Loaded:                                            ║
║     developer.md: 1200 tokens                                  ║
║     typescript-profile: 800 tokens                             ║
║                                                                ║
║  Tool Usage:                                                   ║
║     Read: 15 calls, 8000 tokens                                ║
║     Edit: 8 calls, 3000 tokens                                 ║
║     Bash: 12 calls, 2000 tokens                                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

### Live Commands

```bash
# Display
bash .harmony/hooks/token-monitor.sh dashboard  # Full dashboard
bash .harmony/hooks/token-monitor.sh mini       # Inline compact
bash .harmony/hooks/token-monitor.sh history    # Last 7 days summary

# Tracking
bash .harmony/hooks/token-monitor.sh agent "developer" 5000
bash .harmony/hooks/token-monitor.sh command "/harmony" 2000
bash .harmony/hooks/token-monitor.sh load "typescript.md" 3200
bash .harmony/hooks/token-monitor.sh tool "Read" 500 2000

# Management
bash .harmony/hooks/token-monitor.sh report     # Export MD report
bash .harmony/hooks/token-monitor.sh reset      # Reset session counter
bash .harmony/hooks/token-monitor.sh reset-all  # Reset all (session + history)
bash .harmony/hooks/token-monitor.sh help       # Show help
```

---

## 3. Files

| File | Description | Auto-created |
|------|-------------|--------------|
| `.harmony/hooks/token-monitor.sh` | Monitoring script | No (in framework) |
| `.harmony/local/memory/token-usage.json` | Live session counter | Yes (on first use) |
| `.harmony/local/logs/tokens-YYYY-MM-DD.json` | Daily history logs | Yes (on first use) |
| `.harmony/local/logs/token-report-*.md` | Exported reports | Yes (on export) |

**Log Rotation:** Max 8 days, 1MB per file

---

## See Also

- [Report](report.md) - Full coherence report
- [Profiles](profiles.md) - Manage profiles
