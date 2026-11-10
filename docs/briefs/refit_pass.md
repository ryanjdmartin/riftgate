# The refit pass: the brief

<!-- hangar: {"kind": "rule", "maker": null, "tier": null, "status": "direction", "slot": false, "name": "the refit pass"} -->

The battle's resource model remade from Ryan's play of Phase 2 and the formation pass's reads, 9
November: shields and vents leave the die, a component is a weapon or equipment, the shield is
innate and regenerates, cooling is passive, the hold is the heat decision, component destruction
is off, and the formation pass folds in, its grids re-cut under the new model. The direction is
his and set; the numbers, the reads and the content are this pass's work, and no content moves
before the reads say where the numbers sit and he has played them: the injury rule is off in the
game, the model is a what-if for the runners and a trial in a debug build, and its first reads
are in (section 5). Read `docs/briefs/README.md`'s
How a session runs first; the formation pass's proposal (`docs/formation_proposal.md`) and its
reads (`docs/measurements.md`, 9 November) are the records this stands on.

## 1. Where it stands

- Ryan played Phase 2 on the phone (9 November; the status holds the play in his words): every
  fight survival, the tank needed rather than wanted, Floraison impossible, the Armadillo too
  strong for tier one (the Polar Bear since his kit for it of the same day), the locked pieces chased, the Lance and the Skua's sweep wanted every
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

- **Component destruction off, completely**: "I'm fine disabling component destruction entirely to
  test these points. It was placed to offer a balancing lever between tanks and dps, an issue that
  clearly no longer exists"; asked whether the injury's in-fight break stays: "Lets turn destruction
  off completely, for now, and see where that gets us." So the injury rule is switched off whole
  for the test, the break of the entry showing with the loss after the battle, its code kept behind
  the switch until the reads say.
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
- **The leans accepted, and the send-back** (9 November): of the open list's leans (the basics
  at heat one and the cooling by chassis with a read of an offset; which shield pieces become
  which equipment; the pushers' hull budget by kind; the formation proposal's remaining leans),
  "Your leans are good, but might as well rename the adjusted components when they need to to make
  sense. Doesn't matter to what. Canopy was always a little lame, though." And, with main merged
  in first: "send any machine or component or module that clearly doesn't work in the new system
  (i.e. scorpion, for one), back to design." Section 6 is that audit.
- **After the first reads, 10 November**: the wall strike, "Strike following the threat rating
  makes a lot of sense, otherwise a single giant dude that composes a threat 3 on his own could
  be ignored. It also makes elites make more sense too", and of a worn pack's share, "Your lean
  for the pack survival is fine" (section 4's first hole, answered and built the same day); of
  the trial, "I guess I find it hard to judge a new game backbone against old content that wasn't
  made for it. But I will at least feel it out"; breach, "Let's ignore breach for now, it's useless to evaluate at this junction", so
  section 7's breach question is parked and nothing asks it of him until the model's numbers
  stand; and a team Ward or a team Barrier "probably ok", the Swallowtail a possible home, not
  decided (its brief has his words).
- **The refit's direction, before the model was reached**: "Enemy HP is probably too high, or
  player damage is too low. I'd rather lower enemy HP slightly, and boost synergy pieces to
  increase damage instead of just raw numbers. However, I want to judge the new formations
  before applying the refit based on this." The model came first in the chat; the numbers follow
  it, by band: the bosses and the massives first, where his play broke, the fodder's blows second.

## 3. The model

