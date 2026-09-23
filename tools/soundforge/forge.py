"""Every sound the game plays, built from a written recipe, the way lowforge builds the
models. The direction (bible, 22 September): grounded and heavy, weight and machinery,
nothing that sounds like a space opera; the music an industrial groove, driving but not
fast, more bop than pummel. These are placeholders in that register, to be replaced by
real recordings and a real track when there are some. numpy only.

    tools/spriter/.venv/bin/python tools/soundforge/forge.py build            # everything into art/audio
    tools/spriter/.venv/bin/python tools/soundforge/forge.py build hit kill   # some
    tools/spriter/.venv/bin/python tools/soundforge/forge.py list

Then `godot --headless --path . --import`. `game/audio/sound.gd` plays them by name.
"""
import math
import os
import struct
import sys
import wave

import numpy as np

SR = 32000
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "art", "audio")
RNG = np.random.default_rng(7)


# ---------------------------------------------------------------- primitives

def n_of(seconds):
    return int(round(seconds * SR))


def t_of(n):
    return np.arange(n) / SR


def env_ad(n, attack, decay, curve=4.0):
    """Attack in seconds, then an exponential decay with time constant `decay`."""
    t = t_of(n)
    a = np.clip(t / max(attack, 1e-4), 0.0, 1.0)
    d = np.exp(-np.maximum(t - attack, 0.0) / max(decay, 1e-4) * curve / 4.0)
    return a * d


def noise(n):
    return RNG.standard_normal(n)


def _filter(x, shape):
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1.0 / SR)
    return np.fft.irfft(spec * shape(f), n=len(x))


def lp(x, cutoff, order=2):
    return _filter(x, lambda f: 1.0 / np.sqrt(1.0 + (f / cutoff) ** (2 * order)))


def hp(x, cutoff, order=2):
    return _filter(x, lambda f: 1.0 / np.sqrt(1.0 + (np.maximum(cutoff, 1e-3) / np.maximum(f, 1e-3)) ** (2 * order)))


def bp(x, lo, hi, order=2):
    return lp(hp(x, lo, order), hi, order)


def lp_var(x, cutoffs, passes=2):
    """A one-pole low-pass whose cutoff moves sample by sample (a sweep or a wash)."""
    a = 1.0 - np.exp(-2.0 * math.pi * np.asarray(cutoffs, dtype=float) / SR)
    y = np.array(x, dtype=float)
    for _ in range(passes):
        acc = 0.0
        out = np.empty_like(y)
        for i in range(len(y)):
            acc += a[i] * (y[i] - acc)
            out[i] = acc
        y = out
    return y


def sat(x, drive=2.0):
    return np.tanh(x * drive) / math.tanh(drive)


def sweep(f0, f1, n, tau=None):
    """A sine whose pitch falls from f0 to f1 exponentially over the buffer."""
    t = t_of(n)
    tau = tau or (n / SR) * 0.3
    f = f1 + (f0 - f1) * np.exp(-t / tau)
    phase = 2.0 * math.pi * np.cumsum(f) / SR
    return np.sin(phase)


def thud(f0=140.0, f1=42.0, dur=0.35, click=0.6, drive=2.5):
    """A heavy impact: a falling sine with a click on its front, saturated."""
    n = n_of(dur)
    body = sweep(f0, f1, n) * env_ad(n, 0.002, dur * 0.35)
    c = lp(noise(n), 3000.0) * env_ad(n, 0.0005, 0.012) * click
    return sat(body + c, drive)


def ring(freqs, decays, amps=None, dur=None):
    """Inharmonic partials with their own decays: struck metal."""
    dur = dur or max(decays) * 4.0
    n = n_of(dur)
    t = t_of(n)
    out = np.zeros(n)
    amps = amps or [1.0] * len(freqs)
    for f, d, a in zip(freqs, decays, amps):
        out += a * np.sin(2.0 * math.pi * f * t) * np.exp(-t / d)
    return out / max(1.0, sum(amps) * 0.6)


def burst(dur, lo, hi, attack=0.0005, decay=None):
    n = n_of(dur)
    return bp(noise(n), lo, hi) * env_ad(n, attack, decay or dur * 0.3)


