# Skirmish code audit, 7 November

Ryan's ask, after the spend's order landed: "audit the code for weird mechanical exceptions,
redundant code branches, duplications, unused code, and any other spaghetti nonsense in the
Skirmish code. I want to avoid all these weird edge cases hanging around that keep getting
missed, causing reasoning errors, bugs, and general confusion."

Read from main at `e07fcb5`. Six agents each read one part, every line of it: `sim/skirmish.gd`
in four slices (setup and queries, the round's flow and the spend, the hit's resolution, then
mines, parts and the death check), the pipeline and data types (`sim/effects.gd`, `sim/face.gd`,
`sim/foe.gd`), and the two places outside the engine that work its rules out again
(`sim/policy.gd`, the bot, and `game/skirmish/skirmish_screen.gd`). Claude read every finding
marked *checked* against the code before it landed here; the rest are the agents' readings,
each cited by line, unmeasured. Nothing here was run in Godot beyond the suite, green at
`e07fcb5`. Code the long wall branch (`ccr-56b5169d-lsa2rg`) already removes or rewrites is
left out and listed at the end, so nothing is fixed twice.

Kinds: **Bug** (the code does something the rules don't say, reached by today's content),
**Latent** (the same, no content reaches it yet), **Question** (the rules give two answers or
none: Ryan's call, with Claude's lean), **Exception** (a mechanic special-cased off the general
path), **Duplicate** (a rule written twice, or worked out again outside the engine), **Unused**,
**Tangle** (hidden state, order-dependence, misleading names), **Text** (shown text or the
records out of step with the code).

It retires once its findings are fixed, struck or turned into rows and tasks.

## Where it stands, 8 November

