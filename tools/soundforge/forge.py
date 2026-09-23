"""Every sound the game plays, built from a written recipe, the way lowforge builds the
models. The direction (bible, 22 September): grounded and heavy, weight and machinery,
nothing that sounds like a space opera; the music an industrial groove, driving but not
fast, more bop than pummel. These are placeholders in that register, to be replaced by
real recordings and a real track when there are some. numpy only.

    tools/spriter/.venv/bin/python tools/soundforge/forge.py build            # everything into art/audio
    tools/spriter/.venv/bin/python tools/soundforge/forge.py build hit kill   # some
    tools/spriter/.venv/bin/python tools/soundforge/forge.py list
    tools/spriter/.venv/bin/python tools/soundforge/forge.py measure          # level and balance of every file

Then `godot --headless --path . --import`. `game/audio/sound.gd` plays them by name.

The second cut (Ryan's notes, 23 September, after the first was measured):
  - A phone speaker starts around 300 Hz, so weight lives in the 150 to 800 Hz band (a
    body under every thud, saturation harmonics kept) with the sub as a bonus for headphones.
  - Mechanical, not industrial revolution: damped knocks (partials that die in 10 to 40 ms),
    servos, hydraulics and relays, never a bell or an anvil left to ring.
  - More under and overtones: every pitched thing is a stack (detuned saws, harmonics, an
    undertone an octave down), and a small room on everything, so nothing reads as chip-tune.
  - The mix is here: LEVELS gives each sound its loudness (the loudest 50 ms, RMS dB), so a
    hook in the game passes an offset only for a relative moment.
  - The loops are 16 bars in sections, not a two-bar phrase repeated.
"""
import math
import os
import sys
import wave
import zlib

import numpy as np

SR = 48000
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "art", "audio")
RNG = np.random.default_rng(7)


def seed(name):
    """Every sound is deterministic on its own, whatever else is built with it."""
    global RNG
    RNG = np.random.default_rng(zlib.crc32(name.encode()))


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


def env_pts(n, points):
    """A piecewise-linear envelope through [(seconds, level), ...]."""
    t = t_of(n)
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    return np.interp(t, xs, ys)


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


def shelf(x, freq, gain_db):
    """A gentle high shelf: `gain_db` above `freq`, flat below."""
    g = 10.0 ** (gain_db / 20.0)
    return _filter(x, lambda f: 1.0 + (g - 1.0) * (f ** 2 / (f ** 2 + freq ** 2)))


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


def svf(x, cutoff, q=0.7):
    """A resonant two-pole low-pass; `cutoff` a number or a per-sample array, `q` from 0.4
    (sharp) to 1.4 (dull). For short things: it walks the samples in Python."""
    fc = np.clip(np.broadcast_to(np.asarray(cutoff, dtype=float), (len(x),)), 20.0, 7000.0)
    f = 2.0 * np.sin(math.pi * fc / SR)
    low = band = 0.0
    out = np.empty(len(x))
    for i in range(len(x)):
        low += f[i] * band
        high = x[i] - low - q * band
        band += f[i] * high
        out[i] = low
    return out


def sat(x, drive=2.0):
    return np.tanh(x * drive) / math.tanh(drive)


def sweep(f0, f1, n, tau=None):
    """A sine whose pitch falls from f0 to f1 exponentially over the buffer."""
    t = t_of(n)
    tau = tau or (n / SR) * 0.3
    f = f1 + (f0 - f1) * np.exp(-t / tau)
    phase = 2.0 * math.pi * np.cumsum(f) / SR
    return np.sin(phase)


def saws(f, n, detune=(0.994, 1.0, 1.006), gain=1.0):
    """Detuned sawtooths, each from its own phase: the overtones a pure wave lacks."""
    t = t_of(n)
    out = np.zeros(n)
    for d in detune:
        out += 2.0 * ((f * d * t + RNG.uniform(0.0, 1.0)) % 1.0) - 1.0
    return out / len(detune) * gain


def harmonics(f, n, amps, detune=0.0012):
    """Sines at f, 2f, 3f... with `amps`, each a hair off tune so they beat slowly."""
    t = t_of(n)
    out = np.zeros(n)
    for k, a in enumerate(amps, start=1):
        d = 1.0 + RNG.uniform(-detune, detune) * (k - 1)
        out += a * np.sin(2.0 * math.pi * f * k * d * t + RNG.uniform(0.0, 2.0 * math.pi))
    return out / max(1e-6, sum(abs(a) for a in amps))


def room(x, decay=0.18, mix=0.12, cut=5000.0, pre=0.006):
    """A small room: the sound convolved with a short decaying noise, so it has a place."""
    n = n_of(decay * 4.0)
    ir = noise(n) * np.exp(-t_of(n) / decay)
    ir[: n_of(pre)] = 0.0
    ir = lp(ir, cut)
    ir /= math.sqrt(float(np.sum(ir ** 2))) + 1e-9
    m = len(x) + n - 1
    nfft = 1 << (m - 1).bit_length()
    wet = np.fft.irfft(np.fft.rfft(x, nfft) * np.fft.rfft(ir, nfft), nfft)[:m]
    wet *= (np.max(np.abs(x)) + 1e-9) / (np.max(np.abs(wet)) + 1e-9)
    out = np.zeros(m)
    out[: len(x)] = x
    return out + wet * mix


def body(f0=240.0, f1=110.0, dur=0.18, drive=2.0, click=0.3):
    """The mid of an impact, the part a phone can play: a falling knock through 100 to 300
    Hz, saturated so its harmonics carry it, a little noise on its front."""
    n = n_of(dur)
    knock = sweep(f0, f1, n, tau=dur * 0.25) * env_ad(n, 0.0015, dur * 0.3)
    c = bp(noise(n), 400.0, 2500.0) * env_ad(n, 0.0005, 0.008) * click
    return lp(sat(knock + c, drive), 2600.0)


