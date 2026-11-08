# Riftgate (working title)

Portrait-mode tactical hex battler for Android. A few customizable war machines hold the last
city gate against a whole genre invading, the JRPG world's wildlife and its heroes pouring through rifts, in a roguelike campaign.

The game's rules as they stand are in `docs/rules.md`. The design bible, `docs/design-bible.html`,
records every decision, recommendation and open question, and why; its section 12 holds the
questions only Ryan can settle, and the order of work is `docs/status.md`'s.

## Layout

- `sim/` — pure simulation. No scene dependencies. Seeded RNG. Everything here runs headless.
  - `hex.gd` axial/cube hex math, pointy-top pixel conversion
  - `battle_map.gd` terrain grid, gate, rift, procedural generation with a guaranteed ground path
  - `unit.gd` mechs, packs, city defenses on the battlefield
  - `battlefield.gd` the turn's rules: every pack's walk on the enemy's turn (a pusher to the
    gate, a hunter to its prey, round the machines), the fights hunters force, who joins a
    fight by ring and who can be committed by attack range, the wall struck from anywhere
    along it, Rift Pressure's peaks (the rift's cycle, the tears and the seam)
  - `ramp.gd` the ramp, one table of placeholders by the Convergence: the compositions on the
    field at the start (it scales no pack), the timer, the tears a peak and the seam's creep,
    and by the tier the Fractures and which of them bring an elite
  - `face.gd`, `die.gd` die faces and dice
  - `foe.gd` an enemy inside a skirmish
  - `skirmish.gd` the dice skirmish: two-rank enemy formation fed from a pool, reach rules,
    keywords, heat, shields, injuries, outcome
  - `loadouts.gd` sample dice and packs for prototypes and tests
  - `harness_setup.gd` what the harness launches (team, loadouts, a battle as a run deals it,
    a fight, seed, map shape), built into a battle or a skirmish, kept between launches
  - `policy.gd` a player for the headless skirmish, a ladder of skill (random, blind, greedy,
    and a planner that rolls each decision out two rounds) with personas on top, so balance can
    be measured over thousands of fights
  - `effects.gd` the one pipeline every number is read through: base plus every live modifier
    (passives, rewards, buffs, statuses) with a scope and a source, and the passive triggers
    and effects the engine runs (`Effects.supports`; the validator refuses others)
  - `content_db.gd` loads and validates `content/*.json`, builds dice, mechs, and foes
  - `save.gd` writes the whole battle to `user://battle.json` and reads it back; the run to
    `user://campaign.json` (the battle under way inside it), the quick campaign to
    `user://quick_run.json` (the fight under way inside it) and the profile to
    `user://profile.json`
  - `battle.gd` one battle end to end: the player's turn (moves at once, one fight at a time,
    a fight spends a machine's action, the Dingo's first of two, a hunter's catch first), the enemy's turn, until the gate
    falls, the team is wrecked, or the boss dies; the Rupture meter's tally by menace, its
    Fractures, the elites at them, the boss's seal and the stall guard
  - `campaign.gd` the run: five cities and their gates, rifts rolled as fronts, the roster
    and its shop, salvage by menace and Anathema, the between-battle rules, the turn's bleed
    and drain, the rift's tier locked as it opens and the ramp, the finale
  - `quick_run.gd` the quick campaign: battles without the map, each its fights back to back
    against one domain's formations and elites, then its boss (or from tier two its final),
    the tier's escort beside it; the loot, the token and a maker's offer when the boss falls;
    the hangar's verbs between battles
  - `profile.gd` what outlives a run: the pool, the codex, the tier, the favour piece
  - `battle_bot.gd` plays a whole battle headless (the map's plain rule, every fight by
    `policy.gd`; the turtle and the detaching personas), for the campaign runner
