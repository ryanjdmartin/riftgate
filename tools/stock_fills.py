"""The stock pass's fills onto a scratch checkout, for a direction run (22 October):
  python3 tools/stock_fills.py <checkout>
Applies the brief's numbers (docs/briefs/stock_pass.md, sections 1 to 5, with Ryan's marks of
22 October) to the checkout's content and the engine's constants, so the balance runner can
read them against the design tests; a fill set is the dictionaries below, one lever moved a
loop. Stocks stay today's (the new pieces do not exist); modules are filled but the runner
fits none by default. The checkout is a worktree, never the main folder; run its --import
after this and its tests will fail on the numbers they assert, as expected."""
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
 'badger': (36, 8, 4, 16, 1, 2), 'clydesdale': (40, 10, 5, 16, 1, 1), 'sparrowhawk': (12, 16, 8, 10, 2, 0),
 'baboon': (28, 10, 5, 20, 1, 0), 'armadillo': (40, 8, 4, 16, 1, 2), 'wild_boar': (36, 8, 5, 16, 1, 2),
 'prairie_dog': (16, 10, 8, 16, 1, 0), 'dingo': (16, 10, 6, 16, 1, 0), 'goshawk': (28, 12, 6, 20, 1, 0),
 'nemesis': (36, 6, 4, 20, 1, 2), 'ammit': (32, 10, 5, 20, 1, 1), 'stingray': (24, 12, 6, 20, 0, 0),
 'puffin': (16, 8, 8, 16, 1, 0), 'funnel_web': (30, 10, 5, 16, 1, 1), 'cassowary': (24, 8, 5, 16, 1, 0),
 'cottonmouth': (16, 8, 8, 16, 2, 0), 'whip_scorpion': (40, 8, 4, 20, 0, 1), 'swallowtail': (48, 14, 5, 20, 2, 1),
 'musk_ox': (44, 10, 5, 8, 1, 1),
 'lammergeier': (28, 16, 6, 20, 1, 0),   # not in the brief: today's numbers over four
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
 'halo_shield': E(6), 'blast_door': E(8), 'coolant_jacket': E(4), 'ram_air_scoop': E(6),
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
 'zenith_emitter': A(3, heat=2), 'coolant_dump': E(6), 'blowout_stack': E(5),
 'pinion_driver': A(4, heat=0), 'lorentz_contractor': A(0, heat=2), 'syrinx_drone': A(0, heat=0),   # not in the brief: today's over four
}
# The stun calls (Ryan, 22 October): the Inducer is the Arsenal's at tier three, Volatile in place of heat;
# the Battery's cooldown goes (no price for a Suppress). Their gates wait on the engine's face condition.
MOVED = {'umbra_inducer': dict(maker='arsenal', tier=3)}
raw, d = jload(R + 'content/components.json')
seen = set()
for e in d['entries']:
    f = e['face']; fill = P[e['id']]; seen.add(e['id'])
    for k, v in MOVED.get(e['id'], {}).items():
        e[k] = v
    for k, v in fill.items():
        if k == 'power_max' and 'power_max' not in f and v == fill.get('power'):
            continue
        f[k] = v
    if 'power_max' in f and f['power_max'] == f.get('power') and e['face']['kind'] == 'attack' and 'power_max' not in fill:
        pass
assert seen == set(P), set(P) - seen
jsave(R + 'content/components.json', d, True)

# ---- foes: hp, blow, armour; the moves' values; the new breaches (section 4)
F = {
 'goblin': (3, 1, 0), 'wolf': (4, 2, 0), 'gel': (5, 2, 0), 'gel_half': (2, 1, 0), 'mandragora': (4, 2, 0), 'treant': (32, 5, 1),
 'needler': (2, 2, 0), 'antlion': (6, 4, 0), 'cockatrice': (4, 2, 0), 'sandworm': (36, 6, 2),
 'revenant': (3, 1, 0), 'ghost': (4, 2, 0), 'zombie_knight': (8, 4, 1), 'bone_dragon': (32, 5, 1),
 'bomb': (4, 5, 0), 'salamander': (6, 3, 0), 'drake': (4, 3, 0), 'magma_golem': (40, 6, 2),
 'warrior': (24, 5, 0), 'martial_artist': (20, 4, 0), 'thief': (18, 4, 0), 'lancer': (22, 5, 0),
 'white_mage': (18, 2, 0), 'augur': (18, 3, 0), 'black_mage': (18, 4, 0), 'summoner': (16, 2, 0),
}
PROMO = {'warrior_promoted': 48, 'martial_artist_promoted': 40, 'thief_promoted': 36, 'lancer_promoted': 44,
         'white_mage_promoted': 36, 'augur_promoted': 36, 'black_mage_promoted': 36, 'summoner_promoted': 32}
