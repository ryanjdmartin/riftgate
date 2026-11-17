# The foes' targeting, afresh

Ryan, 17 November, on the audit this page used to hold:

> When I said we need to review targeting, I meant let's make it good and fun and make sense
> and not try to "fix" what was already there, since those rules were built for what is
> basically a completely different game, and was a placeholder system anyway that kind of got
> folded in as a feature.
>
> I said it before, when I proposed random targeting, that Slice and Dice is a pretty close
> analog to our enemies, and that game has a ton of depth with just random, don't overkill,
> and a spattering of "target highest HP" and "target lowest HP." We don't need to copy that
> verbatim, but when you need a 10 page document to detail our targeting rules, something
> seems very wrong to me.

And of the Red Dragon: "the dragon does not change targets after declaring, and ... the heat
target is a property of the attack, not the dragon itself."

The audit's five calls are withdrawn with the frame that made them (`git show
0101e14d:docs/targeting_proposal.md`). This is the proposal in their place, and nothing of it
is built. It stands on his rule of 24 October: "Take away, balance, then add where
appropriate."

## The whole of it

1. **Anyone.** An attack at one machine picks it at random as the round opens. The arrow shows
   the pick before the player acts.
2. **Never overkill.** The foes pick in the order they strike, and a machine the blows already
   drawn would wreck is passed over while another stands.
3. **A word on the attack.** A few attacks say whom they go for, in plain words on their own
   line: the most or the least of one thing on the screen, a tie drawn at random.
4. **The mark.** A machine that stands Exposed draws every aimed attack, up to the blows that
   would wreck it.
5. **The commitment.** A pick never moves by itself once it is shown. A Lure moves it, and a
   machine that is gone hands it to the next in line.

Lines 1, 2, 4 and 5 are decided and built. Line 3 is the part to settle.

## The words

| The attack goes for | It picks | What it asks of the player | The answer |
|---|---|---|---|
| The strongest | The most hull and shield left | Where does the big blow land? | Plate and a Barrier where it is known to land |
| The weakest | The least hull and shield left | Can the hurt machine be kept alive? | A Lure, a Barrier, the kill, a reboot for its shield |
| The hottest | The most heat | Who is riding heat? | The reboot |

- The first two are Slice and Dice's. The third is ours and is in the game.
- Hull and shield together, as the map's hunt already measures its weakest and strongest.
- A tie is drawn at random. So with every machine level the word is line 1, and nothing
  needs a fallback.
- The word belongs to the attack. One foe may carry a seeking breath and a plain claw, and a
  foe has no aim of its own.
- A guide for content: the strongest makes a big blow fair, since it lands on the plate and
  levels the squad. The weakest makes a small blow dangerous, and on a big one wrecks a light
  machine in two rounds.

## What goes

- A foe's own aim, and the sense on its page.
- The aim at the exposed. It drew by weight, and over 600 fights it picked a broken shield no
  more often than chance (`docs/measurements.md`, 16 November).
- The armed. A jam or a corrupt picks anyone, and one that lands on an entry that is no weapon
  is the roll's.
- Fires as one.
- Both fallbacks, with nothing left to fall back from.
- The pick a move at nobody draws, if the question below goes as leaned.

## What it needs

- **Which attacks carry a word.** Take away first: every aim goes but heat's. The Red
  Dragon's Breath and the Black Mage's Fire and Flare keep it as their own; the Red Dragon's
  Crush picks anyone. The Djinn's Unmake goes for the most buffed machine, since a dispel has
  nothing to take elsewhere. The strongest and the weakest are added where a foe's threat
  calls for one, move by move for his marks, in the tiers' pass and each elite's, boss's and
  hero's own session. Until then their attacks pick anyone.
- **One question: a blow a foe lands as it dies.** Only the Dread Knight has one today, its
  Death Throes for 8. It lands on the machine the Dread Knight was aiming at that round, which
  the player sees as its arrow. On a round it is not attacking, showing Reraise, it has no
  arrow, yet the engine has drawn it a target all the same and the blow lands there: 24 of 256
  of its deaths in the Lich's Court. A death curse already lands on the machine that made the
  kill, by his ruling. Two ways to close it. Lean: the blow lands on the killer too, one rule
  for everything a dying foe does to one machine, so the player picks who pays by picking who
  takes the shot, and a kill by a tick pays nothing; then no move at nobody draws a target.
  The other: keep the arrow's rule and draw the arrow on every round, attacking or not.
- **The words on the screen** are his, for his terminology pass: the line an attack shows in
  place of "aims at heat".

## The bench

- *Goes for a broken shield.* The reboot's other gauge. Set aside: the weakest already reads
  the shield, and three words are enough to start.
- *Goes for whoever hit it last.* A grudge the player steers by choosing who shoots. A fourth
  word if a boss wants one.
- *The machine opposite its column.* Needs position to matter inside a fight, which it does
  not today.
