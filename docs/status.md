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
`mech_toon.gdshader` (pixel or clean look; the clean look reads the wear bake) and
`outline.gdshader`; The 3D clean look is the default when a window exists;
`RIFTGATE_MECH3D=pixel|off` overrides, headless runs use sprites. The skirmish shows mechs
in rear three-quarter facing the foes; the codex spins the model in a 200x240 frame. The Badger is the only modelled mech;
its glTF is polished and baked. The 2D sprite path (blendforge render, foeforge edit mode,
cut-mech) still works and still feeds the 24 px map tokens. Art experiments and comparisons
are on `docs/art-lab.html`, sections 8 and 9.

**Next, in order.**

1. Write the five makers into content once Ryan tweaks the drafts; draft CARE's voice.
2. Ryan judges the Minerva-profile Badger; tune profiles and the wear shader (`grime`, `wear`)
   with him; decide map tokens (sprites versus small 3D); livery on a rear or top plate since
   the skirmish now shows the back.
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
