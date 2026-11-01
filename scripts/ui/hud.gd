class_name DigHUD
extends CanvasLayer

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var cargo_label: Label = $MarginContainer/VBoxContainer/CargoLabel
@onready var battery_label: Label = $MarginContainer/VBoxContainer/BatteryLabel
@onready var oxygen_label: Label = $MarginContainer/VBoxContainer/OxygenLabel
@onready var light_label: Label = $MarginContainer/VBoxContainer/LightLabel
@onready var credits_label: Label = $MarginContainer/VBoxContainer/CreditsLabel
@onready var fuel_label: Label = $MarginContainer/VBoxContainer/FuelLabel
@onready var economy_label: Label = $MarginContainer/VBoxContainer/EconomyLabel
@onready var economy_hint_label: Label = $MarginContainer/VBoxContainer/EconomyHintLabel
@onready var descent_label: Label = $MarginContainer/VBoxContainer/DescentLabel
@onready var descent_hint_label: Label = $MarginContainer/VBoxContainer/DescentHintLabel


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


func set_credits(credits: int) -> void:
    credits_label.text = "CREDITS: %d" % credits


func set_fuel(amount: int, capacity: int) -> void:
    fuel_label.text = "FUEL: %d / %d" % [amount, capacity]
    fuel_label.modulate = Color("#ef7b62") if amount <= 0 else Color.WHITE


func set_economy_rates(ore_price: int, fuel_price: int) -> void:
    economy_hint_label.text = "E: SELL CARGO (%d CR/ORE)    B: BUY FUEL (%d CR)" % [ore_price, fuel_price]


func show_economy_message(message: String, success: bool) -> void:
    economy_label.text = message
    economy_label.modulate = Color("#8fd694") if success else Color("#ef7b62")


func set_descent_rows(rows: int) -> void:
    descent_label.text = "DESCENT: %d ROWS" % rows


func set_descent_rates(empty_cost: int, drilling_cost: int) -> void:
    descent_hint_label.text = "R: LOWER SHIP (%d FUEL CLEAR / %d FUEL BLOCKED)" % [empty_cost, drilling_cost]
