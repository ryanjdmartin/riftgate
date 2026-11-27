# Brief: the lure tank, Minerva's tier-one tank (new chassis)

<!-- hangar: {"kind": "chassis", "maker": "minerva", "tier": 1, "status": "idea", "slot": true, "name": "the lure tank"} -->

The session designs Ryan's tier-one Minerva tank: a drone that entangles the tank with one Sprite,
the two able to target only each other. Its niche is his of 25 November: "THE tier-1 tank option,
with Storm Petrel a close second. It can be simpler than Petrel, but hopefully no less
interesting." "The lure tank" is a working label; the name and the machine are Ryan's.

**Status**: Ryan's idea of 25 November, Claude's round on it (the cage), his four brainstorms
and Claude's read of them (the hold), his issue of 26 November with the hold's bar, Claude's
lean on it and his answer that it left a free lure, the price that answers him, and the ideas past his
four that he asked for on 27 November, and his split of that day (the lock a component, the Drone
the passive) with Claude's read of it, unanswered. **Maker**:
Minerva. **Proposed tier**: one. **Read first**: `docs/briefs/README.md` (ten a maker, the
orbits); `docs/rules.md`, The reboot and Foes (a Sprite's target); the bible's redirection row,
threat-shape row and armour row (section 5) and the Storm Petrel's row. The rounds before 25
November (every hit lures, an Armoured for each hit taken; a first read of the drone) are retired
on his "ignoring the old briefs", and stand in git.

## What Ryan said

- 4 November: "Minerva: tier 1 tank. Every hit lures. Needs a hook on how to stay alive. Maybe
  something like, 'every hit taken grants 1 armoured until end of turn' so it works well at
  soaking multiple hits but still bleeds on the first couple."
- 15 October, of the echidna: "we can either play up the spikes, or the luring tank, not both".
- 25 November: "It has a drone. setting the drone on a target entangles them together. Only the
  lure tank can target the entangled target, and the entangled target can only target the lure
  tank. Undecided if area damage can splash in or not."
- 25 November: "Take another crack at this, ignoring the old briefs. Lets get creative with this
  idea and see how we can make it work and make it interesting. Remember the target niche is for
  this to be THE tier-1 tank option, with Storm Petrel a close second. It can be simpler than
  Petrel, but hopefully no less interesting."
- 25 November, on the cage: "Couple brainstorms to throw around: -the entangled target is set
  on it hitting a sprite with anything -the entanglement is removed by targeting itself with
  something -the entangled target and/or the lure tank take damage over time or some other
  penalty while entangled -breaking the entanglement suppresses the target, maybe only during a
  reboot break so it's not just guaranteed damage to the tank"

## Claude's round (25 November): the cage

**The kit in a line.** The drone drops a cage over one Sprite and the tank: that Sprite's whole
turn lands on the tank and nowhere else, the tank's plate is thick against it, and the squad
cannot touch it until someone opens the cage.

**What tier one asks of a tank** (content, 25 November). Its swarms are eight Sprites hitting for
2 to 4; its formations put a massive of 14 to 20 HP and a hit of 6 or 7 in front of five of
those; its eleven elite packs are led by Sprites that hit for up to 16, most for 11 or more, on a
squad whose Frames have 20 to 36 hull, six of them alone on the field, five carrying a hit on
every Frame. So the tank is needed most where one
Sprite is the fight, which is where "only the tank can target it" leaves the other two dice
nothing to do.

**The pieces**, drafts to the text standard, every number a placeholder:

- **The Drone** (Integrated; equipment, Indirect; Lure, Spread, Rapid; heat 1). "Resolve: Apply
  Entangled to the target." / "Only one Sprite can be Entangled at a time." / "When another Frame
  removes Entangled: This entry goes dark until Reboot." Lure and Spread are the working name's
  half: the round it is set, the Sprites beside its target turn on the tank too. Rapid, so the
  tank sets it and still fires.
- **Entangled** (a Debuff that never stacks). "Targets only the Frame that applied it." / "Moves
  affect only that Frame and itself." / "Other Frames cannot hit it." / "When targeted by another
  Frame: Removed."
- **The passive** (working label, the Glacis). "When Hit: If by the Entangled Sprite, +4 Armour,
  applied before Shield." A hit it walls leaves its shield alone.
- **The chassis.** Hull 36, shield 8, Max Heat 12, armour 2 (the first tier-one machine at a
  tank's 2), three hardpoints: a die of four, so the Drone shows about two rounds in three with
  the rerolls spent on it.

**How it plays.**

1. *The save.* The Sprites' targets are shown as the round opens. The others fire, then the tank
   sets the Drone on the Sprite aimed at the wrong Frame: its target turns to the tank, as a
   Lure's does, and the plate meets the hit.
2. *Hold or open.* Each round after, the caged Sprite can do nothing but hit the tank, and the
   squad cannot hit it. Another Frame may aim at it all the same: that opens the cage. The hit it
   already aimed at the tank still lands, on a tank whose Glacis went with the cage, and the Drone
   is dark until the tank reboots. So a round is cover or fire, and the caged Sprite's own intent
   says which: a brace is the round to open on.
3. *The reboot.* The cage holds through the tank's reboot, bare behind its plate. A hold on a
   lone Sprite is the other Frames' safe reboot. One hold a reboot, unless the tank defeats its
   Sprite itself or moves the Drone itself: then it stays lit.
4. *Whom.* The big hitter, so the squad clears the rest; the caster, which can rally, brace or
   summon for nobody while it is held; the storm, which lands on the tank alone.

**Where his words give two answers or none.**

1. *How it ends.* As written nothing ends it. The reading that needs no new rule: the Drone comes
   home when its Sprite is defeated or its tank reboots ("tight" below). Claude's lean is the
   line above, another Frame's aim opening it ("slip"). `tools/lure_duel_model.py`, the hull a
   squad of three loses to tier one's packs, a standard squad's kit and no more:

   | The pack | Three standard Frames | The tank, no drone | Tight, as written | Slip |
   |---|---|---|---|---|
   | The Nob alone | 52, won 83% | 47, won 96% | 29, and 3 turns with nothing to aim at | 29 |
   | The Fell Rider alone | 48, won 85% | 43 | 25, and 4 turns | 27 |
   | The Old Man, two Needlers | 67, won 31% | 68, won 68% | 30 over 14 rounds, and 8 turns | 30 over 12 rounds |
   | The Treant's grove | 11 | 9 | 7, and 2 turns | 5 |
   | The Goblin horde | 11 | 9 | 6 | 6 |

   Tight saves the same hull and pays in the squad's turns, 3 to 8 a fight against an elite. With
   nothing dark at all the others lose less still (5 against the Nob for 8) and no round asks
   anything: the free cover the redirection row withdrew.
2. *Area*, his open point. Claude's lean: sealed both ways. Out: its hit on every Frame lands on
   the tank alone, which is most of the cage's worth against the five elites that carry one (the
   Old Man: the others lose 12 hull sealed, 32 open). In: nothing of the squad's reaches it but an
   aimed use, which opens it; an area that broke the cage by accident would be the worse rule.
   Tight wants area in, to give the other dice something to do.
3. *The tank's edge against its Sprite.* The plate is Minerva's and flat, and conditional armour
   is meant to wall: a massive's 6 does nothing, the Nob's 14 takes the shield and then 8 hull a
   round, so it bleeds to the big ones. The same 4 after the shield loses a Frame in a fifth of
   the Nob's fights, for a ninth. Halved hits read the same at tier one and scale by themselves;
   the drone taking its Sprite's first hit is the best save against a lone hitter (the tank loses
   15 for 21) and the weakest among adds.