def mix(*parts, gain=1.0):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[:len(p)] += p
    return out * gain


def at(buf, sound, seconds, gain=1.0, wrap=False):
    """Add `sound` into `buf` starting at `seconds` (extending, or wrapping for a loop)."""
    start = n_of(seconds)
    if wrap:
        idx = (np.arange(len(sound)) + start) % len(buf)
        np.add.at(buf, idx, sound * gain)
        return buf
    end = start + len(sound)
    if end > len(buf):
        buf = np.concatenate([buf, np.zeros(end - len(buf))])
    buf[start:end] += sound * gain
    return buf


def tail(sound, seconds):
    return np.concatenate([sound, np.zeros(n_of(seconds))])


def normalize(x, peak_db=-1.0):
    m = np.max(np.abs(x)) or 1.0
    return x / m * (10.0 ** (peak_db / 20.0))


def write(name, x):
    x = normalize(x)
    pcm = (np.clip(x, -1.0, 1.0) * 32767.0).astype("<i2")
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    return path


# ---------------------------------------------------------------- effects
# The register: weight, machinery, relays and hydraulics. Nothing whooshes.

def ui_tap():
    # A relay closing: a dry click with a little body.
    return mix(burst(0.03, 1500, 7000, decay=0.006), thud(700, 180, 0.04, click=0.3, drive=1.5) * 0.35)


def ui_back():
    # The same relay letting go, softer, a beat later.
    b = ui_tap() * 0.6
    return at(b, ui_tap() * 0.35, 0.06)


def plot():
    # A plotting tick: the relay, then a short soft blip from the display.
    n = n_of(0.07)
    blip = np.sin(2.0 * math.pi * 620.0 * t_of(n)) * env_ad(n, 0.003, 0.02) * 0.25
    return at(ui_tap() * 0.8, lp(blip, 2000), 0.015)


def codex_open():
    # A plate sliding out on a rail, stopping against its catch.
    n = n_of(0.22)
    slide = bp(noise(n), 400, 2600) * env_ad(n, 0.02, 0.4) * 0.5
    return at(slide, mix(thud(320, 110, 0.08, click=0.5), burst(0.05, 900, 5000, decay=0.01) * 0.5), 0.2)


def codex_close():
    b = mix(thud(260, 90, 0.07, click=0.4), burst(0.04, 800, 4000, decay=0.008) * 0.4)
    n = n_of(0.18)
    slide = bp(noise(n), 300, 2000) * env_ad(n, 0.005, 0.12) * 0.4
    return at(b, slide, 0.03)


def menu_open():
    # A heavy breaker thrown: a thunk, then the hiss of the display holding.
    n = n_of(0.5)
    hiss = lp(noise(n), 1800) * env_ad(n, 0.03, 0.25) * 0.18
    return at(thud(180, 55, 0.18, click=0.8), hiss, 0.04)


def die_pick():
    # Steel picked up off steel: a bright short catch with a ratchet on it.
    r = ring([2100, 3300, 5200], [0.03, 0.02, 0.015], [1.0, 0.6, 0.3])
    return mix(r * 0.7, burst(0.02, 2000, 9000, decay=0.004))


def die_drop():
    # Set back down on the plate: a clunk with a damped ring.
    return mix(thud(240, 70, 0.14, click=0.7, drive=2.0), ring([1400, 2250, 3700], [0.06, 0.04, 0.03], [0.6, 0.4, 0.2]) * 0.5)


def die_roll():
    # Dice on a steel tray: a scatter of small clunks, settling.
    buf = np.zeros(n_of(0.42))
    when = 0.0
    for k in range(7):
        pitch = RNG.uniform(0.85, 1.25)
        hit = mix(thud(260 * pitch, 90 * pitch, 0.06, click=0.6, drive=1.8) * 0.6,
                  ring([1700 * pitch, 2900 * pitch], [0.035, 0.02], [0.5, 0.3]) * 0.5)
        buf = at(buf, hit, when, gain=1.0 - k * 0.09)
        when += RNG.uniform(0.03, 0.075) * (1.0 + k * 0.12)
    return buf


