# Riftgate (working title)

Portrait-mode tactical hex battler for Android. A few customizable war machines hold the last
city gate against a whole genre invading, the JRPG world's wildlife and its heroes pouring through rifts, in a roguelike campaign.

The game's rules as they stand are in `docs/rules.md`. The design bible, `docs/design-bible.html`,
records every decision, recommendation and open question, and why; section 12 is the roadmap.

## Layout

- `sim/` — pure simulation. No scene dependencies. Seeded RNG. Everything here runs headless.
  - `hex.gd` axial/cube hex math, pointy-top pixel conversion
  - `battle_map.gd` terrain grid, gate, rift, procedural generation with a guaranteed ground path
  - `unit.gd` mechs, packs, city defenses on the battlefield
  - `battlefield.gd` the turn's rules: every pack's walk on the enemy's turn (a pusher to the
    gate, a hunter to its prey, round the machines), the fights hunters force, who joins a
    fight by ring and who can be committed by attack range, gate strikes, Rift Pressure
  - `face.gd`, `die.gd` die faces and dice
  - `foe.gd` an enemy inside a skirmish
  - `skirmish.gd` the dice skirmish: two-rank enemy formation fed from a pool, reach rules,
    keywords, heat, shields, injuries, withdraw, outcome
  - `loadouts.gd` sample dice and packs for prototypes and tests
  - `harness_setup.gd` what the harness launches (team, loadouts, enemy side, seed, map
    type), built into a battle or a skirmish, kept between launches
  - `policy.gd` a player for the headless skirmish, a ladder of skill (random, greedy) with
    personas on top, so balance can be measured over thousands of fights
  - `passives.gd` runs the passive triggers the engine supports (the validator refuses others)
  - `effects.gd` the one pipeline every number is read through: base plus every live modifier
    (passives, rewards, buffs, statuses) with a scope and a source
  - `content_db.gd` loads and validates `content/*.json`, builds dice, mechs, and foes
  - `save.gd` writes the whole battle to `user://battle.json` and reads it back; the run to
    `user://campaign.json` (the battle under way inside it) and the profile to
    `user://profile.json`
  - `battle.gd` one battle end to end: the player's turn (moves at once, one fight at a time,
    a machine that fought is spent, a hunter's catch first), the enemy's turn, until the gate
    falls, the team is wrecked, or the boss dies
  - `campaign.gd` the run: five cities and their gates, rifts rolled as fronts, the roster
    and its shop, salvage, the between-battle rules, the turn's bleed and drain, the finale
  - `profile.gd` what outlives a run: the pool, the codex, the tier, the favour piece
  - `battle_bot.gd` plays a whole battle headless (the map's plain rule, every fight by
    `policy.gd`), for the campaign runner
- `content/` — game data: `vocabulary.json` (every mechanic term; `codex` is the rule as the player reads it), `factions.json`,
  `foes.json`, `chassis.json`, `components.json`. Placeholder numbers. `reserved_names.json` is
  every machine name in BattleTech, Heavy Gear, Warhammer 40k and Halo; a chassis nickname or id
  on it fails the validator unless the entry records the clash under `design.name_clash`.
