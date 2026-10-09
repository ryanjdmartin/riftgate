"""The deaths and the shield break again (Ryan, 9 October, on the phone in the game).

His notes, each a rule for these:
  - A foe falls about ten times a fight, and its death had been the machine's: near three
    seconds and three blasts, far too long for it, and it buried Jenny's line. A foe's death
    is short, under a second, its family's own: the Risen's grave-light snuffed and bone
    falling, the Horde's slag bursting and its fire guttering out, the Chorus's word cut dead.
    A plain short blast stands beside them, one death for every family.
  - A machine lost could not be heard under its death, since Jenny says it every time. The
    death sounded like pipes falling off a shelf: the maker's plate falling in pieces, tinkly.
    Explosions are fine; a powering down, maybe. So the death is the blasts and the hull
    hitting the ground in its first half second, then the machine powering down under her
    line, quiet and low, so the two interleave. Two power-downs: the reactor's hum dying through
    a closing filter as its relays drop out one by one, nothing gliding (the Pac-Man ruling);
    and the classic whine falling in pitch, which breaks the ruling, offered to be judged.
  - The shield break was tinkly the same way (shards scattering): an electric explosion, a
    discharge, the field arcing and cut dead, no shards.

Everything here goes through the forge's master stage, so it plays at the game's level, and
the page sets it beside what the game plays now.

    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py     # into out/fx, after the others
    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py 2   # the second cut
    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py 3   # the third
    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py 4   # the fourth
    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py 5   # the fifth
    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py 6   # the sixth
    tools/spriter/.venv/bin/python tools/soundforge/death_sketches.py 7   # the seventh
"""
import json
import math
import os
import subprocess
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as FX  # noqa: E402

SR = F.SR
n_of, t_of, mix, at, room = F.n_of, F.t_of, F.mix, F.at, F.room
E1, E2, B2, E3 = FX.E1, FX.E2, FX.B2, FX.E3
PREFIX = "d1_"
OUT = FX.OUT
ART = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "art", "audio")


# ---------------------------------------------------------------- a foe's death

def foe_blast():
    """One death for every family: a short blast, its boom cut short."""
    b = mix(F.explosion(0.5, 40.0, 0.9, debris=1), FX.boom_tail(0.4, 0.5))
    return room(FX.heft(b, 0.5), decay=0.15, mix=0.12)


def foe_undead():
    """The Risen: the grave-light snuffed (a stutter and gone), the bone giving, a short
    rattle falling, a dull thud."""
    n = n_of(0.12)
    light = FX.cold_hum(0.12, 0.45) * FX.gate(np.ones(n), 40.0, 0.5) * F.env_pts(n, [(0.0, 1.0), (0.1, 0.8), (0.12, 0.0)])
    b = at(light, mix(FX.bone_crack(1.0), F.thud(130.0, 45.0, 0.25, click=0.6, drive=3.0, body_gain=1.2)), 0.1)
    b = at(b, F.ratchet(5, 0.22, 1500.0, 0.45, jitter=0.35), 0.16)
    b = at(b, FX.boom_tail(0.3, 0.35), 0.12)
    return room(FX.heft(b, 0.4), decay=0.15, mix=0.12)


def foe_demonic():
    """The Horde: the slag bursting (a whoomp and a short blast) and the fire guttering out,
    its roar closing down fast, embers."""
    n = n_of(0.45)
    t = t_of(n)
    gutter = F.lp_var(F.sat(F.lp(F.noise(n), 300.0) * 3.0, 3.0), 1200.0 - 1050.0 * (t / 0.45) ** 0.6) * F.env_pts(n, [(0.0, 0.0), (0.02, 0.8), (0.45, 0.0)]) * 0.6
    b = mix(FX.whoomp(0.3, 500.0, 1.0), F.explosion(0.45, 34.0, 0.8, debris=0), at(np.zeros(1), gutter, 0.05))
    b = at(b, FX.embers(0.4, 0.5), 0.08)
    return room(FX.heft(b, 0.5), decay=0.15, mix=0.12)


def foe_eldritch():
    """The Chorus: its word cut dead mid-syllable (the cluster gated fast, then nothing), a
    crushed thud, the feed dropping it: two ticks."""
    n = n_of(0.16)
    word = FX.gate(FX.chorus_cluster(0.16, 0.8), 36.0, 0.45) * F.env_pts(n, [(0.0, 0.0), (0.01, 1.0), (0.15, 0.9), (0.16, 0.0)])
    b = at(word, F.crush(F.thud(150.0, 45.0, 0.26, click=1.0, drive=3.5, body_gain=1.1), bits=6, hold=3), 0.16)
    b = at(b, F.glitch_perc() * 0.6, 0.24)
    b = at(b, F.glitch_perc() * 0.45, 0.31)
    return room(b, decay=0.12, mix=0.1)


# ---------------------------------------------------------------- a machine's death

def reactor_hum(n, gain=1.0):
    """The machine running: E1 with E2, B2 and E3 over it, saturated, as layers a relay can
    drop one by one."""
    return [F.harmonics(E1, n, [1.0, 0.7, 0.5]) * gain, F.harmonics(E2, n, [0.6, 0.4]) * gain,
            F.harmonics(B2, n, [0.45, 0.3]) * gain, F.harmonics(E3, n, [0.35, 0.2]) * gain]


def power_down_relays(dur=1.7, gain=0.55):
    """No glide: the hum's layers drop out with a relay's clack each, top first, the filter
    closing over what is left, the loudness falling."""
    n = n_of(dur)
    t = t_of(n)
    layers = reactor_hum(n)
    drops = [0.35, 0.7, 1.05]   # E3, then B2, then E2 go; E1 runs down to nothing
    out = np.zeros(n)
    for k, layer in enumerate(layers):
        g = np.ones(n)
        if k > 0:
            when = drops[len(layers) - 1 - k]
            g[n_of(when):] = 0.0
            r = n_of(0.01)
            g[n_of(when) - r:n_of(when)] = np.linspace(1.0, 0.0, r)
        out += layer * g
    out = F.lp_var(F.sat(out, 2.0), 2400.0 * (1.0 - 0.95 * (t / dur) ** 0.7) + 90.0)
    out = out * F.env_pts(n, [(0.0, 0.0), (0.03, 1.0), (0.4, 0.8), (dur * 0.8, 0.3), (dur, 0.0)]) * gain
    for when in drops:
        out = at(out, F.knock([380.0, 610.0], [0.04, 0.025], [1.0, 0.4], noise_gain=0.25) * 0.5, when)
    return out


def power_down_whine(dur=1.7, gain=0.5):
    """The classic, against the Pac-Man ruling: a whine falling from A5 to A2 as the hum
    runs down."""
    n = n_of(dur)
    t = t_of(n)
    f = 880.0 * (110.0 / 880.0) ** ((t / dur) ** 0.8)
    ph = 2.0 * math.pi * np.cumsum(f) / SR
    whine = (np.sin(ph) + 0.35 * np.sin(2.0 * ph) + 0.15 * np.sin(3.0 * ph)) * F.env_pts(n, [(0.0, 0.0), (0.04, 0.6), (0.3, 0.5), (dur, 0.0)]) * 0.35
    hum = sum(reactor_hum(n, 0.6))
    hum = F.lp(F.sat(hum, 2.0), 1200.0) * F.env_pts(n, [(0.0, 0.0), (0.03, 1.0), (dur * 0.7, 0.3), (dur, 0.0)]) * 0.5
    return mix(whine, hum) * gain


