# DIG: v0.1 Godot architecture

## Purpose

Organize the **agreed v0.1 prototype** without implementing every system up front.

Core prototype loop: **Dig → Collect → Return → Sell → Refuel → Descend → Repeat.**

The current commit establishes the scene ownership and data boundaries; it is not a playable mining loop yet.

## Scene tree

```text
World (Node2D)
├── Terrain (TileMapLayer)             [terrain.gd]
├── DrillShip (AnimatableBody2D)       [drill_ship.tscn]
│   ├── CollisionShape2D              [deck collision only, temporary]
│   ├── Deck / Roof / HullLeft / HullRight (Polygon2D placeholders)
│   └── SafeZone (Area2D)
│       └── CollisionShape2D
├── Player (CharacterBody2D)           [player.tscn]
│   ├── CollisionShape2D
│   ├── Visuals (Polygon2D)
│   ├── DrillRay (RayCast2D, disabled until mining)
│   └── Camera2D
├── DebugGround (StaticBody2D)         [TEMPORARY; remove when terrain has collision]
│   ├── CollisionShape2D
│   └── Visuals (Polygon2D)
├── Collectibles (Node2D)             [empty container]
├── Economy (Node)                     [economy.gd]
└── HUD (CanvasLayer)                  [hud.tscn]
```

## Separation of responsibilities

- **Terrain** owns tile lookup and removal. The player's drill and ship's drill will call the same public excavation API. Neither should call `erase_cell()` directly.
- **Player** owns movement and, later, drill input, carried ore, oxygen, and shared battery. Ship-specific economics should not live here.
- **DrillShip** owns the safe zone and, later, fuel-funded descent. Its physical movement should occur independently of the terrain's tile removal implementation.
- **Economy** owns credits and spending. Later, ore sales and fuel costs use the same balance API. Corporate debt and interest are out of v0.1.
- **World** wires together scenes and gameplay events, without duplicating their core logic.
- **HUD** displays state; it should not calculate game rules.

**Note on the ship:** This initial scene represents the ship as a deck and a safe-zone trigger. A functioning airlock, interior collision layout, and ship descent are intentionally not built yet.

## Implementation order

1. **Milestone A: Diggable world.** Add terrain tiles and collisions, drill targeting, tile excavation, finite ore, pickups, and carrying capacity. Delete the temporary `DebugGround` once a traversable tile map works.
2. **Milestone B: Survival.** Add a shared battery for drill/light/jetpack, oxygen drain outside, ship recharging, and ship entry/exit behavior.
3. **Milestone C: Economy.** Unload and sell ore, track credits, buy fuel.
4. **Milestone D: Descent.** Lower the ship through empty terrain cheaply or remove a row across its footprint at a higher fuel cost when obstructed. Test moving the player and safe zone with the ship.

## Deliberately deferred

Procedural generation, enemy pockets and combat, ship damage, crushers, smelters, player/ship upgrade trees, debt/interest, story events, and final artwork.

## Implementation notes

- This project was created in Godot **4.7** (Compatibility renderer). Preserve that starting configuration.
- The `TileMapLayer` has no `TileSet` yet; the excavate method safely returns `false` until terrain is populated.
- Treat every resource capacity, rate, tile size, and sale price as a playtest variable, **not** a locked design choice.
- Temporary placeholder geometry is only for scene/signal validation, not an art direction.
