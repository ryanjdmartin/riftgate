# Brief: Minos, the ranks turned (proposal)

The session finishes Minos, whose every foe reached changes rank, as written or adjusted, and
settles when it is worth its slot.

**Status**: proposal with a place, as proposed (the analysis, 14 October). **Maker**: the
Arsenal. **Proposed tier**: three. **Read first**: `docs/briefs/README.md`; "The design as
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

## Open for the session

1. The proposal's questions (the design above): as written, and whether it waits for the
   foes' formations to be worth its slot.

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
