# Riftgate vocabulary

Generated from `content/vocabulary.json` by `tools/export_vocabulary.gd`. Do not edit by hand; edit the JSON and re-run the tool.

Status: 151 implemented, 6 planned, 0 idea.

## Resource

| Term | Codex | Status |
|---|---|---|
| **Hull** | Damage that gets past shield removes hull. Hull never recovers during a battle. At zero the machine is a wreck to be salvaged after the battle. | implemented |
| **HP** | A foe's health. What gets past its armour takes HP off, and at zero the foe falls. A machine's health is its hull. | implemented |
| **Shield** | Enemy damage hits shield before hull. A shield absorbs its number: a blow costs it its damage, and whatever it cannot absorb passes to the hull, armour coming off it there; a breaching blow ignores the shield, which stands, and the armour, so the whole blow reaches the hull. Shield components add shield up to the chassis maximum (a component with Overshield may pass it, and the excess fades at the end of the round); in a fight shield comes back only from components, modules and passives. Out of combat it returns each battlefield phase at the chassis's field rate. It never refills for free between skirmishes. | implemented |
| **Heat** | A component that prints heat adds it when spent. At the end of your turn, before the enemy acts, heat above the chassis maximum burns hull one for one and the gauge settles at the maximum; until then a vent can still bring it down, and a machine the burn wrecks is lost on its own turn. Vent components remove heat. At the start of every round a machine sheds its chassis's cooling rating in heat, so a round spent on shields or cool weapons is a way of cooling down without a vent. Foes never add heat outright: a Burning machine gains its heat at the end of your turn, just before the overheat, and a Scorched machine's weapons and equipment aimed at foes run hotter. | implemented |
| **Reroll** | Three rerolls per round, each rerolling every unlocked, unspent die. A reroll lands on any other component on the die, never the one showing; a second copy of the same component may come up. Rerolls may be spent before or after attacking, so a low damage roll is information for the rest of the round. Never pooled across rounds. | implemented |
| **Rift Pressure** | Ticks once per battlefield phase, never inside a fight. When full it resets and a fresh pack emerges at the rift. | implemented |
| **Gate Integrity** | A pack whose path reaches the gate strikes it instead of moving. Gate integrity persists across battles and is repaired in the meta. | implemented |
| **Shots** | Machine count, the Cassowary's: every weapon and equipment it aims at a foe this fight, shown as six pips under the heat bar, the sixth lit when it is next, where its sixth shot counts double. Shields, vents, buffs and spins are no shots. Never a chip; nothing cleanses it; it resets each fight. | implemented |
| **Armour** | A chassis number taken off every blow that reaches the hull, flat, never a percentage: a blow on bare hull and what passes a shield alike, never a breach, which ignores it. A blow at or under the armour does nothing to the hull. Shield is not armoured: a blow on shield costs the shield its full damage. | implemented |
| **Rage** | Machine store, the Nemesis's: a rage for every time it takes hull damage (a blow, a bite of its own, an overheat), up to 5, kept for the skirmish. Its fists spend one when they strike, and the die rolls again. Never decays; no cleanse, Silence or Purge touches it. | implemented |
| **Hopper** | Machine store, the Honey Badger's: loads its Chainsaw Claw digs out of whatever it hits, which its Bullion Fragmenter fires a few a shot. Lasts the skirmish; never decays, and no cleanse, Silence or Purge touches it. | implemented |
| **Muster** | Machine store, the Swallowtail's: a charge its locked pieces spend for their charged forms. Every die that rolls fills it a sliver, about thirty rolls a charge, and a kill by its own guns five rolls' worth; stored up to its cap. Starts each fight empty and never decays; a store, so no Silence or Purge touches it. With a charge up, its locked pieces go out charged unasked, unless the charged form has nowhere to land; then the plain form goes out and the charge waits. | implemented |
| **Ammo** | The Musk Ox's magazine, a bar under its heat bar, a notch an ammo. Its weapons spend ammo instead of heating it: 1 for every 2 heat a gun would make, rounded up, at least 1, the price printed where the gun's heat would be; a foe's Scorched still heats them. The magazine holds 10, opens each fight at 3 and gains 1 at the start of every round after the first; a vent the Musk Ox spends on itself adds 3, a shield 2. With too little left, a gun cannot be spent (DRY). | implemented |

## Kit

| Term | Codex | Status |
|---|---|---|
| **Component** | A piece of kit on a machine, and one entry on its die. There is no generic kit: every entry on a die is a component, or an empty hardpoint. Each round the die is rolled and the component that comes up is what the machine can do. | implemented |
| **Hardpoint** | A free slot on the chassis. Any component fits any hardpoint. On the model a hardpoint is a socket where the component mounts. | implemented |
| **Fixed component** | A component built into the chassis: always on the die, never removed, never sold, and it uses no hardpoint. It is the machine's own: no other machine carries one, and it can never be built. | implemented |
| **Empty hardpoint** | A hardpoint with nothing in it is an entry on the die that does nothing when it comes up. Nothing fills it for you. | implemented |
| **Module** | Kit inside the machine, not on its die: a few numbers up or down, and at most one rule of its own. A chassis has its module slots (two, three on the Clydesdale), and a module is never spent: it is always working. | implemented |

## Component Kind

