"""The stock pass's fills (22 October): the brief's numbers (its sections 1 to 5, retired:
git show a550c2e:docs/briefs/stock_pass.md, with Ryan's marks of 22 October) onto a checkout's content and the engine's
rule numbers, so the balance runner reads them against the design tests:
  python3 tools/stock_fills.py <checkout>
A fill set is the dictionaries below, one lever moved a loop. The content landed on these on
22 October (the stocks, the new pieces, the renames and retirements were the landing's), so
the script is idempotent on the branch and a loop runs it on a worktree with a lever moved.
Every edit is in place: the foes' file keeps its hand layout.
The loops (22 October, docs/measurements.md) moved: the foes' blows up by half on the rank and
file, a third on the massive foes and double on the heroes; the Sandworm's and the Elemental's armour
2 to 1; the Treant's and the Wyvern's regrow 5 to 3; the heat maxima 16 to 12 and 20 to 14 (the
Kite's 10 and the Musk Ox's 8 stand). The review of the same day (Ryan's go) raised the four
light machines' hull to the scales row's floor of 20 (the Prairie Dog, the Dingo, the Puffin, the
Cottonmouth; the Kite's paper hull 12 stands, its row's one-off)."""
import json, re, sys
R = sys.argv[1].rstrip('/') + '/'

def jload(p):
    raw = open(p, encoding='utf-8').read(); return raw, json.loads(raw)
def jsave(p, d, ascii_):
    open(p, 'w', encoding='utf-8').write(json.dumps(d, indent=1, ensure_ascii=ascii_) + '\n')
def edit(p, reps):
    s = open(p, encoding='utf-8').read()
    for o, n in reps:
        assert s.count(o) == 1, (p, s.count(o), o[:80])
        s = s.replace(o, n)
    open(p, 'w', encoding='utf-8').write(s)

# ---- chassis: hull, shield, recharge, heat max, cooling, armour (the brief's section 2)
C = {
 'badger': (36, 8, 4, 12, 1, 2), 'clydesdale': (40, 10, 5, 12, 1, 1), 'sparrowhawk': (12, 16, 8, 10, 2, 0),
 'baboon': (28, 10, 5, 14, 1, 0), 'armadillo': (40, 8, 4, 12, 1, 2), 'wild_boar': (36, 8, 5, 12, 1, 2),
 'prairie_dog': (20, 10, 8, 12, 1, 0), 'dingo': (20, 10, 6, 12, 1, 0), 'goshawk': (28, 12, 6, 14, 1, 0),
 'nemesis': (36, 6, 4, 14, 1, 2), 'ammit': (32, 10, 5, 14, 1, 1), 'stingray': (24, 12, 6, 14, 0, 0),
 'puffin': (20, 8, 8, 12, 1, 0), 'funnel_web': (30, 10, 5, 12, 1, 1), 'cassowary': (24, 8, 5, 12, 1, 0),
 'cottonmouth': (20, 8, 8, 12, 2, 0), 'whip_scorpion': (40, 8, 4, 14, 0, 1), 'swallowtail': (48, 14, 5, 14, 2, 1),
 'musk_ox': (44, 10, 5, 8, 1, 1),
 'lammergeier': (28, 16, 6, 14, 1, 0),   # not in the brief: today's numbers over four
}
raw, d = jload(R + 'content/chassis.json')
for c in d['entries']:
    h, s, r, hm, co, ar = C[c['id']]
    c['hull'], c['shield'], c['recharge_field'], c['heat_max'], c['cooling'], c['armour'] = h, s, r, hm, co, ar
    for eff in (c.get('passive') or {}).get('effects', []):
        e = eff.get('effect')
        if c['id'] == 'sparrowhawk' and e == 'add_heat': eff['value'] = 2
        if c['id'] == 'armadillo' and e == 'seal_form': eff['value'], eff['heat'] = 3, 3
        if c['id'] == 'prairie_dog' and e == 'add_damage_taken': eff['value'] = -1   # not in the brief: 5 less over four
        if c['id'] == 'goshawk' and e == 'shield_per_heat': eff['value'], eff['per_heat'] = 1, 4
        if c['id'] == 'stingray' and e == 'add_stacks': eff['per_heat'] = 5
        if c['id'] == 'puffin' and e == 'shield_per_ally_heat': eff['value'], eff['per_heat'] = 1, 2
        if c['id'] == 'cottonmouth' and e == 'rewrite_weapon': eff['value'], eff['heat'] = 4, 3
        if c['id'] == 'musk_ox' and e == 'forge': eff['per_heat'] = 2
