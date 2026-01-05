# P-019: Working Memory Protocol

> **Pattern**: Persistance d'etat entre sessions
> **Usage**: TOUS les agents - CENTRAL et OBLIGATOIRE
> **Fichier**: `.claude/memory/working.json`

---

## Principe

La Working Memory garantit la resilience et la continuite entre sessions.
Si une session crash, l'agent suivant sait exactement ou reprendre.

---

## Protocol

```
+-------------------------------------------------------------------+
|                    WORKING MEMORY PROTOCOL                          |
+-------------------------------------------------------------------+
|                                                                   |
|  REGLE #1: LIRE working.json AU DEBUT DE CHAQUE SESSION          |
|  ─────────────────────────────────────────────────────            |
|  - Verifier l'etat du sprint courant                              |
|  - Verifier la story en cours                                     |
|  - Verifier les blockers ouverts                                  |
|  - Verifier les next_steps                                        |
|                                                                   |
|  REGLE #2: ECRIRE working.json APRES CHAQUE ACTION                |
|  ────────────────────────────────────────────────────             |
|  - Crash resilience: si la session crash, l'etat est sauve        |
|  - Pas de perte de contexte entre sessions                        |
|  - L'IA suivante sait exactement ou on en est                     |
|                                                                   |
|  REGLE #3: UTILISER LES FONCTIONS DE sprint-tracker.sh            |
|  ──────────────────────────────────────────────────────           |
|  - start_sprint / complete_sprint                                 |
|  - start_story / complete_story                                   |
|  - add_blocker / resolve_blocker                                  |
|  - add_decision / add_next_step                                   |
|                                                                   |
+-------------------------------------------------------------------+
```

---

## Structure working.json

```json
{
  "current_sprint": {
    "id": "SPRINT-005",
    "name": "Sprint 5 - User Management",
    "started_at": "2026-01-01T09:00:00Z",
    "velocity_target": 20,
    "velocity_achieved": 15,
    "stories": ["STORY-042", "STORY-043", "STORY-044"]
  },
  "current_story": {
    "id": "STORY-042",
    "title": "User can reset password",
    "points": 3,
    "status": "IN_PROGRESS",
    "tasks_completed": 3,
    "tasks_total": 5,
    "started_at": "2026-01-03T10:00:00Z"
  },
  "blockers": [
    {
      "id": "BLOCK-001",
      "description": "Waiting for email service API key",
      "story": "STORY-042",
      "created_at": "2026-01-03T11:00:00Z",
      "status": "OPEN"
    }
  ],
  "recent_decisions": [
    {
      "id": "DEC-001",
      "decision": "Use SendGrid for email service",
      "rationale": "Better deliverability rate",
      "date": "2026-01-02"
    }
  ],
  "next_steps": [
    "Finir tache 4/5 de STORY-042",
    "Lancer tests E2E",
    "Review avec Architect"
  ],
  "statistics": {
    "stories_completed_total": 42,
    "sprints_completed": 4,
    "average_velocity": 18
  },
  "sprint_history": [
    {
      "id": "SPRINT-004",
      "velocity": 18,
      "stories_completed": 6
    }
  ],
  "_checkpoint": {
    "pending_action": null,
    "last_update": "2026-01-03T14:30:00Z"
  }
}
```

---

## Actions et Mises a Jour

| Action | Champs a mettre a jour |
|--------|------------------------|
| **Creer sprint** | `current_sprint.*` (id, name, started, velocity_target) |
| **Clore sprint** | Move to `sprint_history[]`, update `velocity.*`, `statistics.*` |
| **Creer story** | Add to `current_sprint.stories[]`, update `backlog.*` |
| **Demarrer story** | `current_story.*` (id, title, points, status=IN_PROGRESS) |
| **Terminer story** | Clear `current_story`, update `statistics.*`, `velocity_achieved` |
| **Ajouter blocker** | Add to `blockers[]` |
| **Decision prise** | Add to `recent_decisions[]` |
| **Planifier next step** | Add to `next_steps[]` |

---

## Recovery Protocol

**AU DEBUT DE CHAQUE SESSION:**

```
1. LIRE `.claude/memory/working.json`
2. VERIFIER si `_checkpoint.pending_action` existe (crash detecte)
3. AFFICHER le resume de l'etat actuel
4. PROPOSER de continuer ou corriger
```

**APRES CHAQUE ACTION SIGNIFICATIVE:**

```
1. METTRE A JOUR working.json immediatement
2. CREER backup tous les 5 actions (automatique)
3. LOGGER l'action dans `.claude/memory/.action-log.jsonl`
```

---

## Exemple de Recovery

```json
// AVANT: Session precedente a crashe
{
  "current_sprint": {
    "id": "SPRINT-005",
    "velocity_achieved": 15
  },
  "current_story": {
    "id": "STORY-042",
    "status": "IN_PROGRESS",
    "tasks_completed": 3,
    "tasks_total": 5
  },
  "next_steps": [
    "Finir tache 4/5 de STORY-042",
    "Lancer tests E2E"
  ]
}

// L'IA lit ceci et SAIT EXACTEMENT ou reprendre!
// → Story STORY-042, tache 4/5, puis tests E2E
```

---

## Libs Disponibles

| Lib | Path | Fonctions |
|-----|------|-----------|
| sprint-tracker.sh | `.harmony/lib/` | start_sprint, complete_sprint, start_story, complete_story |
| recovery.sh | `.harmony/lib/` | check_recovery, restore_checkpoint |

---

## Integration

- **Utilise par**: TOUS les agents
- **Fichier**: `.claude/memory/working.json`
- **Backup**: `.claude/memory/working.backup.json`
- **Log**: `.claude/memory/.action-log.jsonl`
- **Resilience**: Crash-proof, context preservation
