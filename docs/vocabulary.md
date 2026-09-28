# Riftgate vocabulary

Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.

Status: 77 implemented, 22 planned, 0 idea.

## Resource

| Term | Codex | Status |
|---|---|---|
| **Hull** | Damage that gets past shield removes hull. Hull never recovers during a battle. At zero the mech is a wreck to be salvaged after the battle. | implemented |
| **Shield** | Enemy damage hits shield before hull, and a standing shield blocks a blow whole: however small the shield and however big the blow, nothing bleeds through to the hull (a breaching foe is the exception). The blow still costs the shield its damage. Shield components add shield up to the chassis maximum; in a fight that is the only way shield comes back. Out of combat it returns each battlefield phase at the chassis's field rate. It never refills for free between skirmishes. | implemented |
| **Heat** | Attack components may add heat. At the end of the round, heat above the chassis maximum burns hull one for one and the gauge settles at the maximum; until then a vent can still bring it down. Vent components remove heat. At the start of every turn a mech sheds its chassis's cooling rating in heat, so a round spent on ballistics or shields is a way of cooling down without a vent; Overheating ticks at the end of the round, after the enemy has struck, so a scorch lands on the round's peak heat before cooling relieves it. | implemented |
| **Reroll** | Three rerolls per round, each rerolling every unlocked, unspent mech die. A reroll always lands on a different component: never the one showing, never one equivalent to it (a die whose components are all alike keeps what it shows). Rerolls may be spent before or after attacking, so a low damage roll is information for the rest of the round. Never pooled across rounds. | implemented |
| **Rift Pressure** | Ticks once per battlefield phase and once per skirmish round. When full it resets and a fresh pack emerges at the rift. | implemented |
| **Gate Integrity** | A pack whose path reaches the gate strikes it instead of moving. Gate integrity persists across battles and is repaired in the meta. | implemented |
| **Armour** | A chassis number taken off every blow that lands on bare hull, flat, never a percentage. A blow smaller than the armour does nothing. Shield is not armoured: a blow on shield costs the shield its full damage. | implemented |

## Equipment

| Term | Codex | Status |
|---|---|---|
| **Component** | A piece of equipment on a mech, and one entry on its die. There is no generic equipment: every entry on a die is a component, or an empty hardpoint. Each round the die is rolled and the component that comes up is what the mech can do. | implemented |
| **Hardpoint** | A free slot on the chassis. Any component fits any hardpoint. On the model a hardpoint is a socket where the component mounts. | implemented |
| **Fixed component** | A component built into the chassis: always on the die, never removed, never sold, and it uses no hardpoint. The Badger's claw and its plating are fixed. | implemented |
| **Empty hardpoint** | A hardpoint with nothing in it is an entry on the die that does nothing when it comes up. Nothing fills it for you. | implemented |

## Component Kind

| Term | Codex | Status |
|---|---|---|
| **Attack component** | Spend on a foe within reach to deal its power in damage, then apply its keywords and heat. | implemented |
| **Shield component** | Spend on self or an ally to add its power in shield, capped at that mech's shield maximum. | implemented |
| **Vent component** | Spend on self or an ally to remove its power in heat. | implemented |
| **Cracked component** | A cracked component still acts but loses all keywords and unique effects. Cracked compoents can still crit, still generate heat, and still provide their passive bonuses and abilities. A destroyed component is blank and does nothing when it comes up, and provides passive bonuses but not passive abilities. Both persist until repaired in the hangar. | implemented |
| **Weapon** | A component spent on a foe within its reach. It need not deal damage. | implemented |
| **Equipment** | A component spent on a machine: itself, an ally, or either, as the component says. Shields and vents are equipment. | implemented |

## Component Property

