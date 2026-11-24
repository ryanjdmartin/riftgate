# Gameplay text: one set of words (17 November; his marks in chat from 19 November)

Ryan, 17 November: "I want to standardize and clean up the terms we use and the way we write
tooltip text. So how we refer to units, targets and effect times, how we label gameplay
elements, the language we use in gameplay descriptions, and so on. This is not a lore pass,
this is about gameplay information for the player, and how it is presented."

This is the codex cleanup and terminology pass the to-do kept for him (16 November). Its first
round counted what the text says and proposed a standard for him to mark; he marked it in chat
(section 8), and the tips are written to it (section 3). A rule tagged settled is his; every
other rule is a lean still his to mark.

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

Its rules moved to `docs/text_standard.md` on 24 November, where new content reads them; the
marks page reads them there.

## 3. The texts themselves

Every glossary tip is written to the standard and sits on the hangar's Text tab for his edits.
The move lines, the templates, the passives and the modules follow, kind by kind.

## 4. Calls that aren't rules

The questions the tips' drafts raised (23 November), each settled since and kept for the record,
then the names the to-do routes here.

**A rider's event.** (settled 23 November: his word)
Resolve, Primed's line too: "Riders can be resolve, you're correct that matches better to what
actually happens."

**The number in a sentence.** (settled 23 November: his word)
"Apply N Ablate, yes. Not Ablate 1. It's shorthand for 'Apply N stacks of Ablate.'" A sentence
that lays stacks puts the number first; a chip and a keyword on the die say "Ablate 2".

**A capital after a label.** (settled 23 November: his word)
"Capitalize after a colon, yes."

**A keyword for "only this component".** (settled 24 November: his word, Fixed, the kit word Integrated)
His suggestion of 24 November, for the third case in a week (the Nemesis's Rage, the Whip
Scorpion's reboot that puts the Death Ray on its die, the Mole's burrow): "Fixed: Knuckles of
Fury", with the keyword's tip "Fixed: Only the specified component may be used." The catch is
the name: "fixed" is already the kit word for a chassis's built-in components (CLAUDE.md, 18
September), the loadout editor prints "Fixed: Knuckles of Fury" today for the Nemesis's built-in
pieces, the Destroyed component tip says "a fixed component is rebuilt", and all three pieces in
question are their chassis's fixed components. His answer: "I'd rather change Fixed a chassis
locked components to Integrated, actually." So a chassis's built-in components are Integrated,
and "Fixed: Knuckles of Fury" is the rule on Rage, "Fixed: Inertia Drill" on Burrowed.

**A hit, damage and a loss.** (open, 24 November: his ask)
His ask: "I want to standardize the difference between something that hits, and is affected by
armour and brittle and such like the Mole's Drill debuff, and flat damage that bypasses all that
like Ablate. Both say 'take 1 damage' right now." The engine has three kinds, not two:
- A hit (a weapon's, a Sprite's attack, Cleave, Penetrate, Chain, Ricochet, the Mine, the drill's
  tick): a Frame's Shield first, then Armour; Barrier, Brittle and every When Hit apply.