**The system.** It protects the squad from one Sprite's whole turn, and for a round from its
neighbours. What threatens it: a hit past plate and shield; the crowd on its back while it
holds; Expose, which takes the plate; what passes armour; its own reboot under a hold; a Ward
and a Sprite's Cleanse, the cage being a Debuff; two equal hitters, since it holds one. The foes
it has: a big aimed hitter among adds, the storms and the casters. The foes that keep it honest:
twins (the Wild Hunt's riders), a caster under a Ward, a brute that cleanses itself, and an
immunity for a boss whose storm is its fight.

**The rows it bends**, for his ruling: the redirection row (a standing draw is "the lock": this
is one on one Sprite, from a rolled locked piece, and against a lone Sprite it is a draw on
everything for as long as it holds, bounded by the hit past its plate and the dark Drone); the
threat-shape row ("a blow at every machine beats Lure": sealed, the cage is the first answer
that takes one Sprite's storm whole).

**Two directions**, seeds for its branches, a clause of his sentence each. *The warden* ("can
only target the tank"): the lure holds every round the cage does (the horde: the others lose 2.4
hull for 3.3); the Drone set on another Frame instead, the Sprites aimed at it turning on the
tank, the interpose the redirection row keeps for a locked piece. *The duellist* ("only the tank
can target it"): what its plate stops from its Sprite adds to its next hit on it (the Macaque's
Parry is that counter); the Drone moving to the Sprite beside one the tank defeats.

**The bench**, each with what set it aside:

- The Drone following every aimed use, no entry on the die: the tank can fire at nothing but its
  Sprite without letting go, and set again for nothing it is the free cover.
- The cage lasting while the tank's shield stands: a clock everyone can see, but in a formation
  the crowd breaks it in a round.
- A timed cage (Entangled 2): the same shut-out whoever is in it, and no choice.
- Other Sprites unable to target the tank either: its plate leaves the squad in a swarm.
- 3 more armour after the shield: a Frame wrecked in a quarter of the Nob's fights.

**The machine**, which he has no concept for yet. The wombat is the fantasy whole (it blocks its
burrow with a plated rump and crushes what follows it in against the roof), and its name is on
the reserved list. Free: the Cape buffalo and its oxpecker (the horn boss a glacis, the bird the
drone), the moose (two bulls with locked antlers, and nothing gets between), the kangaroo (the
clinch, the drone out of the pouch). Minerva's maintenance voice has a word for the mechanic:
lockout, the tag that says only the one who hung it may touch the machine.

**What it costs to build**: a status both sides' targeting reads; an entry dark until a reboot;
armour before the shield against one Sprite; the bot's price for a hold and for opening one; a
tether drawn between the two, judged running; a warning on a die held over a caged Sprite.

## Claude's read of his four (25 November): the hold

**The loop they make together.** Every use on a Sprite holds its target. The held Sprite's hits
land on the tank's shield until it breaks, and the broken shield brings the reboot. The reboot
snaps the hold and Suppresses the Sprite, so the tank's bare round is safe and the squad has its
window. The tank's next hit holds again. No entry on the die is the drone: the passive is.

`tools/lure_duel_model.py --hold`, the hull the two other Frames lose, then the tank's:

| | The Nob alone | The Fell Rider alone | The Old Man, two Needlers | The Goblin horde |
|---|---|---|---|---|
| The tank, no drone | 31, 16 | 29, 14 | 42, 26 | 7.5, 1.6 |
| The cage (the round above) | 7.5, 21 | 11, 16 | 12, 18 | 3.2, 2.4 |
| 1 alone, nothing ending it | won 7%, the squad idle 13 turns | won 77%, idle 14 | won 43%, idle 16 | 5.7, 3.1 |
| 1 and 4 | 0.7, 28 | 0.6, 23 | 0.4, 27 | 6.2, 1.9 |
| The four, 2 Heat and 2 HP | 0, 26 | 1.4, 19 | 2.9, 17 | 2.9, 0.8 |
| 1, 2 and 4, 1 HP, no Heat | 0.3, 26 | 2.6, 21 | 6.8, 23 | 2.4, 0.4 |
| The same, 4 Armour against its Sprite | 0, 16 | 2.4, 10 | 7.1, 7 | 2.4, 0.4 |

**Each idea.**

1. *Set by every hit.* The engine of it, and his 4 November "every hit lures" made to last. One
   drone holds one Sprite, so it is the use's target: an area holds its target, a reach over
   every Sprite holds none, and a hit on another Sprite moves the hold. Alone it is a trap against
   a lone elite: nothing to aim at for 13 to 16 turns.
2. *Let go by using something on itself.* A lever, with holding the default: the bot that lets
   go whenever its squad has nothing to aim at loses more to the Old Man (13 hull for 7). Minerva
   has two pieces for it at tier one, the Shoring Jack (Armoured 2) and the Blast Door (a
   Barrier), and both cover the round's held hit, since a pick is a commitment. "Itself" reads
   two ways: the tank, or the held Sprite (its own brace or recovery breaking it free, a counter
   for the foes). The model's elites rarely move on themselves, so it cannot tell the two apart.
3. *A price while held.* Under 4, Heat on the tank is no price but a pace: it brings the reboot,
   and so the stun, sooner. Against the Nob it changes nothing (its hits break the shield first,
   and the broken shield brings the reboot), against the Old Man it saves the others hull (2.9 for
   5.4), and in the horde it costs the tank turns (4.0 rounds for 3.6). The price is already
   there: the held Sprite's every hit lands on the tank. HP off the held Sprite is a bonus on the
   tank's own target, which it keeps hitting: at 1 the horde falls in 3.6 rounds for 5.2 (a hit and
   a tick kill a goblin), the elites a round or two sooner.
4. *A reboot's break stuns.* The heart of it: with it the others lose under 3 hull to the lone
   elites. "Only during a reboot break" is the right line. Every break stunning would let holding
   and letting go stun every other round; the reboot ties the stun to the tank's whole turn.
   Numbed does the rest: an elite's resist of 3 leaves about one reboot in two stunning (2 stuns
   in 4 reboots against the Nob), and its Numbed chip says which.