def die_lock():
    # A latch: click, then clack.
    return at(ui_tap() * 0.9, mix(thud(420, 150, 0.05, click=0.9, drive=2.0), burst(0.03, 2500, 8000, decay=0.005) * 0.5), 0.055)


def shield_up():
    # A plate slamming into place, hydraulics behind it.
    n = n_of(0.3)
    hyd = bp(noise(n), 200, 900) * env_ad(n, 0.05, 0.5) * 0.35
    slam = mix(thud(200, 60, 0.2, click=0.9, drive=3.0), ring([900, 1500, 2450], [0.12, 0.08, 0.05], [0.7, 0.4, 0.25]) * 0.5)
    return at(hyd, slam, 0.12)


def vent():
    # Steam let go: a hard hiss that tails off, the valve knocking shut.
    n = n_of(0.55)
    hiss = bp(noise(n), 900, 7000) * env_ad(n, 0.01, 0.16) * 0.8
    return at(hiss, thud(300, 120, 0.05, click=0.6) * 0.5, 0.42)


def hit():
    # A blow landing on armour: the thud, the noise of the strike, a short metallic ring.
    return mix(thud(150, 45, 0.3, click=0.8, drive=3.0),
               burst(0.08, 300, 4000, decay=0.02) * 0.6,
               ring([620, 1130, 1790, 2600], [0.16, 0.1, 0.07, 0.05], [0.8, 0.5, 0.35, 0.2]) * 0.45)


def hit_crit():
    # The same, bigger: deeper, longer, more of the ring, and a second knock in its tail.
    b = mix(thud(170, 38, 0.5, click=1.0, drive=4.0),
            burst(0.12, 200, 5000, decay=0.03) * 0.7,
            ring([520, 980, 1560, 2350, 3400], [0.3, 0.2, 0.14, 0.1, 0.07], [0.9, 0.6, 0.45, 0.3, 0.2]) * 0.55)
    return at(b, thud(130, 40, 0.2, click=0.4, drive=2.0) * 0.5, 0.11)


def block():
    # Struck plate holding: a dull clang, damped fast, with no low end to speak of.
    return mix(ring([410, 690, 1040, 1520], [0.09, 0.07, 0.05, 0.04], [1.0, 0.7, 0.5, 0.3]) * 0.9,
               burst(0.05, 500, 3000, decay=0.015) * 0.5,
               thud(220, 90, 0.08, click=0.5, drive=1.5) * 0.4)


def shield_break():
    # The shield cracking: a sharp snap, a scatter of shards, and the ground taking the weight.
    buf = mix(burst(0.04, 2000, 12000, decay=0.006) * 1.0, thud(900, 200, 0.05, click=1.0, drive=3.0) * 0.6)
    for k in range(9):
        p = RNG.uniform(0.7, 1.6)
        shard = ring([2400 * p, 3900 * p], [0.05, 0.03], [0.6, 0.3]) * 0.35
        buf = at(buf, shard, 0.03 + k * RNG.uniform(0.012, 0.03))
    return at(buf, thud(120, 40, 0.35, click=0.3, drive=2.5) * 0.7, 0.05)


def kill():
    # A machine coming apart: a deep crunch, rumble, and a few late pieces landing.
    n = n_of(0.9)
    rumble = lp(noise(n), 160) * env_ad(n, 0.01, 0.35) * 1.2
    buf = mix(thud(110, 30, 0.6, click=1.0, drive=4.0), burst(0.2, 150, 2500, decay=0.06) * 0.8, rumble)
    for k, when in enumerate([0.28, 0.41, 0.55]):
        piece = mix(thud(240, 80, 0.07, click=0.6) * 0.5, ring([1300, 2100], [0.05, 0.03], [0.5, 0.3]) * 0.35)
        buf = at(buf, piece, when, gain=1.0 - k * 0.25)
    return buf


def arrival():
    # A heavy footfall as a foe steps into the line, dust after it.
    n = n_of(0.35)
    dust = lp(noise(n), 900) * env_ad(n, 0.04, 0.12) * 0.25
    return at(thud(120, 36, 0.3, click=0.5, drive=3.0), dust, 0.06)


