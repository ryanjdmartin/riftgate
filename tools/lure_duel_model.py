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
    python3 tools/lure_duel_model.py --hold          # Ryan's second pass: every hit holds, the reboot breaks it (fight_hold)
    python3 tools/lure_duel_model.py --tether        # the hold priced: a Drone entry, the stun, Hull a round held (fight_tether)
    python3 tools/lure_duel_model.py --ideas         # the ideas past his four, one loop for them all (fight_ideas)
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
    def __init__(self, name, hp, moves, plate=0, resist=1):
        self.name = name
        self.hp = hp
        self.plate = plate
        self.moves = moves   # (weight, kind, number): "hit" at one Frame, "all" at every Frame, "idle"
        self.move = None
        self.target = None
        self.resist = resist   # its stun resist: the Numbed it gains as a stun ends (1, 2 massive, 3 elite)
        self.numbed = 0
        self.stunned = False

    def biggest(self):
        return max([n for _, k, n in self.moves if k == "hit"] or [0])


def pack(kind):
    goblin = lambda: Sprite("goblin", 4, [(2, "hit", 4), (1, "idle", 0)])
    mandragora = lambda: Sprite("mandragora", 3, [(2, "hit", 2)])
    needler = lambda: Sprite("needler", 4, [(2, "hit", 4)])
    if kind == "nob":
        return [Sprite("nob", 60, [(2, "hit", 14), (2, "hit", 8)], resist=3)]
    if kind == "fell_rider":
        return [Sprite("fell rider", 48, [(2, "hit", 16), (1, "idle", 0), (2, "all", 6)], resist=3)]
    if kind == "old_man":
        return [Sprite("old man", 44, [(2, "hit", 11), (1, "idle", 0), (2, "all", 7)], plate=1, resist=3), needler(), needler()]
    if kind == "treant":
        return [Sprite("treant", 14, [(2, "hit", 6), (1, "idle", 0)], plate=1, resist=2), goblin(), goblin(), goblin(), mandragora(), mandragora()]
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


