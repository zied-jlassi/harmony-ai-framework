# Checklist : Configuration Pipeline CI/CD

## Prérequis
- [ ] Tests unitaires et d'intégration fonctionnels localement
- [ ] Plateforme CI cible identifiée (GitHub Actions / GitLab CI / les deux)
- [ ] Droits d'écriture sur le dépôt ; secrets CI identifiés (Codecov, variables de test)

## Architecture du pipeline (4 couches)
- [ ] Couche 1 — Suite de tests : distribution justifiée par le risque (pyramide ou Testing Trophy), jobs unit/integration/e2e séparés
- [ ] Couche 2 — Parallélisation & **sharding** (shards ≈ temps total / temps cible par shard)
- [ ] Couche 3 — Services Docker éphémères pour l'intégration (PostgreSQL, Redis…), isolation totale
- [ ] Couche 4 — Observabilité : JUnit XML, LCOV, rapport HTML, artifacts (traces/screenshots)

## GitHub Actions (si applicable)
- [ ] `.github/workflows/tests.yml` créé ; trigger push main/develop + PR
- [ ] Jobs `unit-tests`, `integration-tests` (services Docker), `e2e-tests` (sharding ≥ 2), `quality-gate`
- [ ] Cache (npm/pip/cargo) ; artifacts (junit, coverage, playwright-report) ; badge README

## GitLab CI (si applicable)
- [ ] `.gitlab-ci.yml` : stages lint → test-unit → test-integration → test-e2e → quality-gate → report
- [ ] Cache partagé ; services Docker ; `parallel: N` (E2E) ; artifacts JUnit ; coverage regex
- [ ] Script quality gate : échoue si couverture < seuil

## Performance & stabilité du pipeline
- [ ] Build de référence visé **< 10 minutes** (parallélisation = levier n°1)
- [ ] Tests unit < 2 min, intégration < 5 min, E2E < 10 min (shardé)
- [ ] **Quality gates** : échec si couverture < {coverage_threshold}%, traçabilité sous seuil, ou flaky non géré
- [ ] Politique flaky = **quarantaine + cause-racine** (PAS de retry aveugle qui masque)
- [ ] Notifications d'échec configurées (email, Slack…)

## Mesure (DORA)
- [ ] Pipeline aligné sur les DORA metrics : lead time, deployment frequency, change failure rate, MTTR
- [ ] Fail-fast activé ; rollback/garde-fou documenté

## Documentation
- [ ] Badges CI + couverture dans README ; secrets documentés ; procédure de debug CI

## Critères de sortie
- [ ] Pipeline s'exécute sans erreur sur la branche courante
- [ ] Quality gate passe si couverture ≥ {coverage_threshold}% ; rapports visibles dans l'interface CI
