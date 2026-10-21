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
  slots (two; the Clydesdale three) and one passive. Fourteen chassis from five makers
  and four planned, the Cassowary, the Cottonmouth, the Whip Scorpion and the Swallowtail
  (`content/chassis.json`). A run has four squad slots and starts with three machines.
- **The die**: one entry per component, fixed components first, then one per hardpoint in
  order. Each entry shows its place, from I, as a grey Roman numeral: top left on the die, and
  down the hold and the codex. An empty hardpoint is a blank entry; nothing fills it. A full,
  undamaged machine is reliable.
- **Components**: a **weapon** is spent on a foe and need not deal damage; **equipment** (a
  shield, a vent or a buff) is spent on a machine: itself and allies by default, or self
  only, or allies only, as its chip says. A component has a number (or none), heat, strikes,
  up to three authored keywords, and may carry a passive. A **fixed** component is built
  into its chassis, uses no hardpoint, is never a blueprint and has no tier.
- **Rolled or flat**: a rolled weapon shows a range and rolls in it when spent; a flat weapon
  is one number with no roll, however many things feed it (heat fired, missing hull, buffs,
  armour). Neither shape owns heat: a weapon's heat is its own number, set by its niche like
  its reach. There are no crits and no weapon classes.
- **Tags** (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee: the working set,
  not yet assigned to components) are build flavour shown in the codex only (not built).
  A tag carries no rule of its own; a module or passive may read one. Components still carry
  the old internal filing tags; only `melee` is read today (which blows lunge on screen).
  Melee means short range, a shotgun included, never only a blade.
- **Modules** sit inside the machine and are never spent: stat lines up or down (hull,
  shield, heat maximum, armour, move, field recharge, cooling) and at most one rule, tier 1
  to 3, run as one passive nothing on the die can remove. The same module twice stacks.
  Fitted in the harness only (not in the run yet). Catalogue: `content/modules.json`.
- **Tiers and blueprints**: the basics are tier zero, what comes off the assembly line: a run
  starts with every basic's blueprint. Every other component carries its tier, one to three,
  and a chassis stocks only components below its own tier, so a tier-one chassis stocks
  basics beside its fixed pieces and a tier-three component is only ever found. Blueprints
  of tiers one to three are found; a bought chassis brings one copy of each component it
  stocks, never its blueprint. A fixed component has no tier; the Arsenal (the capital's
  maker) makes no basics and fields no tier-one chassis, though its tier-one components exist
  and its tier-two chassis stock them. (Not built: today a stocked component takes the
  lowest tier of the chassis that stock it, an unstocked one carries its own, a run starts
  with every tier-one blueprint, and the stocks wait on the stock pass.)
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
4. END TURN: a machine's Burning adds its heat and loses a stack, and its Scorched goes;
   then heat over a machine's maximum burns hull one for one and the gauge settles at the
   maximum (an overheat). A machine it wrecks is lost on its own turn, before the enemy
   acts.
5. The enemy's turn (below). Round-timed effects end.
6. Machines' statuses tick. Shield past the maximum (overshield) fades.
7. Reinforcements step into empty slots. Next round.

The fight ends the moment it is decided, mid-turn too: victory when no foe stands or waits,
defeat when every machine is wrecked. There is no round limit.

### Dice
- **Rerolls**: three a round for the team, never banked. A reroll rerolls every unlocked,
  unspent die, before or after attacking, and lands on any other entry, never the one
  showing; a copy of it may come up, at the odds its copies give it. Tap a die to lock it;
  spending unlocks it; locks clear each round.
