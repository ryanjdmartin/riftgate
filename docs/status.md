# Status

Handoff note for the next session. Replace stale lines; keep it under a screen. How a
thing works lives in its file's comments; why it is that way lives in the bible
(`docs/design-bible.html`, every decision by section; section 12 is the roadmap). The
bible is published at https://claude.ai/artifact/UuMbAAorUyZbtZ1aYKMWNZ (this account;
republish the committed file after a bible change) and, from the other account, at
https://claude.ai/artifact/AdBTeE9px1Xvg5TKNjHjSP.

## As of 28 September 2026 (evening)

**State.** Tests green: `perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s
tests/run_tests.gd` (about 220 tests). Two or three sessions run on this repo at once:
check `git status` before committing, stage by path, diff a shared file first (a path
still sweeps the other session's hunks), never `git add -A`, never kill a bare
`godot --path .`. Commit after each verified chunk with tests green.

**Where things are.** `sim/` is the headless game (battle map, battlefield resolver, battle
loop, skirmish, effects pipeline, content DB). `game/battle/` the battle screen and the map
(`battle_map_view.gd` overlays and gestures, `map_3d.gd` the scene, `painted_map.gd` the
other world, `bleed.gd` + `bleed.gdshader` the compositor). `game/skirmish/` the fight.
`game/ui/` the HUD kit, codex, pause menu, `mech_view_3d.gd`, `trace_lines.gd`, the feed
effects (`feed_fx.gd`, `tear_layer.gd`; `RIFTGATE_FEED_DEBUG=1` fires them constantly).
`game/audio/sound.gd` plays every sound by name; `tools/soundforge/forge.py` builds them
into `art/audio/`. `tools/lowforge/` builds every model by code (`models_low.py`, one
function per chassis id); `tools/screenshot.gd` poses either screen (README lists the
poses and the phone-layout variables); `tools/balance.gd` writes `docs/balance.md`;
`tools/android.sh` the debug APK, `tools/phone.sh` a Web build on the LAN.
`docs/vocabulary.md` is generated from content (`tools/export_vocabulary.gd`).

**Content (bible section 7).** Chassis ids: `badger`, `clydesdale` (d9; the die cap is
10), `sparrowhawk`, `baboon` (the Mandrill, renamed 28 September; its passive Pocket
Paradox runs on the new `on_foe_status` trigger, `Effects.foe_status_suppress_chance`;
Aphelion stock is `umbra_projector`, `pulse_repeater`, `zenith_emitter`, `halo_shield`,
`radiator_sail`, with `corona_shield` a unique unlock), and the 28 September drafts
`armadillo`, `wild_boar`, `prairie_dog`, `dingo`, `goshawk`, `nemesis`, `ammit` (the last
two the Arsenal's; maker `arsenal` exists). Their shapes are decided (the chassis pass
row): every new passive and most locked components carry `"status": "planned"` until the
engine has volatile, devour, Shocked, Overcharged, taunt, overwhelm, the stealth join
rule, the vent-on-fire face, the die-local reroll and heat-scaled shield regen. Numbers
are in tens and are placeholders; every stat is read through `sim/effects.gd`. An enemy
unit is a **pack** everywhere. Ryan writes `content/*.json` in his own voice (he writes
die totals in his head; the data keeps free slots), often from his phone through the
content editor artifact https://claude.ai/artifact/HnE3gvsxNHXyjRhRyEiDqT: pull collection
`edits` with ArtifactData, apply by hand (the files are hand-formatted), test, commit,
republish the page with its `files` map, clear the documents. The memory note has the
quirks. Tests never hardcode an entry's passive name.

**Reserved names (28 September).** `content/reserved_names.json` holds about 1,250
machine names (BattleTech, Heavy Gear, 40k, Halo); `ContentDB._validate_name_clash`
refuses an exact match unless `design.name_clash` says why it stays. Ryan's verdicts (28
September) are in the notes: `sparrowhawk` kept (a coincidence: a Halo Wars gunship and a
BattleTech fighter, both obscure; the name conjures the bird), `goshawk` and `baboon` kept
(designation-tier: the Vapor Eagle's Inner Sphere name, the Howler's Clan name), `badger`'s
id kept (Honey Badger is clear); `dingo` (a Heavy Gear Northern gear) is still his to decide
(todo). The tiers: iconic (the name conjures their machine: never), known (a hobbyist
recognises it: case by case), coincidence (keep). Names and concepts are spitballed on the
Riftgate Nameplate artifact
https://claude.ai/artifact/6K6mq49XHCUbdZnkzp5rra (a tab per maker, Components, Rules;
rows in its db collection `candidates`; rebake the page from the reserved list and the
content names when either changes). Ryan's brainstorm of component names is on its
Components tab, trimmed, with the used ones marked landed.

