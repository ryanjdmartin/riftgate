# The tide's shape: fodder by count, the fights that matter by the hunt

A proposal, from Ryan's play of the field's dials (23 November). Nothing in sections 3 to 7 is
in content or the engine: it is the direction reasoned as a system, with its holes and the
questions only he can answer. What was built that day is section 2. The formation pass (the
to-do's design sessions) runs from here once he marks it.

## 1. What Ryan said (23 November)

- "The biggest hurdle to overcome, and the most thematic, is quantity. I feel like I would
  rather more packs on the map, and a much wider variety of them with different strengths and
  weaknesses, so that I can choose where to attack and what to let through, instead of just
  hovering by a spawn point and fighting whatever pops out."
- "In general, it feels to me like the game would be more fun if fodder were the primary,
  significant, threat to the wall, but easy to defeat without any hull lost by a decent player,
  and we push all the 'interesting' fights into Hunters, Elites, and Bosses. I'd make almost
  all Elites into Hunters, but hunters of whatever is closest and with a large engage range,
  so we bring back engage range for elites and nothing else. Fodder should pose a threat by
  quantity, not by hard hits."
- "I think 12, 14, and 16 unit field depths all have their merit. The trick with the deeper
  maps is that I found myself spawn camping the rift. There needs to be enough pressure
  elsewhere to make me need to leave the center lane, and that applies to all map sizes."
- "Having starting tears at the top and bottom might make sense, or else sending multiple
  packs out of the rift at once, each headed a different direction."
- "I feel like packs walk too slow, even for a 12 deep map. I'd rather they don't start so
  close but reach the wall faster. Each pack becomes more threatening that way. I'd probably
  give everything +1 right now and see what that does."
- "I would be curious to see how it felt if the packs spawned, then the movement phase
  happens, so packs move the instant they spawn. I think it might feel better overall, since I
  wouldn't be playing so far up."

## 2. Built that day

In the game: the zoom out to the whole field; the seam a circle about the rift, a picture
alone; the round shown under the whole field; a pusher's segment the stretch of wall it reaches
soonest; four tier-one stock dice back to basics (`docs/rules.md`, The battlefield; the bible's
wall, tears and seam rows).

On trial, a debug build's SETTINGS, TRIALS, each read as the next battle starts and none of
them the game's until he says:

| Dial | Its choices | His words it answers |
|---|---|---|
| PACE | BUILT, +1, +2 on every pack's move | "I'd probably give everything +1 right now" |
| SPAWNS | STAND, RIFT WALKS, ALL WALK | "if the packs spawned, then the movement phase happens" |
| RIFT SENDS | ×1, ×2, ×3 a peak, each to its own stretch of wall | "multiple packs out of the rift at once, each headed a different direction" |
| FLANK TEARS | NONE, TWO from the first turn, one at each end of the wall | "starting tears at the top and bottom" |
| FORMATIONS | BUILT, PICKETS ×2, PICKETS ×3 | "Fodder should pose a threat by quantity, not by hard hits" |

FORMATIONS is the direction on today's units, before any content: every formation comes as
three packs rated one, each two or three of its domain's commonest front-liner (his picket of
19 November). The pips are the formation's, so the Rupture asks the same. Beside the dials he
already had (FIELD DEPTH, OPENING, TIDE, STRIKE, RUPTURE), a first set to play: FIELD DEPTH
14, OPENING +1, PACE +1, TIDE ×1.5, FLANK TEARS TWO, SPAWNS RIFT WALKS, FORMATIONS PICKETS ×2.

## 3. The system, as reasoned

**Three things are threatened, and the direction gives each its own enemy.** The wall is
threatened by count: every pack at the wall strikes for its rating each turn, so what the wall
loses is packs times the turns they stand there. The squad's hull is threatened by the fights
that come to it: a hunter's catch, an elite, the boss. The clock is the tide itself, which
opens more mouths the longer the battle runs.

