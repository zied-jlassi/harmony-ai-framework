# /harmony matrix

Generate intelligent Cahier de Charge (Specification Document) with full traceability.

## Usage

```bash
/harmony matrix EP-001                                    # Single epic
/harmony matrix --chain EP-001,EP-004,EP-002,EP-015       # Custom order
/harmony matrix --all --flow deps                         # All epics, auto-order by dependencies
/harmony matrix --chain EP-001,EP-002 --export spec.pdf   # Export PDF
```

## Intelligent Features

| Feature | Description |
|---------|-------------|
| **Auto-Index** | Generates table of contents with page numbers and metrics |
| **Flow Detection** | Analyzes `blocked_by`, `requires` to build dependency graph |
| **Smart Transitions** | Creates narrative links between chapters |
| **Gap Analysis** | Detects missing UCVs, orphan tasks, broken links |
| **Coverage Calc** | Per-chapter and global coverage metrics |
| **Risk Alerts** | Highlights blockers, low coverage, pending validations |
| **Recommendations** | Prioritization suggestions based on dependencies |

## Document Structure

```
CAHIER DE CHARGE
├── Page 1: INDEX GÉNÉRAL
│   ├── Table des matières
│   ├── Flux fonctionnel (diagramme)
│   ├── Métriques globales
│   └── Alertes et recommandations
│
├── CHAPITRE 1: {Epic 1}
│   ├── Description & Contexte
│   ├── Prérequis (dépendances entrantes)
│   ├── Matrice Stories → Tasks → UCVs
│   ├── Couverture du chapitre
│   └── Transition vers chapitre suivant
│
├── CHAPITRE 2: {Epic 2}
│   └── ...
│
├── CHAPITRE N: {Epic N}
│   └── ...
│
└── ANNEXES
    ├── A. Glossaire
    ├── B. Analyse des Gaps
    ├── C. Historique des versions
    └── D. Références documentaires
```

## Ordering Modes

| Mode | Command | Logic |
|------|---------|-------|
| **Manual** | `--chain EP-001,EP-004,EP-002` | Your specified order |
| **Dependencies** | `--flow deps` | Topological sort by `blocked_by` |
| **Sprint** | `--flow sprint` | Sprint 1 → 2 → 3 |
| **Priority** | `--flow priority` | HIGH → MEDIUM → LOW |
| **Functional** | `--flow user-journey` | Follows user flow from brief |

## Intelligence Examples

### Auto-detected Dependencies
```
EP-001 (Auth) ─────────┬──────▶ EP-004 (Profile)
                       │
                       └──────▶ EP-002 (Booking) ──────▶ EP-015 (Payment)

Detected from:
- EP-004.md: "blocked_by: EP-001"
- EP-002.md: "requires: [EP-001]"
- EP-015.md: "blocked_by: EP-002"
```

### Smart Recommendations
```
📊 RECOMMANDATIONS INTELLIGENTES
─────────────────────────────────────────────────────────────────────────────
1. PRIORITÉ CRITIQUE: EP-001 doit être terminé en premier (3 epics en dépendent)
2. RISQUE: EP-002 a 40% de couverture UCV - augmenter avant release
3. OPTIMISATION: EP-004 et EP-003 peuvent être développés en parallèle
4. ALERTE: 5 UCVs sans validation QA depuis 7 jours
```

### Gap Detection
```
🔍 GAPS DÉTECTÉS
─────────────────────────────────────────────────────────────────────────────
CRITIQUES (bloquent la release):
• US-001-003 n'a aucun UCV défini
• TS-002-004 référence une story inexistante (US-001-099)

WARNINGS (dette technique):
• UCV-003-002 pas lié à une task spécifique
• EP-002 n'a pas de brief référencé
```

## Export Formats

| Format | Command | Use Case |
|--------|---------|----------|
| Markdown | `--export spec.md` | Git-friendly, review |
| PDF | `--export spec.pdf` | Client delivery |
| HTML | `--export spec.html` | Web publishing |
| Word | `--export spec.docx` | Editable by non-tech |
| Excel | `--export matrix.xlsx` | Matrix-only, filtering |

## CI/CD Integration

```yaml
# .github/workflows/docs.yml
generate-spec:
  runs-on: ubuntu-latest
  steps:
    - name: Generate Cahier de Charge
      run: /harmony matrix --all --flow deps --export cahier-de-charge.pdf

    - name: Check for Gaps
      run: /harmony matrix --gaps --ci --threshold critical
      # Fails if critical gaps found

    - name: Upload Artifact
      uses: actions/upload-artifact@v3
      with:
        name: specification
        path: cahier-de-charge.pdf
```

## Options Reference

| Option | Description |
|--------|-------------|
| `--chain` | Comma-separated epic order |
| `--all` | Include all epics |
| `--flow` | Auto-order mode: deps, sprint, priority, user-journey |
| `--export` | Output file path (.md, .pdf, .html, .docx, .xlsx) |
| `--gaps` | Show gap analysis only |
| `--impact` | Impact analysis for specific item |
| `--ci` | CI mode with exit codes |
| `--threshold` | Gap severity: critical, warning, all |
| `--lang` | Output language: fr, en |
| `--template` | Custom template path |

## Templates

Custom templates in `.harmony/templates/matrix/`:
- `index.md` - Index page template
- `chapter.md` - Chapter template
- `annexes.md` - Annexes template

## Related Commands

- `/harmony test-book` - Detailed test scenarios
- `/harmony coverage` - Coverage metrics
- `/harmony validate` - Validate artifacts
- `/harmony sync` - Sync with external tools
