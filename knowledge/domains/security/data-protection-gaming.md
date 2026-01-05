# Data Protection - Gaming Educational Platform

> Protection des donnees pour plateforme de jeux educatifs enfants (RGPD + COPPA)

---

## Principes Fondamentaux

```
+---------------------------------------------------------------+
|          PROTECTION DONNEES ENFANTS - PRINCIPES                |
+---------------------------------------------------------------+
|                                                                |
|  MINEURS = PROTECTION RENFORCEE                                |
|                                                                |
|  1. MINIMISATION                                               |
|     +-- Collecter uniquement le necessaire                    |
|     +-- Pas de donnees "au cas ou"                            |
|     +-- Anonymiser des que possible                           |
|                                                                |
|  2. CONSENTEMENT PARENTAL                                      |
|     +-- Obligatoire pour < 16 ans (France)                    |
|     +-- Verification de l'identite du parent                  |
|     +-- Renouvellement periodique                             |
|                                                                |
|  3. DROIT A L'OUBLI                                            |
|     +-- Suppression sur demande                               |
|     +-- Suppression automatique fin d'annee scolaire          |
|     +-- Exportation des donnees                               |
|                                                                |
|  4. TRANSPARENCE                                               |
|     +-- Information claire aux parents                        |
|     +-- Finalites explicites                                  |
|     +-- Pas de surprise                                       |
|                                                                |
+---------------------------------------------------------------+
```

---

## Donnees Collectees - Matrice de Necessite

| Donnee | Necessaire | Finalite | Retention |
|--------|------------|----------|-----------|
| Prenom | Oui | Personnalisation jeu | Fin annee scolaire |
| Nom | Non | - | Ne pas collecter |
| Date naissance | Oui | Adaptation contenu age | Fin annee scolaire |
| Email enfant | Non | - | Ne pas collecter |
| Ecole | Oui | Isolation donnees | Fin annee scolaire |
| Classe | Oui | Groupement | Fin annee scolaire |
| Scores | Oui | Progression | Fin annee scolaire |
| Temps de jeu | Oui | Analytics pedagogiques | Anonymise apres 30j |
| Adresse IP | Non | - | Ne pas logger |
| Device ID | Non | - | Ne pas collecter |

---

## Anonymisation vs Pseudonymisation

```
+---------------------------------------------------------------+
|          ANONYMISATION vs PSEUDONYMISATION                     |
+---------------------------------------------------------------+
|                                                                |
|  ANONYMISATION (Irreversible)                                  |
|  +-- Donnees NE SONT PLUS personnelles                        |
|  +-- RGPD ne s'applique plus                                  |
|  +-- Utilise pour: statistiques agregees                      |
|                                                                |
|  Exemple Gaming:                                               |
|  "Les eleves de CE2 ont un score moyen de 75%"                |
|  -> Pas d'identification possible                              |
|                                                                |
|  PSEUDONYMISATION (Reversible)                                 |
|  +-- Donnees RESTENT personnelles                             |
|  +-- RGPD s'applique toujours                                 |
|  +-- Utilise pour: suivi progression individuel               |
|                                                                |
|  Exemple Gaming:                                               |
|  "Joueur XYZ123 a termine le niveau 5"                        |
|  -> Reversible avec la cle                                    |
|                                                                |
+---------------------------------------------------------------+
```

### Implementation Pseudonymisation Gaming

