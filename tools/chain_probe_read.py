#!/usr/bin/env python3
"""Reads tools/chain_probe.gd's parts (25 October): for each shield variant, after the k-th
formation in a row, the share of chains still winning, their machines standing and their hull
left (a wreck counted as nothing), with each domain's share winning four, six and eight.

  python3 tools/chain_probe_read.py "<label>" build/chain_0.json build/chain_1.json ..."""
import json, sys

CHAIN = 9


def table(rows, title):
    if not rows:
        return
    print(f'\n{title}: {len(rows)} chains')
    print('| In a row | Still winning | Machines standing | Hull left | Rounds |')
    print('|---|---|---|---|---|')
    for k in range(1, CHAIN + 1):
        alive = [r for r in rows if r['won'] >= k]
        if not alive:
            print(f'| {k} | 0% | | | |')
            continue
        mean = lambda key: sum(r[key][k - 1] for r in alive) / len(alive)
        print(f'| {k} | {100.0 * len(alive) / len(rows):.0f}% | {mean("alive"):.2f} | {mean("hull"):.0f}% | {mean("rounds"):.1f} |')
    for fac in sorted({r['fac'] for r in rows}):
        sel = [r for r in rows if r['fac'] == fac]
        share = lambda n: 100.0 * sum(1 for r in sel if r['won'] >= n) / len(sel)
        print(f'- {fac}: {sum(r["won"] for r in sel) / len(sel):.2f} won in a row; four {share(4):.0f}%, six {share(6):.0f}%, eight {share(8):.0f}%')


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    rows = []
    for path in sys.argv[2:]:
        rows += json.load(open(path))
    for recharge in (False, True):
        table([r for r in rows if r['recharge'] == recharge],
              f'{sys.argv[1]}, {"one field recharge between fights" if recharge else "no shield back"}')


if __name__ == '__main__':
    main()