- `content/` — game data: `vocabulary.json` (every mechanic term; `codex` is the rule as the player reads it), `factions.json`,
  `foes.json`, `chassis.json`, `components.json`, `modules.json`, `loot.json` (the field's caches). Placeholder numbers. `reserved_names.json` is
  every machine name in BattleTech, Heavy Gear, Warhammer 40k and Halo; a chassis nickname or id
  on it fails the validator unless the entry records the clash under `design.name_clash`.
- `game/` — scenes and presentation.
  - `harness.tscn` is the main scene, four tabs over launch buttons that stay put: TEAM
    (who deploys, in the order ticked, and each machine's hardpoints, any component on any
    hardpoint), BATTLE (a battle as a run deals it: the domain, which of its bosses, a guest
    domain, the tier and the ramp), FIGHT (a composition picked by its domain, tier and threat
    rating, fought alone with its layout; or one unit by hand, loaded from a faction and edited
    from there: the packs' foes as one pack, or a boss at the tier with them as its escort, its own
    curated escort with none) and SETUP
    (seed, map shape or the one the seed draws, HUD colour). Battle plays the BATTLE tab's
    battle, Fight the FIGHT tab's fight; Resume battle below, while a save exists;
    Quick campaign starts one on SETUP's seed, and Resume quick campaign picks a saved one up.
    What was last launched is kept in `user://harness.json` (`sim/harness_setup.gd`)
  - `battle/battle_screen.gd` the battle screen: the map with the turn around it, the panel
    that sets up a fight, and the skirmish screen hosted over it; `battle/battle_map_view.gd` draws the
    field and reads the gestures; `battle/orders_board.gd` the strip under the map;
    `battle/boss_reveal.gd` the boss's reveal; `battle/bleed.gd` composites the 3D field
    with the painted other world
  - `skirmish/skirmish_screen.gd` the skirmish screen, built in code
  - `quick/quick_run_screen.gd` the quick campaign's screens, built in code: the draft, the
    hangar (the squad, each machine's hardpoints and module slots fitted from the stores), the
    battle's track between fights, the rewards and the run's end, the fights the skirmish
    screen's
  - `ui/` the HUD kit (bars, glyphs, palette, buttons), the die face view, the codex box, the
    pause menu, `mech_view_3d.gd` (a machine's model with its mounts and joints), `mech_rig.gd`
    (its joints, idle acts and strikes from the model's sidecar), `mech_weld.gd` (its parts
    welded at load, a mesh a material in each moving group, for the draw calls),
    `colour_tuner.gd` (a debug build's COLOURS page, under the pause menu's SETTINGS: the HUD
    presets, the enemy's four violets and the meanings, set by wheel, sliders or hex and kept in
    `user://settings.cfg`; PEEK hides the menu until a tap, COPY puts the picks on the
    clipboard as `KEY #rrggbb` lines, RESET ALL asks twice; headless runs and other builds keep
    no picks), `terms.gd` (the one table of every term the keywords list defines, a foe's move
    keywords among them, its icon and
    its colour group, read by the die's marks, the chips and the text, and the matcher that
    finds the terms in shown text), `keyword_tip.gd` (a term's entry, opened by a tap on it in
    any text), the feed
    effects (`feed_fx.gd`, `tear_layer.gd`), the predator sense (`prey_layer.gd`), and the
    skirmish's field (29 October): `hud_backdrop.gd` lays it, `battle_backdrop.gd` paints its
    far part, the other world as a battle screen's backdrop in each domain's palette, and
    `floor_plane.gdshader` its near part, our ground with the display's grid, both seen by the
    one camera that draws the machines
- `tests/` — headless tests. `run_tests.gd` discovers `test_*.gd` files and runs every
  `test_` method, including the content validator and a headless drive of the skirmish screen;
  a `live_test_` method runs on the first frame, once the scene tree is up, for a test that
  routes input as the engine does (a drag over a scrolled list).
- `tools/` — `export_vocabulary.gd` regenerates `docs/vocabulary.md`; `pages/bible_tables.py`
  writes the bible's two vocabulary tables from content; `pages/bible_merge.py` merges the bible
  row by row onto a live page another session moved; `balance.gd` plays every
  chassis and the team against every pack under each policy and writes `docs/balance.md`
  (`--trace` prints one fight blow by blow); `map_survey.gd` measures the map generator over
  many seeds and writes `docs/map_survey.md`; `campaign_run.gd` plays whole runs and writes
  `docs/campaign_run.md`; `target_probe.gd` tallies whom the foes strike, every starter trio
  against each faction's formation, bosses and first pack; `special_probe.gd` tallies how often
  each foe special's condition holds and it is picked, and each fight's overheats, as built, with
  a condition opened or with the foes' heat stacks scaled (`special_probe_read.py` reads its
  parts); `chain_probe.gd` plays a squad through one domain's formation up to nine times in a
  row with its damage carried, for the quick campaign (`chain_probe_read.py` reads its parts);
  `quick_run.gd` plays whole quick campaigns and writes `docs/quick_run.md`; `endgame_fours.py`
  fits the five
  endgame fours up to tier two and runs them through the loop driver; `pricing_run.py` is the
  pricing run's driver (every stocked piece by knock-out, every slottable component and every
  module through the same hardpoint of five benches on the team rows, the guns' heat by steps,
  and the vanilla ladder, a flat heatless gun at every number and across the heat classes, so
  every piece reads in vanilla points; each variant a balance-runner process with `--set` or
  `--fit`, summarised into `build/pricing/<name>/summary.md`); `synergy_map.py` prints who sets and who reads every
  status and resource, from content, and writes `docs/synergy_map.md`; `turn_loop.py` models the
  campaign's turn loop from its constants with every battle won, for the pressure the fronts put
  on the cities; `backdrop_shot.gd` paints the skirmish's battle backdrop for every domain on
  every ground into PNGs, headless; `screenshot.gd` renders a
  scene to PNG at 720x1280; `die_sheet.gd` draws the die's whole iconography on one sheet with
  the die's own drawing (every main mark and what it holds, whom a piece reaches, the rest of a face's marks);
  `hero_shot.gd` renders one unit large; `fit_sheet.gd` renders every
  machine wearing each silhouette class on all its mounts, one sheet; `tileset_shot.gd` draws every
  domain's tileset side by side, posterized as the map shows it; `perf_probe.gd` measures
  the battle map's or the skirmish's frame cost and draw calls; `lowforge/` builds the
  ally units by code from a brief (`models_low.py`, one function per modelled chassis, named by its id; a chassis without one
  draws the Badger's) in the
  mid-nineties 3D register with generated tiles; `sheet_export.py` exports the map tokens and the
  contact sheet from the grids in `docs/sprites-enemies.html` to `art/foes/`; `foeforge/`
  generates enemy candidates with an image model and cuts one into `art/foes/` (the combat
  sprites come from here, not the sheet); `placeholder_art.py` draws a rough placeholder, a
  reminder stamped "?", for a foe with no picked render; `recolour.py` writes a recolour's two sprites from its
  base's by a hue shift (the ladder's palette swaps, its table the hues the three colourblind
  simulations chose); `soundforge/` builds every sound and the
  six music tracks from written recipes (numpy); `phone.sh` puts a Web build on a phone
  over the LAN, `android.sh` the real debug APK over USB; `hangar.html` is the
  hangar page, one artifact with five tabs (the codex, the content editor, the names list, the
  designs: every brief in `docs/briefs/` laid out for Ryan to correct, read from
  `hangar/designs.json`, which `hangar_designs.py` writes from the briefs and folds his
  corrections back with; and the models: each machine live in 3D, its motion and mounts, over
  the game's renders, whose script is `hangar_motion.js`, a port of the game's rig), published
  with the `files` map
  `hangar_data.py` prints (it also writes each built model and silhouette class as glTF JSON
  into `build/hangar/models`, since an artifact serves no .glb): each `content/<file>.json`
  at that same path as the shipped content every tab reads and the editor diffs against,
  `hangar/pins.json` (the models' mounts) and `hangar/renders.json` with the renders under
  `docs/hangar/`; Ryan's saved edits live in its database (collection `edits`), the name
  candidates in `candidates`, his corrections to the briefs in `designs`; `spriter/.venv` is the Python
  the tools run with. The gate and wall are lowforge models too (`gate`, `wall`).
- `art/` — `models/` every glTF the engine draws (units, gate, wall) with a `<id>.rig.json`
  sidecar beside each machine (its joints' axes and limits, its idle acts, its cornering
  numbers, what each hardpoint's stock part is, `hidden_pins` where a model hides its mounts
  (`b.pin(..., hidden=True)`, the Cottonmouth's), `counts` and `spin_held` where a model shows a count or a status, `spin_step` and an act's `locks` where an act stops a spinner on a step, `fires` (each fixed weapon's slices of its acts, in turn, and a slice's `blow`), an act's `idle: false` where it only fires, `launches` where a weapon fires a part out (the Lammergeier's drones, `b.launch(...)`); written by lowforge, read by `mech_rig.gd`
  and by `mech_view_3d.gd`, which wears a fitted die against that record), `models/shapes/` the
  silhouette classes in each maker's metal, a burn weapon's fire for each and `muzzles.json`,
  where each class's muzzle flare blooms (`forge.py shapes` writes all three), `foes/` the combat sprites foeforge cuts from Ryan's picks and the
  16x16 map tokens the sheet export writes, `fonts/` the HUD faces, `audio/` every sound by name (`game/audio/sound.gd` lists
  them) and `audio/voice/` Jenny's lines with `lines.json` (`game/audio/voice_lines.gd` is
  her system). A missing foe sprite falls back to a placeholder shape; a missing sound is silence.
- `docs/` — one job each. `rules.md` the rules as they stand; `design-bible.html` the
  decisions and why, with the questions only Ryan can settle in its section 12; `status.md`
  how things stand and the order of work, rewritten at every handoff; `todo.md` the tasks, one
  line each by who moves it, ticked in the commit that lands it; `measurements.md` every run a
  decision cites; `vocabulary.md` generated from the vocabulary; `synergy_map.md`, who sets and
  who reads every status and resource, generated from content; `balance.md`, `campaign_run.md`,
  `quick_run.md` and `map_survey.md` generated by the runners. Proposals and briefs, each the
  design's one home until its decisions are rows and content, then retired to git: the
  design-session briefs (`briefs/`, with a README that says what each waits on), the economy
  pass (`economy_pass.md`), the bosses' and elites' slate (`bosses_proposal.md`), the heroes'
  pass beyond Final Fantasy (`heroes_proposal.md`), the mechanics audit (`mechanics_audit.md`)
  and the roster analysis (`roster_analysis.md`, published as a page by
  `tools/pages/roster_analysis_page.py`, background since the go). `sprites-enemies.html` is the
  sheet the map tokens are exported from; the hangar page's renders and pins are under
  `hangar/`, look tests under `looks/`, design canvases under `canvas/`.

## Running

Open the folder in Godot 4.8 (4.8-beta2 until 4.8 ships: its MSAA fix is why) or later, or from a terminal:

On Windows (the desk machine since 19 October, when the Mac went out of reach) every command
below runs as written from Git Bash, from the repo folder (a new Git Bash starts in the home
folder: `cd ~/Desktop/Code/riftgate` first); from PowerShell, wrap one as
`& 'C:\Program Files\Git\bin\bash.exe' -lc '<command>'`. The phone scripts have launchers for
PowerShell and cmd, `tools\android` and `tools\phone` (`.cmd` files that run the `.sh` with Git
Bash in the same window, from any folder by their full path); given a `.sh` itself, Windows
opens a separate Git Bash window that closes with the output. What makes them run there: `godot` and
`python3` are shims in `~/bin`, which Git Bash puts first on its path (Godot 4.8-beta2 under
`%LOCALAPPDATA%\Programs\Godot`, self-contained: the `._sc_` file beside it keeps its settings,
export templates and debug keystore in `editor_data` there; Python 3.13, since Windows' own
`python3` is a Microsoft Store stub); each venv has a `bin` junction to its `Scripts`, so `.venv/bin/python` resolves;
`BPY_PYTHON` points lowforge at `.bpy` (Python 3.11 with `bpy==5.0.1`; `.bpy/` and
`tools/soundforge/.venv-piper/` sit in `.git/info/exclude`); and `PYTHONUTF8=1` is set, since
the tools open text without naming an encoding and Windows would read it as cp1252. Python
writes CRLF there; `core.autocrlf=input` folds it back to LF on commit. perl's `alarm` kills
the engine as it does on the Mac. The tests take about a minute. The first import rewrites
the Prairie Dog's four textures, as in a cloud session: restore them. A cloud session sets
none of this up by hand: the repository's session-start hook (`.claude/hooks/session-start.sh`,
registered in `.claude/settings.json`; 27 October) fetches Godot 4.8-beta2's Linux build into
`~/bin`, puts it on the path and runs the first import with the textures restored, before the
session's first command, once in a container. foeforge's `generate` and
`fix` cannot run there (mflux needs Apple silicon, and the PC has no NVIDIA card). The Claude
desktop app is a packaged Windows app: what its sessions write under `AppData` lands in a
private copy only Claude's own processes see (`AppData\Local\Programs` excepted), which is why
the SDK and Godot's data live where every shell sees them; check a new install from a terminal
tab, which sees what your own shells see.