1. **The shield is innate and regenerates.** Every chassis keeps its shield gauge, full as a fight
   opens, and regains `shield_regen` at the start of every round (the slot is built, zero
   everywhere: `content/chassis.json`, `sim/content_db.gd`). The regen is a flat number a chassis,
   always (Ryan, 9 November: "Whatever the initial shield regen number, I would always implement
   it as a flat number per-chassis. Allows for tuning, and for shield-regen buffs to still make
   sense. For that reason I would not go for full-shield regen every round"), by role and by maker
   (Kestrel's shields, Minerva's armour); the first numbers are placeholders read by the runner
   before they are set, half the gauge rounded up the lean (the Kite eight, the Badger four),
   beside a flat two and a flat four.
2. **No pure recovery face on the die.** A component is a weapon or equipment. Shield faces and
   vent faces leave the die: recovery is passive, the regen for the shield and cooling for the
   heat, and every face acts on the fight. A vent that converts heat into something is
   equipment, a payoff, and stays; a vent that only sheds heat goes.
3. **Heat is a pace.** Hot faces cost it, cooling pays it back each round, the overheat is the
   wall, and the active decision is the hold: fire the cold face, keep the hot one for the round
   that needs it, or pass and cool. The prices and the cooling numbers are where heat is felt,
   so the heat session's question (the prices on every face, the basics included) folds into
   this pass; passive cooling is the recovery, not the lever to cut. Every chassis cools, so the
   two at zero today change: the Stingray (its Exothermic Suite wants heat and a vent face was its
   brake; with no vent faces it cools one a round like the rest, its Lance untouched) and the
   Whip Scorpion, which is back in design whole (nothing cools it but its vents, which are its
   guns: section 6).
4. **The defensive tools on the die are targeted statuses.** Armoured against many small blows,
   Barrier against one big one, Ward against the riders; the lure stays the tank's control. The
   three pieces exist already at tier one, in no stock, which is why no starting die has met them
   (a tier-one chassis stocks tier zero only): the Blast Door (a Barrier), the Shoring Jack
   (Armoured 2 for the round) and the Decoherence Veil (a Ward), each on itself or an ally. The
   basics gain the two a stock die needs, an answer to the telegraph and one to the swarm: the
   Halo becomes the Barrier basic, Aphelion's hard light and its one basic, and the Shoring Jack
   comes down to tier zero in the Canopy's place, Minerva's (section 6).
5. **Component destruction off, completely.** No injury: a blow below the threshold breaks nothing
   and nothing is destroyed, a switch for now, the code kept. The injury row's purpose (asymmetric
   balancing between tank and glass cannon) is served by the model instead.
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
   grows). The Marsh's giants carry none today and are the first defect. The first reads make it
   more than a guard: a block trades rounds for hull, and only a threat that rises makes a round
   cost anything, so this point is what lets aggression pay (section 5's fifth point).

## 4. What the formation pass hands in, and the roles

The proposal stands as the grids' first cut (`docs/formation_proposal.md`; its grids as code in
`tools/formation_proposal.py`, which writes them to a scratch worktree for the reads). Two things
re-cut it: the model (the pushers measured by hull lost at three under the regen, the hunters,
elites and bosses keeping survival), and his point on the makeups, which changes who stands in a
flanker.

**Ryan, 9 November, on the makeups**, asked whether the units of pushers, flankers and hunters
are exclusive: "My point about the formation makeups is twofold: 1) player expectation. If a
hunter pack is coming for me, and its wolves and goblins, I'm like 'what are these goblins doing
here.' A pack of wolves and things that keep up with the wolves makes sense. Which leads into 2)
Tuning. If goblins are primarily pushers, then they can be tuned to fight against 3. That same
goblin in a flanker pack is fighting a completely different player composition (probably), so
that means its identity needs to be less sharp. Case in point, right now goblins deal damage per
other goblin in the formation. That's deadly in a formation with 3 or 4 goblins, and lame in a
flanker formation with 1 or 2. I'm not saying we can't cross lines between battlefield roles,
just that I don't want it to come across as lazy, nor encourage lazy designs that are just kind
of generally-threatening or HP sponges to fill out ranks. One spooky flanker revenant or whatever
is a more interesting duel for a Skua or Kite than the Skua or Kite just mowing down less goblins
than they would if they were grouped."

