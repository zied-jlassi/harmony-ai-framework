---
name: "tanstack-query"
description: "TanStack Query (React Query) patterns"
version: "1.0"
auto_invoke: true
activate_when:
  file_matches:
    - "**/hooks/use*.ts"
    - "**/services/**Service.ts"
  keywords:
    - "query"
    - "mutation"
    - "useQuery"
    - "useMutation"
    - "tanstack"
    - "cache"
agents:
  - dev
  - architect
---

# TanStack Query Patterns

> Patterns React Query pour applications React

## QueryClient Config

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,      // 5 min
      gcTime: 30 * 60 * 1000,         // 30 min (was cacheTime)
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});
```

## Query Keys Convention

```typescript
export const queryKeys = {
  users: {
    all: ['users'] as const,
    lists: () => [...queryKeys.users.all, 'list'] as const,
    list: (filters: Filters) => [...queryKeys.users.lists(), filters] as const,
    details: () => [...queryKeys.users.all, 'detail'] as const,
    detail: (id: string) => [...queryKeys.users.details(), id] as const,
  },
};

// Usage
useQuery({
  queryKey: queryKeys.users.detail(userId),
  queryFn: () => fetchUser(userId),
});
```

## Mutations Pattern

```typescript
// With invalidation
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: queryKeys.users.all });
    toast.success('User created');
  },
  onError: (error) => {
    toast.error(error.message);
  },
});

// Optimistic update
const mutation = useMutation({
  mutationFn: updateUser,
  onMutate: async (newUser) => {
    await queryClient.cancelQueries({ queryKey: queryKeys.users.detail(newUser.id) });
    const previous = queryClient.getQueryData(queryKeys.users.detail(newUser.id));
    queryClient.setQueryData(queryKeys.users.detail(newUser.id), newUser);
    return { previous };
  },
  onError: (err, newUser, context) => {
    queryClient.setQueryData(queryKeys.users.detail(newUser.id), context?.previous);
  },
  onSettled: (data, error, newUser) => {
    queryClient.invalidateQueries({ queryKey: queryKeys.users.detail(newUser.id) });
  },
});
```

## Prefetching

```typescript
// Prefetch on hover
<Link
  to={`/users/${user.id}`}
  onMouseEnter={() => {
    queryClient.prefetchQuery({
      queryKey: queryKeys.users.detail(user.id),
      queryFn: () => fetchUser(user.id),
    });
  }}
>
  {user.name}
</Link>
```

## Pagination

```typescript
const { data, isPlaceholderData } = useQuery({
  queryKey: ['users', page],
  queryFn: () => fetchUsers(page),
  placeholderData: keepPreviousData,  // v5 syntax
});

<Button disabled={isPlaceholderData || !data?.hasMore}>
  Next
</Button>
```

## Anti-patterns

| Avoid | Prefer |
|-------|--------|
| `staleTime: Infinity` | Reasonable staleTime |
| Manual refetch in useEffect | Query invalidation |
| String query keys | Typed key factories |
| Fetching in onClick | Prefetch + mutations |

## References

- Steering: `.harmony/steering/tanstack.md`
- v5 Migration: gcTime replaces cacheTime
