# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 18 September 2026

**State.** Everything committed. Tests: 144 tests, 1704 checks, green. Ryan is editing
`content/*.json` in his own voice (reload the file after any pass that touches it).

**Setting, decided.** The governing body is the Council for the Ultimate Liberation of Terra,
"the Council"; its acronym is never stated in the game. The Council believes its own cause and
profits from it; the populace has real believers. The player is Battlefield Commander of an
arms-length defence agency (independent agency or contracted corp, not a ministry), known as CARE,
the Civil Auxiliary for Rift Emergencies ("Agency" if Ryan decides they named themselves). The Council's
own R&D house is the Arsenal, which sells the player a trickle of its tech, gated by how dire
the campaign gets. Open on purpose: last bastion or not, other colonies, whether it was a
power grab. Everything is in `docs/design-bible.html` section 1.

**Makers, decided (bible, section 7).** At most five: Minerva Heavy Works (`minerva`, was
Halvard), Kestrel Dynamics, Wainwright & Sutler (`wainwright_sutler`, was Orrin & Pike),
Aphelion, the Arsenal. Identity by the machines they build, not by battlefield niche; a
chassis's class decides its battlefield skills. Arsenal plates are decrees (Arsenal Instrument
IV) and its nicknames zealot words. Only Minerva, Kestrel and Wainwright & Sutler exist in
content so far; Ryan is moving mechs and equipment around and will place Aphelion and the
Arsenal himself. Fixed slots are never bought open (decided 18 September).
Content ideas are proposed in chat first (CLAUDE.md rule).

