# The formation pass: a proposal

Every domain's patrols and formations written anew as grids, with a lead, a threat rating, a
hunt where one hunts, a question each poses, and variants placed on the tier and the ramp by the
runs; the two hunter questions of the bible's section 12 answered with a lean each; and the
bosses as fixed entries by tier and ramp, the schema and today's numbers laid out for Ryan's
marks. Proposed in chat first (CLAUDE.md: content ideas are proposed in conversation, Ryan tweaks
them against his notes, then they land), so nothing here is in `content/factions.json`: the grids
below were written to a scratch copy of it, validated by `sim/content_db.gd`, and read by the
curve read, whose bands are the tables' last columns. Every number is a placeholder and every
read a direction (30 seeds, called so). Ryan's words carry his name and the date; everything else
is Claude's for him to move.

What this pass does not touch: a foe's numbers (the refit is held until he plays Phase 2, the
bible's section 12), the elites' compositions and ratings (his: "don't downgrade them"), and the
escorts as they stand (the bosses' item, section 6 below, writes them with the bosses' entries).

## 1. What Ryan said, and when

- 5 November: packs as designed formations, "either completely predetermined by the engine or
  semi-random combinations", so that "we would be able to craft far more engaging skirmishes
  with clear identities and patterns, threats and responses".
- 6 November: the threat rating shown on the map, "for how many units it's intended for"; "a
  'true' 4 should be reserved for elites and bosses, with formations a 3. Then the decision
  becomes a 1-3 split, a 2-2 split where one is safe and one short (or taking two 3 fights short,
  or two patrol fights safe), or all 4 on the formations and ignoring the flanks"; a two legal
  for a heavy patrol. Of the ratings by who solos: "something the badger can solo and something
  the Kite or Skua can solo are completely different ratings. Your read about what you're
  sending against the badger probably demolishes the Kite, so those probably are level 2 fights,
  yes. Meaning we need something under that for tier 1. It might mean we need to reposition
  certain enemy types, or create new ones." And the order: "let's do formations after the rest
  here". Of the first turn: "I probably would shy away from hitting the first battle with a fight
  in the first turn, that's for sure. That's just mean."
- 7 November: the cut. A pack is what its eight slots hold; "We just tune the enemies so there's
  no need to have more than 8 on a field. If we really need more, we have the half-size tech,
  perfect for small goblins, rats, gnomes, tiny dragons, who knows what." The ramp scales no
  pack: "maybe gate certain predefined compositions behind a ramp+tier". The variants: "if
  composition #3 is 3 goblins and a shaman, and #3a is 4 goblins and a shaman, and #3b is 3
  goblins and two shamans … we should be able to figure out somewhat empirically where in the
  tier-ramp curve that should sit, and then we have discrete combinations to apply data to for
  testing and such, we can make tables, and prune formations that have no place or are
  redundant." The bosses: "you're right in that those should be numbers per tier. A flat
  multiplier isn't flexible for tuning. Really, a boss' tiered and ramped stats and escorts
  should be split into seperate fixed entries, same as a pack's would"; "Don't curate the bosses
  now, that can wait."
- 8 November: a composition is its grid, "Fix the comps so they make simple sense"; the hunt the
  composition's, "The composition should say if it hunts, not the units", the goblins "normal
  fodder, as per their codex lines"; the hunters "should be a big deal, like
  warn-the-player-when-they-spawn big deal. I'd put them all at threat level 2 at least, and not
  flood the map with them. They're a soft wrench in the plans, where the elite is a hard wrench.
  Part of my shift is that before, we needed hunters to break up the player from continuously
  gaming the formation ranges, so they were a release valve. Now, they're there to make the
  player shift their battlefield deployment around, so they don't need to be so constant"; and
  "I also was under the impression that no hunters should be on the field turn one, but that
  was a formation pass issue, I think."
- 9 November: "I'll sort out the questions in the formation pass."

## 2. What the records already say

