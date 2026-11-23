# The tide's shape: formations and spawns rethought

A proposal, from Ryan's play of the field's dials and his words of 23 November. Sections 3 to
9 are in neither content nor the engine: they are the battle's enemy side reasoned again from
its goals, with what was measured, the holes, and the few questions only he can answer. What
was built that day is section 2. The formation pass (the to-do's design sessions) runs from
here once he marks it.

## 1. What Ryan said (23 November)

- "The biggest hurdle to overcome, and the most thematic, is quantity. I feel like I would
  rather more packs on the map, and a much wider variety of them with different strengths and
  weaknesses, so that I can choose where to attack and what to let through, instead of just
  hovering by a spawn point and fighting whatever pops out."
- "It feels to me like the game would be more fun if fodder were the primary, significant,
  threat to the wall, but easy to defeat without any hull lost by a decent player, and we push
  all the 'interesting' fights into Hunters, Elites, and Bosses ... Fodder should pose a
  threat by quantity, not by hard hits."
- Of the first cut of this proposal, which asked whether a formation stays a fight for three:
  "missing the point. Right now, there is NO REASON to send a machine to the flanks to fight
  the 1s and 2s. Even with fodder worth set to half in the trials tab, it was optimal to just
  group all 4 in the center and spawn camp. Any time I tried splitting my forces, I lost the
  battle. Any time I stayed in the middle, I won. The game as it was, was fundamentally flawed
  and not meeting our goals. I don't want 'tweak what's there,' I want 'rethink how we're doing
  formations and spawns entirely.'"
- Of the elites: "I don't want to be able to lead around Elites. I want it to be a forced
  fight, without feeling like a forced fight. The theme is 'they're crushing our armies, we
  need to sick an Elite on the machines.'"
- Of the Convergence: "I thought the point was that formations had adjustments based on
  convergence levels, that was in the design. A set form of each formation, for each C. Bosses
  too ... If the only thing that scales by C is the pack quantity, then the player is going to
  go through power spikes as they outfit their units, especially for bosses and elites. This
  needs to be sorted out. It's fundamental for balance. I'm barely scraping by some of these
  fights at C2 with stock units, if they don't scale with me they'll become a joke at C4."
- Of the tears: "Spawn then move is sorted out by not putting tears so close to the wall, at
  least so quickly."
- Of the pace: "I'd rather they don't start so close but reach the wall faster ... I'd
  probably give everything +1 right now and see what that does."

## 2. Built that day

In the game: the zoom out to the whole field; the seam a circle about the rift, a picture
alone; the round shown under the whole field; a pusher's segment the stretch of wall it reaches
soonest; the tears' row a row a peak and never within four rows of the wall; four tier-one
stock dice back to basics (`docs/rules.md`, The battlefield; the bible's wall, tears and seam
rows).

On trial, a debug build's SETTINGS, TRIALS, none the game's until he says: PACE (+1, +2);
SPAWNS (a pack walks the turn the tide sends it: the rift's, or every mouth's); RIFT SENDS (two
or three a peak, each to its own stretch of wall); FLANK TEARS (two from the first turn, at
the wall's ends); FORMATIONS (every formation as three packs for one machine, the nearest
thing to section 4 on today's units); LEADERS (an elite's and a boss's hit points a tenth or a
fifth more for each Convergence past its tier's first, the first number of section 5 and not
its form).

For the reads: `--refit finds=N`, a squad a few battles into its tier (N basic guns a die
swapped for tier-one finds), and `tools/anchor_read.gd`'s `life=`, a leader's hit points at a
share of content's, beside its `blows=`.

## 3. Why the middle wins today

Four causes, each a rule as it runs:

1. **One mouth matters.** The rift sends every formation, three pips each, and half the
   patrols; a tear sends a patrol a peak. Most of what fills the Rupture meter and most of
   what threatens the wall comes out of one hex at the field's middle.
2. **The win runs through the same hex.** The meter fills fastest where the formations are,
   and the boss it unseals stands at the rift. A squad parked there kills each wave where it
   lands, since a spawn stands a turn, and is already at the boss.
3. **A formation needs three machines at once.** So the squad can spare one, and that one
   fights alone: a duel at best, a hunting pack rated two at worst, and an elite or a boss met
   a machine short costs four to six times its price. Splitting is what loses hull.
4. **The flanks are worth nothing.** A patrol strikes ten a turn against a gate of 200, pays
   one pip, and the battle is over, two beats of the tide, before it adds up.

So grouping costs nothing and splitting costs hull: one strategy, and no dial moves it. The
coverage model agrees as far as it goes: as built, four machines use two actions in five.

## 4. The rethink

**What it must pass** (design tests, his to strike or add to):

- No hex is worth standing on all battle: wherever four machines stand together, most of the
  tide walks past them.
- A machine alone is whole against fodder: sending one somewhere is never fighting short.
- The flanks are worth what the middle is: the same packs, the same pips, the same wall.
- The fights that cost hull come to the squad, on a clock the player moves: when, where and
  with whom are his, whether is not.
- Every Convergence the same battle is a notch harder, in a form written down.
- A battle still fits ten to thirty minutes.

**A front, not a mouth.** The tide comes through tears across the whole width, open from the
first turn, more of them than one squad can stand on, each sending no more than one machine
answers. The rift sends no fodder: it is the boss's seat and the door the hunters and elites
come through. Then nothing is gained by standing at it, and the squad that stays together
watches the tide walk past on both sides. In the model the same three packs a turn cost a
squad that spreads the same whether they come through the rift or through six tears (7 and 15
of the gate lost in twelve turns); a squad that holds the middle against six tears loses the
wall four times over (861).

**A formation is a wave.** A named set of small packs that come together through
neighbouring tears: two knots of goblins, a bed of mandragoras, a shaman with his guard. Each
pack is a fight for one machine; a wave's anchor (a treant, a knight) may be a fight for two.
The wave is what is authored, named, shown a beat ahead at its tears, and given a set form
for each Convergence (section 5). A lone machine thins a wave a pack a turn; three machines
end it in one. So concentration buys speed, never permission, and cause 3 is gone. The eight
cell grid stays for what is still one fight: a hunting pack, an elite and its retinue, a
boss's escort.

**Fodder is a fight for one, and short.** Two rounds for a machine alone, one for a machine
with an area gun: foes a basic gun ends in one shot, two or three to a pack, blows a shield
takes. Its threat is the wall: ten a pip a turn, for as long as it stands there. The variety
he asks for is two things crossed: how a pack threatens the wall (its pace, whether it flies,
how hard it strikes) and what die answers it (a line, a screen with something behind it, a
swarm, one tough body, plate), so which machine goes where is a matchup and not only a
distance.

**Hunters stay the soft wrench**, as the hunters row has them: a pack rated two that locks a
machine, declared, a turn's walk away as it lands. In a squad that holds a lane each, the lock
is what pulls a neighbour off its lane.

**The elite is sent at the machines.** At a Fracture, which is the squad crushing their
armies, the elite comes for the machines that earned it: named on the Fracture's band, and
through a tear torn open beside its mark wherever the mark has gone, so there is no walk to
lead astray. Its fight opens the player's turn after next: the mark must fight, and every
machine inside its ring fights with it. Forced, and it does not feel it, because all of its
terms are the player's: the meter is on screen, so he chooses which fight tips the Fracture,
with which machine, and where the squad stands when it does; then he has a turn and a half
to bring the others in, each lane left open costing the wall. What it costs is the wrench:
hull if he gathers too few, wall if he gathers them all.

**The boss** as it is: sealed until the Rupture, its fight taking every machine wherever it
stands, so nothing about it asks the squad to wait at the rift.

## 5. A set form for each Convergence

**What the records hold.** His design is there: compositions as discrete variants placed on
the tier and the Convergence (7 November: "if composition #3 is 3 goblins and a shaman, and
#3a is 4 goblins and a shaman ... we should be able to figure out somewhat empirically where
in the tier-ramp curve that should sit"), and "a boss' tiered and ramped stats and escorts
should be split into seperate fixed entries, same as a pack's would." The gate that deals a
variant at its Convergences was built that day and still runs. What happened after: the
formation pass of 9 and 10 November wrote the variants (six, seven, eight foes) and pruned the
thinner of each pair, because its read, on the game before the reboot, found they moved no
band; and the bosses' entries waited on "Don't curate the bosses now, that can wait" and never
came back. So today 26 of 119 compositions carry a gate, the bands are eight Convergences
wide, no leader's numbers move inside a tier, and from the first battle of a tier to its last
the only thing that grows is the opening's count. He is right that this was the design and
right that it is missing.

**How big the spike is** (`tools/anchor_read.gd`, tier one at its second battle, the six
certain tier ones, every squad of them, three fights a squad, the greedy bot;
`docs/measurements.md`, 23 November). A battle's caches hold five to eight components against
about fifteen weapon slots in a squad, so two finds a die is a squad one or two battles in:

| The squad | A formation | An elite | A boss |
|---|---|---|---|
| Stock, basics | 8.0% of a four's hull, 6.1 rounds | 21.5%, 7.8 rounds | 27.0%, 10.6 rounds |
| One find a die | 6.4% | 18.8% | 24.0% |
| Two finds a die | 5.5%, 5.2 rounds | 13.7%, 5.6 rounds | 16.9%, 7.1 rounds |

A third off every leader's price in two battles, from guns alone, picked round the tier's
finds and never the best; a player who picks does better. And the block that puts a leader
back against the squad with two finds a die:

| A leader's block | An elite | A boss |
|---|---|---|
| Hit points ×1.25 | 18.1%, 6.8 rounds | 21.6%, 8.8 rounds |
| Hit points ×1.5 | 23.0%, 8.0 rounds | 26.7%, 10.5 rounds |
| Hit points ×1.25, blows ×1.15 | 25.2% | 30.3%, won 96% |
| Hit points ×1.4, blows ×1.25 | 34.0% | 40.6%, won 91% |

Half again the hit points at the same blows lands both on the anchor's price and length. So
today's kit grows by about a fifth of a leader's hit points a Convergence, and blows are the
sharper dial: a sixth more of them costs the squad more than a quarter more hit points does.

**The two slopes.** The curve inside a tier is the kit's growth against the foes' steps.
Today the first is steep, since eleven of fourteen tier-one guns deal a point more than a
basic and six carry a keyword, and the second is nothing. His tier-one bench (each
find the vanilla with one thing traded) flattens the first; the forms below raise the second.
They are sized together or the game is tuned twice.

**The form.** Each a fixed entry by tier and Convergence, written and never multiplied:

- A wave: its roster at each Convergence of its tier (which packs, how many).
- A hunting pack: its heads at each.
- An elite and a boss: a block of hit points, blows and plate at each, and the retinue or
  escort beside it. `docs/formation_proposal.md`, section 6, has the block's shape; the gate
  already deals a retinue or an escort by Convergence.
- The tide: its tears and its beat (the ramp's table, as now).

A tier is fought across four Convergences and a rift left alone is fought later still, so a
form holds from its Convergence until the next is written, and a tier's last form holds to
the end: an old front fought late is never easier than it was.

## 6. The coverage model

`tools/tide_model.py`: twelve turns, four machines of move 3 to 6 that see everything and
fight for free, so every cell is the tide at its kindest and is read against its neighbours.

| The tide | Packs sent | Packs that struck | Gate lost | Actions spent fighting |
|---|---|---|---|---|
| As built | 13 | 11% | 15 | 40% |
| Twice the packs, as built | 26 | 24% | 275 | 67% |
| Twice the packs, formations as packs for one | 38 | 15% | 96 | 74% |
| Three packs for one a turn through the rift | 42 | 2% | 7 | 81% |
| The same through six tears, the squad free | 42 | 3% | 15 | 81% |
| The same, the squad holding the gate's middle | 42 | 39% | 861 | 47% |
| Four packs a turn through six tears | 54 | 10% | 66 | 91% |

The band with something to let through is narrow: three packs a turn is a squad at work, four
is the wall going. A real squad, whose fights cost turns and hull, sits lower. Pace: a hex
more changes little with the opening a move farther out; two more is a cliff at twelve deep.

## 7. Holes, each with what would settle it

1. **The battle's length.** A squad busy four actions in five fights about thirty fodder
   packs in ten turns. A machine lands one blow a round, so fodder must fall to one basic
   shot and come two or three to a pack, or the thirty minutes go. Settles it: his play of
   FORMATIONS on PICKETS ×2, timed, and the fodder's hit points with it.
2. **A fight with nothing at stake.** Shield and heat are whole as every fight opens, so a
   clean fodder fight costs its action and nothing else. It needs a stake that is no hull.
   The bench's first line is one.
3. **A lane is a lonely place.** A hunter's lock finds a machine alone by design. The lock's
   turn of notice is what a neighbour answers with; if that is too short the hunters' packs
   come down to a fight for one and a half.
4. **Whack-a-mole.** Four machines on six lanes is a chore unless the next beat is readable
   and the packs differ. The wave shown a beat ahead at its tears is the answer; it needs a
   mark on the map he would want to judge.
5. **The content it retires.** Thirty-nine formations as grids for three, their questions,
   and the roles that sorted pushers from flankers. Each domain wants five or six fodder packs
   and three or four waves, with forms by Convergence.
6. **The runner.** Its player defends by gathering; it cannot hold lanes or choose what to
   let through, so its reads of this are a floor until it is rewritten.
7. **The first battle's three machines.** Fewer tears, by the ramp's table; his sizing.

## 8. Questions for Ryan

1. The front: does the rift stop sending fodder altogether, the tears across the width
   sending all of it?
2. The wave: a formation as a named set of packs for one machine, its roster set for each
   Convergence. Is that the form, or do you want some fights for three kept?
3. The elite: through a tear beside the machine that tipped the Fracture, its fight opening
   your turn after next, everyone inside its ring in it. The ring's size (the lean: two) and
   the notice (the lean: a turn and a half) are yours; so is whether any elite still walks on
   the wall.
4. The ladder: the leaders' first number is on a dial (LEADERS, a tenth or a fifth more hit
   points a Convergence), for a feel of C3 and C4. Does the tier-one bench come before the
   entries proper are written, since it changes what the ladder must climb?

## 9. Bench: ideas set aside, one line each, for him to overrule

- A fodder fight won in its first round gives the machine its action back, once a turn: the
  stake hole 2 asks for, and it steps on the Dingo's second action.
- A fodder pack answered at twice its rating falls on the map with no fight: the skirmish is
  where the depth lives.
- Tears that close as others open, so the front shifts: the tears row has them stay open.
- The gate's bar a stretch of wall each, a stretch lost for good: one bar is the rule, and
  wall segment upgrades are where stretches come in.
- The elite hunting whatever machine is closest, read again each turn: it can be handed about
  and led, which he refused.
- A leader's numbers by a multiplier a Convergence: his form is the fixed entry.

## 10. If he says go: the order

1. His answers to section 8.
2. The engine, on dials until he has played it: the tide through a front of tears with the
   rift quiet; a wave dealt as its packs with its form by Convergence; the elite's arrival;
   a leader's block by tier and Convergence.
3. The Meadow's fodder and waves in chat, a row a pack and a row a form, then content; then a
   domain at a time. The leaders' blocks as a table for his marks, tier one first.
4. The hull budget's shares cut again with the foes' line, read at the anchor on squads with
   and without finds.
5. Each dial that settles landed and cut from the page; the runner's player rewritten for
   lanes.