def machine_death(maker, power_down="relays"):
    """The blasts and the hull hitting the ground in the first half second, one knock of the
    maker's plate for whose machine it was (no falling pieces), then the power-down, low and
    quiet, under Jenny's line."""
    b = FX.big_blast(1.0, 24.0, 1.1, debris=2)
    b = at(b, FX.plate(maker, 0.8), 0.02)
    b = at(b, FX.big_blast(0.7, 30.0, 0.7, debris=1), 0.18)
    ground = mix(F.thud(110.0, 32.0, 0.6, click=1.0, drive=3.5, body_gain=1.7), FX.boom_tail(0.6, 0.5))
    b = at(b, FX.heft(ground, 0.6), 0.32)
    pd = power_down_relays() if power_down == "relays" else power_down_whine()
    b = at(b, pd, 0.25)
    return room(b, decay=0.25, mix=0.1)


# ---------------------------------------------------------------- the shield breaking

def arc(dur, gain=1.0, rate=(25.0, 70.0)):
    """The field arcing: a bright band of noise switched on and off at random, fast."""
    n = n_of(dur)
    g = np.zeros(n)
    i = 0
    while i < n:
        on = n_of(F.RNG.uniform(0.004, 0.018))
        off = n_of(1.0 / F.RNG.uniform(*rate)) - on
        g[i:i + on] = 1.0
        i += on + max(off, n_of(0.003))
    g = np.convolve(g, np.ones(n_of(0.002)) / n_of(0.002), mode="same")
    return F.bp(F.noise(n), 600.0, 3800.0) * g * F.env_pts(n, [(0.0, 1.0), (dur * 0.6, 0.7), (dur, 0.0)]) * gain   # held under the piercing band (the rule: 2 to 8 kHz ten under the body)


def shield_discharge(big=False):
    """An electric explosion: the crack, the field arcing as it fails, its hum flaring and cut
    dead, the discharge as a blast with a boom, the ground taking it. No shards."""
    crack = mix(F.burst(0.05, 2000.0, 14000.0, decay=0.008) * 1.1, F.body(900.0, 220.0, 0.06, click=1.0, drive=3.0) * 0.7)
    b = at(crack, arc(0.4 if big else 0.25, 0.8), 0.01)
    n = n_of(0.3)
    hum = FX.field_hum(n, 0.8) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.2), (0.28, 1.0), (0.3, 0.0)])
    b = at(b, hum, 0.0)
    b = at(b, mix(F.explosion(0.7 if big else 0.55, 36.0, 0.85 if big else 0.75, debris=0), FX.boom_tail(0.6, 0.55)), 0.26 if big else 0.18)
    if big:
        b = at(b, arc(0.12, 0.6, (40.0, 90.0)), 0.52)
    b = at(b, F.thud(120.0, 40.0, 0.4, click=0.4, drive=2.5, body_gain=1.3) * 0.8, 0.2)
    return room(FX.heft(b, 0.5), decay=0.2, mix=0.12)


# ---------------------------------------------------------------- the second cut (Ryan, 9 October)
# His picks from the first: one short blast for every foe (the families later). The knocks
# made the machine's death a xylophone rather than chunks hitting, so no knock anywhere (the
# maker's plate, the relays, the explosion's debris pieces): the whine is the power-down (its
# noise "is not Pac-Man at all"), and the maker's flair goes in the explosion itself. The
# bigger discharge for the shield, shorter, its boom cut well down, the arc and fizzle leading.

def blast(dur=1.0, low=24.0, gain=1.0, cut=None):
    """An explosion with no debris pieces (their knocks rang), its boom behind it; `cut`
    low-passes the lot."""
    b = mix(F.explosion(dur, low, gain, debris=0), FX.boom_tail(dur * 0.7, 0.6 * gain))
    if cut:
        b = F.lp(np.concatenate([b, np.zeros(n_of(0.5))]), cut, order=3)[:len(b)]   # padded: see FX.heft
    return FX.heft(b, 0.6)


def grit(dur, gain=1.0, lo=150.0, hi=1800.0, density=0.93):
    """Chunks: sparse bursts of low, untuned noise, the sound of pieces hitting, not ringing."""
    n = n_of(dur)
    hits = (F.RNG.uniform(0.0, 1.0, n) > density).astype(float)
    hits = np.convolve(hits, np.exp(-np.arange(n_of(0.012)) / n_of(0.003)), mode="full")[:n]
    return F.lp(F.bp(F.noise(n), lo, hi) * hits, hi * 0.7, order=3) * F.env_ad(n, 0.005, dur * 0.4) * gain


def fizzle(dur, gain=0.5, lo=900.0, hi=3800.0, density=0.985):
    """Electric crackle thinning out: sparse bright bursts, fewer and fainter."""
    n = n_of(dur)
    t = t_of(n)
    dens = density + (1.0 - density) * 0.8 * (t / dur)
    return F.bp(F.noise(n), lo, hi) * (F.RNG.uniform(0.0, 1.0, n) > dens) * F.env_pts(n, [(0.0, 1.0), (dur, 0.0)]) * gain


def death2(maker):
    """A machine's death, second cut: the maker's explosion, the hull's weight, the whine
    powering down under Jenny's line."""
    if maker == "minerva":
        # Deep, as if inside an armoured hull: the blast muffled by the plate around it, a
        # heavy box resonance, the hull taking it whole.
        b = blast(1.1, 22.0, 1.2, cut=520.0)
        n = n_of(0.5)
        box = F.lp(F.sat(F.bp(F.noise(n), 70.0, 180.0) * 4.0, 3.0), 400.0) * F.env_ad(n, 0.004, 0.18) * 0.9
        b = at(b, box, 0.0)
        b = at(b, FX.heft(F.thud(95.0, 28.0, 0.7, click=0.6, drive=4.0, body_gain=2.0), 0.6), 0.04)
        b = at(b, blast(0.8, 26.0, 0.7, cut=450.0), 0.22)
        b = at(b, power_down_whine(1.7, 0.5), 0.3)
    elif maker == "wainwright_sutler":
        # Winds down: a gritty blast, then the works running down, the clatter of its gears
        # slowing (a rate falling, never a pitch) under the whine, a breath of steam.
        b = blast(0.9, 26.0, 1.0)
        b = at(b, grit(0.4, 0.6), 0.05)
        dur = 1.9
        when = 0.25
        k = 0
        while when < 0.25 + dur:
            gap = 0.05 + 0.22 * ((when - 0.25) / dur) ** 1.4
            b = at(b, F.lp(F.burst(0.03, 150.0, 1600.0, decay=0.008), 1100.0, order=3) * 0.55 * (1.0 - 0.6 * (when - 0.25) / dur), when)
            when += gap
            k += 1
        b = at(b, power_down_whine(2.2, 0.55), 0.25)
        steam = F.bp(F.noise(n_of(0.8)), 1000.0, 2600.0) * F.env_pts(n_of(0.8), [(0.0, 0.0), (0.1, 1.0), (0.8, 0.0)]) * 0.07
        b = at(b, steam, 0.6)
    elif maker == "kestrel":
        # Hits the ground: a sharp blast in the air, then the airframe striking the ground,
        # the crunch and the skid of it, chunks.
        b = blast(0.6, 32.0, 0.9)
        ground = mix(F.thud(120.0, 30.0, 0.7, click=1.4, drive=4.0, body_gain=2.0), F.burst(0.12, 120.0, 1600.0, decay=0.04) * 0.9, FX.boom_tail(0.7, 0.6))
        b = at(b, FX.heft(ground, 0.7), 0.38)
        n = n_of(0.45)
        skid = F.lp_var(F.bp(F.noise(n), 150.0, 1800.0), 1600.0 - 1400.0 * t_of(n) / 0.45) * F.env_pts(n, [(0.0, 0.8), (0.45, 0.0)]) * 0.45
        b = at(b, skid, 0.42)
        b = at(b, grit(0.5, 0.7), 0.4)
        b = at(b, power_down_whine(1.4, 0.4), 0.5)
    elif maker == "aphelion":
        # Beeps and fizzles out: a clean ceramic blast, its systems' warning beeping (three,
        # spreading out, each fainter), then the electrics crackling down to nothing.
        b = blast(0.7, 34.0, 0.85)
        for k, when in enumerate((0.3, 0.52, 0.82)):
            n = n_of(0.07)
            beep = F.lp(np.sign(np.sin(2.0 * math.pi * 987.77 * t_of(n))) * 0.5 + np.sin(2.0 * math.pi * 987.77 * t_of(n)) * 0.5, 3000.0)
            b = at(b, beep * F.env_pts(n, [(0.0, 0.0), (0.004, 1.0), (0.06, 1.0), (0.07, 0.0)]) * 0.22 * (1.0 - 0.3 * k), when)
        b = at(b, fizzle(1.4, 0.55), 0.2)
        b = at(b, power_down_whine(1.5, 0.3), 0.3)
    else:
        # The Arsenal: plasma flames, the whoomp and the fire burning on, and under it, faint,
        # something leaving: breath through a vowel, swelling and gone.
        b = mix(blast(0.8, 28.0, 0.9), FX.plasma_splash(1.0))
        n = n_of(1.3)
        flames = F.lp(F.sat(F.lp(F.noise(n), 320.0) * 3.0, 3.0), 1100.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 0.9), (0.6, 0.6), (1.3, 0.0)]) * 0.55
        b = at(b, flames, 0.05)
        n = n_of(1.2)
        souls = F.choir([0, 3, 7], n, gain=0.18, vowel="oo", octave=2)[:n]
        breath = F.bp(F.noise(n), 600.0, 2400.0) * 0.12
        souls = F.lp(mix(souls, breath), 2600.0) * F.env_pts(n, [(0.0, 0.0), (0.45, 1.0), (0.8, 0.6), (1.2, 0.0)])
        b = at(b, souls, 0.35)
        b = at(b, power_down_whine(1.5, 0.35), 0.3)
    return room(b, decay=0.25, mix=0.1)


