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

Later on 15 September: off-screen squads get an edge portrait (map token, strength or
BOSS, chevron; tap to scroll there). Enemy art now exists: `tools/sheet_export.py` turns the
hand-typed grids in `docs/sprites-enemies.html` into `art/foes/<id>_combat.png` and
`<id>_map.png`, so the skirmish and the map show every foe. The mech sheet page opens with
the rendered contact sheets; its grids are the brief, the renders are current.

Skirmish second pass (15 September, from Ryan's playtest notes): no names, chip row under
every sprite (fantasy intent icons, statuses, forecast warnings), pulsing gauge overlays,
big glyph on the die, Reroll wide under the dice, eye in the header, no rank labels,
upright quotes, `NAME: description` passives. `Skirmish.forecast()` is the prediction.
Three rerolls a round, and `Die.reroll()` never returns the showing face or an equivalent one.
Third pass (same day): eye under the foes, foe slots 194 tall, chips 30 px, mechs centred on
their drawings, ink-white pulse for colour-blind contrast, details pane sized from minimums,
mono labels padded (the left clipping), Barlow Condensed Italic for quotes, withdraw open on
round one, keyword chips coloured by effect (`Glyphs.colour_for`).

Player art direction (15 September, from Ryan's references): isometric read for units,
mech combat frame 80x96 at 2x (foe pixel density), renderer keeps the map facings, the model
refines the renderer's combat sprite as its reference (`forge.py mech`, `cut-mech`). The
Bulwark's front-right is the first hybrid sprite in the engine; Sentinel and Raptor are still
plain renders. Re-running the spriter overwrites the pick; re-run cut-mech afterwards.

**Known rough edges.**

- Ryan reported codex stat lines cut off on the left; not reproduced in a 720x1280 render.
  Labels now expand-fill with autowrap. Needs a screenshot from his device if it persists.
- Only the basic attack exists, so every foe intent is a sword. Defend, heal, buff, debuff
  icons are drawn and wired to the action kind for when the engine runs them.

- Routes are tap-to-destination only. Drag-to-draw is not built.
- A route that passes through another mech's current hex is rejected at resolve time (the
  log says so) unless that mech moves first. The order is the order routes were set.
- Enemy art: `tools/foeforge/` (mflux, FLUX.2 Klein 4B, ~8 s a candidate on the M4 Max)
  generates candidates from foes.json prompts and cuts one into art/foes. The ghoul is the
  first model-made sprite in the engine; the other eight foes still use the sketch grids.
  Next: `forge.py generate <foe> --n 4` for each, Ryan picks from the contact sheets.
- The skirmish's Back button still reads "BACK" even when it returns to the battlefield.

**Next, in order.**

1. Play on a phone with the damage ranges in; tune min, max, crit, injury thresholds, map
   size, squad speeds, and the Rift Pressure rate.
2. Art: mech sheet round two on the grit brief, the Anvil model, enemy art when images exist.
3. Small HUD fixes owed: roomy log at round one, faint disabled eye button, gesture tutorial.
4. Hangar: repair cost for cracked and destroyed faces, then rewards, one-shots, command die.

**Open decisions.** See design bible section 12.
