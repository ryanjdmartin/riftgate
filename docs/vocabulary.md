# Riftgate vocabulary

Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.

Status: 67 implemented, 14 planned, 1 idea.

## Resource

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Hull** | The machine itself. When it is gone, the machine is a wreck. | Damage that gets past shield removes hull. Hull never recovers during a battle. At zero the mech is a wreck to be salvaged after the battle. | implemented |
| **Shield** | A buffer that buys you a few rounds to solve the squad before it starts costing you the machine. | Enemy damage hits shield before hull, and a standing shield blocks a blow whole: however small the shield and however big the blow, nothing bleeds through to the hull (a breaching foe is the exception). The blow still costs the shield its damage. Shield components add shield up to the chassis maximum; in a fight that is the only way shield comes back. Out of combat it returns each battlefield phase at the chassis's field rate. It never refills for free between skirmishes. | implemented |
| **Heat** | Every gun has a price, and the big ones are paid in smoke. | Attack components may add heat. Heat above the chassis maximum spills into hull damage one for one. Vent components remove heat. | implemented |
| **Reroll** | You do not like what you see. You get three chances to change your mind, and the machine never shows you the same thing twice. | Three rerolls per round, each rerolling every unlocked, unspent mech die. A reroll always lands on a different component: never the one showing, never one equivalent to it (a die whose components are all alike keeps what it shows). Rerolls may be spent before or after attacking, so a low damage roll is information for the rest of the round. Never pooled across rounds. | implemented |
| **Rift Pressure** | The city is running out of time, and there is a bar on screen that says so. | Ticks once per battlefield phase and once per skirmish round. When full it resets and a fresh squad emerges at the rift. | implemented |
| **Gate Integrity** | The last wall of mankind. If it falls the campaign is over. | A squad whose path reaches the gate strikes it instead of moving. Gate integrity persists across battles and is repaired in the meta. | implemented |
| **Armour** | Tank treads over a horde of ghouls, laughing. A ghoul that only ever claws for ten deserves to be walled forever; the answer is monsters that do more than claw. | A chassis number taken off every blow that lands on bare hull, flat, never a percentage. A blow smaller than the armour does nothing. Shield is not armoured: a blow on shield costs the shield its full damage. | implemented |

## Equipment

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Component** | The gun, the plate, the heat sink. What the machine is made of, and what the die shows. | A piece of equipment on a mech, and one entry on its die. There is no generic equipment: every entry on a die is a component, or an empty hardpoint. Each round the die is rolled and the component that comes up is what the mech can do. | implemented |
| **Hardpoint** | Bolt it on. The chassis does not care what. | A free slot on the chassis. Any component fits any hardpoint. On the model a hardpoint is a socket where the component mounts. | implemented |
| **Fixed component** | The part of the machine that is the machine. Restriction makes the build. | A component built into the chassis: always on the die, never removed, never sold, and it uses no hardpoint. The Badger's claw and its plating are fixed. | implemented |
| **Empty hardpoint** | You ran light. The die remembers. | A hardpoint with nothing in it is an entry on the die that does nothing when it comes up. Nothing fills it for you. | implemented |

## Component Kind

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Attack component** | A gun, a claw, a shell. The primary icon is its reach. | Spend on a foe within reach to deal its power in damage, then apply its keywords and heat. | implemented |
| **Shield component** | Raise the plating. Yours or a friend's. | Spend on self or an ally to add its power in shield, capped at that mech's shield maximum. | implemented |
| **Vent component** | Blow the heat out of the reactor before it blows out of the hull. | Spend on self or an ally to remove its power in heat. | implemented |
| **Cracked component** | Something inside is broken and the die shows it. | A cracked component still acts but loses all modifiers: keywords, crit chance and unique effect. A destroyed component is blank and does nothing when it comes up. Both persist until repaired in the hangar. | implemented |

