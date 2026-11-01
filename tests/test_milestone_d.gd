extends SceneTree
## Headless regression coverage for the Milestone D mobile drill ship.

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
    var safe_zone := ship.get_node("SafeZone") as Area2D
    var collectibles := world.get_node("Collectibles") as Node2D
    var hud := world.get_node("HUD") as DigHUD
    player.set_physics_process(false)

    _check(terrain != null and player != null and ship != null and safe_zone != null and hud != null, "descent scenes are wired")
    _check(ship.terrain == terrain, "ship uses the shared terrain excavation API")
    _check(InputMap.has_action("descend_ship"), "descent input action exists")
    var descent_events := InputMap.action_get_events("descend_ship")
    _check(not descent_events.is_empty() and descent_events[0] is InputEventKey and (descent_events[0] as InputEventKey).physical_keycode == KEY_R, "R key lowers the ship")
    _check(ship.descent_step == DigTerrain.CELL_SIZE, "one descent equals one terrain row")
    _check(hud.descent_label.text == "DESCENT: 0 ROWS", "HUD starts at zero descent")

    var initial_ship_position := ship.global_position
    var initial_player_position := player.global_position
    var initial_safe_zone_position := safe_zone.global_position
    var first_obstacles := ship.get_descent_obstacles()
    _check(not first_obstacles.is_empty(), "initial descent path is blocked by terrain")
    var footprint_is_bounded := true
    for cell in first_obstacles:
        var cell_center := terrain.to_global(terrain.map_to_local(cell))
        if absf(cell_center.x - ship.global_position.x) > ship.drill_width * 0.5 + DigTerrain.CELL_SIZE * 0.5:
            footprint_is_bounded = false
            break
    _check(footprint_is_bounded, "ship drill stays within the configured footprint and edge tiles")
    _check(ship.get_descent_fuel_cost() == ship.drilling_descent_fuel_cost, "blocked descent uses drilling fuel cost")
    _check(not world.call("try_descend_ship"), "ship cannot descend without enough fuel")
    _check(ship.global_position == initial_ship_position and ship.fuel == 0, "failed descent preserves position and fuel")
    _check(hud.economy_label.text == "NEED 3 FUEL TO DRILL DOWN", "HUD explains blocked descent cost")

    var ore_in_first_row := 0
    for cell in first_obstacles:
        if terrain.get_cell_atlas_coords(cell) == DigTerrain.ORE:
            ore_in_first_row += 1
    var collectibles_before := collectibles.get_child_count()
    _check(ship.add_fuel(ship.drilling_descent_fuel_cost), "ship can receive drilling fuel")
    _check(world.call("try_descend_ship"), "ship drill clears a blocked row and descends")
    await process_frame
    _check(ship.global_position == initial_ship_position + Vector2(0.0, ship.descent_step), "ship moves down one row")
    _check(player.global_position == initial_player_position + Vector2(0.0, ship.descent_step), "inside player moves with ship")
    _check(safe_zone.global_position == initial_safe_zone_position + Vector2(0.0, ship.descent_step), "safe zone moves with ship")
    _check(ship.fuel == 0 and ship.descent_rows == 1, "blocked descent consumes three fuel and advances depth")
    _check(hud.descent_label.text == "DESCENT: 1 ROWS", "HUD tracks completed descent")
    _check(collectibles.get_child_count() == collectibles_before + ore_in_first_row, "ship drill preserves ore as loose pickups")
    for cell in first_obstacles:
        _check(terrain.get_cell_source_id(cell) == -1, "ship drill removes each footprint cell")

    var clearable_obstacles := ship.get_descent_obstacles()
    _check(not clearable_obstacles.is_empty(), "next descent row begins blocked")
    terrain.excavate_cells(clearable_obstacles)
    _check(ship.get_descent_obstacles().is_empty(), "manual excavation creates a clear shaft")
    _check(ship.get_descent_fuel_cost() == ship.empty_descent_fuel_cost, "clear shaft uses cheap descent cost")
    _check(ship.add_fuel(ship.empty_descent_fuel_cost), "ship can receive clear-shaft fuel")
    var ship_before_clear_descent := ship.global_position
    var player_before_clear_descent := player.global_position
    _check(world.call("try_descend_ship"), "ship descends cheaply through cleared terrain")
    _check(ship.global_position == ship_before_clear_descent + Vector2(0.0, ship.descent_step), "clear descent moves ship one row")
    _check(player.global_position == player_before_clear_descent + Vector2(0.0, ship.descent_step), "clear descent carries player")
    _check(ship.fuel == 0 and ship.descent_rows == 2, "clear descent consumes one fuel")
    _check(hud.economy_label.text.contains("CLEAR SHAFT"), "HUD reports cheap clear-shaft descent")

    player.global_position = Vector2(1000.0, -1000.0)
    for _frame in range(3):
        await physics_frame
    var ship_before_remote_attempt := ship.global_position
    _check(not player.inside_ship, "player can leave the ship")
    _check(not world.call("try_descend_ship"), "ship cannot be operated remotely")
    _check(ship.global_position == ship_before_remote_attempt, "remote attempt does not move ship")

    player.global_position = safe_zone.global_position
    for _frame in range(3):
        await physics_frame
    _check(player.inside_ship, "player can return to ship controls")
    _check(not ship.get_descent_obstacles().is_empty(), "third descent path is blocked")
    _check(ship.add_fuel(1), "ship can hold partial drilling fuel")
    var ship_before_insufficient_attempt := ship.global_position
    _check(not world.call("try_descend_ship"), "partial fuel cannot power blocked descent")
    _check(ship.global_position == ship_before_insufficient_attempt and ship.fuel == 1, "insufficient attempt preserves ship and fuel")
    _check(ship.add_fuel(2), "ship can top up to drilling cost")
    _check(world.call("try_descend_ship"), "fully fueled ship completes another blocked descent")
    _check(ship.descent_rows == 3 and ship.fuel == 0, "third descent updates depth and fuel")

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
