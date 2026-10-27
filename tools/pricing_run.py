#!/usr/bin/env python3
"""The pricing run (27 October; the to-do's prices and tier ladders; the bible's rows of 11 and 12
October: a component is balanced against its tier's others in the same hardpoint of the same
machines, every stat and passive has a price, measured): a driver on tools/balance.gd that reads
each slottable component by knock-out and by ladder, each module by ladder, and the guns' heat by
steps, on the records' team rows. Nothing here writes content: every variant is one balance
runner process with its --set and --fit applied in memory, its report and JSON in the run's
folder, never docs/balance.md.

  python3 tools/pricing_run.py plan [options]          the variants and their fights, nothing run
  python3 tools/pricing_run.py run <name> [options]    into build/pricing/<name>/; a variant whose JSON is there is skipped, so a killed run resumes
  python3 tools/pricing_run.py summarise <name>        summary.md from the JSONs there, a partial run included

Options: --parts knockouts,ladders,modules,heat (every part by default); --benches id,id (the
ladders' and the modules' benches, BENCHES below, every one by default); --tiers 0,1,2,3 (the
ladders' candidates); --seeds 30; --policies greedy (random,greedy adds the decision read at
twice the cost); --packs big (the sixteen big fights but the finale, the default: the four
massive foes, the four formations, the eight finals), rank_and_file (the twelve wildlife packs),
all (both), or pack ids as the runner names them; --jobs N (processes at once, the cores by
default); --knock blank|basic (a knock-out leaves the hardpoint empty, or fits the basic of the
piece's kind in its place). GODOT names the binary when it is not on the path.

The reads (the bible's balance rows): a candidate's worth is its row's change against the
bench's stock, read beside its tier's others on the same hardpoint; its pick share says whether
it is spent at all (dead under about 5%, the whole die over about 35%); the heat columns say
what it costs the kit; a knock-out says what a stock piece is worth to its own row. A run at 30
seeds is a direction (a cell near 50% carries a band of about 18 points), so the summary ranks
and flags, and nothing in it is a number to chase.
"""
import argparse
import json
import math
import os
import shutil
import subprocess
import sys
import time
from collections import OrderedDict

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, 'build', 'pricing')
GODOT = os.environ.get('GODOT') or shutil.which('godot') or os.path.expanduser('~/bin/godot')

# The ladders' benches: id -> (the chassis whose hardpoint takes the candidate, the hardpoint's
# index in its stock loadout, the team row it fights in). Each is a role the roster's pieces
# are priced on; a candidate goes into the slot in place of the stock piece there.
BENCHES = OrderedDict([
    ('badger', ('badger', 0, ['badger', 'clydesdale', 'sparrowhawk'])),           # a heavy tank's gun slot (the Rivet Gun), armour 2, in the default team
    ('prairie_dog', ('prairie_dog', 0, ['clydesdale', 'prairie_dog', 'dingo'])),  # a light car's gun slot (the Twin Autoguns), beside a Flak layer and a Shock, in Wainwright & Sutler's team
    ('puffin', ('puffin', 3, ['sparrowhawk', 'goshawk', 'puffin'])),              # a light escort's gun slot (the Laser Carbine) beside two hot kits, in Kestrel's team: equipment reads here
    ('goshawk', ('goshawk', 2, ['sparrowhawk', 'goshawk', 'puffin'])),            # a hot flyer's gun slot (the Arc Fault Cannon): a gun's heat is priced where heat bites
    ('nemesis', ('nemesis', 0, ['nemesis', 'ammit', 'puffin'])),                  # an Arsenal bruiser's slot (the Plasma Arquebus) beside the Ammit: the hull-damage loops read here
])
# The heat ladder's steps: every attack piece's heat mapped a step up the heat row's classes
# (cold 0, cool 1, warm 2, hot 4, very hot 6 and 8), the cold basics alone, and cooling 0.
HEAT_STEP = {0: 1, 1: 2, 2: 3, 3: 4, 4: 6, 6: 8, 8: 10}
POLICY_ORDER = ['random', 'greedy', 'blind', 'planner']


