# Brief: the funnel-web (settled in chat, the go pending)

The session settles the four-legged spider as the roster's tank-buster: an opportunist that
waits on the sidelines, binds its foes and bites with acid.

**Status**: design settled in chat (Ryan, 17 October: "Vitriol is fine, no fangs, everything
else seems good"), the go pending; one item open, the web's cooldown. **Maker**: Wainwright &
Sutler. **Proposed tier**: two. **Read first**: `docs/briefs/README.md`; the bible's stun,
Numbed and Barrier rows (section 5), its chances row (section 2), its build-space row (section
7) and its cooldown row (section 8); `sim/skirmish.gd` (`acting_on`).

## Where it stands (17 October)

Every number is a placeholder; the names below are working names except Vitriol (Ryan's).

- **Passive**: "Its blows on a foe showing no intent on it lay Vitriol." Per hit: each strike
  that lands on such a foe adds a stack, so a multi-strike piece bites several times and a
  single-hit gun once.
- **Vitriol** (a new status on a foe; the vocabulary's planned `corrode` keyword renamed and
  re-stepped): at its action it loses 5% of its current hull a stack, past armour, after
  Burning; a stack fades at each of its actions (stacking `add`, Burning's pattern). Rounded
  down, so it never finishes a foe and never sets off a last act. The keyword and the chip
  share the word.
- **The web** (locked): "Webs a foe. After its action the web bursts: it and the next foe to
  act beside it are Suppressed." Direct, no damage, heat 0. Its cooldown is the open item. A
  foe the team has already suppressed this round gains nothing from the burst on itself
  (Suppressed never stacks and never carries, Ryan, 17 October), so the team's stun and the
  web go on different foes.
- **No fangs** (Ryan, 17 October).
- **Chassis**: medium walker, move 30; hull 110, shield 40, armour 5, heat 60, cooling 5,
  field recharge 20 (in band: the Baboon 100/40/0, the Ammit 120/40/5). Four hardpoints, a d5.
  Stock stand-ins until the stock pass: Maxigun, Howitzer, Twin Autoguns, Laminar Deflector; the
  Suppression Battery comes off the old stock, the web being the control.
- **Waits on**: the elites in fights. As content stands nothing over 50 hull stands outside the
  boss fight and the finals, so Vitriol matters in one fight a battle until the Treant and the
  Sandworm come as packs of one (the to-do's elites line).
- **The HUD** (Ryan, 17 October: "a venom glyph or sinister eyes or something pulsing over
  eligible foes actually helps sell the fantasy, in addition to helping the player. Could go
  all in and dim the screen slightly in a predator-sense kind of way."): on the spider's die
  held or dragged the field dims and the foes the held entry can reach and that show no intent
  on it get pulsing eyes; motion and a glyph, never a hue; started hotter than seems right; a
  `RIFTGATE_PREY_DEBUG=1` switch fires it constantly for judging. A web's timer on the foe's
  chip is already on the to-do.

## Ryan's calls

- 13 October: the fangs, "Direct, flat 10, and 20% of a Suppressed target's current hull more"
  (retired 17 October, below); the web bomb's plan and its working name; the funnel-web name,
  clear in the reserved names.
- 14 October: "I'd be willing to change the funnel spider to not suppress - my thought
  originally was to force a choice between ignoring a suppressed target (usually the correct
  move) and chunking it. But it's got too many themes going on - some kind of Web, some kind of
  Bite, and we had settled on Suppress being the link between the two. It could be correct, it
  could not be."
- 14 October, on Claude's Lure alternative: "I don't like lure as thematically this is a unit
  that sits on the sidelines, waiting to strike. Its opportunistic. We have many scaling
  threats, but no dedicated tank-buster, which was my inspiration - little spider takes down
  big thing with venom. The obvious thing I would do is something like 'deals 5% current HP
  damage for each debuff on the target' but that reads as Aphelion's niche. Could also give it
  its own debuff with a similar effect. It current form isn't bad, though, thematically it
  binds its foes and waits to strike, I just want to make sure there isn't a more interesting
  niche we can push."
- 14 October: "if we gave the spider a locked component that still does the web bomb, a delayed
  suppress, it would be able to feed its own ability by removing targeting through stun. Is
  that too strong? It could have a cooldown." And: "How many targets for the web bomb do you
  think is a fair starting point, if we attach a cooldown? One adjacent? Cleave? Splash?"
- 14 October, on the HUD: "If a target is suppressed, good UX would probably dictate that it's
  intent line disappears, wouldn't it?" (built 15 October).
- 17 October, on venom's count: "Venom - on every hit? Or every spend? Rapid is the only way
  to make it stack right now."
- 17 October, on the fangs: "Thought experiment-put the fangs in, but make it an execute in
  the same vein as the Sparrowhawk? Does that cheapen the design? Make it too well rounded?"
  Then: "no fangs".
- 17 October, on the payoff: "I think the payoff is primarily in the team setting up the venom,
  and if the venom happens to help feed another ability like paradox, then great. If the venom
  alone isn't worth the team helping it, then it probably needs a buff." And: "It's very
  possible that paradox needs more than 3 to fire, since I don't want to limit creating effects
  around the existence of paradox. Let's keep that in mind."
- 17 October, on the burrow (Claude's alternative, below): "I personally think the burrow is
  hilarious. Thought experiment - is this actually a broken ability, shuffling all intents
  away? Does it have a home on another unit, say, a phase-shifter?" And of the gather-a-round
  web: "Your gather a round idea sounds more like a time-shifter support fantasy. There might be
  an Aphelion machine that wants to control the battlefield by delaying and redirecting blows,
  some kind of spacetime manipulator." Both parked as the time-shifter (the README's bench).
- 17 October, on the word: "I would like a more interesting name than just "venom," yes. It's a
  mechanical spider after all, or technically a quaduped steampunk mech that kind of does
  spider-like things. I'm not sure about the lore yet." Then: "Something acidic or corrosive
  works for the venom, I don't want to actually use Corroded as that's probably the likely
  enemy dot to attack the machines with." Then: "Vitriol is fine".
- 17 October, on the stun: "I think the spider keeps the suppress, it fits the kit."
- 17 October, on the web's cooldown: "I don't think that cooldown is even a penalty for
  suppress since numbed is technically a global cooldown. The more other mitigation tools we
  add, the more I think that we need to make sure suppressed is priced accordingly to make the
  other options attractive. Scarcity might make the scarce options (like the spider) a
  must-pick." The roster-wide half of this is in the bible's stun row.
- 17 October: "Not concerned about guarded since that's still just theory, no hard mechanics
  yet."
- 18 October, on what prices a stun: "I'm not sure that dealing no damage is a drawback to
  preventing an entire boss' turn. The point is that one guy stuns, the other 3 are free to
  fire their best weapons without fear. Any damage the stun deals is incidental." And:
  "Suppress gated by condition, setup, self-sacrifice, or timing, and then it's the player's
  decision to build their team in a way that makes it worthwhile. It doesn't have to be
  complex, either. Paradox is a great example". The web's gate is its timing (the foe acts
  once before the burst).

## Claude's proposal, as reissued and corrected (17 October)

- **The ambush read** is the engine's `acting_on` list as the HUD draws it: a foe counts as
  aimed at the spider when its arrow is on it, a gathering countdown included; it shows no
  intent on it when aimed at another machine, Suppressed, or on an untargeted special (a
  Regrow, a Rally, a Scorch-all). A blow at every machine is aimed at everyone. Read at the
  spend, before the spend's own riders, so a Suppress gun never feeds itself; each foe reached
  is judged alone, so Spread and Penetrate bite the ones that qualify. The exposed aim is the
  default for 13 of 26 foes, the front-rank bruisers; the rest aim by anything, focus, armed or
  heat, so the windows have texture, and exposed is itself weighted random.
- **How tight it is**: with three machines against a lone boss the boss looks away from the
  spider about two rounds in three before any play, more with its shield up (its weight in the
  exposed aim falls); alone, never. A soft limit on a boss, a hard one in swarms and alone; the
  hard limit on the damage is the share of current hull, which shrinks and never finishes.
- **Per hit, 5% a stack**: per spend, stacks never happened without Rapid, so the stacking
  machinery was dead weight (Ryan's point). Per hit follows the engine's convention (Burn is
  per blow, Suppress lands per strike) and gives multi-strike pieces a home. A Maxigun bite in a
  window on a 160-hull boss is three stacks, about 36 over its next three actions on top of the
  gun's 22; a single-hit gun's bite is one stack, about 6. So strikes are bites on the spider,
  the Maxigun (Wainwright & Sutler's) its first chase piece, and the stock choice means
  something. A tenth a stack per hit was too strong (about 90 off the boss from one Maxigun
  bite). Shape B, one grant that renews for two of the foe's actions, is engine-native too but
  its duration would be a hidden count (no chip shows rounds left), so A.
- **The payoff**, in Ryan's frame: the team's windows are the setup and Vitriol is the payoff;
  the Paradox is a bonus and never a reason. The measure: a window's Vitriol should beat the
  spend that made it (a Klaxon's Lure is a whole spend doing no damage). One stack does not (6
  against a gun's 17); a Maxigun bite does (36). So the setup is a two-die read: lure when the
  spider shows the Maxigun. The runner reads it once the bot values an ambush (the to-do).
- **Routes in**, two of them mid-turn ordering decisions: an ally's Lure (the Proximity Klaxon
  turns a row onto its machine at the spend, so Lure first, bite second), an ally's Suppress
  clearing a foe's intent before the spider spends, a bare-hulled tank drawing the exposed aim,
  and the spider's own shield for the round after. Payoffs beyond the damage are thin (the
  Paradox and the Susceptibility Tensor read it), which Ryan's frame accepts.
- **The web, weighed as hard control** (the stun row): the shapes weighed and why each falls
  short are on the bench below. Why Ryan's web survives: delayed (one action lands first), no
  damage, Numbed's equilibrium on a boss, and Suppressed never stacking and never carrying
  (Ryan, 17 October: "That way lies madness"), so the web and the team's stuns can't be laid
  on one foe for a longer hold, a second suppress on a suppressed foe being wasted. Its two
  uses differ, and that is the decision: web the foe left of the threat and the
  threat skips now (safety); web the boss and its blow lands now, it is held next round, and
  next round it shows no intent, a window. Direct to start; Indirect is a later lever. It also
  holds a boss's countdown a round.
- **A round**: the intents are drawn; holding the die marks the foes looking away. A window on
  the boss: a gun on it, damage plus Vitriol. No window: the web, or the Deflector on itself
  (lowering its exposed weight for the round after and, being Rapid, still leaving a gun to
  fire), or a gun on a small foe looking away for the gun's own damage. Alone it is a plain d5
  with a web, and it loses, which is tier two's shape.
- **How often the web shows**: one roll in five when up; with a reroll spent on it about every
  three rounds without a cooldown, about every five with cooldown 2.

## Open

1. **The web's cooldown.** Ryan, 17 October: a cooldown is no penalty for a Suppress, Numbed
   being in effect a cooldown. Claude's reading: Numbed is per foe, but on one foe it behaves
   as one (each landed suppress adds three stacks to a massive foe, two to a small one, one
   fades a turn, so the landed rate settles at about one stun in three rounds however often it
   is tried, cooldown 2's rate), so on a boss the cooldown adds nothing; in a formation with
   fresh targets Numbed never engages and the cooldown is the only brake besides the die's
   odds. Under Ryan's 18 October frame (a stun priced by a gate, not by what it deals) the
   web's gate is its timing, so Claude reads the cooldown as off, the runner watching the
   spider's web share in formation fights and the Baboon pairing, cooldown 2 the lever if it
   dominates. Ryan to confirm.

Not this brief's: the price of hard control across the stocks (Ryan, 17 and 18 October: priced
so the other mitigation stays attractive, never rationed, the price a gate: a condition, a
setup, a self-sacrifice or its timing) is the stun row's and the stock pass's.

## Holes

- **It waits on the elites** (above). The alternative, a floor on Vitriol's tick, is a second
  number and makes it Burning on small foes.
- **The stunlock with the Baboon**: the web's chip, its burst and a bite are three debuffs on
  one foe in a round, a Paradox trip; since Suppressed never carries (Ryan, 17 October) a trip
  on the webbed foe is wasted, so one web and the Baboon hold a boss for one action, not two,
  and the stunlock is the web every few rounds with the Baboon's trips on the foes beside it.
  Softer still if the Paradox's threshold rises (Ryan: it may). The boss cells must read it;
  the web's cooldown is the lever.
- The condition sits behind a hold (the chip row shows action and number, not target): the
  predator sense answers it.
- Its own shield buys windows through the exposed weighting, which the player sees as arrows,
  not as the weight.
- Lure on the spider turns foes onto it and closes its windows: a reason not to fit it.
- A Burning tick does not pass through Guarded today (`tick_preview` sums, no damage-taken
  multiplier), and Vitriol would inherit whatever the parts' answer is. Ryan is not concerned
  while the parts are theory.
- The bot values neither an ambush nor a delayed stun until its valuations land (the to-do).

## Bench

Shapes weighed and set aside, one line each with the reason, Ryan's to overrule.

- **A web that weakens** (lays Penance): soft, and a route into Misharu's word; but a weakened
  foe still strikes the spider, so it opens no window and the two halves never meet.
- **A tripwire** that bites the foe when it strikes: a reward that scales with the enemy's
  blows (the retaliation row), and no window.
- **The burrow** (Claude, 17 October): equipment on itself, every foe aiming at it re-picks.
  Broken here: with Rapid it deletes the ambush limit and is a locked piece feeding only its
  own passive; alone, blows lost would be a free stun; for the ally it is a reverse Lure
  without the choice. Moved to the time-shifter with its fixes (the README's bench).
- **The gather-a-round web** (Claude, 17 October): the web gives the foe's next move a
  countdown of one, a delay rather than a stun; a gathering foe still shows its intent, so it
  opens no window, and the neighbour trick is lost. Moved to the time-shifter.
- **No locked control**: windows from the team only; the spider has no say over its own.
- **The fangs as a finisher** (Ryan's thought experiment, 17 October; the Pinion Driver's
  missing-hull form, the bible having retired only the binary Execute): Vitriol opens on current
  hull and the fangs would close on missing hull, a tidy mirror; set aside because it closes the
  role on itself (the spider opens and finishes a boss), costs a hardpoint or stretches the die
  to a d6, and is the Pinion Driver's pattern (a locked gun, missing hull, a finisher). Ryan:
  "no fangs". What would reopen it: play showing Vitriol has no click.
- **A plain locked bite with no rule**: teeth on the die at the price of a hardpoint; set aside
  with the fangs, the passive making every gun a bite.
- **Shape B** (Vitriol as one renewing grant of two actions): a hidden duration. A banked pool of
  "actions left" conflicted with Ryan's 16 October call that timed stacks never extend.
- **A cooldown as the stun's price** (Claude, 14 to 17 October): set aside by Ryan's argument
  that Numbed is the cooldown; the web's own cooldown stays open above.
- **No damage as the stun's price** (Claude, 17 October): set aside by Ryan's argument that a
  stun's damage is incidental to a turn without threat; like the cooldown it priced the stun
  where it is weakest (fodder), not where it is strongest (a boss).
- **The fangs of 13 October** (flat 10 and 20% of a Suppressed foe's current hull): their share
  moved into Vitriol, their condition (a Suppressed foe shows no intent) into the ambush read.
- **Earlier**: the stun punish (a blow on a Suppressed foe striking every other Suppressed foe)
  and the Spinneret it served, two stuns and Rapid on one locked piece (Ryan, 13 October:
  broken); Lure as the spider's own verb (Ryan, 14 October: not the sideliner's theme); venom as
  a separate machine (13 October), brought back as this one's direction in the go.

## The proposal as it stood (13 October)

"A foe it would Suppress takes a web bomb instead: at the end of that foe's turn it bursts,
Suppressing the foe and the next foe beside it" (Ryan's wording and plan). The webbed foe
still acts this round; the burst holds it next round and catches the foe beside it that acts
next, which loses its action now, so the trick is to web the foe standing just left of the
threat; with no foe to its right the burst catches the one to its left. The next-to-act
neighbour over a random one (noise in the enemy's turn) or a picked one (a gesture); both
neighbours was Ryan's lever if it proved weak. Edge cases, carried to the locked web: Numbed is
checked at the burst, each foe for itself; a webbed foe killed before its turn takes its web
with it; a webbed foe already Suppressed by the team skips, and its web still bursts at its
turn's end for the neighbour while the suppress on itself is wasted (Suppressed never stacks
and never carries, Ryan, 17 October), so the team's stun and the web go on different foes. Its
webs then came from Suppress pieces of any maker on its
hardpoints; the go reworked that into the ambush and the locked web (14 October), and 17
October settled the rest above.

## What the session hands back

On Ryan's go: the bible's row for the chassis (the ambush read, Vitriol as a kind, the web
under the stun row, no fangs, the elites dependency); Vitriol into `content/vocabulary.json`
in the planned `corrode` entry's place and `docs/rules.md`'s foe statuses; the chassis, its
passive and the web in content with `"status": "planned"` (a share-of-current-hull tick, a
"shows no intent on this machine" condition and a bursting web are engine work; the cooldown
property is on the to-do); the forecast's predator sense and the web's timer on the to-do; the
bot's valuation already there; the to-do's line ticked; this brief retired.
