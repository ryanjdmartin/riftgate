# Design session briefs

<!-- hangar: {"kind": "shared", "maker": null, "tier": null, "status": "hub", "slot": false, "name": "the briefs README"} -->

One brief for each chassis, component, module or rule in design. A brief is the starting point
of its design session: where the design stands, what Ryan said and when, what Claude proposed,
what is open, the holes already raised and what the session hands back. It is the design's one
home until its decisions are bible rows and content, then it retires to git (the list at the
end). Ryan, 15 October: mechanics nobody has discussed must not muddy a handoff, so a brief
holds only what was proposed and discussed in the records and the chat, and anything new is
proposed in chat first. The long form of this file is `git show cc446826:docs/briefs/README.md`.

## How a session runs

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row (`docs/design-bible.html`), the
  Start here of `docs/status.md`, this file, then the brief and the files it names. If a chat
  and a file disagree, the chat is newer.
- Read `refit_pass.md` and its section 22 before any brief: the reboot, the rule of the shield
  and of heat. Nothing regenerates or cools by itself; a machine that has spent nothing may
  give its turn to a reboot, bare that turn, cold and whole the next; heat past the maximum
  stays and burns hull every turn; a shield at nothing is broken and gains none until the
  reboot. Ryan: "This is fundamental, I don't want it to get skipped by other sessions." No
  shield or vent entry is dealt on a die, and no blow destroys a component by its size. A
  brief's lines on a shield entry, a vent, regen, cooling, an injury or an overheat predate
  these and are read under them: section 22's table reads each unbuilt design here against
  the rule, and `docs/reboot_machines_proposal.md` the built machines. His expectation, no
  strict rule: what grants regen, cooling, flat shield or flat heat reduction is a kit's, a
  locked piece's or gated behind a synergy, and a shield spend may not be standard fare
  ("it's so expensive").
- The briefs predate the vocabulary pass of 15 and 16 November and are not rewritten. Read
  Burn as Ablate (a point a stack off the shield and then the hull on a machine, never heat);
  Flak and Crushed as Brittle; Breach as "ignores armour", written on a piece of a higher
  tier or behind a gate; Disable as Jam; Pinned Flak and Pinned Burning as Pinned and Seared;
  souls as Essence; the injury rule as a boss's Destroy rider. Splash, Silence, Overshield,
  Retaliate, Rallied and Sweep are cut, and Swap, Web and Spillover are each a rule on its one
  piece. Regenerating is a point a stack, a stack fading each turn; Primed lends Ablate 1;
  Phased is out of reach of both sides for a round and still acting, our granters each behind
  a gate. `docs/vocabulary.md` is the vocabulary as it runs; what became of each word is
  `git show 07f01fb:docs/vocabulary_pass_proposal.md`, sections 18 and 20. A design that
  leans on a word that moved says so as its session opens.
- Fold in Ryan's corrections first. On the hangar's Designs tab he corrects a paragraph,
  strikes one, notes a heading, sets a session's direction or leaves an idea with no brief
  yet; they wait in the page's `designs` collection. Before reading the brief, save it with
  ArtifactData's `list` (`collection` `designs`, `out_dir` `build/hangar/inbox`) and run
  `python3 tools/hangar_designs.py --fold build/hangar/inbox` (`--dry` to look first). A
  correction replaces its block, closed with "(Ryan's correction, <day>.)"; a strike removes
  its block; a note goes under its heading and a direction under the header, each opening on
  his name and the day. Read the diff, fold by hand what it could not place and close the
  numbers of a list it struck from; commit, run `python3 tools/hangar_data.py`, republish the
  hangar as the status's Pages says, then clear the folded documents with the batch the fold
  printed. An idea becomes a brief or a bench line and is marked briefed or dropped. A
  correction is his call at the strength he wrote it: a hole in one is raised in chat.
