#!/usr/bin/env python3
"""A balance loop (the stock pass's method, its retired brief's section 7, 22 October: git show a550c2e:docs/briefs/stock_pass.md): a
copy of the project with one lever moved in its content, the balance runner read against the
design tests, the levers kept landing through tools/stock_fills.py.

  python3 tools/stock_loop.py run <name> [--lever name[:arg]]... [--seeds 30] [--alone] [--no-campaign]
      [--team a,b,c,d]... [--set path=json]... [--fit chassis=module,module]...
  python3 tools/stock_loop.py compare <name> [<name>...]
  python3 tools/stock_loop.py levers

`run` copies the project (project.godot, .godot, content, sim, game, the two runners) to
build/loops/<name>, applies the levers to the copy's content in order, then runs the balance
runner on the four team rows (random, greedy, blind and the planner by default) in four
processes, every chassis alone (greedy, no party) with --alone, and the campaign report at 40
runs unless --no-campaign; it writes summary.md against the tests of the bible's section 2
(rounds to win by kind of fight, hull lost, the coordination gap, heat, pick share). About half
an hour on four cores at 30 seeds for the team rows with every rung; --policies random,greedy
and --packs big (or rank_and_file, or pack ids) cut it down. --team adds a row of exactly those
machines (a squad of four, say); --set hands the runner an override it applies after the
content loads, unvalidated, for a fit no stock may carry (a tier-one piece on a tier-one
chassis: `chassis/badger/loadout/0="polarity_projector"`), where a lever edits the copy's
content and the validator still reads it; --fit hands it the modules every machine of a chassis
wears (the endgame fours of 23 October, fitted up to tier two). `compare` lays finished loops side by side. Run it
from the repository; it never touches the repository's own files, and a kept lever lands by
editing tools/stock_fills.py and running it (the copy is a direction at 30 seeds, the bands at
200 are the report's). GODOT names the Godot binary when it is not on the path."""
import argparse, json, math, os, re, shutil, subprocess, sys, time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, 'build', 'loops')
GODOT = os.environ.get('GODOT') or shutil.which('godot') or os.path.expanduser('~/bin/godot')
# The default team as a --team row, so the runner skips the targeting comparison it runs on "team".
TEAMS = ['team:badger+clydesdale+kite', 'minerva team', 'kestrel team', 'wainwright_sutler team']
TEAM_EXTRA = ['--team', 'badger,clydesdale,kite']
POLICIES = ['random', 'greedy', 'blind', 'planner']
GAP_MIN_WIN = 25   # the runner's: the gap reads a cell only where both rungs win this share
GROUPS = ('trash', 'massive', 'formation', 'final', 'finale')


# ------------------------------------------------------------------ the copy

def make_copy(root):
    if os.path.exists(root):
        shutil.rmtree(root)
    os.makedirs(root + '/tools')
    os.makedirs(root + '/docs')
    shutil.copy2(REPO + '/project.godot', root)
    for d in ['.godot', 'content', 'sim', 'game']:
        shutil.copytree(REPO + '/' + d, root + '/' + d, symlinks=True)
    for t in ['balance.gd', 'campaign_run.gd', 'stock_fills.py']:
        shutil.copy2(REPO + '/tools/' + t, root + '/tools/')


def jl(root, name):
    return json.load(open(f'{root}/content/{name}.json', encoding='utf-8'))


def js(root, name, d):
    open(f'{root}/content/{name}.json', 'w', encoding='utf-8').write(json.dumps(d, indent=1, ensure_ascii=False) + '\n')


def rnd(x):
    return int(math.floor(x + 0.5))


# ------------------------------------------------------------------ the levers
# Each takes the copy's root and its argument (a string, maybe empty) and returns a line
# saying what it moved. They edit the copy only.

def lever_blows(root, arg):
    """The foes' blows times k (every foe that names an attack; promoted forms read their hero's): blows:1.5"""
    k = float(arg or 1.5)
    d = jl(root, 'foes')
    moved = []
    for f in d['entries']:
        if 'attack' in f:
            old = f['attack']
            f['attack'] = max(1, rnd(old * k))
            moved.append(f"{f['id']} {old}>{f['attack']}")
    js(root, 'foes', d)
    return 'foes\' blows x%s: %s' % (arg or '1.5', ', '.join(moved))


