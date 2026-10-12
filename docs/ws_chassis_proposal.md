# Wainwright & Sutler: new chassis

A pitch for Ryan's candidate silhouettes (two true spider tanks, a chicken walker, a medium
gunship, a large multi-rotor, a fan-boat hovercraft). Second round, 12 October 2026, after
Ryan's verdicts on the first. Nothing here is decided. The passives come first; names,
designations and numbers follow once the passives hold, so the machines go by silhouette for
now. Numbers are placeholders in the content's tens.

## The tests this round answers

- **A chassis's identity opens build space** (bible section 7): its passive, numbers and
  locked components together, never a convenient hole or a nice-to-have. Each design names
  its routes (the different components and allies that feed it) and its payoff (what it pays
  out, and on what class of kit).
- **A map action that buys a fight buff is not a condition** (bible section 2): none of the
  six reads the map.
- **Locked components may work together, and the next chassis change another piece's reach,
  target or cost within the round rather than growing through a fight** (the live bible,
  v0.116, from the Badger's hopper). Five of the six do exactly that; the chicken walker's is
  a die structure instead, and says so.
- **Each maker owns a few keywords** (a heuristic, `docs/keyword_lineup.md` on the keyword
  branch): W&S owns Suppress, Penetrate and strikes. The spider's web runs on Suppress and the
  chicken walker's gun on strikes; on the new pieces, other makers' keywords appear only on
  locked ones.
- **Every rule is open to debate for a good reason** (bible section 2): three of the six bend
  a rule, and say which and why (the end of this page).
- **Out of bounds**: a kill making a spend Rapid (another session has it), every weapon
  Indirect (danger close is going, so it would be free reach), a decoy every hunter picks, and
  shield turned into damage (the Arsenal pitch's Misaru already reads shield gained).

## The six

| Silhouette | The axis it opens | Passive (shown text, draft) | What it changes within the round |
|---|---|---|---|
| Four-legged spider | Pinned foes as one web | A blow it lands on a Suppressed foe also strikes every other Suppressed foe, for half. | A blow's targets |
| Eight-legged spider | Heat as ammunition, vents as guns | Its vents may be spent on a foe in reach: they deal, as one blow, the heat they take off it. | A vent's target |
| Chicken walker | The die's order as the build | Its die never rolls: each round it turns to the next entry, and each reroll turns it one more. | Nothing: the die's structure |
| Medium gunship | Debuffs as sights | Its Direct weapons reach any foe carrying a debuff, in either rank. | Direct's reach |
| Large multi-rotor | The team's passives on its die | Any machine in the fight may spend its die as its own: that machine's passive and buffs apply, and it pays the heat and any bite. | Who spends it, and who pays |
| Fan-boat hovercraft | Single-target debuffs made rank-wide | Every debuff it puts on a foe drifts onto the foes beside it. | A debuff's targets |

The spider, the gunship and the fan-boat all lean on debuffs, which is W&S's suppression and
on purpose: each pays out differently (a web, a sight, a spread), and they interlock (the
fan-boat pins a rank, the spider's blow crosses it, the gunship reaches what is lit behind
it). Each has an alternative off that theme if three is one too many.

### Four-legged spider: pinned foes as one web

- **Passive.** "A blow it lands on a Suppressed foe also strikes every other Suppressed foe,
  for half."
- **What it opens.** The web is every pinned foe on the field, wherever it stands: area by
  status, a shape no keyword has. Routes to pins: its own Spinneret, the Suppression Battery,
  the Umbra Inducer, the team's (the Dingo's harpoon, the Clydesdale's battery, the Baboon's
  meter tripping at three, the fan-boat's drift pinning a rank). Payoff: any heavy single blow
  of any maker (the Howitzer, the Slugthrower, the Railgun) lands on the whole web at once.
- **Decisions.** A pin lasts until the foe's action, so the web is built and struck inside one
  player's turn: pin, pin, then strike, across the team's spends. Numbed makes a pinned foe
  harder to pin again, so the web is spread round the field rather than stacked on one foe.
- **Danger.** Four pinned foes under a 30 is 30 and three 15s; it takes four pins first.
- **Numbers and locked kit.** Medium, walker, move 30; hull 110, shield 40, armour 5, heat
  60, cooling 5, field recharge 20. Locked: the Spinneret Mortar (new), Indirect, flat 5,
  Suppress, Rapid, heat 10: a cable net thrown anywhere, and the die rolls again, so it can
  pin and strike in one round alone. Four hardpoints (d5).
- **Stock.** Howitzer, Slugthrower, Suppression Battery, Laminar Deflector.
- **Engine.** A blow's damage, halved, dealt to every other Suppressed foe through its own
  armour and modifiers.
- **Model.** As the first round's (Ghost in the Shell's spider tank on howitzer trail spades),
  the Spinneret a stubby tube at the hull's tail.
- **Alternative.** "Spending equipment drives its spades in: its next weapon strikes twice."
  Any shield, vent or buff as the fuel, paid in tempo; it banks one charge, which the newest
  guideline would rather it did not.

### Eight-legged spider: heat as ammunition, vents as guns

- **Passive.** "Its vents may be spent on a foe in reach: they deal, as one blow, the heat they
  take off it."
- **What it opens.** The Wild Wild West spider as a boiler. Routes to heat: hot weapons of any
  maker (the Overclocked Railgun's 40, the Suppression Battery's 20, the Meteor Artillery's
  15), the Thrust Overboost module (weapons twice as hot), and the foes themselves: with the
  overheat now at the end of the player's turn, a foe's heat waits on the gauge for the next
  turn, so the Peak's heat moves and scorch become ammunition. Payoff: every vent of any maker
  becomes a gun (the Coolant Jacket, the Coolant Dump, the Entropy Condenser, the Radiator
  Sail, the Ram-air Scoop; the Wake Diffuser scalds for 10 and rolls again).
- **Decisions.** Each vent: scald a foe, cool an ally, or hold the pressure; with cooling 0 an
  overheat is always one spend away, and venting before the turn ends is how it avoids one.
- **Kinship.** The Goshawk's Afterburner Cannon fires its whole heat gauge into one shot. This
  fires heat through any vent, so its build is a class of equipment rather than one cannon.
- **Numbers and locked kit.** Heavy, walker, move 20; hull 150, shield 30, armour 10, heat
  100, cooling 0 (the Stingray's precedent: the vents are its only brake), field recharge 15.
  Locked: the Steam Cannon (new), Direct, flat 30, heat 30, the pressure. Four hardpoints (d5).
- **Stock.** Coolant Dump, Coolant Jacket, Suppression Battery, Maxigun.
- **Engine.** A vent spent on a foe in Direct reach, its blow the heat it removed (its number,
  or the heat carried if less).
- **Model.** As the first round's (a riveted cab with eight lamps, eight legs arched over a body
  slung low), the abdomen a boiler with its stack, the Steam Cannon between the fangs, and
  vent grilles along the abdomen glowing brighter the more heat it carries, so the pressure
  reads across the map.
- **Alternative.** None as strong yet; a passive that spends its heat on allies (its weapons'
  heat lands on an ally of the player's choice, feeding the Goshawk's shield or the Stingray's
  stacks) is the team version.

### Chicken walker: the die's order as the build

- **Passive.** "Its die never rolls: each round it turns to the next entry, and each reroll
  turns it one more." The first entry of a skirmish is a spin.
- **What it opens.** The loadout's order is a fire plan, a build axis no machine has. A
  suppress lined up before the boss's telegraphed round; a shield before the big blow; a burn
  and then the finisher; a duplicate to repeat a beat (two Howitzers in six chambers fire
  every third round); a blank as a known rest. Locks hold a chamber through the team's
  rerolls; the team's rerolls advance it, at the price of the dice that wanted them.
- **Decisions.** In the hangar, the order; each round, whether to spend the team's rerolls
  turning it.
- **The cost.** No luck either way: a destroyed component is a known dead chamber each turn,
  and a foe's Disable or Scramble lands on a plan.
- **Numbers and locked kit.** Medium, walker, move 40; hull 90, shield 40, armour 5, heat 60,
  cooling 5, field recharge 20. Locked: the Hogleg (new), Direct, two strikes of 10, heat 10,
  the hammer fanned. Five hardpoints, so a six-chamber die.
- **Stock.** Suppression Battery, Twin Autoguns, Incendiary Shells, Ankle Mortar, Laminar
  Deflector.
- **Engine.** The die turns instead of rolling, rerolls turn it and locks hold it; the held
  die marks the next chamber.
- **Model.** As the first round's AT-ST, with a revolver drum on the cab's flank that clicks
  round at each round's start: an act, and the tell for the next chamber.
- **Alternative.** "Spending a weapon also fires the next weapon on its die, at half." The
  order as the build within a spend rather than across rounds.

### Medium gunship: debuffs as sights

- **Passive.** "Its Direct weapons reach any foe carrying a debuff, in either rank."
- **What it opens.** A debuff on a foe (Burning, Suppressed, Shocked or Paradox, what the team
  put on it) lights it for the gunship's Direct guns. Routes: its own Indirect debuffers (the
  Incendiary Shells, the Suppression Battery), the team's (the Dingo's harpoon, the Polarity
  Projector, the Paradox the Baboon's meter lays, the fan-boat's drift lighting a rank).
  Payoff: Direct heavy hitters of any maker (the Slugthrower, the Overclocked Railgun, the
  Enfilade Beam) on the back rank. A Shocked healer behind the front takes the Railgun double.
  It touches only its own Direct reach, and needs no danger close either way.
