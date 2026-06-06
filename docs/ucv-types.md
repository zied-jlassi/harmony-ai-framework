# UCV Types - Guide de Classification

> **"Chaque type de vérification a un rôle précis dans la qualité."**

---

## Vue d'ensemble

Les UCVs (Use Case Verifiables) sont classifiés en **3 types** pour garantir une couverture complète :

| Type | Code | Description | Priorité typique |
|------|------|-------------|------------------|
| **Fonctionnel** | `F` | Happy path, comportement nominal | P0 - Critique |
| **Edge Case** | `E` | Cas limites, erreurs, exceptions | P1 - Important |
| **Non-fonctionnel** | `N` | Performance, sécurité, accessibilité | P1/P2 |

---

## Type 1 : Fonctionnel (F)

### Définition

Vérifie que la fonctionnalité **fonctionne comme attendu** dans des conditions normales.

### Caractéristiques

- ✅ Happy path (chemin nominal)
- ✅ Données valides
- ✅ Utilisateur autorisé
- ✅ Système en état normal

### Exemples

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

### Couverture minimale

| Story Type | UCVs Fonctionnels requis |
|------------|--------------------------|
| Simple (1-3 pts) | 1-2 |
| Moyenne (5 pts) | 2-3 |
| Complexe (8+ pts) | 3-5 |

---

## Type 2 : Edge Case (E)

### Définition

Vérifie le comportement aux **limites** et lors de **conditions anormales**.

### Caractéristiques

- ⚠️ Données invalides ou manquantes
- ⚠️ Cas limites (min, max, vide, null)
- ⚠️ Erreurs utilisateur
- ⚠️ États inattendus

### Exemples

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

### Cas typiques à couvrir

| Catégorie | Exemples |
|-----------|----------|
| **Validation** | Email invalide, champ vide, format incorrect |
| **Limites** | Min/max, 0, négatif, overflow |
| **Permissions** | Non autorisé, session expirée |
| **Réseau** | Timeout, erreur serveur, offline |
| **Concurrence** | Double clic, soumission multiple |

---

## Type 3 : Non-fonctionnel (N)

### Définition

Vérifie les **qualités système** : performance, sécurité, accessibilité, UX.

### Sous-catégories

| Sous-type | Code | Focus |
|-----------|------|-------|
| Performance | `N-PERF` | Temps réponse, charge |
| Sécurité | `N-SEC` | OWASP, injections, XSS |
| Accessibilité | `N-A11Y` | WCAG 2.1 AA |
| UX | `N-UX` | Responsive, feedback |

### Exemples

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

### Critères mesurables

| Catégorie | Métrique | Cible typique |
|-----------|----------|---------------|
| **Performance** | Temps réponse API | < 200ms |
| **Performance** | LCP (Largest Contentful Paint) | < 2.5s |
| **Sécurité** | Vulnérabilités OWASP | 0 critique |
| **Accessibilité** | Score Lighthouse | > 90 |
| **Accessibilité** | Violations axe-core | 0 |

---

## Nomenclature

### Format identifiant

```
V{numéro}: {titre}
```

- **V1, V2, V3...** : Numérotation séquentielle
- Le **Type** est indiqué dans les métadonnées, pas dans l'identifiant

### Dans la table résumé

```markdown
| UCV | Titre | Type | DEV | TEST | QA | Status |
|-----|-------|------|:---:|:----:|:--:|--------|
| **V1** | Connexion réussie | Fonctionnel | ☐ | ☐ | ☐ | 0% |
| **V2** | Email invalide | Edge Case | ☐ | ☐ | ☐ | 0% |
| **V3** | Temps réponse < 200ms | Non-fonctionnel | ☐ | ☐ | ☐ | 0% |
```

### Dans le détail UCV

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

## Couverture recommandée

### Par story

| Points | Fonctionnel | Edge Case | Non-fonct. | Total |
|--------|-------------|-----------|------------|-------|
| 1-2 | 1 | 1 | 0-1 | 2-3 |
| 3-5 | 2 | 2 | 1 | 5 |
| 8+ | 3+ | 3+ | 2+ | 8+ |

### Règle générale

```
Fonctionnel ≥ 40%
Edge Case ≥ 30%
Non-fonctionnel ≥ 20%
```

---

## Priorités

| Priorité | Quand l'utiliser | Conséquence si échec |
|----------|------------------|----------------------|
| **P0 - Critique** | Bloque l'usage principal | Story non livrable |
| **P1 - Important** | Impacte l'expérience | Bug à corriger |
| **P2 - Mineur** | Amélioration | Peut être différé |

### Mapping type → priorité (par défaut)

| Type | Priorité par défaut |
|------|---------------------|
| Fonctionnel (happy path) | P0 |
| Edge Case (erreur critique) | P0/P1 |
| Edge Case (erreur mineure) | P1/P2 |
| Non-fonctionnel (sécurité) | P0 |
| Non-fonctionnel (perf) | P1 |
| Non-fonctionnel (a11y) | P1/P2 |

---

## Workflow de création

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

## Exemples complets

### Story: "Formulaire de contact"

| UCV | Titre | Type | Priorité |
|-----|-------|------|----------|
| V1 | Envoi message réussi | Fonctionnel | P0 |
| V2 | Confirmation email reçu | Fonctionnel | P0 |
| V3 | Email invalide rejeté | Edge Case | P1 |
| V4 | Champs requis validés | Edge Case | P1 |
| V5 | Protection spam (captcha) | Non-fonct. (Sec) | P1 |
| V6 | Accessible clavier | Non-fonct. (A11Y) | P1 |

### Story: "API REST /users"

| UCV | Titre | Type | Priorité |
|-----|-------|------|----------|
| V1 | GET /users retourne liste | Fonctionnel | P0 |
| V2 | POST /users crée utilisateur | Fonctionnel | P0 |
| V3 | 404 si utilisateur inexistant | Edge Case | P1 |
| V4 | 401 si non authentifié | Edge Case | P0 |
| V5 | Injection SQL bloquée | Non-fonct. (Sec) | P0 |
| V6 | Réponse < 200ms | Non-fonct. (Perf) | P1 |

---

## Références

- [HQVF Overview](./commands.md#qualite-hqvf-26-27)
- [Story Template](../templates/story.md)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)

---

*Documentation Harmony Framework v2.0 - UCV Types*
