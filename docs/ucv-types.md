# UCV Types - Classification Guide

> **🌐 Language:** English · [Français](fr/ucv-types.md)

> **"Each verification type plays a precise role in quality."**

---

## Overview

UCVs (Use Case Verifiables) are classified into **3 types** to guarantee complete coverage:

| Type | Code | Description | Typical priority |
|------|------|-------------|------------------|
| **Functional** | `F` | Happy path, nominal behavior | P0 - Critical |
| **Edge Case** | `E` | Boundary cases, errors, exceptions | P1 - Important |
| **Non-functional** | `N` | Performance, security, accessibility | P1/P2 |

---

## Type 1: Functional (F)

### Definition

Verifies that the feature **works as expected** under normal conditions.

### Characteristics

- ✅ Happy path (nominal flow)
- ✅ Valid data
- ✅ Authorized user
- ✅ System in normal state

### Examples

```gherkin
# V1: Connexion réussie (Fonctionnel)
Given un utilisateur avec email "user@test.com" et mot de passe valide
When il soumet le formulaire de connexion
Then il est redirigé vers le dashboard
And un message "Bienvenue" s'affiche
```

```gherkin
# V2: Création produit (Fonctionnel)
Given un admin connecté sur la page produits
When il remplit le formulaire avec des données valides
And il clique sur "Créer"
Then le produit apparaît dans la liste
And un toast "Produit créé" s'affiche
```

### Minimum coverage

| Story Type | Required Functional UCVs |
|------------|--------------------------|
| Simple (1-3 pts) | 1-2 |
| Medium (5 pts) | 2-3 |
| Complex (8+ pts) | 3-5 |

---

## Type 2: Edge Case (E)

### Definition

Verifies behavior at **boundaries** and under **abnormal conditions**.

### Characteristics

- ⚠️ Invalid or missing data
- ⚠️ Boundary cases (min, max, empty, null)
- ⚠️ User errors
- ⚠️ Unexpected states

### Examples

```gherkin
# V3: Email invalide (Edge Case)
Given un utilisateur sur la page connexion
When il entre "not-an-email" dans le champ email
And il soumet le formulaire
Then un message d'erreur "Email invalide" s'affiche
And le formulaire n'est pas soumis
```

```gherkin
# V4: Champ vide (Edge Case)
Given un utilisateur sur la page création produit
When il laisse le champ "nom" vide
And il clique sur "Créer"
Then le champ "nom" est marqué en erreur
And le message "Nom requis" s'affiche
```

```gherkin
# V5: Valeur limite (Edge Case)
Given un produit avec stock = 0
When un client tente d'ajouter au panier
Then le bouton "Ajouter" est désactivé
And le message "Rupture de stock" s'affiche
```

### Typical cases to cover

| Category | Examples |
|-----------|----------|
| **Validation** | Invalid email, empty field, incorrect format |
| **Boundaries** | Min/max, 0, negative, overflow |
| **Permissions** | Unauthorized, expired session |
| **Network** | Timeout, server error, offline |
| **Concurrency** | Double click, multiple submission |

---

## Type 3: Non-functional (N)

### Definition

Verifies **system qualities**: performance, security, accessibility, UX.

### Sub-categories

| Sub-type | Code | Focus |
|-----------|------|-------|
| Performance | `N-PERF` | Response time, load |
| Security | `N-SEC` | OWASP, injections, XSS |
| Accessibility | `N-A11Y` | WCAG 2.1 AA |
| UX | `N-UX` | Responsive, feedback |

### Examples

```gherkin
# V6: Performance API (Non-fonctionnel)
Given l'API /products
When 100 requêtes simultanées sont envoyées
Then 95% des réponses < 200ms
And aucune erreur 5xx
```

```gherkin
# V7: Sécurité XSS (Non-fonctionnel)
Given un champ de commentaire
When l'utilisateur entre "<script>alert('xss')</script>"
Then le script est échappé dans le rendu
And aucun JavaScript n'est exécuté
```

```gherkin
# V8: Accessibilité (Non-fonctionnel)
Given la page de connexion
When analysée avec axe-core
Then aucune violation WCAG 2.1 AA
And tous les champs ont des labels
And le contraste est >= 4.5:1
```

