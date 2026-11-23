#!/usr/bin/env python3
"""What the tide asks of four machines on the long wall. Apart from the game's content.

Ryan, 23 November, after his play of the field's dials: "I would rather more packs on the map
... so that I can choose where to attack and what to let through, instead of just hovering by a
spawn point and fighting whatever pops out"; "Fodder should pose a threat by quantity, not by
hard hits"; and of the packs, "I'd rather they don't start so close but reach the wall faster".
And the rule this model is built under (13 November): a fundamental is reasoned as a system,
with a simple model apart from content, before it is run against the game as it stands.

The question is coverage alone: how many packs, of what rating, from which mouths and at what
pace, make four machines unable to answer them all, so that what to let through is a choice.
The model plays that and nothing else:

  - The field is the wall's twenty columns by a depth in rows, bare ground. A pack walks its
    pace a turn to the stretch of wall it reaches soonest (the game's rule since 23 November),
    and strikes the wall for ten a pip of its rating every turn it stands there.
  - Four machines, moves 3, 4, 5 and 6, open before the gate. A machine has one action a turn:
    it walks, then fights the pack it stands beside. A pack falls the turn as many machines as
    its rating fight it together; fewer do nothing to it. A fight costs nothing: no hull, no
    heat, no dice. So every cell here is the tide at its kindest.
  - The player is greedy and sees everything: each turn the packs nearest their strike are
    answered first by the machines that reach them, and a machine with nothing in reach walks
    toward the most urgent pack still short of machines, to meet it at the wall.
  - The tide is the game's: an opening of one formation a move from the wall and a patrol two
    moves out on each flank, then a peak every third turn, the rift sending the next of its
    cycle and every open tear a patrol, a tear opening a peak on a row that steps toward the
    wall. No hunters, no elites, no boss, no Rupture: twelve turns of the tide and its count.
  - A table is a tide with no middle (docs/tide_proposal.md): packs for one machine through
    tears across the whole width with the rift sending none, against the same packs through
    the rift, for a squad free to go where it will and one that holds a post.
  - Its last table is the fodder tide as the trial deals it (Battlefield.fodder_tide; his
    paradigm of the same day): every formation come apart into packs for one machine and for
    two, the tears sending a patrol and a fodder pack in turn, tears open across the width
    from the first turn, and the wall struck for five a pip.

What it cannot say: what a fight costs, so whether a pack is worth a machine; how long a fight
takes to play; what a hunter does to a squad spread this thin. Read a column against its
neighbours, never as a number: where the leak starts, and which dial moves it.

    python3 tools/tide_model.py                # the tables, as markdown
    python3 tools/tide_model.py --trials 600   # steadier cells
"""
import argparse
import math
import random

WALL = 20
TURNS = 12
BEAT = 3
MOVES = (3, 4, 5, 6)
STRIKE = 10


