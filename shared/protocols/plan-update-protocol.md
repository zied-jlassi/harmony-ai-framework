# Plan Update Protocol

> **Version**: 1.0
> **Source**: Windsurf update_plan Pattern + Agentic Best Practices
> **Status**: OBLIGATOIRE pour tous les agents

---

## Principe Fondamental

> "Whenever you receive new instructions, complete items from the plan, or learn
> any new information that may change the scope or direction of the plan, you
> must update the plan. The plan should always reflect the current state of the
> world before any user interaction."
> — Windsurf System Prompt

Le Plan Update Protocol garantit que le plan reste **synchronise avec la realite**
a tout moment, permettant:
- Coherence des decisions
- Visibilite pour l'utilisateur
- Detection precoce des deviations
- Tracabilite complete

---

## Quand Mettre a Jour le Plan

### Declencheurs OBLIGATOIRES

| Evenement | Action | Urgence |
|-----------|--------|---------|
| **Tache completee** | Marquer DONE + ajouter suivante si necessaire | Immediate |
| **Nouvelle information** | Reviser scope/approche | Immediate |
| **Blocage detecte** | Documenter + proposer alternatives | Immediate |
| **Erreur rencontree** | Ajouter tache de correction | Immediate |
| **Changement de direction** | Reviser tout le plan | Avant action |
| **Fin de session** | Sauvegarder etat pour reprise | Avant fermeture |

### Principe "Update First"

```
┌─────────────────────────────────────────────────────────────────┐
│                    UPDATE FIRST PRINCIPLE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  AVANT d'ecrire du code ou prendre une action majeure:          │
│                                                                  │
│  1. Verifier que le plan actuel est a jour                      │
│  2. Si nouvelle info → mettre a jour d'abord                    │
│  3. PUIS executer l'action                                      │
│                                                                  │
│  APRES chaque action significative:                             │
│                                                                  │
│  1. Mettre a jour le statut de la tache                         │
│  2. Documenter les resultats/decouvertes                        │
│  3. Ajuster le plan si necessaire                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Format de Plan

### Structure Obligatoire

```yaml
plan:
  id: "PLAN-{story_id}-{timestamp}"
  story_ref: "STORY-XXX"
  created_at: "2025-12-26T12:00:00Z"
  last_updated: "2025-12-26T14:30:00Z"
  status: "in_progress"  # draft | in_progress | blocked | completed

  # Objectif global
  goal: "Description claire de l'objectif final"

  # Taches avec statuts
  tasks:
    - id: 1
      description: "Description de la tache"
      status: "completed"  # pending | in_progress | completed | blocked | skipped
      completed_at: "2025-12-26T12:30:00Z"
      notes: "Notes optionnelles sur completion"

    - id: 2
      description: "Tache suivante"
      status: "in_progress"
      started_at: "2025-12-26T14:00:00Z"
      estimated_completion: "2025-12-26T15:00:00Z"

    - id: 3
      description: "Tache future"
      status: "pending"
      depends_on: [2]

  # Blocages actuels
  blockers:
    - description: "Description du blocage"
      since: "2025-12-26T13:00:00Z"
      impact: "high"  # low | medium | high
      proposed_solution: "Solution proposee"

  # Nouvelles informations
  discoveries:
    - timestamp: "2025-12-26T13:30:00Z"
      finding: "Decouverte importante"
      impact_on_plan: "Necessite ajout tache X"

  # Metriques
  metrics:
    total_tasks: 5
    completed: 2
    in_progress: 1
    pending: 2
    blocked: 0
    progress_percent: 40
```

---

## Formats de Mise a Jour

### 1. Completion de Tache

```markdown
## Plan Update: Task Completed

**Plan**: PLAN-STORY-050-001
**Task**: #2 - Implementer validation DTO
**Status**: completed ✅
**Timestamp**: 2025-12-26T14:30:00Z

### Resultats
- DTO cree avec 5 validations
- Tests unitaires passes (100%)

### Prochaine Tache
#3 - Implementer service logic (status: in_progress)

### Plan Progress
[██████████░░░░░░░░░░] 50% (3/6 tasks)
```

### 2. Decouverte d'Information

```markdown
## Plan Update: New Information

**Plan**: PLAN-STORY-050-001
**Discovery**: Le schema existant n'a pas le champ familyId
**Timestamp**: 2025-12-26T14:45:00Z

