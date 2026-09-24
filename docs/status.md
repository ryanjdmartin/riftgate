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
skirmish at 100 on kick, snare, clank and saw stabs, the pad and bass shared. Ryan's
second listen: the map's writing is right (the chimes), the kit reads as Loop Hero (the
pulse-and-saw palette), the industrial noises were too much (the swell cut, the tick kept
to the interlude), the skirmish tune is less complex than the map's. The direction
discussion is in the bible's sound row (open: the palette; the dichotomy as the mixing
rule). The groove engine is now voices over chords (`groove(bpm, form, kit, drums,
chords, voices, pad)`) with new instruments: FM `epiano`, `bell`, `brass`; Karplus-Strong
`pluck`, `pluck_bass`, `chug`; formant `choir`; `organ`, `strings`, `orch_hit`. Three
eight-bar sketches on one riff (`forge.py sketch`, into `tools/soundforge/out/`, ignored
by git): human (FM keys, bells, plucked bass), rift (choir, strings, taiko, orchestral
hits, the crunch bass), djent (a seven-step chug the kick locks to, bells, choir). Ryan
picked: djent for the fight (harder drums, choir up a touch, a bass guitar for the
synth crunch, unison riff sections and drawn-out ones), the rift palette for the map
(creepier, more electronic and glitchy, the echo kept); human was plain beside them. Third
listen: longer sections, the map's bass organic (orchestral, not electronic), the fight
riff-heavy with the kick forward and no long chord stretches, instruments trading by
section on both. Fourth listen (bible section 1,
sound row, has every note): the map's interlude paused between bars (now the pad
crossfades chord to chord and held notes are legato), a discord section (G: every lead in
its own count over tritone chords), the bass a bowed `contrabass` (the pizzicato read
chiptune); the fight's leads softened (`lead`, `chime_metal`, hats, tilt 2), a guitar solo
section (S) and a keyboard solo section (K, `synlead`, the bass answering) in place of
the open chords, wilder drums under them. Now: the map 56 bars (A C D E G A C D) at 92, the
fight 48 (A C U F S K) at 100; `forge.py sketch map_88` renders the map slightly slower
to compare. Effects, fifth pass (bible section 1, sound row):
two registers. The interface is sci-fi electronic (`blip`, `chirp`: taps, back, plot, the
codex, the menu, the dice, Resolve, the dive's count-in, the contact klaxon); combat and the
map are over-the-top weighty (`explosion`, `zap`, `shot`: `laser`, `gunfire`, `cannon`,
`slash`, `slam`, `kill` and `gate_hit` as explosions, heavier steps and arrivals). The
skirmish picks a machine's blow by its face (`_blow_sound`: energy laser, kinetic line
gunfire and cannon on a crit, indirect cannon, melee slash and slam on a crit) and a foe's
by its damage (`SLAM_DAMAGE`). `forge.py sections` prints every section of both loops with
timestamps, for notes by section. Map, fifth listen (bible sound row): a soft taiko on one
and three, airier and softer throughout, cellos under the groove and the contrabass kept to
C, E and G, the strings late by half a beat in the interlude (`late` on a pad), the climax
G as independent melodies over the groove with a crescendo (`crescendo` on the groove);
`sketch map_88 map_90` render the slower variants. Skirmish, sixth listen (bible sound
row): levelled by section (the bass voice changes per section: chug and bass guitar in A,
crunch synth in C, `sub_bass` in F, a dark quiet chug in S, a driven bass guitar with runs
in K), the leads up and high-passed into their own bands, a low shelf on the master
(`low` on the groove), a `ride` and a `china` with displaced snares. Measured: each
section's lead band within one to four dB of its low band. Two experiments as sketches (24
September; bible sound row): `forge.py sketch meter_map meter_skirmish` (sections in
5/4 and 6/8 on the map; four-three alternation and 7/8 on the fight; `meter` on the
groove, steps per bar per section) and `real_map real_skirmish` (the first sixteen bars
of each on a pseudo-realistic palette: `guitar_real`, `lead_real`, `bass_real`,
`strings_real`, `violin_real`, `cello_real`, `horn_real`, `choir_real`, real-ish drums in
three variants each, `human` timing and velocity). The map runs at 90 (Ryan, 24
September: perfect over 92; `Sound.TEMPO` follows). Map, sixth listen (bible sound row): a
fuller kick, the horns up, the contrabass held longer (`hold` on a voice), the cellos
late on the "and" and the upper strings on two in the interlude (`late` on voices and
pads), the discord evened. The realism sketches are now the whole loops with
`real=True` (`REAL_MAP_SWAP`, `REAL_SKIRMISH_SWAP`, an orchestral `bassdrum_real` for the
map); the map's meter sketch is a 7/8 bar at two phrase ends of the interlude and a 6/8
section whose triplets ride the 4/4 bar (`meter` takes (steps, scale)). Fight, seventh listen (bible sound
row): a hybrid palette (real drums with the crash and snare shortened and the ride
lowered, `guitar_real` backing, `bass_real` everywhere with more drive, the original
`epiano`, `lead_real` with more gain for the guitar solo, the synth `lead` for the unison
and the keyboard solo), the kick down, the unison's drums restrained, the ride's cadence
under the keys, both solos as melodic lines with rests, the keyboard solo half time with
crashes and the bass firing alongside. `music_skirmish(palette="synth")` is the old set
(`sketch skirmish_synth`). Four-three as flair and a written 7/8 section wait. The map's realism won (bible
sound row) and is folded in: `music_map(palette="real")` is the map (`map_synth` the
sketch), 60 bars with a 7/8 bar closing each interlude phrase (`meter` in `MUSIC`, which
`sections` reads) and a twelve-bar climax; the bass drum louder with `headroom` before
the master stage and every kit sound normalised, since the mix had been distorting; the
strings' note ends softened; the groove's horns down; the strings section's horns in
three swelling notes. The fight's bass corrected after
Ryan clarified: `sub_bass` under the lift, the keys and the keyboard solo; the driven
`bass_real` under the riff, the unison and the guitar solo, quieter. Map, seventh listen (bible sound
row): the bass drum up with a knock for speakers, loops levelled by mean RMS pinned to
their judged levels (`mean_level` in `write`), horns, bells and interlude cellos down, a
7/8 bar closing each interlude half and two turns in 7/8 (`Y`), the strings section
twelve bars with unpredictable horn swells, the violins up where they carry, the reprise
after the climax dropped (48 bars: A C D E G). In the game a new battle restarts the map
loop from the top after the map is drawn (`Sound.music("map", true)` deferred from the
battle screen); a fight's return still resumes. Map, eighth listen: a four-bar closer (H)
after the climax, a 6/8-at-4/4-length reprise (R) after it, long turns in 9/8 (W) and
5/4 (V) in place of the 7/8 turns, six horn swells in the strings section, the violins'
tails longer and overlapping (`hold` 1.3); 60 bars, 2:40. `forge.py audition` renders
every effect into one file with timestamps. Fight, eighth listen (bible sound row):
60 bars (A C X U F S K) with a written 7/8 section (X), the unison's drums a generated
Peart-style solo (`_drum_solo`), the keys section twelve bars, the guitar solo as the
chug an octave up with open notes, the keyboard solo's sub in long notes against the
lead on the beat with crashes on one and three, a soft `ride_real`, the riff's bass down
and softer-edged. `sketch bass_samples` plays six bass voices on the lift's riff for Ryan
to pick (`sub_pluck`, `slap_bass` new). Map, ninth listen (bible sound row, with
Ryan's rule that the kick keeps its places whatever the meter): opens on eight bars of
the groove bare (P), the 9/8 and 5/4 turns gone (a triplet bar T into the climax, the
kick steady), the bass drum up, bells and the lift's horns down, the strings section's
climb and horn swells rewritten on the beat and quieter, its contrabass gentler, the 6/8
reprise out of the loop and kept as `sketch map_outro` (a second track's seed). Fight, ninth listen (bible sound
row): 66 bars (A C A X U F S K J), crashes by hand at section doors (none at the top),
every drum part and voice on its own seeded stream (`groove` reseeds per part, so an
unedited riff is stable), `tom_real` with bottom end, more cymbals in the solo (`splash`,
`crash_low`, `stack`, `ride_bell`), the keys' sub unbroken with `res`, the keyboard solo on
the crunch synth with the lead travelling and `guitar_chord` behind, a two-bar unison
descent (J) into the loop; `sub_pluck` in the lift to hear in context. The map's closer
violin no longer wraps onto the start. Not yet heard: both loops as rebuilt, the effects. If a loop's bpm changes in
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
