extends Node2D
## Composition root: connects independent scenes.

const ORE_PICKUP_SCENE := preload("res://scenes/collectibles/ore_pickup.tscn")

@onready var terrain: DigTerrain = $Terrain
@onready var player: DigPlayer = $Player
@onready var drill_ship: DrillShip = $DrillShip
@onready var collectibles: Node2D = $Collectibles
@onready var hud: DigHUD = $HUD


func _ready() -> void:
    player.terrain = terrain
    drill_ship.player_entered.connect(_on_player_entered_ship)
    drill_ship.player_exited.connect(_on_player_exited_ship)
    terrain.cell_excavated.connect(_on_cell_excavated)
    player.cargo_changed.connect(hud.set_cargo)
    player.battery_changed.connect(hud.set_battery)
    player.oxygen_changed.connect(hud.set_oxygen)
    player.work_light_changed.connect(hud.set_work_light)
    player.set_inside_ship(true)
    hud.set_cargo(player.ore_carried, player.cargo_capacity)
    hud.set_battery(player.battery, player.maximum_battery)
    hud.set_oxygen(player.oxygen, player.maximum_oxygen)
    hud.set_work_light(player.work_light_enabled)
    hud.set_ship_status(true)


func _on_cell_excavated(map_cell: Vector2i, was_ore: bool) -> void:
    if was_ore:
        spawn_ore_pickup(map_cell)


func spawn_ore_pickup(map_cell: Vector2i) -> Area2D:
    var pickup := ORE_PICKUP_SCENE.instantiate() as Area2D
    collectibles.add_child(pickup)
    pickup.global_position = terrain.to_global(terrain.map_to_local(map_cell))
    return pickup


func _on_player_entered_ship() -> void:
    player.set_inside_ship(true)
    hud.set_ship_status(true)


func _on_player_exited_ship() -> void:
    player.set_inside_ship(false)
    hud.set_ship_status(false)
