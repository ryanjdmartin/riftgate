# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 22 September 2026

**State.** Everything committed. Tests: 173 tests, 2372 checks, green. Ryan writes
`content/*.json` in his own voice (reload after any pass that touches it). The rules are in
`docs/vocabulary.md` (generated) and every decision in `docs/design-bible.html`; the
vocabulary carries an `order_of_operations` rule that the engine follows. Chassis ids:
`badger`, `clydesdale`, `sparrowhawk`, `anvil`.

**Setting, decided (bible 1 and 7).** The Council; the player commands CARE; the Arsenal is
the Council's R&D house; five makers at most (Minerva, Kestrel, Wainwright & Sutler,
Aphelion, the Arsenal), three in content. The city sits under a field and the gate is its
projector (20 September). The battlefield screen is CARE's tactical reconstruction, and it
looks like the commander's holographic display, over the top like the HUD (21 September).

**Rules that landed since the 18th.** Equipment: component, hardpoint, fixed; `Face` is the
engine's name only. Shields block whole; withdraw costs one enemy turn; armour flat. The
effects pipeline in `sim/effects.gd` (every number is a question). Water is fordable by
everyone at a cost by trait (tracks 3, walker 2, hover 1; hover chokes on rubble); only a
crag stops anyone but a flyer (`BattleMap.move_cost`, `passable`). Terrain height is
landscape only, never read by a rule. The gate and walls are two rows deep
(`BattleMap.GATE_ROWS`); squads strike from the row above the apron. Cooling (Ryan, 22
September): a chassis's `cooling` (content, 0 if absent; a stat in the pipeline) is shed
from heat at the start of every turn in `start_round` (one log line); Overheating ticks at
the end of the round after the enemy turn (`_tick_mechs`), so a scorch lands on peak heat;
every overheat burns at the end of the round too (`_settle_heat`: heat climbs past the cap
during the round, `_add_heat` never clamps, a vent in time prevents the burn); the
forecast's `heat_after` and `overheat` include the tick (`scorch_incoming`) and count the
die's own heat only when asked (`forecast(ms, with_face)`; the screen asks while that die
is dragged); the old MAX chip is now the burn warning; the codex grid has a heat max /
cooling cell. Placeholder numbers went in for all four chassis (10, the
Sparrowhawk 5); Ryan tunes them, and the heat sink wants a bigger number (tuning).