def load(name):
    return json.load(open(os.path.join(REPO, 'content', name + '.json'), encoding='utf-8'))


class Content:
    def __init__(self):
        chassis = load('chassis')
        makers = chassis['makers']   # a list of {id, name, ...} in file order
        self.makers = OrderedDict((m['id'], m) for m in makers) if isinstance(makers, list) else OrderedDict(makers)
        self.chassis = OrderedDict((c['id'], c) for c in chassis['entries'])
        self.components = OrderedDict((e['id'], e) for e in load('components')['entries'])
        self.modules = OrderedDict((m['id'], m) for m in load('modules')['entries'])
        self.factions = load('factions')['entries']
        self.foes = OrderedDict((f['id'], f) for f in load('foes')['entries'])

    def runnable(self, cid):
        c = self.chassis[cid]
        p = c.get('passive') or {}
        if p.get('status') == 'planned':
            return False
        return all(self.components[f].get('status') != 'planned' for f in c.get('fixed', []))

    def team_rows(self):
        """The records' team rows as tools/balance.gd builds them: the default team (the first
        three chassis in the file) and each maker's first three runnable chassis, by file order;
        run here as --team rows, so the runner skips its targeting comparison."""
        rows = OrderedDict()
        rows['the default team'] = list(self.chassis.keys())[:3]
        for mk, m in self.makers.items():
            own = [cid for cid, c in self.chassis.items() if c.get('maker') == mk and self.runnable(cid)]
            if len(own) >= 3:
                rows["%s team" % m.get('name', mk)] = own[:3]   # the runner's own name for the row
        return rows

    def packs(self, which):
        """Pack ids as the runner names them: a massive boss 'id x1', a domain 'id formation', a hero 'id final'."""
        big, trash = [], []
        for f in self.factions:
            b = f.get('boss')
            for boss in (b if isinstance(b, list) else [b]):
                if boss in self.foes:
                    big.append('%s x1' % boss)
        for f in self.factions:
            spawn = f.get('spawn', [])
            if len(spawn) >= 2:
                big.append('%s formation' % f['id'])
            for e in spawn:
                pid = '%s x%d' % (e['foe'], e['strength'])
                if e['foe'] in self.foes and pid not in trash:
                    trash.append(pid)
        for f in self.factions:
            for h in f.get('bench', []):
                if h in self.foes:
                    big.append('%s final' % h)
        if which == 'big':
            return big
        if which == 'rank_and_file':
            return trash
        if which == 'all':
            return big + trash
        return [p.strip() for p in which.split(',') if p.strip()]

    def slottable(self, tiers):
        return [e for e in self.components.values() if 'tier' in e and e.get('status') != 'planned' and int(e['tier']) in tiers]

    def basic_for(self, e):
        """The tier-zero piece of a candidate's kind and reach, the floor a ladder is read against: the first in the file."""
        f = e['face']
        for b in self.components.values():
            if b.get('tier') != 0 or b.get('status') == 'planned':
                continue
            bf = b['face']
            if bf.get('kind') != f.get('kind'):
                continue
            if f.get('kind') == 'attack' and bf.get('reach') != f.get('reach'):
                continue
            if f.get('kind') in ('shield', 'vent') and bf.get('targets', 'self_ally') != f.get('targets', 'self_ally'):
                continue
            return b['id']
        return None

    def name(self, cid):
        for d in (self.components, self.chassis, self.modules):
            if cid in d:
                return d[cid]['name']
        return cid


def row_id(ids):
    return 'team:' + '+'.join(ids)


def set_loadout(cid, loadout):
    return ['--set', 'chassis/%s/loadout=%s' % (cid, json.dumps(loadout, separators=(',', ':')))]


# ------------------------------------------------------------------ the variants

