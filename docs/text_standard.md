# How gameplay text is written

Ryan's standard for the text that tells the player how the game works (17 to 24 November): a
term's tip and the keywords list, a component's readout and codex rows, a Sprite move's lines,
passives and module rules, the chips. Lore and flavour quotes are his and follow no rule here.
Read this before drafting or changing any of that text; `docs/voice.md` holds what he has signed
as his own, to write beside. A rule tagged *settled* is his. An untagged rule is Claude's lean,
which the text follows until he marks it on the terminology page (`docs/status.md`, Pages). The
questions still open and the names waiting on his pick are `docs/terminology_proposal.md`,
section 4. `tests/test_terms.gd` holds every tip to the mechanical parts.

## 1. A tip at a glance

- **Words.** *Frame* is ours, *Sprite* theirs, *unit* either; Frame and Sprite are capitalised and
  never tappable. A Frame *uses* a component, and each blow that lands is a *hit*. A Sprite is
  *defeated*, and the Frame that did it *killed* it; a Frame is *wrecked*, a component *destroyed*.
  A chassis's built-in components are *Integrated*; *Fixed: X* means only X may be used.
  Never foe, machine, enemy, blow, strike, shot, falls or felled; "spend" only for a resource paid
  (rerolls, Ore). The HUD's own voice (ENEMY PHASE) stays.
- **Labels.** A timed line opens with its label and a colon, then a capital (rules 10 and 31).
  An always-on line has none.
- **Conditions** sit inside the line: "On Hit: If targeted, ...". **Riders** land at Resolve.
- **Stacks.** "Apply N X" lays stacks, number first ("Apply 2 Brittle"); "Gain N X" on itself;
  "Reduce stacks by 1", "by half, rounded down", "to 0". A status that never stacks says
  "Consumed" when its own effect uses it up ("At 0 Heat: Consumed to Reboot immediately") and
  "Removed" when it simply ends ("Turn Start: Removed."). A chip and a keyword on the die say
  "X N". A timer's stacks are its clock, never its strength.
- **Damage.** "Hit for N" is a hit: Shield, then Armour, with Barrier, Brittle and When Hit. "Suffer
  N damage" is not a hit: Shield first and nothing else. "Lose N Hull" comes off Hull alone (rule 39).
- **Numbers.** Digits; rates use "per". A status's numbers are its own, never the move's or the
  passive's that laid it. `{N}` fills with the unit's current sum and goes only on a per-stack
  line ("+1 damage per stack ({N})"); in a keyword's tip it is the keyword's number.
- **Shape.** Technical lines, not prose: "Only Knuckles of Fury available.", "Reboot disabled.",
  "Cooling disabled." Precise and succinct, one effect a line, no semicolon. It names no other
  rule that may change, no piece that carries it, and never its own heading. Game nouns are
  capitalised as his lines write them: Heat, Max Heat, Shield, Hull, HP, Max HP, Armour, Buff,
  Debuff, Reboot.
- **As written:**
  - Brittle: "When Hit: +1 damage received per stack ({N}). / Turn Start: Reduce stacks by half, rounded down."
  - Shocked: "When Hit: If targeted, consume to double damage received, before applying defensive effects. / Conducts Chain."
  - Golden: "On Hit: +2 damage dealt. / +1 Armour. / Gain Suppressed upon losing 25% Max HP since the start of the effect. / On Suppressed: Reduce stacks to 0. / Turn End: Reduce stacks by 1."
  - Penetrate: "Also hits all other Sprites in the same column, dealing {N} damage. The extra hits are not Targeted."

## 2. The rules

### Who

