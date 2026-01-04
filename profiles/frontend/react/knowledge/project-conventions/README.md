# Conventions Projet React - À Personnaliser

> Ce fichier est un **template**. Chaque équipe doit le remplir avec ses propres conventions.
> Les standards industrie sont dans `../industry-standards/`.

---

## Comment Remplir Ce Fichier

1. **Identifier** ce qui est unique à votre projet React
2. **Documenter** les décisions d'équipe
3. **Expliquer** pourquoi (pas juste quoi)
4. **Versionner** les changements importants

---

## Exemples de Conventions à Documenter

### State Management

```jsx
// Quelle solution utilisez-vous ?
// useState local ? Context ? Redux ? Zustand ? Jotai ?

// Exemple de votre convention:
// "Zustand pour état global, useState pour local"
```

### Structure des Composants

```jsx
// Quel ordre dans vos composants ?
// Types → Hooks → Handlers → Render ?

// Exemple:
function MyComponent({ prop }: Props) {
  // 1. Hooks d'état
  const [state, setState] = useState();

  // 2. Hooks de context/store
  const user = useUser();

  // 3. Hooks d'effets
  useEffect(() => {}, []);

  // 4. Handlers
  function handleClick() {}

  // 5. Render helpers
  const renderItem = (item) => <Item {...item} />;

  // 6. Return
  return <div>...</div>;
}
```

### Styling

```jsx
// CSS Modules ? Tailwind ? Styled-components ? CSS-in-JS ?

// Exemple:
// "Tailwind pour tout, CSS Modules pour animations complexes"
```

### Data Fetching

```jsx
// React Query ? SWR ? useEffect + fetch ? Server Components ?

// Exemple:
// "TanStack Query pour toutes les requêtes API"
```

### Tests

```jsx
// Vitest ou Jest ?
// Testing Library patterns ?
// Coverage minimum ?

// Exemple:
// "Vitest + Testing Library, 80% coverage sur utils"
```

### Error Handling

```jsx
// Error Boundaries ?
// Toast notifications ?
// Logging service ?
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
