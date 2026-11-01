# Milestone C: Mining economy

**Status: complete and validated in Godot 4.7.2.**

- Press E inside the ship to unload and sell all carried ore.
- Each ore sells for a configurable credit value.
- Press B inside the ship to buy one configurable-price fuel unit.
- The drill ship owns a limited fuel reserve for Milestone D descent.
- Selling and purchasing are unavailable outside the ship safe zone.
- Failed transactions preserve resources and explain the failure on the HUD.
- Debt, interest, refining, upgrades, and variable ore grades remain deferred.

### Testing checklist in Godot 4.7

1. Collect ore and return to the ship.
2. Press E; cargo should empty and credits should increase.
3. Press B; credits should decrease and ship fuel should increase.
4. Try both controls outside the ship; neither transaction should occur.
5. Try buying fuel without enough credits and with a full tank; resources should remain unchanged.

Run the complete regression set with:

```text
godot --headless --path . --script res://tests/test_milestone_a.gd
godot --headless --path . --script res://tests/test_milestone_b.gd
godot --headless --path . --script res://tests/test_milestone_c.gd
```

### Next work

Milestone D is now complete. Continue with full-loop playtesting, balance tuning, and feel improvements before expanding scope.
