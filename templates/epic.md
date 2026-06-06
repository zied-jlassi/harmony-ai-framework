# EP-{epic_id}: {title}

> **{summary}**
>
> **Status**: 🔴 TODO | 🟡 IN_PROGRESS | 🟢 DONE | ⚫ BLOCKED

---

## Metadata

| Field | Value |
|-------|-------|
| **Epic ID** | EP-{epic_id} |
| **Status** | 🔴 TODO |
| **Priority** | HIGH \| MEDIUM \| LOW |
| **Theme** | TH-{theme_id} (optionnel) |
| **Owner** | {owner} |
| **Created** | {YYYY-MM-DD} |
| **Target Release** | {target_release} |
| **Stories** | 0/{expected_stories} |
| **UCV Coverage** | 0% |

---

## Related Documentation (REQUIRED)

| Type | File | Status |
|------|------|--------|
| **Brief** | [brief.md](../../docs/briefs/{brief_file}.md) | ✅ Required |
| PRD | [prd.md](../../docs/prd/{prd_file}.md) | Optional |
| Research | [research.md](../../docs/research/{research_file}.md) | Optional |
| Analysis | [analysis.md](../../docs/analysis/{analysis_file}.md) | Optional |
| Architecture | [ADR-XXX.md](../../docs/architecture/ADR-{XXX}.md) | Optional |

---

## Overview

### Problem Statement

{problem_statement}

### Proposed Solution

{proposed_solution}

### Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| {metric_1_name} | {metric_1_target} | - |
| {metric_2_name} | {metric_2_target} | - |

---

## Scope

### In Scope

- {in_scope_1}
- {in_scope_2}
- {in_scope_3}

### Out of Scope

- {out_scope_1}
- {out_scope_2}

---

## SPIDR Decomposition

> Epic decomposed using SPIDR framework (Spikes, Paths, Interfaces, Data, Rules)

### S - Spikes (Technical Unknowns)

| Spike ID | Question | Timebox | Output |
|----------|----------|---------|--------|
| SP-001 | {spike_question} | 4h | Decision Record |

### P - Paths (User Journeys)

| Path | Description | Priority | Story |
|------|-------------|----------|-------|
| Happy Path | {happy_path_desc} | P0 | US-001 |
| Alternative | {alt_path_desc} | P1 | US-002 |
| Edge Case | {edge_path_desc} | P2 | US-003 |

### I - Interfaces (Platforms)

| Interface | Specifics | Dedicated Story? |
|-----------|-----------|------------------|
| Web Desktop | Standard | No |
| Mobile (responsive) | Touch, viewport | No (same story) |
| API | External consumers | Yes → US-XXX |

### D - Data (Variations)

| Data Type | Complexity | Dedicated Story? |
|-----------|------------|------------------|
| Simple text | Low | No |
| Images/Media | Medium | Yes → US-XXX |
| Complex JSON | High | Yes → US-XXX |

### R - Rules (Business Logic)

| Rule | Complexity | Sprint |
|------|------------|--------|
| Basic validation | Low | Sprint 1 |
| Advanced logic | Medium | Sprint 1 |
| Edge cases | High | Sprint 2 |

---

## VOICES (Story Splitting)

> Si une story est trop grande (> 8 points), utiliser VOICES pour la découper

### V - Variations
| Variation | Complexité | Story séparée? |
|-----------|------------|----------------|
| Cas standard | Faible | Non (story principale) |
| {variation_1} | Moyenne | Oui → US-{epic_id}-{n} |

### O - Operations (CRUD)
| Opération | Incluse dans story? |
|-----------|---------------------|
| Create | ✅ |
| Read | ✅ |
| Update | Story séparée |
| Delete | Story séparée |

### I - Inputs
| Type input | Complexité | Story séparée? |
|------------|------------|----------------|
| Texte simple | Faible | Non |
| Upload fichier | Haute | Oui → US-{epic_id}-{n} |

### C - Complexity
| Règle métier | Complexité | Story séparée? |
|--------------|------------|----------------|
| Validation basique | Faible | Non |
| Règles complexes | Haute | Oui |

### E - Exceptions
| Exception | Critique? | Story séparée? |
|-----------|-----------|----------------|
| Erreur validation | Non | Non |
| Cas limite | Oui | Oui → US-{epic_id}-{n} |

### S - Scenarios
| Scénario | Couvert par | Priority |
|----------|-------------|----------|
| Happy path | US-{epic_id}-001 | P0 |
| Error path | US-{epic_id}-002 | P1 |
| Edge cases | US-{epic_id}-003 | P2 |

---

## Stories

| Story ID | Title | Points | Status | Priority | Sprint |
|----------|-------|--------|--------|----------|--------|
| US-001 | {story_1_title} | {pts} | TODO | HIGH | Sprint 1 |
| US-002 | {story_2_title} | {pts} | TODO | HIGH | Sprint 1 |
| US-003 | {story_3_title} | {pts} | TODO | MEDIUM | Sprint 2 |

**Total Points**: {total_points}

### Story-Task Summary

| Story | Tasks | Estimated | Files |
|-------|-------|-----------|-------|
| US-001 | 3 tasks | 8h | 5 files |
| US-002 | 4 tasks | 12h | 8 files |
| US-003 | 2 tasks | 4h | 3 files |

### Critical Path (Dependencies)

```
US-001 (Backend API) ──────────────────┐
    │                                  │
    └── US-002 (Frontend UI) ──────────┼── US-004 (Integration Tests)
            │                          │
            └── US-003 (Validation) ───┘
```

---

## Progress

### Overall Status

```
Progress: {X}%
[████████░░░░░░░░] {completed}/{total} stories
```

### Sprint Breakdown

| Sprint | Stories | Points | Completed | Status |
|--------|---------|--------|-----------|--------|
| Sprint 1 | US-001, US-002 | 13 | 0/2 | IN_PROGRESS |
| Sprint 2 | US-003, US-004 | 8 | 0/2 | TODO |

---

## Technical Considerations

### Architecture Impact

{architecture_impact}

### Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| {dep_name} | External API | Ready |
| {dep_name} | Internal Service | Pending |

### Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk_1} | Medium | High | {mitigation} |

---

## Acceptance Criteria (Epic Level)

1. [ ] All stories completed and verified
2. [ ] E2E tests passing
3. [ ] Performance targets met
4. [ ] Security review passed
5. [ ] Documentation updated

---

## History

| Date | Action | By |
|------|--------|-----|
| {YYYY-MM-DD} | Created | SM Agent |
| {YYYY-MM-DD} | Stories decomposed | SM Agent |

---

## Related

- Brief: [hotel-reservation-brief.md](../briefs/hotel-reservation-brief.md)
- PRD: [{prd_reference}](../prd/{prd_file})
- Architecture: [{arch_reference}](../architecture/{arch_file})

---

## File Structure

```
${HARMONY_DIR}/local/backlog/epics/
└── EP-{XXX}-{slug}/                    ← Epic folder (ID + slug)
    ├── EP-{XXX}-{slug}.md              ← This file
    └── stories/
        ├── US-{XXX}-001-{slug}.md      ← Story files (UCVs inline)
        ├── US-{XXX}-002-{slug}.md
        └── US-{XXX}-003-{slug}.md
```

### Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Epic folder | `EP-{NNN}-{slug}/` | `EP-001-core-architecture/` |
| Epic file | `EP-{NNN}-{slug}.md` | `EP-001-core-architecture.md` |
| Story file | `US-{NNN}-{XXX}-{slug}.md` | `US-001-001-setup-projet.md` |
