# 🔄 Module Cognitif : Reflection (Auto-évaluation)

**Version :** 1.0
**Type :** Module cognitif transversal

---

## Description

Le pattern Reflection permet aux agents de s'auto-évaluer et d'améliorer leurs résultats de manière itérative. Inspiré de Reflexion, ce module augmente significativement la qualité des outputs.

**Impact mesuré :** +11% de succès sur les benchmarks de code (91% vs 80% pour GPT-4)

---

## Boucle de Réflexion

```
┌─────────────────────────────────────────────────────────────────┐
│                     BOUCLE REFLECTION                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 1. PRODUCTION                                            │    │
│  │    Agent produit un résultat initial                     │    │
│  │    (code, documentation, architecture, etc.)             │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 2. AUTO-ÉVALUATION                                       │    │
│  │    Agent évalue son propre résultat selon critères :     │    │
│  │    • Correctness : Est-ce correct ?                      │    │
│  │    • Completeness : Est-ce complet ?                     │    │
│  │    • Quality : Respecte les patterns ?                   │    │
│  │    • Security : Pas de failles ?                         │    │
│  │    • Performance : Optimal ?                             │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 3. CRITIQUE                                              │    │
│  │    Identification des problèmes :                        │    │
│  │    • "Le guard SchoolGuard est manquant"                │    │
│  │    • "La pagination n'est pas limitée à 50"             │    │
│  │    • "Pas de validation sur l'input email"              │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                     │
│                   Problèmes trouvés ?                            │
│                      /          \                                │
│                   OUI            NON                             │
│                    ↓              ↓                              │
│  ┌─────────────────────────┐  ┌─────────────────────────┐       │
│  │ 4. CORRECTION           │  │ 5. VALIDATION           │       │
│  │    Appliquer les fixes  │  │    Résultat final OK    │       │
│  │    Retour à étape 2     │  │    Prêt pour livraison  │       │
│  └─────────────────────────┘  └─────────────────────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Grilles d'Évaluation par Agent

### Developer Agent - Checklist Reflection

```markdown
## Auto-évaluation Code

### Correctness (0-10)
- [ ] Le code compile sans erreurs
- [ ] Les types TypeScript sont corrects
- [ ] La logique métier est implémentée

### Security (0-10)
- [ ] Guards appliqués (JWT, Roles, School)
- [ ] Validation des inputs (DTOs)
- [ ] Pas d'injection possible
- [ ] SchoolGuard pour isolation

### Quality (0-10)
- [ ] Respect des patterns projet
- [ ] Naming conventions suivies
- [ ] Pas de code dupliqué
- [ ] Fonctions < 50 lignes

### Performance (0-10)
- [ ] Pas de N+1 queries
- [ ] Pagination limitée à 50
- [ ] Async/await correct

### Score Total: X/40
### Seuil d'acceptation: 32/40 (80%)
```

### Architect Agent - Checklist Reflection

```markdown
## Auto-évaluation Architecture

### Completeness (0-10)
- [ ] Tous les composants identifiés
- [ ] Relations clairement définies
- [ ] Flux de données documentés

### Consistency (0-10)
- [ ] Cohérent avec architecture existante
- [ ] Patterns réutilisés
- [ ] Naming cohérent

### Scalability (0-10)
- [ ] Design scalable
- [ ] Pas de goulots d'étranglement
- [ ] Cache strategy si nécessaire

### Security (0-10)
- [ ] Guards identifiés
- [ ] SchoolGuard planifié
- [ ] RBAC défini

### Score Total: X/40
### Seuil d'acceptation: 32/40 (80%)
```

### Test Agent - Checklist Reflection

```markdown
## Auto-évaluation Tests

### Coverage (0-10)
- [ ] Cas nominal couvert
- [ ] Cas d'erreur couverts
- [ ] Edge cases identifiés

### Security Tests (0-10)
- [ ] Test 401 sans token
- [ ] Test 403 mauvais rôle
- [ ] Test isolation école

### Quality (0-10)
- [ ] Tests indépendants
- [ ] Setup/teardown propre
- [ ] Assertions claires

### Maintainability (0-10)
- [ ] Tests lisibles
- [ ] Pas de duplication
- [ ] Factories/helpers utilisés

### Score Total: X/40
### Seuil d'acceptation: 32/40 (80%)
```

---

## Format de Trace Reflection

```json
{
  "task_id": "TASK-001",
  "agent": "developer-agent",
  "reflection_trace": {
    "iterations": [
      {
        "iteration": 1,
        "production": "Controller généré avec 3 endpoints",
        "evaluation": {
          "correctness": 8,
          "security": 6,
          "quality": 7,
          "performance": 8,
          "total": 29
        },
        "critique": [
          "SchoolGuard manquant sur endpoint GET :id",
          "DTO sans validation @IsUUID sur schoolId"
        ],
        "action": "correction"
      },
      {
        "iteration": 2,
        "production": "Controller corrigé avec Guards et DTOs",
        "evaluation": {
          "correctness": 9,
          "security": 9,
          "quality": 8,
          "performance": 8,
          "total": 34
        },
        "critique": [],
        "action": "validated"
      }
    ],
    "final_score": 34,
    "iterations_count": 2,
    "improvements": [
      "Ajout SchoolGuard",
      "Ajout @IsUUID validation"
    ]
  }
}
```

---

## Pattern Maker-Checker

Pour les tâches critiques, utiliser deux agents :

```
┌─────────────────────────────────────────────────────────────────┐
│                     MAKER-CHECKER PATTERN                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────┐                    ┌─────────────┐            │
│   │    MAKER    │                    │   CHECKER   │            │
│   │             │                    │             │            │
│   │ Developer   │  ──── Produit ──→  │ Code Review │            │
│   │   Agent     │                    │   Agent     │            │
│   │             │  ←── Critique ───  │             │            │
│   └─────────────┘                    └─────────────┘            │
│         │                                   │                    │
│         ↓                                   ↓                    │
│   ┌─────────────┐                    ┌─────────────┐            │
│   │  Corrige    │                    │  Re-évalue  │            │
│   │  si besoin  │                    │  si corrigé │            │
│   └─────────────┘                    └─────────────┘            │
│                                                                  │
│   Boucle jusqu'à validation ou escalade humaine                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Cas d'utilisation
- **Code critique** : Developer + Code Review
- **Architecture** : Architect + Security
- **Database** : Database + Architect
- **Security** : Security + externe (humain)

---

## Règles d'Application

### 1. Seuils de qualité
- Score minimum : 80% (32/40)
- Si < 80% après 3 itérations → escalade humaine

### 2. Limite d'itérations
- Maximum 3 itérations de reflection
- Évite les boucles infinies

### 3. Traçabilité
- Chaque iteration loggée
- Critique et améliorations documentées

### 4. Apprentissage
- Erreurs récurrentes ajoutées aux anti-patterns
- Améliorations ajoutées aux patterns

---

## Intégration Mémoire

Après chaque reflection réussie :

```json
// Ajout à learned-patterns.json
{
  "pattern_learned": {
    "date": "2025-11-27",
    "agent": "developer-agent",
    "context": "Controller creation",
    "lesson": "Toujours vérifier SchoolGuard sur endpoints avec :id",
    "prevention": "Checklist reflection mise à jour"
  }
}
```

---

## Références

- [Reflexion: Language Agents with Verbal Reinforcement Learning](https://arxiv.org/abs/2303.11366)
- [How Do Agents Learn from Their Own Mistakes?](https://huggingface.co/blog/Kseniase/reflection)

---

**Dernière mise à jour :** 2025-11-27
