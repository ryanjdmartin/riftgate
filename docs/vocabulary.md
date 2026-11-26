# Riftgate vocabulary

Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.

Status: 213 implemented, 5 planned, 0 idea.

## Damage

| Term | Codex | Status |
|---|---|---|
| **Hit for N** | Shield takes it first, then Armour reduces it.
Barrier, Brittle and hit effects apply. | implemented |
| **Suffer N damage** | Not a hit. Shield takes it first.
Armour, Barrier, Brittle and hit effects do not apply. | implemented |
| **Lose N** | Comes straight off the Hull, HP or Shield named.
Nothing reduces or adds to it. | implemented |

## Resource

| Term | Codex | Status |
|---|---|---|
| **Hull** | Damage that gets past shield removes hull. Hull never recovers during a battle. At zero the machine is a wreck to be salvaged after the battle. | implemented |
| **HP** | A foe's health. What gets past its armour takes HP off, and at zero the foe falls. A machine's health is its hull. | implemented |
| **Shield** | Enemy damage hits shield before hull. A shield absorbs its number: a blow costs it its damage, and whatever it cannot absorb passes to the hull, armour coming off it there. Nothing mends a shield by itself: a reboot brings it back whole, and a component, a module or a passive may add to one that still stands, up to the chassis maximum. A shield at nothing is Broken, and takes none until its machine reboots. The shield is full as every fight opens, as the heat starts at zero; nothing returns on the map. | implemented |
| **Heat** | A component that prints heat adds it when spent, and it stays: nothing cools a machine by itself. Heat may pass the chassis maximum, and what stands past it is Overheated: at the end of your turn, before the enemy acts, it burns hull one for one, every turn it stands there, and the first such turn since the machine's last reboot breaks its shield. A reboot takes the heat to nothing; a vent, a module or a passive that cools takes some off, what stands past the maximum first. A machine the burn wrecks is lost on its own turn. Foes never add heat: a Scorched machine's weapons and equipment aimed at foes run hotter for the turn. | implemented |
| **Reroll** | Two rerolls per round, each rerolling every unlocked, unspent die. A reroll lands on any other component on the die, never the one showing; a second copy of the same component may come up. Rerolls may be spent before or after attacking, so a low damage roll is information for the rest of the round. Never pooled across rounds, unless a Giant Petrel fights: its Maverick's Playbook banks up to three left unspent as your turn ends, for the next round. | implemented |
| **Rift Pressure** | Ticks once per battlefield phase, never inside a fight. It fills at the ramp's beat (3 turns, 2 from Convergence 8), a turn short of its peak as a battle opens, and the beat halves once at the Rupture. When full it resets and peaks: the rift and every tear open before the peak each send 2 packs, a hunting pack comes out of the rift every second peak, and new tears open, each peak's nearer the wall. It never stops: the boss's seal breaking does not quiet it. | implemented |
| **Rupture meter** | Fills by the menace of the packs you kill, in any fight however it ends, toward the tier's Fractures (three, four or five), each later one costing more. The last, the Rupture, takes the packs the field opens with and the rift's first two peaks send, one lone patrol left over, and 4 more for each elite the tier's Fractures bring. The Rupture breaks the boss's seal, and nothing else does: a cleared field is breathing room until the next peak. | implemented |
| **Fracture** | A step of the Rupture meter, paid out as a fight ends. At the Fractures the tier names (tier one's first; tier two's first and third; tier three's first, second and fourth) an elite emerges at the rift, the lead domain's elites in turn and never twice in a battle. The last Fracture is the Rupture. | implemented |
| **Gate Integrity** | Each pusher makes for the stretch of the wall its threat rating sends it to: the ends for 1, the middle for 3, between them for 2. A pusher that ends its walk beside any hex of the gate or the wall strikes the gate's bar every turn: 5 for each Frame it is a fight for, less as it loses Sprites, at least 1. The whole wall is the target, so no line plugs it. Gate integrity persists across battles and is repaired in the meta. | implemented |
| **Sustained Recoil** | Max 5 stacks. At 5 stacks, the next weapon hit deals double damage. | implemented |
| **Armour** | A chassis number taken off every blow that reaches the hull, flat, never a percentage: a blow on bare hull and what passes a shield alike. A blow at or under the armour does nothing to the hull. Shield is not armoured: a blow on shield costs the shield its full damage. | implemented |
| **Ore** | Machine store, the Honey Badger's hopper: every foe its weapons damage puts an Ore in it, up to three, and every raise its upgrades grant adds to that. Its Bullion Fragmenter empties it, a strike for every Ore, and puts none back. Lasts the skirmish; never decays, and no cleanse or Purge touches it. | implemented |
| **Muster** | Machine store, the Swallowtail's: a charge its Integrated components spend for their charged forms. Every die that rolls fills it a sliver, about thirty rolls a charge, and a kill by its own guns five rolls' worth; stored up to its cap. Starts each fight empty and never decays; a store, so no Purge touches it. With a charge up, its Integrated components go out charged unasked, unless the charged form has nowhere to land; then the plain form goes out and the charge waits. | implemented |
| **Ammo** | The Musk Ox's magazine, a row of cells under its heat bar, a cell an ammo. Its weapons spend ammo instead of heating it: 1 for every 2 heat a gun would make, rounded up, at least 1, the price printed where the gun's heat would be; a foe's Scorched still heats them. The magazine holds 10, opens each fight at 3 and gains 1 at the start of every round after the first; a vent the Musk Ox spends on itself adds 3, a shield 2, an entry that is both 3, once. With too little left, a gun cannot be spent (DRY). | implemented |
| **Momentum** | Maximum 10.
Gained by Burrowed and Applied Momentum.
Drained by Applied Momentum. | implemented |

## Kit

| Term | Codex | Status |
|---|---|---|
| **Component** | A piece of kit on a machine, and one entry on its die. There is no generic kit: every entry on a die is a component, or an empty hardpoint. Each round the die is rolled and the component that comes up is what the machine can do. | implemented |
| **Hardpoint** | A free slot on the chassis. Any component fits any hardpoint. On the model a hardpoint is a socket where the component mounts. | implemented |
| **Integrated component** | A component built into the chassis. Always on the die and uses no hardpoint. Cannot be removed, sold or built. No other Frame carries it. | implemented |
| **Empty hardpoint** | A hardpoint with nothing in it is an entry on the die that does nothing when it comes up. Nothing fills it for you. | implemented |
| **Module** | Kit inside the machine, not on its die: a few numbers up or down, and at most one rule of its own. A chassis has its module slots (two, three on the Clydesdale), and a module is never spent: it is always working. | implemented |

## Component Kind

| Term | Codex | Status |
|---|---|---|
| **Weapon** | A component that deals damage. Used on a Sprite within reach: deals its damage, then its keywords apply. | implemented |
| **Equipment** | A component that deals no damage: a buff used on a Frame, or a debuff used on a Sprite within reach. | implemented |
| **Buff component** | Equipment used on a Frame. Applies the status and stacks shown on the die. | implemented |

## Component Property

| Term | Codex | Status |
|---|---|---|
| **Swap** | Second target: another Sprite or an empty slot.
Resolve: The target and the second target swap places. Massive Sprites cannot move. | implemented |
| **Volatile** | Commit: Lose {N} Hull. | implemented |
| **Shield cost** | Commit: Lose {N} Shield.
Cannot be used without enough Shield. | implemented |
| **Targets** | Which Frames this can be used on, shown as three hexes under its mark: the middle is this Frame, the sides are the other Frames. A filled hex can be chosen. | implemented |
| **Cooldown** | Resolve: This entry goes dark for the rest of the round and the next {N} rounds.
A dark entry can be rolled but not used. | implemented |
| **Gather** | Resolve: Every other Sprite's Mine merges into the target's Mine. | implemented |
| **Detonate** | Resolve: The target's Mine goes off, including this use's addition. | implemented |
| **On itself** | Resolve: This Frame gains the status shown. Where shown: once per Sprite hit, up to the cap shown. | implemented |
| **An ally's action** | Resolve: If the target Frame's die is used, spend {N} rerolls to reroll it onto a different entry. It can act again. | implemented |
| **Rolls its die** | Resolve: The target's die rerolls onto a different entry. A used die cannot reroll. | implemented |
| **Rerolls a kill** | Resolve: If any Sprite hit was defeated, gain {N} rerolls. | implemented |
| **Grants a reroll** | Resolve: Gain {N} rerolls. | implemented |
| **Vents all** | Commit: Reduce Heat to 0. +X damage per Y Heat vented, as shown on the entry. | implemented |
| **Fires the shield** | Commit: Reduce Shield to 0. +X damage per Y Shield spent, as shown on the entry. | implemented |
| **Passes heat** | Resolve: Move all of this Frame's Heat to the target. The target gains 1 stack of the shown status per Y Heat moved, rounded down. | implemented |
| **Grows with missing HP** | Commit: +X damage per Y HP the target is missing, as shown on the entry. | implemented |
| **Finisher** | Commit: If the target is at or below half Max HP, double base damage. | implemented |
| **Fixed** | Only the specified component may be used. | implemented |
| **Gated** | The keyword applies only to Sprites that meet its condition at Commit. | implemented |
| **Consumes** | Hit: If a weapon, consume all stacks of the named status on the Sprite hit. +{N} damage per stack consumed.
Commit: If equipment, consume up to {N} of the named count from this Frame. Gain 1 stack of the granted status per one consumed.
Equipment cannot be used with nothing to consume. | implemented |
| **Ablates its firer** | Resolve: Apply {N} Ablate to this Frame. | implemented |
| **Ignores Armour** | Armour does not reduce the damage. | implemented |
| **Empties the hopper** | Commit: Consume all Ore. Hit once per Ore consumed. No Ore is gained from these hits.
Cannot be used without Ore. | implemented |
| **Braces** | Resolve: Apply {N} Armoured to this Frame. | implemented |
| **Strikes** | Hits per use. Each hit deals full damage and is reduced by Armour separately. | implemented |

## Reach

| Term | Codex | Status |
|---|---|---|
| **Direct** | Targets front-rank Sprites, back-rank Sprites with nothing in front, and Exposed Sprites. | implemented |
| **Indirect** | Targets any Sprite. | implemented |
| **Every Sprite** | Hits every Sprite for full damage. No hit is Targeted. | implemented |
| **Every Frame** | Applies to every Frame, including this one. | implemented |
| **Every Other Frame** | Applies to every Frame except this one. | implemented |

## Keyword

| Term | Codex | Status |
|---|---|---|
| **Spread** | Also hits all Sprites beside the target, dealing {N} damage. | implemented |
| **Penetrate** | Also hits all other Sprites in the same column, dealing {N} damage. | implemented |
| **Cryo** | Resolve: Apply {N} Cryo per hit to each Sprite hit. | implemented |
| **Ablate** | Resolve: Apply {N} Ablate per hit to each unit hit. | implemented |
| **Lure** | Hit: Change intended target to this Frame. | implemented |
| **Shock** | Resolve: Apply Shocked to each Sprite hit. | implemented |
| **Expose** | Resolve: Apply 2 Exposed to each unit hit. | implemented |
| **Disrupt** | Resolve: Sprites hit switch to the next move they can use, keeping their target. | implemented |
| **Suppress** | Resolve: Apply Suppressed to each Sprite hit. | implemented |
| **Brittle** | Resolve: Apply {N} Brittle per hit to each unit hit. | implemented |
| **Sap** | Resolve: Apply {N} Sapped per hit to each Sprite hit. | implemented |
| **Chain** | Resolve: All Sprites with Shock lose {N} HP. | implemented |
| **Rapid** | Resolve: Reroll this die for free, never onto this entry. This entry goes dark for the rest of the round. | implemented |
| **Instant** | Resolve: Reroll this die for free. May land on this entry again. | implemented |
| **Jam** | Resolve: Apply Jammed to the entry shown by each Frame hit. | implemented |
| **Destroy** | After Hit: If Hull damage was dealt, destroy the entry the target's die shows. | implemented |
| **Corrupt** | Resolve: Apply {N} Corrupted per hit to the entry shown by each Frame hit. | implemented |
| **Purge** | Resolve: Reduce stacks of every Buff on each unit hit by {N}. | implemented |
| **Cleanse** | Resolve: Remove every Debuff from the target, except those that cannot be cleansed. | implemented |

## Status

| Term | Codex | Status |
|---|---|---|
| **Juggernaut Drive** | Weapons Gain:
  Ignores Armour.
  Resolve: Consumed. | implemented |
| **Numbed** | When Suppressed would be applied: Prevent it and reduce stacks by 1.
Turn End: Reduce stacks by 1. | implemented |
| **Paradox** | When another Debuff is applied: Gain 1 stack per stack applied.
At 5 or more stacks: Reduce stacks to 0 and gain Suppressed. | implemented |
| **Shocked** | Hit By Weapon: If targeted, consume to double damage received, before applying defensive effects.
Conducts Chain. | implemented |
| **Pinned** | When Brittle would be reduced: Consumed to prevent it.
Turn End: If there is no Brittle, removed. | implemented |
| **Seared** | When Ablate would be reduced: Consumed to prevent it.
Turn End: Removed. | implemented |
| **Sapped** | Attacks Gain:
  Hit: -1 damage dealt per stack ({N}).
Turn End: Reduce stacks to 0. | implemented |
| **Exposed** | All armour is negated.
Exposed Sprites can be targeted regardless of reach.
Sprites are forced to target an Exposed Frame at round start.
Turn Start: Reduce stacks by 1. | implemented |
| **Empowered** | Attacks Gain:
  Hit: +1 damage dealt per stack ({N}).
Turn End: Reduce stacks by half, rounded down. | implemented |
| **Sealed** | +3 Armour.
Cooling disabled.
Turn End: Gain 3 Heat.
Weapons Gain:
  Resolve: Removed.
On Reboot: Removed. | implemented |
| **Changed Over** | The die rolls the second battery, not the first.
Lasts the battle. | implemented |
| **Cryo** | Hit By Weapon: Consume all stacks. The attacker loses 1 Heat per stack ({N}). | implemented |
| **Armoured** | +1 Armour per stack ({N}).
Turn Start: Reduce stacks to 0. | implemented |
| **Hardened Light** | When Hit: If Shield is up, -1 damage received per stack ({N}).
Shield Broken: Reduce stacks to 0. | implemented |
| **Primed** | Attacks Gain:
  Resolve: Apply 1 Ablate per hit to each unit hit, then reduce stacks by 1. | implemented |
| **Jammed** | This entry comes up blank.
On Reboot: Removed. | implemented |
| **Corrupted** | Commit: Suffer 3 damage per stack ({N}).
On Reboot: Reduce stacks to 0. | implemented |
| **Phased** | Cannot be damaged, targeted or hit by anything.
Round End: Removed. | implemented |
| **Ablate** | Turn End: Suffer 1 damage per stack ({N}), then reduce stacks by 1. | implemented |
| **Suppressed** | May not act.
Turn End: Removed. Gain Numbed equal to stun resist: 1, 2 if massive, 3 if elite, hero or boss. | implemented |
| **Vitriol** | Turn End: Lose 10% of current HP per stack ({N}), rounded down, then reduce stacks by 1.
Cannot reduce HP below 1. | implemented |
| **Web Bomb** | Round End: Consumed to apply Suppressed to this Sprite and the nearest Sprite to its right in the same rank, or to its left if none. | implemented |
| **Spun Up** | Weapons Gain:
  Commit: Consume all stacks to gain +1 damage per stack ({N}). | implemented |
| **Ricochet** | Weapons Gain:
  Resolve: Hit the target again once per stack ({N}) for 1 damage. No effect of the weapon applies.
Hull Damaged: Reduce stacks by half, rounded down.
Lasts the skirmish. | implemented |
| **Essence** | When any Sprite is defeated: Gain 1 Essence.
Skirmish Start: Gain 1 Empowered per 5 Essence.
Round End: If this Frame killed a Sprite this round, gain 1 Empowered per 5 Essence.
Lasts the battle. | implemented |
| **Offhand** | Uses on a Sprite Gain:
  The armament shown.
  Resolve: Switch to the next armament.
Skirmish Start: Switch to the first armament. | implemented |
| **Aile Boost** | Weapons Gain:
  Indirect.
  Resolve: Consumed. | implemented |
| **Aile Blitz** | Weapons Gain:
  Indirect.
  Ignores Armour.
  Resolve: Consumed. | implemented |
| **Aile Assault** | Weapons Gain:
  Indirect.
  Resolve: Consumed. | implemented |
| **Parry** | Counts damage prevented by Armour and Barrier from Sprite hits this round.
Turn Start: The first weapon hit this turn gains +1 damage per 2 damage counted.
Resolve: If a weapon was used, consumed.
Turn End: Removed. | implemented |
| **Essence Flare** | Empowered on any unit is not reduced.
Round End: Removed. | implemented |
| **Brittle** | When Hit: +1 damage received per stack ({N}).
Turn Start: Reduce stacks by half, rounded down. | implemented |
| **Destroyed component** | This entry is blank for the rest of the battle. Passive bonuses still apply. Passive abilities do not.
After the battle: an Integrated component is rebuilt, a hardpoint's component is lost. | implemented |
| **Mine** | Uses aimed at this Sprite by the Frame that laid it add their damage and riders to the Mine.
When defeated: The Mine goes off, hitting every Sprite around it for 1 damage per stack ({N}), with its riders. | implemented |
| **Rage** | Immune to all Debuffs.
Fixed: Knuckles of Fury
Reboot disabled.
At 0 Heat: Consumed to Reboot immediately. | implemented |
| **Ore** | At 3 Ore, base Armour increases by 1. | implemented |
| **Scorched** | Uses on a Sprite Gain:
  Commit: +1 Heat per stack ({N}).
Turn End: Reduce stacks to 0. | implemented |
| **Overheated** | Stacks equal Heat above Max Heat.
Turn End: Lose 1 Hull per stack ({N}). The first time since the last Reboot, reduce Shield to 0.
On Reboot: Reduce stacks to 0.
Cannot be cleansed. | implemented |
| **Broken** | Applied when Shield reaches 0. Shield cannot be gained.
Removed when a Reboot restores Shield.
Cannot be cleansed. | implemented |
| **Rebooting** | Applied by dragging the die of a Frame that has used nothing this turn onto REBOOT. Shield and Heat drop to 0 at once.
Turn Start: Consumed to restore Shield to max and remove Broken. | implemented |
| **Enraged** | Attacks Gain:
  Hit: +1 damage dealt per stack ({N}).
When you use a component that is not a weapon: Gain 1 stack.
Lasts the skirmish. | implemented |
| **Golden** | Attacks Gain:
  Hit: +2 damage dealt.
+1 Armour.
Gain Suppressed upon losing 25% Max HP since the start of the effect.
On Suppressed: Reduce stacks to 0.
Turn End: Reduce stacks by 1. | implemented |
| **Undying** | When defeated: Consumed to return with full HP, acting from next round. | implemented |
| **Aloft** | Cannot be targeted or hit. Other statuses still count down.
Removed when its gathered move lands. | implemented |
| **Appropriated** | Holds the stolen component's number: a weapon's damage, otherwise 1.
Consumed by the next Borrowed Blade, which deals this number. | implemented |
| **Swallowed** | Cannot act. All ongoing effects are paused.
Immune to all damage. Cannot be targeted or hit by anything.
Round End: Reduce stacks by 1.
Reduce stacks to 0 upon {caster} losing 25% Max HP since the start of the effect.
Cannot be cleansed. | implemented |
| **Guarded** | Immune to all damage while every part stands. | implemented |
| **Ability** | A unit's own rule. Not a Buff or Debuff, so no Purge or Cleanse removes it. | implemented |
| **Barrier** | When Hit: Consumed to reduce damage to 0.
Turn Start: Removed. | implemented |
| **Ward** | Blocks every Debuff and Purge from the other side. Damage still applies.
Turn Start: Removed. | implemented |
| **Charged** | Weapons Gain:
  Shock.
  Resolve: Reduce stacks by 1. | implemented |
| **Supercooled** | Weapons Gain:
  Cryo 1.
  Resolve: Reduce stacks by 1. | implemented |
| **Regenerating** | Turn End: Gain 1 Shield per stack ({N}) on a Frame, or 1 HP per stack on a Sprite, then reduce stacks by 1. | implemented |
| **Burrowed** | +1 Armour.
Fixed: Inertia Drill
Turn Start: Remove Broken, Overheated, Jammed and Corrupted. Gain 3 Shield and 5 Momentum, and lose 6 Heat.
Inertia Drill Gains:
  Resolve: Removed. | implemented |
| **Applied Momentum** | Turn Start: Gain 1 Brittle and Pinned. Then, take a hit for 1 damage and drain 5 Momentum from the Mole. If 0 Momentum, removed and returned to the Mole.
Resolve: If hit, the Mole gains 1 Momentum. | implemented |
| **Frozen Momentum** | Turn Start: Gain 2 Brittle, 1 Cryo, Pinned, and Frozen. Then, take a hit for 1 damage and drain 5 Momentum from the Mole. If 0 Momentum, removed and returned to the Mole.
Resolve: If hit, the Mole gains 1 Momentum. | implemented |
| **Heated Momentum** | Turn Start: Gain 1 Brittle, 2 Ablate, Pinned, and Seared. Then, drain 5 Momentum from the Mole. If 0 Momentum, removed and returned to the Mole.
Resolve: If hit, the Mole gains 1 Momentum. | implemented |
| **Frozen** | When Cryo would be consumed: Consumed to prevent it. Consume 1 Numbed, if any. | implemented |
| **Drill Out** | Removed when Applied Momentum returns to the Mole.
On Burrowed: Removed. | implemented |
| **Sonic Needle** | Gain 1 stack per hit from the Frame that laid it, and per hit this Sprite lands on that Frame.
Conducts Chain.
At 3 or more stacks: Chain 2 fires. Reduce stacks to 0. | implemented |

## Formation

| Term | Codex | Status |
|---|---|---|
| **Front rank** | Four slots, one a column. Front-rank foes fill these. Always in Direct reach. | implemented |
| **Back rank** | Four slots behind the front. Back-rank foes hold these. | implemented |
| **Massive** | A massive foe fills both slots of a column and counts as front rank. Its column is never exposed while it stands. Some of the rank and file are massive, the treants and the sandworms among them, and some elites and bosses. | implemented |
| **Strike order** | Foes strike in the order they stand: front rank left to right, then the back rank. Each blow is resolved on its own against the shield standing at that moment, so which foe strikes first decides what a small shield takes. A pack stands as its composition's grid has it; a boss's fight and a final stand heaviest hitters first from the left. | implemented |

## Battlefield

| Term | Codex | Status |
|---|---|---|
| **Movespeed** | Move in hexes: how far a machine goes in an action, a step a hex. Water costs a ground machine two; a hovercraft and a flyer cross it at one; walls are the flyer's alone. | implemented |
| **Walk** | The map shows where every pack will walk on the enemy's turn, worked out from where your machines' plans end: a pusher toward the gate, a hunter toward its prey. Packs walk through your machines and the wrecks, never ending a walk on one, so nothing you do stops one. | implemented |
| **Fight** | Tap a pack to attack it. One pack is one fight: nothing joins it, and you commit the machines beside it. Orders onto several packs play one fight at a time, each resolved before the next and fought to its end; a machine that fought, won or lost, is spent until your next turn. | implemented |
| **Spent** | A machine that has fought this turn is spent: it cannot move or fight again until your next turn. A machine whose passive grants a second action has two before it is spent. | implemented |
| **Carry** | A machine that carries (the Swallowtail's Muster Deck) lifts the machines on the hexes beside it when it moves: they travel as a ring round it and land as a block, each where it rode from it, keeping whatever move and action they had. It cannot stop where a rider would land on a hex it cannot stand on (NO ROOM). A caught machine does not ride. | implemented |
| **Caught** | A machine a hunter has caught fights it first on your turn, before any other fight, and cannot move until then. Others in range may join that fight. It is fought to its end: the hunter falls or the machine is wrecked. | implemented |
| **Engage range** | A hunter catches what stands beside where its walk ends: the engage range, one hex, the same reach every unit has on the map, so a machine joins a fight on a pack beside it and a hunter catches its prey beside it. No ring is drawn: a hunter wears a chip with the machine it comes for. No pack joins a fight; one pack is one fight. | implemented |
| **Behaviour** | A pack pushes unless its composition hunts. A pusher walks toward the gate and threatens nothing else. A hunter locks one machine, by its caveat (the nearest, weakest, strongest or slowest), puts its tag on it and walks toward it; when it ends its walk beside its prey it has caught it, and that fight comes first on your next turn. A caught machine cannot move until the fight, and is caught again while the hunter lives. A prey that keeps its distance is safe, and so is one no hex beside can be stood on that turn: its prey is the only machine a hunter catches, and nothing stands in for it. | implemented |
| **Pack** | An enemy hex is a pack: a composition on one hex, its members listed on a hold, wearing its lead's picture, hunting when its composition says so, walking at its slowest member's pace. Its hold says first how many machines it is a fight for, its threat rating; a pusher walks to a segment of the wall of its own. A fight is the one pack you attack. A boss is one unit on one hex. | implemented |
| **Footprint** | Every unit covers one hex, the boss included: it is occupied, counts for range, and is a tap target. The gate and the rift are wider structures. | implemented |
| **Structure** | Gate and rift hexes are structures wider than one hex. Nobody stands on them. A pack that ends its walk beside a gate hex or a wall hex strikes the gate. A tear is a mouth, not a structure: its hex can be walked and stood on. | implemented |
| **Spawn** | At a peak of Rift Pressure the rift sends 2 packs, each to a stretch of the wall of its own, and every tear open before the peak sends 2 to the wall near it. The pack for a stretch is the next of its threat rating the domain has, the lead domain's and the guest's in turn. A spawn lands on the nearest free hex to its mouth with no Frame beside it, the rift's outside its shell on the side they are headed, at the end of the enemy's turn, so you see it and its walk for a whole turn and nothing lands on top of a detachment. | implemented |
| **Composition** | What the rift sends and what stands on the field when a battle starts: a patrol (a few foes, a fight for one machine or a pair), a formation (the body's fight), an elite leading its own, or a boss's escort. A composition is one pack on one hex: its members, listed on a hold, unpack into the fight together and come back by member. Each domain writes its compositions by tier, each dealt across a band of the ramp; the ramp sets how many stand at the start, never how thick they are. | implemented |
| **Patrol** | The small composition: a few foes, a fight for one machine or for a pair, the threat rating its hold shows. Its threat rating says where it makes for: 1 the wall's ends, 2 between the ends and the middle. | implemented |
| **Formation** | The body's composition: a fight for three machines, the threat rating its hold shows. It makes for the middle of the wall. 1 stands before it at the start (2 from Convergence 3, 3 from 8). A domain's tier writes its formations; the lead's and the guest's come in turn. | implemented |
| **Tear** | A mouth beside the rift's. At a peak of Rift Pressure the ramp's count of tears (one; two from Convergence 8) open on a row a few past the rift (row 4 at twelve deep), each peak's a row nearer the wall and never beside it, as far from the rift and the other tears as the row allows, and every tear open before the peak sends 2 packs to the wall near it. A tear opens a peak before it first sends, so where the next flood comes from is known an interval ahead. Tears stay open and never close. | implemented |
| **Seam** | The flattening's edge: a circle about the rift, four hexes out as a battle opens and half a hex wider every round, stopping at the foot of the wall. It is a picture alone: no rule reads the ground inside it, and a tear opens wherever its own row has room. | implemented |

## Terrain

| Term | Codex | Status |
|---|---|---|
| **Plain** | Open ground. Every machine and pack crosses it. | implemented |
| **Road** | Open ground, the same as plain: the road is art. Every machine and pack crosses it. | implemented |
| **Rough** | Forest and scrub. Every machine and pack crosses it. | implemented |
| **Ruins** | Rubble. Every machine and pack crosses it. | implemented |
| **Water** | Tracks, walkers and wheels wade it, a hex costing two of their move; hovercraft and flyers cross it at full pace. Packs wade it as the ground machines do; a winged pack crosses it. | implemented |
| **Crags** | Rock spikes. Impassable, except to flyers and winged packs. | implemented |
| **Mesas** | Flat-topped rock. Impassable, except to flyers and winged packs. | implemented |
| **Towers** | Dead skyscrapers. Impassable, except to flyers and winged packs. | implemented |
| **Cliffs** | A wall of rock. Impassable, except to flyers and winged packs. | implemented |
| **Chasms** | A sheer drop. Impassable, except to flyers and winged packs. | implemented |

## Trait

| Term | Codex | Status |
|---|---|---|
| **Flyer** | Crosses everything, water and walls included. It flies over machines and packs, and they pass under it, but nothing stops on another's hex. | implemented |
| **Hover** | Skims water at full pace; walls stop it. | implemented |
| **Walker** | Legs. Wades water at half pace. | implemented |
| **Tracked** | Tracks. Wades water at half pace. | implemented |
| **Wheeled** | Wheels. Wades water at half pace. | implemented |
| **City defense** | A wall segment's upgrade the foes can strike, the gate's flanking guns first and turrets later. Not on the field yet. | planned |

## Trigger

| Term | Codex | Status |
|---|---|---|
| **On attack** | Passive trigger. Fires on every attack, after its number is read. Effects: multiply or add damage or heat, multiply the printed number alone before any buff (the Kite's double, on an unhurt foe), or set a minimum damage. | implemented |
| **On struck** | Passive trigger. Fires when a foe's blow lands on this machine, a time a blow, whatever the blow dealt: it gains heat, or lays a status on the striker. A blow that wrecks the machine gains and lays nothing. | implemented |
| **On shield gain** | Passive trigger. Fires when this machine gains shield from any source, with the amount gained; it may shed heat or grant a status, never raise more shield. | implemented |
| **On shielding an ally** | Passive trigger. Fires when this machine spends a shield component on an ally, with the shield's size; it may shed the ally's heat or grant the ally a status, never raise more shield. It never fires for a shield on itself. | implemented |
| **On buffing an ally** | Passive trigger. Fires when this machine spends a piece of equipment on an ally, once for each ally it lands on, whatever the equipment did; it may take some of the ally's heat onto this machine. It never fires for equipment on itself. | implemented |
| **On heat gain** | Passive trigger. Fires when this machine gains heat, with the amount; it may raise shield or grant a status, never add heat. | implemented |
| **On skirmish start** | Passive trigger. Fires once as the skirmish begins, before the first roll: a shield, a vent, a status. | implemented |
| **On foe status** | Passive trigger. Fires when any foe gains a status, whoever applied it: once for each status a spend puts on a foe, however many strikes or stacks (an application, not a stack). Never for Paradox, nor for the Suppressed a Paradox causes, and Numbed is no status. Effects: paradox (the foe gains a stack of Paradox; at the count it is Suppressed and the Paradox clears). | implemented |
| **On applying stacks** | Passive trigger. Fires when this machine applies stacks of a status to anyone: a foe's Ablate (from an Ablate or from Primed), an ally's or its own buff, its own Empowered from a kill. Effects: add_stacks (so many stacks more, flat or for every so much heat the machine carries). Never for Numbed, which is exempt from every interaction. | implemented |
| **On hull damage** | Passive trigger. Fires when this machine loses hull: to a blow, a bite or an overheat. | implemented |
| **On a blow blocked** | Passive trigger. Fires once for every blow of this machine's weapons that a living foe's armour or Barrier takes whole, each foe's of an area and each strike's. | implemented |
| **Turn Start** | Passive trigger. Fires as this machine's turn starts, after a reboot's recovery and before its die rolls. | implemented |
| **On gaining a Barrier** | Passive trigger. Fires as this machine gains a Barrier, from its own equipment or an ally's. | implemented |
| **On a kill** | Passive trigger. Fires once after an attack of this machine's that killed, however many foes fell to it, chains and spills included: a status, a shield (the Kite's, recharged whole) or a vent. | implemented |
| **At the end of a round it killed in** | Passive trigger. Fires as the round ends, after the enemy's turn, for a machine whose own attack killed in that round: once, however many foes fell and however many attacks felled them (the Ammit's flare). | implemented |
| **On a foe killed** | Passive trigger. Fires as a death check counts a kill in this machine's fight, whoever or whatever made it, an ally's blow, an Ablate tick and a Mine's blast among them: a status, once for each foe that fell (the Ammit's Essence), or a shield gain like any (the Buzzard's). | implemented |
| **On damaging a foe** | Passive trigger. Fires after a spend of this machine's weapons that took HP off a foe, however many foes it hurt: a status, a shield or a vent. An effect may fire once a round only (the Skua's stack of Ricochet). | implemented |
| **On use** | Passive trigger. Fires once after every use of this machine's components, its hits all done (Resolve), whatever the component: a status of its own (the Cassowary's Deadeye II, a Sustained Recoil). A blank entry is no use and fires nothing. | implemented |
| **On injury** | Passive trigger. Fires when a blow would destroy a component (a foe's Destroy, any of it on the hull). Effects: no_destroy (the component holds instead of being destroyed). | implemented |
| **Always on** | Passive trigger. Its effects change a machine's numbers or a component's properties while a condition holds, rather than firing on an event: add_stat and multiply_stat on hull, shield, heat maximum, armour, move, cooling or shield regen; add_damage_taken and multiply_damage_taken on every incoming blow; set_reach on a component (direct or indirect while a condition holds); suppress, which turns off another effect by id or tag; and the rules a passive writes on its machine's entries, the star on the die: ignore_armour, and spillover (the Overrun Gearing's: damage past a kill in the front rank carries into the foe behind it in the same column, nothing standing behind a massive foe). | implemented |

