# Riftgate: the rules

The game's rules as they stand, in the present tense. This file says **what** is true; the
design bible (`docs/design-bible.html`) says **why**. A rule that changes is edited here in
place, in the same commit as its bible row; there is no history in this file (git has it).
Every number is a placeholder. "(not built)" marks a decided rule the code does not run yet.
The content lives in `content/*.json` (each file's `_about` explains its fields) and its
words in `docs/vocabulary.md`.

## The game

A campaign is one roguelike run of battles at five cities. A battle is the defence of a city's
wall: a hex field wide along the wall and shallow from the rift to it, the horde coming at the
wall, won by killing the boss that powers the rift. Machines fight packs in skirmishes: dice
fights against one pack at a time (a hunter's catch included). The depth lives in the skirmish.

## Machines

- **Chassis**: hull, shield, shield regen (shield regained as each round opens: one to three
  by chassis, the faster on the smaller gauge), heat maximum, cooling (one at least on every chassis that is dealt), armour, move, size class, one way of moving, hardpoints, fixed components, module
  slots (two; the Clydesdale three) and one passive. Twenty-four chassis from five makers
  (`content/chassis.json`), four of them back in design and dealt by nothing until their
  sessions hand them back (the Polar Bear, the Puffin, the Whip Scorpion, the Swallowtail: a
  chassis whose entry says `"status": "planned"`). A run has four squad slots and starts with three
  machines.
- **The die**: one entry per component, fixed components first, then one per hardpoint in
  order. Each entry shows its place, from I, as a grey Roman numeral: top left on the die,
  beside its name in its readout, and down the codex. An empty hardpoint is a blank entry; nothing fills it. A full,
  undamaged machine is reliable.
- **Components** come in four kinds, as the die's main mark shows them: a **weapon** deals
  damage and is spent on a foe in its reach; **equipment** is a buff or a debuff and deals
  none, a buff spent on a machine and a debuff on a foe in its reach; a **shield** and a
  **vent** are spent on a machine. A shield, a vent or a buff goes to itself and allies by
  default, or self only, or allies only, as the mark under its main mark shows: three connected
  hexes, the middle its own machine, the two beside it its allies, a filled one a machine it may
  be spent on (all three for either), as a weapon's reach is the line of fire under its sight.
  **Every Ally** and **Every Other Ally** (a shield's or a buff's, never a vent's) are targeting
  modes of their own: the entry lands on the whole team, its own machine among them, or on every
  machine but its own, each taking all of it. They and Every Foe (Reach, below) are targeting
  modes, never keywords, so a Silence leaves them whole. A passive may make a piece count as
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
- **One number**: a weapon is one number with no roll, however many things feed it (heat
  fired, missing hull, buffs, armour); nothing on a die rolls but the die. A weapon's heat is
  its own number, set by its niche like its reach. There are no crits and no weapon classes.
- **Tags** (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee: the working set, and
  the only tags a component may wear) are build flavour, shown on its readout's last line and
  beside its name in its codex row. A tag carries no rule of its own; a module or passive may
  read one. Every weapon and debuff wears its tags by its fantasy, a shield, a vent and a buff none, but five locked ones the stock
  pass's table did not reach (the Pinion Driver, the Lorentz Contractor, the Syrinx Drone,
  the Fovea Designator, the St. Elmo's Regenerator), and only `melee` is read today: a blow
  lunges on screen when its weapon is melee and nothing about it crosses the field (a blade's
  class, and no Ballistic, Missile or Beam); any other fires as a gun, a shotgun tagged melee and
  ballistic among them.
  Melee means short range, a shotgun included, never only a blade.
- **Modules** sit inside the machine and are never spent: stat lines up or down (hull,
  shield, heat maximum, armour, move, cooling, shield regen) and at most one rule, tier 1
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
  and its tier-two chassis stock them. The basic kit is six pieces, each a maker's: four
  guns, each making heat (the Twin Autoguns and the Rivet Gun, Direct; the Ankle Mortar, Indirect; the Laser
  Carbine, Direct and warm), and two defensive pieces, each spent on itself or an ally (the
  Halo Projector, a Barrier; the Shoring Jack, Armoured 2 for the round).
- **No recovery on the die**: a component is a weapon or equipment. No stock die holds a
  shield or a vent and no slottable one is dealt: the shield is the chassis's and comes back
  by its regen, heat goes by its cooling, and the decision heat leaves is the hold (fire the
  cold entry, keep the hot one, or pass and cool). The slottable shields and vents are kept in
  content as drafts nothing deals (no blueprint, no loot, no basic), each until it is made
  equipment or removed; the engine still runs both kinds, for the locked pieces that are one
  (the Musk Ox's Quick Reload) and the machines back in design.
- **Damage states**: a component is intact or destroyed, for the whole battle (none is destroyed
  while the injury rule is off: Injury, below).

## The skirmish

### Formation
- Foes stand in two ranks of four columns, front and back. A massive foe (size 2) fills a
  whole column, both its slots, and counts as front rank for reach: always in reach, never
  exposing its column, nothing behind it. A back-rank Sweep's shot or a back-rank area at its
  column meets it as one in the front does, and a blow meets it once however many of its slots
  it reaches, so its own column adds nothing to a Splash or a Penetrate aimed at it.
- A pack is what its fight's slots hold: nothing waits behind the formation and nothing steps in
  once the fight begins. Every composition fits its slots (Content conventions) and every fight
  holds one pack, a boss's with its escort, so no fight is given more than its slots hold.
- At the start, foes take their ranks heaviest hitters first from the left (its heaviest
  move's damage times strikes, a breach 1 more; ties in arrival order).
- A pack is its composition's grid (Content conventions): the count the map shows is the count the
  grid holds. Its fight, holding it alone, stands its foes as the grid has them: each cell, front
  then back, left to right, a foe of its kind, a massive one filling its column; a cell that
  names none stands empty.

### The round
1. Rerolls reset to two (less any a foe drained). Every machine sheds heat by its cooling,
   then regains its shield regen up to its maximum (a shield gain like any). Every die rolls;
   entries are equally likely. Round-start passives fire, and a store that grants a buff
   grants it for the round (the Honey Badger's hopper its Armoured), before the foes pick.
2. Every foe picks its move, then its target; both show, exact, before the player acts, its
   intent chip under it: the move's kind, its blow's number and strikes, and each rider by its
   mark, a numbered one with its stacks. A blow's number counts the rallies on their way to it
   this round (Empowered, below).
3. The player's turn: spend, lock and reroll in any order. Each spend resolves fully before
   the next. UNDO takes back the last spend or reroll, in the order made, back to the last
   roll, its floor: the round's roll, a reroll that draws, or a spend that draws inside itself
   (Rapid's reroll, a roll again, the Scorpion's blast); a stepping die's step draws nothing,
   so it is taken back like a spend. The trail shows a bar at every roll, every line of it at
   full strength, and UNDO's badge says how many spends it reaches; UNDO opens once a spend's
   last blow has played. END TURN sits bottom-left and UNDO bottom-right, and UNDO reads on or
   off by its edge, a heavy solid one or a faint dashed one. END TURN pulses once no
   die has anywhere to be spent, rerolls aside.
4. END TURN: a machine's Burning adds its heat and loses a stack, and its Scorched goes;
   then heat over a machine's maximum burns hull one for one and the gauge settles at the
   maximum (an overheat). A machine it wrecks is lost on its own turn, before the enemy
   acts.
5. The enemy's turn (below). Round-timed effects end.
6. Machines' statuses tick, and foes' Flak halves. Shield past the maximum (overshield) fades.
7. A part due to grow back does, in its corpse's slot (below). Next round.

The fight ends the moment it is decided, mid-turn too: victory when no foe stands, defeat when
every machine is wrecked. There is no round limit.

### Dice
- **Rerolls**: two a round for the team, never banked (Maverick's Playbook, the Giant
  Petrel's passive, below, the one exception). A reroll of one die alone spends that machine's
  own free reroll first, where it has one left (the Clydesdale's Battery Director, the Trim Tabs
  module: one a round each, on top of the team's). A reroll rerolls every unlocked,
  unspent die, before or after attacking, and lands on any other entry, never the one
  showing; a copy of it may come up, at the odds its copies give it. Every roll inside the round
  follows the same rule (Rapid's free reroll, the Kite's reset, the Booster, the Uplink, the
  Reveille Horn), but two, kept on purpose and each saying "itself included" on the die: the
  Nemesis's Knuckle of Fury rolls again as the round's opening roll does, and the Cassowary's
  Spin-Up spins every chamber. Double-tap or hold a die to lock it, and again to unlock it; spending
  unlocks it; locks clear each round.
- **A stepping die** (the Cassowary's): it never rolls. Each fight opens on a random entry,
  and every roll or reroll steps it to the next entry in order, Rapid's free reroll too; a
  lock holds it. The die shows its next entry in its passive box, its mark and the number it
  will show, and its readout and codex show its entries as a
  cylinder, in order (the one showing lit and an arrow to the next, in the readout). Its Spin-Up spins the whole die, the entry
  showing included, one of the two rolls kept on purpose (Rerolls, above), so it may land on itself and
  be spent again. Every sixth weapon or equipment it aims at a foe in the fight counts double,
  its damage and the stacks it lays; the count shows as six cells under the heat bar, as a
  store's are, the sixth apart by its shape (a heavier border, a diamond set in it) and
  lit in the heat's colour when it is next, and a shield, a vent, a buff and a spin are no shots.
- **The Quick-turn Avionics Relay** (the Needletail's passive): equipment, a buff or a debuff
  read on the entry as it is spent, is Rapid on it once a round, the entry dark for the rest of
  the round as Rapid's is; the die shows the Rapid on every setup while the gate is open. A piece Rapid of its own spends no gate.
- **Maverick's Playbook** (the Giant Petrel's passive): the team's rerolls unspent as the
  player's turn ends are banked, up to three, and come back at the next round's start beside
  its two, spent like any reroll; a roar's cost comes off the whole. It banks while the
  Giant Petrel fights: wrecked by the next round's start, it carries nothing.
- **Spending**: drag a die onto a target: a weapon or a debuff onto a foe in reach, a shield, a
  vent or a buff onto a machine it may reach. Each die is spent once a round (Rapid excepted). A blank does
  nothing; an unspent die is lost. On screen a spend's hits and shots land one at a time, a beat
  apart, every one of them: each foe a hit reaches flashes, its gauge steps down to what the blow
  left and the blow's number rises off it, a hit on a foe an earlier one felled landing on it all
  the same, and a Sweep's shot at an empty column landing on that empty slot, a jolt and a ring of
  dust with no number; a foe the spend kills stands until the death check, after the spend's last
  blow, and a last act lands its damage on the machines as it is named. A new spend or the turn's end lands whatever
  is still waiting at once.
- **On a machine**: a shield adds its number up to the target's maximum; a vent removes its
  number in heat; a combined entry spends two halves on one machine (the Wake Diffuser: a vent
  that shields, the vent first, then the shield, sized on the heat the vent left, so the
  Puffin's Slipstream grows it on what is left); a buff grants its status, so many stacks, through so many rounds, or with
  no rounds when the status runs down on its own (Empowered).
- **A debuff** is equipment aimed at a foe (a setter, a swap), spent on a foe in reach as a
  weapon is: its keywords are its whole effect, no effect adds damage to it (Empowered, Spun
  Up, Primed's burn), and its heat is paid as a weapon's. A debuff's entry is read as it is
  spent: the Cottonmouth's drum fires every weapon and equipment it aims at a foe as its shot of
  4, so a debuff through the drum is a weapon.
- **The die's face**: the kinds are Direct, Indirect, Equipment, Shield, Vent and the blank, and
  every entry reads one way. One main mark at the top says what it is and holds what it
  delivers: a weapon's sight holds a strike's blow, its strikes beside it (×4); equipment's gear
  holds what it grants or lays and no number (a buff's status with its stacks beside it, a
  debuff's first keyword that does something to a foe in content's order, or the star for a rule
  of its own; a reach, an area and Rapid stay on the edge, which never shows a thing twice); a
  shield its number in the shield's colour; a vent its number in heat's colour; an entry that
  shields and cools (the Wake Diffuser, the Sutler's Hoist) both numbers in one mark; a reload
  (the Musk Ox's Quick Reload) its shells and the ammo it loads. Whom it reaches stands under
  the mark, the targeting slot: a line of fire, straight for Direct and lobbed for Indirect; for
  a Sweep the line lobbed whole with a short line of fire rising off it for each of the rank's
  four columns; for Every Foe the enemy's formation, both ranks lit, in square brackets; three
  hex cells for an entry spent on a machine, the middle its own, a lit one a machine it may be
  spent on, and for Every Ally and Every Other Ally the three cells under one low arch, the middle
  lit for the whole team and dark for every other ally. Its costs run along the foot (Costs, below) and its keywords
  down the edge. What the machine's passive adds sits in its passive box at the foot of the
  edge, never joined to the blow: a blow added after the strikes by the mark of what pays it
  (the Storm Petrel's zap by the shield's, in the shield's colour), a vent's blast at a random
  foe by the blast's mark (the Whip Scorpion's), a stepping die's next entry by its mark and the
  number it will show (the Cassowary's). The readout says each on a line of its own, headed by
  the same box. A dark entry is blank, its clock and its turns left along the foot. How each
  mark is drawn is `tools/die_sheet.gd`'s sheet and the bible's section 6.

### Reach
- **Direct** reaches the front rank, a back-rank foe whose column's front slot is empty, and
  any foe carrying Exposed.
- **Indirect** reaches any foe, at no cost to its firer: area belongs to the keywords (the Howitzer
  carries Splash 1 and the Musk Ox's two locked guns Splash; which other explosives carry
  which is open).
- **Sweep** reaches any foe and targets its rank, the rank of the foe the entry is dropped on:
  it fires a shot at each column, left to right, repeating until it runs out of shots. A shot
  at an empty column is wasted, its area with it, so a lone foe takes only its own column's
  shots; a foe an earlier shot felled takes its column's later shots on its corpse, since
  nothing is cleared until the shots are done; a massive foe fills both slots of its column, so
  either rank's shot there hits it; a Gel's pair takes a shot for each half, a spot each, as if
  it were another column. The spots are queued as the spend begins, each column at least once,
  so a half that fell before the spend leaves none. A Sweep carries no Swap, detonation or
  gather, each of them acting on one foe. Each shot is aimed at its column's foe and is a hit of its own (A spend's
  order, below), and an area keyword's shape rides each. The die shows a shot's number, and
  dragged over a foe it lights that foe's rank whole and brackets it. The Skua's Flechette
  Pod, and the Musk Ox's salvo an ammo a shot.
- **Every Foe** (a debuff's) reaches any foe and lands on every foe in the fight, front rank and
  back, as on its target. A weapon reaches wide by Spread, Penetrate or Splash instead. Like
  Sweep it is a targeting mode of its own: no passive turns it into Direct or Indirect, and a
  Silence, which mutes keywords, leaves it whole. The Whip Scorpion's Siphon.
- Chain's arcs read no reach: they land on every Shocked foe on the field, front or back,
  whatever the gun's reach.
- A kill clears its slot at its spend's death check, so a hole in the front opens that
  column's back to Direct; what a kill brings back (a foe getting back up, a Gel's halves)
  stands once the spend is done (A spend's order, below), and otherwise the hole stays open:
  nothing steps into it after but a split's half, a summon, a part that grows back or a
  Swap's foe.

### A blow
Every foe a strike reaches takes a blow of its own, read in one order:
1. The number: on the foe the strike is aimed at, the weapon's number; on every other
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
   halved 1); a debuff's blow stays nothing. Its riders land on every foe struck, after its
   weapon's hits (below).
- **Riders land after the hits**: each hit's Cryo and Flak gather on its own foe and land
  once its weapon's hits are done, an application a hit, so no hit of a single-target weapon
  cashes or feeds on what the weapon lays (a ×2 Cryo 1 leaves Cryo 2 and cools nothing; a ×3
  Flak 1 lands 5, 5 and 5 and leaves Flak 3). Every rider lands so, Burn, Suppress, Web, a
  passive's lays, Purge and a Primed machine's Burning with them, in the order the hits earned
  them; Shock, Expose, Lure and Disrupt land after the blow. A Sweep's shots are hits of their
  own: each shot judges its gates, its machine's lays and its foe's reads as it fires, and its
  riders land before the next shot fires, so a later shot at the same column reads them (a ×4
  Flak 1 sweep of two columns lands 5, 5, 6 and 6), opens a gate an earlier shot's mark shut,
  cashes an earlier shot's Cryo, spends its Shock and arcs through it; each shot's marks feed the
  Paradox, and each shot's Disrupt turns the foe it meets.
- **A spend's order**: a single-target weapon (area included) lands its hits on its target,
  then every hit's riders, then the death check; then the spend ends, then what its kills
  bring back. A multi-target weapon (Sweep alone) fires each shot in turn (its column's foe,
  its hit, its riders), then the death check once every shot is done; then the spend ends,
  then the returns. Everything a hit does lands before the death check, on a foe it fells
  too (its riders, a Mine, a Shock, an Expose, a Lure's turn, a Swap, a gather, a detonation,
  the zap after the strikes), so the
  preview shows the chips beside the skull and no trigger goes unfired; a spend that asks
  whether it killed (a kill trigger, the talons, the reset gun) reads its own death check. The death check
  clears a kill's slot; a foe getting back up and a split's arrivals stand only once the spend
  is done, in the slot their unit died in, wherever a Swap moved it, so nothing the spend does meets them, and the preview shows a foe that will get back
  up or split with its return's chip in the skull's place. What a foe's tick fells comes back
  at once, once the Mines its falls set off have blown. The prediction runs in phases: a foe its Burning will kill before it
  acts keeps its intent shown, information whether its blow lands or not, and its blow is left
  out. The enemy's turn is sequenced as it happens: a foe its tick kills never strikes, and a
  wreck takes no more strikes. Its death check runs as each foe's action is done, and at once
  on a foe its tick fells, so its last act lands, its parts fall, its machine is let go and its
  return stands before the next foe moves; and it ends the moment the fight is decided, the
  foes after the blow that wrecks the last machine doing nothing.
- **A kill**: a foe the death check clears that stays down. A foe getting back up and a split
  are none (a split's halves are kills of their own), nor a part, felled alone or taken with
  its core, since a core and its parts are one unit and only the core's fall counts, nor a
  Bomb's burst or a foe a merge takes in. Every kill trigger, the grudge, salvage and menace
  read it.
- Every blow of a strike is read before any of them lands. A foe's own reads (the hull it is
  missing, the stacks it carries) are taken as its hit judges them: a single-target weapon's
  as the die is spent, before any strike lands; a Sweep's at each shot.
- **A Mine** (the Lammergeier's Reverberant Payload, its passive): every weapon and equipment it
  aims at a foe leaves a Mine on that foe as a rider, before the death check, one a spend
  whatever its strikes (a Sweep's and a salvo's on the foe the die is dropped on): the passive's
  flat damage, 2, plain, and the spend's whole result on that foe, joining any Mine the foe
  carries, one Mine a foe: every status's stacks the hits aimed at it fired (each hit's, as its
  machine deepened and doubled them, a Primed machine's Burning and a passive's lays among them,
  a condition read as the die was spent), its Purge and Chain at every hit's number, the rest
  once each (Shock, Suppress, Web, Expose, Breach, Disrupt), a gated keyword where its gate held.
  The numbered ones add up across the spends that feed it. Spread, Penetrate, Splash and
  Spillover, the Swap, Rapid and Lure stay with the spend, and what a hit reads off its foe for
  damage (missing hull, a consumer's stacks) means nothing to a flat Mine; each foe its blast
  meets takes it with its own defences (a Ward, its Numbed). When the foe falls, one
  that gets back up or splits included, a tick's fall and a part's too, the Mine blows once the
  death check has cleared the slots and before what the falls bring back stands: one blow of
  its damage on every foe round its slot (the slot's other half, the foes beside it in its rank
  and the other rank of its column; a massive foe's, the front-rank foes in the columns either
  side), each through its own Flak, a Barrier and its armour, none under Breach, aimed at nobody
  so a Shock neither doubles it nor is spent; Chain's number on every other Shocked foe on the
  field; then its keywords on each foe it met, felled or not, as a hit's riders land, Shock and
  Expose after its blow, Disrupt only in the player's turn. Several Mines due at one death check
  blow in strike order, front left to right, then the back, and a blast that fells a mined foe
  blows that one's Mine in turn. A blast set off in a spend is part of it, so what its falls
  bring back stands once the spend is done. A Mine moves with its foe (a Swap) and goes into a
  merger with the foe a merge takes in; it is a mark the team laid, so a Ward turns it away, a
  foe's cleanse takes it and the Paradox counts it. Its chip shows its damage, its readout its
  keywords.
- Strikes are separate blows; each lands the number and carries the keywords. Heat is paid once a spend.
  A split weapon (the Skua's) hits twice as often, or fires twice the shots for a Sweep, each
  hit's base (its number and what it prints from its firer) halved before the attacker's
  modifiers, rounded down and never below one (a number of nothing stays nothing); every
  modifier and the foe's own reads then count on each hit.
- **The die shows the number** one blow will deal after every modifier; a debuff shows none,
  and a gun whose blow is nothing here shows 0. Dragged over a foe it may strike,
  it shows that foe's number: its missing hull, conditions on it, its Flak, its armour off. A
  Shocked foe's doubling is not folded in (it shows on the foe's chip). Its heat is
  the heat the spend will add, every modifier in (a Scorched machine's weapons run hotter).
- **Tapping a die** opens its readout, the entry showing alone, its marks as text, each line headed
  by the mark on the die it says (the main icon, its targeting mark on its target, a keyword's
  chip, the star, equipment's status chip, each cost's mark, the lock, a corruption): its place and name,
  what holds on it (on cooldown with its turns left, a foe's switch-off, corruption), its
  codex, then a line a mark: its number as the die prints it, its heat, its target, then its
  keywords (how it lands, Volatile, what it applies on hit, Rapid), its own rules and a
  written-out grant's line last, then its tags. A number the live sources moved off the
  component's own is coloured, green where the change is good for its unit and red where it
  is bad (more heat, a smaller blow), always relative to the unit and never the player, with
  its arrow on it, the way it moved: each number on its own, so a split weapon's smaller blow
  and its extra strike each say so. No source is listed. A tap on it again closes it, and it
  is one readout with the units' (below): a tap on another die or a unit moves it. A die's tap
  lands once the double-tap window (0.15 s, from the tap's release to a second touch) has passed
  with no second touch, the die lit from the touch until it does, so a double-tap only locks and
  leaves the readouts as they stand; a tap
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
  A piece that changes its machine's form wears that form's chip: on the Polar Bear, a shield it
  may spend on itself the seal's while its shell is open, and a weapon or a vent the opening's
  while it is sealed; the sealed machine wears a shell round it, a burst as it seals or opens.
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
  beside it ("Armour 2 (+1▲)"); every chip on it by its name and count, a buff's and a debuff's
  headed by the word ("Buff, Empowered +2", "Debuff, Burning ×2") as an Ability's is, what it does
  a tap on its term away, and the round's warnings (an overheat, a wreck, an injury's risk); then a foe's intent
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
  rally, a web's burst, a death before it acts with its intent kept, the last act it sets off,
  a self-destruct) and
  the round's end. The die in hand counts only over somewhere it may be spent, as it would be
  spent there. A foe whose machine falls before it acts strikes the next machine in line: its
  arrow stays on its pick, and a second, dashed, goes to the machine its blow lands on.
  Nothing a roll decides
  is promised: a strike at a random foe among several is left out (a lone foe takes it). A foe's gauge shows the HP the round will
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
  tier three, 30 to 40 massive at tier one and to 56 at tier three, 12
  to 24 heroes, the slate's bosses 48 at tier one (a core in parts 40, a part 8 to 12, a boss
  that may rise once 40; the kill-time test's read, under the 80 to 100 first written for
  them); a foe's blow 2 to 8 at tier one (the rank and file's mostly 2 or 3)
  and to 10 at tier three, a massive
  foe's 7 or 8, a hero's 4 to 10, the slate's bosses' 6 to 10; machine hull 20 to 50 by size (the
  Kite's paper hull 12, its row's one-off), shield 6 to 16, shield regen 1 to 3 a round, base armour 0 to 2 by role, timed armour to 4 or 5; heat
  1 to 20 (1 to 30 if the pricing needs it), the maxima 10 to 14 (the Musk Ox's 8), a vent 3 to
  8 (the Entropy Condenser's 10 the capstone, paid in hull). The scales are magnitudes,
  not steps: any whole number may be used, and content sits a little past them where its
  loops moved it (the Zombie Knight's 8 HP, the promoted forms' 32 to 48, a hero's finisher, a
  multiple of its blow, to 16). A move is a count of hexes, 1 to 6 (the machines' 3 to 6, the foes' 1 to 4).
  The content's numbers are the stock pass's fills as its loops moved them
  (`docs/measurements.md`; set by `tools/stock_fills.py`), the four Kestrel machines' by hand at the same scale; placeholders until play.

### Player keywords
- **Spread N** (id `cleave`): also hits the foes beside the target in its rank, each taking N
  where the target takes the number (a blow, above).
- **Penetrate N**: also hits the other rank of the target's column, which takes N.
- **Splash N**: the plus round the target, Spread and Penetrate at one number; the two at one
  number are written Splash. A weapon's area keyword carries its number; a debuff's carries
  none, its effects reaching those foes and its blow nothing.
- **Breach**: the blow ignores the foe's armour (foes carry no shield), the same word as the
  foes' rider below. The Overclocked Railgun carries it.
- **Burn** (with a number): each foe hit gains that many stacks of Burning (Burn 3: three
  stacks).
- **Cryo** (with a number): every foe the entry reaches gains that many stacks of Cryo a
  strike, laid once its hit's strikes are done, so a hit never cashes its own frost (a Sweep's
  later shot, a hit of its own, cashes an earlier shot's). Any
  machine's hit with a weapon on a foe carrying Cryo spends every stack and cools the hitter 2
  a stack, after the spend's own heat lands; equipment spends none.
- **Suppress**: each foe hit is Suppressed; on a Numbed foe the stun strips a stack and lands
  nothing; a Ward turns it away; one already suppressed for that action gains nothing more.
- **Shock**: every foe the hit reaches is Shocked after its blow, the ones it fells included, so
  a hit never spends its own Shock; a Sweep's later shot, a hit of its own, spends an earlier
  shot's and a Chain arcs through it.
- **Chain N** (a weapon's): the blow also lands N on every other Shocked foe on the field,
  each arc a blow of the spend that no strike is aimed at, so its Shock stands, the riders land
  and an arc adds no heat. Its footprint, like an area's, is read from the strike's own foe: an arc
  spreads nowhere, a foe an area reaches never arcs, and a foe both beside the target and
  Shocked takes one blow, the area's.
- **Lure**: every foe reached turns on the spender for the round, a felled one too. The Whip
  Scorpion's Siphon lures Every Foe, and every blow a foe lands on it that round adds 2 heat
  to it (Siphoning), in the enemy's turn, after the overheat.
- **Expose** (the Needletail's Fovea Designator, the Swallowtail's Spotting Flare, the Lammergeier's Lorentz Contractor): every foe reached
  is Exposed through the next round, a felled one too; a second Expose refreshes it, never
  adds.
- **Disrupt**: every foe reached (by each shot of a Sweep that meets it, so two shots turn a
  two-move foe back) takes the next move in its list that its
  conditions allow, keeping its pick while the machine stands and is in the fight; a new one
  otherwise, and when the move it leaves aimed at no one machine (a brace, a blow at every
  machine), since the pick it carried was never shown. Disrupt resolves before Lure.
- **Purge N** (id `dispel`, the foes' word too; Aphelion's Null Field Emitter, Purge 2): every
  foe the entry reaches loses N stacks of every buff it carries (Armoured, Empowered, Enraged,
  Undying, Primed, Barrier, Regenerating, Numbed; an unstackable buff is one stack; its
  Abilities, a core's guard and a golden rage among them, are no buffs and stay), after
  the blow and with the riders, a debuff's included, so a foe the blow kills stays down and a
  Barrier the blow pops is gone already; a Ward turns it away and stands; a Mine's purges every
  foe its blast meets.
- **Rapid** (any component): the die rerolls free onto any other entry, a copy of the same
  component included, and the machine acts again, so copies of one Rapid component chain.
  Rapid carries no cooldown of its own: a Rapid component prints its cooldown (most print one,
  dark for the rest of the round), shown on the die by its clock like any cooldown, or pays
  heat, hull or shield every spend instead. A Rapid component always
  carries a limiter, a cooldown, heat or a cost; a piece locked on a stepping die (the
  Cassowary's Spin-Up) needs none: its spin
  is a true roll over every chamber, so it lands on itself one time in six, to be spent again,
  a fifth of a spin more a spend on average, and every other way back to it in a round runs
  through the other chambers' cooldowns or the team's rerolls.
  A Rapid vent is never below tier three (the one is the Musk Ox's quick reload, locked on a
  tier three, which cools nothing), and a Rapid shield never below tier two (the Laminar
  Deflector's two).
- **Cooldown** (a printed property on specific pieces, or one a passive grants every weapon
  and equipment its machine aims at a foe, the Kite's two; the longer stands), a cost printed
  along the entry's foot by its clock: once spent, the entry is dark for that many rounds, this
  one included, shown on the die with the turns left; the die may land on it, and a dark entry
  does nothing. No cleanse lifts it.
- **Reset** (the Kite's Pinion Driver): if its spend kills, every entry dark from a cooldown
  comes back, itself included, and the machine acts again, the free roll never landing on the
  entry just spent; a team reroll may bring it back up, and every kill resets it again, with
  no limit.
- **Web** (the funnel-web's Web Bomb): the foe hit is Webbed, one web however often it is
  webbed; at the end of its action the web bursts, Suppressing it and the next foe to act
  beside it (Webbed, below).
- **Swap** (the Dingo's Combat Translocator): the spend takes two targets, a foe and then
  another foe or an empty slot, and they trade places; no damage; a massive foe does not move.
  A Swap lands in the rider phase, before the death check, like every rider: one whose spend
  fells its first target moves the corpse, which dies in the slot it was moved to and gets back
  up or splits there. A Mine moves with its foe.
  A foe keeps its pick and its move, from the rank it now stands in (a back foe pulled into the
  front stands exposed to Direct fire). On the screen: drag the die to the first target and
  drop it; the second targets light; tap one to spend it; a tap or a hold on the die reads it; drag the die
  again to move it or set it back. A tap on the ground sets it back too, the die flying home,
  once no readout is open: the first such tap closes the open readout.
- **Flak** (with a number, Wainwright & Sutler's on-hit): each foe hit gains that many stacks
  of Flak a strike (Flak 2: two stacks), laid once the strikes are done, so no strike of the
  spend feeds on what it lays.
- **Costs** are printed along the entry's foot with its heat, each a mark and a number with no
  word and no sign (the heat's thermometer, the shield's, the hull's machine body, a forging
  gun's shells, the cooldown's clock), never a keyword and never a chip: a
  **hull cost** (Volatile 3: spending it costs its owner 3 hull, past shield and armour,
  before it acts, and a machine it leaves at nothing is wrecked; the Umbra Inducer, the
  Oblation Mantle and the Entropy Condenser cost 3) and a **shield cost** (3 shield, taken
  first from the shield as it stands, overshield included). An entry whose shield cost the
  shield cannot pay cannot be played: the die shows the cost struck through, it has nowhere
  to land, and END TURN pulses as if the die were spent. It is the first entry with a
  condition on its play, and the pattern for any to come.
- **Cleanse** (on a shield or a vent, today): the machine it lands on loses Burning, Scorched, Crushed,
  Silenced, a foe's Disabled and Corrupted (never a cooldown).
- **Overshield** (shields): may pass the maximum; the excess fades at the round's end, and as
  the fight ends, mid-turn included, so it never leaves the fight.

Component properties, printed on the entry rather than learned as keywords (the die marks
them with a star): **Vents all** fires the whole heat gauge into the shot, adding its
bonus per step of heat fired, the step printed on the entry (the Afterburner Cannon: +1 per 2),
then its own heat lands. **Empowered a kill** (the Soulcutter Talons'
rule, no word of its own): each foe its spend kills gives its owner a stack of Empowered, at
the spend's death check. **Missing HP** adds its bonus for every
step of HP the foe struck is missing, each foe its own, on each blow after the attacker's
modifiers (so a split weapon's two strikes each add it), both numbers on the entry (the
Coriolis Accelerator: +1 per 5). **Gated**: a keyword printed with a condition on the foe (a Suppress on a foe carrying
Flak, or on a foe carrying two Burning or more) lands only on a foe that meets it, judged as its
hit is (as the die is spent, a Sweep's at each shot) and before the hit's own riders, so a hit
never opens its own gate; the die
held over a foe strikes the chip where it will not land; a Mine its spend leaves carries the
keyword only where the gate held. Suppress alone carries a gate. **Consumes**: the first blow on each foe it strikes eats every stack of the status
the entry names on that foe and deals it a point more a stack eaten, after the attacker's
modifiers and before the foe's own, so an area consumer spikes only the foes carrying the status; the die over the foe
showing the number with the stacks in; one blow on each foe (no strikes past one); a Mine eats
nothing. The Suppression Battery's Suppress is
gated on Flak, and the Backdraft Charge consumes Burning, its Suppress gated at two.
**Burns its firer** (the Stoker's): spending it sets its own machine Burning, the stacks it
prints, after the blow; the round preview with the die in hand counts the first tick with the turn's heat.
**The hopper**: a weapon that fills it puts the loads it prints in its machine's hopper for
each foe its blows damage, after the blow, in place of what the machine's passive puts in (the
Honey Badger's Chainsaw Claw, two); a weapon that fires it takes up to its most loads a shot,
each adding its bonus to the blow, and spends them (its Bullion Fragmenter fires two at +2),
the armour they stood for going with them. **Braces**:
spending it Armours its owner, the stacks it says, an armour point each, until the round's
end (the Wild Boar's Breaching Plow, two). **Rolls again** (the Nemesis's Knuckle of Fury, on rage): spending it
with a stack of its status spends one, and the die rolls again, a plain roll as the round
opens, so the machine acts again and the same entry may show again; nothing switches off,
the stacks being the limit, and the fight's last blow rolls nothing. **The gather** (the
Lammergeier's Lorentz Contractor, a debuff with Expose): every Mine the field's other foes carry
joins its target's, their damage added and their keywords as one, in the rider phase after the
spend's own Mine joined it; a Ward on the target turns the gather away, the Mines staying where
they lay. **The detonation** (the Lammergeier's Syrinx Drone, a weapon of 1, no cooldown): in
the rider phase, after the spend's own Mine joined its target's, the target's Mine blows now on
it and every foe round its slot as a fall's does (A Mine, above), and is spent, so a target the
drone fells blows nothing more; its strike spends a Shock on the target, never the Mine. **The Immelmann Booster** (the Giant Petrel's, Rapid):
spent on itself, the team gains a reroll (Rallied); spent on an ally whose die is spent, which
it may land on only while the team holds the price, three rerolls are paid, banked or fresh,
and the ally's die rolls again by Rapid's path, never onto the entry it showed, and it acts
again, while the Booster's own Rapid gives the Petrel its turn back. **The Spindrift Salvo** (the
Giant Petrel's): a spend of it that kills gives the team two rerolls this round, once however
many fell, banked if unspent. **The Reheat Uplink** (the Giant Petrel's, allies only): the ally
gains Empowered 2 and its die rolls again, never onto the entry showing; a spent die rolls
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
and never a buff: each shows as a row under the heat in the heat bar's shape, by how it fills:
one that comes in whole units (the hopper's loads, the rage, the magazine's ammo) as separate
cells, each with its own border and a hairline of ground between them, the lit ones filled; one that
fills by degrees (the Muster) as a meter with a notch a charge; the shot count as cells too,
its last marked as the shot that counts; and no Silence or Purge touches it, its filling or its use. An **Ability** is a
unit's own mechanic, the rule it plays by, and never a buff or a debuff, so no Purge, Silence
or Cleanse touches it; its chip shows its mark cut out of a solid tile, ahead of the unit's
other chips, and its hold line names it an Ability and says what goes on. A foe's: the Goblin
Nob's Enrage, a core's guard (Guarded), a Gel's split, a last act, a golden rage while it
lasts. A machine's: the Polar Bear's seal (its form) and the Kite's Hot Streak. What an
ability, a passive or a store grants beyond itself is a buff like any (the Nob's gathered
Enraged, a module's Empowered or Armoured, the Armoured the Honey Badger's hopper grants): a
stack is a stack, whatever granted it.

Every status on a unit says what it is, wherever it shows: a **buff**, which a Purge reaches,
wears a wedge pointing up off its chip's top at the left, and its hold line begins "Buff"; a
**debuff**, laid by the other side, wears a wedge pointing down off its chip's bottom at the
right, and its line begins "Debuff"; an Ability its solid tile and "Ability". A term's tip heads a
status by what it is, and the keywords list files the statuses under BUFFS, DEBUFFS and
ABILITIES.

On a machine:
- **Empowered** (buff): +1 damage a stack, so the count is the bonus. At the end of each
  round it halves, rounded down, whatever granted it, until it is gone; a buff component
  grants it stacks and no rounds. On the Ammit nothing of it fades: its Quintessence Tap
  keeps every stack for the battle, whatever granted it.
- **Armoured** (buff, on either side): armour +1 a stack, every stack at once, whatever
  granted it, so the count is the armour: a machine's until the round's end, a foe's (from
  its brace) until its next action.
- **Primed** (buff, on either side): each blow leaves a Burning stack per Primed stack on its
  target, a sweep's on each shot's own foe, a blow that kills on the foe it felled, a shot at a
  corpse on the corpse. A foe's,
  from a stoker's priming, is spent by its next move, whatever it is, and a
  machine's Ward turns its Burning away as it does a burn.
- **Phased** (buff): cannot act, take damage or be targeted until the
  round's end, so allies cannot vent or shield it, a foe's intent on it re-picks, and a blow or
  a special at every machine passes it by; it still cools by its cooling, and ticks and
  overheats land. Granted only to a unit that has not acted
  this round, whose die stands down as it is granted.
- **Swallowed** (debuff, from a foe's swallow): out of the fight as a Phased machine is (it
  cannot act, take damage or be targeted, a foe's intent on it re-picks, and a blow or a special
  at every machine passes it by; its cooling, ticks and overheats are its own) for the swallow's
  rounds, its die standing down as each round opens, until its swallower falls, or until its
  swallower has lost a quarter of its maximum HP since the swallow (its chip counting the damage
  still to deal, never more than the swallower has left; a second machine taken while it holds
  one joins that count, and the quarter lets both go); either lets it go at once, and in the
  player's turn it acts that round. The swallower loses nothing else. Nothing cleanses it.
- **Muster** (store, the Swallowtail's): its charges. Every die that rolls fills
  it a sliver, thirty rolls a charge, a kill by its own guns five rolls' worth, up to three
  charges; it starts each fight empty and never decays. It shows as a smooth bar under the
  heat, a segment a charge. Each of its locked
  pieces has a plain form and a charged one that spends a muster. With a charge up, a locked
  piece goes out charged, unasked, and its die shows the charged form under a double frame;
  when the charged form has nowhere to land (Phased once any ally has acted, the act again
  with no ally spent), the plain form goes out and the charge waits. The
  Mooring Screens shield every ally but the carrier (Every Other Ally), or Phase every ally, only
  while none has acted this round, so it is never a selective protection;
  the Spotting Flare Exposes a foe, or Exposes and Suppresses it; the Sutler's Hoist cools an ally
  2 and then shields it, or fills its shield, cools it to nothing and cleanses it; the Reveille
  Horn gives the team a reroll, or rolls a spent ally's die again, never onto the entry it
  spent, so it acts again.
- **Rallied** (buff): the team has one reroll more this round.
- **Charged** (buff): while it lasts the machine's weapons fire with Shock, shown on the die
  and landing as the keyword does, after the blows; a weapon fired spends a stack (a Rapid's
  second fire is a second fire, a salvo one, a blast none; equipment carries it not and spends
  nothing); a Mine the fire leaves carries the Shock.
- **Supercooled** (buff): the same with Cryo, one more stack a strike on each foe hit (Cryo 1
  on a gun without it), laid after the hits.
- **Spun Up** (buff): the next weapon the machine spends deals +2 a stack and takes every
  stack; equipment leaves them standing; carried between turns until a weapon takes it.
- **Retaliate** (buff): a foe whose blow reaches this machine's bare hull is Shocked.
- **Regenerating** (buff, on either side): a foe's, from its own special, regrows its value in HP
  at each of its next three actions, after its Burning and Vitriol have ticked (a suppressed
  foe's included), so a foe its tick kills regrows nothing; each grant keeps its own clock. A
  machine's (the Storm Petrel's St. Elmo's Regenerator): 2 shield at the start of each of the
  next three rounds, up to its maximum; it stacks, each grant keeping its own end, and a die
  entry granted it, a buff, so an enemy's purge takes it.
- **Barrier** (buff): the next blow a foe lands on this machine deals no damage, so it never
  injures; its riders land, and a blow of nothing leaves it standing. One at a time and one
  stack whoever grants it (a passive that deepens the stacks its machine applies leaves it at
  one, and a Purge of one takes it whole); until the round's end. No piece grants it to every
  ally at once. The Blast Door grants it, self or ally.
  A foe's, from its own special: the next blow of a weapon the team lands on it deals no damage,
  the blow's riders landing and a Shock it carried spent; equipment pops nothing; until it pops
  or the end of the player's next turn.
- **Ward** (buff): no rider a foe lays lands on this machine this round, from a blow or from a
  move of its own (breach, burn, scorch, disable, corrupt, silence, purge), so its shield
  absorbs a breach like any blow; a blow's damage lands. Until the round's end. The Decoherence
  Veil grants it, self or ally. A foe's, from a special that wards every foe on the field: no mark
  the team lays lands on it (Burning, Flak, Cryo, Vitriol, Shocked, Exposed, Webbed, the Paradox,
  a Mine), nor a stun, nor a Purge, so a turned mark feeds no Paradox; the damage
  lands; until the end of the player's next turn. On either side a Ward turns the whole thing
  and stands.
- **Rage** (store, the Nemesis's): a stack each time it takes hull damage (a blow, a bite
  of its own, an overheat), up to 5, spent by its fists to roll again; lasts the skirmish,
  never decays, and nothing cleanses it. It shows as a bar under the heat, in the heat bar's
  shape, five segments, one lit a stack.
- **Hopper** (store, the Honey Badger's): its Ore Hopper puts a load in for each foe a spend
  of its weapons damages, after the blow (a weapon that prints its own number puts that in
  instead), up to four; a weapon that fires
  the hopper spends them; a Mine's blast fills none. It lasts the skirmish, never decays, nothing cleanses it, and it shows as a row
  under the heat, in the heat bar's shape, four cells, one lit a load. What the loads are
  worth is Armoured, a stack for every two held, granted by the hopper: as each round opens it
  grants the machine Armoured up to that worth, and between rounds the grant follows the loads
  by the change in their worth alone (a load that makes a pair adds a stack, loads fired take
  their stacks back, off the hopper's own grant and no other). It is a buff like any Armoured:
  it goes at the round's end, and a Purge strips it and leaves the loads, so what a Purge took
  comes back at the machine's next turn and no sooner.
- **Sealed** (Ability, the Polar Bear's form): a shield it spends on itself seals it: armour +3,
  its own cooling stopped, 3 heat more at the end of each turn before the overheat, and its Cryo
  Flinger gains Spread (one foe open, its rank's three sealed); a vent or a weapon opens it; a
  shield on an ally and equipment leave the form as it is. An entry that
  is a shield and a vent at once (a vent that shields, a shield that cools) does the one the
  form calls for, never both: spent on itself it seals an open machine and opens a sealed one;
  on an ally its vent opens it. An ally's vent still cools it. One seal, however many shields.
  Its Lockdown also lands its weapons 1 harder on a foe carrying Cryo, open or sealed, read as
  each strike lands: the strike that meets the stacks takes the 1 and its hit spends them, so a
  later strike of the same spend lands plain.
- **Burning** (debuff, from a foe's burn; a foe's Burning below is the same word on the
  other body): +1 heat a stack at the end of the player's turn, before the overheat, then a
  stack fades, so a vent makes room for it or a cleanse takes it off. Cleansable.
- **Scorched** (debuff, from a foe's scorch): every weapon and equipment the machine aims at a
  foe runs 1 hotter a stack, until the end of the player's turn, when every stack goes, so it never piles up.
  Cleansable.
- **Disabled** (debuff): the entry comes up blank through the machine's next turn.
- **Corrupted** (debuff): each spend of the entry bites its owner 3 a stack, shield first,
  no armour off it; lasts the skirmish.
- **Crushed** (debuff, a foe's crush: the World Eater's pin): every blow the machine takes
  deals a point more a stack, the shield taking the extra first as it takes any blow, through
  the next round, when every stack goes; a Ward turns the crush away. Cleansable.
- **Silenced** (debuff, a foe's silence): its components' keywords are muted through its next
  round, printed and granted alike (a Rapid entry acts once, a Spread lands one blow, a
  Suppress suppresses nothing, its own Cleanse is a plain shield), then wake; its buffs count,
  its stores fill and spend as ever, and its targeting modes stand (Every Foe, Every Ally, Every
  Other Ally). Cleansable, an ally's Cleanse the way; a Ward turns
  the silence away. A foe's purge is Purge N too: N stacks off every buff the machine carries,
  for good, whatever granted it (a stack is a stack); its Abilities and its stores stay, and the
  Ammit's Quintessence Tap keeps its Empowered from a Purge as from every clock, whatever granted
  it; a Ward turns it away too.
- **Hot Streak** (Ability, the Kite's, its passive's price): its shots run 1 hotter a stack this
  fight, a stack for each attack that killed; no cleanse, silence or purge lifts it.

On a foe:
- **Burning** (debuff): 1 damage a stack at the start of its action, past armour, then a
  stack fades. It never stops healing.
- **Suppressed** (debuff): it loses its next action: this round's, or the next round's when
  it has already acted this turn. It never stacks and never carries: a second suppress on a
  foe already suppressed, a Paradox's included, does nothing. As the foe recovers it gains its
  stun resist in Numbed, after the round's decay.
- **Shocked** (debuff): when a weapon's strike aimed at it lands, the blow deals double and the
  shock is spent. A strike is aimed at the foe it resolves on: the player's pick, or the draw of
  a vent's blast or a sweep's shot, which the game targets rather than the player. A blow that
  only reaches it (an area's, a Chain's arc, a spill, a Mine's blast) neither doubles nor spends it, and equipment leaves it standing; it never stacks.
- **Exposed** (debuff): it stands in Direct reach of every machine as if its
  column's front were empty, and its armour counts for nothing, its own and any Armoured.
  Through the next round; refreshed, never added.
- **Mine** (debuff, the Lammergeier's): its damage, the spends that fed it added, and their
  keywords, one Mine a foe; when the foe falls it blows on every foe round its slot (A Mine,
  under A blow). It lasts the skirmish, until its foe falls or the Syrinx Drone detonates it.
- **Paradox** (debuff, while the Baboon fights): a stack each time the foe gains any other
  debuff, once a hit per debuff however many strikes or stacks (a single-target weapon's hits
  are one, a Sweep's shots each their own); at three it is Suppressed
  (a stun like any other: a Numbed foe strips a stack instead, a Warded one turns it, and a foe
  already suppressed gains nothing) and the Paradox clears either way. It never decays. The Suppressed a Paradox causes adds none; a Suppress
  keyword's does.
- **Vitriol** (debuff): at its action it loses 10% of its current HP a stack, past armour,
  after Burning on what it leaves, the whole share rounded down and never the last hit point,
  then a stack fades; it never finishes a foe. The funnel-web's Ambush lays it, a stack per
  weapon hit, as its text says; a web or a lure lays none.
- **Webbed** (debuff): at the end of its action, skipped or not, the web bursts: it is
  Suppressed (its next action, since it has acted; a countdown it gathers is held a round),
  and so is the next foe to act beside it in its rank, its right-hand neighbour, which loses
  this round's action, or with none standing there its left-hand one, which has acted and
  loses its next (a stun like any other, each for itself: a Numbed foe strips a stack instead; a foe already suppressed gains nothing,
  as from any second suppress; each half feeds the Paradox as the Suppress keyword's does).
  Killed first, or gone by the end of its action, it takes its web with it. Its chip points at
  the neighbour the burst catches.
- **Cryo** (debuff): a weapon's hit on it spends every stack and cools the hitter 2 a stack;
  equipment spends none. It never fades on its own.
- **Flak** (debuff): every blow of a weapon it takes deals a point more a stack, before its
  multiplies and its armour (a Shocked foe takes a strike aimed at it plus Flak, doubled); a
  debuff's blow stays nothing. The stacks halve at the end of each round, rounded down.
- **Empowered** (buff, Rally): lands on every other foe on the field the moment the rally does,
  the rally's value in stacks, and every blow the foe lands hits a point harder a stack, an add
  before the move's factor as every add is. It halves at the end of each round, rounded down,
  the machine's clock: no move spends it, a special or a Suppress takes none of it, and a
  countdown still gathering carries what stands to the blow it lands. A foe acting after the
  rallier hits harder this turn; one that has acted carries half to the next round; each rally's
  grant adds. An intent counts the rallies on their way to a blow this round, those of the ralliers acting
  before it, each from a rallier alive, not Suppressed and not about to burn to death, so it
  drops the moment the rallier is killed, Suppressed or Disrupted; a countdown still gathering
  shows what it would deal now, at the fight as it stands, never a rally of a round before it
  lands, nor a halving to come. The foe wears the coming Empowered as a preview chip on a dashed edge, its opacity
  pulsing on the gauges' clock, until it lands; a foe whose move shows no blow wears none.
- **Enraged** (buff, a rage: the Goblin Nob's, its own from the fight's start): while the foe
  stands, every shield, vent or equipment entry the team spends lays its rage in stacks on it,
  before the entry acts, and each stack is a point on every blow it lands for the rest of the
  fight, an add before the factor; a weapon or a blank feeds nothing, and no move spends it.
  Its chip climbs with the stacks, so the number an intent shows is the number that lands. A
  Purge lowers the stacks by its number and the rage goes on: the rage is the Nob's Ability,
  its chip the rule (Enrage), and what it has gathered a buff.
- **Golden** (Ability, a golden rage: the Thunder Ape's): for the rounds its move says its blows
  hit the move's value harder, an add before the factor, and it wears a point of armour. A
  quarter of its HP lost since it went gold breaks it and it staggers: the gold goes and it
  loses its next action (never Numbed: a stagger is no stun piece's, and one already
  suppressed loses nothing more). A Suppress that lands breaks it too, one a Numbed stack
  absorbs does not; no Purge strips it, an Ability. Its chip counts
  the rounds left and the damage that breaks it. It goes gold only while calm (the `calm`
  condition: not gold), so one rage at a time.
- **Undying** (buff, Reraise, on itself or from an ally's): after it falls it gets
  back up once, whole, in its own slot, unless it self-destructed: once the spend that felled
  it is done, or at once to a tick; its round is over, as a split's half's is, and it comes back
  with no Mine. A Purge on the hit that fells it strips it first.
- **Numbed** (buff): the rounds until one stun lands. A stun on a Numbed foe strips a stack and
  lands nothing, so a foe with Numbed N takes N+1 stuns in a round. As a stunned foe recovers it
  gains its stun resist in stacks (content's `resist`; by its kind when content says none: 1, a
  massive foe 2, an elite, a hero or a boss 3), after
  the round's decay; a stack goes at the end of each round. A Purge lowers it like any buff;
  nothing deepens, spreads or cleanses it, and a fresh foe is stunned by one.

"A foe carrying a status" (the Susceptibility Tensor) means a debuff the team put on it:
Burning, Suppressed, Shocked, Paradox, Vitriol, Webbed, Cryo, Flak, Exposed or a Mine.

### Shields, armour, hull
- A shield absorbs a blow up to its number and loses what it absorbed; the excess reaches
  the hull. A **breach** blow ignores the shield and the armour: the shield stands, the
  armour counts for nothing, and the whole blow reaches the hull.
- A machine's armour comes off every blow that reaches its hull, flat, what passes a shield
  included, never a breach; a blow at or under the armour is nothing; a shield takes no armour
  off. A foe's armour comes off every blow on it the same way, never off Burning, Vitriol or a
  breaching weapon. Base armour is set by role (a tank 2, a heavy worker 1, the rest 0; the
  Polar Bear, a tank in its sealed form, 1 open and 4 sealed), and
  Armoured adds to it (a brace: a buff, the Breaching Plow, the Siphon) until the
  round's end, the Polar Bear's seal until a vent or a weapon opens it.
  Damage-taken effects apply before armour.
- The shield is the fight's, as the heat is: full as every fight opens, and nothing returns on
  the map. In a fight it comes from components, modules, passives and the shield regen. Hull
  is the battle's and never heals in it.

### Heat
- A weapon adds its heat when spent, once a spend, through the attacker's modifiers in the
  blow's order: adds, then multiplies (so a machine whose heat is doubled doubles Scorched's
  extra too). Heat may pass the maximum during the player's turn harmlessly; at the end of
  the turn, before the enemy acts, the excess burns hull one for one (an overheat) and the
  gauge settles at the maximum. With volatile, it is the way a machine dies on its own
  turn. Machines cool at the start of the round. Heat starts each fight at zero.
- The console speaks of heat on a spend, one line a spend: the overheat every time a spend
  heats a machine and leaves it over its maximum; the warning once, as a machine first stands at
  three quarters of its maximum or past, and not again until it has been seen back under (as a
  round opens, once the machines have cooled, or after a spend), so a machine that stays hot, or
  settles at its maximum after an overheat, is not warned twice.
- An overheat is hull damage for every passive that reads hull damage.
- **The Riot Field Generator** (the Storm Petrel's passive): its weapons' heat comes off its
  shield as they are spent, every point of a gun's own heat taken from the shield as it
  stands, overshield included, and only what the shield cannot pay reaching the gauge; a
  Scorched machine's extra heats the gauge, never the shield, as the forge's does, and
  equipment heats the gauge as ever. After the weapon's strikes, its
  target takes a blow of what the shield paid (the zap): plain, no keyword and no Shock read,
  through what the foe takes and its armour, before the death check, so a target the strikes
  felled takes it too. And while its
  shield stands, every blow on it loses 1, a damage-taken effect read on the shield the blow
  meets. A shield cost on its weapon is no part of it: the cost is paid first as the entry is
  spent and never lands as a blow, and the shield pays the heat from what the cost leaves. The
  die shows what the shield will pay for the heat in its passive box, beside the shield's mark
  and in the shield's colour, one number for the spend and the blow (over a foe, the blow's share with that foe's armour off, as the main number's
  is), never as a cost along its foot, since the spend goes ahead without it; along the foot
  stand only the heat past the shield and a shield cost, as on any machine. The number is never
  joined to the blow's.
- **Ammo** (the Musk Ox's Desublimation Forge): its weapons spend ammo instead
  of heating it, 1 for every 2 heat a gun's own spend would make, rounded up, at least 1, the
  price printed on the die where the gun's heat would be; its debuffs, buffs and shields and
  the foes' heat land on its heat bar as on any machine's, Scorched's extra included. The
  magazine is a row of cells under the heat bar, a cell an ammo, never a status, so no Silence or Purge
  reaches it; it holds 10, opens each fight at 3 and gains 1 at the start of every round after
  the first; a vent it spends on itself adds 3, a shield 2, an entry both at once 3, once, the
  greater; a gun it cannot pay for cannot be
  spent (the die strikes its price through). Its Shrapnel Recuperator returns 1 for every foe its blows reach;
  its Unrestricted Expenditure fires every ammo in the magazine as a shot of one Sweep along
  the rank it is dropped on, with Splash, the magazine its price and no heat of its own (a
  Scorched machine's extra lands on its heat bar, as on any forged gun); its quick reload,
  Rapid, adds 2 for 3 heat, and the Forge counts it as no vent.
- A shield, a vent or a buff that prints heat (the quick reload) adds it to its spender as it
  is spent.
- Foes heat machines only through two debuffs, never outright: Burning, the harsher, adds
  its heat at the end of the player's turn before the overheat, so a vent makes room for it
  or a cleanse takes it off; Scorched, the softer, heats only the weapons and equipment the
  machine aims at a foe in the turn that follows, so a shield, a vent, a buff or a cool weapon plays
  round it. A foe's burn leaves Burning and its scorch
  leaves Scorched, a stack a blow; the Drake's Stoke sets one machine burning, picked as its
  target is (at random: no foe but the Black Mage carries the heat aim), and
  the Magma Elemental's Eruption, the Black Mage's Fira and the Summoner's Pyroclasm scorch every
  machine.

### Injury
- The injury rule is switched off: no blow injures, so no entry breaks in a fight and no
  component is destroyed, in the game and the runners alike (`Skirmish.injuries`; the rule
  stands behind its switch, and what follows is the rule as it runs when on). Shown text still
  names it.
- A foe's blow that puts a quarter of the machine's maximum hull or more past armour into its
  hull (a breach's whole blow included) destroys the entry the machine's die shows (the one it
  spent, held or locked), a blank shrugs it off, and a second such blow in the turn finds it
  broken already. What faces the enemy is the player's choice. A shield absorbs its share first and what reaches the hull counts; a
  Barrier's blow never does. Bites and overheats never injure.
- **Destroyed**: blank; its passive keeps its stat bonuses and loses its abilities. A machine
  wearing the Reinforced Skeleton (Minerva's module) never has a component destroyed, so an
  injury passes it by.

### Foes
- A foe has HP (a foe's word; a machine has hull), a base attack, a rank it holds, a size,
  flat armour (a boss only where its kit is armour, the Cinder Tortoise's stepping by the tier; the promoted forms 2) and perhaps an aim. Its damage
  never rolls.
- **Its move**: from the moves whose conditions hold, weighted by each move's own weight (attacks mostly 2, specials 1, the Bomb's Self-Destruct 3), never
  the same special twice running while anything else is open. A move without a condition
  fires on its weight; the conditions read the foe's own side or what its move needs: below
  half, hurt, a foe behind it, another foe on the field, one
  of its own hurt, a machine carrying a buff, one of its own not readied, one of its own
  marked, one of its parts fallen (a part down and not waiting to step in). A move marked once
  comes once a fight. No foe flees the field but a loot-runner whose prize goes with it (the
  one shape a flee may take; none is built, and no move flees). A move may
  carry a countdown: it gathers, landing that many rounds after it is announced, and nothing
  hits meanwhile; its pick holds while the machine stands; Suppress holds it a round, Disrupt
  breaks it off, and the foe stays on the field. A move may name a follow-up: once it lands, the
  move it names is its foe's next round's intent (the Matador's Red Capote, then Andalucia); a
  follow-up comes only that way, never by the roll, and a Suppress on the first move, or a
  Disrupt that turns it, means it never comes; once announced it cannot be Disrupted, only
  Suppressed (its chip says so, and a Disrupt held over the foe shows its chip struck through),
  so the first move is the window. A borrowed swing with nothing taken is no follow-up, and the
  roll decides. A swallow is never drawn while fewer than two machines stand
  in the fight, nor a merge while nothing of its kinds stands on the field.
- **Its target**, drawn as the round opens: at random, unless the foe or its move carries an
  aim, as its threat calls for: exposed (weighted by the hull its blows would reach
  plus half the shield they would break), heat (the hottest machine), armed (a machine
  showing an intact weapon or debuff, the exposed when none does), focus (its rank shares one pick),
  buffed (the machine carrying the most stacks of buffs, the exposed when none does). The
  foes pick in the order they strike and never over-commit: a machine the blows already picked
  would wreck through its shield and armour is passed over while another stands (a blow at
  every machine counts on each; a special, a suppressed foe and a countdown still gathering
  count nothing). The pick is a commitment, smart as it is made and never after (Slice and Dice's model): during the player's turn it moves only by a Lure, by the
  machine leaving the fight (Phased or Swallowed), or by a Disrupt whose foe finds its machine
  gone or out of the fight; a foe whose machine has fallen or is out of the fight when it acts
  strikes the next machine in line, left to right, that stands in the fight, whatever its aim,
  so the player can tell the pick it
  will make, and the round preview shows it. The preview never moves a pick: a foe aimed at a machine the round will wreck stays
  aimed at it, and the preview shows where its blow lands after. A special that acts on nobody
  in particular (a brace, a regrow, a rally, a scorch all) keeps its pick and shows no arrow:
  it is aimed at no machine.
- **A blow** is its base attack, plus its Empowered, its swarm for each other live foe of its
  type and its grudge (its number for every foe the team has killed this fight, every fall but a
  foe gone whole, a burst or a part falling with its core, and one taken in by a merge), times
  the move's factor: the adds, then the multiplies, the one damage formula on both
  sides; strikes are separate blows. Riders (a Ward turns away all but the last
  three): breach (the blow ignores the shield and the armour), scorch (stacks of Scorched), burn (stacks of
  Burning), disable (the entry the machine shows), corrupt (Corrupted stacks on it), crush
  (Crushed stacks on the machine: a point more on every blow it takes a stack, through the
  next round), steal (the
  entry the machine shows switched off through its next turn, as a disable, and taken: its foe
  holds it until its borrowed swing, whose number is what it took, a weapon's printed blow,
  and anything that was no weapon a fake, for 1),
  drain (the striker regrows what the blow took from the hull, no more than the machine had,
  so a shield starves it; it lays nothing on the machine, so a Barrier's blow drains nothing),
  self-destruct (the striker dies after, for good), every machine
  (each strike lands on every live machine in turn, its number what each takes; no aim or
  Lure moves it). Scorch, burn, corrupt and crush each say their stacks a blow, as the player's
  Burn does (Scorch 2: two).
- **A special** replaces the blow: brace (Armoured, its value in stacks, an armour point each, until its
  next action), regrow (heals its value), cure (the most hurt of its own, itself included, heals its
  value), brace all (the same on every foe in the fight, through the next round), revive once,
  revive an ally (Undying on one of its own, never itself, not readied already: a
  party member first, the heaviest hitter among them, then the rest of its own the same way),
  summon,
  rally (Empowered at its value on every other foe on the field, at once), golden (the rage: Golden for the rounds it says, 1 to 5 and three unsaid, its value the add; only while calm), drain rerolls, burn (stacks of Burning on one machine), scorch all (stacks of
  Scorched on every machine), corrupt all (Corrupted stacks on the entry every machine shows),
  disable, silence (Silenced), purge (Purge N: N stacks off every buff, for good, whatever
  granted it; the Djinn's Unmake at 1; never a last act's), cleanse
  (every mark the team laid, Burning, Flak, Cryo, Vitriol, Shocked, Exposed, Webbed, the Paradox
  and a Mine, off the most-marked of its own, itself included, the first in strike order on
  a tie; never Numbed, never Suppressed; cast where one of its own carries a mark), barrier (a
  Barrier on itself), regenerate (Regenerating at its value on itself), ward all (a Ward on
  every foe on the field, itself included), prime (Primed at its value on every other foe on the
  field, at once), swallow (its machine Swallowed for its rounds, never the last machine in the
  fight, let go early once the swallower has lost a quarter of its HP), merge (every other foe on the field of the kinds it names taken into it, gone with no
  fall, no last act, no split and no kill of the team's: it regrows the HP they had left, and
  its blows hit its value harder for each, Empowered that halves at the round's end, so half
  reaches the next round), each on its target, no blow; a silence and a purge are specials, never riders. A Ward turns away
  every one of them that lands on its machine, a scorch all's and a corrupt all's share
  included, and a scorch all or a corrupt all passes a machine out of the fight by. No foe in
  content carries a silence or a ward all yet; the Djinn's Unmake is the one purge.
- **A last act**: a foe may land a blow the moment it falls (a death blow, with its own
  riders, every machine included), before anything else and even when it was the last foe,
  since damage sticks for the battle.
- **A foe in parts**: a core and the parts of its pack that stand with it. A guard keeps the
  core from taking any damage while all its parts stand, or while any does (Guarded, an Ability), its
  Burning and Vitriol included, whose stacks fade all the same; a part
  that falls may grow back after so many rounds while the core stands; a core that falls takes
  its parts with it.
- **The enemy's turn**: front rank left to right, then the back; on screen each foe is lit from
  just before its move lands until the next acts. At its action each foe's statuses tick
  (Burning first, which may kill it, and a dead foe never strikes; then decaying stacks drop;
  Vitriol after Burning, on what it leaves); a suppressed foe does nothing, and at the round's
  end, after every Numbed loses a stack, it gains its stun resist in Numbed; a web
  on it bursts at the end of its action, skipped or not. A foe with no machine to strike (every one fallen or out of the fight) loses its blow
  alone: its countdown gathers, a special on its own side acts, and the turn goes on to the foes
  after it.
- **A split** (the Gel): a dead Gel splits into two Half-Gels (one deep) once the spend that
  felled it is done, or at once to a tick, standing as a
  pair in the slot it fell from: a twin slot, one slot to the formation, so its hole never
  opens (the Gel is a wall, not an attacker, and its blow carries no breach). An area blow
  that reaches the slot (Spread, Penetrate, Splash, a Mine's blast) reaches both halves, aimed at one
  of them or beside, each half taking the number of the shape it stands in (the aimed half's
  twin the row's, or the column's when the entry reaches no row); a single-target blow, a Spillover included, the one it is spent on. The slot is
  full while either stands, and a half's Mine blows on its twin as on the foes round the slot.
  The left half acts first; a web on it catches its twin; a
  Swap moves the pair together and never swaps a half with its twin. When one falls the other
  keeps the slot alone, still drawn on its own half of it, and with both gone it is a plain slot: the pair is only ever its
  split's, so no half joins another's slot. A Mine the Gel carried blows before the pair stands,
  so they take none of it. Their round is over: no intent, no Lure or Disrupt turns them, a stun takes
  their next action, and they act from the next round. A split that is no pair (none in
  content) steps up one into the slot and the rest into the nearest empty slots of their rank;
  one with no room never forms.
- **A summon** takes an empty slot of its rank at once, the nearest its summoner's column, the
  left on a tie, its round over like a split's half's; a call for several stands as many as fit,
  and a summoner with room for none never picks the summon.
- **A corpse**: a part that falls and will grow back leaves its corpse in its slot, drawn dimmed
  with the rounds until it regrows, and grows back there; no Swap or arrival takes the slot
  meanwhile. A part with no corpse to grow into takes the nearest empty slot of its rank,
  or waits for one. The corpses go with their core.

### Withdrawal
There is no withdrawal: a fight ends in the pack's fall or the machines' wreck. Kills stay
counted however it ends; a pack whose fight wrecks the machines in it keeps its own survivors,
who return whole (a foe that joined it in the fight, a Gel's half, a raised Revenant or a part,
is no survivor, and each of them counts as a kill as any foe does: A kill, above).

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
  each hits twice as often, a Sweep firing twice the shots, and each hit's base weapon damage
  (its number and what the entry prints) is halved, rounded down and never below one, every
  buff and passive and the foe's conditions counting on each hit after it, its armour too; the
  die shows a hit's blow with the hits beside it ("1 ×2"). A debuff deals nothing to halve and hits twice
  all the same, its riders landing on each hit (a Web, a Lure, a Disrupt, a Shock, an Expose
  and a Swap still land once a spend).
- Conditions: the reach is direct or
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
  the passive's condition alone; every strike that reaches it lays it, on a foe the spend fells
  too (A spend's order), a blow of nothing included, unless the passive's text asks for a weapon's hit (the funnel-web's Vitriol).
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
  its Cryo cashed for the machine's cooling, its armour, a Primed machine's Burning, the
  machine's kill trigger), inside the vent's spend, whose heat is paid once (a vent on an ally blasts nothing,
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
Undying, Guarded) means a second grant changes nothing. Nothing writes to
a stat.

## The battlefield

- **Field**: hexes in rows from the rift to the wall, the wall's length and the depth both the
  ramp's (20 and 12 at every Convergence). The rift is three hexes mid its first row; the gate
  is the last two rows' centre (3 and 4 hexes), wall across the rest. One unit to a hex, the boss
  too. The map is a view the player turns (MAP VIEW in the settings): the wall at the left with
  the rift at the right, flat-top hexes, scrolled down the wall (the default); or the wall at the
  bottom with the rift at the top, pointy-top, scrolled along the wall. The field and every rule
  are the same in both. With the wall at the bottom the wall and the gate stand on the last row
  and their height covers the row before it; with the wall at the left they stand on that row,
  against the apron, the last row behind them the city's, and the rift's vortex stands on the
  lowest of its three hexes, a little toward the scenery behind it. The far ground softens
  toward the rift and the city softens past the wall in either view: at the screen's top and
  foot with the wall at the bottom, at its right and left with the wall at the left, never its
  top there. A pack or a machine past the screen's edge has a tag at that
  edge; a tear has none, as the rift has none. Three gauges stand at the top of the screen whatever the scroll: the gate's integrity,
  Rift Pressure toward the next spawn (a box a turn of the beat) and the Rupture meter toward its
  Fractures (a notch a Fracture, those earned lit); the gate and the rift carry no bar on the map
  and are no selection. A gauge that changes flashes. The boss's picture stands far larger than
  a pack's and is drawn for that size: a picture of its own (`art/foes/<id>_boss.png`, cut from
  its combat sprite), its token serving the small faces (an edge tag, a hunter's plate). The
  field reads apart from the scenery past it in both worlds: the reconstruction's grid lies on
  the field alone and the scenery's ground past it stands a step darker, and under the painting
  the field is bright cells and the scenery (the margin past the field's sides and past the
  rift, the city) one shaded ground with no cells.
- **Ground**: open (plain or road), rough, ruins, water, and walls, a wall named by what it is
  (crags, mesas, towers or cliffs) with one rule under every name. Six map shapes, one a
  battle, each with its own water, walls, decorative ground and relief, laid to fill the open
  rows at any size the ramp deals, none of them a band and none an orientation. Two water
  shapes: River Crossing (a river winding through the whole field from past one edge to past
  the other, through the field's centre, two hexes thick and three in places, with one or two
  narrows a hex thick, the water fords where the wade is short, one or two tributaries a hex
  thick off it, a crag on a bank at most, gravel bars along its banks; no land ford: everyone
  wades) and Fjord (the open rows under water, the scenery beside them too, with land lanes
  winding from the rift's row to the team's ground, two hexes wide and pinched to one in
  places, one for every seven hexes of wall, a branch or two off each, and islands; shingle on
  its shores; half to two thirds of the field water). Three wall shapes, a spectrum by the mass
  and the structure of what blocks you: Gorge (cliff mass over the open rows cut by winding,
  branching channels, a trunk for every five hexes of wall from the rift's row to the team's
  ground, one or two hexes wide, three or four branches off each toward the next trunk, meeting
  a channel at a junction or ending blind, a stretch or two flooded, scree at the cliffs' feet,
  the gorge's own sides past both edges), Ruined City (large blocks of
  towers in a grid of streets: avenues one wide from the wall toward the rift four to five
  columns apart, the gate's always one and two wide, side streets along the wall mid the blocks
  whose segments are there or not, an avenue segment fallen in now and then, a plaza or two with
  a fountain in some, a street segment or two flooded, rubble everywhere else, towers thick in
  the scenery) and Badlands (an open field of mesas in groups of two to five, many of them, a
  hex of ground between any two groups so no straight path crosses, two or three ponds of two
  to four hexes, scrub at the mesas' feet). And Open Steppe, the baseline, clear but never bare
  (a crag of one or two hexes at most for every seven hexes of wall, a pond at most for every
  ten, scrub in belts over about a sixth of the field, grass on the open ground). A battle that
  names no shape draws one by its seed, never by its domain. Every map guarantees the
  horde a crossing three hexes wide or more through its walls; the ground beside the rift (its
  mouth, where the packs land) and the gate, and the two rows before the gate, hold no water and
  no wall; every other row is the shape's, the rift's own included. Height is landscape and a look
  alone; no rule reads it: the field is level but for the badlands' mesas on their shoulders and the
  steppe's one rise, at most two steps and never a lone raised hex, and the scenery past the
  edges rises to three.
- **Moving**: a machine's move is a count of hexes, each step one hex, and a chassis has one
  way of moving (tracked, walker, wheeled, hover or flyer), which is its look and its footfall
  and never a rule of its own. Open ground (plain, road), rough and ruins are ground to
  everyone. Water: a ground machine wades it, a water hex costing two of its move, and it can
  always enter one with whatever move it has left; a hovercraft and a flyer cross it at one.
  Walls stop all but a flyer. Nobody stops on another unit's hex, and nothing else blocks a
  move: every unit passes every other, a machine through a machine or a pack and a pack through
  a machine, as under a flyer (they slide under each other, from two different dimensional
  counts), and the two sides meet only in a fight. Each move still lands at once, so the next is
  planned from where it ended.
- **Setup**: up to four machines on the row before the gate; the boss one row below the rift,
  sealed (below); and on the field, the siege under way, the compositions the tier and the ramp
  put there: the ramp's count of formations (one; two from Convergence 3; three from 8) spread
  across the width, each a move of its own from the row before the wall, and its count of
  patrols (two; one from 8) on the flanks two moves out, none on the rift's row (a pack
  whose opening hex the shape took goes along its row, never back toward the rift), each the
  tier's compositions in turn, the lead's and the guest's in turn with the lead's first, each
  as content writes it (the ramp scales no pack: it scales the field). Rift Pressure opens a
  turn short of its peak. No hunter stands on the field at turn one: the opening's patrols
  are the tier's that push, in their order, and the packs that hunt come with the tide and the
  tears (a tier whose patrols all hunt opens with them, each a row further back at a time,
  never onto the rift's row, until no machine stands inside its catch). So no battle opens on a
  forced fight.
- **A turn**: the map shows every pack's coming walk, read from where the machines' plans end,
  and every pack's threat rating under the pack, four pips with one filled a machine it is
  intended for, and no count; no ring is drawn round a hunter: it wears a chip, the attack mark
  and a small picture of the machine it comes for, as that machine wears a tag with the
  hunter's. Every walk's end hex is lit, tinted under a border of dashes crawling round it,
  tapped or not; where the pack attacks from that hex this turn (a pusher striking the wall, a
  hunter catching its prey), the warning stands on it, as the plan stands, and no tag says so;
  a pusher with nowhere beside the wall to land that turn stays where it is under a BLOCKED tag. A tapped pack
  shows its whole way as the field stands, past this turn's walk to its goal, dashed, each later
  turn's stop numbered, and the thing it comes for under a crawling border with the attack mark
  on it (a sword in the reticle's turning ring, one mark for both): a pusher's piece of the
  wall, a hunter's machine; no other pack's whole way shows, a selected machine's hunters'
  included. Each machine has one action (the Dingo two): one move,
  in one go, then it may fight; a fight ends the action however it ends, and the board under the
  map says what each can still do. A selected machine lights the hexes its move reaches, one
  border round the whole reach, and brackets the packs it could be ordered onto. A move is
  planned: its route shows from where the machine stands, and the next move or order reads from
  the route's end. An order can be given again: a machine with a move planned or an order
  waiting shows, in hand, its reach from where it started, and a new move or order there
  replaces the old one; a tap on it in hand takes its order back, and a tap on it with none lets
  it go. A machine it carried that has since been given an order of its own, or one whose
  starting hex another now plans to stand on, is taken back by UNDO alone. The one button reads
  ENGAGE while a fight is ready (a catch, or a machine ordered onto a pack), ENGAGE 1 OF N while
  N fights wait, each numbered on the map in the order ENGAGE opens them (a catch first, then
  the packs in the order their orders were given), else EXECUTE while planned moves wait, else
  END TURN; back from a fight with more waiting, the orders stand and the button pulses. EXECUTE plays every planned move and the turn goes on, so moves play in
  whatever sequence the player gives them; ENGAGE plays them first too (the boss's fight aside,
  below), then the fight opens. UNDO takes back the last move or order, whoever made it, in the
  order they were made, a move that has played included (the machine goes back where it
  stood), back to the turn's start or the last fight. A caught machine's fights come first, one a
  hunter, and the map draws each as the machine's order onto the hunter that caught it. END TURN asks first
  while a machine can still move or fight; then the turn ends: packs walk and strike; Rift
  Pressure rises one. Nothing returns on the map: the shield is full as every fight opens. Once every
  machine has fought, is ordered, is caught, or can neither move nor reach a pack where it
  stands, the button pulses, whichever it reads.
- **A tap and a double-tap** on the map work as a die's do in a fight: a double-tap on a
  machine or a pack opens its codex, and a tap on one lands only once the double-tap window
  (0.15 s, from the tap's release to a second touch) has passed with no second touch, its hex
  bracketed from the touch until it does, so a double-tap never selects first; a tap on bare
  ground lands at once.
- **The readout**: holding or tapping a machine, a pack, the boss or the ground shows
  it in the strip under the map, as the fight's holds read: a machine's hull as a gauge (its
  shield is the fight's), its move and actions left, a chip for its damaged components; a pack's
  threat rating first ("A fight for three"), then its members (each foe type and its count),
  move, what it is doing, and when its whole way gets there as the field stands
  (at the wall, or catching what it comes for, this turn or in so many), and SEALED on the boss
  while its seal holds; the ground by
  its name (a wall by what it is): who crosses it, who wades it and who cannot, and whether
  packs enter it. A refused order
  says what stopped it there too.
- **Orders**: a tap or drag onto a pack plans the machine's move to the farthest hex in attack
  range its move reaches (or leaves it, if in range) and orders it, one step for UNDO; a
  second tap on the pack takes the order back. ENGAGE opens one fight at a time: the first
  order's pack and every machine ordered onto it.
- **A fight** is one pack: nothing joins it and it joins nothing; a hunter's
  catch is a fight a hunter, one hunter a machine. The machines whose engage range covers
  it (1: beside it, the one range everyone on the map has) may join. Orders onto several packs queue, ENGAGE opening them one at a
  time, a catch first; the order changes nothing a fight opens on, its dice included: a fight's
  seed is the battle's seed, the turn, its packs and its machines. Afterwards each machine in it has used its action, a wreck stays on its hex and blocks it for the battle (not built: today
  it leaves), a pack keeps only its survivors, by member, and Rift Pressure does not tick: it
  ticks on the map alone.
- **Packs**: a pack is a composition on one hex: its members, each a foe type times a
  strength, in content order, the lead first, whose sprite the pack wears; a hold lists them. It
  hunts when its composition says so (its caveat, Content conventions), never by its foes; else it
  pushes. A composition is a patrol (a flanker alone, a duel for one machine; a pair of them,
  or a hunting pack, a fight for two), a formation (the body's, a fight for three, which
  pushes), an elite (an elite leading its own) or a boss's escort. A rank-and-file unit is
  made for one role, a pusher's unless its entry says a hunter's or a flanker's: a formation
  fields pushers, a patrol that pushes fields flankers, and a pack that hunts is led by a
  hunter and holds only what keeps its pace and flies if it does; a unit standing outside its
  role is a crossing its composition gives a reason for. Every member unpacks into
  the fight, and the survivors come back by member. A composition may name its lead, which then
  stands first; its grid is where each stands (Content conventions). Each pack carries its threat rating, the machines it is intended
  for: its composition's own, else a patrol 1, a formation 3, an elite and an escort 4, a pack
  of no composition 3, the boss's unit 4. A pack walks at its slowest member's pace,
  winged only when every member is. They cross every land hex and wade water as a
  ground machine does, a water hex costing two of their move (entered with whatever is left),
  and never enter walls; a winged pack (the Cockatrice, the Ghost, the Bone Wyvern, the Bomb,
  the Drake, and their lines' recolours) crosses both as a flyer does and may stand there;
  moves 2 (fast 3, the Dire Wolf's line 4, massive 1). No foe and no pack carries a ring: a
  hunter catches a machine beside where its walk ends, at the engage range everyone on the map
  shares (1). They walk through every other unit, never ending a walk on another unit's hex, so
  nobody holds ground against them and a pusher never turns back for a machine in its way; the
  walk shown is the walk played. The
  enemy never attacks a machine on the map: pushers strike the gate, hunters catch.
- **Pushers** make for the wall at a segment of their own: as a pusher is dealt it draws a wall
  column about the wall nearest it, from the turn and the pack: a pack the rift sends about the
  rift's column within the ramp's spread (2 at Convergence 0, half the wall's length at 12), any
  other (a flank patrol, a formation the opening places, a tear's patrol) about its own column
  within 2; of those columns the least crowded wins (another pusher's segment counting 2, one
  beside it 1), then the nearest the draw. It walks to the land hex of the row before the wall
  nearest that column, a tie toward the gate's column; a pack with no segment (a hunter left
  without prey) walks to the nearest. A pusher ending its walk beside any hex
  of the gate or the wall strikes the gate's bar for its threat rating's worth, 10 a pip (a patrol 10, a
  formation 30, an elite 40), every enemy turn, whatever its head count. A pack a fight has worn strikes
  by the share still standing: its rating's strike times the heads it holds over the heads it took the
  field with, rounded down, at least 1; grown past that count, its rating and no more. The gate is the look
  and the bar's name; the whole wall is the target, so no line plugs it.
- **Hunters** (the packs whose composition hunts) lock one machine when they appear, by its caveat (nearest, weakest, strongest, slowest or fastest; never
  the Prairie Dog, never a machine another hunter already hunts), keep it while it stands, and
  walk to stand beside it; a hunter that finds every machine hunted pushes for the wall
  as a pusher does until one is free, and turns on it then (the log says so). One hunter a
  machine, so a machine is never caught twice at once. The machine a
  hunter comes for wears a tag by it, a plate a hunter with the hunter's picture and a target,
  and the board says HUNTED BY. A hunter with what it comes for beside it at the start of the
  player's turn has caught it: that fight comes first and is fought to its end, the caught
  machine cannot move first, others in range may join; another hunter's catch (of another
  machine) is a fight of its own after it. Its prey is the only machine it catches, however near
  the others stand: short of it, it walks as near as it gets. A prey no hex beside can be stood
  on (every one a wall, water a ground pack cannot stand in, or another unit's) is not caught
  that turn, which is a screen the player paid for with those units' places; nothing stands in
  for it.
- **The carry** (the Swallowtail's Muster Deck): the machines on the hexes beside
  it are lifted in place when it moves and travel as a ring round it, so they never block its
  way; it lands them as a block, each where it rode from the carrier, keeping their action, and
  their move if they have not moved. A stop where a rider would land on a hex it cannot stand on (off the field,
  a structure, ground it cannot take, another unit) is no move: the drawn route marks the stop
  and that hex (NO ROOM), and letting go there is refused. A caught machine does not ride. An
  undo of the carrier's move takes the riders back with it.
- **The boss** patrols within two hexes of the rift, a hex a turn whoever commands it. Its seal
  holds until the Rupture (below): while it does, the boss cannot be ordered onto and joins no
  fight, SEALED on its readout. After the Rupture it can be attacked, nothing joining its
  fight and it joining no other (a hero carries no move and no hunt of its own: it only ever
  commands the boss unit); its fight won wins the battle: the fight ends in victory
  only when no foe stands or waits, so its escort falls with it, and a team wrecked after the
  commander falls has lost the battle (the whole escort must die, else the
  smallest boss, a final's hero, gets cheaper still). Its fight takes every machine, wherever
  it stands and whether or not it has fought this turn; nothing moves first (ENGAGE goes
  straight to the reveal), and it ends the battle. The unit at the rift commands
  it: the lead domain's boss, a final's hero with its escort (one for each other column), or
  the finale's line; it stands while one of its commanders does and holds the rift whatever
  its escort. It stands at the battle's tier (the tiers as the quick campaign shows them, one
  to three: in the campaign tier two runs from Convergence 4 and tier three from 8, and the
  finale at 12 takes tier three's numbers): its commanders' HP ×1.25 at tier two and
  ×1.5 at tier three, their attack +1 and +2, a boss whose kit is armour its `armour_step` more
  armour a tier above one (the Cinder Tortoise 1, 2 and 3). Its escort is curated, never grown by
  the tier: its domain's `escort` composition at the battle's tier, one that names the boss first
  and then one that names none, as content writes it, validated to fit the slots beside its
  commanders; with none written it stands alone. A final's wildlife, which no composition names
  yet, is three of its domain's units at the tier, round robin in content order and never
  massive; a named escort is kept as named. Every domain boss has its own at tiers two and three
  and stands alone at tier one but the King Gel, whose court of Gels comes at every tier for its
  merge. The rank and file never scale in place: a tier's units are their own,
  each with its numbers and its name (a recolour: a base type in a new hue under a new name, with
  a twist). A domain's compositions are by tier, the battle's tier choosing them and a guest's by
  the same tier; a tier with none takes the highest under it.
- **Rift Pressure** fills at the ramp's beat (3 turns, 2 from Convergence 8; +1 each enemy turn,
  never inside a fight), a turn short of its peak as the battle opens. When it fills it resets and peaks: the rift
  sends the next composition of its cycle (the tier's formations and patrols in turn, the
  lead's and the guest's in turn); every tear open before this peak sends the next patrol of
  the patrol cycle; the seam creeps two rows toward the gate (as far as the row before the
  wall); the ramp's count of tears (one; two from Convergence 8) open on the seam's row, each
  on a free land hex with no unit on it and no machine beside it, the farthest from the rift
  and the other tears, so the mouths spread across the width; and the interval shortens by the
  ramp's step (zero today, never below 1). At the Rupture the beat halves once, never below
  one; nothing re-seals. A tear opens a peak before it first sends, so where
  the next flood comes from is known an interval ahead; tears stay open and never close. A
  spawn lands on the nearest free hex to its mouth with no machine beside it, so it and its
  walk are seen for a whole turn and nothing appears on top of a detachment. Packs never
  escalate in place.
- **The seam** is the flattening's edge: the row the rift's bleed reaches, at the start a row for
  every five of the field's depth and one more (row 4 at twelve deep, 5 at twenty). It is the clock's picture,
  and it shows where the tears can open: the painting's edge stands on it, the seam's own row
  the painting's front row and the row past it solid ground. No rule reads the flattened hexes.
- **A peak is shown** once the packs have walked: the map keeps the seam where it stood and the
  new tears unseen through the walks, then glides to the seam, whose edge sweeps to its new row
  under a bright front with its name on it, then in on each new tear, zoomed, as it bursts open,
  and back to where the player was looking at the zoom they had. Nothing on the screen takes
  a touch while the map plays one of these, and nothing skips it.
- **A hunter's lock is shown** after it: for every hunter that turned on a machine this turn,
  in turn, the map glides in on the hunter, zoomed, and the band says HUNTED and who turns on
  whom; then back to the player's view. A catch's band follows.
- **Caches** (the field's loot; `content/loot.json`): the field holds its caches from the first
  turn, so many seeded with the map, one in each of as many bands along the wall, in the rows
  from the third past the rift's to the second short of the apron (never that close to the
  wall), on open ground with no unit on it and none beside another; each a kind (a Derelict, a
  Carcass, a Relic: working names) by its weight at its depth, the better kinds likelier the
  farther from the wall it lies: lesser loot near and safe, better far and under the tide. The
  seam does nothing to a cache. A machine standing on a cache as the player's turn ends, or as
  the battle is won, claims it (a move ending on one; claimed at the turn's end, so an undo never
  shows what it holds): it holds its kind's salvage (a range), so many components of the
  battle's tier, and on its kind's chance (the Relic's) a blueprint of that tier the run holds
  none of, drawn from the battle's seed and the cache. A tap on a cache shows its kind and its
  likely contents, never the contents. On the map a cache is its kind's model while its hex is
  the reconstruction's (a wrecked machine, a skeleton of theirs, splinters of their stone round a
  lit core that turns) and a flat token where the painting has taken the hex, crossing over as
  the ground does; over it in both worlds a chest on a plate, which says how good it is by what
  it is made of (a bare chest, a strapped one with a lock, a solid treasure chest with a glint
  on a doubled plate) and carries no name. A machine standing on one hides the model and dims the chest. The campaign banks what was claimed as it banks the
  kills: on a battle won or held, never on a fall; each component one copy in the stores, each
  blueprint the run's.
- **Menace** is a foe's weight: its heaviest blow plus a quarter of its HP, rounded up, an
  elite's doubled. The Rupture meter, Anathema and salvage count kills by it, so the rift's
  reinforcements pay a trickle and the formations and the elites pay the most.
- **The Rupture meter** fills by the menace of every foe killed, in any fight however it ended,
  tallied as each fight ends, toward the tier's Fractures (three at tier one, four at tier two,
  five at tier three). The thresholds are set from the field's menace at the start (the packs
  placed, the boss aside) and the first compositions the rift will send, as many as the tier's
  Fractures, in the cycle's order: the last at two thirds of it, the steps 1, 1.5, 2, 2.5 and 3, so
  later Fractures cost more and a battle that kills the field as it stood earns the Rupture
  with a third of the field left to leave. A Fracture pays out as a fight ends, announced over
  the map (FRACTURE with its count and what it brings, the last THE RUPTURE); an elite it
  brings is unseen until the map has glided in on its hex, zoomed, then bursts out under the
  band, which names it. At the Fractures
  the tier names (tier one's first; tier two's first and third; tier three's first, second and
  fourth) the lead domain's next own elite composition not yet sent this battle emerges at the
  rift, or a wanderer (`wanders`: Gilgamesh, the Reaper, the Wild Hunt, the World Eater, the
  Shuffler and the Astromancer, each one composition in one domain's list and every domain's), drawn on the
  Fracture's roll one time in three in place of the domain's own and always once its own are
  spent, the same roll picking which among those not yet sent, so every domain may meet them,
  none waits on them and nobody learns an order. An elite
  may come again in a later battle, never twice in one; a run never repeats a boss. Every elite
  stands at the battle's tier as a boss does, its HP and attack the tier's, the other members of
  its composition at their own. The last Fracture is the Rupture:
  the boss's seal breaks. The stall guard breaks it too, when no pack but the boss's stands as
  a fight ends, so a team that cleared the field never waits on the clock. Rift Pressure keeps
  running after. A Fracture brings no prize (not built).
- **The battle ends** when the gate reaches zero, every machine is wrecked, or the boss unit
  falls (every commander of the unit at the rift, its fight won); a wipe after the commander's
  fall is a wipe.
- Not built: city defences (wall segment upgrades, when they come), the Fracture's prize, rift tiles.

## The campaign

Headless only (`sim/campaign.gd`); no screen drives a run yet.

- **Cities**: the capital (the Council and the Arsenal) and four around it, one for each city
  maker. A city's gate is 200, the capital's 300. The capital's gate is the run's life: the
  run is lost at zero.
- **Start**: a tender of one tier-one machine from each city maker (by seed, in stock
  loadout; a chassis whose passive or locked piece is still planned is not dealt, so a maker
  whose only tier one is a draft offers nothing until it lands); the player takes three. Four squad slots, 0 salvage, 100 Favour, a blueprint for
  every basic, the eight of tier zero.
- **A turn** is one battle at a front, with one to four ready machines, or a pass; once the
  finale is due no turn is passed (the Council demands the capital fought now), so the
  Convergence never runs past the finale's. The whole
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
  are three of the slate's own; the massive foes that stood in for them stand in its ranks, each
  with a line of recolours at tiers two and three (its third move back as their twist), the
  Marsh with a massive line of its own (the Barrow Giant's), and the Bone Wyvern among the
  Marsh's elites.
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
harness's Quick campaign). The campaign's rules hold where this part says nothing, and it
follows the main content and code: every fight is one pack dealt as a battle deals it (its
grid and its lead), a boss's the battle's boss unit,
and nothing scales a pack.

- **Start**: three different tier-one chassis, picked freely from every one the engine can
  field, in their stock. Four squad slots, the fourth filled by an offer's chassis. The party is
  dealt as in the campaign. The six basics are free and without limit.
- **Battles**: twelve, a tier every four, then the finale. Each is fought against a lead domain
  drawn at random and, from tier two, a guest. Its fights before the boss are as many as the
  Rupture's Fractures at its tier (three, four, five), and one, two and three of them are
  elites: a formation first, then elites and formations in turn, the elites left over at the
  end. Then the boss's fight, the campaign's boss unit at the tier's numbers with its own escort
  (alone with none; no formation beside it, one pack being one fight): one of the lead's bosses
  its battles have not ended on this run, or from tier two its final, its dealt hero with three of
  its domain's units at the tier, drawn as one more boss while that hero stands; once all are beaten, any of its bosses again. The finale's last
  fight is the party's line, every domain's dealt hero promoted, a domain
  whose final was won leaving its column to a standing domain's boss, as in the campaign.
- **A formation** is one of the domain's formation compositions at the battle's tier, in
  turn, as content writes it (the battle's number as the Convergence for the field); the
  lead's and the guest's take turns. **An elite**'s slot holds the lead's elite compositions in
  turn, or a wanderer on the run's roll (every domain has three of its own at least; a domain
  with none would take the lead's formation).
- **A fight** takes the squad's machines still standing, their damage carried, their heat from
  zero and their shields full; a wipe ends the run.
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
- A composition (`content/factions.json`) is one grid declaration: `front` and `back`, four
  cells each, left to right as it stands in a fight, each cell null for empty or a foe id; a
  front-rank foe in a front cell, a back-rank foe in a back cell, a massive foe in a front cell
  with the back cell behind it null (it fills its column), a core's parts each in a cell of its
  own beside it, once a core. The grid is the whole count: the pack on the map is what it holds,
  a variant with one more goblin is its own composition, and no cell lists alternatives. Four
  fields more, each optional: `squad`, the machines it is intended for, 1 to 4, its threat rating
  on the map (absent: a patrol 1, a formation 3, an elite and an escort 4); `lead`, a foe id in
  the grid whose sprite the pack wears, an elite composition's its elite (absent: the first in
  reading order, front left to right, then back); `hunts`, the caveat its pack hunts by
  (nearest, weakest, strongest, slowest or fastest; absent: it pushes), never on an escort, which
  walks with its boss; a foe carries no hunt and no ring; `ramp`, `[lo, hi]`, the
  Convergences it is dealt at, both held (absent: every one): a battle, the quick campaign and the
  Fractures' elites deal only the compositions whose gate holds their ramp, and where a domain's
  compositions of a size at a tier (an escort's, of its boss) carry any, together they hold
  every Convergence that tier is fought at, from its first (0, 4 and 8 for tiers one to three)
  to 12, which the Convergence never passes (a turn cannot be passed once the finale is due).
  Every patrol and formation writes down the question it poses, `design.question`, internal
  like everything under `design`; and a foe's `role` (pusher, hunter or flanker; absent: a
  pusher's) is what the validator holds a patrol's and a formation's members to, a crossing
  saying why under `design.crossing`. No
  composition in content writes `ramp` yet.

## Known gaps between these rules and the code

- Jenny's foe-down lines are keyed by the retired families, so only the generic pool plays.
- A cache holds no module (the bible's loot row: modules too) until the campaign holds modules.
