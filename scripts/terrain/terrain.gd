class_name DigTerrain
extends TileMapLayer
## Shared terrain access point for both the handheld drill and the ship drill.
## This is an API stub; a TileSet and actual mining come in milestone A.

signal cell_excavated(map_cell: Vector2i)


func excavate_cell(map_cell: Vector2i) -> bool:
    if tile_set == null or get_cell_source_id(map_cell) == -1:
        return false

    erase_cell(map_cell)
    cell_excavated.emit(map_cell)
    return true


func excavate_global_point(global_point: Vector2) -> bool:
    if tile_set == null:
        return false

    return excavate_cell(local_to_map(to_local(global_point)))