**The loop it makes.** A machine has one action a turn, and a pack takes as many machines as
its rating. So four machines answer four pips a turn at most, less what they cannot reach. To
answer many small packs along a wall of twenty the squad must spread, one machine a pack; to
survive a hunter or an elite it must gather. The choice he asks for ("where to attack and
what to let through") is that tension, and it exists only while the tide asks for more than
the squad can reach. Today it does not: the tide of a tier-one battle is about a pip and a
half a turn against four actions, which is why chasing every pack felt possible, and why
standing by the mouth was enough.

**What the coverage model reads** (`tools/tide_model.py`, 400 battles a row; four machines of
move 3 to 6 that see everything and fight for free, so every cell is the tide at its kindest;
`docs/measurements.md`, 23 November). Read each row against its neighbours:

| The tide, twelve turns | Packs sent | Packs that struck | Gate lost | Actions spent fighting |
|---|---|---|---|---|
| As built | 13 | 11% | 15 | 40% |
| Twice the packs, as built | 26 | 24% | 275 | 67% |
| As built, every formation as three packs rated one | 19 | 10% | 34 | 40% |
| Twice the packs, formations as packs rated one | 38 | 15% | 96 | 74% |
| Three times, formations as packs rated one | 57 | 50% | 487 | 94% |

- As built the squad is idle more than half its actions. That is the camping.
- Count alone does not make the choice: twice the tide with formations still fights for three
  loses the wall outright (275 of 200), because two formations on two stretches cannot both
  be met by three machines. The same pips as packs for one machine leave the wall 96 down and
  the squad busy three actions in four. So "more packs" and "fodder a machine can answer
  alone" are one decision, not two.
- The band where there is something to let through is narrow: about twice today's pips is a
  squad at work, three times is a rout. A real squad, whose fights cost turns and hull, sits
  lower: TIDE ×1.5 is where to start.
- Pace: a hex more on every pack changes almost nothing while the opening stands a move
  farther out (65 against 67 lost at twelve deep). Two more is a cliff at twelve deep (283)
  and a slope at fourteen (129), where packs outrun the slower machines. So +1 is safe at any
  depth, and +2 wants the deeper field.
- Mouths: two flank tears or the rift sending two each add about eight packs and take the
  squad from 40% to 55% busy; both together to 69%. They are the same lever as TIDE, aimed
  off the centre lane.
- The order: sending the tide before the walk is the largest single lever in the model. Every
  pack lands a turn nearer its strike and is seen a turn later. With every mouth walking at
  once the wall loses about four times as much (324 against 85); with the rift's packs alone
  about twice (183). Nearly all of the difference is the tears, which open near the wall: a
  patrol that walks as it lands strikes before any turn to answer it. Hence the dial's middle
  choice.

## 4. What it would ask of content

A shape for his marks, never a slate: the slate is a session of its own, a domain at a time,
proposed in chat first.

**Fodder.** Packs rated one, a few rated two, small enough that one machine answers one alone
and short enough to play in two or three rounds. A pack's identity is two things: how it
threatens the wall (its pace, its rating, whether it flies, which mouth sends it) and what die
answers it (a line any gun shoots, a screen with something behind it, a swarm, one tough
body, plate). The variety he asks for is those two crossed, so which machine goes where is a
matchup and not only a distance.

**The hull budget** (the bible's scale row) would be cut again: fodder near nothing at its
rating for a player who sequences well, the tenth and the quarter kept for the hunter and the
elite, the boss what is left. Today's rank and file is sized to bite: three of a domain's
front-liner on one machine read 4% to 17% of a four's hull, two read 0% to 5% (19 November).
So "no hull lost by a decent player" is pairs of today's units, or a lighter unit under them.

**Elites that hunt the closest, with a ring.** As he said it: almost every elite hunts, its
prey whatever machine is nearest, read again each turn, and it catches from a ring of several
hexes where a hunter catches from beside its prey. Three things his words leave open are
section 6's questions 3 to 5.

**The formations.** A fight for three is the one piece the direction does not place: section 6,
question 1.

## 5. Holes, each with what would settle it

1. **The battle's length.** The squad's actions bound the fights, not the packs: more packs
   are more let through, never more fought. But the direction wants the squad busy three
   actions in four where it is busy two in five, so a battle holds nearly twice the fights.
   A machine spends one die a round, so alone it lands one blow a round, and a standard foe
   of 4 takes a basic gun of 3 two: a pair of goblins is four rounds for one machine. Unless a
   fodder fight is two rounds, his ten to thirty minutes go. Settles it: his play of FORMATIONS
   on PICKETS ×2, timed.
2. **A fight with nothing at stake.** Shield and heat are whole as every fight opens, so a
   fodder fight a decent player wins clean costs nothing but its action. Then playing it out
   is a chore unless the fight itself is a puzzle worth a minute. Settles it: the same play.
   On the bench: a pack answered at twice its rating falls on the map with no fight.
3. **Spread is what a hunter eats.** A squad covering the wall one machine a pack meets every
   catch alone, and a hunting pack is rated two. The budget's tenth is read at its rating;
   alone it is far worse. That is the wrench working, or a wreck every battle: his play says
   which, and the hunter's numbers follow.
4. **An elite that hunts never strikes the wall.** Today an elite left alone costs the gate
   forty a turn. If it hunts the closest it can be led about by a fast machine for as long as
   that machine gives its actions to it. That is a cost, and may be the fun of it; it also
   means the elite's whole threat is the catch. Settles it: his answer to question 4.
5. **The tide sent before the walk costs the turn to answer.** Section 3. The dial's middle
   choice keeps it for the rift alone.
6. **The rift's packs fan at every Convergence now.** A consequence of the segment rule as he
   stated it: the ramp's spread, which held them to the gate's five columns early, is gone. If
   a first battle wants the body nearer the gate, the spread comes back as a ceiling.
7. **The purse grows with the count.** Salvage and the Rupture meter pay by rating, so the
   same pips in more packs pay the same; a denser tide pays more. The economy pass's.
8. **The runner cannot read it.** Its player declines no fight and chooses nothing to let
   through, so the battle runner's reads of a dense tide are a floor, as they are today.

## 6. Questions for Ryan

1. Does a formation stay a fight for three, a few a battle, or does the body break up into
   packs for one and two? The model says the count only becomes a choice once most packs are
   for one machine.
2. Fodder from today's units in pairs, or a lighter unit a domain under them (a hit point
   count a basic gun ends in one shot)?
3. An elite's ring: who is in its fight? The lean: the nearest machine must fight, and every
   other machine inside the ring may join, so the ring is the elite's reach and the squad's
   rally at once.
4. Does an elite with no machine to reach walk on the wall, or wait? And is leading it about
   with a fast machine play you want?
5. The ring's size (the lean: three), and which elites keep pushing (a table for your marks
   once the rule is yours).
6. PACE: is +1 the game's now, in content, or does it stay a dial until the fodder is written?

## 7. Bench: ideas set aside, one line each, for him to overrule

- A fodder pack answered at twice its rating falls on the map with no fight: the skirmish is
  where the depth lives (the bible's first row of section 1); his to want.
- A pack that walks as it lands strikes nothing on its first turn at the wall: an exception
  to the strike's one rule, where the dial's middle choice needs none.
- The seam as the place tears open, drawn as rings: his word that the seam is visual only.
- Hunters re-reading the nearest machine each turn like the elites: his "one a machine" and
  the lock's declaration (the hunters row).
- A formation that splits into its pickets as it is first fought: one pack is one fight.

## 8. If he says go: the order

1. His play of the dials, and his answers to section 6.
2. The elites' rule in the engine (the closest, the ring, who joins), with the ring drawn,
   on a trial dial until he has played it; the table of which elites hunt, for his marks.
3. The Meadow's fodder slate in chat, a row a pack, then content; then a domain at a time.
4. The hull budget's shares cut again with the foes' line, and the reads at the anchor.
5. The dials that settled landed in content or the engine, each cut from the page.
