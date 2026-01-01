---
name: "core-web-vitals"
description: "Core Web Vitals 2025 performance patterns"
version: "1.0"
auto_invoke: true
activate_when:
  file_matches:
    - "*.tsx"
    - "*.ts"
    - "vite.config.ts"
  keywords:
    - "performance"
    - "lcp"
    - "inp"
    - "cls"
    - "lighthouse"
    - "bundle"
agents:
  - dev
  - perf
  - architect
---

# Core Web Vitals 2025

> Patterns performance pour applications React

## Metrics 2025

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| **LCP** | ≤ 2.5s | 2.5-4.0s | > 4.0s |
| **INP** | ≤ 200ms | 200-500ms | > 500ms |
| **CLS** | ≤ 0.1 | 0.1-0.25 | > 0.25 |

> **Note**: INP (Interaction to Next Paint) remplace FID depuis mars 2024!

## Bundle Size Rules (PERF-4, PERF-5)

| Rule | Limit |
|------|-------|
| PERF-4 | No chunk > 500 KB |
| PERF-5 | Initial bundle < 200 KB (gzip) |

```bash
# Check after build
docker exec myapp-frontend npm run build
ls -la dist/assets/*.js | awk '$5 > 500000 {print "ERROR:", $9}'
```

## Lazy Loading (PERF-1, PERF-2)

```typescript
// PERF-1: All pages must use React.lazy()
const DashboardPage = React.lazy(() => import('./pages/DashboardPage'));

// PERF-2: Routes must use LazyRoute
<Route
  path="/dashboard"
  element={
    <LazyRoute>
      <DashboardPage />
    </LazyRoute>
  }
/>

// PERF-3: Heavy imports lazy
const Calendar = React.lazy(() =>
  import('@fullcalendar/react').then(m => ({ default: m.default }))
);
```

## Heavy Dependencies

| Library | Size | Solution |
|---------|------|----------|
| MUI Icons | 300KB+ | `@mui/icons-material/Specific` |
| date-fns | 200KB+ | Cherry-pick imports |
| Chart.js | 500KB+ | `React.lazy()` |
| FullCalendar | 800KB+ | Dynamic import |

## Image Optimization

```tsx
<img
  src={imageSrc}
  alt={description}
  loading="lazy"
  decoding="async"
  width={400}
  height={300}
/>

// Font preload
<link
  rel="preload"
  href="/fonts/Inter.woff2"
  as="font"
  type="font/woff2"
  crossOrigin="anonymous"
/>
```

## INP Optimization

```typescript
// Defer non-critical work
requestIdleCallback(() => {
  analytics.track('page_view');
});

// Use startTransition for non-urgent updates
import { startTransition } from 'react';

startTransition(() => {
  setFilteredResults(filterData(query));
});
```

## Lighthouse CLI

```bash
# Install
npm install -g lighthouse

# Run audit
lighthouse http://localhost:5173 \
  --output=html \
  --output-path=./lighthouse-report.html \
  --only-categories=performance
```

## References

- Steering: `.harmony/steering/frontend.md`
- Bundle check: `npm run build && ls -la dist/assets/`