So, as a direction (the bible's Foe roles row, open until he marks the form):

- **A rank-and-file unit is designed for a battlefield role**, a pusher's, a flanker's or a
  hunter's, and tuned for the fight that role meets: a pusher's for three machines, its identity
  sharp in numbers (the goblin's add, a caster behind a wall); a flanker's for one machine, a
  duel; a hunter's for the catch, a sequence a lone machine can play against. A unit crossing
  into another role's pack is deliberate, and its composition says why (beside its question,
  under `design`), so a filler is a thing the author has to defend.
- **A hunter is its line and what keeps up with it.** The engine already walks a pack at its
  slowest member's pace, so the validator can hold it: every member of a hunting composition
  moves at its lead's pace and flies if it does.
- **A flanker is a duel, not a small pusher.** The proposal's patrols rated one are cut-down
  pushers (three goblins, two knives and a screamer, three needlers), which is what his point
  refuses; they go, and each domain's flankers are written round units made for a duel.

**What the proposal's grids keep and lose under it**: the formations stand (pushers of pusher
units), less the antlions in the Waste's four (a hunting line in a pusher: the antlion pit, the
pit ambush, the pit wall and the queen's court are re-cut or defended); the hunters stand (each
its own line: the wolves, the antlions, the queen with her pits); every patrol rated one is
rewritten; the patrols the reads rated two that are no hunters (the knight's retinue, the lizard
trio, the wyverns' perch and the rest) are rewritten with them: a two stays legal for a heavy
patrol by his word of 6 November, and whether a flanker is ever a fight for two is open with the
roles.

**The roster by role today**, tier one's lines (the recolours follow their bases):

| Domain | Pushers | Hunters | Flankers |
|---|---|---|---|
| The Meadow | the Goblin, the Mandragora, the Gel, the Treant | the Dire Wolf | none |
| The Waste | the Needler, the Cockatrice, the Sandworm (the Djinn from tier two) | the Antlion | none |
| The Marsh | the Revenant, the Ghost, the Barrow Giant | none in the ranks (its elites) | the Zombie Knight, if it is re-tuned for one machine and leaves the formations |
| The Peak | the Salamander, the Drake, the Magma Elemental | none in the ranks (its elites) | the Bomb, if a lone one is the duel (kill it whole, or eat the burst) |

So the Meadow and the Waste want a flanker line each, and the Marsh's and the Peak's are a
re-tuning of a unit that then leaves the pushers, or new units too. New units are content ideas,
proposed in chat first; his own bench from the elites session holds candidates (the Coeurl, the
Dullahan, the Banshee, the Sphinx, the Roc, Anzû, the Iron Giant, Cerberus, the Drowned King:
"what misses the cut may be rank and file").

**Holes raised, each with what settles it**:

- A lone duelist barely touches the wall: a pusher strikes for its head count (a third of ten a
  foe), so one foe chips 3 a turn where a formation of eight strikes 26, and leaving a flanker
  alone costs almost nothing. Claude's lean: the strike follows the threat rating the pack
  already shows (ten a pip), so the pips say how many machines it wants and how hard it hits the
  wall. Ryan, 10 November: "Strike following the threat rating makes a lot of sense, otherwise a
  single giant dude that composes a threat 3 on his own could be ignored. It also makes elites
  make more sense too." Built 10 November (`Battlefield.strike_of`; the rules, the bible's wall
  row): it replaces his rule of 30 October ("a stray pair chips less than a trio"), written when
  a count was the threat. A pack that has won a fight keeps its survivors and its rating, so its
  strike is scaled by the share of its heads still standing, one at least (his word: "Your lean
  for the pack survival is fine"); the share is by head, so a worn pack left with its massive
  alone strikes for that one head's share, where a share by menace would weigh the massive more:
  named for him, not asked. The pack's panel and the orders board say what the gate takes.
- A duel a light enjoys: one sharp question from the kit the engine has (a countdown to beat, a
  brace to time, a barrier to pop cheaply, a getting-up to kill twice, a last act to shield
  before), HP for three or four rounds of one die, and no flat armour, which the reads showed
  walls the Skua whatever else the unit does. A heavy sent at it wins slowly: mismatch costs
  time.
- The duels repeat: the flanks at the start and every tear send flankers, so a battle meets four
  to eight of them from one or two lines a domain and tier. A second line a domain, or a line's
  duelist alone and as a pair, is the room; the guest's flankers help from tier two.
- The words: content calls the small composition a patrol and the player's glossary says Patrol;
  his word is flanker. If the role is the word, the schema's sizes follow (a flanker, a pusher,
  a hunter, an elite, an escort), an engine rename with the pass's content.
- The role is read by the validator, so it is a field on the foe, not a line under `design`:
  `role`, a pusher's unless it says otherwise. Shown or internal is his (the Foe roles row).

The twelve prunings, the gates, the bosses' stat blocks (its section 6) and the escalation check
(its hole 8) stand as the proposal has them until the re-read. Nothing of it lands before the
model's numbers.

## 5. The what-if, built, and what its first reads say

Built 9 November, none of it content (`sim/refit.gd`, `tests/test_refit.gd`; the README has every
option):

- **The injury rule is off in the game** (`Skirmish.injuries`, false): no break in a fight and
  no destruction after it; `--injury on|N` reads a run with it back.
- **`--refit SPEC`** on both runners lays the model over the loaded content for a run and names
  what it did in the report's head: `die` (every stock shield and vent swapped in its own slot
  for a defensive basic, a shield spent on its own machine for the Armoured piece and any other
  for the Barrier piece, a vent for whichever the die lacks, else a tier-zero gun; section 6's
  four machines undealt; the Stingray cooling one), `vents=guns` (a vent's slot takes a gun
  instead, so a die holds a defensive basic only where a shield stood: the audit's own deal and
  the stock re-deal's placeholder), `regen=half|N`, `cooling=N`, `heat1` (the basics at heat
  one), `barrier=off|cooldown|heatN|ward` (the Barrier basic's rule: none, dark the round after
  it is spent, N heat a spend, or a Ward in its place), and `all` for the die, half the gauge
  and heat one. The tier-one Blast Door, Shoring Jack and Decoherence Veil stand in for the
  pieces section 6 names.
