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

## The kit, decided

- **The Drone**, its passive: every weapon it uses on a Sprite moves the Drone to that use's
  target. Draft: "Resolve: If a weapon was used on a Sprite, move the Drone to the target."
- **The lock**, its Integrated equipment: quantum entanglement, never a line, thrown as a tractor
  beam from a projector that is its horn, such as it is. Indirect, Entangle 2, Cooldown 1, heat 1,
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

## Claude's round on the look (27 November)

Nicknamed for how it acts, never drawn as the animal: the rhino reads in the mass and the lowered
front, and the kit's two pieces are its features, the lock's projector where a horn would stand
(his: "it can be the 'horn' such as it is"), and a cradle for the Drone. The projector is a
device, blunt and squared, with an emitter at its tip and coils down its length, so it reads as a
horn by where it stands and as a machine by what it is. While the lock holds, a beam joins the
projector to its Sprite: gameplay information, so its colour is checked against its grounds and
it carries structure besides hue (a travelling pulse along it). Minerva's livery, matte steel and
military green; the white is in the name.

- **Look A, the low tractor.** A long, low tracked hull with its weight forward over the front
  sprockets; the projector low on the nose, angled up and forward; the Drone's cradle on a raised
  rear deck. Plates overlap down the flanks in skirts.
- **Look B, the shouldered hauler.** Short and tall: a high armoured hump over the front tracks,
  the projector set on the brow of the hump and the engine decks falling away behind; the Drone
  perched on the crest of the hump, where an oxpecker rides.
- **The Drone, either look.** A single ducted fan in a ring body, a sensor nose with a lit lens
  and a short stun prong, two short grip legs. It rides its cradle, hops to the target of each
  weapon the White Rhino uses and perches there, and dives with the prong as the lock fires: a
  bird in how it moves, a machine in how it looks. A model of its own, which the screen moves.

## Open for the session

1. The look: A, B, or his.
2. The names of the Drone and the lock ("Lock" is his word as a working label, and the die's own
   lock wants it kept apart).
3. Its branches, for tier two.
4. Its numbers once the runner reads it (the bot to price a lock and the Drone's set-up first).

## What the session hands back

On his pick of a look, the model and the Drone's model built and judged running; the engine for
the Drone, Entangled and the lock's Suppress, with the bot's price for them; the content out of
planned, the rules' terms and the vocabulary's, and this brief retired.