## Commander

| Term | Codex | Status |
|---|---|---|
| **Command die** | One die rolled alongside the machines' dice each round. Its entries are rechargeable commander abilities and never deal damage. They come from the hangar, never from rewards. Die size is a research path. | planned |
| **One-shot** | Consumable ability. A pouch of three: a fourth forces a use or a discard. One comes from a Fracture's pick, and a starting stock chosen in the hangar restocks every battle. It expires when the rift closes. | planned |
| **Reward pick** | Not built: a Fracture brings no prize, and whether one should is open. If it comes, a Fracture grants one, unweighted by domain: one of three, a battle-long modifier on a component you carry, a one-shot, or a battle-wide boon (an extra reroll a round). | planned |

## City

| Term | Codex | Status |
|---|---|---|
| **City ability** | Battlefield-level ability owned and upgraded by the city: sprint, airlift, teleport, tractor beam, orbital strike. Cooldowns measured in phases. | planned |
| **Tier** | The hard scaling: a rift's tier is locked as the rift opens and sets the kind of battle: who comes, the sizes of its compositions, the Fractures to the Rupture, how many elites and which, the boss's numbers and escort. The Convergence's tier rises one every four; a rift keeps the tier it opened at, so an old rift never hardens by waiting. | implemented |
| **Ramp** | The soft scaling under the tier, never shown: the Convergence as it stands when a battle starts sets how many compositions stand on the field at the start and which of the tier's variants are dealt, how fast Rift Pressure fills, how many tears open at a peak and how far each peak's open toward the wall. It scales no pack. It rises with the run, the same for every open front, and never resets. | implemented |