- **`--guard W`**: the aggressor's habit for the fight bot (`Policy.guard_weight`: a block at a
  share of its worth; at 0.05 it never rerolls for one and spends one only when its die is stuck
  showing it), so the hull the blocks keep and the rounds they cost are read as its gap from the
  rung, which takes every block worth making.
- **The trial in the game**: `RIFTGATE_REFIT=<spec>` on the desk, and on the phone a debug
  build's SETTINGS → REFIT TRIAL (OFF, MODEL, EVERY, RESTS, NONE: the model with its Barrier
  basic where a Halo stood, on every die, on every die and resting a round, or on none), read at
  the next launch and judged on a new battle or run.
- The curve read's cells carry greedy's rounds and its stalled fights beside the band and the
  hull lost.

Not built, so the trial plays without it (10 November, on his asking what is built):

- **Section 6's content.** No component is retired, renamed or re-kinded: the eleven slottable
  shield and vent pieces are still in content, four of them basics, so a refit by hand, a loot
  drop and the quick campaign's hangar can still put one on a die. The tier-zero Shoring Jack
  and the Halo Projector do not exist; the tier-one pieces stand in, on the stock dice only.
- **The stock re-deal.** A vent's slot holds a Twin Autoguns as a placeholder (MODEL) or the
  defensive basic the die lacks (EVERY).
- **The numbers.** The regen is half the gauge on every chassis, no role or maker in it; cooling
  is as it was but for the Stingray's one; no heat price moved but the two basics'; no foe's
  number moved.
- **The foes.** The formation proposal's grids; the bombs that no longer hunt (content's bomb,
  grenade and balloon compositions still do); the roles and the flankers as duels; the rising
  threat and its validator check. (The wall strike by the rating is built, 10 November, on
  every pack as content has it.)
- **The machines.** The four reworks; the two modules (the Skeleton's rule does nothing with the
  injury off, the Conjugator never fires on a die with no shield); the lines on fielded machines
  that name a shield or a vent (the Musk Ox's forge reads neither; the Storm Petrel's and the
  Buzzard's shields run as written, cheaper under a regen).
- **The engine and the words.** Shield and vent are still kinds, with their keywords, their
  vocabulary and the Overshield; shown text still names the injury (the keywords list) though
  the rule is off. The bot does not value the regen. The commander layer is a note.

The first reads are `docs/measurements.md`'s (9 November, the refit pass's first reads), 30 seeds
a cell and 40 runs a campaign, each a direction, in the bot's hands. What they say:

1. **Over a battle the model takes the bot about twice as far.** Menace killed a battle doubles,
   the Rupture is reached in four battles in ten against one in six, team wipes fall from nine in
   ten to under two in three. The regen alone, on today's dice, is the larger half; the die adds
   the rest however the Barrier is dealt. The campaign stays a wall for the bot,
   whose defence rule sends lone machines at formations.
2. **The regen is the buffer for the outnumbered and for the lights, against plain blows.** At
   the rating its size is one number (2, 4 and half the gauge read alike); short-handed it is the
   dial: a lone Badger against a formation for three is a wall with none, a decision at 81 to 85%
   of its hull at 2, and at 4 (half its gauge) beats the barrow mound for 31% and the treant
   grove for 37%, each in sixteen rounds. The light trio's two walls at three become decisions,
   and the lone elites, whose blows are plain, cost a lone Badger 22% against 41%.
3. **Breach is where hull goes, and the regen never meets it.** Every cell that still costs hull
   is a breach: the sandworm's maw and the magma elemental's fist, the needlers, the knights'
   cleaver. Five of tier one's rank-and-file lines carry it (none of the Meadow's). The needler
   scouts cost a lone machine a quarter of its hull on every read, and the knights' retinue walls
   a lone machine on every read.
4. **The Barrier matters in one kind of fight, a full squad against a breaching massive, and
   there a block trades rounds for hull.** With none the two such formations cost a third of the
   trio's hull as today; with one on every die a tenth, at half again the rounds and four dice in
   ten spent on it; a resting one or a Ward sit between; the aggressor loses a quarter and
   finishes two rounds sooner. Over a battle every deal and the aggressor land together, the
   audit's own among them. Tier two reads the same by its own team.
5. **A round costs nothing, so the block is nearly free hull.** Little in a tier-one pusher's
   fight makes its seventh round worse than its third, and a regen makes a longer fight kinder.
   This is the block-everything loop on one fight's scale, and no rule for the Barrier removes
   it: what prices a round is a threat that rises. The model's ninth point is therefore more than
   a guard against the infinite fight; it is what makes aggression pay.
