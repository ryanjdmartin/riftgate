# Riftgate vocabulary

Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.

Status: 106 implemented, 7 planned, 0 idea.

## Resource

| Term | Codex | Status |
|---|---|---|
| **Hull** | Damage that gets past shield removes hull. Hull never recovers during a battle. At zero the mech is a wreck to be salvaged after the battle. | implemented |
| **Shield** | Enemy damage hits shield before hull, and a standing shield blocks a blow whole: however small the shield and however big the blow, nothing bleeds through to the hull (a breaching foe is the exception). The blow still costs the shield its damage. Shield components add shield up to the chassis maximum (a component with Overshield may pass it, and the excess fades at the end of the round); in a fight that is the only way shield comes back. Out of combat it returns each battlefield phase at the chassis's field rate. It never refills for free between skirmishes. | implemented |
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
| **Buff component** | Equipment spent on a machine (itself, an ally, or either, as the component says) that grants it a status, so many stacks deep, through the end of so many rounds: Overcharged for damage, Braced against damage, Primed to burn on hit. The die shows the status name and the stacks. | implemented |
| **Cracked component** | A cracked component still acts but loses all keywords and unique effects. Cracked compoents can still crit, still generate heat, and still provide their passive bonuses and abilities. A destroyed component is blank and does nothing when it comes up, and provides passive bonuses but not passive abilities. Both persist until repaired in the hangar. | implemented |
| **Weapon** | A component spent on a foe within its reach. It need not deal damage. | implemented |
| **Equipment** | A component spent on a machine: itself, an ally, or either, as the component says. Shields and vents are equipment. | implemented |

## Component Property

| Term | Codex | Status |
|---|---|---|
| **Damage range** | A kinetic attack component shows a minimum and a maximum and rolls between them when spent, immediately and visibly. Energy components show one number and never roll. Numbers are in tens. | implemented |
| **Critical hit** | A kinetic component may carry a crit chance. On a crit the roll is multiplied by the crit multiplier: a base of 2 for everyone, plus every crit damage bonus that applies, from the component itself or a passive. Bonuses add to the multiplier, never multiply each other, so a +0.5 weapon with a +0.5 passive crits for 3 times. The readout shows the resulting multiplier. Energy components never crit. Crits fire the on_crit passive trigger. | implemented |
| **Targets** | Whom a piece of equipment may be spent on: self and allies, self only, or allies only. Shown as a chip on the die when narrowed. | implemented |
| **Vents all** | An attack that fires the machine's whole heat as it is spent: the heat gauge is empty after the shot, and every 10 heat fired adds the component's bonus to the blow before crits and passives. The shot's own heat cost still lands. | implemented |
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
| **Overwhelm** | Player keyword. When a blow kills a front-rank foe, what it had past the kill carries into the foe behind it in the same column. Nothing stands behind a massive foe. | implemented |
| **Burn** | Player keyword. Burning enemies lose 5 HP per stack at the start of their action, then lose one stack. Bypasses armour. Can be resisted. | implemented |
| **Corrode** | Player keyword. Corroding enemies lose 1% of their HP per stack at the start of their action, then lose one stack. Bypasses armour. Can be resisted. | planned |
| **Lure** | Player keyword, on any entry aimed at a foe: a weapon, a status, or an entry that does nothing else. Every foe the entry reaches turns on this machine for the round, intents and all; reach and area decide who and how many. A lured foe whose move has no target keeps doing it. | implemented |
| **Disrupt** | Player keyword, on any entry aimed at a foe. The foe does its other move instead, this round, and its new intent shows at once. A foe with nothing else open is not moved. | implemented |
| **Suppress** | Player keyword. The target skips its telegraphed action this round, then gains two stacks of Numbed (three if massive). A foe may shrug it off: its own stun resistance plus 10% a Numbed stack. | implemented |
| **Volatile** | Player keyword, on any kind of component. Spending it bites its owner for 10 hull, past shield and armour, before the component acts. A blank is never spent, so a disabled entry does not bite. | implemented |
| **Devour** | Player keyword. Every foe this component kills gives its owner a stack of Overcharged for the skirmish; the stacks fade one a round at the round's end. | implemented |
| **Execute** | +100% damage against a foe at or below half its health. Reduced to +50% against bosses and elites. | implemented |
| **Chain** | If this attack kills an enemy, repeat it on a new, valid target. | implemented |
| **Rapid** | After this component is spent, it is switched off for the rest of this round, the die rerolls for free (never the same entry), and the mech may act again. The switch-off only stops an infinite turn. | implemented |
| **Steady** | A component with steady always uses its average damage as its base damage. It may still crit. | implemented |
| **Disable** | Enemy keyword. The component the target's die is showing is switched off through the target's next turn: if the die lands on it, it comes up blank. | implemented |
| **Corrupt** | Foe attack keyword. Each blow that lands leaves a stack of Corrupted on the component the target's die is showing: it deals damage to its owner whenever spent. | implemented |
| **Cleanse** | Player keyword, on shield and vent components. Whoever the component is spent on also loses every Disabled, Corrupted and Overheating status. A rapid component's own switch-off is not a status a cleanse touches. | implemented |
| **Overshield** | Player keyword, on shield components, rare. The shield may raise its target past the target's maximum; shield past the maximum fades at the end of the round. A shield die spent on a machine already at its maximum is never wasted when it carries this. | implemented |

