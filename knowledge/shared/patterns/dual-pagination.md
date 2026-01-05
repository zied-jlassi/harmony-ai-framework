# dual-pagination

> **Pattern**: dual-pagination
> **Version**: 1.0.0
> **Date**: 2025-12-25
> **Status**: OBLIGATOIRE
> **Source**: Harmony Framework
> **Scope**: Toutes les pages liste avec pagination

---

## Principe Fondamental

```
┌─────────────────────────────────────────────────────────────────┐
│                    DUAL PAGINATION                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   UN hook unique pour DEUX modes de pagination:                  │
│                                                                  │
│   ┌─────────────────────┐   ┌─────────────────────┐             │
│   │    LOAD_MORE        │   │     NUMBERED        │             │
│   │  (Infinite Scroll)  │   │ (Classic Pagination)│             │
│   │                     │   │                     │             │
│   │  [Charger plus]     │   │ [<<][<][1][2][3][>][>>]          │
│   │  + indicateur       │   │ + sélecteur taille  │             │
│   └─────────────────────┘   └─────────────────────┘             │
│                                                                  │
│   Mode déterminé par: config système /configuration/pagination   │
│   Limite sécurité backend: maxPageSize = 50                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Règles Obligatoires

| # | Règle | Description |
|---|-------|-------------|
| **R1** | **Un seul hook** | Utiliser `useDualPagination` (jamais `useInfiniteScroll` seul) |
| **R2** | **Config système** | Le mode est lu depuis `usePaginationConfig` |
| **R3** | **Dual UI** | La View doit gérer les 2 modes (conditionnel) |
| **R4** | **Format unifié** | Service retourne `{ data: T[], total: number }` |
| **R5** | **maxPageSize: 50** | Limite backend non configurable |
| **R6** | **Filtres via ref** | Passer les filtres via `filtersRef` pour éviter re-fetch |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────┐                                           │
│   │ PaginationConfig│  (Contexte système)                       │
│   │ mode: LOAD_MORE │                                           │
│   │    ou NUMBERED  │                                           │
│   └────────┬────────┘                                           │
│            │                                                     │
│            ▼                                                     │
│   ┌─────────────────┐                                           │
│   │useDualPagination│  (Hook partagé)                           │
│   │                 │                                           │
│   │ - items         │ ◄─── Données unifiées                     │
│   │ - loading       │                                           │
│   │ - total         │                                           │
│   │                 │                                           │
│   │ Mode LOAD_MORE: │                                           │
│   │ - hasMore       │                                           │
│   │ - loadMore()    │                                           │
│   │ - sentinelRef   │                                           │
│   │                 │                                           │
│   │ Mode NUMBERED:  │                                           │
│   │ - paginationController (null si LOAD_MORE)                  │
│   │                 │                                           │
│   │ - isLoadMoreMode│ ◄─── Détection du mode                    │
│   │ - reset()       │                                           │
│   │ - refresh()     │                                           │
│   └────────┬────────┘                                           │
│            │                                                     │
│            ▼                                                     │
│   ┌─────────────────┐                                           │
│   │   Controller    │  (Feature-specific)                       │
│   │                 │                                           │
│   │ Expose:         │                                           │
│   │ - items         │                                           │
│   │ - loading       │                                           │
│   │ - paginationController                                      │
│   │ - isLoadMoreMode│                                           │
│   │ - hasMore       │                                           │
│   │ - loadMore      │                                           │
│   └────────┬────────┘                                           │
│            │                                                     │
│            ▼                                                     │
│   ┌─────────────────┐                                           │
│   │      View       │  (UI conditionnelle)                      │
│   │                 │                                           │
│   │ if LOAD_MORE:   │                                           │
│   │   <LoadMoreView>│                                           │
│   │                 │                                           │
│   │ if NUMBERED:    │                                           │
│   │   <PaginationView>                                          │
│   └─────────────────┘                                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Composants

### 1. Hook `useDualPagination`

**Localisation**: `frontend-admin/src/shared/hooks/useDualPagination.ts`

```typescript
import { useDualPagination } from '@shared/hooks';

