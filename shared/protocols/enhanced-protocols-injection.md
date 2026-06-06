# Enhanced Protocols Injection (v2.0)

> **Usage**: Ce fichier est injecte dans TOUS les agents Harmony
> **Version**: 2.0 - Deep Thinking Enhanced
> **Status**: OBLIGATOIRE - Ne pas modifier sans validation

---

## 🧠 THINKING OUTPUT PROTOCOL (CRITIQUE)

> **Reference Complete**: `.harmony/shared/thinking-output-protocol.md`
> **Performance**: +54% sur taches complexes (Anthropic Research)

### Niveaux de Reflexion

| Niveau | Duree | Declencheur |
|--------|-------|-------------|
| **think** | 30-60s | Decisions routinieres, patterns connus |
| **think_hard** | 1-2min | Plusieurs options valides, tradeoffs |
| **think_harder** | 2-4min | Risque eleve, irreversible, nouveau probleme |
| **ultrathink** | 5-10min | Architecture systeme, multi-agent, 8+ story points |

### Declencheurs Automatiques

VOUS DEVEZ output `<thinking>` AVANT:
- Operations Git critiques (commit, push, merge)
- Actions destructives (delete, drop, remove)
- Migrations de schema
- Deployments
- Transition exploration → implementation
- Signalement tache terminee
- Choix entre plusieurs approches
- Apres 2+ echecs consecutifs

### Format Obligatoire

```xml
<thinking level="[think|think_hard|think_harder|ultrathink]">
## Contexte
[Situation en 2-3 phrases]

## Options Evaluees
1. **[Option A]**: [Pros] / [Cons] - Score: X/10
2. **[Option B]**: [Pros] / [Cons] - Score: X/10

## Decision
[Choix] car [justification courte]

## Risques
- [Risque 1] → Mitigation: [Action]
</thinking>
```

### Format Court (pour decisions simples)

```xml
<thinking level="think">
**Situation**: [1 phrase]
**Decision**: [1 phrase]
**Raison**: [1 phrase]
</thinking>
```

---

## 📝 MEMORY PROTOCOL (CRITIQUE)

> **Reference Complete**: `.harmony/_cfg/memory-protocol.yaml`
> **Principe**: Sauvegarde PROACTIVE, pas sur demande

### Sauvegarde Automatique

VOUS DEVEZ sauvegarder IMMEDIATEMENT quand:

| Evenement | Fichier Cible | Message Output |
|-----------|---------------|----------------|
| Decision architecturale | `decision-history.json` | "📝 Decision sauvegardee: {summary}" |
| Pattern qui fonctionne | `learned-patterns.json` | "💡 Pattern appris: {summary}" |
| Erreur resolue | `error-journal.json` | "🔧 Erreur documentee: {summary}" |
| Preference utilisateur | `user-preferences.json` | "⚙️ Preference notee: {summary}" |
| Anti-pattern identifie | `anti-patterns.json` | "⚠️ Anti-pattern: {summary}" |

### Recuperation Automatique

AU DEBUT de chaque tache:
1. Lire `.harmony/memory/working.json` pour contexte actuel
2. Charger patterns pertinents pour le domaine
3. Verifier anti-patterns a eviter
4. Consulter MCP Memory si disponible

### Format de Sauvegarde

```json
{
  "id": "TYPE-YYYY-MM-DD-NNN",
  "timestamp": "ISO8601",
  "agent": "agent-name",
  "context": "description",
  "content": { /* details */ },
  "story_ref": "STORY-XXX (si applicable)"
}
```

---

## 📋 PLAN UPDATE PROTOCOL (CRITIQUE)

> **Reference Complete**: `.harmony/shared/plan-update-protocol.md`
> **Principe**: Le plan reflète TOUJOURS l'etat actuel

### Quand Mettre a Jour (OBLIGATOIRE)

| Evenement | Action | Urgence |
|-----------|--------|---------|
| Tache completee | Marquer DONE + passer a suivante | Immediate |
| Nouvelle information | Reviser scope/approche | Immediate |
| Blocage detecte | Documenter + alternatives | Immediate |
| Changement direction | Reviser tout le plan | Avant action |
| Fin session | Sauvegarder pour reprise | Avant fermeture |

### Principe "Update First"

```
AVANT d'ecrire du code ou prendre action majeure:
1. Verifier que le plan est a jour
2. Si nouvelle info → mettre a jour D'ABORD
3. PUIS executer l'action

APRES chaque action significative:
1. Mettre a jour statut tache
2. Documenter resultats/decouvertes
3. Ajuster plan si necessaire
```

### Format Court

```
📋 Plan Update: [Task #X] → [completed|in_progress|blocked]
```

### Format Long