def thud(f0=140.0, f1=42.0, dur=0.35, click=0.6, drive=2.5, body_gain=0.9):
    """A heavy impact: the sub, the body over it, a click on the front. Kept open to 1800 Hz
    so the saturation's harmonics survive to the phone."""
    n = n_of(dur)
    sub = sweep(f0, f1, n) * env_ad(n, 0.002, dur * 0.35) * 0.75
    c = lp(noise(n), 3000.0) * env_ad(n, 0.0005, 0.012) * click
    # The body stays in the band whatever the sub does: a deep boom still knocks at 230 Hz.
    mid = body(max(f0 * 1.8, 230.0), max(f1 * 2.8, 105.0), dur * 0.55, drive=drive * 0.8, click=0.0) * body_gain
    grit = bp(noise(n), 300.0, 1600.0) * env_ad(n, 0.001, dur * 0.15) * 0.3
    return lp(mix(sat(sub + c, drive), mid, grit), 2200.0)


def knock(freqs, decays, amps=None, noise_gain=0.35, dur=None):
    """Damped partials: a plate or a casing struck and stopped, dead in tens of ms. The
    mechanical answer to a ring (Ryan, 23 September: no cowbell, no anvil)."""
    dur = dur or max(decays) * 5.0
    n = n_of(dur)
    t = t_of(n)
    out = np.zeros(n)
    amps = amps or [1.0] * len(freqs)
    for f, d, a in zip(freqs, decays, amps):
        out += a * np.sin(2.0 * math.pi * f * t + RNG.uniform(0.0, 2.0 * math.pi)) * np.exp(-t / d)
    out /= max(1.0, sum(amps) * 0.7)
    transient = bp(noise(n), 800.0, 5000.0) * env_ad(n, 0.0004, 0.004) * noise_gain
    return out + transient


def servo(f0, f1, dur, gain=1.0, band=(500.0, 3200.0)):
    """A servo: a small motor's whine gliding from f0 to f1, thin, with its own grit."""
    n = n_of(dur)
    t = t_of(n)
    f = f0 + (f1 - f0) * (t / dur)
    ph = 2.0 * math.pi * np.cumsum(f) / SR
    tone = (2.0 * ((ph / (2.0 * math.pi)) % 1.0) - 1.0) * 0.6 + np.sin(ph * 2.0) * 0.3
    grit = bp(noise(n), 1500.0, 6000.0) * 0.12
    env = env_pts(n, [(0.0, 0.0), (dur * 0.12, 1.0), (dur * 0.85, 0.9), (dur, 0.0)])
    return bp(sat(tone + grit, 1.8), band[0], band[1]) * env * gain


def hydraulic(dur, c0, c1, gain=1.0, floor=180.0):
    """Hydraulics: a breathy push whose colour moves from c0 to c1 Hz."""
    n = n_of(dur)
    t = t_of(n)
    cut = c0 + (c1 - c0) * (t / dur)
    x = lp_var(hp(noise(n), floor), cut)
    env = env_pts(n, [(0.0, 0.0), (dur * 0.15, 1.0), (dur * 0.7, 0.8), (dur, 0.0)])
    return x * env * gain


def ratchet(count, dur, f=2200.0, gain=1.0, jitter=0.15):
    """A run of small clicks, a pawl over teeth."""
    buf = np.zeros(n_of(dur) + n_of(0.02))
    step = dur / max(count, 1)
    for k in range(count):
        p = RNG.uniform(1.0 - jitter, 1.0 + jitter)
        c = knock([f * p, f * 1.6 * p], [0.004, 0.003], [1.0, 0.5], noise_gain=0.5)
        buf = at(buf, c, k * step + RNG.uniform(0.0, step * 0.2), gain * RNG.uniform(0.6, 1.0))
    return buf


def relay(gain=1.0, pitch=1.0):
    """A relay closing: a dry click with a little casing under it."""
    c = bp(noise(n_of(0.03)), 1200.0 * pitch, 6000.0 * pitch) * env_ad(n_of(0.03), 0.0003, 0.004)
    b = knock([520.0 * pitch, 910.0 * pitch], [0.012, 0.008], [1.0, 0.5], noise_gain=0.0) * 0.6
    return mix(c, b) * gain


def burst(dur, lo, hi, attack=0.0005, decay=None):
    n = n_of(dur)
    return bp(noise(n), lo, hi) * env_ad(n, attack, decay or dur * 0.3)


def mix(*parts, gain=1.0):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out * gain


def at(buf, sound, seconds, gain=1.0, wrap=False):
    """Add `sound` into `buf` starting at `seconds` (extending, or wrapping for a loop)."""
    start = n_of(seconds)
    if wrap:
        idx = (np.arange(len(sound)) + start) % len(buf)
        np.add.at(buf, idx, sound * gain)
        return buf
    if start < 0:
        sound = sound[-start:]
        start = 0
    end = start + len(sound)
    if end > len(buf):
        buf = np.concatenate([buf, np.zeros(end - len(buf))])
    buf[start:end] += sound * gain
    return buf


def tail(sound, seconds):
    return np.concatenate([sound, np.zeros(n_of(seconds))])


def loudness(x):
    """The loudest 50 ms, as RMS dB: what a sound's level means here."""
    win = n_of(0.05)
    if len(x) < win:
        return 20.0 * math.log10(math.sqrt(float(np.mean(x ** 2))) + 1e-9)
    c = np.cumsum(np.concatenate([[0.0], x ** 2]))
    k = (c[win:] - c[:-win]) / win
    return 20.0 * math.log10(math.sqrt(float(k.max())) + 1e-9)


