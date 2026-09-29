# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF (account A, the home
for every page; the pages block below has the rest). Republish it from the committed file after
a bible change, passing the URL from any conversation that did not publish it.

**The pages, as of 29 September, night.** An artifact is republished only by the account that
made it, or by an account invited as Editor from its Share menu; the personal account (A) can
invite outward, the organisation account (B) cannot. **Account A owns five pages and nothing
else:** the bible (https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF, v0.10), the nameplate
(https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH), the hangar codex
(https://claude.ai/artifact/FqiH3b8ZZjxJaCJmWK71vj), the Model Viewer
(https://claude.ai/artifact/HzF8K98MxgJP7kroxAuDMv, every chassis rendered as it stands with
earlier passes folded under each) and the phone sketches
(https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9). Every duplicate and superseded page in A
was deleted on Ryan's word this evening (the first bible link, the Second Passes page, the HUD
swatches, a second codex, a second sketches page). **Sharing:** the nameplate, codex and
sketches are shared to the work email as Editor and open there, so B republishes those three
in place and its own copies retire. Account A merged B's 42 component rows into its nameplate on
29 September (90 rows now; A's Drill and Gelada wording kept as newer) and deleted the export.
**Account B keeps two pages on purpose:** its bible copy (above; republished from the committed
file after any bible change a B session makes) and the content editor
(https://claude.ai/artifact/HnE3gvsxNHXyjRhRyEiDqT; Ryan's saved edits live in its database, its
page source is `tools/content_editor.html`, the README says how it is published). Every other B
page was deleted 29 September, night, on Ryan's word: the phone sketches, both renders pages, the
codex, the Baboon review and, once A had merged its rows, the nameplate copy. **Rules learned today:** a page's link goes into this file in the same commit as
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

## As of 29 September 2026 (evening)

**State.** Tests green: `perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s
tests/run_tests.gd` (about 220 tests). Two or three sessions run on this repo at once:
check `git status` before committing, stage by path, diff a shared file first (a path
still sweeps the other session's hunks), never `git add -A`, never kill a bare
`godot --path .`. Commit after each verified chunk with tests green.

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

**Content (bible section 7).** Chassis ids: `badger`, `clydesdale` (d9; the die cap is
10), `sparrowhawk`, `baboon` (the Mandrill, renamed 28 September; its passive Pocket
Paradox runs on the new `on_foe_status` trigger, `Effects.foe_status_suppress_chance`;
Aphelion stock is `umbra_projector`, `pulse_repeater`, `zenith_emitter`, `halo_shield`,
`radiator_sail`, with `corona_shield` a unique unlock), and the 28 September drafts
`armadillo`, `wild_boar`, `prairie_dog`, `dingo`, `goshawk`, `nemesis`, `ammit` (the last
two the Arsenal's; maker `arsenal` exists). Their shapes are decided (the chassis pass
row): every new passive and most locked components carry `"status": "planned"` until the
engine has volatile, devour, Shocked, Overcharged, taunt, overwhelm, the stealth join
rule, the vent-on-fire face, the die-local reroll and heat-scaled shield regen. Numbers
are in tens and are placeholders; every stat is read through `sim/effects.gd`. An enemy
unit is a **pack** everywhere. Ryan writes `content/*.json` in his own voice (he writes
die totals in his head; the data keeps free slots), often from his phone through the
content editor artifact https://claude.ai/artifact/HnE3gvsxNHXyjRhRyEiDqT: pull collection
`edits` with ArtifactData, apply by hand (the files are hand-formatted), test, commit,
republish the page with its `files` map, clear the documents. The memory note has the
quirks. Tests never hardcode an entry's passive name.

**Reserved names (28 September).** `content/reserved_names.json` holds about 1,250
machine names (BattleTech, Heavy Gear, 40k, Halo); `ContentDB._validate_name_clash`
refuses an exact match unless `design.name_clash` says why it stays. Ryan's verdicts (28
September) are in the notes: `sparrowhawk` kept (a coincidence: a Halo Wars gunship and a
BattleTech fighter, both obscure; the name conjures the bird), `goshawk` and `baboon` kept
(designation-tier: the Vapor Eagle's Inner Sphere name, the Howler's Clan name), `badger`'s
id kept (Honey Badger is clear); `dingo` (a Heavy Gear Northern gear) is still his to decide
(todo). The tiers: iconic (the name conjures their machine: never), known (a hobbyist
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
`hp_<n>` pin in the loadout's order, verified for all seven; two older models still break that
rule and are in the to-do (the Clydesdale has 6 pins for 9 hardpoints since it went to a d9,
the Sparrowhawk 2 for 4). What the second pass changed, so nobody redoes
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

**What must be visible on a model, and how a swapped component looks (decided 29 September).**
Every hardpoint carries an `hp_<n>` Empty at its socket, +Y where the weapon points, one per
hardpoint in the loadout's order; a fixed component is modelled in and has no pin. The bible
row (section 7, "Hardpoints are marked in the model") is Decided now, its stale 2D-versus-3D
clause struck. **Swapping: silhouette classes.** A component declares a `shape` and wears that
shape at the pin in its maker's metal; the die carries the identity. About six shapes to start
(barrel, twin barrel, rack, slab, vent block, dish), and the set may grow when a component
really wants its own (Ryan: landing between classes and one-model-per-component is fine). Not
built yet; the to-do has the three pieces (shape helpers in lowforge, the `shape` field with
its validation, chassis pins parenting their stock shape so `MechView3D.mount()` hides it).
`mount()` and `unmount()` exist and nothing calls them.

**The hangar codex page (29 September).** Ryan asked for one surface showing a chassis and
the components fitted to it instead of jumping between files. `tools/build_codex.py` reads
`content/*.json` and writes a page: each chassis with its designation plate, maker,
silhouette, traits, a stat grid, its passive, and its die laid out entry by entry, fixed
first and then each hardpoint tagged with the model pin it mounts on, every entry showing its
component's numbers, keywords (hover for the vocabulary rule), maker and own passive, with
planned entries marked. Run `python3 tools/build_codex.py . <out.html>` and publish the
result; regenerate after any content change. Account B's copy is
https://claude.ai/artifact/EF74jFYCWWmA3rSJFYWpR1. It is generated and read-only on purpose:
Ryan's editing surface is the content editor, and two pages that both write content would
fight.

**What the game does today.** A battle: the map shows every pack's intent and the exact
result of the plan before Resolve; a grounded machine controls the ground beside it, a
pack stepping into it stops and that is a contact; every grounded machine within
`Battlefield.ENGAGE_RANGE` (2) joins, and a tether runs from each machine to the pack it
will fight (28 September; Ryan's play test decides whether 2 is right). Resolve plays the
moves, a CONTACT band, a panel of contacts; ENGAGE cuts to the skirmish, the dice fight on
the enemy's ground, four columns, every blow heard, the enemy's turn replayed blow by
blow; Back applies it. The boss's contact takes the phase: no panel, a reveal, the family's
theme (only The Chorus has one). MENU pauses, holds the settings and names the track. The
codex opens by double-tap on either screen and shows the machine's base state plus battle
rewards; the fight's effects live on the chips and the hold. Under the map, the orders
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
Next: a speakers/headphones setting (offsets per track and a bus EQ on the speaker
profile); the Risen and Infernal Horde boss themes from their seeds, melodies proposed in
chat first; the real recordings remain section 12's open question.

**How the listening page works** (the phone sketches, account A's page, 29 September; the
page block above owns the account rule). Ryan judges the music on his phone, not from the
repo, so a change is heard as an A/B before it lands.
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

**The phone (26 to 29 September; README has the commands).** Ryan's Pixel runs the debug
APK. Fixed so far: grid ribbons and their gain, safe insets, the MSAA leak, font
oversampling, the drag ghost, the far blur, scanlines on device pixels, leaders, the seam
band's clipped hexes, the orders board in the readout's strip (29 September: gauges, the
order's hex, what it meets, packs and foes, contact or not; the log is behind its LOG
button), a tap bracketing what it hit with gauges or strength over the unit, the gate's
footprint and attack hexes, the current zone told from the predicted, the routes redrawn,
props hidden under a standing machine (`Map3D._hide_props_under`; a passable hex's props
bake by hex). Still to judge on the device: frame rate (the per-hex props added draw
calls), the sound set, edges without MSAA, the text, the grid at the hotter gain.

**Open, in order.** The task list is `docs/todo.md`, one line a task, grouped by who
moves it and ticked in the commit that lands it; this is the order to take them in.

1. Ryan's play test of the engagement range and tethers, and his phone reads.
2. The planned engine pieces, in whichever order he wants to play first.
3. Ryan's text for the new machines and components, and the flagged names.
4. The discuss-first decisions in the Ryan section, the economy last.
5. Art: Ryan's notes on the seven first-pass models, enemy art, the hangar.
6. Before a phone leaves the desk: save and resume, onboarding, then tuning.
