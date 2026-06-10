# Assistant Toolkit

> **🌐 Langue :** [English](../assistant-toolkit.md) · Français

L'Assistant Toolkit fournit une collection de modules pour un développement assisté par IA amélioré. Ces modules enrichissent le Harmony Framework avec la gestion des modèles, le linting automatique, la cartographie de dépôt, la surveillance de fichiers et la gestion de l'historique de session.

## Vue d'ensemble

| Module | Fichier | Rôle |
|--------|------|---------|
| Model Manager | `model-manager.sh` | Alias de modèles, paliers (tiers) et estimation des coûts |
| Auto Linter | `auto-linter.sh` | Détection de langage et linting automatique |
| Repomap | `repomap.sh` | Structure et analyse du dépôt |
| File Watcher | `file-watcher.sh` | Détection des changements de fichiers et hooks |
| History Summarizer | `history-summarizer.sh` | Historique de session et compression du contexte |
| Toolkit Orchestrator | `assistant-toolkit.sh` | Interface unifiée pour tous les modules |

## Démarrage rapide

```bash
# Source the unified toolkit
source .harmony/lib/assistant-toolkit.sh

# Initialize all modules
assistant_init .

# Show status
assistant_status

# Run workflow on a file
assistant_workflow src/index.ts --fix
```

## Model Manager

Fournit l'aliasing de modèles, la classification par palier et l'estimation des coûts pour les workflows IA multi-modèles.

### Alias de modèles

| Alias | Nom complet du modèle |
|-------|-----------------|
| `sonnet` | anthropic/claude-sonnet-4 |
| `opus` | anthropic/claude-opus-4 |
| `haiku` | anthropic/claude-3-5-haiku |
| `gpt4` | openai/gpt-4 |
| `gpt4o` | openai/gpt-4o |
| `deepseek` | deepseek/deepseek-chat |
| `deepseek-r1` | deepseek/deepseek-reasoner |

### Paliers de modèles (tiers)

- **Main** : Coûteux, le plus capable (opus, gpt-4, o1)
- **Editor** : Équilibré pour l'édition de code (sonnet, gpt-4o)
- **Weak** : Bon marché, pour les tâches simples (haiku, deepseek-chat)

### Fonctions

```bash
# Resolve alias to full model name
resolve_model "sonnet"
# -> anthropic/claude-sonnet-4

# Get model tier
get_model_tier "haiku"
# -> weak

# Get model for task type
get_model_for_task "edit"       # -> editor model
get_model_for_task "architect"  # -> main model
get_model_for_task "summarize"  # -> weak model

# Estimate cost (model, input_tokens, output_tokens)
estimate_model_cost "sonnet" 1000 500
# -> 0.0105

# List all models
list_models --all
```

### Variables d'environnement

```bash
export HARMONY_MAIN_MODEL="anthropic/claude-opus-4"
export HARMONY_WEAK_MODEL="anthropic/claude-3-5-haiku"
export HARMONY_EDITOR_MODEL="anthropic/claude-sonnet-4"
```

## Auto Linter

Détection automatique de langage et linting avec prise en charge de plusieurs langages et linters.

### Langages pris en charge

| Langage | Linter par défaut | Alternatives |
|----------|----------------|--------------|
| TypeScript/JavaScript | eslint | jshint, standard |
| Python | ruff | flake8, pylint |
| Bash | shellcheck | - |
| Go | golangci-lint | - |
| Rust | cargo clippy | - |
| Ruby | rubocop | - |
| CSS/SCSS | stylelint | - |
| JSON | jsonlint | - |
| YAML | yamllint | - |

### Fonctions

```bash
# Detect file language
detect_language "src/app.ts"
# -> typescript

# Run lint check on file
run_lint_check "src/app.ts"
run_lint_check "src/app.ts" --fix  # with auto-fix

# Lint multiple files
lint_files --fix src/*.ts

# Lint git staged files
lint_staged_files --fix

# Lint changed files (unstaged)
lint_changed_files --fix

# List available linters
list_available_linters
```

### Variables d'environnement

```bash
export HARMONY_LINT_AUTO_FIX="true"
export HARMONY_LINT_STRICT="true"
export HARMONY_LINT_IGNORE_PATTERNS="node_modules,vendor,.git,dist"
```

## Repomap

Analyse et cartographie de la structure du dépôt pour la génération de contexte IA.

### Fonctions

```bash
# Generate complete repository map
generate_repomap .              # text format
generate_repomap . json         # JSON format
generate_repomap . markdown     # Markdown format

# Get file tree
get_file_tree . 3               # depth of 3

# Find key files (README, package.json, etc.)
find_key_files .

# Find entry points
find_entry_points .

# Get file summary
get_file_summary "src/index.ts"

# Extract symbols from file
get_symbols "src/app.ts"
# -> ["App", "handleClick", "fetchData"]

# Analyze dependencies
analyze_dependencies .

# Cache repomap for performance
cache_repomap .
get_cached_repomap . 3600       # max age in seconds
```

### Motifs de fichiers clés

Détectés automatiquement :
- README, CHANGELOG, CONTRIBUTING
- package.json, Cargo.toml, go.mod, requirements.txt
- Makefile, Dockerfile, docker-compose
- tsconfig.json, .eslintrc, jest.config

