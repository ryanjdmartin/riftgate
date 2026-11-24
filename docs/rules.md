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

- **Chassis**: hull, shield, heat maximum, armour, move, size class, one way of moving, hardpoints, fixed components, module
  slots (two; the Clydesdale three) and one passive. Twenty-seven chassis from five makers
  (`content/chassis.json`), one of them dealt by nothing yet (a chassis whose entry says
  `"status": "planned"`): the Swallowtail, back in design until its session hands it back. A
  run has four squad slots and starts with three machines.
- **The die**: one entry per component, fixed components first, then one per hardpoint in
  order. Each entry shows its place, from I, as a grey Roman numeral: top left on the die,
  beside its name in its readout, and down the codex. A piece a branch has upgraded wears a
  chevron under its place for each step taken on it, on the die and down the codex; a step on
  the passive alone marks no piece, and a destroyed piece shows none. An empty hardpoint is a blank entry; nothing fills it. A full,
  undamaged machine is reliable. A folded die (the Clydesdale's, below) rolls among some of
  its entries alone.
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
  modes, never keywords. A passive may make a piece count as
  a second kind on its machine (none does now): the die's readout shows the kind on the
  machine, the codex the piece as built. A rule over the pieces a machine aims at foes reads every weapon
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
  the Fovea Designator, the Hardlight Pulse), and only `melee` is read today: a blow
  lunges on screen when its weapon is melee and nothing about it crosses the field (no class
  built to fire, and no Ballistic, Missile or Beam); any other fires as a gun, a shotgun tagged melee and
  ballistic among them. A machine's gun shows its shot crossing the field, from its muzzle to
  what it fires at: a tracer for a direct shot, a lobbed arc for an indirect one, a beam held
  through the blow for a laser (the Beam tag). A foe's blow shows none.
  Melee means short range, a shotgun included, never only a blade.
- **Modules** sit inside the machine and are never spent: stat lines up or down (hull,
  shield, heat maximum, armour, move, cooling, shield regen) and at most one rule, tier 1
  to 3, run as one passive nothing on the die can remove. The same module twice stacks.
  Fitted in the harness and the quick campaign's hangar (not in the campaign yet). Catalogue:
  `content/modules.json`.
