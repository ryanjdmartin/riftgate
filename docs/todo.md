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
- [ ] Codex and flavour for the seven new machines, the Baboon's flavour, and the 42 components whose codex is empty
- [ ] Listen to the console's war room cut (2 October, night; section 1 of the listening page, the FM terminal and the channel beside it): the verbs alone first on the speaker, the grunts by maker, then the turn over the climax, then the events, then the turn over the climax; and the voice re-rendered judgeable (section 5: speak at all, Betty or VEGA, which lines). The weapons' third cut is parked as acceptable.
- [x] Run the tests on the Mac: the `sound` label's validation in `content_db.gd` landed from a cloud session with no Godot (2 October: green in the cloud too, Godot fetched into the session)
- [ ] Judge the limbs striking and the turrets flinching in the skirmish, running, and each machine's acts, movement and cornering once built; and each class's size per machine on a refit (a pin's `scale` in `models_low.py`)
- [ ] Propose in chat a Minerva intercept component for the starter set (Ryan, 30 September: tanks need class-based target-modification beyond the Proximity Klaxon; since 2 October the Klaxon is a lure with an area, and a lure on a weapon may be the intercept)
- [ ] A full play of Hold The Line in the game, start to wrap; notes by section letter
- [ ] Read `docs/balance.md` (2 October: the targeting pass and the playtest set in, the formation cells and the targeting comparison added) against your own play; then either the numbers move or the bot's next rung is built. This is the baseline question: whether 80 a round from a ghoul swarm is average or game-losing
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
- [ ] The generator's water feature judged with the two hovercraft, the Stingray and the Puffin (bible section 7, the hovercraft row; built 2 October in another session whose branch is not on main yet: merge it when it lands)
- [x] Enemy targeting among machines in a skirmish (2 October: every foe picks its own target by its aim, weighted and shown; the counterplay is Lure, Suppress and Disrupt, Shield, Armour and Brace; bible section 5)
- [x] Confirm the ghoul's one move (2 October: agreed and built; Claw, 5 plus 5 a kin on the field)
- [ ] The game's name
- [ ] Name and brief the second Aphelion machine: a hovercraft that runs hot, with heat as the suite's power (a stack per 20 heat held on every status it applies); a venomous sea creature's name; buffs exist now, so it can be built when briefed

## Engine

Nothing in content is planned any more; every piece the 28 September content leaned on runs since 30 September (bible section 7, "The 28 September pieces, built"). Movement by way of moving, the machine weld, the joint pass and the idle acts are decided and ready to build ; the rest waits on a design line from Ryan first. Nothing here is claimed by another session; a session that takes a line says so in this file.

- [x] The targeting pass (2 October, bible sections 5 and 9; built the same day with tests green): armour on foes; `aim` and the per-foe weighted pick; `when`, the no-repeat rule and attacks at 2 to a special's 1; Lure as a retarget on any foe-targeted entry; Disrupt; Brace as flat armour; the vocabulary; the nine foes rewritten
- [x] The runner reads targeting on the team cells (2 October: the shipped aims against the lowest-shield rule, in their own section of `docs/balance.md`)
- [ ] Phased (parked) and Corrode still want a design line first
- [ ] Judge the aims, the lure and the disrupt in play: whether the exposed weighting (hull reached plus half a breaking shield) leans hard enough, whether the swarm's opening 80 reads as pressure or as a wall, whether a disrupt into a boss's signature feels like a trick or a trap
- [ ] Movement by way of moving (decided 2 October; bible section 4, the movement row has the table and every reason). Grounds: `BattleMap` keeps its six terrains but reads four grounds (plain and road both open; road is art only), so `move_cost` becomes a word per way of moving and ground: fast 5, normal 10, slow (enterable with any move left, ends the move), wall. The words: tracked normal/normal/slow/normal (open/rough/ruins/water), walker normal/normal/normal/slow, wheeled fast/slow/slow/slow, hover normal/slow/slow/fast, flyer normal everywhere and over mountains; foes (no trait) normal on every land hex, water and mountains walls. `Battlefield`'s bounded search learns the stop: a slow hex is reachable with any move above 0 and the search does not expand from it. Moves in tens in content: every chassis's `movespeed` (today's guesses times ten as a start; Ryan sets them by size and role), and the foe moves into `content/foes.json` (packs 20, brute 30, boss 10) out of `Battle.PACK_SPEED`, `Unit.pack`'s default and the literal in `tick_pressure`; `dress_pack` applies movespeed to the boss too; the `3` default in `sim/content_db.gd`. The content check: a warning, never a refusal, when a ground chassis is at least as fast as another on every ground (hexes a phase on each ground, slow as 1; flyers exempt). Wheeled and Tracked to implemented in `content/vocabulary.json` with codex in the words; the terrain codex rewritten per way of moving (water's "impassable except for hover and flyer" and rough's "cost 1 for quads" are wrong today); a Rough and a Ruins line that say they differ. Foes binary needs, measured 2 October on 200 generated 7x20 maps: `_ensure_ground_path` checks with the foe rule and may carve water (7 maps cut today: seeds 36, 37, 51, 92, 113, 165, 199), with a test at 7x20 (it runs only at 7x13 today); foe crossings at least two or three hexes wide (one land hex is the only foe route on 49 of 193 maps under the rule); `passable`, `can_stand`, placement, `nearest_free` spawns and the boss patrol by the foe rule; a hunter or aggressive pack whose prey stands on a hex it cannot enter aims at the nearest hex it can reach within its zone of the prey (an impassable goal freezes it silently today). Presentation: slow hexes in the reach marked as end hexes by structure (a dashed edge), the move gauge the drawn route drains, the route plaque in tens, the codex's move with its open-ground hex count and the way of moving's words; the aggressive reach ring by the foe rule (it is drawn from the live field while the reaction uses post-move positions, so check the two agree). Rescale the movement phase's pace by movespeed, the hangar page's move column, bump `Save.VERSION`. Tests in `tests/test_map.gd` (the cost table), `test_battlefield.gd`, `test_battle.gd`, `test_battle_screen.gd`, `test_save.gd`, `test_content.gd`; tests use synthetic chassis, never an entry's move
- [ ] The generator's water feature (bible section 4, the movement row; with the hovercraft): one real river or lake band a map in place of puddles (6% of the field today, mean body under two hexes, never a river), with foe crossings two or three hexes wide that everyone may use; measure it on the 200-seed survey (the cloud session's `map_survey.gd` method: preload by path, generate at 7x20, count shares, cuts and the narrowest crossing)
- [ ] Found 2 October, small: 131 of 600 undead packs never moved in a 40-phase packs-only run because both approaches to their nearest gate hex were held by other packs (`sim/battlefield.gd` around 429-441), with no BLOCKED mark; the road's first slab on row 17 is overwritten by the gate clearing and the lone-slab pass runs before it (12 lone slabs on 200 maps); road branches can point south (directions 4 and 5) against the comment; `TERRAIN_WEIGHTS` and `_roll_terrain` are dead code; `BattleMap`'s default height says 14 rows against the game's 20
- [ ] The pacing pieces once Ryan's session decides them (the Ryan section): the threat bar, elites, Rift Pressure's escalation, the flattening as a rule ring (sim state the view reads and the save carries; it advances between phases with its next ring on the plan)
- [ ] Weld each machine at load (decided 2 October; bible section 11, the battery row): meshes merged by material within each moving group (the body, each `joint_*`, each `hp_*`), after the mounts are placed and before the traces, outline and hull attach, skipping hidden detail parts and anything looked up by name; a prototype-hangar swap re-welds. 682 meshes become 224 across the eleven. Count draw calls on the Mac before and after
- [ ] The joint pass (decided 2 October; bible section 7, the joints row lists every machine): add the joints the acts and movement need in `tools/lowforge/models_low.py` (elbows, hips, knees and ankles, the Badger's claw jaw, the Clydesdale's head, gun elevation, the Wild Boar's plow, wheel spin and steering, the Dingo's casters and harpoon pitch, the Goshawk's nacelles, the Ammit's talons and lower limbs), nested where they ride another joint; cockpits stay fixed except the Clydesdale's head. Then `forge.py build` on the Mac and one `--import`; the static model must not change, so a render before and after should match
- [ ] Every machine's idle acts, on the map and in the skirmish (decided 2 October; bible section 7, the idle-acts row has the pilot rule and the joints row each machine's acts): grounded machines never sway or bob, and every few seconds play one of their own acts, several to a machine (a requirement), never the same twice running, out of step with each other, loud enough for a phone. Engine: a caster joint prefix about up, full-rotation keyframes per joint, per-joint limits from the model (the Clydesdale's outward-only turrets, whose idle and flinch swing both ways today; the Dingo's casters), acts as a sidecar per model under `art/models` (never keyed on a chassis id in runtime code), a whole-body move for revs and strafes, a per-instance glow for charges. Replaces the limb-settle idle in `MechView3D`; a debug switch fires the acts constantly for Ryan to judge running
- [ ] Movement animations (decided 2 October; the joints row has each machine's): walkers walk while the map moves them (hip, knee and ankle cycles, feet never below the ground), treads scroll, wheels spin and steer, the Badger's booms lift the claw while it drives, flyers' boosters brighten and they bank, the Goshawk's nacelles tilt; the Dingo drifts on sideways steps and corners (wheels turned toward the move, body keeping its facing; Ryan, 2 October), through one cornering module the flyers and hovercraft share for banking, with a slide and a bank tuned per machine in its sidecar (Ryan, 2 October: the Dingo slides wildly, a hovercraft more controlled, the Sparrowhawk strafier than the Goshawk); the turrets holding aim as a hull turns is a proposal; a debug switch
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
