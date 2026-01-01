# Harmony Hooks - Validation

> Validate Claude Code hooks (executable, references).

---

## What It Checks

| Check | Description |
|-------|-------------|
| Files exist | `.claude/hooks/*.sh` present |
| Executable | chmod +x applied |
| In settings | Referenced in settings.local.json |
| Syntax valid | Shell syntax correct |

---

## Hook Types

| Hook | Trigger | Purpose |
|------|---------|---------|
| `pre-tool-use` | Before Write/Edit/Bash | Validation, Sentinel check |
| `post-tool-use` | After Write/Edit/Bash | Error detection, circuit breaker |
| `pre-commit` | Before git commit | Quality gates |
| `validate-command` | Before Bash | Security check |

---

## Output

```
HARMONY HOOKS VALIDATION
────────────────────────

Found 4 hooks in .claude/hooks/

✅ guardian-checkpoint.sh      Executable, in settings
✅ harmony-sentinel.sh         Executable, in settings
✅ harmony-post-tool.sh        Executable, in settings
✅ validate-command.sh         Executable, in settings

Hook health: 100%
```

---

## Usage

```bash
/harmony hooks              # 9 - Validation hooks
/harmony hooks --install    # Installer hooks par defaut
/harmony hooks --status     # Status hooks
```

---

## See Also

- [Watch](watch.md) - Pre-commit validation
- [Sentinel](sentinel.md) - Error memory system