def fight_hold(kind, o, rng, cap=40):
    """Ryan's second pass (25 November): the tank's every use on a Sprite entangles its target,
    its use on itself lets go, the hold costs while it stands, and a reboot breaks it with a stun.

    o: lock (whether the other Frames may aim at the held Sprite: "always" barred, Ryan's words;
    "crowd", barred while another Sprite stands; "none", never barred), tax (Heat the tank gains
    at its turn end while it holds), dot (HP its Sprite loses then),
    stun ("none", "reboot": the reboot's break Suppresses, "every": every break does), letgo (how
    often the tank's die shows a piece it may use on itself: Armoured 2 as it lets go), through
    (the hold outlasts the reboot, no break), plate (armour more against its Sprite, before the
    shield), sealed (its Sprite's hit on every Frame lands on the tank alone), selfbreak (its
    Sprite's move on itself breaks the hold)."""
    squad = [Frame(tank=(i == 0)) for i in range(3)]
    tank = squad[0]
    foes = pack(kind)
    partner = None
    rounds = idle = stuns = reboots = 0
    braced = 0

    def let_go(stun):
        nonlocal partner, stuns
        if partner is not None and partner.hp > 0 and stun:
            if partner.numbed > 0:
                partner.numbed -= 1
            else:
                partner.stunned = True
                stuns += 1
        partner = None

    while rounds < cap:
        live = [f for f in foes if f.hp > 0]
        up = [m for m in squad if m.hull > 0]
        if not live or not up:
            break
        rounds += 1
        if partner is not None and (partner.hp <= 0 or tank.hull <= 0):
            partner = None
        for m in up:
            if m.rebooting:
                m.rebooting = False
                m.shield = m.shield_max
            m.barrier = False
        braced = 0
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
                if f is partner:
                    f.target = tank
                else:
                    open_to = [m for m in up if doomed.get(m, 0) < m.shield + m.hull] or up
                    f.target = rng.choice(open_to)
                doomed[f.target] = doomed.get(f.target, 0) + f.move[1]
        # Your turn: reboots first, as the player reads them off the intents.
        acting = []
        def barred(f):
            """Whether the other Frames may not aim at f: the hold's lock, by o["lock"] (always;
            crowd, while another Sprite stands; none)."""
            if f is not partner or partner is None:
                return False
            lock = o.get("lock", "always")
            if lock == "none":
                return False
            if lock == "crowd":
                return any(g.hp > 0 and g is not partner for g in foes)
            return True

        only_partner = partner is not None and all(f is partner for f in live) and barred(partner)
        for m in up:
            aimed = any(f.target is m for f in live)
            tax = o.get("tax", 0) if (m.tank and partner is not None) else 0
            must = m.heat + GUN_HEAT + tax > GAUGE or (m.shield == 0 and aimed and m.heat >= GUN_HEAT)
            if not m.tank and only_partner and m.heat >= 2 * GUN_HEAT:
                must = True   # the squad's safe reboot, under the tank's hold
            if must:
                m.rebooting = True
                m.shield = 0
                m.heat = 0
                if m.tank:
                    reboots += 1
                    if not o.get("through"):
                        let_go(o.get("stun") in ("reboot", "every"))
            else:
                acting.append(m)
        tank_acts = tank in acting
        # The tank lets go by using something on itself, when its Sprite is all there is to aim at.
        if tank_acts and partner is not None and all(f is partner for f in foes if f.hp > 0) and barred(partner) \
                and rng.random() < o.get("letgo", 0):
            let_go(o.get("stun") == "every")
            braced = 2
            tank_acts = False
        for m in acting:
            if m.tank:
                continue
            pool = [f for f in foes if f.hp > 0 and not barred(f)]
            if pool:
                kills = [f for f in pool if f.hp <= GUN - f.plate]
                t = min(kills or pool, key=lambda f: f.hp)
                t.hp -= max(0, GUN - t.plate)
                m.heat += GUN_HEAT
            else:
                idle += 1
        if tank_acts:
            pool = [f for f in foes if f.hp > 0]
            if pool:
                big = max(pool, key=lambda f: (f.biggest(), f.hp))
                t = partner if (partner is not None and partner.hp > 0 and partner.biggest() >= big.biggest()) else big
                t.hp -= max(0, GUN - t.plate)
                tank.heat += GUN_HEAT
                if t.hp > 0 and t is not partner:
                    let_go(o.get("stun") == "every")
                    partner = t
                    if t.move[0] == "hit":
                        t.target = tank
        if partner is not None and partner.hp <= 0:
            partner = None
        # Your turn's end: the hold's price, then the heat past the maximum.
        if partner is not None and tank.hull > 0:
            tank.heat += o.get("tax", 0)
            partner.hp -= o.get("dot", 0)
            if partner.hp <= 0:
                partner = None
        for m in [m for m in squad if m.hull > 0]:
            if m.heat > GAUGE:
                m.hull -= m.heat - GAUGE
                m.shield = 0
        # The Sprites' turn.
        for f in foes:
            if f.hp <= 0:
                continue
            if f.stunned:
                f.stunned = False
                f.numbed = f.resist
                continue
            k, n = f.move
            held = f is partner and tank.hull > 0
            if held and k == "idle" and o.get("selfbreak"):
                partner = None   # its move on itself breaks it free (the other reading of "targeting itself")
                held = False
            if k == "hit":
                t = f.target if f.target is not None and f.target.hull > 0 else next((m for m in squad if m.hull > 0), None)
                hits = [t] if t is not None else []
            elif k == "all":
                hits = [tank] if (held and o.get("sealed", True)) else [m for m in squad if m.hull > 0]
            else:
                hits = []
            for m in hits:
                dmg = n
                plate = m.armour + (braced if m is tank else 0)
                if held and m is tank and o.get("plate", 0):
                    dmg = max(0, dmg - plate - o["plate"])
                    plate = 0
                took = min(m.shield, dmg)
                m.shield -= took
                m.hull -= max(0, dmg - took - plate)
            if f.numbed > 0:
                f.numbed -= 1
    won = not [f for f in foes if f.hp > 0]
    a_lost = sum(m.hull_max - max(0, m.hull) for m in squad if m is not tank)
    wrecks = sum(1 for m in squad if m.hull <= 0)
    return won, rounds, tank.hull_max - max(0, tank.hull), a_lost, wrecks, idle, stuns, reboots


def hold_cell(kind, o, trials, seed):
    rng = random.Random(seed)
    tot = [0.0] * 8
    for _ in range(trials):
        for i, v in enumerate(fight_hold(kind, o, rng)):
            tot[i] += v
    return [v / trials for v in tot]


