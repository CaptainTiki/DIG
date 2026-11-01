class_name DrillShip
extends AnimatableBody2D
## The ship's body will move through the world in milestone D.
## Its safe zone supplies oxygen and battery recharge through player signals.

signal player_entered
signal player_exited
signal fuel_changed(amount: int, capacity: int)
signal descent_completed(rows_descended: int, cells_cleared: int, fuel_spent: int)

@export_range(1, 99, 1) var fuel_capacity: int = 10
@export_range(0, 99, 1) var starting_fuel: int = 0
@export_group("Descent")
@export var descent_step: float = 24.0
@export var drill_width: float = 240.0
@export var drill_probe_below_origin: float = 21.0
@export_range(1, 99, 1) var empty_descent_fuel_cost: int = 1
@export_range(1, 99, 1) var drilling_descent_fuel_cost: int = 3

var fuel: int = 0
var descent_rows: int = 0
var terrain: DigTerrain


func _ready() -> void:
    fuel = clampi(starting_fuel, 0, fuel_capacity)


func _on_safe_zone_body_entered(body: Node2D) -> void:
    if body is DigPlayer:
        player_entered.emit()


func _on_safe_zone_body_exited(body: Node2D) -> void:
    if body is DigPlayer:
        player_exited.emit()


func can_add_fuel(units: int = 1) -> bool:
    return units > 0 and fuel + units <= fuel_capacity


func add_fuel(units: int = 1) -> bool:
    if not can_add_fuel(units):
        return false
    fuel += units
    fuel_changed.emit(fuel, fuel_capacity)
    return true


func try_consume_fuel(units: int = 1) -> bool:
    if units <= 0 or fuel < units:
        return false
    fuel -= units
    fuel_changed.emit(fuel, fuel_capacity)
    return true


func get_descent_probe_rect() -> Rect2:
    var target_origin_y := global_position.y + descent_step
    var probe_y := target_origin_y + drill_probe_below_origin
    return Rect2(
        Vector2(global_position.x - drill_width * 0.5, probe_y - 0.5),
        Vector2(drill_width, 1.0)
    )


func get_descent_obstacles() -> Array[Vector2i]:
    if terrain == null:
        return []
    return terrain.occupied_cells_in_global_rect(get_descent_probe_rect())


func get_descent_fuel_cost() -> int:
    return drilling_descent_fuel_cost if not get_descent_obstacles().is_empty() else empty_descent_fuel_cost


func try_descend(rider: DigPlayer = null) -> bool:
    if terrain == null:
        return false

    var obstacles := get_descent_obstacles()
    var fuel_cost := drilling_descent_fuel_cost if not obstacles.is_empty() else empty_descent_fuel_cost
    if not try_consume_fuel(fuel_cost):
        return false

    var cells_cleared := terrain.excavate_cells(obstacles)
    var descent_delta := Vector2(0.0, descent_step)
    global_position += descent_delta
    if rider != null and rider.inside_ship:
        rider.global_position += descent_delta

    descent_rows += 1
    descent_completed.emit(descent_rows, cells_cleared, fuel_cost)
    return true