def shield_discharge2():
    """The bigger discharge, shorter and its boom cut well down: the crack, the field arcing
    as it fails, its hum flaring and cut dead, a second arc's pop, the fizzle after, a small
    thump under it."""
    crack = mix(F.burst(0.05, 2000.0, 14000.0, decay=0.008) * 1.1, F.body(900.0, 220.0, 0.06, click=1.0, drive=3.0) * 0.7)
    b = at(crack, F.lp(arc(0.3, 0.7), 2600.0, order=2), 0.01)
    n = n_of(0.26)
    hum = FX.field_hum(n, 0.8) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.2), (0.24, 1.0), (0.26, 0.0)])
    b = at(b, hum, 0.0)
    b = at(b, mix(F.explosion(0.35, 40.0, 0.3, debris=0), FX.boom_tail(0.3, 0.15)), 0.2)
    b = at(b, F.lp(arc(0.1, 0.55, (40.0, 90.0)), 2600.0, order=2), 0.36)
    b = at(b, fizzle(0.5, 0.4, 600.0, 2400.0), 0.42)
    b = at(b, F.thud(130.0, 45.0, 0.3, click=0.4, drive=2.5, body_gain=1.3) * 0.9, 0.2)
    return room(FX.heft(b, 0.4), decay=0.15, mix=0.1)


# ---------------------------------------------------------------- the third cut (Ryan, 9 October)
# The whine read as Pac-Man after all: gone from every maker but Aphelion. Minerva two booms;
# Wainwright & Sutler's wind-down louder, three much smaller explosions over the clockwork;
# Kestrel the other way round, the hit and then the blast; Aphelion the StarCraft Science
# Vessel, electricity discharging with its warnings and a boom after; the Arsenal's occult
# played right up, a ghostly cry as it ignites. Each death has its own gap for Jenny's
# "machine lost" (VOICE_AT), so she interleaves with it rather than over a blast.

VOICE_AT = {"minerva": 0.95, "wainwright_sutler": 0.45, "kestrel": 0.95, "aphelion": 0.3, "arsenal": 1.05}


def hull_boom(gain=1.0, low=22.0):
    """Minerva's: a blast inside the hull, the plate around it muffling it, a box resonance,
    the hull taking it whole."""
    b = blast(1.0, low, 1.2 * gain, cut=520.0)
    n = n_of(0.5)
    box = F.lp(F.sat(F.bp(F.noise(n), 70.0, 180.0) * 4.0, 3.0), 400.0) * F.env_ad(n, 0.004, 0.18) * 0.9 * gain
    b = at(b, box, 0.0)
    return at(b, FX.heft(F.thud(95.0, 28.0, 0.7, click=0.6, drive=4.0, body_gain=2.0), 0.6) * gain, 0.04)


def wail(dur=1.0, f0=250.0, gain=1.0):
    """A ghostly cry, an "aargh": a voice's harmonics on a cry's contour (a lift, then falling
    away), through the "a" vowel's formants, with breath, a rasp at the front and a voice an
    octave under it; spread and washed so it reads as something leaving, not someone."""
    n = n_of(dur)
    t = t_of(n)
    contour = np.interp(t, [0.0, 0.12, dur * 0.45, dur], [f0 * 0.9, f0 * 1.25, f0, f0 * 0.62])
    contour = contour * (1.0 + 0.012 * np.sin(2.0 * math.pi * 5.5 * t))
    out = np.zeros(n)
    for detune, octave, g in ((1.0, 1.0, 1.0), (1.007, 1.0, 0.7), (0.994, 0.5, 0.6)):
        ph = 2.0 * math.pi * np.cumsum(contour * detune * octave) / SR
        v = np.zeros(n)
        for k in range(1, 18):
            v += np.sin(k * ph) / k
        out += v * g
    rasp = 1.0 - 0.45 * (0.5 + 0.5 * np.sign(np.sin(2.0 * math.pi * 68.0 * t))) * np.clip(1.0 - t / 0.35, 0.0, 1.0)
    out = out * rasp + F.lp(F.noise(n), 2000.0) * 0.25
    vowel = mix(F.bp(out, 650.0, 950.0) * 1.0, F.bp(out, 1050.0, 1400.0) * 0.7, F.bp(out, 2300.0, 2800.0) * 0.12)
    vowel = F.sat(vowel * 2.0, 1.8)
    vowel = vowel * F.env_pts(n, [(0.0, 0.0), (0.05, 1.0), (dur * 0.5, 0.75), (dur, 0.0)])
    return room(FX.chorus(vowel, depth=0.004, rate=0.6, voices=3, wet=0.7), decay=0.6, mix=0.35) * gain


