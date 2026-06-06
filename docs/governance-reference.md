# Governance Modules Reference

> 15 concepts de gouvernance avancée pour agents IA enterprise-grade.
> Version 1.1.0 | Harmony Framework

---

## Vue d'Ensemble

L'architecture de gouvernance est organisée en 4 couches:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     GOVERNANCE LAYER                                 │
│  ┌──────────────┐  ┌───────────────────┐                            │
│  │ Audit Trail  │  │ Compliance Reporter│                           │
│  │  (Traçabilité)│  │  (Conformité)      │                           │
│  └──────────────┘  └───────────────────┘                            │
├─────────────────────────────────────────────────────────────────────┤
│                     INTELLIGENCE LAYER                               │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐              │
│  │ Confidence    │  │ Agent Maturity │  │ A/B Testing │             │
│  │ Scorer        │  │ (L1-L4)       │  │ (Expériences)│             │
│  └───────────────┘  └───────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────────┤
│                     CONTEXT LAYER                                    │
│  ┌───────────────┐  ┌───────────────┐                               │
│  │ Context Filter│  │ Mesh Network  │                               │
│  │ (FILCO)       │  │ (Peer-to-Peer)│                               │
│  └───────────────┘  └───────────────┘                               │
├─────────────────────────────────────────────────────────────────────┤
│                     SAFETY LAYER                                     │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────┐          │
│  │ Data Sandbox  │  │ Security Gates│  │ Anomaly Detector│          │
│  │ (Isolation)   │  │ (Permissions) │  │ (Détection)     │          │
│  └───────────────┘  └───────────────┘  └─────────────────┘          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Governance Layer

### Audit Trail (`lib/audit-trail.sh`)

Piste d'audit complète avec support rollback.

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `audit_start_session` | Démarre une session d'audit |
| `audit_record_decision` | Enregistre une décision avec métadonnées |
| `audit_record_file_change` | Capture les changements de fichiers |
| `audit_create_checkpoint` | Crée un point de sauvegarde |
| `audit_rollback_to` | Restaure à un checkpoint |
| `audit_export` | Exporte l'historique (JSON/CSV) |

**Usage:**

```bash
source .harmony/lib/audit-trail.sh

# Démarrer une session
session_id=$(audit_start_session "feature-login")

# Enregistrer une décision
entry_id=$(audit_record_decision "developer" "create" "auth.ts" "Implementing OAuth")

# Créer un checkpoint
checkpoint=$(audit_create_checkpoint "manual" "Before refactoring")

# Rollback si nécessaire
audit_rollback_to "$checkpoint" --force
```

**Configuration:** `.harmony/local/audit-config.json`

---

### Compliance Reporter (`lib/compliance-reporter.sh`)

Génération de preuves de conformité pour audits.

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `compliance_add_check` | Ajoute un résultat de vérification |
| `compliance_generate_report` | Génère un rapport complet |
| `compliance_get_status` | Obtient le score de conformité |
| `compliance_export_markdown` | Exporte en Markdown |
| `compliance_run_standard_checks` | Exécute les vérifications standard |

**Standards supportés:**

- OWASP Top 10
- Code Coverage (seuils configurables)
- Security Gates
- Documentation

**Usage:**

```bash
source .harmony/lib/compliance-reporter.sh

compliance_add_check "security" "OWASP-1" "passed" "Injection: No vulnerabilities"
compliance_add_check "quality" "Coverage" "passed" "Coverage: 87%"

compliance_generate_report "release-1.0"
```

---

## Intelligence Layer

### Confidence Scorer (`lib/confidence-scorer.sh`)

Quantification de l'incertitude avec escalation automatique.

**Niveaux de confiance:**

| Score | Niveau | Action |
|-------|--------|--------|
| 85-100 | CONFIDENT | Exécution autonome |
| 60-84 | UNCERTAIN | Demande de validation optionnelle |
| 40-59 | LOW | Escalation recommandée |
| 0-39 | VERY_LOW | Human-in-the-loop requis |

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `confidence_calculate` | Calcule le score (0-100) |
| `confidence_get_level` | Retourne le niveau textuel |
| `confidence_needs_review` | Détermine si review nécessaire |
| `confidence_escalate` | Escalade à un humain |
| `confidence_calibrate` | Calibre sur feedback |

**Usage:**

```bash
source .harmony/lib/confidence-scorer.sh

score=$(confidence_calculate "$context" "$decision")
level=$(confidence_get_level "$score")

if confidence_needs_review "$score"; then
    confidence_escalate "$decision_id" "Complex authentication logic"
fi
```

**Configuration:** `.harmony/local/confidence-config.json`

---

### Agent Maturity (`lib/agent-maturity.sh`)

Modèle de maturité à 4 niveaux pour les agents.

**Niveaux:**