## Component Property

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Damage range** | Kinetic weapons do not promise. They roll. | A kinetic attack component shows a minimum and a maximum and rolls between them when spent, immediately and visibly. Energy components show one number and never roll. Numbers are in tens. | implemented |
| **Critical hit** | Sometimes the round finds the seam. | A kinetic component may carry a crit chance. On a crit the roll is doubled before other multipliers. Energy components never crit. Crits fire the on_crit passive trigger. | implemented |
| **Strikes** | Miniguns, missile swarms, the claw that rakes twice. Players love procs; embrace it. | An attack's blows per use. A weapon with three strikes lands three separate hits: each rolls its own damage, its own crit and its own effects, so a rapid-fire weapon procs often. Against a shield, every strike past the first reaches the hull; against armour, every small strike loses the armour, so many small hits are the wrong tool for a heavy target and the right one for a soft one. Foe attacks have strikes too. | implemented |

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
| **Overcharge** | Push the reactor past the red line and hope the housing holds. | Double the component's damage and double its heat. | implemented |
| **Execute** | Finish it before it gets back up. | Double damage against a foe at or below half its health. | implemented |
| **Chain** | The arc jumps to whoever looks weakest. | Also hits the lowest-health foe within reach other than the target. | implemented |
| **Lock** | That roll was too good to let go. | After this component is spent, the die keeps it into next round instead of rolling. | implemented |
| **Steady** | No surprises. That is the whole point of it. | A ranged component with steady always deals its average instead of rolling. It may still crit. | implemented |
| **Flip** | Turn the die over. The other side is usually better. | Set another mech's die to the face opposite its current one. | planned |
| **Copy** | Whatever they rolled, you rolled too. | Set this die to what an ally's die shows. | planned |
| **Reflect** | Hit me. See what happens. | While shield from this face remains, foes that strike this mech take damage equal to the component's power. | idea |

## Status

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Burning** | On fire, and getting less on fire every round. | Foe status. See the burn keyword. | implemented |
| **Suppressed** | Head down, gun silent. | Foe status. Skips its action this round, then clears. | implemented |
| **Cracked component** | They got through the armour and something important is bent. | Mech status, global rule. When a blow lands on bare hull (no shield standing) and what gets past armour is at least a quarter of maximum hull, the mech's die is rolled and the component it lands on is injured. An intact component cracks: it loses its keywords, crit chance and unique effect, but still does its basic action. Any shield standing, however small, prevents injury, except against a breach; a foe's double strike is the other way past it. A cracked component stays cracked across skirmishes and battles until repaired in the hangar. | implemented |
| **Destroyed component** | Hit where it was already broken. | Mech status. When an injury lands on a component that is already cracked, it is destroyed: blank, it does nothing when it comes up, until the hangar repairs or replaces it. An injury that lands on a destroyed component or an empty hardpoint finds nothing to break, so a badly broken mech shrugs off more of them. | implemented |
| **Locked** | Held for next round. | Die status. See the lock keyword. | implemented |

## Formation

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Front rank** | The bodies. | Three slots. Front-preferring foes fill these first. Always in line of fire. | implemented |
| **Back rank** | The problems. | Three slots behind the front. Back-preferring foes hold these and never step up. Front-preferring foes wait here and step up when the slot ahead empties. | implemented |
| **Exposed** | Kill the ghoul and the necromancer behind it is suddenly very interested in cover. | A back-rank foe is exposed when the front slot in its column is empty. Exposed foes are in line of fire. | implemented |
| **Squad pool** | There are always more where those came from. | Foes not yet on the field. Empty slots refill from the pool after each round. The skirmish is won when the field and the pool are both empty. | implemented |
| **Step up** | The horde closes the gap. | After the dead are cleared, a front-preferring foe in the back rank moves into an empty front slot in its column. | implemented |
| **Danger close** | You mortared the thing in your face. Your shields are now also in your face. | Indirect fire on the front rank removes shield from the firing mech equal to half the component's power, rounded up. | implemented |
| **Massive** | Too big for one slot. Too big for one anything. | A massive foe fills both slots of a column and counts as front rank. Its column is never exposed while it stands. Only some elites and bosses are massive. | implemented |
| **Withdraw** | Enough. Fall back and let the map decide the rest. | Available at the start of any round after the first, before any component is spent, so there is never free damage. Ends the skirmish; survivors on both sides carry their damage to the battlefield. Shields do not refill on withdrawing; they recharge at the field rate only in phases spent out of combat. | implemented |
| **Strike order** | No initiative numbers, nothing to micromanage: read the row. | Foes strike in the order they stand: front rank left to right, then the back rank. Each blow is resolved on its own against the shield standing at that moment, so which foe strikes first decides what a small shield blocks. At first contact the heaviest hitters deploy left. | implemented |

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
| **On attack** | Whenever this mech fires. | Passive trigger. Fires after the damage roll on every attack. Effects: multiply or add damage or heat, or set a minimum damage. An effect may carry a when condition: component_cracked (only when the component being spent is cracked). | implemented |
| **On shield gain** | Whenever plating goes up. | Passive trigger. Fires when this mech gains shield from any source. | planned |
| **On heat gain** | Whenever the reactor runs hotter. | Passive trigger. Fires when this mech gains heat. | planned |
| **On round start** | As the dice come up. | Passive trigger. Fires after the roll, before rerolls. | planned |
| **On skirmish start** | As contact is made. | Passive trigger. Fires once when the skirmish begins. | planned |
| **On crit** | When the round finds the seam. | Passive trigger. Fires when an attack component crits. Effects: multiply or add damage, add burn to the target, vent the attacker's heat. | implemented |
| **On hull damage** | When they get through. | Passive trigger. Fires when this mech loses hull. | planned |
| **Out of combat** | A phase spent not fighting. | Passive trigger. Fires at the end of a battlefield phase in which this mech had no skirmish. | planned |
| **on_injury** | What the machine does when something inside it breaks. | Passive trigger. Fires when an injury lands on a component. Effects: no_destroy (a cracked component holds instead of being destroyed). | implemented |

