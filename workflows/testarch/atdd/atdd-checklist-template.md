# ATDD Checklist — {story-id} : {story-title}

**Date** : {date}
**Story** : {story-id}
**Sprint** : {sprint-id}
**Auteur** : {user_name}

---

## Critères d'acceptation couverts

| CA-ID | Description | Scénario | Statut |
|-------|-------------|----------|--------|
| CA-{n} | {description} | {scenario-slug} | 🔴 RED / ✅ GREEN |

---

## Tests créés

| Fichier | Test name | CA couvert | Type | Statut |
|---------|-----------|------------|------|--------|
| `tests/acceptance/{story-id}-*.test.ts` | {test name} | CA-{n} | acceptance | 🔴/✅ |

---

## Scénarios Given/When/Then

### CA-{n} : {titre du critère}

```gherkin
Scenario: {titre_scenario_nominal}
  Given {précondition}
  When {action}
  Then {résultat attendu}
  And {assertion complémentaire}

Scenario: {titre_scenario_erreur}
  Given {précondition}
  When {action invalide}
  Then {erreur attendue}
```

---

## Métriques ATDD

| Métrique | Valeur |
|----------|--------|
| CA total | {n} |
| Tests créés | {n} |
| Phase actuelle | 🔴 RED / ✅ GREEN / 🔵 REFACTOR |
| Couverture | {pct}% |
| Dernière exécution | {date} |

---

## Notes et observations

{observations pendant le cycle ATDD}

---

*Généré par Harmony TestArch — workflow testarch-atdd*
