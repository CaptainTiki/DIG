class_name DigHUD
extends CanvasLayer

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var cargo_label: Label = $MarginContainer/VBoxContainer/CargoLabel


func set_ship_status(is_inside: bool) -> void:
    status_label.text = "LOCATION: SHIP SAFE ZONE" if is_inside else "LOCATION: OUTSIDE SHIP"


func set_cargo(amount: int) -> void:
    cargo_label.text = "ORE: %d" % amount
