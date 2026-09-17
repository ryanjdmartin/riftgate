# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 17 September 2026

**State.** Everything committed. Tests: 117 tests, 1483 checks, green. Ryan is editing
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
Arsenal himself. Hardwired hardpoints with a paid unlock are tabled until an economy exists.
Content ideas are proposed in chat first (CLAUDE.md rule).

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
`<id>_polished.blend`), then `forge.py export`
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
2. The Badger is being taken to completion on its working file, `badger_polished.blend`,
   which Ryan edits by hand; `polish` will not overwrite it, and Claude adds to it with
   `forge.py apply <blend> <script> badger` (backup kept). Applied so far: `finish/badger.py`
   (rams, teeth), `finish/badger_braces.py` (X-braced armour plates, Minerva's tell; bolts
   removed), `finish/badger_deck.py` (panelled skirts with crates, cans and vents; roof
   plates and a hatch; helpers `plate_grid`, `crate`, `hatch`, `top_of`). Next: Ryan moves the rams and tags hardpoints (`hp_<n>`) and joints
   (`joint_<name>` parent Empties); wear shader; map tokens; livery on a rear or top plate.
3. Hardpoint Empties (`hp_<n>`) on the Badger; components as visual swap-outs.
4. Gate, defences and hangar as models.
5. Play on a phone with the damage ranges in; tune numbers, map size, squad speeds, Rift
   Pressure. Hangar: repair, rewards, one-shots, command die. Enemy art via foeforge for the
   eight foes still on sketch grids.

**Known rough edges.** Codex stat labels cut off on Ryan's device once, not reproduced.
Only the basic attack exists, so every foe intent is a sword. Routes are tap-to-destination
only. A route through another mech's hex is rejected at resolve time unless that mech moves
first. The skirmish's Back button reads "BACK" even when it returns to the battlefield.
`RIFTGATE_MECH3D_FLAT=1` skips the outline pass, for debugging.
