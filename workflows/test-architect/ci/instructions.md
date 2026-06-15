# Workflow : Configuration CI/CD Pipeline de Test

> **But** — Configurer les pipelines d'intégration continue selon 4 couches : suite de tests, exécution parallèle, environnements éphémères et observabilité. Objectif moderne : build de référence **< 10 minutes** (les équipes élites y parviennent grâce à la parallélisation) et **quality gates** automatiques. Supporte GitHub Actions et GitLab CI.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Détecter le stack et l'environnement CI

Détecter la plateforme : `.github/workflows/` (GitHub Actions), `.gitlab-ci.yml` (GitLab CI), `Jenkinsfile` (Jenkins), ou `{platform}` explicite. Scanner le stack : framework de test, E2E (Playwright/Cypress), couverture (v8/istanbul/coverage.py), lint. Vérifier scripts `test`, `test:coverage`, `test:e2e` et seuils existants.

## 2. Concevoir l'architecture 4 couches

**Couche 1 — Suite de tests** : distribution justifiée par le risque (pyramide backend ou Testing Trophy front : poids fort sur l'intégration).

**Couche 2 — Parallélisation & sharding** : séparer unit/integration/E2E en jobs parallèles ; sharder l'E2E.
```
Nombre de shards ≈ temps total de la suite / temps cible par shard
Ex. suite 45 min, cible 8 min → ~6 shards
```
Matrix strategy pour multi-version Node/Python. La parallélisation est le levier n°1 pour passer sous 10 min.

**Couche 3 — Environnements éphémères** : services Docker (PostgreSQL/Redis/Mongo) via `services:`, isolation totale, zéro ressource partagée persistante.

**Couche 4 — Observabilité & quality gates** : JUnit XML, LCOV/HTML, upload Codecov, artifacts (traces Playwright, screenshots d'échec), badge CI. **Quality gates** (deployment gates) : échouer si couverture < `{coverage_threshold}%`, si traçabilité sous le seuil, ou si des tests flaky non-quarantinés cassent le build.

Valider l'architecture avec `{user_name}` avant de générer les fichiers.

## 3. Générer le pipeline GitHub Actions (si applicable)

Si `{platform}` ∈ {github, both}, créer `.github/workflows/tests.yml` :
```yaml
# .github/workflows/tests.yml — Harmony Test Architect — pipeline 4 couches
name: Tests
on:
  push: { branches: [main, develop] }
  pull_request: { branches: [main] }
jobs:
  unit-tests:        # rapides, isolés
  integration-tests: # services Docker
    services:
      postgres: { image: postgres:16-alpine }
  e2e-tests:
    strategy:
      fail-fast: false
      matrix: { shard: [1, 2, 3, 4] }   # E2E shardé
    steps:
      - run: npx playwright test --shard=${{ matrix.shard }}/4
  quality-gate:
    needs: [unit-tests, integration-tests]
    # échec si couverture < seuil
```
Écrire le fichier complet avec cache (npm/pip/go), artifacts et notifications.

## 4. Générer le pipeline GitLab CI (si applicable)

Si `{platform}` ∈ {gitlab, both}, créer/mettre à jour `.gitlab-ci.yml` :
```yaml
# .gitlab-ci.yml — Harmony Test Architect — pipeline 4 couches
stages: [lint, test-unit, test-integration, test-e2e, quality-gate, report]
variables: { COVERAGE_THRESHOLD: "{coverage_threshold}" }
e2e-tests:
  stage: test-e2e
  parallel: 4
  script: [ "npx playwright test --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL" ]
quality-gate:
  stage: quality-gate
  script:
    - |
      coverage=$(jq '.total.lines.pct' coverage/coverage-summary.json)
      awk "BEGIN{exit !($coverage < $COVERAGE_THRESHOLD)}" && { echo "❌ $coverage% < $COVERAGE_THRESHOLD%"; exit 1; } || true
```
Écrire le fichier complet avec cache, artifacts JUnit/Allure et badges.

## 5. Mesurer l'efficacité (DORA) et documenter

Aligner le pipeline sur les **DORA metrics** (signaux de santé de la livraison) :
- **Lead time for changes** & **Deployment frequency** : favorisés par un build rapide (< 10 min) et fiable.
- **Change failure rate** : réduit par les quality gates (couverture, traçabilité, NFR).
- **Failed deployment recovery time (MTTR)** : facilité par fail-fast + rollback automatisé.

Valider la syntaxe CI (`actionlint` pour GitHub si dispo). Ajouter au `README.md` les badges + la description du pipeline (unit/integration/E2E shardé/quality gate). Afficher à `{user_name}` le résumé + prochaines étapes (secrets, Codecov, politique de quarantaine flaky).