| Niveau | Nom | Capacités |
|--------|-----|-----------|
| L1 | BASIC | Exécution de tâches, instructions |
| L2 | COORDINATED | Collaboration multi-agent, handoff |
| L3 | AUTONOMOUS | Auto-correction, récupération d'erreurs |
| L4 | SELF_OPTIMIZING | Meta-learning, amélioration continue |

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `maturity_get_level` | Obtient le niveau actuel |
| `maturity_record_capability` | Enregistre une capacité démontrée |
| `maturity_can_perform` | Vérifie si l'agent peut faire X |
| `maturity_assess` | Évalue le niveau global |
| `maturity_promote` | Promeut au niveau supérieur |

**Usage:**

```bash
source .harmony/lib/agent-maturity.sh

level=$(maturity_get_level "developer")
# → L2_COORDINATED

maturity_record_capability "developer" "self_correction"
maturity_assess "developer"
# → L3_AUTONOMOUS (si critères remplis)
```

---

### A/B Testing (`lib/ab-testing.sh`)

Expérimentation structurée pour configurations d'agents.

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `ab_create_experiment` | Crée une expérience |
| `ab_add_variant` | Ajoute une variante |
| `ab_select_variant` | Sélectionne une variante (weighted random) |
| `ab_record_result` | Enregistre un résultat |
| `ab_get_winner` | Détermine le gagnant statistique |

**Usage:**

```bash
source .harmony/lib/ab-testing.sh

exp_id=$(ab_create_experiment "prompt-style" "Test formal vs casual" 50)

ab_add_variant "formal" '{"style":"formal","tone":"professional"}' "prompt-style"
ab_add_variant "casual" '{"style":"casual","tone":"friendly"}' "prompt-style"

variant=$(ab_select_variant "prompt-style")
# → "formal" ou "casual"

ab_record_result "$variant" 85 "prompt-style"
```

---

## Context Layer

### Context Filter - FILCO (`lib/context-filter.sh`)

Filtrage intelligent du contexte pour réduire le bruit.

**Algorithme:**

1. **CHUNK**: Découpe en unités sémantiques (~500 chars)
2. **SCORE**: Score combiné (keyword 60% + structural 40%)
3. **RANK**: Tri par score décroissant
4. **SELECT**: Sélection dans le budget tokens

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `filco_filter` | Filtre le contexte selon une requête |
| `filco_score_chunk` | Score un chunk (0-100) |
| `filco_compact` | Compacte dans un budget tokens |
| `filco_rank_chunks` | Retourne les chunks triés |

**Usage:**

```bash
source .harmony/lib/context-filter.sh

# Filtrer le contexte pour une tâche
filtered=$(filco_filter "$large_context" "implement user authentication")

# Compacter dans un budget
compacted=$(filco_compact "$context" 5000)  # max 5000 tokens
```

**Impact:**

| Métrique | Avant FILCO | Après FILCO |
|----------|-------------|-------------|
| Taille contexte | 15,000 tokens | 5,000 tokens |
| Précision réponse | 75% | 85% |
| Coût tokens | $0.15/req | $0.05/req |

**Pattern associé:** [P-024-context-filtering](../patterns/P-024-context-filtering.md)

---

### Mesh Network (`lib/mesh-network.sh`)

Réseaux maillés pour collaboration peer-to-peer entre agents.

**Types de mesh:**

| Type | Coordinator | Agents | Usage |
|------|-------------|--------|-------|
| Feature | architect | developer, tester, reviewer | Développement feature |
| Quality | qa-lead | tester, security, perf | Validation qualité |
| Incident | commander | developer, devops, analyst | Résolution incident |

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `mesh_create` | Crée un réseau |
| `mesh_join` | Rejoint un réseau |
| `mesh_send` | Envoie un message P2P |
| `mesh_handoff` | Transfert de responsabilité |
| `mesh_escalate` | Escalade au coordinateur |
| `mesh_status` | Affiche le statut |

**Usage:**

```bash
source .harmony/lib/mesh-network.sh

mesh_id=$(mesh_create "login-feature" "architect" "developer" "tester")

# Communication P2P
mesh_send "tester" "Code ready for testing"

# Handoff
mesh_handoff "developer" "tester" "All unit tests pass"

# Escalation
mesh_escalate "Blocked: Need architecture decision"
```

**Pattern associé:** [P-023-mesh-networks](../patterns/P-023-mesh-networks.md)

---

## Safety Layer

### Data Sandbox (`lib/data-sandbox.sh`)

Isolation des données non fiables.

**Types de menaces détectées:**

| Type | Patterns | Exemples |
|------|----------|----------|
| Prompt Injection | `ignore previous`, `disregard`, `new instructions` | Attaques LLM |
| Code Injection | `$()`, backticks, `eval` | Shell injection |
| Path Traversal | `../`, `..\\` | Accès fichiers |
| SQL Injection | `'; DROP`, `UNION SELECT` | DB attacks |
| XSS | `<script>`, `onerror=` | Web attacks |

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `sandbox_validate` | Valide une entrée |
| `sandbox_is_suspicious` | Détecte si suspect |
| `sandbox_detect_injection` | Identifie le type d'injection |
| `sandbox_quarantine` | Met en quarantaine |
| `sandbox_sanitize` | Nettoie l'entrée |