```sh
# first run, and after adding PNGs or a class_name: the import and the script class cache
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import

# run the test suite (about four minutes)
perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd

# run the harness: a battle, a skirmish, a saved battle and the quick campaign
godot --path .

# the hangar page: the codex, the content editor, the names, the designs and the renders in one artifact
python3 tools/hangar_data.py        # writes docs/hangar/pins.json and build/hangar/designs.json, checks the renders manifest, prints the files map
python3 tools/hangar_designs.py --check   # every brief's hangar header, alone
# a design session's first step: save the `designs` collection with ArtifactData's list (out_dir build/hangar/inbox), then
python3 tools/hangar_designs.py --fold build/hangar/inbox --dry   # what it would fold; without --dry it writes the briefs and prints the batch that clears them
# then publish tools/hangar.html to https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH with that map (a render round: pictures into
# docs/hangar/renders/<chassis>/, the entry in docs/hangar/renders.json, republish); after Ryan edits on its Content tab, pull
# the `edits` collection with ArtifactData, apply by hand, test, commit, republish, clear the documents
python3 tools/pages/roster_analysis_page.py > /tmp/roster_analysis.html   # the roster analysis as the page published to its artifact (status has the link), in the bible's style

# regenerate docs/vocabulary.md from content/vocabulary.json
perl -e 'alarm 300; exec @ARGV' godot --headless --path . -s tools/export_vocabulary.gd

# the bible's two vocabulary tables (buffs and debuffs; keywords and their counts), from content, after any content change
python3 tools/pages/bible_tables.py

# the bible republished when another session moved the live page: a three-way merge row by row (a row keyed by its lead, one
# both sides changed merged word by word, the version bumped past the higher), BASE the last publish both started from, OURS
# this branch's file, THEIRS the saved live source with the tool's wrapper line and its trailing </body></html> stripped; a row
# it cannot settle keeps conflict markers and is named on stderr
python3 tools/pages/bible_merge.py BASE.html docs/design-bible.html THEIRS.html > merged.html

# the balance report: every chassis alone and the starting team against every pack (tier one's lists,
# and since 28 October a cell for every recolour at its tier's strength, "goblin_guard x4"), against
# each faction's whole formation in one fight at each tier ("meadow formation" tier one's, "meadow
# formation tier 2" and "tier 3" the ladder's) and against the party (each bench hero's final with
# its domain's first pack, and the finale's line promoted; --noparty drops them), played by random
# and by greedy over 200 seeds a cell, written to docs/balance.md (several hours on one core,
# about two in four parts, below); the team cells run under both targeting
# rules and a section compares them. --seeds N, --policies greedy,
# --cool-above 50 (the cautious persona: each machine keeps its heat under half its maximum,
# venting early and holding a hot spend above the line; the pricing driver passes it on too),
# --overheat 2 (a what-if: an overheat burns two hull a point past the maximum; the driver's too),
# --burnout and --overheat-corrupt 1 (what-ifs on the component that took the gauge past the maximum:
# burnt out once the burn reaches the injury threshold, or Corrupted a stack every overheat; the driver's too),
# --shield-ahead (the shield persona: a shield left standing valued by the blows it turns next round,
# where the rungs bank it at a fifth of a point; the driver's too, for the support ladders),
# --targeting lowest (the rule before 2 October for the matrix), --json out.json for every cell;
# --rows badger,team runs only those rows; --team badger,sparrowhawk (repeatable) adds a row of exactly those machines,
# any number, so pairs and fours read beside the trios; --module tactical_databank runs every row beside its
# twin with that module fitted to every machine, the differences in a section of their own; for prices, --bump armour:5
# (repeatable: hull, shield, armour, heat, cooling, or damage on every blow) gives every machine
# that much more, --nopassive strips every chassis's passive, and --set
# components/arc_fault_cannon/face/keywords=[] replaces one content value for the run only (under
# components/, chassis/, modules/ or foes/: foes/behemoth/hp=48 reads a boss at another HP;
# repeatable, never validated: knock-outs and what-ifs), and --fit badger=ram_frame,tactical_databank
# (repeatable) fits those modules to every machine of that chassis; compare each against the same seeds without;
# --trace "sparrowhawk|goblin x6|greedy|3" plays that one fight and prints its log instead.
# --policies blind,planner reads the coordination gap (blind play's rounds over the planner's, on
# the big fights and on the rank and file); the planner costs about four greedy fights a fight,
# so it runs on the team rows: --rows "team,minerva team,kestrel team" --policies blind,planner;
# --packs big (or rank_and_file, or pack ids such as "treant x1,finale") runs only those packs;
# --pack goblin:3 or --pack goblin:4+mandragora:2 (repeatable) adds a composed pack, one foe type
# times a strength or several together in one fight (its id "pack:" and the spec, for --packs
# and --trace), so patrols and a front with a back read beside the spawn lists' packs (26 October).
# --packs promise runs the promise read instead of the matrix (the long wall brief, section 5):
# every patrol, formation and elite composition at each tier it names, fought by the default four
# machines cut to its threat rating, one short and one over, each cell its win rate, rounds and
# hull lost; printed, and written to --out when one is given (about forty minutes at 30 seeds).
# --packs curve runs the curve read for the formation pass (7 November): every such composition
# against the four cut to every size from one to four, random and greedy, each cell's band (free,
# a decision, a wall) and greedy's hull lost, its menace, ramp gate and rating, the sizes it is a
# decision for and the peers whose bands it matches at every size, candidates for pruning;
# printed, and written to --out (about two minutes a seed, so an hour at 30).
perl -e 'alarm 36000; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200
perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --packs promise --seeds 30 --policies greedy --out /tmp/promise.md
perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --packs curve --seeds 30 --out /tmp/curve.md
# the same matrix on several cores: --part i/n runs every n-th cell into its --json and writes no
# report, and --merge writes the report from the parts (same options on every part and the merge;
# the merged report reads as a whole run, the time the longest part's)
for i in 0 1 2 3; do perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200 --part $i/4 --json /tmp/part$i.json & done; wait
perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200 --merge /tmp/part0.json,/tmp/part1.json,/tmp/part2.json,/tmp/part3.json

# the map survey: 200 generated maps at the game's 9x20, measuring each ground's share, the
# water (bodies, which feature), the horde's narrowest crossing and what the guarantee opened,
# the phases each way of moving takes to the rift at move 3 and its reach after two phases,
# the relief (the steps, the lone hexes, a ring's jogs), then every map shape compared on as
# many seeds; written to docs/map_survey.md (about fifteen minutes). --type KIND
# (steppe, the baseline, or river, fjord, badlands, city, gorge: BattleMap.KINDS) for the detailed report, --seeds N,
# --move M, --w/--h (--width/--height) for another size, 20 by 12 the long wall's field (the default is
# the old field's, for the old reads); --show SEED prints one map as text.
perl -e 'alarm 2400; exec @ARGV' godot --headless --path . -s tools/map_survey.gd -- --seeds 200

# the campaign runner: whole runs played headless by a plain player (it defends the front
# nearest to falling, plays the defence rule on the map, fights at the greedy rung), measuring
# the campaign's placeholders: runs won, cities fallen, wipes, components destroyed per battle;
# written to docs/campaign_run.md. --runs N, --seed S, --policy random, --shape KIND (every
# battle on that map shape; the long wall brief's reads use steppe); --trace SEED prints one run
# battle by battle instead. The defence rule (BattleBot, the long wall brief section 5): a
# hunter's catch first, allies walking into reach of it; then each machine onto the pack it can
# stand beside that reaches the wall soonest, ties by the larger threat rating and the nearer; one
# with no pack in reach taking a cache its move reaches (the nearest, the higher kind on a tie),
# the rest walking toward the soonest, never the sealed boss; every fight fought out (there is no
# withdrawal). The report reads the field's size, the Rupture meter and the mouths (Fractures,
# the Rupture and the stall guard, peaks, what the rift and the tears sent, elites, menace
# killed, gate damage), the pressure ratio (the threat ratings at the wall or reaching it this
# turn over the machines standing: a run's mean, its turns above one, its battles' highest) and
# the fights by the pack's threat rating and the machines in them, with the stalemates (ten
# rounds of nothing changed) apart from the fights stalled at the cap
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40

# the quick campaign's runner (25 October): whole quick campaigns played headless (three draft chassis
# at random, the fights by Policy, a plain player picking and fitting the loot by tier), written to
# docs/quick_run.md: runs won, where they end, each battle's hull before its boss and kit, each kind of
# fight by tier. --runs N, --seed S, --policy random|planner, --team a,b,c;
# --trace SEED prints one run fight by fight. Minutes on four parts, then the merge:
for i in 0 1 2 3; do perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/quick_run.gd -- --runs 40 --part $i/4 --json build/quick_$i.json & done; wait
perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/quick_run.gd -- --merge build/quick_0.json,build/quick_1.json,build/quick_2.json,build/quick_3.json

# the stock pass's fills (22 October): the brief's numbers as the loops moved them, onto a checkout's content
# and the engine's rule numbers; idempotent on the branch, so a kept lever lands by editing its tables and running it
python3 tools/stock_fills.py .
# a balance loop (the stock pass's method): a copy of the project under build/loops/<name> with one lever moved in
# its content (`levers` lists them: the foes' blows, our durability, cooling, the maxima, a foe's armour, HP or move,
# every foe's aim, Flak's clock, any one value), the balance runner on the team rows at 30 seeds with every rung in four processes
# (--policies, --packs big, --rows cut it down), every chassis alone with --alone, the campaign report unless
# --no-campaign, and a summary against the bible's section 2 tests; `compare` lays finished loops side by side.
# --team adds a row of exactly those machines (a squad of four), --set passes the runner a fit no stock may carry
# (unvalidated, after the content loads; the built teams of 23 October) and --fit the modules a chassis wears
# (the endgame fours of 23 October: a loadout by --set, modules by --fit). About half an hour on four cores; a
# direction, never a band (docs/measurements.md). GODOT names the binary if needed.
python3 tools/stock_loop.py run blows --lever blows_by:rf=1.5,massive=1.33,hero=2 --policies random,greedy
python3 tools/stock_loop.py run fours --packs big --rows team:badger+clydesdale+sparrowhawk+dingo --team badger,clydesdale,sparrowhawk,dingo
python3 tools/stock_loop.py run built --packs big --set 'chassis/badger/loadout/0="polarity_projector"'
python3 tools/stock_loop.py compare base blows
# the endgame fours (23 October, the endgame half of the read by stage): five squads of four, chassis of any tier,
# every hardpoint and module slot filled up to tier two, checked against the content and run through the loop driver
# (random and greedy at 30 seeds, no campaign unless --campaign; stock_loop run options pass through)
python3 tools/endgame_fours.py endgame30
# the pricing run (27 October; the bible's pricing row of 28 October): every stocked piece knocked out of its team row, every slottable
# component and every module through the same hardpoint of six benches (BENCHES in the script) on the team rows, and
# every attack a heat class up, each variant one balance-runner process (--set and --fit in memory, content never written)
# against the big fights but the finale (the slate's bosses, tier one's formations from the factions' compositions, the finals), greedy at 30 seeds; `plan` prints the variants and fights (393 and 188,640
# as built, about two and a half hours on four cores), `run` is resumable (a variant with its JSON is skipped), `summarise`
# writes build/pricing/<name>/summary.md from whatever has run. --parts knockouts,ladders,modules,heat, --benches, --tiers,
# --packs all, tiers, tier2 or tier3 (the ladder's formations by tier), --policies random,greedy, --knock basic (the basic of
# the piece's kind in place of an empty hardpoint),
# --pieces and --modules to narrow the ladders, --numbers and --shapes the vanilla ladder, --bench-stocks for the benches'
# rows' baselines alone (a narrow read at 200 seeds), --set path=json on every variant (a module's line, a rule's what-if)
python3 tools/pricing_run.py plan
python3 tools/pricing_run.py run prices
python3 tools/pricing_run.py summarise prices
# the vanilla ladder (28 October): a flat heatless gun of each shape at 2 to 10 and at 3, 5 and 7 across heat 0 to 8 on the
# cold bench and the hot one, the pieces named read in vanilla points beside it; about 45 minutes on four cores
python3 tools/pricing_run.py run vanilla --parts vanilla,vanillaheat,ladders --benches prairie_dog,goshawk --pieces flak_cannon,stoker
# the synergy map: who sets and who reads every status and resource, from content (--write rewrites docs/synergy_map.md)
python3 tools/synergy_map.py --write
# the turn loop's pressure (24 October): the campaign's turn loop modelled from sim/campaign.gd's constants, every
# battle won, each rift keeping the tier it opened at; per way of choosing the front, the cities fallen, the fronts
# on the board, the turns offering two tiers and the rescues on a low gate. --widen N tries a rift that steps a tier
# up once it has bled its city N times. Seconds; a model, not a run of the game
python3 tools/turn_loop.py --seeds 2000
python3 tools/turn_loop.py --seeds 2000 --widen 3
# whom the foes strike (23 October): every starter trio a tender can deal, stock, greedy, against each
# faction's formation, bosses and first pack; picks as intents are drawn, the same with every machine standing,
# swings after any Lure, the exposed aim's weights, hull lost. JSON per cell, read by hand; four parts in parallel.
perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/target_probe.gd -- --out build/probe_0.json --part 0/4 --seeds 20
# how often each foe special fires (24 October): every third starter trio against each domain's formation, each boss
# and each hero alone, the same seeds, as built or with a condition named in OPENED read as true; --heat N scales the
# foes' heat stacks to size a buff, --only peak,magma keeps the cells named; four parts in parallel, then the reader
perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/special_probe.gd -- --out build/special_0.json --part 0/4 --seeds 10 --step 3
python3 tools/special_probe_read.py build
# formations back to back (25 October, docs/quick_campaign_proposal.md): every starter trio (or four: --squads fours,
# or a JSON file of squads, as endgame_fours.py --json prints the endgame fours) against one domain's formation up
# to nine times in a row, hull, injuries and wrecks carried, the shield full as each fight opens (the long wall
# brief: no field recharge); --density F scales the formation; four parts in parallel, then the reader
perl -e 'alarm 5400; exec @ARGV' godot --headless --path . -s tools/chain_probe.gd -- --squads trios --seeds 2 --out build/chain_0.json --part 0/4
python3 tools/endgame_fours.py --json > build/endgame_fours.json   # then --squads build/endgame_fours.json
python3 tools/chain_probe_read.py "starter trios" build/chain_0.json build/chain_1.json build/chain_2.json build/chain_3.json

# screenshot a scene (needs a window; a small one opens briefly); an optional third argument
# poses the screen first. Skirmish: codex, mechcodex, termtip (the first machine's codex with the
# first term its passive names opened, as a tap opens it), pair and pair_spread (a Gel's halves in its slot, and a
# Spread held over them; RIFTGATE_FOES=gel:2,goblin:3), hold (the second die read, its readout; RIFTGATE_HOLD_ENTRY=<place>
# picks the entry showing, with RIFTGATE_TEAM to choose the machine), mechhold and foehold (the first machine's
# and the first foe's: gauges, chips, a foe's intent), confirm, lock, touch (the first die lit as its tap waits out the double-tap window), swaphome (a waiting Swap sent home by a tap on nothing; RIFTGATE_SHOT_FRAME=6 catches it in flight), repick (a foe whose machine falls first, a
# second arrow dashed to the machine it will strike; RIFTGATE_FOES=wolf:3), strike,
# enemyturn (RIFTGATE_SHOT_FRAME=8 catches the acting foe lit), chips (every unit crowded with chips, the rows wrapping:
# seven statuses on each machine, five on each foe), plaque (a foe's named move on the other world's window; RIFTGATE_SHOT_FRAME=7), rage (the rage's roll again, its chip bursting; RIFTGATE_SHOT_FRAME=4), heat (a foe's Burning and Scorched on the first machine with Primed beside them, its die running hotter), foeheat (Burning, Flak and Shocked on the first three front foes, heat's red-orange beside each violet intent), blast and siphon (the Whip Scorpion's vent dragged over itself, every foe ringed with its blast; its Siphon dragged over a foe, the turned foes' arrows dashed; `RIFTGATE_TEAM=whip_scorpion,...`), rounds, logfull, killed, acquire, menu, settings, quit, keywords (the keywords list, as the menu's KEYWORDS opens it), colours and colourpick (a debug build's COLOURS page, and with the red's picker open), and the feed's
# events feed_scanbox, feed_databox, feed_readout, feed_levels, feed_recalc, feed_wobble, feed_tear, feed_signal,
# and groundtear (the corrupted side's tear as it fires), and swallowed (the first machine swallowed: a ghost under a dashed edge).
# RIFTGATE_MAP_KIND=gorge (any standalone battle run) picks the map's shape, none drawing one by the seed,
# and RIFTGATE_SEED=<n> the battle's seed (7); the harness has a picker.
# The skirmish's controls (any run, the battle's fights too): RIFTGATE_SKIRMISH_CONTROLS=bottom|middle overrides
# the saved Skirmish Controls setting (Middle by default: the log, dice and Reroll between the sides; Bottom: the
# machines right under the foes, the controls below them). RIFTGATE_TERRAIN=<ground> (the standalone skirmish)
# dresses the field for that ground, RIFTGATE_FOES puts a domain's foes on it:
# RIFTGATE_SKIRMISH_CONTROLS=bottom RIFTGATE_TERRAIN=ruins RIFTGATE_FOES=revenant:4,ghost:2
# and the backdrops alone, every domain on every ground, into PNGs (headless; size and horizon in art pixels):
# perl -e 'alarm 120; exec @ARGV' godot --headless --path . -s tools/backdrop_shot.gd -- build/backdrops 540 330 86
# Battle: select (a machine in hand: its move and its red band), route (two moves planned),
# plan_play (those played on END TURN; RIFTGATE_SHOT_FRAME), execute (played on EXECUTE, the turn
# going on), endask (END TURN's question while machines can still act), inspect (a pack tapped: its ring
# lit, the others' dashed), draft (a route drawn by hand, about halfway through the move),
# carry (a carrier's route to a stop where its rider cannot land: NO
# ROOM), hold, north, zoom, zoomlast,
# flyer, attack (a fight set up beside a pack), caught (a hunter's catch), resolve (a turn
# ended), contact and engage (the handover into a fight), codex, foecodex, menu, settings, tune, and
# bosscontact (the boss attacked: the reveal; RIFTGATE_REVEAL_T=<seconds> pins its frame), logfull (the battle log full screen), gate and foe (the gate or a pack tapped).
# RIFTGATE_SHOT_FRAME=<n> picks the capture frame, to catch an animation mid-flight.
# RIFTGATE_FEED_DEBUG=1 (any run) fires the skirmish feed's analysis events every half
# second and the ground tears every couple of seconds, to judge them by eye.
# RIFTGATE_SEAL_DEBUG=1 (any run with a model that holds a form, the Armadillo) holds the seal and lets it go in
# turn, and in a skirmish the sealed shell and its burst follow it, to judge them running; the open
# Armadillo stands with its vents ajar.
# RIFTGATE_ACT_DEBUG=1 (any skirmish) lights one foe after another as the acting foe is lit in the
# enemy's turn (its violet glow and breathing corners), a beat each, to judge it running.
# RIFTGATE_RAGE_DEBUG=1 (any skirmish) plays the rage's roll again over and over on the machine
# that spends rage: its chip bursts, then its die flips back with the reroll's sound.
# RIFTGATE_PREY_DEBUG=1 (any skirmish) keeps the predator sense on: the foes' ground dims and the foes
# the first ambusher's entry can reach that show no intent on it wear pulsing eyes (with no ambusher
# on the team, the first machine's, the read forced), to judge it running.
# RIFTGATE_PLAQUE_DEBUG=1 (any skirmish) fires the plaque with one of the field's move names after another,
# to judge it running.
# RIFTGATE_BLAST_DEBUG=1 (any skirmish) keeps the blast's marks on: every foe the first machine whose
# vents blast would fire at with its die's vent wears the turning dashed ring and the number.
# RIFTGATE_PULSE_DEBUG=1 (any run) keeps END TURN pulsing, on the map and in a fight, to judge it
# running (it pulses on its own once nothing else is left to do).
# RIFTGATE_MAP_VIEW=left|bottom (any run) turns the battle map for the run without touching the saved
# MAP VIEW setting (MapOrient): the wall at the left with the rift at the right (flat-top, the default),
# or at the bottom with the rift at the top; the battle screen's `queue` pose (two orders onto two
# packs) shows the fight queue's numbers, ENGAGE 1 OF 2 and the action pips.
# RIFTGATE_BLEED_DEBUG=1 (any run) gives the whole field to the painted world, to judge a domain's
# tileset in place (RIFTGATE_FACTION=meadow|waste|marsh|peak picks the domain on the standalone
# screen); `xvfb-run -a godot --rendering-method gl_compatibility --path . -s tools/tileset_shot.gd
# -- tilesets.png [frame]` draws all four side by side.
# RIFTGATE_PREVIEW_DEBUG=1 (any skirmish) puts the pulsing preview chip of a rally on its way on
# every foe showing a blow (+1 where none is coming, its number unchanged), to judge the pulse
# running; RIFTGATE_FOES=wolf:4 fields the real thing, howls lifting the bites after them.
# RIFTGATE_HIT_DEBUG=1 (any skirmish) lands a blow on a machine every second and a half, in turn a hull
# hit from the left, one its shield holds, one its armour turns and a hull hit from the right, and
# every fifth beat loses one and lights it again, to judge the hit reactions running.
# RIFTGATE_MISS_DEBUG=1 (any skirmish) lands a Sweep's wasted shot on the formation's empty slots in
# turn every second and a half: the jolt and the ring of dust thrown off it, to judge running.
# RIFTGATE_HALO=off|all (any run) draws no halo round the lit parts, or one round every lit part, to compare
# with the vetted set (31 October).
# RIFTGATE_PLUME=off (any run) draws a booster's ring in place of its plume (the Stingray's, on
# trial), to compare the two.
# RIFTGATE_SHOTS=1 (any skirmish) draws the shot crossing the field, tabled and off by default (a debug
# build's Settings → SHOT TRAILS turns it on too).
# The phone's layout on the desk machine: RIFTGATE_SHOT_H=<design height> renders a taller glass
# (a 1080x2424 phone is 1616), RIFTGATE_SAFE=<top>,<bottom> keeps its safe bands clear
# (any run, not only the tool), RIFTGATE_SHOT_SCALE=1.5 renders at its pixel density (the
# PNG comes out 1080 wide). The desk draws with the phone's renderer (gl_compatibility, the
# project's setting since 29 October), so a run there shows the phone's colours.
# RIFTGATE_AA=off|fxaa|msaa2|msaa4 forces the AA mode for a run (any run; the player's SETTINGS → AA MODE, MSAA 4X by
# default). fxaa is the look a phone had on Godot 4.7: no MSAA, the map's compositor running FXAA of its own in its place,
# the renderer leaking with MSAA there (godotengine/godot#97967, fixed in 4.8). The machines' textures read their mipmaps
# in every mode.
# RIFTGATE_SHOT_ZOOM=<z> shows any battle pose zoomed to z on its first machine (the overlay holds its size on screen).
# RIFTGATE_OUTLINE=<n> sets the battle map's machine outline width in design pixels, the same at every zoom, for a comparison
# (Map3D.OUTLINE is the default). A debug build's TRACES toggle draws the map without its traces (the creases on the
# machines, the props and the gate, one device pixel at every zoom), to judge the grain zoomed out on the phone; on the
# desk, RIFTGATE_TUNE=1's TRACE knob does the same live. A debug build's KEYWORD INK sets the terms in shown text
# bold in ink with their icons alone in their colour, against the words in their colour, to compare on the phone.
# RIFTGATE_HUD=<green|amber|blue> forces the HUD colour for a run (any run), to judge a mark against every option.
# RIFTGATE_SHOT_WINDOW=1 puts the scene in the window itself instead of a SubViewport, so the
# capture goes through the project's own stretch and font oversampling as the phone's does:
# run with --resolution 1080x1920 for a 1080 phone's density (the screen caps the height).
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn shot.png codex
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn shot.png route
# the quick campaign's screens: draft, picked, hangar (RIFTGATE_SHOT_H=3000 shows the stores at its foot),
# chooser, fight, track, rewards, over
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/quick/quick_run_screen.tscn shot.png hangar
RIFTGATE_SHOT_H=1616 RIFTGATE_SAFE=80,48 RIFTGATE_SHOT_SCALE=1.5 godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn phone.png
# the die's iconography on one sheet (every main mark and what it holds, whom a piece reaches, the
# rest of a face's marks), at the phone's density (1.5 device pixels a design pixel; a second argument sets
# another); in a cloud session under xvfb-run -a
godot --path . --rendering-method gl_compatibility -s tools/die_sheet.gd -- build/die_sheet.png