def variants(db, opts):
    """Every variant: {id, part, row (the team row's chassis), args (the runner's), and what it reads}."""
    out = []
    rows = db.team_rows()
    for name, ids in rows.items():
        out.append({'id': 'stock:' + '+'.join(ids), 'part': 'stock', 'row': ids, 'args': [], 'row_name': name})
    # A bench whose row is none of the records' team rows (the Arsenal's) gets a stock baseline of its own.
    for b in [b for b in BENCHES if b in opts.benches]:
        ids = BENCHES[b][2]
        if ids not in rows.values() and not any(v['row'] == ids for v in out):
            out.append({'id': 'stock:' + '+'.join(ids), 'part': 'stock', 'row': ids, 'args': [], 'row_name': "the %s bench's row" % b})
    if 'knockouts' in opts.parts:
        for name, ids in rows.items():
            for cid in ids:
                load = list(db.chassis[cid].get('loadout', []))
                seen = set()
                for i, piece in enumerate(load):
                    if piece in seen:
                        continue   # a stock that carries a piece twice knocks out the first; the second would read the same
                    seen.add(piece)
                    without = load[:i] + load[i + 1:]
                    if opts.knock == 'basic':
                        b = db.basic_for(db.components[piece])
                        if b and b != piece:
                            without = load[:i] + [b] + load[i + 1:]
                        elif b == piece:
                            continue   # a basic knocked out for itself reads nothing
                    out.append({'id': 'knock:%s:%s:%d' % ('+'.join(ids), cid, i), 'part': 'knockouts', 'row': ids, 'row_name': name,
                                'chassis': cid, 'piece': piece, 'slot': i, 'args': set_loadout(cid, without)})
    benches = [b for b in BENCHES if b in opts.benches]
    if 'ladders' in opts.parts:
        for b in benches:
            cid, slot, ids = BENCHES[b]
            load = list(db.chassis[cid].get('loadout', []))
            for e in db.slottable(opts.tiers):
                fitted = load[:slot] + [e['id']] + load[slot + 1:]
                out.append({'id': 'ladder:%s:%s' % (b, e['id']), 'part': 'ladders', 'row': ids, 'bench': b, 'chassis': cid,
                            'piece': e['id'], 'slot': slot, 'tier': int(e['tier']), 'args': set_loadout(cid, fitted)})
    if 'modules' in opts.parts:
        for b in benches:
            cid, slot, ids = BENCHES[b]
            for m in db.modules.values():
                if (m.get('text') or {}).get('status') == 'planned':
                    continue
                out.append({'id': 'module:%s:%s' % (b, m['id']), 'part': 'modules', 'row': ids, 'bench': b, 'chassis': cid,
                            'module': m['id'], 'tier': int(m['tier']), 'args': ['--fit', '%s=%s' % (cid, m['id'])]})
    if 'heat' in opts.parts:
        attacks = [e for e in db.components.values() if e.get('face', {}).get('kind') == 'attack' and e.get('status') != 'planned']
        steps = {
            'step': [('components/%s/face/heat' % e['id'], HEAT_STEP[int(e['face'].get('heat', 0))]) for e in attacks
                     if int(e['face'].get('heat', 0)) in HEAT_STEP],
            'cold1': [('components/%s/face/heat' % e['id'], 1) for e in attacks if int(e['face'].get('heat', 0)) == 0],
            'cooling0': [('chassis/%s/cooling' % cid, 0) for cid in db.chassis],
        }
        for name, ids in rows.items():
            for step, edits in steps.items():
                args = []
                for path, value in edits:
                    args += ['--set', '%s=%s' % (path, json.dumps(value))]
                out.append({'id': 'heat:%s:%s' % (step, '+'.join(ids)), 'part': 'heat', 'row': ids, 'row_name': name, 'step': step, 'args': args})
    return out


def runner_args(v, opts, packs):
    return ['--seeds', str(opts.seeds), '--policies', ','.join(opts.policies), '--rows', row_id(v['row']),
            '--team', ','.join(v['row']), '--packs', ','.join(packs)] + v['args']


# ------------------------------------------------------------------ the run

