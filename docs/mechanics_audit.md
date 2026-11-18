# Mechanics audit: what is still open

What is left of the audit of 25 October, a sweep of the game's mechanics for anything that did
not add up or did not match the records, written before the long wall, the refit and the
reboot. Of its forty-two findings thirty are fixed or settled and one went with its rule,
Silence. The eleven below are still true of the game on 17 November, each checked against
today's code and content and kept under its old number, which code comments cite. None is
decided. A Text finding is Ryan's shown text or the records to move, a Question is his call,
and a Gap is the validator's. The file retires once these are fixed, struck or turned into
rows and tasks.

The long form, with every fixed finding and its trace, is
`git show cc446826:docs/mechanics_audit.md`.

## The skirmish

### 14. Text: "below half" fires at exactly half, and "when hurt" reads a brace's armour as hull
`Skirmish._when_word_holds` takes `below_half` as `hp * 2 <= hp_max`, where the shown word is
"when below half" (`Foe.WHEN_TEXT`): the Bomb, at 4 hit points, may self-destruct at 2. One
or the other moves. Its neighbour `missing_hull`, "when hurt", needs the move's own value
missing, which is right for a Recover and wrong for a brace: the Sandworm's Burrow, armour 3,
waits for 3 hit points lost, and the Old Man's Burrow, the Firelord's Submerge and the Mantis
Ant's Burrow read their armour the same way.

### 16. Text: the Grievance Reliquary Empowers on more than blows
"Taking hull damage Empowers it, a stack a blow." Its trigger is any hull lost
(`Skirmish._hull_damaged`: a blow, a tick, a bite, a hull price, an overheat's burn), by
Ryan's rule of 10 October that hull damage is any of them. So a Tithe Coupling beside it
Empowers every spend. The text says "each time it loses hull", or the effect reads blows
alone.

### 18. Text: the Stingray deepens most stacks it lays, not all
"Every stack this machine applies, to a foe, an ally or itself, is one deeper for every 5 heat
it carries." A die entry's stacks pass through `Skirmish._stacks_from`. A weapon's Ablating on
its own firer (`self_ablate`, the Stoker's) and a passive's or a module's stacks (the Phase
Conjugator's Armoured, the Grievance Reliquary's Empowered) do not. The Stoker is a hardpoint
piece, so a Stingray at 10 heat that carries one burns itself 1 and not 3.

### 20. Question: the winning turn is free of heat
A fight ends the moment it is decided, so END TURN's costs never land on the turn it is won:
no burn for heat past the maximum and no tick. Every fight opens with heat at nothing and
the shield whole (`Battle._build_skirmish`), so a machine may fire past its maximum on a
killing turn for nothing, and under the reboot that turn is the one a burn would have
priced. The lean of 25 October was to leave it, the last turn's freedom. The bot and the
numbers pass should know it either way.

### 21. Smaller ones
- A foe that readies itself may ready itself again. `Skirmish.legal_actions` refuses no
  `revive_once` on a foe already Undying, and the status renews, so the move is wasted. The
  Dullahans' Reraise is once a fight. The Zombie Knight's, the Death Knight's and the Dread
  Knight's Reraise and the two giants' Rise Again are not. The ally form has its guard
  (`ally_unready`).
- The Susceptibility Tensor's "a foe carrying any status" reads the team's debuffs alone
  (`Effects.carries_status`, `FOE_STATUSES`), never a foe's own Armoured, Empowered or
  Undying, though each shows as a chip. The text says "any debuff", or the read widens.

## The campaign

### 36. Small ones
- `Profile.absorb` folds a run's blueprints into the pool, the basics every run starts with
  among them (`ContentDB.starting_blueprints`), where the pool is "blueprint ids found in any
  run". It has no guard against folding the same run twice. And a finale won counts a boss
  beaten for the capital's rolled domain (`Campaign.finish_battle`, `bosses_beaten`), so the
  codex gains a domain the run did not beat.
- Comments that drifted. `Campaign.SHOP_BATTLES` says a wreck sits out "battles", and it is
  turns (`docs/rules.md`, The campaign). `ContentDB._resolve_promotions` says a promoted form
  has armour 5, and content has 2. `Profile.codex` says chassis and foe ids, and it holds
  faction ids too.

## Content and shown text

### 38. Text: the promoted forms show their heroes' codex
None of the eight promoted entries sets a codex, so each takes its hero's
(`ContentDB._resolve_promotions`), which the class change contradicts. Each is massive, in
the front rank, with armour 2, beside lines that say "a small figure in the back rank" (the
Summoner), "stands behind the dead" (the Cleric) and "no sword, no armour" (the Martial
Artist).

### 39. Text: codex lines that promise what the engine does not run
For Ryan's codex pass, each his prose to judge.

- The Zombie Knight's "the first time you put it down it gets back up" holds only once it
  has picked Reraise, which waits until it is hurt: killed from whole it stays down.
- The Gel "hits back", with one move and no reaction.
- Six Revenants "arrive for every one you put down", where a pack never grows.
- The Magma Elemental's fist "lands every round until it is dead", sharing its pick with
  Eruption once it is hurt.
- The Warrior "stops picking targets", the Black Mage "stops throwing fire" and the Cleric
  has "one spell left", where each move that opens below half joins the others and replaces
  none.

### 40. Text: the vocabulary's Direct omits the Exposed status
Direct "targets any front-rank foe, and any back-rank foe whose column is exposed". An
Exposed foe stands in Direct reach of every machine too (`docs/rules.md`, Exposed). The rest
of the drift this finding listed is fixed or went with its entries.

## The validator

### 41. Gap: the Rapid tier rule is not enforced, and a test asserts the opposite
"A Rapid vent is never below tier three ... and a Rapid shield never below tier two"
(`docs/rules.md`, Player keywords), but `ContentDB._validate_face` checks no tier for it, and
`test_rapid_rides_on_anything_and_shock_on_weapons_only` builds a tier-one Rapid vent and
asserts it validates. Content complies. With shields and vents off the die the rule may be
the thing to cut: one of the two moves.

### 42. Other gaps
- No unknown key is refused on a die entry, a component, a chassis, a module or a faction: a
  typo such as `"cooldwon": 0` is ignored in silence. A foe's fall, a move's steps and a
  charged store are held to a list (`FALL_ACT_KEYS`, `ALSO_KEYS`, `CHARGED_KEYS`); no more.
- `heat_max` is no required chassis key, and its fallback is 60 (`ContentDB.make_mech`), five
  times the scale.
- "No piece grants it to every ally at once" (`docs/rules.md`, Barrier) is unchecked: a
  Barrier that targets every ally passes.
- A die entry's `heat` may be negative or fractional, and an effect's `multiply_heat` may be
  0, with no error.
