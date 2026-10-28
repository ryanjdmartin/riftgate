# The ladder, the three verbs and the enemy's buffs: a build brief

Ryan's go, 28 October ("Ok, this seems good"), on `docs/foes_proposal.md`'s sections 9 to 11
and the chat of 27 and 28 October. This brief is the build's one home: every number, name
and rule the build needs is here or in the row it points to, and whatever is not here is not
part of this build. Ryan, 28 October: the builder is not to fill any hole with a guess. A hole
this brief does not close is a question for him, asked in chat before anything is built on
it; the last section lists the ones already known.

## Read first

`CLAUDE.md`; `docs/rules.md` (the skirmish's buffs, debuffs and foes; the campaign's boss
paragraph); the bible's section 5 rows "Silence mutes a machine's keywords ...", "Purge strips
a foe's buffs, and the foes carry buffs worth stripping", "Numbed is a buff nothing removes",
"Barrier and Ward"; section 3's row "Difficulty grows first by smarter foes ..."; section 9's
rows "A tier's rank and file are recolours ...", "The domains' levers ...", "A boss scales to
the battle's tier"; `docs/foes_proposal.md` sections 9 to 11 for the reasons; the "Start here"
of `docs/status.md`. The chat is newer than a file where they disagree; this brief is the chat
of 28 October written down.

## Scope

In: (A) the three enemy verbs in the engine, silence, purge and the foe's cleanse; (B) four of
the machines' buffs crossing to the foes, Primed, Barrier, Ward and Regenerating, and the
specials that grant them; (C) the player's Purge keyword and one piece that carries it; (D)
twenty-six recolours in content with their tiers, numbers and twists, and the spawn lists by
tier; (E) the recolour script and the sprites; (F) the reads; (G) the records.

Out, and never guessed at: everything in the last section.

