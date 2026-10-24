#!/usr/bin/env python3
"""The turn loop's pressure (24 October, Ryan's question whether a perfect run, every city
standing, is possible in a run of limited battles): a model of `sim/campaign.gd`'s turn end,
its numbers read from the constants there and its cities from the content, with a player who
wins every battle and lets no pusher through, so any city that falls was felled by the
schedule alone. Each rift keeps the tier it opened at (Ryan's locked tier, section 12), so the
model also counts the turns whose board offers two tiers. A model of the arithmetic, not of
the game: check it against `_end_turn` and `_open_rifts` whenever they change.

  python3 tools/turn_loop.py [--seeds 2000] [--widen N]

prints, for each way of choosing the front: the cities fallen per run, the fronts on the
board by the Convergence's tier, the share of turns whose board holds two tiers, the most
gate a front had lost when it was fought, by the Convergence's tier, and the rescues a run (a
front fought one bleed from falling). --widen N tries Ryan's idea of 24 October, a rift that has
bled its city long enough giving way to a nastier one: a rift that has bled its city N times
steps a tier up (once, to the top tier at most), and the report adds the widened rifts fought a
run and the gate their cities had left."""
import argparse, json, os, random, re
from collections import Counter

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def constants():
    src = open(f'{REPO}/sim/campaign.gd', encoding='utf-8').read()
    k = {m[0]: int(m[1]) for m in re.findall(r'^const (\w+) := (-?\d+)\b', src, re.M)}
    makers = json.load(open(f'{REPO}/content/chassis.json', encoding='utf-8'))['makers']
    k['CITIES'] = sum(1 for m in makers if not m.get('capital', False))
    return k


K = constants()


def run(seed, choose, pass_at=None, widen=0):
    rng = random.Random(seed)
    cities = [{'gate': K['CITY_GATE'], 'rift': None, 'quiet': 0, 'fallen': False} for _ in range(K['CITIES'])]
    conv = 0
    tier = lambda: conv // K['TIER_EVERY']
    top = (K['FINALE_AT'] - 1) // K['TIER_EVERY']
    fallen = lambda: sum(c['fallen'] for c in cities)

    def open_rifts():
        n = sum(1 for c in cities if not c['fallen'] and c['rift'] is not None)
        free = [c for c in cities if not c['fallen'] and c['rift'] is None and c['quiet'] == 0]
        while n < K['RIFTS_BASE'] + tier() and free:
            free.pop(rng.randrange(len(free)))['rift'] = {'tier': tier(), 'opened': conv, 'bled': 0, 'widened': False}
            n += 1

    open_rifts()
    turns = []
    while conv < K['FINALE_AT'] - fallen():
        fronts = [c for c in cities if not c['fallen'] and c['rift'] is not None]
        tiers = sorted({c['rift']['tier'] for c in fronts})
        pick = None if conv == pass_at or not fronts else choose(fronts)
        turns.append({'tier': tier(), 'fronts': len(fronts), 'tiers': tiers, 'picked': pick['rift']['tier'] if pick else None,
                      'lost': K['CITY_GATE'] - pick['gate'] if pick else 0,
                      'widened': pick['gate'] if pick and pick['rift']['widened'] else None})
        if pick:
            pick['gate'], pick['rift'], pick['quiet'] = K['CITY_GATE'], None, K['QUIET_TURNS']
        for c in fronts:
            if c is not pick:
                c['gate'] = max(0, c['gate'] - K['BLEED'])
                c['fallen'] = c['gate'] <= 0
                c['rift']['bled'] += 1
                if widen and c['rift']['bled'] >= widen and not c['rift']['widened']:
                    c['rift']['tier'] = min(top, c['rift']['tier'] + 1)
                    c['rift']['widened'] = True
        conv += K['CONVERGENCE_PER_TURN']
        open_rifts()
        for c in cities:
            c['quiet'] = max(0, c['quiet'] - 1)
    return fallen(), turns


def oldest(fronts):
    return min(fronts, key=lambda c: (c['rift']['opened'], c['gate']))


def highest(fronts):
    return max(fronts, key=lambda c: (c['rift']['tier'], -c['gate']))


def careful(fronts):
    danger = [c for c in fronts if c['gate'] <= K['BLEED']]
    return min(danger, key=lambda c: c['gate']) if danger else highest(fronts)


CHOICES = [('the oldest front', oldest), ('the highest tier', highest),
           ('the highest tier, turning back for a city one bleed from falling', careful)]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--seeds', type=int, default=2000)
    ap.add_argument('--widen', type=int, default=0)
    args = ap.parse_args()
    seeds, widen = range(args.seeds), args.widen
    print(f"{K['CITIES']} cities, gate {K['CITY_GATE']}, bleed {K['BLEED']}, rifts {K['RIFTS_BASE']} + tier, "
          f"a tier every {K['TIER_EVERY']}, quiet {K['QUIET_TURNS']}, finale at {K['FINALE_AT']}; every battle won"
          f"{f'; a rift widens a tier at its bleed {widen}' if widen else ''}")
    for name, choose in CHOICES:
        falls, rescues, lost, fronts, widened, left = Counter(), Counter(), Counter(), {}, Counter(), Counter()
        two = up = n = 0
        for s in seeds:
            f, turns = run(s, choose, widen=widen)
            falls[f] += 1
            widened[sum(t['widened'] is not None for t in turns)] += 1
            left.update(t['widened'] for t in turns if t['widened'] is not None)
            rescues[sum(t['lost'] >= K['CITY_GATE'] - K['BLEED'] for t in turns)] += 1
            for t in turns:
                n += 1
                if len(t['tiers']) > 1:
                    two += 1
                    up += t['picked'] == t['tiers'][-1]
                lost[t['tier']] = max(lost[t['tier']], t['lost'])
                fronts.setdefault(t['tier'], set()).add(t['fronts'])
        print(f"{name}: cities fallen per run {dict(sorted(falls.items()))}; fronts on the board, by tier "
              f"{ {t: sorted(v) for t, v in sorted(fronts.items())} }; two tiers on the board {two / n:.0%} of turns"
              f"{f', the higher taken on {up / two:.0%} of them' if two else ''}; most gate lost when fought, by tier "
              f"{dict(sorted(lost.items()))}; rescues a run {dict(sorted(rescues.items()))}"
              f"{f'; widened rifts fought a run {dict(sorted(widened.items()))}, their gate left {dict(sorted(left.items()))}' if widen else ''}")
    worst = Counter()
    for at in range(K['FINALE_AT']):
        for s in seeds:
            worst[run(s, oldest, pass_at=at, widen=widen)[0]] += 1
    print(f"the oldest front, one turn passed (at each Convergence in turn): cities fallen per run {dict(sorted(worst.items()))}")


if __name__ == '__main__':
    main()
