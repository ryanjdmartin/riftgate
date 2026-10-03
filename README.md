# Riftgate (working title)

Portrait-mode tactical hex battler for Android. A few customizable war machines hold the last
city gate against undead, demonic, and eldritch hordes in a roguelike campaign.

The design bible lives in `docs/design-bible.html` and records every decision, recommendation,
and open question from the design sessions.

## Layout

- `sim/` — pure simulation. No scene dependencies. Seeded RNG. Everything here runs headless.
  - `hex.gd` axial/cube hex math, pointy-top pixel conversion
  - `battle_map.gd` terrain grid, gate, rift, procedural generation with a guaranteed ground path
  - `unit.gd` mechs, packs, city defenses on the battlefield
  - `battlefield.gd` phase resolution: every pack's committed route and its behaviour (pusher,
    aggressive, hunter), player routes, body-blocking, the engagement zones that decide who
    fights, gate damage, Rift Pressure
  - `face.gd`, `die.gd` die faces and dice
  - `foe.gd` an enemy inside a skirmish
  - `skirmish.gd` the dice skirmish: two-rank enemy formation fed from a pool, reach rules,
    keywords, heat, shields, injuries, withdraw, outcome
  - `loadouts.gd` sample dice and packs for prototypes and tests
  - `policy.gd` a player for the headless skirmish, a ladder of skill (random, greedy) with
    personas on top, so balance can be measured over thousands of fights
  - `passives.gd` runs the passive triggers the engine supports (the validator refuses others)
  - `effects.gd` the one pipeline every number is read through: base plus every live modifier
    (passives, rewards, buffs, statuses) with a scope and a source
  - `content_db.gd` loads and validates `content/*.json`, builds dice, mechs, and foes
  - `save.gd` writes the whole battle to `user://battle.json` and reads it back
  - `battle.gd` one battle end to end: plot routes, resolve, open a skirmish per contact
    group, apply the result, until the gate falls, the team is wrecked, or the boss dies
- `content/` — game data: `vocabulary.json` (every mechanic term; `codex` is the rule as the player reads it), `factions.json`,
  `foes.json`, `chassis.json`, `components.json`. Placeholder numbers. `reserved_names.json` is
  every machine name in BattleTech, Heavy Gear, Warhammer 40k and Halo; a chassis nickname or id
  on it fails the validator unless the entry records the clash under `design.name_clash`.
