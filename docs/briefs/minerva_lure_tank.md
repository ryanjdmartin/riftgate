# Brief: the White Rhino, Minerva's tier-one tank (new chassis)

<!-- hangar: {"kind": "chassis", "maker": "minerva", "tier": 1, "status": "direction", "slot": true, "name": "White Rhino", "built": "white_rhino"} -->

The session designs Ryan's White Rhino, the lure tank of his 4-4-2: "THE tier-1 tank option, with
Storm Petrel a close second." Its kit is decided (25 to 27 November, the bible's White Rhino row)
and planned in content (`white_rhino`, its lock `rhino_lock`, the terms `entangle`, `entangled`
and `rhino_drone`), so what is left is its look and its Drone's model, the two names, and its
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
- 27 November: "I think we should try a half-track for this one, it's not a silhouette we have
  yet, right? I can't tell looks without seeing them, so I'll need mock ups. Entanglement itself
  is a little too high tech for Minerva, they sit more at the Kestrel range of pseudo-science.
  Something like Polarity Enforcer, magnetism related, harmonics or resonance related. Anything
  that would cause the field to isolate the two while they're connected. Whether that's
  physically or through some shared attribute that would make them, I guess, unaffected by
  others."

## The kit, decided

- **The Drone**, its passive: every weapon it uses on a Sprite moves the Drone to that use's
  target. Draft: "Resolve: If a weapon was used on a Sprite, move the Drone to the target."
- **The lock**, its Integrated equipment: a field that isolates the White Rhino and one Sprite
  while they are joined, magnetism or resonance, thrown from a projector that is its horn, such as
  it is; "Entangled" a working label until he names the term. Indirect, Entangle 2, Cooldown 1, heat 1,
  not Rapid, a Beam; as it resolves, the Sprite the Drone is on is Suppressed.
- **Entangled**, sealed both ways at half damage, a stack off at its Sprite's turn end, so it
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

## The look round (27 November): three half-tracks and the Drone

His: "I think we should try a half-track for this one, it's not a silhouette we have yet, right?
I can't tell looks without seeing them, so I'll need mock ups." No machine is a half-track (the
Echidna's look round drew one on 15 November and he took the armoured car), and the engine moves
five ways (tracked, walker, wheeled, hover, flyer), so the White Rhino is tracked for the rules
and a half-track to look at. The sheet is `docs/looks/minerva_white_rhino.png`, built by
`tools/lowforge/looks/rhino_looks.py` (`$BPY_PYTHON tools/lowforge/looks/sheet.py rhino_looks`):
blockouts for proportion and placement, not detail.

Every look carries the kit the same way: steered wheels forward under armoured wings, a track
unit under each side of the rear body, the lock's projector where a horn would stand (blunt and
squared, coil collars down it, a lit tip for its field), and the Drone on a cradle on top, where
an oxpecker rides. Minerva's steel and green; the white is in the name. Each wears its stock's
three classes as placeholders.

- **A, the long head.** A long armoured bonnet over the front axle, the projector off its tip
  angled up and forward; the cab the high point, broad-shouldered, with the Drone on its roof
  behind the brow; the gun on a ring on the lower rear deck.
- **B, the shoulder.** A short bonnet and a high armoured hump over the cab, the projector on the
  hump's brow, the Drone on the hump's crest behind it; the gun on the rear deck.
- **C, the low ram.** The cab forward over the wheels with a flat armoured face, the projector low
  between the wheels like a ram, a tall boxy body behind with overlapping skirts down the tracks,
  the Drone on a post at the rear corner.
- **The Drone.** A ducted fan in a hollow green ring, a pod hung under it with a lit lens and a
  stun prong at the nose, a small tail fin, two grip legs to perch on a Sprite.

## Open for the session

1. The look: A, B or C on the sheet, or his.
2. The lock's field and its names: magnetism or resonance (his of 27 November), the term for
   Entangled, the lock piece's name and the Drone's. His example, Polarity Enforcer, meets
   Aphelion's Polarity Projector (the Lammergeier's stock, a Shock debuff).
3. Its branches, for tier two.
4. Its numbers once the runner reads it (the bot to price a lock and the Drone's set-up first).

## What the session hands back

On his pick of a look, the model and the Drone's model built and judged running; the engine for
the Drone, Entangled and the lock's Suppress, with the bot's price for them; the content out of
planned, the rules' terms and the vocabulary's, and this brief retired.
