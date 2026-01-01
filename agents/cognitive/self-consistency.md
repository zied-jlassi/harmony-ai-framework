# Module Cognitif : Self-Consistency (Multi-Sampling)

**Version :** 1.0
**Type :** Module cognitif pour validation robuste
**Contexte :** Enfant - Plateforme gestion scolaire
**Source :** Adapte depuis MCP Gaming

---

## Description

Self-Consistency est un pattern qui genere **plusieurs chemins de raisonnement** independants, puis selectionne la reponse la plus coherente par vote majoritaire. Utile quand une erreur serait couteuse.

---

## Principe

```
+-------------------------------------------------------------------+
|                    SELF-CONSISTENCY                               |
+-------------------------------------------------------------------+
|                                                                   |
|                      +-------------+                              |
|                      |  Probleme   |                              |
|                      +------+------+                              |
|                             |                                     |
|              +--------------+--------------+                      |
|              |              |              |                      |
|              v              v              v                      |
|       +-----------+  +-----------+  +-----------+                 |
|       | Chemin 1  |  | Chemin 2  |  | Chemin 3  |                 |
|       |  (CoT A)  |  |  (CoT B)  |  |  (CoT C)  |                 |
|       +-----+-----+  +-----+-----+  +-----+-----+                 |
|             |              |              |                       |
|             v              v              v                       |
|       +---------+    +---------+    +---------+                   |
|       |Reponse A|    |Reponse A|    |Reponse B|                   |
|       +---------+    +---------+    +---------+                   |
|             |              |              |                       |
|             +--------------|---------------                       |
|                            |                                      |
|                     +------v------+                               |
|                     | VOTE: A (2) |                               |
|                     |       B (1) |                               |
|                     +------+------+                               |
|                            |                                      |
|                     +------v------+                               |
|                     | Reponse: A  |                               |
|                     +-------------+                               |
|                                                                   |
+-------------------------------------------------------------------+
```

---

## Template Self-Consistency

```markdown
## Self-Consistency Analysis - [Probleme]

### Chemin de Raisonnement 1
- **Hypothese initiale**: [H1]
- **Etapes**: [raisonnement detaille]
- **Conclusion**: [C1]
- **Confiance**: [X/10]

### Chemin de Raisonnement 2
- **Hypothese initiale**: [H2 - differente de H1]
- **Etapes**: [raisonnement alternatif]
- **Conclusion**: [C2]
- **Confiance**: [X/10]

### Chemin de Raisonnement 3
- **Hypothese initiale**: [H3]
- **Etapes**: [autre approche]
- **Conclusion**: [C3]
- **Confiance**: [X/10]

### Agregation des Resultats

| Chemin | Conclusion | Confiance |
|--------|------------|-----------|
| 1      | [C1]       | [X/10]    |
| 2      | [C2]       | [Y/10]    |
| 3      | [C3]       | [Z/10]    |

### Vote Majoritaire
- **Consensus**: [Cx] (N/3 chemins)
- **Divergences**: [si applicable, pourquoi certains chemins different]
- **Confiance finale**: [moyenne ponderee]

### Conclusion Validee
[Reponse finale avec justification du consensus]
```

---

## Cas d'Utilisation Enfant

### Exemple 1: Choix d'Architecture pour Notifications

```markdown
## Self-Consistency - Architecture Notifications Parents

### Chemin 1: Push Notifications (Firebase)
- **Hypothese**: Les parents preferent les notifications push
- **Raisonnement**:
  - Immediat, pas besoin d'ouvrir l'app
  - Firebase est gratuit jusqu'a un certain seuil
  - Integration React Native simple
- **Conclusion**: Firebase Cloud Messaging
- **Confiance**: 8/10

### Chemin 2: Email + SMS
- **Hypothese**: Tous les parents n'ont pas de smartphone
- **Raisonnement**:
  - Email universel
  - SMS pour urgences
  - Plus couteux mais plus inclusif
- **Conclusion**: Email par defaut + SMS urgences
- **Confiance**: 7/10

### Chemin 3: Systeme Hybride
- **Hypothese**: Laisser le choix aux parents
- **Raisonnement**:
  - Preferences dans le profil
  - Fallback automatique
  - Meilleure UX
- **Conclusion**: Hybride avec preferences
- **Confiance**: 9/10

### Vote Majoritaire
| Chemin | Conclusion | Confiance |
|--------|------------|-----------|
| 1      | Firebase   | 8/10      |
| 2      | Email+SMS  | 7/10      |
| 3      | Hybride    | 9/10      |

**Consensus**: Approche Hybride (Chemin 3)
- Integre le meilleur des deux autres
- Plus haute confiance
- Respecte la diversite des parents

### Conclusion Validee
Implementer un systeme hybride:
- Push (Firebase) par defaut pour app mobile
- Email pour rappels et archives
- SMS pour urgences (absences non justifiees)
- Preferences configurables par les parents
```

