# Riftgate (working title)

Portrait-mode tactical hex battler for Android. A few customizable war machines hold the last
city gate against a whole genre invading, the JRPG world's wildlife and its heroes pouring
through rifts, in a roguelike campaign.

The game's rules as they stand are in `docs/rules.md`. The design bible,
`docs/design-bible.html`, records every decision, recommendation and open question, and why;
its section 12 holds the questions only Ryan can settle, and the order of work is
`docs/status.md`'s.

## Layout

- `sim/`: the pure simulation. No scene dependencies, a seeded RNG, everything runs headless.
  - `hex.gd` axial and cube hex math, pointy-top pixel conversion
  - `battle_map.gd` the terrain grid, the gate and the rift, and the seeded generator with a
    guaranteed ground path (six shapes, `KINDS`)
  - `unit.gd` machines, packs and city defences on the battlefield
  - `battlefield.gd` the turn's rules on the map: every pack's walk, the fights hunters
    force, who joins a fight, the wall struck, Rift Pressure's peaks
  - `ramp.gd` one table of placeholders by the Convergence and the tier: the compositions on
    the field, the timer, the tears and the seam's creep, the Fractures and their elites
  - `face.gd`, `die.gd` die entries and dice; `foe.gd` an enemy inside a skirmish
  - `skirmish.gd` the dice skirmish: two ranks of foes fed from a pool, reach, keywords, heat,
    shields, the reboot, the outcome
  - `effects.gd` the one pipeline every number is read through: base plus every live modifier
    with a scope and a source, and the passive triggers and effects the engine runs
  - `content_db.gd` loads and validates `content/*.json`, builds dice, machines and foes
  - `refit.gd` the numbers pass's what-ifs, laid over a loaded ContentDB and never the files
    (the runners' `--refit`, the game's `RIFTGATE_REFIT`)
  - `policy.gd` a player for the headless skirmish: a ladder of skill (random, blind, greedy,
    a two-round planner) with personas on top
  - `loadouts.gd` sample dice and packs for prototypes and tests; `harness_setup.gd` what the
    harness launches, kept between launches in `user://harness.json`
  - `battle.gd` one battle end to end: the two turns, the Rupture meter and its Fractures,
    the boss's seal
  - `battle_bot.gd` plays a whole battle headless (the map's defence rule, every fight by
    `policy.gd`), for the campaign runner
  - `campaign.gd` the run: five cities and their gates, rifts rolled as fronts, the roster and
    its shop, salvage, the between-battle rules, the finale
  - `quick_run.gd` the quick campaign: battles without the map, each its fights back to back
    and then its boss, with the loot and the hangar's verbs between
  - `profile.gd` what outlives a run: the pool, the codex, the tier, the favour piece
  - `save.gd` the battle to `user://battle.json` and back, the run to `user://campaign.json`,
    the quick campaign to `user://quick_run.json`, the profile to `user://profile.json`
