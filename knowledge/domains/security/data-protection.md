# Data Protection - Files, Anonymization, Secrets, RGPD

> Module de l'agent `/bmad:security`
> **Commandes**: `audit-files`, `audit-anonymization`, `rgpd-check`

---

## Gestion des Fichiers Sensibles (Import/Export)

### Risques Identifies

```
+-----------------------------------------------------------------+
|          RISQUES FICHIERS IMPORT/EXPORT                         |
+-----------------------------------------------------------------+
|                                                                  |
|  SCENARIOS D'ATTAQUE                                             |
|                                                                  |
|  1. Path Traversal                                               |
|     +-- Attaquant telecharge fichiers hors du dossier prevu     |
|     +-- Ex: GET /download?file=../../../etc/passwd              |
|                                                                  |
|  2. Persistance de donnees sensibles                            |
|     +-- Fichiers non supprimes apres traitement                 |
|     +-- Donnees en clair sur disque                             |
|                                                                  |
|  3. Exposition via erreur serveur                               |
|     +-- Stack trace revele chemins fichiers                     |
|     +-- Directory listing active                                |
|                                                                  |
|  4. Fuite via backup/logs                                       |
|     +-- Fichiers sensibles dans backups non chiffres            |
|     +-- Chemins/contenus dans logs                              |
|                                                                  |
+-----------------------------------------------------------------+
```

### Checklist Fichiers Sensibles

```
+-----------------------------------------------------------------+
|              CHECKLIST FICHIERS IMPORT/EXPORT                   |
+-----------------------------------------------------------------+
|                                                                  |
|  STOCKAGE                                                        |
|  [ ] Fichiers HORS du webroot (pas dans /public)                |
|  [ ] Chiffrement applicatif (AES-256-GCM)                       |
|  [ ] Permissions restrictives (600 ou 640)                      |
|  [ ] Repertoire dedie avec acces controle                       |
|                                                                  |
|  CYCLE DE VIE                                                    |
|  [ ] TTL court (supprimer apres traitement)                     |
|  [ ] Cron/job de nettoyage des fichiers orphelins               |
|  [ ] Pas de conservation "au cas ou"                            |
|  [ ] Suppression securisee (overwrite avant delete)             |
|                                                                  |
|  ACCES                                                           |
|  [ ] Validation nom de fichier (whitelist caracteres)           |
|  [ ] Protection path traversal (../ interdit)                   |
|  [ ] Verification proprietaire avant telechargement             |
|  [ ] Tokens temporaires pour download (pas d'ID previsible)     |
|                                                                  |
|  UPLOAD                                                          |
|  [ ] Validation MIME type cote serveur                          |
|  [ ] Limite taille fichier (Multer limits)                      |
|  [ ] Renommage avec UUID (pas le nom original)                  |
|  [ ] Scan antivirus si possible                                 |
|                                                                  |
|  LOGGING                                                         |
|  [ ] Log des acces fichiers (qui, quand, quoi)                  |
|  [ ] Pas de contenu fichier dans les logs                       |
|  [ ] Alerting sur acces suspects                                |
|                                                                  |
+-----------------------------------------------------------------+
```

### Implementation NestJS Securisee

