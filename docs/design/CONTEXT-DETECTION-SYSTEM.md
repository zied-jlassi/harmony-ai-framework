# Harmony Context Detection System

> **Version**: 1.0.0
> **Status**: Design Phase
> **Author**: Harmony Framework Team
> **Date**: 2025-01-01

## Vue d'Ensemble

Le Context Detection System est un sous-systeme intelligent de Harmony qui:

1. **Detecte** automatiquement le contexte projet (gaming, education, e-commerce...)
2. **Configure** les specialties/knowledge/profiles pertinents
3. **Surveille** en continu pendant TOUT le cycle de vie (analyse -> conception -> dev -> deploy)
4. **Informe** l'utilisateur des activations et gaps de conformite
5. **Memorise** les decisions utilisateur (acceptations ET refus)
6. **Responsabilise** l'utilisateur en tracant ses choix

## Probleme Resolu

### Avant (Sans Context Detection)
```
Developpeur: "Implemente un formulaire utilisateur"
Claude: *code le formulaire*
...
6 mois plus tard: Amende RGPD 4% CA
Raison: Pas de consentement, pas de droit a l'effacement
```

### Apres (Avec Context Detection)
```
Utilisateur: "On va creer une plateforme gaming backend + frontend"

ANALYST (Mary) + ARIA:
> Contexte detecte: GAMING
> Plateforme: fullstack (backend + frontend)
>
> Activations recommandees:
> - Specialty: gaming (8 agents specialises)
> - Knowledge: game-mechanics, progression, multiplayer
> - Profile: game-developer
>
> Conformite detectee:
> - RGPD necessaire (joueurs = utilisateurs)
> - Accessibilite recommandee (frontend web)
>
> Voulez-vous activer ces configurations? [Oui/Personnaliser]
```

## Principe Cle: Detection des l'Analyse

> **REGLE D'OR**: Detecter au plus tot = economiser au maximum

```
COUT DES ERREURS PAR PHASE

Phase           │ Cout Relatif │ Exemple
────────────────┼──────────────┼─────────────────────────────────
Analyse         │ 0.5x         │ "Ah on doit prevoir RGPD, notons-le"
Epics/Stories   │ 1x           │ "Ajoutons les AC de conformite"
Architecture    │ 10x          │ Refonte schema, nouvelles entites
Developpement   │ 100x         │ Refactoring massif, nouveaux tests
Production      │ 1000x        │ Hotfix urgent, amende, reputation

DONC: Detection des l'ANALYSE, avant meme les Epics!
```

## Points d'Intervention (CYCLE COMPLET)

```
CYCLE DE VIE PROJET AVEC CONTEXT DETECTION

PHASE 1: ANALYSE (PREMIERE DETECTION)
├── Utilisateur decrit le projet
├── Analyst (Mary) + ARIA analysent
├── Detection contexte metier
├── Proposition activations automatiques
└── Configuration initiale projet

PHASE 2: CONCEPTION
├── Creation Epics → Rappel si refus precedent
├── Creation Stories → Verification patterns
├── Architecture (ADR) → Rappel contraintes
└── Creation UCVs → Injection verifications compliance

PHASE 3: DEVELOPPEMENT
├── Creation fichiers → Analyse patterns code
├── Modification schema → Check conformite
└── Ajout endpoints → Verification securite

PHASE 4: DEPLOIEMENT
├── Pre-deploy → Gate de conformite
└── Post-deploy → Rapport audit
```

## Gestion des Refus Utilisateur

### Principe de Responsabilisation

> **L'utilisateur peut refuser, mais son refus est trace et il reste responsable**

```
WORKFLOW DE REFUS

1. ARIA detecte: "Champs nom, prenom, age → RGPD necessaire"

2. ARIA propose: "Activer RGPD? [Oui/Non]"

3. Utilisateur refuse: "Non"

4. ARIA sauvegarde dans project.yaml:
   dismissed_recommendations:
     - type: "gdpr"
       detected_at: "2025-01-01T10:00:00Z"
       dismissed_by: "analyst"        # Quel agent
       dismissed_at: "2025-01-01T10:05:00Z"
       reason: "user_choice"          # ou "later", "not_applicable"
       patterns_found: ["firstName", "lastName", "age"]
       reminder_count: 0              # Nombre de rappels faits
       dismissed_for_all: false       # Refuse pour tous les agents?

5. ARIA informe:
   "Decision enregistree. Vous serez rappele lors des phases suivantes.
    Pour reactiver: /harmony context --enable gdpr
    Ou editez: .harmony/project.yaml"
```