def low_share(x):
    spec = np.abs(np.fft.rfft(x)) ** 2
    f = np.fft.rfftfreq(len(x), 1.0 / SR)
    return float(spec[f < 150.0].sum() / (spec.sum() + 1e-9))


def limit(x, knee=0.8):
    """A soft knee above `knee`: peaks fold over, the body is untouched."""
    a = np.abs(x)
    over = a > knee
    folded = knee + (1.0 - knee) * np.tanh((a - knee) / (1.0 - knee))
    return np.where(over, np.sign(x) * folded, x)


def write(name, x, level):
    x = x * 10.0 ** ((level - loudness(x)) / 20.0)
    x = limit(x)
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
# The register: weight, machinery, relays, servos and hydraulics. Nothing whooshes,
# nothing rings.

def ui_tap():
    return room(relay(), decay=0.05, mix=0.06)


def ui_back():
    # The relay letting go: softer, lower, a second click a beat later.
    b = relay(0.6, pitch=0.85)
    return room(at(b, relay(0.35, pitch=0.8), 0.06), decay=0.05, mix=0.06)


def plot():
    # The relay, then a short blip from the display, with overtones so it is not a beep.
    n = n_of(0.06)
    blip = harmonics(540.0, n, [1.0, 0.5, 0.25, 0.12]) * env_ad(n, 0.003, 0.018) * 0.4
    return room(at(relay(0.8), lp(blip, 3000.0), 0.015), decay=0.06, mix=0.08)


def codex_open():
    # A plate sliding out on a rail, stopping against its catch.
    slide = hydraulic(0.2, 900.0, 2200.0, 0.45, floor=300.0)
    stop = mix(knock([310.0, 560.0, 890.0], [0.03, 0.02, 0.012], [1.0, 0.6, 0.3]) * 0.7, body(300.0, 130.0, 0.08, click=0.4) * 0.6)
    return room(at(slide, stop, 0.19), decay=0.12, mix=0.1)


def codex_close():
    stop = mix(knock([260.0, 470.0], [0.025, 0.015], [1.0, 0.5]) * 0.6, body(260.0, 110.0, 0.07, click=0.4) * 0.6)
    slide = hydraulic(0.17, 2000.0, 700.0, 0.4, floor=300.0)
    return room(at(stop, slide, 0.03), decay=0.12, mix=0.1)


def menu_open():
    # A heavy breaker thrown: the thunk, then the hiss of the display holding.
    n = n_of(0.5)
    hiss = lp(noise(n), 1800.0) * env_ad(n, 0.03, 0.25) * 0.18
    return room(at(thud(180.0, 55.0, 0.18, click=0.8), hiss, 0.04), decay=0.2, mix=0.12)


def die_pick():
    # A die lifted off its plate: a small catch letting go, the pawl over two teeth.
    k = knock([1150.0, 1720.0], [0.008, 0.006], [1.0, 0.5], noise_gain=0.5)
    return room(at(k, ratchet(2, 0.03, 2600.0, 0.5), 0.012), decay=0.05, mix=0.06)


def die_drop():
    # Set back down on the plate: a knock with a casing under it.
    return room(mix(body(260.0, 100.0, 0.1, click=0.6), knock([640.0, 1010.0, 1480.0], [0.03, 0.02, 0.012], [1.0, 0.5, 0.25]) * 0.6), decay=0.1, mix=0.1)


def die_roll():
    # Dice on a steel tray: a scatter of small knocks, settling.
    buf = np.zeros(n_of(0.42))
    when = 0.0
    for k in range(7):
        p = RNG.uniform(0.85, 1.25)
        hit_ = mix(body(280.0 * p, 110.0 * p, 0.05, click=0.6) * 0.6,
                   knock([720.0 * p, 1180.0 * p, 1690.0 * p], [0.025, 0.016, 0.01], [1.0, 0.5, 0.3]) * 0.55)
        buf = at(buf, hit_, when, gain=1.0 - k * 0.09)
        when += RNG.uniform(0.03, 0.075) * (1.0 + k * 0.12)
    return room(buf, decay=0.12, mix=0.12)


def die_lock():
    # A latch: click, then the bolt seating.
    seat = mix(body(420.0, 160.0, 0.05, click=0.9, drive=2.0) * 0.8, knock([590.0, 940.0], [0.02, 0.012], [1.0, 0.5]) * 0.6)
    return room(at(relay(0.9), seat, 0.055), decay=0.08, mix=0.08)


def shield_up():
    # A plate slamming into place, hydraulics pushing it, servos catching it.
    hyd = hydraulic(0.24, 500.0, 1400.0, 0.4)
    slam = mix(thud(200.0, 60.0, 0.2, click=0.9, drive=3.0), knock([680.0, 1120.0, 1730.0], [0.04, 0.025, 0.015], [1.0, 0.5, 0.25]) * 0.5)
    b = at(hyd, slam, 0.12)
    b = at(b, servo(1400.0, 900.0, 0.09, 0.25), 0.16)
    return room(b, decay=0.14, mix=0.12)


def vent():
    # Steam let go: a hard hiss that tails off, the valve knocking shut.
    n = n_of(0.55)
    hiss = bp(noise(n), 900.0, 8000.0) * env_ad(n, 0.01, 0.16) * 0.8
    b = at(hiss, mix(body(300.0, 120.0, 0.05, click=0.6) * 0.5, knock([820.0, 1300.0], [0.015, 0.01]) * 0.3), 0.42)
    return room(b, decay=0.12, mix=0.1)


