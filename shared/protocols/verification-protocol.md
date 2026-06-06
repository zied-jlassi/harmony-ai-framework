# Verification Protocol

> **Version**: 1.0
> **Source**: Claude Extended Thinking Tips + Devin AI Practices
> **Status**: OBLIGATOIRE avant de declarer une tache terminee

---

## Principe Fondamental

> "Ask Claude to verify its work with a simple test before declaring a task
> complete. Instruct the model to analyze whether its previous step achieved
> the expected result."
> — Claude Extended Thinking Tips

Le Verification Protocol garantit qu'une tache n'est declaree **DONE** que si
TOUS les criteres sont valides, evitant:
- Implementations partielles
- Bugs non detectes
- Oublis de requirements
- Regression de qualite

---

## Quand Verifier

### Declencheurs OBLIGATOIRES

| Situation | Verification Requise |
|-----------|---------------------|
| Avant de dire "termine" | COMPLETE_VERIFICATION |
| Apres implementation code | CODE_VERIFICATION |
| Apres ecriture tests | TEST_VERIFICATION |
| Avant commit | COMMIT_VERIFICATION |
| Avant PR | PR_VERIFICATION |
| Apres correction bug | BUG_VERIFICATION |

---

## Checklists de Verification

### 1. CODE_VERIFICATION

```markdown
## Code Verification Checklist

### Fonctionnalite ✓
- [ ] Le code fait ce qui est demande dans les AC
- [ ] Tous les edge cases sont geres
- [ ] Les erreurs sont gerees proprement
- [ ] Les messages d'erreur sont clairs (et adaptes enfants si applicable)

### Architecture ✓
- [ ] Respect Clean Architecture (Domain → Application → Infrastructure)
- [ ] Pas de dependances circulaires
- [ ] Single Responsibility respecte
- [ ] Injection de dependances utilisee

### Securite ✓
- [ ] Validation des inputs (Zod/class-validator)
- [ ] Guards appliques (JWT, Roles, Player, School)
- [ ] Pas de donnees sensibles exposees
- [ ] RGPD enfant respecte si applicable

### Performance ✓
- [ ] Pas de N+1 queries
- [ ] Pagination implementee si liste
- [ ] Cache utilise si donnees chaudes
- [ ] Complexite O(n) ou mieux

### Qualite ✓
- [ ] Pas de console.log/debugger
- [ ] Pas de TODO non resolu
- [ ] Naming conventions respectees
- [ ] Types TypeScript stricts

**Score**: _/20 (minimum 16 pour PASS)
```

### 2. TEST_VERIFICATION

```markdown
## Test Verification Checklist

### Coverage ✓
- [ ] Coverage >= 100% (OBLIGATOIRE)
- [ ] Tous les chemins testes (happy + error)
- [ ] Edge cases couverts
- [ ] Cas limites testes

### Qualite des Tests ✓
- [ ] Tests lisibles (Given-When-Then)
- [ ] Assertions significatives
- [ ] Pas de tests fragiles
- [ ] Mocks minimaux et justifies

### Types de Tests ✓
- [ ] Tests unitaires presents
- [ ] Tests integration si necessaire
- [ ] Tests E2E pour parcours critiques

### Execution ✓
- [ ] Tous les tests passent
- [ ] Pas de tests skipped sans raison
- [ ] Temps d'execution raisonnable

**Score**: _/16 (minimum 14 pour PASS)
```

### 3. COMMIT_VERIFICATION

```markdown
## Pre-Commit Verification Checklist

### Code ✓
- [ ] `npm run lint` passe sans erreur
- [ ] `npm run typecheck` passe sans erreur
- [ ] `npm run test` passe sans erreur
- [ ] `npm audit` sans vulnerabilites critiques

### Git ✓
- [ ] Seuls les fichiers necessaires sont staged
- [ ] Pas de fichiers sensibles (.env, credentials)
- [ ] Message de commit suit la convention
- [ ] Reference story dans le message

### Review ✓
- [ ] J'ai relu le diff moi-meme
- [ ] Le code est pret pour review externe

**Score**: _/10 (minimum 10 pour COMMIT - pas d'exception)
```

### 4. COMPLETE_VERIFICATION

```markdown
## Task Completion Verification

### Acceptance Criteria ✓
Pour CHAQUE AC de la story:
- [ ] AC1: [Description] → Verifie: [Comment]
- [ ] AC2: [Description] → Verifie: [Comment]
- [ ] AC3: [Description] → Verifie: [Comment]

### Self-Questions ✓
Repondre OUI a TOUTES ces questions:

1. **Fonctionnel**: "Mon implementation fait-elle EXACTEMENT ce qui est demande?"
   Reponse: [OUI/NON + justification]

2. **Complet**: "Ai-je oublie quelque chose?"
   Reponse: [OUI/NON + verification]

3. **Qualite**: "Si je relisais ce code demain, serais-je fier?"
   Reponse: [OUI/NON + pourquoi]

4. **Tests**: "Les tests prouvent-ils que ca marche?"
   Reponse: [OUI/NON + evidence]

5. **Securite**: "Y a-t-il une faille possible?"
   Reponse: [OUI/NON + verification]

6. **Patterns**: "Ai-je respecte les patterns du projet?"
   Reponse: [OUI/NON + liste patterns utilises]

### Final Gate ✓
- [ ] TOUS les AC sont valides
- [ ] TOUTES les self-questions repondues OUI
- [ ] TOUS les tests passent
- [ ] Documentation a jour si necessaire

**Decision**: [DONE / NOT_DONE + raison]
```

