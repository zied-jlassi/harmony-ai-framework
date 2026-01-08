# Configuration en Langage Naturel

> **Commande**: `/harmony config`

Configurez Harmony en parlant normalement, sans éditer de fichiers YAML.

---

## Principe

```
Vous dites                          →  Harmony génère
────────────────────────────────────────────────────────────────
"Bloquer DROP DATABASE"             →  rules_enforcer.add_dangerous_patterns
"Utiliser Docker"                   →  docker.required: true
"Désactiver le circuit breaker"     →  sentinel.circuit_breaker.enabled: false
```

---

## Exemples d'utilisation

### Sécurité & Règles

```
"Je veux bloquer DROP DATABASE sur ma base production"
```
```yaml
# Résultat dans .harmony/local/config/overrides.yaml
rules_enforcer:
  add_dangerous_patterns:
    - 'DROP DATABASE.*production'
```

```
"Bloquer rm -rf sur le dossier /data"
```
```yaml
rules_enforcer:
  add_dangerous_patterns:
    - 'rm -rf.*/data'
```

```
"Ajouter un warning pour les commandes sudo"
```
```yaml
rules_enforcer:
  add_warning_patterns:
    - 'sudo'
```

---

### Docker

```
"Mon projet utilise Docker avec le préfixe myapp"
```
```yaml
docker:
  required: true
  container_prefix: "myapp"
```

```
"Désactiver Docker pour ce projet"
```
```yaml
docker:
  required: false
```

---

### Guardian (Vérification Stories)

```
"Désactiver la vérification des stories pour le dossier scripts/"
```
```yaml
guardian:
  add_allowed_directories:
    - "scripts/"
```

```
"Exclure les fichiers .test.ts de la vérification"
```
```yaml
guardian:
  add_allowed_extensions:
    - ".test.ts"
```

```
"Passer Guardian en mode blocage"
```
```yaml
guardian:
  mode: "block"  # au lieu de "warn"
```

```
"Désactiver Guardian complètement"
```
```yaml
guardian:
  enabled: false
```

---

### Sentinel (Circuit Breaker)

```
"5 échecs maximum avant circuit breaker"
```
```yaml
sentinel:
  circuit_breaker:
    max_failures: 5
```

```
"10 minutes de cooldown après circuit breaker"
```
```yaml
sentinel:
  circuit_breaker:
    cooldown_minutes: 10
```

```
"Désactiver le circuit breaker"
```
```yaml
sentinel:
  circuit_breaker:
    enabled: false
```

---

### Agents

```
"Désactiver l'agent pentest"
```
```yaml
agents:
  disabled:
    - "pentest"
```

```
"Alias qa pour exploratory-qa"
```
```yaml
agents:
  aliases:
    qa: "exploratory-qa"
```

```
"Alias luna pour l'agent tester"
```
```yaml
agents:
  aliases:
    luna: "tester"
```

---

### Projet

```
"Le projet s'appelle MonApp"
```
```yaml
project:
  name: "MonApp"
```

```
"Je préfère les réponses en français"
```
```yaml
project:
  language: "fr"
```

---

## Mapping Complet

| Vous dites | Clé YAML | Valeur |
|------------|----------|--------|
| "bloquer X" | `rules_enforcer.add_dangerous_patterns` | `["X"]` |
| "warning pour X" | `rules_enforcer.add_warning_patterns` | `["X"]` |
| "autoriser X" | `rules_enforcer.add_allowed_patterns` | `["X"]` |
| "Docker obligatoire" | `docker.required` | `true` |
| "préfixe X" | `docker.container_prefix` | `"X"` |
| "désactiver Guardian" | `guardian.enabled` | `false` |
| "mode blocage" | `guardian.mode` | `"block"` |
| "exclure dossier X" | `guardian.add_allowed_directories` | `["X"]` |
| "exclure extension X" | `guardian.add_allowed_extensions` | `["X"]` |
| "X échecs max" | `sentinel.circuit_breaker.max_failures` | `X` |
| "X minutes cooldown" | `sentinel.circuit_breaker.cooldown_minutes` | `X` |
| "désactiver agent X" | `agents.disabled` | `["X"]` |
| "alias X = Y" | `agents.aliases` | `{ "X": "Y" }` |
| "projet s'appelle X" | `project.name` | `"X"` |
| "langue X" | `project.language` | `"X"` |

---

## Commandes Spéciales

| Commande | Action |
|----------|--------|
| `/harmony config show` | Afficher la config actuelle |
| `/harmony config reset` | Réinitialiser (avec backup) |
| `/harmony config lang fr` | Changer la langue |
| `/harmony config help` | Afficher l'aide |

---

## Fichier Généré

Toutes les configurations utilisateur sont sauvegardées dans:

```
.harmony/local/config/overrides.yaml
```

Ce fichier est:
- **Local** à votre machine (dans `.harmony/local/`)
- **Préservé** lors des mises à jour du framework
- **Ignoré par git** (données personnelles)
- **Mergé** avec les valeurs par défaut

> **Note**: Le dossier `.harmony/local/` contient toutes vos données personnelles et n'est jamais versionné.

---

## Détection de Langue

La commande répond dans votre langue:

```
Vous: "Bloquer les suppressions de base"
Harmony: ✅ Configuration mise à jour !

You: "Block database deletions"
Harmony: ✅ Configuration updated!
```

---

## Exemple de Session Complète

```
Vous: /harmony config

Harmony: 👋 Bonjour ! Je suis l'assistant de configuration Harmony.
         Décrivez ce que vous voulez configurer en langage naturel.

Vous: Je veux que Docker soit obligatoire avec le préfixe "webapp",
      et bloquer toute commande DROP sur la prod.

Harmony: 📝 J'ai compris que vous voulez:
         - Docker obligatoire avec préfixe "webapp"
         - Bloquer les commandes DROP sur la production

         C'est bien ça ?

Vous: Oui

Harmony: ✅ Configuration mise à jour !

         Fichier: .harmony/local/config/overrides.yaml

         docker:
           required: true
           container_prefix: "webapp"

         rules_enforcer:
           add_dangerous_patterns:
             - 'DROP.*prod'
```

---

## Voir Aussi

- [Configuration Reference](overrides.md) - Format YAML détaillé
- [Commands Reference](commands.md) - Toutes les commandes
- [Guardian Protocol](../agents/guardian.md) - Vérification des stories
- [Sentinel System](../agents/sentinel.md) - Circuit breaker
