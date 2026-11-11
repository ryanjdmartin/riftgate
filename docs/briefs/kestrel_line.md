# Brief: the Kestrel line (review, 20 October)

<!-- hangar: {"kind": "hub", "maker": "kestrel", "tier": null, "status": "hub", "slot": false, "name": "the Kestrel line"} -->

The review of every Kestrel chassis, built and proposed, under the action economy's direction
(the bible's row beside the stun row, 20 October): where each stands, what would improve it,
and the holes in Kestrel's stock that the stock pass should fill. Ryan asked for it on 20
October, after the direction went to main: "revisit all the Kestrel chassis and look for
areas of improvement, and flag any stock holes that need filling." Everything here is
Claude's proposal for him to move; each chassis's improvement lives in its own brief and is
only pointed at from here (the interceptor got a brief of its own, retired 23 October: `git show 9ced5e5:docs/briefs/kestrel_interceptor.md`).
Ryan, 20 October, on reading it: the kits written out whole, not as bullet points, and the
stock by kind, since most stock pieces are placeholders until the stock pass; so every brief
now carries "The kit, written out" (the Buzzard's and the Puffin's below), its stock by kind
and a piece named only where it fits as it is.

**Status**: the fast flyers' identities reopened under the long wall on 11 November (the next
section; the Kite and the Needletail a proposal each in a brief of its own). Before that: every chassis decided by 21 October and named that evening (the Skua, the Storm
Petrel, the Needletail and the Giant Petrel in content and modelled 23 October, the Needletail
whole, the Skua whole since its engine of 25 October, the other two planned until theirs); the Buzzard's stock filled and the stock
holes taken; the last two slots marked (the Magpie, a support engine; the
Snowy Owl, a stealth unit), each in a brief of its own since that evening. A proposal (Claude,
20 October) until then. **Maker**: Kestrel. **Read first**:
`docs/briefs/README.md` (the taste lines, the tiers table, the action-economy section); the
bible's action-economy row, its leans row and its Kestrel rows (sections 5 and 7); the five
Kestrel briefs; `content/chassis.json` and `content/components.json` (maker `kestrel`);
`docs/balance.md` (13 October: the Kestrel rows and the pick shares).

## The fast flyers, under the long wall (11 November)

Newer than the review below, which predates the long wall, the refit and the foes' roles: where
the two differ, this section stands.

- Ryan, 11 November: "Given our new battle framework, I want to settle the identities of the
  Kestrel fast flyers. Not pigeonholes, but just what does what and why you'd want one over the
  other." "Kite, Skua, and Needletail are the 3 move Sixers, where the skua has a direction but
  needs tweaks and the needletail is basically free to be whatever we want. Buzzard is close
  behind as a move 5 risky dps/burst engine, giving it a hybrid identity that can fit into either
  a squad or flanker role. So what about the other three? Let's sort them out together, now."
- Of the Kite and the Buzzard: "I feel like the "cousin" angle between kite and Buzzard can be
  dropped since they no longer share names."
- Of the last two slots: "the remaining two Kestrel chassis probably shouldn't be in the move 6
  light space with these three. Probably more in the Buzzard/storm Petrel medium space. So their
  roles are still open but not really relevant to this discussion."

**What the wall asks of a fast machine** (the rules' battlefield; the bible's squad row and roles
row). A high-move machine is the flanker and the firefighter (his word of 5 November). A
formation is a fight for three; a patrol is a duel for one or, as a pair or a hunting pack, a
fight for two; an elite and the boss are a true four. A machine has one action a turn, no fight is
left, hull stays for the battle while the shield opens full, and a pack that a fight has worn
strikes the wall by the heads it still holds. So what a flank sends comes in three shapes: many
small heads (a hunting pack, a pair, the tide's patrols), one head that matters (a duelist, the
worker behind a formation's front, an elite's own), and a fight too long for a light.

**The map**, as his refinement of 11 November left it (his words lead each; the rest Claude's
reading, for him to move):

| Machine | His word | Its fight | It wins by | What it cannot do | What its kit wants |
|---|---|---|---|---|---|
| The Kite | "Burst glass cannon" | the short one, and the first rounds of any | opening at double on what nothing has touched, finishing with its lock, a kill paying it | anything big after its first shot; a long fight | one big single hit; reach |
| The Skua | "Ramping Dakka" | the long one | Ricochet: a strike more for every stack, a stack a round | plate; a pack that out-hits its shield | riders a hit, flat buffs, Exposed |
| The Needletail | "free to be whatever we want" | beside another machine | two things a round, a weapon and an equipment, the mark every round | weight of its own | every maker's equipment |
| The Buzzard (move 5, medium) | "risky dps/burst engine" | either, squad or flank | the burst that builds and commits: its shield spent into its blow | | hot guns |
| A medium, unspecced | "at least one chassis that orbits" Exposed | its session's | cashing the mark the others set | | |

In time they spread: the Kite is strongest in a fight's first round, the Skua in its last, the
Buzzard when it chooses, and the Needletail every round alike. They pair on Exposed, the maker's
keyword: a painted foe's armour counts for nothing, which is the one thing a strike of 1 fears,
and the paint puts an untouched back rank in reach of the Kite's Direct opener.

Where each stands:

