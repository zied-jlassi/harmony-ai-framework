# Workflow : Automatisation des Tests et Couverture

<critical>Ce workflow analyse la couverture de code existante et génère les tests manquants pour atteindre les seuils de qualité définis. Il travaille sur le code existant, pas sur du code à venir.</critical>

<workflow>

<step n="1" goal="Scanner la codebase et détecter le stack de test">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Identifier le scope d'analyse selon `{scope}` :</action>
- `changed` → fichiers modifiés depuis le dernier commit (`git diff --name-only HEAD`)
- `all` → tous les fichiers source
- `path/to/module` → répertoire spécifique

<action>Détecter le framework de test installé :</action>
- Lire `package.json` (jest, vitest, playwright, cypress)
- Lire `pyproject.toml` / `pytest.ini` (pytest, behave)
- Lire `go.mod` (go test)
- Lire `Cargo.toml` (cargo test)

<action>Localiser les fichiers de test existants :</action>
```
Patterns reconnus :
  *.test.ts, *.spec.ts, *.test.js, *.spec.js  (JS/TS)
  test_*.py, *_test.py                         (Python)
  *_test.go                                    (Go)
  #[test] dans *.rs                            (Rust)
  *Spec.java, *Test.java                       (Java)
```
</step>

<step n="2" goal="Analyser la couverture de code actuelle">
<action>Lancer l'outil de couverture selon le framework détecté :</action>

| Framework | Commande couverture |
|-----------|---------------------|
| Vitest | `vitest run --coverage` |
| Jest | `jest --coverage` |
| pytest | `pytest --cov=src --cov-report=term-missing` |
| go test | `go test ./... -cover -coverprofile=coverage.out` |
| cargo | `cargo tarpaulin --out Html` |
| JUnit | `mvn test jacoco:report` |

<action>Parser le rapport de couverture et identifier :</action>
- **Line coverage** global (%)
- **Branch coverage** global (%)
- **Function coverage** global (%)
- **Fichiers sous le seuil** ({coverage_threshold}%) triés par priorité
- **Fichiers sans aucun test** (0% coverage)

<action>Si impossible de lancer les tests (erreurs) → signaler à {user_name} et stopper</action>
</step>

<step n="3" goal="Analyser les fichiers sous-couverts et prioriser">
<action>Pour chaque fichier sous le seuil {coverage_threshold}%, analyser :</action>

**Critères de priorisation (ordre décroissant) :**
1. Fichiers modifiés récemment (git blame)
2. Fichiers avec logique métier critique (patterns : service, repository, handler, controller, use-case)
3. Fichiers avec haute complexité cyclomatique (beaucoup de branches if/switch)
4. Fichiers publics (exportés, API de la lib)
5. Fichiers utilitaires partagés

<action>Classer chaque fichier en catégorie de test manquant :</action>
- **Tests unitaires** : fonctions pures, classes avec peu de dépendances
- **Tests d'intégration** : services avec injection de dépendances, accès DB/API
- **Tests de contrat (Pact)** : interfaces entre microservices

<action>Créer le plan de génération (max 5 fichiers par exécution pour rester focalisé)</action>
</step>

<step n="4" goal="Générer les tests manquants">
<action>Pour chaque fichier prioritaire, appliquer la stratégie suivante :</action>

**Règles de génération :**
1. **Un fichier source → un fichier de test** (même structure de répertoire)
2. **Une fonction → au moins 2 cas** : happy path + cas d'erreur
3. **Chaque branche (if/else/switch) → un cas de test**
4. **Boundary values** : tester les valeurs limites (0, -1, max, null, undefined, "")
5. **Isolation** : mocker toutes les dépendances externes (DB, HTTP, filesystem, date/time)

**Template de test unitaire TypeScript/Vitest :**
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { {FunctionName} } from '../{path-to-source}'

// Mock des dépendances
vi.mock('../{dependency}', () => ({
  {dependencyMethod}: vi.fn()
}))

describe('{FunctionName}', () => {

  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should {expected_behavior} when {condition}', () => {
    // Arrange
    const input = {valid_input}

    // Act
    const result = {FunctionName}(input)

    // Assert
    expect(result).toEqual({expected_output})
  })

  it('should throw {ErrorType} when {invalid_condition}', () => {
    // Arrange
    const invalidInput = {invalid_value}

    // Act & Assert
    expect(() => {FunctionName}(invalidInput)).toThrow({ErrorType})
  })

})
```

**Template de test d'intégration avec mock :**
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { createTestContainer } from '../helpers/test-container'

describe('{ServiceName} — Integration', () => {
  let service: {ServiceType}
  let mockRepository: ReturnType<typeof vi.fn>

  beforeEach(() => {
    mockRepository = {
      findById: vi.fn(),
      save: vi.fn(),
    }
    service = new {ServiceName}(mockRepository)
  })

  it('should {behavior} when repository returns {data}', async () => {
    // Arrange
    mockRepository.findById.mockResolvedValue({mock_data})

    // Act
    const result = await service.{method}({id})

    // Assert
    expect(result).toMatchObject({expected})
    expect(mockRepository.findById).toHaveBeenCalledWith({id})
  })
})
```

<action>Écrire les fichiers de test générés</action>
<action>Lancer les tests générés immédiatement pour vérifier qu'ils compilent et passent</action>
<action>Corriger toute erreur de compilation (types, imports) sans modifier la logique de test</action>
</step>

<step n="5" goal="Mesurer l'amélioration et rapporter">
<action>Relancer la couverture après génération des tests</action>

<action>Comparer avant/après :</action>
```
Couverture AVANT : {coverage_before}%
Couverture APRÈS : {coverage_after}%
Amélioration     : +{delta}%
Seuil cible      : {coverage_threshold}%
Statut           : {ATTEINT|EN_COURS|INSUFFISANT}
```

<action>Lister les fichiers encore sous le seuil avec les branches non couvertes</action>

<action>Si seuil non atteint → proposer les prochains fichiers à traiter</action>

<action>Mettre à jour `.harmony/memory/working.json` si une story est en cours :</action>
```json
{
  "test_coverage": {
    "last_run": "{date}",
    "coverage_pct": {coverage_after},
    "threshold": {coverage_threshold},
    "files_generated": {count}
  }
}
```
</step>

</workflow>
