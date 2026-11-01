# Milestone B: Survival loop

**Status: complete and validated in Godot 4.7.2.**

- Oxygen drains outside the drill ship and refills inside its safe zone.
- One battery powers drilling, jetpack thrust, and the toggleable work light.
- The ship continuously recharges the battery while the player is inside.
- Holding Space after jumping activates the jetpack; F toggles the work light.
- Empty battery blocks drilling and jetpack thrust, and switches off the work light.
- The HUD shows oxygen, battery, light state, and whether ship recharge is active.
- All capacities and rates remain exported playtest variables.

### Testing checklist in Godot 4.7

1. Run F5 and leave the ship; oxygen should begin draining.
2. Toggle the work light with F; battery should drain only while it is on outside.
3. Jump and hold Space; the jetpack should provide visible upward thrust while consuming battery.
4. Drill terrain; each removed tile should consume battery.
5. Empty the battery; drilling and jetpack thrust should stop and the light should switch off.
6. Return to the ship; oxygen and battery should refill to their maximum values.

Run the automated regression checks with:

```text
godot --headless --path . --script res://tests/test_milestone_a.gd
godot --headless --path . --script res://tests/test_milestone_b.gd
```

### Next work

Milestones C and D are now complete. Continue with full-loop playtesting, balance tuning, and feel improvements.