| Term | Codex | Status |
|---|---|---|
| **Weapon** | A component that deals damage: spent on a foe within its reach, it deals its number in damage, then its keywords act and its heat lands. One that deals none is equipment. A passive may make another kind a weapon on its machine too (the Whip Scorpion's vents): its hold reads both, Vent, Weapon. | implemented |
| **Shield component** | Spend on self or an ally to add its power in shield, capped at that machine's shield maximum. | implemented |
| **Vent component** | Spend on self or an ally to remove its power in heat. | implemented |
| **Equipment** | A buff or a debuff: a component that deals no damage. A buff is spent on a machine (itself, an ally, or either, as it says) and grants it a status; a debuff is spent on a foe within its reach, its keywords its whole effect. Shields and vents are kinds of their own. | implemented |
| **Buff component** | Equipment spent on a machine (itself, an ally, or either, as the component says) that grants it a status, so many stacks deep, through the end of so many rounds: Overcharged for damage, Armoured against damage, Primed to burn on hit. A status that runs down on its own (Overcharged, halving) takes no rounds. The die shows the status name and the stacks. | implemented |

## Component Property

| Term | Codex | Status |
|---|---|---|
| **Damage range** | A rolled weapon shows a minimum and a maximum and rolls between them when spent, immediately and visibly. A flat weapon shows one number and never rolls. | implemented |
| **Volatile** | A cost printed on any kind of component, beside its heat. Volatile 3 means spending it costs its owner 3 hull, past shield and armour, before the component acts, and a machine it leaves at nothing is wrecked. A blank is never spent, so a disabled entry costs nothing. | implemented |
| **Shield cost** | A cost printed on any kind of component, beside its heat: spending it takes that much shield from its owner first, overshield included. Short of it, the entry cannot be played: the die shows the cost struck through, and it has nowhere to land. | implemented |
| **Overcharged a kill** | A rule printed on a weapon (the Soulcutter Talons', locked on the Ammit), with no word of its own: every foe it kills gives its owner so many stacks of Overcharged (two), which the Ammit keeps for the battle. | implemented |
| **Targets** | Whom a shield, a vent or a buff may be spent on: self and allies, self only, or allies only. Shown as a chip on the die when narrowed. | implemented |
| **Cooldown** | A rule printed on a component: once spent, its entry goes dark for that many rounds, this one included, and the die shows it dark with the turns left; the die can still land on it, and nothing in it acts. Rapid carries a cooldown of one unless the component prints its own, and "no cooldown" lifts even that. No cleanse lifts a cooldown. | implemented |
| **Reset** | A rule printed on a weapon: if its spend kills, every entry dark from a cooldown comes back, itself included, and its machine acts again, the free roll never landing on the entry just spent; a team reroll may bring it back up, and every kill resets it again (the Kite's Pinion Driver). | implemented |
| **Pull** | A rule printed on a component (the Lammergeier's Lorentz Contractor, a debuff): every mine on the field gathers into the slot it is spent on, in laid order, and a foe standing there takes them now. Spent on an empty slot, it gathers them there. | implemented |
| **Drone** | A rule printed on a component (the Lammergeier's Syrinx Drone, a debuff): the foe carries the Syrinx Drone. If it already carries Exposed, the spend is Rapid; otherwise it gives the foe Exposed, never refreshing it. | implemented |
| **Spray** | A rule printed on a weapon (the Skua's Flechette Pod): its first strike lands on the foe it is spent on, and each strike after it falls on a random foe in reach at that moment, the same foe again allowed. A kill clears its slot at once, so a hole burnt in the front rank opens the foe behind it to the strikes still to come. | implemented |
| **Vents all** | An attack that fires the machine's whole heat as it is spent: the heat gauge is empty after the shot, and every step of heat fired, the step printed on the entry, adds the component's bonus to the blow before the passives. The shot's own heat cost still lands. | implemented |
| **Grows with missing HP** | A flat blow that grows with its target's lost HP: it adds its bonus for every step of HP the target is missing, both numbers printed on the entry, read as the die is spent. No roll is involved, so the number is known before the spend, and the die shows it while held over a target. | implemented |
| **Gated** | A keyword printed with a condition, such as a Suppress on a foe carrying Flak or on a foe carrying two Burning or more: it lands only on a foe that meets the condition, read as the die is spent and before the blow's own riders, so a spend never opens its own gate. Held over a foe where the condition does not hold, the die shows the keyword's chip struck through. | implemented |
| **Consumes** | A rule printed on a weapon: its blow consumes every stack of the status it names on its target and deals a point more for each stack consumed, before the multiplies. The die held over the foe shows the number with the stacks in. | implemented |
| **Burns its firer** | A rule printed on a weapon: spending it sets its own machine Burning, the stacks it says, after the blow. The machine's Burning heats it at the end of the player's turn, before the overheat, then loses a stack, so a vent makes room for it and a cleanse takes it off. Fuel for a machine that wants heat, a price for one that does not. | implemented |
| **The hopper** | Two weapons that work together. One fills its machine's hopper, a load for each foe its blows reach, after the blow. The other fires the hopper: each load it takes adds its bonus to the blow, up to its most a shot, and the loads it takes are spent. The hopper lasts the skirmish and shows on the machine; the die shows what a shot would fire. | implemented |
| **Braces** | A rule printed on a component (the Breaching Plow's). Spending it Armours its owner, the stacks it says (an armour point each), until the round's end: the armour stands behind the blow through the enemy's turn. | implemented |
| **Rolls again** | A rule printed on a component (the Nemesis's Knuckle of Fury). Spending it with a stack of the status it names spends one, and the die rolls again, a plain roll as the round opens, so the machine acts again and the same component may show again. Unlike Rapid nothing switches off: the stacks are the limit. | implemented |
| **Strikes** | An attack's blows per use. A weapon with three strikes lands three separate hits: each rolls its own damage and carries its own effects, so a rapid-fire weapon procs often (the Skua's strikes share each roll, halved). Against a shield, each strike is its own blow, so once one breaks the shield the next reaches the hull; against armour, every small strike loses the armour, so many small hits are the wrong tool for a heavy target and the right one for a soft one. Foe attacks have strikes too. | implemented |

## Reach

| Term | Codex | Status |
|---|---|---|
| **Direct** | Targets any front-rank foe, and any back-rank foe whose column is exposed. | implemented |
| **Indirect** | Targets any foe in either rank, at no cost to its firer. | implemented |

## Keyword

| Term | Codex | Status |
|---|---|---|
| **Spread** | Player keyword. Also hits the foes in the neighbouring columns of the target's rank, for half the blow. | implemented |
| **Penetrate** | Player keyword. Also hits the other rank of the target's column, for half the blow. | implemented |
| **Spillover** | The Wild Boar's rule, granted to every weapon it fires by its Juggernaut Drive and run by the engine as a keyword: when a blow kills a front-rank foe, what it had past the kill carries into the foe behind it in the same column. Nothing stands behind a massive foe. No component carries it; it becomes a keyword the player learns on its own if a second source ever grants it. | implemented |
| **Cryo** | Keyword with a number. Every foe the entry reaches gains that many stacks of Cryo (Cryo 1: one stack). Any machine's hit with a weapon on a foe carrying Cryo spends every stack and cools the hitter 2 a stack. | implemented |
| **Burn** | Keyword with a number. On a player's weapon or equipment, Burn 3 means each foe hit gains three stacks of Burning. On a foe's attack the same: each blow that lands leaves that many stacks of Burning on the machine it hit. | implemented |
| **Lure** | Player keyword, on any entry aimed at a foe, a weapon or equipment. Every foe the entry reaches turns on this machine for the round, intents and all; reach and area decide who and how many. A lured foe whose move has no target keeps doing it. | implemented |
| **Shock** | Player keyword, on any entry aimed at a foe. Every foe the entry reaches and leaves standing is Shocked: the next blow it takes deals double. The entry's own blow never spends the shock it leaves. | implemented |
| **Expose** | Player keyword, on any entry aimed at a foe. Every foe the entry reaches and leaves standing is Exposed through the next round: in Direct reach of every machine, and its armour counts for nothing. A second Expose refreshes it, never adds. | implemented |
| **Disrupt** | Player keyword, on any entry aimed at a foe. The foe does its other move instead, this round, and its new intent shows at once. A foe with nothing else open is not moved. | implemented |
| **Suppress** | Player keyword. The target skips its telegraphed action this round, then gains two stacks of Numbed (three if massive). A foe may shrug it off at 10% a Numbed stack; no foe resists by nature. | implemented |
| **Web** | The funnel-web's Web Bomb, locked: the foe hit is Webbed, no damage. After its action the web bursts, Suppressing it and the next foe to act beside it. | implemented |
| **Swap** | Player keyword, the Dingo's Combat Translocator's: the spend takes two targets, a foe and then another foe or an empty slot, and the two trade places; no damage. A massive foe does not move. Drag the die to the first, drop it, then tap the second; drag it again to move it or set it back. | implemented |
| **Flak** | Flak N: each foe hit gains N stacks of Flak. | implemented |
| **Chain** | If this attack kills an enemy, repeat it on a new, valid target. | implemented |
| **Rapid** | After this component is spent the machine acts again: the die rerolls for free onto any other component (a second copy of this one included, so copies chain). Rapid carries a cooldown of one, so the component is dark for the rest of this round, unless it prints its own cooldown; one that prints none pays heat or hull every spend instead. Any component may carry it, a vent or a shield as well as a weapon. | implemented |
| **Disable** | Enemy keyword. The component the target's die is showing is switched off through the target's next turn: if the die lands on it, it comes up blank. | implemented |
| **Corrupt** | Foe attack keyword with a number. Each blow that lands leaves that many stacks of Corrupted on the component the target's die is showing (Corrupt 2: two): it deals damage to its owner whenever spent, a bite a stack. | implemented |
| **Cleanse** | Player keyword, on shield and vent components. Whoever the component is spent on also loses every Burning, Scorched, Silenced, Disabled and Corrupted status. A rapid component's own switch-off is not a status a cleanse touches. | implemented |
| **Overshield** | Player keyword, on shield components, rare. The shield may raise its target past the target's maximum; shield past the maximum fades at the end of the round, or as the fight ends. A shield die spent on a machine already at its maximum is never wasted when it carries this. | implemented |
| **Breach** | A breaching blow ignores the shield and the armour: the shield stands, the armour counts for nothing, and the whole blow lands. On a foe's move it reaches a machine's hull, and if what gets through is a quarter of its maximum hull or more it destroys a component; a Ward turns it away, and the shield and armour then take the blow like any other. On a weapon it ignores a foe's armour. | implemented |

## Status

| Term | Codex | Status |
|---|---|---|
| **Numbed** | Foe buff that nothing removes: nothing reads it, deepens it, spreads it, cleanses it or purges it, and nothing that counts a foe's statuses counts it. Each stack is 10% resistance to a suppress, the only resistance a foe has; a suppress it shrugs off does nothing and adds no stack. Loses a stack at the start of each of its turns, so a stun repeated on one foe stops landing while stuns spread across the formation keep working. Its chip wears brackets, the mark of what nothing removes. | implemented |
| **Paradox** | Foe status. While a machine runs the Paradox meter (the Baboon's Pocket Paradox), a foe gains a stack each time it gains any other status: one a spend, however many strikes or stacks. At the machine's count (three) its past self knocks it out: it is Suppressed and the Paradox clears. A foe already suppressed loses its next action instead. Never decays. A status like any other: it counts for what reads a status, and a machine that deepens the statuses it applies deepens it. | implemented |
| **Retaliate** | Machine status. While it lasts, a foe that strikes this machine's bare hull is Shocked. It lasts the rounds the component that grants it says. | implemented |
| **Shocked** | Foe status. The next blow of a weapon this foe takes deals double damage, then the status clears; equipment (a lure, a probe) leaves it standing. Never stacks. Laid by the Shock keyword, and on a foe that strikes the bare hull of a machine carrying Retaliate. | implemented |
| **Exposed** | Foe status. In Direct reach of every machine as if its column's front were empty, and its armour counts for nothing, its own and any Armoured. Through the next round; refreshed, never added. | implemented |
| **Syrinx Drone** | Foe status, the Lammergeier's: the next weapon to kill it, any machine's, leaves its shot in the slot it empties, a mine. One mine a drone; it lasts the fight, and a death by a tick leaves nothing. | implemented |
| **Overcharged** | Machine status. Each stack is +1 damage on this machine's attacks, flat, so the count is the bonus. At the end of each round it halves, rounded down, whatever granted it, until it is gone. On the Ammit nothing of it fades: its Quintessence Tap keeps every stack for the battle. | implemented |
| **Sealed** | Machine status, the Armadillo's form. A shield it spends on itself seals it: armour up by its Lockdown's number, its own cooling stopped, and it runs hotter at the end of each turn. A vent or a weapon opens it; a shield on an ally and equipment leave it as it is. An ally's vent still cools it. | implemented |
| **Cryo** | Foe status, the mark the Cryo keyword leaves. Any machine's hit on it with a weapon spends every stack and cools the hitter 2 a stack; equipment spends none. It never fades on its own. | implemented |
| **Armoured** | Status, on either side. Armour +1 a stack: that much off every blow that reaches it, flat, every stack at once, whatever granted it, so the count is the armour. On a machine (a buff, an armouring component, a passive) it lasts until the round's end and comes off blows on bare hull; on a foe, from its brace, it lasts until its next action. | implemented |
| **Primed** | Machine status. Every blow this machine lands leaves a stack of Burning per stack of Primed. Granted by a buff for the rounds it says. | implemented |
| **Disabled** | Component status. This die entry comes up blank while it lasts; the component itself is untouched. A foe's disable lasts through the machine's next turn and can be cleansed; a rapid component's own switch-off ends with the round. | implemented |
| **Corrupted** | Component status. Every time this die entry is spent it bites its owner for 3 per stack, shield first, before the component acts. A blank is never spent, so a disabled entry does not bite. Stacks. Clears at end of skirmish. Can be cleansed. | implemented |
| **Phased** | Machine status. It cannot act, take damage or be targeted until the round's end: a blow or a move at every machine passes it by. Granted only to a machine that has not acted this round. | implemented |
| **Burning** | Status. On a foe: loses 1 HP per stack at the start of its action, then loses one stack; bypasses armour. On a machine: gains 1 heat per stack at the end of the player's turn, before the overheat, then loses one stack, so a vent makes room for it or a cleanse takes it off. Metal does not burn, it heats. | implemented |
| **Suppressed** | Foe status. Skips its action this round, then clears. | implemented |
| **Vitriol** | Foe status, the funnel-web's acid. At its action it loses 10% of its current HP a stack, past armour, after Burning, rounded down, then a stack fades. A share of what is left: it opens on a boss and never finishes a foe. | implemented |
| **Webbed** | Foe status, the funnel-web's web. At the end of its action the web bursts: it and the next foe to act beside it are Suppressed, Numbed resisting each for itself. Killed first, it takes its web with it; one the team has already suppressed gains nothing from the burst on itself. | implemented |
| **Spun Up** | Machine status, the Cassowary's. The next weapon it spends deals 2 more a stack and takes every stack; equipment leaves them standing. Carried between turns until then. | implemented |
| **Hot Streak** | Machine status, the Kite's: its shots run 1 hotter a stack this fight, a stack for each attack that killed. Its passive's price: no cleanse, silence or purge lifts it. | implemented |
| **Quick turn spent** | Machine marker, the Needletail's gate: its free setup this round is spent, so its next debuff or buff this round is a full action. Never a chip: the die shows the gate open by the Rapid it grants a setup. Gone at the round's end. | implemented |
| **Siphoning** | Machine status, the Whip Scorpion's Siphon: every blow a foe lands on it this round adds heat, 2 a blow, whatever the blow dealt. The blows land in the enemy's turn, after the overheat, so it is next round's fuel for its vents, or next turn's burn. Until the round's end; nothing cleanses it. | implemented |
| **Flak** | Foe status, Wainwright & Sutler's on-hit. Every blow of a weapon it takes deals a point more a stack. At the end of each round the stacks halve, rounded down. | implemented |
| **Destroyed component** | Machine status, global rule. When what one blow puts on the hull, past shield and armour, is at least a quarter of its maximum hull, the machine's die is rolled and the component it lands on is destroyed: blank, it does nothing when it comes up, and provides its passive bonuses but not passive abilities, for the rest of the battle; after it, a hardpoint's is gone for good and a built-in one is rebuilt. A shield prevents it only by absorbing enough of the blow, and a blow a Barrier takes never injures. An injury that lands on a destroyed component or an empty hardpoint finds nothing to break, so a badly broken machine shrugs off more of them. | implemented |
| **Scorched** | Machine status, from a foe's scorch: every weapon and equipment it aims at a foe runs 1 hotter per stack, until the end of the player's turn, when every stack goes. Spending a shield, a vent, a buff or a cool weapon plays round it. Can be cleansed. | implemented |
| **Kindled** | Foe status, from a rally, landing on every other foe on the field the moment the rally does. Its next move hits harder by the rally's value, and that move spends it, whatever it is: a blow lands it, a special gains nothing from it, a Suppress that takes the move takes it too, and a countdown carries it to the blow it lands. A foe acting after the rallier spends it this turn; one that has acted carries it to its next move. An intent counts the rallies on their way, a pulsing chip on a dashed edge saying why, and drops them the moment the rallier is killed, Suppressed or Disrupted. | implemented |
| **Getting Back Up** | Foe status, from a Reraise, its own or an ally's. After it falls it gets back up once, whole, in its own slot and at once, unless it self-destructed; it strikes from the next round. | implemented |
| **Silenced** | Machine status, from a foe's silence: its buffs count for nothing through its next round, then wake. Its components' keywords act as ever (a Volatile still bites) and its stores fill and spend as ever. Can be cleansed; a Ward turns the silence away. | implemented |
| **Guarded** | Foe status, a core's. It takes no damage while its parts stand: all of them, or any, by the foe. | implemented |
| **Barrier** | Machine status. The next blow a foe lands on this machine deals no damage, so it never injures; its riders land. Until the round's end. Never granted to every ally at once. | implemented |
| **Ward** | Machine status. No rider a foe lays lands on this machine this round, from a blow or from a move of its own (breach, burn, scorch, disable, corrupt, silence, purge); a blow's damage lands. Until the round's end. | implemented |
| **Rallied** | Machine status, the Swallowtail's Reveille Horn: its team has one reroll more this round. | implemented |
| **Regenerating** | Machine status, the Storm Petrel's. It regains 2 shield at the start of each round for three rounds. Each grant keeps its own clock, so two grants regain 4 a round until the first runs out. | planned |

## Formation

| Term | Codex | Status |
|---|---|---|
| **Front rank** | Four slots, one a column. Front-rank foes fill these. Always in Direct reach. | implemented |
| **Back rank** | Four slots behind the front. Back-rank foes hold these. | implemented |
| **Exposed** | A back-rank foe is exposed when the front slot in its column is empty. Exposed foes are in Direct reach. | implemented |
| **Mine** | A shot waiting in an empty slot of the enemy's formation: laid there by a machine whose weapons and equipment aimed at foes may also be spent on an empty slot (the Lammergeier's Fuse-delayed Bay), as if a foe stood there, or left by a kill on a foe carrying the Syrinx Drone. Its number is fixed when laid and its keywords ride in it; the shots in one slot stack. Whoever steps into the slot takes every shot waiting, in laid order, before it acts (a massive foe both slots'), through its own armour and statuses; every keyword acts as on a blow, and Lure and Disrupt do nothing, their round being over. Any way in sets it off, and nothing expires. | implemented |
| **Reinforcements** | Foes not yet on the field. Front and Back ranks have their own reinforcement pool. Empty slots refill from the pool of reinforcements after each round. The skirmish is won when the field and all reinforcements are defeated. | implemented |
| **Massive** | A massive foe fills both slots of a column and counts as front rank. Its column is never exposed while it stands. Only some elites and bosses are massive. | implemented |
| **Withdraw** | Available at any point of the player's turn, the first round included. The price is always the same: your turn ends (heat over the maximum burns), the enemy takes its full turn, then the skirmish ends, so nobody leapfrogs out of contact unscathed. Machines keep their damage; a pack keeps its survivors, who return whole. Shields do not refill on withdrawing; they recharge at the field rate only in phases spent out of combat. | implemented |
| **Strike order** | Foes strike in the order they stand: front rank left to right, then the back rank. Each blow is resolved on its own against the shield standing at that moment, so which foe strikes first decides what a small shield blocks. At first contact the heaviest hitters deploy left. | implemented |

## Battlefield

| Term | Codex | Status |
|---|---|---|
| **Movespeed** | Move in tens: how far a machine goes in an action. A normal hex costs 10, so MOVE 40 is four hexes on open ground. Each way of moving calls each ground fast (5), normal (10) or slow: a slow hex can always be entered with any move left, and the step ends the move. Move left at the end of a phase is lost. | implemented |
| **Walk** | The map shows where every pack will walk on the enemy's turn, worked out from where your machines stand now: a pusher toward the gate, a hunter toward its prey. Packs go round your machines; nothing you do stops one, and nothing a pack does reacts to your plan. | implemented |
| **Fight** | Tap a pack to attack it. The fight is at that pack's hex: every pack whose ring covers it joins, and you commit the machines whose attack range covers it. One fight at a time, each resolved before the next; a machine that fought, won, lost or withdrew, is spent until your next turn. | implemented |
| **Spent** | A machine that has fought this turn is spent: it cannot move or fight again until your next turn. A machine whose passive grants a second action has two before it is spent. | implemented |
| **Carry** | A machine that carries (the Swallowtail's Muster Deck) lifts the machines on the hexes beside it when it moves: they travel as a ring round it and land as a block, each where it rode from it, keeping whatever move and action they had. It cannot stop where a rider would land on a hex it cannot stand on (NO ROOM). A caught machine does not ride. | implemented |
| **Caught** | A machine a hunter has caught fights it first on your turn, before any other fight, and cannot move until then. Others in range may join that fight. Withdrawing ends it, and the hunter catches the machine again while it lives. | implemented |
| **Ring** | Every unit has a ring. A pack's ring is who it supports: a pack whose ring covers the pack you attack joins the fight. A hunter's ring is how close it must be to catch its prey. A machine's ring is its attack range, two hexes: it can join a fight whose target is that close. | implemented |
| **Behaviour** | A pusher walks toward the gate and threatens nothing else. A hunter locks one machine, by its caveat (the nearest, weakest, strongest or slowest), wears the target rings on it and walks toward it; when it ends its walk with its prey inside its ring it has caught it, and that fight comes first on your next turn. A caught machine cannot move until the fight, and is caught again while the hunter lives. | implemented |
| **Pack** | An enemy hex is a pack: one foe type times a strength. A fight is the pack you attack and every pack whose ring covers it, so the rift's formations and the order you attack them in decide what you fight. A boss is one unit on one hex. | implemented |
| **Footprint** | Every unit covers one hex, the boss included: it is occupied, counts for rings and range, and is a tap target. The gate and the rift are wider structures. | implemented |
| **Structure** | Gate and rift hexes are structures wider than one hex. Nobody stands on them. A pack that ends its walk beside a gate hex strikes the gate. | implemented |
| **Spawn** | When Rift Pressure fills, the next pack of the spawn cycle (the lead domain's packs alternating with the guest's) appears on the nearest free hex to the rift. | implemented |

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
| **Flyer** | Normal pace over every ground, mountains included. Packs walk under it but never stop on its hex. | implemented |
| **Hover** | Skims water fast. Rough ground and ruins are slow: it can enter them, and the step ends its move. | implemented |
| **Walker** | Legs. Rough ground and ruins at normal pace; water is slow: it can enter it, and the step ends its move. | implemented |
| **Tracked** | Tracks. Ploughs through forest and fords water at normal pace; rubble is slow: it can enter ruins, and the step ends its move. | implemented |
| **Wheeled** | Wheels. Fast on open ground. Rough ground, ruins and water are slow: it can enter them, and the step ends its move. | implemented |
| **City defense** | A static player-side unit. Not on the field yet. | planned |

## Trigger

| Term | Codex | Status |
|---|---|---|
| **On attack** | Passive trigger. Fires after the damage roll on every attack. Effects: multiply or add damage or heat, multiply the printed number alone before any buff (the Kite's double), or set a minimum damage. | implemented |
| **On shield gain** | Passive trigger. Fires when this machine gains shield from any source, with the amount gained; it may shed heat or grant a status, never raise more shield. | implemented |
| **On shielding an ally** | Passive trigger. Fires when this machine spends a shield component on an ally, with the shield's size; it may shed the ally's heat or grant the ally a status, never raise more shield. It never fires for a shield on itself. | implemented |
| **On heat gain** | Passive trigger. Fires when this machine gains heat, with the amount; it may raise shield or grant a status, never add heat. | implemented |
| **On round start** | Passive trigger. Fires after the roll, before rerolls: shield from heat, a flat shield, a vent. | implemented |
| **On skirmish start** | Passive trigger. Fires once as the skirmish begins, before the first roll: a shield, a vent, a status. | implemented |
| **On foe status** | Passive trigger. Fires when any foe gains a status, whoever applied it: once for each status a spend puts on a foe, however many strikes or stacks (an application, not a stack). Never for Paradox, nor for the Suppressed a Paradox causes, and Numbed is no status. Effects: paradox (the foe gains a stack of Paradox; at the count it is Suppressed and the Paradox clears). | implemented |
| **On applying stacks** | Passive trigger. Fires when this machine applies stacks of a status to anyone: a foe's Burning (from a burn or from Primed), an ally's or its own buff, its own Overcharged from a kill. Effects: add_stacks (so many stacks more, flat or for every so much heat the machine carries). Never for Numbed, which is exempt from every interaction. | implemented |
| **On hull damage** | Passive trigger. Fires when this machine loses hull: to a blow, a bite or an overheat. | implemented |
| **On a kill** | Passive trigger. Fires once after an attack of this machine's that killed, however many foes fell to it, chains, spills and a vent's blast included: a status (the Kite's Hot Streak), a shield or a vent. | implemented |
| **Out of combat** | Passive trigger. Fires at the end of a battlefield phase in which this machine had no skirmish, after the field recharge: more shield. | implemented |
| **On injury** | Passive trigger. Fires when an injury lands on a component. Effects: no_destroy (the component holds instead of being destroyed). | implemented |
| **Static** | Passive trigger. Always on. Its effects change a machine's numbers or a component's properties while a condition holds, rather than firing on an event: add_stat and multiply_stat on hull, shield, heat, armour, move or recharge; add_damage_taken and multiply_damage_taken on every incoming blow; weapon_cooldown (every weapon the machine fires goes dark for so many rounds: the Kite's); set_reach on a component (direct or indirect while a condition holds); suppress, which turns off another effect by id or tag. | implemented |

## Commander

| Term | Codex | Status |
|---|---|---|
| **Command die** | One die rolled alongside the machines' dice each round. Its entries are rechargeable commander abilities and never deal damage. They come from the hangar, never from rewards. Die size is a research path. | planned |
| **One-shot** | Consumable ability. A pouch of three: a fourth forces a use or a discard. One comes from a Fracture's pick, and a starting stock chosen in the hangar restocks every battle. It expires when the rift closes. | planned |
| **Reward pick** | Each Fracture of the Rupture meter grants one, unweighted by domain: one of three, a battle-long modifier on a component you carry, a one-shot, or a battle-wide boon (an extra reroll a round). | planned |

## City

| Term | Codex | Status |
|---|---|---|
| **City ability** | Battlefield-level ability owned and upgraded by the city: sprint, airlift, teleport, tractor beam, orbital strike. Cooldowns measured in phases. | planned |

## Foe

| Term | Codex | Status |
|---|---|---|
| **Silence** | Foe keyword, on a blow or as a move of its own. The machine it lands on is Silenced: its buffs count for nothing through its next round. A Ward turns it away. | implemented |
| **Purge** | Foe keyword, a hero's or a boss's, on a blow or as a move of its own. The machine it lands on loses every buff it carries (a kept Overcharged too), every stack; its stores and its passives stay. A Ward turns it away. | implemented |
| **Aim** | Whom a foe strikes, picked for every foe on its own as the round opens and shown as its arrow before you act: at random, unless the foe carries an aim. The foes never pile onto a machine their blows would already wreck while another stands. The exposed: weighted toward the machine its blow would hurt most, a shield standing lowering the draw and a shield about to break raising it. Anything: any machine alike. Heat: the hottest machine. The armed: a machine showing an intact weapon or debuff. Fires as one: the rank shares a pick. A move may aim differently from its foe. The pick is a commitment: a foe whose target shields up still swings at it. | implemented |
| **Self-Destruct** | A blow that spends the striker: after it lands the foe is gone, whole, and nothing brings it back. The blow is the foe's whole life, so it is announced like any other and the answer is to kill it first or to shield what it has picked. | implemented |
| **Every Machine** | A blow at every machine: each of its strikes lands on every machine in the fight in turn, so no aim and no lure moves it, and the number shown is what each machine takes. A shield saves only the machine it stands on; the answers that stop the whole blow are aimed at the striker: kill it, suppress it, disrupt it. | implemented |
| **Last Act** | A blow a foe lands the moment it falls, shown on it by the skull and its number. It lands at once, before anything else, even when the foe was the last one standing, so shield up before the kill rather than after. | implemented |
| **Parts** | A foe in parts: a core and the parts that stand with it. While its parts stand (all of them, or any, by the foe) the core is Guarded and takes no damage; a fallen part may grow back after a few rounds; when the core falls, its parts fall with it. Choose what to focus: a part to open the core, or the core to end them all. | implemented |
| **Countdown** | A move that gathers before it lands: announced as the round opens, it lands the stated number of rounds later, its warning chip counting down the whole time. Nothing hits while it gathers. Suppress holds it a round, Disrupt breaks it off, and killing the foe ends it. | implemented |
| **Foe action** | A foe has a base attack, the quick read of how hard it hits, and a list of actions: attacks that scale it, and defends, buffs and debuffs it does instead of a blow (bracing against damage, regrowing or curing one of its own, readying to get back up, calling up a foe, rallying the others, costing the team a reroll, setting a machine burning, switching off the entry a die shows, scorching or corrupting every machine). Each round every foe on the field picks one by weight before the player acts, so what it will do and to whom is announced exactly. An attack's damage is the base times its factor, and the help text shows the resulting number. | implemented |
| **Scorch** | Foe attack keyword with a number. Each blow that lands leaves that many stacks of Scorched on the machine it hit (Scorch 2: two): every weapon and equipment it aims at a foe runs hotter. | implemented |

## Rules

| Term | Codex | Status |
|---|---|---|
| **Order of operations** | Everything that changes a number goes through one pipeline, in one order. Sources: the chassis passive and each fitted component's passive (until refitted), skirmish rewards (until the battle ends), buffs and debuffs (until the skirmish ends, or until the end of a given round). First suppression, shortest-lived source to longest: a live effect that suppresses another by id or tag turns it off, and a suppressed effect suppresses nothing. Then the gate: an effect takes part only if it is live, its trigger fires now, its condition holds, and, for an ability, its component is not destroyed (a destroyed component keeps its stat bonuses and loses its abilities). Then adds, all sources summed; then multiplies, all sources multiplied; then floors and caps; then overrides, where the shortest-lived source wins and the latest granted breaks ties. In an attack, the roll (or the flat number, with what fired heat or a target's missing hull adds) comes before the pipeline's adds and multiplies; a raised ceiling or floor moves a rolled range before the roll, and the die shows it. Nothing is ever stored as a total: every read asks again, so an effect that is gone stops answering. Statuses stack: the same status granted again adds stacks instead of a second copy; an add is worth its value per stack and a multiply is applied once per stack; a status that ticks applies its per-stack tick at its owner's turn, then loses one stack, and is gone at zero. | implemented |

## Holes

Every entry whose `design.holes` is not empty. This is the list of things the mechanics do not do yet.

- **HP** (implemented): A machine's health is its hull; the engine's code may say either word.
- **Shield** (implemented): Rates and shield sizes are placeholders. No in-combat trickle; a passive may bring one back for one chassis.
- **Heat** (implemented): Heat does nothing below the cap. Consider effects at high heat short of overflow. Cooling numbers are placeholders; cooling must stay below a typical weapon's heat or heat never matters, and a vent component must be worth a whole turn (tuning).
- **Rift Pressure** (implemented): It does not escalate yet (section 12's pacing question).
- **Gate Integrity** (implemented): The gate damage formula is a placeholder.
- **Weapon** (implemented): The engine's kind is attack for a weapon and a debuff alike: a debuff is an attack of no damage (Face.is_debuff), so code asks is_weapon() for this word and is_attack() for both.
- **Spillover** (implemented): The spill is plain damage: it spends a Shock and feeds the Ammit's kill rule, and carries no other keyword of the blow.
- **Cryo** (implemented): Other pieces may lay it (marked for reuse as a healthier ally cooling than a vent). A rider on the mark is benched until the roster has room. The cooling a stack is a placeholder.
- **Burn** (implemented): Its number rides on the face beside the keyword (burn), and the validator asks for it.
- **Lure** (implemented): No status and no chip: the arrow is the record. A draw by an ally is parked (the bible's redirection row).
- **Expose** (implemented): The formation word exposed stays rules text, so the status's id is exposure.
- **Disrupt** (implemented): Deterministic: the next move in the foe's list that its conditions allow, so a boss steps through its pattern.
- **Web** (implemented): A keyword, so its chip and checks come free; the burst runs at the end of the foe's action (Skirmish._web_burst).
- **Flak** (implemented): The stacks land after the blow, so the blow that lays them never feeds on them and a later strike of the same spend does.
- **Numbed** (implemented): Its numbers are placeholders, to be judged against fight lengths.
- **Paradox** (implemented): The count is a placeholder.
- **Volatile** (implemented): Hull outright, where the Corrupted bite takes shield first. The number is a placeholder. A keyword with a chip until 26 October; a cost like heat since, so the die says the price and no chip does.
- **Shield cost** (implemented): No piece carries it yet; the numbers are content's.
- **Overcharged a kill** (implemented): A spread that kills two feeds twice; a chain feeds on every link.
- **Rapid** (implemented): Every Rapid piece carries a limiter (a cooldown, heat or Volatile), which the validator holds content to; a Rapid vent is never below tier three and a Rapid shield never below tier two (the bible's Rapid row).
- **Silence** (implemented): Who carries it is section 12's question. Cast only where a machine carries a buff (the move's machine_buffed condition), aimed at the buffed; it touches no store.
- **Purge** (implemented): Who carries it is section 12's question. The id stays dispel. It takes no store; a store's active effect, when one exists, is silenced for a turn instead, since the store would grant it again.
- **Overshield** (implemented): Rare because every overshield on the field makes shield max a soft number; the fade is the whole safeguard, since a lasting excess would stack a team past every blow.
- **Exposed** (implemented): The id is exposure, since exposed names the formation word and the foes' default aim.
- **Syrinx Drone** (implemented): A status the team put on the foe, so the Paradox counts it.
- **Overcharged** (implemented): Every grant is one status on the machine and the stacks add up. A halving rule has no duration, so a buff component grants stacks and no rounds. The name is a placeholder.
- **Sealed** (implemented): One chip, renewing, never stacking: the armour it grants is tied to the form. The numbers are placeholders.
- **Cryo** (implemented): Engine id cryoed, since the keyword holds cryo; the player reads Cryo on both.
- **Armoured** (implemented): The engine id stays braced.
- **Primed** (implemented): A placeholder name.
- **Corrupted** (implemented): The bite is the status's own number in the engine's table, a placeholder.
- **Phased** (implemented): Not targetable means allies cannot vent or shield it either, and a foe's intent on it picks again; it still cools by its own cooling, and ticks and overheats still land. Aphelion's pieces may grant it beside the Swallowtail's screens.
- **Burning** (implemented): Engine ids burning (a foe's) and burning_mech (a machine's).
- **Vitriol** (implemented): Only the funnel-web's passive lays it; a keyword that ever carries it shares the word. Whether a tick passes Guarded is the parts' question, as Burning's is. The word Corroded is kept for a foe's damage over time on machines.
- **Webbed** (implemented): The burst catches the next foe to act beside it in its rank, the one to its left when none stands to its right; on a foe already suppressed it is wasted, and each half feeds the Paradox as the Suppress keyword's does.
- **Spun Up** (implemented): Spent whole by the next weapon, equipment leaving it: weapon only until balance says otherwise (Ryan, 26 October).
- **Hot Streak** (implemented): A working name, the Kite's heat tax.
- **Shots** (implemented): Kept only for a machine whose rule counts (an nth_shot condition).
- **Quick turn spent** (implemented): Set by a static grant of Rapid on setup_once (the Needletail's relay).
- **Siphoning** (implemented): The number is the entry's own (heat_per_blow), the lever.
- **Flak** (implemented): Adds before multiplies and before armour, to a weapon's blow of 0 too (Ryan, 25 October: "Flak and overcharge exist in part to get past armour"), so a Shocked foe carrying Flak takes blow plus Flak, doubled. The id follows the participle habit (Burning, Webbed). Numbers are placeholders; Flak beside Overcharged at a point a stack each may read too strong, the two read together on the Prairie Dog's rows.
- **Destroyed component** (implemented): The threshold is a placeholder, set by what it asks of the player, never by a loss or win rate (Ryan, 25 October). The campaign's hangar screen is not built.
- **Mine** (implemented): The landing waits until the reinforcement step has placed every arrival, then goes left to right, so a Spread mine catches the arrivals beside it. A Swap that moves a foe into a mined slot sets it off at once.
- **Reinforcements** (implemented): How elites arrive is section 12's question.
- **Massive** (implemented): Spread treats it as a front-rank neighbour; Penetrate finds nothing behind it.
- **Movespeed** (implemented): Every chassis's move is a placeholder set by size and role; the content check flags a chassis at least as fast as another on every ground, never refuses it.
- **Walk** (implemented): A pack with no way to the gate waits, and the map says so.
- **Carry** (implemented): A landing animation or a redistribution on landing may come later.
- **Ring** (implemented): Rings are content on the foe type, placeholders; a machine's attack range is two for every chassis, an exception only where a role earns it.
- **Behaviour** (implemented): Push and hunt are the only behaviours; the hunters' caveats are placeholders.
- **Pack** (implemented): The rift should spawn formations, not single packs: the foes' fresh start.
- **Footprint** (implemented): Footprints do not rotate with facing.
- **Structure** (implemented): The rift does nothing yet beyond marking where packs spawn.
- **Spawn** (implemented): A full spawn list should arrive together as a formation; pressure currently sends one pack at a time.
- **Ruins** (implemented): No skirmish condition yet; what terrain does in a fight is section 12's question.
- **Water** (implemented): No skirmish condition yet (section 12). The generator gives every map one real water feature with crossings for the horde.
- **City defense** (planned): No die and no rule yet: how gate defences work is section 12's question.
- **On shield gain** (implemented): No content uses it yet.
- **On shielding an ally** (implemented): Fires on the spend, whatever the shield gained, so a shield die on a topped-up ally still does its other work.
- **On round start** (implemented): The heat it reads is the gauge after the turn's passive cooling (the Buzzard's Thermal Recoupler).
- **On skirmish start** (implemented): No content uses it yet.
- **On applying stacks** (implemented): Shocked and Suppressed are not stacks, so it never touches them.
- **On hull damage** (implemented): The hook for the pinned berserker idea too.
- **Out of combat** (implemented): Heat does not persist between fights, so a vent here would be nothing. No content uses it yet.
- **Command die** (planned): Open question: whether the command die exists at all, or one-shots only.
- **City ability** (planned): Consider range limits from the gate so the push north leaves support behind.
- **Cooldown** (implemented): A price as heat is. The city's battlefield abilities count their own cooldowns in phases.
- **Reset** (implemented): No limit (Ryan, 24 October: "Let the Kite reset infinitely. There are other ways to nerf it that aren't more rules exceptions"): the free roll never lands on the entry just spent, so each action past the second is a team reroll back onto it and another kill, and the Kite's heat climbs with every kill.
- **Pull** (implemented): Never Rapid, so a pull costs the turn and the laying is still chosen.
- **Drone** (implemented): The condition is read before the drone lands, so its own Exposed never makes it Rapid.
- **Spray** (implemented): The die shows the first strike's number, as a Spread does (Ryan, 17 October); a later strike may spend a Shock on another foe, an understood risk ("no different than using a cleave").
- **Component** (implemented): Multi-slot components were set aside as invisible complexity.
- **Fixed component** (implemented): Never bought open. Locked pieces are powerful and unique, never blueprints, so no hardpoint stocks one and none carries a tier (the validator holds it; ContentDB.component_tier answers 0).
- **Module** (implemented): Fitted in the harness and the quick campaign's hangar: the campaign's roster, the loot that drops them and its hangar wait for the economy pass and the hangar screen.
- **Armour** (implemented): Numbers are placeholders.
- **Aim** (implemented): Content: aim on a foe type and on a move; when on a move is the condition that lets a foe pick it, and a special never fires twice running.
- **Self-Destruct** (implemented): A property of a foe's attack action, like breach. A self-destructing foe counts as a kill like any other.
- **Every Machine** (implemented): A property of a foe's attack action. Its number is per machine, so a move with it is priced well under a single blow from the same foe. The name is a working one.
- **Last Act** (implemented): Content: on_death.blow, an attack's shape (name, factor, strikes, keywords), beside or instead of a split. No foe carries it yet.
- **Parts** (implemented): Content: parts (foe ids), guard (all or any), regrow_parts (rounds). Parts are found by pack and type, one deep, and deploy by the ordinary rules, so beside the core is likely but not placed. No foe carries it yet.
- **Countdown** (implemented): The foe stays on the field while it gathers; its pick holds while the machine stands, and a Lure moves it.
- **Foe action** (implemented): A foe's whole brain is its weighted draw and its aim; none plans ahead.
- **Vents all** (implemented): Only the first shot of a chain fires the heat.
- **Grows with missing HP** (implemented): Both numbers are the entry's own (power_per_missing and per_missing), placeholders.
- **Gated** (implemented): Suppress alone carries a gate today. A working name for Ryan's name pass.
- **Consumes** (implemented): A mine laid from it eats its arrival's stacks.
- **Burns its firer** (implemented): A working name for Ryan's name pass.
- **The hopper** (implemented): The numbers are placeholders; the Honey Badger's rework (its brief) may change the fill.
- **Braces** (implemented): A rule on one carrier, not a keyword, until another piece wants it; the stacks are a placeholder.
- **Rolls again** (implemented): A rule on one carrier, not a keyword, until another piece wants it.
- **Strikes** (implemented): Heat is paid once per use, not per strike.
- **Static** (implemented): Every read asks the pipeline; nothing is written to a stat or a component, so an effect that is gone stops answering. A static reach rule cannot be conditioned on reach.
- **Order of operations** (implemented): Refit (the hangar) is what changes loadout-scoped effects; not built.
- **Rage** (implemented): Capped at 5 (the passive's stack_status cap).
- **Hopper** (implemented): No cap and no grant yet: the Honey Badger's rework (its brief) gives it a cap and an armour a load; today it shows as a chip.
- **Scorched** (implemented): Placeholder numbers.
- **Silenced** (implemented): Its stores are untouched (a lever if silence does not hurt enough); a store's active effect, when one exists, is a buff and sleeps with them. Its keywords act (Ryan, 26 October: buffs alone, on the mechanics audit's question; it had muted them since 21 October, when a muted Volatile made a silence an upgrade).
- **Ward** (implemented): A foe's move that lays a debuff without a blow is a rider too (Ryan, 25 October: "Should stop all riders, even from non-damaging attacks"), so a Stoke, a Stone, an Eruption on every machine and a Diamond Dust all pass a warded machine by.
- **Muster** (implemented): Every number is a placeholder; carrying it between fights is section 12's heat question.
- **Rallied** (implemented): The reroll it grants counts toward the Muster when spent on the carrier: the intended combo, held by the cap.
- **Regenerating** (planned): Planned until the engine has a round-start shield on a timed status and the rider on a weapon's own spender. The number is a placeholder.
- **Ammo** (implemented): Never a buff, so no Silence or Purge reaches it. If ammo runs plentiful, the vents' and shields' reloads or the trickle come down.