# build ally units from their briefs (tools/lowforge/models_low.py), then re-import
tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger sparrowhawk clydesdale baboon armadillo wild_boar prairie_dog dingo goshawk nemesis ammit stingray puffin funnel_web skua needletail storm_petrel giant_petrel musk_ox cassowary cottonmouth swallowtail whip_scorpion
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import
godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva hero.png front 480 480   # front, rear, or a yaw in degrees
godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd     # the battle map's ms per frame and draw calls, at zoom 1 and full zoom, with the 3D views' own (the map's world, its machines' layer)
godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd -- skirmish   # the skirmish's, with each machine's view; RIFTGATE_WELD=off on either counts the machines' parts unwelded (any run: every part drawn as authored, to compare; on the phone, a debug build's settings carry the same switch as WELD)

# export the enemy sprites from the grids in docs/sprites-enemies.html to art/foes, then re-import
tools/spriter/.venv/bin/python tools/sheet_export.py
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import

# better enemy sprites from an image model on the Mac (see tools/foeforge/README.md). The picker page
# (https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei): Ryan's picks and notes land in its `picks` collection ({pick, note, set, at}
# a set key), read with ArtifactData `list`.
# Cut each pick with `forge.py cut` and the options it needs (--tol 90 a grey ground shadow, --glow a coloured glow, --height 42 on
# every chibi so the party stands at one scale; pockets of pure white key by default, --holes 0 keeps them, and --keep-glow X0 Y0 X1 Y1
# keeps white-hot light the background's white inside that box of the render, Surtr's blade and blaze), record it in picks.json. A flaw his
# note names is tried first with `forge.py fix` (the edit model on the picked source, four candidates into out/<foe>_fix). Rebuild the
# page for a round with `forge.py phone --tags <the round's tags> --only` and republish out/phone/index.html to that URL with `root`
# set, its new renders/ in `files` and the last round's renders as null (two publishes when the two pass 255 files); a republish keeps
# the picks. Every candidate's source render lived only in tools/foeforge/out on Ryan's Mac (git-ignored); the seventh round's
# were force-added under it (fb45141, 19 October), and once they were cut (26 October) only the Augur's stayed, for her next pass (the
# rest: git show fb45141). Rendering needs the Mac.
tools/foeforge/.venv/bin/python tools/foeforge/forge.py phone --only --tags heroart16 chibi_heroart16 --keys augur_heroart16 augur_chibi_heroart16   # the Augur's seventh-round sets (19 October), where her next pass starts, as a phone page in out/phone
tools/foeforge/.venv/bin/python tools/foeforge/forge.py fix tools/foeforge/picks/sandworm.png sandworm "its head has no eyes at all"   # one fix, four candidates
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate warrior --chibi --variants --tag takesF   # a hero's chibi from its takes (drop --chibi for the boss register)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py prompts                                   # every foe's prompt into tools/foeforge/prompts.md, no model needed (runs anywhere)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate revenant --n 4
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/revenant/revenant_3.png revenant
tools/foeforge/.venv/bin/python tools/foeforge/forge.py rift --n 4                                   # the rift's vortex, the same way
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut-rift tools/foeforge/out/rift/rift_3.png  # three frames into art/terrain/rift.png

