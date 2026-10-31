extends Node2D
## Composition root: connects independent scenes.

const ORE_PICKUP_SCENE := preload("res://scenes/collectibles/ore_pickup.tscn")

@onready var terrain: DigTerrain = $Terrain
@onready var player: DigPlayer = $Player
@onready var drill_ship: DrillShip = $DrillShip
@onready var collectibles: Node2D = $Collectibles
@onready var economy: DigEconomy = $Economy
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
    economy.credits_changed.connect(hud.set_credits)
    drill_ship.fuel_changed.connect(hud.set_fuel)
    player.set_inside_ship(true)
    hud.set_cargo(player.ore_carried, player.cargo_capacity)
    hud.set_battery(player.battery, player.maximum_battery)
    hud.set_oxygen(player.oxygen, player.maximum_oxygen)
    hud.set_work_light(player.work_light_enabled)
    hud.set_credits(economy.credits)
    hud.set_fuel(drill_ship.fuel, drill_ship.fuel_capacity)
    hud.set_economy_rates(economy.ore_sale_price, economy.fuel_unit_price)
    hud.show_economy_message("SHIP SERVICES READY", true)
    hud.set_ship_status(true)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_echo():
        return
    if event.is_action_pressed("sell_cargo"):
        try_sell_cargo()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("buy_fuel"):
        try_buy_fuel()
        get_viewport().set_input_as_handled()


func _on_cell_excavated(map_cell: Vector2i, was_ore: bool) -> void:
    if was_ore:
        spawn_ore_pickup(map_cell)


func spawn_ore_pickup(map_cell: Vector2i) -> Area2D:
    var pickup := ORE_PICKUP_SCENE.instantiate() as Area2D
    collectibles.add_child(pickup)
    pickup.global_position = terrain.to_global(terrain.map_to_local(map_cell))
    return pickup


func try_sell_cargo() -> bool:
    if not player.inside_ship:
        hud.show_economy_message("RETURN TO THE SHIP TO SELL ORE", false)
        return false
    if player.ore_carried <= 0:
        hud.show_economy_message("NO ORE TO SELL", false)
        return false

    var ore_sold := player.unload_all_ore()
    var earnings := economy.sell_ore(ore_sold)
    hud.show_economy_message("SOLD %d ORE FOR %d CREDITS" % [ore_sold, earnings], true)
    return true


func try_buy_fuel() -> bool:
    if not player.inside_ship:
        hud.show_economy_message("RETURN TO THE SHIP TO BUY FUEL", false)
        return false
    if not drill_ship.can_add_fuel():
        hud.show_economy_message("FUEL TANK FULL", false)
        return false

    var cost := economy.fuel_purchase_cost()
    if not economy.try_spend(cost):
        hud.show_economy_message("NEED %d CREDITS FOR FUEL" % cost, false)
        return false

    drill_ship.add_fuel()
    hud.show_economy_message("BOUGHT 1 FUEL FOR %d CREDITS" % cost, true)
    return true


func _on_player_entered_ship() -> void:
    player.set_inside_ship(true)
    hud.set_ship_status(true)


func _on_player_exited_ship() -> void:
    player.set_inside_ship(false)
    hud.set_ship_status(false)
