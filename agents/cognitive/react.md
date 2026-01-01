---
name: "react-module"
displayName: "ReAct Module"
description: "Cognitive module: Reasoning + Acting in iterative loop. Used by all agents."
version: "1.0"
category: cognitive-module
---

# Module Cognitif : ReAct (Reasoning + Acting)

**Version :** 1.0
**Type :** Module cognitif transversal

---

## Description

ReAct est un framework qui couple étroitement le raisonnement et l'action dans une boucle itérative. Chaque agent Harmony utilise ce pattern pour prendre des décisions éclairées.

---

## Boucle ReAct

```
┌─────────────────────────────────────────────────────────────────┐
│                        BOUCLE ReAct                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 1. THOUGHT (Réflexion)                                   │    │
│  │    "Quelle est la meilleure approche pour cette tâche?" │    │
│  │    → Analyser le contexte, la mémoire, les patterns     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 2. ACTION (Exécution)                                    │    │
│  │    → Utiliser un outil, générer du code, lire un fichier│    │
│  │    → Actions concrètes basées sur la réflexion          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 3. OBSERVATION (Résultat)                                │    │
│  │    → Analyser le résultat de l'action                   │    │
│  │    → Identifier succès, échecs, informations nouvelles  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                     │
│                     Tâche complète ?                             │
│                      /          \                                │
│                    OUI          NON                              │
│                     ↓            ↓                               │
│                  [FIN]    [Retour THOUGHT]                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implémentation par Agent

### Developer Agent - ReAct
```
THOUGHT: "Je dois créer un endpoint pour les absences.
         Vérifions les patterns existants dans le projet."

ACTION:  Lire .harmony/memory/learned-patterns.json
         Lire un controller existant comme référence

OBSERVATION: "Pattern trouvé: Controller avec @UseGuards(JwtAuthGuard, RolesGuard, SchoolGuard)
              DTO avec validation class-validator
              Service avec Prisma et pagination max 50"

THOUGHT: "J'applique ce pattern pour le controller Absences.
         Je dois aussi vérifier le schema Prisma."

ACTION:  Lire prisma/schema.prisma
         Générer absences.controller.ts selon le pattern

OBSERVATION: "Controller généré. Vérifions la cohérence avec le service."

THOUGHT: "Le controller est prêt, je génère le service correspondant."

ACTION:  Générer absences.service.ts
         Générer DTOs

OBSERVATION: "Tous les fichiers générés. Build à vérifier."

ACTION:  npm run build

OBSERVATION: "Build réussi. Tâche complète."
```

### Architect Agent - ReAct
```
THOUGHT: "On me demande de concevoir le module de gestion des notes.
         Je dois d'abord comprendre les dépendances existantes."

ACTION:  Lire ARCHITECTURE.md
         Lire les modules students, classes, subjects

OBSERVATION: "Le module notes dépend de: Student, Class, Subject, Teacher.
              Il faut une entité Grade avec relations."

THOUGHT: "Je dois décider entre calcul temps réel vs calcul batch
         pour les moyennes. Analysons les contraintes."

ACTION:  Consulter decision-history.json pour patterns similaires
         Évaluer les volumes de données attendus

OBSERVATION: "Volume: ~500 élèves/école, ~10 notes/élève/trimestre
              Calcul temps réel acceptable pour ce volume."

THOUGHT: "Architecture définie. Je crée l'ADR et le design technique."

ACTION:  Créer ADR-006-grades-module.md
         Créer grades-architecture.md avec diagrammes

OBSERVATION: "Documentation créée. Prête pour validation humaine."
```

---

## Format de Trace ReAct

Pour chaque tâche, les agents produisent une trace ReAct :

```json
{
  "task_id": "TASK-001",
  "agent": "developer-agent",
  "react_trace": [
    {
      "step": 1,
      "thought": "Besoin de créer un controller pour les ressources",
      "action": {
        "type": "read_file",
        "target": ".harmony/memory/learned-patterns.json"
      },
      "observation": "Pattern controller trouvé avec Guards"
    },
    {
      "step": 2,
      "thought": "Appliquer le pattern avec SchoolGuard",
      "action": {
        "type": "generate_code",
        "target": "src/resources/resources.controller.ts"
      },
      "observation": "Code généré, 45 lignes"
    },
    {
      "step": 3,
      "thought": "Vérifier que le code compile",
      "action": {
        "type": "run_command",
        "command": "npm run build"
      },
      "observation": "Build successful"
    }
  ],
  "status": "completed",
  "iterations": 3
}
```

---

## Règles d'Application

### 1. Toujours penser avant d'agir
- Jamais d'action sans THOUGHT préalable
- Expliquer le raisonnement

### 2. Observer chaque résultat
- Analyser le succès/échec
- Extraire les informations utiles

### 3. Limiter les itérations
- Maximum 10 itérations par tâche
- Escalade si blocage

### 4. Tracer pour audit
- Chaque boucle ReAct est loggée
- Permet le debugging et l'amélioration

---

## Intégration avec autres modules

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    ReAct    │ ←→ │  Reflection │ ←→ │    LATS     │
│             │     │             │     │             │
│ Action loop │     │ Self-eval   │     │ Tree search │
└─────────────┘     └─────────────┘     └─────────────┘
       ↑                   ↑                   ↑
       └───────────────────┴───────────────────┘
                           │
                    ┌─────────────┐
                    │   MEMORY    │
                    │             │
                    │ Context +   │
                    │ Patterns    │
                    └─────────────┘
```

---

## Références

- [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629)
- [The Landscape of Emerging AI Agent Architectures](https://arxiv.org/html/2404.11584v1)

---

**Dernière mise à jour :** 2025-11-27
