# TDD Workflow (Test-Driven Development)

> **Usage**: Developer Agent - Cycle obligatoire pour chaque feature
> **CRITIQUE**: Coverage 100% obligatoire - Une seule faille peut tout casser

---

## Cycle TDD (Red-Green-Refactor)

```
┌─────────────────────────────────────────────────────┐
│                    TDD CYCLE                         │
│                                                     │
│     RED                                           │
│     └─ Écrire un test qui ÉCHOUE                    │
│         │                                           │
│         ▼                                           │
│     GREEN                                         │
│     └─ Écrire le code MINIMAL pour passer           │
│         │                                           │
│         ▼                                           │
│     REFACTOR                                      │
│     └─ Améliorer sans casser les tests              │
│         │                                           │
│         └──────────► Répéter                        │
└─────────────────────────────────────────────────────┘
```

---

## Coverage OBLIGATOIRE

```
┌─────────────────────────────────────────────────────┐
│          COVERAGE = 100%                            │
│                                                     │
│  Une seule faille dans le code peut TOUT CASSER.    │
│                                                     │
│  • Unit tests: 100% (OBLIGATOIRE)                   │
│  • Branch coverage: 100%                            │
│  • Line coverage: 100%                              │
│                                                     │
│  SI Tester n'a pas validé 100% coverage:            │
│  → REFUSER le handoff                               │
│  → Renvoyer au Developer                            │
└─────────────────────────────────────────────────────┘
```

---

## Test Strategy par Couche

| Test Type | Coverage | Responsibility | Framework |
|-----------|----------|----------------|-----------|
| **Unit tests** | **100%** | Developer | Jest/Vitest |
| Integration tests | Critical paths | Developer + Tester | Supertest |
| E2E tests | User journeys | Tester | Playwright |
| Exploratory | UX validation | Exploratory QA | Manual |

---

## Règles TDD

| Règle | Description |
|-------|-------------|
| **T1** | Écrire le test AVANT le code |
| **T2** | Un seul assert par test (idéalement) |
| **T3** | Tests indépendants (pas d'ordre) |
| **T4** | Noms descriptifs (should_do_X_when_Y) |
| **T5** | JAMAIS skip des tests |
| **T6** | **100% coverage ou BLOQUER** |

---

## Validation Coverage

```bash
# Vérifier coverage AVANT handoff
npm run test:cov

# Output attendu:
# Statements   : 100% ( XX/XX )
# Branches     : 100% ( XX/XX )
# Functions    : 100% ( XX/XX )
# Lines        : 100% ( XX/XX )
```

**SI coverage < 100%:**
1. Identifier les lignes non couvertes
2. Ajouter les tests manquants
3. Re-run jusqu'à 100%
4. JAMAIS merge avec coverage < 100%

---

## Structure de Test

```typescript
describe('UserService', () => {
  describe('create', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const dto = { email: 'test@test.com', name: 'Test' };

      // Act
      const result = await service.create(dto);

      // Assert
      expect(result.email).toBe(dto.email);
    });

    it('should throw on duplicate email', async () => {
      // Arrange + Act + Assert
      await expect(service.create(existingUser))
        .rejects.toThrow(ConflictException);
    });

    // EDGE CASES - Obligatoires pour 100% coverage
    it('should handle null input', async () => { ... });
    it('should handle empty string', async () => { ... });
    it('should handle special characters', async () => { ... });
  });
});
```

---

## Anti-Patterns à Éviter

| Anti-Pattern | Problème | Solution |
|--------------|----------|----------|
| Test après code | Bias de confirmation | TDD strict |
| Tests couplés | Échec en cascade | Isolation |
| Mocks excessifs | Faux positifs | Integration tests |
| Tests lents | CI bloquée | Parallélisation |
| Coverage < 100% | **BUGS EN PROD** | **BLOQUER MERGE** |
| Skip tests | Régression silencieuse | CI qui fail |

---

## Gate Tester

Le Tester DOIT vérifier:

1. Coverage rapport = 100%
2. TOUS les edge cases testés
3. Error paths testés
4. Boundary conditions testées

**SI non conforme → Retour au Developer**