| Term | Codex | Status |
|---|---|---|
| **Damage range** | A kinetic attack component shows a minimum and a maximum and rolls between them when spent, immediately and visibly. Energy components show one number and never roll. Numbers are in tens. | implemented |
| **Critical hit** | A kinetic component may carry a crit chance. On a crit the roll is multiplied by the crit multiplier: a base of 2 for everyone, plus every crit damage bonus that applies, from the component itself or a passive. Bonuses add to the multiplier, never multiply each other, so a +0.5 weapon with a +0.5 passive crits for 3 times. The readout shows the resulting multiplier. Energy components never crit. Crits fire the on_crit passive trigger. | implemented |
| **Targets** | Whom a piece of equipment may be spent on: self and allies, self only, or allies only. Shown as a chip on the die when narrowed. | implemented |
| **Strikes** | An attack's blows per use. A weapon with three strikes lands three separate hits: each rolls its own damage, its own crit and its own effects, so a rapid-fire weapon procs often. Against a shield, every strike past the first reaches the hull; against armour, every small strike loses the armour, so many small hits are the wrong tool for a heavy target and the right one for a soft one. Foe attacks have strikes too. | implemented |

## Reach

| Term | Codex | Status |
|---|---|---|
| **Melee** | Targets any front-rank foe. Can target any back-rank foe when the front rank is empty. | implemented |
| **Line of sight** | Targets any front-rank foe, and any back-rank foe whose column is exposed. | implemented |
| **Indirect** | Targets any foe in either rank. Hitting the front rank triggers danger close. | implemented |

## Keyword

| Term | Codex | Status |
|---|---|---|
| **Spread** | Player keyword. Also hits the foes in the neighbouring columns of the target's rank. | implemented |
| **Penetrate** | Player keyword. Hits first the front, then the back rank of a single column. | implemented |
| **Overwhelm** | Player keyword. Hits that kill the front rank spill leftover damage to the back rank. | planned |
| **Burn** | Player keyword. Burning enemies lose 5 HP per stack at the start of their action, then lose one stack. Bypasses armour. Can be resisted. | implemented |
| **Corrode** | Player keyword. Corroding enemies lose 1% of their HP per stack at the start of their action, then lose one stack. Bypasses armour. Can be resisted. | planned |
| **Suppress** | Player keyword. The target skips its telegraphed action this round, then gains a stack of Numbed. Bosses and elites gain two stacks. A Numbed foe may shrug it off. | implemented |
| **Overcharge** | Player equipment keyword. The machine it is spent on deals more damage with its attacks until the end of the round. | planned |
| **Execute** | +100% damage against a foe at or below half its health. Reduced to +50% against bosses and elites. | implemented |
| **Chain** | If this attack kills an enemy, repeat it on a new, valid target. | implemented |
| **Rapid** | After this component is spent, it is switched off for the rest of this round, the die rerolls for free (never the same entry), and the mech may act again. The switch-off only stops an infinite turn. | implemented |
| **Steady** | A component with steady always uses its average damage as its base damage. It may still crit. | implemented |
| **Disable** | Enemy keyword. The component the target's die is showing is switched off through the target's next turn: if the die lands on it, it comes up blank. | implemented |
| **Corrupt** | Foe attack keyword. Each blow that lands leaves a stack of Corrupted on the component the target's die is showing: it deals damage to its owner whenever spent. | implemented |
| **Cleanse** | Player keyword, on shield and vent components. Whoever the component is spent on also loses every Disabled, Corrupted and Overheating status. A rapid component's own switch-off is not a status a cleanse touches. | implemented |
| **Energy Armour** | Player status. Until end of round, attacks that strike shield are reduced by a flat amount. Stacks. | planned |
| **Scramble** | Player keyword. Randomize the enemy's intended target. | planned |
| **Confuse** | Player keyword. Randomize the enemy's intended target to target another enemy instead. | planned |

## Status

