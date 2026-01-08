# Harmony Framework - Override System

> **Customize Harmony for your project without modifying framework files.**

---

## Why Overrides?

When you update the Harmony framework, your customizations would be lost if you modified the framework files directly. The override system solves this:

| Approach | Framework Updates | Team Sharing | Recommended |
|----------|-------------------|--------------|-------------|
| Modify `.harmony/` files | ❌ Overwritten | ❌ Conflicts | ❌ No |
| Use `.harmony/local/` | ✅ Preserved | ⚠️ Per-dev | ✅ Personal |
| Use `.harmony/config/overrides.yaml` | ✅ Preserved | ✅ Shared | ✅ Team |

---

## Directory Structure

```
.harmony/                        # FRAMEWORK (don't modify)
├── hooks/                       # Framework hooks
├── agents/                      # Framework agents
├── rules/                       # Framework rules
├── patterns/                    # Framework patterns
├── templates/                   # Framework templates
├── lib/                         # Framework libraries
│   └── config-loader.sh         # Configuration loader
└── config/
    └── overrides.yaml           # PROJECT OVERRIDES (shared)

.harmony/local/                  # LOCAL OVERRIDES (gitignore-able)
├── hooks/                       # Override hooks
├── agents/                      # Override agents
├── rules/                       # Additional rules
├── patterns/                    # Additional patterns
├── templates/                   # Override templates
└── config/
    └── overrides.yaml           # Local-only config (mirrors team structure)
```

---

## Resolution Order

For any component, Harmony checks in this order:

```
1. .harmony/local/config/overrides.yaml  → Highest priority (personal)
2. .harmony/config/overrides.yaml        → Team config (shared)
3. .harmony/{component}                  → Framework default
```

For component overrides (hooks, agents, etc.):
```
1. .harmony/local/{component}          → Personal override
2. .harmony/{component}                → Framework default
```

---

## Configuration File

### Location: `.harmony/config/overrides.yaml`

This file is the primary way to customize Harmony for your project.

### Example Configuration

```yaml
# Project context
project:
  name: "my-awesome-app"
  container_prefix: "myapp"
  language: "fr"

# Docker environment
docker:
  required: true                 # Block local npm/yarn
  container_prefix: "myapp"      # Used in suggestions

# Rules Enforcer customization
rules_enforcer:
  # Add project-specific dangerous patterns
  add_dangerous_patterns:
    - 'DROP.*myapp_production'
    - 'rm -rf /data/myapp'

  # Disable framework patterns (use with caution!)
  disable_patterns:
    - 'prisma migrate reset'     # We allow this in dev

  # Add warning patterns
  add_warning_patterns:
    - 'chmod.*myapp'

  # Add Docker exceptions
  add_allowed_patterns:
    - 'docker exec myapp-backend npm'
    - 'docker exec myapp-frontend yarn'

  # Add secrets patterns
  add_secrets_patterns:
    - '\.myapp-secrets$'
    - 'MYAPP_API_KEY='

# Guardian customization
guardian:
  enabled: true
  mode: "warn"                   # "warn" | "block"
  add_allowed_directories:
    - "scripts/"
    - "tools/"
  add_allowed_extensions:
    - ".sql"

# Sentinel customization
sentinel:
  enabled: true
  circuit_breaker:
    max_failures: 5              # Override default 3

# Agents customization
agents:
  disabled:
    - "pentest"                  # Don't use in this project
  aliases:
    "dev": "game-developer"      # Custom alias

# Hooks customization
hooks:
  disabled_hooks:
    - "guardian-checkpoint"      # Skip story check
  additional_pre_hooks:
    - ".harmony/local/hooks/my-check.sh"
```

---

## Override Examples

### 1. Override a Hook Completely

Create a file at `.harmony/local/hooks/rules-enforcer.sh`:

```bash
#!/bin/bash
# My custom rules enforcer
# This REPLACES the framework hook entirely

echo "Custom rules enforcer running..."

# Your custom logic here
exit 0
```

### 2. Extend a Hook

Create `.harmony/local/hooks/rules-enforcer-ext.sh` and reference it in config:

```yaml
# .harmony/config/overrides.yaml
hooks:
  additional_pre_hooks:
    - ".harmony/local/hooks/rules-enforcer-ext.sh"
```

### 3. Override an Agent

