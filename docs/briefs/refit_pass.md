# The refit pass: the brief

<!-- hangar: {"kind": "rule", "maker": null, "tier": null, "status": "direction", "slot": false, "name": "the refit pass"} -->

The battle's resource model remade from Ryan's play of Phase 2 and the formation pass's reads, 9
November: shields and vents leave the die, a component is a weapon or equipment, the shield is
innate and regenerates, cooling is passive, the hold is the heat decision, component destruction
is off, and the formation pass folds in, its grids re-cut under the new model. The direction is
his and set; the numbers, the reads and the content are this pass's work, and nothing is built
before the reads say where the numbers sit and he has played them. Read `docs/briefs/README.md`'s
How a session runs first; the formation pass's proposal (`docs/formation_proposal.md`) and its
reads (`docs/measurements.md`, 9 November) are the records this stands on.

## 1. Where it stands

- Ryan played Phase 2 on the phone (9 November; the status holds the play in his words): every
  fight survival, the tank needed rather than wanted, Floraison impossible, the Armadillo too
  strong for tier one, the locked pieces chased, the Lance and the Skua's sweep wanted every
  round whatever their heat.
- The formation pass's reads (`docs/measurements.md`, 9 November): fodder formations free for
  three at eight foes, the massives walls for four stock lights, a stall against the grave field,
  the hunters that read as twos and as ones, the campaign a wall for the plain bot either way.
- The root cause, as the chat reached it: every point of hull is permanent across eight to ten
  fights and may cost a component, so the only sane play is zero damage; zero damage needs an
  unrolled defence; only the tank has one, its armour and its lure; and offence cannot buy safety
  fast enough because packs are big and basics do not kill. Ryan: "The balance between WANTING a
  tank and NEEDING a tank is pushed all the way to NEED, so there's no interesting choice. Tank
  lures, or damage dealers do nothing." "In our game, I'm ALWAYS feeling 'how do I block
  everything' and if I deal damage, it's a bonus, not a goal." "I think we're so worried about
  preventing stall that we're actually taking away tools that reward aggression."

## 2. Ryan's calls, 9 November, in his words

