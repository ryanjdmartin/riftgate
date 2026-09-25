# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible.

## As of 23 September 2026 (evening)

**State.** Tests: 187 tests, 2458 checks, green (`perl -e 'alarm 240; exec @ARGV' godot
--headless --path . -s tests/run_tests.gd`). Ryan runs a second session on this repo at
the same time (today: the HUD session and the audio session): check `git status` before
committing and stage by path. Chassis ids: `badger`,
`clydesdale`, `sparrowhawk`, `anvil`. Ryan writes `content/*.json` in his own voice; tests
never hardcode an entry's passive name.

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
vortex in eight true frames (the candidate plus seven image-to-image redraws that move
the tendrils, aligned by correlation, ordered for the smoothest cycle; a dithered tween
was tried and read as blur), one turn a bar of the music, torn in bands like the ground
round it (bible section 5 row, 23 September; every candidate and frame is in
`tools/foeforge/out/rift`), a frame every 0.7 s on its own clock (`RIFT_ON_BEAT` locks
it to the music instead, off). The map's tear, tuned by Ryan's eye through the
afternoon and settled: rows of 32 map pixels, a torn row's tear 6 to 10 tall and 120 to
260 wide at a random place, 1.2% of rows a tick, under 0.3 s, a shear jittering up to
12 px either way, a 12% dim, no hairlines, painted pixels only (so a lone enemy tile
between 3D tiles tears alone); the vortex's own bands tear at most two at once, a fifth
of a second, up to 6 of its pixels either way, never in the tendrils over the hexes; the
rift's ground tear is centred on the vortex's mouth. All the knobs are at the top of the
tear block in `bleed.gdshader` and in `_draw_rift`. The frame's ticks stand level with
the hex beside them; the readouts sit on faint plaques.

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
stops short of it), log 112 tall, dice and Reroll up 16, 30 px of black under Reroll, the
foes' pane 12 px lower (BACK_Y 72) for black under the header. Poses added to
`tools/screenshot.gd`: menu, settings, quit, withdraw, acquire, groundtear, feed_<name>.

**The feed pass, 23 September (locked by Ryan after judging every effect in motion; bible
section 6 row has the full record of kept, cut and reworked).** The skirmish HUD reads as a
feed being analysed. Always on: intents acquired with collapsing brackets and a digit
scramble as they appear (`UnitView.acquire`), the header's fight clock, the log strip's
blinking prompt, the scan band on the mechs' traces only. `game/ui/feed_fx.gd` runs rare
one-shot events on two independent lanes, each firing every 5 to 11 s: the foe lane
(scanbox with a meter and a blinking "SCAN OK"; a telemetry box whose leader's select box
moves between parts of the foe; a sprite tear; a signal drop under static with a plated
"SIG LOST") and the ally lane (a rolling bar chart or a three-bar equaliser beside a
machine; a die's static over its held number at 60 positions a second; a die's wobble in
horizontal slices). `game/ui/tear_layer.gd` + `tear.gdshader` is the screen-reading slice
shear, used over the foes' whole pane (one or two slices every 8 s at most, one slot in
three silent, hidden between tears) and, in manual mode, as the die's wobble. The tear,
the signal drop and the wobble go off with the GLITCH setting. Cut along the way: the scan
band lighting gauges, chips, buttons and rules (blinked rather than swept); a dimming tear
flavour; hairlines on the shear; a jolt-and-tilt wobble; a digit scramble on the die.
`RIFTGATE_FEED_DEBUG=1` fires every lane every half second and the tear every two seconds.
Knobs: `FeedFX.LANES`, `GAP_MIN`/`GAP_MAX`, `DURATION`, `TearLayer.PERIOD`,
`DieFaceView.STATIC_RATE`. Ryan judges effects in motion, never from stills: keep the debug
switch and the poses for the next pass.

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

**Audio, handoff (24 September; the bible's section 1 sound row has every decision and
the reasons, listen by listen).** Everything is `tools/soundforge/forge.py` (numpy only)
writing WAVs into `art/audio/`, played by name from `game/audio/sound.gd`. Commands:
`build [names]` then `godot --headless --path . --import`; `measure`; `sections` (every
section of every loop with timestamps: notes are given by section letter or time);
`audition` (every effect in one file, a second apart); `sketch <name>` (renders to
`tools/soundforge/out/`, git-ignored, never shipped). Any Python with numpy runs it; the
spriter venv is the one that has it.

