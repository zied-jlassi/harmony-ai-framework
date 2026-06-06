# Pattern: Framework Guardian (P-012)

> **ID**: P-012
> **Category**: Architecture / Protection
> **Status**: MANDATORY
> **Priority**: CRITICAL

---

## Problem

Without protection:
- Framework files modified = update failures
- User data scattered = tokens wasted searching
- Confusion framework docs vs user docs

## Solution

Strict separation:
- `.harmony/` = Framework (immutable, like vendor/)
- `.harmony/local/` = User space (all user data here)

---

## Architecture Complete

```
.harmony/
│
├── [FRAMEWORK - IMMUTABLE AFTER INSTALL]
│   │
│   ├── agents/              # Agent definitions
│   ├── workflows/           # Workflow definitions
│   ├── patterns/            # Pattern library
│   ├── templates/           # Base templates
│   ├── hooks/               # Framework hooks
│   ├── lib/                 # Shell libraries
│   ├── bin/                 # Executables
│   ├── config/              # Default config
│   ├── docs/                # FRAMEWORK DOCUMENTATION
│   │   ├── quick-start.md   #   How to use Harmony
│   │   ├── agents.md        #   Agent reference
│   │   └── ...              #   Framework guides
│   └── MANIFEST.json        # Integrity hash
│
└── local/                   # USER SPACE (created at init, before full install)
    │
    ├── config.yaml          # User config overrides
    │
    ├── overrides/           # Framework customizations
    │   ├── agents/          #   Custom/modified agents
    │   ├── hooks/           #   Custom hooks
    │   └── templates/       #   Custom templates
    │
    └── project/             # PROJECT DATA (user created content)
        ├── backlog/
        │   ├── epics/       #   EPIC-XXX.md
        │   ├── stories/     #   STORY-XXX.md
        │   └── tasks/       #   TASK-XXX.md
        ├── prd/             #   PRD documents
        ├── briefs/          #   Product briefs
        ├── analysis/        #   Analysis artifacts
        ├── architecture/
        │   └── adrs/        #   Architecture Decision Records
        ├── roadmap/         #   Roadmap documents
        └── rex/             #   Retours d'experience
```

---

## Two Install Modes

### Mode 1: Quick Init (structure only)

```bash
/hf:init
# OR
harmony --init
```

Creates empty user structure WITHOUT full framework:

```
.harmony/
└── local/
    ├── config.yaml          # Empty, ready for customization
    └── project/
        ├── backlog/
        │   ├── epics/
        │   ├── stories/
        │   └── tasks/
        ├── prd/
        ├── briefs/
        ├── analysis/
        └── architecture/
            └── adrs/
```

User can start organizing docs immediately.

### Mode 2: Full Install

```bash
/hf:install
# OR
harmony --install
```

Installs complete framework + creates user structure:

```
.harmony/
├── agents/
├── workflows/
├── patterns/
├── templates/
├── hooks/
├── lib/
├── bin/
├── config/
├── docs/                    # Framework docs
├── MANIFEST.json
└── local/                   # User space
    └── ...
```

---

## Protection Rules

### Rule 1: Framework is Read-Only

After install, NEVER write to:
```
.harmony/agents/
.harmony/workflows/
.harmony/patterns/
.harmony/templates/
.harmony/hooks/
.harmony/lib/
.harmony/bin/
.harmony/config/
.harmony/docs/              # Framework docs!
```

### Rule 2: User Data ONLY in local/

ALWAYS write user content here:
```
.harmony/local/project/backlog/
.harmony/local/project/prd/
.harmony/local/project/briefs/
.harmony/local/project/analysis/
.harmony/local/project/architecture/
```

### Rule 3: Overrides in local/overrides/

To customize framework:
```bash
# DON'T modify:
.harmony/agents/analyst.md

# DO create:
.harmony/local/overrides/agents/analyst.md
```

---

## Init Script (creates empty structure)

```bash
#!/bin/bash
# bin/init-structure.sh

HARMONY_LOCAL="${HARMONY_DIR:-.harmony}/local"

echo "Creating Harmony user structure..."

# Project directories
mkdir -p "$HARMONY_LOCAL/project/backlog/epics"
mkdir -p "$HARMONY_LOCAL/project/backlog/stories"
mkdir -p "$HARMONY_LOCAL/project/backlog/tasks"
mkdir -p "$HARMONY_LOCAL/project/prd"
mkdir -p "$HARMONY_LOCAL/project/briefs"
mkdir -p "$HARMONY_LOCAL/project/analysis"
mkdir -p "$HARMONY_LOCAL/project/architecture/adrs"
mkdir -p "$HARMONY_LOCAL/project/roadmap"
mkdir -p "$HARMONY_LOCAL/project/rex"

# Override directories
mkdir -p "$HARMONY_LOCAL/overrides/agents"
mkdir -p "$HARMONY_LOCAL/overrides/hooks"
mkdir -p "$HARMONY_LOCAL/overrides/templates"

# Empty config
if [[ ! -f "$HARMONY_LOCAL/config.yaml" ]]; then
    cat > "$HARMONY_LOCAL/config.yaml" << 'EOF'
# Harmony Local Configuration
# Override framework defaults here

# paths:
#   backlog: ".harmony/local/project/backlog"  # default
#   prd: ".harmony/local/project/prd"          # default
EOF
fi

echo "Done! Structure created in $HARMONY_LOCAL"
echo ""
echo "You can now:"
echo "  - Create stories in .harmony/local/project/backlog/stories/"
echo "  - Create PRDs in .harmony/local/project/prd/"
echo "  - Customize agents in .harmony/local/overrides/agents/"
```

