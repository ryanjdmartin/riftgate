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
- Sessions run in parallel on this repository: diff a shared file before staging it, and read
  the bible's live page before republishing it (the status says how).

## Decided on 14 and 15 October

Rows in the bible and lines in `docs/rules.md`; none of it built yet.

- **The shield rule.** A shield absorbs its number and the excess passes to the hull; a breach
  ignores the shield outright (the shield stands); an injury counts what reaches the hull.
  Under the old whole-block rule a tiny shield was secretly "negate one blow", and every new
  shield design was heading for that margin.
- **Barrier and Ward**, two buffs. A Barrier: the next blow a foe lands on the machine deals no
  damage (so it never injures), its riders landing, until the round's end; never granted to
  every ally at once. A Ward: every blow a foe lands on the machine that round leaves no rider,
  breach included, while the damage lands (Ryan: it lasts the round because it is more
  situational). Both up is the old whole block at twice its price. Ward is the buff's word, so
  the Oblation Ward becomes the Oblation Mantle and the Votive Ward the Votive Screen.
- **Cooldowns**: a printed property on specific pieces, shown on the entry as dark with the
  rounds left. Ryan: nearly every Rapid component reads "Rapid, cooldown 1", and the Nemesis's
  fists are simply Rapid. Claude's limits, recommended: never on a basic, at most one cooldown
  entry on a die below tier three, and a dark entry with structure of its own beside Rapid's
  switch-off and a foe's Disabled.
- **The Dingo's Megataser Harpoon** carries Shock in place of Suppress.
- **Misharu's payoff is Penance**, a weaken, in place of Suppress.
- **Kestrel's gaps**: the strafer at tier one and the bomber above it.
- Agreed in chat, for the HUD: a suppressed foe's intent line clears (Ryan's point, 14
  October).

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
  mechanics should not repeat.
- The foes' debuff vocabulary is thin at four words (Burning, Suppressed, Shocked, Paradox;
  Numbed is a resistance), which is why designs keep reaching for Burn or Suppress. New chips
  are fine, even unique to a chassis, since tooltips and popups carry them. The vocabulary
  grows by kinds (a weaken, a flat on-hit, a share of current hull, a timed stun, a trapped
  slot), never by copies.
- Stun is budgeted; prefer changing the enemy's problem over removing its turn.
- Rapid pieces stay small; a damage rider on an action the player takes anyway needs a limit.

## Tiers

- **Ryan's counts** (14 and 15 October): about ten chassis per city maker at the top end, split
  3-5-2 or 4-4-2 across tiers one, two and three; tier three late-game capstones, so few; the
  Arsenal in reverse, little access early and much late.
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
  every tier one a locked piece, and the Clydesdale and the form-changing Armadillo would have
  none.

The tiers as the briefs propose them (nothing decided; "down" and "up" against a chassis's
tier today; the targets two or three tier ones a city maker, two or three tier twos and one
tier three, the Arsenal none, three and three):

| Maker | Tier one | Tier two | Tier three |
|---|---|---|---|
| Minerva | Honey Badger, the Armadillo as a form changer, Wild Boar (down) | the hedgehog | the siege battery |
| Kestrel | Sparrowhawk, the strafer, the shield-spender | Goshawk, Puffin | the bomber (or two, by its engine piece) |
| Wainwright & Sutler | Prairie Dog, Clydesdale (down), the boiler, the revolver; the Dingo undecided | the Dingo if it moves, the funnel-web, the gunship, the fan-boat | the multi-rotor |
| Aphelion | Stingray, the line frame, the Zoids walker if it is Aphelion's (its brief proposes two) | Baboon (up), the jellyfish | the Carrier |
| The Arsenal | none | Nemesis, Misharu, the Onryō, the Zoids walker if it is the Arsenal's | Ammit, Mastema, Minos |

## Budgets (Claude's working rules, not confirmed)

