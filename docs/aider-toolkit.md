# Aider Toolkit

The Aider Toolkit provides a collection of modules inspired by [Aider](https://github.com/paul-gauthier/aider), a powerful AI pair programming tool. These modules enhance Harmony Framework with model management, automatic linting, repository mapping, file watching, and session history management.

## Overview

| Module | File | Purpose |
|--------|------|---------|
| Model Manager | `model-manager.sh` | Model aliases, tiers, and cost estimation |
| Auto Linter | `auto-linter.sh` | Language detection and automatic linting |
| Repomap | `repomap.sh` | Repository structure and analysis |
| File Watcher | `file-watcher.sh` | File change detection and hooks |
| History Summarizer | `history-summarizer.sh` | Session history and context compression |
| Toolkit Orchestrator | `aider-toolkit.sh` | Unified interface for all modules |

## Quick Start

```bash
# Source the unified toolkit
source .harmony/lib/aider-toolkit.sh

# Initialize all modules
aider_init .

# Show status
aider_status

# Run workflow on a file
aider_workflow src/index.ts --fix
```

## Model Manager

Provides model aliasing, tier classification, and cost estimation for multi-model AI workflows.

### Model Aliases

| Alias | Full Model Name |
|-------|-----------------|
| `sonnet` | anthropic/claude-sonnet-4 |
| `opus` | anthropic/claude-opus-4 |
| `haiku` | anthropic/claude-3-5-haiku |
| `gpt4` | openai/gpt-4 |
| `gpt4o` | openai/gpt-4o |
| `deepseek` | deepseek/deepseek-chat |
| `deepseek-r1` | deepseek/deepseek-reasoner |

### Model Tiers

- **Main**: Expensive, most capable (opus, gpt-4, o1)
- **Editor**: Balanced for code editing (sonnet, gpt-4o)
- **Weak**: Cheap, for simple tasks (haiku, deepseek-chat)

### Functions

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

### Environment Variables

```bash
export HARMONY_MAIN_MODEL="anthropic/claude-opus-4"
export HARMONY_WEAK_MODEL="anthropic/claude-3-5-haiku"
export HARMONY_EDITOR_MODEL="anthropic/claude-sonnet-4"
```

## Auto Linter

Automatic language detection and linting with support for multiple languages and linters.

### Supported Languages

| Language | Default Linter | Alternatives |
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

### Functions

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

### Environment Variables

```bash
export HARMONY_LINT_AUTO_FIX="true"
export HARMONY_LINT_STRICT="true"
export HARMONY_LINT_IGNORE_PATTERNS="node_modules,vendor,.git,dist"
```

## Repomap

Repository structure analysis and mapping for AI context generation.

### Functions

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

### Key File Patterns

Automatically detected:
- README, CHANGELOG, CONTRIBUTING
- package.json, Cargo.toml, go.mod, requirements.txt
- Makefile, Dockerfile, docker-compose
- tsconfig.json, .eslintrc, jest.config

## File Watcher

File change detection with hook system for automatic processing.

### Functions

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

### Custom Hooks

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

Session history tracking, summarization, and context compression.

### Functions

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

### Session Management

```bash
# Start named session
start_session "refactor-api"

# Work happens...

# End session and generate summary
end_session
# -> Summary saved to: .harmony/history/session-refactor-api-summary.json
```

## Toolkit Orchestrator

Unified interface that loads and coordinates all modules.

### Initialization

```bash
# Initialize toolkit
aider_init .

# Output:
# Loading modules:
#   ✓ model-manager
#   ✓ auto-linter
#   ✓ repomap
#   ✓ file-watcher
#   ✓ history-summarizer
```

### Quick Commands

```bash
# Show toolkit status
aider_status

# Run workflow on file
aider_workflow src/index.ts --fix

# Process changed files
aider_workflow_changed --fix

# Generate AI context
aider_context .

# Quick lint
aider_lint --fix

# Quick model info
aider_model sonnet

# Quick repomap
aider_map .

# Quick history
aider_history 20
```

### Module Loading

```bash
# Load specific module
load_module "model-manager"

# Load all modules
load_all_modules

# Check if module is loaded
is_module_loaded "auto-linter"
```

## CLI Usage

All modules can be run directly from command line:

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
./lib/aider-toolkit.sh init .
./lib/aider-toolkit.sh status
./lib/aider-toolkit.sh workflow src/app.ts
```

## Integration with Sprint Tracker

The Aider Toolkit integrates with the Sprint Tracker circuit breaker:

```bash
# Auto-linter records failures to circuit breaker
run_lint_check "src/app.ts"
# If lint fails and CURRENT_STORY is set:
# -> record_story_failure "$CURRENT_STORY" "lint"

# History tracks story activities
add_history_entry "story_start" "STORY-001" '{"phase":"development"}'
```

## Best Practices

1. **Initialize at session start**: Run `aider_init .` when starting a coding session
2. **Use appropriate models**: Let `get_model_for_task` select the right model for the job
3. **Enable auto-lint**: Set `HARMONY_LINT_AUTO_FIX=true` for automatic code formatting
4. **Compress regularly**: Use `compress_history` to keep history manageable
5. **Cache repomaps**: Use `cache_repomap` for large codebases
6. **Register custom hooks**: Extend file watching with project-specific logic
