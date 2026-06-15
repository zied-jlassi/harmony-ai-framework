# Harmony Documentation Guidelines

> **🌐 Langue :** [English](../DOCUMENTATION-GUIDELINES.md) · Français

## Regles pour les Exemples

### Secret Professionnel

> **REGLE ABSOLUE**: Ne JAMAIS utiliser le contexte du projet utilisateur dans les exemples de documentation.

| Interdit | Autorise |
|----------|----------|
| Projet reel de l'utilisateur | Exemples generiques |
| Noms de projets clients | "fashion-store", "my-app" |
| Contexte metier specifique | E-commerce, SaaS, Blog |
| Donnees reelles | Donnees fictives |

### Contextes d'Exemples Autorises

Utiliser ces contextes generiques pour les exemples:

| Contexte | Description | Exemple Nom |
|----------|-------------|-------------|
| e-commerce | Boutique en ligne | "fashion-store", "tech-shop" |
| saas | Application SaaS | "project-manager", "crm-app" |
| blog | Blog/CMS | "my-blog", "news-portal" |
| social | Reseau social | "social-app", "community" |
| fintech | Application financiere | "expense-tracker", "budget-app" |
| health | Application sante | "fitness-app", "wellness" |

### Donnees Fictives

Toujours utiliser des donnees fictives:

```yaml
# BON
project:
  name: "fashion-store"
  domain: "e-commerce"

# MAUVAIS - projet reel
project:
  name: "client-project"  # Interdit!
  domain: "confidentiel"
```

### Noms de Personnes

Utiliser des prenoms generiques:
- Alex, Jordan, Security Agent, Taylor (neutres)
- Marie, Jean, Pierre (francophones)
- John, Jane, Scrum Master (anglophones)

## Raisons

1. **Confidentialite**: Les projets utilisateurs sont confidentiels
2. **Neutralite**: Les exemples doivent etre universels
3. **Reutilisabilite**: Documentation utilisable par tous
4. **Professionnalisme**: Respect du secret professionnel

## Verification

Avant de publier de la documentation:

```
□ Aucun nom de projet reel
□ Aucun contexte metier specifique client
□ Donnees 100% fictives
□ Noms de personnes generiques
```
