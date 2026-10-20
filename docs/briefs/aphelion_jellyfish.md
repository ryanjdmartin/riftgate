# Brief: the jellyfish, the Science Vessel homage (proposal reworked into a direction)

The session refines Aphelion's jellyfish into the roster's soft-control specialist and settles
the dispel it carries.

**Status**: direction (14 October); in session since 15 October (Claude's first round, its
review and Ryan's call on the name, below). **Maker**: Aphelion.
**Proposed tier**: two. **Read first**: `docs/briefs/README.md`; the bible's rows on the
dispel and on Numbed (section 5) and on Aphelion's next chassis (section 7).

## Ryan's calls before the go (11 and 12 October)

- 11 October, his brief for Aphelion: "A medium flyer (StarCraft Science vessel homage?)".
- 12 October: "The stingray goes deep on status, this one goes wide." "Could specify 'all
  non-damage effects' to narrow the range and bring the fantasy out of obvious damage carry
  applications." "Otherwise, this sounds great." On area being no maker's alone: "Everything
  wants to boom."
- 12 October: "We will need a dispel effect, I'm not concerned about the keyword count, and
  the EMP is so core to this homage that it seems like a good fit. I'm not worried about
  getting back up, that can be changed if needed."
- 12 October: "It flies, so it should have an aquatic name, and a type of jellyfish works
  beautifully."
- 12 October, for every Aphelion machine: "Aphelion doesn't use rotors as a general rule. They
  use thrusters, sci-fi space-age rockets." And: "the exposed rotor helicopter might go to
  W&S."

## What the go said

- Ryan, 14 October: "science vessel changed to our soft-control specialist?"
- Claude, 14 October: agreed. Its spread would carry Lure, Disrupt and the dispel to the foes
  beside the target, and nothing else. Its EMP then reads as dispel plus Disrupt rather than
  Shock, which is what an EMP does to a plan, and it is never blank, since every foe has a move
  to lose. The two Aphelion tier twos split cleanly: the Baboon counts statuses, the jellyfish
  changes what the enemy does. It also keeps hard control out of the spread: with Suppress in
  it the spread would triple a stun beside the Paradox in the same house.
- Ryan, 14 October: "neat, good direction, needs refinement".

## The design as proposed (11 to 13 October)

From the Aphelion chat, written up on 13 October for the batch evaluation. The bible's
Aphelion row records Ryan's call of 13 October: that session went off the rails, and its
proposal is "a list of ideas, not a design to defend". Everything here is Claude's unless
marked Ryan's, and the numbers are the proposal's placeholders.

- **The frame**: tier two, a medium flyer (Ryan's), move 30. Locked: the EMP (round two),
  Indirect, no damage, carrying the dispel. The homage is StarCraft's Science Vessel, whose
  abilities are Irradiate, Defensive Matrix and the EMP Shockwave.
- **The look**: Ryan's propulsion call retired the round-one look, a pearl dome under one
  great exposed rotor ring with antennae trailing; round two answered with a pearl bell ringed
  with thruster nozzles that fire in pulses, sensor tendrils trailing.
- **The spread** reaches foes only: machines have no neighbours, and an effect on every ally
  would be a different, much bigger rule. Engine: new; no effect today carries a spend's riders
  to the foes beside its target without its damage (Spread, id `cleave`, carries the blow).
- **The dispel**, decided by Ryan (12 October), its shape open:
  - What it strips, as proposed: a foe's own buffs, today Braced (from a brace; Folded until
    16 October), Kindled (Rally) and Getting Back Up (Reraise); later Protect's Braced (a
    planned foe move, a brace on every foe) and Shell (open for the foes' fresh start, bible
    section 12).
  - In round one Claude had weighed an EMP and dropped it, as a new keyword and because
    stripping Getting Back Up is a hard counter to the Marsh; Ryan overruled both (above), and
    the bible's dispel row keeps Getting Back Up in its reach until play says otherwise.
  - Its name: "Dispel" is Final Fantasy's own word, and the bible gives foe moves the genre's
    names while "the engine's words and the player's components keep ours"; Strip, or Purge
    (which pairs with Cleanse), were offered. Ryan's word was "dispel".
  - A keyword, Ryan's call; it would start on one carrier, a rare keyword in the way the bible
    lets Overshield stand.

The bench, the forms set aside:

- Spread on every weapon, damage included (round one; it runs today as `grant_keyword` with
  `cleave`): set aside by Ryan's narrowing to non-damage effects (12 October).
