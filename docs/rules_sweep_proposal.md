# The rules sweep: limits on design space, for Ryan's marks

Ryan, 19 November: "Things that limit design space should never be a rule"; "We need to make
sure I'm being notified when 'rules' are being written without me knowing." The to-do's line
asked for a sweep of `docs/rules.md`, the bible's Decided rows and the briefs for limits on what
a piece, a step or a machine may do that rest on no word of his, a session's reading written as
a rule, each listed with the words it stands on. The validator was read with them, since a check
there refuses content outright. The branch step held to one locked piece was the first, cut on
19 November; this is the rest.

Three readers swept the files on 20 November at `56cf31ae` (line numbers are that commit's), and
the claims were checked against the files before they went in. Nothing has been cut. Each item
is one limit, wherever it is written: the rules, the bible, the briefs and the validator together.

- **A**: no word of his. A session's reasoning written as a rule or an exclusion.
- **B**: it cites him, but the limit is stronger than his words.

His marks, an item at a time (the page has the buttons):

- **Cut**: the limit goes from every place the item names, its check and the check's tests with
  it. A guard the engine needs, because it cannot yet run the shape, stays, labelled as what the
  engine runs.
- **Lean**: it stays as a lean and leaves the rules and the validator. An A item is written as
  Claude's lean; a B item at the strength of his own words.
- **Keep**: it stays as written, and his mark is the word it now stands on.

Each item ends on Claude's suggestion. A note on any item is read as written. The fold cuts and
rewrites what he marks, every place at once, names each change in its report, and retires this
file.

## What the validator refuses

### V1. Three authored keywords at most

- **Kind:** A
- **Where:** `docs/rules.md` 46; `sim/content_db.gd` 11 and 1950 (`MAX_AUTHORED_KEYWORDS`); the bible's keywords row (line 509)
- **It says:** "up to three authored keywords"
- **His words:** none. The row beside it records him dropping the keyword budget "since it got in the way of good ideas".
- **A cut:** the cap and its check go; an authored entry carries the keywords its fantasy needs.
- **Claude:** cut

### V2. A die of four to ten entries, four module slots at most

- **Kind:** A
- **Where:** `sim/content_db.gd` 20, 21 and 2503 (`MIN_DIE`, `MAX_DIE`), 30 (`MAX_MODULE_SLOTS`)
- **It says:** "no machine rolls one today"; "ten leaves it room"; module slots "room to move"
- **His words:** only the facts it was built from: the Clydesdale carries nine, and module slots are two, the Clydesdale's three. The bible's Kite row keeps a die of three "free to come back in another form", which the validator refuses.
- **A cut:** the bounds become a sanity check (a die has at least one entry).
- **Claude:** cut

### V3. Three effects in a passive, one rule on a module

- **Kind:** B
- **Where:** `sim/content_db.gd` 29 and 2004 (`MAX_PASSIVE_EFFECTS`, one more for a one-off); `docs/rules.md` 68 (a module's "at most one rule"); the bible, lines 677 ("at most three rule lines") and 708 ("plus at most one rule")
- **It says:** a passive holds three engine effects at most; a module carries at most one rule
- **His words:** "Rule text is a budget, not a cap" (12 October, the bible's line 337). The bible caps lines of text; the validator counts engine effects, which is another measure.
- **A cut:** the counts go; rule text stays a budget, judged by how it reads.
- **Claude:** cut

### V4. The buffs a spend may lay on its own machine

- **Kind:** A
- **Where:** `sim/content_db.gd` 12 to 15 (`SELF_GRANTS`), checked at 1892 and 2048
- **It says:** a piece's rider on its own machine (`self_status`) lays one of a closed list
- **His words:** none closing the list; on 19 November he added Barrier, Ward and Parry to it for the Beam Buckler. The engine lays any status in its table, so the list refuses Spun Up, Ricochet, Phased, the Aile buffs and Juggernaut Drive as such a rider. It has the form of the Barrier check cut this week.
- **A cut:** the list goes; any machine buff the engine runs may be laid on the spender. His word that every Phased granter is gated still stands.
- **Claude:** cut

### V5. Rapid or Instant, never both

- **Kind:** A
- **Where:** `docs/rules.md` 585; `sim/content_db.gd` 1804 to 1808
- **It says:** "each gives the machine its turn back its own way"
- **His words:** none. The bible's Rapid row says only that the validator holds content to it.
- **A cut:** an entry may carry both, once a test shows the engine runs the pair.
- **Claude:** cut

### V6. Every Ally is never a vent's

- **Kind:** A
- **Where:** `docs/rules.md` 39; `sim/content_db.gd` 1831; the bible, line 446
- **It says:** Every Ally and Every Other Ally are "a shield's or a buff's, never a vent's"
- **His words:** none. The engine's vent lands on one machine, so the true line is that no vent reaches every ally yet.
- **A cut:** the rules say what the engine runs, and the check stays as that guard until a piece wants it built.
- **Claude:** cut

### V7. A gun fires its whole heat or its whole shield, never both

- **Kind:** A
- **Where:** `sim/content_db.gd` 1616 and 1617; in neither the rules nor the bible
- **It says:** "one whole gauge a gun"
- **His words:** none.
- **A cut:** the check goes, or stays as an engine guard if the engine cannot run both.
- **Claude:** cut

### V8. A consumer strikes once on each foe

- **Kind:** A
- **Where:** `docs/rules.md` 663; `sim/content_db.gd` 1758 and 1759
- **It says:** "one blow on each foe (no strikes past one)", and no Every Foe
- **His words:** none. It is the shape of the build of 22 October; area came on 28 October, and the engine already eats each foe's stacks on its first blow.
- **A cut:** a consumer may strike more than once and reach every foe; each foe's first blow eats its stacks.
- **Claude:** cut

### V9. The capital's maker has no tier-one module

- **Kind:** A
- **Where:** `sim/content_db.gd` 2388 and 2389
- **It says:** "the capital's maker has no tier-one module"
- **His words:** his exception of 13 October is "a chassis rule only": no tier-one chassis and no basics. Modules are not in it.
- **A cut:** the check goes.
- **Claude:** cut

### V10. A round-long status is granted for one round

- **Kind:** B
- **Where:** `sim/content_db.gd` 1926 to 1929; `docs/rules.md` 792 ("no grant holds it longer")
- **It says:** Armoured, Barrier, Ward and Parry are never granted for longer than a round
- **His words:** a lingering defensive buff "would stack into a wall" (12 October). The bible's row beside it: "A longer Armoured is not banned: it needs a drawback of its own."
- **A cut:** the check goes; a longer grant carries a drawback of its own, his condition.
- **Claude:** lean

### V11. A branch is never a stat

- **Kind:** B
- **Where:** `docs/rules.md` 88; `sim/content_db.gd` 2599
- **It says:** "a branch is never a stat"
- **His words:** "Probably not stats, since that's more the job for Modules" (`docs/locked_pieces_proposal.md`, 75).
- **A cut:** his "probably not" in the rules, and the check goes.
- **Claude:** lean

### V12. What a fall may do

- **Kind:** A (the drain B)
- **Where:** `docs/rules.md` 1399 to 1401, 1364 and 868; `sim/content_db.gd` 2803 (`Foe.FALL_EFFECTS`), 3107 and 3109; the bible, line 847
- **It says:** a fall "does nothing its own body would carry, summons nothing (a split is the fall's own summon), swallows nothing, never purges, takes no reroll, and lays no Expose"
- **His words:** "Death effects should be dictated by the effect, same as moves" (16 November). On the drain, a lean about one domain and one trigger: "denying rerolls is not the meadow's job, at least not on a ubiquitous enemy at a trigger you can't avoid". On purge, "Agreed on silence, purge, and cleanse". What needs the living body (its own body's effects, a swallow) cannot run once it falls; the summon, the purge, the reroll and the Expose are a session's. The Sap on all of 20 November is missing from the list with no reason given.
- **A cut:** the list keeps only what a fallen foe cannot run; everything else is dictated by the effect.
- **Claude:** cut

### V13. A purge is a special, never a rider

- **Kind:** B
- **Where:** `docs/rules.md` 1375; `sim/foe.gd` 632 (`SPECIALS_ONLY`); `sim/content_db.gd` 2776 to 2778
- **It says:** "a purge is a special, never a rider"
- **His words:** "Agreed on silence, purge, and cleanse", agreeing with an analysis. A before step already puts a Purge ahead of the Pilgrim's knife.
- **A cut:** a purge may ride a blow.
- **Claude:** cut

### V14. Six shape checks

- **Kind:** A
- **Where:** `sim/content_db.gd`, each at its line below
- **It says:**
  - Aloft only on a blow that gathers one round (2774 and 2775); his words of 16 November cover only the untargetable climb.
  - A swallow lasts one to three rounds (2885 and 2886).
  - Follow-ups are one deep (2698 and 2699).
  - A piece that turns a folded die is a Rapid buff on itself (1870 and 1871); his word was "the same piece with one cooldown".
  - A buff that spends its machine's count targets itself (1645 and 1646).
  - A team-reroll buff grants no status beside it (1907 and 1908).
- **His words:** none for any of the six. Some may be what the engine runs today.
- **A cut:** each goes, or stays as an engine guard labelled so; a note names any to keep.
- **Claude:** cut

### V15. Tags: a closed set, read by nothing, worn by weapons alone

- **Kind:** A
- **Where:** `docs/rules.md` 56 and 58; `sim/content_db.gd` 2253 (`TAGS`), checked at 2337, 2110 and 2194; the bible, lines 701 and 702 ("Components never read tags")
- **It says:** eight tags are "the only tags a component may wear", "a shield, a vent and a buff none", and no component reads one
- **His words:** none, for closing the set or for keeping pieces off reading it. The closed set may only guard the vocabulary, as the keyword list does.
- **A cut:** a piece may read a tag and any piece may wear one; a new tag is added as content needs it.
- **Claude:** cut

## Written in the rules

### R1. Barrier: one machine at a time, a cooldown on every granter, one stack

- **Kind:** B
- **Where:** `docs/rules.md` 905 to 908; the bible, lines 485 ("one machine at a time", "no passive counts it past one") and 553 (the table's "never granted to every ally at once"); `docs/briefs/aphelion_barrier_ward.md` 26 and `aphelion_carrier.md` 50 and 51 ("so a screen must stay a shield number")
- **It says:** "No piece grants it to every ally at once, and every piece that grants one carries a cooldown of 1"
- **His words:** "A team ward is probably ok, as is a team barrier, really, it's just combining them in a way that doesn't let both be cast back to back" (10 November); "Barrier can have a cooldown, yeah"; "Barrier probably shouldn't be stackable". The cooldown line is no longer true: the Beam Buckler lays a Barrier every spend.
- **A cut:** the rules and the two briefs say his: a team Barrier and a team Ward never cast back to back, and a Barrier probably does not stack.
- **Claude:** lean

### R2. Foes never add heat to a machine

- **Kind:** B
- **Where:** `docs/rules.md` 1212
- **It says:** "Foes never add heat to a machine."
- **His words:** foe heat is "so polarising that it needs several avenues of counterplay" (12 October), a condition and no ban. The bible's Ablate row has direct heat from a foe retired, "free to come back in a new form".
- **A cut:** the line says his condition.
- **Claude:** lean

### R3. One blow a move, and that its first step

- **Kind:** A
- **Where:** `docs/rules.md` 1335
- **It says:** "One blow a move, and that its first step"
- **His words:** none. The bible calls it "a first build's and no rule".
- **A cut:** the rules say what the bible says: the first build's.
- **Claude:** lean

### R4. No passive turns Every Foe into Direct or Indirect

- **Kind:** B, unsure
- **Where:** `docs/rules.md` 317; `sim/effects.gd` 1469; the bible, line 446
- **It says:** Every Foe is "a targeting mode of its own: no passive turns it into Direct or Indirect"
- **His words:** the engine's note credits him with Every Foe as a targeting mode of its own (4 November). The sweep found his "should not narrow targeting modes" said of Silence, cut on 15 November. Either may be the root.
- **A cut:** a passive may narrow Every Foe, and the engine's hard line goes.
- **Claude:** keep, if his words of 4 November meant it

### R5. No rule reads the flattened hexes

- **Kind:** B
- **Where:** `docs/rules.md` 1816
- **It says:** "No rule reads the flattened hexes."
- **His words:** "art only for now", and a skirmish terrain effect, if ever, "will be on enemy painted terrain".
- **A cut:** "art only for now", his.
- **Claude:** lean

### R6. Hull never heals in the battle

- **Kind:** B, unsure
- **Where:** `docs/rules.md` 1127
- **It says:** hull "is the battle's and never heals in it"
- **His words:** none of his bans a repair piece. It rests on the bible's wear test and on Claude's answer, "unmoved", to his worry about recharging on the map.
- **A cut:** a repair piece is free to be proposed, priced against the wear test.
- **Claude:** lean

### R7. At tier one no action takes the lightest machine from full

- **Kind:** A
- **Where:** `docs/rules.md` 504 to 506; `docs/briefs/numbers_pass.md` 316; the bible's scale row
- **It says:** "any one action's blows on one machine come to less than its shield and hull together"
- **His words:** none for the cap. He gave the numbers pass the sizing, and this is its target.
- **A cut:** it stays as the numbers pass's sizing target, written as its lean.
- **Claude:** lean

## The bible's Decided rows

### D1. Module armour: +1 at most, tier two or three, paid in a big stat

- **Kind:** A
- **Where:** the bible, line 486 (the armour row)
- **It says:** "module armour is scarce, +1 at most, tier two or three, and paid in a big stat"
- **His words:** none; the row's quotes are about base armour. Content already breaks it: the Ablative Plating is tier one at armour +1.
- **A cut:** the sentence goes; module armour is priced as any stat.
- **Claude:** cut

### D2. The occult is the Council's, and the Arsenal's manual never says demon

- **Kind:** A
- **Where:** the bible, line 263
- **It says:** among the makers "the demonic and the eldritch are the Council's and its Arsenal's", the cosmic register "never a maker's", and the Arsenal's manual "never says demon"
- **His words:** names and machines "can be incongruent" (line 262). A maker's theme written as an exclusion.
- **A cut:** it stays as a lean of the Arsenal's voice, no exclusion.
- **Claude:** lean

### D3. The Kite is never balanced around area

- **Kind:** A
- **Where:** the bible, line 446
- **It says:** "area is no part of Kestrel's brief, so the Kite is never balanced around it"
- **His words:** none.
- **A cut:** the sentence goes.
- **Claude:** cut

### D4. Spending more for keywords stays the siege battery's

- **Kind:** A
- **Where:** the bible, line 756 (the Musk Ox row)
- **It says:** "spending more for keywords stays the siege battery's"
- **His words:** none, and his own run the other way: "if you say 'can't do this thing because that already kind of does it,' then you quickly run out of things" (line 678).
- **A cut:** the sentence goes.
- **Claude:** cut

### D5. A passive that only feeds its own fixed pieces adds nothing

- **Kind:** A
- **Where:** the bible, line 678 (the identity row); `docs/briefs/minerva_mole.md` 73 to 75 (retired 24 November; `git show d015406c:docs/briefs/minerva_mole.md`) ("no closed loop between a passive and its own locked piece")
- **It says:** "A passive that only feeds its own fixed components adds nothing"
- **His words:** "it must open build space", said of the Onryō. The sentence runs against line 746 ("fixed pieces that feed each other are design space of their own") and line 692 (a locked piece "glues" the identity together "with the passive").
- **A cut:** the sentence goes, and his "open build space" stays.
- **Claude:** cut

### D6. Two shapes for a passive

- **Kind:** A
- **Where:** the bible, lines 677 ("a double-edged niche definer … or a plain multiplier fantasy") and 679 ("A passive multiplies or redirects what components already do")
- **It says:** a passive takes one of two shapes
- **His words:** none. The Polar Bear's seal and the Cassowary's stepping die fit neither.
- **A cut:** the two shapes stay as examples, no rule.
- **Claude:** lean

### D7. Foes mitigate by armour or recovery, never a shield of their own

- **Kind:** A
- **Where:** the bible, line 847
- **It says:** "The enemy mitigates by armour or recovery, never by a shield of its own"
- **His words:** none. It survives from the old playtest set's row, whose condition gate he disowned. The Pit Antlion and the Djinn already carry Barrier.
- **A cut:** the sentence goes.
- **Claude:** cut

### D8. Components are never modified, and a passive never swapped

- **Kind:** A
- **Where:** the bible, line 875
- **It says:** "Components are never modified"; "its passive is never swapped"
- **His words:** none. Line 870 runs against it: a branch tweaks the locked pieces, and a step on the passive takes the place of the effect it names.
- **A cut:** the row says what the branches do.
- **Claude:** cut

### D9. The commander layer, before its design

- **Kind:** A
- **Where:** the bible, lines 807, 811 and 816 (line 808 pins the layer for later)
- **It says:** "A reusable ability deals no direct damage"; "never from rewards"; "No command die rolls on the battlefield"
- **His words:** none.
- **A cut:** the three stay as Claude's leans for the layer's session.
- **Claude:** lean

### D10. A Fracture brings the elite and nothing more

- **Kind:** A
- **Where:** the bible, line 413
- **It says:** "a Fracture brings the elite and nothing more, Claude's third round, unmoved"
- **His words:** none; lines 412 and 814 hold a Fracture's prize open.
- **A cut:** a lean, labelled Claude's.
- **Claude:** lean

### D11. At most one guest

- **Kind:** A
- **Where:** the bible, lines 361 and 828
- **It says:** "at most one guest"
- **His words:** none; the reason went in a rewrite.
- **A cut:** a lean, its reason back or gone.
- **Claude:** lean

### D12. Robots stay off; flying heroes are hunters with reach

- **Kind:** A
- **Where:** the bible, line 839
- **It says:** "Robots stay off (or one late wildcard); flying heroes are hunters with reach"
- **His words:** none; both reasons were dropped.
- **A cut:** a lean.
- **Claude:** lean

### D13. The Puffin stays the one machine that cools another

- **Kind:** A
- **Where:** the bible, line 735
- **It says:** "it stays the one machine that cools another by its own spend"
- **His words:** none.
- **A cut:** the clause goes.
- **Claude:** cut

### D14. No cleanse lifts a cooldown

- **Kind:** A
- **Where:** the bible, line 817
- **It says:** "No cleanse lifts a cooldown"
- **His words:** none.
- **A cut:** a lean.
- **Claude:** lean

### D15. Five makers at most

- **Kind:** A
- **Where:** the bible, line 716
- **It says:** "Five makers at most"
- **His words:** none; no reason, no exit.
- **A cut:** a lean, or the count stated as today's.
- **Claude:** lean

### D16. A promoted form adds its size, its armour and one move

- **Kind:** A
- **Where:** the bible, line 841
- **It says:** a promoted form adds "its size (2), its armour and one move more"
- **His words:** none.
- **A cut:** the recipe stays as the first promoted forms' shape, no rule.
- **Claude:** lean

### D17. A shield grant keeps two places, and on equipment stays off the die

- **Kind:** B
- **Where:** the bible, line 484
- **It says:** "A shield grant keeps two places"; on equipment it "stays off the die"
- **His words:** on 13 November he refused one proposal. His general expectation (line 490) is softer: "I don't want to make a strict rule about anything", a grant being "part of a kit or locked piece. Or gated behind a synergy". The row leaves out the kit and the synergy.
- **A cut:** his expectation in full, at his strength.
- **Claude:** lean

### D18. A pack is authored by hand, and no cell lists alternatives

- **Kind:** B
- **Where:** the bible, line 390
- **It says:** "authored by hand, never generated"; "no cell listing alternatives"
- **His words:** on 5 November he allowed "semi-random combinations"; the ban on alternatives rests on his question of 8 November about a core's parts.
- **A cut:** his "semi-random combinations" in the row.
- **Claude:** lean

### D19. The action economy's three rules of thumb, and every new Rapid gated

- **Kind:** B
- **Where:** the bible, line 465; `docs/briefs/README.md` 150 to 163 ("Three rules of thumb for every design, rework and rebalance"; "Rapid stays for the cantrip, gated"); `docs/briefs/kestrel_line.md` 117 and 118 ("the Rapid pile the action economy forbids")
- **It says:** a design that wants many blows goes to strikes, order to a die mechanic, a second action to a banked resource, a cooldown or an ally's turn; every new Rapid is gated
- **His words:** a diagnosis: "rapid is turning into the new Suppress in terms of build ubiquity" (20 October). The fix is a session's; the commit that recorded it (`e5654263`) labelled it "Claude's leans, Ryan's numbers", and the label has since dropped.
- **A cut:** the row and the README keep it as Claude's leans, with his diagnosis.
- **Claude:** lean

### D20. City defences are never a unit on a row of their own

- **Kind:** B
- **Where:** the bible, line 391
- **It says:** "never a unit on a row of its own"
- **His words:** "I expect city defenses to take the form of wall segment upgrades now, honestly".
- **A cut:** his expectation, no ban.
- **Claude:** lean

### D21. A foe's tags are never a mechanic

- **Kind:** B
- **Where:** the bible, line 851
- **It says:** a foe's tags are "never a mechanic"; "no rule does"
- **His words:** "really the only hook is for audio AND possibly attack/death animations". He named the hook; he did not ban another.
- **A cut:** his hook, no ban.
- **Claude:** lean

### D22. A retaliation elsewhere needs a fantasy of its own

- **Kind:** B
- **Where:** the bible, line 474
- **It says:** "Retribution is the Arsenal's strongest suit (a lean, section 7); a retaliation elsewhere needs a fantasy of its own."
- **His words:** a lean ("retribution is the Arsenal's thing", line 697) turned into a gate on the other makers. A maker's theme is an identity, never an exclusion.
- **A cut:** the second clause goes.
- **Claude:** cut

### D23. No foe's threat is gated on the player's state

- **Kind:** B
- **Where:** the bible, line 847
- **It says:** "None gates a threat on the player's state"
- **His words:** every special needing a condition "was never a rule I made" (24 October): he disowned requiring a condition, not this kind of one. The row's own purge reads the player's state (a machine carrying a buff).
- **A cut:** the sentence goes.
- **Claude:** cut

### D24. A purge never takes the exemptions

- **Kind:** B
- **Where:** the bible, line 467
- **It says:** a purge takes stacks, "never the exemptions"
- **His words:** "Agreed on silence, purge, and cleanse", agreeing with an analysis.
- **A cut:** a lean.
- **Claude:** lean

### D25. Seven smaller lines, each a softer word of his made firm

- **Kind:** B
- **Where:** the bible, each at its line below
- **It says:**
  - Line 363, "The ramp scales no pack", on his "it probably doesn't need to … maybe".
  - Line 384, a way of moving is "never a rule", on a paraphrase ("no reason beyond visual variety").
  - Line 835, a recolour gets "one twist", "a move added or swapped at most"; his words, "ideally with more threatening mechanics".
  - Line 337, "Common components carry none" (no unique text); his point was that unique text makes building fun.
  - Line 340, "every component carries a price", while the row holds equipment's price open and a buff carries none.
  - Line 847, a special is "an engine effect never keyed to one foe"; on 15 November he called "every enemy special move having unique text and rules" fine.
  - Line 874, "Offers, never trees", with no reason, and a branch is a small tree.
- **His words:** as quoted in each line.
- **A cut:** each reads at his strength; a note names any to keep.
- **Claude:** lean

## The briefs

### S1. The combo ramp pays in heat and offence, never cooling or shield

- **Kind:** A, this session's
- **Where:** `docs/briefs/README.md` 286 to 291, written on 19 November by the session writing this list
- **It says:** "Under the reboot it wants paying in heat and offence, never cooling or shield"
- **His words:** of this ramp, "maybe it gains cooling and shield Regen or something" (14 October, in the line frame's first brief, in git); and his expectation under the reboot, "I don't want to make a strict rule about anything", a grant "Or gated behind a synergy". The ramp could be that synergy.
- **A cut:** the clause goes; the line says the ramp may be the synergy that gates a cooling or a shield payout.
- **Claude:** cut

### S2. What either Kestrel session must hold

- **Kind:** A
- **Where:** `docs/briefs/kestrel_line.md` 100 to 108
- **It says:** the Syrinx Drone "stays on the Lammergeier"; a hidden machine is "a state of its own"; one of the Magpie and the Owl "is the chassis that orbits Exposed"
- **His words:** only "we need at least one chassis that orbits it", which names neither machine. Claude's holes of 21 October became "must hold"; the Syrinx line has the shape of the Barrier line cut this week, and the stealth reason dates from when Phased could not act.
- **A cut:** the three stay as Claude's holes for those sessions.
- **Claude:** lean

### S3. The team's debuffs grow by kinds, never by copies

- **Kind:** A
- **Where:** `docs/briefs/README.md` 106 to 108, filed under his taste; applied at `arsenal_onryo.md` 236 to 238 and 250 to 253
- **It says:** the debuffs the team lays "grow by kinds … never by copies"
- **His words:** none, and his own lean the other way: "maybe the DoT is ok and its the DoT capstone?" (14 October, the Onryō's brief).
- **A cut:** it leaves his taste and stays as Claude's lean.
- **Claude:** lean

### S4. Three ownerships on the Waste's bench

- **Kind:** A
- **Where:** `docs/briefs/numbers_pass.md` 398 to 404
- **It says:** "the swallow is Floraison's and the Colossus's", "a rung's twist is its own", "the field on one machine is Exposed's"
- **His words:** none for the three, and against them, "rather than restricting a difficult mechanic, give it an answer" (20 November). The bench's form is right; these three of its rules are a session's.
- **A cut:** the three go from the bench's rules.
- **Claude:** cut

### S5. The Cryo defence kept clear of two unfinished designs

- **Kind:** A
- **Where:** `docs/briefs/minerva_cryo_defence.md` 53 to 57 and 64
- **It says:** "the trigger wants another home"; the open item keeps it "clear of Misharu's shield layer and the echidna's hull"
- **His words:** none, and against it: "if you say 'can't do this thing because that already kind of does it,' then you quickly run out of things".
- **A cut:** both go.
- **Claude:** cut

### S6. A wall is a kit's own state

- **Kind:** A
- **Where:** `docs/briefs/numbers_pass.md` 155 to 157
- **It says:** "a wall is a kit's own state, the seal or the loaded hopper"
- **His words:** only "don't exceed base armour of 2 in tier 1". Claude's lean of the vocabulary pass, now stated as a principle.
- **A cut:** Claude's lean, beside his tier-one cap.
- **Claude:** lean

### S7. The mole's bench by ownership

- **Kind:** A
- **Where:** `docs/briefs/minerva_mole.md` 135, 136, 141 and 142 (retired 24 November; in git at `d015406c`)
- **It says:** "a charge is the siege battery's question"; "the Onryō's Pall holds that proposal"
- **His words:** none.
- **A cut:** both reasons go; an idea benched there needs a reason of its own.
- **Claude:** cut

### S8. A multiplier is a trial's shape, never the game's

- **Kind:** A
- **Where:** `docs/briefs/refit_pass.md` 195, among the holes of Claude's TIDE lean, unlabelled
- **It says:** "a multiplier is a trial's shape, never the game's form"
- **His words:** none.
- **A cut:** labelled Claude's.
- **Claude:** lean

### S9. Tier one is never a support

- **Kind:** B
- **Where:** `docs/briefs/README.md` 140 to 143 ("Claude's, partly agreed"); applied at `minerva_mole.md` 197 and 198 (retired 24 November; in git at `d015406c`) and `aphelion_barrier_ward.md` 30
- **It says:** a tier one stands in a start "a body or a hitter and never a support"
- **His words:** "...whatever of Puffin and the two undesigned ones makes the most sense as a support-lean" (12 November), for one of Kestrel's tier-one places.
- **A cut:** the sort stays Claude's, without the "never"; the two briefs drop it as a reason.
- **Claude:** lean

### S10. No reward for being struck that scales with the foes' blows

- **Kind:** B
- **Where:** `docs/briefs/README.md` 91 to 93; applied at `arsenal_onryo.md` 279 to 283
- **It says:** "No reward for being struck that scales with the enemy's blows"
- **His words:** thorns are "dangerous rather than forbidden", balanced by a drawback they carry (12 October, the bible's thorns row); of a reward under a draw, "rewarding it for doing it's job seems potentially dangerous" (15 October).
- **A cut:** his condition: such a reward carries a drawback of its own.
- **Claude:** lean

### S11. Mechanics should not repeat

- **Kind:** B
- **Where:** `docs/briefs/README.md` 98; used to bench ideas at `minerva_siege_battery.md` 85 to 88 and `aphelion_carrier.md` 57 to 59
- **It says:** "mechanics should not repeat"
- **His words:** "there's going to be role and mechanic overlap. The trick is making the shape of each different enough" (18 October, in git).
- **A cut:** his words in its place; the two benches re-read under them.
- **Claude:** lean

### S12. Armoured on every ally, a refusal he must overrule

- **Kind:** B
- **Where:** `docs/briefs/aphelion_macross.md` 68 to 83; `ws_swallowtail.md` 24 to 26
- **It says:** his Battroid grant ("allies gain 1 armoured") is "the form the Swallowtail's row refused", needing him to overrule the row in the open
- **His words:** none behind the refusal itself ("Armoured on all hands four machines the dearest stat"). His line against team tank stats in bulk supports caution; his Macross idea asks for this grant.
- **A cut:** the hole stays as a hole; the refusal goes.
- **Claude:** lean

### S13. An interpose only on a locked piece

- **Kind:** B, unsure
- **Where:** the bible, line 478, credits him (12 October); `aphelion_barrier_ward.md` 43 and 44, `aphelion_time_shifter.md` 34 and 35, `arsenal_onryo.md` 26 and 27, `minerva_mole.md` 135 and 136
- **It says:** a draw by an ally "comes back only on a locked piece, never as a core mechanic"
- **His words:** both halves were recorded as his notes on the Arsenal pitch on 12 October ("conditionally on a locked piece, never as a core mechanic"), with no quote of his own words. The briefs sweep read "only on a locked piece", applied across the roster, as wider than he meant.
- **A cut:** "never as a core mechanic" alone.
- **Claude:** keep, unless the locked piece was a session's

### S14. A tier-one find is a new trick, never a bigger number

- **Kind:** B
- **Where:** `docs/briefs/numbers_pass.md` 222 and 223, in quotation marks and used to judge content
- **It says:** a tier-one find "is a new trick and never a bigger number"
- **His words:** "I hope ... not an obviously straight power increase" (the same brief, 25 to 27).
- **A cut:** his hope in its place.
- **Claude:** lean

### S15. Phased is the shadow panther's, by his word

- **Kind:** B
- **Where:** `docs/briefs/minerva_mole.md` 121 (retired 24 November; in git at `d015406c`)
- **It says:** "Phased is the shadow panther's orbit by his word"
- **His words:** "It keeps the phased orbit, not the Kite", a choice between two machines; the Phased row plans other granters.
- **A cut:** his choice as he made it, no ownership.
- **Claude:** lean

### S16. A shield back without the turn is a kit's or a locked piece's

- **Kind:** B
- **Where:** `docs/briefs/kestrel_line.md` 112 to 115
- **It says:** a shield that comes back without spending the turn is something "his expectation keeps to a kit or a locked piece"
- **His words:** the same expectation ends "Or gated behind a synergy", and begins "I don't want to make a strict rule about anything".
- **A cut:** his line whole.
- **Claude:** lean

### S17. A pusher's front is a straight blow and a block

- **Kind:** B
- **Where:** `docs/briefs/refit_pass.md` 56 and 57
- **It says:** "A blow that counts its peers is no identity for a pusher: its front is a straight blow and a block"
- **His words:** of the goblins, "A straight attack, and a block of some kind ... Probably a good lesson there."
- **A cut:** his lesson, as a lesson.
- **Claude:** lean

### S18. Seven smaller lines in the briefs

- **Kind:** B
- **Where:** the briefs, each at its line below
- **It says:**
  - `minerva_hedgehog.md` 105 (retired 24 November; `git show 3b3d5f4b:docs/briefs/minerva_hedgehog.md`), "a damaging lure, if kept, is never Rapid"; his words, "I would absolutely not give it rapid", then "but not sure".
  - `numbers_pass.md` 405 and 406, a countdown on the rank and file is "too ubiquitous", dropping his "primarily".
  - `ws_gunship.md` 191 to 203 reads "magnitudes, not steps" as forbidding a capstone; the rules read it as a permission (any whole number).
  - `kestrel_line.md` 139 and 140, "a locked Kestrel piece never is [a rifle]", widening his call on the Pinion Driver.
  - `README.md` 113, "Rapid pieces stay small", under his taste, with no word of his found.
  - `arsenal_thunder.md` 48, "figures who punish, never war", a name family nobody gave (names are his).
  - `kestrel_magpie.md` 77, "Locked pieces never copy (unique by rule)", Claude's hole written as a rule.
- **His words:** as quoted in each line.
- **A cut:** each reads at his strength or as Claude's lean; a note names any to keep.
- **Claude:** lean

## Corrections the fold makes

The Mole's brief retired on 20 November with its kit built (`git show
f6f11185:docs/briefs/minerva_mole.md`): S7 and S15 stood wholly in it and left with it, so a mark
on either needs no fold, and its lines cited in D5, S9 and S13 went with it.

Lines that are false today, made true with the fold unless he says otherwise:

- The bible's line 869 quotes "a chassis stocks only below its own tier"; line 870 and the validator have it stocking up to its own tier at tiers one and two. Line 869 follows.
- The bible's line 340 says "every chassis cools one at least"; since the reboot no chassis cools.
- The bible's line 466, "No player silence", is moot since Silence was cut on 15 November.
- The bible's lines 709 ("never bought") and 671 ("never removed or bought open") are his in git, but the rows have lost his name and their exits; both come back.
- `sim/content_db.gd` 2032, a comment that a Barrier and a Ward "keep their pieces and their cooldowns", which nothing checks.
- `sim/content_db.gd` 233, a comment that a branch "tweaks a locked piece", the singular reading cut on 19 November.
- The fall list (V12) lacks the Sap on all of 20 November; if the list stays, the Sap joins it.

## Kept: his words match

Read and left standing, each on his words: Instant always carries a limiter; no chassis regenerates
or cools (the reboot); a branch is two directions, each tweaking the locked pieces or the passive;
a locked piece is never a blueprint; the Arsenal fields no tier-one chassis and makes no basics; a
foe's halving status says 2 at least; Expose among the rank and file only from tier two; Destroy a
boss's rider; a status decays or is timed, never both; no foe flees but a loot-runner; no blow
passes a shield; a domain names no map shape; the hunt is the composition's; roles held, with a
stated crossing; height carries no rule; no withdrawal; immunity case by case; the rank and file
never scale in place; reserved names refused; one hunter a machine; no extra controls; pieces that
ignore armour sit high or gated; every Phased granter gated; a Rapid vent from tier three and a
Rapid shield from tier two (his "no place in the early tiers", set at three); no Suppress in a
stock and none below tier two; no suicide boss; escorts curated; Numbed exempt from every
interaction; no team tank stats in bulk; a stun priced by a gate; a team Barrier and a team Ward
never chained; Grudge never popped for burst; and the reboot's spec.
