# document-enrichment

> **Version**: 1.0.0
> **Date**: 2025-12-27
> **Status**: OBLIGATOIRE
> **Scope**: Toute mise a jour de documents de reference (compliance, knowledge, configs)

---

## Principe Fondamental

```
┌─────────────────────────────────────────────────────────────────┐
│                    REGLE ABSOLUE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ENRICHIR, NE JAMAIS ECRASER                                   │
│                                                                  │
│   Les documents de reference sont des sources de verite.        │
│   Toute mise a jour doit AJOUTER de la valeur, pas REMPLACER.   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Acronyme GADER

| Lettre | Action | Description |
|:------:|--------|-------------|
| **G** | GARDER | Contenu valide existant (checklists, exemples, regles) |
| **A** | AJOUTER | Nouvelles sections a la fin ou dans section appropriee |
| **D** | DEMANDER | Validation utilisateur pour toute suppression |
| **E** | ENRICHIR | Completer les sections existantes avec nouvelles infos |
| **R** | REFUSER | Write sur fichier complet, batch delete sans liste |

---

## Pourquoi ce Pattern?

| Probleme Ecrasement | Solution Enrichissement |
|---------------------|-------------------------|
| Perte de checklists uniques | Toutes les checklists preservees |
| Perte d'exemples specifiques au projet | Exemples conserves et enrichis |
| Perte de regles personnalisees | Regles ajoutees, jamais supprimees |
| Confusion entre versions | Versioning strict (X.Y.Z) |
| Pas de trace des decisions | Changelog obligatoire |
| Suppressions silencieuses | Validation utilisateur requise |

---

## Regles Obligatoires

| # | Regle | Description |
|---|-------|-------------|
| **E1** | GARDER | Conserver 100% du contenu valide existant |
| **E2** | AJOUTER | Nouvelles sections en fin de document ou section appropriee |
| **E3** | ENRICHIR | Completer sections existantes, ne pas remplacer |
| **E4** | DEMANDER | AskUserQuestion avant TOUTE suppression |
| **E5** | VERSIONNER | Incrementer version a chaque modification |
| **E6** | EDIT-ONLY | Utiliser Edit, JAMAIS Write sur fichier existant |
| **E7** | CHANGELOG | Documenter les changements dans le fichier |

---

## Workflow en 5 Phases

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW ENRICHISSEMENT                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: INVENTAIRE                                            │
│  ├── Lister toutes les sections existantes                      │
│  ├── Lister toutes les checklists ([ ] ou □)                    │
│  ├── Lister tous les exemples de code                           │
│  └── Lister toutes les regles (format XX-YYY-NNN)               │
│                                                                  │
│  PHASE 2: ANALYSE                                               │
│  ├── Identifier sections a AJOUTER                              │
│  ├── Identifier contenu a ENRICHIR                              │
│  ├── Identifier contenu potentiellement OBSOLETE                │
│  └── Preparer liste des suppressions a VALIDER                  │
│                                                                  │
│  PHASE 3: VALIDATION                                            │
│  ├── Presenter liste ajouts (informatif)                        │
│  ├── Presenter liste suppressions proposees                     │
│  ├── AskUserQuestion pour CHAQUE suppression                    │
│  └── Documenter les decisions utilisateur                       │
│                                                                  │
│  PHASE 4: FUSION                                                │
│  ├── Conserver contenu valide                                   │
│  ├── Ajouter nouvelles sections                                 │
│  ├── Supprimer UNIQUEMENT contenu valide pour suppression       │
│  ├── Incrementer version                                        │
│  └── Utiliser Edit (pas Write)                                  │
│                                                                  │
│  PHASE 5: VERIFICATION                                          │
│  ├── Afficher resume: X ajouts, Y suppressions validees         │
│  ├── Comparer counts avant/apres                                │
│  └── Generer changelog de version                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Classification des Actions

### Actions AUTOMATIQUES (sans validation)

| Action | Exemple |
|--------|---------|
| Ajouter section | Nouvelle categorie de regles |
| Enrichir section | Ajouter details a une regle existante |
| Corriger typo | Faute d'orthographe evidente |
| Corriger erreur factuelle | Mauvais chemin de fichier |
| Incrementer version | v2.0.0 → v2.1.0 |

### Actions avec VALIDATION UTILISATEUR

| Action | Question a poser |
|--------|------------------|
| Supprimer regle | "Regle XX-YYY obsolete. Supprimer? [A/B/C/D]" |
| Supprimer exemple | "Exemple depasse. Supprimer ou marquer deprecated?" |
| Modifier significativement | "Section X modifiee a 50%. Valider les changements?" |
| Retirer code ancien | "Code pre-2024 detecte. Action?" |

### Actions INTERDITES

| Action | Raison |
|--------|--------|
| Write sur fichier existant | Risque d'ecrasement total |
| Batch delete sans liste | Pas de traçabilite |
| Supprimer sans explication | Utilisateur doit comprendre pourquoi |
| Supprimer checklists | Perte de validation manuelle |

---

## Template de Demande de Suppression

```
⚠️  CONTENU POTENTIELLEMENT OBSOLETE DETECTE

