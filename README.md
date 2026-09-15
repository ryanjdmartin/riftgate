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
- `content/` — game data: `vocabulary.json` (every mechanic term, fantasy first), `factions.json`,
  `foes.json`, `chassis.json`, `components.json`. Placeholder numbers.
- `game/` — scenes and presentation.
  - `harness.tscn` is the main scene: pick a team, faction, squad size, seed, and fight
  - `skirmish/skirmish_screen.gd` the skirmish screen, built in code
  - `ui/` die face view, bars, glyphs, palette
  - `main.tscn` the battlefield map viewer
- `tests/` — headless tests. `run_tests.gd` discovers `test_*.gd` files and runs every
  `test_` method, including the content validator and a headless drive of the skirmish screen.
- `tools/` — `export_vocabulary.gd` regenerates `docs/vocabulary.md`; `screenshot.gd` renders a
  scene to PNG at 720x1280.
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
# poses the skirmish screen first: codex, mechcodex, diecodex, hold, confirm, lock
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn shot.png codex

# regenerate mech sprites from the primitive models (see tools/spriter/README.md), then re-import
tools/spriter/.venv/bin/python tools/spriter/spriter.py
godot --headless --path . --import
```

The skirmish screen runs top to bottom: header with End turn and Withdraw at the top right,
enemies, dice with Reroll beneath them, mechs with their bars above the sprites, log at the
bottom. Tap a die to lock it, hold a die to see every face on it, drag a die onto a foe to
spend an attack face or onto a mech to spend a shield or vent face; valid targets light up
while dragging. Keywords float beside each die as annotation tags. Kinetic faces roll their damage when they land and the
number flashes over the target; energy faces are static. Reroll up to twice per round, before
or after attacking. End turn runs the enemy and starts the next round immediately. Numbers
are in tens. Hold a foe or a mech for its numbers and the intent arrows
that concern it; the eye button shows every arrow; double-tap any unit or die for its codex
entry. Withdraw is offered at the start of a round after the first, before Lock in. Blank
faces are discarded at end of turn.

The harness can add the faction's massive elite, which fills both ranks of a column. For the
standalone screen, `RIFTGATE_TEAM=bulwark,sentinel,raptor,anvil` picks the team and
`RIFTGATE_ELITE=1` adds the elite.

In the map viewer: drag to scroll the taller-than-screen battlefield, tap without dragging
for the next seed. The gate and rift are three hexes wide and a three-hex boss walks the
north. Escape returns to the harness.

If a headless tool script errors before it calls quit(), Godot keeps running. Wrap runs in a
timeout when scripting them.