def electric_buzz(dur, gain=0.5):
    """A machine's electrics shorting: a mains-like buzz, stuttering."""
    n = n_of(dur)
    t = t_of(n)
    buzz = F.lp(F.sat(F.harmonics(120.0, n, [1.0, 0.6, 0.5, 0.4, 0.3, 0.2]), 3.0), 2200.0)
    stutter = (F.RNG.uniform(0.0, 1.0, n // n_of(0.02) + 1) > 0.35).repeat(n_of(0.02))[:n].astype(float)
    stutter = np.convolve(stutter, np.ones(n_of(0.003)) / n_of(0.003), mode="same")
    return buzz * stutter * F.env_pts(n, [(0.0, 0.0), (0.03, 1.0), (dur * 0.7, 0.8), (dur, 0.0)]) * gain


def death3(maker):
    """A machine's death, third cut."""
    if maker == "minerva":
        # Two booms inside the hull, the second deeper; the hull settling.
        b = hull_boom(1.0, 24.0)
        b = at(b, hull_boom(1.1, 20.0), 0.42)
        n = n_of(1.2)
        settle = F.lp(F.noise(n), 140.0) * F.env_pts(n, [(0.0, 0.0), (0.1, 1.0), (1.2, 0.0)]) * 0.5
        b = at(b, F.sat(settle * 2.0, 2.0), 0.6)
    elif maker == "wainwright_sutler":
        # A blast, then the works running down out loud: the clockwork clattering slower and
        # slower (a rate falling, never a pitch), three small explosions going off over it,
        # a breath of steam.
        b = blast(0.9, 26.0, 1.0)
        b = at(b, grit(0.4, 0.6), 0.05)
        dur = 2.0
        when = 0.25
        while when < 0.25 + dur:
            frac = (when - 0.25) / dur
            tick = mix(F.lp(F.burst(0.035, 150.0, 1600.0, decay=0.01), 1100.0, order=3), F.thud(260.0, 120.0, 0.04, click=0.6, drive=2.0) * 0.5)
            b = at(b, tick * 1.1 * (1.0 - 0.5 * frac), when)
            when += 0.055 + 0.25 * frac ** 1.4
        for when in (0.7, 1.15, 1.7):
            b = at(b, blast(0.35, 48.0, 0.35), when)
        steam = F.bp(F.noise(n_of(0.8)), 1000.0, 2600.0) * F.env_pts(n_of(0.8), [(0.0, 0.0), (0.1, 1.0), (0.8, 0.0)]) * 0.07
        b = at(b, steam, 0.9)
    elif maker == "kestrel":
        # The airframe strikes the ground first, its crunch and skid, then it goes up.
        ground = mix(F.thud(120.0, 30.0, 0.7, click=1.4, drive=4.0, body_gain=2.0), F.burst(0.12, 120.0, 1600.0, decay=0.04) * 0.9, FX.boom_tail(0.5, 0.5))
        b = FX.heft(ground, 0.7)
        n = n_of(0.4)
        skid = F.lp_var(F.bp(F.noise(n), 150.0, 1800.0), 1600.0 - 1400.0 * t_of(n) / 0.4) * F.env_pts(n, [(0.0, 0.8), (0.4, 0.0)]) * 0.45
        b = at(b, skid, 0.04)
        b = at(b, grit(0.4, 0.7), 0.03)
        b = at(b, blast(0.9, 26.0, 1.1), 0.42)
    elif maker == "aphelion":
        # The Science Vessel: the electrics discharging, arcing and shorting, its warning
        # going under it, the whine running down, and a boom to end it.
        b = mix(F.lp(arc(1.4, 0.7), 2200.0, order=2), electric_buzz(1.4, 0.5))
        b = at(b, fizzle(1.5, 0.45, 600.0, 2400.0), 0.1)
        for k in range(6):
            n = n_of(0.08)
            f = 987.77 if k % 2 == 0 else 880.0
            beep = F.lp(np.sign(np.sin(2.0 * math.pi * f * t_of(n))) * 0.5 + np.sin(2.0 * math.pi * f * t_of(n)) * 0.5, 3000.0)
            b = at(b, beep * F.env_pts(n, [(0.0, 0.0), (0.004, 1.0), (0.07, 1.0), (0.08, 0.0)]) * 0.2, 0.05 + 0.2 * k)
        b = at(b, power_down_whine(1.5, 0.3), 0.15)
        b = at(b, blast(0.9, 28.0, 1.1), 1.6)
    else:
        # The Arsenal: as it ignites, a ghostly cry leaving it, loud and plain; the plasma
        # flames burning on; something else going under them.
        b = mix(blast(0.8, 28.0, 0.9), FX.plasma_splash(1.0))
        b = at(b, wail(1.1, 240.0, 1.4), 0.04)
        n = n_of(1.3)
        flames = F.lp(F.sat(F.lp(F.noise(n), 320.0) * 3.0, 3.0), 1100.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 0.9), (0.6, 0.6), (1.3, 0.0)]) * 0.55
        b = at(b, flames, 0.05)
        n = n_of(1.2)
        souls = F.choir([0, 3, 7], n, gain=0.18, vowel="oo", octave=2)[:n]
        souls = F.lp(mix(souls, F.bp(F.noise(n), 600.0, 2400.0) * 0.12), 2600.0) * F.env_pts(n, [(0.0, 0.0), (0.45, 1.0), (0.8, 0.6), (1.2, 0.0)])
        b = at(b, souls, 0.6)
    return room(b, decay=0.25, mix=0.1)


# ---------------------------------------------------------------- the fourth cut (Ryan, 9 October)
# The pops long after were the forge's filters wrapping a blast's front round to the end of its
# buffer (FX.heft now pads; nine shipped effects carried it too). Wainwright & Sutler's third
# cut is right and lands. Minerva's second boom much deeper. Kestrel: something before the
# impact, the impact an ignition, no second boom. Aphelion: three beeps on one pitch, small
# explosions blended into the end of the discharge rather than a pause for one boom. The
# Arsenal: the cry far quieter, the ignition a whoosh, plasma crackles fizzling out after.

VOICE_AT4 = {"minerva": 1.05, "kestrel": 1.1, "aphelion": 0.2, "arsenal": 1.1}


def deep_hull_boom(gain=1.0):
    """Minerva's second: the reactor going inside the hull, much deeper: a lower, longer blast
    with the plate around it, a box resonance an octave down, a sub rumble under it."""
    b = blast(1.4, 15.0, 1.3 * gain, cut=320.0)
    n = n_of(0.8)
    box = F.lp(F.sat(F.bp(F.noise(n), 35.0, 95.0) * 5.0, 3.0), 250.0) * F.env_ad(n, 0.006, 0.3) * 1.1 * gain
    b = at(b, box, 0.0)
    rumble = F.lp(F.noise(n_of(1.4)), 60.0) * F.env_pts(n_of(1.4), [(0.0, 0.0), (0.05, 1.0), (1.4, 0.0)]) * 1.4 * gain
    b = at(b, F.sat(rumble * 2.5, 2.5), 0.02)
    return at(b, FX.heft(F.thud(70.0, 20.0, 0.9, click=0.4, drive=4.5, body_gain=2.4), 0.6) * gain, 0.05)


def whoosh(dur=0.35, gain=1.0, lo=300.0, hi=3200.0):
    """Air rushing in: noise whose band opens and whose loudness grows (a filter moving,
    never a pitch)."""
    n = n_of(dur)
    t = t_of(n)
    w = F.lp_var(F.hp(F.noise(n), 150.0), lo + (hi - lo) * (t / dur) ** 1.6)
    return w * F.env_pts(n, [(0.0, 0.0), (dur * 0.8, 1.0), (dur, 0.6)]) * gain


def ignition(gain=1.0):
    """Fuel catching: a whoomp with a fire burst on it, the roar after."""
    n = n_of(0.6)
    roar = F.lp(F.sat(F.lp(F.noise(n), 320.0) * 3.0, 3.0), 1100.0) * F.env_pts(n, [(0.0, 0.0), (0.03, 1.0), (0.6, 0.0)]) * 0.7
    b = mix(FX.whoomp(0.4, 520.0, 1.3), F.burst(0.15, 200.0, 2500.0, decay=0.05) * 0.7, roar)
    return FX.heft(b, 0.5) * gain


def crackles(dur=1.3, gain=0.5):
    """Plasma crackling after a fire: hot bright pops, thinning out and fizzling to nothing."""
    n = n_of(dur)
    t = t_of(n)
    dens = 0.975 + 0.024 * (t / dur) ** 0.8
    pops = F.bp(F.noise(n), 700.0, 2600.0) * (F.RNG.uniform(0.0, 1.0, n) > dens)
    hiss = F.bp(F.noise(n), 900.0, 2400.0) * 0.08
    return (pops + hiss) * F.env_pts(n, [(0.0, 1.0), (dur * 0.5, 0.5), (dur, 0.0)]) * gain


