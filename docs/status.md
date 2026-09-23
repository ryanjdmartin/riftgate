# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible.

## As of 23 September 2026 (midday)

**State.** Tests: 187 tests, 2453 checks, green (`perl -e 'alarm 240; exec @ARGV' godot
--headless --path . -s tests/run_tests.gd`). Ryan runs a second session on this repo at
the same time (today: the HUD session and the audio session): check `git status` before
committing and stage by path. The audio session's hunks in `game/ui/hud_button.gd` (the
`sound` property), `game/battle/battle_screen.gd` and `game/skirmish/skirmish_screen.gd`
(buttons with their own sound, the overheat landing) sit in the working tree beside the HUD
session's edits and go in with them. Chassis ids: `badger`, `clydesdale`, `sparrowhawk`, `anvil`. Ryan writes
`content/*.json` in his own voice; tests never hardcode an entry's passive name.

**Where things are.** `sim/` is the headless game (battle map, battlefield resolver,
battle loop, skirmish, effects pipeline, content DB). `game/battle/` is the battle screen
and the map (`battle_map_view.gd` overlays and gestures, `map_3d.gd` the scene, its static
geometry baked into a few meshes by `_bake`, `painted_map.gd` the other world, `bleed.gd` +
`bleed.gdshader` the compositor that mixes them). `game/skirmish/` the fight. `game/ui/`
the HUD kit, the shared codex box, the pause menu, `mech_view_3d.gd` (any model in a
viewport) and `trace_lines.gd` (the display's light on every edge). `game/audio/sound.gd`
plays every sound by name; `tools/soundforge/forge.py` builds them all from recipes into
`art/audio/`. `tools/lowforge/` builds every model by code from a brief; `tools/phone.sh`
exports a Web build and serves it on the LAN for a phone; `tools/screenshot.gd` poses either
screen (`README.md` lists the poses); `tools/perf_probe.gd` measures the map; the
`map_tuner` knobs are behind `RIFTGATE_TUNE=1`. `docs/design-bible.html` records every
decision; section 12 is the roadmap; it is published at
https://claude.ai/artifact/UuMbAAorUyZbtZ1aYKMWNZ (v0.9, republished 23 September;
republish the file to that URL after a bible change).
`docs/vocabulary.md` is generated from content.

**What the game does today.** A battle: the map shows every squad's intent and the exact
result of the plan before Resolve; Resolve plays the moves with footfalls, then a CONTACT
band with its horn, then a panel of the contacts; ENGAGE dives the map and cuts to the
skirmish, the dice fight on the enemy's ground, every blow, shield, kill and overheat heard,
the music dipping under the big ones. Back applies it and the next round plans. The gate has an integrity bar, the rift a spawn bar;
the codex opens by double-tap on either screen; MENU pauses, ducks the music, holds the
settings (music, effects and enemy pace among them) and quits to the harness after asking.
The enemy's turn replays blow by blow with the gauges stepping down, before the next dice
or the outcome, a withdrawal included. The formation is four wide. A map groove plays on
the field and a skirmish groove in the fight, crossfading.

**Done 22 September (late) and 23 September.** The map's draw calls: 5400 and 10.9 ms a
frame at zoom 1 on the Mac became 1036 and about 3 ms by baking rims, columns, grid lines,
props, traces, roads, the gate and the walls into one mesh per material per band of rows;
the three machines stay live models. The map's build: 3.1 s to 0.8 s on the Mac (geometry
as packed arrays, one renderer readback per shape, edges per shape; `map_3d.gd`'s baking
section says why). The phone path without an Android export: `tools/phone.sh`, https with
its own certificate. The real one: `tools/android.sh` exports a signed debug APK
(templates, SDK, JDK and keystore all on this Mac now; README says how) and installs it
over USB; it has not yet been run on a device. The screens follow the phone's height;
pinch from two fingers; roads join on the Compatibility renderer; hex 48. The sound set,
first cut. Trials retired; the bible republished (link above). A placeholder launcher
icon (`art/icon.png`, a tool-drawn hex). Afternoon: the map's frame belongs to the viewport
(lines the view's height, readouts fixed, ticks and numbers scrolling), tighter and with
bigger text, pinned through zoom too; bar labels on plaques; the rift is a foeforge
vortex in four distinct frames (the candidate plus three image-to-image redraws that move
the tendrils, aligned by correlation, chosen by measured likeness), stepping on the
music's beat, torn in bands like the ground round it (bible section 5 row, 23
September; every candidate and frame is in `tools/foeforge/out/rift`).