def lever_blows_by(root, arg):
    """The foes' blows by group, rank and file, massive and heroes: blows_by:rf=1.5,massive=1.33,hero=2"""
    ks = dict(kv.split('=') for kv in arg.split(','))
    d = jl(root, 'foes')
    moved = []
    for f in d['entries']:
        if 'attack' not in f:
            continue
        grp = 'hero' if f.get('hero') else ('massive' if int(f.get('size', 1)) >= 2 else 'rf')
        k = float(ks.get(grp, 1))
        old = f['attack']
        f['attack'] = max(1, rnd(old * k))
        moved.append(f"{f['id']} {old}>{f['attack']}")
    js(root, 'foes', d)
    return 'foes\' blows by group %s: %s' % (arg, ', '.join(moved))


def lever_durability(root, arg):
    """Our hull and shield times k: durability:0.75 (the field recharge went with the long wall brief)"""
    k = float(arg or 0.75)
    d = jl(root, 'chassis')
    for c in d['entries']:
        c['hull'] = max(1, rnd(c['hull'] * k))
        c['shield'] = max(0, rnd(c['shield'] * k))
    js(root, 'chassis', d)
    return 'our hull and shield x%s' % (arg or '0.75')


def lever_cooling(root, arg):
    """Every chassis's cooling set to n, or lowered by one: cooling:0, cooling:minus1"""
    d = jl(root, 'chassis')
    for c in d['entries']:
        if arg == 'minus1':
            c['cooling'] = max(0, int(c.get('cooling', 0)) - 1)
        else:
            c['cooling'] = int(arg or 0)
    js(root, 'chassis', d)
    return 'cooling %s on every chassis' % (arg or '0')


def lever_heatmax(root, arg):
    """Heat maxima mapped: heatmax:16>12,20>14"""
    m = {int(a): int(b) for a, b in (p.split('>') for p in arg.split(','))}
    d = jl(root, 'chassis')
    for c in d['entries']:
        c['heat_max'] = m.get(int(c['heat_max']), c['heat_max'])
    js(root, 'chassis', d)
    return 'heat maxima %s' % arg


def lever_gunheat(root, arg):
    """Every attack component's heat mapped: gunheat:1>2,2>3"""
    m = {int(a): int(b) for a, b in (p.split('>') for p in arg.split(','))}
    d = jl(root, 'components')
    moved = []
    for e in d['entries']:
        f = e.get('face', {})
        if f.get('kind', 'attack') == 'attack' and 'heat' in f and int(f['heat']) in m:
            moved.append(f"{e['id']} {f['heat']}>{m[int(f['heat'])]}")
            f['heat'] = m[int(f['heat'])]
    js(root, 'components', d)
    return 'weapon heat %s: %s' % (arg, ', '.join(moved))


def lever_armour(root, arg):
    """Foes' armour set by id: armour:sandworm=1,magma_elemental=1"""
    m = {a: int(b) for a, b in (p.split('=') for p in arg.split(','))}
    d = jl(root, 'foes')
    for f in d['entries']:
        if f['id'] in m:
            f['armour'] = m[f['id']]
    js(root, 'foes', d)
    return 'foes\' armour %s' % arg


def lever_hp(root, arg):
    """Foes' HP set by id: hp:treant=24"""
    m = {a: int(b) for a, b in (p.split('=') for p in arg.split(','))}
    d = jl(root, 'foes')
    for f in d['entries']:
        if f['id'] in m:
            f['hp'] = m[f['id']]
    js(root, 'foes', d)
    return 'foes\' HP %s' % arg


def lever_move(root, arg):
    """A foe move's value set: move:treant.regen=3,bone_wyvern.regen=3"""
    m = {a: int(b) for a, b in (p.split('=') for p in arg.split(','))}
    d = jl(root, 'foes')
    hit = set()
    for f in d['entries']:
        for a in f.get('actions', []):
            key = f"{f['id']}.{a['id']}"
            if key in m:
                a['value'] = m[key]
                hit.add(key)
    assert hit == set(m), set(m) - hit
    js(root, 'foes', d)
    return 'foe moves %s' % arg