The order that keeps every step testable: A, then B, then C, then D (the content validates
only once B's specials exist), then E, then F, then G. Commit after each verified chunk with
the suite green (`perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd`;
`--import` first after any PNG or class_name, and restore the Prairie Dog textures and the
lowforge tiles it rewrites: `git checkout -- art/models/prairie_dog_* tools/lowforge/tiles/`).

## A. The three verbs

### A1. Silence mutes keywords and never buffs

Rule (the bible's row): a Silenced machine's components' keywords are muted through its next
round, printed and granted alike (a Rapid entry acts once, a Spread lands one blow, a
Suppress suppresses nothing, Lure lures nobody, its own Cleanse is a plain shield); its buffs
count and its stores fill and spend as ever; cleansable (an ally's Cleanse); a Ward turns it
away. Cast with no condition, aimed as content says. A special, never a rider.

Engine:
- `sim/effects.gd`: the `silenced` status drops its `{"effect": "suppress", "value": "buff"}`
  effect and carries `{"trigger": "static", "effect": "mute_keywords", "value": 1}` again;
  `keywords_muted(u)` and the keyword stripping in `effective_face` come back from the code
  of 21 October, which `git show aecbd76^:sim/effects.gd` holds (search `mute_keywords`); the
  26 October commit `aecbd76` lists every file that removal touched (`git show aecbd76 --stat`),
  and each is restored the same way: `sim/foe.gd`, `sim/policy.gd` (the bot's worth of a die
  whose keywords are muted), `sim/skirmish.gd`, `game/ui/glyphs.gd`, `tests/test_skirmish.gd`.
  Volatile is a cost field now, not a keyword, so nothing needs exempting from the mute.
- `sim/skirmish.gd`: `_silence` and the `"silence"` special stay; the `silence` rider path in
  `_strike` and `_rides` goes (A4).
- Tests (`tests/test_skirmish.gd`): under a silence a Spread 2 weapon lands its blow alone; a
  Suppress piece suppresses nothing; a Rapid piece acts once; the machine's own Cleanse shield
  does not lift the silence while an ally's does; a buff component's Overcharged still counts
  under a silence; the Muster still fills; a Ward turns the silence away.
- Shown text: `content/vocabulary.json` `silence` and `silenced` codex to the rule above (the
  `design.holes` of each already says so); `docs/rules.md` Silenced entry and the foe
  specials list lose their "built with the ladder" and "until then" clauses.

### A2. Purge takes what a die face bought and sleeps what the machine is

Rule (the bible's row): the machine loses every buff a die face bought, every stack, for good;
what a store, a form or a passive grants goes for the rest of the enemy's turn and comes back
at the start of the player's turn after its start resolves; the stores stay; the Ammit's kept
Overcharged is its passive's own and stays; a Ward turns it away; a special, never a rider; a
Last Act never purges.

Engine, in `Effects.purge(u)` (`sim/effects.gd`), by each modifier `m` with `scope != LOADOUT`
and `tags` holding `"buff"`:
- kept: `u` carries a static `keep_status` effect naming `m.id` (the Ammit's Quintessence Tap
  on `overcharged`): untouched.
- bought: `m.source` begins with `"buff:"` (a buff component's spend, `Skirmish` line
  `var src := "buff:" + f.component`) or `"brace:"` (the Breaching Plow's braces rule):
  removed, as today.
- the machine's own: any other source (`"seal"`, the Armadillo's form; a passive's or a
  module's grant; a store's active effect when one exists): not removed; `m.slept = true`, a
  new `Modifier` field, which `Effects.live(u)` treats as absent (the modifier takes part in
  nothing while slept) and which `sim/save.gd` saves and loads with the modifier.
- `Skirmish.start_round()` wakes every slept modifier on every machine as its last step, after
  the cooling, the roll and the round-start passives, and logs "<machine>'s <buff> returns".
- `Effects.buff_stacks(u)` (the `buffed` aim) counts neither kept nor slept modifiers, so a
  purger aims at what it can take; a machine carrying only kept stacks reads as unbuffed.
- The `"dispel"` special stays the purge's move (`_foe_acts`); the rider path goes (A4).
- Tests: a Coil's Overcharged is gone for good; the sealed Armadillo loses its armour for the
  enemy's turn and has it back after the next round's start, its heat tax paid meanwhile; the
  Ammit's kept Overcharged stays and does not draw the buffed aim; a Ward turns the purge away;
  a save made in the enemy's turn restores a slept seal asleep.
- Shown: a slept buff's chip is drawn at half opacity on a dashed edge (structure, never hue
  alone) and its hold line reads "asleep until your turn" (placeholders, judged running on the
  phone; `RIFTGATE_FEED_DEBUG=1` is the pattern for a switch that keeps one asleep).
- `docs/rules.md`: the store paragraph and the Silenced entry lose their "(not built ...)"
  clauses once this lands.

### A3. A foe's Cleanse takes the team's marks off its own

Rule (the bible's row): a special on one of its own carrying a mark that takes every mark the
team laid; never Numbed, never Suppressed; weight one in content, never twice running (the
specials rule, already the engine's); its answers kill or suppress the cleanser first, spend
the Shock before it acts, burst.

Engine:
- A new special effect `cleanse` in `Foe.ACTION_EFFECTS["defend"]` and
  `Foe.UNTARGETED_EFFECTS`; a new condition `ally_marked` in `Foe.WHENS` and
  `Skirmish._condition_holds` (whatever the function that reads `WHENS` is called): true when
  any foe on the field, itself included, carries a mark from the list below.
- In `Skirmish._foe_acts`, `"cleanse"`: the target is the foe on its side, itself included,
  carrying the most marks, ties to the earlier in strike order; every mark on it is removed:
  the statuses with ids `burning`, `flakked`, `cryoed`, `vitriol`, `shocked`, `exposure`,
  `webbed`, `paradox`, `syrinx_drone`. Never `numbed`, never `suppressed`, never `guarded`,
  never a buff. The log says which went; the plaque names the move as content names it.
- The validator (`ContentDB._validate_foes`): `cleanse` takes no value; its `when`, if any,
  is `ally_marked`.
- The bot (`sim/policy.gd`): a cleanser's threat is the sum of the marks it would take off
  its side next action, each mark worth what the bot already values laying it (a Shock the
  biggest blow an ally still to act shows on that foe; Flak its stacks times the blows still
  to land; Burning its stacks; Exposed, Cryo, Vitriol, Webbed, the Paradox and the Drone a
  point each: placeholders).
- Tests: a cleanse takes Burning, Flak and a Shock off the most-marked ally and leaves Numbed
  and Suppressed; it never fires twice running; a Numbed-only ally is no target.
- `docs/rules.md`'s specials list: "cleanse" from planned to built.

### A4. Specials, never riders

`Foe.ATTACK_KEYWORDS` loses `"silence"` and `"dispel"`; `ContentDB._validate_foes` refuses
either on an attack and in an `on_death` blow's keywords; `Skirmish._strike` and `_rides`
drop their silence and purge branches. No content carries either as a rider today, so nothing
breaks; a test asserts the refusal.

## B. Four buffs cross to the foes

The same words, the same chips, the same vocabulary entries (`design.table.on` becomes
`"both"` for `primed`, `barrier`, `ward` and `regenerating`, and `regenerating` goes from
planned to implemented for the foe half; its machine half, the Storm Petrel's, stays planned
until that engine session). Each is a buff (tag `"buff"`) a purge takes (C). Semantics on a
foe, every one placeholders Ryan's play judges:

| On a foe | What it does | Lasts | Granted by the special |
|---|---|---|---|
| Primed N | its next blow leaves N stacks of Burning on the machine it hits, as a Burn N rider would | its next move spends it, as Kindled does | `prime`, value N: Primed N on every other foe on the field |
| Barrier | the next weapon blow it takes deals no damage; the blow's riders land; a debuff pops nothing | until popped, or the end of the player's next turn | `barrier`: on itself |
| Ward | no mark the team lays lands on it (the list in A3), Suppressed excepted, since Numbed stays the one stun resistance; damage lands; a turned mark feeds no Paradox | the end of the player's next turn | `ward_all`: on every foe on the field, itself included |
| Regenerating N | at each of its actions it regrows N HP, after Burning and Vitriol have ticked, so a burn is a race and never a wall | three of its actions | `regenerate`, value N: on itself |

Engine: `Foe.ACTION_EFFECTS`: `defend` gains `barrier`, `regenerate`; `buff` gains `prime`,
`ward_all`; all four join `UNTARGETED_EFFECTS`. `Skirmish._foe_acts` grants them (the
`braced` grants there are the pattern: `Effects.stack(f, Effects.STATUS[id], ...)`). Primed on
a foe is read where its blow's riders are laid (`_strike`), Barrier where a machine's blow
lands on a foe and Ward where a machine's keywords lay marks (`_resolve_attack`, and `_land`
for a mine's shot), Regenerating in `_foe_turn` after the ticks. The round preview's copy
(section 6's preview row) runs the same code, so it needs no work of its own; the chip row
draws any status, so the four show on foes without new chips. The validator: `prime` and
`regenerate` need a value of 1 or more; `barrier` and `ward_all` none. The bot values a foe's
Barrier as the biggest blow an ally still to act shows on it, a foe's Ward as nothing, Primed
as 2 a stack and Regenerating as its value times its actions left (placeholders). Tests: each
of the four on a foe, granted by its special, doing the row's thing, and taken by the player's
Purge (C).

## C. The player's Purge

Rule (the bible's row): a keyword on any entry aimed at a foe, every foe the entry reaches
losing every buff it carries but Numbed and Guarded; its name Purge on both sides, its id
`dispel` on both sides, as `breach` is one id for both.

Engine: `dispel` joins the player keywords (`Face`, the validator's known keywords); in
`_resolve_attack`, after the blow and with the riders, each foe struck loses the modifiers
with these ids: `braced`, `kindled`, `risen`, `primed`, `barrier`, `ward`, `regenerating`.
Never `numbed`, never `guarded`. On a debuff (no blow) it still strips. The bot's worth of a
Purge on a foe (`sim/policy.gd`): Getting Back Up the foe's maximum HP; Barrier the biggest
blow an ally still to act shows on it; Armoured its stacks times the allied blows still to
land on it this round; Kindled its value; Primed 2 a stack; Regenerating its value times its
actions left; Ward nothing (placeholders). The die's chip: a new glyph in `game/ui/glyphs.gd`,
a buff mark struck through (a placeholder, judged running).

Vocabulary: the `dispel` entry's `category` becomes `"keyword"` and its codex covers both
sides as `breach`'s does: "Purge. On a player's entry aimed at a foe, every foe it reaches
loses every buff it carries but Numbed and Guarded. On a foe's special, the machine it lands
on loses every buff a die face bought, every stack, for good, and what a store, a form or a
passive grants until the start of the player's turn after its start resolves; its stores stay.
A Ward turns it away." `silence` stays in the `foe` category.

The one piece, proposed by Claude, built unless Ryan strikes it (its name a working name for
his name pass), in `content/components.json`:

```json
{"id": "null_field_emitter", "name": "Null Field Emitter", "maker": "aphelion", "tier": 2,
 "tags": ["Arc"],
 "face": {"kind": "attack", "reach": "indirect", "heat": 2, "keywords": ["dispel"]},
 "codex": "A debuff. Every buff the foe carries is unmade: a brace, a rally, a readied return, a primed claw, a barrier, a ward, a regrowth. Numbed shrugs it off, and a guarded core keeps its guard.",
 "flavour": "Decoherence is not destruction. The field simply declines to remember what the subject was doing.",
 "design": {"fantasy": "The Science Vessel's EMP, slottable: Aphelion's physics nonsense unwriting the enemy's state. The jellyfish's EMP, when it lands, carries the same keyword on a blow with Disrupt (the bible's Aphelion row).", "niche": "The strip-it-or-shoot decision at tier two, Indirect so it reaches the commander in the back; stocked by nobody, a blueprint found."}}
```

No chassis stocks it. Shown text and numbers are placeholders.

## D. The ladder in content

### D1. The rule the numbers follow

The floor, every domain: tier two HP ×1.25 rounded up and a blow +1; tier three HP ×1.5
rounded up and a blow +2. The domain's dial on top, by the entries below: the Meadow's HP ×1 at
tier two and ×1.25 at tier three with the count rising in its lists instead; the Marsh's HP
×1.5 and ×2 in the floor's place; the Waste's and the Peak's as the floor, their dial in the
twists. Every number is a placeholder read on the bands (F); the base units' numbers do not
move. A recolour is its own foe type, so a swarm add counts its own kind only (Goblins and
Goblin Guards are two kinds), which the Meadow's count dial allows for.

Every recolour keeps its base's rank, zone, movespeed, behaviour and hunts unless the entry
says otherwise, and carries `"tier"`. A factored blow is `Foe.damage_of`'s: the base attack
(plus any rally and swarm) times the factor, rounded half up, so the entries below deal, at
their own numbers: the Grenade's burst 5 on every machine (9 × 0.5) and its flare 3, the
Balloon's burst 5 and its flare 3, the Great Needler's thousand needles 10 (5 × 2), the
Antlion Queen's swallow 10 (8 × 1.25), the Wyvern's dive 9 (6 × 1.5), the Red Dragon's crush
10 (7 × 1.4), and every other move its attack; a rally or a swarm adds before the factor. A base's planned moves (the Needler's Scatter, the
Salamander's Ember Hide) are not copied onto its recolours. A split: the Bubble Gel splits
into two Half-Gels as the Gel does; the Metal Gel does not split. `codex` and `flavour` are
shown text, placeholders in the game's voice for Ryan's name pass; `design.fantasy` is
internal.

### D2. The entries

Add to `content/foes.json`'s `entries`, exactly these; the validator's checks are the arbiter
of shape (a foe's keys, an action's keys and its `status`), and a key the validator refuses is
removed, never worked around.

```json
[
{"id": "goblin_guard", "name": "Goblin Guard", "faction": "meadow", "tier": 2, "hp": 3, "attack": 3, "rank": "front", "zone": 1, "movespeed": 20, "behaviour": "hunt", "hunts": "nearest",
 "actions": [
  {"id": "stab", "name": "Stab", "kind": "attack", "swarm": 1, "weight": 2, "text": "A knife from the crowd for {damage}: more for every other guard standing.", "status": "implemented"},
  {"id": "shield_wall", "name": "Shield Wall", "kind": "defend", "effect": "brace", "value": 1, "weight": 1, "text": "Raises a scrap shield: armour +{value} until its next action.", "status": "implemented"}],
 "codex": "A goblin that found a shield. It braces when it is not stabbing, so the swarm takes a blow more to clear.", "flavour": "Gate order one still stands. Add: some of the green ones carry doors now.",
 "design": {"fantasy": "The genre's second goblin, the one with the shield. Tier two of the goblin line."}},
{"id": "goblin_captain", "name": "Goblin Captain", "faction": "meadow", "tier": 3, "hp": 4, "attack": 4, "rank": "back", "zone": 3, "movespeed": 20, "behaviour": "hunt", "hunts": "nearest",
 "actions": [
  {"id": "stab", "name": "Stab", "kind": "attack", "swarm": 1, "weight": 2, "text": "A knife from the crowd for {damage}: more for every other captain standing.", "status": "implemented"},
  {"id": "warcry", "name": "Warcry", "kind": "buff", "effect": "rally", "value": 1, "weight": 1, "when": "others_on_field", "text": "Every other foe on the field hits {value} harder at its next move.", "status": "implemented"}],
 "codex": "The goblin that shouts. It stands at the back and rallies the rest, so the swarm hits harder while it lives.", "flavour": "They have ranks. We do not know how they decide them. We suspect volume.",
 "design": {"fantasy": "The goblin chieftain, the commander in the crowd. Tier three of the goblin line."}},
{"id": "warg", "name": "Warg", "faction": "meadow", "tier": 2, "hp": 4, "attack": 4, "rank": "front", "zone": 1, "movespeed": 30, "behaviour": "hunt", "hunts": "weakest",
 "actions": [
  {"id": "bite", "name": "Bite", "kind": "attack", "weight": 2, "text": "Teeth in the hull for {damage}.", "status": "implemented"},
  {"id": "howl", "name": "Howl", "kind": "buff", "effect": "rally", "value": 1, "weight": 1, "when": "others_on_field", "text": "Every other foe on the field hits {value} harder at its next move.", "status": "implemented"}],
 "codex": "A bigger wolf that picks the weakest machine on the field and runs it down.", "flavour": "The wolves learned which of us limps.",
 "design": {"fantasy": "The dire wolf's bigger cousin, the hunter of the hurt. Tier two of the wolf line."}},
{"id": "alpha_warg", "name": "Alpha Warg", "faction": "meadow", "tier": 3, "hp": 5, "attack": 5, "rank": "front", "zone": 1, "movespeed": 30, "behaviour": "hunt", "hunts": "weakest",
 "actions": [
  {"id": "bite", "name": "Bite", "kind": "attack", "weight": 2, "text": "Teeth in the hull for {damage}.", "status": "implemented"},
  {"id": "howl", "name": "Howl", "kind": "buff", "effect": "rally", "value": 2, "weight": 1, "when": "others_on_field", "text": "Every other foe on the field hits {value} harder at its next move.", "status": "implemented"}],
 "codex": "The pack's leader. Its howl lifts every foe on the field, and it hunts the weakest machine.", "flavour": "When the big one howls, kill it or shield everyone. There is no third option.",
 "design": {"fantasy": "The alpha, the pack's commander. Tier three of the wolf line."}},
{"id": "bubble_gel", "name": "Bubble Gel", "faction": "meadow", "tier": 2, "hp": 5, "attack": 4, "armour": 1, "rank": "front", "zone": 1, "movespeed": 20, "on_death": {"summon": "gel_half", "count": 2, "pair": true},
 "actions": [{"id": "engulf", "name": "Engulf", "kind": "attack", "weight": 2, "text": "Flows over the hull for {damage}.", "status": "implemented"}],
 "codex": "A gel with a skin. Small blows slide off it, and it splits into halves like any gel.", "flavour": "It is not harder to kill. It is harder to scratch.",
 "design": {"fantasy": "The genre's second slime, the bubbly one. Tier two of the gel line: a wall that walls small blows."}},
{"id": "metal_gel", "name": "Metal Gel", "faction": "meadow", "tier": 3, "hp": 3, "attack": 5, "armour": 3, "rank": "front", "zone": 1, "movespeed": 20,
 "actions": [{"id": "engulf", "name": "Engulf", "kind": "attack", "weight": 2, "text": "Flows over the hull for {damage}.", "status": "implemented"}],
 "codex": "A gel of living metal: little inside it, but three points of plate on every blow. Flak and Overcharged are the answer, or one big blow.", "flavour": "Field note: shooting it is like shooting the gate. Hit it with something that counts.",
 "design": {"fantasy": "The metal slime, the genre's armoured joke made a wall. Tier three of the gel line; no split, since the plate is the whole of it."}},
{"id": "mandrake", "name": "Mandrake", "faction": "meadow", "tier": 2, "hp": 4, "attack": 4, "rank": "back", "zone": 3, "movespeed": 20,
 "actions": [
  {"id": "root_lash", "name": "Root Lash", "kind": "attack", "weight": 2, "text": "A whip of root for {damage}.", "status": "implemented"},
  {"id": "scream", "name": "Scream", "kind": "debuff", "effect": "drain_rerolls", "value": 2, "weight": 1, "text": "Costs the team two rerolls next round.", "status": "implemented"}],
 "codex": "A mandragora with lungs. Its scream costs the team two rerolls.", "flavour": "The screaming is not the attack. The screaming is what it does to your plan.",
 "design": {"fantasy": "The mandrake, the louder root. Tier two of the mandragora line."}},
{"id": "alraune", "name": "Alraune", "faction": "meadow", "tier": 3, "hp": 5, "attack": 5, "rank": "back", "zone": 3, "movespeed": 20,
 "actions": [
  {"id": "root_lash", "name": "Root Lash", "kind": "attack", "weight": 2, "text": "A whip of root for {damage}.", "status": "implemented"},
  {"id": "shriek", "name": "Shriek", "kind": "debuff", "effect": "disable", "weight": 1, "text": "Turns what one machine's die is showing to wood, through its next turn.", "status": "implemented"}],
 "codex": "The flowering root. Its shriek switches off the component a machine's die is showing.", "flavour": "Pretty, from a distance. Keep the distance.",
 "design": {"fantasy": "The alraune, the genre's flower woman, here a root that steals an entry. Tier three of the mandragora line."}},
{"id": "barbed_needler", "name": "Barbed Needler", "faction": "waste", "tier": 2, "hp": 3, "attack": 4, "rank": "front", "zone": 1, "movespeed": 30, "behaviour": "hunt", "hunts": "nearest",
 "actions": [{"id": "needles", "name": "Needles", "kind": "attack", "weight": 2, "keywords": ["breach", "corrupt"], "corrupt": 1, "text": "Exactly {damage} barbed needles, through the shield; the one it is showing bites when spent.", "status": "implemented"}],
 "codex": "A needler whose needles stay in. Its blow goes through the shield and corrupts the component the machine is showing.", "flavour": "Count the needles. Then count the ones you cannot find.",
 "design": {"fantasy": "The cactuar's barbed cousin: the Waste's theft of entries on the rank and file. Tier two of the needler line."}},
{"id": "great_needler", "name": "Great Needler", "faction": "waste", "tier": 3, "hp": 3, "attack": 5, "rank": "front", "zone": 1, "movespeed": 30, "behaviour": "hunt", "hunts": "nearest",
 "actions": [
  {"id": "needles", "name": "Needles", "kind": "attack", "weight": 2, "keywords": ["breach"], "text": "Exactly {damage} needles, through the shield.", "status": "implemented"},
  {"id": "thousand_needles", "name": "Thousand Needles", "kind": "attack", "factor": 2, "countdown": 2, "weight": 1, "keywords": ["breach"], "text": "Gathers for two rounds, then {damage} needles through the shield at once.", "status": "implemented"}],
 "codex": "The big one. It gathers for two rounds and then puts every needle through the shield at once. Kill it, suppress it, or shield what it has picked.", "flavour": "If it starts counting, you have two rounds.",
 "design": {"fantasy": "The giant cactuar and its thousand needles, a countdown. Tier three of the needler line."}},
{"id": "pit_antlion", "name": "Pit Antlion", "faction": "waste", "tier": 2, "hp": 8, "attack": 7, "rank": "front", "zone": 1, "movespeed": 20, "behaviour": "hunt", "hunts": "slowest",
 "actions": [
  {"id": "mandibles", "name": "Mandibles", "kind": "attack", "weight": 2, "keywords": ["breach"], "text": "Jaws close on the hull for {damage}, through the shield.", "status": "implemented"},
  {"id": "burrow", "name": "Burrow", "kind": "defend", "effect": "barrier", "weight": 1, "when": "below_half", "text": "Sinks into the sand: the next weapon blow on it deals nothing.", "status": "implemented"}],
 "codex": "An antlion whose jaws go through the shield, and whose burrow swallows the next blow whole. Pop the barrier with a cheap blow, then hit it.", "flavour": "The sand moved. Then the sand had jaws.",
 "design": {"fantasy": "The pit's antlion: breach on one more Waste type, and the burrow that is a Barrier. Tier two of the antlion line."}},
{"id": "antlion_queen", "name": "Antlion Queen", "faction": "waste", "tier": 3, "hp": 9, "attack": 8, "rank": "front", "zone": 1, "movespeed": 20, "behaviour": "hunt", "hunts": "slowest",
 "actions": [
  {"id": "mandibles", "name": "Mandibles", "kind": "attack", "weight": 2, "text": "Jaws close on the hull for {damage}.", "status": "implemented"},
  {"id": "swallow", "name": "Swallow", "kind": "attack", "factor": 1.25, "countdown": 1, "weight": 1, "keywords": ["breach"], "text": "Rears for a round, then swallows a machine for {damage}, through the shield.", "status": "implemented"},
  {"id": "burrow", "name": "Burrow", "kind": "defend", "effect": "brace", "value": 3, "weight": 1, "when": "below_half", "text": "Digs in: armour +{value} until its next action.", "status": "implemented"}],
 "codex": "The queen of the pit. Its swallow is announced a round ahead and goes through the shield; hurt, it digs in behind three points of plate.", "flavour": "Everything in the badlands is something's lunch. This is the something.",
 "design": {"fantasy": "The antlion grown to a queen: the Waste's big fixed blow on a countdown. Tier three of the antlion line."}},
{"id": "basilisk", "name": "Basilisk", "faction": "waste", "tier": 2, "hp": 5, "attack": 4, "rank": "back", "zone": 3, "movespeed": 20, "aim": "armed",
 "actions": [
  {"id": "peck", "name": "Peck", "kind": "attack", "weight": 2, "text": "A beak like a pick, for {damage}.", "status": "implemented"},
  {"id": "stone", "name": "Stone", "kind": "debuff", "effect": "disable", "weight": 1, "text": "Turns what one machine's die is showing to stone, through its next turn.", "status": "implemented"}],
 "codex": "A cockatrice with an eye for weapons: it aims at a machine showing an intact gun, and its stone switches the gun off.", "flavour": "It looks at what you are pointing at it. Then that stops working.",
 "design": {"fantasy": "The basilisk, the gaze that picks the armed. Tier two of the cockatrice line."}},
{"id": "gorgon", "name": "Gorgon", "faction": "waste", "tier": 3, "hp": 6, "attack": 5, "rank": "back", "zone": 3, "movespeed": 20, "aim": "armed",
 "actions": [
  {"id": "peck", "name": "Peck", "kind": "attack", "weight": 2, "keywords": ["corrupt"], "corrupt": 1, "text": "A beak like a pick, for {damage}; the component the machine is showing bites when spent.", "status": "implemented"},
  {"id": "stone", "name": "Stone", "kind": "debuff", "effect": "disable", "weight": 1, "text": "Turns what one machine's die is showing to stone, through its next turn.", "status": "implemented"}],
 "codex": "The gaze that corrupts. Its peck leaves the component a machine is showing biting its owner, and its stone switches one off.", "flavour": "The Waste takes what you have. This one takes it and leaves it in you.",
 "design": {"fantasy": "The gorgon, theft of entries by corruption on the back rank. Tier three of the cockatrice line."}},
{"id": "wight", "name": "Wight", "faction": "marsh", "tier": 2, "hp": 5, "attack": 3, "rank": "front", "zone": 1, "movespeed": 20, "behaviour": "hunt", "hunts": "nearest",
 "actions": [
  {"id": "claw", "name": "Claw", "kind": "attack", "swarm": 1, "weight": 2, "text": "Tears at anything in reach for {damage}: more for every other wight standing.", "status": "implemented"},
  {"id": "grave_mend", "name": "Grave Mend", "kind": "defend", "effect": "regenerate", "value": 2, "weight": 1, "when": "missing_hull", "text": "Knits itself: regrows {value} at each of its next three actions.", "status": "implemented"}],
 "codex": "A revenant that knits itself back together. Hurt, it regrows a little at each action for three rounds: burst it, or purge the mending.", "flavour": "You can hear it mending. Finish it before it finishes.",
 "design": {"fantasy": "The wight, the Marsh's hard-to-keep-down on the rank and file: Regenerating as a foe's buff. Tier two of the revenant line."}},
{"id": "lich", "name": "Lich", "faction": "marsh", "tier": 3, "hp": 6, "attack": 4, "rank": "back", "zone": 3, "movespeed": 20,
 "actions": [
  {"id": "soul_bolt", "name": "Soul Bolt", "kind": "attack", "weight": 2, "text": "A bolt of cold for {damage}.", "status": "implemented"},
  {"id": "reraise", "name": "Reraise", "kind": "buff", "effect": "revive_once_ally", "weight": 1, "when": "ally_unready", "text": "Readies one of its own, never itself: the next time it falls it gets back up, whole, once.", "status": "implemented"},
  {"id": "dark_rite", "name": "Dark Rite", "kind": "defend", "effect": "regrow_all", "value": 3, "countdown": 2, "weight": 1, "text": "A rite that lands two rounds on: every foe on its side regrows {value}.", "status": "planned"}],
 "codex": "The dead that commands the dead. It readies an ally to get back up once, and strikes from the back. Reach it, or purge what it readies.", "flavour": "It does not fight. It makes sure the others do not stop.",
 "design": {"fantasy": "The lich, the Marsh's commander. Tier three of the revenant line. Its Dark Rite, a delayed heal on a countdown, is planned until the engine has a special with a countdown (Ryan, 28 October, mentioned a delayed heal; not built here)."}},
{"id": "spectre", "name": "Spectre", "faction": "marsh", "tier": 2, "hp": 6, "attack": 4, "rank": "back", "zone": 3, "movespeed": 20,
 "actions": [
  {"id": "hex_bolt", "name": "Hex Bolt", "kind": "attack", "weight": 2, "text": "A bolt of grave-light for {damage}.", "status": "implemented"},
  {"id": "raise", "name": "Raise", "kind": "buff", "effect": "summon", "foe": "revenant", "count": 1, "weight": 1, "text": "Raises a revenant into an empty place at once, or into the pool when the line is full.", "status": "implemented"},
  {"id": "hallow", "name": "Hallow", "kind": "defend", "effect": "cleanse", "weight": 1, "when": "ally_marked", "text": "Takes every mark the team laid off the most-marked of its own.", "status": "implemented"}],
 "codex": "A ghost that keeps its dead clean. Its hallow strips the burns, flak and shocks the team has laid on one of its own: kill it first, or cash the marks before it acts.", "flavour": "Debuffs are hard here. Write that on the gate.",
 "design": {"fantasy": "The spectre, the Marsh's cleanser: the domain's lever (Ryan, 28 October, 'debuffs are hard here'). Tier two of the ghost line."}},
{"id": "wraith", "name": "Wraith", "faction": "marsh", "tier": 3, "hp": 8, "attack": 5, "rank": "back", "zone": 3, "movespeed": 20,
 "actions": [
  {"id": "hex_bolt", "name": "Hex Bolt", "kind": "attack", "weight": 2, "keywords": ["corrupt"], "corrupt": 1, "text": "A bolt of grave-light for {damage}; the component the machine is showing bites when spent.", "status": "implemented"},
  {"id": "raise", "name": "Raise", "kind": "buff", "effect": "summon", "foe": "revenant", "count": 1, "weight": 1, "text": "Raises a revenant into an empty place at once, or into the pool when the line is full.", "status": "implemented"},
  {"id": "hallow", "name": "Hallow", "kind": "defend", "effect": "cleanse", "weight": 1, "when": "ally_marked", "text": "Takes every mark the team laid off the most-marked of its own.", "status": "implemented"}],
 "codex": "The spectre's elder. Its bolt corrupts the component a machine is showing, it raises the dead, and it keeps them clean of the team's marks.", "flavour": "Three jobs, one ghost. Reach it.",
 "design": {"fantasy": "The wraith, the Ghost's curse (the proposal's rider on one advanced foe a domain) and the cleanse together. Tier three of the ghost line."}},
{"id": "death_knight", "name": "Death Knight", "faction": "marsh", "tier": 2, "hp": 12, "attack": 7, "armour": 1, "rank": "front", "zone": 1, "movespeed": 20,
 "actions": [
  {"id": "cleaver", "name": "Cleaver", "kind": "attack", "keywords": ["breach"], "weight": 2, "text": "A sword longer than it is tall, for {damage}.", "status": "implemented"},
  {"id": "grave_guard", "name": "Grave Guard", "kind": "defend", "effect": "brace_all", "value": 1, "weight": 1, "when": "others_on_field", "text": "Every foe on its side is Armoured +{value} through the next round.", "status": "implemented"},
  {"id": "reraise", "name": "Reraise", "kind": "buff", "effect": "revive_once", "weight": 1, "when": "missing_hull", "text": "Readies itself once it is hurt: the next time it falls it gets back up, whole, once.", "status": "implemented"}],
 "codex": "A zombie knight that guards the rest: its grave guard armours every foe on the field through the next round, and it gets back up once.", "flavour": "The knight stands in front. Everything behind it is harder to hurt while it does.",
 "design": {"fantasy": "The death knight, the Marsh's guard ('this guy protects his allies'). Tier two of the zombie knight line."}},
{"id": "dread_knight", "name": "Dread Knight", "faction": "marsh", "tier": 3, "hp": 16, "attack": 8, "armour": 1, "rank": "front", "zone": 1, "movespeed": 20,
 "on_death": {"blow": {"name": "Death Throes", "factor": 1, "strikes": 1}},
 "actions": [
  {"id": "cleaver", "name": "Cleaver", "kind": "attack", "keywords": ["breach"], "weight": 2, "text": "A sword longer than it is tall, for {damage}.", "status": "implemented"},
  {"id": "reraise", "name": "Reraise", "kind": "buff", "effect": "revive_once", "weight": 1, "when": "missing_hull", "text": "Readies itself once it is hurt: the next time it falls it gets back up, whole, once.", "status": "implemented"}],
 "codex": "A knight that strikes as it falls: its death throes land a blow the moment it dies, before anything else. Shield up before the kill. It gets back up once, too.", "flavour": "It dies the way it fought. Twice, if you let it.",
 "design": {"fantasy": "The dread knight, the Marsh's last act carrier (the engine's Last Act, no carrier until now). Tier three of the zombie knight line."}},
{"id": "grenade", "name": "Grenade", "faction": "peak", "tier": 2, "hp": 5, "attack": 9, "rank": "front", "zone": 1, "movespeed": 30, "behaviour": "hunt", "hunts": "nearest",
 "actions": [
  {"id": "flare_up", "name": "Flare Up", "kind": "attack", "factor": 0.34, "weight": 2, "keywords": ["scorch"], "scorch": 2, "text": "A lick of fire for {damage}. It scorches.", "status": "implemented"},
  {"id": "self_destruct", "name": "Self-Destruct", "kind": "attack", "factor": 0.5, "weight": 3, "keywords": ["breach", "self_destruct", "all"], "when": "below_half", "text": "Bursts for {damage} on every machine, through the shield, and is gone.", "status": "implemented"}],
 "codex": "A bomb that bursts on everyone: hurt, its self-destruct lands on every machine in the fight, through the shield. Kill it whole, or suppress it.", "flavour": "The small ones you shield against. The grenade you kill before it gets the idea.",
 "design": {"fantasy": "The genre's own ladder, Bomb to Grenade to Balloon: the burst at every machine. Tier two of the bomb line."}},
{"id": "balloon", "name": "Balloon", "faction": "peak", "tier": 3, "hp": 6, "attack": 10, "rank": "front", "zone": 1, "movespeed": 30, "behaviour": "hunt", "hunts": "nearest",
 "actions": [
  {"id": "flare_up", "name": "Flare Up", "kind": "attack", "factor": 0.34, "weight": 2, "keywords": ["scorch"], "scorch": 2, "text": "A lick of fire for {damage}. It scorches.", "status": "implemented"},
  {"id": "self_destruct", "name": "Self-Destruct", "kind": "attack", "factor": 0.5, "countdown": 1, "weight": 3, "keywords": ["breach", "self_destruct", "all", "scorch"], "scorch": 2, "when": "below_half", "text": "Swells for a round, then bursts for {damage} on every machine, through the shield and scorching, and is gone.", "status": "implemented"}],
 "codex": "The bomb that swells. Its burst is announced a round ahead, then lands on every machine, through the shield and scorching. One round to kill it, suppress it, or shield everyone.", "flavour": "It is not getting bigger. It is getting closer to done.",
 "design": {"fantasy": "The balloon, the last of the bomb line: the countdown on the burst. Tier three of the bomb line."}},
{"id": "fire_lizard", "name": "Fire Lizard", "faction": "peak", "tier": 2, "hp": 8, "attack": 6, "rank": "front", "zone": 1, "movespeed": 20,
 "actions": [{"id": "bite", "name": "Bite", "kind": "attack", "weight": 2, "keywords": ["scorch"], "scorch": 3, "text": "A burning bite for {damage}. It scorches, ×3.", "status": "implemented"}],
 "codex": "A salamander that scorches deeper: three stacks a bite, so every gun the machine fires next turn runs three hotter.", "flavour": "The bite is the small problem. The next turn is the big one.",
 "design": {"fantasy": "The fire lizard, the Peak's heat on more of its rank and file. Tier two of the salamander line."}},
{"id": "magma_lizard", "name": "Magma Lizard", "faction": "peak", "tier": 3, "hp": 9, "attack": 7, "rank": "front", "zone": 1, "movespeed": 20,
 "actions": [
  {"id": "bite", "name": "Bite", "kind": "attack", "weight": 2, "keywords": ["scorch"], "scorch": 2, "text": "A burning bite for {damage}. It scorches.", "status": "implemented"},
  {"id": "stoke_the_pack", "name": "Stoke the Pack", "kind": "buff", "effect": "prime", "value": 1, "weight": 1, "when": "others_on_field", "text": "Lights the others: every other foe's next blow leaves {value} Burning.", "status": "implemented"}],
 "codex": "A salamander that lights the rest: its stoke primes every other foe, so their next blows leave the machine Burning. Kill it first, or Ward what they are aimed at.", "flavour": "One of them is the match. Find the match.",
 "design": {"fantasy": "The magma lizard, the Peak's primer: Primed as a foe's buff. Tier three of the salamander line."}},
{"id": "wyvern", "name": "Wyvern", "faction": "peak", "tier": 2, "hp": 5, "attack": 6, "rank": "back", "zone": 3, "movespeed": 20,
 "actions": [
  {"id": "breath", "name": "Breath", "kind": "attack", "weight": 2, "keywords": ["scorch"], "scorch": 2, "text": "A gout of fire for {damage}, over the front rank. It scorches.", "status": "implemented"},
  {"id": "dive", "name": "Dive", "kind": "attack", "factor": 1.5, "weight": 1, "keywords": ["breach"], "text": "Drops on a machine for {damage}, through the shield.", "status": "implemented"},
  {"id": "stoke", "name": "Stoke", "kind": "debuff", "effect": "burn", "value": 4, "weight": 1, "text": "Sets a machine burning, ×{value}.", "status": "implemented"}],
 "codex": "A drake that dives: beside its breath and its stoke, a blow through the shield at half again its bite. The spike the Barrier is for.", "flavour": "When it climbs, it is not leaving.",
 "design": {"fantasy": "The wyvern, the Peak's telegraphed spike on the rank and file. Tier two of the drake line."}},
{"id": "red_dragon", "name": "Red Dragon", "faction": "peak", "tier": 3, "hp": 6, "attack": 7, "rank": "back", "zone": 3, "movespeed": 20, "aim": "heat",
 "actions": [
  {"id": "breath", "name": "Breath", "kind": "attack", "weight": 2, "keywords": ["scorch"], "scorch": 2, "text": "A gout of fire for {damage}, over the front rank. It scorches.", "status": "implemented"},
  {"id": "crush", "name": "Crush", "kind": "attack", "factor": 1.4, "countdown": 1, "weight": 1, "text": "Rears for a round, then comes down on a machine for {damage}.", "status": "implemented"},
  {"id": "flame_breath", "name": "Flame Breath", "kind": "debuff", "effect": "scorch_all", "value": 2, "weight": 1, "text": "Fire over every machine: every machine scorched, ×{value}.", "status": "implemented"},
  {"id": "stoke", "name": "Stoke", "kind": "debuff", "effect": "burn", "value": 5, "weight": 1, "text": "Sets a machine burning, ×{value}.", "status": "implemented"}],
 "codex": "The dragon. It goes for the hottest machine, scorches everyone at once, and its crush is announced a round ahead. Cool the machine it wants, shield it, or kill the dragon.", "flavour": "Every fire cave has one. This is why the cave is empty.",
 "design": {"fantasy": "The red dragon, the Peak's capstone of the rank and file: the aim at heat, the scorch on everyone, the countdown. Tier three of the drake line."}}
]
```

Where a shape above fails the validator (a `countdown` on a `defend` special, an `aim` on a
foe, an `on_death` blow's keys), the validator's own rule decides and the entry is trimmed to
it, the change noted in the status; nothing is added to the engine for an entry's sake except
what sections A to C already say.

### D3. The spawn lists by tier

`content/factions.json`: each domain's `spawn` becomes a dictionary keyed by the tier as a
string, `"1"` today's list unchanged, exactly:

```json
"meadow": {"1": [["goblin", 6], ["wolf", 3], ["gel", 4], ["mandragora", 2]],
           "2": [["goblin", 3], ["goblin_guard", 4], ["warg", 4], ["gel", 3], ["bubble_gel", 2], ["mandrake", 3]],
           "3": [["goblin_guard", 4], ["goblin_captain", 4], ["alpha_warg", 4], ["bubble_gel", 2], ["metal_gel", 3], ["mandrake", 2], ["alraune", 3]]},
"waste":  {"1": [["needler", 5], ["antlion", 2], ["cockatrice", 2]],
           "2": [["needler", 3], ["barbed_needler", 3], ["pit_antlion", 2], ["basilisk", 2]],
           "3": [["barbed_needler", 3], ["great_needler", 2], ["pit_antlion", 1], ["antlion_queen", 1], ["basilisk", 1], ["gorgon", 2]]},
"marsh":  {"1": [["revenant", 6], ["zombie_knight", 2], ["ghost", 3]],
           "2": [["revenant", 3], ["wight", 4], ["death_knight", 2], ["spectre", 3]],
           "3": [["wight", 4], ["lich", 1], ["death_knight", 1], ["dread_knight", 2], ["spectre", 2], ["wraith", 2]]},
"peak":   {"1": [["bomb", 4], ["salamander", 3], ["drake", 2]],
           "2": [["bomb", 2], ["grenade", 3], ["fire_lizard", 3], ["wyvern", 2]],
           "3": [["grenade", 2], ["balloon", 2], ["fire_lizard", 2], ["magma_lizard", 2], ["wyvern", 1], ["red_dragon", 2]]}
```

(written in the file as the entries' existing `{"foe": ..., "strength": ...}` objects.) The
order within a list is the spawn cycle's and the strike order's: hitters and walls first, the
back rank last, as today's lists are.

Engine: `ContentDB.spawn_table(faction_id, tier)` takes the tier (1 to 3, the shown number)
and returns that list; a tier with no list falls back to the highest tier under it, and the
validator asks every domain for a `"1"`. Its readers and the tier each passes:
`sim/battle.gd` (the battle's `tier` as the campaign sets it, `tier + 1` where the code counts
0 to 2: the same number the boss row's scaling reads); `sim/quick_run.gd` `formation_foes`
(its battle's tier, a convenience and never a read); `sim/content_db.gd` `escort_units`
(the battle's tier, the tier's list, round robin in spawn order, never massive, in place of
"else of the highest tier under it" by a unit's own `tier`); `sim/harness_setup.gd`,
`sim/loadouts.gd`, `game/skirmish/skirmish_screen.gd` and the probes (tier 1, or the tier the
harness is asked for); `tools/balance.gd` (F). `sim/save.gd` stores the resolved list and
changes nothing. The campaign's rifts deal the battle's tier as the Convergence counts it (tier
two from 4, tier three from 8); a rift's own tier fixed as it opens is the curve proposal's
open form and is not built.

### D4. Records of content

`tools/hangar_data.py` and the hangar page republished after the content lands (the README's
procedure); `python3 tools/pages/bible_tables.py` before the bible is republished;
`tools/export_vocabulary.gd` after the vocabulary changes; `content/foes.json`'s `_about`
gains one sentence on `tier` and the recolours.

## E. The sprites

A recolour is its base's sprite with its hues shifted and its greys tinted, the same transform
on `art/foes/<base>_combat.png` and `<base>_map.png`, written beside them as
`art/foes/<id>_combat.png` and `<id>_map.png`, then `--import`. The script,
`tools/recolour.py <base> <id> --hue H --light L [--tint T]`: for every opaque pixel whose
lightness (HLS) lies between 0.12 and 0.95 (the outline and the whites untouched), a
saturated pixel (saturation 0.15 or more) has its hue rotated by H degrees and its lightness
multiplied by L; a grey pixel (under 0.15) takes hue H outright at saturation T when T is
given, else stays; the alpha never changes. No other marker (Ryan, 28 October). The table,
chosen by Claude on 28 October by the three Machado simulations (protan, deutan, tritan,
severity 1.0, in linear RGB): the mean per-pixel distance in simulated sRGB between the
recolour and its base, and between the two recolours of a base, each at its worst simulation;
the method and its run are the scratch script's and the numbers below are what it chose, the
weakest pair the Zombie Knight's (dark metal moves little):

| Base | Tier 2 | Tier 3 |
|---|---|---|
| goblin | goblin_guard: hue 240, light 0.80, tint 0.45 | goblin_captain: hue 180, light 1.25, tint 0.45 |
| wolf | warg: hue 60, light 1.25, tint 0.45 | alpha_warg: hue 240, light 0.80, tint 0.45 |
| gel | bubble_gel: hue 150, light 0.80 | metal_gel: hue 180, light 1.25 |
| mandragora | mandrake: hue 210, light 1.25 | alraune: hue 60, light 1.25 |
| needler | barbed_needler: hue 180, light 0.80, tint 0.45 | great_needler: hue 270, light 0.80, tint 0.45 |
| antlion | pit_antlion: hue 210, light 0.80 | antlion_queen: hue 150, light 1.25 |
| cockatrice | basilisk: hue 210, light 0.80 | gorgon: hue 180, light 1.25 |
| revenant | wight: hue 240, light 0.80, tint 0.45 | lich: hue 60, light 1.25, tint 0.45 |
| ghost | spectre: hue 240, light 0.80, tint 0.45 | wraith: hue 60, light 1.25, tint 0.45 |
| zombie_knight | death_knight: hue 60, light 1.25, tint 0.45 | dread_knight: hue 240, light 0.80, tint 0.45 |
| bomb | grenade: hue 180, light 1.25, tint 0.45 | balloon: hue 240, light 1.00 |
| salamander | fire_lizard: hue 210, light 1.25 | magma_lizard: hue 60, light 1.25 |
| drake | wyvern: hue 240, light 1.25 | red_dragon: hue 60, light 1.25 |

Ryan judges the sprites on the phone; a pair he cannot tell apart gets a lightness step
first, never a marker. The `.import` files land with the PNGs (a cloud session has Godot now).

## F. The reads

- `tools/balance.gd`: a formation cell per domain per tier from the tier's list ("The Meadow
  formation, tier 2" and so on), and a rank-and-file pack cell for every recolour at its
  list's strength, beside today's cells; the rows unchanged.
- First, in the session: the new cells alone at 30 seeds (`--packs` with their ids), random and
  greedy, every row: a direction, called one. Then the whole matrix at 200 seeds on the desk
  machine, in parts (the README's `--part` and `--merge`), the read's standard.
- Written to `docs/measurements.md` under its date with the seeds, and read as bands, never
  chased: a tier-two cell should cost a tier-one row more than the tier-one cell of the same
  domain does, and a tier-three cell more again; random play should win no tier-three
  rank-and-file cell with a tier-one stock; the formations at tier three should be a wall for
  any single machine and a fight for a four; the Cassowary's and the Ammit's rows against the
  purging and cleansing cells named in the to-do. A cell that reads too easy or walled at
  these placeholders is reported with the number that would move it, and the number moves only
  on Ryan's word.
- The campaign report (`tools/campaign_run.gd --runs 40`) rerun once, for the record, since
  the tier-two and tier-three battles now field the ladder; read as the spiral it was. No
  quick campaign read is cited.

## G. The records after the build

`docs/rules.md` (the Silenced entry, the store paragraph, the specials list, the boss
paragraph's spawn sentence, the campaign's and battle's spawn rule by tier); the bible's rows
named under "Read first" gain "Built <date>" where they say built with the ladder, and no row
is rewritten beyond that; `content/vocabulary.json` (A1, C) with `docs/vocabulary.md` exported
and the tables regenerated; the bible republished by the README's procedure (read the live
page first, merge three ways if it moved); the hangar page; `docs/status.md` (How things
stand, the Pages lines, the order of work); `docs/todo.md` (the ladder line ticked, the
carriers line updated to what landed, the Ammit test line left for its read); this brief
retired to git once its decisions are rows and content.

## Not in this build, and not to be guessed at

Ask Ryan in chat before touching any of these; none blocks the sections above.

- The compositions (a pack as a composition on one hex, members, the front-and-back arriving
  together), the patrols and the fight sizes, the Rupture meter, its Fractures and the seal,
  the stall guard, the Fracture's prize, menace as a weight, the elites and their moment, the
  bosses' hand-tailored escort compositions, roles on the codex: `docs/foes_proposal.md`'s
  questions 1 to 12, every one open. The escorts keep drawing from the tier's list as D3 says.
- A guest's members inside a formation (the compositions' work): the guest stays the map's
  alternating packs as today.
- A rift's own tier fixed as it opens, the shown number on the card, the ramp (the curve
  proposal's open form). The battle's tier as the Convergence counts it is what this build
  reads.
- The Lich's Dark Rite (a special with a countdown): planned, kept, not run.
- Enemy Shock, telegraphed; the Ghost's curse as a rider on the base Ghost (the proposal's
  question 13): not here; the Wraith's corrupt is the ladder's own.
- The Purge piece's maker, name and numbers if Ryan objects; every name on the ladder and
  every move name (working names, his name pass); every number (placeholders).
- The front card's warning of a purge among the leaders (the mission map); the jellyfish's EMP
  (its chassis session).
- Any base unit's numbers, moves or sprite; the massive foes and the bosses' slate; the heroes
  and their promoted forms.
- The quick campaign: it compiles against the tier's lists and reads nothing.
- A silence or purge carrier on the base roster or the heroes: none in this build; the
  Augur's Dispel is the heroes' session's.
- Which keyword chips, glyphs or HUD marks the phone wants beyond the placeholders named:
  Ryan judges them running.
