# Milestone A: Diggable world

**Status: complete and validated in Godot 4.7.2.**

- The `DigTerrain` TileMapLayer constructs three simple test tiles (dirt, stone, ore) and collisions at runtime.
- The test map is finite and deterministic, not a production world generator.
- The player digs tiles within a limited reach using a left-mouse hold. Collision raycasting prevents drilling through intact foreground tiles.
- Breaking an ore tile spawns a persistent loose pickup at that cell.
- Walking over loose ore collects it when cargo has room. Full cargo leaves the pickup in the world.
- The player carries up to eight ore, and the HUD shows current capacity and a clear full state.
- The hull, deck, and safe-zone arrangement from the architecture branch are unchanged.
- Ship descent, extraction value, battery and O2 remain unimplemented.

### Testing checklist in Godot 4.7

1. Open the project on `main` and run F5.
2. Walk off the deck onto the colored terrain beside the ship.
3. Click a nearby solid tile; the tile should disappear and lose collision.
4. Drill an ore-colored tile; a loose gold pickup should appear in the excavated cell.
5. Walk over the pickup; the HUD should increment and the pickup should disappear.
6. Fill cargo to `8 / 8`; additional pickups should remain in the world.
7. Click beyond drilling reach or through a wall; no tile should disappear.
8. Return to the ship; the HUD safe-zone label should switch.

Run the repeatable regression check with:

```text
godot --headless --path . --script res://tests/test_milestone_a.gd
```

### Next work

Milestones B and C are now complete. Continue with Milestone D: fuel-funded ship descent and large-footprint excavation.
