# Context Persistence System

> **🌐 Language:** English · [Français](fr/context-persistence.md)

The context persistence system protects the chain of reasoning during long analyses, before Claude Code's compaction.

## Problem solved

During long analyses (architecture, research, decisions), Claude Code's compaction can lose:
- The chain of reasoning
- The comparisons made
- The decisions in progress
- The context of investigations

**Important**: The official `@modelcontextprotocol/server-memory` server is **passive** storage — it does NOT automatically save before compaction.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTEXT PERSISTENCE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  UserPromptSubmit Hook                                          │
│  ════════════════════                                           │
│      │                                                          │
│      ├──► session-resume.sh                                     │
│      │    └── Detects in-progress sessions                      │
│      │    └── Offers resume if analysis pending                 │
│      │                                                          │
│      └──► compacting-warning.sh                                 │
│           └── Detects /clear → deletes everything               │
│           └── Detects analysis mode (keywords)                  │
│           └── Auto-save .harmony/local/tmp/sessions/            │
│           └── Yellow warning if limit approaches                │
│           └── Red alert if too many sessions                    │
│                                                                 │
│  Storage (project-specific)                                     │
│  ════════════════════════════                                   │
│      │                                                          │
│      ├──► .harmony/local/tmp/sessions/{session_id}/             │
│      │    ├── analysis.json (analysis-tracker)                  │
│      │    └── session-state.json (compacting-warning)           │
│      │                                                          │
│      ├──► .harmony/local/session-config.json (rotation config)  │
│      │                                                          │
│      └──► research/ (permanent export)                          │
│           └── SESSION-{date}-{topic}.md                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### 1. analysis-tracker.sh (lib/)

Chain-of-reasoning tracker for analyses/decisions.

**Main functions:**
```bash
# Start an analysis session
init_analysis_session "Migration jq vers Node.js" "architecture_decision"

# Add a reasoning step
add_reasoning_step "Probleme identifie" "417 usages jq dans le code"

# Add a finding
add_finding "performance" "jq 5-10x plus rapide que Node.js" "benchmark"

# Add a comparison
add_comparison "jq" "Node.js" "performance" "jq" "natif vs startup overhead"

# Mark a decision
mark_decision "jq recommande" "Performance > Portabilite" "Mise a jour prereqs"

# Export to research/
export_to_markdown "research/ADR-001-migration.md"
```

**Analysis types:**
- `architecture_decision` - Architecture decision (ADR)
- `research` - Research/Investigation
- `comparison` - Option comparison
- `investigation` - Bug/problem investigation

### 2. compacting-warning.sh (hooks/)

Pre-compaction hook with auto-save and UX warning.

**Automatic analysis-mode detection:**
```bash
ANALYSIS_KEYWORDS="analyse|analysis|research|compare|benchmark|study|evaluate|architecture|design|trade-off|decision|adr|investigation|decide|choisir|comparer"
```

**Warning thresholds:**
- 50 messages in the session
- 45 minutes of session
- Analysis mode active

**Auto-save:**
- Every 10 messages
- Every 5 minutes
- To `/tmp/harmony-sessions/{session_id}/`

**UX warning:**
```
╔══════════════════════════════════════════════════════════════════════╗
║  ⚠️  APPROACHING CONTEXT LIMIT - Compaction risk                     ║
╠══════════════════════════════════════════════════════════════════════╣
║  Session: 55 messages | 50 minutes | Mode: analysis                  ║
║  ✓ State auto-saved: /tmp/harmony-sessions/abc12345/                 ║
╠══════════════════════════════════════════════════════════════════════╣
║  Options:                                                            ║
║  1. "Save to research/" → Permanent file                             ║
║  2. "Continue" → Will resume from /tmp if compaction occurs          ║
║  3. "Create an ADR for this decision"                                ║
╚══════════════════════════════════════════════════════════════════════╝
```

### 3. session-resume.sh (hooks/)

Offers to resume in-progress analysis sessions.

**Detection at startup:**
- Checks `/tmp/harmony-sessions/` for pending sessions
- Filters by current project
- Shows the 3 most recent sessions

**Resume commands:**
```
"Resume the analysis [session_id]"
"Continue the previous analysis"
"Export the analysis to research/"
```

## Relationship with server-memory (official)

| Component | Role |
|-----------|------|
| `@modelcontextprotocol/server-memory` | Passive storage (knowledge graph, entities) |
| `analysis-tracker.sh` | **Active protection** - chain of reasoning |
| `compacting-warning.sh` | **UX warning** + auto-save before compaction |
| `session-resume.sh` | **Resume** - offers to resume sessions |

