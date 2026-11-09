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

The grids themselves, every cell of their reads beside them, are section 12, at the end, domain
by domain and tier by tier; section 5 reads them.

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
- tier three, fought at 8 to 12, carries one gate only: a formation that walls three and is a
  decision for four takes the last two battles, 11 to 12; the rest carry none;
- a patrol rated one that reads free for the Skua alone is the foot's; one that is a decision
  for the Skua carries no gate; one that walls the Skua and is free for the Badger is a two, or
  the top's one; a hunter keeps its two whatever the Boar makes of it (his word, "at least").

**The pruning rule**: two compositions of a domain, size and tier whose bands match at every
size and whose questions are one question are one composition, and the lean names which goes;
where the questions differ they both stay, the read's "same as" notwithstanding.

**What the bands say first.** At tier one, read by the default four, the only formations that are a
decision for three are the ones with a massive anchor (the sandworm ambush, 37% hull at three;
the magma vent, 41%); every warband, host and swarm of fodder reads free for three at eight foes,
the fullest the slots allow, and the eight-slot variant moves no band at three against the six
(the goblin horde against the warband, the needler thicket against the swarm, the grave throng
against the host, the ember pyre against the pit): the ramp's variants are redundant where the
anchor is missing, and the thinner one of each pair is pruned below. So the counts are at their
ceiling and the lever left for the fodder formations is the units' numbers, the refit's, held
until Ryan plays Phase 2 (hole 3). At tier two, read by a tier-two team, the same shape: the
single-anchor formations are decisions for two and free for three (the treant march, the pit
ambush, the wyvern roost), the worm and the forge true threes, and the two-anchor candidates
written after the first read (the grove and bloom, the pit wall) are true threes (walls for two,
decisions for three at 41 to 43% hull). The rating of one holds: every fodder patrol of two or
three foes is free for the Badger alone and free or a decision for the Skua alone, so each domain
has true ones under the Badger's twos; the Peak needed one written (the ember pair). The hunters
rated two: the antlions, the pit pair, the queen's hunt and the grenade and balloon flights read
as twos (a decision for the Badger or the Boar alone, or a wall for the Skua and free for a pair);
the wolf pack, the warg pack and the bomb flight read as ones (free for the Skua at a fifth of its
hull or a decision for it, free for the Badger), so a two on them is Ryan's word against the read,
and the lever that would make them twos is their numbers (question 4).

### The Meadow

