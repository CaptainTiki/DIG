# DIG

A 2D mining game prototype: *Dome Keeper, if the dome could move.*

The player excavates finite resources, returns to an enormous mobile drill ship, and eventually pays to move the ship deeper underground. The corporation owns the equipment. The operator is replaceable.

## Current state

**v0.1 architecture scaffold, not yet the mining prototype.**

The project currently contains a runnable scene with:
- A player that can move left/right and jump using Godot's default UI actions.
- A physical drill-ship deck and a safe-zone area with entry/exit signals.
- An empty `TileMapLayer` prepared to own excavation.
- A temporary solid floor so the scene is navigable without terrain tiles.
- A HUD showing whether the player is in the ship's safe zone.
- A small economy class prepared to track credits.

There is **no mining, ore, fuel, descending, oxygen, battery, combat, or jetpack yet**. Those are later implementation steps.

### Run

Open `project.godot` in **Godot 4.7** and press **F6** in `scenes/world/world.tscn`, or press **F5** to run the configured main scene.

Use **Left / Right** to move and **Space / Enter** to jump. These temporarily use Godot's built-in `ui_left`, `ui_right`, and `ui_accept` actions.

## Layout

```text
scenes/
  world/world.tscn           Main scene, temporary test floor
  player/player.tscn         Player body, collision, camera, drill ray placeholder
  drill_ship/drill_ship.tscn Moving-platform foundation, safe-zone area
  ui/hud.tscn                Basic test HUD
scripts/
  world/world.gd             Wires ship signals to HUD
  terrain/terrain.gd         Shared terrain excavation entry point
  player/player.gd           Basic movement only
  drill_ship/drill_ship.gd   Safe-zone events; descent not implemented
  economy/economy.gd         Credits API; not yet connected to ore
  ui/hud.gd                  Displays ship safe-zone status
docs/
  ARCHITECTURE.md            Boundaries and planned v0.1 implementation steps
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for implementation boundaries.
