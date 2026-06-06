# Plan de Test — {feature-ou-story-id}

**Date** : {date}
**Story/Feature** : {story-id} — {titre}
**Auteur** : {user_name}
**Version** : 1.0

---

## 1. Résumé exécutif

**Périmètre** : {description courte de ce qui est testé}

**Objectifs** :
- Valider que {fonctionnalité principale}
- Garantir la robustesse face à {cas d'erreur principaux}
- Assurer les exigences non-fonctionnelles : {NFR listées}

**Risques identifiés** :
| Risque | Niveau | Mitigation |
|--------|--------|-----------|
| {risque 1} | Critique/Élevé/Moyen | {mitigation} |

---

## 2. Stratégie de test

### Distribution pyramide cible

```
E2E          ▲  10% — {n} tests — Playwright/Cypress
Integration  ██  20% — {n} tests — Services, DB, API
Unit         ████  70% — {n} tests — Fonctions, classes
```

### Outils

| Type | Outil | Version |
|------|-------|---------|
| Unitaires | {Vitest | Jest | pytest | JUnit | go test} | {version} |
| Intégration | {Vitest + supertest | pytest | Spring Boot Test} | {version} |
| E2E | {Playwright | Cypress} | {version} |
| Couverture | {v8/Istanbul | coverage.py | JaCoCo} | {version} |
| Contrat | {Pact} | {version} |

### Seuils de qualité

| Métrique | Seuil minimum |
|----------|--------------|
| Line coverage | ≥ 80% |
| Branch coverage | ≥ 80% |
| Function coverage | ≥ 80% |
| Mutation score | ≥ 70% (si applicable) |

---

## 3. Catalogue des cas de test

### TC-001 : {Titre du cas de test}

**Fonctionnalité** : {feature}
**Technique** : Partitionnement équivalence | Boundary | Table décision | Transition état
**Priorité** : Critique | Élevée | Moyenne | Faible
**Type** : Unit | Integration | E2E | Performance | Security

**Préconditions** :
- {condition 1}
- {condition 2}

**Données de test** :
| Paramètre | Valeur valide | Valeur invalide | Valeur limite |
|-----------|--------------|-----------------|---------------|
| {param1} | {valide} | {invalide} | {limite} |

**Étapes** :
1. {action 1}
2. {action 2}
3. {action 3}

**Résultat attendu** :
- {assertion 1}
- {assertion 2}

---

### TC-002 : {Titre du cas d'erreur}

**Type** : Cas d'erreur / Edge case
**Lié à** : TC-001

**Préconditions** : {conditions d'erreur}

**Données de test** : {données invalides ou limites}

**Résultat attendu** :
- Erreur levée : {type d'erreur}
- Message : {message attendu}
- Code HTTP : {code si applicable}

---

*(Répéter pour chaque cas de test)*

---

## 4. Matrice de couverture des exigences

| Exigence | Description | TC couvrants | Couverture |
|----------|-------------|-------------|-----------|
| CA-{n} | {description} | TC-001, TC-003 | ✅ |
| CA-{n} | {description} | TC-002 | ✅ |
| NFR-{n} | {description} | TC-010 | ✅ |

**Taux de couverture** : {n}/{total} exigences = **{pct}%**

---

## 5. Données de test et fixtures

### Fixtures requises

```typescript
// tests/fixtures/{feature}.ts
export const valid{Entity} = {
  // données valides complètes
}

export const invalid{Entity}Cases = [
  { input: null, error: 'ValidationError' },
  { input: '', error: 'ValidationError' },
  // ...
]
```

### Données de seed (si base de données)

```sql
-- tests/fixtures/{feature}.sql
INSERT INTO {table} VALUES (...);
```

---

## 6. Critères de sortie

- [ ] Tous les cas de test TC-001 à TC-{n} implémentés
- [ ] Couverture line ≥ 80%, branch ≥ 80%
- [ ] Aucun test en échec
- [ ] Tous les critères d'acceptation validés

---

*Document généré par Harmony Framework — workflow testarch-test-design*
