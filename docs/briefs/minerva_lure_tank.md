# Brief: the White Rhino, Minerva's tier-one tank (new chassis)

<!-- hangar: {"kind": "chassis", "maker": "minerva", "tier": 1, "status": "direction", "slot": true, "name": "White Rhino", "built": "white_rhino"} -->

The session designs Ryan's White Rhino, the lure tank of his 4-4-2: "THE tier-1 tank option, with
Storm Petrel a close second." Its kit is decided (25 to 27 November, the bible's White Rhino row)
and planned in content (`white_rhino`, its lock `polarity_inversion_field`, the terms `invert`,
`inverted_polarity` and `rhino_drone`), so what is left is its look and its Drone's model, the Drone's name, and its
branches. The rounds that reached the kit (the cage, the hold, the bar, the price, the ideas past
his four, the split and the trigger) stand in git at `536f3d70`.

**Status**: kit decided, look next. **Maker**: Minerva. **Tier**: one. **Read first**: the
bible's White Rhino row and the threat-shape row (section 5); `docs/rules.md`, The reboot and
Foes; `tools/lure_duel_model.py` (`--split` plays the kit) and the measurements of 27 November.

## What Ryan said

- 25 November: "It has a drone. setting the drone on a target entangles them together. Only the
  lure tank can target the entangled target, and the entangled target can only target the lure
  tank. Undecided if area damage can splash in or not."
- 25 November: "Take another crack at this, ignoring the old briefs. Lets get creative with this
  idea and see how we can make it work and make it interesting. Remember the target niche is for
  this to be THE tier-1 tank option, with Storm Petrel a close second. It can be simpler than
  Petrel, but hopefully no less interesting."
- 26 November: "Issue: against a lone elite, the tank is pretty much never allowed to attack. Or
  if it does, it becomes a janky hit last in the turn to lure, then self target/reboot first the
  next round to break it." And: "A free, persistent lure without a strong tactical downside is
  very overpowered, you must see that."
- 27 November: "What if we split the entanglement onto a component, but put the drone onto the
  passive? Hitting with a weapon moves the drone, so the engagement wouldn't move it." Then: "Lets
  go with the 'suppress the drone's target' version. My initial thought was a rhino with its
  little bird friend."
- 27 November, the name: "I like White Rhino as the dichotomy, like we're making the vengeful
  version of its species (which presumably is wiped out in our future timeline, having been
  endangered and all)."
- 27 November, its shape: "1. Sure let's try two rounds. So that's two stacks that decay at the
  end of the sprites turn? Presumably that means the lock goes on cooldown then, too. 2.
  Thematically, the entanglement shouldn't let anything out, just like it doesn't let anything
  in, I think. It makes AoE backliners a better target and gives it a niche that normal Lures
  don't. 3. I would rather it not have rapid and give it something else, either riding or on the
  debuff/buff itself, like the 50% damage reduction from the entangled target. 4. Tier 1 tank
  stats. It needs to be able to find the lock, so it might want only 3 hardpoints, certainly not
  more than 4."
- 27 November, its model: "Make sure that the model isn't too on the nose for rhino, as with all
  models. It's tempting to slap a huge horn on there as a defining feature, when the kit doesn't
  actually use one. We'll want a drone model, too."
- 27 November, its lock: "The lock is referencing quantum entanglement not physical. Shouldn't be a
  winch, this isn't W&S. More, I dunno, tractor beam. And it can be the "horn" such as it is on the
  model."
- 27 November, the names: "I'm not worried about conflicts. We'll audit the components after,
  since the chassis texts should get first pick. Polarity projector is a weak name anyway, using
  up two very good words. Let's go with Polarity Inversion Field, applies Inverted Polarity. The
  drone can use something with Enforcer or Enforcement? Can I see a drone version with twinned
  fans?"
- 27 November, the Drone: "Why does the drone need that flat platform at the bottom? I kind of like
  the tandem cause it's different. I think just "Askari-class Enforcement Drone," or something
  similar, shortened to "Enforcer" for gameplay text."
- 27 November: "I think we should try a half-track for this one, it's not a silhouette we have
  yet, right? I can't tell looks without seeing them, so I'll need mock ups. Entanglement itself
  is a little too high tech for Minerva, they sit more at the Kestrel range of pseudo-science.
  Something like Polarity Enforcer, magnetism related, harmonics or resonance related. Anything
  that would cause the field to isolate the two while they're connected. Whether that's
  physically or through some shared attribute that would make them, I guess, unaffected by
  others."
- 28 November, the first looks: "A and C are best starting shapes but they're all pretty rough. C
  at least looks like it could take a hit, but it's otherwise very plain. A has visual interest
  but looks flimsy, it has humvee heritage. The Polarity field emitter...thing should be a
  defining feature but all 3 of them look tacked on there...like a horn. There's no reason for it
  to be where it is, and when it's the entire identity, it needs to make an impact on the
  silhouette. Also gun placements on A and B don't work, at all. And the drone needs a real dock,
  it's an extension of the chassis so it should have a real home to either dock into, connect to,
  or a shielded bay to eject out of, or anything like that. Another defining feature that's
  getting missed."
- 28 November, the Drone and the roots: "The tandem drone needs refining. It's very crude and
  flimsy looking. I'm imagining, lore -wise, that this unit has something like SWAT roots (or the
  future-tech equivalent), a versatile vehicle designed for isolating and neutralizing a severe
  threat with its kit working in tandem, or tactical support through being able to hold a line
  and handle distant threats with the drone simultaneously, or even riot control and the like. So
  with that, the drone needs to look rugged and durable enough to endure in a combat situation,
  too. So maybe even the tandem rotor isn't really cutting it for what the silhouette needs to
  be." And its name: "I don't love "class" since that sounds like a vehicle and not a drone, so
  I'll take suggestions."

