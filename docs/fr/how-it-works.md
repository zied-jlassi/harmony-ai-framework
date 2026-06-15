# Comment Fonctionne Harmony

> **🌐 Langue :** [English](../how-it-works.md) · Français

> Une visite guidée de ce qu'Harmony fait réellement — d'une simple requête à un
> projet auto-améliorant qui ne répète jamais ses erreurs.

Harmony fonctionne comme une **boucle**. À chaque requête, il route le bon agent
(**Guardian**), se souvient de chaque erreur rencontrée (**Sentinel**), et *prouve*
le résultat au lieu de le supposer (**HQVF**). Puis il *apprend* de ce que vous avez
fait — pour que la session suivante démarre plus intelligente, charge moins, et évite
les bugs passés.

Cette page parcourt chaque pièce, avec les diagrammes qui la montrent en action.

## Sur cette page

- [1 · Les Trois Piliers](#1--les-trois-piliers) — routage, mémoire d'erreurs, quality gates
- [2 · Le Moteur Auto-Améliorant](#2--le-moteur-auto-améliorant) — comment votre travail devient du savoir
- [3 · Travailler Sans Perdre le Contexte](#3--travailler-sans-perdre-le-contexte) — UCVs & chargement JIT
- [4 · Fonctionne Partout](#4--fonctionne-partout) — IDEs, stacks, profils, spécialités
- [5 · Harmony vs Autres Frameworks](#5--harmony-vs-autres-frameworks)
- [6 · Architecture : Core vs Local](#6--architecture--core-vs-local)

---

## 1 · Les Trois Piliers

La fondation. Trois systèmes qui se déclenchent à chaque requête.

### Guardian — routage intelligent

Chaque requête atteint le bon agent **avec le bon contexte déjà chargé** — avant que
l'agent ne dise un mot. Guardian classifie l'intention, précharge uniquement le savoir
que cette requête nécessite, et passe la main avec une ligne que vous voyez réellement.

```
User: "develop the scoring system"
         |
         v
+--------------------------------------------------+
|  1 . INTENT + CONTEXT  (RouteLLM, config model)  |
|      path:  Claude Code  >  API key  >  keywords |
|      result: intent=IMPLEMENT  flags=[is_game]   |
+--------------------------------------------------+
|  2 . PREREQUISITE CHECK                          |
|      story required for code changes (strict)    |
+--------------------------------------------------+
|  3 . JIT CONTEXT PRELOAD  (<= 15K tokens)        |
|      + gaming knowledge   + matching profiles    |
+--------------------------------------------------+
|  4 . VISIBLE HANDOFF                             |
|      shows the context summary, then activates   |
+--------------------------------------------------+
         |
         v
  Developer activated -- with context, not blind
```

Vous voyez le handoff à chaque fois :

```
📥 Context: agent=developer · intent=IMPLEMENT · flags=[is_game] → +tester · 2 knowledge · ~4k tokens
```

**Le modèle de classification est configurable, et le path d'exécution est résolu par
priorité — jamais codé en dur :**

| Où vous l'exécutez | Ce qui classifie l'intention | Clé API requise ? |
|--------------------|------------------------------|:-----------------:|
| **Claude Code** | un sous-agent sur votre session existante (modèle depuis la config) | **Non** |
| CLI / standalone | appel API direct (Anthropic, OpenAI, …) | Oui |
| Hors-ligne / fallback | matching de mots-clés déterministe | Non |

Le rôle du router est de mapper votre formulation libre sur le vocabulaire connu
d'Harmony — pour que la bonne spécialité, le bon savoir et les bons agents se
déclenchent **sans que vous mainteniez un dictionnaire de synonymes**. Choisissez le
modèle dans `config/routing-rules.yaml` (`router_model`) ; surchargez par projet à tout moment.

### Sentinel — mémoire d'erreurs

Se souvient de chaque échec, stoppe les boucles incontrôlées avec un circuit breaker,
et transforme les bugs en patterns réutilisables.

```
┌─────────────────────────────────────────┐
│         CIRCUIT BREAKER STATE           │
├─────────────────────────────────────────┤
│  State: 🟢 CLOSED                       │
│  Failures: 0/3                          │
│                                         │
│  Error Journal:                         │
│  ├── 45 errors documented               │
│  ├── 42 resolved (93%)                  │
│  └── 0 recurring ✓                      │
│                                         │
│  Learned Patterns: 12                   │
│  Applied: 34 times                      │
└─────────────────────────────────────────┘
```

> *(État de dashboard d'exemple.)*

Et vous n'avez pas besoin d'ouvrir un dashboard pour savoir que ça marche — Sentinel
affiche son état à chaque action protégée :

```
🧠 Sentinel: circuit CLOSED (0/3 failures)
```

**Résultat** : les bugs récurrents chutent fortement — la même erreur n'est pas répétée deux fois.

### HQVF — vérification qualité

Chaque cas d'usage est découpé en vérifications, chacune validée trois fois
(DEV + TEST + QA). 100% de couverture = terminé. Plus de « ça marche sur ma machine ».

```yaml
# STORY-042-UCV.md
story: "User Profile Update"
status: APPROVED

use_cases:
  - id: UC-001
    title: "Open edit modal"
    verifications:
      - id: V-001-1
        description: "Modal centered on screen"
        dev: ✅    # Developer confirms
        test: ✅   # Tester validates
        qa: ✅     # QA approves

coverage: 100% → Story DONE ✓
```

**Résultat** : une définition de « terminé » que vous pouvez prouver, pas supposer.

### Observable by design

Vous ne devriez pas avoir à *croire* que le framework s'est exécuté — vous devriez le
*voir*. Chaque garde et chaque décision de routage s'annonce dans le terminal, au moment
où elle se déclenche :

| Quand | Ce que vous voyez |
|-------|-------------------|
| Un agent est dispatché | `📥 Context: agent=developer · intent=IMPLEMENT · flags=[has_auth] → +security,+rgpd` |
| Avant chaque action protégée | `🧠 Sentinel: circuit CLOSED (0/3 failures)` |
| Une commande risquée est filtrée | `🛡️ Rules: clean — no interdiction` (ou un blocage, avec la raison) |
| Une install de package est vérifiée | `📦 Supply-chain: clean — install screened` |

Pas de dashboards, pas de devinettes — une preuve visible vaut mieux qu'une confiance
aveugle. Trop bavard à votre goût ? Un seul switch le coupe : `HARMONY_HOOK_UI=off`.

---

## 2 · Le Moteur Auto-Améliorant

Les piliers font le travail ; voici ce qui rend Harmony *meilleur* avec le temps.

### Flux de savoir

Harmony transforme tout ce que vous faites en savoir réutilisable :

| Source | → Harmony apprend | → L'IA applique |
|--------|:-----------------:|:---------------:|
| 🐛 Vos bugs | Patterns documentés | Jamais répétés |
| 📚 Articles web | `/harmony learn <url>` | Suggestions contextuelles |
| 🏢 Décisions d'équipe | ADRs stockés | Architecture cohérente |
| 🎯 Règles projet | Profils activés | Appliqués automatiquement |

### Votre style + vos erreurs = votre framework

Harmony vit dans *votre* projet, apprend *vos* patterns, s'adapte à *votre* style.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                 🎭 YOUR STYLE + YOUR ERRORS = YOUR FRAMEWORK                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🧠 LOCAL AI ARCHITECTURE                                                    ║
║   ────────────────────────                                                    ║
║   Harmony lives in YOUR project, learns YOUR patterns, adapts to YOUR style   ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐     ║
║   │                                                                     │     ║
║   │   👨‍💻 Your coding style    →  Profiles auto-generated                │     ║
║   │   ❌ Your errors          →  Patterns auto-created                  │     ║
║   │   ✅ Your fixes           →  Solutions auto-documented              │     ║
║   │   🎯 Your context         →  AI reacts appropriately                │     ║
║   │                                                                     │     ║
║   │   Every developer has a UNIQUE perspective.                         │     ║
║   │   Every mistake is a LEARNING opportunity.                          │     ║
║   │   Every fix enriches the COLLECTIVE knowledge.                      │     ║
║   │                                                                     │     ║
║   └─────────────────────────────────────────────────────────────────────┘     ║
║                                                                               ║
║   💡 No senior needed. No documentation to write. Just code naturally.        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Le cycle de contribution

Un bug que vous corrigez peut devenir un pattern que d'autres réutilisent — de votre
terminal au monde entier.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🔄 FROM YOUR TERMINAL TO THE WORLD                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║       ┌───────────────┐                                                       ║
║       │   YOU CODE    │                                                       ║
║       │   YOUR WAY    │                                                       ║
║       └───────────────┘                                                       ║
║               │                                                               ║
║               ▼                                                               ║
║       ┌───────────────┐     ┌───────────────┐     ┌───────────────┐           ║
║       │  ❌ Error     │────►│  🛡️ Harmony   │────►│  📦 Pattern   │           ║
║       │   Happens     │     │    Learns     │     │   Created     │           ║
║       └───────────────┘     └───────────────┘     └───────┬───────┘           ║
║                                                           │                   ║
║               ┌───────────────────────────────────────────┘                   ║
║               │                                                               ║
║               ▼                                                               ║
║       ┌───────────────┐     ┌───────────────┐     ┌───────────────┐           ║
║       │  📤 Export    │────►│  🌍 Community │────►│  🚀 Published │           ║
║       │   Pattern     │     │    Reviews    │     │   to npm      │           ║
║       └───────────────┘     └───────────────┘     └───────────────┘           ║
║                                                                               ║
║   🎯 Result: Your unique experience helps thousands of developers             ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Action | Effort | Impact | Prêt à publier ? |
|--------|:------:|:------:|:----------------:|
| 🐛 Corriger un bug | **0** (automatique) | Pattern créé | ✅ Exportable |
| 📝 Documenter une erreur | 1 commande | Savoir partagé | ✅ Prêt pour PR |
| 🔄 Partager un pattern | 1 PR | Aider des milliers | ✅ Format revu |
| ⬇️ Récupérer les mises à jour | 1 commande | Accès à tous les patterns | ✅ Auto-merge |

> **🚀 De votre terminal à npm en 3 étapes :**
> `fix bug` → `/harmony sentinel --learn` → `git push` → **Publié !**

---

## 3 · Travailler Sans Perdre le Contexte

Comment Harmony vous permet de travailler des jours sans tout ré-expliquer — tout en
gardant une consommation de tokens basse.

### Zéro perte de contexte (UCVs)

Les Use Case Verifiables jalonnent votre progression pour que toute session reprenne
exactement là où la dernière s'est arrêtée.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                 🔄 WORK FOR DAYS WITHOUT STOPPING                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ❌ TRADITIONAL AI                 ✅ HARMONY + UCVs                         ║
║   ─────────────────                 ──────────────────                        ║
║   Session 1: Starts fresh           Session 1: Creates UCVs                   ║
║   Session 2: Lost context           Session 2: Resumes from V-003-2           ║
║   Session 3: Re-explain everything  Session 3: Knows exactly where we were    ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐     ║
║   │                     📋 USE CASE VERIFIABLES                         │     ║
║   ├─────────────────────────────────────────────────────────────────────┤     ║
║   │                                                                     │     ║
║   │   UC-001: Login Form                                                │     ║
║   │   ├── V-001-1: Email validation ✅ DEV ✅ TEST ✅ QA                │     ║
║   │   ├── V-001-2: Password strength ✅ DEV ✅ TEST ⏳ QA               │     ║
║   │   └── V-001-3: Remember me      ⏳ DEV                              │     ║
║   │                                                                     │     ║
║   │   📍 Context: "Resume from V-001-3, Remember me checkbox"           │     ║
║   │   🎯 AI knows: What's done, what's pending, what's next             │     ║
║   │                                                                     │     ║
║   └─────────────────────────────────────────────────────────────────────┘     ║
║                                                                               ║
║   💡 Chain work across sessions, days, or weeks - NOTHING is lost.            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Sans UCVs | Avec UCVs |
|:---------:|:---------:|
| 🔄 Ré-expliquer le contexte chaque session | ✅ Reprise auto depuis le checkpoint |
| ❓ « Où en étions-nous ? » | ✅ « Continue V-003-2 » |
| 🤷 « Terminé » subjectif | ✅ 100% de couverture vérifiable |
| 😤 « Ça marche sur ma machine » | ✅ Triple validation (DEV+TEST+QA) |

### Chargement de contexte JIT

Au lieu de tout charger à chaque session, Harmony charge **uniquement ce dont la
requête courante a besoin** — gardant les prompts petits et peu coûteux.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    ⚡ JIT CONTEXT LOADING                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Traditional:              Harmony:                                          ║
║   ────────────              ─────────                                         ║
║   Load ALL context          Load ONLY what's needed                           ║
║   Every session             When needed                                       ║
║   ~50K tokens               ~5K tokens                                        ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐     ║
║   │  User: "fix the login bug"                                          │     ║
║   │                    ↓                                                │     ║
║   │  Harmony detects: Intent=FIX, Module=Auth, File=login.ts            │     ║
║   │                    ↓                                                │     ║
║   │  Loads ONLY:                                                        │     ║
║   │  ├── 🔐 Auth patterns (2K tokens)                                   │     ║
║   │  ├── 🐛 Past login errors (1K tokens)                               │     ║
║   │  └── 📄 login.ts context (2K tokens)                                │     ║
║   │                    ↓                                                │     ║
║   │  Total: 5K tokens instead of 50K = 90% savings                      │     ║
║   └─────────────────────────────────────────────────────────────────────┘     ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Type de contexte | Quand chargé | Tokens |
|------------------|:------------:|:------:|
| 🎯 Règles d'intention | À chaque message | ~500 |
| 🔧 Patterns de module | À la détection | ~2K |
| 🐛 Historique d'erreurs | Sur erreur similaire | ~1K |
| 📄 Contexte de fichier | À l'accès fichier | ~2K |
| **Total par requête** | **JIT** | **~5K** |

---

## 4 · Fonctionne Partout

Harmony s'adapte à votre IDE, votre stack et la taille de votre équipe — et le savoir
qu'il construit est portable.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🔄 ADAPTS TO YOUR WORLD                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔌 ANY IDE              🛠️ ANY STACK             🏢 ANY TEAM SIZE           ║
║   ─────────              ───────────              ──────────────              ║
║   Claude Code            TypeScript               Solo dev                    ║
║   Cursor                 Python                   Startup (5)                 ║
║   Windsurf               Go, Rust                 Scale-up (50)               ║
║   Continue               React, Vue               Enterprise (500+)           ║
║   Cody                   Node, Django             Remote teams                ║
║                                                                               ║
║   🎯 AUTO-DETECTION: Profiles activate based on your project context          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Support des IDE

| IDE | Statut | Fonctionnalités |
|-----|:------:|-----------------|
| 🟣 **Claude Code** | 🟢 Complet | Hooks, Memory, MCP, Skills |
| 🔵 **Cursor** | 🟡 Bon | Rules, Personas |
| 🟢 **Windsurf** | 🟡 Bon | Rules |
| 🟠 **Continue** | 🟡 Bon | Assistants, Context |
| 🔴 **Cody** | 🟠 Partiel | Prompts |

### Profils de stack technique (agnostiques au framework)

Les profils & spécialités sont du **savoir portable** — pas lié à Harmony, pas
spécifique à un framework, pas verrouillé à un IDE. Ils vous suivent entre projets et éditeurs.

| Profil | Auto-détecté | Savoir chargé |
|--------|:------------:|---------------|
| 🟦 TypeScript | `.ts`, `.tsx` | Best practices, pièges courants |
| 🐍 Python | `.py` | PEP8, patterns async |
| ⚛️ React | `react` dans deps | Hooks, gestion d'état |
| 🟢 Node.js | `node` dans engines | Event loop, streams |
| 🐳 Docker | `Dockerfile` | Multi-stage, sécurité |
| 🗄️ Prisma | `schema.prisma` | Migrations, relations |

### Spécialités (savoir métier)

| Spécialité | Domaines | Portable ? |
|------------|----------|:----------:|
| 🎮 Gaming | Mécaniques de jeu, leaderboards, progression | ✅ |
| 🏥 Healthcare | HIPAA, données patient, conformité | ✅ |
| 💳 FinTech | PCI-DSS, transactions, audit trails | ✅ |
| 🛒 E-commerce | Panier, paiements, inventaire | ✅ |

> **💡 Vos profils vous suivent** — changez d'IDE, changez de projet, gardez votre savoir.

---

## 5 · Harmony vs Autres Frameworks

| Fonctionnalité | LangChain | CrewAI | AutoGen | Semantic Kernel | **Harmony** |
|----------------|:---------:|:------:|:-------:|:---------------:|:-----------:|
| **Mémoire d'erreurs** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Circuit Breaker** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Détection d'intention** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Quality Gates (UCV)** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Mémoire 3 niveaux** | ❌ | ❌ | Partiel | ❌ | ✅ |
| **Dév basé sur stories** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Multi-IDE** | ❌ | ❌ | ❌ | ❌ | ✅ |
| Multi-Agent | ✅ | ✅ | ✅ | ✅ | ✅ |
| Contrôle de workflow | Partiel | Partiel | Partiel | ✅ | ✅ |
| Production Ready | ✅ | ✅ | ✅ | ✅ | ✅ |

> **Note** : LangChain/CrewAI sont des bibliothèques d'orchestration de code. Harmony est un framework de méthodologie SDLC. Catégories différentes, usages complémentaires.

---

## 6 · Architecture : Core vs Local

> **Principe clé** : séparer le framework (partageable) des données projet (locales).

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE HARMONY                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   .harmony/                    CORE FRAMEWORK (Read-Only)       │
│   ├── agents/                  Agent definitions                │
│   ├── workflows/               Workflow definitions             │
│   ├── templates/               Reusable templates               │
│   ├── patterns/                Documented patterns              │
│   ├── rules/                   Framework rules                  │
│   └── docs/                    Documentation                    │
│                                                                 │
│   .harmony/local/              PROJECT DATA (mutable, local)    │
│   └── memory/                  ← Project-specific data          │
│       ├── working.json         Sprint/Story tracking            │
│       ├── workflow-state.json  Workflow state                   │
│       ├── error-journal.json   Project errors                   │
│       └── learned-patterns.json Discovered patterns             │
│                                                                 │
│   .claude/                     IDE CONFIG (Claude Code)         │
│   ├── commands/                                                 │
│   │   └── harmony.md           /harmony skill                   │
│   └── settings.json            Hooks configuration (7 hooks)    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pourquoi cette séparation ?

| Aspect | Bénéfice |
|--------|----------|
| **Cœur immuable** | Mettre à jour Harmony sans perdre vos données |
| **Données isolées** | Vos sprints/erreurs ne polluent pas le framework |
| **PRs propres** | Contribuer au cœur sans données projet |
| **Multi-projet** | Même version d'Harmony, données indépendantes |

---

## Liens connexes

- [Core Concepts](concepts.md)
- [Architecture](architecture.md)
- [Getting Started](getting-started.md)
