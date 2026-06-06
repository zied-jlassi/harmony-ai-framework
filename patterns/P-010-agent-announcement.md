# Pattern P-010: Agent Announcement

> **Mécanisme d'annonce automatique des agents à l'invocation.**

---

## Metadata

| Field | Value |
|-------|-------|
| **Pattern ID** | P-010 |
| **Category** | User Experience |
| **Status** | Active |

---

## Purpose

Ce pattern définit comment chaque agent s'annonce automatiquement quand il est invoqué, créant une expérience utilisateur cohérente et identifiable.

---

## Format d'Annonce

Chaque agent utilise le titre H1 de son fichier markdown comme annonce:

```
# {emoji} {Agent Name} : {greeting}
```

### Exemples

```markdown
# 📊 Analyst Agent : Je suis l'Analyst, expert en exigences. Je transforme vos idées en spécifications claires et actionnables.

# 🏗️ Architect Agent : Je suis l'Architect, expert en conception système. Je transforme vos besoins en architectures robustes et évolutives.

# 💻 Developer Agent : Je suis le Developer, expert en implémentation. Je transforme vos spécifications en code production de qualité.
```

---

## Implémentation

### 1. Structure du Frontmatter

Chaque agent DOIT avoir un champ `emoji` dans son frontmatter:

```yaml
---
name: "analyst"
displayName: "Business Analyst"
emoji: "📊"
description: "Requirements expert..."
---
```

### 2. Format du Titre H1

Le titre H1 DOIT suivre ce format:

```markdown
# {emoji} {displayName} Agent : {greeting en français}
```

### 3. Extraction Automatique

Pour extraire l'annonce d'un agent:

```bash
# Bash - Extraire le titre H1
head -50 agents/analyst.md | grep "^# " | head -1
```

```javascript
// JavaScript - Parser le frontmatter et titre
function getAgentAnnouncement(agentPath) {
  const content = fs.readFileSync(agentPath, 'utf-8');
  const titleMatch = content.match(/^# (.+)$/m);
  return titleMatch ? titleMatch[1] : null;
}
```

---

## Intégration avec Workflows

### Workflow d'Invocation

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT INVOCATION FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. USER invoque agent (ex: /analyst)                           │
│     │                                                            │
│     ▼                                                            │
│  2. GUARDIAN détecte l'intent                                   │
│     │                                                            │
│     ▼                                                            │
│  3. LOAD agent file                                             │
│     │                                                            │
│     ▼                                                            │
│  4. EXTRACT titre H1 (annonce)                                  │
│     │                                                            │
│     ▼                                                            │
│  5. DISPLAY annonce à l'utilisateur                             │
│     │                                                            │
│     │   ┌─────────────────────────────────────────────┐         │
│     │   │ 📊 Analyst Agent : Je suis l'Analyst,      │         │
│     │   │ expert en exigences. Je transforme vos     │         │
│     │   │ idées en spécifications claires.           │         │
│     │   └─────────────────────────────────────────────┘         │
│     │                                                            │
│     ▼                                                            │
│  6. AGENT commence son travail                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Emojis Standards

| Category | Agent | Emoji |
|----------|-------|-------|
| **Core** | Guardian | 🛡️ |
| | Sentinel | 👁️ |
| | Analyst | 📊 |
| | Architect | 🏗️ |
| | Developer | 💻 |
| | Tester | 🧪 |
| **Specialists** | SM | 📋 |
| | UCV Writer | 📝 |
| | UCV Validator | ✅ |
| | Exploratory QA | 🔍 |
| | AI Architect | 🧠 |
| **Utility** | Harmony | 🎵 |
| | Atlas | 🏛️ |
| | Supervisor | 👔 |
| | Party | 🎉 |
| | Backlog | 📦 |
| | Quick-Flow | ⚡ |
| | Review | 👀 |
| **Compliance** | Security | 🔐 |
| | RGPD | ⚖️ |
| | Pentest | 🔓 |
| **Creative** | UX Designer | 🎨 |
| | Tech Writer | ✍️ |
| | Product Manager | 📈 |
| **AI Sub-Agents** | RAG Architect | 📚 |
| | Memory Architect | 🗄️ |
| | Orchestration Architect | 🎭 |
| | Observability Architect | 📈 |
| | GraphRAG Architect | 🕸️ |
| | Safety Architect | 🔒 |

---

## Hook d'Annonce (Optionnel)

Pour automatiser l'affichage, un hook peut être ajouté:

