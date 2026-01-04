# /harmony test-book

Generate a complete test book (Cahier de Test) for one or multiple Epics.

## Usage

```bash
/harmony test-book EP-001                              # Single epic
/harmony test-book --chain EP-001,EP-004,EP-002        # Multiple epics (ordered)
/harmony test-book --all --flow deps                   # All epics by dependencies
/harmony test-book EP-001 --format pdf                 # Export as PDF
/harmony test-book --chain EP-001,EP-002 --export tests.pdf
```

## Description

Generates a comprehensive test book by aggregating all UCVs from Epic folder(s).
When multiple epics: **Page 1 = Index** with table of contents and global metrics.

## Algorithm

```
1. LOCATE Epic folder: .harmony/local/backlog/epics/EP-{epic_id}/
2. SCAN all Stories in: EP-{epic_id}/stories/US-*.md
3. FOR each Story:
   - Parse section <!-- UCV_SECTION_START --> to <!-- UCV_SECTION_END -->
   - FOR each UCV (V1, V2, V3...):
     - Extract via <!-- UCV_Vn_START --> to <!-- UCV_Vn_END -->
     - Parse Gherkin scenario
     - Parse validation table (DEV ☑/☐, TEST ☑/☐, QA ☑/☐)
   - Parse Tasks section (T1, T2, T3...)
4. AGGREGATE into test book structure
5. GENERATE output (Markdown/PDF/HTML)
```

### Parsing des UCVs inline

```regex
# Localiser section UCV dans la story
<!-- UCV_SECTION_START -->(.*?)<!-- UCV_SECTION_END -->

# Extraire chaque UCV
<!-- UCV_V(\d+)_START -->(.*?)<!-- UCV_V\1_END -->

# Parser status validation
\| (DEV|TEST|QA) \| ([^|]*) \| ([^|]*) \| (☐|☑) \|
```

## Output Structure

```markdown
# Cahier de Test - EP-{epic_id}: {epic_title}

## Informations Générales
| Champ | Valeur |
|-------|--------|
| Epic | EP-{epic_id} |
| Date génération | {date} |
| Stories | {count} |
| UCVs Total | {count} |
| Couverture | {X}% |

## Résumé par Story

| Story | Description | UCVs | DEV | TEST | QA | Status |
|-------|-------------|------|-----|------|-----|--------|
| US-001-001 | {desc} | 5 | 5/5 | 4/5 | 3/5 | 80% |
| US-001-002 | {desc} | 3 | 3/3 | 3/3 | 3/3 | 100% |

## Détail des Tests

### US-001-001: {story_title}

#### UCV-001-001: {ucv_title}
- **Préconditions**: {preconditions}
- **Étapes**:
  1. {step_1}
  2. {step_2}
- **Résultat attendu**: {expected}
- **Validation**:
  - [x] DEV - {dev_name} - {date}
  - [x] TEST - {test_name} - {date}
  - [ ] QA - En attente

#### UCV-001-002: {ucv_title}
...

## Annexes
- Tasks associées
- Liens vers documentation
- Historique des modifications
```

## Traceability

The test book maintains full traceability:

```
V1 (inline) → US-001-001 → EP-001
     ↓
T1, T2, T3 (inline tasks)
```

### Nouvelle structure simplifiée

```
EP-001/
├── EP-001.md                (Epic avec SPIDR)
└── stories/
    └── US-001-001.md        (Story avec Tasks T1,T2 et UCVs V1,V2 inline)
        ├── ## Tasks (Inline)
        │   └── T1, T2, T3...
        └── ## UCVs (Use Case Verifiables)
            ├── <!-- UCV_SECTION_START -->
            ├── ### V1: {title}
            ├── ### V2: {title}
            └── <!-- UCV_SECTION_END -->
```

## Options

| Option | Description |
|--------|-------------|
| `--format` | Output format: md (default), pdf, html, xlsx |
| `--status` | Filter by status: all, pending, passed, failed |
| `--story` | Filter specific story: US-001-001 |
| `--output` | Output file path |
| `--include-tasks` | Include task details in output |

## Examples

```bash
# Generate full test book
/harmony test-book EP-001

# Generate PDF for client
/harmony test-book EP-001 --format pdf --output ./exports/

# Only pending tests
/harmony test-book EP-001 --status pending

# Specific story
/harmony test-book EP-001 --story US-001-002
```

## Integration

This command integrates with:
- `/harmony coverage` - Coverage report
- `/harmony matrix` - Traceability matrix
- `/harmony ucv --validate` - UCV validation

## File Dependencies

Reads from:
- `.harmony/local/backlog/epics/EP-{id}/EP-{id}.md`
- `.harmony/local/backlog/epics/EP-{id}/stories/US-*.md`
  - Section: `<!-- UCV_SECTION_START -->` to `<!-- UCV_SECTION_END -->`
  - Each UCV: `<!-- UCV_Vn_START -->` to `<!-- UCV_Vn_END -->`

Outputs to:
- `.harmony/local/reports/test-book-EP-{id}-{date}.md`
- `.harmony/local/reports/test-book-EP-{id}-{date}.pdf` (si --format pdf)
