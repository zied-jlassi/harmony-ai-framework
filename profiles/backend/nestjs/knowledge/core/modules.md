# NestJS Modules

> Core concept - Always loaded

## Overview

Modules are the fundamental building blocks in NestJS. Every application has at least one root module.

```typescript
@Module({
  imports: [],      // Other modules to import
  controllers: [],  // Controllers belonging to this module
  providers: [],    // Services/providers for this module
  exports: []       // Providers to export for other modules
})
export class AppModule {}
```

## Best Practices

1. **Feature modules** - Group related functionality
2. **Shared modules** - Export common providers
3. **Lazy loading** - Use dynamic imports for large modules
4. **Global modules** - Use `@Global()` sparingly

## Common Patterns

```typescript
// Feature module
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService]
})
export class UsersModule {}

// Dynamic module
@Module({})
export class ConfigModule {
  static forRoot(options: ConfigOptions): DynamicModule {
    return {
      module: ConfigModule,
      providers: [
        { provide: 'CONFIG_OPTIONS', useValue: options },
        ConfigService
      ],
      exports: [ConfigService]
    };
  }
}
```

---
*Populated via /harmony learn - Last update: 2026-01-04*