## Status

| Term | Codex | Status |
|---|---|---|
| **Numbed** | Foe status. Each stack is 10% resistance to a suppress on top of the foe's own; a suppress it shrugs off does nothing and adds no stack. Loses a stack at the start of each of its turns, so a stun repeated on one foe stops landing while stuns spread across the formation keep working. Numbed is exempt from every other interaction: nothing deepens it, spreads it, cleanses it or reads it beyond suppress itself and its own decay. | implemented |
| **Retaliate** | Mech status. While it lasts, a foe that strikes this machine's bare hull is Shocked. From buff equipment it lasts the rounds the component says; the Armadillo's Faraday Hull carries it always. | implemented |
| **Shocked** | Foe status. The next blow this foe takes deals double damage, then the status clears. A Shocked foe that strikes bare hull again takes 10. Never stacks. | implemented |
| **Overcharged** | Mech status. Each stack is +10% damage on this machine's attacks. From buff equipment it lasts through the rounds the component says; from devour it lasts the skirmish and loses a stack at the end of each round unless a passive says otherwise. | implemented |
| **Braced** | Mech status. Armour +10 per stack: that much off every blow on bare hull, flat. Granted by buff equipment for the rounds it says. | implemented |
| **Primed** | Mech status. Every blow this machine lands leaves a stack of Burning per stack of Primed. Granted by buff equipment for the rounds it says. | implemented |
| **Disabled** | Component status. This die entry comes up blank while it lasts; the component itself is untouched. A foe's disable lasts through the mech's next turn and can be cleansed; a rapid component's own switch-off ends with the round. | implemented |
| **Corrupted** | Component status. Every time this die entry is spent it bites its owner for 10 per stack, shield first, before the component acts. A blank is never spent, so a disabled entry does not bite. Stacks. Clears at end of skirmish. Can be cleansed. | implemented |
| **Phased** | Player and enemy status. This unit cannot attack, nor can it be damaged by attacks, until end of round. | planned |
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
| **Movespeed** | Move in tens: how far a machine goes in a phase. A normal hex costs 10, so MOVE 40 is four hexes on open ground. Each way of moving calls each ground fast (5), normal (10) or slow: a slow hex can always be entered with any move left, and the step ends the move. Move left at the end of a phase is lost. | implemented |
| **Intent** | Each pack commits its path when the round opens and the map shows it exactly: a pusher walks to the gate or the nearest city defense, an aggressive pack turns for a machine that ends inside its reach, a hunter chases the machine it has locked. Player routes resolve first. | implemented |
| **Body block** | A pack stops at the first hex on its path occupied by a blocking unit. Flyers do not block; packs pass through their hex but never land on it. | implemented |
| **Contact** | After all movement, every machine standing inside a pack's zone fights that pack. A machine inside two packs' zones joins their fights into one; that is the only way fights join. Multiple skirmishes resolve one at a time, in the order you choose. | implemented |
| **Engagement zone** | Every pack has a zone, a radius in hexes around where it ends its move, drawn on the map before Resolve. Stand inside it and you fight that pack. Nothing else decides who fights: a pack stops only where a body stands in its path, and a machine beside its path is walked past unless the zone reaches it. | implemented |
| **Behaviour** | Every pack commits its route when the round opens; the route you read is the route, and only a body in its path cuts it. A pusher walks it to the gate whatever you do. An aggressive pack does the same unless a machine ends inside its reach, the dashed ring: then it comes for the biggest catch it can make. A hunter locks one machine when it spawns, by its caveat (the nearest, weakest, strongest, slowest or fastest), wears the target rings on it, and chases wherever that machine ends until one of them is dead. | implemented |
| **Pack** | An enemy hex is a pack: one foe type times a strength. A skirmish's enemy composition is every pack whose zone your machines stand in, so the rift's formations and how you come at them decide what you fight. Bosses are single three-hex units. | implemented |
| **Footprint** | A unit covers one or more hexes. A boss covers three in a triangle. Every footprint hex blocks, touches for contact, and is a tap target. Packs and mechs stay single-hex. | implemented |
| **Structure** | Gate and rift hexes are structures wider than one hex. Nobody stands on them. A pack whose path reaches any gate hex strikes the gate. | implemented |
| **Spawn** | When Rift Pressure fills, the next pack of the faction's spawn list appears on the nearest free hex to the rift. | implemented |

