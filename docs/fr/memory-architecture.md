# Architecture Mémoire — Deux Zones

> **🌐 Langue :** [English](../memory-architecture.md) · Français

> **Une règle à retenir :** l'état mutable vit dans **`.harmony/local/`**. Tout le reste sous `.harmony/` est la **base read-only du framework** et est écrasé à chaque mise à jour.
>
> Décision : **ADR-010**. Spécificités sprint/backlog : [working-memory.md](working-memory.md).

Harmony écrit deux types de fichiers très différents. Les garder séparés est ce qui vous permet de **mettre à jour le framework sans perdre votre travail**.

## Les deux zones

```
.harmony/
├── agents/  lib/  patterns/  rules/  hooks/   ← BASE — framework code
├── templates/memory/*.template.json           ← BASE — seed templates (source)
├── docs/                                       ← BASE — framework docs
│   ↑ READ-ONLY · regenerated/overwritten on every install & update
│
└── local/                                      ← USER ZONE — yours, never overwritten
    ├── memory/        ← all mutable state (see below)
    ├── backlog/       ← stories, epics
    └── docs/          ← your briefs, PRDs, architecture
```

| | Base (`.harmony/…`) | Zone utilisateur (`.harmony/local/…`) |
|---|---|---|
| Contient | code framework, templates, docs | état runtime, vos docs, surcharges |
| Cycle de vie | écrasé à la mise à jour | préservé à la mise à jour |
| Vous l'éditez ? | non (régénéré) | oui (ce sont vos données) |

## Ce qui vit dans `local/memory/`

Tout l'état mutable — créé à la demande ou semé à l'installation :

| Fichier | Écrit par | Rôle |
|---------|-----------|------|
| `working.json` | sprint tracker, agents | état sprint/story courant |
| `circuit-breaker.json` | Sentinel | suivi des échecs |
| `error-journal.json` | Sentinel | erreurs apprises |
| `learned-patterns.json` | Sentinel | patterns extraits |
| `workflow-state.json` | Guardian/ARIA | phase, context flags |
| `*-patterns.json`, `reviews.json`, `vulnerabilities.json`, … | agents | apprentissages par agent |

> Il n'y a **pas** de `.harmony/memory/` (base). Tout chemin écrit `${HARMONY_DIR}/local/memory/...` est correct ; un `${HARMONY_DIR}/memory/...` nu est un bug.

## Les logs de sécurité vivent dans `local/logs/security/` (pas `memory/`)

Les logs sont des événements append-only, pas de l'état — ils vont sous `local/logs/`, dans **deux fichiers** par couche de menace (ADR-010) :

| Fichier | Couche | Écrit par | Exemples |
|---------|--------|-----------|----------|
| `local/logs/security/security.log` | **App / poste de travail** | `rules-enforcer.sh`, `supply-chain-guard.sh` | commandes shell dangereuses, combos d'injection shell (`base64 -d \| bash`, `eval $(curl)`), secrets dans des fichiers, typosquats `[SUPPLY]` |
| `local/logs/security/llm-security.log` | **LLM** | `llm-output-sanitizer.sh`, `data-sandbox.sh` (miroir) | artefacts de prompt-injection/jailbreak, URLs d'exfiltration, stéganographie unicode, échecs de validation d'entrée non fiable |

Les deux sont **auto-créés à la première détection** (`mkdir -p`) ; ils n'ont pas besoin d'être semés. `data-sandbox.sh` tient aussi un `local/memory/sandbox-log.json` structuré (schématisé) et miroite une ligne lisible dans `llm-security.log`.

## Comment les fichiers sont créés & mis à jour (pourquoi les updates sont sûrs)

1. **Source de vérité** = `templates/memory/*.template.json` (livré, read-only).
2. À l'installation, `initialize_memory()` lance `merge_memory_file()` par fichier :
   - **fichier absent** (install neuve) → créé depuis le template (état propre) ;
   - **fichier présent** (réinstall / update) → **merge additif** : *vos valeurs existantes l'emportent*, les nouvelles clés du template sont ajoutées.
3. À la réinstallation, si `local/memory/` contient déjà des données, toute la zone `local/` est préservée (ADR-007).

Effet net : une nouvelle version du framework peut ajouter des champs ou des fichiers **sans rien effacer** de ce que vous avez.

```
templates/memory/working.template.json   (source, read-only)
        │  install → merge ("existing values win")
        ▼
local/memory/working.json                 (your state, survives updates)
```

## Règles d'or

1. **Ne jamais** lire ou écrire la mémoire sous la base `.harmony/memory/` — elle n'existe pas. Utiliser `.harmony/local/memory/`.
2. Les fichiers d'instructions d'agent (`.md`) sont du code : leurs chemins mémoire doivent pointer vers `local/memory/`.
3. Pour ajouter un nouveau fichier mémoire, livrer un `templates/memory/<name>.template.json` et le semer via `initialize_memory()`.
4. Ne jamais commiter d'état runtime dans le package (`framework/memory/` n'est pas une source de seed).

## Protection (test)

`tests/e2e/scripts/scenarios/test-scenario-memory-install.sh` lance une **vraie install neuve** et une **simulation d'agent**. Il vérifie : `local/memory/` semé propre, seeds vierges (historique vide, pas de données dev fuitées), la base ne porte aucun état, **chaque référence mémoire d'agent résout sous `local/memory/`**, et les données utilisateur survivent à la réinstallation. Il doit rester vert.

```bash
./tests/e2e/scripts/test.sh /tmp/anything scenario memory-install
```

## Voir aussi

- [working-memory.md](working-memory.md) — détails de la working-memory sprint/backlog
- [context-persistence.md](context-persistence.md) — contexte cross-session
- ADR-010 (research/) — la décision d'architecture et les problèmes qu'elle corrige