- **A stepping die** (the Cassowary's, not built): it never rolls. Each fight opens on a
  random entry, and every roll or reroll steps it to the next entry in order; a lock holds
  it; a foe's Scramble is a true roll, and the sequence runs on from where it lands. Its
  Spin-Up spins the whole die, the entry showing included, the one exception to the reroll
  rule. Every sixth weapon spend counts double, its damage and the stacks it lays.
- **Spending**: drag a die onto a target: a weapon onto a foe in reach, equipment onto a
  machine its chip allows. Each die is spent once a round (Rapid excepted). A blank does
  nothing; an unspent die is lost.
- **Equipment**: a shield adds its number up to the target's maximum; a vent removes its
  number in heat; a buff grants its status, so many stacks, through so many rounds, or with
  no rounds when the status runs down on its own (Overcharged).

### Reach
- **Direct** reaches the front rank, and a back-rank foe whose column's front slot is empty.
- **Indirect** reaches any foe, at no cost to its firer: area belongs to the keywords. (Not
  built: today, fired at the front rank, it splashes: the firer loses shield equal to half
  the damage the target took, rounded up, never hull, and the Artillery Rangefinder spares
  it. It goes with the stock pass's area keywords and the Rangefinder's new rule.)
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
  off. A Shocked foe's doubling is not folded in (it shows on the foe's chip). Its heat is
  the heat the spend will add, every modifier in (a Scorched machine's weapons run hotter).
- Player damage sits at the scale of fives; hull, shield, heat and foe numbers at the scale of
  tens. The scales are magnitudes, not steps: any whole number may be used (an armour of 2, a
  blow of 12), and the numbers between the round ones are the room for balancing and upgrades.
  Move alone keeps steps of 5, since a hex costs 5 or 10.

### Player keywords
- **Spread** (id `cleave`): also hits the target's neighbours in its rank.
- **Penetrate**: also hits the other rank of the target's column.
- **Burn** (with a number): each foe hit gains that many stacks of Burning, whatever the
  blow dealt (Burn 3: three stacks).
- **Cryo** (with a number): every foe the entry reaches gains that many stacks of Cryo. Any
  machine's damaging hit on a foe carrying Cryo spends every stack and cools the hitter 10 a
  stack, after the spend's own heat lands; a blow of nothing spends none.
- **Suppress**: each foe hit is Suppressed unless its Numbed resists; one already suppressed for
  that action gains nothing more, Numbed included.
- **Shock**: every foe the spend reaches and leaves standing is Shocked after the blow.
- **Chain**: a kill repeats the attack on the next valid target, rolling and paying heat
  again, until a link fails to kill.
- **Lure**: every foe reached and left standing turns on the spender for the round. (Not
  built: the Whip Scorpion's Siphon reaches every foe in the fight, and every blow landed on
  it that round adds 10 heat to it.)
- **Disrupt**: every foe reached and left standing takes the next move in its list that its
  conditions allow, with a new target. Disrupt resolves before Lure.
- **Rapid** (any component): the die rerolls free onto any other entry, a copy of the same
  component included, and the machine acts again, so copies of one Rapid component chain.
  A Rapid component always carries a limiter, a cooldown, heat or Volatile; every Rapid
  component today carries a cooldown of one: the entry switches off for the round. The
  Cassowary's Spin-Up (not built) carries none: a stepping die cannot chain it into itself.
- **Cooldown** (a printed property on specific pieces, not built): after the entry fires it
  is dark for so many rounds, shown on the entry with the rounds left.
- **Web** (the funnel-web's Web Bomb): the foe hit is Webbed, one web however often it is
  webbed; at the end of its action the web bursts, Suppressing it and the next foe to act
  beside it (Webbed, below).
- **Swap** (the Dingo's Combat Translocator, not built): two foes, or a foe and an empty slot,
  trade places; no damage; a massive foe does not move.
- **Flak** (Wainwright & Sutler's on-hit, not built): Flak N, each foe hit gains N stacks of
  Flak, whatever the blow dealt.
- **Volatile** (any component): spending it costs its owner 10 hull, past shield and
  armour, before it acts.
- **Cleanse** (equipment, today): the machine it lands on loses Burning, Scorched,
  Scrambled, a foe's Disabled and Corrupted (never a Rapid switch-off).
- **Overshield** (shields): may pass the maximum; the excess fades at the round's end.

Component properties, printed on the entry rather than learned as keywords (the die marks
them with a star): **Vents all** fires the whole heat gauge into the shot, adding its
bonus per 10 heat fired, then its own heat lands. **Overcharged a kill** (the Soulcutter Talons'
rule, no word of its own): each foe it kills gives its owner two stacks of Overcharged. **Missing hull** adds its bonus for every
20 hull the target is missing. **The hopper**: a weapon that fills it puts a load in its
machine's hopper for each foe its blows reach, after the blow; a weapon that fires it takes
up to its most loads a shot, each adding its bonus to the blow, and spends them (the Honey
Badger's Chainsaw Claw fills, its Bullion Fragmenter fires three at +5). **Braces**:
spending it Armours its owner, the stacks it says, an armour point each, until the round's
end (the Wild Boar's Breaching Plow, ten). **Rolls again** (the Nemesis's Knuckle of Fury, on rage): spending it
with a stack of its status spends one, and the die rolls again, a plain roll as the round
opens, so the machine acts again and the same entry may show again; nothing switches off,
the stacks being the limit, and the fight's last blow rolls nothing. **Spillover** (the Wild
Boar's Juggernaut Drive, on every weapon it fires): damage past the kill of a front-rank foe
carries into the foe behind it as plain damage, the killing strike's excess and every later
strike of the spend whole; the engine runs it as a keyword the passive
grants, so the Boar's entries wear its chip today (the star proposed).

### Buffs, debuffs and resistance
On a machine:
- **Overcharged** (buff): +1 damage a stack, so the count is the bonus. At the end of each
  round it halves, rounded down, whatever granted it, until it is gone; a buff component
  grants it stacks and no rounds. On the Ammit nothing of it fades: its Quintessence Tap
  keeps every stack for the battle, whatever granted it.
- **Armoured** (buff, on either side): armour +1 a stack, every stack at once, whatever
  granted it, so the count is the armour: a machine's until the round's end, a foe's (from
  its brace) until its next action.
- **Primed** (buff): each blow leaves a Burning stack per Primed stack on its target.
- **Phased** (buff, either side, not built): cannot act, take damage or be targeted until the
  round's end, so allies cannot vent or shield it and a foe's intent on it re-picks; it still
  cools by its cooling, and ticks and overheats land. Granted only to a unit that has not acted
  this round.
- **Muster** (buff, the Swallowtail's, not built): a banked charge. Every die that rolls fills
  it a sliver, about thirty rolls a charge, a kill by its own guns five rolls' worth, up to its
  cap; it starts each fight empty and never decays. Each of its locked pieces has a plain form
  and a charged one that spends a muster: the Mooring Screens shield every ally, or Phase every
  ally that has not acted; the Spotting Flare Exposes a foe, or Exposes and Suppresses it; the Sutler's
  Hoist shields and cools an ally, or fills its shield, cools it to zero and cleanses it; the
  Reveille Horn gives the team a reroll, or lets an ally act again.
- **Rallied** (buff, not built): the team has one reroll more this round.
- **Spun Up** (buff, not built): its next weapon spend deals +5 a stack, then every stack is
  spent; carried between turns until a weapon spends it.
- **Retaliate** (buff): a foe whose blow reaches this machine's bare hull is Shocked.
- **Barrier** (buff, not built): the next blow a foe lands on this machine deals no damage,
  so it never injures; its riders land. Until the round's end. Never granted to every ally
  at once.
- **Ward** (buff, not built): every blow a foe lands on this machine leaves no rider
  (breach, burn, scorch, disable, corrupt), and no silence or purge touches it; its damage
  lands. Until the round's end.
- **Rage** (buff, the Nemesis's, banked): a stack each time it takes hull damage (a blow, a bite
  of its own, an overheat), spent by its fists to roll again; lasts the skirmish, never
  decays, and nothing cleanses it.
- **Hopper** (buff, the Honey Badger's, banked): loads for a weapon that fires the hopper; lasts
  the skirmish, never decays, and nothing cleanses it.
- **Sealed** (buff, the Armadillo's form): a shield it spends on itself seals it: armour +10,
  its own cooling stopped, 15 heat more at the end of each turn before the overheat; a vent or
  a weapon that deals damage opens it; a shield on an ally, a buff and a weapon of no damage
  leave the form as it is. An ally's vent still cools it. One seal, however many shields.
- **Burning** (debuff, from a foe's burn; a foe's Burning below is the same word on the
  other body): +5 heat a stack at the end of the player's turn, before the overheat, then a
  stack fades, so a vent makes room for it or a cleanse takes it off. Cleansable.
- **Scorched** (debuff, from a foe's scorch): every weapon the machine fires runs 5 hotter a
  stack, until the end of the player's turn, when every stack goes, so it never piles up.
  Cleansable.
- **Scrambled** (debuff): the die's next reroll may land anywhere, the same entry included.
- **Disabled** (debuff): the entry comes up blank through the machine's next turn.
- **Corrupted** (debuff): each spend of the entry bites its owner 10 a stack, shield first,
  no armour off it; lasts the skirmish.

On a foe:
- **Burning** (debuff): 1 damage a stack at the start of its action, past armour, then a
  stack fades. It never stops healing.
- **Suppressed** (debuff): it loses its next action: this round's, or the next round's when
  it has already acted this turn. It never stacks and never carries: a second suppress on a
  foe already suppressed, a Paradox's included, does nothing and numbs it no further.
- **Shocked** (debuff): the next team blow that deals it damage deals double, spending the
  shock; it never stacks.
- **Paradox** (debuff, while the Baboon fights): a stack each time the foe gains any other
  debuff, once a spend per debuff however many strikes or stacks; at three it is Suppressed
  (Numbed may resist, and a foe already suppressed gains nothing) and the Paradox clears
  either way. It never decays. The Suppressed a Paradox causes adds none; a weapon's
  Suppressed does.
- **Vitriol** (debuff): at its action it loses 5% of its current hull a stack, past armour,
  after Burning on what it leaves, the whole share rounded down and never the last hit point,
  then a stack fades; it never finishes a foe. A passive lays it a stack per strike that lands
  with a number; a blow of nothing (a web, a lure) lays none.
- **Webbed** (debuff): at the end of its action, skipped or not, the web bursts: it is
  Suppressed (its next action, since it has acted; a countdown it gathers is held a round),
  and so is the next foe to act beside it in its rank, its right-hand neighbour, which loses
  this round's action, or with none standing there its left-hand one, which has acted and
  loses its next (Numbed may resist, each for itself; a foe already suppressed gains nothing,
  as from any second suppress; each half feeds the Paradox as a weapon's Suppressed does).
  Killed first, or gone by the end of its action, it takes its web with it. Its chip points at
  the neighbour the burst catches.
- **Cryo** (debuff): a damaging hit on it spends every stack and cools the hitter 10 a stack;
  a blow of nothing spends none. It never fades on its own.
- **Flak** (debuff, not built): every blow it takes deals a point more a stack; the stacks
  halve at the end of each round, rounded down.
- **Kindled** (buff, Rally): hits harder by its rally's value through the next round. It goes
  live when that round's intents are drawn, so a foe striking after the rallier this turn
  hits the number it showed.
- **Getting Back Up** (buff, Reraise): after it falls it returns to the reinforcements once,
  whole, unless it self-destructed.
- **Numbed** (buff, nothing removes it, drawn in brackets): each stack is a 10%
  chance a suppress fails. A landed suppress adds two stacks (three on a massive foe); a
  shrugged one adds none, and one wasted on a foe already suppressed adds none; a stack fades
  at each of its turns. Nothing reads, deepens, spreads or cleanses it, and no foe resists by
  nature.

"A foe carrying a status" (the Susceptibility Tensor) means a debuff the team put on it:
Burning, Suppressed, Shocked, Paradox, Vitriol, Webbed or Cryo (Flak once built).

### Shields, armour, hull
- A shield absorbs a blow up to its number and loses what it absorbed; the excess reaches
  the hull. A **breach** blow ignores the shield: the shield stands and the whole blow
  reaches the hull. (Not built: today a standing shield blocks a whole blow, however small,
  and only a breach's overflow passes it.)
- A machine's armour comes off every blow that reaches its hull, flat, a breach's overflow
  included; a shield takes no armour off. A foe's armour comes off every blow on it, never
  off Burning. Damage-taken effects apply before armour.
- In a fight, shield comes only from components, modules and passives. Shield carries
  between fights and returns at the field rate only in map turns spent out of a fight. Hull
  never heals in a battle.

### Heat
- A weapon adds its heat when spent, once a spend, through the attacker's modifiers in the
  blow's order: adds, then multiplies (so a machine whose heat is doubled doubles Scorched's
  extra too). Heat may pass the maximum during the player's turn harmlessly; at the end of
  the turn, before the enemy acts, the excess burns hull one for one (an overheat) and the
  gauge settles at the maximum. With volatile, it is the way a machine dies on its own
  turn. Machines cool at the start of the round. Heat starts each fight at zero.
- An overheat is hull damage for every passive that reads hull damage.
- Foes heat machines only through two debuffs, never outright: Burning, the harsher, adds
  its heat at the end of the player's turn before the overheat, so a vent makes room for it
  or a cleanse takes it off; Scorched, the softer, heats only the weapons the machine fires
  in the turn that follows, so equipment or a cool weapon plays round it. A foe's burn leaves Burning and its scorch
  leaves Scorched, a stack a blow; the Drake's Stoke sets the hottest machine burning, and
  the Magma Golem's Eruption, the Black Mage's Fira and the Summoner's Pyroclasm scorch every
  machine.

### Injury
- A foe's blow that puts a quarter of the machine's maximum hull or more past armour into
  its hull (a breach's whole blow included) rolls the machine's die: an intact entry cracks, a
  cracked one is destroyed, a blank shrugs it off. A shield absorbs its share first and what
  reaches the hull counts; a Barrier's blow never does (not built: today a standing shield
  prevents it, breach excepted). Bites, splash and overheats never injure.
- **Cracked**: keeps its number, heat, action and passive; loses its keywords.
- **Destroyed**: blank; its passive keeps its stat bonuses and loses its abilities. The Honey
  Badger's components are never destroyed.

### Foes
- A foe has hull, a base attack, a rank it holds, a size, flat armour (bosses 5) and an
  aim. Its damage never rolls.
- **Its move**: from the moves whose conditions hold, weighted (attacks 2, specials 1), never
  the same special twice running while anything else is open. Conditions: below half, hurt,
  fewer than two summons waiting, the team has a reroll left, a machine at 20 heat or more, a
  machine showing an intact weapon, a foe behind it, another foe on the field, one of its own
  hurt. A move may
  carry a countdown: it gathers, landing that many rounds after it is announced, and nothing
  hits meanwhile; its pick holds while the machine stands; Suppress holds it a round, Disrupt
  breaks it off, and the foe stays on the field.
- **Its target**, by aim: exposed (the default: weighted by the hull its blows would reach
  plus half the shield they would break), anything, heat (the hottest machine), armed (a
  machine showing an intact weapon), focus (its rank shares one pick). A move may carry its
  own aim. The pick is a commitment; Lure and Disrupt move it. A special that acts on nobody
  in particular (a brace, a regrow, a rally, a scorch all) keeps its pick and shows no arrow:
  it is aimed at no machine.
- **A blow** is its base attack times the move's factor, plus its swarm for each other live
  foe of its type; strikes are separate blows. Riders: breach (the blow ignores the shield;
  not built: today only its overflow passes), scorch (a stack of
  Scorched), burn (a stack of Burning), disable (the entry the machine shows), corrupt (a
  Corrupted stack on it), self-destruct (the striker dies after, for good), every machine
  (each strike lands on every live machine in turn, its number what each takes; no aim or
  Lure moves it).
- **A special** replaces the blow: brace (Armoured, its value in stacks, an armour point each, until its
  next action), regrow (heals its value), cure (the most hurt of its own, itself included, heals its
  value), brace all (the same on every foe in the fight, through the next round), revive once,
  summon,
  rally, drain rerolls, burn (stacks of Burning on one machine), scorch all (stacks of
  Scorched on every machine), corrupt all (Corrupted on the entry every machine shows),
  disable.
- **A last act**: a foe may land a blow the moment it falls (a death blow, with its own
  riders, every machine included), before anything else and even when it was the last foe,
  since damage sticks for the battle.
- **A foe in parts**: a core and the parts of its pack that stand with it. A guard keeps the
  core from taking any damage while all its parts stand, or while any does (Guarded); a part
  that falls may grow back after so many rounds while the core stands; a core that falls takes
  its parts with it.
- **The enemy's turn**: front rank left to right, then the back. At its action each foe's
  statuses tick (Burning first, which may kill it; then decaying stacks drop, Numbed
  included; Vitriol after Burning, on what it leaves); a suppressed foe does nothing; a web
  on it bursts at the end of its action, skipped or not.
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
  indirect; the target carries a debuff; an ally is in the fight; the component carries a tag;
  the target shows no intent on this machine (the funnel-web's: a foe shows intent as its
  arrow is drawn, on its pick or on every machine, a gathering countdown included, and none
  when aimed at another machine, Suppressed, or on a special that acts on nobody in
  particular; read at the spend, before the spend's own riders, each foe reached judged
  alone); the target's
  rank (not built: the Cottonmouth's); the striker carries a status (the Prairie Dog's fight
  half: its damage-taken effect reads the foe whose blow it is taking, so a foe carrying Flak
  hits it 5 lighter, whoever laid the Flak; inert until Flak is built).
- A passive may lay a status on each foe its blows hit (a stack per strike that lands with a
  number, the foe judged by the passive's condition alone: the funnel-web's Vitriol).
- A passive may change an entry's reach, grant it a keyword or move its range; the entry as
  changed is what is spent, shown and weighed, while the die keeps the real one. Not built:
  the Cottonmouth's replaces every weapon's shot whole (Indirect, 15, heat 10, the weapon's
  keywords kept), Penetrate at the back rank and Spread at the front; the Whip Scorpion's
  makes every vent it spends on itself blast a random live foe for the heat it took off, as
  its own blow (a vent on an ally blasts nothing, an ally's vent on it blasts nothing).

### Every number is a question
Every stat, damage figure and property is read through one pipeline (`sim/effects.gd`), in
one order: suppression (shortest-lived source first), the gate (live, triggered, condition
met, and for an ability its component not destroyed), adds, multiplies, floors and caps,
overrides (shortest-lived source, then latest granted). Every buff, debuff, passive, module
and reward is a modifier with a source and a scope: rounds, skirmish, battle or loadout. The
same status in the same scope stacks: an add counts per stack, a multiply applies per stack,
and a ticking status loses a stack at its owner's turn, a halving one half of them, rounded
down; a timed one stacks only with a grant that ends the same round, so each grant's stacks go
when its own rounds run out. A status runs down to zero on its own clock or is timed, never
both. A status's
definition may say otherwise: one that renews keeps one grant, its end the later and its
count the larger (Suppressed, Retaliate), which on an untimed one-stack status (Shocked,
Getting Back Up, Guarded, Scrambled) means a second grant changes nothing. Nothing writes to
a stat.

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
  Pressure does not tick: it ticks on the map alone.
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
- **The carry** (the Swallowtail's Muster Deck, not built): the machines on the hexes beside
  it travel with it when it moves and are set down on the nearest standable hexes where it
  stops, keeping whatever move and action they had; it cannot stop where a rider cannot be set
  down.
- **The boss** patrols within two hexes of the rift, ring 2, joins fights in its ring and can
  be attacked from the first turn; its death wins the battle. A withdrawal leaves it standing.
- **Rift Pressure** fills at 12 (+1 each enemy turn, never inside a fight) and spawns the next
  pack of the spawn cycle by the rift. Packs never escalate.
- **The battle ends** when the gate reaches zero, every machine is wrecked, or the boss dies.
- Not built: city defences, the Rupture meter and its Fractures, the sealed boss, rift tiles.

## The campaign

Headless only (`sim/campaign.gd`); no screen drives a run yet.

- **Cities**: the capital (the Council and the Arsenal) and four around it, one for each city
  maker. A city's gate is 200, the capital's 300. The capital's gate is the run's life: the
  run is lost at zero.
- **Start**: a tender of one tier-one machine from each city maker (by seed, in stock
  loadout; a chassis whose passive or locked piece is still planned is not dealt, so a maker
  whose only tier one is a draft offers nothing until it lands); the player takes three. Four squad slots, 0 salvage, 100 Favour, a blueprint for
  every basic (not built: today every tier-one component's).
- **A turn** is one battle at a front, with one to four ready machines, or a pass. The whole
  roster goes to the one front; the open fronts left alone bleed (below). A battle is played
  to its end and a team wipe is the graded loss; a withdrawal from a battle is not built (open:
  the bible's section 4).
- **Won** (the boss dies): the gate refills, the rift closes, no rift opens there next turn;
  10 salvage a kill (to be weighted by the foe's threat, not built); 100 Favour less 1 per gate
  point the city lost, never below 0; a research
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

- Each content file's `_about` is the authority on its fields; `sim/content_db.gd` validates
  them in the tests, so bad content fails the build. Shown to the player: `codex`, `flavour`, a
  passive's `name` and `description`, a module's `text.description`, a foe action's `text`;
  everything under `design` is internal; shown text never says "face"; a draft the engine cannot
  run carries `"status": "planned"` and is kept, never shown or run.

## Known gaps between these rules and the code

- Jenny's foe-down lines are keyed by the retired families, so only the generic pool plays.
