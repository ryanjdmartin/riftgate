# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF (v0.43 since 6 October: the makers' vocabularies as naming guidelines, the Puffin's names and speed, the Arc Fault Cannon and the Umbra Inducer, over the movement session's v0.42, the sixth notes on the machines); republish it from the committed file after every bible change, passing that URL, and read it first, since a publish over a newer version is refused.

**The pages, as of 2 October.** Every page lives in the personal account (A). Four are shared
to the work email (B) as Editor, so a session in either account republishes them in place by
URL (a read first, then publish with `url`; checked from a B session on 2 October, the Melody
Desk republished unchanged), and no account keeps a copy of its own. The engagement sandbox
stays in A alone (Ryan, 1 October: it serves one ongoing task) and is republished from an A
session; a B session cannot read it. Shared:

- **The bible** (above): `docs/design-bible.html`, published whole after every change.
- **The hangar page** (https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH; republished 4 October with the acts and movement's second pass): four tabs, the
  codex, the content editor, the names list and Models. Models (the renders and the Animation
  tab merged, Ryan, 3 October) puts each machine live in 3D on top: its acts, walk and
  cornering played from its rig sidecar by `tools/hangar_motion.js` (published as
  `hangar/motion.js`), a port of `game/ui/mech_rig.gd` and `Map3D._corner` that must move with
  them in the same commit; Acts (in turn or one looped, a scrubber, melee and shot blows), Walk
  (the RIFTGATE_MOVE_DEBUG drive) and Route (a four-move loop on hexes sized and paced as the
  map's, which shows the drift, the banks and the helicopter strafe the debug switches cannot);
  every mount takes stock, bare or any silhouette class in any maker's metal, fitted live as
  `MechView3D.mount` does. Under the stage sit the game's own renders of that machine, with the
  pass's note and the earlier passes folded: those carry the look to judge, since the 3D view's
  lighting is the page's own. Classes in the picker shows one class alone in any metal, turning,
  over the game's renders of the classes and the refits. The codex thumbnails open the machine
  there. The tab no longer carries the codex's filter (thirteen machines fit the picker).
  Artifacts do not serve .glb, so `hangar_data.py` writes each model and each class as glTF
  JSON into `build/hangar/models` (git ignores it), with `build/hangar/shapes.json` naming the
  classes (the engine's SHAPES) and makers, and maps them all; the 3 October republish sent only
  the page and those files, leaving the content files as they were. The viewer's content policy
  refuses `fetch` on a `blob:` address, which three.js r128 uses to decode embedded textures
  ("Could not load the model: Failed to fetch", fixed 3 October): the page fetches each model
  itself and a loader plugin decodes textures through image elements. A local test of the
  page needs the policy too (`connect-src 'self'`), or it passes where the viewer fails. Since 2 October, night, every list carries a filter and sort bar (search,
  chips per group, a sort with its direction); the codex, the models and the editor's chassis
  list share one chassis filter, and the codex has a Compact view of stats alone. Filters are
  kept per viewer in the browser, not in the database. Source `tools/hangar.html`, published with the `files` map
  `tools/hangar_data.py` prints (`content/*.json`, `hangar/pins.json`, `hangar/renders.json`
  and every render under `docs/hangar/renders/`); republish after every content, model or
  render change, or its tabs go stale. Capabilities `db` and `user`; collections `edits` (the
  editor) and `candidates` (the names). Ryan edits content from his phone on its Content tab;
  after he does, pull `edits` with ArtifactData, apply by hand (the files are hand-formatted),
  test, commit, republish, clear the documents.
- **The Melody Desk** (https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV): a piano roll of up
  to sixteen bars, source `tools/soundforge/melody_desk.html`. The shipped tracks' parts stack
  as layers from collection `parts` (seeded by `tools/soundforge/desk_parts.py`; re-seed after
  a track's parts change). Send writes to collection `melodies` with every note, each layer's
  source and Ryan's memo; a session pulls a `new` document, listens, applies it in the forge
  and marks it `applied` with a `reply` the page shows. The session interprets what he sends;
  it is not drop-in.
- **The listening page** (https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9): the effects'
  pass from `tools/soundforge/fx_sketches.py` (the weapons' third cut, the console, the blunt
  impact with its plasma layer, the voice in two registers; every file re-rendered 2 October),
  the console derived again that night, the voice re-rendered), and nothing else; render with
  `fx_sketches.py`, then `console_sketches.py`, then `warroom_sketches.py`, copy `fx_page.html` in as `index.html`, and
  republish from `tools/soundforge/out/fx/` with `root` set to it (numpy and scipy, plus ffmpeg). The music
  rounds re-render from `phone_sketches.py` if ever wanted again.

In A alone: **the engagement sandbox** (https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg) that
drew the zone options, for the play test of the engagement zones.

**Rules learned:** a page's link goes into
this file in the same commit as the publish, so a parallel session sees it before publishing a
twin; `Artifact` with `action: "list"` shows only what the account you are in owns, so a shared
page is reached by its URL, never by listing; a page's database stays with the owning account:
from a B session ArtifactData is refused on every collection (checked 2 October on `edits` and
`melodies`), so pulling `edits` or `melodies`, re-seeding `parts` and clearing documents happen
in an A session (Ryan can use every page's database from the page itself in either account).

**Cold start, including from another account.** Nothing needed to work here lives outside
the repo. Read this file, then `docs/todo.md` (the task list), then `CLAUDE.md` (the rules,
the commands, and how Ryan works: he pressure-tests, judges effects running, leans hotter
on a phone, and retires old directions as he goes). `README.md` has the layout and every
command with its screenshot poses and phone-layout variables. The bible's sections hold the
why; section 11 carries the phone rows, section 12 the roadmap. Ryan may be running
another session on this repo at the same time: `git status` first, stage by path, diff a
shared file before staging it, and never `git add -A`. If a chat and the bible disagree,
the chat is newer.

## As of 3 October 2026

**State.** Tests green: `perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s
tests/run_tests.gd` (335 tests, 7,806 checks on 5 October in a cloud session, after the campaign session merged with the Puffin's passive;
a cloud session fetches Godot 4.7's Linux build from the GitHub release asset to run them
(`Godot_v4.7-stable_linux.x86_64.zip`, and `xvfb-run` for screenshots), since
the proxy serves the asset though not the release page; it builds models too, with
`BPY_PYTHON` naming a python3.11 venv holding `pip install bpy==5.0.1`, blender.org being
unreachable there, and renders through `xvfb-run` on Mesa's software GL, so `tools/hero_shot.gd`
and `tools/act_shot.gd` work there). Two or three
sessions run on this repo at once: check `git status` before committing, stage by path, diff a
shared file first (a path still sweeps the other session's hunks), never `git add -A`, never
kill a bare `godot --path .`. Commit after each verified chunk with tests green.

**2 October: the to-do review and what came of it.** Every to-do line was checked against the
code. Ryan's calls, each in the bible:
- Closed: the d4 question (die size is a balance lever like any base stat), the participant
  cap (four columns is the most a formation will be), the Baboon's rear silhouette and the
  Clydesdale's twin spacing. The seated die is in the new effects pass.
- Idle acts and movement (section 7): a pilot drives every machine, never an animal; several
  acts per machine; grounded machines never sway; cockpits fixed but the Clydesdale's head;
  the joints each machine needs are listed; the Dingo drifts through one cornering module
  shared with flyers and hovercraft, its slide and bank tuned per machine.
- Battery (section 11): weld the machines at load, props by hex with a dither fade, the 3D at
  30 while planning, which comes after the animations so it can be judged against them.
- Later: a prototype hangar (paints and loadouts, no economy); the commander layer once the
  balance has a baseline; enemy targeting and the horde hooks in Ryan's own design session;
  the Armadillo sealing its ports, to consider once the acts run.
- Built: the plate lists traits, not a silhouette; the field is gone from the content, the
  codex subtitle reads maker, traits, die; Wheeled is on both cars and Tracked is the tank
  trait, both planned.
- Found: eight of nine foes are still their sketch grids (the ghoul is the foeforge cut); the
  Honey Badger cannot ford today; water's terrain codex wrongly says impassable.

**2 October, late: movement by way of moving and the pacing direction** (bible section 4, the
movement row decided and the pacing row open; bible v0.20). The day's price table is retired:
a bigger move bought back any price, so a wheeled 60 reached everything a walker 30 did.
Instead each way of moving calls each ground fast (5), normal (10) or slow (enterable with any
move left, and it ends the move), on four grounds: open (plain and road; road is art only),
rough, ruins and water. Moves follow size and role; the content check flags, never refuses, a
chassis at least as fast as another on every ground (Ryan: a slow wheeled APC is valid). Foes
move binary: every land hex 10, water and mountains walls. Water gets built around (one real
feature a map, with foe crossings two or three hexes wide, judged with Ryan's hovercraft).
Pacing is open for Ryan's session: a threat bar whose marks are prizes and one of which
unseals the boss, an elite tier, Rift Pressure escalating, the flattening reaching the gate as
the hard backstop. The discussion was measured in a cloud session on 200 generated 7x20 maps
(a rush wins in 3 to 9 phases, a flyer starts the boss fight by phase 3, a team that never
moves holds the undead for 300 phases, 210 of 1,400 packs stuck at a shore under the old
costs). Those probe scripts lived in the cloud scratchpad and are gone; the method is in the
to-do's water-feature line. The build landed the same night (next paragraph).

**Movement by way of moving is built** (2 October, night; bible section 4, the movement row
ends with what stands; the to-do's ticked line lists the pieces). What the next session
should know: moves are in tens everywhere (`Unit.MECH_MOVE` 30, `PACK_MOVE` 20, `BOSS_MOVE`
10 are the defaults before content dresses a unit); `BattleMap.move_cost` returns a word
(`FAST` 5, `NORMAL` 10, `SLOW`, `WALL`) and `BattleMap.spend(t, traits, left)` is what every
budget site calls; a unit with no way of moving moves by the horde's rule (normal on land,
water and crags walls); `Battlefield.hunt_target` aims a hunter at the shore when its prey
stands in water; `ContentDB.movement_flags()` prints, never fails.

**The movement leftovers, built 3 October** (bible section 4, the movement row; v0.27). The
**move gauge**: pips at the end of a route being drawn, one a normal hex split in halves for
fast, filling from the left; solid while left, a faint outline when spent, hatched when a slow
last step took them (`Battle.draft_spend`, `BattleMapView.gauge_cells`; the `draft` and
`draftslow` screenshot poses). The **horde's crossing three wide** (Ryan's call over waiting
for the water): `BattleMap.CROSSING_WIDTH`, max flow reads `narrowest_crossing()` and
`horde_cut()`, and `_ensure_ground_path` routes the horde round each narrower cut by the
cheapest openings, a crag before water (`opened` records what it opened). The **water
feature**: `_lay_water`, one a map, a river through the field with fords along its line or a
lake band from the west, the east or in the middle (`water_feature` names it); the wetness
field is gone. `tools/map_survey.gd` measures 200 seeds into `docs/map_survey.md`: every map
three wide or more, water 6% of the field in 1.7 bodies (3.9 with the puddles), 16 ms a map;
`--show SEED` prints a map as text. Its phases to the rift barely move by way of moving, so the
river's bite is where the horde crosses and where a walker off a ford stops; Ryan judges it with
the hovercraft. Left: the small finds and the hangar page's other content files (the to-do).

**The hovercraft are on main** (2 October, night, merged from the Mac session; bible section 7,
the hovercraft row). The **Stingray** (Aphelion, `stingray`): hull 80, shield 50, move 40, heat
max 100, cooling 0 by design, a d6 of the locked Photosphere Lance (hot energy burn) and five
hardpoints with the new Aurora Lattice (Aphelion's buff, Primed) in stock; its Exothermic Suite
deepens every stack it applies by one per 20 heat carried, through the `on_stack` trigger and
`add_stacks` effect (`Effects.extra_stacks`, read at the burn, Primed, buff and devour sites in
`sim/skirmish.gd`). **Numbed is exempt from every interaction** (Ryan, a general rule). The
**Puffin** (Kestrel, `puffin`): hull 50, shield 30, move 30 (the slowest Kestrel), a d5 of the
locked Prow Projector (shield 30, allies only) and four hardpoints, the Overcharge Coil's first
chassis; its passive **Slipstream** (decided and built 5 October; the name a placeholder): an ally it
shields also sheds 10 heat, through the new `on_shield_granted` trigger (fires on the granter with the
recipient, on the spend); and the Prow Projector carries **Overshield**, a new rare support keyword
(shields only): the shield may pass the target's maximum and the excess fades at the round's end
(`Skirmish._trim_overshield`), shown on the gauge as a hatched block beyond the bar's end. No penalty:
the die is the brake. The bot weighs both (`Policy.shield_score`). Both modelled (`stingray(b)`, `puffin(b)` in `models_low.py`; propulsion reads the
maker: the Stingray on lift fans flush in its wings, the Puffin on boosters far too big for it)
and rendered to the hangar page's Models tab; rebuilt twice the same night on his notes (the
Stingray: too literal and floating, so no tail and every part seated on the skin through
`_ray_top`, `_seat` and `_ridge`; then the turret a sleek dome with the emitter leaving its
edge, the rear mounts under the wings, the stern two hollow exhausts; the Puffin: hilarious
and floating, so a sleek escort; then that read as a thing that could fly and had lost the
charm, so a wide oblong hover hull wearing the first pass's head, bill and dark back, boosters
in the sponsons, fins for the ancestry, no wings), then a fourth pass on 3 October (the Stingray's pods under the forewings, its turret pin back
into the dome, its tail one wide exhaust duct; the Puffin without its head, with a fighter canopy,
side wings and the giant louvred boosters brought out), then a fifth pass the same evening on his fourth
notes (the Stingray's turret pin deeper under a taller dome, its tail tapering again with the grey one thin
rim, two front mounts to the wing tips, the shoulder pods by Claude's pick with the other pick, the forewing
pods, rendered beside it under `RIFTGATE_STINGRAY_TIPS=under`; the Puffin's wings reverse-swept and drooping
with their pods clear of the blade, the canopy carried back and settled with a frame band, the skirt up the
prow to the nose, the deck carried over the boosters as lids with the vent housings on them, the rear mounts
moved to the shoulders), then a sixth pass that night on his fifth notes (the Stingray's tail short and
thin, the third pass's shape; the Puffin's back too boxy, so the fourth pass's taper and half-out drums came
back, each sponson a faired nacelle whose top is the deck itself sloping with the hull, a narrow low vent
housing on it, the wings grown out of the nacelles' flanks, the skirt ending on the prow's chine), then on his sixth notes the Stingray's tail in one
straight stage (the weapons layout kept, the tip-mount pick closed, the switch gone) and, for the Puffin, which
he likes but which does not quite read Kestrel, a sleek trial rendered beside the model and not into it (a
chined airframe hull leaning in to a narrower, lower deck, a pinched waist so the nacelles stand proud, taller
swept fins; `RIFTGATE_PUFFIN_SLEEK=1` at build) with suggestions in chat, the earlier passes folded under each
on the Models tab, for his seventh look; then on 5 October the Stingray's eighth pass, since the seventh
still read as two stages (the body had run on behind the wings as a near-parallel neck before the taper): the
body now ends at the wings' trailing edge and the tail is one straight taper to the exhaust; the ninth pass ran
that taper longer to a smaller tip. The Puffin's sleek trial was made the model the same day (the chined hull),
and suggestions 4 and 5 (a skirt at two thirds, a cobalt chine stripe) kept on top. Then the Stingray's
tenth (the left tip's flare pods pointing forward, the fire a unit inside the mouth), and Ryan called both
hovercraft good on 5 October. The hangar
page was not republished for it (the movement session had it in flux); the renders are in `docs/hangar/renders/`. The Stingray's helicopter-style movement is being built
in the movement session; when it lands, the skirmish's `sway_pitch` idle is to be judged
against it or retired. The skirmish's hover
idle gained a slow pitch (`sway_pitch`), to judge running. The merge took the tens for both
moves and the balance matrix is rerun with thirteen machines (the Balance paragraph). **The
hangar page's content is ahead of main again** (2 October, night): another session is tuning
numbers on the page from a tree not yet committed (its components, foes and vocabulary files
match no commit: the Chainsaw Claw at 10 to 20, the Pit Lord's armour at 5, among others), so
this session republished only the page's chassis file, with the hovercraft, and left those
three alone; the page's numbers are not the repo's until that work lands on main.


**Open from the audit (1 October).** The bible's HUD palette row (18 September) read Ryan's
swatch confusions as protanomalous, while the 29 September rule says he has not named the
type; both rows say so, and every colour is checked under all three simulations regardless.

**Where things are.** `sim/` is the headless game (battle map, battlefield resolver, battle
loop, skirmish, effects pipeline, content DB, save). `game/battle/` the battle screen and the
map (`battle_map_view.gd` overlays and gestures, `map_3d.gd` the scene, `painted_map.gd` the
other world, `bleed.gd` + `bleed.gdshader` the compositor, `orders_board.gd`,
`boss_reveal.gd`). `game/skirmish/` the fight. `game/ui/` the HUD kit, codex, pause menu,
`mech_view_3d.gd`, `trace_lines.gd`, the feed effects (`feed_fx.gd`, `tear_layer.gd`;
`RIFTGATE_FEED_DEBUG=1` fires them constantly). `game/audio/sound.gd` plays every sound by
name; `tools/soundforge/forge.py` builds them into `art/audio/`. `tools/lowforge/` builds
every model by code (`models_low.py`, one function per chassis id); `tools/screenshot.gd`
poses either screen (README lists the poses and the phone-layout variables);
`tools/balance.gd` writes `docs/balance.md`; `tools/android.sh` the debug APK,
`tools/phone.sh` a Web build on the LAN. `tools/hangar.html` is the hangar page and
`tools/hangar_data.py` its pins file and publish map; the renders live under `docs/hangar/`. `docs/vocabulary.md` is generated from content
(`tools/export_vocabulary.gd`).

**Content (bible section 7).** Thirteen chassis: `badger` (d6; its fourth stock entry the
Proximity Klaxon), `clydesdale` (d9; the die cap is 10), `sparrowhawk`, `baboon` (Aphelion's;
d7, the Halo Shield dropped; passive Pocket Paradox on `on_foe_status`), `armadillo` (its
locked component the Lockdown Shutters), `wild_boar` (five hardpoints), `prairie_dog`,
`dingo`, `goshawk`, `nemesis`, `ammit` (the last two the Arsenal's), and since 2 October the
hovercraft `stingray` (Aphelion's, d6, passive Exothermic Suite on `on_stack`) and `puffin`
(Kestrel's, d5, passive Slipstream on `on_shield_granted`; its Prow Projector the first Overshield). Nothing
else in content is planned: every passive, keyword, status and trigger the vocabulary names runs
(`Effects.fire`; the bible's section 7 row "The 28 September pieces, built" has each one), and
the ten foe actions run (`Foe.ACTION_EFFECTS`, weights 3:1 attack to special as placeholders,
section 9 row). Still planned in the vocabulary, waiting on design: Phased (parked), Corrode, and the
commander and city pieces (the command die, one-shots, the reward pick, city abilities,
cooldowns). Numbers are in tens and are placeholders;
every stat is read through `sim/effects.gd`. An enemy unit is a **pack** everywhere. Ryan
writes `content/*.json` in his own voice (he writes die totals in his head; the data keeps
free slots). Every component's codex and flavour are empty (45), and the nine new machines'
codex and flavour too: his to write. Tests never hardcode an entry's passive name.
`content/reserved_names.json` holds about 1,250 machine names (BattleTech, Heavy Gear, 40k,
Halo); the validator refuses an exact match unless `design.name_clash` says why it stays, and
every flagged name is decided (the bible's naming row). Names and concepts are spitballed on
the hangar page's Names tab (a tab per maker, Components, Rules; rows in the page's db
collection `candidates`; the check reads the reserved list and the live content, so nothing is
baked in).

**Models (bible section 7, the mount-rule row has the rule, the helpers and every machine as it
stands).** Every chassis has a lowforge model; `tools/lowforge/models_low.py` holds one function
per chassis id and every number in it is a proportion, so a note moves it and `forge.py build
<id>` plus one `--import` is the whole loop. Hardpoints are gun mounts (`hp_<n>` pins, each
parenting its stock part or a bare pad); a shaped component takes the next mount in its maker's
metal (barrel, twin barrel, rack, blade, dish), armour and vents show nowhere. Joints are code
too, nested where one rides another (`with b.joint(name, pivot, axis=, limits=)`), and so are
the idle acts (`b.act(...)` at the end of each machine), both written to the model's sidecar
`art/models/<id>.rig.json` by the build. The round-by-round history is retired (Ryan, 1 October); the code and the
hangar page's Models tab are the record. **Ryan judges a model only from a render**, never from
code (`tools/hero_shot.gd` renders bare and needs a window); a hand edit in Blender has to be
re-expressed in the code to survive a rebuild. **The eleven machines of 1 October are signed off for
now** (Ryan); the two hovercraft of 2 October are at their seventh and sixth passes (3 October, night) waiting on his look on
the Models tab, carrying the acts and gaits the animation session wrote for their second pass (the part
names brought over to the third); the joint pass, the idle acts and the movement animations landed
3 October (the paragraphs below); next on the art side is Ryan judging the acts and the movement
running. Open on the models: each class's size per machine, and the machines' scale
on the map's hexes (Ryan, 2 October: needs adjusting; all are fitted to one width today).

**Joints and idle acts, built 3 October (a cloud session; bible section 7, the idle-acts row
and the joints row).** Every joint the joints row asked for is in `models_low.py`: elbows in
the Badger's booms with the claw's jaw as two halves on its pin; the Clydesdale's head (the
cheek mounts on it), hips and knees, elevation inside the mortar and howitzer turrets; the
Baboon's elbows, hips, knees, ankles and projector elevation; the Armadillo's hips, knees, port
guns and missile cell; the Wild Boar's mantlet, plow and pod; the Prairie Dog's wheels,
steering, sensor head and chassis; the Dingo's casters carrying wheel spin, harpoon, chassis
and mortar; the Goshawk's nacelles; the Nemesis's elbows, hips, knees and Meteor tubes; the
Ammit's elbows, hands, legs, planted lower pair and cannons. Each joint names its axis
(pitch, yaw, roll; a turret, caster, steer, head or sensor yaws by name) and its limits (the
Clydesdale's turrets outward only, the casters' swing); the build writes them with the acts to
`art/models/<id>.rig.json`. The rebuilt glTFs were checked geometry-identical to the committed
ones (a scratch comparer: world-space vertex hashes per mesh), so no render should differ;
they were built with Blender 5.0.1 as a Python module (`pip install bpy`), since the cloud
cannot reach blender.org, so the Mac's next `forge.py build` rewrites the files differently
byte for byte and identically in content. The engine: `game/ui/mech_rig.gd` (MechRig) reads a
model's tags and sidecar, picks an act every 2.5 to 6.5 seconds (never the same twice running,
each instance seeded apart), samples keyframes per joint (degrees in the machine's own terms,
eased or linear, a slide for a chassis squat), a body track for revs and strafes, a glow track
scaling the emission of named lit parts or a joint's or socket's group, clamps to the limits,
and plays the strikes (melee swings the `swing` joints, the shoulders; ranged kicks whatever
carries a socket, toward the side its limits allow). `MechView3D` and `Map3D` each own a rig
per machine; the limb-settle idle and the turret scan are gone; flyers and hovercraft still
sway on the pivot and their acts ride the body. `RIFTGATE_ACTS_DEBUG=1` plays the acts back to
back, `=<act name>` loops one. Every act's numbers are a first cut for Ryan to judge running
(the to-do has the doubtful signs). Tests: `tests/test_mech_rig.gd` instantiates every model
headless and checks the sidecar against it, the nesting the bible asked for, the picking, the
limits, the strikes and an act's motion.

**Movement animations, built 3 October, later (the same session; on main, for Ryan to
judge).** Each machine's gait is authored
beside its model (`b.gait(...)`) and written to the same sidecar; `MechRig.drive(speed, aim,
turn, dt)` plays it: cycles keyed by distance travelled (a stride in model units, so a slow
machine steps slowly), the walkers in diagonal pairs through one `_step` shape (hip forward
to back over the stance, the knee bending through the swing to lift the foot), the Baboon's
fists planting in step, the Nemesis's arms swinging against its legs, the Ammit's planted
lower arms stepping; wheels spun by their radius and never unwinding; treads scrolling their
tiles (`uv1_offset` on the tread meshes, per instance); the Prairie Dog's steering knuckles
turning with the turn and the Dingo's casters pointing along the travel; offsets held while
moving (the Badger's booms carrying the claw clear, the Goshawk's nacelles tilted forward, a
flyer's nose down); boosters brightening; a rock on pulling away and stopping from the
smoothed acceleration; and a bank into turns. The cornering module is `Map3D._corner`: the
facing eases toward the move's heading at a rate from the machine's `slide` (0 snaps, as
every machine did before; the Dingo's 1.0 lags through corners and sideways steps, so its
casters swing toward the move and the body keeps its facing), and the rig is told the
speed (from the seat's motion, in model units), the travel's bearing against the facing and
the turn. A pilot on the move starts no act; the gait blends in over a quarter second and
settles out over a third. `RIFTGATE_MOVE_DEBUG=1` drives every machine constantly at the
reference speed on both screens; `tools/act_shot.gd <chassis> <maker> gait <seconds> out.png`
freezes a stride, and the frames checked here read right (the diagonal pairs, the lifted
fist, the swinging arms, the carried claw, the tilted nacelles). Every number is a first cut.
Then, on Ryan's word (3 October, later): the Wild Boar's and the Prairie Dog's turrets hold
their aim while the hull turns under them (`hold_aim` in the gait: the turret winds against
the turn, up to 170 degrees, and relaxes to centre over most of a second once the hull runs
straight); a machine with a slide sits off its path on the outside, by how square its travel
is to its facing (`DRIFT_UNITS`, 12 model units for the Dingo at a right angle, eased), on top
of the facing's lag; the Stingray and the Puffin have three first-cut acts each and brighten
their thrusters under way. Not done: the feet arcing a little through the stance. Tests cover
the cycle sampling, a walker stepping and settling, wheels and casters, holds, rock and bank,
the held aim, the drift, the hovercraft's sidecars, every gait against its model, and no act
under way. **Movement styles (Ryan, 3 October):** the Stingray is the first helicopter-style
machine, on its fans, with one or two more to come: it keeps its facing through a move (the
map's `strafe`: it yaws to the facing it will end with in the first moment, then translates
there, sideways or backward as the path demands) and leans into its travel by its speed
(`tilt`: nose down going forward, up going back, a side down going that way; no bank, no
rock). The Puffin is a jet crossed with the Dingo, on its boosters: it banks into turns and
its facing lags the path, less wildly than the Dingo's. Both for Ryan to judge on a real move.

**The second pass, 4 October (Ryan: acts too subtle, moves too fast with hard corners; bible
section 7, the joints row).** Every machine's acts are rewritten in `models_low.py`: four to
six seconds each, several joints at once, the body moving with them, and glows at six to ten
so they read from across the map (the Sparrowhawk strafes as it dips its wings, the Baboon
inspects each arm, the Puffin's hop leaps, the Ammit rears, the Armadillo presents its back
guns). Moves on the map are `game/battle/move_path.gd` (MovePath): the hex route cut into
one curve with arcs at the corners, speed from rest to rest under each machine's `accel`
(seconds to full speed) and slowing into corners by its `corner` (the share given up at
sixty degrees), both from `b.move` in the sidecar. Machines run at
`MECH_SECONDS_PER_HEX` 0.55 (was 0.22); the packs keep 0.22 and their straight steps, my
call, which Ryan can reverse. The rock, bank and drift are eased softer to match, and a
machine at rest turns to its recorded facing rather than snapping. The hangar's Route runs
the same curve (the JS port matches the GDScript's durations). Tests: `test_move_path.gd`, and
the rig tests now read their numbers from the sidecars. Ryan judges it all running.

**The codex (29 September; a tab of the hangar page since 1 October).** One surface showing a
chassis and the components fitted to it: the Codex tab renders it in the browser from the
content files beside the page, each chassis with its plate, stats, passive, current render and
die laid out entry by entry, the model's mount count (from `hangar/pins.json`) checked against
the hardpoints, each component's class as a dashed chip, planned entries marked, pending edits
laid over and tagged; tapping a name or an entry opens it in the Content tab. One page, one
database, so the codex and the editor never fight.

**What the game does today.** A battle: the map shows every pack's intent and the exact
result of the plan before Resolve; every pack carries an engagement zone from its foe type
(`zone` in `content/foes.json`; `Unit.zone`), drawn red where it will stop, and every machine
inside it fights it, a machine inside two zones joining those fights into one; a pack stops
only where a body stands in its path; every pack commits its route when the round opens
(`behaviour`: a pusher walks it, an aggressive pack turns for a machine that ends inside its
reach, the dashed ring, a hunter locks one machine by its caveat, `hunts`, and chases it;
decided and built 1 October, bible section 5). Resolve plays the moves, a CONTACT band, a
panel of contacts; ENGAGE cuts to the skirmish, the dice fight on the enemy's ground, four
columns, every blow heard, the enemy's turn replayed blow by blow; Back applies it. The
boss's contact takes the phase: no panel, a reveal, the family's theme (only The Chorus has
one). MENU pauses, holds the settings and names the track. The codex opens by double-tap on
either screen and shows the machine's base state plus battle rewards, its passives one row
each coloured by source; the fight's effects live on the chips and the hold. Under the map,
the orders board (`game/battle/orders_board.gd`) carries every machine's gauges, its order
and what it will meet while nothing is held; the log is behind its LOG button. A battle
started from the harness is saved after every change (`sim/save.gd`, `user://battle.json`)
and Resume battle opens it where it stood; standalone runs and tests never write it.

**Balance (bible section 11).** `sim/policy.gd` plays the skirmish headless (RANDOM, GREEDY,
`withdraw_below`); `tools/balance.gd` runs the matrix, about nineteen minutes on the Mac at 200 seeds with
thirteen machines, four team rows (the starting team, and since 5 October a team of three per
maker with three machines: Minerva, Kestrel, Wainwright & Sutler), twelve packs (the nine plus
each faction's whole formation in one fight, since 2 October) and the starting team run twice
for the targeting comparison (`docs/balance.md`, generated 5 October, evening, 86,400 fights).
**The hovercraft's first read:** the Stingray alone sits in the support band beside the Baboon,
beating the back-rank packs under greedy and losing to every front-rank pack and formation; the
flare, the emitter and the lance share its spends about a third each and the Radiator Sail takes
2%, so the bot runs it hot and never vents (the Nemesis's problem again) and cooling 0 is the
knob to watch. The Puffin alone loses nearly everything, as an escort with an allies-only locked
shield and a planned passive must (its Prow Projector is never spendable in a solo cell; greedy
still takes the necromancers at 71%); it reads only once a team cell carries it. The maker team rows (5 October, evening) put it on a cell at last: the Kestrel team (Sparrowhawk, Goshawk, Puffin) is the first team row with a decision on the formation cells (random 44, 85 and 92 against greedy 99 to 100; the starting team wins them all at both rungs), costs the same as the starting team on the Risen formation (4.0 rounds, 17% hull), and spends the Backwash Ionizer (the Prow Projector until 6 October) 2% of the time and the Deflector 9%, because nearly every cell ends in a round or two, where a kill ends the fight and a shield only delays it. The projector reads only on the formations; dead or patient waits on longer packs and on Ryan's play. The Wainwright & Sutler team is the weakest team row (random 20 on the Risen formation, 7.0 rounds and 26% hull under greedy); Minerva's wins everything at no cost. **The baseline reading, for Ryan's
question of whether 80 a round is average or game-losing:** the team of three still wins every
cell, the formations included, in about a round and at no cost, under the aims and under the
lowest-shield rule alike (the Risen formation, fifteen foes, is the one fight that lasts: 4.6
rounds, 17% hull, both rules). Targeting cannot read on the team cells yet because the foes die
before they swing: the team's damage dwarfs every pack's hit points, so that, not the
targeting rule, is the first number to move. Alone, the playtest set bit hard where it was meant
to: the ghoul swarm turned the easiest pack into a wall for the light machines (the Ammit 95 to
0 under greedy, the Nemesis 100 to 27, the Clydesdale 96 to 54; the Badger, Armadillo and Boar
still clear it at little cost, which is armour against volume doing its job), the breaching Pit
Lord and the double-biting Maw cut the solo win rates of everything but the three heavies, and
the Colossus barely moved. The Badger, Armadillo and Wild Boar still win nearly every solo cell;
the Baboon, Prairie Dog and Dingo lose to every front-rank pack alone, as support machines
might. Pick share: the Klaxon's lure is spent 1% of the time, since the team never needs it;
the Shutters 2%. Rerun after each engine piece lands; read bands, not numbers.

**Audio (the bible's section 1 sound row has the direction, the palettes and every rule; the
listen-by-listen history is retired).** Everything is `tools/soundforge/forge.py` writing WAVs
into `art/audio/` (`build`, `measure`, `sections`, `audition`, `sketch`); the recipes are the
record of each track. Six titled tracks in `Sound.TRACKS`, all locked or "pretty great"; the
map's set cycles Low Ground and Night Shift, the skirmish's picks one of Hold The Line, The
Crossing and Full Bore per visit, The Far Bank is The Chorus's boss theme (`SETS["boss_<faction>"]`,
`LOOP_FROM`). The track levels stay until Ryan says otherwise. Ryan judges on his phone, so a
change is heard as an A/B from the listening page before it lands; a sketch never overwrites a
shipped track; his melodies come through the Melody Desk and the session interprets them. **The
effects' pass** is on the listening page (`tools/soundforge/fx_sketches.py`; the bible's sound
row has the set and the 2 October decisions), nothing shipped. Where it stands (Ryan, 2 October):
the weapons' third cut (every blow drawn out with `heft` and a boom tail, measured through the
phone model) is acceptable and parked; the voice section (`tools/soundforge/speech.py`, a Betty
and a VEGA) is too faint under noise, cracks and pops to judge; the console was derived again
that night from the UI design, Hold The Line and the direction notes, not from the existing
sounds (`tools/soundforge/console_sketches.py`, section 1 of the page, in its fourth cut, the war room
(`warroom_sketches.py`: low, slow, vocoded and broken up; a carrier, a vocoded grunt per maker, digital
breakup; piercing measured and held 10 dB under the body), with the FM terminal and its operations
channel (`console_sketches.py`) kept beside it for the comparison; the music under the sequences
4 dB down; the morning's fourth cut folded away at the page's foot); the voice is re-rendered judgeable (a smooth glottal pulse,
the vowels levelled over the bursts, the contact's level).
Content carries a `sound` label on a component (a word or a list meaning layers, validated in
`content_db.gd`; the Breaching Plow says blunt, the Gravity Knuckles blunt and plasma). A pick
lands as a recipe in `forge.py` with its hook (shape, maker, faction, silhouette, the label, the
replay telling shield hit from block from hit). The sketch script encodes AAC with `ffmpeg` at
256 kbps where there is no `afconvert` (its encoder smears a transient's front at 128). Next:
Ryan's listen of the fresh console (the verbs first, then the climax row); the Risen and Infernal
Horde boss themes from their seeds, melodies proposed in chat first. The speakers/headphones
setting is dropped (Ryan, 2 October): the one master balances for both for now.

**The phone (bible section 11 has four rows on it; README has the commands).** Ryan's Pixel
runs the debug APK at 60 fps with the fine map (the default, since the Compatibility renderer
has no anti-aliasing to give; MSAA measured leaking and is unreachable). Text is clean. The
marks are in three registers, green/violet/red, each carried by structure as well as hue,
because Ryan is colourblind: check a new colour by simulation (CLAUDE.md has the rule;
`RIFTGATE_HUD` renders against every HUD option). Still to judge on the device: the outline at
2.6, the intent field's stripe width and spoke count in motion (`STRIPE`, `SPOKES`), the
sound set, the grid at the hotter gain.

**Enemy targeting (2 October; bible section 5, the playtest set in section 9). Built the same
day, in the cloud, tests green.** Every foe picks its own target at round start by its `aim`
(exposed: weighted by the hull its blows would reach plus half of any shield they would break;
anything; heat; the armed; fires as one), drawn on the skirmish's die and shown as the arrows,
the pick a commitment; the lowest-shield rule stays as `Skirmish.targeting_override` for the
runner's comparison and nothing else. The counterplay is Lure (a keyword on any foe-targeted
entry; every foe the blows reach and leave alive turns on the spender, no chip, the arrow is
the record), Suppress (unchanged), Disrupt (the foe's other move, the next in its list that its
conditions allow, the new move picking its own target), Shield, Armour and a flat Brace. Taunt,
Beacon, Scramble, Confuse and Energy Armour are gone from the engine and the vocabulary; Phased
is parked. Foes carry armour (flat off every blow, never off a burn); a move may carry a `when`
(eight words, `Foe.WHENS`) and is not rolled when it fails; a special never fires twice running;
a blow may carry `swarm`, so much more per kin on the field. The nine foes are rewritten as the
bible row says: the ghoul's one move is the swarm claw, the bosses wear armour 10 and carry a
third move that opens below half (Bone Storm, Eruption, Unravel), the Pit Lord's blow breaches,
the Whisperer's Hush switches off the showing weapon (new effects `disable`, `heat_all`,
`corrupt_all`). The Proximity Klaxon is an indirect entry of no damage that lures with a
spread; the Lockdown Shutters keep their shield and passive and lose the draw. The hangar page
is republished with the content. Still to judge in play (the to-do): whether the exposed
weighting leans hard enough, whether the swarm's opening reads as pressure or a wall, whether a
disrupt into a boss's signature is a trick or a trap.

**5 October: the campaign and the economy decided** (a design session, Ryan and Claude, in a cloud session resumed from the VS Code one that died when the account switched; bible v0.34, sections 3 and 10 rewritten, the budget in section 2, the damage rows in section 7, the open list in 12). Five cities as five lives, each under its maker, gate integrity carried between battles and bleeding when a front is ignored; a city falls only by losing a battle there and costs its salvage, its maker's new blueprints and its rift staying open, never the player's kit. The capital's gate is the life bar in the Into the Breach shape: every fallen city drains it, zero loses the run mid-campaign, and the finale is fought on what is left; repairing it is the one priced repair. Track B: the finale is inevitable, faction finals are prizes. Difficulty by smarter foes and compositions, one lead faction and at most one guest until the last tier. The hangar: hull and cracked repair free, a destroyed hardpoint component gone, a destroyed fixed one rebuilt, wrecks back after one battle in the shop, refit instant, resources only on builds, modules and the capital's gate. Components flat, never modified; a chassis carries module slots with rule text in four archetypes (stats and text traded), the hard cap retired for a budget of about three texts a machine, the Clydesdale the sandbox that overruns it; passives never swapped. Offers over trees, the host maker's catalogue after a won battle, the Arsenal's trickle at the capital. Between campaigns the pool, the codex, tiers and the makers' favour (decided: one rare piece in the maker's voice from a maker whose own measure the player topped, one offer taken; the measures recommended, relative per maker, the Arsenal's absolute), never power; livery decided as the cheap carrot (colours unlocked by a maker's favour, free on any machine; later, after the hangar); the makers' voice rule loosened to "no in-your-face advertising" from "maintenance-manual voice"; carrying a machine refused as Into the Breach's gimmick. Twelve battles the working length. Nothing built: the to-do has the save's campaign state, the mission map and the hangar screens, and the runner's destroyed count, which the destroyed-is-gone rule depends on: its first reading (greedy, 20 seeds, the cost-of-a-win table) is nearly zero per won fight, the team losing none and a single machine losing one only against a boss, so the rule is safe from the spiral and may be too gentle; a per-battle count waits on a runner that plays whole battles. The word: the campaign is the run.

**Open, in order.** The task list is `docs/todo.md`, one line a task, grouped by who moves
it and ticked in the commit that lands it; this is the order to take them in.

1. The Puffin's Slipstream and Overshield read in play (built 5 October; the hovercraft models are called good; the runner's Kestrel team row carries it since that evening, the Balance paragraph); named 6 October: the passive is the Slipstream Projector, the fixed shield the Backwash Ionizer, and the Puffin moves 40.
2. Ryan's play test of the engagement zones and the three behaviours (the radii, the brute's hunt, how big fights come out), and his phone reads.
3. Ryan's text for the new machines and components; the machines' scale on the map; the strikes, the hover idle's pitch, the idle acts (`RIFTGATE_ACTS_DEBUG=1`) and the gaits (`RIFTGATE_MOVE_DEBUG=1`, and a real move for the Dingo's drift, the Stingray's helicopter strafe and the banks), judged running; the movement branch merged on his word.
4. The discuss-first decisions left in the Ryan section (the campaign and the economy are decided, 5 October, the paragraph above; what remains of them is the makers' measures and notices, and the in-battle ones: ally wrecks, terrain, base defences, reinforcements, the multi-hex boss, Rift Pressure in the boss fight, packs keeping hull between fights); enemy targeting decided and built 2 October (the paragraph above; the runner's read is the baseline question); the commander layer once the balance has a baseline.
5. Ready to build: the pacing pieces after Ryan's session; the movement's small finds (the frozen packs' missing mark, the road's first slab); the machine weld and the prop fade; the 3D at 30 last, once the animations exist to judge it against. The engine gaps waiting on design (Phased parked, Corrode, foe roles), and a dedicated hunter foe and spawned formations once proposed.
6. Audio: a full play of Hold The Line, the console's fresh pass and the effects' picks, the two boss themes.
7. A prototype hangar in the game (paints and loadouts, no economy), now with a design to grow into (the hangar and the mission map in the to-do's screens section, the campaign state in the engine's). Art: enemy art through foeforge, the hangar as a model. Before a phone leaves the desk: onboarding, then tuning.
