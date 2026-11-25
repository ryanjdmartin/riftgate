# Brief: the lure tank, Minerva's tier-one tank (new chassis)

<!-- hangar: {"kind": "chassis", "maker": "minerva", "tier": 1, "status": "idea", "slot": true, "name": "the lure tank"} -->

The session designs Ryan's tier-one Minerva tank: a drone that entangles the tank with one Sprite,
the two able to target only each other. Its niche is his of 25 November: "THE tier-1 tank option,
with Storm Petrel a close second. It can be simpler than Petrel, but hopefully no less
interesting." "The lure tank" is a working label; the name and the machine are Ryan's.

**Status**: Ryan's idea of 25 November, Claude's round on it (the cage), his four brainstorms
on that and Claude's read of them (the hold), all of 25 November, unanswered. **Maker**:
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
3. *A price while held.* Heat on the tank measures as nothing: against a big hitter its shield
   breaks first, and the broken shield brings the reboot before the Heat does. The shield is the
   clock, and the Sprite's every hit on the tank is the price. HP off the held Sprite is a bonus
   on the tank's own target, which it keeps hitting: at 1 the horde falls in 3.6 rounds for 5.2
   (a hit and a tick kill a goblin), the elites a round or two sooner.
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


1. The cage (a Drone entry, the slip line) or the hold (every hit, the reboot's stun): Ryan's
   four lean to the hold.
2. Whose "itself" lets go: the tank's use on itself, or the held Sprite's move on itself.
3. The price while held: HP off the held Sprite (1), Heat on the tank, or the shield alone.
4. Its edge against its Sprite: 4 Armour before the shield, or none.
5. Area: sealed both ways, or the squad's area in and its Sprite's storms out.
6. The bend of the redirection row against a lone elite.
7. The machine and its name; numbers and stock; its branches.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's Minerva row and the rows it bends, Entangled in
`content/vocabulary.json` before its code, content planned, and this brief kept until its content
lands.
