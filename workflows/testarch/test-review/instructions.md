# Workflow : Revue Qualité des Tests (Test Review)

<critical>Ce workflow audite la qualité des tests existants. Il détecte les anti-patterns, mesure la pertinence de la couverture (au-delà du simple pourcentage) et produit des recommandations actionnables.</critical>

<workflow>

<step n="1" goal="Scanner et inventorier les tests existants">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Localiser tous les fichiers de test selon le scope `{scope}` :</action>
- `all` → récursivement dans `tests/`, `src/**/__tests__/`, `spec/`
- `unit` → filtrer les tests unitaires uniquement
- `integration` → filtrer les tests d'intégration
- `e2e` → filtrer les tests E2E (playwright, cypress)

<action>Calculer les métriques de base :</action>
- Nombre total de fichiers de test
- Nombre total de cas de test (`it()`, `test()`, `def test_`, `#[test]`)
- Ratio tests/code (nombre de fichiers source vs fichiers test)
- Distribution unit / integration / E2E
- Dernière modification de chaque fichier de test
</step>

<step n="2" goal="Détecter les anti-patterns critiques">
<action>Analyser chaque fichier de test et détecter les problèmes suivants :</action>

**Anti-pattern 1 — Ice Cream Cone (pyramide inversée)**
```
Symptôme : Plus de tests E2E que de tests unitaires
Seuil d'alerte : ratio E2E > 30% du total
Impact : Pipeline lent, feedback tardif, debugging difficile
```

**Anti-pattern 2 — Tests sans assertions**
```
Symptôme : it('should do something', () => {}) sans expect()
Détection : grep "it\(|test\(" sans "expect\(|assert" dans la même fonction
Impact : Faux sentiment de couverture — tests inutiles qui passent toujours
```

**Anti-pattern 3 — Tests couplés / ordre-dépendants**
```
Symptôme : Tests qui partagent un état global, beforeAll sans afterAll
Détection : Variables mutables déclarées hors beforeEach, absence de cleanup
Impact : Résultats aléatoires, tests qui passent seuls mais échouent ensemble
```

**Anti-pattern 4 — Mocks excessifs (over-mocking)**
```
Symptôme : Tout est mocké, y compris ce qui est testé
Détection : Plus de vi.mock()/jest.mock() que d'assertions réelles
Impact : Tests qui testent l'implémentation, pas le comportement
```

**Anti-pattern 5 — Tests trop larges (God tests)**
```
Symptôme : Un seul test avec 20+ assertions, ou un describe() avec 50+ cas
Détection : Nombre d'assertions > 10 par test
Impact : Maintenance difficile, cause d'échec impossible à isoler
```

**Anti-pattern 6 — Tests flaky (résultats aléatoires)**
```
Symptôme : Tests qui dépendent de l'heure, dates, ordre aléatoire, délais réseau
Détection :
  - Usage de Date.now(), new Date(), Math.random() sans mock
  - setTimeout/setInterval sans vi.useFakeTimers()
  - Appels réseau réels (fetch, axios) sans msw/nock
  - sleep() ou attentes arbitraires dans les tests E2E
```

**Anti-pattern 7 — Tests trop lents**
```
Seuils :
  - Tests unitaires  : > 100ms → problème
  - Tests intégration: > 2s    → problème
  - Tests E2E        : > 30s   → problème
Détection : Analyser les durées depuis le dernier rapport de test
```

**Anti-pattern 8 — Tests mort (dead tests)**
```
Symptôme : Tests désactivés (skip, xit, @pytest.mark.skip) depuis > 30 jours
Détection : grep "\.skip\|xit\|xdescribe\|@pytest.mark.skip" + git blame pour la date
Impact : Accumulation de dette technique, confusion sur la couverture réelle
```
</step>

<step n="3" goal="Évaluer la qualité des assertions">
<action>Pour un échantillon représentatif de tests, évaluer la qualité des assertions :</action>

**Critères d'une bonne assertion :**
- ✅ Teste le **comportement observable**, pas l'implémentation interne
- ✅ Message d'erreur explicite (`.toEqual()` plutôt que `.toBeTruthy()`)
- ✅ Une seule responsabilité par test
- ✅ Utilise des matchers spécifiques (`toMatchObject`, `toContain`, `toBeCloseTo`)

**Assertions à risque :**
- ⚠️ `expect(result).toBeTruthy()` → trop permissif, passe avec n'importe quelle valeur truthy
- ⚠️ `expect(result).toBeDefined()` → passe même si result = 0, "", false
- ⚠️ `expect(fn).not.toThrow()` sans vérifier le résultat retourné
- ⚠️ `expect(mock).toHaveBeenCalled()` sans vérifier les arguments
- ❌ Pas d'assertion du tout

<action>Évaluer la couverture des cas d'erreur :</action>
- Ratio tests nominaux / tests d'erreur (idéal : ~60% nominal, ~40% erreur)
- Edge cases couverts (null, undefined, vide, max, min, types incorrects)
</step>

<step n="4" goal="Analyser la couverture significative vs cosmétique">
<action>Dépasser le simple pourcentage de couverture :</action>

**Couverture significative :**
- Les branches critiques (if/else, switch, ternaires) sont couvertes
- Les chemins d'erreur sont testés (catch, finally, fallback)
- Les cas limites métier sont explicitement testés

**Couverture cosmétique (à éviter) :**
- Tests qui passent toujours car ils ne testent rien de substantiel
- Couverture obtenue uniquement par des snapshots auto-générés
- Couverture de getters/setters sans logique

<action>Identifier les zones à risque non couvertes malgré un bon %, par exemple :</action>
- Gestion des erreurs réseau
- Timeout et retry logic
- Comportement concurrentiel
- Cas de données corrompues
</step>

<step n="5" goal="Produire le rapport de revue et les recommandations">
<action>Écrire le rapport dans `{output_report}` ou `docs/test-review-{date}.md`</action>

**Structure du rapport :**
```markdown
# Rapport de Revue des Tests — {date}

## Résumé exécutif
- Score qualité global : {score}/10
- Anti-patterns détectés : {count}
- Tests flaky identifiés : {count}
- Tests morts : {count}

## Distribution (pyramide)
- Unit : {pct}% ({count} tests)
- Integration : {pct}% ({count} tests)
- E2E : {pct}% ({count} tests)
- Cible recommandée : 70% / 20% / 10%

## Anti-patterns détectés
{liste avec fichiers, lignes, exemples}

## Recommandations prioritaires
### P1 — Critique (à corriger avant merge)
### P2 — Important (sprint courant)
### P3 — Amélioration (backlog)

## Plan d'action
{étapes concrètes avec effort estimé}
```

<action>Afficher à {user_name} les 3 actions les plus prioritaires à effectuer</action>
</step>

</workflow>