- **Decisions.** Light first, then shoot; which back-rank foe to light; who on the team lights
  it.
- **Numbers and locked kit.** Medium, flyer, move 30 (the slow flyer); hull 100, shield 40,
  armour 5, heat 60, cooling 5, field recharge 20. Locked: the Flare Rockets (new), Indirect,
  flat 10, Burn, Rapid, heat 5: it lights a foe anywhere and rolls again. Four hardpoints (d5).
- **Stock.** Slugthrower, Enfilade Beam, Maxigun, Laminar Deflector.
- **Engine.** Direct's valid targets gain a back-rank foe carrying a debuff, for this machine.
- **Model.** As the first round's Hind, with flare pods under the stub wings.
- **Alternative.** Off the debuff theme: "Its die shows two entries each round, pilot and
  gunner; it spends one." Situational kit becomes worth fitting, though it sits near the
  Clydesdale's free reroll.

### Large multi-rotor: the team's passives on its die

- **Passive.** "Any machine in the fight may spend its die as its own: that machine's passive
  and buffs apply, and it pays the heat and any bite." (A bite: a volatile component's hull.)
- **What it opens.** Its loadout is built for the team: big flat guns for the Sparrowhawk to
  fire at double damage; melee and volatile kit for the Nemesis's Crucible; stack appliers
  for the Stingray; shields for the Puffin, which vents whoever it shields; status pieces for
  the Baboon's meter; hot weapons for the Goshawk's shield. A sutler supplied an army in the
  field: this is the maker's own name, a sutler's wagon in the air. Its verb is supply, never
  launching, so it leaves Aphelion's Carrier (bible section 7, open) its own.
