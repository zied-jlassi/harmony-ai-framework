# Test Charter - {zone_or_feature}

> **Exploratory Testing Session**

---

## Mission

| EXPLORE | {specific_zone} |
|---------|-----------------|
| **WITH** | {tools_and_resources} |
| **TO DISCOVER** | {target_issues} |

---

## Metadata

| Field | Value |
|-------|-------|
| **Charter ID** | CHARTER-{id} |
| **Date** | {date} |
| **Tester** | Exploratory QA |
| **Duration** | 60-90 min (max 2h) |
| **Priority** | P0 / P1 / P2 |
| **Story Reference** | STORY-{story_id} |

---

## Scope

### In Scope

- [ ] {feature_1}
- [ ] {feature_2}
- [ ] {feature_3}

### Out of Scope

- {excluded_1}
- {excluded_2}

---

## Personas to Simulate

| Persona | Description | Focus |
|---------|-------------|-------|
| **Hacker Dave** | Security-minded user | SQL injection, XSS, IDOR |
| **Senior Adam** | Reduced vision, motor issues | Accessibility, contrast, focus |
| **Mobile Marie** | Smartphone on slow 4G | Responsive, touch, performance |
| **Impatient Igor** | Rapid double-clicks | Race conditions, loading states |
| **Distracted Daniel** | Frequent interruptions | State preservation, auto-save |
| **Beginner Betty** | First-time user | Onboarding, help, clarity |
| **Power User Paul** | Keyboard shortcuts expert | Shortcuts, efficiency, bulk ops |

---

## Test Heuristics

### CRUD Operations

- [ ] **Create** - Add new item
- [ ] **Read** - Display details correctly
- [ ] **Update** - Modify existing item
- [ ] **Delete** - Remove with confirmation

### Boundary Values

- [ ] `0` (zero/empty)
- [ ] `1` (minimum)
- [ ] `Max` (upper limit)
- [ ] `Max + 1` (overflow)

### Special Characters

- [ ] Emoji input
- [ ] SQL injection (`'; DROP TABLE--`)
- [ ] XSS (`<script>alert('xss')</script>`)
- [ ] Unicode / RTL characters
- [ ] Very long strings (10000+ chars)

### Navigation

- [ ] Browser back button
- [ ] Page refresh (F5)
- [ ] Direct deep links
- [ ] Breadcrumb consistency

### States

- [ ] Loading state
- [ ] Error state
- [ ] Empty state
- [ ] Success state
- [ ] Partial data state

### Accessibility

- [ ] Keyboard navigation (Tab, Enter, Escape)
- [ ] Focus visible indicators
- [ ] Screen reader compatibility
- [ ] Color contrast (4.5:1 minimum)
- [ ] Alt text for images

---

## Session Notes

{notes_during_exploration}

---

## Bugs Found

| ID | Severity | Description | Steps to Reproduce | Screenshot |
|----|----------|-------------|-------------------|------------|
| BUG-001 | {severity} | {description} | 1. ... 2. ... | {link} |

### Severity Scale

| Level | Description |
|-------|-------------|
| **Critical** | App crash, data loss, security breach |
| **High** | Feature broken, no workaround |
| **Medium** | Feature impaired, workaround exists |
| **Low** | Minor inconvenience, cosmetic |

---

## Observations

### Positive Points

- {what_works_well}

### Attention Points

- {potential_issues}

### UX Suggestions

- {improvement_ideas}

---

## Coverage Summary

| Area | Tested | Notes |
|------|:------:|-------|
| Happy Path | [ ] | {notes} |
| Error Handling | [ ] | {notes} |
| Edge Cases | [ ] | {notes} |
| Accessibility | [ ] | {notes} |
| Performance | [ ] | {notes} |
| Security | [ ] | {notes} |

---

## Go/No-Go Decision

- [ ] **GO** - Ready for release
- [ ] **GO with reservations** - Minor bugs acceptable
- [ ] **NO-GO** - Critical blocking bugs

### Justification

{decision_justification}

---

## Time Tracking

| Activity | Duration |
|----------|----------|
| Preparation | {x} min |
| Exploration | {y} min |
| Documentation | {z} min |
| **Total** | **{total}** min |

---

## Related

- Story: [STORY-{story_id}](../stories/STORY-{story_id}.md)
- UCV: [STORY-{story_id}-UCV](../stories/STORY-{story_id}-UCV.md)
- Exploratory QA Agent: [Exploratory QA 🔍](../agents/exploratory-qa.md)
