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
  5. The first two tables again for the shapes of a wider bench (MORE): one field for the
     squad, a gauge that shrinks each round, a shield small blows bounce off, and a block each
     machine may call once a fight.

    python3 tools/shield_model.py --fight    # a fight that ends, and heat

The second model gives the squad a gun and the pack hit points, so a fight has a length and a
machine that holds its fire costs the squad a shot. Each machine fires 3 damage for the gun's
heat, or holds; the pack dies front foe first. It prints:
  6. A reboot that takes a round longer every time the shield breaks (Ryan, 13 November),
     with the block and without, by the fight's length.
  7. One gauge that fills from heat and from hits (his form of the same day), beside the
     shield and the heat gauge as built, by the gun's heat.

    python3 tools/shield_model.py --builds   # his menu of 13 November spliced into rule sets

The third model plays whole rule sets, each a splice of the options he listed: the shield's
regen, the block, what a pass recovers, cooling, one bar for both. A machine passes when its
die is a dud (one round in five), when its build says a pass would recover something, or when
its shot would overheat it; else it fires. It prints each build against each pack twice, by
the squad that fires whenever it can and by the squad that passes whenever a pass recovers
anything, and then the builds by the gun's heat.
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

# A wider bench (Ryan, 13 November: "Think outside the box for a second. What other shapes are
# there?"), each beside the shield as built. pool: the squad's gauges are one field, whoever is
# hit. fade: every gauge a point smaller as each round opens. bounce: a blow at or under half the
# gauge does nothing, a bigger one loses that much, drops the shield and it is back whole after
# `down` rounds. call: once a fight a machine may block the next blow on it whole, one call a
# round for the squad, and its shield is then down two rounds; the model calls it when one
# round's forecast says it saves a wreck or six hull.
MORE = [
    ("As built", {"block": "none", "down": 0, "hit_stops": False, "regen": 1}),
    ("One field for the squad", {"block": "none", "down": 0, "hit_stops": False, "regen": 1, "pool": True}),
    ("Regen 3, every gauge a point smaller a round", {"block": "none", "down": 0, "hit_stops": False, "regen": 3, "fade": 1}),
    ("Small blows bounce, a big one drops it 2 rounds", {"block": "none", "down": 2, "hit_stops": False, "regen": 0, "bounce": True}),
    ("As built, and a block each machine calls once", {"block": "none", "down": 0, "hit_stops": False, "regen": 1, "call": True}),
]

# The fight that ends (--fight). A machine's gun, its heat gauge as tier one has it, and what
# the squad's rules are read against.
GUN_DAMAGE = 3
HEAT_MAX = 12
COOLING = 2
# grow: a broken shield stays down `down` rounds the first time and `grow` more each time after.
# whole: it is back at its full gauge when the reboot ends, where the others restart their regen.
REBOOTS = [
    ("As built", {"block": "none", "down": 0, "hit_stops": False, "regen": 1}),
    ("Block, 2 down", {"block": "whole", "down": 2, "hit_stops": False, "regen": 1}),
    ("Block, 2 down then one more each break", {"block": "whole", "down": 2, "grow": 1, "hit_stops": False, "regen": 1}),
    ("Block, 1 down", {"block": "whole", "down": 1, "hit_stops": False, "regen": 1}),
    ("Block, 1 down then one more each break", {"block": "whole", "down": 1, "grow": 1, "hit_stops": False, "regen": 1}),
    ("No block, 2 down then one more each break", {"block": "none", "down": 2, "grow": 1, "hit_stops": False, "regen": 1}),
    ("No block, back whole after 1 then one more each break", {"block": "none", "down": 1, "grow": 1, "whole": True, "hit_stops": False, "regen": 0}),
]
# one_gauge: no shield bar. Hits fill the heat gauge as shots do, its size the heat maximum and
# the shield together, its drain the cooling and the regen together; what will not fit burns hull.
GAUGES = [
    ("As built", {"block": "none", "down": 0, "hit_stops": False, "regen": 1}),
    ("One gauge, hits and heat", {"block": "none", "down": 0, "hit_stops": False, "regen": 1, "one_gauge": True}),
]