Element: [Nom de l'element]
Type: [Regle / Exemple / Section / Checklist]
Raison: [Pourquoi potentiellement obsolete]

Actions possibles:
  [A] Supprimer (obsolete confirme)
  [B] Conserver (encore utile)
  [C] Marquer [DEPRECATED] mais garder
  [D] Demander plus de contexte

Votre choix?
```

---

## Exemple de FUSION Correcte

### Document Original (v2.0.0)

```markdown
# Document v2.0.0

## Section A
[contenu A]

## Section B
[checklist B]
- [ ] Item 1
- [ ] Item 2
```

### Apres FUSION (v2.1.0)

```markdown
# Document v2.1.0

## Section A
[contenu A]                    ← GARDE
[nouveau paragraphe]           ← AJOUTE

## Section B
[checklist B]                  ← GARDE
- [ ] Item 1
- [ ] Item 2
- [ ] Item 3                   ← AJOUTE

## Section C (NOUVELLE)        ← AJOUTE
[nouveau contenu]

## Changelog
- v2.1.0: Ajout Section C, enrichissement Section A/B
```

---

## Exemple de FUSION Incorrecte

```markdown
# Document v2.0.0 (AVANT)
## Section A avec 5 regles
## Section B avec checklist

# Document v2.1.0 (APRES - INCORRECT!)
## Section A avec 3 regles     ← 2 regles PERDUES!
## Section C (nouvelle)        ← Section B SUPPRIMEE!
```

**Problemes:**
- 2 regles supprimees sans validation
- Section B disparue completement
- Pas de changelog

---

## Checklist Pre-Modification

```
□ J'ai lu le document ENTIER avant modification
□ J'ai liste toutes les sections existantes
□ J'ai identifie les checklists a preserver
□ J'utiliserai Edit (pas Write)
□ Je demanderai validation pour toute suppression
□ J'incrementerai la version
□ Je documenterai les changements
```

---

## Checklist Post-Modification

```
□ Nombre sections apres >= nombre sections avant
□ Toutes les checklists sont presentes
□ Tous les exemples sont presents (ou valides pour suppression)
□ Version incrementee
□ Changelog mis a jour
□ Aucun Write utilise sur fichier existant
```

---

## Integration avec Harmony

Ce pattern est applique automatiquement par:

| Mode Harmony | Application |
|--------------|-------------|
| `harmony claude --update` (12u) | Mise a jour regles conformite |
| `harmony memory` (11) | Sync MCP ↔ CLAUDE.md |
| `harmony fix` (4) | Corrections proposees |

---

## Documents Concernes

| Document | Type | Pattern Applicable |
|----------|------|:------------------:|
| `claude-code-compliance.md` | Conformite | OUI |
| `CLAUDE.md` | Configuration | OUI |
| `knowledge/*.md` | Reference | OUI |
| `patterns/*.md` | Patterns | OUI |
| Stories/Epics | Temporaire | NON |
| Logs/Reports | Genere | NON |

---

## Anti-Patterns

| Anti-Pattern | Consequence | Solution |
|--------------|-------------|----------|
| "Je recree le fichier" | Perte totale | Edit incrementaux |
| "C'est obsolete, je supprime" | Perte sans trace | Demander validation |
| "Je nettoie les vieilles regles" | Perte de contexte | Marquer deprecated |
| "Write c'est plus simple" | Ecrasement | Edit uniquement |

---

**Pattern**: Document Enrichment
**Objectif**: Preserver l'integrite des documents de reference lors des mises a jour