```typescript
// Service de gestion fichiers securise
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';
import { unlink, writeFile, readFile } from 'fs/promises';
import { join, basename, normalize } from 'path';

@Injectable()
export class SecureFileService {
  private readonly uploadDir = '/var/app/secure-files'; // HORS webroot
  private readonly algorithm = 'aes-256-gcm';
  private readonly key = Buffer.from(process.env.FILE_ENCRYPTION_KEY!, 'hex');

  // Upload securise avec chiffrement
  async saveSecureFile(
    buffer: Buffer,
    userId: string,
    originalName: string,
  ): Promise<string> {
    // Generer nom unique (pas le nom original!)
    const fileId = randomUUID();
    const iv = randomBytes(16);

    // Chiffrer le contenu
    const cipher = createCipheriv(this.algorithm, this.key, iv);
    const encrypted = Buffer.concat([
      cipher.update(buffer),
      cipher.final(),
    ]);
    const authTag = cipher.getAuthTag();

    // Stocker: IV + AuthTag + Encrypted
    const finalBuffer = Buffer.concat([iv, authTag, encrypted]);
    const filePath = join(this.uploadDir, `${fileId}.enc`);

    await writeFile(filePath, finalBuffer, { mode: 0o600 });

    // Log l'acces (sans contenu!)
    this.logger.log({
      action: 'file_upload',
      userId,
      fileId,
      originalName: basename(originalName),
      timestamp: new Date().toISOString(),
    });

    return fileId;
  }

  // Download securise avec verification proprietaire
  async getSecureFile(
    fileId: string,
    requestingUserId: string,
  ): Promise<Buffer> {
    // Valider le format de l'ID (protection injection)
    if (!/^[a-f0-9-]{36}$/.test(fileId)) {
      throw new BadRequestException('Invalid file ID');
    }

    // Verifier proprietaire en BDD
    const fileRecord = await this.prisma.file.findUnique({
      where: { id: fileId },
    });

    if (!fileRecord || fileRecord.ownerId !== requestingUserId) {
      throw new ForbiddenException('Access denied');
    }

    // Construire chemin securise (protection path traversal)
    const filePath = join(this.uploadDir, `${fileId}.enc`);
    const normalizedPath = normalize(filePath);

    if (!normalizedPath.startsWith(this.uploadDir)) {
      throw new ForbiddenException('Path traversal detected');
    }

    // Lire et dechiffrer
    const encrypted = await readFile(normalizedPath);
    const iv = encrypted.subarray(0, 16);
    const authTag = encrypted.subarray(16, 32);
    const content = encrypted.subarray(32);

    const decipher = createDecipheriv(this.algorithm, this.key, iv);
    decipher.setAuthTag(authTag);

    return Buffer.concat([
      decipher.update(content),
      decipher.final(),
    ]);
  }

  // Suppression securisee
  async deleteSecureFile(fileId: string): Promise<void> {
    const filePath = join(this.uploadDir, `${fileId}.enc`);

    // Overwrite avant suppression (anti-forensics)
    const stats = await stat(filePath);
    const zeros = Buffer.alloc(stats.size);
    await writeFile(filePath, zeros);

    // Puis supprimer
    await unlink(filePath);
  }
}
```

### Controller avec Multer securise

```typescript
@Controller('files')
@UseGuards(JwtAuthGuard, RolesGuard, PlayerGuard)
export class FilesController {
  @Post('upload')
  @UseInterceptors(FileInterceptor('file', {
    limits: {
      fileSize: 10 * 1024 * 1024, // 10MB max
      files: 1,
    },
    fileFilter: (req, file, cb) => {
      // Whitelist MIME types
      const allowed = [
        'image/png',
        'image/jpeg',
        'image/gif',
        'application/json',
      ];
      if (allowed.includes(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new BadRequestException('File type not allowed'), false);
      }
    },
  }))
  async upload(
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: User,
  ) {
    return this.fileService.saveSecureFile(
      file.buffer,
      user.id,
      file.originalname,
    );
  }
}
```

### Cron de Nettoyage

```typescript
@Injectable()
export class FileCleanupService {
  private readonly maxAgeHours = 24;

  @Cron('0 */6 * * *') // Toutes les 6 heures
  async cleanupExpiredFiles() {
    const cutoff = new Date();
    cutoff.setHours(cutoff.getHours() - this.maxAgeHours);

    const expiredFiles = await this.prisma.file.findMany({
      where: {
        createdAt: { lt: cutoff },
        status: { not: 'permanent' },
      },
    });

    for (const file of expiredFiles) {
      await this.secureFileService.deleteSecureFile(file.id);
      await this.prisma.file.delete({ where: { id: file.id } });

      this.logger.log({
        action: 'file_cleanup',
        fileId: file.id,
        reason: 'expired',
      });
    }
  }
}
```

