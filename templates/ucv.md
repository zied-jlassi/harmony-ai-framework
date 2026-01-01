# STORY-{story_id}-UCV: Use Case Verifications

> **{story_title}**

---

## Metadata

| Field | Value |
|-------|-------|
| **Story ID** | STORY-{story_id} |
| **UCV Status** | {ucv_status} |
| **Created** | {created_date} |
| **Approved** | {approved_date} |
| **Approved By** | {approved_by} |

---

## Summary

| Metric | Value |
|--------|-------|
| **Total Use Cases** | {total_use_cases} |
| **Total Verifications** | {total_verifications} |
| **Coverage Target** | 100% |
| **Current Coverage** | {current_coverage}% |

---

## Verification Matrix

| Verification | Dev | Test | QA | Complete |
|--------------|:---:|:----:|:--:|:--------:|
| V-001-1 | {v001_1_dev} | {v001_1_test} | {v001_1_qa} | {v001_1_complete} |
| V-001-2 | {v001_2_dev} | {v001_2_test} | {v001_2_qa} | {v001_2_complete} |
| V-002-1 | {v002_1_dev} | {v002_1_test} | {v002_1_qa} | {v002_1_complete} |

---

## Use Cases

### UC-001: {use_case_1_title}

**Gherkin Scenario:**

```gherkin
Feature: {feature_name}

  Scenario: {scenario_1_name}
    Given {given_1}
    And {given_2}
    When {when_1}
    Then {then_1}
    And {then_2}
```

**Verifications:**

| ID | Description | Dev | Test | QA |
|----|-------------|:---:|:----:|:--:|
| V-001-1 | {verification_1_1_desc} | [ ] | [ ] | [ ] |
| V-001-2 | {verification_1_2_desc} | [ ] | [ ] | [ ] |
| V-001-3 | {verification_1_3_desc} | [ ] | [ ] | [ ] |

---

### UC-002: {use_case_2_title}

**Gherkin Scenario:**

```gherkin
Feature: {feature_name}

  Scenario: {scenario_2_name}
    Given {given_1}
    When {when_1}
    Then {then_1}
```

**Verifications:**

| ID | Description | Dev | Test | QA |
|----|-------------|:---:|:----:|:--:|
| V-002-1 | {verification_2_1_desc} | [ ] | [ ] | [ ] |
| V-002-2 | {verification_2_2_desc} | [ ] | [ ] | [ ] |

---

### UC-003: {use_case_3_title} (Error Handling)

**Gherkin Scenario:**

```gherkin
Feature: {feature_name}

  Scenario: {error_scenario_name}
    Given {given_1}
    When {when_error}
    Then {then_error_message}
    And {then_error_state}
```

**Verifications:**

| ID | Description | Dev | Test | QA |
|----|-------------|:---:|:----:|:--:|
| V-003-1 | {verification_3_1_desc} | [ ] | [ ] | [ ] |
| V-003-2 | {verification_3_2_desc} | [ ] | [ ] | [ ] |

---

## Edge Cases

| ID | Edge Case | Expected Behavior | Verified |
|----|-----------|-------------------|:--------:|
| EC-001 | {edge_case_1} | {expected_1} | [ ] |
| EC-002 | {edge_case_2} | {expected_2} | [ ] |

---

## Non-Functional Requirements

| ID | Requirement | Criteria | Verified |
|----|-------------|----------|:--------:|
| NFR-001 | Performance | {perf_criteria} | [ ] |
| NFR-002 | Accessibility | {a11y_criteria} | [ ] |
| NFR-003 | Security | {security_criteria} | [ ] |

---

## Approval

### Status: {ucv_status}

| Reviewer | Role | Status | Date |
|----------|------|--------|------|
| {reviewer_1} | {reviewer_1_role} | {reviewer_1_status} | {reviewer_1_date} |
| {reviewer_2} | {reviewer_2_role} | {reviewer_2_status} | {reviewer_2_date} |

### Approval Comments

{approval_comments}

---

## Coverage Report

### By Validator

| Validator | Completed | Total | Coverage |
|-----------|-----------|-------|----------|
| Dev | {dev_completed} | {total_verifications} | {dev_coverage}% |
| Test | {test_completed} | {total_verifications} | {test_coverage}% |
| QA | {qa_completed} | {total_verifications} | {qa_coverage}% |

### Missing Verifications

{missing_verifications}

---

## History

| Date | Action | By |
|------|--------|-----|
| {created_date} | Created | Clara |
| {approved_date} | Approved | {approved_by} |
| {updated_date} | {last_action} | {updated_by} |

---

## Related

- Story: [STORY-{story_id}](./STORY-{story_id}.md)
- Epic: [EPIC-{epic_id}](../epics/EPIC-{epic_id}.md)