## Foe

| Term | Codex | Status |
|---|---|---|
| **Immune** | Immune to the effect named on the chip. | implemented |
| **Drain** | After Hit: Heal HP equal to the Hull damage dealt. | implemented |
| **Timid** | Attacks only while carrying a Buff, or with a Buff announced for it. | implemented |
| **Swallow** | Round End: Apply {N} Swallowed to the target.
Cannot target the last Frame able to act. | implemented |
| **Golden Rage** | Turn End: Gain {N} Golden.
Only usable while not Golden. | implemented |
| **Merge** | Absorbs every other Sprite of the named kinds, healing the HP they had left, up to Max HP.
Gain {N} Empowered per Sprite absorbed. | implemented |
| **Aim** | How a Sprite picks its target at round start, shown as its arrow.
Strongest: most Hull plus Shield.
Weakest: least Hull plus Shield.
Hottest: most Heat.
Most buffed: most Buff stacks.
No word: any Frame. Ties are random.
Never targets a Frame its hits would already wreck while another stands. | implemented |
| **Self-Destruct** | Resolve: This Sprite is removed. It cannot return. | implemented |
| **Every Frame** | Hits every Frame. No target, so Lure cannot move it. | implemented |
| **Last Act** | When defeated: Use this move at once. A single-target move hits the Frame that killed it, or nothing if no Frame did. | implemented |
| **Parts** | A core and its parts. While every part stands, the core is Guarded. A defeated part may grow back. When the core is defeated, its parts are defeated. | implemented |
| **Countdown** | Lands {N} rounds after it is announced. Nothing hits while it gathers.
Suppress delays it 1 round. Disrupt cancels it. | implemented |
| **Follow-up** | Names the move its Sprite announces next round. Suppress or Disrupt on the first cancels the second. Once announced, the second can be Suppressed but not Disrupted. | implemented |
| **Grudge** | +1 damage per Sprite the team has killed this skirmish. | implemented |
| **Sprite move** | Each round every Sprite picks a move and a target before your turn, shown on its intent chip. Attack damage is the Sprite's attack times the move's factor. | implemented |
| **Scorch** | Resolve: Apply {N} Scorched per hit to each Frame hit. | implemented |
| **Menace** | A pack's threat rating: a patrol 1 or 2, a formation 3, an elite or a boss 4. The Rupture meter, Anathema and salvage count it. Killing a pack pays its remaining Menace. | implemented |
| **Elite** | A unique Sprite leading its own pack, rated 4 Menace, arriving at a Fracture. It stands at the battle's tier. | implemented |
| **Seal** | The boss cannot be attacked or join a skirmish until the Rupture breaks its seal. | implemented |