def death4(maker):
    """A machine's death, fourth cut (Minerva, Kestrel, Aphelion, the Arsenal)."""
    if maker == "minerva":
        b = hull_boom(1.0, 24.0)
        b = at(b, deep_hull_boom(1.1), 0.45)
    elif maker == "kestrel":
        # Falling: its engine sputtering out, cutting in and out, the air rushing up at it;
        # then it strikes the ground and its fuel catches, the crunch in the ignition, chunks,
        # the fire burning down. No second boom.
        n = n_of(0.55)
        t = t_of(n)
        engine = F.lp(F.sat(F.harmonics(55.0, n, [1.0, 0.7, 0.5, 0.35, 0.25]) + F.lp(F.noise(n), 600.0) * 0.4, 2.5), 1400.0)
        cut = (F.RNG.uniform(0.0, 1.0, n // n_of(0.04) + 1) > (0.25 + 0.6 * np.linspace(0.0, 1.0, n // n_of(0.04) + 1))).repeat(n_of(0.04))[:n].astype(float)
        cut = np.convolve(cut, np.ones(n_of(0.004)) / n_of(0.004), mode="same")
        b = engine * cut * F.env_pts(n, [(0.0, 0.0), (0.03, 0.7), (0.55, 0.4)]) * 0.6
        b = mix(b, whoosh(0.55, 0.45))
        hit = 0.55
        ground = mix(F.thud(120.0, 30.0, 0.7, click=1.4, drive=4.0, body_gain=2.0), F.burst(0.12, 120.0, 1600.0, decay=0.04) * 0.9)
        b = at(b, FX.heft(ground, 0.7), hit)
        b = at(b, ignition(1.1), hit + 0.02)
        b = at(b, grit(0.5, 0.7), hit + 0.03)
        b = at(b, crackles(0.9, 0.3), hit + 0.4)
    elif maker == "aphelion":
        # The Science Vessel: the electrics discharging, arcing and shorting, its warning three
        # beeps on one pitch, the whine running down, small blasts going off into the end of
        # the discharge, no pause.
        b = mix(F.lp(arc(1.7, 0.7), 2200.0, order=2), electric_buzz(1.7, 0.5))
        b = at(b, fizzle(1.8, 0.45, 600.0, 2400.0), 0.1)
        for k in range(3):
            n = n_of(0.09)
            beep = F.lp(np.sign(np.sin(2.0 * math.pi * 987.77 * t_of(n))) * 0.5 + np.sin(2.0 * math.pi * 987.77 * t_of(n)) * 0.5, 3000.0)
            b = at(b, beep * F.env_pts(n, [(0.0, 0.0), (0.004, 1.0), (0.08, 1.0), (0.09, 0.0)]) * 0.22, 0.05 + 0.22 * k)
        b = at(b, power_down_whine(1.6, 0.3), 0.15)
        for k, when in enumerate((1.25, 1.42, 1.6, 1.75)):
            b = at(b, blast(0.4, 44.0, 0.45 + 0.08 * k), when)
    else:
        # The Arsenal: the plasma rushing in and catching, the cry leaving it under the fire
        # (far quieter now), the flames, then plasma crackles fizzling out.
        b = whoosh(0.32, 0.8, 250.0, 2600.0)
        ign = 0.3
        b = at(b, mix(blast(0.7, 30.0, 0.8), FX.plasma_splash(0.9), ignition(1.0)), ign)
        b = at(b, wail(1.0, 240.0, 0.45), ign + 0.02)
        n = n_of(1.0)
        flames = F.lp(F.sat(F.lp(F.noise(n), 320.0) * 3.0, 3.0), 1100.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 0.9), (0.5, 0.5), (1.0, 0.0)]) * 0.5
        b = at(b, flames, ign + 0.05)
        b = at(b, crackles(1.4, 0.55), ign + 0.45)
    return room(b, decay=0.25, mix=0.1)


# ---------------------------------------------------------------- the fifth cut (Ryan, 9 October)
# Minerva: a lower-pitched first blast, the second boom a little later (read two ways: the
# death's first boom lowered, or the second boom's own front lowered; both rendered). Kestrel:
# no sputter, the whoosh softer and longer, the crackling after louder and longer. Aphelion:
# the beeps quieter, the blasts sooner, each a different pitch and unevenly spaced. The
# Arsenal: the whoosh is Kestrel's now, so a fiery roar into the ignition; the cry lower still
# and longer, crackles and sputters over it.

VOICE_AT5 = {"minerva_first_low": 1.25, "minerva_second_low": 1.25, "kestrel": 1.4, "aphelion": 0.2, "arsenal": 1.3}


def hull_boom_low(gain=1.0):
    """Minerva's first boom, lower: the muffling plate closed further, the box and the thud a
    step down."""
    b = blast(1.0, 19.0, 1.2 * gain, cut=340.0)
    n = n_of(0.5)
    box = F.lp(F.sat(F.bp(F.noise(n), 50.0, 130.0) * 4.0, 3.0), 300.0) * F.env_ad(n, 0.004, 0.2) * 0.9 * gain
    b = at(b, box, 0.0)
    return at(b, FX.heft(F.thud(80.0, 24.0, 0.75, click=0.5, drive=4.0, body_gain=2.1), 0.6) * gain, 0.04)


def deep_hull_boom_low_front(gain=1.0):
    """Minerva's second boom with its own front lowered: no crack at its head, the blast's
    burst cut to the low band, so it arrives as weight and not as a hit."""
    b = blast(1.4, 14.0, 1.25 * gain, cut=200.0)
    n = n_of(0.8)
    box = F.lp(F.sat(F.bp(F.noise(n), 30.0, 85.0) * 5.0, 3.0), 220.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.8, 0.0)]) * 1.1 * gain
    b = at(b, box, 0.0)
    rumble = F.lp(F.noise(n_of(1.5)), 55.0) * F.env_pts(n_of(1.5), [(0.0, 0.0), (0.06, 1.0), (1.5, 0.0)]) * 1.5 * gain
    b = at(b, F.sat(rumble * 2.5, 2.5), 0.0)
    return at(b, FX.heft(F.thud(60.0, 18.0, 1.0, click=0.15, drive=4.5, body_gain=2.6), 0.6) * gain, 0.03)


def flame_sputters(dur, gain=0.5):
    """Fire sputtering: short irregular bursts of low roar, as a flame catches and gutters."""
    n = n_of(dur)
    out = np.zeros(n)
    when = 0.0
    while when < dur - 0.08:
        k = n_of(F.RNG.uniform(0.03, 0.09))
        seg = F.lp(F.sat(F.lp(F.noise(k), 400.0) * 3.0, 3.0), 1300.0) * F.env_pts(k, [(0.0, 0.0), (0.005, 1.0), (k / SR, 0.0)])
        out = at(out, seg * F.RNG.uniform(0.5, 1.0), when)
        when += F.RNG.uniform(0.07, 0.22)
    return out[:n] * F.env_pts(n, [(0.0, 1.0), (dur, 0.2)]) * gain


