# Checklist : Matrice de Traçabilité

## Prérequis
- [ ] Sources d'exigences disponibles (stories, AC, PRD, spécifications)
- [ ] Tests existants accessibles (répertoire `tests/`)
- [ ] Seuil de couverture configuré ({coverage_threshold}%)

## Collecte des exigences
- [ ] Toutes les stories du scope chargées
- [ ] Critères d'acceptation extraits et numérotés (CA-{epic}-{story}-{n})
- [ ] NFR identifiées et référencées (NFR-{cat}-{n})
- [ ] Total des exigences compté

## Inventaire des tests
- [ ] Tous les fichiers de test scannés
- [ ] Tests référençant explicitement des exigences identifiés (tags @requirement, @covers)
- [ ] Correspondance sémantique appliquée pour les tests sans tag explicite
- [ ] Total des tests comptés
- [ ] Tests orphelins identifiés (aucune exigence associée)

## Matrice construite
- [ ] Vue Exigences → Tests créée (chaque exigence pointe vers ses tests)
- [ ] Vue Tests → Exigences créée (chaque test pointe vers ses exigences)
- [ ] Exigences non couvertes listées avec niveau de risque
- [ ] Tests orphelins listés (possiblement obsolètes)

## Métriques calculées
- [ ] Taux de couverture calculé : {covered}/{total} exigences (%)
- [ ] Couverture explicite vs déduite distinguée
- [ ] Exigences critiques non couvertes identifiées séparément
- [ ] Résultat vs seuil {coverage_threshold}% évalué

## Rapport et intégration CI
- [ ] Matrice écrite dans `docs/test-traceability.md`
- [ ] Rapport JSON machine-readable généré
- [ ] Quality gate défini : pipeline échoue si couverture < {coverage_threshold}%
- [ ] Script CI intégré (GitHub Actions ou GitLab CI)

## Actions sur les lacunes
- [ ] Lacunes critiques documentées avec recommandation de tests à créer
- [ ] Tests orphelins examinés (obsolètes à supprimer ou exigences à documenter)
- [ ] Plan de comblement des lacunes présenté à {user_name}

## Critères de sortie
- [ ] Couverture ≥ {coverage_threshold}% OU plan documenté pour l'atteindre
- [ ] 0 exigence critique non couverte
- [ ] Matrice à jour et commitée dans le dépôt
