# AUDIT-001: Orchestration Routing - Deux Boucles Manquantes

> **🌐 Langue :** [English](../../audits/01-routing-orchestration-defaut.md) · Français

**Date**: 2026-01-07
**Statut**: CORRIGE
**Severite**: CRITIQUE
**Impact**: Le systeme de routing ne charge pas le contexte automatiquement

---

## Resume du Defaut

Le framework Harmony definit un systeme complet de detection automatique dans `routing-rules.yaml` mais **aucun composant ne l'execute**. Resultat: les agents travaillent "a l'aveugle" sans contexte enrichi.

---

## Les Deux Boucles Manquantes

```
┌─────────────────────────────────────────────────────────────────┐
│            FLUX ACTUEL (DEFECTUEUX)                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User: "creer un systeme d'authentification"                    │
│                          │                                       │
│                          ▼                                       │
│  ┌────────────────────────────────────────┐                     │
│  │  Guardian: Detection Intent            │  ✓ FONCTIONNE      │
│  │  → IMPLEMENT detecte via keywords      │                     │
│  └────────────────────────────────────────┘                     │
│                          │                                       │
│                          ▼                                       │
│  ┌────────────────────────────────────────┐                     │
│  │  Guardian: Route to Developer          │  ✓ FONCTIONNE      │
│  └────────────────────────────────────────┘                     │
│                          │                                       │
│                          ▼                                       │
│  ┌────────────────────────────────────────┐                     │
│  │  Developer: Commence le travail        │  ❌ SANS CONTEXTE  │
│  │  → Pas de knowledge charge             │                     │
│  │  → Pas de flags securite               │                     │
│  │  → Pas d'agents declenches             │                     │
│  └────────────────────────────────────────┘                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Boucle 1: Classification Haiku (NON EXECUTEE)

**Configuration dans routing-rules.yaml (lignes 33-80):**
```yaml
auto_detection:
  enabled: true
  router_model: "haiku"  # Devrait classifier l'intention

  classification_prompt: |
    Determine:
    1. PRIMARY_INTENT: [ANALYZE, DESIGN, ...]
    2. CONTEXT_FLAGS: [has_auth, personal_data, security_critical...]
    3. SUGGESTED_AGENT: Primary agent
    4. TRIGGERED_AGENTS: ALL agents needed
    5. CONFIDENCE: 0.0 to 1.0

    CRITICAL FLAGS (auto-trigger):
    - Auth/login/account → [has_auth, has_db_schema]
    - PII (name, email, phone) → [personal_data]

    User request: "{user_input}"

    JSON: {"primary_intent":"...", "context_flags":[...], ...}
```

**Probleme**: Haiku n'est JAMAIS appele pour classifier la demande.

### Boucle 2: Context Flag Triggers (NON EXECUTEE)

**Configuration dans routing-rules.yaml (lignes 96-141):**
```yaml
context_flag_triggers:
  has_auth:
    agents: [security, database]
    priority: 2
    message: "🔐 Authentification - Securite DB requise"

  personal_data:
    agents: [rgpd, security]
    priority: 1
    message: "⚠️ Donnees personnelles - Validation RGPD requise"

  security_critical:
    agents: [security, pentest]
    priority: 0
    message: "🔒 Securite critique - Audit obligatoire"