**Skirmish rules and screen (22 September).** A kill clears its slot at once
(`_resolve_attack` calls `_clear_dead`), so line and melee reach the back rank until the
reinforcement phase; the screen plays a ghost of the drawing (`_animate_death`) and
reinforcements step in after the enemy's replay (`_animate_arrival`). A decided fight ends
the moment a die decides it (`assign` checks the outcome; the screen shows it after the
blow plays). Every skirmish animation returns a unit to `_home` and kills what was still
moving it (`_settle`), so recoil never drifts a mech. Mech gauges and chips hug the model
by `MechView3D.model_rect` (every vertex projected through the camera's basis) through
`UnitView.used_override`; gauges 11 px tall, pending overlays pulse on one shared clock,
a die's hold readout opens above the die;
nothing reads a viewport texture back from the GPU any more (`Sprites.used_rect` did,
every frame until a non-empty read, which is the likely cause of the choppy die drag and
the floating gauges on the phone; unverified on a device). The log strip scrolls (every
line, newest brightest, scrolled to the end when something happens) and a double-tap
opens it full screen (`_toggle_log_full`); gauges sit on dark plates and a pending loss
breathes between dim and ink. Screenshot poses added: rounds, logfull, killed.

**Ally art, locked (21 September).** The mid-nineties 3D register, built by `tools/lowforge`:
`models_low.py` holds one function of numbers per chassis id (`badger`, `sparrowhawk`,
plus `gate` and `wall`), `bl_low.py` the primitives, maker metals (`MAKERS`) and the tile
generator; `forge.py build <id>` writes `art/models/<id>.glb` and a working
`tools/lowforge/models/<id>.blend` (tiles packed); `forge.py export <id>` turns a
hand-edited .blend back into the glTF with its Empties (joints `joint_*`, pins `hp_*`);
`forge.py terrain` writes the ground tiles to `art/terrain`. The model's Z = 0 is the
ground; forward is +Y. `MechView3D.toon` takes the tile look for any textured model; amber
is emissive, glass glossy. `tools/hero_shot.gd` renders one unit large. The skirmish is fought on the enemy's ground
(decided 21 September): `TerrainArt.draw_ground` styles "other" (the overworld, two
frames, under the foes) and "seam" (the tile with the other world dithering into it from
above, under the mechs); the overworld hex drawing is `TerrainArt.draw_other_hex`, shared
with `PaintedMap`. The skirmish backdrop draws each ground band in a clipped child (no spill past the
edges), on the display grid's lattice at map-size hexes with a faint grid. The skirmish's
mech views carry the trace and its backdrop's bar lights them (`MechView3D.set_sweep_screen`; `trace.gdshader` takes a `screen_down` vector). Sparrowhawk locked;
Badger is Ryan's to tweak in Blender (joints and pins are his next art job).

**The battlefield (`game/battle/`).** `map_3d.gd` is a screen-sized SubViewport whose
camera follows the map view's scroll and zoom (`look`), so it renders every frame: every
hex a column at `BattleMap.elevation` (relief field, water sunk) wearing a tile via
`terrain.gdshader` (water ripples), roads drawn by `road.gdshader` from a per-hex link mask
so they join, crags in their ground's idiom (`_crag`), props with the trace, the gate and
walls across the margin columns, units as their skirmish models centred by bounds and set
south, flyers hovering with a shadow disc; the grid is emissive lines in the scene. Every
feature edge of units, structures and props is traced in light (`game/ui/trace_lines.gd`,
shared with the skirmish's mech views, which carry a steady trace; `trace.gdshader`); the traces brighten under the screen's one scan bar (`BattleScreen.ScanBar`, drawn on
top of everything; it hands the map its y through `sweep_at`). `painted_map.gd` is the other world, two frames; `bleed.gd` and `bleed.gdshader`
composite the two by the bleed with a hard dithered seam, tilt-shift north and a wider, stronger blur past the field's sides (`edge_fade`,
`edge_blur`), scanlines and the skirmish's band on top, and expose saturation,
brightness, flicker and frame rate. The map view draws the field's frame (boundary lines,
row ticks and numbers counted up from the gate, a sector readout; `frame_alpha`). `battle_map_view.gd` draws every overlay in map space
under one transform (zoom by wheel or pinch, pan both ways); `center` and `hex_at` follow
the terrain's lift; tap empty ground for its readout, tap an ally to select and read it,
tap an enemy for its label, double-tap is wired for the codex; the readout is docked in
its own strip and a tap on it dismisses it. Before a plan is locked the map shows the phase as it will resolve
(`Battlefield.preview_phase`: the resolver's own movement run dry and every unit put
back; the map view caches it per plan): contact groups, squads stopped by another squad
(BLOCKED), routes that will be rejected (NO ROUTE). Zone of control (decided 22 September):
`Battlefield.controlled(h)` is true beside any grounded mech; `compute_intents` runs inside
`_move_all` after the mechs (preview and resolve alike, `PhaseResult.intents`); squads
plan blind to the machines (a plot never makes a squad swerve, Ryan 22 September) and the
path is cut at the first controlled hex (`intercepted`); a squad starting on controlled
ground holds; flyers control nothing. The map draws intents from the preview's intents,
never during a move: the destination is one component (tint, heavy outline, three
counter-turning broken rings, the line arriving at the outer ring; `_destination_effect`,
`_target_rings`), a contact a heavier pulsing tint with bursting rings
(`_contact_effect`; one effect per hex, contact wins), a machine's own marker sits on two
faint breathing rings (`_ally_target`), and each grounded machine's zone is one faint
tinted flower with one outline (`_zone`). The bleed never covers a machine
(`Bleed.holes`, `holes` in the compositor). Moves
play at a pace by movespeed (`MOVE_REF_SPEED` moves at `MOVE_SECONDS_PER_HEX`, the
fastest ever; slower units slower). Mechs move in plot order and routes are planned in that order
(`Battlefield.with_plan`: earlier machines at their destinations, later ones where they
stand), so Resolve never rejects a route; a re-plot puts the mech last in the order; any route
the change breaks is dropped with a log line (`Battle._drop_conflicts`). A boss stands on one hex now and patrols within `BOSS_ZONE` of
the rift (`_pick_target`, picked by phase so the preview holds); the multi-hex footprint
stays in the engine (`Unit.TRIANGLE`) for later. Squads plan and move after, in field order, each intent routed around where the squads
before it will end (`compute_intents`), so a squad never stops short of another squad.
While contacts are pending the map freezes on them (`BattleMapView.pending`: the fights
lit, no plaque, nothing of the next phase drawn). After the movement phase, a CONTACT
band beats three times over the dimmed map (about three seconds), then the contact panel slides up
(`_show_contacts` then `_build_contact_panel`: one contact at a time with `MechView3D`
and foe-sprite portraits, arrows to page, ENGAGE; paging zooms the map to that fight via
`focus_on` and lights its hexes via `set_highlight`; `Battle.open_skirmish_at`), and
nothing opens until the player picks; portraits carry no silhouette
(`MechView3D.strip_silhouette`) and foes use their battle sprite. Contact tags name the
units (`contact_text`), kept on screen when zoomed. The codex is a shared box
(`game/ui/codex_box.gd`, `CodexBox.open(entry)`), on both screens: double-tap a unit on
the map (`BattleScreen.codex_entry_for`: a machine's own entry, a squad's foe type headed
by the squad). A tap on a destination wins over the machine still drawn there, so a
route can end where an earlier-plotted machine is leaving. The bleed's squad sources follow the movement animation
(`Bleed.sources(..., moving)`). Resolve plays the movement phase (`play_moves`, which first parks every mover at its
start so nobody blinks to the end: mechs then squads along the paths they
actually took, `MOVE_SECONDS_PER_HEX`; `Map3D.set_anim` moves the model and turns it to
its heading) and only then opens the skirmish; headless skips the play. `map_tuner.gd` (TUNE on the battle screen) is
the live knob panel; nothing it sets persists. The default trace mode is `assets`: the mechs, gate and
walls in ink with a light silhouette (`TraceLines.silhouette`, the material's stencil
outline), the field's props and grid in fainter light; `pulse` rests everything as ink and
the scan lights it (`pulse_material`; the trace shader blends rather than adds, so `base`
0 is black); `RIFTGATE_INK=light|dark` for the others (the tuner's TRACE has
assets, light, ink, off). The skirmish's mech views take the same. Side blur begins at the
frame's lines (`_frame_x`), not the field's edge; intent lines carry a dark underline; the
scan bar pauses `HudBackdrop.SCAN_PAUSE` seconds between sweeps on both screens; the
corrupted tear is rarer, and the skirmish's overworld band tears too; `RIFTGATE_MAP_WIRE=1` is the pure-wireframe trial. `tools/screenshot.gd` poses:
select, route, hold, north, zoom, zoomlast, tune, predict, resolve, contact
(`RIFTGATE_SHOT_FRAME=210` catches the CONTACT band after the move plays, 400 the panel).