def packs(rounds_at_full_fire, blow):
    """The packs of the fight that ends: [(name, [foe, ...])], a foe {hp, pick, blows, rider}.
    Hit points are sized so four machines firing every round end it in so many rounds; every
    pack deals `blow` a round while it stands whole."""
    hp = GUN_DAMAGE * len(SQUAD) * rounds_at_full_fire
    light = SQUAD[1]["gauge"]
    return [
        ("A lone foe, one blow of %d" % blow, [{"hp": hp, "pick": "one", "blows": [blow], "rider": None}]),
        ("A lone foe, two strikes, %d then %d" % (light, blow - light), [{"hp": hp, "pick": "one", "blows": [light, blow - light], "rider": None}]),
        ("A lone foe, %d on the same machine every round" % blow, [{"hp": hp, "pick": "first", "blows": [blow], "rider": None}]),
        ("Four foes, a blow of %d each" % (blow // 4), [{"hp": hp // 4, "pick": "one", "blows": [blow // 4], "rider": None} for _ in range(4)]),
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
    __slots__ = ("hull", "gauge", "armour", "shield", "down", "hit", "barrier", "brace", "called", "calling", "heat", "breaks")

    def __init__(self, spec):
        self.hull = spec["hull"]
        self.gauge = spec["gauge"]
        self.armour = spec["armour"]
        self.shield = self.gauge
        self.down = 0
        self.hit = False
        self.barrier = False
        self.brace = 0
        self.called = False
        self.calling = False
        self.heat = 0
        self.breaks = 0

    def copy(self):
        m = Machine.__new__(Machine)
        for k in Machine.__slots__:
            setattr(m, k, getattr(self, k))
        return m


def land(m, amount, rider, rule, field):
    """One blow on one machine. Returns what reached its hull."""
    if amount <= 0 or m.hull <= 0:
        return 0
    if m.barrier:
        m.barrier = False   # a Barrier takes the blow whole: the shield untouched, the machine not hit
        return 0
    if m.calling:
        m.calling = False   # the block it called: the blow whole, and its shield reboots
        m.shield = 0
        m.down = 3
        return 0
    m.hit = True
    if rider == "breach":
        through = amount    # as built: it ignores the shield and the armour
    elif rule.get("one_gauge"):
        absorbed = min(max(0, HEAT_MAX + m.gauge - m.heat), amount)
        m.heat += absorbed
        through = max(0, amount - absorbed - m.armour - m.brace)
    elif rule.get("pool"):
        absorbed = min(field["pool"], amount * (2 if rider == "x2" else 1))
        field["pool"] -= absorbed
        through = max(0, amount - (absorbed + 1) // 2 if rider == "x2" else amount - absorbed)
        through = max(0, through - m.armour - m.brace)
    elif rule.get("bounce"):
        rating = m.gauge // 2
        if m.shield > 0 and amount * (2 if rider == "x2" else 1) <= rating:
            through = 0
        else:
            through = amount - (rating if m.shield > 0 else 0)
            if m.shield > 0:
                m.shield = 0
                m.down = rule["down"] + 1
            through = max(0, through - m.armour - m.brace)
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
            wait = rule["down"] + rule.get("grow", 0) * m.breaks
            m.breaks += 1
            if wait > 0:
                m.down = wait + 1
        through = max(0, through - m.armour - m.brace)
    m.hull -= through
    return through


def open_round(squad, rule, field):
    for m in squad:
        was_hit, m.hit, m.brace, m.barrier, m.calling = m.hit, False, 0, False, False
        if m.hull <= 0:
            continue
        if rule.get("fade"):
            m.gauge = max(0, m.gauge - rule["fade"])
            m.shield = min(m.shield, m.gauge)
        if m.down > 0:
            m.down -= 1
            if m.down > 0:
                continue
            if rule.get("bounce") or rule.get("whole"):
                m.shield = m.gauge   # back whole
        if rule["hit_stops"] and was_hit:
            continue
        m.shield = min(m.gauge, m.shield + rule["regen"])
    if rule.get("pool"):
        live = [m for m in squad if m.hull > 0]
        field["pool"] = min(sum(m.gauge for m in live), field["pool"] + rule["regen"] * len(live))


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


def strike(squad, intents, rule, field, lured_to=None):
    """The enemy's turn. Returns the hull the round took."""
    lost = 0
    for target, blows, rider in intents:
        for b in blows:
            if target == "all":
                for m in squad:
                    lost += land(m, b, rider, rule, field)
                continue
            at = lured_to if lured_to is not None else target
            if squad[at].hull <= 0:   # its machine fell first: the next in line
                live = [i for i, m in enumerate(squad) if m.hull > 0]
                if not live:
                    return lost
                at = live[0]
            lost += land(squad[at], b, rider, rule, field)
    return lost


def forecast(squad, intents, rule, field, prepare):
    """One round played on a copy: a wreck first, then hull, then a quarter for shield kept."""
    trial = [m.copy() for m in squad]
    trial_field = dict(field)
    lure = prepare(trial)
    before = sum(m.shield for m in trial) + trial_field.get("pool", 0)
    stood = sum(1 for m in trial if m.hull > 0)
    lost = strike(trial, intents, rule, trial_field, lure)
    wrecks = stood - sum(1 for m in trial if m.hull > 0)
    kept = sum(m.shield for m in trial) + trial_field.get("pool", 0)
    return 40 * wrecks + lost + 0.25 * (before - kept), lost, wrecks


def call_block(squad, intents, rule, field):
    """The block a machine may call once a fight: called where one round's forecast says it
    saves a wreck or six hull, one call a round."""
    _, lost, wrecks = forecast(squad, intents, rule, field, lambda t: None)
    best, best_gain = None, 0
    for i, m in enumerate(squad):
        if m.hull <= 0 or m.called:
            continue
        _, l, w = forecast(squad, intents, rule, field, lambda t, i=i: setattr(t[i], "calling", True))
        gain = 40 * (wrecks - w) + (lost - l)
        if (w < wrecks or lost - l >= 6) and gain > best_gain:
            best, best_gain = i, gain
    if best is not None:
        squad[best].calling = True
        squad[best].called = True


def best_use(squad, intents, rule, field, tool):
    """The tool's best use by one round's forecast."""
    def worth(prepare):
        return forecast(squad, intents, rule, field, prepare)[0]

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
    field = {"pool": sum(m.gauge for m in squad)} if rule.get("pool") else {}
    lost, ready = 0, True
    for r in range(rounds):
        if r > 0:
            open_round(squad, rule, field)
        if all(m.hull <= 0 for m in squad):
            break
        intents = picks(squad, shape[1:] if front_falls and r > 0 else shape, rng)
        lure = None
        if tool and (tool == "armoured" or ready):
            use = best_use(squad, intents, rule, field, tool)
            lure = use(squad)
            used = lure is not None or any(m.barrier or m.brace for m in squad)
            ready = not used or tool == "armoured"
        else:
            ready = True
        if rule.get("call"):
            call_block(squad, intents, rule, field)
        lost += strike(squad, intents, rule, field, lure)
    return lost, sum(1 for m in squad if m.hull <= 0)


def duel(rule, pack, rng, gun_heat=4, risk=2, cap_rounds=14):
    """A fight that ends. Each round: the machines cool and regain, the foes pick, each machine
    fires (GUN_DAMAGE for gun_heat) or holds, the pack takes the fire front foe first, heat
    over a gauge burns hull, and the foes left strike. A machine holds when its shot would cost
    more than `risk` hull this round: its own overheat, and under one gauge the blow it has
    been shown. Returns rounds, hull lost, wrecks and the share of machine-rounds held."""
    squad = [Machine(s) for s in SQUAD]
    foes = [dict(f) for f in pack]
    field = {}
    one = bool(rule.get("one_gauge"))
    if one:
        for m in squad:
            m.shield = 0
    start = sum(m.hull for m in squad)
    held = turns = rounds = 0
    while rounds < cap_rounds and any(f["hp"] > 0 for f in foes) and any(m.hull > 0 for m in squad):
        rounds += 1
        if rounds > 1:
            open_round(squad, rule, field)
            for m in squad:
                m.heat = max(0, m.heat - COOLING - (rule["regen"] if one else 0))
            if one:
                for m in squad:
                    m.shield = 0
        standing = [f for f in foes if f["hp"] > 0]
        intents = picks(squad, [(f["pick"], f["blows"], f["rider"]) for f in standing], rng)
        fire = 0
        for i, m in enumerate(squad):
            if m.hull <= 0:
                continue
            turns += 1
            cap = HEAT_MAX + (m.gauge if one else 0)
            shown = sum(sum(blows) for target, blows, _ in intents if target == i or target == "all") if one else 0
            cost = max(0, m.heat + gun_heat + shown - cap) - max(0, m.heat + shown - cap)
            if cost > risk:
                held += 1
                continue
            m.heat += gun_heat
            fire += GUN_DAMAGE
        for f in foes:
            if f["hp"] > 0 and fire > 0:
                took = min(f["hp"], fire)
                f["hp"] -= took
                fire -= took
        for m in squad:
            cap = HEAT_MAX + (m.gauge if one else 0)
            if m.hull > 0 and m.heat > cap:
                m.hull -= m.heat - cap
                m.heat = cap
        strike(squad, [it for it, f in zip(intents, standing) if f["hp"] > 0], rule, field)
    lost = start - sum(max(0, m.hull) for m in squad)
    return rounds, lost, sum(1 for m in squad if m.hull <= 0), held / float(max(1, turns))


def fights(a):
    """The fight that ends: the reboot that grows, then the one gauge."""
    hull = float(sum(m["hull"] for m in SQUAD))
    n = max(1, a.trials // 2)
    print("The fight that ends: the same squad, a gun of %d damage for 4 heat, a heat gauge of %d cooling %d, the pack dealing %d a round with hit points sized to four machines' fire, %d fights a cell. A machine holds when its shot would cost it more than 2 hull that round. No dice, no content." % (GUN_DAMAGE, HEAT_MAX, COOLING, a.blow, n))
    print()
    heads = [name for name, _ in REBOOTS]
    for length in (4, 6, 8):
        rows = []
        for pname, pack in packs(length, a.blow):
            cells = []
            for rname, rule in REBOOTS:
                rng = random.Random(a.seed)
                rs = ls = ws = 0
                for _ in range(n):
                    r, l, w, _h = duel(rule, pack, rng)
                    rs += r
                    ls += l
                    ws += w
                cells.append("%d%%, %.1f" % (round(100.0 * ls / n / hull), ws / n))
            rows.append((pname, cells))
        table("A fight of %d rounds at full fire: the squad's hull lost, then the wrecks" % length, rows, heads)
    heads = []
    for gname, _ in GAUGES:
        for heat in (2, 4, 6):
            heads.append("%s, a gun of %d heat" % (gname, heat))
    for length in (4, 6):
        rows = []
        for pname, pack in packs(length, a.blow):
            cells = []
            for gname, rule in GAUGES:
                for heat in (2, 4, 6):
                    rng = random.Random(a.seed)
                    rs = ls = ws = hs = 0
                    for _ in range(n):
                        r, l, w, h = duel(rule, pack, rng, heat)
                        rs += r
                        ls += l
                        ws += w
                        hs += h
                    cells.append("%.1f rounds, %d%%, %d%% held" % (rs / n, round(100.0 * ls / n / hull), round(100.0 * hs / n)))
            rows.append((pname, cells))
        table("One gauge for hits and heat, a fight of %d rounds at full fire: its rounds, the hull lost, the shots held" % length, rows, heads)


# ---------------------------------------------------------------- the builds (--builds)
# A build is a splice of the options of 13 November. regen and cooling are what returns every
# round with nothing done. reboot: what a pass does for the shield as the next round opens,
# "broken" (a broken shield back whole, and a broken shield never recovers by itself where
# regen is nothing), "always" (any shield back whole) or absent. vent: a pass empties the heat.
# block: the blow that breaks the shield is stopped whole. now: the pass's shield is back the
# same turn, before the foes strike. one_bar: no shield and no heat gauge; shots and hits drain
# one bar the size of both, a pass refills it, and at nothing the hull takes what is left.
# hot_stops: no regen while the heat stands at half its maximum or more. heat_cuts: the shield's
# maximum is lower by a third of the heat the machine carries.
BUILDS = [
    ("As built", {"regen": 1, "cooling": 2}),
    ("As built, no regen while hot", {"regen": 1, "cooling": 2, "hot_stops": True}),
    ("As built, heat lowers the shield's maximum", {"regen": 1, "cooling": 2, "heat_cuts": True}),
    ("As built, and a pass reboots a broken shield", {"regen": 1, "cooling": 2, "reboot": "broken"}),
    ("No regen, no cooling: a pass reboots a broken shield and vents", {"regen": 0, "cooling": 0, "reboot": "broken", "vent": True}),
    ("The same with the block", {"regen": 0, "cooling": 0, "reboot": "broken", "vent": True, "block": True}),
    ("The same, the shield back the turn it passes", {"regen": 0, "cooling": 0, "reboot": "broken", "vent": True, "now": True}),
    ("The same, a pass refills any shield", {"regen": 0, "cooling": 0, "reboot": "always", "vent": True}),
    ("One bar: shots and hits drain it, a pass refills it", {"regen": 0, "cooling": 0, "one_bar": True}),
]
DUD = 0.2   # a machine's die shows nothing it can fire, one round in five


class Unit:
    __slots__ = ("hull", "gauge", "armour", "shield", "heat", "down", "passed", "bar", "cap")

    def __init__(self, spec):
        self.hull = spec["hull"]
        self.gauge = spec["gauge"]
        self.armour = spec["armour"]
        self.shield = self.gauge
        self.heat = 0
        self.down = False
        self.passed = False
        self.cap = HEAT_MAX + self.gauge
        self.bar = self.cap


def bout(build, pack, rng, gun_heat=4, eager=True, risk=2, cap_rounds=16):
    """A fight that ends, on a build. Returns rounds, hull lost, wrecks, the share of
    machine-turns passed. eager: the squad passes whenever a pass would recover anything;
    else it passes only on a dud or to keep from overheating."""
    squad = [Unit(s) for s in SQUAD]
    foes = [dict(f) for f in pack]
    one = bool(build.get("one_bar"))
    start = sum(u.hull for u in squad)
    passes = turns = rounds = 0
    while rounds < cap_rounds and any(f["hp"] > 0 for f in foes) and any(u.hull > 0 for u in squad):
        rounds += 1
        if rounds > 1:
            for u in squad:
                if u.hull <= 0:
                    continue
                if one:
                    u.bar = u.cap if u.passed else u.bar
                else:
                    u.heat = 0 if (u.passed and build.get("vent")) else max(0, u.heat - build["cooling"])
                    if u.passed and not build.get("now"):
                        _reboot(u, build)
                    top = u.gauge - (u.heat // 3 if build.get("heat_cuts") else 0)
                    u.shield = min(u.shield, max(0, top))
                    if build["regen"] and u.shield < top and not (build.get("hot_stops") and u.heat * 2 >= HEAT_MAX):
                        u.shield = min(top, u.shield + build["regen"])
                u.passed = False
        standing = [f for f in foes if f["hp"] > 0]
        intents = picks(squad, [(f["pick"], f["blows"], f["rider"]) for f in standing], rng)
        fire = 0
        for u in squad:
            if u.hull <= 0:
                continue
            turns += 1
            want = rng.random() < DUD
            if one:
                want = want or u.bar < gun_heat or (eager and u.bar * 4 <= u.cap)
            else:
                over = u.heat + gun_heat - HEAT_MAX
                want = want or (over > 0 if build.get("vent") else over > risk)
                if eager and build.get("reboot") == "broken" and u.down:
                    want = True
                if eager and build.get("reboot") == "always" and u.shield * 2 <= u.gauge:
                    want = True
            if want:
                passes += 1
                u.passed = True
                if build.get("now") and not one:
                    _reboot(u, build)
                continue
            if one:
                u.bar -= gun_heat
            else:
                u.heat += gun_heat
            fire += GUN_DAMAGE
        for f in foes:
            if f["hp"] > 0 and fire > 0:
                took = min(f["hp"], fire)
                f["hp"] -= took
                fire -= took
        for u in squad:
            if not one and u.hull > 0 and u.heat > HEAT_MAX:
                u.hull -= u.heat - HEAT_MAX   # an overheat, as built
                u.heat = HEAT_MAX
        for (target, blows, _), f in zip(intents, standing):
            if f["hp"] <= 0:
                continue
            for b in blows:
                if target == "all":
                    for u in squad:
                        _take(u, b, build, one)
                    continue
                at = target
                if squad[at].hull <= 0:
                    live = [i for i, u in enumerate(squad) if u.hull > 0]
                    if not live:
                        break
                    at = live[0]
                _take(squad[at], b, build, one)
    lost = start - sum(max(0, u.hull) for u in squad)
    return rounds, lost, sum(1 for u in squad if u.hull <= 0), passes / float(max(1, turns))


def _reboot(u, build):
    if build.get("reboot") == "always" or (build.get("reboot") == "broken" and u.down):
        u.shield = u.gauge
        u.down = False


def _take(u, amount, build, one):
    if u.hull <= 0 or amount <= 0:
        return
    if one:
        absorbed = min(u.bar, amount)
        broke = absorbed > 0 and u.bar == absorbed
        u.bar -= absorbed
    else:
        absorbed = min(u.shield, amount)
        broke = absorbed > 0 and u.shield == absorbed
        u.shield -= absorbed
        if broke:
            u.down = True
    through = 0 if (broke and build.get("block")) else amount - absorbed
    u.hull -= max(0, through - u.armour)


def build_packs(length, blow):
    out = packs(length, blow)
    hp = GUN_DAMAGE * len(SQUAD) * length
    out.append(("A lone foe, %d on every machine" % (blow // 3), [{"hp": hp, "pick": "all", "blows": [blow // 3], "rider": None}]))
    return out


def builds(a):
    hull = float(sum(m["hull"] for m in SQUAD))
    n = max(1, a.trials // 3)
    print("The builds: the same squad and gun, the pack dealing %d a round, a die that is a dud one round in five, %d fights a cell. No content." % (a.blow, n))
    print()
    for length in (4, 6):
        for eager, label in ((False, "the squad fires whenever it can"), (True, "the squad passes whenever a pass recovers anything")):
            names = [p for p, _ in build_packs(length, a.blow)]
            print("A fight of %d rounds at full fire, %s: the hull lost, the rounds, the turns passed" % (length, label))
            print()
            print("| The build | " + " | ".join(names) + " |")
            print("|---|" + "---|" * len(names))
            for bname, build in BUILDS:
                cells = []
                for pname, pack in build_packs(length, a.blow):
                    rng = random.Random(a.seed)
                    rs = ls = ps = 0
                    for _ in range(n):
                        r, l, w, p = bout(build, pack, rng, 4, eager)
                        rs += r
                        ls += l
                        ps += p
                    cells.append("%d%%, %.1f, %d%%" % (round(100.0 * ls / n / hull), rs / n, round(100.0 * ps / n)))
                print("| %s | %s |" % (bname, " | ".join(cells)))
            print()
    print("By the gun's heat, a fight of 4 rounds against the lone blow, the squad passing whenever a pass recovers anything: the hull lost, the rounds, the turns passed")
    print()
    print("| The build | A gun of 2 heat | A gun of 4 heat | A gun of 6 heat |")
    print("|---|---|---|---|")
    pack = build_packs(4, a.blow)[0][1]
    for bname, build in BUILDS:
        cells = []
        for heat in (2, 4, 6):
            rng = random.Random(a.seed)
            rs = ls = ps = 0
            for _ in range(n):
                r, l, w, p = bout(build, pack, rng, heat, True)
                rs += r
                ls += l
                ps += p
            cells.append("%d%%, %.1f, %d%%" % (round(100.0 * ls / n / hull), rs / n, round(100.0 * ps / n)))
        print("| %s | %s |" % (bname, " | ".join(cells)))
    print()


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
    ap.add_argument("--bench", action="store_true", help="the wider bench alone")
    ap.add_argument("--fight", action="store_true", help="the fight that ends: the reboot that grows, and one gauge for hits and heat")
    ap.add_argument("--blow", type=int, default=12, help="what a pack deals a round in the fight that ends")
    ap.add_argument("--builds", action="store_true", help="his menu of 13 November spliced into rule sets")
    a = ap.parse_args()
    dealt = a.damage * a.rounds
    heads = [name for name, _ in RULES]
    if a.bench:
        bench(a, dealt)
        return
    if a.fight:
        fights(a)
        return
    if a.builds:
        builds(a)
        return
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
    bench(a, dealt)


def bench(a, dealt):
    """The wider bench: what reaches a hull, the wrecks, and the worst a single light loses."""
    heads = [name for name, _ in MORE]
    share, wrecks = [], []
    for sname, shape in shapes(a.damage):
        row_s, row_w = [], []
        for rname, rule in MORE:
            rng = random.Random(a.seed)
            lost = wrecked = 0
            for _ in range(a.trials):
                l, w = fight(rule, shape, a.rounds, rng)
                lost += l
                wrecked += w
            row_s.append("%d%%" % round(100.0 * lost / a.trials / dealt))
            row_w.append("%.1f" % (wrecked / a.trials))
        share.append((sname, row_s))
        wrecks.append((sname, row_w))
    table("The wider bench: of the damage dealt, what reaches a hull", share, heads)
    table("The wider bench: machines wrecked a fight", wrecks, heads)


if __name__ == "__main__":
    main()
