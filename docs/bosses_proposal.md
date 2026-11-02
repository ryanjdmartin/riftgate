# The bosses and elites: a proposal

The roster's tiers are decided (Ryan, 15 October; the bible's section 9, "The roster comes in
tiers"): tropes for the rank and file and its elites, the genre's iconic bosses three a domain,
the genre's heroes as the finals, big as an attribute of any tier, and a boss's mechanics kept
inside the skirmish. This file holds what fills the elite and boss tiers until Ryan has marked
it all; then its picks become content and bible rows, and it retires (git keeps it). Names are
working names, and everything here is Ryan's to move.

The slate's twelve landed 30 October as runnable placeholder kits: seven on Ryan's word ("build
what can be built, and specify exactly what you need to flesh the rest out, including any
holes"), the last five on his yes ("Yes to all waiting bosses"). The stand-ins went to the rank
and file and the Bone Wyvern to the elites. Their kits are in `content/foes.json`; what landed
and the calls still open are below the slate.

## Elites

Ryan's definition (23 and 24 October; the bible's tiers row): a spawn of one or more unique packs
outside the usual spawn list, a mini-boss tier, any size: a miniboss event in the middle of a
battle, guaranteed rather than one of the random spawns, to break up the flow, add depth and
drain the player's resources with a high-pressure situation every battle is sure to hold. It
throws a visible curveball into the player's strategy and demands the player adapt, by a
mechanic on the map (a dangerous hunter, a fast blitz on the gate, a sudden swarm, an aura or a
battlefield effect) or simply by being a harder fight that threatens the gate while it holds the
team, which is what a tier-one elite looks like. About one an early battle, more later.

