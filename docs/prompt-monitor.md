# Prompt Monitor — Activation Guide

> **🌐 Language:** English · [Français](fr/prompt-monitor.md)

> **Disabled by default.** The Prompt Monitor is an optional tool — it must be enabled explicitly.
>
> `${HARMONY_DIR}` is the Harmony install directory (default: `.harmony`).
> If you customized this path, replace `.harmony` with your value in all examples below.

## What the Prompt Monitor does

- Analyzes the clarity and quality of every prompt submitted to Claude
- Traces tool interactions (Bash, Edit, Write, Read, WebFetch...)
- Provides a web dashboard with statistics and trends
- Generates suggestions to improve your prompts over time

All data stays **local** in `${HARMONY_DIR}/local/` — nothing is sent outside.

---

## Prerequisites

```bash
pip3 install -r ${HARMONY_DIR}/tools/prompt-monitor/requirements.txt
```

---

## Activation

The Prompt Monitor hooks are isolated in a dedicated file (`settings-addon.json`) so as not to mix with the main Harmony hooks in `settings.json`.

### Step 1 — Enable the hooks

**Case A — `.claude/settings.local.json` does not exist yet:**

```bash
# Copy the dedicated file directly
cp ${HARMONY_DIR}/tools/prompt-monitor/settings-addon.json .claude/settings.local.json

# Replace ${HARMONY_DIR} with the real path
sed -i 's|\${HARMONY_DIR}|.harmony|g' .claude/settings.local.json
```

**Case B — `.claude/settings.local.json` already exists:**

> ⚠️ **Merge, do not replace.** Copying over the existing file would overwrite your configuration.
> Open `${HARMONY_DIR}/tools/prompt-monitor/settings-addon.json` and **add only the missing blocks** to your existing `.claude/settings.local.json`:
>
> - Add the `UserPromptSubmit` block if it does not already exist
> - Add the `track-interaction.sh` entry in `PostToolUse` if the `Bash|Read|Write|...` matcher is not already present
>
> Never duplicate an existing `UserPromptSubmit` or `PostToolUse` block.

Claude Code loads `.claude/settings.local.json` and automatically **merges** its hooks with those in `.claude/settings.json` — the main Harmony hooks stay intact.

### Step 2 — Start the server

```bash
# Start (port 8081 by default)
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py start

# With a custom port
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py start --port 9000

# Check status
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py status
```

### Step 3 — Open the dashboard

```
http://localhost:8081
```

---

## Contents of settings-addon.json

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash .harmony/tools/prompt-monitor/hooks/track-user-prompt.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Read|Write|Edit|Glob|Grep|Task|WebFetch|WebSearch",
        "hooks": [{
          "type": "command",
          "command": "bash .harmony/tools/prompt-monitor/hooks/track-interaction.sh"
        }]
      }
    ]
  }
}
```

---

## Available commands

```bash
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py start    # Start the server
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stop     # Stop the server
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py status   # See status and PID
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stats    # Statistics in the CLI
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py reset    # Reset the data
```

---

## Deactivation

**Case A — `.claude/settings.local.json` only contains the prompt-monitor hooks:**

```bash
rm .claude/settings.local.json
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stop
```

**Case B — `.claude/settings.local.json` contains other configurations:**

Remove only the two added blocks:
- The `UserPromptSubmit` block containing `track-user-prompt.sh`
- The `track-interaction.sh` entry in `PostToolUse`

Then stop the server:
```bash
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stop
```

---

## Data collected

| Location | Contents |
|----------|----------|
| `${HARMONY_DIR}/local/logs/` | Raw interaction logs |
| `${HARMONY_DIR}/local/metrics/` | Aggregated metrics per session |

No data leaves your machine.
