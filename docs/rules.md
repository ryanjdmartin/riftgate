# Riftgate: the rules

The game's rules as they stand, in the present tense. This file says **what** is true; the
design bible (`docs/design-bible.html`) says **why**. A rule that changes is edited here in
place, in the same commit as its bible row; there is no history in this file (git has it).
Every number is a placeholder. "(not built)" marks a decided rule the code does not run yet.
The content lives in `content/*.json` (each file's `_about` explains its fields) and its
words in `docs/vocabulary.md`.

## The game

A campaign is one roguelike run of battles at five cities. A battle is a hex field, gate at
the bottom and rift at the top, won by killing the boss that powers the rift. Machines fight
packs in skirmishes: dice fights against one or more packs at a time. The depth lives in the
skirmish.

## Machines

- **Chassis**: hull, shield, field recharge (shield regained out of fights), heat maximum,
  cooling, armour, move, size class, one way of moving, hardpoints, fixed components, module
  slots (two; the Clydesdale three) and one passive. Thirteen chassis from five makers
  (`content/chassis.json`). A run has four squad slots and starts with three machines.
- **The die**: one entry per component, fixed components first, then one per hardpoint. An
  empty hardpoint is a blank entry; nothing fills it. A full, undamaged machine is reliable.
- **Components**: a **weapon** is spent on a foe and need not deal damage; **equipment** (a
  shield, a vent or a buff) is spent on a machine: itself and allies by default, or self
  only, or allies only, as its chip says. A component has a number (or none), heat, strikes,
  up to three authored keywords, and may carry a passive. A **fixed** component is built
  into its chassis, uses no hardpoint, is never a blueprint and has no tier.
- **Rolled or flat**: a rolled weapon shows a range and rolls in it when spent; a flat weapon
  is one number with no roll, however many things feed it (heat fired, missing hull, buffs,
  armour). There are no crits and no weapon classes.
- **Tags** (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee: the working set,
  not yet assigned to components) are build flavour shown in the codex only (not built).
  A tag carries no rule of its own; a module or passive may read one. Components still carry
  the old internal filing tags; only `melee` is read today (the Nemesis's passive, and which
  blows lunge on screen).
- **Modules** sit inside the machine and are never spent: stat lines up or down (hull,
  shield, heat maximum, armour, move, field recharge, cooling) and at most one rule, tier 1
  to 3, run as one passive nothing on the die can remove. The same module twice stacks.
  Fitted in the harness only (not in the run yet). Catalogue: `content/modules.json`.
- **Tiers and blueprints**: the basics are tier zero, what comes off the assembly line: a run
  starts with every basic's blueprint, and a tier-one chassis stocks basics beside its fixed
  pieces. Blueprints of tiers one to three are found, or their components come on a bought
  chassis of tier two or three. A fixed component has no tier; the Arsenal (the capital's
  maker) makes no basics and has no tier one. (Not built: today a stocked component takes the
  lowest tier of the chassis that stock it, an unstocked one carries its own, a run starts
  with every tier-one blueprint, and the tier-one stocks wait on the stock pass.)
- **Damage states**: a component is intact, cracked or destroyed, for the whole battle.

## The skirmish

### Formation
- Foes stand in two ranks of four columns, front and back. A massive foe (size 2) fills a
  whole column and counts as front rank for every rule: always in reach, never exposing its
  column, nothing behind it.
- At the start, foes take their ranks heaviest hitters first from the left (damage times
  strikes; ties in arrival order). Foes left over wait as reinforcements.

### The round
1. Rerolls reset to three (less any a foe drained). Every machine sheds heat by its cooling.
   Every die rolls; entries are equally likely. Round-start passives fire.
2. Every foe picks its move, then its target; both show, exact, before the player acts.
3. The player's turn: spend, lock and reroll in any order. Each spend resolves fully before
   the next. Withdrawal is open at any point.
4. END TURN: heat over a machine's maximum burns hull one for one and the gauge settles at
   the maximum (an overheat). A machine it wrecks is lost on its own turn, before the enemy
   acts.
5. The enemy's turn (below). Round-timed effects end.
6. Machines' statuses tick. Shield past the maximum (overshield) fades.
7. Reinforcements step into empty slots. Next round.

The fight ends the moment it is decided, mid-turn too: victory when no foe stands or waits,
defeat when every machine is wrecked. There is no round limit.

### Dice
- **Rerolls**: three a round for the team, never banked. A reroll rerolls every unlocked,
  unspent die, before or after attacking, and never lands on the entry showing or an
  identical one. Tap a die to lock it; spending unlocks it; locks clear each round.
- **Spending**: drag a die onto a target: a weapon onto a foe in reach, equipment onto a
  machine its chip allows. Each die is spent once a round (Rapid excepted). A blank does
  nothing; an unspent die is lost.
- **Equipment**: a shield adds its number up to the target's maximum; a vent removes its
  number in heat; a buff grants its status, so many stacks, through so many rounds.

### Reach
- **Direct** reaches the front rank, and a back-rank foe whose column's front slot is empty.
- **Indirect** reaches any foe. Fired at the front rank it splashes: the firer loses shield
  equal to half the damage the target took, rounded up, never hull (the Artillery
  Rangefinder spares it).
- A kill clears its slot at once, so a hole in the front opens that column's back to Direct.

### A blow
1. The number: the roll, or the flat number, plus what heat fired adds (Vents all) and what
   the target's missing hull adds.
2. The attacker's modifiers: adds, then multiplies, then floors.
3. Each foe hit takes it through its own modifiers (Shocked doubles it), then loses its
   armour off it.
- Strikes are separate blows; each rolls and carries the keywords. Heat is paid once a spend.
- A raised ceiling or floor (the Muzzle Velocity Booster, the Tactical Databank) moves a
  rolled range by its value before the roll, never past the top; a flat weapon gains
  nothing.
- **The die shows the number** one blow will deal after every modifier. Dragged over a foe
  it may strike, it shows that foe's number: its missing hull, conditions on it, its armour
  off. A Shocked foe's doubling is not folded in (it shows on the foe's chip).