def check(db, opts):
    errs = []
    for b in opts.benches:
        if b not in BENCHES:
            errs.append('no bench %s (benches: %s)' % (b, ', '.join(BENCHES)))
            continue
        cid, slot, ids = BENCHES[b]
        if cid not in db.chassis:
            errs.append('%s: no chassis %s' % (b, cid))
        elif slot >= len(db.chassis[cid].get('loadout', [])):
            errs.append('%s: %s has no stock piece at hardpoint %d' % (b, cid, slot))
        if cid not in ids:
            errs.append('%s: %s is not in its row' % (b, cid))
        errs += ['%s: no chassis %s' % (b, x) for x in ids if x not in db.chassis]
        errs += ['%s: %s is not runnable yet' % (b, x) for x in ids if x in db.chassis and not db.runnable(x)]
    return errs


def fights_of(v, opts, packs):
    return len(packs) * len(opts.policies) * opts.seeds


def plan(db, opts):
    packs = db.packs(opts.packs)
    vs = variants(db, opts)
    by_part = OrderedDict()
    for v in vs:
        n, f = by_part.get(v['part'], (0, 0))
        by_part[v['part']] = (n + 1, f + fights_of(v, opts, packs))
    print('Packs (%d): %s' % (len(packs), ', '.join(packs)))
    print('Policies: %s; seeds a cell: %d; jobs: %d' % (', '.join(opts.policies), opts.seeds, opts.jobs))
    print('Benches: %s' % ', '.join('%s (%s, hardpoint %d, with %s)' % (b, db.name(BENCHES[b][0]), BENCHES[b][1], ' + '.join(db.name(x) for x in BENCHES[b][2]))
                                    for b in BENCHES if b in opts.benches))
    print()
    print('| Part | Variants | Fights |')
    print('|---|---|---|')
    total = 0
    for part, (n, f) in by_part.items():
        total += f
        print('| %s | %d | %s |' % (part, n, format(f, ',')))
    print('| all | %d | %s |' % (len(vs), format(total, ',')))
    rate = 5.0 * opts.jobs
    print()
    print('About %s fights; at a guess of five team fights a second a job, about %.1f hours on %d jobs. The first variants\' logs say the true rate.'
          % (format(total, ','), total / rate / 3600.0, opts.jobs))
    if opts.verbose:
        for v in vs:
            print('  ' + v['id'] + ': ' + ' '.join(runner_args(v, opts, packs)))


def run(db, opts):
    errs = check(db, opts)
    if errs:
        raise SystemExit('\n'.join(errs))
    if not os.path.exists(GODOT):
        raise SystemExit('no Godot at %s (GODOT names the binary)' % GODOT)
    packs = db.packs(opts.packs)
    root = os.path.join(OUT, opts.name)
    os.makedirs(root, exist_ok=True)
    vs = variants(db, opts)
    json.dump({'seeds': opts.seeds, 'policies': opts.policies, 'packs': packs, 'benches': {b: BENCHES[b] for b in BENCHES if b in opts.benches},
               'variants': [{k: v[k] for k in v if k != 'args'} | {'args': v['args']} for v in vs], 'knock': opts.knock},
              open(os.path.join(root, 'plan.json'), 'w', encoding='utf-8'), indent=1)
    todo = []
    for v in vs:
        jpath = os.path.join(root, v['id'].replace(':', '~').replace('+', '_') + '.json')
        v['json'] = jpath
        if os.path.exists(jpath):
            try:
                if json.load(open(jpath, encoding='utf-8')).get('cells'):
                    continue
            except Exception:
                pass
        todo.append(v)
    print('%d variants, %d to run, %d done before (%s)' % (len(vs), len(todo), len(vs) - len(todo), root))
    running = []
    t0 = time.time()
    done = 0
    while todo or running:
        while todo and len(running) < opts.jobs:
            v = todo.pop(0)
            fights = fights_of(v, opts, packs)
            log = open(v['json'][:-5] + '.log', 'w')
            cmd = [GODOT, '--headless', '--path', REPO, '-s', 'tools/balance.gd', '--'] + runner_args(v, opts, packs) + [
                '--out', v['json'][:-5] + '.md', '--json', v['json']]
            p = subprocess.Popen(cmd, stdout=log, stderr=subprocess.STDOUT, cwd=REPO)
            running.append((v, p, time.time(), 1800 + fights * 2.0, log))
        time.sleep(2)
        still = []
        for v, p, started, limit, log in running:
            if p.poll() is None:
                if time.time() - started > limit:
                    p.kill()
                    print('%s hung past %d s and was killed' % (v['id'], limit), file=sys.stderr)
                else:
                    still.append((v, p, started, limit, log))
                    continue
            log.close()
            done += 1
            ok = os.path.exists(v['json'])
            print('[%d/%d] %s %s in %.0f s' % (done, len(vs), v['id'], 'done' if ok else 'FAILED (see its .log)', time.time() - started), flush=True)
        running = still
    print('run in %.0f s; now: python3 tools/pricing_run.py summarise %s' % (time.time() - t0, opts.name))
    summarise(db, opts)


