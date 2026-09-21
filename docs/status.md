# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 20 September 2026

**State.** Everything committed. Tests: 151 tests, 1767 checks, green. Ryan writes
`content/*.json` in his own voice (reload after any pass that touches it). The rules are in
`docs/vocabulary.md` (generated) and every decision in `docs/design-bible.html`; the
vocabulary carries an `order_of_operations` rule that the engine follows.

**Setting and makers, decided (bible sections 1 and 7).** The Council for the Ultimate
Liberation of Terra ("the Council", acronym never stated); the player commands CARE, the
Civil Auxiliary for Rift Emergencies, an arms-length agency; the Arsenal is the Council's
own R&D house. Five makers at most: Minerva Heavy Works, Kestrel Dynamics, Wainwright &
Sutler, Aphelion, the Arsenal. Only the first three exist in content; Ryan places the rest.

**Equipment (18 September).** A component is one entry on the die (`face`, a single
object). A chassis has `fixed` components (built in, no hardpoint, never sold) and
`hardpoints` (free slots, one `hp_<n>` pin each on the model); an empty hardpoint is a blank
entry. Shown text says component, never face. Injuries roll the die on a bare-hull blow of
a quarter max hull: intact cracks (keywords only), cracked is destroyed, destroyed or empty
takes the blow; a breach injures through shield. Reach is melee (front rank; the back only
when the whole front is empty), line of sight, indirect (splash on the front rank).
Keywords: spread (id `cleave`), penetrate, burn (5 per stack), suppress (then Numbed),
execute (+100%, +50% on massive), chain (repeats on a kill, heat every link), steady,
rapid (switch off for the round, free reroll, act again), overcharge. Foe attack keywords:
breach, scorch (placeholder: stacks Overheating, 5 heat per stack per turn), disable
(switches off the showing entry through the next turn). `strikes` on any attack are
separate blows, heat once per use. Crit: `Face.CRIT_MULT` (2.0) plus additive bonuses.

**Shields and armour (18 September).** A standing shield blocks a blow whole; no in-combat
recharge; withdraw at any point of the player's turn, always at the price of one enemy turn
(19 September); `recharge_field` per quiet battlefield phase; `armour` is flat off bare-hull
blows and zero damage is fine. Foes strike front rank left to right then back; heaviest
deploy left. Shield sits above hull in every readout.

**Effects pipeline (18 September).** `sim/effects.gd`: every stat, damage figure and
component property is a question, never a stored total. A Modifier is a passive with a
scope (LOADOUT, BATTLE, SKIRMISH, ROUNDS), a source, stacks and a decay rule; order is
suppression, gate, adds, multiplies, floors, overrides. Mech maximums are accessors over
`Unit.base`. Foes carry statuses the same way (burning, suppressed, numbed). Component
passives are granted with their component id; a destroyed component keeps bonuses, loses
abilities. `Effects.explain` and `effect_text` feed the die screen.

**Screens (18 September).** Palette shipped from Ryan's swatch review: fixed semantic set
(hull d8d2c4, shield 2f63d8, heat ff6a00, enemy ff1e1e, white for good and selection, ink
f2f4ee over muted 7b857c, no green or purple as meaning), HUD picker is chrome only (green,
amber, cyan; red gone), map numbers on plaques, boss and elite by shape, rift as its own art.
Gauges dim a pending loss and hatch a pending gain. The die screen is a breakdown: labelled
components in one column, per-entry effect tags, every live effect in words. Shield shatter
plays on the enemy turn replay. Skirmish mechs face the foes (`YAW_SKIRMISH` 155).

**Structures (19 September).** `BattleMap.wall_hexes` fills the bottom row beside the
three-hex gate; walls are structures (nobody stands there, nothing hurts them). Models are
code-massed: `tools/blendforge/structures.py` (gate with two tower guns, wall segment),
`forge.py structures` builds `models/gate.blend`, `models/wall.blend` and exports the glTFs,
which `Map3D` places on the bottom row; then `--import`. Ryan may reshape the .blend files.
Rebuilt 20 September to feel epic: wall body 70 high, a gatehouse above it with a tall narrow
pointed mouth in three stepped reveals, towers of 112 with fins and bigger guns, blades along
every top edge in place of crenellations (Ryan: sand-castle squares make it small). The
structures are two rows deep (`BattleMap.GATE_ROWS`): the row above them is an apron nobody
enters, so the wall never hides a unit; squads strike the gate from the row above the apron. Per-mech repaint exists:
`Unit.paint` {primary, secondary} recolours the livery and bone plating (`MechView3D.paint`,
`ramp_for`); `RIFTGATE_PAINT=badger:ff8800/223344` previews it. Nothing sets it in play yet.

