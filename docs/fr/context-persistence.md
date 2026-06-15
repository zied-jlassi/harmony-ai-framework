# Context Persistence System

> **🌐 Langue :** [English](../context-persistence.md) · Français

Le systeme de persistance de contexte protege le fil de raisonnement lors des analyses longues, avant le compacting de Claude Code.

## Probleme resolu

Lors d'analyses longues (architecture, recherche, decisions), le compacting de Claude Code peut perdre:
- Le fil de raisonnement
- Les comparaisons effectuees
- Les decisions en cours
- Le contexte des investigations

**Important**: Le serveur officiel `@modelcontextprotocol/server-memory` est un stockage **passif** - il ne sauvegarde PAS automatiquement avant compacting.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTEXT PERSISTENCE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  UserPromptSubmit Hook                                         │
│  ════════════════════                                          │
│      │                                                          │
│      ├──► session-resume.sh                                    │
│      │    └── Detecte sessions en cours                        │
│      │    └── Propose reprise si analyse pending               │
│      │                                                          │
│      └──► compacting-warning.sh                                │
│           └── Detecte /clear → supprime tout                   │
│           └── Detecte mode analyse (keywords)                  │
│           └── Auto-save .harmony/local/tmp/sessions/           │
│           └── Warning jaune si limite approche                 │
│           └── Alerte rouge si trop de sessions                 │
│                                                                 │
│  Stockage (projet-specifique)                                   │
│  ════════════════════════════                                   │
│      │                                                          │
│      ├──► .harmony/local/tmp/sessions/{session_id}/            │
│      │    ├── analysis.json (analysis-tracker)                 │
│      │    └── session-state.json (compacting-warning)          │
│      │                                                          │
│      ├──► .harmony/local/session-config.json (config rotation) │
│      │                                                          │
│      └──► research/ (export permanent)                         │
│           └── SESSION-{date}-{topic}.md                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Composants

### 1. analysis-tracker.sh (lib/)

Tracker du fil de raisonnement pour les analyses/decisions.

**Fonctions principales:**
```bash
# Demarrer une session d'analyse
init_analysis_session "Migration jq vers Node.js" "architecture_decision"

# Ajouter une etape de raisonnement
add_reasoning_step "Probleme identifie" "417 usages jq dans le code"

# Ajouter une decouverte
add_finding "performance" "jq 5-10x plus rapide que Node.js" "benchmark"

# Ajouter une comparaison
add_comparison "jq" "Node.js" "performance" "jq" "natif vs startup overhead"

# Marquer une decision
mark_decision "jq recommande" "Performance > Portabilite" "Mise a jour prereqs"

# Exporter vers research/
export_to_markdown "research/ADR-001-migration.md"
```

**Types d'analyse:**
- `architecture_decision` - Decision architecturale (ADR)
- `research` - Recherche/Investigation
- `comparison` - Comparaison d'options
- `investigation` - Investigation de bug/probleme

### 2. compacting-warning.sh (hooks/)

Hook pre-compacting avec auto-save et warning UX.

**Detection automatique du mode analyse:**
```bash
ANALYSIS_KEYWORDS="analyse|analysis|research|compare|benchmark|study|evaluate|architecture|design|trade-off|decision|adr|investigation|decide|choisir|comparer"
```

**Seuils de warning:**
- 50 messages dans la session
- 45 minutes de session
- Mode analyse actif

**Auto-save:**
- Toutes les 10 messages
- Toutes les 5 minutes
- Vers `/tmp/harmony-sessions/{session_id}/`

**Warning UX:**
```
╔══════════════════════════════════════════════════════════════════════╗
║  ⚠️  APPROCHE LIMITE DE CONTEXTE - Risque de compacting             ║
╠══════════════════════════════════════════════════════════════════════╣
║  Session: 55 messages | 50 minutes | Mode: analyse                   ║
║  ✓ Etat auto-sauvegarde: /tmp/harmony-sessions/abc12345/             ║
╠══════════════════════════════════════════════════════════════════════╣
║  Options:                                                            ║
║  1. "Sauvegarde dans research/" → Fichier permanent                  ║
║  2. "Continue" → Reprendra depuis /tmp si compacting                 ║
║  3. "Cree un ADR pour cette decision"                               ║
╚══════════════════════════════════════════════════════════════════════╝
```

### 3. session-resume.sh (hooks/)

Propose la reprise des sessions d'analyse en cours.

**Detection au demarrage:**
- Verifie `/tmp/harmony-sessions/` pour sessions pending
- Filtre par projet courant
- Affiche les 3 sessions les plus recentes

**Commandes de reprise:**
```
"Reprends l'analyse [session_id]"
"Continue l'analyse precedente"
"Exporte l'analyse dans research/"
```

## Relation avec server-memory (officiel)

| Composant | Role |
|-----------|------|
| `@modelcontextprotocol/server-memory` | Stockage passif (knowledge graph, entites) |
| `analysis-tracker.sh` | **Protection active** - fil de raisonnement |
| `compacting-warning.sh` | **Warning UX** + auto-save avant compacting |
| `session-resume.sh` | **Reprise** - propose de reprendre les sessions |

