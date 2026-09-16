# Riftgate vocabulary

Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.

Status: 57 implemented, 14 planned, 1 idea.

## Resource

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Hull** | The machine itself. When it is gone, the machine is a wreck. | Damage that gets past shield removes hull. Hull never recovers during a battle. At zero the mech is a wreck to be salvaged after the battle. | implemented |
| **Shield** | A buffer that buys you a few rounds to solve the squad before it starts costing you the machine. | Enemy damage removes shield before hull. Shield faces add shield up to the chassis maximum. Shields recharge fully between skirmishes. | implemented |
| **Heat** | Every gun has a price, and the big ones are paid in smoke. | Attack faces may add heat. Heat above the chassis maximum spills into hull damage one for one. Vent faces remove heat. | implemented |
| **Reroll** | You do not like what you see. You get three chances to change your mind, and the machine never shows you the same thing twice. | Three rerolls per round, each rerolling every unlocked, unspent mech die. A reroll always lands on a different face: never the one showing, never one equivalent to it (a die whose faces are all alike keeps its face). Rerolls may be spent before or after attacking, so a low damage roll is information for the rest of the round. Never pooled across rounds. | implemented |
| **Rift Pressure** | The city is running out of time, and there is a bar on screen that says so. | Ticks once per battlefield phase and once per skirmish round. When full it resets and a fresh squad emerges at the rift. | implemented |
| **Gate Integrity** | The last wall of mankind. If it falls the campaign is over. | A squad whose path reaches the gate strikes it instead of moving. Gate integrity persists across battles and is repaired in the meta. | implemented |

## Face Kind

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Attack face** | A gun, a claw, a shell. The primary icon is its reach. | Spend on a foe within reach to deal its power in damage, then apply its keywords and heat. | implemented |
| **Shield face** | Raise the plating. Yours or a friend's. | Spend on self or an ally to add its power in shield, capped at that mech's shield maximum. | implemented |
| **Vent face** | Blow the heat out of the reactor before it blows out of the hull. | Spend on self or an ally to remove its power in heat. | implemented |
| **Cracked face** | Something inside is broken and the die shows it. | Does nothing when rolled. Only a destroyed face is blank; a cracked face still acts. Persists until repaired in the hangar. | implemented |

## Face Property

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Damage range** | Kinetic weapons do not promise. They roll. | A kinetic attack face shows a minimum and a maximum and rolls between them when spent, immediately and visibly. Energy faces show one number and never roll. Numbers are in tens. | implemented |
| **Critical hit** | Sometimes the round finds the seam. | A kinetic face may carry a crit chance. On a crit the roll is doubled before other multipliers. Energy faces never crit. Crits fire the on_crit passive trigger. | implemented |

## Reach

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Melee** | Up close and personal. | Targets any front-rank foe, and any back-rank foe whose column is exposed. | implemented |
| **Line of fire** | If you can see it, you can shoot it. If something is in the way, shoot that first. | Targets any front-rank foe, and any back-rank foe whose column is exposed. | implemented |
| **Indirect** | Over the wall and onto the thing behind it. Just do not aim it at your own feet. | Targets any foe in either rank. Hitting the front rank triggers danger close. | implemented |

## Keyword

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Cleave** | One swing, three ghouls. | Also hits the foes in the neighbouring columns of the target's rank. | implemented |
| **Pierce** | The railgun does not care who is standing in front of whom. | Also hits the foe in the other rank of the target's column. | implemented |
| **Burn** | Set it alight and let it think about its choices. | Adds one burn stack per 20 damage dealt, rounded up. Each round the foe takes 10 per stack, then loses one stack. | implemented |
| **Suppress** | The big hit it was winding up never lands. | The target skips its telegraphed action this round. | implemented |
| **Overcharge** | Push the reactor past the red line and hope the housing holds. | Double the face's damage and double its heat. | implemented |
| **Execute** | Finish it before it gets back up. | Double damage against a foe at or below half its health. | implemented |
| **Chain** | The arc jumps to whoever looks weakest. | Also hits the lowest-health foe within reach other than the target. | implemented |
| **Lock** | That roll was too good to let go. | After this face is spent, the die keeps it into next round instead of rolling. | implemented |
| **Steady** | No surprises. That is the whole point of it. | A ranged face with steady always deals its average instead of rolling. It may still crit. | implemented |
| **Flip** | Turn the die over. The other side is usually better. | Set another mech's die to the face opposite its current one. | planned |
| **Copy** | Whatever they rolled, you rolled too. | Set this die to the current face of an ally's die. | planned |
| **Reflect** | Hit me. See what happens. | While shield from this face remains, foes that strike this mech take damage equal to the face's power. | idea |

