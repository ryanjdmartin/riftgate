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
  (`content/chassis.json`). A run has four squad slots and starts with three
  machines.
- **The die**: one entry per component, fixed components first, then one per hardpoint in
  order. Each entry shows its place, from I, as a grey Roman numeral: top left on the die,
  beside its name in its readout, and down the codex. An empty hardpoint is a blank entry; nothing fills it. A full,
  undamaged machine is reliable.
- **Components** come in four kinds, as the die's main icon shows them: a **weapon** deals
  damage and is spent on a foe in its reach; **equipment** is a buff or a debuff and deals
  none, a buff spent on a machine and a debuff on a foe in its reach; a **shield** and a
  **vent** are spent on a machine. A shield, a vent or a buff goes to itself and allies by
  default, or self only, or allies only, as its chip says. A passive may make a piece count as
  a second kind on its machine (the Whip Scorpion's vents blast a foe, so they are weapons
  too there, and the blast is a weapon's hit): the die's readout shows the kind on the machine, the
  codex the piece as built. A rule over the pieces a machine aims at foes reads every weapon
  and equipment aimed at a foe, so a buff, a shield and a vent stay out of it. A
  component has a number (or none), heat, strikes, up to three authored keywords, and may
  carry a passive. A **fixed** component is built into its chassis, uses no hardpoint, is
  never a blueprint and has no tier.
- **Hits**: a rule reads one of three: damaging a foe with a weapon (its blow dealt
  something); hitting a foe with a weapon (any blow of a weapon, a blow of 0 included); hitting
  a foe with a weapon or equipment (anything spent on it, a debuff included).
- **Rolled or flat**: a rolled weapon shows a range and rolls in it when spent; a flat weapon
  is one number with no roll, however many things feed it (heat fired, missing hull, buffs,
  armour). Neither shape owns heat: a weapon's heat is its own number, set by its niche like
  its reach. There are no crits and no weapon classes.
- **Tags** (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee: the working set, and
  the only tags a component may wear) are build flavour, shown on its readout's last line and
  beside its name in its codex row. A tag carries no rule of its own; a module or passive may
  read one. Every weapon and debuff wears its tags by its fantasy, a shield, a vent and a buff none, but five locked ones the stock
  pass's table did not reach (the Pinion Driver, the Lorentz Contractor, the Syrinx Drone,
  the Fovea Designator, the St. Elmo's Regenerator), and only `melee` is read today (which
  blows lunge on screen).
  Melee means short range, a shotgun included, never only a blade.
- **Modules** sit inside the machine and are never spent: stat lines up or down (hull,
  shield, heat maximum, armour, move, field recharge, cooling) and at most one rule, tier 1
  to 3, run as one passive nothing on the die can remove. The same module twice stacks.
  Fitted in the harness and the quick campaign's hangar (not in the campaign yet). Catalogue:
  `content/modules.json`.
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
- **Damage states**: a component is intact or destroyed, for the whole battle.

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
2. Every foe picks its move, then its target; both show, exact, before the player acts, its
   intent chip under it: the move's kind, its blow's number and strikes, and each rider by its
   mark, a numbered one with its stacks. A blow's number counts the rallies on their way to it
   this round (Kindled, below).
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
  showing; a copy of it may come up, at the odds its copies give it. Double-tap or hold a die
  to lock it, and again to unlock it; spending unlocks it; locks clear each round.
