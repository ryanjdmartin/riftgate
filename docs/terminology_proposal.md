# Gameplay text: one set of words (17 November; his marks in chat from 19 November)

Ryan, 17 November: "I want to standardize and clean up the terms we use and the way we write
tooltip text. So how we refer to units, targets and effect times, how we label gameplay
elements, the language we use in gameplay descriptions, and so on. This is not a lore pass,
this is about gameplay information for the player, and how it is presented."

This is the codex cleanup and terminology pass the to-do kept for him (16 November). Its first
round counted what the text says and proposed a standard for him to mark; he is marking it in
chat (section 8). Nothing in it is built except one bug fix (section 5). Every rule here is a
lean unless it quotes him or section 8 says he marked it.

**What it covers.** Every line that tells the player how the game works: the die's readout and
the codex's rows (the code composes both), a term's tip and the keywords list, a foe move's lines
and its intent, the how-it-fights sentences on a foe's page, passives and module rules, the chips'
readouts, the plates' labels and the battle log.

**What it leaves alone.** Lore (a page's history, every flavour quote); the HUD's own voice
(ENEMY PHASE, SIG LOST, CARE // PROJECTOR LINE); names, except the ones the to-do routes here
(section 4); and what shown text calls the die, which is section 12's question and a session of
its own.

**What was counted.** 2,797 lines a player can read, counted again on 19 November over main at
`946c2ed`. 651 are shown drafts in content, from `tools/hangar_text.py`'s inventory. 2,146 are
lines the code composes: the 73 dealt components' readouts, every foe's moves, the plates and the
chips, taken from a scratch dump of `EntryReadout`, `Face.describe`, `Effects.effect_text` and
the chip rows. None of it is his: the ledger has nothing signed and the Text tab had nothing
waiting to be folded, so no text of his would move.

## 1. What the text does today

**Units.**
- Ours is a machine (452 times) and theirs a foe (262), but also an enemy (65). 51 of those are
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
- The die's target line has eight forms in the code, and a foe move's has fourteen. Among the
  foe's: "Every Machine" in the term's capitals beside "Every foe" without them, plus "The most
  hurt of its own", "One of its own", "The most-marked of its own", "Empty places" and "The
  team's rerolls".
- The targeting build (17 November) put an attack's word on its target line: "Target: The
  hottest machine" on 5 moves and "The most buffed machine" on 1. The words are a session's
  drafts.
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
- One pack fought is "the fight" 27 times and "the skirmish" in the Nemesis's and the Ammit's
  passives and the map's end text ("%d skirmishes"), and the vocabulary's term for it is
  Fight (a map term, not in the keywords list).
- A stack runs down in seven verbs: halves, decays, fades, falls off, runs down, lifts, clears.

**Labels and numbers.**
- Stacks are written "Empowered ×2" on the die and the chips, "Ablating 2" and "Regenerating 3"
  in the moves, "armour +3" or "Armoured +3" for Armoured in 15 moves, and "every machine
  scorched, ×4" in lower case. Meanwhile × means four things: strikes ("Attack 3 ×2"), stacks
  ("Grants Empowered ×2"), repeats ("Fills the hopper ×2") and a multiplier ("×2 on a foe at
  half its HP or less").
- A term reads in its colour and taps only when written with its capital (`Terms.split`). The
  moves and foe pages write 84 status and keyword words in lower case (scorches, scorched,
  corrupted, jams, frostbitten, readied), so none of those tap.
- A keyword's line on the die reads "Apply Ablate 2 on hit" or "Apply Expose on hit" (19
  lines): the keyword's own verb inside a second verb, next to a chip that just says "Ablate 2".
- A foe's plate says ATK and ARM where a machine's says ARMOUR.
- 67 of 112 tips open by saying what kind of term they are, in a dozen forms: "Keyword with a
  number.", "Player keyword, on any entry aimed at a foe.", "Enemy keyword.", "Foe attack
  keyword with a number.", "Machine status.", "Foe buff:", "Status, on either side:". The heading
  above each one already says KEYWORD, BUFF or DEBUFF.

**Language.**
- The median tip is 60 words long. 36 of 112 run past 70 and 11 past 100 (Foe action 182,
  Phased 173, Aim 161).
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

The principle is one word for each thing, and the same word on both sides of the field. A
term's rule lives in its tip, and every other text names the term and its number. Each rule is
his to mark by its number; where a rule offers a choice, A is the lean. A rule tagged "changed
19 November" is one main or his mark moved since the list of 17 November.
`tools/pages/terminology_marks_page.py` makes this section and section 4 into the page he marks
on (`docs/status.md`, Pages).

### Who

**1. Machine, foe, unit.**
Our side's pieces are *machines*, the other side's are *foes*, and *unit* means either. "Enemy"
stops appearing in explanations. The HUD banners (ENEMY PHASE and so on) keep their style.
- "Target: Enemy, Direct" → "Target: Foe, Direct"

**2. Name a group by who is in it, not by who is acting.**
- **A:** Ours are Self, Any machine, Another machine, Every Machine, Every Other Machine. The
  foes' are Self, Another foe, Every Foe, Every other foe. A buff on your whole team and a foe's
  attack on your whole team are then both "Every Machine", one term with one tip.
  - "Any ally or self" → "Any machine"
  - "Any other ally" → "Another machine"
  - "Every Ally" → "Every Machine"
- **B:** Keep "ally", meaning any machine on your team, itself included: Any ally, Another ally,
  Every Ally, Every Other Ally. The foes' "Every Machine" keeps its name, so that group has two
  names.

**3. A piece calls the machine it's on "this machine".**
That covers components, passives and modules. A status's tip calls the unit carrying it "it",
and anyone else by what they did.
- "costs its owner 3 hull" → "costs this machine 3 hull"
- "cools the hitter 2 a stack" → "cools the machine that hit it 2 per stack"

**4. The player is "you".**
The two halves of a round are "your turn" and "the foes' turn".
- "at the end of the player's turn" → "at the end of your turn"
- "through the enemy's turn" → "through the foes' turn"

**5. A foe makes moves.**
Its *intent* is the move it's showing this round. The word "action" goes, and the term "Foe
action" becomes "Foe move".
- "skips its telegraphed action" → "skips its move"

### Whom

**6. One format for the target line.** (changed 19 November: main's summon texts)
It's "Target:" plus the group, and for a weapon, its reach after a comma. Terms keep their
capitals and everything else is sentence case. A move aimed at a place rather than a unit keeps
its plain words: main's summons now say "Target: Empty places", and the reroll drain stays
"Target: The team's rerolls". Main's new "Every foe it readied" stays as it is.
- "Every foe" → "Every Foe"
- "One of its own" → "Another foe"
- "The most hurt of its own" → "The most hurt foe"

**7. "The target" and "each foe hit".**
*The target* is the one unit the spend or move is aimed at. *Each foe hit* (or *each machine
hit*) is every unit it lands on: the target plus anything its area reaches.
- "every foe the entry reaches is Exposed" → "each foe hit is Exposed"

**8. Area words.**
*Beside* means left or right in the same rank. *Behind* and *in front of* mean the other rank of
the same column. *Around* means all of those.
- "every foe round its slot" → "every foe around it"

**9. The attack's targeting word goes on its target line.** (changed 19 November: already built)
Main's targeting build did this. "Target: The hottest machine" shows on 5 moves and "Target: The
most buffed machine" on 1. "The strongest machine" and "The weakest machine" are waiting for
moves that use them. Foe pages no longer show an aim line. All that's left is his sign-off on
the four words (section 4, Names).

### When

**10. One phrase for each of his four timing points.**
"Its" means whoever carries it. The bare "until its next turn" goes: today it ends Armoured at
the start of a turn, but the Cockatrice's jam at the end of one.
- **A:** "at the start of its turn", "at the end of its turn", "at the end of the round", "when
  spent". For durations: "until the start of its next turn", "until the end of its next turn",
  "until the end of the round", "until spent".
- **B:** The rules doc's wording: "as its turn starts", "as its turn ends", "as the round ends".

**11. A status's timing lives in its tip.** (changed 19 November: the count and an example)
- **A:** A text that applies a status gives its name and number, and only states a time when
  that source changes it ("for 2 rounds"). About 55 move lines get shorter. The six moves that
  Expose each repeat Exposed's whole rule today.
  - "Points out one machine: it stands Exposed through the next round, its armour counting for nothing and every foe's targeted move turned on it." → "Points out one machine: it is Exposed."
  - "Raises a scrap shield: armour +1 until its next turn" → "Raises a scrap shield: Armoured 1"
- **B:** Every text keeps its timing, in rule 10's wording.

**12. Looking ahead.**
Use "this round" and "next round". Something that lands later is "in 2 rounds"; something that
lasts is "for 2 rounds".
- "two rounds on" → "in 2 rounds"
- "through the round after" → "until the end of next round"

**13. Round, skirmish, battle.** (changed 19 November: his mark)
His word: "I want to keep skirmish." A *round* is your turn plus the foes' turn. A *skirmish* is
one pack fought to the end. A *battle* is the whole map. The map's own "turn" stays. Keeping
skirmish leaves one choice: what happens to "fight", which today names the same thing 27 times.
- **A:** "Skirmish" is the noun, and "fight" stays only as a verb ("move or fight", "machines
  that fought").
  - "Once a fight" → "Once a skirmish"
  - "It lasts the fight" → "It lasts the skirmish"
  - "Fight" (the map's term) → "Skirmish"
- **B:** "Fight" stays a noun too, as a second word for a skirmish.

**14. Five verbs for things running out.**
The verbs are *halves* (rounded down), *loses a stack*, *ends*, *is spent*, and *is removed* (by
a Cleanse or a Purge). *Decays* is only the catch-all, for a rule that stops both halving and
losing stacks. Fades, runs down, falls off, lifts and clears all go.
- "a stack fades" → "loses a stack"

### What things are called

**15. A term is written with its capitals, followed by its number.**
That way it shows in its colour and can be tapped. A keyword's verb form counts ("Jams",
"Exposes"). Ordinary words stay lowercase. Today 84 status words in moves and foe pages are
lowercase and can't be tapped.
- "every machine scorched, ×4" → "every machine is Scorched 4"
- "It scorches." → "It Scorches."

**16. Stacks are always written "Name N".**
"×" only means times, as in a weapon's strikes or a multiplier. "+" and "−" only mean a change
to a number. "Attack 3 ×2" stays (two strikes), and so does "Hull +8" (a change).
- "Grants Empowered ×2" → "Grants Empowered 2"
- "Debuff, Ablating ×2" → "Debuff, Ablating 2"

**17. A chip shows its stack count as a plain number.**
It would read "2" instead of "×2", and a single stack still shows no number. This one needs his
eye on the phone.

**18. A readout's first line says what kind of act it is.**
It's Attack N, Buff, Debuff or Defend, the same four words on both sides. Our buffs keep
"Grants" to say what they give. A buff that grants no status reads "Buff": that fix is on the
branch (section 5).
- "Grants Empowered ×2" → "Grants Empowered 2"

**19. A keyword's line matches its chip on the die.**
- "Apply Ablate 2 on hit" → "Ablate 2"
- "Apply Suppress on a foe carrying Brittle" → "Suppress, on a foe carrying Brittle"

**20. Each stat has one label, spelled out.**
HP stays the only abbreviation.
- "ATK 4 // ARM 1" (a foe's plate) → "ATTACK 4 // ARMOUR 1"

**21. Attack, strike, hit.** (changed 19 November: the count)
An *attack* is one use: one spend of a weapon, or one attack move. A *strike* is one of its
blows. A strike that lands *hits*.
- **A:** "Blow" and "shot" leave the text, with Shots kept as the Cassowary's counter. That's
  145 uses of "blow".
  - "the next blow a foe lands on it" → "the next strike a foe lands on it"
- **B:** Keep "blow" as a second word for a strike.

**22. Falls, kills, wrecked, destroyed.**
A foe *falls* at 0 HP, and whoever got it there *killed* it. A machine is *wrecked*. A component
is *destroyed*.
- "a felled one too" → "even one that falls"

**23. The die keeps its current words.**
The die *rolls* and *shows* an entry. An entry holds a component or is blank. You *spend* a die
by dropping it on a target. Whether to keep the word "die" at all is still a separate question.
- "the component the target's die is showing" → "the entry the target's die shows"
- "cannot be played" → "cannot be spent"

### How it reads

**24. A tip gives the rule first, then only what would surprise.**
Today's median tip is 60 words, and the longest are Foe action (182), Phased (173) and Aim (161).
- The first sentence is the rule in plain words.
- After that comes only what a player would otherwise get wrong. Anything that just works is
  left out.
- It never repeats the heading above it, such as "Machine status." under BUFF.
- It says which side carries it only when it can be either: "On a foe: … On a machine: …".
- It doesn't name the pieces that carry it.
- It stays under about 60 words.
- "Machine status. Each stack is +1 damage on this machine's attacks, flat, so the count is the bonus. As its turn ends it halves, rounded down, whatever granted it, until it is gone." → "+1 damage per stack on its attacks. Halves at the end of its turn, rounded down."

**25. Rule numbers are digits, and rates use "per".**
A move's flavour can keep words like "Three heads bite", since its readout lines carry the
numbers.
- "a point a stack" → "1 per stack"
- "+2 a load" → "+2 per load"

**26. Repeat the noun.**
- "a machine's as the player's turn ends, a foe's as its own turn does" → "a machine's Empowered at the end of your turn, and a foe's Empowered at the end of its own turn"

**27. A move's line keeps its voice.**
The flavour stays as written. Any rule it states follows these rules.
- "Bloodlust: every foe on the field hits 2 harder, itself too, fading by half each round." → "Bloodlust: every foe, itself included, gains Empowered 2."

**28. A foe's page says what it is, then how it fights.**
The lore stays word for word. Either way, every "shield up" goes.
- **A:** Keep advice where today's rules make it true.
  - "One round to kill it, suppress it, or shield everyone." → "One round to kill it or Suppress it."
- **B:** Cut advice entirely.

**29. Retired words leave.** (changed 19 November: skirmish taken off)
These follow from rulings he has already made, so they need no mark.
- shields and vents as pieces (except the Musk Ox's reload, and machines still in design)
- overshield
- Retaliate
- a chassis's cooling
- "braces", which is Armoured now
- "burning" for Ablating
- "enemy"

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

## 4. Calls that aren't rules

**Who rewrites the ~600 texts.**
- **A:** Once the rules are marked, a session redrafts them type by type, the die's lines first,
  and puts each type on the Text tab for his marks. Nothing is signed for him.
- **B:** He writes them himself, with the lints flagging anything that breaks the rules.

**Names.** (changed 19 November: main's to-do routes more here)
- **Aloft.** The Roc's climb out of reach, a working name. Pick: Keep · Soaring · Airborne
- **Last Act.** What a foe does as it falls ("maybe rename to something more interesting").
  Swan Song fits blows, curses and buffs alike; Parting Shot fits only a blow. Pick: Swan Song ·
  Parting Shot · Last Gasp · Keep
- **The attack's words.** On the target line since the targeting build (rule 9): "the strongest
  machine", "the weakest machine", "the hottest machine", "the most buffed machine". Pick: Sign
  off · Change
- **Immune.** The drafted name for a foe's ability that one of your effects never lands on.
  Pick: Sign off · Change
- **The four falls.** Drafted names: Scream, Dying Gaze, Unbound, Embers. Pick: Sign off ·
  Change
- **The moves that Expose.** Drafted names: Kill Order, Mark Prey, Transfix, Command, Name the
  Quarry. Pick: Sign off · Change
- **Ablative Plating and Ward Plate.** Module names beside the keywords Ablate and Ward. Neither
  breaks a tap, since names are never matched as terms; the only question is whether players
  read them as the keyword. Pick: Keep both · Rename

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
   opening kind and its length. The code's other composed lines would also be listed on the
   Text tab, read-only as the status lines and (since 19 November) a move's target words are,
   so he can see what the die says.
3. **The drafts**, kind by kind, one commit each: the tips, the moves' rule clauses, the
   how-it-fights sentences on foe pages, the passives, the module rules. `docs/vocabulary.md` and
   the bible's tables are regenerated after each.
4. **The renames he takes** (rule 2's two, rule 5's one, rule 13's Fight): names only, ids
   kept.
5. **Where the standard lives.** Lean: the rules as a short list in `docs/rules.md`'s Content
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
- Numbers in words in a rule ("two stacks"). Killed by rule 25; a move's flavour keeps its own.
- "Fight" as the one noun, and "skirmish" out of shown text. Overruled by his mark of 19
  November (rule 13).
- One grammar for every keyword, a verb plus its participle (Embrittle for Brittle, Chill for
  Cryo). Set aside: Brittle and Cryo are his picks, and each already serves as both the keyword
  and the status (the bible's shared-name row).

## 8. His marks

**19 November, in chat.** On the first round's summary: "I need the rules spelled out, yeah. We
can do it in chat." On the list spelled out: "Pull in main and adjust this list accordingly. I
want to keep skirmish." Main was taken in at `946c2ed` and every count read again (section 1);
the rules main had moved were changed with it: rule 6 keeps the summons' "Empty places", rule 9
is built, rule 11's count grew with the moves that Expose, and section 4's names took in the
drafts the to-do routes here. Rule 13 is his: skirmish stays, the word for one pack fought,
with fight's place beside it the choice left (rule 13's A and B). Rule 29 no longer lists it.
