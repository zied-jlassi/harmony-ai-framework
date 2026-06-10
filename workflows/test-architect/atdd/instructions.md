# Workflow : ATDD — Acceptance Test Driven Development

> **But** — Implémenter le cycle RED → GREEN → REFACTOR à partir des critères d'acceptation d'une story Harmony. Les tests d'acceptation sont des **spécifications exécutables** (Specification by Example) qui servent aussi de **documentation vivante** : ils doivent être écrits et en échec AVANT toute implémentation.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Charger la story et ses critères d'acceptation

Localiser la story cible :
1. Si `{story_id}` fourni → chercher `{sprint_artifacts}/{story_id}*.md`
2. Si `{story_file}` fourni → charger directement
3. Sinon → lire `{working_memory}` → champ `current_story`

Extraire : titre, description, **critères d'acceptation**, Definition of Done, contraintes techniques. Si aucun critère d'acceptation trouvé → arrêter et demander à `{user_name}` de les compléter avant de continuer.

## 2. Discovery — Example Mapping (Three Amigos)

Avant de formaliser, faire émerger les exemples concrets (atelier « Three Amigos » : produit + dev + test), sur 4 types de cartes :
- 🟡 **Story** (carte jaune en haut)
- 🔵 **Règles** métier qui la gouvernent
- 🟢 **Exemples** concrets illustrant chaque règle — nominal, erreur, limite
- 🔴 **Questions** ouvertes à lever avec `{user_name}` avant implémentation

Objectif : transformer des AC ambiguës en exemples testables et révéler les cas oubliés tôt (shift-left). Beaucoup de cartes rouges = story pas prête.

## 3. Formaliser en spécifications exécutables (Gherkin)

Pour chaque critère : Type (fonctionnel/perf/sécurité/accessibilité/UX), Priorité (critique/majeur/mineur), Testabilité (mesurable ?). Transformer chaque exemple vert en scenario Given/When/Then :

```gherkin
Scenario: Connexion réussie avec identifiants valides
  Given un utilisateur enregistré avec l'email "user@example.com"
  And son mot de passe est "SecureP@ss123"
  When il soumet le formulaire de connexion
  Then il est redirigé vers le tableau de bord
  And un token JWT valide est retourné

Scenario: Échec avec mauvais mot de passe
  Given un utilisateur enregistré avec l'email "user@example.com"
  When il soumet le formulaire avec le mot de passe "wrong"
  Then une erreur 401 est retournée
  And le message "Identifiants invalides" est affiché
```

**Génération assistée par IA** (optionnelle, avec garde-fou) : l'IA peut proposer scénarios et edge cases à partir des AC ; **revue humaine obligatoire** — l'ingénieur valide l'oracle et les cas métier rares. Ne jamais accepter un scénario dont l'assertion n'est pas comprise.

Couvrir : happy path, cas d'erreur (inputs invalides, état inattendu), cas limites (BVA, null/vide), concurrence si pertinent.

## 4. Détecter le framework et créer les tests d'acceptation

Détecter le framework installé (`vitest.config.*`, `jest.config.*`, `pytest.ini`, `playwright.config.*`…). Pour une **API**, privilégier le **contract testing** comme acceptation (schéma OpenAPI / Pact consumer-driven) plutôt que de l'E2E lourd. Créer le fichier d'acceptation (`tests/acceptance/{story-id}-{slug}.test.ts`).

**Template TypeScript/Vitest :**
```typescript
// Story: {story_id} - {story_title} | AC couverts: CA-1, CA-2
import { describe, it, expect } from 'vitest'

describe('{Feature} — Acceptance', () => {
  describe('CA-1: {critère_1}', () => {
    it('should {comportement} when {condition}', async () => {
      // Given / When / Then
      expect(result).toBeDefined() // ← remplacer par l'assertion réelle
    })
  })
})
```
**Template Python/pytest** : `tests/acceptance/test_{story_id}_{slug}.py`, une classe par AC, méthodes Given/When/Then.

Écrire des sélecteurs/assertions **résilients** (rôles ARIA, data-testid stables) pour limiter la fragilité.

## 5. Vérifier la phase RED — tous les tests échouent

Lancer les tests et vérifier qu'ils échouent TOUS pour la BONNE raison (assertion non satisfaite, pas erreur de compilation) :
- Un test qui passe déjà → la feature existe-t-elle déjà ?
- Erreur de syntaxe → corriger la syntaxe uniquement, pas la logique.

Documenter l'état dans la story :
```yaml
atdd_status: { phase: RED, tests_created: {n}, tests_failing: {n}, test_file: tests/acceptance/{fichier} }
```

## 6. Guider l'implémentation (vers GREEN) puis valider

Préparer le contexte pour `dev-story` : tests = critères de succès, ordre d'implémentation (simple → complexe), dépendances à créer.

```
✅ Phase RED confirmée — {n} tests d'acceptation en échec.
Prochaine étape : /hf:dev-story pour implémenter.
Suivi : {test_run_command} --watch tests/acceptance/{fichier}
```

Après implémentation, valider GREEN :
- [ ] Tous les tests d'acceptation passent
- [ ] Aucune régression sur les tests existants
- [ ] Couverture ≥ seuil configuré (défaut 80%)
- [ ] Tests d'acceptation non-flaky (3 exécutions consécutives stables)

Phase REFACTOR : les tests doivent rester verts après refactoring. La suite Gherkin devient la **documentation vivante** de la feature. Mettre à jour le statut :
```yaml
atdd_status: { phase: GREEN, tests_passing: {n}, coverage: {pct}%, validated_at: {date} }
```
