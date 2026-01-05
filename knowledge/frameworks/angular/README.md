# Expérience Projet Angular - Auto-Enrichi par Sentinel

> Ce dossier est **automatiquement enrichi** par Harmony Sentinel.
> Chaque erreur documentée devient une leçon apprise.

---

## Comment ça Fonctionne

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE D'APPRENTISSAGE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. ERREUR RENCONTRÉE                                           │
│     └─ Bug Angular, erreur build, problème runtime              │
│                                                                  │
│  2. SENTINEL DOCUMENTE                                          │
│     └─ /harmony --mode sentinel --learn                         │
│     └─ Ajoute dans error-journal.json                           │
│                                                                  │
│  3. SYNC VERS PROFILE                                           │
│     └─ Tags Angular → Copié ici automatiquement                 │
│     └─ Devient "pitfall" documenté                              │
│                                                                  │
│  4. PRÉVENTION FUTURE                                           │
│     └─ Guardian/Sentinel vérifie avant chaque dev               │
│     └─ Alerte si pattern similaire détecté                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Fichiers Auto-Générés

| Fichier | Source | Description |
|---------|--------|-------------|
| `pitfalls.md` | error-journal.json | Erreurs avec tags "angular", "frontend" |
| `solutions.md` | learned-patterns.json | Solutions validées |
| `anti-patterns.md` | anti-patterns.json | Ce qu'il ne faut plus faire |

---

## Tags Surveillés

Le Sentinel synchronise automatiquement les erreurs avec ces tags:

- `angular`
- `typescript`
- `frontend`
- `rxjs`
- `signals`
- `standalone`
- `router`
- `forms`

---

## Exemple d'Entrée Auto-Générée

```markdown
## ERR-078: Memory Leak avec Subscription RxJS

**Date**: 2026-01-03
**Sévérité**: HIGH
**Module**: dashboard

### Symptôme
Performance dégradée après navigation, mémoire croissante.

### Cause Racine
Subscription HTTP non unsubscribe dans ngOnDestroy.

### Solution
Utiliser le pattern takeUntilDestroyed() ou async pipe.

\`\`\`typescript
// ❌ CAUSAIT LE BUG
export class DashboardComponent implements OnInit {
  data: any;

  ngOnInit() {
    this.http.get('/api/data').subscribe(d => this.data = d);
    // ← Jamais unsubscribe!
  }
}

// ✅ SOLUTION 1: takeUntilDestroyed (Angular 16+)
export class DashboardComponent {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.http.get('/api/data')
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(d => this.data = d);
  }
}

// ✅ SOLUTION 2: async pipe (préféré)
@Component({
  template: `@if (data$ | async; as data) { ... }`
})
export class DashboardComponent {
  data$ = this.http.get('/api/data');
}
\`\`\`

### Règle de Prévention
- Préférer async pipe pour les Observables dans les templates
- Si subscription manuelle, utiliser takeUntilDestroyed()
- JAMAIS de .subscribe() nu sans cleanup
```

---

## Commandes Sentinel

```bash
# Documenter une erreur manuellement
/harmony --mode sentinel --learn

# Voir les erreurs Angular
/harmony --mode sentinel --report --tags angular

# Sync vers ce dossier
/harmony --mode sentinel --sync-profile angular
```

---

*Ce dossier se remplit automatiquement. Ne modifiez pas manuellement.*
