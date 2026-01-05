# Bash Pitfalls - Quick Reference

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

# Cross-platform readlink -f
realpath_portable() {
    local path="$1"
    while [ -L "$path" ]; do
        dir=$(dirname "$path")
        path=$(readlink "$path")
        [[ $path != /* ]] && path="$dir/$path"
    done
    echo "$path"
}
```

> **Erreurs bash courantes**: voir `error-library/errors/bash/`
