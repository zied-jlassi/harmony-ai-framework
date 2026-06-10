# Guide d'Installation

> **🌐 Langue :** [English](../installation.md) · Français

Guide complet pour installer Harmony Framework dans votre projet.

## Prérequis (Obligatoires)

Harmony Framework requiert l'installation de ces outils **avant** l'installation :

| Outil | Version | Rôle | Installation |
|-------|---------|------|--------------|
| **Node.js** | 18+ | Runtime pour npx | [nodejs.org](https://nodejs.org/) |
| **jq** | 1.6+ | Traitement JSON & parsing de config | Voir ci-dessous |
| **yq** | toute | Traitement YAML & chargement de config | Voir ci-dessous |

### Pourquoi jq et yq ?

- **Performance** : le parsing natif JSON/YAML est 10-100x plus rapide que les alternatives shell
- **Fiabilité** : gestion robuste des fichiers de config sans hacks regex
- **Fonctionnalités** : deep merge, requêtes par chemin, conversion de format

### Installation par OS

**Ubuntu/Debian :**
```bash
sudo apt update && sudo apt install -y jq yq
```

**macOS :**
```bash
brew install jq yq
```

**Fedora/RHEL :**
```bash
sudo dnf install -y jq yq
```

**Arch Linux :**
```bash
sudo pacman -S jq yq
```

**Windows (WSL2 recommandé) :**
```bash
# Dans WSL2 Ubuntu :
sudo apt update && sudo apt install -y jq yq
```

### Vérifier l'installation

```bash
# Les trois doivent réussir
node --version   # v18.0.0 ou supérieur
jq --version     # jq-1.6 ou supérieur
yq --version     # n'importe quelle version fonctionne
```

> ⚠️ **L'installation échouera** si jq ou yq ne sont pas trouvés dans votre PATH.

---

## Méthodes d'installation

Harmony s'installe **dans votre projet** avec une seule commande `npx` — pas d'install
globale et pas d'étape `init` séparée. Lancez-la depuis la racine de votre projet.

### Méthode 1 : npx (Recommandée)

```bash
# Installation complète AVEC hooks (recommandée)
npx harmony-ai --full
```

C'est tout. L'installeur crée `.harmony/` dans votre projet, configure automatiquement
les hooks Claude Code (dans `.claude/settings.json`), et affiche un résumé.

#### Options

| Flag | Effet |
|------|-------|
| `--full` | Framework complet **avec** hooks (recommandé) |
| `--minimal` | Fichiers cœur seulement, **sans** hooks |
| `--hooks` | Active les hooks (déjà inclus dans `--full`) |
| `--no-hooks` | À utiliser avec `--full` pour tout installer sauf les hooks |
| `--ide TYPE` | IDE cible : `auto` (défaut), `claude-code`, `cursor`, `windsurf`, `continue`, `cody` |
| `--project-dir PATH` | Répertoire projet cible (doit déjà exister ; défaut : répertoire courant) |
| `--force` | Écrase une installation existante |
| `--help` | Affiche toutes les options |

```bash
# Installation complète pour Cursor
npx harmony-ai --full --ide cursor

# Installation complète sans hooks
npx harmony-ai --full --no-hooks

# Installation minimale (sans hooks)
npx harmony-ai --minimal

# Réinstallation forcée / restauration
npx harmony-ai --full --force
```

### Méthode 2 : Installation manuelle (depuis un clone)

```bash
# Cloner le dépôt
git clone https://github.com/zied-jlassi/harmony-ai-framework.git

# Lancer l'installeur sur votre projet (le répertoire cible doit déjà exister)
./harmony-ai-framework/bin/install.sh --full --project-dir /path/to/your/project
```

> **Note** : le package npm publié est **`harmony-ai`**. Il n'y a pas de `harmony init`,
> `harmony doctor`, ni autre CLI `harmony <sous-commande>` — une fois installé, vous
> pilotez Harmony via des slash commands (`/go`, `/harmony`) dans votre assistant IA.

---

## Configuration Post-Installation

### 1. Configurer votre assistant IA

#### Pour Claude Code

**Les hooks sont configurés automatiquement** quand vous installez avec `--full`.
L'installeur les écrit dans `.claude/settings.json` (en sauvegardant tout fichier
existant). Vous n'avez normalement rien à toucher.

L'installation câble sept hooks :

| Phase | Matcher | Hook | Rôle |
|-------|---------|------|------|
| `PreToolUse` | `Edit\|Write` | `aria-detect.sh` | Détection d'accessibilité sur les éditions |
| `PreToolUse` | `Edit\|Write\|Bash` | `rules-enforcer.sh` | **Bloque les commandes destructrices** (`rm -rf /`, fork bombs, `curl\|bash`, secrets…) — s'exécute en premier |
| `PreToolUse` | `Edit\|Write\|Bash` | `guardian-checkpoint.sh` | Garde du contexte story |
| `PreToolUse` | `Edit\|Write\|Bash` | `sentinel-pre.sh` | Vérifie l'historique d'erreurs |
| `PreToolUse` | `Bash` | `supply-chain-guard.sh` | Vérifie les installations de packages |
| `PostToolUse` | `Edit\|Write\|Bash` | `sentinel-post.sh` | Enregistre le résultat / apprend les patterns |
| `PostToolUse` | `Bash\|WebFetch\|WebSearch` | `llm-output-sanitizer.sh` | Assainit la sortie externe |

