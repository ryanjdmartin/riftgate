# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/LnfQcNkQhaDQNsMTTxrjCF (v0.16 since 2 October); republish it from the committed file after every bible change, passing that URL.

**The pages, as of 2 October.** Every page lives in the personal account (A). Four are shared
to the work email (B) as Editor, so a session in either account republishes them in place by
URL (a read first, then publish with `url`; checked from a B session on 2 October, the Melody
Desk republished unchanged), and no account keeps a copy of its own. The engagement sandbox
stays in A alone (Ryan, 1 October: it serves one ongoing task) and is republished from an A
session; a B session cannot read it. Shared:

- **The bible** (above): `docs/design-bible.html`, published whole after every change.
- **The hangar page** (https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH; republished 2 October with the targeting pass's content): four tabs, the
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
- **The listening page** (https://claude.ai/artifact/52qg7kVfAsANgURn98r9d9): the effects'
  pass from `tools/soundforge/fx_sketches.py` (the weapons' third cut, the console, the blunt
  impact with its plasma layer, the voice in two registers; every file re-rendered 2 October),
  the console derived again that night, the voice re-rendered), and nothing else; render with
  `fx_sketches.py` then `console_sketches.py`, copy `fx_page.html` in as `index.html`, and
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

## As of 2 October 2026

**State.** Tests green: `perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s
tests/run_tests.gd` (293 tests, 3,899 checks on 2 October, after the targeting pass merged main;
a cloud session fetches Godot 4.7's Linux build from the GitHub release asset to run them, since
the proxy serves the asset though not the release page). Two or three
sessions run on this repo at once: check `git status` before committing, stage by path, diff a
shared file first (a path still sweeps the other session's hunks), never `git add -A`, never
kill a bare `godot --path .`. Commit after each verified chunk with tests green.

**Unmerged:** `claude/sweet-goldberg-m588er` carries the effects' third cut, the console's
fourth, the blunt impact, a `sound` label on components (validated in `sim/content_db.gd`,
never yet tested) and the console voice (`tools/soundforge/speech.py`). It branched before the
clean slate, so its `docs/` resolve to main's copies with its facts ported, and its tests run
on the merge.

**2 October: the to-do review and what came of it.** Every to-do line was checked against the
code. Ryan's calls, each in the bible:
- Closed: the d4 question (die size is a balance lever like any base stat), the participant
  cap (four columns is the most a formation will be), the Baboon's rear silhouette and the
  Clydesdale's twin spacing. The seated die is in the new effects pass.
- Movement in tens, with a price table by way of moving, a Wheeled trait for the cars,
  stranded leftover move and a move gauge (section 4). Ready to build.
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

**Content (bible section 7).** Eleven chassis: `badger` (d6; its fourth stock entry the
Proximity Klaxon), `clydesdale` (d9; the die cap is 10), `sparrowhawk`, `baboon` (Aphelion's;
d7, the Halo Shield dropped; passive Pocket Paradox on `on_foe_status`), `armadillo` (its
locked component the Lockdown Shutters), `wild_boar` (five hardpoints), `prairie_dog`,
`dingo`, `goshawk`, `nemesis`, `ammit` (the last two the Arsenal's). Nothing in content is
planned any more: every passive, keyword, status and trigger the vocabulary names runs
(`Effects.fire`; the bible's section 7 row "The 28 September pieces, built" has each one), and
the ten foe actions run (`Foe.ACTION_EFFECTS`, weights 3:1 attack to special as placeholders,
section 9 row). Still planned in the vocabulary, all waiting on design: Phased, Energy
Armour, Corrode, Scramble, Confuse, and the Tracked and Wheeled traits. Numbers are in tens and are placeholders;
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
1 October); next on the art side is the joint pass (bible section 7, the joints row), then the
acts and movement. Open on the models: each class's size per machine, and the machines' scale
on the map's hexes (Ryan, 2 October: needs adjusting; all are fitted to one width today).

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
`withdraw_below`); `tools/balance.gd` runs the matrix, about half an hour at 200 seeds with
eleven machines, twelve packs (the nine plus each faction's whole formation in one fight, since
2 October) and the team row run twice for the targeting comparison (`docs/balance.md`, generated
2 October with the targeting pass and the playtest set in). **The baseline reading, for Ryan's
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
sounds (`tools/soundforge/console_sketches.py`, section 1 of the page, in its second and third cuts side
by side: the FM terminal, the console's own instrument apart from the music's, with digital
motions, and the same terminal through an operations channel after Ryan's RTS thought experiment,
orders out and each maker's machine answering, the field reporting; the music under the sequences
4 dB down; the fourth cut folded away at the page's foot); the voice is re-rendered judgeable (a smooth glottal pulse,
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

**Open, in order.** The task list is `docs/todo.md`, one line a task, grouped by who moves
it and ticked in the commit that lands it; this is the order to take them in.

0. **First, on the Mac:** run the tests. The `sound` label's validation in `sim/content_db.gd`
   (a word or a list of words) landed from a cloud session with no Godot; the two content
   entries that carry it are the Breaching Plow and the Gravity Knuckles. Then the effects:
   Ryan listens to the page (the third cut of the weapons, the fourth cut of the console, the
   blunt impact with its plasma layer, the voice in two registers, the level offsets) and his
   notes drive the next round in `tools/soundforge/fx_sketches.py`; a pick lands in `forge.py`
   with its hook. The page republishes from `tools/soundforge/out/fx/` with `root` set to it.
1. Ryan's play test of the engagement zones and the three behaviours (the radii, the brute's hunt, how big fights come out), and his phone reads.
2. Ryan's text for the new machines and components; the machines' scale on the map; the strikes, then the acts and movement, judged running.
3. The discuss-first decisions in the Ryan section, the economy last; enemy targeting decided and built 2 October (the paragraph above; the runner's read is the baseline question); the commander layer once the balance has a baseline.
4. Ready to build: movement in tens; the joint pass, then the idle acts, then the movement animations; the machine weld and the prop fade; the 3D at 30 last, once the animations exist to judge it against. The engine gaps waiting on design (Phased parked, Corrode, foe roles), and a dedicated hunter foe and spawned formations once proposed.
5. Audio: a full play of Hold The Line, the console's fresh pass and the effects' picks, the two boss themes.
6. A prototype hangar in the game (paints and loadouts, no economy). Art: enemy art through foeforge, the hangar as a model. Before a phone leaves the desk: onboarding, then tuning.
