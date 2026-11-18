#!/usr/bin/env python3
"""What a fight costs a squad, as the hull budget counts it. Apart from the game's content.

Ryan, 13 November: "It's all part of the same system, not just how hard the foes hit, but HOW
they hit that matters. Ergo we need to be thinking theoretically and critically about the
system as a whole and how it fits together, and build simple models perhaps, before slamming
it against the whole game as it stands." His budget, 9 November: a formation's fight costs a
twentieth of the squad's hull at its rating, a flanker's a thirtieth or less, a hunter's a
tenth, an elite's a quarter, the boss what is left.

The reboot is the rule (docs/rules.md, The reboot): nothing mends or cools by itself. So a
squad meets a fight with a fixed pool, its shields, and buys the pool again with a turn. A
fight's cost is what the foes offer past that pool. This model plays that and nothing else:

  - A machine has a shield, a hull and a gauge of 12, and one gun, 3 for 4 heat. It fires
    every turn it can. It reboots, giving its turn, when its next shot would pass the gauge
    or when its shield is broken and a blow is on its way: bare that turn, cold and whole as
    the next round opens.
  - A foe has hit points, a blow, plate, and the share of rounds it strikes rather than
    doing its other move. The front rank shelters the back from a Direct gun; one shot in
    four is Indirect and takes the back's weakest. The squad kills what it can kill first.
  - Each foe that strikes picks a machine level, passing one the blows already picked would
    wreck. A blow takes the shield up to its number and the rest reaches the hull.

No dice, no riders, no kits, no armour on the machines: the tables say what a shape of pack
costs, never what a named fight does. The bot at the anchor says that (tools/anchor_read.gd).

How far to trust it, its last table: against the bot's read of 17 November it lands on a duel
and on a pack of wolves, where a kit has little to add, and it reads a formation at two to
three times the bot's, since a squad of three brings kits, rerolls, plate and a Barrier that
this squad lacks. So read a formation's cells against each other, never as a number: what a
point on the blow, a foe more or a hit point past the gun's kill line does to the cost.

    python3 tools/budget_model.py                 # the tables, as markdown
    python3 tools/budget_model.py --trials 4000   # steadier cells

Hull is a share of a squad of four's, as the anchor reads it: four machines of the standard
hull, whatever the fight's rating.
"""
import argparse
import random

SHIELD = 8        # the standard machine: tier one's run 6 to 12
HULL = 24         # and 20 to 36
GAUGE = 12
GUN = 3
GUN_HEAT = 4
INDIRECT = 0.25   # one shot in four reaches the back rank


class Machine:
    def __init__(self):
        self.shield = SHIELD
        self.hull = HULL
        self.heat = 0
        self.rebooting = False


class Foe:
    def __init__(self, hp, blow, strikes=0.67, plate=0, back=False, regrow=0):
        self.hp = hp
        self.hp_max = hp
        self.blow = blow
        self.strikes = strikes   # the share of rounds it strikes
        self.plate = plate
        self.back = back
        self.regrow = regrow     # hit points it mends on a round it does not strike


def fight(n, pack, rng, cap=30):
    """One fight: n machines against a pack. Returns (rounds, hull lost, reboots, wrecks)."""
    squad = [Machine() for _ in range(n)]
    foes = [Foe(f.hp, f.blow, f.strikes, f.plate, f.back, f.regrow) for f in pack]
    rounds = 0
    reboots = 0
    while rounds < cap:
        live = [f for f in foes if f.hp > 0]
        up = [m for m in squad if m.hull > 0]
        if not live or not up:
            break
        rounds += 1
        # The round opens: a reboot's recovery lands, then the foes pick and show.
        for m in up:
            if m.rebooting:
                m.rebooting = False
                m.shield = SHIELD
        picks = []
        doomed = {}
        for f in live:
            if rng.random() >= f.strikes:
                f.hp = min(f.hp_max, f.hp + f.regrow)
                continue
            open_to = [m for m in up if doomed.get(m, 0) < m.shield + m.hull] or up
            m = rng.choice(open_to)
            doomed[m] = doomed.get(m, 0) + f.blow
            picks.append((f, m))
        # The player's turn: reboot or fire.
        for m in up:
            aimed = any(t is m for _, t in picks)
            if m.heat + GUN_HEAT > GAUGE or (m.shield == 0 and aimed and m.heat >= GUN_HEAT):
                m.rebooting = True
                m.shield = 0
                m.heat = 0
                reboots += 1
                continue
            m.heat += GUN_HEAT
            front = [f for f in foes if f.hp > 0 and not f.back]
            back = [f for f in foes if f.hp > 0 and f.back]
            reach = back if (back and (not front or rng.random() < INDIRECT)) else front
            if not reach:
                continue
            # A kill first, the weakest of them; else the foe nearest one.
            kills = [f for f in reach if f.hp <= GUN - f.plate]
            target = min(kills or reach, key=lambda f: f.hp)
            target.hp -= max(0, GUN - target.plate)
        # The foes' turn: those still standing land what they showed.
        for f, m in picks:
            if f.hp <= 0 or m.hull <= 0:
                continue
            took = min(m.shield, f.blow)
            m.shield -= took
            m.hull -= f.blow - took
    lost = sum(HULL - max(0, m.hull) for m in squad)
    wrecks = sum(1 for m in squad if m.hull <= 0)
    return rounds, lost, reboots / float(n), wrecks


