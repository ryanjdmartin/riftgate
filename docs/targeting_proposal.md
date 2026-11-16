# The foes' targeting: the audit, what was cut, and what is proposed

Ryan, 16 November: "We need to look at foe targeting rules now, I think. Clean that up."
His mark of 15 November on the aims' row: "These need to be audited separately as an entire
subsystem."

This is that audit. Section 1 is the rules as the engine runs them today, in one place.
Section 2 reads them as a system. Section 3 is what was plain leftover and is cut. Section 4
is what the audit finds that is a design call, each with a lean, and nothing of it is built.
The decided rows it stands on are the bible's "Each foe picks its own target as the round
opens" and "Exposed is one word on both sides" (section 5) and the foes' rule set (section 9).

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

Each is a design call. Leans are Claude's.

### 4.1 "Exposed" means four things

The aim that picks the soft machine. The mark a foe lays on a machine. The status a machine
lays on a foe. And a back-rank foe whose front has fallen, which the engine calls an exposed
column. Inside the pick itself one line reads the mark and the next falls back to the aim,
under the one word.

The mark and the status are one decided word on both sides, and they stay. The aim wants
another name, in the engine and on the screen. Lean: **the weakest**. The map's hunts already
use the word for nearly the same thing, the least hull and shield, so the two layers would
say it once.

### 4.2 The aim at the exposed is a draw nobody can read

It is the one aim that draws by weight. For a blow of 10:

| The machine | Weight | Its odds among the three |
|---|---|---|
| Bare, no shield | 11 | 54% |
| A shield of 5, which the blow breaks | 8.5 | 41% |
| A shield of 15, which holds | 1 | 5% |

Between two machines, one bare and one whose shield holds, the bare one is picked eleven
times in twelve. So the rule is "the soft machine, usually". The player learns the first
half and is surprised by the rest, and nothing on the screen says which round is which. It
is the kind of randomness the design tests ask to keep out: neither seen nor shifted.

Lean: make it exact. The machine its blows would reach the most hull on, a tie drawn, as
heat draws its ties. Then it is a lever like the others: the player sees who is bare and
knows where these foes go, and under the reboot that is the machine that just rebooted.
It makes its four carriers sharper, an elite and three heroes, which is the job his words
give that kind of foe: "this guy is going to kill my unit". Never over-commit still holds.

The other way is to cut the aim and leave its four on the default. That loses the one aim
that reads the reboot.

### 4.3 Two aims fall back to it

A foe that goes for the armed finds no weapon showing and draws by the weights instead, and
the buffed the same. That is a second rule to learn inside the first. Lean: fall back to the
default, an even draw. "It goes for a weapon showing, and for anyone when none is."

### 4.4 A move at nobody still draws a pick

A foe showing a brace has a pick the player never sees. It surfaces in one place: a fall's
blow. Kill a Dread Knight while it shows Reraise and its Death Throes lands on a machine
no arrow ever named. The die held over the kill previews it, which is the one way to learn
it, and a draw the player sees only through the preview is what the rule of 26 October
retired elsewhere.

This is the open point of the vocabulary proposal's section 29, from the other side. If a
fall's single blow follows the kill, as its curse now does, no hidden pick is ever used and
the draw itself can go: a foe picks when its move aims at a machine, and a move that comes
to aim mid-round takes the next in line, as today. Lean: that.

### 4.5 Fires as one has one fight

Three back-rank heroes carry it, and a rank shares a pick only when two of them stand in
it. The party is one hero a domain, so that is the finale's last fight and nowhere else.
Everywhere else it is the aim at the exposed under another name. Lean: keep it, as the
party's own rule for that fight, and say so where it is written.

### 4.6 The words on the screen

His note of 21 October: "aims at the exposed" is cryptic. A foe's page shows its aim as a
sense, and a move's readout says it after the target. Proposals, his to write:

| Aim | Today | Proposed |
|---|---|---|
| The exposed | aims at the exposed | goes for the weakest |
| Heat | aims at heat | goes for the hottest |
| The armed | aims at the armed | goes for a weapon showing |
| The buffed | aims at the buffed | goes for the most buffed |
| Fires as one | fires as one | picks with its rank |
| Anything | aims at anything | picks anyone |

The to-do's line on these names five earlier proposals in a retired brief. That commit is
not in this clone, so these are written fresh.

### 4.7 What is clean and stays

The default and its reason. The order of the picks. Never over-commit. The commitment, and
the next machine in line. An aim on the foe with a move free to name its own. The picks on a
foe's own side. The map's hunt.

## 5. The bench: what a rule kills

- *Every jam goes for a weapon showing.* "Dictated by the effect" read all the way: a jam is
  wasted on a blank, so the effect would aim itself. Killed by the baseline of 24 October: it
  would put an aim on eleven more foes, tier one's among them.
- *A foe re-aims when its machine shields up.* Killed by the commitment of 26 October.
- *More aims in the rank and file of tiers two and three.* Not killed: his own direction, "an
  aim is the curve's targeting lever". It is content, for the tiers' pass, and wants 4.2
  settled first so the lever it pulls is one the player can read.

## 6. For Ryan

1. The aim's new name. Lean: the weakest.
2. Exact or by weight. Lean: exact, a tie drawn.
3. The fallback of the armed and the buffed. Lean: the default.
4. A fall's single blow, and with it the hidden pick. Lean: the blow follows the kill and the
   hidden pick goes.
5. The words of 4.6.