# a recolour's sprites from its base's (the ladder's palette swaps, 28 October): a hue shift on the
# saturated pixels, the greys tinted where a tint is given, the outline, the whites and the alpha kept;
# --all rewrites every recolour in its table (a base's sprite changed, or a pair taking a lightness step).
# Then the import. Runs anywhere with numpy and Pillow (the spriter venv has both).
tools/spriter/.venv/bin/python tools/recolour.py goblin goblin_guard --hue 240 --light 0.8 --tint 0.45
tools/spriter/.venv/bin/python tools/recolour.py --all

# rough placeholder sprites, a reminder each, for the bosses and parts with no picked render (30
# October): a few flat shapes at the cut's sizes, outlined, a yellow "?" in a corner; only the
# foes with no art unless named or --force. Then the import. Pillow alone.
python3 tools/placeholder_art.py

# the gate and wall are built the same way
tools/spriter/.venv/bin/python tools/lowforge/forge.py build gate wall
# joints are code too: `with b.joint("shoulder_l", pivot, axis="pitch", limits=(-12, 40)):` in models_low.py hangs a limb under a
# joint_<name> Empty, nested where it rides another; `b.act(name, seconds, {joint: [(t, degrees), ...]}, body=, glow=)` at the end of a
# machine writes its idle acts to art/models/<id>.rig.json with the joints. Judge them running:
RIFTGATE_ACTS_DEBUG=1 godot --path .            # every act back to back in the skirmish and on the map (=<act name> loops one)
RIFTGATE_MOVE_DEBUG=1 godot --path .            # every machine driven constantly: the walks, wheels, treads and held poses (`b.gait(...)` in models_low.py); the cornering (the Dingo's drift, the banks) needs a real move
# a model may show a count and a status: `b.count(source, parts)` lights the first n of its parts for the number the game passes
# (`shots`, the counted shots toward the sixth; `ammo`, the magazine), a falling number flaring them all dark (the Cassowary's
# capacitor); `b.spin_held(status, joint, speed)` turns a joint while the machine carries that status (its capacitor, Spun Up)
# `b.spin(joint, idle, moving, step=60)` gives a spinner its pitch, and an act naming `locks=[joint]` parks it on the next step ahead
# and holds it while the act plays, the act's turn folded into the spin as it ends (the Cottonmouth's drum, stopped on a chamber to fire)
RIFTGATE_COUNT_DEBUG=1 godot --path .           # every count display counts up a part a second until it falls
RIFTGATE_SPIN_DEBUG=1 godot --path .            # every status's spin held in turn, then let go
godot --path . --resolution 360x640 --position 2000,2000 -s tools/act_shot.gd -- badger minerva test_claw 1.4 claw.png front   # one act frozen 1.4 s in; "gait 0.5" freezes a stride, "lose 3" its slump 3 s after it is lost, "fire:spotting_flare 2.9" that weapon 2.9 s after it fires (its slice and what it launches)
godot --path . --resolution 360x640 -s tools/gait_clip.gd -- clydesdale wainwright_sutler clip/clydesdale 8 front 480x400 trot   # a machine walking at its map pace, every frame a PNG (a gait option by name, "-" for its own); then ffmpeg -framerate 30 -i clip/clydesdale_%04d.png -pix_fmt yuv420p clydesdale.mp4
# with no Blender installed (a cloud session): a python3.11 venv with `pip install bpy==5.0.1`, then
BPY_PYTHON=.bpy/bin/python tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger
tools/spriter/.venv/bin/python tools/lowforge/glbcmp.py art/models/badger.glb /tmp/badger.glb   # a rebuild's geometry against the committed file
# the silhouette classes a swapped component wears at a gun mount (models_low.SHAPES) and their variants (VARIANTS: the round
# launcher, which a mount's `fits` may declare for its class), every maker's metal, then re-import
tools/spriter/.venv/bin/python tools/lowforge/forge.py shapes
# one machine wearing swapped components on its mounts ("2:" bares a mount; armour and vents show nowhere); a class alone: <chassis> shapes/barrel_minerva; rendered bare
RIFTGATE_FIT="1:photosphere_lance,4:blazethrower" godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva fit.png front 480 480
# the fit sheet: every machine's stock, then each class on all its mounts at once, a row a machine, into one PNG (about a minute
# for all of them); run it after a model's mounts change, before the model goes to Ryan; name chassis to sheet only those
godot --path . --resolution 360x640 --position 2000,2000 -s tools/fit_sheet.gd -- fit_sheet.png [armadillo goshawk] [--cell 220]
# a proposal's look test (tools/lowforge/looks/, never content): built like a unit, rendered at a set yaw and pitch (180 75 is from above,
# nose up), then the art/models/wslook_* and ktlook_* files deleted again
$BPY_PYTHON tools/lowforge/looks/build_look.py -- --model wslook_deck --out art/models/wslook_deck.glb --tiles /tmp/tiles
godot --path . --resolution 360x640 -s tools/lowforge/looks/look_shot.gd -- wslook_deck wainwright_sutler deck.png 180 75 520 520

