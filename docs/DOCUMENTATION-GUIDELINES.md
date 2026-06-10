# Harmony Documentation Guidelines

> **🌐 Language:** English · [Français](fr/DOCUMENTATION-GUIDELINES.md)

## Rules for Examples

### Professional Secrecy

> **ABSOLUTE RULE**: NEVER use the user's project context in documentation examples.

| Forbidden | Allowed |
|-----------|---------|
| The user's real project | Generic examples |
| Client project names | "fashion-store", "my-app" |
| Specific business context | E-commerce, SaaS, Blog |
| Real data | Fictitious data |

### Allowed Example Contexts

Use these generic contexts for examples:

| Context | Description | Example Name |
|---------|-------------|--------------|
| e-commerce | Online store | "fashion-store", "tech-shop" |
| saas | SaaS application | "project-manager", "crm-app" |
| blog | Blog/CMS | "my-blog", "news-portal" |
| social | Social network | "social-app", "community" |
| fintech | Financial application | "expense-tracker", "budget-app" |
| health | Health application | "fitness-app", "wellness" |

### Fictitious Data

Always use fictitious data:

```yaml
# GOOD
project:
  name: "fashion-store"
  domain: "e-commerce"

# BAD - real project
project:
  name: "client-project"  # Forbidden!
  domain: "confidential"
```

### Personal Names

Use generic first names:
- Alex, Jordan, Security Agent, Taylor (neutral)
- Marie, Jean, Pierre (French)
- John, Jane, Scrum Master (English)

## Rationale

1. **Confidentiality**: User projects are confidential
2. **Neutrality**: Examples must be universal
3. **Reusability**: Documentation usable by everyone
4. **Professionalism**: Respecting professional secrecy

## Verification

Before publishing documentation:

```
□ No real project name
□ No specific client business context
□ 100% fictitious data
□ Generic personal names
```