- Player damage comes in fives; hull, shield, heat and foe numbers in tens.

### Player keywords
- **Spread** (id `cleave`): also hits the target's neighbours in its rank.
- **Penetrate**: also hits the other rank of the target's column.
- **Burn**: each foe hit gains a Burning stack per 10 of the blow, rounded up.
- **Suppress**: each foe hit is Suppressed unless its Numbed resists.
- **Shock**: every foe the spend reaches and leaves standing is Shocked after the blow.
- **Chain**: a kill repeats the attack on the next valid target, rolling and paying heat
  again, until a link fails to kill.
- **Spillover**: damage past the kill of a front-rank foe carries into the foe behind it as
  plain damage.
- **Lure**: every foe reached and left standing turns on the spender for the round.
- **Disrupt**: every foe reached and left standing takes the next move in its list that its
  conditions allow, with a new target. Disrupt resolves before Lure.
- **Rapid** (any component): the entry switches off for the round, the die rerolls free onto
  another entry, and the machine acts again.
- **Volatile** (any component): spending it costs its owner 10 hull, past shield and
  armour, before it acts.
- **Cleanse** (shields and vents): the machine it lands on loses Overheating, Scrambled, a
  foe's Disabled and Corrupted (never a Rapid switch-off).
- **Overshield** (shields): may pass the maximum; the excess fades at the round's end.

Component properties, printed on the entry rather than learned as keywords (the die marks
them with a star): **Vents all** fires the whole heat gauge into the shot, adding its
bonus per 10 heat fired, then its own heat lands. **Devour** (the Soulcutter Talons): each
kill gives the owner a stack of Overcharged. **Missing hull** adds its bonus for every
20 hull the target is missing. **The hopper**: a weapon that fills it puts a load in its
machine's hopper for each foe its blows reach, after the blow; a weapon that fires it takes
up to its most loads a shot, each adding its bonus to the blow, and spends them (the Honey
Badger's Chainsaw Claw fills, its Bullion Fragmenter fires three at +5). **Braces**:
spending it Braces its owner, the stacks it says, until the round's end (the Wild Boar's
Breaching Plow, two).

### Buffs, debuffs and resistance
On a machine:
- **Overcharged** (buff): +5 damage a stack. From Devour it lasts the skirmish, losing a
  stack each round's end (the Ammit keeps it for the battle).
- **Braced** (buff): armour +5 a stack, until the round's end, every stack at once,
  whatever granted it.