**The two are complementary:**
- `server-memory` = long-term memory (entities, relations)
- Our system = short-term protection (analyses in progress, decisions)

## Usage

### Start a structured analysis
```bash
# Via CLI (for tests)
.harmony/lib/analysis-tracker.sh init "Choix framework frontend" comparison
.harmony/lib/analysis-tracker.sh step "React vs Vue vs Svelte"
.harmony/lib/analysis-tracker.sh compare "React" "Vue" "ecosystem" "React" "Plus mature"
.harmony/lib/analysis-tracker.sh decide "React choisi" "Ecosystem et equipe"
.harmony/lib/analysis-tracker.sh export
```

### List in-progress sessions
```bash
.harmony/hooks/session-resume.sh --list
```

### Resume a session
```bash
.harmony/hooks/session-resume.sh --resume abc12345
```

### View session status
```bash
.harmony/hooks/compacting-warning.sh --status
```

### Clear all sessions (like /clear)
```bash
.harmony/hooks/compacting-warning.sh --clear
```

## Rotation & Cleanup

The system includes automatic rotation to avoid disk saturation.

### Integration with Claude Code's /clear

When the user runs `/clear` (Claude Code's native command), the hook automatically detects it and:
1. Deletes all sessions saved in `.harmony/local/tmp/sessions/`
2. Resets the session tracker
3. Shows a confirmation: `[Harmony] Sessions cleared with /clear`

This ensures that when the user wants to "start from scratch", all session data is cleaned up.

### Automatic rotation

| Trigger | Action |
|---------|--------|
| `init` (new session) | Deletes sessions >7 days + keeps max 5 |
| `export` to research/ | Deletes the session from /tmp |
| `/clear` (Claude Code) | Deletes ALL sessions |

### Manual commands

```bash
# View disk space used
.harmony/lib/analysis-tracker.sh disk

# Force rotation
.harmony/lib/analysis-tracker.sh rotate

# Delete a specific session
.harmony/lib/analysis-tracker.sh cleanup abc12345

# Delete ALL sessions
.harmony/lib/analysis-tracker.sh cleanup
```

### Rotation config

Local config file: `.harmony/local/session-config.json`

```json
{
    "max_sessions": 5,       // Keep max 5 sessions
    "max_age_days": 7,       // Delete sessions > 7 days
    "max_disk_mb": 50,       // Max 50MB for all sessions
    "cleanup_on_export": true // Delete from /tmp after export
}
```

Config commands:
```bash
# View the current config
.harmony/lib/analysis-tracker.sh config

# Change a value
.harmony/lib/analysis-tracker.sh config set max_sessions 10
.harmony/lib/analysis-tracker.sh config set max_disk_mb 100
```

## Configuration

Environment variables:
```bash
# Save folder (default: .harmony/local/tmp/sessions)
# Project-specific, inside the .harmony folder
export HARMONY_DIR=".harmony"

# Warning thresholds
WARNING_THRESHOLD_MESSAGES=50
WARNING_THRESHOLD_MINUTES=45
AUTO_SAVE_INTERVAL_MESSAGES=10
```

## Tests

The context persistence system is covered by unit tests (24 assertions).

### Run the tests

```bash
# All session-management tests
./tests/e2e/scripts/unit/test-session-management.sh

# Via the unified runner
./tests/e2e/scripts/unit/run-all.sh session-management

# Via test.sh (with a target project)
./tests/e2e/scripts/test.sh /path/to/project unit session-management
```

### Tests covered

| Test | Description |
|------|-------------|
| `/clear` detection | Detects `/clear`, `/clear args`, but not `clear` in text |
| `/clear` execution | Deletes all sessions and resets the tracker |
| Session tracker init | Automatic tracker creation |
| Analysis mode detection | Keyword detection (analyse, research, compare, etc.) |
| Rotation config | Creating and reading `session-config.json` |
| Session cleanup | Deleting sessions via command |
| Disk usage display | Showing disk space used |
| Session resume detection | Detecting pending sessions |
| Full lifecycle | init → track → clear |

### Prerequisites for the tests

- `jq` installed (JSON manipulation)
- Write permissions in the test directory
- Harmony framework present in the project directory (`.harmony/`)

## References

- [Official server-memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
- [mcp-memory-keeper](https://github.com/mkreyman/mcp-memory-keeper) (complementary)
