# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next: how things stand is
`docs/status.md`, the rules are `docs/rules.md`, the why and the roadmap's order are the
bible (section 12). "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Read `docs/rules.md` once and answer the bible's section 12 questions (the rules, content, the campaign, the foes, look and sound); then a fresh session starts from CLAUDE.md, the rules and the status
- [ ] Name things: the Sparrowhawk's locked weapon (a subtler bird name; the Coriolis Accelerator is saved for another component), the loot (working names Derelict, Carcass, Relic), the game
- [ ] Text: codex and flavour for the nine new machines, the Baboon's flavour, the components without a codex; each maker's Sponsorship notice in its voice; the mitigation discussion for the bible
- [ ] Play the 10 October weapon rules: the die showing the number, rolled against flat, the two reaches, the Paradox meter, Numbed's chip
- [ ] Play the content revision's components and the modules (the harness's TEAM tab): the Wake Diffuser's tempo, the Maxigun into armour, the Oblation Ward's price, the Polarity Projector feeding the Baboon, the mirrored Booster and Databank; confirm the Susceptibility Tensor's name
- [ ] Play the four domains and their wildlife, the Thief's Flee and the plaque's rule; judge the plaque running on the phone (`SkirmishScreen.PLAQUE_HOLD`, `Plaque.px`, its place, whether a boss's plain blow earns one, a sound of its own)
- [ ] Play the round: the rings, the attack range, the hunters' catch, nine wide, the walks on the phone; every chassis's move and the movement words; the five map types and the water feature (`RIFTGATE_MAP_KIND`, the harness's picker); the move gauge on the phone
- [ ] Play the foes' aims, the lure and the disrupt: whether the exposed weighting leans hard enough, whether the swarm's opening blows read as pressure or as a wall, whether a disrupt into a boss's signature feels like a trick or a trap
- [ ] Judge on the phone after a re-export: the machines' outline at 2.6 (`MechView3D.OUTLINE`), the intent field in motion (`STRIPE`, `SPOKES`, the pulse), the machine's lock's contrast, the gate's hazard pulse, the grid at `GRID_GAIN_PHONE`
- [ ] Judge the motion running: the idle acts resting 6 to 12 s and opening in turn, the hovercraft's balancing idle, the drift through the double corner (Dingo, Puffin, Stingray), the Clydesdale's trot to gallop, the limbs striking and turrets flinching, each size class on the phone (`Map3D.SIZE_FIT`, `MechView3D.SIZE_FILL`)
- [ ] Hear the in-game sound on the phone and confirm or overturn the calls made landing it: a hovercraft steps like a flyer, information lines wait only for the line in progress and a second, no route tick, random pitch only on footfalls and plates; then a full play of Hold The Line, notes by section letter
- [ ] Discuss: the enemy turn under the spend chain's rule (a machine lost: Jenny's line at the landing in place of the kill blast, or after it as now)
- [ ] Read `docs/balance.md` and `docs/campaign_run.md` after their rerun: which placeholders move, and enemy damage against the team's durability (the next axis)
- [ ] Judge the campaign and the economy in play once the mission map and the hangar exist: twelve battles, the capital's bleed per fallen city, a battle in the shop, the module archetypes, about three rule texts a machine read running

### Discuss first, then decide

- [ ] Every maker's proposed chassis evaluated together by a fresh session, nothing built first (Ryan, 12 October): the Arsenal's in `docs/arsenal_proposal.md` (four chassis and a cleanse that moves debuffs onto a foe), the others where `docs/status.md` lists them, Aphelion's written down first; then the go and the build order
- [ ] The Armadillo's Faraday Hull: keep it, or let retaliation be the Arsenal's (Ryan is thinking about it: armoured, not a porcupine)
- [ ] The content questions, then the stock pass (Engine): tags on every component (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee as the working set), the basic kit's names, makers and numbers, the equipment basics' names, the twists for the Laminar Deflector and the Entropy Condenser
- [ ] The module catalogue again as soft-synergy pairs once tags are assigned, simple text; a new rule for the Ram Frame
- [ ] Heat from foes only through debuffs: names (the Overheating name goes), the ticking one at the end of the player's turn before the overheat, the softer one raising every weapon's heat per stack, maybe both, and a glyph of its own
- [ ] Chips as buffs and debuffs, the word "status" retired; Numbed stays its own kind
- [ ] The word "die" in shown text (Ryan, 13 October): the dice look like no dice, the problem that kept "face" out of shown text; a session of its own
- [ ] A gravity effect for the Gravity Knuckles (half damage to the foes beside the target, or pulling a back-rank foe forward); the Honey Badger's two locked weapons made interesting; the Faraday Hull's strength against rank and file
- [ ] The foes' fresh start, a session of its own: foe roles, a dedicated hunter foe (the Wolf, the Antlion and the Thief already hunt), formations with a front and a back spawned by the rift, the heroes' extra moves, the White Wizard's Shell
- [ ] Pacing, Ryan's session: the Rupture meter's numbers and prizes, elites, Rift Pressure's escalation, one backstop (the flattening reaching the gate, or a forced boss); Anathema's fill with it
- [ ] Ally wrecks (block a hex, for a round or the battle); what terrain does in a skirmish; base defences (gate guns, then turrets); the reinforcement phase; the multi-hex boss; Rift Pressure feeding the boss fight; packs keeping hull and statuses between fights
- [ ] A render margin round each skirmish machine view; attack acts, a session of their own
- [ ] The commander layer, once the balance has a baseline (bible section 8)
- [ ] Corrode and Phased: a design line before code

## Engine

- [ ] On merging `claude/focused-ritchie-omn8i5`: `docs/keyword_lineup.md` section 5 recast as leanings, never ownership, its list of exceptions to fix struck (Ryan, 13 October: a maker's profile is an identity, never an exclusion; the bible's row)
- [ ] Rally: Kindled reads its move's value and goes live from the next round, so every foe's shown intent stays exact (today a fixed +10 at once; the Wolf's Howl says 5)
- [ ] Jenny's foe-down lines keyed by domain, once Ryan says whether a domain borrows an old family's pool or gets its own
- [ ] The stock pass, after the content questions: the new tags in place of the internal filing tags (kinetic, energy, single, support), the basic kit, the old close weapons brought to Direct's band, the Headhunter's successor fixed on the Sparrowhawk (the die still a d4, so three hardpoints; the Goshawk's hardpoint a basic; the model with the rifle built in), the Zenith Emitter folded into the Laser Carbine, the Rivet Gun a basic on the Armadillo, the Blast Door and the Ram-air Scoop renamed, the Coolant Dump and the Blowout Stack retired, the Prairie Dog on the basic shield, the Baboon free to stock a shield; rebuild the Stingray's and the Baboon's models with their stock
- [ ] The heat debuffs, once named: the foes' heat moves (Stoke, Eruption) become debuffs, the tick moves to the end of the player's turn, the forecast shows it
- [ ] The balance runner's module rows (a fitted cell beside the stock one); then `tools/balance.gd` at 200 seeds and `tools/campaign_run.gd` on the four domains, read for a reach premium and for the Booster against the Databank
- [ ] The domains' engine gaps: a flee (the Needler's Scatter, the Thief's Flee), a cure and a harden on allies (the White Mage), a foe-side interpose (the Warrior's Cover) and retaliate (the Martial Artist's Counter, the Salamander's Ember Hide), the delayed blow (the Lancer's Jump), a blow at every machine, a self-damage rider (the Necromancer), a rare pack that flees on the map (the Gold Bug), the Mimic as loot, placement and the bleed by domain
- [ ] The party in `sim/campaign.gd`: the deal from each domain's `bench`, the party card, a domain's final against its dealt hero with its wildlife, the promoted form at the finale, the runner's party cell; a final counts only when the hero dies
- [ ] The promoted forms as entries (size 2, armour 5, one move more; names proposed in chat first) and the finale: the four in line, a beaten hero's column to boss-tier wildlife of the standing domains, elites and bosses behind
- [ ] Three bosses a domain before its hero: `boss` a list, each battle drawing one its domain has not ended on this run; the second and third written once Ryan moves the proposals
- [ ] Anathema as the weighted bar, and the pacing pieces, after Ryan's session
- [ ] The Sponsorship tallies in the run (Kestrel hexes moved, Minerva damage taken on shield and armour, Wainwright & Sutler dice spent on entries that deal damage, Aphelion on entries that deal none)
- [ ] The economy pass, a session of its own (`docs/economy_pass.md`): the runner's spending policy first, then every price and yield
- [ ] The hangar's economy verbs on the run (the host maker's offer, a token unpacked, building from a blueprint, fitting a module), procurement (each standing maker's stock for Favour, refreshed each turn; the Arsenal's trickle at the capital by the Convergence's tier) and loot on the map (seeded with the map, claimed by ending a move on one, a tap telling its kind and likely contents), after the economy pass
- [ ] Weld each machine at load (bible section 11): meshes merged by material within each moving group, skipping the acts' glow parts; count draw calls before and after
- [ ] Props by hex back in the big batches, with a fade as a machine enters (a debug switch to judge it)
- [ ] The 3D at 30 while planning, once the acts and movement are judged
- [ ] Hooks the game cannot fire yet: the flattening's spread, the loss by the city; the buff hook per keyword once the vocabulary is locked
- [ ] Onboarding: the gesture tutorial and the cheat sheet, the reroll rule and the round first
- [ ] The hangar page's Names board follows the naming guidelines (a maker-free parts tab, the rules text)

## Map and screens

- [ ] A prototype hangar in the game, no economy: paints on every machine and a refit's look before a battle (`Unit.paint`, `RIFTGATE_PAINT`)
- [ ] The mission map (the capital centred, four cities, each front a card of words: domain, guest, ground, tier, how long its gate holds; a fallen city's horde marching on the centre; the capital's gate the one bar) and the hangar (the shop, the roster, the host maker's offer)
- [ ] The draft screen: the tender, take three (`Campaign.tender`, `Campaign.new(seed, team)`)
- [ ] The wreck's death on the map, and corruption in a pack's wake, once decided

## Art

- [ ] Ryan's touch-ups on the picked foes (missing arms, weapons through hands) on the sources in `tools/foeforge/picks`, recut with `forge.py cut` and the options `picks.json` records (on main)
- [ ] Judge the 72x96 foes on the phone (the frame, the whole-pixel slot, the sharpen's strength), then recut every pick at the strength chosen
- [ ] The foe picker on the phone: a session reads the `picks` collection and cuts the new picks
- [ ] Battle-pose takes for the other 23 foes and heroes, on Ryan's go (he called the Goblin, Revenant and Cockatrice takes workable, 9 October): four takes each in `design.variants` (costume and pose over the same anatomy, colour pinned, a small head on humanoids, never "facing the party"), `forge.py generate <foe> --variants --tag takes`, then `forge.py phone --tags takesD takes` and republish the picker
- [ ] The four bleeds for the flattened ground
- [ ] The hangar as a model; a licensed icon set (game-icons.net, CC BY) in place of the line-drawn glyphs, in one pass
- [ ] Each component class's size per machine on a refit (a pin's `scale` in `models_low.py`); the Armadillo's Lockdown Shutters made real, if Ryan takes it up

## Audio

- [ ] Level the other five tracks against Hold The Line through the phone model
- [ ] Boss themes for the Meadow, the Waste, the Peak and the finale, melodies proposed in chat first
- [ ] The codex's open and close and the pause menu in the console's grammar
- [ ] A foe death per domain, later
- Stretch, not now: a burn or shock modification adds its own sound layer

## Pages (standing)

- Republish the bible from the committed file to its one URL (in status) after every bible change
- Republish the hangar page with `tools/hangar_data.py`'s map after every content, model or render change (add `content/modules.json` to the map first)
- After Ryan edits on the hangar's Content tab: pull `edits` with ArtifactData, apply by hand, test, commit, republish, clear the documents
- Re-seed the Melody Desk's `parts` after a track's voices change (`desk_parts.py`)

## Pinned, not now

- A low-hull berserker or last-stand entry; command entries with a battlefield meaning; an endless mode; livery by Sponsorship once the hangar exists; Jenny's idle nag; a map taunt for a slow Arsenal bruiser; a machine that moves after it fights; Hellfire as an Arsenal component prefix (Ryan, 12 October)