def death5(variant):
    if variant == "minerva_first_low":
        b = hull_boom_low(1.0)
        b = at(b, deep_hull_boom(1.1), 0.6)
    elif variant == "minerva_second_low":
        b = hull_boom(1.0, 24.0)
        b = at(b, deep_hull_boom_low_front(1.1), 0.6)
    elif variant == "kestrel":
        # The air rushing up at it, softer and longer; it strikes the ground and its fuel
        # catches; the fire crackling after, louder and on for longer.
        b = whoosh(0.85, 0.3, 250.0, 2400.0)
        hit = 0.85
        ground = mix(F.thud(120.0, 30.0, 0.7, click=1.4, drive=4.0, body_gain=2.0), F.burst(0.12, 120.0, 1600.0, decay=0.04) * 0.9)
        b = at(b, FX.heft(ground, 0.7), hit)
        b = at(b, ignition(1.1), hit + 0.02)
        b = at(b, grit(0.5, 0.7), hit + 0.03)
        b = at(b, crackles(1.6, 0.55), hit + 0.3)
    elif variant == "aphelion":
        # The discharge with its warning quieter; small blasts from early in it, each its own
        # pitch, at uneven gaps, rolling into its end.
        b = mix(F.lp(arc(1.7, 0.7), 2200.0, order=2), electric_buzz(1.7, 0.5))
        b = at(b, fizzle(1.8, 0.45, 600.0, 2400.0), 0.1)
        for k in range(3):
            n = n_of(0.09)
            beep = F.lp(np.sign(np.sin(2.0 * math.pi * 987.77 * t_of(n))) * 0.5 + np.sin(2.0 * math.pi * 987.77 * t_of(n)) * 0.5, 3000.0)
            b = at(b, beep * F.env_pts(n, [(0.0, 0.0), (0.004, 1.0), (0.08, 1.0), (0.09, 0.0)]) * 0.11, 0.05 + 0.22 * k)
        b = at(b, power_down_whine(1.6, 0.3), 0.15)
        for when, low, gain in ((0.62, 52.0, 0.4), (0.83, 30.0, 0.55), (1.18, 64.0, 0.4), (1.3, 22.0, 0.65), (1.62, 40.0, 0.5)):
            b = at(b, blast(0.4, low, gain), when)
    else:
        # The Arsenal: fire roaring up into the ignition; the cry lower still and drawn out,
        # crackling and sputtering over it; the flames.
        n = n_of(0.45)
        t = t_of(n)
        roar_up = F.lp_var(F.sat(F.lp(F.noise(n), 260.0) * 3.0, 3.0), 300.0 + 900.0 * (t / 0.45) ** 1.5) * (t / 0.45) ** 1.4 * 0.9
        b = roar_up
        ign = 0.42
        b = at(b, mix(blast(0.7, 30.0, 0.8), FX.plasma_splash(0.9), ignition(1.0)), ign)
        b = at(b, wail(1.8, 230.0, 0.28), ign + 0.02)
        b = at(b, crackles(1.8, 0.5), ign + 0.15)
        b = at(b, flame_sputters(1.6, 0.45), ign + 0.2)
        n = n_of(1.2)
        flames = F.lp(F.sat(F.lp(F.noise(n), 320.0) * 3.0, 3.0), 1100.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 0.9), (0.6, 0.5), (1.2, 0.0)]) * 0.5
        b = at(b, flames, ign + 0.05)
    return room(b, decay=0.25, mix=0.1)


# ---------------------------------------------------------------- the sixth cut (Ryan, 9 October)
# Minerva: every boom so far began on the same explosion front (the forge's thud from 160 Hz,
# its burst to 5 kHz), so lowering what came after it never moved what the ear latches onto.
# So "boom... BOOM" from scratch: each boom its own front, a kick-like thump whose fall starts
# where it is pitched, its noise body low-passed in step, and saturated so a phone (which plays
# almost nothing under 220 Hz) hears the front's harmonics; the second lower, bigger and longer.
# Kestrel: the crash with more of a tail, the crackles after much louder. Aphelion lands. The
# Arsenal: the cry lower still, static and sputtering over the top.

VOICE_AT6 = {"minerva": 1.4, "kestrel": 1.45, "arsenal": 1.3}


def boom(f0, f1, dur, gain=1.0, body_cut=600.0, sub=0.0):
    """A boom built from its front: a thump falling from f0 to f1 over the first tenth of a
    second (its pitch is the front the ear hears), a noise body low-passed at body_cut, the
    whole saturated for the speaker's band, and its air after it."""
    n = n_of(dur)
    t = t_of(n)
    f = f1 + (f0 - f1) * np.exp(-t / 0.035)
    thump = np.sin(2.0 * math.pi * np.cumsum(f) / SR) * F.env_pts(n, [(0.0, 0.0), (0.002, 1.0), (0.12, 0.7), (dur, 0.0)])
    body = F.lp(F.noise(n), body_cut, order=3) * F.env_pts(n, [(0.0, 0.0), (0.003, 1.0), (dur * 0.3, 0.35), (dur, 0.0)]) * 1.2
    b = F.sat((thump * 1.4 + body) * 1.8, 2.6)
    if sub > 0.0:
        rumble = F.lp(F.noise(n), 60.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 1.0), (dur, 0.0)]) * sub
        b = mix(b, F.sat(rumble * 2.5, 2.5))
    b = mix(b, FX.boom_tail(dur * 0.9, 0.5, cut=body_cut * 0.6))
    pad = np.zeros(n_of(0.5))
    b = b + F.bp(np.concatenate([F.sat(b * 1.5, 3.0), pad]), 180.0, 1400.0)[:len(b)] * 0.6   # the speaker's band, as heft, kept below the old front
    return b * gain


def death6(maker):
    if maker == "minerva":
        # boom ... BOOM: the first smaller and pitched higher, the second lower, bigger, longer,
        # with the hull's sub under it.
        b = boom(190.0, 70.0, 0.7, 0.5, body_cut=650.0)
        b = at(b, boom(105.0, 32.0, 1.5, 1.6, body_cut=330.0, sub=1.2), 0.62)
    elif maker == "kestrel":
        b = whoosh(0.85, 0.3, 250.0, 2400.0)
        hit = 0.85
        ground = mix(F.thud(120.0, 30.0, 0.7, click=1.4, drive=4.0, body_gain=2.0), F.burst(0.12, 120.0, 1600.0, decay=0.04) * 0.9, FX.boom_tail(1.4, 0.65))
        b = at(b, FX.heft(ground, 0.7), hit)
        b = at(b, ignition(1.1), hit + 0.02)
        b = at(b, grit(0.9, 0.7), hit + 0.03)
        n = n_of(1.6)
        settle = F.lp(F.noise(n), 400.0) * F.env_pts(n, [(0.0, 0.0), (0.1, 1.0), (1.6, 0.0)]) * 0.35
        b = at(b, F.sat(settle * 2.0, 2.0), hit + 0.2)
        b = at(b, crackles(2.4, 1.1), hit + 0.25)
    else:
        n = n_of(0.45)
        t = t_of(n)
        roar_up = F.lp_var(F.sat(F.lp(F.noise(n), 260.0) * 3.0, 3.0), 300.0 + 900.0 * (t / 0.45) ** 1.5) * (t / 0.45) ** 1.4 * 0.9
        b = roar_up
        ign = 0.42
        b = at(b, mix(blast(0.7, 30.0, 0.8), FX.plasma_splash(0.9), ignition(1.0)), ign)
        b = at(b, wail(1.8, 230.0, 0.15), ign + 0.02)
        b = at(b, crackles(1.9, 0.65), ign + 0.15)
        b = at(b, flame_sputters(1.9, 0.75), ign + 0.15)
        b = at(b, static(1.7, 0.35), ign + 0.2)
        n = n_of(1.2)
        flames = F.lp(F.sat(F.lp(F.noise(n), 320.0) * 3.0, 3.0), 1100.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 0.9), (0.6, 0.5), (1.2, 0.0)]) * 0.5
        b = at(b, flames, ign + 0.05)
    return room(b, decay=0.25, mix=0.1)