## Terrain

| Term | Codex | Status |
|---|---|---|
| **Plain** | Open ground. Normal pace for every machine; wheels run fast. Packs cross it. | implemented |
| **Road** | Open ground, the same as plain: the road is art. Normal pace for every machine; wheels run fast. Packs cross it. | implemented |
| **Rough** | Forest and scrub. Normal pace for tracks, walkers and flyers; slow for wheels and hovercraft, which can enter it but end their move there. Packs cross it at full pace. | implemented |
| **Ruins** | Rubble. Normal pace for walkers and flyers; slow for tracks, wheels and hovercraft, which can enter it but end their move there. Packs cross it at full pace. | implemented |
| **Water** | Hovercraft skim it fast and tracks ford at normal pace; walkers and wheels can enter it but end their move there; flyers pass over. Packs never enter it. | implemented |
| **Mountain** | Impassable except for flyers, which cross at normal pace. Packs go around. | implemented |

## Trait

| Term | Codex | Status |
|---|---|---|
| **Flyer** | Normal pace over every ground, mountains included. Packs pass through it: it cannot stop one. It fights by the zone like any machine. | implemented |
| **Hover** | Skims water fast. Rough ground and ruins are slow: it can enter them, and the step ends its move. Stops a pack in its path like any ground machine. | implemented |
| **Walker** | Legs. Rough ground and ruins at normal pace; water is slow: it can enter it, and the step ends its move. | implemented |
| **Tracked** | Tracks. Ploughs through forest and fords water at normal pace; rubble is slow: it can enter ruins, and the step ends its move. | implemented |
| **Wheeled** | Wheels. Fast on open ground. Rough ground, ruins and water are slow: it can enter them, and the step ends its move. | implemented |
| **Stealth** | A pack's zone never pulls it in on its own. Joins a fight only when another machine is in it, or when it stopped a pack in its path; a pack whose zone merely falls on it has walked past. | implemented |
| **City defense** | A static player-side unit. Packs path toward it, and it joins any skirmish it is adjacent to. | implemented |

## Trigger

