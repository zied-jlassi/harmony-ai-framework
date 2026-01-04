# Conventions Projet Angular - À Personnaliser

> Ce fichier est un **template**. Chaque équipe doit le remplir avec ses propres conventions.
> Les standards industrie sont dans `../industry-standards/`.

---

## Comment Remplir Ce Fichier

1. **Identifier** ce qui est unique à votre projet Angular
2. **Documenter** les décisions d'équipe
3. **Expliquer** pourquoi (pas juste quoi)
4. **Versionner** les changements importants

---

## Template de Convention

```markdown
# [Nom de la Convention]

## Contexte
Pourquoi cette convention existe.

## Règle
Ce qui doit être fait.

## Exemple
\`\`\`typescript
// ✅ Bon
// ❌ Mauvais
\`\`\`

## Exceptions
Cas où la règle ne s'applique pas.
```

---

## Exemples de Conventions à Documenter

### Préfixe Sélecteurs

```typescript
// Quel préfixe utilisez-vous ?
// app- ? mycompany- ? projet- ?

@Component({
  selector: 'app-user-profile',  // ← Votre convention
})
```

### Structure State Management

```typescript
// Utilisez-vous NgRx, Signals, un service simple ?
// Quelle structure pour les stores ?

// Exemple de votre convention:
// src/app/
// ├── state/
// │   ├── user.state.ts
// │   └── cart.state.ts
```

### Conventions de Nommage Fichiers

```
// Quel pattern pour vos fichiers ?
// user-profile.component.ts  ?
// UserProfileComponent.ts    ?
// userProfile.component.ts   ?
```

### Gestion des Erreurs HTTP

```typescript
// Comment gérez-vous les erreurs HTTP ?
// Interceptor global ?
// Catch par service ?
// Toast automatique ?
```

### Tests

```typescript
// Quelle couverture minimum ?
// Jest ou Karma ?
// Mocks standards ?
```

---

## Votre Section Conventions

> ⬇️ Ajoutez vos conventions ci-dessous ⬇️

### [Votre Convention 1]

*À remplir par l'équipe*

### [Votre Convention 2]

*À remplir par l'équipe*

---

*Ce fichier est maintenu manuellement par l'équipe.*
*Dernière mise à jour: [DATE]*
