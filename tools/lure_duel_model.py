#!/usr/bin/env python3
"""The lure tank's drone as a duel: what its lock buys and costs, by how it ends. Apart from content.

Ryan, 25 November: "It has a drone. setting the drone on a target entangles them together.
Only the lure tank can target the entangled target, and the entangled target can only target
the lure tank." The brief is docs/briefs/minerva_lure_tank.md.

A squad of three against one big aimed hitter among adds, round numbers and placeholders:

  - The tank has hull 20 and armour 1, each ally hull 12 and armour 0; each machine deals 4
    a round to the one foe it picks. No shields and no heat: the question here is who takes
    the blows and for how long (under the reboot a broken shield stays broken, so a long
    duel is harder on the tank than this).
  - The brute has 14 HP, armour 1 and one blow a round; three adds have 4 HP and a blow of 2.
    A foe picks a standing machine at random; the entangled brute picks the tank.
  - Without the drone the squad takes the brute first, then the adds. With it, the tank takes
    the brute and its allies the adds, and they cannot pick the brute while the lock holds.

The lock ends four ways: never set (none), held until the brute or the tank falls (hold),
let go once the adds are down at the price of the tank's use that round (recall_spend), and
let go then for nothing (recall_free).

    python3 tools/lure_duel_model.py
"""
import random


def fight(mode: str, blow: int, seed: int) -> tuple:
    rng = random.Random(seed)
    machines = {"tank": [20, 1, 4], "ally a": [12, 0, 4], "ally b": [12, 0, 4]}   # hull, armour, damage
    foes = {"brute": [14, 1, blow], "add 1": [4, 0, 2], "add 2": [4, 0, 2], "add 3": [4, 0, 2]}   # HP, armour, blow
    taken = {k: 0 for k in machines}
    locked = mode != "none"
    rounds = 0
    while foes and any(m[0] > 0 for m in machines.values()) and rounds < 30:
        rounds += 1
        if machines["tank"][0] <= 0:
            locked = False   # the drone falls with the tank: the brute is everyone's again
        spent = False
        if locked and mode.startswith("recall") and all(f == "brute" for f in foes):
            locked = False
            spent = mode == "recall_spend"
        for k in [k for k in machines if machines[k][0] > 0]:
            if not foes or (k == "tank" and spent):
                continue
            if k == "tank":
                pick = "brute" if "brute" in foes else next(iter(foes))
            else:
                pool = [f for f in foes if not (locked and f == "brute")]
                if not pool:
                    continue   # the brute is the tank's, and nothing else stands to pick
                pick = "brute" if "brute" in pool else pool[0]
            foes[pick][0] -= max(0, machines[k][2] - foes[pick][1])
            if foes[pick][0] <= 0:
                del foes[pick]
                if pick == "brute":
                    locked = False
        for name, (_, _, hit) in list(foes.items()):
            standing = [k for k in machines if machines[k][0] > 0]
            if not standing:
                break
            k = "tank" if name == "brute" and locked and machines["tank"][0] > 0 else rng.choice(standing)
            d = max(0, hit - machines[k][1])
            machines[k][0] -= d
            taken[k] += d
    lost = sum(1 for m in machines.values() if m[0] <= 0)
    return not foes, rounds, taken["tank"], taken["ally a"] + taken["ally b"], lost


def main() -> None:
    seeds = 4000
    for blow in (5, 8):
        print("The brute's blow %d, on the tank's armour 1:" % blow)
        print("  %-13s %5s %7s %10s %12s %15s" % ("lock", "won", "rounds", "tank took", "allies took", "machines lost"))
        for mode in ("none", "hold", "recall_spend", "recall_free"):
            rs = [fight(mode, blow, s) for s in range(seeds)]
            avg = lambda i: sum(r[i] for r in rs) / seeds
            print("  %-13s %4.0f%% %7.1f %10.1f %12.1f %15.2f" % (mode, 100 * avg(0), avg(1), avg(2), avg(3), avg(4)))


if __name__ == "__main__":
    main()