## The kit, decided

- **The Drone**, its passive, the Enforcer in gameplay text (his; its full name is open, the
  content still holding his "Askari-class Enforcement Drone" of 27 November): every weapon it uses on a Sprite moves the Enforcer to that use's target. Draft: "Resolve: If a weapon was used on a Sprite, move the Enforcer to the
  target."
- **The lock**, its Integrated equipment, the Polarity Inversion Field (his name): a field that
  isolates the White Rhino and one Sprite while they are joined, thrown from a projector that is
  its horn, such as it is. Indirect, Invert 2 (the keyword's name the session's draft), Cooldown 1,
  heat 1, not Rapid, a Beam; as it resolves, the Sprite the Drone is on is Suppressed.
- **Inverted Polarity** (his name), sealed both ways at half damage, a stack off at its Sprite's turn end, so it
  holds the round it is set and the next. Draft, worded after Phased: "Targets only the Frame that
  applied it." / "Affects only that Frame and itself." / "Cannot be targeted, damaged, or affected
  in any way by units other than that Frame." / "Deals half damage, rounded down." / "Turn End:
  Reduce stacks by 1."
- **Its numbers**, placeholders: hull 36, shield 8, armour 1 (his tier-one Boar's, 20 November:
  "the Boar at tier 1 needs base armour 1, not 2"), Max Heat 12, move 3, three
  hardpoints stocked with basics (the Rivet Gun, the Ankle Mortar so the Drone reaches a
  backliner, the Shoring Jack). Tracked until a look is picked.

What follows from his words, built so and named: a hit on every Frame from its Sprite lands on
the White Rhino alone; the squad's area, Chain's ping and a Mine's blast pass its Sprite by, and
its own pack's rally, Cleanse and revival never reach it; statuses already on it keep counting
down. The model (`--split`, the White Rhino as settled): against the lone elites the squad loses
about a third less hull than the same tank with no kit, and swarms are untouched, the lock
having no big hitter to take. With half damage the lock is safe enough that hooking whenever it
shows does better than waiting a round for the Drone, so the set-up is the stun's, not the
lock's safety.

## The look rounds

A half-track, his of 27 November ("it's not a silhouette we have yet, right?"): no machine is one,
and the engine moves five ways (tracked, walker, wheeled, hover, flyer), so the White Rhino is
tracked for the rules and a half-track to look at. `tools/lowforge/looks/rhino_looks.py` builds
every round (`$BPY_PYTHON tools/lowforge/looks/sheet.py rhino_looks --sheet SHEET4`): blockouts
for proportion and placement, each wearing its stock's three classes as placeholders.

**Round one** (27 November; `docs/looks/minerva_white_rhino.png`, `2` the twinned fans, `3` the
tandem on each): A the long head, B the shoulder, C the low ram, the projector a horn on each and
the Drone on a cradle. His read of 28 November is above: A and C the shapes to start from, the
emitter tacked on, the guns of A and B without a field of fire, no real dock, the Drone flimsy.

**Round two** (28 November; `docs/looks/minerva_white_rhino4.png`): each hull is built round its
emitter, each gun has the road ahead clear, each Drone has a home in the hull, and each Drone is
an armoured body with its fans sunk in it.

- **D, the yoke** (from C). The hull's front is a horseshoe magnet: two armoured pole arms reach
  forward over the front wheels, coil windings round their roots, lit shoes on their tips and lit
  strips down their inner faces, a lit core in the throat between them; the cab looks down the
  gap. The gun ring is forward on the roof and fires down the gap. The Drone lives in a shielded
  bay sunk in the rear roof, its two lids stood open.
- **E, the turret** (from A, armoured: boxed wheel housings, a blunt bonnet, a push bar). The
  emitter is its turret, where a riot vehicle carries its cannon: a coil drum on trunnions over
  the cab, flaring to a lit dish. The Drone rides a saddle on the turret's bustle, so the two turn
  as one head. The gun and the rack are on the front housings, a bare mount on the bonnet.
- **F, the plates** (from C). Two great raked plates stand down the rear deck, the field's two
  poles, coil bands round them, lit under their caps and up their leading edges; the Drone docks
  in the trench between them on a pad, a charging arm from each plate. The gun ring is on the
  cab's roof ahead of them.
- **The Enforcer, three bodies.** The brick: two fan wells in tandem sunk in one armoured lozenge
  (the tandem made solid). The shield: four wells in a slab behind a broad front plate. The drum:
  one well in a deep armoured drum under a roll cage, on four stout legs. Each has a guard over
  its fans, a chin sensor with a lit lens, and a two-pronged stun fork. On the sheet D carries
  the brick, E the drum and F the shield; any body fits any dock.

## Open for the session

1. The look: D, E or F on round two's sheet, a mix of their parts, or his.
2. The Enforcer's body: the brick, the shield or the drum, or his.
3. The Drone's full name, without "class" (his of 28 November); Enforcer stands in gameplay text.
4. The designation, a session's draft from the roots he named: "TI-36W Threat Isolation Carrier".
5. Name clashes wait on the component audit (his: "We'll audit the components after, since the
   chassis texts should get first pick").
6. Its branches, for tier two.
7. Its numbers once the runner reads it (the bot to price a lock and the Drone's set-up first).

## What the session hands back

On his pick of a look, the model and the Drone's model built and judged running; the engine for
the Drone, Inverted Polarity and the lock's Suppress, with the bot's price for them; the content out of
planned, the rules' terms and the vocabulary's, and this brief retired.