def static(dur, gain=0.4):
    """Static over the fire: broadband hiss switched in short random bursts, thinning out."""
    n = n_of(dur)
    t = t_of(n)
    gate = (F.RNG.uniform(0.0, 1.0, n // n_of(0.015) + 1) > (0.45 + 0.4 * np.linspace(0.0, 1.0, n // n_of(0.015) + 1))).repeat(n_of(0.015))[:n].astype(float)
    gate = np.convolve(gate, np.ones(n_of(0.002)) / n_of(0.002), mode="same")
    return F.bp(F.noise(n), 500.0, 2600.0) * gate * F.env_pts(n, [(0.0, 1.0), (dur, 0.0)]) * gain


# ---------------------------------------------------------------- the seventh cut (Ryan, 9 October)
# Minerva's boom... BOOM broke the speaker and rang like a timpani: measured, its band under
# 100 Hz sat 6.6 dB over its mids, where every death that plays clean sits at or under level,
# and its thump was a pure tone held too long. So the thump decays fast (a punch, not a drum),
# the sub is mostly gone with a high-pass under the lot, the noise body carries it, the two
# fronts still pitched apart; and a full second between them, as if at either end of the
# machine. Kestrel lands. The Arsenal: the boom first, then the roar over the ghost, breaking
# up into the static and crackles; the ghost a wail.

VOICE_AT7 = {"minerva": 1.75, "arsenal": 1.25}


def boom2(f0, f1, dur, gain=1.0, body_cut=600.0, sub=0.0):
    """A boom built from its front, phone-safe: the thump falling from f0 punches and is gone in
    a tenth of a second, the noise body carries the rest, nothing under 45 Hz."""
    n = n_of(dur)
    t = t_of(n)
    f = f1 + (f0 - f1) * np.exp(-t / 0.035)
    thump = np.sin(2.0 * math.pi * np.cumsum(f) / SR) * F.env_pts(n, [(0.0, 0.0), (0.002, 1.0), (0.04, 0.45), (0.12, 0.08), (dur, 0.0)])
    body = F.lp(F.noise(n), body_cut, order=3) * F.env_pts(n, [(0.0, 0.0), (0.003, 1.0), (dur * 0.3, 0.4), (dur, 0.0)]) * 1.4
    b = F.sat((thump * 0.9 + body) * 1.5, 2.0)
    if sub > 0.0:
        rumble = F.lp(F.noise(n), 70.0) * F.env_pts(n, [(0.0, 0.0), (0.05, 1.0), (dur, 0.0)]) * sub
        b = mix(b, F.sat(rumble * 2.0, 2.0))
    b = mix(b, FX.boom_tail(dur * 0.9, 0.55, cut=body_cut * 0.7))
    pad = np.zeros(n_of(0.5))
    b = b + F.bp(np.concatenate([F.sat(b * 1.5, 3.0), pad]), 180.0, 1400.0)[:len(b)] * 0.7
    b = F.hp(np.concatenate([b, pad]), 60.0, order=3)[:len(b)]
    return b * gain


def banshee(dur=1.8, f0=430.0, gain=1.0):
    """A wail: a voice held high on a slow rise and fall with a wide slow waver, from "oo"
    opening to "ah", breathy, washed far back; something leaving, not someone shouting."""
    n = n_of(dur)
    t = t_of(n)
    contour = np.interp(t, [0.0, dur * 0.3, dur * 0.65, dur], [f0 * 0.85, f0 * 1.2, f0 * 1.05, f0 * 0.7])
    contour = contour * (1.0 + 0.03 * np.sin(2.0 * math.pi * 4.6 * t) + 0.01 * np.sin(2.0 * math.pi * 7.3 * t))
    out = np.zeros(n)
    for detune, g in ((1.0, 1.0), (1.006, 0.8), (0.995, 0.7)):
        ph = 2.0 * math.pi * np.cumsum(contour * detune) / SR
        v = np.zeros(n)
        for k in range(1, 10):
            v += np.sin(k * ph) / (k * k)
        out += v * g
    out = out + F.lp(F.noise(n), 2200.0) * 0.18
    o = (t / dur)
    oo = mix(F.bp(out, 280.0, 420.0), F.bp(out, 700.0, 950.0) * 0.5)
    ah = mix(F.bp(out, 650.0, 950.0), F.bp(out, 1050.0, 1400.0) * 0.6)
    vowel = oo * (1.0 - o) + ah * o
    vowel = vowel * F.env_pts(n, [(0.0, 0.0), (0.18, 1.0), (dur * 0.7, 0.85), (dur, 0.0)])
    return room(FX.chorus(vowel, depth=0.005, rate=0.4, voices=3, wet=0.8), decay=0.8, mix=0.45) * gain


def death7(maker):
    if maker == "minerva":
        b = boom2(190.0, 70.0, 0.8, 0.42, body_cut=650.0)
        b = at(b, boom2(105.0, 34.0, 1.5, 1.8, body_cut=330.0, sub=0.1), 1.0)
    else:
        # The Arsenal: the boom first; the fire roaring up over the wail; then it breaks up into
        # static, crackles and sputters as the roar and the wail go.
        b = mix(blast(0.8, 28.0, 1.0), FX.plasma_splash(1.0))
        n = n_of(1.5)
        t = t_of(n)
        roar = F.lp_var(F.sat(F.lp(F.noise(n), 280.0) * 3.0, 3.0), 400.0 + 700.0 * np.minimum(1.0, t / 0.4)) * F.env_pts(n, [(0.0, 0.0), (0.35, 1.0), (0.9, 0.8), (1.5, 0.0)]) * 0.8
        b = at(b, roar, 0.12)
        b = at(b, banshee(1.7, 430.0, 0.32), 0.2)
        b = at(b, static(1.4, 0.5) * F.env_pts(n_of(1.4), [(0.0, 0.0), (0.25, 1.0), (1.4, 0.0)]), 1.0)
        b = at(b, crackles(1.6, 0.7), 0.95)
        b = at(b, flame_sputters(1.5, 0.75), 1.0)
    return room(b, decay=0.25, mix=0.1)


# ---------------------------------------------------------------- written as the game plays it

def at_level(x, level):
    """At its level, then the forge's master stage, as the game's files are."""
    return F.master(x * 10.0 ** ((level - F.loudness(x)) / 20.0))


def read(path, rate=SR):
    with wave.open(path, "rb") as w:
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32767.0
        sr = w.getframerate()
    if sr != rate:
        x = np.interp(np.arange(int(len(x) * rate / sr)) * sr / rate, np.arange(len(x)), x)
    return x


def write(name, x):
    """Like the page's writer, without folding the master stage's peaks again."""
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, name + ".wav")
    pcm = (np.clip(x, -1.0, 1.0) * 32767.0).astype("<i2")
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    subprocess.run(["afconvert", "-f", "mp4f", "-d", "aac", "-b", "128000", "-q", "127", wav, os.path.join(OUT, name + ".mp4")], check=True, capture_output=True)


def short(fn, keep=0.55, fade=0.25):
    """A foe's death held under a second: the room and the boom faded out after `keep`."""
    def build():
        x = fn()
        n, f = n_of(keep), n_of(fade)
        x = x[:n + f].copy()
        x[n:] *= np.linspace(1.0, 0.0, len(x) - n) ** 2
        return x
    return build


def tail(x, s=0.35):
    return np.concatenate([x, np.zeros(n_of(s))])


FOE_LEVEL = F.LEVELS["kill"] + 1.0 - 3.0      # three under the machine's death: it happens ten times a fight
DEATH_LEVEL = F.LEVELS["kill"] + 1.0          # the third cut's kill level
BREAK_LEVEL = F.LEVELS["shield_break"] + 2.0  # the third cut's shield level

SINGLES = [
    ("foe_blast", short(foe_blast), FOE_LEVEL), ("foe_undead", short(foe_undead), FOE_LEVEL),
    ("foe_demonic", short(foe_demonic), FOE_LEVEL), ("foe_eldritch", short(foe_eldritch), FOE_LEVEL),
    ("death_minerva_relays", lambda: machine_death("minerva", "relays"), DEATH_LEVEL),
    ("death_arsenal_relays", lambda: machine_death("arsenal", "relays"), DEATH_LEVEL),
    ("death_kestrel_relays", lambda: machine_death("kestrel", "relays"), DEATH_LEVEL),
    ("death_minerva_whine", lambda: machine_death("minerva", "whine"), DEATH_LEVEL),
    ("break_discharge", lambda: shield_discharge(False), BREAK_LEVEL),
    ("break_discharge_big", lambda: shield_discharge(True), BREAK_LEVEL),
]


SINGLES2 = [("death2_" + m, (lambda m=m: death2(m)), DEATH_LEVEL) for m in ("minerva", "wainwright_sutler", "kestrel", "aphelion", "arsenal")] + [
    ("break2", shield_discharge2, BREAK_LEVEL)]


def cut2():
    made = {}
    for name, fn, level in SINGLES2:
        F.seed("d2_" + name)
        x = at_level(fn(), level)
        made[name] = x
        write("d2_" + name, tail(x))
        print("  d2_%-24s %5.2f s" % (name, len(x) / SR))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    brute = read(os.path.join(ART, "foe_demonic_heavy.wav"))
    land = 0.3
    for m in ("minerva", "wainwright_sutler", "kestrel", "aphelion", "arsenal"):
        hit = read(os.path.join(ART, "hit_%s.wav" % m))
        x = made["death2_" + m]
        seq = at(at(at(at(np.zeros(1), brute, 0.0), hit * 0.7, land), x, land + 0.12), line_lost, land + 0.12 + 0.55)
        write("d2_seq_lost_" + m, tail(seq, 0.5))
    print("  sequences written")
    return 0


SINGLES3 = [("death3_" + m, (lambda m=m: death3(m)), DEATH_LEVEL) for m in ("minerva", "wainwright_sutler", "kestrel", "aphelion", "arsenal")]


def cut3():
    made = {}
    for name, fn, level in SINGLES3:
        F.seed("d3_" + name)
        x = at_level(fn(), level)
        made[name] = x
        write("d3_" + name, tail(x))
        print("  d3_%-24s %5.2f s" % (name, len(x) / SR))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    brute = read(os.path.join(ART, "foe_demonic_heavy.wav"))
    land = 0.3
    for m in ("minerva", "wainwright_sutler", "kestrel", "aphelion", "arsenal"):
        hit = read(os.path.join(ART, "hit_%s.wav" % m))
        seq = at(at(at(at(np.zeros(1), brute, 0.0), hit * 0.7, land), made["death3_" + m], land + 0.12), line_lost, land + 0.12 + VOICE_AT[m])
        write("d3_seq_lost_" + m, tail(seq, 0.5))
    print("  sequences written")
    return 0


SINGLES4 = [("death4_" + m, (lambda m=m: death4(m)), DEATH_LEVEL) for m in ("minerva", "kestrel", "aphelion", "arsenal")]


def cut4():
    made = {}
    for name, fn, level in SINGLES4:
        F.seed("d4_" + name)
        x = at_level(fn(), level)
        made[name] = x
        write("d4_" + name, tail(x))
        print("  d4_%-24s %5.2f s" % (name, len(x) / SR))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    for m in ("minerva", "kestrel", "aphelion", "arsenal"):
        seq = at(np.zeros(1), made["death4_" + m], 0.0)
        seq = at(seq, line_lost, VOICE_AT4[m])
        write("d4_seq_lost_" + m, tail(seq, 0.5))
    print("  sequences written")
    return 0


SINGLES5 = [("death5_" + v, (lambda v=v: death5(v)), DEATH_LEVEL) for v in ("minerva_first_low", "minerva_second_low", "kestrel", "aphelion", "arsenal")]


def cut5():
    made = {}
    for name, fn, level in SINGLES5:
        F.seed("d5_" + name)
        x = at_level(fn(), level)
        made[name] = x
        write("d5_" + name, tail(x))
        print("  d5_%-26s %5.2f s" % (name, len(x) / SR))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    for v in VOICE_AT5:
        write("d5_seq_lost_" + v, tail(at(at(np.zeros(1), made["death5_" + v], 0.0), line_lost, VOICE_AT5[v]), 0.5))
    print("  sequences written")
    return 0


SINGLES6 = [("death6_" + m, (lambda m=m: death6(m)), DEATH_LEVEL) for m in ("minerva", "kestrel", "arsenal")]


def cut6():
    made = {}
    for name, fn, level in SINGLES6:
        F.seed("d6_" + name)
        x = at_level(fn(), level)
        made[name] = x
        write("d6_" + name, tail(x))
        print("  d6_%-24s %5.2f s" % (name, len(x) / SR))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    for m in VOICE_AT6:
        write("d6_seq_lost_" + m, tail(at(at(np.zeros(1), made["death6_" + m], 0.0), line_lost, VOICE_AT6[m]), 0.5))
    print("  sequences written")
    return 0


SINGLES7 = [("death7_" + m, (lambda m=m: death7(m)), DEATH_LEVEL) for m in ("minerva", "arsenal")]


def cut7():
    made = {}
    for name, fn, level in SINGLES7:
        F.seed("d7_" + name)
        x = at_level(fn(), level)
        made[name] = x
        write("d7_" + name, tail(x))
        print("  d7_%-24s %5.2f s" % (name, len(x) / SR))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    for m in VOICE_AT7:
        write("d7_seq_lost_" + m, tail(at(at(np.zeros(1), made["death7_" + m], 0.0), line_lost, VOICE_AT7[m]), 0.5))
    print("  sequences written")
    return 0


def main(argv):
    if argv[:1] == ["7"]:
        return cut7()
    if argv[:1] == ["6"]:
        return cut6()
    if argv[:1] == ["5"]:
        return cut5()
    if argv[:1] == ["2"]:
        return cut2()
    if argv[:1] == ["3"]:
        return cut3()
    if argv[:1] == ["4"]:
        return cut4()
    made = {}
    for name, fn, level in SINGLES:
        F.seed(PREFIX + name)
        x = at_level(fn(), level)
        made[name] = x
        write(PREFIX + name, tail(x))
        print("  %s%-24s %5.2f s" % (PREFIX, name, len(x) / SR))
    for name in ("kill", "kill_minerva", "shield_break"):
        write(PREFIX + "now_" + name, tail(read(os.path.join(ART, name + ".wav"))))
    # In context: a laser kills a ghoul and Jenny says it; a brute fells a Minerva machine.
    line_foe = read(os.path.join(ART, "voice", "line_undead_anomaly_cleared.wav"))
    line_lost = read(os.path.join(ART, "voice", "line_machine_lost.wav"))
    laser = read(os.path.join(ART, "w_laser.wav"))
    land = 0.08 + 0.47
    now = at(at(np.zeros(1), laser, 0.08), line_foe, land)                        # today: her line in place of the kill
    new = at(at(at(np.zeros(1), laser, 0.08), made["foe_undead"], land), line_foe, land + 0.45)
    write(PREFIX + "seq_foe_now", tail(now, 0.5))
    write(PREFIX + "seq_foe_new", tail(new, 0.5))
    brute = read(os.path.join(ART, "foe_demonic_heavy.wav"))
    hit = read(os.path.join(ART, "hit_minerva.wav"))
    land = 0.3
    now = at(at(at(at(np.zeros(1), brute, 0.0), hit * 0.7, land), read(os.path.join(ART, "kill_minerva.wav")), land + 0.12), line_lost, land + 0.9)
    write(PREFIX + "seq_lost_now", tail(now, 0.5))
    for pd in ("relays", "whine"):
        x = made["death_minerva_" + pd]
        new = at(at(at(at(np.zeros(1), brute, 0.0), hit * 0.7, land), x, land + 0.12), line_lost, land + 0.12 + 0.55)
        write(PREFIX + "seq_lost_" + pd, tail(new, 0.5))
    print("  sequences written")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