# ------------------------------------------------------------------ the summary

def cell_read(data, rid, packs, policy):
    """A row's means over the packs under one policy: win%, rounds won, hull lost, the heat columns, the spends."""
    cells = data['cells']
    t = {'fights': 0, 'victory': 0, 'rounds_won': 0, 'hull': 0.0, 'heat_peak': 0.0, 'overheats': 0, 'forced': 0, 'forgone': 0.0,
         'end_heat': 0.0, 'rounds': 0, 'hot_rounds': 0, 'overheat_hull': 0}
    spends = {}
    won_cells = []
    for pid in packs:
        a = cells.get('%s|%s|%s' % (rid, pid, policy))
        if a is None:
            continue
        t['fights'] += a['fights']; t['victory'] += a['victory']; t['rounds_won'] += a['rounds_won']
        t['hull'] += a['hull_lost_pct']; t['heat_peak'] += a.get('heat_peak', 0); t['overheats'] += a.get('overheats', 0)
        t['forced'] += a.get('forced', 0); t['forgone'] += a.get('forgone', 0); t['end_heat'] += a.get('end_heat', 0)
        t['rounds'] += a['rounds']; t['hot_rounds'] += a.get('hot_rounds', 0); t['overheat_hull'] += a.get('overheat_hull', 0)
        if a['victory']:
            won_cells.append(a['rounds_won'] / a['victory'])
        for c, n in a.get('spends', {}).items():
            spends[c] = spends.get(c, 0) + n
    n = max(1, t['fights'])
    total_spends = max(1, sum(spends.values()))
    return {'win': 100.0 * t['victory'] / n, 'rounds': (sum(won_cells) / len(won_cells)) if won_cells else float('nan'),
            'hull': t['hull'] / n, 'peak': t['heat_peak'] / n, 'overheats': t['overheats'] / n, 'held': t['forced'] / n,
            'forgone': t['forgone'] / n, 'end_heat': t['end_heat'] / n, 'hot_rounds': t['hot_rounds'] / n, 'burned': t['overheat_hull'] / n,
            'share': {c: 100.0 * v / total_spends for c, v in spends.items()}, 'fights': t['fights']}


def read_variant(v, packs, policy):
    try:
        data = json.load(open(v['json'], encoding='utf-8'))
    except Exception:
        return None
    if not data.get('cells'):
        return None
    return cell_read(data, row_id(v['row']), packs, policy)


def fmt(x, d=1):
    return '-' if x is None or (isinstance(x, float) and math.isnan(x)) else ('%.*f' % (d, x))