```bash
#!/bin/bash
# .claude/hooks/agent-announce.sh

AGENT_FILE="$1"

if [[ -f "$AGENT_FILE" ]]; then
  # Extraire le titre H1
  ANNOUNCEMENT=$(head -50 "$AGENT_FILE" | grep "^# " | head -1 | sed 's/^# //')

  if [[ -n "$ANNOUNCEMENT" ]]; then
    echo ""
    echo "● $ANNOUNCEMENT"
    echo ""
  fi
fi
```

---

## R4: 1 Prompt = 1 Agent (STRICT)

> **Règle absolue**: Un prompt utilisateur ne peut déclencher qu'UN SEUL agent.

```
┌─────────────────────────────────────────────────────────────────┐
│              ⛔ RÈGLE ABSOLUE - 1 PROMPT = 1 AGENT              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  POURQUOI:                                                       │
│  - Cadrer Claude au maximum pour meilleures performances        │
│  - Protéger l'application contre les dérives                    │
│  - Éviter le travail "gauche-droite" non contrôlé               │
│  - Responsabilités claires et traçables                         │
│                                                                  │
│  INTERDIT:                                                       │
│  ❌ Agent A qui déclenche automatiquement Agent B               │
│  ❌ Chaînage implicite d'agents                                 │
│  ❌ Mélange de responsabilités dans un prompt                   │
│  ❌ "Je vais maintenant appeler Tester..."                      │
│                                                                  │
│  AUTORISÉ:                                                       │
│  ✅ Suggestion du prochain agent (sans déclenchement)           │
│  ✅ Affichage du Template de Fin avec suggestion                │
│  ✅ Workflow complet si OPT-IN explicite par utilisateur        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Agents Concernés (24)

Tous les agents opérationnels doivent respecter cette règle:

| Catégorie | Agents |
|-----------|--------|
| **Core Dev** | developer, developer-quickwin, architect, database |
| **QA/Test** | tester, exploratory-qa, ucv, review |
| **Design** | designer, ux-designer, narrative-designer |
| **Management** | scrum-master, product-manager, analyst, analyst-mini, backlog |
| **Security** | security, pentest, rgpd, accessibility |
| **Infra** | atlas, supervisor |
| **Docs** | tech-writer |
| **Special** | quick-flow, quick-flow-solo, party |

**Exclus** (agents système): guardian, harmony, sentinel

---

## R5: Template de Fin (OBLIGATOIRE)

> **Chaque agent DOIT afficher un template de fin standardisé.**

### Format Standard

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅ {emoji} {agent_name} - Terminé                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Résumé                                                       │
│  {description de ce qui a été fait}                             │
│                                                                  │
│  📁 Fichiers modifiés                                           │
│  - {fichier1}                                                   │
│  - {fichier2}                                                   │
│                                                                  │
│  🎯 Résultat                                                     │
│  {SUCCESS/PARTIAL/BLOCKED - détails}                            │
│                                                                  │
│  💡 Prochaine étape suggérée                                    │
│  **{next_agent}** - {raison}                                    │
│                                                                  │
│  Pour continuer: "{example_prompt}"                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Règles du Template

| Règle | Description |
|-------|-------------|
| **TF-1** | Afficher TOUJOURS à la fin du travail |
| **TF-2** | Inclure suggestion de prochain agent |
| **TF-3** | NE JAMAIS déclencher l'agent suggéré |
| **TF-4** | Donner un exemple de prompt exact |
| **TF-5** | Indiquer le status (success/partial/blocked) |

### Mapping Suggestions

| Agent Qui Termine | Suggestion Typique | Exemple Prompt |
|-------------------|-------------------|----------------|
| Developer | Tester | "teste {story}" |
| Scrum Master | UCV Writer | "écris UCVs {story}" |
| Analyst | Scrum Master | "crée story {feature}" |
| Tester | UCV Validator | "valide UCVs {story}" |
| Architect | Developer | "développe {feature}" |
| Developer QuickWin | Tester | "teste {feature}" |
| Analyst Mini | (selon intent) | (selon clarification) |

---

## Validation

### Checklist Agent

- [ ] Frontmatter contient `emoji:`
- [ ] Titre H1 suit le format `# {emoji} {Name} Agent : {greeting}`
- [ ] Greeting est en français
- [ ] Greeting décrit le rôle en 1-2 phrases
- [ ] Section "Règle Absolue - 1 Prompt = 1 Agent" présente
- [ ] Section "Template de Fin (OBLIGATOIRE)" présente
- [ ] Agent ne déclenche JAMAIS un autre agent automatiquement

---

## Related

- [P-006: Intent Detection](P-006-intent-detection.md)
- [Guardian Agent](../agents/guardian.md)
- [Harmony Agent](../agents/harmony.md)
