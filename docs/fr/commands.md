# Référence des Commandes Harmony

> **🌐 Langue :** [English](../commands.md) · Français

> Référence complète des 35 commandes Harmony.

---

## Référence rapide

```bash
/go                    # Démarrage de session
/harmony               # Menu interactif
```

---

## Commandes par catégorie

### Framework de validation (1-5)

| Commande | Description |
|----------|-------------|
| `/harmony full` | Audit complet (~2-5 min) |
| `/harmony quick` | Check rapide (~30s) |
| `/harmony duplicates` | Détection de duplicats |
| `/harmony fix` | Proposer des corrections |
| `/harmony fix --apply` | Appliquer avec confirmation |
| `/harmony watch` | Pre-commit hook |
| `/harmony watch --install` | Installer le hook |
| `/harmony watch --status` | Statut du hook |

### Rapports (6-7)

| Commande | Description |
|----------|-------------|
| `/harmony report` | Matrice de cohérence |
| `/harmony report --verbose` | Détails par catégorie |
| `/harmony tokens` | Coût tokens par agent |
| `/harmony tokens --breakdown` | Détails par agent |
| `/harmony tokens --optimize` | Suggestions d'optimisation |

### Validation spécifique (8-10)

| Commande | Description |
|----------|-------------|
| `/harmony pipeline` | Cohérence pipeline config vs docs |
| `/harmony pipeline --verbose` | Détails complets |
| `/harmony pipeline --fix` | Proposer des corrections |
| `/harmony hooks` | Validation des hooks Claude |
| `/harmony hooks --install` | Installer les hooks par défaut |
| `/harmony hooks --status` | Statut des hooks |
| `/harmony patterns` | Validation des patterns |
| `/harmony patterns --fix` | Proposer des corrections |

### Synchronisation (11-12)

| Commande | Description |
|----------|-------------|
| `/harmony memory` | Sync MCP <-> CLAUDE.md |
| `/harmony memory --diff` | Afficher les différences |
| `/harmony claude` | Validation config Claude Code |
| `/harmony claude --update` | MAJ des règles (pattern GADER) |
| `/harmony claude --fix` | Proposer des corrections |

### Application des règles (13-15)

| Commande | Description |
|----------|-------------|
| `/harmony rules` | Audit des règles |
| `/harmony rules --usage` | Usage dans le code |
| `/harmony rules --report` | Rapport de conformité |

### Harmony Sentinel (16-20)

| Commande | Description |
|----------|-------------|
| `/harmony sentinel` | Dashboard santé (défaut) |
| `/harmony sentinel --status` | Alias pour status |
| `/harmony sentinel --learn` | Documenter une erreur |
| `/harmony sentinel --reset` | Réinitialiser le Circuit Breaker |
| `/harmony sentinel --check` | Vérification complète |
| `/harmony sentinel --report` | Rapport détaillé |

### Knowledge & Profils (21-23)

| Commande | Description |
|----------|-------------|
| `/harmony learn <url>` | Apprendre depuis une URL |
| `/harmony profiles` | Lister les profils |
| `/harmony profiles --active` | Afficher les actifs |
| `/harmony profiles --add <name>` | Activer un profil |
| `/harmony profiles --remove <name>` | Désactiver un profil |
| `/harmony specialties` | Lister les spécialités |
| `/harmony specialties --active` | Afficher les actives |
| `/harmony specialties --add <name>` | Activer une spécialité |
| `/harmony specialties --remove <name>` | Désactiver une spécialité |

### Intégrations (24-25)

| Commande | Description |
|----------|-------------|
| `/harmony install <ide>` | Déployer vers un IDE |
| `/harmony install --status` | Afficher les intégrations |

### Qualité HQVF (26-27)

| Commande | Description |
|----------|-------------|
| `/harmony ucv <story>` | Créer les UCVs |
| `/harmony ucv --validate <story>` | Vérifier la couverture |

### Framework (28-30)

| Commande | Description |
|----------|-------------|
| `/harmony init` | Initialiser Harmony |
| `/harmony upgrade` | Mettre à jour le framework |
| `/harmony upgrade --check` | Vérifier les mises à jour |
| `/harmony export` | Exporter la configuration |
| `/harmony export --full` | Export complet avec mémoire |

### Session & Config (31-35)

| Commande | Description |
|----------|-------------|
| `/harmony go` | Démarrage de session - initialise le contexte |
| `/harmony config` | **Configuration en langage naturel** |
| `/harmony config show` | Afficher la config actuelle |
| `/harmony config reset` | Réinitialiser la config |
| `/harmony coverage` | Rapport de couverture UCV |
| `/harmony coverage <epic>` | Couverture pour un Epic |
| `/harmony matrix` | Générer un cahier des charges |
| `/harmony matrix <epic>` | Cahier des charges pour un Epic |
| `/harmony test-book` | Générer un cahier de test |
| `/harmony test-book <epic>` | Cahier de test pour un Epic |

> **Nouveau** : `/harmony config` permet de configurer Harmony en **langage naturel**.
> Voir [Natural Language Config](natural-language-config.md) pour les détails.

---

## Exemples

### Workflow quotidien

```bash
# Démarrer la session
/go

# Check rapide avant commit
/harmony quick

# Audit complet avant PR
/harmony full
```

### Gestion des erreurs

```bash
# Voir le dashboard d'erreurs
/harmony sentinel

# Documenter une erreur résolue
/harmony sentinel --learn

# Réinitialiser le circuit breaker après diagnostic
/harmony sentinel --reset
```

### Vérification qualité

```bash
# Créer les UCVs pour une story
/harmony ucv STORY-042

# Valider la couverture
/harmony ucv --validate STORY-042
```

### Configuration en langage naturel

```bash
# Ouvrir l'assistant config
/harmony config

# Exemples de phrases :
"Bloquer DROP DATABASE sur la production"
"Docker obligatoire avec prefix myapp"
"5 echecs max avant circuit breaker"
"Desactiver l'agent pentest"
```

> Voir [Natural Language Config](natural-language-config.md) pour plus d'exemples.
