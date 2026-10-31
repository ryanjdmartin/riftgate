# The bosses and elites: a proposal

The roster's tiers are decided (Ryan, 15 October; the bible's section 9, "The roster comes in
tiers"): tropes for the rank and file and its elites, the genre's iconic bosses three a domain,
the genre's heroes as the finals, big as an attribute of any tier, and a boss's mechanics kept
inside the skirmish. This file holds what fills the elite and boss tiers until Ryan has marked
it all; then its picks become content and bible rows, and it retires (git keeps it). Names are
working names, and everything here is Ryan's to move.

Seven of the twelve landed 30 October as runnable placeholder kits on Ryan's word ("build what
can be built, and specify exactly what you need to flesh the rest out, including any holes"):
every boss he marked in, the Adamantoise he marked probably, and Gilgamesh on Claude's lean.
Their kits are in `content/foes.json`; what landed, what each waiting boss needs and the calls
on what landed are below the slate.

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
| The Marsh | Bone Wyvern | Massive | Built, standing in as the boss; an elite unless a better setup comes (Ryan, 24 October) |
| The Marsh | The Reaper (Persona's chained one among many: every JRPG has a reaper, Ryan) | Not massive | Ryan, 15 October: in, a trope by the tiers' own test, so an elite that can turn up in many fights, leaving the boss slot to the Matador; 24 October: the deadly hunter elite. Art picked and cut 18 October (image to image from his first pick, its third hand gone) |
| The Marsh | The Coven: three hags, each unique (a triple trope: Macbeth's Weird Sisters, the Graeae sharing one eye; the genre's own are Final Fantasy IV's Magus Sisters) | Not massive | Noted for later (Ryan, 15 October: not yet) |
| Any | A pair of gate gargoyles (a pair trope) | Not massive | Noted for later (Ryan, 15 October: not yet) |

Out of the tier (Ryan, 23 and 24 October): the Treant, the Magma Elemental (the Magma Golem
until 23 October: a golem implies a master) and the Sandworm are rank and file, massive. Each
stands as its domain's last boss until the slate gives the domain three of its own (30 October),
then joins its domain's compositions (a massive foe may stand in one since 24 October).

## Bosses: the slate (third cut, 15 October)

Each brings its signature move, inside the skirmish.

The boss in parts is a pattern worth including whoever carries it (Ryan, 15 October): parts that
regrow, or stand for a while, until the core is killed, so the player chooses what to focus.
Two fists and a head (Chrono Trigger's Giga Gaia), Retinite's core, Exor's hilt. In the engine:
the core massive in its column, its parts separate foes in the next ones, regrowing while the core
stands or shielding it until one falls.

| Domain | Boss | From | Its signature | Engine |
|---|---|---|---|---|
| The Meadow | King Slime | Dragon Quest | When enough Gels stand on the field they merge into the king: thin them first | A merge (new) |
| The Meadow | A Malboro (working name Rotbloom) | Final Fantasy | Bad Breath: a blow at every machine carrying every rider at once; cleanse is the answer | Landed 30 October as Rotbloom |
| The Meadow | Floraison (Ryan's name, 15 October: the flowering; Bourgeon, French for a branch's bud, is its game's own). Its shape is humanoid (Ryan, 18 October, of the first takes: none matched; a humanoid body with the round thorn-rimmed maw of take 1 for a face), the fourth round of takes; his pick of it (4), redrawn less muscular, lanky as a sapling, for the fifth; his pick of that (2) wanted 1's eyeless maw (19 October), so the sixth is the edit model on 2 (the eyes inside the mouth removed) beside a composite of 1's head onto 2 re-rendered close; his pick of that (3, the composite) lost spines and vines on the head's left where the paste box clipped, so the seventh completed them (the edit model, and the composite redone wider), which did not work either (Ryan, 19 October: "maybe go back and try the head-swap compositing again"); the eighth is the composite of 1's head onto 2 again, a generous box, shown raw and after a close pass at 0.9: the spines and vines complete at last, all three clean to Claude's eye; Ryan (19 October): still weird even at phone scale, cut off or blurred by turns, is there another way? The ninth round is another way: the two eyes inside the maw painted out with the maw's own black on his pick itself (an erase over dark, as an erase over white is the one hand edit that has passed his bar; nothing re-rendered, so nothing blurs), beside image to image from his pick at 0.7 with the maw described eyeless (0.8 kept the eyes, set aside); Ryan's pick (26 October) the paint-out (bossart10 1), cut into `art/foes` and recorded in picks.json: Floraison is done | Clair Obscur | Swallows a machine, out of the fight for a few rounds; three- and five-hit combos. Its game's miasma would repeat the Rotbloom's Bad Breath in the same domain, so the swallow and the combos are its own (Ryan, 15 October: agreed; the third round's takes show the swallow and the vines); the swallow is hard control, weighed first (the bible's stun row). The game places one in its Meadows | A swallow, built; landed 30 October |
| The Waste | Gilgamesh | Final Fantasy V | Takes the weapon a machine shows and fights with it; now and then the piece it took is a fake | A steal of the showing entry and a borrowed swing, built; landed 30 October |
| The Waste | A Tonberry (working name Pilgrim) | Final Fantasy | Creeps closer, its countdown shown, then the knife; Everyone's Grudge grows with every foe the team has killed and passes the shield. Ryan hates it, which may be the point: keep the dread, drop the unfairness (its games kill outright; here the countdown is shown) | A countdown (the delayed blow, held longer) and a blow that grows with the team's kills |
| The Waste | An Exor homage | Super Mario RPG | The parts boss: a colossal weapon fallen into the badlands, its eyes shielding the core that drives them, the core untouchable until a part falls. Ryan, 15 October: in, distinct from its game's look, and a hammer or an axe is distinct enough; 18 October, by his pick on the picker: the double-bitted axe standing haft-down, an eye in each blade, cut. The two bits are the parts, a mirrored pair whose blows differ by the eye that drives them (Claude's lean, to propose with its kit: one bit's blow passes the shield, the other's prises loose the component a machine shows, the Waste's two halves), the haft the core | The parts; landed 30 October as the Fallen Weapon |
| The Marsh | The Phantom Train | Final Fantasy VI | Runs a machine down; its whistle calls the dead aboard (Ghosts into the pool) | Runs today |
| The Marsh | Neclord | Suikoden | Drinks what it deals, and gets back up once | A drain (new); getting back up runs today |
| The Marsh | The Matador | Shin Megami Tensei III | Red Capote: hardens for a round, then Andalucia, a flurry of strikes. Ryan, 15 October: in, the legacy pick; the Reaper goes to the elites. Art: his pick of 18 October (the flourish, 4) lacks the hand on the arm bent across his chest; an added arm and a cape grip through the edit model both missed, so the third round was image to image from the pick, as he asked, and landed the hand; his pick of it (3) wanted 2's head and boots (19 October), so the fourth round was the edit model on 3 (red eye sockets, shoes under the greaves) beside a composite of 2's head and shoes onto 3 re-rendered close (image to image at 0.8), the first composite tried since hand edits failed in October; his pick of that (2, the edit) wanted 3's bolder jaw and nose bone, and the fifth round's edit of the skull was "way too much, full of artifacts" (Ryan, 19 October), so the sixth is a composite of 3's skull onto 2, the two aligned siblings, shown raw and after a close pass at 0.9: the jaw and nose bone carried over clean, no artifacts; Ryan's pick (19 October) the second close pass (fixhand6 3), cut into `art/foes` and recorded in picks.json: the Matador is done | Landed 30 October, its cape and flurry a follow-up (built) |
| The Peak | The Behemoth | Final Fantasy | Meteor on every machine as it dies: shield up, then kill it | A last act; landed 30 October |
| The Peak | The Adamantoise | Final Fantasy | Withdraws into its shell (armour up, so that round's blows are wasted), then Earthquake on every machine | Landed 30 October as the Cinder Tortoise, its shell and quake a follow-up |
| The Peak | Black Tyrano | Chrono Trigger | Azala rides it, the brain: while she stands it is armoured; once she falls it counts down from five and breathes fire on every machine at zero | A countdown (the delayed blow); armour while an ally stands |

Six of the twelve are Final Fantasy's and six come from six other series.

## What landed (30 October)

The kits are placeholders for Ryan's marks, every number too; each boss carries three moves,
the third opening on a condition or following another, and a point of armour (the set of 2
October). The engine pieces built for them run on any foe: a follow-up (a move that names the
move its foe announces next round), a steal with its borrowed swing, and a swallow.

| Domain | Boss | Its kit | Claude's leans inside it |
|---|---|---|---|
| The Meadow | Rotbloom | Tendrils, two strikes; Bad Breath at every machine, carrying Burn, Scorch, Disable and Corrupt; below half, Seedfall, two mandragoras called up | The third move and its name |
| The Meadow | Floraison | Thorn Combo, three strikes; Swallow, a machine out of the fight for two rounds or until Floraison falls; below half, Full Bloom, five strikes | Two rounds; never the last machine able to act; no damage while held; only the kill frees it early |
| The Waste | Gilgamesh | Blade; Disarm, a blow that takes the entry the machine shows, then Borrowed Blade, that weapon's number, or a fake for 1 | The fake as anything that was no weapon; one strike at the piece's number, no keyword riding it |
| The Waste | The Fallen Weapon | The core: Haft; Drive, a rally; below half, The Fall, every machine two rounds on. Two eyes as parts, the Piercing Eye (breach) and the Prising Eye (disable); the core Guarded while both stand, an eye back three rounds after it falls | One eye down opens the core (guard all); the eyes' blows; the eyes drawn as the placeholder shape |
| The Marsh | The Matador | Estocada; Red Capote, armour +3, then Andalucia, four strikes at one machine | A Suppress or a Disrupt on the cape breaks the pair |
| The Peak | Behemoth | Gore; Flame, Scorch 2; below half, Charge, a round's warning, through the shield; Meteor on every machine as it falls | The Flame and the Charge |
| The Peak | Cinder Tortoise | Bite; Withdraw, armour +3 on its own 2, then Earthquake on every machine, Scorch 1 | In at Ryan's probably |

Each domain keeps its old massive stand-in as its last boss while it has fewer than three of the
slate's: the Meadow draws from Rotbloom, Floraison and the Treant, the Waste from Gilgamesh, the
Fallen Weapon and the Sandworm, the Marsh from the Matador and the Bone Wyvern, the Peak from the
Behemoth, the Cinder Tortoise and the Magma Elemental.

The slate lands at 48 HP at tier one, the boss in parts' core at 40 and its eyes at 8, under
the scale row's 80 to 100 (the bible's section 11): at 80 the default team took 7 to 13 rounds
against each boss alone and a stock four 11 to 22, where the kill-time test asks three to five; at
48 the default team takes 4 to 7 (`docs/measurements.md`, 30 October, 30 seeds, a direction).

## What each waiting boss needs

The Marsh needs two of its three waiting marks to reach three bosses of its own; the Meadow, the
Waste and the Peak one each. Each line is Claude's kit for a yes, so a mark lands it.

- **King Slime** (the Meadow; the King Gel by name): a mark, and the merge's shape. Lean: the
  King Gel stands from the fight's start with Gels round it, and a special pulls every Gel and
  half on the field into it, healing it by what they had left and lifting its blow, so thinning
  the Gels first is the answer (new: a merge). The other shape, the king forming mid-fight from
  Gels standing together, leaves the boss off the field at its own reveal.
- **The Pilgrim** (the Waste; the Tonberry): Ryan's call. Lean: a knife on a countdown of two,
  through the shield, and Everyone's Grudge, a blow a point heavier for every foe the team has
  killed this fight, through the shield (new: a blow that reads the team's kills). Keep the dread,
  drop the unfairness: the countdown shown is the fairness. If Gilgamesh moves to the elites, the
  Pilgrim fills his slot.
- **The Phantom Train** (the Marsh; or a ghost ship, the Flying Dutchman): a mark. Runs today:
  Run Down, a heavy blow; Whistle, two Ghosts called up; below half, a run at every machine on a
  countdown of one. No art yet.
- **Neclord** (the Marsh; Suikoden's coinage, so a name of ours): a mark and a name. Lean: a blow
  that heals what it deals (new: a drain), Getting Back Up once (runs today), and below half a
  drain at every machine.
- **Black Tyrano** (the Peak; Chrono Trigger's coinage, so a name of ours): a mark and a name.
  Lean, nearly all running today: its rider a part, the beast Guarded while she stands, and once
  she falls a countdown from five to fire on every machine (new: a condition reading a fallen
  part).

## Calls on what landed

1. Gilgamesh as a boss or an elite (Ryan, 24 October: tempted, since he can pop up anywhere).
2. The Cinder Tortoise in or out, and its name: the Cinder Tortoise or Zaratan.
3. Names: Rotbloom, the Fallen Weapon and its Piercing and Prising Eyes are working names.
4. The swallow: two rounds, the kill the only early way out, no damage while held. The option on
   the table: a blow's worth of damage on Floraison frees its machine, an answer after it lands.
5. The steal's fake as anything that was no weapon, so what the die shows is a decision when he
   comes for it.
6. The follow-up: a Suppress or a Disrupt on the first move breaks the pair; the other reading is
   that the follow-up comes anyway.
7. Escorts: the tier's units round robin today; a hand-tailored escort per boss (the hook is
   built) wants Ryan's marks.
8. The stand-ins as each domain's last boss until it has three of its own (built), or into the
   compositions now, leaving the Marsh one boss.
9. The bosses' size: 48 at tier one (above), or the scale row's 80 to 100 kept and the kill-time
   test read on built teams instead.

## Art the forge owes

Rotbloom, Gilgamesh and the Fallen Weapon's two eyes have briefs in their entries'
`design.sprite` and `design.variants`, and are drawn as the placeholder shape until a render is
picked. The forge's `generate` and `fix` have had no machine since the Mac went out of reach (the
status's Start here), so these wait on the route for the image model Ryan chooses. Meanwhile the
eyes could be cut from the axe he picked, the core then drawn as the haft alone, which needs no
model.

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

- Marks on the five waiting bosses, and the calls on what landed (above).
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
