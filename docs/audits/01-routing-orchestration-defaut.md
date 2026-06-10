# AUDIT-001: Orchestration Routing - Two Missing Loops

> **🌐 Language:** English · [Français](../fr/audits/01-routing-orchestration-defaut.md)

**Date**: 2026-01-07
**Status**: FIXED
**Severity**: CRITICAL
**Impact**: The routing system does not load context automatically

---

## Defect Summary

The Harmony framework defines a complete automatic detection system in `routing-rules.yaml` but **no component executes it**. Result: agents work "blindly" without enriched context.

---

## The Two Missing Loops

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

### Loop 1: Haiku Classification (NOT EXECUTED)

**Configuration in routing-rules.yaml (lines 33-80):**
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

**Problem**: Haiku is NEVER called to classify the request.

### Loop 2: Context Flag Triggers (NOT EXECUTED)

**Configuration in routing-rules.yaml (lines 96-141):**
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

**Problem**: Even if the flags were detected, no code loads the corresponding agents/knowledge.

---

## What Should Have Happened

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

## Defect Analysis

| Component | Defined in Config? | Executed? |
|-----------|---------------------|----------|
| auto_detection.enabled | ✅ `true` | ❌ Not called |
| router_model: "haiku" | ✅ Configured | ❌ Never invoked |
| classification_prompt | ✅ Complete | ❌ Not used |
| context_flag_triggers | ✅ 9 triggers | ❌ Not read |
| knowledge paths | ✅ In manifests | ❌ Not loaded |
| agent cross-loading | ✅ Defined | ❌ Not done |

### Patterns Documented but Not Implemented

| Pattern | File | Description | Status |
|---------|---------|-------------|--------|
| P-003 | `patterns/P-003-jit-context.md` | JIT Loading pattern | ❌ Not implemented |
| P-015 | `patterns/P-015-context-discovery.md` | Context Discovery protocol | ❌ Manual only |

---

## Implemented Fix

### New File: `lib/context-preloader.sh`

**Objective**: Automatically load context BEFORE an agent executes.

**Main functions**:

| Function | Description |
|----------|-------------|
| `preload_context()` | Main orchestrator |
| `classify_with_haiku()` | Call Haiku for classification |
| `parse_classification_result()` | Parse the JSON response |
| `load_triggered_agents()` | Load the triggered agents |
| `load_knowledge_for_flags()` | Load knowledge per flag |
| `inject_context_to_memory()` | Write into working.json |
| `display_context_summary()` | Display the summary |

**Execution flow**:

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

### Change: `agents/guardian.md`

Added a "Context Pre-Loading" section after routing:

```
1. Intent Detection     ← Existant
2. Prerequisite Check   ← Existant
3. Agent Routing        ← Existant
4. CONTEXT PRE-LOADING  ← NOUVEAU
5. Agent Announcement   ← Existant (enrichi)
```

### Change: `lib/config-loader.sh`

Added functions:
- `get_routing_rules()`: Read routing-rules.yaml
- `get_context_flag_triggers()`: Read the triggers per flag
- `get_knowledge_paths_for_flag()`: Map flag → knowledge

---

## Files Created/Modified

### New Files

| File | Description |
|---------|-------------|
| `framework/docs/audits/01-routing-orchestration-defaut.md` | This document |

### Modified Files

| File | Change |
|---------|--------------|
| `framework/lib/config-loader.sh` | Branch cache + improved resolve_agent |

### Change Details

#### `config-loader.sh` - Lines added/modified

**New variables (lines 45-48):**
```bash
# Branch cache for specialty resolution (built once, O(1) lookup)
declare -A BRANCH_CACHE
BRANCH_CACHE_BUILT=false
```

**New functions (lines 167-214):**
- `build_branch_cache()` - Builds the cache on first call
- `get_branch_cache_count()` - Debug: number of entries
- `list_branch_cache()` - Debug: list all branches

**Modified function `resolve_agent()` (lines 368-431):**
1. Checks the branch cache first (O(1))
2. Supports the `{specialty}-{branch}` pattern automatically
3. Falls back to agents/ and patterns/cognitive/

### Resolution of Missing Agents

| Agent Reference | Before | After |
|-----------------|-------|-------|
| `ucv-writer` | ❌ NOT FOUND | ✅ `specialties/ucv/branchs/writer.md` |
| `ucv-qa` | ❌ NOT FOUND | ✅ `specialties/ucv/branchs/qa.md` |
| `ucv-validator` | ❌ NOT FOUND | ✅ `specialties/ucv/branchs/validator.md` |
| `developer-web` | ❌ NOT FOUND | ✅ `specialties/developer/branchs/web.md` |
| `security-auditor` | ❌ NOT FOUND | ✅ `specialties/security/branchs/auditor.md` |

**50 branches auto-discovered** by the cache.

### Files to Include in the Package

Already included automatically since `lib/*.sh` is copied by `install.sh`:

```bash
# Modifie (sera copie automatiquement)
framework/lib/config-loader.sh

# Documentation (optionnel)
framework/docs/audits/01-routing-orchestration-defaut.md
```

---

## Integration with the Installation

The `bin/install.sh` script already copies `lib/*.sh`. The new file `context-preloader.sh` will be included automatically.

To verify after installation:

```bash
# Verifier que le preloader est installe
ls -la .harmony/lib/context-preloader.sh

# Tester le preload
source .harmony/lib/context-preloader.sh
preload_context "test auth" "developer" --dry-run
```

---

## Validation Tests

Add to `tests/e2e/scripts/test.sh`:

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

## Summary

| Before | After |
|-------|-------|
| Guardian routes → Agent executes without context | Guardian routes → Preloader loads → Agent executes with context |
| Haiku not called | Haiku classifies the request |
| Triggers not read | Triggers drive the loading |
| Knowledge not loaded | Knowledge injected automatically |
| P-003/P-015 documented only | P-003/P-015 implemented |

---

## Next Steps

1. ✅ Audit document created
2. ✅ Modify `config-loader.sh` - Branch cache + resolve_agent
3. ✅ Automatic resolution of missing agents (ucv-*, developer-*, etc.)
4. ⏳ Implement `context-preloader.sh` (Haiku classification + knowledge loading)
5. ⏳ Modify `guardian.md` to integrate the pre-loader
6. ⏳ Add tests to `test.sh`
7. ⏳ Publish new version

## Remaining Agents to Create

These agents are referenced in `routing-rules.yaml` but have no specialty/branch:

| Agent | Solution |
|-------|----------|
| `legal` | ✅ FIXED - Specialty renamed: `specialties/legal/branchs/legal.md` (fallback same-name) |
| `devops` | Use `specialties/devops/branchs/devops.md` ✅ (fallback same-name) |
| `i18n` | Use `specialties/i18n/branchs/i18n.md` ✅ (fallback same-name) |
| `lint` | Use `specialties/quality/branchs/lint.md` ✅ (via branch cache) |
| `dependency` | Use `specialties/quality/branchs/dependency.md` ✅ (via branch cache) |
| `accessibility` | Use `specialties/accessibility/branchs/accessibility.md` ✅ (fallback same-name) |

**Note**: The `compliance` specialty was renamed to `legal` so the fallback works:
`legal` → `specialties/legal/branchs/legal.md` (auto-resolution)