HOLD_ROWS = [
    ("1 alone: every hit holds, nothing ends it", {"through": True}),
    ("1 and 4: the reboot breaks it and stuns", {"stun": "reboot"}),
    ("The four: 2 Heat, 2 HP, a let-go", {"stun": "reboot", "tax": 2, "dot": 2, "letgo": 0.5}),
    ("1, 2 and 4, 1 HP, no Heat", {"stun": "reboot", "dot": 1, "letgo": 0.5}),
    ("The same, barred only while another Sprite stands", {"stun": "reboot", "dot": 1, "letgo": 0.5, "lock": "crowd"}),
    ("Never barred: 1 and 4, 1 HP", {"stun": "reboot", "dot": 1, "lock": "none"}),
    ("Never barred, no HP", {"stun": "reboot", "lock": "none"}),
    ("Never barred, no stun", {"dot": 1, "lock": "none"}),
    ("Never barred, 4 Armour against its Sprite", {"stun": "reboot", "dot": 1, "lock": "none", "plate": 4}),
    ("Barred, every break stunning", {"stun": "every", "dot": 1, "letgo": 0.5}),
    ("Barred, its move on itself breaking free", {"stun": "reboot", "dot": 1, "letgo": 0.5, "selfbreak": True}),
]


def fight_tether(kind, o, rng, cap=40):
    """The hold priced in the tank's own guns (26 November, on Ryan's "A free, persistent lure
    without a strong tactical downside is very overpowered"): while it holds a Sprite, its
    weapons are disabled. Nothing bars the squad.

    o: set ("drone", an Integrated entry that shows o["shows"] of the time, used when the
    biggest hitter hits for 6 or more; "hit", every use on a Sprite holds its target), off
    (weapons disabled while it holds), stun (its reboot breaks the hold with a Suppress), equip
    (how often its die shows equipment while it holds: 2 off the held Sprite's hit that round,
    a Sap or a brace), shows, break (what its reboot does to the hold: "stun", "repick" (its
    Sprite picks again), "none" (let go, its pick standing), "keep" (the hold outlasts it)),
    burn (Hull the tank loses each round it holds), persist (False: a plain Lure, the round's)."""
    squad = [Frame(tank=(i == 0)) for i in range(3)]
    tank = squad[0]
    foes = pack(kind)
    partner = None
    rounds = stuns = shots = held = 0
    while rounds < cap:
        live = [f for f in foes if f.hp > 0]
        up = [m for m in squad if m.hull > 0]
        if not live or not up:
            break
        rounds += 1
        if partner is not None and (partner.hp <= 0 or tank.hull <= 0):
            partner = None
        for m in up:
            if m.rebooting:
                m.rebooting = False
                m.shield = m.shield_max
        sap = 0
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
                if f is partner:
                    f.target = tank
                else:
                    open_to = [m for m in up if doomed.get(m, 0) < m.shield + m.hull] or up
                    f.target = rng.choice(open_to)
                doomed[f.target] = doomed.get(f.target, 0) + f.move[1]
        acting = []
        for m in up:
            aimed = any(f.target is m for f in live)
            if m.tank:
                must = m.shield == 0 or m.heat + GUN_HEAT > GAUGE   # the tank's shield is its job
            else:
                must = m.heat + GUN_HEAT > GAUGE or (m.shield == 0 and aimed and m.heat >= GUN_HEAT)
            if must:
                m.rebooting = True
                m.shield = 0
                m.heat = 0
                if m.tank and partner is not None:
                    brk = o.get("break", "stun" if o.get("stun") else "none")
                    if brk == "stun" and partner.hp > 0:
                        if partner.numbed > 0:
                            partner.numbed -= 1
                        else:
                            partner.stunned = True
                            stuns += 1
                    elif brk == "repick" and partner.hp > 0 and partner.move[0] == "hit":
                        partner.target = rng.choice([x for x in squad if x.hull > 0])
                    if brk != "keep":
                        partner = None
            else:
                acting.append(m)

        def shoot(m, pool):
            kills = [f for f in pool if f.hp <= GUN - f.plate]
            t = min(kills or pool, key=lambda f: f.hp)
            t.hp -= max(0, GUN - t.plate)
            m.heat += GUN_HEAT
            return t

        for m in acting:
            if m.tank:
                continue
            pool = [f for f in foes if f.hp > 0]
            if pool:
                shoot(m, pool)
        if partner is not None and partner.hp <= 0:
            partner = None   # weapons back the moment it is defeated
        if tank in acting:
            pool = [f for f in foes if f.hp > 0]
            if pool:
                big = max(pool, key=lambda f: (f.biggest(), f.hp))
                if partner is not None and o.get("off", True):
                    if rng.random() < o.get("equip", 0):
                        sap = 2
                        tank.heat += 1
                elif o.get("set") == "drone" and partner is None and big.biggest() >= 6 and tank.shield > 0 \
                        and rng.random() < o.get("shows", SHOWS):
                    partner = big
                    if big.move[0] == "hit":
                        big.target = tank
                    tank.heat += 1
                else:
                    if o.get("set") == "hit":
                        t = partner if partner is not None and partner.hp > 0 else big
                        t.hp -= max(0, GUN - t.plate)
                        tank.heat += GUN_HEAT
                        shots += 1
                        if t.hp > 0 and t is not partner:
                            partner = t
                            if t.move[0] == "hit":
                                t.target = tank
                    else:
                        shoot(tank, pool)
                        shots += 1
        if partner is not None and partner.hp <= 0:
            partner = None
        if partner is not None:
            held += 1
            tank.hull -= o.get("burn", 0)   # the tether's price, past Shield and Armour
        for f in foes:
            if f.hp <= 0:
                continue
            if f.stunned:
                f.stunned = False
                f.numbed = f.resist
                continue
            k, n = f.move
            is_held = f is partner and tank.hull > 0
            if k == "hit":
                t = f.target if f.target is not None and f.target.hull > 0 else next((m for m in squad if m.hull > 0), None)
                hits = [t] if t is not None else []
            elif k == "all":
                hits = [tank] if is_held else [m for m in squad if m.hull > 0]
            else:
                hits = []
            for m in hits:
                dmg = max(0, n - (sap if is_held else 0))
                took = min(m.shield, dmg)
                m.shield -= took
                m.hull -= max(0, dmg - took - m.armour)
            if f.numbed > 0:
                f.numbed -= 1
        if not o.get("persist", True):
            partner = None   # a plain Lure: the round's pick and no more
    won = not [f for f in foes if f.hp > 0]
    a_lost = sum(m.hull_max - max(0, m.hull) for m in squad if m is not tank)
    wrecks = sum(1 for m in squad if m.hull <= 0)
    return won, rounds, tank.hull_max - max(0, tank.hull), a_lost, wrecks, shots, stuns, held


