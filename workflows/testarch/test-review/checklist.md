# Checklist : Revue Qualité des Tests

## Prérequis
- [ ] Tests existants localisés selon le scope défini
- [ ] Rapport de couverture disponible ou générable
- [ ] Accès aux résultats CI récents (tests flaky détectables)

## Inventaire et métriques de base
- [ ] Nombre total de fichiers de test compté
- [ ] Nombre total de cas de test compté
- [ ] Distribution unit / integration / E2E calculée
- [ ] Ratio tests/code évalué
- [ ] Couverture line / branch / function mesurée

## Détection des anti-patterns

### Ice Cream Cone (pyramide inversée)
- [ ] Ratio E2E < 30% du total des tests
- [ ] Tests unitaires > 50% du total
- [ ] Sinon → recommandation de rééquilibrage documentée

### Tests sans assertions
- [ ] Aucun test avec body vide (`it('...', () => {})`)
- [ ] Aucun test avec uniquement `console.log` ou `console.error`
- [ ] Chaque test a au moins une assertion `expect()` / `assert`

### Tests couplés
- [ ] Pas de variables mutables partagées entre tests sans reset
- [ ] `beforeEach` utilisé pour l'initialisation (pas `before`)
- [ ] `afterEach` / `afterAll` présents pour le cleanup si nécessaire
- [ ] Ordre d'exécution des tests ne modifie pas les résultats

### Over-mocking
- [ ] Les mocks testent le comportement, pas l'implémentation
- [ ] Au moins une assertion sur le résultat (pas uniquement `toHaveBeenCalled`)
- [ ] Ce qui est testé n'est pas lui-même mocké

### Tests flaky
- [ ] Pas de `Date.now()` / `new Date()` sans `vi.useFakeTimers()` / freeze
- [ ] Pas de `Math.random()` sans seed fixe
- [ ] Pas de `setTimeout` / `setInterval` réels dans les tests unitaires
- [ ] Pas d'appels réseau réels (fetch/axios/http) sans msw/nock/httptest
- [ ] Pas de `sleep()` ou attente arbitraire dans les tests

### Tests lents
- [ ] Tests unitaires : aucun > 100ms
- [ ] Tests d'intégration : aucun > 2000ms
- [ ] Fichiers volumineux analysés pour optimisation

### Tests morts (dead tests)
- [ ] Pas de tests avec `.skip` / `xit` / `xdescribe` depuis > 30 jours
- [ ] Pas de tests commentés (code mort)

## Qualité des assertions
- [ ] Matchers spécifiques utilisés (`toEqual`, `toMatchObject`, `toContain`)
- [ ] Évitement de `toBeTruthy()` / `toBeDefined()` quand plus précis possible
- [ ] Assertions sur les arguments des mocks si pertinent
- [ ] Cas d'erreur ont des assertions sur le type d'erreur ET le message

## Rapport produit
- [ ] Rapport de revue écrit dans `docs/test-review-{date}.md`
- [ ] Anti-patterns listés avec fichiers et lignes
- [ ] Recommandations P1/P2/P3 définies
- [ ] Plan d'action avec effort estimé inclus

## Critères de sortie
- [ ] Aucun anti-pattern critique (P1) non documenté
- [ ] Score qualité calculé et communiqué
- [ ] Actions prioritaires présentées à {user_name}