- The schema (`content/factions.json`'s `_about`, `docs/rules.md` Content conventions): `front`
  and `back`, four cells each, null or a foe id; the ranks hold, a massive foe fills its column,
  a core's parts take cells of their own; the grid is the whole count. Optional: `squad` (1 to
  4), `lead`, `hunts` (nearest, weakest, strongest, slowest, fastest; never on an escort), `ramp`
  ([lo, hi], the gated compositions of a size at a tier together holding every Convergence from
  the tier's first to 12). Every domain writes every size at every tier; a tier with none has
  none.
- The dealing (`sim/battle.gd`, `sim/ramp.gd`): at the start the ramp's count of formations (one;
  two from Convergence 3; three from 8) a move from the apron and of patrols (two; one from 8) on
  the flanks, each the tier's compositions in content order, the lead's and the guest's in turn;
  the rift's cycle formations and patrols in turn; the tears send patrols. A hunter placed at the
  start opens a row further back until it has caught nobody. The quick campaign deals the same
  formations in turn.
- The reads (`docs/measurements.md`, 6 November): the promise read at 30 seeds found the
  formations holding their promise best (a decision in 24 of 38 cells at three), tier one's
  mostly too easy (random 87%), the patrols at one costing the lone Badger a quarter of its hull
  at tier one and over half at tiers two and three with four walls (the pit pair, the great
  scouts, the knight's retinue, the fire lizards), and the elites not earning their four. The
  campaign runner found 169 of 481 fights one machine against a formation, won 5%.
- The design tests (the bible's section 2): every pack poses a question ("finish the
  resurrectors, interrupt the big hit: never a damage race"); rank and file die to a die or two,
  the big foes open a gap; mismatch costs time, never ability. The pack row (section 4): the
  player is never told how to beat a formation, learning them is the mastery, the compositions
  authored by hand and never generated.
- The long wall proposal's shape for a formation (`git show 68381ff:docs/long_wall_proposal.md`,
  sections 4.3 and 10): an anchor and a swarm, one or two durable pieces whose moves carry the
  enemy's verbs and trash that dies to a die but threatens the shield while it stands; the
  output curve rising; the designer's question under `design`.

## 3. The rules the grids follow

Claude's method, each line a proposal:

1. **One question a composition, written down.** Every patrol and formation carries
   `design.question`, internal and never shown (CLAUDE.md: everything under `design` is
   internal): what the player must answer, in the engine's vocabulary, as the long wall
   proposal asked. The validator could require it on a formation, so the design test "every
   pack poses a question" is checked, not hoped. The question is a discipline for the author,
   never a beat line: the map shows the rating and nothing else (the pack row).
2. **The grid carries the question.** Where a back-rank piece stands decides its reach: behind a
   front foe it is reached by Indirect or through the hole a kill opens; in an open column
   Direct reaches it. A patrol for one puts its one caster in an open column (kill it first,
   and you can); a formation walls its casters (open a hole, or bring Indirect). A summoner that
   needs room gets it or does not, on purpose: the Rotbloom's bed leaves two back cells for its
   seedfall, the grave host leaves none, so the ghosts raise only into the gaps the kills open.
3. **Anchor and swarm.** A formation for three has one or two durable pieces (a massive, a knight,
   two casters) carrying the domain's verbs, and trash that dies to a die. The swarm pieces
   threaten the shield while they stand (the goblin's and the revenant's add, the needler's
   breach), the anchor is what the setup pays on.
4. **Eight is the ceiling, and the ramp's variant is a step toward it.** A formation's variants
   step 6, 7, 8 foes, never past the slots (the cut); the gentlest at the ramp's foot, the
   fullest at its top. Where a formation at eight fodder is still free for three, the answer is
   the units' numbers (the refit, held for Ryan's play), never a ninth foe.
