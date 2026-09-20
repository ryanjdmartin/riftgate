# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 20 September 2026

**State.** Everything committed. Tests: 151 tests, 1746 checks, green. Ryan writes
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
`forge.py structures` builds `models/gate.blend`, `models/wall.blend` and exports the glTFs;
`tools/structure_sprites.gd` renders `art/structures/gate.png` (76x44) and `wall.png`
from the map's angle; `BattleMapView` draws them under the units. Ryan may reshape
the .blend files; rerun export and the sprite tool after. Rebuilt 20 September to feel epic:
wall body 70 high, a gatehouse above it with a tall narrow pointed mouth in three stepped
reveals, towers of 112 with fins and bigger guns, blades along every top edge in place of
crenellations (Ryan: sand-castle squares make it small). Sprite frames 92x70 and 31x48
(widths fix the hex scale, heights follow the projected aspect). Not yet seen in play by Ryan. Per-mech repaint exists:
`Unit.paint` {primary, secondary} recolours the livery and bone plating (`MechView3D.paint`,
`ramp_for`); `RIFTGATE_PAINT=badger:ff8800/223344` previews it. Nothing sets it in play yet.

**True 3D battlefield (19 September, decided).** Bible: the battlefield is 3D and the rift's world
bleeds in as flat 2D (gradient toward the rift plus radii around squads; foes are flat
images with no 3D cues; contact flattens the camera into the skirmish look; terrain marks
as a ground texture). Not built yet beyond the experiment: the compositor of the 3D
viewport and the existing 2D map by a mask, the prop collapse, the contact transition,
zoom. Fiction frame decided 20 September: the screen is CARE's tactical reconstruction
(survey plus telemetry; the rift's world returns flat; contact hands over to the feed), with
sensor language for the HUD (contacts, returns, projections) wanted. Open, awaiting Ryan: what
keeps the rift's world out of the city, since a wall can be flown over. Proposal in the bible:
an energy field with the gate as its projector, the mouth its one blind spot.
**True 3D battlefield (19 September, experiment).** `RIFTGATE_MAP3D=1` swaps the map's
ground, structures and units for geometry in `game/battle/map_3d.gd` (a SubViewport the map
view draws behind its overlays): hex ground stretched in depth so it projects onto the 2D
grid exactly (overlays and gestures untouched), lit props for mountains, rubble, rocks and
roads, the gate and wall glTFs, mechs as toon models turned to their facing, foes as
billboard sprites. `MechView3D.toon` is the shared material pass. No outline pass, no
terrain marks yet. Off by default until Ryan decides.

**Art (17 September).** Player units are native 3D (glTF plus toon and surface shader);
enemies painted 2D. The Badger's working file is `tools/blendforge/models/badger.blend`
(finished; `polish` refuses it); `forge.py export` then `tools/map_tokens.gd` then
`--import`. The engine reads `joint_*` and `hp_*` Empties (idle, strike, mount). Ryan is
adding joints and pins by hand; the file has `hp_3` and `hp_4` on the tubes so far.

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
   Build next, once the enclosure is picked: the 3D map compositor (mask of north gradient,
   squad radii and rift; prop collapse; terrain marks as a ground texture; contact transition).
5. Art: wear tuning by eye; livery on a rear or top plate; the other makers' manners on
   real models; enemy art for the eight foes still on sketch grids; gate, defences and
   hangar as models; the other chassis borrow the Badger's model and tokens.
6. Play it on a phone and tune numbers, map size, squad speeds, Rift Pressure.

**Known rough edges.** Codex stat labels cut off on Ryan's device once, not reproduced.
Routes are tap-to-destination only; a route through another mech's hex is rejected at
resolve time unless that mech moves first. The skirmish's Back button reads "BACK" even when
it returns to the battlefield. `RIFTGATE_MECH3D_FLAT=1` skips the outline pass;
`RIFTGATE_MECH3D_MODEL=<id>` previews another exported model; `RIFTGATE_MECH3D=pixel|off`.