## Rules

| Term | Codex | Status |
|---|---|---|
| **Order of operations** | Everything that changes a number goes through one pipeline, in one order. Sources: the chassis passive, each fitted component's passive and each fitted module (until refitted), skirmish rewards (until the battle ends), buffs and debuffs (until the skirmish ends, or until the end of a given round). First suppression, shortest-lived source to longest: a live effect that suppresses another by id or tag turns it off, and a suppressed effect suppresses nothing. Then the gate: an effect takes part only if it is live, its trigger fires now, its condition holds, and, for an ability, its component is not destroyed (a destroyed component keeps its stat bonuses and loses its abilities). Then adds, all sources summed; then multiplies, all sources multiplied; then floors and caps; then overrides, where the shortest-lived source wins and the latest granted breaks ties. In an attack, the number (with what fired heat or a target's missing hull adds) comes before the pipeline's adds and multiplies; nothing is ever stored as a total: every read asks again, so an effect that is gone stops answering. Statuses stack: the same status granted again adds stacks instead of a second copy; an add is worth its value per stack and a multiply is applied once per stack; each ends on one of four clocks, its owner's turn starting, its turn ending, the round ending or its spending, a ticking one paying its point a stack and losing a stack as its owner's turn ends, and is gone at zero. | implemented |

## Holes

Every entry whose `design.holes` is not empty. This is the list of things the mechanics do not do yet.

