# Gameplay text: one set of words (17 November, the first round)

Ryan, 17 November: "I want to standardize and clean up the terms we use and the way we write
tooltip text. So how we refer to units, targets and effect times, how we label gameplay
elements, the language we use in gameplay descriptions, and so on. This is not a lore pass,
this is about gameplay information for the player, and how it is presented."

This is the codex cleanup and terminology pass the to-do kept for him (16 November). This first
round counts what the text says today and proposes a standard for him to mark. Nothing in it is
built except one bug fix (section 5). Every rule here is a lean unless it quotes him.

**What it covers.** Every line that tells the player how the game works: the die's readout and
the codex's rows (the code composes both), a term's tip and the keywords list, a foe move's lines
and its intent, the how-it-fights sentences on a foe's page, passives and module rules, the chips'
readouts, the plates' labels and the battle log.

**What it leaves alone.** Lore (a page's history, every flavour quote); the HUD's own voice
(ENEMY PHASE, SIG LOST, CARE // PROJECTOR LINE); names, except the three the to-do routes here
(section 4); and what shown text calls the die, which is section 12's question and a session of
its own.

**What was counted.** 2,767 lines a player can read. 623 are shown drafts in content, from
`tools/hangar_text.py`'s inventory. 2,144 are lines the code composes: the 73 dealt components'
readouts, every foe's moves, the plates and the chips, taken from a scratch dump of
`EntryReadout`, `Face.describe`, `Effects.effect_text` and the chip rows. None of it is his: the
ledger has nothing signed and the Text tab has nothing waiting to be folded, so no text of his
would move.

## 1. What the text does today

**Units.**
- Ours is a machine (414 times) and theirs a foe (241), but also an enemy (68). 51 of those are
  on the die's own target line, "Target: Enemy, Direct", while the next piece reads "Target:
  Every Foe".
- "Ally" means two things. "Any other ally", "an ally whose die is spent" and a passive's "with
  an ally in the fight" mean another machine. Every Ally means the whole team, itself included,
  which is why the default target has to say "Any ally or self". A foe's blow at that same team
  is Every Machine: one set with two names.
- The machine a piece sits on is called its machine, its own machine, this machine, its owner,
  its firer, the attacker, the hitter, the striker, its carrier and whoever spends it.
- The player is "you" 31 times (24 of them on foe pages) and "the player" 10 times (all in
  tips). A foe's own side is "its own", "one of its own" or "the others".

**Targets.**
- The die's target line has eight forms in the code, and a foe move's has eleven. Among the
  foe's: "Every Machine" in the term's capitals beside "Every foe" without them, plus "The most
  hurt of its own", "One of its own", "The most-marked of its own", "The waiting pool" and "The
  team's rerolls".
- 39 moves add their aim after the target, "Target: Any machine, aims at the exposed". The page
  on targeting retires those aims.
- Whoever a spend reached is called the target, each foe hit, every foe the entry reaches, the
  foe aimed at, the machine it hit, or the machine it lands on.
- Area is beside, behind, round its slot, a neighbour's, or the other rank of its column.

**Time.**
- His four places (`docs/rules.md`, When a status ends) are written more than twenty ways. Turn
  start alone has six: as its turn starts, until its next turn starts, until its next turn,
  until their next turn, as each round opens, as the foes' turn starts.
- Bare "until its next turn" ends Armoured as that turn starts (16 moves, "armour +1 until its
  next turn"), but it also ends the Cockatrice's stone, a jam, as that turn ends. Elsewhere that
  second end is written "through its next turn" (21 texts). A player cannot tell which end is
  meant.
- A text that lays a status repeats the status's clock, and drifts from it. Bloodlust's
  Empowered is "fading by half each round"; the rule is that it halves as each foe's own turn
  ends.
- A fight is "the fight" 31 times and "the skirmish" 5 times (the Nemesis's and the Ammit's
  passives, and the map's "%d skirmishes").
- A stack runs down in seven verbs: halves, decays, fades, falls off, runs down, lifts, clears.

**Labels and numbers.**
- Stacks are written "Empowered ×2" on the die and the chips, "Ablating 2" and "Regenerating 3"
  in the moves, "armour +3" or "Armoured +3" for Armoured in 15 moves, and "every machine
  scorched, ×4" in lower case. Meanwhile × means four things: strikes ("Attack 3 ×2"), stacks
  ("Grants Empowered ×2"), repeats ("Fills the hopper ×2") and a multiplier ("×2 on a foe at
  half its HP or less").
- A term reads in its colour and taps only when written with its capital (`Terms.split`). The
  moves and foe pages write 74 status and keyword words in lower case (scorches, scorched,
  corrupted, jams, frostbitten, readied), so none of those tap.
- A keyword's line on the die reads "Apply Ablate 2 on hit" or "Apply Expose on hit" (19
  lines): the keyword's own verb inside a second verb, next to a chip that just says "Ablate 2".
- A foe's plate says ATK and ARM where a machine's says ARMOUR.
- 66 of 110 tips open by saying what kind of term they are, in a dozen forms: "Keyword with a
  number.", "Player keyword, on any entry aimed at a foe.", "Enemy keyword.", "Foe attack
  keyword with a number.", "Machine status.", "Foe buff:", "Status, on either side:". The heading
  above each one already says KEYWORD, BUFF or DEBUFF.

**Language.**
- The median tip is 58 words long. 34 of 110 run past 70 and 11 past 100 (Foe action 172,
  Primed 129, Exposed 128).
- Ten tips name the piece that carries their rule ("the Dingo's Combat Translocator"), so the
  tip goes stale every time a piece is renamed or moved.
- Rates use the sessions' idiom, "a point a stack", "2 a stack", "+2 a load", where his own
  words use per: "burn should only do 1 damage per stack" (18 October), "granting 1 Empowered
  per soul" (12 November).
- Possessives drop their noun: "a machine's as the player's turn ends, a foe's as its own turn
  does".
- Words the refit pass and the vocabulary pass retired are still shown. Cleanse's tip says it
  rides "shield and vent components", but two buffs carry it now. Rapid's tip says "a vent or a
  shield as well as a weapon". The Nob's page says "every shield you raise, every vent you
  spend". Shield cost says "overshield included". Shocked says it is laid on "a machine carrying
  Retaliate". The Polar Bear's seal says "its own cooling stopped". Ablating's tip says "a
  burning foe". About twenty-five foe pages tell the player to shield (the to-do's count).

## 2. The standard

The principle is one word for each thing, and the same word on both sides of the field. A term's
rule lives in its tip; every other text names the term and its number. Each numbered rule is his
to mark. "Now" is what it replaces.

### Who

1. **Machine, foe, unit.** A machine is ours, a foe is theirs, a unit is either. "Enemy" leaves
   the explanatory text. Now: the die's "Target: Enemy" (51), "Enemy keyword", "the enemy's
   turn". The HUD's banners keep their own voice.
2. **A set is named by who is in it, never by who acts.** Ours: Self, Any machine, Another
   machine, Every Machine, Every Other Machine. The foes': Another foe, Every Foe, Every other
   foe. So the buff on the whole team and the foes' blow at the whole team are both Every
   Machine, one term with one tip. Now: Any ally or self, Any other ally, Every Ally, Every
   Other Ally, One of its own, Every foe. *Or*: keep "ally", meaning any machine of the team
   including itself (Any ally, Another ally, Every Ally, Every Other Ally). The foes' Every
   Machine then keeps its name, and that set keeps two names.
3. **A piece calls its own machine "this machine"**, in a piece's, a passive's and a module's
   text. A status's tip calls the unit carrying it "it". Now: its owner, its firer, the attacker,
   the hitter, the striker, its carrier, whoever spends it, its own machine.
4. **The player is "you".** The turns are your turn and the foes' turn. Now: the player (10),
   the player's turn, the enemy's turn.
5. **A foe makes moves.** Its intent is the move it shows for the round. "Action" leaves (16
   uses), and the listed term Foe action becomes Foe move.

### Whom

6. **One target line.** "Target:" then the set; for a weapon, its reach after a comma. Ours: Foe,
   Direct; Foe, Indirect; Every Foe; Self; Any machine; Another machine; Every Machine. A foe's:
   Any machine; Every Machine; Self; Another foe; Every Foe; The most hurt foe; The most-marked
   foe. Terms keep their capitals and the rest is sentence case. A move aimed at no unit (a
   summon, a drain) shows no target line.
7. **The target, and each unit hit.** The target is the one unit a spend or a move is aimed at.
   Each foe hit (or each machine hit) is every unit its strikes or effects land on: the target,
   plus whatever its area reaches. Now: every foe the entry reaches, the foe aimed at, the
   machine it lands on, the machine it hit.
8. **Beside, behind, in front of, around.** Beside is either side of it in its rank. Behind and
   in front of are the other rank of its column. Around is all three. Now: round its slot, a
   neighbour's, the other rank of its column.
9. **The attack's word goes on its target line** (this waits on the page on targeting): "Target:
   The hottest machine", "The weakest machine", "The strongest machine", in place of "Target: Any
   machine, aims at heat". A foe's page then carries no sense line.

### When

10. **Four places, four phrases.** At the start of its turn, at the end of its turn, at the end
    of the round, when spent. For things that last: until the start of its next turn, until the
    end of its next turn, until the end of the round, until spent. "Its" means the carrier's; a
    machine's turn is your turn and a foe's turn is its own move. Never a bare "until its next
    turn". *Or*: the rules' own wording, as its turn starts, as its turn ends, as the round ends.
11. **A status's clock lives in its tip.** Whatever lays a status names it and its stacks
    ("Armoured 2", "Jams the entry its die shows"). It gives a time only where the source sets
    one ("for 2 rounds"). Now: about 45 moves restate the clock of what they lay, in seven
    forms.
12. **Rounds ahead.** This round, next round, "in 2 rounds" for what lands later, "for 2
    rounds" for what lasts. Now also: two rounds on, two rounds later, through the round after,
    the rest of the round.
13. **Round, fight, battle.** A round is your turn plus the foes' turn. A fight is one pack
    fought. A battle is the whole field. "Skirmish" leaves shown text; the map's turn keeps its
    name.
14. **Five verbs for running down.** Halves (rounded down), loses a stack, ends, is spent, is
    removed (by a Cleanse or a Purge). "Decays" covers the first two, where a rule stops both.
    Now also: fades, runs down, falls off, lifts, clears, goes.

### What it is called

15. **A term keeps its capitals, with its number after it**: "Scorched 4", "Exposed", "Every
    Machine". That way it reads in its colour and taps. A keyword's verb form counts as the
    keyword ("Jams", "Exposes"). A plain word stays lower case. Now: 74 lower-case uses in
    moves and foe pages.
16. **Stacks are written Name N**: Empowered 2, Ablating 3, Armoured 1, the same way a numbered
    keyword is written (Ablate 2). × only means times: a weapon's strikes (Attack 3 ×2) and a
    multiplier (×2 damage). + and − only mean a change (Hull +8, +2 damage, "Empowered +2 on its
    way").
17. **A chip's number is its stacks**: 2 where the chip says ×2 today. One stack still shows no
    number. This one needs his eye on the phone.
18. **The act line stays Attack, Buff, Debuff and Defend on both sides.** Our buff keeps
    "Grants" for what it grants, "Grants Empowered 2". (Weapon is the piece's kind; Attack is
    the act's.) A buff that grants no status says "Buff", the way a debuff says "Debuff" (the
    bug in section 5).
19. **A keyword's line is the keyword as the die's chip shows it**: Ablate 2, Shock, Expose, plus
    its gate where it has one ("Suppress, on a foe carrying Brittle"). Now: Apply Ablate 2 on
    hit.
20. **One label per stat, in full**: HP, ATTACK and ARMOUR on a foe's plate, matching SHIELD,
    HULL, ARMOUR, HEAT and MOVE on a machine's. HP stays the one short form (the bible's HP row).
21. **Attack, strike, hit.** An attack is one spend of a weapon or one attack move. A strike is
    one of its blows (the Strikes term). A strike that lands hits. "Blow" and "shot" leave shown
    text, with Shots kept as the Cassowary's count. This is the biggest rewrite on the list
    (blow appears 141 times). *Or*: keep blow next to strike, as one word in two forms.
22. **Falls, kills, wrecked, destroyed.** A foe falls at 0 HP, and the unit that took it there
    kills it. A machine is wrecked. A component is destroyed. Now also: felled, dies, dead.
23. **The die's words stay as they are.** The die rolls and shows an entry. An entry holds a
    component or is blank. A spend drops the die on a target, and an entry that cannot pay
    cannot be spent (now: "cannot be played"). Section 12's question on the word "die" is not
    touched.

### How it reads

24. **A tip states the rule, then only what would surprise.** The first sentence is the rule in
    plain words. After that comes only what a player would get wrong, and nothing that just works
    (Ryan, 7 November: "things should just work how they should intuitively"). A tip never
    repeats its heading. It says who carries it only where both sides can ("On a foe: … On a
    machine: …"). It names no piece that carries it. It stays under about 60 words.
25. **Digits, and "per".** Every gameplay number is in digits, and a rate uses per: "1 damage per
    stack", "+2 per load". Now: a point a stack, 2 a stack, two stacks.
26. **Say the noun again.** No possessive that drops its noun.
27. **A move's line keeps its voice.** The flavour is the foe's and stays. Any rule it states
    uses the standard's words, with its numbers as {damage} and {value}: "every machine
    scorched, ×4" becomes "every machine is Scorched 4".
28. **A foe's page says what it is, then how it fights.** The first part is lore and stays word
    for word. The second part uses the standard's words, and gives advice only where today's
    rules make it true. Every "shield up" goes.
29. **The retired words leave**: a shield or a vent as a piece (except the Musk Ox's reload, and
    the machines in design while they stay in design), overshield, Retaliate, a chassis's
    cooling, "braces" (it means the Plow's Armoured), "burning" for Ablating, skirmish, enemy.
    These follow from rulings already made (the refit pass, the vocabulary pass), so they need
    no mark. They go out with each text's rewrite.

## 3. Some texts redrawn under the standard

Drafts, for the eye; none lands before the marks.

| Where | Now | Under the standard |
|---|---|---|
| The die: Incendiary Shells | Attack 2 · Heat 4 · Target: Enemy, Indirect · Apply Ablate 2 on hit | Attack 2 · Heat 4 · Target: Foe, Indirect · Ablate 2 |
| The die: Overcharge Coil | Grants Empowered ×2 · Target: Any ally or self | Grants Empowered 2 · Target: Any machine |
| A chip's readout | Buff, Empowered ×2 | Buff, Empowered 2 |
| Empowered's tip (BUFF) | Machine status. Each stack is +1 damage on this machine's attacks, flat, so the count is the bonus. As its turn ends it halves, rounded down, whatever granted it, until it is gone. (33 words) | +1 damage per stack on its attacks. Halves at the end of its turn, rounded down. (14) |
| Armoured's tip (BUFF) | Status, on either side. Armour +1 a stack: that much off every blow that reaches it, flat, every stack at once, whatever granted it, so the count is the armour. It lasts until its next turn starts: a machine's (a buff, an armouring component, a passive) through the enemy's turn, coming off blows on bare hull, and a foe's, from its brace or another's, through the player's. (63) | Each stack is 1 armour: every strike that reaches its hull or HP deals 1 less per stack. Ends at the start of its next turn, so a machine's lasts through the foes' turn and a foe's through yours. (39) |
| Jam's tip (KEYWORD) | Enemy keyword. The component the target's die is showing is Jammed through the target's next turn: if the die lands on it, it comes up blank. | The entry the target's die shows is Jammed. |
| Jammed's tip (DEBUFF) | Component status. This die entry comes up blank while it lasts; the component itself is untouched. A foe's jam lasts through the machine's next turn and can be cleansed; a rapid component's own switch-off ends with the round, and is no jam. | This entry comes up blank; its component is untouched. Ends at the end of its machine's next turn. A Cleanse removes it. |
| A goblin's Shield Wall | Raises a scrap shield: armour +1 until its next turn. | Raises a scrap shield: Armoured 1. |
| The shaman's Bloodlust | Bloodlust: every foe on the field hits 2 harder, itself too, fading by half each round. | Bloodlust: every foe, itself included, gains Empowered 2. |
| The Balloon's page | The bomb that swells. Its burst is announced a round ahead, then lands on every machine, scorching. One round to kill it, suppress it, or shield everyone. | The bomb that swells. Its burst is announced a round ahead, then hits every machine and Scorches it. One round to kill it or Suppress it. |

## 4. Where his words leave a choice

1. **Who rewrites.** Shown text is his to write, and the standard reaches about 600 drafts.
   Lean: once the standard is marked, a session redrafts them kind by kind, the die's lines
   first. Each kind goes on the Text tab for his marks, and nothing is signed for him. *Or*: he
   takes the drafts himself against the standard, with the lints flagging what breaks it.
2. **What an ally is** (rule 2). Today's text gives both answers: another machine, and any
   machine of the team. The lean drops the word from the labels and names the sets by machine.
   The other way keeps "ally" as the whole team.
3. **A status's clock in its tip alone** (rule 11). About 45 move lines lose their time, and the
   player taps the status to read it. *Or*: every text keeps its clock, in rule 10's phrase.
4. **Blow** (rule 21): one word for a strike, or two.
5. **The time phrases** (rule 10): the usual game wording, "at the end of its turn", or the
   rules', "as its turn ends".
6. **Advice on a foe's page** (rule 28): kept where it is true, or cut back to how the foe fights
   and nothing more.
7. **The names the to-do routes here**, his to pick or replace:
   - Aloft, for the Roc's climb out of reach, is a working name. Lean: keep it. Soaring and
     Airborne are the alternatives.
   - Last Act, for what a foe does as it falls ("maybe rename to something more interesting").
     Candidates: Swan Song, Parting Shot, Last Gasp. Parting Shot suits a blow but not a curse or
     a buff for the others; Swan Song suits all three.
   - The attack's word (rule 9): The strongest, The weakest, The hottest, as the page on
     targeting has them.

## 5. What this round changed

- **One bug, fixed.** The Baboon's Retrocausal Shroud and the Giant Petrel's Immelmann Booster
  are buffs that grant no status. Their readout and codex row said "Grants  ×1", a Grants line
  with no name. They now say "Buff", the way a debuff says "Debuff" (`EntryReadout.effects_of`;
  a check in `tests/test_screen.gd`).
- **Left for the build**, since the fix needs the standard's words: the Nemesis's Knuckles of
  Fury read "5 rage: 5 instant (+6 heat)", and the Swallowtail's charged forms (in design) read
  "A muster: indirect expose suppress (+1 heat)". In both, a charged form prints the engine's
  debug string
  (`Face.describe`). Also, the tips for Every Foe, Every Ally and Every Other Ally end in "..".

## 6. The build, once marked

1. **The code's lines**, one commit each, along with the tests that read those strings: the die's
   readout and the codex's rows (`EntryReadout`, `Face.rule_phrases`, the charged forms); a
   move's lines (`EntryReadout.move_lines`, `MOVE_TARGETS`, `Foe.WHEN_TEXT`); the passives'
   generic words (`Effects.effect_text`); the chips (`SkirmishScreen.status_row` and the ability
   rows); the plates (`ContentDB.codex_for_unit`, `codex_for_foe`); and the log.
2. **The lints**, added to `tools/hangar_text.py`'s `lints()` beside the two it already has
   ("face", "damaging weapon"), so the Text tab flags any text that breaks the standard. They
   would catch the words that left (rules 1, 4, 5, 13, 22, 29), a bare "until its next turn",
   ×N after a status, "Apply … on hit", the distributive "a", a term in lower case, and a tip's
   opening kind and its length. The code's composed lines would also be listed on the Text tab,
   read-only like the status lines, so he can see what the die says.
3. **The drafts**, kind by kind, one commit each: the tips, the moves' rule clauses, the
   how-it-fights sentences on foe pages, the passives, the module rules. `docs/vocabulary.md` and
   the bible's tables are regenerated after each.
4. **The renames he takes** (rule 2's two, rule 5's one): names only, ids kept.
5. **The attack's word**, with the targeting build.
6. **Where the standard lives.** Lean: the rules as a short list in `docs/rules.md`'s Content
   conventions, next to "shown text never says face"; the reasons in one bible row; and
   `CLAUDE.md`'s shown-text rule pointing at both.

## 7. The bench: what a rule above kills

- Foe and enemy as two words, for variety. Killed by rule 1: one word for each thing.
- Sets named by who acts (Every Ally for ours, Every Machine for theirs). Killed by rule 2.
- "The player" in the third person, for a rulebook tone. Killed by rule 4.
- Every text repeating its status's clock, so no tap is needed. Killed by rule 11.
- ×N for stacks, as the chips write it. Killed by rule 16: × means times.
- "Damage N" in place of "Attack N". Killed by rule 18: Attack is the act, alongside Buff, Debuff
  and Defend.
- A tip that holds every edge case, as a full reference. Killed by rule 24 and the bible's
  learnable row: "Tooltips and an in-game cheat sheet, never a wiki".
- A tip that opens with its kind, so the list reads top to bottom. Killed by rule 24: the list's
  headings already file each term.
- Numbers in words where the voice wants them ("two blows"). Killed by rule 25.
- One grammar for every keyword, a verb plus its participle (Embrittle for Brittle, Chill for
  Cryo). Set aside: Brittle and Cryo are his picks, and each already serves as both the keyword
  and the status (the bible's shared-name row).