### 5. BUG_VERIFICATION

```markdown
## Bug Fix Verification

### Root Cause ✓
- [ ] Cause racine identifiee (pas juste symptome)
- [ ] Cause documentee dans Error Journal

### Fix ✓
- [ ] Fix cible la cause racine
- [ ] Fix ne casse pas autre chose
- [ ] Fix minimal et focalise

### Prevention ✓
- [ ] Test ajoute pour ce cas specifique
- [ ] Test aurait echoue AVANT le fix
- [ ] Test passe APRES le fix

### Regression ✓
- [ ] Tous les tests existants passent
- [ ] Pas de nouveau warning

**Score**: _/8 (minimum 8 pour valider bug fix)
```

---

## Workflow de Verification

```
┌─────────────────────────────────────────────────────────────────┐
│                  VERIFICATION WORKFLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. IMPLEMENTATION TERMINEE                                      │
│                    │                                             │
│                    ▼                                             │
│  2. CODE_VERIFICATION                                            │
│     └─ Score >= 16/20 ?                                         │
│        └─ NON → Corriger → Retour etape 2                       │
│        └─ OUI → Continuer                                       │
│                    │                                             │
│                    ▼                                             │
│  3. TEST_VERIFICATION                                            │
│     └─ Score >= 14/16 ?                                         │
│        └─ NON → Ajouter tests → Retour etape 3                  │
│        └─ OUI → Continuer                                       │
│                    │                                             │
│                    ▼                                             │
│  4. COMMIT_VERIFICATION                                          │
│     └─ Score == 10/10 ?                                         │
│        └─ NON → Corriger → Retour etape 4                       │
│        └─ OUI → Continuer                                       │
│                    │                                             │
│                    ▼                                             │
│  5. COMPLETE_VERIFICATION                                        │
│     └─ Tous OUI ?                                                │
│        └─ NON → Identifier gap → Retour etape appropriee        │
│        └─ OUI → DONE ✅                                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Format de Sortie

### Verification Reussie

```markdown
## ✅ Verification PASSED

**Task**: STORY-050 - Implementer scoring system
**Verification Type**: COMPLETE_VERIFICATION
**Timestamp**: 2025-12-26T15:00:00Z

### Resultats
- CODE_VERIFICATION: 18/20 ✅
- TEST_VERIFICATION: 16/16 ✅
- COMMIT_VERIFICATION: 10/10 ✅
- AC Validation: 3/3 ✅

### Self-Questions
1. Fonctionnel: OUI - Tous les scores sont calcules correctement
2. Complet: OUI - Verifie contre requirements
3. Qualite: OUI - Code clean, bien structure
4. Tests: OUI - 15 tests, coverage 100%
5. Securite: OUI - PlayerGuard applique, validation input
6. Patterns: OUI - Cache-Aside, Clean Architecture

### Decision
**DONE** - Tache prete pour review
```

### Verification Echouee

```markdown
## ❌ Verification FAILED

**Task**: STORY-050 - Implementer scoring system
**Verification Type**: CODE_VERIFICATION
**Timestamp**: 2025-12-26T14:30:00Z

### Resultats
- CODE_VERIFICATION: 12/20 ❌

### Echecs Identifies
1. **Securite**: PlayerGuard manquant sur `GET /scores`
2. **Performance**: N+1 query sur relation Player
3. **Qualite**: 2 TODO non resolus

### Actions Requises
1. Ajouter `@UseGuards(PlayerGuard)` ligne 45
2. Utiliser `include: { player: true }` dans query
3. Resoudre TODO lignes 78, 92

### Prochaine Etape
Corriger les 3 points puis re-executer CODE_VERIFICATION
```

---

## Integration dans les Agents

Chaque agent DOIT inclure:

```markdown
## Verification Protocol

> **Reference**: `.harmony/shared/verification-protocol.md`
> **Status**: OBLIGATOIRE

### Avant de dire "termine"

VOUS DEVEZ executer COMPLETE_VERIFICATION et obtenir:
- TOUS les scores >= seuil
- TOUTES les self-questions = OUI

### Si verification echoue

1. Identifier les gaps
2. Corriger
3. Re-verifier
4. NE JAMAIS dire "termine" si verification echoue
```

---

## Anti-Patterns (A EVITER)

### ❌ Ne PAS faire:

```markdown
<!-- MAUVAIS: Declarer termine sans verification -->
Agent: "J'ai termine l'implementation."
[Pas de verification executee]

<!-- MAUVAIS: Ignorer les echecs -->
Verification: 12/20 ❌
Agent: "C'est bon, c'est juste des details."

<!-- MAUVAIS: Verification superficielle -->
Agent: "Tout est bon." [Sans details]
```

### ✅ FAIRE:

```markdown
<!-- BON: Verification complete -->
Agent:
"## Verification COMPLETE_VERIFICATION
[Checklist complete avec scores]
**Decision**: DONE ✅"

<!-- BON: Echec = correction -->
Verification: 12/20 ❌
Agent: "Verification echouee. Correction en cours..."
[Corrige les problemes]
"Re-verification: 18/20 ✅ - Maintenant termine."
```

---

## Metriques

| Metrique | Cible | Mesure |
|----------|-------|--------|
| Taches avec verification | 100% | Audit |
| Score moyen CODE | >= 18/20 | Average |
| Score moyen TEST | >= 15/16 | Average |
| Bugs post-verification | < 5% | Bug tracker |

---

**Derniere mise a jour**: 2025-12-26
**Auteur**: Harmony Framework Team
