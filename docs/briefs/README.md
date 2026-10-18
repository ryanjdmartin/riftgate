# Design session briefs

One brief for each chassis proposal, chassis direction and rework that came out of the roster
analysis (`docs/roster_analysis.md`) and Ryan's go on it, 14 and 15 October. Each is the
starting point for a design session of its own: where the design stands, what Ryan said and
when, what Claude proposed, what is open, the holes already raised, and what the session hands
back. A brief retires to git once its decisions are rows and content, as a proposal does.

Ryan, 15 October: mechanics nobody has discussed must not muddy a handoff. So the briefs hold
only what was proposed and discussed in the records and the chat; anything new is proposed in
chat first.

## How a session runs

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row (`docs/design-bible.html`), the
  "Start here" of `docs/status.md`, this file, then the brief and the files it names. If a chat
  and a file disagree, the chat is newer.
- Each brief is the design's one home. The three makers' proposal files were folded into
  their briefs on 15 October and retired, with `docs/mechanic_budgets.md`; git keeps them
  (`git show 2df9340:docs/arsenal_proposal.md`, and likewise `ws_chassis_proposal.md`,
  `aphelion_chassis_proposal.md` and `mechanic_budgets.md`) for the names offered, the retired
  rounds and the full arithmetic, all of it written under the old whole-block shield rule.
  The roster analysis's sections 1 to 11 predate the go too: where a brief and the analysis
  differ, the brief is newer.
- Propose in chat first. Ryan tweaks ideas against his own notes; a suggestion of his opens a
  discussion, so look for holes and raise them before building. If he reaffirms after hearing
  them, build it as he said.
- Mark whose words are whose: Ryan's calls carry his name and the date; everything else is
  Claude's proposal for him to move.
- Names, numbers and looks are Ryan's. He matches mechanics to silhouettes he has in hand;
  propose a name or a look only when he asks. Every number is a placeholder.
- On Ryan's go: the bible's rows (each decision with its reason and the condition that would
  reopen it), `docs/rules.md` where a rule changes, content with `"status": "planned"` where
  the engine cannot run it yet, the to-do ticked, `docs/status.md` updated, the bible
  republished. Nothing is built before the go.
- Landing a chassis also takes: its locked pieces in `content/components.json`; a new keyword
  in `content/vocabulary.json` before its code; engine pieces tested with synthetic passives;
  a lowforge model with its rig, acts and gait, judged running (a new model kind where the
  frame needs one); the bible's chassis table and the chassis count in `docs/rules.md`; the
  hangar page republished; a balance-runner row, read alone as a diagnostic.
- Sessions run in parallel on this repository: diff a shared file before staging it, and read
  the bible's live page before republishing it (the status says how).

## Decided on 14 and 15 October

Rows in the bible and lines in `docs/rules.md`; built only where a line says so.

- **The shield rule.** A shield absorbs its number and the excess passes to the hull; a breach
  ignores the shield outright (the shield stands); an injury counts what reaches the hull.
  Under the old whole-block rule a tiny shield was secretly "negate one blow", and every new
  shield design was heading for that margin.
- **Barrier and Ward**, two buffs. A Barrier: the next blow a foe lands on the machine deals no
  damage (so it never injures), its riders landing, until the round's end; never granted to
  every ally at once. A Ward: every blow a foe lands on the machine that round leaves no rider,
  breach included, while the damage lands (Ryan: it lasts the round because it is more
  situational). Both up is the old whole block at twice its price. Ward is the buff's word, so
  the Oblation Ward becomes the Oblation Mantle (in content, 15 October) and the Votive Ward the
  Votive Screen.
- **Cooldowns**: a printed property on specific pieces, shown on the entry as dark with the
  rounds left. Ryan: nearly every Rapid component reads "Rapid, cooldown 1", and the Nemesis's
  fists are simply Rapid. No cap on where a cooldown goes or how many a die carries (Ryan, 15
  October: a cap is artificially limiting).
