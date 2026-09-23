# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible.

## As of 22 September 2026 (late)

**State.** Everything committed. Tests: 180 tests, 2422 checks, green (`perl -e 'alarm
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
decision; section 12 is the roadmap. Its published copy (the claude.ai artifact from 22
September) was found deleted late that day and has not been republished: Ryan to say
whether he wants a new link. `docs/vocabulary.md` is generated from content.

**What the game does today.** A battle: the map shows every squad's intent and the exact
result of the plan before Resolve; Resolve plays the moves with footfalls, then a CONTACT
band with its horn, then a panel of the contacts; ENGAGE dives the map and cuts to the
skirmish, the dice fight on the enemy's ground, every blow, shield and kill heard. Back
applies it and the next round plans. The gate has an integrity bar, the rift a spawn bar;
the codex opens by double-tap on either screen; MENU pauses, ducks the music, and holds
the settings, now with music and effects knobs. A map groove plays on the field and a
skirmish groove in the fight, crossfading.

**Done this session (22 September, late).** The map's draw calls: 5400 and 10.9 ms a frame
at zoom 1 on the Mac became 1166 and 2.0 ms by baking rims, columns, grid lines, props,
traces, the gate and the walls into one mesh per material per band of rows; what remains
is the three machines, live models of about 70 meshes each, left alone because joints are
coming. The phone path without an Android export: `tools/phone.sh` (needs the 4.7.2
export templates, now installed on this Mac; the README says where they go). The sound
set, first cut, unheard by anyone yet. The intent-line and wireframe trials retired as
closed; the die drag and the codex labels struck off as resolved.

**Open, in the order I would take them.**

1. Ryan: hear the sound set on the phone (`tools/phone.sh`, then Battle) and say what is
   wrong with it; the loops and every effect are recipes in `forge.py`, cheap to redo.
   Badger tweaks in Blender, then joints and pins (`forge.py export badger`); notes on the
   Clydesdale; the Anvil.
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

**Known rough edges.** Routes are tap-to-destination only. On the phone's browser the
address bar takes a strip until the first button press goes full screen. The engage pose
of `tools/screenshot.gd` prints renderer leak warnings at exit (mid-tween quit), harmless.