jsave(R + 'content/chassis.json', d, False)

# ---- components: (power, power_max, heat) and extra face fields (section 3)
def A(p, pm=None, heat=0, **k): return dict(power=p, power_max=pm if pm is not None else p, heat=heat, **k)
def E(p, **k): return dict(power=p, **k)   # equipment: its number
P = {
 'twin_autoguns': A(1, 3, 0), 'rivet_gun': A(2, heat=0), 'ankle_mortar': A(1, 3, 1), 'laser_carbine': A(3, heat=2),
 'halo_shield': E(6), 'canopy': E(8), 'coolant_jacket': E(4), 'bleed_valve': E(6),
 'howitzer': A(2, 5, 1), 'incendiary_shells': A(1, 3, 1, burn=2), 'slugthrower': A(2, 5, 1), 'shotfire_rack': A(2, 4, 2),
 'maxigun': A(1, 2, 1, strikes=3), 'enfilade_beam': A(4, heat=2), 'arc_fault_cannon': A(4, heat=2),
 'overclocked_railgun': A(10, heat=8, keywords=['breach']), 'plasma_arquebus': A(2, 4, 2), 'blazethrower': A(3, heat=3, burn=2),
 'polarity_projector': A(0, heat=2), 'proximity_klaxon': A(0, heat=1), 'phased_sublimator': E(4), 'radiator_sail': E(5),
 'wake_diffuser': E(3, shields=3), 'overcharge_coil': dict(stacks=2), 'shoring_jack': dict(stacks=2), 'thermal_ray': A(6, heat=6),
 'retribution_thurible': {}, 'oblation_ward': E(10),
 'pulse_vacillator': A(2, heat=2), 'umbra_inducer': A(3, heat=0, keywords=['suppress', 'volatile']), 'differentiation_probe': A(0, heat=2), 'tesla_gauntlets': A(4, heat=3),
 'meteor_artillery': A(5, heat=6, burn=3), 'suppression_battery': A(1, 3, 2), 'coriolis_accelerator': A(3, heat=1, power_per_missing=1),
 'laminar_deflector': E(6), 'corona_shield': E(6), 'aurora_lattice': {}, 'entropy_condenser': E(10), 'gravity_knuckles': A(5, heat=4, burn=3),
 'chainsaw_claw': A(2, 4, 0), 'bullion_fragmenter': A(4, heat=2, power_per_load=1), 'breaching_plow': A(2, 5, 0, braces=2),
 'cryo_flinger': A(0, heat=1), 'flakshot_repeater': A(1, heat=0, flak=1), 'megataser_harpoon': A(1, 2, 2), 'combat_translocator': A(0, heat=1),
 'afterburner_cannon': A(2, heat=0, power_per_heat=1, per_heat=2), 'backwash_ionizer': E(3), 'web_bomb': A(0, heat=1),
 'heliographic_siphon': A(0, heat=0, braces=1, heat_per_blow=2), 'solar_flare_array': A(3, heat=3, burn=2), 'photosphere_lance': A(4, heat=6, burn=2),
 'knuckle_of_fury': A(5, heat=3), 'soulcutter_talons': A(3, heat=1, devours=1), 'spin_up': {},
 'mooring_screens': E(2), 'spotting_flare': A(0, heat=1), 'sutlers_hoist': E(3, vents=2), 'reveille_horn': {},
 'shrapnel_recuperator': A(1, heat=2, flak=1), 'unrestricted_expenditure': A(2, heat=0), 'quick_reload': dict(heat=3),
 'blast_door': {}, 'decoherence_veil': {},   # the Barrier and the Ward: no numbers
 'transonic_rifle': A(5, heat=4), 'airburst_shell': A(1, 2, 1, flak=1), 'cyclic_cannon': A(2, heat=3, strikes=4),
 'flak_cannon': A(3, heat=2, flak=2), 'stoker': A(3, heat=1, burn=2, self_burn=1), 'backdraft_charge': A(2, heat=2),
 'pinion_driver': A(2, heat=0, strikes=2), 'lorentz_contractor': A(0, heat=2), 'syrinx_drone': A(0, heat=0),   # not in the brief: today's over four (the Driver's four in two shots, Ryan, 29 October)
}
raw, d = jload(R + 'content/components.json')
seen = set()
for e in d['entries']:
    f = e['face']; fill = P[e['id']]; seen.add(e['id'])
    for k, v in fill.items():
        if k == 'power_max' and v == fill.get('power'):
            f.pop('power_max', None)   # a flat fill: one number, no roll
            continue
        f[k] = v
    if 'volatile' in f.get('keywords', []):
        f['volatile'] = 3          # Volatile bites 3 (a numbered keyword since 22 October)
    if f.get('power_per_missing'):
        f['per_missing'] = 5       # the missing-HP step (a field since 22 October)
