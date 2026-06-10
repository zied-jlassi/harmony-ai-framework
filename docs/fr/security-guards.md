# Security Guards — Harmony Framework

> **🌐 Langue :** [English](../security-guards.md) · Français

Une couche de protection qui s'exécute **automatiquement** à chaque action, conçue
pour **zéro impact perf** quand un garde est inactif. `rules-enforcer` est **actif
par défaut** (installation `--full`) ; les deux gardes de supply chain / contenu
externe s'activent/désactivent via switch.

> `${HARMONY_DIR}` = répertoire d'installation Harmony (défaut : `.harmony`).

---

## Vue d'ensemble

| Guard | Type de hook | Par défaut | Rôle |
|-------|-------------|:----------:|------|
| **rules-enforcer** | PreToolUse (Edit, Write, Bash) | ✅ actif | Bloque les commandes destructrices et l'injection shell avant exécution |
| **supply-chain-guard** | PreToolUse (Bash) | ✅ actif | Vérifie les installations de packages avant exécution |
| **llm-output-sanitizer** | PostToolUse (Bash, WebFetch, WebSearch) | ✅ actif | Filtre le contenu externe entrant dans le contexte |

> **Contrat de hook (Claude Code).** Chaque garde lit les données de l'outil en
> **JSON sur stdin** (`tool_name`, `tool_input`, `tool_response`) et **bloque par
> `exit 2`** (la raison part sur stderr, montrée à l'assistant). En passe, il émet
> une preuve visible (voir [Ce que vous voyez](#ce-que-vous-voyez)).

> ℹ️ Référentiel complet des hooks (les 11, contrat stdin/exit 2, visibilité,
> défaut vs optionnel) : **[hooks.md](hooks.md)**. Bloc `settings.json` exact :
> [installation.md](installation.md#for-claude-code). Tous les knobs `HARMONY_*` :
> [configuration.md](configuration.md).

---

## 0. rules-enforcer

Intercepte **toute** opération `Edit` / `Write` / `Bash` et bloque les schémas
dangereux **avant** qu'ils s'exécutent :

| Catégorie | Exemples bloqués (exit 2) |
|-----------|---------------------------|
| Destruction fichiers | `rm -rf /`, `rm -rf ~`, `rm -rf *` |
| SQL destructif | `DROP DATABASE`, `DROP TABLE`, `TRUNCATE` |
| Permissions dangereuses | `chmod 777 /`, `chmod -R 777` |
| Pipe-vers-interpréteur | `curl … \| bash`, `wget … \| sh`, `bash <(curl …)`, `eval $(curl …)` |
| Fork bomb / disque | `:(){ :\|:& };:`, `dd if=/dev/zero`, `> /dev/sda` |
| Secrets dans le contenu | clés privées, API keys, tokens écrits dans un fichier |

Modes : `block` (défaut, exit 2) ou `warn`. Surcharges projet (patterns à
ajouter/désactiver, exceptions Docker) : voir [overrides.md](overrides.md).

---

## 1. supply-chain-guard

Intercepte les commandes d'installation (`npm`, `pip`, `composer`, `cargo`, `gem`, `go`, `apt`, `brew`, `npx`) et applique 6 couches de vérification :

| Couche | Vérification |
|--------|-------------|
| 1 | Patterns dangereux : URLs non-officielles, archives locales, post-install chaîné, HTTP non-sécurisé |
| 2 | **Typosquatting** : noms proches de packages populaires (liste enrichie incidents 2026 : OpenSearch, ElasticSearch, Kubernetes...) |
| 3 | **Audit local** : `npm audit`, `pip-audit`/`safety`, `composer audit`, `cargo audit` |
| 4 | **Période de quarantaine** : alerte si un package a été publié il y a moins de N jours (défaut 14) — un package récent est un vecteur supply chain |
| 5 | **Lock file** : alerte si install sans `package-lock.json` / `requirements.txt` pinné |
| 6 | **Serveurs MCP** : bloque les installs MCP sans version pinnée + hash (`npx -y @modelcontextprotocol/server-*`) |

### Pourquoi la vérification MCP ?

Les serveurs MCP installés via `npx -y @modelcontextprotocol/server-xxx` tirent toujours la **dernière version sans pin ni hash**. Une version compromise serait auto-installée silencieusement.

```bash
# ❌ BLOQUÉ — version non pinnée
npx -y @modelcontextprotocol/server-memory

# ✅ AUTORISÉ — version pinnée
npx @modelcontextprotocol/server-memory@2025.1.0
```

Le guard scanne aussi `.mcp.json`, `.claude/mcp.json`, `.cursor/mcp.json` pour détecter les serveurs configurés sans version pinnée.

### Modes

- `block` (défaut) : bloque la commande dangereuse (exit 2)
- `warn` : alerte seulement, laisse passer

### Variables d'environnement

| Variable | Effet |
|----------|-------|
| `HARMONY_PKG_COOLING_DAYS` | Seuil de quarantaine en jours (défaut 14) |
| `HARMONY_GUARDS=off` | Désactive tous les guards instantanément |

---

## 2. llm-output-sanitizer

Filtre le contenu provenant de **sources externes non-natives Claude**. Les réponses natives de Claude (Edit, Write) ne sont PAS filtrées — seul le contenu qui *entre* dans le contexte depuis l'extérieur est analysé.

### Deux modes d'activation

| Mode | Sources analysées | Usage |
|------|-------------------|-------|
| **external-only** (défaut) | WebFetch, WebSearch, `curl`/`wget` vers URL, appels LLM (`ollama`, API) | Recommandé — couvre les vrais vecteurs d'injection avec un coût minimal |
| **strict** | external-only **+** lectures de fichiers (`Read`) **+** static analysis Semgrep sur le code | Maximum de sécurité, légèrement plus coûteux |

### Pourquoi distinguer "externe" et "natif" ?

Le risque d'injection de prompt vient du **contenu non fiable** qui entre dans le contexte :
- Une page web récupérée par WebFetch (injection cachée dans le HTML/markdown)
- Une réponse d'un LLM externe (ollama, OpenAI, etc.)
- Un document téléchargé via curl/wget
- Un fichier externe lu (mode strict)

Le contenu généré par Claude lui-même est de confiance → pas besoin de le filtrer, d'où le gain de performance.

### 7 couches de détection

| Couche | Détection |
|--------|-----------|
| 1 | Stéganographie Unicode (zero-width, ASCII smuggling U+E0000) |
| 2 | Artifacts d'injection de prompt (DAN, jailbreak, override, ignore instructions) |
| 3 | Injection shell (reverse shells, `/dev/tcp`, fork bomb, `rm -rf`) |
| 4 | Exfiltration réseau (ngrok, webhook.site, DNS exfil, data URI) |
| 5 | Secrets & credentials (clés privées, API keys, tokens) |
| 6 | Supply chain dans le code suggéré (post-install, typosquats) |
| 7 | Static analysis Semgrep (mode strict, si `semgrep` installé) |

### Limitation connue

Les injections **multimodales** (instructions cachées dans des images) ne sont pas couvertes — le sanitizer analyse uniquement le texte. Pour les LLM multimodaux, prévoir une couche dédiée.

---

## Ce que vous voyez

Chaque garde laisse une **trace visible** — vous savez qu'il s'est déclenché, sans
ouvrir de dashboard :

| Garde | Sortie visible (exit 0 = pass) |
|-------|--------------------------------|
| **rules-enforcer** | `🛡️ Rules: clean — no interdiction (Bash)` · ou un bloc + la raison au blocage |
| **supply-chain-guard** | `📦 Supply-chain: clean — install screened` |
| **Sentinel** (circuit breaker) | `🧠 Sentinel: circuit CLOSED (0/3 failures)` à chaque action |

La preuve transite par le champ `systemMessage` du hook (seul canal d'un hook
non-bloquant visible à l'utilisateur dans Claude Code) ; un spinner `statusMessage`
s'affiche pendant l'exécution. Pour tout couper : `export HARMONY_HOOK_UI=off`.

---

## Switch : activer / désactiver

### Via slash command (dans Claude Code)

```
/hf:security:guards status                      # État actuel
/hf:security:guards on                          # Activer tout
/hf:security:guards off                         # Désactiver tout
/hf:security:guards on supply-chain             # Activer un guard
/hf:security:guards off llm-sanitizer           # Désactiver un guard
/hf:security:guards mode supply-chain warn      # Changer le mode
/hf:security:guards mode llm-sanitizer strict   # Mode strict
```

### Via script (terminal / CI)

```bash
bash ${HARMONY_DIR}/lib/security-guards.sh status
bash ${HARMONY_DIR}/lib/security-guards.sh off supply-chain
```

### Via variable d'environnement (override instantané)

```bash
export HARMONY_GUARDS=off    # Désactive tout — utile en CI ou debug
```

---

## Configuration

Source de vérité : `${HARMONY_DIR}/local/security-guards.json`

```json
{
  "supply_chain_guard": {
    "enabled": true,
    "mode": "block"
  },
  "llm_output_sanitizer": {
    "enabled": true,
    "mode": "external-only"
  }
}
```

**Priorité de résolution** (du plus rapide au plus lent) :
1. `HARMONY_GUARDS=off` (env) → désactivation instantanée, 0ms
2. Config file → état persistant, ~5ms
3. Défaut → activé

Quand un guard est désactivé, son hook sort en quelques millisecondes sans rien analyser → **zéro impact perf**.

---

## Performance

| Situation | Coût |
|-----------|------|
| Guard désactivé (env ou config) | < 5ms (exit immédiat) |
| supply-chain sur commande non-install | < 1ms (exit rapide) |
| supply-chain sur install (audit local + registry online) | 2-8s |
| llm-sanitizer sur tool natif Claude | < 1ms (non-externe) |
| llm-sanitizer sur WebFetch/LLM (couches bash) | < 10ms |
| llm-sanitizer mode strict + Semgrep | +1-3s par bloc de code |

---

## Références

- OWASP LLM Top 10 — Prompt Injection (LLM01)
- Microsoft Security (2026-05-28) — typosquats npm volant secrets CI/CD
- PISanitizer (arxiv 2511.10720) — prompt sanitization long-context