const {
  // ========== Données unifiées ==========
  items,                    // T[] - Items de la page courante
  loading,                  // boolean - Chargement en cours
  initialLoading,           // boolean - Premier chargement
  error,                    // Error | null
  total,                    // number | null - Total items

  // ========== Mode LOAD_MORE ==========
  hasMore,                  // boolean - Plus d'items à charger
  totalLoaded,              // number - Items chargés jusqu'ici
  loadMore,                 // () => Promise<void> - Charger plus
  sentinelRef,              // (node) => void - Ref pour intersection

  // ========== Mode NUMBERED ==========
  paginationController,     // PaginationController | null

  // ========== Détection mode ==========
  isLoadMoreMode,           // boolean - true si LOAD_MORE
  paginationConfig,         // Config système

  // ========== Actions ==========
  reset,                    // () => void - Reset page 1
  refresh,                  // () => void - Refresh current
} = useDualPagination<T, F>({
  fetchFn: (page, pageSize, filters) => service.getPaginated(page, pageSize, filters),
  filtersRef,               // React.MutableRefObject<F>
  initialPageSize: 50,      // Défaut: 50
  pageSizeOptions: [10, 25, 50, 100],
  canChangePageSize: true,
});
```

### 2. PaginationController (Mode NUMBERED)

```typescript
interface PaginationController {
  pagination: PaginationModel;
  handleNextPage: () => void;
  handlePreviousPage: () => void;
  handleGoToPage: (page: number) => void;
  handlePageSizeChange: (size: number) => void;
  pageSizeOptions: number[];
  canChangePageSize: boolean;
  canGoPrevious: boolean;
  canGoNext: boolean;
  paginationText: string;
}
```

### 3. PaginationView (Composant UI)

**Localisation**: `frontend-admin/src/shared/components/pagination/views/PaginationView.tsx`

```tsx
<PaginationView
  controller={paginationController}
  showTotalItems={true}           // "Affichage de X à Y sur Z"
  showPageSizeSelector={true}     // Sélecteur 10/25/50/100
/>
```

**Affichage**:
```
[Affichage de 1 à 50 sur 245 résultats]  [Éléments par page: [50▼]]

                    [<<] [<] [1] [2] [3] [4] [5] [>] [>>]
```

### 4. LoadMoreView (Composant UI)

```tsx
<LoadMoreView
  onLoadMore={loadMore}
  loading={loading}
  current={items.length}
  total={total}
/>
```

---

## Implémentation

### 1. Controller

```typescript
// AVANT (ancien pattern)
import { useInfiniteScroll } from '@shared/hooks';

const infiniteScroll = useInfiniteScroll<User>({
  fetchFn: fetchUsers,
  limit: 50,
});

// APRÈS (nouveau pattern)
import { useDualPagination } from '@shared/hooks';

const filtersRef = useRef<UserFilters>({});

const {
  items,
  loading,
  initialLoading,
  hasMore,
  loadMore,
  reset,
  sentinelRef,
  // Nouveaux props
  paginationController,
  isLoadMoreMode,
} = useDualPagination<User, UserFilters>({
  fetchFn: (page, pageSize, filters) =>
    usersService.getUsersPaginated(page, pageSize, filters),
  filtersRef,
});

// Exporter vers la View
return {
  items,
  loading,
  paginationController,
  isLoadMoreMode,
  hasMore,
  loadMore,
  // ...
};
```

### 2. View

```tsx
import { PaginationView } from '@shared/components/pagination/views/PaginationView';
import { LoadMoreView } from '@shared/components/pagination/views/LoadMoreView';

