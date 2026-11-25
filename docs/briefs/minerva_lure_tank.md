# Brief: the lure tank, Minerva's tier-one front (new chassis)

<!-- hangar: {"kind": "chassis", "maker": "minerva", "tier": 1, "status": "idea", "slot": true, "name": "the lure tank"} -->

The session designs Ryan's tier-one Minerva tank: a drone that entangles it with one Sprite, the
two able to pick only each other (25 November), beside or in place of his kit of 4 November
(every hit lures, and the blows it draws harden it). It takes the luring half of the echidna's split, and it is one of the tier-one
fronts beside the Polar Bear's move to tier two. "The lure tank" is a working label; the name is
Ryan's.

**Status**: Ryan's ideas of 4 and 25 November, Claude's second round below, on the drone, unanswered. **Maker**: Minerva.
**Proposed tier**: one. **Read first**: `docs/briefs/README.md` (ten a maker, the orbits);
`minerva_hedgehog.md` (the split; retired with the Echidna's model, in git); the bible's Armoured row, retaliation and thorns row and
redirection row (section 5), and section 12's Polar Bear question.

## What Ryan said

- 4 November: "Minerva: tier 1 tank. Every hit lures. Needs a hook on how to stay alive. Maybe
  something like, 'every hit taken grants 1 armoured until end of turn' so it works well at
  soaking multiple hits but still bleeds on the first couple."
- 4 November: "Armadillo moves to T2, and either Boar or Mole will move down."
- 15 October, of the echidna: "we can either play up the spikes, or the luring tank, not both".
- 25 November: "It has a drone. setting the drone on a target entangles them together. Only the
  lure tank can target the entangled target, and the entangled target can only target the lure
  tank. Undecided if area damage can splash in or not." The machine has no concept yet; three
  animals were floated in chat that day (an alligator snapper, a killdeer, an anglerfish).

## Claude's first round (4 November)

**In today's engine.** The passive grants Lure to every weapon the machine fires, the Wild Boar's
shape (a keyword a passive grants). Each blow it takes adds an Armoured stack until the round's
end. The round ends at the end of the enemy's turn, so "until end of turn" reads the same.

It passes the tier-one test: every basic gun lures.

It is the luring tank the echidna's brief split from the spikes, so Ryan's two Minerva ideas take
the two halves. It is also one of the tier-one fronts section 12's Polar Bear question waited on.

**Armour at or over the tier's blows is immunity.** Section 12's Polar Bear question found that flat
armour at or over a tier's blows is immunity at any number, and tier one's rank and file hit for 2
or 3. A tank's base armour of 2, plus a point for each hit it takes, is immune after the first hit
at tier one. So "still bleeds on the first couple" holds only against bigger blows. Claude's lean
in that question is a floor of 1 past armour on a blow that reaches the hull, on both sides. With
that floor the tank reads as Ryan describes at every tier. Without it, the tank's base armour
wants to be 0 or 1, and its passive becomes its armour (the toughness row: a tank is tough
"through its numbers and passive").

**The holes.**

1. **Immunity at tier one** (above). Base armour of 0 or 1, or the floor of 1, makes "bleeds on the
   first couple" true. Against a massive foe's single big blow it gains nothing, so it is a swarm
   tank rather than a wall, which sets it apart from the Polar Bear.
2. **What counts as a hit.** Does a blow that lands on its shield count, or only one that reaches
   its hull? Hull only means it bleeds to harden, and it reuses the engine's hull-damage trigger
   (the Nemesis's). That trigger also reads an overheat and a bite, so it would need to read a
   foe's blow only; otherwise an overheat buys armour. Claude's lean: a foe's blow that reaches its
   hull.
3. **The lure's reach.** One spend a round lures the one foe it hits, or more with an area or a
   sweep. So the choice is which foe to pull: the small hitters, which its ramp eats, rather than
   the big one, which it cannot.
4. **The bot.** The greedy bot values a lure for allies at nothing (the Polar Bear's row), so this
   machine's runner rows wait on that valuation (the to-do's engine line), as do the three other
   lure machines' (the orbits).
5. **Being struck** is the roster's most crowded orbit (the briefs README): this machine reads a
   foe's blow on its hull, as the echidna does, and parts from it by payoff (armour here, delayed
   damage there).

## Claude's second round (25 November)

**The reading.** The drone is an Integrated component, an entry on its die. Set on a Sprite, it
entangles the two, each able to pick only the other: "target" read as the rules read a pick
(Lure: "A move at every machine or at nobody holds no pick"). As a draw on a locked piece,
rolled and on one foe, it passes the redirection row so long as it keeps a price: Guard failed
as a standing draw on everything, and the cover of 9 November as a free cover of the biggest hit.

**What follows from Ryan's words**, consequences rather than questions:

- Its own pack cannot pick it either: an aimed heal (the Enkidu's), Cleanse (the Spectre's) or
  revival (the Lich's) passes it by, while a move on the whole field (the Goblin Captain's
  rally) still reaches it.
- Its own aimed support finds no one; its moves on itself stand, since they pick no machine.
- An ally's Lure cannot turn it, and while the tank is Phased it has no pick at all.
- A blow at every machine holds no pick, so it still lands on every machine, as it beats Lure
  (the threat-shape row).
- On a lone foe the rest of the squad has nothing to pick.

**The holes.**

1. **Area**, Ryan's open point. Claude's lean: nothing of the squad's but the tank's reaches it.
   The price is what passes the redirection row: with area splashing in, a squad of every-foe
   guns, Chain's ping and ticks keeps killing a lone boss that swings only at the tank, which is
   Guard's standing draw on everything for that build.
2. **How it ends.** His words give no end. `tools/lure_duel_model.py` (a brute of 14 HP among
   three adds against a squad of three): a free recall wins as fast as no drone and cuts the
   allies' damage from 10 to 1.3, so it is the free cover again; held until one of the two
   falls, it buys the allies' safety with two rounds and the tank's hull, and a blow of 8
   against hull 20 wrecks the tank; a recall that costs the tank its use sits between. Claude's
   lean: it holds until one of the two falls, or the tank lets go at the price of a use (setting
   the drone again, or a recall).
3. **The 4 November kit.** Whether every hit still lures and each hit taken still grants
   Armoured. The drone takes the lure's place, and the hook to stay alive matters more: the
   tank soaks one foe's every pick for the duel, and its shield, once broken, stays broken.

**What it needs.** The bot to price two things before the runner can read it: the blows the
lock moves off its allies, and the aim the squad gives up. Packs with one big aimed hitter among
adds, which is what the lock is for; a storm, which answers it; and a pack's healers and
Cleansers, which lose their reach on it.

## Open for the session

1. Whether area splashes in.
2. How the lock ends.
3. Whether the 4 November kit stays beside the drone: what counts as a hit, and its base armour
   with the floor of 1 if that lands.
4. Its numbers and stock; the drone is its locked piece.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Minerva row and the Polar Bear's tier move with it,
content planned, and this brief kept until its content lands.