def step():
    # A machine's footfall on the map, light: heard once a hex.
    n = n_of(0.12)
    grit = bp(noise(n), 600, 3000) * env_ad(n, 0.002, 0.03) * 0.3
    return mix(thud(160, 55, 0.11, click=0.5, drive=2.0) * 0.8, grit)


def resolve():
    # A lever pulled over and latched: the travel, then the heavy engagement.
    n = n_of(0.28)
    travel = bp(noise(n), 250, 1600) * env_ad(n, 0.04, 0.5) * 0.45
    latch = mix(thud(160, 48, 0.25, click=1.0, drive=3.5), ring([700, 1150], [0.1, 0.06], [0.5, 0.3]) * 0.35)
    return at(travel, latch, 0.24)


def contact():
    # The alarm: a low industrial horn, saturated, swelling and cut.
    n = n_of(0.62)
    t = t_of(n)
    horn = np.sign(np.sin(2.0 * math.pi * 55.0 * t)) * 0.5 + np.sin(2.0 * math.pi * 82.5 * t) * 0.6 + np.sin(2.0 * math.pi * 110.0 * t) * 0.3
    horn = lp(sat(horn, 3.0), 1400) * env_ad(n, 0.06, 0.5, curve=2.0)
    env = np.ones(n)
    env[-n_of(0.05):] = np.linspace(1.0, 0.0, n_of(0.05))
    return mix(horn * env, thud(90, 40, 0.3, click=0.2, drive=2.0) * 0.4)


def engage():
    # The dive: the display's drive spinning down, a wash rising under it, until the cut.
    n = n_of(2.2)
    t = t_of(n)
    f = 420.0 * np.exp(-t / 0.9) + 38.0
    drive = np.sin(2.0 * math.pi * np.cumsum(f) / SR)
    drive = lp(sat(drive, 2.0), 900) * (0.5 + 0.5 * np.exp(-t / 1.2))
    wash = lp_var(noise(n), 600 + 2400 * (t / 2.2) ** 2) * (t / 2.2) ** 1.5 * 0.8
    return mix(drive * 0.6, wash)


def cut():
    # The cut to black at the handover: one hard boom, close.
    n = n_of(0.6)
    rumble = lp(noise(n), 120) * env_ad(n, 0.005, 0.25) * 1.0
    return mix(thud(90, 28, 0.6, click=1.0, drive=4.0), rumble)


def gate_hit():
    # The gate struck: a huge slow boom, the structure groaning after it.
    n = n_of(1.6)
    t = t_of(n)
    groan = np.sin(2.0 * math.pi * (58.0 + 6.0 * np.sin(2.0 * math.pi * 1.3 * t)) * t) * env_ad(n, 0.15, 0.6) * 0.5
    groan = lp(sat(groan, 2.5), 700)
    rumble = lp(noise(n), 90) * env_ad(n, 0.01, 0.5) * 1.3
    return mix(thud(70, 22, 1.0, click=0.8, drive=4.0) * 1.2, rumble, groan, burst(0.15, 120, 1800, decay=0.05) * 0.5)


def spawn():
    # The rift: a swell rising from nothing to a low pulse, a wash of static over it.
    n = n_of(1.3)
    t = t_of(n)
    swell = np.sin(2.0 * math.pi * 44.0 * t) * (t / 1.3) ** 2.5
    swell = lp(sat(swell, 3.0), 500)
    static = bp(noise(n), 1500, 6000) * (t / 1.3) ** 3 * 0.35
    end = thud(110, 36, 0.5, click=0.6, drive=3.0) * 0.8
    return at(mix(swell, static), end, 1.05)


def victory():
    # The stand held: a low power chord with a slow front, industrial, let ring.
    n = n_of(1.8)
    t = t_of(n)
    chord = np.zeros(n)
    for f, a in [(82.4, 1.0), (123.5, 0.7), (164.8, 0.5), (247.0, 0.3)]:
        chord += a * (np.sin(2.0 * math.pi * f * t) + 0.3 * np.sign(np.sin(2.0 * math.pi * f * 1.002 * t)))
    chord = lp(sat(chord, 2.0), 1600) * env_ad(n, 0.12, 0.7, curve=2.5)
    return mix(chord, thud(120, 40, 0.5, click=0.5, drive=3.0) * 0.6)