**Ryan's skirmish notes, 23 September (done).** Four columns locked in. The menu has QUIT
(asks first; `quit_requested` runs harness-ward through the battle screen) and a colour
change keeps the menu up behind a mask while the screen rebuilds (`_build` on both screens
spares `_menu`). Withdraw replays the enemy's parting blows before the outcome; every
enemy turn replays at ENEMY PACE (`Settings.display["enemy_pace"]`, top = the old 0.12 s
beat), each blow stepping the struck mech's shield and hull from the event the sim records
(`turn_events` now carry `shield` and `hull`), taps held off by `_replay_shade` meanwhile.
Layout: ally gauges and chips 10 px off the model, a foe's gauge 16 px above its sprite
with a 16 px leader running onto it, every gauge on a black ground of its own shape (no
plate), the eye 60 px in the black at the log's right with 12 px margins (the log strip
stops short of it), log 112 tall, dice and Reroll up 16, 30 px of black under Reroll. Poses
added to `tools/screenshot.gd`: menu, settings, quit, withdraw, acquire. The bible has the
rows (section 5, and the HUD row in 4) and is republished as v0.8 (link above). Then the
"feed being analysed" pass (bible section 6 row): intents are acquired with collapsing
brackets and a digit scramble (`UnitView.acquire`; Ryan: exactly right), the phase readout
carries a fight clock, the log strip ends in a blinking prompt, and `game/ui/feed_fx.gd`
runs one rare one-shot event every 4 to 9 s on a random unit or die (scanbox, databox,
readout, recalc, tear, signal; poses `feed_<name>` and `groundtear` in the screenshot
tool). The ground tear (`TerrainArt._tear`) is one burst of one to three slices every
eight seconds at most, over part of the width, dimming or shearing (the map's rift shear),
off with the glitch setting like the unit tears. Cut after Ryan saw it: the scan band
lighting gauges, chips, buttons and rules (blinked rather than swept). Ryan's second pass:
the events were far too slow (now about half a second each) and the tears too many and
too often. `RIFTGATE_FEED_DEBUG=1` fires everything constantly for judging; Ryan is doing
that now. Knobs: `FeedFX.WEIGHTS`, `GAP_MIN`/`GAP_MAX`, `DURATION`, `TerrainArt.TEAR_PERIOD`.

**Ryan's verdict on the web harness (23 September).** It served for sizes and touch and no
more: the map must not get smaller (the base hex size may go up a little; zoom makes it
playable as is). Judged real, to fix now: the load time (the first frame builds the map in
3.2 s on the Mac, all GDScript: the feature-edge extraction per prop and the per-vertex
bake loops); the letterboxing (stretch aspect `keep` on a 9:16 design leaves a 9:20 phone
with bars, both screens laid out at fixed 720x1280 coordinates); roads not joining (the
road shader's per-instance parameters are not a Compatibility-renderer feature, and the
phone runs Compatibility); pinch (the map only hears the magnify gesture, which the web
never sends: handle two fingers directly). Not to chase on the web: missing hex outlines
and general frame rate, which want a native build. Then the true Android export.

**Audio (23 September, second cut; bible section 1, sound row).** Ryan's notes on the first
cut: the skirmish loop went missing about half the time (the last crossfade's chained stop
landed on the player the new loop had taken: fixed, verified in a window at every gap);
the loops needed length and complexity, more under and overtones, and read as chip-tune;
the pings were cowbell and anvil where mechanical was wanted. Done: 48 kHz; every thud has
a body pinned to 230 Hz so a phone hears the weight; knocks that die in tens of ms, servos,
hydraulics, relays; stacks and a small room on everything; a loudness target per sound in
`LEVELS` (the mix lives in the forge; hooks carry offsets only for relative moments); the
music dips under big moments (`Sound.DIP`); pitched sounds keep their pitch (`Sound.TONAL`);
a loop resumes where it left; 16-bar forms in sections; buttons with their own sound no
longer double the tap; overheats land after the enemy's blows with their own sound.
Measured, not heard: `forge.py measure` prints each file's loudness and low share, and the
phone band (300 to 4000 Hz) of every blow sits 6 to 10 dB under its full loudness, the
music 6 dB, so the balance holds on a speaker. Ryan heard the map loop (a huge improvement)
and gave notes, now built and in the bible's sound row: no builds, bass drops or speed
snares; 32-bar loops with an eight-bar interlude; the crunch bass back; a little metal at
low gain; the map at 92 (84 was too slow) on its own kit (soft kick, rim, brushed hats, pad and chimes), the
skirmish at 100 on kick, snare, clank and saw stabs, the pad and bass shared. Not yet
heard: the skirmish loop as rebuilt, and every effect. The knobs: `LEVELS`, `DIP`, each
loop's `kit` gains, `bass` and `pad` in `music_map` and `music_skirmish`. If a loop's bpm changes in
`groove()`, change `Sound.TEMPO` to match: the rift's vortex steps on `Sound.beat()`. The
loops stay sample-exact for seamless play: `groove` sizes the buffer from bpm and bars and
wraps every tail, the room's included. The display's scan and idle stay silent by decision.

**Open, in the order I would take them.**

1. Ryan: plug the phone in with USB debugging on and run `tools/android.sh`; judge the
   frame rate, the hex outlines, the sound set and the layout at the phone's height.
   Badger tweaks in Blender, then joints and pins (`forge.py export badger`); notes on
   the Clydesdale; the Anvil.
2. Ryan's content: names for overheating and scorch; strikes, breach, scorch, disable and
   rapid placed on foes and components; Ablative Plating as armour or shield; the Badger's
   loadout and claw numbers; Aphelion and the Arsenal; CARE's voice, including the gate's
   codex entry (rule text today).
3. Design that needs a decision before code (all in bible section 12): ally wrecks (block?
   how long?); what terrain does in a skirmish; movespeed in tens; base defences and
   turrets; the reinforcement phase; skirmish composition from placement; the multi-hex
   boss's return; the economy.
4. The map: wreck death animation once decided; joint idle for grounded units once joints
   exist; corruption in squads' wake. If a phone still drops frames, the machines are the
   next lever (one mesh per material per machine, until joints).
5. Engine gaps waiting on content: Numbed resistance roll; Corrupted; cleanse; foe roles;
   the ten planned foe actions in `foes.json`; planned statuses as modifiers; component
   stat modifiers; granted passives coloured on the codex; Ryan's cooling numbers.
6. Art: enemy art for the eight foes still on sketch grids; the hangar as a model;
   Aphelion and Arsenal chassis once written; per-mech repaint (`Unit.paint` exists,
   nothing sets it). Sound: the real recordings and the real track, once the set is judged.
7. Before a phone leaves the desk: save and resume mid-battle (nothing serialised);
   onboarding (gesture tutorial, cheat sheet: reroll rule and zone of control first); the
   Android export checked on a device (templates are installed; the SDK and a debug
   keystore are not); then play and tune numbers, map size, squad speeds, Rift Pressure.

**Known rough edges.** Routes are tap-to-destination only. The bible's formation figure
still draws three columns (the text says four). On the phone's browser the
address bar takes a strip until the first button press goes full screen. The engage pose
of `tools/screenshot.gd` prints renderer leak warnings at exit (mid-tween quit), harmless.
