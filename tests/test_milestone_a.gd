extends SceneTree
## Headless regression coverage for the complete Milestone A loop.

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
    await physics_frame

    var terrain := world.get_node("Terrain") as DigTerrain
    var player := world.get_node("Player") as DigPlayer
    var collectibles := world.get_node("Collectibles") as Node2D
    var hud := world.get_node("HUD") as DigHUD
    player.set_physics_process(false)
    _check(terrain != null and player != null, "terrain and player are wired")
    _check(collectibles != null and hud != null, "collectibles and HUD are wired")
    _check(player.cargo_capacity == 8, "cargo capacity defaults to eight ore")
    _check(hud.cargo_label.text == "ORE: 0 / 8", "HUD shows empty cargo capacity")

    var ore_cell := Vector2i.ZERO
    var found_ore := false
    for cell in terrain.get_used_cells():
        if terrain.get_cell_atlas_coords(cell) == DigTerrain.ORE:
            ore_cell = cell
            found_ore = true
            break
    _check(found_ore, "test map contains ore")

    if found_ore:
        var expected_position := terrain.to_global(terrain.map_to_local(ore_cell))
        var count_before := collectibles.get_child_count()
        _check(terrain.excavate_cell(ore_cell), "ore tile can be excavated")
        await process_frame
        _check(terrain.get_cell_source_id(ore_cell) == -1, "excavated ore tile is removed")
        _check(collectibles.get_child_count() == count_before + 1, "excavated ore spawns one pickup")

        var pickup := collectibles.get_child(collectibles.get_child_count() - 1) as Area2D
        _check(pickup != null and pickup.scene_file_path.ends_with("ore_pickup.tscn"), "spawned collectible is an ore pickup")
        if pickup != null:
            _check(pickup.global_position.is_equal_approx(expected_position), "pickup spawns at the excavated cell")
            player.global_position = pickup.global_position
            for _frame in range(3):
                await physics_frame
            await process_frame
            _check(player.ore_carried == 1, "walking over ore adds it to cargo")
            _check(not is_instance_valid(pickup), "collected ore leaves the world")
            _check(hud.cargo_label.text == "ORE: 1 / 8", "HUD updates after collection")

    _check(player.try_collect_ore(player.cargo_capacity - player.ore_carried), "cargo can be filled to capacity")
    _check(player.is_cargo_full(), "player reports full cargo")
    _check(hud.cargo_label.text.contains("CARGO FULL"), "HUD clearly reports full cargo")

    var full_pickup := world.call("spawn_ore_pickup", Vector2i.ZERO) as Area2D
    player.global_position = full_pickup.global_position + Vector2(48.0, 0.0)
    for _frame in range(2):
        await physics_frame
    player.global_position = full_pickup.global_position
    for _frame in range(3):
        await physics_frame
    await process_frame
    _check(is_instance_valid(full_pickup), "ore remains in the world when cargo is full")
    _check(player.ore_carried == player.cargo_capacity, "full cargo cannot overfill")
    _check(not player.try_collect_ore(0), "invalid ore amounts are rejected")

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
