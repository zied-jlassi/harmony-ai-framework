# Harmony Init - Project Initialization

> Initialize Harmony in a new or existing project.

---

## Quick Start

```bash
# Navigate to your project
cd my-project

# Initialize Harmony
harmony init
```

---

## What It Does

### Step 1: Create Structure

```
my-project/
└── .harmony/
    ├── harmony.manifest.json  # Project config
    ├── memory/                # Sentinel files
    │   ├── error-journal.json
    │   ├── circuit-breaker.json
    │   └── workflow-state.json
    └── project.yaml           # Active profiles/specialties
```

### Step 2: Detect Stack

Analyzes your project to detect:
- `package.json` → nodejs, typescript
- `tsconfig.json` → typescript
- `prisma/schema.prisma` → prisma
- `angular.json` → angular
- `nest-cli.json` → nestjs

### Step 3: Suggest Profiles

```
Detected profiles:
├── typescript (required: javascript)
├── nodejs
├── nestjs
└── prisma

Activate these profiles? [Y/n]
```

### Step 4: Configure IDE

```
Which IDE are you using?
1. Claude Code (recommended)
2. Cursor
3. Windsurf
4. Continue
5. Cody
6. Skip for now

Select [1-6]:
```

---

## Options

| Option | Description |
|--------|-------------|
| `--profiles <list>` | Pre-select profiles |
| `--specialty <id>` | Pre-select specialty |
| `--ide <name>` | Pre-select IDE |
| `--skip-detect` | Skip auto-detection |

---

## Example

```bash
# Full auto-detection
harmony init

# Pre-configured
harmony init --profiles "typescript,nestjs,prisma" --ide claude-code

# Gaming project
harmony init --specialty gaming
```

---

## Output

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    🛡️ HARMONY INITIALIZED                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Project: my-project                                                         ║
║   Profiles: typescript, nodejs, nestjs, prisma                                ║
║   Specialty: none                                                             ║
║   IDE: Claude Code                                                            ║
║                                                                               ║
║   Next steps:                                                                 ║
║   1. Run: harmony status                                                      ║
║   2. Start developing with /harmony workflow                                  ║
║                                                                               ║
║   Learn. Protect. Deliver. ✓                                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## See Also

- [Profiles](profiles.md) - Manage tech profiles
- [Specialties](specialties.md) - Add domain expertise
- [Install](install.md) - Configure IDE