## Status

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Burning** | On fire, and getting less on fire every round. | Foe status. See the burn keyword. | implemented |
| **Suppressed** | Head down, gun silent. | Foe status. Skips its action this round, then clears. | implemented |
| **Cracked face** | They got through the armour and something important is bent. | Mech status, global rule. When a hit gets past shield and takes at least a quarter of maximum hull in one blow, there is a one-in-two chance one intact face cracks: it loses its keywords, crit chance and unique effect, but still does its basic action. Counterplay is shield before a big telegraphed hit. A cracked face is a damaged component: it persists across skirmishes and battles until repaired in the hangar. | implemented |
| **Destroyed face** | Hit where it was already broken. | Mech status. When an injury lands on a face that is already cracked, the component is destroyed: the face is blank and does nothing when rolled, until the hangar repairs or replaces it. | implemented |
| **Locked** | Held for next round. | Die status. See the lock keyword. | implemented |

## Formation

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Front rank** | The bodies. | Three slots. Front-preferring foes fill these first. Always in line of fire. | implemented |
| **Back rank** | The problems. | Three slots behind the front. Back-preferring foes hold these and never step up. Front-preferring foes wait here and step up when the slot ahead empties. | implemented |
| **Exposed** | Kill the ghoul and the necromancer behind it is suddenly very interested in cover. | A back-rank foe is exposed when the front slot in its column is empty. Exposed foes are in line of fire. | implemented |
| **Squad pool** | There are always more where those came from. | Foes not yet on the field. Empty slots refill from the pool after each round. The skirmish is won when the field and the pool are both empty. | implemented |
| **Step up** | The horde closes the gap. | After the dead are cleared, a front-preferring foe in the back rank moves into an empty front slot in its column. | implemented |
| **Danger close** | You mortared the thing in your face. Your shields are now also in your face. | Indirect fire on the front rank removes shield from the firing mech equal to half the face's power, rounded up. | implemented |
| **Massive** | Too big for one slot. Too big for one anything. | A massive foe fills both slots of a column and counts as front rank. Its column is never exposed while it stands. Only some elites and bosses are massive. | implemented |
| **Withdraw** | Enough. Fall back and let the map decide the rest. | Available at the start of any round after the first, before any face is spent, so there is never free damage. Ends the skirmish; survivors on both sides carry their damage to the battlefield. | implemented |

## Battlefield

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Movespeed** | How much ground it covers before the enemy moves. | Movement points per phase. Entering a hex costs its terrain's move cost for that unit's traits. | implemented |
| **Intent** | You can see where they are going. Whether they get there is up to you. | Each squad's path for the phase is previewed exactly. It heads for the gate or the nearest city defense, or hunts mechs if aggro. Player routes resolve first. | implemented |
| **Body block** | Stand in the road. They stop. | A squad stops at the first hex on its path occupied by a blocking unit. Flyers do not block; squads pass through their hex but never land on it. | implemented |
| **Contact** | Adjacent means fighting. | After all movement, every connected group of adjacent units that contains both sides becomes one skirmish. Multiple skirmishes resolve one at a time. | implemented |
| **Squad** | One hex, one kind of thing, several of them. | An enemy hex is a squad: one foe type times a strength. A skirmish's enemy composition is whatever squads are chained together at contact, so the rift's formation and the player's disruption of it decide what you fight. Bosses are single three-hex units. | implemented |
| **Footprint** | Some things do not fit in a hex. | A unit covers one or more hexes. A boss covers three in a triangle. Every footprint hex blocks, touches for contact, and is a tap target. Squads and mechs stay single-hex. | implemented |
| **Structure** | The gate is not a hex. It is a wall. | Gate and rift hexes are structures wider than one hex. Nobody stands on them. A squad whose path reaches any gate hex strikes the gate. | implemented |
| **Spawn** | The rift coughs up another squad. | When Rift Pressure fills, the next squad of the faction's spawn list appears on the nearest free hex to the rift. | implemented |

## Terrain

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Plain** | Open ground. | Cost 1. | implemented |
| **Road** | Somebody paved this before the end of the world. | Cost 1. | implemented |
| **Rough** | Rubble and broken ground. | Cost 2. Cost 1 for quads and flyers. | implemented |
| **Ruins** | What is left of the suburbs. | Cost 2. Cost 1 for quads and flyers. | implemented |
| **Water** | Deep enough to drown a tank. | Impassable except for hover and flyer. | implemented |
| **Mountain** | Go around. | Impassable except for flyer. | implemented |

