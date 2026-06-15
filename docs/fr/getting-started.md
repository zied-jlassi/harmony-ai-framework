# Démarrer avec Harmony

> **🌐 Langue :** [English](../getting-started.md) · Français

Bienvenue dans Harmony Framework ! Ce guide vous aide à être opérationnel en quelques minutes.

## Prérequis

### Outils requis

| Outil | Rôle | Installation |
|-------|------|--------------|
| **Node.js 18+** | Runtime pour npx | [nodejs.org](https://nodejs.org/) |
| **jq** | Traitement JSON | `sudo apt install jq` / `brew install jq` |
| **yq** | Traitement YAML | `sudo apt install yq` / `brew install yq` |
| **Git** | Contrôle de version | Pré-installé sur la plupart des systèmes |

### Serveurs MCP requis (Anthropic officiels)

Harmony Framework requiert ces serveurs MCP officiels pour l'apprentissage cross-session et le raisonnement structuré :

| Serveur MCP | Package | Rôle |
|-------------|---------|------|
| **server-memory** | `@modelcontextprotocol/server-memory` | Mémoire cross-session, patterns d'erreurs Sentinel |
| **server-sequentialthinking** | `@modelcontextprotocol/server-sequentialthinking` | Décomposition structurée des problèmes |

**Configuration du client MCP** (Claude Desktop / Cursor / VS Code) :

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequentialthinking"]
    }
  }
}
```

### Optionnel

- **Assistant IA** : Claude Code, Cursor, Windsurf, ou similaire
- **Docker** (pour le développement conteneurisé)

## Démarrage rapide

### Étape 1 : Installer Harmony

```bash
# Créer un nouveau projet ou aller dans un projet existant
mkdir my-project && cd my-project

# Installer Harmony dans le projet (une commande, pas d'init séparé)
npx harmony-ai --full
```

### Étape 2 : Ce que `--full` met en place

L'installeur est non-interactif (il utilise des défauts raisonnables). Il :

- crée `.harmony/` (le cœur read-only du framework) dans votre projet ;
- câble les 7 hooks Claude Code dans `.claude/settings.json` ;
- sème la mémoire projet dans `.harmony/local/memory/` ;
- affiche une vérification système et un résumé de succès.

Guardian, Sentinel et HQVF sont activés par défaut ; le projet démarre en
**Discovery (Phase 1)**.

### Étape 3 : Vérifier l'installation

```bash
# Arbre du framework + hooks présents
ls .harmony/agents .harmony/hooks .harmony/local/memory
cat .claude/settings.json

# Puis, dans votre assistant IA :
/go            # Démarrage de session — charge le contexte et reporte l'état
```

## Votre premier workflow

### 1. Commencer par Discovery (Phase 1)

Ouvrez votre assistant IA et tapez naturellement :

```
"analyze the requirements for a user authentication system"
```

Le Guardian d'Harmony va :
1. Détecter l'intention : **ANALYZE**
2. Router vers : **Analyst (Analyst)**
3. Créer un document de brief

### 2. Passer à la Planification (Phase 2)

```
"create the PRD for authentication"
```

Guardian détecte : **PLAN** → Route vers **PM**

### 3. Concevoir l'architecture (Phase 3)

```
"design the authentication architecture"
```

Guardian détecte : **DESIGN** → Route vers **Architect**

### 4. Créer des stories

```
"create stories for the login feature"
```

Guardian détecte : **PLAN_STORY** → Route vers **SM**

### 5. Générer les UCVs

```
"create UCVs for STORY-001"
```

Guardian détecte : **CREATE_UCV** → Route vers **UCV Writer**

### 6. Implémenter (Phase 4)

```
"implement STORY-001"
```

Guardian :
1. Vérifie que la story existe ✅
2. Vérifie que l'UCV est approuvée ✅
3. Route vers **Developer (Developer)**

## Comprendre le workflow

```
┌────────────────────────────────────────────────────────────────┐
│                    HARMONY WORKFLOW                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  You say: "develop the login feature"                          │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      GUARDIAN PROTOCOL          │                           │
│  │  ┌───────────────────────────┐  │                           │
│  │  │ 1. Detect Intent          │  │                           │
│  │  │    → IMPLEMENT            │  │                           │
│  │  │                           │  │                           │
│  │  │ 2. Check Prerequisites    │  │                           │
│  │  │    → Story exists? ✅     │  │                           │
│  │  │    → UCV approved? ✅     │  │                           │
│  │  │                           │  │                           │
│  │  │ 3. Route to Agent         │  │                           │
│  │  │    → Developer (Developer)   │  │                           │
│  │  └───────────────────────────┘  │                           │
│  └─────────────────────────────────┘                           │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      SENTINEL SYSTEM            │                           │
│  │  • Monitors for errors          │                           │
│  │  • Records in error journal     │                           │
│  │  • Triggers circuit breaker     │                           │
│  └─────────────────────────────────┘                           │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      DEVELOPMENT                │                           │
│  │  • Code implementation          │                           │
│  │  • UCV checkboxes marked        │                           │
│  │  • Tests written                │                           │
│  └─────────────────────────────────┘                           │
│                    │                                            │
│                    ▼                                            │
│  ┌─────────────────────────────────┐                           │
│  │      QUALITY GATE               │                           │
│  │  • Exploratory QA explores               │                           │
│  │  • UCV Validator validates UCVs        │                           │
│  │  • Story marked DONE            │                           │
│  └─────────────────────────────────┘                           │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## Commandes en langage naturel