def lever_aim(root, arg):
    """Every foe's aim, and every move's own, set to one: aim:anything (a level draw, the random baseline)"""
    aim = arg or 'anything'
    d = jl(root, 'foes')
    moved = 0
    for f in d['entries']:
        if f.get('aim', 'exposed') != aim:
            moved += 1
        f['aim'] = aim
        for a in f.get('actions', []):
            if 'aim' in a:
                a['aim'] = aim
    js(root, 'foes', d)
    return 'every foe aims at %s (%d moved)' % (aim, moved)


def lever_flak_clock(root, arg):
    """Flak's clock in the engine's status table: flak_clock:tick (a stack a round) or flak_clock:half"""
    p = f'{root}/sim/effects.gd'
    s = open(p, encoding='utf-8').read()
    i = s.index('"flakked": {"id": "flakked"')
    j = s.index('\n', i)
    line = s[i:j]
    if arg == 'tick':
        new = line.replace(' "decay": "half",', '')
        assert new != line, 'the Flak status carries no halving clock to remove'
    else:
        new = line
    s = s[:i] + new + s[j:]
    open(p, 'w', encoding='utf-8').write(s)
    return 'Flak\'s clock: %s' % (arg or 'half')


def lever_set(root, arg):
    """Any one content value, the value as JSON: set:chassis/badger/hull=30, set:components/stoker/face/heat=2"""
    path, value = arg.split('=', 1)
    fname, eid, *keys = path.split('/')
    d = jl(root, fname)
    for e in d['entries']:
        if e['id'] == eid:
            o = e
            for k in keys[:-1]:
                o = o[k]
            o[keys[-1]] = json.loads(value)
            break
    else:
        raise SystemExit('no entry ' + eid)
    js(root, fname, d)
    return 'set %s' % arg


LEVERS = {k[6:]: v for k, v in globals().items() if k.startswith('lever_')}


# ------------------------------------------------------------------ the runs

def godot(root, args, log):
    return subprocess.Popen([GODOT, '--headless', '--path', root, '-s'] + args, stdout=open(log, 'w'), stderr=subprocess.STDOUT)


def wait_all(procs, limit):
    """Every process waited for, each killed past its limit (a tool script that errors before quit() hangs)."""
    for p in procs:
        try:
            p.wait(timeout=limit)
        except subprocess.TimeoutExpired:
            p.kill()
            print('a run hung past %d s and was killed' % limit, file=sys.stderr)


def run_balance(root, tag, rows, policies, seeds, extra, parts=4):
    procs = []
    for i in range(parts):
        procs.append(godot(root, ['tools/balance.gd', '--', '--seeds', str(seeds), '--rows', ','.join(rows),
                                  '--policies', ','.join(policies), '--part', f'{i}/{parts}',
                                  '--json', f'{root}/{tag}_part{i}.json'] + extra,
                           f'{root}/{tag}_part{i}.log'))
    return procs


def merge_balance(root, tag, rows, policies, seeds, extra, parts=4):
    jsons = ','.join(f'{root}/{tag}_part{i}.json' for i in range(parts))
    p = godot(root, ['tools/balance.gd', '--', '--seeds', str(seeds), '--rows', ','.join(rows),
                     '--policies', ','.join(policies), '--merge', jsons, '--out', f'{root}/{tag}.md',
                     '--json', f'{root}/{tag}.json'] + extra, f'{root}/{tag}_merge.log')
    wait_all([p], 900)


# ------------------------------------------------------------------ the summary

def pct(a, b):
    return 100.0 * a / b if b else 0.0


def groups(packs, foes):
    """The packs by kind: the wildlife (trash), the massive foes, the formations, the heroes' finals, the finale."""
    out = {g: [] for g in GROUPS}
    for p in packs:
        pid = p['id']
        if pid == 'finale':
            out['finale'].append(pid)
        elif pid.endswith(' final'):
            out['final'].append(pid)
        elif pid.endswith(' formation'):
            out['formation'].append(pid)
        elif int(foes.get(p.get('foe', ''), {}).get('size', 1)) >= 2:
            out['massive'].append(pid)
        else:
            out['trash'].append(pid)
    return out


def is_team(rid):
    return rid in TEAMS or rid.startswith('team:') or rid.endswith(' team') or rid == 'team'