assert seen == set(P), set(P) - seen
jsave(R + 'content/components.json', d, True)

# ---- foes: hp, blow, armour; the moves' values; the new breaches (section 4)
F = {
 'goblin': (3, 2, 0), 'wolf': (4, 3, 0), 'gel': (5, 3, 0), 'gel_half': (2, 2, 0), 'mandragora': (4, 3, 0), 'treant': (32, 7, 1),
 'needler': (2, 3, 0), 'antlion': (6, 6, 0), 'cockatrice': (4, 3, 0), 'sandworm': (36, 8, 1),
 'revenant': (3, 2, 0), 'ghost': (4, 3, 0), 'zombie_knight': (8, 6, 1), 'bone_dragon': (32, 7, 1),
 'bomb': (4, 8, 0), 'salamander': (6, 5, 0), 'drake': (4, 5, 0), 'magma_golem': (40, 8, 1),
 'warrior': (24, 10, 0), 'martial_artist': (20, 8, 0), 'thief': (18, 8, 0), 'lancer': (22, 10, 0),
 'white_mage': (18, 4, 0), 'augur': (18, 6, 0), 'black_mage': (18, 8, 0), 'summoner': (16, 4, 0),
}
PROMO = {'warrior_promoted': 48, 'martial_artist_promoted': 40, 'thief_promoted': 36, 'lancer_promoted': 44,
         'white_mage_promoted': 36, 'augur_promoted': 36, 'black_mage_promoted': 36, 'summoner_promoted': 32}
VALUES = {('wolf', 'howl'): 1, ('antlion', 'burrow'): 2, ('sandworm', 'burrow'): 3, ('treant', 'regen'): 3, ('bone_dragon', 'regen'): 3,
          ('magma_golem', 'stoke_the_forge'): 2, ('martial_artist', 'chakra'): 4, ('white_mage', 'cure'): 4}
BREACH = {('gel', 'engulf'), ('zombie_knight', 'cleaver'), ('warrior', 'cleave')}
# The foes' file is laid out by hand (an entry's fields on a few lines, a move a line), so it is
# edited in place, line by line, and checked against what the edits mean.
raw = open(R + 'content/foes.json', encoding='utf-8').read()
want = json.loads(raw)
for f in want['entries']:
    i = f['id']
    if i in F:
        f['hp'], f['attack'] = F[i][0], F[i][1]
        if 'armour' in f or F[i][2] > 0:
            f['armour'] = F[i][2]
    elif i in PROMO:
        f['hp'] = PROMO[i]; f['armour'] = 2
    for a in f.get('actions', []):
        if 'swarm' in a: a['swarm'] = 1   # not in the brief: 5 over five
        if (i, a['id']) in VALUES: a['value'] = VALUES[(i, a['id'])]
        if (i, a['id']) in BREACH and 'breach' not in a.get('keywords', []):
            a['keywords'] = a.get('keywords', []) + ['breach']


def setnum(line, key, value, after=None):
    """The number under `key` on this line set to `value`; added after `after` when absent."""
    pat = r'("%s": )-?\d+' % key
    if re.search(pat, line):
        return re.sub(pat, r'\g<1>%d' % value, line, count=1)
    assert after is not None and after in line, (key, line[:80])
    return line.replace(after, after + ' "%s": %d,' % (key, value), 1)