The working rules every brief is read against, and their one home; the bible's section 12
asks Ryan to confirm or move them. From the roster analysis's section 6: no hard-control piece below tier two, at most one locked
on a die, at most one hard-control passive a maker (the Paradox is Aphelion's); a new chassis
earns its place by a new read, a new product, a new price, or by changing what a kind of piece
does; every passive has two routes in and two payoffs from other makers' pieces; a tier one
shows its identity with basics alone.

## Roster holes, as the go left them

Soft control: Minos, the jellyfish, the hedgehog's lure, the Armadillo's lure-shields, filling.
Amplify for others: the Dingo's Shock, the Onryō's on-hit, filling. Area on a hardpoint: the
stock pass's explosives, the strafer's volume, the bomber's clusters. New prices: the cooldown,
negative cooling. Reads nobody used: the foes' intents (the spider), the slots (the bomber),
the die's own state (the revolver, the Gundam), the team's rerolls (the Armadillo's cash-in).
The tender: Kestrel's deal varies with the strafer; Wainwright & Sutler's deal holds a front
with the boiler, the revolver or the Clydesdale at tier one; Aphelion's with the line frame.
Every maker fields every tier it may once the gaps land. The foes' debuff vocabulary grows from
four words by kinds, never by copies: Penance (a weaken), Grudge (a flat on-hit), Venom (a
share of current hull), the web (a timed stun), the mine (a trapped slot); and Barrier and Ward
on our side.

## The briefs

| Brief | Kind | Maker | Proposed tier | Waits on |
|---|---|---|---|---|
| `minerva_armadillo.md` | rework | Minerva | 1 | nothing |
| `minerva_honey_badger.md` | rework | Minerva | 1 | nothing |
| `minerva_hedgehog.md` | direction | Minerva | 2 | the Armadillo's session |
| `minerva_siege_battery.md` | direction | Minerva | 3 | the Carrier's session (the foil) |
| `kestrel_strafer.md` | decided | Kestrel | 1 | nothing |
| `kestrel_shield_spender.md` | direction | Kestrel | 1 | nothing |
| `kestrel_bomber.md` | decided | Kestrel | 2 or 3 | the foes' fresh start (reinforcements) |
| `ws_boiler.md` | proposal | Wainwright & Sutler | 1 (proposed as 2) | the stock pass's heat prices |
| `ws_revolver.md` | proposal | Wainwright & Sutler | 1 (proposed as 2) | nothing |
| `ws_multirotor.md` | proposal | Wainwright & Sutler | 3 | the session on what shown text calls the die |
| `ws_funnel_web.md` | direction | Wainwright & Sutler | 2 | nothing |
| `ws_gunship.md` | proposal | Wainwright & Sutler | 2 | the stock pass's tags |
| `ws_fan_boat.md` | proposal, back to the board | Wainwright & Sutler | 2 (proposed as 1) | the stock pass's keywords |
| `ws_prairie_dog.md` | rework | Wainwright & Sutler | 1 | nothing |
| `ws_dingo.md` | rework | Wainwright & Sutler | 1 or 2 | the stock pass |
| `aphelion_line_frame.md` | direction | Aphelion | 1 | nothing |
| `aphelion_jellyfish.md` | direction | Aphelion | 2 | the foes' fresh start (foes with several moves) |
| `aphelion_carrier.md` | proposal, open | Aphelion | 3 | the siege battery's session (the foil) |
| `aphelion_baboon.md` | rework | Aphelion | 2 (now 1) | the stock pass |
| `zoids_walker.md` | proposal, maker open | Aphelion or the Arsenal | 2 (1 if Aphelion's, in the reshuffle) | nothing |
| `arsenal_misharu.md` | proposal | the Arsenal | 2 | nothing |
| `arsenal_onryo.md` | direction | the Arsenal | 2 | nothing |
| `arsenal_mastema.md` | direction | the Arsenal | 3 | the foes' fresh start (riders on machines) |
| `arsenal_minos.md` | proposal | the Arsenal | 3 | the foes' fresh start (back ranks) |

Not briefed here: the large Aphelion hovercraft (parked by Ryan); the empty slots toward each
maker's ten (later maker sessions); cantrips (Ryan's idea of small Rapid pieces with no
cooldown, a component for the stock pass, noted in the line frame's brief); the Scapegoat
Brand (a rare after the vocabulary pass, half of it now Mastema's mover: in Mastema's brief);
enemy Shock on machines (none today; Claude's lean, if any: on a hero or an elite,
telegraphed, never the rank and file; the foes' fresh start); the economy items
(`docs/economy_pass.md`); the engine work (the to-do).

## A suggested order

1. Nothing to wait on: the Armadillo first, since it hands the Faraday Hull to the hedgehog;
   then any of the Honey Badger, the strafer, the shield-spender, the line frame, Misharu, the
   Onryō, the funnel-web, the revolver, the Prairie Dog and the Zoids walker (its maker first).
2. In pairs: the hedgehog after the Armadillo; the siege battery and the Carrier together
   (Ryan's battlecruiser foil); the Baboon and the Dingo with the stock pass.
3. After the stock pass: the boiler, the gunship, the fan-boat; the multi-rotor once the die
   has its shown word.
4. After the foes' fresh start: the bomber, the jellyfish, Mastema, Minos.
