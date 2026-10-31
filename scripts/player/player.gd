class_name DigPlayer
extends CharacterBody2D
## Milestone A: movement, mouse-targeted digging, and limited ore cargo.
## Oxygen, battery, and jetpack are later tasks.

signal cargo_changed(amount: int, capacity: int)

@export var move_speed: float = 170.0
@export var jump_velocity: float = -305.0
@export var gravity: float = 900.0
@export var drill_reach: float = 80.0
@export var drill_interval: float = 0.18
@export_range(1, 64, 1) var cargo_capacity: int = 8

var ore_carried: int = 0
var _drill_cooldown: float = 0.0
var terrain: DigTerrain


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    velocity.x = Input.get_axis("ui_left", "ui_right") * move_speed
    if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
        velocity.y = jump_velocity
    move_and_slide()

    _drill_cooldown = maxf(0.0, _drill_cooldown - delta)
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _drill_cooldown <= 0.0:
        _try_drill()
        _drill_cooldown = drill_interval


func _try_drill() -> void:
    if terrain == null:
        return
    var target := get_global_mouse_position()
    if global_position.distance_to(target) > drill_reach:
        return
    # Prevent drilling a tile hidden behind another solid tile.
    var query := PhysicsRayQueryParameters2D.create(global_position, target, 1, [get_rid()])
    var hit := get_world_2d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return
    var hit_position: Vector2 = hit.position - hit.normal * 1.0
    terrain.excavate_global_point(hit_position)


func try_collect_ore(amount: int = 1) -> bool:
    if amount <= 0:
        return false
    if ore_carried + amount > cargo_capacity:
        return false
    ore_carried += amount
    cargo_changed.emit(ore_carried, cargo_capacity)
    return true


func is_cargo_full() -> bool:
    return ore_carried >= cargo_capacity
