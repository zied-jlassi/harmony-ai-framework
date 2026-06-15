# Quick Start

> **🌐 Language:** English · [Français](fr/QUICK-START.md)

> Get Harmony running in 2 minutes.

## 1. Install (30 sec)

```bash
# Requires jq + yq — run from your project root
npx harmony-ai --full
```

## 2. Configure MCP Servers (1 min)

Add to your AI assistant config (Claude Desktop, Cursor, VS Code):

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]
    }
  }
}
```

## 3. Start Working (30 sec)

Open your AI assistant and talk naturally:

```
"analyze requirements for user authentication"  → Analyst
"design the auth architecture"                  → Architect
"create stories for login feature"              → Scrum Master
"implement STORY-001"                           → Developer
```

Harmony routes automatically to the right agent.

## Verify Installation

```bash
# Framework tree + hooks present
ls .harmony/agents .harmony/hooks .harmony/local/memory
cat .claude/settings.json

# Then, inside your AI assistant:
/go            # Session kickoff — loads context and reports state
```

---

## What Just Happened?

Harmony installed 3 systems:

| System | Purpose |
|--------|---------|
| **Guardian** | Routes your requests to the right agent |
| **Sentinel** | Remembers errors, prevents repetition |
| **HQVF** | Ensures quality via verifiable use cases |

---

## Next Steps

- [Getting Started](getting-started.md) - Full walkthrough
- [Core Concepts](concepts.md) - Understand the architecture
- [Commands](../commands/index.md) - All 30+ commands

---

**Need help?** Run `/harmony` inside your assistant or [open an issue](https://github.com/zied-jlassi/harmony-ai-framework/issues)