- **A stepping die** (the Cassowary's): it never rolls. Each fight opens on a random entry,
  and every roll or reroll steps it to the next entry in order, Rapid's free reroll too; a
  lock holds it. The die shows its next entry beside it, and its readout and codex show its entries as a
  cylinder, in order (the one showing lit and an arrow to the next, in the readout). Its Spin-Up spins the whole die, the entry
  showing included, the one piece that breaks the reroll rule, so it may land on itself and
  be spent again. Every sixth weapon or equipment it aims at a foe in the fight counts double,
  its damage and the stacks it lays; the count shows as six pips under the heat bar, the sixth
  lit when it is next, and a shield, a vent, a buff and a spin are no shots.
- **The Quick-turn Avionics Relay** (the Needletail's passive): equipment, a buff or a debuff
  read on the entry as it is spent, is Rapid on it once a round, the entry dark for the rest of
  the round as Rapid's is; the die shows the Rapid on every setup while the gate is open. A piece Rapid of its own spends no gate.
- **Maverick's Playbook** (the Giant Petrel's passive): the team's rerolls unspent as the
  player's turn ends are banked, up to three, and come back at the next round's start beside
  its three, spent like any reroll; a roar's cost comes off the whole. It banks while the
  Giant Petrel fights: wrecked by the next round's start, it carries nothing.
- **Spending**: drag a die onto a target: a weapon or a debuff onto a foe in reach, a shield, a
  vent or a buff onto a machine its chip allows. Each die is spent once a round (Rapid excepted). A blank does
  nothing; an unspent die is lost.
- **On a machine**: a shield adds its number up to the target's maximum; a vent removes its
  number in heat; a combined entry spends two halves on one machine (the Wake Diffuser: a vent
  that shields, the vent first, then the shield, sized on the heat the vent left, so the
  Puffin's Slipstream grows it on what is left); a buff grants its status, so many stacks, through so many rounds, or with
  no rounds when the status runs down on its own (Overcharged).
- **A debuff** is equipment aimed at a foe (a setter, a swap), spent on a foe in reach as a
  weapon is: its keywords are its whole effect, no effect adds damage to it (Overcharged, Spun
  Up, Primed's burn), and its heat is paid as a weapon's. The die's kinds: Direct, Indirect, Debuff,
  Buff, Shield, Vent, and the blank. On the die a gun is its reach frame with its number, a
  debuff the frame with the status mark inside and no number (the crosshair's ring with its
  cross cut to four ticks round the mark, or the arc over it; the mark is the debuff chips'
  down arrow), a buff the mark alone; a shield or vent that also buffs is its own glyph with a
  buff chip. A debuff's entry is read as it is spent: the Cottonmouth's drum fires every
  weapon and equipment it aims at a foe as its shot of 4, so a debuff through the drum is a
  weapon.

### Reach
- **Direct** reaches the front rank, a back-rank foe whose column's front slot is empty, and
  any foe carrying Exposed.
- **Indirect** reaches any foe, at no cost to its firer: area belongs to the keywords (which
  explosives carry which is open: no shell carries Splash, and the Musk Ox's two locked guns
  do).
- Chain's arcs read no reach: they land on every Shocked foe on the field, front or back,
  whatever the gun's reach.
- A kill clears its slot at once, so a hole in the front opens that column's back to Direct
  (a Gel's halves step up into it at once, below).
- **A mine** (the Lammergeier's Fuse-delayed Bay, its passive): every weapon and equipment it
  aims at a foe may also be spent on an empty slot in the enemy's formation as if a foe stood there (Direct a front slot, or a back slot whose
  front is empty; Indirect any); a Swap and the Syrinx Drone take a foe, a slot holding none
  to move or carry it. The shot waits there, its number as rolled and modified when laid
  (each strike a shot), with its keywords, behind what already waits; its heat lands now.
  Whoever steps in takes every shot waiting, in laid order, before it acts, and a massive
  arrival takes both slots'; shots still waiting when it falls wait on for the next. The
  reinforcement step places every arrival first, then the mines land left to right; any other
  way in (a Swap) sets them off at once. Every keyword acts as the shot lands, as on a blow:
  a stun takes the arrival's first action, and a Chain mine arcs its number as laid to every
  other Shocked foe on the field as it lands, then charges one other foe at random; Lure and
  Disrupt do nothing, their round being over, and Rapid and Volatile acted at the spend.
  Nothing expires.

### A blow
Every foe a strike reaches takes a blow of its own, read in one order:
1. The number: on the foe the strike is aimed at, the roll or the flat number; on every other
   foe its area reaches, the number of the shape it stands in (Spread's beside the target,
   Penetrate's in the other rank of its column, Splash's both); on every other Shocked foe on
   the field, Chain's (a foe in a shape and Shocked takes the shape's, one blow). Then what the
   entry prints from its firer: what heat fired adds (Vents all) and the hopper's loads.
2. The attacker's modifiers, on every blow: adds, then multiplies, then floors, a condition on
   the foe read on that foe (a status it carries, its rank).
3. The foe's own, flat first: what the entry reads off it (the hull it is missing on every
   blow, the stacks a consumer eats on it on its first blow) and its Flak; then its multiplies
   (Shocked doubles a weapon's strike aimed at it, never a blow that only reaches it); then its
   armour comes off. A weapon's blow takes them whatever it deals, a 0 included (the Skua's
   halved 1); a debuff's blow stays nothing. Its riders land on every foe struck.
- Every blow of a strike is read before any of them lands, so a kill in it (the talons'
  Overcharged) feeds the next strike and never the same strike's other blows. A foe's own
  reads (the hull it is missing, the stacks it carries) are taken as the die is spent, before
  any strike lands.
- A mine carries its numbers as laid: its own on the foe it lands on and its area's on every
  other foe its keywords reach there, each through its spender's modifiers when it was laid
  with no foe in hand, then each foe's own as it lands.
- Strikes are separate blows; each rolls and carries the keywords. Heat is paid once a spend.
  A split weapon (the Skua's) rolls once for the two strikes each of its strikes becomes, and
  each takes half the roll, rounded down and never below one (a roll of nothing shares
  nothing).
- A raised ceiling or floor (the Muzzle Velocity Booster, the Tactical Databank) moves a
  rolled range by its value before the roll, never past the top; a flat weapon gains
  nothing.
- **The die shows the number** one blow will deal after every modifier; a debuff shows none,
  and a gun whose blow is nothing here shows 0. Dragged over a foe it may strike,
  it shows that foe's number: its missing hull, conditions on it, its Flak, its armour off. A
  Shocked foe's doubling is not folded in (it shows on the foe's chip). Its heat is
  the heat the spend will add, every modifier in (a Scorched machine's weapons run hotter).
- **Tapping a die** opens its readout, the entry showing alone, its marks as text, each line headed
  by the mark on the die it says (the big glyph, a keyword's chip, the star, the self or ally chip,
  the lock, a corruption, a mark beside the heat): its place and name,
  what holds on it (on cooldown with its turns left, a foe's switch-off, corruption), its
  codex, then a line a mark: its number as the die prints it, its heat, its target, then its
  keywords (how it lands, Volatile, what it applies on hit, Rapid), its own rules and a
  written-out grant's line last, then its tags. A number the live sources moved off the
  component's own is coloured, green where the change is good for its unit and red where it
  is bad (more heat, a smaller blow), always relative to the unit and never the player, with
  its arrow on it, the way it moved: each number on its own, so a split weapon's smaller blow
  and its extra strike each say so. No source is listed. A tap on it again closes it, and it
  is one readout with the units' (below): a tap on another die or a unit moves it. A die's tap
  lands once the double-tap window (0.2 s) has passed with no second tap, the die lit from the
  touch until it does, so a double-tap only locks and leaves the readouts as they stand; a tap
  that lands as the enemy's turn replays, or under a codex, opens nothing. The whole die is in
  the codex (double-tap the machine). **The keywords list**, in the pause menu, gives every reach, keyword, rule and status the dice and chips print, and the keywords
  a foe's move carries (Every Machine, Countdown, Last Act and the rest), with its codex line. Wherever shown text names one of those terms (the holds, the readouts, the codex, the
  list itself), it reads bold in its colour with its icon before it, and a tap on it opens its
  entry beside the word, where its own terms open theirs; a tap anywhere else closes it. A term
  wears one colour on the die, on its chip and in text, its group's: heat's red-orange for
  fire, heat and what hits harder, the shield's blue for what protects or holds, the enemy's
  violet for what only a foe does, the red-red for harm (Exposed, a destroyed component), the
  hull's colour for a price in hull, and ink for a shape, a reach or a rule; never the HUD
  colour.
  A vent on a machine whose vents blast shows the blast beside it (its mark and the blow the
  heat it would take off makes), and read or dragged anywhere but over an ally, every foe the
  blast may land on wears a turning dashed ring with the number it would deal there.
- **Tapping a machine or a foe** opens its readout, the way a die's shows an entry, and
  tapping it again closes it; one readout is open at a time, a tap on another unit or a die
  moves it, a tap on nothing or ending the turn closes it, and a hold opens it too; a tap on an
  open readout, a term's aside, reaches nothing under it. It follows the fight
  while open, translucent over the arrows it draws, a machine's resting on its gauges. It
  shows its name;
  its gauges with their numbers (a machine's shield, hull and heat, and its magazine if it
  has one; a foe's HP), a maximum something moved off its own coloured with its arrow; its
  armour and cooling (a foe's armour and attack) as the codex's stats, the base with the change
  beside it ("Armour 2 (+1▲)"); every chip on it by its name and count, what it does a tap on its
  term away, and the round's warnings (an overheat, a wreck, an injury's risk); then a foe's intent
  under its chip as the field draws it, a line a mark: its move's name,
  its blow as it will land read against its own, the machine it is aimed at by name, when it
  lands, its riders and its text. The colours are the unit's, so a foe hitting harder is green
  and up. A suppressed foe shows no intent.
- **The codex** (double-tap a machine or a foe) is the unit between fights, never a combat
  effect: its numbers, each its chassis's or its kind's own with the change its loadout and
  the battle make in a bracket beside it, the change green up or red down with its arrow
  ("20 (+18▲)"); its passive;
  its active effects, what else it carries between fights (a module, a battle's reward, a
  status the battle keeps), each named with its source; then its die in one column, each
  component a row (its tile, its name, its type as its icon shows it, Weapon, Shield, Vent, or
  Equipment for a buff or a debuff, and its tags, then the readout's marks joined into three
  lines: its number, heat and target; its keywords; its own rules and its passive's), at the
  component's own numbers; a foe's moves the same way, at its own numbers, its last act
  last; then its lore and its quote.
- **Every gauge wears its scale**, on the field and in the readouts: a tick a point, every fifth
  long, the fives alone where the ones would stand closer than four design pixels (the tens past
  that); a tick inside the fill is cut in the ground's dark, past it drawn in the bar's colour.
- **The gauges forecast the round**: everything the rest of the round will do as it stands,
  played on a copy of the fight with every rule as it runs: the end of the player's turn (its
  burns and overheats), the enemy's turn with each foe's move as announced (a heal, a brace, a
  rally, a web's burst, a death before it acts, the last act it sets off, a self-destruct) and
  the round's end. The die in hand counts only over somewhere it may be spent, as it would be
  spent there. A foe whose machine falls before it acts strikes the next machine in line: its
  arrow stays on its pick, and a second, dashed, goes to the machine its blow lands on.
  Nothing a roll decides
  is promised: a rolled blow counts its lowest roll, and a stun Numbed may shrug off, the entry
  an injury lands on and a strike at a random foe among several are left out (a lone foe takes
  it). The reinforcements are the next round's. A foe's gauge shows the HP the round will
  leave it, a heal hatched as a machine's gain is, and a foe the round kills wears the
  destroyed chip, its intent kept. Every status the round will land, on a machine or a foe,
  wears a preview chip: the status's own glyph and colour, pulsing in opacity on a dashed
  edge, with the stacks it gains, beside the destroyed chip when one is its cause; every
  warning (the overheat, an injury, the destroyed chip itself) pulses the same way, a
  prediction like any other. A Lure in hand shows its turn before it is spent: the foes it
  would turn draw dashed arrows to its machine, those on it already solid, and the gauges read
  the round as the lure would leave it (the Siphon's heat a blow included).
- Every number inside a fight is single digits or low tens: a blow 1 to 6, big guns to 10, one
  capstone 12; an amp a point a stack; foe HP 2 to 8 for rank and file at tier one and to 16 at
  tier three, 30 to 40 massive, 12
  to 24 heroes, the slate's bosses 48 at tier one (a core in parts 40, each part 8; under the
  80 to 100 first written for them, on the kill-time test's read, for Ryan's word), the four
  massive foes standing in as bosses 32 to 40; a foe's blow 2 to 8 at tier one (the rank and file's mostly 2 or 3)
  and to 10 at tier three, a massive
  foe's 7 or 8, a hero's 4 to 10, the slate's bosses' 6 to 10; machine hull 20 to 50 by size (the
  Kite's paper hull 12, its row's one-off), shield 6 to 16, field recharge 4 to 8 (about half
  the shield a map turn out of fights), base armour 0 to 2 by role, timed armour to 4 or 5; heat
  1 to 20 (1 to 30 if the pricing needs it), the maxima 10 to 14 (the Musk Ox's 8), a vent 3 to
  8 (the Entropy Condenser's 10 the capstone, paid in hull). The scales are magnitudes,
  not steps: any whole number may be used, and content sits a little past them where its
  loops moved it (the Zombie Knight's 8 HP, the promoted forms' 32 to 48, a hero's finisher, a
  multiple of its blow, to 16). A move is a count of hexes, 1 to 6 (the machines' 2 to 5).
  The content's numbers are the stock pass's fills as its loops moved them
  (`docs/measurements.md`; set by `tools/stock_fills.py`), the four Kestrel machines of 23
  October by hand at the same scale; placeholders until play.

### Player keywords
- **Spread N** (id `cleave`): also hits the foes beside the target in its rank, each taking N
  where the target takes the roll (a blow, above).
- **Penetrate N**: also hits the other rank of the target's column, which takes N.
- **Splash N**: the plus round the target, Spread and Penetrate at one number; the two at one
  number are written Splash. A weapon's area keyword carries its number; a debuff's carries
  none, its effects reaching those foes and its blow nothing.
- **Breach**: the blow ignores the foe's armour (foes carry no shield), the same word as the
  foes' rider below. The Overclocked Railgun carries it.
- **Burn** (with a number): each foe hit gains that many stacks of Burning (Burn 3: three
  stacks).
- **Cryo** (with a number): every foe the entry reaches gains that many stacks of Cryo. Any
  machine's hit with a weapon on a foe carrying Cryo spends every stack and cools the hitter 2
  a stack, after the spend's own heat lands; equipment spends none.
- **Suppress**: each foe hit is Suppressed unless its Numbed resists; one already suppressed for
  that action gains nothing more, Numbed included.
- **Shock**: every foe the spend reaches and leaves standing is Shocked after the blow.
- **Chain N** (a weapon's): the blow also lands N on every other Shocked foe on the field,
  each arc a blow of the spend that no strike is aimed at, so its Shock stands, the riders land
  and an arc adds no heat; then one other foe at random, neither the target nor already
  Shocked, is Shocked. Its footprint, like an area's, is read from the strike's own foe: an arc
  spreads nowhere, a foe an area reaches never arcs, and a foe both beside the target and
  Shocked takes one blow, the area's.
- **Lure**: every foe reached and left standing turns on the spender for the round. The Whip
  Scorpion's Siphon reaches every foe in the fight, and every blow a foe lands on it that
  round adds 2 heat to it (Siphoning), in the enemy's turn, after the overheat.
- **Expose** (the Needletail's Fovea Designator, the Swallowtail's Spotting Flare): every foe reached
  and left standing is Exposed through the next round; a second Expose refreshes it, never
  adds.
- **Disrupt**: every foe reached and left standing takes the next move in its list that its
  conditions allow, keeping its pick while the machine stands and is in the fight; a new one
  otherwise, and when the move it leaves aimed at no one machine (a brace, a blow at every
  machine), since the pick it carried was never shown. Disrupt resolves before Lure.
- **Purge** (id `dispel`, the foes' word too; Aphelion's Null Field Emitter): every foe the
  entry reaches loses every buff it carries but Numbed and Guarded (Armoured, Kindled, Getting
  Back Up, Primed, Barrier, Ward, Regenerating), after the blow and with the riders, a debuff's
  included, so a foe the blow kills stays down and a Barrier the blow pops is gone already; a
  laid shot purges the foe it lands on.
- **Rapid** (any component): the die rerolls free onto any other entry, a copy of the same
  component included, and the machine acts again, so copies of one Rapid component chain.
  Rapid carries a cooldown of one (the entry is dark for the rest of the round) unless the
  component prints its own; one that prints none pays heat, hull or shield every spend (the
  Cryo Flinger, 1 heat). A Rapid component always carries a limiter, a cooldown, heat or a
  cost; a piece locked on a stepping die (the Cassowary's Spin-Up) needs none: its spin
  is a true roll over every chamber, so it lands on itself one time in six, to be spent again,
  a fifth of a spin more a spend on average, and every other way back to it in a round runs
  through the other chambers' switch-offs or the team's rerolls.
  A Rapid vent is never below tier three (the one is the Musk Ox's quick reload, locked on a
  tier three, which cools nothing), and a Rapid shield never below tier two (the Laminar
  Deflector's two).
- **Cooldown** (a printed property on specific pieces, or one a passive grants every weapon
  and equipment its machine aims at a foe, the Kite's two; the longer stands): once spent, the entry is dark for
  that many rounds, this one included, shown on the die with the turns left; the die may
  land on it, and a dark entry does nothing. No cleanse lifts it.
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
  drop it; the second targets light; tap one to spend it; a tap or a hold on the die reads it; drag the die
  again to move it or set it back. A tap on the ground sets it back too, the die flying home,
  once no readout is open: the first such tap closes the open readout.
- **Flak** (with a number, Wainwright & Sutler's on-hit): each foe hit gains that many stacks
  of Flak after the blow (Flak 2: two stacks), so the blow that lays it never
  feeds on it and a later strike of the same spend does.
- **Costs** are printed on the entry beside its heat, never a keyword and never a chip: a
  **hull cost** (Volatile 3: spending it costs its owner 3 hull, past shield and armour,
  before it acts, and a machine it leaves at nothing is wrecked; the Umbra Inducer, the
  Oblation Mantle and the Entropy Condenser cost 3) and a **shield cost** (3 shield, taken
  first from the shield as it stands, overshield included). An entry whose shield cost the
  shield cannot pay cannot be played: the die shows the cost struck through, it has nowhere
  to land, and END TURN pulses as if the die were spent. It is the first entry with a
  condition on its play, and the pattern for any to come.
- **Cleanse** (on a shield or a vent, today): the machine it lands on loses Burning, Scorched,
  Silenced, a foe's Disabled and Corrupted (never a cooldown).
- **Overshield** (shields): may pass the maximum; the excess fades at the round's end, and as
  the fight ends, mid-turn or by a withdrawal, so it never leaves the fight.

Component properties, printed on the entry rather than learned as keywords (the die marks
them with a star): **Vents all** fires the whole heat gauge into the shot, adding its
bonus per step of heat fired, the step printed on the entry (the Afterburner Cannon: +1 per 2),
then its own heat lands. **Overcharged a kill** (the Soulcutter Talons'
rule, no word of its own): each foe it kills gives its owner a stack of Overcharged. **Missing HP** adds its bonus for every
step of HP the foe struck is missing, each foe its own, on each blow after the attacker's
modifiers (so a split weapon's two strikes each add it), both numbers on the entry (the
Coriolis Accelerator: +1 per 5). **Gated**: a keyword printed with a condition on the foe (a Suppress on a foe carrying
Flak, or on a foe carrying two Burning or more) lands only on a foe that meets it, judged as the
die is spent and before the spend's own riders, so a spend never opens its own gate; the die
held over a foe strikes the chip where it will not land; a mine laid from it is judged as it
lands. Suppress alone carries a gate. **Consumes**: the first blow on each foe it strikes eats every stack of the status
the entry names on that foe and deals it a point more a stack eaten, after the attacker's
modifiers and before the foe's own, so an area consumer spikes only the foes carrying the status; the die over the foe
showing the number with the stacks in; one blow on each foe (no strikes past one); a mine laid
from it eats each foe's own as it lands. The Suppression Battery's Suppress is
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
before the drone lands) the drone is Rapid, and otherwise it gives the foe Exposed, never refreshing it. **The Immelmann Booster** (the Giant Petrel's, Rapid):
spent on itself, the team gains a reroll (Rallied); spent on an ally whose die is spent, which
it may land on only while the team holds the price, three rerolls are paid, banked or fresh,
and the ally's die rolls again by Rapid's path, never onto the entry it showed, and it acts
again, while the Booster's own Rapid gives the Petrel its turn back. **The Spindrift Salvo** (the
Giant Petrel's): a spend of it that kills gives the team two rerolls this round, once however
many fell, banked if unspent. **The Reheat Uplink** (the Giant Petrel's, allies only): the ally
gains Overcharged 2 and its die rolls again, never onto the entry showing; a spent die rolls
nothing. **Regenerates** (the Storm Petrel's St. Elmo's Regenerator, a lure): spent on a
foe, its own machine gains Regenerating, the shield it prints at the start of each of the
rounds it prints after this one. **Spillover** (the Wild
Boar's Juggernaut Drive, on every weapon it fires): damage past the kill of a front-rank foe
carries into the foe behind it as plain damage, the killing strike's excess and every later
strike of the spend whole, aimed at nobody, so a Shock behind neither doubles it nor is
spent; the engine runs it as a keyword the passive grants written out, so each of the Boar's
weapons wears the star, the die's readout reading the passive's line, and no keyword chip.

### Buffs, debuffs and resistance
A **store** is a capped resource a machine fills and spends (the Muster, the rage, the
hopper, the Cassowary's shot count; the Musk Ox's magazine works the same way), its own kind
and never a buff: each shows as a bar under the heat, boxes or a smooth fill in segments by how
it fills, and no Silence or Purge touches it, its filling or its use. An active effect a store,
a form or a passive grants is a buff and shows as one: no Silence touches it, and a Purge puts
it to sleep until the start of the player's turn, after the turn's start resolves (the cooling,
the roll and the round-start passives), and before the foes draw, since its source grants it
again; asleep it takes part in nothing, its clocks running, and its chip shows half lit on a
dashed edge. A form's price keeps biting while it sleeps: the Armadillo's seal sleeps its
armour, and its cooling stays stopped. No store grants an active effect yet. The hopper has no
cap yet, so it shows as a chip.

On a machine:
- **Overcharged** (buff): +1 damage a stack, so the count is the bonus. At the end of each
  round it halves, rounded down, whatever granted it, until it is gone; a buff component
  grants it stacks and no rounds. On the Ammit nothing of it fades: its Quintessence Tap
  keeps every stack for the battle, whatever granted it.
- **Armoured** (buff, on either side): armour +1 a stack, every stack at once, whatever
  granted it, so the count is the armour: a machine's until the round's end, a foe's (from
  its brace) until its next action.
- **Primed** (buff, on either side): each blow leaves a Burning stack per Primed stack on its
  target, a spray's on each strike's own foe; a blow that kills leaves nothing to burn. A foe's,
  from a stoker's priming, is spent by its next move, whatever it is, on Kindled's clock, and a
  machine's Ward turns its Burning away as it does a burn.
- **Phased** (buff): cannot act, take damage or be targeted until the
  round's end, so allies cannot vent or shield it, a foe's intent on it re-picks, and a blow or
  a special at every machine passes it by; it still cools by its cooling, and ticks and
  overheats land. Granted only to a unit that has not acted
  this round, whose die stands down as it is granted.
- **Swallowed** (debuff, from a foe's swallow): out of the fight as a Phased machine is (it
  cannot act, take damage or be targeted, a foe's intent on it re-picks, and a blow or a special
  at every machine passes it by; its cooling, ticks and overheats are its own) for the swallow's
  rounds, its die standing down as each round opens, or until its swallower falls, which lets
  it go at once: in the player's turn it acts that round. Nothing cleanses it.
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
- **Spun Up** (buff): the next weapon the machine spends deals +2 a stack and takes every
  stack; equipment leaves them standing; carried between turns until a weapon takes it.
- **Retaliate** (buff): a foe whose blow reaches this machine's bare hull is Shocked.
- **Regenerating** (buff, on either side): a foe's, from its own special, regrows its value in HP
  at each of its next three actions, after its Burning and Vitriol have ticked (a suppressed
  foe's included), so a foe its tick kills regrows nothing; each grant keeps its own clock. A
  machine's (the Storm Petrel's St. Elmo's Regenerator): 2 shield at the start of each of the
  next three rounds, up to its maximum; it stacks, each grant keeping its own end, and a die
  entry bought it, so an enemy's purge takes it.
- **Barrier** (buff): the next blow a foe lands on this machine deals no damage, so it never
  injures; its riders land, and a blow of nothing leaves it standing. One at a time; until
  the round's end. Never granted to every ally at once. The Blast Door grants it, self or ally.
  A foe's, from its own special: the next blow of a weapon the team lands on it deals no damage,
  the blow's riders landing and a Shock it carried spent; equipment pops nothing; until it pops
  or the end of the player's next turn.
- **Ward** (buff): no rider a foe lays lands on this machine this round, from a blow or from a
  move of its own (breach, burn, scorch, disable, corrupt, silence, purge), so its shield
  absorbs a breach like any blow; a blow's damage lands. Until the round's end. The Decoherence
  Veil grants it, self or ally. A foe's, from a special that wards every foe on the field: no mark
  the team lays lands on it but Suppressed (Burning, Flak, Cryo, Vitriol, Shocked, Exposed,
  Webbed, the Paradox, the Syrinx Drone), so a turned mark feeds no Paradox; the damage lands;
  until the end of the player's next turn.
- **Rage** (store, the Nemesis's): a stack each time it takes hull damage (a blow, a bite
  of its own, an overheat), up to 5, spent by its fists to roll again; lasts the skirmish,
  never decays, and nothing cleanses it. It shows as five boxes under the heat, one lit a
  stack.
- **Hopper** (store, the Honey Badger's): loads for a weapon that fires the hopper; lasts
  the skirmish, never decays, and nothing cleanses it.
- **Sealed** (buff, the Armadillo's form): a shield it spends on itself seals it: armour +3,
  its own cooling stopped, 3 heat more at the end of each turn before the overheat; a vent or
  a weapon opens it; a shield on an ally and equipment leave the form as it is. An ally's
  vent still cools it. One seal, however many shields.
- **Burning** (debuff, from a foe's burn; a foe's Burning below is the same word on the
  other body): +1 heat a stack at the end of the player's turn, before the overheat, then a
  stack fades, so a vent makes room for it or a cleanse takes it off. Cleansable.
- **Scorched** (debuff, from a foe's scorch): every weapon and equipment the machine aims at a
  foe runs 1 hotter a stack, until the end of the player's turn, when every stack goes, so it never piles up.
  Cleansable.
- **Disabled** (debuff): the entry comes up blank through the machine's next turn.
- **Corrupted** (debuff): each spend of the entry bites its owner 3 a stack, shield first,
  no armour off it; lasts the skirmish.
- **Silenced** (debuff, a foe's silence): its components' keywords are muted through its next
  round, printed and granted alike (a Rapid entry acts once, a Spread lands one blow, a
  Suppress suppresses nothing, its own Cleanse is a plain shield), then wake; its buffs count
  and its stores fill and spend as ever. Cleansable, an ally's Cleanse the way; a Ward turns
  the silence away. A foe's purge takes every buff a die face bought, every
  stack, for good; what a store, a form or a passive grants goes for the rest of the enemy's
  turn and comes back at the start of the player's turn after its start resolves; the stores
  stay, and the Ammit's kept Overcharged is its passive's own and stays; a Ward turns it away
  too. A die face bought it when a buff component's spend or a braces rule granted it.
- **Hot Streak** (the Kite's, its passive's price): its shots run 1 hotter a stack this fight,
  a stack for each attack that killed; no cleanse, silence or purge lifts it.

On a foe:
- **Burning** (debuff): 1 damage a stack at the start of its action, past armour, then a
  stack fades. It never stops healing.
- **Suppressed** (debuff): it loses its next action: this round's, or the next round's when
  it has already acted this turn. It never stacks and never carries: a second suppress on a
  foe already suppressed, a Paradox's included, does nothing and numbs it no further.
- **Shocked** (debuff): when a weapon's strike aimed at it lands, the blow deals double and the
  shock is spent (a vent's blast and a mine's shot on its arrival too); a blow that only reaches
  it (an area's, a Chain's arc, a spill) neither doubles nor spends it, and equipment leaves it
  standing; it never stacks.
- **Exposed** (debuff): it stands in Direct reach of every machine as if its
  column's front were empty, and its armour counts for nothing, its own and any Armoured.
  Through the next round; refreshed, never added.
- **Syrinx Drone** (debuff, the name of the Lammergeier's piece that leaves it): the next weapon to kill it, any
  machine's, leaves its shot in the slot it empties, a mine; one mine a drone; it lasts the
  skirmish, and a death by a tick leaves nothing.
- **Paradox** (debuff, while the Baboon fights): a stack each time the foe gains any other
  debuff, once a spend per debuff however many strikes or stacks; at three it is Suppressed
  (Numbed may resist, and a foe already suppressed gains nothing) and the Paradox clears
  either way. It never decays. The Suppressed a Paradox causes adds none; a Suppress
  keyword's does.
- **Vitriol** (debuff): at its action it loses 10% of its current HP a stack, past armour,
  after Burning on what it leaves, the whole share rounded down and never the last hit point,
  then a stack fades; it never finishes a foe. The funnel-web's Ambush lays it, a stack per
  weapon hit, as its text says; a web or a lure lays none.
- **Webbed** (debuff): at the end of its action, skipped or not, the web bursts: it is
  Suppressed (its next action, since it has acted; a countdown it gathers is held a round),
  and so is the next foe to act beside it in its rank, its right-hand neighbour, which loses
  this round's action, or with none standing there its left-hand one, which has acted and
  loses its next (Numbed may resist, each for itself; a foe already suppressed gains nothing,
  as from any second suppress; each half feeds the Paradox as the Suppress keyword's does).
  Killed first, or gone by the end of its action, it takes its web with it. Its chip points at
  the neighbour the burst catches.
- **Cryo** (debuff): a weapon's hit on it spends every stack and cools the hitter 2 a stack;
  equipment spends none. It never fades on its own.
- **Flak** (debuff): every blow of a weapon it takes deals a point more a stack, before its
  multiplies and its armour (a Shocked foe takes a strike aimed at it plus Flak, doubled); a
  debuff's blow stays nothing. The stacks halve at the end of each round, rounded down.
- **Kindled** (buff, Rally): lands on every other foe on the field the moment the rally does,
  and its next move hits harder by the rally's value, an add before the move's factor as
  every add is. That move spends it, whatever it is: a blow lands it, a special gains nothing
  from it, a Suppress that takes the move takes it too, and a countdown still gathering
  carries it to the blow it lands. A foe acting after the rallier spends it this turn; one
  that has acted carries it to its next move; each rally's grant adds. An intent counts the
  rallies on their way: a blow this round those of the ralliers acting before it, a
  countdown's blow every rally this round, each from a rallier alive, not Suppressed and not
  about to burn to death, so it drops the moment the rallier is killed, Suppressed or
  Disrupted. The foe wears the coming Kindled as a preview chip on a dashed edge, its opacity
  pulsing on the gauges' clock, until it lands; a foe whose move shows no blow wears none.
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
  Armoured adds to it (a brace: a buff, the Breaching Plow, the Siphon) until the
  round's end, the Armadillo's seal until a vent or a weapon opens it.
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
- **The Riot Field Generator** (the Storm Petrel's passive): its weapons' heat comes off its
  shield as they are spent, every point a spend adds (a Scorched machine's extra included)
  taken from the shield as it stands, overshield included, and only what the shield cannot
  pay reaching the gauge; equipment heats the gauge as ever. After the weapon's strikes, its
  target takes a blow of what the shield paid (the zap): plain, no keyword and no Shock read,
  through what the foe takes and its armour, and lost if the strikes killed it. And while its
  shield stands, every blow on it loses 1, a damage-taken effect read on the shield the blow
  meets. The die shows the shield a weapon will take in its heat slot's place, behind the
  shield's mark ("-3"), with the heat past it beside, and over a foe the blow joined to its
  zap ("3+2"), each with the foe's armour off.
- **Ammo** (the Musk Ox's Desublimation Forge): its weapons spend ammo instead
  of heating it, 1 for every 2 heat a gun's own spend would make, rounded up, at least 1, the
  price printed on the die where the gun's heat would be; its debuffs, buffs and shields and
  the foes' heat land on its heat bar as on any machine's, Scorched's extra included. The
  magazine is a bar under the heat bar, a notch an ammo, never a status, so no Silence or Purge
  reaches it; it holds 10, opens each fight at 3 and gains 1 at the start of every round after
  the first; a vent it spends on itself adds 3, a shield 2; a gun it cannot pay for cannot be
  spent (the die says DRY). Its Shrapnel Recuperator returns 1 for every foe its blows reach;
  its Unrestricted Expenditure fires every ammo in the magazine as a strike, each at a random
  live foe with Splash, the magazine its price and no heat; its quick reload,
  Rapid, adds 2 for 3 heat, and the Forge counts it as no vent.
- A shield, a vent or a buff that prints heat (the quick reload) adds it to its spender as it
  is spent.
- Foes heat machines only through two debuffs, never outright: Burning, the harsher, adds
  its heat at the end of the player's turn before the overheat, so a vent makes room for it
  or a cleanse takes it off; Scorched, the softer, heats only the weapons and equipment the
  machine aims at a foe in the turn that follows, so a shield, a vent, a buff or a cool weapon plays
  round it. A foe's burn leaves Burning and its scorch
  leaves Scorched, a stack a blow; the Drake's Stoke sets one machine burning, picked as its
  target is (at random since 24 October: no foe but the Black Mage carries the heat aim), and
  the Magma Elemental's Eruption, the Black Mage's Fira and the Summoner's Pyroclasm scorch every
  machine.

### Injury
- A foe's blow that puts a quarter of the machine's maximum hull or more past armour into its
  hull (a breach's whole blow included) rolls the machine's die: the entry it lands on is
  destroyed, a blank shrugs it off. A shield absorbs its share first and what reaches the hull counts; a
  Barrier's blow never does. Bites and overheats never injure.
- **Destroyed**: blank; its passive keeps its stat bonuses and loses its abilities. The Honey
  Badger's components are never destroyed, so an injury passes it by.

### Foes
- A foe has HP (a foe's word; a machine has hull), a base attack, a rank it holds, a size,
  flat armour (every boss 1 or 2, the promoted forms 2) and perhaps an aim. Its damage
  never rolls.
- **Its move**: from the moves whose conditions hold, weighted by each move's own weight (attacks mostly 2, specials 1, the Bomb's Self-Destruct 3), never
  the same special twice running while anything else is open. A move without a condition
  fires on its weight; the conditions read the foe's own side or what its move needs: below
  half, hurt, a foe behind it, another foe on the field, one
  of its own hurt, a machine carrying a buff, one of its own not readied. A move may
  carry a countdown: it gathers, landing that many rounds after it is announced, and nothing
  hits meanwhile; its pick holds while the machine stands; Suppress holds it a round, Disrupt
  breaks it off, and the foe stays on the field. A move may name a follow-up: once it lands, the
  move it names is its foe's next round's intent (the Matador's Red Capote, then Andalucia); a
  follow-up comes only that way, never by the roll, and a Suppress on the first move, or a
  Disrupt that turns it, means it never comes. A borrowed swing with nothing taken is no
  follow-up, and the roll decides. A swallow is never drawn while fewer than two machines stand
  in the fight.
- **Its target**, drawn as the round opens: at random, unless the foe or its move carries an
  aim, as its threat calls for: exposed (weighted by the hull its blows would reach
  plus half the shield they would break), heat (the hottest machine), armed (a machine
  showing an intact weapon or debuff, the exposed when none does), focus (its rank shares one pick),
  buffed (the machine carrying the most stacks of buffs, the exposed when none does). The
  foes pick in the order they strike and never over-commit: a machine the blows already picked
  would wreck through its shield and armour is passed over while another stands (a blow at
  every machine counts on each; a special, a suppressed foe and a countdown still gathering
  count nothing). The pick is a commitment, smart as it is made and never after (Slice and
  Dice's model, Ryan, 26 October): during the player's turn it moves only by a Lure, by the
  machine leaving the fight (Phased or Swallowed), or by a Disrupt whose foe finds its machine
  gone or out of the fight; a foe whose machine has fallen or is out of the fight when it acts
  strikes the next machine in line, left to right, that stands in the fight, whatever its aim,
  so the player can tell the pick it
  will make, and the round preview shows it. The preview never moves a pick: a foe aimed at a machine the round will wreck stays
  aimed at it, and the preview shows where its blow lands after. A special that acts on nobody
  in particular (a brace, a regrow, a rally, a scorch all) keeps its pick and shows no arrow:
  it is aimed at no machine.
- **A blow** is its base attack, plus its Kindled and its swarm for each other live foe of its
  type, times the move's factor: the adds, then the multiplies, the one damage formula on both
  sides; strikes are separate blows. Riders (a Ward turns away all but the last
  two): breach (the blow ignores the shield and the armour), scorch (stacks of Scorched), burn (stacks of
  Burning), disable (the entry the machine shows), corrupt (Corrupted stacks on it), steal (the
  entry the machine shows switched off through its next turn, as a disable, and taken: its foe
  holds it until its borrowed swing, whose number is what it took, a weapon's printed blow, a
  rolled one at its middle, and anything that was no weapon a fake, for 1),
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
  rally (Kindled at its value on every other foe on the field, at once), drain rerolls, burn (stacks of Burning on one machine), scorch all (stacks of
  Scorched on every machine), corrupt all (Corrupted stacks on the entry every machine shows),
  disable, silence (Silenced), purge (every buff a die face bought gone, a store's, a form's
  or a passive's grant until the start of the player's turn; never a last act's), cleanse
  (every mark the team laid, Burning, Flak, Cryo, Vitriol, Shocked, Exposed, Webbed, the Paradox
  and the Drone, off the most-marked of its own, itself included, the first in strike order on
  a tie; never Numbed, never Suppressed; cast where one of its own carries a mark), barrier (a
  Barrier on itself), regenerate (Regenerating at its value on itself), ward all (a Ward on
  every foe on the field, itself included), prime (Primed at its value on every other foe on the
  field, at once), swallow (its machine Swallowed for its rounds, never the last machine in the
  fight), each on its target, no blow; a silence and a purge are specials, never riders. A Ward turns away
  every one of them that lands on its machine, a scorch all's and a corrupt all's share
  included, and a scorch all or a corrupt all passes a machine out of the fight by. No foe in
  content carries a silence, a purge or a ward all yet.
- **A last act**: a foe may land a blow the moment it falls (a death blow, with its own
  riders, every machine included), before anything else and even when it was the last foe,
  since damage sticks for the battle.
- **A foe in parts**: a core and the parts of its pack that stand with it. A guard keeps the
  core from taking any damage while all its parts stand, or while any does (Guarded); a part
  that falls may grow back after so many rounds while the core stands; a core that falls takes
  its parts with it.
- **The enemy's turn**: front rank left to right, then the back; on screen each foe is lit from
  just before its move lands until the next acts. At its action each foe's
  statuses tick (Burning first, which may kill it; then decaying stacks drop, Numbed
  included; Vitriol after Burning, on what it leaves); a suppressed foe does nothing; a web
  on it bursts at the end of its action, skipped or not. A foe with no machine to strike (every one fallen or out of the fight) loses its blow
  alone: its countdown gathers, a special on its own side acts, and the turn goes on to the foes
  after it.
- **A split** (the Gel): a dead Gel splits into two Half-Gels at once (one deep), standing as a
  pair in the slot it fell from: a twin slot, one slot to the formation, so its hole never
  opens (the Gel is a wall, not an attacker, and its blow carries no breach). An area blow
  that reaches the slot (Spread, Penetrate, Splash, a mine's) reaches both halves, aimed at one
  of them or beside, each half taking the number of the shape it stands in (the aimed half's
  twin the row's, or the column's when the entry reaches no row); a single-target blow, a Spillover included, the one it is spent on. The slot is
  full while either stands: no mine is laid in it, and a Syrinx Drone on a half that falls
  while its twin stands leaves none. The left half acts first; a web on it catches its twin; a
  Swap moves the pair together and never swaps a half with its twin. When one falls the other
  keeps the slot alone, still drawn on its own half of it, and with both gone it is a plain slot: the pair is only ever its
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
Open at any point of the player's turn, but in the boss's fight, which ends in the boss unit's
fall, escort and all, or the team's, and in the quick campaign, which has none. Withdrawing ends the turn, so heat over the maximum
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
  this machine's that killed, arcs, spills and a vent's blast included). No trigger feeds itself.
- A passive may double a weapon's printed number before its buffs, on every blow, what the
  entry prints from its firer included (an area's number, heat fired, hopper loads), the buffs
  added once after it and the struck foe's own reads (its missing HP, the stacks consumed on
  it) after those, undoubled (the Kite's), and may grant a cooldown to every weapon and equipment its machine
  aims at a foe. It may split every weapon and equipment aimed at a foe instead (the Skua's):
  each strikes twice as often, each
  roll, what the entry prints included, divided between the two strikes, rounded down and
  never below one, and
  every buff and the foe's conditions counting on each strike, its armour too; the die shows
  a strike's share with the strikes beside it ("1 ×2"). A debuff has no number to halve and
  fires twice all the same, its riders landing on each strike (a Web, a Lure, a Disrupt, a
  Shock, an Expose and a Swap still land once a spend).
- Conditions: the weapon is rolled; the reach is direct or
  indirect; the target carries a debuff; an ally is in the fight; the component carries a tag;
  the target shows no intent on this machine (the funnel-web's: a foe shows intent as its
  arrow is drawn, on its pick or on every machine, a gathering countdown included, and none
  when aimed at another machine, Suppressed, or on a special that acts on nobody in
  particular; read at the spend, before the spend's own riders, each foe reached judged
  alone); the rank the spend is aimed at (the Cottonmouth's grants, judged on the aim), and on
  an attack's own effects the rank of each foe struck with the spend's reach beside it (the Ram
  Frame's Direct blows at the front rank, the Artillery Rangefinder's Indirect blows at the
  back, a point each); the striker carries a status (the Prairie Dog's fight
  half: its damage-taken effect reads the foe whose blow it is taking, so a foe carrying Flak
  hits it 1 lighter, whoever laid the Flak).
- A passive may lay a status on each foe its blows hit, a stack per strike, the foe judged by
  the passive's condition alone; every strike that reaches it alive lays it, a blow of nothing
  included, unless the passive's text asks for a weapon's hit (the funnel-web's Vitriol).
- A passive may change an entry's reach, grant it a keyword or move its range; the entry as
  changed is what is spent, shown and weighed, while the die keeps the real one. A numbered
  keyword's grant says its number, and on an entry already carrying the keyword the grant's
  number replaces the entry's own (the drum forces the weapon into its shape, and adds only the
  keywords and effects it lacks). The
  Cottonmouth's replaces the shot of every weapon and equipment it aims at a foe whole, first,
  under every other change (Indirect,
  a flat 4, heat 3, one blow, Ballistic, the entry's keywords, rules and tags kept),
  Penetrate 2 when aimed at the back rank and Spread 2 at the front, shown on the die over the foe
  it is dragged to. The Whip Scorpion's makes every vent it spends on itself blast a random
  live foe, back rank included, for the heat it took off: a weapon's hit, flat and Indirect,
  that does everything a weapon's hit does (the machine's adds, the foe's Flak, a Shock spent,
  its Cryo cashed for the machine's cooling, its armour, a Primed machine's Burning, a drone's
  mine, the machine's kill trigger), inside the vent's spend, whose heat is paid once (a vent on an ally blasts nothing,
  an ally's vent on it blasts nothing, a vent with no heat to take off blasts nothing).

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
- **Ground**: open (plain or road), rough, ruins, water, and walls, a wall named by what it is
  (crags, mesas, towers or cliffs) with one rule under every name. Six map shapes, one a
  battle, each with its own water, walls, decorative ground and relief: River Crossing (a
  river across, two or three hexes thick, with one or two fords three or four hexes wide in
  all, a crag on a bank at most), Fjord (water down the field, two or three wide, a
  lane two wide at least either side), Badlands (mesas in groups and two or three ponds, the
  paths winding between), Open Steppe (a lone crag and a pond at most), Ruined City (one or
  two bands of towers across, each with streets through it three or four hexes wide in all,
  one to four of them), Gorge (one or two cliff walls down the field, lanes two wide at
  least). A ford or a street is one to three hexes wide, with a hex of river or towers
  between two. A battle that names no shape draws one by its seed, never by its domain. Every
  map guarantees the
  horde a crossing three hexes wide or more through its walls; the rift's mouth (rows 0 to 3)
  and the two rows before the gate hold no water and no wall. Height is landscape and a look
  alone; no rule reads it: the field is level but for the badlands' mesas on their shoulders and the
  steppe's one rise, at most two steps and never a lone raised hex, and the scenery past the
  edges rises to three.
- **Moving**: a machine's move is a count of hexes, each step one hex, and a chassis has one
  way of moving (tracked, walker, wheeled, hover or flyer), which is its look and its footfall
  and never a rule of its own. Open ground (plain, road), rough and ruins are ground to
  everyone. Water: a ground machine wades it, a water hex costing two of its move, and it can
  always enter one with whatever move it has left; a hovercraft and a flyer cross it at one.
  Walls stop all but a flyer. Nobody stops on another unit's hex. A flyer and a grounded unit
  pass each other and meet only in a fight: a flyer flies over machines and packs, and they
  pass under it and under a winged pack. A grounded machine never passes another grounded
  machine or a grounded pack: each move lands at once, so the next is planned from where it
  ended and the player sequences them.
- **Setup**: up to four machines on the row before the gate; the boss one row below the rift,
  sealed (below); and on the field the compositions the tier and the ramp put there: the
  ramp's count of formations (one; two from Convergence 3; three from 8) spread across the
  width three to five rows below the rift, and its count of patrols (two; one from 8) on the
  flanks a little lower, each the tier's compositions in turn, the lead's and the guest's in
  turn with the lead's first, every member's strength at the ramp's density (×1 at
  Convergence 0 to ×1.5 at 12, rounded, never below one).
- **A turn**: the map shows every pack's coming walk, read from where the machines' plans end,
  and every pack's ring. Each machine has one action (the Dingo two): one move, in one go, then
  it may fight; a fight ends the action however it ends. A selected machine lights the hexes
  its move reaches, and in the enemy's violet the hexes past them within its attack range:
  where it could attack from. A move is planned: its route shows from where the machine stands,
  and the next move or order reads from the route's end. UNDO takes back the last move or
  order, whoever made it, in the order they were made, back to the turn's start or the last
  fight. A caught machine's fight comes first. ENGAGE and END TURN play every planned move
  first (the boss's fight aside, below); then the fight opens, or the turn ends: packs walk and
  strike; machines that did not fight regain shield at their field rate; Rift Pressure rises
  one. Once every machine has fought, is ordered, is caught, or can neither move nor reach a
  pack where it stands, the button pulses.
- **The readout**: holding or tapping a machine, a pack, the boss, the gate or the ground shows
  it in the strip under the map, as the fight's holds read: a machine's shield and hull as
  gauges, its move and actions left, a chip for its damaged components; a pack's members (each foe
  type and its count), move, ring and what it is doing, and SEALED on the boss while its seal
  holds; the gate's integrity as its gauge; the ground by
  its name (a wall by what it is): who crosses it, who wades it and who cannot, and whether
  packs enter it. A refused order
  says what stopped it there too.
- **Orders**: a tap or drag onto a pack plans the machine's move to the farthest hex in attack
  range its move reaches (or leaves it, if in range) and orders it, one step for UNDO; a
  second tap on the pack takes the order back. ENGAGE opens one fight at a time: the first
  order's pack and every machine ordered onto it.
- **A fight** is at the target's hex. Every other pack whose ring covers that hex joins (no
  chaining); machines whose attack range (2) covers it may join. Afterwards each machine in
  it has used its action, wrecks leave, a pack keeps only its survivors, by member, and Rift
  Pressure does not tick: it ticks on the map alone.
- **Packs**: a pack is a composition on one hex: its members, each a foe type times a
  strength, in content order, the lead first, whose sprite and behaviour the pack wears; a hold
  lists them. A composition is a patrol (a few foes, one machine's fight), a formation (the
  body's), an elite (an elite leading its own) or a boss's escort. Every member unpacks into
  the fight, and the survivors come back by member. A pack walks at its slowest member's pace
  with the largest of its members' rings, winged only when every member is. They cross every land hex and wade water as a
  ground machine does, a water hex costing two of their move (entered with whatever is left),
  and never enter walls; a winged pack (the Cockatrice, the Ghost, the Bone Wyvern, the Bomb,
  the Drake, and their lines' recolours) crosses both as a flyer does and may stand there;
  moves 2 (fast 3, the Dire Wolf's line 4, massive 1); rings 1 (front rank), 3 (back rank), 2
  (massive), a hunter's 2 at least. A ring counts hexes as the crow flies, over anything
  between. They walk round grounded machines, through each other and under a flyer, never
  ending a walk on another unit's hex, so a flyer holds no ground and a pack holds none
  against the packs; the walk shown is the walk played. The
  enemy never attacks a machine on the map: pushers strike the gate, hunters catch.
- **Pushers** make for the wall; a pusher ending its walk beside any hex of the gate or the
  wall strikes the gate's bar for its strength times 10 divided by 3, at least 1 (the floor of
  ten is gone, so a stray pair chips less than a trio), every enemy turn. The gate is the look
  and the bar's name; the whole wall is the target, so no line plugs it.
- **Hunters** lock one machine when they appear (nearest, weakest, strongest, slowest or fastest; never
  the Prairie Dog), keep it while it stands, and walk to put it inside their ring; the machine a
  hunter comes for wears a tag by it, a plate a hunter with the hunter's picture and a target,
  and the board says HUNTED BY. A hunter with what it comes for in its ring at the start of the
  player's turn has caught it: that fight comes first, the caught machine cannot move first,
  others in range may join. A prey that any route reaches is the only machine its hunter
  catches, however near the others stand. A prey sealed off (no hex the hunter can walk to,
  round walls and grounded machines, through packs and under flyers, and stand on puts it
  inside its ring) is not safe: the hunter takes the machine that a walk this turn can put
  inside its ring and that stands nearest the prey, its caveat breaking a tie and never one
  that is never hunted; the tag moves to it and the pack's readout says whom it takes and why.
  With none in reach that turn it walks as near its prey as it gets.
- **The carry** (the Swallowtail's Muster Deck): the machines on the hexes beside
  it are lifted in place when it moves and travel as a ring round it, so they never block its
  way; it lands them as a block, each where it rode from the carrier, keeping their action, and
  their move if they have not moved. A stop where a rider would land on a hex it cannot stand on (off the field,
  a structure, ground it cannot take, another unit) is no move: the drawn route marks the stop
  and that hex (NO ROOM), and letting go there is refused. A caught machine does not ride. An
  undo of the carrier's move takes the riders back with it.
- **The boss** patrols within two hexes of the rift, a hex a turn whoever commands it. Its seal
  holds until the Rupture (below): while it does, the boss cannot be ordered onto and joins no
  fight, its ring inert, SEALED on its readout. After the Rupture it joins
  the fights its ring covers (2; a final's back-rank hero's 3) and can be attacked
  (a hero carries no move and no hunt of its own: it only ever commands the boss unit); its fight won wins the battle: the fight ends in victory
  only when no foe stands or waits, so its escort falls with it, and a team wrecked after the
  commander falls has lost the battle (Ryan, 27 October: the whole escort must die, else the
  smallest boss, a final's hero, gets cheaper still). A fight it is in, ordered onto
  it or joined by its ring, takes every machine, wherever it stands and whether or not it has
  fought this turn; nothing moves first (ENGAGE goes straight to the reveal) and nobody
  withdraws, so it ends the battle. The unit at the rift commands
  it: the lead domain's boss, a final's hero with its escort (one for each other column), or
  the finale's line; it stands while one of its commanders does and holds the rift whatever
  its escort. It stands at the battle's tier (the tiers as the quick campaign shows them, one
  to three: in the campaign tier two runs from Convergence 4 and tier three from 8, and the
  finale at 12 takes tier three's numbers): its commanders' HP ×1.25 at tier two and
  ×1.5 at tier three, their attack +1 and +2, and two more escort at tier two and four at tier
  three. An escort it does not name (a final's wildlife, the tier's more) is its domain's `escort`
  composition at the battle's tier when one is written (none is yet), its members at the
  ramp's density, else the foes of its domain's units at the tier, round robin in content
  order and never massive; a named escort is kept. The rank and file never scale in place: a tier's units are their own,
  each with its numbers and its name (a recolour: a base type in a new hue under a new name, with
  a twist). A domain's compositions are by tier, the battle's tier choosing them and a guest's by
  the same tier; a tier with none takes the highest under it.
- **Rift Pressure** fills at the ramp's timer (12 at Convergence 0, one less every 3, 8 at
  12; +1 each enemy turn, never inside a fight). When it fills it resets and peaks: the rift
  sends the next composition of its cycle (the tier's formations and patrols in turn, the
  lead's and the guest's in turn); every tear open before this peak sends the next patrol of
  the patrol cycle; the seam creeps two rows toward the gate (as far as the row before the
  wall); the ramp's count of tears (one; two from Convergence 8) open on the seam's row, each
  on a free land hex with no unit on it and no machine beside it, the farthest from the rift
  and the other tears, so the mouths spread across the width; and the interval shortens by the
  ramp's step (zero today, never below 2). A tear opens a peak before it first sends, so where
  the next flood comes from is known an interval ahead; tears stay open and never close. A
  spawn lands on the nearest free hex to its mouth with no machine beside it, so it and its
  walk are seen for a whole turn and nothing appears on top of a detachment. Packs never
  escalate in place.
- **The seam** is the flattening's edge: the row the rift's bleed reaches, five at the start,
  total on the rift's row and gone past the seam. It is the clock's picture: no rule reads the
  flattened hexes.
- **Menace** is a foe's weight: its heaviest blow plus a quarter of its HP, rounded up, an
  elite's doubled. The Rupture meter, Anathema and salvage count kills by it, so the rift's
  reinforcements pay a trickle and the formations and the elites pay the most.
- **The Rupture meter** fills by the menace of every foe killed, in any fight however it ended,
  tallied as each fight ends, toward the tier's Fractures (three at tier one, four at tier two,
  five at tier three). The thresholds are set from the field's menace at the start (the packs
  placed, the boss aside): the last at two thirds of it, the steps 1, 1.5, 2, 2.5 and 3, so
  later Fractures cost more and a battle that kills the field as it stood earns the Rupture
  with a third of the field left to leave. A Fracture pays out as a fight ends. At the Fractures
  the tier names (tier one's first; tier two's first and third; tier three's first, second and
  fourth) the next elite composition of the lead's domain not yet fought this battle emerges at
  the rift (a domain with none, the Peak today, sends none). The last Fracture is the Rupture:
  the boss's seal breaks. The stall guard breaks it too, when no pack but the boss's stands as
  a fight ends, so a team that cleared the field never waits on the clock. Rift Pressure keeps
  running after. A Fracture brings no prize (not built).
- **The battle ends** when the gate reaches zero, every machine is wrecked, or the boss unit
  falls (every commander of the unit at the rift, its fight won); a wipe after the commander's
  fall is a wipe.
- Not built: city defences (along the wall when they come), the Fracture's prize, rift tiles;
  the escort compositions have no content yet, so every boss brings the tier's units.

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
  2 salvage a point of menace killed, the boss's included; 100 Favour less 1 per gate
  point the city lost, never below 0; a research
  token of the lead domain and an offer from the host maker are owed (the token a choice of
  three blueprints of the domain's theme at the Convergence's tier; the offer a chassis, a
  component copy and a module from the maker's catalogue, one taken free; unpacking and offers
  not built).
- **Fell** (the gate reached 0): the city falls, the battle's salvage is lost, the rift stays
  open, as art: no front, and nothing reads its domain. **Wiped** (every machine wrecked): the horde strikes the gate for up to six phases;
  the city falls at zero or holds wounded, keeping the salvage; no Favour.
- **After a battle**: hull mends free; a destroyed hardpoint component is gone, a destroyed
  fixed one rebuilt; a wreck sits out the next turn unless rushed (100 Favour). Fitting and
  stripping are instant; the capital's gate repairs at 5 salvage a point.
- **Turn end**: each unfought open rift bleeds its city 50 (falling it at zero); each fallen
  city drains the capital 25; the Convergence rises 1; rifts open at standing cities that are
  not quiet, up to 2 + tier (tier = the Convergence ÷ 4, rounded down, so two rifts at first,
  three from Convergence 4 and four from 8, before the finale at 12). A rift keeps the tier it
  opened at, whatever the Convergence does after (the finale's is the Convergence's), so an old
  rift never hardens by waiting; the ramp a battle reads is the Convergence as it stands when
  the battle starts, the same for every open front, never shown and never reset.
- **Domains**: a rift rolls its lead domain (Meadow, Waste, Marsh, Peak; never a beaten one)
  and from tier 1 a guest, another domain not beaten, whose compositions alternate with the lead's on the field at the start and in
  the rift's cycle.
- **The party**: dealt as the run starts, one hero to each domain from its bench, the front
  jobs and the back as even as the benches allow (two and two), by the seed; no job changes
  after.
- **A rift's boss**: each battle brings one of its domain's bosses that its battles have not
  ended on this run, drawn by the seed; once every one has been, any of them. A domain's bosses
  are the slate's it has, its old massive stand-in last while it has fewer than three (the
  Meadow's, the Waste's and the Peak's three, the Marsh's two).
- **Anathema**: the menace of a domain's foes killed this run, every battle however it ended,
  is recorded by domain beside the count of its bosses beaten; the count still sets the final.
- **Finals and finale**: three bosses of one domain beaten set its final: every rift it leads
  at a standing city around the capital turns final at once, and every rift it leads after is
  one, fought
  against the domain's dealt hero in its rank with the domain's wildlife beside it; it is won
  when the hero's fight is won, the hero and its escort down, and a won final beats the domain: it leads and guests no new rift (a
  rift it already guests keeps it), and every rift it leads at a standing city around the
  capital closes at once, a free reprieve: that city opens no rift next turn, its gate stays as it stood (only a win
  restores one) and nothing is paid. The finale is due at Convergence 12,
  one sooner per fallen city; the capital, which holds no rift before then (a fallen city's horde
  drains its gate from the fallen city), opens the finale's and is then the only front. It is fought against the
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

## The quick campaign

A run of battles with no map and no cities, Slice and Dice's flow (`sim/quick_run.gd`; the
harness's Quick campaign). The campaign's rules hold where this part says nothing.

- **Start**: three different tier-one chassis, picked freely from every one the engine can
  field, in their stock. Four squad slots, the fourth filled by an offer's chassis. The party is
  dealt as in the campaign. The eight basics are free and without limit.
- **Battles**: twelve, a tier every four, then the finale. Each is fought against a lead domain
  drawn at random and, from tier two, a guest. Its fights before the boss are as many as the
  Rupture's Fractures at its tier (three, four, five), and one, two and three of them are
  elites: a formation first, then elites and formations in turn, the elites left over at the
  end. Then the boss with its formation and the tier's escort, at the tier's numbers, as the
  campaign's boss unit stands: one of the lead's bosses its battles have not ended on this run,
  or from tier two its final, its dealt hero leading the lead's formation, drawn as one more
  boss while that hero stands; once all are beaten, any of its bosses again. The finale's last
  fight is the party's line with the tier's escort, every domain's dealt hero promoted, a domain
  whose final was won leaving its column to a standing domain's boss, as in the campaign.
- **A formation** is one of the domain's formation compositions at the battle's tier, in
  turn, every member at the ramp's density (the battle's number as the Convergence); the
  lead's and the guest's take turns. **An elite**'s slot holds the lead's elite compositions in
  turn (a domain with none, the Peak today, the lead's formation).
- **A fight** takes the squad's machines still standing, their damage carried and their heat
  from zero. There is no withdrawal. A won fight gives each standing machine one field recharge
  before the next; a wipe ends the run.
- **The boss's fall**: the campaign's after-battle rule without the shop (hull mends; a
  destroyed hardpoint component is gone, a destroyed fixed one rebuilt). Then, each one of three
  and one taken: a loot pick for each fight before the boss (components and modules: a tier-one
  battle's of tier one; a tier-two's of tiers one and two, a tier three now and then; a
  tier-three's mostly tier two, tier three oftener); the boss's token, components of the
  battle's tier, its modules filling in where it has fewer than three (tier three has two); and
  an offer from a maker drawn from all five: a chassis of its own at or under the battle's tier
  that the roster lacks (bringing its stock), a component of the tier (else the highest under it
  the maker makes) and a module at or under it.
- **The hangar**, between battles only: up to four machines of the roster, in the order they
  deploy; any component from the stores on any hardpoint and any module in any slot, what comes
  off going back to the stores.
- The run saves after every change and resumes where it stood, a fight under way included.

## Content conventions

- Each content file's `_about` is the authority on its fields; `sim/content_db.gd` validates
  them in the tests, so bad content fails the build. Shown to the player: `codex`, `flavour`, a
  passive's `name` and `description`, a module's `text.description`, a foe action's `text`;
  everything under `design` is internal; shown text never says "face"; a draft the engine cannot
  run carries `"status": "planned"` and is kept, never shown or run.

## Known gaps between these rules and the code

- Jenny's foe-down lines are keyed by the retired families, so only the generic pool plays.