- **Tiers and blueprints**: every component that is not fixed carries its tier, one to three, and
  a chassis stocks components up to its own tier at tiers one and two, a tier three to tier two,
  so a tier-three component is only ever found. A **basic** is a tier-one piece with a flag, what
  comes off the assembly line: a run starts with every basic's blueprint, and a basic is never a
  find. A tier-one chassis may stock found tier-one pieces beside its basics. Blueprints of every
  piece but the basics are found; a bought chassis brings one copy of each component it
  stocks, never its blueprint. A fixed component has no tier; the Arsenal (the capital's
  maker) makes no basics and fields no tier-one chassis, though its tier-one components exist
  and its tier-two chassis stock them. The basic kit is six pieces, each a maker's: four
  guns, the Twin Autoguns and the Rivet Gun dealing 3 for 4 heat, Direct, the Ankle Mortar 3 for
  5, Indirect (a point of heat over Direct), and the Laser Carbine, Direct and warm, 4 for 5, and two defensive pieces, each spent on itself or an ally (the
  Halo Projector, a Barrier, cooldown 1; the Shoring Jack, Armoured 2 until its side's next turn).
- **A machine's tier**: one to three. A machine arrives at its chassis's tier, as stocked, and is
  bought up a tier at a time between battles (the campaign's hangar, for salvage; the quick
  campaign's, at no price), a tier opening as the Convergence reaches that tier's rifts. An
  upgrade lifts the whole machine and carries its branch's pick as the choice where its chassis
  has branches. The lift is a passive of its own on the machine, a tier at a time, never a write
  to a stat or a piece: its stat lines rise, and its plate in the codex says its tier. A locked
  piece's number does not rise with the tier: it grows by the branch's steps or by the kit beside
  it, and a piece that needs a number of its own a tier is a call for its chassis. Every chassis
  takes one standard lift for now (`tier_lift` in `content/chassis.json`). A machine keeps its tier and its picks,
  a wreck included.
- **Branches** (an upgrade's picks; the harness fields them too): a chassis of tier one or two may carry two directions,
  each a step a pick, as deep as its machine picks, a tier one twice and a tier two once. A
  machine's first pick takes a direction's first step and its second the same direction's
  deeper step or the other's first, so a tier one ends specialized or mixed. A step tweaks the
  machine's locked pieces or its passive, as many as it needs, never a stat: its effects ride the
  machine as a passive of their own, each scoped to its piece where it names one, so the die keeps the piece as
  printed and the entry as spent carries the tweak, and a destroyed piece takes its tweaks with
  it. A step on the passive takes over the effect it names in place: an effect that names a
  slot gives way to a later grant in the same slot, so the step's number or form replaces the
  passive's own rather than adding to it. The codex says each step taken on its piece's row,
  or the passive's, its direction's name and numeral first (DEFENCE I). The Storm Petrel's are
  the first, on its Hardlight Pulse: Defence, a Ward on itself and its Hardened Light held up to
  4, then Spread with a stack for each foe hit, up to 5; Striker, Chain 2 and Charged 1 on
  itself, then Chain 3 and Charged 2. The Buzzard's, a tier two's single pick: Sustain, on its
  passive, its zap adding 3 for the same 2 shield and every foe that falls laying Regenerating 2
  on it in place of the 2 shield; Burst, on its Shield-burner Cannon, Spread 2 and Penetrate 2 and
  its own number 2 higher. The Macaque's, a tier one's, each touch its offhand's forms (a form
  a step names takes its slot's place in the cycle) and its second steps its Aile Booster too:
  Duelist, the Beam Sword's slot holding the Beam Saber, then the shield's the Beam Buckler and the
  Booster granting Aile Blitz; Valkyrie, the rifle's slot holding the Beam Bazooka, then the shield's
  the Beam Pavise and the Booster granting Aile Assault with 1 Empowered. A step may name the piece
  it upgrades, and the die's readout and the codex call the piece so (the Aile Blitzer, the Aile
  Assaulter), the die keeping the piece as printed. A step may remake a piece whole, its entry
  as spent, read and shown the new one under the step's name, the die keeping it as printed;
  a grant may hold once a round, the first spend that takes it spending it until the next round
  opens; and a step may have its machine's weapon strikes count a status more. The Honey
  Badger's, a tier one's: Miner, its Chainsaw Claw gaining Penetrate 2, Ore max +1 and a point of
  armour for each Ore past three, then Brittle 2 on the Claw, its first spend each turn Instant
  (two uses a turn, the second if the die finds it again) and Ore max +2; Smelter, its Bullion
  Fragmenter gaining Spread 2 and Ore max +1, then Ablate 1 and Ore max +3. The Prairie Dog's,
  a tier one's: Flakker, the first strike of its weapons on a Brittle foe each turn Rapid, then
  its Flakshot Spreader remade as the Flakshot Disperser (Indirect, Brittle 4, Spread,
  Penetrate); Harrier, its weapon strikes counting Brittle twice, then the Spreader remade as the
  Flakshot Repeater (Direct, 1 three times, Brittle 1, Spread 1). Neither form keeps the
  Spreader's cooldown. The Echidna's, a tier one's: Spiker, its Supersonic Spike Tether as the
  Hypersonic Spike Tether, Instant at a heat more, then its Sonic Needles taking a point a stack
  off the attacks of the foe they are in; Chaos, its needles' bolt leaving its foe one stack in
  place of none, then its weapons dealing 1 more to a foe for each stack of Sonic Needle in it.
  A direction may be back in design, a planned draft: kept in content, its depth unchecked, and
  never offered (the Mole's two since its move to tier two).
- **No recovery on the die**: a component is a weapon or equipment. No stock die holds a
  shield or a vent and no slottable one is dealt: no chassis regains shield or cools by
  itself, both gauges come back by a reboot (The reboot, below), and the decision heat leaves
  is the hold or the reboot (fire the cold entry, keep the hot one, or give the turn and come
  back cold and whole). The slottable shields and vents of tiers zero
  and one are retired; the three of tier two are kept in content as drafts nothing deals (no
  blueprint, no loot, no basic) until a kit wants one; the engine still runs both kinds, for the
  locked pieces that are one (the Musk Ox's Quick Reload, the Sutler's Hoist) and the machines
  back in design. No piece grants a cooling or a shield regen today; the engine keeps both, the
  reboot's rulings on a granted one standing (The reboot, below).
- **Damage states**: a component is intact or destroyed, for the whole battle (none is destroyed
  until a foe carries the rider that does it: Destroy, below).

## The skirmish

### Formation
- Foes stand in two ranks of four columns, front and back. A massive foe (size 2) fills a
  whole column, both its slots, and counts as front rank for reach: always in reach, never
  exposing its column, nothing behind it. A back-rank area at its
  column meets it as one in the front does, and a blow meets it once however many of its slots
  it reaches, so its own column adds nothing to a Penetrate aimed at it.
- A pack is what its fight's slots hold: nothing waits behind the formation and nothing steps in
  once the fight begins. Every composition fits its slots (Content conventions) and every fight
  holds one pack, a boss's with its escort, so no fight is given more than its slots hold.
- At the start, a pack stands as its composition's grid has it; a boss's fight and a final,
  which carry no grid, take their ranks heaviest hitters first from the left (its heaviest
  move's damage times strikes; ties in arrival order).
- The squad stands in four spots across the floor, one under each of the foes' columns: a squad
  of three from the left, a squad of one or two in the middle spots, the outer ones empty; a
  wrecked machine keeps its spot. A machine faces the column of its spot, and the foe in front of
  it is that column's front rank, then its back; with neither standing, the next column left,
  then right, then two left, two right. The Photosphere Lance lays its Sapped there.
- A pack is its composition's grid (Content conventions): the count the map shows is the count the
  grid holds. Its fight, holding it alone, stands its foes as the grid has them: each cell, front
  then back, left to right, a foe of its kind, a massive one filling its column; a cell that
  names none stands empty.

### The round
1. Rerolls reset to two (less any a foe drained). The machines' turn starts: a
   machine's Armoured, its Barrier and its Ward go, its Brittle halves, and an Exposed whose
   round is past falls (When a status ends, below). A machine that gave its last turn to a
   reboot recovers: its heat nothing, its shield whole. Every machine sheds what cooling it is
   granted, then regains what shield regen it is granted, up to its maximum (a module's, a
   passive's or a status's: a chassis has neither of its own; a shield gain like any). Every die rolls;
   entries are equally likely.
2. Every foe picks its move, then its target; both show, exact, before the player acts, its
   intent plate above it: the move's kind, its blow's number and strikes, and each rider by its
   mark, a numbered one with its stacks. A blow's number counts the rallies on their way to it
   this round (Empowered, below).
3. The player's turn: spend, lock and reroll in any order. Each spend resolves fully before
   the next. UNDO takes back the last spend or reroll, in the order made, back to the last
   roll, its floor: the round's roll, a reroll that draws, or a spend that draws inside itself
   (Rapid's or Instant's reroll); a stepping die's step draws nothing,
   so it is taken back like a spend, and so does a roll that can land only one way (an Instant
   roll among one entry, a raging Nemesis's fists; a Rapid reroll with one other entry to go to). The trail shows a bar at every roll, every line of it at
   full strength, and UNDO's badge says how many spends it reaches; UNDO opens once a spend's
   last blow has played. END TURN sits bottom-left and UNDO bottom-right, and UNDO reads on or
   off by its edge, a heavy solid one or a faint dashed one. END TURN pulses once no
   die has anywhere to be spent, rerolls aside. A machine that has spent nothing this turn may
   give the turn to a reboot, its die dragged onto REBOOT between the two (The reboot, below).
4. END TURN, the machines' turn's end: a machine's Ablating takes a point a stack, its shield
   first and then its hull past armour, and loses a stack; its Regenerating then pays a point
   of shield a stack and loses one; its Scorched and its Sapped go;
   then heat over a machine's maximum burns hull one for one and stays on the gauge, burning
   again every turn it stands there; the first such turn since the machine's last reboot is
   its overheat, and its shield breaks; then each machine's Empowered halves, and a dark entry
   whose rounds are done lights again (a cooldown). A rebooting machine has vented as
   its shield dropped, so it carries nothing to burn, and no rule spares it. One out of reach
   (Phased, Swallowed) neither burns nor overheats, its heat staying for the turn it is back: a Phased
   machine's stacks tick all the same and take nothing, and everything a Swallowed one carries
   waits. A machine the tick or the burn wrecks is lost on its own turn, before the enemy acts.
5. The enemy's turn (below). It starts with every foe's Armoured, Barrier and Ward going, its
   Brittle halving and its Exposed falling once its round is past; each foe's own turn then
   ends with its ticks, its action done or lost.
6. The round's end: round-timed effects end (Phased and the wait for it, Essence Flare, a
   swallow's and a golden rage's rounds), a web on a foe bursts (the Web Bomb, below), and a
   machine whose own attack killed in the round fires what its passive grants for it (the
   Ammit's flare). Nothing ticks or halves here.
7. A part due to grow back does, in its corpse's slot (below). Next round.

The fight ends the moment it is decided, mid-turn too: victory when no foe stands, defeat when
every machine is wrecked. There is no round limit.

### When a status ends
A status decays, ticks or falls off in one of four places. A machine's turn is the player's
turn: it starts as the round opens and ends at END TURN. A foe's turn starts as the foes' turn
opens, after END TURN and before the first of them acts, and ends as its own action does,
landed, lost to a stun or skipped.
- **Its turn starts**: Armoured, a Barrier and a Ward go, every stack; Brittle halves, rounded
  down; Exposed falls, at the turn start after the next one.
- **Its turn ends**: Ablating and Vitriol take their points and lose a stack; Regenerating
  pays after them and loses one; Empowered halves, rounded down; Scorched and Sapped go; a
  cooldown whose rounds are done lights again; a Suppress is spent with the turn it
  cost; Numbed loses a stack, or lands on a foe that lost this turn to a stun.
- **The round ends**: Phased is granted or lost, Essence Flare goes, a swallow's and a
  golden rage's rounds run, and a web bursts.
- **It is spent**: the primers by a weapon fired, Spun Up, the Juggernaut Drive, the Aile buffs
  and a Parry's return by the next weapon, Shocked and Cryo by the weapon's hit that cashes them,
  Undying by its fall, a Mine by its foe's fall, a pin by the decay it stops, and a foe's jam by
  its machine's reboot.
What works in the other side's turn ends as its own turn starts, and what works in its own
turn ends with it. So a stack gained outside its carrier's turn stands whole for its next
one, and a chip always shows what the next blows will meet. On a Phased machine every clock
runs and nothing damages it; on a Swallowed one none runs but the swallow's.

### Dice
- **Rerolls**: two a round for the team, never banked (Maverick's Playbook, the Giant
  Petrel's passive, below, the one exception). A reroll of one die alone spends that machine's
  own free reroll first, where it has one left (the Trim Tabs module: one a round, on top of
  the team's). A reroll rerolls every unlocked,
  unspent die, before or after attacking, and lands on any other entry, never the one
  showing; a copy of it may come up, at the odds its copies give it. Every roll inside the round
  follows the same rule (Rapid's free reroll, the Booster, the Uplink, the
  Reveille Horn), but Instant's, kept on purpose and shown on the die by its keyword: it rolls as
  the round's opening roll does, itself included, and spins every chamber on the Cassowary's
  die. Hold a die to lock it, and again to unlock it; spending
  unlocks it; locks clear each round. A double-tap shows the whole die, its loadout, every entry at its
  live numbers, the one showing marked.
- **A folded die** (the Clydesdale's Disappearing Carriages): its hardpoints are two batteries
  of four, one up at a time, and every roll and reroll lands among the battery up and its fixed
  pieces, the Changeover live on both. The Changeover (Rapid, spent on itself) turns
  the die to its other battery, and Rapid's free roll lands there, never on the Changeover, which
  Rapid darkens for the rest of the round, so it turns once a round. The second battery up is its Ability, Changed Over, kept from fight to
  fight through the battle and gone as the battle ends, so a battle opens on the first; no chip
  is the first. The codex dims the battery down; on the model the battery down is sunk in the
  hull under shut trapdoors, the battery up on the deck, and each battery's components take its
  own mounts in order, so one that shows nowhere leaves its own battery's mount bare.
- **A stepping die** (the Cassowary's): it never rolls. Each fight opens on a random entry,
  and every roll or reroll steps it to the next entry in order, Rapid's free reroll too; a
  lock holds it. The die shows its next entry in its passive box, its mark and the number it
  will show, and its readout and codex show its entries as a
  cylinder, in order (the one showing lit and an arrow to the next, in the readout). Its Spin-Up, Instant, spins the whole die, the
  entry showing included, the roll kept on purpose (Rerolls, above), so it may land on itself and
  be spent again. Every sixth weapon or equipment it aims at a foe in the fight counts double,
  its damage and the stacks it lays; the count shows as six cells under the heat bar, as a
  store's are, the sixth apart by its shape (a heavier border, a diamond set in it) and
  lit in the heat's colour when it is next, and a shield, a vent, a buff and a spin are no shots.
- **The Quick-turn Avionics Relay** (the Needletail's passive): each round it acts twice,
  once with a weapon and once with equipment (a buff or a debuff), in either order. Spending a
  weapon sends every weapon on its die onto cooldown for the rest of the round, and spending
  equipment its equipment; then, while a lit entry of the other kind stands, its die flips to
  one and it acts again. One entry to flip to is no draw: the die shows it in its passive box
  beforehand, and an undo reaches past the flip; several are a draw among them. With none lit
  its die is done, and a spend that is neither kind (a blank) ends it. Its rolls and rerolls
  land anywhere on the die, a dark entry doing nothing, as any die's. A Rapid or Instant spend
  sends nothing onto cooldown but what its own rule darkens (Rapid its entry), so its kind
  stays lit and it acts again by its own rule, none of its spends. With one spend made at most
  it may reboot (The reboot, below), whatever its die shows, a die left with nothing lit to
  flip to included, its reboot turn keeping what it spent, and the vent takes that heat with
  the rest; with both spent it may not. It is the machine's own rule and no keyword.
- **Maverick's Playbook** (the Giant Petrel's passive): the team's rerolls unspent as the
  player's turn ends are banked, up to three, and come back at the next round's start beside
  its two, spent like any reroll; a roar's cost comes off the whole. It banks while the
  Giant Petrel fights: wrecked by the next round's start, it carries nothing.
- **Spending**: aim a die at a target, its crosshair dragged from the die (the die stays in its
  tray, showing what it will deal there) and let go there: a weapon or a debuff onto a foe in reach, a shield, a
  vent or a buff onto a machine it may reach. Each die is spent once a round (Rapid and Instant excepted). A blank does
  nothing; an unspent die is lost. On screen a spend's hits and shots land one at a time, a beat
  apart, every one of them: each foe a hit reaches flashes, its gauge steps down to what the blow
  left and the blow's number rises off it, a hit on a foe an earlier one felled landing on it all
  the same; a foe the spend kills stands until the death check, after the spend's last
  blow, and a last act lands its damage on the machines as it is named. A new spend or the turn's end lands whatever
  is still waiting at once.
- **On a machine**: a shield adds its number up to the target's maximum; a vent removes its
  number in heat; a shield that cools spends two halves on one machine (the Sutler's Hoist:
  the cooling first, then the shield); a buff grants its status, so many stacks, through so many rounds, or with
  no rounds when the status runs down on its own (Empowered), waits for the weapon that spends
  it (Spun Up, a primer) or lasts the fight (Ricochet).
- **Passes heat** (a rule on a piece of equipment: the Puffin's Overdrive Injector): spent on an
  ally, it passes its machine's whole heat onto that ally, its overheat with it and past the
  ally's maximum too, through the heat path (what the ally does with heat gained answers it: the
  Storm Petrel's shield), and grants its status a stack for every step of heat printed on it,
  rounded down (Empowered 1 for every 2). Its machine's gauge is empty after it; heat it takes an
  ally past the maximum burns as the turn ends, and the ally's first such turn is its overheat.
  The die shows the stacks it would grant now and the heat beside them.
- **A debuff** is equipment aimed at a foe (a setter, a swap), spent on a foe in reach as a
  weapon is: its keywords are its whole effect, no effect adds damage to it (Empowered, Spun
  Up), no primer rides it, and its heat is paid as a weapon's. A debuff's entry is read as it is
  spent: the Cottonmouth's drum fires every weapon and equipment it aims at a foe as its shot of
  4, so a debuff through the drum is a weapon.
- **The die's face**: the kinds are Direct, Indirect, Equipment, Shield, Vent and the blank, and
  every entry reads one way. One main mark at the top says what it is and holds what it
  delivers: a weapon's sight holds a strike's blow, its strikes beside it (×4); equipment's gear
  holds what it grants or lays and no number (a buff's status with its stacks beside it, a
  debuff's first keyword that does something to a foe in content's order, or the star for a rule
  of its own; a reach, an area, Rapid and Instant stay on the edge, which never shows a thing twice); a
  shield its number in the shield's colour; a vent its number in heat's colour; a shield that
  cools (the Sutler's Hoist) both numbers in one mark; a reload
  (the Musk Ox's Quick Reload) its shells and the ammo it loads. Whom it reaches stands under
  the mark, the targeting slot: a line of fire, straight for Direct and lobbed for Indirect;
  for Every Foe the enemy's formation, both ranks lit, in square brackets; three
  hex cells for an entry spent on a machine, the middle its own, a lit one a machine it may be
  spent on, and for Every Ally and Every Other Ally the three cells under one low arch, the middle
  lit for the whole team and dark for every other ally. Its costs run along the foot (Costs, below) and its keywords
  down the edge. What the machine's passive adds sits in its passive box at the foot of the
  edge, never joined to the blow: the strikes a Ricochet adds after each shot (the Skua's), a
  stepping die's next entry by its mark and the
  number it will show (the Cassowary's), the shield a zap will pay by the shield's mark ("-2",
  the Buzzard's). The readout says each on a line of its own, headed by
  the same box. A dark entry does nothing, and the die shows its own face dimmed under a veil of
  stripes, a plate on its foot with the clock and its turns left (a cooldown, Rapid's own
  switch-off) or the reboot's mark, the stripes heavier and in the red-red (a foe's jam). How each
  mark is drawn is `tools/die_sheet.gd`'s sheet and the bible's section 6.

### Reach
- **Direct** reaches the front rank, a back-rank foe whose column's front slot is empty, and
  any foe carrying Exposed.
- **Indirect** reaches any foe, at no cost to its firer: area belongs to the keywords (the Howitzer
  and the Musk Ox's Shrapnel Recuperator carry Spread 1 and Penetrate 1 together; which other
  explosives carry which is open).
- **Every Foe** reaches any foe and lands on every foe in the fight, front rank and back, and
  none is its one target: a debuff's effects on each, a weapon's strike on each for its whole
  number, every foe through its own Brittle and armour. A weapon's strike is aimed at each, so a
  Shock on any of them is doubled and spent; with no primary target no Ricochet follows it, and
  no area keyword rides it. It is
  a targeting mode of its own: no passive turns it into Direct or Indirect. One gated special carries it, the Musk Ox's
  salvo, and one debuff, the Shift Whistle's lure (Minerva, tier
  three). A
  weapon reaches wide by Spread or Penetrate, or lands on every foe.
- Chain's arcs read no reach: they strike every foe on the field that conducts (a Shocked
  foe, or one carrying a Sonic Needle), front or back, whatever the gun's reach.
- A kill clears its slot at its spend's death check, so a hole in the front opens that
  column's back to Direct; what a kill brings back (a foe getting back up, a Gel's halves)
  stands once the spend is done (A spend's order, below), and otherwise the hole stays open:
  nothing steps into it after but a split's half, a summon, a part that grows back or a
  swap's foe.

### A blow
Every foe a strike reaches takes a blow of its own, read in one order:
1. The number: on the foe the strike is aimed at, the weapon's number; on every other
   foe its area reaches, the number of the shape it stands in (Spread's beside the target,
   Penetrate's in the other rank of its column). Then what the entry prints from its firer:
   what heat fired adds (Vents all), what shield fired adds (Fires the shield). A Chain's arc
   is its own blow, struck apart once the strike's have landed (Chain N, under Player keywords),
   its number flat: steps 1 and 2 give it nothing more.
2. The attacker's modifiers, on every blow of the strike: adds, then multiplies, then floors, a
   condition on the foe read on that foe (a status it carries, its rank). A zap's add is one of
   the adds, beside Empowered's (Passives, below).
3. The foe's own, flat first: what the entry reads off it (the hull it is missing on every
   blow, the stacks a consumer eats on it on its first blow) and its Brittle; then its multiplies
   (Shocked doubles a weapon's strike aimed at it, never a blow that only reaches it); then its
   armour comes off. A weapon's blow takes them whatever it deals, a 0 included; a debuff's
   blow stays nothing. Its riders land on every foe struck, after its
   weapon's hits (below).
- **The strike order**: a strike's blows are resolved in one order, the target's first, then
  Spread's left and then its right, then Penetrate's other rank, a twin slot's other half with
  its pair, then the Beam Rifle's foe to the right, then Chain's arcs, read once those have
  landed. It is the calculation's
  alone: the screen shows a strike's blows landing together, on its beat. What waits on a
  machine's next strike lands on its spend's first blow alone, its first strike's on its target,
  and on none of that strike's area (the Parry's return).
- **Riders land after the hits**: each hit's Cryo and Brittle gather on its own foe and land
  once its weapon's hits are done, an application a hit, so no hit of a single-target weapon
  cashes or feeds on what the weapon lays (a ×2 Cryo 1 leaves Cryo 2 and cools nothing; a ×3
  Brittle 1 lands 5, 5 and 5 and leaves Brittle 3). Every rider lands so, Ablate, Suppress, the Web Bomb's web, a
  passive's lays, Purge and a primer's rider with them, in the order the hits earned
  them; Shock, Expose, Lure and Disrupt land after the blow.
- **A spend's order**: a weapon (an area's and a reach over every foe included) lands its hits
  on its target, then every hit's riders, then the death check; then the spend ends, then what
  its kills bring back. Everything a hit does lands before the death check, on a foe it fells
  too (its riders, a Mine, a Shock, an Expose, a Lure's turn, a swap, a gather, a detonation,
  a shove after the strikes), so the
  preview shows the chips beside the skull and no trigger goes unfired; a spend that asks
  whether it killed (a kill trigger, the Spindrift Salvo's rerolls) reads its own death check. The death check
  clears a kill's slot; a foe getting back up and a split's arrivals stand only once the spend
  is done, in the slot their unit died in, wherever a swap moved it, so nothing the spend does meets them, and the preview shows a foe that will get back
  up or split with its return's chip in the skull's place. What a foe's tick fells comes back
  at once, once the Mines its falls set off have blown. The enemy's turn is sequenced as it
  happens: a foe strikes whole and its ticks come as its turn ends, so a foe its Ablating will
  fell strikes first, and its blow is counted; a wreck takes no more strikes. Its death check
  runs as each foe's action is done, and again on a foe its tick fells, so its last act lands,
  its parts fall, its machine is let go and its return stands before the next foe moves; and
  it ends the moment the fight is decided, the foes after the blow that wrecks the last machine
  doing nothing, their ticks included.
- **A kill**: a foe the death check clears that stays down. A foe getting back up and a split
  are none (a split's halves are kills of their own), nor a part, felled alone or taken with
  its core, since a core and its parts are one unit and only the core's fall counts, nor a
  Bomb's burst or a foe a merge takes in. Every kill trigger, the grudge and the battle's
  count of kills read it; menace reads the pack, not the kill (the battlefield's Menace).
- Every blow of a strike is read before any of them lands. A foe's own reads (the hull it is
  missing, the stacks it carries) are taken as its hit judges them,
  as the die is spent, before any strike lands.
- **A Mine** (the Lammergeier's Reverberant Payload, its passive): every weapon and equipment it
  aims at a foe leaves a Mine on that foe as a rider, before the death check, one a spend
  whatever its strikes (a reach over every foe's on the foe the die is dropped on): the passive's
  flat damage, 2, plain, and the spend's whole result on that foe, joining any Mine the foe
  carries, one Mine a foe: every status's stacks the hits aimed at it fired (each hit's, as its
  machine deepened and doubled them, a primer's rider and a passive's lays among them,
  a condition read as the die was spent), its Purge and Chain at every hit's number, the rest
  once each (Shock, Suppress, Expose, Disrupt), a gated keyword where its gate held.
  The numbered ones add up across the spends that feed it. Spread and Penetrate, Rapid, Instant
  and Lure stay with the spend, as does a rule written on one piece (ignores armour, a swap, a
  web, a spill behind), and what a hit reads off its foe for
  damage (missing hull, a consumer's stacks) means nothing to a flat Mine; each foe its blast
  meets takes it with its own defences (a Ward, its Numbed). When the foe falls, one
  that gets back up or splits included, a tick's fall and a part's too, the Mine blows once the
  death check has cleared the slots and before what the falls bring back stands: one blow of
  its damage on every foe round its slot (the slot's other half, the foes beside it in its rank
  and the other rank of its column; a massive foe's, the front-rank foes in the columns either
  side), each through its own Brittle, a Barrier and its armour, aimed at nobody
  so a Shock neither doubles it nor is spent; then Chain's number, flat, on every foe on the field
  that conducts, a foe the blast met among them, each a blow alone that no rider rides; then its
  keywords on each foe it met, felled or not, as a hit's riders land, Shock and
  Expose after its blow, Disrupt only in the player's turn. Several Mines due at one death check
  blow in strike order, front left to right, then the back, and a blast that fells a mined foe
  blows that one's Mine in turn. A blast set off in a spend is part of it, so what its falls
  bring back stands once the spend is done. A Mine moves with its foe (a swap) and goes into a
  merger with the foe a merge takes in; it is a mark the team laid, so a Ward turns it away, a
  foe's cleanse takes it and the Paradox counts it. Its chip shows its damage, its readout its
  keywords.
- Strikes are separate blows; each lands the number and carries the keywords. Heat is paid once a spend.
  A split weapon (the Split-cycle Breech, a module) hits twice as often, each hit's base (its number and what it prints from its firer) halved
  before the attacker's modifiers, rounded down and never below one (a number of nothing stays
  nothing); every modifier and the foe's own reads then count on each hit. A machine carrying
  Ricochet strikes again after each shot (Ricochet, below).
- **The die shows the number** one blow will deal after every modifier; a debuff shows none,
  and a gun whose blow is nothing here shows 0. Aimed at a foe it may strike,
  it shows that foe's number: its missing hull, conditions on it, its Brittle, its armour off. A
  Shocked foe's doubling is not folded in (it shows on the foe's chip). Its heat is
  the heat the spend will add, every modifier in (a Scorched machine's weapons run hotter).
- **Tapping a die** opens its readout, the entry showing alone, its marks as text, each line headed
  by the mark on the die it says (the main icon, its targeting mark on its target, a keyword's
  chip, the star, equipment's status chip, each cost's mark, the lock, a corruption): its place and name,
  what holds on it (on cooldown with its turns left, a foe's switch-off, corruption), its
  codex, then a line a mark: its number as the die prints it, its heat, its target, then its
  keywords (how it lands, Volatile, what it applies on hit, Rapid or Instant), its own rules and a
  written-out grant's line last, then its tags. A number the live sources moved off the
  component's own is coloured, green where the change is good for its unit and red where it
  is bad (more heat, a smaller blow), always relative to the unit and never the player, with
  its arrow on it, the way it moved: each number on its own, so a smaller blow and an extra
  strike each say so. No source is listed. A tap on it again closes it, and it
  is one readout with the units' (below): a tap on another die or a unit moves it. A die's tap
  lands once the double-tap window (0.15 s, from the tap's release to a second touch) has passed
  with no second touch, the die lit from the touch until it does, so a double-tap never flashes
  the readout open; a unit's tap in a fight waits out the same window; a tap
  that lands as the enemy's turn replays, or under a codex, opens nothing. The whole die as the
  fight has it is the die's double-tap; as it stands between fights, the codex's (double-tap the
  machine). **The keywords list**, in the pause menu, gives every reach, keyword, rule and status the dice and chips print, and the keywords
  a foe's move carries (Every Machine, Countdown, Last Act and the rest), with its codex line. Wherever shown text names one of those terms (the holds, the readouts, the codex, the
  list itself), it reads bold in its colour with its icon before it, and a tap on it opens its
  entry beside the word, where its own terms open theirs; a tap anywhere else closes it. A term
  wears one colour on the die, on its chip and in text, its group's: heat's red-orange for
  fire, heat and what hits harder, the shield's blue for what protects or holds, the enemy's
  violet for what only a foe does, the red-red for harm (Exposed, a destroyed component), the
  hull's colour for a price in hull, and ink for a shape, a reach or a rule; never the HUD
  colour.
  A piece that changes its machine's form wears that form's chip: on the Polar Bear, a buff it
  may spend on itself the seal's while its shell is open, and a weapon the opening's while it is
  sealed; the sealed machine wears a shell round it, a burst as it seals or opens.
- **Tapping a machine or a foe** opens its readout, the way a die's shows an entry, and
  tapping it again closes it; one readout is open at a time, a tap on another unit or a die
  moves it, a tap on nothing or ending the turn closes it, and a hold opens it too; a tap on an
  open readout, a term's aside, reaches nothing under it. It follows the fight
  while open, translucent over the arrows it draws, a machine's resting on its gauges. It
  shows its name;
  its gauges with their numbers (a machine's shield, hull and heat, and its magazine if it
  has one; a foe's HP), a maximum something moved off its own coloured with its arrow; its
  armour, and its cooling where it is granted any (a foe's armour and attack), as the codex's stats, the base with the change
  beside it ("Armour 2 (+1▲)"); every chip on it by its name and count, a buff's and a debuff's
  headed by the word ("Buff, Empowered +2", "Debuff, Ablating ×2") as an Ability's is, what it does
  a tap on its term away, and the round's warnings (an overheat, a wreck, a component at risk); then a foe's intent
  under its chip as the field draws it, a line a mark: its move's name,
  its blow as it will land read against its own, the machine it is aimed at by name with its
  move's word after it ("Skua, the hottest machine"), when it
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
  played on a copy of the fight with every rule as it runs: the end of the player's turn (what
  Ablating takes, the burns and the overheats), the enemy's turn with each foe's move as announced (a heal, a brace, a
  rally, the ticks as its turn ends and a death they bring, the last act it sets off,
  a self-destruct) and
  the round's end, a web's burst with it. The die in hand counts only over somewhere it may be spent, as it would be
  spent there. A foe whose machine falls before it acts strikes the next machine in line: its
  arrow stays on its pick, and a second, dashed, goes to the machine its blow lands on.
  Nothing a roll decides
  is promised: a strike at a random foe among several is left out (a lone foe takes it). A foe's gauge shows the HP the round will
  leave it, a heal hatched as a machine's gain is, and a foe the round kills wears the
  destroyed chip, its intent kept. Every status the round will land, on a machine or a foe,
  wears a preview chip: the status's own glyph and colour, pulsing in opacity on a dashed
  edge, with the stacks it gains, beside the destroyed chip when one is its cause; every
  warning (the overheat, a component at risk, the destroyed chip itself) pulses the same way, a
  prediction like any other. A Lure in hand shows its turn before it is spent: the foes it
  would turn draw dashed arrows to its machine, those on it already solid, and the gauges read
  the round as the lure would leave it (a machine's heat a blow taken included).
- Every number inside a fight is single digits or low tens: a blow 1 to 6, big guns to 10, one
  capstone 12; an amp a point a stack; foe HP 2 to 8 for rank and file at tier one and to 16 at
  tier three, a lone flanker 10 to 14 at tier one, 14 to 20 massive at tier one and to 56 at tier three, 12
  to 24 heroes, an elite 16 to 60, the slate's bosses 60 to 72 at tier one (a core in parts 40, a part
  8 to 18, a boss that may rise once 50); a foe's blow 2 to 8 at tier one (the rank and file's
  mostly 2 or 3) and to 10 at tier three, a massive
  foe's 3 to 8, a hero's 4 to 10, an elite's 7 to 18 and the slate's bosses' 10 to 20, sized
  against the shield that refilled before the reboot, the defence side's pass's to size again (at tier one no action of theirs takes the lightest machine
  from full: any one action's blows on one machine come to less than its shield and
  hull together); machine hull 20 to 50 by size (the
  Kite's paper hull 12, its row's one-off), shield 6 to 16 (tier one the low end, 6 to 12, since a level lifts it), base armour 0 to 2 by role, timed armour to 4 or 5; heat
  1 to 20 (1 to 30 if the pricing needs it; a weapon 3 to 11 today, a basic gun 4 or 5), the maxima 10 to 14 (the Musk Ox's 8), a vent 3 to
  8 (the Entropy Condenser's 10 the capstone, paid in hull). The scales are magnitudes,
  not steps: any whole number may be used, and content sits a little past them where its
  loops moved it (the promoted forms' 32 to 48, a hero's finisher, a
  multiple of its blow, to 16). A move is a count of hexes, 1 to 6 (the machines' 3 to 6, the foes' 1 to 4).
  The content's numbers are set by hand in the content, on these scales (the stock pass's loops,
  `docs/measurements.md`, the first of them); placeholders until play.

### Player keywords
- **Spread N** (id `cleave`): also hits the foes beside the target in its rank, each taking N
  where the target takes the number (a blow, above).
- **Penetrate N**: also hits the other rank of the target's column, which takes N.
- A piece may carry both, the plus round the target (the Howitzer's and the Shrapnel
  Recuperator's, each at 1); no third word names the pair. A weapon's area keyword carries its number; a debuff's carries
  none, its effects reaching those foes and its blow nothing.
- **Ignores armour** (a rule written on the piece, no keyword): the weapon's blows take nothing
  off for the foe's armour, its own or Armoured; a Barrier still takes the blow. The Overclocked
  Railgun prints it, and the Ammit's Soulcutter Talons, four strikes of 1 that armour would
  otherwise take whole; the Wild Boar's next weapon after a Barrier fires with it (the
  Juggernaut Drive, below). A Mine never carries it.
- **Ablate** (with a number): each foe hit gains that many stacks of Ablating (Ablate 3: three
  stacks). The same word on a foe's blow, on the machine it hits.
- **Cryo** (with a number): every foe the entry reaches gains that many stacks of Cryo a
  strike, laid once its hit's strikes are done, so a hit never cashes its own frost. Any
  machine's hit with a weapon on a foe carrying Cryo spends every stack and cools the hitter 1
  a stack, after the spend's own heat lands; equipment spends none.
- **Suppress**: each foe hit is Suppressed; on a Numbed foe the stun strips a stack and lands
  nothing; a Ward turns it away; one already suppressed for that action gains nothing more;
  and a foe immune to it (An immunity, under Foes) takes none.
- **Shock**: every foe the hit reaches is Shocked after its blow, the ones it fells included, so
  a hit never spends its own Shock.
- **Chain N**: all foes on the field that conduct (a Shocked foe, or one carrying a Sonic Needle)
  are struck for N, front or back, whatever the reach, with every strike of the entry (a
  Ricochet's strikes and a hit again arc none). The arcs are read once the strike's own blows
  have landed, so its own target is struck too while it still conducts: a weapon's strike aimed
  at it spends a Shock first, so a Shocked target is out, but a needle stays, and equipment spends
  no Shock. Each arc is N flat: no add or multiply of the machine's, no rule of the piece's (a
  gun that ignores armour, a spill), no rider (the entry's, its primers' or a passive's: no mark,
  no Lure, no Shock, no needle), no heat, and it does not use or consume a Shock. The conductor's
  own statuses and armour read it (its Brittle adds, Armoured and armour come off, Exposed takes
  them away), and a Barrier takes a weapon's arc; whether an arc stays a strike they read or
  becomes a flat ping they never touch waits on Ryan (the bible's section 12). It stacks with an
  area: a conductor Spread or Penetrate reaches takes the area's blow, with its riders, and the
  arc. An arc spreads nowhere and cashes no Cryo; a kill by an arc is still its machine's (the
  kill rules read it), and a foe it damages counts where a rule counts the foes a spend damaged
  (the Honey Badger's Ore).
- **Lure**: every foe reached turns on the spender for the round, a felled one too. A move at
  every machine or at nobody holds no pick, so it has nothing to turn.
- **Expose** (the Needletail's Fovea Designator, the Swallowtail's Spotting Flare, the Lammergeier's Lorentz Contractor): every foe reached
  is Exposed through the next round, a felled one too; a second Expose refreshes it, never
  adds.
- **Disrupt**: every foe reached takes the next move in its list that its
  conditions allow, keeping its pick while the machine stands and is in the fight; the next
  machine in line otherwise, and when the move it leaves held no pick (a brace, a blow at
  every machine); and no pick at all when the move it turns to is aimed at no one machine.
  A follow-up once announced is not turned, nor a gather its foe is immune through (An
  immunity, under Foes).
  Disrupt resolves before Lure. The Baboon's
  Retrocausal Shroud, spent on itself or an ally, Cleanses it and gives Disrupt to every foe
  showing intent on it, its pick or a blow at every machine: they change their move, not their
  pick.
- **Purge N** (id `dispel`, the foes' word too; Aphelion's Null Field Emitter, Purge 2): every
  foe the entry reaches loses N stacks of every buff it carries (Armoured, Empowered, Enraged,
  Undying, Primed, Barrier, Regenerating, Numbed; an unstackable buff is one stack; its
  Abilities, a core's guard and a golden rage among them, are no buffs and stay), after
  the blow and with the riders, a debuff's included, so a foe the blow kills stays down and a
  Barrier the blow pops is gone already; a Ward turns it away and stands; a Mine's purges every
  foe its blast meets.
- **Rapid** (any component): the die rerolls free onto any other entry, a copy of the same
  component included (a folded die among its live entries), and the machine acts again, so
  copies of one Rapid component chain. The entry spent stays dark for the rest of the round,
  Rapid's own cooldown, never printed, so each copy acts once a round; no cleanse lifts it.
  A Rapid vent is never below tier three (the one is the Musk Ox's quick reload, locked on a
  tier three, which cools nothing), and a Rapid shield never below tier two (the Laminar
  Deflector's two).
- **Instant** (any component): the die rolls again free, as the round's opening roll does,
  itself included, so the same entry may show again and be spent again, and the machine acts
  again; on a stepping die the roll spins every chamber. Nothing goes dark, so an Instant
  component always carries a limiter: a cooldown, heat or a cost. A piece Instant only while its
  machine rages has its machine's heat (the Nemesis's Knuckles of Fury, below). A piece locked on a stepping die (the Cassowary's
  Spin-Up) needs none: its spin is a true roll over every chamber, so it lands on itself one
  time in six, to be spent again, a fifth of a spin more a spend on average, and every other way
  back to it in a round runs through the other chambers' switch-offs or the team's rerolls. An
  entry is Rapid or Instant, never both.
- **Cooldown** (a printed property on specific pieces; a passive may grant one to every weapon
  and equipment its machine aims at a foe, none does today, and the longer stands), a cost printed
  along the entry's foot by its clock: once spent, the entry is dark for the rest of the round
  and for that many rounds after it, shown on the die with the rounds left, this one included;
  the die may land on it, and a dark entry does nothing. No cleanse lifts it.
- **Finisher** (the Kite's Pinion Driver, ×2): against a foe at half its HP or less the
  weapon's printed number is multiplied, before its buffs as a passive's double is. The foe's
  HP is read once a hit, as the hit begins, so every strike of
  the hit is multiplied or none is: a strike that takes the foe to half does nothing for the
  strikes after it.
- **Rules written on one piece** are that piece's own text and no keyword: the die wears the
  star for them and its readout says the rule (a keyword is a word several pieces share). Three
  were keywords until they were each found on one piece alone.
- **The Web Bomb's web** (the funnel-web's): the foe hit wears the Web Bomb's mark, one web
  however often it is webbed; as the round ends the web bursts, Suppressing it and the
  foe beside it, each for its next turn (the Web Bomb, below). No Mine carries it.
- **The swap** (the Dingo's Combat Translocator): the spend takes two targets, a foe and then
  another foe or an empty slot, and they trade places; no damage; a massive foe does not move.
  What the entry carries beside the swap lands on both foes named (the Translocator's Shock: both
  come out Shocked), and such an entry may name a massive foe as either target: two targets
  always, nothing moves, and the rider lands on both all the same. A swap that carries nothing
  else has no use for a massive foe.
  A swap lands in the rider phase, before the death check, like every rider: one whose spend
  fells its first target moves the corpse, which dies in the slot it was moved to and gets back
  up or splits there. A Mine moves with its foe.
  A foe keeps its pick and its move, from the rank it now stands in (a back foe pulled into the
  front stands exposed to Direct fire). On the screen: aim the die at the first target and
  let go; the crosshair stays pinned there and the second targets light; tap one to spend it; a tap or a hold on the die reads it; drag from the die
  again to aim anew or set it back. A tap on the ground sets it back too,
  once no readout is open: the first such tap closes the open readout.
- **Sap** (with a number; the Baboon's Redshift Emitter, beside a Purge 1): each foe hit gains
  that many stacks of Sapped a strike, laid once the strikes are done.
- **Brittle** (with a number, the same on either side; Wainwright & Sutler's on-hit on ours):
  each foe hit gains that many stacks of Brittle a strike (Brittle 2: two stacks), laid once
  the strikes are done, so no strike of the spend feeds on what it lays. A foe's blow that
  carries it leaves its number on the machine it hits.
- **A pin** (the Dingo's Hollow-point Harpoon): its target is Pinned, a status of its own:
  the next time its Brittle would halve, what the spend lays and what stood there, it does
  not, and the pin is spent; it halves again the time after. A pin with nothing to hold goes as
  its foe's turn ends.
  A Ward turns it away. Ablating has a pin of its own, Seared: the next time the foe's Ablating
  would lose a stack it takes its points and loses none (no piece lays it yet). Each wears the
  lock on the status it holds. Empowered has no
  pin: what holds it is a buff on the Ammit, Essence Flare (the Quintessence Tap, below).
- **Costs** are printed along the entry's foot with its heat, each a mark and a number with no
  word and no sign (the heat's thermometer, the shield's, the hull's machine body, a forging
  gun's shells, the cooldown's clock), never a keyword and never a chip: a
  **hull cost** (Volatile 3: spending it costs its owner 3 hull, past shield and armour,
  before it acts, and a machine it leaves at nothing is wrecked; a Phased machine pays none;
  the Umbra Inducer, the Oblation Mantle and the Entropy Condenser cost 3) and a **shield cost** (3 shield, taken
  first from the shield as it stands). An entry whose shield cost the
  shield cannot pay cannot be played: the die shows the cost struck through, it has nowhere
  to land, and END TURN pulses as if the die were spent. It is the first entry with a
  condition on its play, and the pattern for any to come; the second is a **count it spends**
  (the Quintessence Tap's Essence, by its mark, the number what it would take now), unplayable and
  struck the same way while its machine holds none.
- **Cleanse** (on a buff or a shield: the Breaching Plow, the Retrocausal Shroud, the Sutler's Hoist
  Charged): the machine it lands on loses Ablating, Scorched, Brittle, Sapped, Exposed, a foe's
  Jammed and Corrupted (never a cooldown).
- No shield passes its maximum: a shield granted to a full machine is lost.

Component properties, printed on the entry rather than learned as keywords (the die marks
them with a star): **Vents all** fires the whole heat gauge into the shot, adding its
bonus per step of heat fired, the step printed on the entry (the Heliographic Death Ray: +1 per
2), then its own heat lands. **Fires the shield** fires the whole shield into the shot, adding
its bonus per step of shield fired, the step printed on the entry (the Shield-burner Cannon: +1
per 2), and leaves the shield at nothing, Broken until the reboot (Shields, below), so no zap
rides it; a broken shield adds nothing. **Missing HP** adds its bonus for every
step of HP the foe struck is missing, each foe its own, on each blow after the attacker's
modifiers (so a split weapon's two strikes each add it), both numbers on the entry (the
Coriolis Accelerator: +1 per 5). **Gated**: a keyword printed with a condition on the foe (a Suppress on a foe carrying
Brittle, or on a foe carrying two Ablating or more) lands only on a foe that meets it, judged as its
hit is (as the die is spent) and before the hit's own riders, so a hit
never opens its own gate; the die
held over a foe strikes the chip where it will not land; a Mine its spend leaves carries the
keyword only where the gate held. Suppress alone carries a gate. **Consumes**: the first blow on each foe it strikes eats every stack of the status
the entry names on that foe and deals it a point more a stack eaten, after the attacker's
modifiers and before the foe's own, so an area consumer spikes only the foes carrying the status; the die over the foe
showing the number with the stacks in; one blow on each foe (no strikes past one); a Mine eats
nothing. The Suppression Battery's Suppress is
gated on Brittle, and the Backdraft Charge consumes Ablating, its Suppress gated at two.
**Ablates its firer** (the Stoker's): spending it sets its own machine Ablating, the stacks it
prints, after the blow; the round preview with the die in hand counts the first tick, off its shield as the turn ends.
**Empties the hopper** (the Honey Badger's Bullion Fragmenter): spent, it empties its machine's
hopper and strikes once for every Ore it empties, the armour the Ore stood for going with it; it
puts no Ore in, and with none in the hopper it is a dead entry, nowhere to land. **Braces**:
spending it Armours its owner, the stacks it says, an armour point each, until its side's
next turn begins (the Shift Whistle prints it). **The Quintessence Tap** (the Ammit's, equipment spent on
itself, cooldown 3): it consumes the Ammit's Essence, as much as it holds up to 5, and grants a
stack of Empowered for each, the die showing what it would take now; and its machine gains
Essence Flare, a buff, until the round's end. While a live machine carries Essence Flare no
Empowered halves that round, on any unit: a machine's as the player's turn ends, a foe's as
its own turn does, what each holds and what it gains before then, and it halves again the
round after. The buff is on the Ammit alone and no other unit wears anything for it, so a Ward
turns nothing away and nothing counts it as a mark; it is a buff like any, so a Purge that
takes it ends the hold, a carrier wrecked before the round's end holds nothing, and a
Swallowed carrier's buff waits with it and holds the round it is back for. With no
Essence it cannot be played (Costs, above). **The gather** (the
Lammergeier's Lorentz Contractor, a debuff with Expose): every Mine the field's other foes carry
joins its target's, their damage added and their keywords as one, in the rider phase after the
spend's own Mine joined it; a Ward on the target turns the gather away, the Mines staying where
they lay. **The detonation** (the Lammergeier's Syrinx Drone, a weapon of 1, no cooldown): in
the rider phase, after the spend's own Mine joined its target's, the target's Mine blows now on
it and every foe round its slot as a fall's does (A Mine, above), and is spent, so a target the
drone fells blows nothing more; its strike spends a Shock on the target, never the Mine. **The Immelmann Booster** (the Giant Petrel's, Rapid):
spent on itself, the team gains a reroll (A granted reroll, below); spent on an ally whose die is spent, which
it may land on only while the team holds the price, three rerolls are paid, banked or fresh,
and the ally's die rolls again by Rapid's path, never onto the entry it showed, and it acts
again, while the Booster's own Rapid gives the Petrel its turn back. **The Spindrift Salvo** (the
Giant Petrel's): a spend of it that kills gives the team two rerolls this round, once however
many fell, banked if unspent. **The Reheat Uplink** (the Giant Petrel's, allies only): the ally
gains Empowered 2 and its die rolls again, never onto the entry showing; a spent die rolls
nothing. **On itself** (the Storm Petrel's Hardlight Pulse, a lure, and its branches): spent on
a foe, its own machine gains the status it says, after the spend's hits and its primers, so a
fire never spends a Charged it has just laid; a stack set for every foe the spend reached where
it says so, a foe its Spread reaches among them, beside any flat stacks it names; never past the
most it names, the highest of the piece's own and its branches'. A buff may lay a status on its
own spender beside its grant where its piece says so (the Aile Assaulter's Empowered); a Barrier
laid this way is gained as any other is. **The offhand** (the Macaque's passive): its offhand
holds one form of a cycle at a time, the Beam Rifle, the Beam Sword or the Beam Shield, an
Ability under the form's name, and every fight opens on the first. The form is a rider on every
weapon and equipment the machine aims at a foe, and every such spend turns it to the next, the
first after the last, a Rapid spend's second shot riding the form after; a buff, a reboot or a
blank turns nothing. The die marks the rider with a star in the entry's passive box, its readout
reading the form's line. The rifle: each strike also lands a blow of 2 on the foe to the right of
the target in its rank (a twin's right half beside its left, nothing at the rank's end or past an
empty slot), its own blow beside any area's, so a Spread's neighbour there takes both, each through
its armour; it reaches the foe without being aimed at it (no Shock read), and carries the entry's
riders. The sword: after each strike, a hit again on the target, a strike of its own: its number
half the strike's own, rounded down (the Beam Saber's the whole of it), then the firer's pipeline
and the entry's reads of the foe as any later strike's, so a 4 strikes as a 4 and a 2 and a 2 ×2
as 2, 1, 2 and 1, and what buffs one strike never reaches the other; the entry's riders land with
it. A Ricochet's hits come after the spend's strikes and set off neither. On equipment the rifle's
and the sword's blows deal nothing and their riders land, as an area on equipment does. The shield: once the spend is done, Armoured 2 on its machine. Upgraded
forms: the Beam Buckler grants Barrier, Ward and Parry (below); the Beam Bazooka gives each strike
Spread 2 and Penetrate 2, added to any the weapon carries; the Beam Pavise grants 1 Armoured and 1
more for every foe the spend struck, its area's included. **The Aile Booster** (the Macaque's,
Rapid, on itself, heat 1): it grants Aile Boost; its Duelist II makes it the Aile Blitzer,
granting Aile Blitz, and its Valkyrie II the Aile Assaulter, granting Aile Assault (Buffs, below). **The spill** (the Overrun Gearing's, a Minerva module, on
every weapon its machine fires): damage past the kill of a front-rank foe
carries into the foe behind it as plain damage, the killing strike's excess and every later
strike of the spend whole, aimed at nobody, so a Shock behind neither doubles it nor is
spent; it is the module's own rule and no keyword, so each weapon wears the
star, the die's readout reading the module's line.
**The Juggernaut Drive** (the Wild Boar's, since 11 November): once a spend's hits land, every
front-rank foe a blow of it damaged, felled or not, drives a quarter of its maximum HP, rounded
up, into the foe standing behind it, once a spend, a plain blow (no
keyword and no Shock read, through what that foe takes, its armour and its Barrier); a massive foe
has nothing behind it. As the Boar gains a Barrier, from its own Breaching Plow (Cleanse and a
Barrier on itself, a cooldown of 1) or an ally's piece, its Drive waits (a buff under the passive's own name): its next weapon attack ignores armour.

### Buffs, debuffs and resistance
A **store** is a capped resource a machine fills and spends (the Muster, the
hopper, the Cassowary's shot count; the Musk Ox's magazine works the same way), its own kind
and never a buff: each shows as a row under the heat in the heat bar's shape, by how it fills:
one that comes in whole units (the hopper's loads, the magazine's ammo) as separate
cells, each with its own border and a hairline of ground between them, the lit ones filled; one that
fills by degrees (the Muster) as a meter
with a notch a charge, a dragged charged piece's price pending on it; the shot count as cells too,
its last marked as the shot that counts; and no Purge touches it, its filling or its use. An **Ability** is a
unit's own mechanic, the rule it plays by, and never a buff or a debuff, so no Purge
or Cleanse touches it; its chip shows its mark cut out of a solid tile, ahead of the unit's
other chips, and its hold line names it an Ability and says what goes on. A foe's: the Goblin
Nob's Enrage, a core's guard (Guarded), a Gel's split, a last act, a golden rage while it
lasts. A machine's: the Polar Bear's seal (its form), the Nemesis's Rage and the Ammit's Essence
(a count with no cap, so no store: its chip says the number). What an
ability, a passive or a store grants beyond itself is a buff like any (the Nob's gathered
Enraged, a module's Empowered or Armoured): a
stack is a stack, whatever granted it.

Every status on a unit says what it is, wherever it shows: a **buff**, which a Purge reaches,
wears a wedge pointing up off its chip's top at the left, and its hold line begins "Buff"; a
**debuff**, laid by the other side, wears a wedge pointing down off its chip's bottom at the
right, and its line begins "Debuff"; an Ability its solid tile and "Ability". A term's tip heads a
status by what it is, and the keywords list files the statuses under BUFFS, DEBUFFS and
ABILITIES.

On a machine:
- **Empowered** (buff): +1 damage a stack, so the count is the bonus. As its turn ends
  (END TURN) it halves, rounded down, whatever granted it, until it is gone, so what a machine
  gains in the enemy's turn it carries whole into its next; a buff component
  grants it stacks and no rounds. While a machine carries Essence Flare it does not halve, on any
  unit (the Quintessence Tap, above).
- **Essence Flare** (buff, the Quintessence Tap's, on the machine that spent it): no Empowered
  halves this round, any unit's, a machine's at END TURN or a foe's as its own turn ends. Until
  the round's end; one stack, renewed.
- **Essence** (Ability, the Ammit's Quintessence Reactor): 1 for every foe that falls in a fight
  the Ammit stands in, whoever or whatever fells it (its own blow, an ally's, an Ablate tick, a
  Mine's blast: a kill as the death check counts it, so a foe getting back up, a split and a
  part bank none), with no cap, kept from fight to fight through the battle and gone as the
  battle ends. The Essence flares as each fight opens, and at the end of a round in which an
  attack of the Ammit's own killed (its weapon's blow, an arc, a spill), once a round however
  many fell and however many of its attacks felled them: it gains a stack
  of Empowered for every 5 Essence it holds, nothing under 5, and none is spent by it. The
  round's kills are banked by then, so the flare reads the count with all of them in; an Ammit
  wrecked before the round ends flares nothing. What a flare grants is Empowered like any: it
  stands whole through the Ammit's next turn, halves as that turn ends, and a Purge takes
  it. Its Quintessence Tap consumes Essence.
  An Ability, so no Purge or Cleanse touches it; its chip says the count, and the
  codex lists it among what the battle keeps.
- **Armoured** (buff, on either side): armour +1 a stack, every stack at once, whatever
  granted it, so the count is the armour, until its side's next turn begins: a machine's
  (from a buff or a brace) stands through the enemy's turn and goes as the next
  round opens, before the foes announce, and a foe's (from its brace or another's) stands
  through the player's turn and goes as the foes' next turn opens, before the first of them
  acts. It takes no rounds: no grant holds it longer.
- **Hardened Light** (a machine's buff; the Storm Petrel's Hardlight Pulse): while its shield
  stands, every blow on it loses 1 a stack, a damage-taken effect read on the shield the blow
  meets, so it takes nothing off a blow on bare hull, a tick or a burn, and an Expose leaves it.
  It stays until the shield breaks, whatever breaks it, a reboot's drop included, and then every
  stack goes. A grant stops at the most its machine holds: 3, and 4 and then 5 in the Storm
  Petrel's Defence branch. A Purge takes stacks as any buff's.
- **Phased** (buff): cannot be damaged or targeted by anything until the end of the round, and
  it acts. Granted as the round ends: a source lays the wait for it (Phasing, a buff, a chip on
  a dashed edge), on a machine that has acted or not, and as the enemy's turn ends every machine
  that waits and still stands is Phased through the next round's end; one wrecked first never
  phases, and a foe's Purge takes the wait as any buff. While it stands no foe picks the
  machine, a blow or a special at every machine passes it by, and no ally may spend on it.
  Everything it carries ticks as ever, and nothing damages it: its Ablating takes no point and
  loses its stack, its Scorched and Sapped go, its Empowered and its Brittle halve, its
  Regenerating pays, so a round Phased waits a debuff out. It spends
  its die on a foe or on itself, and it may reboot, bare where nothing reaches it. Its own
  heat does not burn it either: what it carries past its maximum stays, more if it fires
  again, and burns the turn it is back in reach, the first such turn its overheat. A bite of
  its own entry is damage and is blocked with the rest: a hull cost (Volatile), a passive's
  hull price on a spend and a corrupted entry's bite take nothing. Its Lure turns no pick. A second grant while it stands carries it through the round after.
  On a foe (the Spectre's and the Wraith's, a step after their Hex Bolt, or a move of a foe's
  own): the wait is laid as the move lands and the foe fades as that round ends, if it still
  stands, so the round its move is announced is the window. Through the next round it is out
  of the team's reach as an Aloft foe is, no die dropped on it and nothing aimed elsewhere
  reaching it, and nothing damages it: what it carries ticks and takes no point, and a Mine on
  it does it no harm. It acts all the same, and it is back as that round ends. A foe's is
  less strict than a machine's in one way, its own side still reaching it, a rally's
  Empowered or a mend. Two guards: the last foe standing does not fade, so a fight has a foe
  to end on, and a foe Phased already gains no wait, so none is out two rounds running, and
  its intent wears Phased's mark only on a round the fade would land.
- **Swallowed** (debuff, from a foe's swallow): out of the fight (it
  cannot act, take damage or be targeted, a foe's intent on it re-picks, and a blow or a special
  at every machine passes it by) for the swallow's
  rounds, its die standing down as each round opens, until its swallower falls, or until its
  swallower has lost a quarter of its maximum HP since the swallow (its chip counting the damage
  still to deal, never more than the swallower has left; a second machine taken while it holds
  one joins that count, and the quarter lets both go); either lets it go at once, and in the
  player's turn it acts that round. The swallower loses nothing else. Nothing cleanses it.
  Out of play, so everything it carries waits where a Phased machine's ticks: no stack fades,
  halves or pays (its Ablating, Scorched, Sapped, Empowered, Brittle and Regenerating stand as
  they were), nothing of its own cools, regenerates or fires, a buff of its own holds nothing
  on the field (Essence Flare), it neither burns nor overheats,
  and no timed status on it runs out: each, a dark entry's rounds among them, moves a round
  later for every round's end it sits out, so the rounds it sat out never came for it. Only the
  swallow's own rounds run. Let go as they run out, it is back before that round's end is
  read, the end it was owed from the round it was taken in: what was that round's ends, its
  Brittle halves, a kill of its own is read. Let go sooner, it goes on from where it stood.
  Two things are no clock and reach it all the same: an event of its fight (a foe felled banks
  an Ammit's Essence), and a reboot it had begun, which recovers as the next round opens.
- **Muster** (store, the Swallowtail's): its charges. Every die that rolls fills
  it a sliver, thirty rolls a charge, a kill by its own guns five rolls' worth, up to three
  charges; it starts each fight empty and never decays. It shows as a smooth bar under the
  heat, a segment a charge. Each of its locked
  pieces has a plain form and a charged one that spends a muster. With a charge up, a locked
  piece goes out charged, unasked, and its die shows the charged form under a double frame;
  when the charged form has nowhere to land (Phased once any ally has acted, the act again
  with no ally spent), the plain form goes out and the charge waits. The
  Mooring Screens shield every ally but the carrier (Every Other Ally), or queue Phased on every ally, only
  while none has acted this round, so it is never a selective protection;
  the Spotting Flare Exposes a foe, or Exposes and Suppresses it; the Sutler's Hoist cools an ally
  2 and then shields it, or fills its shield, cools it to nothing and cleanses it; the Reveille
  Horn gives the team a reroll, or rolls a spent ally's die again, never onto the entry it
  spent, so it acts again.
- **A granted reroll** is no buff and no chip: a piece that grants one (the Reveille Horn, the
  Immelmann Booster) gives it to the team at once, past the round's two and with none left
  alike, and unspent it goes as the round's own do. While the die in hand would grant one the
  REROLL button pulses, lit even when it cannot be pressed, and its badge shows the count and
  the gain ("×1+1").
- **A drained reroll** is no status and no keyword: the move that takes one says so in its own
  text, and the REROLL button wears it. While a drain is announced the button says what the
  next round stands to lose under its count ("NEXT -1": the drains still coming, summed, never
  more than a round gives) and rings close in on its edge, since the loss can still be stopped;
  a drain that will not land (its foe destroyed or Suppressed, its move changed) leaves the
  note. As each lands in the enemy's turn the button flashes, and the rings stop with the
  last. The round a drain shortened wears what it took ("DRAINED -1") for as long as it lasts.
  A drain is a move's alone: no fall takes a reroll.
- **Charged** (buff): while it lasts the machine's weapons fire with Shock, shown on the die
  and landing as the keyword does, after the blows; a weapon fired spends a stack (a Rapid's
  or an Instant's second fire is a second fire, a salvo one; equipment carries it not and spends
  nothing); a Mine the fire leaves carries the Shock.
- **Supercooled** (buff): the same with Cryo 1, a stack a strike on each foe hit, one more
  than its own on a gun that carries Cryo, laid after the hits.
- **Primed** (buff, on either side): the third primer, the same with Ablate 1, a stack of
  Ablating a strike on each foe hit, one more than its own on a gun that carries Ablate. The
  three wait for a weapon, across rounds: no clock runs them down. A foe's, from a stoker's
  priming, its value in stacks: each blow of a move that strikes leaves Ablating 1 on the
  machine it hits, and that move spends a stack; a special, or a move lost to a stun, spends
  none; stokings add their stacks; and a machine's Ward turns its Ablating away as it does an
  ablate.
- **Spun Up** (buff): the next weapon the machine spends deals +2 a stack and takes every
  stack; equipment leaves them standing; carried between turns until a weapon takes it.
- **Ricochet** (buff, the Skua's): after a weapon fires, it hits its target again for 1, once a
  stack, once all its own strikes are done. Each is a strike of its own with every effect of
  the weapon but its area: its number 1 in place of the entry's and of what the entry reads off
  the foe, the firer's modifiers on it (Empowered adds), the foe's Brittle, then its armour, so a
  point of plate stops every one and an Exposed foe's plate stops none; the weapon's riders
  land with each, a stack a strike; an area and a Chain's arcs are the weapon's own and no
  Ricochet carries them, and a weapon over every foe has no target for one to hit. The stacks are read as the spend begins, so one
  the spend earns strikes nothing of it. Equipment strikes nothing again. Whenever the
  machine's hull is damaged (a blow, a bite or an overheat) half its stacks go, rounded down, so
  a lone stack is lost; a blow its shield takes whole costs none. It lasts the fight, with no
  cap, and a Purge takes it as any buff. The die shows the strikes its weapon will get in its
  passive box ("+3").
- **Regenerating** (buff, on either side): a point a stack as its carrier's turn ends, after
  its Ablating, then a stack fades, so Regenerating 3 gives 3, 2 and 1, the first as the turn
  it was gained in ends; a second grant adds its stacks. A foe's, from its own special, its
  value in stacks: HP as each of its turns ends, after its Ablating and Vitriol have ticked (a
  suppressed foe's included), so a foe its tick kills regrows nothing. A machine's (the Buzzard's
  Sustain lays it as foes fall): shield at END TURN, before the foes strike, up to its maximum; a broken
  shield takes none and the stack fades all the same. A buff, so an enemy's purge takes it, a
  stack a point of the purge.
- **Barrier** (buff): the next blow a foe lands on this machine deals no damage, so a Destroy
  on it finds no hull to read; its riders land, and a blow of nothing leaves it standing. One at a time and one
  stack whoever grants it (a passive that deepens the stacks its machine applies leaves it at
  one, and a Purge of one takes it whole); until its next turn starts. No piece grants it to every
  ally at once, and every piece that grants one carries a cooldown of 1, so it sits out the
  round after its spend: the Halo Projector and the Blast Door, self or ally, and the Wild
  Boar's Breaching Plow, on itself.
  A foe's, from its own special: the next blow of a weapon the team lands on it deals no damage,
  the blow's riders landing and a Shock it carried spent; equipment pops nothing; until it pops
  or its next turn starts.
- **Ward** (buff): no rider a foe lays lands on this machine this round, from a blow or from a
  move of its own (ablate, scorch, jam, corrupt, destroy, purge); a blow's damage lands. Until its next turn starts. The Decoherence
  Veil grants it, self or ally. A foe's, from a special that wards every foe on the field: no mark
  the team lays lands on it (Ablating, Brittle, Cryo, Vitriol, Shocked, Exposed, the Web Bomb, the Paradox,
  a Mine), nor a stun, nor a Purge, so a turned mark feeds no Paradox; the damage
  lands; until its next turn starts. On either side a Ward turns the whole thing
  and stands.
- **Rage** (Ability, the Nemesis's): its Crucible Capacitor heats it 1 for each foe's blow its
  shield takes with nothing on its hull, 2 for hull damage (a blow, a bite of its own, an
  overheat; a blow that breaks the shield and wounds is hull damage alone), and 2 for every
  blow of its own weapons a foe's armour or Barrier takes whole, each foe's and each strike's
  (a corpse's and a debuff's never). A bite of its own on its shield and a blow its own Barrier
  or armour takes whole heat nothing. A turn it opens at its heat maximum or past it, it rages,
  before its die rolls: every debuff on it lifts (what a Cleanse lifts), and none lands on it
  while it rages, a foe's riders and its moves turned away with a line in the log; its die rolls
  among its Knuckles of Fury alone, no reroll moving it, and they are Instant, so it swings
  again, each swing cooling it 3. When its heat reaches nothing, by its swings, a cooling it is
  granted or an ally's pull, its Rage ends and it reboots at once, whatever it has spent, and
  acts no more that turn. Ending the turn leaves it raging, its die still the fists, and what
  stands past its maximum burns as any machine's. It never reboots by choice while it rages, nor
  at its heat maximum or past it. No Purge touches it. Out of the Rage the Knuckles are one entry
  of its die, a plain swing that cools it 3.
- **Ore** (store, the Honey Badger's hopper): its Ore Hopper puts one Ore in for each foe a spend
  of its weapons damages, after the blow, up to its most (three, and every raise a step grants
  added to it); a weapon that empties the hopper puts none in, and a Mine's blast fills none. It
  lasts the skirmish, never decays, nothing cleanses it, and it shows as a row under the heat, in
  the heat bar's shape, a cell an Ore. What the Ore is worth is armour, the **Ore** chip, an
  Ability: a point once it holds three (a step adds a point for each Ore past three), set the
  moment the Ore moves, so it lands with the Ore that earns it and goes as the hopper empties;
  no Purge touches it.
- **Sealed** (Ability, the Polar Bear's form): equipment it spends on itself (a buff dropped on
  itself) seals it: armour +3, any cooling it is granted stopped (a chassis has none of its own), 3 heat more at the end of each turn
  before the overheat, and its Cryo Flinger gains Spread (one foe open, its rank's three sealed);
  a weapon it fires opens it, and so does a reboot: the shell and its armour go as the die
  drops, so the seal's clock adds nothing that turn and it stands bare and open through the
  enemy's. Equipment on an ally and a debuff (the Flinger's lure) leave the
  form as it is, so the sealed shell lures and stays shut; an ally's buff on it seals nothing.
  An overheat leaves it sealed. One seal, however often it seals.
  Its Lockdown also lands its weapons 1 harder on a foe carrying Cryo, open or sealed, read as
  each strike lands: the strike that meets the stacks takes the 1 and its hit spends them, so a
  later strike of the same spend lands plain.
- **Ablating** (debuff, from a foe's ablate; a foe's Ablating below is the same rule on the
  other body): a point a stack as its turn ends, at END TURN, before the overheat, off the
  shield first and then off the hull past armour, then a stack fades. A tick is no blow: a
  Barrier neither stops it nor is spent on it, and nothing that reads a blow fires; a shield
  it takes to nothing is broken, and what it takes from the hull is hull damage for every
  passive that reads it. The player has the turn to cleanse what the foes laid. Cleansable.
- **Scorched** (debuff, from a foe's scorch): every weapon and equipment the machine aims at a
  foe runs 1 hotter a stack, until its turn ends, when every stack goes, so it never piles up.
  Cleansable.
- **Jammed** (debuff, a foe's jam): the entry comes up blank until the machine reboots, the
  reboot's drop lighting it, or a Cleanse lifts it; no clock ends it, and its veil carries the
  reboot's mark in place of a count. A cooldown is no debuff: the spend's own price, its chip
  saying no Debuff and wearing no wedge.
- **Corrupted** (debuff): each spend of the entry bites its owner 3 a stack, shield first,
  no armour off it; it lasts until the machine reboots, the reboot's drop healing every
  corrupted entry as it lights a jam, or a Cleanse lifts it.
- **Brittle** (debuff, from a foe's Brittle rider: the World Eater's pin; a foe's Brittle below
  is the same rule on the other body): every blow the machine takes deals a point more a
  stack, the shield taking the extra first as it takes any blow, and the stacks halve as its
  turn starts, rounded down. So it stands whole for the foes still to strike that turn
  and half for the next, and a Brittle 1 is gone by then. A Ward turns the rider away.
  Cleansable.
- **Exposed** (debuff, from a foe's Expose; a foe's Exposed below is the armour rule on the
  other body): its armour counts for nothing, its own, any Armoured and what a kit grants,
  from the moment it lands through the round after. Armour it gains meanwhile is gained and
  does nothing until the mark ends; its shield, and a reduction that is no armour, are
  untouched. As that round opens every foe's targeted move turns on it, whatever the move's
  word, in the order they strike, until the blows already drawn would wreck it; from there the
  rest pick as they would. A move at every machine or at none is unmoved, a countdown's pick
  carried from the round before holds, and a machine out of reach as the round opens (Phased)
  draws nothing. Everything after is as ever: a Lure pulls a blow off it, and a foe that picks
  again mid-round takes the next machine in line. Refreshed, never added. Cleansable: a
  Cleanse gives the armour back and leaves the intents where they turned.
- **A foe's purge** is Purge N, the rule ours runs: N stacks off every buff the machine carries,
  for good, whatever granted it (a stack is a stack); its Abilities and its stores stay (the
  Ammit's Essence among them, never the Empowered it grants); a Ward turns it away.

On a foe:
- **Ablating** (debuff): 1 damage a stack as its turn ends, past armour, then a
  stack fades, so a burning foe strikes before it burns, and one its Ablating fells has
  acted. It never stops healing.
- **Suppressed** (debuff): it loses its next action: this round's, or the next round's when
  it has already acted this turn. It never stacks and never carries: a second suppress on a
  foe already suppressed, a Paradox's included, does nothing. As the turn it lost ends it gains
  its stun resist in Numbed.
- **Shocked** (debuff): when a weapon's strike aimed at it lands, the blow deals double and the
  shock is spent. A strike is aimed at the foe it resolves on: the player's pick, or each foe a
  weapon over every foe strikes, which the game targets rather than the player. A blow that
  only reaches it (an area's, a Chain's arc, a spill, a Mine's blast) neither doubles nor spends it, and equipment leaves it standing; it never stacks.
  It conducts Chain.
- **Sonic Needle** (debuff, the Echidna's): a stack for every strike of the Echidna's weapons and
  equipment that reaches the foe, an area's neighbours included and a Chain's arc never, and a
  stack for every blow the foe lands on the Echidna, whatever the blow dealt; a blow that wrecks
  it lays none. It conducts Chain. The stacks land one at a time, and the one that brings the foe
  to 3 fires the bolt before the next lands: the Echidna fires Chain 2, aimed at nothing, so 2
  lands on every foe on the field that conducts, that foe included while it stands, each a blow
  alone as a Chain's arc is (no rider and no needle, a Shock neither doubled nor spent, through
  its own Brittle, a Barrier and its armour); then every stack on that foe is consumed. A foe the
  strike fells takes its riders as any does, and its bolt fires on the others all the same; a
  foe whose own blow brings its bolt and fells it strikes no more that turn. A foe's cleanse
  takes the needles, a Ward turns them away, and they last until a bolt spends them. With no
  Echidna in the fight they land as any status and fire nothing.
- **Exposed** (debuff): it stands in Direct reach of every machine as if its
  column's front were empty, and its armour counts for nothing, its own and any Armoured.
  Through the player's next turn: it falls as the foe's turn starts in the next round;
  refreshed, never added.
- **Mine** (debuff, the Lammergeier's): its damage, the spends that fed it added, and their
  keywords, one Mine a foe; when the foe falls it blows on every foe round its slot (A Mine,
  under A blow). It lasts the skirmish, until its foe falls or the Syrinx Drone detonates it.
- **Paradox** (debuff, while the Baboon fights): a stack for every stack of another debuff the
  foe gains, a debuff that never stacks one (Shocked, Exposed, a Suppress, a pin), a buff none;
  at five or more every stack is consumed and it is Suppressed
  (a stun like any other: a Numbed foe strips a stack instead, a Warded one turns it, and a foe
  already suppressed gains nothing), the stacks spent either way. It never decays. The Suppressed a Paradox causes adds none; a Suppress
  keyword's does.
- **Vitriol** (debuff): as its turn ends it loses 10% of its current HP a stack, past armour,
  after Ablating on what it leaves, the whole share rounded down and never the last hit point,
  then a stack fades; it never finishes a foe. The funnel-web's Ambush lays it, a stack per
  weapon hit, as its text says; a web or a lure lays none.
- **The Web Bomb** (debuff, the mark its piece leaves): as the round ends the web bursts: it is
  Suppressed, losing its next turn (a countdown it gathers is held a round),
  and so is the foe beside it in its rank, its right-hand neighbour, or with none standing
  there its left-hand one. Every foe acts in the round the web is laid, so it stops nothing
  already announced: it is a double stun a round ahead. Each stun is like any other, each for
  itself. Every foe's turn has ended by the burst, so it meets the Numbed the foe ends the
  round with: a stack on it strips and nothing is stunned, and a foe the team stunned this
  round has just gained its Numbed, so the web strips a stack of that. A foe already
  Suppressed for its next turn gains nothing; a Ward turns the stun away; each half feeds the
  Paradox as the Suppress keyword's does. A foe felled before the round ends takes its web
  with it, and a foe's cleanse may lift it first. Its chip points at the neighbour the burst
  catches.
- **Cryo** (debuff): a weapon's hit on it spends every stack and cools the hitter 1 a stack;
  equipment spends none. It never fades on its own.
- **Brittle** (debuff): every blow of a weapon it takes deals a point more a stack, before its
  multiplies and its armour (a Shocked foe takes a strike aimed at it plus Brittle, doubled); a
  debuff's blow stays nothing. The stacks halve as its turn starts, rounded down: once the
  player's turn is over, so what a Mine's blast lays in the enemy's turn stands whole for the next.
- **Sapped** (debuff, on either side): its attacks deal 1 less a stack, an add before the
  multiplies, never below nothing: a foe's blow, its intent showing it, or a machine's weapon.
  Every stack goes after its next turn: a foe's at the end of its next action, a machine's at the
  end of the player's turn. A foe's Ward turns it away; a Cleanse clears it from a machine.
- **Juggernaut Drive** (buff, the Wild Boar's passive waiting): gained as it gains a Barrier, one at a time; its
  next weapon attack ignores armour and lifts it, equipment leaving it standing. A purge takes it.
- **Aile Boost**, **Aile Blitz**, **Aile Assault** (buffs, the Macaque's Aile Booster and its
  branches'): one at a time, carried between turns until the next weapon its machine fires, which
  reaches as Indirect for every strike of its spend and lifts it, equipment reaching as its own and
  leaving it standing. Aile Blitz's weapon ignores armour too.
- **Parry** (buff, the Macaque's Beam Buckler): through the round it is gained, what a Barrier
  and its machine's armour keep off foes' blows is counted (the whole blow a Barrier takes, what
  armour takes off what passes the shield; never what the shield soaks). As its machine's next turn
  starts it goes, and half of that count, rounded down, stands under the same name as its next
  strike's add that turn: the first blow of the first weapon it fires, on its target (The strike
  order, above), in Empowered's place in the blow, a point a stack. That weapon lifts it, equipment
  leaving it, and it goes as the turn ends if no weapon fires. The die shows it in the weapon's
  passive box, never in its number.
- **Empowered** (buff, Rally): lands on every foe on the field the moment the rally does, its
  rallier too, the rally's value in stacks, and every blow the foe lands hits a point harder a stack, each
  strike of its move, as a machine's weapon does. It halves as its own turn ends, its action done, rounded down,
  as a machine's does at the player's, and skips the halving while a machine carries Essence Flare, as a machine's
  does: no move spends it, a special or a Suppress takes none of it, and a
  countdown still gathering carries what stands to the blow it lands. A foe acting after the
  rallier hits harder this turn and carries half on; one that has acted has had this turn's
  halving, so its next blow has the whole rally; the rallier's own share halves at once, its
  turn ending on the rally. A rally says 2 at the least (below); each rally's grant adds. An intent counts the rallies on their way to a blow this round, those of the ralliers acting
  before it, each from a rallier alive and not Suppressed, so it
  drops the moment the rallier is killed, Suppressed or Disrupted; a countdown still gathering
  shows what it would deal now, at the fight as it stands, never a rally of a round before it
  lands, nor a halving to come. The foe wears the coming Empowered as a preview chip on a dashed edge, its opacity
  pulsing on the gauges' clock, until it lands; a foe whose move shows no blow wears none.
- **Enraged** (buff, a rage: the Goblin Nob's, its own from the fight's start): while the foe
  stands, every shield, vent or equipment entry the team spends lays its rage in stacks on it,
  before the entry acts, and each stack is a point on every blow it lands for the rest of the
  fight, each strike of a move; a weapon or a blank feeds nothing, and no move spends it.
  Its chip climbs with the stacks, so the number an intent shows is the number that lands. A
  Purge lowers the stacks by its number and the rage goes on: the rage is the Nob's Ability,
  its chip the rule (Enrage), and what it has gathered a buff.
- **Golden** (Ability, a golden rage: the Thunder Ape's): for the rounds its move says its blows
  hit the move's value harder, each strike of a move, and it wears a point of armour. A
  quarter of its HP lost since it went gold breaks it and it staggers: the gold goes and it
  loses its next action (never Numbed: a stagger is no stun piece's, and one already
  suppressed loses nothing more). A Suppress that lands breaks it too, one a Numbed stack
  absorbs does not; no Purge strips it, an Ability. Its chip counts
  the rounds left and the damage that breaks it. It goes gold only while calm (the `calm`
  condition: not gold), so one rage at a time.
- **Appropriated** (an Ability, a take's: Gilgamesh's): the number of the entry he holds, which
  his borrowed swing lands in place of his attack and spends. One piece at a time, what he
  takes next replacing it; no Purge reaches it.
- **Undying** (buff, Reraise, on itself or from an ally's): after it falls it gets
  back up once, whole, in its own slot, unless it self-destructed: once the spend that felled
  it is done, or at once to a tick; its round is over, as a split's half's is, and it comes back
  with no Mine. A Purge on the hit that fells it strips it first.
- **Aloft** (buff, the Roc's while its Stoop gathers; a working name): the foe is out of the
  team's reach. No die may be dropped on it, as a spend's target or a Swap's second, and
  nothing a spend lands with no aim reaches it either: a neighbour's Spread, a blow or a mark
  at every foe, a Chain's arc, a Mine's blast beside it, a web's catch, a spill or a shove
  from the foe in front. What it carries is its own, which is what parts it from Phased: its
  Ablating and Vitriol tick and damage it, a web on it bursts on it and a Mine on it blows on
  it. It begins as the move begins to gather, in the enemy's turn of the round it was
  announced, so that round is the window: a kill, a Suppress, a Disrupt, or a burn laid to run
  while it is up. Nothing breaks off the climb once it is up. It ends as the move lands. A web
  it carried up holds the move a round, and the climb with it. The foe is drawn as what no die
  reaches is, faint under a dashed edge, higher over its shadow.
- **Numbed** (buff): the rounds until one stun lands. A stun on a Numbed foe strips a stack and
  lands nothing, so a foe with Numbed N takes N+1 stuns in a round. As a stunned foe recovers it
  gains its stun resist in stacks (content's `resist`; by its kind when content says none: 1, a
  massive foe 2, an elite, a hero or a boss 3), as the turn it lost ends;
  a stack goes as each of its turns ends after that. A Purge lowers it like any buff;
  nothing deepens, spreads or cleanses it, and a fresh foe is stunned by one.

"A foe carrying a status" (the Susceptibility Tensor) means a debuff the team put on it:
Ablating, Suppressed, Shocked, Paradox, Vitriol, the Web Bomb, Cryo, Brittle, Exposed or a Mine.

### Shields, armour, hull
- A shield absorbs a blow up to its number and loses what it absorbed; the excess reaches
  the hull. No blow of a foe's passes a shield or armour.
- A machine's armour comes off every blow that reaches its hull, flat, what passes a shield
  included; a blow at or under the armour is nothing; a shield takes no armour
  off. A foe's armour comes off every blow on it the same way, never off Ablating, Vitriol or a
  weapon that ignores armour. Base armour is set by role (a tank 2, a heavy worker 1, the rest 0; the
  Polar Bear, a tank in its sealed form, 1 open and 4 sealed), and
  Armoured adds to it (a brace: a buff) until its
  side's next turn begins, the Polar Bear's seal until a weapon opens it.
  Damage-taken effects apply before armour.
- The shield is the fight's, as the heat is: full as every fight opens, and nothing returns on
  the map. In a fight nothing mends it by itself: a reboot brings it back whole (The reboot,
  below), and a component, a module or a passive adds to one that still stands. A shield at
  nothing is Broken, and takes none until its machine reboots, whatever took it there: a blow,
  the overheat, or its own spend (the Buzzard's zap paying its last point, its cannon firing it
  whole). Hull
  is the battle's and never heals in it.

### Heat
- A weapon adds its heat when spent, once a spend, through the attacker's modifiers in the
  blow's order: adds, then multiplies (so a machine whose heat is doubled doubles Scorched's
  extra too). A spend is never refused for its heat. Heat may pass the maximum during the
  player's turn harmlessly, and it stays there: at the end of the turn, before the enemy acts,
  every point past the maximum burns a point of hull, and burns again every turn it stands
  (Overheated, a stack a point). The first such turn since the machine's last reboot is its
  overheat: its shield breaks, and what an overheat sets off fires, once between reboots. With
  volatile and what its Ablating takes, it is the way a machine dies on its own turn. Nothing cools by itself: a reboot
  takes the heat to nothing, and what cooling a machine is granted (a vent, a module, a
  passive) takes the stacks past the maximum first. Heat starts each fight at zero.
- The prices are a pace. A basic gun makes 4 heat and the Laser Carbine 5, against a maximum
  of 12 or 14: a machine that fires every round stands at its limit in three rounds, and from
  there holds, burns, or gives a turn to a reboot. Equipment is the cool play: a buff makes
  none and a debuff device its one or two.
- The console speaks of heat on a spend, one line a spend: the overheat every time a spend
  heats a machine and leaves it over its maximum; the warning once, as a machine first stands at
  three quarters of its maximum or past, and not again until it has been seen back under (as a
  round opens, once a reboot or a granted cooling has taken it down, or after a spend), so a
  machine that stays hot is not warned twice.
- The burn is hull damage for every passive that reads hull damage, each turn it burns.

### The reboot
- Nothing regenerates and nothing cools by itself. A machine gets both gauges back by giving a
  turn: on the player's turn a machine that has spent nothing this turn may reboot, its die
  dragged onto REBOOT, the target in the middle of the bottom row. It is its whole turn: a
  machine that could act more than once, by Rapid, Instant or a grant, gives all of it up. A Rapid or
  Instant spend is a spend, so no machine reboots after one, with one exception: the
  Needletail's Quick-turn Avionics Relay, which may reboot after one action whatever its die
  shows (above), the vent taking the heat of what it spent with the rest. A die showing nothing
  lit, every entry jammed or on cooldown, has spent nothing, so its machine may reboot.
- At once its shield goes to nothing and its heat with it, Overheated's stacks too, every entry
  a foe jammed lights, and it is
  free to overheat again; it is Rebooting through the enemy's turn. As the next round opens,
  before the roll and before the foes pick, its shield is whole and Broken is gone. Heat laid
  on it after the vent stays: one vent, as the shield drops. UNDO takes a reboot back like a
  spend.
- A machine whose reboot fires a piece first (the Whip Scorpion's Heliographic Death Ray, a
  locked piece its die never rolls): while its die is held, REBOOT reads the piece's word (DEATH
  RAY), and its die dropped there brings the piece up in place of the entry it showed, nothing
  vented yet; while it is up REBOOT reads CANCEL, and a drop there again shows the entry it did.
  Held over REBOOT, the die shows what the drop brings up, the piece at the number its heat makes
  now, and over CANCEL the entry it goes back to.
  The die with the piece up rerolls nothing. Spent, the piece does its thing and the machine
  reboots as above, the reboot its whole turn. A die with nothing the piece may land on (a field
  of Phased foes) cannot reboot that turn: it skips, or spends an entry that needs no foe. UNDO
  takes the shot and its reboot back, the piece up again. The round's roll stands in place of a
  piece left up.
- Besides that piece's, one rule reboots a machine: a Rage that reaches no heat (the Nemesis's,
  Rage under Statuses). Nothing else forces a reboot, and it clears nothing else: the machine's
  statuses stand. It is no pass, no entry spent and no shield gain, so nothing that reads one
  fires on it.
- **Overheated** (debuff): the heat a machine carries past its maximum, a stack a point. It is
  heat like any other: every rule that reads heat counts it, and a maximum that rises takes
  stacks back onto the bar. No cleanse lifts it. Its burn and the one overheat between reboots
  are Heat's, above.
- **Broken** (debuff): a shield at nothing, whatever took it there: a foe's blow, the overheat,
  the machine's own reboot, or a shield spend or cost of its own. A Broken shield gains no
  shield by any method, a grant, a regen, a refill on a kill or a module's, until the reboot's
  recovery (a turn under, for a burrower), so a shield breaks once between reboots. No cleanse lifts it. A Barrier is a buff
  in front of shield and hull: it touches neither bar and lands on any machine, Broken or
  rebooting.
- A Swallowed machine cannot reboot: it has no turn to give. A Phased one may, and its reboot
  is the safe one, bare where nothing reaches it.
- **The burrow** (the Mole's passive, Burrow): it burrows in its reboot's place, its die dragged
  onto the same target, which reads BURROW while its die is in hand; the reboot's gate, a turn
  it has spent nothing, and its whole turn. Its shield is never emptied. What stands past its
  heat's maximum vents at once, as a reboot's does, so nothing burns at its END TURN and it is
  free to overheat again, and every entry a foe jammed lights. It gains a stack of **Conserved
  Momentum** (a store, so no Purge touches it, up to 3, a bar under its heat), and its drill
  comes home with what is left of the Applied Momentum in its foe, back as Conserved up to the
  cap. It is then **Burrowed** (an ability, so no Purge touches it): armour 1, its die rolling
  the Inertia Drill alone, which its die never rolls above ground; and each of its turns under
  opens, before anything cools, with Broken and Overheated cleared and the one overheat between
  reboots free again, half of what its shield was missing as it burrowed back on it and half of
  the heat it carried then off it, each rounded up (two turns under is whole and cold, and a
  blow taken under is not mended), every entry a foe jammed lit, and a stack of Conserved
  Momentum. It stays under until it spends the Drill, and cannot burrow again while under.
- **The Inertia Drill** (its locked piece, equipment, Indirect): spent at a foe, it spends every
  stack of Conserved Momentum, lays as many of **Applied Momentum** on the foe (a mark the team
  lays: the foe's Ward turns it away, the stacks spent all the same), and brings the Mole up,
  **Drill Out** (an ability) until its next burrow, its foe felled or not. As the foes' turn
  starts, before their side's opening, each foe carrying Applied Momentum takes its drill's
  blow, a plain blow of 2 (its Brittle adds, its armour and a Barrier from its last turn take it,
  no Shock is read, and a Phased foe takes nothing), then what a branch of its drill lays (the
  Mole's two are back in design and offered nowhere: Ablate, Ablate 2 in the blow's place, then
  Seared with it; Squad, Brittle 1 and Pinned, then Exposed), and a stack goes. Before the opening, so a Pinned it lays holds
  the Brittle the opening would halve. A foe's cleanse takes it, a foe that falls takes it with
  it, and the Mole's next burrow takes it home. The drill works as its machine stood when it
  drilled: a branch learned later changes the next drill.
- The fight bot burrows a burrower by the reboot's reads, but never while its drill still works
  in a standing foe unless it overheats; under, it holds the drill until it has its cap of
  Conserved Momentum and is whole and cold, then drills the foe its blows pay most on.
- The fight bot reboots a machine past its maximum, unless a vent it shows takes it back
  under; one whose shield is broken when a blow is coming or its heat is half spent; one whose
  entry would pass its maximum, where it has heat to shed and this round's blows would take a
  point of its shield or less; and a die left idle, where there is something to get back. A
  machine whose reboot fires a piece first (the Whip Scorpion's) fires it at its best target
  wherever it would reboot, standing it down when it has nothing to fire at, and in place of its
  best spend when the piece's shot, its heat free, less what standing bare through the round
  costs over standing as it is, is worth more. It prices heat that takes a gauge past half where
  that doubles the hits on it, reads a heat scale on every blow at the heat the machine holds and
  a cooling of its own as heat off. A machine that would rage (the Nemesis's) reads heat that
  opens its next turn at its maximum as the Rage's swings, at a share, never reboots to make room
  for its entry or for a shield short of broken, and swings a Rage down to its reboot. Other heat
  under the maximum it reads as free, never as fuel. A machine that may reboot after an
  action (the Needletail's) spends first where a spend is worth making, its heat free before
  the vent, and reboots after it. It weighs a pull as the ally's cooling less what the heat costs
  on its own gauge, and a dump as the buff its heat makes and its own gauge emptied, less what
  the heat costs on the ally's.
- **The Hardlight Generator** (the Storm Petrel's passive): every point of heat it gains, from
  any source (a spend of its own, a foe's Scorch, a passive's), stands up a point of shield as
  the gauge climbs, on a shield that stands and up to its maximum; a Broken shield gains none
  until the reboot, so its heat is its fuel and its clock at once, and the overheat it walks
  toward breaks the shield it built. A shield cost is paid first as the entry is spent, and the
  heat stands shield back from what the cost leaves. It has no shield armour of its own: its
  lock, the Hardlight Pulse, a lure of heat 3, lays Hardened Light 1 on it, up to 3, so its
  taunt stands up its shield and hardens it, and heat is the one gate to both.
- **Ammo** (the Musk Ox's Desublimation Forge): its weapons spend ammo instead
  of heating it, 1 for every 2 heat a gun's own spend would make, rounded up, at least 1, the
  price printed on the die where the gun's heat would be; its debuffs, buffs and shields and
  the foes' heat land on its heat bar as on any machine's, Scorched's extra included. The
  magazine is a row of cells under the heat bar, a cell an ammo, never a status, so no Purge
  reaches it; it holds 10, opens each fight at 3 and gains 1 at the start of every round after
  the first; a vent it spends on itself adds 3, a shield 2, an entry both at once 3, once, the
  greater; a gun it cannot pay for cannot be
  spent (the die strikes its price through). Its Shrapnel Recuperator returns 1 for every foe its blows reach;
  its Unrestricted Expenditure needs 8 ammo, empties the magazine and lands its number on every
  foe (a stand-in until its own session), the magazine its price and no heat of its own (a
  Scorched machine's extra lands on its heat bar, as on any forged gun); its quick reload,
  Rapid, adds 2 for 3 heat, and the Forge counts it as no vent.
- A shield, a vent or a buff that prints heat (the quick reload) adds it to its spender as it
  is spent.
- Foes never add heat to a machine. One debuff taxes it: Scorched heats the weapons and
  equipment the machine aims at a foe in the turn that follows, so a hold, a buff or a cool
  weapon plays round it. Ablating is damage, never heat: a point a
  stack off the shield and then the hull (Statuses, above). A foe's ablate leaves Ablating
  and its scorch
  leaves Scorched, a stack a blow; the Drake's Stoke sets one machine Ablating, any machine,
  as a move with no word picks, and
  the Magma Elemental's Eruption, the Black Mage's Fira and the Summoner's Pyroclasm scorch every
  machine.

### Destroy
- No blow destroys a component by its size. **Destroy** is a rider on a foe's blow, a boss's
  and no rule of every blow, and no foe carries it yet: when any of the blow reaches the hull,
  past shield and armour, it destroys the entry the machine's die shows (the one it spent, held
  or locked); a blank shrugs it off, and a second such blow in the turn finds it broken
  already. What faces the enemy is the player's choice. A shield that takes the whole blow, a
  Barrier or a Ward keeps the entry, and the round's preview warns of a component at risk.
  Bites, ticks and overheats destroy nothing.
- **Destroyed**: blank; its passive keeps its stat bonuses and loses its abilities. A machine
  wearing the Reinforced Skeleton (Minerva's module) never has a component destroyed, so a
  Destroy passes it by.

### Foes
- A foe has HP (a foe's word; a machine has hull), a base attack, a rank it holds, a size,
  flat armour (a boss only where its kit is armour, the Cinder Tortoise's stepping by the tier; the promoted forms 2). Its damage
  never rolls.
- **Its move**: from the moves whose conditions hold, weighted by each move's own weight (attacks mostly 2, specials 1, the Bomb's Self-Destruct 3), never
  the same special twice running while anything else is open. The foes announce in the order
  they strike, each reading the moves already out: a reroll drain is no move a foe may announce
  once the drains already out take every reroll a round gives, so the field never announces more
  than two (a drain held by a Suppress, still gathering, or its foe destroyed counts nothing; a
  Disrupt reads the same, and finds such a foe nothing else to do). A move without a condition
  fires on its weight; the conditions read the foe's own side or what its move needs: below
  half, hurt, a foe behind it, another foe on the field, one
  of its own hurt, a machine carrying a buff, one of its own not readied, one of its own
  marked, one of its parts fallen (a part down and not waiting to step in). A move marked once
  comes once a fight. A foe that strikes only when buffed (the goblins' Timid, an
  Ability on its chip) announces its blow alone while a buff stands on it or a move announced
  ahead of it this round will lay one on it (a wall beside it, a brace, a rally or a Ward on
  every foe), and anything but its blow while none does. No foe flees the field but a loot-runner whose prize goes with it (the
  one shape a flee may take; none is built, and no move flees). A move may
  carry a countdown: it gathers, landing that many rounds after it is announced, and nothing
  hits meanwhile; its pick holds while the machine stands; Suppress holds it a round, Disrupt
  breaks it off, and the foe stays on the field. A blow that gathers one round may climb (the
  Rocs' Stoop): its foe is Aloft while it gathers (Aloft, above), on the field and out of the
  team's reach, where no Suppress or Disrupt finds it. A move may name a follow-up: once it lands, the
  move it names is its foe's next round's intent (the Matador's Red Capote, then Andalucia); a
  follow-up comes only that way, never by the roll, and a Suppress on the first move, or a
  Disrupt that turns it, means it never comes; once announced it cannot be Disrupted, only
  Suppressed (its chip says it is committed and that no Disrupt turns it, and a Disrupt held
  over the foe shows its chip struck through), so the first move is the window. It is the
  engine's pattern and no term of the player's list: a move's readout says what it names next,
  and nothing calls it a follow-up. A borrowed swing with nothing taken is no follow-up, and the
  roll decides. A swallow is never drawn while fewer than two machines stand
  in the fight, nor a merge while nothing of its kinds stands on the field, nor an Expose while
  another foe's is out this round or a machine stands Exposed: one machine at a time, and the
  whole field's fire every other round at the most.
- **Its target**, for a move aimed at one machine, drawn as the round opens and shown as its
  arrow: any machine, level, unless the move carries a word for whom it goes for. The words
  are the strongest and the weakest (the most and the least hull and shield together), the
  hottest (the most heat) and the most buffed (the most stacks of buffs). A tie is drawn level
  among the tied, so a field that is level picks anyone and no word falls back on another.
  The word is the move's: a foe has none of its own, and one may carry a seeking breath and a
  plain claw. The Red Dragon's Breath and the Black Mage's Fire and Flare go for the hottest
  and the Djinn's Unmake for the most buffed; no move carries the strongest or the weakest
  yet. A move at every machine or at nobody (a brace, a regrow, a rally, a scorch all) draws no
  pick and shows no arrow. A
  machine that stands Exposed comes before every word (Exposed, above). The
  foes pick in the order they strike and never over-commit: a machine the blows already picked
  would wreck through its shield and armour is passed over while another stands (a blow at
  every machine counts on each; a special, a suppressed foe and a countdown still gathering
  count nothing). The pick is a commitment, smart as it is made and never after (Slice and Dice's model): during the player's turn it moves only by a Lure, by the
  machine leaving the fight (Swallowed), or by a Disrupt whose foe finds its machine
  gone or out of the fight; a machine Phased as the round ended is out of the picks the next
  round opens with, a countdown's carried pick drawn again; a foe whose machine has fallen or is out of the fight when it acts
  strikes the next machine in line, left to right, that stands in the fight, whatever its move's word,
  so the player can tell the pick it
  will make, and the round preview shows it. The preview never moves a pick: a foe aimed at a machine the round will wreck stays
  aimed at it, and the preview shows where its blow lands after.
- **A blow** is the move's number, the foe's base attack times the move's factor, rounded to
  the nearest whole, plus its adds: its Empowered, its swarm for each other live foe of its
  type and its grudge (its number for every foe the team has killed this fight, every fall but a
  foe gone whole, a burst or a part falling with its core, and one taken in by a merge), less
  its Sapped, never below nothing. A move's number is its own, as a weapon's is, and an add is
  a point on every strike whatever the factor: the one damage formula on both
  sides; strikes are separate blows. An attack deals damage, 1 at the least at its foe's base
  attack: a move that would deal none is a debuff, a rider-only hit with its effect (the
  Half-Gel's Engulf), as a machine's component that deals none is equipment. A foe carries at
  least one move that lands on a machine, a blow or a rider-only hit, and opens with its first
  blow, or with its first move where it has none. Riders (a Ward turns away all but the last
  three): scorch (stacks of Scorched), ablate (stacks of
  Ablating), jam (the entry the machine shows is Jammed), corrupt (Corrupted stacks on it), brittle
  (Brittle stacks on the machine: a point more on every blow it takes a stack, halving as its
  next turn starts), destroy (any of the blow on the hull destroys
  the entry the machine shows: Destroy, above; no foe carries it yet), expose (the machine is
  Exposed through the round after: Exposed, above; among the rank and file a tier-two foe's at
  the least, the validator refusing it on a foe of the line dealt at tier one, while an elite
  and a boss may hold any mechanic at any tier; a blow's Expose lays nothing while a machine
  stands Exposed, never a second mark and never the first renewed, and its intent wears no
  mark for it that round, so the one foe whose only move it is, the Piercing Eye, marks every
  other round at the most),
  self-destruct (the striker dies after, for good), every machine
  (each strike lands on every live machine in turn, its number what each takes; it holds no
  pick, so no word and no Lure moves it). Scorch, ablate, corrupt and brittle each say their stacks a blow, as the player's
  Ablate does (Scorch 2: two). What a foe's move lays that halves says 2 at the
  least, a rally's Empowered and a move's Brittle: one stack is gone at its first halving, a
  machine's Brittle as its next turn starts and the rallier's own share as its turn ends. The validator holds a foe's moves to it. A blow's rider may lay 1 (the
  halves of a Bubble Gel and a Molten Gel): the foes strike in turn, so a single stack of
  Brittle a blow lays is on its machine for every blow after it that turn. No such floor binds the player's pieces:
  the player orders the turn's spends, so a single stack is used before it halves.
- **An immunity** is a foe's own Ability, a chip on it that no Purge reaches, given case by
  case to a foe whose fight needs it: one thing of the team's that never lands on it. A foe
  immune to Suppress is never stunned, by a die, a web's burst or a Paradox, and gains no
  Numbed for it (the Pilgrim). A foe immune to Disrupt while a move gathers is not turned
  from that move, from the round it is announced to the round it lands, and a Suppress
  still holds it a round (the Obsidian Tyrant through Firestorm, the Ruby Colossus through
  Ultima). The die's own mark is struck over a foe it will do nothing to.
- **A drain** is no rider: it is a foe's own Ability, a chip on it that no Purge reaches (the
  Vampire Lord's). Every blow it lands, whatever the move, regrows it by what the blow took
  from the hull, no more than the machine had, so a shield starves it; it lays nothing on the
  machine, so no Ward turns it away and a Barrier's blow drains nothing, and Ablating on the
  foe takes back what it heals.
- **A move is a short list of steps.** Its first is the move as written, a blow with its
  riders or one special. It may do more after, each further step a special's effect by that
  effect's own rules, in the order written, once the first is done. A step aimed at a machine
  lands on the move's own pick: a Ward there turns it away, and one whose machine the blow
  wrecked, or that is out of the fight, lands on nobody. A step on its own side acts whoever
  stands. A foe its own blow spent does nothing more. The move is announced once, its intent
  wears the marks of its steps beside its blow's riders, and its text says all of it. What may
  never be announced is read off every step: a drain past the round's two, a swallow of the
  last machine, a second Expose. A foe left with nothing to announce takes a blow whose own
  condition holds before any other, so the Thief's Mug lands when the round's rerolls are
  spoken for and what it takes past them is nothing. One blow a move, and that its first
  step, unless the move says what the blow does before it lands: each such step is a
  special's effect on the move's own pick, in the order written, and the blow meets the
  machine as they leave it. The Pilgrim's knife purges first, Purge 1 and then the blow, so
  a Barrier is gone before the knife arrives and a stack of every other buff with it; a Ward
  turns the purge away and the Barrier behind it takes the knife. The needler line's Needles,
  the Old Man of the Desert's Maw and the Rust Monster's bite purge first the same way. The intent wears such a
  step's mark ahead of the blow's riders, and the preview of the round reads the blow as it
  will land. A rider is no such step: riders land after the hits, on either side. One pair
  of steps reads as one act: a cleanse that follows a heal lands on the foe
  the heal mended, whoever else carries more marks (the Cleric's Cure, one patient).
- **A take** (Gilgamesh's Collect): a blow that Jams the entry its machine shows, then a step
  of his own: he gains Appropriated, that entry's number, a weapon's printed blow and 1 for
  anything else, a fake. Appropriated is his Ability, a chip he wears from the fight's start
  whose number is the piece he holds: no Purge reaches it, and what he takes next replaces
  it. His Borrowed Blade is a blow whose number is his Appropriated in place of his attack; it
  comes only as Collect's follow-up, only while he holds something, and the swing spends it. A
  Ward turns the jam and the take away together.
- **A special** stands in the blow's place as a move's first step, or follows it as a later one: brace (Armoured, its value in stacks, an armour point each, until the
  foes' next turn opens), recover (regains its value, itself), heal (the most hurt of its own, itself included, regains its
  value), brace all (the same on every foe in the fight, on the same clock), brace beside (the
  same on itself and on every foe beside it in its rank, a massive foe in a column beside it
  among them, so walls raised side by side add: the goblins' Shield Wall), revive once,
  revive an ally (Undying on one of its own, never itself, not readied already: a
  party member first, the heaviest hitter among them, then the rest of its own the same way),
  summon,
  rally (Empowered at its value on every foe on the field, itself too, at once), golden (the rage: Golden for the rounds it says, 1 to 5 and three unsaid, its value the add; only while calm), drain rerolls, ablate (stacks of Ablating on one machine), Brittle (stacks of Brittle on one
  machine), Brittle on all (the same on every machine), Sap on all (stacks of Sapped on every
  machine, through its next turn), scorch all (stacks of
  Scorched on every machine), corrupt all (Corrupted stacks on the entry every machine shows),
  jam, purge (Purge N: N stacks off every buff, for good, whatever
  granted it; the Djinn's Unmake at 1; never a last act's), cleanse
  (every mark the team laid, Ablating, Brittle, Cryo, Vitriol, Shocked, Exposed, the Web Bomb, the Paradox
  and a Mine, off the most-marked of its own, itself included, the first in strike order on
  a tie; never Numbed, never Suppressed; cast where one of its own carries a mark), barrier (a
  Barrier on itself), phase (the wait for Phased on itself: Phased, above), regenerate (Regenerating, its value in stacks, on itself), ward all (a Ward on
  every foe on the field, itself included), prime (Primed, its value in stacks, on every other foe on the
  field, at once), swallow (its machine Swallowed for its rounds, never the last machine in the
  fight, let go early once the swallower has lost a quarter of its HP), expose (its machine
  Exposed, the rider's rule as a move of its own, its intent wearing Expose's mark), merge (every other foe on the field of the kinds it names taken into it, gone with no
  fall, no last act, no split and no kill of the team's: it regrows the HP they had left, and
  its blows hit its value harder for each, Empowered that halves as its own turn ends, so
  half reaches its next blow), each on its target, no blow; a purge is a special, never a rider. A Ward turns away
  every one of them that lands on its machine, a scorch all's and a corrupt all's share
  included, and a scorch all or a corrupt all passes a machine out of the fight by. No foe in
  content carries a ward all yet; the Djinn's Unmake is the one purge cast as a move, and a Purge 1 stands ahead of
  the Pilgrim's knife, the needler line's Needles, the Old Man of the Desert's Maw and the
  Rust Monster's bite; an Expose of its own
  is the Goblin Warchief's, the Basilisk's, the Alpha Warg's, the Lich's and the Wild
  Huntsman's, each cast while another foe stands to follow it.
- **A last act**: a foe may act the moment it falls, before anything else and even when it
  was the last foe, since damage sticks for the battle. A fall is a short list of steps, as a
  move is: a death blow with its own riders, every machine included, or one special in a
  blow's place, and then what it does also, each effect by its own rules in the order
  written, as a move's are. What it aims at one machine, its single blow and its curse
  alike, lands on the machine that made the kill: the one whose spend or whose reboot's
  blast felled it, a Mine that spend sets off included. A kill no machine made lands it on
  nobody, so Ablating a foe to death dodges its blow and its curse, as a Mine blowing in the
  enemy's turn and the foe's own burst do; a killer wrecked or out of the fight by then
  takes nothing, and a Ward on it turns the curse and the blow's riders away. A blow at
  every machine lands on each. What a fall lays on its own side reaches the foes still
  standing, never itself.
  A fall may heal, armour, cleanse, ward, prime, ready or rally its own, ablate, jam or lay
  Brittle on its pick, lay Brittle on, scorch or corrupt every machine, and take back the
  readiness to rise its kind gave: every other foe still standing loses the Undying it
  readied, what a foe readied for itself staying its own, and a foe felled by the same blow
  fell readied and gets up. It does
  nothing its own body would carry, summons nothing (a split is the fall's own summon),
  swallows nothing, never purges, takes no reroll, and lays no Expose, which is announced.
  Brittle a fall lays in the player's own turn stands through the enemy's turn after it, and
  halves as the next round opens. The foe wears its fall as an Ability from the fight's start, its blow's
  number on the chip where it strikes. In content the Dread Knight's Death Throes and the
  Gargantuan King's Meteor are blows; the Mandragora screams Brittle 2 onto its killer, the
  Mandrake and the Alraune Brittle 2 onto every machine, the Gorgon's dying gaze Jams the entry its killer shows, the
  Salamander's embers Scorch every machine, and the Lich's fall takes back what it readied.
- **A foe in parts**: a core and the parts of its pack that stand with it. A guard keeps the
  core from taking any damage while all its parts stand, or while any does (Guarded, an Ability), its
  Ablating and Vitriol included, whose stacks fade all the same; a part
  that falls may grow back after so many rounds while the core stands; a core that falls takes
  its parts with it.
- **The enemy's turn**: front rank left to right, then the back; on screen each foe is lit from
  just before its move lands until the next acts. Each foe makes its move, every step of it,
  and then its own turn ends (When a status ends, above): its Ablating takes its points, which
  may fell it, then Vitriol what that leaves, and each loses a stack; its Regenerating pays;
  its Empowered halves; its Sapped goes; its Numbed loses a stack. A
  suppressed foe does nothing and its turn ends the same way, its Suppress spent and its stun
  resist landing as Numbed. A foe with no machine to strike (every one fallen or out of the fight) loses its blow
  alone: its countdown gathers, a special or a step on its own side acts, and the turn goes on to the foes
  after it.
- **A split** (the Gel): a dead Gel splits into two Half-Gels (one deep) once the spend that
  felled it is done, or at once to a tick, standing as a
  pair in the slot it fell from: a twin slot, one slot to the formation, so its hole never
  opens (the Gel is a wall, not an attacker). An area blow
  that reaches the slot (Spread, Penetrate, a Mine's blast) reaches both halves, aimed at one
  of them or beside, each half taking the number of the shape it stands in (the aimed half's
  twin the row's, or the column's when the entry reaches no row); a single-target blow, a spill included, the one it is spent on. The slot is
  full while either stands, and a half's Mine blows on its twin as on the foes round the slot.
  The left half acts first; a web on it catches its twin; a
  swap moves the pair together and never swaps a half with its twin. When one falls the other
  keeps the slot alone, still drawn on its own half of it, and with both gone it is a plain slot: the pair is only ever its
  split's, so no half joins another's slot. A Mine the Gel carried blows before the pair stands,
  so they take none of it. Their round is over: no intent, no Lure or Disrupt turns them, a stun takes
  their next action, and they act from the next round. A split that is no pair (none in
  content) steps up one into the slot and the rest into the nearest empty slots of their rank;
  one with no room never forms.
- **A summon** takes an empty slot of its rank at once, the nearest its summoner's column, the
  left on a tie, its round over like a split's half's; a call for several stands as many as fit,
  and a summoner with room for none never picks the summon. A summon may call back only what its
  pack has lost (the Wild Huntsman's Horn): it is picked only while fewer of the kind it calls
  stand in the fight than rode out with the pack, and calls no more than that, so the pack never
  grows past its start.
- **A corpse**: a part that falls and will grow back leaves its corpse in its slot, drawn dimmed
  with the rounds until it regrows, and grows back there; no swap or arrival takes the slot
  meanwhile. A part with no corpse to grow into takes the nearest empty slot of its rank,
  or waits for one. The corpses go with their core.

### Withdrawal
There is no withdrawal: a fight ends in the pack's fall or the machines' wreck. Kills stay
counted however it ends; a pack whose fight wrecks the machines in it keeps its own survivors,
who return whole (a foe that joined it in the fight, a Gel's half, a raised Revenant or a part,
is no survivor, and each of them counts as a kill as any foe does: A kill, above).

### Passives: triggers and conditions
- Triggers: static, on attack, on struck (a foe's blow landing on this machine, a time a blow
  whatever it dealt, laying a status on the striker: the Echidna's needle; a blow that wrecks it
  lays nothing), on injury (a blow that would destroy a component), on skirmish start,
  on hull damage (any hull lost: a blow, a bite or an overheat), on shield gain, on shield
  granted (an ally this machine shields), on buffing an ally (equipment this machine spends on an
  ally, once for each ally it lands on, whatever it did there), on heat gain, on foe status (a foe
  gains a debuff), on stack (this machine applies stacks), on a kill (once after an attack of
  this machine's that killed, however many fell to it, arcs and spills included:
  the Kite's shield), at the end of a round it killed in (once as the round ends, after the
  enemy's turn, for a machine whose own attack killed in it, however many fell and however
  many attacks felled them; a machine wrecked first fires nothing: the Ammit's flare), on a foe killed (every kill the death check counts in
  this machine's fight, whoever made it, once for each: the Ammit's Essence, the Buzzard's
  shield), on
  damaging a foe (after a spend of its weapons that took HP off a foe, once however many it
  hurt; what it grants lands after the spend, so the Skua's stack bounces none of the shots
  that earned it). An effect an event fires may fire once a round only (the Skua's). No trigger
  feeds itself.
- A passive may count a grant off a status its machine carries, in steps (a stack of Empowered
  for every 5 Essence), and a status may name the battle as its scope, kept from fight to fight
  (Essence). It may count an attack's add off the stacks of a status in the foe the blow lands
  on: the Echidna's Chaos, 1 more a Sonic Needle, read on every blow of its weapons on that foe,
  an area's among them (a Chain's arc and the needles' bolt are flat and take none).
- A passive may double a weapon's printed number before its buffs, on every blow, what the
  entry prints from its firer included (an area's number, heat fired), the buffs
  added once after it and the struck foe's own reads (its missing HP, the stacks consumed on
  it) after those, undoubled, and under a condition where it carries one (the Kite's, against
  an unhurt foe); it may grant a cooldown to every weapon and equipment its machine aims at a
  foe (none does today). On a kill a passive may recharge its machine's shield whole (the
  Kite's), as any shield gained is; on a foe killed it may give its machine shield (the
  Buzzard's, 2 a fall), a shield gain like any, so a broken shield takes none.
- On buffing an ally a passive may **pull** the ally's heat (the Puffin's Downwash Exchanger:
  up to 4): that much of what the ally carries, its overheat first, comes off it onto this
  machine through the heat path, so this machine may pass its own maximum and burns for it as
  the turn ends. A piece that passes heat pulls none: its heat goes the other way.
- A passive may charge every weapon its machine spends a **zap**, a cost in shield for a flat
  add (the Buzzard's: 2 shield for +2). It is paid unasked as the spend begins whenever the
  shield holds the cost: short of it the weapon fires plain, and the last point paid breaks
  the shield. The add is the attacker's, beside Empowered's, wherever Empowered's goes: every
  strike of the spend, every foe its area reaches and a Ricochet's strikes, never a Chain's arc,
  the cost paid once a spend. Equipment pays none, nor an entry that fires the whole shield. The
  die's number carries the add while the zap is ready, and its passive box shows the cost. A passive or a module may split every weapon and equipment aimed at a foe instead (the Split-cycle Breech, a module; a second adds nothing):
  each hits twice as often, and each hit's base weapon damage
  (its number and what the entry prints) is halved, rounded down and never below one, every
  buff and passive and the foe's conditions counting on each hit after it, its armour too; the
  die shows a hit's blow with the hits beside it ("1 ×2"). A debuff deals nothing to halve and hits twice
  all the same, its riders landing on each hit (a web, a Lure, a Disrupt, a Shock, an Expose
  and a swap still land once a spend).
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
  half: its damage-taken effect reads the foe whose blow it is taking, so a foe carrying Brittle
  hits it 1 lighter, whoever laid the Brittle); the target is unhurt (at its full HP) or at half
  its HP or less, each read once a hit as the hit begins, so a
  hit's strikes share one answer and the first strike of a two-strike gun does not take the
  double from the second.
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
  a flat 4, heat 6, one blow, Ballistic, the entry's keywords, rules and tags kept),
  Penetrate 2 when aimed at the back rank and Spread 2 at the front, shown on the die over the foe
  it is dragged to. The Whip Scorpion's Thermal Ejection Manifold is its boiler: its weapons'
  damage runs with its heat, half at no heat to double at its maximum along a straight line, a
  multiply after every add and held at double past the maximum, read at the heat it holds as a
  shot begins (before a Vents all shot fires it); the die's number and the bot read it the same
  way. Past half its heat maximum every hit a foe lands on it is doubled, before its shield,
  armour and a Barrier see it. Its reboot fires its locked Heliographic Death Ray first (The
  reboot, below): 2, and 1 more for every 2 heat it fires, at its heat scale, then the reboot.

### Every number is a question
Every stat, damage figure and property is read through one pipeline (`sim/effects.gd`), in
one order: suppression (shortest-lived source first), the gate (live, triggered, condition
met, and for an ability its component not destroyed), adds, multiplies, floors and caps,
overrides (shortest-lived source, then latest granted). Every buff, debuff, passive, module
and reward is a modifier with a source and a scope: rounds, skirmish, battle or loadout. The
same status in the same scope stacks: an add counts per stack, a multiply applies per stack,
and a ticking status loses a stack as its owner's turn ends, a halving one half of them, rounded
down, a buff as its turn ends and a debuff as its turn starts (When a status ends, above); a timed one stacks only with a grant that ends the same round, so each grant's stacks go
when its own rounds run out. A status runs down to zero on its own clock or is timed, never
both. A status's
definition may say otherwise: one that renews keeps one grant, its end the later and its
count the larger (Suppressed), which on an untimed one-stack status (Shocked,
Undying, Guarded) means a second grant changes nothing. Nothing writes to
a stat.

## The battlefield

- **Field**: hexes in rows from the rift to the wall, the wall's length and the depth both the
  ramp's (20 and 12 at every Convergence). The rift is five hexes, a half circle open to the field: three mid its first row and the two of the next row that touch its middle; the gate
  is the last two rows' centre (3 and 4 hexes), wall across the rest. One unit to a hex, the boss
  too. The map is a view the player turns (MAP VIEW in the settings): the wall at the left with
  the rift at the right, flat-top hexes, scrolled down the wall (the default); or the wall at the
  bottom with the rift at the top, pointy-top, scrolled along the wall. The field and every rule
  are the same in both. With the wall at the bottom the wall and the gate stand on the last row
  and their height covers the row before it; with the wall at the left they stand on that row,
  against the apron, the last row behind them the city's. The rift's vortex stands over its five
  hexes in either view, a row of scenery behind it and no more: with the wall at the left on the
  lowest of its row's three, half a hex toward the field; with the wall at the bottom on the
  middle one, ending at the five's lower edge, its eye over the rift's own row. The far ground softens
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
  (crags, mesas, towers, cliffs or chasms) with one rule under every name. Six map shapes, one a
  battle, each with its own water, walls, decorative ground and relief, laid to fill the open
  rows at any size the ramp deals, none of them a band and none an orientation. Two water
  shapes: River Crossing (one fat river winding in long bends through the whole field from
  past one edge to past the other, through the field's centre, three hexes thick and four in
  places, with one narrow a hex thick across the field's middle columns, the water ford where
  the pushers cross and the wade is short, the flanks the long wade, a crag on a bank at most,
  gravel bars along its banks; no land ford: everyone wades) and River Delta (a true delta of
  streams a hex wide: the river comes in at one end, by the seed down past the rift's end beside
  it or out from under the wall off the gate's front, runs whole and two wide for a row or two,
  then splits and splits again, each arm taking its share of the fan, until a stream runs for
  every three or four columns across the field and past its edges at the far end, where it meets
  the wall or the lagoon past the rift that a delta from the gate empties into; the streams
  wander, fork round islets and rejoin, and a short cut joins two now and then, so they braid;
  no dry way from the rift to the gate is kept, every stream a single wade; shingle on some
  shores; two to five tenths of the field water). Three wall shapes, a spectrum by the mass and the structure of what
  blocks you: Gorge (chunks of land split by chasms a hex wide winding along their borders, the
  field's and the scenery's alike, each chunk joined to a chunk beside it by a land bridge a hex
  wide or by none where the chunks stay joined the long way round; a stretch of chasm flooded now
  and then, spilling into the chasm beside it as a waterfall; scree at the chasms' edges), Ruined City (blocks of towers in a grid of streets:
  avenues one wide from the wall toward the rift four to five columns apart, the gate's always
  one and two wide, cross-streets along the wall every third row so a block is two rows deep, an
  avenue segment fallen in now and then, on a field twelve wide or more a suburb of ruins between
  one edge and its first avenue and a plaza, on a narrower one a plaza or two, two such sections
  of ruins at most, no water, rubble everywhere else, towers thick in the scenery) and Badlands (an open field of mesas in groups of two to five, many of them, a
  hex of ground between any two groups so no straight path crosses, two or three ponds of two to
  four hexes, scrub at about two thirds of the mesas' feet). And Open Steppe, the baseline and
  the anything-goes ground, clear but never bare (a wall of one to three hexes for every six
  columns of the width, half of them cliffs and the rest each of another look, never the gorge's
  chasm and never in front of the rift, a little lake of five to eight hexes for every eight and a patch of ruins of two to four for every ten, always laid,
  scrub in belts over about a sixth of the field, grass on the open ground). A battle that names no shape draws one by its seed, never by
  its domain. Every map guarantees the horde a crossing three hexes wide or more through its
  walls; the ground beside the rift (its mouth, where the packs land) and the gate, and the two
  rows before the gate, hold no wall, though water, rough and ruins may lie there as anywhere;
  every other row is the shape's, the rift's own included. Height is landscape and a look alone; no rule reads it: the field is level but for the
  badlands' mesas on their shoulders and the steppe's one rise, at most two steps and never a
  lone raised hex, water sunk and a chasm deep, and the scenery past the edges rises to three.
  The painted world stands at the same heights. A chasm is a black pit in the painting; in the
  machines' world its rock darkens down to a dim gravel floor with a stream winding along it.
  Water beside a chasm falls into it, a waterfall from the water's edge to the floor in the
  machines' world and the water's bank drawn falling in the painting.
- **Moving**: a machine's move is a count of hexes, each step one hex, and a chassis has one
  way of moving (tracked, walker, wheeled, hover or flyer), which is its look and its footfall
  and never a rule of its own. Open ground (plain, road), rough and ruins are ground to
  everyone. Water: a ground machine wades it, a water hex costing two of its move, and it can
  always enter one with whatever move it has left; a hovercraft and a flyer cross it at one.
  Walls stop all but a flyer, and the rift's shell every machine while the seal stands (the
  Rupture, below). Nobody stops on another unit's hex or a wreck's, and nothing else blocks a
  move: every unit passes every other, a machine through a machine or a pack and a pack through
  a machine, as under a flyer (they slide under each other, from two different dimensional
  counts), and the two sides meet only in a fight. Each move still lands at once, so the next is
  planned from where it ended.
- **Setup**: up to four machines on the row before the gate; the boss on its hex, the one touching both of the rift's front hexes, on the rift's middle line (the nearest free hex should a pack hold it),
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
  hunter's. Every walk's end hex is lit, tinted under the enemy's two-colour border, a deep violet line
  with the light violet's dashes crawling round it, tapped or not; where the pack attacks from that hex this turn (a pusher striking the wall, a
  hunter catching its prey), the warning stands on it, as the plan stands, and no tag says so;
  a pusher with nowhere beside the wall to land that turn stays where it is under a BLOCKED tag. A tapped pack
  shows its whole way as the field stands, past this turn's walk to its goal, dashed, each later
  turn's stop numbered, and the thing it comes for under a crawling border with the attack mark
  on it (a sword in the reticle's turning ring, one mark for both): a pusher's piece of the
  wall, a hunter's machine; no other pack's whole way shows, a selected machine's hunters'
  included. Each machine has one action (the Dingo two, by its Retrograde Flywheel: it may
  move and act twice during each turn of the map phase, and inside a fight it spends its die once a round like any machine): one move,
  laid a waypoint at a time until it plays, then it may fight; a fight ends the action however it
  ends, and the board under the map says what each can still do. The fight is ordered before the
  move plays: a move that plays (EXECUTE, ENGAGE or END TURN) with no order standing ends the
  action there, and one that plays with an order keeps that order as given, the machine taking no
  other. A machine carried in another's move keeps its action and its move.
- **Laying a move**: a tap on a machine takes it in hand and lights the hexes its move reaches,
  one border round the whole reach, its dashes crawling as its target's do, and brackets the packs
  it could be ordered onto. A tap on a lit hex lays a waypoint there, the route to it the cheapest;
  while move is left the reach is drawn again from that waypoint with what is left, and the next
  tap extends from it, until the move is spent. Every waypoint stays lit and the route runs through
  them from where the machine stands. A tap on a pack the move left reaches (from the latest
  waypoint, to the farthest hex in attack range, or from the waypoint itself when it is beside the
  pack) paths there and orders the machine onto it, one step; an order onto another pack replaces
  it. A tap on an earlier waypoint takes back every step after it; a tap on the latest waypoint, or
  on the pack it is ordered onto, executes its move at once, the machine walking there and let go.
  A tap on the machine itself, or on anything out of its reach (a hex or a pack), cancels its plan
  and lets it go, and the steps that plan put on the undo go with it; a tap on another machine
  cancels it the same way and takes that one in hand. A move that has played is taken back by UNDO
  alone. A route can also be drawn by hand for a first leg: a drag from the machine through the
  hexes it should walk, let go on a hex for a waypoint or on a pack for an order.
- **The button** reads EXECUTE while a machine is in hand, lit while it has waypoints or an order
  to play, dimmed and disabled otherwise; EXECUTE plays its move as a tap on its latest waypoint
  does. With none in hand it reads ENGAGE while a fight is ready (a catch, or a machine ordered
  onto a pack), ENGAGE 1 OF N while N fights wait, each numbered on the map in the order ENGAGE
  opens them (a catch first, then the packs in the order their orders were given), else END TURN;
  back from a fight with more waiting, the orders stand and the button pulses. ENGAGE plays any
  move still planned first (the boss's fight aside, below), then the fight opens.
- **UNDO** takes back the last step, whoever made it, in the order made: a waypoint, an order, or
  an executed move (the machine back where it stood, its waypoints and order as they were, its
  action whole again), back to the turn's start or the last fight. The machine the step was about
  comes into hand while it has a plan left, and is let go once it has none. A caught machine's
  fights come first, one a hunter, and the map draws each as the machine's order onto the hunter
  that caught it. END TURN asks first
  while a machine can still move or fight; then the turn ends: packs walk and strike; Rift
  Pressure rises one. Nothing returns on the map: the shield is full as every fight opens. Once every
  machine has fought, is ordered, is caught, or can neither move nor reach a pack where it
  stands, the button pulses while no machine is in hand.
- **A tap and a double-tap** on the map work as a die's do in a fight: a double-tap on a
  machine, the boss or a cache opens its codex, and on a pack its formation, the grid the fight
  will deal, back rank over front, a double-tap on a foe there opening that foe's codex in its
  place, BACK returning to it; a codex or a formation shuts on a tap outside it, with no CLOSE; a tap
  on one lands only once the double-tap window
  (0.1 s on the map, from the tap's release to a second touch; a die's is 0.15) has passed with no second touch, its hex
  bracketed from the touch until it does, so a double-tap never selects first; a tap on bare
  ground lands at once. A pack shows no count on the map, in its readout or its plaque: its
  formation does.
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
- **Orders**: ENGAGE opens one fight at a time: the first order's pack and every machine ordered
  onto it.
- **A fight** is one pack: nothing joins it and it joins nothing; a hunter's
  catch is a fight a hunter, one hunter a machine. The machines whose engage range covers
  it (1: beside it, the one range everyone on the map has) may join. Orders onto several packs queue, ENGAGE opening them one at a
  time, a catch first; the order changes nothing a fight opens on, its dice included: a fight's
  seed is the battle's seed, the turn, its packs and its machines. Afterwards each machine in it has used its action, a wrecked machine lies on the hex it fell on for the battle, held as
  any unit holds one: every walk passes it and none ends on it, no tear opens on it, and a cache
  under it waits unclaimed; its model lies there at its size, in its death pose as a lost
  machine goes down in a fight, dimmed, smoking, seen over both worlds as a machine is. A pack keeps only its survivors, by member, and Rift Pressure does not tick: it
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
  shares (1). They walk through every other unit and every wreck, never ending a walk on either, so
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
- **Hunters** (the packs whose composition hunts) lock one machine when they appear, by its caveat (nearest, weakest, strongest or slowest; never
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
- **The boss** holds its hex in front of the rift for the battle and never walks, whoever
  commands it. Its seal
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
  finale at 12 takes tier three's numbers): its commanders' HP ×1.1 at tier two and
  ×1.25 at tier three, their attack +1 and +2, a boss whose kit is armour its `armour_step` more
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
- **Menace** is a pack's worth, its threat rating: a lone patrol 1, a heavier patrol 2, a
  formation 3, an elite 4 and a boss's unit 4, whoever is in it, in every domain and at every
  tier. The Rupture meter, Anathema and salvage count by it. A pack's fall pays its rating
  whole. A pack a fight has worn and left standing has paid the share of its rating that its
  strike at the wall has lost, the heads gone of the heads it took the field with; its fall
  pays the rest, and nothing pays past its rating or twice, so a head raised, split off or
  grown back adds none. The boss's unit's four is a placeholder: what a boss pays in salvage
  and Anathema is the economy pass's to set.
- **The Rupture meter** fills by the menace killed, in any fight however it ended, tallied as
  each fight ends, toward the tier's Fractures (three at tier one, four at tier two, five at
  tier three). It is sized in beats of the tide, a beat a peak of Rift Pressure, two at every
  tier: the Rupture takes the ratings of the packs the opening places (the boss aside) and the
  tide sends through its second peak (the rift's compositions and the tears' patrols, as the
  peaks send them), less the lightest patrol the tide deals, which the squad may leave; and on
  top an elite's four for each elite the tier's Fractures call. So the seal is earned by
  fighting the tide, never the opening alone, the size follows the ramp's counts with no
  table of its own and is level across the domains, and more Fractures at a higher tier are
  more elites, not a longer run of beats.
  The Fractures split the size at the steps 1, 1.5, 2, 2.5 and 3, so later ones cost more.
  A Fracture pays out as a fight ends, announced over
  the map (FRACTURE with its count and what it brings, the last THE RUPTURE); an elite it
  brings is unseen until the map has glided in on its hex, zoomed, then bursts out under the
  band, which names it. At the Fractures
  the tier names (tier one's first; tier two's first and third; tier three's first, second and
  fourth) the lead domain's next own elite composition not yet sent this battle emerges at the
  rift, or a wanderer (`wanders`: Gilgamesh, the Reaper, the Wild Hunt, the World Eater, the
  Shuffler and the Astromancer, each written in one domain's list and dealt from every domain's), drawn on the
  Fracture's roll one time in three in place of the domain's own and always once its own are
  spent, the same roll picking which among those not yet sent, so every domain may meet them,
  none waits on them and nobody learns an order. An elite
  may come again in a later battle, never twice in one; a run never repeats a boss. Every elite
  stands at the battle's tier as a boss does, its HP and attack the tier's, the other members of
  its composition at their own. The last Fracture is the Rupture:
  the boss's seal breaks, and nothing else breaks it. A field cleared with the seal standing
  earns nothing by itself: it is the squad's breathing room, to reposition or fetch a cache,
  until the next peak comes on its beat. Rift Pressure keeps
  running after. A Fracture brings no prize (not built). The rift's shell is a wall along the
  outer edges of the seven hexes beside its five, the boss's among them, so the boss stands
  behind it: while the seal stands no machine enters or stands on one of the seven, a flyer as
  much as any, while the packs pass and land there as ever; each Fracture cracks one hex's
  stretch of it, the ends first and the boss's last, and the Rupture bursts it and opens the
  seven. One cache lies behind it, on one of the seven (never the boss's), its kind rolled at
  the rift's depth: the final sortie's bait.
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
  whose only tier one is a draft offers nothing until it lands); the player takes three. Four
  squad slots; the first battle is fought by those three and brings the fourth machine (The
  first battle, below). 0 salvage, 100 Favour, a blueprint for every basic, the six of tier
  zero the game deals.
- **The first battle** is the Meadow's, and a run opens on it: a forced choice of city, no
  turn passed before it is fought. The first rifts are the opening domain's, the one content
  marks (a domain's `opening`; with none marked they roll as any other), so the two first
  fronts differ by their city, and the city defended chooses the maker. Won, that maker puts up three of its machines and one is
  taken free: its chassis of the battle's tier or under that the engine fields and the roster
  lacks, drawn by the seed, fewer when it has fewer; no battle starts and no turn passes until
  one is taken. Not won, or a maker with none to put up, the draft's missing pick comes
  unasked, the machine left on the tender (and with nothing left there, content's first
  tier-one machine the roster lacks). Either way it arrives ready, in its stock. Every battle
  after is fought with four.
- **A turn** is one battle at a front, with one to four ready machines, or a pass; no turn is
  passed before the run's first battle, and once the
  finale is due no turn is passed (the Council demands the capital fought now), so the
  Convergence never runs past the finale's. The whole
  roster goes to the one front; the open fronts left alone bleed (below). A battle is played
  to its end and a team wipe is the graded loss; a withdrawal from a battle is not built (open:
  the bible's section 4).
- **Won** (the boss dies): the gate refills, the rift closes, no rift opens there next turn;
  18 salvage a pip of menace killed, the boss's included; 100 Favour less 1 per gate
  point the city lost, never below 0; a research
  token of the lead domain and an offer from the host maker are owed (the token a choice of
  three blueprints of the domain's theme at the Convergence's tier; the offer a chassis, a
  component copy and a module from the maker's catalogue, one taken free; unpacking and that
  offer not built). The first battle's offer is the fourth machine instead (The first battle,
  above).
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
- **Domains**: a rift rolls its lead domain (Meadow, Waste, Marsh, Peak; never a beaten one;
  a run's first rifts the Meadow's)
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
- Not built: building from blueprints, the offers after the first battle's, procurement, loot
  on the map, modules in the run, Sponsorship, livery, the mission map, draft and hangar
  screens.

## The quick campaign

A run of battles with no map and no cities, Slice and Dice's flow (`sim/quick_run.gd`; the
harness's Quick campaign). The campaign's rules hold where this part says nothing, and it
follows the main content and code: every fight is one pack dealt as a battle deals it (its
grid and its lead), a boss's the battle's boss unit,
and nothing scales a pack.

- **Start**: three different tier-one chassis, picked freely from every one the engine can
  field, in their stock. Four squad slots, the fourth filled by the first battle's offer. The
  party is dealt as in the campaign. The six basics are free and without limit.
- **Battles**: twelve, a tier every four, then the finale. The first is the opening domain's,
  the Meadow's, as in the campaign; each after is fought against a lead domain drawn at random
  and, from tier two, a guest. Its fights before the boss are as many as the
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
  the maker makes) and a module at or under it. The first battle's offer is the fourth machine
  instead, as in the campaign: three machines of one maker, dealt by the campaign's rule, the
  maker drawn among those with a machine to put up since no city hosts the battle.
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
  (nearest, weakest, strongest or slowest; absent: it pushes), never on an escort, which
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
