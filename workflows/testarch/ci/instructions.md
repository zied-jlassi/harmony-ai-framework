# Workflow : Configuration CI/CD Pipeline de Test

<critical>Ce workflow configure les pipelines d'intégration continue selon l'architecture 4 couches : suite de tests, exécution parallèle, environnements éphémères et observabilité. Supporte GitHub Actions et GitLab CI.</critical>

<workflow>

<step n="1" goal="Détecter le stack et l'environnement CI existant">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Détecter la plateforme CI cible selon `{platform}` ou par auto-détection :</action>
- Présence de `.github/workflows/` → GitHub Actions
- Présence de `.gitlab-ci.yml` → GitLab CI
- Présence de `Jenkinsfile` → Jenkins
- `{platform}` fourni → utiliser la valeur explicite

<action>Scanner le stack de test installé :</action>
- Framework de test (vitest, jest, pytest, go test, cargo test, JUnit)
- Framework E2E (playwright, cypress, selenium)
- Outil de couverture (v8, istanbul/nyc, coverage.py, tarpaulin, JaCoCo)
- Outil de lint/qualité (eslint, pylint, golangci-lint, clippy)

<action>Vérifier la configuration existante :</action>
- Scripts `test`, `test:coverage`, `test:e2e` dans `package.json`
- Commandes de test dans `Makefile` ou scripts shell
- Configuration de couverture et seuils définis
</step>

<step n="2" goal="Concevoir l'architecture 4 couches du pipeline">
<action>Structurer le pipeline selon les 4 couches recommandées :</action>

**Couche 1 — Suite de tests (distribution pyramide)**
```
Unit tests     (70%) → Rapides, isolés, < 10ms par test
Integration    (20%) → Services, DB, API mocks, < 500ms par test
E2E / Browser  (10%) → Playwright/Cypress, flux complets utilisateur
```

**Couche 2 — Exécution parallèle**
- Séparer unit / integration / E2E en jobs parallèles
- Sharding E2E (ex: 4 shards Playwright sur 4 machines)
- Matrix strategy pour multi-version Node/Python

**Couche 3 — Environnements éphémères**
- Services Docker (PostgreSQL, Redis, MongoDB) via `services:`
- Pas de dépendance à des ressources partagées persistantes
- Isolation complète entre les runs

**Couche 4 — Observabilité et rapports**
- JUnit XML pour résultats de tests
- LCOV/HTML pour rapport de couverture
- Upload vers Codecov ou couverture native GitHub/GitLab
- Artifacts : traces Playwright, screenshots d'échec
- Badge de statut CI dans README
- Quality gate : échec si couverture < {coverage_threshold}%

<action>Valider l'architecture avec {user_name} avant de générer les fichiers</action>
</step>

<step n="3" goal="Générer le pipeline GitHub Actions (si applicable)">
<action>Si `{platform}` est `github` ou `both`, créer `.github/workflows/tests.yml`</action>

<action>Utiliser le template GitHub Actions adapté au stack détecté</action>

**Structure générée :**
```yaml
# .github/workflows/tests.yml
# Harmony TestArch — Pipeline de test 4 couches

name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    # Tests unitaires rapides

  integration-tests:
    # Tests d'intégration avec services Docker
    services:
      postgres:
        image: postgres:16-alpine
        # ...

  e2e-tests:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]  # 4 shards parallèles
    # Tests E2E Playwright

  quality-gate:
    needs: [unit-tests, integration-tests]
    # Vérification du seuil de couverture
```

<action>Écrire le fichier complet avec cache npm/pip/go, artifacts, et notifications</action>
</step>

<step n="4" goal="Générer le pipeline GitLab CI (si applicable)">
<action>Si `{platform}` est `gitlab` ou `both`, créer ou mettre à jour `.gitlab-ci.yml`</action>

**Structure générée :**
```yaml
# .gitlab-ci.yml
# Harmony TestArch — Pipeline de test 4 couches

stages:
  - lint
  - test-unit
  - test-integration
  - test-e2e
  - quality-gate
  - report

variables:
  COVERAGE_THRESHOLD: "{coverage_threshold}"

# Cache partagé pour dépendances
.node_cache: &node_cache
  cache:
    key: "$CI_COMMIT_REF_SLUG"
    paths:
      - node_modules/
      - .pnpm-store/

unit-tests:
  stage: test-unit
  # ...

integration-tests:
  stage: test-integration
  services:
    - name: postgres:16-alpine
      alias: postgres
  # ...

e2e-tests:
  stage: test-e2e
  parallel: 4
  script:
    - npx playwright test --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
  # ...

quality-gate:
  stage: quality-gate
  script:
    - |
      coverage=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
      if (( $(echo "$coverage < $COVERAGE_THRESHOLD" | bc -l) )); then
        echo "❌ Coverage $coverage% < threshold $COVERAGE_THRESHOLD%"
        exit 1
      fi
```

<action>Écrire le fichier complet avec cache, artifacts Allure/JUnit, et badges de couverture</action>
</step>

<step n="5" goal="Valider et documenter le pipeline">
<action>Valider la syntaxe des fichiers CI générés :</action>
- GitHub Actions : `actionlint` si disponible, sinon vérification manuelle de la structure YAML
- GitLab CI : vérification syntaxique YAML

<action>Ajouter dans `README.md` :</action>
```markdown
## CI/CD

![Tests](https://github.com/{owner}/{repo}/actions/workflows/tests.yml/badge.svg)
![Coverage]({codecov_badge_url})

### Pipeline
- **Unit tests** : Lancés sur chaque push
- **Integration tests** : Lancés sur chaque push (avec PostgreSQL/Redis Docker)
- **E2E tests** : Lancés sur PR et merge vers main (4 shards Playwright)
- **Quality gate** : Couverture minimum {coverage_threshold}% requise
```

<action>Afficher à {user_name} un résumé du pipeline configuré avec les prochaines étapes (créer secrets, configurer Codecov, etc.)</action>
</step>

</workflow>
