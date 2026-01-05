# P-018: SPIDR Framework

> **Pattern**: Decomposition d'Epic en Stories atomiques
> **Usage**: Scrum Master, Analyst, PM

---

## Principe

SPIDR est un framework de decomposition systematique des Epics en User Stories atomiques et testables.

---

## Framework SPIDR

```
+-------------------------------------------------------------------+
|                    FRAMEWORK SPIDR                                  |
+-------------------------------------------------------------------+
|                                                                   |
|  S - SPIKES (Incertitude)                                        |
|      Question: Y a-t-il des inconnues techniques?                |
|      Action: Creer spike timebox (2-4h) AVANT les stories        |
|      Ex: "Spike: evaluer Phaser vs PixiJS pour jeu temps reel"   |
|                                                                   |
|  P - PATHS (Chemins utilisateur)                                 |
|      Question: Y a-t-il plusieurs parcours possibles?            |
|      Action: 1 story par chemin principal                        |
|      Ex: "Login email" / "Login OAuth" / "Login parent"          |
|                                                                   |
|  I - INTERFACES (Plateformes)                                    |
|      Question: Plusieurs devices/interfaces?                      |
|      Action: 1 story par interface si comportement different     |
|      Ex: "Jeu Web Desktop" / "Jeu PWA Mobile" / "API scores"     |
|                                                                   |
|  D - DATA (Types de donnees)                                     |
|      Question: Donnees de complexite variable?                    |
|      Action: Commencer par donnees simples, ajouter complexes    |
|      Ex: "QCM texte" / "QCM images" / "QCM audio TTS"            |
|                                                                   |
|  R - RULES (Regles metier)                                       |
|      Question: Regles metier complexes?                           |
|      Action: Implementer regle basique, puis ajouter contraintes |
|      Ex: "Score basique" puis "Bonus streak" puis "Handicap age" |
|                                                                   |
+-------------------------------------------------------------------+
```

---

## Template Analyse SPIDR

```markdown
## Analyse SPIDR - Epic: [EPIC-XXX]

### S - Spikes necessaires?
| ID | Spike | Duree | Output attendu |
|----|-------|-------|----------------|
| SP-1 | [Investigation technique] | 4h | Decision Record |

### P - Chemins alternatifs?
| Path | Description | Priorite |
|------|-------------|----------|
| Happy Path | [Flux principal] | P0 |
| Alternative | [Mode facile/difficile] | P1 |
| Edge Case | [Game over/timeout] | P2 |

### I - Interfaces multiples?
| Interface | Specificites | Story dediee? |
|-----------|--------------|---------------|
| Web Desktop | Standard | Non |
| PWA Mobile | Touch, orientation | Oui |
| API | External/Webhook | Oui |

### D - Variations de donnees?
| Type Data | Complexite | Story dediee? |
|-----------|------------|---------------|
| Texte simple | Low | Non |
| Images | Medium | Oui |
| Audio/TTS | High | Oui |

### R - Regles metier?
| Regle | Complexite | Ordre implementation |
|-------|------------|---------------------|
| Score basique | Low | Sprint 1 |
| Bonus streak | Medium | Sprint 1 |
| Handicap niveau | High | Sprint 2 |

### Stories generees
| ID | Story | Points | Source SPIDR |
|----|-------|--------|--------------|
| STORY-001 | [titre] | 5 | P: Happy Path |
| STORY-002 | [titre] | 3 | I: Mobile PWA |
| STORY-003 | [titre] | 5 | D: Audio/TTS |
```

---

## Checklist SPIDR

| Lettre | Question Cle | Action |
|--------|--------------|--------|
| **S** | Des inconnues techniques? | Spike timebox |
| **P** | Plusieurs parcours? | 1 story/path |
| **I** | Multi-plateformes? | 1 story/interface |
| **D** | Donnees variables? | Simple → Complexe |
| **R** | Regles complexes? | Basique → Contraintes |

---

## Integration

- **Utilise par**: Scrum Master, Analyst, PM
- **Avant**: Context Discovery, Epic Definition
- **Apres**: INVEST Validation, Story Creation
- **Output**: Stories atomiques decomposees
