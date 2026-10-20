# Brief: the shield-spender (new chassis, direction)

The session designs a Kestrel tier one whose hits spend its own shield for more damage: a
sustained hitter with a real decision on every spend. "The shield-spender" is a working label;
the name and the look are Ryan's.

**Status**: direction (Ryan, 15 October). **Maker**: Kestrel. **Proposed tier**: one. **Read
first**: `docs/briefs/README.md`; `docs/roster_analysis.md` section 8 (Kestrel gap one, the
raider); the bible's shield rule and Kestrel rows; `content/chassis.json`
(puffin, goshawk) and `content/components.json` (backwash_ionizer, laminar_deflector).

## How it came about

- Claude, 14 October (the analysis, section 8): a raider whose weapons may fire its shield, so
  much shield for so much more damage a blow, its shield returning at the field rate out of
  fights, as Kestrel's detachment.
- Ryan, 14 October: "Your raider proposal fights with itself, a unit that spends its defenses
  to deal damage is a risky solo unit. A passive that consumes say, 5 shield on every hit to do
  5 more damage, pushing rapid and multihit weapons (which we have none of and badly need, I
  think), that feels very Kestrel. But that design isn't a detachment unit. What will happen is
  it will get into a fight, spend some shield, maybe kill a guy, and then get stuck in a loop
  where all the shield it raises gets burned before it can spend it on damage."
- Claude withdrew it from the detachment niche; the strafer took that niche.
- Ryan, 15 October: "The Kestrel shield-spender was a good design, just not for that niche. A
  sustained dps with a real gameplay decision. Not a terrible tier 1 either."

## What frames it now

- Under the honest shield rule (decided 14 October) its shield is its hit points, so every
  point spent is a real trade.
- It loops badly alone and shines beside a shielder: the Puffin's ally overshield, any maker's
  ally shield.
- Ryan's sketch pushes Rapid and multi-strike weapons, which the strafer and the stock pass
  also want.

## The session (15 October)

- Claude proposed: Ryan's sketch as the passive (every hit spends up to 5 of its shield for
  that much more damage, per hit, so Rapid and multi-strike pieces spend more for more); the
  decision in which entry is spent, the team's order (an ally's shield before it fires is
  damage, after it is protection) and the intents (what will strike it shows before the
  player acts); the shown number with the bonus in and a shield cost beside the heat;
  overshield as the intended synergy and not too free, since it fades after the enemy's turn
  and so guards that turn's blows; a locked gun of three small strikes, cool.
- Ryan, 15 October: "a really great tier one since it's very straightforward"; the trick is
  telling it from the strafer, since "both of their final results can converge easily -
  multi-hit flat damage stacking", so it "needs a hook to diversify its options away from just
  multi-hit to blast that shield". No multi-strike lock: "its completing the build and the
  unit needs nothing but that and fill the rest of its hardpoints with shields."
