#!/usr/bin/env python3
"""A small model of the stock basics, apart from the game's content.

Ryan, 14 November: "A 'standard' vanilla shot should be 1 less than our 'standard' fodder
health, whatever that is. So if a goblin, the most basic swarm unit, is 4, then we set a
normal, no rider, direct gun at 3 ... a basic with one decent rider gets -1 damage, and one
with a more powerful effect gets -2, and so on until it turns into Equipment by dealing no
damage ... a 4 damage shot is premium since it prevents one instance of damage. That needs to
cost something, and for basics, the only cost we should have is Heat."

Three machines stand against a pack of rank and file. Each machine fires one gun a round, a
gun is a number and a heat, a foe is hit points, plate and a blow, and a foe that is dead
before the foes' turn strikes nobody. Heat runs under the reboot (the refit brief's section
22): nothing cools, a machine past its maximum may not fire without burning, and a reboot
gives the turn. Nothing else of the game is here: no dice, no reach, no shield, no riders, no
content. So the tables say what a gun's number does against a foe's, never what a fight costs.

    python3 tools/basics_model.py            # the tables, as markdown
    python3 tools/basics_model.py --machines 4 --cap 14

What it prints:
  1. Shots to kill, by a foe's hit points and plate and a gun's number.
  2. The pairs of guns that kill a foe of 3, 4 and 5 between them: the room a rider has.
  3. A fight with heat left out: rounds and blows taken, by the gun and the pack.
  4. The same fight under the reboot, the guns held and the pack changed: a vanilla of 3 at
     three prices, and the gun of 4 beside it from the vanilla's own heat to the maximum. Each
     cell is rounds, blows taken, and the blows that landed while the squad stood bare.
  5. How often a die shows one entry, by how many of its six hold it and the rerolls given it.
  6. One machine of the squad changed, heat left out: one of its six entries dealing one more,
     against every weapon of its dealing one more from the second round (a lasting amp), by
     the vanilla's number.
  7. The ladder by the standard foe's hit points, 3 to 6, the vanilla one under it: what each
     gun under the vanilla still does to that foe, alone and beside another, and behind a
     point of plate. It answers whether a standard foe of 5 buys anything a 4 does not.
  8. A bench of tier-one guns, each the vanilla with one thing traded (Ryan, 14 November: "a
     hot 4 and a less hot 2x2 ... a variety of combinations of riders, damage, heat, and hit
     counts, and then see what sticks ... and what is redundant enough to cut"): the spends
     each takes to kill five standard foes, a plain 4, a 3 behind a point of plate, a thin 3,
     a thick 6 and a 4 behind plate. Two guns with the same row and the same heat are one gun.
     Priced from the vanilla he settled on 23 November (3 for 4 heat, the Laser Carbine 4 for
     5), with what a gauge of 12 holds of each: its shots before the maximum, and their damage.
"""

import argparse
import math
import random

# The packs: a name, then (hit points, plate, blow) a foe. Counts and numbers are a formation's
# order of size at tier one, no composition of the game's.
PACKS = [
    ("eight thin (3)", [(3, 0, 3)] * 8),
    ("eight standard (4)", [(4, 0, 4)] * 8),
    ("six thick (6)", [(6, 0, 4)] * 6),
    ("six plated (4, plate 1)", [(4, 1, 3)] * 6),
    ("mixed: a big one (16, plate 1), three standard, three thin", [(16, 1, 7)] + [(4, 0, 4)] * 3 + [(3, 0, 3)] * 3),
]


def shots_to_kill(hp, plate, dmg):
    """The shots of `dmg` a foe of `hp` behind `plate` takes; 0 for a gun that cannot hurt it."""
    through = dmg - plate
    return 0 if through <= 0 else math.ceil(hp / through)


def table(title, heads, rows):
    print("\n**%s**\n" % title)
    print("| " + " | ".join(heads) + " |")
    print("|" + "---|" * len(heads))
    for r in rows:
        print("| " + " | ".join(str(c) for c in r) + " |")


def finishes(foes, shots):
    """Whether `shots` (each a damage) kill every foe in `foes` (each [hp, plate, blow]), the
    weakest first."""
    left = sorted(([f[0], f[1]] for f in foes if f[0] > 0), key=lambda f: f[0])
    shots = list(shots)
    for f in left:
        while f[0] > 0 and shots:
            f[0] -= max(shots.pop(0) - f[1], 0)
        if f[0] > 0:
            return False
    return True


def aim(foes, dmg):
    """Focus fire: the foe this shot kills with the least to spare, else the weakest standing."""
    alive = [f for f in foes if f[0] > 0 and dmg - f[1] > 0]
    if not alive:
        return None
    kills = [f for f in alive if f[0] <= dmg - f[1]]
    if kills:
        return max(kills, key=lambda f: f[0])
    return min(alive, key=lambda f: f[0])


