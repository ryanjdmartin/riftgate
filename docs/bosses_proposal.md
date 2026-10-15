# The bosses: a proposal

Each domain needs three distinct bosses before its hero, drawn without repeats (the bible's
section 9, "Three bosses beaten"), so the game needs twelve; four exist. The 9 October pitch
never reached the records, so this file holds the slate until Ryan has marked all of it; then
its picks become content and bible rows, and the file retires (git keeps it). Names are
working names, and everything here is Ryan's to move.

## Ryan's direction (15 October, under discussion)

- The rank and file are the genre's tropes (goblins, skeletons, ghosts, drakes, slimes,
  wolves): what exists, tweaked.
- Size is not boss-ness: a large foe can be an elite, a pack of one. This is a lost line: the
  bible said "A massive elite may occupy both rank slots of a column" until its 10 October
  rewrite, and the 9 October domains made each boss "the massive wildlife". The Treant and the
  Sandworm read as elites, tropes rather than bosses.
- The finals (the heroes) are homages to the genre's heroes, spread beyond Final Fantasy (the
  Thief as Persona 5's Joker with a gun, perhaps); the benched ideas in the same vein.
- The sub-bosses, three a domain, are a who's who of the genre's iconic bosses, without their
  mechanics for now (the Reaper chasing the party), and never a story's final boss (no
  Sephiroth, no Paintress, no Lavos).

Claude's holes, in chat the same day:

1. By the test, the Bone Wyvern and the Magma Golem are tropes too: all four built bosses
   become elites, their art carried over, and all twelve sub-bosses are new. The Golem is then
   the lava field's elite, which settles the Summoner.
2. The genre's signature monsters (the Behemoth, the Malboro, the Tonberry, the Adamantoise)
   are field monsters in their own games, neither tropes nor bosses: elites if big, wildlife if
   small (as the Bomb and the Needler are). The sub-bosses are named bosses: the Phantom Train,
   Giga Gaia, Ultros, Gilgamesh, the Matador.
3. A boss is recognised by its signature move as much as its look: it brings the move when our
   vocabulary has it (Meteor a blow at every machine, Bad Breath every rider at once), and
   anything needing a system of its own waits (the chase, a countdown, a merge, a reflect).
4. The no-final rule also cuts Giygas; Omega (optional) and Gilgamesh (a mid-game rival) pass.
   Clair Obscur's homage is then the Mime or a mid-game boss (the Axons, Sirène and Visages, or
   Évêque, whose Spring Meadows is the Meadow).
5. Size decouples both ways: a sub-boss may be human-sized (Gilgamesh, the Matador). The engine
   assumes otherwise in three places: the validator refuses a boss that is not massive
   (`sim/content_db.gd`), the plaque takes any massive foe's blow for a boss's
   (`Skirmish._damage_mech`), and the engine's `elite` means the boss pack (`Unit.elite`), a
   rename before real elites exist.
6. Joker: a gun overlaps the Gunslinger on the same bench, his signature is the calling card (a
   warning a turn ahead, as every intent already is), and the Thief's art was just finished.

The slate below predates this direction; it is re-cut by tier once Ryan answers.

## Standing

| Domain | Boss | State |
|---|---|---|
| The Meadow | Treant | built |
| The Waste | Sandworm | built |
| The Marsh | Bone Wyvern | built |
| The Peak | Magma Golem | built; the Summoner's (Ryan, 15 October), reopened by Ifrit (below) |

The Treant and the Bone Wyvern share a kit (one big hit, a heal, a three-blow storm at
anything), so each new boss carries its own idea.

## Ryan's calls (15 October)

- Any Final Fantasy homage is probably incomplete without Bahamut, the Behemoth and Omega;
  Ifrit and Shiva are next in line for most common.
- If the reference is the genre's summoner, the Summoner calls Ifrit.
- The Peak: the Cinder Tortoise in, the Adamantoise being more ubiquitous than the Fire Naga;
  the Phoenix and the Elder Drake out (the bench).
- The Mother Gel and the Great Needler are fine, but easy cuts for something more interesting.

## Where the five go (Claude's proposal)

