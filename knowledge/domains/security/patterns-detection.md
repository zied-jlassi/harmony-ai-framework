# Dangerous Patterns Detection

> Module de l'agent `/hf-agent-security`
> **Source**: Audit CIS Benchmark
> **Commandes**: `audit-patterns`, `audit-code`

---

## Detection de Patterns Dangereux

**Contexte**: Les audits de securite recommandent d'interdire les fonctions dangereuses comme `eval()`, `shell_exec()`, etc.

### Checklist Patterns Dangereux

```markdown
## Audit Patterns Dangereux

### JavaScript/TypeScript
- [ ] Pas de eval() ou Function()
- [ ] Pas de child_process.exec() non securise
- [ ] Pas de vm.runInContext() avec input utilisateur
- [ ] Pas de new Function() dynamique
- [ ] Pas de innerHTML avec input non sanitise

### SQL/Prisma
- [ ] Pas de $queryRaw sans parametres
- [ ] Pas de $executeRaw avec interpolation
- [ ] Pas de concatenation SQL

### Secrets
- [ ] Pas de cles API en dur
- [ ] Pas de mots de passe dans le code
- [ ] Pas de tokens dans les logs

### Dependances
- [ ] Pas de dependances avec CVE critiques
- [ ] Pas de dependances deprecated
```

---

## Script d'Audit Automatise

