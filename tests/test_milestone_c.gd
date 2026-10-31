extends SceneTree
## Headless regression coverage for the Milestone C economy loop.

var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(condition: bool, message: String) -> void:
    _checks += 1
    if condition:
        print("PASS: %s" % message)
    else:
        _failures.append(message)
        push_error("FAIL: %s" % message)


func _run() -> void:
    var world_scene := load("res://scenes/world/world.tscn") as PackedScene
    _check(world_scene != null, "world scene loads")
    if world_scene == null:
        _finish()
        return

    var world := world_scene.instantiate()
    root.add_child(world)
    await process_frame
    for _frame in range(3):
        await physics_frame

    var player := world.get_node("Player") as DigPlayer
    var ship := world.get_node("DrillShip") as DrillShip
    var economy := world.get_node("Economy") as DigEconomy
    var hud := world.get_node("HUD") as DigHUD
    player.set_physics_process(false)

    _check(player != null and ship != null and economy != null and hud != null, "economy scenes are wired")
    _check(InputMap.has_action("sell_cargo") and InputMap.has_action("buy_fuel"), "economy input actions exist")
    var sell_events := InputMap.action_get_events("sell_cargo")
    var fuel_events := InputMap.action_get_events("buy_fuel")
    _check(not sell_events.is_empty() and sell_events[0] is InputEventKey and (sell_events[0] as InputEventKey).physical_keycode == KEY_E, "E key sells cargo")
    _check(not fuel_events.is_empty() and fuel_events[0] is InputEventKey and (fuel_events[0] as InputEventKey).physical_keycode == KEY_B, "B key buys fuel")
    _check(economy.credits == 0 and ship.fuel == 0, "economy starts empty")
    _check(hud.credits_label.text == "CREDITS: 0" and hud.fuel_label.text == "FUEL: 0 / 10", "HUD shows initial economy state")
    _check(hud.economy_hint_label.text.contains("10 CR/ORE") and hud.economy_hint_label.text.contains("25 CR"), "HUD shows configurable prices")

    _check(player.try_collect_ore(3), "player can carry ore for sale")
    _check(world.call("try_sell_cargo"), "cargo sells inside the ship")
    _check(player.ore_carried == 0, "sale unloads all cargo")
    _check(economy.credits == 3 * economy.ore_sale_price, "sale awards configured credits")
    _check(hud.cargo_label.text == "ORE: 0 / 8" and hud.credits_label.text == "CREDITS: 30", "HUD updates after sale")
    _check(hud.economy_label.text == "SOLD 3 ORE FOR 30 CREDITS", "HUD reports sale receipt")

    var credits_after_sale := economy.credits
    _check(not world.call("try_sell_cargo"), "empty cargo cannot be sold")
    _check(economy.credits == credits_after_sale and hud.economy_label.text == "NO ORE TO SELL", "empty sale preserves credits and explains failure")

    player.global_position = Vector2(1000.0, -1000.0)
    for _frame in range(3):
        await physics_frame
    _check(not player.inside_ship, "player can leave ship services")
    _check(player.try_collect_ore(2), "player can carry another load")
    _check(not world.call("try_sell_cargo"), "cargo cannot be sold outside the ship")
    _check(player.ore_carried == 2 and economy.credits == credits_after_sale, "failed remote sale keeps cargo and credits")
    _check(not world.call("try_buy_fuel"), "fuel cannot be bought outside the ship")

    player.global_position = ship.global_position + Vector2(0.0, -52.0)
    for _frame in range(3):
        await physics_frame
    _check(player.inside_ship, "returning to the ship restores services")
    _check(world.call("try_buy_fuel"), "fuel purchase succeeds with enough credits")
    _check(ship.fuel == 1 and economy.credits == 5, "fuel purchase transfers credits into ship fuel")
    _check(hud.fuel_label.text == "FUEL: 1 / 10" and hud.credits_label.text == "CREDITS: 5", "HUD updates after fuel purchase")

    _check(not world.call("try_buy_fuel"), "insufficient credits block fuel purchase")
    _check(ship.fuel == 1 and economy.credits == 5, "failed fuel purchase preserves both balances")
    _check(hud.economy_label.text == "NEED 25 CREDITS FOR FUEL", "HUD explains insufficient credits")

    economy.add_credits(economy.fuel_purchase_cost(ship.fuel_capacity - ship.fuel))
    while ship.fuel < ship.fuel_capacity:
        _check(world.call("try_buy_fuel"), "fuel tank accepts a purchased unit")
    var credits_at_full := economy.credits
    _check(not world.call("try_buy_fuel"), "full fuel tank rejects purchases")
    _check(economy.credits == credits_at_full and ship.fuel == ship.fuel_capacity, "full-tank rejection does not spend credits")
    _check(hud.economy_label.text == "FUEL TANK FULL", "HUD explains full fuel tank")

    _check(ship.try_consume_fuel(2), "ship can consume stored fuel for future descent")
    _check(ship.fuel == ship.fuel_capacity - 2, "fuel consumption updates reserve")
    var fuel_after_consumption := ship.fuel
    _check(not ship.try_consume_fuel(ship.fuel_capacity), "ship cannot over-consume fuel")
    _check(ship.fuel == fuel_after_consumption, "failed fuel consumption preserves reserve")
    _check(economy.sell_ore(0) == 0 and economy.fuel_purchase_cost(0) == 0, "invalid economy amounts are harmless")
    _check(not ship.add_fuel(0) and not ship.try_consume_fuel(0), "invalid fuel amounts are rejected")

    world.queue_free()
    await process_frame
    _finish()


func _finish() -> void:
    if _failures.is_empty():
        print("RESULT: %d checks, 0 failures" % _checks)
        quit(0)
    else:
        print("RESULT: %d checks, %d failures" % [_checks, _failures.size()])
        quit(1)
