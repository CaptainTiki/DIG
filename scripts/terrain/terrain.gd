class_name DigTerrain
extends TileMapLayer
## Temporary procedural test terrain; one excavation API for player and ship.

signal cell_excavated(map_cell: Vector2i, was_ore: bool)

const CELL_SIZE := 24
const SOURCE_ID := 0
const DIRT := Vector2i(0, 0)
const STONE := Vector2i(1, 0)
const ORE := Vector2i(2, 0)

@export var generate_test_map: bool = true


func _ready() -> void:
    _build_test_tileset()
    if generate_test_map:
        _populate_test_map()


func _build_test_tileset() -> void:
    var atlas_image := Image.create_empty(CELL_SIZE * 3, CELL_SIZE, false, Image.FORMAT_RGBA8)
    var shades := [Color("#73513d"), Color("#55616a"), Color("#bb9352")]
    for i in range(3):
        atlas_image.fill_rect(Rect2i(i * CELL_SIZE, 0, CELL_SIZE, CELL_SIZE), shades[i])
        # A small inset border gives untextured test blocks definition.
        atlas_image.fill_rect(Rect2i(i * CELL_SIZE + 2, 2, CELL_SIZE - 4, 2), shades[i].lightened(0.14))
        atlas_image.fill_rect(Rect2i(i * CELL_SIZE + 2, CELL_SIZE - 4, CELL_SIZE - 4, 2), shades[i].darkened(0.18))

    var tiles := TileSet.new()
    tiles.tile_size = Vector2i(CELL_SIZE, CELL_SIZE)
    tiles.add_physics_layer()
    tiles.set_physics_layer_collision_layer(0, 1)

    var atlas := TileSetAtlasSource.new()
    atlas.texture = ImageTexture.create_from_image(atlas_image)
    atlas.texture_region_size = Vector2i(CELL_SIZE, CELL_SIZE)
    for i in range(3):
        var coordinates := Vector2i(i, 0)
        atlas.create_tile(coordinates)
        var data := atlas.get_tile_data(coordinates, 0)
        data.add_collision_polygon(0)
        data.set_collision_polygon_points(0, 0, PackedVector2Array([
            Vector2(-12, -12), Vector2(12, -12),
            Vector2(12, 12), Vector2(-12, 12)
        ]))

    tiles.add_source(atlas, SOURCE_ID)
    tile_set = tiles


func _populate_test_map() -> void:
    for y in range(6, 33):
        for x in range(-22, 23):
            # Deterministic deposits for debugging; no procedural world generation yet.
            var tile_kind := DIRT
            if y > 15 and (x * 7 + y * 11) % 9 == 0:
                tile_kind = STONE
            if (x * 13 + y * 17) % 23 == 0:
                tile_kind = ORE
            set_cell(Vector2i(x, y), SOURCE_ID, tile_kind)


func excavate_cell(map_cell: Vector2i) -> bool:
    if tile_set == null or get_cell_source_id(map_cell) == -1:
        return false

    var is_ore := get_cell_atlas_coords(map_cell) == ORE
    erase_cell(map_cell)
    cell_excavated.emit(map_cell, is_ore)
    return true


func excavate_global_point(global_point: Vector2) -> bool:
    if tile_set == null:
        return false
    return excavate_cell(local_to_map(to_local(global_point)))