Si vous avez installé avec `--no-hooks` et voulez les activer plus tard, relancez
`npx harmony-ai --full --force`, ou ajoutez le bloc manuellement à `.claude/settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/aria-detect.sh" }
        ]
      },
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/rules-enforcer.sh" },
          { "type": "command", "command": "bash .harmony/hooks/guardian-checkpoint.sh" },
          { "type": "command", "command": "bash .harmony/hooks/sentinel-pre.sh" }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/supply-chain-guard.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/sentinel-post.sh" }
        ]
      },
      {
        "matcher": "Bash|WebFetch|WebSearch",
        "hooks": [
          { "type": "command", "command": "bash .harmony/hooks/llm-output-sanitizer.sh" }
        ]
      }
    ]
  }
}
```

#### Pour Cursor

Ajoutez à `.cursor/settings.json` :

```json
{
  "harmony": {
    "enabled": true,
    "configPath": ".harmony"
  }
}
```

#### Pour Windsurf

Ajoutez à `.windsurf/config.json` :

```json
{
  "extensions": {
    "harmony": {
      "path": ".harmony"
    }
  }
}
```

### 2. Ajouter à votre CLAUDE.md (ou instructions IA)

Ajoutez ce qui suit au fichier d'instructions IA de votre projet :

```markdown
## Harmony Framework

This project uses the Harmony Framework for structured AI development.

### Guardian Protocol (Always Active)

Before any action, check:
1. What is the user's intent?
2. Consult `.harmony/config/intent-router.json`
3. Verify prerequisites in `${MEMORY_DIR}/workflow-state.json`
4. Route to the appropriate agent

> **Note**: Memory files are stored in IDE-specific locations:
> - Claude Code: `.harmony/local/memory/`
> - Cursor: `.cursor/harmony-memory/`
> - See `.harmony/config/paths.json` for configured path

### Sentinel System (Always Active)

Before risky operations:
1. Check `${MEMORY_DIR}/error-journal.json` for past errors
2. Check `${MEMORY_DIR}/circuit-breaker.json` state
3. Apply learned patterns from `${MEMORY_DIR}/learned-patterns.json`

### HQVF Quality (Phase 4)

Before development:
1. Story must exist
2. UCV must be approved
3. Mark verifications as you implement
```

---

## Structure des Répertoires

Après installation, votre projet contiendra :

```
your-project/
├── .harmony/                    # CORE FRAMEWORK (Read-Only, Shareable)
│   ├── agents/
│   │   ├── guardian.md
│   │   ├── sentinel.md
│   │   ├── analyst.md
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   ├── ai-architect.md
│   │   ├── exploratory-qa.md
│   │   ├── ucv-writer.md
│   │   ├── ucv-validator.md
│   │   ├── ucv-qa.md
│   │   ├── security.md
│   │   ├── rgpd.md
│   │   ├── accessibility.md
│   │   └── pentest.md
│   ├── patterns/
│   │   ├── P-XXX-*.md           # System patterns
│   │   └── cognitive/           # Reasoning patterns
│   │       ├── react.md
│   │       └── reflection.md
│   ├── config/
│   │   ├── harmony.config.js
│   │   ├── intent-router.json
│   │   └── paths.json           # IDE-specific paths configuration
│   ├── docs/
│   │   └── ...
│   ├── hooks/
│   │   ├── guardian-checkpoint.sh
│   │   ├── sentinel-pre.sh
│   │   └── sentinel-post.sh
│   ├── memory/
│   │   └── templates/           # Memory file templates only
│   ├── patterns/
│   │   └── ...
│   ├── rules/
│   │   └── ...
│   ├── templates/
│   │   ├── story.md
│   │   ├── ucv.md
│   │   ├── adr.md
│   │   └── handoff.md
│   └── workflows/
│       └── ...
│
│   └── local/                   # PROJECT DATA (mutable, not read-only)
│       └── memory/              # IDE-specific memory location (Claude Code)
│           ├── error-journal.json
│           ├── circuit-breaker.json
│           ├── workflow-state.json
│           ├── working.json
│           └── learned-patterns.json
│
├── .claude/                     # IDE config (Claude Code)
│   └── settings.json            # Hooks configuration (written by --full)
│
├── docs/
│   └── backlog/
│       ├── epics/
│       └── stories/
└── package.json
```

> **Note d'architecture** : le cœur du framework (`.harmony/`) est read-only et peut être
> partagé/commité. La mémoire spécifique au projet va dans des emplacements propres à l'IDE
> (`.harmony/local/memory/` pour Claude Code).

---

## Configuration

