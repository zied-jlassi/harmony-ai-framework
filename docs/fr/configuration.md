# Référence de Configuration

> **🌐 Langue :** [English](../configuration.md) · Français

Tout ce que vous pouvez régler dans Harmony, au même endroit : variables
d'environnement (surcharges instantanées, par shell ou en CI) et fichiers de
configuration (état persistant).

> `${HARMONY_DIR}` = répertoire d'installation Harmony (défaut : `.harmony`).

---

## Ordre de résolution

Pour tout réglage, la source la plus spécifique l'emporte :

```
variable d'environnement   →   fichier de config projet   →   défaut framework
   (instantané, par shell)      (persistant)                   (intégré)
```

Ainsi `HARMONY_GUARDS=off` l'emporte toujours sur `security-guards.json`, qui
l'emporte sur le défaut intégré « activé ».

---

## Variables d'environnement

### Core

| Variable | Défaut | Effet |
|----------|--------|-------|
| `HARMONY_DIR` | `.harmony` | Répertoire d'installation (où vit le framework) |
| `HARMONY_MEMORY_DIR` | `${HARMONY_DIR}/local/memory` | Emplacement de la mémoire projet mutable |
| `HARMONY_NO_AUTOLOAD` | `0` | `1` désactive l'autoload automatique du contexte |

### Hooks & gardes de sécurité

| Variable | Défaut | Effet |
|----------|--------|-------|
| `HARMONY_HOOK_UI` | `on` | `off` coupe le statut visible `systemMessage` (les gardes tournent toujours) |
| `HARMONY_GUARDS` | *(activé)* | `off` désactive supply-chain + sanitizer LLM instantanément (zéro impact perf) |
| `HARMONY_HOOK_DEBUG` | `0` | `1` affiche la trace de décision d'un hook sur stderr |
| `HARMONY_SANITIZER_MODE` | `external-only` | `strict` analyse aussi `Read` + lance Semgrep |
| `HARMONY_PKG_COOLING_DAYS` | `14` | Seuil de quarantaine — alerte sur les packages publiés plus récemment |

→ Voir [Hooks](hooks.md) et [Security Guards](security-guards.md).

### Routage d'intention & modèles (RouteLLM)

| Variable | Défaut | Effet |
|----------|--------|-------|
| `HARMONY_ROUTER_MODE` | `auto` | Force le path du router : `auto` \| `claude-code` \| `api` \| `pattern` |
| `HARMONY_MAIN_MODEL` | *(config)* | Surcharge l'alias du modèle fort/tier-1 |
| `HARMONY_WEAK_MODEL` | *(config)* | Surcharge l'alias du modèle léger/router |
| `HARMONY_EDITOR_MODEL` | *(config)* | Surcharge le modèle utilisé pour les éditions |

**Priorité du path** (`auto`) : `CLAUDECODE=1` → Task tool natif (**sans clé API**)
→ clé API si présente → fallback pattern déterministe. Le modèle de classification
vient de la config (`router_model`), jamais codé en dur. → Voir [How It Works](how-it-works.md).

#### Clés API provider (CLI / standalone uniquement)

Nécessaires seulement **hors** Claude Code (le path natif n'a besoin d'aucune clé).
La première clé présente sélectionne le provider :

| Variable | Provider |
|----------|----------|
| `ANTHROPIC_API_KEY` | Anthropic (Claude) |
| `OPENAI_API_KEY` | OpenAI |
| `GROQ_API_KEY` | Groq |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI |
| `MISTRAL_API_KEY` | Mistral |

### Auto-linter

| Variable | Défaut | Effet |
|----------|--------|-------|
| `HARMONY_LINT_AUTO_FIX` | `false` | `true` applique automatiquement les correctifs lint sûrs |
| `HARMONY_LINT_STRICT` | `false` | `true` traite les warnings lint comme des erreurs |
| `HARMONY_LINT_IGNORE_PATTERNS` | `node_modules,vendor,.git,dist,build` | Chemins à ignorer (séparés par virgule) |

→ Voir [Assistant Toolkit](../assistant-toolkit.md).

### Prompt Monitor (optionnel)

| Variable | Défaut | Effet |
|----------|--------|-------|
| `HARMONY_MONITOR_PORT` | `8080` | Port du dashboard local |
| `HARMONY_MONITOR_URL` | `http://localhost:8080` | Endpoint où le hook de tracking poste |

→ Voir [Prompt Monitor](../prompt-monitor.md).

---

## Fichiers de configuration

| Fichier | Portée | Contrôle |
|---------|--------|----------|
| `.claude/settings.json` | IDE | Hooks câblés (PreToolUse / PostToolUse) + `statusMessage` |
| `${HARMONY_DIR}/local/security-guards.json` | Projet | `enabled` + `mode` des gardes (block/warn, external-only/strict) |
| `${HARMONY_DIR}/config/routing-rules.yaml` | Framework | `router_model`, `classification_prompt`, triggers d'auto-détection |
| `${HARMONY_DIR}/config/model-tiers.yaml` | Framework | Mapping modèle par provider (tier1/tier2/tier3/router) |
| `${HARMONY_DIR}/config.yaml` | Surcharge projet | ex. `llm.router.model` — surcharge le modèle router du framework |
| `${HARMONY_DIR}/local/memory/*.json` | Projet (mutable) | workflow-state, circuit-breaker, error-journal, working, learned-patterns |

> Les surcharges projet vivent dans `local/` et survivent aux réinstallations ; le
> cœur du framework est read-only et remplacé à la mise à jour.
> → Voir [Memory Architecture](../memory-architecture.md).

### Exemple : choisir un autre modèle de router

```yaml
# .harmony/config.yaml
llm:
  router:
    model: "sonnet"   # le défaut est "haiku" (depuis routing-rules.yaml)
```

Ou au niveau framework :

```yaml
# .harmony/config/routing-rules.yaml
auto_detection:
  router_model: "sonnet"
```

---

## Liens connexes

- [Hooks](hooks.md) — le système de hooks et son contrat
- [Security Guards](security-guards.md) — couche de protection
- [How It Works](how-it-works.md) — routage & observabilité
- [Overrides](../overrides.md) — modèle de personnalisation projet
