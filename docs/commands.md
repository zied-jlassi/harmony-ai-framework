# Harmony Commands Reference

> Complete reference for all 30 Harmony commands.

---

## Quick Reference

```bash
/go                    # Session kickoff
/harmony               # Interactive menu
```

---

## Commands by Category

### Validation Framework (1-5)

| Command | Description |
|---------|-------------|
| `/harmony full` | Audit complet (~2-5 min) |
| `/harmony quick` | Check rapide (~30s) |
| `/harmony duplicates` | Detection duplicats |
| `/harmony fix` | Proposer corrections |
| `/harmony fix --apply` | Appliquer avec confirmation |
| `/harmony watch` | Pre-commit hook |
| `/harmony watch --install` | Installer hook |
| `/harmony watch --status` | Status hook |

### Rapports (6-7)

| Command | Description |
|---------|-------------|
| `/harmony report` | Matrice coherence |
| `/harmony report --verbose` | Details par categorie |
| `/harmony tokens` | Cout tokens par agent |
| `/harmony tokens --breakdown` | Details par agent |
| `/harmony tokens --optimize` | Suggestions optimisation |

### Validation Specifique (8-10)

| Command | Description |
|---------|-------------|
| `/harmony pipeline` | Coherence pipeline config vs docs |
| `/harmony pipeline --verbose` | Details complets |
| `/harmony pipeline --fix` | Proposer corrections |
| `/harmony hooks` | Validation hooks Claude |
| `/harmony hooks --install` | Installer hooks par defaut |
| `/harmony hooks --status` | Status hooks |
| `/harmony patterns` | Validation patterns |
| `/harmony patterns --fix` | Proposer corrections |

### Synchronisation (11-12)

| Command | Description |
|---------|-------------|
| `/harmony memory` | Sync MCP <-> CLAUDE.md |
| `/harmony memory --diff` | Afficher differences |
| `/harmony claude` | Validation config Claude Code |
| `/harmony claude --update` | MAJ regles (GADER pattern) |
| `/harmony claude --fix` | Proposer corrections |

### Regles Application (13-15)

| Command | Description |
|---------|-------------|
| `/harmony rules` | Audit regles |
| `/harmony rules --usage` | Usage dans le code |
| `/harmony rules --report` | Rapport conformite |

### Harmony Sentinel (16-20)

| Command | Description |
|---------|-------------|
| `/harmony sentinel` | Dashboard health (defaut) |
| `/harmony sentinel --status` | Alias pour status |
| `/harmony sentinel --learn` | Documenter erreur |
| `/harmony sentinel --reset` | Reinitialiser Circuit Breaker |
| `/harmony sentinel --check` | Verification complete |
| `/harmony sentinel --report` | Rapport detaille |

### Knowledge & Profiles (21-23)

| Command | Description |
|---------|-------------|
| `/harmony learn <url>` | Apprendre depuis URL |
| `/harmony profiles` | Lister profiles |
| `/harmony profiles --active` | Afficher actifs |
| `/harmony profiles --add <name>` | Activer profile |
| `/harmony profiles --remove <name>` | Desactiver profile |
| `/harmony specialties` | Lister specialties |
| `/harmony specialties --active` | Afficher actives |
| `/harmony specialties --add <name>` | Activer specialty |
| `/harmony specialties --remove <name>` | Desactiver specialty |

### Integrations (24-25)

| Command | Description |
|---------|-------------|
| `/harmony install <ide>` | Deployer vers IDE |
| `/harmony install --status` | Afficher integrations |

### Qualite HQVF (26-27)

| Command | Description |
|---------|-------------|
| `/harmony ucv <story>` | Creer UCVs |
| `/harmony ucv --validate <story>` | Verifier couverture |

### Framework (28-30)

| Command | Description |
|---------|-------------|
| `/harmony init` | Initialiser Harmony |
| `/harmony upgrade` | Mettre a jour framework |
| `/harmony upgrade --check` | Verifier updates |
| `/harmony export` | Exporter configuration |
| `/harmony export --full` | Export complet avec memory |

---

## Examples

### Daily Workflow

```bash
# Start session
/go

# Quick check before commit
/harmony quick

# Full audit before PR
/harmony full
```

### Error Management

```bash
# View error dashboard
/harmony sentinel

# Document a resolved error
/harmony sentinel --learn

# Reset circuit breaker after diagnosis
/harmony sentinel --reset
```

### Quality Verification

```bash
# Create UCVs for a story
/harmony ucv STORY-042

# Validate coverage
/harmony ucv --validate STORY-042
```
