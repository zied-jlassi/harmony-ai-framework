# Harmony Export - Configuration Backup

> Export Harmony configuration for backup or sharing.

---

## What It Does

| Action | Description |
|--------|-------------|
| Export config | Overrides, profiles, specialties |
| Export memory | Workflow state, error journal |
| Create archive | Single file for transfer |
| Version included | Framework version in export |

---

## Commands

### Export Configuration Only

```bash
harmony export
```

### Full Export (Config + Memory)

```bash
harmony export --full
```

---

## Output

```
HARMONY EXPORT
──────────────

Exporting configuration...

Included:
  ✅ .harmony/config/overrides.yaml
  ✅ .harmony/project.yaml
  ✅ Active profiles: nestjs, angular
  ✅ Active specialties: gaming, quality

Full export (--full):
  ✅ .claude/memory/workflow-state.json
  ✅ .claude/memory/error-journal.json
  ✅ .claude/memory/learned-patterns.json

Created: harmony-export-2025-12-30.tar.gz

Size: 24 KB
Checksum: sha256:abc123...
```

---

## Export Contents

### Standard Export

```
harmony-export-2025-12-30/
├── meta.yaml                          # Export metadata
├── config/
│   ├── overrides.yaml                 # Project overrides
│   └── project.yaml                   # Project info
└── active/
    ├── profiles.yaml                  # Active profiles list
    └── specialties.yaml               # Active specialties list
```

### Full Export (--full)

```
harmony-export-2025-12-30/
├── meta.yaml
├── config/
│   ├── overrides.yaml
│   └── project.yaml
├── active/
│   ├── profiles.yaml
│   └── specialties.yaml
└── memory/
    ├── workflow-state.json           # Current phase/story
    ├── error-journal.json            # Error history
    ├── learned-patterns.json         # Validated patterns
    └── circuit-breaker.json          # CB state
```

---

## Meta File

```yaml
# meta.yaml
export:
  version: "1.0"
  date: "2025-12-30T10:30:00Z"
  framework_version: "1.3.0"
  type: "full"  # or "config"

source:
  project: "my-project"
  user: "developer"

checksums:
  config/overrides.yaml: "sha256:..."
  memory/workflow-state.json: "sha256:..."
```

---

## Import

To import an exported configuration:

```bash
# Extract
tar -xzf harmony-export-2025-12-30.tar.gz

# Apply config
cp harmony-export-2025-12-30/config/* .harmony/config/

# Apply memory (optional)
cp harmony-export-2025-12-30/memory/* .claude/memory/
```

---

## Use Cases

| Use Case | Command |
|----------|---------|
| Backup before upgrade | `harmony export` |
| Share config with team | `harmony export` |
| Transfer to new machine | `harmony export --full` |
| Disaster recovery | `harmony export --full` |

---

## Usage

```bash
/harmony export                     # 30 - Exporter configuration
/harmony export --full              #    - Export complet avec memory
```

---

## See Also

- [Upgrade](upgrade.md) - Framework updates
- [Install](install.md) - Initial setup
- [Overrides](../docs/overrides.md) - Configuration system
