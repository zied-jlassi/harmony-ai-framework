# Workflow : Conception des Tests (Test Design)

<critical>Ce workflow produit un plan de test complet basé sur l'analyse des exigences, l'évaluation des risques et les techniques de conception reconnues. Il précède l'implémentation des tests.</critical>

<workflow>

<step n="1" goal="Analyser les exigences et le contexte">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Charger les sources d'exigences disponibles :</action>
- Story Harmony (`{story_file}` ou `{working_memory}:current_story`)
- PRD / spécifications fonctionnelles
- Diagrammes d'état ou de séquence
- Contrats d'API (OpenAPI/Swagger)
- Issues/tickets référencés

<action>Identifier le type de système à tester :</action>
- **API REST/GraphQL** → tests de contrat, tests d'intégration, validation des schémas
- **Interface utilisateur** → tests E2E, tests visuels, accessibilité
- **Logique métier** → tests unitaires, tests de propriétés
- **Microservices** → tests de contrat Pact, tests d'intégration
- **Batch/traitement de données** → tests de volume, tests de transformation
</step>

<step n="2" goal="Identifier les fonctionnalités et les risques">
<action>Décomposer les exigences en fonctionnalités testables</action>

<action>Évaluer le risque de chaque fonctionnalité :</action>

| Niveau | Critères | Priorité de test |
|--------|----------|-----------------|
| **Critique** | Données sensibles, transactions financières, authentification, sécurité | Exhaustif — toutes les branches |
| **Élevé** | Fonctionnalités cœur de métier, flux utilisateur principal | Étendu — happy path + principaux edge cases |
| **Moyen** | Fonctionnalités secondaires, configurations | Standard — happy path + cas d'erreur majeurs |
| **Faible** | Affichage, formatage, messages cosmétiques | Minimal — smoke test |

<action>Identifier les zones de risque technique :</action>
- Intégrations tierces (paiement, email, SMS, API externe)
- Traitement de données utilisateur (RGPD, validation, sanitization)
- Logique concurrentielle (race conditions)
- Gestion des erreurs et des timeouts
- Performance sous charge
</step>

<step n="3" goal="Appliquer les techniques de conception de tests">
<action>Pour chaque fonctionnalité, sélectionner et appliquer la/les technique(s) adaptée(s) :</action>

**Technique 1 — Partitionnement en classes d'équivalence**
```
Exemple : validation d'un champ "âge" (entier, 0-120)
Classes valides   : [0-120] → tester avec 0, 60, 120
Classes invalides : [-∞, -1] → tester avec -1
                   [121, +∞] → tester avec 121
                   Non-entier → tester avec 25.5, "vingt"
                   Null/vide  → tester avec null, ""
```

**Technique 2 — Analyse des valeurs limites (Boundary Value)**
```
Pour chaque limite identifiée : tester à, avant, et après la limite
Exemple âge [0-120] :
  Limites    : 0, 120
  Avant      : -1, 119
  Après      : 1, 121
```

**Technique 3 — Tables de décision**
```
Quand plusieurs conditions combinées influencent le résultat :
  C1: utilisateur authentifié | C2: rôle admin | Action résultante
  ────────────────────────────────────────────────────────────────
  Vrai  | Vrai  | Accès total
  Vrai  | Faux  | Accès restreint
  Faux  | N/A   | Redirection login
```

**Technique 4 — Transitions d'état (State Transition)**
```
Modéliser les états et transitions :
  DRAFT → SUBMITTED → APPROVED/REJECTED → ARCHIVED
  Tester chaque transition valide ET les transitions invalides
```

**Technique 5 — Tests de propriétés (Property-Based)**
```
Pour les fonctions pures avec domaine large :
  "Pour tout entier n ≥ 0, fibonacci(n) ≥ 0"
  "Pour toute liste l, sort(l).length === l.length"
  Outils : fast-check (JS), Hypothesis (Python), proptest (Rust)
```

**Technique 6 — Tests de mutation (Mutation Testing)**
```
Vérifier la robustesse des tests existants en introduisant des mutations :
  Outils : Stryker (JS/TS), mutmut (Python), PIT (Java)
  Seuil recommandé : mutation score ≥ 70%
```
</step>

<step n="4" goal="Concevoir les cas de test">
<action>Pour chaque fonctionnalité prioritaire, créer les cas de test selon le format :</action>

```markdown
## TC-{ID}: {Titre descriptif}

**Fonctionnalité** : {feature}
**Technique** : {technique utilisée}
**Priorité** : Critique | Élevée | Moyenne | Faible
**Type** : Unit | Integration | E2E | Performance | Security

**Préconditions** :
- {condition 1}
- {condition 2}

**Données de test** :
| Input | Valeur |
|-------|--------|
| {param1} | {valeur} |

**Étapes** :
1. {action 1}
2. {action 2}

**Résultat attendu** :
- {assertion 1}
- {assertion 2}

**Notes** :
- {edge case particulier}
```

<action>Vérifier la complétude des cas de test :</action>
- Couverture de toutes les exigences (au moins 1 TC par AC)
- Cas nominaux (happy path) couverts
- Cas d'erreur couverts
- Cas limites couverts pour les fonctionnalités critiques
</step>

<step n="5" goal="Produire le document de plan de test">
<action>Écrire le document de plan de test dans `{output_file}` ou `docs/test-design-{story-id}.md`</action>

<action>Le document doit contenir :</action>
1. **Résumé exécutif** : périmètre, objectifs, risques identifiés
2. **Stratégie de test** : types de tests, outils, seuils
3. **Pyramide de test cible** : distribution unit/integration/E2E
4. **Catalogue des cas de test** : liste complète avec priorités
5. **Matrice de couverture** : exigences → cas de test
6. **Critères de sortie** : définition of Done pour les tests
7. **Données de test** : jeux de données, fixtures à préparer

<action>Afficher à {user_name} le résumé avec les métriques :</action>
- Nombre de cas de test conçus par type
- Fonctionnalités couvertes vs total
- Estimation du temps d'implémentation des tests
- Recommandation d'ordre d'implémentation
</step>

</workflow>