VALUES = {('wolf', 'howl'): 1, ('antlion', 'burrow'): 2, ('sandworm', 'burrow'): 3, ('treant', 'regen'): 5, ('bone_dragon', 'regen'): 5,
          ('magma_golem', 'stoke_the_forge'): 2, ('martial_artist', 'chakra'): 4, ('white_mage', 'cure'): 4}
BREACH = {('gel', 'engulf'), ('zombie_knight', 'cleaver'), ('warrior', 'cleave')}
raw = open(R + 'content/foes.json', encoding='utf-8').read()
d = json.loads(raw)
for f in d['entries']:
    i = f['id']
    if i in F:
        f['hp'], f['attack'], f['armour'] = F[i]
    elif i in PROMO:
        f['hp'] = PROMO[i]; f['armour'] = 2
    for a in f.get('actions', []):
        if 'swarm' in a: a['swarm'] = 1   # not in the brief: 5 over five
        if (i, a['id']) in VALUES: a['value'] = VALUES[(i, a['id'])]
        if (i, a['id']) in BREACH:
            a['keywords'] = sorted(set(a.get('keywords', [])) | {'breach'})
# foes.json does not round-trip through json.dumps; write it back with the same indent as a best effort
open(R + 'content/foes.json', 'w', encoding='utf-8').write(json.dumps(d, indent=1, ensure_ascii=False) + '\n')

# ---- modules (section 5)
M = {
 'ablative_plating': ({'hull': 8, 'armour': 1, 'move': -10}, None), 'ram_frame': ({'hull': 24}, None),
 'spall_liner': ({'move': -10, 'heat': -4}, [2]), 'boundary_layer_bleed': ({'cooling': 1}, [1]), 'muzzle_velocity_booster': ({}, [1]),
 'thrust_overboost': ({'move': 20, 'shield': 12}, [2]), 'flak_skirt': ({'hull': 6}, None), 'field_radiators': ({'heat': 4, 'cooling': 1}, None),
 'tactical_databank': ({}, [1]), 'artillery_rangefinder': ({}, None), 'phase_conjugator': ({'shield': 4}, ['stacks', 1]),
 'susceptibility_tensor': ({'shield': 4}, [1]), 'exotic_matter_shell': ({'shield': 16, 'heat': 6}, [2]), 'ward_plate': ({'shield': 8, 'armour': 1}, None),
 'grievance_reliquary': ({'hull': 4}, None), 'tithe_coupling': ({'hull': 20, 'shield': 12}, [3]),
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
edit(R + 'sim/skirmish.gd', [
 ('const CRYO_COOL_PER_STACK := 10', 'const CRYO_COOL_PER_STACK := 2'),
 ('const CORRUPT_BITE_PER_STACK := 10', 'const CORRUPT_BITE_PER_STACK := 3'),
 ('const VOLATILE_BITE := 10', 'const VOLATILE_BITE := 3'),
 ('const HOT_HEAT := 20', 'const HOT_HEAT := 5'),
])
edit(R + 'sim/face.gd', [('const MISSING_STEP := 20', 'const MISSING_STEP := 5')])
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
open(R + 'sim/effects.gd', 'w', encoding='utf-8').write(s)
edit(R + 'sim/policy.gd', [('const KILL_BONUS := 10.0', 'const KILL_BONUS := 3.0'), ('const DEATH_WEIGHT := 60.0', 'const DEATH_WEIGHT := 20.0')])
print('fills applied')
