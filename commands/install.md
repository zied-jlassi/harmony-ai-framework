# Harmony Install - IDE Deployment

> Deploy Harmony to your favorite IDE or LLM tool.

---

## Supported IDEs

| IDE | Support Level | Features |
|-----|---------------|----------|
| **Claude Code** | Full | Hooks, Memory, MCP, Skills |
| **Cursor** | Good | Rules (.mdc), Personas |
| **Windsurf** | Good | Rules (.windsurfrules) |
| **Continue** | Good | Assistants (YAML), Context |
| **Cody** | Partial | Prompts (MD) |

---

## Commands

### Install to IDE

```bash
harmony install cursor
harmony install windsurf
harmony install continue
harmony install cody
```

### Show Status

```bash
harmony install --status
```

---

## What Gets Installed

### Claude Code (Full)

```
.claude/
├── commands/harmony.md       # Slash command
├── hooks/
│   ├── harmony-sentinel.sh   # Error memory
│   └── guardian-checkpoint.sh # Story enforcement
├── memory/
│   ├── error-journal.json
│   ├── circuit-breaker.json
│   └── workflow-state.json
└── settings.local.json       # Hooks config
```

### Cursor

```
.cursor/rules/
├── harmony-core.mdc          # Base rules
├── harmony-guardian.mdc      # Intent routing
└── harmony-agents.mdc        # Agent personas
```

### Windsurf

```
.windsurf/
└── harmony.windsurfrules     # Combined rules
```

### Continue

```
.continue/
├── config.yaml               # Main config
└── assistants/
    ├── harmony-developer.yaml
    ├── harmony-tester.yaml
    └── harmony-analyst.yaml
```

### Cody

```
.cody/prompts/
├── harmony-developer.md
├── harmony-tester.md
├── harmony-analyst.md
└── harmony-guardian.md
```

---

## Feature Mapping

| Harmony Feature | Claude Code | Cursor | Windsurf | Continue |
|-----------------|:-----------:|:------:|:--------:|:--------:|
| Guardian | hooks | .mdc rules | rules | yaml rules |
| Sentinel | memory + hooks | N/A | N/A | N/A |
| HQVF | CLAUDE.md | .mdc rules | rules | yaml rules |
| Agents | Skills | Rule personas | Instructions | Assistants |
| Profiles | JIT loading | Glob matching | N/A | Context |

---

## Post-Installation

After running `harmony install <ide>`:

1. Restart your IDE
2. Open a project with Harmony installed
3. Test with a simple command:
   - Claude Code: `/harmony status`
   - Cursor: Type "Harmony status"
   - Windsurf: Ask for framework status
   - Continue: Select Harmony assistant

---

## See Also

- [Architecture](../docs/architecture.md) - Integration details
- [Getting Started](../docs/getting-started.md) - First steps
