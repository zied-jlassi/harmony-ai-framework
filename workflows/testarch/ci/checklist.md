# Checklist : Configuration Pipeline CI/CD

## Prérequis
- [ ] Tests unitaires et d'intégration fonctionnels localement
- [ ] Plateforme CI cible identifiée (GitHub Actions / GitLab CI / les deux)
- [ ] Droits d'écriture sur le dépôt (pour créer `.github/workflows/` ou `.gitlab-ci.yml`)
- [ ] Secrets CI identifiés (tokens Codecov, variables d'environnement de test)

## Architecture du pipeline (4 couches)
- [ ] Couche 1 — Suite de tests définie : unit / integration / e2e séparés en jobs
- [ ] Couche 2 — Parallélisme configuré (matrix strategy ou parallel)
- [ ] Couche 3 — Services Docker configurés pour les tests d'intégration (PostgreSQL, Redis...)
- [ ] Couche 4 — Observabilité : JUnit XML, LCOV, rapport HTML, artifacts

## GitHub Actions (si applicable)
- [ ] `.github/workflows/tests.yml` créé
- [ ] Trigger configuré : push sur main/develop, PR vers main
- [ ] Job `unit-tests` : rapide, sans dépendances externes
- [ ] Job `integration-tests` : avec services Docker (postgres, redis...)
- [ ] Job `e2e-tests` : Playwright/Cypress avec sharding (≥ 2 shards)
- [ ] Job `quality-gate` : vérifie seuil couverture {coverage_threshold}%
- [ ] Cache npm/pip/cargo configuré (économie de temps)
- [ ] Artifacts uploadés : junit-results.xml, coverage/, playwright-report/
- [ ] Badge de statut récupéré pour le README

## GitLab CI (si applicable)
- [ ] `.gitlab-ci.yml` créé ou mis à jour
- [ ] Stages : lint → test-unit → test-integration → test-e2e → quality-gate → report
- [ ] Cache partagé configuré pour les dépendances
- [ ] Services Docker configurés dans les jobs d'intégration
- [ ] Parallélisme E2E configuré (`parallel: N`)
- [ ] Artifacts JUnit XML configurés (intégration native GitLab)
- [ ] Badge de couverture configuré (GitLab coverage regex)
- [ ] Quality gate script : échoue si couverture < seuil

## Qualité du pipeline
- [ ] Tests unitaires : durée < 2 minutes
- [ ] Tests intégration : durée < 5 minutes
- [ ] Tests E2E : durée < 10 minutes avec sharding
- [ ] Pipeline complet : durée < 15 minutes (feedback loop rapide)
- [ ] Flaky tests : politique de retry configurée (max 2 retry)
- [ ] Notifications d'échec configurées (email, Slack...)

## Documentation
- [ ] Badge CI ajouté dans README.md
- [ ] Badge couverture ajouté dans README.md
- [ ] Secrets CI documentés (noms des variables, où les configurer)
- [ ] Procédure de debug des tests CI documentée

## Critères de sortie
- [ ] Pipeline s'exécute sans erreur sur la branche courante
- [ ] Quality gate passe si couverture ≥ {coverage_threshold}%
- [ ] Rapports de test visibles dans l'interface CI
