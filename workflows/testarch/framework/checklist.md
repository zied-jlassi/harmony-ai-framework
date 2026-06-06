# Checklist : Initialisation Framework de Test

## Prérequis
- [ ] Stack technologique identifié (language, framework applicatif)
- [ ] Gestionnaire de paquets détecté (npm/pnpm/yarn/bun, pip/poetry, cargo...)
- [ ] Accès en écriture au projet

## Sélection du framework
- [ ] Framework de test unitaire/intégration sélectionné (Vitest/Jest/pytest/JUnit/go test...)
- [ ] Framework E2E sélectionné si applicable (Playwright/Cypress)
- [ ] Outil de couverture sélectionné (v8/Istanbul/coverage.py/tarpaulin/JaCoCo)
- [ ] Outil de test de contrat sélectionné si applicable (Pact)
- [ ] Justification documentée du choix

## Installation et configuration
- [ ] Dépendances de test installées
- [ ] Fichier de configuration créé (vitest.config.ts / jest.config.ts / pytest.ini...)
- [ ] Seuils de couverture configurés (line ≥ 80%, branch ≥ 80%, function ≥ 80%)
- [ ] Reporter LCOV + HTML configuré pour le CI
- [ ] Scripts npm/Makefile ajoutés : `test`, `test:watch`, `test:coverage`, `test:e2e`

## Structure des répertoires
- [ ] `tests/unit/` créé
- [ ] `tests/integration/` créé
- [ ] `tests/e2e/` créé (si E2E framework installé)
- [ ] `tests/fixtures/` créé
- [ ] `tests/helpers/` créé

## Fichiers d'exemple
- [ ] Au moins un test unitaire d'exemple fonctionnel
- [ ] Au moins un test d'intégration d'exemple fonctionnel
- [ ] Au moins un test E2E d'exemple fonctionnel (si Playwright/Cypress)
- [ ] Tous les tests d'exemple passent (`npm test` / `pytest` / `go test ./...`)

## Documentation
- [ ] `tests/README.md` créé avec : framework choisi, conventions de nommage, comment lancer
- [ ] Pyramide de test cible documentée (distribution 70/20/10)
- [ ] `.gitignore` mis à jour (coverage/, playwright-report/, .nyc_output/)

## Critères de sortie
- [ ] `npm test` (ou équivalent) s'exécute sans erreur
- [ ] Couverture > 0% détectée sur les exemples
- [ ] Configuration CI-ready (variables d'environnement documentées)