def tether_cell(kind, o, trials, seed):
    rng = random.Random(seed)
    tot = [0.0] * 8
    for _ in range(trials):
        for i, v in enumerate(fight_tether(kind, o, rng)):
            tot[i] += v
    return [v / trials for v in tot]


def fight_ideas(kind, o, rng, cap=40):
    """The ideas past Ryan's four (27 November), one loop for them all. The Drone is an entry on
    the die, set on the biggest hitter when it shows; nothing else sets the hold.

    o: drone (False: the same tank with no Drone), start ("now": the hold takes at once and turns
    its Sprite's pick, as a Lure does; "next": it takes as the next round opens), lure_now (with
    "next": the Drone Lures this round as well), bar (no other Frame may aim at the held Sprite,
    the whole of a round it is held), end ("reboot": the tank's reboot ends it; "never": only its
    Sprite's defeat does), end_at ("now" or "round_end": when a reboot's ending lands), stun (the
    tank's reboot Suppresses the held Sprite), rage (a point more on every hit of the held
    Sprite's for each round it has been held), rage_keep (the points stay once it is let go;
    otherwise they halve each round it is not held), commit_at (the tank sets the Drone only
    once its Sprite stands at this share of its HP or under), plate (armour more against its
    Sprite, before the shield), burn (Hull the tank loses each round it holds), pack (a hold
    needs another Sprite standing: alone on the field the Drone is a plain Lure), toll (Hull the
    tank loses each time another Frame's use hurts the held Sprite), tug (the tug of war: the
    count the hold starts at; the tank's use on its Sprite adds 1, its Sprite's hit that reaches
    the tank's Hull takes 1; at tug_win it is Suppressed and let go, the Drone ready; at 0 it
    breaks free and the Drone is dark until the tank reboots), launch (Hull the tank loses each
    time it sets the Drone), shows."""
    squad = [Frame(tank=(i == 0)) for i in range(3)]
    tank = squad[0]
    foes = pack(kind)
    full = {f: f.hp for f in foes}
    rage = {f: 0 for f in foes}
    partner = queued = None
    leaving = False
    dark = False          # the tug lost: the Drone waits on its tank's reboot
    rope = 0              # the tug of war's count
    rounds = idle = stuns = held = 0
    while rounds < cap:
        if partner is not None and (partner.hp <= 0 or tank.hull <= 0):
            partner = None
        if queued is not None and queued.hp > 0 and tank.hull > 0:
            partner, queued = queued, None
        queued = None
        live = [f for f in foes if f.hp > 0]
        up = [m for m in squad if m.hull > 0]
        if not live or not up:
            break
        rounds += 1
        for m in up:
            if m.rebooting:
                m.rebooting = False
                m.shield = m.shield_max
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
                if f is partner:
                    f.target = tank
                else:
                    open_to = [m for m in up if doomed.get(m, 0) < m.shield + m.hull] or up
                    f.target = rng.choice(open_to)
                doomed[f.target] = doomed.get(f.target, 0) + f.move[1]
        if o.get("pack") and partner is not None and all(f is partner for f in live):
            partner = None   # the pack rule: alone on the field, nothing holds it (its pick stands)
        barred = partner if (o.get("bar") and partner is not None) else None
        nothing_else = barred is not None and all(f is barred for f in live)
        acting = []
        for m in up:
            aimed = any(f.target is m for f in live)
            if m.tank:
                must = m.shield == 0 or m.heat + GUN_HEAT > GAUGE
                if nothing_else and o.get("end") == "reboot":
                    must = True   # the rest round: its reboot ends the hold
            else:
                must = m.heat + GUN_HEAT > GAUGE or (m.shield == 0 and aimed and m.heat >= GUN_HEAT)
                if nothing_else and (m.heat > 0 or m.shield < m.shield_max):
                    must = True   # nothing it may aim at: it rests under the hold
            if must:
                m.rebooting = True
                m.shield = 0
                m.heat = 0
                if m.tank:
                    dark = False
                if m.tank and partner is not None:
                    if o.get("stun") and partner.hp > 0:
                        if partner.numbed > 0:
                            partner.numbed -= 1
                        else:
                            partner.stunned = True
                            stuns += 1
                    if o.get("end") == "reboot":
                        if o.get("end_at") == "round_end":
                            leaving = True
                        else:
                            partner = None
            else:
                acting.append(m)

        def shoot(m, pool):
            kills = [f for f in pool if f.hp <= GUN - f.plate]
            t = min(kills or pool, key=lambda f: f.hp)
            t.hp -= max(0, GUN - t.plate)
            m.heat += GUN_HEAT

        for m in acting:
            if m.tank:
                continue
            pool = [f for f in foes if f.hp > 0 and f is not barred]
            if pool:
                before = partner.hp if partner is not None else 0
                shoot(m, pool)
                if partner is not None and partner.hp < before:
                    tank.hull -= o.get("toll", 0)   # shared wounds: its Sprite hurt, the tank pays
            else:
                idle += 1
        if partner is not None and partner.hp <= 0:
            partner = None
        if tank in acting:
            pool = [f for f in foes if f.hp > 0]
            if pool:
                big = max(pool, key=lambda f: (f.biggest(), f.hp))
                if o.get("drone", True) and partner is None and queued is None and big.biggest() >= 6 \
                        and tank.shield > 0 and big.hp <= o.get("commit_at", 1.0) * full[big] and not dark \
                        and rng.random() < o.get("shows", SHOWS):
                    tank.heat += 1
                    tank.hull -= o.get("launch", 0)   # a price printed on the Drone, paid as it is set
                    rope = o.get("tug", 0)
                    if o.get("pack") and len(pool) == 1:
                        if big.move[0] == "hit":
                            big.target = tank   # alone on the field: a plain Lure, the round's pick
                    elif o.get("start", "now") == "now":
                        partner = big
                        if big.move[0] == "hit":
                            big.target = tank
                    else:
                        queued = big
                        if o.get("lure_now") and big.move[0] == "hit":
                            big.target = tank
                shoot(tank, [partner] if partner is not None and partner.hp > 0 else pool)
                if o.get("tug") and partner is not None and partner.hp > 0:
                    rope += 1
                    if rope >= o.get("tug_win", 4):
                        if partner.numbed > 0:
                            partner.numbed -= 1
                        else:
                            partner.stunned = True
                            stuns += 1
                        partner = None   # hauled in: the hold ends, the Drone ready
        if partner is not None and partner.hp <= 0:
            partner = None
        if partner is not None:
            held += 1
            tank.hull -= o.get("burn", 0)
        for m in [m for m in squad if m.hull > 0]:
            if m.heat > GAUGE:
                m.hull -= m.heat - GAUGE
                m.shield = 0
        for f in foes:
            if f.hp <= 0:
                continue
            if f.stunned:
                f.stunned = False
                f.numbed = f.resist
                continue
            k, n = f.move
            is_held = f is partner and tank.hull > 0
            if k == "hit":
                t = f.target if f.target is not None and f.target.hull > 0 else next((m for m in squad if m.hull > 0), None)
                hits = [t] if t is not None else []
            elif k == "all":
                hits = [m for m in squad if m.hull > 0]
            else:
                hits = []
            for m in hits:
                dmg = n + rage[f]
                plate = m.armour
                if is_held and m is tank and o.get("plate", 0):
                    dmg = max(0, dmg - plate - o["plate"])
                    plate = 0
                took = min(m.shield, dmg)
                m.shield -= took
                through = max(0, dmg - took - plate)
                m.hull -= through
                if o.get("tug") and is_held and m is tank and through > 0:
                    rope -= 1
            if o.get("tug") and f is partner and rope <= 0:
                partner = None   # it breaks free: the Drone dark until its tank reboots
                dark = True
            if f.numbed > 0:
                f.numbed -= 1
        for f in foes:
            if f.hp > 0 and o.get("rage", 0):
                if f is partner:
                    rage[f] += o["rage"]
                elif not o.get("rage_keep"):
                    rage[f] //= 2
        if leaving:
            partner = None
            leaving = False
    won = not [f for f in foes if f.hp > 0]
    a_lost = sum(m.hull_max - max(0, m.hull) for m in squad if m is not tank)
    wrecks = sum(1 for m in squad if m.hull <= 0)
    tank_wrecked = 1 if tank.hull <= 0 else 0
    return won, rounds, tank.hull_max - max(0, tank.hull), a_lost, wrecks, idle, stuns, held, tank_wrecked


