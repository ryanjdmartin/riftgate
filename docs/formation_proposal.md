# The formation pass: a proposal

What is left of the formation pass, which landed on 10 November: its grids are
`content/factions.json`. Live: section 6, the bosses as fixed entries by tier and ramp, a
session of their own on Ryan's go; section 13, the flankers' slate as it landed, with its
holes and bench; section 10, the ideas the pass's rules kill. Every other section is a stub.

Cut down on 17 November from 991 lines. The long form, with every grid and read of the first
cut, is `git show cc446826:docs/formation_proposal.md`, a stub's text under the same section
number. The roles are the refit brief's section 4 (`docs/briefs/refit_pass.md`), the numbers
`docs/briefs/numbers_pass.md`, and every run named here is in `docs/measurements.md`.

## 0. Since the proposal (9 November, the same day)

A stub: what moved between the first cut and the landing, each a bible row now. The bombs
never hunt (the hunters row). A unit is made for a battlefield role, the goblin's line stabs
straight behind its Shield Wall, and a formation is read with a heavier machine among its
three (the Foe roles row). A pusher is measured by hull lost at its rating, never a win band.

## 1. What Ryan said, and when

A stub: his words of 5 to 9 November that set the pass, each in its bible row. Packs as
designed formations with the threat rating shown, a true four for elites and bosses, the cut
at eight slots (the pack row). Compositions as discrete variants gated by tier and ramp (the
ramp row). The hunt the composition's, the hunters a soft wrench rated two at least, none on
the field at turn one (the hunters row). The bosses as fixed entries (section 6). One line
the rows lack, of 8 November: a composition is its grid, "Fix the comps so they make simple
sense".

## 2. What the records already say

A stub: the schema, the dealing and the reads as they stood on 9 November. Today's are
`content/factions.json`'s `_about` and `docs/rules.md` (Content conventions; The battlefield).

## 3. The rules the grids follow

A stub: the eleven rules of the first cut. Those that stand are in content and the validator:
one question a composition (`design.question`, required on every patrol and formation), the
grid carrying it, an anchor and a swarm, eight the ceiling, hunters as heavy patrols rated two
and no formation hunting, the ramp's bands at the ramp's own steps. Rule 5's free mixing of
members and rule 8's rating by who solos gave way to the roles (the Foe roles row).

## 4. The two hunter questions (the bible's section 12)

