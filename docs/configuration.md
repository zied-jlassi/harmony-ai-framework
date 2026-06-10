# Configuration Reference

> **🌐 Language:** English · [Français](fr/configuration.md)

Everything you can tune in Harmony, in one place: environment variables (instant,
per-shell or CI overrides) and configuration files (persistent state).

> `${HARMONY_DIR}` = Harmony install directory (default: `.harmony`).

---

## Resolution order

For any setting, the most specific source wins:

```
environment variable   →   project config file   →   framework default
   (instant, per-shell)      (persistent)              (built-in)
```

So `HARMONY_GUARDS=off` always wins over `security-guards.json`, which wins over
the built-in "enabled" default.

---

## Environment variables

### Core

| Variable | Default | Effect |
|----------|---------|--------|
| `HARMONY_DIR` | `.harmony` | Install directory (where the framework lives) |
| `HARMONY_MEMORY_DIR` | `${HARMONY_DIR}/local/memory` | Mutable project memory location |
| `HARMONY_NO_AUTOLOAD` | `0` | `1` disables automatic context autoload |

### Hooks & security guards

| Variable | Default | Effect |
|----------|---------|--------|
| `HARMONY_HOOK_UI` | `on` | `off` silences the visible `systemMessage` status (guards still run) |
| `HARMONY_GUARDS` | *(enabled)* | `off` disables supply-chain + LLM sanitizer instantly (zero perf impact) |
| `HARMONY_HOOK_DEBUG` | `0` | `1` prints a hook's decision trace to stderr |
| `HARMONY_SANITIZER_MODE` | `external-only` | `strict` also scans `Read` + runs Semgrep |
| `HARMONY_PKG_COOLING_DAYS` | `14` | Quarantine threshold — warn on packages published more recently |

→ See [Hooks](hooks.md) and [Security Guards](security-guards.md).

### Intent routing & models (RouteLLM)

| Variable | Default | Effect |
|----------|---------|--------|
| `HARMONY_ROUTER_MODE` | `auto` | Force the router path: `auto` \| `claude-code` \| `api` \| `pattern` |
| `HARMONY_MAIN_MODEL` | *(config)* | Override the strong/tier-1 model alias |
| `HARMONY_WEAK_MODEL` | *(config)* | Override the light/router model alias |
| `HARMONY_EDITOR_MODEL` | *(config)* | Override the model used for edits |

**Path priority** (`auto`): `CLAUDECODE=1` → native Task tool (**no API key**) →
API key if present → deterministic pattern fallback. The classifier model comes
from config (`router_model`), never hardcoded. → See [How It Works](how-it-works.md).

#### Provider API keys (CLI / standalone only)

Only needed **outside** Claude Code (the native path needs no key). The first key
present selects the provider:

| Variable | Provider |
|----------|----------|
| `ANTHROPIC_API_KEY` | Anthropic (Claude) |
| `OPENAI_API_KEY` | OpenAI |
| `GROQ_API_KEY` | Groq |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI |
| `MISTRAL_API_KEY` | Mistral |

### Auto-linter

| Variable | Default | Effect |
|----------|---------|--------|
| `HARMONY_LINT_AUTO_FIX` | `false` | `true` auto-applies safe lint fixes |
| `HARMONY_LINT_STRICT` | `false` | `true` treats lint warnings as errors |
| `HARMONY_LINT_IGNORE_PATTERNS` | `node_modules,vendor,.git,dist,build` | Comma-separated paths to skip |

→ See [Assistant Toolkit](assistant-toolkit.md).

### Prompt Monitor (optional)

| Variable | Default | Effect |
|----------|---------|--------|
| `HARMONY_MONITOR_PORT` | `8080` | Local dashboard port |
| `HARMONY_MONITOR_URL` | `http://localhost:8080` | Endpoint the tracking hook posts to |

→ See [Prompt Monitor](prompt-monitor.md).

---

## Configuration files

| File | Scope | Controls |
|------|-------|----------|
| `.claude/settings.json` | IDE | Wired hooks (PreToolUse / PostToolUse) + `statusMessage` |
| `${HARMONY_DIR}/local/security-guards.json` | Project | Guard `enabled` + `mode` (block/warn, external-only/strict) |
| `${HARMONY_DIR}/config/routing-rules.yaml` | Framework | `router_model`, `classification_prompt`, auto-detection triggers |
| `${HARMONY_DIR}/config/model-tiers.yaml` | Framework | Per-provider model mapping (tier1/tier2/tier3/router) |
| `${HARMONY_DIR}/config.yaml` | Project override | e.g. `llm.router.model` — overrides the framework router model |
| `${HARMONY_DIR}/local/memory/*.json` | Project (mutable) | workflow-state, circuit-breaker, error-journal, working, learned-patterns |

> Project overrides live in `local/` and survive reinstalls; the framework core
> is read-only and replaced on update. → See [Memory Architecture](memory-architecture.md).

### Example: pick a different router model

```yaml
# .harmony/config.yaml
llm:
  router:
    model: "sonnet"   # default is "haiku" (from routing-rules.yaml)
```

Or framework-wide:

```yaml
# .harmony/config/routing-rules.yaml
auto_detection:
  router_model: "sonnet"
```

---

## Related

- [Hooks](hooks.md) — the hook system and contract
- [Security Guards](security-guards.md) — protection layer
- [How It Works](how-it-works.md) — routing & observability
- [Overrides](overrides.md) — project-level customization model