```typescript
// services/pseudonymization.service.ts
import { createHmac, randomBytes } from 'crypto';

@Injectable()
export class PseudonymizationService {
  private readonly secret = process.env.PSEUDONYM_SECRET;

  // Generer un pseudonyme stable pour un enfant
  generatePseudonym(studentId: string): string {
    const hmac = createHmac('sha256', this.secret);
    hmac.update(studentId);
    return 'player_' + hmac.digest('hex').slice(0, 12);
  }

  // Pour les logs et analytics
  anonymizeForLogging(data: StudentData): AnonymousData {
    return {
      pseudonym: this.generatePseudonym(data.studentId),
      grade: data.grade, // Garder pour segmentation
      schoolType: data.schoolType,
      // PAS de: nom, prenom, email, date naissance exacte
    };
  }

  // Pour les statistiques agregees (vraie anonymisation)
  anonymizeForStats(students: StudentData[]): AggregatedStats {
    // Verifier k-anonymite (k >= 5)
    const groups = this.groupBy(students, ['grade', 'schoolType']);

    return Object.entries(groups)
      .filter(([_, group]) => group.length >= 5) // k-anonymite
      .map(([key, group]) => ({
        segment: key,
        count: group.length,
        avgScore: this.average(group.map(s => s.score)),
        // Pas de donnees individuelles
      }));
  }
}
```

---

## Stockage Securise

### Chiffrement des Donnees Enfants

```typescript
// services/encryption.service.ts
import { createCipheriv, createDecipheriv, randomBytes, scrypt } from 'crypto';
import { promisify } from 'util';

const scryptAsync = promisify(scrypt);

@Injectable()
export class ChildDataEncryption {
  private readonly algorithm = 'aes-256-gcm';
  private readonly keyLength = 32;
  private readonly ivLength = 16;
  private readonly saltLength = 32;
  private readonly tagLength = 16;

  async encrypt(data: ChildSensitiveData): Promise<EncryptedData> {
    const salt = randomBytes(this.saltLength);
    const iv = randomBytes(this.ivLength);

    const key = await scryptAsync(
      process.env.ENCRYPTION_KEY,
      salt,
      this.keyLength
    ) as Buffer;

    const cipher = createCipheriv(this.algorithm, key, iv);

    const jsonData = JSON.stringify({
      firstName: data.firstName,
      birthDate: data.birthDate,
      // Donnees sensibles uniquement
    });

    const encrypted = Buffer.concat([
      cipher.update(jsonData, 'utf8'),
      cipher.final(),
    ]);

    const tag = cipher.getAuthTag();

    return {
      data: Buffer.concat([salt, iv, tag, encrypted]).toString('base64'),
      // Stocker le reste en clair pour les requetes
      studentId: data.studentId,
      grade: data.grade,
      schoolId: data.schoolId,
    };
  }

  async decrypt(encrypted: EncryptedData): Promise<ChildSensitiveData> {
    const buffer = Buffer.from(encrypted.data, 'base64');

    const salt = buffer.subarray(0, this.saltLength);
    const iv = buffer.subarray(this.saltLength, this.saltLength + this.ivLength);
    const tag = buffer.subarray(
      this.saltLength + this.ivLength,
      this.saltLength + this.ivLength + this.tagLength
    );
    const data = buffer.subarray(this.saltLength + this.ivLength + this.tagLength);

    const key = await scryptAsync(
      process.env.ENCRYPTION_KEY,
      salt,
      this.keyLength
    ) as Buffer;

    const decipher = createDecipheriv(this.algorithm, key, iv);
    decipher.setAuthTag(tag);

    const decrypted = Buffer.concat([
      decipher.update(data),
      decipher.final(),
    ]);

    return {
      ...encrypted,
      ...JSON.parse(decrypted.toString('utf8')),
    };
  }
}
```

### Schema Prisma avec Donnees Chiffrees

```prisma
// prisma/schema.prisma
model Student {
  id        String   @id @default(uuid())
  schoolId  String
  grade     Grade

  // Donnees sensibles CHIFFREES
  encryptedData String // JSON chiffre: firstName, birthDate

  // Donnees non-sensibles en clair pour les requetes
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  school    School   @relation(fields: [schoolId], references: [id])
  scores    Score[]
  progress  Progress[]

  @@index([schoolId])
  @@index([grade])
}

model Score {
  id        String   @id @default(uuid())
  studentId String
  gameId    String
  score     Int
  playedAt  DateTime @default(now())

  // Pas de donnees personnelles dans Score
  student   Student  @relation(fields: [studentId], references: [id])
  game      Game     @relation(fields: [gameId], references: [id])

  @@index([studentId])
  @@index([gameId])
}
```

