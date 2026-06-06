# Prompt Monitor — Guide d'activation

> **Désactivé par défaut.** Le Prompt Monitor est un outil optionnel — il doit être activé explicitement.
>
> `${HARMONY_DIR}` désigne le répertoire d'installation Harmony (défaut : `.harmony`).
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

Les hooks du Prompt Monitor sont isolés dans un fichier dédié (`settings-addon.json`) pour ne pas mélanger avec les hooks Harmony principaux dans `settings.json`.

### Étape 1 — Activer les hooks

**Cas A — `.claude/settings.local.json` n'existe pas encore :**

```bash
# Copier directement le fichier dédié
cp ${HARMONY_DIR}/tools/prompt-monitor/settings-addon.json .claude/settings.local.json

# Remplacer ${HARMONY_DIR} par le chemin réel
sed -i 's|\${HARMONY_DIR}|.harmony|g' .claude/settings.local.json
```

**Cas B — `.claude/settings.local.json` existe déjà :**

> ⚠️ **Fusionner, ne pas remplacer.** Copier le fichier existant écraserait ta configuration.
> Ouvrir `${HARMONY_DIR}/tools/prompt-monitor/settings-addon.json` et **ajouter uniquement les blocs manquants** dans ton `.claude/settings.local.json` existant :
>
> - Ajouter le bloc `UserPromptSubmit` s'il n'existe pas déjà
> - Ajouter l'entrée `track-interaction.sh` dans `PostToolUse` si le matcher `Bash|Read|Write|...` n'est pas déjà présent
>
> Ne jamais dupliquer un bloc `UserPromptSubmit` ou `PostToolUse` existant.

Claude Code charge `.claude/settings.local.json` et **merge** automatiquement ses hooks avec ceux de `.claude/settings.json` — les hooks Harmony principaux restent intacts.

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

## Contenu de settings-addon.json

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [{
          "type": "command",
          "command": "bash .harmony/tools/prompt-monitor/hooks/track-user-prompt.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Read|Write|Edit|Glob|Grep|Task|WebFetch|WebSearch",
        "hooks": [{
          "type": "command",
          "command": "bash .harmony/tools/prompt-monitor/hooks/track-interaction.sh"
        }]
      }
    ]
  }
}
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

**Cas A — `.claude/settings.local.json` ne contient que les hooks prompt-monitor :**

```bash
rm .claude/settings.local.json
python3 ${HARMONY_DIR}/tools/prompt-monitor/cli.py stop
```

**Cas B — `.claude/settings.local.json` contient d'autres configurations :**

Supprimer uniquement les deux blocs ajoutés :
- Le bloc `UserPromptSubmit` contenant `track-user-prompt.sh`
- L'entrée `track-interaction.sh` dans `PostToolUse`

Puis arrêter le serveur :
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
