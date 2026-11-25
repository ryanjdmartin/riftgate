#!/usr/bin/env python3
"""The lure tank's drone as a duel: what its lock buys and costs, by how it ends. Apart from content.

Ryan, 25 November: "It has a drone. setting the drone on a target entangles them together.
Only the lure tank can target the entangled target, and the entangled target can only target
the lure tank." The brief is docs/briefs/minerva_lure_tank.md.

The reboot is the rule (docs/rules.md, The reboot), so this plays it: a squad of three, a gun
of 3 for 4 heat on a gauge of 12, a shield that takes a hit first and stays Broken until its
Frame gives a turn to a reboot, bare that turn and whole the next. A standard Frame has shield
8 and hull 24; the tank shield 8, hull 36 and armour 2. A Sprite picks its move by weight and
its target level as the round opens, passing a Frame the hits already picked would wreck.

The packs are tier one's as content has them (25 November), riders left out: the Nob alone, the
Fell Rider alone with its hit on every Frame, the Old Man with two Needlers, the Treant's grove
and the Goblin horde.

The drone's lock, by how it ends:
  none    no drone: the tank is its plate alone
  tight   Ryan's words as written: no other Frame may aim at the entangled Sprite; the drone
          comes home when its Sprite is defeated or its tank reboots, and a Sprite let go that
          way picks again
  slip    another Frame may aim at it, which sends the drone home, dark until its tank reboots;
          a Sprite the tank defeats itself leaves the drone ready, and the lock holds through
          its tank's reboot
  free    as slip, with nothing dark: the drone is ready again at once (the bench's free cover)
Set mid-turn, the lock turns its Sprite's pick onto the tank, as a Lure does. A pick is a
commitment: a Sprite another Frame's aim lets go keeps this round's pick, and lands it on a
tank whose edge against it went with the lock.

The tank's edge against its Sprite: front N, N more armour that meets the hit before the
shield does; plate N, the same armour after the shield, as armour stands everywhere else; half,
the hit halved, rounded up; first, the drone taking its Sprite's first hit; barrier, a Barrier
as the drone is set. Sealed keeps the entangled Sprite's hit on every Frame to the tank alone.
The drone's lure: none; set, the Sprites beside its target turn on the tank the round it is
set (Lure and Spread on the piece); hold, every round the lock holds.

Read a pack's cells against each other, never as a number: this squad has no kit, no rerolls
and no riders, and the Sprites none either (tools/budget_model.py says how far such a squad
sits from the bot's read). The tank's policy is plain: the drone onto the biggest hitter when
its entry shows, held; the others open the cage once nothing else stands, or reboot under it.

    python3 tools/lure_duel_model.py                 # the tables
    python3 tools/lure_duel_model.py --trials 4000   # steadier cells
    python3 tools/lure_duel_model.py --shows 1       # a drone no die rolls: there whenever wanted
"""
import argparse
import random

GAUGE = 12
GUN = 3
GUN_HEAT = 4
SHOWS = 0.67   # the drone's entry on a die of four, two rerolls spent looking for it (--shows)


class Frame:
    def __init__(self, tank=False):
        self.tank = tank
        self.shield_max = 8
        self.hull_max = 36 if tank else 24
        self.armour = 2 if tank else 0
        self.shield = self.shield_max
        self.hull = self.hull_max
        self.heat = 0
        self.rebooting = False
        self.barrier = False


class Sprite:
    def __init__(self, name, hp, moves, plate=0):
        self.name = name
        self.hp = hp
        self.plate = plate
        self.moves = moves   # (weight, kind, number): "hit" at one Frame, "all" at every Frame, "idle"
        self.move = None
        self.target = None

    def biggest(self):
        return max([n for _, k, n in self.moves if k == "hit"] or [0])


def pack(kind):
    goblin = lambda: Sprite("goblin", 4, [(2, "hit", 4), (1, "idle", 0)])
    mandragora = lambda: Sprite("mandragora", 3, [(2, "hit", 2)])
    needler = lambda: Sprite("needler", 4, [(2, "hit", 4)])
    if kind == "nob":
        return [Sprite("nob", 60, [(2, "hit", 14), (2, "hit", 8)])]
    if kind == "fell_rider":
        return [Sprite("fell rider", 48, [(2, "hit", 16), (1, "idle", 0), (2, "all", 6)])]
    if kind == "old_man":
        return [Sprite("old man", 44, [(2, "hit", 11), (1, "idle", 0), (2, "all", 7)], plate=1), needler(), needler()]
    if kind == "treant":
        return [Sprite("treant", 14, [(2, "hit", 6), (1, "idle", 0)], plate=1), goblin(), goblin(), goblin(), mandragora(), mandragora()]
    if kind == "horde":
        return [goblin(), goblin(), goblin(), goblin(), mandragora(), mandragora(), mandragora(), mandragora()]
    raise ValueError(kind)