def ideas_cell(kind, o, trials, seed):
    rng = random.Random(seed)
    tot = [0.0] * 9
    for _ in range(trials):
        for i, v in enumerate(fight_ideas(kind, o, rng)):
            tot[i] += v
    return [v / trials for v in tot]


IDEAS_ROWS = [
    ("No Drone, the same tank", {"drone": False}),
    ("The free one: held at once, the reboot ending it with a stun", {"start": "now", "end": "reboot", "stun": True}),
    ("A. Between rounds: his bar whole, the hold taking and leaving as a round ends", {"start": "next", "lure_now": True, "bar": True, "end": "reboot", "end_at": "round_end", "stun": True}),
    ("A without the Lure the round it is set", {"start": "next", "bar": True, "end": "reboot", "end_at": "round_end", "stun": True}),
    ("A without the stun", {"start": "next", "lure_now": True, "bar": True, "end": "reboot", "end_at": "round_end"}),
    ("B. No letting go, set at once", {"start": "now", "end": "never"}),
    ("B set at half its HP", {"start": "now", "end": "never", "commit_at": 0.5}),
    ("B set at once, the reboot stunning", {"start": "now", "end": "never", "stun": True}),
    ("C. Angrier: 1 a round held, kept", {"start": "now", "end": "reboot", "stun": True, "rage": 1, "rage_keep": True}),
    ("C. Angrier: 2 a round held, fading", {"start": "now", "end": "reboot", "stun": True, "rage": 2}),
    ("D. 3 Hull as the Drone is set", {"start": "now", "end": "reboot", "stun": True, "launch": 3}),
    ("E. The tug of war, 2 to 4", {"start": "now", "end": "never", "tug": 2, "tug_win": 4}),
    ("E with 2 Armour against its Sprite", {"start": "now", "end": "never", "tug": 2, "tug_win": 4, "plate": 2}),
    ("Set aside: alone on the field, a plain Lure", {"start": "now", "bar": True, "pack": True, "end": "reboot", "stun": True}),
    ("Set aside: 2 Hull when another Frame hurts it", {"start": "now", "end": "reboot", "stun": True, "toll": 2}),
]