```typescript
// scripts/audit-dangerous-patterns.ts
import { glob } from 'glob';
import * as fs from 'fs';

interface DangerousPattern {
  pattern: RegExp;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
  description: string;
  cwe: string;
}

const dangerousPatterns: DangerousPattern[] = [
  // Code Execution
  {
    pattern: /\beval\s*\(/g,
    severity: 'CRITICAL',
    description: 'eval() detected - Code injection risk',
    cwe: 'CWE-95',
  },
  {
    pattern: /new\s+Function\s*\(/g,
    severity: 'CRITICAL',
    description: 'new Function() detected - Code injection risk',
    cwe: 'CWE-95',
  },
  {
    pattern: /child_process\.(exec|execSync|spawn)\s*\(/g,
    severity: 'HIGH',
    description: 'Command execution detected - Verify input sanitization',
    cwe: 'CWE-78',
  },
  {
    pattern: /vm\.(runInContext|runInNewContext|runInThisContext)\s*\(/g,
    severity: 'HIGH',
    description: 'VM execution detected - Sandbox escape risk',
    cwe: 'CWE-94',
  },

  // DOM XSS
  {
    pattern: /\.innerHTML\s*=/g,
    severity: 'HIGH',
    description: 'innerHTML assignment - XSS risk if unsanitized',
    cwe: 'CWE-79',
  },
  {
    pattern: /document\.write\s*\(/g,
    severity: 'HIGH',
    description: 'document.write() detected - XSS risk',
    cwe: 'CWE-79',
  },
  {
    pattern: /dangerouslySetInnerHTML/g,
    severity: 'MEDIUM',
    description: 'dangerouslySetInnerHTML - Verify sanitization',
    cwe: 'CWE-79',
  },

  // SQL Injection
  {
    pattern: /\$queryRaw`[^`]*\$\{/g,
    severity: 'CRITICAL',
    description: 'Prisma raw query with interpolation - SQL injection risk',
    cwe: 'CWE-89',
  },
  {
    pattern: /\$executeRaw`[^`]*\$\{/g,
    severity: 'CRITICAL',
    description: 'Prisma execute raw with interpolation - SQL injection risk',
    cwe: 'CWE-89',
  },

  // Secrets
  {
    pattern: /(api[_-]?key|apikey|secret[_-]?key|password|passwd|pwd)\s*[:=]\s*['"][^'"]{8,}['"]/gi,
    severity: 'CRITICAL',
    description: 'Hardcoded secret detected',
    cwe: 'CWE-798',
  },
  {
    pattern: /-----BEGIN (RSA |EC |DSA )?(PRIVATE KEY|ENCRYPTED PRIVATE KEY)-----/g,
    severity: 'CRITICAL',
    description: 'Private key in code',
    cwe: 'CWE-321',
  },
  {
    pattern: /eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/g,
    severity: 'HIGH',
    description: 'JWT token in code',
    cwe: 'CWE-798',
  },

  // Unsafe deserialization
  {
    pattern: /JSON\.parse\s*\(\s*req\.(body|query|params)/g,
    severity: 'MEDIUM',
    description: 'Direct JSON.parse from request - Prototype pollution risk',
    cwe: 'CWE-1321',
  },

  // Path traversal
  {
    pattern: /path\.(join|resolve)\s*\([^)]*req\.(body|query|params)/g,
    severity: 'HIGH',
    description: 'User input in path operation - Path traversal risk',
    cwe: 'CWE-22',
  },

  // Regex DoS
  {
    pattern: /new RegExp\s*\(\s*req\.(body|query|params)/g,
    severity: 'MEDIUM',
    description: 'User input in RegExp - ReDoS risk',
    cwe: 'CWE-1333',
  },

  // Console in production
  {
    pattern: /console\.(log|debug|info|warn|error)\s*\(/g,
    severity: 'LOW',
    description: 'Console statement - Remove in production',
    cwe: 'CWE-532',
  },
];

async function auditDangerousPatterns(srcPath: string): Promise<void> {
  const files = await glob(`${srcPath}/**/*.{ts,tsx,js,jsx}`, {
    ignore: ['**/node_modules/**', '**/dist/**', '**/*.spec.ts', '**/*.test.ts'],
  });

  const findings: Array<{
    file: string;
    line: number;
    pattern: DangerousPattern;
    match: string;
  }> = [];

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf-8');

    for (const pattern of dangerousPatterns) {
      let match;
      const regex = new RegExp(pattern.pattern.source, pattern.pattern.flags);

      while ((match = regex.exec(content)) !== null) {
        const lineNum = content.substring(0, match.index).split('\n').length;

        findings.push({
          file,
          line: lineNum,
          pattern,
          match: match[0].substring(0, 50),
        });
      }
    }
  }

  // Rapport
  console.log('\n AUDIT PATTERNS DANGEREUX\n');
  console.log('='.repeat(80));

  const bySeverity = {
    CRITICAL: findings.filter(f => f.pattern.severity === 'CRITICAL'),
    HIGH: findings.filter(f => f.pattern.severity === 'HIGH'),
    MEDIUM: findings.filter(f => f.pattern.severity === 'MEDIUM'),
    LOW: findings.filter(f => f.pattern.severity === 'LOW'),
  };

  for (const [severity, items] of Object.entries(bySeverity)) {
    if (items.length > 0) {
      console.log(`\n ${severity} (${items.length})`);
      for (const item of items) {
        console.log(`  ${item.file}:${item.line}`);
        console.log(`     ${item.pattern.description}`);
        console.log(`     CWE: ${item.pattern.cwe}`);
        console.log(`     Match: ${item.match}...`);
      }
    }
  }

  console.log('\n' + '='.repeat(80));
  console.log(`Total: ${findings.length} issues found`);
  console.log(`  CRITICAL: ${bySeverity.CRITICAL.length}`);
  console.log(`  HIGH: ${bySeverity.HIGH.length}`);
  console.log(`  MEDIUM: ${bySeverity.MEDIUM.length}`);
  console.log(`  LOW: ${bySeverity.LOW.length}`);

  // Exit code non-zero si problemes critiques
  if (bySeverity.CRITICAL.length > 0) {
    process.exit(1);
  }
}

// Usage: npx ts-node scripts/audit-dangerous-patterns.ts ./src
auditDangerousPatterns(process.argv[2] || './src');
```

---

## Configuration ESLint Security

```javascript
// .eslintrc.js - Regles de securite
module.exports = {
  plugins: ['security', 'no-secrets'],
  extends: ['plugin:security/recommended'],
  rules: {
    // Bloquer eval et equivalents
    'no-eval': 'error',
    'no-implied-eval': 'error',
    'no-new-func': 'error',

    // Security plugin
    'security/detect-eval-with-expression': 'error',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-non-literal-require': 'warn',
    'security/detect-object-injection': 'warn',
    'security/detect-possible-timing-attacks': 'warn',
    'security/detect-child-process': 'warn',
    'security/detect-unsafe-regex': 'error',

    // No secrets
    'no-secrets/no-secrets': ['error', { tolerance: 4.5 }],

    // Console
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
  },
};
```

---

## Patterns par Categorie

### Code Execution (CWE-94, CWE-95, CWE-78)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `eval()` | CRITICAL | Code injection |
| `new Function()` | CRITICAL | Dynamic code execution |
| `child_process.exec()` | HIGH | Command injection |
| `vm.runInContext()` | HIGH | Sandbox escape |

### XSS (CWE-79)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `.innerHTML =` | HIGH | DOM manipulation |
| `document.write()` | HIGH | Document injection |
| `dangerouslySetInnerHTML` | MEDIUM | React unsafe |

### SQL Injection (CWE-89)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `$queryRaw\`...\${` | CRITICAL | Prisma raw query |
| `$executeRaw\`...\${` | CRITICAL | Prisma raw execute |

### Secrets (CWE-798, CWE-321)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `api_key = "..."` | CRITICAL | Hardcoded API key |
| `-----BEGIN PRIVATE KEY-----` | CRITICAL | Private key |
| `eyJ...` (JWT) | HIGH | Hardcoded token |

### Path Traversal (CWE-22)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `path.join(...req.body)` | HIGH | User input in path |

### Prototype Pollution (CWE-1321)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `JSON.parse(req.body)` | MEDIUM | Direct parse |

### ReDoS (CWE-1333)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `new RegExp(req.query)` | MEDIUM | User input in regex |

---

## Integration CI/CD

```yaml
# .github/workflows/security-scan.yml
name: Security Patterns Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'

      - name: Install dependencies
        run: npm ci

      - name: Run security patterns audit
        run: npx ts-node scripts/audit-dangerous-patterns.ts ./src

      - name: Run ESLint security
        run: npx eslint --ext .ts,.tsx src/ --rule 'security/*: error'
```

---

## References

- [CWE Database](https://cwe.mitre.org/)
- [ESLint Security Plugin](https://github.com/eslint-community/eslint-plugin-security)
- [OWASP Code Review Guide](https://owasp.org/www-project-code-review-guide/)