def summarise_team(root, tag='teams'):
    data = json.load(open(f'{root}/{tag}.json'))
    foes = {f['id']: f for f in jl(root, 'foes')['entries']}
    packs = data['packs']
    cells = data['cells']
    G = groups(packs, foes)
    pols = sorted({k.split('|')[2] for k in cells}, key=lambda x: POLICIES.index(x) if x in POLICIES else 9)
    L = []
    for r in data['rows']:
        rid = r['id']
        if not is_team(rid):
            continue
        L.append(f"### {r['name']}")
        L.append('')
        L.append('| Group | ' + ' | '.join(f'{p} win% / rounds / hull lost%' for p in pols) + ' |')
        L.append('|---|' + '---|' * len(pols))
        for g, ids in G.items():
            if not ids:
                continue
            row = [f'{g} ({len(ids)})']
            for pol in pols:
                wins = fights = 0
                hull = 0.0
                rounds_by = []
                for pid in ids:
                    a = cells[f'{rid}|{pid}|{pol}']
                    wins += a['victory']; fights += a['fights']; hull += a['hull_lost_pct']
                    if a['victory']:
                        rounds_by.append(a['rounds_won'] / a['victory'])
                rr = (sum(rounds_by) / len(rounds_by)) if rounds_by else float('nan')
                lo = min(rounds_by) if rounds_by else float('nan')
                hi = max(rounds_by) if rounds_by else float('nan')
                row.append('%.0f / %.1f (%.1f-%.1f) / %.1f' % (pct(wins, fights), rr, lo, hi, hull / max(1, fights)))
            L.append('| ' + ' | '.join(row) + ' |')
        for pid in G['massive'] + G['finale']:
            parts = []
            for pol in pols:
                a = cells[f'{rid}|{pid}|{pol}']
                rr = a['rounds_won'] / a['victory'] if a['victory'] else float('nan')
                parts.append('%s %.0f%% %.1f r %.0f%% hull' % (pol, pct(a['victory'], a['fights']), rr, a['hull_lost_pct'] / max(1, a['fights'])))
            L.append(f'- {pid}: ' + '; '.join(parts))
        if 'blind' in pols and 'planner' in pols:
            def ratios_of(ids):
                out = []
                for pid in ids:
                    a = cells[f'{rid}|{pid}|blind']; b = cells[f'{rid}|{pid}|planner']
                    if pct(a['victory'], a['fights']) < GAP_MIN_WIN or pct(b['victory'], b['fights']) < GAP_MIN_WIN:
                        continue
                    rb = b['rounds_won'] / max(1, b['victory'])
                    if rb > 0:
                        out.append((a['rounds_won'] / max(1, a['victory'])) / rb)
                return out
            big = [p['id'] for p in packs if p['id'] not in G['trash']]
            for which, ids in (('big fights', big), ('rank and file', G['trash'])):
                rs = ratios_of(ids)
                if rs:
                    L.append('- gap blind/planner, %s: %.2f over %d (%.2f to %.2f)' % (which, sum(rs) / len(rs), len(rs), min(rs), max(rs)))
                else:
                    L.append('- gap blind/planner, %s: none both win often enough' % which)
            for which in ('massive', 'formation', 'final'):
                rs = ratios_of(G[which])
                if rs:
                    L.append('  - %s: %.2f over %d' % (which, sum(rs) / len(rs), len(rs)))
        for pol in [p for p in ('greedy', 'planner') if p in pols]:
            t = {'fights': 0, 'heat_peak': 0.0, 'hot_rounds': 0, 'overheats': 0, 'overheat_hull': 0, 'forced': 0}
            for p in packs:
                a = cells[f'{rid}|{p["id"]}|{pol}']
                for k in t:
                    t[k] += a.get(k, 0)
            n = max(1, t['fights'])
            L.append('- heat, %s: peak %.0f%%, hot rounds %.2f, overheats %.2f, hull burned %.2f, held for heat %.2f a fight' % (
                pol, t['heat_peak'] / n, t['hot_rounds'] / n, t['overheats'] / n, t['overheat_hull'] / n, t['forced'] / n))
        if 'planner' in pols:
            plans = changes = fights = 0
            for p in packs:
                a = cells[f'{rid}|{p["id"]}|planner']
                plans += a.get('plans', 0); changes += a.get('plan_changes', 0); fights += a['fights']
            L.append('- planner: %.1f decisions a fight, %.0f%% changed' % (plans / max(1, fights), pct(changes, plans)))
        if 'greedy' in pols:
            spends = {}
            for p in packs:
                for c, n in cells[f'{rid}|{p["id"]}|greedy']['spends'].items():
                    spends[c] = spends.get(c, 0) + n
            tot = sum(spends.values())
            if tot:
                L.append('- greedy spends: ' + ', '.join('%s %.0f%%' % (c, pct(n, tot)) for c, n in sorted(spends.items(), key=lambda x: -x[1])))
        L.append('')
    return L


