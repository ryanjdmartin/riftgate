# The roster analysis

Claude's reading of the current roster and the proposed chassis, for Ryan to move, 14 October
2026, from the brief in `docs/mechanic_budgets.md` (Ryan's brief of 14 October) and the records
alone: `docs/rules.md`, the bible at v0.158 (its first row, the balance rows of section 11,
sections 5, 7 and 10), `docs/measurements.md`, `content/*.json` and the three proposals on main
(`docs/arsenal_proposal.md`, `docs/ws_chassis_proposal.md`, `docs/aphelion_chassis_proposal.md`).
Nothing here is built, run or measured: the proposals are theory, no stand-in was fielded, and
the runner's rows appear only where they diagnose the roster as it stands.

Since 15 October this page is background. Ryan's go on it is recorded where the conventions put
it: decisions as bible rows and lines in `docs/rules.md`, each proposal, direction and rework as
a design-session brief in `docs/briefs/`, tasks in `docs/todo.md`, the economy items in
`docs/economy_pass.md`. The three proposal files it rates and the brief in
`docs/mechanic_budgets.md` were folded into the briefs and retired to git that day. Sections 1
to 11 are the analysis as written on 14 October, under the old whole-block shield rule; where a
brief differs, the brief is newer. The page retires to git once the last brief that cites it
lands.

## How to read this

- **Fit, not viability.** Each design is rated for the place it takes in the ecosystem: what it
  does that nothing else does, what it gives a team and needs from one, and how many directions
  its hardpoints reward. Whether it would win is not asked. Every number in content is a
  placeholder, nothing is balanced yet, and the bible's balance rows hold: the unit of balance is
  the composition, a solo row is a diagnostic, and a support or specialist frame is expected to
  lose most fights alone.
- **The four axes**, each read as a band (strong, sound, thin, or open where it waits on a
  decision in the records):
  - *Quality*: the design holds together. One passive, one idea; the locked pieces say the same
    thing the passive says; the numbers and the way of moving agree with it; nothing in it
    contradicts a rule it does not mean to bend; the rule text fits the budget.
  - *Niche*: what it does that nothing else does. The brief's second rule is the test: it reads
    a state nobody reads, produces a state nobody produces, or changes what a kind of piece does;
    another source of an existing state needs a reason beyond its maker's flavour.
  - *Build diversity*: how many directions its hardpoints and passive reward with generic kit.
    The brief's fourth rule is the test: two routes in and two payoffs from other makers' pieces.
    A die that collapses onto its locked pieces, or a passive that generic kit cannot touch, is
    thin.
  - *Composition*: what it gives a team and needs from one, and whether it can detach (section
    4's four-machines row: the squad moves as one and a detachment is a decision priced by time,
    so the roster needs identities that can take a small pack alone and identities that are only
    good together).
- **The verdicts.** A current machine *stands*, *stands with a question*, or *needs the stock
  pass* (its design is sound and its stock is the problem). A proposal has *a place*, goes *back
  to the board* with what it needs to come back with, or is *unfinished* (Aphelion's, whose
  session ended before its questions closed; this page lists them and guesses no verdict).
- **Whose words.** A line marked Ryan with its date is his call, from the records. Everything
  else is Claude's reading, there to be argued; the brief's budgets are argued in section 6, and
  the ideas this page sets aside are in section 11 with the rule that killed each, so Ryan can
  overrule the rule and not only the idea.
- **The runner's rows.** Where a row of `docs/balance.md` or `docs/measurements.md` is quoted it
  is a diagnostic of the greedy bot on placeholder numbers: the bot values nothing it cannot
  forecast in one round (a shield handed away, a status laid for an ally, a second action on the
  map), so its rows say nothing against a support frame and are never a rating. The one
  diagnostic used often is pick share, how a machine's spends divide between its entries, read
  as whether a die has more than one thing worth spending.
- **What this page does not do.** It names no name, number or look for Minerva's and Kestrel's
  gaps (Ryan matches mechanics to his silhouettes in another session; the labels in section 8
  are the mechanics', not names); it writes no heat report (the stock pass's); and nothing of the
  struck Minerva and Kestrel designs is in it, by Ryan's call of 13 and 14 October.

## 1. The ecosystem the designs are fitted against

What the game asks of a machine, from the rules and the bible as they stand, so the ratings have
something to be rated against.

- **Four questions.** Each domain asks one (bible section 9): the Meadow numbers that swarm
  (area, armour against volume, kill order); the Waste fixed damage no shield answers and theft
  of rerolls and entries (hull and tempo over shields, redundancy on the die); the Marsh things
  that will not stay down (kill order, reach to the healer, burst); the Peak hard hits on a
  telegraph and heat (shields for the telegraph, cooling, a lure onto a cold machine). A run
  meets them in whatever order its fronts open, with one guest at most, so a team of three or
  four must hold an answer to each or pay in time.
- **Four machines, moving as one.** Concentration halves the hull a fight costs with every
  machine added (the one-to-four measurement, 13 October), so the squad moves as one and a
  detachment is a decision priced by time. The roster needs identities that can take a small
  pack alone for a tenth of their hull, and identities that are only good together; the Honey
  Badger is the one named today, and the cars' map rules sit on dice that cannot detach.
- **The composition is the unit of balance.** If every machine is a solo carry, a battle with
  four is trivial (section 11). The runner showed that count dominates composition today: a
  four of tank, controller, bruiser and support reads the same as a four of hitters, which says
  the roster's team verbs are too quiet for the bot to see, not that they are worthless.
- **The tiers as dealt.** The tender offers one tier-one machine from each city maker and the
  player takes three; tiers two and three come as the host maker's offer after a won battle at
  its city (a chassis, a blueprint and a module, one taken free) and from procurement (a chassis
  on the shelf more often than not; placeholder, at least one a turn); the Arsenal fields no
  tier one and sells its trickle at the capital. A chassis's tier is complexity (a sharper
  passive, more locked pieces, a higher ceiling and a lower floor), a component's is power, a
  chassis stocks only below its own tier, and the basics are tier zero. Section 5 reads the
  roster through this.
- **The map.** Five ways of moving over five map types, each with a good and a bad ground; four
  size classes; an attack range of two hexes, rings of one to three; hunters that lock a
  machine. A chassis's silhouette is a terrain trait, so the set should spread across the ways.
- **The dice.** Three rerolls a round for the team, never banked; a die of four to nine entries;
  heat the one cost that competes with damage on the same die, and barely felt outside the Peak
  today (the stock pass re-prices it); no cooldowns (open, section 7); hard control budgeted and
  Numbed the brake.

### The census by verb

The brief's table, recounted from `content/components.json` and the chassis passives. A piece
counts once; locked pieces are marked, since a locked piece is a route only for its own
machine.

