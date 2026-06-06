# Agent Completion Template

> Standard completion message format for all agents.
> Ensures consistent user experience and clear next steps.

---

## Template

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅ {agent_emoji} {agent_name} - Terminé                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Résumé                                                       │
│  {brief_description_of_what_was_done}                           │
│                                                                  │
│  📁 Fichiers modifiés                                           │
│  - {file1}                                                      │
│  - {file2}                                                      │
│  - ...                                                          │
│                                                                  │
│  🎯 Résultat                                                     │
│  {outcome: success/partial/blocked}                             │
│                                                                  │
│  💡 Prochaine étape suggérée                                    │
│  **{next_agent}** - {reason}                                    │
│                                                                  │
│  Pour continuer: "{example_prompt}"                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Fields Explanation

| Field | Description | Required |
|-------|-------------|:--------:|
| `{agent_emoji}` | Agent's emoji | ✅ |
| `{agent_name}` | Agent's display name | ✅ |
| `{brief_description}` | 1-3 sentences summary | ✅ |
| `{file_list}` | Modified/created files | ✅ (if applicable) |
| `{outcome}` | success, partial, blocked | ✅ |
| `{next_agent}` | Suggested next agent | ✅ |
| `{reason}` | Why this agent next | ✅ |
| `{example_prompt}` | Exact prompt to use | ✅ |

---

## Agent-Specific Suggestions

### After Developer

| Situation | Next Agent | Example Prompt |
|-----------|------------|----------------|
| Code complete | Tester | "teste [feature]" |
| Architecture needed | Architect | "conçois [système]" |
| Need review | Review | "review [files]" |

### After Tester

| Situation | Next Agent | Example Prompt |
|-----------|------------|----------------|
| All tests pass | UCV QA | "valide UCVs [story]" |
| Tests fail | Developer | "corrige [errors]" |
| Coverage low | Developer | "ajoute tests [feature]" |

### After Architect

| Situation | Next Agent | Example Prompt |
|-----------|------------|----------------|
| Design complete | Developer | "développe [feature]" |
| Need analysis | Analyst | "analyse [requirements]" |
| Security concern | Security | "audit [design]" |

### After Scrum Master

| Situation | Next Agent | Example Prompt |
|-----------|------------|----------------|
| Story created | UCV Writer | "écris UCVs [story]" |
| Need analysis | Analyst | "analyse [feature]" |
| Sprint planning | Backlog | "planifie sprint" |

### After Analyst

| Situation | Next Agent | Example Prompt |
|-----------|------------|----------------|
| Brief complete | Scrum Master | "crée story [feature]" |
| Architecture needed | Architect | "conçois [système]" |
| More research | Analyst | "continue analyse" |

---

## Critical Rule

```
┌─────────────────────────────────────────────────────────────────┐
│              ⚠️ NE JAMAIS AUTO-DÉCLENCHER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  SUGGÉRER uniquement. L'utilisateur décide de continuer.        │
│                                                                  │
│  ❌ "Je vais maintenant appeler Tester..."                      │
│  ❌ Appeler automatiquement un autre agent                      │
│                                                                  │
│  ✅ "Je vous suggère: teste [feature]"                          │
│  ✅ Terminer et laisser l'utilisateur décider                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Examples by Agent

### Developer Completion

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅ 💻 Developer - Terminé                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Résumé                                                       │
│  Implémentation du composant UserProfile avec validation        │
│  des champs et gestion des erreurs.                             │
│                                                                  │
│  📁 Fichiers modifiés                                           │
│  - src/components/UserProfile.tsx                               │
│  - src/components/UserProfile.test.tsx                          │
│  - src/types/user.ts                                            │
│                                                                  │
│  🎯 Résultat                                                     │
│  SUCCESS - Build et tests passent                               │
│                                                                  │
│  💡 Prochaine étape suggérée                                    │
│  **Tester** - Valider la feature avec tests E2E                 │
│                                                                  │
│  Pour continuer: "teste UserProfile"                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Scrum Master Completion

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅ 📋 Scrum Master - Terminé                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Résumé                                                       │
│  Story US-042 créée avec critères d'acceptance et              │
│  estimation de 5 points.                                        │
│                                                                  │
│  📁 Fichiers créés                                              │
│  - .harmony/local/backlog/stories/US-042-user-profile.md        │
│                                                                  │
│  🎯 Résultat                                                     │
│  SUCCESS - Story prête pour UCVs                                │
│                                                                  │
│  💡 Prochaine étape suggérée                                    │
│  **UCV Writer** - Créer les UCVs pour validation                │
│                                                                  │
│  Pour continuer: "écris UCVs US-042"                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Analyst Mini Completion

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍 Analyst Minimaliste - Terminé                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Compréhension                                               │
│  Vous souhaitez créer rapidement un prototype de               │
│  fonctionnalité de partage social.                              │
│                                                                  │
│  🎯 Intention identifiée                                        │
│  DÉVELOPPER un BOUTON PARTAGE en mode PROTOTYPE                 │
│                                                                  │
│  💡 Agent suggéré                                               │
│  **Developer QuickWin** - Mode rapide sans story                │
│                                                                  │
│  Pour continuer: "quickwin bouton partage social"               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

*Template: Harmony Framework v2.0 - Agent Completion Standard*