def hit():
    # A blow landing on armour: the thud, the strike, the plate knocked and stopped.
    b = mix(thud(150.0, 45.0, 0.3, click=0.8, drive=3.0),
            burst(0.08, 250.0, 5000.0, decay=0.02) * 0.6,
            knock([480.0, 860.0, 1390.0, 2100.0], [0.045, 0.03, 0.02, 0.012], [1.0, 0.6, 0.35, 0.2]) * 0.5)
    return room(b, decay=0.16, mix=0.14)


def hit_crit():
    # The same, bigger: deeper, longer, a second knock in its tail, a servo giving way.
    b = mix(thud(170.0, 38.0, 0.5, click=1.0, drive=4.0),
            burst(0.12, 200.0, 6000.0, decay=0.03) * 0.7,
            knock([420.0, 760.0, 1240.0, 1900.0, 2700.0], [0.07, 0.045, 0.03, 0.02, 0.012], [1.0, 0.6, 0.45, 0.3, 0.2]) * 0.55)
    b = at(b, thud(130.0, 40.0, 0.2, click=0.4, drive=2.0) * 0.5, 0.11)
    b = at(b, servo(1200.0, 300.0, 0.3, 0.2), 0.14)
    return room(b, decay=0.24, mix=0.16)


def block():
    # Struck plate holding: a dull knock, stopped fast, the casing behind it.
    b = mix(knock([380.0, 640.0, 1010.0, 1480.0], [0.05, 0.035, 0.022, 0.014], [1.0, 0.7, 0.45, 0.25], noise_gain=0.5) * 0.9,
            burst(0.05, 500.0, 3500.0, decay=0.015) * 0.5,
            body(240.0, 100.0, 0.08, click=0.5) * 0.5)
    return room(b, decay=0.12, mix=0.12)


def shield_break():
    # The shield cracking: a sharp snap, a scatter of pieces, the ground taking the weight.
    buf = mix(burst(0.04, 2000.0, 14000.0, decay=0.006) * 1.0, body(900.0, 220.0, 0.05, click=1.0, drive=3.0) * 0.6)
    for k in range(9):
        p = RNG.uniform(0.7, 1.6)
        shard = knock([2100.0 * p, 3300.0 * p], [0.018, 0.012], [0.6, 0.3], noise_gain=0.3) * 0.35
        buf = at(buf, shard, 0.03 + k * RNG.uniform(0.012, 0.03))
    buf = at(buf, thud(120.0, 40.0, 0.35, click=0.3, drive=2.5) * 0.7, 0.05)
    return room(buf, decay=0.18, mix=0.14)


def kill():
    # A machine coming apart: a deep crunch, rumble, the drive winding down, late pieces landing.
    n = n_of(0.9)
    rumble = lp(noise(n), 200.0) * env_ad(n, 0.01, 0.35) * 1.2
    buf = mix(thud(110.0, 30.0, 0.6, click=1.0, drive=4.0), burst(0.2, 150.0, 3000.0, decay=0.06) * 0.8, rumble)
    buf = at(buf, servo(900.0, 160.0, 0.55, 0.3, band=(300.0, 2600.0)), 0.08)
    for k, when in enumerate([0.28, 0.41, 0.55]):
        piece = mix(body(260.0, 90.0, 0.07, click=0.6) * 0.5, knock([980.0, 1600.0], [0.02, 0.012], [0.6, 0.3]) * 0.4)
        buf = at(buf, piece, when, gain=1.0 - k * 0.25)
    return room(buf, decay=0.28, mix=0.16)


def arrival():
    # A heavy footfall as a foe steps into the line, hydraulics settling, dust after it.
    n = n_of(0.35)
    dust = lp(noise(n), 900.0) * env_ad(n, 0.04, 0.12) * 0.25
    b = at(thud(120.0, 36.0, 0.3, click=0.5, drive=3.0, body_gain=1.3), dust, 0.06)
    b = at(b, knock([300.0, 520.0, 810.0], [0.05, 0.03, 0.02], [1.0, 0.5, 0.3]) * 0.5, 0.0)
    b = at(b, hydraulic(0.18, 1200.0, 400.0, 0.4), 0.05)
    return room(b, decay=0.2, mix=0.14)


def step():
    # A machine's footfall on the map, light: heard once a hex.
    n = n_of(0.12)
    grit = bp(noise(n), 600.0, 3500.0) * env_ad(n, 0.002, 0.03) * 0.3
    return room(mix(thud(160.0, 55.0, 0.11, click=0.5, drive=2.0) * 0.8, grit), decay=0.1, mix=0.1)


def resolve():
    # A lever pulled over and latched: the travel, then the heavy engagement.
    travel = hydraulic(0.26, 400.0, 1600.0, 0.45, floor=250.0)
    latch = mix(thud(160.0, 48.0, 0.25, click=1.0, drive=3.5), knock([620.0, 1050.0], [0.035, 0.02], [0.5, 0.3]) * 0.5)
    b = at(travel, ratchet(4, 0.16, 1800.0, 0.35), 0.03)
    return room(at(b, latch, 0.24), decay=0.18, mix=0.12)


