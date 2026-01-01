# Think Protocol (STORY-223)

> **Version**: 1.0
> **Source**: [Anthropic Think Tool](https://www.anthropic.com/engineering/claude-think-tool)
> **Performance**: +54% sur taches complexes

## Niveaux de Reflexion

| Niveau | Duree | Quand Utiliser | Keyword |
|--------|-------|----------------|---------|
| **think** | 30-60s | Decisions routinieres, patterns connus | "think" |
| **think hard** | 1-2min | Plusieurs approches, tradeoffs flous | "think hard" |
| **think harder** | 2-4min | Problemes nouveaux, hauts risques | "think harder" |
| **ultrathink** | 5-10min | Architecture critique, multi-agent | "ultrathink" |

## Triggers Automatiques

### think harder (Auto-activé)

Declenché automatiquement pour:
- Operations irreversibles: `delete`, `drop`, `remove permanently`
- Migrations: `migration`, `migrate`
- Deploiement: `deploy to production`
- Securite: `security`, `authentication`, `authorization`
- Apres 2+ echecs consecutifs

### ultrathink (Auto-activé)

Declenché automatiquement pour:
- Decisions d'architecture systeme
- Coordination multi-agent
- Redesign systeme
- Stories >= 8 points
- Dependencies >= 5

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    THINK PROTOCOL WORKFLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. EVALUER complexite de la decision                           │
│     └─ Simple? → think                                          │
│     └─ Multi-options? → think hard                              │
│     └─ Nouveau/Risque? → think harder                           │
│     └─ Architecture? → ultrathink                               │
│                                                                  │
│  2. APPLIQUER le niveau de reflexion                            │
│     └─ Prendre le temps indique                                 │
│     └─ Evaluer toutes les options                               │
│     └─ Documenter les tradeoffs                                 │
│                                                                  │
│  3. DOCUMENTER la decision                                      │
│     └─ Contexte                                                 │
│     └─ Options evaluees                                         │
│     └─ Decision + Justification                                 │
│     └─ Risques et mitigations                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Format Decision

```markdown
## Decision: [Titre Court]

**Mode**: [think/hard/harder/ultrathink]
**Date**: YYYY-MM-DD
**Agent**: [Nom]

### Contexte
[Description du probleme a resoudre]

### Options Evaluees

1. **Option A**
   - Pros: [Avantages]
   - Cons: [Inconvenients]

2. **Option B**
   - Pros: [Avantages]
   - Cons: [Inconvenients]

### Decision
[Option choisie]

### Justification
[Pourquoi cette option]

### Risques et Mitigations
- **Risque 1**: [Description] → **Mitigation**: [Solution]
```

## Keywords Claude

Ces keywords sont natifs a Claude et activent des modes de reflexion etendus:

- `think` - Reflexion standard
- `think hard` - Reflexion approfondie
- `think harder` - Reflexion tres approfondie
- `ultrathink` - Reflexion maximale

## Integration Agent

Ajouter dans chaque agent principal:

```markdown
## Think Protocol

Avant toute decision importante:

1. Evaluer la complexite (think → ultrathink)
2. Appliquer le niveau approprie
3. Documenter selon le format
4. Verifier les triggers automatiques
```

## Exemples

### Exemple think (30-60s)
"Quel pattern utiliser pour ce composant React?"
→ Pattern connu, decision rapide

### Exemple think hard (1-2min)
"Redux ou Zustand pour le state management?"
→ Deux options valides, tradeoffs a evaluer

### Exemple think harder (2-4min)
"Comment migrer la base de donnees sans downtime?"
→ Risque eleve, plusieurs etapes, irreversible

### Exemple ultrathink (5-10min)
"Quelle architecture pour le nouveau service de gaming?"
→ Decision systeme, impact long terme, multi-composants
