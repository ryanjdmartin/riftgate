# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 15 September 2026

**State.** Everything committed. Tests: 108 tests, 1241 checks, green.

**Last done.** The battle loop. `sim/battle.gd` owns one battle: routes, resolve, a
skirmish per contact group, results applied back, outcome on gate fallen, all wrecked, or
boss dead. `game/battle/battle_screen.gd` plays it: tap a mech, tap a lit hex to route, hold
for numbers, drag to scroll, Resolve bottom-left, Clear routes bottom-right; the skirmish
screen opens over the map on contact and its Back button continues the battle. The harness
has a Battle button. Screenshot poses: select, route, hold, resolve, contact.

**Known rough edges.**

- The map is 20 rows and starts scrolled to the gate, so the squads are off-screen at phase
  one. The intent lines coming in from the top are the only hint. A minimap strip, a smaller
  default map, or auto-scroll to the nearest threat are all candidates.
- Routes are tap-to-destination only. Drag-to-draw is not built.
- A route that passes through another mech's current hex is rejected at resolve time (the
  log says so) unless that mech moves first. The order is the order routes were set.
- Squads on the map still draw as diamonds; foe map sprites do not exist.
- The skirmish's Back button still reads "BACK" even when it returns to the battlefield.

**Next, in order.**

1. Play on a phone with the damage ranges in; tune min, max, crit, injury thresholds, map
   size, squad speeds, and the Rift Pressure rate.
2. Art: mech sheet round two on the grit brief, the Anvil model, enemy art when images exist.
3. Small HUD fixes owed: roomy log at round one, faint disabled eye button, gesture tutorial.
4. Hangar: repair cost for cracked and destroyed faces, then rewards, one-shots, command die.

**Open decisions.** See design bible section 12.
