# US-{epic_id}-{story_id}: [{LAYER}] {title}

> **{summary}**
>
> **Layer**: `[FE]` Frontend | `[BE]` Backend | `[DB]` Database | `[FS]` Fullstack | `[DO]` DevOps | `[TEST]` Tests
> **Status**: 🔴 TODO | 🟡 IN_PROGRESS | 🟢 DONE | ⚫ BLOCKED

---

## Metadata

| Field | Value |
|-------|-------|
| **Story ID** | US-{epic_id}-{story_id} |
| **Layer** | {LAYER} - [FE] \| [BE] \| [DB] \| [FS] \| [DO] \| [TEST] |
| **Epic** | [EP-{epic_id}](../EP-{epic_id}.md) |
| **Status** | 🔴 TODO |
| **Priority** | HIGH \| MEDIUM \| LOW |
| **Points** | {story_points} (Fibonacci: 1,2,3,5,8,13) |
| **Sprint** | Sprint {N} |
| **Assigned** | {agent_name} |
| **Created** | {YYYY-MM-DD} |

---

## Related Documentation

| Type | File | Status |
|------|------|--------|
| Epic | [EP-{epic_id}](../EP-{epic_id}.md) | ✅ |
| Brief | [brief.md](../../docs/briefs/{brief_file}.md) | ✅ |
| ADR | [ADR-XXX.md](../../docs/architecture/ADR-{XXX}.md) | Optional |
| Figma | [{figma_link}]({figma_url}) | Optional |

---

## User Story

As a **{role}**,
I want to **{action}**,
So that **{benefit}**.

---

## Acceptance Criteria (Gherkin)

### AC-1: {criterion_title}

```gherkin
Given {precondition}
When {action}
Then {expected_result}
```

### AC-2: {criterion_title}

```gherkin
Given {precondition}
When {action}
Then {expected_result}
```

### AC-3: {criterion_title}

```gherkin
Given {precondition}
When {action}
Then {expected_result}
```

---

## INVEST Validation

| Criterion | Status | Notes |
|-----------|--------|-------|
| **I**ndependent | ✅ | Can be developed alone |
| **N**egotiable | ✅ | Details can be discussed |
| **V**aluable | ✅ | Delivers user value |
| **E**stimable | ✅ | Team can estimate |
| **S**mall | ✅ | ≤ 8 points, < 3 days |
| **T**estable | ✅ | Clear acceptance criteria |

---

## Tasks (Inline)

> **Notation**: T1, T2, T3... | **Status**: 🔴 TODO | 🟡 IN_PROGRESS | 🟢 DONE | ⚫ BLOCKED

| Task | Description | Layer | Status | Files |
|------|-------------|-------|--------|-------|
| **T1** | {task_1_desc} | [{layer}] | 🔴 | `src/...` |
| **T2** | {task_2_desc} | [{layer}] | 🔴 | `src/...` |
| **T3** | {task_3_desc} | [{layer}] | 🔴 | `src/...` |

**Total Estimate**: {total_hours}h

### T1: {task_1_title}

**Description**: {task_1_detailed_description}

**Files to modify**:
- `src/modules/{module}/controllers/{file}.controller.ts`
- `src/modules/{module}/services/{file}.service.ts`

**UCV Mapping**: V1, V2

---

### T2: {task_2_title}

**Description**: {task_2_detailed_description}

**Files to modify**:
- `src/modules/{module}/services/{file}.service.ts`

**Dependencies**: T1 doit être complété

---

### T3: {task_3_title}

**Description**: {task_3_detailed_description}

**Files to modify**:
- `src/components/{Component}.tsx`
- `src/hooks/use{Hook}.ts`

**Dependencies**: T1, T2 doivent être complétés

---

<!-- UCV_SECTION_START -->
## UCVs (Use Case Verifiables)

> **Validation Triple**: DEV ✓ (33%) → TEST ✓ (66%) → QA ✓ (100%)
> **Notation**: V1, V2, V3... | ☐ = non validé | ☑ = validé

### Résumé Couverture

| UCV | Titre | Type | DEV | TEST | QA | Status |
|-----|-------|------|:---:|:----:|:--:|--------|
| **V1** | {ucv_1_title} | Fonctionnel | ☐ | ☐ | ☐ | 0% |
| **V2** | {ucv_2_title} | Edge Case | ☐ | ☐ | ☐ | 0% |
| **V3** | {ucv_3_title} | Non-fonctionnel | ☐ | ☐ | ☐ | 0% |

**Couverture Story**: 0% (0/3 UCVs validés)

---

<!-- UCV_V1_START -->
### V1: {ucv_1_title}

| Champ | Valeur |
|-------|--------|
| **Type** | Fonctionnel |
| **Priorité** | P0 - Critique |
| **Tasks liées** | T1, T2 |

**Préconditions**:
- {precondition_1}
- {precondition_2}

**Scénario Gherkin**:
```gherkin
Feature: {feature_name}

  Scenario: {scenario_name}
    Given {given_1}
    And {given_2}
    When {when_1}
    Then {then_1}
    And {then_2}
```

**Étapes manuelles**:
1. {step_1}
2. {step_2}
3. {step_3}

**Résultat attendu**:
- {expected_result}