**The bleed (built 20 September, the clash made to jar the same day).** `PaintedMap` paints
the map once in two styles into two SubViewports: "ground" (gritty, muted, grain and
cracks) which the 3D columns' tops wear through `ground.gdshader` (lit, sampled by world
position), and "other" (bright saturated overworld, chunky marks) which the bleed shows
through. `Map3D`: every hex is a column with `HEIGHT` by terrain, one sun with shadows;
`lift(h)` is how far a hex's top sits above its grid cell on screen, and the map view's
`center` and `hex_at` use it so overlays and taps follow the terrain. `bleed.gd` is the
bleed function (gradient south of the rift plus a radius per squad); `bleed.gdshader` in the
compositor SubViewport (`_mix`) mixes the two by it with a hard Bayer-dithered seam, and
tilt-shifts the 3D side around `focus_y` (trial: `focus_band`, `focus_falloff`, `blur_max`).
`Map3D.sync` collapses columns and structures just outside the seam (`Bleed.FLAT_AT`). Knobs:
`Bleed` constants, `Map3D.HEIGHT`, `PaintedMap.OTHER`, the sun and ambient in
`_build_light`, the albedo lift in `ground.gdshader`. Not built: the contact transition,
zoom, the gradient growing with Rift Pressure, an outline pass, outlines for units behind
tall columns. `tools/screenshot.gd ... north` shows the rift end.
Fiction frame decided 20 September: the screen is CARE's tactical reconstruction
(survey plus telemetry; the rift's world returns flat; contact hands over to the feed), with
sensor language for the HUD (contacts, returns, projections) wanted. Open, awaiting Ryan: what
keeps the rift's world out of the city, since a wall can be flown over. Proposal in the bible:
an energy field with the gate as its projector, the mouth its one blind spot.
**3D battlefield (default since 20 September).** `game/battle/map_3d.gd` is a SubViewport the
map view draws behind its overlays: hex ground stretched in depth so it projects onto the 2D
grid exactly (overlays and gestures untouched), lit props for mountains, rubble, rocks and
roads, the gate and wall glTFs, mechs as toon models turned to their facing. Foes are flat
pictures drawn by the map view over the viewport, never objects in the scene. Headless runs
fall back to the painted 2D map. `MechView3D.toon` is the shared material pass. No outline
pass yet.

**Ally art (locked 21 September).** The mid-nineties 3D register (Descent, MechWarrior 2),
built by `tools/lowforge`: `models_low.py` holds one function of numbers per chassis id
(`badger`, `sparrowhawk` so far), `bl_low.py` the primitives, the maker metals (`MAKERS`) and the
tile generator, `forge.py build <id>` writes `art/models/<id>.glb` with the tiles embedded
(review PNGs under `tools/lowforge/tiles/<maker>/`). `MechView3D.toon` takes the tile look
automatically for any textured model (nearest filter, gloss by maker, a sun in the view);
`forge.py build` also saves `tools/lowforge/models/<id>.blend` (tiles packed) for hand
edits in Blender, and `forge.py export <id>` turns that file back into the glTF, Empties
included, so joints (`joint_*`) and pins (`hp_*`) can be placed by hand; a rebuild from code
overwrites the .blend, so an edited unit is saved under another name or its code retired.
Those folders carry `.gdignore` so Godot never tries to import the .blend files itself.
The gate and wall are lowforge models too (`gate`, `wall`, maker arsenal, `tile_world` 40
so their tiles read at true scale on the map). On the map a mech is the same textured model
as the skirmish with a dark inverted-hull outline (`Map3D._marker`), fitted to about one
hex; the ground style is drawn at half resolution with chunky marks, so its texels match
the units'. The map zooms (wheel, pinch; `BattleMapView.zoom_at`, 1 to 2.6) and pans both
ways: overlays draw in map space under one transform, `to_screen`/`to_map` convert, the
edge tags stay in screen space; `tools/screenshot.gd ... zoom` (or `zoomlast`) shows it.
The 3D scene and the compositor are screen-sized: `Map3D.look(scroll, zoom)` pans and
zooms the camera in the world, so a frame costs one screen at any zoom and both render
every frame (the map is alive: `Map3D._process` sways and bobs the units, flyers more;
water ripples in `terrain.gdshader`). Units stand on their lowest point (`_rise`), flyers
hover (`HOVER`). Roles light the register: `amber` tiles are emissive and both 3D
environments carry a little glow; `glass` is glossy. Terrain (21 September): the columns
wear material tiles from `art/terrain` (`forge.py terrain` generates dirt, gravel, rubble,
concrete, water, rock, crag) through `terrain.gdshader`, sides in rock, heights in
`Map3D.HEIGHT` (crags 20 plus a spire: impassable, flyers only, decided); the painted
ground map is gone and `PaintedMap` is the overworld only. Roads are laid by
`BattleMap._lay_roads` as a drifting trunk north from the gate with a branch or two and
`ROAD_GAP_CHANCE` missing slabs, never rolled. The landscape is laid, not rolled
(`BattleMap._lay_landscape`, 21 September): seeded `FastNoiseLite` fields for wetness
(water bodies), roughness (gravel belts) and a ridge (crags along lines), ruins in two or
three clusters; a crag keeps the ground under it in `crag_base` (crag-water, crag-ruin) and
the 3D map shows that tile under the spikes; the two rows above the apron are always open
ground. Water is fordable by everyone at a cost by trait (tracks 3, walker 2, hover 1;
hover chokes on rubble at 3): `BattleMap.move_cost` is where each way of moving gets its
own worst ground. `BattleMap.margin` holds `MARGIN_COLS` columns of scenery either side
of the field, laid from the same noise, never played on; `Map3D` builds them, the wall
runs across them, `bleed.gdshader` fades them out past `play_x` so the field is a window
on a longer battlefield. Crags take their ground's idiom (`Map3D._crag`: rock spikes,
broken towers on ruins, mesas on wasteland); scrub carries dead trees. The readout has its
own strip (`BattleScreen.INFO_H`) between the map and the log. A scan sweeps the map top
to bottom every few seconds (`SWEEP_H`, `SWEEP_SPEED`; the map view processes every frame
for it); the flicker is rare. Roads are drawn, not tiled (`road.gdshader`, one material, per-hex instance uniforms
`links` and `seed` from `Map3D._road_links`): a deck runs from the hex centre to every
road neighbour (the gate counts), so adjoining road hexes make one road; concrete
shoulders, kerbs, a guide line, verge lamps with some lit and emissive. The map's own
overlay draws the skirmish backdrop's scanlines and drifting band. Past the field's sides
the world blurs and fades over `edge_fade` (150 px, `MARGIN_COLS` 3), as the far north
does. The outline hull is light, not ink (`Map3D._ink`: HUD colour, emissive; `RIFTGATE_INK=dark`
compares). Composition: wasteland across the rougher half, ruins in dense clusters, water
in bodies; ruins may sit on shores again. The gatehouse wears the lighter plate tile. Props carry the ink hull (`Map3D._prop`); dead trees
and boulders on wasteland, taller skyscraper crags with a couple of lit windows. Ruins
keep off water's shores. Units: the ground is the model's Z = 0 by convention (nothing
hangs below it; the Badger's arm was raised so the claw rests on the ground), and
`Map3D._make_unit` centres a model halfway by its bounds and sets it south by half its
height, so its body sits on the hex and a long reach leans over the front edge. Past the
field's sides the scenery dims at once and fades out (`edge_fade`), the holo table's edge. `RIFTGATE_MAP_WIRE=1` is a trial of terrain as pure
wireframe. The gate and wall were rebuilt to Ryan's curtain-wall references (21 September):
battered slabs (`_battered`) with a lip, pilaster ribs, seam bands, vents and lamps; the
gate a taller gatehouse block with a wide panelled door parting on a lit seam under a
lintel, squat tapered bastions (`_bastion`) with turret drums and twin guns at the ends,
masts on top; no blades or crenellations. Height is a relief field (`BattleMap.elevation`, steps of `Map3D.STEP`, water
sunk), not terrain type; crags sit at their ground's level. The holographic display
(decided 21 September): the grid is emissive lines in the scene (`_grid_mesh`), scanlines
and the corrupted side's flicker are in `bleed.gdshader`, the gate and walls carry the ink
outline, spikes and ruin props wear terrain tiles, rough is scrub (rare), the road is dark
paving. The edge tags no longer jump on tap. Column walls are built only on edges whose
neighbour sits at another height, so pools and fields read as one. Crags are clusters of
leaning rock spikes. The gate's rows draw no ground. Units hang off a pivot at the hex,
centred by their bounds; only flyers move at rest (a slow swell, `HOVER` 30 above the
ground, a shadow disc on their tile); grounded idle waits for joints. The team deploys
facing north (one of the two north directions, seeded). Tapping empty ground with nothing
selected shows the terrain's name, move cost and who can cross it; the readout is docked
over the bottom of the map and a tap on it dismisses it; tapping an ally selects it and
shows its shield, hull and move (no gauge over the unit any more), tapping an enemy shows
its quick label, double-tap (`hex_double_tapped`) is wired and shows the full readout until
the battle screen hosts the skirmish's codex. Flyers draw at 0.8 of a mech's fit and every
unit is set south so its visual middle lands on its hex. The tilt-shift blurs only north
of the focus. Open on the map: the gate wants a sci-fi pass (less gothic); terrain height
is landscape with no rule (decided 21 September: skirmishes happen on flattened ground);
whether squads leave corruption in their wake; the movement phase animated; an outline for
units behind tall columns; the codex on the battle screen. Deleted: `art/mechs`, the spriter, the map token
tool, all of blendforge and its .blend files. Dead code to remove next: `Sprites.combat_mech`/`map_mech` and the
skirmish's `RIFTGATE_MECH3D=off` sprite fallback, the pixel look. Not built: joints and
hardpoint pins on the new units (the engine reads `joint_*` and `hp_*`; lowforge writes
`hp_*` pins only), the wireframe mode, and a map-scale look: `Map3D` fits every unit to
about one hex (`MARKER_FIT`), but at that size the tile grain reads as static and there is
no outline, so units on the map want a flat-tone, outlined LOD (the reconstruction's
marker) rather than the skirmish's textured facets.

**Open, in the order I would take them.**

1. Ryan: Badger joints and pins; then re-export, tokens, and tune the strike swing.
2. Ryan's content: names for overheating and scorch; place strikes, breach, scorch, disable
   and rapid on foes and components; Ablative Plating as armour or shield; line versus
   "direct"; the Badger's loadout and claw numbers; Aphelion and the Arsenal; CARE's voice.
3. Engine gaps waiting on content: Numbed resistance roll; Corrupted (needs an on-spend
   trigger, value from the foe's ability); cleanse; foe roles (fodder, elite, boss) so
   execute and chain cannot cheese priority targets; the planned statuses (overwhelm, corrode, energy armour, scramble,
   confuse, retaliate, phased, taunt, beacon) are plain modifiers once placed; component
   stat modifiers as content; granted passives in their own colour on the mech codex.
4. Design still open: player interaction with the reinforcement phase; skirmish
   composition follows battlefield placement (rules and rules text needed); battlefield
   landscape, terrain costs and movespeed in tens; the economy (salvage from rift wrecks,
   research tokens, hangar repair and refit); the city's enclosure (field, dome or mountain;
   bible, 20 September); base defences: how the gate guns attack and are attacked (proposal
   in chat, 19 September), then deployable turrets.
   Build next: the contact transition (the camera flattening into the skirmish's pixel
   look), then tune the bleed by eye with Ryan (radii, gradient rows, posterize, dither
   cell), then the wall as the field's emitter line once the enclosure is picked.
5. Art: wear tuning by eye; livery on a rear or top plate; the other makers' manners on
   real models; enemy art for the eight foes still on sketch grids; gate, defences and
   hangar as models; the other chassis borrow the Badger's model and tokens.
6. Play it on a phone and tune numbers, map size, squad speeds, Rift Pressure.

**Known rough edges.** Codex stat labels cut off on Ryan's device once, not reproduced.
Routes are tap-to-destination only; a route through another mech's hex is rejected at
resolve time unless that mech moves first. The skirmish's Back button reads "BACK" even when
it returns to the battlefield. `RIFTGATE_MECH3D_FLAT=1` skips the outline pass;
`RIFTGATE_MECH3D_MODEL=<id>` previews another exported model; `RIFTGATE_MECH3D=pixel|off`.