out, cur = [], None
for line in raw.split('\n'):
    m = re.match(r'^      "id": "([^"]+)"', line)
    if m:
        cur = m.group(1)
        if cur in PROMO:
            line = setnum(line, 'armour', 2)
            if '"hp":' not in line:
                line = line.replace('"armour":', '"hp": %d, "armour":' % PROMO[cur], 1)
            else:
                line = setnum(line, 'hp', PROMO[cur])
    if cur in F and re.search(r'^\s*"hp": \d+, "attack": \d+', line):
        hp, atk, arm = F[cur]
        line = setnum(line, 'hp', hp)
        line = setnum(line, 'attack', atk)
        if '"armour":' in line or arm > 0:
            line = setnum(line, 'armour', arm, after='"attack": %d,' % atk)
    a = re.match(r'^\s*\{\s*"id": "([^"]+)"', line)
    if a and cur is not None:
        aid = a.group(1)
        obj = json.loads(line.strip().rstrip(','))
        if 'swarm' in obj:
            line = setnum(line, 'swarm', 1)
        if (cur, aid) in VALUES:
            line = setnum(line, 'value', VALUES[(cur, aid)])
        if (cur, aid) in BREACH and 'breach' not in obj.get('keywords', []):
            if '"keywords": [' in line:
                line = re.sub(r'"keywords": \[([^\]]*)\]', lambda k: '"keywords": [%s]' % ', '.join([x for x in [k.group(1).strip()] if x] + ['"breach"']), line, count=1)
            else:
                line = line.replace('"kind": "attack",', '"kind": "attack", "keywords": ["breach"],', 1)
    out.append(line)
text = '\n'.join(out)
assert json.loads(text) == want, 'the in-place edits and the data disagree'
open(R + 'content/foes.json', 'w', encoding='utf-8').write(text)

# ---- modules (section 5)
M = {
 'ablative_plating': ({'hull': 8, 'armour': 1, 'move': -1}, None), 'ram_frame': ({'hull': 24}, None),
 'spall_liner': ({'move': -1, 'heat': -4}, [2]), 'boundary_layer_bleed': ({'cooling': 1}, [1]), 'muzzle_velocity_booster': ({}, [1]),
 'thrust_overboost': ({'move': 2, 'shield': 12}, [2]), 'flak_skirt': ({'hull': 6}, None), 'field_radiators': ({'heat': 4, 'cooling': 1}, None),
 'tactical_databank': ({}, [1]), 'artillery_rangefinder': ({}, None), 'phase_conjugator': ({'shield': 4}, ['stacks', 1]),
 'susceptibility_tensor': ({'shield': 4}, [1]), 'exotic_matter_shell': ({'shield': 16, 'heat': 6}, [2]), 'ward_plate': ({'shield': 8, 'armour': 1}, None),
 'grievance_reliquary': ({'hull': 4}, None), 'tithe_coupling': ({'hull': 20, 'shield': 12}, [3]),
 'trim_tabs': ({'heat': -4}, None),
}
raw, d = jload(R + 'content/modules.json')
for m in d['entries']:
    stats, val = M[m['id']]
    m['stats'] = stats
    t = m.get('text')
    if isinstance(t, dict) and val and t.get('effects'):
        if val[0] == 'stacks': t['effects'][0]['stacks'] = val[1]
        else: t['effects'][0]['value'] = val[0]
jsave(R + 'content/modules.json', d, False)

# ---- the engine's constants and status values (section 1's tables)
s = open(R + 'sim/effects.gd', encoding='utf-8').read()
def status_value(s, sid, effect, new):
    i = s.index('"%s": {"id": "%s"' % (sid, sid)); j = s.index('\n\t"', i + 1) if '\n\t"' in s[i+1:] else len(s)
    block = s[i:j]
    m = re.search(r'("effect": "%s", "value": )(\d+)' % effect, block)
    assert m, (sid, effect)
    block = block[:m.start(2)] + str(new) + block[m.end(2):]
    return s[:i] + block + s[j:]
s = status_value(s, 'burning_mech', 'tick_heat', 1)
s = status_value(s, 'scorched', 'add_heat', 1)
s = status_value(s, 'vitriol', 'tick_hp_share', 10)
s = status_value(s, 'kindled', 'add_attack', 2)
s = status_value(s, 'siphoning', 'heat_per_blow', 2)
s = status_value(s, 'spun_up', 'add_damage', 2)
s = status_value(s, 'hot_streak', 'add_heat', 1)
s = status_value(s, 'cryoed', 'cool_hitter', 2)       # Cryo's cooling, a field on its status since 22 October
s = status_value(s, 'corrupted', 'corrupt_bite', 3)   # Corrupted's bite, likewise
open(R + 'sim/effects.gd', 'w', encoding='utf-8').write(s)
# The bot's weights in foe HP, at the new scale.
s = open(R + 'sim/policy.gd', encoding='utf-8').read()
for name, value in (('KILL_BONUS', '3.0'), ('DEATH_WEIGHT', '20.0')):
    s, n = re.subn(r'(const %s := )[0-9.]+' % name, r'\g<1>' + value, s)
    assert n == 1, name
open(R + 'sim/policy.gd', 'w', encoding='utf-8').write(s)
print('fills applied')