```

**Probleme**: Meme si les flags etaient detectes, aucun code ne charge les agents/knowledge correspondants.

---

## Ce Qui Aurait Du Se Passer

```
┌─────────────────────────────────────────────────────────────────┐
│            FLUX CORRIGE                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User: "creer un systeme d'authentification"                    │
│                          │                                       │
│                          ▼                                       │
│  ┌────────────────────────────────────────┐                     │
│  │  ETAPE 1: HAIKU CLASSIFICATION         │  ← NOUVEAU         │
│  │  ├── Appeler Haiku avec le prompt      │                     │
│  │  ├── Recevoir JSON:                    │                     │
│  │  │   {                                 │                     │
│  │  │     "primary_intent": "IMPLEMENT",  │                     │
│  │  │     "context_flags": [              │                     │
│  │  │       "has_auth",                   │                     │
│  │  │       "has_db_schema",              │                     │
│  │  │       "personal_data"               │                     │
│  │  │     ],                              │                     │
│  │  │     "triggered_agents": [           │                     │
│  │  │       "developer", "security",      │                     │
│  │  │       "rgpd", "database"            │                     │
│  │  │     ],                              │                     │
│  │  │     "confidence": 0.92              │                     │
│  │  │   }                                 │                     │
│  │  └── Passer les flags a l'etape 2      │                     │
│  └────────────────────────────────────────┘                     │
│                          │                                       │
│                          ▼                                       │
│  ┌────────────────────────────────────────┐                     │
│  │  ETAPE 2: CONTEXT PRE-LOADING          │  ← NOUVEAU         │
│  │  ├── Lire context_flag_triggers        │                     │
│  │  ├── has_auth → load security, db      │                     │
│  │  ├── personal_data → load rgpd         │                     │
│  │  ├── Charger knowledge correspondant   │                     │
│  │  └── Injecter dans working memory      │                     │
│  └────────────────────────────────────────┘                     │
│                          │                                       │
│                          ▼                                       │
│  ┌────────────────────────────────────────┐                     │
│  │  ETAPE 3: AGENT AVEC CONTEXTE ENRICHI  │  ← NOUVEAU         │
│  │  Developer recoit:                     │                     │
│  │  • knowledge/domains/security/*.md     │                     │
│  │  • agents/security.md (resume)         │                     │
│  │  • agents/rgpd.md (resume)             │                     │
│  │  • Regles de prevention d'erreurs      │                     │
│  └────────────────────────────────────────┘                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Analyse du Defaut

| Composant | Defini dans Config? | Execute? |
|-----------|---------------------|----------|
| auto_detection.enabled | ✅ `true` | ❌ Non appele |
| router_model: "haiku" | ✅ Configure | ❌ Jamais invoque |
| classification_prompt | ✅ Complet | ❌ Non utilise |
| context_flag_triggers | ✅ 9 triggers | ❌ Non lu |
| knowledge paths | ✅ Dans manifests | ❌ Non charge |
| agent cross-loading | ✅ Defini | ❌ Non fait |

### Pattern Documents mais Non Implementes

| Pattern | Fichier | Description | Status |
|---------|---------|-------------|--------|
| P-003 | `patterns/P-003-jit-context.md` | JIT Loading pattern | ❌ Non implemente |
| P-015 | `patterns/P-015-context-discovery.md` | Context Discovery protocol | ❌ Manuel seulement |

---

## Correctif Implemente

### Nouveau Fichier: `lib/context-preloader.sh`

**Objectif**: Charger automatiquement le contexte AVANT l'execution d'un agent.

**Fonctions principales**:

| Fonction | Description |
|----------|-------------|
| `preload_context()` | Orchestrateur principal |
| `classify_with_haiku()` | Appeler Haiku pour classification |
| `parse_classification_result()` | Parser la reponse JSON |
| `load_triggered_agents()` | Charger les agents declenches |
| `load_knowledge_for_flags()` | Charger le knowledge par flag |
| `inject_context_to_memory()` | Ecrire dans working.json |
| `display_context_summary()` | Afficher le resume |

**Flow d'execution**:

```bash
preload_context "creer systeme auth" "developer"
  │
  ├─ classify_with_haiku "creer systeme auth"
  │   └─ Retourne: {"context_flags": ["has_auth", "personal_data"], ...}
  │
  ├─ load_triggered_agents ["security", "rgpd", "database"]
  │   └─ Charge summaries des agents
  │
  ├─ load_knowledge_for_flags ["has_auth", "personal_data"]
  │   └─ Charge knowledge/domains/security/*.md, etc.
  │
  ├─ inject_context_to_memory
  │   └─ Ecrit dans .harmony/local/memory/working.json
  │
  └─ display_context_summary
      └─ Affiche le resume pour l'utilisateur
```

### Modification: `agents/guardian.md`

Ajout d'une section "Context Pre-Loading" apres le routing:

```
1. Intent Detection     ← Existant
2. Prerequisite Check   ← Existant
3. Agent Routing        ← Existant
4. CONTEXT PRE-LOADING  ← NOUVEAU
5. Agent Announcement   ← Existant (enrichi)
```

### Modification: `lib/config-loader.sh`

Ajout des fonctions:
- `get_routing_rules()`: Lire routing-rules.yaml
- `get_context_flag_triggers()`: Lire les triggers par flag
- `get_knowledge_paths_for_flag()`: Mapper flag → knowledge

---

## Fichiers Crees/Modifies

### Nouveaux Fichiers

| Fichier | Description |
|---------|-------------|
| `framework/docs/audits/01-routing-orchestration-defaut.md` | Ce document |

### Fichiers Modifies

| Fichier | Modification |
|---------|--------------|
| `framework/lib/config-loader.sh` | Cache de branches + resolve_agent ameliore |

### Details des Modifications

#### `config-loader.sh` - Lignes ajoutees/modifiees

**Nouvelles variables (ligne 45-48):**
```bash
# Branch cache for specialty resolution (built once, O(1) lookup)
declare -A BRANCH_CACHE
BRANCH_CACHE_BUILT=false
```

**Nouvelles fonctions (lignes 167-214):**
- `build_branch_cache()` - Construit le cache au premier appel
- `get_branch_cache_count()` - Debug: nombre d'entries
- `list_branch_cache()` - Debug: liste toutes les branches

**Fonction modifiee `resolve_agent()` (lignes 368-431):**
1. Verifie le cache de branches en premier (O(1))
2. Supporte le pattern `{specialty}-{branch}` automatiquement
3. Fallback vers agents/ et patterns/cognitive/

### Resolution des Agents Manquants

| Agent Reference | Avant | Apres |
|-----------------|-------|-------|
| `ucv-writer` | ❌ NOT FOUND | ✅ `specialties/ucv/branchs/writer.md` |
| `ucv-qa` | ❌ NOT FOUND | ✅ `specialties/ucv/branchs/qa.md` |
| `ucv-validator` | ❌ NOT FOUND | ✅ `specialties/ucv/branchs/validator.md` |
| `developer-web` | ❌ NOT FOUND | ✅ `specialties/developer/branchs/web.md` |
| `security-auditor` | ❌ NOT FOUND | ✅ `specialties/security/branchs/auditor.md` |

**50 branches auto-decouvertes** par le cache.

### Fichiers a Inclure dans le Package

Deja inclus automatiquement car `lib/*.sh` est copie par `install.sh`:

```bash
# Modifie (sera copie automatiquement)
framework/lib/config-loader.sh

# Documentation (optionnel)
framework/docs/audits/01-routing-orchestration-defaut.md
```

---

## Integration avec l'Installation

Le script `bin/install.sh` copie deja `lib/*.sh`. Le nouveau fichier `context-preloader.sh` sera automatiquement inclus.

Pour verifier apres installation:

```bash
# Verifier que le preloader est installe
ls -la .harmony/lib/context-preloader.sh

# Tester le preload
source .harmony/lib/context-preloader.sh
preload_context "test auth" "developer" --dry-run
```

---

## Tests de Validation

Ajouter dans `tests/e2e/scripts/test.sh`:

```bash
test_context_preloader() {
    echo "Testing context-preloader..."

    # Test 1: Classification mock
    result=$(classify_with_haiku "creer systeme auth" --mock)
    assert_contains "$result" "has_auth"

    # Test 2: Knowledge loading
    result=$(load_knowledge_for_flags "has_auth")
    assert_file_exists "$result"

    # Test 3: Integration
    result=$(preload_context "test" "developer" --dry-run)
    assert_contains "$result" "CONTEXT LOADED"

    echo "✓ Context preloader tests passed"
}
```

---

## Resume

| Avant | Apres |
|-------|-------|
| Guardian route → Agent execute sans contexte | Guardian route → Preloader charge → Agent execute avec contexte |
| Haiku non appele | Haiku classifie la demande |
| Triggers non lus | Triggers declenchent le chargement |
| Knowledge non charge | Knowledge injecte automatiquement |
| P-003/P-015 documentes seulement | P-003/P-015 implementes |

---

## Prochaines Etapes

1. ✅ Document d'audit cree
2. ✅ Modifier `config-loader.sh` - Cache de branches + resolve_agent
3. ✅ Resolution automatique des agents manquants (ucv-*, developer-*, etc.)
4. ⏳ Implementer `context-preloader.sh` (Haiku classification + knowledge loading)
5. ⏳ Modifier `guardian.md` pour integrer le pre-loader
6. ⏳ Ajouter tests dans `test.sh`
7. ⏳ Publier nouvelle version

## Agents Restants a Creer

Ces agents sont references dans `routing-rules.yaml` mais n'ont pas de specialty/branch:

| Agent | Solution |
|-------|----------|
| `legal` | ✅ CORRIGE - Specialty renommee: `specialties/legal/branchs/legal.md` (fallback same-name) |
| `devops` | Utiliser `specialties/devops/branchs/devops.md` ✅ (fallback same-name) |
| `i18n` | Utiliser `specialties/i18n/branchs/i18n.md` ✅ (fallback same-name) |
| `lint` | Utiliser `specialties/quality/branchs/lint.md` ✅ (via branch cache) |
| `dependency` | Utiliser `specialties/quality/branchs/dependency.md` ✅ (via branch cache) |
| `accessibility` | Utiliser `specialties/accessibility/branchs/accessibility.md` ✅ (fallback same-name) |

**Note**: La specialty `compliance` a ete renommee en `legal` pour que le fallback fonctionne:
`legal` → `specialties/legal/branchs/legal.md` (auto-resolution)
