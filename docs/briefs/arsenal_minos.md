# Brief: Minos, the ranks turned (proposal)

<!-- hangar: {"kind": "chassis", "maker": "arsenal", "tier": 3, "status": "proposal", "slot": true, "name": "Minos"} -->

**Ryan's direction (6 November)**: The movement is a cool idea, but I don't know what a build on it
would look like, and that's the issue. It needs something else, or the lammergeier takes over its
movement role since ita mining niche needs altering.

The session finishes Minos, whose every foe reached changes rank, as written or adjusted, and
settles when it is worth its slot.

**Status**: proposal with a place, as proposed (the analysis, 14 October); in session since 15
October (Claude's first round and its review, below; Ryan has answered none of it). **Maker**:
the Arsenal. **Proposed tier**: three. **Read first**: `docs/briefs/README.md`; "The design as
proposed" below, with Ryan's calls; `docs/roster_analysis.md` section 4; `docs/rules.md` on the
formation and reach.

## The design (the proposal, with Ryan's calls of 12 October)

Passive, the Catherine Wheel: every foe its weapons reach and leave standing changes rank in
its column, trading places with whoever stands there. Not optional; one turn a spend; everyone
hit moves; hover; nothing against a massive foe, which is fine; extraordinarily strong against
formations (Ryan). Locked: the Gibbet Hook, a small Direct whip.

## The analysis (14 October)

A place, and the best fit of any proposal by the brief's third rule: the only positioning verb
on the player's side, changing the enemy's problem without removing a turn. Spread turns three
columns, Penetrate trades one, Indirect brings the back forward; the payoff is every Direct gun
on the team. It adds a decision to every round it is in, so the habit that answers it is
spending Minos first or last.

## The design as proposed (12 and 13 October)

Claude's proposal for Ryan to move, except where marked as his; names are working names and
numbers the proposal's placeholders.

**Ryan, 12 October**, as the proposal recorded his notes. First: Minos, a step further: hitting
any unit flips its rank. Not optional; powerful, and the whole team has to work around it. A
backpack with short wings, digitigrade legs, a corrupted Aile Strike Gundam or Evangelion
frame. Second: hover movement, one flip per spend, everyone hit moves in its column. It is bad
against massive foes, which is fine, and extraordinarily powerful against formations. Two
Gundams are fine, since this is the stereotypical dark one and not the hero frame.

**The chassis**: Arsenal Instrument XIII (eldritch: the ranks turned), tier three, medium,
hover. Hull 90, shield 40, armour 0, move 30, heat maximum 80, cooling 5, field 25, two
modules; a die of five, one locked entry and four hardpoints. The name: Minos as Dante drew him
at the mouth of the second circle, the judge who sends each soul to its place by coiling his
tail. It answered the Marsh, and every formation.

**The passive**, the Catherine Wheel: *every foe its weapons reach and leave standing changes
rank in its column, trading places with whoever stands there.*

- When: once a spend, after the spend resolves (every strike, every Chain link, Spillover, and
  any Lure or Disrupt on the entry), however many strikes reached a foe.
- Who: every foe the spend reached and left standing, Spillover's foe behind included. Each
  trades places with the other foe in its column, or steps into the slot if it stands alone
  (the dead are cleared first, so a kill's hole takes it).
- Spread turns three columns. Penetrate reaches both foes of one column, which trade places
  once, not twice.
- A massive foe fills its column and never moves, so Minos does nothing to one.
- Intents and targets go with the foes: each keeps the move and the target it drew.
- Weapons only: Minos's shields and vents move nothing.
- The ranks hold for everyone else. Nothing walks a moved foe back, and reinforcements fill
  empty slots by their own rank as now, so a foe moved out of its rank stays there.
- Foes strike from either rank, so the turn changes not who can hit the team but whom the team
  can reach (Direct reaches the front, and the back only through a hole), the enemy's order
  (the front acts first), where an Indirect spend splashes (fired at the front rank), where
  Spillover carries, and anything that reads a foe's rank.
- It breaks "the ranks hold" for one machine, which is the point of a passive.

**Locked piece**: the Gibbet Hook (attack, Direct, flat 10, heat 5, Melee), a chain whip
coiled on its right forearm. Its own number is small: the turn is the point.

**Stock**, four hardpoints: the Suppression Battery, the Shotfire Rack, the Plasma Arquebus,
the Entropy Condenser.

**What the team works around.** Minos's turn is the round's hinge. Spent first, it brings the
healer, the caster or the Drake into the front rank, in reach of every Direct gun on the team.
Spent late, it sends a wounded front-liner behind its fellows, out of the team's Direct reach,
and brings the one behind forward. A Penetrate or a Spillover through a kill brings the foe
behind into the empty front at once, and the enemy's order changes with every turn.

**The look**, on Ryan's calls (Claude's detail): tall, thin and long-limbed; digitigrade legs
on hoverjets; an Aile-style pack with two short swept wings and twin thrusters; the V-fin
crest grown into horns, twin eyes in red glass, one wing notched shorter, seams lit red like
cracks. Mounts: hp_1 and hp_2 pods beside the thrusters, hp_3 the left forearm, hp_4 the right
hip. Acts: a predator at rest (flares the pack, crouches and rises on its digitigrade legs,
uncoils the whip, turns its horned head and holds); it hovers, balancing like a platform on
water. Its model is a new lowforge kind: digitigrade legs on hoverjets under a winged pack.

A first look test of it, 15 November, on Ryan's ask of that day for the chassis with a
direction ("let's see what you come up with for all of these. Doesn't have to be too detailed
since none are finalized"): `docs/looks/arsenal_minos.png`, built by
`tools/lowforge/looks/minos_looks.py`, never content until the chassis lands. The figure as
above, 126 tall with its horns and 77 across the wings, taller than the Nemesis: hunched
forward over a bare red-lit spine, a keeled chest with three lit ribs a side, shoulder blades
swept back, a low wedge head with two slit eyes, the winged pack with twin thrusters blowing
down and back, and digitigrade legs that hang and trail, a hoverjet at each hock. A homage in
its cues alone, no one suit's or unit's head, chest or colours. Claude's choices, his to
change: an uneven stance, its left arm raised and its right hanging to the shin; the corruption
as the left wing broken short and uneven horns, the right longer with a second tine; the locked
piece a plain drum on the right forearm, since its kit is in question; hp_1 and hp_2 as racks
on the wing roots over the shoulders, where the proposal had them beside the thrusters, hp_3 a
barrel along the left forearm and hp_4 a twin barrel on the right hip. A second row adds a
segmented tail coiling under its feet to a hook, the judge's tail of its name, which nobody
asked for: his to strike or keep. His to judge besides: the codex angle is busy, dark on dark;
from above it reads as wings, racks, horns and trailing legs.

**Engine and tests**, as proposed: medium. A turn of the ranks after `_resolve_attack`,
collected across the Chain's recursive calls (its list of foes touched is local today); the
swap of `front` and `back` in a column and each foe's `rank`; the forecast and the drawing on
the skirmish screen; the greedy bot learning the round's order; the save already keeps
positions. Tests: two foes trade; a lone foe steps into the empty slot; a massive foe holds;
Spread turns three columns; Penetrate trades once; a Chain turns every link's survivors once;
the dead never move; intents are kept; the next enemy turn runs in the new order; Direct's
reach follows.

**What the runner should read**: the four formation cells, and team rows. Minos alone is a
diagnostic.

## The bench, with what set each aside

- **The Penance Windlass and the hanged saint**: Minos's first passive (its indirect blows
  dragged a back-rank foe forward) and its first look (a robed figure hanging over its
  hoverjets with a ring of eyes). Ryan took the turn further (12 October: hitting any unit
  flips its rank), and the dark Gundam replaced the saint. Penance is now Misharu's word.

## The Arsenal session (15 and 16 October)

Nothing here is Ryan's yet. Claude's first round went to chat on 15 October and Claude's review
of it on 16 October (Ryan's ask: errors in logic, biases, wrong assumptions, gaps in design).
He has answered none of it.

**Claude's first round (15 October)**: keep it as written; decide the design now (its row, the
passive planned in content) and build it after the foes' fresh start, since only formations
have a back rank today. Nothing in the go or the shield rule changed it. The round added that
every boss is massive, so Minos never touches one and its job is formations and a boss's adds.

**Claude's review (16 October)**: that line was wrong when the round wrote it. Since the tiers
row (Ryan, 15 October; the engine reads a boss whatever its size since that day) a boss may be
human-sized, and the four massive bosses step down to elites as the slate lands, so Minos may
turn a boss's rank, and a core's beside its parts (a boss in parts, built 15 October): ground
Ryan has not ruled on. Unexamined with it: a turn that moves a part and its core in one column.

**Since then on main (to 20 October)**:

- The Dingo's Combat Translocator (Ryan's go, 19 October): any two foes, or a foe and an empty
  slot, trade places, a massive foe staying. The bible's Dingo row parts it from Minos by
  pattern (Minos turns whole ranks over, the Dingo chooses two), and the engine piece that
  moves a foe between slots is the one Minos's turn waits on too (the to-do's Translocator
  line). Soft control has a tier-two carrier before Minos lands.