## Trait

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Flyer** | Reaches anywhere. Holds nothing. | Ignores terrain cost, crosses water and mountains, cannot body-block. | implemented |
| **Hover** | Skims the river like it is not there. | Crosses water. | implemented |
| **Walker** | Legs do not care about rubble. | Rough and ruins cost 1. | implemented |
| **Tank** | Tracks and armour. | No effect yet. | planned |
| **City defense** | The city shoots back. | A static player-side unit. Squads path toward it, and it joins any skirmish it is adjacent to. | implemented |

## Trigger

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **On attack** | Whenever this mech fires. | Passive trigger. Fires after the damage roll on every attack. Effects: multiply or add damage or heat, or set a minimum damage. | implemented |
| **On shield gain** | Whenever plating goes up. | Passive trigger. Fires when this mech gains shield from any source. | planned |
| **On heat gain** | Whenever the reactor runs hotter. | Passive trigger. Fires when this mech gains heat. | planned |
| **On round start** | As the dice come up. | Passive trigger. Fires after the roll, before rerolls. | planned |
| **On skirmish start** | As contact is made. | Passive trigger. Fires once when the skirmish begins. | planned |
| **On crit** | When the round finds the seam. | Passive trigger. Fires when an attack face crits. Effects: multiply or add damage, add burn to the target, vent the attacker's heat. | implemented |
| **On hull damage** | When they get through. | Passive trigger. Fires when this mech loses hull. | planned |
| **Out of combat** | A phase spent not fighting. | Passive trigger. Fires at the end of a battlefield phase in which this mech had no skirmish. | planned |

## Commander

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Command die** | You are not in the machine. You are the one telling the machines what to do. | One die rolled alongside the mech dice each round. Faces are rechargeable commander abilities and never deal damage. Faces come from the hangar, never from rewards. Die size is a research path. | planned |
| **One-shot** | The button you only get to press once. | Consumable ability. Pouch of three. Picked up from skirmishes, expires when the battle ends. Starting stock restocks every battle. | planned |
| **Reward pick** | Three things on the table. Take one. | After a skirmish victory: a modifier on a mech face you carry, a one-shot, or a battle-wide boon. Weighted by the squad's faction. | planned |

## City

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **City ability** | The city has a very large gun and a very large crane. | Battlefield-level ability owned and upgraded by the city: sprint, airlift, teleport, tractor beam, orbital strike. Cooldowns measured in phases. | planned |
| **Cooldown** | Reloading. Come back in two phases. | City abilities only. Counted in battlefield phases. Never used inside a skirmish. | planned |

## Holes

Every entry whose `design.holes` is not empty. This is the list of things the mechanics do not do yet.

- **Shield** (implemented): Option not coded: recharge only during phases spent out of combat.
- **Heat** (implemented): Heat does nothing below the cap. Consider effects at high heat short of overflow.
- **Rift Pressure** (implemented): Spawns a fixed squad. Should draw from the battle's faction and escalate.
- **Gate Integrity** (implemented): Gate damage formula is a placeholder (strength divided by three).
- **Damage range** (implemented): Ranges are content-authored per component; no upgrade path raises min or max yet.
- **Critical hit** (implemented): No crit-chance upgrades yet; no visible crit chance on the die face beyond the description.
- **Flip** (planned): Needs a definition of opposite faces for non-d6 dice.
- **Reflect** (idea): Would need shield sources to be tracked separately.
- **Cracked face** (implemented): Threshold and chance are placeholders. Repair cost and the hangar screen are not built.
- **Squad pool** (implemented): Elites should surface at set points rather than in pool order.
- **Massive** (implemented): Cleave treats it as a front-rank neighbour; pierce cannot hit anything behind it because nothing is.
- **Intent** (implemented): Aggro is a fixed flag. Should be a behaviour per foe type.
- **Contact** (implemented): No participant cap. May need one for phone readability.
- **Footprint** (implemented): Footprints do not rotate with facing.
- **Structure** (implemented): The rift does nothing yet beyond marking where squads spawn.
- **Spawn** (implemented): A full spawn list should arrive together as a formation; pressure currently sends one squad at a time.
- **Road** (implemented): Tanks should move faster on roads. Not coded.
- **Ruins** (implemented): Designed as cover for the squad inside a skirmish. Skirmish terrain conditions are not coded.
- **Water** (implemented): Designed to dampen burn inside a skirmish. Not coded.
- **Tank** (planned): Intended: faster on roads.
- **City defense** (implemented): Defenses have no die. They cannot act inside a skirmish yet.
- **On hull damage** (planned): Hook for the pinned berserker idea.
- **Command die** (planned): Open question: whether the command die exists at all, or one-shots only.
- **City ability** (planned): Consider range limits from the gate so the push north leaves support behind.
