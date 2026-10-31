class_name DrillShip
extends AnimatableBody2D
## The ship's body will move through the world in milestone D.
## Its safe zone supplies oxygen and battery recharge through player signals.

signal player_entered
signal player_exited
signal fuel_changed(amount: int, capacity: int)

@export_range(1, 99, 1) var fuel_capacity: int = 10
@export_range(0, 99, 1) var starting_fuel: int = 0

var fuel: int = 0


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