5. **Hunters are heavy patrols rated two, one a domain and tier, and the formations push.**
   Ryan's frame of 8 November: a soft wrench, a big deal, few. A hunting formation rated three
   that catches a lone machine is a fight it wins one time in twenty (the campaign read), a hard
   wrench with no answer but a wreck, so no formation hunts. A hunter rated two says what the
   catch means: a caught machine alone is in trouble and a friend joining makes it a fair fight,
   so the plan shifts, which is what the wrench is for. One hunting patrol a domain and tier
   (none where the domain's rank and file do not hunt), placed last among its tier's patrols so
   the first patrols dealt push.
6. **Who hunts, by the codex.** Wolves, wargs and alphas ("picks the slowest machine on the field",
   "runs it down"); antlions, pit antlions and the queen ("waits under the sand for whatever is
   slowest"); the bombs, grenades and balloons ("a ball of fire with a face, and it comes straight
   for you"). The needlers push ("nobody has ever seen one move"), and so do the revenants and
   wights, whose codex is the goblin's nearly word for word, the goblins being "normal fodder" by
   Ryan's word. The Marsh's hunters are the Fell Rider and the wanderers, none in its rank and
   file. Section 4 lays the two questions out with this lean.
7. **The rating is read by who solos.** A one is a decision for a lone light tier-one machine
   (the Skua, hull 20 and shield 12) and free for the Badger; a two is the Badger's decision, or
   a pair's free fight; a three is a decision for three; a four is a decision for four. So the
   curve read runs twice at least: the default four (the Badger first) and a light four (the Skua
   first), and a tier's compositions with a team of its tier, since the default team is tier one's
   stock and reads every tier-three formation as a wall.
8. **Place, then prune.** A variant's gate is a ramp band read off its bands: the gentlest
   decision at its rating takes the foot, the hardest the top. Two compositions of a domain, size
   and tier with the same bands at every size and the same question are one composition: the
   read's "same as" column names them and the proposal says which goes.
9. **The ramp's bands are the ramp's own steps.** Convergence 0 to 2 (one formation on the field,
   two patrols), 3 to 7 (two formations), 8 to 12 (three formations, one patrol, the beat at two,
   two tears a peak). A tier-one composition is fought from 0, a tier two's from 4, a tier three's
   from 8, each to 12. Three bands at most, two in practice.
10. **The pass moves grids and counts, never a foe's number**, and writes no new foe type: where
   the reads say a true one does not exist among a domain's units, section 9 names it as his
   question (his words of 6 November: reposition or create).

<!-- TABLES -->

## 4. The two hunter questions (the bible's section 12)

**Who hunts among the rank and file.** Lean: the lines whose codex says they come for a machine
hunt, as heavy patrols rated two; the rest push. So of today's twenty-nine hunting compositions
(eleven formations, twelve patrols, six elites) the elites keep their hunts (the Pilgrim, the Fell
Rider, the Thunder Ape, the Bane, the Reaper, the Wild Hunt: each a hard wrench by design), nine
patrols hunt (the wolf, warg and alpha packs; the antlion pair, the pit pair and the queen's hunt;
the bomb, grenade and balloon flights), and no formation does. The needler line pushes (five
compositions today hunt by it: "a cactus … in the pose of someone running, and nobody has ever
seen one move" is a pusher's codex), and the Marsh's revenants and wights push (four today: the
goblin's line, "straight at the nearest thing with a heartbeat", which Ryan called fodder). The one
line this lean is least sure of is the bombs': "it comes straight for you" reads as a hunt, and a
flight of bombs that catches a lone machine and bursts through its shield is the kind of wrench a
hunter should be; but a bomb is also the Peak's fodder, and if Ryan reads the line as a pusher's
the Peak has no rank-and-file hunter at all, which the Marsh already shows is fine (its hunters are
the Fell Rider and the wanderers). His call: the bombs.

Hole raised against the lean: the wolves' codex says "picks the slowest machine on the field",
which is a hunt, and the goblins' "straight at the nearest thing with a heartbeat", which he
called fodder, so the codex alone does not settle a line; what settles it here is the fantasy of a
pursuit (a pack that runs something down, a thing waiting under the sand for the slow) against a
crowd that simply comes. If he wants a line changed, its codex changes with it, the one home for
the words.

**Who keeps hunters off the field at turn one.** Lean: code, one line. `Battle.setup` places the
ramp's patrols from the tier's patrol compositions in content order; placing them from those that
do not hunt (`patrols.filter(not hunts)`, falling back to all when a tier has only hunters)
keeps every hunter off the opening whatever order content writes, with or without a guest, at any
ramp gate. The content way (every domain's first patrol at every tier and every Convergence a
pusher, the validator holding it) works too and is written into the proposal's order as a belt
beside the braces, but it is fragile: the opening's second patrol is the guest's first, and a
ramp gate on the first patrol moves which is first. The rift's cycle and the tears still send the
hunters, so they arrive as the wrench they are meant to be, declared by the HUNTED band when they
turn on a machine. Not a rule the player is told, a shape of the opening, so no vocabulary moves;
`docs/rules.md`'s Setup gains a clause.

## 5. The ramp gates and the pruning, from the reads

The reads: the curve read at 30 seeds (`tools/balance.gd --packs curve`), random and greedy, on
the proposal's grids, with four teams in stock: the default four (the Honey Badger, the
Clydesdale, the Kite, the Baboon), a light four (the Skua, the Prairie Dog, the Cottonmouth, the
Puffin: the Skua alone is the rating of one's read), a tier-two four (the Wild Boar, the
Clydesdale, the Buzzard, the Dingo) on tiers two and three, and a tier-three four (the
Swallowtail, the Musk Ox, the Ammit, the Giant Petrel) on tier three; and today's compositions
with the default four beside them. Every cell a band (free: random wins half or more; a decision:
greedy wins half or more and random less; a wall: greedy wins less than half) with greedy's hull
lost; a direction, called one (`docs/measurements.md`, 9 November). The tables of section 12
carry every cell.

**The gate rule**, read off the bands (Claude's, for Ryan to move). The team that reads a tier is
its own: the default four for tier one, the tier-two four for tier two, the tier-three four for
tier three; the light four reads the rating of one at every tier. Within a domain and a tier:

- a formation that reads free at three is the tier's gentlest and carries the foot's gate, from
  the tier's first Convergence to 7 (tier one's 0 to 7, tier two's 4 to 7);
- a formation that reads a decision at three carries no gate: it is what a three is;
- a formation that walls three and is a decision at four carries the top's gate, 8 to 12;
- the heaviest formation of a tier carries no gate whatever it reads, so the coverage rule holds
  (every Convergence from the tier's first to 12 dealt something);
- tier three's compositions carry no gate: its five Convergences are one band;
- a patrol rated one that reads free for the Skua alone is the foot's; one that is a decision
  for the Skua carries no gate; one that walls the Skua and is free for the Badger is a two, or
  the top's one; a hunter keeps its two whatever the Boar makes of it (his word, "at least").

**The pruning rule**: two compositions of a domain, size and tier whose bands match at every
size and whose questions are one question are one composition, and the lean names which goes;
where the questions differ they both stay, the read's "same as" notwithstanding.

<!-- GATES -->

## 6. The bosses as fixed entries by tier and ramp

Ryan, 7 November: "a boss' tiered and ramped stats and escorts should be split into seperate fixed
entries, same as a pack's would"; "Don't curate the bosses now, that can wait." The to-do puts the
form with the formation pass. Claude's lean for the form, for him to move, and today's numbers
laid out so his marks have a table to land on:

- **Stat blocks on the boss's entry**, in `content/foes.json`: `tiers`, a list of fixed entries
  `{"tier": t, "ramp": [lo, hi], "hp": n, "attack": n, "armour": n}`, the ramp optional as a
  composition's is (absent: every Convergence the tier is fought at), the blocks of a tier
  together holding every Convergence from the tier's first to 12 (the validator's gate rule, as
  for compositions). The engine takes the block whose tier matches and whose ramp holds, in
  place of `ContentDB.BOSS_TIERS` and `armour_step`; an entry with no blocks rides the multiplier
  as today (the elites, a final's hero, the finale's line, until he marks them). The boss stays
  one named entity at every tier, so no separate foe entries: a recolour is a new unit with a
  new name, which a boss never is.
- **The escort stays an `escort` composition**, by tier and, when wanted, a ramp band, so a boss's
  escort at the ramp's top can be its own entry as a pack's variant is. Nothing new in the
  schema for it: the gate field exists since 7 November.
- **Today's numbers as the first entries** (×1.0, ×1.25 and ×1.5 on HP, +0, +1 and +2 on attack,
  the multiplier made explicit and no number moved), each a placeholder for his marks:

| Boss | Domain | Tier 1 HP / attack / armour | Tier 2 | Tier 3 | Escort today (tier 1 / 2 / 3) |
|---|---|---|---|---|---|
| Floraison | The Meadow | 48 / 6 / 0 | 60 / 7 / 0 | 72 / 8 / 0 | alone / two Wargs / two Alpha Wargs, a Guard, a Captain |
| The King Gel | The Meadow | 48 / 6 / 0 | 60 / 7 / 0 | 72 / 8 / 0 | three Gels / two Gels, a Bubble Gel / a Bubble, a Metal and a Gel |
| The Mantis Ant | The Meadow | 48 / 6 / 0 | 60 / 7 / 0 | 72 / 8 / 0 | alone / two Guards / a Guard, a Captain, two Alraunes |
| The Ruby Colossus | The Waste | 40 / 8 / 1 | 50 / 9 / 1 | 60 / 10 / 1 | alone / a Pit Antlion, a Basilisk / the Antlion Queen, two Gorgons |
| The Fallen Weapon | The Waste | 40 / 8 / 1 | 50 / 9 / 1 | 60 / 10 / 1 | alone / a Barbed Needler, a Basilisk / a Barbed Needler, two Gorgons |
| The Emperor Scorpion | The Waste | 48 / 7 / 1 | 60 / 8 / 1 | 72 / 9 / 1 | alone / a Pit Antlion, a Barbed Needler / a Pit Antlion, a Great Needler, a Gorgon |
| The Matador | The Marsh | 48 / 7 / 0 | 60 / 8 / 0 | 72 / 9 / 0 | alone / two Wights / three Wights, a Spectre |
| The Phantom Train | The Marsh | 48 / 8 / 1 | 60 / 9 / 1 | 72 / 10 / 1 | alone / two Ghosts / a Ghost, a Wraith, a Spectre |
| The Vampire Lord | The Marsh | 40 / 6 / 0 | 50 / 7 / 0 | 60 / 8 / 0 | alone / a Death Knight, a Wight / a Dread Knight, a Death Knight, a Wight |
| The Marsh Serpent | The Marsh | 48 / 7 / 0 | 60 / 8 / 0 | 72 / 9 / 0 | alone / two Ghosts / two Wights, a Spectre, a Ghost |
| The Gargantuan King | The Peak | 48 / 8 / 0 | 60 / 9 / 0 | 72 / 10 / 0 | alone / a Bomb, a Grenade / two Grenades, a Balloon |
| The Fiend of Fire | The Peak | 48 / 7 / 0 | 60 / 8 / 0 | 72 / 9 / 0 | alone / two Fire Lizards / two Magma Lizards, a Wyvern |
| The Obsidian Tyrant | The Peak | 48 / 8 / 1 | 60 / 9 / 1 | 72 / 10 / 1 | alone / a Fire Lizard, a Wyvern / two Magma Lizards, two Wyverns |

A part's numbers ride its core's block (the tentacles, the eyes, the Saurian Queen), as they ride
the multiplier today. The Cinder Tortoise's `armour_step` (1, 2, 3 by tier) is an elite's and
stays a step until the elites are marked. A final's wildlife (three of its domain's units at the
tier, the one escort no composition names) becomes a named `escort` composition per domain and
tier in the same pass, so the final's fight is authored as every other is; the bench's heroes are
not the compositions' to name, so an escort for a final names no `boss` and is picked as today's
fallback is (the composition that names none).

What this asks of him: the form (blocks on the entry, or something else), whether a boss ramps
inside a tier at all (his words say "tiered and ramped"; the first entries above carry no ramp
band, one block a tier), and when the curation comes. Built only on his go, in a session after
the grids land.

## 7. Holes, each with what settles it

1. **The light machine's one.** A rating of one read by the Skua alone may show that no patrol of
   two or three of a domain's units is a decision for it (too free, or a wall), in which case the
   true one wants a unit the domain lacks (a lesser revenant, a lone drake with no lizard). The
   light read's first column settles it per domain; a new unit is a chat proposal first.
2. **The read's team is stock.** Every band is read on stock kits at the greedy rung; a built team
   with tier-matched pieces reads easier, and Ryan's play decides feel. The gates proposed below
   are placings to start from, moved on his word after the 200-seed matrix and his play.
3. **Eight fodder may still be free for three.** If the eight-slot variants read free at three on
   the default team, the pass has no lever left but the units' numbers, which are the refit's,
   held until he plays Phase 2. The proposal then places the eight at the top and says so.
4. **A heavy patrol that pushes.** A pack rated two that walks to the wall (the knight's retinue)
   strikes the gate as any pusher does, by its strength: a two with three foes costs the gate
   what a one with three does. The rating is the fight's, the strike the count's; if the two
   should cost more at the wall, that is the gate strike's rule, not this pass's.
5. **A summoner with no room.** A ghost in a full front rank raises only after a kill opens a
   slot; a summoner never picks a summon with no room (7 November). So a walled formation's
   raisers wait a round, by design here; whether that reads as the ghosts "doing nothing" on the
   first round is his play's to say.
6. **The armour-three pair.** The metal pair, a heavy patrol of two Metal Gels, blanks a blow of
   three or under: for a pair of light machines that is time (their fours and strikes land), for a
   lone machine of small blows a wall. Rated two it is never a lone machine's fight by the map's
   word; whether a pack the Skua cannot scratch belongs on the map at all is his call.
7. **The tier-two and tier-three reads.** The default team is tier one's, so the tiers above are
   read with teams of their tier (stock), which no run fields exactly: a direction for placing
   within a tier, never across tiers.

## 8. The rows this touches, with the reason each had

- The pack row (section 4 of the bible): the hunts by composition (unchanged in form; the set
  changes, nine patrols and the six elites), a rating of two on every hunter and on the heavy
  patrols, `design.question` as the composition's one internal text. Its reason stands.
- The hunters row: its content clause (rated two at least, few on a map, none on the field at
  turn one) becomes built fact; the row keeps the words and gains the one line of code.
- The ramp row: "a denser fight is a composition of its own … its gate a composition's `ramp`"
  becomes the written gates of section 5; the row's reason stands.
- The boss row: the multiplier becomes the first stat blocks (section 6); the reason stands.
- Section 12: the hunter question and the formation pass item retire into rows on his go; the
  bosses' form becomes a row or stays a question as he says.
- `docs/rules.md`: the Setup clause (no hunter at the opening), the Packs line ("a patrol … one
  machine's fight, a heavy patrol two"), Content conventions (`design.question`).
- The vocabulary's Patrol ("a fight for one machine" becomes "for one or two"), Formation and
  Behaviour entries, and `docs/vocabulary.md` regenerated.

## 9. Questions for Ryan

1. The bombs: a hunter line (the lean) or fodder?
2. The opening: no hunter dealt at turn one by the one line of code (the lean), by content order,
   or neither (today's opening backs a hunter off a row at a time instead)?
3. The rating of one read by a lone light machine, and two by the Badger alone: is that the
   reading of "intended for"?
4. Hunters as heavy patrols rated two, no formation hunting: his "at least" left three open.
5. `design.question` on every patrol and formation, required by the validator on a formation?
6. The ramp bands at the ramp's own steps (0 to 2, 3 to 7, 8 to 12), two variants a formation
   at most?
7. The pruning candidates section 5 names: which go.
8. Where the light read finds no true one among a domain's units, a new fodder type for that
   domain (proposed in chat), or the lightest existing pair as the one?
9. The bosses' form (section 6): stat blocks on the entry, one a tier to start, the escort a gated
   composition?
10. The metal pair (hole 6): on the map as a two, or in formations only?

## 10. Bench: ideas the rules kill, one line each, for Ryan to overrule

- A hunting formation rated three: killed by the soft wrench (a lone catch it wins one time in
  twenty); today's eleven are pushers in the proposal.
- A cell that lists alternatives for the seed to draw from (the "semi-random" layout): killed by
  the grid rule of 8 November (no cell lists alternatives).
- A guest's members inside the lead's formation: killed by a composition not knowing the guest;
  the alternation of whole compositions stands in.
- A patrol with a massive foe: killed by "a few foes"; the massives lead formations.
- A formation past eight: killed by the cut; the half-size tech is the exit he named.
- A loot-runner patrol that flees with a cache: the one flee the register allows, not proposed
  here (a new foe and a flee move; the treasure goblin's shape, his to want).
- The drakes as a winged hunter line: killed by their codex ("stands at the back").
- An escort for every elite (the Nob's goblins): section 12's elites item, not this pass.
- A rating of two on a formation that reads free at three: killed by "formations a 3"; the
  proposal thins or thickens the grid instead.

## 11. If Ryan says go: the order

1. His marks on the grids, the hunters, the ratings and the gates; then `content/factions.json`
   as marked, `design.question` on every patrol and formation, the validator allowing `design` on
   a composition and requiring the question on a formation; the content tests on the new shape
   (every domain every size at every tier, the gates holding).
2. The opening's one line and its test (no hunter placed at the start at any ramp, with and
   without a guest), or the content-order check, as he picks.
3. The vocabulary's three entries and `docs/vocabulary.md`; `docs/rules.md`'s three lines; the
   bible's rows and section 12; the hangar page republished (the content changed); the to-do
   ticked; the status.
4. The curve read at 30 seeds on the landed content with the three teams, and 40 runs of the
   campaign runner, into `docs/measurements.md`; the gates moved where a band says so, on his
   word.
5. The bosses' stat blocks in a session of their own on his marks (section 6), the final's
   wildlife as named escorts with them.