- **Hit for N** (implemented): The three ways damage lands, the standard's rule 39 (Ryan, 24 November: "I like hit for N, suffer N damage, and lose N hull as the format examples that we want"), given a heading of their own in the keywords list on his yes of 25 November to a Damage section in place of reminders on each tip. Listed, never matched in a line (Terms.UNMATCHED): "Hit" is a label's word. The text is a session's draft.
- **Suffer N damage** (implemented): The three ways damage lands, the standard's rule 39 (Ryan, 24 November: "I like hit for N, suffer N damage, and lose N hull as the format examples that we want"), given a heading of their own in the keywords list on his yes of 25 November to a Damage section in place of reminders on each tip. Listed, never matched in a line (Terms.UNMATCHED): "Hit" is a label's word. The text is a session's draft.
- **Lose N** (implemented): The three ways damage lands, the standard's rule 39 (Ryan, 24 November: "I like hit for N, suffer N damage, and lose N hull as the format examples that we want"), given a heading of their own in the keywords list on his yes of 25 November to a Damage section in place of reminders on each tip. Listed, never matched in a line (Terms.UNMATCHED): "Hit" is a label's word. The text is a session's draft.
- **HP** (implemented): A machine's health is its hull; the engine's code may say either word.
- **Shield** (implemented): Shield sizes are placeholders. No chassis regenerates: the reboot refills a shield, and a passive, a module or a status may grant a regen.
- **Heat** (implemented): Heat does nothing below the cap. Consider effects at high heat short of overflow. No chassis cools: the reboot vents, and a cooling a piece grants must stay below a typical weapon's heat or heat never matters (tuning).
- **Rift Pressure** (implemented): The interval step inside a battle (the escalation a stall would meet) is on the ramp's table at zero until the turtle read asks for it.
- **Rupture meter** (implemented): Shown as a bar under the gate's with a notch a Fracture, a first cut; the beats, the patrol left and the steps are placeholders.
- **Fracture** (implemented): The prize a Fracture may bring is not built (decided after the meter is played).
- **Gate Integrity** (implemented): The gate damage formula is a placeholder; city defences along the wall are not built.
- **Weapon** (implemented): The engine's kind is attack for a weapon and a debuff alike: a debuff is an attack of no damage (Face.is_debuff), so code asks is_weapon() for this word and is_attack() for both.
- **Spread** (implemented): Its number rides on the entry beside the keyword (cleave), and the validator asks for it on a weapon. The half it dealt from 26 October retired 28 October (Ryan): at single digits a neighbour's half killed no rank and file. A piece may carry it beside Penetrate, the plus round its target; Splash, the two under one word, was cut on 15 November (Ryan: "It might be a more interesting game with only the other area shapes, with a few select pieces carrying both spread and penetrate together").
- **Penetrate** (implemented): Its number rides on the entry beside the keyword (penetrate), and the validator asks for it on a weapon.
- **Every Sprite** (implemented): A keyword from 2 November (Ryan: 'Every foe is a targeting mode, just like spread, penetrate, and splash, it should be listed as such and given a keyword'), a targeting mode in its own right since 4 November ('Silence should not narrow targeting modes, that's why I'm switching them to targeting modes'), drawn in the die's targeting slot. A working name, the foes' Every Machine mirrored. A weapon's too since 12 November, when Sweep went (Ryan: the Whip Scorpion's and the Musk Ox's specials "a 'target all'"): it strikes every foe for its whole number and none is its one target (Ryan, 12 November: "Target all shouldn't need a target in the same way that sweep didn't. Why would only the first target pop shock? That's weird and useless"), so a Shock is doubled and spent on each and, with no primary target, no Ricochet follows it. No area keyword rides it.
- **Every Frame** (implemented): Every Foe's mirror on the team's side (2 November; a targeting mode since 4 November); a working name. Its mark is the three hexes under a low arch, its own cell lit (Ryan, 4 November: 'the difference is whether the center one is lit or not, its two modes, even if the every ally doesn't actually exist in game, yet'): no piece carries it yet. Never a vent's (the validator).
- **Every Other Frame** (implemented): Every Ally's other mode (4 November), the Mooring Screens' team shield; a working name. Its mark is Every Ally's with its own cell dark. Never a vent's (the validator).
- **Cryo** (implemented): Other pieces may lay it (marked for reuse as a healthier ally cooling than a vent). A rider on the mark is benched until the roster has room. The cooling a stack is a placeholder.
- **Ablate** (implemented): Its number rides on the face beside the keyword (ablate), and the validator asks for it. Burn until 15 November: the word is Ryan's, for an eroding that is not only fire ("Ablating or ablate is very clinical, it fits the military notation, and evokes eating though armour to me"). A session's draft, his to write.
- **Lure** (implemented): No status and no chip: the arrow is the record. A draw by an ally is parked (the bible's redirection row).
- **Expose** (implemented): The formation word exposed stays rules text, so the status's id is exposure. The foes' half is Ryan's of 15 November (the vocabulary pass's fourth and fifth rounds), built 16 November: a tier-two foe's at the least, the validator refusing it on anything dealt at tier one ("only in formations that feel thematic and fair, so that the player has tools to answer by that point"), and one out at a time ("Enemy units should be smart enough to only try to Expose one player unit at a time"). Its carriers since 17 November: the Goblin Warchief, the Basilisk, the Alpha Warg, the Lich and the Rider of the Wild Hunt, each a move of its own, and the Piercing Eye, whose Gaze carries it as a rider. A blow's Expose lays nothing while a machine stands Exposed, so a foe whose one move it is marks every other round at the most. The foes' text is a session's draft, his to write.
- **Disrupt** (implemented): Deterministic: the next move in the foe's list that its conditions allow, so a boss steps through its pattern.
- **Swap** (implemented): A keyword until 15 November (Ryan: "Can be unique text, not a keyworded rider"): the piece's own rule, `swaps` on its entry, its mark kept on the die.
- **Brittle** (implemented): Its number rides on the face beside the keyword (brittle), and the validator asks for it. Flak on our side and Crush on the foes' until 15 November, one word on both since (Ryan: "Crushed and flak - agreed, brittle"). The word names the state, so a piece that lays it reads Brittle 2 and the Flak pieces keep their names; a verb for it is his to pick if he wants one. A session's draft, his to write.
- **Sap** (implemented): The keyword that lays Ryan's Sapped (11 November), first on the Baboon's Redshift Emitter.
- **Juggernaut Drive** (implemented): Ryan, 11 November: "After gaining Barrier, its next weapon attack gains Breach. The next attack breach will need to be represented by a purgeable buff, I'd just call it 'Juggernaut Breach.'" 15 November, Breach cut on our side: 'Change to explicit "ignores armour."', so the state shows under the passive's own name and the word Breach is gone from the game.
- **Numbed** (implemented): Ryan's clock (2 November): the chip reads as the rounds until it can be stunned again, so the stacks land after the decay phase; a stun lock costs its resist and one every round, so an all-in stun team can brute-force a boss at a price, and a Purge is the other key. The resist numbers are placeholders (content's resist; the bosses' by hand).
- **Paradox** (implemented): The count is a placeholder (Ryan, 11 November: "we have no idea how many paradox stacks is balanced, we just decided on 3 or whatever as a placeholder without knowing how much status chips were going to get thrown around in the game as a whole"); a stack a debuff stack since that day, at five.
- **Volatile** (implemented): Hull outright, where the Corrupted bite takes shield first. The number is a placeholder. A keyword with a chip until 26 October; a cost like heat since, so the die says the price and no chip does.
- **Shield cost** (implemented): No piece carries it yet; the numbers are content's.
- **Chain** (implemented): Ryan, 24 November, his text: "I want to change Chain. The under-armour ping is simpler. Resolve: All Sprites with Shock, Static, or Sonic Needle lose {N} HP." Static is the debuff of his Static machine of 4 November, not yet built (docs/briefs/aphelion_static.md), so only Shock and Sonic Needle conduct until it lands. His words, not yet signed on the Text tab; 25 November, of the conductors: "the only non-exclusive conductor is Shock. So it's possible that we just need to mention Shock specifically", so Sonic Needle's and Static's own tips say they conduct it.
- **Rapid** (implemented): Its limiter is its own switch-off, the entry dark for the rest of the round (Ryan, 12 November: "rapid gets its innate cooldown zero back without the explicit display"), which no cleanse lifts; a Rapid vent is never below tier three and a Rapid shield never below tier two (the bible's Rapid row).
- **Instant** (implemented): Ryan, 12 November: "the rapid no cooldown pieces change to a new keyword: Instant (reroll after use, can land on itself)". Every Instant piece carries a limiter, which the validator holds content to: a cooldown, heat, Volatile or a shield cost, or the store a charged form spends; a piece locked on a stepping die has the cylinder's odds (the Spin-Up's), and a piece Instant only while its machine rages has its heat (the Nemesis's Knuckles of Fury). An entry is Rapid or Instant, never both.
- **Jam** (implemented): Disable until 15 November (Ryan: "Rename to Jammed"); the rider follows the pattern, Jam lays Jammed.
- **Destroy** (implemented): No foe carries it (Ryan, 15 November: "This can be a boss-level rider, that destroys the visible face if it damages hull at all. Only promoted form or superboss-level so we're not tuning the economy around it. No longer a general rule"). Its carrier is the foes' pass's, and the fight bot prices no entry's loss until one does.
- **Immune** (implemented): Ryan, 15 November: "not as a blanket for all bosses, but for ones who need it for their fight to actually do something." Content: immune on a foe, suppress or disrupt, each true or the id of a move of its own that gathers. Three carriers since 17 November, on his yes to the bench's rows: the Pilgrim, Suppress, whose dread is that it keeps coming; the Obsidian Tyrant, Disrupt while Firestorm gathers, and the Ruby Colossus, Disrupt while Ultima gathers, whose rounds of warning are the fight. A session's draft, his to write.
- **Drain** (implemented): The Vampire Lord's (30 October), its bite and, below half, a drain at every machine. The genre's word (Drain), and the soft counter section 2 asks for: Ablating never stops healing. The hull alone, so the shield answers it: a drain of shield and hull walled the slowest trio at every HP tried, the shield, its answer to every blow, doing nothing against the heal. A rider on its blows until 16 November, and the unit's own Ability since, on Ryan's mark of 15 November ("This should be moved to an ability on the unit since it's on every attack. Like the Nob"): a chip on the foe, every blow of its, and no word on the blow. The text is a session's draft, his to write.
- **Timid** (implemented): Ryan, 20 November: "goblins only attack when they have any buff, or are predicted to get one" and "If a goblin is getting a shield from its peer in the intent, it should queue an attack". The foes announce in the order they strike, so a goblin reads the moves already out ahead of it, never one after it. The name is his (20 November: "Rename Safety in Numbers to Timid"); the text a session's draft.
- **Swallow** (implemented): Floraison's (30 October). The rounds, 1 to 3, are the move's, and no damage lands on the machine while it is held. The early release (31 October, Ryan agreeing Claude's lean): a quarter of the swallower's HP lost since the swallow, Clair Obscur's stagger in its smallest form, a round of the team's focus; the swallower loses nothing else, since a lost action on top would be a stun. A machine let go in the player's turn acts that round.
- **Golden Rage** (implemented): The Thunder Ape's (4 November); see Golden. Its weight is content's, 2 so it comes about a round in three while calm.
- **Merge** (implemented): The King Gel's (30 October): every Gel, Bubble Gel, Metal Gel and half on the field. Content: effect merge, foe (an id or a list), value (the lift a foe taken in). A foe taken in leaves no last act and no split and is no kill of the team's; its pack's tally still counts it gone. It needs its kinds beside it, so the King Gel's escort is its own (an escort that names its boss).
- **Purge** (implemented): One id, dispel, on both sides (28 October); numbered 2 November (Ryan: "lower everything by N and price accordingly", a softer answer to armour and damage stacking that prices cheap and common; the Null Field Emitter at Purge 2, a placeholder). One purge on either side (Effects.purge): N stacks off every buff, whatever granted it (Ryan, 8 November: "A stack is a stack, doesn't matter where it came from"); retired with it the purge by source of 28 October (a die entry's stacks gone for good, a store's, a form's or a passive's put to sleep until the player's turn), which he called cryptic. What the unit is, its form or its passive mechanic, is an Ability and no buff, so no purge reaches it (the same day).
- **Cleanse** (implemented): A Sprite's Cleanse lifts Suppressed too since 26 November (Ryan: "Change the cleanse to remove suppress, I never approved that"), so its line says no more than a Frame's. Cleanse and Purge stay two effects (his the same day: "Keep cleanse and purge seperate, I was confused").
- **Pinned** (implemented): Ryan, 11 November: "The Flak pin should be its own status that gets applied for one turn. I assume we're going to want a similar one for burning as well." Pinned Flak until 15 November, and what it holds Brittle since; the name is his ("Just \"Pinned.\"").
- **Seared** (implemented): Ryan, 11 November: coded in beside Brittle's pin, "since the Mastema will want it as a fitted piece, if nothing else". No piece lays it yet. The name is his, 15 November: "Rename 'Seared.'"
- **Sapped** (implemented): Ryan, 11 November: "I'd like to code in Weaken ... Weaken (debuff): Deals 1 less damage per stack with attacks ... Weaken can apply to both sides, it's not a bad soft CC from the foes to apply"; then "Weaken can change till after it's next turn then, instead of round end. Let's use Sapped." So a foe's Sapped laid in its turn reaches the machine's next attack.
- **Exposed** (implemented): The id is exposure, since exposed names the formation word (and named an aim of the foes' until 17 November); a machine's is exposure_mech in the engine. The machine's half is Ryan's of 15 November, built 16 November: "all armour of all kinds"; "Exposed does not strip the petrel's resistant shield"; "keep the logic where enemies don't try and overkill. That helps keep it fair. So the whole field targets up until predicted death, then the rest pick intent targets as normal"; "Exposed sets the intents, everything after proceeds as normal"; "Lure wins". A session's reads where his words give none: a countdown's pick carried from the round before holds, and a machine out of reach (Phased as the round ended) draws nothing. Still his: whether a machine that stands Exposed may be marked again; built as no, so the whole field's fire comes every other round at most. The aim content called exposed went on 17 November with every aim of a foe's own. The machine's text is a session's draft, his to write.
- **Empowered** (implemented): Every grant is one status on the machine and the stacks add up. A halving rule has no duration, so a buff component grants stacks and no rounds. The name is a placeholder. It halves at END TURN since 16 November (Ryan: "Empowered should decay at the end of turn, clearly, not end of round"), so what a machine gains in the enemy's turn it carries whole into its next; at the round's end until then. One term for both sides since 26 November (Ryan: "'Both' empowereds? There should be only one."): the foes' Empowered, the engine's kindled (an add on a foe's attack where a machine's is an add on its attack's damage), reads as this entry (Terms.ALIASES).
- **Sealed** (implemented): One chip, renewing, never stacking: the armour it grants is tied to the form. The numbers are placeholders.
- **Changed Over** (implemented): A working name and text, Claude's drafts of 11 November for Ryan to rewrite. One chip for the second battery, none for the first.
- **Cryo** (implemented): Engine id cryoed, since the keyword holds cryo; the player reads Cryo on both.
- **Armoured** (implemented): The engine id stays braced. One clock on both sides, the opening of its side's next turn (Ryan, 15 November: "The common "end" state between both sides is "start of their next turn.""; 16 November, of a machine's, which went at the round's end until then: "Armoured we should change so its end is symmetrical on both sides. Probably means until "start of its next turn.""). A machine's goes as the round opens, before the foes announce, so no blow lands between its old end and its new one. It takes no rounds from any grant.
- **Hardened Light** (implemented): Ryan, 18 November: "no innate shield armour. The Pulse grants one Hardened Light at tier 1. Hardened Light only decays when the shield breaks, and has a cap of 3 stacks"; "The reboot breaks it yes. When it breaks, it loses all of them. If it's weak, we'll buff it, but this is the best shape that doesn't add any weird exceptions. It contains high points and low points and that makes it interesting and healthy". Shield armour, never armour, so an Expose leaves it ("It's the only tank not weak to Expose"), and it takes nothing off a blow on bare hull, a tick or a burn. What reopens it: a Purge proving too threatening, which moves it to a resource bar in place of a buff (his word the same day). His name of 17 November; the session's Hardened before it, a stack off each turn start for a day.
- **Primed** (implemented): The third primer since 15 November, beside Charged and Supercooled (Ryan: "give it the same format as cryo ... use a stack on firing"; "Primed - agreed, how many Ablate stacks does each Primed stack apply? Just one, like supercooled?"; one, since Ablate 1 on a gun measures as about the point a Charged stack's Shock does). Until then every blow left a stack of Ablating a stack of Primed, for a buff's rounds on a machine and one move on a foe. A placeholder name.
- **Jammed** (implemented): Disabled until 15 November (Ryan: "Rename to Jammed"). The engine's own name for an entry switched off, by a jam or by a cooldown, stays disabled.
- **Corrupted** (implemented): The bite is the status's own number in the engine's table, a placeholder.
- **Phased** (implemented): Ryan's mark, 15 November: "New effect: "Cannot be damaged or targeted by anything until the end of this round." We remove the awkward act clause, but still ensure that it cannot be buffed or interacted with by allies until it unphases"; "all sources of Phased should say "at the end of this round, grant Phased.""; and his answer: "it's a safe reboot if you can pull it off. All phased granters need to be gated, it should be earned, with the caveat that you have to survive the current round". Engine ids phased and phasing, the wait a source lays, a buff a Purge takes. Its own heat does not burn it (his ruling, 16 November, on a session's read that had the burn land: "it shouldn't take damage from overheating since we don't need the exception. It does accumulate the stacks, though, which it will feel the round after"). Everything it carries ticks (16 November: "Everything ticks during phased. It doesn't take damage but it's a way of waiting out a debuff. That's why my clause of the self-cleanse and self-purge is our way out if it's broken"), so its Ablating fades a stack a turn and takes nothing, and its Regenerating runs. A Volatile bite and a corrupted entry's bite are blocked with the rest ("I think we block the damage as a feature, and see how bad it is once we have real hull cost pieces that matter"). A session's reads of his words: it may spend on itself, and its Lure turns no pick. His spare clause is held until play asks for it ("If that's too strong, I would add "Remove all buffs and debuffs. Cannot gain any buffs or debuffs while Phased.""). A foe's Phased is built since 17 November, on his yes to the bench's row for the Spectre and the Wraith (16 November: "Phased foes act"): the engine's effect phase, a move of a foe's own or a step of one, the wait landing as the round ends. A Phased unit may target another Phased unit on its own side, and nothing else may (Ryan, 26 November: "A phased sprite could heal another phased sprite, that's allowed"; "Phased can target other phased"), so a foe's side reaches a Phased foe only from one Phased too; the session's read of his "less strict" that let its side reach it went the same day (his: "The 'less strict' line is deprecated and should be removed"). Never the last foe standing, never two rounds running. Until 15 November: cannot act, take damage or be targeted until the round's end, granted at once to a machine yet to act. A session's draft, his to write.
- **Ablate** (implemented): Engine ids ablating (a foe's) and ablating_mech (a machine's). Ryan's rule, 15 November, in the place of Burning as heat on a machine: "hits shield first, I think. Pretty deadly otherwise. Bypasses armour when damaging hull"; "Tick of ablate ignores barrier yes". A Phased machine takes no point and its stack fades all the same, and a Swallowed one's stacks wait (Ryan, 16 November: "Everything ticks during phased. It doesn't take damage but it's a way of waiting out a debuff"; "Swallowed it's out of play so everything should pause"). The foes' numbers are still the ones sized as heat, his to set. A session's draft, his to write.
- **Vitriol** (implemented): Only the funnel-web's passive lays it; a keyword that ever carries it shares the word. Whether a tick passes Guarded is the parts' question, as Ablating's is. The word Corroded is kept for a foe's damage over time on machines.
- **Web Bomb** (implemented): The burst catches the next foe to act beside it in its rank, the one to its left when none stands to its right; on a foe already suppressed it is wasted, and each half feeds the Paradox as the Suppress keyword's does. Named for its piece and its rider no keyword since 15 November (Ryan: "I don't think the rider needs to be listed as a keyword. It's a unique effect, and the debuff can be renamed \"web bomb.\""); the id is the engine's.
- **Spun Up** (implemented): Ryan, 26 November: "Spun up needs to go to 1 at base, the 2 was a holdover from larger numbers", and his line "Weapons Gain: Commit: Consume all stacks to gain +1 damage per stack ({N})". Spent whole by the next weapon, equipment leaving it (26 October).
- **Ricochet** (implemented): Ryan, 12 November: "Ricochet (buff): After firing a weapon, it hits the primary target 1 more time per stack, dealing 1 damage each time and applying all effects other than area keywords"; "I'm leaving what applies in the ricochets open, if applying unique effects N more times is broken, then we dial it back and explicitly say 'keywords' instead of 'effects'"; 11 November: "Lose half stacks of Ricochet on any hull damage". His first thought, a Ricochet on every foe a weapon hits, he dropped with Sweep. Claude's readings, built on his go and his to move: 1 in place of the entry's number and of its reads of the foe, the firer's adds on it; half rounded down at each blow, bite or overheat that takes hull, so a lone stack is lost; no cap; a buff a Purge takes.
- **Essence** (implemented): Ryan's rework of 12 November, Souls then; Essence his name of 15 November ("Rename souls to Essence"). No cap by his call ("as part of the fantasy"), so it is no store, which is capped and wears a bar: an Ability, a chip with its count. The kill's flare is once a round, as it ends, when an attack of the Ammit's killed in it (Ryan, 16 November: "at the end of a round where the Ammit killed at least one enemy"); once an attack that killed from 12 November until then ("Flaring twice for an AoE is probably wrong, let's make it 'one of more killed' by an attack"), and once for each foe in the first build. The text is a session's draft.
- **Offhand** (implemented): Ryan, 19 November: "Only its offhand swaps"; "It cycles after a spend"; "remove the manual weapon cycle"; the spends that carry its rider turn it, his answer of the same day. The chip takes its armament's name and line (Beam Rifle, Beam Sword, Beam Shield, and the branches' Saber, Buckler, Bazooka and Pavise), each the passive's or a step's. The text is a session's draft.
- **Aile Boost** (implemented): Ryan, 19 November: "Rapid. Next weapon strike gains Indirect reach"; "Next weapon strike -> Next weapon fired. Applies to the whole spend"; "Booster's buff is the booster's name". The text is a session's draft.
- **Aile Blitz** (implemented): Ryan, 19 November: "Aile Booster -> Aile Blitzer: 'Rapid. Next weapon strike gains Indirect reach and ignores armour.'"; its name his ("'Aile Blitz'"). The text is a session's draft.
- **Aile Assault** (implemented): Ryan, 19 November: "Aile Booster -> Aile Assaulter: 'Rapid. Next weapon strike gains Indirect reach. Gain 1 Empowered.'"; its name his ("'Aile Assault'"). The text is a session's draft.
- **Parry** (implemented): Ryan, 19 November: "Parry: 'The first weapon fired next turn gains bonus damage equal to half of all damage blocked by this machine this round (rounded down).'" What is blocked, his answer that day: what a Barrier and armour keep off, never the shield's soak. His of the same day, on the bonus: "Can we change it to 'next strike' instead?" (every strike of the next weapon, his first wording, made a busted area of the rifle that follows the shield), the next strike the spend's first blow by his strike order. Claude's reading: the count runs from the moment it is gained. It pays half the blow a Barrier stops, so a boss's biggest blow pays most, beside his taste of October ("No reward for being struck that scales with the enemy's blows"): his of 19 November, "The duelist is supposed to be a boss-killer, and this is a tier-3 capstone, yes, so it can be powerful". The text is a session's draft.
- **Essence Flare** (implemented): Ryan, 12 November: "No Empowered decays this round. And I mean none, not ally or enemy." Pinned Empowered until 15 November, a chip on every unit holding Empowered and the round's own rule; then his: "This is not pinned empowered, this is an Ammit specific buff. I would give it to the Ammit only, even though it affects the whole battlefield"; "Grants the no-decay state which is represented as a buff on the Ammit called Essence Flare." That a Purge ends the hold follows from its being a buff.
- **Sustained Recoil** (implemented): Ryan, 26 November: "Sustained Recoil (Resource): Max 5 stacks. At 5 stacks, the next weapon hit deals double damage." Every weapon hit, an area's included, adds a stack; the hit that finds five consumes them all. Its bar has five cells, glowing and pulsing whole while full (his: "indicating the next shot is the sixth"). The six-shot count it replaced (shots) is git's.
- **Brittle** (implemented): Engine ids brittled (a foe's) and brittled_mech (a machine's). Flak on a foe (Wainwright & Sutler's on-hit, 19 October) and Crushed on a machine (the World Eater's pin, 4 November, Monster Hunter's Defense Down by archetype; Ryan: "that inflicts Defense Down in game, something we don't have") until 15 November, folded on Ryan's mark ("We could consider making this one symmetrical and folding it into Flak as well, changing the name so it works on both sides") and his "agreed, brittle". One clock, the halving: a machine's stood whole through the next round until then, so a foe's Brittle 1 was the pack's for the turn it was laid in and gone by the next, and a foe lays 2 at the least since 16 November (Ryan: "Buffs and debuffs that decay at end of round should just have a minimum of 2"; the validator holds a foe's moves to it, and our own pieces are not held to it: "The minimum 2 is different for the player since they can sequence. So I wouldn't make it a blanket rule"). Adds before multiplies and before armour, to a weapon's blow of 0 too (Ryan, 25 October: "Flak and overcharge exist in part to get past armour"), so a Shocked foe carrying Brittle takes blow plus Brittle, doubled. Numbers are placeholders; Brittle beside Empowered at a point a stack each may read too strong, the two read together on the Prairie Dog's rows. A session's draft, his to write. It halves as its carrier's turn starts since 16 November (his four places, Brittle with what ends at a turn's start; at the round's end until then, no blow apart).
- **Destroyed component** (implemented): No foe carries Destroy yet, so nothing is destroyed in play (Ryan, 15 November: "Only promoted form or superboss-level so we're not tuning the economy around it. No longer a general rule"). The campaign's hangar screen is not built.
- **Mine** (implemented): Ryan, 9 November: "the lammergeier basically converts all hits to AoE hits, at the cost of a delay until Death". One Mine a spend at a flat 2 ("then look at per hit later if it's weak"); its riders the spend's whole result on the foe ("the mine should take the entire result of the spend, then apply it. So a 3-hit flak that burns 1 per hit if the target is under 50% HP, would result in adding a 2 damage mine with 3 flak, and 0-3 burn"), every hit's stacks as its machine deepened and doubled them and a gated keyword where its gate held ("if a gate is met when fired only, then apply it"); the numbered ones add up and the rest ride once; Chain rides as its arcs (Claude's lean, which he took); in the enemy's turn a Mine's Disrupt does nothing; a Suppress rides as fired, each foe the blast meets judging its own Numbed (Claude's read; Ryan: "Your reads are correct"). A mark the team laid: a Ward turns it away, a foe's cleanse takes it, the Paradox counts it. A foe taken into a merge hands its Mine to the merger.
- **Massive** (implemented): Spread treats it as a front-rank neighbour; Penetrate finds nothing behind it.
- **Movespeed** (implemented): Every chassis's move is a placeholder set by size and role; what crossing water and walls is worth is the pricing run's to read (28 October).
- **Walk** (implemented): A pack with no way to the gate waits, and the map says so.
- **Carry** (implemented): A landing animation or a redistribution on landing may come later.
- **Engage range** (implemented): One number in the engine, the engage range (Unit.ENGAGE_RANGE, a placeholder: adjacency), serving the machines' reach onto a pack, the hunters' catch and the ring drawn; the hunters' pounce of two (Ryan, 29 October, "wolfs pounce") retired 10 November with the body blocking, so the catch is "the same melee engage range as everyone else" (Ryan); no foe or composition carries a ring since 8 November.
- **Behaviour** (implemented): Push and hunt are the only behaviours; the hunters' caveats are placeholders.
- **Footprint** (implemented): Footprints do not rotate with facing.
- **Composition** (implemented): Each tier's compositions are partitioned from its list as placeholders for Ryan's marks; the escorts are written for their bosses by tier.
- **Patrol** (implemented): The tier-one patrols read as a lone starter's fight on the greedy rung, not a tenth of its hull (docs/measurements.md, 30 October); their sizes are Ryan's to mark.
- **Formation** (implemented): The word also names the skirmish's two ranks; the context tells them apart.
- **Tear** (implemented): Drawn as a first cut for the phone; its mark and its opening are to judge running (RIFTGATE_PEAK_DEBUG=1 peaks every enemy turn).
- **Seam** (implemented): Its start and its growth a round are placeholders for his eye (Bleed.seam_start_hex, Bleed.seam_grow_hex; the map tuner moves both).
- **Ruins** (implemented): No skirmish condition yet; what terrain does in a fight is section 12's question.
- **Water** (implemented): No skirmish condition yet (section 12). Each map shape lays its own water (a fat river with its narrows, a delta's channels, ponds, a pond, the gorge's flooded channels, or none: the city has none). Since 29 October the horde wades it as the ground machines do, so water slows a crossing and never walls it; the crossing guarantee binds the walls.
- **City defense** (planned): No die and no rule yet: how gate defences work is section 12's question.
- **On struck** (implemented): Its carriers the Echidna's Sonic Needles (Ryan, 20 November: "getting struck by one, grants that foe a stack of Sonic Needle") and the Nemesis's heat (24 November: "When Hit: gain 1 heat"). The codex is a session's draft.
- **On shield gain** (implemented): No content uses it yet.
- **On shielding an ally** (implemented): Fires on the spend, whatever the shield gained, so a shield die on a topped-up ally still does its other work.
- **On buffing an ally** (implemented): Its carrier the Puffin's pull (Ryan, 11 November: "Using an equipment on an ally moves some of its heat to the Puffin"; 19 November: "I think 4 for the Puffin"). The piece that passes heat fires none: its heat goes the other way. The codex is a session's draft.
- **On skirmish start** (implemented): The Ammit's passive uses it.
- **On applying stacks** (implemented): Shocked and Suppressed are not stacks, so it never touches them.
- **On hull damage** (implemented): The hook for the pinned berserker idea too; the Nemesis's Berserker, a heat for hull lost (24 November).
- **On a blow blocked** (implemented): The Nemesis's Breaker, two heat a blow blocked (Ryan, 11 November: per blow, "that lets it scrap against the comp its supposed to"; on its passive from 23 to 24 November, its branch's since).
- **Turn Start** (implemented): The Whip Scorpion's Obliterator (Ryan, 24 November: "Turn Start: Gain 1 heat"). The codex is a session's draft.
- **On gaining a Barrier** (implemented): The Wild Boar's Juggernaut Drive (Ryan, 11 November: "After gaining Barrier, its next weapon attack gains Breach"; ignores armour since 15 November).
- **At the end of a round it killed in** (implemented): Ryan, 16 November, the Ammit's passive in his words: "At the start of the skirmish, or at the end of a round where the Ammit killed at least one enemy, the Essences Flare, granting 1 Empowered per 5 Essences it holds." A kill is an attack's, as the kill trigger counts it; a machine wrecked in the enemy's turn fires nothing.
- **On a foe killed** (implemented): Built 12 November for the Ammit's Souls. It fires once for each foe that falls, which is what the trigger is: no effect opts into the count. A foe getting back up, a part and a Bomb's burst are no kill and fire nothing.
- **On damaging a foe** (implemented): Built for the Skua's rewrite (Ryan, 11 November: "Damaging an enemy grants it a stack of Ricochet (once per turn)"). The stack lands after the spend that earned it, so none of that spend's shots bounce off it. The once-a-round gate is the effect's own (once: round), open to any effect an event fires.
- **On use** (implemented): Built for the Cassowary's Deadeye II (Ryan, 26 November: "All Components gain: Resolve: Gain 1 Sustained Recoil"). It fires after the use's own reads: the Negentropy Spinner's advance reads the count before its Resolve adds one. A stack it lays on a store stops at the store's cap. Only stack_status runs on it today.
- **Command die** (planned): Open question: whether the command die exists at all, or one-shots only.
- **Reward pick** (planned): Built without one (Ryan, 24 October: maybe not warranted at all); decided after the meter is played, with the economy pass.
- **City ability** (planned): Consider range limits from the gate so the push north leaves support behind.
- **Tier** (implemented): Shown on the front's card when the mission map comes; today the campaign runs headless.
- **Ramp** (implemented): One table of placeholders (sim/ramp.gd), read by the campaign runner and moved on Ryan's word; the timer's 12 reads as the old clock's number (docs/measurements.md, 30 October).
- **Cooldown** (implemented): A price as heat is. Counted after the round of the spend since 12 November (Ryan: "change the count so 1 is how I intended"; the round of the spend counted from 14 October, when a weapon's 1 cost nothing, the die spent for the round anyway). The city's battlefield abilities count their own cooldowns in phases.
- **Gather** (implemented): Ryan, 9 November: "moves all mines to a single target, and Exposes that target. The Expose rider will effectively create an AoE expose mine, which we can try and see if it's dangerous." Its Expose is its keyword, so the Mine it gathers carries Expose. A Ward on the target turns the gather away.
- **Detonate** (implemented): Ryan, 9 November: "Deals a small amount of damage and detonates a foe's combined mine immediately ... The small chip damage makes it add a stack first. Try without a cooldown first." Its chip strike spends a Shock on the target, so a Shock doubles the chip, never the Mine.
- **On itself** (implemented): Its carrier the Storm Petrel's Hardlight Pulse (Ryan, 18 November): Hardened Light 1, up to 3, printed on the piece; its branches take it further through the pipeline (self_status): the Defence direction a Ward and a cap of 4, then a stack for each foe hit and a cap of 5, the Striker's Charged 1 and then 2. Its first form the lock's own Regenerating on itself (regenerates, 30 October to 17 November). Machine buffs and a Ward, never a Barrier, which keeps its pieces and its cooldown.
- **An ally's action** (implemented): Its price is the lever if it reads as Rapid embodied in a machine (the bible's Kestrel row); the order is the play, the ally spending first.
- **Grants a reroll** (implemented): The Rallied buff until 15 November (Ryan's mark: "This doesn't need to be a temporary buff or a keyword ... We can communicate by highlighting the reroll button as part of the preview, if one will be granted"; the grant passing the round's two: "allow it"). A reroll the Horn grants still counts toward the Muster when spent on the carrier. A session's draft, his to write.
- **Component** (implemented): Multi-slot components were set aside as invisible complexity.
- **Integrated component** (implemented): Never bought open. Locked pieces are powerful and unique, never blueprints, so no hardpoint stocks one and none carries a tier (the validator holds it; ContentDB.component_tier answers 0).
- **Module** (implemented): Fitted in the harness and the quick campaign's hangar: the campaign's roster, the loot that drops them and its hangar wait for the economy pass and the hangar screen.
- **Armour** (implemented): Numbers are placeholders.
- **Aim** (implemented): Content: aim on a move aimed at one machine, never on a foe (Ryan, 17 November: "the heat target is a property of the attack, not the dragon itself"; his go on the three words the same day: "if it's the strongest/weakest/hottest table from above, then yes I agree and you can go ahead"); when on a move is the condition that lets a foe pick it, and a special never fires twice running. The strongest and the weakest have no carrier yet, and the most buffed is a session's keep for the Djinn's Unmake (the bible's section 12). The codex and the words on a move's target line are a session's drafts, his to write in his terminology pass.
- **Self-Destruct** (implemented): A property of a foe's attack action. A self-destructing foe counts as a kill like any other.
- **Every Frame** (implemented): A property of a foe's attack action. Its number is per machine, so a move with it is priced well under a single blow from the same foe. The name is a working one.
- **Last Act** (implemented): Content: on_death.blow, an attack's shape (name, factor, strikes, keywords), beside or instead of a split. The Gargantuan King's Meteor (30 October). A short list of steps since 16 November, on Ryan's mark of 15 November ('foes who, say buff others on death, or debuff on death'): the blow may carry also, and on_death.act is one special in a blow's place with its own also, each an effect a fall may do (Foe.FALL_EFFECTS). Carriers of more than a blow since 17 November, on his yes to the bench: the Mandragora line's scream, the Gorgon's dying gaze, the Salamander's embers and the Lich's, which takes back the readiness it gave (unready_all, a fall's by sense). The codex is a session's draft for them; it and the term's word are his ('maybe rename to something more interesting'). A single blow lands on the machine that made the kill since 17 November, as a curse does (Ryan, of the Dread Knight's Death Throes: 'yes, hit its killer, if it has one'); it followed the foe's own pick until then.
- **Parts** (implemented): Content: parts (foe ids), guard (all or any), regrow_parts (rounds). Parts are found by pack and type, one deep, and each takes a cell of its pack's grid. The Fallen Weapon's two eyes and the Obsidian Tyrant's rider (30 October); a move may open once a part has fallen (part_fallen).
- **Countdown** (implemented): The foe stays on the field while it gathers; its pick holds while the machine stands, and a Lure moves it.
- **Follow-up** (implemented): Content: then, on the first move, naming the second (30 October). One deep: a follow-up names none of its own and comes only after the move that names it, never by the roll. A borrowed swing with nothing taken is no follow-up, and the roll decides. Off the player's list since 15 November (Ryan: "I don't think we need to explicitly spell this out for the player. A backend pattern is ok, and it will become obvious through play and mastery by the player"): the engine's pattern, with no term and no row in the list; a move's own readout still says what it names next.
- **Grudge** (implemented): The Pilgrim's Karma (30 October), the Tonberry's Everyone's Grudge under a name of ours. Content: per_kill on an attack, the points a kill. Every fall counts but a foe that went whole (a burst, a part falling with its core) and one taken in by a merge.
- **Sprite move** (implemented): A foe's whole brain is its weighted draw and its pick; none plans ahead.
- **Vents all** (implemented): Only the first shot of a chain fires the heat.
- **Fires the shield** (implemented): Its carrier the Buzzard's Shield-burner Cannon (Ryan, 18 November: it breaks the shield, and no zap rides it: "It can't, since the shield will be empty"). Never beside Vents all on one entry (the validator). The codex is a session's draft.
- **Passes heat** (implemented): Its carrier the Puffin's dump (Ryan, 11 November: "A locked piece can transfer the Puffins heat to another unit along with a buff based on heat moved"; "just allies"; 19 November, Empowered for every 2: "that needs data"). An ally its heat takes past the maximum burns as the turn ends, his "forcing an overheat". The codex is a session's draft.
- **Grows with missing HP** (implemented): Both numbers are the entry's own (power_per_missing and per_missing), placeholders.
- **Finisher** (implemented): A working name. The Coriolis Accelerator's slope as one step (Ryan, 11 November: "is there a way to make the pinion driver simpler but fill the same purpose"); its factor is the entry's own (finisher), a placeholder.
- **Fixed** (implemented): Ryan, 24 November, for the third case in a week (the Nemesis's Rage, the Mole's burrow, the Whip Scorpion's reboot that puts the Death Ray on its die): "It might want a keyword: 'Fixed: Knuckles of Fury'. Fixed: Only the specified component may be used." The kit word it would have met became Integrated the same day ("I'd rather change Fixed a chassis locked components to Integrated"). A word of the text: each piece's own engine path holds its die to its one component.
- **Gated** (implemented): Suppress alone carries a gate today. A working name for Ryan's name pass.
- **Consumes** (implemented): A mine laid from it eats its arrival's stacks. The equipment's form is the Quintessence Tap's (12 November, the Soul Siphon then), the engine's spends and spends_up_to; its text is a session's draft.
- **Ablates its firer** (implemented): A working name for Ryan's name pass. It was fuel for a machine that wanted heat while a machine's Burning was heat; since Ablate (15 November) it is a price alone, the component pass's to read.
- **Ignores Armour** (implemented): Ryan, 15 November, with Breach cut on both sides: "I would remove Breach from the player's side. Ignores armour can be an explicitly written out property"; "the player armour piercing pieces should be higher tier, obviously, or gated, I think. Else they become obvious best faces for certain domains". On the Ammit's Soulcutter Talons, the Wild Boar's next weapon after a Barrier, and the Overclocked Railgun, whose tier is the component pass's. A session's draft, his to write.
- **Empties the hopper** (implemented): Ryan, 20 November: "Empties the hopper, striking once for every load emptied. Grants no Ore." "Fragmenter is a dead face with no Ore." The numbers are placeholders.
- **Braces** (implemented): A rule on one carrier, not a keyword, until another piece wants it; the stacks are a placeholder.
- **Strikes** (implemented): Heat is paid once per use, not per strike.
- **Always on** (implemented): Every read asks the pipeline; nothing is written to a stat or a component, so an effect that is gone stops answering. A static reach rule cannot be conditioned on reach.
- **Order of operations** (implemented): Refit (the hangar) is what changes loadout-scoped effects; not built.
- **Rage** (implemented): Ryan, 23 November: "When the Nemesis starts its turn with heat at or over max, it gains the unpurgable status Rage: Remove all debuffs on self. Immune to all debuffs. The only component available is Knuckles of Fury"; "Rage ends when the Nemesis' heat reaches zero, at which point it immediately reboots, regardless of how it got there." Its debuffs are the statuses a foe lays on a machine, the ones a Cleanse lifts. Its heat comes from the blows it takes and its own blows a foe's armour or Barrier takes whole, by the rules its rage was banked by from 11 November. The text is a session's draft.
- **Ore** (implemented): Ryan, 20 November: "Damaging a foe grants one stack of Ore (max 3). At 3, base armour increases by 1 (represented by an ability chip)." The engine id stays hopper. What the Ore is worth is the Ore chip (ore_plate), an Ability. The four loads and their Armoured of 31 October and 10 November are git's.
- **Ore** (implemented): Ryan, 20 November: "It's no longer cleansable, represented as an Ore ability chip." Its stacks are the armour, set from the Ore held (Effects._plate).
- **Scorched** (implemented): Placeholder numbers.
- **Overheated** (implemented): The reboot's (Ryan, 13 November: "an uncleanseable debuff on the unit, a stack for every point of heat"), read off the gauge and no status of the engine's table. A session's draft, his to write. The hull a stack burns is the trial's OVERHEAT dial, one the game's.
- **Broken** (implemented): The reboot's (Ryan, 13 November: "the unit cannot gain shield by any method"; "you can break yourself"), a state of the machine and no status of the engine's table. A session's draft, his to write.
- **Rebooting** (implemented): The reboot (Ryan, 13 November; folded in 15 November), a state of the machine and no status of the engine's table. A session's draft, his to write.
- **Enraged** (implemented): The rage's value and the Nob's numbers are placeholders. Permanent for the fight, as built (Ryan, 4 November: "Nob permanent"; Claude's lean, since an elite's job is to make the player change plan). The rage is the foe's own from the start since 8 November: it was a Bellow, the Nob's opening move, so its first round fed nothing (Ryan: "It's not innate? ... That is so unbelievably incorrect").
- **Golden** (implemented): Monster Hunter's Rajang by archetype, Ryan's read of 4 November (the golden rage "is a mode, not an attack ... a cycle that forces the player into a cycle of attack and defense, broken by a bold player with great timing"). Claude's translation: the window is the decision, shield through its rounds or burst a quarter of its HP through the extra plate to stagger it; the lost action is the bold play's pay, where the swallow's release loses none (the stun row's care; the exit if it reads as a free stun). The add is the move's value and the plate a point; numbers placeholders.
- **Aloft** (implemented): Ryan, 16 November: "I think the stoop can make it untargetable, yes. I don't think I'd call it phased though, it should still take damage from its riders, unlike phased. So it's different, should be a different buff, could be unique to the Roc for now if nothing else has that shape." And 17 November: "I'd say the roc doesn't get splashed while aloft." Content: aloft on a blow that gathers one round. Built on his second ruling as nothing new reaching it at all, with an aim or without, so equipment over every foe passes it by as a blast does and nothing breaks off a climb once it is up; what it carries is its own, a web and a Mine on it included. The name is a working one, his to change.
- **Appropriated** (implemented): Ryan's mark of 15 November on the steal rider: "Doesn't need to be it's own rider. It grants Jammed on the target, and Gilgamesh gains Appropriated with the value. The ability should be renamed to Collect." Built 16 November as the first move written in steps: a blow that jams, then a step of its own (appropriate). His Ability, a count on his chip that follows what he holds (Ryan, the same day, of the purgeable buff a session had read from "gains": "I think Appropriated is a balance read. Maybe make it his ability, a number that fluctuates depending on what he's currently holding"). The swing is one strike at the piece's number, whatever strikes the piece had, and no keyword of the piece rides it. The steal rider and the foe's own field for what it held left the engine with it. The text is a session's draft.
- **Swallowed** (implemented): Out of play, so everything it carries pauses (Ryan, 16 November: "Swallowed it's out of play so everything should pause"), where a Phased machine's ticks on: its Ablating, Scorched and Sapped wait, its Empowered and Brittle do not halve, its Regenerating pays nothing, it neither cools nor regenerates, a buff of its own holds nothing on the field (Essence Flare), and every timed status on it, a cooldown and a jam among them, moves a round later for each round's end it sits out: the rounds it sat out never came for it. Let go as its swallow's rounds run out, it is back before that round's end is read, the end it was owed from the round it was taken in; let go sooner, it goes on from where it stood. The swallow's own rounds run. It burns nothing while it is out and burns the turn it is back. A session's reads: an event of its fight still reaches it (a foe felled banks an Ammit's Essence), and a reboot it had begun before it was taken still recovers as the next round opens, the second half of a turn already given. Nothing cleanses it.
- **Ability** (implemented): Ryan, 8 November, of the Nob's rage: "Nob, and any other enemies with a passive ability, should have an unpurgable passive chip that points out what's going on. Plus, that's how slay the Spire works, where he comes from. It's not a Buff, it's not a Debuff, it's labelled as an Ability, so it doesn't get purged. Can use this for player units as well, like the armadillo's form. Golden rage should be an ability chip too." The tile is a placeholder look, to judge on the phone (RIFTGATE_ABILITY_DEBUG=1).
- **Ward** (implemented): A foe's move that lays a debuff without a blow is a rider too (Ryan, 25 October: "Should stop all riders, even from non-damaging attacks"), so a Stoke, a Stone, an Eruption on every machine and a Diamond Dust all pass a warded machine by. A foe's Ward (28 October) turns the team's marks (Effects.TEAM_MARKS), and since 2 November a stun and a Purge too, on either side, and stands (Ryan: nothing but damage lands on a Warded foe; the exception that let a stun through went with Numbed's roll).
- **Menace** (implemented): One weight for the three tallies, flat by tier; salvage's growth by tier and what a boss pays are the economy pass's to set, the boss's four a placeholder.
- **Elite** (implemented): Placeholder kits in every domain for Ryan's marks; the Bone Wyvern waits on the slate.
- **Seal** (implemented): The seal's look on the ring is a first cut for the phone.
- **Muster** (implemented): Every number is a placeholder; carrying it between fights is section 12's heat question.
- **Charged** (implemented): The Shock primer (Ryan, 2 November), Primed's cousin, so Chain is the arcs alone and the Shock supply is a kit choice; a keyword on the weapon fired, never a mark per hit (3 November: "a multi-hit weapon with Shock would apply it after both hits"), so a strikes gun never cashes what it just laid. Its first granter is the Storm Petrel's lure in its Striker branch (17 November: "adds a self-grant of Charged stacks to the lure"), two stacks a spend.
- **Supercooled** (implemented): The Cryo primer (Ryan, 2 November: "laying 1 cryo at a time makes sense, keeps it a little unique, and avoids massive cooling spikes"; the name his pick), so any gun is a Cryo setter for a turn and the Cryo synergies open past the Cryo Flinger; a stack a strike after the hits (3 November: "resulting in 2 applications, not apply-cash-apply-cash, and not hit-hit-apply once"). No piece grants it yet.
- **Regenerating** (implemented): One clock on both sides since 15 November (Ryan: "These are structured as 'Regen 1 per stack' and I'd give all sources either a fixed duration, say 2 or 3 turns, or have it decay one stack at a time"; "Regenerating - agreed"), Ablating's turned round; a value at each of three turns until then. The machine half, built 30 October for the Storm Petrel's lock, which lays it no longer since its rework of 17 November, is kept with no piece granting it on Ryan's word of that day: "put machine regeneration back, that will literally be added in this session probably". Bought by whatever grants it, so a foe's purge takes it. The numbers are placeholders, the foes' unmoved by the new clock.
- **Ammo** (implemented): Never a buff, so no Purge reaches it. If ammo runs plentiful, the vents' and shields' reloads or the trickle come down.
- **Burrowed** (implemented): Ryan, 16 November: "Instead of Reboot, it Burrows. While burrowed, it gains a unpurgable buff called 'Burrowed'"; an unpurgeable buff is labelled an Ability by his rule of 8 November. Its turns under his of 24 November: "When burrowed, it gains 50% shield regen, 50% cooling, and 50% Momentum generation", "50% of the final numbers, but represented as flat numbers"; "Burrow does not bank. But it does gain the 1 Armour." The text is a session's draft.
- **Momentum** (implemented): Ryan, 24 November: "Momentum is a Resource. It goes to 10 (subject to tuning)." Renamed from Conserved Momentum. The text is a session's draft.
- **Applied Momentum** (implemented): Ryan, 24 November, his text: "Debuff, doesn't stack. Turn Start: Gain 1 Brittle and Pinned. Then, take 1 damage and drain 5 Momentum from the Mole. If 0 Momentum, remove and return to the Mole"; "The take 1 is a blow"; "Go to Resolve, and include area hits as well. Easily added to the Applied Momentum debuff: Resolve: The Mole gains 1 Momentum." His words, not yet signed on the Text tab.
- **Frozen Momentum** (implemented): Ryan, 24 November, the Glacial Mole's: "Applied Momentum -> Frozen Momentum. Debuff, doesn't stack. Turn Start: Gain 2 Brittle, 1 Cryo, Pinned, and Frozen. Then, take 1 damage and drain 5 Momentum from the Mole. If 0 Momentum, remove and return to the Mole." Its Resolve line is Applied Momentum's, the form it takes the place of. His words, not yet signed on the Text tab.
- **Heated Momentum** (implemented): Ryan, 24 November, the Magma Mole's: "Applied Momentum -> Heated Momentum. Debuff, doesn't stack. Turn Start: Gain 1 Brittle, 2 Ablate, Pinned, and Seared. Then, drain 5 Momentum from the Mole. If 0 Momentum, remove and return to the Mole." Its Resolve line is Applied Momentum's, the form it takes the place of. His words, not yet signed on the Text tab.
- **Frozen** (implemented): Ryan, 24 November, the Glacial Mole's: "Frozen: Debuff. When any amount of Cryo would be consumed, consume 1 Numbed instead, if any, then remove Frozen"; "It gets the cooling. It is preserved regardless of numbed existing." His words, not yet signed on the Text tab.
- **Drill Out** (implemented): Ryan, 16 November: "It returns to the Mole when it burrows, taking the debuff with it"; 18 November, "Build the toggle". The text is a session's draft.
- **Sonic Needle** (implemented): Ryan, 20 November: "Sonic Needle - Conducts Chain. On 3 stacks, the Echidna fires Chain 2, then consume all stacks on this foe"; his answers that day: the bolt is "targeted at nothing. So the foe that hit 3 stacks and procced it would take 2 by definition", and a stack a strike. Its branches tweak it: the Spiker's sap (1 less on the foe's attacks a stack) and Chaos's bolt leaving its foe one stack in place of none (Ryan, 21 November: "reduce stacks to 1"). The text is a session's draft.
