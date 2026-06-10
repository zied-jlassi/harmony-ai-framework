# Harmony Specialties - Domain Expertise

> List and activate domain-specific specialties for your project.

---

## What Are Specialties?

Specialties define **WHAT** you're building (domain knowledge):
- Gaming: Game mechanics, leaderboards, achievements
- Security: Pentesting, OWASP, RGPD
- AI: RAG, LLMs, embeddings
- DevOps: CI/CD, Kubernetes, deployment
- Quality: Testing, performance, accessibility

---

## Commands

### List All Specialties

```bash
harmony specialties
```

### Show Active Specialties

```bash
harmony specialties --active
```

### Activate Specialty

```bash
harmony specialties --add gaming
```

### Deactivate Specialty

```bash
harmony specialties --remove gaming
```

---

## Available Specialties

| Specialty | Description | Agents | Knowledge |
|-----------|-------------|--------|-----------|
| **gaming** | Game development | game-designer, game-architect, game-developer, game-sm | godot, unity |
| **security** | Security & pentesting | security, pentest, rgpd | owasp, pentest-patterns |
| **ai** | AI/ML integration | - | rag, langchain, prompts |
| **quality** | Testing & QA | lint, performance, dependency | playwright, core-web-vitals |
| **devops** | Infrastructure | devops, builder | kubernetes, ansible, github-actions |
| **compliance** | Legal & regulatory | legal | - |
| **creative** | Design & UX | brainstorm, design-thinking, ux-storyteller | - |
| **i18n** | Internationalization | i18n | - |
| **mobile** | Mobile development | mobile | - |
| **accessibility** | A11y & WCAG | accessibility | - |

---

## Specialty Structure

```
specialties/
├── specialties-registry.yaml     # Master index
├── gaming/
│   ├── manifest.yaml
│   ├── agents/
│   │   ├── game-designer.md
│   │   ├── game-architect.md
│   │   ├── game-developer.md
│   │   └── game-sm.md
│   └── knowledge/
│       ├── godot-gdscript-patterns.md
│       └── unity-ecs-patterns.md
├── security/
│   ├── manifest.yaml
│   ├── agents/
│   │   ├── security.md
│   │   ├── pentest.md
│   │   └── rgpd.md
│   ├── modules/
│   │   ├── pentest-web.md
│   │   └── pentest-crypto.md
│   └── knowledge/
│       ├── owasp-top10.md
│       ├── owasp-checklists.md
│       └── pentest-patterns.md
└── ai/
    ├── manifest.yaml
    └── knowledge/
        ├── rag-implementation.md
        ├── langchain-architecture.md
        └── prompt-engineering-patterns.md
```

---

## Output

```
HARMONY SPECIALTIES
───────────────────

Available specialties:

| Specialty | Status | Agents | Knowledge Files |
|-----------|--------|--------|-----------------|
| gaming | ✅ Active | 4 | 2 |
| security | ⚪ Inactive | 3 | 12 |
| ai | ⚪ Inactive | 0 | 3 |
| quality | ✅ Active | 3 | 4 |
| devops | ⚪ Inactive | 2 | 6 |
| compliance | ⚪ Inactive | 1 | 0 |
| creative | ⚪ Inactive | 6 | 0 |
| i18n | ⚪ Inactive | 1 | 0 |
| mobile | ⚪ Inactive | 1 | 0 |
| accessibility | ⚪ Inactive | 1 | 0 |

Active: gaming, quality
Total agents available: 22
Total knowledge files: 27
```

---

## Profiles vs Specialties

| Aspect | Profiles | Specialties |
|--------|----------|-------------|
| **Question** | HOW to build | WHAT to build |
| **Focus** | Technology | Domain |
| **Example** | NestJS, Angular | Gaming, Security |
| **Dependencies** | Hierarchical (L0-L3) | Independent |
| **Agents** | Code-focused | Domain-focused |

---

## Combining Profiles + Specialties

```
Project: Online Game Platform
├── Profiles: typescript, nestjs, angular, postgresql
└── Specialties: gaming, security

Available Agents:
├── From Profiles: developer, tester, architect
├── From Gaming: game-designer, game-architect, game-developer
└── From Security: security, pentest, rgpd
```

---

## Usage

```bash
/harmony specialties                  # 23 - Lister specialties
/harmony specialties --active         #    - Afficher actives
/harmony specialties --add <name>     #    - Activer specialty
/harmony specialties --remove <name>  #    - Desactiver specialty
```

---

## See Also

- [Profiles](profiles.md) - Technology stacks
- [Learn](learn.md) - Enrich knowledge
