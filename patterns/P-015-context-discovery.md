# P-015: Context Discovery Protocol

> **Pattern**: Phase 0 obligatoire avant toute implémentation
> **Usage**: Developer Agent - AVANT de coder

---

## Principe

**OBLIGATOIRE avant toute implémentation. Ne JAMAIS sauter cette phase.**

Le Context Discovery garantit que le développeur comprend:
1. L'existant (code, patterns, conventions)
2. Les erreurs passées (Error Journal)
3. Les dépendances et risques

---

## Protocol

```
┌─────────────────────────────────────────────────────────────────┐
│                 CONTEXT DISCOVERY PROTOCOL                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ÉTAPE 0: CONSULTER LE ERROR JOURNAL                            │
│  □ Lire .harmony/local/memory/error-journal.json                       │
│  □ Filtrer par module: quick_lookup.by_module[module]           │
│  □ EXTRAIRE les prevention_rules applicables                    │
│  □ NOTER les validation_checklist[] à appliquer                 │
│                                                                  │
│  ÉTAPE 1: COMPRENDRE L'ARCHITECTURE DU MODULE                   │
│  □ Lire la story file complètement                              │
│  □ Lire le fichier UCV associé                                  │
│  □ Lire le code existant dans le module                         │
│     ├── *.controller.ts (endpoints, guards, decorators)         │
│     ├── *.service.ts (logique métier, patterns)                 │
│     ├── dto/*.dto.ts (validations, types)                       │
│     └── *.spec.ts (patterns de test)                            │
│                                                                  │
│  ÉTAPE 2: IDENTIFIER LES PATTERNS ÉTABLIS                       │
│  □ Comment sont nommés les endpoints?                           │
│  □ Quelle structure de DTO?                                     │
│  □ Comment est gérée la pagination?                             │
│  □ Quels guards sont utilisés?                                  │
│  □ Comment sont structurés les tests?                           │
│                                                                  │
│  ÉTAPE 3: MAPPER LES DÉPENDANCES                                │
│  □ Quels autres modules sont importés?                          │
│  □ Quelles entités sont utilisées?                              │
│  □ Y a-t-il des services partagés?                              │
│                                                                  │
│  ÉTAPE 4: SYNTHÉTISER                                           │
│  → Documenter les patterns identifiés                           │
│  → Lister les fichiers qui seront impactés                      │
│  → Identifier les risques potentiels                            │
│  → RAPPELER les erreurs passées du Error Journal                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Format de Sortie

```markdown
## Context Discovery - [Module]

### Error Journal Check
| ID | Erreur Passée | Règle de Prévention |
|----|---------------|---------------------|
| ERR-XXX | [titre] | [prevention_rule] |

### Architecture Existante
| Fichier | Lignes | Patterns Identifiés |
|---------|--------|---------------------|
| xxx.controller.ts | XXX | [guards, decorators...] |
| xxx.service.ts | XXX | [méthodes, patterns...] |

### Patterns à Suivre
- **Endpoints**: [convention]
- **DTOs**: [structure]
- **Guards**: [liste]
- **Pagination**: [pattern]

### Fichiers à Impacter
1. [fichier1] - [modification]
2. [fichier2] - [modification]

### Risques Identifiés
- [risque potentiel]
- [erreur passée à éviter]

### Ready to Implement
[Confirmer contexte compris]
```

---

## Intégration

- **Pattern parent**: P-014 (ReAct V3 Developer)
- **Phase**: 0 (avant REASON)
- **Durée**: 2-5 minutes
- **Output**: Synthèse documentée
