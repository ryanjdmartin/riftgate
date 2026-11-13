#!/usr/bin/env python3
"""A small model of the shield, apart from the game's content.

Ryan, 13 November: "we need to be thinking theoretically and critically about the system as a
whole and how it fits together, and build simple models perhaps, before slamming it against the
whole game as it stands"; "not just how hard the foes hit, but HOW they hit that matters".

Four machines stand in a fight, one plated and three light. A pack deals the same damage every
round, and only its shape changes: one blow, two strikes, a swarm, a cleave, a blow at the same
machine every round. The shield runs under one of several rules. Nothing else of the game is
here: no dice, no heat, no kills, no content. So the tables say what a rule does with a shape,
never what a fight costs.

    python3 tools/shield_model.py            # the tables, as markdown
    python3 tools/shield_model.py --trials 20000 --rounds 5 --damage 16

What it prints:
  1. Of the damage dealt, the share that reaches a hull, by the foes' shape and the shield's rule.
  2. Machines wrecked a fight, the same way.
  3. What a tool saves a fight, in hull and in wrecks, used as well as one round's forecast
     allows: a Barrier every other round, Armoured 2 every round, a lure onto the plated
     machine every other round.
  4. What a kill saves: the foe in front gone after the first round, in hull for each point of
     damage it would have dealt. Over 1, the kill saved more than its foe's own blows.
"""
import argparse
import random

# The squad: a plated machine and three lights, near tier one's lines of 12 November.
SQUAD = [
    {"hull": 36, "gauge": 6, "armour": 1},
    {"hull": 20, "gauge": 8, "armour": 0},
    {"hull": 20, "gauge": 8, "armour": 0},
    {"hull": 20, "gauge": 8, "armour": 0},
]

# The shield's rules. block: what the blow that breaks a shield loses ("none", the honest
# shield; "whole", all that was left of it; "again", as much again as the shield that stood).
# down: the rounds a broken shield waits before its regen. hit_stops: a machine hit last round,
# shield or hull, regains nothing this round. regen: shield back a round.
RULES = [
    ("As built", {"block": "none", "down": 0, "hit_stops": False, "regen": 1}),
    ("A break blocks the blow, 2 down", {"block": "whole", "down": 2, "hit_stops": False, "regen": 1}),
    ("A break blocks as much again, 2 down", {"block": "again", "down": 2, "hit_stops": False, "regen": 1}),
    ("2 down, no block", {"block": "none", "down": 2, "hit_stops": False, "regen": 1}),
    ("2 down, no block, regen 3", {"block": "none", "down": 2, "hit_stops": False, "regen": 3}),
    ("Any hit stops regen, regen 3", {"block": "none", "down": 0, "hit_stops": True, "regen": 3}),
]