| Verb class | What it does to a fight | Carriers today | Among the proposals |
|---|---|---|---|
| Hard control: a foe loses its action | removes a turn | Suppress on the Suppression Battery, the Umbra Inducer and the Megataser Harpoon (locked, the Dingo); the Pocket Paradox (the Baboon's passive). Three pieces and one passive in 54 | Misharu's sentence (a passive the enemy triggers); the funnel-web's web bomb (a passive, two actions a web); the jellyfish's spread, which triples whatever status it carries, Suppress included; the funnel-web's fangs read Suppressed |
| Soft control: a foe changes what it does or where it stands | changes the enemy's problem | Lure (the Proximity Klaxon); Disrupt (the Differentiation Probe). Two pieces, no passive | Minos's turn of the ranks (a passive) |
| Damage over time | hull at the foe's own actions | Burn on the Incendiary Shells, the Blazethrower, the Meteor Artillery, the Solar Flare Array (locked) and the Photosphere Lance (locked); Primed (the Aurora Lattice); the Exothermic Suite deepens them. Five pieces, a buff and a passive | Mastema's Bellows, Ewer and Ward (a passive and two tools); the Onryō's Grudge (a passive); the Scapegoat Brand (moves Burning onto a foe) |
| Amplify: the next blow lands harder | sets up a kill | Shock on the Polarity Projector and the Tesla Gauntlets (unstocked); Retaliate (the Retribution Thurible); the Faraday Hull (passive); Overcharged on the Overcharge Coil (the Puffin's stock), Devour (the Ammit's talons) and the Grievance Reliquary (a module); the Susceptibility Tensor (a module) | None as a chassis identity. The gunship's Arc row raises its own rolls; the multi-rotor lends its die to whichever passive amplifies it |
| Tempo: act again | more spends a round | Rapid on the Wake Diffuser, the Laminar Deflector, the Flakshot Repeater (locked) and the Pulse Vacillator (unstocked); rolls again (the Knuckle of Fury, locked); Chain (the Arc Fault Cannon); the Dingo's two actions; the Clydesdale's free reroll | The revolver's sequence; Rapid shells on the fan-boat; the Zoids walker's kill-Rapid (open) |
| Area: more than one foe a blow | answers numbers | Spread on the Chainsaw Claw (locked), the Breaching Plow (locked) and the Proximity Klaxon (no damage); Penetrate (the Enfilade Beam); Spillover (the Wild Boar's passive). On a hardpoint, one damaging piece | The explosives carrying Spread and Penetrate (the stock pass, decided); the jellyfish's spread of effects; Mastema's fire travelling along a rank; Minos turning three columns with Spread |
| Sustain: shield, vent, armour, cleanse | takes a blow | Seven shields, eight vents, Braced (the Shoring Jack, the plow), Cleanse (the Corona Shield, the Phased Sublimator), Overshield (the Backwash Ionizer), the Thermal Recoupler; three modules | The Votive Ward; the Pall; the Vigil Pavise (the first self overshield); the Carrier's screen (open) |
| Self-cost: a price in hull, heat or something else | a price beside the die | Volatile (the Oblation Ward, the Entropy Condenser); the Tithe Coupling; the Sparrowhawk's double heat; the Stingray's cooling 0; the rage reads it | The boiler's cooling below zero; the Pall's moved wounds; Mastema's blank entries until burn is down |
| Ramp: grows through a fight | rewards the long fight | The hopper; Devour kept for the battle (the Ammit); the Stingray's heat; the Goshawk's heat; the rage | Grudge; the Carrier's interceptors (reopened); Mastema's fire as it spreads |
| Changes what a kind of piece does, on this machine | the rules bend for its kit | The Sparrowhawk (every weapon doubled), the Wild Boar (every weapon spills), the Stingray (every stack deeper), the Puffin (every shield on an ally vents) | The fan-boat (every weapon fires the deck gun), the gunship (every weapon is a stat), the revolver (its die steps), Misharu (every shield is bait) |
| Changes what a kind of piece does, for the team | the rules bend for everyone's kit | None | The multi-rotor (any machine spends its die) |
| Strips the enemy's buffs | answers Harden, Rally, Reraise | None (decided 12 October, not built) | The jellyfish's EMP, the dispel's first carrier |

Three corrections to the brief's table, for the record: Shock and Retaliate are amplify, not
control, and the Faraday Hull with them; the Overcharge Coil is in the Puffin's stock, so
Overcharged has a source on a die today; and "changes what pieces do" is not empty, four
passives do it for their own kit, where the multi-rotor alone would do it for the team.

### The census by what a passive reads and produces

The niche test asks what each passive reads (its trigger or condition) and what it produces.
Reads that several share are where the roster repeats itself; reads nothing uses are where a
new chassis finds room.

| Read | Who reads it today | Who would, among the proposals |
|---|---|---|
| A foe gains a debuff | the Baboon | the jellyfish (spreads it), Misharu and the web bomb (add one) |
| This machine's heat | the Goshawk (shield), the Stingray (stacks) | the boiler (blows) |
| A blow reaching this machine's hull, or any hull | the Polar Bear (Shocks the striker), the Nemesis (banks rage), the Spall Liner and the Grievance Reliquary (modules) | the Onryō (Grudge on the striker, team-wide) |
| A kill | the Ammit's talons (Devour), the Arc Fault Cannon (Chain) | Mastema (a burning foe's death), the Zoids walker (Rapid, open) |
| A shield this machine grants | the Puffin | nobody |
| A shield this machine gains | nobody | nobody (the line frame's round one, superseded) |
| Its own die's state or order | nobody | the revolver (its order), the multi-rotor (lent) |
| The map | the Prairie Dog (never hunted), the Dingo (two actions) | nobody |
| A foe's missing or current hull | the Pinion Driver (a rule on one piece) | the funnel-web's fangs (current hull of a Suppressed foe) |
| A shield breaking | nobody | Misharu |
| The count of foes in a state | nobody | the Votive Ward |
| A foe's rank | nobody (Direct's reach is a rule, not a passive) | Minos |
| Which weapons are fitted (tags) | nobody | the gunship, the line frame's Beam passive (open) |
| The foes' intents or targets as drawn | nobody | nobody |
| The reinforcements waiting | nobody | nobody |
| Unspent entries, blanks, locks, the team's rerolls | nobody | nobody |
| A foe's buffs | nobody | the jellyfish's EMP |

### The roster by maker, tier, size and way of moving

| Maker | Tier one | Tier two | Tier three | Among the proposals |
|---|---|---|---|---|
| Minerva | Honey Badger (heavy, tracked), Polar Bear (assault, walker) | Wild Boar (heavy, tracked) | none | none standing; section 8 |
| Kestrel | Sparrowhawk (light, flyer) | Goshawk (medium, flyer), Puffin (light, hover) | none | none standing; section 8 |
| Wainwright & Sutler | Prairie Dog (light, wheeled), Dingo (light, wheeled) | Clydesdale (assault, walker) | none | the fan-boat (1, light, hover); the boiler, the revolver, the funnel-web, the gunship (2); the multi-rotor (3, assault, flyer) |
| Aphelion | Baboon (medium, walker), Stingray (medium, hover) | none | none | the line frame (1, walker); the jellyfish (2, flyer), the Zoids walker (2, open); the Carrier (3, assault, flyer) |
| The Arsenal | none, by rule | Nemesis (heavy, walker) | Ammit (medium, walker) | Misharu (2, heavy, walker), the Onryō (2, medium, walker); Mastema (3, heavy, flyer), Minos (3, medium, hover) |

Thirteen machines: five walkers, two tracked, two wheeled, two hover, two flyers; four light,
four medium, three heavy, two assault. The fourteen proposed (the parked hovercraft aside):
seven walkers, five flyers, two hover, no tracks and no wheels.

### What the census says

1. **Hard control is three pieces and a passive, two of them in tier-one kits** (the Inducer
   twice in the Baboon's stock, the Harpoon locked on the Dingo), which is why it reads as
   prevalent: the stock pass takes the Inducers out of a tier-one stock, and the Harpoon stays as
   the one locked stun a tier-one chassis may carry. The proposals would add two hard-control
   passives and a tripler; section 6 proposes the count that lets the right ones in.
2. **Soft control is the thinnest class and has no chassis identity**: two pieces, on Minerva's
   and Aphelion's stock, and Minos the one proposal. It is also the class the brief prefers,
   and Lure is Minerva's lean carried by one piece.
3. **Damage over time is where the proposals crowd**: Mastema's three pieces, Grudge and the
   Brand on top of five burners, Primed and the Stingray.
4. **Amplify for others has no chassis identity**: the Polar Bear produces it as a side effect of
   being struck and the Stingray deepens buffs, and no passive is about making an ally's blow
   land harder, though Overcharged is Kestrel's lean.
5. **Area damage on a hardpoint is one piece** (the Enfilade Beam) until the stock pass puts
   Spread and Penetrate on the explosives; the Meadow's answer lives on locked pieces today.
6. **Two reads are crowded**: this machine's heat (the Goshawk, the Stingray, the boiler) and a
   blow on hull (the Polar Bear, the Nemesis, two modules, the Onryō). Each has distinct payoffs,
   which is what keeps them apart.
7. **Nothing reads the foes' intents as drawn, the reinforcements, or the die's own unspent
   entries and locks.** These are the room.
8. **Three makers have no tier three and one has no tier two**, and Kestrel has one tier one, so
   its tender offer never varies. Section 5.
9. **The proposals are walkers and flyers.** No tracked or wheeled machine is proposed, so the
   Steppe's and the Flooded map's specialists stay the cars and Minerva's tracks.

## 2. The roster

Each machine: the idea as the bible's chassis table has it, the four axes, the verdict, and
what it needs. The runner's diagnostic, where quoted, is the greedy bot's pick share from
`docs/balance.md` (13 October, 200 seeds, placeholders) and says only whether the die has more
than one thing worth spending.

### Honey Badger (Minerva, tier one, heavy, tracked)

*A brawler whose claw fills a hopper its fragmenter fires; its components crack but are never
destroyed.*

- **Quality: sound kit, thin passive.** The locked pair is the model the bible holds up for
  pieces that work together: the Chainsaw Claw's spread fills a load a foe, the Bullion
  Fragmenter fires three at +5, and the round holds decisions (claw before fragmenter, fire now
  or bank, reroll toward the pair). The passive is the problem the bible's open row already
  names: "never destroyed" has no job in a fight, since the injury threshold at a quarter of
  maximum hull spares a heavy machine anyway (11 October: no heavy machine is ever injured), so
  the passive fires in the campaign about never and says nothing about who the machine is.
- **Niche: strong, on the locked pieces.** The only store filled by one piece and fired by
  another, and the roster's one named detachment identity: it takes any small pack alone for a
  tenth of its hull (the cars row, 13 October). Its niche sits entirely on its kit; the passive
  adds none.
- **Build diversity: thin.** Three hardpoints, untyped, and nothing rewards a direction: only
  the claw fills the hopper and only the fragmenter fires it, so a gun, a shield and a lure are
  all equally fine in its slots and no other maker's piece has a route in. The fourth rule
  fails outright. The diagnostic agrees: the bot spends 78% of its entries on the locked pair
  and about a fifth across three hardpoints.
- **Composition: sound as a body, thin as a partner.** It gives the team a front and a boss hit
  built from a crowd, needs nothing from anyone, and hands nothing to anyone: no state another
  machine cashes, no protection. Can detach: yes, the clearest in the roster.
- **Verdict: stands, with the open row.** Ryan's question of 12 October (damage, support, a
  tank, or the mining roots) folds in here. Claude's lean, under the fit lens: the identity
  should live where the fight is, and the hopper is already the mining in it, so the passive's
  business is the hopper and the hardpoints get a route in. The shape: *every weapon it fires
  puts a load in the hopper for each foe its blows reach, the claw's spread fastest; the hopper
  holds so many loads; loads held are plate (armour per load) and loads fired are damage.* Then
  every blow is ore, any maker's Spread, Penetrate or multi-strike piece is a filler, and the
  round's decision deepens: hold the ore and stand, or fire it and hit. "Never destroyed"
  leaves the passive for a Minerva module (platings are modules; a low-stats, good-text
  module), where its campaign meaning survives. The holes: a filler on every weapon overflows
  the hopper unless the cap bites, and a hopper always full makes the fragmenter a flat number
  again, so the cap and the armour per load are the levers; the claw's three loads a swing must
  stay the best fill or the claw becomes a plain gun. The bench holds the three earlier shapes
  (section 11). Nothing of this is built; it is the roster's one identity question and Ryan's
  to settle.

### Polar Bear (Minerva, tier one, assault, walker)

*The tank: its shutters and live hull Shock whatever strikes it.*

- **Quality: sound.** The toughest numbers in the roster (armour 15, hull 150) and a passive
  that turns being struck into the team's next kill: Shocked doubles the next blow, which is
  the bible's own line on a tank, "sets up kills, and does nothing else". The Lockdown Shutters
  extend it to blocked blows, so a shield on a hardpoint does not fight the passive. It holds
  together; the question on it is Ryan's (12 October): if a retaliation mechanic must go, this
  goes first, the Polar Bear being armoured and not a porcupine.
- **Niche: sound, and shared.** The tank by numbers is a niche of plain numbers, which the
  bible allows. The passive's read (a foe's blow on this machine) is the roster's most crowded,
  and its product is exactly the Retribution Thurible's: a buff any machine fits for a
  hardpoint and two rounds that does what the Polar Bear's passive does. That is the overlap
  that costs the Polar Bear its niche, not the Nemesis (which banks tempo) or the proposed
  Grudge (a slow curse).
