# P-016: Error Journal Pattern

> **Pattern**: Apprentissage des erreurs pour ne pas les répéter
> **Usage**: Tous les agents, particulièrement Developer

---

## Principe (Pattern Reflexion)

Apprendre des erreurs passées pour ne pas les répéter.

---

## Lecture AVANT Développement

**OBLIGATOIRE avant chaque tâche:**

1. **LIRE** `.claude/memory/error-journal.json`
2. **FILTRER** par contexte actuel:
   - Par module: `quick_lookup.by_module[module]`
   - Par catégorie: `quick_lookup.by_category[type]`
   - Par tags: `quick_lookup.by_tag[keyword]`
3. **EXTRAIRE** les règles de prévention:
   - `prevention_rules_summary[].rule`
   - Chaque erreur a une `validation_checklist[]`
4. **APPLIQUER** les checklists AVANT de coder

---

## Écriture APRÈS Correction

**OBLIGATOIRE après chaque correction de bug:**

```json
{
  "id": "ERR-XXX",
  "date": "YYYY-MM-DD",
  "category": "[typescript|architecture|pagination|security|rgpd|accessibility|...]",
  "severity": "[critical|high|medium|low]",
  "title": "Description courte",
  "context": {
    "module": "nom_module",
    "file": "fichier.ts",
    "function": "nomFonction",
    "story": "STORY-XXX"
  },
  "symptom": "Ce qui s'est passé (observable)",
  "root_cause": "Pourquoi c'est arrivé (cause racine)",
  "wrong_approach": "Ce qu'il ne faut PAS faire",
  "correct_solution": "La bonne solution appliquée",
  "prevention_rule": "Règle pour éviter à l'avenir",
  "validation_checklist": ["check1", "check2"],
  "tags": ["tag1", "tag2"]
}
```

---

## Catégories d'Erreurs

| Catégorie | Description | Exemples |
|-----------|-------------|----------|
| `typescript` | Erreurs TypeScript | `any`, types manquants |
| `architecture` | Violations Clean Architecture | hooks dans services |
| `pagination` | Erreurs de pagination | limit > 50 |
| `security` | Failles sécurité | guards manquants, injection |
| `rgpd` | Violations RGPD/GDPR | données personnelles exposées, consentement manquant, rétention non conforme |
| `accessibility` | Problèmes a11y WCAG | ARIA manquants, contraste insuffisant, navigation clavier cassée |
| `api` | Erreurs API | endpoints, DTOs |
| `database` | Erreurs DB | N+1 queries |
| `react` | Erreurs React | hooks, state |
| `testing` | Erreurs de tests | coverage |

---

## Checklist RGPD

| Vérification | Description |
|--------------|-------------|
| Minimisation des données | Ne collecter que le nécessaire |
| Consentement | Obtenir avant traitement |
| Droit à l'oubli | Permettre suppression |
| Portabilité | Export des données |
| Logs d'accès | Tracer qui accède aux données |
| Encryption | Chiffrer données sensibles |
| Rétention | Durée de conservation définie |

---

## Checklist Accessibilité (WCAG 2.1 AA)

| Vérification | Description |
|--------------|-------------|
| ARIA labels | Sur tous les éléments interactifs |
| Keyboard nav | Tab, Enter, Escape fonctionnels |
| Focus visible | Indicateur de focus visible |
| Contraste | Ratio >= 4.5:1 (texte), >= 3:1 (UI) |
| Alt text | Sur toutes les images |
| Screen reader | Testé avec NVDA/VoiceOver |
| Skip links | Lien "Skip to content" |
| Error messages | Associés aux champs (aria-describedby) |

---

## Structure du Fichier

```json
{
  "version": "1.0",
  "errors": [...],
  "quick_lookup": {
    "by_module": { "users": ["ERR-001", "ERR-003"] },
    "by_category": { "typescript": ["ERR-001"], "rgpd": ["ERR-005"], "accessibility": ["ERR-006"] },
    "by_tag": { "pagination": ["ERR-002"], "gdpr": ["ERR-005"], "wcag": ["ERR-006"] }
  },
  "prevention_rules_summary": [
    { "id": "ERR-001", "rule": "Toujours typer les retours" },
    { "id": "ERR-005", "rule": "Chiffrer les données personnelles" },
    { "id": "ERR-006", "rule": "Ajouter ARIA labels sur les boutons icon-only" }
  ]
}
```

---

## Validation Atlas (Architecture)

**OBLIGATOIRE AVANT handoff au Tester:**

```
Developer termine implémentation
         ↓
    /atlas {path}
         ↓
┌────────────────────────────────┐
│ Score >= 70/100?               │
│ ZERO violations BLOCKER?       │
└────────────────────────────────┘
         ↓
   OUI → Handoff to Tester
   NON → Corriger violations → Re-run Atlas
```

| Critère Atlas | Seuil | Action si NON |
|---------------|-------|---------------|
| Score global | >= 70/100 | Refactorer |
| BLOCKER violations | 0 | Corriger immédiatement |
| MAJOR violations | Documentées | Justifier ou corriger |

**Erreurs d'architecture fréquentes:**
- Hooks dans services (Clean Architecture violation)
- Business logic dans controllers
- Dépendances circulaires
- Couplage fort entre modules

---

## Intégration

- **Pattern parent**: P-015 (Context Discovery)
- **Fichier**: `.claude/memory/error-journal.json`
- **Lecture**: Étape 0 du Context Discovery
- **Écriture**: Après chaque bug fix
- **Validation**: Atlas AVANT handoff (obligatoire)