## File Watcher

Détection des changements de fichiers avec un système de hooks pour le traitement automatique.

### Fonctions

```bash
# Start watching directory
watch_files .

# Detect changes since last check
detect_changes .

# Get recently modified files
get_modified_files . 60         # modified in last 60 seconds

# Register custom hook
register_hook "my_hook_function"

# Start/stop daemon
start_watch_daemon .
stop_watch_daemon
watch_status

# Watch git changes
watch_git_files
watch_git_files --staged-only

# Get statistics
get_watch_stats
```

### Hooks personnalisés

```bash
# Define custom hook function
my_lint_hook() {
    local event="$1"  # added, modified, deleted
    local file="$2"

    if [[ "$event" != "deleted" ]]; then
        run_lint_check "$file" --fix
    fi
}

# Register hook
register_hook "my_lint_hook"

# Start watching
watch_files .
```

## History Summarizer

Suivi de l'historique de session, synthèse et compression du contexte.

### Fonctions

```bash
# Initialize history
init_history

# Add history entry
add_history_entry "command" "npm test" '{"exit_code": 0}'
add_history_entry "file_edit" "src/index.ts" '{"lines_changed": 42}'

# Get history
get_history 50                  # last 50 entries
get_history 50 "command"        # filter by type

# Search history
search_history "test"
search_history "error" "command"

# Get session summary
get_session_summary

# Compress history
compress_history 100            # keep last 100 entries

# Compress context for AI
compress_context "$long_text" 4000

# Git history
get_git_history 20
get_git_history_json 20
summarize_commits HEAD~10 HEAD

# Session management
start_session "feature-auth"
end_session
list_sessions
```

### Gestion des sessions

```bash
# Start named session
start_session "refactor-api"

# Work happens...

# End session and generate summary
end_session
# -> Summary saved to: .harmony/history/session-refactor-api-summary.json
```

## Toolkit Orchestrator

Interface unifiée qui charge et coordonne tous les modules.

### Initialisation

```bash
# Initialize toolkit
assistant_init .

# Output:
# Loading modules:
#   ✓ model-manager
#   ✓ auto-linter
#   ✓ repomap
#   ✓ file-watcher
#   ✓ history-summarizer
```

### Commandes rapides

```bash
# Show toolkit status
assistant_status

# Run workflow on file
assistant_workflow src/index.ts --fix

# Process changed files
assistant_workflow_changed --fix

# Generate AI context
assistant_context .

# Quick lint
assistant_lint --fix

# Quick model info
assistant_model sonnet

# Quick repomap
assistant_map .

# Quick history
assistant_history 20
```

### Chargement des modules

```bash
# Load specific module
load_module "model-manager"

# Load all modules
load_all_modules

# Check if module is loaded
is_module_loaded "auto-linter"
```

## Utilisation en CLI

Tous les modules peuvent être exécutés directement en ligne de commande :

```bash
# Model Manager
./lib/model-manager.sh resolve sonnet
./lib/model-manager.sh tier sonnet
./lib/model-manager.sh cost sonnet 1000 500
./lib/model-manager.sh list --all

# Auto Linter
./lib/auto-linter.sh detect src/app.ts
./lib/auto-linter.sh check src/app.ts
./lib/auto-linter.sh lint --fix src/*.ts
./lib/auto-linter.sh staged --fix

# Repomap
./lib/repomap.sh map .
./lib/repomap.sh json .
./lib/repomap.sh keys .
./lib/repomap.sh summary src/index.ts

# File Watcher
./lib/file-watcher.sh watch .
./lib/file-watcher.sh changes .
./lib/file-watcher.sh status

# History Summarizer
./lib/history-summarizer.sh add command "npm test"
./lib/history-summarizer.sh summary
./lib/history-summarizer.sh git 20

# Toolkit
./lib/assistant-toolkit.sh init .
./lib/assistant-toolkit.sh status
./lib/assistant-toolkit.sh workflow src/app.ts
```

## Intégration avec Sprint Tracker

L'Assistant Toolkit s'intègre au circuit breaker du Sprint Tracker :

```bash
# Auto-linter records failures to circuit breaker
run_lint_check "src/app.ts"
# If lint fails and CURRENT_STORY is set:
# -> record_story_failure "$CURRENT_STORY" "lint"

# History tracks story activities
add_history_entry "story_start" "STORY-001" '{"phase":"development"}'
```

## Bonnes pratiques

1. **Initialiser au démarrage de la session** : Exécutez `assistant_init .` au début d'une session de codage
2. **Utiliser les modèles appropriés** : Laissez `get_model_for_task` sélectionner le bon modèle pour la tâche
3. **Activer le linting automatique** : Définissez `HARMONY_LINT_AUTO_FIX=true` pour un formatage automatique du code
4. **Compresser régulièrement** : Utilisez `compress_history` pour garder l'historique gérable
5. **Mettre en cache les repomaps** : Utilisez `cache_repomap` pour les grandes bases de code
6. **Enregistrer des hooks personnalisés** : Étendez la surveillance de fichiers avec une logique propre au projet
