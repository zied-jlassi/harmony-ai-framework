# Workflow : Sélection et Initialisation du Framework de Test

<critical>Ce workflow détecte automatiquement le stack technologique et configure le framework de test optimal. Il doit être exécuté AVANT tout autre workflow testarch.</critical>

<workflow>

<step n="1" goal="Détecter le stack technologique du projet">
<action>Communiquer en {communication_language} avec {user_name}</action>
<action>Scanner les fichiers de configuration à la racine du projet :</action>

**Fichiers à inspecter (par ordre de priorité) :**
- `package.json` → TypeScript/JavaScript (React, Vue, Angular, Next.js, NestJS, Express)
- `pyproject.toml` / `requirements.txt` / `setup.py` → Python (Django, FastAPI, Flask)
- `pom.xml` / `build.gradle` → Java/Kotlin (Spring Boot)
- `go.mod` → Go
- `Cargo.toml` → Rust
- `Gemfile` → Ruby (Rails)
- `composer.json` → PHP (Laravel, Symfony)
- `*.csproj` / `*.sln` → C#/.NET

**Vérifier si un framework de test existe déjà :**
- `jest.config.*`, `vitest.config.*`, `playwright.config.*`, `cypress.config.*`
- `pytest.ini`, `pyproject.toml [tool.pytest]`
- `src/test/`, `tests/`, `spec/`, `__tests__/`
</step>

<step n="2" goal="Recommander le framework optimal selon le stack">
<action>Appliquer la matrice de décision suivante :</action>

**TypeScript/JavaScript — Recommandations 2026 :**

| Use case | Framework recommandé | Alternative |
|----------|---------------------|-------------|
| Tests unitaires/intégration (TS/JS) | **Vitest** (10x plus rapide que Jest, natif ESM) | Jest (écosystème plus large) |
| Tests E2E / browser automation | **Playwright** (multi-browser, traces, screenshots) | Cypress (DX supérieure, mono-browser) |
| Tests de composants React/Vue | **Vitest + Testing Library** | Jest + Testing Library |
| Tests API/HTTP | **Vitest + supertest** ou **msw** (mock service worker) | Jest + nock |
| Tests de contrat | **Pact** (consumer-driven contract testing) | — |
| Tests visuels | **Playwright** + screenshots comparaison | Chromatic + Storybook |

**Python :**
| Use case | Framework recommandé |
|----------|---------------------|
| Tous types de tests | **pytest** + pytest-cov |
| Tests BDD/ATDD | **pytest-bdd** ou **Behave** |
| Tests async | **pytest-asyncio** |
| Tests E2E | **Playwright** (bindings Python) |

**Java/Kotlin :**
| Use case | Framework recommandé |
|----------|---------------------|
| Tests unitaires | **JUnit 5** + Mockito |
| Tests intégration | **Spring Boot Test** + Testcontainers |
| Tests E2E | **Playwright** (bindings Java) ou **Selenium** |
| Tests de contrat | **Pact JVM** |

**Go :**
- Tests unitaires/intégration : `go test` + **testify** + **httptest**
- Tests E2E : **Playwright** (bindings Go) ou `net/http/httptest`

**Rust :**
- Tests unitaires/intégration : **cargo test** (built-in)
- Benchmarks : **criterion**
- Tests de propriétés : **proptest**
</step>

<step n="3" goal="Installer et configurer le framework sélectionné">
<action>Générer les commandes d'installation adaptées au gestionnaire de paquets détecté (npm/yarn/pnpm/bun, pip/poetry/uv, cargo, go mod)</action>

**Pour Vitest (TypeScript/JavaScript) :**
```bash
# Installation
pnpm add -D vitest @vitest/coverage-v8 @vitest/ui

# Configuration vitest.config.ts
```
```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // ou 'jsdom' pour React/Vue
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      thresholds: {
        lines: 80,
        branches: 80,
        functions: 80,
        statements: 80
      }
    }
  }
})
```

**Pour Playwright :**
```bash
pnpm create playwright
# Choisir: TypeScript, tests/, GitHub Actions CI
```

**Pour pytest :**
```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--cov=src --cov-report=term-missing --cov-report=lcov"

[tool.coverage.run]
branch = true

[tool.coverage.report]
fail_under = 80
```

<action>Créer la structure de répertoires standard :</action>

```
tests/
├── unit/           # Tests unitaires rapides (< 10ms)
├── integration/    # Tests d'intégration (services, DB, API)
├── e2e/            # Tests end-to-end (navigateur, flux complets)
├── fixtures/       # Données de test partagées
├── helpers/        # Utilitaires de test
└── README.md       # Documentation de la stratégie de test
```
</step>

<step n="4" goal="Créer les fichiers de base et exemples">
<action>Générer un test d'exemple fonctionnel pour chaque type :</action>

- Un test unitaire simple (fonction pure)
- Un test d'intégration (service avec dépendance mockée)
- Un test E2E basique (si Playwright/Cypress installé)

<action>Ajouter les scripts npm/scripts de build :</action>
```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```
</step>

<step n="5" goal="Documenter la stratégie de test du projet">
<action>Créer ou mettre à jour `tests/README.md` avec :</action>

- Framework(s) choisi(s) et justification
- Pyramide de test cible (distribution 70/20/10)
- Seuils de couverture (line, branch, function)
- Conventions de nommage (`*.test.ts`, `*.spec.ts`, `test_*.py`)
- Comment lancer les tests localement
- Comment lancer les tests en CI

<action>Afficher un résumé à {user_name} avec les prochaines étapes recommandées</action>
</step>

</workflow>
