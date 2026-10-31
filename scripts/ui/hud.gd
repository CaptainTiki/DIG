class_name DigHUD
extends CanvasLayer

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var cargo_label: Label = $MarginContainer/VBoxContainer/CargoLabel
@onready var battery_label: Label = $MarginContainer/VBoxContainer/BatteryLabel
@onready var oxygen_label: Label = $MarginContainer/VBoxContainer/OxygenLabel
@onready var light_label: Label = $MarginContainer/VBoxContainer/LightLabel


func set_ship_status(is_inside: bool) -> void:
    status_label.text = "LOCATION: SHIP SAFE ZONE — RECHARGING" if is_inside else "LOCATION: OUTSIDE SHIP"


func set_cargo(amount: int, capacity: int) -> void:
    if amount >= capacity:
        cargo_label.text = "ORE: %d / %d  CARGO FULL" % [amount, capacity]
        cargo_label.modulate = Color("#f0a35e")
    else:
        cargo_label.text = "ORE: %d / %d" % [amount, capacity]
        cargo_label.modulate = Color.WHITE


func set_battery(amount: float, maximum: float) -> void:
    battery_label.text = "BATTERY: %d / %d" % [roundi(amount), roundi(maximum)]
    battery_label.modulate = Color("#ef7b62") if amount <= maximum * 0.25 else Color.WHITE


func set_oxygen(amount: float, maximum: float) -> void:
    oxygen_label.text = "OXYGEN: %d / %d" % [roundi(amount), roundi(maximum)]
    oxygen_label.modulate = Color("#ef7b62") if amount <= maximum * 0.25 else Color.WHITE


func set_work_light(enabled: bool) -> void:
    light_label.text = "WORK LIGHT: ON" if enabled else "WORK LIGHT: OFF"
    light_label.modulate = Color("#f2cd79") if enabled else Color("#8d99a6")