**Landscape generation (`sim/battle_map.gd`).** `_lay_landscape` from seeded noise: water
in bodies, wasteland across the rougher half, ruins in dense clusters, crags along a ridge
keeping the ground under them (`crag_base`), four margin columns of scenery either side
and three rows beyond the rift (`margin`, never played on), two rows of city behind the
wall (`city`, built as lit blocks by `Map3D._city_block`, blurred south into the HUD;
the scroll runs a row past the rift and a row past the wall, no further; the wall rows'
margin is level and bare), the two rows above the apron always open; `_lay_roads` lays
a drifting trunk north from the gate with branches and gaps, never a lone slab, all at
ground level.

**Open, in the order I would take them.**

1. Ryan: Badger tweaks in Blender, joints and pins; then `forge.py export badger`, and
   tune the strike swing. Then briefs for the Clydesdale and the Anvil (they borrow the
   Badger's model until then).
2. Ryan's content: names for overheating and scorch; place strikes, breach, scorch,
   disable and rapid on foes and components; Ablative Plating as armour or shield; line
   versus "direct"; the Badger's loadout and claw numbers; Aphelion and the Arsenal; CARE's
   voice.
3. The map, next: ally wrecks left on the map with a death animation (Ryan, 22
   September; a wrecked machine leaves the field today); the contact transition into the
   skirmish (proposal in chat, 22 September); an outline for units behind tall columns; joint idle for grounded units once joints exist;
   the contact transition (camera flattening into the skirmish); whether squads leave
   corruption in their wake; tune every knob with all three chrome colours; delete the
   dead sprite loaders (`Sprites.combat_mech`/`map_mech`, the skirmish's sprite fallback,
   the pixel look).
4. Engine gaps waiting on content: Numbed resistance roll; Corrupted (on-spend trigger,
   value from the foe's ability); cleanse; foe roles (fodder, elite, boss); the planned
   statuses as plain modifiers once placed; component stat modifiers as content; granted
   passives in their own colour on the mech codex.
5. Design still open: player interaction with the reinforcement phase; skirmish
   composition follows battlefield placement (rules and text); movespeed in tens; the
   economy (salvage, research tokens, hangar repair and refit); base defences: how the gate
   guns attack and are attacked (proposal in chat, 19 September), then deployable turrets.
6. Art: enemy art for the eight foes still on sketch grids; the hangar as a model; the
   field itself, if it shows; per-mech repaint in play (`Unit.paint` exists, nothing sets it).
7. Play it on a phone and tune numbers, map size, squad speeds, Rift Pressure, and the
   per-frame cost of the map.

**Known rough edges.** Codex stat labels cut off on Ryan's device once, not reproduced.
Routes are tap-to-destination only. The skirmish's Back button reads "BACK" even
when it returns to the battlefield. 
