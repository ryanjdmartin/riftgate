# The Clydesdale: a rework

<!-- hangar: {"kind": "chassis", "maker": "wainwright_sutler", "tier": 2, "status": "rework", "slot": false, "name": "Clydesdale", "built": "clydesdale"} -->

**Ryan's idea (11 November)**: "I had an idea to make the Clydesdale a little more interesting
while keeping it's identity. It has two dice, each with 5 sides. Each die has the same locked
component on it, that flips its die to the other on Rapid, cooldown 1, so it can only flip once a
turn. That leaves it with 8 total hardpoints, and the locked piece, for still a total of 9
components. Visually, if we put all 8 hardpoints back on its back, flipping dice would cause 4 to
retreat into its hull (similar to the armadillo) and the other 4 to emerge. Flipping back does the
opposite. I'd imagine it as the 4 pivoting vertical, then retreating downward vertically. The
choice then is do the second 4 come out of the same ports, or are there 8 ports on it that
alternate."

**His answers to the first round, the same day**: "One half at a time, yes, not two dice spinning.
The active half should persist between skirmishes, too, so that there's not a "first" die,
technically, other than the start of the battle." "My intent was for the flipper to be shared
between the two, so it's the same piece with one cooldown. However you need to code that is fine."
"I was planning on removing the extra rerolls and replacing it with this version. An upgrade could
bring them back, or if it proves too unwieldy without." Of the lance: "What even is the lance? The
enfilade beam? Does it even need to look like that? That's a special model for the Clydesdale
only, and I thought we got rid of all special models, didn't we?"

## What stands

The Clydesdale today (content at main's `2a9242e`): Wainwright & Sutler's tier-two assault walker,
nine hardpoints and nothing fixed, three module slots (its identifying feature, the bible's module
slots row), Battery Director (rerolling its own die alone is free once a round; the bible's row
"the Clydesdale's big die earns its reroll"). The maker's versatility by loadout (the Cottonmouth
row: "the Clydesdale's is loadout, the gunship's stats, this one's reach"); a sandbox, its point
(`docs/locked_pieces_proposal.md`, section 1); no locked piece, so its upgrade branch stands on
rerolls or module slots (the tiers row).

## The design, as it stands after the first round