TETHER_ROWS = [
    ("No drone, the same tank", {"set": "none"}),
    ("A plain Lure entry: the round's pick", {"set": "drone", "off": False, "break": "none", "persist": False}),
    ("Drone hold, the reboot lets its Sprite pick again", {"set": "drone", "off": False, "break": "repick"}),
    ("Drone hold, the reboot stuns", {"set": "drone", "off": False, "break": "stun"}),
    ("Drone hold, stun, 1 Hull a round held", {"set": "drone", "off": False, "break": "stun", "burn": 1}),
    ("Drone hold, stun, 2 Hull a round held", {"set": "drone", "off": False, "break": "stun", "burn": 2}),
    ("Drone hold, stun, weapons off while held", {"set": "drone", "off": True, "break": "stun"}),
    ("Every hit holds, stun: the free one", {"set": "hit", "off": False, "break": "stun"}),
]


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
    ap.add_argument("--hold", action="store_true", help="Ryan's second pass: every hit holds, a reboot breaks it")
    ap.add_argument("--tether", action="store_true", help="the hold priced: a Drone entry, the reboot's stun, Hull a round held")
    ap.add_argument("--ideas", action="store_true", help="the ideas past his four: between rounds, no letting go, angrier, a price as set, the tug of war")
    a = ap.parse_args()
    for kind, title in PACKS:
        print("\n### %s\n" % title)
        print("| The squad | Won | Rounds | Hull lost, the tank | Hull lost, the others | Wrecks | Turns with nothing to aim at |")
        print("|---|---|---|---|---|---|---|")
        for label, sk, lock, duel, sealed, sync, lure in ROWS:
            if a.hold and lock not in ("none",) and label != "Slip, the lean":
                continue
            c = cell(kind, sk, lock, duel, sealed, sync, a.trials, 11, a.shows, lure)
            print("| %s | %.0f%% | %.1f | %.1f | %.1f | %.2f | %.1f |" % (label, 100 * c[0], c[1], c[2], c[3], c[4], c[5]))
        if a.tether:
            print("\nThe hold priced (26 November): a tank that reboots whenever its shield is down and holds only while it stands.\n")
            print("| The hold | Won | Rounds | Hull lost, the tank | Hull lost, the others | The squad's whole | Wrecks | Stuns | Rounds held |")
            print("|---|---|---|---|---|---|---|---|---|")
            for label, o in TETHER_ROWS:
                c = tether_cell(kind, o, a.trials, 11)
                print("| %s | %.0f%% | %.1f | %.1f | %.1f | %.1f | %.2f | %.1f | %.1f |" % (label, 100 * c[0], c[1], c[2], c[3], c[2] + c[3], c[4], c[6], c[7]))
        if a.ideas:
            print("\nThe ideas past his four (27 November): the Drone an entry, its Sprite's storms on every Frame.\n")
            print("| The idea | Won | Rounds | Hull lost, the tank | Hull lost, the others | The squad's whole | The tank wrecked | Turns with nothing to aim at | Stuns |")
            print("|---|---|---|---|---|---|---|---|---|")
            for label, o in IDEAS_ROWS:
                c = ideas_cell(kind, o, a.trials, 11)
                print("| %s | %.0f%% | %.1f | %.1f | %.1f | %.1f | %.0f%% | %.1f | %.1f |" % (label, 100 * c[0], c[1], c[2], c[3], c[2] + c[3], 100 * c[8], c[5], c[6]))
        if a.hold:
            print("\nThe hold (Ryan's second pass): its stuns and its tank's reboots a fight.\n")
            print("| The hold | Won | Rounds | Hull lost, the tank | Hull lost, the others | Wrecks | Turns with nothing to aim at | Stuns | Reboots, the tank |")
            print("|---|---|---|---|---|---|---|---|---|")
            for label, o in HOLD_ROWS:
                c = hold_cell(kind, o, a.trials, 11)
                print("| %s | %.0f%% | %.1f | %.1f | %.1f | %.2f | %.1f | %.1f | %.1f |" % (label, 100 * c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]))


if __name__ == "__main__":
    main()
