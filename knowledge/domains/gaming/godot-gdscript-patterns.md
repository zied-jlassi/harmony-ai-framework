---
name: godot-gdscript-patterns
displayName: "Godot GDScript Patterns"
category: game-development
tier: 2
model: inherit
triggers:
  - "godot"
  - "gdscript"
  - "game engine"
  - "2d game"
  - "3d game"
---

# Godot GDScript Patterns

> Build games with Godot Engine using GDScript best practices.

## Project Structure

```
project/
├── addons/                  # Plugins
├── assets/
│   ├── sprites/
│   ├── sounds/
│   └── fonts/
├── scenes/
│   ├── main/
│   │   └── main.tscn
│   ├── ui/
│   │   ├── hud.tscn
│   │   └── menu.tscn
│   ├── characters/
│   │   ├── player.tscn
│   │   └── enemy.tscn
│   └── levels/
│       └── level_01.tscn
├── scripts/
│   ├── autoload/            # Singletons
│   │   ├── game_manager.gd
│   │   └── audio_manager.gd
│   ├── components/          # Reusable behaviors
│   │   ├── health.gd
│   │   └── movement.gd
│   └── resources/           # Custom resources
│       └── weapon_data.gd
└── project.godot
```

## Scene Structure

### Player Scene
```
Player (CharacterBody2D)
├── CollisionShape2D
├── AnimatedSprite2D
├── HealthComponent
├── HurtBox (Area2D)
│   └── CollisionShape2D
├── HitBox (Area2D)
│   └── CollisionShape2D
└── StateMachine
    ├── IdleState
    ├── RunState
    └── JumpState
```

## GDScript Basics

### Class Structure
```gdscript
class_name Player
extends CharacterBody2D

# Signals
signal health_changed(new_health: int)
signal died

# Exports (Inspector variables)
@export var speed: float = 200.0
@export var jump_force: float = 400.0
@export_range(1, 100) var max_health: int = 100

# Onready (cached references)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine

# Private variables
var _current_health: int
var _is_invincible: bool = false

# Lifecycle
func _ready() -> void:
    _current_health = max_health
    health_component.max_health = max_health

func _physics_process(delta: float) -> void:
    _handle_input()
    move_and_slide()

func _process(delta: float) -> void:
    _update_animation()

# Public methods
func take_damage(amount: int) -> void:
    if _is_invincible:
        return

    _current_health = max(_current_health - amount, 0)
    health_changed.emit(_current_health)

    if _current_health <= 0:
        _die()

# Private methods
func _handle_input() -> void:
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = -jump_force

func _update_animation() -> void:
    if velocity.x != 0:
        sprite.flip_h = velocity.x < 0
        sprite.play("run")
    else:
        sprite.play("idle")

func _die() -> void:
    died.emit()
    queue_free()
```

## State Machine Pattern

```gdscript
# state_machine.gd
class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self

    if initial_state:
        current_state = initial_state
        current_state.enter()

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func transition_to(state_name: String) -> void:
    var new_state = states.get(state_name.to_lower())
    if new_state == null or new_state == current_state:
        return

    current_state.exit()
    current_state = new_state
    current_state.enter()


# state.gd (base class)
class_name State
extends Node

var state_machine: StateMachine

func enter() -> void:
    pass

func exit() -> void:
    pass

func update(_delta: float) -> void:
    pass

func physics_update(_delta: float) -> void:
    pass


# idle_state.gd
class_name IdleState
extends State

@onready var player: Player = owner

func physics_update(delta: float) -> void:
    if player.velocity.x != 0:
        state_machine.transition_to("run")

    if Input.is_action_just_pressed("jump") and player.is_on_floor():
        state_machine.transition_to("jump")
```

## Autoload (Singleton)

```gdscript
# autoload/game_manager.gd
extends Node

signal game_paused
signal game_resumed
signal score_changed(new_score: int)

var score: int = 0:
    set(value):
        score = value
        score_changed.emit(score)

var is_paused: bool = false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func pause_game() -> void:
    get_tree().paused = true
    is_paused = true
    game_paused.emit()

func resume_game() -> void:
    get_tree().paused = false
    is_paused = false
    game_resumed.emit()

func add_score(amount: int) -> void:
    score += amount

func reset() -> void:
    score = 0
    is_paused = false
```

## Custom Resources

```gdscript
# resources/weapon_data.gd
class_name WeaponData
extends Resource

@export var name: String
@export var damage: int
@export var attack_speed: float
@export var sprite: Texture2D
@export var sound: AudioStream

# Create in editor: Right-click > New Resource > WeaponData
```

```gdscript
# Usage in weapon.gd
class_name Weapon
extends Node2D

@export var weapon_data: WeaponData

func attack() -> void:
    var damage = weapon_data.damage
    # Apply damage...
```

## Signals & Events

```gdscript
# Emitter
class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)
signal damaged(amount: int)

func take_damage(amount: int) -> void:
    health -= amount
    damaged.emit(amount)

    if health <= 0:
        died.emit(self)
        queue_free()


# Listener
class_name GameManager
extends Node

@onready var enemies = get_tree().get_nodes_in_group("enemies")

func _ready() -> void:
    for enemy in enemies:
        enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy) -> void:
    score += 100
```

## Object Pooling

```gdscript
# object_pool.gd
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var initial_size: int = 10

var _pool: Array[Node] = []

func _ready() -> void:
    for i in initial_size:
        _add_to_pool()

func get_object() -> Node:
    for obj in _pool:
        if not obj.visible:
            return obj

    # Pool exhausted, create new
    return _add_to_pool()

func _add_to_pool() -> Node:
    var obj = scene.instantiate()
    obj.visible = false
    add_child(obj)
    _pool.append(obj)
    return obj


# Usage
@onready var bullet_pool: ObjectPool = $BulletPool

func shoot() -> void:
    var bullet = bullet_pool.get_object()
    bullet.global_position = muzzle.global_position
    bullet.visible = true
    bullet.activate()
```

## Component Pattern

```gdscript
# components/health_component.gd
class_name HealthComponent
extends Node

signal health_changed(current: int, max_health: int)
signal died

@export var max_health: int = 100

var current_health: int:
    set(value):
        current_health = clamp(value, 0, max_health)
        health_changed.emit(current_health, max_health)
        if current_health <= 0:
            died.emit()

func _ready() -> void:
    current_health = max_health

func damage(amount: int) -> void:
    current_health -= amount

func heal(amount: int) -> void:
    current_health += amount
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Typed variables** | Use `: Type` for all variables |
| **Signals over refs** | Decouple with signals |
| **Scene composition** | Reusable scene components |
| **Autoloads** | For global state/managers |
| **Custom resources** | Data-driven design |
| **Groups** | For finding nodes dynamically |
| **Object pooling** | For bullets, particles |
| **State machines** | For complex behaviors |
