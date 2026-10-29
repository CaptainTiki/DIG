extends Node2D
## Composition root: connects independent scenes.

@onready var terrain: DigTerrain = $Terrain
@onready var player: DigPlayer = $Player
@onready var drill_ship: DrillShip = $DrillShip
@onready var hud: DigHUD = $HUD


func _ready() -> void:
    player.terrain = terrain
    drill_ship.player_entered.connect(_on_player_entered_ship)
    drill_ship.player_exited.connect(_on_player_exited_ship)
    terrain.cell_excavated.connect(_on_cell_excavated)
    player.ore_collected.connect(hud.set_cargo)
    hud.set_cargo(player.ore_carried)


func _on_cell_excavated(_cell: Vector2i, was_ore: bool) -> void:
    if was_ore:
        player.collect_ore()


func _on_player_entered_ship() -> void:
    hud.set_ship_status(true)


func _on_player_exited_ship() -> void:
    hud.set_ship_status(false)
