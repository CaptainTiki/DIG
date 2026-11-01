# Milestone D: Mobile drill ship

**Status: complete and validated in Godot 4.7.2.**

- Press R inside the ship to descend one 24-pixel terrain row.
- Descending through a manually cleared shaft costs one fuel.
- A blocked descent costs three fuel and excavates the ship's full 240-pixel footprint.
- Excavated ore still spawns as loose pickups through Terrain's shared excavation API.
- The player and safe zone move with the ship; remote operation is blocked.
- The HUD reports descent rows, fuel rules, success receipts, and failure reasons.
- Descent step, footprint, and both fuel costs remain exported playtest variables.

### Testing checklist in Godot 4.7

1. Mine and sell a full cargo, then buy three fuel.
2. Press R inside the ship with terrain beneath it; the drill should clear one row and the ship should descend.
3. Manually clear the next full row beneath the ship, buy one fuel, and press R; the ship should descend cheaply without drilling.
4. Confirm the player, hull, safe zone, HUD depth, and camera all move together.
5. Try descending outside the ship or without enough fuel; nothing should move or be consumed.

Run the complete regression set with:

```text
godot --headless --path . --script res://tests/test_milestone_a.gd
godot --headless --path . --script res://tests/test_milestone_b.gd
godot --headless --path . --script res://tests/test_milestone_c.gd
godot --headless --path . --script res://tests/test_milestone_d.gd
```

### Next work

Playtest several complete loops. Tune movement, oxygen, battery, prices, fuel costs, and descent pacing before adding more systems or replacing the placeholder visuals.