def cell(n, pack, trials, seed):
    rng = random.Random(seed)
    r = h = b = w = 0.0
    for _ in range(trials):
        a = fight(n, pack, rng)
        r += a[0]; h += a[1]; b += a[2]; w += a[3]
    four = 4.0 * HULL
    return r / trials, 100.0 * h / trials / four, b / trials, w / trials


def say(c):
    return "%.1f, %.1f%%" % (c[0], c[1])


def table(title, heads, rows):
    print("\n**%s**\n" % title)
    print("| " + " | ".join(heads) + " |")
    print("|" + "---|" * len(heads))
    for row in rows:
        print("| " + " | ".join(row) + " |")


def horde(count, hp, blow, back_blow=None, strikes=0.67):
    """Half in front, half behind: the back strikes for back_blow (the front's blow if none)."""
    half = count // 2
    return [Foe(hp, blow, strikes) for _ in range(count - half)] + [Foe(hp, back_blow or blow, strikes, back=True) for _ in range(half)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=2000)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()
    t, s = a.trials, a.seed
    print("What a fight costs a squad, apart from content: %d fights a cell. Each cell is rounds, then hull lost as a share of a four's (%d points)." % (t, 4 * HULL))
    print("The budget: a formation 5%, a lone flanker 3.3% or less, a hunter's pack 10%, an elite 25%.")

    blows = [2, 3, 4, 5]
    table("A formation for three machines: a horde of eight, four in front and four behind, by its blow and its hit points",
        ["Hit points"] + ["A blow of %d" % b for b in blows],
        [[str(hp)] + [say(cell(3, horde(8, hp, b), t, s)) for b in blows] for hp in [3, 4, 5, 6]])

    table("The same horde of 4s by its count, and by what the back rank strikes for",
        ["The horde", "A blow of 3", "Front 4, back 3", "A blow of 4"],
        [["%d foes" % c, say(cell(3, horde(c, 4, 3), t, s)), say(cell(3, horde(c, 4, 4, 3), t, s)), say(cell(3, horde(c, 4, 4), t, s))] for c in [6, 7, 8]])

    def led(hp, blow, plate, regrow, rest_blow, rest=6):
        return [Foe(hp, blow, 0.67, plate, regrow=regrow)] + horde(rest, 4, rest_blow)
    table("A massive in front of six 4s, for three machines: by the massive's blow, its hit points behind a point of plate, and what it mends on a round it does not strike",
        ["The massive", "Its six strike for 3", "For 4"],
        [["%d hit points, a blow of %d%s" % (hp, bl, (", mends %d" % rg) if rg else ""), say(cell(3, led(hp, bl, 1, rg, 3), t, s)), say(cell(3, led(hp, bl, 1, rg, 4), t, s))]
            for hp, bl, rg in [(12, 5, 0), (14, 4, 0), (14, 6, 0), (16, 7, 0), (16, 7, 3), (16, 5, 3), (20, 7, 0)]])

    table("A lone flanker against one machine: by its hit points and its blow",
        ["Hit points"] + ["A blow of %d" % b for b in [3, 4, 5, 6]],
        [[str(hp)] + [say(cell(1, [Foe(hp, b)], t, s)) for b in [3, 4, 5, 6]] for hp in [8, 10, 12, 14]])

    table("A hunter's pack against two machines: by its count, its hit points and its blow",
        ["The pack"] + ["A blow of %d" % b for b in [3, 4, 5, 6]],
        [["%d of %d hit points" % (c, hp)] + [say(cell(2, [Foe(hp, b) for _ in range(c)], t, s)) for b in [3, 4, 5, 6]] for c, hp in [(3, 6), (4, 6), (4, 7), (3, 8)]])

    table("An elite against four machines: one foe by its hit points and its blow, striking every round, alone and with four 4s that strike for 3",
        ["The elite"] + ["A blow of %d" % b for b in [8, 10, 12, 14]],
        [["%d hit points%s" % (hp, ", with four" if esc else "")] + [say(cell(4, [Foe(hp, b, 1.0)] + (horde(4, 4, 3) if esc else []), t, s)) for b in [8, 10, 12, 14]]
            for hp, esc in [(30, False), (40, False), (30, True), (40, True)]])

    # The bot's read of the same shapes, tier one at the anchor (docs/measurements.md, 17 November).
    table("How far to trust it: the model beside the bot's read of the shape it stands for",
        ["The shape", "The model", "The bot, 17 November"],
        [["A lone flanker of 14 hit points, a blow of 4 (the roc)", say(cell(1, [Foe(14, 4)], t, s)), "6.3, 3.4%"],
         ["A lone flanker of 12 hit points, a blow of 5 (the whisker cat)", say(cell(1, [Foe(12, 5)], t, s)), "4.8, 5.4%"],
         ["A lone flanker of 10 hit points, a blow of 5 (the dullahan, the cerberus)", say(cell(1, [Foe(10, 5)], t, s)), "7.4 and 4.7, 7.4%"],
         ["Four of 7 hit points, a blow of 4 (the wolf pack)", say(cell(2, [Foe(7, 4) for _ in range(4)], t, s)), "6.0, 15.1%"],
         ["Four 4s in front striking for 4, four behind for 3 every round (the goblin horde)", say(cell(3, [Foe(4, 4) for _ in range(4)] + [Foe(4, 3, 1.0, back=True) for _ in range(4)], t, s)), "5.2, 7.1%"],
         ["Four 2s in front, four 4s behind, a blow of 3 (the needler thicket)", say(cell(3, [Foe(2, 3, 1.0) for _ in range(4)] + [Foe(4, 3, back=True) for _ in range(4)], t, s)), "4.1, 2.1%"]])

if __name__ == "__main__":
    main()
