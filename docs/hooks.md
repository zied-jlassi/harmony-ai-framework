# Hooks Reference

> **🌐 Language:** English · [Français](fr/hooks.md)

Harmony runs as a set of **hooks** — small, fast scripts the IDE invokes around
your actions. They route context, guard against dangerous operations, learn from
errors, and — importantly — **tell you when they fire**.

> `${HARMONY_DIR}` = Harmony install directory (default: `.harmony`).
> Hooks live in `${HARMONY_DIR}/hooks/`, wired in `.claude/settings.json`.

---

## The hook contract (Claude Code)

Every Harmony hook follows the current Claude Code contract — no positional args,
no `$TOOL_INPUT` env interpolation:

| Aspect | Behaviour |
|--------|-----------|
| **Input** | JSON on **stdin** — `tool_name`, `tool_input`, `tool_response` (PostToolUse) |
| **Block** | **`exit 2`** + reason on **stderr** (surfaced to the assistant) |
| **Pass** | `exit 0`; a JSON `{"systemMessage": "…"}` on stdout is shown to *you* |
| **Spinner** | `statusMessage` in `settings.json` is shown while the hook runs |

This is what makes Harmony **observable**: a non-blocking hook's plain stdout is
hidden by the IDE, so each guard emits a `systemMessage` as visible proof it ran.

```
🛡️ Rules: clean — no interdiction (Bash)
🧠 Sentinel: circuit CLOSED (0/3 failures)
📦 Supply-chain: clean — install screened
```

Helper library: `lib/hook-ui.sh` (`hook_status`, `hook_debug`, `hook_block`).
Silence all visible status with `HARMONY_HOOK_UI=off` (debug still goes to stderr).

---

## Hooks wired by `--full` (active by default)

`npx harmony-ai --full` writes these seven into `.claude/settings.json`:

| Order | Hook | Event (matcher) | Role | Blocks? |
|:-----:|------|-----------------|------|:-------:|
| 1 | **rules-enforcer** | PreToolUse · `Edit\|Write\|Bash` | Block destructive commands (`rm -rf /`, `DROP DATABASE`, fork bombs), shell injection (`curl \| bash`), secrets in files | ✅ |
| 2 | **guardian-checkpoint** | PreToolUse · `Edit\|Write\|Bash` | Enforce story-based development (strict mode) | ✅ (strict) |
| 3 | **sentinel-pre** | PreToolUse · `Edit\|Write\|Bash` | Check error history; block when circuit breaker is OPEN; print circuit status | ✅ (OPEN) |
| 4 | **aria-detect** | PreToolUse · `Edit\|Write` | Detect accessibility/context flags on edits | — |
| 5 | **supply-chain-guard** | PreToolUse · `Bash` | Screen package installs (typosquats, audits, unpinned MCP, cooling period) | ✅ |
| 6 | **sentinel-post** | PostToolUse · `Edit\|Write\|Bash` | Record result, update circuit breaker, learn patterns | — |
| 7 | **llm-output-sanitizer** | PostToolUse · `Bash\|WebFetch\|WebSearch` | Sanitize external content entering context (injection, exfiltration, hidden Unicode) | — |

`rules-enforcer` runs **first** — interdictions before anything else.

> Install without hooks: `npx harmony-ai --full --no-hooks`. Re-enable later by
> re-running `npx harmony-ai --full --force`, or edit `.claude/settings.json`
> (the exact block is in [installation.md](installation.md#for-claude-code)).

### What each one shows you

| Hook | Visible status on pass | On block |
|------|------------------------|----------|
| rules-enforcer | `🛡️ Rules: clean — no interdiction (<tool>)` | red block + the matched pattern (stderr) |
| guardian-checkpoint | `🛡️ Guardian: story <id> active` / `⚠️ no active story` | violation reason (stderr) |
| sentinel-pre | `🧠 Sentinel: circuit <state> (<n>/3 failures)` | circuit-OPEN warning (stderr) |
| supply-chain-guard | `📦 Supply-chain: clean — install screened` | `[SCG-BLOCK]` + reason (stderr) |

---

## Additional hooks (opt-in, not wired by `--full`)

These ship with the framework but are **not** added to `settings.json` by default.
Enable them by adding an entry to `.claude/settings.json` (or via the relevant
toolkit). They are session/analysis-lifecycle helpers, not security guards.

| Hook | Purpose | Typical event |
|------|---------|---------------|
| **token-monitor** | Track estimated token usage per session (cross-platform) | PostToolUse / periodic |
| **compacting-warning** | Warn before a context compaction so you can save research/insights | Pre-compaction |
| **session-resume** | Detect a pending analysis session at startup and offer to resume | SessionStart / first prompt |
| **profile-loader** | Load profile sections conditionally by detected intent (team > framework override) | Invoked by the context system |

> See [Overrides](overrides.md) for the 2-level override model (local/team >
> framework) that `profile-loader` and the guards rely on.

---

## Customizing & disabling

| Goal | How |
|------|-----|
| Silence visible status (keep guards active) | `export HARMONY_HOOK_UI=off` |
| Disable supply-chain + sanitizer instantly | `export HARMONY_GUARDS=off` |
| Switch a guard to warn-only | `/hf:security:guards mode supply-chain warn` |
| Debug a hook's decision | `HARMONY_HOOK_DEBUG=1` then pipe JSON to it (see [overrides.md](overrides.md)) |
| Add project-specific rules / exceptions | `.harmony/config.yaml` → see [Overrides](overrides.md) |
| Full env-var reference | [Configuration](configuration.md) |

### Manual invocation (debugging)

Hooks read JSON on stdin — invoke them the way the IDE does:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"npm install lodash"}}' \
  | bash .harmony/hooks/supply-chain-guard.sh
```

---

## Related

- [Security Guards](security-guards.md) — the protection layer in depth
- [Configuration](configuration.md) — every `HARMONY_*` knob and config file
- [How It Works](how-it-works.md#observable-by-design) — Observable by design
- [Installation](installation.md#for-claude-code) — the exact `settings.json` block