- **Primed** (buff): each blow leaves a Burning stack per Primed stack on its target.
- **Retaliate** (buff): a foe whose blow reaches this machine's bare hull is Shocked.
- **Crucible** (buff, the Nemesis's): its melee blows deal +5 a stack, a stack each time it
  takes hull damage; lasts the skirmish.
- **Hopper** (a store, the Honey Badger's): loads for a weapon that fires the hopper; lasts
  the skirmish, never decays, and nothing cleanses it.
- **Overheating** (debuff, from a foe's scorch): +5 heat a stack at the round's end, then a
  stack fades; the heat burns at the end of the next turn unless vented. Cleansable.
- **Scrambled** (debuff): the die's next reroll may land anywhere, the same entry included.
- **Disabled** (debuff): the entry comes up blank through the machine's next turn.
- **Corrupted** (debuff): each spend of the entry bites its owner 10 a stack, shield first,
  never armoured; lasts the skirmish.

On a foe:
- **Burning** (debuff): 5 damage a stack at the start of its action, past armour, then a
  stack fades. It never stops healing.
- **Suppressed** (debuff): it skips its action this round; landed on a foe that has already
  acted, or by a Paradox on a foe already suppressed, it costs the next action instead.
- **Shocked** (debuff): the next team blow that deals it damage deals double, spending the
  shock; it never stacks.
- **Paradox** (debuff, while the Baboon fights): a stack each time the foe gains any other
  debuff, once a spend per debuff however many strikes or stacks; at three it is Suppressed
  (Numbed may resist) and the Paradox clears. It never decays. The Suppressed a Paradox
  causes adds none; a weapon's Suppressed does.
- **Folded** (buff, Harden): armour +value until its next action.
- **Kindled** (buff, Rally): hits harder until the end of the next round.
- **Getting Back Up** (buff, Reraise): after it falls it returns to the reinforcements once,
  whole, unless it self-destructed.
- **Numbed** (a resistance, neither buff nor debuff, drawn in brackets): each stack is a 10%
  chance a suppress fails. A landed suppress adds two stacks (three on a massive foe); a
  shrugged one adds none; a stack fades at each of its turns. Nothing reads, deepens,
  spreads or cleanses it, and no foe resists by nature.

"A foe carrying a status" (the Susceptibility Tensor) means a debuff the team put on it:
Burning, Suppressed, Shocked or Paradox.

### Shields, armour, hull
- A standing shield blocks a whole blow, however small, and loses the blow's damage. A
  **breach** blow's overflow past the shield reaches the hull.
- A machine's armour comes off every blow that reaches its hull, flat, a breach's overflow
  included; shields are never armoured. A foe's armour comes off every blow on it, never off
  Burning. Damage-taken effects apply before armour.
- In a fight, shield comes only from components, modules and passives. Shield carries
  between fights and returns at the field rate only in map turns spent out of a fight. Hull
  never heals in a battle.

### Heat
- A weapon adds its heat when spent, once a spend. Heat may pass the maximum during the
  player's turn harmlessly; at the end of the turn, before the enemy acts, the excess burns
  hull one for one (an overheat) and the gauge settles at the maximum. With volatile, it is
  the way a machine dies on its own turn. Machines cool at the start of the round. Heat
  starts each fight at zero.
- An overheat is hull damage for every passive that reads hull damage.
- Foes heat machines by scorch (Overheating), and by moves that add heat to one machine or
  to all. That heat lands after the burn, so it waits on the gauge for the next turn, where a
  vent or a cleanse answers it. (Decided, not built: foes heat machines only through
  debuffs, every move that adds heat today putting on one or the other by how threatening it
  must be. One adds its heat at the end of the player's turn, before the overheat, so it can
  be vented or cleansed first; a softer one raises the heat every weapon generates, per
  stack. Scorch puts on one of them; the names are open.)

### Injury
- A foe's blow that puts a quarter of the machine's maximum hull or more past armour into
  its hull (a breach's overflow included) rolls the machine's die: an intact entry cracks, a
  cracked one is destroyed, a blank shrugs it off. A standing shield prevents it (breach
  excepted). Bites, splash and overheats never injure.
- **Cracked**: keeps its number, heat, action and passive; loses its keywords.
- **Destroyed**: blank; its passive keeps its stat bonuses and loses its abilities. The Honey
  Badger's components are never destroyed.

### Foes
- A foe has hull, a base attack, a rank it holds, a size, flat armour (bosses 5) and an
  aim. Its damage never rolls.
- **Its move**: from the moves whose conditions hold, weighted (attacks 2, specials 1), never
  the same special twice running while anything else is open. Conditions: below half, hurt,
  fewer than two summons waiting, the team has a reroll left, a machine at 20 heat or more, a
  machine showing an intact weapon, a foe behind it, another foe on the field.
- **Its target**, by aim: exposed (the default: weighted by the hull its blows would reach
  plus half the shield they would break), anything, heat (the hottest machine), armed (a
  machine showing an intact weapon), focus (its rank shares one pick). A move may carry its
  own aim. The pick is a commitment; Lure and Disrupt move it.
- **A blow** is its base attack times the move's factor, plus its swarm for each other live
  foe of its type; strikes are separate blows. Riders: breach, scorch (a stack of
  Overheating), disable (the entry the machine shows), corrupt (a Corrupted stack on it),
  self-destruct (the striker dies after, for good).
- **A special** replaces the blow: harden, regrow (heals its value), revive once, summon,
  rally, drain rerolls, add heat (one machine or every machine), disable.
- **The enemy's turn**: front rank left to right, then the back. At its action each foe's
  statuses tick (Burning first, which may kill it; then decaying stacks drop, Numbed
  included); a suppressed foe does nothing.
- **Reinforcements**: at the round's end every empty column takes a waiting massive foe
  first, then each empty slot, left to right, a random waiting foe of its rank. A dead Gel
  splits into two Half-Gels in the reinforcements (one deep).

### Withdrawal
Open at any point of the player's turn. Withdrawing ends the turn, so heat over the maximum
burns first; then the enemy takes its full turn, and the skirmish ends; the round's end does
not run. Kills stay counted, machines keep their damage and
shields do not refill; a pack keeps its survivors, who return whole.

### Passives: triggers and conditions
- Triggers: static, on attack, on injury, on round start (after the roll), on skirmish start,
  on hull damage (any hull lost: a blow, a bite or an overheat), on shield gain, on shield
  granted (an ally this machine shields), on heat gain, out of combat, on foe status (a foe
  gains a debuff), on stack (this machine applies stacks). No trigger feeds itself.
- Conditions: the component is cracked; the weapon is rolled; the reach is direct or
  indirect; the target carries a debuff; an ally is in the fight; the component carries a tag.
- A passive may change an entry's reach, grant it a keyword or move its range; the entry as
  changed is what is spent, shown and weighed, while the die keeps the real one.

### Every number is a question
Every stat, damage figure and property is read through one pipeline (`sim/effects.gd`), in
one order: suppression (shortest-lived source first), the gate (live, triggered, condition
met, and for an ability its component not destroyed), adds, multiplies, floors and caps,
overrides (shortest-lived source, then latest granted). Every buff, debuff, passive, module
and reward is a modifier with a source and a scope: rounds, skirmish, battle or loadout. The
same status in the same scope stacks: an add counts per stack, a multiply applies per stack,
and a ticking status loses a stack at its owner's turn. Nothing writes to a stat.

## The battlefield

- **Field**: pointy-top hexes, 9 wide and 20 rows. The rift is three hexes mid top row; the
  gate is two rows at the bottom centre (3 and 4 hexes), wall across the rest. One unit to a
  hex, the boss too.
- **Ground**: open (plain or road), rough, ruins, water, crags. Every map guarantees the
  horde a crossing three hexes wide or more and one water feature (a river with fords, or a
  lake band); the two rows before the gate are never water or crags. Five map types: Mixed
  Ground, Open Steppe, Rubble Field, Badlands, Flooded. Height is landscape; no rule reads it.
- **Ways of moving** (each chassis has one): a fast hex costs 5, a normal hex 10; a slow hex
  takes whatever move is left and ends the move; crags are walls except to flyers. Tracked:
  ruins slow. Walker: water slow. Wheeled: open fast; rough, ruins and water slow. Hover:
  water fast; rough and ruins slow. Flyer: everything normal. Machines never enter or cross
  another unit's hex.
- **Setup**: up to four machines on the row before the gate; the lead domain's spawn list as
  packs three to five rows below the rift; the boss one row below the rift.
- **A turn**: the map shows every pack's coming walk. Each machine has one action (the Dingo
  two): move, in pieces if wanted, then may fight; a fight ends the action however it ends.
  UNDO MOVE restores a machine until it fights. A caught machine's fight comes first. END
  TURN: packs walk and strike; machines that did not fight regain shield at their field rate;
  Rift Pressure rises one.
- **Orders**: a tap or drag onto a pack moves the machine to the farthest hex in attack range
  its move reaches (or leaves it, if in range) and orders it. ENGAGE opens one fight at a
  time: the first order's pack and every machine ordered onto it.
- **A fight** is at the target's hex. Every other pack whose ring covers that hex joins (no
  chaining); machines whose attack range (2) covers it may join. Afterwards each machine in
  it has used its action, wrecks leave, a pack keeps only its survivor count, and Rift
  Pressure rises one per round fought.
- **Packs**: one foe type times a strength. They treat every land hex as normal and water and
  crags as walls; moves 20 (fast 30, massive 10); rings 1 (front rank), 3 (back rank), 2
  (massive). They walk round machines and other packs; the walk shown is the walk played. The
  enemy never attacks a machine on the map: pushers strike the gate, hunters catch.
- **Pushers** make for the gate; a pusher ending its walk beside it strikes the gate for its
  strength times 10 divided by 3, at least 10, every enemy turn.
- **Hunters** lock one machine when they appear (nearest, weakest, strongest or slowest; never
  the Prairie Dog) and walk to put it inside their ring. A hunter with its prey in its ring
  at the start of the player's turn has caught it: that fight comes first, the prey cannot
  move first, others in range may join.
- **The boss** patrols within two hexes of the rift, ring 2, joins fights in its ring and can
  be attacked from the first turn; its death wins the battle. A withdrawal leaves it standing.
- **Rift Pressure** fills at 12 (+1 each enemy turn, +1 each round fought) and spawns the next
  pack of the spawn cycle by the rift. Packs never escalate.
- **The battle ends** when the gate reaches zero, every machine is wrecked, or the boss dies.
- Not built: city defences, the Rupture meter and its Fractures, the sealed boss, rift tiles.

## The campaign

Headless only (`sim/campaign.gd`); no screen drives a run yet.

- **Cities**: the capital (the Council and the Arsenal) and four around it, one for each city
  maker. A city's gate is 200, the capital's 300. The capital's gate is the run's life: the
  run is lost at zero.
- **Start**: a tender of one tier-one machine from each city maker (by seed, in stock
  loadout); the player takes three. Four squad slots, 0 salvage, 100 Favour, a blueprint for
  every basic (not built: today every tier-one component's).
- **A turn** is one battle at a front, with one to four ready machines, or a pass.
- **Won** (the boss dies): the gate refills, the rift closes, no rift opens there next turn;
  10 salvage a kill; 100 Favour less 1 per gate point the city lost, never below 0; a research
  token of the lead domain and an offer from the host maker are owed (unpacking and offers
  not built).
- **Fell** (the gate reached 0): the city falls, the battle's salvage is lost, the rift stays
  open. **Wiped** (every machine wrecked): the horde strikes the gate for up to six phases;
  the city falls at zero or holds wounded, keeping the salvage; no Favour.
- **After a battle**: hull and cracks mend free; a destroyed hardpoint component is gone, a
  destroyed fixed one rebuilt; a wreck also loses its cracked components and sits out the next
  turn unless rushed (100 Favour). Fitting and stripping are instant; the capital's gate
  repairs at 5 salvage a point.
- **Turn end**: each unfought open rift bleeds its city 50 (falling it at zero); each fallen
  city drains the capital 25; the Convergence rises 1; rifts open at standing cities up to
  2 + tier (tier = the Convergence ÷ 4).
- **Domains**: a rift rolls its lead domain (Meadow, Waste, Marsh, Peak; never a thinned one)
  and from tier 1 a guest, whose packs alternate with the lead's in the spawn cycle.
- **Finals and finale**: three bosses of one domain beaten make its next rift a final; a won
  final thins the domain. The finale is due at Convergence 12, one sooner per fallen city; the
  capital is then the only front. Winning it wins the run. (Not built: the party dealt from
  the benches, heroes in finals, the promoted finale.)
- **Between runs**: a finished run adds its blueprints to the pool and its chassis and beaten
  domains to the codex; a win clears a difficulty tier (`sim/profile.gd`, run by tests only so
  far).
- Not built: building from blueprints, offers, procurement, loot on the map, modules in the
  run, Sponsorship, livery, the mission map, draft and hangar screens.

## Content conventions

- `content/*.json` is data, validated by `sim/content_db.gd` in the tests; bad content fails
  the build.
- Shown to the player: `codex`, `flavour`, a passive's `name` and `description`, a module's
  `text.description`, a foe action's `text`. Internal text lives under `design` and is never
  shown. Shown text never says "face".
- A draft the engine cannot run carries `"status": "planned"`: kept, never shown or run.
- Runtime code takes defaults from content, never from a hardcoded id.

## Known gaps between these rules and the code

- Rally grants a fixed +10 at once, not its move's value next round, so foes acting after
  the rallier that turn hit above their shown intent.
- Jenny's foe-down lines are keyed by the retired families, so only the generic pool plays.
- `tools/hangar_data.py` leaves `content/modules.json` out of the hangar page's files.