| Term | Codex | Status |
|---|---|---|
| **Numbed** | Foe status. Each stack is 10% resistance to being Suppressed: a suppress it shrugs off does nothing, and adds no stack. Does not decay; clears at end of skirmish. | implemented |
| **Retaliate** | Until the end of this round, foes that strike this unit lose HP equal to this component's power. Stacks. | planned |
| **Disabled** | Component status. This die entry comes up blank while it lasts; the component itself is untouched. A foe's disable lasts through the mech's next turn and can be cleansed; a rapid component's own switch-off ends with the round. | implemented |
| **Corrupted** | Component status. Every time this die entry is spent it bites its owner for 10 per stack, shield first, before the component acts. A blank is never spent, so a disabled entry does not bite. Stacks. Clears at end of skirmish. Can be cleansed. | implemented |
| **Phased** | Player and enemy status. This unit cannot attack, nor can it be damaged by attacks, until end of round. | planned |
| **Taunt** | Player status. Until end of round, all front-rank foes will target this unit. | planned |
| **Beacon** | Player status. Until end of round, all back-rank foes will target this unit. | planned |
| **Burning** | Foe status. Loses 5 HP per stack at the start of its action, then loses one stack. Bypasses armour. Applied by the burn keyword, one stack per twenty damage dealt. | implemented |
| **Suppressed** | Foe status. Skips its action this round, then clears. | implemented |
| **Cracked component** | Mech status, global rule. When a blow lands on bare hull (no shield standing) and what gets past armour is at least a quarter of maximum hull, the mech's die is rolled and the component it lands on is injured. An intact component cracks: it loses its keywords and unique effects, but still does its basic action, can still crit, still generates heat, and still provides its passive bonuses and abilities. Any shield standing, however small, prevents injury, except against a breach; a foe's double strike is the other way past it. A cracked component stays cracked across skirmishes and battles until repaired in the hangar. | implemented |
| **Destroyed component** | Mech status. When an injury lands on a component that is already cracked, it is destroyed: blank, it does nothing when it comes up, and provides its passive bonuses but not passive abilities. until the hangar repairs or replaces it. An injury that lands on a destroyed component or an empty hardpoint finds nothing to break, so a badly broken mech shrugs off more of them. | implemented |
| **Overheating** | Mech status. Gains 5 heat per stack at the end of the round, after the enemy has struck, then loses one stack. The mech-side counterpart of Burning: metal does not burn, it heats. Applied by foe attacks that scorch. Clears at end of skirmish. Can be cleansed. | implemented |

## Formation

| Term | Codex | Status |
|---|---|---|
| **Front rank** | Three slots. Front-preferring foes fill these. Always in line of fire. | implemented |
| **Back rank** | Three slots behind the front. Back-preferring foes hold these. | implemented |
| **Exposed** | A back-rank foe is exposed when the front slot in its column is empty. Exposed foes are in line of fire. | implemented |
| **Reinforcements** | Foes not yet on the field. Front and Back ranks have their own reinforcement pool. Empty slots refill from the pool of reinforcements after each round. The skirmish is won when the field and all reinforcements are defeated. | implemented |
| **Splash** | Indirect fire on the front rank damages the firing unit equal to half the component's power, rounded up. | implemented |
| **Massive** | A massive foe fills both slots of a column and counts as front rank. Its column is never exposed while it stands. Only some elites and bosses are massive. | implemented |
| **Withdraw** | Available at any point of the player's turn, the first round included. The price is always the same: the enemy takes its turn, then the team flees at the end of the round, so nobody leapfrogs out of contact unscathed. Ends the skirmish; survivors on both sides carry their damage to the battlefield. Shields do not refill on withdrawing; they recharge at the field rate only in phases spent out of combat. | implemented |
| **Strike order** | Foes strike in the order they stand: front rank left to right, then the back rank. Each blow is resolved on its own against the shield standing at that moment, so which foe strikes first decides what a small shield blocks. At first contact the heaviest hitters deploy left. | implemented |

## Battlefield

| Term | Codex | Status |
|---|---|---|
| **Movespeed** | Movement points per phase. Entering a hex costs its terrain's move cost for that unit's traits. | implemented |
| **Intent** | Each pack's path for the phase is previewed exactly. It heads for the gate or the nearest city defense, or hunts mechs if aggro. Player routes resolve first. | implemented |
| **Body block** | A pack stops at the first hex on its path occupied by a blocking unit. Flyers do not block; packs pass through their hex but never land on it. | implemented |
| **Contact** | After all movement, every connected group of adjacent units that contains both sides becomes one skirmish. Multiple skirmishes resolve one at a time. | implemented |
| **Pack** | An enemy hex is a pack: one foe type times a strength. A skirmish's enemy composition is whatever packs are chained together at contact, so the rift's formation and the player's disruption of it decide what you fight. Bosses are single three-hex units. | implemented |
| **Footprint** | A unit covers one or more hexes. A boss covers three in a triangle. Every footprint hex blocks, touches for contact, and is a tap target. Packs and mechs stay single-hex. | implemented |
| **Structure** | Gate and rift hexes are structures wider than one hex. Nobody stands on them. A pack whose path reaches any gate hex strikes the gate. | implemented |
| **Spawn** | When Rift Pressure fills, the next pack of the faction's spawn list appears on the nearest free hex to the rift. | implemented |

