# /harmony coverage

Generate UCV coverage report for an Epic or the entire project.

## Usage

```bash
/harmony coverage                      # Full project coverage
/harmony coverage EP-001               # Coverage for specific epic
/harmony coverage EP-001 --by-story    # Breakdown by story
/harmony coverage --trend              # Coverage trend over time
```

## Description

Analyzes UCV validation status across the project and generates coverage metrics.

## Coverage Calculation

```
Coverage = (Validated UCVs / Total UCVs) × 100

UCV Validated = DEV ☑ (33%) + TEST ☑ (66%) + QA ☑ (100%)

Story Coverage = Moyenne de tous les UCVs inline (V1, V2, V3...)
Epic Coverage = Moyenne de toutes les Stories
Project Coverage = Moyenne de tous les Epics
```

### Parsing UCVs inline

```
1. SCAN stories: EP-{id}/stories/US-*.md
2. FOR each story:
   - Extract section <!-- UCV_SECTION_START --> to <!-- UCV_SECTION_END -->
   - FOR each <!-- UCV_Vn_START --> ... <!-- UCV_Vn_END -->:
     - Parse validation table: DEV ☑/☐, TEST ☑/☐, QA ☑/☐
     - Calculate: (DEV + TEST + QA) / 3 = UCV coverage
3. Aggregate by story, epic, project
```

## Validation Levels

| Level | Symbol | Weight | Description |
|-------|--------|--------|-------------|
| DEV | ☑ DEV | 33% | Developer self-validation |
| TEST | ☑ TEST | 33% | Tester validation |
| QA | ☑ QA | 34% | QA final validation |

## Output Example

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                        HARMONY COVERAGE REPORT                               ║
║                        Project: reservation-hotels                           ║
║                        Date: 2026-01-04                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

📊 PROJECT SUMMARY
─────────────────────────────────────────────────────────────────────────────
Total Epics:     2          Total Stories:   8          Total UCVs:    45
Coverage:        78%        Validated:       35/45      Pending:       10

📈 COVERAGE BY EPIC
─────────────────────────────────────────────────────────────────────────────
EP-001: Hotel Reservation MVP
[████████████████████░░░░] 85% (34/40 UCVs)
├── US-001-001: Hotel Search API     [████████████████████] 100% ✓
├── US-001-002: Room Availability    [████████████████░░░░] 80%
├── US-001-003: Booking Flow         [████████████████████] 100% ✓
└── US-001-004: Payment Integration  [████████░░░░░░░░░░░░] 40%

EP-002: User Management
[████████░░░░░░░░░░░░░░░░] 35% (1/5 UCVs)
└── US-002-001: User Registration    [████████░░░░░░░░░░░░] 35%

📋 VALIDATION STATUS
─────────────────────────────────────────────────────────────────────────────
[DEV]  ████████████████████████ 42/45 (93%)
[TEST] ████████████████░░░░░░░░ 35/45 (78%)
[QA]   ████████████░░░░░░░░░░░░ 28/45 (62%)

⚠️  PENDING VALIDATION (10 UCVs)
─────────────────────────────────────────────────────────────────────────────
• UCV-002-001 (US-001-002) - Awaiting TEST validation
• UCV-002-002 (US-001-002) - Awaiting TEST, QA validation
• UCV-004-001 (US-001-004) - Awaiting DEV, TEST, QA validation
...

🎯 RECOMMENDATIONS
─────────────────────────────────────────────────────────────────────────────
1. PRIORITY: Complete US-001-004 Payment Integration (40% coverage)
2. ACTION: 10 UCVs pending TEST validation - assign to Tester agent
3. BLOCKER: US-002-001 blocked by missing API dependency
```

## Options

| Option | Description |
|--------|-------------|
| `--by-story` | Show breakdown by story |
| `--by-layer` | Show breakdown by layer [FE/BE/DB] |
| `--trend` | Show coverage trend over time |
| `--threshold` | Fail if below threshold (e.g., --threshold 80) |
| `--export` | Export to file (json, csv, md) |
| `--ci` | CI mode: exit code 1 if below threshold |

## CI/CD Integration

```yaml
# .github/workflows/quality.yml
- name: Check UCV Coverage
  run: |
    /harmony coverage --threshold 80 --ci
    # Fails pipeline if coverage < 80%
```

## Trend Tracking

Coverage history stored in:
`.harmony/local/metrics/coverage-history.json`

```json
{
  "history": [
    {"date": "2026-01-01", "coverage": 45, "validated": 20, "total": 45},
    {"date": "2026-01-02", "coverage": 62, "validated": 28, "total": 45},
    {"date": "2026-01-04", "coverage": 78, "validated": 35, "total": 45}
  ]
}
```

## Related Commands

- `/harmony test-book EP-001` - Generate full test book
- `/harmony matrix EP-001` - Traceability matrix
- `/harmony ucv --status` - UCV status details
