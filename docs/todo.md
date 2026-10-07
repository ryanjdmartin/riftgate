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
- [ ] Listen to the console's war room cut (2 October, night; section 1 of the listening page, the FM terminal and the channel beside it): the verbs alone first on the speaker, the grunts by maker, then the turn over the climax, then the events, then the turn over the climax; and the voice re-rendered judgeable (section 5: speak at all, Betty or VEGA, which lines). The weapons' third cut is parked as acceptable.
- [ ] Judge the limbs striking and the turrets flinching in the skirmish, running, and each machine's acts, movement and cornering once built; and each class's size per machine on a refit (a pin's `scale` in `models_low.py`)
- [ ] Propose in chat a Minerva intercept component for the starter set (Ryan, 30 September: tanks need class-based target-modification beyond the Proximity Klaxon; since 2 October the Klaxon is a lure with an area, and a lure on a weapon may be the intercept)
- [ ] A full play of Hold The Line in the game, start to wrap; notes by section letter
- [ ] Read `docs/balance.md` (2 October, night: the targeting pass, the playtest set, the formation cells, the targeting comparison and the two hovercraft in; the Stingray in the support band with its vent never spent, the Puffin unreadable alone) against your own play; then either the numbers move or the bot's next rung is built. This is the baseline question: whether 80 a round from a ghoul swarm is average or game-losing
- [ ] Discuss first, then decide: ally wrecks (block a hex? a round or the battle?)
- [ ] Discuss first, then decide: what terrain does in a skirmish (things the machines feel, never a bonus to the foes; burning terrain a candidate)
- [ ] Discuss first, then decide: base defences (gate guns, then turrets; `Battlefield.defenses()` is empty)
- [ ] Discuss first, then decide: the reinforcement phase, and whether skirmish composition follows placement
- [ ] Discuss first, then decide: when and how the multi-hex boss comes back (`Unit.TRIANGLE` waits)
- [ ] Discuss first, then decide: Rift Pressure feeding packs into the boss fight, so bum-rushing the boss is a race between temporary power gained and the boss's reinforcements (Ryan, 29 September: valid, fits the complexity wanted, tight to balance; hinges on how strong the in-battle temporary upgrades are, which do not exist yet)
- [ ] Decide the makers' measures (bible section 10, recommended: relative, one a maker, Kestrel hexes moved, Minerva damage taken on shield and armour, Wainwright dice spent on attacks, Aphelion status stacks applied, the Arsenal absolute at the top threat tier) and write each maker's notice in its voice
- [ ] Read `docs/campaign_run.md` (6 October, the first whole runs, and since 7 October who each fight holds; every number in `sim/campaign.gd` a placeholder) and say which placeholders move. Decided 7 October: a won battle restores the whole gate, a lever for higher tiers. Open: the starting draft (proposed in chat 7 October), tiers on chassis, the rush's price (each wreck its own cost)
- [ ] Name the in-battle bar (the pacing row's; Ryan, 7 October: arcane or pseudo-science, reading as forcing our way through, never serving them; candidates in chat that day: Rupture, Fracture, Dissonance, Incursion)
- [ ] Propose in chat a new passive for the Prairie Dog: its screen lets machines out before the enemy strikes and makes blows miss as the team leaves, which the guaranteed enemy turn on a withdrawal now forbids (Ryan, 7 October)
- [ ] Battlefield chests (decided 7 October, bible section 10, the salvage row): decide how many a map holds and where, how a machine takes one, and what a held or fallen battle does with them; then the engine and the end screen build them
- [ ] Faction finals (Ryan, 7 October: a tougher fight against a tougher boss, the faction's leader): a bar per faction on the mission map, Anathema, draws the leader out (Ryan, 7 October); decide what fills it (recommended 7 October: section 4's pacing calculation, every kill weighted by its danger, the same tally as the in-battle threat bar, settled with the pacing session) and propose each faction's leader in the enemy roster session
- [ ] Judge the campaign and the economy in play once the mission map and the hangar exist: twelve battles as the length, the capital's bleed per fallen city, one battle in the shop, the module archetypes, the budget of about three rule texts a machine read running
- [ ] Discuss first, once the balance has a baseline (Ryan, 2 October): the commander layer, bible section 8 (the reward pick after a won skirmish, one-shots, city abilities, whether the command die exists); it needs heavy UI work and a place on the skirmish screen, and Rift Pressure in the boss fight waits on its rewards
- [ ] Discuss first, then decide: does a pack keep its foes' hull and statuses between fights (a withdrawal leaves them hurt today only in the count), and how the map shows it (the strength segments could show it)
- [ ] Judge the movement words and every chassis's move in play once movement by way of moving lands (bible section 4, the movement row); the moves follow size and role, the content check only flags a chassis at least as fast as another on every ground
- [ ] Pacing, in a design session (bible section 4, the pacing row, open 2 October): the threat bar (its name, the marks and their prizes, the mark that unseals the boss, the extra marks past it), the elite tier (what elites are; costly for the Sparrowhawk to stay on, not unreachable), Rift Pressure's escalation (faster, worse packs), and the flattening reaching the gate as the hard backstop (or a Loop Hero forced boss; one, not both)
- [ ] Judge the water feature in play with the two hovercraft, the Stingray and the Puffin (built 3 October; bible section 4, the movement row): a river with fords or a lake band, one a map; the map survey says the river barely changes how far anyone gets, so its bite is where the horde crosses and where a walker off the ford stops; and the move gauge on the phone (`draft` and `draftslow` screenshot poses)
- [ ] The game's name
- [ ] Judge the skirmish's hover idle pitch (`sway_pitch`, 2 October) against the rig's tilt and the hovercraft's acts running; retire the idle pitch if the rig's acts cover it
- [ ] Read the Puffin in play: the overshield on an ally against a heavy round, the vent on the Stingray
- [ ] Judge the Badger's Bullion Fragmenter from the renders (first pass 6 October: a housing with a hazard band, a collar and a tapering chisel on the right boom where the barrel mount was)
- [ ] Reset the Armadillo's and the Wild Boar's loadouts: their Slug Cannon slots carry the Rivet Gun as a stopgap since 6 October (the Boar's two of them)
- [ ] The Names board (the hangar page's names tab) follows the vocabulary guidelines of 6 October rather than maker claims: its maker tabs for chassis stay, its parts tab is maker-free (the labels came off 6 October), its rules text wants the guidelines; rework the page once the movement session is done with it

## Engine

- [x] The campaign state and the between-battle rules (6 October, first pass on Ryan's go; bible section 3's rows of 6 October): `sim/campaign.gd` (cities and gates, rifts rolled as fronts, the roster and its shop, salvage, tokens, offers owed, blueprints, the threat and the finale), `sim/profile.gd` (what outlives a run), the run and the profile in `sim/save.gd`, `sim/battle_bot.gd` and `tools/campaign_run.gd` playing whole runs
- [x] The runner counts components destroyed per won battle on the greedy ladder (6 October: `tools/campaign_run.gd`, whole battles in whole runs; its reading is in `docs/campaign_run.md` and the bible's numbers row)
- [ ] The makers' favour tallies in the run (bible section 10, the measures row: hexes moved, damage taken on shield and armour, dice spent on attacks, status stacks applied, per maker), once Ryan decides the measures
- [ ] The hangar's economy verbs on the run: the host maker's offer, a research token unpacked, building from a blueprint, fitting a module (the run already holds offers owed, tokens and blueprints); waits on the catalogues and the numbers row

Nothing in content is planned any more; every piece the 28 September content leaned on runs since 30 September (bible section 7, "The 28 September pieces, built"). The machine weld is decided and ready to build; the joint pass and the idle acts are built (3 October, a cloud session; Ryan judges them running next); movement by way of moving is built; the rest waits on a design line from Ryan first. Nothing here is claimed by another session; a session that takes a line says so in this file.

- [ ] Phased (parked) and Corrode still want a design line first
- [ ] Judge the aims, the lure and the disrupt in play: whether the exposed weighting (hull reached plus half a breaking shield) leans hard enough, whether the swarm's opening 80 reads as pressure or as a wall, whether a disrupt into a boss's signature feels like a trick or a trap
- [ ] Left from the movement build: the hangar page's foes, components and vocabulary files republished from main (its chassis file carries the tens and the hovercraft since 2 October, night; the other three are ahead of main from another session's tuning, so republish them once that work lands, never over it)
- [x] The small finds of 2 October, built 6 October (Ryan's rule: packs retarget, a stalled horde is never the norm): a pack held off its gate hex by its own side turns for the next gate hex or defence it can reach, one with no goal waits with a STALLED mark in the plan (156 of 600 packs stood still in the packs-only run on 200 maps, 2 after, both marked); the gate clearing keeps the road's first slab and branches run north only (no lone slab on 200 maps, was 11); the dead terrain code and the map's default height had already gone; save version 3, since the roads changed under every seed
- [ ] The pacing pieces once Ryan's session decides them (the Ryan section): the threat bar, elites, Rift Pressure's escalation, the flattening as a rule ring (sim state the view reads and the save carries; it advances between phases with its next ring on the plan)
- [ ] Weld each machine at load (decided 2 October; bible section 11, the battery row): meshes merged by material within each moving group (the body, each `joint_*`, each `hp_*`), after the mounts are placed and before the traces, outline and hull attach, skipping hidden detail parts and anything looked up by name (the acts' glow parts, listed in each model's `art/models/<id>.rig.json` under `glow_parts`); a prototype-hangar swap re-welds. 682 meshes become 224 across the eleven. Count draw calls on the Mac before and after
- [ ] Judge the acts and the gaits running (Ryan, on the Mac and the phone, with `RIFTGATE_ACTS_DEBUG=1` and `RIFTGATE_MOVE_DEBUG=1`, and a real move for the cornering; or first on the hangar page's Models tab, whose Route shows the cornering without a battle): every number in `models_low.py`'s `b.act` blocks is a first cut, loud on purpose; the signs of a few leg lifts (the Clydesdale's hind hoof, the Armadillo's foot, the Ammit's weight shift) were reasoned, not seen; the Nemesis's fists come in without meeting (the arms are too far apart to touch); the Wild Boar's rev has no tread scroll yet (movement animations); the gap between acts is 2.5 to 6.5 seconds
- [ ] Judge the second pass running (4 October; bible section 7, the joints row): the longer, louder acts on every machine, and the moves on a real map: the 0.55 seconds a hex, each machine's acceleration and corner braking (`b.move(accel=, corner=)` in `models_low.py`), the smoothed corners, the eased turn to rest; and say whether the packs (still 0.22 a hex, straight steps) should slow too
- [ ] Foe roles: undefined anywhere, so nothing built; Ryan proposes what a role is before it is coded
- [ ] A dedicated hunter foe and the rift spawning formations, once Ryan has proposed them (the Ryan section)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the engagement zone first

## Map and screens

- [ ] The mission map (bible section 3, decided 5 October; its rules run in `sim/campaign.gd` since 6 October): the capital centred, the four cities around it, each front a card of words (faction, ground type, threat tier, the gate's bleed if ignored), a fallen city's horde drawn marching on the centre, the capital's gate as the one bar; and the hangar with the shop, the roster (in the shop or ready, dressed or bare) and the host maker's offer
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

- [ ] The Risen and Infernal Horde boss themes from their seeds; melodies proposed in chat first
- [ ] The effects' pass: Ryan's picks from the listening page land in `forge.py` with their hooks (shape, maker, faction, silhouette, the `sound` label; the replay telling a shield hit from a block from a hit, which `_land_blow` now plays as two)
- Stretch, not now: a modification that adds burn or shock to a component adds its sound layer
- [ ] The codex's open and close and the pause menu in the console grammar, once the console picks land

## Pinned, not now

- Low-hull berserker or last-stand ability
- Command die faces with a second, battlefield meaning
- Endless mode after the bounded campaign (twelve battles the working length)
- Hardwired hardpoints with a paid unlock (waits on the economy)
- Livery colours unlocked by a maker's favour, free on any machine (decided 5 October, bible section 10; after the hangar exists)