## Terrain

| Term | Codex | Status |
|---|---|---|
| **Plain** | Cost 1. | implemented |
| **Road** | Cost 1. | implemented |
| **Rough** | Cost 2. Cost 1 for quads and flyers. | implemented |
| **Ruins** | Cost 2. Cost 1 for quads and flyers. | implemented |
| **Water** | Impassable except for hover and flyer. | implemented |
| **Mountain** | Impassable except for flyer. | implemented |

## Trait

| Term | Codex | Status |
|---|---|---|
| **Flyer** | Ignores terrain cost, crosses water and mountains, cannot body-block. | implemented |
| **Hover** | Crosses water. | implemented |
| **Walker** | Rough and ruins cost 1. | implemented |
| **Tank** | No effect yet. | planned |
| **City defense** | A static player-side unit. Packs path toward it, and it joins any skirmish it is adjacent to. | implemented |

## Trigger

| Term | Codex | Status |
|---|---|---|
| **On attack** | Passive trigger. Fires after the damage roll on every attack. Effects: multiply or add damage or heat, or set a minimum damage. An effect may carry a when condition: component_cracked (only when the component being spent is cracked). | implemented |
| **On shield gain** | Passive trigger. Fires when this mech gains shield from any source. | planned |
| **On heat gain** | Passive trigger. Fires when this mech gains heat. | planned |
| **On round start** | Passive trigger. Fires after the roll, before rerolls. | planned |
| **On skirmish start** | Passive trigger. Fires once when the skirmish begins. | planned |
| **On crit** | Passive trigger. Fires when an attack component crits. Effects: multiply or add damage, add burn to the target, vent the attacker's heat. | implemented |
| **On hull damage** | Passive trigger. Fires when this mech loses hull. | planned |
| **Out of combat** | Passive trigger. Fires at the end of a battlefield phase in which this mech had no skirmish. | planned |
| **on_injury** | Passive trigger. Fires when an injury lands on a component. Effects: no_destroy (a cracked component holds instead of being destroyed). | implemented |
| **Static** | Passive trigger. Always on. Its effects change a mech's numbers or a component's properties while a condition holds, rather than firing on an event: add_stat and multiply_stat on hull, shield, heat, armour, move or recharge; add_damage_taken and multiply_damage_taken on every incoming blow; set_reach on a component (the Badger's cracked weapons become melee); suppress, which turns off another effect by id or tag. | implemented |

## Commander

| Term | Codex | Status |
|---|---|---|
| **Command die** | One die rolled alongside the mech dice each round. Its entries are rechargeable commander abilities and never deal damage. They come from the hangar, never from rewards. Die size is a research path. | planned |
| **One-shot** | Consumable ability. Pouch of three. Picked up from skirmishes, expires when the battle ends. Starting stock restocks every battle. | planned |
| **Reward pick** | After a skirmish victory: a modifier on a component you carry, a one-shot, or a battle-wide boon. Weighted by the pack's faction. | planned |

## City

| Term | Codex | Status |
|---|---|---|
| **City ability** | Battlefield-level ability owned and upgraded by the city: sprint, airlift, teleport, tractor beam, orbital strike. Cooldowns measured in phases. | planned |
| **Cooldown** | City abilities only. Counted in battlefield phases. Never used inside a skirmish. | planned |

## Foe

| Term | Codex | Status |
|---|---|---|
| **Breach** | A breaching blow overflows: what the shield cannot absorb reaches the hull, and if that is a quarter of maximum hull it injures a component like any bare-hull blow. It breaks the fundamental promise that a standing shield stops the big hit, so it is a dangerous, uncommon attack modifier, and its counterplay is not the shield: redirect it or interrupt it. | implemented |
| **Foe action** | A foe has a base attack, the quick read of how hard it hits, and a list of attacks that scale it. Each round every foe on the field picks one by weight before the player acts, so what it will do and to whom is announced exactly. An attack's damage is the base times its factor, and the help text shows the resulting number. | implemented |
| **Scorch** | Foe attack keyword. Each blow that lands leaves one stack of Overheating on the mech it hit. | implemented |

## Rules

| Term | Codex | Status |
|---|---|---|
| **Order of operations** | Everything that changes a number goes through one pipeline, in one order. Sources: the chassis passive and each fitted component's passive (until refitted), skirmish rewards (until the battle ends), buffs and debuffs (until the skirmish ends, or until the end of a given round). First suppression, shortest-lived source to longest: a live effect that suppresses another by id or tag turns it off, and a suppressed effect suppresses nothing. Then the gate: an effect takes part only if it is live, its trigger fires now, its condition holds, and, for an ability, its component is not destroyed (a destroyed component keeps its stat bonuses and loses its abilities). Then adds, all sources summed; then multiplies, all sources multiplied; then floors and caps; then overrides, where the shortest-lived source wins and the latest granted breaks ties. In an attack, the crit multiplier and the fixed keyword rule (execute) come before the pipeline's adds and multiplies. Nothing is ever stored as a total: every read asks again, so an effect that is gone stops answering. Statuses stack: the same status granted again adds stacks instead of a second copy; an add is worth its value per stack and a multiply is applied once per stack; a status that ticks applies its per-stack tick at its owner's turn, then loses one stack, and is gone at zero. | implemented |

## Holes

Every entry whose `design.holes` is not empty. This is the list of things the mechanics do not do yet.

- **Shield** (implemented): Rates and shield sizes are placeholders. Decided 18 September: block-the-blow replaced bleed-through, and the in-combat trickle was dropped the same day (a passive may bring it back for one chassis).
- **Heat** (implemented): Heat does nothing below the cap. Consider effects at high heat short of overflow. Cooling numbers are placeholders; cooling must stay below a typical weapon's heat or heat never matters, and a vent component must be worth a whole turn (tuning).
- **Rift Pressure** (implemented): Spawns a fixed pack. Should draw from the battle's faction(s) and escalate.
- **Gate Integrity** (implemented): Gate damage formula is a placeholder (strength divided by three).
- **Damage range** (implemented): Ranges are content-authored per component; no upgrade path raises min or max yet.
- **Critical hit** (implemented): The base is Face.CRIT_MULT, a balance knob; lower it if crit triggers make crits too strong at low chance.
- **Numbed** (implemented): Numbers are placeholders; a boss at five suppresses is immune.
- **Overcharge** (planned): Retired as double damage and double heat on 26 September (the Sparrowhawk's passive already was that); Ryan wants the word for an offensive buff. Numbers and shape open; needs player buffs to exist.
- **Equipment** (implemented): Buffs will be equipment too, once they exist.
- **Corrupt** (implemented): No foe carries it yet; Ryan places it (The Chorus, presumably).
- **Cleanse** (implemented): No component carries it yet; Ryan places it.
- **Retaliate** (planned): Would need shield sources to be tracked separately.
- **Corrupted** (implemented): The bite is a placeholder number (Skirmish.CORRUPT_BITE_PER_STACK).
- **Cracked component** (implemented): Threshold is a placeholder. Repair cost and the hangar screen are not built.
- **Reinforcements** (implemented): Elites should surface at set points rather than in pool order.
- **Massive** (implemented): Cleave treats it as a front-rank neighbour; pierce cannot hit anything behind it because nothing is.
- **Intent** (implemented): Aggro is a fixed flag. Should be a behaviour per foe type.
- **Contact** (implemented): No participant cap. May need one for phone readability.
- **Footprint** (implemented): Footprints do not rotate with facing.
- **Structure** (implemented): The rift does nothing yet beyond marking where packs spawn.
- **Spawn** (implemented): A full spawn list should arrive together as a formation; pressure currently sends one pack at a time.
- **Road** (implemented): Tanks should move faster on roads. Not coded.
- **Ruins** (implemented): Designed as cover for the pack inside a skirmish. Skirmish terrain conditions are not coded.
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
- **Static** (implemented): Every read asks the pipeline; nothing is written to a stat or a component, so an effect that is gone stops answering. A static reach rule cannot be conditioned on reach.
- **Order of operations** (implemented): Refit (the hangar) is what changes loadout-scoped effects; not built.
- **Overheating** (implemented): Placeholder name and numbers, engine id overheating; Ryan is looking for the flavour.
- **Scorch** (implemented): Placeholder name. No foe carries it yet; Ryan places it (fire demons, presumably).
