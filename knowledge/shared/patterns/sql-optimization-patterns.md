---
name: sql-optimization-patterns
displayName: "SQL Optimization Patterns"
category: developer-essentials
tier: 2
model: inherit
triggers:
  - "slow query"
  - "sql performance"
  - "index optimization"
  - "query plan"
  - "database optimization"
---

# SQL Optimization Patterns

> Optimize SQL queries and indexing for maximum performance.

## Query Analysis

### EXPLAIN ANALYZE
```sql
-- PostgreSQL
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM users WHERE email = 'test@example.com';

-- Key metrics to watch:
-- - Seq Scan vs Index Scan
-- - Rows estimated vs actual
-- - Execution time
```

### Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `SELECT *` | Fetches unnecessary data | Select only needed columns |
| `OR` in WHERE | Prevents index usage | Use UNION or IN |
| Functions on columns | Prevents index usage | Use computed columns |
| `LIKE '%value%'` | Full table scan | Full-text search or trigram |
| N+1 queries | Multiple round trips | JOIN or batch fetch |

## Indexing Strategies

### B-Tree Index (Default)
```sql
-- Single column
CREATE INDEX idx_users_email ON users(email);

-- Composite (order matters!)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);

-- Partial index
CREATE INDEX idx_active_users ON users(email) WHERE active = true;
```

### Covering Index
```sql
-- Include columns to avoid table lookup
CREATE INDEX idx_orders_covering ON orders(user_id)
INCLUDE (total, status, created_at);
```

### Index Selection Rules

1. **High selectivity** columns first
2. **Equality** before **range** conditions
3. **Frequently queried** columns
4. **Foreign keys** always indexed
5. **Avoid over-indexing** (write performance)

## Query Optimization

### Pagination
```sql
-- BAD: OFFSET is slow for large values
SELECT * FROM posts ORDER BY id LIMIT 20 OFFSET 10000;

-- GOOD: Keyset pagination
SELECT * FROM posts
WHERE id > :last_seen_id
ORDER BY id
LIMIT 20;
```

### Batch Operations
```sql
-- BAD: One by one
UPDATE users SET status = 'inactive' WHERE id = 1;
UPDATE users SET status = 'inactive' WHERE id = 2;

-- GOOD: Batch update
UPDATE users SET status = 'inactive'
WHERE id = ANY(ARRAY[1, 2, 3, 4, 5]);
```

### CTEs for Readability
```sql
WITH active_orders AS (
  SELECT user_id, COUNT(*) as order_count
  FROM orders
  WHERE status = 'active'
  GROUP BY user_id
)
SELECT u.name, ao.order_count
FROM users u
JOIN active_orders ao ON u.id = ao.user_id;
```

## Monitoring

```sql
-- PostgreSQL: Slow queries
SELECT query, calls, mean_time, total_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Unused indexes
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

## Checklist

- [ ] Run EXPLAIN ANALYZE on slow queries
- [ ] Check index usage with pg_stat_user_indexes
- [ ] Avoid N+1 queries (use eager loading)
- [ ] Use keyset pagination for large datasets
- [ ] Monitor query performance regularly