function UsersListView({ controller }: Props) {
  return (
    <div>
      {/* DataTable */}
      <DataTable
        data={controller.items}
        columns={columns}
        loading={controller.loading}
      />

      {/* Mode LOAD_MORE */}
      {controller.isLoadMoreMode && controller.hasMore && (
        <LoadMoreView
          onLoadMore={controller.loadMore}
          loading={controller.loading}
          current={controller.items.length}
          total={controller.total}
        />
      )}

      {/* Mode NUMBERED */}
      {!controller.isLoadMoreMode && controller.paginationController && (
        <PaginationView
          controller={controller.paginationController}
          showTotalItems={true}
          showPageSizeSelector={true}
        />
      )}
    </div>
  );
}
```

### 3. Service

```typescript
// Le service DOIT retourner { data: T[], total: number }
async getUsersPaginated(
  page: number,
  pageSize: number,
  filters?: UserFilters
): Promise<{ data: User[]; total: number }> {
  // Pattern SEARCH-RESOURCE: POST avec body
  const response = await api.post('/users', {
    page,
    limit: pageSize,
    ...filters,
  });

  return {
    data: response.data.data,
    total: response.data.meta.total,
  };
}
```

---

## Modes de Pagination

### LOAD_MORE (Infinite Scroll)

```
┌─────────────────────────────────────────┐
│  [Item 1]                               │
│  [Item 2]                               │
│  [Item 3]                               │
│  ...                                    │
│  [Item 50]                              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Charger plus (50 sur 245)      │   │
│  └─────────────────────────────────┘   │
│                                         │
│  <sentinel ref="sentinelRef" />         │
└─────────────────────────────────────────┘
```

**Props utilisés**:
- `hasMore`: Afficher le bouton
- `loadMore()`: Action du bouton
- `sentinelRef`: Intersection Observer
- `totalLoaded`: Compteur affiché

### NUMBERED (Classic)

```
┌─────────────────────────────────────────────────────────────────┐
│  [Item 1]                                                        │
│  [Item 2]                                                        │
│  ...                                                             │
│  [Item 50]                                                       │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│  Affichage de 1 à 50 sur 245   Éléments par page: [50▼]         │
│                                                                  │
│                        [<<] [<] [1] [2] [3] [4] [5] [>] [>>]    │
└─────────────────────────────────────────────────────────────────┘
```

**Props utilisés**:
- `paginationController.pagination`: État
- `paginationController.handleGoToPage(n)`: Navigation
- `paginationController.handlePageSizeChange(size)`: Taille page
- `paginationController.canGoPrevious/canGoNext`: État boutons

---

## Limites Sécurité

| Paramètre | Valeur | Configurable | Description |
|-----------|--------|--------------|-------------|
| `maxPageSize` | 50 | Non | Limite imposée par backend |
| `defaultPageSize` | 20 | Oui | Via `/configuration/pagination` |
| `pageSizeOptions` | [10, 25, 50] | Oui | Options du sélecteur |

**Backend**: Si `limit > 50`, retourne `400 Bad Request`.

---

## Checklist Pré-Dev

### Controller
```
□ Importer useDualPagination de @shared/hooks
□ Créer filtersRef avec useRef<Filters>({})
□ Remplacer useInfiniteScroll par useDualPagination
□ Adapter fetchFn: (page, pageSize, filters) => service.getPaginated(...)
□ Exporter paginationController, isLoadMoreMode
□ Exporter hasMore, loadMore (pour mode LOAD_MORE)
```

### View
```
□ Importer PaginationView et LoadMoreView
□ Ajouter section conditionnelle LOAD_MORE
□ Ajouter section conditionnelle NUMBERED
□ Vérifier que DataTable reçoit controller.items
```

### Service
```
□ Format retour: { data: T[], total: number }
□ Utiliser POST (pattern SEARCH-RESOURCE)
□ Respecter maxPageSize: 50
```

### Tests
```
□ Mode LOAD_MORE fonctionne
□ Changer config → /configuration/pagination
□ Mode NUMBERED: boutons [<<] [<] [1] [2] [3] [>] [>>]
□ Sélecteur page size (10, 25, 50)
□ Navigation entre pages
□ Filtres reset page à 1
□ Backend refuse > 50 items
```

---

## Migration depuis useInfiniteScroll

```diff
- import { useInfiniteScroll } from '@shared/hooks';
+ import { useDualPagination } from '@shared/hooks';

+ const filtersRef = useRef<MyFilters>({});

- const {
-   items,
-   loading,
-   hasMore,
-   loadMore,
-   sentinelRef,
- } = useInfiniteScroll<Item>({
-   fetchFn: (page, limit) => myService.getItems({ page, limit }),
-   limit: 50,
- });

+ const {
+   items,
+   loading,
+   hasMore,
+   loadMore,
+   sentinelRef,
+   paginationController,
+   isLoadMoreMode,
+ } = useDualPagination<Item, MyFilters>({
+   fetchFn: (page, pageSize, filters) =>
+     myService.getItemsPaginated(page, pageSize, filters),
+   filtersRef,
+ });
```

---

## Références

| Ressource | Localisation |
|-----------|--------------|
| **Hook source** | `frontend/src/shared/hooks/useDualPagination.ts` |
| **PaginationView** | `frontend/src/shared/components/pagination/views/PaginationView.tsx` |
| **PaginationModel** | `frontend/src/shared/components/pagination/models/Pagination.model.ts` |
| **useInfiniteScroll** | `frontend/src/shared/hooks/useInfiniteScroll.ts` |
| **Pattern search-resource** | `.harmony/core/knowledge/search-resource.md` |

---

## Changelog

| Version | Date | Changement |
|---------|------|------------|
| 1.0.0 | 2025-12-25 | Création initiale |
