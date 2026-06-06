# Harmony Patterns Library

> Bibliotheque de patterns pour la detection automatique et la resolution rapide des problemes courants.

---

## Vue d'ensemble

Les patterns Harmony permettent:
- **Detection proactive** des problemes potentiels AVANT qu'ils surviennent
- **Resolution instantanee** des erreurs courantes
- **Apprentissage continu** base sur l'experience du projet

---

## Catalogue des Patterns

### Cross-Platform & Compatibility

| ID | Pattern | Severite | Description |
|----|---------|----------|-------------|
| [P-011](P-011-bash-cross-platform.md) | Cross-Platform Guide | - | Guide complet compatibilite Linux/macOS/Windows |

### Architecture & Design

| ID | Pattern | Severite | Description |
|----|---------|----------|-------------|
| [P-001](P-001-hybrid-orchestration.md) | Hybrid Orchestration | - | Orchestration multi-agents |
| [P-002](P-002-three-tier-memory.md) | Three-Tier Memory | - | Architecture memoire 3 niveaux |
| [P-003](P-003-jit-context.md) | JIT Context | - | Chargement contexte a la demande |
| [P-004](P-004-circuit-breaker.md) | Circuit Breaker | - | Protection contre les echecs en cascade |
| [P-005](P-005-closed-loop.md) | Closed Loop | - | Boucle fermee d'amelioration |
| [P-006](P-006-intent-detection.md) | Intent Detection | - | Detection d'intention utilisateur |
| [P-007](P-007-story-based.md) | Story-Based Dev | - | Developpement base sur les stories |
| [P-008](P-008-ucv-gate.md) | UCV Gate | - | Verification Use Cases |
| [P-009](P-009-task-progress.md) | Task Progress | - | Suivi de progression des taches |
| [P-010](P-010-agent-announcement.md) | Agent Announcement | - | Annonce des agents |

---

## Patterns Registry (Auto-Detection)

Le fichier [patterns-registry.json](patterns-registry.json) contient les patterns detectables automatiquement par Sentinel:

### Bash Patterns

| ID | Nom | Severite | Declencheur |
|----|-----|----------|-------------|
| PAT-BASH-001 | set -e arithmetic | Critical | `((var++))` avec `set -e` |
| PAT-BASH-002 | sha256sum missing | High | `sha256sum` sur macOS |
| PAT-BASH-003 | readlink -f missing | High | `readlink -f` sur macOS |
| PAT-BASH-004 | sed -i syntax | Medium | `sed -i` sur macOS |
| PAT-BASH-005 | grep exit code | Medium | `grep` sans `|| true` |

### TypeScript/JavaScript Patterns

| ID | Nom | Severite | Declencheur |
|----|-----|----------|-------------|
| PAT-TS-001 | Path alias | High | `@/` non configure |

### NPM/Packaging Patterns

| ID | Nom | Severite | Declencheur |
|----|-----|----------|-------------|
| PAT-NPM-001 | Files array | High | Dossier manquant dans `files[]` |

---

## Case Studies

Exemples concrets demontrant le ROI des patterns Harmony:

| ID | Titre | Pattern | ROI |
|----|-------|---------|-----|
| [CS-001](case-studies/CS-001-bash-set-e-arithmetic.md) | Bug `((var++))` avec `set -e` | PAT-BASH-001 | **3500x** plus rapide |

---

## Profils de Langage

Les profils chargent automatiquement les patterns pertinents selon le contexte:

| Profil | Extensions | Patterns |
|--------|------------|----------|
| [Bash](../profiles/languages/bash/) | `.sh`, `.bash` | PAT-BASH-* |

---

## Comment Ajouter un Pattern

### 1. Documenter le pattern

Creer `patterns/P-XXX-nom-pattern.md`:
```markdown
# P-XXX: Nom du Pattern

## Overview
Description du probleme et de la solution.

## Bad
Code problematique.

## Good
Code corrige.
```

### 2. Ajouter au registry

Dans `patterns-registry.json`:
```json
{
  "id": "PAT-XXX-001",
  "name": "Nom du pattern",
  "triggers": ["mot-cle"],
  "error_patterns": ["regex erreur"],
  "quick_fix": {
    "description": "Description du fix",
    "suggestion": "Code de solution"
  },
  "severity": "critical|high|medium|low"
}
```

### 3. (Optionnel) Creer un case study

Si le pattern a un ROI significatif, documenter dans `case-studies/CS-XXX-*.md`.

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Patterns documentes | 11 |
| Patterns auto-detectables | 7 |
| Case studies | 1 |
| Temps moyen economise | 10 min/pattern |

---

## Navigation

- [Retour a la documentation](../docs/README-technical.md)
- [Architecture Harmony](../docs/architecture.md)
- [Guide d'installation](../docs/installation.md)