---

## Gestion des Secrets

### Regles Fondamentales

```
+-----------------------------------------------------------------+
|                    GESTION DES SECRETS                          |
+-----------------------------------------------------------------+
|                                                                  |
|  INTERDIT                                                        |
|  - Secrets dans le code source                                  |
|  - Secrets dans Dockerfile                                      |
|  - Secrets dans docker-compose.yml                              |
|  - Secrets dans variables d'environnement (production)          |
|  - Secrets dans logs                                            |
|                                                                  |
|  AUTORISE                                                        |
|  - Docker Secrets (Swarm)                                       |
|  - HashiCorp Vault                                              |
|  - AWS Secrets Manager / GCP Secret Manager                     |
|  - External Secrets Operator (K8s)                              |
|  - Fichiers chiffres (SOPS + age/GPG)                           |
|                                                                  |
+-----------------------------------------------------------------+
```

### Configuration Vault avec Docker

```yaml
# docker-compose.yml avec Vault
services:
  vault:
    image: hashicorp/vault:latest
    cap_add:
      - IPC_LOCK
    ports:
      - "127.0.0.1:8200:8200"
    environment:
      VAULT_ADDR: http://127.0.0.1:8200
    volumes:
      - vault-data:/vault/file
    command: server -config=/vault/config/config.hcl
```

```typescript
// Injection secrets au runtime
import Vault from 'node-vault';

const vault = Vault({
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN,
});

const secret = await vault.read('secret/data/database');
const dbPassword = secret.data.data.password;
```

---

## Anonymisation vs Pseudonymisation

### Definitions (Source: CNIL)

```
+-----------------------------------------------------------------+
|          ANONYMISATION vs PSEUDONYMISATION                      |
+-----------------------------------------------------------------+
|                                                                  |
|  ANONYMISATION (Irreversible)                                    |
|  +-- Impossible de re-identifier la personne                    |
|  +-- Meme avec donnees supplementaires                          |
|  +-- Donnees NE SONT PLUS des donnees personnelles              |
|  +-- RGPD ne s'applique plus                                    |
|  +-- Exemple: Agregats statistiques                             |
|                                                                  |
|  PSEUDONYMISATION (Reversible)                                   |
|  +-- Remplacement identifiants par alias                        |
|  +-- Re-identification possible avec la cle                     |
|  +-- Donnees RESTENT des donnees personnelles                   |
|  +-- RGPD s'applique toujours                                   |
|  +-- Exemple: UUID a la place de l'email                        |
|                                                                  |
|  POUR TESTS/DEVELOPPEMENT                                        |
|  +-- Utiliser donnees SYNTHETIQUES (generees)                   |
|  +-- Jamais de vraies donnees en dev/staging                    |
|  +-- OU anonymisation verifiee                                  |
|                                                                  |
+-----------------------------------------------------------------+
```

### Checklist Protection Donnees Tests

```
+-----------------------------------------------------------------+
|          CHECKLIST DONNEES DE TEST                              |
+-----------------------------------------------------------------+
|                                                                  |
|  PRINCIPE: PAS DE VRAIES DONNEES EN DEV/STAGING                 |
|                                                                  |
|  DONNEES SYNTHETIQUES (Recommande)                               |
|  [ ] Generateur de donnees realistes (Faker.js)                 |
|  [ ] Schema respecte (contraintes, FK)                          |
|  [ ] Volume representatif pour tests perf                       |
|  [ ] Seed reproductible                                         |
|                                                                  |
|  SI COPIE DEPUIS PROD (A eviter)                                 |
|  [ ] Anonymisation AVANT copie                                  |
|  [ ] Verification k-anonymite (k >= 5)                          |
|  [ ] Suppression colonnes sensibles inutiles                    |
|  [ ] Validation par DPO                                         |
|                                                                  |
|  ACCES                                                           |
|  [ ] Environnements isoles (pas de connexion prod)              |
|  [ ] Credentials differents par environnement                   |
|  [ ] Logs d'acces aux donnees de test                           |
|                                                                  |
+-----------------------------------------------------------------+
```