## Commander

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Command die** | You are not in the machine. You are the one telling the machines what to do. | One die rolled alongside the mech dice each round. Its entries are rechargeable commander abilities and never deal damage. They come from the hangar, never from rewards. Die size is a research path. | planned |
| **One-shot** | The button you only get to press once. | Consumable ability. Pouch of three. Picked up from skirmishes, expires when the battle ends. Starting stock restocks every battle. | planned |
| **Reward pick** | Three things on the table. Take one. | After a skirmish victory: a modifier on a component you carry, a one-shot, or a battle-wide boon. Weighted by the squad's faction. | planned |

## City

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **City ability** | The city has a very large gun and a very large crane. | Battlefield-level ability owned and upgraded by the city: sprint, airlift, teleport, tractor beam, orbital strike. Cooldowns measured in phases. | planned |
| **Cooldown** | Reloading. Come back in two phases. | City abilities only. Counted in battlefield phases. Never used inside a skirmish. | planned |

## Foe

| Term | Fantasy | Codex | Status |
|---|---|---|---|
| **Breach** | Something big enough that the field bends. | A breaching blow overflows: what the shield cannot absorb reaches the hull, and if that is a quarter of maximum hull it injures a component like any bare-hull blow. It breaks the fundamental promise that a standing shield stops the big hit, so it is a dangerous, uncommon attack modifier, and its counterplay is not the shield: redirect it or interrupt it. | implemented |
| **Foe action** | The ghoul claws, but sometimes it bites. You always know which. | A foe has a base attack, the quick read of how hard it hits, and a list of attacks that scale it. Each round every foe on the field picks one by weight before the player acts, so what it will do and to whom is announced exactly. An attack's damage is the base times its factor, and the help text shows the resulting number. | implemented |

## Holes

Every entry whose `design.holes` is not empty. This is the list of things the mechanics do not do yet.

- **Shield** (implemented): Rates and shield sizes are placeholders. Decided 18 September: block-the-blow replaced bleed-through, and the in-combat trickle was dropped the same day (a passive may bring it back for one chassis).
- **Heat** (implemented): Heat does nothing below the cap. Consider effects at high heat short of overflow.
- **Rift Pressure** (implemented): Spawns a fixed squad. Should draw from the battle's faction(s) and escalate.
- **Gate Integrity** (implemented): Gate damage formula is a placeholder (strength divided by three).
- **Damage range** (implemented): Ranges are content-authored per component; no upgrade path raises min or max yet.
- **Critical hit** (implemented): No crit-chance upgrades yet; no visible crit chance on the die face beyond the description.
- **Flip** (planned): Needs a definition of opposite faces for non-d6 dice.
- **Reflect** (idea): Would need shield sources to be tracked separately.
- **Cracked component** (implemented): Threshold is a placeholder. Repair cost and the hangar screen are not built.
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
- **Component** (implemented): Multi-slot components were considered and scrapped on 18 September as invisible complexity.
- **Fixed component** (implemented): Decided against unlocking fixed slots for money (18 September).
- **Armour** (implemented): Numbers are placeholders. Armour from components is content, not yet written.
- **Breach** (implemented): A property of a foe's attack action. No foe carries it yet; Ryan places it. Redirect and interrupt do not exist yet. Name is a placeholder (pierce is taken by the player keyword).
- **Foe action** (implemented): Only attacks run; defend, buff and debuff actions stay planned. Weighted RNG is the whole brain for now.
- **Strikes** (implemented): Heat is paid once per use, not per strike. Foes have no armour yet, so on the player side strikes only matter for procs until they do.
