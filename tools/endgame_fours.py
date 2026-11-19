#!/usr/bin/env python3
"""The endgame fours (23 October, the endgame half of Ryan's read by stage: which foes and
compositions are harder for an early stock trio than for an endgame four). Five squads of four,
chassis of any tier, every hardpoint and module slot filled from tiers zero to two, since tier
three is powerful and rare by design (Ryan, 23 October: until the components' power curve is
known). Built by Claude for the read, each a concept; the fits are Ryan's to move.

  python3 tools/endgame_fours.py <name> [stock_loop run options]...
  python3 tools/endgame_fours.py --json    # the five as tools/chain_probe.gd's squads

checks every fit against the content (tier two at most, no more pieces than hardpoints or
modules than slots) and runs `tools/stock_loop.py run <name>` on the five rows, random and
greedy at 30 seeds without the campaign unless the options say otherwise, the loadouts through
the runner's --set and the modules through its --fit. The starter half is every trio the tender
deals, stock (docs/measurements.md, 23 October)."""
import json, os, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# chassis id: (the pieces in its hardpoints, its modules)
KITS = {
    'nemesis': (['meteor_artillery', 'blazethrower', 'backdraft_charge'], ['ward_plate', 'grievance_reliquary']),
    'wild_boar': (['tesla_gauntlets', 'slugthrower', 'shotfire_rack'], ['ram_frame', 'spall_liner']),
    'badger': (['transonic_rifle'], ['ram_frame', 'spall_liner']),
    'buzzard': (['overclocked_railgun', 'transonic_rifle', 'cyclic_cannon'], ['boundary_layer_bleed', 'ward_plate']),
    'prairie_dog': (['flak_cannon', 'corona_shield'], ['susceptibility_tensor', 'flak_skirt']),
    'clydesdale': (['maxigun', 'cyclic_cannon', 'enfilade_beam', 'howitzer', 'howitzer', 'airburst_shell',
                    'suppression_battery'], ['spall_liner', 'susceptibility_tensor', 'flak_skirt']),
    'baboon': (['polarity_projector', 'pulse_vacillator', 'corona_shield', 'airburst_shell',
                'differentiation_probe'], ['phase_conjugator', 'susceptibility_tensor']),
    'dingo': (['airburst_shell', 'cyclic_cannon'], ['susceptibility_tensor', 'flak_skirt']),
    'lammergeier': (['meteor_artillery', 'polarity_projector', 'cyclic_cannon'], ['boundary_layer_bleed', 'ward_plate']),
    'kite': (['transonic_rifle'], ['boundary_layer_bleed', 'ward_plate']),
    'puffin': (['corona_shield', 'laminar_deflector', 'cyclic_cannon'], ['phase_conjugator', 'flak_skirt']),
    'cottonmouth': (['flak_cannon', 'tesla_gauntlets', 'meteor_artillery', 'corona_shield'], ['susceptibility_tensor', 'flak_skirt']),
    'polar_bear': (['proximity_klaxon', 'slugthrower'], ['ward_plate', 'ablative_plating']),
    'musk_ox': (['thermal_ray', 'enfilade_beam'], ['ward_plate', 'flak_skirt']),
    'stingray': (['incendiary_shells', 'airburst_shell', 'corona_shield', 'aurora_lattice'],
                 ['susceptibility_tensor', 'field_radiators']),
    'funnel_web': (['maxigun', 'howitzer', 'cyclic_cannon'], ['susceptibility_tensor', 'flak_skirt']),
    'whip_scorpion': (['thermal_ray', 'entropy_condenser', 'maxigun'], ['ward_plate', 'ablative_plating']),
}
FOURS = [
    ('the heavy line', ['nemesis', 'wild_boar', 'badger', 'buzzard']),
    ('the setups', ['prairie_dog', 'clydesdale', 'baboon', 'dingo']),
    ("Kestrel's four", ['lammergeier', 'kite', 'puffin', 'buzzard']),
    ('armour and the drum', ['badger', 'cottonmouth', 'polar_bear', 'musk_ox']),
    ('the statuses', ['stingray', 'funnel_web', 'whip_scorpion', 'baboon']),
]
MAX_TIER = 2


def entries(name):
    return {e['id']: e for e in json.load(open(f'{REPO}/content/{name}.json', encoding='utf-8'))['entries']}


def check():
    co, mo, ch = entries('components'), entries('modules'), entries('chassis')
    errs = []
    for cid, (load, mods) in KITS.items():
        c = ch[cid]
        if len(load) > c['hardpoints']:
            errs.append(f'{cid}: {len(load)} pieces for {c["hardpoints"]} hardpoints')
        if len(mods) > c['module_slots']:
            errs.append(f'{cid}: {len(mods)} modules for {c["module_slots"]} slots')
        errs += [f'{cid}: {x} is tier {co[x].get("tier")}' for x in load if co[x].get('tier') is None or co[x]['tier'] > MAX_TIER]
        errs += [f'{cid}: module {m} is tier {mo[m]["tier"]}' for m in mods if mo[m]['tier'] > MAX_TIER]
    return errs


def loop_args():
    args = ['--rows', ','.join('team:' + '+'.join(f) for _, f in FOURS)]
    for cid in sorted({c for _, f in FOURS for c in f}):
        load, mods = KITS[cid]
        args += ['--set', f'chassis/{cid}/loadout=' + json.dumps(load, separators=(',', ':')), '--fit', f'{cid}=' + ','.join(mods)]
    for _, f in FOURS:
        args += ['--team', ','.join(f)]
    return args


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    errs = check()
    if errs:
        raise SystemExit('\n'.join(errs))
    if sys.argv[1] == '--json':
        print(json.dumps([[[cid, KITS[cid][0], KITS[cid][1]] for cid in f] for _, f in FOURS]))
        return
    extra = sys.argv[2:]
    defaults = [] if '--policies' in extra else ['--policies', 'random,greedy']
    defaults += [] if '--seeds' in extra else ['--seeds', '30']
    defaults += [] if '--campaign' in extra else ['--no-campaign']
    extra = [x for x in extra if x != '--campaign']
    sys.exit(subprocess.call([sys.executable, f'{REPO}/tools/stock_loop.py', 'run', sys.argv[1]] + loop_args() + defaults + extra))


if __name__ == '__main__':
    main()
