# Working Memory - Suivi des sprints et du backlog

> **🌐 Langue :** [English](../working-memory.md) · Français

> **Agnostique de l'IA** : Fonctionne avec Claude, Cursor, Windsurf, Cody, Continue ou tout autre assistant IA.

Le système Working Memory assure un suivi persistant des sprints et du backlog qui survit aux plantages de session et permet une transmission de contexte fluide entre les sessions.

## Emplacement de la mémoire (spécifique à l'IDE)

Les fichiers de mémoire sont stockés dans des **emplacements spécifiques à l'IDE**, et NON dans `.harmony/` :

| IDE | Emplacement de la mémoire |
|-----|-----------------|
| Claude Code | `.harmony/local/memory/` |
| Cursor | `.cursor/harmony-memory/` |
| Windsurf | `.windsurf/harmony-memory/` |
| Continue | `.continue/harmony-memory/` |
| Cody | `.cody/harmony-memory/` |
| Generic | `.harmony-local/memory/` |

> **Pourquoi ?** Le cœur du framework (`.harmony/`) reste en lecture seule et partageable. Les données spécifiques au projet restent locales.

Le chemin est configuré dans `.harmony/config/paths.json` lors de l'installation.

## Vue d'ensemble

```
+-------------------------------------------------------------------+
|                    WORKING MEMORY SYSTEM                            |
+-------------------------------------------------------------------+
|                                                                   |
|  ${MEMORY_DIR}/working.json       ← Central state file           |
|  ${MEMORY_DIR}/.action-log.jsonl  ← Action journal               |
|  ${MEMORY_DIR}/.checkpoint.json   ← Crash recovery               |
|  ${MEMORY_DIR}/.backups/          ← Automatic backups            |
|                                                                   |
|  .harmony/lib/sprint-tracker.sh   ← CRUD operations              |
|  .harmony/lib/recovery.sh         ← Crash recovery               |
|                                                                   |
|  Example (Claude Code):                                           |
|  .harmony/local/memory/working.json                                      |
|  .harmony/local/memory/.action-log.jsonl                                 |
+-------------------------------------------------------------------+
```

## Pourquoi Working Memory ?

### Le problème

Sans état persistant :
- L'IA perd le contexte lorsque la session se termine ou plante
- L'utilisateur doit ré-expliquer le statut du sprint, la story en cours, les blocages
- Risque de travail dupliqué ou de tâches oubliées
- Aucun suivi de la vélocité d'un sprint à l'autre

### La solution

Avec Working Memory :
- L'état persiste entre les sessions
- L'IA lit `working.json` au démarrage de la session → sait exactement où reprendre
- Sauvegardes automatiques toutes les 5 actions
- Le journal d'actions permet la récupération après plantage

## Démarrage rapide

### 1. Initialiser Working Memory

```bash
# From your project root
source .harmony/lib/sprint-tracker.sh
init_working_memory "My Project"
```

### 2. Démarrer un sprint

```bash
start_sprint "SPRINT-001" "MVP Sprint" 30 "Deliver core features"
```

### 3. Travailler sur des stories

```bash
start_story "STORY-001" "User login" 5 "EPIC-AUTH"
# ... do work ...
complete_story
```

### 4. Afficher le tableau de bord

```bash
show_sprint_dashboard
```

## Structure des fichiers

### working.json

```json
{
  "version": "2.0.0",
  "type": "working_memory",
  "created": "2025-01-01",
  "last_updated": "2025-01-01T14:30:00+00:00",

  "project": {
    "name": "My Project",
    "language": "en"
  },

  "current_sprint": {
    "id": "SPRINT-001",
    "name": "MVP Sprint",
    "started": "2025-01-01",
    "status": "IN_PROGRESS",
    "velocity_target": 30,
    "velocity_achieved": 15,
    "sprint_goal": "Deliver core features",
    "stories": ["STORY-001", "STORY-002"],
    "blockers": []
  },

  "current_story": {
    "id": "STORY-002",
    "title": "User registration",
    "status": "IN_PROGRESS",
    "points": 5,
    "tasks_completed": 2,
    "tasks_total": 4
  },

  "velocity": {
    "average_3_sprints": 25,
    "trend": "improving",
    "recommended_capacity": 28
  },

  "blockers": [],

  "recent_decisions": [
    {
      "date": "2025-01-01",
      "decision": "Use JWT for authentication",
      "reason": "Stateless, scalable"
    }
  ],

  "next_steps": [
    "Complete STORY-002 tasks 3-4",
    "Start STORY-003"
  ]
}
```

## Bibliothèque Sprint Tracker

### Opérations sur les sprints

```bash
source .harmony/lib/sprint-tracker.sh

# Start new sprint
start_sprint "SPRINT-ID" "Sprint Name" target_velocity "Sprint Goal"

# Complete current sprint (moves to history)
complete_sprint

# Add axis to sprint (for multi-epic sprints)
add_sprint_axis "A_Backend" "EPIC-001" 20 "Backend implementation"

# Update axis status
update_axis_status "A_Backend" "DONE"

# Add velocity points
add_velocity 15
```

