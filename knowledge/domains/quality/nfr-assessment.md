---
name: nfr-assessment
displayName: "NFR Assessment"
description: "Non-Functional Requirements assessment patterns"
version: "1.0"
auto_invoke: true
activate_when:
  keywords:
    - "nfr"
    - "non-functional"
    - "performance audit"
    - "security audit"
    - "quality gate"
    - "release readiness"
agents:
  - performance
  - security
  - tester
---

# NFR Assessment Patterns

> Assess Non-Functional Requirements before release with evidence-based validation

## NFR Categories

| Category | What to Assess | Key Metrics |
|----------|----------------|-------------|
| **Performance** | Response time, throughput, resources | P50/P95/P99 latency, RPS, CPU/Memory |
| **Security** | Auth, data protection, vulnerabilities | OWASP compliance, CVE count, encryption |
| **Reliability** | Error handling, recovery, availability | Error rate, MTTR, uptime % |
| **Maintainability** | Code quality, test coverage, tech debt | Coverage %, complexity, lint errors |

---

## Assessment Rules (PASS/CONCERNS/FAIL)

### PASS Criteria

- All evidence available AND
- All thresholds met (or exceeded) AND
- No blocking issues AND
- All mandatory checks completed

### CONCERNS Criteria

- Evidence exists BUT
- Some thresholds not met OR
- Minor gaps exist OR
- Thresholds undefined (never guess)

### FAIL Criteria

- Missing mandatory evidence OR
- Critical thresholds breached OR
- Blocking security issues OR
- No test coverage for critical paths

---

## Performance Assessment

### Thresholds

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| **API P95 latency** | < 200ms | < 500ms | > 1000ms |
| **Page load (LCP)** | < 2.5s | < 4.0s | > 4.0s |
| **Time to Interactive** | < 3.8s | < 7.3s | > 7.3s |
| **Error rate** | < 0.1% | < 1% | > 5% |
| **CPU usage** | < 70% | < 85% | > 95% |
| **Memory usage** | < 70% | < 85% | > 95% |

### Evidence Sources

- Load test results (k6, JMeter, Artillery)
- APM metrics (New Relic, Datadog)
- Lighthouse reports
- Core Web Vitals

---

## Security Assessment

### Checklist

| Check | Evidence | Status |
|-------|----------|--------|
| SAST scan clean | SonarQube report | ✅/❌ |
| DAST scan clean | OWASP ZAP report | ✅/❌ |
| Dependencies audit | npm audit / Snyk | ✅/❌ |
| Auth tested | Penetration test | ✅/❌ |
| Secrets scan | GitLeaks / TruffleHog | ✅/❌ |
| HTTPS enforced | SSL Labs | ✅/❌ |

### Critical Blockers (Auto-FAIL)

- Known CVE with CVSS > 7.0
- Hardcoded credentials
- SQL injection vulnerability
- XSS vulnerability
- Missing authentication on sensitive endpoints

---

## Reliability Assessment

### Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Availability** | 99.9% | Uptime monitoring |
| **Error rate** | < 0.1% | APM / Logs |
| **MTTR** | < 1 hour | Incident history |
| **Recovery** | Auto-heal | Chaos testing |

### Evidence Sources

- CI burn-in results (10+ iterations stable)
- Error logs analysis
- Chaos engineering results
- Failover test results

---

## Maintainability Assessment

### Code Quality

| Metric | Target | Tool |
|--------|--------|------|
| **Test coverage** | > 80% | Istanbul/NYC |
| **Lint errors** | 0 | ESLint |
| **Type coverage** | > 90% | TypeScript |
| **Complexity** | < 10 per function | SonarQube |
| **Duplication** | < 3% | SonarQube |

### Documentation

- [ ] API documented (OpenAPI/Swagger)
- [ ] README up-to-date
- [ ] Architecture decisions recorded (ADR)
- [ ] Runbooks for operations

---

## Gate Decision Matrix

```
┌───────────────────────────────────────────────────────────────┐
│                    GATE DECISION                               │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  All evidence + All thresholds met     → PASS ✅              │
│                                                                │
│  Evidence exists + Minor gaps          → CONCERNS ⚠️          │
│  (Document gaps, plan remediation)                             │
│                                                                │
│  Missing evidence OR Critical breach   → FAIL ❌              │
│  (Block release until resolved)                                │
│                                                                │
│  Business-approved exception           → WAIVED 📋            │
│  (Documented risk acceptance)                                  │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

---

## Report Template

```markdown
# NFR Assessment Report

**Date:** YYYY-MM-DD
**Version:** X.Y.Z
**Evaluator:** [Name]

## Summary

| Category | Status | Score |
|----------|--------|-------|
| Performance | ✅ PASS | 92/100 |
| Security | ⚠️ CONCERNS | 78/100 |
| Reliability | ✅ PASS | 95/100 |
| Maintainability | ✅ PASS | 88/100 |

**Overall:** CONCERNS (requires remediation plan)

## Details

[See NFR Report Template](../../templates/quality/nfr-report.md)
```

---

## See Also

- [NFR Report Template](../../templates/quality/nfr-report.md)
- [Core Web Vitals](core-web-vitals.md)
- [E2E Security RGPD](e2e-security-rgpd.md)
