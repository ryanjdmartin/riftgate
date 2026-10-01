# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF (account A, the home
for every page; the pages block below has the rest; v0.12). Republish it from the committed file after
a bible change, passing the URL from any conversation that did not publish it.

**The pages, as of 29 September, night.** An artifact is republished only by the account that
made it, or by an account invited as Editor from its Share menu; the personal account (A) can
invite outward, the organisation account (B) cannot. **Account A owns six pages and nothing
else:** the Melody Desk (https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV, 30 September:
a piano roll of up to sixteen bars on a plain piano, source
`tools/soundforge/melody_desk.html`; notes drag to move and stretch, tap to select, a
selection drags together; the shipped tracks' parts stack as layers over what is there
(store collection `parts`, one document per track, seeded from
`tools/soundforge/desk_parts.py`, which captures each builder's `groove` call; re-seed
after a track's parts change), each layer with its source, a mute and a fill of its own;
Play runs from a start marker tapped on the ruler; Send writes to collection `melodies`
with every note, each layer's source and forge lanes, and Ryan's memo. A session pulls a
`new` document, listens, applies it in the forge and marks it `applied` with a `reply`
the page shows. Ryan's intent: the session interprets what he sends; it is not drop-in), the bible (https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, v0.12), the nameplate
(https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH), the hangar codex
(https://claude.ai/artifact/FqiH3b8ZZjxJaCJmWK71vj), the Model Viewer
(https://claude.ai/artifact/HzF8K98MxgJP7kroxAuDMv, every chassis rendered as it stands with
earlier passes folded under each, and a Classes section for the silhouette classes and four
refits; the third pass of 30 September is current) and the listening page
(https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9; since 30 September, evening, the effects'
second pass from `tools/soundforge/fx_sketches.py`, every music round's file removed from it;
the music rounds re-render from `phone_sketches.py` if ever wanted again). Every duplicate and superseded page in A
was deleted on Ryan's word this evening (the first bible link, the Second Passes page, the HUD
swatches, a second codex, a second sketches page). **Sharing:** the nameplate, codex and
sketches are shared to the work email as Editor and open there, so B republishes those three
in place and its own copies retire. Account A merged B's 42 component rows into its nameplate on
29 September (90 rows now; A's Drill and Gelada wording kept as newer) and deleted the export.
**Account B keeps two pages** (Ryan's correction, 29 September, late): its bible copy (above;
republished from the committed file after any bible change a B session makes) and a Model Viewer
of its own (a B session records its link here). **The content editor page no longer exists** in
either account: B's copy (HnE3gvsxNHXyjRhRyEiDqT) is gone, its `edits` database was empty when B
last read it and its baselines matched the shipped content, so nothing was lost. Its page source is
`tools/content_editor.html` (the README says how it is published, with a `files` map carrying
`content/*.json`); when Ryan wants to edit from his phone again, publish it from account A and
share it to the work email as Editor, so an A session can pull the edits (a B session cannot use
an A page's database from Claude Code, though Ryan can from the page). Every other B page was
deleted 29 September, night, on Ryan's word: the phone sketches, both renders pages, the codex, the
Baboon review and, once A had merged its rows, the nameplate copy. **Rules learned today:** a page's link goes into this file in the same commit as
the publish, so a parallel session sees it before publishing a twin; `Artifact` with `action:
"list"` says what the account you are in owns, and a read of another account's page comes back
"not found"; a page shared as Editor across accounts republishes, but its database stays with
the owning account.

**Cold start, including from another account.** Nothing needed to work here lives outside
the repo. Read this file, then `docs/todo.md` (the task list), then `CLAUDE.md` (the rules,
the commands, and how Ryan works: he pressure-tests, judges effects running, leans hotter
on a phone, and retires old directions as he goes). `README.md` has the layout and every
command with its screenshot poses and phone-layout variables. The bible's sections hold the
why; section 11 carries the phone rows (the two paths, the reference glass, the readout's strip, the second phone pass), section 12 the roadmap. Ryan may be running
another session on this repo at the same time: `git status` first, stage by path, diff a
shared file before staging it, and never `git add -A`. If a chat and the bible disagree,
the chat is newer.

## As of 30 September 2026

**State.** Tests green: `perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s
tests/run_tests.gd` (279 tests, 3,593 checks on 1 October, after the merge of the cloud branch). Two or three sessions run on this repo at once:
check `git status` before committing, stage by path, diff a shared file first (a path
still sweeps the other session's hunks), never `git add -A`, never kill a bare
`godot --path .`. Commit after each verified chunk with tests green.

**The cloud session's branch is merged (1 October).** Branch `ccr-23c2f18f-qlilnd` carried the
engine list (the planned pieces, the ten foe actions, every trigger, save and resume); it merged
main through the fourth round itself, and main merged it at ee87e17 with tests green (279 tests,
3,593 checks) and pushed. Main and origin match. The branch is left on origin until Ryan says to
delete it; nothing else claims the engine list now, so the engine section of the to-do is open.

**The fist's other faces (1 October).** Ryan gave the Nemesis's front fist tile turned the
way he reads it (thumb side up, back of the hand right) and asked for the top, left and bottom.
`bl_low.Tiles` draws `fisttop` (thumb over the top, index finger side on), `fistpalm`
(the thumb forward along the top and bent down beside the front, the fingertips behind it, the heel) and `fistbase` (the little finger across the
front curling in, the thumb's tip at the palm edge, the palm) folded out from the front as a net, every groove, ridge, knuckle light and edge meeting
across the shared edges; the `fist` tile is now stored in that frame too, and the `thumb` tile is
retired. `models_low._fist` places each tile by the hand's own axes (forward, back of hand,
thumb), so the edges meet on both hands and the right hand wears the mirror; the back of the
hand and the wrist stay plate. Both the Nemesis and the Baboon use it. Not rebuilt yet: no
Blender in the cloud, so `forge.py build nemesis baboon` on the Mac.

**Where things are.** `sim/` is the headless game (battle map, battlefield resolver, battle
loop, skirmish, effects pipeline, content DB). `game/battle/` the battle screen and the map
(`battle_map_view.gd` overlays and gestures, `map_3d.gd` the scene, `painted_map.gd` the
other world, `bleed.gd` + `bleed.gdshader` the compositor). `game/skirmish/` the fight.
`game/ui/` the HUD kit, codex, pause menu, `mech_view_3d.gd`, `trace_lines.gd`, the feed
effects (`feed_fx.gd`, `tear_layer.gd`; `RIFTGATE_FEED_DEBUG=1` fires them constantly).
`game/audio/sound.gd` plays every sound by name; `tools/soundforge/forge.py` builds them
into `art/audio/`. `tools/lowforge/` builds every model by code (`models_low.py`, one
function per chassis id); `tools/screenshot.gd` poses either screen (README lists the
poses and the phone-layout variables); `tools/balance.gd` writes `docs/balance.md`;
`tools/android.sh` the debug APK, `tools/phone.sh` a Web build on the LAN.
`docs/vocabulary.md` is generated from content (`tools/export_vocabulary.gd`).

**Content (bible section 7).** Chassis ids: `badger` (its fourth stock entry the Proximity
Klaxon since 30 September: tanks protect their team; an intercept component is the other
candidate, unwritten), `clydesdale` (d9; the die cap is 10), `sparrowhawk`, `baboon` (the
Mandrill, renamed 28 September; d7 since 30 September, the Halo Shield dropped; its passive
Pocket Paradox runs on the new `on_foe_status` trigger, `Effects.foe_status_suppress_chance`;
Aphelion stock is `umbra_projector`, `pulse_repeater`, `zenith_emitter`, `radiator_sail`, with
`halo_shield` and `corona_shield` unlocks), and the 28 September drafts `armadillo` (its locked
component the `lockdown_shutters` since 30 September: a taunt whose Sealed Live passive extends
Faraday Hull to the shield; the Faraday Shutters are gone), `wild_boar` (five hardpoints, a
second Slug Cannon), `prairie_dog`, `dingo`, `goshawk`, `nemesis`, `ammit` (the last two the
Arsenal's; maker `arsenal` exists). Their shapes are decided (the chassis pass
row): every new passive and most locked components carry `"status": "planned"` until the
engine has volatile, devour, Shocked, Overcharged, taunt, overwhelm, the stealth join
rule, the vent-on-fire face, the die-local reroll and heat-scaled shield regen. Numbers
**Every 28 September passive and locked
component runs since 30 September** (the cloud session, branch `ccr-23c2f18f-qlilnd`,
one commit each, the bible's section 7 row "The 28 September pieces, built" has the
reasoning and the runner's first readings): volatile (`Face.ANY_KEYWORDS`, on any kind),
devour (a stack of Overcharged per kill, fading a round at a time), Shocked and Retaliate
(`shock_on_hull_strike`, `shock_on_block`, `SHOCK_DISCHARGE`), taunt and beacon
(`draw_rank`, support keywords and buff statuses), overwhelm with `grant_keyword` and the
effective face (`Effects.effective_face`: what the resolver spends, the bot weighs, the
codex lists and the die draws), the vent-on-fire face (`vents_all`, `power_per_heat`),
`on_round_start` (`shield_per_heat`), `ally_present` with `roll_max` (units carry
`allies`), `free_reroll` (`MechState.free_rerolls`, `Skirmish.can_reroll`),
`on_hull_damage` with `stack_status` and `per_stack`, `add_armour_vs_rank`,
`keep_status`, `screen_withdraw`, and the stealth join rule (`PhaseResult.blockers`).
Nothing in content is planned any more: the ten foe actions run too (30 September; `Foe.ACTION_EFFECTS`, a foe's special replaces its blow that turn, weights 3:1 attack to special as placeholders, bible section 9 row). Every trigger the vocabulary names runs (`Effects.fire`); only Phased, Energy Armour, Corrode, Scramble, Confuse and the tank trait remain planned, all waiting on design. **Save and resume** (30 September): `sim/save.gd` writes the whole battle (map seed, units, dice, damage, modifiers, routes, contacts, the skirmish with its dice, foes and both random streams) to `user://battle.json` after every change when the harness started the battle; Resume battle in the harness opens it where it stood, straight into a fight that was on; a decided battle clears it; standalone runs and tests never write it (bible section 11 row).
Readings for Ryan from the runner: the Faraday Hull alone makes the Armadillo win every
solo cell at both rungs; the Crucible costs the Nemesis under the bot (its Overheating
burns hull); the Tap lifts the Ammit's ghoul cell to a greedy win; overwhelm and the
Databank never fire in the runner's single-type, single-machine cells. Numbers
are in tens and are placeholders; every stat is read through `sim/effects.gd`. An enemy
unit is a **pack** everywhere. Ryan writes `content/*.json` in his own voice (he writes
die totals in his head; the data keeps free slots), until 29 September from his phone through
the content editor page, which no longer exists (source `tools/content_editor.html`; the pages
block says how to bring it back). When it exists: pull collection `edits` with ArtifactData,
apply by hand (the files are hand-formatted), test, commit, republish the page with its `files`
map, clear the documents. The memory note has the
quirks. Tests never hardcode an entry's passive name.

**Reserved names (28 September).** `content/reserved_names.json` holds about 1,250
machine names (BattleTech, Heavy Gear, 40k, Halo); `ContentDB._validate_name_clash`
refuses an exact match unless `design.name_clash` says why it stays. Ryan's verdicts (28
September) are in the notes: `sparrowhawk` kept (a coincidence: a Halo Wars gunship and a
BattleTech fighter, both obscure; the name conjures the bird), `goshawk` and `baboon` kept
(designation-tier: the Vapor Eagle's Inner Sphere name, the Howler's Clan name), `badger`'s
id kept (Honey Badger is clear); `dingo` kept too (29 September: an obscure Heavy Gear gear with
no silhouette resemblance, the real ATF Dingo the closer match). Every flagged name is decided. The tiers: iconic (the name conjures their machine: never), known (a hobbyist
recognises it: case by case), coincidence (keep). Names and concepts are spitballed on the
Riftgate Nameplate artifact
https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH (account A, shared to B as Editor; a tab per maker, Components, Rules;
rows in its db collection `candidates`; rebake the page from the reserved list and the
content names when either changes). Ryan's brainstorm of component names is on its
Components tab, trimmed, with the used ones marked landed.

**Models (29 September).** Every chassis has a lowforge model. The seven 28 September
machines were built from their fantasies and then rebuilt once on Ryan's notes;
`tools/lowforge/models_low.py` holds one function per chassis id and every number in it is a
proportion, so a note moves it and `forge.py build <id>` plus one `--import` is the whole
loop. Fixed components are modelled into the machine with no pin and every hardpoint carries its
`hp_<n>` pin, one per hardpoint, every pin a gun mount pointing forward-ish (the rule, 30
September, below). Every pin parents its stock part (`with b.socket(...)` in `models_low.py`) and
carries the frame and scale a mounted part wears (a Sparrowhawk's pins are half size); a mount
with no stock gun is a bare pad (`b.pad()`). **The third pass (30 September, all on Ryan's notes
from the viewer):** the Baboon's fists on the ground again and armed (two mounts a hand, d7, the
Halo Shield dropped, knee pads on the knees); the Armadillo longer than wide with a small nestled
head, recessed rear ports, two sealed forward ports, the hatch pitched forward, its locked
component the Lockdown Shutters; the Wild Boar to five hardpoints on a larger turret (two parallel
guns, a rack on top, rear-quarter mounts); the Prairie Dog's mast lower and centred, visor flush,
turret on a neck; the Dingo's rail into the drum, a tail vent, mirrored coolant tanks, longer
glass; the Goshawk's cannon recessed as a wide oval blended into the belly; the Nemesis with forward
spiked fists, a hip cannon, chest ports, traps, a vent-striped core; the Ammit with throat ports
and its spines down the spine; red glass on every Arsenal machine. **The fourth round (30
September, same day):** the Badger's arms clear of the body (wider cuffs, hinges, pauldrons); the
Armadillo's first-pass cowl back over a smaller bay, its ports hollows with the mount at the floor
(`_tube` in `models_low.py`), forward ports level, tail band fuller; the Boar's turret guns apart
with the missile pod on a rear quarter; the Prairie Dog's back broken up; the Goshawk's fifth mount
a stub under the fairing, its barrel glowing; the Nemesis's fists upright, traps meeting the helm,
the cannon on the waist, ports up, the core vented over a glow; the Ammit's back panel flat on the
back with the cannons along it and the spines rooted. **Joints (1 October):** `with b.joint(...)`
in `models_low.py` hangs a limb under a `joint_<name>` Empty by code; the Badger's booms, the
Baboon's, Nemesis's and Ammit's upper arms and the Clydesdale's lance have them, the view's strike
and idle read them (a mount under a joint recoils with its arm), vehicles and aircraft have none.
Ryan judges the strike and the idle running in the skirmish. **The fifth round (1 October):** the
Armadillo's ports cut through the shell with a boolean (`b.cut` in `bl_low.py`, applied before export;
a `_tube` lines the hole), its forward ports cut into the front band's crown flanking the cowl (the
fourth round's were buried inside the band), its bay out to the lip; the Badger's arms in a little;
the Boar's pod out of the turret's sweep; the Prairie Dog's turret lower; the Goshawk's barrel mouth
open with the glow inside; the Nemesis's core a plain fire (a `glow` tile) and its condenser up on
the back; the Ammit's panel and cannons narrower, lit slots on its tail block. **The sixth round (1
October):** a `lit` tile for slots that must light whole; the Ammit's panel ending below the back's
crown; the Boar's plow ahead of the treads and rooted in the hull, its turret up on a base clear of
the skirts and decks; the Prairie Dog's turret squat with a class gun either side (the fixed repeater
left, the autoguns right), nothing hand-modelled; the Goshawk's barrel lit in rings, then (the seventh round) plain again
with the glow in the mouth itself; the Prairie Dog's drum smaller with the guns on its flanks; the
Boar's decks back to the tail under the pod and its plow taller and wider over the treads; the
eighth round: the Goshawk's muzzle open for real (`_rings` capped the rim's annulus with a disc
since the fifth round; it takes `cap=False` now), rings and lit ports on the barrel; the Armadillo's
ports deeper, its forward ports level in the step behind the front band, its hatch up and back; the
Boar's plow raked and barely ahead of the treads with its bars meeting it and its tusks out of its
face; the ninth round: the port rims floorless (`_tube(..., floor=False)`; the floor had been a lid
over every port), the Boar's plow wider with a crest behind the spikes, the Prairie Dog's guns sunk
into the drum's flanks, the Goshawk's cannon vented with cut pockets (`b.cut_box`) and a glowing
groove, and **turret joints** (`joint_turret`, `_l`/`_r`) on the Boar, the Prairie Dog, the Clydesdale
and the Badger, which the view traverses about their up axis (`MechView3D.joint_axis`); the tenth
round: the Armadillo's insets halfway back up, the Badger's shoulders symmetrical gimbals (the deck
box keeps no joint), the Clydesdale's mortar and howitzer out and gimballed with its bare mounts on
the head's cheeks and behind the head, the Boar's crest leaning back, the Goshawk's vents deeper with
a strip of glow at the floor, the Prairie Dog's launcher the class rack; the eleventh round: the
Armadillo's rear barrels a fixed length from the mount, the Badger's mounts on the gimbals, the
Clydesdale's turrets, mortar and howitzer on pedestals clear of the lance, the Boar's tusks grown,
the Goshawk's glows filling their cuts; the twelfth: the Armadillo's rear ports shallow sockets, the
Clydesdale's turrets back down (they turn outward only) with the mortar and howitzer on the deck, the
Boar's tusks apart; the thirteenth: the Armadillo's collars seated in the shell, the Clydesdale's
turrets lower and forward with the mortar and howitzer mounts at one height. The fourteenth: firing channels
through the Armadillo's front band ahead of its forward ports. The Prairie Dog, the Badger, the
Goshawk, the Boar and the Clydesdale are done (Ryan). Ryan asked
whether hand edits in Blender can be taken: yes through `forge.py export <id>`, but the models are
built from code and any rebuild overwrites the working file, so a hand edit has to be re-expressed in
`models_low.py` to survive; the way that works is a note or a picture, as the Boar's clip was. `tools/hero_shot.gd` renders bare now
(`RIFTGATE_OUTLINE_KEEP=1` keeps the display's edge), and the viewer shows every machine bare. Ryan
judges the round on the viewer. What the second pass changed, so nobody redoes
it: the **Armadillo** stands on long legs whose hips come out of the shell's flanks (it read
as a beetle that would catch on rocks) and shows only its weapons' muzzles out of round ports
in the shell, Blastoise-fashion, with a small snout of a head to sell its size, since it is
meant to be the biggest land machine in the game; the **Wild Boar** is an H-tank so the
treads carry the silhouette, with a spiked cowcatcher in a V and a double-barrelled turret
(it read as a bulldozer); the **Prairie Dog** and **Dingo** had to separate, and vehicles
never have open cockpits (Ryan, 29 September), so the Prairie Dog is a closed armoured buggy
with arched wheels and a rotating roof turret and the Dingo a low flat wedge whose wheels
ride out on cambered swing arms with lit hubs; the **Goshawk** lost its tail structure (the
boosters are shoulder nacelles, each carrying a canted fin), gained span, lost length, and
its cannon is a wide short bore tucked under the nose in a belly fairing that reads as
drawing heat off the chassis; the **Nemesis** was rebuilt from nothing after Ryan called the
first pass "a reskinned baboon without a head", and is now an almost-human brute in demonic
armour, hard-lined, asymmetric, hooded helm with horns, a round lit core, the Apex homage he
asked for; the **Ammit** was right first time and needed only its spines laid flat, its upper
arms raised and pointed forward, its eyes turned into long cockpit-glass strips down the
snout, shoulder cannons in place of arm guns, and its heel spurs and throat vent actually
attached. Facets: 676 to 928 each, the Nemesis 816, the Ammit 1,316, beside the Baboon's 1,396 and
the Clydesdale's 1,016; the register's 900 is a first-pass guideline, not a rule (Ryan, 29
September), so no facet count is an open question.
Renders, with earlier passes folded under each chassis: the Model Viewer
https://claude.ai/artifact/HzF8K98MxgJP7kroxAuDMv (account A; B's two renders pages are deleted).
**Ryan judges a model only from a render**, never from code: `tools/hero_shot.gd` takes a
chassis, a maker, an out file and `front`, `rear` or a yaw, and needs a window, so it cannot
run headless.

**The mount rule and the silhouette classes (decided 29 September, the rule settled 30 September;
the bible row in section 7 has the reasoning).** Hardpoints are gun mounts on the model. A
component with a `shape` takes the next mount in the die's order, in its own maker's metal; a
component with shape `none` (armour panels, vents) takes a die entry and no mount, since it is
applied to the whole machine. Equipment that can look like a gun keeps a shape: shield projectors
and the Overcharge Coil are a `dish`. Five classes: barrel, twin barrel, rack, blade (katar-style,
every one punches forward; wing blades on the flyers are wanted) and dish; slab and vent block are
detail helpers. `models_low.SHAPES` builds them, `forge.py shapes` writes every maker's metal into
`art/models/shapes/`, `ContentDB.SHAPES` validates (a weapon always has a shape, a vent never), and a
test refuses a class without a model in every metal. `MechView3D.mount_plan()` counts mounts over
the shaped entries of the die and of the stock loadout and names only the mounts that differ;
`plan_for(unit, db)` is passed by the skirmish, the codex and the map portrait; a borrowed fallback
model never wears another machine's kit. Every machine wears its stock today, so nothing on screen
changed. `RIFTGATE_FIT="1:lance,4:blazethrower"` on `tools/hero_shot.gd` renders a swap (unshaped
equipment in the spec is skipped); the Model Viewer's Classes section shows four refits and four
classes. The codex page names no socket per entry (Ryan: the order is internal, the hangar will be
visual); it checks the mount count once per die and shows each component's class as a dashed chip.

**The hangar codex page (29 September).** Ryan asked for one surface showing a chassis and
the components fitted to it instead of jumping between files. `tools/build_codex.py` reads
`content/*.json` and writes a page: each chassis with its designation plate, maker,
silhouette, traits, a stat grid, its passive, and its die laid out entry by entry, fixed
first and then each hardpoint tagged with the model pin it mounts on, read from the built
`.glb` so a hardpoint the model has no socket for is flagged rather than assumed (none is, since
the pins pass), every entry showing its silhouette class (a dashed chip), its
component's numbers, keywords (hover for the vocabulary rule), maker and own passive, with
planned entries marked. Republished 29 September, night, with the classes and the pins. Run `python3 tools/build_codex.py . <out.html>` and publish the
result; regenerate after any content change. Account B's copy is
account A's at https://claude.ai/artifact/FqiH3b8ZZjxJaCJmWK71vj. It is generated and read-only
on purpose: the content editor is Ryan's writing surface when it exists, and two pages that both
write content would fight.

**What the game does today.** A battle: the map shows every pack's intent and the exact
result of the plan before Resolve; a grounded machine controls the ground beside it, a
pack stepping into it stops and that is a contact; every grounded machine within
`Battlefield.ENGAGE_RANGE` (2) joins, and a tether runs from each machine to the pack it
will fight (28 September). Ryan's 29 September play: the joins chain across the map and
nothing shows who joins until a contact exists; the rule is to be replaced, proposal in
the bible's section 5 (a pack's capture zone), decision his, in a session of its own. Resolve plays the
moves, a CONTACT band, a panel of contacts; ENGAGE cuts to the skirmish, the dice fight on
the enemy's ground, four columns, every blow heard, the enemy's turn replayed blow by
blow; Back applies it. The boss's contact takes the phase: no panel, a reveal, the family's
theme (only The Chorus has one). MENU pauses, holds the settings and names the track. The
codex opens by double-tap on either screen and shows the machine's base state plus battle
rewards, its passives one row each coloured by source (the chassis's own in the accent, a
component's in the overlay colour, a reward in ink; 29 September, night); the fight's effects
live on the chips and the hold. Under the map, the orders
board (`game/battle/orders_board.gd`) carries every machine's gauges, its order and what
it will meet while nothing is held; a held readout takes the same strip; the log is off
the screen behind the board's LOG button.

**The Baboon (26 to 29 September; the bible's Aphelion row has the reasoning).** Aphelion's
first machine, from Ryan's stub; the Mandrill until the reserved-names pass found
BattleTech's. Passive **Pocket Paradox**, from Ryan's codex about a researcher who knocked
out his past self: a foe gaining any status, from anyone, has a 20% chance of being
Suppressed too, plus 10% per 10 shield the Baboon is missing. `on_foe_status` fires from
`Skirmish._foe_gained_status` (never on suppressed or numbed, or it feeds itself),
`Effects.foe_status_suppress_chance` reads it through the pipeline, and the roll goes
through `_suppress`, so Numbed and `stun_resist` still apply; the live percentage is a hold
row and the log says "<foe> got trapped in a paradox!". The fixed backpack pods carry
`solar_flare_array` so the passive has a status source in stock kit, which is the loadout
row's rule. Its loadout is ordered as the model's pins are. **Open:** Ryan judges the rear
silhouette now the fists hang at knee height (they sat on the ground, which read as two
boxes set down); if it still reads wrong, his two options are heavier hands carrying
hardware or a standard forward pose with the fist tile turned 90 degrees. Its flavour and
the seven Aphelion components' text are his. The passive's numbers are unplayed, and the
greedy bot does not value a status for the stun it may cause, so its balance row
understates it.

**Buff equipment (29 September; bible section 7 row).** A third equipment kind, `buff`:
spent on a machine it grants one of `Effects.MECH_STATUSES` (`overcharged` +10% damage a
stack, `braced` 15% less taken a stack, `primed` a Burning stack on every blow; names are
placeholders) for `stacks` and `rounds` (`Face.buff`, `Effects.grant_buff`, ROUNDS scope).
The validator holds a buff to a machine status. The old `overcharge` keyword is gone from
the vocabulary; Overcharged is the status, and devour will stack the same one. One draft
component, `overcharge_coil` (Kestrel), fitted to nothing. The bot weighs a buff
(`Policy.buff_score`) and values a burn for the stun a loop passive may cause
(`_loop_chance`), so the Baboon's row is honest now.

**Balance (bible section 11).** `sim/policy.gd` plays the skirmish headless (RANDOM,
GREEDY, `withdraw_below`); `tools/balance.gd` runs the matrix, about two minutes with
eleven machines. Last read (28 September, after the Baboon, Pocket Paradox and the
drafts' stock; their passives are still planned, so their rows are kits alone): the
Badger, Wild Boar, Nemesis and Armadillo each win nearly every cell alone at little cost,
the runner's flag for too strong out of the box; the Clydesdale's d9 lifted it (beats
ghouls, holds the Colossus); the Baboon beats the back-rank packs and the Colossus and
loses to the Pit Lord half the time under greedy, the bosses' stun resistance biting the
one machine built on suppress; the Dingo and Prairie Dog lose to nearly everything alone,
as support cars might, but their hull is worth a look; the Sparrowhawk and Goshawk hold;
the team of three still wins every single-pack fight at no cost, so the rank and file's
numbers are the lever. Numbed decays now and bosses carry 30 stun resistance. Rerun after
each engine piece lands; read bands, not numbers.

**Audio (the bible's section 1 sound row has every listen and decision).** Everything is
`tools/soundforge/forge.py` writing WAVs into `art/audio/` (`build`, `measure`,
`sections`, `audition`, `sketch`); Ryan gives notes by section letter or timestamp. Six
titled tracks in `Sound.TRACKS`, all locked or "pretty great"; the map's set cycles, the
skirmish's picks, the boss theme per family (`SETS["boss_<faction>"]`, `LOOP_FROM`). The
phone pass (26 to 28 September, from the sketches page
https://claude.ai/artifact/FCaphxM3Y3SnRPdNnprpXc, rendered by
`tools/soundforge/phone_sketches.py`) is in the forge and all six tracks are rebuilt on
it: one master for both palettes (tilt 1.5 plus a presence lift at 1 to 2 kHz), the driven
bass without its hard clip (asymmetric stages, the drive following the note, a bass
cabinet: Hold The Line and Full Bore), the backing guitar without its clip at the old
level (the three human tracks), a metal kick and a tightened tom (the human tracks), a
softer crash, the soft sub's speaker shadow, and the rift tracks a quarter of their
phone gap louder (The Far Bank -20.2, The Crossing -19.2; Low Ground unchanged). Still
to judge: the kick's size alone and the toms in headphones (Ryan's last drum notes).
The Far Bank runs at 88 (judged in the game, 29 September) and the rift levels are at the
half gap (-17.9, The Crossing -17.7). Hold The Line shipped its 29 and 30 September pass on 30 September, every note in: 104, the wrap
to bar nine, the master with headroom (the human tracks had run into the saturator; the
climax's crackle was that), the kit rebalanced (kick up, snare and crashes down and softer,
the toms hard with their body kept, at 130 and 98 Hz), the seven twelve bars with the held
guitar a whole bar each on E, D, D flat, C twice, the bridge on Ryan's seventh Melody Desk
melody (1 October: the tune's last four bars rewritten over the sixth's one harmony line and his sub root line; the desk's parts re-seeded), the drum
solo a fresh pass with four cymbal kinds in turn and a closing snare run climbing from full,
the climax at one loudness and thinned (no piano, no second chug, the drone throughout, the
chimes from the second set's fifth bar, the riff's synth in the keys' register from the third
set, the double kick the last four bars). Nothing of his is pending on it but a full play in
the game. The track levels stay as they are until Ryan says otherwise. Next: a
speakers/headphones setting (offsets per track and a bus EQ on the speaker profile); the
Risen and Infernal Horde boss themes from their seeds, melodies proposed in chat first. The
real recordings question is closed (29 September): the forge is the instrument.

**The effects' second pass** (30 September, evening; Ryan's ask: a new set that suits the
game better, from the UI, the lore, the music and both sides' unit design; the bible's sound
row has the design). `tools/soundforge/fx_sketches.py` renders every effect again beside the
shipped one at the shipped level into `tools/soundforge/out/fx/`, plus four rounds in
context over the tracks (a skirmish round, the map's handover, the three families, the
iron), and copies `fx_page.html` in as `index.html`; the listening page now holds that and
nothing else. Sections: the console (one key grammar, E-tuned replies, the die as a
mechanism, an intent tick), the iron (blows by weapon shape with plasma for the Arsenal,
hit/block/kill by the struck maker's metal, footfalls by silhouette), the rift (a blow, a
heavy blow and an arrival per family, a boss reveal), the red (contact, dive, gate, victory,
defeat). Nothing is shipped; a pick lands as a recipe in `forge.py` and, where the page says,
a small hook (shape, maker, faction, silhouette) in `skirmish_screen.gd`, `battle_screen.gd`
and `sound.gd`. Next: Ryan's notes by section and row.

**How the listening page worked for the music** (the phone sketches, account A's page, 29
September; the page block above owns the account rule). Ryan judges the music on his phone,
not from the repo, so a change is heard as an A/B before it lands.
`tools/soundforge/phone_sketches.py` renders one change at a time from Hold The Line's own
bars into `tools/soundforge/out/phone/`: a WAV and an AAC copy in an `.mp4` container,
which is the audio an artifact will serve (`afconvert`, macOS; `.m4a` is refused). It also
copies `tools/soundforge/phone_page.html`, the committed listening page, in beside them as
`index.html`. Publish that folder: `root` set to it, the `.mp4` files and `manifest.json`
in `files`; the page reads each file's phone-speaker loudness and the level gap from the
manifest. Every file in a set is the same bars from the same seed, so the player keeps its
position when switching rows and the comparison is real. `out/phone/` is git-ignored
scratch: render the sets you need (`voices`, `balance`, `levels`, `voices2`, `guitar`,
`shadows2`, `rift`, `round3`, `round4`), then publish. Ryan's notes come by set and row
number, speaker first and headphones second. Two are open, in `docs/todo.md`: the kick's
size and the toms in headphones, whose answer files are round four's "Now" set
(`mix_ship`, `drums_kick`, `drums_tom`, the drums bare in three marked steps each). A
sketch never overwrites a shipped track: a pick lands in `forge.py`, then `build` and one
`--import`.

**The phone (26 to 29 September; README has the commands; the bible's section 11 has
three rows on it).** Ryan's Pixel runs the debug APK at 60 fps with the fine map (the
default: the map and the machines' views at the glass's density, since the Compatibility
renderer has no anti-aliasing to give; MSAA measured leaking 170 MB every twenty seconds
and is unreachable). Text is clean. The marks are in three registers, green/violet/red,
each carried by structure as well as hue, because Ryan is colourblind: check a new colour
by simulation (CLAUDE.md has the rule; `RIFTGATE_HUD` renders against every HUD option).
Still to judge on the device: the outline at 2.6, the intent field's stripe width and spoke
count in motion (`STRIPE`, `SPOKES`), the sound set, the grid at the hotter gain.

**Open, in order.** The task list is `docs/todo.md`, one line a task, grouped by who
moves it and ticked in the commit that lands it; this is the order to take them in.

1. The engagement rule, in a session of its own: `docs/engagement-rules.md` has the discussion; and Ryan's phone reads.
2. The planned engine pieces, in whichever order he wants to play first.
3. Ryan's text for the new machines and components, and the flagged names.
4. The discuss-first decisions in the Ryan section, the economy last.
5. Art: Ryan's notes on the seven first-pass models, enemy art, the hangar.
6. Before a phone leaves the desk: save and resume, onboarding, then tuning.
