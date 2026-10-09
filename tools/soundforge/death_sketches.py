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
        b = F.lp(b, cut, order=3)
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


def main(argv):
    if argv[:1] == ["2"]:
        return cut2()
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