### Configuration des Rappels

```yaml
# .harmony/project.yaml - Section rappels
reminder_policy:
  default_interval: "each_phase"  # each_phase | once | never

  gdpr:
    reminder_at:
      - analyst: true      # Rappel pendant analyse
      - architect: true    # Rappel pendant architecture
      - epic: true         # Rappel a chaque epic
      - story: true        # Rappel a chaque story
      - ucv: true          # Rappel a chaque UCV
      - dev: false         # Pas pendant dev (trop tard)
    max_reminders: 5       # Apres 5, on arrete (sauf critical)

  accessibility:
    reminder_at:
      - analyst: true
      - architect: true
      - epic: true
      - story: true
      - ucv: true
      - dev: false
    max_reminders: 3
```

### Escalade des Rappels

```
ESCALADE DES RAPPELS

Rappel 1 (Analyst):
"RGPD non active. Donnees personnelles detectees."
→ [Activer] [Plus tard] [Ignorer pour cet agent]

Rappel 2 (Architect):
"Rappel: RGPD toujours non active. Schema contient email, nom."
→ [Activer] [Plus tard] [Ignorer pour cet agent]

Rappel 3 (Epic):
"Rappel: RGPD non active (2 rappels ignores)."
→ [Activer] [Plus tard] [Ignorer pour tous les agents]

Si "Ignorer pour tous les agents":
→ Plus de rappels automatiques
→ Message final:
  "RGPD desactive definitivement.
   VOUS ETES RESPONSABLE de cette decision.
   Pour reactiver:
   - /harmony context --enable gdpr
   - Ou: /harmony context --reset-dismissed gdpr
   - Fichier: .harmony/project.yaml section dismissed_recommendations"
```

### Integration UCV (Clara)

```
CREATION UCV AVEC CONTEXT DETECTION

UCV Writer (Clara) cree UCVs pour STORY-042...

ARIA CONTEXT WATCHER:
├── Story: "Formulaire inscription utilisateur"
├── RGPD Status: DISMISSED (refuse par utilisateur)
├── Rappel #3 sur 5

RAPPEL CONFORMITE

Vous avez refuse RGPD, mais cette story contient:
- Champ email (donnees personnelles)
- Champ nom/prenom (identite)
- Formulaire (consentement necessaire)

UCVs de conformite NON generes:
- UCV: Verification consentement RGPD
- UCV: Lien politique confidentialite
- UCV: Droit a l'effacement

[Activer RGPD maintenant] [Continuer sans] [Ignorer pour tous]

Si "Continuer sans":
→ UCVs generes SANS verifications RGPD
→ Log dans project.yaml:
   ucv_without_compliance:
     - story: "STORY-042"
       missing: ["gdpr"]
       user_acknowledged: true
```

### Format Dismissed Recommendations

```yaml
# .harmony/project.yaml
dismissed_recommendations:
  - id: "dismiss-001"
    type: "gdpr"
    status: "active"                  # active | all_agents | reactivated

    detection:
      first_detected: "2025-01-01T10:00:00Z"
      patterns_found:
        - pattern: "firstName"
          file: "user.entity.ts"
        - pattern: "email"
          file: "user.entity.ts"

    dismissals:
      - agent: "analyst"
        at: "2025-01-01T10:05:00Z"
        reason: "later"
      - agent: "architect"
        at: "2025-01-01T11:00:00Z"
        reason: "not_applicable"
      - agent: "epic"
        at: "2025-01-01T14:00:00Z"
        reason: "dismiss_all"         # Ignore pour tous

    reminder_count: 3
    dismissed_for_all: true
    dismissed_for_all_at: "2025-01-01T14:00:00Z"

    reactivation:
      command: "/harmony context --enable gdpr"
      file: ".harmony/project.yaml"
      agent: "/harmony gdpr --activate"

  - id: "dismiss-002"
    type: "accessibility"
    status: "active"
    # ... meme structure
```

## Commandes de Reactivation

