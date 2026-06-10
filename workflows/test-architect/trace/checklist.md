# Checklist : Matrice de Traçabilité

## Prérequis
- [ ] Sources d'exigences disponibles (stories, AC, PRD, spécifications)
- [ ] Tests existants accessibles (répertoire `tests/`)
- [ ] Seuil de couverture configuré ({coverage_threshold}%)

## Collecte des exigences
- [ ] Toutes les stories du scope chargées ; AC extraits et numérotés (CA-{epic}-{story}-{n})
- [ ] NFR identifiées et référencées (NFR-{cat}-{n}) ; total des exigences compté
- [ ] Idéal : exigences taguées **à la source** (requirements-as-code)

## Inventaire des tests
- [ ] Tous les fichiers de test scannés
- [ ] Tests référençant explicitement des exigences identifiés (`@requirement`, `@covers`)
- [ ] Correspondance sémantique pour les tests sans tag, marquée « déduit » vs « explicite »
- [ ] Tags manquants proposés par IA → **revue humaine** avant fiabilisation
- [ ] Tests orphelins identifiés (aucune exigence associée)

## Matrice bidirectionnelle
- [ ] Vue Exigences → Tests (couverture) et vue Tests → Exigences (justification) créées
- [ ] Exigences non couvertes listées avec niveau de risque ; tests orphelins listés
- [ ] Une cellule vide = un maillon manquant explicitement signalé

## Métriques calculées
- [ ] Taux de couverture {covered}/{total} (%) ; part **explicite** vs **déduite**
- [ ] Exigences critiques non couvertes identifiées séparément ; résultat vs seuil évalué

## Rapport et intégration CI (living traceability)
- [ ] Matrice dans `docs/test-traceability.md` + rapport JSON machine-readable
- [ ] **Quality gate** : pipeline échoue si couverture < {coverage_threshold}%
- [ ] Matrice régénérée en CI (synchronisée par construction)

## Actions sur les lacunes
- [ ] Lacunes critiques documentées avec recommandation de tests à créer (ordre par risque)
- [ ] Tests orphelins examinés (obsolètes à supprimer ou exigences à documenter)
- [ ] Plan de comblement présenté à {user_name}

## Critères de sortie
- [ ] Couverture ≥ {coverage_threshold}% OU plan documenté ; 0 exigence critique non couverte
- [ ] Matrice à jour et commitée
