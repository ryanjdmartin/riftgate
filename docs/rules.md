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
  slots (two; the Clydesdale three) and one passive. Twenty-four chassis from five makers
  (`content/chassis.json`), two of them planned and never dealt until their engines land (the
  Storm Petrel, the Giant Petrel). A run has four squad slots and starts with three
  machines.
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
- **Tags** (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee: the working set, and
  the only tags a component may wear) are build flavour shown in the codex only (not built:
  the codex does not list them yet). A tag carries no rule of its own; a module or passive may
  read one. Every weapon wears its tags by its fantasy, equipment none, but five locked ones the stock
  pass's table did not reach (the Pinion Driver, the Lorentz Contractor, the Syrinx Drone,
  the Fovea Designator, the St. Elmo's Regenerator), and only `melee` is read today (which
  blows lunge on screen).
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
  and its tier-two chassis stock them. The basic kit is eight pieces, each a maker's: two
  rolled guns (the Twin Autoguns, Direct; the Ankle Mortar, Indirect), two flat (the Rivet Gun;
  the Laser Carbine, warm), two shields (the Halo Shield, self or ally; the Canopy, self only, the
  bigger) and two vents (the Coolant Jacket, self or ally; the Bleed Valve, self only, the
  bigger).
- **Damage states**: a component is intact, cracked or destroyed, for the whole battle.

## The skirmish

### Formation
- Foes stand in two ranks of four columns, front and back. A massive foe (size 2) fills a
  whole column and counts as front rank for every rule: always in reach, never exposing its
  column, nothing behind it.
