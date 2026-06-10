# Checklist : Initialisation Framework de Test

## Prérequis
- [ ] Stack technologique identifié (langage, framework applicatif)
- [ ] Gestionnaire de paquets détecté (npm/pnpm/yarn/bun, pip/poetry/uv, cargo…)
- [ ] Accès en écriture au projet

## Sélection du framework (état 2026)
- [ ] Unitaire/intégration : **Vitest** (TS/JS, ESM-natif) ou Jest si écosystème en place ; **pytest** (Python) ; JUnit 5 ; `go test` ; `cargo test`
- [ ] E2E : **Playwright** (a dépassé Selenium ; auto-wait → stabilité ~92% ; Radar *Adopt*) — Selenium réservé au legacy
- [ ] Outil de couverture sélectionné (v8/Istanbul/coverage.py/tarpaulin/JaCoCo)
- [ ] Contract testing (Pact) sélectionné si interfaces inter-services
- [ ] Justification documentée du choix

## Installation et configuration
- [ ] Dépendances de test installées ; fichier de config créé (vitest.config.ts / pytest.ini…)
- [ ] Seuils de couverture (line/branch/function ≥ 80%) ; reporter LCOV + HTML (CI)
- [ ] Scripts ajoutés : `test`, `test:watch`, `test:coverage`, `test:e2e`

## Structure des répertoires
- [ ] `tests/{unit,integration,e2e,fixtures,helpers}/` créés (e2e si framework E2E installé)

## Fichiers d'exemple
- [ ] Un test unitaire, un test d'intégration (dépendance mockée), un test E2E (si Playwright) — tous fonctionnels
- [ ] Tous les tests d'exemple passent

## Documentation
- [ ] `tests/README.md` : framework choisi + justification, conventions de nommage, lancement
- [ ] Forme de couverture cible documentée (**pyramide** backend ou **Testing Trophy** front)
- [ ] `.gitignore` mis à jour (coverage/, playwright-report/, .nyc_output/)

## Critères de sortie
- [ ] `npm test` (ou équivalent) s'exécute sans erreur ; couverture > 0% sur les exemples
- [ ] Configuration CI-ready (variables d'environnement documentées)