- **Decisions.** Each round, whose hands its die goes to.
- **Danger.** The team's best passive on an extra die every round, bounded by one die a round
  and the spender's own heat (a Sparrowhawk doubling it pays double).
- **Numbers and locked kit.** Assault, flyer, move 20; hull 170, shield 50, armour 5, heat 80,
  cooling 5, field recharge 15. Nothing locked: its kit is the team's. Six hardpoints (d6).
- **Stock.** Howitzer, Enfilade Beam, Maxigun, Incendiary Shells, Laminar Deflector, Coolant
  Jacket.
- **Engine.** A spend whose die belongs to one machine and whose passive, buffs and heat
  belong to another; a gesture to hand the die over on the phone (dragged onto an ally's
  portrait, say); the bot choosing the spender.
- **Model.** The V-12 with its deck, as liked. Ducted fans set in a deck are open too, if the
  helicarrier itself is wanted.
- **Alternative.** "Spending a weapon also fires the next weapon on its deck, at half." A
  ripple across the deck.

### Fan-boat hovercraft: single-target debuffs made rank-wide

- **Passive.** "Every debuff it puts on a foe drifts onto the foes beside it."
- **What it opens.** Any single-target debuff becomes a rank's. Routes: burn (the Incendiary
  Shells, the Blazethrower, the Meteor Artillery), Primed from an ally's Aurora Lattice (each
  blow leaves Burning, which drifts), suppress (the Suppression Battery, the Umbra Inducer),
  shock (the Polarity Projector, the Tesla Gauntlets). Payoff for the team: three Shocked
  foes for three doubled blows, three pinned foes for the spider's web, a burning rank; every
  drifted debuff feeds the Baboon's meter. The drift never drifts again.
