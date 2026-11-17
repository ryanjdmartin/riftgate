# The machines the reboot broke

Ryan, 13 November, as he ruled the reboot: "I'd also like a list of the chassis that break with
this change, so that I can start brainstorming." The list is the refit brief's section 22 (`The
machines, redone against the briefs`). Ryan, 17 November: "Now that we have some decisions made
from the new game mechanics, I want to examine the chassis that broke during the huge change to
heat and shield and work on fixing them."

This page reads that list again against the game as it stands on 17 November, and puts a first
round of fixes to him. It builds nothing and moves nothing in content; two of its machines were
settled on main the same day by his own rulings in another session (the Polar Bear, the Whip
Scorpion). It retires once its calls are rows and content.

## The whole of it

| The machine | What the rule did to it | The fix put to him |
|---|---|---|
| Polar Bear | Its seal was priced against a cooling that stopped; none exists, so opening cools nothing, and a sealed bear rebooted inside its shell at armour 4, so the shell never had to open | Decided and built on main the same day, his word ("Polar bear unseals when rebooting"), this page's lean too; one clause of its text is left (below) |
| **Storm Petrel**, as built | Its guns spend the shield it tanks with, and a shield its own guns empty is Broken: bare on 42% of its turns against a boss, a tank losing a third of its hull | **Build his direction of 11 November**: a point of shield for every point of heat it gains, the plate kept, its lock a lure that runs hot. Emulated, its bare turns and wrecks halve, and its fights run longer without the zap |
| **Buzzard**, as built | Its regen climbs with a heat that never leaves, and the Afterburner is a reboot's heat half that keeps the shield | **Build the form settled on 11 November**, with two corrections and one hole (below) |
| **Kite** | A kill recharges its shield, but a Broken shield takes nothing: once its 8 break, its 12 hull is bare until it reboots. Small at tier one in the read; a design call more than a measured need | **A kill mends its shield, broken or not**: its passive breaks the Broken rule, as a passive may |
| **Puffin** (in design) | Moving heat, his direction, is now the dearest verb in the game | **A first round of its kit** (below); its numbers wait on the heat prices |
| **Swallowtail** (in design) | Two of its pieces are kinds no die is dealt | **A niche for his session: the pit crew**, the machine that runs the team's reboots |
| Needletail, Cottonmouth, Skua | Their pace moved: the Needletail reboots on a quarter of its turns, the drum's heat was set against a cooling of 3, the Skua's ramp halves on its reboot's bare turn | Flagged: a number each, or as designed (below) |
| Whip Scorpion | Reworked on main the same day on his word ("the reboot vent is the one that explodes"): its blast is its reboot's vent, and since his next round it has no gate, 1 on every foe for every 2 heat it sheds | Done, his |
| Stingray, Nemesis | The rule fits them: stacks deeper the higher it rides; rage from the hull the shield no longer covers | Nothing to fix |
| Wild Boar, Giant Petrel, Musk Ox | Only their stats went (regen 3, cooling 3); the Musk Ox's ammo stands apart | Nothing to fix; the Musk Ox's own session |
| The other nine | Nothing of theirs reads heat, cooling, regen or a shield gain | Untouched |

What is his is the last section.

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
the direction makes it the tank and takes the striker out (below). The Kite's mend moves a point
in formations and nothing against a lone boss.

## The fixes

### The Polar Bear: decided, the reboot opens it

*What the rule did.* Its seal was priced in heat against a cooling it stopped (the bible's row:
"with no vent on any die its heat has one way down, opening"). Nothing cools now, so opening
cooled nothing, and a reboot clears no status, so a sealed bear rebooted in its shell, no shield
and armour 4, which tier one's blows of 3 and 4 cannot pass: three turns sealed and one rebooting,
for good, and the shell never had to open.

*His ruling, 17 November, his eighteenth round*, on the question another session had put to him
that morning, with this page's lean: "Polar bear unseals when rebooting.
It's a good change because you're never accidentally stuck sealed, and a weaponless build is
possible if you wanted it for some reason." Built on main the same day (`d657a20`): the shell and
its armour go as the die drops, and it stands open and bare through the enemy's turn. The read
above has the lean's price as the bot plays it, two points of the bear's hull a boss fight.

*Left.* Its passive still says "its own cooling stopped", a cooling no chassis has; the clause
goes, the rest of the text as it stands (a draft, his to write). If the Barrier leaves the stock
dice (his lean), the bear's open turn has less cover; and the bot seals on few turns, so how a
player times the shell is read by his play, not the runner.

### The Storm Petrel: build his direction

*As built*, the old form: the Riot Field Generator burns its guns' heat off its shield and zaps
the target with it, and the St. Elmo's Regenerator lures and lays Regenerating 3.

*His direction, 11 November* (its brief): "The thing I want to keep mostly on it is the shield
armour ... gaining shield when it gains heat is a really solid hook. That would fuel the shield
tank role with risk ... The shield zap can go somewhere else." The zap went to the Buzzard the same
day.

*What the rule did.* To the built form, it is the worst on the list: its guns empty the shield
it tanks with, a shield its own spend empties is Broken until the reboot ("you can break
yourself"), and the Regenerator lands nothing on a Broken shield. To the direction, the opposite:
heat is a clock that never runs back, the hook turns the clock into shield up to its maximum, and
the overheat it walks toward breaks the shield it built. The risk he asked for is the rule's own.

*The lean, as a spec.*
- The Riot Field Generator: while its shield stands, every blow on it loses 1, and every point of
  heat it gains stands up a point of shield, up to its maximum. Any source: its spends, Scorched's
  extra, heat an ally moves onto it. A Broken shield takes none.
- Its weapons make heat as anyone's. The shield burn and the zap leave the engine with their last
  carrier, unless the Buzzard's cannon takes the zap's path.
- Its lock: a lure that runs hot (heat 3 to start), so its taunt raises its own shield through the
  hook, one idea where the Regenerator was two; the Regenerating goes. The name is his, and St.
  Elmo's fire still fits a lock that glows hotter.

*The bench.* The Regenerator kept as built beside the hook: two shield sources on one machine, and
a regen grant on the lock that his expectation would gate. A point of shield for every two heat:
half the hook, if one a point reads too strong.

*Holes.* The read's: the direction makes it the tank and takes the striker out. Its bare turns
and its wrecks halve, but without the zap it deals less, so its fights run two rounds longer and
the squad pays a few points more as the bot plays it. What has to pay for that is its lure, blows
drawn onto a plated shield that mends instead of onto a light's hull, and the bot weighs a lure
crudely; if its damage is wanted back, the lever is a gun in its stock (the stock re-deal), never
the zap, which is the Buzzard's. At one a point, three basic shots are its whole gauge again, a
cycle's shield doubled before the plate. A full shield gains nothing, so the hook pays the tank
that is struck, the lure its partner. The Boundary-layer Bleed is the hook in a module (his "no
bar"). The Puffin's dump onto it is heat in and shield out: a pair to watch.

### The Buzzard: build the settled form

*As built.* The Thermal Recoupler: its regen 1 higher for every 4 heat. The Afterburner Cannon:
its whole heat in one blow, leaving it cold.

*Settled, 11 November* (its brief): its passive pays a flat shield cost on each weapon, unasked,
for flat damage, firing plain when short ("Automatically paid. Everything should be automatic in
this game"); its cannon fires its whole field; its heat raises its regen.

*Read under the rule, the settled form stands.* Heat climbs through a cycle and the regen with
it, refilling what the guns pay; the cannon cashes the field; the reboot follows. Its heat dump
goes with the cannon's old form, so it reboots like anyone, which is right for a machine whose
heat is its sustain. Two corrections to section 22:
- The cannon is not free before a reboot. The shield it fires is the shield that would have stood
  through the enemy's turn, so the cannon and then the reboot are two turns bare where the reboot
  alone is one. That turn is the cannon's price.
- Its regen has no base now: cold it has none, so a cycle's first turns are its thinnest.

*The hole, his.* The unasked cost that takes its last point breaks its shield, and a Broken
shield regenerates nothing until the reboot, so an automatic payment can switch its own sustain
off. Lean: the passive pays only while a point would stand, so nothing automatic breaks it and
the cannon is the one break it chooses.

### The Kite: a kill mends its shield, broken or not

*As built.* Disabled Weapon Regulators: double on an unhurt foe; a kill recharges its shield.

*What the rule did.* A Broken shield gains nothing by any method, a refill on a kill named in the
rule. The Kite's 8 breaks in two or three blows, and from there its refill does nothing until it
reboots: its one way to live is gone for the rest of the cycle, its hull of 12 bare.

*What the read says.* Less than the rule suggests, at tier one. Against tier one's bosses it is
wrecked in one fight in six, but a lone boss gives it nothing to kill, so that is its design ("a
long fight, are another machine's") and no lean moves it; in tier one's formations the lean,
with a bot that fights a broken Kite on for a kill, takes its wrecks from 2% to 1%. The break
bites where a fight is long and full of foes, tier two's, which no read here reaches.

*The lean.* Its kill mends a broken shield. The passive breaks the Broken rule as a one-off, which
is what a passive is for (the bible's section 7: "A passive may break a rule, as a one-off"). Its
design is "a kill recharges its shield whole", and the Broken rule came two days later without
being read against it. The rule holds for every other machine, and the exception lives in the
Kite's own words.

*The bench.* Leave it: a short fight seldom reaches the break, and its risk is the point. A kill
grants a Barrier in the shield's place. A kill Phases it: the shadow panther's orbit (his, 11
November: "It keeps the phased orbit, not the Kite").

*Holes.* A mended shield can break again in the same cycle; a trigger on a break, when one exists,
still fires once between reboots (his ruling), so the exception reaches the shield and never the
trigger. A kill mends the shield and never the heat. And since 17 November a dying foe's blow
lands on the machine that killed it, so the machine that kills most takes the most of those
blows: the Kite, on a shield the kill has just mended or on a hull it has not.

### The Puffin: a first round of its kit

*His direction, 11 November*: "it MOVES heat around. Using an equipment on an ally moves some of
its heat to the Puffin. A locked piece can transfer the Puffins heat to another unit along with a
buff based on heat moved, so it gets along with the Buzzard and stingray, and other niche
interactions like forcing an overheat for hull damage. I'd probably move it to tier two though."
The dump goes to allies only.

*What the rule did.* It made the direction the dearest verb in the game. Short of a reboot, a dump,
Cryo or a module's cooling, moving heat is the only way heat leaves a machine: a pull is an ally's
cooling paid on the Puffin's own clock, and the dump hands the heat to a machine that profits
from it (the Stingray's stacks, the Petrel's shield, the Scorpion's blast, the Buzzard's regen)
or that pays for it (an overheat, the Nemesis's rage). The team's heat is moved, not removed, until the Puffin
reboots: its reboot is the team's vent, and its bare turn the team's price.

*A first round.*
- Its passive: equipment it spends on an ally takes 3 of that ally's heat onto the Puffin, the
  stacks past the ally's maximum first. A flat number the readout can show; "some" is his.
- Its lock, in the Backwash Ionizer's place (a shield no die is dealt): the dump, all its heat onto
  an ally, the ally Empowered 1 for every 3 heat moved.
- The pull rides the equipment it carries and is never an entry of its own, so the refit's rule of
  no pure recovery piece holds; its stock carries two pieces of it (the Halo Projector and the
  Shoring Jack, where today it carries the Halo alone), so two entries of five can pull.
- Tier two; Kestrel's tier one is then the Skua and the Storm Petrel.

*Holes.* A pull on a rebooting ally takes heat its recovery would take anyway. A dump past an
ally's maximum overheats it, its shield breaking and its burn standing: allowed, his "forcing an
overheat", and the readout shows the gauge after. Its session was set for after the heat prices
land: the shape is his to mark now, its numbers after.

### The Swallowtail: a niche for his session

*His word, 11 November*: "Needs a skirmish niche properly carved. It's got solid base mechanics
but nothing solid to do with them." Its fantasy, his: "It doesn't rain death, but it directs units
to rain death, offers in-fight refueling and support, and gives them a lift when needed."

*What the rule hands it.* In-fight refuelling is now the reboot itself, and the dearest thing the
rule has is a machine back cold and whole without its bare turn. A helicarrier that runs the
team's reboots, a pit crew, is a verb no machine has, and his fantasy's own word.
- Its charged Mooring Screens already are one: every ally that has not acted waits for Phased,
  and is Phased through the round after, where a reboot is the safe one; so the charge is the
  whole team's pit stop. Their plain form, a shield on every other ally, wants another: a Barrier
  on every ally that has given its turn to a reboot, cover for the team's reboots that cannot
  stand as a block, since a machine rebooting does nothing else. It bends the Barrier's rule (no
  piece grants it to every ally at once) on his word of 10 November ("A team ward is probably ok,
  as is a team barrier ... it's just combining them in a way that doesn't let both be cast back to
  back granting perpetual invulnerability").
- Its charged Sutler's Hoist ("its shield full, its heat gone", cleansed) would be a reboot by
  another hand with no bare turn, the dearest effect, gated by the Muster, once it says so whole:
  an ally recovered as a reboot recovers it, Broken and Overheated gone, since a Broken shield
  takes no refill otherwise. Its plain form, a shield and a vent, wants another; cooling an ally is
  the Puffin's, his call across the two.
- The Spotting Flare stands; the Reveille Horn is to be replaced, its own question.

An offer for his session, nothing more.

### The pace, flagged

- **Needletail.** Two spends a round on a light's maximum of 12: it reboots on a quarter of its
  turns, the most of any, and each reboot gives up two actions. Its lever is its maximum (about
  20 would give it the vanilla's share of actions a cycle; 16 halves the gap), a number for the
  heat session or for this pass, his choice.
- **Cottonmouth.** The drum's heat of 6 was set against its cooling of 3; it is two shots a cycle
  now. Its lever is the drum's heat or its gauge, the heat session's.
- **Skua.** Hull damage halves its Ricochet, and its reboot's bare turn is a turn of hull damage,
  so its ramp spans a cycle unless an ally covers its reboot. As designed ("it ramps only while
  its shield holds"), and the cover is the counterplay; read again with the Barrier's place.

## What is his

1. The Storm Petrel: a point of shield a point of heat, its lock a hot lure, the shield burn and
   the zap cut; built on his word.
2. The Buzzard: the settled form built, the last point kept (the lean).
3. The Kite: a kill mends a broken shield (the lean), or left as it is.
4. The Puffin: its first round, now or kept for its session after the heat prices.
5. The Swallowtail: the pit crew as its niche, for his session.
6. The Needletail's maximum: now, or with the heat session.
7. The Polar Bear's passive text: "its own cooling stopped" goes.