def summarise_alone(root, tag='alone'):
    data = json.load(open(f'{root}/{tag}.json'))
    foes = {f['id']: f for f in jl(root, 'foes')['entries']}
    packs = data['packs']
    cells = data['cells']
    G = groups(packs, foes)
    L = ['| Chassis | win% trash / massive / formation | rounds trash / massive | peak | hot rounds | overheats | hull burned | held | rounds |', '|---|---|---|---|---|---|---|---|---|']
    for r in data['rows']:
        rid = r['id']
        t = {'fights': 0, 'heat_peak': 0.0, 'hot_rounds': 0, 'overheats': 0, 'overheat_hull': 0, 'forced': 0, 'rounds': 0}
        for p in packs:
            a = cells[f'{rid}|{p["id"]}|greedy']
            for k in t:
                t[k] += a.get(k, 0)
        n = max(1, t['fights'])
        w = []
        rr = []
        for g in ('trash', 'massive', 'formation'):
            wins = fights = 0
            rs = []
            for pid in G[g]:
                a = cells[f'{rid}|{pid}|greedy']
                wins += a['victory']; fights += a['fights']
                if a['victory']:
                    rs.append(a['rounds_won'] / a['victory'])
            w.append('%.0f' % pct(wins, fights))
            if g != 'formation':
                rr.append('%.1f' % (sum(rs) / len(rs)) if rs else '-')
        L.append('| %s | %s | %s | %.0f%% | %.2f | %.2f | %.2f | %.2f | %.1f |' % (
            r['name'], ' / '.join(w), ' / '.join(rr), t['heat_peak'] / n, t['hot_rounds'] / n, t['overheats'] / n,
            t['overheat_hull'] / n, t['forced'] / n, t['rounds'] / n))
    return L


def summarise_campaign(root):
    p = f'{root}/campaign.md'
    if not os.path.exists(p):
        return ['(no campaign report)']
    s = open(p, encoding='utf-8').read()
    L = []
    for pat in [r'\| Runs won \| [^|]*\|', r'\| Runs that reached the finale \| [^|]*\|', r'\d+ battles\. Won [^\n]*',
                r'\| Machines wrecked per battle \| [^|]*\| [^|]*\|', r'\| Components destroyed per battle, any outcome \| [^|]*\| [^|]*\|',
                r'\| 1 machines \| [^\n]*', r'\| 2 machines \| [^\n]*', r'\| 3 machines \| [^\n]*', r'\| the finale \| [^\n]*',
                r'\| 1 of 1 \| [^\n]*', r'\| 2 of 2 \| [^\n]*', r'\| 3 of 3 \| [^\n]*']:
        m = re.search(pat, s)
        if m:
            L.append('- ' + m.group(0).strip('| ').replace(' | ', ': ', 1))
    return L


def write_summary(root, name, moved, times):
    L = [f'# Loop {name}', '', 'Levers: ' + ('; '.join(moved) if moved else 'none (the content as it stands)'), '']
    if times:
        L += ['Times: ' + ', '.join(f'{k} {v:.0f} s' for k, v in times.items()), '']
    if os.path.exists(f'{root}/teams.json'):
        L += ['## Teams', ''] + summarise_team(root)
    if os.path.exists(f'{root}/alone.json'):
        L += ['## Alone, greedy, no party', ''] + summarise_alone(root) + ['']
    L += ['## Campaign', ''] + summarise_campaign(root) + ['']
    out = '\n'.join(L)
    open(f'{root}/summary.md', 'w', encoding='utf-8').write(out)
    print(out)