# every sound and the six music tracks into art/audio (forge.py SHIP: the console from palette_sketches.py,
# the iron, rift and red from fx_sketches.py's third cut, each as Ryan heard it; the loops from forge.py), then re-import
tools/spriter/.venv/bin/python tools/soundforge/forge.py build          # or: build effects (all but the loops), or: build ui_tap kill music_far_bank
tools/spriter/.venv/bin/python tools/soundforge/voice_lines.py ship     # Jenny's lines into art/audio/voice at 24 kHz with lines.json (the pools, chances and signals the game reads), then re-import
perl -e 'alarm 300; exec @ARGV' godot --path . --resolution 360x640 -s tools/sound_smoke.gd   # every sound hook run with a window, muted (headless, Sound is a no-op): a SCRIPT ERROR in the log is a broken hook
tools/spriter/.venv/bin/python tools/soundforge/phone_sketches.py [set]  # A/B sketches of one change at a time for the phone's speaker, as AAC into tools/soundforge/out/phone/ with a listening page (index.html) to publish
tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py [all]   # every track as a pair (24 and 28 October): each track's new half on its shipped recipe's own groove call (map halves for Hold The Line, Full Bore, The Far Bank and The Crossing, battle halves for Night Shift and Low Ground), each pair as one stereo file for the page's live switch, and Hold The Line's run as the game would play it, as AAC into tools/soundforge/out/pairs/ with the page (index.html) to publish; a missing half is rendered first, `all` renders every new half again, `render <track>` one track's new half alone (a process a track runs them side by side)
tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py [set ...]   # Hold The Line's thirteenth round (3 November), the pair as Ryan settled it: the battle half (the loop without J, V and Q kept, the first lift on the crunch synth and the synth lead and the second on the crunch synth and the lead guitar over a quieter backing guitar, M as it ships with the crunch synth, K's first eight bars at its slower tempo on the drums in between with the plucked string 3 dB down beside the crunch synth on the walk and its long crash choked to a second and a half) and the map half minimal (both lifts as they were with the riff on the tine piano, the first lift's bell once a bar, K's walk on the synth bass over its backing, the climax without the harp, the ticking guitar alone on its riff 3 dB up, the bell 3 dB down, the tine piano on Z's riff 6 dB down, the drone held level into Z); the pair and an A/B set of the map's climax (mz: the drone into Z as the twelfth round had it or held level) through one master, as AAC into tools/soundforge/out/pairs/ with hold13.json for the pair page (`full` for the pair; no argument runs everything, about seven minutes on four cores)
tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py [set ...]  # Night Shift's tenth round (3 November): the battle half as a whole jam in turns of two bars (the guitar and the bass walking one line on Ryan's rhythms with the arpeggio or the hook, holding three-three-two 6 dB down under both, the synth lines voiced for each turn's job, the intro on three-three-two, D the piano's turn and the factory's blended over Hold The Line's riff as the map's nod, R a sixteen-bar jam whose turns hand the lead round the band, the bass on the synth bass 3 dB down everywhere) beside the second round's map half without its muted guitar as a full pair, an A/B set of the whole battle half on the driven bass, the synth bass or a slap bass (b) and one of the map's groove with and without its muted guitar (m), with night10.json for the pair page
tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py   # The Far Bank's map half, its fourth round (3 November): the first round's with the bells at half speed and one echo in the groove and the lift, and the strings section and the climax re-voiced (the violins' tune on one lead over the harp's arpeggios, one note at a time, 3 dB under the violins' level in the strings section, the horns' break-ins on the bells, a soft sub for the cellos and the contrabass, the choir for the string pads, the climax's bells full) under the shipped battle half as a full pair, and A/B cuts of the strings section (fe) and the climax (fg) with the tune on the plucked string, the tine piano or the clean guitar on one string against the third round's pair, with far4.json for the pair page
tools/spriter/.venv/bin/python tools/soundforge/fx_sketches.py [singles|sequences]   # every effect sketched again beside the shipped one, and four rounds in context, as AAC into tools/soundforge/out/fx/ with the listening page (index.html) to publish (AAC by afconvert on the Mac, by ffmpeg at 256 kbps elsewhere, since ffmpeg's encoder smears a transient's front at 128; numpy and scipy are all it needs)
tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py [track]   # every track's melodic parts as notes, one JSON per track into tools/soundforge/out/desk/, for the Melody Desk page's store (collection `parts`)
tools/spriter/.venv/bin/python tools/soundforge/forge.py measure        # each file's loudness, peak and share under 150 Hz
tools/spriter/.venv/bin/python tools/soundforge/forge.py sections       # every section of every track, with timestamps
tools/spriter/.venv/bin/python tools/soundforge/forge.py sketch map_88  # eight-bar sketches and variants, to tools/soundforge/out (not shipped)
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import