- Every effect its weapons put on a foe also lands on the foes beside it, never its damage
  (round two, Ryan's narrowing made exact), so the neighbours would take the target's Burning
  stacks, its Suppress against their own Numbed, and a Paradox each: set aside in the go for
  Lure, Disrupt and the dispel alone, since Suppress in it would triple a stun beside the
  Paradox (Ryan, 14 October: "neat, good direction, needs refinement").
- Shock on the EMP, so it is never blank against a pack with no buffs (round two): set aside
  in the go for Disrupt, never blank since every foe has a move to lose.

## The Aphelion session, first round (15 to 20 October)

Opened by Ryan on 15 October with the line frame, the Baboon and the Carrier (its record is in
`aphelion_line_frame.md`): Claude's proposal in chat that day, Claude's review of it on 16
October at Ryan's ask, written down on 20 October. Ryan's call on the name came the same day
(below); everything else here is Claude's, for him to move.

**The proposal, as the review left it**

- **The spread**: whatever its weapons land on a foe that leaves no chip also lands on the
  foes beside it: Lure, Disrupt and Purge, never damage and never a debuff. On 15 October
  this was put as "what its weapons do to a foe's plan", which the review found wrong as worded
  (Suppress changes a plan too). The honest line, checked in the engine: Lure and Disrupt leave
  no chip (`sim/skirmish.gd`, `_lure`: "No status and no chip: the arrow changing is the
  record") and Purge takes chips away. So the jellyfish never feeds the Paradox, and the
  two Aphelion tier twos sit side by side without multiplying: hard control stays out of the
  spread by its category, not by a carve-out.
- **The EMP** carries Purge and Disrupt: Purge, the dispel, is the homage, and is blank against
  a pack with no buffs; Disrupt means it always does something, since every foe has a move to
  lose.
- **A spread Lure stays**: the EMP carries none, it comes only from a piece the player fits,
  and three foes turning on a fragile flyer is a price the player chooses; the runner counts how
  often it dies to its own lure.
- **The name: Purge, on both sides** (Ryan, 20 October: "Use Purge for both, for now"). Ours
  strips a foe's buffs, the foes' a machine's (their keyword was Dispel from 17 October to 20
  October), one word for one effect on either body as Burning is. Strip was set aside, since it
  collides with the hangar's verb (stripping a component); Claude had leaned to Purge for ours
  alone on 15 October ("Cleanse ours, Purge theirs"). The hole to read in play: Purge and
  Cleanse are near-synonyms in plain English, though Purge is the genre's word for stripping a
  foe's buffs; the codex carries which is which.
- **The reach**: the foes' own buffs, never Numbed; the EMP its only carrier at first.

**What the review added** (16 October)

- **Purge and Guarded.** A core in parts wears Guarded (built 15 October), a buff on a foe in
  the vocabulary's table, so a Purge worded "strips a foe's buffs" would strip a boss core
  bare and undo the boss in parts. Its reach must be named (Armoured from a brace, Kindled,
  Getting Back Up), Guarded out unless Ryan wants the EMP to be the answer to a boss in parts.
- **Disrupt waits on the fresh start less than this brief said.** It already breaks off a
  countdown (built 15 October: the Lancer's Jump, the bosses' gathers), and a boss or a hero
  carries three moves; only the one-move rank and file reduce it to a new target.

**Since then, on main** (to 20 October)

- Silence and Purge on the enemy's side (section 5, Ryan, 17 and 18 October): the foes' Purge
  (decided as Dispel, renamed with ours on 20 October) is a hero's or a boss's keyword that
  strips every buff on a machine, a Ward turning it away; the vocabulary's entry keeps the id
  `dispel`.
- Numbed is a buff nothing removes (18 October), so it is out of the reach by its own line; the
  foes' brace leaves Armoured (the bible's word since 18 October; Braced in the rules and the
  engine until that branch lands).
- The time-shifter (Ryan, 17 October; the briefs README's bench) parts from the jellyfish by
  pattern: it moves the blow in time and target, where this one changes the move and purges.
- A lure to read beside the spread Lure: the Whip Scorpion's Siphon, a lure-all that heats its
  spender (landed 20 October). The helicarrier's dock lost its lure the same day (Ryan: Phased
  allies cannot be targeted, so the intents move by themselves; `ws_multirotor.md`).

## Open for the session (the refinement)

1. The spread's category: what leaves no chip (Lure, Disrupt, Purge), never damage or a
   debuff.
2. The EMP's verbs: Purge and Disrupt both (proposed), or one.
3. A spread Lure turning three foes onto a medium flyer: kept as a decision (proposed), or too
   much.
4. Purge's reach named (Armoured from a brace, Kindled, Getting Back Up; Numbed out; Guarded
   out, or in by Ryan's choice), and its carriers; its name is Purge on both sides for now
   (Ryan, 20 October).
5. Its stock and its designation.

## Waits on

The foes' fresh start, for the rank and file with one move (Disrupt is only a new target
there); countdowns and three-move bosses already give it work.

## What the session hands back

A proposal in chat; on Ryan's go, Purge into the vocabulary as our keyword beside the foes', the
bible's rows, content planned, and this brief retired.
