# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next. Why, and the
direction behind it, live in the bible (section 12 is the roadmap); how things stand
today lives in `docs/status.md`. "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Play-test the engagement zones and the behaviours: the radii (front 1, back 3, boss 2 are placeholders), the ghoul as aggressive and the brute hunting the strongest at move 3, whether a hunter needs more move than a machine, whether fights come out big enough, whether the map must grow wider if the zones crowd it; the sandbox at https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg draws the zone rule
- [ ] Name a dedicated hunter foe (Ryan, 1 October: the brute's hunt is a placeholder; a stalker type with a caveat of its own, proposed in chat first)
- [ ] Formations (Ryan, 1 October): seed the opening enemy formations as threatening shapes with a front and a back, and have the rift spawn formations rather than single packs; shapes proposed in chat first
- [ ] Judge on the phone after a re-export: the machines' outline at 2.6 (`MechView3D.OUTLINE`; 1.0 was the thin), the intent field in motion (stripe width `STRIPE`, ring spokes `SPOKES`, the pulse), the machine's lock's contrast (the light at half), the orange pulse of the gate's hazard glyphs, the sound set, the grid at `GRID_GAIN_PHONE`
- [ ] Codex and flavour for the nine new machines, the Baboon's flavour, and the 45 components whose codex is empty
- [ ] Listen to the palette console's eleventh cut and the baseline mix (7 October; sections 1 and 6 of the listening page): every glass measured level under its rider, the console's statements at seven over the music, the voice at ten, the sliders at music 0.63 and effects 1.0; picks land in `forge.py` with their hooks, the hover needing an over-target state in the drag and the map's acquire a hook on the map's selection; a per-track music offset when the ten-decibel spread between tracks on the phone is wanted closed
- [ ] The console voice: Jenny on the mid chain slowed a third (Ryan, 7 October), her plosives tamed in the page's section 5; Ryan confirms the tamed one keeps her bite, then a line per moment, the levels against the music, a hook per line in `sound.gd`, and the credits line for Jenny (Dioco)
- [x] Run the tests on the Mac: the `sound` label's validation in `content_db.gd` landed from a cloud session with no Godot (2 October: green in the cloud too, Godot fetched into the session)
- [ ] Judge the limbs striking and the turrets flinching in the skirmish, running, and each machine's acts, movement and cornering once built; and each class's size per machine on a refit (a pin's `scale` in `models_low.py`)
- [ ] Propose in chat a Minerva intercept component for the starter set (Ryan, 30 September: tanks need class-based target-modification beyond the Proximity Klaxon; since 2 October the Klaxon is a lure with an area, and a lure on a weapon may be the intercept)
- [ ] A full play of Hold The Line in the game, start to wrap; notes by section letter
- [ ] Read `docs/balance.md` (2 October: the player's damage halved, the targeting pass and the playtest set in, the formation cells, the targeting comparison and the two hovercraft in; the Stingray in the support band with its vent never spent, the Puffin unreadable alone) against your own play. The next axis to read is enemy damage against the team's durability, now that fights last: whether 80 a round from a ghoul swarm is average or game-losing
- [ ] Judge the halved numbers in play (2 October): a 10 to 20 kinetic beside a flat 15 energy, armour 5 on a boss, Overcharged +5 a stack; whether the die reads easier and whether anything feels like a tap
- [ ] Discuss first, then decide: ally wrecks (block a hex? a round or the battle?)
- [ ] Discuss first, then decide: what terrain does in a skirmish (things the machines feel, never a bonus to the foes; burning terrain a candidate)
- [ ] Discuss first, then decide: base defences (gate guns, then turrets; `Battlefield.defenses()` is empty)
- [ ] Discuss first, then decide: the reinforcement phase, and whether skirmish composition follows placement
- [ ] Discuss first, then decide: when and how the multi-hex boss comes back (`Unit.TRIANGLE` waits)
- [ ] Discuss first, then decide: Rift Pressure feeding packs into the boss fight, so bum-rushing the boss is a race between temporary power gained and the boss's reinforcements (Ryan, 29 September: valid, fits the complexity wanted, tight to balance; hinges on how strong the in-battle temporary upgrades are, which do not exist yet)
- [ ] Discuss first, then decide: the final battle's source rift has a boss of its own (Ryan's lean, 29 September: probably yes, as the campaign's climax; The Far Bank may be that boss's track, being more doom-and-gloom than a fight, which would leave The Chorus wanting a theme from a seed)
- [ ] Discuss first, then decide: the economy and the blueprint tiers, hull repair included (nothing that prices anything can be designed before this)
- [ ] Discuss first, once the balance has a baseline (Ryan, 2 October): the commander layer, bible section 8 (the reward pick after a won skirmish, one-shots, city abilities, whether the command die exists); it needs heavy UI work and a place on the skirmish screen, and Rift Pressure in the boss fight waits on its rewards
- [ ] Discuss first, then decide: does a pack keep its foes' hull and statuses between fights (a withdrawal leaves them hurt today only in the count), and how the map shows it (the strength segments could show it)
- [ ] Judge the movement words and every chassis's move in play once movement by way of moving lands (bible section 4, the movement row); the moves follow size and role, the content check only flags a chassis at least as fast as another on every ground
- [ ] Pacing, in a design session (bible section 4, the pacing row, open 2 October): the threat bar (its name, the marks and their prizes, the mark that unseals the boss, the extra marks past it), the elite tier (what elites are; costly for the Sparrowhawk to stay on, not unreachable), Rift Pressure's escalation (faster, worse packs), and the flattening reaching the gate as the hard backstop (or a Loop Hero forced boss; one, not both)
- [ ] The generator's water feature judged with the two hovercraft, the Stingray and the Puffin (bible section 7, the hovercraft row; on main since 2 October, night)
- [x] Enemy targeting among machines in a skirmish (2 October: every foe picks its own target by its aim, weighted and shown; the counterplay is Lure, Suppress and Disrupt, Shield, Armour and Brace; bible section 5)
- [x] Confirm the ghoul's one move (2 October: agreed and built; Claw, 5 plus 5 a kin on the field)
- [ ] The game's name
- [x] Name and brief the second Aphelion machine: the Stingray, built 2 October with the Puffin
- [ ] Judge the Stingray's and the Puffin's third renders on the hangar's Models tab (2 October, late: the Stingray's dome turret, under-wing mounts and twin exhausts; the Puffin a wide oblong hover hull with the first pass's head; notes by part, a note moves a number in `models_low.py`, then `forge.py build` and one `--import`)
- [x] The movement session's helicopter-style movement for the Stingray landed 3 October (`b.move(tilt=...)` in its rig: nose down to go forward, a side down to strafe, no bank)
- [ ] Judge the skirmish's hover idle pitch (`sway_pitch`, 2 October) against the rig's tilt and the hovercraft's acts running; retire the idle pitch if the rig's acts cover it
- [ ] Decide the Puffin's passive (discuss first): the overshield, shield an ally past its maximum, with its cost or second effect; Claude's shape is Overpressure, the excess fading at the end of the round, the fixed Prow Projector outward-only; then it gets built, with the gauges showing the excess

## Engine

Nothing in content is planned any more; every piece the 28 September content leaned on runs since 30 September (bible section 7, "The 28 September pieces, built"). The machine weld is decided and ready to build; the joint pass and the idle acts are built (3 October, a cloud session; Ryan judges them running next); movement by way of moving is built; the rest waits on a design line from Ryan first. Nothing here is claimed by another session; a session that takes a line says so in this file.

- [x] The targeting pass (2 October, bible sections 5 and 9; built the same day with tests green): armour on foes; `aim` and the per-foe weighted pick; `when`, the no-repeat rule and attacks at 2 to a special's 1; Lure as a retarget on any foe-targeted entry; Disrupt; Brace as flat armour; the vocabulary; the nine foes rewritten
- [x] The runner reads targeting on the team cells (2 October: the shipped aims against the lowest-shield rule, in their own section of `docs/balance.md`)
- [ ] The Puffin's Overpressure, once Ryan decides it (the Ryan section): shield past maximum at the cap site when the Puffin's shield component is spent on an ally, a round-end trim, the gauges showing the excess
- [ ] Phased (parked) and Corrode still want a design line first
- [ ] Judge the aims, the lure and the disrupt in play: whether the exposed weighting (hull reached plus half a breaking shield) leans hard enough, whether the swarm's opening 80 reads as pressure or as a wall, whether a disrupt into a boss's signature feels like a trick or a trap
- [x] Movement by way of moving (decided and built 2 October; bible section 4, the movement row ends with what stands): the words and `BattleMap.spend`, moves in tens in content with the foes' in `foes.json`, the horde's rule, the hunter's shore target, the validator and the flag, the generator's guarantee under the horde's rule with no single-hex plug, the terrain tap, the codex's open-ground count, the dashed slow end hexes, the pace, `Save.VERSION` 2
- [ ] Left from the movement build: the move gauge the drawn route drains (today the plaque counts spent against the whole; the dashed end hex says a slow step); a crossing at least three wide (two is guaranteed; 21 of 200 maps have a two-hex cut); the hangar page republished with the tens once the hovercraft branch lands (its live copy carries the Stingray and the Puffin, which main does not yet; a republish from main today would drop them)
- [ ] The generator's water feature (bible section 4, the movement row; with the hovercraft): one real river or lake band a map in place of puddles (6% of the field today, mean body under two hexes, never a river), with foe crossings two or three hexes wide that everyone may use; measure it on the 200-seed survey (the cloud session's `map_survey.gd` method: preload by path, generate at 7x20, count shares, cuts and the narrowest crossing)
- [ ] Found 2 October, small: 131 of 600 undead packs never moved in a 40-phase packs-only run because both approaches to their nearest gate hex were held by other packs (`sim/battlefield.gd` around 429-441), with no BLOCKED mark; the road's first slab on row 17 is overwritten by the gate clearing and the lone-slab pass runs before it (12 lone slabs on 200 maps); road branches can point south (directions 4 and 5) against the comment; `TERRAIN_WEIGHTS` and `_roll_terrain` are dead code; `BattleMap`'s default height says 14 rows against the game's 20
- [ ] The pacing pieces once Ryan's session decides them (the Ryan section): the threat bar, elites, Rift Pressure's escalation, the flattening as a rule ring (sim state the view reads and the save carries; it advances between phases with its next ring on the plan)
- [ ] Weld each machine at load (decided 2 October; bible section 11, the battery row): meshes merged by material within each moving group (the body, each `joint_*`, each `hp_*`), after the mounts are placed and before the traces, outline and hull attach, skipping hidden detail parts and anything looked up by name (the acts' glow parts, listed in each model's `art/models/<id>.rig.json` under `glow_parts`); a prototype-hangar swap re-welds. 682 meshes become 224 across the eleven. Count draw calls on the Mac before and after
- [x] The joint pass (decided 2 October; built 3 October in a cloud session, bible section 7, the joints row says what stands): every joint the row asked for, nested where it rides another, in `tools/lowforge/models_low.py`, with its axis and limits; the eleven models rebuilt with Blender 5.0.1 as a Python module and each checked geometry-identical to its committed file (only the node tree changed), so no render should differ
- [x] Every machine's idle acts, on the map and in the skirmish (decided 2 October; built 3 October): `game/ui/mech_rig.gd` plays each model's sidecar (`art/models/<id>.rig.json`, written by lowforge from `b.act(...)` beside the model) in `MechView3D` and `Map3D`, several acts a machine, never the same twice running, each instance on its own clock, limits clamped, a whole-body track, a per-instance glow; the limb-settle idle is gone; `RIFTGATE_ACTS_DEBUG=1` (or an act's name) runs them back to back
- [ ] Judge the acts and the gaits running (Ryan, on the Mac and the phone, with `RIFTGATE_ACTS_DEBUG=1` and `RIFTGATE_MOVE_DEBUG=1`, and a real move for the cornering): every number in `models_low.py`'s `b.act` blocks is a first cut, loud on purpose; the signs of a few leg lifts (the Clydesdale's hind hoof, the Armadillo's foot, the Ammit's weight shift) were reasoned, not seen; the Nemesis's fists come in without meeting (the arms are too far apart to touch); the Wild Boar's rev has no tread scroll yet (movement animations); the gap between acts is 2.5 to 6.5 seconds
- [x] Movement animations (decided 2 October; built 3 October in a cloud session, on the branch for Ryan to judge): each machine's gait in its sidecar (`b.gait(...)` beside the model): the walkers' hip, knee and ankle cycles keyed by distance in diagonal pairs (the Clydesdale, the Armadillo; the Baboon's knuckle-walk with the fists planting; the Nemesis's arms swinging against its legs; the Ammit's legs and planted lower arms), treads scrolling, wheels spun by their radius, the Prairie Dog's fronts steering, the Dingo's casters pointing along the travel while its facing lags the path, the Badger's booms carrying the claw clear, the flyers' boosters brightening and nacelles tilting, a rock on pulling away and stopping, a bank into turns from the cornering module in `Map3D` (the slide and bank per machine from `b.move`); `RIFTGATE_MOVE_DEBUG=1` drives every machine constantly on both screens; `tools/act_shot.gd ... gait <seconds>` freezes a stride. Then (3 October, later, on Ryan's word): the Wild Boar's and the Prairie Dog's turrets hold their aim while the hull turns under them (`hold_aim`, winding against the turn and relaxing once it runs straight); a machine with a slide sits off its path on the outside by how square its travel is to its facing (the Dingo 12 model units at a right angle, the hovercraft a third of that); the Stingray and the Puffin have three first-cut acts each (the emitter's turret scanning, the lance charging, the thrusters surging; the boosters flaring, the prow pulsing, a hop on the lift nozzles) and brighten their thrusters under way. Then (Ryan, 3 October): the Stingray moves like a helicopter, the first of one or two more to come (`strafe` and `tilt` in `b.move`: the map turns it to the facing it will end with and translates it there; it leans into its travel, nose down going forward, up going back, a side down going that way; no bank, no rock), and the Puffin like a jet crossed with the Dingo (banks 22, slides 0.6, boosters for propulsion). Left: feet arc a little through the stance since the map moves the body at one speed
- [ ] Foe roles: undefined anywhere, so nothing built; Ryan proposes what a role is before it is coded
- [ ] A dedicated hunter foe and the rift spawning formations, once Ryan has proposed them (the Ryan section)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the engagement zone first
- [x] A mixed-pack cell in `tools/balance.gd` (2 October: each faction's whole spawn list as one formation cell); rerun after each engine piece, and read bands, not numbers

## Map and screens

- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [ ] Props by hex back in the big batches, with the fade (decided 2 October; bible section 11, the battery row): each prop vertex carries its hex, the props' shader reads a small per-hex texture, the per-hex prop meshes in `game/battle/map_3d.gd` (`_prop_meshes`) go back into the bands. The texture fades a hex's props out as a machine enters and in as it leaves, with a setting to hold them see-through while it stands; a dither fade first, true alpha as the alternative; a debug switch to judge it running
- [ ] The 3D at 30 while planning, after the acts and movement exist, since it can only be judged against them (decided 2 October to try; bible section 11): only the 3D layers (the map's scene and units layer, each skirmish machine view) drop to 30 while nothing in them moves fast, back to 60 for moves, strikes and the dive; the 2D (HUD, board, the map's marks) stays at 60. Watch the scan bar's glow on the traces and grid, which is 3D; a debug switch, and Ryan judges on the phone
- [ ] The machines' scale on the map's hexes (Ryan, 2 October: needs adjusting): every machine is fitted to the same width today (`MARKER_FIT` in `game/battle/map_3d.gd`, a flyer at `FIT_FLYER`); Ryan says which way, then judge it running
- [ ] A prototype hangar in the game, no economy (Ryan, 2 October): try paints and hardpoint loadouts on every machine to check the looks, and carry the loadout into a battle for play tests (`Unit.paint` and the mounts exist; the harness's `RIFTGATE_PAINT` repaints for a look today)

## Art

- [ ] Enemy art through foeforge for the eight foes still on sketch grids (every foe but the ghoul, the one foeforge cut; checked pixel for pixel 2 October)
- [ ] The hangar as a model
- [ ] Consider, once the acts run: the Armadillo sealing its ports, the Lockdown Shutters made real (Ryan, 2 October: very cool, its own flavour). The guns retract into the shell first, a slide joints cannot do today, then shutters close over the ports, which need geometry; bible section 7, the joints row
- [ ] A licensed icon set (game-icons.net, CC BY) rendered to textures, replacing the line-drawn glyphs in one pass

## Pages (standing, after every content change)

- The hangar page (https://claude.ai/artifact/YAswJ7eGJ43ZFMQ6U1yhuH, the nameplate's link kept for its rows and its sharing): republish it with the `files` map `tools/hangar_data.py` prints after every content, model or render change, or its tabs go stale (source `tools/hangar.html`; a render round puts its pictures under `docs/hangar/renders/<chassis>/` and its entry in `docs/hangar/renders.json`)
- After Ryan edits on its Content tab: pull collection `edits` with ArtifactData, apply by hand, test, commit, republish, clear the documents
- Republish the bible from the committed file to its one URL (in status) after every bible change, from either account
- Re-seed the Melody Desk's `parts` after a track's voices change: `desk_parts.py`, then a batch `set` of the six `parts/<track>` documents (pinned to their versions), or a loaded part is the track as it was

## Audio

- [x] A speakers or headphones setting (2 October: not needed; the one master balances for both for now, Ryan)
- [ ] The Risen and Infernal Horde boss themes from their seeds; melodies proposed in chat first
- [ ] The effects' pass: Ryan's picks from the listening page land in `forge.py` with their hooks (shape, maker, faction, silhouette, the `sound` label; the replay telling a shield hit from a block from a hit, which `_land_blow` now plays as two)
- Stretch, not now: a modification that adds burn or shock to a component adds its sound layer
- [ ] The codex's open and close and the pause menu in the console grammar, once the console picks land

## Pinned, not now

- Low-hull berserker or last-stand ability
- Command die faces with a second, battlefield meaning
- Endless mode after the bounded campaign
- Hardwired hardpoints with a paid unlock (waits on the economy)