- One brief a design: every chassis, component, module or rule in design has a file of its
  own here, `<maker>_<label>.md`. Its hangar header stands on a line of its own within the
  five lines after the title, an HTML comment holding one JSON object:
  `<!-- hangar: {"kind": "chassis", "maker": "kestrel", "tier": 2, "status": "direction", "slot": false, "name": "Buzzard", "built": "buzzard"} -->`.
  `kind` is chassis, component, module, rule, hub or shared. `maker` is a maker's id in
  `content/chassis.json` (minerva, kestrel, wainwright_sutler, aphelion, arsenal) or null.
  `tier` is 1, 2 or 3, or null while open. `status` is a short word (idea, shape, direction,
  proposal, parked, rework, session, hub, cut). `slot` is true when the design fills one of
  its maker's ten: only a chassis may, and it needs its maker; it is false for a piece, a
  rework of a built machine, a rule or a hub. `name` is its working name. `built` is the
  content id, on a rework. The Designs tab reads no brief without a sound header:
  `python3 tools/hangar_designs.py --check` checks them all and writes nothing.
- Propose in chat first. A suggestion of Ryan's opens a discussion: look for holes and raise
  them before building, and if he reaffirms after hearing them, build it as he said. His calls
  carry his name and the date; everything else is Claude's proposal for him to move.