### Measurable criteria

| Category | Metric | Typical target |
|-----------|----------|---------------|
| **Performance** | API response time | < 200ms |
| **Performance** | LCP (Largest Contentful Paint) | < 2.5s |
| **Security** | OWASP vulnerabilities | 0 critical |
| **Accessibility** | Lighthouse score | > 90 |
| **Accessibility** | axe-core violations | 0 |

---

## Nomenclature

### Identifier format

```
V{numéro}: {titre}
```

- **V1, V2, V3...** : Sequential numbering
- The **Type** is indicated in the metadata, not in the identifier

### In the summary table

```markdown
| UCV | Titre | Type | DEV | TEST | QA | Status |
|-----|-------|------|:---:|:----:|:--:|--------|
| **V1** | Connexion réussie | Fonctionnel | ☐ | ☐ | ☐ | 0% |
| **V2** | Email invalide | Edge Case | ☐ | ☐ | ☐ | 0% |
| **V3** | Temps réponse < 200ms | Non-fonctionnel | ☐ | ☐ | ☐ | 0% |
```

### In the UCV detail

```markdown
<!-- UCV_V1_START -->
### V1: Connexion réussie

| Champ | Valeur |
|-------|--------|
| **Type** | Fonctionnel |
| **Priorité** | P0 - Critique |
| **Tasks liées** | T1, T2 |
...
<!-- UCV_V1_END -->
```

---

## Recommended coverage

### Per story

| Points | Functional | Edge Case | Non-func. | Total |
|--------|-------------|-----------|------------|-------|
| 1-2 | 1 | 1 | 0-1 | 2-3 |
| 3-5 | 2 | 2 | 1 | 5 |
| 8+ | 3+ | 3+ | 2+ | 8+ |

### General rule

```
Fonctionnel ≥ 40%
Edge Case ≥ 30%
Non-fonctionnel ≥ 20%
```

---

## Priorities

| Priority | When to use it | Consequence if failed |
|----------|------------------|----------------------|
| **P0 - Critical** | Blocks the main usage | Story not deliverable |
| **P1 - Important** | Impacts the experience | Bug to fix |
| **P2 - Minor** | Improvement | Can be deferred |

### Type → priority mapping (default)

| Type | Default priority |
|------|---------------------|
| Functional (happy path) | P0 |
| Edge Case (critical error) | P0/P1 |
| Edge Case (minor error) | P1/P2 |
| Non-functional (security) | P0 |
| Non-functional (perf) | P1 |
| Non-functional (a11y) | P1/P2 |

---

## Creation workflow

```
1. Story reçue
       ↓
2. Identifier Use Cases principaux → UCVs Fonctionnels
       ↓
3. Identifier cas d'erreur → UCVs Edge Case
       ↓
4. Vérifier exigences NFR → UCVs Non-fonctionnels
       ↓
5. Assigner priorités (P0/P1/P2)
       ↓
6. Validation triple (DEV → TEST → QA)
```

---

## Complete examples

### Story: "Contact form"

| UCV | Title | Type | Priority |
|-----|-------|------|----------|
| V1 | Message sent successfully | Functional | P0 |
| V2 | Confirmation email received | Functional | P0 |
| V3 | Invalid email rejected | Edge Case | P1 |
| V4 | Required fields validated | Edge Case | P1 |
| V5 | Spam protection (captcha) | Non-func. (Sec) | P1 |
| V6 | Keyboard accessible | Non-func. (A11Y) | P1 |

### Story: "REST API /users"

| UCV | Title | Type | Priority |
|-----|-------|------|----------|
| V1 | GET /users returns list | Functional | P0 |
| V2 | POST /users creates user | Functional | P0 |
| V3 | 404 if user does not exist | Edge Case | P1 |
| V4 | 401 if not authenticated | Edge Case | P0 |
| V5 | SQL injection blocked | Non-func. (Sec) | P0 |
| V6 | Response < 200ms | Non-func. (Perf) | P1 |

---

## References

- [HQVF Overview](./commands.md#qualite-hqvf-26-27)
- [Story Template](../templates/story.md)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)

---

*Harmony Framework Documentation v2.0 - UCV Types*
