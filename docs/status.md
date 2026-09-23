# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible.

## As of 23 September 2026 (midday)

**State.** Everything committed. Tests: 187 tests, 2452 checks, green (`perl -e 'alarm
240; exec @ARGV' godot --headless --path . -s tests/run_tests.gd`). Ryan sometimes runs a
second session on this repo at the same time: check `git status` before committing and
stage by path. Chassis ids: `badger`, `clydesdale`, `sparrowhawk`, `anvil`. Ryan writes
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
https://claude.ai/artifact/UuMbAAorUyZbtZ1aYKMWNZ (v0.7, republished 23 September after
the earlier copy was deleted; republish the file to that URL after a bible change).
`docs/vocabulary.md` is generated from content.

**What the game does today.** A battle: the map shows every squad's intent and the exact
result of the plan before Resolve; Resolve plays the moves with footfalls, then a CONTACT
band with its horn, then a panel of the contacts; ENGAGE dives the map and cuts to the
skirmish, the dice fight on the enemy's ground, every blow, shield and kill heard. Back
applies it and the next round plans. The gate has an integrity bar, the rift a spawn bar;
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
icon (`art/icon.png`, a tool-drawn hex).

**Ryan's skirmish notes, 23 September (done).** Four columns locked in. The menu has QUIT
(asks first; `quit_requested` runs harness-ward through the battle screen) and a colour
change keeps the menu up behind a mask while the screen rebuilds (`_build` on both screens
spares `_menu`). Withdraw replays the enemy's parting blows before the outcome; every
enemy turn replays at ENEMY PACE (`Settings.display["enemy_pace"]`, top = the old 0.12 s
beat), each blow stepping the struck mech's shield and hull from the event the sim records
(`turn_events` now carry `shield` and `hull`), taps held off by `_replay_shade` meanwhile.
Layout: ally gauges and chips 10 px off the model, foe leaders longer, every gauge on a
black ground of its own shape (no plate), the eye 52 px in the black at the log's right
(the log strip stops short of it), log 112 tall, dice and Reroll up 16, 30 px of black
under Reroll. Poses added to `tools/screenshot.gd`: menu, settings, quit, withdraw. The
bible has the rows (sections 5 and the HUD row in 4); it is not yet republished.

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

**Audio, for whoever picks it up (a separate session is expected).** Nobody has heard the
set yet. Every sound is a Python function in `tools/soundforge/forge.py`, one per name,
built from a few primitives at the top of the file (`thud`, `ring`, `burst`, `sweep`,
filters, `sat`, `at` to place a part in time, `wrap` for loops); the two loops are
`groove()` with drum patterns as strings, a bass riff in semitones above E2, a drone.
Rebuild one or all with `tools/spriter/.venv/bin/python tools/soundforge/forge.py build
[names]`, then `godot --headless --path . --import`. The names and where each is heard:
`game/audio/sound.gd` lists them (`NAMES`) and `grep -rn 'Sound\.' game` finds every hook
with its level in dB and its delay after the animation. Levels to check first on a phone
speaker: `step` (-9 dB a hex, may still be too much), `hit` under the enemy turn (-4),
`ui_tap` on every button (-2, and it doubles with the specific sound on Resolve and
End Turn), `contact` twice. Not hooked: the scan bar, overheating burns (they surface only
in the log), the display's idle. The direction is bible section 1 (sound row, 22
September). The loops must stay sample-exact for seamless play: `groove` sizes the buffer
from bpm and bars and wraps tails.

**Open, in the order I would take them.**

1. Ryan: plug the phone in with USB debugging on and run `tools/android.sh`; judge the
   frame rate, the hex outlines, the sound set and the layout at the phone's height.
   Badger tweaks in Blender, then joints and pins (`forge.py export badger`); notes on
   the Clydesdale; the Anvil. Another session: audio tweaking, from the paragraph above.
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
   nothing sets it). Sound: the display's scan has no sound; overheating burns are silent
   (they surface only in the log).
7. Before a phone leaves the desk: save and resume mid-battle (nothing serialised);
   onboarding (gesture tutorial, cheat sheet: reroll rule and zone of control first); the
   Android export checked on a device (templates are installed; the SDK and a debug
   keystore are not); then play and tune numbers, map size, squad speeds, Rift Pressure.

**Known rough edges.** Routes are tap-to-destination only. The bible's formation figure
still draws three columns (the text says four). On the phone's browser the
address bar takes a strip until the first button press goes full screen. The engage pose
of `tools/screenshot.gd` prints renderer leak warnings at exit (mid-tween quit), harmless.
