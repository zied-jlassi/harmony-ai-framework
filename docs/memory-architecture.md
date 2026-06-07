# Memory Architecture — Two Zones

> **One rule to remember:** mutable state lives in **`.harmony/local/`**. Everything else under `.harmony/` is **read-only framework base** and is overwritten on every update.
>
> Decision record: **ADR-010**. Sprint/backlog specifics: [working-memory.md](working-memory.md).

Harmony writes two very different kinds of files. Keeping them apart is what lets you **update the framework without losing your work**.

## The two zones

```
.harmony/
├── agents/  lib/  patterns/  rules/  hooks/   ← BASE — framework code
├── templates/memory/*.template.json           ← BASE — seed templates (source)
├── docs/                                       ← BASE — framework docs
│   ↑ READ-ONLY · regenerated/overwritten on every install & update
│
└── local/                                      ← USER ZONE — yours, never overwritten
    ├── memory/        ← all mutable state (see below)
    ├── backlog/       ← stories, epics
    └── docs/          ← your briefs, PRDs, architecture
```

| | Base (`.harmony/…`) | User zone (`.harmony/local/…`) |
|---|---|---|
| Contains | framework code, templates, docs | runtime state, your docs, overrides |
| Lifecycle | overwritten on update | preserved on update |
| You edit it? | no (regenerated) | yes (it's your data) |

## What lives in `local/memory/`

Every piece of mutable state — created on demand or seeded at install:

| File | Written by | Purpose |
|------|-----------|---------|
| `working.json` | sprint tracker, agents | current sprint/story state |
| `circuit-breaker.json` | Sentinel | failure tracking |
| `error-journal.json` | Sentinel | learned errors |
| `learned-patterns.json` | Sentinel | extracted patterns |
| `workflow-state.json` | Guardian/ARIA | phase, context flags |
| `*-patterns.json`, `reviews.json`, `vulnerabilities.json`, … | agents | per-agent learnings |

> There is **no** `.harmony/memory/` (base). Any path you see written as `${HARMONY_DIR}/local/memory/...` is correct; a bare `${HARMONY_DIR}/memory/...` is a bug.

## Security logs live in `local/logs/security/` (not `memory/`)

Logs are append-only events, not state — they go under `local/logs/`, in **two files** by threat layer (ADR-010):

| File | Layer | Written by | Examples |
|------|-------|-----------|----------|
| `local/logs/security/security.log` | **App / workstation** | `rules-enforcer.sh`, `supply-chain-guard.sh` | dangerous shell commands, shell-injection combos (`base64 -d \| bash`, `eval $(curl)`), secrets in files, `[SUPPLY]` typosquats |
| `local/logs/security/llm-security.log` | **LLM** | `llm-output-sanitizer.sh`, `data-sandbox.sh` (mirror) | prompt-injection/jailbreak artifacts, exfiltration URLs, unicode steganography, untrusted-input validation failures |

Both are **auto-created on first detection** (`mkdir -p`); they do not need seeding. `data-sandbox.sh` also keeps a structured `local/memory/sandbox-log.json` (schema-backed) and mirrors a human-readable line into `llm-security.log`.

## How files are created & updated (why updates are safe)

1. **Source of truth** = `templates/memory/*.template.json` (shipped, read-only).
2. At install, `initialize_memory()` runs `merge_memory_file()` per file:
   - **file absent** (fresh install) → created from the template (clean state);
   - **file present** (re-install / update) → **additive merge**: *your existing values win*, new template keys are added.
3. On reinstall, if `local/memory/` already holds data, the whole `local/` zone is preserved (ADR-007).

Net effect: a new framework version can add fields or files **without erasing** anything you have.

```
templates/memory/working.template.json   (source, read-only)
        │  install → merge ("existing values win")
        ▼
local/memory/working.json                 (your state, survives updates)
```

## Golden rules

1. **Never** read or write memory under the base `.harmony/memory/` — it does not exist. Use `.harmony/local/memory/`.
2. Agent instruction files (`.md`) are code: their memory paths must point to `local/memory/`.
3. To add a new memory file, ship a `templates/memory/<name>.template.json` and seed it via `initialize_memory()`.
4. Never commit runtime state into the package (`framework/memory/` is not a seed source).

## Protection (test)

`tests/e2e/scripts/scenarios/test-scenario-memory-install.sh` runs a **real fresh install** and an **agent simulation**. It asserts: `local/memory/` seeded clean, seeds are vierge (empty history, no leaked dev data), the base carries no state, **every agent memory reference resolves under `local/memory/`**, and user data survives reinstall. It must stay green.

```bash
./tests/e2e/scripts/test.sh /tmp/anything scenario memory-install
```

## See also

- [working-memory.md](working-memory.md) — sprint/backlog working-memory details
- [context-persistence.md](context-persistence.md) — cross-session context
- ADR-010 (research/) — the architecture decision and the issues it fixed
