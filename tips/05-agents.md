# Tip: Invoquer les agents

Harmony inclut 42 agents spécialisés. Pour les invoquer :

```bash
# Référencer directement le fichier agent
@.harmony/agents/analyst.md "Analyser les besoins"
@.harmony/agents/developer.md STORY-XXX
@.harmony/agents/architect.md "Designer l'architecture"
```

Chaque phase a son agent recommandé :

| Phase | Agent |
|-------|-------|
| 1 - Discovery | analyst.md |
| 2 - Planning | product-manager.md |
| 3 - Solutioning | architect.md |
| 4 - Implementation | developer.md |

> Ce tip ne s'affichera plus après cette session.
