---
name: secrets-management
displayName: "Secrets Management"
category: cicd-automation
tier: 2
model: inherit
triggers:
  - "secrets"
  - "vault"
  - "credentials"
  - "environment variables"
  - "secure config"
---

# Secrets Management

> Implement secure secrets management for applications.

## Principles

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECRETS MANAGEMENT                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  NEVER                        ALWAYS                             │
│  ├── Commit secrets           ├── Use secret managers           │
│  ├── Log secrets              ├── Rotate regularly              │
│  ├── Hardcode in code         ├── Encrypt at rest               │
│  ├── Share via chat           ├── Audit access                  │
│  └── Use same for all envs    └── Least privilege               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Environment Variables (Development)

```bash
# .env.example (committed to git)
DATABASE_URL=postgresql://user:password@localhost:5432/db
JWT_SECRET=your-secret-here
API_KEY=your-api-key

# .env.local (not committed, in .gitignore)
DATABASE_URL=postgresql://real:creds@localhost:5432/db
JWT_SECRET=actual-secret
API_KEY=actual-api-key
```

```typescript
// config/env.ts
import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  API_KEY: z.string(),
});

export const env = envSchema.parse(process.env);
```

## GitHub Secrets

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
        run: |
          echo "Deploying with secrets..."

      # For OIDC auth (no long-lived secrets)
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1
```

## Kubernetes Secrets

```yaml
# External Secrets Operator (recommended)
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: api-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-url
      remoteRef:
        key: production/api/database
        property: url
    - secretKey: jwt-secret
      remoteRef:
        key: production/api/jwt
        property: secret
---
# Secret Store configuration
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-secrets-manager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets
            namespace: external-secrets
```

## HashiCorp Vault

```typescript
// vault-client.ts
import Vault from 'node-vault';

const vault = Vault({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN,
});

export async function getSecret(path: string): Promise<Record<string, string>> {
  const response = await vault.read(`secret/data/${path}`);
  return response.data.data;
}

// Usage
const dbSecrets = await getSecret('production/database');
const connectionString = dbSecrets.url;
```

```bash
# Vault CLI
# Login
vault login -method=oidc

# Write secret
vault kv put secret/production/database \
  url="postgresql://user:pass@db:5432/app"

# Read secret
vault kv get secret/production/database

# Dynamic database credentials
vault read database/creds/readonly
```

## AWS Secrets Manager

```typescript
// aws-secrets.ts
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: 'us-east-1' });

export async function getSecret(secretId: string): Promise<Record<string, any>> {
  const command = new GetSecretValueCommand({ SecretId: secretId });
  const response = await client.send(command);

  if (response.SecretString) {
    return JSON.parse(response.SecretString);
  }

  throw new Error('Secret not found');
}

// With caching
import { createCache } from 'cache-manager';

const cache = createCache({ ttl: 300 }); // 5 minutes

export async function getSecretCached(secretId: string) {
  return cache.wrap(secretId, () => getSecret(secretId));
}
```

## Secret Rotation

```typescript
// secret-rotation.ts
import { ScheduledHandler } from 'aws-lambda';
import { SecretsManager } from '@aws-sdk/client-secrets-manager';

export const handler: ScheduledHandler = async () => {
  const client = new SecretsManager({});

  // 1. Generate new secret
  const newPassword = generateSecurePassword();

  // 2. Update in target system (e.g., database)
  await updateDatabasePassword(newPassword);

  // 3. Update in Secrets Manager
  await client.updateSecret({
    SecretId: 'production/database',
    SecretString: JSON.stringify({ password: newPassword }),
  });

  // 4. Notify applications to refresh
  await notifyApplications();
};

function generateSecurePassword(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  let password = '';
  const array = new Uint32Array(32);
  crypto.getRandomValues(array);
  for (let i = 0; i < 32; i++) {
    password += chars[array[i] % chars.length];
  }
  return password;
}
```

## Pre-commit Secret Detection

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: package-lock.json

  - repo: https://github.com/awslabs/git-secrets
    rev: master
    hooks:
      - id: git-secrets
```

```bash
# Initialize baseline
detect-secrets scan > .secrets.baseline

# Audit baseline
detect-secrets audit .secrets.baseline
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Secret rotation** | Rotate every 30-90 days |
| **Least privilege** | Minimal access per role |
| **Audit logging** | Track all secret access |
| **Encryption** | At rest and in transit |
| **No defaults** | Fail if secret missing |
| **Separate by env** | Different secrets per env |
| **Dynamic secrets** | Short-lived when possible |
| **Pre-commit hooks** | Prevent accidental commits |