---

## Guardian Hook

```bash
#!/bin/bash
# hooks/guardian-framework.sh

HARMONY_DIR="${HARMONY_DIR:-.harmony}"
TARGET_PATH="$1"

# Paths that are protected (framework)
PROTECTED_PATHS=(
    "$HARMONY_DIR/agents"
    "$HARMONY_DIR/workflows"
    "$HARMONY_DIR/patterns"
    "$HARMONY_DIR/templates"
    "$HARMONY_DIR/hooks"
    "$HARMONY_DIR/lib"
    "$HARMONY_DIR/bin"
    "$HARMONY_DIR/config"
    "$HARMONY_DIR/docs"
)

# Check if target is in protected area
for protected in "${PROTECTED_PATHS[@]}"; do
    if [[ "$TARGET_PATH" == "$protected"* ]]; then
        echo ""
        echo "FRAMEWORK GUARDIAN - Write Blocked"
        echo "==================================="
        echo ""
        echo "Target: $TARGET_PATH"
        echo ""
        echo "This path is part of the Harmony framework."
        echo "Modifying it will cause:"
        echo "  - Update failures"
        echo "  - Framework inconsistency"
        echo "  - Lost changes on next update"
        echo ""
        echo "SOLUTION: Use .harmony/local/ instead"
        echo ""

        # Suggest alternative
        RELATIVE="${TARGET_PATH#$HARMONY_DIR/}"
        echo "Suggested path:"
        echo "  .harmony/local/overrides/$RELATIVE"
        echo ""

        exit 1
    fi
done

# Path OK
exit 0
```

---

## Integrity Check: `/hf:check:framework`

```bash
#!/bin/bash
# bin/check-framework.sh

HARMONY_DIR="${HARMONY_DIR:-.harmony}"
MANIFEST="$HARMONY_DIR/MANIFEST.json"

echo ""
echo "Harmony Framework Integrity Check"
echo "=================================="
echo ""

if [[ ! -f "$MANIFEST" ]]; then
    echo "[WARN] MANIFEST.json not found"
    echo "       Cannot verify integrity."
    echo "       Run /hf:install to create manifest."
    exit 1
fi

ERRORS=0

for dir in agents workflows patterns templates hooks lib bin config docs; do
    if [[ -d "$HARMONY_DIR/$dir" ]]; then
        CURRENT=$(find "$HARMONY_DIR/$dir" -type f -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -d' ' -f1)
        EXPECTED=$(jq -r ".directories.\"$dir\".hash // empty" "$MANIFEST" 2>/dev/null)

        if [[ -z "$EXPECTED" ]]; then
            echo "[SKIP] $dir - Not in manifest"
        elif [[ "$CURRENT" == "$EXPECTED" ]]; then
            echo "[OK]   $dir"
        else
            echo "[FAIL] $dir - Modified!"
            ((ERRORS++))
        fi
    fi
done

echo ""
if [[ $ERRORS -gt 0 ]]; then
    echo "RESULT: $ERRORS directories modified"
    echo ""
    echo "To fix:"
    echo "  1. Move changes to .harmony/local/overrides/"
    echo "  2. Run: /hf:install --force"
else
    echo "RESULT: Framework integrity OK"
fi
```

---

## Path Resolution (updated)

```yaml
# Default paths (in config-loader)
defaults:
  # User project data
  backlog: ".harmony/local/project/backlog"
  prd: ".harmony/local/project/prd"
  briefs: ".harmony/local/project/briefs"
  analysis: ".harmony/local/project/analysis"
  architecture: ".harmony/local/project/architecture"

  # Overrides
  agents_override: ".harmony/local/overrides/agents"
  hooks_override: ".harmony/local/overrides/hooks"
  templates_override: ".harmony/local/overrides/templates"

  # Framework (read-only)
  agents: ".harmony/agents"
  workflows: ".harmony/workflows"
  patterns: ".harmony/patterns"
  templates: ".harmony/templates"
  docs: ".harmony/docs"
```

---

## Benefits

| Aspect | Benefit |
|--------|---------|
| **Token efficiency** | Claude searches only `.harmony/local/project/` |
| **Safe updates** | Framework untouched by user data |
| **Quick start** | `/hf:init` creates structure immediately |
| **Clean project** | One `.harmony/` folder, nothing scattered |
| **Easy backup** | `tar -czf backup.tar.gz .harmony/local/` |
| **Clear distinction** | Framework docs vs User docs |

---

## Summary

| Location | Purpose | Mutable? |
|----------|---------|----------|
| `.harmony/docs/` | How to use Harmony | NO |
| `.harmony/agents/` | Framework agents | NO |
| `.harmony/local/project/` | User's work | YES |
| `.harmony/local/overrides/` | User customizations | YES |

---

## Related

- [Config Loader](../lib/config-loader.sh)
- [Install Script](../bin/install.sh)
- [P-007 Story Based](./P-007-story-based.md)