### Impact sur le Plan
- Ajout tache: Migration Prisma pour familyId
- Reordonnancement: Migration AVANT service logic

### Plan Revise
1. ✅ Analyse requirements
2. ✅ Creation DTO
3. ➕ **[NOUVEAU]** Migration schema Prisma
4. 🔄 Implementation service (deplace)
5. ⏳ Tests E2E
```

### 3. Blocage

```markdown
## Plan Update: Blocker Detected

**Plan**: PLAN-STORY-050-001
**Blocker**: Dependance STORY-049 non terminee
**Severity**: HIGH
**Timestamp**: 2025-12-26T15:00:00Z

### Impact
- Impossible de continuer tache #4
- Attente completion STORY-049

### Solutions Proposees
1. **Attendre** - ETA STORY-049: 2h
2. **Contourner** - Mock temporaire (risque: dette technique)
3. **Escalader** - Demander priorisation STORY-049

### Action Recommandee
Option 1 - Attendre + travailler sur taches independantes

### Taches Reordonnees
- #5 Tests E2E (peut commencer sans #4)
- #4 Implementation service (bloque)
```

### 4. Fin de Session

```markdown
## Plan Update: Session End

**Plan**: PLAN-STORY-050-001
**Session End**: 2025-12-26T18:00:00Z

### Etat Final Session
- Completed: 4/6 tasks
- In Progress: #5 (60% done)
- Pending: #6

### Pour Reprendre
1. Lire ce plan update
2. Continuer #5 depuis: `src/games/math/math.service.ts:42`
3. Fichiers modifies: [liste]

### Contexte a Retenir
- Decision: Utiliser Cache-Aside pour scores
- Pattern: PlayerGuard obligatoire
- Attention: Migration deja executee
```

---

## Integration avec TodoWrite

Le Plan Update Protocol se synchronise avec l'outil TodoWrite:

```yaml
synchronization:
  todowrite_to_plan:
    - todowrite.status == "completed" → plan.task.status = "completed"
    - todowrite.status == "in_progress" → plan.task.status = "in_progress"

  plan_to_todowrite:
    - plan.task.added → todowrite.add(task)
    - plan.task.removed → todowrite.remove(task)

  timing:
    update_todowrite: "after_each_plan_update"
    update_plan: "after_significant_action"
```

---

## Anti-Patterns (A EVITER)

### ❌ Ne PAS faire:

```markdown
<!-- MAUVAIS: Plan jamais mis a jour -->
[Commence a coder sans plan]
[Termine sans documenter]

<!-- MAUVAIS: Plan mis a jour trop tard -->
[Complete 5 taches]
[Met a jour le plan une seule fois a la fin]

<!-- MAUVAIS: Plan incomplet -->
Plan:
1. Faire le truc
2. Tester
[Pas de details, pas de statuts]
```

### ✅ FAIRE:

```markdown
<!-- BON: Plan mis a jour incrementalement -->
[Complete tache 1]
"## Plan Update: Task #1 completed..."
[Complete tache 2]
"## Plan Update: Task #2 completed..."

<!-- BON: Nouvelle info = update immediat -->
"Je decouvre que X necessite Y"
"## Plan Update: New Information..."
[Puis continue avec plan revise]
```

---

## Integration dans les Agents

Chaque agent DOIT inclure cette section:

```markdown
## Plan Update Protocol

> **Reference**: `.bmad/bmm/shared/plan-update-protocol.md`
> **Status**: OBLIGATOIRE

### Workflow

1. **Debut de tache**: Creer/charger plan
2. **Pendant execution**: Update apres chaque etape significative
3. **Nouvelle info**: Update AVANT de changer de direction
4. **Fin de tache**: Update final avec resume

### Format Court

Pour updates mineurs, utiliser:
```
📋 Plan Update: [Task #X] → [status]
```

### Format Long

Pour updates majeurs, utiliser le template complet.
```

---

## Metriques

| Metrique | Cible | Mesure |
|----------|-------|--------|
| Plans a jour | 100% | Audit |
| Updates par tache | >= 1 | Count |
| Temps max sans update | < 30min | Timer |
| Blocages documentes | 100% | Review |

---

**Derniere mise a jour**: 2025-12-26
**Auteur**: BMAD Framework Team
