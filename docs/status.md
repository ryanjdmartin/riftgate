# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF (account A, the home
for every page; the pages block below has the rest; v0.14 since the audit of 1 October).
Republish it from the committed file after a bible change, passing the URL from any
conversation that did not publish it.

**The pages, as of 1 October, evening.** An artifact is republished only by the account that made
it, or by an account invited as Editor from its Share menu; the personal account (A) can invite
outward, the organisation account (B) cannot. **Account A owns four pages and nothing else:**
the Melody Desk (https://claude.ai/artifact/PcASpr5ijTdPcx1dNg3UoV: a piano roll of up to
sixteen bars, source `tools/soundforge/melody_desk.html`; the shipped tracks' parts stack as
layers from store collection `parts`, seeded by `tools/soundforge/desk_parts.py`, re-seed
after a track's parts change; Send writes to collection `melodies` with every note, each
layer's source and Ryan's memo; a session pulls a `new` document, listens, applies it in
the forge and marks it `applied` with a `reply` the page shows. Ryan's intent: the session
interprets what he sends; it is not drop-in), the bible (above), **the hangar page**
(https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH; 1 October, evening, Ryan: the pages
overlapped, merge what makes sense and clean up; four tabs: the codex, the content editor, the
names list and the renders with earlier passes folded under each chassis and a Classes
section; the nameplate's link kept for its `candidates` rows and its sharing; source
`tools/hangar.html`, published with the `files` map `tools/hangar_data.py` prints:
`content/*.json`, the shipped content every tab reads and the editor diffs against,
`hangar/pins.json`, each model's mounts read from the built `.glb`, and `hangar/renders.json`
with every render under `docs/hangar/renders/`; capabilities `db` and `user`, collections
`edits` and `candidates`; republish after every content, model or render change, or its tabs
go stale; the separate codex, Model Viewer and content editor pages are deleted and
`tools/build_codex.py` retired) and the listening page (https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9; since 30
September the effects' second pass from `tools/soundforge/fx_sketches.py` and nothing else;
the music rounds re-render from `phone_sketches.py` if ever wanted again). The engagement
sandbox that drew the zone options is https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg.
**Sharing:** the hangar page (as the nameplate it grew from) and the listening page are shared
to the work email as Editor and open there, so B republishes them in place; a B session cannot
use an A page's database from Claude Code, though Ryan can from the page. **Account B keeps
two pages:** its bible copy (republished from the committed file after any bible change a B
session makes) and a Model Viewer of its own (a B session records its link here). Ryan edits
content from his phone on the hangar page's Content tab; after he does, pull collection
`edits` with ArtifactData, apply by hand (the files are hand-formatted), test, commit,
republish the page with its map, clear the documents.
**Rules learned:** a page's link goes into this file in the same commit as the publish, so a
parallel session sees it before publishing a twin; `Artifact` with `action: "list"` says what
the account you are in owns, and a read of another account's page comes back "not found"; a
page shared as Editor across accounts republishes, but its database stays with the owner.

**Cold start, including from another account.** Nothing needed to work here lives outside
the repo. Read this file, then `docs/todo.md` (the task list), then `CLAUDE.md` (the rules,
the commands, and how Ryan works: he pressure-tests, judges effects running, leans hotter
on a phone, and retires old directions as he goes). `README.md` has the layout and every
command with its screenshot poses and phone-layout variables. The bible's sections hold the
why; section 11 carries the phone rows, section 12 the roadmap. Ryan may be running
another session on this repo at the same time: `git status` first, stage by path, diff a
shared file before staging it, and never `git add -A`. If a chat and the bible disagree,
the chat is newer.

## As of 1 October 2026