def contact():
    # The alarm: a low industrial horn, a stack with an undertone, saturated, swelling and cut.
    n = n_of(0.62)
    t = t_of(n)
    horn = mix(saws(82.5, n, (0.992, 1.0, 1.008)) * 0.7,
               harmonics(110.0, n, [0.6, 0.5, 0.4, 0.3, 0.2, 0.15]) * 0.6,
               np.sin(2.0 * math.pi * 55.0 * t) * 0.35)
    horn = lp(sat(horn, 3.0), 2200.0) * env_ad(n, 0.06, 0.5, curve=2.0)
    env = np.ones(n)
    env[-n_of(0.05):] = np.linspace(1.0, 0.0, n_of(0.05))
    return room(mix(horn * env, thud(90.0, 40.0, 0.3, click=0.2, drive=2.0) * 0.4), decay=0.3, mix=0.14)


def engage():
    # The dive: the display's drive spinning down, a wash rising under it, until the cut.
    n = n_of(2.2)
    t = t_of(n)
    f = 420.0 * np.exp(-t / 0.9) + 38.0
    ph = 2.0 * math.pi * np.cumsum(f) / SR
    drive = np.sin(ph) + 0.35 * np.sin(2.0 * ph) + 0.2 * (2.0 * ((ph / (2.0 * math.pi)) % 1.0) - 1.0)
    drive = lp(sat(drive, 2.0), 1400.0) * (0.5 + 0.5 * np.exp(-t / 1.2))
    wash = lp_var(noise(n), 600.0 + 2400.0 * (t / 2.2) ** 2) * (t / 2.2) ** 1.5 * 0.8
    b = mix(drive * 0.6, wash)
    b = at(b, servo(600.0, 2400.0, 1.6, 0.12), 0.5)
    return room(b, decay=0.3, mix=0.12)


def cut():
    # The cut to black at the handover: one hard boom, close.
    n = n_of(0.6)
    rumble = lp(noise(n), 160.0) * env_ad(n, 0.005, 0.25) * 1.0
    return room(mix(thud(90.0, 28.0, 0.6, click=1.0, drive=4.0, body_gain=1.2), rumble), decay=0.3, mix=0.14)


def gate_hit():
    # The gate struck: a huge slow boom, the structure groaning after it.
    n = n_of(1.6)
    t = t_of(n)
    groan = saws(58.0, n, (0.99, 1.0, 1.01)) * (1.0 + 0.1 * np.sin(2.0 * math.pi * 1.3 * t)) * env_ad(n, 0.15, 0.6) * 0.5
    groan = lp(sat(groan, 2.5), 1100.0)
    rumble = lp(noise(n), 110.0) * env_ad(n, 0.01, 0.5) * 1.3
    b = mix(thud(70.0, 22.0, 1.0, click=0.8, drive=4.0, body_gain=1.3) * 1.2, rumble, groan, burst(0.15, 120.0, 2200.0, decay=0.05) * 0.5)
    for k, when in enumerate([0.5, 0.75, 1.1]):
        b = at(b, knock([340.0, 610.0, 900.0], [0.05, 0.035, 0.02], [1.0, 0.5, 0.3]) * 0.3, when, gain=1.0 - 0.25 * k)
    return room(b, decay=0.45, mix=0.18)


def spawn():
    # The rift: a swell rising from nothing to a low pulse, a wash of static over it.
    n = n_of(1.3)
    t = t_of(n)
    swell = mix(np.sin(2.0 * math.pi * 44.0 * t) * 0.5, harmonics(88.0, n, [0.5, 0.3, 0.35, 0.3, 0.25, 0.2, 0.15]) * 0.8,
                saws(176.0, n, (0.99, 1.0, 1.01)) * 0.3) * (t / 1.3) ** 2.5
    swell = lp(sat(swell, 3.0), 1600.0)
    static = bp(noise(n), 1000.0, 7000.0) * (t / 1.3) ** 3 * 0.5
    end = thud(110.0, 36.0, 0.5, click=0.6, drive=3.0, body_gain=1.3) * 0.8
    return room(at(mix(swell, static), end, 1.05), decay=0.3, mix=0.14)


def victory():
    # The stand held: a low power chord with a slow front, industrial, let ring.
    n = n_of(1.8)
    chord = np.zeros(n)
    for f, a in [(82.4, 1.0), (123.5, 0.7), (164.8, 0.5), (247.0, 0.3)]:
        chord += saws(f, n, (0.995, 1.0, 1.005)) * a
    chord += np.sin(2.0 * math.pi * 41.2 * t_of(n)) * 0.3   # the undertone
    chord = lp(sat(chord, 2.0), 2400.0) * env_ad(n, 0.12, 0.7, curve=2.5)
    return room(mix(chord, thud(120.0, 40.0, 0.5, click=0.5, drive=3.0) * 0.6), decay=0.5, mix=0.18)


def defeat():
    # The line broken: a low drone sinking, then the last thing to fall.
    n = n_of(1.9)
    t = t_of(n)
    f = 70.0 * np.exp(-t / 1.6) + 26.0
    ph = 2.0 * math.pi * np.cumsum(f) / SR
    drone_ = np.sin(ph) + 0.4 * np.sin(ph * 1.5) + 0.3 * (2.0 * ((ph / (2.0 * math.pi)) % 1.0) - 1.0) + 0.25 * np.sin(ph * 3.0)
    drone_ = lp(sat(drone_, 2.5), 900.0) * env_ad(n, 0.05, 1.0, curve=2.0)
    return room(at(drone_, thud(100.0, 30.0, 0.5, click=0.6, drive=3.5) * 0.9, 1.35), decay=0.5, mix=0.18)


def withdraw():
    # Pulling out: hydraulics retreating, a door coming down behind the machines.
    b = hydraulic(0.7, 1400.0, 500.0, 0.45)
    b = at(b, servo(1500.0, 700.0, 0.4, 0.15), 0.1)
    return room(at(b, thud(140.0, 42.0, 0.35, click=0.8, drive=3.0), 0.55), decay=0.3, mix=0.14)