- `game/` — scenes and presentation.
  - `harness.tscn` is the main scene: pick a team, faction, pack size, seed, then Battle
    (the whole loop), Resume battle (the saved one, while one exists), Fight (one
    skirmish), or the map viewer
  - `battle/battle_screen.gd` the battle screen: the map with the phase loop around it, and
    the skirmish screen hosted over it on contact; `battle/battle_map_view.gd` draws the
    field and reads the gestures; `battle/orders_board.gd` the strip under the map;
    `battle/boss_reveal.gd` the boss's contact; `battle/bleed.gd` composites the 3D field
    with the painted other world
  - `skirmish/skirmish_screen.gd` the skirmish screen, built in code
  - `ui/` the HUD kit (bars, glyphs, palette, buttons), the die face view, the codex box, the
    pause menu, `mech_view_3d.gd` (a machine's model with its mounts and joints), `mech_rig.gd`
    (its joints, idle acts and strikes from the model's sidecar), the feed
    effects (`feed_fx.gd`, `tear_layer.gd`)
  - `main.tscn` the battlefield map viewer
- `tests/` — headless tests. `run_tests.gd` discovers `test_*.gd` files and runs every
  `test_` method, including the content validator and a headless drive of the skirmish screen.
- `tools/` — `export_vocabulary.gd` regenerates `docs/vocabulary.md`; `balance.gd` plays every
  chassis and the team against every pack under each policy and writes `docs/balance.md`
  (`--trace` prints one fight blow by blow); `map_survey.gd` measures the map generator over
  many seeds and writes `docs/map_survey.md`; `screenshot.gd` renders a
  scene to PNG at 720x1280; `hero_shot.gd` renders one unit large; `perf_probe.gd` measures
  the battle map's frame cost; `lowforge/` builds the
  ally units by code from a brief (`models_low.py`, one function per chassis id) in the
  mid-nineties 3D register with generated tiles; `sheet_export.py` exports the enemy grids
  in `docs/sprites-enemies.html` to `art/foes/`; `foeforge/` generates enemy candidates with
  an image model and cuts one into `art/foes/`; `soundforge/` builds every sound and the
  six music tracks from written recipes (numpy); `phone.sh` puts a Web build on a phone
  over the LAN, `android.sh` the real debug APK over USB; `hangar.html` is the
  hangar page, one artifact with five tabs (the codex, the content editor, the names list, the
  renders, and the animation viewer, whose script is `hangar_motion.js`, a port of the game's
  rig), published with the `files` map `hangar_data.py` prints (it also writes each built
  model as glTF JSON into `build/hangar/models`, since an artifact serves no .glb): each `content/<file>.json`
  at that same path as the shipped content every tab reads and the editor diffs against,
  `hangar/pins.json` (the models' mounts) and `hangar/renders.json` with the renders under
  `docs/hangar/`; Ryan's saved edits live in its database (collection `edits`), the name
  candidates in `candidates`; `spriter/.venv` is the Python
  the tools run with. The gate and wall are lowforge models too (`gate`, `wall`).
- `art/` — `models/` every glTF the engine draws (units, gate, wall) with a `<id>.rig.json`
  sidecar beside each machine (its joints' axes and limits, its idle acts, its cornering
  numbers; written by lowforge, read by `mech_rig.gd`), `foes/` from the sheet
  export, `fonts/` the HUD faces, `audio/` every sound by name (`game/audio/sound.gd` lists
  them). A missing foe sprite falls back to a placeholder shape; a missing sound is silence.
- `docs/` — design bible, generated vocabulary, the hangar page's renders and pins under `hangar/`,
  `sprites-enemies.html` (the enemy sheet the export reads), design canvases under
  `canvas/`, `status.md`, the handoff note updated at the end of every working session,
  and `todo.md`, the task list: one line a task, grouped by who moves it, ticked in the
  commit that lands it.

## Running

Open the folder in Godot 4.7 or later, or from a terminal:

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
# docs/hangar/renders/<chassis>/, the entry in docs/hangar/renders.json, republish)

# regenerate docs/vocabulary.md from content/vocabulary.json
godot --headless --path . -s tools/export_vocabulary.gd

# the balance report: every chassis alone and the starting team against every pack and against
# each faction's whole formation in one fight, played by random and by greedy over 200 seeds a
# cell, written to docs/balance.md (about half an hour); the team cells run under both targeting
# rules and a section compares them. --seeds N, --policies greedy, --withdraw 40 (a persona),
# --targeting lowest (the rule before 2 October for the matrix), --json out.json for every cell;
# --trace "sparrowhawk|brute x4|greedy|3" plays that one fight and prints its log instead.
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200

# the map survey: 200 generated maps at the game's 7x20, measuring the water (share, bodies,
# which feature), the horde's narrowest crossing and what the guarantee opened, and the phases
# each way of moving takes to the rift at move 30; written to docs/map_survey.md (under a
# minute). --seeds N, --move M, --w/--h for another size; --show SEED prints one map as text.
perl -e 'alarm 600; exec @ARGV' godot --headless --path . -s tools/map_survey.gd -- --seeds 200

# screenshot a scene (needs a window; a small one opens briefly); an optional third argument
# poses the screen first. Skirmish: codex, mechcodex, hold, confirm, lock, strike,
# enemyturn, withdraw, rounds, logfull, killed, acquire, menu, settings, quit, and the feed's
# events feed_scanbox, feed_databox, feed_readout, feed_levels, feed_recalc, feed_wobble, feed_tear, feed_signal,
# and groundtear (the corrupted side's tear as it fires).
# Battle: select, route, draft and draftslow (a route drawn by hand, its move gauge spent or
# stopped by a slow hex), hold, north, zoom, zoomlast,
# flyer, predict, resolve, contact, engage, codex, foecodex, menu, settings, tune, and
# bosscontact (the boss reached: the reveal; RIFTGATE_REVEAL_T=<seconds> pins its frame), logfull (the battle log full screen), gate and foe (the gate or a pack tapped).
# RIFTGATE_SHOT_FRAME=<n> picks the capture frame, to catch an animation mid-flight.
# RIFTGATE_FEED_DEBUG=1 (any run) fires the skirmish feed's analysis events every half
# second and the ground tears every couple of seconds, to judge them by eye.
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

# better enemy sprites from an image model on this Mac (see tools/foeforge/README.md)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate ghoul --n 4
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/ghoul/ghoul_3.png ghoul
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
# with no Blender installed (a cloud session): a python3.11 venv with `pip install bpy==5.0.1`, then
BPY_PYTHON=.bpy/bin/python tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger
tools/spriter/.venv/bin/python tools/lowforge/glbcmp.py art/models/badger.glb /tmp/badger.glb   # a rebuild's geometry against the committed file
# the silhouette classes a swapped component wears at a gun mount (models_low.SHAPES), every maker's metal, then re-import
tools/spriter/.venv/bin/python tools/lowforge/forge.py shapes
# one machine wearing swapped components on its mounts ("2:" bares a mount; armour and vents show nowhere); a class alone: <chassis> shapes/barrel_minerva; rendered bare (RIFTGATE_OUTLINE_KEEP=1 keeps the display's edge)
RIFTGATE_FIT="1:lance,4:blazethrower" godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva fit.png front 480 480

# every sound and the six music tracks, from the recipes in tools/soundforge/forge.py, then re-import
tools/spriter/.venv/bin/python tools/soundforge/forge.py build          # or: build hit kill music_far_bank
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
# ~/Library/Application Support/Godot/export_templates/4.7.2.stable
tools/phone.sh          # export then serve; `tools/phone.sh serve` serves the last export

# the real thing: a debug APK exported, installed over USB and launched (USB debugging on
# the phone). Beyond the templates this needs the Android SDK at ~/Library/Android/sdk
# (brew install --cask android-commandlinetools, then sdkmanager "platform-tools"
# "build-tools;35.0.0" "platforms;android-35"), a JDK (brew's openjdk does; Godot's
# editor settings point export/android/java_sdk_path at it) and the debug keystore
# (keytool, at the path Godot's editor settings name). All of that is set up on this Mac.
tools/android.sh        # export, install, launch; `tools/android.sh log` tails the phone
# after a crash on the phone: the abort and its backtrace; and the app's memory while it
# runs (Native Heap and EGL/GL mtrack are the columns that climb when something leaks)
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
times per round, before or after attacking; a reroll always lands on a different face,
never the one showing nor an equivalent one. End turn runs the enemy: its turn replays blow
by blow at the ENEMY PACE setting, the struck mech's gauges stepping down as each lands,
and then the next round's dice show. Numbers are in tens. Hold a foe or a mech for its
numbers, its statuses with icons and text, and the intent arrows that concern it; the eye
shows every arrow; double-tap any unit for its codex entry. Withdraw is offered at any point
of the player's turn; the enemy's parting blows replay before the team flees. Blank faces
are discarded at end of turn. MENU pauses: resume, settings, or quit to the harness. A
battle started from the harness is saved after every change (`user://battle.json`, written
by `sim/save.gd`: the map by its seed, every unit, the routes, the contacts waiting and the
fight under way with its dice and random streams), so quitting or a phone killing the app
loses nothing: Resume battle opens it where it stood, straight into the fight if one was
on. A decided battle clears the save. Standalone scene runs and the tests never write it.

The harness can add the faction's massive elite, which fills both ranks of a column. For the
standalone screen, `RIFTGATE_TEAM=badger,clydesdale,sparrowhawk,baboon` picks the team and
`RIFTGATE_ELITE=1` adds the elite.

The screens are laid out for 720 by 1280 and the window expands its height to the phone's
(stretch aspect `expand`): the battle screen gives the extra to the map, the skirmish
spreads its rows. Pinch is read from the two fingers themselves, so it works in a browser
too.

The battle screen is the loop. The header shows the round and how many rounds until the
rift spawns; the gate's integrity is a bar on the wall and the rift's pressure a bar above
the rift. The map scrolls by drag, zooms by pinch or wheel, and starts at the gate end. Tap
a mech to select it and the hexes it can reach light up; tap a lit hex to plot the route
there; tap the mech again to clear its route. Routes are planned in the order they are
plotted, so a later machine may end where an earlier one is leaving; re-plotting a machine
puts it last. Hold any unit for its numbers; double-tap it for its codex; tap the gate for
its integrity. Red lines are where each pack goes this round, from the plan as it stands:
every pack commits its route when the round opens and only a body in its path cuts it;
every pack carries an engagement zone (its foe type's radius, drawn red where the pack will
stop: a thin outline when nobody stands in it, tinted and heavily outlined when a fight is
in it), every machine inside a pack's zone fights it, and a machine inside two zones joins
those fights into one. Pushers walk their route whatever you do; an aggressive pack turns
for anything that ends inside its reach, the dashed ring; a hunter wears the target rings
on the machine it has locked and chases it. So who is in is never a surprise. The contact
is marked before Resolve with who is in it and the ground
it will be fought on. Resolve plays the moves, then a CONTACT band, then a panel of the
contacts with portraits; ENGAGE dives the map onto the fight and hands over to the skirmish
screen. Its Back button applies the result: wrecks leave the map, packs shrink to their
survivors, surviving shields recharge, and Rift Pressure ticks once per round fought. The
battle ends when the gate falls, every mech is wrecked, or the boss dies. MENU on either
screen pauses and holds the settings (display colour, brightness, move pace, glitch, scan
bar, music and effects volume). For the standalone screen `RIFTGATE_TEAM` picks the team and
`RIFTGATE_FACTION=undead|demonic|eldritch` the enemy; `RIFTGATE_TUNE=1` shows the
development knob panel.

In the map viewer: drag to scroll the taller-than-screen battlefield, tap without dragging
for the next seed. The gate and rift are three hexes wide and a three-hex boss walks the
north. Escape returns to the harness.

If a headless tool script errors before it calls quit(), Godot keeps running. Wrap runs in a
timeout when scripting them.
