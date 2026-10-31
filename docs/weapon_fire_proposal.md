# The weapon-fire and hit-reaction package: a proposal

Ryan, 31 October: "In general, we need to improve our getting-hit-by-enemy and weapons-fire
animation package. It would obviously be really cool if the actual weapon from the die fired.
Obviously some custom work is needed for locked weapons, like ammit and badger claws, nemesis
fists, etc, but some of the idle animations can be repurposed and/or moved i'm sure."

This file is the proposal until Ryan evaluates it; its decisions then become bible rows and its
build the to-do's lines.

## What runs today

- A spend calls the attacker's `strike(ranged)`. Ranged, every joint that carries a hardpoint
  kicks about its own axis (a gun that runs in its port slides back along its line); melee, the
  joints marked to swing swing forward. Whichever weapon fired, every armed joint kicks.
- The attacker's sprite kicks back 8 pixels (ranged) or lunges 18 toward the target (melee, by
  the component's tag); the component's own sound lands on the blow.
- The target flashes (its modulate to 1.8, 1.4, 1.4 and back in a quarter second) and shakes
  side to side four times. A machine struck by a foe does the same; nothing on the model moves.
- Since 31 October the strike names the component that struck, and a burn weapon's fire on its
  class flares as it fires (the only part of a weapon that knows it fired).

## The proposal, in five pieces (each can land alone, in this order)

1. **The weapon that fired is the one that moves.** The strike already names its component;
   the view knows which pin carries it (the plan and the pin record). Only that pin's joint
   kicks, and a pin on the body (no joint) kicks the whole machine a little along the pin's
   line. A component on no pin (armour, vents, fixed equipment) kicks nothing.
2. **A muzzle flare on every class.** Each silhouette class gets a firing part at its business
   end, as the burn weapons got their fire: a flash at a barrel's muzzle, a puff from a rack's
   face, a pulse at a dish's core, a glint down a blade's edge. It flares as its weapon fires and
   wears the halo. Its colour says what struck, by the component's tags, in the glows' colour
   language (heat red to orange, a fire weapon red, shield blue for a shield's own projector);
   the tags' colours are Ryan's to set (below).
3. **The shot crosses the field.** A short 2D effect from the pin's place on screen (the view
   projects it) to the target: a tracer for a direct shot, an arc for an indirect one, a beam
   held for the blow's length for an energy weapon, nothing for melee (the lunge is the
   travel). It lands where the target flashes, when the sound says it lands.
4. **Locked and built-in weapons fire with their own acts.** The claws, the fists, the cryo
   racks, the lance: a sidecar names, for a component, the act (or a slice of one, start and end
   in seconds) that is its firing, played fast on the spend in place of the generic kick. Most
   exist already as idle acts and can be cut from them: the Honey Badger's claw test and boom
   raise, the Nemesis's fist pound, the Ammit's cannon raise and claw rear, the Armadillo's
   presented guns, the Stingray's lance charge, the Buzzard's cannon charge (too long as it is:
   its last second, the flare and the recoil, would be the shot). An idle act that becomes a
   firing stays an idle act too, unless Ryan would rather the two part.
5. **A hit on a machine moves the machine.** The model jolts away from the blow (the body's
   servo, as an act's body track moves it), a struck plate flashes for a beat where the blow
   lands (its side, from where the foe stands), and a blow the shield takes shows on the shield
   instead: a ripple in the shield's blue round the machine, the hull untouched. A kill on a
   machine (the hull at zero) gets its own beat: the lit parts gutter out and the outline dims.

## What it costs

Piece 1 is a day's work and changes no model. Piece 2 is the burn weapons' build again for the
other classes plus a colour per tag. Piece 3 is new 2D effects in the skirmish, a day or two.
Piece 4 is a sidecar key and a pass over the machines with locked weapons, a machine at a time,
judged running. Piece 5 is a rig behaviour and a shield effect, a day or two, judged running.

## The bench: ideas a rule set aside

- A projectile model flying in 3D from the gun to the foe: the foes are 2D sprites in their own
  space, not in the machines' scene, so a 3D shot cannot reach them; a 2D tracer can.
- Screen shake on every blow: the board is the player's reading surface, and shaking it on
  every spend costs reading for every blow; kept for a kill or a boss's blow, if at all.
- A white flash on a hit: the glows' rule (a lit part's colour says what it is; none flares to
  white) leans against it; a struck plate's flash in heat's red-orange keeps the language.

## Questions only Ryan can answer

- The flare's colour by tag: which tags get which colour (ballistic, plasma, energy, flame,
  cryo, electric...), or one colour for every shot?
- Should a weapon that fires also pull the machine's aim toward the foe first (a turret turning,
  an arm raising), or only fire where it points?
- Which locked weapons come first (the claws, the fists, the cryo racks, the lance)?
- The out-of-bounds list is his to write.
