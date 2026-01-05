# Definition of Ready / Definition of Done

> **Usage**: Scrum Master, Developer, Tester, QA - Gates de qualite
> **CRITIQUE**: Aucune story ne passe sans validation complete

---

## Definition of Ready (DoR)

> **Gate d'entree**: Story prete pour le developpement

```
+-------------------------------------------------------------------+
|                    DEFINITION OF READY                              |
+-------------------------------------------------------------------+
|                                                                   |
|  [ ] User story follows INVEST criteria                          |
|  [ ] Acceptance criteria are testable (Given/When/Then)          |
|  [ ] Story is a vertical slice                                   |
|  [ ] UCVs generated and approved                                 |
|  [ ] Dependencies mapped and resolved                            |
|  [ ] Estimation <= 13 points                                     |
|  [ ] Technical approach validated by Architect                   |
|                                                                   |
+-------------------------------------------------------------------+
```

### Checklist DoR

| Critere | Responsable | Validation |
|---------|-------------|------------|
| INVEST 6/6 | Scrum Master | Checklist |
| AC testables | Scrum Master | Gherkin format |
| Vertical slice | Scrum Master | UI+API+DB |
| UCVs approuves | UCV Writer + User | Signature |
| Dependencies | Scrum Master | DAG graph |
| Points <= 13 | Team | Fibonacci |
| Architecture | Architect | Review |

---

## Definition of Done (DoD)

> **Gate de sortie**: Story terminee et livrable

```
+-------------------------------------------------------------------+
|                    DEFINITION OF DONE                               |
+-------------------------------------------------------------------+
|                                                                   |
|  [ ] Code implemented and build OK                               |
|  [ ] Unit tests with 80%+ coverage                               |
|  [ ] E2E tests for critical paths                                |
|  [ ] Code reviewed and approved                                  |
|  [ ] UCVs 100% validated (DEV + TEST + QA)                      |
|  [ ] Exploratory QA completed                                    |
|  [ ] No security vulnerabilities                                 |
|  [ ] Performance within SLAs                                     |
|  [ ] Deployed to staging and verified                            |
|                                                                   |
+-------------------------------------------------------------------+
```

### Checklist DoD

| Critere | Responsable | Validation |
|---------|-------------|------------|
| Build OK | Developer | CI green |
| Coverage 80%+ | Developer | Jest report |
| E2E tests | Tester | Playwright |
| Code review | Architect | PR approved |
| **UCVs DEV** | Developer | Implementation coverage |
| **UCVs TEST** | Tester | Test coverage |
| **UCVs QA** | Exploratory QA | Exploratory coverage |
| **UCVs 100%** | UCV Validator | All 3 validated |
| Security | Developer | No OWASP issues |
| Performance | Developer | SLA metrics |
| Staging | Tester | Smoke tests |

---

## Pipeline de Validation UCVs

```
+-------------------------------------------------------------------+
|                    UCV VALIDATION PIPELINE                          |
+-------------------------------------------------------------------+
|                                                                   |
|  1. DEVELOPER                                                     |
|     +-- Implemente les UCVs (code + tests unitaires)             |
|     +-- Coverage: Implementation                                  |
|                                                                   |
|  2. TESTER                                                        |
|     +-- Valide les UCVs (tests E2E)                              |
|     +-- Coverage: Test automatise                                 |
|                                                                   |
|  3. EXPLORATORY QA                                                |
|     +-- Valide les UCVs (tests exploratoires)                    |
|     +-- Coverage: Edge cases, UX, scenarios reels                 |
|                                                                   |
|  4. UCV VALIDATOR                                                 |
|     +-- Verifie 100% UCVs valides (DEV + TEST + QA)              |
|     +-- Status: PASS (100%) ou FAIL (< 100%)                     |
|                                                                   |
+-------------------------------------------------------------------+
```

### Regles UCV Validation

| Regle | Description | Consequence |
|-------|-------------|-------------|
| **UCV-1** | UCVs DEV obligatoires | Blocker si manquant |
| **UCV-2** | UCVs TEST obligatoires | Blocker si manquant |
| **UCV-3** | UCVs QA obligatoires | Blocker si manquant |
| **UCV-4** | 100% = DEV + TEST + QA | Story DONE uniquement si 100% |

---

## Workflow DoR → DoD

```
Story created
     ↓
[DoR Checklist] ←── FAIL → Retour SM
     ↓ PASS
Status: READY
     ↓
Developer implements (UCVs DEV)
     ↓
Tester validates (UCVs TEST)
     ↓
Exploratory QA explores (UCVs QA)
     ↓
[DoD Checklist] ←── FAIL → Retour Developer/Tester/QA
     ↓ PASS
UCV Validator confirms 100%
     ↓
Status: DONE
```

---

## Agents Impliques

| Agent | Role dans DoR/DoD |
|-------|-------------------|
| **Scrum Master** | Verifie DoR, orchestre |
| **Developer** | Implemente, UCVs DEV |
| **Tester** | Tests E2E, UCVs TEST |
| **Exploratory QA** | Tests exploratoires, UCVs QA |
| **UCV Validator** | Verifie 100% final |
| **Architect** | Review technique |

---

## Integration

- **DoR verifie par**: Scrum Master
- **DoD verifie par**: UCV Validator (avec DEV + TEST + QA)
- **Bloquant**: Aucun merge sans DoD complet (100% UCVs)
