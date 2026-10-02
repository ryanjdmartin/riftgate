# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next. Why, and the
direction behind it, live in the bible (section 12 is the roadmap); how things stand
today lives in `docs/status.md`. "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Play-test the engagement zones and the behaviours: the radii (front 1, back 3, boss 2 are placeholders), the ghoul as aggressive and the brute hunting the strongest at move 3, whether a hunter needs more move than a machine, whether fights come out big enough; the sandbox at https://claude.ai/artifact/VfmMXTs5w7itJUQRtCLCmg draws the zone rule
- [ ] Name a dedicated hunter foe (Ryan, 1 October: the brute's hunt is a placeholder; a stalker type with a caveat of its own, proposed in chat first)
- [ ] Formations (Ryan, 1 October): seed the opening enemy formations as threatening shapes with a front and a back, and have the rift spawn formations rather than single packs; shapes proposed in chat first
- [ ] Judge on the phone after a re-export: the machines' outline at 2.6 (`MechView3D.OUTLINE`; 1.0 was the thin), the intent field in motion (stripe width `STRIPE`, ring spokes `SPOKES`, the pulse), the machine's lock's contrast (the light at half), the orange pulse of the gate's hazard glyphs, the sound set, the grid at `GRID_GAIN_PHONE`
- [ ] Codex and flavour for the seven new machines, the Baboon's flavour, and the 42 components whose codex is empty
- [ ] Listen to the console derived again, second cut, the FM terminal (2 October, night; section 1 of the listening page): the verbs alone first, then the events, then the turn over the climax; and the voice re-rendered judgeable (section 5: speak at all, Betty or VEGA, which lines). The weapons' third cut is parked as acceptable.
- [ ] Run the tests on the Mac: the `sound` label's validation in `content_db.gd` landed from a cloud session with no Godot
- [ ] Judge the turrets traversing and the limbs striking in the skirmish, running (idle scan, a flinch on a shot); and each class's size per machine on a refit (a pin's `scale` in `models_low.py`)
- [ ] A turret joint that turns outward only (the Clydesdale's, beside the lance): the view's idle and flinch swing both ways today
- [ ] Decide whether the Clydesdale's hand-modelled turret pairs should match the twin-barrel class's spacing, since on a swap the class is what shows (the Prairie Dog's are the class now)
- [ ] Propose in chat a Minerva intercept component for the starter set (Ryan, 30 September: tanks need class-based target-modification beyond the Proximity Klaxon)
- [ ] A full play of Hold The Line in the game, start to wrap; notes by section letter
- [ ] Read `docs/balance.md` (1 October, every engine piece in) against your own play; then either the numbers move or the bot's next rung is built
- [ ] Discuss first, then decide: ally wrecks (block a hex? a round or the battle?)
- [ ] Discuss first, then decide: what terrain does in a skirmish (things the machines feel, never a bonus to the foes)
- [ ] Discuss first, then decide: base defences (gate guns, then turrets; `Battlefield.defenses()` is empty)
- [ ] Discuss first, then decide: the reinforcement phase, and whether skirmish composition follows placement
- [ ] Discuss first, then decide: when and how the multi-hex boss comes back (`Unit.TRIANGLE` waits)
- [ ] Discuss first, then decide: Rift Pressure feeding packs into the boss fight, so bum-rushing the boss is a race between temporary power gained and the boss's reinforcements (Ryan, 29 September: valid, fits the complexity wanted, tight to balance; hinges on how strong the in-battle temporary upgrades are, which do not exist yet)
- [ ] Discuss first, then decide: the final battle's source rift has a boss of its own (Ryan's lean, 29 September: probably yes, as the campaign's climax; The Far Bank may be that boss's track, being more doom-and-gloom than a fight, which would leave The Chorus wanting a theme from a seed)
- [ ] Discuss first, then decide: the economy and the blueprint tiers (nothing that prices anything can be designed before this)
- [ ] Discuss first, then decide: does a pack keep its foes' hull between fights (a withdrawal leaves them hurt today only in the count), and how the map shows it (the strength segments could show it)
- [ ] The ideas list: burning terrain, statuses carried between fights, hull repair
- [ ] Movespeed in tens like every other number, or in hexes as now
- [ ] Enemy targeting among machines in a skirmish (lowest shield, highest heat, last attacker, random) and how it is telegraphed
- [ ] The game's name
- [ ] Name and brief the second Aphelion machine: a hovercraft that runs hot, with heat as the suite's power (a stack per 20 heat held on every status it applies); a venomous sea creature's name; buffs exist now, so it can be built when briefed

## Engine

Nothing in content is planned any more; every piece the 28 September content leaned on runs since 30 September (bible section 7, "The 28 September pieces, built"). What is left waits on a design line from Ryan first. Nothing here is claimed by another session; a session that takes a line says so in this file.

- [ ] The planned statuses still without an engine: Phased, Energy Armour; both want a design line first (what applies Phased, what Energy Armour's flat number is)
- [ ] The planned player keywords: Corrode, Scramble, Confuse
- [ ] The tank trait (planned in the vocabulary; nothing defines what it does)
- [ ] Foe roles: undefined anywhere, so nothing built; Ryan proposes what a role is before it is coded
- [ ] A dedicated hunter foe and the rift spawning formations, once Ryan has proposed them (the Ryan section)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the engagement zone first
- [ ] A mixed-pack cell in `tools/balance.gd` (two packs in one contact), so overwhelm and the Databank can be read; then rerun after each engine piece, and read bands, not numbers

## Map and screens

- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [ ] If the phone drops frames: one mesh per material per machine
- [ ] The map growing wider if the engagement zones crowd it (bible section 5, still open)

## Art

- [ ] Ryan: judge the Baboon's rear silhouette in the harness (the fists hang at knee height now, not on the ground); if it still reads as carrying two boxes, pick heavier hands carrying hardware or a standard forward pose with the fist tile turned 90 degrees
- [ ] Enemy art through foeforge for the foes still on sketch grids
- [ ] The hangar as a model
- [ ] Per-mech repaint (`Unit.paint` exists; nothing sets it)
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