# the game on a phone, without an Android export: a Web build served over the LAN (https,
# with a certificate the script makes: accept the browser's warning once). Open the printed
# address in the phone's browser on the same Wi-Fi; the first button press goes full
# screen. Sizes and touch are the phone's own, the frame rate is the browser's.
# Needs the 4.8-beta2 export templates once: fetch Godot_v4.8-beta2_export_templates.tpz
# from the release (github.com/godotengine/godot-builds/releases/tag/4.8-beta2), unzip, and put
# its `templates` folder at ~/Library/Application Support/Godot/export_templates/4.8.beta2 (on
# the Windows PC, editor_data\export_templates\4.8.beta2 beside the Godot executable). On Windows the first serve asks Windows
# Firewall to let Python take connections: allow it on private networks.
tools/phone.sh          # export then serve; `tools/phone.sh serve` serves the last export

# the real thing: a debug APK exported, installed over USB and launched (USB debugging on
# the phone). Beyond the templates this needs the Android SDK at ~/Library/Android/sdk
# (brew install --cask android-commandlinetools, then sdkmanager "platform-tools"
# "build-tools;36.1.0" "platforms;android-36"), a JDK (brew's openjdk does; Godot's
# editor settings point export/android/java_sdk_path at it) and the debug keystore
# (keytool, at the path Godot's editor settings name). All of that was set up on the Mac,
# at 35 for Godot 4.7: 4.8 refuses to export without build-tools 36.1.0 and platform 36.
# On Windows, where it is set up now: the SDK at ~/Android/Sdk, out of AppData (Google's
# command-line tools unzipped to cmdline-tools\latest, then `android sdk install platform-tools
# build-tools/36.1.0 platforms/android-36`: the Android CLI replaced sdkmanager in 2026 and
# names packages with slashes; pass --no-metrics, it reports usage otherwise), Temurin's JDK 17
# unzipped under %LOCALAPPDATA%\Programs\Eclipse Adoptium (an unzip, so the Java 8 this PC's
# other software opens .jar files with stays the default), and the keystore in Godot's
# editor_data\keystores. The export needs no NDK (no Gradle build). A phone
# holding a build signed on the Mac refuses this machine's until that build is uninstalled.
tools/android.sh        # export, install, launch; `tools/android.sh log` tails the phone
# after a crash on the phone: the abort and its backtrace; and the app's memory while it
# runs (Native Heap and EGL/GL mtrack are the columns that climb when something leaks;
# on the Windows PC, adb is ~/Android/Sdk/platform-tools/adb)
~/Library/Android/sdk/platform-tools/adb logcat -d -b crash | grep -A 12 "Abort message"
~/Library/Android/sdk/platform-tools/adb shell dumpsys meminfo com.publabs.riftgate
```

The skirmish screen runs top to bottom: header with the round tag and MENU, enemies in two
ranks of four, log with the controls' switch and the intent eye at its right, dice with the
wide Reroll right under them, mechs at the bottom with their gauges above the sprite, End turn
bottom-left and Withdraw bottom-right; the setting Skirmish Controls at
Bottom (or the switch, mid-fight) stands the mechs right under the enemies and puts the log,
dice and Reroll below them. Both sides stand on one field seen from behind the mechs: the
other world far, under the enemies, our ground near, the mechs in four fixed hexes of its grid
turned a little toward the middle (a squad of one or two in the middle hexes, three from the
left), each die in its mech's column. No unit names on screen. Under each foe sits its intent as a fantasy icon and number (a sword for
the attack) and its statuses (burn, suppressed, exposed) as chips. Under each mech sit its
statuses and warning signs: a broken shield when incoming damage will break it, a crack when
a hit that big may destroy a component, a skull when the round would wreck it, a thermometer
when the current face would overheat. The gauges pulse over the part about to change and the
warnings update as you act, so shielding or killing an attacker clears them at once. Tap a
die to read the entry showing (its effects a line each, each term tappable for what it means;
the readout a beat after the tap, the die lit meanwhile, so a double-tap never flashes it; tap
again to close it; double-tap the machine for the whole die), double-tap or hold a die to lock
it, drag a die onto a foe to spend an attack face or onto a mech to spend a shield or vent face;
valid targets light up while dragging. A Swap waits on its first target for a tap on its second;
a tap on the ground sends it home to the tray. Read or drag an ambusher's die (the funnel-web's)
and the foes' ground dims: the foes its entry can reach that show no intent on it get pulsing
eyes, the ones its blows bite.
Keywords float beside each die as annotation tags. A weapon's number flashes over the target
as it lands. Reroll up to three
times per round, before or after attacking; a reroll lands on any other face, never the
one showing; a copy of it may come up. End turn runs the enemy: its turn replays blow
by blow at the ENEMY PACE setting, the struck mech's gauges stepping down as each lands,
and then the next round's dice show. Tap a foe or a mech for its
numbers, its statuses with icons and text, and the intent arrows that concern it, and tap it
again to close it (one readout at a time, a die's included; a tap on nothing closes it too);
the eye shows every arrow; double-tap any unit for its codex entry; MENU's KEYWORDS lists every
keyword. A fight ends in the pack's fall or the team's: there is no withdrawal. Blank faces
are discarded at end of turn. MENU pauses: resume, settings, or quit to the harness. A
battle started from the harness is saved after every change (`user://battle.json`, written
by `sim/save.gd`: the map by its seed, every unit, the player's turn (who has moved and
fought, the fights hunters forced) and the fight under way with its dice and random streams), so quitting or a phone killing the app
loses nothing: Resume battle opens it where it stood, straight into the fight if one was
on. A decided battle clears the save. Standalone scene runs and the tests never write it.

