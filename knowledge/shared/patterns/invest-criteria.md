# INVEST Criteria

> **Usage**: Scrum Master, Analyst - Validation de User Stories
> **CRITIQUE**: Chaque story DOIT respecter les 6 criteres

---

## Les 6 Criteres INVEST

### I - Independent

```
[ ] La story peut etre developpee independamment
[ ] Pas de couplage fort avec d'autres stories
[ ] Peut etre livree seule
```

**Question**: Cette story depend-elle d'autres stories non terminees?
**Si OUI**: Reordonner ou fusionner les stories

---

### N - Negotiable

```
[ ] Les details peuvent etre discutes
[ ] Le "quoi" est fixe, le "comment" est flexible
[ ] Ouvert aux suggestions techniques
```

**Question**: Les criteres d'acceptation permettent-ils plusieurs implementations?
**Si NON**: Generaliser les AC, focus sur le resultat pas la methode

---

### V - Valuable

```
[ ] Apporte de la valeur a l'utilisateur final
[ ] Contribue au sprint goal
[ ] ROI justifiable
```

**Question**: L'utilisateur final verra-t-il une difference?
**Si NON**: Reconsiderer la priorite ou fusionner avec une story valuable

---

### E - Estimable

```
[ ] L'equipe peut estimer la complexite
[ ] Pas d'inconnues majeures (sinon → Spike)
[ ] Scope suffisamment clair
```

**Question**: Peut-on estimer en points Fibonacci avec confiance?
**Si NON**: Creer un Spike pour lever les inconnues

---

### S - Small

```
[ ] Realisable en moins de 3 jours
[ ] Max 8 points (sinon decouper avec SPIDR)
[ ] Testable dans le sprint
```

**Question**: La story peut-elle etre terminee en 1 sprint?
**Si NON**: Decouper avec SPIDR (Spike, Path, Interface, Data, Rules)

---

### T - Testable

```
[ ] Criteres d'acceptation definis (Given-When-Then)
[ ] Tests automatisables
[ ] Definition of Done claire
```

**Question**: Comment saurons-nous que c'est "fait"?
**Si FLOU**: Reecrire les AC en format Gherkin

---

## Validation Checklist

```
+-------------------------------------------------------------------+
|                    INVEST VALIDATION                                |
+-------------------------------------------------------------------+
|                                                                   |
|  [ ] I - Independent: Pas de dependances bloquantes              |
|  [ ] N - Negotiable: Details flexibles                           |
|  [ ] V - Valuable: Valeur utilisateur claire                     |
|  [ ] E - Estimable: Points Fibonacci assignables                 |
|  [ ] S - Small: <= 8 points, < 3 jours                          |
|  [ ] T - Testable: AC en Given/When/Then                        |
|                                                                   |
|  SCORE: ___/6                                                    |
|  STATUS: [ ] READY  [ ] NEEDS WORK                               |
|                                                                   |
+-------------------------------------------------------------------+
```

---

## Points Fibonacci

| Points | Complexite | Duree Estimee |
|--------|------------|---------------|
| 1 | Trivial | 1-2h |
| 2 | Simple | 2-4h |
| 3 | Medium | 4-8h (1 jour) |
| 5 | Complexe | 1-2 jours |
| 8 | Tres complexe | 2-3 jours |
| 13 | **TROP GRAND** | Decouper! |

---

## Integration

- **Utilise par**: Scrum Master, Analyst, PM
- **Apres**: SPIDR decomposition
- **Avant**: Story marked READY
- **Si echec**: Retour a la decomposition