*The engine.* `groove(bpm, form, kit, drums, chords, voices, pad, ...)`: a form string of
section letters, a bar per letter; `meter` gives a section its steps per bar or (steps,
scale) so a bar can be 7/8, or 6/8 at the 4/4 bar's length; drums as pattern strings (a
pattern shorter than a bar walks round it: polymeter); chords per section, one or a list
cycling per bar; voices in `riff` (semitones, holds), `chord` (the bar's chord by degree)
or `stab` mode with `hold`, `late`, `legato`, `echo`, `shape` (a voice's own rise and fall
across its section's run); pads by section with `pump`, `swell`, `late`; `crescendo` per
section; `human` timing and velocity slop; kit sounds as variant lists picked per hit,
normalised, an optional third field playing them behind the beat; `headroom` before the
master. Every drum part and voice draws its own seeded stream, so an unedited riff never
changes. Loops are levelled by mean RMS pinned where Ryan judged them (`LEVELS`);
effects by their loudest 50 ms. Ryan's rule: the kick keeps its places for the whole
track, whatever the meter.

*The tracks.* `music_map` is the **rift theme** (90, 89 bars, 3:56): the real orchestral
palette (bass drum, cellos, contrabass, violins, horns, harp, timpani, choir, strings
pads, bells with a three-tap echo, glitch clicks and stutters), form P A C E D T V G H
(a gradual build from the choir and kick alone through the groove to the lift, the
bells' lift, minor strings, interlude with 7/8 closes, triplet turn, the quiet before, a
twenty-eight-bar climax that starts level and then swells each voice in and out twice
before thinning into the closer). Ryan: nearly perfect; the strings' chords and the
build's bells were the last notes (25 September). A pattern whose length is no multiple
of the bar walks round the bar by design: write section patterns in bar multiples unless
that is wanted. `music_skirmish` is **human A** (100, 117 bars, 4:41; Ryan labels tracks by creation
order now, human A B C and rift A B C, the screens unsettled): the hybrid palette (real
drums with many cymbals, the real guitar's mechanical chug, the real bass driven, the
soft sub, the crunch synth, the original piano, the synth lead), form A B C N L M X U F
W S Z Y K J (the riff in three stages, a drum-fill turn, lift, riff on power chords,
second lift, a bar down, the seven, the unison over a drum solo, keys, the keys' turn,
the climax riff in unison then under a blast beat, a one-bar breath, the keyboard solo
sixteen bars six percent slower over dark chords, a one-bar descent). `drum_gain` per
section, a `clean` guitar voice and `fade` on the sub exist for it. `music_rift_calm` (90, 6/8 throughout, a ground bass under six
variations, 2:29) and `music_human_calm` (94, four on the floor, industrial, 3:04) are
their calm siblings, and **the map's music for now** (Ryan, 25 September: both very good):
`Sound.SETS["map"]` plays them in turn, one full loop each, crossing over the seam for
`SET_FADE` seconds, and the set resumes its current loop where it left after a fight; a
new battle restarts the set from rift B's top. The skirmish set is human A. Rift A is in
the table, unhooked. The rift theme runs at 86 now. The interface effects are future-digital (a sine with a shimmer and air),
not the pulse wave. Third tracks, both rebuilt after Ryan's first notes (25 September, unheard since):
`music_rift_drive` (**rift C**: 126, E Phrygian, a pizzicato three-three-two over
timpani as the engine, Ryan's kick-chug-snare pattern as one section, a new motif on horn
and violins, eight bars of 3/4, 72 bars, 2:13) and `music_human_heavy` (**human C**: 105,
the Omnific construction on the human sound leaning metal: the guitar chugging the riff's
power chords with the driven bass, the clean bass melody doubled by the lead guitar, the
drone, a section in seven, 66 bars, 2:06; `bass_clean`), in the table, not hooked. The pure-synth versions survive as sketches
(`map_synth`, `skirmish_synth`), as do `map_86/88/92`, `map_outro` and `bass_samples`.

*The effects.* Two registers: the interface sci-fi electronic (blips and chirps), combat
and the map over-the-top weighty (an explosion primitive; laser, gunfire, cannon, slash,
slam; kills and the gate as explosions). The skirmish picks a machine's blow by its face
(`_blow_sound`) and a foe's by its damage (`SLAM_DAMAGE`). `Sound.DIP` ducks the music
under big moments; `TONAL` sounds keep their pitch; a new battle restarts the map loop
from the top after the map is drawn, a fight's return resumes it. The display's scan and
idle stay silent by decision.

*To do, audio (25 September).* (1) Listen: rift A (**locked** at the twenty-second listen's build: the climax thirty-two bars, the rotation from the repeat edge; 89 bars, 3:56) and human A (twenty-third listen built: **locked** at the twenty-sixth listen's build (the riff sixteen bars, the drone under its last four, the second riff and the whole climax, alone under the climax's first set); Ryan really likes the drone as a human-track element; a pad `skip` and `chord`, the sweep pad's `open` and `depth`; "everything else fixed, breaths and turns great"); human B
(calm) and C (heavy) and rift B (calm, the ground bass) and C (drive) not yet heard at
all beyond a first pass on the two calms; the interface effects since the fourth audition
(retried from scratch as a Terran console: `relay`, `tone` and `chatter` in the forge, no glides; the brief is irony, not parody; `forge.py audition`); the map set's crossfade since it went equal-power (it had gapped). Expect a round of notes on each. (2) The
screens: the map plays rift B and human B in turn (a set; judge the two-second crossfade
at the seam), the skirmish human A; rift A, rift C and human C sit in the table unhooked;
decide where they go and whether a set should pick rather than cycle. Both calms are rebuilt
on the current engine (pad crossfades at their doors), pinned at one level, the map's
(-24.9 dB mean RMS), and **locked for now** (Ryan, 25 September: both sound good); the
other tracks' levels wait on where they end up. (3) Loose ends inside the tracks:
four-three flair belongs to the prog track, human C (human A's and rift A's meters are
settled). Human A's drum solo is the intensity Ryan wants wherever drums lead a human
track. (4) The phone: nothing has been heard on a device;
the mix was checked by measurement only (each section's low band against its lead band,
the phone band of every blow). (5) The real recordings and the real track remain
section 12's open question; everything here is a placeholder in the decided register.

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
   Android export checked on a device (everything it needs is on this Mac; bible section
   11 and the README say how); then play and tune numbers, map size, squad speeds, Rift
   Pressure.

**Two sessions on the bible.** Both sessions edited and published `docs/design-bible.html`
on 23 September; publishing from one collides with the other's uncommitted working copy.
Whoever publishes should commit first and publish from the committed file, and the file
in the repo is the superset either way. The published copy is a row or two behind the
repo at the end of the day (the phone row in section 11, the frame and rift rows in 5).

**Known rough edges.** Routes are tap-to-destination only. The bible's formation figure
still draws three columns (the text says four). On the phone's browser the
address bar takes a strip until the first button press goes full screen. The engage pose
of `tools/screenshot.gd` prints renderer leak warnings at exit (mid-tween quit), harmless.