def overheat():
    # A machine burning: the crackle of it, and a warning tone twice under it.
    n = n_of(0.9)
    t = t_of(n)
    crackle = bp(noise(n), 2000.0, 9000.0) * (0.4 + 0.6 * (RNG.uniform(0.0, 1.0, n) > 0.985)) * env_ad(n, 0.02, 0.4) * 0.5
    crackle = lp(crackle, 7000.0)
    tone = lp(sat(saws(220.0, n_of(0.14), (0.99, 1.0, 1.01)) + np.sin(2.0 * math.pi * 110.0 * t_of(n_of(0.14))) * 0.5, 2.5), 1800.0) * env_ad(n_of(0.14), 0.01, 0.06) * 0.6
    b = at(crackle, tone, 0.02)
    b = at(b, tone, 0.24)
    b = at(b, knock([760.0, 1240.0], [0.02, 0.012]) * 0.3, 0.45)
    return room(b, decay=0.2, mix=0.12)


# ---------------------------------------------------------------- music
# Two loops in one kit, each 16 bars in sections. A bar is 16 steps. In a drum pattern `x`
# is a hit, `o` a softer one, `r` a roll of three in the step, `.` a rest; a pattern may be
# 16 or 32 steps long (a two-bar figure). A bass riff is semitones above E2 (82.4 Hz): a
# digit, `a`..`f` for 10..17, `g` and `h` for -2 and -5; `-` holds the note, `.` rests. An
# arp pattern indexes the section's chord (0 root, 1, 2, 3 the octave), `.` rests. Loops
# are rendered wrapped, so tails cross the seam and it plays round.

E2 = 82.41
NOTE = {"a": 10, "b": 11, "c": 12, "d": 14, "e": 15, "f": 17, "g": -2, "h": -5}


def kick_drum():
    # Sub under a knock at 200 Hz: the knock is what a phone plays.
    return mix(thud(150.0, 46.0, 0.3, click=0.9, drive=3.0, body_gain=1.2),
               body(260.0, 130.0, 0.08, drive=2.5, click=0.2) * 0.8)


def snare_drum():
    n = n_of(0.22)
    tone = harmonics(190.0, n, [1.0, 0.4, 0.2]) * env_ad(n, 0.001, 0.05) * 0.6
    b = mix(burst(0.22, 180.0, 7500.0, decay=0.05) * 0.9, tone, body(300.0, 140.0, 0.06, click=0.5) * 0.4)
    return room(b, decay=0.1, mix=0.18, cut=7000.0)


def hat(open_=False):
    return burst(0.28 if open_ else 0.045, 5500.0, 13000.0, decay=0.09 if open_ else 0.012) * 0.35


def knock_perc():
    # The percussion that was a clank: a casing tapped, dead at once.
    return knock([740.0, 1180.0, 1660.0], [0.03, 0.02, 0.012], [1.0, 0.5, 0.3], noise_gain=0.5) * 0.6


def tick():
    return ratchet(1, 0.008, 3000.0, 0.5) * 0.5


def bass_note(freq, dur, drive=3.0, cutoff=900.0, res=0.8):
    # Three detuned saws, a sub, an undertone an octave down, through a resonant filter that
    # closes over the note.
    n = n_of(dur)
    t = t_of(n)
    x = saws(freq, n, (0.995, 1.0, 1.005)) + np.sin(2.0 * math.pi * freq * t) * 0.35 + np.sin(2.0 * math.pi * freq * 0.5 * t) * 0.1
    x = sat(x, drive)
    cut = cutoff * (0.7 + 1.6 * np.exp(-t / (dur * 0.35)))
    x = svf(x, cut, res)
    env = env_ad(n, 0.004, dur * 0.7, curve=2.0)
    r = n_of(0.015)
    env[-r:] *= np.linspace(1.0, 0.0, r)
    return x * env


def pad_chord(semis, n, cutoff=700.0, gain=0.12, octave=1):
    # A stack of detuned saws with a harmonics layer over each note, a slow swell in the
    # filter: the overtones under the loop.
    t = t_of(n)
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        x += saws(f, n, (0.993, 1.0, 1.007)) * 0.5 + harmonics(f, n, [0.6, 0.0, 0.3, 0.0, 0.15]) * 0.4
    x /= max(1, len(semis))
    lfo = 0.8 + 0.2 * np.sin(2.0 * math.pi * 0.07 * t + RNG.uniform(0.0, 6.0))
    return lp(sat(x, 1.6), cutoff) * lfo * gain


def arp_note(freq, dur):
    n = n_of(dur)
    t = t_of(n)
    pulse = np.where((freq * t) % 1.0 < 0.28, 1.0, -1.0) * 0.6 + np.sin(2.0 * math.pi * freq * 2.0 * t) * 0.2
    return bp(sat(pulse, 1.5), 300.0, 3500.0) * env_ad(n, 0.003, dur * 0.35)


def machine_swell(dur):
    return mix(hydraulic(dur, 400.0, 1800.0, 0.5), at(np.zeros(1), servo(700.0, 1500.0, dur * 0.7, 0.18), dur * 0.15))


def _steps(form, part, default="."):
    """The whole loop's step string for a part: the section's pattern per bar."""
    out = []
    for bar, sec in enumerate(form):
        pat = part.get(sec, part.get("*", default * 16))
        out.append("".join(pat[(bar * 16 + i) % len(pat)] for i in range(16)))
    return "".join(out)