- Claude, 15 October, the hook: the convergence comes from "per hit" (a bonus per hit is a flat
  on-hit, which the strafer doubles), so change what scales the burn rather than add beside
  it: its weapons take their heat from its shield instead of its gauge and hit harder by as
  much, once a spend as heat is paid, so multi-hit gains nothing. Kestrel's three tier ones
  then want three kinds of weapon: the Sparrowhawk cold guns (it doubles heat), the strafer
  many hits, this one hot guns (Aphelion's and the Arsenal's hot pieces, where the Sparrowhawk
  pulls Minerva's and Wainwright & Sutler's kinetics). The decision moves onto the die with no
  gesture: a hot entry burns shield for a big hit, a cold one burns nothing. Routes in: every
  ally shield, and the Peak's Scorched (a stack makes its weapons 5 hotter: 5 more burnt, 5
  more dealt). Holes: it changes the sketch's 5 a hit; while its shield stands its gauge
  hardly moves, so vents are nearly dead on it (only Burning heats it), a direction refused;
  the stock pass's heat prices set its whole economy; a weapon hotter than the shield left
  pays the rest as heat and gains only what the shield paid. The lock: never a big hot gun,
  which would complete the build; Claude's lean, once the hook is settled, a cold gun whose
  hits regain shield, so the die always carries both halves of the decision, reload or burn.
  Bench: 5 a spend in place of 5 a hit (ends the convergence but adds no appetite); the burn
  sized by the blow (the Sparrowhawk's bargain at another price); a locked shield dump (the
  Goshawk's vents-all in shield, and the build would be the dump and shields).

- Ryan, 15 October, the second round: "the multi-hit part doesn't make sense with that
  description. Instead, 'While it has shield, consumes its own shield instead of generating
  heat. After firing a weapon, zap the target for the amount of shield consumed.' The zap would
  be wasted on a kill, but the shield still consumed, and that is correct." No gun as the lock
  ("then its just gun on gun"); instead: "Buff, self or ally, give target +X shield regen for Y
  turns (numbers tbd). Itself is probably the best target, but if it has a friend shielding it,
  then it can lend the buff to the friend instead. And its a really good reason to stop
  shooting for a turn."
- Claude, 15 October, reading it: a weapon hotter than the shield left pays what the shield
  holds and the rest as heat, the zap being what the shield paid; the zap is a blow of its own
  after the weapon's strikes, plain (no keyword, no buff added), so it loses the target's
  armour; since a kill wastes it, a hot gun wants a foe it will not finish, which makes the
  target a choice. The regen: at each round's start, as the Goshawk's, up to the maximum;
  whether a second cast stacks, as every status does, or only renews the count; and it takes
  in-fight regen past the Goshawk, whose content note calls its regen the game's first, kept
  safe on one chassis (one target at a time, so never shield in bulk).

- Ryan, 16 October: the regen was meant to wear off after a few turns, "so it could just be a
  refresh. How dangerous is stacking?" For the zap: a plain blow, one that pierces armour, a
  ping on a random foe, or a random ping that also Shocks "to set up its next hit"; "Not sure
  what opens more build options."
- Claude, 16 October: renew, never stack. Stacked, a regen recast every round grows to as many
  stacks as it lasts rounds (three rounds, three stacks), a heal that triples while it is kept
  up, lent to a tank, and doubled by a second shield-spender; renewing caps it at one regen a
  target however many cast it, and a recast early only wastes the rounds left. (First argued
  from the engine's old stacking, which pushed every stack to the newest expiry and so ramped
  without end: a bug, fixed the same day.) The zap: Shock on its own target opens the most builds,
  since it makes a state other pieces read (the Sparrowhawk's four-times blow, any big single
  blow, the Paradox meter, the Susceptibility Tensor), keeps the choice in the aim and keeps the
  waste on a kill (no zap, no Shock); to watch, its own next hot shot at that foe lands double,
  near the Sparrowhawk's bargain, and it is a second Shock setter at tier one beside the
  Dingo. Armour-piercing gives the sharpest identity (the armour-cracker, the strafer's
  opposite) and the fewest new builds. The random ping is the boiler's blast again (a random
  foe hit for the heat spent) and, beside the strafer's spray, a second random-target tier one
  in one maker.

- Ryan, 16 October, later: renewal without stacking is the right shape, "or it risks becoming a
  support"; the engine's stacking is a bug, timed stacks to decay from when they started (fixed
  in the engine the same day). Shock on the zap's target "makes no sense to me, because you've
  already chunked the guy for your weapon plus your shield", and a guaranteed Shock every round
  riding on damage "seems cheesy". The random zap is no repeat of the boiler, rewarded for a
  non-combat action, or of the strafer, a locked piece: "the only thing they have in common is
  random, their contexts are very different."
- Claude, 16 October: the zap as a random ping, any foe standing with its target among them, so
  a lone boss still takes it and a kill never wastes it: the soft area a sustained hitter
  wants, finishing stragglers wherever they stand. Plain is the zap with no hook;
  armour-piercing the sharper single-target identity.

## The proposal for the go (Claude, 18 October)

Claude's proposal, in chat first; every number a placeholder, the name and the look Ryan's.