| Composition | Size, rated | The read at its rating (default · light · tier team) | Gate | Keep or prune |
|---|---|---|---|---|
| `goblin_horde` | formation, 3 | free 1% · free 2% · — | 0 to 7 | keep; `goblin_warband` pruned (the same bands at two, three and four; the eight is the one) |
| `treant_grove` | formation, 3 | free 7% · decision 16% · — | none (the tier's heaviest) | keep |
| `gel_wall` | formation, 3 | free 4% · free 7% · — | 0 to 7 | keep (its question is the halves) |
| `goblin_raiders` | patrol, 1 | free 2% · free 32% · — | none | keep |
| `screamer_picket` | patrol, 1 | free 0% · free 12% · — | none | keep (the reach question) |
| `gel_pair` | patrol, 1 | free 1% · free 21% · — | none | keep |
| `wolf_pack` | patrol, 2, hunts the slowest | free 4% · free 21% at one · — | none | keep at two on his word; reads a one |
| `guard_horde` | formation, 3 (tier two) | free 2% · free 4% · free 1% | 4 to 7 | keep; `guard_warband` pruned (the same at two and three) |
| `treant_march` | formation, 3 | free 12% · decision 37% · free 10% | 4 to 7 | keep |
| `rotblooms_bed` | formation, 3 (tiers 2, 3) | free 3% · decision 55% · free 3% | 4 to 7 at tier two | keep |
| `gel_drift` | formation, 3 | free 4% · decision 9% · free 3% | 4 to 7 | keep (the plate and the halves) |
| `grove_and_bloom` | formation, 3 | — · — · decision 41% | none (the tier's three) | keep: the Meadow's true tier-two three |
| `guard_raiders` | patrol, 1 | free 4% · free 23% · free 0% | none | keep |
| `mandrake_picket` | patrol, 1 | free 3% · free 17% · free 0% | none | keep (the reach question) |
| `bubble_pair` | patrol, 1 | free 11% · wall 100% · free 11% | — | prune: a point of plate walls the Skua and nothing else reads; the gel drift carries the bubble gels |
| `warg_pack` | patrol, 2, hunts the weakest | free 14% · decision 40% at one · free 7% | none | keep at two on his word; reads a one |

### The Waste

| Composition | Size, rated | The read at its rating (default · light · tier team) | Gate | Keep or prune |
|---|---|---|---|---|
| `needler_thicket` | formation, 3 | free 8% · free 2% · — | 0 to 7 | keep; `needler_swarm` pruned (the same at two and three) |
| `antlion_pit` | formation, 3 | free 3% · free 3% · — | 0 to 7 | keep (the burrow question) |
| `sandworm_ambush` | formation, 3 | decision 37% · wall 100% · — | none (a true three) | keep; the light four walls at every size (the massive against light kits, hole 1) |
| `needler_scouts` | patrol, 1 (tiers 1, 2) | free 26% · free 19% · free 16% | none | keep; `needler_pair` pruned (the same bands, the same question) |
| `cockatrice_roost` | patrol, 1 | free 10% · free 1% · — | none | keep (the stone question) |
| `antlion_trio` | patrol, 2, hunts the slowest | decision 36% at one · wall 100% at one, decision 32% at two · — | none | keep: the Waste's hunter, a true two; `antlion_pair` pruned (the lighter two; one hunter a tier) |
| `barbed_swarm` | formation, 3 (tier two) | free 8% · free 1% · free 5% | 4 to 7 | keep; `djinns_mirage` pruned (the same bands; its second djinn is his if he wants the purge formation) |
| `pit_ambush` | formation, 3 | free 11% · decision 40% · free 16% | 4 to 7 | keep |
| `sandworm_pit` | formation, 3 | decision 60% · wall 100% · decision 44% | none (a true three) | keep |
| `pit_wall` | formation, 3 | — · — · decision 43% | none (a true three) | keep (four barriers, a question the worm does not ask) |
| `barbed_scouts` | patrol, 1 | decision 49% · wall 85% · free 34% | none | keep, rated two: three barbs through the shield are a decision for the Badger alone and a wall for the Skua |
| `basilisk_nest` | patrol, 1 | free 20% · wall 88% · free 6% | none | keep at one: free for every heavy, the Skua's wall being its stoned gun (a tier-two light's read is the next read) |
| `pit_pair` | patrol, 2, hunts the slowest | decision 76% at one · wall · decision 76% at one | none | keep: a true two |

### The Marsh

| Composition | Size, rated | The read at its rating (default · light · tier team) | Gate | Keep or prune |
|---|---|---|---|---|
| `grave_throng` | formation, 3 | free 1% · free 3% · — | 0 to 7 | keep; `grave_host` pruned (the same at two and three) |
| `barrow_mound` | formation, 3 | free 6% · decision 23% · — | 0 to 7 | keep |
| `knights_vigil` | formation, 3 | free 15% · wall 100% · — | none (the tier's heaviest) | keep; the knights wall the light four to three (hole 1) |
| `revenant_shamblers` | patrol, 1 | free 2% · free 32% · — | none | keep |
| `ghost_light` | patrol, 1 | free 1% · decision 51% · — | none | keep: a true one, the Skua's decision |
| `knights_retinue` | patrol, 2 | wall 100% at one, free 32% at two · wall to three · — | none | keep: a true two, hard |
| `wight_host` | formation, 3 (tier two) | free 5% · decision 19% · free 5% | 4 to 7 | keep |
| `grave_field` | formation, 3 | decision 15% · wall (a stall) · decision 21% | none (a three) | keep; the light four stalls against it at every size (hole 8) |
| `death_knights_retinue` | formation, 3 | decision 31% · wall 100% · decision 36% | none (a three, the heaviest) | keep (the grave guard's question) |
| `wight_shamblers` | patrol, 1 (tiers 2, 3) | free 14% · wall 100% · free 18% | none | keep at one: free for every heavy; the wights' knit out-heals a stock light alone |
| `spectres_wake` | patrol, 1 | free 14% · wall 97% · free 16% | none | keep (the raise and the cleanse) |
| `knight_and_wights` | patrol, 2 | decision 88% at one · wall · wall 100% at one, free 24% at two | none | keep: a true two |

### The Peak

| Composition | Size, rated | The read at its rating (default · light · tier team) | Gate | Keep or prune |
|---|---|---|---|---|
| `ember_pyre` | formation, 3 | free 6% · decision 27% · — | 0 to 7 | keep; `ember_pit` pruned (the same at three) |
| `magma_vent` | formation, 3 | decision 41% · wall 100% · — | none (a true three) | keep |
| `ember_pair` | patrol, 1 | free 0% · free 25% · — | none | keep: the Peak's true one, written after the first read |
| `salamander_trio` | patrol, 1 | free 23% · wall 100% · — | none | keep, rated two (free for the Badger, a wall for the Skua); `salamander_pair` pruned (the same bands, the same question) |
| `drakes_perch` | patrol, 1 | free 8% · wall 94% · — | none | keep, rated two (the stoke's question) |
| `bomb_flight` | patrol, 2, hunts the nearest | free 12% · decision 48% at one · — | none | keep at two on his word; reads a one (a blow of four kills a bomb whole) |
| `wyvern_roost` | formation, 3 (tier two) | free 5% · decision 57% · free 10% | 4 to 7 | keep |
| `grenade_volley` | formation, 3 | free 5% · decision 36% · free 8% | 4 to 7 | keep (everyone bursts: a question the roost does not ask) |
| `magma_forge` | formation, 3 | decision 60% · wall 100% · decision 52% | none (a true three) | keep |
| `fire_lizards` | patrol, 1 | free 27% · wall 100% · free 19% | none | keep at one: free for every heavy |
| `lizard_trio` | patrol, 2 | decision 87% at one · wall · wall 85% at one, free 6% at two | none | keep: a true two |
| `wyverns_perch` | patrol, 1 | decision 43% · wall 100%, decision 71% at two · wall 87% at one, free 6% at two | none | keep, rated two: a two by every read |
| `grenade_flight` | patrol, 2, hunts the nearest | free 12% · wall 90% at one · free 12% | none | keep: a two (walls the Skua, free for a pair) |

### Tier three, read by the tier-three four

The tier-three team (the Swallowtail, the Musk Ox, the Ammit, the Giant Petrel) reads harder alone
than the tier-two team did (the Swallowtail is a support frame, no soloist: every fodder patrol is
a decision for it at 42 to 75% hull, where the Boar found them free) and much the same at three.
Tier three is fought at Convergence 8 to 12, five battles, so it carries one gate only: a formation
that walls three and is a decision for four takes the last two battles, 11 to 12, where Ryan's goals
of 23 October want little fodder and dense fights; the rest carry none.

| Composition | Size, rated | The read at its rating (default · light · tier-two · tier-three) | Gate | Keep or prune |
|---|---|---|---|---|
| `captains_warband` | formation, 3 | free 3% · decision 9% · free 1% · free 3% | none | keep; `wolfrider_warband` pruned (the same bands on every read; its alphas' howl is the captains' shout again) |
| `rotblooms_bed` | formation, 3 (tiers 2, 3) | free 3% · decision 55% · free 3% · free 6% | none at tier three | keep |
| `metal_drift` | formation, 3 | decision 23% · wall 97% · free 20% · free 23% | none | keep (three plate on the metal gels) |
| `treant_wilds` | formation, 3 | free 13% · wall 84% · free 11% · free 15% | none | keep |
| `frost_and_bloom` | formation, 3 | — · — · decision 56% · decision 72% | none (a true three, the heaviest) | keep: the Meadow's tier-three three |
| `alpha_pack` | patrol, 2, hunts the weakest | free 16% · wall 100% · free 28% · decision 61% at one | none | keep: a two (a wall for the Skua, a decision for the Swallowtail alone) |
| `captains_raiders` | patrol, 1 | free 10% · decision 59% · free 5% · decision 42% | none | keep: a one |
| `metal_pair` | patrol, 2 | decision 62% at one · wall at one and two · free 23% · decision 67% at one | none | keep, rated two (a decision for the Badger and the Swallowtail alone); hole 6 stands for a light pair |
| `great_swarm` | formation, 3 | free 15% · decision 30% · free 11% · free 17% | none | keep |
| `mirage_court` | formation, 3 | free 14% · decision 30% · free 13% · free 16% | none | keep: the same bands as the great swarm on every read, a different question (two unmakers); his to prune if one of them goes |
| `queens_court` | formation, 3 | decision 21% · wall 100% · decision 33% · decision 48% | none (a true three) | keep |
| `sandworm_flats` | formation, 3 | decision 75% · wall 100% · decision 62% · decision 76% | none (a true three, the heaviest) | keep |
| `great_scouts` | patrol, 1 | free 48% · wall 94% · free 36% · decision 60% | none | keep: a one (a decision for the Swallowtail, half the Badger's hull) |
| `gorgon_pair` | patrol, 1 | decision 30% · wall 100% · free 34% · wall 90% at one, free 3% at two | none | keep, rated two: the stares wall a lone machine with few entries |
| `queens_hunt` | patrol, 2, hunts the slowest | wall at one, free 35% at two · wall · wall, free 34% · wall, free 47% | none | keep: a true two, hard |
| `lichs_court` | formation, 3 | wall 99% at three, decision 75% at four · wall · wall 98%, decision 81% · wall 100%, decision 59% | 11 to 12 | keep: a four by every read, the last battles' formation (a true four is the elites' and the bosses', so it stays a three on the map and earns the top's gate) |
| `charnel_pit` | formation, 3 | decision 46% · wall · decision 61% · wall 68% at three, decision 16% at four | none | keep: a decision for three for the default and tier-two teams, a wall for the tier-three team, whose three (the Swallowtail, the Musk Ox, the Ammit) has no burst for the knit |
| `wraith_choir` | formation, 3 | decision 68% · — · decision 71% · wall 84% at three, decision 30% at four | none | keep: a decision for three for the default and tier-two teams, a wall for the tier-three team as the charnel pit is (two grave guards, a question the pit does not ask) |
<!-- HOST -->
| `dread_host` | formation, 3 | wall 94% at four · wall · wall 96% at four · wall 85% at four | — | prune: a wall for four on every read (two death throes, a grave guard and four raisers), beyond what a formation may be |
| `wight_shamblers` | patrol, 1 (tiers 2, 3) | free 14% · wall 100% · free 18% · decision 56% | none | keep: a one |
| `wraiths_wake` | patrol, 1 | decision 42% · wall 100%, decision 37% at two · decision 49% · wall 98% at one, free 4% at two | none | keep, rated two: a decision for the Badger and the Boar alone, a wall for the Swallowtail |
| `dread_vigil` | patrol, 2 | wall at one, decision 37% at two · wall to three · wall, decision 53% · wall at one and two, free 29% at three | none | keep: a two (the tier-three pair walls on it: the Swallowtail and the Musk Ox against a dread knight) |
| `dragons_roost` | formation, 3 | decision 19% · wall 100% · decision 29% · decision 43% | none (a true three) | keep |
| `magma_pit` | formation, 3 | free 5% · decision 68% · free 13% · free 15% | none | keep |
| `balloon_storm` | formation, 3 | free 11% · decision 76% · free 11% · free 19% | none | keep: the same bands as the pit on every read, a different question (the swelling bursts); his to prune if one goes |
| `magma_caldera` | formation, 3 | decision 82% · wall 100% · decision 75% · decision 89% | none (a true three, the heaviest) | keep |
| `magma_lizards` | patrol, 1 | free 34% · wall 100% · free 40% · decision 75% | none | keep: a one for a heavy (a decision for the Swallowtail at three quarters of its hull) |
| `dragons_perch` | patrol, 2 | free 14% · wall 100% · free 36% · decision 69% at one | none | keep: a two (a decision for the Swallowtail alone, free for every pair) |
| `balloon_flight` | patrol, 2, hunts the nearest | free 18% · wall 95% · free 33% · decision 65% at one | none | keep: a two |

**The count.** Today's sixty patrols and formations become ninety-one candidates and, with the
twelve prunings above (the goblin warband, the guard warband, the bubble pair and the wolfrider
warband; the needler swarm, the needler pair, the antlion pair and the djinn's mirage; the grave
host and the dread host; the ember pit and the salamander pair), seventy-nine: the Meadow
twenty-two, the Waste twenty, the Marsh seventeen, the Peak twenty (the elites' twenty and the
escorts' twenty-four unchanged). The hunters: nine patrols (the antlion pair pruned to the trio)
and the six elites, from twenty-nine. Rated two among the patrols: the nine hunters and the
knight's retinue, the knight and wights, the dread vigil, the lizard trio, the wyverns' perch, the
salamander trio, the drakes' perch, the barbed scouts, the gorgon pair, the wraiths' wake, the metal
pair and the dragons' perch, twenty-one in all; rated one, seventeen; the formations
forty-one.


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
8. **A stall the enemy cannot end.** The light four against the grave field stalls at the bot's
   sixty rounds (traced: the Grave Giant knits three a round while four light kits chip one or
   two through its plate, and its one blow of eight never passes the shields they raise every
   round; nobody loses hull). The long wall proposal's guard against the infinite fight was that
   every script carries a rising threat, a rally, a breach or a countdown; the Marsh's giants
   carry none (a cleaver, a knit, a rise), so a kit that cannot out-damage the knit cannot lose or
   win. Not this pass's to fix, but its reads found it: the lean is an escalation on the giants'
   line (the cleaver breaching below half, or the knit's rounds finite), his to mark with the refit;
   the runner's stall count names the cells meanwhile (section 12's tables, a wall with little hull
   lost).

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
10. The metal pair (hole 6): on the map as a two, or in formations only? The read: it walls the
    light four at one and two (their blows bounce off three plate) and is a decision for the Badger
    alone; the lean is formations only.
11. The three hunters that read as ones (the wolf pack and the warg pack free for the Skua at a
    fifth of its hull and free for the Badger; the bomb flight a decision for the Skua, a blow of
    four killing a bomb whole): a two on his word, a one by the read, or their numbers moved with
    the refit so the two is earned?
12. The giants' line has no escalation and a kit that cannot out-damage the knit stalls against it
    (hole 8): an escalation on the Barrow Giant's line with the refit, or left to the kits?
13. The ratings are read on the default four; the light four finds every massive-anchored formation
    a wall at every size and the tier-two and tier-three ones by a heavy alone (the Boar, the
    Swallowtail): is a tier-two light's read wanted before the ones at tiers two and three are
    trusted, or is a light flanker meant to leave the formations to the heavies?

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
   as marked (`tools/formation_proposal.py write` holds the grids as code and writes them in place
   of today's patrols and formations, the elites and escorts kept; it retires with the proposal),
   `design.question` on every patrol and formation, the validator allowing `design` on a
   composition and requiring the question on a formation; the content tests on the new shape
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

## 12. The compositions and their reads, domain by domain

Every patrol and formation proposed, its grid left to right as it stands in a fight (a dot an
empty cell), its question and what changed from today; then its reads: the band at one, two,
three and four machines for each team (F free, D a decision, W a wall; greedy's hull lost beside
it), and the compositions of its domain, size and tier whose bands match it at every size on some
read (the pruning rule's candidates). The elites and the escorts are not here: they stand as
content has them.

<!-- TABLES -->