6. **The fight nobody can finish is back.** No fight passed sixty rounds today; with a regen 5
   to 19 of some 900 do over 40 runs, and the fights the model turns from lost to won for the
   light trio run seventeen rounds and more.
7. **Heat is untouched by losing the vents, and is still no pace.** The bot spent 7% of its dice
   on vents; without them its peaks and overheats sit where they did, a hot die is held less than
   once a fight, and the hottest tier-one trio loses one to three hull a fight to heat. The
   basics at heat one are under the cooling of one nearly every chassis has, so they are no
   price. The hold needs prices above the cooling, the heat session's list.
8. **A Ward makes the regen the dial against breach, and is a blank against a plain blow.** It
   lands the round's breaches on the shield, so hull lost follows the regen's size where a
   Barrier's does not, in a shorter fight; but the Meadow's whole tier-one line and all of the
   Marsh's but the knights lay no rider, so on a stock die it would do nothing there.
9. **The what-if dealt more Barriers than the audit does.** It filled a vent's slot with the
   defensive basic a die lacked, a Barrier on nearly every die, where the audit puts one only
   where a Halo stood. The reads above are that deal's and bracket the audit's: the default trio
   under the audit's deal holds no Barrier (the no-Barrier column is its own), and the light
   trio holds two and reads as well on it as with one on every die, in shorter fights (a gun
   where a vent stood is worth more to it than a second block). Over a battle the audit's deal
   lands with the rest.
10. **The proposal's pushers sit on the budget but for the breachers.** Of the formation
   proposal's fifteen tier-one formations, twelve cost the default trio 8% of its hull or less
   at three on every read, ten of them at or under the twentieth the budget names on the audit's
   deal. The three over it are breach:
   the two with a massive at 39%, eight times the budget, and the knights' vigil at 15%; on the
   audit's deal the model leaves them exactly there, since that trio holds no Barrier and the
   regen never meets a breach. The massives' own numbers are the lever, the refit's first band.
   The hunters at their rating of two cost what they did; caught alone, the plain-blow lines
   lose their teeth on a tank (the wolves nothing, the antlion trio half) and the breaching ones
   keep theirs.

Still to read: the cautious persona on the model's dice (the rung prices only an overheat, so it
cannot say whether a player would feel heat); the stalled fights by pack (the campaign runner
names none); tier three, and the proposal's formations at tiers two and three, under the model
(their reads ran past the hour and were stopped); a light caught alone by a hunter; 200 seeds on
any cell a decision cites. Then Ryan's play at placeholders, which
decides feel.

## 6. The audit: what the model breaks, touches and leaves (9 November, on main's content)

Read on the merged content: 24 chassis, 81 components (56 weapons and debuffs, 10 buffs, 8
shields, 7 vents), 18 modules. Nothing in `content/` has moved; each line is where the piece
goes when the pass's content lands. Names follow the piece where its kind changes (his word);
every name here is a working name for his name pass.

**Machines back to design** (each a brief; none is dealt once the pass's content lands, until
its session hands it back):

| Machine | What breaks | Its brief |
|---|---|---|
| The Whip Scorpion (tier two) | "Its vents blast a random foe for the heat they take off it. Nothing else cools it": no vent to spend, so no guns and no way down; his tabled shapes stood on vents too | `ws_whip_scorpion.md` |
| The Polar Bear (tier one) | Lockdown seals on a shield it spends on itself and opens on a vent or a weapon: nothing seals it; his kit of 9 November stands, the seal's trigger is the question | `minerva_polar_bear.md` |
| The Puffin (tier one) | a shield escort with no shield to spend; his direction, the one unit that cools its allies | `kestrel_puffin.md` |
| The Swallowtail (tier three) | the Mooring Screens and the Sutler's Hoist are shields, the Hoist a vent too; with the Horn already to be replaced, three of its four locked pieces are open | `ws_swallowtail.md` |

**Machines touched, no redesign** (a dead line or a number to read again, in the pass's content):

- The Musk Ox: "a vent it spends on itself adds 3, a shield 2" has nothing to mean, so the
  forge's reloads are its trickle, the Recuperator's refund and the Quick Reload, which becomes
  equipment as it is; his question of 8 November (whether a shield reloads it at all) is
  answered by the model. Its ammo is read again with two sources gone (its tabled session).
- The Storm Petrel: its shield pays its weapons' heat and the shield now refills each round, so
  its engine runs cheaper; the St. Elmo's regen is a regen buff on top of the chassis's own.
  Read first, its burn or its regen the lever.
- The Buzzard: the model's own example already (a shield from its heat each round, one weapon
  that fires its heat); its Thermal Recoupler stacks on the chassis's regen. Read.
