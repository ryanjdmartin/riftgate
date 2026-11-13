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

    python3 tools/shield_model.py --shutdown # the shutdown as he stated it the same day

No regen and no cooling; a broken shield allows a shutdown, an overheat forces one, a shutdown
recovers both meters, and no machine shuts down by choice. It prints:
  8. The rule beside the game as built and the pass at will, with each point his words leave
     open played as its own row: what an overheat costs past the turn (the excess off the
     hull, or the shield down at once), when the recovery lands, and the block.
  9. The same rules by the gun's heat.
 10. The break's choice played two ways, fighting on or shutting down at once.
 11. A long fight against a lighter pack, where the game as built runs at its heat cap.
 12. Which meter sets the clock: the share of shutdowns an overheat forced, and what each
     kind wasted of the other meter.
 13. What a gun's heat costs in turns as built and under the shutdown, one machine alone.
 14. A foe that heats the machine it strikes, at random and at the hottest.

    python3 tools/shield_model.py --choice   # the reboot by choice, his next form

"It takes away player agency ... letting the player ride at max heat and the reboot being a
choice to vent heat and recover shield. If the shield is not empty and the unit reboots, I'd
feel like we should empty the shield." A reboot takes the turn and empties the shield at
once; heat and shield are back as the next round opens; nothing forces one, and a shot past
the maximum burns its excess as built. It prints:
 15. The rule beside the game as built, section 19's splice and the shutdown above, against
     the packs and against a foe that aims at the hottest machine or at the least shield.
 16. The rule by the way it is played: blind to the foes' picks, reading them, firing past the
     maximum, and rebooting at half a shield.
 17. What emptying the shield buys, by the squad that reboots at half a shield or less.
 18. The rule by the gun's heat, and a gun's heat in turns.
 19. What the reboots were: how many, how many under fire, and what each gave up.
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
        elif pick == "hot":
            top = max(getattr(squad[i], "heat", 0) for i in live)
            last = rng.choice([i for i in live if getattr(squad[i], "heat", 0) == top])
        elif pick == "bare":
            low = min(squad[i].shield for i in live)
            last = rng.choice([i for i in live if squad[i].shield == low])
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
# The shutdown as Ryan stated it on 13 November: no regen and no cooling; a broken shield allows
# a shutdown and an overheat forces one; a shutdown recovers both meters; no machine shuts down
# by choice. A machine fires whenever it can, the shot that overheats it included, since nothing
# else vents it; its next turn is the shutdown, and both meters are back as the round after
# opens. burn: the overheat's excess comes off the hull, as built. crash: the overheat takes the
# shield down at once. now: the recovery lands on the turn of the shutdown, before the foes
# strike. risk: the heat past the maximum a machine as built will fire into (2 unless it says).
SHUTDOWN = {"regen": 0, "cooling": 0, "shutdown": True}
SHUTDOWNS = [
    ("As built", {"regen": 1, "cooling": 2}),
    ("As built, a machine never overheating itself", {"regen": 1, "cooling": 2, "risk": 0}),
    ("A pass reboots a broken shield and vents, at will", {"regen": 0, "cooling": 0, "reboot": "broken", "vent": True}),
    ("The shutdown as stated", SHUTDOWN),
    ("The same, the overheat's excess off the hull", dict(SHUTDOWN, burn=True)),
    ("The same, the overheat taking the shield down at once", dict(SHUTDOWN, crash=True)),
    ("The same, the recovery landing the turn of the shutdown", dict(SHUTDOWN, now=True)),
    ("The shutdown with the block", dict(SHUTDOWN, block=True)),
]
# The reboot by choice (Ryan, 13 November, on the shutdown above: "it takes away player agency
# ... letting the player ride at max heat and the reboot being a choice to vent heat and recover
# shield. If the shield is not empty and the unit reboots, I'd feel like we should empty the
# shield"). No regen and no cooling. A machine may give its turn to a reboot whenever it likes:
# its shield goes to nothing at once, and as the next round opens its heat is empty and its
# shield whole. Nothing forces one: a shot past the maximum burns its excess off the hull and
# the gauge settles at the maximum, as built. keeps: the reboot leaves a standing shield up
# through the foes' turn. bare: in the shutdown above, the shield is down for its turn.
CHOICE = {"regen": 0, "cooling": 0, "choice": True}
CHOICES = [
    ("As built", {"regen": 1, "cooling": 2}),
    ("Section 19's splice: a pass vents, and reboots a broken shield", {"regen": 0, "cooling": 0, "reboot": "broken", "vent": True}),
    ("The shutdown of section 20, bare for its turn", dict(SHUTDOWN, bare=True)),
    ("The reboot by choice", CHOICE),
    ("The same, a standing shield kept through the reboot", dict(CHOICE, keeps=True)),
    ("The reboot by choice with the block", dict(CHOICE, block=True)),
]
# How a squad plays the reboot by choice. plain: a machine reboots when its next shot would
# pass the maximum or its shield is down, and never looks at the foes' picks. timed: it reads
# them (a pick is set as the round opens and does not move): with no blow coming it reboots at
# the maximum, on a dud, or to top up a shield at a quarter or less; with a blow coming and a
# shield standing it rides at the maximum, holding its fire, or firing once more when the
# excess is 2 or less. pushes: it never holds, firing past the maximum and burning, and
# reboots only a shield that is down. greedy: it reboots whenever its shield is at half or
# less, picks or no picks.
PLAYS = [("plain", "It reboots at the maximum or on a break, blind to the picks"), ("timed", "It reads the picks"), ("pushes", "It fires past the maximum and burns"), ("greedy", "It reboots at half a shield or less, blind")]
DUD = 0.2   # a machine's die shows nothing it can fire, one round in five


