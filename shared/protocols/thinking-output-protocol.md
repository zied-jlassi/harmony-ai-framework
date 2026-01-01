# Thinking Output Protocol (ENHANCED)

> **Version**: 2.0
> **Source**: [Anthropic Think Tool](https://www.anthropic.com/engineering/claude-think-tool) + [Extended Thinking Tips](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/extended-thinking-tips)
> **Performance**: +54% sur taches complexes (Anthropic Research)
> **Status**: OBLIGATOIRE pour tous les agents

---

## Principe Fondamental

> "Claude often performs better with high level instructions to just think deeply about a task rather than step-by-step prescriptive guidance."
> — Anthropic Documentation

Le Thinking Output Protocol force les agents a **externaliser leur reflexion** dans des blocs `<thinking>` visibles, permettant:
- Meilleure qualite des decisions
- Tracabilite du raisonnement
- Detection precoce des erreurs
- Apprentissage continu

---

## Niveaux de Reflexion

| Niveau | Duree | Declencheur | Format Output |
|--------|-------|-------------|---------------|
| **think** | 30-60s | Decisions routinieres | `<thinking level="think">` |
| **think_hard** | 1-2min | Plusieurs options valides | `<thinking level="think_hard">` |
| **think_harder** | 2-4min | Risque eleve, irreversible | `<thinking level="think_harder">` |
| **ultrathink** | 5-10min | Architecture, multi-agent | `<thinking level="ultrathink">` |

---

## Triggers Automatiques (OBLIGATOIRE)

### Vous DEVEZ output `<thinking>` quand:

```yaml
mandatory_triggers:
  # Decisions critiques
  - pattern: "git commit|git push|git merge"
    level: think_hard
    reason: "Operations Git irreversibles"

  - pattern: "delete|drop|remove permanently|truncate"
    level: think_harder
    reason: "Destruction de donnees"

  - pattern: "migration|migrate|schema change"
    level: think_harder
    reason: "Changements structurels"

  - pattern: "deploy|production|release"
    level: ultrathink
    reason: "Impact utilisateurs"

  # Transitions d'etat
  - pattern: "exploration → implementation"
    level: think_hard
    reason: "Changement de mode"

  - pattern: "declare complete|mark as done"
    level: think_hard
    reason: "Validation finale"

  # Situations de doute
  - pattern: "multiple approaches|plusieurs options"
    level: think_hard
    reason: "Decision a prendre"

  - pattern: "error|echec|failure"
    level: think_harder
    reason: "Analyse d'erreur"

  # Complexite
  - pattern: "story_points >= 5"
    level: think_hard
    reason: "Tache complexe"

  - pattern: "story_points >= 8"
    level: ultrathink
    reason: "Tache tres complexe"

  - pattern: "dependencies >= 3"
    level: think_harder
    reason: "Multiple dependances"
```

---

## Format de Sortie OBLIGATOIRE

### Structure du bloc `<thinking>`

```xml
<thinking level="[think|think_hard|think_harder|ultrathink]">

## Contexte
[Description de la situation actuelle en 2-3 phrases]

## Probleme
[Quel probleme dois-je resoudre?]

## Options Evaluees
1. **[Option A]**
   - Avantages: [liste]
   - Inconvenients: [liste]
   - Score: [1-10]

2. **[Option B]**
   - Avantages: [liste]
   - Inconvenients: [liste]
   - Score: [1-10]

## Decision
[Option choisie] car [justification en 1-2 phrases]

## Risques et Mitigations
- **Risque 1**: [description] → **Mitigation**: [action]
- **Risque 2**: [description] → **Mitigation**: [action]

## Plan d'Action
1. [Etape 1]
2. [Etape 2]
3. [Etape 3]

</thinking>
```

### Formats Courts (pour think simple)

```xml
<thinking level="think">
**Situation**: [1 phrase]
**Decision**: [1 phrase]
**Raison**: [1 phrase]
</thinking>
```

---

## Exemples Concrets

### Exemple 1: think (Decision routiniere)

```xml
<thinking level="think">
**Situation**: Besoin d'ajouter validation email dans le DTO
**Decision**: Utiliser class-validator @IsEmail()
**Raison**: Pattern standard du projet, deja utilise partout
</thinking>
```

### Exemple 2: think_hard (Plusieurs options)

```xml
<thinking level="think_hard">

## Contexte
L'utilisateur demande d'implementer le cache pour les scores de jeux.
Le projet utilise Redis mais il y a plusieurs patterns possibles.

## Options Evaluees
1. **Cache-Aside (Read-Through)**
   - Avantages: Simple, pattern standard du projet
   - Inconvenients: Possible cache stampede
   - Score: 8/10

2. **Write-Through Cache**
   - Avantages: Donnees toujours fraiches
   - Inconvenients: Latence ecriture plus elevee
   - Score: 6/10

## Decision
Cache-Aside car c'est le pattern etabli dans le projet et les scores
ne necessitent pas une fraicheur absolue (TTL 60s acceptable).

## Risques et Mitigations
- **Cache stampede**: → Utiliser locking Redis

</thinking>
```

### Exemple 3: think_harder (Risque eleve)

```xml
<thinking level="think_harder">

## Contexte
Migration de la structure des Players pour ajouter le champ familyId.
Base de donnees de production avec 50,000 joueurs.

## Probleme
Comment migrer sans downtime et sans perte de donnees?

## Options Evaluees
1. **Migration directe**
   - Avantages: Simple, rapide
   - Inconvenients: Downtime requis, risque si echec
   - Score: 4/10

2. **Migration en 3 phases (Expand-Contract)**
   - Avantages: Zero downtime, rollback possible
   - Inconvenients: Plus complexe, 3 deployments
   - Score: 9/10

3. **Dual-write pendant transition**
   - Avantages: Securite maximale
   - Inconvenients: Complexite code, maintenance
   - Score: 7/10

## Decision
Expand-Contract (Option 2) car zero downtime obligatoire
et rollback possible a chaque etape.

## Risques et Mitigations
- **Donnees orphelines**: → Script de verification post-migration
- **Performance pendant migration**: → Executer en heures creuses
- **Echec mid-migration**: → Chaque phase est independante

## Plan d'Action
1. Phase Expand: Ajouter colonne nullable familyId
2. Phase Migrate: Backfill des donnees existantes
3. Phase Contract: Rendre colonne NOT NULL, supprimer ancien code

</thinking>
```

### Exemple 4: ultrathink (Architecture)

```xml
<thinking level="ultrathink">

## Contexte
Conception du systeme de progression pour la plateforme gaming.
Impact sur: Players, Games, Achievements, Leaderboards.
~200,000 joueurs potentiels, temps reel requis.

## Probleme
Comment structurer la progression pour etre scalable,
engageante pour les enfants 6-12 ans, et pedagogique?

## Options Evaluees

1. **Progression Lineaire (XP simple)**
   - Avantages: Simple a implementer, facile a comprendre
   - Inconvenients: Peu engageant, pas adaptatif
   - Scalabilite: Excellente
   - Pedagogie: Faible
   - Score: 5/10

2. **Progression Adaptative (Mastery-based)**
   - Avantages: S'adapte au niveau, pedagogique
   - Inconvenients: Complexe, necessite ML/heuristiques
   - Scalabilite: Moyenne (calculs couteux)
   - Pedagogie: Excellente
   - Score: 8/10

3. **Systeme Hybride (XP + Competences)**
   - Avantages: Balance engagement/pedagogie
   - Inconvenients: Plus de donnees a gerer
   - Scalabilite: Bonne (Redis pour temps reel)
   - Pedagogie: Tres bonne
   - Score: 9/10

## Decision
Systeme Hybride car il combine:
- Gratification immediate (XP, niveaux)
- Progression pedagogique (competences maitrisees)
- Adaptabilite (difficulte ajustee par competence)

## Architecture Proposee

```
┌─────────────────────────────────────────────────┐
│              PROGRESSION SERVICE                 │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐ │
│  │   XP     │     │ SKILLS   │     │ LEVELS   │ │
│  │  Engine  │ ←→  │  Matrix  │ ←→  │  System  │ │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘ │
│       │                │                │       │
│       └────────────────┼────────────────┘       │
│                        ▼                         │
│              ┌─────────────────┐                │
│              │  Redis Cache    │                │
│              │  (Leaderboards) │                │
│              └─────────────────┘                │
│                        │                         │
│                        ▼                         │
│              ┌─────────────────┐                │
│              │   PostgreSQL    │                │
│              │ (Persistence)   │                │
│              └─────────────────┘                │
│                                                  │
└─────────────────────────────────────────────────┘
```

## Risques et Mitigations

- **Performance temps reel**: → Redis Sorted Sets pour leaderboards
- **Complexite calcul competences**: → Pre-calcul batch nocturne
- **Regression enfants**: → Mecanisme de "protection" (pas de baisse visible)
- **Triche**: → Validation server-side, anti-cheat basique

## Plan d'Action

1. Creer module `progression/` avec entities XP, Skill, Level
2. Implementer XP Engine (event-driven via RabbitMQ)
3. Implementer Skill Matrix avec seuils de maitrise
4. Integrer avec Redis pour temps reel
5. Ajouter tests E2E pour scenarios de progression
6. Playtest avec 10 enfants pilotes

## ADR Required
Oui - ADR-007-progression-system.md

</thinking>
```

---

## Integration dans les Agents

Chaque agent DOIT inclure cette section dans son fichier:

```markdown
## Thinking Output Protocol

> **Reference**: `.harmony/shared/thinking-output-protocol.md`
> **Status**: OBLIGATOIRE

### Declencheurs pour cet agent

| Situation | Niveau | Exemple |
|-----------|--------|---------|
| [situation specifique agent] | think | [exemple] |
| [situation specifique agent] | think_hard | [exemple] |
| [situation specifique agent] | think_harder | [exemple] |

### Format de sortie

Toujours utiliser `<thinking level="X">...</thinking>`
avant les decisions importantes.
```

---

## Anti-Patterns (A EVITER)

### ❌ Ne PAS faire:

```xml
<!-- MAUVAIS: Thinking sans structure -->
<thinking>
Je vais faire A parce que c'est mieux.
</thinking>

<!-- MAUVAIS: Pas de thinking avant decision critique -->
User: "Supprime la table players"
Agent: *Execute directement* ❌

<!-- MAUVAIS: Thinking trop long pour decision simple -->
<thinking level="ultrathink">
[10 paragraphes pour changer une variable]
</thinking>
```

### ✅ FAIRE:

```xml
<!-- BON: Thinking structure adapte au niveau -->
<thinking level="think_harder">
## Contexte
Demande de suppression table players...
[structure complete]
</thinking>

<!-- BON: Verification avant action destructive -->
User: "Supprime la table players"
Agent:
<thinking level="think_harder">
## Contexte
Demande de suppression de la table players.
Cette table contient 50,000 enregistrements.
Action IRREVERSIBLE.
...
</thinking>
"Attention: Cette action est irreversible. Confirmez-vous?"
```

---

## Metriques et Evaluation

| Metrique | Cible | Mesure |
|----------|-------|--------|
| % decisions avec thinking | > 80% | Audit logs |
| Niveau thinking adapte | > 90% | Review |
| Structure respectee | 100% | Lint |
| Erreurs post-thinking | < 10% | Error Journal |

---

## References

- [The "think" tool - Anthropic Engineering](https://www.anthropic.com/engineering/claude-think-tool)
- [Extended thinking tips - Claude Docs](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/extended-thinking-tips)
- [Chain-of-Thought Prompting](https://www.promptingguide.ai/techniques/cot)
- [Buffer of Thoughts (BoT)](https://arxiv.org/abs/2406.04271)

---

**Derniere mise a jour**: 2025-12-26
**Auteur**: BMAD Framework Team