- **The Kite**: redesigned from the ground up on his word, in its brief (`kestrel_kite.md`). A
  Kite that left a fight at its heat maximum he declined ("it adds clunk to the battle. We
  ditched withdrawal and the game feels better for it"). Its kit as his words of 11 November
  leave it: four entries and no reset; every weapon doubled on an unhurt foe; the Pinion Driver
  the finisher again; a kill recharging a small shield whole. Phased on a kill he kept for the
  shadow panther ("It keeps the phased orbit, not the Kite"). Open: the Coriolis Accelerator,
  the Driver's twin in the pool, and the frame's numbers.
- **The Skua**: his rewrite of 11 November, in a brief of its own (`kestrel_skua.md`): a stack of
  Ricochet for damaging an enemy, once a round, and a second only by its lock, the Hypersonic
  Swoop (Rapid, a cooldown of one); a strike of 1 more for every stack, half lost on any hull
  damage; the Flechette Pod an ordinary weapon. Open: Claude's readings of what his words leave
  (strikes of 1 through the whole blow; once for each enemy a spend is aimed at; half rounded
  down at each blow that takes hull; no cap), written so unless he says.
- **The Needletail**: settled 11 November ("I agree with the Needletail, yes"), in its brief
  (`kestrel_needletail.md`): two things a round, a weapon and an equipment every round, the
  Designator kept, so it marks every round. The squad's fire on its paint he set aside
  ("spotting, yes, but artillery, not necessarily"). Its build waits on his go.
- **A chassis that orbits Exposed** ("Exposed being Kestrels primary keyword means we need at
  least one chassis that orbits it"): one of the two unspecced mediums, the payoff the three
  setters lack; that slot's session's to design.
- **The last two slots** (the Snowy Owl, the Magpie): medium, by his word above; open, and not
  this round's.

## The line as it stands

Eight machines decided, 3-3-2 across the tiers, and the last two of Ryan's ten marked on 21
October, their tiers open (the counts: 3-5-2 or 4-4-2). Each with what it reads, what it produces, what it pays, and the currency the
direction gives it (the row's homes: strikes, a die mechanic, a banked resource, a cooldown
burst, a delayed action, a combined entry, own rerolls).

| Tier | Machine | Reads | Produces | Pays | Currency |
|---|---|---|---|---|---|
| one | the strafer, the Skua (its go 21 October, named that evening, the Butcherbird a BattleTech 'Mech's; landed 25 October, its brief retired) | nothing new: its own blows | two strikes a weapon, riders and flat buffs twice | the foe's armour twice | strikes (the many-blows want's home) |
| one | the off-tank, the Storm Petrel (its go 21 October; `git show d84ad16:docs/briefs/kestrel_shield_spender.md`, retired with its engine on 30 October) | its own shield as plate and magazine | a lure that regens itself; the zap | shield burnt, an injury risked | shield; its lock the model combined entry |
| two | the interceptor, the Needletail (decided 21 October, tier two and named that day; landed 23 October, its brief retired) | debuffs and buffs | a free setup a round; a foe Exposed: in the team's Direct reach, armourless | two spends' heat, glass | the gate: a debuff or a buff |
| two | the Buzzard (built) | its own heat | shield from heat; one blow that fires it all | running hot | heat banked (the row's Kestrel resource) |
| one | the Puffin (reworked and built 21 October, tier one since that day; the bible's Puffin row) | allies' heat | shields grown by the ally's heat, the overshield the big one | its thin frame | heat converted for others |
| two | the Kite (reworked and built 21 October; its brief retired) | its kills | a chain of doubled shots | flat heat, the tax, dark guns, hull 30 | a cooldown burst gated by a kill |
| three | the bomber, the Lammergeier (its go 21 October; the Magpie until that evening; `kestrel_bomber.md`; reworked 9 November, the bible's Lammergeier row) | the foes it hits, and their falls | a Mine on each foe it hits, blowing round it as the foe falls; the gather, the detonation | the delay until the fall | a delayed action |
| three | the gun platform, the capital, the Giant Petrel (its go 21 October, the formation leader; `git show d84ad16:docs/briefs/kestrel_gun_platform.md`, retired with its engine on 30 October) | the team's rerolls | a reroll bank; an ally's action bought with three rerolls; a jet's die relaunched; rerolls brewed | rerolls, the fleet's pace | rerolls |
| open | the Magpie (marked 21 October, Ryan: a support engine; to design) | | | | |
| open | the Snowy Owl (marked 21 October, Ryan: a stealth unit; to design) | | | | |

**Kestrel's identity, re-read under the direction.** The leans row (13 October) gives
Kestrel "Rapid, Empowered and Overshield, and the chain rule (tempo, burst, escort)". The
line as it stands reads otherwise: Kestrel's currencies are heat as a resource (the Buzzard
banks it, the Afterburner and the Kite spend it, the off-tank burns shield in its
place), the die as a gamble (the platform's growth, the Kite's d3, the strafer's
spray), rerolls (Ryan, 19 October: Kestrel's), strikes (the strafer) and speed on the map
(move 50, field recharge 30: the detachment). Rapid is its gated cantrip, not its spine.
Ryan, 20 October: "the maker didn't really have an identity before other than the look, and
now we are indeed looking at heat, rerolls, multi-strikes, and risk". The leans row carries it
since that day; Empowered leaves the Kestrel lean (the Coil is its one carrier, and the
Ammit's talons and the Reliquary are the Arsenal's). Three of the eight hover (the Puffin, the
off-tank, the capital) and five fly; the capital hovers from irony (Ryan, 20 October).

**The overlap map**, each pair parted by its shape (Ryan's rule of 18 October): the strafer
and the Kite, count against magnitude; the strafer and the platform, strikes doubled
by a passive against strikes grown by rolls; the off-tank and the Buzzard, shield burnt for
damage and plate against heat banked for shield; the interceptor and the Kite, a
second spend every round against a chain on a kill; the interceptor and the Puffin, its own
second spend against a vent that gives an ally its turn; the bomber and the platform, the
slots against the rolls; the Buzzard and the Kite, hot sustain against hot burst.

**The tender.** Three tier ones (a hitter of volume, a body, a tempo hitter), so Kestrel's
deal varies by seed and the off-tank holds a front, Ryan's reason of 19 October (a tier-one
body from more than one maker).

**The data** (13 October, the old line): the Kestrel team loses the Meadow formation (39
percent greedy, 83 percent of its hull), the Marsh (7) and bleeds on the Peak (72, at 72
percent of its hull): no body. The Buzzard alone wins only the fights a hitter wins (1 percent
against the goblins, 14 against the gels, 41 against the needlers), the weakest of the
hitters, which the review reads as its stock's verdict (below), not its passive's.

## Each chassis: where it stands, what would improve it

One pointer each; the proposal is in the brief named.

- **The strafer** stands as proposed for the go. The hole re-flagged: with basics alone it
  gains nothing against bare foes and loses against plate; the root is the scales question
  (section 12), never an exception; its payoffs are riders, flat buffs and multi-strike
  pieces, cross-maker by design, and the stock holes below give Kestrel one of its own.
  `git show f87b831:docs/briefs/kestrel_strafer.md`, the line review.
- **The off-tank** stands as Ryan's package, a hovercraft at 50 (Ryan, 20 October: fast, so
  Kestrel is seen to make a fast one; a decent generalist that can zoom off and fight a pack).
  The plate's arithmetic read against the foes: a wall against the packs that strike for 10
  (six of the eighteen wildlife), no wall against a swarm (six goblins strike 30 each with
  their swarm, 25 past the plate); the lever named. Its lock is the direction's model combined
  entry; never Rapid. `git show d84ad16:docs/briefs/kestrel_shield_spender.md`, retired with its engine on 30 October, the sixth and seventh rounds. Its go (Ryan,
  21 October): the Storm Petrel, a hovercraft at 50, the kit as written; the burn is every
  shot's, through the passive, and the lock the lure alone.
- **The interceptor** had no kit; its first Ryan read as thin and its second as possibly
  overdesigned with a good nugget (20 October). The third: a debuff is Rapid once
  a round, so every control piece of every maker is a cantrip on it; its lock the designator,
  a debuff with Indirect reach that paints a foe for the team's Direct guns this
  round; the dive's price benched; a tilt-jet. The fourth round (late that day): the mark is
  Exposed, the game's own word (the vocabulary's formation entry, the engine's one reach
  check), reach alone, its on-hit half declined as Flak's kind and the armour clause benched;
  the gate widened to buffs, the die's glyph deciding (a shield or vent that also buffs wears
  a chip and is excluded); the foes' aim word flagged for renaming. The fifth: Ryan took
  Exposed as reach and armour counting for nothing, and no number on a debuff;
  the duration evaluated (the round's, as Expose 1; a foe's statuses tick at its turn whether
  it acts or skips, so "until it acts" buys nothing) and his die kinds answered (Direct,
  Indirect, Debuff, Buff, Shield, Vent, the blank a drawing; the Debuff glyph wears its reach;
  a debuff deals nothing under any effect). The sixth: the one-meaning fix struck on Ryan's
  reason (cover is reach, armour the foe's own); the glyph's grammar settled in the open, a
  reach frame carrying a number (a gun) or the status mark (a debuff), the mark alone a buff.
  The seventh (21 October): Exposed lasts two rounds and a second Expose refreshes it (Ryan);
  the aims' shown words to be rewritten plainly (Ryan: cryptic). `git show 9ced5e5:docs/briefs/kestrel_interceptor.md`.
- **The Buzzard** stands; its stock was cold for a heat machine (its hottest stocked gun pays
  10, the Afterburner's base nothing), so its loop barely runs with its own kit: about 15
  heat carried, 5 shield a round. Its stock filled on Ryan's word (21 October, below): every
  gun a step of heat, the Railgun off the Kite's, the mid-heat gun, the Arc Fault Cannon, a
  basic shield and the basic vent, the Coriolis Accelerator out (a blueprint, the Kite's
  rework); its niche word in content rewritten to the sustain it is (flagged 18 October, done
  21 October). Its thinness as a partner (no state given, none needed) is accepted: the
  Kestrel that stays.
- **The Puffin** was reworked and built on Ryan's go (21 October), after his worry that it was
  toxic and boring (20 October) and his split: the Slipstream Projector grows every shield it
  spends on an ally by a fifth of that ally's heat, the Backwash Ionizer at 10 is the big one
  through it, and the cooling passive is gone (the bible's Puffin row; its brief retired to
  git). The Wake Diffuser landed on his go of 20 October: Rapid off, a vent of 10 that
  shields 10 (the shield half with the combined entry's engine), so on the Puffin it is the
  cooling, the vent first and the shield reading what is left; and Rapid vents or shields, if
  any exist, never below tier three and two (his rules of the day).
- **The Kite**'s rework is decided (Ryan's go, 21 October, when he named its lock): the reset
  gun is the Pinion Driver, the old finisher the Coriolis Accelerator, a blueprint once the
  rework lands; the trash chain and the steady doubled gun, the caster-killer the
  interceptor's Exposed. Built 21 October, its engine and content, tier two (the bible's
  Kite row; its brief retired to git). The to-do's stock pass line and the bible's
  stock-pass row moved with the go.
- **The bomber**'s go (Ryan, 21 October): the Lammergeier since that evening (the Magpie
  before, the name moving to the support engine), a heavy flyer, a flying wing since 27 October (the tandem wing of its go ditched); its mark the
  Syrinx Drone, which leaves a debuff of its own name and is Rapid on a foe already Exposed,
  else gives it Exposed with no refresh (the line review's gate to the bench); every keyword acts from a
  mine as the shot lands, Chain whatever Chain becomes. `kestrel_bomber.md`. Reworked 9 November
  (Ryan: "A chassis based around opening an empty spot isn't a good design"): every spend it aims at
  a foe leaves a Mine on it that blows round its slot when the foe falls, the Syrinx Drone its
  detonator and the Lorentz Contractor its gather, which Exposes; the bible's Lammergeier row.
- **The gun platform** is Kestrel's capital ship, a hover, not a flyer (Ryan, 20 October,
  from irony: three quarters of the line flies), and the action-economy utility capstone on
  his word: the reroll economy all the way, no growth. Its seventh round: the team's unspent
  rerolls banked, up to three; an ally's second action bought with three rerolls, never with
  the capital's turn; a lock that shields a jet and rolls its die again; a lock that vents and
  brews the team a reroll; four hardpoints, assault, the ekranoplan. Settled here: no
  multi-strike vent in the pool. Its eighth round (21 October): the Giant Petrel and the
  ekranoplan on Ryan's word; three locks and three hardpoints on his frame, two support locks and
  an offensive one around rolls, rerolls and actions, the cash-in a Rapid lock that spends
  three rerolls on a spent ally (proposal). Its ninth round (21 October), Ryan's: the formation
  leader, aggressive, where the Swallowtail is the supportive HQ; lock 1 Rapid, a team reroll on
  itself or an ally's action for three rerolls; lock 2 the battery; lock 3 Empowered 2 and a
  roll for an ally. Its go the same day, on his answers: three rerolls paid, a spent ally, the
  bank, the hardpoints. `git show d84ad16:docs/briefs/kestrel_gun_platform.md`, retired with its engine on 30 October.

## The Buzzard's and the Puffin's kits, as the stock pass would leave them

The two built Kestrels have no brief; their kits are here, the passives and fixed pieces as
built and the stock by kind (Ryan, 20 October: the stock pieces are placeholders until the
stock pass, so a piece is named only where it fits as it is).

**The Buzzard.** Tier two, a medium flyer at move 40. Hull 100, shield 50, field recharge 25,
heat maximum 100, cooling 5, armour 0; five hardpoints beside the fixed Afterburner Cannon, a
d6; two module slots. The passive, the Thermal Recoupler, as built: at the start of its turn
it regains 5 shield for every 10 heat it carries. The fixed piece, the Afterburner Cannon, as
built: Direct, flat 10, heat 0, fires the whole heat gauge into the shot at +10 per 10 heat
fired, and the airframe is cold after.

Its stock, filled by Claude on Ryan's word (21 October: "Fill the buzzards stock with what you
think"), for the stock pass to land:

| Entry | Piece | What it is for |
|---|---|---|
| I | the Afterburner Cannon (fixed) | the dump: 70 at 60 heat, then no regen next round |
| II | the Overclocked Railgun: Direct, flat 50, heat 40 (kept in the pool, its note's "temporary" retired) | the big hot shot, the regen's best fuel |
| III | the mid-heat gun, Kestrel's new tier one (below): Direct, flat 25, heat 20 | the middle step |
| IV | the Arc Fault Cannon: Direct, 15, Chain, heat 10 | the warm round and the trash; Kestrel's chain gun, whatever Chain becomes |
| V | the basic self shield (Minerva's; its name the pass's) | the reload when it is cold and hurt |
| VI | the basic vent (Kestrel's, the Ram-air Scoop until the pass renames it) | the brake near 100, with cooling at 5 |

Why: every gun is a step of heat (40, 20, 10) and the Afterburner the dump, so each roll asks
how hot to ride, and the regen reads the answer at the next round's start; the shield and the
vent are its two brakes, one for hull and one for heat. Out with the pass: the Laser Carbine
(heat 5 feeds no loop), the Coriolis Accelerator (a blueprint
now) and the Laminar Deflector (a tier-two blueprint, never on a tier-two stock). A tier two
stocks below its tier, so the pass sets the Railgun, the Arc Fault Cannon and the mid-heat gun
at tier one; if the mid-heat gun is not taken, entry III is a second warm gun. Until the pass
its stock carries about 15 heat a round (a warm gun, the chain gun, a gun of no heat, a
shield, a vent), 5 shield a round, which is why its solo rows are the weakest of the hitters.
The round as played: fire hot; at the next round's
start cooling takes 5 and the regen reads what is left (40 → 20 shield, 60 → 30); ride hot for
the regen or dump the Afterburner and be cold next round; the vent when the gauge nears 100
and the Afterburner is not showing. A hot stock (a 40 and a 20 a round) sits at 60 by round
two, a tank's regen at tier two under the honest shield rule, with the overheat at 100 the
ceiling. It wants hot guns of every maker, the Peak's Scorched, the Thrust Overboost (its guns
twice as hot: twice the regen for twice the risk) and the Boundary-layer Bleed; it gives
nothing to others, the Kestrel that stays, and the Puffin's shields grow on it (its vent fought
it until 21 October). Its niche word in
content says the sustain it is since 21 October; its 5 per 10 is re-read under the honest
shield rule by the stock pass.

**The Puffin** (reworked and built 21 October). Tier one since that day, a light hover at move 40. Hull 50,
shield 30, field recharge 30, heat maximum 60, cooling 5, armour 0; four hardpoints beside the
fixed Backwash Ionizer, a d5; two module slots. The passive, the Slipstream Projector: a shield
it spends on an ally grows by a fifth of the heat that ally carries. The fixed piece, the
Backwash Ionizer: shield 10, allies only, Overshield, so on a hot ally it is the big one (the
Buzzard at the top of its gauge, 30 past its maximum; a jet at 40 heat, 18; a cold ally, 10).

At tier one it stocks basics beside the Ionizer (the tiers row; the stock pass, 22 October:
the Halo Shield, the Coolant Jacket, the Twin Autoguns and the Laser Carbine), so the Coil and
the Diffuser it carried before the pass are its found upgrades. By kind, as the line review
had it (21 October):

| Entry | Piece | What it is for |
|---|---|---|
| I | the Backwash Ionizer | the hot ally, past its maximum |
| II | the basic shield, self or ally (the Halo Shield today) | the hurt ally, grown by its heat |
| III | the basic vent, self or ally (the Radiator Sail today) | the ally that must cool |
| IV | a basic gun | when nobody needs anything |
| V | a second basic gun, or the self-only basic shield (the pass's call) | |

The round as played: the Ionizer on the hot ally the intents name, after it has fired its hot
gun, so the team's order is part of the play; the basic shield on the hurt one, grown by its
heat; the vent on an ally that must cool; a gun otherwise. Found, the Coil goes on the hitter
before it fires and the Diffuser is the vent that shields. It
wants hot allies and shields of every maker, each grown through its passive; it gives the jets
a bubble sized to the risk they took, the strafer's doubled Coil and the off-tank its magazine,
and the Buzzard riding hot is its best ally now. Alone it loses, by design.


Kestrel's pool today: ten components (one fixed, the Afterburner; one locked, the Backwash
Ionizer; the Coriolis Accelerator leaving the Kite's and the Buzzard's stocks for the pool as a
blueprint) and three modules. Every stocked Kestrel weapon is Direct, flat and single-target,
Chain aside: no multi-strike piece, no rider, one hot gun (the Railgun at 40 heat, which its
own note calls temporary) and nothing between it and the Carbine's 5. What the builds want
that the pool does not give, re-read 21 October with every machine decided, and taken that
evening for the stock pass's list (Ryan: "stock changes as you see fit"), each with its name:

1. **The Cyclic Cannon**, Kestrel's multi-strike gun, tier one or two: Direct, flat and warm,
   5 ×4 at heat 15, a rotary cannon on a jet (the cyclic rate is a gun's rate of fire). The strafer's (×8 under its passive), the interceptor's cash (an
   Exposed foe's armour counts for nothing, the one thing a multi-strike gun fears), Flak's
   partner. Parted from the Maxigun (rolled, cool, three strikes). The action-economy row
   (the bible, section 5) names multi-strike pieces the blow currency; this is Kestrel's one.
2. **The Transonic Rifle**, Kestrel's mid-heat gun, tier one: Direct, flat 25, heat 20, the
   step between the Carbine and the Railgun (transonic is the band between subsonic and
   supersonic; a stock piece may be a rifle, a locked Kestrel piece never is, Ryan, 11
   October). The Storm Petrel's middle burn (20 shield for 20 more and a zap of
   20), the Buzzard's regen fuel (its stock above), the Kite's doubled 50 at 30 heat.
3. **Trim Tabs**, Kestrel's reroll module, tier two: one free reroll of this machine's die a
   round, its stat line paid (heat maximum −20, or shield −20), per the action economy's row (own rerolls
   as a number, priced so no module is the universal pick). The Kite's d3 fishing for its live
   lock, the Skua's Flechette Pod, any small die; Kestrel's own reroll beside the Giant
   Petrel's team bank.