### Configuration de base

Créez ou éditez `.harmony/config/harmony.config.js` :

```javascript
module.exports = {
  // Project settings
  project: {
    name: 'my-awesome-project',
    language: 'en',        // 'en' | 'fr'
    timezone: 'UTC',
  },

  // Phase settings
  workflow: {
    currentPhase: 1,       // 1-5
    autoAdvance: false,    // Auto-advance phases when gates pass
  },

  // Guardian Protocol
  guardian: {
    enabled: true,
    mode: 'warn',          // 'warn' | 'block'
    requireStory: true,    // Require story before coding
    requireUcv: true,      // Require UCV before coding
  },

  // Sentinel System
  sentinel: {
    enabled: true,
    errorMemory: true,
    circuitBreaker: {
      enabled: true,
      maxFailures: 3,
      cooldownMinutes: 5,
      autoReset: false,
    },
    patternLearning: true,
  },

  // HQVF Quality
  hqvf: {
    enabled: true,
    requireApproval: true,
    coverageTarget: 100,   // Percentage
    validators: ['dev', 'test', 'qa'],
  },

  // Memory (path is auto-configured per IDE, see .harmony/config/paths.json)
  memory: {
    // path: auto-detected based on IDE (Claude: .harmony/local/memory/, Cursor: .cursor/harmony-memory/)
    compress: true,
    retention: {
      errors: 90,          // Days to keep errors
      patterns: -1,        // -1 = forever
      sessions: 7,         // Days to keep session data
    },
  },

  // Agents
  agents: {
    core: ['guardian', 'sentinel', 'analyst', 'architect', 'developer', 'tester'],
    specialists: ['ai-architect', 'exploratory-qa', 'ucv-writer', 'ucv-validator'],
    compliance: ['security', 'rgpd', 'accessibility', 'pentest'],
    custom: [],            // Add your custom agents here
  },
};
```

---

## Vérification

L'installeur affiche une vérification système et un résumé de succès en fin
d'exécution. Pour vérifier après coup, confirmez que l'arbre du framework et les hooks
existent :

```bash
# Cœur du framework installé (read-only)
ls .harmony/agents .harmony/hooks .harmony/local/memory

# Hooks câblés dans Claude Code (uniquement avec --full)
cat .claude/settings.json
```

Puis, dans votre assistant IA, lancez les vérifications de santé en direct :

```bash
/go                 # Démarrage de session — charge le contexte et reporte l'état
/harmony            # Menu interactif (30 commandes)
/harmony quick      # Validation rapide (~30s)
```

> Il n'y a pas de CLI `npx harmony doctor` / `npx harmony test`. La vérification et
> l'usage quotidien passent par les slash commands dans l'assistant.

---

## Désinstallation

```bash
# Supprimer le framework et ses données projet
rm -rf .harmony

# Supprimer les hooks qu'Harmony a ajoutés à Claude Code
#   (restaurer une sauvegarde si l'installeur en a fait une, sinon supprimer le fichier)
rm -f .claude/settings.json
mv .claude/settings.json.backup .claude/settings.json 2>/dev/null || true
```

> Harmony est installé *dans* le projet par `npx` ; rien n'est ajouté aux dépendances
> de votre `package.json`, donc il n'y a pas d'étape `npm uninstall`.

---

## Mise à jour

```bash
# Réinstaller la dernière version par-dessus l'existante
npx harmony-ai@latest --full --force
```

`--force` écrase les fichiers read-only du framework tout en préservant vos données
projet dans `.harmony/local/memory/` (la mémoire JSON existante est détectée et conservée).

---

## Dépannage

### `jq`/`yq` introuvable — l'installation s'interrompt

Installez les prérequis (voir le haut de ce guide) et confirmez qu'ils sont dans votre PATH :

```bash
jq --version && yq --version
```

### Échec de vérification des checksums

Le framework vérifie l'intégrité des fichiers à l'installation. S'il signale une
incohérence de checksum, le téléchargement/clone est incomplet ou corrompu — relancez
l'installation, ou pour un clone faites `git pull` pour rafraîchir, puis réessayez avec `--force`.

### Les hooks ne se déclenchent pas

1. Assurez-vous d'avoir installé avec `--full` (pas `--minimal` / `--no-hooks`).
2. Vérifiez que les hooks sont exécutables :
   ```bash
   chmod +x .harmony/hooks/*.sh
   ```
3. Vérifiez que `.claude/settings.json` est un JSON valide et contient les entrées de hooks.
4. Redémarrez votre assistant IA pour qu'il recharge les settings.

### Fichiers de mémoire corrompus

```bash
# Supprimer la mémoire runtime ; elle est ré-initialisée depuis les templates au prochain /go
rm -rf .harmony/local/memory
```

---

## Étapes Suivantes

- [Getting Started](getting-started.md) - Votre premier workflow
- [Core Concepts](concepts.md) - Comprendre l'architecture d'Harmony
- [Agents Guide](../../agents/INDEX.md) - Configurer les agents
