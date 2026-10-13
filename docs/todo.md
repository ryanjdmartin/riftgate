# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next: how things stand is
`docs/status.md`, the rules are `docs/rules.md`, the why and the roadmap's order are the
bible (section 12). "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Read `docs/rules.md` once, the bible's first row (how to read a row, 13 October) and its section 12 questions (the rules, content, the campaign, the foes, look and sound), the stock rule's hole among them; then a fresh session starts from CLAUDE.md, the rules and the status
- [ ] Name things: the loot (working names Derelict, Carcass, Relic), the game
- [ ] Text: codex and flavour for the nine new machines, the Baboon's flavour, the components without a codex; each maker's Sponsorship notice in its voice; the mitigation discussion for the bible
- [ ] Play the 10 October weapon rules: the die showing the number, rolled against flat, the two reaches, the Paradox meter, Numbed's chip
- [ ] Play the 11 October builds: the Badger's hopper (the claw fills a load a foe, the fragmenter fires three at +5), the overheat at the end of the turn, armour off a breach's overflow
- [ ] Play the 12 October builds: the Breaching Plow bracing the Boar (two stacks until the round's end, the Glacis gone), the Laminar Deflector's rapid 20, the Entropy Condenser's volatile 40, the Nemesis's rage (its fists rolling again; a fist that shows again punches again); and of 13 October: the rage's burst and flip (`RIFTGATE_RAGE_DEBUG=1`), the fists without Burn, the Peak's fire as Burning and Scorched (the tick at the end of your turn, before the overheat; scorched weapons running hotter)
- [ ] Play the content revision's components and the modules (the harness's TEAM tab): the Wake Diffuser's tempo, the Maxigun into armour, the Oblation Ward's price, the Polarity Projector feeding the Baboon, the mirrored Booster and Databank; confirm the Susceptibility Tensor's name
- [ ] Play the four domains and their wildlife, the Thief's Flee and the plaque's rule; judge the plaque running on the phone (`SkirmishScreen.PLAQUE_HOLD`, `Plaque.px`, its place, whether a boss's plain blow earns one, a sound of its own)
- [ ] Play the round: the rings, the attack range, the hunters' catch, nine wide, the walks on the phone; every chassis's move and the movement words; the five map types and the water feature (`RIFTGATE_MAP_KIND`, the harness's picker); the move gauge on the phone
- [ ] Play the foes' aims, the lure and the disrupt: whether the exposed weighting leans hard enough, whether the swarm's opening blows read as pressure or as a wall, whether a disrupt into a boss's signature feels like a trick or a trap
- [ ] Judge on the phone after a re-export: the machines' outline at 2.6 (`MechView3D.OUTLINE`), the intent field in motion (`STRIPE`, `SPOKES`, the pulse), the machine's lock's contrast, the gate's hazard pulse, the grid at `GRID_GAIN_PHONE`
- [ ] Judge the motion running: the idle acts resting 6 to 12 s and opening in turn, the hovercraft's balancing idle, the drift through the double corner (Dingo, Puffin, Stingray), the Clydesdale's trot to gallop, the limbs striking and turrets flinching, each size class on the phone (`Map3D.SIZE_FIT`, `MechView3D.SIZE_FILL`)
- [ ] Hear the in-game sound on the phone and confirm or overturn the calls made landing it: a hovercraft steps like a flyer, information lines wait only for the line in progress and a second, no route tick, random pitch only on footfalls and plates; then a full play of Hold The Line, notes by section letter
- [ ] Discuss: the enemy turn under the spend chain's rule (a machine lost: Jenny's line at the landing in place of the kill blast, or after it as now)
- [ ] Read `docs/campaign_run.md` (rerun 13 October on the four domains: 3 of 40 runs won, 6% of battles, most fights solo) and `docs/balance.md` (rerun 13 October at 200 seeds; the bands in `docs/measurements.md`): which placeholders move, which of the domains and the 10 to 13 October rules made the campaign a wall for a plain player, and enemy damage against the team's durability (the next axis)
- [ ] Judge the campaign and the economy in play once the mission map and the hangar exist: twelve battles, the capital's bleed per fallen city, a battle in the shop, the module archetypes, about three rule texts a machine read running

### Discuss first, then decide

- [ ] Every maker's proposed chassis evaluated together by a fresh session, nothing built first (Ryan, 12 October): the Arsenal's in `docs/arsenal_proposal.md` (four chassis and a cleanse that moves debuffs onto a foe), the others where `docs/status.md` lists them, Aphelion's written down first; then the go and the build order; the proposals are work in progress on their branches (Ryan, 13 October). The evaluation re-reads each proposal's "out of bounds" and "must not cross" lists under the Lean rule (the bible's first row): those lists are Ryan's to write, and each proposal's bench shows what a rule killed so he can overrule the rule
- [ ] The Armadillo's Faraday Hull: keep it, or let retaliation be the Arsenal's strongest suit alone (Ryan is thinking about it: armoured, not a porcupine); folded into the chassis evaluation (Ryan, 13 October)
- [ ] The stock rule's hole (the review of 13 October; bible section 10): the Arsenal makes no tier one, so under "a chassis stocks only below its own tier" its tier-two machines (the Nemesis, the proposed Misharu and Onryō) can stock nothing of its own. Other makers' basics on them, "at or below", or an Arsenal tier one
- [ ] The content questions, then the stock pass (Engine): tags on every component (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee as the working set; Melee stays, Ryan 12 October), the basic kit's names, makers and numbers, the equipment basics' names (the twists landed 12 October)
- [ ] The keyword line-up (`docs/keyword_lineup.md`; Ryan's answers of 11 and 12 October in it): the area set tested (the half rule, danger close gone, explosives carrying Spread and Penetrate; if they need no price on the firer, Splash folds into the two), Chain's jump to the weakest foe in reach and its maker (area is no part of Kestrel's brief), Breach the foes' word, Braced for Folded, which maker owns which keyword; a tight list is no priority until the content is locked (Ryan); the Artillery Rangefinder's new rule
- [ ] Injuries, a session of their own with the economy (Ryan, 12 October: shelved until then): one state at half the hull, the cracked state gone, measured 12 October to keep today's losses and move no fight
- [ ] The module catalogue again as soft-synergy pairs once tags are assigned, simple text; a new rule for the Ram Frame (Ryan, 11 October: "all weapons Direct" is free on an open build, hurting only locked indirect weapons; Claude's next: "its die can't be rerolled") and for the Artillery Rangefinder, whose rule goes with danger close
- [x] The heat debuffs: Burn and Scorch (Ryan, 13 October), built the same day; Burning on a machine has a glyph of its own (Ryan, 13 October: Burn's flame solid, the thermometer cut out)
- [ ] Chips as buffs and debuffs, the word "status" retired; Numbed stays its own kind
- [x] The Nemesis's rage, built 12 October (the passive banks a rage on all hull damage, the new locked fists spend one to roll again with no switch-off, a plain roll): measured in the bible's row; its numbers wait on Ryan's play
- [x] The Faraday Hull against rank and file: the discharge went (Ryan, 11 October)
- [ ] The Honey Badger's identity (Ryan, 12 October: a scrappy machine that keeps on coming, not a scaling threat; damage, support, tank, or its mining roots?): Claude's options in the bible's row (won't stay down, the campaign's workhorse, more salvage), the hopper kept as its kit; folded into the chassis evaluation (Ryan, 13 October)
- [ ] Aphelion's next chassis (Ryan, 11 October: badly needed), proposed in chat first
- [ ] What a tier means for chassis, components and modules, whether a starting chassis is replaced or kept, and rolled module stats (Ryan's questions, 11 October; Claude's lean and the measured tiers in the bible's section 10 row); decided 12 October: the basics tier zero, a chassis stocking only below its own tier, a bought chassis bringing its stock and never the blueprints, tier three the most unique effects and raw power, tier two most of the synergy pieces
- [x] The Glacis: the plow braces the Boar instead (Ryan, 12 October), built
- [ ] The Arsenal's register (Ryan, 11 October, not sure): a pivot to the demonic and occult, hellfire free now the demons are gone, the eldritch left to the Council; what the Council names a machine and what it manifests as may differ (Ryan, decided); a secret true final boss, an Arsenal extradimensional superweapon
- [x] What a hand holds: tabled (Ryan, later on 12 October), the bible's row pinned with where hands would be
- [ ] Modules as a priced stat bundle and a priced rule (Ryan, 12 October; Claude: generated to one budget, so an offer asks which fits; or the catalogue's rules with generated stat lines)
- [ ] More turnover in the roster (Ryan, 12 October: machines easier to scrap); read with the foes' damage axis, wrecks being rare while teams win nearly every fight
- [ ] Our armour first, before the foes' numbers (Ryan, 12 October; measured: 5 less moves the teams a point or two, the heavy machines closing on the light ones alone): how much lower (by 2 or 3 if need be: the scales are magnitudes), then the fight's size (several packs, formations) read through the campaign runner rerun on today's rules
- [ ] The foes' fresh start, a session of its own: foe roles, a dedicated hunter foe (the Wolf, the Antlion and the Thief already hunt), formations with a front and a back spawned by the rift, the heroes' extra moves, the White Wizard's Shell
- [ ] Pacing, Ryan's session: the Rupture meter's numbers and prizes, elites, Rift Pressure's escalation, one backstop (the flattening reaching the gate, or a forced boss); Anathema's fill with it
- [ ] Ally wrecks (block a hex, for a round or the battle); what terrain does in a skirmish; base defences (gate guns, then turrets); the reinforcement phase; the multi-hex boss; Rift Pressure feeding the boss fight; packs keeping hull and statuses between fights
- [ ] A render margin round each skirmish machine view; attack acts, a session of their own
- [ ] The commander layer, once the balance has a baseline (bible section 8)
- [ ] Corrode and Phased: a design line before code

## Engine

- [x] Rally, built 13 October: Kindled carries its move's value and goes live from the next round, so every foe's shown intent stays exact
- [ ] Jenny's foe-down lines keyed by domain, once Ryan says whether a domain borrows an old family's pool or gets its own
- [ ] The stock pass, after the content questions: the new tags in place of the internal filing tags (kinetic, energy, single, support), the basic kit, the old close weapons brought to Direct's band, the Pinion Driver fixed on the Sparrowhawk (the die still a d4, so three hardpoints; the Goshawk's hardpoint a basic; the model with the driver built in), the Zenith Emitter folded into the Laser Carbine, the Rivet Gun a basic on the Armadillo, the Blast Door and the Ram-air Scoop renamed, the Coolant Dump and the Blowout Stack retired, the Prairie Dog on the basic shield, the Baboon free to stock a shield, every tier-one chassis on basics beside its locked piece (the Sparrowhawk's Railgun, Arc Fault Cannon and Deflector out; the Stingray and the Baboon too, the Stingray moved 11 October), each component's tier in its entry with the basics at zero, the run starting with their blueprints and every chassis stocking below its own tier, the Boar's Spillover chips shown as the star; rebuild the Stingray's and the Baboon's models with their stock
- [x] The heat debuffs, built 13 October: Burning ticking at the end of the player's turn before the overheat, Scorched heating the weapons fired for the turn (every stack going at its end), Stoke, Eruption, Fira and Hellfire converted, the forecast, the die's heat and the bot's cleanse reading them
- [ ] The balance runner's module rows: `--module` and `--rows` built 11 October (a module on every machine, a run beside one without); a fitted cell beside the stock one in the report is next, read for a reach premium (the Booster and the Databank measured even, 11 October)
- [ ] A measurement of the fights a team fights together under a bot that bunches by design (`docs/measurements.md`, 13 October: with a team on the field two thirds of the campaign's fights are solo), before the module rows and the economy pass read the team rows as the game
- [ ] The bot's valuations for the mechanics the proposals need before the batch evaluation measures them (a sentence, a doubling, a turn of the ranks, a wound, the boiler's blast), or the rollout rung; until then the runner's verdict on them is a verdict on the bot and the evaluation says so
- [ ] The domains' engine gaps: a flee (the Needler's Scatter, the Thief's Flee), a cure and a harden on allies (the White Mage), a foe-side interpose (the Warrior's Cover) and retaliate (the Martial Artist's Counter, the Salamander's Ember Hide), the delayed blow (the Lancer's Jump), a blow at every machine, a self-damage rider (the Necromancer), a rare pack that flees on the map (the Gold Bug), the Mimic as loot, placement and the bleed by domain
- [ ] The party in `sim/campaign.gd`: the deal from each domain's `bench`, the party card, a domain's final against its dealt hero with its wildlife, the promoted form at the finale, the runner's party cell; a final counts only when the hero dies
- [ ] The promoted forms as entries (size 2, armour 5, one move more; names proposed in chat first) and the finale: the four in line, a beaten hero's column to boss-tier wildlife of the standing domains, elites and bosses behind
- [ ] Three bosses a domain before its hero: `boss` a list, each battle drawing one its domain has not ended on this run; the second and third written once Ryan moves the proposals
- [ ] Anathema as the weighted bar, and the pacing pieces, after Ryan's session
- [ ] The Sponsorship tallies in the run (Kestrel hexes moved, Minerva damage taken on shield and armour, Wainwright & Sutler dice spent on entries that deal damage, Aphelion on entries that deal none)
- [ ] The economy pass, a session of its own (`docs/economy_pass.md`): the runner's spending policy first, then every price and yield
- [ ] Prices and tier ladders (Ryan, 11 and 12 October: a component is balanced against its tier's others, never by a chassis's solo win rate): each stocked component by knock-out with `--set`, then each tier's components swapped through the same hardpoint of the same machines, read on the team rows and whole runs; the Phase Conjugator on a team row
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
- [ ] Ryan picks every wildlife foe from its takes on the phone picker; a session reads the picks (or his pasted Copy all picks), cuts each with `forge.py cut` from `out/<foe>_<tag>/` and the options it needs, copies the source into `tools/foeforge/picks` and records it in `picks.json`
- [x] Battle-pose takes for the wildlife (10 October): four in `design.variants` for each of the fifteen without, four more for the Goblin and the Revenant (`--seed 5`), rendered as `takesE`; the original sets off the picker
- [ ] Battle-pose takes for the eight heroes' boss register, once the promoted forms are entries (their chibis stay as picked)
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
- Republish the hangar page with `tools/hangar_data.py`'s map after every content, model or render change
- After Ryan edits on the hangar's Content tab: pull `edits` with ArtifactData, apply by hand, test, commit, republish, clear the documents
- Re-seed the Melody Desk's `parts` after a track's voices change (`desk_parts.py`)

## Pinned, not now

- A low-hull berserker or last-stand entry; command entries with a battlefield meaning; an endless mode; livery by Sponsorship once the hangar exists; Jenny's idle nag; a map taunt for a slow Arsenal bruiser; a machine that moves after it fights; Hellfire as an Arsenal component prefix (Ryan, 12 October); the gravity piece, a tier-three blueprint with an area effect (Ryan, 13 October: shelved, it will come back)
