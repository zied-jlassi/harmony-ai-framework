# Vertical Slicing

> **Usage**: Scrum Master, Developer - Structure des User Stories
> **CRITIQUE**: OBLIGATOIRE pour toutes les stories

---

## Principe

```
HORIZONTAL (INTERDIT)              VERTICAL (OBLIGATOIRE)
+-----------------------------+    +---+---+---+---+---+
|         UI Layer            |    | S | S | S | S | S |
+-----------------------------+    | t | t | t | t | t |
|        API Layer            |    | o | o | o | o | o |
+-----------------------------+    | r | r | r | r | r |
|      Business Logic         |    | y | y | y | y | y |
+-----------------------------+    |   |   |   |   |   |
|       Database              |    | 1 | 2 | 3 | 4 | 5 |
+-----------------------------+    +---+---+---+---+---+
```

---

## Exemples

### INTERDIT (Horizontal)

```
❌ "Story: Creer le frontend jeu"
❌ "Story: Creer l'API scores"
❌ "Story: Creer le schema DB"
❌ "Story: Implementer la couche service"
```

### OBLIGATOIRE (Vertical)

```
✅ "Story: Joueur peut voir son score"
✅ "Story: Joueur peut jouer 1 partie"
✅ "Story: Joueur peut debloquer badge"
✅ "Story: Admin peut voir statistiques"
```

---

## Checklist Vertical Slice

```
+-------------------------------------------------------------------+
|                    VERTICAL SLICE CHECKLIST                         |
+-------------------------------------------------------------------+
|                                                                   |
|  [ ] UI: Composant visible par l'utilisateur (si applicable)     |
|  [ ] API: Endpoint(s) fonctionnel(s)                             |
|  [ ] Logic: Regle metier implementee                             |
|  [ ] Data: Persistance si necessaire                             |
|  [ ] Tests: E2E qui valide le flux complet                       |
|  [ ] Demontrable: L'utilisateur peut voir/utiliser quelque chose |
|                                                                   |
+-------------------------------------------------------------------+
```

---

## Test du Gateau

```
HORIZONTAL = Couches du gateau (mauvais)
- "Je mange d'abord la creme"
- "Puis le biscuit"
- "Puis le nappage"

VERTICAL = Tranches du gateau (bon)
- "Je mange une tranche complete"
- "Chaque tranche a creme + biscuit + nappage"
- "Chaque tranche est satisfaisante"
```

---

## Integration

- **Utilise par**: Scrum Master (validation), Developer (implementation)
- **Valide avec**: INVEST criteria (critere V - Valuable)
- **Consequence**: Story non-verticale = REFUSER
