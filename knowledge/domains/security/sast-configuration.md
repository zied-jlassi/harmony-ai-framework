---
name: sast-configuration
displayName: "SAST Configuration"
category: security-scanning
tier: 2
model: inherit
triggers:
  - "static analysis"
  - "security scanning"
  - "code security"
  - "SAST"
  - "vulnerability"
---

# Static Application Security Testing (SAST)

> Configure Static Application Security Testing for automated vulnerability detection.

## Tools Overview

| Tool | Language | Use Case |
|------|----------|----------|
| **ESLint Security** | JavaScript/TS | XSS, injection |
| **Semgrep** | Multi-language | Custom rules |
| **SonarQube** | Multi-language | Enterprise |
| **Snyk Code** | Multi-language | Real-time |
| **CodeQL** | Multi-language | GitHub native |

## ESLint Security Configuration

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:security/recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  plugins: ['security', 'no-secrets'],
  rules: {
    // Detect hardcoded secrets
    'no-secrets/no-secrets': 'error',

    // Prevent eval and similar
    'no-eval': 'error',
    'no-implied-eval': 'error',
    'no-new-func': 'error',

    // Prevent prototype pollution
    'security/detect-object-injection': 'warn',

    // Prevent unsafe regex
    'security/detect-unsafe-regex': 'error',

    // Prevent buffer issues
    'security/detect-buffer-noassert': 'error',

    // Prevent child_process issues
    'security/detect-child-process': 'warn',

    // Prevent non-literal require
    'security/detect-non-literal-require': 'warn',

    // Prevent non-literal fs
    'security/detect-non-literal-fs-filename': 'warn',

    // SQL injection prevention
    'security/detect-sql-injection': 'error',
  },
};
```

## Semgrep Configuration

```yaml
# .semgrep.yaml
rules:
  - id: hardcoded-jwt-secret
    patterns:
      - pattern: |
          jwt.sign($PAYLOAD, "...")
    message: "Hardcoded JWT secret detected"
    severity: ERROR
    languages: [javascript, typescript]

  - id: sql-injection
    patterns:
      - pattern: |
          $DB.query(`... ${$VAR} ...`)
    message: "Potential SQL injection - use parameterized queries"
    severity: ERROR
    languages: [javascript, typescript]

  - id: xss-vulnerability
    patterns:
      - pattern: |
          dangerouslySetInnerHTML={{ __html: $VAR }}
    message: "Potential XSS - sanitize input before rendering"
    severity: WARNING
    languages: [javascript, typescript]

  - id: insecure-crypto
    patterns:
      - pattern: |
          crypto.createHash("md5")
      - pattern: |
          crypto.createHash("sha1")
    message: "Use SHA-256 or stronger hashing algorithm"
    severity: WARNING
    languages: [javascript, typescript]

  - id: command-injection
    patterns:
      - pattern: |
          exec($USER_INPUT)
      - pattern: |
          spawn($USER_INPUT, ...)
    message: "Potential command injection"
    severity: ERROR
    languages: [javascript, typescript]
```

### Semgrep in CI
```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Semgrep Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/secrets
            p/owasp-top-ten
            .semgrep.yaml
```

## CodeQL Configuration

```yaml
# .github/workflows/codeql.yml
name: CodeQL

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0' # Weekly

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read

    strategy:
      matrix:
        language: ['javascript', 'typescript']

    steps:
      - uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
          queries: +security-and-quality

      - name: Autobuild
        uses: github/codeql-action/autobuild@v2

      - name: Perform Analysis
        uses: github/codeql-action/analyze@v2
        with:
          category: "/language:${{ matrix.language }}"
```

## Custom CodeQL Query

```ql
// queries/sql-injection.ql
/**
 * @name SQL Injection
 * @description User input in SQL query without parameterization
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.0
 * @id js/sql-injection
 */

import javascript
import semmle.javascript.security.dataflow.SqlInjectionQuery

from SqlInjectionConfiguration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select sink, source, sink, "SQL injection from $@.", source.getNode(), "user input"
```

## OWASP Top 10 Checks

| # | Vulnerability | Detection Rule |
|---|--------------|----------------|
| A01 | Broken Access Control | Role checks, authorization |
| A02 | Cryptographic Failures | Weak crypto, hardcoded secrets |
| A03 | Injection | SQL, Command, XSS |
| A04 | Insecure Design | Architecture patterns |
| A05 | Security Misconfiguration | Config files, headers |
| A06 | Vulnerable Components | Dependency scanning |
| A07 | Auth Failures | Session, password handling |
| A08 | Integrity Failures | Unsigned data, CI/CD |
| A09 | Logging Failures | Sensitive data in logs |
| A10 | SSRF | URL validation |

## Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/returntocorp/semgrep
    rev: v1.50.0
    hooks:
      - id: semgrep
        args: ['--config', 'p/security-audit', '--error']

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: detect-private-key
```

## Integration with CI/CD

```yaml
# Complete security pipeline
security:
  stage: test
  parallel:
    matrix:
      - SCANNER: [eslint, semgrep, snyk]
  script:
    - case $SCANNER in
        eslint)
          npm run lint:security
          ;;
        semgrep)
          semgrep --config=p/security-audit --error
          ;;
        snyk)
          snyk test --severity-threshold=high
          ;;
      esac
  allow_failure: false
```

## Best Practices

- [ ] Run SAST on every commit
- [ ] Block PRs on high/critical findings
- [ ] Maintain baseline for false positives
- [ ] Custom rules for project-specific patterns
- [ ] Regular rule updates
- [ ] Combine with DAST for full coverage
- [ ] Developer training on findings