- **Component destruction off**: "I'm fine disabling component destruction entirely to test these
  points. It was placed to offer a balancing lever between tanks and dps, an issue that clearly
  no longer exists." The in-fight break of the entry showing stays, a tactical cost and no loss
  (Claude's reading of "destruction"; his to correct).
- **Two rerolls stay**: "Third reroll could be ok, but it's still not stable, and encourages the
  chase more, which is why I wanted to try at 2. I did notice in my play that I was more likely
  to take an ok roll when I had 2, than when I had 3, so I think that is doing its job … With 2,
  it was less boring, but more unfair."
- **The shield**: of three shapes he laid out (no innate shield and faces that grant it; an innate
  shield with regen and no shield faces, Armoured, Barrier and Ward the defensive tools; an innate
  shield with faces that overshield and drop at the round's end), "I like the second option for
  the same reasons as you do."
- **Heat the same way**: "If Shield is a side we're getting rid of... why is Vent still a thing";
  then, of the principle that no pure recovery face stays on the die: "yes, this direction excites
  me. Less component types - weapons and equipment. It's simple, elegant, streamlined. Each
  component is interesting, each round is interesting, and if you greed on heat, well you can
  always pass, which literally how a Mech game works - run hot, and you're forced to wait and
  think about your decisions while you cool off. A deliberate trigger finger, threading weapons
  and equipment, is far more engaging than what we have. I think it's worth the effort."
- **The commander layer**: "The shield and vent faces are perfect commander actions, giving the
  immediate emergency effect of a coolant dump or shield boost. It works."
- **The bombs never hunt** (the formation pass's first question): a hunter's threat is a sequence
  a lone support can play against, never a burst that decides the fight.
- **The refit's direction, before the model was reached**: "Enemy HP is probably too high, or
  player damage is too low. I'd rather lower enemy HP slightly, and boost synergy pieces to
  increase damage instead of just raw numbers. However, I want to judge the new formations
  before applying the refit based on this." The model came first in the chat; the numbers follow
  it, by band: the bosses and the massives first, where his play broke, the fodder's blows second.

## 3. The model

1. **The shield is innate and regenerates.** Every chassis keeps its shield gauge, full as a fight
   opens, and regains `shield_regen` at the start of every round (the slot is built, zero
   everywhere: `content/chassis.json`, `sim/content_db.gd`). The regen is a content number by
   chassis, by role and by maker (Kestrel's shields, Minerva's armour), a placeholder read by the
   runner before it is set; the dial runs from a point a round to a full reset, where the shield
   is simply full as every round opens.
2. **No pure recovery face on the die.** A component is a weapon or equipment. Shield faces and
   vent faces leave the die: recovery is passive, the regen for the shield and cooling for the
   heat, and every face acts on the fight. A vent that converts heat into something is
   equipment, a payoff, and stays; a vent that only sheds heat goes.
3. **Heat is a pace.** Hot faces cost it, cooling pays it back each round, the overheat is the
   wall, and the active decision is the hold: fire the cold face, keep the hot one for the round
   that needs it, or pass and cool. The prices and the cooling numbers are where heat is felt,
   so the heat session's question (the prices on every face, the basics included) folds into
   this pass; passive cooling is the recovery, not the lever to cut.
4. **The defensive tools on the die are targeted statuses.** Armoured against many small blows,
   Barrier against one big one, Ward against the riders; the lure stays the tank's control. The
   basic kit gains a Barrier basic and an Armoured basic at tier zero in the Canopy's and the
   Halo's places, so a stock die carries an answer to the telegraph.
5. **Component destruction off.** A destroyed hardpoint component is rebuilt after a battle as a
   fixed one is; the injury's in-fight break of the entry showing stays. The injury row's
   purpose (asymmetric balancing between tank and glass cannon) is served by the model instead.
6. **Two rerolls.** Unchanged.
7. **Hull stays permanent across a battle.** The budget is spent on hunters, elites and bosses:
   a pusher's or a flanker's fight costs time and heat and little hull when played well, a
   hunter's, an elite's or a boss's may be survival (Ryan: danger "should be reserved for Hunter,
   Elite and Boss packs, not pushers and flankers"). The pushers are measured by hull lost at
   their rating, not by win bands (the formation proposal's section 5 read them by the elite's
   yardstick, which was the wrong one).
8. **The cover withdrawn.** An unrolled interpose for the tank was offered in chat and withdrawn:
   the redirection row stands (Guard was built and taken out because a standing draw made one
   machine the target of everything; an interpose returns only as a conditional draw on a locked
   piece). A free per-round cover of the biggest hit is the same lock in a milder form, and under
   this model the regen answers the chip, the Barrier and the lure the big hit, so it is not
   needed.
9. **The guard against the infinite fight.** Regen and no shield faces make a fight neither side
   can end likelier, so the long wall's principle becomes a validator check: every formation
   carries a rising threat (a rally that stacks, a countdown, a prime, a summon, a blow that
   grows). The Marsh's giants carry none today and are the first defect.

## 4. What the formation pass hands in

The proposal stands as the grids' first cut (`docs/formation_proposal.md`; its grids as code in
`tools/formation_proposal.py`, which writes them to a scratch worktree for the reads). Under the
model it is re-read and re-cut: the pushers smaller where a kill should buy safety (five or six
foes at tier one rather than eight), measured by hull lost at three under the regen; the hunters,
elites and bosses keep survival; the twelve prunings stand until the re-read says otherwise; the
hunters that read as ones (the wolf and warg packs) are his question 11; the bosses' stat blocks
its section 6; the escalation check its hole 8. Nothing of it lands before the model's numbers.

## 5. The reads before any content moves

Three what-if switches in the balance runner (`tools/balance.gd`), none of them content:

- `--regen N`: every chassis regains N shield a round, shield faces skipped when the machines are
  made (a shield entry becomes a blank), so the second shape is read at N of 1, 2, 3 and the full
  reset.
- `--novents` with `--cooling N`: vent faces skipped, every chassis cooling N a round, so heat as
  a pace is read at coolings of 0, 1 and 2 with the prices as they stand.
- `--nodestroy`: the injury breaks the entry for the fight and destroys nothing.

Then, on the proposal's grids in a scratch worktree, at thirty seeds: the curve read with hull
lost a fight, stalls and rounds beside the bands, for each switch and for the three together; the
campaign runner's hull a battle, fights a battle and battles won; the vanilla ladder's heat grid
without vents at each cooling. A persona that trades hull for kills beside the greedy, which
already shields whenever it saves hull this round, so "aggression rewarded" is read and not felt.
Every read a direction into `docs/measurements.md`; then Ryan's play at placeholders, which
decides feel.

## 6. The content the model moves, once the numbers are read

- Eight shield-kind components: the Canopy and the Halo Shield (basics, tier zero), the Laminar
  Deflector and the Corona Shield (tier two), the Oblation Mantle (tier one), and the fixed pieces
  the Backwash Ionizer (the Puffin), the Mooring Screens and the Sutler's Hoist (the Swallowtail).
  Each becomes equipment (a Barrier, an Armoured, a Ward, a one-round overshield as a Kestrel
  piece if one survives), a commander action later, or retires.
- Seven vent-kind components: the Coolant Jacket and the Bleed Valve (basics), the Radiator Sail,
  the Phased Sublimator and the Wake Diffuser (tier one), the Entropy Condenser (tier two), and the
  Musk Ox's Quick Reload (fixed). A payoff vent becomes equipment that converts heat; a plain vent
  retires; the Whip Scorpion's vents that blast (Vent, Weapon) are weapons.
- The chassis whose identity is the shield or the vent, re-stated: the Puffin (Kestrel's shield
  escort reading the ally's heat), the Storm Petrel (its shield pays its weapons' heat and zaps;
  its own regen a timed grant), the Swallowtail (screens and hoist), the Musk Ox (its reload), the
  Cassowary's Spin-Up and the Kite's cooling as identities that stay.
- Every chassis's `shield_regen` and `cooling`, by role and maker; every component's heat price
  (the heat session's list); the bosses' and massives' HP by band, the fodder's blows; the
  pushers re-cut; the injury rule's destruction off; the basics' Barrier and Armoured pieces.
- The records: the bible's kit row, shield row, triangle row, injury row, redirection row and the
  commander layer's Open row; `docs/rules.md` as each lands; the vocabulary's Shield, Vent and
  Equipment entries; CLAUDE.md's kit words; the hangar page republished.

## 7. Open, for Ryan

1. The regen's size and shape: a point or two a round, or the full reset; by role, by maker, or
   one number.
2. Heat's prices and the cooling: whether the heat session's list lands here, and the cooling by
   chassis.
3. Which shield pieces survive as equipment and as what; whether any one-round overshield stays
   as a Kestrel piece.
4. The Puffin's and the Swallowtail's identities under the model.
5. The pushers' hull target at their rating: a twentieth a fight, so ten fights spend half a
   squad, or another number.
6. The injury's in-fight break: kept, as read here, or off with the destruction.
7. The commander layer's shield and vent actions: a note now, a row when that layer is designed.
8. The formation proposal's questions still open (its section 9: the opening's line, the ratings'
   reading, the question under `design`, the ramp bands, the prunings, the bosses' form, the metal
   pair, the hunters that read as ones, the giants' escalation, a tier-two light's read).

## 8. Holes raised, each with what settles it

- A regen large enough to absorb fodder makes lights untouchable against it and the fight a
  kill-speed race alone; too small and nothing changes. The reads at the dial's steps settle the
  size, his play the feel.
- Heat as a background number nobody feels: passive cooling cannot carry a pillar, so the prices
  must bite; the heat grid without vents says whether they do at each cooling.
- The bot: the greedy must learn the hold (it cannot vent) and value the regen as hull kept;
  `sim/policy.gd` moves with the switches, read against its old self on the matrix.
- The Storm Petrel's loop: a shield that pays heat and regenerates each round is a cheaper engine
  under the model; its numbers are read on its row before anything lands.
- The lights' identity: big shields on small hulls read differently when the shield regenerates;
  Kestrel's shields against Minerva's armour is the lean, the regen and the armour the two
  makers' answers.

## 9. The order, on his answers

1. The three switches and the persona in the runner, tested; the reads of section 5 into
   `docs/measurements.md`.
2. His play at placeholders (the switches run in the harness too), his read.
3. The content of section 6 as marked, the pushers re-cut and read by hull lost, the escalation
   check, the records, the hangar page.
4. The formation proposal's remaining questions settled in play; the bosses' blocks after.