- **The Dingo's Megataser Harpoon** carries Shock in place of Suppress (in content, 15 October).
- **Misharu's payoff is Penance**, a weaken, in place of Suppress.
- **Kestrel's gaps**: the strafer at tier one and the bomber above it.
- Agreed in chat, for the HUD: a suppressed foe's intent line clears (Ryan's point, 14
  October; built 15 October, the hold readout the last place it showed).
- **The budgets** (15 October): hard control weighed and never capped, and three tests kept
  (below).

## Ryan's taste, as the go established it

- Elegant over complicated. He pushed back each time a design grew a second mechanism ("this is
  taking off into complicated territory"); one passive, one idea; complexity belongs to the
  higher tiers.
- Never an unkillable team by another name: no team-wide armour, Braced or shield handed out in
  bulk ("giving the team tank stats is just as toxic as taking all the blows").
- No reward for being struck that scales with the enemy's blows (the old discharge). A thorns
  tank is balanceable only if the thorns carry a drawback of their own, and rewarding a tank
  for doing its job (being struck under a draw) is dangerous.
- Niches can and should overlap across a larger roster so a player finds something that fits;
  mechanics should not repeat, and a mechanic is its pattern in its context, never one trait it
  shares (Ryan, 16 October: a random target in two pieces is no repeat; "if you say 'can't do
  this thing because that already kind of does it,' then you quickly run out of things").
- Random is welcome where it adds and the player can steer it (the bible's section 2, Ryan,
  16 October).
- The foes' debuff vocabulary is thin at four words (Burning, Suppressed, Shocked, Paradox;
  Numbed is a resistance), which is why designs keep reaching for Burn or Suppress. New chips
  are fine, even unique to a chassis, since tooltips and popups carry them. The vocabulary
  grows by kinds (a weaken, a flat on-hit, a share of current hull, a timed stun, a trapped
  slot), never by copies.
- Stun is budgeted; prefer changing the enemy's problem over removing its turn. Price, never
  scarcity (17 October, of Suppress): a mechanic rationed by availability makes its carriers
  must-picks, so it is priced so the other answers stay attractive. The price is a gate, never
  the damage it deals (18 October): a condition, a setup, a self-sacrifice or its timing, so a
  stun is planned for rather than reacted with; the Paradox is the model.
- Rapid pieces stay small; a damage rider on an action the player takes anyway needs a limit.

## Tiers

- **Ryan's counts** (14 and 15 October): about ten chassis per city maker at the top end, split
  3-5-2 or 4-4-2 across tiers one, two and three; tier three late-game capstones, so few; the
  Arsenal in reverse, little access early and much late. Ryan, 15 October, in the Minerva
  session: Minerva's two tier threes are a treaded capstone and a capital ship, "the capital
  ship that it seems like every maker is going to end up getting".
- **The sort** (Claude's, partly agreed): tier one is itself with basics alone and stands in a
  start (a body or a hitter, not a support); tier three bends a rule the player has already
  learned; the rest is tier two, where the supports and the machines that are only good
  together belong. Ryan reads the Baboon as tier two and is unsure of the Dingo.
- **As dealt**: the tender offers one tier-one machine of each city maker by seed and the
  player takes three, so each maker's tier-one pool should vary and more than one maker's deal
  should hold a front. The host maker's offer after a win and procurement's shelf deal the
  higher tiers; the economy items the go raised are in `docs/economy_pass.md`.
- Each brief gives a proposed tier; none is decided. The reshuffle proposed so far: the Wild
  Boar, the Clydesdale, the boiler and the revolver to tier one; the Baboon and the fan-boat to
  tier two; the Dingo undecided. One rule to reword if it lands: the 12 October tier row gives
  every tier one a locked piece, and the Clydesdale would have none (the form-changing
  Armadillo keeps one, its lure, by Ryan's framework of 15 October).

The tiers as the briefs propose them (nothing decided; "down" and "up" against a chassis's
tier today; the targets two or three tier ones a city maker, two or three tier twos and one
tier three, the Arsenal none, three and three):

| Maker | Tier one | Tier two | Tier three |
|---|---|---|---|
| Minerva | Honey Badger, the Armadillo as a form changer, Wild Boar (down) | the echidna (the hedgehog) | the H-tank (the siege battery), the battlecruiser |
| Kestrel | Sparrowhawk, the strafer, the shield-spender | Goshawk, Puffin | the bomber (Ryan, 15 October) |
| Wainwright & Sutler | Prairie Dog, Clydesdale (down), the boiler, the revolver; the Dingo undecided | the Dingo if it moves, the funnel-web, the gunship, the fan-boat | the multi-rotor |
| Aphelion | Stingray, the line frame, the Zoids walker if it is Aphelion's (its brief proposes two) | Baboon (up), the jellyfish | the Carrier |
| The Arsenal | none | Nemesis, Misharu, the Onryō, the Zoids walker if it is the Arsenal's | Ammit, Mastema, Minos |

## Budgets (Ryan, 15 October)

Decided on the roster analysis's budgets; the bible's rows hold them.

- **Hard control**: adding it (a foe losing its action) is always carefully considered, and
  other options explored, before it is suggested or committed to. The analysis's caps (no
  hard-control piece below tier two, at most one locked on a die, one hard-control passive a
  maker) are struck as artificially limiting. The bible's stun row (section 5).
- **A new chassis earns its place** by a new read, a new product, a new price, or by changing
  what a kind of piece does; niches can and should overlap, so the test reads the mechanics
  (section 7).
- **A passive aims** to be fed by, and to feed, other makers' pieces, ideally two routes in and
  two payoffs: an aspiration, never a pass or fail (section 7).
- **A tier one shows its identity** with basics alone (section 10).

## Roster holes, as the go left them

Soft control: Minos, the jellyfish, the echidna's draw, the Armadillo's locked lure, filling.
Amplify for others: the Dingo's Shock, the Onryō's on-hit, the echidna's Sonic Needle, filling.
Area on a hardpoint: the stock pass's explosives, the strafer's volume, the bomber's clusters.
New prices: the cooldown, negative cooling. Reads nobody used: the foes' intents (the spider),
the slots (the bomber), the die's own state (the revolver, the Gundam, the battlecruiser), the
team's rerolls (no taker since Ryan refused them as the Armadillo's payout, 15 October).
The tender: Kestrel's deal varies with the strafer; Wainwright & Sutler's deal holds a front
with the boiler, the revolver or the Clydesdale at tier one; Aphelion's with the line frame.
Every maker fields every tier it may once the gaps land. The foes' debuff vocabulary grows from
four words by kinds, never by copies: Penance (a weaken), Grudge (a flat on-hit), Venom (a
share of current hull), the web (a timed stun), the mine (a trapped slot); and Barrier and Ward
on our side.

## The briefs

| Brief | Kind | Maker | Proposed tier | Waits on |
|---|---|---|---|---|
| `minerva_armadillo.md` | rework, in session | Minerva | 1 | nothing |
| `minerva_honey_badger.md` | rework, in session | Minerva | 1 | nothing |
| `minerva_hedgehog.md` | direction, in session (the echidna) | Minerva | 2 | nothing |
| `minerva_siege_battery.md` | direction, in session (Ryan's H-tank) | Minerva | 3 | nothing |
| `minerva_battlecruiser.md` | direction | Minerva | 3 | the Carrier's session (the foil); the cooldown property |
| `kestrel_strafer.md` | decided | Kestrel | 1 | nothing |
| `kestrel_shield_spender.md` | direction | Kestrel | 1 | nothing |
| `kestrel_bomber.md` | decided | Kestrel | 3 (Ryan, 15 October) | nothing (Ryan, 15 October) |
| `ws_boiler.md` | proposal | Wainwright & Sutler | 1 (proposed as 2) | the stock pass's heat prices |
| `ws_revolver.md` | proposal | Wainwright & Sutler | 1 (proposed as 2) | nothing |
| `ws_multirotor.md` | proposal | Wainwright & Sutler | 3 | the session on what shown text calls the die |
| `ws_funnel_web.md` | landed 18 October, retired (`git show bfa8cf2:docs/briefs/ws_funnel_web.md`) | Wainwright & Sutler | 2 | its engine and assets (the to-do) |
| `ws_gunship.md` | proposal | Wainwright & Sutler | 2 | the stock pass's tags |
| `ws_fan_boat.md` | proposal, back to the board | Wainwright & Sutler | 2 (proposed as 1) | the stock pass's keywords |
| `ws_prairie_dog.md` | rework | Wainwright & Sutler | 1 | nothing |
| `ws_dingo.md` | rework | Wainwright & Sutler | 1 or 2 | the stock pass |
| `aphelion_line_frame.md` | direction | Aphelion | 1 | nothing |
| `aphelion_jellyfish.md` | direction | Aphelion | 2 | the foes' fresh start (foes with several moves) |
| `aphelion_carrier.md` | proposal, open | Aphelion | 3 | the battlecruiser's session (the foil) |
| `aphelion_baboon.md` | rework | Aphelion | 2 (now 1) | the stock pass |
| `zoids_walker.md` | proposal, maker open | Aphelion or the Arsenal | 2 (1 if Aphelion's, in the reshuffle) | nothing |
| `arsenal_misharu.md` | proposal | the Arsenal | 2 | nothing |
| `arsenal_onryo.md` | direction | the Arsenal | 2 | nothing |
| `arsenal_mastema.md` | direction | the Arsenal | 3 | the foes' fresh start (riders on machines) |
| `arsenal_minos.md` | proposal | the Arsenal | 3 | the foes' fresh start (back ranks) |

Not briefed here: the large Aphelion hovercraft (parked by Ryan; below); the empty slots toward
each maker's ten (later maker sessions); cantrips (Ryan's idea of small Rapid pieces with no
cooldown, a component for the stock pass, noted in the line frame's brief); the Scapegoat Brand
(a rare after the vocabulary pass, half of it now Mastema's mover: in Mastema's brief); enemy
Shock on machines (none today; Claude's lean, if any: on a hero or an elite, telegraphed, never
the rank and file; the foes' fresh start); the economy items (`docs/economy_pass.md`); the
engine work (the to-do).

## Benches and parked ideas from the retired proposals

Ideas the makers' proposals set aside that belong to no single brief, one line each with what
set it aside, so Ryan can overrule the reason and not only the idea. A chassis's own bench is
in its brief; the full rounds are in git (above).

**Aphelion**

- The large hovercraft, parked by Ryan (12 October: "Me trying to fill out the hovercraft
  roster, but we can park it for now"): proposed at tier two, heavy, hover. Its holes:
  Aphelion's "high-tech suites over light hulls" against a hover tank, and the Stingray already
  hovering; it would need a map verb the Carrier does not take (the deck suits a barge).
- The long guns, parked by Ryan (12 October: "I do like the long-guns ship idea, but
  considering that it's possible engagement range could change, it would be tough to balance
  it now"): a machine joining fights three hexes away; attack range is already a number on
  each unit (`Unit.attack_range`, 2 today).
- The time-shifter (Ryan, 17 October, from the funnel-web's session: "There might be an
  Aphelion machine that wants to control the battlefield by delaying and redirecting blows,
  some kind of spacetime manipulator. Soft control, moving or delaying hits as a whole
  identity."): delay (a foe's next move gathers a round, the countdown as built, so the blow
  lands late and dies with the foe) and redirect (the blows meant for a machine re-pick by the
  foes' aim, held rather than lost when no one else stands, the phase its action for the
  round). Holes for its brief: delay alone is tempo and the fight's last blow, so it pairs with
  burst; a redirect onto a chosen ally is an interpose by proxy, which the redirection row
  allows on a locked piece only; our countdown chip on their foe must read as ours; it parts
  from the jellyfish by pattern (the jellyfish changes the move and dispels; this moves the blow
  in time and target).
- The burrow, grown on the spider and moved here (Claude, 17 October; Ryan: "hilarious", and
  "is this actually a broken ability, shuffling all intents away?"): equipment on itself,
  every foe aiming at it re-picks. Broken on the spider (with Rapid it deletes the ambush
  limit, a locked piece feeding only its own passive; alone, blows lost would be a free stun)
  and a reverse Lure without the choice for the ally; sound as the time-shifter's shift with the
  two fixes above.

**The Arsenal** (Claude's, 11 and 12 October)

- Haunted: a striker spends its next blow on the foe beside it; a novel verb (foes turning on
  each other) that does nothing against a lone boss.
- The guardian's stay: a blow that would wreck an ally leaves it at 10 hull; rare, binary, and
  close to the Honey Badger's open identity.
- The bell tower (medieval): an assault walker with a bell caged on its back, its toll a big
  indirect blow with Spread, Penetrate and Shock; set aside for the four on 11 October, no
  other reason recorded.
- Hubris: strongest whole, weaker as it is hurt; hard to keep from binary.
- The fate-edited die (eldritch): its blanks reroll free; a stripped die degenerates to one
  entry.
- A veil (eldritch): out of the world for a round, waiting on Phased's design line.
- The Misericorde: the first Onryō's mercy dagger (Direct, flat 10, heat 5, Rapid), free for
  another Arsenal machine.
- The four as a set: one for each of Ryan's words (medieval, demonic, eldritch, sinister) and
  four reads (a shield breaking, a blow reaching hull, a burning death, its own reach); with the
  Nemesis and the Ammit, three at each of tiers two and three. Pairs to watch: the Votive
  Screen feeds Misharu (each Screen spent is a fresh shield that may break); Minos lines burning
  foes up for the Bellows. A team row once the four exist: Misharu baits, Mastema burns, Minos
  arranges, the Onryō punishes.
- Retired with the shield rule: the proposal's "only a breach sets off Misharu and the Onryō
  with one blow"; a breach now breaks no shield, and any blow above the shield breaks it and
  wounds.

**Wainwright & Sutler** (11 to 13 October; the reasons Claude's unless marked, Ryan's to
overrule)

- Fighting without having moved gives Spread: set aside, since a map action that buys a fight
  buff is free.
- Crags as slow ground: set aside, since a map rule alone is weak.
- A kill makes a spend Rapid: set aside as an Arsenal machine's shape (the Zoids walker's brief
  carries it).
- Every weapon Indirect: set aside as free reach once danger close goes (decided 11 October,
  not built).
- Indirect weapons strike twice: set aside as dangerous as written.
- Shield as a spider's ammunition: set aside while Misharu turned shield into damage; Misharu's
  payoff is now Penance (Ryan, 14 October), so the idea is free again.
- Debuffs as the gunship's sights and the fan-boat's drift: set aside (Ryan, 12 October:
  statuses are Aphelion's strength, and a gunship is about its weapons; 13 October: statuses are
  never Aphelion's alone).
- Two tests from those rounds (Claude's, 13 October): a passive that is pure upside with no
  interest fails (the fan-boat's Ballistic splash); so does a payoff not worth its setup (the
  gunship's missile-marked reach).

## A suggested order

1. Nothing to wait on: the Minerva session (the Armadillo, the Honey Badger, the echidna, the
   H-tank; in session since 15 October); then any of the strafer, the shield-spender, the bomber,
   the line frame, Misharu, the Onryō, the revolver, the Prairie Dog and the Zoids walker (its
   maker first); the funnel-web landed on 18 October.
2. In pairs: the battlecruiser and the Carrier together (Ryan's foil); the Baboon and the Dingo
   with the stock pass.
3. After the stock pass: the boiler, the gunship, the fan-boat; the multi-rotor once the die
   has its shown word.
4. After the foes' fresh start: the jellyfish, Mastema, Minos.
