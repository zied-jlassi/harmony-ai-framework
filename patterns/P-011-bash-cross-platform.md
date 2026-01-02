# P-011: Bash Cross-Platform Compatibility

## Problem

Bash scripts that work on Linux may fail silently on macOS or with `set -e` enabled.

## Critical Rules

### Rule 1: Arithmetic with `set -e`

```bash
# BAD - Exits if count=0 (exit code 1)
((count++))

# GOOD - Always succeeds
count=$((count + 1))
```

**Why?** `((0++))` returns exit code 1 because bash treats 0 as falsy. With `set -e`, script dies.

### Rule 2: SHA256 Checksums

```bash
# BAD - Doesn't exist on macOS
sha256sum file.txt

# GOOD - Cross-platform function
sha256_cmd() {
    if command -v sha256sum &>/dev/null; then
        sha256sum "$@"
    elif command -v shasum &>/dev/null; then
        shasum -a 256 "$@"
    else
        echo "WARNING: No SHA256 tool" >&2
        return 1
    fi
}
```

### Rule 3: Readlink

```bash
# BAD - Option -f doesn't exist on macOS
readlink -f "$path"

# GOOD - Manual loop
while [ -L "$path" ]; do
    dir="$(cd -P "$(dirname "$path")" && pwd)"
    path="$(readlink "$path")"
    [[ $path != /* ]] && path="$dir/$path"
done
```

### Rule 4: Grep Exit Code

```bash
# BAD - Exits with code 1 if no match (fails with set -e)
grep "pattern" file.txt

# GOOD - Ignore exit code
grep "pattern" file.txt || true

# OR in conditionals (already safe)
if grep -q "pattern" file.txt; then
    echo "Found"
fi
```

## Cross-Platform Checklist

Before shipping a bash script:

| Check | Linux | macOS | Windows (Git Bash) |
|-------|-------|-------|-------------------|
| `sha256sum` | ✅ | ❌ Use `shasum -a 256` | ✅ |
| `readlink -f` | ✅ | ❌ Manual loop | ✅ |
| `sed -i` | ✅ | ❌ Needs `sed -i ''` | ✅ |
| `grep -P` | ✅ | ❌ Use `grep -E` | ⚠️ |
| `date +%s%N` | ✅ | ❌ No nanoseconds | ✅ |
| `/dev/tty` | ✅ | ✅ | ⚠️ May not work |

## Template: Safe Bash Header

```bash
#!/bin/bash
set -e

# Cross-platform SHA256
sha256_cmd() {
    if command -v sha256sum &>/dev/null; then
        sha256sum "$@"
    elif command -v shasum &>/dev/null; then
        shasum -a 256 "$@"
    else
        return 1
    fi
}

# Safe increment (works with set -e)
safe_increment() {
    local var_name=$1
    eval "$var_name=\$(($var_name + 1))"
}

# Check if interactive TTY available
has_tty() {
    (exec </dev/tty) 2>/dev/null
}
```

## Related

- ERR-003: `((expr++))` avec set -e cause exit inattendu
- PAT-001: Bash set -e et expressions arithmetiques

## Tags

`bash`, `cross-platform`, `macos`, `linux`, `set-e`, `compatibility`