```bash
# Voir tous les refus
/harmony context --list-dismissed

# Reactiver une conformite specifique
/harmony context --enable gdpr
/harmony context --enable accessibility

# Reactiver tout
/harmony context --enable-all

# Reset un refus specifique (recommence les rappels)
/harmony context --reset-dismissed gdpr

# Appeler l'agent specialise pour activation guidee
/harmony gdpr --activate
/harmony accessibility --activate

# Voir le fichier de configuration
/harmony context --show-config
```

## Integration Phase Analyse

### Scenario Type

```
Utilisateur: "On va creer une plateforme de jeux educatifs pour
              enfants, avec backend NestJS et frontend Angular"

ANALYST (Mary):
Je vais analyser votre besoin. ARIA va m'aider a detecter le contexte.

ARIA CONTEXT DETECTION

Analyse de votre description...

CONTEXTES DETECTES:
├── Principal: GAMING (jeux)
├── Secondaire: EDUCATION (educatifs)
└── Audience: ENFANTS (< 13 ans)

ALERTES CONFORMITE:

COPPA/RGPD Enfants (CRITIQUE):
├── Audience < 13 ans detectee
├── Consentement parental OBLIGATOIRE
├── Collecte donnees TRES restreinte
└── Marketing aux enfants INTERDIT

ACTIVATIONS RECOMMANDEES:

Specialties:
├── [x] gaming (8 agents)
├── [x] education (5 agents)
├── [x] compliance (legal, rgpd)
├── [x] accessibility
└── [ ] i18n (multi-langue?)

Voulez-vous:
1. Appliquer toutes les recommandations
2. Personnaliser les activations
3. Refuser (sera trace, rappels actifs)
```

## Architecture

### Composants Principaux

```
+-------------------+     +-------------------+     +-------------------+
|   Agent ARIA      |---->|  project.yaml     |---->|  context-rules    |
| (Context Watcher) |     | (Source Verite)   |     |  (Regles Actives) |
+-------------------+     +-------------------+     +-------------------+
        |                         |                         |
        v                         v                         v
+-------------------+     +-------------------+     +-------------------+
| Pattern Detection |     | Dismissed Tracker |     | Reminder Engine   |
| (Text + Code)     |     | (Refus Logs)      |     | (Rappels Config)  |
+-------------------+     +-------------------+     +-------------------+
```

## Configuration Projet Complete

```yaml
# .harmony/project.yaml - Configuration complete
project:
  name: "mon-projet"
  version: "1.0.0"
  initialized_at: "2025-01-01T10:00:00Z"

context:
  domain: "gaming"
  sub_domain: "casual-games"
  secondary_domains:
    - "education"
  audience:
    type: "children"
    age_restriction: 13

platform:
  type: "fullstack"
  frontend:
    framework: "angular"
    targets: ["web", "pwa"]
  backend:
    framework: "nestjs"
    api_type: "rest"

compliance:
  gdpr:
    enabled: true              # ou false si refuse
    regions: ["EU"]
    level: "strict"
    audience: "children"

  accessibility:
    enabled: true
    wcag_level: "AA"

specialties:
  active:
    - gaming
    - education
    - compliance

# SECTION REFUS
dismissed_recommendations:
  - type: "i18n"
    dismissed_for_all: true
    dismissed_for_all_at: "2025-01-01T10:00:00Z"
    reactivation:
      command: "/harmony context --enable i18n"

reminder_policy:
  gdpr:
    reminder_at:
      analyst: true
      architect: true
      epic: true
      story: true
      ucv: true
    max_reminders: 5

# LOG DES STORIES SANS CONFORMITE
stories_without_compliance:
  - story: "STORY-042"
    missing: ["accessibility"]
    acknowledged_at: "2025-01-02T14:00:00Z"
```

## Regles de Detection

### Contexte Metier

| Pattern Detecte | Contexte | Specialties Auto |
|-----------------|----------|------------------|
| player, score, level | gaming | gaming |
| student, teacher, course | education | education |
| product, cart, checkout | e-commerce | commerce |
| tenant, subscription | saas | multi-tenant |

### Audiences Speciales

| Pattern Detecte | Audience | Conformite Auto |
|-----------------|----------|-----------------|
| enfant, child, kid | children | COPPA, RGPD renforce |
| senior, elderly | elderly | Accessibilite renforcee |

### Conformite Requise

| Pattern Detecte | Niveau | Actions |
|-----------------|--------|---------|
| email, phone, address | MOYEN | RGPD |
| birthDate, age | ELEVE | RGPD + Age verification |
| credit_card, cvv | CRITIQUE | PCI-DSS |
| form, input, button | STANDARD | Accessibilite |

