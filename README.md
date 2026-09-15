# Riftgate (working title)

Portrait-mode tactical hex battler for Android. A few customizable war machines hold the last
city gate against undead, demonic, and eldritch hordes in a roguelike campaign.

The design bible lives in `docs/design-bible.html` and records every decision, recommendation,
and open question from the design sessions.

## Layout

- `sim/` — pure simulation. No scene dependencies. Seeded RNG. Everything here runs headless.
  - `hex.gd` axial/cube hex math, pointy-top pixel conversion
  - `battle_map.gd` terrain grid, gate, rift, procedural generation with a guaranteed ground path
  - `unit.gd` mechs, squads, city defenses on the battlefield
  - `battlefield.gd` phase resolution: previewed enemy intents, player routes, body-blocking,
    connected-group skirmish detection, gate damage, Rift Pressure
  - `face.gd`, `die.gd` die faces and dice
  - `foe.gd` an enemy inside a skirmish
  - `skirmish.gd` the dice skirmish: two-rank enemy formation fed from a pool, reach rules,
    keywords, heat, shields, injuries, withdraw, outcome
  - `loadouts.gd` sample dice and squads for prototypes and tests
  - `passives.gd` runs the passive triggers the engine supports (the validator refuses others)
  - `content_db.gd` loads and validates `content/*.json`, builds dice, mechs, and foes
  - `battle.gd` one battle end to end: plot routes, resolve, open a skirmish per contact
    group, apply the result, until the gate falls, the team is wrecked, or the boss dies
- `content/` — game data: `vocabulary.json` (every mechanic term, fantasy first), `factions.json`,
  `foes.json`, `chassis.json`, `components.json`. Placeholder numbers.
- `game/` — scenes and presentation.
  - `harness.tscn` is the main scene: pick a team, faction, squad size, seed, then Battle
    (the whole loop), Fight (one skirmish), or the map viewer
  - `battle/battle_screen.gd` the battle screen: the map with the phase loop around it, and
    the skirmish screen hosted over it on contact; `battle/battle_map_view.gd` draws the
    field and reads the gestures
  - `skirmish/skirmish_screen.gd` the skirmish screen, built in code
  - `ui/` die face view, bars, glyphs, palette
  - `main.tscn` the battlefield map viewer
- `tests/` — headless tests. `run_tests.gd` discovers `test_*.gd` files and runs every
  `test_` method, including the content validator and a headless drive of the skirmish screen.
- `tools/` — `export_vocabulary.gd` regenerates `docs/vocabulary.md`; `screenshot.gd` renders a
  scene to PNG at 720x1280; `spriter/` renders mech sprites from primitive models;
  `sheet_export.py` exports the enemy grids in `docs/sprites-enemies.html` to `art/foes/`;
  `foeforge/` generates enemy candidates with an image model and cuts one into `art/foes/`.
- `art/` — `mechs/` from the spriter, `foes/` from the sheet export, `fonts/` the HUD faces.
  Everything is optional: a missing sprite falls back to a placeholder shape.
- `docs/` — design bible, generated vocabulary, concept intake in `docs/concepts/`, and
  `status.md`, the handoff note updated at the end of every working session.

## Running

Open the folder in Godot 4.7 or later, or from a terminal:

```sh
# first run only: build the script class cache
godot --headless --path . --import

# run the test suite
godot --headless --path . -s tests/run_tests.gd

# run the harness (skirmish screen and map viewer)
godot --path .

# regenerate docs/vocabulary.md from content/vocabulary.json
godot --headless --path . -s tools/export_vocabulary.gd

# screenshot a scene (needs a window; a small one opens briefly); an optional third argument
# poses the screen first. Skirmish: codex, mechcodex, diecodex, hold, confirm, lock.
# Battle: select, route, hold, resolve, contact.
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn shot.png codex
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn shot.png route

# regenerate mech sprites from the primitive models (see tools/spriter/README.md), then re-import
tools/spriter/.venv/bin/python tools/spriter/spriter.py
godot --headless --path . --import

# export the enemy sprites from the grids in docs/sprites-enemies.html to art/foes, then re-import
tools/spriter/.venv/bin/python tools/sheet_export.py
godot --headless --path . --import

# better enemy sprites from an image model on this Mac (see tools/foeforge/README.md)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate ghoul --n 4
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/ghoul/ghoul_3.png ghoul
```

The skirmish screen runs top to bottom: header with the round tag, enemies with the intent
eye right under them at the right edge, log, dice with the wide Reroll right under them, mechs at the bottom with
their gauges hugging the sprite, End turn bottom-left and Withdraw bottom-right. No unit
names on screen. Under each foe sits its intent as a fantasy icon and number (a sword for
the attack) and its statuses (burn, suppressed, exposed) as chips. Under each mech sit its
statuses and warning signs: a broken shield when incoming damage will break it, a crack when
a hit that big may injure a component, a skull when the round would wreck it, a thermometer
when the current face would overheat. The gauges pulse over the part about to change and the
warnings update as you act, so shielding or killing an attacker clears them at once. Tap a
die to lock it, hold a die to see every face on it, drag a die onto a foe to spend an attack
face or onto a mech to spend a shield or vent face; valid targets light up while dragging.
Keywords float beside each die as annotation tags. Kinetic faces roll their damage when they
land and the number flashes over the target; energy faces are static. Reroll up to three
times per round, before or after attacking; a reroll always lands on a different face,
never the one showing nor an equivalent one. End turn runs the enemy and starts the next round
immediately. Numbers are in tens. Hold a foe or a mech for its numbers, its statuses with
icons and text, and the intent arrows that concern it; the eye shows every arrow;
double-tap any unit or die for its codex entry. Withdraw is offered at the start of any round,
before a face is spent. Blank faces are discarded at end of turn.

The harness can add the faction's massive elite, which fills both ranks of a column. For the
standalone screen, `RIFTGATE_TEAM=bulwark,sentinel,raptor,anvil` picks the team and
`RIFTGATE_ELITE=1` adds the elite.

The battle screen is the loop. The header shows the phase, the gate's hull, and Rift
Pressure. The map scrolls by drag and starts at the gate end. Tap a mech to select it and the
hexes it can reach light up; tap a lit hex to plot the route there; tap the mech again to
clear its route. Two mechs cannot claim the same destination. Hold any unit for its numbers.
Red lines are where each squad goes this phase unless something stops it. A squad outside the
view gets a portrait at the edge nearest it, with its strength and a chevron; tap the
portrait to scroll to it. Resolve, bottom left, moves the team first and then the squads; every group of touching units that mixes both
sides becomes a skirmish, played on the skirmish screen over the map. Its Back button applies
the result: wrecks leave the map, squads shrink to their survivors, surviving shields recharge,
and Rift Pressure ticks once per round fought. The battle ends when the gate's hull reaches
zero, every mech is wrecked, or the boss dies. For the standalone screen `RIFTGATE_TEAM`
picks the team and `RIFTGATE_FACTION=undead|demonic|eldritch` the enemy.

In the map viewer: drag to scroll the taller-than-screen battlefield, tap without dragging
for the next seed. The gate and rift are three hexes wide and a three-hex boss walks the
north. Escape returns to the harness.

If a headless tool script errors before it calls quit(), Godot keeps running. Wrap runs in a
timeout when scripting them.
