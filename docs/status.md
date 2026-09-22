# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible.

## As of 22 September 2026

**State.** Everything committed. Tests: 177 tests, 2387 checks, green (`perl -e 'alarm
240; exec @ARGV' godot --headless --path . -s tests/run_tests.gd`). Ryan sometimes runs a
second session on this repo at the same time: check `git status` before committing and
stage by path. Chassis ids: `badger`, `clydesdale`, `sparrowhawk`, `anvil`. Ryan writes
`content/*.json` in his own voice; tests never hardcode an entry's passive name.

**Where things are.** `sim/` is the headless game (battle map, battlefield resolver,
battle loop, skirmish, effects pipeline, content DB). `game/battle/` is the battle screen
and the map (`battle_map_view.gd` overlays and gestures, `map_3d.gd` the scene,
`painted_map.gd` the other world, `bleed.gd` + `bleed.gdshader` the compositor that mixes
them). `game/skirmish/` the fight. `game/ui/` the HUD kit, the shared codex box, the pause
menu, `mech_view_3d.gd` (any model in a viewport) and `trace_lines.gd` (the display's
light on every edge). `tools/lowforge/` builds every model by code from a brief;
`tools/screenshot.gd` poses either screen (`README.md` lists the poses);
`tools/perf_probe.gd` measures the map; the `map_tuner` knobs are behind
`RIFTGATE_TUNE=1`. `docs/design-bible.html` records every decision; section 12 is the
roadmap. `docs/vocabulary.md` is generated from content.

**What the game does today.** A battle: the map shows every squad's intent and the exact
result of the plan before Resolve (the resolver run dry): contacts, blocks, zones of
control, the ground each fight will be on. Resolve plays the moves at a pace by movespeed,
then a CONTACT band, then a panel of the contacts with portraits; ENGAGE dives the map
and the other world's painting spreads over the ground before the skirmish fades up. The
skirmish is the dice fight on the enemy's ground. Back applies it and the next round
plans. The gate has an integrity bar, the rift a spawn bar, both on the map; the codex
opens by double-tap on either screen; MENU pauses with settings that persist.

**Decided this week, in the bible (section 4 and 5 rows dated 20 to 22 September).**
The field projector and the city behind the wall; the clash between the gritty 3D
reconstruction and the flat bright overworld; the mid-nineties 3D register for every
ally asset, built by lowforge, maker metals and finishes as the differentiator; the
holographic display look with the pulse trace as default; exact preview, plotting in
order, re-plot last, squads planning in order; zone of control (grounded machines stop
squads beside them, flyers stop nobody, squads never swerve); contacts offered and
chosen; the boss on one hex patrolling the rift; the skirmish fought on the first squad's
hex; the handover; machines never under the painting (drawn from their own layer where
the geometry is gone, the scene with its depth elsewhere); the ground keeping its height
under the painting (`Map3D.COLLAPSE` false, a trial Ryan called flawless); tints heavy on
purpose; the pause menu and its knobs; the top bar in plain words.

**Open, in the order I would take them.**

1. Ryan: Badger tweaks in Blender, then joints and pins (`forge.py export badger`); notes
   on the Clydesdale's first pass; the Anvil (borrows the Badger's model).
2. Ryan's content: names for overheating and scorch; strikes, breach, scorch, disable and
   rapid placed on foes and components; Ablative Plating as armour or shield; the
   Badger's loadout and claw numbers; Aphelion and the Arsenal; CARE's voice, including
   the gate's codex entry (rule text today).
3. The map: ally wrecks left on the field with a death animation (discuss first: does a
   wreck block, and does it stay a round or the battle); joint idle for grounded units
   once joints exist; whether squads leave corruption in their wake; the `LINE_TO_CENTRE`
   trial on intent lines (Ryan to judge in play).
4. Engine gaps waiting on content: Numbed resistance roll; Corrupted; cleanse; foe roles;
   planned statuses as modifiers; component stat modifiers; granted passives coloured on
   the codex.
5. Design still open (bible section 12): the reinforcement phase; skirmish composition
   from placement; movespeed in tens; the economy; base defences and turrets.
6. Art: enemy art for the eight foes still on sketch grids; the hangar as a model.
7. Phone: play it and tune numbers, map size, squad speeds, Rift Pressure. The map costs
   about 8.4 ms a frame on the Mac at 5130 draw calls (every prop and trace its own
   instance); if a phone drops frames, batch props and traces per column into MultiMeshes.

**Known rough edges.** Codex stat labels cut off on Ryan's device once, not reproduced.
Routes are tap-to-destination only. The skirmish's die drag was choppy on the phone
before the GPU readback went; unverified since.