def fight(pack, guns, cap=12, heat_on=True, push=True, cap_rounds=40):
    """One fight. `guns` is a function (machine, round) -> (damage, heat) or None for a turn
    with no gun. A machine whose shot would pass its maximum reboots instead, unless the squad's
    shots this round end the fight and `push` lets it fire: the fight ends on the spend that
    kills the last foe, before the turn's end, so that shot is never burnt.
    Returns rounds, blows taken, blows taken while a machine stood bare (its share), shots,
    reboots and foes killed outright by one shot from full."""
    foes = [list(f) for f in pack]
    n = guns.machines
    heat = [0] * n
    booting = [False] * n
    rounds = blows = bare = shots = reboots = oneshots = 0
    while any(f[0] > 0 for f in foes) and rounds < cap_rounds:
        rounds += 1
        for i in range(n):
            if booting[i]:
                booting[i], heat[i] = False, 0
        plan = [guns(i, rounds) for i in range(n)]
        for i in range(n):
            g = plan[i]
            if g is None or not any(f[0] > 0 for f in foes):
                continue
            dmg, h = g
            if heat_on and heat[i] + h > cap:
                rest = [plan[j][0] for j in range(i, n) if plan[j] is not None]
                if not (push and finishes(foes, rest)):
                    booting[i] = True
                    reboots += 1
                    continue
            f = aim(foes, dmg)
            if f is None:
                continue
            if f[0] == f[3] and f[0] <= dmg - f[1]:
                oneshots += 1
            f[0] -= dmg - f[1]
            heat[i] += h
            shots += 1
        live = sum(f[2] for f in foes if f[0] > 0)
        blows += live
        bare += live * sum(booting) / n
    return rounds, blows, bare, shots, reboots, oneshots


class Guns:
    """Every machine the same gun every round."""
    def __init__(self, machines, dmg, heat):
        self.machines, self.dmg, self.heat = machines, dmg, heat

    def __call__(self, i, rnd):
        return (self.dmg, self.heat)


class Dice:
    """The squad's first machine on a die of six, the others on plain vanilla: `hot_entries` of
    its six hold the gun that deals one more, the rest the vanilla, and `amp` adds a point to
    every weapon of its from the second round on (a lasting amp). One roll a round and no
    reroll, seeded."""
    def __init__(self, machines, vanilla, hot, hot_entries, amp, rng):
        self.machines, self.vanilla, self.hot = machines, vanilla, hot
        self.hot_entries, self.amp, self.rng = hot_entries, amp, rng

    def __call__(self, i, rnd):
        if i > 0:
            return self.vanilla   # the squad's other machines: plain dice
        dmg, h = self.hot if self.rng.randrange(6) < self.hot_entries else self.vanilla
        return (dmg + (self.amp if rnd >= 2 else 0), h)


