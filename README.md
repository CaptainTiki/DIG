# DIG

*Dome Keeper, if the dome could move.*

## Current prototype status

**Milestones A through C complete:** temporary colored TileMapLayer terrain, movement and jetpack flight, battery-powered drilling and work light, oxygen drain outside the ship, ship recharge/refill, persistent loose ore pickups, limited cargo, ore sales, credits, and purchasable ship fuel. The test world is finite and the temporary ship is stationary.

**Not implemented:** ship descent, enemies, refining, and corporate debt.

Open in **Godot 4.7** and press F5.

Controls: Left/Right movement, Space/Enter jump, hold Space in the air to jetpack, F to toggle the work light, hold Left Mouse near a terrain tile to drill, and walk over loose ore to collect it. Inside the ship, E sells all cargo and B buys one fuel unit. A raycast prevents mining through other solid tiles.

The TileSet and terrain map are intentionally generated from GDScript so no external art assets are required. Colors and balance values are temporary, and the script is designed for replacement with an authored tile atlas later.

See `docs/ARCHITECTURE.md` for scene boundaries and planned milestones.

Milestones A through C are covered by the matching scripts in `tests/`, validated headlessly in Godot 4.7.2.