# ------------------------------------------------------------------ compare

def reads(root):
    """One loop's team rows by group: random and greedy win rates, greedy rounds and hull, the gap where both rungs ran."""
    p = f'{root}/teams.json'
    if not os.path.exists(p):
        return None
    d = json.load(open(p))
    foes = {f['id']: f for f in jl(root, 'foes')['entries']}
    G = groups(d['packs'], foes)
    cells = d['cells']
    out = {}
    for r in d['rows']:
        rid = r['id']
        t = {}
        for g in GROUPS:
            ids = G[g]
            if not ids:
                continue
            row = {}
            for pol in POLICIES:
                ks = [f'{rid}|{p}|{pol}' for p in ids]
                if not all(k in cells for k in ks):
                    continue
                a = [cells[k] for k in ks]
                w = sum(x['victory'] for x in a); n = sum(x['fights'] for x in a)
                rr = [x['rounds_won'] / x['victory'] for x in a if x['victory']]
                row[pol] = (100.0 * w / n, sum(rr) / len(rr) if rr else float('nan'), sum(x['hull_lost_pct'] for x in a) / n)
            t[g] = row
        a = [cells[f'{rid}|{p["id"]}|greedy'] for p in d['packs'] if f'{rid}|{p["id"]}|greedy' in cells]
        n = max(1, sum(x['fights'] for x in a))
        heat = (sum(x['heat_peak'] for x in a) / n, sum(x['overheats'] for x in a) / n, sum(x['forced'] for x in a) / n) if a else None
        out[r['name'].split(' (')[0]] = (t, heat)
    return out


def campaign_line(root):
    p = f'{root}/campaign.md'
    if not os.path.exists(p):
        return 'no campaign report'
    s = open(p, encoding='utf-8').read()
    m = re.search(r'(\d+) battles\. Won (\d+)%[^;]*; (\d+)% of battles ended in a team wipe', s)
    three = re.search(r'\| 3 machines \| \d+ \| (\d+)%', s)
    one = re.search(r'\| 1 of 1 \| \d+ \| (\d+)%', s)
    fin = re.search(r'\| Runs that reached the finale \| (\d+) of', s)
    return 'battles won %s%%, wiped %s%%, 3-machine battles won %s%%, lone fights won %s%%, finale reached %s/40' % (
        m.group(2) if m else '?', m.group(3) if m else '?', three.group(1) if three else '?', one.group(1) if one else '?', fin.group(1) if fin else '?')


def compare(names):
    roots = {n: (n if os.path.isdir(n) else os.path.join(OUT, n)) for n in names}
    R = {n: reads(r) for n, r in roots.items()}
    teams = []
    for v in R.values():
        for t in (v or {}):
            if t not in teams:
                teams.append(t)
    for team in teams:
        print('### ' + team)
        print('| Group | ' + ' | '.join(names) + ' |')
        print('|---|' + '---|' * len(names))
        for g in GROUPS:
            cells = []
            for n in names:
                row = (R[n] or {}).get(team, ({}, None))[0].get(g)
                if not row:
                    cells.append('')
                    continue
                s = ''
                if 'random' in row:
                    s += 'r%.0f ' % row['random'][0]
                if 'greedy' in row:
                    s += 'g%.0f %.1fr %.1f%%' % row['greedy']
                if 'planner' in row and 'blind' in row and row['planner'][1]:
                    s += ' gap %.2f' % (row['blind'][1] / row['planner'][1])
                cells.append(s)
            print('| %s | %s |' % (g, ' | '.join(cells)))
        hs = []
        for n in names:
            h = (R[n] or {}).get(team, (None, None))[1]
            hs.append('peak %.0f%% oh %.2f held %.2f' % h if h else '')
        print('| heat, greedy | %s |' % ' | '.join(hs))
        print()
    for n in names:
        print('- %s: %s' % (n, campaign_line(roots[n])))