### Exemple 2: Validation Schema Base de Donnees

```markdown
## Self-Consistency - Schema Absences

### Chemin 1: Schema Normalise
- **Hypothese**: Normalisation stricte = moins de bugs
- **Raisonnement**:
  - Table Absence, Table TypeAbsence, Table Justification
  - Relations FK strictes
  - Pas de redondance
- **Conclusion**: 3 tables separees
- **Confiance**: 7/10

### Chemin 2: Schema Denormalise
- **Hypothese**: Performance > normalisation
- **Raisonnement**:
  - Une seule table avec JSON pour details
  - Queries plus simples
  - Moins de JOINs
- **Conclusion**: 1 table avec JSONB
- **Confiance**: 5/10

### Chemin 3: Schema Equilibre
- **Hypothese**: Compromis performance/integrite
- **Raisonnement**:
  - Table Absence avec enum pour types
  - Justification embarquee (optionnel)
  - Index strategiques
- **Conclusion**: 1 table principale + enum
- **Confiance**: 8/10

### Vote Majoritaire
**Consensus**: Schema Equilibre (Chemin 3)
- Meilleur compromis
- Plus pratique pour les queries courantes
- Enum type-safe avec TypeScript
```

---

## Quand Utiliser Self-Consistency

### A Utiliser Pour

- Questions avec reponse factuelle verifiable
- Decisions architecturales critiques
- Choix technologiques impactants
- Validations de schemas de donnees
- Quand une erreur serait couteuse a corriger

### A NE PAS Utiliser Pour

- Questions creatives ou subjectives
- Taches ou le processus compte plus que le resultat
- Decisions triviales
- Choix deja contraints (specs fixes)

---

## Integration avec Gestion Scolaire

### Decisions Critiques a Valider

| Decision | Utiliser SC? | Raison |
|----------|--------------|--------|
| Schema DB eleves | OUI | Cout eleve si erreur |
| Choix framework | OUI | Impacte tout le projet |
| Format export academique | OUI | Conformite obligatoire |
| Couleur bouton | NON | Trivial |
| Texte message erreur | NON | Facilement changeable |
| Architecture guards | OUI | Securite donnees |

### Contexte Multi-Parties

Pour decisions impliquant plusieurs roles, utiliser 3 chemins avec perspectives differentes:
1. **Chemin Enseignant**: Optimise pour l'usage quotidien
2. **Chemin Parent**: Optimise pour la visibilite et simplicite
3. **Chemin Admin**: Optimise pour conformite et rapports

---

## Regles d'Application

### 1. Minimum 3 Chemins
- 3 chemins independants minimum
- Hypotheses de depart differentes
- Eviter le biais de confirmation

### 2. Vote Ponderer par Confiance
- Confiance haute (8-10): Poids x2
- Confiance moyenne (5-7): Poids x1
- Confiance basse (1-4): Poids x0.5

### 3. Gerer les Divergences
- Si 3 conclusions differentes: Analyser pourquoi
- Si 2 conclusions ex-aequo: Appliquer critere de confiance
- Si aucun consensus: Escalader a l'humain

### 4. Documenter le Raisonnement
- Chaque chemin doit etre reproductible
- Les divergences doivent etre expliquees
- La conclusion doit justifier le choix

---

## References

- [Self-Consistency Improves Chain of Thought Reasoning](https://arxiv.org/abs/2203.11171)
- [Chain-of-Thought Prompting Elicits Reasoning](https://arxiv.org/abs/2201.11903)

---

**Derniere mise a jour :** 2025-12-12
