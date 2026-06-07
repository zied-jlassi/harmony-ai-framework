# Harmony Upgrade - Framework Update

> Update the Harmony Framework to the latest version.

---

## What It Does

| Action | Description |
|--------|-------------|
| Check version | Compare installed vs latest |
| Backup config | Save overrides before update |
| Update framework | Pull latest from source |
| Preserve local | Keep `.harmony/local/` intact |
| Migrate config | Update deprecated keys |

---

## Commands

### Check for Updates

```bash
harmony upgrade --check
```

### Upgrade Framework

```bash
harmony upgrade
```

---

## Output: --check

```
HARMONY UPGRADE CHECK
─────────────────────

Current version: 1.2.3
Latest version:  1.3.0

Changes in 1.3.0:
├── NEW: AI specialty agents (Nova, Riley, Milo)
├── NEW: Sentinel auto-learning improvements
├── FIX: Circuit breaker edge cases
└── IMPROVED: Profile dependency resolution

Upgrade available! Run: harmony upgrade
```

---

## Output: upgrade

```
HARMONY UPGRADE
───────────────

Step 1/5: Checking current installation...
  ✅ Version 1.2.3 installed
  ✅ Config overrides found

Step 2/5: Backing up configuration...
  ✅ Saved to .harmony/backup/overrides-1.2.3.yaml

Step 3/5: Downloading latest version...
  ✅ Version 1.3.0 downloaded

Step 4/5: Installing framework files...
  ✅ Updated agents/ (22 files)
  ✅ Updated profiles/ (18 files)
  ✅ Updated specialties/ (10 files)
  ✅ Updated commands/ (30 files)
  ⚠️  Skipped local/ (preserved)

Step 5/5: Migrating configuration...
  ✅ Config compatible, no migration needed

Upgrade complete! 1.2.3 → 1.3.0
```

---

## Preserved Files

These files are NEVER overwritten during upgrade:

| Path | Description |
|------|-------------|
| `.harmony/local/` | Local overrides |
| `.harmony/config/overrides.yaml` | Project config |
| `.harmony/local/memory/` | Memory files |
| `CLAUDE.md` | Project instructions |

---

## Rollback

If something goes wrong:

```bash
# Restore previous version
cp .harmony/backup/overrides-1.2.3.yaml .harmony/config/overrides.yaml

# Re-run install with specific version
harmony install --version 1.2.3
```

---

## Version History

Stored in `.harmony/version-history.yaml`:

```yaml
current: "1.3.0"
history:
  - version: "1.3.0"
    date: "2025-12-30"
    from: "1.2.3"
  - version: "1.2.3"
    date: "2025-12-15"
    from: "1.2.0"
```

---

## Usage

```bash
/harmony upgrade                    # 29 - Mettre a jour le framework
/harmony upgrade --check            #    - Verifier updates disponibles
```

---

## See Also

- [Install](install.md) - Initial installation
- [Export](export.md) - Backup configuration
- [Overrides](../docs/overrides.md) - Configuration system