- **Kinship.** The Arsenal pitch's Mastema passes a Burning foe's stacks to its neighbours
  when it dies. Both spread to the row; the fan-boat spreads what it lays as it lays it, any
  debuff, where Mastema spreads the team's burn through kill order.
- **Knobs.** Three suppressed foes a spend is strong (each foe's Numbed still slopes it); if it
  is too much, only stacks drift.
- **Numbers and locked kit.** Light, hover, move 50; hull 60, shield 30, armour 0, heat 60,
  cooling 10 (the fan), field recharge 30. Locked: the Bayou Torch (new), Direct, flat 10,
  Burn, heat 10, the fan blowing the flame down the rank. Three hardpoints (d4).
- **Stock.** Incendiary Shells, Twin Autoguns, Laminar Deflector.
- **Engine.** A debuff it lands is copied once to the target's neighbours in its rank.
- **Model.** As the first round's airboat on a skirt, the torch at the bow in place of the punt
  gun.
- **Alternative.** Off the debuff theme: "Each vent it spends on an ally loads its guns: its
  next weapon deals 5 more for every 10 heat it took off them." The team's heat as its
  ammunition; it shares vents with the boiler spider.

## The rules these bend, and why

- **Equipment is spent on a machine** (bible section 7): the eight-legged spider spends vents
  on foes. The redirect is its identity, and the vent still does its own job.
- **Every die rolls; entries are equally likely** (`docs/rules.md`, the round): not the chicken
  walker's. An ordering axis no other machine has, W&S's "everything works" as a die, and the
  team's other dice keep their luck.
- **A machine spends its own die**: not the multi-rotor's. The most soft synergy one passive
  can buy, with no lynchpin.
- Two stretch rather than bend: the gunship's reach is the first to depend on its target (a
  passive may already change reach), and the spider's web is area by status where the
  keywords' area is by shape (the open "area by shape" row).

## The first round, retired (Ryan, 12 October)

- Four-legged spider, fighting without having moved gives Spread: a map action buying a fight
  buff is free, and Spread on everything opened no build.
- Eight-legged spider, crags slow ground: a map rule alone is a weak identity.
- Chicken walker, a spend that kills is Rapid: it belongs on a vicious Arsenal machine, and
  another session has it.
- Gunship, every weapon Indirect: danger close is going, and full Indirect is then free reach.
- Multi-rotor, Indirect weapons strike twice: dangerous as written (the visual stays).
- Fan-boat, every hunter takes it as prey: the Prairie Dog's original passive; it scraps the
  machine unless it kites, and kiting is a dangerous road.
- Not holes after all: the maker profiles are guidelines, the other makers are being
  fleshed out elsewhere, and fans set in a deck were only ever the Stingray's.