- **One die of nine entries, folded in two** (Claude's form of his "same piece with one cooldown"):
  the flip, fixed, is entry I; hardpoints 1 to 4 are one half and 5 to 8 the other. Only one half
  is out, and the round's roll and every reroll land among the five live entries, the flip and the
  half that is out. Two copies of the flip, one a die, would have flipped twice a round: a cooldown
  is kept by entry and copies of a Rapid piece chain on purpose (`sim/skirmish.gd`, Rapid's
  comment); one entry has one cooldown.
- **The flip**: equipment spent on itself, Rapid, cooldown 1. It turns the die to the other half
  and Rapid rolls that half; the free roll never lands on the entry showing, the flip, so it
  always lands on one of the new half's four. Once a round falls out of the one entry. A spend, so
  no extra control (the bible's design test of 11 November).
- **The half is the battle's**, as the hull is: a battle opens on the first half, and every
  skirmish after opens on the half the last one ended on.
- **Battery Director retires.** Claude's reading of "replacing it with this version": the halves
  are the passive (a rule of its die, as the Cassowary's stepping die is its passive) and the flip
  its locked piece. The free reroll may come back through an upgrade, a tweak of the flip (a branch
  tweaks a locked piece and leaves the passive alone), or if play finds the flip unwieldy without
  it; the Trim Tabs module (rerolling its own die alone free once a round, heat maximum −4) gives it
  back as a build choice today.

## What follows from it (no questions)

- The kit words hold: the flip is one component and one entry on the die.
- The end of a fight sets up the next: a fight ends the moment it is decided, so the half that
  carries is the one out at the last blow, and opening the next fight on the other half means
  flipping before the killing blow. On the map the half that is out shows on the model and in the
  codex: a reason to take one pack before another.
- Upgrades: it holds a locked piece, so its branch tweaks the flip as every machine's does; the
  tiers row's exception for it retires with Battery Director, as do the row "the Clydesdale's big
  die earns its reroll" and the parked idea "two rerolls or ten entries if the Clydesdale's passive
  is thin".
- Each half rolls as an ordinary machine's die (the dealt roster rolls three to eight entries, most
  five or six). Heat bites on it again: on the nine-entry die a hot piece never reached its knee
  (the pricing row), on a live five it fires a fifth of its half's spends.
- With no free reroll, a flip that shows while the player wants to stay costs a team reroll or the
  turn: the play test's question (his "if it proves too unwieldy without").
- A foe's switch-off or corruption lands on the entry showing, so never on the stowed half; a
  Corrupted entry stays corrupted stowed, and a Disabled one stowed by a flip lapses there.
- The half that is out is an Ability chip (the Polar Bear's seal the precedent): nothing purges it.
- The battle's save keeps the half. A lone skirmish (the harness's, the runner's matrix) opens on
  the first half, so the matrix reads a fight's flips and never the carry.
- Work to come, named for planning: the live half in the engine; the die, its readout and the
  codex (the stowed four dim); the policy valuing a flip and a half that persists; the pricing
  run's Clydesdale bench (`tools/pricing_run.py`, keyed to the Howitzer's slot, index 4 today);
  the model rebuilt, its tests with it.

## The model

- **The ports** (Claude's lean, unanswered): eight, alternating. Four sink while four rise, one
  motion; through shared ports the second four rise only once the first are down, so a flip takes
  twice as long and Rapid's spend after it waits on it (its gun up and turned before the blow). The
  guns stand elsewhere after a flip whatever their classes, so the half reads at rest by position,
  where through the same ports two halves wearing the same classes (there are five) look alike once
  they settle. Each raised gun turns over the shut hatch beside it. One pin a hardpoint, so the
  mount rule holds: hp_1 to hp_4 one half, hp_5 to hp_8 the other. From behind and above, where
  the skirmish sees it, a sideways shift reads at full width and a fore-and-aft one foreshortened:
  a checkerboard (staggered, as a battlecruiser's wing turrets) mirrors the deck on a flip, the
  hotter start, and breaks up the turret pairs whose spacing is a settled look; pairs by row (rows
  one and three, then two and four) are the calmer fallback, each half symmetric at the settled
  spacing.
- **The lance** is the Enfilade Beam's hand-built stock gun on hp_3 (`tools/lowforge/models_low.py`,
  `clydesdale`): a breech block aft, a six-sided rail down the spine and out past the head, about
  98 units long, a guard, a lit emitter at the point, pivoting at the breech. It is the
  Clydesdale's alone: anywhere else the Enfilade Beam wears the barrel class. It cannot sink into
  a hull about 20 deep. Claude's lean: it goes, its hardpoint one of the eight ports.
- **Special models**, his question: a fitted component has worn one of five classes in its
  maker's metal since 29 and 30 September, and on 28 October the models drawing stock their
  machines no longer carried (thirteen) took their classes until each model follows. The
  hand-built stock guns were kept on 2 November ("Yes to keeping hand built guns", the bible's
  hardpoints row: each machine's own look out of the box): sixteen on seven machines today, the
  Clydesdale's four the right turret's Twin Autoguns, the lance, the pocket mortar and the
  howitzer (its Maxigun, Airburst Shell and Incendiary Shells wear their classes). What rides the
  eight ports was hand-built guns rebuilt to fold and sink or classes on all eight (Claude's lean
  classes: on this machine the ports and the flip are the look, a refit then looks exactly like
  the stock, and every class must fit the ports anyway); settled as classes (Open, item 6).
- **His doubt, the same day**: "Yeah I though all hand built models went away already. What are
  left? I don't remember agreeing to keeping them, I thought the opposite. Polar bears guns are no
  longer hand built, that's certain. Something you're reading is out of date, regarding the polar
  bear if nothing else." What the repository holds: main and all seventeen other branches on
  GitHub agree, none changing the Polar Bear's guns. Its Rivet Gun and Twin
  Autoguns are built by hand in their ports' slide joints (`tools/lowforge/models_low.py`, the
  `polar_bear` build's two sockets), they are in `art/models/polar_bear.glb` (`rivet_barrel`,
  `autogun_barrel`), today's stock die shows both, and the hangar's rear render shows them; its
  swapped render shows round launchers in all four ports, the class look a refit has worn since
  2 November. The record of 2 November: commit `6638c07` quotes his "replace or fix those hand
  built stock guns", the session taking "fix" (their muzzle flares), and commit `ac16ef2`, the
  same day, wrote the hardpoints row's "Yes to keeping hand built guns". His next word: "There
  must be a session or branch that didn't push. The work done created different model shapes
  that hardpoints could request. First one was a round missile rack that fit inside the polar
  bears ports." That work is `ac16ef2` on main (the round launcher, `models_low.VARIANTS`'
  `rack_round`, and every mount's fits; its session, "Ready chassis for modeling", merged at
  `a3ef10d`, and every session since that touched a model reports merged): a variant is what a
  fitted class wears at a mount, and the same commit's renders kept the Polar Bear's hand-built
  stock guns beside its new swapped render. Asked: whether a change
  lives somewhere the repository does not (the desk's folder, a session that never pushed), and
  whether the hand-built stock guns go everywhere, every hardpoint then wearing its class in its
  maker's metal, stock or fitted, the fixed pieces still modelled in.
- **Depth**: a full-size barrel is about 34 long against 22 from the deck to the belly, so the
  vertical sink wants the mounts at about two thirds or a deeper body; failing both, guns that tip
  back flat into troughs need almost none (the old disappearing-gun carriages).
- The head's cheek mounts and the crown's pad go with all eight on the back; the head still turns.
- A debug switch flips it constantly (`RIFTGATE_FLIP_DEBUG=1`, the seal's pattern), to judge it
  running.

## The stock (Claude's proposal, unanswered)

Nine pieces to eight. The ninth, the second Twin Autoguns, is the refit's placeholder in a vent's
slot (`docs/briefs/refit_pass.md`, section 5), so it goes. The eight split cleanly: a Direct half
first (the Maxigun, the Twin Autoguns, the Enfilade Beam, the Shoring Jack) and an Indirect half
(the Ankle Mortar, the Howitzer, the Airburst Shell, the Incendiary Shells), a front-rank kit and
a back-rank kit, the flip's first lesson in the stock.

## What it touches when it lands

- The gunship's brief stands on "two Wainwright & Sutler machines that lock nothing" and asks the
  overlap by tier or by sharpening: this sharpens the Clydesdale, for that brief's session to note.
- The rows above, the rules' chassis line and dice section (Battery Director named there), the
  die's rule for a live half, and the briefs README's bench "Own rerolls as a number", whose
  example becomes the Trim Tabs.
- Shown text, his to write: the flip's name and codex, the passive's name and description (Battery
  Director's slot in the ledger goes with it).

## Open

1. The ports: eight alternating (Claude's lean), a checkerboard or pairs by row.
2. The lance: whether it goes (Claude's lean).
3. What rides the ports: settled, classes on all eight, since the hand-built stock guns go
   everywhere (item 6).
4. The stock split, and the Direct half first.
5. The names and texts.
6. The hand-built stock guns across the roster: settled 11 November, they go ("Yes I think the
   hand built guns have to go, clearly that session got cut off. My quote might have been
   misinterpreted. There's no reason to keep hand build guns anywhere"; Claude agreed, the fixed
   pieces staying modelled in). The bible's hardpoints row holds it and the to-do's Art line the
   sixteen to rebuild, lowforge running in the cloud (the README's recipe).