## Skill `/harmony context`

```bash
# Voir config actuelle
/harmony context

# Voir refus
/harmony context --list-dismissed

# Reactiver
/harmony context --enable gdpr
/harmony context --enable-all

# Reset rappels
/harmony context --reset-dismissed gdpr

# Agents specialises
/harmony gdpr --activate
/harmony accessibility --activate
```

## Avantages

| Avantage | Description |
|----------|-------------|
| Detection ultra-precoce | Des la phase Analyse |
| Responsabilisation | Refus traces, utilisateur responsable |
| Rappels intelligents | Escalade puis silence si tout refuse |
| Reactivation facile | Commandes claires, fichier editable |
| Integration UCV | Conformite dans les criteres d'acceptation |
| Tracabilite complete | Tout documente dans project.yaml |

## Scenario Reel: Cas d'Usage Complet

> **Contexte**: Alex developpe une boutique en ligne de vetements.
> Voici le deroulement reel sur plusieurs semaines.

### Semaine 1 - Phase Analyse

```
Alex: "On va creer une boutique e-commerce pour vendre des vetements,
       avec paiement en ligne et livraison. Stack: NestJS + React."

ANALYST (Mary):
Excellent projet! Je lance l'analyse avec detection de contexte...

ARIA CONTEXT DETECTION
──────────────────────

Contexte detecte:
├── Principal: E-COMMERCE (boutique, vetements, paiement)
├── Plateforme: fullstack (NestJS + React)
└── Features: paiement, livraison

Conformite necessaire:
├── RGPD (clients, adresses, historique achats)
├── PCI-DSS (paiements carte bancaire)
└── Accessibilite (site web commercial)

Activations recommandees:
├── Specialty: commerce
├── Specialty: security (paiements)
├── Knowledge: checkout, payments, logistics
└── Profile: e-commerce-developer

[Tout activer] [Personnaliser] [Refuser]

Alex: "Personnaliser"

Quelles activations?
├── [x] commerce - Oui
├── [x] security - Oui
├── [ ] RGPD - "Je connais deja, pas besoin d'aide"
├── [ ] PCI-DSS - "On utilisera Stripe, c'est gere"
├── [x] Accessibilite - Oui
└── [x] Profiles - Oui

ARIA:
Decisions enregistrees.
- RGPD: REPORTE (rappel actif)
- PCI-DSS: REPORTE (rappel actif)
- Vous serez rappele lors des prochaines phases.
```

### Semaine 2 - Creation Epic "Gestion Clients"

```
Alex: "/harmony:workflows:create-epics-stories"

SM (Bob):
Je vais creer les epics. ARIA, un check contextuel?

ARIA CONTEXT WATCHER
────────────────────

RAPPEL #1 - RGPD non active

Vous avez reporte l'activation RGPD.
Cette epic "Gestion des clients" implique:
├── Comptes utilisateurs
├── Adresses de livraison
├── Historique des commandes
└── Preferences marketing

RGPD est fortement recommande pour:
- Droit d'acces aux donnees
- Droit a l'effacement
- Consentement marketing

[Activer maintenant] [Reporter encore] [Ignorer pour Epics]

Alex: "Reporter encore, je gere manuellement"

ARIA:
OK. Rappel programme pour la phase Architecture.
(Rappel 1/5 effectue pour RGPD)
```

### Semaine 2 - Architecture

```
Alex: "/harmony:agents:architect"
      "Designer le schema de la base de donnees"

ARCHITECT (Winston):
Je vais concevoir le schema. ARIA, verification contexte?

ARIA CONTEXT WATCHER
────────────────────

RAPPEL #2 - RGPD non active
RAPPEL #1 - PCI-DSS non active

J'analyse votre schema en cours...

entity Customer {
  email: string           ← Donnee personnelle
  phone: string           ← Donnee personnelle
  firstName: string       ← Donnee personnelle
  lastName: string        ← Donnee personnelle
  birthDate: Date         ← Donnee sensible
  addresses: Address[]    ← Donnees personnelles
}

entity Order {
  customerId: string
  items: OrderItem[]
  paymentMethod: string   ← Donnee sensible
  cardLast4: string       ← Attention PCI-DSS!
}

ALERTES:
├── RGPD: 6 champs de donnees personnelles
└── PCI-DSS: Stockage infos carte detecte

Champs manquants si RGPD:
├── consent_date: DateTime
├── consent_marketing: boolean
├── deletion_requested: boolean
└── data_retention_until: DateTime

Pour PCI-DSS:
├── NE JAMAIS stocker CVV
├── cardLast4 OK si chiffre
├── Utiliser tokenization (Stripe)

[Activer RGPD] [Activer PCI-DSS] [Ignorer Architect] [Ignorer TOUS]

Alex: "Ignorer pour Architect - Stripe gere le PCI-DSS,
       et je connais le RGPD"

ARIA:
Decisions enregistrees.
⚠️ Schema cree SANS verifications automatiques RGPD/PCI-DSS.
Vous etes responsable de la conformite.
(RGPD: Rappel 2/5, PCI-DSS: Rappel 1/5)
```