PACKS = [("nob", "The Nob alone"), ("fell_rider", "The Fell Rider alone"), ("old_man", "The Old Man, two Needlers"),
         ("treant", "The Treant's grove"), ("horde", "The Goblin horde")]


def beside(foes, partner):
    """The Sprites standing next to the drone's: the list is the rank, left to right."""
    i = foes.index(partner)
    return [f for f in (foes[i - 1] if i > 0 else None, foes[i + 1] if i + 1 < len(foes) else None) if f is not None and f.hp > 0]


def fight(kind, squad_kind, lock, duel, sealed, sync, rng, shows=SHOWS, lure="none", cap=40):
    squad = [Frame(tank=(squad_kind == "tank" and i == 0)) for i in range(3)]
    tank = squad[0] if squad_kind == "tank" else None
    foes = pack(kind)
    partner = None        # the Sprite the drone is on
    dark = False          # the drone waits on its tank's reboot
    fresh = False         # the drone has yet to take its Sprite's first hit (--duel first)
    rounds = 0
    idle = 0              # the allies' turns with nothing they may aim at
    while rounds < cap:
        live = [f for f in foes if f.hp > 0]
        up = [m for m in squad if m.hull > 0]
        if not live or not up:
            break
        rounds += 1
        if partner is not None and (partner.hp <= 0 or tank.hull <= 0):
            partner = None
        # The round opens: a reboot's recovery, then every Sprite picks and shows.
        for m in up:
            if m.rebooting:
                m.rebooting = False
                m.shield = m.shield_max
                if m.tank:
                    dark = False
            m.barrier = False
        doomed = {}
        for f in live:
            total = sum(w for w, _, _ in f.moves)
            r = rng.random() * total
            for w, k, n in f.moves:
                r -= w
                if r < 0:
                    f.move = (k, n)
                    break
            f.target = None
            if f.move[0] == "hit":
                if f is partner or (lure == "hold" and partner is not None and f in beside(foes, partner)):
                    f.target = tank
                else:
                    open_to = [m for m in up if doomed.get(m, 0) < m.shield + m.hull] or up
                    f.target = rng.choice(open_to)
                doomed[f.target] = doomed.get(f.target, 0) + f.move[1]
        # Your turn. Reboots first, as the player reads them off the intents.
        acting = []
        for m in up:
            aimed = any(f.target is m for f in live)
            must = m.heat + GUN_HEAT > GAUGE or (m.shield == 0 and aimed and m.heat >= GUN_HEAT)
            if m.tank and dark and m.shield == 0 and m.heat >= GUN_HEAT:
                must = True   # nothing to hold and nothing to hold it with: fetch the drone
            if not m.tank and sync and partner is not None and m.heat >= 2 * GUN_HEAT \
                    and all(f is partner for f in live):
                must = True   # the squad's safe reboot, under the tank's hold
            if must:
                m.rebooting = True
                m.shield = 0
                m.heat = 0
                if m.tank and partner is not None and lock == "tight":
                    # The drone comes home with its tank's reboot, and its Sprite picks again.
                    if partner.move[0] == "hit":
                        partner.target = rng.choice(up)
                    partner = None
            else:
                acting.append(m)

        def shoot(m, pool):
            kills = [f for f in pool if f.hp <= GUN - f.plate]
            t = min(kills or pool, key=lambda f: f.hp)
            t.hp -= max(0, GUN - t.plate)
            m.heat += GUN_HEAT

        # The other Frames fire first, so the tank's lock goes on last.
        for m in acting:
            if m.tank:
                continue
            pool = [f for f in foes if f.hp > 0 and f is not partner]
            if pool:
                shoot(m, pool)
            elif partner is not None and partner.hp > 0 and lock in ("slip", "free"):
                if lock == "slip":
                    dark = True
                partner = None
                shoot(m, [f for f in foes if f.hp > 0])
            elif partner is not None:
                idle += 1
        if tank is not None and tank in acting:
            pool = [f for f in foes if f.hp > 0]
            if pool:
                # The drone goes out when its entry shows: onto the biggest hitter, and held there;
                # among small Sprites it moves to wherever its lure turns the most onto the tank.
                small = partner is None or partner.biggest() < 6
                if lock != "none" and not dark and rng.random() < shows and (partner is None or (lure == "set" and small)):
                    def drawn(f):
                        near = [f] + (beside(foes, f) if lure != "none" else [])
                        return sum(g.move[1] for g in near if g.move[0] == "hit" and g.target is not tank)
                    big = max(pool, key=lambda f: (f.biggest(), f.hp))
                    pick = big if big.biggest() >= 6 else max(pool, key=lambda f: (drawn(f), f.biggest(), f.hp))
                    if pick is not partner:
                        partner = pick
                        fresh = True
                        if partner.move[0] == "hit":
                            partner.target = tank
                        if lure != "none":
                            for f in beside(foes, partner):
                                if f.move[0] == "hit":
                                    f.target = tank
                    if duel == "barrier":
                        tank.barrier = True
                shoot(tank, [partner] if partner is not None and partner.hp > 0 else pool)
        if partner is not None and partner.hp <= 0:
            partner = None
        # The Sprites' turn.
        for f in foes:
            if f.hp <= 0:
                continue
            k, n = f.move
            if k == "idle":
                continue
            held = f is partner and tank is not None and tank.hull > 0
            if k == "hit":
                t = f.target if f.target is not None and f.target.hull > 0 else next((m for m in squad if m.hull > 0), None)
                hits = [t] if t is not None else []
            else:
                hits = [tank] if (held and sealed) else [m for m in squad if m.hull > 0]
            for m in hits:
                dmg = n
                plate = m.armour
                if m.barrier:
                    m.barrier = False
                    continue
                if held and m is tank:
                    if duel == "half":
                        dmg = (dmg + 1) // 2
                    elif duel.startswith("plate"):
                        plate += int(duel[5:] or 3)
                    elif duel.startswith("front"):
                        # The plate meets its Sprite's hit before the shield does.
                        dmg = max(0, dmg - plate - int(duel[5:] or 4))
                        plate = 0
                    elif duel == "first" and fresh:
                        fresh = False
                        continue
                took = min(m.shield, dmg)
                m.shield -= took
                m.hull -= max(0, dmg - took - plate)
    won = not [f for f in foes if f.hp > 0]
    t_lost = (tank.hull_max - max(0, tank.hull)) if tank is not None else 0
    a_lost = sum(m.hull_max - max(0, m.hull) for m in squad if m is not tank)
    wrecks = sum(1 for m in squad if m.hull <= 0)
    return won, rounds, t_lost, a_lost, wrecks, idle


