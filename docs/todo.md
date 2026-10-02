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
- [ ] Listen to the effects' second pass as re-cut 1 October on the listening page (console beeps, barrel, rack, blade, laser, plasma, deflector, the punch, blocks, the shield hit, the kills); picks land in `forge.py` with their hooks (shape, maker, faction, silhouette; the replay telling a shield hit from a block from a hit)
- [ ] A content word for the blunt melee pieces (Gravity Knuckles, Breaching Plow, bare fists) so a punch plays instead of a blade; Ryan names it
- [ ] Judge the turrets traversing and the limbs striking in the skirmish, running (idle scan, a flinch on a shot); and each class's size per machine on a refit (a pin's `scale` in `models_low.py`)
- [ ] A turret joint that turns outward only (the Clydesdale's, beside the lance): the view's idle and flinch swing both ways today
- [ ] Propose in chat a Minerva intercept component for the starter set (Ryan, 30 September: tanks need class-based target-modification beyond the Proximity Klaxon)
- [ ] A full play of Hold The Line in the game, start to wrap; notes by section letter
- [ ] Read `docs/balance.md` (1 October, every engine piece in) against your own play; then either the numbers move or the bot's next rung is built
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
- [ ] Name the wheels trait for the cars (the Prairie Dog and the Dingo), so movement in tens can land; then judge the move prices in play
- [ ] Enemy targeting and the horde hooks, in a design session Ryan is starting (2 October). Built: a foe strikes the machine drawing its rank (taunt or beacon), else the weakest shield, then the weakest hull; holding a foe draws its arrows. Open: whether foe types vary from that (highest heat, last attacker, random), a commander unit whose death scrambles a pack, how stupid the rank and file may be
- [ ] The game's name
- [ ] Name and brief the second Aphelion machine: a hovercraft that runs hot, with heat as the suite's power (a stack per 20 heat held on every status it applies); a venomous sea creature's name; buffs exist now, so it can be built when briefed

## Engine

Nothing in content is planned any more; every piece the 28 September content leaned on runs since 30 September (bible section 7, "The 28 September pieces, built"). Movement in tens, the machine weld, the joint pass and the idle acts are decided and ready to build (the wheels trait's name aside); the rest waits on a design line from Ryan first. Nothing here is claimed by another session; a session that takes a line says so in this file.

- [ ] The planned statuses still without an engine: Phased, Energy Armour; both want a design line first (what applies Phased, what Energy Armour's flat number is)
- [ ] The planned player keywords: Corrode, Scramble, Confuse
- [ ] Movement in tens (decided 2 October; bible section 4, the movement-in-tens row has the price table). Moves and costs become tens: every chassis's and foe's `movespeed` times ten in content (and the `3` default in `sim/content_db.gd`), `BattleMap.move_cost` returns the row's price by way of moving (tracks, the new wheels trait, walker, hover, flyer; the tank trait is tracks), `Battlefield` budgets read the new numbers unchanged. Wheels: a new trait in the vocabulary for the Prairie Dog and the Dingo, its name Ryan's (ask before landing). Leftover move is stranded; the one-hex fallback (a machine that has not moved may always enter one adjacent hex) only if Ryan finds stranding mean in play. Presentation: a move gauge the drawn route drains, each step's cost visible, the route plaque in tens, the codex's move with its plain-ground hex count, the terrain codex entries rewritten per way of moving (water's says impassable today, which is wrong since the fording row). Zones stay in hexes; an aggressive pack's reach is its move by cost then its zone in hexes (check the ring). Rescale the movement phase's pace by movespeed, the validator's floor, the hangar page's move column, and bump `Save.VERSION`. Tests in `tests/test_battlefield.gd`, `test_battle.gd`, `test_battle_screen.gd`, `test_save.gd`, `test_content.gd`
- [ ] Weld each machine at load (decided 2 October; bible section 11, the battery row): meshes merged by material within each moving group (the body, each `joint_*`, each `hp_*`), after the mounts are placed and before the traces, outline and hull attach, skipping hidden detail parts and anything looked up by name; a prototype-hangar swap re-welds. 682 meshes become 224 across the eleven. Count draw calls on the Mac before and after
- [ ] The joint pass (decided 2 October; bible section 7, the joints row lists every machine): add the joints the acts and movement need in `tools/lowforge/models_low.py` (elbows, hips, knees and ankles, the Badger's claw jaw, the Clydesdale's head, gun elevation, the Wild Boar's plow, wheel spin and steering, the Dingo's casters and harpoon pitch, the Goshawk's nacelles, the Ammit's talons and lower limbs), nested where they ride another joint; cockpits stay fixed except the Clydesdale's head. Then `forge.py build` on the Mac and one `--import`; the static model must not change, so a render before and after should match
- [ ] Every machine's idle acts, on the map and in the skirmish (decided 2 October; bible section 7, the idle-acts row has the pilot rule and the joints row each machine's acts): grounded machines never sway or bob, and every few seconds play one of their own acts, several to a machine (a requirement), never the same twice running, out of step with each other, loud enough for a phone. Engine: a caster joint prefix about up, full-rotation keyframes per joint, per-joint limits from the model (the Clydesdale's outward-only turrets, the Dingo's casters), acts as a sidecar per model under `art/models` (never keyed on a chassis id in runtime code), a whole-body move for revs and strafes, a per-instance glow for charges. Replaces the limb-settle idle in `MechView3D`; a debug switch fires the acts constantly for Ryan to judge running
- [ ] Movement animations (decided 2 October; the joints row has each machine's): walkers walk while the map moves them (hip, knee and ankle cycles, feet never below the ground), treads scroll, wheels spin and steer, the Badger's booms lift the claw while it drives, flyers' boosters brighten and they bank, the Goshawk's nacelles tilt; the Dingo drifts on sideways steps and corners (wheels turned toward the move, body keeping its facing; Ryan, 2 October), through one cornering module the flyers and hovercraft share for banking, with a slide and a bank tuned per machine in its sidecar (Ryan, 2 October: the Dingo slides wildly, a hovercraft more controlled, the Sparrowhawk strafier than the Goshawk); the turrets holding aim as a hull turns is a proposal; a debug switch
- [ ] Foe roles: undefined anywhere, so nothing built; Ryan proposes what a role is before it is coded
- [ ] A dedicated hunter foe and the rift spawning formations, once Ryan has proposed them (the Ryan section)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the engagement zone first
- [ ] A mixed-pack cell in `tools/balance.gd` (two packs in one contact), so overwhelm and the Databank can be read; then rerun after each engine piece, and read bands, not numbers

## Map and screens

- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [ ] If the phone drops frames: one mesh per material per machine
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

- [ ] A speakers or headphones setting (default speaker on a phone; Godot cannot tell what is plugged in): shipped levels for headphones, an offset per track and an EQ on the music bus for the speaker profile; discuss the offsets first
- [ ] The Risen and Infernal Horde boss themes from their seeds; melodies proposed in chat first

## Pinned, not now

- Low-hull berserker or last-stand ability
- Command die faces with a second, battlefield meaning
- Endless mode after the bounded campaign
- Hardwired hardpoints with a paid unlock (waits on the economy)
