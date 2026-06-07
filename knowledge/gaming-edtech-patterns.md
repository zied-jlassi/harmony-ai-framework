# Gaming / EdTech Patterns — Industry Benchmark

> Shared knowledge document referenced by the gaming branches (architecture, developer, designer, scrum-master).
> **Source**: cross-platform analysis (Synthesis, Prodigy, DragonBox, Khan Academy Kids, SplashLearn, Duolingo).

EdTech games combine learning science with game design. The patterns below capture
architecture, content, and pedagogy decisions proven across leading platforms.

## Architecture Patterns EdTech

| Pattern | Source | Architectural decision |
|---------|--------|------------------------|
| **Real-time Adaptation** | Synthesis | Event-driven architecture for adaptation < 500ms |
| **Offline Learning** | Khan Academy | IndexedDB + Service Worker, deferred sync |
| **Content Versioning** | Duolingo | CDN + manifest versioning + delta updates |
| **Multi-tenant Schools** | SplashLearn | Sharding per school, data isolation |
| **Analytics Pipeline** | All | Event streaming → processing → storage |

## ADR Template (EdTech)

```markdown
# ADR-XXX: [EdTech Pattern]

## Context EdTech
Child/education-specific constraints:
- Variable connectivity (school, home, transport)
- Diverse devices (school tablets are often old)
- Children's data protection (GDPR/COPPA — sensitive data)
- Critical performance (limited attention span)

## Decision
[Chosen architecture with EdTech justification]

## EdTech Considerations
- Offline-first: [YES/NO] — why?
- Age-appropriate: [target age range]
- Teacher dashboard: [monitoring needs]
- Parental controls: [integration]
```

## Adaptive Learning Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                ADAPTIVE LEARNING ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    LEARNER PROFILE                      │    │
│  │  ├── knowledge_state: Map<Concept, Mastery>            │    │
│  │  ├── learning_style: 'visual' | 'auditory' | 'kinetic' │    │
│  │  ├── pace: 'slow' | 'normal' | 'fast'                  │    │
│  │  └── accessibility: AccessibilityConfig                 │    │
│  └────────────────────────────────────────────────────────┘    │
│                            ▼                                     │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                 DIFFICULTY ENGINE                        │    │
│  │  Algorithm: Bayesian Knowledge Tracing (BKT)            │    │
│  │  ├── P(L) = probability of mastery                      │    │
│  │  ├── P(T) = probability of transition (learning)        │    │
│  │  ├── P(G) = probability of guess                        │    │
│  │  └── P(S) = probability of slip (error despite mastery) │    │
│  └────────────────────────────────────────────────────────┘    │
│                            ▼                                     │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                 CONTENT SELECTION                        │    │
│  │  Zone of Proximal Development (Vygotsky)                │    │
│  │  Target: 70-85% success rate                            │    │
│  │  ├── Too easy: < 70% → increase difficulty              │    │
│  │  ├── Optimal: 70-85% → maintain                         │    │
│  │  └── Too hard: > 85% failures → decrease + scaffold     │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Evidence-based design principles (2025 research)

Six core principles recur across recent educational-game research:

1. **Clear goal definition** — every activity maps to an explicit learning objective.
2. **Interaction diversity** — vary mechanics to sustain attention and reach different learners.
3. **Contextual authenticity** — situate skills in real-world scenarios for transfer.
4. **Immediate scaffolding & explanatory feedback** — correct *and explain*, in the moment.
5. **Dynamically adaptive environment** — difficulty tracks performance in real time.
6. **Safety-by-design for digital well-being** — protect minors; avoid manipulative loops.

### AI-driven personalization (current trend)

- Combining gamification with AI personalization positively affects achievement, motivation, and depth of engagement.
- Prefer **interpretable rule-based** adaptation (auditable thresholds) over opaque models — important for education and for explaining decisions to teachers/parents.
- Common stack: game engine (Unity/Unreal/Godot) + backend adaptation service; keep the difficulty engine explainable (e.g., BKT, threshold rules).

### Multimodal learning

Integrate multiple sensory/cognitive channels (hands-on experimentation + problem-solving) to improve retention and critical thinking.

## Cross-cutting concerns

- **Privacy by design**: minors' data is sensitive — minimize collection, encrypt, honor parental consent (GDPR/COPPA).
- **Accessibility**: design for varied abilities and old/low-power devices from day one.
- **Engagement vs. learning**: optimize for learning outcomes, not just retention; avoid dark patterns with children.

## Sources

- [Enhancing Student Engagement through AI-Driven Adaptive Learning and Gamification (British Journal of Education, 2025)](https://eajournals.org/bje/vol13-issue12-2025/enhancing-student-engagement-through-ai-driven-adaptive-learning-and-gamification/)
- [Evaluating Educational Game Design Through Human–Machine Pair Inspection (MDPI, 2025)](https://www.mdpi.com/2414-4088/9/9/92)
- [Educational game design: game elements for promoting engagement (arXiv)](https://arxiv.org/pdf/1709.09931)
- [The Games for Learning Institute: Design Patterns for Effective Educational Games (GDC Vault)](https://www.gdcvault.com/play/1012682/The-Games-for-Learning-Institute)