def groove(bpm, form, drums, riffs, chords, arps, drive, cutoff, pad_gain, pad_cut, swells=(), hat_gain=1.0):
    form = form.replace(" ", "")
    bars = len(form)
    step_s = 60.0 / bpm / 4.0
    n = int(round(bars * 16 * step_s * SR))
    buf = np.zeros(n)
    kit = {"kick": kick_drum(), "snare": snare_drum(), "hat": hat(False), "open": hat(True), "knock": knock_perc(), "tick": tick()}
    gains = {"kick": 1.0, "snare": 1.1, "hat": 0.8 * hat_gain, "open": 0.7 * hat_gain, "knock": 0.8, "tick": 0.35}
    for name, part in drums.items():
        s = _steps(form, part)
        for i, c in enumerate(s):
            when = i * step_s
            if c == "x":
                buf = at(buf, kit[name], when, gains[name] * (1.0 if name != "hat" or i % 4 == 0 else 0.7), wrap=True)
            elif c == "o":
                buf = at(buf, kit[name], when, gains[name] * 0.45, wrap=True)
            elif c == "r":
                for j in range(3):
                    buf = at(buf, kit[name], when + j * step_s / 3.0, gains[name] * 0.55, wrap=True)
    # The riff: a note holds through `-` steps, across bars too.
    s = _steps(form, riffs)
    i = 0
    while i < len(s):
        c = s[i]
        if c in ".-":
            i += 1
            continue
        semis = int(c) if c.isdigit() else NOTE[c]
        length = 1
        while i + length < len(s) and s[i + length] == "-":
            length += 1
        freq = E2 * 2.0 ** (semis / 12.0)
        buf = at(buf, bass_note(freq, length * step_s * 0.95, drive, cutoff), i * step_s, 0.6, wrap=True)
        i += length
    # The pad: one chord a section, held while the section runs, with a slow front.
    bar_n = int(round(16 * step_s * SR))
    start = 0
    while start < bars:
        end = start
        while end < bars and form[end] == form[start]:
            end += 1
        semis = chords.get(form[start], chords.get("*"))
        if semis:
            pad = pad_chord(semis, bar_n * (end - start), pad_cut, pad_gain)
            pad *= env_pts(len(pad), [(0.0, 0.0), (0.4, 1.0), (len(pad) / SR - 0.3, 1.0), (len(pad) / SR, 0.0)])
            buf = at(buf, pad, start * 16 * step_s, 1.0, wrap=True)
        start = end
    # The arp: a texture on the chord, with an echo a dotted eighth later.
    s = _steps(form, arps)
    for i, c in enumerate(s):
        if not c.isdigit():
            continue
        semis = chords.get(form[i // 16], chords.get("*"))
        k = int(c)
        f = E2 * 2.0 ** ((semis[k % len(semis)] + 12 * (k // len(semis)) + 24) / 12.0)
        note = arp_note(f, step_s * 1.6)
        buf = at(buf, note, i * step_s, 0.4, wrap=True)
        buf = at(buf, note, (i + 3) * step_s, 0.18, wrap=True)
    for bar in swells:
        buf = at(buf, machine_swell(16 * step_s * 0.9), bar * 16 * step_s, 0.35, wrap=True)
    r = room(buf, decay=0.12, mix=0.06, cut=6000.0)
    buf = r[:n]
    buf[: len(r) - n] += r[n:]   # the room's tail wraps to the top, so the seam is seamless
    buf = shelf(buf, 700.0, 4.0)   # the master's tilt: the mids and highs up, for the phone
    return sat(buf, 1.25)


def music_map():
    # Subdued, still moving: four to the floor but light, the snare on two and four, hats
    # ticking, a knock a bar, the riff sparse and low. Sixteen bars: two of the plain groove,
    # a lift with the arp, a breakdown where the kick drops out, and a build back.
    return groove(
        bpm=92,
        form="AAAB AACB DDDB AACE",
        drums={
            "kick": {"A": "x...o...x.....o.x...o...x...o.o.", "B": "x...o...x.....o.x...o...x...x.x.",
                     "C": "x...o...x..o..o.x...o...x...o.o.", "D": "................", "E": "x...x...x...x...x.x.x.x.xxxxxxxx"},
            "snare": {"A": "....x.......x...", "B": "....x.......x..o....x.......r.r.",
                      "C": "....x.......x.o.", "D": "............o...", "E": "....x.......x...........rrrrrrrr"},
            "hat": {"A": "x.x.x.x.x.x.x.x.", "B": "x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.r.",
                    "C": "xxx.x.xxx.x.xxx.", "D": "x...x...x...x...", "E": "x.x.x.x.x.x.x.x.xxxxxxxxxxxxxxxx"},
            "open": {"A": "..........x.....", "C": "......x.......x.", "E": "..............x."},
            "knock": {"A": "......x.........", "C": "..x.....x..x....", "D": "......x.......x.", "E": "......x...x...x."},
            "tick": {"A": "xxxxxxxxxxxxxxxx", "C": "xxxxxxxxxxxxxxxx", "D": "xxxxxxxxxxxxxxxx"},
        },
        riffs={"A": "0--.3-.0-...1-..0--.3-.g-...0-..", "B": "0--.3-.0-...1-..0--.3-.g-..h0-..",
               "C": "0--.3-.5-..3.1-.0--.3-.7-..5.3-.", "D": "0---------------8-------7-------",
               "E": "0-.0-.0-.3-.5-..0-.0-.0-.7-.c-.."},
        chords={"A": [0, 7, 15], "B": [0, 7, 15], "C": [8, 15, 19], "D": [10, 17, 22], "E": [7, 14, 22]},
        arps={"C": "0.2.1.3.0.2.1.2.", "D": "0...2...1...3...0...2...3...1...", "E": "0.1.2.3.0.1.2.3."},
        drive=2.2, cutoff=650.0, pad_gain=0.24, pad_cut=900.0, swells=(8,), hat_gain=0.8)


def music_skirmish():
    # Driving: the kick pushes, the snare answers with ghosts, trap hats with rolls, knocks
    # on the offbeats, the riff busier and dirtier with the octave jump. Sixteen bars: the
    # groove, a lift with the arp and open hats, a half-time drop, and the build.
    return groove(
        bpm=100,
        form="AAAB CCCB DDDB AACE",
        drums={
            "kick": {"A": "x..x..x...x.x...x..x..x.x...x.o.", "B": "x..x..x...x.x...x..x..x.x.x.x.x.",
                     "C": "x..x..x...x.x..ox..x..x.x...x.o.", "D": "x.......x.....x.x.......x..x....", "E": "x...x...x...x...x.x.x.x.x.x.xxxx"},
            "snare": {"A": "....x..o....x...", "B": "....x..o....x.......x..o..o.r.r.",
                      "C": "....x..o....x..o", "D": "........x.......", "E": "....x.......x...rrrr....rrrrrrrr"},
            "hat": {"A": "x.x.x.x.xxx.x.x.x.x.x.rrx.x.x.x.", "B": "x.x.x.x.xxx.x.x.x.x.x.x.r.x.r.r.",
                    "C": "xxxxxxxxxxxxxxxx", "D": "x...x.x.x...x.x.", "E": "x.x.x.x.x.x.x.x.xxxxxxxxxxxxxxxx"},
            "open": {"A": "......x.......x.", "C": "..x...x...x...x.", "D": "..............x.", "E": "......x.......x."},
            "knock": {"A": "..x...x...x...x.", "C": "..x...x...x...x.", "D": "..x.......x.....", "E": "..x...x...x...x."},
            "tick": {"C": "xxxxxxxxxxxxxxxx", "D": "xxxxxxxxxxxxxxxx"},
        },
        riffs={"A": "00.c.0-3.00.1-.g00.c.0-3.00.h-..", "B": "00.c.0-3.00.1-.g00.c.0-3.5-.7-.c",
               "C": "0-.c.0-3.0-.5-.30-.c.0-3.8-.7-.5", "D": "0-------3-------g-------0---..3-",
               "E": "0-.0-.0-.c-.0-.30-.0-.0-.c-.d-.e"},
        chords={"A": [0, 7, 15], "B": [0, 7, 15], "C": [8, 15, 19], "D": [-2, 5, 10], "E": [7, 14, 22]},
        arps={"C": "0.1.2.1.3.2.1.0.", "D": "0.......2.......1.......3.......", "E": "0.1.2.3.2.1.0.1."},
        drive=3.5, cutoff=1100.0, pad_gain=0.2, pad_cut=1100.0, swells=(12,), hat_gain=0.9)


SOUNDS = {
    "ui_tap": ui_tap, "ui_back": ui_back, "plot": plot,
    "codex_open": codex_open, "codex_close": codex_close, "menu_open": menu_open,
    "die_pick": die_pick, "die_drop": die_drop, "die_roll": die_roll, "die_lock": die_lock,
    "shield_up": shield_up, "vent": vent,
    "hit": hit, "hit_crit": hit_crit, "block": block, "shield_break": shield_break, "kill": kill,
    "arrival": arrival, "step": step, "resolve": resolve,
    "contact": contact, "engage": engage, "cut": cut, "gate_hit": gate_hit, "spawn": spawn,
    "victory": victory, "defeat": defeat, "withdraw": withdraw, "overheat": overheat,
    "music_map": music_map, "music_skirmish": music_skirmish,
}

## The mix: each sound's loudness (its loudest 50 ms, RMS dB). The music sits under the
## blows; the taps are far under both; the gate and the cut are the biggest things.
LEVELS = {
    "ui_tap": -22, "ui_back": -24, "plot": -20, "codex_open": -18, "codex_close": -18, "menu_open": -15,
    "die_pick": -20, "die_drop": -17, "die_roll": -16, "die_lock": -19, "shield_up": -14, "vent": -15,
    "hit": -12, "hit_crit": -10, "block": -14, "shield_break": -11, "kill": -9,
    "arrival": -13, "step": -22, "resolve": -13,
    "contact": -10, "engage": -13, "cut": -8, "gate_hit": -8, "spawn": -12,
    "victory": -10, "defeat": -10, "withdraw": -11, "overheat": -12,
    "music_map": -17, "music_skirmish": -16,
}


def read(name):
    with wave.open(os.path.join(OUT, name + ".wav"), "rb") as w:
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2") / 32767.0
        return x, w.getframerate()


def main(argv):
    if len(argv) < 1 or argv[0] not in ("build", "list", "measure"):
        print(__doc__)
        return 2
    if argv[0] == "list":
        for name in SOUNDS:
            print(name)
        return 0
    if argv[0] == "measure":
        print("%-16s %6s %8s %8s %6s" % ("name", "dur", "loud dB", "peak dB", "<150Hz"))
        for name in argv[1:] or list(SOUNDS):
            x, sr = read(name)
            print("%-16s %6.2f %8.1f %8.1f %6.2f" % (name, len(x) / sr, loudness(x), 20.0 * math.log10(np.max(np.abs(x)) + 1e-9), low_share(x)))
        return 0
    names = argv[1:] or list(SOUNDS)
    for name in names:
        if name not in SOUNDS:
            print("no such sound:", name)
            return 1
        seed(name)
        x = SOUNDS[name]()
        path = write(name, x, LEVELS[name])
        print("%-16s %5.2f s  %s" % (name, len(x) / SR, os.path.relpath(path)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
