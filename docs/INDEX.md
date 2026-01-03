# Harmony Framework Documentation

> Documentation complete du framework Harmony pour le developpement assiste par IA.

---

## Navigation Rapide

| Section | Description |
|---------|-------------|
| [INDEX-REFERENCE](INDEX-REFERENCE.md) | **Reference rapide** (agents, commandes, HQVF) |
| [Getting Started](getting-started.md) | Guide de demarrage rapide |
| [Installation](installation.md) | Installation et configuration |
| [Concepts](concepts.md) | Concepts fondamentaux |
| [Architecture](architecture.md) | Architecture technique |

---

## Guides

### Pour Commencer

- [Getting Started](getting-started.md) - Premier pas avec Harmony
- [Installation](installation.md) - Installation complete
- [Concepts](concepts.md) - Comprendre les concepts cles

### Reference Technique

- [Architecture](architecture.md) - Architecture du framework
- [Working Memory](working-memory.md) - Systeme de memoire
- [Overrides](overrides.md) - Personnalisation et surcharges
- [Evolution](evolution.md) - Roadmap et evolution

### Guidelines

- [Documentation Guidelines](DOCUMENTATION-GUIDELINES.md) - Standards de documentation
- [README Technique](README-technical.md) - Details techniques

---

## Bibliotheques

### Patterns

> Bibliotheque de patterns pour la detection automatique et resolution rapide des problemes.

**[Acceder aux Patterns →](../patterns/INDEX.md)**

Inclut:
- 11 patterns documentes
- 7 patterns auto-detectables par Sentinel
- Case studies avec benchmarks ROI

### Agents

> Agents specialises pour differents roles de developpement.

**Core Agents:**
- [Harmony Agent](../agents/harmony.md) - Agent principal
- [Developer Agent](../agents/developer.md) - Agent developpeur
- [Guardian Agent](../agents/guardian.md) - Protection et validation
- [Sentinel Agent](../agents/sentinel.md) - Memoire et apprentissage

**Specialists:**
- [UCV QA](../agents/specialists/ucv-qa.md) - Validation UCV en browser
- [UCV Writer](../agents/specialists/ucv-writer.md) - Creation UCVs
- [UCV Validator](../agents/specialists/ucv-validator.md) - Verification 100%
- [Exploratory QA](../agents/specialists/exploratory-qa.md) - QA exploratoire

**Compliance:**
- [Accessibility](../agents/compliance/accessibility.md) - WCAG/RGAA/EAA
- [Security](../agents/compliance/security.md) - Audit securite
- [RGPD](../agents/compliance/rgpd.md) - Conformite GDPR

### Workflows

> Workflows pre-definis pour les taches courantes.

- Voir le dossier [workflows/](../workflows/)

### Routing

> Detection, routage et orchestration des agents.

- [Routing README](../routing/README.md) - Vue d'ensemble
- [Routing INDEX](../routing/INDEX.md) - Reference rapide
- [Detection Patterns](../routing/detection-patterns.yaml) - Keywords et scores
- [Routing Algorithm](../routing/routing-algorithm.yaml) - Algorithme de scoring

---

## Architecture Globale

```
harmony-framework/
├── README.md              ← Vous etes ici (via lien)
├── docs/
│   ├── INDEX.md           ← Point d'entree documentation
│   ├── INDEX-REFERENCE.md ← Reference rapide
│   ├── getting-started.md
│   ├── installation.md
│   ├── concepts.md
│   ├── architecture.md
│   └── ...
├── patterns/
│   ├── INDEX.md           ← Bibliotheque de patterns
│   ├── case-studies/      ← Exemples concrets
│   └── P-XXX-*.md         ← Documentation patterns
├── agents/
│   ├── INDEX.md           ← Index des agents
│   ├── specialists/       ← UCV QA, Exploratory QA
│   └── compliance/        ← Accessibility, Security, RGPD
├── routing/               ← Detection et routage agents
│   ├── INDEX.md
│   ├── detection-patterns.yaml
│   └── routing-algorithm.yaml
├── workflows/             ← Workflows pre-definis
├── hooks/                 ← Hooks Sentinel
└── profiles/              ← Profils de langage
```

---

## Liens Externes

- [GitHub Repository](https://github.com/harmony-ai/harmony-framework)
- [Issues & Support](https://github.com/harmony-ai/harmony-framework/issues)

---

## Changelog

Voir [CHANGELOG.md](../CHANGELOG.md) pour l'historique des versions.
