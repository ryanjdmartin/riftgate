# Brief: the funnel-web (proposal reworked into a direction)

The session settles the four-legged spider as the roster's tank-buster: an opportunist that
waits on the sidelines, binds its foes and strikes with venom.

**Status**: direction (14 October). **Maker**: Wainwright & Sutler. **Proposed tier**: two.
**Read first**: `docs/briefs/README.md`; `docs/roster_analysis.md` section 4; the bible's stun
budget and Numbed rows (section 5) and its cooldown row (section 8).

## The proposal as it stood

A foe it would Suppress takes a web bomb instead, bursting at the end of that foe's turn,
Suppressing the foe and the next foe beside it (Ryan's plan, 13 October). The locked fangs:
Direct, flat, and a share of a Suppressed target's current hull more.

In full, as the go found it (12 and 13 October; Claude's unless marked Ryan's; the go reworks
it, below):

- **The shown text** (Ryan, 13 October): "A foe it would Suppress takes a web bomb instead: at
  the end of that foe's turn it bursts, Suppressing the foe and the next foe beside it." The
  web bomb is his working name, and he called the plan "a good plan". The rule it bent: a
  Suppress lands when it hits. The name: Ryan leans to the funnel-web spider (13 October),
  clear in the reserved names.
- **How it played**: the webbed foe still acts this round (the stun is no interrupt). The burst
  holds it for the next round and catches the foe beside it that acts next (foes act left to
  right), which loses its action now, before it strikes. So the trick is to web the foe
  standing just left of the threat: the burst stops the threat this round and the webbed foe
  the next, one stun taking two actions. With no foe to its right, the burst catches the one to
  its left, which loses its next action.
- **Which neighbour**: random would be noise (the burst comes in the enemy's turn, so the
  player cannot time it), a pick by the player costs a gesture, and the next to act uses the
  order the player already watches. Both neighbours, Ryan's alternative (13 October), was the
  lever if it proved weak. The plainer timing, the bomb bursting at the end of the enemy's turn
  and both foes losing the next round's action, reads easier and loses the trick.
- **The web bomb dealt nothing** (Claude's lean): the web holds and the fangs kill, one job
  each.
- **The fangs** (locked; Ryan, 13 October): "Direct, flat 10, and 20% of a Suppressed target's
  current hull more." Current hull, never maximum, so they open on a boss and never finish one;
  once a bite. They read any Suppressed foe, so the team's stuns fed them as well as its webs.
- **What it opened**: its webs came from its hardpoints, a Suppress piece of any maker laying
  them (the stock's Suppression Battery reaching the back rank, the Umbra Inducer); the payoff
  was the fangs and every blow on a foe that cannot answer. Of the team's other stuns it named,
  the Baboon's meter still stuns; the Dingo's harpoon now carries Shock and Misharu's payoff is
  Penance (both Ryan, 14 October). A web bomb is a debuff, so it fed the Baboon's Paradox as it
  landed, and the burst's two Suppresses fed it again.
- **Engine**: a Suppress this machine lands becomes a web-bomb debuff on the foe (a chip of its
  own) that bursts at the end of that foe's turn, Suppressing it and the next foe to act beside
  it; the fangs' bonus reads Suppressed and the foe's current hull, through `sim/effects.gd`.
- **Edge cases**: Numbed is checked at the burst, each foe for itself; a webbed foe killed
  before its turn takes its web with it; a webbed foe already Suppressed by the team skips its
  action and its web still bursts at its turn's end.
- **Numbers and kit** (the proposal's placeholders, set under the whole-block shield rule):
  medium, walker, move 30; hull 110, shield 40, armour 5, heat 60, cooling 5, field
  recharge 20. Locked: the Fangs (a working name), Direct, flat 10, the bonus above, heat 5.
  Four hardpoints (a d5). Its stock, today's pieces as stand-ins: Suppression Battery,
  Slugthrower, Howitzer, Laminar Deflector.
- **Set aside along the way**: the stun punish, a blow on a Suppressed foe also striking every
  other Suppressed foe (proposed at half; Ryan, 12 October: at full, stuns being rare, though
  on 13 October he called Suppress prevalent, the bible's stun budget row), retired with the
  Spinneret it served, two stuns and Rapid on one locked piece (Ryan, 13 October: broken). A
  venom version was set aside on 13 October as a separate machine, its share of hull moved onto
  the fangs; the go brings venom back as this machine's direction (below).

## What Ryan said in the go

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
  intent line disappears, wouldn't it?" (agreed).

## What Claude proposed

- Ambush and venom (14 October): its blows on a foe that will not strike it this round lay
  Venom, a share of the foe's current hull at its action, a stack, fading. A share of current
  hull is the tank-buster by construction: nothing on a goblin, a wound on a Treant, never a
  finish. Two themes only, ambush and venom; it needs a front to draw the aim, so it is a team
  machine.
- The ambush read (14 October): "a foe that will not strike the spider this round" covers a foe
  aimed at another machine, a suppressed foe and a foe making a move that strikes nobody (the
  healer while it heals), all visible on the intent before the player acts. A suppressed foe
  keeps the target it drew, so a narrower read ("aimed at another machine") would let a web
  feed nothing.
- The web as a locked piece with a cooldown (14 October): not too strong, because the web is
  delayed (the foe lands one action before it is held), venom is a share of current hull (each
  tick smaller, never a finish), each web adds Numbed (the third web on a boss fails about half
  the time), and a cooldown of two on a d5 is a real price. Alone against a pack every foe aims
  at the spider, nothing is ambushable, and it loses, which is right for a tier two. Its hard
  control sits on a locked piece rather than the passive, and is weighed under the stun row's
  rule (Ryan, 15 October: always carefully considered, other options explored first).
- The web's targets (14 October): start at the target and the next foe to act beside it, with
  the cooldown; that keeps Ryan's trick (web the foe left of the threat). Spread is the lever
  if it proves weak. Claude had first suggested dropping the neighbour, then answered Ryan's
  question with this as the starting point.

## Open for the session

1. Venom's shape and numbers (the share, stacks, fading), which are the whole balance of the
   machine.
2. The ambush read as worded, and whether the original fangs' read of a Suppressed foe survives
   beside it.
3. The web: targets, delay, cooldown length; and whether the web bomb's edge cases and its zero
   damage, as proposed (above), carry to a locked piece.
4. Two themes or three: whether web, venom and ambush are one machine.

## Holes already raised

- The Baboon, the spider and a tank together are the stunlock team the boss cells must read.
- The web's delay and the dark entry must show as counts (a timer on the foe's chip, the rounds
  on the die), or they are hidden counts.
- A share of current hull needs the foe's current hull on screen, which it is.
- The bot values neither an ambush nor a delayed stun until its valuations land.

## What the session hands back

A proposal in chat; on Ryan's go, the bible's row, content planned (Venom is a new status), the
HUD's cleared intent line, and this brief retired.
