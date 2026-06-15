# Harmony Framework - Système de Surcharges

> **🌐 Langue :** [English](../overrides.md) · Français

> **Personnalisez Harmony pour votre projet sans modifier les fichiers du framework.**

---

## Pourquoi des surcharges ?

Quand vous mettez à jour le framework Harmony, vos personnalisations seraient perdues si vous modifiiez directement les fichiers du framework. Le système de surcharges résout cela :

| Approche | Mises à jour du framework | Partage d'équipe | Recommandé |
|----------|---------------------------|------------------|------------|
| Modifier les fichiers `.harmony/` | ❌ Écrasés | ❌ Conflits | ❌ Non |
| Utiliser `.harmony/local/` | ✅ Préservé | ⚠️ Par dev | ✅ Personnel |
| Utiliser `.harmony/config/overrides.yaml` | ✅ Préservé | ✅ Partagé | ✅ Équipe |

---

## Structure des Répertoires

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

## Ordre de Résolution

Pour tout composant, Harmony vérifie dans cet ordre :

```
1. .harmony/local/config/overrides.yaml  → Highest priority (personal)
2. .harmony/config/overrides.yaml        → Team config (shared)
3. .harmony/{component}                  → Framework default
```

Pour les surcharges de composants (hooks, agents, etc.) :
```
1. .harmony/local/{component}          → Personal override
2. .harmony/{component}                → Framework default
```

---

## Fichier de Configuration

### Emplacement : `.harmony/config/overrides.yaml`

Ce fichier est le moyen principal de personnaliser Harmony pour votre projet.

### Exemple de configuration

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

## Exemples de Surcharges

### 1. Surcharger complètement un hook

Créez un fichier à `.harmony/local/hooks/rules-enforcer.sh` :

```bash
#!/bin/bash
# My custom rules enforcer
# This REPLACES the framework hook entirely

echo "Custom rules enforcer running..."

# Your custom logic here
exit 0
```

### 2. Étendre un hook

Créez `.harmony/local/hooks/rules-enforcer-ext.sh` et référencez-le dans la config :

```yaml
# .harmony/config/overrides.yaml
hooks:
  additional_pre_hooks:
    - ".harmony/local/hooks/rules-enforcer-ext.sh"
```

### 3. Surcharger un agent

Créez `.harmony/local/agents/developer.md` :

```markdown
# Custom Developer Agent

This is my project's developer agent with custom rules...
```

### 4. Ajouter des règles spécifiques au projet

Créez `.harmony/local/rules/my-project-rules.yaml` :

```yaml
rules:
  - id: MYAPP-001
    name: "No direct database access"
    pattern: "pg_connect|mysql_connect"
    action: block
    message: "Use the ORM instead of direct database connections"
```

---

## Compatibilité Ascendante

Le système de surcharges est conçu pour la compatibilité ascendante :

### Pour les hooks

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

### Pour la configuration

Les clés manquantes ont toujours des défauts raisonnables :

```bash
# These never fail, they return the default if key is missing
get_config "docker.required" "false"          # → "false" if not set
get_config "project.name" "unknown"           # → "unknown" if not set
get_config_array "rules.add_patterns"         # → empty if not set
```

---

## Migration de Version

Quand le framework se met à jour, votre config est préservée. Si de nouvelles clés sont ajoutées :

```yaml
# Old config (still works)
docker:
  required: true

# New framework version adds sentinel.auto_learn
# Your config still works - it uses the default value
```

### Avertissements de dépréciation

Si vous utilisez des clés dépréciées, vous verrez des avertissements :

```
⚠️  Deprecated: 'docker_required' → use 'docker.required' instead
```

### Commande de migration

```bash
npx harmony migrate
```

Cela met à jour votre config pour utiliser les nouveaux noms de clés tout en préservant les valeurs.

---

## Recommandations Gitignore

```gitignore
# .gitignore

# Local overrides (personal dev preferences)
.harmony/local/
.harmony-local/

# Memory files (IDE-specific locations)
.harmony/local/memory/*.json          # Claude Code
.cursor/harmony-memory/*.json  # Cursor
.windsurf/harmony-memory/*.json # Windsurf

# Security logs
.harmony/local/memory/.security.log

# KEEP in git:
# .harmony/config/overrides.yaml  (team configuration)
```

---

## Référence API

### Fonctions du Config Loader

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

## Bonnes Pratiques

1. **Utilisez `overrides.yaml` pour les réglages d'équipe** - Committez dans git
2. **Utilisez `local/` pour les préférences personnelles** - Ajoutez à `.gitignore`
3. **Ne modifiez jamais les fichiers `.harmony/`** - Ils seront écrasés
4. **Fournissez toujours des fallbacks** - Pour la compatibilité ascendante
5. **Testez après les mises à jour du framework** - Lancez `/harmony quick` dans votre assistant

---

## Dépannage

### La config ne se charge pas ?

```bash
# Check if config loader exists
ls -la .harmony/lib/config-loader.sh

# Test config loading
source .harmony/lib/config-loader.sh
get_config "docker.required" "not-found"
```

### Un hook n'utilise pas les surcharges ?

```bash
# Enable debug mode (hook reads Claude Code JSON on stdin)
echo '{"tool_name":"Bash","tool_input":{"command":"npm install"}}' \
  | HARMONY_HOOK_DEBUG=1 .harmony/hooks/rules-enforcer.sh
```

### Une surcharge locale ne prend pas effet ?

```bash
# Check file exists and is executable
ls -la .harmony/local/hooks/

# Check resolution
source .harmony/lib/config-loader.sh
resolve_hook "rules-enforcer"
```

---

## Liens connexes

- [Installation Guide](installation.md)
- [Natural Language Config](natural-language-config.md)