- The Stingray: cooling 0 to 1 (its vent face was its brake); the Lance untouched.
- The Nemesis and the Ammit: their stock holds the Oblation Mantle and the Entropy Condenser,
  the pieces that pay in hull; the Nemesis's rage reads hull damage, which a regenerating shield
  thins. Read with the Arsenal's two pieces.
- The Cassowary: its cylinder's order is re-dealt with its stock.
- Every stock die: 37 stock slots hold a piece that retires or changes (the Coolant Jacket 13,
  the Canopy 10, the Halo Shield 6, the Bleed Valve 5, the Oblation Mantle 2, the Entropy
  Condenser 1), on every chassis but the Lammergeier. The stock re-deal is the pass's largest
  piece of content: a table in chat first.

The other thirteen are untouched in kind: the Honey Badger, the Clydesdale, the Kite, the Baboon,
the Wild Boar, the Prairie Dog, the Dingo, the Funnel-web, the Cottonmouth, the Skua, the
Needletail, the Giant Petrel and the Lammergeier read their own numbers again and nothing more.

**Components**, the eight shields and seven vents, and the three that move:

| Piece | Today | Under the model |
|---|---|---|
| The Halo Shield (tier zero, Aphelion) | shield 6 | the Barrier basic, on itself or an ally, renamed the Halo Projector: hard light that stops one blow, and Aphelion keeps its one basic |
| The Canopy (tier zero, Minerva) | shield 8, self | retires ("always a little lame"); the Shoring Jack takes its place |
| The Shoring Jack (tier one, Minerva) | Armoured 2 for the round, self or ally | comes down to tier zero: the Armoured basic |
| The Coolant Jacket (tier zero, Wainwright & Sutler) | vent 4 | retires |
| The Bleed Valve (tier zero, Kestrel) | vent 6, self | retires |
| The Blast Door (tier one, Minerva) | a Barrier, self or ally | stays at tier one and must be more than the basic (Claude's lean: its Barrier holds until it is struck, where the Halo's lasts the round), or retires as its duplicate |
| The Decoherence Veil (tier one, Aphelion) | a Ward, self or ally | stays: the Ward at tier one |
| The Laminar Deflector (tier two, Kestrel) | shield 6, Rapid, a round's cooldown | a Barrier, Rapid, a round's cooldown; the name stands (a deflector turns one blow) |
| The Corona Shield (tier two, Aphelion) | shield 6 and a Cleanse | a Ward and a Cleanse on a machine, renamed the Corona Veil (Aphelion's Wards are Veils); a Barrier that Wards too, offered first, is the old whole block on one piece and is dropped |
| The Phased Sublimator (tier one, Aphelion) | vent 4 and a Cleanse | a Cleanse on itself or an ally, equipment; the name stands |
| The Radiator Sail (tier one, Aphelion) | vent 5 on an ally | retires: cooling an ally is the Puffin's by his direction |
| The Wake Diffuser (tier one, Kestrel) | vent 3 that shields 3 | back to design: two recoveries on one piece; its own line ("it runs cooler, and somehow faster") points at heat turned into tempo, a payoff vent as equipment |
| The Oblation Mantle (tier one, the Arsenal) | shield 10, paid 3 hull | back to design with the Arsenal's sessions: what its hull buys when it is no shield (Claude's lean: a Barrier on an ally that holds until it is struck) |
| The Entropy Condenser (tier two, the Arsenal) | vent 10, paid 3 hull | back to design with the Arsenal's sessions (Claude's lean: its heat thrown at a foe as a blow, paid in hull: a weapon) |
| The Backwash Ionizer (the Puffin's) | an overshield on an ally | its brief |
| The Mooring Screens, the Sutler's Hoist (the Swallowtail's) | shields | its brief |
| The Quick Reload (the Musk Ox's) | a vent in kind | equipment, as it plays today |

The basics are then six, from eight: the four guns (Wainwright & Sutler's Twin Autoguns and Ankle
Mortar, Minerva's Rivet Gun, Kestrel's Laser Carbine), the Halo Projector and the Shoring Jack;
the fifth gun he wants, an Indirect one, and whatever the stock re-deal asks are the component
pass's. The ladder this leaves for the pricing pass: a Barrier for the round at tier zero, one
that holds at tier one, a Rapid one at tier two; Armoured 2 at tier zero and its higher numbers
to write; a Ward at tier one and a Ward that cleanses at tier two.

**Modules**:

| Module | Today | Under the model |
|---|---|---|
| The Reinforced Skeleton (tier two, Minerva) | its components are never destroyed; hull 8 | back to design: with destruction off its rule does nothing; parked until destruction's fate is known, or a new rule beside its hull line |
| The Phase Conjugator (tier two, Aphelion) | an ally it shields is Armoured 1; shield 4 | back to design: nothing shields an ally, so it never fires (Claude's lean: it reads a Barrier or a Ward it grants an ally) |
| The Spall Liner, the Boundary-layer Bleed | stand shield up on a trigger | work as they are: shield onto the gauge |
| The Ward Plate, the Field Radiators, the plates | stats | work; shield regen is a stat a plate may now carry |
| The Muzzle Velocity Booster, the Tactical Databank | planned since 2 November | untouched by this; still waiting on rules |

The other eleven modules read no shield, vent or injury and stand.

**The foes the model touches** (no content moves; each is read):

- The Goblin Nob's Enrage counts every shield raised, vent spent and equipment used: under the
  model it counts equipment alone, so it punishes exactly the Barrier and the Armoured a team
  reaches for. Sharper, and its text changes.
- Breach ignores the shield, so the regen buys nothing against the Waste: its pushers carry their
  hull budget in their numbers, or the Waste is where hull is spent by its identity ("hull and
  tempo over shields"). His call with the budget.
- A drain is starved by a shield that refills (the Vampire Lord); Scorched and Burning bite
  harder with no vent to answer them, so the Peak's cells are where heat as a pace is read first.
- A Barrier in stock dice makes it common where it was a tier-one find, and his row of 17
  October says what follows: "if a Barrier grows common the foes need more damaging riders to
  carry past it" (damage over time, on-hit effects, a countdown's blow). How common is section
  7's first question; the bosses' telegraphs are read with the Halo Projector in the team's
  dice.

**The engine the pass touches** (for its build, after the reads): `Face.Kind`'s SHIELD and VENT
and what reads them (`is_shield`, `is_vent`, the die's marks, the readouts, `tools/die_sheet.gd`);
the effects `seal_form`, `vent_blast`, the forge's vent and shield reloads, `on_shield_granted`
(`shield_per_ally_heat` and the Conjugator's), the keyword Overshield, a face's `vents` and
`shields`; `shield_regen` read at the round's start (built, zero everywhere); the injury
(`Skirmish.injury_pct`, `_injure_entry`, `no_destroy`, the campaign's and the quick campaign's
destroyed pieces); the bot's shield and vent valuation and its cautious and shield personas
(`sim/policy.gd`); the vocabulary's Shield, Vent, Overshield and Injury entries.

**Designs not yet built whose briefs stand on shield or vent entries** (each folds the model in
at its own session; the briefs README says so for all): Misharu (its Vigil Pavise a self
overshield, every shield on the team its bait; his new direction of 6 November supersedes the
bait), the line frame (its parry is a Barrier already; what breaks its combo names a shield and
a vent; its stacking regen is a regen buff, which the flat regen keeps meaningful), the gunship
(Beam weapons raise its shield and recharge), Mastema (the Votive Screen, a shield for each
burning foe), the Macross (GERWALK's shield regen on allies, his own idea, fits as it is), the
Carrier (a screen of shield on every machine, benched already), the Onryō's Pall, the Cryo
defence (a blow on any ally's shield as its trigger still works), the siege battery (its
charge by components used), and the heat pillar's brief, which this pass takes in whole.

## 7. Open, for Ryan

Settled 9 November: the regen a flat number a chassis, never the full reset; the injury rule off
completely; the Puffin to the drawing board and the Swallowtail to its session; and his leans
accepted on the rest of the first list ("Your leans are good"): the basics at heat one, the
cooling by chassis with a read of an offset, the heat session's list landing here; the shield
pieces' fates (section 6, with the names following); the hull budget by kind (a pusher's fight a
twentieth of the squad's hull at its rating, a flanker's a thirtieth or less, a hunter's a
tenth, an elite's a quarter, the boss what is left); and the formation proposal's remaining leans,
which his point on the makeups (section 4) now re-cuts for the flankers.

Still his, the first five with what the first reads say (section 5), the fourth parked on his
word:

1. **How common the Barrier is.** The audit puts one where a Halo stood (the Halo Projector: in
   stock the Baboon, the Prairie Dog, the Stingray, the Cassowary and the Cottonmouth, and the
   Arsenal's two where the Mantle stood) and re-deals the vents' slots; the what-if's first fill
   gave those slots the defensive basic a die lacked, a Barrier on nearly every die. The reads
   bracket it: on every die it is the whole saving against a breaching massive, at four dice in
   ten and half again the rounds; on none those formations cost a third of a trio's hull as they
   do today; over a battle the deals land together. So the stock re-deal sets it, and a squad's
   Barriers become a choice of machines. The trial plays four deals: MODEL (the audit's, a gun in
   every vent's slot), EVERY, RESTS (every die, dark the round after it is spent: half the
   saving, a round and a half back) and NONE. On the bench, each with what took it off: a Ward in
   the Barrier's place (the read: the same saving with the regen as its dial; but it does
   nothing against a plain blow, a blank against the Meadow's tier-one line), a Barrier that
   Wards too (his row of 17 October: the old whole block on one piece), a heat price (the read:
   it does not shorten the fight). Claude's lean: the audit's deal, the Barrier a maker's tool
   with no standing rule on it (the light trio reads as well on it as with one on every die),
   read again against the bosses' telegraphs; his play decides.
2. **What prices a round.** A block trades rounds for hull and a round costs nothing, so the
   best line is still to block. The model's ninth point (every formation carries a rising threat,
   a validator check) is what the reads say prices it; it is a rule over every pusher, his to
   set, and the Marsh's giants are its first defect. The other levers on the bench: a pack's
   strike at the wall while a fight runs (the wall has no clock inside a fight today), heat that
   bites (item 5).
3. **The regen's size.** Half the gauge lets a lone tank beat a plain-blow formation rated for
   three, slowly; 2 a round leaves it a decision at four fifths of its hull. By role and by maker
   once the basic is picked; Claude's lean: 2 or 3 a round for the heavies, more for Kestrel's
   lights, read again with the content.
4. **Breach under the regen: parked** (Ryan, 10 November: "Let's ignore breach for now, it's
   useless to evaluate at this junction"). The read stands as a read (hull is spent where breach
   is: the Waste's whole line, the Marsh's knights, the Peak's bombs and elementals, none of the
   Meadow's) and nothing is asked of him or proposed on it until the model's numbers stand.
5. **Heat as a pace.** Losing the vents changed nothing, and nothing makes the bot hold a die:
   the prices are under the cooling. The heat session's list (the prices on every face, the
   basics included) is where the hold comes from; the cautious persona's read comes first.
6. The four machines' sessions and their order (the Polar Bear first, since Minerva's tier-one
   front and his own try of 9 November ride on it).
7. The roles (section 4): a role on every rank-and-file unit, the flankers as duels, the units
   each domain lacks. The strike at the wall follows the rating (his word and built, 10
   November: section 4).
8. The Reinforced Skeleton: parked with destruction, or a new rule now.
9. The commander layer's shield and vent actions: a note now, a row when that layer is designed.

## 8. Holes raised, each with what settles it

- A regen large enough to absorb fodder makes lights untouchable against it and the fight a
  kill-speed race alone; too small and nothing changes. The first reads place it: at the rating
  its size does not show, short-handed half the gauge makes a plain-blow formation survivable
  alone and 2 a round does not (section 5's second point). His play sets the feel.
- A fight neither side can end. Read: none today, 5 to 19 in some 900 with a regen. The rising
  threat in every formation is the guard and the price of a round (section 7's second item).
- Heat as a background number nobody feels: confirmed for the bot on both dice (section 5's
  seventh point); the prices must bite, and the cautious persona reads whether they do.
- The bot: the greedy reads this round's forecast, so it values a block by the hull it keeps now
  and the regen not at all, and still gains what the model gives; its aggressor's habit
  (`--guard`) is the second line. It cannot say what a player feels.
- The Storm Petrel's loop: a shield that pays heat and regenerates each round is a cheaper engine
  under the model; its numbers are read on its row before anything lands.
- The lights' identity: big shields on small hulls read differently when the shield regenerates;
  Kestrel's shields against Minerva's armour is the lean, the regen and the armour the two
  makers' answers.
- The elites under a regen: their blows are plain, so a lone Badger takes most of tier one's lone
  elites for a few points of hull (section 5's second point). Their numbers are their own item
  (the bible's section 12); this is one more read for it, no proposal.

## 9. The order, on his answers

1. Done, 9 November: the what-if, the injury rule off, the aggressor's habit, the trial, and the
   first reads (section 5).
2. His play at placeholders: the trial under each deal of the Barrier (the to-do's Ryan list),
   and his answers to section 7's first five but the fourth, which is parked.
3. The content of section 6 as marked, with the deal he picks; the regen and cooling numbers by
   chassis; the heat prices; the pushers re-cut and read by hull lost, each with its rising
   threat and the validator's check for it; the flankers rewritten as duels; the records, the
   vocabulary, the rules, the hangar page.
4. The formation proposal's remaining questions settled in play; the bosses' blocks after.