**Les deux sont complementaires:**
- `server-memory` = memoire long-terme (entites, relations)
- Notre systeme = protection court-terme (analyses en cours, decisions)

## Usage

### Demarrer une analyse structuree
```bash
# Via CLI (pour tests)
.harmony/lib/analysis-tracker.sh init "Choix framework frontend" comparison
.harmony/lib/analysis-tracker.sh step "React vs Vue vs Svelte"
.harmony/lib/analysis-tracker.sh compare "React" "Vue" "ecosystem" "React" "Plus mature"
.harmony/lib/analysis-tracker.sh decide "React choisi" "Ecosystem et equipe"
.harmony/lib/analysis-tracker.sh export
```

### Lister les sessions en cours
```bash
.harmony/hooks/session-resume.sh --list
```

### Reprendre une session
```bash
.harmony/hooks/session-resume.sh --resume abc12345
```

### Voir le status de session
```bash
.harmony/hooks/compacting-warning.sh --status
```

### Effacer toutes les sessions (comme /clear)
```bash
.harmony/hooks/compacting-warning.sh --clear
```

## Rotation & Cleanup

Le systeme inclut une rotation automatique pour eviter la saturation disque.

### Integration avec /clear de Claude Code

Quand l'utilisateur execute `/clear` (commande native de Claude Code), le hook detecte automatiquement cette commande et:
1. Supprime toutes les sessions sauvegardees dans `.harmony/local/tmp/sessions/`
2. Reinitialise le tracker de session
3. Affiche une confirmation: `[Harmony] Sessions effacees avec /clear`

Cela garantit que quand l'utilisateur veut "repartir de zero", toutes les donnees de session sont nettoyees.

### Rotation automatique

| Declencheur | Action |
|-------------|--------|
| `init` (nouvelle session) | Supprime sessions >7 jours + garde max 5 |
| `export` vers research/ | Supprime la session de /tmp |
| `/clear` (Claude Code) | Supprime TOUTES les sessions |

### Commandes manuelles

```bash
# Voir espace disque utilise
.harmony/lib/analysis-tracker.sh disk

# Forcer la rotation
.harmony/lib/analysis-tracker.sh rotate

# Supprimer une session specifique
.harmony/lib/analysis-tracker.sh cleanup abc12345

# Supprimer TOUTES les sessions
.harmony/lib/analysis-tracker.sh cleanup
```

### Configuration rotation

Fichier de config local: `.harmony/local/session-config.json`

```json
{
    "max_sessions": 5,       // Garder max 5 sessions
    "max_age_days": 7,       // Supprimer sessions > 7 jours
    "max_disk_mb": 50,       // Max 50MB pour toutes les sessions
    "cleanup_on_export": true // Supprimer de /tmp apres export
}
```

Commandes de config:
```bash
# Voir la config actuelle
.harmony/lib/analysis-tracker.sh config

# Modifier une valeur
.harmony/lib/analysis-tracker.sh config set max_sessions 10
.harmony/lib/analysis-tracker.sh config set max_disk_mb 100
```

## Configuration

Variables d'environnement:
```bash
# Dossier de sauvegarde (defaut: .harmony/local/tmp/sessions)
# Specifique au projet, dans le dossier .harmony
export HARMONY_DIR=".harmony"

# Seuils de warning
WARNING_THRESHOLD_MESSAGES=50
WARNING_THRESHOLD_MINUTES=45
AUTO_SAVE_INTERVAL_MESSAGES=10
```

## Tests

Le systeme de persistance de contexte est couvert par des tests unitaires (24 assertions).

### Executer les tests

```bash
# Tous les tests session-management
./tests/e2e/scripts/unit/test-session-management.sh

# Via le runner unifie
./tests/e2e/scripts/unit/run-all.sh session-management

# Via test.sh (avec projet cible)
./tests/e2e/scripts/test.sh /path/to/project unit session-management
```

### Tests couverts

| Test | Description |
|------|-------------|
| `/clear` detection | Detecte `/clear`, `/clear args`, mais pas `clear` dans le texte |
| `/clear` execution | Supprime toutes les sessions et reinitialise le tracker |
| Session tracker init | Creation automatique du tracker |
| Analysis mode detection | Detection des mots-cles (analyse, research, compare, etc.) |
| Rotation config | Creation et lecture de `session-config.json` |
| Session cleanup | Suppression des sessions via commande |
| Disk usage display | Affichage de l'espace disque utilise |
| Session resume detection | Detection des sessions pending |
| Full lifecycle | init → track → clear |

### Prerequis pour les tests

- `jq` installe (manipulation JSON)
- Permissions d'ecriture dans le repertoire de test
- Framework Harmony present dans le repertoire du projet (`.harmony/`)

## References

- [Official server-memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
- [mcp-memory-keeper](https://github.com/mkreyman/mcp-memory-keeper) (complementaire)
