# Bash Pitfalls - Quick Reference

## CRITICAL: set -e Traps

| Bad | Good | Why |
|-----|------|-----|
| `((count++))` | `count=$((count + 1))` | Exit 1 if count=0 |
| `grep pattern file` | `grep pattern file \|\| true` | Exit 1 if no match |

## macOS Compatibility

| Linux | macOS | Fix |
|-------|-------|-----|
| `sha256sum` | `shasum -a 256` | Wrapper function |
| `readlink -f` | Manual loop | See below |
| `sed -i 'cmd'` | `sed -i'' 'cmd'` | No space! |
| `date +%N` | N/A | Use `date +%s` |

## Quick Fixes

```bash
# Cross-platform sha256
sha256_cmd() { command -v sha256sum &>/dev/null && sha256sum "$@" || shasum -a 256 "$@"; }

# Safe TTY check
has_tty() { (exec </dev/tty) 2>/dev/null; }

# Safe increment
count=$((count + 1))  # NOT ((count++))
```
