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
- [ ] Listen to the effects' second pass as re-cut 1 October on the listening page (console beeps, barrel, rack, blade, laser, plasma, deflector, the punch, blocks, the shield hit, the kills); picks land in `forge.py` with their hooks (shape, maker, faction, silhouette; the replay telling a shield hit from a block from a hit); and whether the seated die (a die put back in its socket unused) wants a voice, a low quiet E3 the candidate, or stays toneless
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
- [ ] Movespeed in tens like every other number, or in hexes as now; the traits' terrain rules hinge on it (Ryan, 2 October: the tank faster on roads, how walker and hover costs read)
- [ ] Enemy targeting and the horde hooks, in a design session Ryan is starting (2 October). Built: a foe strikes the machine drawing its rank (taunt or beacon), else the weakest shield, then the weakest hull; holding a foe draws its arrows. Open: whether foe types vary from that (highest heat, last attacker, random), a commander unit whose death scrambles a pack, how stupid the rank and file may be
- [ ] The game's name
- [ ] Name and brief the second Aphelion machine: a hovercraft that runs hot, with heat as the suite's power (a stack per 20 heat held on every status it applies); a venomous sea creature's name; buffs exist now, so it can be built when briefed

## Engine

Nothing in content is planned any more; every piece the 28 September content leaned on runs since 30 September (bible section 7, "The 28 September pieces, built"). What is left waits on a design line from Ryan first. Nothing here is claimed by another session; a session that takes a line says so in this file.

- [ ] The planned statuses still without an engine: Phased, Energy Armour; both want a design line first (what applies Phased, what Energy Armour's flat number is)
- [ ] The planned player keywords: Corrode, Scramble, Confuse
- [ ] The tank trait, once movespeed is decided (the Ryan section): the vocabulary's intent is faster on roads, and a road costs what plain ground does today
- [ ] Foe roles: undefined anywhere, so nothing built; Ryan proposes what a role is before it is coded
- [ ] A dedicated hunter foe and the rift spawning formations, once Ryan has proposed them (the Ryan section)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the engagement zone first
- [ ] A mixed-pack cell in `tools/balance.gd` (two packs in one contact), so overwhelm and the Databank can be read; then rerun after each engine piece, and read bands, not numbers

## Map and screens

- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [ ] If the phone drops frames: one mesh per material per machine
- [ ] The machines' scale on the map's hexes (Ryan, 2 October: needs adjusting): every machine is fitted to the same width today (`MARKER_FIT` in `game/battle/map_3d.gd`, a flyer at `FIT_FLYER`); Ryan says which way, then judge it running
- [ ] A prototype hangar in the game, no economy (Ryan, 2 October): try paints and hardpoint loadouts on every machine to check the looks, and carry the loadout into a battle for play tests (`Unit.paint` and the mounts exist; the harness's `RIFTGATE_PAINT` repaints for a look today)

## Art

- [ ] Enemy art through foeforge for the eight foes still on sketch grids (every foe but the ghoul, the one foeforge cut; checked pixel for pixel 2 October)
- [ ] The hangar as a model
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