| Term | Codex | Status |
|---|---|---|
| **On attack** | Passive trigger. Fires after the damage roll on every attack. Effects: multiply or add damage or heat, or set a minimum damage. An effect may carry a when condition: component_cracked (only when the component being spent is cracked). | implemented |
| **On shield gain** | Passive trigger. Fires when this mech gains shield from any source, with the amount gained; it may shed heat or grant a status, never raise more shield. | implemented |
| **On shielding an ally** | Passive trigger. Fires when this machine spends a shield component on an ally, with the shield's size; it may shed the ally's heat or grant the ally a status, never raise more shield. It never fires for a shield on itself. | implemented |
| **On heat gain** | Passive trigger. Fires when this mech gains heat, with the amount; it may raise shield or grant a status, never add heat. | implemented |
| **On round start** | Passive trigger. Fires after the roll, before rerolls: shield from heat, a flat shield, a vent. | implemented |
| **On skirmish start** | Passive trigger. Fires once as the skirmish begins, before the first roll: a shield, a vent, a status. | implemented |
| **On foe status** | Passive trigger. Fires when any foe gains a status (Burning today; the buffs and debuffs to come), whoever applied it, and never for Suppressed or Numbed themselves. Effects: chance_suppress (a chance the foe is also Suppressed, rising per point of shield the owner is missing). | implemented |
| **On applying stacks** | Passive trigger. Fires when this machine applies stacks of a status to anyone: a foe's Burning (from a burn or from Primed), an ally's or its own buff, its own Overcharged from a devour. Effects: add_stacks (so many stacks more, flat or for every so much heat the machine carries). Never for Numbed, which is exempt from every interaction. | implemented |
| **On crit** | Passive trigger. Fires when an attack component crits. Effects: multiply or add damage, add burn to the target, vent the attacker's heat. | implemented |
| **On hull damage** | Passive trigger. Fires when this mech loses hull to a blow or a bite, never to its own overheat. | implemented |
| **Out of combat** | Passive trigger. Fires at the end of a battlefield phase in which this mech had no skirmish, after the field recharge: more shield. | implemented |
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
| **Stun resistance** | A foe's base chance to shrug off a suppress, before Numbed. Rank and file have none; bosses carry some. | implemented |
| **Aim** | What a foe's sense goes for when it picks whom to strike, chosen for every foe on its own as the round opens and shown as its arrow before you act. The exposed: weighted toward the machine its blow would hurt most, a shield standing lowering the draw and a shield about to break raising it. Anything: any machine alike. Heat: the hottest machine. The armed: a machine showing an intact weapon. Fires as one: the rank shares a pick. A move may aim differently from its foe. The pick is a commitment: a foe whose target shields up still swings at it. | implemented |
| **Breach** | A breaching blow overflows: what the shield cannot absorb reaches the hull, and if that is a quarter of maximum hull it injures a component like any bare-hull blow. It breaks the fundamental promise that a standing shield stops the big hit, so it is a dangerous, uncommon attack modifier, and its counterplay is not the shield: redirect it or interrupt it. | implemented |
| **Foe action** | A foe has a base attack, the quick read of how hard it hits, and a list of actions: attacks that scale it, and defends, buffs and debuffs it does instead of a blow (folding against damage, regrowing, readying to get back up, calling up a foe, rallying the others, costing the team a reroll, stoking a machine's heat, scrambling a reroll, cracking a component). Each round every foe on the field picks one by weight before the player acts, so what it will do and to whom is announced exactly. An attack's damage is the base times its factor, and the help text shows the resulting number. | implemented |
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
- **Buff component** (implemented): Only one component carries it, a draft. Debuffs on foes stay weapons.
- **Damage range** (implemented): Ranges are content-authored per component; no upgrade path raises min or max yet.
- **Critical hit** (implemented): The base is Face.CRIT_MULT, a balance knob; lower it if crit triggers make crits too strong at low chance.
- **Overwhelm** (implemented): Built 29 September. The spill is plain damage: it spends a shock and feeds a devour, and carries no other keyword of the blow. The Wild Boar's Juggernaut Drive grants it to every attack (grant_keyword, the first passive to add a keyword).
- **Lure** (implemented): Decided 2 October in place of Taunt and Beacon (bible, section 5). No status and no chip: the arrow is the record. A draw by ally (cover) is parked until a support role proves to need it.
- **Disrupt** (implemented): Decided 2 October in place of the planned Scramble and Confuse (bible, section 5). Deterministic: the next move in the foe's list that its conditions allow, so a boss steps through its pattern.
- **Numbed** (implemented): Decaying since 26 September (was permanent for the fight); numbers are placeholders, to be judged against skirmish and boss-fight lengths. Exempt from everything (Ryan, 2 October): a stun resist that passives or cleanses could touch is where other games' combat loops broke.
- **Stun resistance** (implemented): 30 on the three bosses as a placeholder.
- **Volatile** (implemented): The Arsenal's self-damage (Ryan, 28 September), built 29 September: hull outright where the Corrupted bite takes shield first. The bite is a placeholder number (Skirmish.VOLATILE_BITE). It will feed the Nemesis's Crucible Capacitor once that counts blows that reach hull.
- **Devour** (implemented): The Ammit's talons (28 September), built 29 September on the kill in the attack resolution: a spread that kills two feeds two, a chain feeds on every link. The Quintessence Tap, which stops the fade and keeps the stacks for the battle, is planned.
- **Equipment** (implemented): Buffs will be equipment too, once they exist.
- **Corrupt** (implemented): No foe carries it yet; Ryan places it (The Chorus, presumably).
- **Cleanse** (implemented): No component carries it yet; Ryan places it.
- **Overshield** (implemented): Decided 5 October (Ryan: overshield as a component keyword, a rare one). The Puffin's fixed Backwash Ionizer carries it, allies only, so the excess never lands on the Puffin itself. Rare because every overshield on the field makes shield max a soft number. The fade is the whole safeguard: a persisting excess would stack a team past every blow. The gauge shows the excess as a hatched block beyond the bar's end.
- **Retaliate** (implemented): Was flat damage equal to the component's power. Thorns scales with enemy blows and so inverts horde against boss; a debuff does not (Ryan, 28 September). The Armadillo's passive carries it always on.
- **Shocked** (implemented): The Armadillo's retaliation (Ryan, 28 September): the tank sets up kills instead of out-damaging area weapons against a horde, and it works on a boss. The discharge on a second strike is the small thorns left in. Numbers are placeholders.
- **Overcharged** (implemented): The buff side and devour run (29 September); a buff's stacks and devour's are the same status to the machine and add up. The Ammit's Quintessence Tap (which stops the decay and keeps the stacks for the battle, never the campaign) is planned. Name is a placeholder.
- **Braced** (implemented): Placeholder name and number (29 September). Flat since 2 October; it was 15% less damage a stack.
- **Primed** (implemented): Placeholder name (29 September).
- **Corrupted** (implemented): The bite is a placeholder number (Skirmish.CORRUPT_BITE_PER_STACK).
- **Cracked component** (implemented): Threshold is a placeholder. Repair cost and the hangar screen are not built.
- **Reinforcements** (implemented): Elites should surface at set points rather than in pool order.
- **Massive** (implemented): Cleave treats it as a front-rank neighbour; pierce cannot hit anything behind it because nothing is.
- **Movespeed** (implemented): Built 2 October (bible section 4). Every chassis's move is a placeholder Ryan sets by size and role; the content check flags a chassis at least as fast as another on every ground, never refuses it.
- **Contact** (implemented): No participant cap. May need one for phone readability. Decided 1 October: zones on the packs, measured from where each stops; nothing chains.
- **Engagement zone** (implemented): Decided 1 October after the touching rule (22 September) and the engagement range (28 September). Radii are content on the foe type: front-rank 1, back-rank 3, bosses 2, placeholders. Dropped on the way: chaining in any form, a touch rule between packs, double-booking a machine into two fights, the zone as the stop.
- **Behaviour** (implemented): Decided 1 October: the enemy commits first, so no pack re-aims at the plan without a drawn trigger. Placeholders: the ghoul aggressive, the brute hunts the strongest at move 3; a dedicated hunter is a foe to name.
- **Pack** (implemented): The rift should seed and spawn formations, not single packs (Ryan, 1 October): to design.
- **Footprint** (implemented): Footprints do not rotate with facing.
- **Structure** (implemented): The rift does nothing yet beyond marking where packs spawn.
- **Spawn** (implemented): A full spawn list should arrive together as a formation; pressure currently sends one pack at a time.
- **Ruins** (implemented): Designed as cover for the pack inside a skirmish. Skirmish terrain conditions are not coded.
- **Water** (implemented): Designed to dampen burn inside a skirmish. Not coded. The generator gives one real water feature a map with crossings for the horde, with the hovercraft (bible section 4).
- **Tracked** (implemented): Was tank until 2 October (Ryan). Built 2 October.
- **Wheeled** (implemented): The cars (Ryan, 2 October: the Prairie Dog and the Dingo). Built 2 October.
- **Stealth** (implemented): The Dingo (Ryan, 28 September): a support car that waits in the wings while the heavies get into position, then joins their fight, and never fights alone unless run into. Pays again when hunter packs exist.
- **City defense** (implemented): Defenses have no die. They cannot act inside a skirmish yet.
- **On shield gain** (implemented): Built 30 September (Effects.fire); no content uses it yet.
- **On shielding an ally** (implemented): Built 5 October for the Puffin's Slipstream (an ally it shields sheds 10 heat). Fires on the spend, whatever the shield gained, so a shield die on a topped-up ally still does its other work.
- **On heat gain** (implemented): Built 30 September (Effects.fire); no content uses it yet.
- **On round start** (implemented): Built 30 September for the Thermal Recoupler; the heat it reads is the gauge after the turn's passive cooling.
- **On skirmish start** (implemented): Built 30 September (Effects.fire); no content uses it yet.
- **On foe status** (implemented): One machine's passive so far (the Baboon's Pocket Paradox).
- **On applying stacks** (implemented): One machine's passive so far (the Stingray's Exothermic Suite). Shocked and Suppressed are not stacks, so it never touches them.
- **On hull damage** (implemented): Built 30 September for the Crucible Capacitor (stack_status). Still the hook for the pinned berserker idea.
- **Out of combat** (implemented): Built 30 September (Effects.fire in Battle.commit); heat does not persist between fights, so a vent here would be nothing. No content uses it yet.
- **Command die** (planned): Open question: whether the command die exists at all, or one-shots only.
- **City ability** (planned): Consider range limits from the gate so the push north leaves support behind.
- **Component** (implemented): Multi-slot components were considered and scrapped on 18 September as invisible complexity.
- **Fixed component** (implemented): Decided against unlocking fixed slots for money (18 September).
- **Armour** (implemented): Numbers are placeholders. Armour from components is content, not yet written.
- **Aim** (implemented): Decided 2 October (bible, section 5). Content: `aim` on a foe type and on a move; `when` on a move is the condition that lets a foe pick it, and a special never fires twice running.
- **Breach** (implemented): A property of a foe's attack action. No foe carries it yet; Ryan places it. Redirect and interrupt do not exist yet. Name is a placeholder (pierce is taken by the player keyword).
- **Foe action** (implemented): Only attacks run; defend, buff and debuff actions stay planned. Weighted RNG is the whole brain for now.
- **Vents all** (implemented): Built 30 September for the Afterburner Cannon (vents_all and power_per_heat on the face). Only the first shot of a chain fires the heat.
- **Strikes** (implemented): Heat is paid once per use, not per strike. Foes have no armour yet, so on the player side strikes only matter for procs until they do.
- **Static** (implemented): Every read asks the pipeline; nothing is written to a stat or a component, so an effect that is gone stops answering. A static reach rule cannot be conditioned on reach.
- **Order of operations** (implemented): Refit (the hangar) is what changes loadout-scoped effects; not built.
- **Overheating** (implemented): Placeholder name and numbers, engine id overheating; Ryan is looking for the flavour.
- **Scorch** (implemented): Placeholder name. No foe carries it yet; Ryan places it (fire demons, presumably).