---

## Gestion du Consentement Parental

```typescript
// services/parental-consent.service.ts
@Injectable()
export class ParentalConsentService {
  // Verifier le consentement avant toute action
  async verifyConsent(studentId: string): Promise<boolean> {
    const consent = await this.prisma.parentalConsent.findFirst({
      where: {
        studentId,
        status: 'VALID',
        expiresAt: { gt: new Date() },
      },
    });

    return consent !== null;
  }

  // Demander un nouveau consentement
  async requestConsent(studentId: string, parentEmail: string): Promise<void> {
    const token = randomBytes(32).toString('hex');

    await this.prisma.parentalConsent.create({
      data: {
        studentId,
        parentEmail,
        token,
        status: 'PENDING',
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 jours
      },
    });

    // Envoyer email au parent
    await this.emailService.sendConsentRequest({
      to: parentEmail,
      token,
      studentInfo: 'Votre enfant souhaite utiliser la plateforme...',
    });
  }

  // Valider le consentement
  async validateConsent(token: string): Promise<void> {
    const consent = await this.prisma.parentalConsent.findFirst({
      where: { token, status: 'PENDING' },
    });

    if (!consent) {
      throw new NotFoundException('Demande de consentement non trouvee');
    }

    if (consent.expiresAt < new Date()) {
      throw new BadRequestException('Demande expiree');
    }

    await this.prisma.parentalConsent.update({
      where: { id: consent.id },
      data: {
        status: 'VALID',
        validatedAt: new Date(),
        // Consentement valide 1 an
        expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
      },
    });
  }

  // Revoquer le consentement
  async revokeConsent(studentId: string, parentEmail: string): Promise<void> {
    await this.prisma.parentalConsent.updateMany({
      where: { studentId, parentEmail },
      data: { status: 'REVOKED', revokedAt: new Date() },
    });

    // Declencher la suppression des donnees
    await this.dataRetentionService.scheduleDataDeletion(studentId);
  }
}
```

---

## Droit a l'Oubli - Implementation

```typescript
// services/data-deletion.service.ts
@Injectable()
export class DataDeletionService {
  // Supprimer toutes les donnees d'un enfant
  async deleteStudentData(studentId: string, reason: string): Promise<void> {
    await this.prisma.$transaction(async (tx) => {
      // 1. Supprimer les scores (anonymiser d'abord si besoin stats)
      await tx.score.deleteMany({ where: { studentId } });

      // 2. Supprimer la progression
      await tx.progress.deleteMany({ where: { studentId } });

      // 3. Supprimer les achievements
      await tx.achievement.deleteMany({ where: { studentId } });

      // 4. Supprimer le consentement
      await tx.parentalConsent.deleteMany({ where: { studentId } });

      // 5. Supprimer l'eleve
      await tx.student.delete({ where: { id: studentId } });

      // 6. Logger la suppression (sans donnees personnelles)
      await tx.deletionLog.create({
        data: {
          entityType: 'STUDENT',
          entityId: studentId,
          reason,
          deletedAt: new Date(),
        },
      });
    });
  }

  // Exportation des donnees (portabilite)
  async exportStudentData(studentId: string): Promise<ExportedData> {
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      include: {
        scores: true,
        progress: true,
        achievements: true,
      },
    });

    // Dechiffrer les donnees sensibles pour l'export
    const decrypted = await this.encryption.decrypt(student.encryptedData);

    return {
      personalData: {
        firstName: decrypted.firstName,
        birthDate: decrypted.birthDate,
        grade: student.grade,
      },
      gameData: {
        scores: student.scores.map(s => ({
          game: s.gameId,
          score: s.score,
          date: s.playedAt,
        })),
        progress: student.progress,
        achievements: student.achievements,
      },
      exportedAt: new Date().toISOString(),
    };
  }
}
```

