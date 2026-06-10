# Démarrage Rapide

> **🌐 Langue :** [English](../QUICK-START.md) · Français

> Faites tourner Harmony en 2 minutes.

## 1. Installer (30 sec)

```bash
# Requiert jq + yq — lancer depuis la racine de votre projet
npx harmony-ai --full
```

## 2. Configurer les serveurs MCP (1 min)

Ajoutez à la config de votre assistant IA (Claude Desktop, Cursor, VS Code) :

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

## 3. Commencer à travailler (30 sec)

Ouvrez votre assistant IA et parlez naturellement :

```
"analyze requirements for user authentication"  → Analyst
"design the auth architecture"                  → Architect
"create stories for login feature"              → Scrum Master
"implement STORY-001"                           → Developer
```

Harmony route automatiquement vers le bon agent.

## Vérifier l'installation

```bash
# Arbre du framework + hooks présents
ls .harmony/agents .harmony/hooks .harmony/local/memory
cat .claude/settings.json

# Puis, dans votre assistant IA :
/go            # Démarrage de session — charge le contexte et reporte l'état
```

---

## Que vient-il de se passer ?

Harmony a installé 3 systèmes :

| Système | Rôle |
|---------|------|
| **Guardian** | Route vos requêtes vers le bon agent |
| **Sentinel** | Se souvient des erreurs, évite la répétition |
| **HQVF** | Garantit la qualité via des cas d'usage vérifiables |

---

## Étapes suivantes

- [Getting Started](getting-started.md) - Parcours complet
- [Core Concepts](concepts.md) - Comprendre l'architecture
- [Commands](../../commands/index.md) - Les 30+ commandes

---

**Besoin d'aide ?** Lancez `/harmony` dans votre assistant ou [ouvrez une issue](https://github.com/zied-jlassi/harmony-ai-framework/issues)
