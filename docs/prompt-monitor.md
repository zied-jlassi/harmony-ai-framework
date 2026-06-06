# Prompt Monitor — Guide d'activation

> **Désactivé par défaut.** Le Prompt Monitor est un outil optionnel — il doit être activé explicitement.
>
> `HARMONY_DIR` désigne le répertoire d'installation Harmony (défaut : `.harmony`).
> Si tu as personnalisé ce chemin, remplace `.harmony` par ta valeur dans tous les exemples ci-dessous.

## Ce que fait le Prompt Monitor

- Analyse la clarté et la qualité de chaque prompt soumis à Claude
- Trace les interactions outils (Bash, Edit, Write, Read, WebFetch...)
- Fournit un tableau de bord web avec statistiques et tendances
- Génère des suggestions pour améliorer tes prompts au fil du temps

Toutes les données restent **locales** dans `${HARMONY_DIR}/local/` — rien n'est envoyé à l'extérieur.

---

## Prérequis

```bash
pip3 install -r ${HARMONY_DIR}/tools/prompt-monitor/requirements.txt
```

---

## Activation

### Étape 1 — Activer les hooks dans `.claude/settings.json`

Ouvre `.claude/settings.json` et ajoute les blocs suivants.

> Si des hooks existent déjà dans `PostToolUse`, **fusionne les tableaux** — ne remplace pas le fichier entier.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${HARMONY_DIR}/tools/prompt-monitor/hooks/track-user-prompt.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Read|Write|Edit|Glob|Grep|Task|WebFetch|WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${HARMONY_DIR}/tools/prompt-monitor/hooks/track-interaction.sh"
          }
        ]
      }
    ]
  }
}
```

### Étape 2 — Lancer le serveur

```bash
# Démarrer (port 8081 par défaut)
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py start

# Avec un port personnalisé
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py start --port 9000

# Vérifier le statut
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py status
```

### Étape 3 — Ouvrir le tableau de bord

```
http://localhost:8081
```

---

## Commandes disponibles

```bash
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py start    # Démarrer le serveur
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stop     # Arrêter le serveur
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py status   # Voir le statut et le PID
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stats    # Statistiques en CLI
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py reset    # Réinitialiser les données
```

---

## Désactivation

1. Dans `.claude/settings.json`, supprimer :
   - Le bloc `UserPromptSubmit` contenant `track-user-prompt.sh`
   - L'entrée `track-interaction.sh` dans `PostToolUse`

2. Arrêter le serveur :
```bash
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stop
```

---

## Données collectées

| Emplacement | Contenu |
|-------------|---------|
| `${HARMONY_DIR}/local/logs/` | Logs bruts des interactions |
| `${HARMONY_DIR}/local/metrics/` | Métriques agrégées par session |

Aucune donnée ne quitte ta machine.