### Semaine 3 - Creation Stories Checkout

```
Alex: "/harmony:workflows:create-story"
      "Story pour le tunnel de paiement"

SM (Bob):
Je cree la story checkout. ARIA, check contextuel?

ARIA CONTEXT WATCHER
────────────────────

RAPPEL #3 - RGPD non active
RAPPEL #2 - PCI-DSS non active

Story: "Tunnel de paiement"

Cette story implique:
├── Saisie carte bancaire
├── Adresse de facturation
├── Sauvegarde moyen de paiement
└── Historique transactions

C'est une story CRITIQUE pour la conformite!

Rappels precedents ignores:
├── RGPD: 2 rappels
└── PCI-DSS: 1 rappel

[Activer RGPD + PCI-DSS] [Ignorer Stories] [IGNORER POUR TOUS]

Alex: "IGNORER POUR TOUS - j'utilise Stripe, tout est gere!"

ARIA:
⚠️ DECISION FINALE ENREGISTREE ⚠️

RGPD et PCI-DSS DESACTIVES DEFINITIVEMENT par votre choix.
VOUS ETES RESPONSABLE de cette decision.

Cette decision est tracee dans:
.harmony/project.yaml

Pour reactiver a tout moment:
├── /harmony context --enable gdpr
├── /harmony context --enable pci-dss
├── /harmony compliance --activate (guide complet)
└── Editer .harmony/project.yaml

Plus de rappels automatiques.
```

### Semaine 4 - Creation UCV

```
Alex: "/harmony:sub-agents:ucv-writer STORY-089"
      "UCVs pour le formulaire de paiement"

UCV Writer (Clara):
Je genere les UCVs pour "Formulaire paiement"...

ARIA (Mode silencieux - tout ignore):
[Pas de rappel affiche]
[Log dans project.yaml: story_without_compliance]

UCV Writer (Clara):
Voici les UCVs generes:

UC-001: Affichage formulaire paiement
├── V-001: Formulaire Stripe Elements visible
├── V-002: Champs carte, date, CVV presents
└── V-003: Montant total affiche

UC-002: Validation paiement
├── V-004: Erreur si carte invalide
├── V-005: Confirmation apres paiement reussi
└── V-006: Email confirmation envoye

ℹ️ Note: UCVs de conformite NON generes (desactives par utilisateur)
Manquants:
├── UCV: Checkbox sauvegarde carte (consentement)
├── UCV: Lien CGV avant paiement
├── UCV: Option paiement en tant qu'invite
└── UCV: Message securite donnees
```

### Semaine 8 - Audit Pre-Lancement

```
Alex: "On va bientot lancer! Peut-on faire un audit de conformite?"

Claude:
Je lance un audit de conformite...

ARIA COMPLIANCE AUDIT
─────────────────────

STATUT CONFORMITE: ⚠️ RISQUES DETECTES

RGPD (Desactive par utilisateur):
├── ❌ Pas de consentement marketing
├── ❌ Pas de page "Mes donnees"
├── ❌ Pas de fonction suppression compte
├── ❌ Pas de politique confidentialite liee
└── Historique: Ignore 3 fois (analyse, archi, story)

PCI-DSS (Desactive par utilisateur):
├── ⚠️ Stripe utilise (bon choix)
├── ❌ Pas de page securite visible
├── ❌ cardLast4 stocke sans audit
└── Historique: Ignore 2 fois (archi, story)

ACCESSIBILITE (Active):
├── ✅ Labels sur formulaires
├── ⚠️ Contraste a verifier sur 3 pages
└── ⚠️ Navigation clavier incomplete checkout

RISQUE LEGAL:
├── France: Amende CNIL jusqu'a 4% CA
├── EU: RGPD applicable si clients EU
└── Paiement: Responsabilite partagee avec Stripe

RECOMMANDATION: Activer les verifications avant lancement

Alex: "OK, activons RGPD au moins..."

/harmony context --enable gdpr
```