def defeat():
    # The line broken: a low drone sinking, then the last thing to fall.
    n = n_of(1.9)
    t = t_of(n)
    f = 70.0 * np.exp(-t / 1.6) + 26.0
    drone = np.sin(2.0 * math.pi * np.cumsum(f) / SR) + 0.4 * np.sin(2.0 * math.pi * np.cumsum(f * 1.5) / SR)
    drone = lp(sat(drone, 2.5), 600) * env_ad(n, 0.05, 1.0, curve=2.0)
    return at(drone, thud(100, 30, 0.5, click=0.6, drive=3.5) * 0.9, 1.35)


def withdraw():
    # Pulling out: hydraulics retreating, a door coming down behind the machines.
    n = n_of(0.7)
    t = t_of(n)
    hyd = lp_var(hp(noise(n), 220), 1400 - 900 * t / 0.7) * env_ad(n, 0.05, 0.6) * 0.45
    return at(hyd, thud(140, 42, 0.35, click=0.8, drive=3.0), 0.55)


# ---------------------------------------------------------------- music
# Two loops in one kit. Sixteenths on a grid; a bar is 16 steps. `x` in a drum pattern is
# a hit, `.` a rest, `o` a softer hit. Bass riffs are semitones above E2 (82.4 Hz), `-`
# holds, `.` rests. Loops are rendered wrapped, so tails cross the seam and it plays round.

E2 = 82.41


def kick_drum():
    return mix(thud(160, 44, 0.32, click=0.9, drive=3.5), lp(noise(n_of(0.05)), 300) * env_ad(n_of(0.05), 0.001, 0.01) * 0.3)


def snare_drum():
    n = n_of(0.22)
    tone = np.sin(2.0 * math.pi * 185.0 * t_of(n)) * env_ad(n, 0.001, 0.05) * 0.5
    return mix(burst(0.22, 180, 6500, decay=0.05) * 0.9, tone, thud(300, 120, 0.06, click=0.5) * 0.4)


def hat(open_=False):
    return burst(0.28 if open_ else 0.045, 6000, 14000, decay=0.09 if open_ else 0.012) * 0.55


def clank():
    return ring([1180, 1930, 2760, 4100], [0.09, 0.06, 0.045, 0.03], [0.8, 0.5, 0.35, 0.2]) * 0.6


def bass_note(freq, dur, drive=3.0, cutoff=900.0):
    n = n_of(dur)
    t = t_of(n)
    saw = 2.0 * ((freq * t) % 1.0) - 1.0
    sub = np.sin(2.0 * math.pi * freq * t) * 0.6
    x = lp(sat(saw + sub, drive), cutoff)
    env = env_ad(n, 0.004, dur * 0.6, curve=2.0)
    release = np.ones(n)
    r = n_of(0.02)
    release[-r:] = np.linspace(1.0, 0.0, r)
    return x * env * release


def drone(freq, n, cutoff=380.0, gain=0.14):
    t = t_of(n)
    x = np.zeros(n)
    for det in [0.996, 1.0, 1.004]:
        x += 2.0 * ((freq * det * t) % 1.0) - 1.0
    x = lp(x, cutoff)
    lfo = 0.85 + 0.15 * np.sin(2.0 * math.pi * 0.11 * t)
    return x * lfo * gain


