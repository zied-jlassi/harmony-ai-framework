# Specialties

> **Philosophie** : `Agent = Domaine`, `Branch = Contexte/Rôle`.
> Chaque specialty contient un `manifest.yaml` (config + détection automatique) et des
> branches contextuelles dans `branchs/`.

## Domaines disponibles

| Specialty | Branches | Description |
|-----------|----------|-------------|
| [accessibility](accessibility/) | accessibility | Audit WCAG/RGAA/EAA |
| [ai](ai/) | ai-systems | Systèmes IA/LLM (RAG, mémoire, orchestration) |
| [architecture](architecture/) | ai, gaming, mobile, software, web | Conception système & ADRs |
| [creative](creative/) | brainstorm-facilitator, design-thinking-lead, innovation-scout, problem-solver, ux-storyteller, visual-documenter | Idéation & innovation |
| [designer](designer/) | gaming, mobile, sound, web | Design UI/UX |
| [developer](developer/) | gaming, mobile, software, web | Implémentation code |
| [devops](devops/) | builder, devops | CI/CD & infrastructure |
| [i18n](i18n/) | i18n | Internationalisation & localisation |
| [legal](legal/) | legal | Audit légal (RGPD, CGV, accessibilité) |
| [narrative-designer](narrative-designer/) | gaming, mobile, software, web | Narration & storytelling |
| [quality](quality/) | dependency, lint, performance | Qualité de code |
| [scrum-master](scrum-master/) | gaming, mobile, software, web | Gestion agile |
| [security](security/) | auditor, dpo, engineer, researcher | Sécurité & conformité |
| [tester](tester/) | gaming, mobile, software, web | QA & tests |
| [ucv](ucv/) | qa, validator, writer | Use Case Verifiables (HQVF) |
| [ux-designer](ux-designer/) | gaming, mobile, software, web | UX (wireframes, user flows) |

## Structure d'une specialty

```
specialties/<domaine>/
├── manifest.yaml      # Config + règles de détection automatique
└── branchs/
    ├── web.md
    ├── mobile.md
    └── ...            # Une branche par contexte/rôle
```

Voir aussi : [Agents](../agents/INDEX.md) · [Workflows](../workflows/README.md) · [Knowledge](../knowledge/)