- **Ifrit, Shiva and Bahamut are the Summoner's.** In its final it calls Ifrit and Shiva, each
  a move: a blow at every machine with its own rider. Ifrit's Pyroclasm scorches; Shiva's
  Diamond Dust freezes the entry each machine shows (Disable). Promoted at the finale, its one
  move more (the bible's promoted form) is Bahamut's Mega Flare, the one that hurts. Summons as
  moves rather than companions: three massive companions could not stand in two ranks of four
  with the wildlife, three moves can, and it keeps the Summoner apart from the Tamer and the
  Necromancer, who call things into the fight every round. The answer is the back rank: reach
  the Summoner, Suppress it or Disrupt it, or shield every machine. Every foe move is announced
  a turn ahead, so they run on today's engine; the new work is their art and a moment on
  screen for each to appear. The trade: they are seen only in runs that deal the Summoner.
- **The Behemoth is a Peak boss**: Meteor at every machine as it dies (King Behemoth), so the
  kill is the telegraph: shield up, then kill it. A blow on death is a small engine piece beside
  the Gel's split; a Meteor below half runs today. The Nemesis's Meteor Artillery shares the word.
- **Omega is the genre's superboss**, the bible's pinned slot (an optional fight past the
  Rupture, never the finale). It is a machine, the one the genre brings, so it stays the only
  one (the benches keep robots off but one late wildcard); painted flat like every foe, the
  genre's idea of a machine against ours. It sits beside Ryan's pinned secret final boss, the
  Arsenal's superweapon: a superweapon a side.

Names: Bahamut, the Behemoth, Ifrit and Omega come from folklore, scripture and the alphabet,
so the names are free and the looks are ours, never the series' designs; Ifrit is a spirit of
fire, never a demon (the demonic is the Arsenal's, section 1). Shiva is the name of a living
god, Hinduism's, which the series borrowed for its ice maiden, and games that used Hindu gods
have drawn complaints; Diamond Dust carries the homage on its own, so the summon could take a
name of ours. The Summoner's circles stay deep violet: the fire and the ice are the summons'.

If the Summoner calls Ifrit, the Golem is no longer its identity, so the reason to replace it
as the Peak's boss goes. If it stays, it and the Tortoise are both slow lava heavies that erupt
below half: one of them changes its job (the Tortoise's could be its shell alone, the eruption
left to the Golem, or the Golem's kit could become Chrono Trigger's, below).

## Homages from the rest of the genre (pitched 15 October)

Ryan asked what other classic JRPGs could give, and for a Clair Obscur: Expedition 33 homage
somewhere, retrograded to the sixteen-bit register (it is modern, but held as the genre's
pinnacle). Each fills a slot the records already hold open.

| Homage | From | Slot | What it asks of the player | Engine |
|---|---|---|---|---|
| A boss in parts | Chrono Trigger (Giga Gaia's hands on Mt. Woe, Mother Brain's screens) | The Golem's kit, if it stays: its fists stand in the next columns, one healing the body, one guarding it | Kill order across the parts, on our two ranks of four | The White Mage's cure and harden on allies (the to-do); new art for the hands |
| The Reaper | Persona (it comes for a party that lingers on a floor) | The forced boss the bible leaves open as turtling's backstop (section 4) | A battle that drags brings it out of the rift, far stronger than anything, heard coming a few turns ahead: the clock is a creature | A pack and its trigger; the warning is the rule (never helpless) |
| The King Slime merge | Dragon Quest (eight slimes become the king) | The Meadow, if a slime boss stays | The swarm becomes the boss unless it is thinned first | A merge: so many of a kind on the field become one |
| The ungraspable attack | EarthBound (Giygas) | The Lovecraftian dial at the Convergence's last tier (section 9) | The plaque reads "You cannot grasp the true form of its attack!" while the intent still shows the exact number | None beyond the foe; the name is the game's coinage, so ours |
| Gilgamesh | Final Fantasy V (banished into the rift between worlds, he turns up across the series) | A rival of no domain, the premise made a character | Appears in any domain's battle, fights, flees and returns stronger; once with a fake sword (Excalipoor) | The flee (the to-do), and a rule for a foe of no domain; the name is the epic's, free |
| The Paintress | Clair Obscur (she paints a number, and everyone of that age is erased, the Gommage) | A second superboss beside Omega (the fifth game had two), or her monolith as the face of the Convergence's count | Each round she paints a number; at the round's end every machine's showing entry with that number cracks, and the number drops: the reroll is the answer | A move that reads the dice (foes' interrupts attack the die, section 9) |
| The Mime | Clair Obscur (silent duellists hidden in every area, dropping cosmetics) | A rare pack on the map, beside the Gold Bug and the Mimic (the to-do) | It mimes the last blow it took back at whoever dealt it (the deterministic reflect pinned in section 5); its plaque stays blank, since a mime has no lines; beating it unlocks a livery | A mirror blow |

Retrograding Clair Obscur suits the register: the foes are painted already, and a painter whose
world is a painting is the invasion's own medium. Several benches already read as homages to
other series: the Psychic (EarthBound), the Dragon Heir (Breath of Fire), the Gunslinger (Wild
ARMs), the Tamer (Dragon Quest V).

## The slate

| Domain | Boss | What it asks of the player | Engine | Ryan |
|---|---|---|---|---|
| The Meadow | Goblin Warlord (his marked goblin take 4 at boss size) | Every goblin hits harder each round and more come: the leader or the swarm first? | Runs today | |
| The Meadow | Rotbloom (a Malboro homage), for the Mother Gel | Bad Breath: a blow at every machine carrying every rider at once (scorch, burn, disable, corrupt); the riders are the threat and cleanse the answer | Runs today | |
| The Waste | Sand Scorpion | Its pincers ruin the component a machine shows, its sting turns that weapon to stone: redundancy on the die | Runs today | |
| The Waste | Pilgrim (a Tonberry homage), for the Great Needler | Shuffles closer, its intent counting down, then Everyone's Grudge: a blow that grows with every foe the team has killed and passes the shield, the Waste's fixed damage | Needs a countdown (the delayed blow, held longer) and a blow that grows with the team's kills; the Onryō's Grudge shares the word | |
| The Marsh | Drowned King | Makes the dead hit harder and gets back up once: kill the king, twice | Runs today | |
| The Marsh | Charnel Heap | Falls apart into revenants when killed, so the kill is not the end | Runs today | |
| The Peak | Cinder Tortoise (the Adamantoise) | Withdraws into its shell, so hitting it that round is wasted; below half the volcano on its back erupts at every machine | Runs today | In |
| The Peak | Behemoth | Meteor at every machine as it dies: shield up, then kill | A blow on death (small); runs today as a Meteor below half | |
| The Peak | Magma Golem, if it stays; else the Fire Naga | The Naga (the first game's Marilith): six strikes at the hottest machine, each its own blow; a lure onto a cold machine | Runs today | |

The Malboro and the Tonberry are the series' own coinages, so they take names of ours, as the
Cactuar became the Needler.

## Bench

The ideas set aside, each with what set it aside.

- Phoenix: it rises once from its ashes, the Drowned King's move and the Marsh's signature
  (Ryan, 15 October).
- Elder Drake: somewhat uninspired (Ryan, 15 October); it would also have been the third
  dragon, after the Drake and the Bone Wyvern.
- Ifrit as a boss: it is a summon, so it is the Summoner's (Ryan, 15 October).
- The other summons (Titan, Leviathan, Ramuh, Odin) as domain bosses, the way some games make
  the party fight one to earn it: it blurs "a summon is the Summoner's".
- Mother Gel and Great Needler: easy cuts for something more interesting (Ryan, 15 October),
  if the Rotbloom and the Pilgrim land.
- Bomb King: waits on the Bomb's verdict in play.
- Red Dragon: another dragon.
- Fire Emblem's weapon triangle: the bible refuses a damage-type triangle (section 9).
- Shin Megami Tensei's demons (Jack Frost, Pyro Jack): demons are the Arsenal's register
  (section 1), though Jack Frost's name is folklore's if an imp is ever wanted.
- Clair Obscur's parry and dodge: real-time timing, against an exact preview and a phone's
  thumbs.
- SaGa's glimmer (a technique learned mid-fight): components are never modified (section 10).

## Questions for Ryan

- The five's homes: Ifrit, Shiva and Bahamut as the Summoner's moves, the Behemoth at the
  Peak, Omega as the superboss?
- Shiva's name, or one of ours?
- The Peak's third: the Golem kept (the Tortoise then its shell alone) or the Fire Naga?
- The Rotbloom for the Mother Gel and the Pilgrim for the Great Needler?
- Which of the genre's homages earn their engine piece, and the Clair Obscur one: the Paintress,
  the Mime, or both?