The harness's FIGHT tab can add any faction's boss; a massive foe fills both ranks of a column. For the
standalone screen, `RIFTGATE_FOES=warrior,goblin:3,white_mage` puts any foes on by id and count (heroes included), `RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,baboon` picks the team and
`RIFTGATE_BOSS=1` adds the faction's boss, `RIFTGATE_TERRAIN=<ground>` dresses the field, and
`RIFTGATE_SKIRMISH_CONTROLS=bottom|middle` places the controls over the saved setting.

The screens are laid out for 720 by 1280 and the window expands its height to the phone's
(stretch aspect `expand`): the battle screen gives the extra to the map, the skirmish
spreads its rows. Pinch is read from the two fingers themselves, so it works in a browser
too.

The battle screen is the loop (bible section 4, the round row). The header shows the turn and
how many turns until the rift spawns; the gate's integrity is a bar on the wall and the rift's
pressure a bar above the rift. The map scrolls by drag, zooms by pinch or wheel, and starts at
the gate end. Purple lines are where each pack will walk on the enemy's turn, from where your
machines stand now: a pusher toward the gate, a hunter (target rings on its prey) toward its
prey; packs go round machines and never stop at one. Tap a machine to select it and the hexes
it can reach light up; tap a lit hex, or drag a route from it, and it moves there at once,
staying in hand while it can act; UNDO MOVE takes the move back until it fights. With a
machine in hand, tap a pack (or drag the machine onto it) and it moves into range and is
ordered onto that fight; tap the pack again to take the order back. The map shows the next
fight: its target and the machines ordered in (one pack is one fight: nothing joins it). The bottom-left
button reads ENGAGE while a fight is ready and dives the map onto it, handing over to the
skirmish screen. A fight spends a machine's action until the next turn (the Dingo has two). A hunter that ends its
walk beside its prey has caught it: the next turn opens with a CAUGHT band, and that fight is
the next one ENGAGE opens. END TURN plays the enemy's turn: the packs walk, a pack beside the gate strikes it, and Rift
Pressure ticks; nothing returns on the map, since the shield is full as every fight opens. The skirmish's Back button
applies the result: wrecks leave the map, packs shrink to their survivors; Rift Pressure ticks on the map's enemy turns only, never
inside a fight. The battle ends when the gate falls, every mech is wrecked, or the boss
dies. Hold any unit for its numbers; double-tap it for its codex; tap the gate for its
integrity. MENU on either
screen pauses and holds the settings (display colour, brightness, move pace, enemy pace,
glitch, scan bar, skirmish controls, AA mode, and music, effects and voice volume). For the standalone screen `RIFTGATE_TEAM` picks the team and
`RIFTGATE_FACTION=meadow|waste|marsh|peak` the enemy; `RIFTGATE_TUNE=1` shows the
development knob panel.

If a headless tool script errors before it calls quit(), Godot keeps running, so every
headless run sits in a watchdog: `perl -e 'alarm N; exec @ARGV'`, since macOS has no `timeout`.
