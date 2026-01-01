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

## Validation

### Checklist Agent

- [ ] Frontmatter contient `emoji:`
- [ ] Titre H1 suit le format `# {emoji} {Name} Agent : {greeting}`
- [ ] Greeting est en français
- [ ] Greeting décrit le rôle en 1-2 phrases

---

## Related

- [P-006: Intent Detection](P-006-intent-detection.md)
- [Guardian Agent](../agents/guardian.md)
- [Harmony Agent](../agents/harmony.md)
