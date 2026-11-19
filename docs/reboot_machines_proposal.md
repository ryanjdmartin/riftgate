# The machines the reboot broke

Ryan, 13 November, as he ruled the reboot: "I'd also like a list of the chassis that break with
this change, so that I can start brainstorming." The list is the refit brief's section 22 (`The
machines, redone against the briefs`). Ryan, 17 November: "Now that we have some decisions made
from the new game mechanics, I want to examine the chassis that broke during the huge change to
heat and shield and work on fixing them."

This page reads that list again against the game as it stands on 17 November: each kit written
out whole, with its context, and read as a whole against the system (his second word the same
day: "we need to evaluate the kit as a whole against the new system and not just repair the
deltas"). It builds nothing and moves nothing in content; two of its machines were settled on
main the same day by his own rulings in another session (the Polar Bear, the Whip Scorpion), and
the Storm Petrel landed the same day on his word, with his upgrade branches (the bible's Storm
Petrel row; its section is a stub), and the Buzzard on the 18th (its row; its section a stub
too), and the Needletail the same day. It retires once its calls are rows and content.

## The whole of it

| The machine | The kit as a whole, under the system | Open |
|---|---|---|
| Storm Petrel | Landed 17 November (the bible's row): the Hardlight Generator, a point of shield a point of heat; its lock the Hardlight Pulse, a lure run hot; the Arc Fault Cannon in the Shoring Jack's slot; his branches Defence and Striker | His play of it, and his marks on its texts |
| Buzzard | Landed 18 November (the bible's row): the Field-Recoupling Injectors, a zap on every weapon it fires and 2 shield for every foe that falls; its Shield-burner Cannon fires the whole shield; a Barrier piece and a warm gun in its stock; his branches Sustain and Burst | His play of it, and his marks on its texts |
| Needletail | Landed 18 November on his two calls (the bible's Kestrel row): its Designator makes no heat, and its reboot may be its second spend, after one action of either kind | His play of it, and his "dull" |
| Skua | Its ramp lives behind a shield that lasts a cycle, and every cycle ends bare | Whether its ramp is for a cycle or a fight |
| Kite | Holds in short fights; its refill dies with a break, its reboot is the frailest bare turn | A kill mends a broken shield, or as it is |
| Cottonmouth | The drum's shape holds; at 6 heat it is two shots a cycle on the lightest frame | The drum's heat or its gauge; a keyword shell in stock |
| Puffin, in design | Nothing of the old kit survives; his direction, moving heat, is the system's dearest verb | Its session now or after the heat prices |
| Swallowtail, in design | Two dead plain forms; the system hands it a niche, the team's pit crew | His session |
| Polar Bear | Holds: a timed shell, a bare exit, and a Cryo that is now team cooling | Its text clause; the wall at tier one |
| Whip Scorpion | His rework: the one kit built on the system | Its strength; the Ray a dump that keeps the shield |
| Stingray | The Suite suits the system; its stock gives it almost nothing to deepen | Its stock; its tier |
| Nemesis | The system feeds its rage, its overheat included | The rage-and-burn loop; its placeholder slot |
| Wild Boar | Lost a stat and nothing else | Nothing |
| Giant Petrel | Its rerolls stand; its gifts of actions cost their receivers heat | Its unrefined kit, his session |
| Musk Ox | Its clock is ammo; the reboot is for its shield alone | Its session, the Forge's dead clause |
| The other nine | Nothing of theirs reads heat, cooling, regen or a shield gain | Nothing |

What is his is the last section.

## The system the kits are read against

Ryan, 17 November, of the first round: "we need to evaluate the kit as a whole against the new
system and not just repair the deltas ... Need the context listed." The system, as main runs it:

- Nothing regenerates or cools by itself. Regen and cooling exist only as a grant (a passive, a
  module, a status, a piece), and his expectation is that such grants are special: a kit's, a
  locked piece's, or behind a synergy.
- Heat only climbs. A basic gun is 3 for 4 heat (the Laser Carbine 4 for 5), so a stock die at
  a maximum of 12 fires three times and reboots on the fourth turn.
- The reboot: a machine that has spent nothing gives its turn. Its heat vents at once, its
  shield drops to nothing and it stands bare through the enemy's turn, and it comes back whole
  and unbroken as the next round opens. Heat laid on it after the vent stays; Phased makes it
  safe.
- Past the maximum each point of heat burns a hull at every END TURN; the first time between
  reboots is the overheat, and the shield breaks.
- The shield is one cycle's budget. At nothing it is Broken, and takes no shield of any kind
  until the reboot.
- Cover for a bare turn comes from another machine: an ally's Barrier (every Barrier piece has a
  cooldown of 1, and a machine's own is gone by the turn it would reboot), Armoured, a Lure
  drawing the blows elsewhere.
- The foes pick anyone, level, as the round opens; a few attacks go for the hottest or the most
  buffed; they never overkill, and an Exposed machine comes first. Their numbers were sized
  against a shield that refilled, the defence side's pass to size again.
- Cryo is one of the few coolings left: a weapon's hit on a foe carrying it cools the hitter 2
  a stack.

## The kits, whole

Each as content has it on main (`f475a59`): the context, every piece with its numbers (a gun
as number for heat), then the kit read as a whole against the system. The read's numbers are
the probe's (above).

### Storm Petrel, landed

Landed 17 November on his word with his branches; the bible's Storm Petrel row says what it is
and why. Its kit as this proposal read it is in git: `git show 86234dc:docs/reboot_machines_proposal.md`.

### Buzzard, landed

Landed 18 November on his word in its carrion form, with his branches; the bible's Buzzard row
says what it is and why. Its kit as this proposal read it is in git: `git show 288de9a:docs/reboot_machines_proposal.md`.

### Needletail, landed

Landed 18 November on his two calls, the Designator at no heat and its reboot its second spend;
the bible's Kestrel row says what it is and why, and `docs/measurements.md` the same day reads
it. Its kit as this proposal read it is in git: `git show f167af8:docs/reboot_machines_proposal.md`.

### Skua

Kestrel, tier 1, light flyer. *Context*: Ramping Dakka (11 November), "the long fight's hitter,
weak in its first round and a storm by its fifth"; "it ramps only while its shield holds:
Kestrel's risk".

*Kit*: hull 20, shield 9, armour 0, heat 12, move 6, 3 hardpoints.
- Carom Field: once a round, damaging a foe with a weapon gains it a stack of Ricochet (after a
  weapon fires, a strike of 1 a stack through the foe's Brittle and armour); hull damage halves
  the stacks.
- Hypersonic Swoop (fixed): Ricochet 1 on itself, Rapid: the one way to a second stack a round.
- Laser Carbine 4 for 5; Twin Autoguns 3 for 4; Flechette Pod 1 four times for 4.

*As a whole.* A stack a round (two with the Swoop), each an extra strike after every gun, about
three shots a cycle and the Swoop free. The shield it ramps behind lasts a cycle at most, and
every cycle ends in a reboot whose bare turn makes any blow hull damage, halving the stacks; a
burn halves them too. So the ramp tops out around one cycle, three or four stacks, likely halves
at the reboot and climbs again. A storm by the fifth round needs the team to cover its reboot.

*Verdict.* It collides with the system on length. If its ramp is meant for a cycle, it stands as
built; if for a fight, the halving wants another trigger (a foe's blow alone, its own reboot's
bare turn spared, or the stacks kept through the reboot). His: which it is for.

### Kite

Kestrel, tier 2, light flyer. *Context*: the burst glass cannon (11 November); its shield comes
back by killing (his: "What exactly is wrong from a shield refill if the max shield is small?");
"anything big after its first shot, and a long fight, are another machine's".

*Kit*: hull 12, shield 8, armour 0, heat 12, move 6, 3 hardpoints.
- Disabled Weapon Regulators: every weapon hits an unhurt foe at double its printed number; a
  kill recharges its shield.
- Pinion Driver (fixed): 2 twice for 3, Finisher (double on a foe at half its HP or less).
- Transonic Rifle 5 for 7 (10 opening); Twin Autoguns 3 for 4 (6); Laser Carbine 4 for 5 (8).

*As a whole.* Every entry is a gun, so every turn is a shot, an opener on a whole foe or the
finisher on a half-dead one; two or three shots a cycle on 12. Its only defence and its only
sustain is a shield a kill refills, and the Broken rule cuts that: once its 8 breaks, in two or
three tier-one blows, kills refill nothing until the reboot. Its reboot is the most dangerous
bare turn in the game, 12 hull, no armour and nothing on its die to cover itself; and since 17
November a dying foe's blow lands on its killer, most often the Kite.

*Verdict.* Its identity holds where it plays, short fights full of foes; the system costs it the
refill past a break and a bare turn every short cycle. The lean is that a kill mends a broken
shield, its passive breaking the rule as a one-off; the read has it small at tier one, so it is
a design call.

### Cottonmouth

Wainwright & Sutler, tier 1, light hover. *Context*: versatility of reach, "a tier one that plugs
holes in many draft compositions"; every weapon through the drum.

*Kit*: hull 20, shield 6, armour 0, heat 12, move 6, 4 hardpoints.
- Adaptive Munitions Drum: every weapon and equipment it aims at a foe leaves as the drum's shot,
  Indirect, 4, heat 6, with its own keywords; Penetrate 2 into the back rank, Spread 2 on the
  front.
- Ankle Mortar, Twin Autoguns twice (each the drum's shot); Halo Projector, a Barrier, not drummed.

*As a whole.* Three of its four entries are one shot, 4 on the target and 2 on its neighbours or
on the foe in front of it. At 6 a shot it is two shots a cycle (a third overshoots by 6, a burn
of 6 a turn and the shield broken), so it reboots every third turn on the lightest frame; the 6
was set against its old cooling of 3, four shots to a gauge. It still deals about twice the
vanilla's damage a round when its area finds foes, so the shot is paid in tempo and exposure now,
not in heat. Its identity, a keyword shell of any maker made an area shot, never shows in its
stock (the basics carry none); its Halo is now cover for an ally's reboot.

*Verdict.* The shape holds, a row or a column every shot; the pace does not fit. The levers are
the drum's heat (4 is three shots a cycle) or its gauge, and a keyword shell in its stock (the
placeholder slot's mark).

### Puffin, in design

Kestrel, pegged for tier 2, light hover. *Context*: his 9 November instinct, "the only unit able
to cool its allies"; his 11 November direction, it moves heat: equipment it spends on an ally
pulls some of that ally's heat onto it, and a locked piece passes the Puffin's heat to another
unit with a buff by the heat moved, allies only; its session set for after the heat prices.

*Kit as it stands, undealt*: hull 20, shield 6, armour 0, heat 12, move 5, 4 hardpoints; the
Slipstream Projector (a shield it gives grows with the ally's heat) and the Backwash Ionizer
(shield 3 on an ally) are both shield kinds no die is dealt; the rest is a Halo Projector, two
Twin Autoguns and a Laser Carbine.

*As a whole.* Nothing of the old kit survives the system, and the direction is now its dearest
verb: a pull is an ally's cooling paid on the Puffin's own clock, so its reboot is the team's
vent, and the dump turns heat into a payoff for the machines that read it (the Stingray, the
Storm Petrel, the Whip Scorpion, the Buzzard). The first round as a kit: the pull rides any
equipment it spends on an ally (3 heat to start, the stacks past the ally's maximum first); the
dump is its lock, with Empowered by the heat moved; its stock carries two pieces of equipment,
so the pull has carriers.

*Verdict.* The direction fits the system better than any kit on the list; whether its session
runs now or after the heat prices is his.

### Swallowtail, in design

Wainwright & Sutler, tier 3, assault flyer. *Context*: his helicarrier, "It doesn't rain death,
but it directs units to rain death, offers in-fight refueling and support, and gives them a lift
when needed"; punted on his "Needs a skirmish niche properly carved"; the Horn to be replaced; his
session to start.

*Kit as it stands, undealt*: hull 48, shield 14, armour 1, heat 14, move 3, 3 hardpoints.
- Muster Deck: allies beside it on the map travel with it; every die that rolls fills its Muster a
  sliver, a kill by its guns more, up to three, and its locked pieces spend one unasked for their
  charged forms.
- Mooring Screens: shield 2 on every other ally, a dead kind; charged, Phased on every ally that
  has not acted.
- Spotting Flare: Expose, heat 1; charged, Suppress too.
- Sutler's Hoist: shield 3 and vent 2 on an ally, dead kinds; charged, the ally's shield full, its
  heat gone, cleansed.
- Reveille Horn: a team reroll; charged, an ally acts again.
- Howitzer 4 for 4, Spread 1 and Penetrate 1; Twin Autoguns 3 for 4; Shoring Jack.

*As a whole.* Two of its four locks have dead plain forms, but the system hands it the niche it
lacked: in-fight refuelling is the reboot itself now, so the HQ can be the team's pit crew. Its
charged Screens already give every ally the safe reboot (Phased), and its charged Hoist, written
to clear Broken and Overheated too, would be a reboot by another hand with no bare turn, the
dearest effect in the system behind the Muster's gate.

*Verdict.* A niche for his session to carve; the pit crew is the offer (the plain forms' bench
is the Swallowtail's brief).

### Polar Bear

Minerva, tier 1 pegged for tier 2, assault walker. *Context*: Minerva's form-changing tank; his
rework of 9 November ("The Armadillo is OP"), the trigger of 11 November, and today's "Polar bear
unseals when rebooting"; "probably too much of a wall for tier 1".

*Kit*: hull 40, shield 6, armour 1 (4 sealed), heat 12, move 3, 4 hardpoints.
- Lockdown: equipment it spends on itself seals it, armour +3, 3 hotter at each END TURN, its
  Cryo Flinger gaining Spread; a weapon it fires opens it, and so does a reboot; its weapons deal 1
  more to a foe carrying Cryo. Its text still says "its own cooling stopped".
- Cryo Flinger (fixed): Lure and Cryo 1, Indirect, heat 1; sealed, the foes beside the target too.
- Rivet Gun 3 for 4; Twin Autoguns 3 for 4, twice; Shoring Jack, Armoured 2 (on itself, it seals).

*As a whole.* Open, a plain three-gun line with a point more on Cryo. Sealed, a lure sponge at
armour 4 (6 the round the Jack seals it) on a clock of 4 heat a turn, three turns from cold, the
shell ending in a reboot that leaves it open and bare. Two things the system moved underneath
it. Its shield barely matters sealed: it breaks in the first round of luring and stays broken,
while armour 4 stops tier one's blows of 3 and 4 outright, so the wall is armour against blow
size, not the shield. And its Cryo is now one of the few coolings in the game: sealed, the
Flinger lays Cryo 1 on up to three foes a turn, up to 6 cooling for the team's hitters, which
stretches every other machine's cycle; that may be its real worth to a team now.

*Verdict.* It holds together. Left: the text clause; the wall at tier one (the bench's floor of 1,
or its move to tier two, both his); and an open form with little reason to open.

### Whip Scorpion

Wainwright & Sutler, tier 2, heavy walker, his rework of 17 November. *Context*: the formation
breaker, "heat is its ammunition"; "the reboot vent is the one that explodes", then "remove the 8
heat minimum".

*Kit*: hull 40, shield 8, armour 1, heat 14, move 3, 4 hardpoints.
- Thermal Ejection Manifold: a reboot opens its valves as its heat vents, every foe taking 1 for
  every 2 heat it sheds; every blow a foe lands on it adds 2 heat.
- Heliographic Death Ray (fixed): 2, heat 3, firing its whole heat, a point more a 2 heat, and
  leaving it cold.
- Thermal Ray 6 for 9; Twin Autoguns 3 for 4, twice; Maxigun 2 three times for 4.

*As a whole.* The one kit built on the system: its reboot is its attack, its bare turn a bruiser's
price (40 hull), and the blows it takes bare are the next blast's fuel. Two ways to cash its heat:
the blast on every foe, bare after, or the Ray on one foe with its shield kept and no reboot. Read
with its gate it was the strongest machine against a lone boss; without the gate it blasts a
round sooner.

*Verdict.* It fits. One note: the Ray is a heat dump that keeps the shield, the same dear effect
as the Buzzard's Afterburner, and it outvalues the blast against a lone foe. Its strength's first
lever is his, a lower heat maximum.

### Stingray

Aphelion, tier unplaced, medium hover. *Context*: the hot status amplifier; the Lance support
since 11 November ("a defensive debuff plus an offensive buff"); "Upgrades can redirect it to the
primed+burn abuse".

*Kit*: hull 24, shield 9, armour 0, heat 14, move 5, 5 hardpoints.
- Exothermic Suite: every stack it lays, on a foe, an ally or itself, is 1 deeper for every 5
  heat it carries.
- Photosphere Lance (fixed): Empowered 2 on itself or an ally and Sapped 2 on the foe in front of
  that machine, heat 6.
- Laser Carbine 4 for 5; Halo Projector (a Barrier, which never deepens); Twin Autoguns 3 for 4,
  twice; Ankle Mortar 3 for 4.

*As a whole.* The system suits the Suite: heat only climbs, so it ramps through a cycle (the Lance
2 and 2 cold, 3 and 3 from 5 heat, 4 and 4 from 10), and riding past 14 buys a stack for a burn.
Its stock is the trouble: the Lance is the only thing it lays, so most turns it is a plain gunline
whose heat is a timer and not a resource.

*Verdict.* It fits; its stock starves its passive (riders for the Suite to deepen, the stock
re-deal's), and its tier is his.

### Nemesis

Arsenal, tier 2, heavy walker. *Context*: the sustained-damage bruiser; rage from blows ("a smooth
resource bar ... Taking a hit on shield gives 1 rage, hull damage gives 2 rage"); rage spent in
fives for a fist that is Instant; its fourth slot a placeholder since the Retribution Thurible
went back to design.

*Kit*: hull 36, shield 6, armour 2, heat 14, move 3, 4 hardpoints.
- Crucible Capacitor: a foe's hit on its shield banks 1 rage; hull damage, or a blow of its own a
  foe's armour or Barrier takes whole, banks 2; up to 10.
- Knuckle of Fury, twice (fixed): 5 for 6, melee; for 5 rage, Instant (it rolls again and acts
  again).
- Plasma Arquebus 4 for 5; Blazethrower 3 and Ablate 2 for 6; Twin Autoguns 3 for 4 (the
  placeholder); Halo Projector.

*As a whole.* The system feeds it. Its 6 shield breaks in a round and stays broken, so nearly every
blow is hull damage and 2 rage; its bare reboot turn is a rage turn; and the burn past its maximum
is hull damage at every END TURN, more rage. An Instant Knuckle buys a second spend the same
round, up to 12 heat between them, so its raging rounds push it over its maximum and the burn pays
back in rage: "reboot, or die" as a build.

*Verdict.* It fits. To watch: that loop, rage from its own overheat into more Instant heat; its
placeholder slot is the stock re-deal's.

### Wild Boar

Minerva, tier 2, heavy tracked. *Context*: the vanguard tank that "dives rather than tanks"; it
lost its regen stat and nothing else.

*Kit*: hull 36, shield 8, armour 2, heat 12, move 4, 5 hardpoints.
- Juggernaut Drive: damaging a front-rank foe deals 25% of its maximum HP, rounded up, to the foe
  behind it; after it gains a Barrier, its next weapon ignores armour.
- Breaching Plow (fixed): a Barrier on itself and a Cleanse, cooldown 1.
- Slugthrower 4 for 4, twice; Shotfire Rack 4 for 5; Twin Autoguns 3 for 4; Shoring Jack.

*As a whole.* Guns above the vanilla, a shove that turns front-rank hits into back-rank damage, two
cool defensive entries that stretch its cycle, and armour 2 that keeps its bare turn survivable. As
sturdy as the Honey Badger in the read.

*Verdict.* It fits; the reboot leaves it nothing to fix.

### Giant Petrel

Kestrel, tier 3, assault hover. *Context*: Kestrel's capital and the reroll economy; his note of 5
November, "Placeholder model, unrefined kit"; the kit's session his to start.

*Kit*: hull 44, shield 14, armour 0, heat 14, move 3, 3 hardpoints.
- Maverick's Playbook: the team's rerolls left unspent bank, up to three.
- Immelmann Booster (fixed): Rapid, a team reroll; or for three rerolls a spent ally's die rolls
  again and it acts again.
- Spindrift Salvo (fixed): 4 for 7, Indirect; a kill brews two rerolls.
- Reheat Uplink (fixed): Empowered 2 on an ally, and its die rolls again.
- Overclocked Railgun 8 for 11, ignores armour; Twin Autoguns 3 for 4, twice.

*As a whole.* Rerolls cost no heat, so its economy stands; but its gifts are actions, and an action
costs its receiver heat: a second action on a hot ally is a burn, and a rebooting ally cannot take
one. So its tempo is worth most on cool allies. Its own Railgun is one shot a cycle.

*Verdict.* The system moves what its gifts are worth, not its rules; its unrefined kit is his
session's.

### Musk Ox

Wainwright & Sutler, tier 3, assault wheeled. *Context*: the artillery on ammo; "Ox will be
tackled in a seperate session"; its salvo a stand-in.

*Kit*: hull 44, shield 10, armour 1, heat 8, move 3, 4 hardpoints.
- Desublimation Forge: its weapons spend ammo instead of heat, 1 for every 2 heat a gun would
  make; the magazine holds 10, opens at 3 and gains 1 a round; a vent it spends on itself adds 3,
  a shield 2.
- Shrapnel Recuperator (fixed): 1, Spread 1, Penetrate 1, Brittle 1 (3 ammo), and an ammo back
  for every foe it reaches.
- Unrestricted Expenditure (fixed): needs 8 ammo, empties the magazine, 2 on every foe.
- Quick Reload (fixed): Rapid, heat 3, 2 ammo back.
- Thermal Ray (5 ammo); Enfilade Beam 4, Penetrate 3 (3 ammo); Twin Autoguns (2 ammo); Shoring
  Jack.

*As a whole.* Its clock is ammo and not heat: its guns never heat it, so it hardly reboots for
heat, its reboot is for its shield alone, and the reboot leaves its ammo as it stands. The Forge's
"a vent adds 3, a shield 2" reads nothing now, since no die deals either and the Quick Reload
counts as no vent.

*Verdict.* The reboot barely reaches it; the dead clause is its own session's.

### The nine the rule does not reach

The Honey Badger, the Clydesdale, the Dingo, the Funnel-web, the Ammit, the Baboon, the Prairie
Dog, the Cassowary and the Lammergeier: nothing of theirs reads heat, cooling, regen or a shield
gain; they lost their stat lines alone. Written out the same way on his word.

## What moved since the list

The list was read on 13 November. Since then: Ablate stands in Burn's place, damage and never
heat, so no foe heats a machine but by Scorched, and Burning is no longer a source for the Storm
Petrel's hook; Regenerating pays at END TURN, a stack fading a turn (3 is 3, 2 and 1), and none
lands on a Broken shield; Phased is built, the safe reboot; a machine's Barrier goes as its side's
turn starts, so it cannot cover its own reboot (the reboot needs nothing spent) and only an ally's
can; and the vanilla is 3 for 4 heat, so a basic die stands at its maximum of 12 after three
shots. And on 17 November, on main as this page was written (his "Maybe the heat gets shunted when
the shield gets taken down?"): a reboot's heat goes as its shield drops, the recovery bringing the
shield back, so heat laid on a machine after the vent stays; a dying foe's blow lands on the
machine that killed it; and the Whip Scorpion's blast is its reboot's vent, so a passive reads a
reboot now. Then his eighteenth round, the same day: a reboot opens the Polar Bear's seal, and the
Scorpion's blast has no gate. Nothing reads a break or an overheat: his ruling allows one of each
between reboots, and no piece prints either.

## The read

A probe, a direction and no runner row (`tools/reboot_probe.gd`; `docs/measurements.md`, 17
November), on main at `0565624`: the vent at the drop in, his eighteenth round not yet, so the
bear reboots sealed and the Scorpion's blast keeps its gate of 8. Each machine is fielded first
in a squad of four beside the Honey Badger, the Prairie Dog and the Cassowary, which the rule
does not reach, the greedy bot playing. Against tier one's
formations and elites (21 compositions, 8 seeds, 168 fights a machine) every fight is short, five
rounds, and every machine reboots about once a fight. Against tier one's bosses alone (13, 6
seeds, 78 fights a machine) the cycle shows. Of its turns, the share it rebooted and the share it
stood bare of shield as the enemy struck; its own hull lost and its fights wrecked.

| The machine | Formations: rebooted, bare, hull lost | Bosses: rebooted, bare | Bosses: hull lost, wrecked |
|---|---|---|---|
| Honey Badger (the rule does not reach it) | 16%, 18%, 3% | 18%, 22% | 14%, 0% |
| Wild Boar | 16%, 18%, 2% | 18%, 22% | 14%, 0% |
| Prairie Dog | 11%, 13%, 6% | 13%, 17% | 28%, 5% |
| Cassowary | 8%, 9%, 4% | 10%, 13% | 30%, 9% |
| Polar Bear, rebooting sealed (sealed 7% and 16% of its turns) | 17%, 19%, 5% | 22%, 26% | 31%, 4% |
| **Storm Petrel** | 11%, 35%, 7% | 16%, 42% | 33%, 10% |
| **Buzzard** | 11%, 12%, 2% | 15%, 18% | 15%, 3% |
| **Kite** | 19%, 20%, 8% | 23%, 24% | 36%, 17% |
| Needletail | 25%, 25%, 4% | 29%, 30% | 23%, 1% |
| Cottonmouth | 18%, 18%, 7% | 17%, 17% | 32%, 8% |
| Skua | 14%, 15%, 7% | 17%, 21% | 29%, 4% |
| Whip Scorpion, its blast gated (blasts 0.6 and 0.9 a fight) | 16%, 17%, 3% | 16%, 20% | 9%, 0% |
| Stingray | 15%, 16%, 4% | 19%, 24% | 26%, 4% |
| Nemesis | 19%, 21%, 3% | 20%, 24% | 18%, 0% |
| Giant Petrel | 13%, 13%, 2% | 19%, 19% | 12%, 0% |

Hull lost is a share of the machine's own, so a light reads higher than a heavy for the same
blows: the Kite is read against the Prairie Dog and the Cassowary, the Petrel against them and
the tanks. The bot plays the reboot by a first heuristic and knows nothing of a seal's timing, a
Kite's kill or a Petrel's plate, so its losses are a floor of skill, and today's foes were sized
against a shield that refilled. What it says: the Petrel is the machine the rule breaks in
play, bare twice as often as anyone; the Kite is wrecked twice as often as the other lights
against a boss, though that is its design, a lone boss leaving it nothing to kill; the bear's
seal is barely used; the Needletail gives the most turns to the
reboot without paying for it in hull; the Buzzard, whose Afterburner is the one heat dump left
that keeps its shield, reboots least for its heat (about five a turn on its stock die, the
Cottonmouth's and the Kite's pace, where those two reboot on a fifth of their turns); and the
reworked Scorpion, whose dump is its reboot now, reads strongest against a lone boss (6.5 rounds,
the squad losing 14%, where the rest take 8 to 12 rounds and 19% to 30%).

Three leans, laid over the probe's fight loop where the engine had no switch for them (its
`--whatif`), each against its machine as it stood; the bear's is his ruling since and built. The
two forms of the Petrel's lock read alike, and the hot lure is the one idea. The Kite's needs a
bot that fights a broken Kite on for a kill, since the bot reboots a broken machine whenever a
blow is coming, so that bot is read alone beside it. Bosses: rounds, won, and the squad's hull
lost beside.

| The lean | Formations: bare, own hull, wrecked | Bosses: bare, own hull, wrecked | Bosses: rounds, won, squad |
|---|---|---|---|
| Polar Bear, rebooting sealed | 19%, 5%, 0% | 26%, 31%, 4% | 11.1, 97%, 30% |
| The reboot opens it (his ruling since) | 19%, 6%, 0% | 25%, 33%, 3% | 11.7, 96%, 31% |
| Storm Petrel as built | 35%, 7%, 0% | 42%, 33%, 10% | 8.3, 100%, 24% |
| The hook, the Regenerator kept | 17%, 5%, 0% | 25%, 30%, 6% | 10.8, 99%, 26% |
| The hook, its lock a lure of heat 3 | 18%, 4%, 0% | 27%, 27%, 5% | 10.9, 96%, 28% |
| Kite as built | 20%, 8%, 2% | 24%, 36%, 17% | 8.9, 99%, 27% |
| A bot that fights a broken Kite on | 20%, 8%, 2% | 24%, 36%, 15% | 8.8, 99%, 27% |
| That bot, and a kill mends | 19%, 7%, 1% | 23%, 36%, 15% | 8.8, 99%, 27% |

The bear's lean, his ruling since, costs it two points of its hull a boss fight, small because the
bot seals on few turns. The Petrel's hook halves its bare turns and its wrecks, and its fights run two rounds
longer with the squad paying two to four points more: the zap was a fair share of its damage, so
the direction makes it the tank and takes the striker out (its kit, above). The Kite's mend moves a point
in formations and nothing against a lone boss.

## What is his

1. Storm Petrel: landed 17 November on his "Your verdict leans are solid", with his branches
   (the bible's row; `docs/measurements.md`, the same day, reads the four builds).
2. Buzzard: landed 18 November on his "Do the carrion-style", its own spend free to break its
   shield, with his branches (the bible's row; `docs/measurements.md`, the same day, reads the
   three builds).
3. Needletail: landed 18 November on his calls, its Designator at no heat and its reboot its
   second spend (the bible's Kestrel row); his "dull" waits on his play.
4. Skua: its ramp for a cycle or for a fight.
5. Kite: a kill mends a broken shield (lean), or left as it is.
6. Cottonmouth: the drum's heat or its gauge, and a keyword shell in its stock.
7. Puffin and Swallowtail: their sessions now, or as set.
8. Polar Bear: "its own cooling stopped" off its text; the wall at tier one stays with the bench.
