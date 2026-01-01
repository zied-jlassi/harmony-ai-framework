# Harmony Watch - Pre-Commit Validation

> Hook for pre-commit validation to catch issues before commit.

---

## What It Does

Integrates with git pre-commit hook to validate changes.

| Check | Description |
|-------|-------------|
| Syntax | Valid YAML/JSON/Markdown |
| References | No broken links in changes |
| Naming | Follows conventions |
| Secrets | No credentials in commit |

---

## Setup

```bash
# Install hook
/harmony watch --install

# Creates .git/hooks/pre-commit with Harmony validation
```

---

## Hook Behavior

```
PRE-COMMIT VALIDATION
─────────────────────

Checking staged files...

✅ agents/new-agent.md     Syntax OK
✅ profiles/nestjs.yaml    References valid
⚠️ CLAUDE.md               Large file (>1000 lines)
❌ .env.local               Contains secrets!

BLOCKED: 1 error found
Fix issues or use --no-verify to bypass
```

---

## Bypass

```bash
# Emergency bypass (not recommended)
git commit --no-verify -m "hotfix: urgent"
```

---

## Usage

```bash
/harmony watch           # Check current changes
/harmony watch --install # Install pre-commit hook
/harmony watch --status  # Show hook status
```

---

## See Also

- [Quick](quick.md) - Manual quick check
- [Hooks](hooks.md) - Hook validation
