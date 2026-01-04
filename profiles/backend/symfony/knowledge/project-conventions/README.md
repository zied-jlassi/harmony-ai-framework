# Conventions Projet Symfony - À Personnaliser

> Ce fichier est un **template**. Chaque équipe doit le remplir avec ses propres conventions.
> Les standards industrie sont dans `../industry-standards/`.

---

## Comment Remplir Ce Fichier

1. **Identifier** ce qui est unique à votre projet Symfony
2. **Documenter** les décisions d'équipe
3. **Expliquer** pourquoi (pas juste quoi)
4. **Versionner** les changements importants

---

## Exemples de Conventions à Documenter

### Structure API

```php
// Quelle structure de réponse JSON ?
// Utilisez-vous API Platform ou contrôleurs manuels ?

// Exemple de votre convention:
return $this->json([
    'data' => $entity,
    'meta' => ['timestamp' => new \DateTime()],
]);
```

### Gestion des Exceptions

```php
// Comment gérez-vous les erreurs ?
// ExceptionListener global ?
// Format d'erreur standard ?

throw new ApiException('User not found', 404, [
    'code' => 'USER_NOT_FOUND',
    'user_id' => $userId,
]);
```

### Validation

```php
// Où placez-vous la validation ?
// Dans les DTOs ? Entities ? Services ?

// Contraintes personnalisées ?
#[Assert\UniqueEntity(fields: ['email'])]
#[App\Validator\ValidPhoneNumber]
```

### Doctrine

```php
// Soft delete activé ?
// Timestamps automatiques ?
// UUID vs auto-increment ?

// Votre convention pour les relations:
#[ORM\ManyToOne(targetEntity: User::class)]
#[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
```

### Tests

```php
// PHPUnit ou Pest ?
// Fixtures avec Foundry ?
// Base de test SQLite ou PostgreSQL ?
```

---

## Votre Section Conventions

> ⬇️ Ajoutez vos conventions ci-dessous ⬇️

### [Votre Convention 1]

*À remplir par l'équipe*

### [Votre Convention 2]

*À remplir par l'équipe*

---

*Ce fichier est maintenu manuellement par l'équipe.*
*Dernière mise à jour: [DATE]*