- **Shape.** Kestrel, tier one, a medium hovercraft on big boosters, move 40 (the 40 club):
  the one Kestrel tier one that is not a fast jet, so the tender's Kestrel deal varies on the
  map as it does on the die; a flyer if Ryan's silhouette is one. Hull 70, shield 80 (its
  shield is its gauge, so it carries the biggest one in the roster, and under the honest
  shield rule every point of it is hit points it chooses to burn), field recharge 30
  (Kestrel's), heat maximum 60, cooling 5 (idle while the shield stands, Burning aside),
  armour 0; four hardpoints beside the lock, a d5; two module slots.
- **The passive**, Ryan's words of 15 and 17 October as the codex would print them: while it
  has shield, its weapons burn shield in place of heat, every point a spend would add, a
  Scorched machine's extra included; a weapon hotter than the shield left burns what the
  shield holds and the rest reaches the gauge. After the weapon's strikes the target takes a
  zap of what the shield paid: a plain blow, no keyword, its armour off, lost on a kill.
- **The zap's shape: on the target**, Ryan's first wording and the waste on a kill he called
  correct, in place of the random ping Claude leaned to on 16 October. The reasons: the waste
  is the decision (a hot gun wants a foe it will not finish, and the drag shows whether the
  blow kills), where a ping that always lands somewhere deletes it; a ping on any foe standing
  hands a Direct gun's zap the back rank, a reach nobody paid for; against fodder a ping turns
  a hot shot into a two-kill spend, which is the strafer's ground, where the target zap keeps
  this machine the big-foe hitter that pays in shield, so Kestrel's two new tier ones part
  cleanly (trash, the big one); and it is one random-foe rule fewer beside the spray and
  Chain's rework. The zap is part of the spend: it lands after the strikes and before the
  spend's riders, so a Shock weapon's zap never spends the shock its strikes leave, as the
  strikes never do. Bench: the random ping (any foe standing, the target among them; back if
  the waste proves too harsh in play) and the armour-piercing zap (the sharpest identity, the
  fewest builds, a second armour rule to learn).
- **The lock, the regen buff**: self or ally, a full action (no Rapid: Ryan's "really good
  reason to stop shooting for a turn"), working name Regenerating, Ryan's to move: the target
  regains 10 shield at the start of each round for three rounds, up to its maximum. It renews
  and never stacks (decided 16 October): a recast sets the count back to three, and two
  casters are one regen. On itself 10 a round is a 10-heat gun fired free every round or a
  Railgun's 40 every four; lent to a tank or to the Puffin it is the game's second in-fight
  regen after the Goshawk's, one target at a time, never shield in bulk.
- **Stock**, stand-ins until the stock pass, hot and cold both and no vent (Ryan, 17
  October): the Laser Carbine (a small burn), the Overclocked Railgun (the big hot shot: 40
  shield for 50 and a zap of 40), the Twin Autoguns (cold: burns nothing, the entry to fire
  when the shield must stand), the Laminar Deflector (shield 20 with Rapid: reload and act).
- **The die.** The heat slot, bottom left, is where the burn shows: while the shield covers
  the spend the entry reads the burn there with the shield's glyph and its number (structure,
  never hue alone), and reads +N HEAT again for whatever the shield cannot pay. Since the
  burn is the zap, one number says both, and the hold's line reads "burns 10 shield, zaps the
  target for 10". Dragged over a foe the number shows what that foe takes, the blow and the
  zap with its armour off each, as two numbers joined ("10+5"), since the zap is a blow of its
  own and the rule is that the die shows one blow. Judged on the phone.
- **The arithmetic** at today's heat prices (mean a spend on the target; the pool 80):

  | Weapon | Burns and zaps | Target takes, armour 0 / 5 | Spends of a full pool | Regen refills one every |
  |---|---|---|---|---|
  | Laser Carbine 10 flat, heat 5 | 5 | 15 / 5 | 16 | half a round |
  | Slugthrower 15–30, heat 10 | 10 | 32.5 / 22.5 | 8 | a round |
  | Overclocked Railgun 50, heat 40 | 40 | 90 / 80 | 2 | four rounds |
  | Twin Autoguns 5–15, heat 0 | 0 | 10 / 5 | never | - |

  The read: with today's numbers the basics barely burn, so the identity shows with basics
  alone but small; the stock pass's heat (a hot kit overheats by its third round) is what
  sizes the decision, so its feel is read after the stock pass, like the boiler's, though its
  design waits on nothing. Multi-strike gains nothing, since heat is paid once a spend, which
  is the hook that parts it from the strafer.
- **Engine work.** A passive effect at the spend: the heat the pipeline returns is taken
  from the shield before the gauge, the zap a plain blow through the target's damage taken
  and armour after the strikes; the die's heat read (`shown_face`) becoming a burn while the
  shield stands; the regen as a status, likely cheap, since a status may carry the round-start
  shield effect the Goshawk's passive already runs and the renewing policy exists; the bot
  reading shield spent as a cost (its `shield_score` counts hull saved this round) and the
  zap as damage; each tested with synthetic passives. Its runner row lies until the honest
  shield rule is built (the to-do's shield-rule line): under today's whole-block rule a
  shield burnt to 1 still blocks a whole blow, so the burn costs nothing it should.
- **What the runner reads.** Alone (the loop: whether it burns before it spends); beside the
  Puffin (the overshield as the magazine, Kestrel's locked pieces working together); beside a
  tank (the regen lent out); the share of its spends that burn against the share that hold.

## The second round (18 October)

- Ryan, 18 October, on the proposal: "Propose some alternative kits for the shield burner to
  help give it a unique identity from the other Kestrel damage dealers, and/or if the other
  damage dealers' identities need to be sharpened. Don't mind moving things around, even
  'locked' items like the Sparrow and goshawk, to improve the roster as a whole."
- Claude, 18 October, the overlap named: the Goshawk turns heat into shield and the burner
  shield into damage, two converters on the same two gauges, both pulling hot guns, where the
  Sparrowhawk pulls cold guns and the strafer rider pieces; the burner also loops alone (Ryan,
  14 October), which is the tier-two shape by the sort. Three kits, the capacitor the lean:
  1. **The capacitor: overshield is its ammunition.** Passive: shield it raises on itself may
     pass its maximum, up to its maximum again, and the excess holds from round to round; a
     weapon it fires adds the excess to the blow and spends it. The charge is a shield until
     it is fired, and the enemy's blows eat it first, so each round asks whether to fire it
     or hold it as plate. Lock, the lean: a converter gun (Direct, flat 10, heat 10) that
     fires the charge at double; bench: a loader (a self shield of 30 with Overshield and
     Rapid, charge and fire in one round when it shows). Stock stand-ins: the Laminar
     Deflector (its Rapid is the loader: shield, act, fire), the Laser Carbine, the Twin
     Autoguns, a plain shield. It reads a state nobody reads, overshield, the Puffin's own
     product, so Kestrel's escort gets a Kestrel hitter to feed (the Ionizer loads it with 30
     and vents it); it pulls shields of every maker (the Halo Shield, the Blast Door, the
     Corona Shield, the Oblation Ward's 40 for 10 hull) and any gun, cold ones included; it
     works alone with basics (a shield round, a gun round). Holes: a charged Spread blow
     carries the charge to the neighbours, a build at the charge's price; it is a bank-and-
     spend shape like the Goshawk's heat and the Badger's hopper, with the opposite valence
     (a bank of safety that pays damage, where the Goshawk's is a danger that pays shield);
     Misharu's Vigil Pavise would no longer be the only self overshield, its payoff bait where
     this one's is ammunition; the overshield fade is broken on this chassis as a one-off,
     capped at its maximum; the bot must value a charge as damage.
  2. **The interceptor: its first weapon each round is Rapid.** The decision is the order of
     two spends (a setup then a hit, a hit then a shield), the second entry the die's; the
     price two spends' heat a round, so vents are real on it, and a small die. Lock: a
     designator (0 damage, Direct, cool, Shock), so its own two passes are paint then fire.
     It produces an extra skirmish action, which nothing has. Holes: tempo is the line frame's
     claim (Ryan, 14 October: the most tempo-oriented damage dealer); "twice" is the strafer's
     word too, strikes there and spends here; two spends at tier one wants glass numbers; the
     Paradox and riders double a round.
  3. **The glass gun**, the design as proposed on 18 October: the sharpest decision of the
     three (hit points for damage), the Goshawk's axis, and the loop alone; if kept, its
     better home is tier two beside the Puffin, where the machines only good together belong,
     Kestrel's fourth tier two free in the 4-4-2 count.
  The other damage dealers hold: the Sparrowhawk (the model of a double-edged niche
  definer), the Goshawk (the cleanest loop in the roster) and the strafer (count). No lock
  moves. The one wart, the Puffin's vent fighting the Goshawk's regen, is answered by the
  capacitor without a move. One content fix: the Goshawk's niche word says ramping damage
  and its passive is sustain. One stock move: the Laminar Deflector into the capacitor's
  stand-ins, off the Sparrowhawk's as the stock pass already has it. Bench, one line each: a
  kill regains shield (devour's pattern on the strafer's ground); a team reroll spent on its
  die doubles its blow (a new price nobody uses, but it taxes the die's steering); a streak
  of rounds fired (a ramp, the easy design).

## The third round (18 October)

- Ryan, 18 October: "Kit 2 is interesting. Again, in a roster of up to 50 units, there's going
  to be role and mechanic overlap. The trick is making the shape of each different enough that
  they create a unique enough feeling. That said, first fire rapid is a great tier 1 design,
  but I don't want to give up on the shield-centric design. The thing we haven't tapped is a
  shield that actually does things. Shield armour is one, even though that feels more Minerva,
  but it could be a way to give Kestrel a body. Shoot with the shield for damage or keep it up
  when you need to take a few hits for the team. Not a true tank by any means, but a
  conditional off-tank option. My other idea, which could also be a whole other chassis too,
  was the idea of a mode-shifter that changes the properties of its shield somehow, maybe with
  on-hit effects or altering its defensive properties somehow, or offering a buff while it
  still holds." Also: "What was the glass gun?" (Claude's label for the design as proposed on
  18 October, the burn with the zap; no more labels); reroll effects are Wainwright & Sutler's
  to explore, not Kestrel's; a shield-on-kill design he would try with zero or negative field
  recharge and the shield recharging from damage dealt, not kills, unsure what makes it worth
  the stress; the Sparrowhawk should be riskier and move to tier two ("not sure, but that's how
  I interpret the data"); the capital ship need not be assault size, the bomber could be it,
  and what is Kestrel's other tier three?
- Claude, 18 October, the shield-centric tier one as Ryan framed it, the shield dual-use:
  while its shield stands every blow on it loses 5 (an armoured shield, "shields are never
  armoured" bent as a one-off), and its weapons burn shield in place of heat with the zap of
  the burn on the target (the 18 October proposal's half kept). The tension is the point: a
  hot gun thins the plate, a cold gun keeps it. The hole in the off-tank half: the foes' exposed
  aim picks the machine whose hull its blows would reach plus half the shield they would
  break, so a plated shield makes them look elsewhere, and "take a few hits for the team"
  needs a draw. The lock, the lean: a flare, Indirect, no damage, Lure with Spread, heat 5, so
  the draw is a choice on the die and the flare's heat burns a little of the very shield it
  raises the pack against; the regen buff on the bench as the lock if Ryan would rather the
  draw come from a stock lure (the Proximity Klaxon as the cross-maker route in). The frame as
  proposed: a medium hovercraft at 40, hull 70, shield 80, a d5.
- Claude, 18 October, the mode-shifter as Kestrel's second tier three, the lean: three locked
  shields, each a tuning that holds while its shield stands and is replaced by the next raised
  (the form follows the die, as the Armadillo's does): Plate (blows on its shield land at
  half), Lance (its next weapon adds its whole shield to the blow and spends it), Aura (while
  it holds, every ally's blows gain 5); four hardpoints beside them, a d7, any maker's shield
  topping up whichever tuning holds. The rule it bends: a shield absorbs its number and does
  nothing else; its floor a shieldless d7, its ceiling the right tuning each round. Bench: a
  reactive tuning (a foe striking its shield is Shocked; retaliation elsewhere needs a fantasy
  of its own, the bible's thorns row). The alternative tier three, the chain: Rapid switches
  nothing off on it and vents do nothing on it, so its Rapid pieces of every maker chain while
  its heat lasts, an alpha strike then a hot brick; its hole, the Rapid vent Ryan is wary of,
  answered by the dead vents. The bomber as the capital ship either way, heavy.
- Claude, 18 October, the Sparrowhawk: moved to `kestrel_sparrowhawk.md` (its brief since 19
  October), with Ryan's lean of the day.
- Claude, 18 October, the shield from damage dealt with no field recharge: its interest is on
  the map, a machine that must fight every turn to stay shielded, which the map cannot yet make
  a decision (the four-machines row sends the whole roster to one front); benched as a Kestrel
  tier two to revisit after the foes' fresh start, Ryan's version recorded.

## The fourth round (19 October)

- Ryan, 19 October: "If the shield-burner is leaning towards off-tank, then I'd like it to
  take a tier 1 slot if possible to ease the pressure off Minerva (seems like W&S is pure
  offense and utility, aphelion tbd). That means that it will need a lure or something baked
  in. it could be attached to the regen buff, luring a foe while granting itself regen, and we
  remove the ally-targeting, meaning the buff can be stronger (or stackable). It works as a
  package, actually, now we just need to refine it." On shapes: he never gave Kestrel specific
  shapes, only "things other than dogfighters"; the bomber is a bomber, another hovercraft
  makes sense, and the exposed-rotor helicopter sent to Wainwright & Sutler on 12 October could
  come here. The mode-shifter reads to him as an Aphelion tier three, an all-in aura support
  with shifting auras; he asks for other Kestrel capstone or flagship ideas, "a giant, mean
  looking, fast-looking-but-slow mobile gun platform" allowed if the gimmick is Kestrel's.
  Reroll-based effects are back on Kestrel's table, since Wainwright & Sutler's ten filled
  without effort: "it actually fits, and means we can push Kestrel way into the
  risk-versus-reward space, like a real maverick pilot." The Sparrowhawk at tier two: "the
  whole gimmick is that its a flying accident waiting to happen, scoring kills by the seat of
  its pants in order to stay alive", pushed past double-damage-double-heat, "which by todays
  standards feels thin and abusable"; kills scoring shield past the cap, decaying a turn, with
  a hull as thin as paper, or as far as kills granting invulnerability, "but there's danger
  there"; what niche it fills under the latest skirmish and battlefield decisions.
- Claude, 19 October, the package refined (tier one, the off-tank, in Ryan's frame). The
  passive as the third round left it: while its shield stands every blow on it loses 5, and
  its weapons burn shield in place of heat with the zap of the burn on the target. The lock:
  a weapon of no damage, Indirect, heat 0, spent on one foe: that foe is Lured for the round
  and the spender gains Regenerating, 10 shield at the start of each round for three rounds,
  stacking (timed stacks keep their own end, so two casts are 20 a round until the first runs
  out); self only, never Rapid, no cooldown, the die its brake. The loop: lure and regen, the
  plate takes the blow, the regen refills it, a hot gun burns it when the damage is wanted.
  Shown: a weapon glyph with the Lure chip and the star, the hold reading the self regen. The
  order the regen lands in matters: the lured blow lands this enemy turn, the first 10 at the
  next round's start. Frame: a medium hovercraft at 40, hull 70, shield 80, four hardpoints
  beside the lock; stand-ins the Laser Carbine, the Overclocked Railgun, the Twin Autoguns, a
  plain shield. The tender gains a body from a second maker. Holes: the Armadillo's form
  changer is a tier-one off-tank with a locked lure too (seal, Braced and a heat clock there;
  plate, regen and the burn here: the shapes differ, Ryan's rule of the third round); a lure
  onto a plated shield with stacking regen may wall trash, which the runner reads on the
  formation cells; the engine needs a weapon's rider on its own spender (new, small), the regen
  as a status (a round-start shield effect the Goshawk already fires), and the plate as a
  damage-taken add while the shield stands (a new condition). Ryan's regen was lent to allies
  on 16 October and renewed for that reason; self only, it stacks as he says.
- Claude, 19 October, on shapes: "hovercraft on big boosters" is the makers table's own line
  (Kestrel: small and mid flyers and hovercraft on big boosters, all the fast jets, nothing
  big) and the Puffin is the one built, a ground-effect escort. Shapes beyond the dogfighter,
  each with a reading: the attack jet with a gun run (the strafer); the flying wing (the
  bomber); the ground-effect hovercraft (the off-tank, a skirted body with a shield prow); the
  exposed-rotor helicopter, free since Wainwright & Sutler's ten filled (the interceptor's two
  passes, or the off-tank as a flying tank); the tilt-jet with swinging nacelles (the
  interceptor); the ekranoplan, a giant ground-effect plane with a missile battery on its
  back, hover, slow on rough ground and fast on water (the capstone: fast-looking, slow); the
  gunship, a big slow airframe with its guns down one side (the capstone as a flyer); the
  airship on boosters; the jet car on wheels, Kestrel's one ground machine for the Steppe.
  Silhouettes are Ryan's; the list is for matching.
- Claude, 19 October, the capstone: moved to `kestrel_gun_platform.md` (its brief since 19
  October). The mode-shifter goes to Aphelion's bench as an aura support.
- Claude, 19 October, the Sparrowhawk's niche at tier two: moved to `kestrel_sparrowhawk.md`.

## The fifth round (19 October)

- Ryan, 19 October: "The point of adding another tier one lure is to take the pressure off of
  making the armadillo a must-pick. Aphelion also will need a defensive tier 1 to balance
  things out even more." His two questions of the day, the platform's kit and the
  Sparrowhawk's cool guns, are answered in their briefs.
- Claude, 19 October: recorded as the reason in the briefs README (a tier-one body from more
  than one maker) and the Aphelion defensive tier one as a line for Aphelion's session.

## The sixth round: the line review (Claude, 20 October)

Under the action economy's direction the off-tank's lock is the model combined entry (two
effects on one spend, a lure that regens itself) and is never Rapid; the package stands as
Ryan's. The review read the plate's arithmetic against the foes as they are: a blow of 5 past
the plate is nothing, of 10 is 5, of 20 is 15, of 30 is 25, so while its shield stands it halves
the packs that strike for 10 (wolves, gels, mandragoras, needlers, cockatrices, ghosts: six of
the eighteen wildlife) and shrugs their 5s, which with a lure and a stacking regen of 10 a
round is a wall against those packs, and a tank's job; against a swarm it is no wall (six
goblins strike 30 each with their swarm, 25 past the plate, 150 a round onto a lured shield of
80), nor against the big foes (a Sandworm's 40 is 35). The lever if the wall reads wrong in
play: the plate's number (3, by the scales question) before the regen's stacking (renew). Its
stock wants a step between the Carbine's 5 heat and the Railgun's 40, a mid-heat Kestrel gun
the line review asks of the stock pass (flat 25 at 20: 20 shield burnt for 20 more and a zap of
20), and the Railgun kept as its big hot shot. The vent-dead hole stands as a direction refused.

## The kit, written out (Claude, 20 October)

Ryan's package of 19 October, whole; every number a placeholder, the name and the look Ryan's,
the stock by kind (Ryan, 20 October: the stock pieces are placeholders until the stock pass).

**The frame.** A medium hovercraft on big boosters at move 40, the one Kestrel tier one that is
not a fast jet (or the exposed-rotor helicopter as a flying tank, if Ryan's silhouette is
one). Hull 70, shield 80 (its shield is its gauge and its plate, so the roster's biggest),
field recharge 30, heat maximum 60, cooling 5, armour 0. Four hardpoints beside the lock, a
d5; two module slots.

**The passive**, as the codex would print it (Ryan's words of 15, 17 and 18 October): while
its shield stands, every blow on it loses 5, and its weapons burn shield in place of heat:
every point a spend would add comes off the shield (a Scorched machine's extra included), and
a weapon hotter than the shield left burns what the shield holds and the rest reaches the
gauge. After the weapon's strikes the target takes a zap of what the shield paid, a plain blow
with its armour off, lost on a kill.

**The lock, the lure that regens itself** (Ryan, 19 October): a weapon of no damage,
Indirect, heat 0, spent on one foe. That foe is Lured for the round, and this machine gains
Regenerating: 10 shield at the start of each round for three rounds, stacking (timed stacks
keep their own end, so two casts are 20 a round until the first runs out). Self only, never
Rapid, no cooldown; the die is its brake. Shown as a weapon glyph with the Lure chip and the
star; the hold reads the self regen.

**The die.**

| Entry | Piece | What it is for |
|---|---|---|
| I | the lure that regens itself: Indirect, no damage, heat 0 | the draw and the refill |
| II | a big hot flat gun | the burn's big shot |
| III | a mid-heat gun (a stock hole: nothing sits between the warm guns and the big hot one today) | the middle burn |
| IV | a cold rolled gun | burns nothing: fired when the shield must stand |
| V | a shield (self) | reload |

No vent: with no weapon heat reaching the gauge a vent is nearly a blank (Burning alone heats
it), and Ryan agreed (17 October).

**The round as played.** The lure showing, spend it on the foe whose blows you want, and the
regen starts at the next round's start (the lured blow lands this enemy turn, the first 10
next round). A hot gun showing, burn its heat off the shield for the same again as a zap, on a
foe it will not finish, since a kill wastes the zap. The cold gun when the shield must hold
for the enemy's turn. The shield to reload. On the die the heat slot reads the burn with the
shield's glyph while the shield covers it, and +N HEAT again for the rest; dragged over a foe,
two numbers joined ("25+20"), the blow and the zap, each with its armour off.

**The arithmetic** (today's heat prices; the pool 80, the regen 10 a round a stack).

| Weapon | Burns and zaps | The target takes, armour 0 / 5 | Spends of a full pool | A regen stack refills one in |
|---|---|---|---|---|
| a warm flat 10, heat 5 | 5 | 15 / 5 | 16 | half a round |
| a mid-heat flat 25, heat 20 | 20 | 45 / 35 | 4 | two rounds |
| a big hot flat 50, heat 40 | 40 | 90 / 80 | 2 | four rounds |
| a cold rolled 5–15, heat 0 | 0 | 10 / 5 | never | - |

The plate: a blow of 5 is nothing, 10 is 5, 20 is 15, 30 is 25, 40 is 35. So with a lure and
a stack of regen it walls the packs that strike for 10 (wolves, gels, mandragoras, needlers,
cockatrices, ghosts) and is no wall against a swarm (six goblins strike 30 each with their
swarm, 150 a round past the plate onto 80) or a big foe. The lever if the wall reads wrong in
play: the plate's number before the regen's stacking.

**With the team.** It wants every ally shield (the Puffin's overshield is its magazine), hot
guns of every maker and the Peak's Scorched (5 hotter: 5 more burnt, 5 more zapped). It gives
the lure, a body from a second maker, and its zaps.

**Engine.** At the spend, the heat the pipeline returns taken from the shield before the gauge
and the zap a plain blow through the target's damage taken and armour after the strikes; the
die's heat read becoming a burn while the shield stands; a weapon's rider on its own spender
(new, small) for the lock; the regen as a status (a round-start shield effect the Goshawk's
passive already fires); the plate as a damage-taken add while the shield stands (a new
condition); the bot reading shield spent as a cost and the zap as damage; each tested with
synthetic passives. Its runner row lies until the honest shield rule is built.


1. The package's numbers (the plate, the regen's 10 for three rounds stacking, the lure's
   reach), its frame (a hovercraft, or the exposed-rotor helicopter as a flying tank), and
   Ryan's go. The capacitor of the second round stays on the bench (overshield as ammunition).
2. The interceptor has a brief of its own since 20 October (`kestrel_interceptor.md`).

## Holes already raised

- Alone it burns its shield before it can spend it on damage (Ryan's loop), which is fine for a
  sustained hitter that fights beside a team, and a reason it is not the detachment.
- A shield spent is also an injury risked, since a blow on bare hull rolls the die; the entry
  should show the cost.
- The review (Claude, 16 October) raised Scorched inverting on it: a stack makes its weapons run
  5 hotter, under the passive 5 more shield burnt and 5 more zapped, so the Peak's scorchers
  make it a glass cannon rather than choking it. Ryan, 17 October: "flipping the shield and heat
  interactions on its head is kind of the shield-spender's whole deal": every point of heat its
  weapons would generate burns shield instead, Scorched's included.
- Its die carries hot and cold entries both, and its stock no vent (Ryan, 17 October, agreed:
  "sometimes you might actually want to not explode your whole shield"; with no weapon heat
  reaching the gauge a vent is nearly a blank, Burning alone heating it).
- The regen renews and never stacks: a stacking policy the engine lacked until 17 October
  (Ryan: "it should be supported, since that's a pretty common thing for a powerful or
  non-number-related buff to do"), now read off the status's definition (add, renew or never;
  the bible's section 5).
- The zap's ping (any foe standing, its target included), Chain's ping (Claude's lean, any other
  foe) and the strafer's spray (among the foes in reach, the same one again) are three rules for
  a random foe. Ryan, 17 October: neither the zap nor Chain is final and the spray is a locked
  unique, so the count is no worry now, "but point taken".
- The honest shield rule is decided and not built (Claude, 18 October): until it lands, a
  shield burnt down to a point still blocks a whole blow, so a runner row on this machine reads
  the old rule's free block, not the burn's price. Its engine follows the shield rule's.
- The zap on a Guarded core (a boss in parts) deals nothing, as every blow on it does; the zap
  carries no keyword, so it never spills, chains, burns or shocks, and Chain's repeat pays its
  heat again and so burns and zaps again on the new target (Claude, 18 October).

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Kestrel row moved from withdrawn to decided,
content planned, and this brief retired.