**Equipment words (18 September, decided).** A component is one piece of equipment and
exactly one entry on the die (component JSON: `face` is a single object; no slot count).
A chassis has `fixed` components (built in, never removed or sold, no hardpoint) and
`hardpoints` (free slots, one `hp_<n>` pin each on the model); die size is fixed plus
hardpoints; `filler` is gone and an empty hardpoint is a blank entry that does nothing.
Multi-slot components were scrapped as invisible complexity; no paid unlock of fixed slots.
Shown text says component, never face (`Face` stays the engine's word for one entry).
Injuries roll the die: intact cracks, cracked is destroyed, destroyed or empty takes the
blow. Passives: `status: planned` keeps a draft out of the engine; `on_injury` with
`no_destroy` (the Badger's Reinforced Skeleton) and a `when: component_cracked` condition on
`on_attack`/`on_crit` effects exist. The Badger: 4 hardpoints, fixed claw and plating (d6);
its stock loadout (two slug cannons, twin autoguns, a heat sink) and the one-face versions
of the claw, twin autoguns and howitzer are placeholders for Ryan to tune.

**Shields, armour, strikes (18 September, decided after discussion).** A standing shield
blocks a blow whole (nothing bleeds through; the blow costs the shield its damage). No
in-combat recharge (a passive may add it for one chassis); `recharge_field` per battlefield
phase out of contact stays (`Battle.commit`). `armour` is a flat chassis number off every
bare-hull blow; zero damage is fine (Badger 10, others 0, placeholders). Injury only on a
bare-hull blow whose through-damage is at least a quarter of max hull. Foes: `strikes`
(default 1; a double strike breaks a shield and reaches hull) and `breach` (overflow into
hull, never injures through shield); none set in content yet, Ryan places them. Strike
order: front rank left to right then back; heaviest hitters (`Foe.threat`) deploy left at
first contact. `Skirmish._blow` is the shared arithmetic for the real hit and the forecast.
Round cap rejected. Per-round Rift Pressure tick kept (it is what makes a long wall cost). Later the same day: a breach injures like any blow (hull lost in one
blow is what counts; its counterplay is redirect or interrupt, not built yet);
`Skirmish.turn_events` records every enemy blow and the screen replays them with a shield
shatter (`UnitView.shatter_shield`, screenshot pose `enemyturn`); `Face.fixed` marks
built-in entries and the component list draws hardpoints as dashed sockets and empty ones
as EMPTY; the codex stat block shows hull, shield, armour, move and recharge (hardpoints
dropped as a number). **Foe actions (18 September, built).** A foe's implemented attack actions scale its base
attack: `factor` (default 1.0), `strikes`, `breach`, `weight`; `{damage}` in an action's
text shows the resulting number. `Foe.choose_action(rng)` picks one by weight at round
start, before the player acts (intent chip shows damage plus ×n or !, forecast is exact);
`Foe.damage()/strikes()/breaches()` replace the foe-level fields. Content: `value` on an
attack is refused; a foe needs at least one implemented attack. "Numbers in tens" means the
magnitude of tens, not multiples of ten (15 is fine; the test says >= 10). Stat block:
hull, shield, armour, recharge (+15), move; 4 px inset fixes the left clip.
`Face.strikes` (built 18 September): an attack's blows per use, each its own roll, crit,
keywords and passives; heat once per use; die face shows "10 ×3"; content `strikes` on a
component face; foe actions carry the same field. Power checks are non-negative only
(numbers in tens means magnitude). Salvage from rift-belched wrecks and monster research
tokens recorded as open in the bible's open questions. HUD palette swatches published as an
artifact for Ryan's eyes (protan simulation toggles).
**Vocabulary audit (18 September, Ryan's overhaul, engine caught up).** Renames: cleave is
shown as Spread (id stays `cleave`, `Face.keyword_label`), pierce is `penetrate`, danger
close is Splash (log says "splash"), line is "Line of sight". Removed: the lock keyword and
its die-keeping state, flip, copy, reflect, step_up. Melee is a third reach: front rank
only, the back only when the whole front is empty. Chain: a kill repeats the attack on a
new target, heat paid on every link (the risk). Execute: +100%, +50% against massive foes. Burn: 5 per stack.
A crack takes only keywords (crit, heat, passives stay). New planned entries (overwhelm,
corrode, numbed, rapid, disable, corrupt, energy armour, scramble, confuse, retaliate,
disabled, corrupted, phased, taunt, beacon) are content only. `static` trigger with
`set_reach` and `when: reach_melee/line/indirect` exist; the Badger's Reinforced Skeleton
uses them (cracked weapons go melee, melee +10%). Reach is never written to a component:
`Skirmish.reach_of(ms, f)` / `Passives.effective_reach` compute it on every read from the
owner's passive, so an ally reading the entry or a suppressed passive gets the plain reach;
`Skirmish.shown_face` gives the screen a display copy. Vocabulary entries carry no `fantasy`
any more (validator and export tool follow). `Face.CRIT_MULT` is the crit base (Face, not
Skirmish: a cycle otherwise).
**Effects pipeline (18 September, built).** `sim/effects.gd` replaces `passives.gd`: a
Modifier is a passive with a scope (LOADOUT, BATTLE, SKIRMISH, ROUNDS) and a source;
`Unit.modifiers` holds them, `Unit.base` holds chassis numbers and `hull_max`, `shield_max`,
`heat_max`, `armour`, `movespeed`, `recharge_field` are accessors over `Effects.stat`
(writing sets the base). Queries: `stat`, `attack` (adds, multiplies, floors on damage and
heat, burn and vent from crit effects), `crit_bonus`, `damage_taken`, `effective_reach`,
`no_destroy`, `describe`. Lifetimes: `end_round` (Skirmish.end_round), `end_skirmish`
(Skirmish._finish), `end_battle` (Battle outcome). Static effects: add_stat, multiply_stat,
add/multiply_damage_taken, set_reach, suppress (by id or tag). Component passives are
granted by make_mech with their component id; destroyed components keep bonuses, lose
abilities. Order of operations is a vocabulary rule (category `rules`). Foes are not on it
yet (burn, suppressed stay statuses). Component stat modifiers in content are now just
`static add_stat` effects on a component's passive; none written yet.
Open, discussed 18 September, not built: component stat modifiers as content
and granted passives with totals shown as base plus bonus, a fixed colour standard for a
protanomalous player, movespeed granularity.

**Content shape.** Shown text at the top level (`codex`, `flavour`, a passive's `name` and
`description`, an action's `text`, a chassis's optional `designation`); everything internal
under `design`; the validator refuses internal keys at the top level. Code takes defaults
from content order (`ContentDB.default_team`, `default_faction`, `spawn_foes`, `make_boss`).
The Bulwark is the Badger (`badger`) everywhere.

**Art, decided: player units are native 3D; enemies stay painted 2D.** Pipeline for a mech:
Ryan masses it in Blender (`tools/blendforge/models/<id>.blend`, active scene only, materials
by role, "detail" on small parts), then `forge.py polish <blend> <chassis>` (chamfers, panels, corner bolts, tracks with cleats and
wheels, and, per the maker's manner in `profiles.py`, rim bars, a rear vent, rams to the arms,
stack collars; per the chassis kit, extras like the Badger's work lights and tow lugs; writes
`<massing>_polished.blend`, which becomes the working file `<id>.blend`), then `forge.py export`
(bakes occlusion and pointiness into a `wear` vertex colour, writes `art/models/<id>.glb`),
then `--import`. `game/ui/mech_view_3d.gd` draws it in the skirmish screen and the codex with
`mech_toon.gdshader` (pixel or clean look; the clean look reads the wear bake and runs a
procedural surface pass per material role, tuned 17 September: light wear, chipped livery,
tread ridges, a hint of dust, rust off, primary steel and livery as glossy plating with a
reflection gradient, secondary steel matte with a fine weave, a `gloss` lever per maker
(`MechView3D.GLOSS`: Kestrel 1.0, Minerva 0.35, W&S 0.15), glass and lamp glow, no UVs) and
`outline.gdshader`; The 3D clean look is the default when a window exists;
`RIFTGATE_MECH3D=pixel|off` overrides, headless runs use sprites. The skirmish shows mechs
in rear three-quarter facing the foes; the codex spins the model in a 200x240 frame. The Badger is the only modelled mech;
its glTF is polished and baked. The 2D sprite path (blendforge render, foeforge edit mode,
cut-mech) still works and still feeds the 24 px map tokens. Art experiments and comparisons
are on `docs/art-lab.html`, sections 8 and 9.

**Alive (17 September).** Filler animation on the skirmish screen: lunge or recoil on a
player attack, flash and shake on the struck unit, the enemy turn replayed as staggered
lunges, dice pop on reroll, damage numbers rise, log lines type in, 3D mechs sway, foes
breathe, a scan band drifts on the backdrop. `Skirmish.terrain` is the contact hex's terrain
(set by `Battle._build_skirmish`); the backdrop draws ground strips in it, and
`game/ui/terrain_art.gd` textures the map's hexes with the same marks. `tools/screenshot.gd`
gained a `strike` pose and `RIFTGATE_SHOT_FRAME` to catch a frame mid-animation.

**Ranks and reinforcements (17 September).** `Skirmish.pool` is `reinforcements`. Ranks hold:
front foes only ever stand in front, back foes in back, even with an empty slot the other way;
no stepping up. First deployment in arrival order; the reinforcement phase at the end of the
enemy turn fills each empty slot left to right, front first, with a random waiting foe of the
right rank, logged. Ryan wants player interaction with that phase (open). Facing: mechs at
`MechView3D.YAW_SKIRMISH` (25 degrees, front three-quarter biased front, turned right), foes
left (`UnitView.flip_h`, driven by an optional `flip` on a foe; the foeforge prompt asks for
left). Idle: foes breathe 3%; only flyers and hover chassis sway in 3D, ground stands still
until joints are annotated. Battlefield direction (landscape, high and low, rift terrain,
grouped features) is recorded in the bible, section 4, open.

**Next, in order.**

1. Write the five makers into content once Ryan tweaks the drafts; draft CARE's voice.
2. **The Badger's starting point is `tools/blendforge/models/badger.blend` (finalized 17
   September, Ryan's call: "good enough for now").** Cleaned for hand editing: parts named
   by what they are (`body`, `glacis`, `shoulder_l`, `arm_l`, `forearm_l`, `claw_l`, `gun_r`,
   `launcher`, `beacon`, `track_l`, `skirt_l`, `axle`, `undercarriage`...), slivers joined
   (braces, cleats, wheels, vent slats, teeth: 224 objects became 109), one material per
   role, one `badger` collection, marked `blendforge_stage = finished` so `polish` refuses it.
   The massing is `badger_massing.blend`, reference only; the three `finish/badger*.py`
   scripts are history (headers say so). `art/models/badger.glb` is exported from it.
   Ryan is now moving the rams, tweaking parts, and tagging hardpoints (`hp_<n>`) and joints
   (`joint_<name>` parent Empties) in that file. He removed the teeth (they floated); revisit.
   The engine already reads the tags (`MechView3D.joints` / `hardpoints`, built while Ryan
   was out on 17 September, tested on a scratch-tagged copy, not his file): joints idle
   (slow settle about X, left and right out of step), swing on a melee strike and recoil on
   a ranged one where they carry a pin (`strike(ranged)`, called from the skirmish's attack
   animation); `mount(n, scene, maker)` / `unmount(n)` swap a component model onto a pin.
   `RIFTGATE_MECH3D_MODEL=<id>` previews another exported file in every slot. Untagged
   models draw as before. Map tokens now come from the glTF too: `tools/map_tokens.gd`
   writes `art/mechs/<id>_map_strip.png` (pixel look, pitch 42, detail parts hidden, flat
   tones); the Badger's strip is the 3D one. After Ryan's tags land: re-export, re-run the
   tokens, check the swing direction and size against his pivots, then components as
   models under the pins, livery on a rear or top plate.
4. Gate, defences and hangar as models.
5. Play on a phone with the damage ranges in; tune numbers, map size, squad speeds, Rift
   Pressure. Hangar: repair, rewards, one-shots, command die. Enemy art via foeforge for the
   eight foes still on sketch grids.

**Known rough edges.** Codex stat labels cut off on Ryan's device once, not reproduced.
Only the basic attack exists, so every foe intent is a sword. Routes are tap-to-destination
only. A route through another mech's hex is rejected at resolve time unless that mech moves
first. The skirmish's Back button reads "BACK" even when it returns to the battlefield.
`RIFTGATE_MECH3D_FLAT=1` skips the outline pass, for debugging.