### Opérations sur les stories

```bash
# Start working on a story
start_story "STORY-001" "Story Title" 5 "EPIC-001" "Developer"

# Update progress
update_story_progress 3 5  # 3 of 5 tasks done

# Update UCV status
update_ucv_status "APPROVED"

# Complete story (adds points to velocity)
complete_story
```

### Opérations sur les blocages

```bash
# Add a blocker
add_blocker "BLK-001" "API not ready" "STORY-001" "high" "DevOps"

# Resolve a blocker
resolve_blocker "BLK-001"

# View open blockers
get_blockers
```

### Décisions et étapes suivantes

```bash
# Record a decision
add_decision "Use Redis for caching" "Better performance" "Architect"

# Add next step
add_next_step "Finalize API contract"

# Remove completed step
remove_next_step "Finalize API contract"

# View recent decisions
get_recent_decisions
```

### Accesseurs (getters)

```bash
get_current_sprint    # Sprint info
get_current_story     # Story info
get_velocity          # Velocity stats
get_backlog_summary   # Backlog counts
get_blockers          # Open blockers
get_next_steps        # Pending next steps
```

### Affichage

```bash
# Full dashboard
show_sprint_dashboard

# Export for AI consumption (JSON)
export_for_ai
```

## Système de récupération

### Récupération automatique

Le système de récupération gère les plantages avec élégance :

1. **Points de contrôle (checkpoints)** : Avant chaque action, l'état est sauvegardé
2. **Journal d'actions** : Chaque action est journalisée dans `.action-log.jsonl`
3. **Sauvegardes** : Sauvegarde automatique toutes les 5 actions
4. **Récupération** : Au démarrage de la session, les actions incomplètes sont détectées

### Utiliser la récupération

```bash
source .harmony/lib/recovery.sh

# Check state at session start
recover_state

# If issues found:
fix_state              # Auto-fix common issues
list_backups           # Show available backups
restore_backup "file"  # Restore from backup

# View action history
show_action_log 20     # Last 20 actions

# Manual backup
create_backup "manual" "Before major refactor"
```

### Détection de plantage

Lorsque vous démarrez une session, `recover_state` vérifie :

1. `working.json` est-il un JSON valide ?
2. Existe-t-il un point de contrôle incomplet (`_checkpoint.pending_action`) ?
3. Y a-t-il des incohérences d'état ?

Si des problèmes sont détectés, vous verrez des options de récupération.

## Intégration avec l'IA

### Pour les assistants IA

Au début de chaque session, l'IA devrait :

1. **Lire** `${MEMORY_DIR}/working.json` (par ex. `.harmony/local/memory/working.json`)
2. **Vérifier** la présence d'actions incomplètes
3. **Afficher** un résumé de l'état actuel
4. **Continuer** là où la session précédente s'est arrêtée

### Exemple de workflow IA

```markdown
# Session Start

AI reads working.json and says:

"I see you're in Sprint SPRINT-005 (15/30 pts achieved).
Current story: STORY-042 (3/5 tasks done).
Open blockers: None.
Next steps:
- Finish task 4/5 of STORY-042
- Run E2E tests

Shall I continue with the current story?"
```

### Après chaque action

L'IA devrait mettre à jour `working.json` :

```python
# Pseudo-code
after_action = lambda action: {
    update_working_json(action.changes),
    log_action(action.description),
    maybe_create_backup()
}
```

## Bonnes pratiques

### 1. Toujours mettre à jour working.json

Après toute action significative :
- Story créée / démarrée / terminée
- Sprint démarré / terminé
- Blocage ajouté / résolu
- Décision prise

### 2. Utiliser next_steps pour la continuité

Avant de terminer une session :
```bash
add_next_step "Continue implementing validation"
add_next_step "Review PR #123"
```

### 3. Sauvegardes régulières

Pour les jalons critiques :
```bash
create_backup "manual" "Sprint 5 complete"
```

### 4. Vérifier l'état au démarrage

Toujours exécuter au démarrage de la session :
```bash
recover_state
show_sprint_dashboard
```

## Configuration

### Surcharger les valeurs par défaut

Dans `.harmony/config/overrides.yaml` :

```yaml
working_memory:
  backup_interval: 5      # Actions between backups
  max_backups: 10         # Keep last N backups
  auto_recovery: true     # Auto-recover on start
```

## Dépannage

### working.json corrompu

```bash
# Check if valid JSON (use your IDE's memory path)
jq empty .harmony/local/memory/working.json  # Claude Code example

# If corrupted, recover from backup
list_backups
restore_backup "working_20250101_120000_auto.json"
```

### État manquant

```bash
# Re-initialize
init_working_memory "Project Name"

# Or reset with backup
reset_working_memory "Project Name"
```

### État incohérent

```bash
# Auto-fix common issues
fix_state

# Or view action log to understand what happened
show_action_log 50
```

## Documentation associée

- [Agent Scrum Master](../../agents/scrum-master.md) - Utilise Working Memory
- [Surcharges (Overrides)](./overrides.md) - Options de configuration