def with_marks(pack):
    """Each foe with its full hit points kept, to tell a kill from full."""
    return [(hp, plate, blow, hp) for hp, plate, blow in pack]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--machines", type=int, default=3)
    ap.add_argument("--cap", type=int, default=12, help="a machine's heat maximum")
    ap.add_argument("--trials", type=int, default=4000)
    a = ap.parse_args()
    m, cap = a.machines, a.cap

    # 1. Shots to kill.
    rows = []
    for hp in range(2, 9):
        for plate in (0, 1):
            if plate and hp not in (4, 6):
                continue
            rows.append(["%d%s" % (hp, ", plate 1" if plate else "")] + [shots_to_kill(hp, plate, d) or "never" for d in range(1, 7)])
    table("1. Shots to kill, by the foe and the gun's number", ["Foe's hit points"] + ["A gun of %d" % d for d in range(1, 7)], rows)

    # 2. The pairs that kill.
    rows = []
    for hp in (3, 4, 5):
        vanilla = hp - 1
        ok, no = [], []
        for x in range(vanilla, 0, -1):
            for y in range(x, 0, -1):
                (ok if x + y >= hp else no).append("%d+%d" % (x, y))
        rows.append([hp, vanilla, ", ".join(ok), ", ".join(no) or "none"])
    table("2. Two guns on one foe: the pairs that kill it, the vanilla one under its hit points", ["Foe's hit points", "The vanilla", "Pairs that kill", "Pairs that do not"], rows)

    # 3. The fight, heat left out.
    rows = []
    for name, pack in PACKS:
        p = with_marks(pack)
        cells = [name]
        for d in (2, 3, 4, 5):
            r, b, _, s, _, _ = fight(p, Guns(m, d, 0), cap, heat_on=False)
            cells.append("%d rounds, %d" % (r, b))
        rows.append(cells)
    table("3. %d machines, heat left out: rounds to clear and the blows taken, by the gun" % m, ["The pack"] + ["A gun of %d" % d for d in (2, 3, 4, 5)], rows)

    # 4. Under the reboot: the guns held, the pack changed.
    def cell(pack, dmg, h):
        r, b, bare, _, boots, _ = fight(with_marks(pack), Guns(m, dmg, h), cap)
        return "%d rounds, %d, %d bare" % (r, b, round(bare))
    rows = []
    for name, pack in PACKS:
        rows.append([name] + [cell(pack, 3, h) for h in (2, 3, 4)] + [cell(pack, 4, h) for h in (3, 4, 6, 8, cap)])
    table("4. Under the reboot, a maximum of %d: rounds, blows taken, and the blows taken bare" % cap,
          ["The pack", "3 for 2 heat", "3 for 3", "3 for 4", "4 for 3 heat", "4 for 4", "4 for 6", "4 for 8", "4 for %d" % cap], rows)

    # 5. How often a die shows an entry.
    rows = []
    for k in (1, 2, 3):
        rows.append(["%d of 6" % k] + ["%d%%" % round(100 * (1 - (1 - k / 6.0) ** (r + 1))) for r in (0, 1, 2)])
    table("5. How often a machine's turn shows an entry, by how many of its six hold it", ["Entries holding it", "No reroll", "One reroll on it", "Two rerolls on it"], rows)

    # 6. One machine changed: a hot entry, or a lasting amp.
    rows = []
    rng = random.Random(7)
    for name, pack in PACKS[:3]:
        p = with_marks(pack)
        for vanilla in (3, 2):
            cells = [name, vanilla]
            for hot_entries, amp in ((0, 0), (1, 0), (2, 0), (0, 1)):
                tot_r = tot_b = tot_o = 0.0
                for _ in range(a.trials):
                    r, b, _, _, _, o = fight(p, Dice(m, (vanilla, 0), (vanilla + 1, 0), hot_entries, amp, rng), cap, heat_on=False)
                    tot_r += r
                    tot_b += b
                    tot_o += o
                cells.append("%.1f rounds, %.0f, %.1f outright" % (tot_r / a.trials, tot_b / a.trials, tot_o / a.trials))
            rows.append(cells)
    table("6. One machine of %d changed, heat left out: rounds, blows taken and foes killed outright (%d fights a cell)" % (m, a.trials),
          ["The pack", "The vanilla", "Plain dice", "One of its six entries deals one more", "Two of its six", "Every weapon of its one more from round two"], rows)

    # 7. The ladder by the standard foe.
    rows = []
    for hp in (3, 4, 5, 6):
        vanilla = hp - 1
        for d in range(vanilla, 0, -1):
            if d == vanilla:
                what = "the vanilla: two shots"
            elif d + d >= hp:
                what = "kills in two of its own: the point paid for its rider is free on this foe"
            else:
                need = hp - d
                what = "kills only beside a gun of %d or more%s" % (need, ", the vanilla alone" if need == vanilla else "")
            plated = shots_to_kill(hp, 1, d)
            rows.append([hp, d, "%d under" % (vanilla - d) if d < vanilla else "", what, plated or "never"])
    table("7. The ladder by the standard foe: each gun from the vanilla down, on that foe", ["The standard foe", "A gun of", "Paid for a rider", "On the standard foe", "Shots behind a point of plate"], rows)

    # 8. The bench: each gun's kill signature across the standard foes.
    bench = [   # name, damage a strike, strikes, heat
        ("The vanilla: 3", 3, 1, 4),
        ("One more for a point of heat: 4", 4, 1, 5),
        ("One more, split: 2 twice", 2, 2, 4),
        ("Split fine: 1 four times", 1, 4, 4),
        ("A point less for a rider: 2", 2, 1, 4),
        ("The rider kept for a point of heat: 3", 3, 1, 5),
        ("The rider kept twice over: 3", 3, 1, 6),
        ("Two more: 5", 5, 1, 7),
        ("Three more: 6", 6, 1, 9),
        ("Six, split: 2 three times", 2, 3, 6),
        ("One more on the indirect gun: 4", 4, 1, 6),
    ]
    marks = [("a plain 4", 4, 0), ("3 behind plate", 3, 1), ("a thin 3", 3, 0), ("a thick 6", 6, 0), ("4 behind plate", 4, 1)]
    def spends(hp, plate, dmg, strikes):
        through = (dmg - plate) * strikes
        return "never" if through <= 0 else math.ceil(hp / through)
    seen = {}
    rows = []
    for name, dmg, strikes, h in bench:
        sig = tuple(spends(hp, plate, dmg, strikes) for _, hp, plate in marks)
        same = seen.get(sig, "")
        seen.setdefault(sig, name)
        shots = 12 // h
        rows.append([name, h, "%d, %d damage" % (shots, shots * dmg * strikes)] + list(sig) + [("as " + same.split(":")[0].lower()) if same else ""])
    table("8. A bench of guns, each the vanilla with one thing traded: spends to kill", ["The gun", "Heat", "Shots a gauge of 12"] + [m_[0].capitalize() for m_ in marks] + ["The same kills"], rows)


if __name__ == "__main__":
    main()