- Names, numbers and looks are Ryan's. He matches mechanics to silhouettes he has in hand, so
  propose a name or a look only when he asks. Every number is a placeholder: magnitudes come
  from the bible's scales row (section 11) and `numbers_pass.md`, section 2, and a round from
  before 22 October quotes an older scale, a shape at most. The sizing numbers have one owner
  (the status's Start here): a design session moves no balance number.
- On Ryan's go: the bible's rows (each decision with its reason and the condition that
  reopens it), `docs/rules.md` where a rule changes, content with `"status": "planned"` where
  the engine cannot run it yet, the to-do ticked, the status updated. Nothing is built before
  the go.
- Landing a chassis also takes: its locked pieces in `content/components.json`; a new keyword
  in `content/vocabulary.json` before its code; engine pieces tested with synthetic passives;
  a lowforge model with its rig, acts and gait, judged running; the chassis count in
  `docs/rules.md`; the hangar's files (`tools/hangar_data.py`); a balance-runner row, read
  alone as a diagnostic.

## Ryan's taste, as the go established it

- Elegant over complicated: one passive, one idea ("this is taking off into complicated
  territory"). Complexity belongs to the higher tiers.
- Never an unkillable team by another name: no team-wide armour or shield handed out in bulk
  ("giving the team tank stats is just as toxic as taking all the blows").
- No reward for being struck that scales with the enemy's blows; a thorns tank needs a
  drawback on the thorns. What reopens it (20 October): a machine that spends its own turn to
  be struck, deals nothing that turn and is paid later and at random is not a tank doing its
  job.
- Niches can and should overlap across a larger roster; mechanics should not repeat, and a
  mechanic is its pattern in its context, never one trait it shares ("if you say 'can't do
  this thing because that already kind of does it,' then you quickly run out of things").
- Reroll effects lean to Kestrel ("we can push Kestrel way into the risk-versus-reward space,
  like a real maverick pilot").
- A tier-one body from more than one maker, so no one tank is a must-pick; Aphelion needs a
  defensive tier one.
- Random is welcome where it adds and the player can steer it.
- The debuffs the team lays on foes grow by kinds (a weaken, a flat on-hit, a share of
  current HP, a timed stun, a trapped slot), never by copies. A new chip is fine, even one
  unique to a chassis.
- Stun is budgeted: prefer changing the enemy's problem over removing its turn. Price, never
  scarcity, since rationing a mechanic makes its carriers must-picks. The price is a gate (a
  condition, a setup, a self-sacrifice, its timing), never the damage it deals; the Paradox
  is the model (the bible's stun row, section 5).
- Rapid pieces stay small, and a damage rider on an action the player takes anyway needs a
  limit. A Rapid vent is never below tier three, a Rapid shield never below tier two (the
  rules' Rapid).

## Budgets (Ryan, 15 October)

The bible's rows hold them (the stun row, section 5; the identity row, section 7).

- Hard control, a foe losing its action, is always weighed first, and other options explored
  before it is suggested. No cap rations it.
- A new chassis earns its place by a new read, a new product, a new price, or by changing
  what a kind of piece does.
- A passive aims to be fed by, and to feed, other makers' pieces, ideally two routes in and
  two payoffs: an aspiration, never a pass or fail.
- A tier one shows its identity with basics alone, with a locked piece or without.
- Two tests of Claude's: a passive that is pure upside with no interest fails, and so does a
  payoff not worth its setup.

## Tiers

- Ten a maker, fifty in all (Ryan, 4 November: "I want to target 10 per maker, at least for
  now"). Tier three is a late-game capstone, so few; the Arsenal fields none at tier one.
  Across the tiers the count is 4-4-2 to work with (11 November: "we restructure the tier
  list from 3-5-2 to 4-4-2"; 12 November: "That's probably fine for 4-4-2 for now"). The refit
  brief's section 13 has each maker's four tier ones with his marks and what they leave open;
  each open place is its chassis's session's, and content deals a machine where the roster
  below says until then.
- The sort (Claude's, partly agreed): tier one is itself with basics alone and stands in a
  start, a body or a hitter and never a support; tier three bends a rule the player has
  already learned; the rest is tier two, where the supports and the machines that are only
  good together belong.
- As dealt: a run starts from a tender of one tier-one machine of each city maker by seed,
  and the player takes three; the fourth is the first battle's offer from the host maker's
  catalogue (decided, not built). So each maker's tier-one line should vary, and more than
  one maker's should hold a front; Wainwright & Sutler's holds none, accepted. The economy's
  items are `docs/economy_pass.md`.

## The action economy

The bible's action economy row (section 5) holds it: Rapid is priced by a gate and never
rationed, and each want it sold has a home that is no Rapid piece. Three rules of thumb for
every design, rework and rebalance:

- A design that wants many blows is pointed at strikes.
- One that wants order is given a die mechanic.
- One that wants a second action pays in a banked resource, a cooldown or an ally's turn.

Rapid stays for the cantrip, gated (if it kills, on a cold spend, once a round, by a
cylinder). Rapid darkens its own entry for the round; Instant rolls the die again, itself
included, and always carries a limiter. The reasoning in full, want by want and home by
home, is in this file's long form.

## Ten a maker

The working roster: 24 built, 23 in briefs, 3 open. A design in italics is a brief in the
table below, under its maker; the rest are built. Ryan's calls moved it this far, and the
moves he has not marked stand as its plan.

| Maker | Tier one | Tier two | Tier three |
|---|---|---|---|
| Minerva (10) | Honey Badger; *the lure tank*; the Wild Boar or *the mole* | the Polar Bear, dealt at tier one until the lure tank lands; *the echidna*; *the Cryo party defence*; *the immune one*; *the mole* or the Wild Boar | *the siege battery*; *the battlecruiser* |
| Kestrel (10) | Skua; Storm Petrel; Puffin, back in design | Buzzard, its rework settled and unbuilt; Kite; Needletail | Lammergeier; Giant Petrel |
| Kestrel's two, tiers open | *the Snowy Owl*, leaning to Cryo | *the Magpie*, its slot open to another design | |
| Wainwright & Sutler (10) | Prairie Dog; Cassowary; Cottonmouth | Dingo; Clydesdale; funnel-web; Whip Scorpion; *the gunship* | Swallowtail, back in design; Musk Ox |
| Aphelion (9, one open) | Stingray; *the line frame*; *Static*; *the Barrier and Ward support*, the defensive tier one | Baboon, dealt at tier one, its tier placed later; *the jellyfish* with the status detonator; *the time-shifter*; one open, the time area's if it wants it | *the Carrier*; *the Macross* with the aura-shifter |
| The Arsenal (8, two open) | none | Nemesis; *Misharu*; *the Onryō*; *the Zoids walker* | Ammit; *Mastema*; *Minos*; *the thunder figure* |

His calls that shape it, and what each leaves open:

- The Polar Bear moves to tier two when Minerva's replacement tier-one front, his own design,
  lands: the lure tank, "and either Boar or Mole will move down". 12 November, of the fourth
  tier one: "the choice now would be between the mole and the echidna depending on their
  mechanics". The Wild Boar's place is unsaid.
- "Mole needs a better hook than 'ignores armour' but we can work on that later."
- The shield-basher is cut as a unit and kept as a piece (`minerva_shield_bash.md`).
- The status detonator is the jellyfish's; the time-shifter stays unrefined; the frost figure
  is cut ("Cut. Moved onto Minerva"), its detonation the Cryo party defence's locked piece.
- "Arsenal 10th can wait until its many unrefined ideas are settled." The Zoids walker "could
  still be Aphelion's 10th"; cats stay out of Aphelion's names.
- The Magpie and the Snowy Owl are "completely unspecced other than general directions and
  names". With the Owl on Cryo, one slot stays open for each of Kestrel, Aphelion and the
  Arsenal.
- Under 4-4-2: Kestrel's four are "two of the three fast Kestrels", the Storm Petrel and a
  support-lean; Wainwright & Sutler's set stands with the Dingo down ("The cars stay");
  Aphelion's wait on its designs.
- Merged by Claude, unmarked: the shock unit is Static and the thunder figure; the
  aura-shifter is the Macross's shifts.

## Roster holes still open

- Soft control: Minos, the jellyfish, the echidna's draw.
- Amplify for others: the echidna's Sonic Needle; the Onryō's curse in another shape, since
  Brittle took the flat on-hit.
- A read nobody uses yet: the die's own state, on the line frame and the battlecruiser.
- The tender: Aphelion's deal with the line frame, and its defensive tier one.

## Orbits

Machines whose identity sits on one thing, a passive or a locked piece, built or briefed
(Ryan, 5 November: "There's some assumptions and holes here, but this is good
information"). `docs/synergy_map.md` is the built content's view, piece by piece.

- **Being struck (6), the largest:** Misharu, the Onryō, the Nemesis's rage, the echidna, the
  lure tank and the Cryo party defence. A blow on hull is the roster's most crowded state.
- **Lure (3, 4 with the jellyfish):** the Polar Bear, the Storm Petrel and the lure tank,
  apart by shape.
- **Cryo (3, 4 with the Macross):** the Polar Bear lays it, the Cryo party defence keeps it
  and blows it up, the Snowy Owl cashes it to stay unseen. The detonation is the one to check
  for room.
- **Stuns (5):** the Baboon's Paradox, the funnel-web's web, the Swallowtail's charged flare,
  the Cryo party defence's gated Suppress, the time-shifter's delay. Numbed is the shared
  brake, and the time-shifter's stasis would freeze it.
- **Kills (4):** the Kite's recharge, the Ammit's Essence, the Giant Petrel's Salvo and
  Mastema's Bellows; the Zoids walker's Phased on a kill would be a fifth.
- **Maker leans, crowded on purpose:** Aphelion's statuses (the Stingray, the jellyfish, the
  time-shifter, the Baboon, Static; the jellyfish's EMP wipes what the others build);
  Minerva's armour (the Badger, the Polar Bear, the Wild Boar, the lure tank, the shield
  bash); heat, the Snowy Owl the first to want none; Kestrel's Exposed (the Needletail, the
  Lammergeier, the Swallowtail).
- **Light:** Shock and Chain (Static, the thunder figure, the Dingo, the Storm Petrel's
  Striker branch); an ally acting again (the Giant Petrel, the Swallowtail, the
  time-shifter); Empowered (the Ammit, the Stingray, the Giant Petrel).

## The briefs

One row a live brief; the to-do's Design sessions hold each one's task.

| Brief | Kind | Maker | Tier | Waits on |
|---|---|---|---|---|
| `refit_pass.md` | the reboot's spec and the refit pass's open calls | the battle and the kit | rule | his play and his calls |
| `numbers_pass.md` | tier one sized against the reboot; the tier-one bench | the battle and the kit | rule | the foes' line's sizing, then his play |
| `heat_pillar.md` | heat as a pillar: his frame, his overheat calls, what the reboot left open | every maker | rule | the heat session |
| `kestrel_line.md` | the Kestrel line's hub: what each fast flyer is for | Kestrel | all | the Giant Petrel's kit, the chassis that orbits Exposed, the last two slots |
| `kestrel_puffin.md` | the Puffin's rework: it moves heat | Kestrel | 1 (two his lean) | his session, after the heat prices |
| `kestrel_buzzard.md` | the Buzzard's rework: shield spent into its blows, not built | Kestrel | 2 | his mark on the reboot machines' round |
| `kestrel_magpie.md` | a support engine: the thief, the mimic, the cache | Kestrel | open | his pick of a direction |
| `kestrel_owl.md` | the silent hunter, leaning to Cryo | Kestrel | open | his pick of where the stealth lives |
| `ws_swallowtail.md` | the Swallowtail's rework, three locked pieces open | Wainwright & Sutler | 3 | parked: his session, its niche first |
| `ws_gunship.md` | proposal, Claude's first round | Wainwright & Sutler | 2 | his own session |
| `minerva_lure_tank.md` | the tier-one front: every hit lures | Minerva | 1 | his calls |
| `minerva_mole.md` | a shape, the drill tank | Minerva | 1 or 2 | its hook |
| `minerva_hedgehog.md` | the echidna: strikers hurt themselves after they act | Minerva | 2 | his calls on the new shape |
| `minerva_cryo_defence.md` | Cryo for the party, detonated by a locked piece | Minerva | 2 | Claude's round on his direction |
| `minerva_immune.md` | immune to every buff and debuff, lent to an ally | Minerva | 2 | his calls |
| `minerva_siege_battery.md` | his H-tank, a charge | Minerva | 3 | parked until he picks it up |
| `minerva_battlecruiser.md` | the capital ship, the broadside | Minerva | 3 | its session |
| `minerva_shield_bash.md` | his piece: damage equal to armour, then no armour | Minerva | 3, a piece | his call on its form |
| `aphelion_line_frame.md` | the line frame, a combo by blows | Aphelion | 1 | his calls |
| `aphelion_static.md` | Static, the shock unit's Aphelion half | Aphelion | 1 | his calls |
| `aphelion_barrier_ward.md` | the defensive tier one | Aphelion | 1 | his calls |
| `aphelion_jellyfish.md` | the status payoff carry, no weapons | Aphelion | 2 | Claude's round on his direction |
| `aphelion_time_shifter.md` | delaying and redirecting blows | Aphelion | 2 | its session |
| `aphelion_carrier.md` | proposal, open | Aphelion | 3 | his calls |
| `aphelion_macross.md` | the flagship mode changer | Aphelion | 3 | his calls |
| `zoids_walker.md` | the shadow panther: Phased on a kill | the Arsenal or Aphelion | 2 | Claude's first round, its maker with it |
| `arsenal_misharu.md` | delayed judgement: marks read, then cashed | the Arsenal | 2 | Claude's round on his direction |
| `arsenal_onryo.md` | its own hull as a resource | the Arsenal | 2 | Claude's round on his direction |
| `arsenal_thunder.md` | the soft Archon homage, much shield | the Arsenal | 3 | Claude's round on his direction |
| `arsenal_mastema.md` | fire through the team | the Arsenal | 3 | his calls |
| `arsenal_minos.md` | the mover; "It needs something else" | the Arsenal | 3 | the something else, in chat |
| `arsenal_frost.md` | cut by Ryan: a stub of what the Cryo round takes | the Arsenal | none | retires with `minerva_cryo_defence.md`'s round |

Not briefed: the empty slots toward each maker's ten; cantrips, his idea of small Rapid
pieces with no cooldown, a combined entry before a Rapid one; the economy's items
(`docs/economy_pass.md`).

## Benches and parked ideas

Ideas set aside that belong to no single brief, free to be proposed, each with what set it
aside so Ryan can overrule the reason. A chassis's own bench is in its brief.

**Aphelion**

- The exposed-rotor helicopter ("they have rotor precedence there"): a shape, no mechanic.
- The large hovercraft, parked by Ryan: tier two, heavy. It sits against "high-tech suites
  over light hulls", and the Stingray already hovers.
- The long guns, parked by Ryan while the engagement range may change: a machine joining
  fights three hexes away.
- The time-shifter's bench is in its brief (`aphelion_time_shifter.md`).
- Three slot-ins for Aphelion's control, none briefed until the roster's powers are read ("or
  we'll end up with an OP umbra inducer all over again"): a status spreader; a stasis piece
  that holds a foe's statuses, its Numbed included; the Zenith Emitter back at tier three as
  a status reader.

**The Arsenal** (Claude's)

- Haunted: a striker spends its next blow on the foe beside it. Nothing against a lone boss.
- The guardian's stay: a blow that would wreck an ally leaves it standing. Rare and binary.
- The bell tower: a walker whose toll is a big indirect blow with Spread, Penetrate and
  Shock. No reason against it is recorded.
- Hubris: strongest whole, weaker as it is hurt. Hard to keep from binary.
- The fate-edited die: its blanks reroll free. A stripped die degenerates to one entry.
- A veil: out of the world for a round, which is Phased as built.
- The Misericorde: a mercy dagger, Direct, flat and Rapid, free for an Arsenal machine.

**Wainwright & Sutler** (the reasons Claude's unless marked)

- Fighting without having moved gives Spread: a map action that buys a fight buff is free.
- Crags as slow ground: a map rule alone is weak.
- Every weapon Indirect: free reach. Indirect weapons strike twice: dangerous as written.
- Shield as a spider's ammunition: free again, though a shield spend is dear under the reboot.
- Debuffs as a gunship's sights: Ryan, a gunship is about its weapons.

**The foes**

- Weaken, a status that weakens a machine's blows (Ryan, 30 October: "Weaken is something the
  foes might want to carry. Note it down for that reason").

## Retired briefs

Each landed; its decisions are bible rows and content.

- The Polar Bear's seal: `git show 96fe416:docs/briefs/minerva_polar_bear.md`
- The Polar Bear's first form: `git show 63487a9:docs/briefs/minerva_armadillo.md`
- The Honey Badger's Ore Hopper: `git show c05c41b:docs/briefs/minerva_honey_badger.md`
- The Storm Petrel and the first upgrade branches: `git show ca717bd:docs/briefs/kestrel_storm_petrel.md`
- The Storm Petrel's first engine: `git show d84ad16:docs/briefs/kestrel_shield_spender.md`
- The Skua's Ricochet: `git show e5638e2:docs/briefs/kestrel_skua.md`
- The Skua's first form: `git show f87b831:docs/briefs/kestrel_strafer.md`
- The Kite: `git show eed817e:docs/briefs/kestrel_kite.md`
- The Needletail: `git show bf6bd1e:docs/briefs/kestrel_needletail.md`
- The Needletail's first form: `git show 9ced5e5:docs/briefs/kestrel_interceptor.md`
- The Lammergeier: `git show 62192a4:docs/briefs/kestrel_bomber.md`
- The Giant Petrel: `git show d84ad16:docs/briefs/kestrel_gun_platform.md`
- The Clydesdale: `git show a2a2b29:docs/briefs/ws_clydesdale.md`
- The Whip Scorpion: `git show 82ff916:docs/briefs/ws_boiler.md`
- The Cassowary: `git show 021f075:docs/briefs/ws_revolver.md`
- The Swallowtail: `git show 5d989be:docs/briefs/ws_multirotor.md`
- The Musk Ox: `git show bc97727:docs/briefs/ws_artillery.md`
- The funnel-web: `git show bfa8cf2:docs/briefs/ws_funnel_web.md`
- The Cottonmouth: `git show 021f075:docs/briefs/ws_fan_boat.md`
- The Prairie Dog's Flakshot: `git show f5a085a:docs/briefs/ws_prairie_dog.md`
- The Dingo's Combat Translocator: `git show 021f075:docs/briefs/ws_dingo.md`
- The Nemesis's rage bar: `git show d264c85:docs/briefs/arsenal_nemesis.md`
- The elites: `git show e75be15:docs/briefs/elites.md`
- The foes' tiers two and three: `git show 26c54c7:docs/briefs/foes_ladder.md`
- Chain reworked: `git show 0cea0ee:docs/briefs/chain_conductor.md`
- The stock pass: `git show a550c2e:docs/briefs/stock_pass.md`
- The six map shapes: `git show b2762d5:docs/briefs/map_shapes.md`
- The long wall: `git show 68381ff:docs/briefs/long_wall_build.md`, its design
  `git show 68381ff:docs/long_wall_proposal.md`

The makers' first proposals, written under an older shield rule:
`git show 2df9340:docs/arsenal_proposal.md`, and at that commit `ws_chassis_proposal.md`,
`aphelion_chassis_proposal.md` and `mechanic_budgets.md`; Ryan's chassis ideas of 4
November, `git show a228545:docs/aphelion_minerva_chassis_proposal.md`.
