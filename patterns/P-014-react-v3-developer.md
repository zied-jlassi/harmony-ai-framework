# P-014: ReAct V3 Developer Pattern

> **Pattern**: Boucle ReAct V3 spécialisée pour le Developer Agent
> **Usage**: Obligatoire pour CHAQUE tâche d'implémentation

---

## Boucle ReAct V3 DEV

```
┌─────────────────────────────────────────────────────────────────┐
│                    BOUCLE ReAct V3 DEV                          │
│                                                                 │
│  0. CONTEXT DISCOVERY (NOUVEAU - Obligatoire)                │
│     - Lire la story et UCVs                                     │
│     - Lire le code existant: controller, service, DTOs          │
│     - Identifier les patterns établis dans le projet            │
│     - Consulter Error Journal pour erreurs passées              │
│     - NE PAS coder avant d'avoir compris l'existant!            │
│                                                                 │
│  1. REASON (Raisonner)                                       │
│     - Quel est l'objectif technique?                            │
│     - Quels patterns existants dois-je suivre? (trouvés en P0)  │
│     - Quelle stratégie de test adopter?                         │
│                                                                 │
│  2. ACT (Agir)                                                │
│     - Exécuter l'action planifiée                               │
│     - Une seule action atomique à la fois                       │
│     - TDD: Test first si applicable                             │
│                                                                 │
│  3. OBSERVE (Observer)                                       │
│     - Quel est le résultat?                                     │
│     - Build/Tests passent-ils?                                  │
│     - Y a-t-il des warnings/erreurs?                            │
│                                                                 │
│  4. REFLECT (Auto-critique)                                  │
│     - Le code est-il maintenable?                               │
│     - Y a-t-il du code smell?                                   │
│     - Ai-je respecté les patterns identifiés en P0?             │
│                                                                 │
│  5. EVALUATE (Évaluer)                                       │
│     - L'objectif est-il atteint?                                │
│     - Si OUI → Passer à HANDOFF                                 │
│     - Si NON → Retour à REASON                                  │
│                                                                 │
│  6. HANDOFF STRUCTURÉ (Checklist obligatoire)                │
│     - Voir checklist détaillée dans developer.md                │
│     - TOUS les items doivent être validés                       │
│                                                                 │
│  Max 5 itérations. Si échec → Escalader à Architect.            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Règles d'Application

| Règle | Description |
|-------|-------------|
| **R1** | Phase 0 (Context Discovery) est OBLIGATOIRE |
| **R2** | Une seule action atomique par ACT |
| **R3** | TOUJOURS vérifier build/tests après ACT |
| **R4** | Max 5 itérations avant escalade |
| **R5** | HANDOFF seulement si TOUS les checks passent |

---

## Intégration

- **Agent**: Developer
- **Phase**: 4 (Implementation)
- **Prérequis**: Story existe avec UCVs approuvés
- **Sortie**: Code testé + UCVs marqués + Handoff to Tester