- `game/` — scenes and presentation.
  - `harness.tscn` is the main scene, three tabs over launch buttons that stay put: TEAM
    (who deploys, in the order ticked, and each machine's hardpoints, any component on any
    hardpoint), ENEMY (the packs, the boss and a guest faction, loaded from a faction and
    edited from there) and SETUP (seed, map type, HUD colour). Battle plays the whole loop
    with the packs as its formation and its rift's cycle; Fight chains them all with the
    boss into one skirmish; Resume battle (while a save exists) and the map viewer below.
    What was last launched is kept in `user://harness.json` (`sim/harness_setup.gd`)
  - `battle/battle_screen.gd` the battle screen: the map with the turn around it, the panel
    that sets up a fight, and the skirmish screen hosted over it; `battle/battle_map_view.gd` draws the
    field and reads the gestures; `battle/orders_board.gd` the strip under the map;
    `battle/boss_reveal.gd` the boss's reveal; `battle/bleed.gd` composites the 3D field
    with the painted other world
  - `skirmish/skirmish_screen.gd` the skirmish screen, built in code
  - `ui/` the HUD kit (bars, glyphs, palette, buttons), the die face view, the codex box, the
    pause menu, `mech_view_3d.gd` (a machine's model with its mounts and joints), `mech_rig.gd`
    (its joints, idle acts and strikes from the model's sidecar), the feed
    effects (`feed_fx.gd`, `tear_layer.gd`)
  - `main.tscn` the battlefield map viewer
- `tests/` — headless tests. `run_tests.gd` discovers `test_*.gd` files and runs every
  `test_` method, including the content validator and a headless drive of the skirmish screen.
- `tools/` — `export_vocabulary.gd` regenerates `docs/vocabulary.md`; `pages/bible_tables.py`
  writes the bible's two vocabulary tables from content; `balance.gd` plays every
  chassis and the team against every pack under each policy and writes `docs/balance.md`
  (`--trace` prints one fight blow by blow); `map_survey.gd` measures the map generator over
  many seeds and writes `docs/map_survey.md`; `campaign_run.gd` plays whole runs and writes
  `docs/campaign_run.md`; `screenshot.gd` renders a
  scene to PNG at 720x1280; `hero_shot.gd` renders one unit large; `perf_probe.gd` measures
  the battle map's frame cost; `lowforge/` builds the
  ally units by code from a brief (`models_low.py`, one function per chassis id) in the
  mid-nineties 3D register with generated tiles; `sheet_export.py` exports the map tokens and the
  contact sheet from the grids in `docs/sprites-enemies.html` to `art/foes/`; `foeforge/`
  generates enemy candidates with an image model and cuts one into `art/foes/` (the combat
  sprites come from here, not the sheet); `soundforge/` builds every sound and the
  six music tracks from written recipes (numpy); `phone.sh` puts a Web build on a phone
  over the LAN, `android.sh` the real debug APK over USB; `hangar.html` is the
  hangar page, one artifact with four tabs (the codex, the content editor, the names list, and
  the models: each machine live in 3D, its motion and mounts, over the game's renders, whose
  script is `hangar_motion.js`, a port of the game's rig), published with the `files` map
  `hangar_data.py` prints (it also writes each built model and silhouette class as glTF JSON
  into `build/hangar/models`, since an artifact serves no .glb): each `content/<file>.json`
  at that same path as the shipped content every tab reads and the editor diffs against,
  `hangar/pins.json` (the models' mounts) and `hangar/renders.json` with the renders under
  `docs/hangar/`; Ryan's saved edits live in its database (collection `edits`), the name
  candidates in `candidates`; `spriter/.venv` is the Python
  the tools run with. The gate and wall are lowforge models too (`gate`, `wall`).
- `art/` — `models/` every glTF the engine draws (units, gate, wall) with a `<id>.rig.json`
  sidecar beside each machine (its joints' axes and limits, its idle acts, its cornering
  numbers; written by lowforge, read by `mech_rig.gd`), `foes/` the combat sprites foeforge cuts from Ryan's picks and the
  16x16 map tokens the sheet export writes, `fonts/` the HUD faces, `audio/` every sound by name (`game/audio/sound.gd` lists
  them) and `audio/voice/` Jenny's lines with `lines.json` (`game/audio/voice_lines.gd` is
  her system). A missing foe sprite falls back to a placeholder shape; a missing sound is silence.
- `docs/` — one job each. `rules.md` the rules as they stand; `design-bible.html` the
  decisions and why, with the questions only Ryan can settle in its section 12; `status.md`
  how things stand and the order of work, rewritten at every handoff; `todo.md` the tasks, one
  line each by who moves it, ticked in the commit that lands it; `measurements.md` every run a
  decision cites; `vocabulary.md` generated from the vocabulary; `balance.md`, `campaign_run.md`
  and `map_survey.md` generated by the runners; the roster analysis (`roster_analysis.md`, 14
  October, published as a page by `tools/pages/roster_analysis_page.py`, background since the
  go), the design-session briefs that came of it (`briefs/`, one per chassis proposal,
  direction and rework, each the design's one home, with a README; the makers' proposal files
  were folded into them and retired on 15 October), the Kestrel airframes as a canvas under
  `canvas/`, the economy pass's brief (`economy_pass.md`), the bosses' slate
  (`bosses_proposal.md`) and the heroes' pass beyond Final Fantasy (`heroes_proposal.md`), each
  retired once its decisions are rows and content; `sprites-enemies.html`,
  the sheet the map tokens are exported from; the hangar page's renders and pins under `hangar/`,
  look tests under `looks/`, design canvases under `canvas/`.

## Running

Open the folder in Godot 4.7 or later, or from a terminal:

On Windows (the desk machine since 19 October, when the Mac went out of reach) every command
below runs as written from Git Bash; from PowerShell, wrap one as
`& 'C:\Program Files\Git\bin\bash.exe' -lc '<command>'`. What makes them run there: `godot` and
`python3` are shims in `~/bin`, which Git Bash puts first on its path (Godot 4.7.2 under
`%LOCALAPPDATA%\Programs\Godot`; Python 3.13, since Windows' own `python3` is a Microsoft Store
stub); each venv has a `bin` junction to its `Scripts`, so `.venv/bin/python` resolves;
`BPY_PYTHON` points lowforge at `.bpy` (Python 3.11 with `bpy==5.0.1`; `.bpy/` and
`tools/soundforge/.venv-piper/` sit in `.git/info/exclude`); and `PYTHONUTF8=1` is set, since
the tools open text without naming an encoding and Windows would read it as cp1252. Python
writes CRLF there; `core.autocrlf=input` folds it back to LF on commit. perl's `alarm` kills
the engine as it does on the Mac. The tests take about a minute. The first import rewrites
the Prairie Dog's four textures, as in a cloud session: restore them. foeforge's `generate` and
`fix` cannot run there (mflux needs Apple silicon, and the PC has no NVIDIA card).

```sh
# first run only: build the script class cache
godot --headless --path . --import

# run the test suite
godot --headless --path . -s tests/run_tests.gd

# run the harness (skirmish screen and map viewer)
godot --path .

# the hangar page: the codex, the content editor, the names and the renders in one artifact
python3 tools/hangar_data.py        # writes docs/hangar/pins.json, checks the renders manifest, prints the files map
# then publish tools/hangar.html to https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH with that map (a render round: pictures into
# docs/hangar/renders/<chassis>/, the entry in docs/hangar/renders.json, republish); after Ryan edits on its Content tab, pull
# the `edits` collection with ArtifactData, apply by hand, test, commit, republish, clear the documents
python3 tools/pages/roster_analysis_page.py > /tmp/roster_analysis.html   # the roster analysis as the page published to its artifact (status has the link), in the bible's style

# regenerate docs/vocabulary.md from content/vocabulary.json
godot --headless --path . -s tools/export_vocabulary.gd

# the bible's two vocabulary tables (buffs and debuffs; keywords and their counts), from content, after any content change
python3 tools/pages/bible_tables.py

# the balance report: every chassis alone and the starting team against every pack and against
# each faction's whole formation in one fight, played by random and by greedy over 200 seeds a
# cell, written to docs/balance.md (about half an hour); the team cells run under both targeting
# rules and a section compares them. --seeds N, --policies greedy, --withdraw 40 (a persona),
# --targeting lowest (the rule before 2 October for the matrix), --json out.json for every cell;
# --rows badger,team runs only those rows; --team badger,sparrowhawk (repeatable) adds a row of exactly those machines,
# any number, so pairs and fours read beside the trios; --module tactical_databank fits that module to every
# machine (--out elsewhere, then compare against a run without it); for prices, --bump armour:5
# (repeatable: hull, shield, armour, heat, cooling, or damage on every blow) gives every machine
# that much more, --nopassive strips every chassis's passive, and --set
# components/arc_fault_cannon/face/keywords=[] replaces one content value for the run only
# (repeatable, never validated: knock-outs and what-ifs); compare each against the same seeds without;
# --trace "sparrowhawk|brute x4|greedy|3" plays that one fight and prints its log instead.
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200

# the map survey: 200 generated maps at the game's 7x20, measuring each ground's share, the
# water (bodies, which feature), the horde's narrowest crossing and what the guarantee opened,
# the phases each way of moving takes to the rift at move 30 and its reach after two phases,
# then every map type compared; written to docs/map_survey.md (a few minutes). --type KIND
# (mixed, steppe, rubble, badlands, flooded: BattleMap.KINDS) for the detailed report, --seeds N,
# --move M, --w/--h for another size; --show SEED prints one map as text.
perl -e 'alarm 900; exec @ARGV' godot --headless --path . -s tools/map_survey.gd -- --seeds 200

# the campaign runner: whole runs played headless by a plain player (it defends the front
# nearest to falling, hunts the nearest enemy on the map, fights at the greedy rung), measuring
# the campaign's placeholders: runs won, cities fallen, wipes, components destroyed per battle;
# written to docs/campaign_run.md. --runs N, --seed S, --policy random; --trace SEED prints one
# run battle by battle instead.
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40

# screenshot a scene (needs a window; a small one opens briefly); an optional third argument
# poses the screen first. Skirmish: codex, mechcodex, hold, confirm, lock, strike,
# enemyturn, plaque (a foe's named move on the other world's window; RIFTGATE_SHOT_FRAME=7), rage (the rage's roll again, its chip bursting; RIFTGATE_SHOT_FRAME=4), heat (a foe's Burning and Scorched on the first machine with Primed beside them, its die running hotter), withdraw, rounds, logfull, killed, acquire, menu, settings, quit, and the feed's
# events feed_scanbox, feed_databox, feed_readout, feed_levels, feed_recalc, feed_wobble, feed_tear, feed_signal,
# and groundtear (the corrupted side's tear as it fires).
# RIFTGATE_MAP_KIND=rubble (any standalone battle run) picks the map's type; the harness has a picker.
# Battle: select, route, draft and draftslow (a route drawn by hand, its move gauge spent or
# stopped by a slow hex), hold, north, zoom, zoomlast,
# flyer, attack (a fight set up beside a pack), caught (a hunter's catch), resolve (a turn
# ended), contact and engage (the handover into a fight), codex, foecodex, menu, settings, tune, and
# bosscontact (the boss attacked: the reveal; RIFTGATE_REVEAL_T=<seconds> pins its frame), logfull (the battle log full screen), gate and foe (the gate or a pack tapped).
# RIFTGATE_SHOT_FRAME=<n> picks the capture frame, to catch an animation mid-flight.
# RIFTGATE_FEED_DEBUG=1 (any run) fires the skirmish feed's analysis events every half
# second and the ground tears every couple of seconds, to judge them by eye.
# RIFTGATE_RAGE_DEBUG=1 (any skirmish) plays the rage's roll again over and over on the machine
# that spends rage: its chip bursts, then its die flips back with the reroll's sound.
# The phone's layout on the Mac: RIFTGATE_SHOT_H=<design height> renders a taller glass
# (a 1080x2424 phone is 1616), RIFTGATE_SAFE=<top>,<bottom> keeps its safe bands clear
# (any run, not only the tool), RIFTGATE_SHOT_SCALE=1.5 renders at its pixel density (the
# PNG comes out 1080 wide); add --rendering-method gl_compatibility for the phone's renderer.
# RIFTGATE_MSAA=on|off forces the 3D viewports' anti-aliasing (any run; off on a phone by default).
# RIFTGATE_OUTLINE=<n> sets the machines' light outline thickness for a comparison (MechView3D.OUTLINE is the default).
# RIFTGATE_HUD=<green|amber|blue> forces the HUD colour for a run (any run), to judge a mark against every option.
# RIFTGATE_FINE_MAP=1 forces the FINE MAP setting (the map's scene and compositor at the glass's
# density; with RIFTGATE_SHOT_SCALE=1.5 that is a phone's).
# RIFTGATE_SHOT_WINDOW=1 puts the scene in the window itself instead of a SubViewport, so the
# capture goes through the project's own stretch and font oversampling as the phone's does:
# run with --resolution 1080x1920 for a 1080 phone's density (the Mac's screen caps the height).
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn shot.png codex
godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn shot.png route
RIFTGATE_SHOT_H=1616 RIFTGATE_SAFE=80,48 RIFTGATE_SHOT_SCALE=1.5 godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/battle/battle_screen.tscn phone.png

# build ally units from their briefs (tools/lowforge/models_low.py), then re-import
tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger sparrowhawk clydesdale baboon armadillo wild_boar prairie_dog dingo goshawk nemesis ammit
godot --headless --path . --import
godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva hero.png front 480 480   # front, rear, or a yaw in degrees
godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd     # the battle map's ms per frame and draw calls, at zoom 1 and full zoom

# export the enemy sprites from the grids in docs/sprites-enemies.html to art/foes, then re-import
tools/spriter/.venv/bin/python tools/sheet_export.py
godot --headless --path . --import

# better enemy sprites from an image model on the Mac (see tools/foeforge/README.md). The picker page
# (https://claude.ai/artifact/1a2yJbdRMfdpJDYXYQoTei): Ryan's picks and notes land in its `picks` collection ({pick, note, set, at}
# a set key), read with ArtifactData `list` from his personal account; from the work account he taps Copy all picks and pastes it.
# Cut each pick with `forge.py cut` and the options it needs (--tol 90 a grey ground shadow, --glow a coloured glow, --height 46 on
# every chibi so the party stands at one scale; pockets of pure white key by default, --holes 0 keeps them), record it in picks.json. A flaw his
# note names is tried first with `forge.py fix` (the edit model on the picked source, four candidates into out/<foe>_fix). Rebuild the
# page for a round with `forge.py phone --tags <the round's tags> --only` and republish out/phone/index.html to that URL with `root`
# set, its new renders/ in `files` and the last round's renders as null (two publishes when the two pass 255 files); a republish keeps
# the picks. Every candidate's source render lived only in tools/foeforge/out on Ryan's Mac (git-ignored); the seventh round's
# were force-added under it (fb45141, 19 October), so its picks cut and its page rebuilds on any machine. Rendering needs the Mac.
tools/foeforge/.venv/bin/python tools/foeforge/forge.py phone --tags fix fix2 chibi_takesF takesF --only   # the 13 October round as a phone page in out/phone (status has the link)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py fix tools/foeforge/picks/sandworm.png sandworm "its head has no eyes at all"   # one fix, four candidates
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate warrior --chibi --variants --tag takesF   # a hero's chibi from its takes (drop --chibi for the boss register)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py prompts                                   # every foe's prompt into tools/foeforge/prompts.md, no model needed (runs anywhere)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate revenant --n 4
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/revenant/revenant_3.png revenant
tools/foeforge/.venv/bin/python tools/foeforge/forge.py rift --n 4                                   # the rift's vortex, the same way
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut-rift tools/foeforge/out/rift/rift_3.png  # three frames into art/terrain/rift.png

# the gate and wall are built the same way
tools/spriter/.venv/bin/python tools/lowforge/forge.py build gate wall
# joints are code too: `with b.joint("shoulder_l", pivot, axis="pitch", limits=(-12, 40)):` in models_low.py hangs a limb under a
# joint_<name> Empty, nested where it rides another; `b.act(name, seconds, {joint: [(t, degrees), ...]}, body=, glow=)` at the end of a
# machine writes its idle acts to art/models/<id>.rig.json with the joints. Judge them running:
RIFTGATE_ACTS_DEBUG=1 godot --path .            # every act back to back in the skirmish and on the map (=<act name> loops one)
RIFTGATE_MOVE_DEBUG=1 godot --path .            # every machine driven constantly: the walks, wheels, treads and held poses (`b.gait(...)` in models_low.py); the cornering (the Dingo's drift, the banks) needs a real move
godot --path . --resolution 360x640 --position 2000,2000 -s tools/act_shot.gd -- badger minerva test_claw 1.4 claw.png front   # one act frozen 1.4 s in; "gait 0.5" freezes a stride
godot --path . --resolution 360x640 -s tools/gait_clip.gd -- ammit arsenal clip/ammit 8 front 480x400 offbeat   # a machine walking at its map pace, every frame a PNG (a gait option by name, "-" for its own); then ffmpeg -framerate 30 -i clip/ammit_%04d.png -pix_fmt yuv420p ammit.mp4
# with no Blender installed (a cloud session): a python3.11 venv with `pip install bpy==5.0.1`, then
BPY_PYTHON=.bpy/bin/python tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger
tools/spriter/.venv/bin/python tools/lowforge/glbcmp.py art/models/badger.glb /tmp/badger.glb   # a rebuild's geometry against the committed file
# the silhouette classes a swapped component wears at a gun mount (models_low.SHAPES), every maker's metal, then re-import
tools/spriter/.venv/bin/python tools/lowforge/forge.py shapes
# one machine wearing swapped components on its mounts ("2:" bares a mount; armour and vents show nowhere); a class alone: <chassis> shapes/barrel_minerva; rendered bare (RIFTGATE_OUTLINE_KEEP=1 keeps the display's edge)
RIFTGATE_FIT="1:lance,4:blazethrower" godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva fit.png front 480 480
# a proposal's look test (tools/lowforge/looks/, never content): built like a unit, rendered at a set yaw and pitch (180 75 is from above,
# nose up), then the art/models/wslook_* files deleted again
$BPY_PYTHON tools/lowforge/looks/build_look.py -- --model wslook_deck --out art/models/wslook_deck.glb --tiles /tmp/tiles
godot --path . --resolution 360x640 -s tools/lowforge/looks/look_shot.gd -- wslook_deck wainwright_sutler deck.png 180 75 520 520

# every sound and the six music tracks into art/audio (forge.py SHIP: the console from palette_sketches.py,
# the iron, rift and red from fx_sketches.py's third cut, each as Ryan heard it; the loops from forge.py), then re-import
tools/spriter/.venv/bin/python tools/soundforge/forge.py build          # or: build effects (all but the loops), or: build ui_tap kill music_far_bank
tools/spriter/.venv/bin/python tools/soundforge/voice_lines.py ship     # Jenny's lines into art/audio/voice at 24 kHz with lines.json (the pools, chances and signals the game reads), then re-import
perl -e 'alarm 300; exec @ARGV' godot --path . --resolution 360x640 -s tools/sound_smoke.gd   # every sound hook run with a window, muted (headless, Sound is a no-op): a SCRIPT ERROR in the log is a broken hook
tools/spriter/.venv/bin/python tools/soundforge/phone_sketches.py [set]  # A/B sketches of one change at a time for the phone's speaker, as AAC into tools/soundforge/out/phone/ with a listening page (index.html) to publish
tools/spriter/.venv/bin/python tools/soundforge/fx_sketches.py [singles|sequences]   # every effect sketched again beside the shipped one, and four rounds in context, as AAC into tools/soundforge/out/fx/ with the listening page (index.html) to publish (AAC by afconvert on the Mac, by ffmpeg at 256 kbps elsewhere, since ffmpeg's encoder smears a transient's front at 128; numpy and scipy are all it needs)
tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py [track]   # every track's melodic parts as notes, one JSON per track into tools/soundforge/out/desk/, for the Melody Desk page's store (collection `parts`)
tools/spriter/.venv/bin/python tools/soundforge/forge.py measure        # each file's loudness, peak and share under 150 Hz
tools/spriter/.venv/bin/python tools/soundforge/forge.py sections       # every section of every track, with timestamps
tools/spriter/.venv/bin/python tools/soundforge/forge.py sketch map_88  # eight-bar sketches and variants, to tools/soundforge/out (not shipped)
godot --headless --path . --import

# the game on a phone, without an Android export: a Web build served over the LAN (https,
# with a certificate the script makes: accept the browser's warning once). Open the printed
# address in the phone's browser on the same Wi-Fi; the first button press goes full
# screen. Sizes and touch are the phone's own, the frame rate is the browser's.
# Needs the 4.7.2 export templates once: fetch Godot_v4.7.2-stable_export_templates.tpz
# from the Godot release, unzip, and put its `templates` folder at
# ~/Library/Application Support/Godot/export_templates/4.7.2.stable (on Windows,
# %APPDATA%\Godot\export_templates\4.7.2.stable). On Windows the first serve asks Windows
# Firewall to let Python take connections: allow it on private networks.
tools/phone.sh          # export then serve; `tools/phone.sh serve` serves the last export

# the real thing: a debug APK exported, installed over USB and launched (USB debugging on
# the phone). Beyond the templates this needs the Android SDK at ~/Library/Android/sdk
# (brew install --cask android-commandlinetools, then sdkmanager "platform-tools"
# "build-tools;35.0.0" "platforms;android-35"), a JDK (brew's openjdk does; Godot's
# editor settings point export/android/java_sdk_path at it) and the debug keystore
# (keytool, at the path Godot's editor settings name). All of that was set up on the Mac.
# On Windows, where it is set up now: the SDK at %LOCALAPPDATA%\Android\Sdk (Google's
# command-line tools unzipped to cmdline-tools\latest, then `android sdk install platform-tools
# build-tools/35.0.1 platforms/android-35`: the Android CLI replaced sdkmanager in 2026 and
# names packages with slashes; pass --no-metrics, it reports usage otherwise), Temurin's JDK 17
# unzipped under %LOCALAPPDATA%\Programs\Eclipse Adoptium (an unzip, so the Java 8 this PC's
# other software opens .jar files with stays the default), and the keystore at
# %APPDATA%\Godot\keystores\debug.keystore. The export needs no NDK (no Gradle build). A phone
# holding a build signed on the Mac refuses this machine's until that build is uninstalled.
tools/android.sh        # export, install, launch; `tools/android.sh log` tails the phone
# after a crash on the phone: the abort and its backtrace; and the app's memory while it
# runs (Native Heap and EGL/GL mtrack are the columns that climb when something leaks;
# on Windows, adb is %LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe)
~/Library/Android/sdk/platform-tools/adb logcat -d -b crash | grep -A 12 "Abort message"
~/Library/Android/sdk/platform-tools/adb shell dumpsys meminfo com.publabs.riftgate
```

The skirmish screen runs top to bottom: header with the round tag and MENU, enemies in two
ranks of four, log with the intent eye at its right, dice with the wide Reroll right under
them, mechs at the bottom with their gauges above the sprite, End turn bottom-left and
Withdraw bottom-right. No unit names on screen. Under each foe sits its intent as a fantasy icon and number (a sword for
the attack) and its statuses (burn, suppressed, exposed) as chips. Under each mech sit its
statuses and warning signs: a broken shield when incoming damage will break it, a crack when
a hit that big may injure a component, a skull when the round would wreck it, a thermometer
when the current face would overheat. The gauges pulse over the part about to change and the
warnings update as you act, so shielding or killing an attacker clears them at once. Tap a
die to lock it, hold a die to see every face on it, drag a die onto a foe to spend an attack
face or onto a mech to spend a shield or vent face; valid targets light up while dragging.
Keywords float beside each die as annotation tags. Kinetic faces roll their damage when they
land and the number flashes over the target; energy faces are static. Reroll up to three
times per round, before or after attacking; a reroll lands on any other face, never the
one showing, a copy of it included. End turn runs the enemy: its turn replays blow
by blow at the ENEMY PACE setting, the struck mech's gauges stepping down as each lands,
and then the next round's dice show. Hold a foe or a mech for its
numbers, its statuses with icons and text, and the intent arrows that concern it; the eye
shows every arrow; double-tap any unit for its codex entry. Withdraw is offered at any point
of the player's turn; the enemy's parting blows replay before the team flees. Blank faces
are discarded at end of turn. MENU pauses: resume, settings, or quit to the harness. A
battle started from the harness is saved after every change (`user://battle.json`, written
by `sim/save.gd`: the map by its seed, every unit, the player's turn (who has moved and
fought, the fights hunters forced) and the fight under way with its dice and random streams), so quitting or a phone killing the app
loses nothing: Resume battle opens it where it stood, straight into the fight if one was
on. A decided battle clears the save. Standalone scene runs and the tests never write it.

The harness can add any faction's boss; a massive foe fills both ranks of a column. For the
standalone screen, `RIFTGATE_FOES=warrior,goblin:3,white_mage` puts any foes on by id and count (heroes included), `RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,baboon` picks the team and
`RIFTGATE_BOSS=1` adds the faction's boss.

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
fight: its target, the packs whose ring covers it, the machines ordered in. The bottom-left
button reads ENGAGE while a fight is ready and dives the map onto it, handing over to the
skirmish screen. A machine that fought is spent until the next turn. A hunter that ends its
walk beside its prey has caught it: the next turn opens with a CAUGHT band, and that fight is
the next one ENGAGE opens. END TURN plays the enemy's turn: the packs walk, a pack beside the gate strikes it, machines
that did not fight recharge, and Rift Pressure ticks. The skirmish's Back button applies the
result: wrecks leave the map, packs shrink to their survivors; Rift Pressure ticks on the map's enemy turns only, never
inside a fight. The battle ends when the gate falls, every mech is wrecked, or the boss
dies. Hold any unit for its numbers; double-tap it for its codex; tap the gate for its
integrity. MENU on either
screen pauses and holds the settings (display colour, brightness, move pace, glitch, scan
bar, music and effects volume). For the standalone screen `RIFTGATE_TEAM` picks the team and
`RIFTGATE_FACTION=meadow|waste|marsh|peak` the enemy; `RIFTGATE_TUNE=1` shows the
development knob panel.

In the map viewer: drag to scroll the taller-than-screen battlefield, tap without dragging
for the next seed. The gate and rift are three hexes wide and a three-hex boss walks the
north. Escape returns to the harness.

If a headless tool script errors before it calls quit(), Godot keeps running. Wrap runs in a
timeout when scripting them.