Create `.harmony/local/agents/developer.md`:

```markdown
# Custom Developer Agent

This is my project's developer agent with custom rules...
```

### 4. Add Project-Specific Rules

Create `.harmony/local/rules/my-project-rules.yaml`:

```yaml
rules:
  - id: MYAPP-001
    name: "No direct database access"
    pattern: "pg_connect|mysql_connect"
    action: block
    message: "Use the ORM instead of direct database connections"
```

---

## Backward Compatibility

The override system is designed for backward compatibility:

### For Hooks

```bash
# In any hook, this pattern ensures backward compatibility:

# Source config loader if available
if [[ -f "${HARMONY_DIR}/lib/config-loader.sh" ]]; then
    source "${HARMONY_DIR}/lib/config-loader.sh"
else
    # Fallback functions (for old framework versions)
    get_config() { echo "${2:-}"; }
    get_config_bool() { [[ "${2:-false}" == "true" ]]; }
    get_config_array() { echo ""; }
fi

# Now use get_config with fallbacks
docker_required=$(get_config "docker.required" "false")
```

### For Configuration

Missing keys always have sensible defaults:

```bash
# These never fail, they return the default if key is missing
get_config "docker.required" "false"          # → "false" if not set
get_config "project.name" "unknown"           # → "unknown" if not set
get_config_array "rules.add_patterns"         # → empty if not set
```

---

## Version Migration

When the framework updates, your config is preserved. If new keys are added:

```yaml
# Old config (still works)
docker:
  required: true

# New framework version adds sentinel.auto_learn
# Your config still works - it uses the default value
```

### Deprecation Warnings

If you use deprecated keys, you'll see warnings:

```
⚠️  Deprecated: 'docker_required' → use 'docker.required' instead
```

### Migration Command

```bash
npx harmony migrate
```

This updates your config to use new key names while preserving values.

---

## Gitignore Recommendations

```gitignore
# .gitignore

# Local overrides (personal dev preferences)
.harmony/local/
.harmony-local/

# Memory files (IDE-specific locations)
.claude/memory/*.json          # Claude Code
.cursor/harmony-memory/*.json  # Cursor
.windsurf/harmony-memory/*.json # Windsurf

# Security logs
.claude/memory/.security.log

# KEEP in git:
# .harmony/config/overrides.yaml  (team configuration)
```

---

## API Reference

### Config Loader Functions

```bash
# Source the loader
source ".harmony/lib/config-loader.sh"

# Get a string value with fallback
value=$(get_config "key.subkey" "default")

# Get a boolean with fallback
if get_config_bool "feature.enabled" false; then
    echo "Feature is enabled"
fi

# Get an array as newline-separated values
while IFS= read -r item; do
    echo "Item: $item"
done < <(get_config_array "list.items")

# Check if key exists
if has_config "optional.key"; then
    echo "Key exists"
fi

# Resolve hook/agent/template with override check
hook_path=$(resolve_hook "rules-enforcer")
agent_path=$(resolve_agent "developer")
template_path=$(resolve_template "story")

# Check if hook is disabled
if is_hook_disabled "guardian-checkpoint"; then
    exit 0
fi
```

---

## Best Practices

1. **Use `overrides.yaml` for team settings** - Commit to git
2. **Use `local/` for personal preferences** - Add to `.gitignore`
3. **Never modify `.harmony/` files** - They'll be overwritten
4. **Always provide fallbacks** - For backward compatibility
5. **Test after framework updates** - Run `npx harmony doctor`

---

## Troubleshooting

### Config not loading?

```bash
# Check if config loader exists
ls -la .harmony/lib/config-loader.sh

# Test config loading
source .harmony/lib/config-loader.sh
get_config "docker.required" "not-found"
```

### Hook not using overrides?

```bash
# Enable debug mode
HARMONY_HOOK_DEBUG=1 .harmony/hooks/rules-enforcer.sh Bash '{"command":"npm install"}'
```

### Local override not taking effect?

```bash
# Check file exists and is executable
ls -la .harmony/local/hooks/

# Check resolution
source .harmony/lib/config-loader.sh
resolve_hook "rules-enforcer"
```

---

## Related

- [Installation Guide](installation.md)
- [Configuration Reference](configuration.md)
- [Hooks Documentation](hooks.md)