- `content/`: game data. `vocabulary.json` (every mechanic term; `codex` is the rule as the
  player reads it), `factions.json`, `foes.json`, `chassis.json`, `components.json`,
  `modules.json`, `loot.json` (the field's caches). Placeholder numbers. `reserved_names.json`
  is every machine name in BattleTech, Heavy Gear, Warhammer 40k and Halo: a chassis nickname
  or id on it fails the validator unless the entry records the clash under `design.name_clash`.
- `game/`: scenes and presentation.
  - `harness.tscn` the main scene, four tabs over launch buttons: TEAM (who deploys, each
    machine's hardpoints, modules and upgrade build), BATTLE (a battle as a run deals it),
    FIGHT (a composition fought alone, or one unit built by hand) and SETUP (seed, map
    shape, HUD colour). It also resumes a saved battle and starts or resumes a quick campaign.
  - `settings.gd` the player's settings in `user://settings.cfg`, and a debug build's trial
    dials (below)
  - `battle/` the battle screen (`battle_screen.gd`: the map with the turn around it, the
    panel that sets up a fight, the skirmish screen hosted over it), `battle_map_view.gd`
    (draws the field and reads the gestures), `map_3d.gd` and `painted_map.gd` (the 3D field
    and the painted other world, composited by `bleed.gd`), `map_orient.gd` (MAP VIEW),
    `orders_board.gd`, `top_bar.gd`, `boss_reveal.gd`, `map_tuner.gd`
  - `skirmish/skirmish_screen.gd` the skirmish screen, built in code
  - `quick/quick_run_screen.gd` the quick campaign's screens: the draft, the hangar, the track
    between fights, the rewards and the run's end
  - `ui/` the HUD kit (bars, glyphs, palette, buttons), the die's view, the codex box and the
    pause menu; `mech_view_3d.gd`, `mech_rig.gd` and `mech_weld.gd` (a machine's model, its
    joints and acts from the model's sidecar, its parts welded at load); `colour_tuner.gd` (a
    debug build's COLOURS page: COPY puts the picks on the clipboard as `KEY #rrggbb` lines);
    `terms.gd` (the one table of every term, its icon and colour group) and `keyword_tip.gd`
    (a term's entry, opened by a tap); the feed's effects, the predator sense and the
    skirmish's field (`hud_backdrop.gd`, `battle_backdrop.gd`, `floor_plane.gdshader`)
  - `audio/sound.gd` every sound by name; `audio/voice_lines.gd` Jenny's lines
- `tests/`: headless tests. `run_tests.gd` finds every `test_*.gd` and runs every `test_`
  method, the content validator and a headless drive of the screens among them. A run whose
  tests never ran fails. A `live_test_` method runs on the first frame, for a test that
  routes input as the engine does.
- `tools/`: each script carries its own usage notes at its head; the commands are below.
  - Generated documents: `export_vocabulary.gd`, `pages/bible_tables.py`,
    `pages/bible_merge.py`, `pages/roster_analysis_page.py`, `synergy_map.py`
  - Runners: `balance.gd`, `anchor_read.gd`, `campaign_run.gd`, `battle_run.gd`, `quick_run.gd`,
    `map_survey.gd`
  - Probes: `special_probe.gd` and `chain_probe.gd` (each with a `_read.py`),
    `reboot_probe.gd`, `behaviour_trace.gd`, `death_floor.gd` (where each lost machine lies)
  - Drivers over the balance runner: `stock_loop.py`, `endgame_fours.py`, `pricing_run.py`
  - Models apart from content: `turn_loop.py`, `basics_model.py`, `budget_model.py`
  - Pictures: `screenshot.gd`, `die_sheet.gd`, `hero_shot.gd`, `act_shot.gd`, `gait_clip.gd`,
    `fit_sheet.gd`, `tileset_shot.gd`, `backdrop_shot.gd`, `perf_probe.gd`, `sound_smoke.gd`
  - Art: `lowforge/` builds the machines, the gate, the wall and the caches by code
    (`models_low.py`, one function a chassis; a chassis without one draws the Badger's);
    `sheet_export.py`, `foeforge/`, `placeholder_art.py`, `recolour.py`, `loot_tokens.py`
  - Sound: `soundforge/` builds every sound and the six music tracks from written recipes
  - The phone: `phone.sh` and `android.sh`, with `.cmd` launchers on Windows
  - The hangar page: `hangar.html`, one artifact with seven tabs (the codex, the bench, the
    content editor, the text, the names, the designs, the models), its motion script
    `hangar_motion.js`, and the scripts that write its files: `hangar_data.py` (the files
    map, the models as glTF JSON into `build/hangar/models`), `hangar_designs.py` (the
    briefs) and `hangar_text.py` (every shown text). Ryan's saved edits live in its
    database: `edits` (the content editor and the bench), `candidates` (names), `designs`
    (his corrections to the briefs) and `text` (his texts, marks and notes).
  - `spriter/.venv` is the Python the art and sound tools run with.
- `art/`: `models/` every glTF the engine draws, with a `<id>.rig.json` sidecar beside each
  machine (written by lowforge, read by `mech_rig.gd` and `mech_view_3d.gd`);
  `models/shapes/` the silhouette classes in each maker's metal with `muzzles.json`; `foes/`
  the combat sprites, the 16-pixel map tokens and each boss's 48-pixel picture; `loot/`,
  `terrain/`, `fonts/`; `audio/` every sound by name and `audio/voice/` Jenny's lines with
  `lines.json`. A missing foe sprite falls back to a placeholder shape; a missing sound is
  silence.
- `docs/`: one job each.
  - `rules.md` the rules as they stand; `design-bible.html` the decisions and why, with the
    questions only Ryan can settle in its section 12; `status.md` how things stand and the
    order of work; `todo.md` the tasks, one line each by who moves it; `measurements.md`
    every run a decision cites.
  - Generated: `vocabulary.md` (from the vocabulary), `voice.md` (every shown text Ryan has
    signed as his own, read before a session drafts shown text), `synergy_map.md` (who sets
    and who reads every status and resource), `balance.md`, `campaign_run.md`, `battle_run.md`,
    `quick_run.md` and `map_survey.md` (the runners').
  - Proposals and briefs, each a design's one home until its decisions are rows and content,
    then retired to git: `briefs/` (its README says what each waits on), among them
    `briefs/refit_pass.md` (the reboot's rules, its section 22) and `briefs/numbers_pass.md`
    (tier one sized against the reboot: the yardsticks, the baseline, the defence side's
    approach, the tier-one bench); `economy_pass.md`; `formation_proposal.md` (kept for the
    bosses' stat blocks and the flankers' slate); `locked_pieces_proposal.md`;
    `reboot_machines_proposal.md` (the machines the reboot broke); `bosses_proposal.md` (the
    bosses' and elites' slate); `heroes_proposal.md`; `mechanics_audit.md`;
    `skirmish_audit.md` (the code audit and its order of work); `roster_analysis.md`.
  - Retired, in git: the vocabulary pass's proposal and its table of marks
    (`git show 07f01fb:docs/vocabulary_pass_proposal.md`,
    `git show 07f01fb:docs/vocabulary_table.md`), which is what "the proposal's section N" in
    a bible row or a code comment points at; the targeting page
    (`git show d657a206:docs/targeting_proposal.md`).
  - `sprites-enemies.html` is the sheet the map tokens are exported from; `hangar/` holds
    the hangar page's renders, pins and the text ledger (`text.json`); `looks/` look tests;
    `canvas/` design canvases.

## Running

Open the folder in Godot 4.8 (4.8-beta2 until 4.8 ships, for its MSAA fix), or run from a
terminal. The screens are laid out for 720 by 1280 and the window expands its height to the
phone's (stretch aspect `expand`); the project draws with `gl_compatibility`, the phone's
renderer. How each screen plays is in `docs/rules.md`.

The desk machine is a Windows PC. Every command below runs as written from Git Bash in the
repo folder (`cd ~/Desktop/Code/riftgate` first); from PowerShell, wrap one as
`& 'C:\Program Files\Git\bin\bash.exe' -lc '<command>'`, and the phone scripts have
launchers, `tools\android` and `tools\phone`. Set up there: `godot` and `python3` as shims in
`~/bin` (Godot 4.8-beta2 self-contained under `%LOCALAPPDATA%\Programs\Godot`, its settings,
export templates and debug keystore in `editor_data` beside it; Python 3.13); a `bin`
junction in each venv, so `.venv/bin/python` resolves; `BPY_PYTHON` at `.bpy` (Python 3.11
with `bpy==5.0.1`); `PYTHONUTF8=1`; `core.autocrlf=input`. The tests take about a minute
there. foeforge's `generate` and `fix` cannot run there (the to-do's Art line). The Claude
desktop app is a packaged Windows app: what its sessions write under `AppData`
(`AppData\Local\Programs` excepted) lands in a private copy Ryan's shells never see, so
shared tools live elsewhere and an install is checked from a terminal tab.

A cloud session sets nothing up by hand: the session-start hook
(`.claude/hooks/session-start.sh`, registered in `.claude/settings.json`) fetches Godot
4.8-beta2's Linux build into `~/bin` and runs the first import, once in a container. Anything
that needs a window runs under `xvfb-run -a` with `--rendering-method gl_compatibility`
there. A model's textures ride in its `.glb`, and the import copies each out beside it
(`art/models/<id>_<texture>.png`, its fingerprint in the `.import`) as the file the game
draws, on any machine: a model is committed with the copies the import then writes, and a
texture a fresh import rewrites is one a model left behind, to commit and never to restore
(`tests/test_model_textures.gd` fails the build until it is committed, and on a copy whose
model no longer has its texture).

If a headless tool script errors before it calls `quit()`, Godot keeps running, so every
headless run sits in a watchdog: `perl -e 'alarm N; exec @ARGV'`.

```sh
# first run, and after adding PNGs or a class_name: the import and the script class cache
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import

# the test suite (about four minutes); read the checks' count, never the exit code alone
perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd
perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd -- loot rig   # only the files whose names hold one of those words

# the harness: a battle, a lone fight, a saved battle and the quick campaign
godot --path .
```

### Documents and pages

```sh
# docs/vocabulary.md from content/vocabulary.json, after a vocabulary change
perl -e 'alarm 300; exec @ARGV' godot --headless --path . -s tools/export_vocabulary.gd
# the bible's two vocabulary tables (buffs and debuffs; keywords and their counts), after any content change
python3 tools/pages/bible_tables.py
# the bible republished when another session moved the live page: a three-way merge row by row.
# BASE is the last publish both started from, THEIRS the saved live source with the tool's
# wrapper line, its trailing newline and </body></html> stripped; a row it cannot settle keeps
# conflict markers and is named on stderr
python3 tools/pages/bible_merge.py BASE.html docs/design-bible.html THEIRS.html > merged.html
# who sets and who reads every status and resource, from content (--write rewrites docs/synergy_map.md)
python3 tools/synergy_map.py --write
# the roster analysis as its page (status has the link)
python3 tools/pages/roster_analysis_page.py > /tmp/roster_analysis.html

# the hangar page (https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH)
python3 tools/hangar_data.py              # writes docs/hangar/pins.json and build/hangar/designs.json, checks the renders manifest, prints the files map tools/hangar.html is published with
python3 tools/hangar_designs.py --check   # every brief's hangar header, alone
python3 tools/hangar_text.py              # the Text tab's inventory into build/hangar/text.json, and its counts
python3 tools/hangar_text.py --check      # every string key in content classified, the ledger sound
# after Ryan writes on the Text tab: save the `text` collection with ArtifactData's list (out_dir build/hangar/text_inbox), then
python3 tools/hangar_text.py --fold build/hangar/text_inbox --dry   # what it would change; without --dry it writes his texts into content, his marks into docs/hangar/text.json and docs/voice.md, and prints his notes
# a design session's first step: save the `designs` collection the same way (out_dir build/hangar/inbox), then
python3 tools/hangar_designs.py --fold build/hangar/inbox --dry     # what it would fold; without --dry it writes the briefs and prints the batch that clears them
# a render round: pictures into docs/hangar/renders/<chassis>/, the entry in docs/hangar/renders.json, republish.
# After Ryan edits on the Content tab: pull `edits`, apply by hand, test, commit, republish, clear the documents.
```

### The runners

```sh
# the anchor read: every fight of a tier at its rating (a lone flanker one machine, a hunter's
# pack two, a formation three, an elite and a boss four), by the greedy bot, hull lost as a
# share of a squad of four's: the measure the numbers pass sizes against. It prints markdown
# and writes no file. About a second a fight; split the kinds across cores with only= or kinds=.
# Under each kind's mean it says who paid: each machine's own hull lost a fight, and its wrecks.
# Every squad of the pool is the draw (squads=0, the default): a count of them is uneven by
# machine, and five of the fifteen fours had the Honey Badger in four and the Cottonmouth in two
perl -e 'alarm 3400; exec @ARGV' godot --headless --path . -s tools/anchor_read.gd -- pool=badger,skua,storm_petrel,prairie_dog,cassowary,cottonmouth seeds=5 kinds=patrol
perl -e 'alarm 3400; exec @ARGV' godot --headless --path . -s tools/anchor_read.gd -- pool=badger,skua,storm_petrel,prairie_dog,cassowary,cottonmouth seeds=2 kinds=formation
perl -e 'alarm 3400; exec @ARGV' godot --headless --path . -s tools/anchor_read.gd -- pool=badger,skua,storm_petrel,prairie_dog,cassowary,cottonmouth seeds=2 kinds=elite,boss
#   only=id,id reads those compositions or bosses alone; tier=, ramp=; refit=<spec> lays a
#   what-if over content for the run (refit=barrier=none, the Barrier basic off the stock dice);
#   blows=80 sets every elite's and boss's attack to that share of content's, in hundredths

# the balance report into docs/balance.md: every chassis alone, the starting team and each
# maker's team against every pack, each domain's formation at each tier and the party, random
# and greedy over 200 seeds a cell (hours on one core; about two in four parts)
perl -e 'alarm 36000; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200
# on several cores: --part i/n runs every n-th cell into its --json, and --merge writes the
# report from the parts (the same options on every part and the merge)
for i in 0 1 2 3; do perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200 --part $i/4 --json /tmp/part$i.json & done; wait
perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200 --merge /tmp/part0.json,/tmp/part1.json,/tmp/part2.json,/tmp/part3.json
# its options (the script's head has each in full):
#   --seeds N, --policies random,greedy (blind and planner too; the planner costs about four
#     greedy fights a fight, so run it on the team rows), --out path, --json path
#   --rows badger,team     only those rows; --team badger,kite adds a row of exactly those machines
#   --packs big | rank_and_file | elites | "treant x1,finale"   only those packs, by the JSON's ids;
#     --pack goblin:4+mandragora:2 adds a composed pack; --boss-tiers the bosses by tier; --noparty
#   --trace "kite|goblin x6|greedy|3"   plays that one fight and prints its log
#   --module tactical_databank          every row beside its twin with that module fitted
#   --fit badger=ram_frame,tactical_databank   those modules on every machine of that chassis
#   --set components/arc_fault_cannon/face/keywords=[]   one content value replaced for the run,
#     under components/, chassis/, modules/ or foes/; never validated
#   --bump armour:5 (more of a stat on every machine), --damage F (every blow scaled), --nopassive
#   personas: --cool-above 50 (heat kept under half the maximum), --shield-ahead (a standing
#     shield valued by the blows it turns next round), --guard 0.05 (a block at a twentieth of its worth)
#   what-ifs: --overheat 2 (hull burnt a point past the maximum), --overheat-corrupt 1,
#     --pilot whip_scorpion=1 (heat gained as each round opens)
#   --refit SPEC   the numbers pass's what-ifs over the run's content (sim/refit.gd), comma-separated:
#     hotter=N (every weapon N heat more, negative for cooler), top=N (the basic guns that deal
#     more than the plainest make N more heat), foehp=N (every foe a tier-one formation fields
#     that is no massive has N more hit points), barrier=cooldownN (the Barrier basic sits out N
#     rounds once spent), barrier=heatN (it costs N heat), barrier=none (it leaves the stock
#     dice, the Armoured basic in its slot)
# two reads in the matrix's place, printed, and written to --out when one is given:
#   --packs promise   every patrol, formation and elite composition at each tier, fought by the
#     default four cut to its threat rating, one short and one over (forty minutes at 30 seeds)
#   --packs curve     the same against the four cut to every size from one to four: each cell's
#     band (free, a decision, a wall), hull lost, rounds and stalls (two minutes a seed); --team
#     reads another team in that cut order, and --tiers, --sizes, --domains and --ids narrow it
#   --packs rating    every patrol, formation and elite composition and every boss with its escort
#     at the --tiers given (one by default), each fought by squads of exactly its rating, every run
#     of that many in the --team pool's order; each cell won, rounds and hull lost as a share of a
#     four's hull beside the budget for its rating (about a minute a domain at 5 seeds, greedy)
perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --packs promise --seeds 30 --policies greedy --out /tmp/promise.md
perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --packs curve --seeds 30 --out /tmp/curve.md
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --packs rating --seeds 5 --policies greedy --out /tmp/rating.md

# the campaign runner into docs/campaign_run.md: whole runs played headless by a plain player
# (the front nearest to falling, the map's defence rule, the greedy rung). --runs N, --seed S,
# --policy random, --shape KIND, --out path, --refit and --guard as above; --trace SEED prints one run;
# --muster plays the map by the player that gathers instead (BattleBot.Rule.MUSTER): each pack, in the
# order it reaches the wall, its threat rating's count of the nearest machines, the unsealed boss first
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40

# the battle runner into docs/battle_run.md: one battle of a run (--convergence 1, the second, by
# default; --tier 1) played whole by squads (--squad a,b,c,d, repeatable), --seeds a domain and squad,
# the map by the player that gathers (--rule muster, or defence), --domains to narrow; each cell won,
# the gate fallen, wiped, the Rupture reached, the hull and the wrecks, and a ledger of every fight
# (about twelve minutes on one core)
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/battle_run.gd -- --seeds 20

# the quick campaign's runner into docs/quick_run.md: whole quick campaigns played headless
# by a plain player. --runs N, --seed S, --policy random|planner, --team a,b,c, --out path;
# --trace SEED prints one run. In four parts, then the merge:
for i in 0 1 2 3; do perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/quick_run.gd -- --runs 40 --part $i/4 --json build/quick_$i.json & done; wait
perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/quick_run.gd -- --merge build/quick_0.json,build/quick_1.json,build/quick_2.json,build/quick_3.json

# the map survey into docs/map_survey.md: generated maps measured (each ground's share, the
# water, the horde's narrowest crossing, the phases each way of moving takes, the relief), then
# every shape compared (about fifteen minutes). It defaults to a 9 by 20 field: pass
# --width 20 --height 12 for a battle's own, with --out to keep docs/map_survey.md.
# --type KIND (steppe, river, delta, badlands, city, gorge), --seeds N, --move M; --show SEED prints one map as text
perl -e 'alarm 2400; exec @ARGV' godot --headless --path . -s tools/map_survey.gd -- --seeds 200
```

### Loops, models and probes

```sh
# a balance loop: a copy of the project under build/loops/<name> with one lever moved in its
# content (`levers` lists them), the balance runner on the team rows at 30 seeds in four
# processes, the campaign report unless --no-campaign, and a summary; `compare` lays loops side
# by side. --policies, --packs, --rows, --team, --set, --fit and --alone pass through. Half an
# hour on four cores; a direction, never a band. GODOT names the binary if needed
python3 tools/stock_loop.py run blows --lever blows_by:rf=1.5,massive=1.33,hero=2 --policies random,greedy
python3 tools/stock_loop.py run fours --packs big --rows team:badger+clydesdale+kite+dingo --team badger,clydesdale,kite,dingo
python3 tools/stock_loop.py run built --packs big --set 'chassis/badger/loadout/0="polarity_projector"'
python3 tools/stock_loop.py compare base blows
# the endgame fours: five squads of four fitted up to tier two, through the loop driver
# (random and greedy at 30 seeds; --campaign adds the campaign)
python3 tools/endgame_fours.py endgame30
python3 tools/endgame_fours.py --json > build/endgame_fours.json   # the squads, for chain_probe's --squads
# the pricing run: every stocked piece knocked out of its team row, every slottable component
# and module through the same hardpoint of the benches (BENCHES in the script), every attack a
# heat class up, each variant one balance-runner process, greedy at 30 seeds. `plan` prints the
# variants, `run` is resumable, `summarise` writes build/pricing/<name>/summary.md. --parts
# knockouts,ladders,modules,heat, --benches, --tiers, --packs all|tiers|tier2|tier3, --knock
# basic, --pieces, --modules, --numbers, --shapes, --bench-stocks, --set path=json
python3 tools/pricing_run.py plan
python3 tools/pricing_run.py run prices
python3 tools/pricing_run.py summarise prices
# the vanilla ladder: a flat heatless gun of each shape across numbers and heat on a cold bench and a hot one
python3 tools/pricing_run.py run vanilla --parts vanilla,vanillaheat,ladders --benches prairie_dog,buzzard --pieces flak_cannon,stoker

# models apart from content, seconds each
python3 tools/turn_loop.py --seeds 2000            # the campaign's turn loop from sim/campaign.gd's constants, every battle won: the pressure the fronts put on the cities
python3 tools/turn_loop.py --seeds 2000 --widen 3  # with a rift that steps a tier up once it has bled its city three times
python3 tools/basics_model.py                      # the stock guns against rank and file: shots to kill, the gun that deals one more by its heat, the rider ladder, a bench of guns by its spends to kill five marks
python3 tools/budget_model.py                      # what a fight costs a squad under the reboot, as the hull budget counts it: a horde, a massive in front, a lone flanker, a pack and an elite by blow and hit points, and how far it tracks the bot

# how often each foe special fires: every third starter trio against each domain's formation,
# each boss and each hero alone, as built or with a condition named in OPENED read as true;
# --heat N scales the foes' heat stacks, --only peak,magma keeps the cells named; four parts, then the reader
perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/special_probe.gd -- --out build/special_0.json --part 0/4 --seeds 10 --step 3
python3 tools/special_probe_read.py build
# the machines the reboot reaches, one at a time (docs/reboot_machines_proposal.md): each
# chassis first in a squad beside the Honey Badger, the Prairie Dog and the Cassowary, against
# tier one's formations and elites, or its bosses with --bosses; --only narrows the roster,
# --whatif kite_bot|kite_mends lays a lean over the fight, --branches defence,striker fields the
# machine with those upgrade picks; about seven minutes in four parts of the roster
perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --seeds 8 --only polar_bear,storm_petrel,kite
perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --bosses --seeds 6 --only storm_petrel --branches striker,striker
perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/reboot_probe.gd -- --bosses --seeds 6 --only kite --whatif kite_mends
# formations back to back: every starter trio (--squads fours, or a JSON file of squads) against
# one domain's formation up to nine times in a row, hull and wrecks carried, the shield full as
# each fight opens; --density F scales the formation; four parts, then the reader
perl -e 'alarm 5400; exec @ARGV' godot --headless --path . -s tools/chain_probe.gd -- --squads trios --seeds 2 --out build/chain_0.json --part 0/4
python3 tools/chain_probe_read.py "starter trios" build/chain_0.json build/chain_1.json build/chain_2.json build/chain_3.json
# the behaviour trace, for a change that must change nothing: stock and fitted teams against
# every composition, boss and spawn at each tier, an md5 a line. Run it on main (a worktree) and
# on the change, four parts each (about four minutes), then cmp the two; --fight "<id from a
# .log's ### line>" writes one fight whole
for i in 0 1 2 3; do perl -e 'alarm 3000; exec @ARGV' godot --headless --path . -s tools/behaviour_trace.gd -- --out build/trace_$i --part $i/4 & done; wait
cat build/trace_{0,1,2,3}.hash > build/trace.hash; cat build/trace_{0,1,2,3}.log > build/trace.log
```

### Screenshots

```sh
# a scene to a PNG at 720x1280 (needs a window); a third argument poses the screen first
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn shot.png codex
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn shot.png route
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/quick/quick_run_screen.tscn shot.png hangar
RIFTGATE_SHOT_H=1616 RIFTGATE_SAFE=80,48 RIFTGATE_SHOT_SCALE=1.5 godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn phone.png
# Skirmish poses: codex, mechcodex, termtip, hold (the second die's readout), mechhold, foehold,
# confirm, lock, touch, pair, pair_spread (RIFTGATE_FOES=gel:2,goblin:3), swaphome, acquire,
# strike, enemyturn, plaque, lure_all, rage, repick (RIFTGATE_FOES=wolf:3), columns
# (RIFTGATE_FOES=goblin:4,mandragora:4), chips, essence (RIFTGATE_TEAM=ammit,badger), stores
# (RIFTGATE_TEAM=badger,nemesis,cassowary,swallowtail), heat, foeheat, swallowed, undo, reboot,
# rebootdrag, rounds, logfull, killed, keywords, menu, settings, trials, quit, colours,
# colourpick, groundtear, and the feed's feed_scanbox, feed_databox, feed_readout,
# feed_levels, feed_recalc, feed_wobble, feed_tear, feed_signal.
# Battle poses: select, route, hold, boss, ground, plan_play, execute, endask, inspect, hunter,
# hunted, draft, carry, north, queue, attack, predict, caught, flyer, caches, cachesflat, zoom,
# zoomlast, codex, foecodex, resolve, rift, tear, peak, fracture, elite, foe, onprops, logfull,
# engage, contact, bosscontact, menu, settings, trials, tune.
# Quick campaign poses: draft, picked, hangar (RIFTGATE_SHOT_H=3000 shows the stores at its
# foot), chooser, fight, track, rewards, over.
# The tool's switches: RIFTGATE_SHOT_FRAME=<n> picks the capture frame, to catch an animation
# mid-flight; RIFTGATE_SHOT_H=<design height> renders a taller glass (a 1080x2424 phone is 1616)
# and RIFTGATE_SHOT_SCALE=1.5 at its pixel density (the PNG comes out 1080 wide);
# RIFTGATE_SHOT_WINDOW=1 puts the scene in the window itself, through the project's own stretch
# (with --resolution 1080x1920 for a 1080 phone's density);
# RIFTGATE_SHOT_ZOOM=<z> zooms a battle pose on its first machine; RIFTGATE_HOLD_ENTRY=<place>
# picks the entry the hold pose shows; RIFTGATE_PEAKS=<n> gives the tear pose more peaks;
# RIFTGATE_REVEAL_T=<seconds> pins the boss reveal's frame (bosscontact).

godot --path . --rendering-method gl_compatibility -s tools/die_sheet.gd -- build/die_sheet.png   # the die's iconography on one sheet, at the phone's density (a second argument sets another)
perl -e 'alarm 120; exec @ARGV' godot --headless --path . -s tools/backdrop_shot.gd -- build/backdrops 540 330 86   # the skirmish's backdrops, every domain on every ground (size and horizon in art pixels)
xvfb-run -a godot --rendering-method gl_compatibility --path . -s tools/tileset_shot.gd -- tilesets.png [frame]   # every domain's tileset side by side with a joined range of each look of wall, in the view RIFTGATE_MAP_VIEW names
godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd              # the battle map's ms per frame and draw calls, at zoom 1 and full zoom
godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd -- skirmish  # the skirmish's, with each machine's view
```

### Switches

Each is an environment variable read as a run starts. "Standalone" is a scene run by itself
(the screenshot tool, or `godot --path . <scene>`), not from the harness.

```sh
# What a standalone run fields
#   RIFTGATE_TEAM=badger,clydesdale,kite,baboon   the team (the standalone skirmish and battle screens)
#   RIFTGATE_FOES=warrior,goblin:3,cleric         the skirmish's foes by id and count, heroes included
#   RIFTGATE_BOSS=1                               adds the faction's boss to the skirmish
#   RIFTGATE_COLUMNS=4                            the width of the skirmish's formation
#   RIFTGATE_TERRAIN=<ground>                     dresses the skirmish's field for that ground
#   RIFTGATE_PAINT=badger:ff8800/223344,kite:ffffff   repaints machines in the skirmish (primary/secondary)
#   RIFTGATE_FACTION=meadow|waste|marsh|peak      the battle's enemy domain
#   RIFTGATE_MAP_KIND=gorge, RIFTGATE_SEED=<n>    the battle's map shape (none draws one by the seed) and its seed (7)
#   RIFTGATE_TUNE=1                               the battle screen's development knob panel
# What any run looks like
#   RIFTGATE_SKIRMISH_CONTROLS=bottom|middle      the skirmish's controls, over the saved setting
#   RIFTGATE_MAP_VIEW=left|bottom                 the battle map's turn, over the saved MAP VIEW (the wall at the left, or at the bottom)
#   RIFTGATE_HUD=green|amber|blue                 the HUD colour
#   RIFTGATE_AA=off|fxaa|msaa2|msaa4              the AA mode (the player's SETTINGS, AA MODE; MSAA 4X by default)
#   RIFTGATE_SAFE=<top>,<bottom>                  keeps a phone's safe bands clear
# Numbers on trial (a what-if over content, never a decision)
#   RIFTGATE_REFIT=hotter=-1                      any spec the runners' --refit takes, read as the game starts
#   RIFTGATE_OVERHEAT=2                           the hull an overheat burns a point of heat past the maximum, 1 the game's
#   RIFTGATE_FIELD_DEPTH=14                       the field's rows from the rift to the wall, 10 to 24, 12 the game's
#   RIFTGATE_OPENING=1                            how many more of their own moves from the wall the first packs stand, 0 to 3
#   RIFTGATE_FODDER=50                            the share, in hundredths, of a rank-and-file pack's menace that fills the Rupture meter
#   RIFTGATE_BEATS=3                              the Rupture meter's size in beats of the tide, 1 to 6, 2 the game's
#   RIFTGATE_TIDE=150                             the packs the opening places and each wave sends, in hundredths, 100 the game's
#   RIFTGATE_STRIKE=5                             what a pip of threat rating strikes the wall for, 10 the game's
# The same on the phone, a debug build's SETTINGS, TRIALS (a page that scrolls). Read at the
# next launch, so pick, close the app, open it and start a new battle or run (a saved one keeps
# the numbers it was saved with):
#   HEAT (−2, −1, BUILT, +1)       every weapon cooler or hotter than content prices it (hotter)
#   TOP BASIC (BUILT, +2, +4)      more heat on the basic guns that deal more than the plainest (top)
#   RANK AND FILE (BUILT, +1)      a hit point more on tier one's rank and file, the massive foes as built (foehp)
#   BARRIER BASIC (BUILT, NONE)    the Barrier basic on the stock dice, or the Armoured basic in its slot (barrier=none)
# Read as the next battle starts, or a lone fight for OVERHEAT, with no relaunch:
#   OVERHEAT (×1, ×2, ×3), FIELD DEPTH (12, 14, 16), OPENING (+0, +1, +2), FODDER (FULL, 3/4, HALF),
#   RUPTURE (1 BEAT, 2 BEATS, 3 BEATS), TIDE (×1, ×1.5, ×2), STRIKE (10, 7, 5, 3)
# A thing fired constantly, to judge it running (=1 unless a value is shown)
#   RIFTGATE_FEED_DEBUG       the skirmish feed's analysis events and the ground tears (any run)
#   RIFTGATE_PULSE_DEBUG      END TURN pulsing, on the map and in a fight (any run)
#   RIFTGATE_SEAL_DEBUG       a model's form held and let go in turn: the Polar Bear's seal, the Clydesdale's batteries (any run)
#   RIFTGATE_ACT_DEBUG        one foe after another lit as the acting foe (skirmish)
#   RIFTGATE_RAGE_DEBUG       the rage meter filling and emptying on the machine that banks it (skirmish)
#   RIFTGATE_PREY_DEBUG       the predator sense kept on (skirmish)
#   RIFTGATE_PLAQUE_DEBUG     the plaque with one move name after another (skirmish)
#   RIFTGATE_ALOFT_DEBUG      every foe drawn as out of the dice's reach; RIFTGATE_FOES=roc:1 is the real thing (skirmish)
#   RIFTGATE_DRAIN_DEBUG      a drain announced on the REROLL button and flashed; RIFTGATE_FOES=mandragora:2 is the real thing (skirmish)
#   RIFTGATE_PREVIEW_DEBUG    a rally's pulsing preview chip on every foe showing a blow; RIFTGATE_FOES=wolf:4 is the real thing (skirmish)
#   RIFTGATE_HIT_DEBUG        a blow on a machine every second and a half: hull, shield, armour, a loss (skirmish)
#   RIFTGATE_ABILITY_DEBUG    an ability's chip on every unit that has none (skirmish)
#   RIFTGATE_MINE_DEBUG       a Mine of 3 on every foe as the fight opens (skirmish)
#   RIFTGATE_ESSENCE_DEBUG=12 that much Essence on every machine that banks it (skirmish)
#   RIFTGATE_PEAK_DEBUG       Rift Pressure peaking every enemy turn (battle)
#   RIFTGATE_CACHE_DEBUG      a cache of every kind beside the team and by the rift (a new battle)
#   RIFTGATE_WRECK_DEBUG      a wreck of each of the team's chassis beside it, let go every four seconds (a new battle)
#   RIFTGATE_SHELL_DEBUG      the rift's shell cracking a stretch every 1.2 s through all seven, then bursting (battle)
#   RIFTGATE_BLEED_DEBUG      the whole field given to the painted world (any run)
#   RIFTGATE_ACTS_DEBUG       every act of a model back to back (=<act name> loops one)
#   RIFTGATE_MOVE_DEBUG       every machine driven constantly: walks, wheels, treads, held poses
#   RIFTGATE_COUNT_DEBUG      every count display counting up a part a second until it falls
#   RIFTGATE_SPIN_DEBUG       every status's spin held in turn, then let go
# A look compared
#   RIFTGATE_HALO=off|all     no halo round the lit parts, or one round every lit part
#   RIFTGATE_PLUME=off        a booster's ring in place of its plume
#   RIFTGATE_WELD=off         every part of a machine drawn as authored (a debug build's settings carry it as WELD)
#   RIFTGATE_OUTLINE=<n>      the battle map's machine outline width in design pixels
#   RIFTGATE_INK=dark|light|pulse   the map's trace lines' mode (the map tuner switches it live)
#   RIFTGATE_INTENT_EDGE=1    a pack's intent line with its edge put back
#   RIFTGATE_MECH3D=pixel|off the machines in the pixel look, or as 2D sprites
#   RIFTGATE_MECH3D_MODEL=<id>      another exported model in every slot, to preview it
#   RIFTGATE_MECH3D_FLAT=1, RIFTGATE_MECH3D_WIRE=1   no outline pass; wireframe
```

### Models and sprites

```sh
# the machines from their code (tools/lowforge/models_low.py), then the import
tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger kite clydesdale baboon polar_bear wild_boar prairie_dog dingo buzzard nemesis ammit stingray puffin funnel_web skua needletail storm_petrel giant_petrel musk_ox cassowary cottonmouth swallowtail whip_scorpion
tools/spriter/.venv/bin/python tools/lowforge/forge.py build gate wall
tools/spriter/.venv/bin/python tools/lowforge/forge.py build cache_derelict cache_carcass cache_relic
tools/spriter/.venv/bin/python tools/lowforge/forge.py shapes   # the silhouette classes a swapped component wears, in every maker's metal
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import
# commit the model with the texture copies the import wrote beside it (art/models/<id>_*.png and
# their .import), and delete a copy of a texture the model no longer has; tests/test_model_textures.gd checks both
# with no Blender installed (a cloud session): a python3.11 venv with `pip install bpy==5.0.1`, then
BPY_PYTHON=.bpy/bin/python tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger
tools/spriter/.venv/bin/python tools/lowforge/glbcmp.py art/models/badger.glb /tmp/badger.glb   # a rebuild's geometry against the committed file
# Joints, acts, gaits, counts, spins, hidden mounts and launches are code in models_low.py
# (`b.joint`, `b.act`, `b.gait`, `b.count`, `b.spin`, `b.pin`, `b.launch`); all of it lands in
# art/models/<id>.rig.json.
# A machine's own way down is `b.death(seconds, tracks, body=, glow=, ease=, hang=, plant=)` at the
# end of its recipe, in place of the slump (the bible's death row; act_shot's "lose 3" shows it).
# Where each lost machine lies and whether it rests; --slide how far its standing feet move along the
# floor, --clip the parts that cross as it lies, --try pose variants over its death without a rebuild
perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/death_floor.gd -- [badger,nemesis] [--joints] [--slide] [--clip] [--try variants.json]

godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva hero.png front 480 480   # one unit large: front, rear, or a yaw in degrees
RIFTGATE_FIT="1:photosphere_lance,4:blazethrower" godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva fit.png front 480 480   # wearing swapped components on its mounts ("2:" bares one); RIFTGATE_FORM=<form> holds a form the model has
godot --path . --resolution 360x640 --position 2000,2000 -s tools/act_shot.gd -- badger minerva test_claw 1.4 claw.png front   # one act frozen 1.4 s in; "gait 0.5" a stride, "lose 3" its slump, "fire:spotting_flare 2.9" that weapon after it fires
godot --path . --resolution 360x640 -s tools/gait_clip.gd -- clydesdale wainwright_sutler clip/clydesdale 8 front 480x400 trot   # a machine walking at its map pace, every frame a PNG; then ffmpeg -framerate 30 -i clip/clydesdale_%04d.png -pix_fmt yuv420p clydesdale.mp4
godot --path . --resolution 360x640 --position 2000,2000 -s tools/fit_sheet.gd -- fit_sheet.png [polar_bear buzzard] [--cell 220]   # every machine's stock, then each class on all its mounts; run it after a model's mounts change
# a proposal's look test (tools/lowforge/looks/, never content): built like a unit, rendered at a
# set yaw and pitch, then its art/models/ files deleted again
$BPY_PYTHON tools/lowforge/looks/build_look.py -- --model wslook_deck --out art/models/wslook_deck.glb --tiles /tmp/tiles
godot --path . --resolution 360x640 -s tools/lowforge/looks/look_shot.gd -- wslook_deck wainwright_sutler deck.png 180 75 520 520
# a look round's sheet in one command (15 November): each model a look module's SHEET names is built, imported and rendered at
# each view it lists, laid out under its labels into the module's sheet under docs/looks/, and the built models deleted again; a
# new round is a new file in that folder (its LOOKS and its SHEET), found by build_look.py itself. --project <a copy of the
# project> builds, imports and renders there, so several rounds built side by side never meet in one import
$BPY_PYTHON tools/lowforge/looks/sheet.py siege_looks

# the map tokens and the contact sheet from the grids in docs/sprites-enemies.html into art/foes, then the import
tools/spriter/.venv/bin/python tools/sheet_export.py
# each cache's flat map token, from the grids typed in the script
tools/spriter/.venv/bin/python tools/loot_tokens.py [sheet.png]
# a recolour's sprites from its base's: a hue shift on the saturated pixels, the outline, the
# whites and the alpha kept; --all rewrites every recolour in its table. Then the import
tools/spriter/.venv/bin/python tools/recolour.py goblin goblin_guard --hue 240 --light 0.8 --tint 0.45
tools/spriter/.venv/bin/python tools/recolour.py --all
# placeholder sprites stamped "?" for the foes with no art (ids or --force for others). Then the import
python3 tools/placeholder_art.py

# foe sprites from an image model (tools/foeforge/README.md). Rendering (`generate`, `fix`) has
# no machine today; `cut`, `boss`, `prompts` and `phone` run anywhere. Ryan's picks and notes
# live in the picker page's `picks` collection (https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei).
# Cut each pick with the options it needs (--tol, --glow, --height 42 on every chibi, --holes 0,
# --keep-glow X0 Y0 X1 Y1) and record it in picks.json; rebuild the page for a round with
# `phone --tags <tags> --only` and republish out/phone/index.html to that URL
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate revenant --n 4
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate warrior --chibi --variants --tag takesF   # a hero's chibi from its takes
tools/foeforge/.venv/bin/python tools/foeforge/forge.py fix tools/foeforge/picks/sandworm.png sandworm "its head has no eyes at all"   # one fix, four candidates
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/revenant/revenant_3.png revenant
tools/foeforge/.venv/bin/python tools/foeforge/forge.py phone --only --tags heroart16 chibi_heroart16 --keys augur_heroart16 augur_chibi_heroart16   # the Augur's sets, where her next pass starts
tools/foeforge/.venv/bin/python tools/foeforge/forge.py prompts   # every foe's prompt into tools/foeforge/prompts.md, no model needed
python3 tools/foeforge/forge.py boss                              # each boss's 48-pixel picture for the map from its combat sprite (ids after it for some); Pillow and numpy alone
tools/foeforge/.venv/bin/python tools/foeforge/forge.py rift --n 4                                   # the rift's vortex
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut-rift tools/foeforge/out/rift/rift_3.png  # three frames into art/terrain/rift.png
```

### Sound

```sh
# every sound and the six music tracks into art/audio, then the import
tools/spriter/.venv/bin/python tools/soundforge/forge.py build          # or: build effects (all but the loops), or: build ui_tap kill music_far_bank
tools/spriter/.venv/bin/python tools/soundforge/voice_lines.py ship     # Jenny's lines into art/audio/voice with lines.json
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import
perl -e 'alarm 300; exec @ARGV' godot --path . --resolution 360x640 -s tools/sound_smoke.gd   # every sound hook run with a window, muted: a SCRIPT ERROR in the log is a broken hook
tools/spriter/.venv/bin/python tools/soundforge/forge.py measure        # each file's loudness, peak and share under 150 Hz
tools/spriter/.venv/bin/python tools/soundforge/forge.py sections       # every section of every track, with timestamps
tools/spriter/.venv/bin/python tools/soundforge/forge.py sketch map_88  # eight-bar sketches and variants into tools/soundforge/out (not shipped)
# sketches for Ryan's ear, each as AAC with a page (index.html) to publish
tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py [all]      # every track as a pair, a map half and a battle half, into out/pairs/
tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py [set ...]  # Hold The Line's pair and its A/B sets
tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py [set ...] # Night Shift's
tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py             # The Far Bank's map half
tools/spriter/.venv/bin/python tools/soundforge/fx_sketches.py [singles|sequences]   # every effect beside the shipped one, into out/fx/ for the listening page
tools/spriter/.venv/bin/python tools/soundforge/phone_sketches.py [set]     # A/B sketches of one change for the phone's speaker, into out/phone/
tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py [track]       # every track's melodic parts as notes into out/desk/, for the Melody Desk page's `parts`
```

### The phone

```sh
# a Web build served over the LAN (https, with a certificate the script makes: accept the
# browser's warning once); open the printed address in the phone's browser on the same Wi-Fi.
# Needs the 4.8-beta2 export templates once (Godot_v4.8-beta2_export_templates.tpz from
# github.com/godotengine/godot-builds/releases/tag/4.8-beta2, its `templates` folder at
# editor_data\export_templates\4.8.beta2 beside the Godot executable). The first serve asks
# Windows Firewall to let Python take connections: allow it on private networks
tools/phone.sh          # export then serve; `tools/phone.sh serve` serves the last export

# the real thing: a debug APK exported, installed over USB and launched (USB debugging on the
# phone). Beyond the templates it needs the Android SDK at ~/Android/Sdk (Google's command-line
# tools under cmdline-tools\latest, then `android sdk install platform-tools build-tools/36.1.0
# platforms/android-36`, with --no-metrics), Temurin's JDK 17 under
# %LOCALAPPDATA%\Programs\Eclipse Adoptium, and the debug keystore in Godot's
# editor_data\keystores. The export needs no NDK. A phone holding a build signed on another
# machine refuses this one's until that build is uninstalled
tools/android.sh        # export, install, launch; `tools/android.sh log` tails the phone
# after a crash: the abort and its backtrace, and the app's memory while it runs (Native Heap
# and EGL/GL mtrack climb when something leaks)
~/Android/Sdk/platform-tools/adb logcat -d -b crash | grep -A 12 "Abort message"
~/Android/Sdk/platform-tools/adb shell dumpsys meminfo com.publabs.riftgate
```