Ryan's calls on the questions (8 November) and the bugs he read as "correctly assessed" are
built, each with a test that failed first (`ad0b607`, `ccd04bc`), and his answers to the four
left open the same evening: the Knuckle of Fury and the Spin-Up keep their rolls, said on the die;
the Musk Ox reloads once, the greater; a countdown shows what it would deal now; a Sweep's spots
are queued at the spend's start, a pair's halves a spot each. Bugs 5 and 6 went further than
their fix: "A stack is a stack, doesn't matter where it came from" retired the purge by source
and its sleep whole, and a unit's own mechanic became an Ability that no purge touches; the
Ammit's Quintessence Tap, which keeps its Empowered from a Purge, is a question in the bible's
section 12. 15's
rally worth is fixed; the bot's other readings wait for the bot's step below, and Bug 16 goes
with Structure 3. All of it landed on main on 8 November (Ryan: "If there's nothing else open,
clean up and merge into main"); what is left is Structure, the Unused list and the comments,
in the order at the end.

**The mine path went with the Lammergeier's rework** (Ryan, 8 November: "Flag the mine path as
an issue but don't bother fixing mine problems until the rework, in case it stops existing"; the
rework, 9 November: Mines on foes, the bible's Lammergeier row). The slot mines' code is gone, so
Bug 7, Question 11, Root 1's mine half (`_mine_hit`, `_mine_spill`), the strands in Structure 7
and the mine half of Structure 4 went with it rather than being fixed: a Mine's blast is one
plain blow a foe its reach meets (`_blow_mine`), no copy of the hit routine, and nothing lands on
an arrival. Question 9 carries on in the new form, on the lean: a blast set off in a spend is
part of it, so what its falls bring back stands once the spend is done (the rules say so).

**Step 3 began the same day** (`ccr-8df9952c-4cccdf`, Ryan: "No behaviour changes; the suite green
after each step"): Root 1's spend half, Root 3 and Structure 3's engine half, each part checked by
the suite and by `tools/behaviour_trace.gd` (2,988 seeded fights, every spend's previews,
forecasts and whole state, identical to main's byte for byte) and twenty whole quick-campaign runs
the same. Structure 3's last two pieces on Ryan's word, 9 November ("Go ahead with both"): the
screen's Swap-pending fallback onto `preview_round` (Bug 16, the one visible change: the gauges
no longer drop to the bot's estimate while a Swap waits), and the die-in-hand half of `forecast`
gone, which no production code called but twenty-three tests pinned rules through (Scorched's
extra under a heat multiplier, the Thrust Overboost's, by a synthetic passive; the Storm Petrel's
burn; a bite; a brace), each now read through `preview_round` with the die in hand or the die as
shown. The engine's play stayed identical to main's. The mine's half went with the slot mines (9
November).

## The roots

Most of what follows comes from five habits. Fixing a root clears its findings for good; fixing
a finding alone leaves the habit to grow the next one.

1. **Two hit resolvers.** A spend's hit runs through `_resolve_attack`; a mine's hit runs
   through `_mine_hit` and `_mine_spill` (about 150 lines), a second copy written before the
   spend's order of 3 and 7 November and never brought along: a mine that kills skips the
   riders, the area skips corpses, missing hull and the talons' kill rule are absent. The
   Spillover branch in the resolver keeps a third shape. One per-hit routine both call.
   *The spend's half done 8 November (step 3): one `_hit` for the plain spend, the salvo and the
   blast, each caller paying its own (`_finish_hits`), and one `_land_blow` for every blow of a
   hit, the spill's included. The mine's half went with the slot mines, 9 November.*
2. **The engine's rules worked out again outside it.** The bot restates the blow's arithmetic
   (`damage_outcomes`, `_area_mean`), the salvo, Spillover, a last act, the blast, the Paradox
   feed, the Cryo cash and Shock; the screen infers deaths and returns, a Sweep's rank and the
   unspent dice; the engine itself keeps two models of the round (`forecast` beside
   `preview_round`) and copies `end_round` into the preview. The Skua's halving needed four
   edits today for this reason. Each mirror asks the engine instead, through shared helpers.
3. **Hidden flags in place of arguments.** `_salvo_strike`, `_blast_strike`, the `_spend_*`
   three added today, `_strike_no`, `_holding_returns` cleared as a side effect, `_reinforcing`,
   and the pipeline's process-wide `recording` and `muted`. Each changes behaviour deep inside a
   function that does not take it as a parameter. Arguments and return values.
   *Done 8 November (step 3): the salvo, the blast and the `_spend_*` three are arguments and a
   return; the strike number is `_spill`'s argument; the spend opens and closes its own hold and
   `_release_returns` only releases (the hold stays the spend's scope, which a mine set off
   inside it reads: Question 9); the preview's recorder lives on its copy's units and foes, gone
   with the copy. `muted` was never the process's (a local of `Effects.effective_face`, read off
   the machine's Silenced), and `_reinforcing` went with the long wall.*
4. **Special cases keyed by id instead of data.** Nineteen of the 43 statuses carry no effect
   and run by id elsewhere; a status's clock is chosen at each call site; "every machine" is
   listed four ways, "the machine acts again" six, "a kill" three, "this keyword won't land on
   this foe" four, "whom a foe's move acts on" four tables, "a foe stepping into a slot sets off
   its mines" six places. One definition each, read everywhere.
5. **Leftovers of retired mechanics.** Rolled ranges (gone 2 November) still shape the bot's
   outcome lists and a dozen comments; Chain's repeat and "the next link" (retired 28 October);
   "strike" where a Sweep now fires shots; "a kill clears its slot at once"; Overcharged and
   Kindled; the spray. They mislead whoever reads the code next, a session included.

## Bugs

Checked against the code unless marked. "Change" says what fixing it does: *to the rules* (the
code takes what the rules already say), *text* (shown text or the log only), or *bot* (the
balance runner's valuation only).

1. **The enemy's turn checks death only at its end.** *Fixed 8 November.* `_enemy_turn` 2212-2215 skips a foe its
   own tick kills, and the one `_clear_dead()` runs at 2241 after every foe has acted. So a
   Behemoth burnt to death lands its Meteor after every other blow (the rules: "the moment it
   falls, before anything else"), a burnt core's parts still strike that turn, a burnt
   swallower holds its machine out of the fight for the rest of the turn, and a burnt Undying
   foe or Gel comes back at the turn's end, not "at once to a tick". Fix: a death check after a
   tick kill and after each foe's turn (the foe already in `_acted`, so a gold rage its tick
   broke still staggers next round). Change: to the rules. *Checked.*
2. **A fight lost in the enemy's turn plays on.** *Fixed 8 November.* After the last machine falls the remaining
   foes still tick and act (a Burning death counts as a kill, a heal, a rally, a summon), and
   `end_round` still runs the turn's end, regrowth and the reinforcement step, before
   `_check_outcome` (2152-2161). `Battle.finish_skirmish` reads `kills_by_type` on a defeat, so
   those deaths raise the battle's kills and menace. The rules: the fight "ends the moment it is
   decided". Fix: stop the foe loop when no machine stands; check the outcome after
   `_enemy_turn`. Change: to the rules. *Checked.*
3. **Guarded is missing from the die's number and the bot's.** *Fixed 8 November.* `shown_number` (skirmish 642),
   `damage_outcomes` (policy 1274) and `pull_score` (policy 901) add the foe's flat
   damage-taken adds only (`Effects.damage_taken_add`), to keep Shocked's double off the die,
   and so drop Guarded's ×0 too. Over a `guard: all` core (the Fallen Weapon, the Astromancer,
   the Obsidian Tyrant) the die shows a full blow that deals 0, and the bot values hitting it.
   Fix: `Effects.damage_taken(foe, blow, striker, weapon, false)`, which reads every add and
   multiply but the aimed-only Shock; delete `damage_taken_add`. Change: the die shows 0 over a
   guarded core. *Checked.*
4. **A merge's taken foes count as the team's kills.** *Fixed 8 November, with Question 4.* `kills_by_type` (465-482) counts an own
   foe as killed when it is no longer on the field; `_lift_out` (3767) takes merged foes off it,
   so the King Gel's merge credits the team its court as kills (salvage, menace, the Rupture
   meter). The rules: a merged foe is no kill of the team's. With Question 4. *Checked.*
5. **A partly purged buff's sleeping stacks skip their clock.** *Gone with the sleep (Ryan, 8 November: "A stack is a stack").* `Effects.purge` puts N of an
   innate grant's stacks in `slept_stacks`; the round's halving touches only `stacks`; `wake`
   adds the slept part back whole. A Grievance Reliquary's Empowered 3 purged by the Djinn's
   Unmake (Purge 1) wakes at 2 where unpurged it would be 1. Fix: sleep a split-off modifier
   that every clock reads. Change: to the rules ("their clocks still running"). *Checked.*
6. **Grants of one status from different sources merge, and a Purge reads the first source.** *Gone with the purge by source (Ryan, 8 November: "Your purge by source makes no sense. A stack is a stack"): a Purge takes stacks whatever granted them, so merged grants are right.*
   `Effects.stack` merges on id and scope (620-625); `bought` reads the merged modifier's
   source prefix. The Reliquary's Empowered and an Overcharge Coil's merge: a Purge then sleeps
   the bought stacks, or ends the passive's for good, depending on which came first. Fix: a
   `bought` field in the merge key, set at the grant (and the same for "cooldown", read by
   source string at 1965 and 2079). Change: to the rules. *Checked.*
7. **A mine that kills lands none of its riders.** *Gone with the slot mines (9 November): a Mine's blast lands its riders on every foe it meets, felled or not.* `_mine_hit` meets a foe its shot felled with
   `continue` (its line 91 from the function's head): no Burn, Suppress, Web, Cryo, Flak,
   Shock or Expose, and no Cryo cash for the spender (a Purge alone is patched in). Its area
   drops corpses that `reached_by` keeps (so a pair's living half is missed once its left half
   fell), it never reads missing hull, and a mine's kill feeds no talons. Root 1. Change: to the
   rules ("every keyword acts as the shot lands, as on a blow"). *Checked.*
8. **Spillover's later strike drops its riders.** *Fixed 8 November.* The resolver's branch for a front foe an
   earlier strike felled (2766-2778) spills and `continue`s past the lays, Burn, Suppress, Web,
   Cryo, Flak and Purge, which the same strike without Spillover lands on the corpse; the
   Primed Burning still lands. A Wild Boar's ×2 Flak 1 that kills with its first strike leaves
   Flak 1, not 2. Fix: spill, then fall through to the riders. Change: to the rules. *Checked.*
9. **A last act at every machine strikes machines out of the fight.** *Fixed 8 November.* `_last_act` walks
   `live_mechs()`, Phased and Swallowed machines included; `_damage_mech` records nothing for a
   machine out of the fight, and `_strike` then reads the last recorded event anyway (another
   machine's, or index -1 when the list is empty), landing riders on the machine that is out.
   The Behemoth's Meteor, with a machine Phased. Fix: one "who a blow at every machine reaches"
   (Duplicate 1), and `_damage_mech` returns its blow. *Checked.*
10. **A reroll of nothing spends a team reroll.** *Fixed 8 November.* `_reroll` with no live die named still takes a
    reroll (1673-1689), and REROLL stays lit with every die spent or locked. Fix: nothing named,
    nothing spent; the button needs an unspent die. *Checked.*
11. **The screen plays a death and a rise that never happened.** *Fixed 8 November.* `_use_die` infers a death from
    "carried Undying before the spend, lacks it after" (skirmish_screen 2937-2960, 3086-3092): a
    Purge that strips Undying from a foe it doesn't kill plays a stand-in death and an arrival.
    Fix: read the engine's `returned` entries. Change: text. *Checked.*
12. **END TURN asks about dice that cannot be spent.** *Fixed 8 November.* `_unspent_count` (skirmish_screen 4025)
    counts every unspent die that isn't blank, while the button's pulse uses `can_spend`: a dry
    gun or an unpayable shield cost makes END TURN pulse and then ask "1 die is still unspent".
    Fix: count `can_spend`. Change: text. *Checked.*
13. **Shown text.** *Fixed 8 November.* Purge N never shows its number (`Face.describe` lists Burn, Cryo, Flak, area
    and Chain numbers, never Purge's; `add_keyword` gives it no default either): the Null Field
    Emitter reads "purge" for Purge 2. The readout's `MOVE_TARGETS` (entry_readout 429) lacks
    barrier, regenerate, cleanse, prime, enrage, golden and ward_all, so Burrow, Grave Mend, Knit
    and Hallow read "Target: Any machine". A summon's log names foes by content id ("2 wolf
    answer the call", skirmish 3393). *Checked.*
14. **A kill built a mine shot it rarely needs (today's, fixed with this audit).** The killing
    shot a drone leaves was built for every kill, and building it deepens its stacks, which logs
    "runs hot" for a hot Stingray's Photosphere Lance. Now built only for a foe carrying a drone
    or an entry that lays one. *Checked, fixed.*
15. **The bot misvalues several pieces.** *The rally worth fixed 8 November; the rest with the bot's step.* *Bot.* The salvo is valued as if each shot were a first
    blow (a Shock doubles every shot, a Barrier zeroes every shot, a consumer eats on every
    shot) and skips the kill terms (policy 1432-1446); a Shock is credited on area neighbours and
    conductors already Shocked, where `_shock` lands nothing (495-501); `rally_worth` counts a
    foe its Burning kills before it acts and Phased machines under a blow at every machine
    (skirmish 927-937); Suppress is valued on a Warded foe (513-519); a kill that comes back
    (Undying, a split) or a part's, which is no kill, is paid in full; the reach tally books a forged gun's heat that ammo paid
    (skirmish 2949 before 2953); `effective_face` runs twice on one entry, so Supercooled's Cryo
    counts twice. Agents' readings; Bug 3 above is the checked one.
16. **The forecast with the die in hand reads the raw entry's heat.** *Fixed 9 November, with
    Structure 3: the die-in-hand forecast is gone (the round preview is the one model with a die
    in hand), and the screen's gauges read the round preview while a Swap waits too.*
    `pending_heat` and
    `pending_burn` pass the printed heat, not the Cottonmouth drum's rewrite, so an overheat
    warning can be missed (the Ankle Mortar forecasts 1 and pays 3); and while a Swap waits for
    its second target the screen's gauges switch to that older model (no coming chips, no
    next-in-line pick, no last act on a burn death). Fix: Duplicate 3. Agents' reading.

## Questions (Ryan's call)

1. **A Sweep's per-shot boundary.** *Ryan, 8 November: "Per shot." Built.* Riders, Shock, Expose, Disrupt, Lure and what a status gain
   sets off land per shot (built today: "riders per hit, for each shot fired"); the gates, a
   passive's lays and the foe's own reads are taken once at the spend. What follows, each against
   a line in the records: the Paradox gains a stack per shot (rules: "once a spend per debuff");
   a later shot spends the Shock an earlier shot laid (rules: "a shocking weapon never spends its
   own"; Cryo: "a fire never cashes its own frost"); a foe two shots meet is Disrupted twice and a
   two-move foe flips back; a Shock laid this spend conducts a later shot's Chain arc. A Primed
   Musk Ox's eight-shot salvo with the Baboon on the team gives each foe two Paradox stacks
   today. Lean: per shot for all of them, since "each shot is independent", the gates and reads
   taken per shot too; the records rewritten to say so.
2. **Does a Guarded core take its ticks?** *Ryan: "I wouldn't think so by definition." Built.* Ticks come off `hp` straight (2212), so a guarded core
   burns and Vitriol eats it, while Guarded "takes no damage while its parts stand". Lean: no;
   ticks go through `damage_taken` with Guarded applying and Flak not.
3. **The salvo's heat under Scorched.** *Ryan: "scorch affects the actual heat bar, not the ammo cost ... Same as the storm petrel when its shield is up." Built, the Petrel's shield paying the gun's own heat alone.* The resolver zeroes the salvo's heat (`_salvo_strike`,
   2953) while the forecast prices Scorched's extra on it; the rules say both ("Scorched's extra
   included" on ammo, "no heat" on the salvo). Lean: Scorched's extra lands, as on every forged
   gun, and the flag goes.
4. **What is a kill.** *Ryan: merges, returns, splits and parts are none, only a core counting ("I thought I said only the core counts"). Built.* Three counts: `_falls` (the kill triggers, the reset gun, the Spindrift
   Salvo, the Muster) counts a part taken by its falling core and a Bomb's burst; `team_kills`
   (the Pilgrim's grudge) leaves out anything that stays down; `kills_by_type` (salvage, menace)
   counts every own foe gone, merges included (Bug 4). The Swallowtail killing the Ruby Colossus
   with both tentacles standing gets three kills' muster. A mine's kill counts to whichever spend
   set it off. Lean: one tally at the death check by pack and type; a kill is a foe a blow, a
   tick or a mine felled; a part taken by its core and a merge are not.
5. **The Reveille Horn's roll.** *Ryan: "It's a roll, it should follow roll rules." The Horn built; "Nemesis and cassowary keep their special rolls, we just need to make it clear": each says "itself included" on the die.* Three pieces make an ally act again by three paths; the Horn's
   is a plain roll that may land on the entry just spent, the Immelmann Booster's never does.
   Lean: one path, Rapid's (never the entry just spent).
6. **The Goblin Nob's opener and Disrupt.** *Moot: the rage is the Nob's own from the start (Ryan, 8 November), the opener retired.* The opener is taken "before any other", so a Disrupt
   has nothing to turn it to, yet the die shows Disrupt live over the Nob (`shut_gates` strikes it
   only for a committed follow-up). Lean: the die strikes it; the opener stands.
7. **The cool-and-shield entry's two encodings.** *Ryan: "both types at once ... atomic based on the current game state." The form built; the Musk Ox's reload once, the greater ("Once, take the greater number").* The Sutler's Hoist is a shield that cools and
   the Wake Diffuser a vent that shields; the paths differ (the vent logs its printed number, not
   the heat it took off, and never overshields), and the encoding decides the Polar Bear's form (a
   shield seals, a vent opens) and the Musk Ox's reload (3 for a vent, 2 for a shield). Lean: one
   "cools then shields" helper; the form and the forge read what the entry does.
8. **A countdown's rally.** *Ryan: "It shouldn't forecast rounds in the future. Show what it would deal at the current game state." Built.* A gathering countdown shows its blow with the rallies it carries now,
   though Empowered halves at every round's end before it lands (checked in the engine, 8
   November: a countdown of 2 announced beside a rally of 2 shows its blow +2, then +1 the round
   after, and lands at +0).
   Lean: show what lands.
9. **A mine set off inside a spend** *Settled with the rework (9 November) on the lean: a blast set off in a spend is part of it, its falls' returns standing once the spend is done.* (a pull or a Swap) holds its kill's return until the spend
   ends, where the rules say "at once to a mine". Lean: the spend's rule, since a mine set off by
   a spend is part of it; the rules line says so.
10. **A Sweep's dropped-on foe and its entry effects.** *Ryan: "I think you're correct, except that I would use up a shot for each gel half." Built: the spots queued at the spend's start, the zap on the dropped-on foe, the validator refusing a Swap, drone or pull on a Sweep.* The drop picks the rank and nothing else,
    yet it still sets the zap's foe and the conditions read for heat and the sixth shot; a Sweep
    granted a Swap, a drone or a pull does nothing; a twin slot's shots always meet its left
    half. No content reaches these. Lean: the validator refuses a Swap, drone or pull on a Sweep;
    a Sweep's zap and conditions read each shot's foe; a twin slot's shot meets both halves, as an
    area does.
11. **The drone's mine.** *Gone with the slot mines (9 November): a Mine carries a flat damage, never the killing blow, so no foe's reads ride in it.* It carries the killing blow including the dead foe's own reads (a
    Backdraft Charge's eaten stacks, counted again when the mine eats the next arrival's; a
    Coriolis's missing hull baked in) and no Primed Burning, and a Storm Petrel zap that kills a
    droned foe leaves none. Lean: the firer's number without the foe's reads, Primed Burning
    included, and the zap counts.

## Structure (no behaviour change)

1. **One "who a blow at every machine reaches"** for `_foe_turn`, `specials_reach`
   (`targetable_mechs` under a third name), `_draw_blows` and `_last_act`. *Done 8 November
   with Bug 9: `targetable_mechs` for all four, `specials_reach` gone.*
2. **One hit routine** for the resolver, the mine and the spill (Root 1), split from the spend's
   costs (ammo, heat, the shield's burn and the zap, the tally, the cooling, the casings), each
   caller paying its own; the second target, `exposed_before` and the strike number passed as
   arguments, the drone's Rapid returned. *Done 8 November but the mine's half: `_hit` returns
   what it did (`Hits`), and `_finish_hits` tells it, lands the zap where the gauge pays, runs the
   death check and pays (`_pay_hits`, how the heat is paid the caller's `Pays`); `_land_blow`
   lands every blow of a hit, the spill's too.*
3. **One round model.** The screen's Swap-pending fallback reads `preview_round`; `forecast`
   stays the bot's estimate and shares one blow helper with `_damage_mech` (`blows_on` copies its
   first half); the die-in-hand half of `forecast` goes (`with_face`, `aimed`, `pending_heat`,
   `pending_burn`, `cryo_cash`, `lure_preview`: no production caller). `preview_round` and
   `end_round` share one `_finish_round`. *Done: `_finish_round` and `_blow_on` (the blow
   `_damage_mech` lands and `blows_on` walks) on 8 November; on Ryan's word, 9 November, the
   screen's Swap fallback onto `preview_round` (Bug 16) and the die-in-hand half gone,
   `forecast(ms, extra_shield, overshield)` the bot's estimate alone, the twenty-three tests
   reading their rules through `preview_round` with the die in hand or the die as shown.*
4. **One geometry.** `area_shapes` is the shape of a hit; `reached_by` is its target and its keys
   (they build the same set today); the mine uses it.
5. **One act-again path** with the "fight decided" check written once (now three times) and the
   spent entry's index captured at the spend's start; Rapid alone lacks the wreck and decided
   checks today (a Rapid kill whose last act wrecks its own machine rerolls the wreck's die).
6. **One `lands_on(ms, f, keyword, foe)`** for the die, the resolver and the bot: gates, a Ward,
   a Numbed foe's stun, a committed or fresh foe's Disrupt and Lure (the die shows Lure and
   Disrupt live over a fresh foe today).
7. **One arrival** that stands a foe, a pair or a massive foe, in place of the paths (`_place`,
   `_step_up`, the pair split, the twin riser, the riser), two of them setting the massive foe's
   back slot in different orders. *Its mine strand (`_arrive_at`, the slot's shots) went with the
   slot mines, 9 November.*
8. **One spend legality.** `can_assign`, `can_spend` and `_assign` check it three ways
   (`_assign` has no index bound, runs `charge_lands` twice, accepts a blank `can_assign`
   refuses); `_assign` spends a blank only so the screen can grey it.
9. **Statuses as data.** Every STATUS entry names its decay (call sites pass literals today, so a
   passive laying Shocked would lose it at the foe's next action); one Ward rule for both sides
   (its chip text says Suppressed lands, the code turns a stun and a Purge away); membership by
   tags, not id lists (`FOE_STATUSES`, `TEAM_MARKS`, `KEYWORD_STATUS`; `FOE_PURGED` went with
   the purge by source); the
   effect-less statuses given real effect kinds; about thirty single-effect readers folded into
   one aggregation table (two ignore stacks, three take a max).
10. **Grants to the spender.** `braces`, `self_burn`, `regen_*` and `heat_per_blow` each have
    their own block and source prefix (no Purge reads the source since "a stack is a stack");
    one list on the entry, landed in one place.
11. **One Face.** A Face is the printed entry, the effective one or the shown one, and nothing
    tells them apart: shown-only fields live on the sim object (`short`, `ammo`, `dry`, `burns`),
    `shown_face` writes the piped heat into `heat`, an effective entry is fed back into
    `effective_face` (not idempotent), and a shown face fed to `can_fire` reads a forging gun's
    price as 1. The fields are written five times (`from_dict`, `to_dict`, `duplicate_face`,
    `has_unique_rule`, `rule_phrases` beside `describe`), already drifted.
12. **The bot asks the engine.** `shown_number`, `_area_blow` and a foe-side helper made public
    and static; `damage_outcomes`, `_area_mean`, `_widest`, `mine_score`, the salvo, Spillover,
    `last_act_cost`, `blast_score`, the Paradox feed and the Cryo cash call them; the rolled
    outcome lists become one number.
13. **The screen asks the engine.** Deaths and returns from `returned` (Bug 11) and `form_mark`
    from the engine's `form_change` (Question 7), both done 8 November; the mine text went with
    the slot mines (`Skirmish.mine_text`). *Done 9 November:* a Sweep's rank from
    `sweep_rank_of` at each of the screen's four reads, and the intent's number from
    `Skirmish.intent_value` through one read for the field's chip and the readout's
    (`_intent_read`).

## Unused (checked by grep across `sim/`, `game/`, `tools/` and `tests/`)

- The engine: `any_assigned`; `last_blast`; `mine_tally` and
  `_land`'s `pulled`; most of `last_roll` (the screen reads only its tags) and the `Hits.base`
  and `mech_index` that fill it; the attack's `vent` (`vent_heat` is refused by the validator and
  always 0, `Hits.vent` now); the dry-magazine branch of `_spend_at` (`targets_for_face` refuses
  a dry gun);
  `_salvo`'s null-target and no-shot fallbacks and its `reach` write, added today; `kills_for`
  (tests only; `lure_preview` went with the die-in-hand forecast, 9 November); `preview_round`'s `bite`, `volatile`, `heat_end`,
  `breaks_shield` and `notes` (the last two read by one test each); `MechState.locked` (saved
  only); `Unit.allies` and `_refresh_allies` (read only by the `ally_present` condition, which
  no content uses); `_split_slot`'s rank, `_repick`'s foe and `_pick_exposed`'s rng parameters;
  `Skirmish.pilot` (measured "no lever at all", 30 October).
- The pipeline and data: effect kinds `suppress`, `set_reach`, `min_damage`, `multiply_stat`,
  `per_stack`, `shock_on_block`, `add_armour_vs_rank`; triggers `on_skirmish_start` and
  `on_shield_gain`; conditions `reach_direct`, `reach_indirect`, `ally_present`, `tag_*` and the
  move condition `back_behind`; Charged and Supercooled are run by the engine but missing from
  `MECH_STATUSES`, so the validator refuses any buff that grants them; `Effects.explain` (tests
  only); `Effects.effect_text` (a fallback no passive reaches); `Foe.text_of` and
  `Foe.choose_action` (tests only), `Foe.on_field` (no caller), `Foe.wanders` (written, never
  read); `Face.label` (the die sheet only); `brace_stacks` and `braced_armour` (identities since a
  stack is a point); the save shims for the "line" and "melee" reaches.
- The bot: `hull_percent` (tests only); the `aimed` parameter (never false); the `uses`
  parameters of `heat_cost` and `volatile_cost` (never passed).

Kept on purpose, said so: an effect kind content may yet use is kept only in one block marked
"engine ahead of content", so the next session knows it is unreached.

## Text and records

- Done 8 November: the rules' zap "lost if the strikes killed it" and a passive's lay "on a foe
  it reaches alive" (both land on a foe the spend fells, as the code does), and the lone die's
  free reroll (the Battery Director, the Trim Tabs), now in the rules' Rerolls.
- Stale comments: `skirmish.gd`'s header ("a kill clears its slot at once", "damage in fives");
  `shown_number`'s "[low, high]" and "a raised ceiling", sitting on `split_share`; "a sweep's
  strikes", "a chain link" (the resolver's note on `real` and "the salvo's strikes" went with step
  3); "killed by a die this round, it stands until the dead are
  cleared" (2204); `_place`'s "Minos's turn of the ranks"; `_shot`'s "Volatile acted at the
  spend"; the section banners ("mines" covers fifty unrelated functions, "formation" holds only
  `_clear_dead`); `effects.gd`'s header stating the blow's order wrongly (missing hull first) and
  without `multiply_printed` or the foe's stage; Empowered's "the move spends it"; Ore Plate's "a
  point a load"; Hot Streak's "5 hotter"; the Crucible; "Numbers are
  in tens", "each rolls", "a sprayer"; the screen's header ("tap to lock", "Kinetic faces roll",
  "Withdraw") and "POOL 02"; misplaced docs in the bot and the screen; the Flechette Pod's and
  the Musk Ox's design text still describing the spray and random targets.

## The long wall's cut, landed

The long wall landed on main on 8 November, just before the audit's own landing, with
reinforcement inside a fight cut: the pool, the reserve, `_reinforce`'s random path, `reserve_counts`, every `_reinforcing`
read, withdrawal and the reserve plaques are gone. What the audit expected it to leave behind is
for the Unused pass to check again on main as it stands: the bot's reinforcement estimates
(`arrival_odds`, `waiting_for` and their kin, reading a queue `begin` now empties), the engine's
loops over `reinforcements`, the pool's half of `parts_down`, and `_schedule_regrowth`,
`_fall_with_cores` and `_refresh_kin` beside the corpse a regrowing part now keeps. Latent: a
part held to get back up is invisible to `_schedule_regrowth`, so an Undying part would be
scheduled to regrow and then rise as well (no content pairs them).

## Order of work, proposed

1. Ryan's calls on the eleven questions. *Done 8 November.*
2. The bugs that take the rules as written (1-13), each with a test that fails first. *Done 8
   November; the mine's went with the slot mines, 9 November.*
3. Roots 1 and 3 together (one hit routine, its arguments), since Bugs 7 and 8 and Question 10
   live there; then Root 2's engine half (one round model, `_finish_round`). *Done 8 and 9
   November, the mine's half going with the slot mines; nothing the engine plays changed, the
   Swap's gauges alone (Bug 16).*
4. The bot's mirrors onto the engine's helpers, then a 30-seed run read as a direction against
   the last, since the bot's valuations move.
5. Statuses as data, the Face, the dead code and the comments, in one pass each.
