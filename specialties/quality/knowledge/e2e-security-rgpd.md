---
name: "e2e-security-rgpd"
description: "E2E Security & RGPD compliance testing patterns"
version: "1.0"
auto_invoke: true
activate_when:
  file_matches:
    - "e2e/**"
    - "*.spec.ts"
  keywords:
    - "security"
    - "rgpd"
    - "gdpr"
    - "consent"
    - "auth"
    - "xss"
agents:
  - tester
  - qa
  - security
---

# E2E Security & RGPD Testing Patterns

> Tests E2E pour sécurité et conformité RGPD

## Security E2E Tests

### Authentication Tests

```typescript
test.describe('Security - Authentication', () => {
  test('should redirect unauthenticated to login', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL(/.*login/);
  });

  test('should prevent IDOR - cross-school access', async ({ page }) => {
    await loginAs(page, 'director'); // School A
    const response = await page.goto('/api/schools/other-id/students');
    expect(response?.status()).toBe(403);
  });
});
```

### XSS Prevention

```typescript
test('should sanitize XSS in input', async ({ page }) => {
  const xssPayload = '<script>alert("xss")</script>';
  await page.getByLabel('Nom').fill(xssPayload);
  await page.getByRole('button', { name: 'Enregistrer' }).click();

  // Should show escaped text, not execute
  await expect(page.getByText('<script>')).toBeVisible();
});
```

## RGPD Compliance Tests

### Cookie Consent (ePrivacy)

```typescript
test.describe('RGPD - Consent', () => {
  test('should display cookie banner on first visit', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('dialog', { name: /cookies/i })).toBeVisible();
  });

  test('should allow refusing non-essential', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: /refuser/i }).click();
    const cookies = await page.context().cookies();
    expect(cookies.filter(c => c.name.includes('analytics'))).toHaveLength(0);
  });
});
```

### Data Subject Rights (Art. 15-17)

```typescript
test('should allow data export (Art. 15)', async ({ page }) => {
  await loginAs(page, 'parent');
  await page.goto('/profile/privacy');
  const download = page.waitForEvent('download');
  await page.getByRole('button', { name: /exporter/i }).click();
  expect((await download).suggestedFilename()).toMatch(/export.*\.json$/);
});

test('should allow deletion request (Art. 17)', async ({ page }) => {
  await loginAs(page, 'parent');
  await page.goto('/profile/privacy');
  await page.getByRole('button', { name: /supprimer/i }).click();
  await page.getByRole('button', { name: /confirmer/i }).click();
  await expect(page.getByText(/demande.*prise en compte/i)).toBeVisible();
});
```

### Protection Mineurs (Art. 8 / Art. 45 LIL)

```typescript
test('should require parental consent for < 15 years', async ({ page }) => {
  await loginAs(page, 'director');
  await page.goto('/students/create');
  await page.getByLabel('Date de naissance').fill('2015-01-01');
  await page.getByRole('button', { name: 'Suivant' }).click();
  await expect(page.getByText(/consentement parental/i)).toBeVisible();
});

test('should NOT allow profiling for minors', async ({ page }) => {
  await loginAs(page, 'director');
  await page.goto('/students/123/profile');
  await expect(page.getByRole('button', { name: /profilage/i })).not.toBeVisible();
});
```

## Security Checklist

- [ ] Auth flows (login/logout/session)
- [ ] Authorization (role-based)
- [ ] IDOR prevention (multi-tenant)
- [ ] XSS sanitization
- [ ] CSRF tokens
- [ ] Rate limiting

## RGPD Checklist

- [ ] Cookie consent banner
- [ ] Data export works
- [ ] Deletion request works
- [ ] Privacy policy accessible
- [ ] Parental consent for minors
- [ ] No profiling for minors

## References

- OWASP Top 10: `.harmony/skills/security/owasp-top10/`
- Art. 45 LIL: Mineurs < 15 ans
- Steering: `.harmony/steering/security.md`
