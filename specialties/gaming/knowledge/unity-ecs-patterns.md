---
name: unity-ecs-patterns
displayName: "Unity ECS Patterns"
category: game-development
tier: 2
model: inherit
triggers:
  - "unity"
  - "ECS"
  - "DOTS"
  - "entity component system"
  - "game engine"
---

# Unity ECS Patterns

> Implement Unity Entity Component System for high-performance games.

## ECS Fundamentals

```
┌─────────────────────────────────────────────────────────────────┐
│                    ECS ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ENTITY          COMPONENT           SYSTEM                     │
│  ├── ID only     ├── Data only       ├── Logic only            │
│  ├── Container   ├── No behavior     ├── Processes entities    │
│  └── Archetype   └── Struct          └── Queries components    │
│                                                                  │
│  Entity = Component1 + Component2 + Component3 + ...            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Components (Data)

```csharp
using Unity.Entities;
using Unity.Mathematics;

// Position component
public struct Position : IComponentData
{
    public float3 Value;
}

// Velocity component
public struct Velocity : IComponentData
{
    public float3 Value;
}

// Health component
public struct Health : IComponentData
{
    public float Current;
    public float Max;
}

// Tag component (no data, just marking)
public struct PlayerTag : IComponentData { }

// Shared component (same value for many entities)
public struct TeamId : ISharedComponentData
{
    public int Value;
}

// Buffer element (dynamic array)
public struct InventoryItem : IBufferElementData
{
    public int ItemId;
    public int Quantity;
}
```

## Systems (Logic)

### Basic System
```csharp
using Unity.Entities;
using Unity.Burst;
using Unity.Jobs;

[BurstCompile]
public partial struct MovementSystem : ISystem
{
    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        float deltaTime = SystemAPI.Time.DeltaTime;

        // Query and process entities
        foreach (var (position, velocity) in
            SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>())
        {
            position.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
        }
    }
}
```

### Job System (Parallel Processing)
```csharp
[BurstCompile]
public partial struct MovementJobSystem : ISystem
{
    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var job = new MovementJob
        {
            DeltaTime = SystemAPI.Time.DeltaTime
        };

        state.Dependency = job.ScheduleParallel(state.Dependency);
    }
}

[BurstCompile]
public partial struct MovementJob : IJobEntity
{
    public float DeltaTime;

    public void Execute(ref Position position, in Velocity velocity)
    {
        position.Value += velocity.Value * DeltaTime;
    }
}
```

### System with Filtering
```csharp
[BurstCompile]
public partial struct DamageSystem : ISystem
{
    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var ecb = new EntityCommandBuffer(Allocator.Temp);

        // Query entities with Health and DamageEvent
        foreach (var (health, damage, entity) in
            SystemAPI.Query<RefRW<Health>, RefRO<DamageEvent>>()
                .WithEntityAccess())
        {
            health.ValueRW.Current -= damage.ValueRO.Amount;

            // Remove damage event after processing
            ecb.RemoveComponent<DamageEvent>(entity);

            // Destroy if dead
            if (health.ValueRO.Current <= 0)
            {
                ecb.DestroyEntity(entity);
            }
        }

        ecb.Playback(state.EntityManager);
        ecb.Dispose();
    }
}
```

## Entity Creation

### Spawning Entities
```csharp
public partial struct SpawnerSystem : ISystem
{
    public void OnUpdate(ref SystemState state)
    {
        var ecb = new EntityCommandBuffer(Allocator.Temp);

        foreach (var (spawner, transform) in
            SystemAPI.Query<RefRW<Spawner>, RefRO<LocalTransform>>())
        {
            spawner.ValueRW.Timer -= SystemAPI.Time.DeltaTime;

            if (spawner.ValueRO.Timer <= 0)
            {
                spawner.ValueRW.Timer = spawner.ValueRO.Interval;

                // Create new entity
                var entity = ecb.Instantiate(spawner.ValueRO.Prefab);

                // Set position
                ecb.SetComponent(entity, new Position
                {
                    Value = transform.ValueRO.Position
                });

                // Add velocity
                ecb.AddComponent(entity, new Velocity
                {
                    Value = new float3(0, 0, 10)
                });
            }
        }

        ecb.Playback(state.EntityManager);
        ecb.Dispose();
    }
}
```

### Prefab Conversion (Baker)
```csharp
public class EnemyAuthoring : MonoBehaviour
{
    public float MoveSpeed;
    public float MaxHealth;

    class Baker : Baker<EnemyAuthoring>
    {
        public override void Bake(EnemyAuthoring authoring)
        {
            var entity = GetEntity(TransformUsageFlags.Dynamic);

            AddComponent(entity, new Velocity
            {
                Value = new float3(0, 0, authoring.MoveSpeed)
            });

            AddComponent(entity, new Health
            {
                Current = authoring.MaxHealth,
                Max = authoring.MaxHealth
            });

            AddComponent<EnemyTag>(entity);
        }
    }
}
```

## Querying Patterns

```csharp
// Basic query
foreach (var (pos, vel) in SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>())
{
    // Process
}

// With entity access
foreach (var (pos, entity) in SystemAPI.Query<RefRO<Position>>().WithEntityAccess())
{
    // Can use entity reference
}

// Filter by tag
foreach (var (pos, vel) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()
        .WithAll<PlayerTag>())
{
    // Only players
}

// Exclude components
foreach (var pos in
    SystemAPI.Query<RefRW<Position>>()
        .WithNone<DeadTag>())
{
    // Exclude dead entities
}

// Shared component filter
foreach (var (pos, team) in
    SystemAPI.Query<RefRO<Position>, SharedComponentFilter<TeamId>>())
{
    // Filter by team
}
```

## Common Patterns

### Singleton Access
```csharp
// Get singleton
var gameConfig = SystemAPI.GetSingleton<GameConfig>();

// Set singleton
SystemAPI.SetSingleton(new GameConfig { Difficulty = 2 });

// Check exists
if (SystemAPI.HasSingleton<GameConfig>())
{
    // ...
}
```

### Aspect (Component Bundle)
```csharp
public readonly partial struct TransformAspect : IAspect
{
    public readonly RefRW<Position> Position;
    public readonly RefRO<Rotation> Rotation;
    public readonly RefRW<Velocity> Velocity;

    public void Move(float deltaTime)
    {
        Position.ValueRW.Value += Velocity.ValueRO.Value * deltaTime;
    }
}

// Usage in system
foreach (var transform in SystemAPI.Query<TransformAspect>())
{
    transform.Move(deltaTime);
}
```

## Performance Tips

| Tip | Description |
|-----|-------------|
| **Use Burst** | `[BurstCompile]` on systems and jobs |
| **Parallel Jobs** | `ScheduleParallel` for large entity counts |
| **Avoid Allocations** | Use `Allocator.Temp` or pooling |
| **Batch Commands** | Use EntityCommandBuffer |
| **Chunk Iteration** | Keep components together |
| **Shared Components** | For grouping many entities |
| **Enable/Disable** | Prefer over destroy/create |

## Best Practices

- [ ] Components are pure data (no methods)
- [ ] Systems contain all logic
- [ ] Use Burst compilation everywhere
- [ ] Prefer jobs for parallelism
- [ ] Use EntityCommandBuffer for structural changes
- [ ] Profile with Unity Profiler
- [ ] Keep archetypes stable (minimize component add/remove)
