<div align="center">

# 🛡️ Harmony Framework

### Un framework de dév IA auto-améliorant pour Claude Code, Cursor & plus

**Routage d'agent intelligent · Mémoire d'erreurs · Quality gates vérifiables**

[![npm version](https://img.shields.io/npm/v/harmony-ai.svg?style=for-the-badge)](https://www.npmjs.com/package/harmony-ai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![GitHub stars](https://img.shields.io/github/stars/zied-jlassi/harmony-ai-framework?style=for-the-badge)](https://github.com/zied-jlassi/harmony-ai-framework/stargazers)

[🚀 Démarrage Rapide](#-démarrage-rapide) • [🧠 Comment ça marche](how-it-works.md) • [📚 Docs](INDEX.md) • [🧩 Patterns](../../patterns/INDEX.md)

**🌐 Langue :** [English](../../README.md) · Français

</div>

---

Harmony est un framework de développement IA qui fait que votre assistant IA **route le
bon agent, se souvient de chaque bug rencontré, et prouve la qualité au lieu de la
supposer** — sur Claude Code, Cursor, Windsurf et plus. Il vit dans *votre* projet et
s'adapte à *votre* code : ne charger que le nécessaire, quand c'est nécessaire.

> **« Les autres frameworks vous aident à construire vite. Harmony vous aide à construire juste. »**

---

## 🏆 Les Trois Piliers

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                      THE THREE PILLARS OF HARMONY                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔒 GUARDIAN           🛡️ SENTINEL           ✅ HQVF                         ║
║   ─────────────        ───────────           ──────────                       ║
║   Intent Detection     Error Memory          Quality Gates                    ║
║   Agent Routing        Circuit Breaker       Use Case Verifiables             ║
║   Workflow Protection  Pattern Learning      Triple Validation                ║
║                                                                               ║
║   "Right agent,        "Never repeat         "Quality you can                 ║
║    right time"          the same bug"         prove, not assume"              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

…mais Harmony, c'est **plus que trois piliers** : 50+ agents spécialisés, spécialités
métier, profils de stack technique, support multi-IDE, gardes de sécurité et chargement
de contexte JIT. 👉 **[Voir le tableau complet → how-it-works.md](how-it-works.md)**

---

## 🚀 Démarrage Rapide

```bash
# Installer (requiert jq + yq)
npx harmony-ai --full

# Commencer à coder
/go                    # Démarrage de session
/harmony               # Menu interactif (30 commandes)
/harmony sentinel      # Dashboard mémoire d'erreurs
```

**30 secondes pour installer. Une vie de temps de debug économisé.**

📖 [Guide d'installation complet →](installation.md) · [Les 30 commandes →](commands.md)

---

## 🤖 La Boucle Auto-Améliorante

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    🔄 THE SELF-IMPROVING LOOP                                 ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║      ┌─────────┐         ┌─────────┐         ┌─────────┐                      ║
║      │   AI    │ ──────► │ HARMONY │ ──────► │   AI    │                      ║
║      │  Makes  │         │ Learns  │         │ Better  │                      ║
║      │ Mistake │         │ Pattern │         │  Next   │                      ║
║      └─────────┘         └─────────┘         └─────────┘                      ║
║                                                                               ║
║   💡 Feed the framework with errors → It feeds you with solutions             ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

Harmony vit dans *votre* projet, apprend *vos* patterns, s'adapte à *votre* style.
Le cycle de contribution, le zéro-perte-de-contexte entre sessions (UCVs), et le
chargement de contexte JIT sont tous détaillés ici 👉 **[how-it-works.md](how-it-works.md)**

---

## 📊 Ce Qui Nous Différencie

| Fonctionnalité | 🏛️ Traditionnel | 🛡️ Harmony |
|----------------|:---------------:|:----------:|
| 🧠 Mémoire d'erreurs | ❌ Repartir de zéro à chaque fois | ✅ Apprend des erreurs |
| 🔄 Circuit Breaker | ❌ Répéter les échecs sans fin | ✅ S'arrête après 3 échecs |
| 🎯 Détection d'intention | ❌ Sélection manuelle d'agent | ✅ Auto-routage |
| ✅ Quality Gates | ❌ « Ça marche » = terminé | ✅ Triple validation (DEV+TEST+QA) |
| 💾 Persistance de contexte | ❌ Perdu entre les sessions | ✅ Mémoire 3 niveaux |
| 📈 Apprentissage de patterns | ❌ Pas d'apprentissage | ✅ Devient plus intelligent avec le temps |
| 🛡️ Gardes de sécurité | ❌ Confiance aveugle | ✅ Filtrage supply-chain + injection |

---

## 🔌 Fonctionne Partout

| Tout IDE | Toute Stack | Toute Taille d'Équipe |
|----------|-------------|-----------------------|
| Claude Code 🟢 · Cursor · Windsurf · Continue · Cody | TypeScript · Python · Go · Rust · React · Node · Django | Solo → Enterprise (500+) |

🎯 **Auto-détection** : les profils & spécialités s'activent depuis le contexte de votre
projet — et ils sont **portables** (pas liés à Harmony, pas verrouillés à un IDE).
👉 [Support IDE, profils & spécialités →](how-it-works.md#4--fonctionne-partout)

---

## 🛡️ Gardes de Sécurité

Des gardes qui filtrent ce qui s'exécute, ce qui entre, et ce qui s'installe — et qui le
**disent à voix haute** quand ils se déclenchent :

| Garde | Défaut | Protège contre |
|-------|:------:|----------------|
| **rules-enforcer** | ✅ actif | Commandes destructrices (`rm -rf /`, `DROP DATABASE`, fork bombs), injection shell (`curl \| bash`), secrets écrits dans des fichiers |
| **supply-chain-guard** | ✅ actif | Packages vulnérables / typosquattés, serveurs MCP non pinnés, packages en période de quarantaine, lock files manquants |
| **llm-output-sanitizer** | ✅ actif | Injection de prompt, exfiltration de données, Unicode caché, secrets fuités dans le contenu **externe** |

Chaque passage affiche une preuve visible (`🛡️ Rules: clean — no interdiction`) ; un
blocage stoppe l'action avec sa raison. Coupez à tout moment avec `HARMONY_HOOK_UI=off`.

```bash
/hf:security:guards status     # Voir l'état actuel
/hf:security:guards off        # Désactiver supply-chain + sanitizer (zéro impact perf)
```

> ⚠️ **Défense en profondeur, pas une solution miracle.** Détection à base de patterns —
> gardez-la à jour et combinez toujours avec une revue humaine. 📖 [Doc Security Guards →](security-guards.md)

---

## 📋 Prérequis

| Outil | Version | Requis ? |
|-------|---------|----------|
| **Node.js** | v18+ | ✅ Runtime (npx) |
| **Bash** | 4.0+ | ✅ (macOS : `brew install bash`) |
| **jq** | 1.6+ | ✅ Traitement JSON |
| **yq** | v4+ (mikefarah) | ✅ Traitement YAML |
| **Bun** / **Python 3.8+** | latest / 3.8+ | ⚪ Optionnel (vitesse / Prompt Monitor) |

📖 [Setup détaillé & vérification →](installation.md)

---

## 📚 Documentation

| 📖 Guide | Description |
|----------|-------------|
| [🚀 Getting Started](getting-started.md) | Tutoriel de 5 minutes |
| [🧠 How It Works](how-it-works.md) | Le tableau complet — diagrammes, flux, JIT, UCVs |
| [💡 Core Concepts](concepts.md) | Les trois piliers expliqués |
| [🏗️ Architecture](architecture.md) | Plongée technique |
| [⌨️ Commands](commands.md) | Les 30 commandes |
| [🤖 Agents](agents.md) | L'écosystème d'agents |
| [📈 Impact & ROI](enterprise.md) | Gains estimés (basés sur l'expérience réelle) |

---

## 💬 Ce Que Nous Avons Vécu en Dogfoodant Harmony

> *Ce sont nos propres observations en construisant Harmony avec Harmony — votre vécu variera.*

- **Les bugs récurrents ont fortement chuté** une fois que Sentinel a commencé à se souvenir des erreurs passées.
- **Le temps de debug sur les problèmes connus** est passé d'environ 10 min à moins d'une minute.
- **« Ça marche sur ma machine »** a cessé d'exister grâce à la triple validation (DEV+TEST+QA).
- **La confusion d'agents** a disparu avec l'auto-routage de Guardian.

📈 Estimations détaillées (économies de tokens, projections temps/coût) — clairement
étiquetées comme des estimations basées sur l'expérience — dans **[enterprise.md](enterprise.md)**.

---

## 🤝 Communauté

[Signaler des bugs](https://github.com/zied-jlassi/harmony-ai-framework/issues) ·
[Idées & aide](https://github.com/zied-jlassi/harmony-ai-framework/discussions)

## 📄 Licence

Publié sous [Licence MIT](../../LICENSE) — SPDX : `MIT`.

© 2025 Harmony AI Team. Utilisez-le partout — contribuez en retour si vous le pouvez.

## 🏢 Enterprise & Consulting IA

Besoin d'un déploiement en production avec la **sécurité des données comme priorité
absolue** ? Intégration multi-env sécurisée, optimisation des coûts LLM, agents
personnalisés, durcissement de la sécurité des données.
📬 [Détails & contact →](enterprise.md)

---

<div align="center">

### 🛡️ Arrêtez de répéter les bugs. Commencez à construire juste.

[Commencer](getting-started.md) • [Comment ça marche](how-it-works.md) • [Docs](INDEX.md)

⭐ **Mettez une étoile si Harmony vous fait gagner du temps !**

</div>