- The bomber (Kestrel, tier three) leaves mines on empty slots, and Ryan, 15 October: "If Minos
  or any other move effect causes an enemy to step on a mine, it blows up. That's a synergy." A
  Minos spend on a lone foe steps it into the empty slot of its column. Since 9 November the
  Lammergeier's Mines ride the foes it hits and blow round their slots when they fall (the bible's
  Lammergeier row), so its rework took no movement from Minos (Ryan's direction above): a foe
  Minos turns carries its Mine with it, and where it stands when it falls is where it blows.
- Indirect's splash is retired (decided, not built: area belongs to the keywords), so the edge
  on where an Indirect spend splashes goes when that lands; Chain's rework, open in section 12,
  would change the edge that a Chain turns every link's survivors once.

## Open for the session

The first round's answer is above; Ryan has given none.

1. The proposal's questions (the design above): as written, and whether it waits for the
   foes' formations to be worth its slot (the round: as written, decided now, built after).
2. A human-sized boss: whether Minos turns it as it turns any foe (the rule as written does),
   and a boss in parts.
3. Its look: his read of the first look test (15 November), the tail with it, or another round.

## Holes already raised

- Only formations have a back rank today, so outside them Minos mostly shuffles the enemy's
  order (a lone foe stepping back leaves the column's back reachable through the hole anyway);
  its worth waits on the foes' fresh start.
- The forecast must show who will move while the die is dragged, and the screen must draw the
  turn.
- The bot must weigh the state after the turn, or the runner cannot read Minos at all.

## Waits on

The foes' fresh start (back ranks in more fights).

## What the session hands back

A proposal in chat; on Ryan's go, the bible's row, content planned, and this brief retired.