---

## Retention Automatique

```typescript
// jobs/data-retention.job.ts
@Injectable()
export class DataRetentionJob {
  // Executer chaque nuit
  @Cron('0 2 * * *')
  async cleanupExpiredData() {
    const schoolYearEnd = this.getSchoolYearEnd();

    // Supprimer les donnees des annees precedentes
    if (new Date() > schoolYearEnd) {
      await this.cleanupPreviousYearData();
    }

    // Anonymiser les logs de plus de 30 jours
    await this.anonymizeOldLogs();
  }

  private async cleanupPreviousYearData() {
    const previousYearEnd = new Date();
    previousYearEnd.setFullYear(previousYearEnd.getFullYear() - 1);
    previousYearEnd.setMonth(7); // Aout
    previousYearEnd.setDate(31);

    const studentsToDelete = await this.prisma.student.findMany({
      where: {
        createdAt: { lt: previousYearEnd },
        // Ne pas supprimer si consentement explicite de conservation
        parentalConsent: {
          none: { extendedRetention: true },
        },
      },
    });

    for (const student of studentsToDelete) {
      await this.dataDeletionService.deleteStudentData(
        student.id,
        'RETENTION_POLICY_SCHOOL_YEAR'
      );
    }

    this.logger.log(`Deleted ${studentsToDelete.length} students (retention policy)`);
  }

  private async anonymizeOldLogs() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    await this.prisma.gameLog.updateMany({
      where: {
        createdAt: { lt: thirtyDaysAgo },
        anonymized: false,
      },
      data: {
        // Remplacer les IDs par des pseudonymes
        studentId: null,
        pseudonymId: true, // Flag pour indiquer anonymisation
        anonymized: true,
      },
    });
  }

  private getSchoolYearEnd(): Date {
    const now = new Date();
    const year = now.getMonth() >= 8 ? now.getFullYear() + 1 : now.getFullYear();
    return new Date(year, 7, 31); // 31 aout
  }
}
```

---

## Checklist RGPD Gaming Enfants

```markdown
## Checklist Conformite RGPD Enfants

### Collecte
- [ ] Minimisation: uniquement donnees necessaires
- [ ] Pas de donnees de localisation
- [ ] Pas de photos/videos sans consentement explicite
- [ ] Pas d'enregistrement audio

### Consentement
- [ ] Consentement parental obligatoire < 16 ans
- [ ] Verification identite parent
- [ ] Consentement granulaire (jeux, stats, export)
- [ ] Renouvellement annuel

### Stockage
- [ ] Chiffrement au repos (AES-256)
- [ ] Donnees sensibles separees
- [ ] Acces restreint (need-to-know)
- [ ] Logs d'acces

### Droits
- [ ] Acces: parent peut voir les donnees
- [ ] Rectification: parent peut corriger
- [ ] Effacement: suppression sur demande
- [ ] Portabilite: export JSON/CSV

### Retention
- [ ] Duree definie (fin annee scolaire)
- [ ] Suppression automatique
- [ ] Anonymisation pour stats
- [ ] Logs de suppression

### Securite
- [ ] Pas de donnees en frontend
- [ ] Pas de localStorage
- [ ] HTTPS obligatoire
- [ ] Audit trail
```

---

## References

- [CNIL - Droits des mineurs](https://www.cnil.fr/fr/les-droits-des-mineurs)
- [RGPD Article 8](https://www.cnil.fr/fr/reglement-europeen-protection-donnees/chapitre2#Article8)
- [COPPA Rule](https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa)
- [ICO Children's Code](https://ico.org.uk/for-organisations/childrens-code-hub/)

---

**Derniere mise a jour**: 2025-12-12
**Module**: Gaming Platform - Data Protection