| Domain | Elite | Size | State |
|---|---|---|---|
| The Meadow | Goblin shaman (the marked `goblin_takesD_1`) | Not massive | Ryan, 15 October: a decent elite |
| The Meadow | The Elder Treant, the beefed-up alpha | Massive | Ryan, 24 October: the harder-fight elite (the ent is Tolkien's coinage, and the treant D&D's rename of it, so the name is ours) |
| The Meadow | The Leshy (Slavic folklore's forest lord) | Open | Ryan, 24 October: liked, and may be a foe of its own beside the Elder Treant for diversity |
| The Waste | The Old Man of the Desert, the king sandworm | Massive | Ryan, 24 October: the harder-fight elite, named for Dune's own words for its worm, plain words the names rule below lets stay |
| The Marsh | Bone Wyvern | Massive | An elite since 30 October (Ryan, 24 October), the Marsh's second, at tiers two and three with three Revenants |
| The Marsh | The Reaper (Persona's chained one among many: every JRPG has a reaper, Ryan) | Not massive | Ryan, 15 October: in, a trope by the tiers' own test, so an elite that can turn up in many fights, leaving the boss slot to the Matador; 24 October: the deadly hunter elite. Art picked and cut 18 October (image to image from his first pick, its third hand gone) |
| The Marsh | The Coven: three hags, each unique (a triple trope: Macbeth's Weird Sisters, the Graeae sharing one eye; the genre's own are Final Fantasy IV's Magus Sisters) | Not massive | Noted for later (Ryan, 15 October: not yet) |
| Any | A pair of gate gargoyles (a pair trope) | Not massive | Noted for later (Ryan, 15 October: not yet) |

Out of the tier (Ryan, 23 and 24 October): the Treant, the Magma Elemental (the Magma Golem
until 23 October: a golem implies a master) and the Sandworm are rank and file, massive, in their
domains' formations at tiers one and two since 30 October (Ryan: "they are rank and file after
all"), two moves each as the rank and file carry at tier one, each one's third left for a
higher line's twist.

## Bosses: the slate (third cut, 15 October)

Each brings its signature move, inside the skirmish.

The boss in parts is a pattern worth including whoever carries it (Ryan, 15 October): parts that
regrow, or stand for a while, until the core is killed, so the player chooses what to focus.
Two fists and a head (Chrono Trigger's Giga Gaia), Retinite's core, Exor's hilt. In the engine:
the core massive in its column, its parts separate foes in the next ones, regrowing while the core
stands or shielding it until one falls.

| Domain | Boss | From | Its signature | Engine |
|---|---|---|---|---|
| The Meadow | King Slime | Dragon Quest | When enough Gels stand on the field they merge into the king: thin them first | Landed 30 October as the King Gel, its merge built |
| The Meadow | A Malboro (working name Rotbloom) | Final Fantasy | Bad Breath: a blow at every machine carrying every rider at once; cleanse is the answer | Landed 30 October as Rotbloom |
| The Meadow | Floraison (Ryan's name, 15 October: the flowering; Bourgeon, French for a branch's bud, is its game's own). Its shape is humanoid (Ryan, 18 October, of the first takes: none matched; a humanoid body with the round thorn-rimmed maw of take 1 for a face), the fourth round of takes; his pick of it (4), redrawn less muscular, lanky as a sapling, for the fifth; his pick of that (2) wanted 1's eyeless maw (19 October), so the sixth is the edit model on 2 (the eyes inside the mouth removed) beside a composite of 1's head onto 2 re-rendered close; his pick of that (3, the composite) lost spines and vines on the head's left where the paste box clipped, so the seventh completed them (the edit model, and the composite redone wider), which did not work either (Ryan, 19 October: "maybe go back and try the head-swap compositing again"); the eighth is the composite of 1's head onto 2 again, a generous box, shown raw and after a close pass at 0.9: the spines and vines complete at last, all three clean to Claude's eye; Ryan (19 October): still weird even at phone scale, cut off or blurred by turns, is there another way? The ninth round is another way: the two eyes inside the maw painted out with the maw's own black on his pick itself (an erase over dark, as an erase over white is the one hand edit that has passed his bar; nothing re-rendered, so nothing blurs), beside image to image from his pick at 0.7 with the maw described eyeless (0.8 kept the eyes, set aside); Ryan's pick (26 October) the paint-out (bossart10 1), cut into `art/foes` and recorded in picks.json: Floraison is done | Clair Obscur | Swallows a machine, out of the fight for a few rounds; three- and five-hit combos. Its game's miasma would repeat the Rotbloom's Bad Breath in the same domain, so the swallow and the combos are its own (Ryan, 15 October: agreed; the third round's takes show the swallow and the vines); the swallow is hard control, weighed first (the bible's stun row). The game places one in its Meadows | A swallow, built; landed 30 October |
| The Waste | Gilgamesh | Final Fantasy V | Takes the weapon a machine shows and fights with it; now and then the piece it took is a fake | A steal of the showing entry and a borrowed swing, built; landed 30 October |
| The Waste | A Tonberry (working name Pilgrim) | Final Fantasy | Creeps closer, its countdown shown, then the knife; Everyone's Grudge grows with every foe the team has killed and passes the shield. Ryan hates it, which may be the point: keep the dread, drop the unfairness (its games kill outright; here the countdown is shown) | Landed 30 October as the Pilgrim, its grudge built |
| The Waste | An Exor homage | Super Mario RPG | The parts boss: a colossal weapon fallen into the badlands, its eyes shielding the core that drives them, the core untouchable until a part falls. Ryan, 15 October: in, distinct from its game's look, and a hammer or an axe is distinct enough; 18 October, by his pick on the picker: the double-bitted axe standing haft-down, an eye in each blade, cut. The two bits are the parts, a mirrored pair whose blows differ by the eye that drives them (Claude's lean, to propose with its kit: one bit's blow passes the shield, the other's prises loose the component a machine shows, the Waste's two halves), the haft the core | The parts; landed 30 October as the Fallen Weapon |
| The Marsh | The Phantom Train | Final Fantasy VI | Runs a machine down; its whistle calls the dead aboard (Ghosts into the pool) | Landed 30 October |
| The Marsh | Neclord | Suikoden | Drinks what it deals, and gets back up once | Landed 30 October as the Vampire Lord, its drain built and its readying once a fight |
| The Marsh | The Matador | Shin Megami Tensei III | Red Capote: hardens for a round, then Andalucia, a flurry of strikes. Ryan, 15 October: in, the legacy pick; the Reaper goes to the elites. Art: his pick of 18 October (the flourish, 4) lacks the hand on the arm bent across his chest; an added arm and a cape grip through the edit model both missed, so the third round was image to image from the pick, as he asked, and landed the hand; his pick of it (3) wanted 2's head and boots (19 October), so the fourth round was the edit model on 3 (red eye sockets, shoes under the greaves) beside a composite of 2's head and shoes onto 3 re-rendered close (image to image at 0.8), the first composite tried since hand edits failed in October; his pick of that (2, the edit) wanted 3's bolder jaw and nose bone, and the fifth round's edit of the skull was "way too much, full of artifacts" (Ryan, 19 October), so the sixth is a composite of 3's skull onto 2, the two aligned siblings, shown raw and after a close pass at 0.9: the jaw and nose bone carried over clean, no artifacts; Ryan's pick (19 October) the second close pass (fixhand6 3), cut into `art/foes` and recorded in picks.json: the Matador is done | Landed 30 October, its cape and flurry a follow-up (built) |
| The Peak | The Behemoth | Final Fantasy | Meteor on every machine as it dies: shield up, then kill it | A last act; landed 30 October |
| The Peak | The Adamantoise | Final Fantasy | Withdraws into its shell (armour up, so that round's blows are wasted), then Earthquake on every machine | Landed 30 October as the Cinder Tortoise, its shell and quake a follow-up |
| The Peak | Black Tyrano | Chrono Trigger | Azala rides it, the brain: while she stands it is armoured; once she falls it counts down from five and breathes fire on every machine at zero | Landed 30 October as the Obsidian Tyrant with the Saurian Queen as its part, its countdown opening once she falls (built) |

Six of the twelve are Final Fantasy's and six come from six other series.

## What landed (30 October to 2 November)

The kits are placeholders for Ryan's marks, every number too; each boss carries three moves,
the third opening on a condition or following another, and a point of armour (the set of 2
October). The engine pieces built for them run on any foe: a follow-up (a move that names the
move its foe announces next round), a steal with its borrowed swing, a swallow, a merge, a
drain, a grudge (a blow a point heavier for every foe the team has killed this fight), a
condition that reads a fallen part, and a move used once a fight.

| Domain | Boss | Its kit | Claude's leans inside it |
|---|---|---|---|
| The Meadow | Rotbloom | Tendrils, two strikes; Bad Breath at every machine, carrying Burn, Scorch, Disable and Corrupt; below half, Seedfall, two mandragoras called up | The third move and its name |
| The Meadow | Floraison | Thorn Combo, three strikes; Swallow, a machine out of the fight for two rounds, until Floraison falls, or until it has lost a quarter of its HP since (Ryan, 31 October); below half, Full Bloom, five strikes | Two rounds; never the last machine able to act; no damage while held; the release at a quarter, its chip counting the damage left, the swallower losing nothing else |
| The Meadow | The King Gel | Body Slam; Merge, every Gel and half on the field taken in, regrowing what they had left and its next move a point harder for each; below half, Belly Flop at every machine | Its court is its own escort (Gels at every tier), so the merge has fuel; a Gel taken in is no kill of the team's |
| The Waste | The Ruby Colossus (2 November, in the Djinn's place; Ryan: "Ruby weapon is cool". The Djinn, a trope archetype, went to the rank and file: a tier-two back-rank caster, the Waste's purge in the ranks) | Big Claw; Whirlsand, a swallow; below half, Ultima, every machine three rounds on. Two tentacles as parts with no guard, the Burrowing (breach) and the Thrashing (two strikes), back two rounds after they fall | The kit and its name; parts that guard nothing, so the arms or the body is the question; Ultima's three rounds |
| The Waste | The Fallen Weapon | The core: Haft; Drive, a rally; below half, The Fall, every machine two rounds on. Two eyes as parts, the Piercing Eye (breach) and the Prising Eye (disable); the core Guarded while both stand, an eye back three rounds after it falls | One eye down opens the core (guard all); the eyes' blows |
| The Waste | The Pilgrim | Lantern; Chef's Knife, twice its blow on a countdown of two, through the shield; below half, Karma, a point heavier for every foe the team has killed this fight, through the shield | Human-sized; the knife's two rounds |
| The Marsh | The Matador | Estocada; Red Capote, armour +3, then Andalucia, four strikes at one machine | A Suppress or a Disrupt on the cape breaks the pair |
| The Marsh | The Phantom Train | Run Down; Whistle, two Ghosts called up; below half, Last Run, every machine a round on | Two Ghosts, which raise Revenants of their own |
| The Marsh | The Vampire Lord | Drain, a bite that heals what it takes from the hull; Undying, once a fight when hurt, readying it to get back up whole; below half, Blood Feast, a drain at every machine | 40 HP, since it may rise once; once a fight, so it never readies again after it rises; the drain from the hull alone, so a shield starves it (one of shield and hull walled the slowest trio at every HP tried) |
| The Peak | Behemoth | Gore; Flame, Scorch 2; below half, Charge, a round's warning, through the shield; Meteor on every machine as it falls | The Flame and the Charge |
| The Peak | Cinder Tortoise | Bite; Withdraw, armour +2 on its own (3 until 2 November; Ryan: "nerf withdraw to 2 armour so it doesn't completely goof my test runs"), then Earthquake on every machine, Scorch 1 | In, its name kept (Ryan, 30 October); its armour 1, 2 and 3 by the tier (Ryan, 31 October), since at 2 at tier one its base was the hurdle and its shell was not |
| The Peak | The Obsidian Tyrant | Crunch; Roar, a reroll off the team; once its rider has fallen, Firestorm, a countdown of five to half again its blow at every machine, Scorch 2. Its part, the Saurian Queen in the back rank: Lash, and Goad, a rally | Guarded while she stands; the firestorm drawn as good as at once after she falls |

The stand-ins left the boss lists (30 October): the Treant, the Sandworm and the Magma Elemental
stand in their domains' formations at tier one, each with a recolour at tiers two and three
that takes back its third move as the twist (31 October: the Dusk and the Frost Treant with
Root Storm, the Night and the Salt Sandworm with Quake, the Basalt and the Sulphur Elemental
with Stoke the Forge), and the Bone Wyvern leads an elite of the Marsh's at tiers two and
three. The Marsh has a massive line of its own (31 October): the Barrow Giant (a cleaver and
Knit, a regeneration), the Grave Giant and the Charnel Giant (Rise Again, getting back up
once), each in a formation at its tier.

Gilgamesh is an elite since 31 October, the one that wanders: drawn by any domain's Fracture one
time in three in place of its next own elite and always once its own are spent (2 November), at
an elite's 40 HP scaled by the tier as a boss is; an elite may come again in a later battle,
never twice in one, where a run never repeats a boss (Ryan, 2 November). Every boss but the King Gel has its own
escort at tiers two and three, at the tier's counts (two and four), picked to sharpen its
mechanic, and stands alone at tier one:

| Boss | Its escort | Why |
|---|---|---|
| Rotbloom | Mandrakes and Goblin Guards; Alraunes at tier three | The Scream and the Shriek pile more trouble on the die it breathes on |
| Floraison | Wargs; Alpha Wargs and goblins at tier three | Howls and bites on a team a machine down |
| The Ruby Colossus | A Basilisk and a Pit Antlion; Gorgons, the Antlion Queen and a Pit Antlion | Stone and a pit's breach beside a buried machine, so the tempo Whirlsand takes is pressed |
| The Fallen Weapon | Barbed Needlers and Basilisks; Great Needlers and Gorgons | The Waste's breach and theft beside the eyes', so the eyes are a race |
| The Pilgrim | Needlers; Barbed and Great Needlers | Every kill feeds Karma, so the kill order turns over |
| The Matador | Wights; a Death Knight and a Spectre at tier three | A wall of claws while the cape is up |
| The Phantom Train | A Revenant and a Spectre; Wights, a Wraith and a Spectre | The dead it carries, raising more |
| The Vampire Lord | A Death Knight and a Wight; a Dread Knight, a Lich and their kind | The Marsh's other risers, so the burst it asks for is spread thin |
| The Behemoth | A Bomb and a Grenade; Grenades and Balloons | A second blast to shield for |
| The Cinder Tortoise | Fire Lizards; Magma Lizards and a Wyvern | Scorch under the quake, so the shelled round is a heat question |
| The Obsidian Tyrant | A Wyvern and a Fire Lizard; a Red Dragon and its kind | Fire while the count runs |

The slate stands at 48 HP at tier one, the boss in parts' core at 40 and its eyes at 8, the
Obsidian Tyrant's rider at 12 and the Vampire Lord at 40, under the scale row's 80 to 100 (the
bible's section 11): at 80 the default team took 7 to 13 rounds against each boss alone and a
stock four 11 to 22, where the kill-time test asks three to five; at 48 the default team takes 4
to 7 (`docs/measurements.md`, 30 October, 30 seeds, a direction). Ryan, 30 October: "Whatever
you think works best for scaling", so 48 stands, 60 and 72 at tiers two and three.

## Calls still open

Ryan's answers of 30 and 31 October ("I agree with everything in your last two messages")
settled the six calls of the 30th: Gilgamesh an elite that wanders, the swallow's release at a
quarter of the swallower's HP, the steal's fake and the follow-up's break as built, the escorts
written for his marks, the massive lines, and the Cinder Tortoise's armour by the tier. His
calls of 2 November, on the review: the Ruby Colossus in the Djinn's place and the Djinn to the
ranks; the wanderer drawn by chance and elites reusable across battles; the worms' and the
Antlion Queen's bites renamed Maw and Devour, since Swallow is the vocabulary's word for
Floraison's move; Withdraw 2; the King Gel's court six at tier three; the quick campaign's
bosses bringing their own escorts; the Dusk Treant off violet; and no foe flees but a
loot-runner, so the Needler's Scatter is struck. Every name and number above waits on his
content pass. Open:

1. **The slate's blanket point of armour at tier one** (Ryan: "be careful giving all bosses
   blanket 1 armour early on"). Read (`docs/measurements.md`, 31 October, 20 seeds, a
   direction): it costs the small-blow kits about 40% more rounds against the slate and
   Wainwright & Sutler's trio a few fights it wins without it. The forms: armour only where a
   boss's kit is armour, at every tier, every other boss at 0; or none at tier one and the
   standard point from tier two. Claude's lean: the first, a boss's armour by its fantasy as a
   machine's is by its role, the Tortoise's step the form for any that grows it.
2. **A follow-up that cannot be Disrupted** (Ryan: "we need to watch whether stunning a
   follow-up is too strong or not, since its so telegraphed. The follow-up chip could grant
   Numbed if it needed to, but that doesn't stop disrupt, which is the bigger issue. I would
   probably add 'cannot be Disrupted' to the follow-up chip"). A follow-up comes only after
   the move that names it, never by the roll (built so). Claude's view, in chat first: the
   announced follow-up committed, Disrupt unable to turn it, its chip saying so and a Disrupt
   held over it struck through, as a gated keyword shows; the first move stays the window that
   breaks the pair, a round earlier and on that round's dice; Suppress stays, Numbed its limit.
   The hole named: a countdown is as telegraphed and a Disrupt breaks it off, which is its
   design (interrupt the big hit), so the two part by their questions and the countdown stays.
3. **The Thief's Flee under the flee rule** (Ryan, 2 November: a foe flees only as a
   loot-runner whose prize goes with it). The Thief's prize is the final's count, so Claude reads
   it as the rule's one shape; his to confirm, else it is struck as the Needler's Scatter was.
4. **The Cinder Tortoise at tier three** (flagged 2 November, left for now on Ryan's word):
   armour 3, and 5 withdrawn, against blows of 2 to 6, so a round of basics is zeroed; its
   tier-three read with a tier-matched kit is the to-do's, on the runner's `--boss-tiers` cells.

## Art the forge owes

Every boss and part with no picked render is drawn as a rough placeholder, a reminder with a
yellow "?" (Ryan, 30 October: "It can be a comically rough entry as a reminder"):
`tools/placeholder_art.py` draws Rotbloom, Gilgamesh, the Fallen Weapon's two eyes, the King
Gel, the Pilgrim, the Phantom Train, the Vampire Lord, the Obsidian Tyrant, the Saurian Queen,
the Djinn, the Ruby Colossus and its two tentacles, and the Marsh's three giants.
Each entry's `design.sprite` and `design.variants` are its brief for the forge, whose `generate`
and `fix` have had no machine since the Mac went out of reach (the status's Start here), so the
renders wait on the route for the image model Ryan chooses; a pick through the picker replaces
a placeholder.

Names: the series' coinages take names of ours (the Malboro, the Tonberry, the Adamantoise,
Bourgeon, Exor, Neclord, the Tyrano), as the Cactuar became the Needler; myths and plain words stay
(Gilgamesh, the Behemoth, the Matador, the Phantom Train; King Slime is the King Gel). Every
look is ours, never the series' design.

## Conversions (Ryan, 15 October: look for the bosses we could convert)

The slate's six from Final Fantasy, with Claude's lean on each, by Ryan's measure (16 October:
balance the series out a little, never purge it):

- **The Behemoth**: keep. An FF homage is incomplete without it (Ryan), and its name is the Book
  of Job's.
- **The Adamantoise**: converted already, as the Cinder Tortoise, its signature the genre's (into
  the shell, then a quake). For a myth's name as the Behemoth has one: Zaratan, the
  island-tortoise of the old bestiaries.
- **Gilgamesh**: keep, the series' recurring rival, as iconic as the dragoon. If one more is
  wanted, the conversion is **Benkei**, the legend Final Fantasy V's Gilgamesh draws on: the
  warrior monk who took a sword from every warrior crossing Gojō Bridge until the thousandth beat
  him (FF5 fights its Gilgamesh on the Big Bridge). The same signature, the weapon a machine shows
  taken and turned on it; the legend's death, standing in a storm of arrows, a kit idea new to the
  engine (he holds his slot a round after he falls, the back rank still covered). Ryan, 24
  October: tempted to move him down to the elites, since he can pop up anywhere; noted, not
  decided (his slot in the Waste would then want another boss).
- **The Malboro (Rotbloom)**: stays (Ryan, 24 October: mechanically very different from
  Floraison, and a different silhouette), so Claude's lean to convert it out, two maw-plants in
  one domain, is withdrawn.
- **The Tonberry (Pilgrim)**: Ryan's call. Its dread was the countdown, which any foe can carry
  now, and the Reaper is the genre's stalker among the elites, so its slot could go to another
  series as well.
- **The Phantom Train**: keep, Final Fantasy VI's own. The conversion, if wanted, is a ghost ship
  (the Flying Dutchman), with the same signature: it runs one machine down and calls the dead
  aboard.

## Other sources (15 October)

- **Nintendo's games** (Super Mario RPG, Paper Mario, Pokémon): homage by archetype, as for
  everything else: never a name or a look-alike design, and never one of its patented
  mechanics. Nintendo and The Pokémon Company sued Pocketpair over Palworld in 2024 on patents
  (capturing creatures, switching mounts), not on looks. And played straight: only their
  straight-faced moments fit the register (Exor's sword falling into the keep). Pokémon's
  natural home is the Tamer on the Meadow's bench, the trainer as a beast-tamer.
- **Darkest Dungeon** is a Western gothic roguelike, not the genre, so it cannot invade; its
  dread is the register the bible gives the Arsenal (section 1) and the Convergence's last tier.
- **The genre's other subgenres**: the Mystery Dungeon roguelikes (Shiren the Wanderer,
  Torneko's Great Adventure), the genre's own roguelike and Riftgate's nearest cousin, whose
  Torneko is the Merchant on the Waste's bench; the monster-collectors (Pokémon, Dragon Quest
  Monsters), the Tamer; the action RPGs, Mana's Rabite for the Meadow's wildlife and Kingdom
  Hearts' Guard Armor as another boss in parts; the dungeon crawlers, whose Etrian Odyssey
  FOEs (visible monsters far stronger than the floor, roaming the map) are already our hunters,
  so a lone big elite that hunts is the homage with no new system. The tactics games give the
  foes little: Disgaea's Prinnies are comic and Final Fantasy Tactics' Lucavi are demons.

## Beyond the twelve

- **Omega** (Ryan, 15 October: pretty sold on it, but where it lives is open; noted, not now):
  the genre's superboss, the bible's pinned slot (an optional fight past the Rupture, never the
  finale) the first home to weigh; the one machine the genre brings, painted flat like every
  foe, beside Ryan's pinned Arsenal superweapon.
- **The Summoner's summons** (Ryan, 15 October: yes, with names that are not the series' own;
  then full Norse): in content since that day, each a move, from the Norse world its rune circle
  opens on (its robes are stitched with runes). Surtr (the fire giant, in Ifrit's place; Ryan: a
  perfect replacement; his note of 18 October on the first takes: made of fire rather than on fire, so the fourth round draws a body that is itself flame over a core of slag): Pyroclasm, every machine scorched, below half. Ifrit's own move is
  Hellfire (Ryan asked, 16 October). It was the Summoner's until 13 October, when it became
  Pyroclasm: the bible gives hell's words to the Council's side and pins Hellfire as an Arsenal
  prefix (the King James Bible's), and Surtr's fire is Muspelheim's, not Hel's. If the move
  should carry the homage as Diamond Dust does, Surtr could take Hellfire and the Arsenal's
  prefix Brimstone, the same Bible's other fire; Ryan, 16 October: Pyroclasm stays. Skaði (the winter
  giantess, in Shiva's place; Ryan: for sure), a huntress in white furs and an iron helm, her look
  far from Shiva's: Diamond Dust (Ryan: fine), a frostbite on the component every machine shows
  (corrupt all), soft rather than a freeze that switches components off, since freezing every
  machine at once would be the hardest control in the game. Fáfnir (the sagas' wyrm on its
  cursed gold, in Bahamut's place; Ryan's suggestion): the promoted form's one move more, waiting
  on the promoted forms, drawn as the sagas tell it, a wingless serpent whose breath is venom,
  so neither its look nor its blow is Bahamut's. Art in the forge's drafts (the third round on
  the picker), and the screen's moment for each summon to appear is still to come. Fáfnir is picked and cut (Ryan, 18 October: the head and upper section of the
  first take, the gold hoard taken off by the edit model); Skaði's pick waits on her lower-hand
  weapon reading (a bow failed twice; a third round offers the bow again and a hunting spear);
  Surtr's on a head that is not a skull (his pick of the fire-bodied takes, 3, redrawn: the
  edit model and a freer pass took the skull off, his pick 5 the crowned head of fire; 19 October,
  his two worries, the head's definition when shrunk and a sword that seems to grow from the arm,
  through the edit model and a close pass). Skaði's lowered hand has had a bow, a spear and
  knives drawn into it over three rounds without one reading; the fourth empties the hand and
  slings the bow on her back, and lands (Ryan, 19 October: the fresh take 4 great from the waist
  up, the pose and the bow; the edit's 1 best below the waist, trousers, a longer tabard, thigh furs
  and its boots, and its gloves), so the fifth dresses 4's lower half as 1's through the edit
  model. Surtr's fourth round "busted the sword more" (a face-and-sword edit in one instruction),
  so the fifth asked for the sword alone on his pick 5: a crossguard and pommel between fist and blade;
  it drew the grip right and lost the blade (Ryan: none of these have a blade at all; 1 holds the hilt
  and crossguard correctly), so the sixth adds a blade of fire to 1's grip, the edit model and a pass
  at 0.6 side by side: the edit model landed it (two candidates, a blade of flame from the held
  crossguard, on the picker) and the pass at 0.6 lost the blade again (set aside), the colour
  rule of the fix-order row holding for an added glow. Ryan on it (19 October): "so close", 2
  picked, its blade to turn clockwise about five degrees and move right onto the line of the
  grip. The seventh does that by hand (the blade cut by its mask, turned five degrees about its
  base and moved onto the grip's line, the hand edit the layout for a close pass at 0.9, never
  shown raw): the pass drew the blade on the grip's line and joined to the crossguard, but
  redrew his head a little, so the sword's column alone is pasted back onto his pick (the two
  aligned, the seam in white and in the fist both share), shown beside the full pass; Ryan's
  pick (26 October) the pasted column (bossart10 5), cut into `art/foes` with his white-hot
  blade and the blaze round his face kept by the cut (`--keep-glow`, since they are the
  background's white) and recorded in picks.json: Surtr is done. Skaði is picked and cut (19
  October: the fifth round's 1, the fresh-take pose with the edit's lower half).
- **Clair Obscur's Mime**, if wanted beside Floraison: a rare pack that throws the last blow it
  took back at whoever dealt it (the bible's pinned reflect), its plaque blank, a livery its
  prize.

## Questions for Ryan

- The calls still open (above): Gilgamesh, the swallow's release, the escorts, more massive
  foes, a boss's armour by the tier.
- The conversions above; where Omega lives; the Mime.

## Bench

The ideas set aside, each with what set it aside.

- Sephiroth, the Paintress, Lavos, Giygas: a story's final boss (Ryan, 15 October).
- The Reaper running the party down on the map: a boss's mechanics stay inside the skirmish.
- The Goblin Warlord, the Drowned King, the Charnel Heap, the Sand Scorpion, the Mother Gel, the
  Great Needler: generic tropes or the wildlife grown big, so elites if anything (the first
  slate).
- Phoenix: getting back up is the Marsh's signature, and Neclord's (Ryan, 15 October, of the
  Drowned King then).
- Elder Drake: somewhat uninspired (Ryan, 15 October); and another dragon.
- Ifrit as a boss, and the other summons (Titan, Leviathan, Ramuh, Odin): a summon is the
  Summoner's.
- Yuki-onna in Shiva's place: her look, a beautiful woman of ice, the nearest of any to Shiva's;
  and the Cailleach, Morana and Boreas: the set went full Norse (Ryan, 15 October).
- The Dragon King, the plain title, and Ryūjin: Fáfnir in Bahamut's place (Ryan's suggestion),
  the set full Norse.
- Bouton, gemme, Nepenthes, Calyx and the Craw for Bourgeon's name: Floraison (Ryan, 15 October).
  Calice (the calyx): in Québec it is an oath.
- Wings on Fáfnir (Ryan, 15 October: some later depictions give him wings, so allowed if
  wanted): the roster's two other dragons are winged (the Bone Wyvern, the Drake), so the
  wingless wyrm is the silhouette a phone tells apart, and the move's name can carry Bahamut.
- Giga Gaia: a golem beside the Peak's Magma Golem (now the Magma Elemental); its parts live on in the parts pattern.
- Retinite: a sidequest boss rather than a who's-who name; its pattern stays (the parts, Ryan,
  15 October), carried by Exor.
- A colossal flail for the Exor homage, its chain up into the rift (Claude's pitch, for an outline
  unlike a weapon standing in the ground): Ryan, 15 October, a hammer or an axe is distinct enough.
- Darkest Dungeon: not the genre (above).
- Bomb King: waits on the Bomb's verdict in play.
- Fire Emblem's weapon triangle: the bible refuses a damage-type triangle (section 9).
- Shin Megami Tensei's demons (Jack Frost, Pyro Jack): demons are the Arsenal's register
  (section 1).
- Clair Obscur's parry and dodge: real-time timing, against an exact preview and a phone's
  thumbs.
- SaGa's glimmer (a technique learned mid-fight): components are never modified (section 10).
