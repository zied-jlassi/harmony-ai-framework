# P-011: Cross-Platform Compatibility Guide

## Overview

This pattern ensures scripts and tools work across Linux, macOS, and Windows (Git Bash/WSL).

---

## 1. Bash Scripts

### 1.1 Arithmetic with `set -e`

```bash
# BAD
((count++))    # Exit code 1 if count=0

# GOOD
count=$((count + 1))
```

### 1.2 SHA256 Checksums

| OS | Command |
|----|---------|
| Linux | `sha256sum` |
| macOS | `shasum -a 256` |
| Windows | `sha256sum` (Git Bash) |

```bash
sha256_check() {
    command -v sha256sum &>/dev/null && sha256sum "$@" || shasum -a 256 "$@"
}
```

### 1.3 Symlink Resolution

```bash
# BAD - macOS doesn't have -f
readlink -f "$path"

# GOOD - Manual resolution
resolve_path() {
    local path="$1"
    while [ -L "$path" ]; do
        local dir="$(cd -P "$(dirname "$path")" && pwd)"
        path="$(readlink "$path")"
        [[ $path != /* ]] && path="$dir/$path"
    done
    echo "$(cd -P "$(dirname "$path")" && pwd)/$(basename "$path")"
}
```

### 1.4 sed In-Place

```bash
# BAD
sed -i 's/old/new/' file    # Fails on macOS

# GOOD
sed -i'' 's/old/new/' file  # Works on both (no space!)
# OR
sed 's/old/new/' file > tmp && mv tmp file
```

### 1.5 Date/Time

```bash
# BAD - macOS doesn't support nanoseconds
date +%s%N

# GOOD
date +%s    # Seconds only (portable)
# OR use Python for precision
python3 -c "import time; print(int(time.time() * 1000))"
```

---

## 2. Node.js / npm

### 2.1 Path Separators

```javascript
// BAD
const configPath = './config/settings.json';

// GOOD
const path = require('path');
const configPath = path.join('config', 'settings.json');
```

### 2.2 Line Endings

```javascript
// .gitattributes
* text=auto
*.sh text eol=lf
*.bat text eol=crlf
```

### 2.3 Environment Variables

```javascript
// BAD
process.env.HOME  // Undefined on Windows

// GOOD
const os = require('os');
os.homedir();  // Works everywhere
```

---

## 3. Docker

### 3.1 File Permissions

```dockerfile
# Linux/macOS: files are owned by host user
# Windows: files are owned by root

# Solution: Use environment variable for UID
ARG UID=1000
RUN useradd -u $UID appuser
```

### 3.2 Line Endings in Scripts

```dockerfile
# Ensure LF endings for shell scripts
COPY --chmod=755 scripts/*.sh /app/
RUN sed -i 's/\r$//' /app/*.sh
```

---

## 4. Python

### 4.1 Paths

```python
# BAD
config_path = "config/settings.json"

# GOOD
from pathlib import Path
config_path = Path("config") / "settings.json"
```

### 4.2 Encoding

```python
# Always specify encoding
with open(file, 'r', encoding='utf-8') as f:
    content = f.read()
```

---

## 5. Quick Reference Table

| Feature | Linux | macOS | Windows (Git Bash) |
|---------|-------|-------|-------------------|
| `sha256sum` | ✅ | ❌ `shasum -a 256` | ✅ |
| `readlink -f` | ✅ | ❌ | ✅ |
| `sed -i` | ✅ | ❌ `sed -i''` | ✅ |
| `date +%N` | ✅ | ❌ | ✅ |
| `grep -P` | ✅ | ❌ `grep -E` | ⚠️ |
| `/dev/tty` | ✅ | ✅ | ⚠️ |
| Case-sensitive FS | ✅ | ⚠️ Default no | ❌ |
| Path separator | `/` | `/` | `\` or `/` |
| Line endings | LF | LF | CRLF |

---

## 6. Pre-Release Checklist

Before releasing cross-platform tools:

- [ ] Test on Linux (Ubuntu/Debian)
- [ ] Test on macOS
- [ ] Test on Windows (Git Bash or WSL)
- [ ] Check for hardcoded paths (`/usr/`, `/home/`)
- [ ] Verify `set -e` compatibility
- [ ] Ensure UTF-8 encoding
- [ ] Check line endings (`.gitattributes`)
- [ ] Verify npm/node scripts work
- [ ] Test Docker builds on all platforms

---

## Related

- ERR-003: Bash `((expr++))` with `set -e`
- PAT-001: Bash arithmetic patterns

## Tags

`cross-platform`, `linux`, `macos`, `windows`, `bash`, `nodejs`, `docker`, `python`
