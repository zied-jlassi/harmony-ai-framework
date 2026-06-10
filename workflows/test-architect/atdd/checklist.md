# Checklist : ATDD — Acceptance Test Driven Development

## Prérequis
- [ ] Story chargée avec critères d'acceptation documentés
- [ ] Framework de test installé et configuré
- [ ] Environnement de test fonctionnel (les tests existants passent)

## Discovery (Example Mapping / Three Amigos)
- [ ] Atelier Three Amigos réalisé (produit + dev + test)
- [ ] Règles métier, exemples concrets (nominal/erreur/limite) et questions ouvertes cartographiés
- [ ] Questions ouvertes (cartes rouges) levées avant de coder

## Formalisation (spécifications exécutables)
- [ ] Critères transformés en scénarios Given/When/Then (Gherkin)
- [ ] Happy path, cas d'erreur et cas limites (BVA, null/vide) couverts
- [ ] Pour les API : contract testing (OpenAPI/Pact) privilégié à l'E2E lourd
- [ ] Scénarios générés par IA (si utilisés) passés en **revue humaine**
- [ ] NFR extraites et référencées (performance, sécurité, accessibilité)

## Phase RED — tests créés et en échec
- [ ] Fichier d'acceptation créé dans `tests/acceptance/` (`{story-id}-{feature}.test.ts`)
- [ ] ≥ 1 test par critère d'acceptation ; assertions spécifiques (pas de `toBeTruthy()`)
- [ ] Sélecteurs résilients (rôles ARIA, data-testid stables)
- [ ] Tous les tests **échouent** pour la bonne raison (assertion, pas erreur de syntaxe)
- [ ] Statut `atdd_status: RED` mis à jour dans la story

## Guidage de l'implémentation
- [ ] Tests présentés comme guide ; ordre d'implémentation (simple → complexe)
- [ ] Dépendances techniques identifiées (services, DB, routes)

## Phase GREEN — implémentation validée
- [ ] Tous les tests d'acceptation **passent**
- [ ] Aucune régression sur les tests existants ; couverture ≥ seuil (défaut 80%)
- [ ] Tests d'acceptation **non-flaky** (3 exécutions consécutives stables)
- [ ] Statut `atdd_status: GREEN` mis à jour

## Phase REFACTOR (optionnelle)
- [ ] Refactoring effectué sans modifier les tests ; tests toujours verts
- [ ] La suite Gherkin sert de **documentation vivante** de la feature

## Critères de sortie
- [ ] Tous les CA ont un test correspondant, en phase GREEN
- [ ] Story mise à jour avec référence aux tests