def groove(bpm, bars, kick, snare, hats, opens, clanks, riff, drive, cutoff, drone_gain):
    step_s = 60.0 / bpm / 4.0
    n = int(round(bars * 16 * step_s * SR))
    buf = np.zeros(n)
    k, s, ho, hc, cl = kick_drum(), snare_drum(), hat(True), hat(False), clank()
    for bar in range(bars):
        for i in range(16):
            when = (bar * 16 + i) * step_s
            pat = lambda p: p[(bar * 16 + i) % len(p)]
            if pat(kick) == "x":
                buf = at(buf, k, when, 1.0, wrap=True)
            elif pat(kick) == "o":
                buf = at(buf, k, when, 0.55, wrap=True)
            if pat(snare) == "x":
                buf = at(buf, s, when, 0.9, wrap=True)
            elif pat(snare) == "o":
                buf = at(buf, s, when, 0.35, wrap=True)
            if pat(opens) == "x":
                buf = at(buf, ho, when, 0.5, wrap=True)
            elif pat(hats) == "x":
                buf = at(buf, hc, when, 0.55 if i % 4 == 0 else 0.35, wrap=True)
            elif pat(hats) == "r":   # a roll: three in the step
                for j in range(3):
                    buf = at(buf, hc, when + j * step_s / 3.0, 0.3, wrap=True)
            if pat(clanks) == "x":
                buf = at(buf, cl, when + RNG.uniform(-0.004, 0.004), 0.5, wrap=True)
    # The riff: a note holds through `-` steps.
    i = 0
    total = bars * 16
    while i < total:
        c = riff[i % len(riff)]
        if c in ".-":
            i += 1
            continue
        semis = int(c) if c.isdigit() else {"a": 10, "b": 11, "c": 12, "d": 14, "e": 15, "f": 17, "g": -2, "h": -5}[c]
        length = 1
        while i + length < total and riff[(i + length) % len(riff)] == "-":
            length += 1
        freq = E2 * 2.0 ** (semis / 12.0)
        buf = at(buf, bass_note(freq, length * step_s * 0.95, drive, cutoff), i * step_s, 0.8, wrap=True)
        i += length
    buf += drone(E2 / 2.0, n, gain=drone_gain)
    return sat(buf, 1.4)


def music_map():
    # Subdued, still moving: four to the floor but light, the snare on two and four, hats
    # ticking sixteenths with a roll at the turn, one clank a bar, the riff sparse and low.
    return groove(
        bpm=92, bars=8,
        kick="x...o...x.....o.x...o...x...o.o.",
        snare="....x.......x.......x.......x..o",
        hats="x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.r.",
        opens="..........x...............x.....",
        clanks="......x.................x.......",
        riff="0--.3-.0-...1-..0--.3-.g-...0-..",
        drive=2.2, cutoff=650.0, drone_gain=0.16)


def music_skirmish():
    # Driving: the kick pushes, the snare answers with ghosts, trap hats with rolls, clanks
    # on the offbeats, the riff busier and dirtier with the octave jump.
    return groove(
        bpm=100, bars=8,
        kick="x..x..x...x.x...x..x..x.x...x.o.",
        snare="....x..o....x.......x..o..o.x...",
        hats="x.x.x.x.xxx.x.x.x.x.x.rrx.x.x.x.x.x.x.x.xxx.x.x.x.x.x.x.r.x.r.",
        opens="......x...............x.......x.",
        clanks="..x...x...x...x...x...x...x.x.x.",
        riff="00.c.0-3.00.1-.g00.c.0-3.00.h-..",
        drive=3.5, cutoff=1100.0, drone_gain=0.12)


SOUNDS = {
    "ui_tap": ui_tap, "ui_back": ui_back, "plot": plot,
    "codex_open": codex_open, "codex_close": codex_close, "menu_open": menu_open,
    "die_pick": die_pick, "die_drop": die_drop, "die_roll": die_roll, "die_lock": die_lock,
    "shield_up": shield_up, "vent": vent,
    "hit": hit, "hit_crit": hit_crit, "block": block, "shield_break": shield_break, "kill": kill,
    "arrival": arrival, "step": step, "resolve": resolve,
    "contact": contact, "engage": engage, "cut": cut, "gate_hit": gate_hit, "spawn": spawn,
    "victory": victory, "defeat": defeat, "withdraw": withdraw,
    "music_map": music_map, "music_skirmish": music_skirmish,
}


def main(argv):
    if len(argv) < 1 or argv[0] not in ("build", "list"):
        print(__doc__)
        return 2
    if argv[0] == "list":
        for name in SOUNDS:
            print(name)
        return 0
    names = argv[1:] or list(SOUNDS)
    for name in names:
        if name not in SOUNDS:
            print("no such sound:", name)
            return 1
        x = SOUNDS[name]()
        path = write(name, x)
        print("%-16s %5.2f s  %s" % (name, len(x) / SR, os.path.relpath(path)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