A stub: both answered and built. Who hunts: six patrols rated two (the wolf, warg and alpha
packs; the antlion trio, the pit pair and the queen's hunt) and six elites. No formation
hunts, and the bombs push on his word of 9 November. Who keeps hunters off the field at turn
one: `Battle.setup` places the opening's patrols from those that do not hunt. The bible's
hunters row holds his words.

## 5. The ramp gates and the pruning, from the reads

A stub: sixty compositions grown to ninety-two candidates and pruned to eighty by the curve
read of 9 November, on the model before the refit. The gates that landed are each
composition's `ramp` in content, and its patrols rated one were rewritten as the duelists
(section 13). Its bands are no read of today's game: the baseline is the numbers brief's.

## 6. The bosses as fixed entries by tier and ramp

Open, his, and built only on his go, in a session of its own. Ryan, 7 November: "a boss'
tiered and ramped stats and escorts should be split into seperate fixed entries, same as a
pack's would"; "Don't curate the bosses now, that can wait." The bible's boss row holds the
decision. This is the form proposed for it, his to move.

Today a boss rides a multiplier (`ContentDB.BOSS_TIERS`): its hit points as written at tier
one, by 1.1 at tier two and by 1.25 at tier three; its attack as written, one more and two
more. An elite, a final's hero and the finale's line ride the same, and a foe whose kit is
armour grows it by its `armour_step` a tier (the Cinder Tortoise, an elite: 1, 2 and 3).

- **Stat blocks on the boss's entry**, in `content/foes.json`: `tiers`, a list of fixed
  entries `{"tier": t, "ramp": [lo, hi], "hp": n, "attack": n, "armour": n}`, the ramp
  optional as a composition's is, a tier's blocks together holding every Convergence from the
  tier's first to 12. The engine takes the block whose tier and ramp hold, in place of the
  multiplier and the armour step; an entry with no blocks rides the multiplier until he marks
  it. The boss stays one named entity at every tier: a recolour is a new unit, never a boss.
- **The escort stays an `escort` composition**, curated by tier as today and never grown,
  with a ramp band when wanted. A part's numbers ride its core's block (the Ruby Colossus's
  tentacles, the Fallen Weapon's eyes, the Obsidian Tyrant's Saurian Queen).
- **A final's wildlife** is the one escort no composition names: the domain's units of the
  tier, round robin (`ContentDB.escort_units`). It becomes a named `escort` composition a
  domain and tier in the same pass, naming no boss, so a final's fight is authored too.

Today's numbers as the first entries, the multiplier made explicit, each a placeholder: hit
points, attack and armour. A move's blow is the attack by the move's factor.

| Boss | Domain | Tier 1 | Tier 2 | Tier 3 | Escort today (tier 1 / 2 / 3) |
|---|---|---|---|---|---|
| Floraison | The Meadow | 72 / 10 / 0 | 79 / 11 / 0 | 90 / 12 / 0 | alone / two Wargs / two Alpha Wargs, a Guard, a Captain |
| The King Gel | The Meadow | 72 / 15 / 0 | 79 / 16 / 0 | 90 / 17 / 0 | three Gels / two Gels, a Bubble Gel / a Bubble, a Metal and a Gel |
| The Mantis Ant | The Meadow | 72 / 15 / 0 | 79 / 16 / 0 | 90 / 17 / 0 | alone / two Guards / a Guard, a Captain, two Alraunes |
| The Ruby Colossus | The Waste | 40 / 14 / 1 | 44 / 15 / 1 | 50 / 16 / 1 | alone / a Pit Antlion, a Basilisk / the Antlion Queen, two Gorgons |
| The Fallen Weapon | The Waste | 40 / 16 / 1 | 44 / 17 / 1 | 50 / 18 / 1 | alone / a Barbed Needler, a Basilisk / a Barbed Needler, two Gorgons |
| The Emperor Scorpion | The Waste | 60 / 14 / 1 | 66 / 15 / 1 | 75 / 16 / 1 | alone / a Pit Antlion, a Barbed Needler / a Pit Antlion, a Great Needler, a Gorgon |
| The Matador | The Marsh | 72 / 12 / 0 | 79 / 13 / 0 | 90 / 14 / 0 | alone / two Wights / three Wights, a Spectre |
| The Phantom Train | The Marsh | 72 / 16 / 1 | 79 / 17 / 1 | 90 / 18 / 1 | alone / two Ghosts / a Ghost, a Wraith, a Spectre |
| The Vampire Lord | The Marsh | 50 / 12 / 0 | 55 / 13 / 0 | 63 / 14 / 0 | alone / a Death Knight, a Wight / a Dread Knight, a Death Knight, a Wight |
| The Marsh Serpent | The Marsh | 72 / 18 / 0 | 79 / 19 / 0 | 90 / 20 / 0 | alone / two Ghosts / two Wights, a Spectre, a Ghost |
| The Gargantuan King | The Peak | 72 / 15 / 0 | 79 / 16 / 0 | 90 / 17 / 0 | alone / a Bomb, a Grenade / two Grenades, a Balloon |
| The Fiend of Fire | The Peak | 72 / 14 / 0 | 79 / 15 / 0 | 90 / 16 / 0 | alone / two Fire Lizards / two Magma Lizards, a Wyvern |
| The Obsidian Tyrant | The Peak | 72 / 18 / 1 | 79 / 19 / 1 | 90 / 20 / 1 | alone / a Fire Lizard, a Wyvern / two Magma Lizards, two Wyverns |

At tier one the thirteen cost a squad of four from 9% of its hull (the Mantis Ant) to 62%
(the Fiend of Fire) on the baseline of 17 November: tier one's numbers are the numbers pass's
to size. What this asks of him: the form, blocks on the entry or something else; whether a
boss ramps inside a tier at all (his words say "tiered and ramped", and the first entries
carry one block a tier); and when the curation comes. Beside it, his marks on the escorts at
tiers two and three (`docs/bosses_proposal.md`; the to-do).

## 7. Holes, each with what settles it

A stub: eight holes of the first cut. Settled by the landing: the light machine's one (the
duelists), the armour-three pair (no patrol holds Metal Gels), a heavy patrol's strike at the
wall (by the threat rating: the bible's wall row). The numbers brief's: eight fodder free for
three. Parked with what prices a round: the stall no side can end, the Marsh's giants having
no escalation (the refit brief's section 7). By design: a walled summoner waits for a slot.

## 8. The rows this touches, with the reason each had

A stub: written on 10 November. The bible's pack, hunters, ramp, boss and Foe roles rows;
`docs/rules.md`'s Setup and Packs; the vocabulary's Patrol and Formation.

## 9. Questions for Ryan

A stub: thirteen questions, twelve answered by his calls of 9 and 10 November and by the
landing (the rows of section 8). Open: question 9, the bosses' form, which is section 6's.

## 10. Bench: ideas the rules kill, one line each, for Ryan to overrule

- A hunting formation rated three: the soft wrench; a lone catch won one fight in twenty.
- A cell that lists alternatives for the seed to draw from: the grid rule of 8 November.
- A guest's members inside the lead's formation: a composition does not know its guest.
- A patrol with a massive foe: "a few foes"; the massives lead formations.
- A formation past eight: the cut; the half-size tech is the exit he named.
- A loot-runner patrol that flees with a cache: the one flee the register allows, his to want.
- The drakes as a winged hunter line: their codex ("stands at the back").
- An escort for every elite (the Nob's goblins): the elites' item, the bible's section 12.
- A rating of two on a formation that reads free at three: "formations a 3"; its grid moves.

## 11. If Ryan says go: the order

A stub: steps 1 to 4 ran on 10 November (the grids, the opening, the records, the reads). Step
5 is left: the bosses' stat blocks and the final's wildlife as named escorts (section 6).

## 12. The compositions and their reads, domain by domain

A stub: every grid of the first cut with its bands at one to four machines for four teams. The
grids as they landed, re-cut to the roles, are `content/factions.json`: 39 formations, 30
patrols, 22 elites and 27 escorts. The reads are `docs/measurements.md`, 9 and 10 November.

## 13. The flankers: a slate for Ryan's marks (10 November)

His rule (9 November): a flanker is a duel for one machine and no small pusher, "One spooky
flanker revenant or whatever is a more interesting duel for a Skua or Kite than the Skua or
Kite just mowing down less goblins than they would if they were grouped." The slate was one
duelist a domain from his bench of 3 November ("what misses the cut may be rank and file"),
each one sharp question. **Landed 10 November** on his "Duelists are as you see fit": each
alone as a patrol rated one at every tier, and as a pair rated two on the ramp's later steps
(from Convergence 3 at tier one, 8 at tier two, 11 at tier three). Tiers two and three follow
his recolour rule, a bigger number and no twist. As content has them, each a placeholder:

| Domain | The duelist | Hit points, attack | The duel | Tiers two and three |
|---|---|---|---|---|
| The Meadow | The Whisker Cat | 12, 5 | A Claw, and the Whisker Lash, a half blow that Jams the entry its machine shows: what do I leave showing, and do I spend my best die before it strikes? | The Sabre Cat, the Storm Cat |
| The Waste | The Roc | 14, 4, winged | Talons, and the Stoop, half again as hard a round after it is announced. It is Aloft while the Stoop gathers and nothing reaches it, so the round the climb is announced is the window. | The Night Roc, the Great Roc |
| The Marsh | The Dullahan | 10, 5 | A Blade, and the Reraise, a rise it readies once a fight: burst it before it readies, purge the rise, or keep the big die for the second life? | The Grave Dullahan, the Charnel Dullahan |
| The Peak | Cerberus | 10, 5 | Three Heads, three bites of a third in one action, and the Maul, which leaves Scorch 2: Armoured turns a point off every head where a Barrier stops one. | The Basalt Cerberus, the Sulphur Cerberus |

The test each was written to (the refit brief's section 4): one question answered with a die;
hit points for three or four rounds of one light machine; no flat armour, which walls the
lights; a decision for a lone light, free for the Honey Badger; a mismatch costs time, never
hull. What moved in the building and since: the Dullahan's rise is once a fight, since a rise it
could ready again made a duel the slow lights could not end; Cerberus's bites are plain and
the Maul the one that scorches, since three scorching bites a round left the slow lights no
way to fire; the Roc's Stoop lost its breach with the word (15 November) and gained the climb
(16 November: "that's its identity"). On the baseline of 17 November a lone duelist costs the
machine sent at it 3.4% to 7.4% of a four's hull, all over the thirtieth of his budget.

**Open, his:**
- The duelists' numbers, with the numbers pass, and whether a pair is the heavy patrol a
  flank wants (the refit brief's section 4).
- A second flank patrol a domain, since the duels repeat, four to eight packs a battle from
  one line: a picket of the domain's own front-rank pushers, proposed and not in content (the
  refit brief's section 11; the to-do).
- The twelve working names and their shown text, and their sprites, rough placeholders.

**Holes that stand:**
- The Whisker Cat's Jam can cost a lone machine its whole round, with no second die to
  answer: the blow's weight and its damage are the dial.
- The Roc on a countdown of one is seen for a single round. A count of two is gentler.
- The Dullahan and the Zombie Knight ask the same question: the Knight stays the anchor of
  the Marsh's formations, armour and all, and the flank has the rider.
- Cerberus asks for Armoured, which two of the nine tier ones stock (the Shoring Jack): a
  lone light without one takes all three heads.

**Bench** (his names left off the slate, one line each with what kept it off): the Sphinx (a
riddle is a condition on the player's dice, and no gate reads the player's state); the
Banshee (a wail that takes a reroll is the Mandragora's scream on another body); the Iron
Giant (a massive foe is no patrol by "a few foes"); the Drowned King and Anzû (no question
found that is theirs alone yet); the lone Bomb (a burst that decides the fight, his own
refusal for the hunters); the Zombie Knight re-tuned (kept as the formations' anchor).