def cell(kind, squad_kind, lock, duel, sealed, sync, trials, seed, shows=SHOWS, lure="none"):
    rng = random.Random(seed)
    tot = [0.0] * 6
    for _ in range(trials):
        r = fight(kind, squad_kind, lock, duel, sealed, sync, rng, shows, lure)
        for i, v in enumerate(r):
            tot[i] += v
    return [v / trials for v in tot]


ROWS = [
    # label, squad, lock, edge, sealed, the squad reboots under the hold, lure
    ("Three standard Frames", "std", "none", "none", False, False, "none"),
    ("The tank, no drone", "tank", "none", "none", False, False, "none"),
    ("Tight, as written", "tank", "tight", "front4", True, False, "set"),
    ("Slip, the lean", "tank", "slip", "front4", True, True, "set"),
    ("Slip, its storms on every Frame", "tank", "slip", "front4", False, True, "set"),
    ("Slip, no lure", "tank", "slip", "front4", True, True, "none"),
    ("Slip, the lure held", "tank", "slip", "front4", True, True, "hold"),
    ("Slip, plate after the shield", "tank", "slip", "plate4", True, True, "set"),
    ("Slip, hits halved", "tank", "slip", "half", True, True, "set"),
    ("Slip, the drone takes the first hit", "tank", "slip", "first", True, True, "set"),
    ("Free, nothing dark", "tank", "free", "front4", True, True, "set"),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=2000)
    ap.add_argument("--shows", type=float, default=SHOWS, help="how often the drone is there to set when wanted (1 for a drone no die rolls)")
    a = ap.parse_args()
    for kind, title in PACKS:
        print("\n### %s\n" % title)
        print("| The squad | Won | Rounds | Hull lost, the tank | Hull lost, the others | Wrecks | Turns with nothing to aim at |")
        print("|---|---|---|---|---|---|---|")
        for label, sk, lock, duel, sealed, sync, lure in ROWS:
            c = cell(kind, sk, lock, duel, sealed, sync, a.trials, 11, a.shows, lure)
            print("| %s | %.0f%% | %.1f | %.1f | %.1f | %.2f | %.1f |" % (label, 100 * c[0], c[1], c[2], c[3], c[4], c[5]))


if __name__ == "__main__":
    main()