**What the game does today.** A battle: the map shows every pack's intent and the exact
result of the plan before Resolve; a grounded machine controls the ground beside it, a
pack stepping into it stops and that is a contact; every grounded machine within
`Battlefield.ENGAGE_RANGE` (2) joins, and a tether runs from each machine to the pack it
will fight (28 September; Ryan's play test decides whether 2 is right). Resolve plays the
moves, a CONTACT band, a panel of contacts; ENGAGE cuts to the skirmish, the dice fight on
the enemy's ground, four columns, every blow heard, the enemy's turn replayed blow by
blow; Back applies it. The boss's contact takes the phase: no panel, a reveal, the family's
theme (only The Chorus has one). MENU pauses, holds the settings and names the track. The
codex opens by double-tap on either screen and shows the machine's base state plus battle
rewards; the fight's effects live on the chips and the hold.

**Balance (bible section 11).** `sim/policy.gd` plays the skirmish headless (RANDOM,
GREEDY, `withdraw_below`); `tools/balance.gd` runs the matrix, about two minutes with
eleven machines. Last read (28 September, after the Baboon, Pocket Paradox and the
drafts' stock; their passives are still planned, so their rows are kits alone): the
Badger, Wild Boar, Nemesis and Armadillo each win nearly every cell alone at little cost,
the runner's flag for too strong out of the box; the Clydesdale's d9 lifted it (beats
ghouls, holds the Colossus); the Baboon beats the back-rank packs and the Colossus and
loses to the Pit Lord half the time under greedy, the bosses' stun resistance biting the
one machine built on suppress; the Dingo and Prairie Dog lose to nearly everything alone,
as support cars might, but their hull is worth a look; the Sparrowhawk and Goshawk hold;
the team of three still wins every single-pack fight at no cost, so the rank and file's
numbers are the lever. Numbed decays now and bosses carry 30 stun resistance. Rerun after
each engine piece lands; read bands, not numbers.

**Audio (the bible's section 1 sound row has every listen and decision).** Everything is
`tools/soundforge/forge.py` writing WAVs into `art/audio/` (`build`, `measure`,
`sections`, `audition`, `sketch`); Ryan gives notes by section letter or timestamp. Six
titled tracks in `Sound.TRACKS`, all locked or "pretty great"; the map's set cycles, the
skirmish's picks, the boss theme per family (`SETS["boss_<faction>"]`, `LOOP_FROM`). The
phone pass (26 to 28 September, from the sketches page
https://claude.ai/artifact/FCaphxM3Y3SnRPdNnprpXc, rendered by
`tools/soundforge/phone_sketches.py`) is in the forge and all six tracks are rebuilt on
it: one master for both palettes (tilt 1.5 plus a presence lift at 1 to 2 kHz), the driven
bass without its hard clip (asymmetric stages, the drive following the note, a bass
cabinet: Hold The Line and Full Bore), the backing guitar without its clip at the old
level (the three human tracks), a metal kick and a tightened tom (the human tracks), a
softer crash, the soft sub's speaker shadow, and the rift tracks a quarter of their
phone gap louder (The Far Bank -20.2, The Crossing -19.2; Low Ground unchanged). Still
to judge: the kick's size alone and the toms in headphones (Ryan's last drum notes).
Next: a speakers/headphones setting (offsets per track and a bus EQ on the speaker
profile); the Risen and Infernal Horde boss themes from their seeds, melodies proposed in
chat first; the real recordings remain section 12's open question.

**The phone (26 to 28 September; README has the commands).** Ryan's Pixel runs the debug
APK. Fixed so far: grid ribbons and their gain, safe insets, the MSAA leak, font
oversampling, the drag ghost, the far blur, scanlines on device pixels, leaders, the seam
band's clipped hexes, and the readout's strip under the map filled by the orders board
while nothing is held (`game/battle/orders_board.gd`: a row a machine with its order and
what the plan says it meets, the field at the right). Still to judge on the device: frame
rate, the sound set, edges without MSAA, the text, the grid at the hotter gain, the board.

**Open, in order.** The task list is `docs/todo.md`, one line a task, grouped by who
moves it and ticked in the commit that lands it; this is the order to take them in.

1. Ryan's play test of the engagement range and tethers, and his phone reads.
2. The planned engine pieces, in whichever order he wants to play first.
3. Ryan's text for the new machines and components, and the flagged names.
4. The discuss-first decisions in the Ryan section, the economy last.
5. Art: the seven new models, enemy art, the hangar.
6. Before a phone leaves the desk: save and resume, onboarding, then tuning.