- Damage that is not a hit (Ablate, Corrupted's bite): a Frame's Shield first (his "hits shield
  first, I think. Pretty deadly otherwise", 15 November), then Hull or HP; Armour, Barrier,
  Brittle and the hit events never see it.
- A loss (Volatile, Overheated, Vitriol): off the one number, past the Shield too.

Hull Damaged reads all three. Two catches: "flat" already means a fixed number, never a
percentage (Armour, a flat shield, Burrowed's flat numbers), and Vitriol bypasses everything as a
percentage; and the second and third kinds differ by a Frame's Shield alone, on a Sprite not at all.

**A:** The verbs carry it, in three forms. "Hit for N" or "take a hit of N damage" is a hit; "take N
damage" is damage, the Shield first; "lose N Hull", "lose N HP" and "lose N Shield" come off that
number alone. Ablate, Vitriol and Volatile drop their "Ignores ..." lines, Overheated reads "Turn
End: Lose 1 Hull per stack ({N}).", and the drill's tick reads "take a hit of 1 damage".

**B:** A term the player can tap for damage that is not a hit (Flat, True or Pure): "Take 1 Flat
damage", its tip saying what never sees it and that a Frame's Shield takes it first. "Lose N Hull"
stays for what passes the Shield too.

**Names.**
- **Aloft.** The Roc's climb out of reach, a working name. Pick: Keep · Soaring · Airborne
- **Last Act.** What a foe does when defeated ("maybe rename to something more interesting").
  Pick: Swan Song · Parting Shot · Last Gasp · Keep
- **The attack's words.** On the target line: "the strongest machine", "the weakest machine",
  "the hottest machine", "the most buffed machine". Pick: Sign off · Change
- **Immune.** The drafted name for a foe's ability that one of your effects never lands on.
  Pick: Sign off · Change
- **The four falls.** Drafted names: Scream, Dying Gaze, Unbound, Embers. Pick: Sign off ·
  Change
- **The moves that Expose.** Drafted names: Kill Order, Mark Prey, Transfix, Command, Name the
  Quarry. Pick: Sign off · Change
- **Ablative Plating, Ward Plate and Ram Frame.** Module names beside the keywords Ablate and Ward
  and the word Frame. Pick: Keep them · Rename

## 5. What this round changed

- **One bug, fixed.** The Baboon's Retrocausal Shroud and the Giant Petrel's Immelmann Booster
  are buffs that grant no status. Their readout and codex row said "Grants  ×1", a Grants line
  with no name. They now say "Buff", the way a debuff says "Debuff", from the template a foe's
  buff move uses (`kind.buff`; `EntryReadout.effects_of`; a check in `tests/test_screen.gd`).
- **Left for the build**, since the fix needs the standard's words: the Nemesis's Knuckles of
  Fury read "5 rage: 5 instant (+6 heat)", and the Swallowtail's charged forms (in design) read
  "A muster: indirect expose suppress (+1 heat)". In both, a charged form prints the engine's
  debug string
  (`Face.describe`). Also, the tips for Every Foe, Every Ally and Every Other Ally end in "..".

## 6. The build, once marked

1. **The templates' words.** Since 20 November the die's readout, the codex's rows and a foe
   move's lines are content (`content/templates.json`, filled by `sim/templates.gd`), and he
   edits them on the Text tab's Templates view; so the standard reaches them as drafts there,
   one commit a group, along with the tests that read those strings. What the code still
   composes on its own follows: the passives' generic words (`Effects.effect_text`), the chips
   (`SkirmishScreen.status_row` and the ability rows), the charged forms (`Face.describe`) and
   the log.
2. **The lints**, added to `tools/hangar_text.py`'s `lints()` beside the two it already has
   ("face", "damaging weapon"), so the Text tab flags any text or template that breaks the
   standard. They would catch the words that left (rules 1, 4, 5, 13, 22, 29), a bare "until
   its next turn", ×N after a status, "Apply … on hit", the distributive "a", a term in lower
   case, and a tip's opening kind and its length.
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

**22 November, in chat**, on his timing events and the questions they raised. "You're right on
all of 1, 2, 3. I was imprecise. Go with how the game works": riders land after the hits (rule
31), Brittle halves as its carrier's turn starts (rule 32), and "if damage dealt" is an After
hit condition. Area hits fire every event but the "target" ones (rule 33). One word for a hit,
weapon or equipment (rule 21). "Spend" is the design's word and not the player's: a component is
used (rule 23). The events line up with the engine's triggers except where only the engine needs
one (rule 33). The tip headings are Property, Buff, Debuff, Ability and Resource, with "Buff,
Unpurgeable" and "Debuff, Uncleanseable" (rule 24). His wording of Spread and Penetrate takes in
the half-slots on purpose, and a tip names no gauge: "Ablate just says take 1 damage ... It's
precise." Rule 24 now carries his words on precision and the semicolon.

**22 November, in chat**, the second round. Marks: 2-A, 11-A, 13-A, 28-B. Rule 10 is neither A
nor B: a timed line is written as the timing events are, a label then the text ("Turn Start:
{text}", "Turn End: {text}", "Round End: {text}"), so "its" never needs to say whose; the
labels are Turn Start, Turn End and Round End. A consumption is an event too ("When Hit:
Consumed to double damage received, after all flat modifiers are applied"; "After Use: Consume
1 stack ..."). The use's two events are Commit and Resolve, in place of On use and After use.
The statuses on a clock became stacks that count it down ("could we just switch them to Stacks
and use that as the timer?"): Exposed 2, Golden and Swallowed are timers, built that day (the
bible's timers row, `docs/rules.md`, When a status ends); a hit is "hit", never "struck".

**23 November, in chat**, on the sample of ten, with his own texts for them (now on the Text
tab). His rules: a buff's or a debuff's tip says the sum its unit carries, his `{N}` ("All buffs
and debuffs need to have their current sum mentioned in their in-game tips"); a stack changes by
"reduce stacks by" or "reduce stacks to", so no plural is needed; a condition goes inside the
line, never in its event ("On hit: if targeted"); a tip does not over-specify, so it names no
other rule that may change ("if either gets changed, the tip needs editing as well. It also
assumes knowledge of the other two keywords"); one effect a line. Ablating is renamed Ablate,
one name for the keyword and the status it leaves, as Brittle is.
Then, on the answers: a sum only where a line says "per stack" ("Don't need to sum stacks when
the meaning is just the stacks"); Golden is +2 whatever laid it, its move saying only its rounds
("No stack should be dynamic based on what created it"); its break is a Suppress like any
("Otherwise you can chain a stagger into a suppress and the boss rolls over"); a swallow's
release on its swallower's fall goes unsaid ("implied ... from common sense"), and so does a
Shock or a Brittle on a hit that deals nothing.