class Unit:
    __slots__ = ("hull", "gauge", "armour", "shield", "heat", "down", "passed", "bar", "cap", "shut")

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
        self.shut = False


def bout(build, pack, rng, gun_heat=4, eager=True, risk=2, cap_rounds=16, tally=None):
    """A fight that ends, on a build. Returns rounds, hull lost, wrecks, the share of
    machine-turns passed. eager: the squad passes whenever a pass would recover anything;
    else it passes only on a dud or to keep from overheating. tally: a dict the shutdown
    builds count into (the shutdowns forced and taken, and what each wasted). A foe's rider
    ("heat", n) heats the machine it strikes by n."""
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
                elif build.get("shutdown") or build.get("choice"):
                    if u.passed and not build.get("now"):
                        u.heat, u.shield, u.down = 0, u.gauge, False
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
        for i, u in enumerate(squad):
            if u.hull <= 0:
                continue
            turns += 1
            want = rng.random() < DUD
            if build.get("choice"):
                coming = sum(sum(b) for t, b, _ in intents if t == "all" or t == i)
                kept = 0 if build.get("keeps") else min(u.shield, coming)   # what a reboot would let through
                excess = u.heat + gun_heat - HEAT_MAX
                act = "idle" if want else "fire"
                if eager == "plain":
                    if want:
                        act = "reboot" if (u.shield == 0 or excess > 0) else "idle"
                    elif u.shield == 0 or excess > 0:
                        act = "reboot"
                elif eager == "greedy":
                    if u.shield * 2 <= u.gauge or (excess > 0 and not want):
                        act = "reboot"
                elif eager == "pushes":
                    if u.shield == 0:
                        act = "reboot"
                else:   # timed
                    safe = kept <= 2
                    if want:
                        act = "reboot" if safe and (u.heat > 0 or u.shield < u.gauge) else "idle"
                    elif u.shield == 0:
                        act = "reboot"
                    elif excess > 0:
                        act = "reboot" if safe else ("fire" if excess <= 2 else "idle")
                    elif safe and u.shield * 4 <= u.gauge:
                        act = "reboot"
                if act == "reboot":
                    passes += 1
                    u.passed = True
                    if tally is not None:
                        tally["reboots"] += 1
                        tally["shield_left"] += u.shield
                        tally["gauge"] += u.gauge
                        tally["heat_left"] += max(0, HEAT_MAX - u.heat)
                        tally["under_fire"] += 1 if coming > 0 else 0
                    if not build.get("keeps"):
                        u.shield, u.down = 0, True
                elif act == "idle":
                    passes += 1
                    if tally is not None and not want:
                        tally["held"] += 1
                else:
                    u.heat += gun_heat
                    fire += GUN_DAMAGE
                    if tally is not None and excess > 0:
                        tally["pushed"] += 1
                continue
            if build.get("shutdown"):
                # Forced by an overheat; allowed by a broken shield, taken on a dud or, played
                # to the full, at once; never by choice. A dud with nothing broken recovers nothing.
                if u.shut or (u.down and (want or eager)):
                    if tally is not None:
                        if u.shut:
                            tally["forced"] += 1
                            tally["shield_left"] += u.shield
                            tally["gauge"] += u.gauge
                        else:
                            tally["taken"] += 1
                            tally["heat_left"] += max(0, HEAT_MAX - u.heat)
                    passes += 1
                    u.shut = False
                    u.passed = True
                    if build.get("bare"):
                        u.shield, u.down = 0, True
                    if build.get("now"):
                        u.heat, u.shield, u.down = 0, u.gauge, False
                elif want:
                    passes += 1
                else:
                    u.heat += gun_heat
                    fire += GUN_DAMAGE
                continue
            if one:
                want = want or u.bar < gun_heat or (eager and u.bar * 4 <= u.cap)
            else:
                over = u.heat + gun_heat - HEAT_MAX
                want = want or (over > 0 if build.get("vent") else over > build.get("risk", risk))
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
            if build.get("shutdown"):
                if u.hull > 0 and u.heat > HEAT_MAX and not u.passed:
                    u.shut = True   # its next turn is the shutdown
                    if build.get("burn"):
                        u.hull -= u.heat - HEAT_MAX
                        u.heat = HEAT_MAX + 1   # it stays overheated
                    if build.get("crash"):
                        u.shield, u.down = 0, True
                continue
            if not one and u.hull > 0 and u.heat > HEAT_MAX:
                u.hull -= u.heat - HEAT_MAX   # an overheat, as built
                u.heat = HEAT_MAX
        for (target, blows, rider), f in zip(intents, standing):
            if f["hp"] <= 0:
                continue
            if rider and rider[0] == "heat" and target != "all":
                live = [i for i, u in enumerate(squad) if u.hull > 0]
                if live:
                    hot = squad[target if target in live else live[0]]
                    if one:
                        hot.bar = max(0, hot.bar - rider[1])
                    else:
                        hot.heat += rider[1]
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
    family, title = BUILDS, "The builds"
    hull = float(sum(m["hull"] for m in SQUAD))
    n = max(1, a.trials // 3)
    print("%s: the same squad and gun, the pack dealing %d a round, a die that is a dud one round in five, %d fights a cell. No content." % (title, a.blow, n))
    print()
    for length in (4, 6):
        for eager, label in ((False, "the squad fires whenever it can"), (True, "the squad passes whenever a pass recovers anything")):
            names = [p for p, _ in build_packs(length, a.blow)]
            print("A fight of %d rounds at full fire, %s: the hull lost, the rounds, the turns passed" % (length, label))
            print()
            print("| The build | " + " | ".join(names) + " |")
            print("|---|" + "---|" * len(names))
            for bname, build in family:
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
    for bname, build in family:
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


def _cell(build, pack, a, n, hull, heat=4, eager=True, tally=None, cap=16):
    rng = random.Random(a.seed)
    rs = ls = ps = 0
    for _ in range(n):
        r, l, w, p = bout(build, pack, rng, heat, eager, cap_rounds=cap, tally=tally)
        rs += r
        ls += l
        ps += p
    return 100.0 * ls / n / hull, rs / float(n), 100.0 * ps / n


def pace(heat, turns, shutdown, start=0):
    """One machine firing a gun of `heat` whenever its rule lets it, over `turns` turns from
    turn `start`: the share of them it fires. As built it never overheats: it holds when the
    shot would end over the maximum, and cools 2 as a round opens. Under the shutdown the shot
    that overheats it fires, and its next turn is the shutdown."""
    h = fired = 0
    shut = False
    for t in range(start + turns):
        if shutdown:
            if shut:
                h, shut = 0, False
            else:
                h += heat
                shut = h > HEAT_MAX
                fired += t >= start
        else:
            h = max(0, h - COOLING) if t else 0
            if h + heat <= HEAT_MAX:
                h += heat
                fired += t >= start
    return fired / float(turns)


def shutdown(a):
    hull = float(sum(m["hull"] for m in SQUAD))
    n = max(1, a.trials // 3)
    stated = SHUTDOWN
    print("The shutdown as stated on 13 November: the same squad and gun, the pack dealing %d a round, a die that is a dud one round in five, %d fights a cell. No content." % (a.blow, n))
    print()
    for length in (4, 6):
        names = [p for p, _ in build_packs(length, a.blow)]
        print("A fight of %d rounds at full fire, a machine shutting down at once on a break: the hull lost, the rounds, the turns passed" % length)
        print()
        print("| The rule | " + " | ".join(names) + " |")
        print("|---|" + "---|" * len(names))
        for bname, build in SHUTDOWNS:
            cells = ["%d%%, %.1f, %d%%" % tuple(round(v, 1) if i == 1 else round(v) for i, v in enumerate(_cell(build, pack, a, n, hull))) for _, pack in build_packs(length, a.blow)]
            print("| %s | %s |" % (bname, " | ".join(cells)))
        print()
    print("By the gun's heat, a fight of 4 rounds against the lone blow, shutting down at once on a break: the hull lost, the rounds, the turns passed")
    print()
    print("| The rule | A gun of 2 heat | A gun of 4 heat | A gun of 6 heat |")
    print("|---|---|---|---|")
    lone = build_packs(4, a.blow)[0][1]
    for bname, build in SHUTDOWNS:
        cells = ["%d%%, %.1f, %d%%" % (round(l), r, round(p)) for l, r, p in (_cell(build, lone, a, n, hull, heat) for heat in (2, 4, 6))]
        print("| %s | %s |" % (bname, " | ".join(cells)))
    print()
    print("The break's choice under the rule as stated, played two ways: the hull lost, the rounds")
    print()
    names = [p for p, _ in build_packs(4, a.blow)]
    print("| The fight, and the play | " + " | ".join(names) + " |")
    print("|---|" + "---|" * len(names))
    for length in (4, 6):
        for eager, label in ((False, "it fights on, and shuts down on a dud"), (True, "it shuts down at once")):
            cells = []
            for _, pack in build_packs(length, a.blow):
                l, r, p = _cell(stated, pack, a, n, hull, 4, eager)
                cells.append("%d%%, %.1f" % (round(l), r))
            print("| %d rounds, %s | %s |" % (length, label, " | ".join(cells)))
    print()
    long_blow = a.blow * 2 // 3
    longs = [(p, k) for p, k in build_packs(8, long_blow) if "two strikes" not in p]
    print("A long fight, 8 rounds at full fire, the pack dealing %d a round: the hull lost, the rounds, the turns passed" % long_blow)
    print()
    print("| The rule and the play | " + " | ".join(p for p, _ in longs) + " |")
    print("|---|" + "---|" * len(longs))
    for bname, build, eager in (
        ("As built", SHUTDOWNS[0][1], True),
        ("As built, a machine never overheating itself", SHUTDOWNS[1][1], True),
        ("The shutdown as stated, a broken machine fighting on", stated, False),
        ("The shutdown as stated, shutting down at once on a break", stated, True),
    ):
        cells = ["%d%%, %.1f, %d%%" % (round(l), r, round(p)) for l, r, p in (_cell(build, pack, a, n, hull, 4, eager, None, 30) for _, pack in longs)]
        print("| %s | %s |" % (bname, " | ".join(cells)))
    print()
    print("Which meter sets the clock, a fight of 6 rounds, shutting down at once on a break: of the shutdowns, the share an overheat forced; the shield a forced one found still standing, of the gauge; the heat a taken one left unspent, of the maximum")
    print()
    print("| The pack | A gun of 2 heat | A gun of 4 heat | A gun of 6 heat |")
    print("|---|---|---|---|")
    for pname, pack in build_packs(6, a.blow):
        cells = []
        for heat in (2, 4, 6):
            t = {"forced": 0, "taken": 0, "shield_left": 0, "gauge": 0, "heat_left": 0}
            _cell(stated, pack, a, n, hull, heat, True, t)
            both = max(1, t["forced"] + t["taken"])
            cells.append("%d%%, %d%%, %d%%" % (round(100.0 * t["forced"] / both), round(100.0 * t["shield_left"] / max(1, t["gauge"])), round(100.0 * t["heat_left"] / float(max(1, t["taken"]) * HEAT_MAX))))
        print("| %s | %s |" % (pname, " | ".join(cells)))
    print()
    print("What a gun's heat costs in turns, one machine firing whenever its rule lets it (a maximum of %d; as built it cools %d a round and never overheats): the share of turns it fires in a fight's first six rounds, then at the cap; under the shutdown, the shield of %d its clock alone returns a round" % (HEAT_MAX, COOLING, SQUAD[1]["gauge"]))
    print()
    print("| The gun's heat | As built, six rounds | As built, at the cap | The shutdown, six rounds | The shutdown, at the cap | The shield its clock returns a round |")
    print("|---|---|---|---|---|---|")
    for heat in (2, 3, 4, 5, 6, 8):
        cycle = HEAT_MAX // heat + 2
        print("| %d | %d%% | %d%% | %d%% | %d%% | %.1f |" % (heat, round(100 * pace(heat, 6, False)), round(100 * pace(heat, 600, False, 60)), round(100 * pace(heat, 6, True)), round(100 * pace(heat, 600, True, 60)), SQUAD[1]["gauge"] / float(cycle)))
    print()
    print("A foe that heats the machine it strikes, a fight of 6 rounds: the hull lost, the rounds, the turns passed")
    print()
    hp = GUN_DAMAGE * len(SQUAD) * 6
    burners = [
        ("A blow of 4", [{"hp": hp, "pick": "one", "blows": [4], "rider": None}]),
        ("A blow of 4 and 4 heat", [{"hp": hp, "pick": "one", "blows": [4], "rider": ("heat", 4)}]),
        ("A blow of 4 and 4 heat, at the hottest machine", [{"hp": hp, "pick": "hot", "blows": [4], "rider": ("heat", 4)}]),
        ("A blow of 8", [{"hp": hp, "pick": "one", "blows": [8], "rider": None}]),
        ("A blow of 8 and 4 heat", [{"hp": hp, "pick": "one", "blows": [8], "rider": ("heat", 4)}]),
        ("A blow of 8 and 4 heat, at the hottest machine", [{"hp": hp, "pick": "hot", "blows": [8], "rider": ("heat", 4)}]),
    ]
    rows = [
        ("As built", SHUTDOWNS[0][1], True),
        ("As built, a machine never overheating itself", SHUTDOWNS[1][1], True),
        ("The shutdown as stated, a broken machine fighting on", stated, False),
        ("The shutdown as stated, shutting down at once on a break", stated, True),
        ("The same, the overheat taking the shield down at once", dict(SHUTDOWN, crash=True), True),
        ("The same, the overheat's excess off the hull", dict(SHUTDOWN, burn=True), True),
    ]
    print("| The rule and the play | " + " | ".join(b for b, _ in burners) + " |")
    print("|---|" + "---|" * len(burners))
    for bname, build, eager in rows:
        cells = ["%d%%, %.1f, %d%%" % (round(l), r, round(p)) for l, r, p in (_cell(build, pack, a, n, hull, 4, eager) for _, pack in burners)]
        print("| %s | %s |" % (bname, " | ".join(cells)))
    print()


def choice_packs(length, blow):
    out = [(p, k) for p, k in build_packs(length, blow) if "two strikes" not in p]
    hp = GUN_DAMAGE * len(SQUAD) * length
    out.append(("A lone foe, %d at the hottest machine" % blow, [{"hp": hp, "pick": "hot", "blows": [blow], "rider": None}]))
    out.append(("A lone foe, %d at the least shield" % blow, [{"hp": hp, "pick": "bare", "blows": [blow], "rider": None}]))
    return out


def choice(a):
    hull = float(sum(m["hull"] for m in SQUAD))
    n = max(1, a.trials // 3)

    def cells(build, play, packs_, heat=4, cap=16):
        return ["%d%%, %.1f, %d%%" % (round(l), r, round(p)) for l, r, p in (_cell(build, pack, a, n, hull, heat, play, None, cap) for _, pack in packs_)]

    def play_of(build):
        return "timed" if build.get("choice") else True

    print("The reboot by choice, 13 November: the same squad and gun, the pack dealing %d a round, a die that is a dud one round in five, %d fights a cell. No content." % (a.blow, n))
    print()
    for length in (4, 6):
        ps = choice_packs(length, a.blow)
        print("A fight of %d rounds at full fire, the reboot by choice played reading the picks: the hull lost, the rounds, the turns not fired" % length)
        print()
        print("| The rule | " + " | ".join(p for p, _ in ps) + " |")
        print("|---|" + "---|" * len(ps))
        for bname, build in CHOICES:
            print("| %s | %s |" % (bname, " | ".join(cells(build, play_of(build), ps))))
        print()
    for length in (4, 6):
        ps = choice_packs(length, a.blow)
        print("The reboot by choice by the way it is played, a fight of %d rounds: the hull lost, the rounds, the turns not fired" % length)
        print()
        print("| The play | " + " | ".join(p for p, _ in ps) + " |")
        print("|---|" + "---|" * len(ps))
        for play, label in PLAYS:
            print("| %s | %s |" % (label, " | ".join(cells(CHOICE, play, ps))))
        print()
    ps = choice_packs(4, a.blow)
    print("What emptying the shield buys, a fight of 4 rounds, the squad rebooting at half a shield or less: the hull lost, the rounds, the turns not fired")
    print()
    print("| The rule | " + " | ".join(p for p, _ in ps) + " |")
    print("|---|" + "---|" * len(ps))
    print("| A reboot empties the shield | %s |" % " | ".join(cells(CHOICE, "greedy", ps)))
    print("| A reboot keeps a standing shield | %s |" % " | ".join(cells(dict(CHOICE, keeps=True), "greedy", ps)))
    print()
    print("By the gun's heat, a fight of 4 rounds against the lone blow: the hull lost, the rounds, the turns not fired")
    print()
    print("| The rule | A gun of 2 heat | A gun of 4 heat | A gun of 6 heat |")
    print("|---|---|---|---|")
    lone = build_packs(4, a.blow)[0][1]
    for bname, build in CHOICES:
        row = ["%d%%, %.1f, %d%%" % (round(l), r, round(p)) for l, r, p in (_cell(build, lone, a, n, hull, heat, play_of(build)) for heat in (2, 4, 6))]
        print("| %s | %s |" % (bname, " | ".join(row)))
    print()
    print("A gun's heat in turns, one machine firing whenever its rule lets it and never burning (a maximum of %d): the share of turns it fires at the cap" % HEAT_MAX)
    print()
    print("| The gun's heat | As built, cooling %d | The shutdown of section 20 | The reboot by choice | The same, one shot past the maximum before each reboot, and the hull it burns |" % COOLING)
    print("|---|---|---|---|---|")
    for heat in (2, 3, 4, 5, 6, 8):
        shots = HEAT_MAX // heat
        over = (shots + 1) * heat - HEAT_MAX
        print("| %d | %d%% | %d%% | %d%% | %d%%, %d |" % (heat, round(100 * pace(heat, 600, False, 60)), round(100 * pace(heat, 600, True, 60)), round(100.0 * shots / (shots + 1)), round(100.0 * (shots + 1) / (shots + 2)), over))
    print()
    print("What the reboots were, a fight of 6 rounds, the squad reading the picks: reboots a machine a fight; the share taken with a blow coming; the shield a reboot gave up, of the gauge; the heat it left unspent, of the maximum; turns held at the maximum a machine a fight")
    print()
    print("| The pack | A gun of 4 heat | A gun of 6 heat |")
    print("|---|---|---|")
    for pname, pack in choice_packs(6, a.blow):
        row = []
        for heat in (4, 6):
            t = {"reboots": 0, "shield_left": 0, "gauge": 0, "heat_left": 0, "under_fire": 0, "held": 0, "pushed": 0}
            _cell(CHOICE, pack, a, n, hull, heat, "timed", t)
            rb = max(1, t["reboots"])
            row.append("%.1f, %d%%, %d%%, %d%%, %.1f" % (t["reboots"] / float(n * len(SQUAD)), round(100.0 * t["under_fire"] / rb), round(100.0 * t["shield_left"] / max(1, t["gauge"])), round(100.0 * t["heat_left"] / float(rb * HEAT_MAX)), t["held"] / float(n * len(SQUAD))))
        print("| %s | %s |" % (pname, " | ".join(row)))
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
    ap.add_argument("--shutdown", action="store_true", help="the shutdown as he stated it on 13 November, and the points it leaves open")
    ap.add_argument("--choice", action="store_true", help="the reboot by choice, his form of the same day: ride at the maximum, a reboot empties the shield")
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
    if a.shutdown:
        shutdown(a)
        return
    if a.choice:
        choice(a)
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
