# Milestone A: First digging pass

This is a **work-in-progress implementation**, based on the v0.1 architecture scaffold.

- The `DigTerrain` TileMapLayer constructs three simple test tiles (dirt, stone, ore) and collisions at runtime.
- The test map is finite and deterministic, not a production world generator.
- The player digs tiles within a limited reach using a left-mouse hold. Collision raycasting prevents drilling through intact foreground tiles.
- Breaking an ore tile immediately increments a simple carried-ore counter. Physical pickups and cargo limits are deferred.
- The hull, deck, and safe-zone arrangement from the architecture branch are unchanged.
- Ship descent, extraction value, battery and O2 remain unimplemented.

### Testing checklist in Godot 4.7

1. Open the project with the feature branch checked out and run F5.
2. Walk off the deck onto the colored terrain beside the ship.
3. Click a nearby solid tile; the tile should disappear and lose collision.
4. Try clicking an ore-colored tile; the HUD's ORE count should increment.
5. Click beyond drilling reach or through a wall; no tile should disappear.
6. Return to the ship; the HUD safe-zone label should switch.

If the editor reports a syntax/API error, capture the error and line number before merging. No Godot runtime was available for automated testing.

### Next work

Make the terrain easier to explore (jetpack), add proper pickups and limited inventory, then the O2/battery loop. Keep the ship descent and economy in later milestones.