- At the start, foes take their ranks heaviest hitters first from the left (its heaviest
  move's damage times strikes, a breach 1 more; ties in arrival order). Foes left over wait as reinforcements.

### The round
1. Rerolls reset to three (less any a foe drained). Every machine sheds heat by its cooling.
   Every die rolls; entries are equally likely. Round-start passives fire.
2. Every foe picks its move, then its target; both show, exact, before the player acts.
3. The player's turn: spend, lock and reroll in any order. Each spend resolves fully before
   the next. Withdrawal is open at any point. END TURN pulses once no die has anywhere to be
   spent, rerolls aside.
4. END TURN: a machine's Burning adds its heat and loses a stack, and its Scorched goes;
   then heat over a machine's maximum burns hull one for one and the gauge settles at the
   maximum (an overheat). A machine it wrecks is lost on its own turn, before the enemy
   acts.
5. The enemy's turn (below). Round-timed effects end.
6. Machines' statuses tick, and foes' Flak halves. Shield past the maximum (overshield) fades.
7. Reinforcements step into empty slots. Next round.

The fight ends the moment it is decided, mid-turn too: victory when no foe stands or waits,
defeat when every machine is wrecked. There is no round limit.

### Dice
- **Rerolls**: three a round for the team, never banked (Maverick's Playbook, the Giant
  Petrel's passive, below, the one exception). A reroll rerolls every unlocked,
  unspent die, before or after attacking, and lands on any other entry, never the one
  showing; a copy of it may come up, at the odds its copies give it. Tap a die to lock it;
  spending unlocks it; locks clear each round.
- **A stepping die** (the Cassowary's): it never rolls. Each fight opens on a random entry,
  and every roll or reroll steps it to the next entry in order, Rapid's free reroll too; a
  lock holds it. The die shows its next entry beside it, and its hold and codex show its entries as a
  cylinder, in order (the one showing lit and an arrow to the next, in the hold). Its Spin-Up spins the whole die, the entry
  showing included, the one piece that breaks the reroll rule. Every sixth weapon spend of the
  fight counts double, its damage and the stacks it lays; the count shows as six pips under
  the heat bar, the sixth lit when it is next, and equipment and spins are no shots.
- **The Quick-turn Avionics Relay** (the Needletail's passive): a setup, a debuff or a buff
  read on the entry as it is spent, is Rapid on it once a round, the entry dark for the rest of
  the round as Rapid's is; the die shows the Rapid on every setup while the gate is open. A piece Rapid of its own spends no gate.
- **Maverick's Playbook** (the Giant Petrel's passive, not built): while it fights, the team's rerolls
  unspent at the round's end are banked, up to three, and spent in a later round like any
  reroll.
- **Spending**: drag a die onto a target: a weapon onto a foe in reach, equipment onto a
  machine its chip allows. Each die is spent once a round (Rapid excepted). A blank does
  nothing; an unspent die is lost.
- **Equipment**: a shield adds its number up to the target's maximum; a vent removes its
  number in heat; a combined entry spends two halves on one machine (the Wake Diffuser: a vent
  that shields, the vent first, then the shield, sized on the heat the vent left, so the
  Puffin's Slipstream grows it on what is left); a buff grants its status, so many stacks, through so many rounds, or with
  no rounds when the status runs down on its own (Overcharged).
- **A debuff** is a weapon of no damage (a setter, a swap), spent on a foe in reach like any
  weapon: its keywords are its whole effect, no effect adds damage to it (Overcharged, Spun
  Up, Primed's burn), and its heat is a weapon's. The die's kinds: Direct, Indirect, Debuff,
  Buff, Shield, Vent, and the blank. On the die a gun is its reach frame with its number, a
  debuff the frame with the status mark inside and no number (the crosshair's ring with its
  cross cut to four ticks round the mark, or the arc over it; the mark is the debuff chips'
  down arrow), a buff the mark alone; a shield or vent that also buffs is its own glyph with a
  buff chip. A debuff's entry is read as it is spent: the Cottonmouth's drum fires every
  weapon as its shot of 4, so a debuff through the drum is a gun.

### Reach
- **Direct** reaches the front rank, a back-rank foe whose column's front slot is empty, and
  any foe carrying Exposed.
- **Indirect** reaches any foe, at no cost to its firer: area belongs to the keywords (which
  explosives carry Spread and Penetrate is open: no shell carries both, and the Musk Ox's two
  locked guns do).
- A kill clears its slot at once, so a hole in the front opens that column's back to Direct
  (a Gel's halves step up into it at once, below).
- **A mine** (the Lammergeier's Fuse-delayed Bay, its passive): its weapons may be spent on an empty slot in
  the enemy's formation as if a foe stood there (Direct a front slot, or a back slot whose
  front is empty; Indirect any); a Swap and the Syrinx Drone take a foe, a slot holding none
  to move or carry it. The shot waits there, its number as rolled and modified when laid
  (each strike a shot), with its keywords, behind what already waits; its heat lands now.
  Whoever steps in takes every shot waiting, in laid order, before it acts, and a massive
  arrival takes both slots'; shots still waiting when it falls wait on for the next. The
  reinforcement step places every arrival first, then the mines land left to right; any other
  way in (a Swap) sets them off at once. Every keyword acts as the shot lands, as on a blow:
  a stun takes the arrival's first action, and a Chain mine that kills repeats its spender's
  attack on the next foe in reach, rolling and paying heat again (nothing repeats once the
  spender is gone); Lure and Disrupt do nothing, their round being over, and Rapid and
  Volatile acted at the spend. Nothing expires.

### A blow
1. The number: the roll, or the flat number, plus what heat fired adds (Vents all) and what
   the target's missing hull adds.
2. The attacker's modifiers: adds, then multiplies, then floors.
3. Each foe hit takes it through its own modifiers (its Flak adds, then Shocked doubles it),
   then loses its armour off it. A damaging weapon's blow takes them whatever it deals, a 0
   included (the Skua's halved 1); a debuff's blow stays nothing.
- Strikes are separate blows; each rolls and carries the keywords. Heat is paid once a spend.
  A split weapon (the Skua's) rolls once for the two strikes each of its strikes becomes, and
  each takes half the roll, rounded down.
- A raised ceiling or floor (the Muzzle Velocity Booster, the Tactical Databank) moves a
  rolled range by its value before the roll, never past the top; a flat weapon gains
  nothing.
- **The die shows the number** one blow will deal after every modifier; a debuff shows none,
  and a gun whose blow is nothing here shows 0. Dragged over a foe it may strike,
  it shows that foe's number: its missing hull, conditions on it, its Flak, its armour off. A
  Shocked foe's doubling is not folded in (it shows on the foe's chip). Its heat is
  the heat the spend will add, every modifier in (a Scorched machine's weapons run hotter).
  A vent on a machine whose vents blast shows the blast beside it (its mark and the blow the
  heat it would take off makes), and held or dragged anywhere but over an ally, every foe the
  blast may land on wears a turning dashed ring with the number it would deal there.
- **The gauges forecast the round**: what the enemy's blows, the turn's heat and the die in
  hand (its own heat, its bite, its brace) will leave. A Lure in hand shows its turn before it
  is spent: the foes it would turn draw dashed arrows to its machine, those on it already
  solid, and every machine's gauges read the round as the lure would leave it (the Siphon's
  heat a blow included).
- Every number inside a fight is single digits or low tens: a blow 1 to 6, big guns to 10, one
  capstone 12; an amp a point a stack; foe HP 2 to 6 for rank and file, 30 to 40 massive, 12
  to 24 heroes, 80 to 100 for the bosses' slate (not built; the four massive foes standing in
  as bosses are 32 to 40); a foe's blow 2 to 8 (the rank and file's mostly 2 or 3), a massive
  foe's 7 or 8, a hero's 4 to 10, the slate's bosses' 6 to 10; machine hull 20 to 50 by size (the
  Kite's paper hull 12, its row's one-off), shield 6 to 16, field recharge 4 to 8 (about half
  the shield a map turn out of fights), base armour 0 to 2 by role, timed armour to 4 or 5; heat
  1 to 20 (1 to 30 if the pricing needs it), the maxima 10 to 14 (the Musk Ox's 8), a vent 3 to
  8 (the Entropy Condenser's 10 the capstone, paid in hull). The scales are magnitudes,
  not steps: any whole number may be used, and content sits a little past them where its
  loops moved it (the Zombie Knight's 8 HP, the promoted forms' 32 to 48, a hero's finisher, a
  multiple of its blow, to 16). Move alone keeps steps of 5, since a hex costs 5
  or 10. The content's numbers are the stock pass's fills as its loops moved them
  (`docs/measurements.md`; set by `tools/stock_fills.py`), the four Kestrel machines of 23
  October by hand at the same scale; placeholders until play.

### Player keywords
- **Spread** (id `cleave`): also hits the target's neighbours in its rank.
- **Penetrate**: also hits the other rank of the target's column.
- **Breach**: the blow ignores the foe's armour (foes carry no shield), the same word as the
  foes' rider below. The Overclocked Railgun carries it.
- **Burn** (with a number): each foe hit gains that many stacks of Burning, whatever the
  blow dealt (Burn 3: three stacks).
- **Cryo** (with a number): every foe the entry reaches gains that many stacks of Cryo. Any
  machine's hit with a damaging weapon on a foe carrying Cryo spends every stack, whatever the
  hit dealt, and cools the hitter 2 a stack, after the spend's own heat lands; a debuff spends
  none.
- **Suppress**: each foe hit is Suppressed unless its Numbed resists; one already suppressed for
  that action gains nothing more, Numbed included.
- **Shock**: every foe the spend reaches and leaves standing is Shocked after the blow.
- **Chain**: a kill repeats the attack on the next valid target, rolling and paying heat
  again, until a link fails to kill.
- **Lure**: every foe reached and left standing turns on the spender for the round. The Whip
  Scorpion's Siphon reaches every foe in the fight, and every blow a foe lands on it that
  round adds 2 heat to it (Siphoning), in the enemy's turn, after the overheat.
- **Expose** (the Needletail's Fovea Designator, the Swallowtail's Spotting Flare): every foe reached
  and left standing is Exposed through the next round; a second Expose refreshes it, never
  adds.
- **Disrupt**: every foe reached and left standing takes the next move in its list that its
  conditions allow, with a new target. Disrupt resolves before Lure.
- **Rapid** (any component): the die rerolls free onto any other entry, a copy of the same
  component included, and the machine acts again, so copies of one Rapid component chain.
  Rapid carries a cooldown of one (the entry is dark for the rest of the round) unless the
  component prints its own; one that prints none pays heat or Volatile every spend (the Cryo
  Flinger, 1 heat). A Rapid component always carries a limiter, a cooldown, heat or
  Volatile; a piece locked on a stepping die (the Cassowary's Spin-Up) needs none: the
  cylinder cannot chain it into itself.
  A Rapid vent is never below tier three (the one is the Musk Ox's quick reload, locked on a
  tier three, which cools nothing), and a Rapid shield never below tier two (the Laminar
  Deflector's two).
- **Cooldown** (a printed property on specific pieces, or one a passive grants every weapon
  its machine fires, the Kite's two; the longer stands): once spent, the entry is dark for
  that many rounds, this one included, shown on the die with the rounds left; the die may
  land on it, and a dark entry does nothing. No cleanse lifts it, and a crack keeps it.
- **Reset** (the Kite's Pinion Driver): if its spend kills, every entry dark from a cooldown
  comes back, itself included, and the machine acts again, the free roll never landing on the
  entry just spent; a team reroll may bring it back up, and every kill resets it again, with
  no limit.
- **Spray** (the Skua's Flechette Pod): the first strike lands on the foe the entry is spent
  on; each strike after it falls on a random foe in reach at that moment, the same foe again
  allowed, and a kill clears its slot at once, so a hole in the front opens the foe behind it
  to the strikes still to come. The die shows the first strike's number.
- **Web** (the funnel-web's Web Bomb): the foe hit is Webbed, one web however often it is
  webbed; at the end of its action the web bursts, Suppressing it and the next foe to act
  beside it (Webbed, below).
- **Swap** (the Dingo's Combat Translocator): the spend takes two targets, a foe and then
  another foe or an empty slot, and they trade places; no damage; a massive foe does not move.
  A foe keeps its pick and its move, from the rank it now stands in (a back foe pulled into the
  front stands exposed to Direct fire). On the screen: drag the die to the first target and
  drop it; the second targets light; tap one to spend it; a hold reads as ever; drag the die
  again to move it or set it back.
- **Flak** (with a number, Wainwright & Sutler's on-hit): each foe hit gains that many stacks
  of Flak after the blow, whatever it dealt (Flak 2: two stacks), so the blow that lays it never
  feeds on it and a later strike of the same spend does.
- **Volatile** (with a number, any component): spending it costs its owner that much hull,
  past shield and armour, before it acts (Volatile 3: 3 hull). Its carriers today (the Umbra
  Inducer, the Oblation Mantle and the Entropy Condenser) bite 3.
- **Cleanse** (equipment, today): the machine it lands on loses Burning, Scorched,
  Silenced, a foe's Disabled and Corrupted (never a cooldown).
- **Overshield** (shields): may pass the maximum; the excess fades at the round's end, and as
  the fight ends, mid-turn or by a withdrawal, so it never leaves the fight.

Component properties, printed on the entry rather than learned as keywords (the die marks
them with a star): **Vents all** fires the whole heat gauge into the shot, adding its
bonus per step of heat fired, the step printed on the entry (the Afterburner Cannon: +1 per 2),
then its own heat lands. **Overcharged a kill** (the Soulcutter Talons'
rule, no word of its own): each foe it kills gives its owner a stack of Overcharged. **Missing HP** adds its bonus for every
step of HP the target is missing, both numbers on the entry (the Coriolis Accelerator: +1 per
5). **Gated**: a keyword printed with a condition on the foe (a Suppress on a foe carrying
Flak, or on a foe carrying two Burning or more) lands only on a foe that meets it, judged as the
die is spent and before the spend's own riders, so a spend never opens its own gate; the die
held over a foe strikes the chip where it will not land; a mine laid from it is judged as it
lands. Suppress alone carries a gate. **Consumes**: the blow eats every stack of the status the
entry names on its target and deals a point more a stack eaten, before the multiplies, the
die over the foe showing the number with the stacks in; one blow on one foe (no strikes past
one, no area); a mine laid from it eats its arrival's. The Suppression Battery's Suppress is
gated on Flak, and the Backdraft Charge consumes Burning, its Suppress gated at two.
**Burns its firer** (the Stoker's): spending it sets its own machine Burning, the stacks it
prints, after the blow; the die in hand's forecast counts the first tick with the turn's heat.
**The hopper**: a weapon that fills it puts a load in its
machine's hopper for each foe its blows reach, after the blow; a weapon that fires it takes
up to its most loads a shot, each adding its bonus to the blow, and spends them (the Honey
Badger's Chainsaw Claw fills, its Bullion Fragmenter fires three at +1). **Braces**:
spending it Armours its owner, the stacks it says, an armour point each, until the round's
end (the Wild Boar's Breaching Plow, two). **Rolls again** (the Nemesis's Knuckle of Fury, on rage): spending it
with a stack of its status spends one, and the die rolls again, a plain roll as the round
opens, so the machine acts again and the same entry may show again; nothing switches off,
the stacks being the limit, and the fight's last blow rolls nothing. **The pull** (the
Lammergeier's Lorentz Contractor): every mine on the field gathers into the slot it is spent on, and a foe
standing there takes them now, in laid order; spent on an empty slot, it gathers them there. **The drone**
(the Lammergeier's Syrinx Drone): the foe carries the Syrinx Drone; if it already carries Exposed (read
before the drone lands) the drone is Rapid, and otherwise it gives the foe Exposed, never refreshing it. **The Immelmann Booster** (the Giant Petrel's, Rapid, not built):
spent on itself, the team gains a reroll; spent on an ally whose die is spent, three rerolls
are paid, the ally's die rolls again and it acts again. **The Spindrift Salvo** (the Giant Petrel's,
not built): a kill by its shot gives the team two rerolls. **The Reheat Uplink** (the Giant Petrel's,
not built): the ally gains Overcharged 2 and its die rolls again, which does nothing on a
spent die. **Spillover** (the Wild
Boar's Juggernaut Drive, on every weapon it fires): damage past the kill of a front-rank foe
carries into the foe behind it as plain damage, the killing strike's excess and every later
strike of the spend whole; the engine runs it as a keyword the passive grants written out,
so each of the Boar's weapons wears the star, the hold reading the passive's line, and no
keyword chip.

### Buffs, debuffs and resistance
A **store** is a capped resource a machine fills and spends (the Muster, the rage, the
hopper, the Cassowary's shot count; the Musk Ox's magazine works the same way), its own kind
and never a buff: each shows as a bar under the heat, boxes or a smooth fill in segments by how
it fills, and no Silence or Purge touches it, its filling or its use. An active effect a store
grants is a buff and shows as one: a Silence sleeps it, and a Purge silences it for a turn
instead of taking it, since the store would grant it again (not built: no store grants one
yet). The hopper has no cap yet, so it shows as a chip.

On a machine:
- **Overcharged** (buff): +1 damage a stack, so the count is the bonus. At the end of each
  round it halves, rounded down, whatever granted it, until it is gone; a buff component
  grants it stacks and no rounds. On the Ammit nothing of it fades: its Quintessence Tap
  keeps every stack for the battle, whatever granted it.
- **Armoured** (buff, on either side): armour +1 a stack, every stack at once, whatever
  granted it, so the count is the armour: a machine's until the round's end, a foe's (from
  its brace) until its next action.
- **Primed** (buff): each blow leaves a Burning stack per Primed stack on its target.
- **Phased** (buff): cannot act, take damage or be targeted until the
  round's end, so allies cannot vent or shield it, a foe's intent on it re-picks, and a blow or
  a special at every machine passes it by; it still cools by its cooling, and ticks and
  overheats land. Granted only to a unit that has not acted
  this round, whose die stands down as it is granted.
- **Muster** (store, the Swallowtail's): its charges. Every die that rolls fills
  it a sliver, thirty rolls a charge, a kill by its own guns five rolls' worth, up to three
  charges; it starts each fight empty and never decays. It shows as a smooth bar under the
  heat, a segment a charge. Each of its locked
  pieces has a plain form and a charged one that spends a muster. With a charge up, a locked
  piece goes out charged, unasked, and its die shows the charged form under a double frame;
  when the charged form has nowhere to land (Phased once any ally has acted, the act again
  with no ally spent), the plain form goes out and the charge waits. The
  Mooring Screens shield every ally (never the carrier), or Phase every ally, only while none
  has acted this round, so it is never a selective protection;
  the Spotting Flare Exposes a foe, or Exposes and Suppresses it; the Sutler's Hoist cools an ally
  2 and then shields it, or fills its shield, cools it to nothing and cleanses it; the Reveille
  Horn gives the team a reroll, or rolls a spent ally's die again so it acts again.
- **Rallied** (buff): the team has one reroll more this round.
- **Spun Up** (buff): its next weapon spend deals +2 a stack, then every stack is spent, by a
  weapon of no damage too; carried between turns until a weapon spends it.
- **Retaliate** (buff): a foe whose blow reaches this machine's bare hull is Shocked.
- **Regenerating** (buff, the Storm Petrel's St. Elmo's Regenerator, not built): 2 shield at the start of each
  round for three rounds; it stacks, each grant keeping its own end.
- **Barrier** (buff): the next blow a foe lands on this machine deals no damage, so it never
  injures; its riders land, and a blow of nothing leaves it standing. One at a time; until
  the round's end. Never granted to every ally at once. The Blast Door grants it, self or ally.
- **Ward** (buff): no rider a foe lays lands on this machine this round, from a blow or from a
  move of its own (breach, burn, scorch, disable, corrupt, silence, purge), so its shield
  absorbs a breach like any blow; a blow's damage lands. Until the round's end. The Decoherence
  Veil grants it, self or ally.
- **Rage** (store, the Nemesis's): a stack each time it takes hull damage (a blow, a bite
  of its own, an overheat), up to 5, spent by its fists to roll again; lasts the skirmish,
  never decays, and nothing cleanses it. It shows as five boxes under the heat, one lit a
  stack.
- **Hopper** (store, the Honey Badger's): loads for a weapon that fires the hopper; lasts
  the skirmish, never decays, and nothing cleanses it.
- **Sealed** (buff, the Armadillo's form): a shield it spends on itself seals it: armour +3,
  its own cooling stopped, 3 heat more at the end of each turn before the overheat; a vent or
  a weapon that deals damage opens it; a shield on an ally, a buff and a weapon of no damage
  leave the form as it is. An ally's vent still cools it. One seal, however many shields.
- **Burning** (debuff, from a foe's burn; a foe's Burning below is the same word on the
  other body): +1 heat a stack at the end of the player's turn, before the overheat, then a
  stack fades, so a vent makes room for it or a cleanse takes it off. Cleansable.
- **Scorched** (debuff, from a foe's scorch): every weapon the machine fires runs 1 hotter a
  stack, until the end of the player's turn, when every stack goes, so it never piles up.
  Cleansable.
- **Disabled** (debuff): the entry comes up blank through the machine's next turn.
- **Corrupted** (debuff): each spend of the entry bites its owner 3 a stack, shield first,
  no armour off it; lasts the skirmish.
- **Silenced** (debuff, a foe's silence): its buffs (a kept Overcharged too) count for
  nothing through its next round, then wake. Its components' keywords act as ever (a Volatile
  still bites), and its stores fill and spend as ever. Cleansable; a Ward turns the silence
  away. A foe's purge takes every buff, every stack; its stores and its passives stay; a Ward
  turns it away too.
- **Hot Streak** (the Kite's, its passive's price): its shots run 1 hotter a stack this fight,
  a stack for each attack that killed; no cleanse, silence or purge lifts it.

On a foe:
- **Burning** (debuff): 1 damage a stack at the start of its action, past armour, then a
  stack fades. It never stops healing.
- **Suppressed** (debuff): it loses its next action: this round's, or the next round's when
  it has already acted this turn. It never stacks and never carries: a second suppress on a
  foe already suppressed, a Paradox's included, does nothing and numbs it no further.
- **Shocked** (debuff): the next team blow of a damaging weapon deals double, spending the
  shock whatever the blow dealt (a vent's blast and a mine's shot of a damaging weapon too); a
  debuff leaves it standing; it never stacks.
- **Exposed** (debuff): it stands in Direct reach of every machine as if its
  column's front were empty, and its armour counts for nothing, its own and any Armoured.
  Through the next round; refreshed, never added. A back-rank foe whose front slot is empty
  is exposed by its formation, in reach only.
- **Syrinx Drone** (debuff, the name of the Lammergeier's piece that leaves it): the next weapon to kill it, any
  machine's, leaves its shot in the slot it empties, a mine; one mine a drone; it lasts the
  skirmish, and a death by a tick leaves nothing.
- **Paradox** (debuff, while the Baboon fights): a stack each time the foe gains any other
  debuff, once a spend per debuff however many strikes or stacks; at three it is Suppressed
  (Numbed may resist, and a foe already suppressed gains nothing) and the Paradox clears
  either way. It never decays. The Suppressed a Paradox causes adds none; a weapon's
  Suppressed does.
- **Vitriol** (debuff): at its action it loses 10% of its current HP a stack, past armour,
  after Burning on what it leaves, the whole share rounded down and never the last hit point,
  then a stack fades; it never finishes a foe. The funnel-web's Ambush lays it, a stack per hit
  with a damaging weapon, whatever the hit dealt, as its text says; a web or a lure lays none.
- **Webbed** (debuff): at the end of its action, skipped or not, the web bursts: it is
  Suppressed (its next action, since it has acted; a countdown it gathers is held a round),
  and so is the next foe to act beside it in its rank, its right-hand neighbour, which loses
  this round's action, or with none standing there its left-hand one, which has acted and
  loses its next (Numbed may resist, each for itself; a foe already suppressed gains nothing,
  as from any second suppress; each half feeds the Paradox as a weapon's Suppressed does).
  Killed first, or gone by the end of its action, it takes its web with it. Its chip points at
  the neighbour the burst catches.
- **Cryo** (debuff): a hit on it with a damaging weapon spends every stack, whatever it dealt,
  and cools the hitter 2 a stack; a debuff spends none. It never fades on its own.
- **Flak** (debuff): every blow of a damaging weapon it takes deals a point more a stack, a
  blow of 0 included, before its multiplies and its armour (a Shocked foe takes blow plus Flak,
  doubled); a debuff's blow stays nothing. The stacks halve at the end of each round, rounded
  down.
- **Kindled** (buff, Rally): hits harder by its rally's value through the next round. It goes
  live when that round's intents are drawn, so a foe striking after the rallier this turn
  hits the number it showed.
- **Getting Back Up** (buff, Reraise, on itself or from an ally's): after it falls it gets
  back up once, whole, in its own slot and at once, unless it self-destructed; its round is
  over, as a split's half's is, and it takes a mine its fall left there.
- **Numbed** (buff, nothing removes it, drawn in brackets): each stack is a 10%
  chance a suppress fails. A landed suppress adds two stacks (three on a massive foe); a
  shrugged one adds none, and one wasted on a foe already suppressed adds none; a stack fades
  at each of its turns. Nothing reads, deepens, spreads or cleanses it, and no foe resists by
  nature.

"A foe carrying a status" (the Susceptibility Tensor) means a debuff the team put on it:
Burning, Suppressed, Shocked, Paradox, Vitriol, Webbed, Cryo, Flak, Exposed or the Syrinx Drone.

### Shields, armour, hull
- A shield absorbs a blow up to its number and loses what it absorbed; the excess reaches
  the hull. A **breach** blow ignores the shield and the armour: the shield stands, the
  armour counts for nothing, and the whole blow reaches the hull.
- A machine's armour comes off every blow that reaches its hull, flat, what passes a shield
  included, never a breach; a blow at or under the armour is nothing; a shield takes no armour
  off. A foe's armour comes off every blow on it the same way, never off Burning, Vitriol or a
  breaching weapon. Base armour is set by role (a tank 2, a heavy worker 1, the rest 0), and
  Armoured adds to it (a brace: buff equipment, the Breaching Plow, the Siphon) until the
  round's end, the Armadillo's seal until a vent or a damaging weapon opens it.
  Damage-taken effects apply before armour.
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
- **Ammo** (the Musk Ox's Desublimation Forge): its damaging guns spend ammo instead
  of heating it, 1 for every 2 heat a gun's own spend would make, rounded up, at least 1, the
  price printed on the die where the gun's heat would be; its debuffs, buffs and shields and
  the foes' heat land on its heat bar as on any machine's, Scorched's extra included. The
  magazine is a bar under the heat bar, a notch an ammo, never a status, so no Silence or Purge
  reaches it; it holds 10, opens each fight at 3 and gains 1 at the start of every round after
  the first; a vent it spends on itself adds 3, a shield 2; a gun it cannot pay for cannot be
  spent (the die says DRY). Its Shrapnel Recuperator returns 1 for every foe its blows reach;
  its Unrestricted Expenditure fires every ammo in the magazine as a strike, each at a random
  live foe with Spread and Penetrate, the magazine its price and no heat; its quick reload,
  Rapid, adds 2 for 3 heat, and the Forge counts it as no vent.
- A piece of equipment that prints heat (the quick reload) adds it to its spender as it is
  spent.
- Foes heat machines only through two debuffs, never outright: Burning, the harsher, adds
  its heat at the end of the player's turn before the overheat, so a vent makes room for it
  or a cleanse takes it off; Scorched, the softer, heats only the weapons the machine fires
  in the turn that follows, so equipment or a cool weapon plays round it. A foe's burn leaves Burning and its scorch
  leaves Scorched, a stack a blow; the Drake's Stoke sets the hottest machine burning, and
  the Magma Elemental's Eruption, the Black Mage's Fira and the Summoner's Pyroclasm scorch every
  machine.

### Injury
- A foe's blow that puts a quarter of the machine's maximum hull or more past armour into
  its hull (a breach's whole blow included) rolls the machine's die: an intact entry cracks, a
  cracked one is destroyed, a blank shrugs it off. A shield absorbs its share first and what
  reaches the hull counts; a Barrier's blow never does. Bites and overheats never injure.
- **Cracked**: keeps its number, heat, cooldown, action and passive; loses its keywords.
- **Destroyed**: blank; its passive keeps its stat bonuses and loses its abilities. The Honey
  Badger's components are never destroyed.

### Foes
- A foe has HP (a foe's word; a machine has hull), a base attack, a rank it holds, a size,
  flat armour (the four built bosses 1, the promoted forms 2) and perhaps an aim. Its damage
  never rolls.
- **Its move**: from the moves whose conditions hold, weighted by each move's own weight (attacks mostly 2, specials 1, the Bomb's Self-Destruct 3), never
  the same special twice running while anything else is open. A move without a condition
  fires on its weight; the conditions read the foe's own side or what its move needs: below
  half, hurt, fewer than two summons waiting, a foe behind it, another foe on the field, one
  of its own hurt, a machine carrying a buff, one of its own not readied. A move may
  carry a countdown: it gathers, landing that many rounds after it is announced, and nothing
  hits meanwhile; its pick holds while the machine stands; Suppress holds it a round, Disrupt
  breaks it off, and the foe stays on the field.
- **Its target**, drawn as the round opens: at random, unless the foe or its move carries an
  aim, as its threat calls for: exposed (weighted by the hull its blows would reach
  plus half the shield they would break), heat (the hottest machine), armed (a machine
  showing an intact weapon, the exposed when none does), focus (its rank shares one pick),
  buffed (the machine carrying the most stacks of buffs, the exposed when none does). The
  foes pick in the order they strike and never over-commit: a machine the blows already picked
  would wreck through its shield and armour is passed over while another stands (a blow at
  every machine counts on each; a special, a suppressed foe and a countdown still gathering
  count nothing). The pick is a commitment; Lure and Disrupt move it, and a foe whose machine
  has fallen picks again as it acts. A special that acts on nobody
  in particular (a brace, a regrow, a rally, a scorch all) keeps its pick and shows no arrow:
  it is aimed at no machine.
- **A blow** is its base attack times the move's factor, plus its swarm for each other live
  foe of its type; strikes are separate blows. Riders (a Ward turns away all but the last
  two): breach (the blow ignores the shield and the armour), scorch (stacks of Scorched), burn (stacks of
  Burning), disable (the entry the machine shows), corrupt (Corrupted stacks on it), silence
  (Silenced), purge (every buff gone, the stores kept; a hero's or a boss's),
  self-destruct (the striker dies after, for good), every machine
  (each strike lands on every live machine in turn, its number what each takes; no aim or
  Lure moves it). Scorch, burn and corrupt each say their stacks a blow, as the player's Burn
  does (Scorch 2: two).
- **A special** replaces the blow: brace (Armoured, its value in stacks, an armour point each, until its
  next action), regrow (heals its value), cure (the most hurt of its own, itself included, heals its
  value), brace all (the same on every foe in the fight, through the next round), revive once,
  revive an ally (Getting Back Up on one of its own, never itself, not readied already: a
  party member first, the heaviest hitter among them, then the rest of its own the same way),
  summon,
  rally, drain rerolls, burn (stacks of Burning on one machine), scorch all (stacks of
  Scorched on every machine), corrupt all (Corrupted stacks on the entry every machine shows),
  disable, silence, purge (each on its target, no blow). A Ward turns away every one of them
  that lands on its machine, a scorch all's and a corrupt all's share included, and a scorch all
  or a corrupt all passes a Phased machine by. No foe in content carries a silence or a purge
  yet.
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
- **A split** (the Gel): a dead Gel splits into two Half-Gels at once (one deep), standing as a
  pair in the slot it fell from: a twin slot, one slot to the formation, so its hole never
  opens (the Gel is a wall, not an attacker, and its blow carries no breach). An area blow
  that reaches the slot (Spread, Penetrate, a mine's) reaches both halves, aimed at one of them
  or beside; a single-target blow, a Spillover included, the one it is spent on. The slot is
  full while either stands: no mine is laid in it, and a Syrinx Drone on a half that falls
  while its twin stands leaves none. The left half acts first; a web on it catches its twin; a
  Swap moves the pair together and never swaps a half with its twin. When one falls the other
  keeps the slot alone, and with both gone it is a plain slot: the pair is only ever its
  split's, so no half joins another's slot. A mine waiting in the slot goes off on the pair
  as they step up. Their round is over: no intent, no Lure or Disrupt turns them, a stun takes
  their next action, and they act from the next round. A split that is no pair (none in
  content) steps up one into the slot and the rest into the nearest empty slots of their rank.
- **A summon** takes an empty slot of its rank at once, the nearest its summoner's column, the
  left on a tie, its round over like a split's half's; with no room it waits in the
  reinforcements. A foe joining the reinforcements is shown going in: it flies into its rank's
  count in the gutter, which goes up as it lands.
- **Reinforcements**: at the round's end every empty column takes a waiting massive foe
  first, then each empty slot, left to right, a random waiting foe of its rank. The formation
  shows how many wait for each rank, and the massive ones apart, in its right gutter.

### Withdrawal
Open at any point of the player's turn, but in the boss's fight, which ends in the boss's fall
or the team's. Withdrawing ends the turn, so heat over the maximum
burns first; then the enemy takes its full turn, and the skirmish ends; the round's end does
not run, but shield past the maximum fades as the fight ends. Kills stay counted, machines
keep their damage and shields do not refill; a pack keeps its own survivors, who return whole
(a foe that joined it in the fight, a Gel's half, a raised Revenant or a part, is no survivor,
and every one of them that fell is a kill).

### Passives: triggers and conditions
- Triggers: static, on attack, on injury, on round start (after the roll), on skirmish start,
  on hull damage (any hull lost: a blow, a bite or an overheat), on shield gain, on shield
  granted (an ally this machine shields), on heat gain, out of combat, on foe status (a foe
  gains a debuff), on stack (this machine applies stacks), on a kill (once after an attack of
  this machine's that killed, chains and spills included). No trigger feeds itself.
- A passive may double a weapon's printed number before its buffs, what the entry prints
  included (heat fired, missing HP, hopper loads, stacks consumed), the buffs added once
  after it (the Kite's), and may grant a cooldown to every weapon its machine fires. It may
  split every damaging weapon instead (the Skua's): the weapon strikes twice as often, each
  roll, what the entry prints included, divided between the two strikes, rounded down, and
  every buff and the foe's conditions counting on each strike, its armour too; the die shows
  a strike's share with the strikes beside it ("1 ×2"). A debuff has no number to halve and
  fires twice all the same, its riders landing on each strike (a Web, a Lure, a Disrupt, a
  Shock, an Expose and a Swap still land once a spend).
- Conditions: the component is cracked; the weapon is rolled; the reach is direct or
  indirect; the target carries a debuff; an ally is in the fight; the component carries a tag;
  the target shows no intent on this machine (the funnel-web's: a foe shows intent as its
  arrow is drawn, on its pick or on every machine, a gathering countdown included, and none
  when aimed at another machine, Suppressed, or on a special that acts on nobody in
  particular; read at the spend, before the spend's own riders, each foe reached judged
  alone); the rank the spend is aimed at (the Cottonmouth's), and on an attack's own effects its
  reach with it (the Ram Frame's Direct blows at the front rank, the Artillery Rangefinder's
  Indirect blows at the back, a point each); the striker carries a status (the Prairie Dog's fight
  half: its damage-taken effect reads the foe whose blow it is taking, so a foe carrying Flak
  hits it 1 lighter, whoever laid the Flak).
- A passive may lay a status on each foe its blows hit, a stack per strike, the foe judged by
  the passive's condition alone; every strike that reaches it alive lays it, a blow of nothing
  included, unless the passive's text asks for a damaging weapon's hit (the funnel-web's
  Vitriol).
- A passive may change an entry's reach, grant it a keyword or move its range; the entry as
  changed is what is spent, shown and weighed, while the die keeps the real one. The
  Cottonmouth's replaces every weapon's shot whole, first, under every other change (Indirect,
  a flat 4, heat 3, one blow, Ballistic, the weapon's keywords, rules and tags kept),
  Penetrate when aimed at the back rank and Spread at the front, shown on the die over the foe
  it is dragged to. The Whip Scorpion's makes every vent it spends on itself blast a random
  live foe, back rank included, for the heat it took off, as its own blow through the
  pipeline, the foe's Flak, Shocked and armour applying (a vent on an ally blasts nothing, an
  ally's vent on it blasts nothing, a vent with no heat to take off blasts nothing).

### Every number is a question
Every stat, damage figure and property is read through one pipeline (`sim/effects.gd`), in
one order: suppression (shortest-lived source first), the gate (live, triggered, condition
met, and for an ability its component not destroyed), adds, multiplies, floors and caps,
overrides (shortest-lived source, then latest granted). Every buff, debuff, passive, module
and reward is a modifier with a source and a scope: rounds, skirmish, battle or loadout. The
same status in the same scope stacks: an add counts per stack, a multiply applies per stack,
and a ticking status loses a stack at its owner's turn, a halving one half of them at the
round's end, rounded down; a timed one stacks only with a grant that ends the same round, so each grant's stacks go
when its own rounds run out. A status runs down to zero on its own clock or is timed, never
both. A status's
definition may say otherwise: one that renews keeps one grant, its end the later and its
count the larger (Suppressed, Retaliate), which on an untimed one-stack status (Shocked,
Getting Back Up, Guarded) means a second grant changes nothing. Nothing writes to
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
  takes whatever move is left and ends the move (lit with a dashed edge and a stop sign);
  crags are walls except to flyers. Tracked:
  ruins slow. Walker: water slow. Wheeled: open fast; rough, ruins and water slow. Hover:
  water fast; rough and ruins slow. Flyer: everything normal. Machines never enter or cross
  another unit's hex.
- **Setup**: up to four machines on the row before the gate; the lead domain's spawn list as
  packs three to five rows below the rift; the boss one row below the rift.
- **A turn**: the map shows every pack's coming walk, read from where the machines' plans end,
  and every pack's ring. Each machine has one action (the Dingo two): move, in pieces if
  wanted, then may fight; a fight ends the action however it ends. A selected machine lights
  the hexes its move reaches, and in red the hexes past them within its attack range: where it
  could attack from. A move is planned: its route shows from where the machine stands, and the
  next move or order reads from the route's end. UNDO takes back the last move or order,
  whoever made it, in the order they were made, back to the turn's start or the last fight.
  A caught machine's fight comes first. ENGAGE and END TURN play every planned move first (the
  boss's fight aside, below);
  then the fight opens, or the turn ends: packs walk and strike; machines that did not fight
  regain shield at their field rate; Rift Pressure rises one. Once every machine has fought,
  is ordered, is caught, or can neither move nor reach a pack where it stands, the button
  pulses.
- **Orders**: a tap or drag onto a pack plans the machine's move to the farthest hex in attack
  range its move reaches (or leaves it, if in range) and orders it, one step for UNDO; a
  second tap on the pack takes the order back. ENGAGE opens one fight at a time: the first
  order's pack and every machine ordered onto it.
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
  the Prairie Dog) and walk to put it inside their ring; the prey wears a tag by it, a plate a
  hunter with the hunter's picture and a target. A hunter with its prey in its ring
  at the start of the player's turn has caught it: that fight comes first, the prey cannot
  move first, others in range may join.
- **The carry** (the Swallowtail's Muster Deck): the machines on the hexes beside
  it are lifted in place when it moves and travel as a ring round it, so they never block its
  way; it lands them as a block, each where it rode from the carrier, keeping whatever move and
  action they had. A stop where a rider would land on a hex it cannot stand on (off the field,
  a structure, ground it cannot take, another unit) is no move: the drawn route marks the stop
  and that hex (NO ROOM), and letting go there is refused. A caught machine does not ride. An
  undo of the carrier's move takes the riders back with it.
- **The boss** patrols its ring of the rift (ring 2; a final's back-rank hero ring 3), joins fights in its ring and can
  be attacked from the first turn; its death wins the battle. A fight it is in, ordered onto
  it or joined by its ring, takes every machine, wherever it stands and whether or not it has
  fought this turn; nothing moves first (ENGAGE goes straight to the reveal) and nobody
  withdraws, so it ends the battle. The unit at the rift commands
  it: the lead domain's boss, a final's hero with its escort (the domain's first pack's foe,
  one for each other column), or the finale's line; it stands while one of its commanders
  does and holds the rift whatever its escort.
- **Rift Pressure** fills at 12 (+1 each enemy turn, never inside a fight) and spawns the next
  pack of the spawn cycle by the rift. Packs never escalate.
- **The battle ends** when the gate reaches zero, every machine is wrecked, or the boss dies
  (every commander of the unit at the rift).
- Not built: city defences, the Rupture meter and its Fractures, the sealed boss, rift tiles.

## The campaign

Headless only (`sim/campaign.gd`); no screen drives a run yet.

- **Cities**: the capital (the Council and the Arsenal) and four around it, one for each city
  maker. A city's gate is 200, the capital's 300. The capital's gate is the run's life: the
  run is lost at zero.
- **Start**: a tender of one tier-one machine from each city maker (by seed, in stock
  loadout; a chassis whose passive or locked piece is still planned is not dealt, so a maker
  whose only tier one is a draft offers nothing until it lands); the player takes three. Four squad slots, 0 salvage, 100 Favour, a blueprint for
  every basic, the eight of tier zero.
- **A turn** is one battle at a front, with one to four ready machines, or a pass. The whole
  roster goes to the one front; the open fronts left alone bleed (below). A battle is played
  to its end and a team wipe is the graded loss; a withdrawal from a battle is not built (open:
  the bible's section 4).
- **Won** (the boss dies): the gate refills, the rift closes, no rift opens there next turn;
  10 salvage a kill, the boss's included (to be weighted by the foe's threat, not built); 100 Favour less 1 per gate
  point the city lost, never below 0; a research
  token of the lead domain and an offer from the host maker are owed (the token a choice of
  three blueprints of the domain's theme at the Convergence's tier; the offer a chassis, a
  component copy and a module from the maker's catalogue, one taken free; unpacking and offers
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
- **The party**: dealt as the run starts, one hero to each domain from its bench, the front
  jobs and the back as even as the benches allow (two and two), by the seed; no job changes
  after.
- **A rift's boss**: each battle brings one of its domain's bosses that its battles have not
  ended on this run, drawn by the seed; once every one has been, any of them.
- **Finals and finale**: three bosses of one domain beaten make its next rift a final, fought
  against the domain's dealt hero in its rank with the domain's wildlife beside it; it is won
  when the hero falls, and a won final thins the domain. The finale is due at Convergence 12,
  one sooner per fallen city; the capital is then the only front. It is fought against the
  party promoted, a column a domain in the content's order: each hero's promoted form (its
  hero's kit, massive, armour 2, and one move more, built for the Cleric alone: Reraise on an
  ally), and for a domain whose final was won a
  standing domain's boss, each standing boss drawn in turn before any comes twice. Winning
  it wins the run. (Not built: the party card, the reserve of elites and bosses behind the
  line.)
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