- **Build diversity: sound.** Five hardpoints; every gun on the team cashes its Shocks, so the
  payoffs are everything; the routes in are the enemy's blows and anything that draws them (the
  Klaxon's lure). The diagnostic shows a die spread across three guns.
- **Composition: strong.** It gives the team amplified kills it is badly placed to take itself
  (the machine being struck is the one not shooting), so its best partner is a hitter that
  doubles on a Shocked foe, and the Sparrowhawk doubles twice. It needs hitters. Can detach:
  yes.
- **Verdict: stands; keep the Faraday Hull.** Claude's lean on the open row: the passive is
  worth keeping because it is the one tank passive that composes, Shocked-as-setup is a decided
  design line, and the Arsenal's retribution is a lean and never an exclusion (first row). What
  should move is the duplicate: the Retribution Thurible gives the Polar Bear's whole passive to
  any machine as stock kit on the Nemesis, so either it differs on purpose (a Shock from
  blocked blows too, the shutters' half, or a longer buff at a cost) or it becomes the rare,
  tier-three way to borrow the Polar Bear's trick, and the Nemesis stocks something of its own.
  If Ryan removes the Hull anyway, the replacement should still be something the team cashes,
  and the bench has the shape that fits the fantasy best: a conditional draw on the locked
  shutters (section 11), the interpose the bible allows on a locked piece and the mitigation
  the starter set was asked for (30 September).

### Wild Boar (Minerva, tier two, heavy, tracked)

*Dives in: every weapon spills past a front-rank kill.*

- **Quality: sound, and quiet.** The spill from any gun and the plow that braces the charge say
  one thing: through. The passive is unconditional and its value is rare (a foe behind with
  blow to spare), which the bible accepts: it opens flexibility the runner cannot see and is
  buffed if weak.
- **Niche: sound, conditional on back ranks.** The only machine whose damage reaches the back
  through the front from any gun, and the only Braces carrier. Penetrate does a column
  outright; Spillover is Penetrate on a kill. Only formations have a back rank today, so its
  worth waits on the foes' fresh start, as the bible says of Minos too.
- **Build diversity: sound.** Five hardpoints; the passive rewards overkill, so big flat hits,
  Overcharged and a raised ceiling are directions, from any maker; the payoff is its own. The
  diagnostic: two entries carry 79% of its spends, the Slugthrower and the plow, which is the
  stock, not the design.
- **Composition: sound as a body, thin as a partner.** A front-line body whose extra reaches
  foes the team's Direct guns cannot; it hands nothing to allies and needs nothing. Can detach:
  yes.
- **Verdict: stands.** Nothing to change now; the star chip for its entries in the stock pass;
  its slot in a four is worth more once back ranks are common.

### Sparrowhawk (Kestrel, tier one, light, flyer)

*Double damage and double heat on everything.*

- **Quality: strong.** The bible's model of a double-edged niche definer, and the one machine
  that feels heat today. With the Pinion Driver locked in the stock pass (the finisher: flat,
  and more for every 20 hull the target is missing), the kit says assassin as plainly as the
  passive says glass.
- **Niche: strong.** Burst and the finish; the only heat-feeler; the machine that cashes a
  Shocked foe at four times.
- **Build diversity: sound, on a small die.** Every weapon of every maker reads differently on
  it, since each is doubled and so is its heat: the cold kinetics of Minerva and Wainwright &
  Sutler become its best guns, and the hot ones become volatile by another name, which is a
  cross-maker pull the roster wants more of. Three free entries after the lock limit the
  directions to three.
- **Composition: strong as the cash-out.** It needs a body in front (no armour, 60 hull: a
  formation kills it) and a setup to spend; it gives the kill. Can detach: at a price (a pack
  alone costs it a third of its hull, by the one-to-four measurement), which is the
  interceptor's fantasy half-delivered: see Kestrel's gaps, section 8.
- **Verdict: stands.** The stock pass's lock and basics.

### Goshawk (Kestrel, tier two, medium, flyer)

*Shield from its heat, and one blow that fires it all.*

- **Quality: strong.** Sustain split from burst, each round a choice between riding hot for
  shield and dumping the heat into the Afterburner Cannon: a two-way decision on one resource,
  the cleanest loop in the roster. The game's first in-fight regen, kept safe on one chassis.
- **Niche: strong.** The only in-fight shield regen and the only weapon that vents all; one of
  two heat-readers today, three with the boiler, each with a payoff of its own (the Stingray
  reads heat for stacks, the boiler would for blows).
- **Build diversity: sound.** Five hardpoints; hot weapons of any maker feed it (the Arsenal's
  plasma on a Kestrel airframe is the cross-maker pull), the Peak's Scorched feeds it from the
  enemy's side, and cold builds get nothing from it, which is a direction refused rather than a
  slot wasted.
- **Composition: sound as a second body, thin as a partner.** Self-sufficient: it gives the
  team no state and needs none; it is the Kestrel that stays in a long fight. Cannot detach
  cheaply.
- **Verdict: stands.**

### Puffin (Kestrel, tier two, light, hover)

*The shield escort: overshields allies and vents whoever it shields.*

- **Quality: sound.** The passive multiplies what shields already do (a shield on an ally is
  also a vent), the fixed projector reaches allies only, and the overshield fading at the
  round's end is the safeguard against a shield-bot. The parked question, whether the fixed
  shield pays off, is answered by design: ally-only is the one restriction that makes a shield
  specialist and not a bot, and it should stay.
- **Niche: strong.** The only ally-only locked piece, the only Overshield, the only shield that
  vents.
- **Build diversity: strong.** Four hardpoints; four makers have a shield and its passive
  rewards each (the Halo Shield, the Blast Door, the Oblation Ward, the Corona Shield, the
  Deflector; Wainwright & Sutler has none of its own yet), the fourth rule's clearest pass in
  the roster. The vent it adds is a cost on allies that want their heat (the Goshawk, the
  Stingray), which is a decision, not a fault.
- **Composition: strong.** Pure support: shield and cooling to others, Overcharged from its
  stock Coil; it needs a body and hot allies to matter and is expected to lose alone. Cannot
  detach.
- **Verdict: stands.** The roster's one unmixed support frame.

### Clydesdale (Wainwright & Sutler, tier two, assault, walker)

*The big die, with a free reroll of its own.*

- **Quality: sound.** Capacity as the identity: nine untyped hardpoints, three module slots,
  nothing locked, and a passive that is a number (one free reroll) on purpose; the bible has
  the fallback if it feels thin (two rerolls, or ten entries). It overruns the rule-text budget
  on purpose with its stock of nine and is the one machine allowed to.
- **Niche: sound, a niche of shape.** The only d9, the only three-module machine, the only free
  reroll. It adds no verb; it carries whatever verbs the team lacks, which is its fantasy.
- **Build diversity: strong, by construction**, with the thin deck as the cost: a big die shows
  each entry less often, so a build of nine is a build of what shows, and the reroll is what
  makes it a build at all.
- **Composition: strong as the flex piece.** It gives the team whatever its stock holds
  (control from the Suppression Battery, a shield from the Blast Door, column fire from the
  Enfilade Beam) and needs rerolls, which it half supplies. Can detach: as a body, slowly.
- **Verdict: stands.** One note for the proposals: the gunship is pitched into the Clydesdale's
  utility space (nothing locked, a jack), and if both stand the Clydesdale's capacity should
  sharpen so the two read apart; the parked ten entries or second reroll is the lever.

### Prairie Dog (Wainwright & Sutler, tier one, light, wheeled)

*The elusive scout: no hunter picks it; a rapid gun.*

- **Quality: thin.** A map rule as the passive, which the bible calls a weak identity on its
  own, and a rapid gun locked under it. The two halves disagree: the passive says it works
  alone behind the horde, and its die cannot finish a small pack alone (the cars row, 13
  October: it loses to half of them). The bible's own line names it: the cars' map rules are
  detachment tools on dice that cannot detach.
- **Niche: sound on paper, unbuilt in play.** The only machine a hunter never picks, so the
  only one that chooses every fight it is in. What that buys (scouting a fuzzy formation, a
  loot detour, holding the gate's flank against a pusher) is all in systems not built yet, so
  today it buys movement without a fight.
- **Build diversity: thin.** Three hardpoints and nothing rewards a direction; the passive
  touches no component, so the fourth rule cannot pass, and the locked Repeater's Rapid rewards
  small pieces generically.
- **Composition: thin today.** It gives the team a free piece on the map and needs the team to
  fight without it, which the engagement rules allow; it cannot take the pack it reaches.
- **Verdict: needs the stock pass, and the fight's half of its identity.** The map rule should
  stay (the cars trade strengths, Decided). What it needs is a die that can finish a small
  pack alone, and the cleanest place for that is the locked Flakshot Repeater rather than a
  second idea on the passive: a rule on the gun that reads *alone* (no ally in the fight, a
  state nothing reads today and the Tactical Databank's mirror), making its round "shoot, roll
  again, shoot, leave" only when it has chosen to be there. Rapid stays small; the rule is a
  locked piece's and costs the passive nothing.

### Dingo (Wainwright & Sutler, tier one, light, wheeled)

*Two actions a turn; a suppressing harpoon.*

- **Quality: thin.** Two map actions as the passive and a cheap pin locked under it. Alone it
  loses to every pack but two, by design: it is the pack animal that drifts between fights and
  makes its second action count in an ally's. The harpoon is the one hard-control source a
  tier-one chassis locks, which the brief's first rule allows, and the bot's 64% share on it is
  the die having nothing else worth spending, a stock problem.
- **Niche: strong on the map.** The only machine that can be in two fights a turn, or move
  twice, which is the reason a detachment can rejoin and a four can fight as a four more often
  under the ring and range rules. In the fight it pins the foe an ally is about to eat.
- **Build diversity: thin.** Three hardpoints and a map passive: no route in, no payoff. Its
  vent can be spent on a friend, which is a support entry, not a direction.
- **Composition: sound.** A pure team piece: it gives a second fight joined and a pin, and
  needs allies to fight beside, which is the shape the bible asks for ("machines that are only
  good together"). Cannot detach, and should not.
- **Verdict: needs the stock pass.** The design stands as a team piece once the map's fights
  come in sizes; its die is the stock pass's. The pair of cars is the reason Wainwright &
  Sutler's tier-one deal is always a light wheeled support that cannot stand in a front, which
  section 5 reads.

### Baboon (Aphelion, tier one, medium, walker)

*Control through statuses: the Pocket Paradox.*

- **Quality: sound; the stock is the problem.** The meter is the game's own answer to a chance
  to stun (binary) and a damage-zeroing debuff (toxic), and it never feeds itself. Its stock
  carries two Umbra Inducers, so today it suppresses with the gun and suppresses again with the
  meter the gun fills, which is the density Ryan named on 13 October. A d7 of six status pieces
  is a tier-two read on a tier-one machine, which the records already say; the stock pass puts
  basics on it.
- **Niche: strong.** The only meter, and the only passive that reads a foe gaining a debuff,
  which every status piece of every maker feeds: Burn from Wainwright & Sutler's shells and the
  Arsenal's plasma, Shock from the Polar Bear's hull and Minerva's gauntlets, Disrupt and Shock
  from its own house. The status house's hub.
- **Build diversity: strong.** Six untyped hardpoints; any debuff piece of any maker is a route
  in, and Suppressed is a payoff everything cashes. With basics the meter fills slowly, which is
  the tier-one sandbox: find status pieces. The stock pass's "may stock a shield again" is
  right; nothing fights the passive now.
- **Composition: strong.** The clearest composition machine in the roster: it gives suppresses
  the whole team benefits from and needs status appliers around it (the Stingray's burns feed
  it on purpose). Expected to lose alone; cannot detach.
- **Verdict: needs the stock pass.** Its one hard-control passive is the budget's model: the
  stun scales with the team's status count, not with its own die.

### Stingray (Aphelion, tier one, medium, hover)

*The hot status amplifier: stacks deepen with its heat.*

- **Quality: sound.** Cooling 0 by design, a hot locked burn, and a passive that reads its own
  heat and deepens every stack it lays, on a foe, an ally or itself: every round is a heat
  decision. The double dip through Primed and the five extra stacks at 100 heat are knobs Ryan
  has already called silly and tunable.
- **Niche: strong.** The only stack amplifier; one of two heat-readers today, with a payoff of
  its own. Its reach is wider than its burns: a Shoring Jack spent at 100 heat braces for
  seven, an Overcharge Coil overcharges for seven, which is a hidden wall and a hidden burst on
  a tier-one machine, and the levers are the per-heat step and the buffs' numbers.
- **Build diversity: strong.** Five hardpoints; stack appliers of any maker (burns, Primed,
  Braced, Overcharged), hot weapons of any maker to feed it, and vents as its brake: two
  directions (burn deep, buff deep) and a third (run cold and lose the passive) that is a real
  build choice.
- **Composition: strong.** It gives deep stacks to foes (the Baboon's meter, a Mastema's Ewer)
  and deep buffs to allies, and needs a body and stack sources; it makes its own heat. Cannot
  detach cheaply.
- **Verdict: stands.** The Braced interaction is for the stock pass to price, not a fault.

### Nemesis (the Arsenal, tier two, heavy, walker)

*Hull damage, overheats included, banks rage its fists spend to roll again.*

- **Quality: strong.** One idea, Ryan's, and the bible's example of how a passive opens build
  space: the way in is any hull damage, so overheating on purpose, biting kit and a lure are
  all builds; rage buys actions and never damage, so the die stops collapsing onto the fists.
  In a team it rages seldom, since foes seldom reach its hull (0.15 times a round, 13
  October), which is the design asking the build to feed it, as Ryan expected.
- **Niche: strong.** The only machine rewarded for hull damage with tempo, the only roll again,
  the only hurt-yourself build.
- **Build diversity: sound.** Four hardpoints; routes in from every maker (Volatile pieces, the
  Tithe Coupling, hot weapons for the overheat, Minerva's Klaxon to draw blows); the payoff is
  the locked fists alone, which the bible allows for a pair that fits its identity. The
  diagnostic: the fists carry 56% of its spends, which the rage makes true by design.
- **Composition: sound as a body, thin as a partner.** It gives the team a second front that
  grows when the team fails to protect it, which trades against every shield the Puffin would
  hand it (a decision); it hands nothing out. Can detach: yes, the roster's second detachment
  identity after the Badger, unnamed in the records until now.
- **Verdict: stands.**

### Ammit (the Arsenal, tier three, medium, walker)

*Devours: its kills Overcharge it for the battle.*

- **Quality: sound.** Four locked talons and a passive that keeps what they take: the one
  battle-scoped ramp, with an end. Its tier is carried by its locked count rather than a
  sharper passive, which is half of what the tier row asks; a tier three's low floor it has.
- **Niche: sound.** The only Devour and the only battle-long growth; a ramp among several, kept
  apart by its scope.
- **Build diversity: sound, on half a die.** Four hardpoints beside four identical talons;
  routes in are everything that brings a foe within a flat 10 of death (burns and big hitters
  of any maker) and every Overcharged source, which it keeps forever (Kestrel's Coil on the
  Arsenal's machine is +10 for the battle); the payoff is every blow it makes. The build is
  four slots, the rest is talons.
- **Composition: sound.** It asks the one question nothing else asks, who takes the kill, and
  takes the Baboon's suppresses and the Polar Bear's Shocks as free kills; it gives a body that
  grows. Can detach: no, it starts weak.
- **Verdict: stands.** A tier three whose complexity is in its kit count; fine as the Arsenal's
  first.

## 3. The roster as a whole

| Machine | Quality | Niche | Build diversity | Composition | Verdict |
|---|---|---|---|---|---|
| Honey Badger | sound kit, thin passive | strong, on the kit | thin | a body; detaches | stands; the identity row |
| Polar Bear | sound | sound, shared with the Thurible | sound | strong; detaches | stands; keep the Hull |
| Wild Boar | sound | sound, waits on back ranks | sound | a body; detaches | stands |
| Sparrowhawk | strong | strong | sound | strong cash-out | stands |
| Goshawk | strong | strong | sound | a second body | stands |
| Puffin | sound | strong | strong | strong support | stands |
| Clydesdale | sound | sound, a shape | strong | strong flex piece | stands |
| Prairie Dog | thin | sound, unbuilt | thin | thin today | needs the stock pass and the fight's half |
| Dingo | thin | strong on the map | thin | sound team piece | needs the stock pass |
| Baboon | sound | strong | strong | strong | needs the stock pass |
| Stingray | sound | strong | strong | strong | stands |
| Nemesis | strong | strong | sound | a body; detaches | stands |
| Ammit | sound | sound | sound | sound | stands |

- **What a four can be today.** Bodies: the Badger, the Polar Bear, the Boar, the Nemesis, the
  Clydesdale. Burst: the Sparrowhawk, the Goshawk's cannon. Control: the Baboon, the Dingo's
  pin. Support: the Puffin, the Dingo. Amplifiers: the Stingray, the Polar Bear's Shocks. A
  ramp: the Ammit. So a four of body, controller, amplifier and support exists (the Polar Bear,
  the Baboon, the Stingray, the Puffin) and reads as a composition on paper; the runner cannot
  see it because the bot cannot value three of the four, which is the to-do's valuation line,
  not the roster's fault.
- **Detachment identities** are the Badger and the Nemesis, and the heavy bodies at a cost; the
  fast machines (the cars, the Sparrowhawk) cannot, which is the inversion the bible names. The
  fast detachment is Kestrel's gap (section 8).
- **Only good together**: the Puffin, the Dingo, the Baboon. The proposals add the multi-rotor,
  Misharu and Minos.
- **Overlaps worth resolving**: the Faraday Hull and the Retribution Thurible (the same read and
  the same product); the gunship and the Clydesdale (the same space); the Stingray, the Aurora
  Lattice and the proposed Chrism Ewer (burn deepened three ways); five ramps, which Ryan
  accepts for now.
- **Identities whose fight half is missing**: the two cars, and the Badger's passive.
- **The classes a new chassis should add to**, in the order the census ranks them: soft
  control, amplify for others, area on a hardpoint, a new price (section 6), and reads nobody
  uses (the foes' drawn intents, the reinforcements, the die's own unspent entries).

## 4. The proposals

Rated on the same axes, for fit. Each has a verdict: a place, back to the board with what it
needs, or unfinished. Ryan's calls on each are in its proposal and are not reargued here; where
a lean of Claude's differs from the proposal's, it says so.

### The Arsenal's four, and the Brand

**Misharu** (tier two, heavy, walker). *A foe whose blow breaks a machine's shield is
Suppressed.* Locked: the Vigil Pavise (a self overshield, the first), the Interdict Halberd
(Penetrate).

- **Quality: sound, with a named risk.** The bait loop is clear and the fallbacks are named by
  Ryan (hull damage in the sentence's place, or several breaks to a sentence). The risk is the
  bible's own test: a control rider on an action the player takes anyway (shielding) needs a
  limit, and the limits here are Numbed's ramp and the shield being small. A first sentence on
  a boss is sure, and Numbed slows only the second and third.
- **Niche: strong on the read, dear on the budget.** It reads a shield breaking, which nothing
  reads, and is the only hard control the enemy sets off itself. It is also a fifth source of
  the scarcest class.
- **Build diversity: sound, on a small die.** Three hardpoints; every shield in the pool is a
  route in (the fourth rule's second-clearest pass among the proposals, after the
  multi-rotor's), and every hitter is a payoff on a sentenced foe. Two locked pieces on a d5
  leave three directions.
- **Composition: strong.** It makes every shield on the team a weapon, so the shielders feed it
  (the Puffin's ally overshield most, a Kestrel and Arsenal pair), and it gives the heavy
  hitters' lost actions to everyone. Only good together: nearly.
- **Verdict: a place**, under the count in section 6: after the stock pass takes the Inducers
  out of a tier-one stock, the roster's hard control is one locked piece (the Harpoon), two
  blueprints and the Paradox, and a second passive fits the budget if it is the enemy's own act
  that triggers it. The team to read first when it exists is Misharu beside the Puffin, where a
  fresh overshield lands every round; if that cell locks the bosses, the meter fallback (two
  breaks a sentence) is the one that keeps the read and halves the count.

**Mastema** (tier three, heavy, flyer). *A Burning foe that dies passes its Burning to the foes
beside it.* Locked: the Chrism Ewer (doubles a target's Burning, no damage), the Votive Ward
(shield 10 for each Burning foe).

- **Quality: strong.** Tools that work the fire rather than light it, by Ryan's call; deep
  against wide pulls the two apart; the arithmetic is written out; the risks (no cap on the
  doubling, two blanks until burn is down) are named with their levers. A tier three by
  complexity: three rules that fit together.
- **Niche: sound, in a crowded class.** It reads a burning foe's death and the count of
  burning foes, which nothing reads, and produces spread, doubling and shield from burn.
  Damage over time is where the proposals crowd, and burn would be deepened in three places;
  its niche within burn is the manager, and nothing on its locked kit lights a fire, so it is
  the burn team's capstone rather than a fourth burner.
- **Build diversity: strong.** Four hardpoints; every burn source of every maker is a route in,
  and its tools are the payoff; with no burn on the team it is a d6 with two blanks, the low
  floor a tier three should have.
- **Composition: strong.** The Stingray feeds it deep, Wainwright & Sutler's shells feed it
  wide, the Baboon's meter counts every stack it spreads, and the Ward gives sustain to allies
  from the enemy's state. It needs burners.
- **Verdict: a place**, as the burn capstone. If the Arsenal's four land in order, Mastema
  before the Onryō: it composes across makers where Grudge composes with wounds alone.

**Minos** (tier three, medium, hover). *Every foe its weapons reach and leave standing changes
rank in its column.* Locked: the Gibbet Hook.

- **Quality: sound.** Ryan's calls fixed the shape (not optional, one turn a spend, nothing
  against a massive foe). The cost it adds is cognitive: each Minos spend changes the board for
  every other die, so a round with Minos in it is one more decision than the budget of one to
  three; the habit that answers it is spending Minos first or last.
- **Niche: strong.** The only positioning verb on the player's side; it reads nothing and
  produces a state nothing produces. By the brief's third rule, the best fit of any proposal:
  it changes the enemy's problem and removes no turn.
- **Build diversity: strong.** Four hardpoints; Spread turns three columns, Penetrate trades
  one, Indirect brings the back forward; the payoff is every Direct gun on the team.
- **Composition: strong, and demanding.** It gives reach to the Direct hitters and takes it
  away again on the next spend; the team works around it, which is the point. Only good
  together: yes.
- **Verdict: a place**, built when back ranks are common, which the bible already ties to the
  foes' fresh start. Nothing to come back with.

**The Onryō** (tier two, medium, walker). *Each blow a foe lands on a machine's hull gives that
foe a stack of Grudge: 5 a stack at its action, past armour, never fading.* Locked: the Pall
(an ally's hull damage lands on the Onryō instead, until the round's end).

- **Quality: sound.** Thorns avoided on purpose, the curse slow and permanent, the Pall the
  interpose the bible allows on a locked piece. The tension inside it is real: it rewards the
  team for being wounded, and the team's best verb (a standing shield) earns it nothing, so a
  well-played team feeds it least.
- **Niche: thin on the passive, sound on the Pall.** Grudge reads the roster's most crowded
  state (a blow on hull: the Polar Bear, the Nemesis, two modules), in the Arsenal's own house,
  at the same tier as the Nemesis: two Arsenal tier twos built around being wounded would
  compete for the same team slot and the same wounds. Its product is damage over time with a
  new source, in the crowded class. The Pall is new: the first interpose, and it shelters a
  fragile ally's components as well as its hull.
- **Build diversity: sound, closed.** Lures and fragile allies are routes in; Grudge ticks on
  its own and nothing cashes it beyond the Tensor and the Paradox reading it as a status.
- **Composition: sound.** The Pall is strong beside a glass cannon; Grudge composes with
  nothing (the Bellows stays off it) and asks the team to bleed.
- **Verdict: back to the board.** Keep the Pall as the locked piece. Come back with Grudge
  sourced from the Pall: *a wound the Onryō takes for an ally curses the striker*, so the
  machine that suffers is the one that chose to, the read is a moved wound (nothing reads
  one), the anti-shield tension narrows to the one ally it covers, and it stops competing with
  the Nemesis for the team's wounds. The locked piece and the passive then work together,
  which the bible asks of every new chassis. If Ryan keeps Grudge team-wide as written, the
  reason for a fourth hull-wound reader beside the Nemesis should be in the row.

**The Scapegoat Brand** (a rare component: a cleanse that moves debuffs onto a foe). Not a
chassis; rated for its home. Shape D (one meaning on any body) is the principled one and waits
on the buffs-and-debuffs pass; shape A (Burning alone) is buildable now and thin in two
domains of four. A place as a rare, after the vocabulary pass; not on Mastema, whose die cannot
afford a third blank. If Grudge becomes the Pall's, the question of Grudge against a moved
Corrupted resolves itself: Grudge keeps its word and its source.

**The four as a set.** Four different reads (a shield breaking, a burning death, its own reach,
a wound) and four different payoffs; the pairs the proposal names (the Ward feeding Misharu,
Minos arranging for the Bellows) are real; three Arsenal machines at each tier. Under the
budget, Misharu and the web bomb are the two hard-control passives of which section 6 admits
at most one a maker, and Misharu is the Arsenal's.

### Wainwright & Sutler's six

**The boiler** (tier two, heavy, walker, eight legs). *Its vents blast a random foe for the
heat they take off it; cooling -10.* Locked: the Steam Cannon.

- **Quality: sound.** Ryan's limits make it: the random target is the rider's limit and the
  player times it; the heat is its own, so no spare vent on the team becomes a free gun. It
  bends two floors (negative cooling, stats at zero) for one machine, which is what a passive
  is for.
- **Niche: strong.** Vents as weapons is a product nothing has; a third heat-reader, with a
  payoff of its own; and the roster's first build that wants to run hot outside Kestrel, in
  the maker whose kit is cold, which the heat row asked for on purpose (a class to add) and
  which pulls the Arsenal's hot guns onto a Wainwright & Sutler frame.
- **Build diversity: strong.** Four hardpoints; every maker's vent is a route in (each has
  one), every hot weapon is fuel, the Peak's debuffs are free fuel, and the payoff is any vent.
  The fourth rule's cleanest pass among the Wainwright & Sutler six.
- **Composition: sound as a body, thin as a partner.** Self-contained damage, by Ryan's call; a
  heavy that holds a front. Can detach: likely.
- **Verdict: a place.** Its numbers mean nothing until the stock pass prices heat (the gain
  must stay under a vent's number), so it waits on that, not on a decision.

**The multi-rotor** (tier three, assault, flyer). *Any machine in the fight may spend its die
as its own.* Nothing locked.

- **Quality: sound.** One line that bends one rule; the look settled; what waits is the word
  for the die and the gesture on a phone (its die dropped on an ally's).
- **Niche: strong, unique in the whole set.** The only thing that changes what pieces do for
  the team: its entries take whichever ally's passive and buffs the player chooses, so a flat
  gun doubles on the Sparrowhawk's account, a burn deepens on the Stingray's, a hit spills on
  the Boar's.
- **Build diversity: strong.** Six hardpoints built for the team: every piece of every maker is
  a route in and every ally's passive a payoff, the fourth rule's strongest pass conceivable;
  alone it is a plain d6 with no passive, the lowest floor in the game.
- **Composition: strong.** The purest support, giving its whole die; it needs allies with
  passives worth lending to.
- **Verdict: a place**, and the roster's clearest "only good together" machine; tier three is
  right. It waits on the die-word session and a bot that chooses the spender. Under the budget
  it multiplies nothing by itself: a lent stun is still one stun.

**The revolver** (tier two, medium, walker). *Whenever its die rolls, it moves to the next
entry instead, in sequence.* Locked: the Hogleg.

- **Quality: sound.** The fire plan, the first chamber, Rapid as a known double, the chain
  settled by Ryan (funny not strong, with the lever named). One interaction to write into its
  row: a team reroll rerolls every unlocked die, so it steps the revolver whether or not the
  player wanted the chamber moved, and the player locks the revolver's die before every team
  reroll meant for another machine. One tap a round, and it must be taught.
- **Niche: strong.** The only die that does not roll: it reads its own order, a state nothing
  reads, and takes the game's one randomness off one machine on purpose, which is a real
  choice for the player who hates dice and no threat to anyone else's.
- **Build diversity: strong.** Five chambers; sequence is an axis of building nothing else has,
  and Rapid pieces of any maker become known doubles.
- **Composition: sound.** Its plan is its own, but a known sequence is a team planning tool:
  the stun chamber or the shield timed for the boss's telegraph.
- **Verdict: a place.** Nothing to come back with.

**The funnel-web** (tier two, medium, walker). *A foe it would Suppress takes a web bomb
instead: at the end of that foe's turn it bursts, Suppressing it and the next foe beside it.*
Locked: the Fangs (flat 10, and 20% of a Suppressed target's current hull).

- **Quality: sound.** Ryan's plan; the next-to-act rule reasoned; the edge cases listed. The
  fangs' percent of current hull is a new shape on a locked piece (it opens on a boss and never
  finishes one), which is the right way round.
- **Niche: sound on the read, dear on the budget.** It reads a Suppress landing, which nothing
  reads but Numbed, and produces a timed, spreading stun with a window: the player sees the web
  on the chip, the webbed foe acts once, and killing it first takes its web with it. As hard
  control goes it is the kind the brief prefers, since where the web sits is a decision; it is
  still two actions a web.
- **Build diversity: sound, narrow.** Four hardpoints; Suppress pieces of any maker are the
  route in, and after the stock pass they are blueprints, so its engine is scarce on purpose
  (its stock carries the Battery, so it is never without one); the payoff is the fangs and
  every blow on a foe that cannot answer, and every stun on the team feeds the fangs.
- **Composition: sound.** Two actions removed a web, kill windows for everyone, the Paradox
  fed twice; beside the Baboon and Misharu it is a stunlock team, which the boss cells read.
- **Verdict: a place**, under section 6's count: one hard-control passive a maker, and this is
  Wainwright & Sutler's (pinning is its lean). It should land after the stock pass has made
  Suppress pieces blueprints, so webs are precious.

**The gunship** (tier two, medium, flyer). *Its Ballistic weapons raise its armour and cooling,
its Beams its shield and recharge, its Missiles its move and hull; its Arc weapons raise the
others' highest rolls.* Nothing locked.

- **Quality: sound, and settled by Ryan.** Many rounds of his calls (built in the hangar,
  numbers only, five of a tag the best at its number, two-tag pieces the chase); three lines of
  rule text, the budget's edge; the table measured on a stand-in, which this page does not
  rerun.
- **Niche: sound, shared.** The first machine built in the hangar and the first tag reader,
  which the tags row wants (a tag earns its place once two things read it). It shares its space
  with the Clydesdale: both Wainwright & Sutler tier twos that lock nothing and carry whatever
  is fitted. They differ in where the build happens (the fit against the roll), and the maker
  whose character is odd designs would field two plain ones.
- **Build diversity: strong.** Four straight lines and the mixes; every weapon of every maker
  is a route in once tags exist. By the fourth rule it is the weakest composer of the six,
  since nothing it does reaches an ally, and that is Ryan's call (a gunship is about its
  weapons).
- **Composition: thin as a partner.** A body, a wall or the fastest machine by build; it gives
  the team nothing and needs nothing.
- **Verdict: a place**, conditioned on the stock pass's tags and on the Clydesdale's capacity
  sharpening so the two read apart. Nothing to come back with.

**The fan-boat** (tier one, light, hover). *Everything it fires goes through its deck gun: each
weapon fires the deck gun's shot, with its own keywords.* Locked: the deck gun (flat 15).

- **Quality: sound, with a tier problem.** The rule holds together and the holes are named
  (Rapid shells, a shell's heat not counting). The problem is the tender: a tier-one chassis
  stocks basics beside its locked piece, basics carry no keyword by definition, so at the
  tender the fan-boat is four entries that all fire a flat 15 and its passive is invisible
  until the first keyword blueprint is found. A tier one must show its identity with basics
  alone (section 6's fifth rule), and this one cannot.
- **Niche: sound.** It changes what every weapon does on it, like the Sparrowhawk, with
  keywords in place of numbers: small keyword pieces become its best guns.
- **Build diversity: strong, later.** Three hardpoints; every keyword piece of every maker is a
  route in; big numbers, Indirect reach and the rolled-range modules are wasted on it, which is
  a refusal with a reason.
- **Composition: sound.** A status platform at a reliable number: a Lure shell, a Shock shell,
  a Burn shell all land at 15 flat, which is a team role once the shells exist. It is light and
  cannot hold a front, so it does not answer the tier-one gap of section 5.
- **Verdict: back to the board, with its tier.** Either tier two, where it stocks tier-one
  keyword pieces and its passive shows from the first fight (the proposal's own question,
  whether the magazine makes a better tier two, points the same way), or a locked piece that
  carries the first keyword so the tender shows what it is. Wainwright & Sutler's tier-one gap
  (a machine that can hold a front, section 5) stays open either way.

**The six as a set.** Six different bends of six different rules, no two alike, which is the
maker's character; four at tier two and none that holds a front at tier one. The multi-rotor
and the boiler are the two the ecosystem is shortest of (a team support that is not a shield,
a hot build on a cold frame); the revolver and the gunship are new axes of building; the
funnel-web is the maker's share of the stun budget; the fan-boat needs its tier.

### Aphelion's four, unfinished

Their session ended before its questions closed (Ryan, 13 October: the proposal is a list of
ideas, not a design to defend). This page rates none of them and lists what each left open,
with what the census tells the session that finishes them.

**The line frame** (the Gundam homage; tier one, medium, walker). Open: the Beam passive, plain
+5 or +5 on a foe it has already hit this round; the shield-and-saber pair (spending the shield
lets the saber reach any foe that round); its tier; its designation. From the census: a
tag-reading chassis passive would be the first (the gunship reads tags for numbers), and the
bible admits one only if it opens build space; of the two forms, the lead reads the order of
its own spends this round, which nothing reads, and the plain form reads a tag alone; both are
amplify on itself, a class with no chassis identity on the giving side. At tier one it would be
Aphelion's third, which varies the tender; it would also be the first Aphelion machine with a
locked shield, and shields on a status house compose with Misharu.

**The jellyfish** (the Science Vessel homage; tier two, medium, flyer). Open: the spread rule
as written (every effect its weapons put on a foe also lands on the foes beside it, never its
damage, foes only); the dispel's name (Dispel, Strip or Purge) and its exact reach; Shock on
the EMP; its stock; its designation. From the census: the dispel is decided and is the one
wholly new verb in every proposal, the answer to Harden, Rally and Reraise that nothing holds;
and the spread triples whatever status it carries, Suppress included, so under section 6's
count it is a hard-control multiplier beside the Paradox in the same house unless the spread
excludes Suppress (Ryan's own narrowing to non-damage effects leaves the door open to
narrowing once more). Wide beside the Stingray's deep is the pair the maker wants.

**The Carrier** (the Protoss Carrier homage; tier three, assault, flyer). Open: its verb (the
screen of 10 shield to every machine, interceptors as extra strikes, or another); its passive;
whether it is drawn bigger than the assault class; its designation; and the foil, a Minervan
battlecruiser, which does not exist and is Minerva's tier-three gap (section 8), so the two
are best designed in one session. From the census: the screen would be the first equipment
that reaches every ally; interceptors that build through a fight are reopened by the
locked-pieces row's revision.

**The Zoids walker** (tier two, medium, a fast four-legged walker). Open: its maker (Aphelion's
or the Arsenal's, with its name and passive following the answer); a kill making the spend
Rapid, which Ryan feels is Arsenal's; its tier; its designation. From the census: a kill-reader
joins Devour and Chain; a walker at move 40 would be the roster's first fast walker, the Rubble
Field's machine; and Rapid on a kill is tempo from kill order, strong into swarms and plain
against a boss, as the proposal says.

**The large hovercraft**: parked by Ryan, with the reason recorded (the Stingray already hovers;
it would earn a place by a map verb the Carrier does not take).

## 5. The tiers as the game deals them

**The tender.** One tier-one machine from each city maker, by seed, and the player takes
three. So every start is three of {a Minerva, a Kestrel, a Wainwright & Sutler, an Aphelion},
and the maker left out gets no hearing that run. Today's pools:

| Maker | Tier-one pool | What the deal can be |
|---|---|---|
| Minerva | Honey Badger, Polar Bear | always a body that holds a front and detaches |
| Kestrel | Sparrowhawk | always the Sparrowhawk: the deal never varies |
| Wainwright & Sutler | Prairie Dog, Dingo | always a light wheeled car that cannot stand in a front or finish a pack alone |
| Aphelion | Baboon, Stingray | always a medium support or amplifier without armour |

Two things follow. **Kestrel's deal is fixed**, so a player who takes Kestrel meets the same
machine every run, which the tender's purpose (every maker gets a hearing) does not intend;
the fix is a second Kestrel tier one, and that is the first of Kestrel's gaps (section 8).
**Minerva is the only maker whose deal is ever a body**, so the three the player takes hold a
front only if Minerva is among them: a Sparrowhawk, a Dingo and a Baboon is a legal start with
no armour and 220 hull between them, and the player who skips Minerva has chosen the hardest
run without being told. The squad moves as one, and the runner says count beats composition
for the bot, so three light machines together may well take the small packs; the exam is the
boss with its formation, which costs a pair about a machine's worth of hull today, and a start
with no front is the start that loses it. The fix is not to make Kestrel or Aphelion build
bodies: a second maker whose tier-one pool holds a machine that stands in a front (Wainwright
& Sutler's, section 8) means two of the four deals carry one, and a three without a body
becomes a choice taken rather than a corner dealt.

**What a tier-one set should look like**, as this page would write the test:

1. Each maker's deal is legible with basics alone: the locked piece and the passive show what
   the machine is in the first fight, and the basics fill it (Slay the Spire's opening). The
   Badger, the Polar Bear, the Sparrowhawk (once the Pinion Driver is locked), the Stingray and
   the Baboon pass; the cars pass on the map and not on the die; the fan-boat fails until its
   tier moves.
2. Any three of the dealt four can win the first battles at competent play: the small packs
   together and the first boss with its formation. That needs at least two makers whose deal
   can hold a front, so that the starts with a body and some glass outnumber the one with
   none.
3. Each maker's deal varies by seed, so each maker needs two tier ones or more. Kestrel has
   one.
4. The four deals differ in way of moving, so the map matters from the first battle: tracked
   or walker (Minerva), flyer (Kestrel), wheeled (Wainwright & Sutler), walker or hover
   (Aphelion). This holds today.
5. The dealt four answer the four domain questions between them: area or armour against the
   Meadow, hull and redundancy against the Waste, reach and burst against the Marsh, shields
   and cooling against the Peak. Today the Minerva deal answers the Meadow and the Waste, the
   Sparrowhawk the Marsh, the Baboon or the Stingray the Peak (a lure, burns, the Sublimator's
   cleanse), and a car answers nothing in the fight.

**Tiers two and three.** A chassis above tier one reaches the player as the host maker's offer
after a won battle at its city, or from procurement while its city stands; so a maker whose
city is fought at offers its own tier twos and threes, and a maker with none at a tier offers
a blueprint and a module and no machine. Aphelion has nothing above tier one today, so a win at
its city offers no Aphelion chassis; Minerva, Kestrel and Wainwright & Sutler have nothing at
tier three, so a late-run offer from any of them is a tier two again. The proposals fill
Aphelion's two tiers, Wainwright & Sutler's three and the Arsenal's two; Minerva's and
Kestrel's tier threes are section 8's.

Since tiers two and three are scarce and reached by the fronts chosen, not every one needs a
niche of its own against the whole roster, as the brief says. What each needs is to be worth
swapping a starter for: a sandbox of a different kind from the three the player holds, which
is a sharper passive, more locked pieces, a verb the tier ones lack, a higher ceiling and a
lower floor. So the tier-two shelf is where the machines that are only good together belong
(the player has a team to fit them into by then: the Puffin, Misharu, the funnel-web), and
tier three is where the rule-benders with the lowest floors belong (the multi-rotor, Minos,
Mastema, the Carrier). The one shape a tier two should not take is a second plain body (the
Clydesdale's and the gunship's overlap is the near case); a tier one may be plain, since plain
is what basics make legible.

## 6. The budgets, argued

The brief's table and four rules are Claude's proposal of 13 October, unconfirmed; the census
above is the recount, and these are the rules as this page would put them to Ryan, each with
the holes the census found.

1. **Hard control is the scarcest class.** Holds. Two refinements. First, count it where it
   is felt: per die and per team rather than per roster, as actions removed a spend, so a
   multiplier counts as what it multiplies (the web bomb two, a spread suppress three) and the
   Paradox counts as one source whose rate the team sets. Second, the placement rule the stock
   pass already implies: no hard-control piece below tier two (so no basic and no tier-one
   stock carries one), at most one locked on any chassis (the Harpoon), and at most one
   hard-control passive a maker: the Paradox is Aphelion's, Misharu the Arsenal's, the web bomb
   Wainwright & Sutler's, and Minerva's and Kestrel's gaps add none (section 8). The jellyfish's
   spread would be Aphelion's second unless it excludes Suppress. Numbed stays the systemic
   brake, and the boss cells say whether the count holds once the three passives exist.
2. **A new chassis earns its place by a new read, a new product, or changing what a kind of
   piece does.** Holds; it is the niche axis above, and the reads table is its tool. One
   addition: **or a new price**. The self-cost class is where a design can be new without a
   new verb (negative cooling, a wound moved, shield spent as ammunition, a cooldown), and a
   new price opens build space as surely as a new verb does, since the cold builds the heat row
   says must pay elsewhere need somewhere else to pay. Sections 7 and 8 use it.
3. **Prefer verbs that change the enemy's problem over verbs that remove its turn.** Holds, and
   the census makes it urgent: soft control is two pieces with no chassis identity, and the
   proposals add one (Minos). The gaps add one more (Minerva's, section 8).
4. **Every passive needs two routes in and two payoffs from other makers' pieces.** Holds as
   the build-diversity test, with one hole: a map passive cannot pass it, since no component
   touches the map, so a map rule on a passive needs the fight's half of the identity
   somewhere (a locked piece's rule, as proposed for the Prairie Dog), or the chassis is a map
   piece and should say so (the Dingo). The roster's failures today are the Badger's passive
   and the two cars'; the Clydesdale's reroll reads nothing and composes with everything, which
   passes in spirit.
5. **A tier-one chassis shows its identity with basics alone** (new, from section 5). The
   locked piece and the passive must read in the first fight with nothing but basics in the
   hardpoints. The fan-boat fails; the cars half-fail.
6. **Each maker fields a chassis at every tier it may** (new, from section 5). A roster rule,
   not a design rule: Aphelion at two and three, Minerva and Kestrel at three, Wainwright &
   Sutler at three; the Arsenal at two and three by its own rule.

**On the heat spectrum.** No report, by the brief. Where heat bears on fit: the boiler is the
hot build on purpose the heat row asked for, and the first outside Kestrel; the Goshawk and
the Stingray read heat and are judged once the roster has hot builds to feel it; the
Sparrowhawk is the one machine that feels it today. The heat report and the three-ways
fielding are the stock pass's and the balancing session's.

## 7. Cooldowns in a skirmish

The question (bible section 8, reopened 13 October): a printed rule on a specific piece, shown
on the die as an entry blank for a round or two after it fires, paid in the die's reliability;
or kept out. Ryan is willing to be convinced either way. This page's lean is **yes, as a
printed rule on specific pieces, with limits**, for four reasons and with the costs named.

- **The player already knows the shape.** Rapid's switch-off is a cooldown of one round: the
  entry switches off for the round after it fires. A cooldown of two rounds is the same thing
  with a count on the chip, so it costs no new idea, only a number the die must show.
- **It prices what heat cannot.** Heat is a price per spend and bites hot kit; a cooldown is a
  price per die and bites small dice (a blank on a d4 is a quarter of every roll, on a d9 a
  ninth), so it falls on the opposite machines. The cold kinetics the heat row says must pay
  elsewhere get a second place to pay, and the big dice (Wainwright & Sutler's capacity) get a
  price they can afford: the second axis the question asks for, and one that favours the
  makers heat ignores.
- **It is the shape two parked designs wanted**: the turret design the bible mentions, and a
  big flat hit on a cold machine that today can only be priced by a lower number or a rolled
  range. Minerva's tier-three gap in section 8 is its first natural carrier.
- **It is the revolver's native currency**: on a die that steps, a cooldown of so many rounds
  is exactly so many chambers, with no chip to track.

The costs, and the limits that answer them:

- A timer per piece for the player to track, which section 2 refuses when hidden. So the entry
  itself shows it (greyed, with the rounds left), the hold explains it like any rule, and a
  cooldown lives only on a piece whose popup is read anyway; never on a basic, never more than
  one cooldown entry on a die below tier three, and never as a keyword every piece may carry.
- It stacks with Rapid's switch-off and a foe's Disabled as a third way an entry is dark, so
  the three need three structures, not three hues.
- A cooldown on a locked piece prices the chassis, and a chassis passive may make it an
  identity at tier three (section 8), where the complexity belongs.
- The exit: if play says the timer reads as a hidden count or the dark entries clutter a phone
  die, the shape retires to Rapid's one-round form and the price returns to numbers and heat.

## 8. The gaps: Minerva and Kestrel

What the census says each maker's next designs should fill, and what an execution could look
like: the mechanic, the verb class it adds to, the tier, the rule it bends, its routes in and
payoffs, and its holes. No names, numbers or looks: Ryan has silhouettes in hand and matches
mechanics to them in another session, and the labels below are the mechanics', not names.
Each maker gets the two gaps the census ranks highest, and the bench (section 11) holds the
rest, so the fresh sessions start from the gaps and not from a design.

### Minerva

Minerva fields two tier ones (a brawler and a tank) and a tier-two diver, no tier three, and
its leans (Spread, Lure, Braced: heavy industry holding a line) are carried by one piece each.
The census's thinnest class, soft control, is Minerva's lean with no identity; the pricing
axis that cold kinetics lack is Minerva's problem first.

**Gap one: the line, a soft-control identity at tier two.** *Every weapon it fires Lures: each
foe its blows reach and leave standing turns on it for the round.* The Wild Boar's shape (a
keyword granted to every weapon by the passive) with Lure in place of Spillover, so every blow
is the draw and the draw is a spend that shows on the intent, which is the redirection the
bible wants and never a tank's lock (the lure lasts the round and reaches only what it hit).
Verb class: soft control, the thinnest. Tier two: a plain line that needs plate under it, so
the numbers carry half the identity, and its locked piece can be the tool that makes the draw
worth taking (a shield that does something, as the Polar Bear's does, or a Braces blow). What
it reads: nothing new; what it produces: soft control on every entry, which nothing does.
Routes in: any weapon of any maker (a Spread piece lures three, Penetrate a column, Indirect
the back rank onto it); payoffs: everything that reads being struck (the Retribution Thurible,
the Spall Liner, a Nemesis beside it that wants the blows it does not take), and every ally it
is struck instead of. Composition: the protection the starter set was asked for on 30
September, by choice rather than by lock, and the Peak's answer (a lure onto a cold machine)
as an identity. Holes: it is a second Minerva tank in a team, so it should read as the one
struck by its own choice where the Polar Bear is struck by the enemy's; a lure on every blow is
a lure the player cannot refuse, so a weapon aimed at a foe the machine does not want drawn is
a decision the die must show; and against a lone boss the passive is a plain taunt, which is
fine, since a boss is the exam for the body anyway.

**Gap two: the siege battery, the cooldown made an identity at tier three.** *Every weapon it
fires strikes twice and goes dark for two rounds after.* The Sparrowhawk's bargain paid in the
die's reliability instead of heat: a battery of guns that reload. Verb class: a new price
(section 6's addition to rule 2), and volume rather than multiplied damage (two strikes, each
losing the foe's armour, so it is the swarm's answer and not the boss's, which keeps it off
the Sparrowhawk's ground). Tier three: the lowest floor in Minerva's line (a die half dark by
the third round of a fight it fires freely in) and the highest ceiling (an alpha strike every
other round), the first carrier of section 7's rule if Ryan says yes to it, and the foil the
Carrier's proposal asks for, Minerva's largest machine at its top tier. What it reads: its own
die's state (dark entries), which nothing reads. Routes in: every weapon of every maker, the
cold kinetics most (a rolled 15 to 30 struck twice is the roll Minerva already makes, and heat
says nothing to it); payoffs: its own, and a team that times its rounds (a Lure the round
before the battery fires, a Suppress the round it is dark). Composition: burst on a timer the
team plans around, where the Sparrowhawk's burst is every round at a price in heat. Holes: it
is only as good as the cooldown rule's chip, so it waits on section 7; two strikes on every
weapon doubles every rider too (a Burn piece lays its stacks twice), which is a reason to make
the strikes the locked piece's and the dark rounds the passive's if the doubling proves too
much; and a passive that only punishes (dark entries with no upside on the machine) is a cost
without an identity, so the upside must be on the same machine, in the strikes or in a line
that reads its dark entries (the bench has one).

### Kestrel

Kestrel fields one tier one (the Sparrowhawk), two tier twos (the Goshawk, the Puffin), no
tier three; its leans are Rapid, Overcharged, Overshield and the chain (tempo, burst, escort).
Its tender deal is fixed, and the roster's fast machines cannot detach, which is the inversion
the bible names: the maker of speed should own the detachment.

**Gap one: the raider, a second tier one that detaches.** *Its weapons may fire its shield: a
blow it makes spends so much of its own shield for so much more damage, and its shield returns
at the field rate out of fights.* Shield as ammunition, the idea the Wainwright & Sutler bench
set free when Misharu took the shield-into-suppress shape. Verb class: a new price (shield,
which nothing spends; the brake is built in, since the shield spent is the shield not there
for the enemy's blow) and burst. Tier one: one rule, legible with basics (a basic gun and the
basic self-only shield are its whole kit, and the locked piece is the gun that fires shield),
and the second Kestrel the tender can deal, so a player meets a different Kestrel glass each
run. What it reads: its own shield as a resource, which nothing reads; what it produces:
damage from mitigation, the Goshawk's loop run backwards. Routes in: every shield in the pool,
the Puffin's ally overshield most (Kestrel's own escort filling the raider's magazine is the
locked-pieces-work-together row at the maker's scale), the Halo Shield, the Blast Door, the
Spall Liner; payoffs: its own blows. Composition: the detachment the four-machines row asks
for, fast and cheap to send, since it fights a small pack on its shield and flies off to
recharge (the field rate is Kestrel's highest number and nothing has made it an identity);
beside a shielder it is a hitter with a second magazine. Holes: it is a second Kestrel burst at
tier one beside the Sparrowhawk, so it must pay differently (shield, not heat) and compose
differently (shielders, not vents), which it does, and the look is Ryan's to keep apart; a
shield spent is also an injury risked (a blow on bare hull rolls the die), which is the right
cost and must be shown on the entry; and the exchange rate (shield for damage) is the whole
balance of it, a placeholder the stock pass prices.

**Gap two: the interceptor, acting on the reinforcements at tier three.** *Its weapons may be
spent on a foe waiting in the reinforcements, and a kill there never steps in.* A read nothing
uses (the waiting list) and an answer to an Open row (ways for the player to act on the
reinforcement phase). Verb class: area in the campaign's sense (it thins what is coming rather
than what is here) and tempo (a foe killed in the wait is a round of blows never taken). Tier
three: it bends the rule that a die reaches only the field, which no passive may do lightly,
and its floor is low (against a pack with nothing waiting it is a plain flyer). What it reads:
the reinforcements; what it produces: a state nothing produces, foes dead before they arrive.
Routes in: any weapon; payoffs: the team's, since every foe it kills in the wait is a slot that
stays empty and a column that stays open to Direct. Composition: the Marsh's answer (Reraise
returns a foe to the reinforcements whole, and this is the machine that meets it there), the
Meadow's (a dead Gel's halves wait), the Tamer's wildlife, and every formation the fresh start
spawns with a wait list; beside Minos it is the back rank handled at both ends. Holes: it must
obey the one rule set for foes (a foe that leaves the field says so on the plaque; one that
never arrives needs the same honesty, so the wait list must be shown as a row the player can
read, which it is not today); a foe in the wait has no rank, so Direct and Indirect need a
word for it; the exposed aim and the swarm bonus must not count the dead-in-waiting; and the
bot cannot value it until the fresh start gives fights a wait list worth thinning, so its
runner rows wait on that.

### A gap that is nobody's proposal

**Wainwright & Sutler's tier-one body.** Section 5's finding: the maker's tier-one deal is
always a car, and the fan-boat is light too, so no deal but Minerva's holds a front. The maker
builds wheels and quads and old-West iron; a plain tier-one quad that stands in a front with a
locked piece in its lean (strikes, Penetrate) is the gap, and its session is the Wainwright &
Sutler one that already has six proposals, which this page would hand the finding rather than
a design.

## 9. Decisions for Ryan

1. The roster's ratings and verdicts (sections 2 and 3), machine by machine: anything he reads
   differently.
2. The Honey Badger's identity: the hopper as the passive's business (loads held are plate,
   loads fired are damage, every weapon fills) with "never destroyed" as a Minerva module, or
   one of the benched shapes.
3. The Polar Bear: keep the Faraday Hull and make the Retribution Thurible differ or rarer, or
   remove the Hull and take the shutters' conditional draw.
4. The cars: the fight's half on the Prairie Dog's locked gun (a rule that reads *alone*), the
   Dingo as a team piece whose die is the stock pass's.
5. The proposals: Misharu, Mastema, Minos, the boiler, the multi-rotor, the revolver, the
   funnel-web and the gunship have a place; the Onryō and the fan-boat go back to the board
   with what section 4 names; the Brand is a rare after the vocabulary pass; Aphelion's four
   are finished in their own session with section 4's notes.
6. The budgets as section 6 puts them: the per-die and per-team count, one hard-control
   passive a maker, the price added to rule 2, the two new rules (a tier one legible with
   basics; a chassis at every tier a maker may field).
7. Cooldowns: yes as section 7 limits them, or no.
8. The tier-one set's tests (section 5), and whether a second maker's deal should hold a front.
9. Minerva's and Kestrel's gaps (section 8): which to hand their fresh sessions, and whether
   Wainwright & Sutler's body goes to its session.
10. The go, and the order after it: the stock pass, then balancing for real.

## 10. After the go

- **The stock pass** takes from this page: the Inducers off the Baboon's stock and the
  Baboon's shield (decided already); the Prairie Dog's locked rule, if taken; the Thurible's
  change, if taken; the Boar's star chip; the hard-control placement rule (none below tier
  two, one locked); the fan-boat's tier, if it is built.
- **The fresh sessions**: Minerva's and Kestrel's from section 8, proposed in chat first;
  Aphelion's finishing from section 4's open questions; Wainwright & Sutler's session takes
  the body finding.
- **The records**: each decision Ryan makes becomes a bible row and this page retires to git;
  its ratings never go into the bible (a rating is this page's register, a row is a decision).
- **The runner**: nothing from this page is run until it is content; the to-do's valuation
  lines (support, and the mechanics the proposals need) come before any row is read on a
  design this page rated.

## 11. The bench

Ideas this page set aside or did not take, one line each with the rule, so Ryan can overrule
the rule and not only the idea.

- **The Badger's last stand** (once a battle, a blow that would wreck it leaves it at 1 hull):
  binary, and rare in a fight; section 2's "chances live on riders" and the fit lens (the
  hopper is already the mining in it).
- **The Badger's campaign insurance** (never sits out after a wreck, never loses a component):
  the campaign half of today's passive grown up; no job in a fight, so it is a module's text.
- **The Badger's salvage** (more salvage from its kills): an economy engine as a chassis
  passive; the economy is unbuilt and a map or economy rule alone is a weak identity.
- **The Badger's every-blow fill without a cap or plate**: the hopper overflows and the
  fragmenter becomes a flat number; the cap and the plate are what keep the decision.
- **The Polar Bear's conditional draw on the Lockdown Shutters** (while the shutters are raised,
  a blow at an ally's bare hull turns on the Polar Bear): the interpose the bible allows on a
  locked piece and the mitigation the starter set was asked for; set aside only because the
  Faraday Hull should stay, and it is the first thing to take if the Hull goes.
- **The Retribution Thurible retired**: it is Retaliate's only carrier and Retaliate is the
  Arsenal's lean; it should differ or become rare, not go.
- **Misharu's Penance** (a debuff: blows 5 less a stack): the Arsenal bench's softer
  alternative; a soft verb the game lacks, set aside because Ryan wants the sentence tested;
  the one to reach for if the count fails.
- **The Onryō's Grudge team-wide as written**: a fourth hull-wound reader beside the Nemesis in
  the same house and tier; the Pall-sourced form keeps the word.
- **The jellyfish's spread with Suppress in it**: a hard-control tripler beside the Paradox;
  Aphelion's session decides, under the one-passive-a-maker count.
- **Minerva's hold-fire line** (an entry left unspent at the end of its turn braces it for the
  round; the rule bent: an unspent die is lost): sustain, a fat class, and a read nothing uses;
  the bench's best alternative for the tier-two gap if Lure is not wanted, and a candidate
  line for the siege battery's upside (its dark entries brace it).
- **Minerva's tier three as one big hit with a cooldown on its locked gun** rather than the
  whole die: smaller and safer; it makes the cooldown a piece's rule and not an identity, which
  is also fine, and is the shape to take if section 7's answer is yes but cautious.
- **Kestrel's reroll-maker** (a passive that gives the team rerolls on some trigger): tempo for
  others in the dice game's own currency, a read nothing uses (the team's rerolls); set aside
  because rerolls are never banked and every trigger found was free or a map action; worth a
  fresh look if the raider is not wanted.
- **Kestrel's wingman** (an ally this machine buffs or shields is Overcharged): amplify for
  others, a class with no identity, and Overcharged Kestrel's lean; set aside because it is
  the Puffin's shape with a different payoff, and two Kestrel escorts is one too many until
  the Puffin is judged.
- **Kestrel's cheaper withdrawal** (a passive that bends "withdrawal costs one enemy turn"):
  the detachment identity by the exit; set aside because the row's reason (forced contact is
  bad strategy, not bad luck) is about not skipping the price, and the raider detaches by the
  field rate instead.
- **A Minerva or Kestrel hard-control passive**: refused by section 6's count, one a maker,
  and both makers' leans are elsewhere.
- **Rating Aphelion's four**: refused by the brief; their open questions are in section 4.
- **Reading the retired first pass or the struck designs**: refused by the brief; nothing of
  either is here.

## 12. The go (14 and 15 October)

Ryan's go began in chat the day this page was published and ran through the next. What it
settled or opened lives in its usual home, so this section is only a pointer:

- **Decided**: bible rows and lines in `docs/rules.md` (the shield rule, Barrier and Ward,
  cooldowns, the Dingo's Shock, Misharu's Penance, Kestrel's strafer and bomber, the renames),
  none of it built yet.
- **Each proposal, direction and rework**: a design-session brief in `docs/briefs/`, whose
  README holds the decisions, Ryan's taste as the go established it, the tiers as proposed, the
  working budgets, the roster holes and an order.
- **Tasks** in `docs/todo.md`, the order of work in `docs/status.md`, the economy items in
  `docs/economy_pass.md`.

Sections 2, 4 and 8 were written before the go: the Polar Bear's options, the raider and the
interceptor, Misharu's sentence and every reading that rests on the whole-block shield are
superseded where the briefs say so.
