# Workflow : ATDD — Acceptance Test Driven Development

<critical>Ce workflow implémente le cycle RED → GREEN → REFACTOR à partir des critères d'acceptation d'une story Harmony. Les tests d'acceptation doivent être écrits et en échec AVANT toute implémentation.</critical>

<workflow>

<step n="1" goal="Charger la story et ses critères d'acceptation">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Localiser la story cible :</action>
1. Si `{story_id}` fourni → chercher `{sprint_artifacts}/{story_id}*.md`
2. Si `{story_file}` fourni → charger directement
3. Sinon → lire `{working_memory}` → champ `current_story`

<action>Extraire de la story :</action>
- **Titre** et **description** (contexte utilisateur)
- **Critères d'acceptation** (section `## Acceptance Criteria` ou `## Critères d'acceptation`)
- **Définition of Done** (DoD) si présente
- **Contraintes techniques** mentionnées

<action>Si aucun critère d'acceptation trouvé → arrêter et demander à {user_name} de les compléter avant de continuer</action>
</step>

<step n="2" goal="Analyser et structurer les critères d'acceptation">
<action>Pour chaque critère d'acceptation, identifier :</action>

- **Type** : fonctionnel | performance | sécurité | accessibilité | UX
- **Priorité** : critique (bloquant) | majeur | mineur
- **Testabilité** : est-il mesurable et vérifiable automatiquement ?

<action>Transformer chaque critère en scenario Gherkin (Given/When/Then) :</action>

**Exemple de transformation :**
```
Critère original :
"L'utilisateur doit pouvoir se connecter avec email + mot de passe"

→ Scenario Gherkin :
Scenario: Connexion réussie avec identifiants valides
  Given un utilisateur enregistré avec l'email "user@example.com"
  And son mot de passe est "SecureP@ss123"
  When il soumet le formulaire de connexion
  Then il est redirigé vers le tableau de bord
  And un token JWT valide est retourné

Scenario: Échec de connexion avec mauvais mot de passe
  Given un utilisateur enregistré avec l'email "user@example.com"
  When il soumet le formulaire avec le mot de passe "wrong"
  Then une erreur 401 est retournée
  And le message "Identifiants invalides" est affiché
```

<action>Identifier les edge cases à couvrir :</action>
- Cas nominaux (happy path)
- Cas d'erreur (inputs invalides, état inattendu)
- Cas limites (boundary values, valeurs nulles/vides)
- Cas de concurrence si pertinent
</step>

<step n="3" goal="Détecter le framework de test et créer les fichiers d'acceptation">
<action>Vérifier le framework de test installé (lire `vitest.config.*`, `jest.config.*`, `pytest.ini`, etc.)</action>

<action>Créer le fichier de test d'acceptation dans le répertoire approprié :</action>

**Structure de fichier recommandée :**
```
tests/
├── acceptance/         ← Nouveaux tests ATDD
│   └── {story-id}-{slug}.test.ts
├── unit/
└── integration/
```

**Template TypeScript/Vitest :**
```typescript
// tests/acceptance/{story-id}-{feature-slug}.test.ts
// Story: {story_id} - {story_title}
// Critères d'acceptation couverts: CA-1, CA-2, CA-3

import { describe, it, expect, beforeEach } from 'vitest'

describe('{Feature} — Acceptance Tests', () => {

  describe('CA-1: {critère_1}', () => {
    it('should {comportement_attendu} when {condition}', async () => {
      // Arrange (Given)
      // ...

      // Act (When)
      // ...

      // Assert (Then)
      expect(result).toBeDefined() // ← Remplacer par assertion réelle
    })
  })

})
```

**Template Python/pytest :**
```python
# tests/acceptance/test_{story_id}_{feature_slug}.py
# Story: {story_id} - {story_title}

import pytest

class TestCA1_{FeatureName}:
    """CA-1: {critère_1}"""

    def test_{scenario_nominal}(self):
        # Arrange
        # ...
        # Act
        # ...
        # Assert
        assert result is not None  # ← Remplacer par assertion réelle
```
</step>

<step n="4" goal="Vérifier la phase RED — tous les tests doivent échouer">
<action>Lancer les tests d'acceptation créés</action>

<action>Vérifier que TOUS les tests échouent (phase RED) :</action>
- Si un test passe déjà → analyser pourquoi (feature déjà implémentée ?)
- Si un test lève une erreur de compilation → corriger la syntaxe uniquement, pas la logique
- Les tests doivent échouer pour la BONNE raison (assertion non satisfaite, pas erreur technique)

<action>Documenter l'état RED dans la story :</action>
```yaml
# Dans le fichier story
atdd_status:
  phase: RED
  tests_created: {nombre}
  tests_failing: {nombre}
  test_file: tests/acceptance/{fichier}
```
</step>

<step n="5" goal="Guider l'implémentation (transition vers GREEN)">
<action>Afficher à {user_name} le résumé des tests créés et leur état RED</action>

<action>Préparer le contexte pour le workflow `dev-story` :</action>
- Lister les tests d'acceptation comme critères de succès
- Préciser l'ordre d'implémentation recommandé (du plus simple au plus complexe)
- Identifier les dépendances techniques à créer (services, repositories, API routes)

<action>Message à {user_name} :</action>
```
✅ Phase RED confirmée — {n} tests d'acceptation créés et en échec.

Prochaine étape : lancer /hf:dev-story pour implémenter la story.
Les tests d'acceptation servent de guide et de critères de validation.

Commande de suivi des tests :
  {test_run_command} --watch tests/acceptance/{fichier}
```
</step>

<step n="6" goal="Valider la phase GREEN après implémentation">
<action>Une fois l'implémentation signalée par {user_name}, lancer les tests d'acceptation</action>

<action>Critères de validation GREEN :</action>
- [ ] Tous les tests d'acceptation passent
- [ ] Aucune régression dans les tests unitaires existants
- [ ] Couverture de code ≥ seuil configuré (défaut : 80%)
- [ ] Temps d'exécution des tests acceptable (< 30s pour acceptance tests)

<action>Si tests encore en échec → analyser l'écart entre implémentation et critères, suggérer les corrections</action>

<action>Phase REFACTOR : vérifier que les tests passent toujours après refactoring</action>

<action>Mettre à jour le statut ATDD dans la story :</action>
```yaml
atdd_status:
  phase: GREEN
  tests_passing: {nombre}
  coverage: {pourcentage}%
  validated_at: {date}
```
</step>

</workflow>