Harmony comprend le langage naturel. Pas besoin de mémoriser des commandes !

| Vous dites... | Harmony comprend... | Agent activé |
|---------------|---------------------|--------------|
| "develop the login" | IMPLEMENT | Developer |
| "fix the bug" | FIX | Developer |
| "create a story" | PLAN_STORY | SM |
| "test the API" | TEST | Tester |
| "explore the UI" | EXPLORE_QA | Exploratory QA |
| "analyze requirements" | ANALYZE | Analyst |
| "design architecture" | DESIGN | Architect |
| "create UCVs" | CREATE_UCV | UCV Writer |
| "validate UCVs" | VALIDATE_UCV | UCV Validator |

## Support multilingue

Harmony comprend l'anglais et le français :

```
English: "develop the scoring system"
French:  "développe le système de scoring"

Both → Intent: IMPLEMENT → Developer Agent
```

## Et ensuite ?

- [Installation Guide](installation.md) - Options d'installation détaillées
- [Core Concepts](concepts.md) - Plongée dans l'architecture d'Harmony
- [Agents Guide](../../agents/INDEX.md) - Découvrir tous les agents disponibles
- [Patterns Reference](../../patterns/INDEX.md) - Bibliothèque de design patterns
- [Prompt Monitor](../../commands/monitor.md) - Tracker et améliorer vos prompts
- [Examples](examples/) - Exemples concrets

### Optionnel : activer le Prompt Monitor

Trackez vos interactions et apprenez à écrire de meilleurs prompts :

```bash
# Installer les dépendances Python (une fois)
pip3 install -r .harmony/tools/prompt-monitor/requirements.txt

# Démarrer le dashboard
harmony monitor start

# Ouvrir dans le navigateur
harmony monitor open   # → http://localhost:8080
```

---

## Dépannage

### « Guardian a bloqué mon opération »

```
🛡️ GUARDIAN CHECKPOINT - VIOLATION
ATTEMPT: Code modification without active story
```

**Solution** : créez ou activez d'abord une story :
```
"create a story for [your feature]"
```

### « Le circuit breaker est OPEN »

```
🛑 SENTINEL: Circuit Breaker OPEN
3 consecutive failures detected
```

**Solution** :
1. Consultez le journal d'erreurs : `.harmony/local/memory/error-journal.json`
2. Corrigez la cause racine
3. Réinitialisez le circuit : `/harmony sentinel --reset`

### « Agent non disponible pour la phase courante »

**Solution** : vérifiez votre phase courante (dans votre assistant) :
```
/harmony            # menu interactif / statut
```

Passez à la phase appropriée ou utilisez un agent autorisé dans votre phase courante.

---

<p align="center">
  <strong>Besoin d'aide ?</strong><br>
  Ouvrez une issue sur GitHub ou rejoignez notre communauté Discord.
</p>
