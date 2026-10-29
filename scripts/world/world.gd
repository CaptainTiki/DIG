extends Node2D
## Composition root: connect systems here rather than coupling them together.

@onready var drill_ship: DrillShip = $DrillShip
@onready var hud: DigHUD = $HUD


func _ready() -> void:
    drill_ship.player_entered.connect(_on_player_entered_ship)
    drill_ship.player_exited.connect(_on_player_exited_ship)


func _on_player_entered_ship() -> void:
    hud.set_ship_status(true)


func _on_player_exited_ship() -> void:
    hud.set_ship_status(false)