4. **The Railgun kept**: the pool's big hot flat gun, its "temporary" note retired, in the
   Buzzard's stock rather than the Kite's.
5. **Settled since**: the Wake Diffuser landed 20 October (a vent of 10 that shields 10, no
   Rapid), and the Laminar Deflector is a tier-two blueprint with its Rapid, out of the
   tier-one and tier-two stocks (Ryan, 20 October: a Rapid shield is never below tier two, a
   Rapid vent never below three); Chain in mines at the bomber's go (every keyword acts from a
   mine as the shot lands, Chain whatever Chain becomes); the seven locks named in the names
   round (the pull the Lorentz Contractor), the reset gun the Pinion Driver and the mark the
   Syrinx Drone since 21 October.
6. **Not holes**: a stocked Kestrel Indirect gun (Kestrel's Indirect pieces are locked: the
   Fovea Designator, St. Elmo's Regenerator, the Lorentz Contractor, the Syrinx Drone and the Spindrift
   Salvo; the artillery makers' reach is theirs) and a stocked Kestrel rolled gun (the
   Flechette Pod and the Spindrift Salvo are locked; the Muzzle Velocity Booster serves other makers' rolled guns on Kestrel frames, the
   cross-maker pull); no Kestrel plain shield (the basic shield is shared; Overshield is the
   Puffin's); no Kestrel cold hard hitter (the Kite's pull of Minerva's and Wainwright &
   Sutler's kinetics is its design).

## The last two slots

- Ryan, 21 October, evening: "Mark down Magpie and an Owl (probably snowy owl) as our last two
  chassis, probably a support engine and stealth unit, respectively."
- Marked: the Magpie, a support engine, and the Snowy Owl, a stealth unit, each designed in a
  session of its own (the to-do); a plain Owl is a Heavy Gear machine, so the owl's name keeps
  its species. Their tiers are open: the counts put both at tier two (3-5-2) or the support
  engine at tier one (4-4-2).
- Ryan, 21 October, later: "Magpie (working name) could lean into the thieving space (myth,
  but decent gameplay hook), or something to do with its general intelligence. The stealth
  thing is obviously completely undefined, could be map related or skirmish related, the theme
  is just silent hunter." Each has its brief since, with a first round:
  `kestrel_magpie.md` (the thief, Claude's lean; the mimic; the cache) and `kestrel_owl.md`
  (cold is quiet, Claude's lean; the hunter on the map; Hidden as a status).
- Holes for those sessions, one line each (Claude, 21 October): a third Kestrel support beside
  the Puffin (shields from an ally's heat) and the Giant Petrel (tempo: rerolls and actions)
  must part from both by its shape, the overlap map's rule; the magpie's folklore is the thief
  and the mimic, and the Syrinx Drone, the mimic's voice box, stays on the Lammergeier;
  stealth is new to the rules, and the nearest state, the Swallowtail's Phased (on main),
  cannot act, so stealth is a state of its own (hidden until it strikes, say, or never an
  aim's pick); owls fly silent, which is its look and its sound.

The bench for either, one line each:

- The capacitor (18 October, kit 1): overshield as its ammunition, a bank of safety that pays
  damage; tier two beside the Puffin, which feeds it. Ryan passed over it for kit 2 without
  striking it.
- The machine that must fight to stay shielded (Ryan's version, 18 October: zero or negative
  field recharge, the shield recharging from damage dealt): a map identity; benched until the
  map can make it a decision (the four-machines row sends the roster to one front).
- Growth on every roll (the platform's shape until 20 October): Ryan, enough growers; its
  arithmetic stays in the platform's brief for any grower that wants it.
- Struck: the chain tier three (Rapid switches nothing off on it), the Rapid pile the row
  forbids; its exit: a pool where every Rapid piece is gated bounds it, so reopen if the
  stock pass gates them all and the shape still reads.

## Records the review found stale or waiting on a go

- The leans row's Kestrel line: rewritten 20 October on Ryan's word.
- The Buzzard's niche word in content ("Ramping damage"; its notes already say damage scaling
  was dropped): rewritten 21 October to the sustain it is.
- The to-do's stock pass line and the bible's stock-pass row lock the Pinion Driver on the
  Kite and give the Buzzard's hardpoint a basic; the Kite's rework supersedes
  both on its go (the reset gun its lock, the Driver a tier-two or tier-three blueprint, the
  Kite at tier two stocking tier-one pieces).
- The tiers row's "every tier-one chassis has a locked piece once the Pinion Driver locks on
  the Kite": rewritten 21 October (the Kite leaves tier one with its rework); Kestrel's tier
  ones each carry one (the strafer's spray, the Storm Petrel's lure, the Puffin's fixed
  Ionizer).
- The bomber brief's "a free mark every other round" (cooldown 1 is the switch-off): the
  gate is the Syrinx Drone's since 21 October (Rapid on a foe already Exposed).
- The makers table's "nothing big" takes two exceptions, the bomber heavy and the platform
  heavy or assault, a Lean bending as Leans do.

## Which fighter at tier one (21 October)

- Ryan, 21 October, after moving the Puffin to tier one: "The storm petrel, Puffin, and one of
  the fighters - not sure which makes sense for t1." So the line stays 3-3-2: the Storm Petrel,
  the Puffin and a fighter at tier one; the Buzzard, the Kite and the other fighter at tier
  two; the bomber and the capital at tier three.
- Claude's lean: the Butcherbird at tier one, the interceptor at tier two.
  - **With basics alone.** The tier-one test is identity with basics alone. The Butcherbird's
    two strikes at half show on every gun, basics included. The interceptor's gate fires on a
    debuff or a buff, and no basic is either, so at tier one it fires on its own lock alone (one
    round in four, and after a reroll). At tier two its stock may carry tier-one buffs and
    setters (the Coil, a probe), so its identity shows on the die from the start.
  - **Complexity.** A chassis's tier is complexity. The interceptor carries a gate, a new status
    with two halves and two rounds, and it pays off through other makers' pieces: the synergy
    machine. The Butcherbird is one rule and a spray.
  - **Tempo.** Two spends a round asked for glass numbers at tier one (its holes); at tier two
    its numbers can breathe.
  - **The tender.** A body, a support and a damage dealer, so Kestrel's deal varies by role.
  - **The cost.** The Butcherbird's start hole (a halved basic against armour 5) sits in the
    tender, and Exposed, its Kestrel answer, arrives a tier later; the root stays the scales
    question (section 12) and the stock pass. The Coil is a tier-one piece now (the Puffin's
    stock), which feeds its strikes from the start.
- Ryan, 21 October: "Put butcher in." Decided: the Butcherbird at tier one, the interceptor at
  tier two. Kestrel stands 3-3-2: the Butcherbird, the Storm Petrel and the Puffin; the
  Buzzard, the Kite and the interceptor; the bomber and the capital.

## The names round (21 October, evening)

- Ryan, 21 October: "Lets name the remaining items. Fill the buzzards stock with what you
  think. What are the other questions?"
- Claude's picks, one each with another, Ryan's to settle. Kestrel's register is flight and
  aerodynamics, with a bird inside where one fits (the Pinion Driver, the Syrinx Drone).
  Every chassis name is checked against `content/reserved_names.json` (BattleTech, Heavy Gear,
  Warhammer 40,000, Halo), which is how the Butcherbird turned out a BattleTech 'Mech
  (`git show f87b831:docs/briefs/kestrel_strafer.md`); every name against the names in content on main and the branches.

| Item | What it is | Claude's pick | The other |
|---|---|---|---|
| The strafer (the Butcherbird is a BattleTech 'Mech) | the swing-wing; two strikes at half | the Skua: seabirds that harry other birds in repeated dives until they drop what they carry (and a 1930s naval dive-bomber) | the Kingbird: the tyrant flycatchers, which strike hawks again and again |
| The interceptor | the tilt-jet; a free setup a round; Exposes | the Swift: among the fastest flyers, living on the wing; acting twice a round is its tempo | the Needletail: a swift claimed the fastest in flapping flight, a needle that points the team at the kill |
| The strafer's lock, the spray | 10–15 ×2, the first strike aimed, the rest at random | the Flechette Pod: fletched darts, sprayed | the Raking Cannon: raking fire, and a falcon that rakes off after other quarry |
| The Storm Petrel's lock, the lure that regens itself | Lures a foe; Regenerating on itself | the Corposant Lamp: St. Elmo's fire, the storm glow on a ship's mast that every eye turns to | the Squall Lantern |
| The interceptor's lock, the designator | an Indirect debuff that Exposes | the Fovea Designator: a falcon's eye has two foveae, the deep one for distance | the Schlieren Designator: the photograph that shows invisible air |
| The Magpie's lock, the pull | every mine gathered into one slot and set off | the Roost Beacon: every mine comes home to roost | the Larder Hook: the hoard gathered into one larder |
| The Giant Petrel's first lock, the Hot-Pit | Rapid: a team reroll on itself, or for three rerolls a spent ally acts again | the Hot-Pit Boom: hot-pit refuelling turns a jet around with its engines running | the Turnaround Rig |
| Its second, the battery | a rolled Indirect gun; its kill gives two rerolls | the Wavetop Launcher: the ekranoplan's sea-skimming missiles ("battery" is Wainwright & Sutler's word) | the Spindrift Salvo |
| Its third, the buff | Empowered 2 and a roll for an ally | the Reheat Uplink: reheat is the afterburner, sent to an ally | the Throttle Uplink |
| The strafer's passive | every weapon strikes twice at half | the Interrupter Gear: the gear that let a gun fire between a propeller's blades | the Split-cycle Breech |
| The Storm Petrel's passive | the plate, the burn and the zap | the Plenum Discharge: the plenum is the hovercraft's cushion chamber | the Skirt Capacitor |
| The interceptor's passive | a debuff or a buff Rapid once a round | the Handoff Relay: the target handed to the team, the jet free to go again | the Quick-turn Avionics |
| The Magpie's passive | the mines | the Loiter Bay: loitering munitions wait over a target | the Delay-fuse Bay |
| The Giant Petrel's passive | the bank | the Holding Pattern: unspent rerolls circle until called down | the Ready Stack |
| The Kite's passive, reworked | doubled, flat heat, dark two rounds | Disabled Weapon Regulators, kept: the rework still disables them | |
| The multi-strike gun, if the kind goes | Direct, flat 5 ×4, heat 15 | the Cyclic Cannon: the cyclic rate is a gun's rate of fire | the Rotary Shear |
| The mid-heat gun, if the kind goes | Direct, flat 25, heat 20 | the Transonic Rifle: transonic is the band between subsonic and supersonic, the middle gun (a stock piece may be a rifle; a locked Kestrel piece never is, Ryan, 11 October) | the Bow-shock Rifle |
| The reroll module, if the kind goes | a free reroll of its own die a round | Trim Tabs: the small surfaces a pilot adjusts in flight | the Gimbal Reset |

- Designations, in Kestrel's pattern (the codex's stamped tag, so shown text): K-13 Mk I
  Swing-Wing Strafer, K-15 Mk I Air-Cushion Picket (the Storm Petrel), K-17 Mk I Tilt-Jet
  Spotter (the interceptor), K-19 Mk I Flying-Wing Minelayer (the Magpie), K-21 Mk I
  Ground-Effect Flagship (the Giant Petrel, beside the Puffin's Ground-Effect Escort). The
  Kite keeps K-7 and takes Mk IV with its rework, so its Interceptor parts from the new
  machine's Spotter.
- Words left out: Battery (Wainwright & Sutler's lean word, and the Clydesdale's Battery
  Director), Siphon (main's Heliographic Siphon), Talon (the Arsenal's), Scramble (a foe's
  action), Vectoring (the Buzzard's nacelles vector in its acts), Pathfinder (a BattleTech
  'Mech).

### Ryan's picks (21 October, evening)

> Change the bomber to Lammergeier. Skua is fine too, as is Needletail. Mark down Magpie and
> an Owl (probably snowy owl) as our last two chassis, probably a support engine and stealth
> unit, respectively.
>
> Flechette Pod / St. Elmo’s Regenerator / Fovea Designator / Don't love either of the bomber
> pull names, it can be more technical, something about warping or teleporting / Immelmann
> Booster / Spindrift Salvo / Reheat Uplink
>
> Split-cycle Breech / Storm petrel should reference the fact that it has hard shields, or
> something, used both for defense and for whacking things with. / Quick-turn Avionics Relay /
> Fuse-delayed Bay / Giant Petrel passive: Maverick's Playbook / Keep Kite passive
>
> Designations as you see fit, stock changes as you see fit. I wouldn't lean Expose to
> Kestrel just yet.

Decided:

- **Machines**: the strafer is the Skua; the interceptor the Needletail; the bomber the
  Lammergeier (the bearded vulture, which drops bones from a height to break them: a bomber by
  habit; the English spelling, the German Lämmergeier), the name Magpie moving to the support
  engine.
- **Locks**: the Flechette Pod (the Skua's spray); St. Elmo's Regenerator (the Storm Petrel's
  lure that regens itself; Ryan's); the Fovea Designator (the Needletail's); the Immelmann
  Booster (the Giant Petrel's Rapid lock; Ryan's: the Immelmann turn reverses a fighter's
  course and climbs, as a spent ally comes round to act again); the Spindrift Salvo (its gun);
  the Reheat Uplink (its buff); the Pinion Driver and the Syrinx Drone as named before.
- **Passives**: the Split-cycle Breech (the Skua); the Quick-turn Avionics Relay (the
  Needletail; Ryan's joining of the two); the Fuse-delayed Bay (the Lammergeier; Ryan's turn of
  the delay-fuse); Maverick's Playbook (the Giant Petrel; Ryan's); Disabled Weapon Regulators
  kept (the Kite).
- **Designations** (Claude's, on Ryan's word): K-13 Mk I Swing-Wing Strafer (the Skua), K-15
  Mk I Air-Cushion Picket (the Storm Petrel), K-17 Mk I Tilt-Jet Spotter (the Needletail),
  K-19 Mk I Flying-Wing Minelayer (the Lammergeier), K-21 Mk I Ground-Effect Flagship (the
  Giant Petrel); the Kite K-7 Mk IV with its rework.
- **The stock pieces** (Claude's, on Ryan's word): the Cyclic Cannon, the Transonic Rifle,
  Trim Tabs (the stock holes above).
- **Expose** stays out of Kestrel's lean for now; the leans row is unchanged.
- Flagged to Ryan: Spindrift is also a BattleTech 'Mech. As one word of a component's name it
  passes the reserved list's rule (sharing a word is fine, and the validator reads chassis
  names only), so the Spindrift Salvo stands unless he minds; the Wavetop Launcher is the
  other. Ryan, 21 October: "Spindrift is fine." It stands.

Open, with Claude's new picks (21 October):

| Item | Ryan's steer | Claude's pick | Others |
|---|---|---|---|
| The Lammergeier's pull | more technical, about warping or teleporting | the Lorentz Contractor: length contraction shrinks the space between, so every mine ends in one slot (and it contracts them in) | the Spatial Shunt; the Fold-space Anchor |
| The Storm Petrel's passive | hard shields, used both for defence and for whacking things | Birdstrike Plating: a canopy rated for bird strikes is hardened against them, and here the bird does the striking | the Riot Field (a riot shield blocks and shoves); Hard-field Bumpers |

- Words left out for the pull: Translocator (the Dingo's Combat Translocator), Phase (Aphelion's
  word, and main's Phased), Rift (the enemy's), Tesseract (two Warhammer 40,000 machines),
  Slipspace (Halo's).

- Ryan, 21 October, later: "Lorentz Contractor, Riot Field Generator". Decided: the
  Lammergeier's pull is the Lorentz Contractor, the Storm Petrel's passive the Riot Field
  Generator (his turn of the Riot Field).

## Open for Ryan

Two of the built four are not finished (Ryan's notes on the hangar's Designs tab, 5 November,
folded 7 November), for the design session the to-do names for them:

- **The Giant Petrel**: "marked built, but it is far from completed. Placeholder model,
  unrefined kit."
- **The Needletail**: "marked built, but it is far from completed. Placeholder model,
  unrefined, dull, kit, not worthy of tier 2." Its kit has a brief of its own since 11 November
  (`kestrel_needletail.md`).

The last two slots are their briefs' (`kestrel_magpie.md`, `kestrel_owl.md`), taken up in
another session (Ryan, 21 October: "I'll take up the last 2 chassis in another session").

Done 21 October: the Buzzard's stock (above); the names, the designations and the stock
pieces (the picks above), the Spindrift Salvo kept; Expose left out of the lean (Ryan); the
last two slots marked and briefed.

## What the session hands back

The names into each brief, the bible's Kestrel row, the rules and the content sessions' lines
(done 21 October); the stock pieces in the to-do's stock pass line and the bible's stock-pass
row (done 21 October); this brief retired once the line's briefs have landed.