# The foes' shapes, each `damage` a round. A shape is a list of attackers in the order they
# strike; an attacker is (pick, [its blows], rider). pick: "one" a machine at random, "same"
# the machine the attacker before it picked (a shared pick), "all" every machine, "first" the
# same light every round while it stands. rider: None, "breach" (as built: the shield and the
# armour ignored) or "x2" (each point of the blow takes two off a shield).
def shapes(d):
    q = d // 4
    return [
        ("One blow of %d" % d, [("one", [d], None)]),
        ("Two strikes of %d" % (d // 2), [("one", [d // 2, d // 2], None)]),
        ("Two strikes, %d then %d" % (d // 2 - 2, d // 2 + 2), [("one", [d // 2 - 2, d // 2 + 2], None)]),
        ("%d, then %d from the foe behind" % (d - q, q), [("one", [d - q], None), ("same", [q], None)]),
        ("%d, then %d from the foe behind" % (q, d - q), [("one", [q], None), ("same", [d - q], None)]),
        ("%d double on shield, then %d from the foe behind" % (q, d - q), [("one", [q], "x2"), ("same", [d - q], None)]),
        ("Four blows of %d, each its own pick" % q, [("one", [q], None)] * 4),
        ("%d on every machine" % q, [("all", [q], None)]),
        ("1 on every machine, then %d on one" % (d - 4), [("all", [1], None), ("one", [d - 4], None)]),
        ("%d on the same machine every round" % d, [("first", [d], None)]),
        ("%d through the shield, a breach as built" % d, [("one", [d], "breach")]),
    ]


class Machine:
    __slots__ = ("hull", "gauge", "armour", "shield", "down", "hit", "barrier", "brace")

    def __init__(self, spec):
        self.hull = spec["hull"]
        self.gauge = spec["gauge"]
        self.armour = spec["armour"]
        self.shield = self.gauge
        self.down = 0
        self.hit = False
        self.barrier = False
        self.brace = 0

    def copy(self):
        m = Machine.__new__(Machine)
        for k in Machine.__slots__:
            setattr(m, k, getattr(self, k))
        return m


def land(m, amount, rider, rule):
    """One blow on one machine. Returns what reached its hull."""
    if amount <= 0 or m.hull <= 0:
        return 0
    if m.barrier:
        m.barrier = False   # a Barrier takes the blow whole: the shield untouched, the machine not hit
        return 0
    m.hit = True
    if rider == "breach":
        through = amount    # as built: it ignores the shield and the armour
    else:
        stood = m.shield
        per = 2 if rider == "x2" else 1
        absorbed = min(stood, amount * per)
        through = amount - (absorbed + per - 1) // per
        m.shield = stood - absorbed
        if stood > 0 and m.shield == 0:
            if rule["block"] == "whole":
                through = 0
            elif rule["block"] == "again":
                through = max(0, through - stood)
            if rule["down"] > 0:
                m.down = rule["down"] + 1
        through = max(0, through - m.armour - m.brace)
    m.hull -= through
    return through


def open_round(squad, rule):
    for m in squad:
        was_hit, m.hit, m.brace, m.barrier = m.hit, False, 0, False
        if m.hull <= 0:
            continue
        if m.down > 0:
            m.down -= 1
            if m.down > 0:
                continue
        if rule["hit_stops"] and was_hit:
            continue
        m.shield = min(m.gauge, m.shield + rule["regen"])


def picks(squad, shape, rng):
    """The round's intents: [(machine index or 'all', blows, rider)], drawn as the round opens."""
    live = [i for i, m in enumerate(squad) if m.hull > 0]
    out, last = [], None
    for pick, blows, rider in shape:
        if pick == "all":
            out.append(("all", blows, rider))
            continue
        if pick == "first":
            last = live[0] if 0 not in live or len(live) == 1 else next(i for i in live if i != 0)
        elif pick == "one" or last is None:
            last = rng.choice(live)
        out.append((last, blows, rider))
    return out


def strike(squad, intents, rule, lured_to=None):
    """The enemy's turn. Returns the hull the round took."""
    lost = 0
    for target, blows, rider in intents:
        for b in blows:
            if target == "all":
                for m in squad:
                    lost += land(m, b, rider, rule)
                continue
            at = lured_to if lured_to is not None else target
            if squad[at].hull <= 0:   # its machine fell first: the next in line
                live = [i for i, m in enumerate(squad) if m.hull > 0]
                if not live:
                    return lost
                at = live[0]
            lost += land(squad[at], b, rider, rule)
    return lost


def best_use(squad, intents, rule, tool):
    """The tool's best use by one round's forecast: a wreck first, then hull, then a quarter for
    shield kept."""
    def worth(prepare):
        trial = [m.copy() for m in squad]
        lure = prepare(trial)
        before = sum(m.shield for m in trial)
        stood = sum(1 for m in trial if m.hull > 0)
        lost = strike(trial, intents, rule, lure)
        return 40 * (stood - sum(1 for m in trial if m.hull > 0)) + lost + 0.25 * (before - sum(m.shield for m in trial))

    options = [lambda t: None]
    for i, m in enumerate(squad):
        if m.hull <= 0:
            continue
        if tool == "barrier":
            options.append(lambda t, i=i: setattr(t[i], "barrier", True))
        elif tool == "armoured":
            options.append(lambda t, i=i: setattr(t[i], "brace", 2))
    if tool == "lure" and squad[0].hull > 0:
        options.append(lambda t: 0)
    scored = [(worth(o), k) for k, o in enumerate(options)]
    return options[min(scored)[1]]


def fight(rule, shape, rounds, rng, tool=None, front_falls=False):
    squad = [Machine(s) for s in SQUAD]
    lost, ready = 0, True
    for r in range(rounds):
        if r > 0:
            open_round(squad, rule)
        if all(m.hull <= 0 for m in squad):
            break
        intents = picks(squad, shape[1:] if front_falls and r > 0 else shape, rng)
        lure = None
        if tool and (tool == "armoured" or ready):
            use = best_use(squad, intents, rule, tool)
            lure = use(squad)
            used = lure is not None or any(m.barrier or m.brace for m in squad)
            ready = not used or tool == "armoured"
        else:
            ready = True
        lost += strike(squad, intents, rule, lure)
    return lost, sum(1 for m in squad if m.hull <= 0)


def table(title, rows, heads):
    print(title)
    print()
    print("| The foes' shape | " + " | ".join(heads) + " |")
    print("|---|" + "---|" * len(heads))
    for name, cells in rows:
        print("| %s | %s |" % (name, " | ".join(cells)))
    print()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=6000)
    ap.add_argument("--rounds", type=int, default=5)
    ap.add_argument("--damage", type=int, default=16)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()
    dealt = a.damage * a.rounds
    heads = [name for name, _ in RULES]
    print("The shield's model: a plated machine (hull 36, shield 6, armour 1) and three lights (hull 20, shield 8), %d damage a round for %d rounds in each shape, %d fights a cell. No dice, no kills, no content." % (a.damage, a.rounds, a.trials))
    print()
    plain = {}
    share, wrecks = [], []
    for sname, shape in shapes(a.damage):
        row_s, row_w = [], []
        for rname, rule in RULES:
            rng = random.Random(a.seed)
            lost = wrecked = 0
            for _ in range(a.trials):
                l, w = fight(rule, shape, a.rounds, rng)
                lost += l
                wrecked += w
            plain[(sname, rname)] = lost / a.trials
            row_s.append("%d%%" % round(100.0 * lost / a.trials / dealt))
            row_w.append("%.1f" % (wrecked / a.trials))
        share.append((sname, row_s))
        wrecks.append((sname, row_w))
    table("Of the damage dealt, what reaches a hull", share, heads)
    table("Machines wrecked a fight", wrecks, heads)
    tools = [("barrier", "A Barrier every other round"), ("armoured", "Armoured 2 every round"), ("lure", "A lure onto the plated machine every other round")]
    for tool, label in tools:
        rows = []
        for sname, shape in shapes(a.damage):
            if "breach" in sname and tool != "barrier":
                continue
            cells = []
            for rname, rule in RULES:
                n = max(1, a.trials // 4)
                rng = random.Random(a.seed)
                lost = wrecked = 0
                for _ in range(n):
                    l, w = fight(rule, shape, a.rounds, rng, tool)
                    lost += l
                    wrecked += w
                rng = random.Random(a.seed)
                base_l = base_w = 0
                for _ in range(n):
                    l, w = fight(rule, shape, a.rounds, rng)
                    base_l += l
                    base_w += w
                cells.append("%d, %.1f" % (round((base_l - lost) / n), (base_w - wrecked) / n))
            rows.append((sname, cells))
        table("%s: the hull it saves a fight, then the wrecks" % label, rows, heads)
    rows = []
    for sname, shape in shapes(a.damage):
        if len(shape) < 2:
            continue
        gone = sum(shape[0][1]) * (len(SQUAD) if shape[0][0] == "all" else 1) * (a.rounds - 1)
        cells = []
        for rname, rule in RULES:
            n = max(1, a.trials // 2)
            rng = random.Random(a.seed)
            with_kill = sum(fight(rule, shape, a.rounds, rng, None, True)[0] for _ in range(n)) / n
            rng = random.Random(a.seed)
            without = sum(fight(rule, shape, a.rounds, rng)[0] for _ in range(n)) / n
            cells.append("%.1f" % ((without - with_kill) / gone))
        rows.append((sname, cells))
    table("The foe in front killed in the first round: hull saved for each point of damage it would have dealt", rows, heads)


if __name__ == "__main__":
    main()
