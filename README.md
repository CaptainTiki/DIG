# DIG

*Dome Keeper, if the dome could move.*

## Current prototype status

**Milestone A complete:** temporary colored TileMapLayer terrain, movement and jumping, mouse-directed digging, persistent loose ore pickups, and an eight-slot cargo limit. Ore remains in the world when cargo is full. The test world is finite and the temporary ship is stationary.

**Not implemented:** oxygen, battery, jetpack, ship descent, fuel, selling, enemies, refining, and corporate debt.

Open in **Godot 4.7** and press F5.

Controls: Left/Right movement, Space/Enter jump, hold Left Mouse near a terrain tile to drill, and walk over loose ore to collect it. A raycast prevents mining through other solid tiles.

The TileSet and terrain map are intentionally generated from GDScript so no external art assets are required. Colors and balance values are temporary, and the script is designed for replacement with an authored tile atlas later.

See `docs/ARCHITECTURE.md` for scene boundaries and planned milestones.

Milestone A is covered by `tests/test_milestone_a.gd` and validated headlessly in Godot 4.7.2.
