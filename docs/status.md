# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF (v0.14 since the audit
of 1 October); republish it from the committed file after every bible change, passing that URL.

**The pages, as of 1 October, night.** Every page lives in the personal account (A). The three
that last are shared to the work email (B) as Editor, so a session in either account republishes
them in place by URL (a read first, then publish with `url`), and no account keeps a copy of its
own: B's old bible copy and Model Viewer retire. The two that serve an ongoing task stay in A
alone (Ryan, 1 October) and are republished from an A session. Shared:

- **The bible** (above): `docs/design-bible.html`, published whole after every change.
- **The hangar page** (https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH): four tabs, the
  codex, the content editor, the names list and the renders (earlier passes folded under each
  chassis, a Classes section). Source `tools/hangar.html`, published with the `files` map
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

In A alone, for the task each serves:

- **The listening page** (https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9): the effects'
  pass from `tools/soundforge/fx_sketches.py` (the weapons' third cut, the console, the blunt
  impact with its plasma layer, the voice in two registers; every file re-rendered 2 October),
  and nothing else; republish from `tools/soundforge/out/fx/` with `root` set to it. The music
  rounds re-render from `phone_sketches.py` if ever wanted again.
- **The engagement sandbox** (https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg) that drew the
  zone options, for the play test of the engagement zones.

**Rules learned:** a page's link goes into
this file in the same commit as the publish, so a parallel session sees it before publishing a
twin; `Artifact` with `action: "list"` shows only what the account you are in owns, so a shared
page is reached by its URL, never by listing; a page's database stays with the owning account,
so pulling `edits` or `melodies` from Claude Code works from an A session (Ryan can use every
page's database from the page itself in either account).

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

**The audit (1 October).** The bible, status, to-do, README and CLAUDE.md were read against
each other and the code: stale rows retired or marked superseded, the bible's keyword table
regenerated from the vocabulary, section 12 brought level with the to-do, the ticked to-do
lines pruned, this file cut to what stands. On Ryan's word the listen-by-listen history of the
tracks and the round-by-round history of the machines were retired from the bible, keeping the
rules and each thing as it stands; the unused `docs/concepts/` intake is deleted. One contradiction left for Ryan: the bible's HUD
palette row (18 September) read his swatch confusions as protanomalous, while the 29 September
rule says he has not named the type; both rows now say so, and every colour is checked under
all three simulations regardless.

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

**Models (bible section 7, the mount-rule row has the rule, the helpers and every machine as it
stands).** Every chassis has a lowforge model; `tools/lowforge/models_low.py` holds one function
per chassis id and every number in it is a proportion, so a note moves it and `forge.py build
<id>` plus one `--import` is the whole loop. Hardpoints are gun mounts (`hp_<n>` pins, each
parenting its stock part or a bare pad); a shaped component takes the next mount in its maker's
metal (barrel, twin barrel, rack, blade, dish), armour and vents show nowhere. Joints and turret
joints are code too. The round-by-round history is retired (Ryan, 1 October); the code and the
hangar page's Models tab are the record. **Ryan judges a model only from a render**, never from
code (`tools/hero_shot.gd` renders bare and needs a window); a hand edit in Blender has to be
re-expressed in the code to survive a rebuild. **Every machine is signed off for now** (Ryan,
1 October); next on the art side is judging the joints and turrets running in the skirmish.
Open on the models: the outward-only turret, each class's size per machine, the Clydesdale's
twin spacing, and the Baboon's rear silhouette with the fists at knee height (if it still reads
as two boxes: heavier hands carrying hardware, or a forward pose with the fist tile turned 90
degrees).

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
and a VEGA) is too faint under noise, cracks and pops to judge; the console is getting a fresh
pass from the UI design, Hold The Line and the direction notes, not from the existing sounds.
Content carries a `sound` label on a component (a word or a list meaning layers, validated in
`content_db.gd`; the Breaching Plow says blunt, the Gravity Knuckles blunt and plasma). A pick
lands as a recipe in `forge.py` with its hook (shape, maker, faction, silhouette, the label, the
replay telling shield hit from block from hit). The sketch script encodes AAC with `ffmpeg` at
256 kbps where there is no `afconvert` (its encoder smears a transient's front at 128). Next:
the fresh console pass on the page; the speakers/headphones setting; the Risen and Infernal
Horde boss themes from their seeds, melodies proposed in chat first.

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

0. **First, on the Mac:** run the tests. The `sound` label's validation in `sim/content_db.gd`
   (a word or a list of words) landed from a cloud session with no Godot; the two content
   entries that carry it are the Breaching Plow and the Gravity Knuckles. Then the effects:
   Ryan listens to the page (the third cut of the weapons, the fourth cut of the console, the
   blunt impact with its plasma layer, the voice in two registers, the level offsets) and his
   notes drive the next round in `tools/soundforge/fx_sketches.py`; a pick lands in `forge.py`
   with its hook. The page republishes from `tools/soundforge/out/fx/` with `root` set to it.
0. First, on the Mac: run the tests. The `sound` label's validation in `sim/content_db.gd` landed from a cloud session with no Godot (the carriers are the Breaching Plow and the Gravity Knuckles).
1. Ryan's play test of the engagement zones and the three behaviours (the radii, the brute's hunt, how big fights come out), and his phone reads.
2. Ryan's text for the new machines and components; with every machine signed off for now, the joints and turrets judged running in the skirmish.
3. The discuss-first decisions in the Ryan section, the economy last.
4. The engine gaps waiting on design (Phased, Energy Armour, Corrode, Scramble, Confuse, foe roles), and a dedicated hunter foe and spawned formations once proposed.
5. Audio: a full play of Hold The Line, the console's fresh pass and the effects' picks, the speakers/headphones setting, the two boss themes.
6. Art: enemy art through foeforge, the hangar. Before a phone leaves the desk: onboarding, then tuning.
