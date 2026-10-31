class_name DigPlayer
extends CharacterBody2D
## Player movement, excavation, cargo, and Milestone B survival resources.

signal cargo_changed(amount: int, capacity: int)
signal battery_changed(amount: float, maximum: float)
signal oxygen_changed(amount: float, maximum: float)
signal work_light_changed(enabled: bool)

@export_group("Movement")
@export var move_speed: float = 170.0
@export var jump_velocity: float = -305.0
@export var gravity: float = 900.0
@export var jetpack_acceleration: float = 760.0
@export var jetpack_max_rise_speed: float = 230.0

@export_group("Excavation")
@export var drill_reach: float = 80.0
@export var drill_interval: float = 0.18
@export var drill_battery_cost: float = 4.0

@export_group("Survival")
@export var maximum_battery: float = 100.0
@export var jetpack_battery_per_second: float = 20.0
@export var work_light_battery_per_second: float = 1.0
@export var battery_recharge_per_second: float = 30.0
@export var maximum_oxygen: float = 100.0
@export var oxygen_drain_per_second: float = 4.0
@export var oxygen_refill_per_second: float = 25.0

@export_group("Cargo")
@export_range(1, 64, 1) var cargo_capacity: int = 8

var ore_carried: int = 0
var battery: float
var oxygen: float
var inside_ship: bool = true
var work_light_enabled: bool = true
var terrain: DigTerrain

var _drill_cooldown: float = 0.0
var _jetpack_active: bool = false

@onready var work_light: Polygon2D = $WorkLight
@onready var jetpack_exhaust: Node2D = $JetpackExhaust


func _ready() -> void:
    battery = maximum_battery
    oxygen = maximum_oxygen
    work_light.visible = work_light_enabled
    jetpack_exhaust.visible = false


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta

    var horizontal_input := Input.get_axis("ui_left", "ui_right")
    velocity.x = horizontal_input * move_speed
    if not is_zero_approx(horizontal_input):
        work_light.scale.x = signf(horizontal_input)

    if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
        velocity.y = jump_velocity

    _jetpack_active = false
    if not is_on_floor() and Input.is_action_pressed("ui_accept"):
        _jetpack_active = try_use_jetpack(delta)
    jetpack_exhaust.visible = _jetpack_active

    move_and_slide()

    if Input.is_action_just_pressed("toggle_work_light"):
        set_work_light_enabled(not work_light_enabled)
    update_survival_resources(delta)

    _drill_cooldown = maxf(0.0, _drill_cooldown - delta)
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _drill_cooldown <= 0.0:
        _try_drill()
        _drill_cooldown = drill_interval


func _try_drill() -> bool:
    if terrain == null or battery < drill_battery_cost:
        return false
    var target := get_global_mouse_position()
    if global_position.distance_to(target) > drill_reach:
        return false
    # Prevent drilling a tile hidden behind another solid tile.
    var query := PhysicsRayQueryParameters2D.create(global_position, target, 1, [get_rid()])
    var hit := get_world_2d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return false
    var hit_position: Vector2 = hit.position - hit.normal * 1.0
    return try_excavate_at(hit_position)


func try_excavate_at(global_point: Vector2) -> bool:
    if terrain == null or battery < drill_battery_cost:
        return false
    if not terrain.excavate_global_point(global_point):
        return false
    try_spend_battery(drill_battery_cost)
    return true


func try_use_jetpack(delta: float) -> bool:
    if delta <= 0.0:
        return false
    if not try_spend_battery(jetpack_battery_per_second * delta):
        return false
    velocity.y = maxf(velocity.y - jetpack_acceleration * delta, -jetpack_max_rise_speed)
    return true


func update_survival_resources(delta: float) -> void:
    if delta <= 0.0:
        return

    if inside_ship:
        set_battery(battery + battery_recharge_per_second * delta)
        set_oxygen(oxygen + oxygen_refill_per_second * delta)
        return

    set_oxygen(oxygen - oxygen_drain_per_second * delta)
    if work_light_enabled:
        var light_cost := work_light_battery_per_second * delta
        if not try_spend_battery(light_cost):
            set_battery(0.0)
            set_work_light_enabled(false)


func set_inside_ship(is_inside: bool) -> void:
    inside_ship = is_inside


func set_battery(amount: float) -> void:
    var next_amount := clampf(amount, 0.0, maximum_battery)
    if is_equal_approx(next_amount, battery):
        return
    battery = next_amount
    battery_changed.emit(battery, maximum_battery)
    if battery <= 0.0 and work_light_enabled:
        set_work_light_enabled(false)


func set_oxygen(amount: float) -> void:
    var next_amount := clampf(amount, 0.0, maximum_oxygen)
    if is_equal_approx(next_amount, oxygen):
        return
    oxygen = next_amount
    oxygen_changed.emit(oxygen, maximum_oxygen)


func try_spend_battery(amount: float) -> bool:
    if amount <= 0.0:
        return true
    if battery + 0.0001 < amount:
        return false
    set_battery(battery - amount)
    return true


func set_work_light_enabled(enabled: bool) -> void:
    var next_enabled := enabled and battery > 0.0
    if next_enabled == work_light_enabled:
        return
    work_light_enabled = next_enabled
    work_light.visible = work_light_enabled
    work_light_changed.emit(work_light_enabled)


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
