# Workflow : Sélection et Initialisation du Framework de Test

> **But** — Détecter le stack technologique et configurer le framework de test optimal. Ce workflow doit être exécuté AVANT tout autre workflow Test Architect.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Détecter le stack technologique

Scanner les fichiers racine (par priorité) : `package.json` (TS/JS), `pyproject.toml`/`requirements.txt` (Python), `pom.xml`/`build.gradle` (Java/Kotlin), `go.mod` (Go), `Cargo.toml` (Rust), `Gemfile` (Ruby), `composer.json` (PHP), `*.csproj` (.NET). Vérifier l'existence d'un framework : `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `cypress.config.*`, `pytest.ini`, dossiers `tests/`/`__tests__/`/`spec/`.

## 2. Recommander le framework optimal (état 2026)

**TypeScript/JavaScript :**

| Use case | Recommandé 2026 | Note |
|----------|-----------------|------|
| Unitaires / intégration | **Vitest** | ESM-natif, rapide, partage la config Vite ; adoption ~29% et en forte hausse |
| (existant à large écosystème) | Jest | encore dominant (~63%) ; rester si déjà en place |
| E2E / browser | **Playwright** | a **dépassé Selenium** en 2026 (≈45% vs 22%) ; auto-wait → ~92% de stabilité ; ThoughtWorks Radar = *Adopt* |
| Composants React/Vue | **Vitest + Testing Library** | tester le comportement, pas l'implémentation |
| API/HTTP | **Vitest + msw** (mock service worker) | ou supertest |
| Contrat (inter-services) | **Pact** | consumer-driven |
| Visuel | **Playwright** screenshots | ou Chromatic + Storybook |

> Selenium = *Hold* pour les nouveaux projets (Radar) ; le réserver au legacy/contraintes spécifiques. L'écosystème IA de Playwright (MCP : Planner / Generator / Healer) émerge — utile pour la génération assistée et le self-healing, **toujours avec revue humaine**.

**Python** : **pytest** (+ pytest-cov) pour tout ; pytest-bdd/Behave (BDD), pytest-asyncio (async), Playwright (E2E).
**Java/Kotlin** : **JUnit 5** + Mockito ; Spring Boot Test + **Testcontainers** (intégration) ; Pact JVM (contrat).
**Go** : `go test` + **testify** + httptest.
**Rust** : `cargo test` (built-in), **criterion** (bench), **proptest** (property-based).

## 3. Installer et configurer

Générer les commandes selon le gestionnaire détecté (npm/pnpm/bun, pip/poetry/uv, cargo, go).

**Vitest :**
```bash
pnpm add -D vitest @vitest/coverage-v8 @vitest/ui
```
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // 'jsdom' pour React/Vue
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      thresholds: { lines: 80, branches: 80, functions: 80, statements: 80 },
    },
  },
})
```
**Playwright :** `pnpm create playwright` (TypeScript, tests/, CI).
**pytest :**
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--cov=src --cov-report=term-missing --cov-report=lcov"
[tool.coverage.run]
branch = true
[tool.coverage.report]
fail_under = 80
```

Créer l'arborescence standard : `tests/{unit,integration,e2e,fixtures,helpers}/` + `tests/README.md`.

## 4. Créer les fichiers de base et scripts

Générer un test d'exemple fonctionnel par type (unitaire, intégration mockée, E2E si Playwright). Ajouter les scripts :
```json
{ "scripts": {
  "test": "vitest run", "test:watch": "vitest", "test:ui": "vitest --ui",
  "test:coverage": "vitest run --coverage",
  "test:e2e": "playwright test", "test:e2e:ui": "playwright test --ui"
}}
```

## 5. Documenter la stratégie

Créer/mettre à jour `tests/README.md` : framework(s) choisis + justification, forme de couverture cible (pyramide ou Testing Trophy), seuils (line/branch/function), conventions de nommage, lancement local et CI. Afficher un résumé à `{user_name}` avec les prochaines étapes.