**Données de test**:
```json
{
  "input": "{test_input}",
  "expected": "{expected_output}"
}
```

**Validation**:
| Niveau | Validateur | Date | Status | Commentaire |
|--------|------------|------|:------:|-------------|
| DEV | - | - | ☐ | - |
| TEST | - | - | ☐ | - |
| QA | - | - | ☐ | - |

<!-- UCV_V1_END -->

---

<!-- UCV_V2_START -->
### V2: {ucv_2_title}

| Champ | Valeur |
|-------|--------|
| **Type** | Edge Case |
| **Priorité** | P1 - Important |
| **Tasks liées** | T2 |

**Préconditions**:
- {precondition_1}

**Scénario Gherkin**:
```gherkin
Feature: {feature_name}

  Scenario: {edge_case_scenario}
    Given {given_edge}
    When {when_edge}
    Then {then_edge_error}
```

**Résultat attendu**:
- {expected_error_handling}

**Validation**:
| Niveau | Validateur | Date | Status | Commentaire |
|--------|------------|------|:------:|-------------|
| DEV | - | - | ☐ | - |
| TEST | - | - | ☐ | - |
| QA | - | - | ☐ | - |

<!-- UCV_V2_END -->

---

<!-- UCV_V3_START -->
### V3: {ucv_3_title} (Non-Fonctionnel)

| Champ | Valeur |
|-------|--------|
| **Type** | Non-fonctionnel |
| **Catégorie** | Performance \| Sécurité \| Accessibilité |
| **Priorité** | P1 - Important |

**Critères**:
| Critère | Cible | Actuel | Status |
|---------|-------|--------|:------:|
| Temps réponse | < 200ms | - | ☐ |
| Accessibilité | WCAG 2.1 AA | - | ☐ |

**Validation**:
| Niveau | Validateur | Date | Status | Commentaire |
|--------|------------|------|:------:|-------------|
| DEV | - | - | ☐ | - |
| TEST | - | - | ☐ | - |
| QA | - | - | ☐ | - |

<!-- UCV_V3_END -->
<!-- UCV_SECTION_END -->

---

## Technical Notes

### Architecture Decisions

{architecture_notes}

### Security Considerations

- [ ] Input validation
- [ ] Authentication required
- [ ] Authorization checks
- [ ] Data sanitization

### Performance Requirements

- API response time: < 200ms
- No N+1 queries

---

## Dependencies

### Blocked By

- [ ] US-{prev} - {description}

### Blocks

- [ ] US-{next} - {description}

---

## Definition of Done

- [ ] Tous les tasks complétés (T1 → Tn) 🟢
- [ ] Tous les critères d'acceptation validés
- [ ] UCVs 100% validés (DEV ✓ + TEST ✓ + QA ✓)
- [ ] Tests unitaires écrits (>80% coverage)
- [ ] Tests E2E passent
- [ ] Code review approuvée
- [ ] Pas de vulnérabilités sécurité
- [ ] Documentation mise à jour

---

## Workflow de Validation

> **Auto-triggered** quand status → 🟢 DONE

```
Story → DONE
    ↓
┌───────────────────────────────────────────────────────┐
│ STEP 1: ucv-qa                                        │
│ ├── Parse: <!-- UCV_SECTION_START/END -->             │
│ ├── Pour chaque V1, V2, V3...:                        │
│ │   └── Valider niveau QA (☐ → ☑)                     │
│ └── Update: table validation dans story               │
└───────────────────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────────────────┐
│ STEP 2: ucv-validator                                 │
│ ├── Check: DEV ☑ + TEST ☑ + QA ☑ = 100%               │
│ ├── Si < 100%: BLOQUER story                          │
│ └── Si = 100%: VALIDER story DONE                     │
└───────────────────────────────────────────────────────┘
    ↓
Story DONE ✅ (100% validated)
```

**Agents de validation**:
| Agent | Rôle | Trigger |
|-------|------|---------|
| `ucv-qa` | Valide QA pour UCVs inline | Story → DONE |
| `ucv-validator` | Vérifie coverage 100% | Après ucv-qa |

---

## History

| Date | Action | Par | Status |
|------|--------|-----|--------|
| {YYYY-MM-DD} | Créée | SM Agent | 🔴 TODO |
| {YYYY-MM-DD} | Tasks définis | SM Agent | 🔴 TODO |
| {YYYY-MM-DD} | UCVs générés | UCV Writer | 🔴 TODO |
| {YYYY-MM-DD} | Implémentation | Developer | 🟡 IN_PROGRESS |
| {YYYY-MM-DD} | Validation DEV | Developer | 🟡 IN_PROGRESS |
| {YYYY-MM-DD} | Validation TEST | Tester | 🟡 IN_PROGRESS |
| {YYYY-MM-DD} | Validation QA | QA | 🟢 DONE |

---

## Related

- Epic: [EP-{epic_id}](../EP-{epic_id}.md)
- ADR: [ADR-{XXX}](../../docs/architecture/ADR-{XXX}.md)

---

*Template: Harmony Framework v2.0 - Story avec Tasks et UCVs inline*
*Marqueurs UCV: `<!-- UCV_SECTION_START -->` ... `<!-- UCV_Vn_START/END -->`*
