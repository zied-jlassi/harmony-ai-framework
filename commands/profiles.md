# Harmony Profiles - Tech Stack Management

> List and activate technology profiles for your project.

---

## What Are Profiles?

Profiles define **HOW** to build (technical knowledge):
- Languages: JavaScript, TypeScript, Python
- Runtimes: Node.js, Deno, Bun
- Frameworks: NestJS, Angular, React, Django
- Databases: PostgreSQL, MongoDB, Redis
- Tools: Prisma, GraphQL, Docker

---

## Commands

### List All Profiles

```bash
harmony profiles
```

### Show Active Profiles

```bash
harmony profiles --active
```

### Activate Profile

```bash
harmony profiles --add nestjs
```

### Deactivate Profile

```bash
harmony profiles --remove nestjs
```

---

## Profile Hierarchy

```
Level 0: Languages
├── javascript
└── typescript

Level 1: Runtimes
├── nodejs (requires: javascript)
├── deno (requires: typescript)
└── bun (requires: javascript)

Level 2: Frameworks
├── nestjs (requires: typescript, nodejs)
├── angular (requires: typescript)
├── react (requires: javascript)
└── django (requires: python)

Level 3: Meta/Tools
├── prisma (requires: typescript)
├── graphql
└── docker
```

---

## Dependency Resolution

When you activate `nestjs`:

```
nestjs (L2)
├── typescript (L0) ← auto-loaded
│   └── javascript (L0) ← auto-loaded
└── nodejs (L1) ← auto-loaded
    └── javascript (L0) ← already loaded
```

**Loading order:** javascript → typescript → nodejs → nestjs

---

## Available Profiles

| Category | Profiles |
|----------|----------|
| **Languages** | javascript, typescript, python, go, rust, java |
| **Runtimes** | nodejs, deno, bun, dotnet, jvm |
| **Backend** | nestjs, express, fastify, django, flask |
| **Frontend** | angular, react, vue, svelte, solid |
| **Databases** | postgresql, mongodb, redis, mysql, sqlite |
| **Styling** | tailwind, bootstrap, sass, css |
| **Tools** | prisma, graphql, docker, kubernetes |

---

## Profile Structure

```
profiles/
├── profiles-registry.yaml    # Master index
├── languages/
│   ├── javascript/
│   │   ├── manifest.yaml
│   │   └── knowledge/
│   │       ├── async.md
│   │       ├── modules.md
│   │       └── errors.md
│   └── typescript/
│       ├── manifest.yaml
│       └── knowledge/
│           ├── types.md
│           ├── generics.md
│           └── decorators.md
└── backend/
    └── nestjs/
        ├── manifest.yaml
        └── knowledge/
            ├── modules.md
            ├── controllers.md
            ├── providers.md
            └── guards.md
```

---

## See Also

- [Specialties](specialties.md) - Domain expertise
- [Learn](learn.md) - Enrich profiles