### Service de Generation Donnees Synthetiques

```typescript
import { faker } from '@faker-js/faker/locale/fr';

@Injectable()
export class SyntheticDataService {
  // Generer des donnees synthetiques realistes
  generatePlayer(): SyntheticPlayer {
    return {
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      email: faker.internet.email(),
      birthDate: faker.date.birthdate({ min: 6, max: 12, mode: 'age' }),
      // Utiliser des valeurs realistes mais synthetiques
      avatar: faker.image.avatar(),
    };
  }

  // Seed base de test avec donnees synthetiques
  async seedTestDatabase(count: number = 1000) {
    const families = Array.from({ length: 200 }, () => ({
      name: faker.person.lastName() + ' Family',
    }));

    const players = Array.from({ length: count }, () =>
      this.generatePlayer()
    );

    await this.prisma.$transaction([
      this.prisma.family.createMany({ data: families }),
      this.prisma.player.createMany({ data: players }),
    ]);

    this.logger.log(`Seeded ${players.length} synthetic players`);
  }
}
```

### References CNIL/RGPD

- [CNIL - Anonymisation des donnees](https://www.cnil.fr/fr/lanonymisation-des-donnees-un-traitement-cle-pour-lopen-data)
- [CNIL - Guide pratique anonymisation](https://www.cnil.fr/sites/cnil/files/atoms/files/guide_durcissement_v2.pdf)
- [Groupe Article 29 - Opinion 05/2014](https://ec.europa.eu/justice/article-29/documentation/opinion-recommendation/files/2014/wp216_fr.pdf)

---

## Checklist RGPD - Protection Mineurs (COPPA)

```
+-----------------------------------------------------------------+
|          CHECKLIST CONFORMITE RGPD + COPPA                      |
+-----------------------------------------------------------------+
|                                                                  |
|  BASE LEGALE                                                     |
|  [ ] Consentement parental explicite (mineurs < 16 ans)         |
|  [ ] Finalites du traitement documentees                        |
|  [ ] Duree de conservation definie                              |
|                                                                  |
|  DROITS DES PERSONNES                                            |
|  [ ] Droit d'acces implemente (parent pour enfant)              |
|  [ ] Droit de rectification implemente                          |
|  [ ] Droit a l'effacement implemente                            |
|  [ ] Droit a la portabilite (export)                            |
|                                                                  |
|  SECURITE DONNEES ENFANTS                                        |
|  [ ] Chiffrement donnees sensibles                              |
|  [ ] Controle d'acces base sur roles                            |
|  [ ] Journalisation des acces                                   |
|  [ ] Procedure de notification breach (72h)                     |
|                                                                  |
|  SPECIFIQUE ENFANTS (COPPA)                                     |
|  [ ] Pas de publicite ciblee                                    |
|  [ ] Pas de partage donnees avec tiers                          |
|  [ ] Collecte minimale (strictement necessaire)                 |
|  [ ] Verification age implementee                               |
|                                                                  |
|  DOCUMENTATION                                                   |
|  [ ] Registre des traitements                                   |
|  [ ] Analyse d'impact (PIA) si necessaire                       |
|  [ ] Politique de confidentialite adaptee enfants               |
|                                                                  |
+-----------------------------------------------------------------+
```

---

## References

- [CNIL - RGPD](https://www.cnil.fr/fr/rgpd-de-quoi-parle-t-on)
- [ANSSI - Securite des donnees](https://cyber.gouv.fr/publications)
- [OWASP Data Protection](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [FTC - COPPA](https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa)