```yaml
plan_update:
  timestamp: "2025-12-26T14:30:00Z"
  completed: ["Task 1", "Task 2"]
  current: "Task 3"
  remaining: ["Task 4", "Task 5"]
  blockers: []
  discoveries: ["Nouvelle info importante"]
```

---

## ✅ VERIFICATION PROTOCOL (CRITIQUE)

> **Reference Complete**: `.harmony/shared/verification-protocol.md`
> **Principe**: JAMAIS "termine" sans verification complete

### Self-Questions Obligatoires

AVANT de declarer une tache terminee, repondre OUI a TOUTES:

1. **Fonctionnel**: "Mon implementation fait-elle EXACTEMENT ce qui est demande?"
2. **Complet**: "Ai-je oublie quelque chose?"
3. **Qualite**: "Si je relisais ce code demain, serais-je fier?"
4. **Tests**: "Les tests prouvent-ils que ca marche?"
5. **Securite**: "Y a-t-il une faille de securite possible?"
6. **Patterns**: "Ai-je respecte les patterns du projet?"

### Regle Absolue

```
SI une reponse == NON:
   → NE PAS declarer termine
   → Corriger le probleme
   → Re-verifier
   → PUIS seulement declarer termine
```

### Format de Sortie

```markdown
## ✅ Verification PASSED
- Self-questions: 6/6 OUI
- Tests: PASS (coverage 100%)
- Decision: **DONE**

## ❌ Verification FAILED
- Self-questions: 4/6 OUI
- Echecs: [liste]
- Action: Corriger avant de continuer
```

---

## 🔄 CIRCUIT BREAKER PROTOCOL

> **Reference Complete**: `.harmony/shared/circuit-breaker-protocol.md`

### Pre-Execution Check

AVANT chaque operation critique:
1. Lire `.harmony/memory/circuit-breaker.json`
2. **Si `state === "OPEN"`**: STOP + afficher erreurs + attendre `/reset-circuit`
3. **Si `state === "CLOSED"`**: Continuer normalement

### Tracking Echecs

| Tentative | Message | Action |
|-----------|---------|--------|
| 1/3 | `⚠️ [Retry 1/3]` | Logger + Retry |
| 2/3 | `⚠️ [Retry 2/3]` | Logger + Retry |
| 3/3 | `🛑 Circuit OPEN` | STOP + Diagnostic obligatoire |

### Apres Succes

Remettre `failure_count` a 0 dans circuit-breaker.json

---

## 🎯 WORKFLOW UNIFIE

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW AGENT UNIFIE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. RECEVOIR tache                                              │
│     └─ Charger contexte Memory                                  │
│     └─ Verifier Circuit Breaker                                 │
│                                                                  │
│  2. ANALYSER avec <thinking>                                    │
│     └─ Evaluer complexite → niveau think                        │
│     └─ Output `<thinking level="X">...</thinking>`              │
│                                                                  │
│  3. PLANIFIER                                                   │
│     └─ Creer/charger plan                                       │
│     └─ Synchroniser TodoWrite                                   │
│                                                                  │
│  4. EXECUTER                                                    │
│     └─ Suivre plan etape par etape                             │
│     └─ Update plan apres CHAQUE etape                          │
│     └─ Sauvegarder decisions/patterns Memory                   │
│                                                                  │
│  5. VERIFIER                                                    │
│     └─ Self-questions (6/6 OUI requis)                         │
│     └─ Si echec → corriger → re-verifier                       │
│                                                                  │
│  6. COMPLETER                                                   │
│     └─ Marquer DONE                                             │
│     └─ Memory: lessons learned                                  │
│     └─ Plan Update: final                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚠️ ANTI-PATTERNS CRITIQUES

| Anti-Pattern | Description | Consequence |
|--------------|-------------|-------------|
| ❌ Agir sans `<thinking>` | Executer sans reflexion explicite | Erreurs evitables |
| ❌ Ignorer Memory | Ne pas charger/sauvegarder | Perte d'apprentissage |
| ❌ Plan statique | Jamais mettre a jour | Incoherence |
| ❌ Skip verification | Dire "termine" sans verifier | Bugs production |
| ❌ Ignorer Circuit Breaker | Continuer malgre echecs | Boucle infinie |
| ❌ Declarer termine avec NON | Self-question = NON mais continue | Qualite degradee |

---

## 📊 METRIQUES CIBLES

| Metrique | Cible | Mesure |
|----------|-------|--------|
| `<thinking>` avant decisions | > 80% | Audit |
| Memory saves/session | >= 5 | Count |
| Plan updates/tache | >= 1 | Count |
| Verification avant DONE | 100% | Audit |
| Erreurs post-verif | < 5% | Bug tracker |

---

**Version Injection**: 2.0
**Derniere mise a jour**: 2025-12-26
