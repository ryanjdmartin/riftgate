# Every rider, buff and debuff in one table (15 November)

Ryan, 15 November, in the vocabulary pass's third round: "Can you gather all the riders,
buffs and debuffs into one table? Just names, type, effects, and where it exists. No numbers
needed. I just need to see them all in one place to mark them."

Read from content as it stands on main: the vocabulary's keywords and statuses, the foes'
riders and moves, and what the pass has decided or proposed, his rulings of the fourth round
among them. A rider and the mark it lays
share a row. "Planned" is a draft the engine does not run; "in design" is a machine not
dealt. The pass itself is `docs/vocabulary_pass_proposal.md`; his marks on this table fold
into it. `tools/pages/vocabulary_marks_page.py` turns this file into the page he marks on.

| Name | Type | Effect | Where it exists |
|---|---|---|---|
| **Our riders: the shape of a blow** | | | |
| Spread | Rider, ours | The foes beside the target in its rank take the rider's number. On equipment its effects reach them | Airburst Shell, Proximity Klaxon (tier one). The Prairie Dog's Flakshot Repeater. The Cottonmouth's drum at the front rank. The Polar Bear's Cryo Flinger while sealed |
| Splash | Rider, ours | Every foe round the target takes the rider's number: beside it, and behind or before it | Howitzer (tier one). The Musk Ox's Shrapnel Recuperator |
| Penetrate | Rider, ours | The other rank of the target's column takes the rider's number | Enfilade Beam (tier one). The Cottonmouth's drum at the back rank |
| Chain | Rider, ours | Every other Shocked foe takes the rider's number. Their Shock stands | Arc Fault Cannon (tier one) |
| Spillover | Rider, ours, a module's | Damage past a kill in the front rank carries into the foe behind | Overrun Gearing (module, tier two) |
| Breach, ours | Rider, ours | The blow ignores a foe's armour | Overclocked Railgun (tier one). The Ammit's Soulcutter Talons. The Wild Boar's next weapon after it gains a Barrier |
| **Our riders: a mark on a foe** | | | |
| Burn, lays Burning | Rider, ours. Debuff on a foe | Stacks. At the start of its action the foe loses a point of hit points a stack, past armour, then a stack fades | Incendiary Shells, Blazethrower (tier one). Stoker, Meteor Artillery (tier two). Gravity Knuckles (tier three). Solar Flare Array (planned). A Primed machine's blows |
| Flak | Rider, ours. Debuff on a foe | Stacks. Every weapon blow on the foe lands a point more a stack. Halves each round | Airburst Shell (tier one). Flak Cannon (tier two). The Prairie Dog's Flakshot Repeater. The Dingo's Hollow-point Harpoon. The Musk Ox's Shrapnel Recuperator |
| Shock, lays Shocked | Rider, ours. Debuff on a foe | The next weapon strike aimed at the foe deals double, then the mark clears. Never stacks | Polarity Projector (tier one). Tesla Gauntlets (tier two). The Dingo's Combat Translocator. A foe that strikes a Retaliating machine's bare hull |
| Sap, lays Sapped | Rider, ours. Debuff on a foe | The foe's blows deal a point less a stack until after its next action. The rule runs on a machine too, and no foe lays it | The Baboon's Redshift Emitter |
| Cryo | Rider, ours. Debuff on a foe | Stacks. Any machine's weapon hit on the foe spends them and cools the hitter | The Polar Bear's Cryo Flinger |
| Expose, lays Exposed | Rider, ours. Debuff on a foe | The foe is in Direct reach of every machine and its armour counts for nothing, until the end of the next round | The Needletail's Fovea Designator. The Lammergeier's Lorentz Contractor. The Swallowtail's Spotting Flare (in design) |
| Suppress, lays Suppressed | Rider, ours. Debuff on a foe | The foe skips its action this round, and is harder to stun for a while after | Suppression Battery, Backdraft Charge (tier two). Umbra Inducer (tier three). The Baboon's Paradox at its count. A Web's burst |
| Disrupt | Rider, ours | The foe does its other move instead, this round | Differentiation Probe (tier two). The Baboon's Retrocausal Shroud, on every foe aiming at the machine it covers |
| Lure | Rider, ours | Every foe the entry reaches turns on this machine for the round | Proximity Klaxon (tier one). Shift Whistle (tier three). The Polar Bear's Cryo Flinger. The Storm Petrel's St. Elmo's Regenerator |
| Purge, ours | Rider, ours | The foe loses stacks of every buff it carries | The Baboon's Redshift Emitter. Null Field Emitter (tier two) |
| Web, lays Webbed | Rider, ours, a kit's | After the foe's action the web bursts: it and the next foe to act beside it are Suppressed | The Funnel-web's Web Bomb |
| Swap | Rider, ours, a kit's | Two foes trade places | The Dingo's Combat Translocator |
| Vitriol | Debuff on a foe, a kit's | Stacks. At its action the foe loses a tenth of its current hit points a stack, past armour, then a stack fades | The Funnel-web's Ambush |
| Mine | Debuff on a foe, a kit's | The machine's spends add damage and keywords to a Mine on the foe. It blows on every foe round it when the foe falls | The Lammergeier's Reverberant Payload, with Gather on its Lorentz Contractor and Detonate on its Syrinx Drone |
| Paradox | Debuff on a foe, a kit's | The foe gains a stack for every other debuff stack it gains. At the machine's count it is Suppressed | The Baboon's Pocket Paradox |
| Pinned Flak | Debuff on a foe, a kit's | The foe's Flak does not halve at this round's end | The Dingo's Hollow-point Harpoon |
| Pinned Burning | Debuff on a foe | The foe's Burning burns and loses no stack this round | No piece lays it today |
| **Our riders: on the spend, and on a machine** | | | |
| Rapid | Rider, ours | After the spend the machine acts again on another entry, and the entry spent is dark for the round | Pulse Vacillator (tier two). The Skua's Hypersonic Swoop. The Clydesdale's Changeover. The Musk Ox's Quick Reload. The Giant Petrel's Immelmann Booster. Laminar Deflector (planned) |
| Instant | Rider, ours | After the spend the die rolls again and may land on the same entry | The Cassowary's Spin-Up. The Nemesis's Knuckle of Fury on its rage |
| Cleanse | Rider, on either side | Ours: whoever the entry is spent on loses Burning, Scorched, Crushed, Silenced, Disabled and Corrupted. A foe's: the marks the team laid come off one of its own | The Baboon's Retrocausal Shroud. The Wild Boar's Breaching Plow. Corona Shield, Phased Sublimator (planned). Foes: the Spectre, the Wraith |
| Overshield | Rider, ours | The shield granted may pass the maximum. The excess fades at the round's end | The Puffin's Backwash Ionizer (in design) |
| **Buffs** | | | |
| Barrier | Buff, on either side | The next blow that lands deals nothing, and its riders still land. Until the round's end | Halo Projector (basic). Blast Door (tier one). The Wild Boar's Breaching Plow. Foes: the Pit Antlion, the Djinn |
| Ward | Buff, on either side | No rider or mark the other side lays lands this round. Damage lands | Decoherence Veil (tier one). No foe wards today |
| Armoured | Buff, on either side | A point of armour a stack, off every blow that reaches the hull. A machine's lasts until the round's end, a foe's until its next action | Shoring Jack (basic). Shift Whistle (tier three). The Honey Badger's Ore Hopper. The Polar Bear's Lockdown. Phase Conjugator (module). Foes: the Goblin's, the Antlion's and the Sandworm's brace and their kin; on every foe, the Goblin Shaman and the Death Knight |
| Empowered | Buff, on either side | A point on every attack a stack. Halves each round | Overcharge Coil (tier one). The Stingray's Photosphere Lance. The Giant Petrel's Reheat Uplink. The Ammit's Souls and Soul Siphon. Grievance Reliquary (module). Foes: a rally, from the Dire Wolf, the Goblin Shaman and eight more |
| Regenerating | Buff, on either side | A machine regains shield as each of the next rounds opens. A foe regrows hit points at each of its next actions | The Storm Petrel's St. Elmo's Regenerator. Foes: the Barrow Giant and its kin, the Wight, the Draugr |
| Primed | Buff, on either side | Every blow it lands leaves Burning | Aurora Lattice (tier two). Foes: the Magma Lizard primes its pack |
| Retaliate | Buff on a machine | A foe that strikes its bare hull is Shocked | Retribution Thurible (tier one). The Salamander's Ember Hide is planned |
| Charged | Buff on a machine | Its weapons fire with Shock. A weapon fired spends a stack | No piece grants it today |
| Supercooled | Buff on a machine | Its weapons fire with Cryo. A weapon fired spends a stack | No piece grants it today |
| Spun Up | Buff on a machine, a kit's | Its next weapon deals more a stack and takes every stack | The Cassowary's Spin-Up |
| Ricochet | Buff on a machine, a kit's | After a weapon fires it hits its target again, once a stack. Hull damage halves the stacks | The Skua's Carom Field and Hypersonic Swoop |
| Juggernaut Breach | Buff on a machine, a kit's | Its next weapon attack gains Breach | The Wild Boar's Juggernaut Drive, on gaining a Barrier |
| Phased | Buff on a machine | It cannot act, take damage or be targeted until the round's end | The Swallowtail's Mooring Screens, charged (in design) |
| Rallied | Buff on a machine | Its team has one reroll more this round | The Giant Petrel's Immelmann Booster. The Swallowtail's Reveille Horn (in design) |
| Pinned Empowered | The round's rule, a kit's | No Empowered halves at this round's end, on any unit | The Ammit's Soul Siphon |
| **The foes' riders: a mark on a machine** | | | |
| Breach, the foes' | Rider, the foes' | The blow ignores the shield and the armour and lands whole on the hull. A Ward turns it away | 34 foes. At tier one: the Needler, the Zombie Knight, the Sandworm, the Magma Elemental, the Roc, the Bomb's last blow; the Old Man of the Desert, the Reaper, the Pilgrim |
| Burn, lays Burning, on a machine | Rider, the foes'. Debuff on a machine | Stacks. A point of heat a stack as the player's turn ends, then a stack fades | The Drake's and the Wyvern's Stoke. The Bane. Rotbloom. The Fiend of Fire. A pack the Magma Lizard has primed |
| Scorch, lays Scorched | Rider, the foes'. Debuff on a machine | Every weapon and equipment the machine aims at a foe runs hotter a stack, this turn alone | 21 foes. At tier one: the Salamander, the Drake, the Bomb, Cerberus; the Goblin Nob, the Cinder Tortoise. On every machine at once: the Magma Elemental and its kin, the Red Dragon, the Black Mage, the Summoner |
| Corrupt, lays Corrupted | Rider, the foes'. Debuff on a machine | The entry the die shows bites its owner when spent, a bite a stack, shield first, for the rest of the fight | 13 foes. At tier one: the Reaper, the Rust Monster, the Fell Rider. Above: the Barbed Needler, the Gorgon, the Wraith, Rotbloom; the Emperor Scorpion, the Marsh Serpent |
| Crush, lays Crushed | Rider, the foes'. Debuff on a machine | Every blow the machine takes lands a point more a stack, through the next round | The World Eater |
| Disable, lays Disabled | Rider or move, the foes'. Debuff on a machine | The entry the die shows comes up blank through the machine's next turn | 15 foes. At tier one: the Whisker Cat, the Cockatrice; the Thunder Ape, the Rust Monster, the Rider of the Wild Hunt. Above: the Basilisk, the Gorgon, the Alraune, the Leshy; the Emperor Scorpion |
| Steal | Rider, the foes' | As a Disable, and the foe's next swing lands the stolen weapon's number | Gilgamesh |
| Drain | Rider, the foes' | The foe regrows what its blow took from the hull | The Vampire Lord |
| Silence, lays Silenced | Move, the foes'. Debuff on a machine | The machine's keywords are muted through its next round | No foe carries it today |
| Swallow, lays Swallowed | Move, the foes'. Debuff on a machine | The machine is out of the fight for some rounds, or until the swallower falls or is hurt enough | Floraison. The Ruby Colossus |
| Drained rerolls | Move, the foes' | The team has a reroll fewer next round. The foes never announce more of it in a round than a round's rerolls | The Mandragora and the Mandrake. The Fell Rider. The Obsidian Tyrant. The Thief |
| Purge, the foes' | Move, the foes' | The machine carrying the most buffs loses every buff an entry bought | The Djinn |
| Destroyed component | Debuff on a machine, a rule | A blow that puts a quarter of its hull on the hull destroys the entry the die shows, for the battle | Any blow big enough |
| **The foes: the shape of a blow** | | | |
| Every Machine | Blow's shape, the foes' | The blow lands on every machine, so no aim and no lure moves it | 31 foes. At tier one: the Goblin Shaman, the Old Man of the Desert, the Fell Rider, the Cinder Tortoise. Most bosses |
| Countdown | Blow's shape, the foes' | The move lands rounds after it is announced | 17 foes. At tier one: the Roc, the Reaper, the Pilgrim. Six bosses |
| Several strikes | Blow's shape, the foes' | The blow lands more than once | 12 foes. At tier one: Cerberus, the Thunder Ape. Floraison, the Matador, the Emperor Scorpion, the Fiend of Fire |
| Self-Destruct | Blow's shape, the foes' | The blow spends the striker | The Bomb, the Grenade, the Balloon |
| Last Act | Blow's shape, the foes' | A blow the foe lands the moment it falls | The Dread Knight. The Gargantuan King |
| Grudge | Blow's shape, the foes' | The blow is a point heavier for every foe the team has killed this fight | The Pilgrim |
| Follow-up | Blow's shape, the foes' | A move that names the move its foe makes next round | Gilgamesh, the Cinder Tortoise, the Firelord. The Matador, the Mantis Ant |
| The aims | Whom a foe strikes | The hottest machine; the lowest shield, which the engine calls the exposed; the armed; the most buffed; one machine held to | Heat: the Red Dragon, the Black Mage. The lowest shield: the Bone Wyvern, the Lancer, the Martial Artist, the Warrior. The armed: the Basilisk, the Gorgon, Gilgamesh, the Rust Monster, the Thief |
| **The foes' own buffs and moves** | | | |
| Brace | Move, the foes' | The foe is Armoured until its next action; some brace every foe | 13 foes, and 3 that brace every foe. At tier one: the Goblin, the Antlion, the Sandworm; the Goblin Shaman, the Old Man of the Desert, the Cinder Tortoise |
| Rally | Move, the foes' | Every other foe is Empowered | 10 foes. At tier one: the Dire Wolf, the Goblin Shaman |
| Regrow | Move, the foes' | The foe, or one of its own, regains hit points at once | The Treant and its kin, the Rust Monster, the Bone Wyvern. On another: the Mending Orb, Enkidu, the Cleric |
| Undying | Buff on a foe | After it falls it gets back up once, whole | The Zombie Knight, the Dullahan and their kin, the giants above tier one, the Vampire Lord. Given to another: the Lich, the Skeleton King |
| Summon | Move, the foes' | A foe of a named kind joins the field | 11 foes. At tier one: the Ghost. Above: the Spectre, the Wraith, Rotbloom, six elites, the Phantom Train |
| Merge | Move, the foes' | Every Gel on the field is taken in: it regrows their hit points and hits harder for each | King Gel |
| Splits as it falls | A foe's own rule | The foe leaves two smaller of itself | The Gel, the Bubble Gel |
| Numbed | Buff on a foe | A stun on it strips a stack and lands nothing | Every foe after a stun; deeper on a massive foe, an elite, a hero and a boss |
| Enraged | A foe's own rule | Every shield, vent or equipment entry the team spends lays a stack on it, each a point on its blows | The Goblin Nob |
| Golden | A foe's own rule | Its blows hit harder and it wears armour while the rage lasts. Enough damage breaks it and staggers the foe | The Thunder Ape |
| Guarded, and parts | A foe's own rule | A core takes no damage while its parts stand | The Astromancer. The Fallen Weapon, the Obsidian Tyrant, the Ruby Colossus |
| **A machine's own states, no buff and no debuff** | | | |
| Sealed, Changed Over, Souls, Quick turn spent | A kit's own | Each its machine's mechanic: no Purge, Silence or Cleanse touches it | The Polar Bear. The Clydesdale. The Ammit. The Needletail |
| **New with the reboot, and proposed in this pass** | | | |
| Rebooting | State, the reboot's | The machine has given its turn: its shield is at nothing through the enemy's turn, and it is cold and whole as the next round opens | Every machine, behind the REBOOT trial |
| Overheated | Debuff on a machine, the reboot's | Heat past the maximum stays, a stack a point, and burns hull a stack at every END TURN. No cleanse lifts it | Every machine, behind the REBOOT trial |
| Broken | Debuff on a machine, the reboot's | A shield at nothing gains no shield by any method until the reboot. No cleanse lifts it | Every machine, behind the REBOOT trial |
| Ablate, lays Ablating | Decided 15 November, his word and form: one rule for Burn on both sides | Stacks. As its side's turn comes round the unit loses a point a stack, then a stack fades. On a foe hit points, past armour. On a machine the shield first, then the hull past armour. A tick ignores a Barrier | Replaces Burn and Burning on every piece and foe that carries them. Not built |
| Exposed, on a machine | Decided 15 November, his | The machine's armour of every kind counts for nothing at once and until the end of the next round, and as the next round opens every targeted intent turns on it, the whole field. Nothing happens to its shield. A Lure moves the fire, and the mark as it is announced; a Ward turns it; a Cleanse gives the armour back and leaves the intents. The foes try it on one machine at a time | No foe yet: tier two and up, in formations that suit it. Not built |
| Breach, the foes', as shield damage | Proposed, his of 15 November, and in question since: whether the foes need Breach at all | The blow deals more to a shield, in place of ignoring shield and armour. It no longer reaches the hull directly | Would replace the foes' Breach, as one domain's identity at most. Not built |
| Ignores armour | Decided 15 November, his: a property written on the piece, no keyword | The blow ignores a foe's armour | Replaces our Breach on its three carriers: the Overclocked Railgun, the Ammit's Soulcutter Talons, the Wild Boar's next weapon after it gains a Barrier. Not built |
