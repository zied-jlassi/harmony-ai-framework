# Instruction Resilience Architecture

> **🌐 Langue :** [English](../../architecture/instruction-resilience.md) · Français

Harmony sépare ses instructions critiques du fichier `CLAUDE.md` détenu par l'utilisateur,
afin que les protocoles du framework continuent de fonctionner même si `CLAUDE.md` est
modifié, tronqué ou affecté par un conflit de fusion. Ce document explique l'architecture
et les raisons de sa conception.

> Décision d'architecture : cette architecture est archivée sous forme d'ADR dans le dossier
> interne `research/`. Cette page est la description publique, telle qu'implémentée.

---

## Contexte

Lorsque Harmony est installé, il a besoin que ses instructions critiques soient disponibles
de manière fiable :

- Protocole d'annonce des agents (P-010)
- Routage Guardian
- Gestion des erreurs Sentinel
- Limites de sécurité

Injecter tout cela directement dans `CLAUDE.md` est fragile :

1. **Fragilité** : si l'utilisateur modifie `CLAUDE.md`, le comportement du framework peut casser
2. **Conflits de mise à jour** : les mises à jour du framework peuvent corrompre le contenu utilisateur
3. **Aucun repli** : si l'en-tête est endommagé, toute l'application des protocoles échoue
4. **Conflits de fusion** : conflits git lorsque plusieurs outils modifient `CLAUDE.md`
5. **Aucune protection** : les instructions peuvent être supprimées par accident

Si le protocole d'annonce P-010 n'est pas respecté, c'est généralement parce que les
instructions de `CLAUDE.md` ont été modifiées, tronquées lors d'une mise à jour, ou n'ont pas
été chargées correctement.

---

## Architecture

Harmony adopte une **architecture d'instructions hiérarchique et résiliente** : un pointeur
minimal dans `CLAUDE.md`, les véritables instructions résidant sous `.harmony/`.

```
BEFORE (Fragile):
┌─────────────────────────────────────┐
│ CLAUDE.md                           │
│ ├── Harmony header (50+ lines)     │◄── Can be corrupted
│ ├── Framework instructions         │◄── Can be modified
│ └── User content                   │
└─────────────────────────────────────┘

AFTER (Resilient):
┌─────────────────────────────────────┐
│ CLAUDE.md (minimal - 10 lines)      │
│ └── Pointer to .harmony/            │◄── Safe to modify
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ .harmony/INSTRUCTIONS.md            │
│ ├── P-010 Agent Announcement       │◄── Protected
│ ├── Guardian Protocol              │◄── Checksummed
│ ├── Sentinel Rules                 │◄── Versioned
│ └── All critical instructions      │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ .harmony/AGENTS.md (optional)       │
│ └── OpenAI Codex / Cursor compat   │◄── Multi-tool
└─────────────────────────────────────┘
```

---

## Implémentation

### 1. En-tête minimal de CLAUDE.md

```markdown
## 🛡️ HARMONY FRAMEWORK

> **IMPORTANT**: Read `.harmony/INSTRUCTIONS.md` for all framework protocols.
> **CONFIG**: `HARMONY_DIR=.harmony`
> **READ-ONLY**: This section is auto-generated. Run `/harmony init` to repair.
```

### 2. Instructions complètes dans .harmony/INSTRUCTIONS.md

Contient tous les protocoles critiques :

- Annonce des agents P-010 (OBLIGATOIRE)
- Protocole Guardian (détection d'intent, routage)
- Système Sentinel (mémoire des erreurs, circuit breaker)
- Portes qualité HQVF
- Limites de sécurité
- Formats de salutation des agents

### 3. AGENTS.md pour la compatibilité multi-outils

```markdown
# AGENTS.md - Harmony Framework

Compatible with: OpenAI Codex, Cursor, GitHub Copilot, JetBrains AI

[Same instructions as INSTRUCTIONS.md]
```

### 4. Protection par checksum

```bash
# .harmony/checksums.sha256
sha256sum INSTRUCTIONS.md AGENTS.md > checksums.sha256
```

### 5. Mécanisme d'auto-réparation

```bash
# /harmony init --repair
# Regenerates INSTRUCTIONS.md from framework source
# Restores CLAUDE.md header if corrupted
```

---

## Conséquences

### Positives

1. **CLAUDE.md modifiable sans risque** : les utilisateurs peuvent ajouter librement leur propre contenu
2. **Pas de conflits de mise à jour** : les mises à jour du framework ne touchent que `.harmony/`
3. **Repli garanti** : les instructions sont toujours disponibles dans `.harmony/`
4. **Support multi-outils** : fonctionne avec Cursor, Codex, Copilot via AGENTS.md
5. **Versionné** : les instructions sont versionnées avec le framework
6. **Protégé par checksum** : détecte les altérations ou la corruption

### Négatives

1. **Fichier supplémentaire à charger** : Claude doit lire `.harmony/INSTRUCTIONS.md`
2. **Migration nécessaire** : les installations existantes ont besoin d'une mise à jour

### Neutres

1. **Chargement hiérarchique** : correspond aux pratiques du secteur (OpenAI, Anthropic)

---

## Sources

| Source | Pattern | Pertinence |
|--------|---------|-----------|
| [Anthropic Blog](https://claude.com/blog/using-claude-md-files) | "Break up into separate files and reference them" | Recommandation directe |
| [Anthropic Engineering](https://www.anthropic.com/engineering/claude-code-best-practices) | Hierarchical loading, `.local.md` variants | Bonne pratique |
| [OpenAI Codex](https://github.com/letta-ai/agent-file) | `AGENTS.md` with fallback chain | Compatibilité multi-outils |

---

## Liens connexes

- [P-010 Agent Announcement](../../../patterns/P-010-agent-announcement.md)
- [Guardian Protocol](../../../agents/guardian.md)
- [Installation Script](../../../bin/install.sh)