# ------------------------------------------------------------------ main

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    r = sub.add_parser('run', help='copy the project, move the levers, run the runner, summarise')
    r.add_argument('name')
    r.add_argument('--lever', action='append', default=[], help='name:arg, repeatable, applied in order; `levers` lists them')
    r.add_argument('--seeds', type=int, default=30)
    r.add_argument('--policies', default=','.join(POLICIES))
    r.add_argument('--rows', default=','.join(TEAMS), help='the runner\'s row ids (the default team is a --team row here)')
    r.add_argument('--packs', default='', help='the runner\'s --packs: big, rank_and_file, or pack ids')
    r.add_argument('--team', action='append', default=[], help='the runner\'s --team, repeatable: a row of exactly these chassis ids (its row id is team:a+b+c)')
    r.add_argument('--set', action='append', default=[], help='the runner\'s --set, repeatable: path=json, applied after the content loads and never validated (a fit no stock may carry)')
    r.add_argument('--fit', action='append', default=[], help='the runner\'s --fit, repeatable: chassis=module,module, fitted to every machine of that chassis')
    r.add_argument('--alone', action='store_true', help='every chassis alone too, greedy, without the party')
    r.add_argument('--alone-rows', default='', help='with --alone: only these chassis ids')
    r.add_argument('--no-team', action='store_true')
    r.add_argument('--no-campaign', action='store_true')
    r.add_argument('--summary-only', action='store_true', help='re-read a finished loop\'s files')
    c = sub.add_parser('compare', help='finished loops side by side, by team row and kind of fight')
    c.add_argument('names', nargs='+')
    sub.add_parser('levers', help='list the levers')
    a = ap.parse_args()
    if a.cmd == 'levers':
        for k, f in LEVERS.items():
            print('%-12s %s' % (k, (f.__doc__ or '').strip()))
        return
    if a.cmd == 'compare':
        compare(a.names)
        return
    root = os.path.join(OUT, a.name)
    if a.summary_only:
        m = open(f'{root}/levers.txt').read().split('\n') if os.path.exists(f'{root}/levers.txt') else []
        write_summary(root, a.name, [x for x in m if x], {})
        return
    if not os.path.exists(os.path.join(REPO, '.godot')):
        raise SystemExit('no .godot import in the repository: run `godot --headless --path . --import` first')
    make_copy(root)
    moved = []
    for lv in a.lever:
        name, _, arg = lv.partition(':')
        if name not in LEVERS:
            raise SystemExit('no lever %r (`levers` lists them)' % name)
        moved.append(LEVERS[name](root, arg))
    open(f'{root}/levers.txt', 'w', encoding='utf-8').write('\n'.join(moved) + '\n')
    pols = a.policies.split(',')
    extra = TEAM_EXTRA + (['--packs', a.packs] if a.packs else [])
    for t in a.team:
        extra += ['--team', t]
    for v in a.set:
        extra += ['--set', v]
    for v in a.fit:
        extra += ['--fit', v]
    if a.set or a.fit:
        moved.append('the runner\'s overrides: ' + ', '.join(a.set + a.fit))
        open(f'{root}/levers.txt', 'w', encoding='utf-8').write('\n'.join(moved) + '\n')
    rows = a.rows.split(',')
    times = {}
    t0 = time.time()
    procs = []
    if not a.no_team:
        procs = run_balance(root, 'teams', rows, pols, a.seeds, extra)
    camp = None
    if not a.no_campaign:
        camp = godot(root, ['tools/campaign_run.gd', '--', '--runs', '40', '--out', f'{root}/campaign.md'], f'{root}/campaign.log')
    wait_all(procs, 14400)
    if not a.no_team:
        merge_balance(root, 'teams', rows, pols, a.seeds, extra)
        times['teams'] = time.time() - t0
    if a.alone:
        t1 = time.time()
        alone_rows = a.alone_rows.split(',') if a.alone_rows else [c['id'] for c in jl(root, 'chassis')['entries']]
        wait_all(run_balance(root, 'alone', alone_rows, ['greedy'], a.seeds, ['--noparty']), 14400)
        merge_balance(root, 'alone', alone_rows, ['greedy'], a.seeds, ['--noparty'])
        times['alone'] = time.time() - t1
    if camp is not None:
        wait_all([camp], 7200)
    times['all'] = time.time() - t0
    write_summary(root, a.name, moved, times)


if __name__ == '__main__':
    main()
