# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 16 September 2026

**State.** Everything committed. Tests: 116 tests, 1478 checks, green.

**Last done (16 September).** `tools/blendforge/`: mech sprites from a Blender model. Ryan
models in Blender (5.2 is installed at /Applications); `forge.py render <file.blend> <chassis>`
runs Blender headless for normal, material and depth passes and then shades them with the
spriter's own code, so the output files and the look are the spriter's. `--install` writes
`art/mechs`; otherwise `tools/blendforge/out/`. `forge.py example bulwark` builds a template
.blend from the primitive Bulwark (`tools/blendforge/models/bulwark.blend`, committed) and
that render matches the spriter's contact sheet. Modelling rules and the material roles are
in `tools/blendforge/README.md`. The spriter's `write_sheets` is now shared. Nothing in
`art/mechs` changed. Later on 16 September: "house" is retired everywhere (too BattleTech);
the material role and palette are now `livery`, the maker's colour, which the hangar will
one day let the player repaint for a fee. Setting direction recorded in the bible, section 1:
an elected council of mankind that is really a martial-law dictatorship, competing
manufacturers, propaganda, "nobody stands against the march of human progress". Lore is
not written; Ryan likes MARCH for the council if it names the body (leading expansion in the
bible: Mandated Assembly of the Remaining Cities of Humanity). Sixteen starter .blend
silhouettes for Ryan to reshape live in `tools/blendforge/models/archetypes/` (authored in
`archetypes.py`, `forge.py archetypes` rebuilds and renders the review sheet, also on
`docs/art-lab.html` section 7). Standing instruction from Ryan: take each new direction as
he gives it; tone iterates as we build.

MARCH is decided: the Ministerial Assembly for the Reclamation of Civilised Humanity. Open
on purpose: whether this is the last bastion, whether other colonies are fine, whether the
whole thing was a power grab. Ryan is rewriting `content/*.json` in his own voice and
renaming units. Content text is now split by shape (bible, section 6): shown at the top
level (`codex`, `flavour`, a passive's `name` and `description`, an action's `text`),
everything internal under `design` (`fantasy`, `niche`, `holes`, `signature`, `answer`,
`notes`); the validator refuses internal keys at the top level and passives have no
`rules` text (description plus at most three effects). Components have empty `codex` and
`flavour` waiting for Ryan's words. Sim and game code take their defaults from content
order (`ContentDB.default_team`, `default_faction`, `spawn_foes`, `make_boss`) instead of
hardcoding bulwark, ghoul or undead. Ryan's Bulwark model is
`tools/blendforge/models/new_bulwark.blend`; it renders cleanly, not yet installed.

Detail for modelled mechs (16 September, late): the image-model pass was tried on the
Badger's render at three strengths and replaced the design every time (art lab, section 8),
so it is retired for mechs. Blendforge gained surface patterns instead: materials named
`tread`, `grille`, `rivet`, `panel` draw a pattern in the part's own coordinates from a
third data pass (object-local position), consistent in all nine views. `tread` on the
Badger's track boxes makes them read as tracks. Next: Ryan renames his track material to
`tread` (and splits tracks into run, skirt and sprockets if he wants the spriter's read),
then `render --install`. Tests still name the current
ids, as do `tools/spriter` MODELS, `tools/sheet_export.py` grid mapping, `tools/foeforge`
BIG_MAP, and the art file names under `art/`; those get one pass after the rename lands. Next for art: Ryan's first hand-modelled mech (the Anvil has no design
yet), then `render --install`, `--import`, and a look at it in the skirmish.

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

Formation width is a setting: `Skirmish.new(seed, columns)`, `Battle.columns`, a picker on
the harness, `RIFTGATE_COLUMNS=4` for the standalone screen. Three by default. Ryan is
taking a pass on enemy types and compositions; the current content is proof of concept.
Design direction recorded in the bible: few machines versus a horde, hooks from that
(area damage, taunt, mitigation, dumb rank and file, smart demon and eldritch tiers,
commander units that scramble targeting when killed). Art experiments are collected on
`docs/art-lab.html` (open it in a browser); third-party-derived images live in the
ignored `docs/art-lab/ext/`.

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
2. Art: Ryan's Blender models through blendforge (the Anvil first), enemy candidates from
   foeforge for the eight foes still on sketch grids.
3. Small HUD fixes owed: roomy log at round one, faint disabled eye button, gesture tutorial.
4. Hangar: repair cost for cracked and destroyed faces, then rewards, one-shots, command die.

**Open decisions.** See design bible section 12.