**Usage:**

```bash
source .harmony/lib/data-sandbox.sh

if sandbox_is_suspicious "$user_input"; then
    injection_type=$(sandbox_detect_injection "$user_input")
    sandbox_quarantine "$user_input" "Detected: $injection_type"
else
    clean_input=$(sandbox_sanitize "$user_input")
fi
```

**Configuration:** `.harmony/local/sandbox-config.json`

---

### Security Gates (`lib/security-gates.sh`)

Portes de sécurité pour contrôle d'accès.

**Niveaux de sécurité:**

| Niveau | Opérations | Autorisation |
|--------|------------|--------------|
| 1 | file_read | Auto |
| 2 | file_write, api_call | Review |
| 3 | deploy, config_change | Approval |
| 4 | production, database | Explicit |

**Chemins bloqués:**

- `/etc/*`, `/usr/*`, `/bin/*` (système)
- `~/.ssh/*`, `~/.gnupg/*` (secrets)
- `node_modules/` (dépendances)

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `security_check_gate` | Vérifie l'autorisation |
| `security_record_event` | Enregistre un événement |
| `security_request_approval` | Demande approbation |

**Usage:**

```bash
source .harmony/lib/security-gates.sh

if security_check_gate "file_write" "/path/to/file" "developer"; then
    echo "Écriture autorisée"
else
    echo "Accès refusé - niveau insuffisant"
fi
```

---

### Anomaly Detector (`lib/anomaly-detector.sh`)

Détection d'anomalies comportementales.

**Anomalies détectées:**

| Type | Indicateurs | Sévérité |
|------|-------------|----------|
| Loop | Lignes répétées (>3x) | 2-3 |
| Hallucination | Fichiers/classes inexistants | 2-3 |
| Performance | Temps > 2x baseline | 1-2 |
| Unusual | Output > 2x normal | 1-2 |

**Fonctions principales:**

| Fonction | Description |
|----------|-------------|
| `anomaly_check` | Vérifie la sortie d'un agent |
| `anomaly_record_baseline` | Établit une baseline |

**Usage:**

```bash
source .harmony/lib/anomaly-detector.sh

severity=$(anomaly_check "developer" "$agent_output")

if [[ $severity -gt 2 ]]; then
    echo "Anomalie sévère détectée!"
    # Activer circuit breaker
fi
```

---

## Patterns Cognitifs

### Emotional Prompting (`patterns/cognitive/emotional-prompting.md`)

Techniques psychologiques pour améliorer l'engagement:

- **Positive Framing**: "L'équipe compte sur toi"
- **Stakes Communication**: "C'est critique pour la release"
- **Empathy Injection**: Reconnaissance de la difficulté

### Meta-Prompting (`patterns/cognitive/meta-prompting.md`)

Génération dynamique de prompts selon le contexte:

- Sélection de template adaptée
- Injection de connaissances JIT
- Adaptation au niveau de complexité

**Pattern associé:** [P-021-meta-prompting](../patterns/P-021-meta-prompting.md)

### Self-Evolving (`patterns/cognitive/self-evolving.md`)

Boucle d'amélioration continue:

```
Execute → Evaluate → LLM-as-Judge → Feedback → Meta-prompt → Execute
```

---

## Configuration

### Fichiers de configuration

| Fichier | Description |
|---------|-------------|
| `.harmony/local/audit-config.json` | Rétention, champs sensibles |
| `.harmony/local/confidence-config.json` | Seuils, poids scoring |
| `.harmony/local/sandbox-config.json` | Patterns bloqués, schémas |

### Variables d'environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `HARMONY_DIR` | `.harmony` | Répertoire framework |
| `FILCO_CHUNK_SIZE` | 500 | Taille des chunks |
| `PRELOADER_MAX_TOKENS` | 15000 | Budget tokens max |

---

## Tests

### Validation rapide

```bash
./tests/e2e/scripts/test.sh /path/to/project governance
```

### Scénario complet

```bash
./tests/e2e/scripts/test.sh /path/to/project scenario governance
```

### Self-tests des modules

Chaque module inclut une fonction `_self_test()`:

```bash
source .harmony/lib/audit-trail.sh
audit_trail_self_test  # ou appel direct avec --test
```

---

## Références

| Pattern | Description |
|---------|-------------|
| [P-021-meta-prompting](../patterns/P-021-meta-prompting.md) | Génération dynamique prompts |
| [P-022-agent-maturity](../patterns/P-022-agent-maturity.md) | Modèle maturité L1-L4 |
| [P-023-mesh-networks](../patterns/P-023-mesh-networks.md) | Collaboration P2P |
| [P-024-context-filtering](../patterns/P-024-context-filtering.md) | Algorithme FILCO |

---

## Changelog

- **v1.1.0**: Implémentation initiale des 15 concepts
  - 10 modules bash (lib/)
  - 3 patterns cognitifs
  - 4 patterns système (P-021 à P-024)
  - Tests E2E complets