**1. Frame, Sprite, unit.** (settled 23 November: his word)
Our side's pieces are *Frames*, the other side's are *Sprites*, and *unit* means either, always
capitalised but never tappable terms. "Foe", "machine" and "enemy" leave the shown text (his: "I
want to stop using 'foe'. I'd prefer something like Sprite for the flat faction"; "Sprite and
Frame?"). The engine keeps its own names. The HUD's ENEMY PHASE stays ("Keep it, no need to
change that"). The tips, the target lines and the glossary are swept; the other kinds follow as
each is rewritten.
- "Target: Every Foe" → "Target: Every Sprite"
- "this machine" → "this Frame"

**2. Name a group by who is in it.** (settled 22 November: his mark, 2-A)
Ours are Self, Any Frame, Another Frame, Every Frame, Every Other Frame. The Sprites' are Self,
Another Sprite, Every Sprite, Every other Sprite (rule 1's words). Every Frame is one term for a
buff on your whole team and a Sprite's attack on it. Built on the target lines and the tips.
- "Any ally or self" → "Any Frame"
- "Every Ally" → "Every Frame"

**3. A piece calls the machine it's on "this machine".**
That covers components, passives and modules. A status's tip calls the unit carrying it "it".
- "costs its owner 3 hull" → "costs this machine 3 hull"

**4. The player is "you".**
The two halves of a round are "your turn" and "the foes' turn".
- "at the end of the player's turn" → "at the end of your turn"

**5. A Sprite makes moves.**
Its *intent* is the move it's showing this round. The word "action" goes, and the term "Foe
action" becomes "Sprite move" (renamed with rule 1).
- "skips its telegraphed action" → "skips its move"

### Whom

**6. One format for the target line.**
It's "Target:" plus the group, and for a weapon, its reach after a comma. Terms keep their
capitals and everything else is sentence case. A move aimed at a place keeps its plain words
("Target: Empty places").
- "Every foe" → "Every Foe"
- "One of its own" → "Another foe"

**7. "The target" and "each foe hit".**
*The target* is the one unit the use or move is aimed at. *Each foe hit* (or *each unit hit*) is
every unit it lands on: the target plus anything its area reaches. The tips use both.
- "every foe the entry reaches is Exposed" → "Resolve: Apply 2 Exposed to each unit hit."

**8. Area words.**
*Beside* means left or right in the same rank. *Behind* and *in front of* mean the other rank of
the same column. *Around* means all of those.
- "every foe round its slot" → "every foe around it"

**9. The attack's targeting word goes on its target line.** (settled 19 November: built)
"Target: The hottest machine" and its kin. The four words wait on his sign-off (section 4).

### When

**10. Event labels.** (settled 22 and 23 November: his word)
A timed line opens with its label, then a colon: Turn Start, Turn End, Round End, and a use's
events (rule 31). "Its" never needs to say whose. Past those, the labels the tips use (his "The
rest is fine", with "When broken -> Shield Broken", and his "Hull Damaged" of 24 November): When
defeated, On Reboot, Shield Broken, Hull Damaged,
Skirmish Start, When it would gain X, When X would be reduced, At N stacks, and On X as X is gained
(his Golden's "On Suppressed", Drill Out's "On Burrowed"). "Lasts the skirmish."
or "Lasts the battle." is a line of its own for what never counts down.
- "As its turn ends it halves" → "Turn End: Reduce stacks by half, rounded down."

**11. A status's timing lives in its tip.** (settled 22 November: his mark, 11-A)
A text that applies a status gives its name and number, and states a time only when that source
changes it.
- "It roars and its fur goes gold: its blows hit 2 harder ... for three rounds" → "It roars and its fur goes gold: Golden 3."

**12. Looking ahead.**
Use "this round" and "next round". Something that lands later is "in 2 rounds"; something that
lasts is "for 2 rounds".
- "two rounds on" → "in 2 rounds"

**13. Round, skirmish, battle.** (settled 22 November: his mark, 13-A)
A *round* is your turn plus the foes' turn, a *skirmish* one pack fought to the end, a *battle*
the whole map. "Skirmish" is the noun; "fight" stays only as a verb.
- "It lasts the fight" → "Lasts the skirmish."

**14. A stack changes by "reduce stacks"; a status that never stacks is consumed or removed.** (settled 23 and 24 November: his word)
"Reduce stacks by 1", "Reduce stacks by half, rounded down", "Reduce stacks to 0". No plural to
adjust. A status that never stacks has no stacks to reduce ("Rage is a buff status that isn't
stacked. So non-stacking statuses shouldn't say 'reduce to 0,' they can just say 'Consumed' or
'Removed' just like Shock"): "Consumed" when its own effect spends it, "Removed" when it ends.
A Cleanse or a Purge *removes*.
- "a stack fades" → "Reduce stacks by 1."
- "Turn Start: Reduce stacks to 0." (Ward) → "Turn Start: Removed."
- "When its heat reaches nothing, the Rage ends and it reboots at once." → "At 0 Heat: Consumed to Reboot immediately."

### What things are called

**15. A term is written with its capitals.**
That way it shows in its colour and can be tapped. Ordinary words stay lowercase.
- "every machine scorched, ×4" → "every machine is Scorched 4"

**16. Stacks are written "Name N" on a chip, a readout and a move line.**
"×" only means times, as in a weapon's hits or a multiplier. "+" and "−" only mean a change to a
number. A sentence that lays stacks puts the number first ("Apply 1 Ablate", "Gain 3 Golden"), his word
of 23 November.
- "Grants Empowered ×2" → "Grants Empowered 2"

**17. A chip shows its stack count as a plain number.**
"2" instead of "×2"; a single stack shows no number, a timer shows its count at one. This one
needs his eye on the phone.

**18. A readout's first line says what kind of act it is.**
Attack N, Buff, Debuff or Defend, the same four words on both sides.
- "Grants Empowered ×2" → "Grants Empowered 2"

**19. A keyword's line matches its chip on the die.**
- "Apply Ablate 2 on hit" → "Ablate 2"

**20. Each stat has one label, spelled out.**
HP stays the only abbreviation.
- "ATK 4 // ARM 1" → "ATTACK 4 // ARMOUR 1"

**21. Attack and hit.** (settled 22 November: his word)
An *attack* is one use of a weapon, or one attack move. A *hit* is one of its blows landing on a
unit. "Blow", "strike" and "shot" leave the text.

**22. Defeated, wrecked, destroyed.** (changed 23 November: his word)
A foe is *defeated* at 0 HP ("When it falls -> when defeated"), and whoever got it there *killed*
it. A machine is *wrecked*. A component is *destroyed*. "Falls" and "felled" leave the text.
- "When this foe falls" → "When defeated"

**23. A component is used, not spent.** (settled 22 November: his word)
You *use* a component by dropping its die on a target. "Spend" stays the engine's word and the
word for a resource that is gone once paid (rerolls, Ore).

### How it reads

**24. A tip is precise and succinct.** (settled 22 and 23 November: his words)
- It says what happens in the game's terms and nothing more, and names no other rule that may
  change ("if either gets changed, the tip needs editing as well").
- No semicolon. One effect a line.
- A condition goes inside the line, never in its label ("On Hit: If targeted").
- A per-stack line shows its unit's sum, his {N} ("+1 damage per stack ({N})"); a line that only
  counts stacks shows none.
- A status's numbers are its own, never the move's or the passive's that laid it.
- It names no piece that carries it, and never repeats its heading.

**25. Rule numbers are digits, and rates use "per".**
- "a point a stack" → "1 per stack"

**26. Repeat the noun.**
- "a machine's as the player's turn ends, a foe's as its own turn does" → "a machine's Empowered at the end of your turn, and a foe's at the end of its own turn"

**27. A move's line keeps its voice.**
The flavour stays as written. Any rule it states follows these rules, and by rule 11 a status it
lays is named, not explained.
- "Bloodlust: every foe on the field hits 2 harder, itself too, fading by half each round." → "Bloodlust: every foe, itself included, gains Empowered 2."

**28. A foe's page says what it is, then how it fights.** (settled 22 November: his mark, 28-B)
The lore stays word for word, and advice is cut entirely.

**29. Retired words leave.**
These follow from rulings he has already made: shields and vents as pieces (but the Musk Ox's
reload and machines in design), overshield, Retaliate, a chassis's cooling, "braces" (Armoured),
"burning" for Ablate, "enemy", "falls".

### Timing

His proposal of 22 November, for design and for the player alike: a use split into events, so a
rule says exactly when it acts. "These are not replacements for actual code hooks."

**30. A property has no event.** (settled 22 November: his word)
Spread, Penetrate, Instant and "Ignores Armour" are always on, so they are written bare.
- "Penetrate" → "Also hits all other foes in the same column, dealing {N} damage. The extra hits are not Targeted."

**31. A use's events, in order.** (settled 22 November: his words, Commit and Resolve)
*Commit*: the target is chosen, before any hit. *On Hit* and *When Hit*: as each hit lands.
*After Hit* and *After Being Hit*: once that hit's damage is known. *Resolve*: every hit done;
riders land here, so no hit of a use feeds on what the use lays.

**32. When a status acts.** (settled 22 November: his word)
Turn Start, Turn End, Round End, and when it is consumed ("When Hit: If targeted, consume to
double damage received").

**33. Conditions.** (settled 22 November: his word)
Inside the line: "If any foe hit was defeated", "If damage dealt", "If targeted". The extra hits
of Spread and Penetrate fire every event but the target's.

**34. The Honey Badger, written so.** (settled 22 November: his example)
- "Ore" (Resource): "Maximum 3. Consumed by Bullion Fragmenter. At 3 Ore, base Armour increases by 1."
- "Chainsaw Claw": "Ignores Armour. After Hit: If damage dealt, gain 1 Ore."
- "Bullion Fragmenter": "Commit: Consume all Ore. Hit once per Ore consumed. No Ore is gained from these hits."

### Phrases

**35. Common phrases.**
"If a weapon was used" on what a weapon's use spends, "If this was an attack" where either side's
attack spends it; "When it would gain X: Prevent it" for what stops a status landing; "Cannot be
cleansed." on a debuff no Cleanse removes, until the headings say it (rule 24); X and Y for an
entry's two printed numbers ("+X damage per Y Heat vented, as shown on the entry"); "Only X
available." gave way to "Fixed: X" for a die held to one component (24 November).
- "Resolve: If triggered, reduce stacks by 1." → "Resolve: If a weapon was used, reduce stacks by 1."

**36. A reach over every Sprite targets the field.** (settled 24 November: his word)
"A weapon that hits every sprite, for that reason, should probably be coded as none are targeted,
since its targeting the field." Its tip says "No hit is Targeted", and the engine aims none of its
hits (`docs/rules.md`, Every Foe).

**37. Technical lines, not prose.** (settled 24 November: his word)
"You're still writing prose and not technical lines": a line states the rule, no "its" and no
clause it can do without. A status's trigger lives on what grants it: the Nemesis's passive says
"Turn Start: If at Max Heat or higher, remove all Debuffs and gain Rage.", and Rage says what it
does.
- "Its Knuckles of Fury are its only component, and gain Instant." → "Only Knuckles of Fury available." (Rage) and "During Rage, gain Instant." (the Knuckles)
- "Cannot reboot by choice." → "Reboot disabled."

**38. Game nouns are capitalised.**
His lines of 24 November write Heat, Max Heat, Debuffs and Reboot with capitals, beside Armour
and Max HP: so do Shield, Hull, HP, Buff and Debuff. "Damage" stays lowercase, as his lines have it.

### Damage

**39. Hit, suffer, lose.** (settled 24 November: his word)
His format of 24 November: "I like hit for N, suffer N damage, and lose N hull as the format
examples that we want", for his ask the same day, "standardize the difference between something
that hits, and is affected by armour and brittle and such like the Mole's Drill debuff, and flat
damage that bypasses all that like Ablate." Three verbs for the three ways damage lands:
- *Hit for N*: a hit. A Frame's Shield takes it first, then Armour comes off what reaches Hull or
  HP; Barrier, Brittle and every When Hit apply. A status's own line says "take a hit for N damage".
- *Suffer N damage*: not a hit. A Frame's Shield takes it first, then Hull or HP; Armour, Barrier,
  Brittle and the hit events never touch it (Ablate, Corrupted).
- *Lose N Hull* (HP, Shield): off that number alone, nothing before it (Volatile, Overheated,
  Vitriol).

Hull Damaged reads all three. The verb says what touches the damage, so no line adds "Ignores
Armour and Barrier" to say it again.
- "Turn End: Take 1 damage per stack ({N}), then reduce stacks by 1. Ignores Armour and Barrier." (Ablate) → "Turn End: Suffer 1 damage per stack ({N}), then reduce stacks by 1."
- "Take 1 Hull damage per stack ({N}), ignoring Shield and Armour." (Overheated) → "Lose 1 Hull per stack ({N})."
- "Then, take 1 damage" (Applied Momentum) → "Then, take a hit for 1 damage"
