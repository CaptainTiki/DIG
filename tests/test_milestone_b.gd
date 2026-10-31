extends SceneTree
## Headless regression coverage for the Milestone B survival loop.

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

    var terrain := world.get_node("Terrain") as DigTerrain
    var player := world.get_node("Player") as DigPlayer
    var ship := world.get_node("DrillShip") as DrillShip
    var hud := world.get_node("HUD") as DigHUD
    player.set_physics_process(false)

    _check(terrain != null and player != null and ship != null and hud != null, "survival scenes are wired")
    _check(InputMap.has_action("toggle_work_light"), "work-light input action exists")
    var light_events := InputMap.action_get_events("toggle_work_light")
    _check(not light_events.is_empty() and light_events[0] is InputEventKey and (light_events[0] as InputEventKey).physical_keycode == KEY_F, "F key toggles the work light")
    _check(is_equal_approx(player.battery, player.maximum_battery), "battery starts full")
    _check(is_equal_approx(player.oxygen, player.maximum_oxygen), "oxygen starts full")
    _check(player.inside_ship, "player starts inside the ship")
    _check(hud.status_label.text.contains("RECHARGING"), "HUD reports ship recharge state")
    _check(player.work_light.visible and not player.jetpack_exhaust.visible, "survival visuals start correctly")

    player.global_position = Vector2(1000.0, -1000.0)
    for _frame in range(3):
        await physics_frame
    _check(not player.inside_ship, "leaving the safe zone switches to outside state")
    _check(hud.status_label.text == "LOCATION: OUTSIDE SHIP", "HUD reports safe-zone exit")

    player.set_work_light_enabled(false)
    player.set_battery(player.maximum_battery)
    player.set_oxygen(player.maximum_oxygen)
    player.update_survival_resources(2.0)
    _check(is_equal_approx(player.oxygen, player.maximum_oxygen - player.oxygen_drain_per_second * 2.0), "oxygen drains outside")
    _check(is_equal_approx(player.battery, player.maximum_battery), "battery does not drain with idle light off")

    player.set_work_light_enabled(true)
    var battery_before_light := player.battery
    player.update_survival_resources(2.0)
    _check(is_equal_approx(player.battery, battery_before_light - player.work_light_battery_per_second * 2.0), "work light drains shared battery")
    _check(hud.light_label.text == "WORK LIGHT: ON", "HUD reports work-light state")

    player.set_work_light_enabled(false)
    player.set_battery(player.maximum_battery)
    var drill_cell := terrain.get_used_cells()[0]
    var drill_point := terrain.to_global(terrain.map_to_local(drill_cell))
    _check(player.try_excavate_at(drill_point), "drill excavates with available battery")
    _check(terrain.get_cell_source_id(drill_cell) == -1, "battery-powered drilling removes terrain")
    _check(is_equal_approx(player.battery, player.maximum_battery - player.drill_battery_cost), "drill spends shared battery")

    var blocked_cell := terrain.get_used_cells()[0]
    var blocked_point := terrain.to_global(terrain.map_to_local(blocked_cell))
    player.set_battery(0.0)
    _check(not player.try_excavate_at(blocked_point), "empty battery blocks drilling")
    _check(terrain.get_cell_source_id(blocked_cell) != -1, "blocked drill leaves terrain intact")

    player.set_battery(20.0)
    player.velocity = Vector2.ZERO
    _check(player.try_use_jetpack(0.5), "jetpack activates with available battery")
    _check(player.velocity.y < 0.0, "jetpack produces upward thrust")
    _check(is_equal_approx(player.battery, 20.0 - player.jetpack_battery_per_second * 0.5), "jetpack spends shared battery")
    player.set_battery(0.0)
    _check(not player.try_use_jetpack(0.5), "empty battery blocks jetpack thrust")

    player.set_battery(0.5)
    player.set_work_light_enabled(true)
    player.update_survival_resources(1.0)
    _check(is_zero_approx(player.battery), "light consumes the final partial battery")
    _check(not player.work_light_enabled and not player.work_light.visible, "work light shuts off at empty battery")

    player.set_battery(10.0)
    player.set_oxygen(20.0)
    player.global_position = ship.global_position + Vector2(0.0, -52.0)
    for _frame in range(3):
        await physics_frame
    _check(player.inside_ship, "entering the safe zone restores inside state")
    player.update_survival_resources(2.0)
    _check(is_equal_approx(player.battery, 10.0 + player.battery_recharge_per_second * 2.0), "ship recharges battery")
    _check(is_equal_approx(player.oxygen, 20.0 + player.oxygen_refill_per_second * 2.0), "ship refills oxygen")
    _check(hud.battery_label.text == "BATTERY: 70 / 100", "HUD tracks battery recharge")
    _check(hud.oxygen_label.text == "OXYGEN: 70 / 100", "HUD tracks oxygen refill")

    player.update_survival_resources(20.0)
    _check(is_equal_approx(player.battery, player.maximum_battery), "battery recharge clamps at maximum")
    _check(is_equal_approx(player.oxygen, player.maximum_oxygen), "oxygen refill clamps at maximum")

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
