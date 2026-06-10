# Workflow : Conception des Tests (Test Design)

> **But** — Produire une stratégie de test et un plan de cas de test complets, basés sur l'analyse des exigences, l'évaluation des risques et les techniques reconnues (ISTQB, ISO/IEC 25010, ISO/IEC/IEEE 29119). Ce workflow précède l'implémentation des tests et alimente la traçabilité exigences↔tests.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Cadrer la stratégie de test (shift-left + shift-right)

Choisir la forme de couverture cible selon la nature du système :
- **Test Pyramid** (classique) : beaucoup d'unitaires, moins d'intégration, peu d'E2E — adapté au backend/logique métier.
- **Testing Trophy** (apps modernes/UI) : poids fort sur l'**intégration**, base statique (types, lint), sommet E2E réduit — adapté front/full-stack.

Documenter la distribution visée (ex. 70/20/10) et la **justifier par le risque**, pas par dogme. Positionner les tests sur le cycle (continuous testing) :
- **Shift-left** : contrat, statique, unitaire, composant au plus tôt (pré-merge).
- **Shift-right** : validation en production — feature flags, canary, monitoring synthétique, real user monitoring (RUM).

## 2. Analyser les exigences et le type de système

Charger les sources d'exigences : story Harmony (`{story_file}` ou `{working_memory}:current_story`) et ses critères d'acceptation, PRD, diagrammes d'état/séquence, contrats d'API (OpenAPI, GraphQL, Protobuf), tickets référencés.

Identifier le type de système et la stratégie associée :
- **API REST/GraphQL** → tests de schéma, **contract testing** (consumer-driven), intégration
- **Interface utilisateur** → intégration (Testing Trophy), E2E ciblés, visuel, accessibilité (WCAG)
- **Logique métier** → unitaires, **property-based**, mutation
- **Microservices** → **contrats Pact**, résilience (timeouts, retries, circuit breaker)
- **Pipelines de données / batch** → volume, transformation, qualité de données
- **Composant IA/LLM** → évaluation (eval sets), garde-fous, non-déterminisme (tolérances, jugé-par-LLM)

## 3. Évaluer le risque (scoring probabilité × impact)

Décomposer les exigences en fonctionnalités testables, puis scorer chacune — **risque = Probabilité (1-3) × Impact (1-3)** :

| Score | Niveau | Profondeur de test |
|-------|--------|--------------------|
| 6-9 | Critique | Exhaustif — toutes branches, edge cases, NFR, sécurité |
| 4-5 | Élevé | Étendu — happy path + principaux cas d'erreur/limites |
| 2-3 | Moyen | Standard — happy path + cas d'erreur majeurs |
| 1 | Faible | Minimal — smoke test |

Marquer les zones de risque technique (probabilité élevée) : intégrations tierces (paiement, email, API externe), données personnelles (RGPD), concurrence (race conditions, idempotence), erreurs/timeouts/dégradation gracieuse, frontières de service, montée en charge.

Prioriser : les premiers cas conçus doivent couvrir le maximum de risque (viser ~70-80 % du risque avec les premiers ~20-30 % des cas).

## 4. Appliquer les techniques de conception

- **Partitionnement en classes d'équivalence** — réduire le domaine d'entrée à des classes représentatives. Ex. champ `âge` (0-120) : valides `0, 60, 120` ; invalides `-1`, `121`, `25.5`, `"vingt"`, `null`, `""`.
- **Analyse des valeurs limites (BVA)** — tester à, juste avant, juste après chaque limite. Ex. `âge [0-120]` → `0, 120` (limites), `-1, 119` (avant), `1, 121` (après).
- **Tables de décision** — combinaisons de conditions (authentifié × admin → accès total / restreint / redirection).
- **Transitions d'état** — `DRAFT → SUBMITTED → APPROVED/REJECTED → ARCHIVED` ; tester transitions valides **et** invalides.
- **Tests combinatoires (pairwise / n-wise)** — couvrir toutes les paires plutôt que toutes les combinaisons (capte l'essentiel des défauts d'intégration à coût réduit).
- **Property-based** — invariants sur domaine large (`∀ liste l, sort(l).length === l.length`). Outils : fast-check (JS/TS), Hypothesis (Python), proptest (Rust).
- **Contract testing** — contrats consumer-driven (Pact) côté consommateur + vérification côté provider, en CI ; réduit le besoin d'E2E inter-services.
- **Mutation testing** — mesurer la robustesse des tests (Stryker, mutmut, PIT). Cible : mutation score ≥ 70 % sur le code critique.

**Génération assistée par IA** (quand pertinent) : générer des ébauches de cas (classes d'équivalence, edge cases) à partir des AC et schémas, puis **revue humaine obligatoire** (l'IA propose, l'ingénieur valide). Surveiller les angles morts (oracles implicites, cas métier rares, NFR). Prévoir la maintenance : sélecteurs/assertions résilients et politique anti-flaky (quarantaine + cause racine, jamais de retry masquant).

## 5. Couvrir les exigences non-fonctionnelles (ISO/IEC 25010)

Pour les fonctionnalités Critiques/Élevées, planifier les tests NFR par caractéristique :
- **Performance** : latence p95/p99, débit, ressources — seuils explicites
- **Sécurité** : authz/authn, injection, secrets, OWASP — déléguer l'audit à l'agent security
- **Fiabilité** : reprise sur panne, idempotence, dégradation gracieuse
- **Compatibilité / Interaction** : navigateurs, OS, accessibilité (WCAG)
- **Maintenabilité / Observabilité** : logs, traces, métriques exploitables en test

Référencer ces NFR vers le workflow d'évaluation NFR dédié pour le détail.

## 6. Concevoir les cas de test

Format d'un cas :

```markdown
## TC-{ID}: {Titre}
**Exigence couverte** : {AC-id}          ← pour la traçabilité
**Technique** : {technique}
**Priorité** : Critique | Élevée | Moyenne | Faible   (issue du score de risque)
**Type** : Unit | Integration | Contract | E2E | Performance | Security
**Niveau** : static | unit | integration | e2e
**Préconditions** : …
**Données de test** : | input | valeur |
**Étapes** : 1. … 2. …
**Oracle / Résultat attendu** : {assertions vérifiables}
**Notes** : {edge case, NFR lié}
```

Vérifier la complétude : ≥ 1 cas par critère d'acceptation (traçabilité bidirectionnelle) ; happy path + erreur + limites pour Critiques/Élevées ; cas négatifs/abus (sécurité) pour les zones sensibles.

## 7. Produire le document de plan de test

Écrire le plan dans `{output_file}` ou `docs/test-design-{story-id}.md`, contenant :
1. **Résumé exécutif** : périmètre, objectifs, top risques (score)
2. **Stratégie** : forme de couverture (pyramide/trophy + distribution), shift-left/right, outils, seuils
3. **Catalogue des cas de test** : liste avec priorités et niveaux
4. **Matrice de traçabilité** : exigence/AC → cas de test (bidirectionnelle)
5. **Couverture NFR** : caractéristiques ISO 25010 visées + seuils
6. **Critères de sortie** : Definition of Done des tests (couverture, mutation score, NFR)
7. **Données & environnements** : fixtures, jeux de données, gestion des données de test

Afficher à `{user_name}` le résumé : cas conçus par type/niveau, couverture des AC (couverts/total), top risques adressés, estimation d'effort, ordre d'implémentation recommandé (du risque le plus élevé au plus faible).
