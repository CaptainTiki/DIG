# DIG: v0.1 Godot architecture

## Purpose

Organize the **agreed v0.1 prototype** without implementing every system up front.

Core prototype loop: **Dig → Collect → Return → Sell → Refuel → Descend → Repeat.**

The current prototype supports digging, collection, survival resources, ore sales, and fuel purchases. Ship descent remains unfinished.

## Scene tree

```text
World (Node2D)
├── Terrain (TileMapLayer)             [terrain.gd]
├── DrillShip (AnimatableBody2D)       [drill_ship.tscn]
│   ├── CollisionShape2D              [deck collision only, temporary]
│   ├── Deck / Roof / HullLeft / HullRight (Polygon2D placeholders)
│   ├── Fuel reserve                   [capacity and consumption API]
│   └── SafeZone (Area2D)
│       └── CollisionShape2D
├── Player (CharacterBody2D)           [player.tscn]
│   ├── CollisionShape2D
│   ├── WorkLight (Polygon2D)
│   ├── JetpackExhaust (Node2D)
│   ├── Visuals (Polygon2D)
│   ├── DrillRay (RayCast2D, reserved; runtime drilling uses a physics query)
│   └── Camera2D
├── Collectibles (Node2D)
│   └── OrePickup (Area2D)            [spawned as ore is excavated]
├── Economy (Node)                     [economy.gd]
└── HUD (CanvasLayer)                  [hud.tscn]
```

## Separation of responsibilities

- **Terrain** owns tile lookup and removal. The player's drill and ship's drill will call the same public excavation API. Neither should call `erase_cell()` directly.
- **Player** owns movement, drill input, carried ore, oxygen, and the battery shared by drilling, jetpack thrust, and the work light. Ship-specific economics should not live here.
- **DrillShip** owns the safe zone, fuel reserve, and later fuel-funded descent. Its physical movement should occur independently of the terrain's tile removal implementation.
- **Economy** owns credits, ore pricing, and fuel pricing. Corporate debt and interest are out of v0.1.
- **World** wires together scenes and gameplay events, without duplicating their core logic.
- **HUD** displays state; it should not calculate game rules.

**Note on the ship:** This initial scene represents the ship as a deck and a safe-zone trigger. A functioning airlock, interior collision layout, and ship descent are intentionally not built yet.

## Implementation order

1. **Milestone A: Diggable world (complete).** Terrain tiles and collisions, drill targeting, tile excavation, finite ore, persistent pickups, and limited carrying capacity.
2. **Milestone B: Survival (complete).** Shared battery for drill/light/jetpack, oxygen drain outside, ship recharging, and ship entry/exit behavior.
3. **Milestone C: Economy (complete).** Unload and sell ore, track credits, and buy fuel for the ship.
4. **Milestone D: Descent.** Lower the ship through empty terrain cheaply or remove a row across its footprint at a higher fuel cost when obstructed. Test moving the player and safe zone with the ship.

## Deliberately deferred

Procedural generation, enemy pockets and combat, ship damage, crushers, smelters, player/ship upgrade trees, debt/interest, story events, and final artwork.

## Implementation notes

- This project was created in Godot **4.7** (Compatibility renderer). Preserve that starting configuration.
- The temporary `TileSet` and finite test map are generated at runtime; excavation safely rejects empty cells.
- Treat every resource capacity, rate, tile size, and sale price as a playtest variable, **not** a locked design choice.
- Temporary placeholder geometry is only for scene/signal validation, not an art direction.