**State.** Tests green: `perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s
tests/run_tests.gd` (279 tests, 3,593 checks on 1 October, after the merge of the cloud
branch; the engagement zones and behaviours added more that day). Two or three sessions run on
this repo at once: check `git status` before committing, stage by path, diff a shared file
first (a path still sweeps the other session's hunks), never `git add -A`, never kill a bare
`godot --path .`. Commit after each verified chunk with tests green.

**The cloud session's branch is merged (1 October).** Branch `ccr-23c2f18f-qlilnd` carried the
engine list (the planned pieces, the ten foe actions, every trigger, save and resume); main
merged it at ee87e17 with tests green. It is left on origin until Ryan says to delete it.
Nothing claims the engine list now; the engine section of the to-do is open.

**The audit (1 October).** The bible, status, to-do, README and CLAUDE.md were read against
each other and the code: stale rows retired or marked superseded, the bible's keyword table
regenerated from the vocabulary, section 12 brought level with the to-do, the ticked to-do
lines pruned, this file cut to what stands. One contradiction left for Ryan: the bible's HUD
palette row (18 September) read his swatch confusions as protanomalous, while the 29 September
rule says he has not named the type; both rows now say so, and every colour is checked under
all three simulations regardless.

**Not rebuilt yet: the fists (1 October).** `bl_low.Tiles` draws `fisttop`, `fistpalm` and
`fistbase` folded out from the front as a net, and `models_low._fist` places each tile by the
hand's own axes, so the right hand wears the mirror; the `thumb` tile is retired. The Nemesis
and the Baboon use it. No Blender in the cloud, so `forge.py build nemesis baboon` on the Mac,
then `--import`.

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
(`tools/export_vocabulary.gd`). `docs/concepts/` holds the first day's batch template; no
batch was ever written to it, content is proposed in chat and lands in the JSON.

**Content (bible section 7).** Eleven chassis: `badger` (d6; its fourth stock entry the
Proximity Klaxon), `clydesdale` (d9; the die cap is 10), `sparrowhawk`, `baboon` (Aphelion's;
d7, the Halo Shield dropped; passive Pocket Paradox on `on_foe_status`), `armadillo` (its
locked component the Lockdown Shutters), `wild_boar` (five hardpoints), `prairie_dog`,
`dingo`, `goshawk`, `nemesis`, `ammit` (the last two the Arsenal's). Nothing in content is
planned any more: every passive, keyword, status and trigger the vocabulary names runs
(`Effects.fire`; the bible's section 7 row "The 28 September pieces, built" has each one), and
the ten foe actions run (`Foe.ACTION_EFFECTS`, weights 3:1 attack to special as placeholders,
section 9 row). Still planned in the vocabulary, all waiting on design: Phased, Energy
Armour, Corrode, Scramble, Confuse, the tank trait. Numbers are in tens and are placeholders;
every stat is read through `sim/effects.gd`. An enemy unit is a **pack** everywhere. Ryan
writes `content/*.json` in his own voice (he writes die totals in his head; the data keeps
free slots). Every component's codex and flavour are empty (42), and the seven new machines'
codex and flavour too: his to write. Tests never hardcode an entry's passive name.
`content/reserved_names.json` holds about 1,250 machine names (BattleTech, Heavy Gear, 40k,
Halo); the validator refuses an exact match unless `design.name_clash` says why it stays, and
every flagged name is decided (the bible's naming row). Names and concepts are spitballed on
the hangar page's Names tab (a tab per maker, Components, Rules; rows in the page's db
collection `candidates`; the check reads the reserved list and the live content, so nothing is
baked in).

**Models (bible section 7, the mount-rule row carries every round).** Every chassis has a
lowforge model; `tools/lowforge/models_low.py` holds one function per chassis id and every
number in it is a proportion, so a note moves it and `forge.py build <id>` plus one
`--import` is the whole loop. Fixed components are modelled in with no pin; every hardpoint
carries its `hp_<n>` pin, a gun mount pointing forward-ish that parents its stock part
(`with b.socket(...)`) or a bare pad (`b.pad()`). A component with a `shape` takes the next
mount in the die's order in its maker's metal (five classes: barrel, twin barrel, rack,
blade, dish; `models_low.SHAPES`, `forge.py shapes`, validated by `ContentDB.SHAPES`); shape
`none` (armour, vents) shows nowhere. `MechView3D.mount_plan()` names only the mounts that
differ from stock; `RIFTGATE_FIT="1:lance,4:blazethrower"` on `tools/hero_shot.gd` renders a
swap. Joints are code too (`with b.joint(...)`: the five limbed machines' arms, booms and
lance; turret joints on the Boar, Prairie Dog, Clydesdale and Badger, turned about their up
axis); vehicles and aircraft have no limb joints. Lowforge has a boolean cutter (`b.cut`,
`b.cut_box`), hollow tubes (`_tube(..., floor=False)`), open rings (`_rings(cap=False)`) and
`lit` and `glow` tiles. Thirteen rounds of Ryan's notes from the renders (the hangar page's Models tab since 1 October) are built; the
Prairie Dog, Badger, Goshawk and Boar are done; the thirteenth round (the Armadillo's seated
collars, the Clydesdale's turret height) waits on his judgement. Hand edits in Blender can be
taken through `forge.py export <id>`, but a rebuild overwrites the working file, so a hand
edit has to be re-expressed in `models_low.py` to survive. `tools/hero_shot.gd` renders bare
(`RIFTGATE_OUTLINE_KEEP=1` keeps the display's edge) and needs a window. **Ryan judges a
model only from a render**, never from code. Facet counts are a guideline, not a rule.
**Open on the Baboon:** Ryan judges the rear silhouette with the fists at knee height; if it
still reads as two boxes, his options are heavier hands carrying hardware or a standard
forward pose with the fist tile turned 90 degrees.

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
`withdraw_below`); `tools/balance.gd` runs the matrix, about fifteen minutes at 200 seeds
with eleven machines (`docs/balance.md`, generated 1 October with every engine piece in).
Its bands: the Honey Badger, Armadillo and Wild Boar win nearly every cell alone at little
cost (too strong out of the box; the Faraday Hull alone makes the Armadillo's), and the team
of three wins every single-pack fight at no cost, so the rank and file's numbers are the
lever; the Clydesdale and Ammit beat the ghouls under greedy and wall at the brutes and the
spawn; the Nemesis beats most packs but the Crucible costs it (its Overheating burns hull and
the bot does not vent for it); the Baboon, Prairie Dog and Dingo lose to the front-rank packs
alone, as support machines might; the Sparrowhawk and Goshawk hold. Overwhelm and the
Databank never fire in the runner's single-type, single-machine cells. Rerun after each
engine piece lands; read bands, not numbers.

**Audio (the bible's section 1 sound row has every listen and decision).** Everything is
`tools/soundforge/forge.py` writing WAVs into `art/audio/` (`build`, `measure`, `sections`,
`audition`, `sketch`); Ryan gives notes by section letter or timestamp. Six titled tracks in
`Sound.TRACKS`, all locked or "pretty great"; the map's set cycles, the skirmish's picks, the
boss theme per family (`SETS["boss_<faction>"]`, `LOOP_FROM`); one master for both palettes
(tilt 1.5 plus a presence lift). The Far Bank runs at 88 and the rift levels sit at the half
gap (-17.9, The Crossing -17.7). Hold The Line shipped its last pass on 30 September with
Ryan's seventh bridge melody from the Melody Desk (1 October); nothing of his is pending on it
but a full play in the game. The track levels stay until Ryan says otherwise. Ryan judges
the music on his phone, so a change is heard as an A/B before it lands: a sketch never
overwrites a shipped track, a pick lands in `forge.py`, then `build` and one `--import`.
Next: a speakers/headphones setting (offsets per track and a bus EQ on the speaker profile);
the Risen and Infernal Horde boss themes from their seeds, melodies proposed in chat first.

**The effects' second pass** (30 September, evening; the bible's sound row has the design).
`tools/soundforge/fx_sketches.py` renders every effect again beside the shipped one at the
shipped level into `tools/soundforge/out/fx/`, plus four rounds in context over the tracks,
and copies `fx_page.html` in as `index.html`; the listening page holds that and nothing else.
Sections: the console, the iron, the rift, the red. Nothing is shipped; a pick lands as a
recipe in `forge.py` and, where the page says, a small hook (shape, maker, faction,
silhouette) in `skirmish_screen.gd`, `battle_screen.gd` and `sound.gd`. Next: Ryan's notes by
section and row.

**The phone (bible section 11 has four rows on it; README has the commands).** Ryan's Pixel
runs the debug APK at 60 fps with the fine map (the default, since the Compatibility renderer
has no anti-aliasing to give; MSAA measured leaking and is unreachable). Text is clean. The
marks are in three registers, green/violet/red, each carried by structure as well as hue,
because Ryan is colourblind: check a new colour by simulation (CLAUDE.md has the rule;
`RIFTGATE_HUD` renders against every HUD option). Still to judge on the device: the outline at
2.6, the intent field's stripe width and spoke count in motion (`STRIPE`, `SPOKES`), the
sound set, the grid at the hotter gain.

**Open, in order.** The task list is `docs/todo.md`, one line a task, grouped by who moves
it and ticked in the commit that lands it; this is the order to take them in.

1. Ryan's play test of the engagement zones and the three behaviours (the radii, the brute's hunt, how big fights come out), and his phone reads.
2. Ryan's text for the new machines and components; his judgement of the thirteenth round and of the fists once rebuilt.
3. The discuss-first decisions in the Ryan section, the economy last.
4. The engine gaps waiting on design (Phased, Energy Armour, Corrode, Scramble, Confuse, foe roles), and a dedicated hunter foe and spawned formations once proposed.
5. Audio: a full play of Hold The Line, the effects' second pass, the speakers/headphones setting, the two boss themes.
6. Art: enemy art through foeforge, the hangar. Before a phone leaves the desk: onboarding, then tuning.
