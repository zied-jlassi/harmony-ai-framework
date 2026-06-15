# Référence des Hooks

> **🌐 Langue :** [English](../hooks.md) · Français

Harmony fonctionne comme un ensemble de **hooks** — de petits scripts rapides que
l'IDE invoque autour de vos actions. Ils chargent le contexte, bloquent les
opérations dangereuses, apprennent des erreurs et — surtout — **vous signalent
quand ils se déclenchent**.

> `${HARMONY_DIR}` = répertoire d'installation Harmony (défaut : `.harmony`).
> Les hooks vivent dans `${HARMONY_DIR}/hooks/`, câblés dans `.claude/settings.json`.

---

## Le contrat de hook (Claude Code)

Chaque hook Harmony suit le contrat actuel de Claude Code — pas d'arguments
positionnels, pas d'interpolation `$TOOL_INPUT` :

| Aspect | Comportement |
|--------|--------------|
| **Entrée** | JSON sur **stdin** — `tool_name`, `tool_input`, `tool_response` (PostToolUse) |
| **Blocage** | **`exit 2`** + raison sur **stderr** (remontée à l'assistant) |
| **Passage** | `exit 0` ; un JSON `{"systemMessage": "…"}` sur stdout vous est montré |
| **Spinner** | `statusMessage` dans `settings.json` s'affiche pendant l'exécution |

C'est ce qui rend Harmony **observable** : le stdout d'un hook non-bloquant est
masqué par l'IDE, donc chaque garde émet un `systemMessage` comme **preuve visible**
qu'il s'est exécuté.

```
🛡️ Rules: clean — no interdiction (Bash)
🧠 Sentinel: circuit CLOSED (0/3 failures)
📦 Supply-chain: clean — install screened
```

Bibliothèque d'aide : `lib/hook-ui.sh` (`hook_status`, `hook_debug`, `hook_block`).
Couper toute la sortie visible : `HARMONY_HOOK_UI=off` (le debug reste sur stderr).

---

## Hooks câblés par `--full` (actifs par défaut)

`npx harmony-ai --full` écrit ces sept hooks dans `.claude/settings.json` :

| Ordre | Hook | Événement (matcher) | Rôle | Bloque ? |
|:-----:|------|---------------------|------|:--------:|
| 1 | **rules-enforcer** | PreToolUse · `Edit\|Write\|Bash` | Bloque les commandes destructrices (`rm -rf /`, `DROP DATABASE`, fork bombs), l'injection shell (`curl \| bash`), les secrets dans les fichiers | ✅ |
| 2 | **guardian-checkpoint** | PreToolUse · `Edit\|Write\|Bash` | Impose le développement basé sur des stories (mode strict) | ✅ (strict) |
| 3 | **sentinel-pre** | PreToolUse · `Edit\|Write\|Bash` | Vérifie l'historique d'erreurs ; bloque si le circuit breaker est OPEN ; affiche l'état du circuit | ✅ (OPEN) |
| 4 | **aria-detect** | PreToolUse · `Edit\|Write` | Détecte les flags d'accessibilité/contexte sur les éditions | — |
| 5 | **supply-chain-guard** | PreToolUse · `Bash` | Vérifie les installations de packages (typosquats, audits, MCP non pinné, quarantaine) | ✅ |
| 6 | **sentinel-post** | PostToolUse · `Edit\|Write\|Bash` | Enregistre le résultat, met à jour le circuit breaker, apprend les patterns | — |
| 7 | **llm-output-sanitizer** | PostToolUse · `Bash\|WebFetch\|WebSearch` | Filtre le contenu externe entrant (injection, exfiltration, Unicode caché) | — |

`rules-enforcer` s'exécute **en premier** — les interdictions avant tout le reste.

> Installer sans hooks : `npx harmony-ai --full --no-hooks`. Réactiver ensuite en
> relançant `npx harmony-ai --full --force`, ou éditer `.claude/settings.json`
> (le bloc exact est dans [installation.md](installation.md#for-claude-code)).

### Ce que chacun vous montre

| Hook | Statut visible au passage | Au blocage |
|------|---------------------------|------------|
| rules-enforcer | `🛡️ Rules: clean — no interdiction (<outil>)` | bloc rouge + le pattern détecté (stderr) |
| guardian-checkpoint | `🛡️ Guardian: story <id> active` / `⚠️ no active story` | raison de la violation (stderr) |
| sentinel-pre | `🧠 Sentinel: circuit <état> (<n>/3 failures)` | avertissement circuit OPEN (stderr) |
| supply-chain-guard | `📦 Supply-chain: clean — install screened` | `[SCG-BLOCK]` + raison (stderr) |

---

## Hooks additionnels (optionnels, non câblés par `--full`)

Ils sont livrés avec le framework mais **ne sont pas** ajoutés à `settings.json` par
défaut. Activez-les en ajoutant une entrée dans `.claude/settings.json`. Ce sont des
aides au cycle de session/analyse, pas des gardes de sécurité.

| Hook | Rôle | Événement typique |
|------|------|-------------------|
| **token-monitor** | Suit l'usage estimé de tokens par session (cross-platform) | PostToolUse / périodique |
| **compacting-warning** | Avertit avant une compaction de contexte pour sauver vos recherches/insights | Pré-compaction |
| **session-resume** | Détecte une session d'analyse en attente au démarrage et propose de reprendre | SessionStart / 1er prompt |
| **profile-loader** | Charge des sections de profil selon l'intention détectée (surcharge équipe > framework) | Invoqué par le système de contexte |

> Voir [Overrides](../overrides.md) pour le modèle de surcharge à 2 niveaux
> (local/équipe > framework) utilisé par `profile-loader` et les gardes.

---

## Personnaliser & désactiver

| Objectif | Comment |
|----------|---------|
| Couper le statut visible (gardes actives) | `export HARMONY_HOOK_UI=off` |
| Désactiver supply-chain + sanitizer instantanément | `export HARMONY_GUARDS=off` |
| Passer une garde en warn-only | `/hf:security:guards mode supply-chain warn` |
| Déboguer la décision d'un hook | `HARMONY_HOOK_DEBUG=1` puis piper le JSON (voir [overrides.md](../overrides.md)) |
| Ajouter des règles/exceptions projet | `.harmony/config.yaml` → voir [Overrides](../overrides.md) |
| Référence complète des variables d'env | [Configuration](configuration.md) |

### Invocation manuelle (debug)

Les hooks lisent le JSON sur stdin — invoquez-les comme le fait l'IDE :

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"npm install lodash"}}' \
  | bash .harmony/hooks/supply-chain-guard.sh
```

---

## Liens connexes

- [Security Guards](security-guards.md) — la couche de protection en détail
- [Configuration](configuration.md) — chaque knob `HARMONY_*` et fichier de config
- [How It Works](how-it-works.md#observable-by-design) — Observable by design
- [Installation](installation.md#for-claude-code) — le bloc `settings.json` exact
