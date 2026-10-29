# DIG

*Dome Keeper, if the dome could move.*

## Current prototype status

**Milestone A work in progress:** temporary colored TileMapLayer terrain, digging with left mouse button, and ore added to cargo when an ore tile is destroyed. World is finite for this test; the temporary ship is stationary.

**Not implemented:** physical loose pickups, cargo limits, oxygen, battery, jetpack, ship descent, fuel, selling, enemies, refining, and corporate debt.

Open in **Godot 4.7** and press F5.

Controls: Left/Right movement, Space/Enter jump, hold Left Mouse near a terrain tile to drill. A raycast prevents mining through other solid tiles.

The TileSet and terrain map are intentionally generated from GDScript so no external art assets are required. Colors and balance values are temporary, and the script is designed for replacement with an authored tile atlas later.

See `docs/ARCHITECTURE.md` for scene boundaries and planned milestones.

**Unverified:** The Godot runtime isn't available in the coding environment. This code must be opened and checked in Godot before considering the digging implementation complete.