**The bend.** Against a lone elite the tank is the target of all the Sprite does, the whole fight:
the redirection row's "standing draw" that "made one machine the target of everything", there
Guard's failure. Here the price is the tank's hull (16 to 28 of its 36 a fight, and hull is the
battle's), with the Numbed holes and one Sprite at a time; a Suppress-immune Sprite (the Pilgrim)
makes every reboot bare.

## The bar (26 November)

Ryan, 26 November: "Issue: against a lone elite, the tank is pretty much never allowed to attack.
Or if it does, it becomes a janky hit last in the turn to lure, then self target/reboot first the
next round to break it."

**The root.** The bar ("Only the lure tank can target the entangled target") was the hold's
price, and it is paid by the squad, against its most important target. The model (`--hold`)
shows it doing nothing else: against the Nob, barred always and never barred read the same,
because the bot plays exactly the sequence he names (the squad fires first, the tank holds last,
and its reboot breaks the hold first the round after); against the Fell Rider and the Old Man,
where the tank does not reboot every round, it is idle turns and hull (the others lose 2.6 and
6.8 barred, 0 unbarred); in the Treant's grove and the horde it changes nothing, since the squad
has other targets.

**Claude's lean: bar the Sprite's own side, never the squad.** "Other Sprites cannot target it":
the tether cuts the held Sprite off from its pack (no aimed heal, Cleanse or revival reaches it),
and the squad aims at it as at any Sprite. Then:

- The kit is three lines. The passive: "Commit: If used on a Sprite, apply Entangled to the
  target." / "On Reboot: Apply Suppressed to the Entangled Sprite, then remove Entangled."
  Entangled, a Debuff that never stacks, one a Frame: "Targets only the Frame that applied it." /
  "Moves affect only that Frame and itself." / "Other Sprites cannot target it."
- The tank never wants to let go, so idea 2 read as the tank's has no use. Read as the Sprite's
  (its own brace or recovery breaking the hold), it becomes the foes' counter.
- The price is the tank's hull and its reboots: unbarred, against the lone elites the others lose
  nothing and the tank 16 to 26 of its 36; with 4 Armour against its Sprite, 3 to 10, too little
  for an elite. So the stun is its hook to stay alive, and the plate goes.
- Without the stun the others lose 4 to 12 against the lone elites: the stun is what covers the
  reboot.

The bend of the redirection row stands, and grows: against a lone elite the tank takes everything
the Sprite does, and the squad gives up nothing for it.

## The price (26 November)

Ryan, 26 November, on the lean above: "A free, persistent lure without a strong tactical downside
is very overpowered, you must see that." He is right, and the lean's own table said so: the
others lost nothing to the lone elites. The bar lifted from the squad left the hold with no price
in anything the tank values.

**What the model says** (`--tether`: a tank that reboots whenever its shield is down and holds
only while it stands), the hull the squad loses, the tank's and the others' together:

| | The Nob alone | The Fell Rider alone | The Old Man, two Needlers | The Treant's grove |
|---|---|---|---|---|
| No drone | 46 | 43 | 67, won 69% | 9 |
| A plain Lure entry, the round's pick | 50 | 44 | 58, won 87% | 11 |
| The Drone's hold, the reboot letting its Sprite pick again | 50 | 40 | 51 | 9 |
| The Drone's hold, the reboot stunning | 35 (the others 10) | 28 | 34 | 6 |
| The same, 2 Hull a round held | 47 (the others 16, the tank 31) | 38 | 49, won 95% | 14 |
| Every hit holding, the stun: the lean above | 28 (the others 0.7) | 20 | 22 | 6 |

- A lure moves damage and barely removes it: under the reboot each Frame's shield takes a hit
  fresh, so three shields spread a big hitter's hits as well as the tank's one takes them. Its
  gain is keeping a hit off a Frame that cannot take it.
- A hold alone is a lure: the tank reboots every other round against a big hitter, which ends it.
- The reboot's stun is what removes damage: a quarter to a half off the squad's loss.
- Weapons off while it holds prices little: nothing against the Nob (the hold ends at the reboot
  that follows its first held hit, so there is no held round in which the tank wanted to fire),
  2 to 5 hull against the others.
- His idea 3 as Hull, not Heat, does: at 2 a round held the Drone's hold costs what it saves
  against the Nob (protecting the others at the tank's hull), still pays against the Old Man, and
  costs more than it saves in the Treant's grove, so holding is a call each fight. Claude had
  tried idea 3 as Heat and called it a pace: the wrong form of it.
- While every hit holds, any price on the hold is a price on attacking: the bar was one, the
  burn would be another. So the hold is its own act, the Drone an entry on the die.

**Claude's lean, the kit.** The Drone (Integrated equipment, heat 1): "Resolve: Apply Entangled
to the target." Entangled (a Debuff that never stacks, one a Frame): "Targets only the Frame that
applied it." / "Moves affect only that Frame and itself." / "Other Sprites cannot target it." The
passive: "Turn End: If a Sprite is Entangled, lose 2 Hull." / "On Reboot: Apply Suppressed to the
Entangled Sprite, then remove Entangled." / "Commit: If used on this Frame, remove Entangled." His
idea 2 earns its place back as the way to stop paying without a reboot; his idea 1 goes, for the
reason above. Nothing bars the squad, and the tank's weapons stay free.

## Ideas past his four (27 November)

Ryan, 27 November: "Do you have any other ideas outside of what I proposed? Or in combination
with the general concept?"

**What undid every form so far.** A two-round cycle: the tank sets the hold last in a turn, and
its reboot breaks it first the turn after. Nothing charged during the squad's turn survives it:
the bar is the jank he named, and a toll of 2 Hull whenever another Frame hurts the held Sprite
changes nothing against the Nob. So a downside has to act on the cycle. `tools/lure_duel_model.py
--ideas`, the Drone an entry on the die in every row, its Sprite's storms on every Frame:

| | The Nob: the others lose | the tank loses | the tank wrecked | The Old Man, two Needlers: won |
|---|---|---|---|---|
| No Drone | 32 | 15 | 5% | 70% |
| The free one (26 November's lean) | 8 | 22 | 5% | 98% |
| A. Between rounds | 8 | 25 | 17% | 97% |
| B. No letting go, set at half its HP | 20 | 26 | 20% | 72% |
| C. Angrier, 1 a round held, kept | 11 | 27 | 28% | 63% |
| D. 3 Hull as the Drone is set | 10 | 30 | 40% | 91% |
| E. The tug of war | 14 | 34 | 67% | 89% |
| E with 2 Armour against its Sprite | 9 | 22 | 8% | 98% |

- **A. The tether changes only between rounds.** His rule whole (it targets only the tank, only
  the tank targets it). The Drone's order takes hold as the next round opens, with a Lure the
  round it is set; a reboot Suppresses the held Sprite at once and lets it go as the round ends.
  A held round cannot be dodged, so the bar bites for the whole of it; against a lone elite it is
  the squad's planned rest, every Frame rebooting under the hold. The tank's weapons are free.
  The Nob's fight runs 11.4 rounds for 9.7. Without the stun the tank is wrecked in 82% of them.
- **B. No letting go.** The hold lasts until its Sprite is defeated, nothing bars the squad, and
  the tank's reboots under it are bare. The downside is the commitment: set at once the tank is
  wrecked in 86% of the Nob's fights, at half its HP in 20%, the squad's loss then no Drone's (46)
  moved off the others. It cannot carry the stun (the others lose 2.4 with it).
- **C. It gets angrier.** A point more on its every hit for each round held, kept. His idea 3 in
  another form. It makes whom matter: a held storm grows on every Frame, so the Old Man held
  reads worse than no Drone.
- **D. A price as it is set.** Volatile or a shield cost printed on the Drone, or a reroll. A
  price and no tactic; a reroll is the dice's own currency and the same in every fight, and the
  model has no dice to read it with.
- **E. The tug of war.** The hold a count from 2: the tank's use on its Sprite adds 1, its
  Sprite's hit that reaches the tank's Hull takes 1; at 4 it is Suppressed and let go, at 0 it
  breaks free and the Drone is dark until Reboot. The stun is earned, and a brace, a Barrier or
  plate on the tank wins it. In the bot's hands, which give it none, the tank loses every tug
  with the Nob.
- **Set aside**: alone on the field the Drone a plain Lure (it ends the lone-elite trouble and
  leaves a weak tank there: the squad loses 40 to the Nob, 46 with no Drone), and the toll.

Claude's lean: A, with C the dial to add if it reads too strong.

## His split (27 November)

Ryan, 27 November: "What if we split the entanglement onto a component, but put the drone onto
the passive? Hitting with a weapon moves the drone, so the engagement wouldn't move it. I'm not
sure what the drone does, but something that would make you want to move it to your intended
lure target the round before? Like a delayed suppress or a channeled effect or something? So it
can set up to offer personal safety while luring, or split its focus as the situation demands
it?"

**The reading.** Two pieces. The Drone is the passive: it moves to the target of every weapon
the tank uses, and it is primed on a Sprite it began the round on. The lock is a component, the
Tether, Integrated equipment: it moves nothing, so the tank's guns are free and the lock is a
deliberate act. What follows from his words: an area weapon moves the Drone to its target, a
weapon that hits every Sprite has none and moves nothing, and equipment never moves it.

**The lock, Claude's lean:** his rule whole for two rounds, the round it is set among them, and
nothing ending it early. The Tether: "Resolve: Apply 2 Entangled to the target." Entangled, a
timer: "Targets only the Frame that applied it." / "Only that Frame can target it." / "Round End:
Reduce stacks by 1." No release means no dodge and no trap past one barred round, which against
a lone elite is the squad's rest. It makes the lock its own downside: `tools/lure_duel_model.py
--split`, hooked with no help whenever the Tether shows, the tank is wrecked in 69% of the Nob's
fights. So the Drone is what makes a hook safe, and setting it up a round ahead is the play.

**What the Drone does**, played with a tank that hooks only the Sprite its Drone is primed on,
its shield whole (the Nob alone, then the Old Man with two Needlers):

| | The others lose | The tank loses | The tank wrecked | The Old Man: won |
|---|---|---|---|---|
| No Tether, no Drone | 32 | 15 | 5% | 66% |
| The lock alone, hooked whenever it shows | 26 | 33 | 69% | 64% |
| The hook fires the Drone's Suppress | 19 | 16 | 3% | 92% |
| 4 Armour against the Drone's Sprite, before Shield | 18 | 10 | 0% | 100% |
| The Drone's Sap, 1 a round it has stayed, to 3 | 12 | 18 | 5% | 100% |
| The Drone takes its Sprite's next hit, and comes home | 19 | 6 | 0% | 100% |
| The reboot fires the Drone's Suppress | 20 | 8 | 0% | 98% |
| That Suppress with no Tether on the die | 24 | 6 | 0% | 98% |

- **The Suppress the hook fires** (his first example). The Tether adds: "Resolve: Apply Suppressed
  to the Sprite the Drone began this round on", wherever the Tether itself goes. On one Sprite it
  is the safe hook: stunned the first round of its lock, the second landing on a whole shield.
  On two it is his split: one loses its turn, the other comes at the tank. The one form where
  each piece needs the other; Numbed is its brake. The tank still bleeds (16 hull).
- **The Sap** (his second, a channel). The Drone's Sprite hits for 1 less for each round the
  Drone has stayed, to 3, on every Frame. Kindest to the squad, storms included (the Old Man's
  others lose 26 for 35), and strong with no Tether at all (the others lose 24), which wants its
  cap watched.
- **Facing**: Minerva's plate, and the tank's own safety alone; the split gains nothing by it.
- **Set aside**: a Suppress the reboot fires. The Drone alone then does the kit's work (24 and 6
  with no Tether), and the lure stops mattering.

The tank fires a weapon in five or six of the Nob's ten rounds, for three when it hooks whenever
it can. His ideas 2 and 4 retire with this form: nothing lets go, and the stun is the hook's.

Claude's lean: the Suppress the hook fires, the Sap the alternative if the stun reads too sharp.

## Open for the session

1. What the Drone does: the Suppress the hook fires, the Sap, facing, or another.
2. The lock: two rounds that nothing ends early, or another length or end.
3. Whether the Tether is Rapid (the model's is not: the hook is the tank's use that round).
4. Area: sealed both ways, or its storms on every Frame.
5. The machine and its name; numbers and stock; its branches.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Minerva row and the rows it bends, Entangled in
`content/vocabulary.json` before its code, content planned, and this brief kept until its content
lands.