def summarise(db, opts):
    root = os.path.join(OUT, opts.name)
    plan_path = os.path.join(root, 'plan.json')
    if not os.path.exists(plan_path):
        raise SystemExit('no run named %s under %s' % (opts.name, OUT))
    p = json.load(open(plan_path, encoding='utf-8'))
    packs = p['packs']
    pols = sorted(p['policies'], key=lambda x: POLICY_ORDER.index(x) if x in POLICY_ORDER else 9)
    top = pols[-1]
    vs = p['variants']
    for v in vs:
        v['json'] = os.path.join(root, v['id'].replace(':', '~').replace('+', '_') + '.json')
    reads = {v['id']: read_variant(v, packs, top) for v in vs}
    reads_low = {v['id']: read_variant(v, packs, pols[0]) for v in vs} if len(pols) > 1 else {}
    stock = {'+'.join(v['row']): reads[v['id']] for v in vs if v['part'] == 'stock'}
    done = sum(1 for r in reads.values() if r)
    L = ['# The pricing run: %s' % opts.name, '',
         'Generated by `tools/pricing_run.py` from `build/pricing/%s/`: %d of %d variants read, %d seeds a cell, policies %s, over %d packs (%s). '
         'A direction, never a band: a cell near 50%% carries about 18 points at 30 seeds, so read the ranks and the flags, not the decimals. '
         'Every read is under %s play; win is the row\'s mean win rate over the packs, rounds the mean rounds of the fights won, hull the mean share of the row\'s hull lost, '
         'share the candidate\'s share of the row\'s spends, peak the hottest machine as a turn ended (percent of its maximum), over (overheats) and held (damaging dice held for heat) per fight.'
         % (opts.name, done, len(vs), p['seeds'], ', '.join(pols), len(packs), ', '.join(packs), top), '']
    L.append('## The team rows as stocked')
    L.append('')
    L.append('| Row | Win | Rounds | Hull | Peak | Over | Held | Spends |')
    L.append('|---|---|---|---|---|---|---|---|')
    for v in vs:
        if v['part'] != 'stock':
            continue
        r = reads[v['id']]
        if not r:
            L.append('| %s | not run |  |  |  |  |  |  |' % v['row_name'])
            continue
        top5 = sorted(r['share'].items(), key=lambda x: -x[1])[:6]
        L.append('| %s | %s | %s | %s%% | %s%% | %s | %s | %s |' % (v['row_name'], fmt(r['win']), fmt(r['rounds']), fmt(r['hull'], 0), fmt(r['peak'], 0),
                 fmt(r['overheats'], 2), fmt(r['held'], 2), ', '.join('%s %.0f%%' % (db.name(c), s) for c, s in top5)))
    L.append('')
    # the knock-outs
    ko = [v for v in vs if v['part'] == 'knockouts']
    if ko:
        L.append('## Knock-outs: each stock piece out of its row (%s)' % ('the hardpoint left empty' if p.get('knock') == 'blank' else 'the basic of its kind in its place'))
        L.append('')
        L.append('What the row loses without the piece: a drop is the piece\'s worth to its row, nothing says the stock carries filler there (the stock\'s question, not the piece\'s price).')
        L.append('')
        L.append('| Row | Machine | Piece | Tier | Stock share | Win stock > without | Rounds | Hull | Peak |')
        L.append('|---|---|---|---|---|---|---|---|---|')
        rows_ko = []
        for v in ko:
            r = reads[v['id']]
            s = stock.get('+'.join(v['row']))
            if not r or not s:
                continue
            rows_ko.append((s['win'] - r['win'], v, r, s))
        rows_ko.sort(key=lambda x: -x[0])
        for d, v, r, s in rows_ko:
            L.append('| %s | %s | %s | %s | %s%% | %s > %s (%+.1f) | %s > %s | %s > %s%% | %s > %s%% |' % (
                v['row_name'], db.name(v['chassis']), db.name(v['piece']), db.components[v['piece']].get('tier', '-'), fmt(s['share'].get(v['piece'], 0), 0),
                fmt(s['win']), fmt(r['win']), -d, fmt(s['rounds']), fmt(r['rounds']), fmt(s['hull'], 0), fmt(r['hull'], 0), fmt(s['peak'], 0), fmt(r['peak'], 0)))
        L.append('')
    # the ladders
    for b in p['benches']:
        cid, slot, ids = p['benches'][b]
        lad = [v for v in vs if v['part'] == 'ladders' and v.get('bench') == b]
        if not lad:
            continue
        s = stock.get('+'.join(ids))
        stock_piece = db.chassis[cid].get('loadout', [])[slot]
        L.append('## Ladder: %s, hardpoint %d (the %s in stock), with %s' % (db.name(cid), slot, db.name(stock_piece), ' and '.join(db.name(x) for x in ids if x != cid)))
        L.append('')
        L.append('Each candidate in that hardpoint in place of the stock piece, by tier, best change first; the stock row is the floor every delta is read against. '
                 'Flags: dead (share under 5%%), the die (share over 35%%), hot (an overheat a fight more than stock), under tier %s (below the best of the tier beneath).' % 'N-1')
        L.append('')
        L.append('| Tier | Candidate | Kind | Win (delta) | Rounds | Hull | Share | Peak | Over | Held | Flags |')
        L.append('|---|---|---|---|---|---|---|---|---|---|---|')
        best_by_tier = {}
        got = []
        for v in lad:
            r = reads[v['id']]
            if not r:
                continue
            got.append((v, r))
            t = v['tier']
            best_by_tier[t] = max(best_by_tier.get(t, -999), r['win'])
        got.sort(key=lambda x: (x[0]['tier'], -x[1]['win']))
        for v, r in got:
            e = db.components[v['piece']]
            f = e['face']
            kind = f.get('kind', 'attack')
            if kind == 'attack':
                kind = '%s %s%s, heat %s' % (f.get('reach', ''), f.get('power', 0), ('-%s' % f['power_max']) if f.get('power_max', f.get('power')) != f.get('power') else '',
                                             f.get('heat', 0)) + (', ' + ' '.join(f.get('keywords', [])) if f.get('keywords') else '')
            else:
                kind = '%s %s' % (kind, f.get('power', '')) + (', ' + ' '.join(f.get('keywords', [])) if f.get('keywords') else '')
            flags = []
            share = r['share'].get(v['piece'], 0.0)
            if share < 5:
                flags.append('dead')
            if share > 35:
                flags.append('the die')
            if s and r['overheats'] >= s['overheats'] + 1:
                flags.append('hot')
            t = v['tier']
            if t >= 1 and (t - 1) in best_by_tier and r['win'] < best_by_tier[t - 1]:
                flags.append('under tier %d' % (t - 1))
            delta = (r['win'] - s['win']) if s else float('nan')
            L.append('| %d | %s | %s | %s (%s) | %s | %s%% | %s%% | %s%% | %s | %s | %s |' % (
                t, e['name'] + (' (stock)' if v['piece'] == stock_piece else ''), kind, fmt(r['win']), ('%+.1f' % delta) if not math.isnan(delta) else '-',
                fmt(r['rounds']), fmt(r['hull'], 0), fmt(share, 0), fmt(r['peak'], 0), fmt(r['overheats'], 2), fmt(r['held'], 2), ', '.join(flags)))
        L.append('')
    # the modules
    for b in p['benches']:
        cid, slot, ids = p['benches'][b]
        mod = [v for v in vs if v['part'] == 'modules' and v.get('bench') == b]
        if not mod:
            continue
        s = stock.get('+'.join(ids))
        L.append('## Modules on the %s (with %s)' % (db.name(cid), ' and '.join(db.name(x) for x in ids if x != cid)))
        L.append('')
        L.append('Each module fitted to the machine alone, its other slot empty; the delta against the row as stocked. The mirrors (the Ram Frame and the Rangefinder, the Booster and the Databank) read against each other here, and a module ahead of every other on every bench is the must-pick the modules row forbids.')
        L.append('')
        L.append('| Tier | Module | Stats and text | Win (delta) | Rounds | Hull | Peak | Over |')
        L.append('|---|---|---|---|---|---|---|---|')
        got = []
        for v in mod:
            r = reads[v['id']]
            if r:
                got.append((v, r))
        got.sort(key=lambda x: (x[0]['tier'], -x[1]['win']))
        for v, r in got:
            m = db.modules[v['module']]
            text = ', '.join('%s %+d' % (k, val) for k, val in (m.get('stats') or {}).items())
            if m.get('text'):
                text += ('; ' if text else '') + m['text'].get('description', '')
            delta = (r['win'] - s['win']) if s else float('nan')
            L.append('| %d | %s | %s | %s (%s) | %s | %s%% | %s%% | %s |' % (v['tier'], m['name'], text, fmt(r['win']), ('%+.1f' % delta) if not math.isnan(delta) else '-',
                                                                         fmt(r['rounds']), fmt(r['hull'], 0), fmt(r['peak'], 0), fmt(r['overheats'], 2)))
        L.append('')
    # the heat ladder
    heat = [v for v in vs if v['part'] == 'heat']
    if heat:
        L.append('## The heat ladder')
        L.append('')
        L.append('Every team row with every attack piece a step hotter (step: 0 to 1, 1 to 2, 2 to 3, 3 to 4, 4 to 6, 6 to 8, 8 to 10), with the cold basics alone at 1 (cold1), and with cooling 0 on every chassis (cooling0), against the row as stocked. '
                 'The heat row\'s test: a hot kit overheats by about its third round of firing without a vent; a cold kit stays cold and pays in its numbers; the worst case is slack, a kit that ends the fights that matter with budget unused.')
        L.append('')
        L.append('| Row | Variant | Win | Rounds | Hull | Peak | Hot rounds | Over | Hull burned | Held | Damage held | Heat left |')
        L.append('|---|---|---|---|---|---|---|---|---|---|---|---|')
        for v in [x for x in vs if x['part'] == 'stock'] + heat:
            r = reads[v['id']]
            if not r:
                continue
            L.append('| %s | %s | %s | %s | %s%% | %s%% | %s | %s | %s | %s | %s | %s%% |' % (
                v['row_name'], v.get('step', 'stock'), fmt(r['win']), fmt(r['rounds']), fmt(r['hull'], 0), fmt(r['peak'], 0), fmt(r['hot_rounds'], 1),
                fmt(r['overheats'], 2), fmt(r['burned'], 1), fmt(r['held'], 2), fmt(r['forgone'], 1), fmt(r['end_heat'], 0)))
        L.append('')
    if reads_low:
        L.append('## The decision read, %s against %s' % (pols[0], top))
        L.append('')
        L.append('The low rung\'s win rate beside the top\'s on every variant read: a variant both rungs win together holds no decision, one the low rung loses and the top wins is where play matters.')
        L.append('')
        L.append('| Variant | %s | %s |' % (pols[0], top))
        L.append('|---|---|---|')
        for v in vs:
            a, b2 = reads_low.get(v['id']), reads.get(v['id'])
            if a and b2:
                L.append('| %s | %s | %s |' % (v['id'], fmt(a['win']), fmt(b2['win'])))
        L.append('')
    out = os.path.join(root, 'summary.md')
    open(out, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
    print('wrote %s' % out)


# ------------------------------------------------------------------ main

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('command', choices=['plan', 'run', 'summarise'])
    ap.add_argument('name', nargs='?')
    ap.add_argument('--parts', default='knockouts,ladders,modules,heat')
    ap.add_argument('--benches', default=','.join(BENCHES))
    ap.add_argument('--tiers', default='0,1,2,3')
    ap.add_argument('--seeds', type=int, default=30)
    ap.add_argument('--policies', default='greedy')
    ap.add_argument('--packs', default='big')
    ap.add_argument('--jobs', type=int, default=os.cpu_count() or 4)
    ap.add_argument('--knock', choices=['blank', 'basic'], default='blank')
    ap.add_argument('--verbose', action='store_true', help='plan: print each variant\'s runner arguments')
    opts = ap.parse_args()
    opts.parts = [x.strip() for x in opts.parts.split(',') if x.strip()]
    opts.benches = [x.strip() for x in opts.benches.split(',') if x.strip()]
    opts.tiers = [int(x) for x in opts.tiers.split(',') if x.strip()]
    opts.policies = [x.strip() for x in opts.policies.split(',') if x.strip()]
    db = Content()
    if opts.command == 'plan':
        errs = check(db, opts)
        if errs:
            raise SystemExit('\n'.join(errs))
        plan(db, opts)
    elif opts.command == 'run':
        if not opts.name:
            raise SystemExit('run needs a name')
        run(db, opts)
    else:
        if not opts.name:
            raise SystemExit('summarise needs a name')
        summarise(db, opts)


if __name__ == '__main__':
    main()
