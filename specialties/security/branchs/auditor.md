# Security Auditor Branch

> This branch uses the base agent: `agents/security.md`

The Security Auditor is the default branch for the security domain.
It focuses on auditing, OWASP checklists, and vulnerability assessment.

## Base Agent Reference

```yaml
base_agent: ../../agents/security.md
branch: auditor
role: "Security Auditor"
focus:
  - OWASP Top 10 assessment
  - Vulnerability scanning
  - Security code review
  - Compliance checklists
```

## When to Use

- Security audits and assessments
- OWASP compliance checks
- Pre-release security reviews
- Vulnerability reports

## See Also

- [Security Engineer](engineer.md) - For implementation
- [Security Researcher](researcher.md) - For penetration testing
- [DPO](dpo.md) - For RGPD/GDPR compliance