### Semaine 8 - Reactivation RGPD

```
Alex: "/harmony gdpr --activate"

AGENT RGPD:
Je vais vous guider pour la mise en conformite RGPD.

ANALYSE PROJET E-COMMERCE
─────────────────────────

Fichiers a modifier:
├── prisma/schema.prisma
│   └── Ajouter: consent_*, deletion_requested, data_retention
├── src/customer/customer.entity.ts
│   └── Ajouter champs RGPD
├── src/auth/register.dto.ts
│   └── Validation consentement obligatoire
└── frontend/src/pages/account/*
    └── Page "Mes donnees personnelles"

Stories a creer:
├── STORY-NEW: Page "Mes donnees" (RGPD Art. 15)
├── STORY-NEW: Suppression compte (RGPD Art. 17)
├── STORY-NEW: Export donnees JSON (RGPD Art. 20)
├── STORY-NEW: Gestion consentements marketing
└── STORY-NEW: Politique de confidentialite

UCVs a ajouter aux stories existantes:
├── STORY-089: Checkbox "sauvegarder ma carte"
├── STORY-023: Lien politique confidentialite inscription
└── STORY-045: Option "commander sans compte"

Estimation impact: 5 stories, ~3 jours de dev

Voulez-vous que je:
1. Cree toutes les stories manquantes
2. Mette a jour le schema
3. Genere les UCVs de conformite

Alex: "Tout faire!"

[Agent RGPD execute les modifications...]

ARIA:
RGPD reactive avec succes!
- 5 stories creees dans le backlog
- Schema mis a jour
- UCVs de conformite ajoutes

Configuration mise a jour dans .harmony/project.yaml
```

### Fichier project.yaml Final

```yaml
# .harmony/project.yaml apres reactivation partielle
project:
  name: "fashion-store"
  initialized_at: "2025-01-01T10:00:00Z"

context:
  domain: "e-commerce"
  features: ["payments", "shipping", "accounts"]

compliance:
  gdpr:
    enabled: true                    # Reactive!
    activated_at: "2025-02-20T15:00:00Z"
    late_activation: true
  pci_dss:
    enabled: false                   # Toujours desactive
    reason: "stripe_managed"
  accessibility:
    enabled: true
    wcag_level: "AA"

# Decisions tracees
decision_history:
  - type: "gdpr"
    action: "dismissed"
    at: "2025-01-01"
    by: "analyst"

  - type: "gdpr"
    action: "dismissed_all"
    at: "2025-01-15"
    by: "story"

  - type: "gdpr"
    action: "reactivated"
    at: "2025-02-20"
    by: "user_command"
    via: "/harmony gdpr --activate"
    reason: "pre_launch_audit"

  - type: "pci_dss"
    action: "dismissed_all"
    at: "2025-01-15"
    by: "story"
    reason: "stripe_handles_compliance"
    still_dismissed: true

# Stories creees en retard
late_compliance_stories:
  - story: "STORY-120"
    type: "gdpr"
    title: "Page Mes Donnees"
    created_at: "2025-02-20"
    reason: "late_activation"

stories_without_compliance:
  - story: "STORY-089"
    created_without: ["gdpr", "pci_dss"]
    later_fixed: true
    fixed_at: "2025-02-20"
```

---

## Prochaines Etapes

1. [ ] Implementer l'agent ARIA
2. [ ] Enrichir Analyst avec detection contexte
3. [ ] Creer systeme de rappels par agent
4. [ ] Integrer dans UCV Writer (Clara)
5. [ ] Creer skill /harmony context
6. [ ] Creer agents de reactivation (/harmony gdpr, etc.)
7. [ ] Tests et documentation

## Conclusion

Le Context Detection System transforme Harmony en **systeme de gouvernance projet intelligent** qui:
- Detecte le contexte des la premiere interaction
- Propose les bonnes configurations
- Respecte les choix utilisateur (meme les refus)
- Trace tout pour responsabilisation
- Permet la reactivation a tout moment