def axial(col, row):
    return (col - (row - (row & 1)) // 2, row)


def offset(q, r):
    return (q + (r - (r & 1)) // 2, r)


def dist(a, b):
    (aq, ar), (bq, br) = axial(*a), axial(*b)
    return (abs(aq - bq) + abs(ar - br) + abs(aq + ar - bq - br)) // 2


def toward(a, b, steps):
    """The hex `steps` along the straight way from a to b, b itself when it is nearer."""
    d = dist(a, b)
    if d <= steps:
        return b
    (aq, ar), (bq, br) = axial(*a), axial(*b)
    t = steps / d
    x, z = aq + (bq - aq) * t + 1e-6, ar + (br - ar) * t + 2e-6
    y = -x - z
    rx, ry, rz = round(x), round(y), round(z)
    dx, dy, dz = abs(rx - x), abs(ry - y), abs(rz - z)
    if dx > dy and dx > dz:
        rx = -ry - rz
    elif dy <= dz:
        rz = -rx - ry
    return offset(rx, rz)


class Pack:
    def __init__(self, at, rating, pace):
        self.at = at
        self.rating = rating
        self.pace = pace
        self.goal = None
        self.struck = False


class Field:
    def __init__(self, depth, rng, leash=0, camp="gate", strike=STRIKE):
        self.depth = depth
        self.apron = depth - 3
        self.rng = rng
        self.strike = strike   # what a pip strikes the wall for
        self.leash = leash   # the hexes from its post the squad keeps within; 0 for a free squad
        self.home = (WALL // 2, self.apron if camp == "gate" else 3)   # the post: the gate's front, or the rift's
        self.packs = []
        self.tears = []
        self.tear_row = min(4, max(2, math.ceil(depth / 5))) + 1
        self.machines = [(8 + i, self.apron) for i in range(4)]
        self.sent = self.killed = self.struck_packs = self.gate = self.fights = 0
        self.pips_sent = self.pips_killed = 0

    def deal(self, at, rating, pace, part=0, parts=1):
        p = Pack(at, rating, pace)
        turns = {}
        for col in range(WALL):
            turns[col] = math.ceil(dist(at, (col, self.apron)) / pace)
        fewest = min(turns.values())
        cols = [c for c in range(WALL) if turns[c] == fewest]
        if parts > 1 and len(cols) >= parts:
            cols = cols[len(cols) * part // parts:len(cols) * (part + 1) // parts]
        want = self.rng.choice(cols)

        def crowd(col):
            return sum(2 if q.goal == col else (1 if abs(q.goal - col) == 1 else 0) for q in self.packs)
        p.goal = min(cols, key=lambda c: (crowd(c), abs(c - want)))
        self.packs.append(p)
        self.sent += 1
        self.pips_sent += rating

    def open_tear(self):
        """On the tears' row, the column farthest from the rift and every open tear."""
        def clear(col):
            at = (col, self.tear_row)
            return min([dist(at, (WALL // 2, 0))] + [dist(at, t) for t in self.tears])
        best = max(range(WALL), key=lambda c: (clear(c), self.rng.random()))
        self.tears.append((best, self.tear_row))

    def turns_to_strike(self, p):
        return math.ceil(dist(p.at, (p.goal, self.apron)) / p.pace)

    def player(self):
        """The squad's turn: the packs nearest their strike first. A pack falls when as many free
        machines as its rating reach it this turn, the slowest that can; then each machine left
        walks toward the most urgent pack still short of machines, to its stretch of wall when
        that is the nearer meeting or the pack strikes next turn, else to the pack itself."""
        free = list(range(4))
        urgent = sorted(self.packs, key=lambda q: (self.turns_to_strike(q), -q.rating))
        if self.leash:   # a squad that holds the middle answers only what comes inside its leash
            urgent = [q for q in urgent if dist(q.at, self.home) <= self.leash]
        for p in urgent:
            near = sorted((i for i in free if dist(self.machines[i], p.at) - 1 <= MOVES[i]), key=lambda i: MOVES[i])
            if len(near) < p.rating:
                continue
            for i in near[:p.rating]:
                self.machines[i] = p.at
                free.remove(i)
            self.packs.remove(p)
            self.killed += 1
            self.pips_killed += p.rating
            self.fights += p.rating
        for p in urgent:
            if p not in self.packs:
                continue
            wall = (p.goal, self.apron)
            for i in sorted(free, key=lambda j: dist(self.machines[j], wall) / MOVES[j])[:p.rating]:
                at = self.machines[i]
                meet = wall if dist(at, wall) > dist(at, p.at) or self.turns_to_strike(p) <= 1 else p.at
                if self.leash and dist(meet, self.home) > self.leash:
                    meet = p.at
                self.machines[i] = toward(at, meet, MOVES[i])
                free.remove(i)

    def enemy(self):
        for p in self.packs:
            p.at = toward(p.at, (p.goal, self.apron), p.pace)
            if p.at[1] >= self.apron:
                self.gate += self.strike * p.rating
                if not p.struck:
                    p.struck = True
                    self.struck_packs += 1


def front(rng, depth=14, pace=3, mouths=6, rate=3, leash=0, camp="gate", through_rift=False):
    """A tide with no middle: `mouths` tears stand open across the width from the first turn, on
    the tears' row, and `rate` packs for one machine come a turn, each through the next mouth
    in turn, standing the turn they land; the rift sends nothing. `through_rift` sends the same
    packs through the rift instead, to read the same count with a middle. `leash` keeps the
    squad within that many hexes of its post, `camp` the gate's front or the rift's."""
    f = Field(depth, rng, leash, camp)
    if leash and camp == "rift":
        f.machines = [(8 + i, 3) for i in range(4)]
    at = [((WALL * (2 * k + 1)) // (2 * mouths), f.tear_row) for k in range(mouths)]
    for k in range(mouths):   # the siege under way: a pack a mouth, two moves out (down the middle when the rift sends all)
        col = WALL // 2 - mouths // 2 + k if through_rift else at[k][0]
        f.deal((col, max(1, f.apron - 2 * pace)), 1, pace)
    turn_mouth = 0
    for turn in range(TURNS):
        f.player()
        f.enemy()
        for i in range(rate):
            if through_rift:
                f.deal((WALL // 2, 2), 1, pace, i, rate)
            else:
                f.deal(at[turn_mouth % mouths], 1, pace)
                turn_mouth += 1
    return f


def battle(rng, depth=12, pace=2, tide=1, split=False, flank_tears=0, rift_sends=1, opening=1, fodder=False, strike=STRIKE, leash=0, camp="gate"):
    """One battle's tide. `tide` multiplies the opening, the rift's sends and the tears a peak;
    `split` deals every formation as three packs rated one; `opening` is the moves out the
    opening's formation stands (its patrols one more); `flank_tears` stand open from the first
    turn, evenly across the width (two at the wall's ends). `fodder` is the trial's tide: a
    formation comes apart into packs for one and for two (three ones, or a one and a two), the
    opening's stood six columns apart, and every tear sends a patrol and a fodder pack in turn,
    the pack for two one time in three. `strike` is what a pip strikes the wall for; `leash`
    and `camp` hold the squad to a post (Field)."""
    f = Field(depth, rng, leash, camp, strike)
    if leash and camp == "rift":
        f.machines = [(8 + i, 3) for i in range(4)]

    def send(at, rating, part=0, parts=1, spread=0):
        if fodder and rating == 3:
            ways = rng.choice(([1, 1, 1], [1, 2], [2, 1]))
            for k, r in enumerate(ways):
                col = min(WALL - 1, max(0, at[0] + (spread * (2 * k - (len(ways) - 1))) // 2))
                f.deal((col, at[1]), r, pace, part * len(ways) + k, parts * len(ways))
        elif split and rating == 3:
            for k in range(3):
                f.deal(at, 1, pace, part * 3 + k, parts * 3)
        else:
            f.deal(at, rating, pace, part, parts)

    for k in range(tide):
        send(((WALL * (k + 1)) // (tide + 1), max(1, f.apron - opening * pace)), 3, spread=6)
    for k in range(2 * tide):
        inset = (k // 2) * 3
        f.deal((inset if k % 2 == 0 else WALL - 1 - inset, max(1, f.apron - (opening + 1) * pace)), 1, pace)
    for k in range(flank_tears):
        f.tears.append((((WALL - 1) * k) // max(1, flank_tears - 1), f.tear_row))
    cycle = [3, 1]
    at_cycle = 0
    at_tear = 0
    pressure = BEAT - 1
    stop = max(f.tear_row, f.apron - 4)   # the tears' row never within four rows of the wall

    def peak():
        nonlocal at_cycle, at_tear
        n = tide * rift_sends
        for i in range(n):
            send((WALL // 2, 2), cycle[at_cycle % len(cycle)], i, n)
            at_cycle += 1
        for t in list(f.tears):
            f.deal(t, (2 if rng.random() < 1 / 3 else 1) if fodder and at_tear % 2 == 1 else 1, pace)
            at_tear += 1
        f.tear_row = min(f.tear_row + 1, stop)
        for i in range(tide):
            f.open_tear()

    for turn in range(TURNS):
        f.player()
        pressure += 1
        f.enemy()
        if pressure >= BEAT:
            pressure = 0
            peak()
    return f


def read(trials, seed, play=None, **kw):
    tot = {"packs": 0.0, "pips": 0.0, "killed": 0.0, "struck": 0.0, "gate": 0.0, "busy": 0.0}
    for t in range(trials):
        f = (play or battle)(random.Random(seed * 7919 + t), **kw)
        tot["packs"] += f.sent
        tot["pips"] += f.pips_sent
        tot["killed"] += f.pips_killed / max(1, f.pips_sent)
        tot["struck"] += f.struck_packs / max(1, f.sent)
        tot["gate"] += f.gate
        tot["busy"] += f.fights / (4.0 * TURNS)
    return {k: v / trials for k, v in tot.items()}


def row(label, r):
    return "| %s | %.0f | %.0f | %.0f%% | %.0f%% | %.0f | %.0f%% |" % (label, r["packs"], r["pips"], 100 * r["killed"], 100 * r["struck"], r["gate"], 100 * r["busy"])


HEAD = "| The tide | Packs sent | Pips sent | Pips killed | Packs that struck | Gate lost | Actions spent fighting |\n|---|---|---|---|---|---|---|"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=300)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()
    n, s = a.trials, a.seed
    print("Twelve turns of the tide against four machines that fight for free (tools/tide_model.py, %d battles a row).\n" % n)
    print("**The count.** The game's tide, then more of it, then every formation dealt as three packs rated one.\n")
    print(HEAD)
    for label, kw in [
        ("As built", {}),
        ("TIDE ×2", {"tide": 2}),
        ("TIDE ×3", {"tide": 3}),
        ("As built, formations split", {"split": True}),
        ("TIDE ×2, formations split", {"tide": 2, "split": True}),
        ("TIDE ×3, formations split", {"tide": 3, "split": True}),
    ]:
        print(row(label, read(n, s, **kw)))
    print("\n**The pace and the depth.** At TIDE ×2 with formations split, the opening a move farther out.\n")
    print(HEAD)
    for depth in (12, 14, 16):
        for pace in (2, 3, 4):
            print(row("%d deep, pace %d" % (depth, pace), read(n, s, tide=2, split=True, depth=depth, pace=pace, opening=2)))
    print("\n**The mouths.** Fourteen deep at pace 3, formations split, the opening a move farther out.\n")
    print(HEAD)
    for label, kw in [
        ("TIDE ×1", {}),
        ("TIDE ×1, two flank tears", {"flank_tears": 2}),
        ("TIDE ×1, the rift sends 2", {"rift_sends": 2}),
        ("TIDE ×1, the rift sends 2, two flank tears", {"rift_sends": 2, "flank_tears": 2}),
        ("TIDE ×2", {"tide": 2}),
        ("TIDE ×2, two flank tears", {"tide": 2, "flank_tears": 2}),
    ]:
        print(row(label, read(n, s, depth=14, pace=3, split=True, opening=2, **kw)))
    print("\n**A tide with no middle.** Three packs for one machine a turn, fourteen deep at pace 3: through the rift, or through six tears across the width with the rift sending none; a squad free to go where it will, one camped within four hexes of the rift, or one holding within four of the gate. (A squad camped on a rift that sends everything is his play's to say, 23 November: it won; this model has no fight to cost the squad that splits.)\n")
    print(HEAD)
    for label, kw in [
        ("Through the rift, the squad free", {"through_rift": True}),
        ("Through six tears, the squad free", {}),
        ("Through six tears, the squad camped on the rift", {"leash": 4, "camp": "rift"}),
        ("Through six tears, the squad holding the gate", {"leash": 4}),
        ("Through six tears, four packs a turn, the squad free", {"rate": 4}),
        ("Through four tears, the squad free", {"mouths": 4}),
    ]:
        print(row(label, read(n, s, play=front, **kw)))
    print("\n**The fodder tide.** The trial's tide (FORMATIONS on FODDER), twelve deep at pace 2: every formation as packs for one machine and for two, the tears sending a patrol and a fodder pack in turn. A pack for two still wants two machines here; in the game one machine may take it alone, at a price.\n")
    print(HEAD)
    for label, kw in [
        ("As built, the wall struck for ten a pip", {}),
        ("The fodder tide, ten a pip", {"fodder": True}),
        ("The fodder tide, five a pip", {"fodder": True, "strike": 5}),
        ("His set: fodder, two tears from the start, five a pip", {"fodder": True, "strike": 5, "flank_tears": 2}),
        ("The set, four tears from the start", {"fodder": True, "strike": 5, "flank_tears": 4}),
        ("The set, TIDE ×2", {"fodder": True, "strike": 5, "flank_tears": 2, "tide": 2}),
        ("The set, the squad holding the gate", {"fodder": True, "strike": 5, "flank_tears": 2, "leash": 4}),
        ("The set, the squad camped on the rift", {"fodder": True, "strike": 5, "flank_tears": 2, "leash": 4, "camp": "rift"}),
        ("The set with four tears, the squad holding the gate", {"fodder": True, "strike": 5, "flank_tears": 4, "leash": 4}),
    ]:
        print(row(label, read(n, s, **kw)))


if __name__ == "__main__":
    main()
