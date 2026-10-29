class_name DigHUD
extends CanvasLayer
## Display-only UI. Gameplay state stays with its owning system.

@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel


func set_ship_status(is_inside: bool) -> void:
    if is_inside:
        status_label.text = "LOCATION: SHIP SAFE ZONE"
    else:
        status_label.text = "LOCATION: OUTSIDE SHIP"
