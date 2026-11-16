# The foes' targeting: the audit, what was cut, and what is proposed

Ryan, 16 November: "We need to look at foe targeting rules now, I think. Clean that up."
His mark of 15 November on the aims' row: "These need to be audited separately as an entire
subsystem."

This is that audit. Section 1 is the rules as the engine runs them today, in one place.
Section 2 reads them as a system. Section 3 is what was plain leftover and is cut. Section 4
is what the audit finds that is a design call, each with a lean, and nothing of it is built.
The decided rows it stands on are the bible's "Each foe picks its own target as the round
opens" and "Exposed is one word on both sides" (section 5) and the foes' rule set (section 9).

He read section 4 in the abstract and asked to see it in a fight (16 November: "I think I
need to see these targeting rules in context to understand the issue you're presenting").
The scenes are a page, https://claude.ai/artifact/9UTL3VqdoHVVGfodtBv124: each rule on the
game's own screen, with the engine's draws counted beside it. The counts are in
`docs/measurements.md` (16 November, the foes' aims in context). What they showed is folded
into section 4, and it moved two leans: what the aim at the exposed should do, and with it
the aim's name.

## 1. The rules as they run

**The pick, as the round opens.** The dice roll, then the foes announce in the order they
strike, the front rank left to right and then the back. Each announces its move, then draws
its pick.

| Step | Rule |
|---|---|
| The default | Any machine in the fight, each as likely as another. 99 of the 121 foes pick so |
| An aim | The foe's, or the move's own where it names one, reads the team in its place. Fourteen foes and two moves name one, below, and the eight heroes' promoted forms take their hero's |
| Never over-commit | A machine the blows already drawn this round would wreck is passed over while another stands |
| The mark | A machine that stands Exposed takes every aimed pick, whatever the aim, until the blows drawn would wreck it |
| A carried pick | A countdown's pick holds from the round before while its machine stands |
| A move at nobody | A brace, a rally, a blow at every machine: the foe draws a pick all the same and shows none |

**The aims.**

| Aim | It picks | When none qualifies | Who carries it |
|---|---|---|---|
| Anything | Any machine, evenly | | Every foe that names no aim, and the Martial Artist's Hundred Fists |
| The exposed | A draw by weight: one, plus the hull its blows would reach, plus half of any shield they would break | | The Bone Wyvern; the Warrior, the Martial Artist, the Lancer |
| Heat | The hottest machine, a tie drawn | | The Red Dragon; the Black Mage |
| The armed | A machine showing an intact weapon or debuff, drawn among them | The exposed | The Basilisk, the Gorgon; the Rust Monster, Gilgamesh; the Thief |
| The buffed | The machine carrying the most stacks of buffs, a tie drawn | The exposed | The Djinn's Unmake |
| Fires as one | The pick its rank already shares, the first of them drawing by the exposed | | The Cleric, the Augur, the Summoner |

Three of the fourteen are rank and file: the Basilisk at tier two, the Gorgon and the Red
Dragon at tier three. The rest are three elites and eight heroes, which is every hero.

**After the pick.** The pick is a commitment: smart as it is made, never after.

| What happens | Where the pick goes |
|---|---|
| A Lure | The spender. A move at nobody keeps doing what it does |
| A Disrupt | It holds. It is drawn again only when the machine is gone or out of the fight, or the move it left aimed at nobody |
| Its machine is Swallowed | The next machine in line |
| Its machine is gone or out of the fight as the foe acts | The next machine in line, left to right, whatever the aim |
| The round preview | Never moves a pick |

**At a fall.** A fall's blow lands on the foe's own pick. A curse lands on the machine that
made the kill, and on nobody when no machine did (his ruling of 16 November).

**On its own side.** A heal goes to the most hurt of its own, a cleanse to the most marked,
a readying to a hero first and then the heaviest hitter, a summon to the empty slot nearest
its caller. Each is exact. None draws.

**On the map.** A hunting pack locks one machine as it appears, by its composition's caveat:
the nearest, the weakest, the strongest or the slowest. One hunter a machine. It is the
other targeting rule in the game, and it is clean: twelve packs, four caveats, each carried.

## 2. Read as a system

Targeting decides where the foes' damage lands, and it has three layers.

1. *The baseline.* An even draw, shown and committed, that never wrecks a machine twice
   over. It protects nobody and hunts nobody. The numbers are balanced on it, which is why it
   reads nothing of the team (his reason, 24 October: with a rule on every foe "it's
   impossible to get a true baseline that's agnostic of player composition"). The player's
   answers are the ones every blow has: mitigation on the machine shown, a kill, a Suppress,
   a Lure.
2. *An aim.* It sends one foe's damage at a state the team controls: heat, the entry a die
   shows, the buffs a machine carries, the machine with no shield. So it asks its own
   question, and the answer is to change that state. But the pick is drawn as the round
   opens, so most of those states were set the turn before. An aim is answered a round
   ahead, or in the round by a Lure.
3. *The mark.* Exposed sends the whole field at one machine, announced a round ahead, and
   stops at the machine's predicted death.

What holds the three together is the commitment. Nothing a foe does reacts to the player's
turn, so every answer the player makes sticks, and the preview is exact.

What the layers need from each other: an aim is only a lever if the player can read it. A
rule they cannot predict is the baseline with a worse name.

## 3. Cut, 16 November

Leftovers by the rule of 12 November: a rule leaves the engine with its last piece.

- **The rule before 2 October.** Every foe on the machine with the lowest shield. The engine
  kept it behind a switch "for the balance runner's comparison and nothing else", and the
  runner replayed the team's whole row under it on every run to print a section nobody has
  read a decision off since. Gone: the switch, its branch in the pick, the runner's flag and
  section, the README's line and the test of it. `docs/balance.md` keeps the section of its
  last run until the next one.
- **The fastest hunt.** A caveat on the map's list that no pack hunts by.
- **A test holds both lists to content** (`tests/test_leftovers.gd`): an aim no foe or move
  carries, or a caveat no pack hunts by, fails the build.

## 4. What the audit finds

Each is a design call. Leans are Claude's. The counts are on a squad of four, the Honey
Badger (36 hull, 6 shield, 1 armour), the Skua (20 and 9), the Cassowary (24 and 6) and the
Buzzard (28 and 12): a prepared opening is one position opened 2000 times, a whole fight a
real composition at its tier, 300 fights by the greedy bot.

### 4.1 "Exposed" means four things

The player reads the word in four places. A foe's aim: "aims at the exposed". The status our
Expose lays on a foe. The status a foe's Expose lays on a machine, the mark. And a reach
rule: "any back-rank foe whose column is exposed". Inside the pick itself one line reads the
mark and the next falls back to the aim, under the one word.

The two statuses are one decided word on both sides, and they stay. The reach rule is plain
language. The aim wants another name, in the engine and on the screen, and the name follows
4.2. Lean: **the broken**, if the aim comes to read a broken shield. **The weakest**, the
map's word for nearly the same thing, if it keeps reading hull.

### 4.2 The aim at the exposed picks like chance

It is the one aim that draws by weight: one, plus the hull the blow would reach, plus half
of any shield it would break. With the Skua's shield broken and the rest whole:

| The foe's blow | Honey Badger | Skua, broken | Cassowary | Buzzard |
|---|---|---|---|---|
| The Bone Wyvern at tier two, 19 | 24% | 33% | 24% | 19% |
| The Lancer, 10 | 26% | 43% | 28% | 3% |
| An even draw | 25% | 25% | 25% | 25% |

It behaves three ways, and the screen shows none of them.

- *A blow that breaks every shield is near chance.* The Wyvern's weights are 16, 20, 17 and
  14.
- *A shield that holds the whole blow takes its machine out of the draw.* The Buzzard's 12
  against a blow of 10 weighs one.
- *A hurt machine is passed over.* The weight counts only the hull left to reach. Against a
  blow of 19, a broken machine with 15 hull left weighs 16, the same as the Honey Badger
  whole, and less below that.

In whole fights the three cancel. The Bone Wyvern's Flight at tiers two and three, 600
fights: 1403 times the Wyvern drew with a broken shield standing beside a whole one, and it
picked a broken one 411 times, 29%, where an even draw gives 30%. With every shield up it
picked the softest machine 30% of the time against 28% by chance. So the page says it aims
and the play shows a coin, which is the kind of randomness the design tests ask to keep out:
neither seen nor shifted.

An earlier form of this section said a bare machine is picked eleven times in twelve. That
was a built case of two machines, one bare and one whose shield holds the whole blow. It
does not describe a fight.

Four ways on:

| | The rule | In the scene, the Skua broken | With every shield up |
|---|---|---|---|
| a | The weights, as today | the Skua one time in three | near even |
| b | The most hull reached, a tie drawn | the Skua | the Cassowary, every round |
| c | A machine whose shield is broken, an even draw among them; anyone when every shield stands | the Skua | anyone |
| d | Cut the aim: its four carriers pick anyone | anyone | anyone |

Lean: **c**. It is heat's shape on the reboot's own state, which the screen already marks:
the dashed bar, the chip under the machine, the log's line. The lean was b before the
scenes. b fixes on one machine while every shield is up, which is close to the rule retired
on 2 October, back on four foes; it reads sums the player cannot see; and unless its cap
goes it still turns from a machine low on hull.

**c as a system**, before any run (targeting is a fundamental):

- *Whom it threatens.* The machine whose shield has broken and that has not rebooted. Its
  four carriers' aimed blows go to it for certain, from the round after the break.
- *Whom it protects.* Every machine whose shield stands. With no shield broken these foes
  are the default.
- *What the reboot does to it.* The picks are drawn before the player chooses a reboot, and
  a rebooted machine opens the next round whole. So no aim ever sees a rebooting machine: a
  reboot ends the hold a round later and never draws it. The blow already shown lands on the
  broken machine bare either way.
- *The player's answers.* The ones every arrow has, a Lure, a Barrier, a Suppress, the kill;
  the reboot, at the price of one certain blow; and keeping a point of shield, since a
  shield at one is not broken.
- *Its cliff.* A shield at one draws nothing and a shield at nothing draws all of it. It is
  the reboot rule's own cliff, and b has none.
- *What it does to the numbers.* A blow that breaks a shield is followed by a certain one on
  hull. The Wyvern's 19 takes the Skua's shield and 10 of its 20 hull, then the rest the
  round after: two blows, where the default lands both on one machine one time in four. That
  is "this guy is going to kill my unit" as his words give the kind, and it is a number for
  the carriers' blows as much as for the aim. Their blows are read again with it, a small
  model first and then the runner. No new foe is needed.

Never over-commit holds under each of the four.

### 4.3 The fallback of the armed and the buffed

The armed works as written. Over three compositions, 1200 fights and 5889 picks, it ruled a
machine out in 69% of them and every one of those picks showed a weapon; in 31% every
machine showed one and the draw was even. It follows the dice: the picks are drawn after the
roll and before a reroll, so the player reads it and cannot steer it. That is its job, to
keep a jam or a corrupt off an entry that is no weapon.

Its loose end is the fallback. With no weapon showing it draws by the weights of the
exposed, a second rule inside the first: 28 picks of the 5889, one in two hundred.

The buffed has the same fallback and cannot reach it. The Djinn's Unmake is only open while
a machine carries a buff, so in 159 picks a buffed machine stood every time; the fallback
fires only when every buffed machine is already wrecked that round.

Lean: fall back to the default, an even draw. "It goes for a weapon showing, and for anyone
when none is." With 4.2 at c or d the weights then leave the engine altogether, as a rule
does with its last piece.

### 4.4 A move at nobody still draws a pick

A foe showing a brace has a pick the player never sees. It surfaces in one place: a fall's
single blow. Kill a Dread Knight while it shows Reraise and its Death Throes lands on a
machine no arrow ever named. In the scene it breaks the shield of a Cassowary nothing was
aimed at. The die held over the kill previews it, which is the one way to learn it, and a
draw the player sees only through the preview is what the rule of 26 October retired
elsewhere.

In the Lich's Court at tier three, 300 fights, 256 Dread Knights fell and 24 of them fell on
a round they showed no arrow. The Dread Knight is the only foe whose fall is a single blow
today; the Gargantuan King's Meteor lands on every machine.

| | Where the blow lands |
|---|---|
| a | The foe's own pick, shown or not, as today |
| b | The machine that made the kill, as a curse does since his ruling; nobody when no machine made it. The hidden pick leaves the engine: a foe picks when its move aims at a machine, and a move that comes to aim mid-round takes the next in line, as today |
| c | The foe's own pick, always shown: a foe with a last act draws its arrow on a move at nobody too |

Lean: b. It is the open point of the vocabulary proposal's section 29 from the other side,
and it makes the last act a choice: who delivers the kill takes the blow, and a kill by a
tick dodges it.

### 4.5 Fires as one has one fight

Three back-rank heroes carry it, and a rank shares a pick only when two of them stand in
it. The party is one hero a domain, so that is the finale's last fight and nowhere else.
Everywhere else it is the aim at the exposed under another name: the first of the rank
draws by the weights. Lean: keep it, as the party's own rule for that fight, say so where it
is written, and let its first pick be drawn as anyone's is if the weights go.

### 4.6 The words on the screen

His note of 21 October: "aims at the exposed" is cryptic. A foe's page shows its aim as a
sense, and a move's readout says it after the target ("Target: Buzzard, aims at the
exposed"). Proposals, his to write:

| Aim | Today | Proposed |
|---|---|---|
| The exposed | aims at the exposed | goes for a broken shield (goes for the weakest, if 4.2 keeps to hull) |
| Heat | aims at heat | goes for the hottest |
| The armed | aims at the armed | goes for a weapon showing |
| The buffed | aims at the buffed | goes for the most buffed |
| Fires as one | fires as one | picks with its rank |
| Anything | aims at anything | picks anyone |

The to-do's line on these names five earlier proposals in a retired brief. That commit is
not in this clone, so these are written fresh.

### 4.7 What is clean and stays

The default and its reason. The order of the picks. Never over-commit. The commitment, and
the next machine in line. Heat, the model for what an aim is: one state on the screen, an
even draw among the machines that match. In 600 fights of two tier-three formations the Red
Dragons drew 2593 picks and 2582 went to a hottest machine, the other 11 passing over a
machine already wrecked; one machine alone was hottest in 58% of the draws, and every
machine was cold in 35%. The mark, which no foe lays yet. An aim on the foe with a move free
to name its own. The picks on a foe's own side. The map's hunt.

## 5. The bench: what a rule kills

- *Every jam goes for a weapon showing.* "Dictated by the effect" read all the way: a jam is
  wasted on a blank, so the effect would aim itself. Killed by the baseline of 24 October: it
  would put an aim on eleven more foes, tier one's among them.
- *A foe re-aims when its machine shields up.* Killed by the commitment of 26 October.
- *The most hull reached, exact.* 4.2's b, the lean before the scenes. Killed by no rule:
  set aside for what the scenes showed, and his to take up.
- *More aims in the rank and file of tiers two and three.* Not killed: his own direction, "an
  aim is the curve's targeting lever". It is content, for the tiers' pass, and wants 4.2
  settled first so the lever it pulls is one the player can read.

## 6. For Ryan

1. The aim's name. Lean: the broken, with the second call at c.
2. What the aim at the exposed does. Lean: c, a machine whose shield is broken, anyone when
   every shield stands.
3. The fallback of the armed and the buffed. Lean: the default.
4. A fall's single blow, and with it the hidden pick. Lean: b, the blow follows the kill and
   the hidden pick goes.
5. The words of 4.6.
