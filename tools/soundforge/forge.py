"""Every sound the game plays, built from a written recipe, the way lowforge builds the
models. The direction (bible, 22 September): grounded and heavy, weight and machinery,
nothing that sounds like a space opera; the music an industrial groove, driving but not
fast, more bop than pummel. These are placeholders in that register, to be replaced by
real recordings and a real track when there are some. numpy only.

    tools/spriter/.venv/bin/python tools/soundforge/forge.py build            # everything into art/audio
    tools/spriter/.venv/bin/python tools/soundforge/forge.py build hit kill   # some
    tools/spriter/.venv/bin/python tools/soundforge/forge.py list
    tools/spriter/.venv/bin/python tools/soundforge/forge.py measure          # level and balance of every file
    tools/spriter/.venv/bin/python tools/soundforge/forge.py sketch [human rift djent]   # eight bars in a direction, to tools/soundforge/out
    tools/spriter/.venv/bin/python tools/soundforge/forge.py sections                    # every section of both loops, with timestamps
    tools/spriter/.venv/bin/python tools/soundforge/forge.py audition                    # every effect in one file, a second apart, to tools/soundforge/out

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
  - The loops are 32 bars in sections, not a two-bar phrase repeated, with a long interlude,
    on a kit each (the map slower, rim and brushed hats; the skirmish kick, snare, clank and
    stabs) over a shared pad and bass. Never a build, a bass drop or a speed snare.
  - A little metal is allowed, at low gain and gone in a tenth of a second; the crunch bass
    of the first cut came back.
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


def low_shelf(x, freq, gain_db):
    """A gentle low shelf: `gain_db` below `freq`, flat above."""
    g = 10.0 ** (gain_db / 20.0)
    return _filter(x, lambda f: 1.0 + (g - 1.0) * (freq ** 2 / (f ** 2 + freq ** 2)))


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


def metal(gain=0.2, pitch=1.0):
    """The little metal allowed (Ryan, 23 September): inharmonic partials that die in a
    tenth of a second, band-limited, under a blow at low gain. Never a cowbell."""
    k = knock([1180.0 * pitch, 1930.0 * pitch, 2760.0 * pitch], [0.08, 0.055, 0.04], [1.0, 0.5, 0.3], noise_gain=0.0)
    return bp(k, 600.0, 6000.0) * gain


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


def mean_level(x):
    """The whole file's RMS dB: a loop's level, so its drums cannot pull its body down."""
    return 20.0 * math.log10(math.sqrt(float(np.mean(x ** 2))) + 1e-9)


def write(name, x, level):
    # An effect is levelled by its loudest 50 ms; a loop by its body (Ryan, 24 September:
    # a louder kick had dragged the rest of the map down under the peak rule).
    x = x * 10.0 ** ((level - (mean_level(x) if name.startswith("music_") else loudness(x))) / 20.0)
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
# Two registers (Ryan, 23 September). The interface is sci-fi electronic: beeps and boops,
# StarCraft's menu pushed a little toward comedy, never a Doom or Quake menu. Combat and
# the map are over-the-top weighty: lasers, gunfire, explosions and melee of various kinds,
# with Doom levels of punch, for both sides.

def blip(f0, f1=None, dur=0.05, width=0.5, attack=0.002, decay=None, gain=1.0):
    """A pulse wave gliding from f0 to f1: the interface's voice."""
    n = n_of(dur)
    t = t_of(n)
    f1 = f1 or f0
    f = f0 * (f1 / f0) ** (t / dur)
    ph = np.cumsum(f) / SR
    x = np.where(ph % 1.0 < width, 1.0, -1.0) * 0.7 + np.sin(2.0 * math.pi * ph) * 0.3
    return lp(x, 7000.0) * env_ad(n, attack, decay or dur * 0.5, curve=3.0) * gain


def chirp(notes, gap=0.0, gain=1.0):
    """A sequence of blips: [(f0, f1, dur), ...] one after another."""
    buf = np.zeros(1)
    when = 0.0
    for f0, f1, dur in notes:
        buf = at(buf, blip(f0, f1, dur), when, gain)
        when += dur + gap
    return buf


def tick_click():
    return bp(noise(n_of(0.012)), 2500.0, 9000.0) * env_ad(n_of(0.012), 0.0002, 0.002) * 0.5


def zap(f0, f1, dur, gain=1.0):
    """An energy discharge: a saw stack falling fast, saturated, with a sizzle."""
    n = n_of(dur)
    t = t_of(n)
    f = f0 * (f1 / f0) ** (t / dur)
    ph = 2.0 * math.pi * np.cumsum(f) / SR
    x = (2.0 * ((ph / (2.0 * math.pi)) % 1.0) - 1.0) * 0.7 + np.sin(ph * 2.0) * 0.4 + np.sin(ph * 3.01) * 0.25
    sizzle = hp(noise(n), 2500.0) * env_ad(n, 0.001, dur * 0.4) * 0.35
    return lp(sat(x + sizzle, 3.0), 6000.0) * env_ad(n, 0.001, dur * 0.45, curve=2.5) * gain


def explosion(dur=1.1, low=28.0, gain=1.0, debris=3):
    """The big one: a hard front, a body, a rumble, the crack of the air, pieces landing."""
    n = n_of(dur)
    front = mix(thud(160.0, low, dur * 0.7, click=1.2, drive=4.0, body_gain=1.5),
                burst(dur * 0.35, 120.0, 5000.0, decay=dur * 0.08) * 1.0,
                lp(noise(n), 220.0) * env_ad(n, 0.005, dur * 0.4) * 1.3,
                bp(noise(n_of(0.05)), 2000.0, 9000.0) * env_ad(n_of(0.05), 0.0002, 0.006) * 0.8)
    buf = front
    for k in range(debris):
        when = 0.22 + k * RNG.uniform(0.09, 0.16)
        piece = mix(body(RNG.uniform(220.0, 340.0), 90.0, 0.07, click=0.6) * 0.5,
                    knock([RNG.uniform(700.0, 1300.0), RNG.uniform(1500.0, 2400.0)], [0.03, 0.02], [0.6, 0.3]) * 0.4)
        buf = at(buf, piece, when, gain=1.0 - k * 0.2)
    return room(buf, decay=0.35, mix=0.2) * gain


# ---- the interface

def ui_tap():
    # A two-tone blip with a click on its front.
    return mix(chirp([(1100.0, 1500.0, 0.028), (1500.0, 1500.0, 0.03)], gain=0.8), tick_click())


def ui_back():
    # The same going down.
    return mix(chirp([(1400.0, 1000.0, 0.03), (900.0, 760.0, 0.04)], gain=0.7), tick_click() * 0.7)


def plot():
    # Three notes climbing, quick, and a data tick: the route is accepted.
    return mix(chirp([(700.0, 760.0, 0.035), (950.0, 1000.0, 0.035), (1300.0, 1450.0, 0.06)], gain=0.8),
               at(np.zeros(1), tick_click() * 0.6, 0.11))


def codex_open():
    # A rising sweep chopped into pulses, then a confirm: the plate slides out of the console.
    n = n_of(0.2)
    t = t_of(n)
    sweep_ = blip(300.0, 2400.0, 0.2, width=0.35, decay=0.4) * (0.55 + 0.45 * np.sign(np.sin(2.0 * math.pi * 38.0 * t)))
    return at(sweep_ * 0.7, chirp([(1600.0, 1900.0, 0.05)]) * 0.7, 0.19)


def codex_close():
    n = n_of(0.16)
    t = t_of(n)
    sweep_ = blip(2200.0, 320.0, 0.16, width=0.35, decay=0.3) * (0.55 + 0.45 * np.sign(np.sin(2.0 * math.pi * 44.0 * t)))
    return at(chirp([(1400.0, 1100.0, 0.04)]) * 0.6, sweep_ * 0.6, 0.03)


def menu_open():
    # The console powering up: a low hum swelling, four blips climbing over it.
    n = n_of(0.5)
    hum = lp(sat(saws(110.0, n, (0.995, 1.0, 1.005)), 1.5), 900.0) * env_pts(n, [(0.0, 0.0), (0.08, 0.6), (0.3, 0.5), (0.5, 0.0)]) * 0.5
    arp = chirp([(660.0, 660.0, 0.05), (880.0, 880.0, 0.05), (1100.0, 1100.0, 0.05), (1320.0, 1500.0, 0.09)], gap=0.01, gain=0.6)
    return at(hum, arp, 0.06)


def die_pick():
    # A bright bip rising: the die lifts off the display.
    return mix(chirp([(1500.0, 2300.0, 0.04)], gain=0.7), tick_click() * 0.6)


def die_drop():
    # A lower boop, and a soft set-down.
    return mix(chirp([(800.0, 520.0, 0.07)], gain=0.7), body(240.0, 100.0, 0.06, click=0.3) * 0.35)


def die_lock():
    # Two tones confirming, and the click.
    return mix(chirp([(880.0, 880.0, 0.045), (1320.0, 1320.0, 0.07)], gap=0.01, gain=0.75), tick_click())


def die_roll():
    # The display computing: a run of random blips, quick, settling on a low boop.
    buf = np.zeros(n_of(0.42))
    when = 0.0
    for k in range(9):
        f = RNG.choice([660.0, 880.0, 1100.0, 1320.0, 1760.0, 2200.0])
        buf = at(buf, blip(f, f * RNG.uniform(0.9, 1.15), 0.03, decay=0.012), when, 0.55)
        when += RNG.uniform(0.028, 0.045)
    return at(buf, chirp([(600.0, 440.0, 0.09)]) * 0.7, when + 0.02)


def resolve():
    # The plan committed: a descending run, a low confirm swelling under it, and the
    # console's heavy latch so it still has weight.
    run = chirp([(1760.0, 1760.0, 0.04), (1320.0, 1320.0, 0.04), (1100.0, 1100.0, 0.04), (880.0, 700.0, 0.12)], gap=0.005, gain=0.7)
    n = n_of(0.45)
    swell = lp(sat(saws(82.4, n, (0.996, 1.0, 1.004)) + np.sin(2.0 * math.pi * 164.8 * t_of(n)) * 0.5, 2.0), 1200.0) * env_pts(n, [(0.0, 0.0), (0.1, 0.7), (0.3, 0.6), (0.45, 0.0)]) * 0.5
    b = at(run, swell, 0.1)
    return room(at(b, thud(160.0, 48.0, 0.25, click=1.0, drive=3.5) * 0.7, 0.2), decay=0.18, mix=0.12)


def engage():
    # The dive: the display's drive spinning down, a wash rising under it, three beeps
    # counting in faster and faster, until the cut.
    n = n_of(2.2)
    t = t_of(n)
    f = 420.0 * np.exp(-t / 0.9) + 38.0
    ph = 2.0 * math.pi * np.cumsum(f) / SR
    drive = np.sin(ph) + 0.35 * np.sin(2.0 * ph) + 0.2 * (2.0 * ((ph / (2.0 * math.pi)) % 1.0) - 1.0)
    drive = lp(sat(drive, 2.0), 1400.0) * (0.5 + 0.5 * np.exp(-t / 1.2))
    wash = lp_var(noise(n), 600.0 + 2400.0 * (t / 2.2) ** 2) * (t / 2.2) ** 1.5 * 0.8
    b = mix(drive * 0.6, wash)
    for k, when in enumerate([0.9, 1.45, 1.8, 2.02]):
        b = at(b, blip(1200.0 + 150.0 * k, 1200.0 + 150.0 * k, 0.06), when, 0.4)
    return room(b, decay=0.3, mix=0.12)


def contact():
    # The alarm: the low industrial horn, and a klaxon beeping twice over it.
    n = n_of(0.62)
    t = t_of(n)
    horn = mix(saws(82.5, n, (0.992, 1.0, 1.008)) * 0.7,
               harmonics(110.0, n, [0.6, 0.5, 0.4, 0.3, 0.2, 0.15]) * 0.6,
               np.sin(2.0 * math.pi * 55.0 * t) * 0.35)
    horn = lp(sat(horn, 3.0), 2200.0) * env_ad(n, 0.06, 0.5, curve=2.0)
    env = np.ones(n)
    env[-n_of(0.05):] = np.linspace(1.0, 0.0, n_of(0.05))
    b = mix(horn * env, thud(90.0, 40.0, 0.3, click=0.2, drive=2.0) * 0.4)
    b = at(b, blip(1800.0, 1800.0, 0.12, width=0.5, decay=0.1), 0.05, 0.3)
    b = at(b, blip(1800.0, 1800.0, 0.12, width=0.5, decay=0.1), 0.3, 0.3)
    return room(b, decay=0.3, mix=0.14)


def cut():
    # The cut to black at the handover: one hard boom, close.
    return explosion(0.7, 26.0, 1.0, debris=0)


# ---- combat and the map: over-the-top weighty

def laser():
    # An energy weapon: the discharge falling from a scream to a growl, the beam's sizzle,
    # and the hit on armour under it.
    b = zap(2600.0, 220.0, 0.16, 1.0)
    b = at(b, mix(thud(150.0, 45.0, 0.28, click=0.6, drive=3.0), burst(0.1, 300.0, 5000.0, decay=0.03) * 0.5), 0.05, 0.9)
    b = at(b, hp(noise(n_of(0.25)), 4000.0) * env_ad(n_of(0.25), 0.001, 0.07) * 0.25, 0.04)
    return room(b, decay=0.2, mix=0.14)


def shot(pitch=1.0):
    return mix(thud(420.0 * pitch, 110.0 * pitch, 0.07, click=1.3, drive=4.0, body_gain=1.2),
               burst(0.04, 700.0, 7000.0, decay=0.01) * 0.9,
               bp(noise(n_of(0.015)), 3000.0, 10000.0) * env_ad(n_of(0.015), 0.0002, 0.003) * 0.8)


def gunfire():
    # A kinetic line weapon: a burst of four, the action clacking between, the last one
    # landing on armour.
    buf = np.zeros(1)
    for k in range(4):
        buf = at(buf, shot(RNG.uniform(0.94, 1.06)), k * 0.058, 1.0 - k * 0.06)
        buf = at(buf, knock([1400.0, 2300.0], [0.008, 0.005], [0.6, 0.3], noise_gain=0.4) * 0.35, k * 0.058 + 0.03)
    buf = at(buf, mix(thud(150.0, 45.0, 0.25, click=0.5, drive=3.0), knock([480.0, 860.0, 1390.0], [0.04, 0.03, 0.02], [1.0, 0.6, 0.35]) * 0.4), 0.2, 0.8)
    return room(buf, decay=0.22, mix=0.16)


def cannon():
    # One heavy shot: the crack, the shell leaving, the blast, and the shell landing as an
    # explosion of its own.
    front = mix(thud(220.0, 32.0, 0.5, click=1.4, drive=4.0, body_gain=1.5), burst(0.14, 150.0, 4000.0, decay=0.04) * 1.0,
                bp(noise(n_of(0.03)), 2000.0, 9000.0) * env_ad(n_of(0.03), 0.0002, 0.005) * 1.0)
    b = at(front, hydraulic(0.2, 3000.0, 800.0, 0.3), 0.05)
    b = at(b, explosion(0.9, 30.0, 0.9, debris=3), 0.26)
    return room(b, decay=0.3, mix=0.16)


def slash():
    # A claw or a blade: the swing's air, the rip through plate, a wet weight under it.
    n = n_of(0.12)
    t = t_of(n)
    swing = lp_var(hp(noise(n), 400.0), 7000.0 - 5500.0 * (t / 0.12)) * env_ad(n, 0.003, 0.05) * 0.6
    rip = bp(noise(n_of(0.16)), 600.0, 5000.0) * (0.5 + 0.5 * np.sign(np.sin(2.0 * math.pi * 58.0 * t_of(n_of(0.16))))) * env_ad(n_of(0.16), 0.001, 0.05) * 0.8
    b = at(swing, rip, 0.05)
    b = at(b, mix(thud(170.0, 50.0, 0.2, click=0.7, drive=3.0), knock([520.0, 940.0, 1500.0], [0.035, 0.025, 0.015], [1.0, 0.5, 0.3]) * 0.4), 0.07, 0.9)
    return room(b, decay=0.18, mix=0.14)


def slam():
    # The heavy melee: a fist, a tread, a bulk landing. The biggest thud of the set with a
    # crack of plate and a scatter of pieces.
    b = mix(thud(130.0, 30.0, 0.55, click=1.3, drive=4.0, body_gain=1.6), burst(0.15, 200.0, 5000.0, decay=0.04) * 0.9,
            knock([420.0, 760.0, 1240.0, 1900.0], [0.07, 0.045, 0.03, 0.02], [1.0, 0.6, 0.45, 0.3]) * 0.5,
            metal(0.2, 0.9))
    for k, when in enumerate([0.14, 0.24, 0.36]):
        b = at(b, knock([RNG.uniform(600.0, 1100.0), RNG.uniform(1400.0, 2200.0)], [0.025, 0.015], [0.6, 0.3]) * 0.3, when, 1.0 - 0.25 * k)
    return room(b, decay=0.28, mix=0.16)


def hit():
    # A blow landing on armour, the generic one: the thud, the strike, the plate knocked.
    b = mix(thud(150.0, 45.0, 0.3, click=1.0, drive=3.5, body_gain=1.2),
            burst(0.08, 250.0, 5000.0, decay=0.02) * 0.7,
            knock([480.0, 860.0, 1390.0, 2100.0], [0.045, 0.03, 0.02, 0.012], [1.0, 0.6, 0.35, 0.2]) * 0.5,
            metal(0.18, 0.9))
    return room(b, decay=0.16, mix=0.14)


def hit_crit():
    return slam()


def block():
    # Struck plate holding: a dull knock, stopped fast, and a ping off the deflection.
    b = mix(knock([380.0, 640.0, 1010.0, 1480.0], [0.05, 0.035, 0.022, 0.014], [1.0, 0.7, 0.45, 0.25], noise_gain=0.5) * 0.9,
            burst(0.05, 500.0, 3500.0, decay=0.015) * 0.5,
            body(240.0, 100.0, 0.08, click=0.5) * 0.6,
            metal(0.3, 1.4))
    return room(b, decay=0.12, mix=0.12)


def shield_break():
    # The shield failing: an electric crack, the field's discharge, shards, the ground
    # taking the weight.
    buf = mix(burst(0.04, 2000.0, 14000.0, decay=0.006) * 1.0, body(900.0, 220.0, 0.05, click=1.0, drive=3.0) * 0.6,
              zap(3200.0, 400.0, 0.12, 0.7))
    for k in range(9):
        p = RNG.uniform(0.7, 1.6)
        shard = knock([2100.0 * p, 3300.0 * p], [0.018, 0.012], [0.6, 0.3], noise_gain=0.3) * 0.35
        buf = at(buf, shard, 0.03 + k * RNG.uniform(0.012, 0.03))
    buf = at(buf, thud(120.0, 40.0, 0.35, click=0.3, drive=2.5) * 0.7, 0.05)
    return room(buf, decay=0.18, mix=0.14)


def shield_up():
    # The field raised: a charge climbing, then the snap of it holding, hydraulics under.
    n = n_of(0.22)
    charge = blip(200.0, 1600.0, 0.22, width=0.3, decay=0.5) * 0.35 + zap(300.0, 1400.0, 0.22, 0.25)[::-1]
    b = at(charge, mix(thud(200.0, 60.0, 0.2, click=0.9, drive=3.0), zap(2400.0, 900.0, 0.06, 0.5),
                       knock([680.0, 1120.0, 1730.0], [0.04, 0.025, 0.015], [1.0, 0.5, 0.25]) * 0.4), 0.2)
    b = at(b, hydraulic(0.2, 500.0, 1400.0, 0.3), 0.1)
    return room(b, decay=0.14, mix=0.12)


def vent():
    # Steam let go: a hard hiss that tails off, the valve knocking shut.
    n = n_of(0.55)
    hiss = bp(noise(n), 900.0, 8000.0) * env_ad(n, 0.01, 0.16) * 0.8
    b = at(hiss, mix(body(300.0, 120.0, 0.05, click=0.6) * 0.5, knock([820.0, 1300.0], [0.015, 0.01]) * 0.3), 0.42)
    return room(b, decay=0.12, mix=0.1)


def kill():
    # A machine coming apart: the explosion, the drive winding down, pieces landing late.
    buf = explosion(1.2, 26.0, 1.0, debris=4)
    buf = at(buf, servo(900.0, 160.0, 0.55, 0.3, band=(300.0, 2600.0)), 0.1)
    return buf


def arrival():
    # A foe stepping into the line: a heavy footfall, hydraulics settling, dust after it.
    n = n_of(0.35)
    dust = lp(noise(n), 900.0) * env_ad(n, 0.04, 0.12) * 0.25
    b = at(thud(120.0, 36.0, 0.35, click=0.6, drive=3.5, body_gain=1.4), dust, 0.06)
    b = at(b, knock([300.0, 520.0, 810.0], [0.05, 0.03, 0.02], [1.0, 0.5, 0.3]) * 0.5, 0.0)
    b = at(b, hydraulic(0.18, 1200.0, 400.0, 0.4), 0.05)
    return room(b, decay=0.24, mix=0.16)


def step():
    # A machine's footfall on the map, once a hex: a stomp, the hydraulics catching it.
    n = n_of(0.12)
    grit = bp(noise(n), 600.0, 3500.0) * env_ad(n, 0.002, 0.03) * 0.3
    b = mix(thud(150.0, 45.0, 0.16, click=0.7, drive=2.5, body_gain=1.2), grit)
    b = at(b, hydraulic(0.1, 900.0, 300.0, 0.2), 0.03)
    return room(b, decay=0.12, mix=0.1)


def gate_hit():
    # The gate struck: the biggest explosion of the set, the structure groaning after it.
    n = n_of(1.8)
    t = t_of(n)
    groan = saws(58.0, n, (0.99, 1.0, 1.01)) * (1.0 + 0.1 * np.sin(2.0 * math.pi * 1.3 * t)) * env_ad(n, 0.15, 0.6) * 0.5
    groan = lp(sat(groan, 2.5), 1100.0)
    b = mix(explosion(1.6, 22.0, 1.3, debris=5), groan)
    for k, when in enumerate([0.6, 0.85, 1.2]):
        b = at(b, knock([340.0, 610.0, 900.0], [0.05, 0.035, 0.02], [1.0, 0.5, 0.3]) * 0.3, when, gain=1.0 - 0.25 * k)
    return room(b, decay=0.45, mix=0.18)


def spawn():
    # The rift: a swell rising from nothing to a low pulse, a wash of static over it, the
    # thing arriving with a boom.
    n = n_of(1.3)
    t = t_of(n)
    swell = mix(np.sin(2.0 * math.pi * 44.0 * t) * 0.5, harmonics(88.0, n, [0.5, 0.3, 0.35, 0.3, 0.25, 0.2, 0.15]) * 0.8,
                saws(176.0, n, (0.99, 1.0, 1.01)) * 0.3) * (t / 1.3) ** 2.5
    swell = lp(sat(swell, 3.0), 1600.0)
    static = bp(noise(n), 1000.0, 7000.0) * (t / 1.3) ** 3 * 0.5
    return room(at(mix(swell, static), explosion(0.6, 34.0, 0.8, debris=1), 1.05), decay=0.3, mix=0.14)


def victory():
    # The stand held: a low power chord with a slow front, industrial, let ring.
    n = n_of(1.8)
    chord = np.zeros(n)
    for f, a in [(82.4, 1.0), (123.5, 0.7), (164.8, 0.5), (247.0, 0.3)]:
        chord += saws(f, n, (0.995, 1.0, 1.005)) * a
    chord += np.sin(2.0 * math.pi * 41.2 * t_of(n)) * 0.3
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
    return room(at(drone_, explosion(0.8, 28.0, 0.9, debris=2), 1.35), decay=0.5, mix=0.18)


def withdraw():
    # Pulling out: hydraulics retreating, a door coming down behind the machines.
    b = hydraulic(0.7, 1400.0, 500.0, 0.45)
    b = at(b, servo(1500.0, 700.0, 0.4, 0.15), 0.1)
    return room(at(b, thud(140.0, 42.0, 0.4, click=0.9, drive=3.5, body_gain=1.4), 0.55), decay=0.3, mix=0.14)


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
# Two loops, each 32 bars in sections, on kits of their own with a shared pad and bass
# (Ryan, 23 September: the two read too alike; the map on other instruments, some tones in
# common). A bar is 16 steps. In a drum pattern `x` is a hit, `o` a softer one, `.` a rest;
# a pattern may be any length in steps: 16 or 32 for a bar or two, 7 for a figure that
# walks round the bar (polymeter). Never a build, never a bass drop, never a speed snare
# (Ryan, the same day): a section changes by what plays, not by a roll into it.
#
# The tune is voices over chords. A section's chords are one chord or a list, one per bar,
# cycling. A voice is an instrument and a pattern: `riff` mode reads semitones above E2
# (82.4 Hz: a digit, `a`..`f` for 10..17, `g` and `h` for -2 and -5; `-` holds, `.` rests),
# `chord` mode indexes the bar's chord (0 root, 1, 2, 3 the octave up; the chimes), `stab`
# mode plays the whole chord on `x`. A pad holds each chord while it runs. Loops render
# wrapped, so every tail crosses the seam and it plays round.
#
# The instruments (Ryan, 23 September: the pulse-and-saw palette read as Loop Hero; the
# game's own ancestors are FM keys and bells (Descent, MechWarrior 2), plucked strings,
# choir and fantasy harmony (Final Fantasy), the liturgical register (40K), and the
# polymetric chug (progressive metal)): `fm`, `epiano`, `bell`, `brass`; `pluck` and
# `chug` by the Karplus-Strong string; `choir` by formants; `organ`, `strings`; the crunch
# `bass` and the `chime` and `stab` of the second cut stay available.

E2 = 82.41
NOTE = {"a": 10, "b": 11, "c": 12, "d": 14, "e": 15, "f": 17, "i": 19, "j": 22, "k": 24, "g": -2, "h": -5}


# ---- the kit

def kick_drum(hard=True):
    if hard:
        return mix(thud(150.0, 46.0, 0.3, click=0.9, drive=3.0, body_gain=1.2),
                   body(260.0, 130.0, 0.08, drive=2.5, click=0.2) * 0.8)
    # The map's: a rounder front, less click, the same knock so a phone still hears it.
    return mix(thud(130.0, 44.0, 0.34, click=0.35, drive=2.2, body_gain=1.0),
               body(220.0, 120.0, 0.09, drive=1.8, click=0.0) * 0.6)


def taiko():
    # The rift side's drum: a big skin in a big room.
    return room(thud(95.0, 38.0, 0.55, click=0.3, drive=2.0, body_gain=1.4), decay=0.35, mix=0.25, cut=3000.0)


def snare_drum(big=False):
    n = n_of(0.22)
    tone = harmonics(190.0, n, [1.0, 0.4, 0.2]) * env_ad(n, 0.001, 0.05) * 0.6
    b = mix(burst(0.22, 180.0, 7500.0, decay=0.05) * 0.9, tone, body(300.0, 140.0, 0.06, click=0.5) * 0.4)
    return room(b, decay=0.3 if big else 0.1, mix=0.3 if big else 0.18, cut=7000.0)


def rim():
    # A side-stick on a casing: the map's answer to the snare.
    return mix(knock([900.0, 1400.0, 2300.0], [0.02, 0.014, 0.009], [1.0, 0.5, 0.3], noise_gain=0.6) * 0.7,
               body(420.0, 200.0, 0.03, click=0.4) * 0.3)


def hat(open_=False, bright=True):
    if bright:
        return burst(0.28 if open_ else 0.045, 5500.0, 13000.0, decay=0.09 if open_ else 0.012) * 0.35
    # Brushed: a softer front, a narrower band.
    return burst(0.24 if open_ else 0.05, 3500.0, 9000.0, attack=0.004, decay=0.08 if open_ else 0.014) * 0.3


def knock_perc():
    # A casing tapped, dead at once.
    return knock([740.0, 1180.0, 1660.0], [0.03, 0.02, 0.012], [1.0, 0.5, 0.3], noise_gain=0.5) * 0.6


def clank():
    # The little metal that is allowed: inharmonic, gone in a tenth of a second,
    # band-limited so it never gets to cowbell.
    k = knock([1180.0, 1930.0, 2760.0], [0.08, 0.055, 0.04], [1.0, 0.5, 0.3], noise_gain=0.3)
    return bp(k, 600.0, 6000.0) * 0.5


def tick():
    return ratchet(1, 0.008, 3000.0, 0.5) * 0.5


# ---- the instruments: one note

def fm(f, n, ratio=1.0, index=2.0, idx_decay=0.3, amp_decay=0.6, attack=0.003, curve=3.0):
    """One FM voice: a sine carrier bent by a sine at `ratio` times its pitch, the bend
    (`index`) fading over `idx_decay` so the note starts bright and settles."""
    t = t_of(n)
    idx = index * np.exp(-t / max(idx_decay, 1e-3))
    return np.sin(2.0 * math.pi * f * t + idx * np.sin(2.0 * math.pi * f * ratio * t)) * env_ad(n, attack, amp_decay, curve=curve)


def epiano(f, dur):
    # The tine piano: a soft carrier with a bright short bell on its front.
    n = n_of(dur)
    return mix(fm(f, n, 1.0, 1.6, 0.18, dur * 0.45), fm(f, n, 14.0, 0.25, 0.04, 0.06) * 0.2, fm(f * 0.5, n, 1.0, 0.6, 0.3, dur * 0.4) * 0.3) * 0.8


def bell(f, dur):
    # Glassy and inharmonic, long: the chimes without the pulse wave.
    n = n_of(dur)
    return mix(fm(f, n, 3.5, 2.8, dur * 0.35, dur * 0.45, curve=2.0), fm(f, n, 1.41, 1.2, dur * 0.3, dur * 0.5, curve=2.0) * 0.5) * 0.7


def brass(f, dur):
    # A stab: the bend rises over the front, the note is driven and cut.
    n = n_of(dur)
    t = t_of(n)
    idx = 2.5 * (1.0 - np.exp(-t / 0.04))
    x = np.sin(2.0 * math.pi * f * t + idx * np.sin(2.0 * math.pi * f * t)) + 0.4 * np.sin(2.0 * math.pi * f * 2.0 * t + idx * np.sin(2.0 * math.pi * f * t))
    return lp(sat(x, 1.8), 3200.0) * env_ad(n, 0.01, dur * 0.35)


def pluck(f, dur, bright=0.6, damp=0.996):
    """A plucked string (Karplus-Strong): a burst of noise round a delay line the length of
    the pitch, averaged each pass so it darkens as it rings."""
    n = n_of(dur)
    length = max(2, int(round(SR / f)))
    ring = lp(noise(length), 600.0 + 9000.0 * bright)
    ring /= np.max(np.abs(ring)) + 1e-9
    out = np.empty(n)
    prev = 0.0
    for i in range(n):
        j = i % length
        y = ring[j]
        ring[j] = damp * 0.5 * (y + prev)
        prev = y
        out[i] = y
    return out * env_pts(n, [(0.0, 1.0), (max(dur - 0.02, 0.0), 1.0), (dur, 0.0)])


def pluck_bass(f, dur):
    x = pluck(f, dur, bright=0.35, damp=0.998)
    return lp(sat(x * 1.5, 1.6), 1800.0)


def chug(f, dur, mute=True, cutoff=1500.0):
    # A palm-muted low string through a wall of gain: the plucked string driven hard,
    # a resonant low-pass for the cabinet, muted quickly, a thump on the front.
    x = pluck(f, dur, bright=0.45, damp=0.992)
    x = np.clip(sat(x * 4.0, 3.0) * 1.4, -1.0, 1.0)
    x = hp(svf(x, cutoff, 0.8), 70.0)
    n = len(x)
    x = x * (env_ad(n, 0.001, min(0.14, dur * 0.5), curve=3.0) if mute else env_ad(n, 0.001, dur * 0.7, curve=2.0))
    return mix(x, body(210.0, 95.0, 0.05, drive=2.0, click=0.3) * 0.35)


def bass_note(freq, dur, drive=3.0, cutoff=900.0):
    # The crunch (Ryan, 23 September: the rougher first cut fit better): one saw with a
    # shadow a hair off tune, a sub, driven hard and clipped, then one fixed low-pass.
    n = n_of(dur)
    t = t_of(n)
    saw = 2.0 * ((freq * t) % 1.0) - 1.0
    shadow = 2.0 * ((freq * 1.004 * t + 0.3) % 1.0) - 1.0
    sub = np.sin(2.0 * math.pi * freq * t) * 0.6
    x = np.clip(sat(saw + shadow * 0.35 + sub, drive) * 1.3, -1.0, 1.0)
    x = lp(x, cutoff)
    env = env_ad(n, 0.004, dur * 0.6, curve=2.0)
    r = n_of(0.02)
    env[-r:] *= np.linspace(1.0, 0.0, r)
    return x * env


def chime(f, dur):
    # The second cut's chimes: a pulse through a band. Kept for reference.
    n = n_of(dur)
    t = t_of(n)
    pulse = np.where((f * t) % 1.0 < 0.28, 1.0, -1.0) * 0.6 + np.sin(2.0 * math.pi * f * 2.0 * t) * 0.2
    return bp(sat(pulse, 1.5), 300.0, 3500.0) * env_ad(n, 0.003, dur * 0.35)


def saws_vib(f, n, detune=(0.994, 1.0, 1.006), vib_hz=5.2, vib_depth=0.004):
    """Detuned saws with a slow vibrato: a bowed or sung tone rather than a synth's."""
    t = t_of(n)
    out = np.zeros(n)
    for d in detune:
        ph = RNG.uniform(0.0, 2.0 * math.pi)
        fr = f * d * (1.0 + vib_depth * np.sin(2.0 * math.pi * vib_hz * t + ph))
        out += 2.0 * ((np.cumsum(fr) / SR + RNG.uniform(0.0, 1.0)) % 1.0) - 1.0
    return out / len(detune)


NOTE_INST = {}   # name -> f(freq, dur, params)
NOTE_INST["bass"] = lambda f, d, p: bass_note(f, d, p.get("drive", 3.0), p.get("cutoff", 900.0))
NOTE_INST["chime"] = lambda f, d, p: chime(f, d)
NOTE_INST["bell"] = lambda f, d, p: bell(f, d)
NOTE_INST["epiano"] = lambda f, d, p: epiano(f, d)
NOTE_INST["brass"] = lambda f, d, p: brass(f, d)
NOTE_INST["pluck"] = lambda f, d, p: pluck(f, d, p.get("bright", 0.6)) * 0.7
NOTE_INST["pluck_bass"] = lambda f, d, p: pluck_bass(f, d)
NOTE_INST["chug"] = lambda f, d, p: chug(f, d, p.get("mute", True), p.get("cutoff", 1500.0))


# ---- the instruments: a chord held or struck

def pad_chord(semis, n, cutoff=700.0, gain=0.12, octave=1):
    # Detuned saws with a harmonics layer over each note, a slow swell in the filter.
    t = t_of(n)
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        x += saws(f, n, (0.993, 1.0, 1.007)) * 0.5 + harmonics(f, n, [0.6, 0.0, 0.3, 0.0, 0.15]) * 0.4
    x /= max(1, len(semis))
    lfo = 0.8 + 0.2 * np.sin(2.0 * math.pi * 0.07 * t + RNG.uniform(0.0, 6.0))
    return lp(sat(x, 1.6), cutoff) * lfo * gain


VOWELS = {"ah": (700.0, 1100.0, 2600.0), "oh": (450.0, 800.0, 2500.0), "oo": (300.0, 700.0, 2400.0)}


def choir(semis, n, gain=0.2, vowel="ah", octave=1):
    # Voices: five slightly detuned singers a note, each with a vibrato of its own, through
    # the vowel's three formants.
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        x += saws_vib(f, n, (0.992, 0.996, 1.0, 1.004, 1.008), vib_hz=RNG.uniform(4.6, 5.8), vib_depth=0.005)
    x /= max(1, len(semis))
    f1, f2, f3 = VOWELS[vowel]
    y = bp(x, f1 * 0.8, f1 * 1.25) * 1.0 + bp(x, f2 * 0.85, f2 * 1.18) * 0.5 + bp(x, f3 * 0.88, f3 * 1.14) * 0.22
    return room(y, decay=0.4, mix=0.25, cut=4000.0)[:n] * gain * 2.2


def organ(semis, n, gain=0.15, octave=1):
    # Drawbars: eight harmonics a note, a slow chorus between two copies.
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        x += harmonics(f, n, [1.0, 0.7, 0.5, 0.35, 0.25, 0.15, 0.1, 0.08], detune=0.0) + harmonics(f * 1.003, n, [1.0, 0.7, 0.5, 0.35, 0.25], detune=0.0) * 0.5
    x /= max(1, len(semis))
    return lp(x, 4000.0) * gain


def strings(semis, n, gain=0.15, octave=1):
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        x += saws_vib(f, n, (0.993, 0.997, 1.0, 1.003, 1.007), vib_hz=5.0, vib_depth=0.003)
    x /= max(1, len(semis))
    return room(lp(x, 2600.0), decay=0.35, mix=0.2, cut=5000.0)[:n] * gain


PAD_INST = {"saw": lambda c, n, p: pad_chord(c, n, p.get("cut", 700.0), p.get("gain", 0.12)),
            "choir": lambda c, n, p: choir(c, n, p.get("gain", 0.2), p.get("vowel", "ah")),
            "organ": lambda c, n, p: organ(c, n, p.get("gain", 0.15)),
            "strings": lambda c, n, p: strings(c, n, p.get("gain", 0.15))}


def stab(semis, dur):
    # A saw stab on the chord: short, driven.
    n = n_of(dur)
    x = np.zeros(n)
    for s in semis:
        x += saws(E2 * 2.0 ** (s / 12.0) * 2.0, n, (0.99, 1.0, 1.01))
    x /= max(1, len(semis))
    return lp(sat(x, 2.5), 1800.0) * env_ad(n, 0.004, dur * 0.3)


def epiano_chord(semis, dur):
    return hp(mix(*[epiano(E2 * 2.0 ** (s / 12.0) * 2.0, dur) for s in semis]) / max(1, len(semis)) * 1.2, 180.0)


def brass_chord(semis, dur):
    return mix(*[brass(E2 * 2.0 ** (s / 12.0) * 2.0, dur) for s in semis]) / max(1, len(semis))


def orch_hit(semis, dur):
    # The other world's hit: strings and brass together, a crack on the front, a hall.
    n = n_of(dur)
    x = mix(strings(semis, n, 1.0, 1)[:n] * env_ad(n, 0.01, dur * 0.3), brass_chord(semis, dur) * 0.6,
            burst(0.06, 300.0, 6000.0, decay=0.02) * 0.5, thud(110.0, 40.0, 0.4, click=0.4, drive=2.5) * 0.5)
    return room(x, decay=0.5, mix=0.3, cut=5000.0)


STAB_INST = {"stab": stab, "epiano": epiano_chord, "brass": brass_chord, "hit": orch_hit}


# ---- the metal kit and the other world's tools (Ryan's verdict on the sketches, 23
# September: djent for the fight, harder still; the rift palette for the map, creepier,
# more electronic and glitchy; the bells and the choir shared between them)

def kick_metal():
    # Tight and clicky: a short sub, the knock, and a hard click at 3 to 6 kHz so it cuts
    # through the chug on a phone.
    click = bp(noise(n_of(0.03)), 2500.0, 7000.0) * env_ad(n_of(0.03), 0.0002, 0.004) * 1.2
    return mix(thud(175.0, 50.0, 0.22, click=0.9, drive=3.5, body_gain=1.1), click)


def snare_metal():
    # A crack: the tone higher and shorter, the noise brighter, a transient on the front,
    # a short bright room.
    n = n_of(0.18)
    tone = harmonics(225.0, n, [1.0, 0.5, 0.25]) * env_ad(n, 0.001, 0.035) * 0.6
    crack = bp(noise(n_of(0.02)), 1500.0, 9000.0) * env_ad(n_of(0.02), 0.0002, 0.003) * 0.9
    b = mix(burst(0.18, 300.0, 9500.0, decay=0.045) * 1.0, tone, crack, body(320.0, 150.0, 0.05, click=0.5) * 0.4)
    return room(b, decay=0.08, mix=0.16, cut=9000.0)


def crash():
    # A crash: a long bright wash with a few inharmonic partials, quiet by nature.
    n = n_of(1.6)
    wash = bp(noise(n), 2500.0, 15000.0) * env_ad(n, 0.002, 0.45, curve=2.5)
    return mix(wash, knock([3100.0, 4700.0, 6900.0], [0.5, 0.35, 0.25], [0.5, 0.3, 0.2], noise_gain=0.0) * 0.3) * 0.4


def tom(f=140.0):
    return mix(thud(f * 1.6, f * 0.8, 0.28, click=0.4, drive=2.0, body_gain=0.6), burst(0.06, 200.0, 3000.0, decay=0.02) * 0.3)


def bass_guitar(f, dur, drive=2.2):
    # A bass guitar, not a synth (Ryan: the crunch bass was too electronic under the metal):
    # the plucked string with a pick on it, driven a little, the cabinet's low-pass.
    x = pluck(f, dur, bright=0.55, damp=0.9975)
    x = np.clip(sat(x * drive, drive) * 1.2, -1.0, 1.0)
    return hp(lp(x, 2400.0), 45.0) * 0.9


def lead(f, dur):
    # The unison lead: two saws a hair apart with a slow vibrato, driven, sustained.
    n = n_of(dur)
    x = saws_vib(f, n, (0.997, 1.003), vib_hz=5.5, vib_depth=0.004)
    x = hp(lp(sat(x, 1.8), 2400.0), 260.0)   # softer on top, and out of the bass's band
    return x * env_pts(n, [(0.0, 0.0), (0.01, 1.0), (max(dur - 0.03, 0.02), 0.9), (dur, 0.0)])


def crush(x, bits=6, hold=6):
    """Bit depth down and every `hold` samples held: the glitch."""
    q = 2.0 ** (bits - 1)
    y = np.round(x * q) / q
    return np.repeat(y[::hold], hold)[: len(x)]


def glitch_perc():
    # A crushed click: the other world's percussion, digital and wrong.
    n = n_of(0.05)
    x = crush(bp(noise(n), 900.0, 6000.0) * env_ad(n, 0.0003, 0.012), bits=5, hold=9)
    return lp(x, 7000.0) * 0.6


def bell_stutter(f, dur):
    # A bell whose first slice retriggers four times, then rings: the glitch on a chime.
    note = bell(f, dur)
    s = n_of(0.042)
    head = np.concatenate([note[:s] * g for g in (1.0, 0.8, 0.65, 0.5)])
    return np.concatenate([head, note[len(head):]]) if len(note) > len(head) else head


def swell_rev(semis, dur):
    # A chord's room played backwards, so it arrives on the beat that follows it.
    n = n_of(dur)
    x = mix(*[bell(E2 * 2.0 ** (s / 12.0) * 4.0, dur * 0.5) for s in semis]) / max(1, len(semis))
    r = room(x, decay=dur * 0.3, mix=1.0, cut=6000.0)[:n]
    r = r[::-1] * env_pts(n, [(0.0, 0.0), (dur * 0.85, 1.0), (dur, 0.0)])
    return lp(r, 5000.0) * 0.5


NOTE_INST["bass_guitar"] = lambda f, d, p: bass_guitar(f, d, p.get("drive", 2.2))
NOTE_INST["lead"] = lambda f, d, p: lead(f, d)
NOTE_INST["bell_stutter"] = lambda f, d, p: bell_stutter(f, d)
STAB_INST["swell_rev"] = swell_rev


# ---- the orchestra, and the fight's own chime (Ryan's third listen, 23 September: the
# map's bass organic rather than electronic, toward Final Fantasy's orchestral epicness;
# different orchestra sections carrying the tune; the skirmish's bells distinct from the
# map's)

def pizz(f, dur):
    # Pizzicato contrabass: the plucked string, dark, short, with the body's thump.
    x = pluck(f, min(dur, 0.6), bright=0.25, damp=0.995)
    return mix(lp(x, 1400.0) * 0.9, body(180.0, 90.0, 0.05, drive=1.5, click=0.2) * 0.25)


def cello(f, dur):
    # A bowed low string: two voices a hair apart, a slow front, the vibrato late.
    n = n_of(dur)
    x = saws_vib(f, n, (0.997, 1.003), vib_hz=4.8, vib_depth=0.004)
    x = lp(sat(x, 1.3), 1500.0)
    return x * env_pts(n, [(0.0, 0.0), (0.05, 1.0), (max(dur - 0.05, 0.06), 0.9), (dur, 0.0)])


def violin(f, dur):
    n = n_of(dur)
    x = saws_vib(f, n, (0.996, 1.0, 1.004), vib_hz=5.6, vib_depth=0.006)
    x = lp(x, 4200.0) - lp(x, 300.0)
    return x * env_pts(n, [(0.0, 0.0), (0.06, 1.0), (max(dur - 0.05, 0.08), 0.85), (dur, 0.0)]) * 0.8


def horn(f, dur):
    # A French horn: the bend rises slowly and stays low, the tone round.
    n = n_of(dur)
    t = t_of(n)
    idx = 1.1 * (1.0 - np.exp(-t / 0.12))
    x = np.sin(2.0 * math.pi * f * t + idx * np.sin(2.0 * math.pi * f * t)) + 0.25 * np.sin(2.0 * math.pi * f * 2.0 * t)
    return lp(sat(x, 1.3), 2200.0) * env_pts(n, [(0.0, 0.0), (0.05, 1.0), (max(dur - 0.06, 0.08), 0.8), (dur, 0.0)]) * 0.8


def harp(f, dur):
    x = pluck(f, dur, bright=0.85, damp=0.997)
    return lp(x, 6000.0) * 0.7


def timpani():
    return room(mix(thud(105.0, 62.0, 0.7, click=0.2, drive=1.8, body_gain=0.8), harmonics(62.0, n_of(0.7), [1.0, 0.3, 0.2]) * env_ad(n_of(0.7), 0.005, 0.25) * 0.4), decay=0.4, mix=0.25, cut=2500.0)


def chime_metal(f, dur):
    # The fight's chime: brighter, shorter, more metal than the map's bell.
    n = n_of(dur)
    return lp(mix(fm(f, n, 4.2, 2.0, dur * 0.2, dur * 0.3, curve=3.0), fm(f, n, 1.0, 0.6, dur * 0.2, dur * 0.35) * 0.5,
                  fm(f * 2.0, n, 2.76, 1.2, dur * 0.15, dur * 0.2) * 0.2), 5000.0) * 0.7


NOTE_INST["pizz"] = lambda f, d, p: pizz(f, d)
NOTE_INST["cello"] = lambda f, d, p: cello(f, d)
NOTE_INST["violin"] = lambda f, d, p: violin(f, d)
NOTE_INST["horn"] = lambda f, d, p: horn(f, d)
NOTE_INST["harp"] = lambda f, d, p: harp(f, d)
NOTE_INST["chime_metal"] = lambda f, d, p: chime_metal(f, d)


# ---- the fourth listen's instruments (Ryan, 23 September: the pizzicato read electronic
# and chiptune; the fight's leads together were harsh; solos wanted)

def contrabass(f, dur):
    # A bowed contrabass, short bows: detuned saws with vibrato, the body's resonance round
    # 250 Hz, the bow's grit on the front. Organic where the plucked string was not.
    n = n_of(dur)
    x = saws_vib(f, n, (0.996, 1.0, 1.004), vib_hz=4.4, vib_depth=0.005)
    x = lp(sat(x, 1.4), 1100.0)
    x = x + bp(x, 190.0, 330.0) * 0.7
    grit = bp(noise(n), 700.0, 2600.0) * env_ad(n, 0.004, 0.04) * 0.12
    return (x + grit) * env_pts(n, [(0.0, 0.0), (0.035, 1.0), (max(dur - 0.06, 0.05), 0.85), (dur, 0.0)]) * 0.8


def synlead(f, dur):
    # The keyboard solo's voice: an FM lead with a saw under it, rounder than the guitar's.
    n = n_of(dur)
    t = t_of(n)
    x = fm(f, n, 2.0, 1.4, dur * 0.6, dur * 2.0, attack=0.004) + saws(f, n, (0.998, 1.002)) * 0.35
    x = hp(lp(sat(x, 1.4), 2800.0), 320.0)
    return x * env_pts(n, [(0.0, 0.0), (0.008, 1.0), (max(dur - 0.03, 0.02), 0.85), (dur, 0.0)]) * 0.8


NOTE_INST["contrabass"] = lambda f, d, p: contrabass(f, d)
NOTE_INST["synlead"] = lambda f, d, p: synlead(f, d)


# ---- the engine

def _bars(form, meter):
    """Steps per bar, each bar's first step, and each bar's step scale. A section's meter
    is its steps per bar (16 is 4/4; 12 is 3/4 or 6/8; 14 is 7/8), or (steps, scale) where
    the scale stretches the step: (12, 4/3) is 6/8 whose triplets ride a 4/4 bar's length."""
    steps, scales = [], []
    for sec in form:
        m = (meter or {}).get(sec, 16)
        if isinstance(m, (tuple, list)):
            steps.append(int(m[0]))
            scales.append(float(m[1]))
        else:
            steps.append(int(m))
            scales.append(1.0)
    starts = [0]
    for s in steps[:-1]:
        starts.append(starts[-1] + s)
    return steps, starts, scales


def _steps(form, part, meter=None, default="."):
    """The whole loop's step string for a part: the section's pattern per bar. With every
    bar sixteen steps a pattern is indexed by the loop's own step, so a figure shorter
    than a bar walks round it (polymeter) and a two-bar figure keeps its place. With mixed
    meters a pattern that fits its bar whole is indexed from its run's start, and one that
    does not (a seven-step figure) still walks by the loop's step."""
    steps, starts, _ = _bars(form, meter)
    uniform = all(s == 16 for s in steps)
    out = []
    run_start = 0
    for bar, sec in enumerate(form):
        if bar > 0 and form[bar - 1] != sec:
            run_start = bar
        pat = part.get(sec, part.get("*", default * steps[bar]))
        if uniform or len(pat) % steps[bar] != 0:
            out.append("".join(pat[(starts[bar] + i) % len(pat)] for i in range(steps[bar])))
        else:
            base = starts[bar] - starts[run_start]
            out.append("".join(pat[(base + i) % len(pat)] for i in range(steps[bar])))
    return "".join(out)


def _chords_per_bar(form, chords):
    out = []
    start = 0
    while start < len(form):
        end = start
        while end < len(form) and form[end] == form[start]:
            end += 1
        c = chords.get(form[start], chords.get("*"))
        for b in range(start, end):
            if c and isinstance(c[0], (list, tuple)):
                out.append(list(c[(b - start) % len(c)]))
            else:
                out.append(list(c) if c else None)
        start = end
    return out


def groove(bpm, form, kit, drums, chords, voices, pad=None, tilt=4.0, crescendo=None, air=(0.12, 0.06), low=None,
           meter=None, human=None, swap=None, master=1.25, headroom=None, drum_gain=None):
    """`kit` maps a drum to (sound, gain) or ([variants], gain), a variant chosen per hit.
    `human` is (seconds of timing slop, fraction of velocity slop) for every hit and note.
    `swap` renames instruments (a realism pass: {"cello": "cello_real"}). A voice may carry
    `late` (steps after the beat), `hold` (its notes' length as a fraction of their steps,
    0.95 by default) and `legato` (a hold of 1)."""
    form = form.replace(" ", "")
    bars = len(form)
    step_s = 60.0 / bpm / 4.0
    steps, starts, scales = _bars(form, meter)
    total = sum(steps)
    step_t = [0.0]
    step_bar = []
    for b, s in enumerate(steps):
        for _ in range(s):
            step_t.append(step_t[-1] + step_s * scales[b])
            step_bar.append(b)
    n = int(round(step_t[-1] * SR))
    buf = np.zeros(n)
    slop_t, slop_v = human if human else (0.0, 0.0)
    swap = swap or {}

    def tm(step):
        # A step's time, running on past the loop's end at the last bar's pace (tails wrap).
        if step <= total:
            return step_t[int(step)] + (step - int(step)) * step_s * scales[-1]
        return step_t[total] + (step - total) * step_s * scales[-1]

    def when(step):
        return tm(step) + (RNG.uniform(-slop_t, slop_t) if slop_t else 0.0)

    def span(step, length):
        return tm(step + length) - tm(step)

    def vel():
        return 1.0 - RNG.uniform(0.0, slop_v) if slop_v else 1.0

    def pick(sound):
        s = sound[RNG.integers(len(sound))] if isinstance(sound, list) else sound
        return s / max(1.0, float(np.max(np.abs(s))))   # never louder than full scale

    def inst(name):
        return swap.get(name, name)

    runs = []
    b0 = 0
    while b0 < bars:
        e0 = b0
        while e0 < bars and form[e0] == form[b0]:
            e0 += 1
        runs.append((b0, e0))
        b0 = e0

    def run_pos(step):
        bar = step_bar[min(step, total - 1)]
        for r0, r1 in runs:
            if r0 <= bar < r1:
                s0 = starts[r0]
                s1 = starts[r1] if r1 < bars else total
                return (step - s0) / float(s1 - s0)
        return 0.0

    def shape(spec, pos):
        # (lo, hi) is a line across the run; [(pos, gain), ...] is a shape of points.
        if isinstance(spec[0], (tuple, list)):
            return float(np.interp(pos, [p[0] for p in spec], [p[1] for p in spec]))
        lo, hi = spec
        return lo + (hi - lo) * pos

    def swell(step):
        bar = step_bar[min(step, total - 1)]
        if not crescendo or form[bar] not in crescendo:
            return 1.0
        return shape(crescendo[form[bar]], run_pos(step))

    global RNG
    outer = RNG
    for name, part in drums.items():
        RNG = np.random.default_rng(zlib.crc32(("drum:" + name).encode()))
        entry = kit[name]
        sound, gain = entry[0], entry[1]
        behind = entry[2] if len(entry) > 2 else 0.0   # seconds behind the beat (a crash that drags)
        s = _steps(form, part, meter)
        for i, c in enumerate(s):
            in_bar = i - starts[step_bar[i]]
            dg = (drum_gain or {}).get(form[step_bar[i]], 1.0)   # the drums up or down by section
            if c == "x":
                buf = at(buf, pick(sound), when(i) + behind, gain * dg * vel() * (1.0 if not name.startswith("hat") or in_bar % 4 == 0 else 0.7), wrap=True)
            elif c == "o":
                buf = at(buf, pick(sound), when(i) + behind, gain * dg * vel() * 0.45, wrap=True)
    per_bar = _chords_per_bar(form, chords)
    for vi, v in enumerate(voices):
        RNG = np.random.default_rng(zlib.crc32(("voice:%s:%d" % (v["inst"], vi)).encode()))
        s = _steps(form, v["pat"], meter)
        mode = v.get("mode", "riff")
        gain = v.get("gain", 0.4)
        params = v.get("params", {})
        octave = v.get("octave", 0)
        echo = v.get("echo")
        late = v.get("late", 0)
        hold = 1.0 if v.get("legato") else v.get("hold", 0.95)
        name = inst(v["inst"])
        own = v.get("shape")   # this voice's own rise and fall across its section's run

        def vs(step):
            return swell(step) * (shape(own, run_pos(step)) if own else 1.0)
        if mode == "riff":
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
                f = E2 * 2.0 ** ((semis + 12 * octave) / 12.0)
                buf = at(buf, NOTE_INST[name](f, span(i, length) * hold, params), when(i + late), gain * vel() * vs(i), wrap=True)
                i += length
        elif mode == "chord":
            for i, c in enumerate(s):
                if not c.isdigit() or not per_bar[step_bar[i]]:
                    continue
                semis = per_bar[step_bar[i]]
                k = int(c)
                f = E2 * 2.0 ** ((semis[k % len(semis)] + 12 * (k // len(semis)) + 12 * octave) / 12.0)
                note = NOTE_INST[name](f, span(i, v.get("dur", 1.6)), params)
                g = gain * vel() * vs(i)
                buf = at(buf, note, when(i + late), g, wrap=True)
                if echo:
                    for k2 in range(1, (echo[2] if len(echo) > 2 else 1) + 1):
                        buf = at(buf, note, tm(i + late + echo[0] * k2), g * echo[1] ** k2, wrap=True)
        elif mode == "stab":
            for i, c in enumerate(s):
                if c == "x" and per_bar[step_bar[i]]:
                    buf = at(buf, STAB_INST[name](per_bar[step_bar[i]], span(i, v.get("dur", 1.2))), when(i + late), gain * vel() * vs(i), wrap=True)
    RNG = outer
    for pad in (pad if isinstance(pad, list) else [pad]) if pad else []:
        secs = pad.get("sections", form)
        on = [bool(per_bar[i]) and form[i] in secs for i in range(bars)]
        xf = 0.5   # seconds of crossfade between one chord and the next in a run
        b = 0
        while b < bars:
            e = b
            while e < bars and per_bar[e] == per_bar[b] and form[e] == form[b]:
                e += 1
            if on[b]:
                first = b == 0 or not on[b - 1] or form[b - 1] != form[b]
                last = e == bars or not on[e] or form[e] != form[b]
                t0 = tm(starts[b])
                t1 = tm(starts[e]) if e < bars else tm(total)
                n_span = int(round((t1 - t0) * SR)) + (0 if last else n_of(xf))
                p = PAD_INST[inst(pad["inst"])](per_bar[b], n_span, pad)
                T = len(p) / SR
                p *= env_pts(len(p), [(0.0, 0.0), (0.35 if first else xf, 1.0), (T - (0.25 if last else xf), 1.0), (T, 0.0)])
                if pad.get("pump"):
                    # Ducked on every eighth and let back: the electronic pulse under the choir.
                    tt = t_of(len(p)) % (2.0 * step_s)
                    p *= 1.0 - pad["pump"] * np.exp(-tt / (step_s * 0.6))
                if pad.get("swell"):
                    # A crescendo across the section's run (the drone strings under the strings).
                    g0 = shape(pad["swell"], run_pos(starts[b]))
                    g1 = shape(pad["swell"], run_pos(starts[e]) if e < bars else 1.0)
                    p *= np.linspace(g0, g1, len(p))
                buf = at(buf, p, tm(starts[b] + pad.get("late", 0)), 1.0, wrap=True)
            b = e
    r = room(buf, decay=air[0], mix=air[1], cut=6000.0)
    buf = r[:n]
    buf[: len(r) - n] += r[n:]   # the room's tail wraps to the top, so the seam is seamless
    buf = shelf(buf, 700.0, tilt)   # the master's tilt: the mids and highs up, for the phone
    if low:
        buf = low_shelf(buf, low[0], low[1])   # and the low shelf cut, so the leads have room
    if headroom:
        # The mix brought under the knee before the master's saturation, so a big drum
        # cannot drive the whole track into distortion (Ryan, 24 September).
        buf = buf / max(1.0, float(np.max(np.abs(buf))) / headroom)
    return sat(buf, master)


# The loops' shape, for `forge.py sections`: bar counts and timestamps of every section.
MUSIC = {
    "music_map": {"bpm": 90, "form": "PPPPPPPP AAAAAAAB CCCCCCCB EEEEEEEEEEEEEEEE DDDZDDDZ T VVVV GGGGGGGGGGGGGGGGGGGGGGGGGGGG HHHH",
                  "meter": {"Z": 14, "T": (12, 4.0 / 3.0), "V": (12, 4.0 / 3.0)},
                  "names": {"P": "the groove bare: the choir and the kick, the cellos from its second half",
                            "A": "groove: the bells arrive, then the horn answers from its second half",
                            "B": "turn bar: a backwards swell into the next section",
                                                        "T": "a triplet turn: 6/8 over the bar's length, the kick where it always is",
                            "V": "the quiet before: four bars in 6/8, the choir and a low cello, the bells sparse, until the climax lands",
                            "H": "the climax's closer: a hit, a tutti chord held and let go over the timpani",
                            "C": "lift: the bells' section, the bows under them, the choir",
                            "D": "interlude: exposed chords, cellos late on the and, strings on two, timpani, sparse bells",
                            "Z": "a bar of 7/8 closing the interlude's half",
                            "E": "strings section, sixteen bars, minor throughout: the violins on the theme's rhythm then its melody, cellos in two-note chords, the drone swelling, the horns only in the second half, a roll into the interlude",
                            "G": "climax, twenty-eight bars: eight level, then each lead swelling in and out fast, twice, the leads thinning at the end into the closer"}},
    "music_rift_calm": {"bpm": 90, "form": "IIIIIIII AAAAAAAAAAAAAAAA CCCCCCCCCCCCCCCC DDDDDDDD RRRRRRRRRRRRRRRR OOOOOOOO",
                        "meter": {k: (12, 4.0 / 3.0) for k in "IACDRO"},
                        "names": {"I": "intro: the choir pumping and the bells in threes",
                                  "A": "groove: a soft bass drum on one and three, the sub pulsing in threes, cellos on the roots, bells, horns sparse",
                                  "C": "lift: the violins' line, the harp, the strings under, horns at the phrase ends",
                                  "D": "breakdown: no kick, the choir on ah, cellos late with a dissonance, the bells' stutters",
                                  "R": "the groove again with a violin counter-line",
                                  "O": "outro: the kick thinning, the pad fading, into the intro"}},
    "music_human_calm": {"bpm": 96, "form": "IIIIIIII AAAAAAAAAAAAAAAA BBBBBBBB CCCCCCCCCCCCCCCC DDDDDDDD RRRRRRRR OOOOOOOO",
                         "names": {"I": "intro: the kick on every beat, hats, the sub pulsing",
                                   "A": "groove: the piano off the beat, the chime's hook, a soft clap, the sub, the guitar muted low, knocks and ticks",
                                   "B": "breakdown: the choir, the piano holding chords, the sub in long notes",
                                   "C": "the lead in long notes over the guitar's muted rhythm and a ride",
                                   "D": "the crunch synth dark and low on the riff, hats in sixteenths, knocks and a stack",
                                   "R": "the groove again",
                                   "O": "outro: the kick thinning, the pad fading, the chime"}},
    "music_skirmish": {"bpm": 100, "form": "AAAAAAAAAAAAB CCCCCCCC NNNN LLLLLLLL M XXXXXXXX UUUUUUUU FFFFFFFFFFFFFFFF W SSSSSSSS YY KKKKKKKK J",
                       "meter": {"X": 14, "K": (16, 1.06)},
                       "names": {"A": "riff, twelve bars: four bare, four with a low bass, four with bass power chords",
                                 "N": "the riff again, on power chords",
                                 "B": "turn bar: the chug and bass cut short, the drums filling",
                                 "W": "the keys' turn: the tune finishing over the fill",
                                 "Y": "a breath: the guitar's high note held over a sub pedal, a swell into the drop",
                                 "M": "a bar down into the seven",
                                 "C": "lift: the soft sub takes the riff, piano stabs, metal chime, syncopated snare, choir, a tom fill closing it",
                                 "L": "second lift: the crunch synth takes the riff",
                                 "X": "the seven: a riff for 7/8, power chords, the piano on the long beat, a chime, a guitar held through its second half",
                                 "U": "unison riff: chug, bass and lead in octaves, a drum solo behind them in threes and twos, the drums up",
                                 "F": "keys section: the sub punching on the roots, the lead's tune, chord work at chosen moments and more in the second half",
                                 "S": "guitar solo: the chug an octave up, cleaner, sixteenths in places, climbing to a high note",
                                 "K": "keyboard solo, six percent slower: the piano in single notes drifting from the crunch synth's walk, dark chords held on guitar and piano changing with the crashes",
                                 "J": "the descent: one bar, chug, bass and lead down in a gallop with the toms and cymbals on its hits"}},
}


def sections(name):
    """Every run of bars in a loop: section, bars, and where it starts in seconds."""
    m = MUSIC[name]
    form = m["form"].replace(" ", "")
    steps, starts, scales = _bars(form, m.get("meter"))
    step_s = 60.0 / m["bpm"] / 4.0
    t_of_bar = [0.0]
    for b in range(len(form)):
        t_of_bar.append(t_of_bar[-1] + steps[b] * scales[b] * step_s)
    out = []
    b = 0
    while b < len(form):
        e = b
        while e < len(form) and form[e] == form[b]:
            e += 1
        out.append((form[b], b + 1, e, t_of_bar[b], m["names"].get(form[b], "")))
        b = e
    return out, t_of_bar[-1]

# ---- the loops (Ryan's verdicts, 23 September: the fight in the djent palette, the map in
# the rift's, long sections, instruments trading the tune, solos in the fight)

def taiko_soft():
    # The map's drum (Ryan: inevitable, not pushy; then fuller, but not far): little front,
    # a long tail, the skin's low tone held under it, a knock at 200 Hz, a big room.
    n = n_of(0.9)
    hold = np.sin(2.0 * math.pi * 55.0 * t_of(n)) * env_ad(n, 0.01, 0.4) * 0.6
    return lp(room(mix(thud(80.0, 36.0, 0.9, click=0.12, drive=1.6, body_gain=1.3), hold,
                       body(200.0, 110.0, 0.12, drive=1.6, click=0.0) * 0.5), decay=0.5, mix=0.3, cut=2200.0), 900.0)


def bassdrum_real(pitch=1.0):
    # An orchestral bass drum: a big skin's pitch falling slowly, the mallet's soft front,
    # a long room. The realism sketch's kick, since the timpani vanished as one.
    n = n_of(1.2)
    t = t_of(n)
    f = (42.0 + 40.0 * np.exp(-t / 0.12)) * pitch
    skin = np.sin(2.0 * math.pi * np.cumsum(f) / SR) * env_ad(n, 0.003, 0.55, curve=2.5)
    over = harmonics(58.0 * pitch, n, [0.0, 0.4, 0.25, 0.15]) * env_ad(n, 0.003, 0.15) * 0.5
    mallet = lp(noise(n_of(0.03)), 1200.0) * env_ad(n_of(0.03), 0.0005, 0.008) * 0.6
    knock_ = body(210.0, 120.0, 0.14, drive=1.6, click=0.0) * 1.0   # the part a speaker can play
    return room(mix(sat(skin, 1.5), over, knock_, at(np.zeros(1), mallet, 0.0)), decay=0.65, mix=0.3, cut=2500.0) * 1.2


def contrabass_real(f, dur):
    x = cello_real(f, dur)
    return lp(x + bp(x, 90.0, 140.0) * 0.6, 1400.0)


NOTE_INST["contrabass_real"] = lambda f, d, p: contrabass_real(f, d)

# The realism pass: the map's voices and kit, swapped for their real-ish counterparts.
REAL_MAP_SWAP = {"cello": "cello_real", "contrabass": "contrabass_real", "violin": "violin_real", "horn": "horn_real",
                 "strings": "strings_real", "choir": "choir_real", "hit": "hit_real"}
REAL_SKIRMISH_SWAP = {"chug": "guitar_real", "bass_guitar": "bass_real", "lead": "lead_real", "choir": "choir_real"}


def _inject(total_steps, spots, dur):
    """A chord-mode pattern of `total_steps` with a note at each (step, degree) in `spots`."""
    s = ["."] * total_steps
    for step, degree in spots:
        s[step] = str(degree)
    return "".join(s)


# The reprise's material (6/8 at the 4/4 bar's length): out of the loop (Ryan, 24
# September: cool, but it does not belong), kept as the seed of a second track the loop
# could crossfade into instead of looping.
OUTRO_VOICES = [
    {"inst": "cello", "mode": "riff", "gain": 0.32, "legato": True,
     "pat": {"R": "0-----------0-----------g-----------3-----------0-----------8-----------g-----------0-----------"}},
    {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.11, "echo": (3, 0.4, 3), "dur": 3.5, "pat": {"R": "0..2..1..3.."}},
    {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.18, "dur": 3.0,
     "pat": {"R": "........................2..........................1...................................."}},
    {"inst": "harp", "mode": "chord", "octave": 2, "gain": 0.2, "dur": 1.2, "pat": {"R": "0.1.2.3.2.1."}},
]
OUTRO_CHORDS = {"R": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17], [0, 7, 15], [8, 15, 19], [-2, 5, 10], [0, 7, 15]]}


def music_map(bpm=MUSIC["music_map"]["bpm"], palette="real"):
    # The other world at 90, orchestral, wistful, on the real palette. The groove bare (P:
    # cellos low, the bells, the choir on "oo" pulsing, nothing in front), then the groove
    # with the horns answering (A), the lift (C: the contrabass in long bows, the bells
    # doubled, strings under, the horns quieter), the interlude (D: exposed chords, the
    # cellos changing on the "and" of one and the upper strings on two, timpani, a tritone
    # every other bar, the bells sparse and some stuttering, one orchestral hit at its
    # door, a bar of 7/8 closing each half), the strings' section (E, twelve bars: the
    # violins carry the tune on the beat, the horns break in six times on beats, three
    # swelling notes each), a triplet turn (T: 6/8 over the bar's length, the kick where it
    # always is), the climax (G, twelve bars: every lead running its own melody at once, a
    # crescendo across the run), and its closer (H, four bars: a hit, a tutti chord held and
    # let go over the timpani), whose swell releases into the bare groove on the wrap. The
    # kick keeps its places for the whole track (Ryan's rule, 24 September): every bar is
    # the 4/4 bar's length but the interlude's 7/8 closes. An orchestral bass drum for the
    # kick, a big-room snare, sparse hats, crushed clicks for the glitch, every hit varied
    # and humanised. `palette="synth"` is the earlier set, kept to compare.
    real = palette == "real"
    if real:
        drum = variants(bassdrum_real)
        kit = {"kick": (drum, 1.95), "kick_soft": (drum, 1.4), "snare": (variants(snare_real), 0.55), "hat": (variants(lambda p: hat_real(False, p)), 0.4),
               "open": ([hat_real(True)], 0.3), "glitch": (glitch_perc(), 0.4), "clank": (clank(), 0.25), "timp": (variants(lambda p: timpani_real()), 0.8)}
    else:
        kit = {"kick": (taiko_soft(), 1.1), "kick_soft": (taiko_soft(), 0.8), "snare": (snare_drum(True), 0.7), "hat": (hat(False, True), 0.35),
               "open": (hat(True, True), 0.3), "glitch": (glitch_perc(), 0.4), "clank": (clank(), 0.25), "timp": (timpani(), 0.8)}
    form = MUSIC["music_map"]["form"].replace(" ", "")
    meter = MUSIC["music_map"]["meter"]
    steps, starts, _ = _bars(form, meter)
    total = sum(steps)
    # The orchestral hit at the interlude's door and the closer's front: patterns indexed by
    # the loop's own step (their length is no multiple of a bar).
    doors = [starts[b] for b in range(len(form)) if form[b] in "DHG" and b > 0 and form[b - 1] not in "DZHG"]
    g_len = 16 * form.count("G")
    hit_pat = "".join("x" if i in doors else "." for i in range(total + (1 if total % 16 == 0 else 0)))
    # The strings section's horns: six three-note swells, every note on a beat, at the ends
    # of its phrases and at three places between.
    e_len = 16 * form.count("E")
    expected_soft = [(32 * k + 24, (2, 1, 0)[k % 3]) for k in range(4, e_len // 32)]
    expected_loud = [(32 * k + 28, (1, 0, 2)[k % 3]) for k in range(4, e_len // 32)] + [(32 * k + 30, (0, 2, 1)[k % 3]) for k in range(4, e_len // 32)]
    horn_soft = _inject(e_len, expected_soft + [(140, 1), (172, 0), (204, 2), (232, 1)], 2.0)
    horn_loud = _inject(e_len, expected_loud + [(144, 0), (148, 2), (176, 2), (180, 1), (208, 1), (212, 0), (236, 0), (238, 2)], 2.5)
    groove_bells = "0.2.1.3.0.2.1.2."
    groove_cellos = "0------.3------.0---....1-------g------.3------.5---....3-------"
    return groove(
        bpm=bpm,
        form=form,
        meter=meter,
        kit=kit,
        drums={
            "kick_soft": {"P": "x.......x.......", "A": "x.......x.......", "E": "x.......x......."},
            "kick": {"B": "x.......x.....x.", "T": "x.....x.....", "V": "x...........",
                     "C": "x.......x.....x.", "D": "x...............", "Z": "x.............", "G": "x.......x.....x.",
                     "H": "x..............."},
            "snare": {"P": "." * 64 + "....x.......x...", "A": "....x.......x...", "B": "....x.......x..o", "T": "......x.....",
                      "C": "....x.......x..o", "D": "........x.......", "Z": "......x.....x.", "E": "....x.......x...", "G": "....x.......x..o",
                      "H": "................"},
            "hat": {"P": "." * 64 + "..x...x...x...x.", "A": "..x...x...x...x.", "B": "..x...x...x...x.", "T": "x.x.x.x.x.x.",
                    "C": "..x...x...x...x.", "D": "....x.......x...", "Z": "..x...x...x...", "E": "..x...x...x...x.", "G": "x.x.x.x.x.x.x.x."},
            "open": {"G": "......x.......x."},
            "glitch": {"D": ".....x.........x......x.........", "G": "..x..x....x...x."},
            "clank": {"A": "..............x................."},
            "timp": {"D": "x...............x...............x.........x.x...", "Z": "x.............", "T": "x...........",
                     "E": "." * 248 + "x.x.x.x.",
                     "G": "x...............x...............x...............x.......x...x.x.",
                     "H": "x...............x...............x.......x.......x...x...x.x.x.x."},
        },
        chords={"P": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]], "A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                "B": [[0, 7, 15]], "T": [[3, 10, 17]], "V": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [0, 6, 13]],
                "C": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22]],
                "D": [[10, 17, 22], [10, 16, 22], [8, 15, 19], [7, 14, 22], [7, 13, 22], [0, 7, 15]],
                "Z": [[0, 6, 13]],
                "E": [[0, 7, 15, 19], [5, 12, 20, 24], [7, 14, 22, 26], [0, 7, 15, 19], [0, 7, 15, 19], [5, 12, 20, 24], [10, 13, 17, 22], [7, 14, 22, 26],
                      [0, 7, 15, 19], [8, 11, 15, 20], [7, 14, 22, 26], [0, 7, 15, 19], [5, 12, 20, 24], [10, 13, 17, 22], [7, 14, 22, 26], [0, 7, 15, 19]],
                "G": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10],
                      [0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10],
                      [0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10],
                      [0, 7, 15], [8, 15, 19], [7, 14, 22], [0, 7, 15]],
                "H": [[0, 7, 15]]},
        voices=[
            # The groove's bass: cellos low and legato, softer than the bows.
            {"inst": "cello", "mode": "riff", "gain": 0.32, "legato": True,
             "pat": {"P": "." * 64 + groove_cellos, "A": groove_cellos, "B": "0------.3------.0-------5-------"}},
            {"inst": "contrabass", "mode": "riff", "gain": 0.42, "hold": 1.25,
             "pat": {"C": "8--.a-.8-..a.5-.3--.5-.7-..5.7-.", "T": "3-----5-----"}},
            # The bridge out of the strings and the quiet six-eight before the climax: cellos
            # low, a dissonance creeping in.
            {"inst": "cello", "mode": "riff", "gain": 0.36, "legato": True,
             "pat": {"V": "0-----------0-----------g-----------0-----------"}},
            {"inst": "cello", "mode": "riff", "gain": 0.22, "legato": True, "octave": 1,
             "pat": {"V": "........................................6-------"}},
            # Under the strings and the climax, gentler and no longer overlapping (it had
            # summed into a clipped edge).
            {"inst": "contrabass", "mode": "riff", "gain": 0.42, "hold": 1.0,
             "pat": {"E": "0..0..0.3..3..3.a..a..a.7..7..7.0..0..0.5..5..5.3..3..3.g..g..g."}},
            {"inst": "contrabass", "mode": "riff", "gain": 0.42, "hold": 1.0,
             "shape": [(0.0, 1.0), (0.285, 1.0), (0.3, 0.7), (0.74, 0.7), (0.77, 1.6), (0.8, 0.7), (1.0, 1.1)],
             "pat": {"G": "0..0..0.8..8..8.a..a..a.7..7..7.0..0..0.5..5..5.3..3..3.g..g..g."}},
            # The interlude's cellos, changing on the "and" of one; on the 7/8 bars they hold.
            {"inst": "cello", "mode": "riff", "gain": 0.32, "legato": True, "late": 2,
             "pat": {"D": "a---------------8---------------g---------------", "Z": "0-------------"}},
            {"inst": "cello", "mode": "riff", "gain": 0.24, "octave": 1, "legato": True, "late": 2,
             "pat": {"D": "5-------4-------3---------------7-------6-------", "Z": "6-------------"}},
            {"inst": "cello", "mode": "riff", "gain": 0.4, "legato": True,
             "shape": [(0.0, 1.0), (0.285, 1.0), (0.3, 0.6), (0.55, 0.6), (0.58, 1.6), (0.61, 0.6), (0.8, 0.6), (0.83, 1.5), (0.86, 0.7), (1.0, 1.2)],
             "pat": {"G": "0---------------8---------------a---------------7---------------0---------------5---------------3---------------g---------------",
                     "H": "0---------------------------------------------------------------"}},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.13, "echo": (3, 0.42, 3), "dur": 3.5,
             "pat": {"V": "0..........2..........1..........."}},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.2, "echo": (3, 0.42, 3), "dur": 3.5,
             "pat": {"C": "0.2.1.3.0.2.1.2.0.3.2.1.0.3.2.3."}},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.13, "echo": (3, 0.42, 3), "dur": 3.5,
             "shape": [(0.0, 1.0), (0.285, 1.0), (0.3, 0.6), (0.44, 0.6), (0.47, 2.0), (0.5, 0.6), (0.75, 0.6), (0.78, 1.8), (0.81, 0.6), (0.9, 0.5), (0.95, 0.0), (1.0, 0.0)],
             "pat": {"P": "." * 64 + groove_bells, "A": groove_bells, "B": groove_bells,
                     "T": "0..2..1..3..",
                     "D": "0...2...1...3...0...2...1.3.....0.2...1...3.....", "Z": "0...2...1.3...",
                     "G": "0..2.1.3..0.2..10..3.2.1..0.3..2",
                     "H": "3...2...1...0...3...2...1...0..............................."}},
            {"inst": "bell_stutter", "mode": "chord", "octave": 3, "gain": 0.08, "echo": (3, 0.3, 2), "dur": 2.5,
             "pat": {"D": "......................2........."}},
            # The horns: answering in the groove, quieter in the lift.
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.24, "dur": 3.0, "pat": {"A": "." * 64 + "........3...2.1."}},
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.16, "dur": 3.0, "pat": {"T": "......1..0.."}},
            # The strings section's horns break in on beats: three notes, the first softer,
            # the next two coming up.
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.18, "dur": 2.0, "pat": {"E": horn_soft}},
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.3, "dur": 2.5, "pat": {"E": horn_loud}},
            # The closer's horns: the chord held long.
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.45, "dur": 12.0,
             "pat": {"H": "0...............2...............1..............................."}},
            {"inst": "horn", "mode": "chord", "octave": 0, "gain": 0.3, "dur": 16.0,
             "pat": {"H": "0...............0...............0..............................."}},
            # The climax's melodies: each its own line and its own rhythm, none written to fit
            # the others; levelled so none leads.
            {"inst": "horn", "mode": "riff", "gain": 0.3, "octave": 1,
             "shape": [(0.0, 1.0), (0.285, 1.0), (0.3, 0.6), (0.31, 0.6), (0.34, 1.8), (0.37, 0.6), (0.6, 0.6), (0.63, 1.7), (0.66, 0.6), (0.88, 0.7), (1.0, 1.3)],
             "pat": {"G": "3-----5---7-----8-------7---5---3-----0---g-----0-------3---5---"}},
            # The violins: the melody in the strings section, on the beat where it climbs,
            # their tails overlapping the next note as bows do.
            {"inst": "violin", "mode": "riff", "gain": 0.42, "octave": 2, "hold": 1.3,
             "pat": {"E": "0------.3------.0---....1-------g------.3------.5---....3-------"
                          "7------.a------.7---....8-------5------.7------.a---....8-------"
                          "7--.8-.7-..5.3-.0---....3-.5-.7-8--.a-.8-..7.5-.3---....5-.3-.0-"
                          "7---a---c-------a---8---7---5---3-------5---3---0---------------"}},
            # The cellos under the strings in two-note chords (root and tenth).
            {"inst": "cello", "mode": "chord", "octave": 0, "gain": 0.3, "dur": 16.0, "pat": {"E": "0..............."}},
            {"inst": "cello", "mode": "chord", "octave": 0, "gain": 0.24, "dur": 16.0, "pat": {"E": "2..............."}},
            {"inst": "violin", "mode": "riff", "gain": 0.44, "octave": 2, "hold": 1.3,
             "shape": [(0.0, 1.0), (0.285, 1.0), (0.3, 0.6), (0.38, 0.6), (0.41, 1.8), (0.44, 0.6), (0.7, 0.6), (0.73, 1.6), (0.76, 0.6), (0.92, 0.6), (0.97, 0.0), (1.0, 0.0)],
             "pat": {"G": "0.3.5.7.8-..7.5.3-..5.7.a---8.7.5.3.0.3.5---3.0.g.0.3---5-..7-..", "T": "3..5..7..a.."}},
            # The closer's violin: held, then let go before the loop's end, so its tail cannot
            # wrap onto the start (Ryan: the track began on a high violin).
            {"inst": "violin", "mode": "riff", "gain": 0.34, "octave": 2, "hold": 1.0,
             "pat": {"H": "7-------------------------------8-----------------------........"}},
            {"inst": "harp", "mode": "chord", "octave": 2, "gain": 0.28, "dur": 1.2,
             "pat": {"E": "0.1.2.3.2.1.0.1."}},
            {"inst": "harp", "mode": "chord", "octave": 2, "gain": 0.28, "dur": 1.2,
             "shape": [(0.0, 1.0), (0.285, 1.0), (0.3, 0.6), (0.52, 0.6), (0.55, 1.9), (0.58, 0.6), (0.67, 0.6), (0.7, 1.5), (0.73, 0.6), (0.86, 0.5), (0.9, 0.0), (1.0, 0.0)],
             "pat": {"G": "0.1.2.3.2.1.0.1.3.2.1.0.1.2.3.2."}},
            {"inst": "swell_rev", "mode": "stab", "gain": 0.45, "dur": 2.0,
             "pat": {"B": "..............x.", "E": "." * 254 + "x.", "Z": "............x.", "V": "." * 46 + "x.", "H": "." * 62 + "x."}},
            {"inst": "hit", "mode": "stab", "gain": 0.4, "dur": 3.0,
             "pat": {"D": hit_pat, "H": hit_pat}},
        ],
        pad=[{"inst": "choir", "gain": 0.26, "vowel": "oo", "pump": 0.2, "sections": "PABC"},
             {"inst": "choir", "gain": 0.2, "vowel": "oo", "sections": "V"},
             {"inst": "strings", "gain": 0.16, "sections": "GTH"},
             {"inst": "strings", "gain": 0.16, "sections": "E", "swell": [(0.0, 1.0), (0.5, 1.0), (0.9, 1.9), (1.0, 0.5)]},   # swelling, then let go
             {"inst": "strings", "gain": 0.18, "sections": "DZ", "late": 4},   # the upper strings land on two
             {"inst": "choir", "gain": 0.18, "vowel": "ah", "sections": "DZEGH"}],
        crescendo={"G": [(0.0, 0.8), (0.285, 0.8), (0.8, 1.3), (1.0, 1.15)], "H": (1.15, 0.45)},
        air=(0.3, 0.12),
        master=1.1 if real else 1.25, headroom=0.6 if real else None,
        swap=REAL_MAP_SWAP if real else None,
        human=(0.007, 0.18) if real else None)


def sketch_map_outro():
    # The reprise on its own: the seed of a second track (Ryan, 24 September).
    kit = {"kick": (variants(bassdrum_real), 1.4), "snare": (variants(snare_real), 0.5), "hat": (variants(lambda p: hat_real(False, p)), 0.35),
           "glitch": (glitch_perc(), 0.35)}
    return groove(bpm=90, form="RRRRRRRR", meter={"R": (12, 4.0 / 3.0)}, kit=kit,
                  drums={"kick": {"R": "x..........."}, "snare": {"R": "......x....."}, "hat": {"R": "x.x.x.x.x.x."}, "glitch": {"R": "........x..."}},
                  chords=OUTRO_CHORDS, voices=OUTRO_VOICES,
                  pad=[{"inst": "choir", "gain": 0.26, "vowel": "oo", "pump": 0.2}],
                  air=(0.3, 0.12), master=1.1, headroom=0.6, swap=REAL_MAP_SWAP, human=(0.007, 0.18))


def ride():
    # A ride: the stick's tick with a bell-like partial under it, ringing a third of a second.
    n = n_of(0.4)
    tick_ = bp(noise(n_of(0.02)), 4000.0, 12000.0) * env_ad(n_of(0.02), 0.0002, 0.004) * 0.8
    wash = bp(noise(n), 3500.0, 11000.0) * env_ad(n, 0.002, 0.11) * 0.35
    bellp = knock([2900.0, 4300.0, 6100.0], [0.25, 0.18, 0.12], [0.5, 0.35, 0.2], noise_gain=0.0) * 0.35
    return mix(tick_, wash, bellp) * 0.5


def china():
    # A china: trashy, short, all splash and no bell.
    n = n_of(0.55)
    return mix(bp(noise(n), 1500.0, 10000.0) * env_ad(n, 0.001, 0.13, curve=3.0),
               knock([2100.0, 3300.0, 5200.0], [0.12, 0.09, 0.06], [0.4, 0.3, 0.2], noise_gain=0.0) * 0.3) * 0.45


def sub_bass(f, dur, res=0.0, punch=0.0):
    # The back seat: a sine with a little saw, soft-edged, for the sections the leads own;
    # `res` adds a resonance in the low mids, `punch` a kick-like front on every note (Ryan:
    # like a club woofer).
    n = n_of(dur)
    t = t_of(n)
    x = np.sin(2.0 * math.pi * f * t) + saws(f, n, (1.0,)) * 0.18
    x = lp(sat(x, 1.2), 500.0)
    if res:
        x = x + bp(x, 110.0, 260.0) * res * 1.5 + bp(saws(f, n, (1.0,)), 200.0, 600.0) * res * 0.5
    if punch:
        front = sweep(f * 3.0, f, n, tau=0.03) * env_ad(n, 0.001, 0.05, curve=3.0) * punch
        x = sat(x + lp(front, 900.0), 1.3)
    return x * env_pts(n, [(0.0, 0.0), (0.012, 1.0), (max(dur - 0.04, 0.02), 0.85), (dur, 0.0)]) * 0.8


NOTE_INST["sub_bass"] = lambda f, d, p: sub_bass(f, d, p.get("res", 0.0), p.get("punch", 0.0))


def slap_bass(f, dur):
    # A slapped string: the thumb's thump, the string's bright snap against the frets, a
    # quick decay.
    n = n_of(dur)
    x = pluck(f, dur, bright=0.95, damp=0.996)[:n]
    snap = bp(noise(n_of(0.01)), 2500.0, 9000.0) * env_ad(n_of(0.01), 0.0002, 0.002) * 0.9
    thump = lp(noise(n_of(0.025)), 700.0) * env_ad(n_of(0.025), 0.0005, 0.007) * 0.7
    x = at(at(x, snap, 0.0), thump, 0.0)[:n]
    x = np.clip(sat(x * 2.0, 2.0), -1.0, 1.0)
    return hp(lp(x, 4500.0), 50.0) * env_ad(n, 0.001, dur * 0.45, curve=2.0) * 0.9


def sub_pluck(f, dur):
    # The soft sub with a pluck on its front: the lift's bass with a finger.
    n = n_of(dur)
    pluck_ = at(np.zeros(n), pluck_bass(f, min(dur, 0.5)) * 0.35, 0.0)[:n]
    return sub_bass(f, dur) + pluck_ * env_ad(n, 0.001, 0.12)


NOTE_INST["slap_bass"] = lambda f, d, p: slap_bass(f, d)
NOTE_INST["sub_pluck"] = lambda f, d, p: sub_pluck(f, d)


# ---- more cymbals, a heavier tom (Ryan, 24 September: many cymbal voices is very prog;
# the toms wanted bottom end)

def tom_real(f=150.0, pitch=1.0):
    # A tom with weight: the skin's pitch falling, a sub under it, the shell's ring, the
    # stick's front, a room.
    n = n_of(0.55)
    t = t_of(n)
    fr = f * pitch * (1.0 + 0.35 * np.exp(-t / 0.06))
    skin = np.sin(2.0 * math.pi * np.cumsum(fr) / SR) * env_ad(n, 0.001, 0.15, curve=2.5)
    sub = np.sin(2.0 * math.pi * f * pitch * 0.5 * t) * env_ad(n, 0.002, 0.12) * 0.5
    shell = harmonics(f * pitch * 1.6, n, [0.5, 0.3, 0.15]) * env_ad(n, 0.001, 0.04) * 0.4
    stick = bp(noise(n_of(0.01)), 1500.0, 7000.0) * env_ad(n_of(0.01), 0.0002, 0.003) * 1.6   # sharper, drier (Ryan: hollow)
    front = body(f * pitch * 2.2, f * pitch, 0.04, drive=2.4, click=0.8) * 0.9   # more of a hit at the start
    return room(mix(sat(skin + sub, 1.6), shell, front, at(np.zeros(1), stick, 0.0)), decay=0.09, mix=0.1, cut=5000.0) * 1.1


def splash():
    n = n_of(0.3)
    return mix(bp(noise(n), 4000.0, 15000.0) * env_ad(n, 0.001, 0.07, curve=2.5),
               knock([5200.0, 7300.0, 9800.0], [0.12, 0.09, 0.07], [0.4, 0.3, 0.2], noise_gain=0.0) * 0.3) * 0.4


def crash_long():
    # A crash let ring (Ryan: in the keyboard solo they should echo and draw out).
    n = n_of(1.8)
    return mix(bp(noise(n), 2000.0, 15000.0) * env_ad(n, 0.002, 0.45, curve=2.0),
               knock([2900.0, 4300.0, 6400.0, 8100.0], [0.8, 0.65, 0.5, 0.4], [0.5, 0.35, 0.28, 0.2], noise_gain=0.0) * 0.5) * 0.35


def crash_low():
    n = n_of(1.3)
    return mix(bp(noise(n), 1200.0, 10000.0) * env_ad(n, 0.002, 0.32, curve=2.0),
               knock([1900.0, 2800.0, 4100.0, 5600.0], [0.5, 0.4, 0.3, 0.22], [0.4, 0.3, 0.25, 0.2], noise_gain=0.0) * 0.4) * 0.35


def stack():
    # A stack: two cymbals clamped together, trashy and short.
    n = n_of(0.14)
    return bp(noise(n), 2000.0, 9000.0) * env_ad(n, 0.0005, 0.03, curve=3.0) * (0.6 + 0.4 * np.sign(np.sin(2.0 * math.pi * 210.0 * t_of(n)))) * 0.5


def ride_bell():
    n = n_of(0.8)
    return mix(knock([2600.0, 3900.0, 5200.0, 7100.0], [0.45, 0.35, 0.25, 0.18], [0.5, 0.4, 0.3, 0.2], noise_gain=0.0) * 0.5,
               bp(noise(n_of(0.01)), 3000.0, 9000.0) * env_ad(n_of(0.01), 0.0002, 0.002) * 0.6) * 0.45


def guitar_chord(semis, dur):
    # The mechanical guitar on an extended chord, open, behind the keys.
    return mix(*[guitar_real(E2 * 2.0 ** (s / 12.0), dur, mute=False) for s in semis]) / max(1, len(semis)) * 0.9


STAB_INST["guitar_chord"] = guitar_chord


def _drum_solo(bars):
    """A drum solo over `bars` bars in the Ba-ta-ta Ba-ta-ta Ba-ta framework (eighths
    grouped three, three, two): the kick on every Ba, a crash on one and a china or the low
    crash on the "and" of two, a ride bell on some of the last group's Ba, the ta-tas traded
    between snare and toms with doubles and flams and the odd splash or stack, a sixteenth
    fill closing every fourth bar, and never the same bar twice (Ryan: Peart)."""
    parts = {k: [] for k in ("kick", "snare", "tom", "tom2", "crash", "crash2", "china", "splash", "stack", "bell")}
    for b in range(bars):
        bar = {k: ["."] * 16 for k in parts}
        for g, (start, length) in enumerate([(0, 6), (6, 6), (12, 4)]):
            bar["kick"][start] = "x"
            if g == 0:
                bar["crash"][start] = "x"
            elif g == 1:
                bar["china" if b % 2 == 0 else "crash2"][start] = "x"
            elif RNG.integers(3) == 0:
                bar["bell"][start] = "x"
            for pos in range(start + 2, start + length, 2):
                choice = RNG.integers(8)
                if choice == 0:
                    bar["snare"][pos] = "x"
                elif choice == 1:
                    bar["tom"][pos] = "x"
                elif choice == 2:
                    bar["tom2"][pos] = "x"
                elif choice == 3:
                    bar["snare"][pos] = "x"
                    if pos + 1 < 16:
                        bar["snare"][pos + 1] = "o"
                elif choice == 4:
                    bar["tom"][pos] = "x"
                    if pos + 1 < 16:
                        bar["tom2"][pos + 1] = "x"
                elif choice == 5:
                    bar["snare"][pos] = "o"
                    bar["tom2"][pos] = "x"
                elif choice == 6:
                    bar["splash"][pos] = "x"
                    bar["snare"][pos] = "x"
                else:
                    bar["stack"][pos] = "x"
                    bar["tom"][pos] = "x"
                if pos + 1 < 16 and bar["tom2"][pos + 1] == "." and bar["snare"][pos + 1] == "." and RNG.integers(3) == 0:
                    bar["tom2"][pos + 1] = "x"   # fills the air (Ryan: a couple of empty bits)
        if b % 4 == 3:
            for pos in range(12, 16):
                bar[("snare", "tom", "tom2")[pos % 3]][pos] = "x"
            bar["kick"][14] = "x"
        for k in parts:
            parts[k].append("".join(bar[k]))
    return {k: "".join(v) for k, v in parts.items()}


def music_skirmish(palette="hybrid"):
    # The human theme at 100 on the hybrid palette. Eighty-six bars: the riff (A: four bars
    # bare, four with a low bass, four with bass power chords), a turn (B: the chug and
    # bass cut short, the drums filling), the lift (C: the soft sub takes the riff, piano
    # stabs, the metal chime, a tom fill closing it), the riff again on power chords (N),
    # the second lift on the crunch synth (L), a bar down (M), the seven (X: a riff for
    # 7/8, the kick in two-two-three, filled out with the piano, a chime and a held guitar),
    # the unison (U: chug, bass and lead in octaves, a drum solo behind them, the drums up),
    # the keys (F, sixteen bars: the sub punching on the roots, the piano's tune with chord
    # work at chosen moments, more in the second half), a turn the keys play over (W), the
    # guitar solo (S: the chug an octave up, cleaner, faster in places, climbing to a high
    # note it holds), a breath (Y: the held note alone over a sub pedal), the keyboard solo
    # (K, six percent slower: the piano in single notes drifting from the crunch synth's
    # walk, the guitar and piano holding dark chords that change with the crashes), and the
    # descent (J). `palette="synth"` is the second cut's set.
    real = palette == "hybrid"
    riff1 = "0--.3-.0-...1-..g--.3-.1-...3-.."   # E G E F D G F G: the seventh note at the fourth's pitch
    rise = "0--.3-.0-...1-..g--.3-.5-...3-.."    # the rise (A for the seventh), for a run's last bar
    riff_up = "7--.a-.7-...8-..5--.a-.8-...a-.."  # a fifth above: the power chord
    rise_up = "7--.a-.7-...8-..5--.a-.c-...a-.."
    if real:
        kit = {"kick": (variants(kick_real), 1.0), "snare": (variants(snare_real), 1.0), "hat": (variants(lambda p: hat_real(False, p)), 0.45),
               "open": ([hat_real(True)], 0.4), "crash": ([crash_real()], 0.9), "crash2": ([crash_low()], 0.9), "china": (china(), 0.8),
               "crash_long": ([crash_long()], 0.9, 0.035),
               "splash": ([splash()], 0.8), "stack": ([stack()], 0.7), "bell": ([ride_bell()], 0.6), "ride": ([ride_real()], 0.35),
               "tom": (variants(lambda p: tom_real(150.0, p)), 0.9), "tom2": (variants(lambda p: tom_real(105.0, p)), 0.9), "clank": (clank(), 0.3),
               "knock": (knock_perc(), 0.5)}
    else:
        kit = {"kick": (kick_metal(), 1.0), "snare": (snare_metal(), 1.0), "hat": (hat(False, True), 0.45),
               "open": (hat(True, True), 0.4), "crash": (crash(), 1.0), "crash2": (crash(), 0.9), "china": (china(), 0.9),
               "crash_long": (crash(), 1.0, 0.035),
               "splash": (splash(), 0.8), "stack": (stack(), 0.7), "bell": (ride_bell(), 0.6), "ride": (ride(), 0.5),
               "tom": (tom(150.0), 0.8), "tom2": (tom(110.0), 0.8), "clank": (clank(), 0.3), "knock": (knock_perc(), 0.5)}
    backing = "guitar_real" if real else "chug"
    bass = "bass_real" if real else "bass_guitar"
    solo = _drum_solo(8)
    form = MUSIC["music_skirmish"]["form"].replace(" ", "")
    meter = MUSIC["music_skirmish"]["meter"]
    steps, starts, _ = _bars(form, meter)
    total = sum(steps)
    # Crashes at the doors of the sections that want one, never at the top.
    doors = [starts[b] for b in range(len(form)) if form[b] in "CLXFSJ" and b > 0 and form[b - 1] != form[b]]
    door_pat = "".join("x" if i in doors else "." for i in range(total + (1 if total % 16 == 0 else 0)))
    fill_tom = "....x.x.xx.x.x.."
    fill_tom2 = "......x.....x.xx"
    return groove(
        bpm=MUSIC["music_skirmish"]["bpm"],
        form=form,
        meter=meter,
        kit=kit,
        drums={
            "kick": {"A": "x.xx.x.", "N": "x.xx.x.", "B": "x...............", "W": "x.......x.......", "C": "x..xx...x..xx.x.", "L": "x..xx...x..xx.x.",
                     "M": "x...x...x...x...", "X": "x...x.x.x.x...",
                     "U": solo["kick"],
                     "F": "x.......x...xx..x.....x.x...xx..", "S": "x..x..x.x..x..x.x..x..x.x.x.x...", "Y": "x...............................",
                     "K": "x.......x.......x.....x.x.......", "J": "x..x..x.x..x..x."},
            "snare": {"A": "....x.......x...", "N": "....x.......x...", "B": "....x.......x...", "W": "....x.......x...", "C": "....x..o.x..x..o", "L": "....x..o.x..x..o",
                      "M": "....x.......x...", "X": "......x.....x.",
                      "U": solo["snare"],
                      "F": "....x..x....x...", "S": "....x.......x...", "K": "........x.......", "J": "......x.......x."},
            "hat": {"A": "x.x.x.x.x.x.x.x.", "N": "x.x.x.x.x.x.x.x.", "C": "x.x.x.xxx.x.x.xx", "L": "x.x.x.xxx.x.x.xx", "M": "x.x.x.x.x.x.x.x.",
                    "X": "x.x.x.x.x.x.x.", "S": "x.x.x.x.x.x.x.x."},
            "ride": {"F": "x.x.x.x.x.x.xx.xx.x.x.x.x.xxx.x.x.x.x.x.x.x.x.x.x.xx.x.x.x.x.xx.", "W": "x.x.x.x.x.x.x.x.",
                     "S": "x.x.x.x.x.x.x.x.x.x.x.x.x.xx.x.."},
            "open": {"C": "......x.......x.", "L": "......x.......x.", "F": "..............x.", "X": "............x."},
            "knock": {"X": "..x...x...x.x."},
            "crash": {"*": door_pat, "U": solo["crash"], "X": "............x.", "Y": "x..............................."},
            "crash_long": {"K": "x" + "." * 31},
            "crash2": {"U": solo["crash2"], "X": "x" + "." * 27},
            "china": {"B": "..............x.", "W": "..............x.", "M": "..............x.", "S": "......x.......x.", "U": solo["china"], "J": "......x........."},
            "splash": {"U": solo["splash"], "K": "." * 30 + "x."},
            "stack": {"U": solo["stack"]},
            "tom": {"B": fill_tom, "W": fill_tom, "C": "." * 112 + fill_tom, "S": "." * 60 + "x.x.", "F": "." * 62 + "x.", "U": solo["tom"],
                    "K": "." * 26 + "x.x..." + "." * 28 + "x.x.", "J": ".x.x....x.x....x", "Y": "........x.x.xx.x................"},
            "tom2": {"B": fill_tom2, "W": fill_tom2, "C": "." * 112 + fill_tom2, "S": "." * 62 + "x.", "U": solo["tom2"],
                     "K": "." * 30 + "x." + "." * 28 + "x...", "J": "...x.x....x.x...", "Y": "............x.x................."},
            "clank": {"C": "..............x.................", "L": "..............x................."},
        },
        chords={"A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]], "N": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                "B": [[0, 7, 15]], "W": [[0, 7, 15]], "M": [[8, 15, 19]], "Y": [[0, 7, 15]],
                "C": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22]],
                "L": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22]],
                "X": [[0, 7, 15], [0, 7, 15], [3, 10, 17], [-2, 5, 10]],
                "U": [[0, 7, 15]],
                "F": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10],
                      [0, 7, 15], [8, 15, 19], [7, 14, 22], [-2, 5, 10], [0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22]],
                "S": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                # The keyboard solo darker and heavier: E minor, C minor, B minor, E with a tritone.
                "K": [[0, 7, 15], [0, 7, 15], [8, 11, 15], [8, 11, 15], [7, 10, 14], [7, 10, 14], [0, 6, 13], [0, 6, 13]],
                "J": [[0, 7, 15]]},
        voices=[
            # The riff: the chug at full; the bass low for its first stage, then the power chords.
            {"inst": backing, "mode": "riff", "gain": 0.75, "octave": -1,
             "pat": {"A": "0.0-3.0", "N": "0.0-3.0", "B": "0---............", "W": "0---............", "M": "8---7---5---3---", "Y": "0---............................"}},
            {"inst": bass, "mode": "riff", "gain": 0.42, "hold": 1.1, "octave": -1, "params": {"drive": 3.5},
             "pat": {"A": "." * 64 + riff1 + rise}},
            {"inst": bass, "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5},
             "pat": {"A": "." * 128 + riff1 + rise, "N": riff1 + rise, "B": "0---............", "W": "0---............", "M": "8---7---5---3---", "Y": "0-------------------------------"}},
            {"inst": bass, "mode": "riff", "gain": 0.3, "hold": 1.1, "params": {"drive": 3.5},
             "pat": {"A": "." * 128 + riff_up + rise_up, "N": riff_up + rise_up}},
            # The lifts.
            {"inst": "sub_bass", "mode": "riff", "gain": 0.55, "hold": 1.0,
             "pat": {"C": "8-.c.8-a.8-.5-.38-.c.8-a.3-.5-.7"}},
            {"inst": "bass", "mode": "riff", "gain": 0.5, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 800.0},
             "pat": {"L": "8-.c.8-a.8-.5-.38-.c.8-a.3-.5-.7"}},
            # The seven: a riff written for it, power chords under, the piano on the long beat,
            # a chime, and a guitar holding the root an octave up through its second half.
            {"inst": backing, "mode": "riff", "gain": 0.72, "octave": -1,
             "pat": {"X": "0-..3-..5-3-0.0-..3-..8-7-5."}},
            {"inst": bass, "mode": "riff", "gain": 0.32, "hold": 1.1, "params": {"drive": 3.5},
             "pat": {"X": "0-..3-..5-3-0.0-..3-..8-7-5."}},
            {"inst": bass, "mode": "riff", "gain": 0.26, "hold": 1.1, "params": {"drive": 3.5},
             "pat": {"X": "7-..a-..c-a-7.7-..a-..e-d-c."}},
            {"inst": "epiano", "mode": "stab", "gain": 0.4, "dur": 3.0, "pat": {"X": "........x....."}},
            {"inst": "chime_metal", "mode": "chord", "octave": 2, "gain": 0.22, "echo": (3, 0.25, 2), "dur": 1.6,
             "pat": {"X": "....0.....2...1.......3....."}},
            {"inst": backing, "mode": "riff", "gain": 0.3, "octave": 1, "params": {"mute": False, "cutoff": 2000.0}, "legato": True,
             "pat": {"X": "." * 56 + "0-------------3-------------0-------------g-------------"}},
            # The unison: the lead on top, the chug and the bass behind it, the drums soloing.
            {"inst": backing, "mode": "riff", "gain": 0.55, "octave": -1, "params": {"cutoff": 1100.0},
             "pat": {"U": "0..0..0.3..3..3.5..5..5.3.0.g.0.5..5..5.8..8..8.a..a..a.8.5.3.0."}},
            {"inst": bass, "mode": "riff", "gain": 0.3, "params": {"drive": 3.5},
             "pat": {"U": "0..0..0.3..3..3.5..5..5.3.0.g.0.5..5..5.8..8..8.a..a..a.8.5.3.0."}},
            {"inst": "lead", "mode": "riff", "gain": 0.5, "octave": 2,
             "pat": {"U": "0..0..0.3..3..3.5..5..5.3.0.g.0.5..5..5.8..8..8.a..a..a.8.5.3.0."}},
            # The keys: the sub punching on the roots, the piano's tune, chord work at chosen
            # moments and more in the second half; the turn after it is theirs too.
            {"inst": "sub_bass", "mode": "riff", "gain": 0.52, "legato": True, "params": {"res": 0.35, "punch": 1.3},
             "pat": {"F": "0---------------8---------------a---------------7---------------0---------------5---------------3---------------g---------------"
                          "0---------------8---------------7---------------g---------------0---------------8---------------a---------------7---------------",
                     "W": "0---------------"}},
            {"inst": "lead", "mode": "riff", "gain": 0.46, "octave": 2,
             "pat": {"F": "7--.8-.7-..5.3-.0---....3-.5-.7-8--.a-.8-..7.5-.3---....5-.3-.0-"
                          "7--.a-.c---....a--.8-.7-.5---...3--.5-.7-..8.a-.7-------........"
                          "c---a---8-------7---5---3---0-------3---5---7---8---7---5---0---"
                          "7---8---a---c---a---8---7---5---3-------5---3---0-------3---5---",
                     "W": "7-------8-------"}},
            {"inst": "epiano", "mode": "stab", "gain": 0.5, "dur": 2.0,
             "pat": {"C": "..x...x...x...x.", "L": "..x...x...x...x.",
                     "F": "............x..." "................" "............x..." "x..............."
                          "............x..." "x.......x......." "............x..." "x...x...x......."
                          "x...........x..." "x.......x......." "x...x.......x..." "x.......x...x..."
                          "x...x...x...x..." "x.......x...x..." "x...x...x...x..." "x...x...x...x...",
                     "W": "x.......x......."}},
            # The guitar solo: cleaner, faster in places, climbing to a high note held through
            # the breath; over a darker quieter chug and the crunch synth.
            {"inst": backing, "mode": "riff", "gain": 0.4, "octave": -1, "params": {"cutoff": 800.0},
             "pat": {"S": "0.0-3.0"}},
            {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 800.0},
             "pat": {"S": "0--.3-.0-...1-..g--.3-.5-...3-.."}},
            {"inst": backing, "mode": "riff", "gain": 0.5, "octave": 0, "params": {"mute": False, "cutoff": 2400.0, "clean": True}, "hold": 1.0,
             "pat": {"S": "0-3-5---7-8-7-5-3-5-7---a-8-7-5-"
                          "3-5-7-a-8---7-5-3-0-3-5-7-------"
                          "c.e.f.i.f.e.c.a.8---a.c.e.f.i---"
                          "j.i.f.e.c.a.8.7.5.7.8.a.c.e.f.i-"
                          "j---------------i-------j-------"
                          "e.f.i.j.i.f.e.c.a---c.e.f.i.j---"
                          "k-------j-------i-------f-------"
                          "i---------------k---------------",
                     "Y": "k-------------------------------k-------------------------------"}},
            {"inst": "sub_bass", "mode": "riff", "gain": 0.4, "legato": True,
             "pat": {"Y": "0-------------------------------"}},
            # The keyboard solo: the piano in single notes drifting from the crunch synth's
            # walk; the guitar and piano holding dark chords that change with the crashes.
            {"inst": "bass", "mode": "riff", "gain": 0.5, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 800.0},
             "pat": {"K": "0---3---5---3---0---g---0---3---8---a---c---a---8---7---8---a---"
                          "7---a---c---a---7---5---7---a---0---6---7---6---0---g---0---6---"}},
            {"inst": "epiano", "mode": "riff", "gain": 0.6, "octave": 2, "hold": 1.0,
             "pat": {"K": "7-----8-----7-----5-------3-----5-------7-----8-----a-------8---"
                          "c-----a-----8-----7-------5-----3-------6-----7-----6-------0---"}},
            {"inst": "guitar_chord", "mode": "stab", "gain": 0.55, "dur": 30.0,
             "pat": {"K": "x" + "." * 31}},
            {"inst": "epiano", "mode": "stab", "gain": 0.55, "dur": 14.0,
             "pat": {"K": "x...............x..............."}},
            # The descent.
            {"inst": backing, "mode": "riff", "gain": 0.7, "octave": 0,
             "pat": {"J": "j..i..f.e..c..a.8..7..5.3..0..g."}},
            {"inst": bass, "mode": "riff", "gain": 0.4, "params": {"drive": 3.5},
             "pat": {"J": "j..i..f.e..c..a.8..7..5.3..0..g."}},
            {"inst": "lead", "mode": "riff", "gain": 0.5, "octave": 2,
             "pat": {"J": "j..i..f.e..c..a.8..7..5.3..0..g."}},
            {"inst": "chime_metal", "mode": "chord", "octave": 2, "gain": 0.22, "echo": (3, 0.25, 2), "dur": 1.6,
             "pat": {"A": "0...............2...............", "C": "0.2.1.3.0.2.1.2.0.3.2.1.0.3.2.3.", "F": "........0.2....."}},
            {"inst": "brass", "mode": "stab", "gain": 0.2, "dur": 1.0,
             "pat": {"C": "..............x."}},
            {"inst": "swell_rev", "mode": "stab", "gain": 0.4, "dur": 2.0,
             "pat": {"Y": "." * 30 + "x."}},
        ],
        pad=[{"inst": "choir_real" if real else "choir", "gain": 0.18, "vowel": "oh", "sections": "C"}],
        drum_gain={"U": 1.3},
        tilt=3.0, low=(150.0, -6.0),
        human=(0.005, 0.15) if real else None)


def sketch_bass_samples():
    # Six bass voices on the lift's riff, two bars each with a bar's rest between, so Ryan
    # can pick (24 September). In order: the soft sub, the sub with a pluck on it, the slap
    # bass, the real bass (the keys' one, undriven), the driven real bass, the crunch synth.
    voices = ["sub_bass", "sub_pluck", "slap_bass", "bass_real", "bass_real", "bass"]
    params = [{}, {}, {}, {"drive": 1.6}, {"drive": 2.6}, {"drive": 3.5, "cutoff": 800.0}]
    form = "".join("%sR" % chr(ord("A") + i) for i in range(len(voices)))   # A R B R C R ...
    pats = {}
    vs = []
    for i, (v, p) in enumerate(zip(voices, params)):
        sec = chr(ord("A") + i)
        vs.append({"inst": v, "mode": "riff", "gain": 0.6, "hold": 1.0, "params": p, "pat": {sec: "8-.c.8-a.8-.5-.38-.c.8-a.3-.5-.7"}})
    kit = {"kick": (variants(kick_real), 0.9), "snare": (variants(snare_real), 0.8), "hat": (variants(lambda p: hat_real(False, p)), 0.4)}
    drums = {"kick": {"*": "x..xx...x..xx.x.", "R": "................"}, "snare": {"*": "....x..o.x..x..o", "R": "................"},
             "hat": {"*": "x.x.x.x.x.x.x.x.", "R": "................"}}
    chords = {"*": [[8, 15, 19], [5, 12, 19]]}
    return groove(bpm=100, form=form, kit=kit, drums=drums, chords=chords, voices=vs, tilt=3.0, low=(150.0, -6.0), human=(0.005, 0.15))


# ---- the calm tracks (Ryan, 24 September): the map loop is the rift theme and the fight
# loop the human theme; these are their subdued siblings, background music that embraces
# the house roots more (a steady soft kick, off-beat opens, a pulsing sub, pumped and swept
# pads), each in its theme's palette. Not hooked in the game yet; a multi-track setup later.

def pad_sweep(semis, n, gain=0.14, octave=1, rate=0.05):
    # A house pad: saws under a low-pass that opens and closes slowly (two fixed filters
    # blended by a slow sine, so it costs nothing).
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        x += saws(f, n, (0.994, 1.0, 1.006))
    x /= max(1, len(semis))
    x = sat(x, 1.4)
    dark, bright = lp(x, 420.0), lp(x, 2600.0)
    m = 0.5 + 0.5 * np.sin(2.0 * math.pi * rate * t_of(n) + RNG.uniform(0.0, 6.0))
    return (dark * (1.0 - m) + bright * m) * gain


PAD_INST["sweep"] = lambda c, n, p: pad_sweep(c, n, p.get("gain", 0.14), p.get("octave", 1), p.get("rate", 0.05))


def music_rift_calm():
    # The rift theme's calm sibling, grown from the reprise: 6/8 at the 4/4 bar's length
    # throughout, the pulse a triplet, at 90. The choir on "oo" pumping, the bells in threes
    # with their long echo, cellos legato on the roots, a soft bass drum on one and three
    # with a sub pulsing under it, brushed hats in threes, glitch clicks and the odd stutter
    # (the rift's electronic side), horns and a harp coming and going, the violins once.
    # Seventy-two bars: an intro of pad and bells (I), the groove (A), the lift with the
    # violins and the harp (C), a breakdown with the choir and the bells' stutters (D), the
    # groove again with a violin counter-line (R), and an outro that thins to the pad and
    # wraps into the intro (O).
    m = MUSIC["music_rift_calm"]
    drum = variants(bassdrum_real)
    kit = {"kick": (drum, 1.0), "snare": (variants(snare_real), 0.35), "hat": (variants(lambda p: hat_real(False, p)), 0.3),
           "open": ([hat_real(True)], 0.22), "glitch": (glitch_perc(), 0.3), "timp": (variants(lambda p: timpani_real()), 0.6)}
    roots = "0-----------0-----------g-----------3-----------0-----------8-----------g-----------0-----------"
    return groove(
        bpm=m["bpm"], form=m["form"], meter=m["meter"], kit=kit,
        drums={
            "kick": {"A": "x.....x.....", "C": "x.....x.....", "R": "x.....x.....", "O": "x..........."},
            "snare": {"A": "......o.....", "C": "......x.....", "R": "......x....."},
            "hat": {"A": "x.x.x.x.x.x.", "C": "x.x.x.x.x.x.", "R": "x.x.x.x.x.x.", "O": "x..x..x..x.."},
            "open": {"A": ".........x..", "C": "...x.....x..", "R": "...x.....x.."},
            "glitch": {"I": "........x...", "A": "........x...........x......x.", "D": "....x.......x...x.......", "O": "........x..."},
            "timp": {"D": "x.......................x.......................x.......................x...........x.x.x.x."},
        },
        chords={"I": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                "A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17], [0, 7, 15], [8, 15, 19], [-2, 5, 10], [0, 7, 15]],
                "C": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22], [0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22]],
                "D": [[10, 17, 22], [10, 16, 22], [8, 15, 19], [0, 6, 13], [7, 14, 22], [7, 13, 22], [0, 7, 15], [0, 6, 13]],
                "R": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17], [0, 7, 15], [8, 15, 19], [-2, 5, 10], [0, 7, 15]],
                "O": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [0, 7, 15]]},
        voices=[
            {"inst": "cello", "mode": "riff", "gain": 0.3, "legato": True,
             "pat": {"A": roots, "C": "8-----------5-----------3-----------7-----------0-----------8-----------a-----------7-----------",
                     "R": roots, "O": "0-----------0-----------g-----------0-----------"}},
            {"inst": "cello", "mode": "riff", "gain": 0.3, "legato": True, "late": 2,
             "pat": {"D": "a-----------a-----------8-----------0-----------7-----------7-----------0-----------0-----------"}},
            {"inst": "cello", "mode": "riff", "gain": 0.2, "legato": True, "octave": 1, "late": 2,
             "pat": {"D": "5-----------4-----------3-----------6-----------2-----------1-----------7-----------6-----------"}},
            # The sub pulsing in threes: the house under the six-eight.
            {"inst": "sub_bass", "mode": "riff", "gain": 0.34, "hold": 0.6,
             "pat": {"A": "0.0.0.0.0.0.0.0.0.0.0.0.g.g.g.g.g.g.3.3.3.3.3.3.0.0.0.0.0.0.8.8.8.8.8.8.g.g.g.g.g.g.0.0.0.0.0.0.",
                     "R": "0.0.0.0.0.0.0.0.0.0.0.0.g.g.g.g.g.g.3.3.3.3.3.3.0.0.0.0.0.0.8.8.8.8.8.8.g.g.g.g.g.g.0.0.0.0.0.0.",
                     "C": "8.8.8.8.8.8.5.5.5.5.5.5.3.3.3.3.3.3.7.7.7.7.7.7.0.0.0.0.0.0.8.8.8.8.8.8.a.a.a.a.a.a.7.7.7.7.7.7."}},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.11, "echo": (3, 0.45, 3), "dur": 3.5,
             "pat": {"I": "0..2..1..3..", "A": "0..2..1..3..", "C": "0..2..1..3..0..3..2..1..", "R": "0..2..1..3..", "O": "0.....2.....",
                     "D": "0...........2...........1..........."}},
            {"inst": "bell_stutter", "mode": "chord", "octave": 3, "gain": 0.09, "echo": (3, 0.3, 2), "dur": 2.5,
             "pat": {"D": "......3.................1...............", "A": "........................................3......."}},
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.18, "dur": 3.0,
             "pat": {"A": "........................2..........................1....................................",
                     "C": "..................2.....1...............................................0..........."}},
            {"inst": "violin", "mode": "riff", "gain": 0.26, "octave": 2, "hold": 1.3,
             "pat": {"C": "7-----8--.7-----5--.3-----0--......3--.5--.7-----8-----a--.8-----7--.5-----3--......5--.3--.0-----",
                     "R": "................................................7-----8--.7--.5--.3-----........0--.3--.5--.3-----"}},
            {"inst": "harp", "mode": "chord", "octave": 2, "gain": 0.18, "dur": 1.2,
             "pat": {"C": "0.1.2.3.2.1.", "R": ".......................................0.1.2.3.2.1."}},
            {"inst": "swell_rev", "mode": "stab", "gain": 0.35, "dur": 2.0,
             "pat": {"D": "." * 94 + "x.", "O": "." * 94 + "x."}},
        ],
        pad=[{"inst": "choir", "gain": 0.24, "vowel": "oo", "pump": 0.25, "sections": "IAR"},
             {"inst": "choir", "gain": 0.2, "vowel": "ah", "sections": "DC"},
             {"inst": "sweep", "gain": 0.1, "sections": "ACRO", "rate": 0.04},
             {"inst": "strings", "gain": 0.12, "sections": "C"},
             {"inst": "choir", "gain": 0.24, "vowel": "oo", "pump": 0.25, "sections": "O", "swell": (1.0, 0.35)}],
        air=(0.35, 0.14), master=1.1, headroom=0.6, swap=REAL_MAP_SWAP, human=(0.007, 0.18))


def music_human_calm():
    # The human theme's calm sibling at 96, four-on-the-floor and soft: the kick on every
    # beat, hats in eighths with the open on the off-beats, a clap-soft snare on two and
    # four, the sub pulsing in eighths, the electric piano stabbing off the beat (the house
    # piano), the metal chime as the hook, the mechanical guitar muted and low as a rhythm,
    # the crunch synth filtered dark for one section, a synth lead in long notes once, the
    # choir under the breakdown, and the industry under it all (Ryan: it fits the background
    # brief): knocks and ticks, a clank now and then, crushed clicks, the guitar muted low as
    # a rhythm through the groove, the crunch synth dark under the sub. Seventy-two bars: the intro (I), the groove (A), a
    # breakdown (B), the lead's section (C), the dark synth's section (D), the groove again
    # (R) and an outro that thins to the pad and the chime (O).
    m = MUSIC["music_human_calm"]
    kit = {"kick": (variants(kick_real), 0.75), "snare": (variants(snare_real), 0.45), "hat": (variants(lambda p: hat_real(False, p)), 0.4),
           "open": ([hat_real(True)], 0.3), "ride": ([ride_real()], 0.3), "clank": (clank(), 0.25), "knock": (knock_perc(), 0.45),
           "tick": (tick(), 0.25), "glitch": (glitch_perc(), 0.3), "stack": ([stack()], 0.5)}
    pulse = "0.0.0.0.0.0.0.0.8.8.8.8.8.8.8.8.a.a.a.a.a.a.a.a.7.7.7.7.7.7.7.7.0.0.0.0.0.0.0.0.5.5.5.5.5.5.5.5.3.3.3.3.3.3.3.3.g.g.g.g.g.g.g.g."
    return groove(
        bpm=m["bpm"], form=m["form"], meter=m.get("meter"), kit=kit,
        drums={
            "kick": {"I": "x...x...x...x...", "A": "x...x...x...x...", "C": "x...x...x...x...", "D": "x...x...x...x...", "R": "x...x...x...x...", "O": "x...............x..............."},
            "snare": {"A": "....o.......o...", "C": "....x.......x...", "D": "....o.......o...", "R": "....x.......x..."},
            "hat": {"I": "x.x.x.x.x.x.x.x.", "A": "x.x.x.x.x.x.x.x.", "C": "x.x.x.x.x.x.x.x.", "D": "xxxxxxxxxxxxxxxx", "R": "x.x.x.x.x.x.x.x."},
            "open": {"I": "..x...x...x...x.", "A": "..x...x...x...x.", "C": "..x...x...x...x.", "R": "..x...x...x...x.", "O": "..x.......x....."},
            "ride": {"C": "x.x.x.x.x.x.x.x."},
            "clank": {"A": "..............x.................................................", "R": "..............x.................", "D": "..............x................."},
            "knock": {"A": "......x.......x.", "C": "......x.......x.", "R": "......x.......x.", "D": "..x...x...x...x."},
            "tick": {"A": "xxxxxxxxxxxxxxxx", "C": "xxxxxxxxxxxxxxxx", "R": "xxxxxxxxxxxxxxxx"},
            "glitch": {"I": "........x.......", "A": "...x.......x....x.........x.....", "D": "...x.......x....", "O": "........x......."},
            "stack": {"D": "..x...x...x...x."},
        },
        chords={"I": [[0, 7, 15]],
                "A": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10]],
                "B": [[0, 7, 15, 19], [8, 15, 19, 24], [10, 17, 22, 26], [7, 14, 22, 26]],
                "C": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10]],
                "D": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                "R": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10]],
                "O": [[0, 7, 15], [8, 15, 19], [7, 14, 22], [0, 7, 15]]},
        voices=[
            # The sub pulsing in eighths on the roots: the house floor.
            {"inst": "sub_bass", "mode": "riff", "gain": 0.4, "hold": 0.7, "params": {"punch": 0.3},
             "pat": {"I": "0.0.0.0.0.0.0.0.", "A": pulse, "C": pulse, "R": pulse, "D": "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.g.g.g.g.g.g.g.g.3.3.3.3.3.3.3.3."}},
            {"inst": "sub_bass", "mode": "riff", "gain": 0.36, "legato": True,
             "pat": {"B": "0---------------8---------------a---------------7---------------", "O": "0---------------8---------------7---------------0---------------"}},
            # The piano off the beat.
            {"inst": "epiano", "mode": "stab", "gain": 0.42, "dur": 1.5,
             "pat": {"A": "..x...x...x...x.", "C": "..x...x...x...x.", "R": "..x...x...x...x."}},
            {"inst": "epiano", "mode": "stab", "gain": 0.4, "dur": 8.0,
             "pat": {"B": "x.......x.......", "O": "x..............."}},
            # The chime as the hook, and the guitar muted and low as a rhythm.
            {"inst": "chime_metal", "mode": "chord", "octave": 2, "gain": 0.16, "echo": (3, 0.3, 2), "dur": 1.6,
             "pat": {"A": "0...2.1.....3...", "R": "0...2.1.....3...", "O": "0.......2......."}},
            {"inst": "guitar_real", "mode": "riff", "gain": 0.22, "octave": -1, "params": {"cutoff": 800.0},
             "pat": {"A": "0.0.0.0.0.0.0.0.8.8.8.8.8.8.8.8.a.a.a.a.a.a.a.a.7.7.7.7.7.7.7.7.0.0.0.0.0.0.0.0.5.5.5.5.5.5.5.5.3.3.3.3.3.3.3.3.g.g.g.g.g.g.g.g.",
                     "R": "0.0.0.0.0.0.0.0.8.8.8.8.8.8.8.8.a.a.a.a.a.a.a.a.7.7.7.7.7.7.7.7.0.0.0.0.0.0.0.0.5.5.5.5.5.5.5.5.3.3.3.3.3.3.3.3.g.g.g.g.g.g.g.g."}},
            {"inst": "guitar_real", "mode": "riff", "gain": 0.28, "octave": -1, "params": {"cutoff": 900.0},
             "pat": {"C": "0.0.0.0.0.0.0.0.8.8.8.8.8.8.8.8.a.a.a.a.a.a.a.a.7.7.7.7.7.7.7.7.0.0.0.0.0.0.0.0.5.5.5.5.5.5.5.5.3.3.3.3.3.3.3.3.g.g.g.g.g.g.g.g."}},
            # The crunch synth dark under the sub through the groove.
            {"inst": "bass", "mode": "riff", "gain": 0.2, "hold": 1.0, "params": {"drive": 3.0, "cutoff": 300.0},
             "pat": {"A": "0-------8-------a-------7-------0-------5-------3-------g-------", "R": "0-------8-------a-------7-------0-------5-------3-------g-------"}},
            # The lead in long notes, once; the crunch synth dark, once.
            {"inst": "lead", "mode": "riff", "gain": 0.28, "octave": 2,
             "pat": {"C": "7-------8-------7-------5-------3---------------5-------3-------0-------------------------------3-------5-------7-------8---------------"}},
            {"inst": "bass", "mode": "riff", "gain": 0.34, "hold": 1.0, "params": {"drive": 2.5, "cutoff": 380.0},
             "pat": {"D": "0--.3-.0-...1-..g--.3-.1-...3-.."}},
            {"inst": "brass", "mode": "stab", "gain": 0.16, "dur": 1.0,
             "pat": {"A": "." * 62 + "x.", "R": "." * 62 + "x."}},
        ],
        pad=[{"inst": "sweep", "gain": 0.12, "sections": "IACR", "rate": 0.06},
             {"inst": "choir_real", "gain": 0.2, "vowel": "oh", "sections": "B"},
             {"inst": "sweep", "gain": 0.14, "sections": "D", "rate": 0.12},
             {"inst": "sweep", "gain": 0.12, "sections": "O", "swell": (1.0, 0.3)}],
        tilt=2.0, low=(150.0, -4.0), air=(0.2, 0.08), human=(0.005, 0.15))


# ---- the sketches: eight bars each on one riff and one chord progression, so only the
# instruments differ. Rendered by `forge.py sketch` into tools/soundforge/out, never into
# the game, for Ryan to A/B (23 September).

SKETCH_FORM = "AACC AADD"
SKETCH_CHORDS = {"A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                 "C": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22]],
                 "D": [[10, 17, 22], [8, 15, 19], [-2, 5, 10], [0, 7, 15]]}
SKETCH_RIFF = {"A": "0--.3-.0-...1-..g--.3-.5-...3-..", "C": "8--.a-.8-..a.5-.3--.5-.7-..5.7-.",
               "D": "a---------------8-------g-------"}
SKETCH_CHIMES = {"A": "0.2.1.3.0.2.1.2.", "C": "0.2.1.3.0.2.1.2.0.3.2.1.0.3.2.3.", "D": "0...2...1...3...0...2...1.3....."}
SKETCH_ANSWER = {"A": "........3...2.1.", "C": "....3.2.....1...", "D": "........2.......3..............."}


def sketch_human():
    # The human side: FM keys and bells, a plucked bass, drums in a room, one knock. The
    # reconstruction's own music: precise, technical, warm.
    return groove(
        bpm=96, form=SKETCH_FORM,
        kit={"kick": (kick_drum(True), 0.9), "snare": (snare_drum(), 1.0), "hat": (hat(False, False), 0.6),
             "open": (hat(True, False), 0.45), "knock": (knock_perc(), 0.5)},
        drums={"kick": {"A": "x.......x..x....x.....x.x.......", "C": "x..x....x.....x.x..x....x...x...", "D": "x...............x...........o..."},
               "snare": {"A": "....x.......x...", "C": "....x.......x..o", "D": "....x.......x..."},
               "hat": {"A": "x.x.x.x.x.x.x.x.", "C": "x.xxx.x.x.xxx.x.", "D": "x...x...x...x..."},
               "open": {"C": "......x.......x."},
               "knock": {"A": "..............x.................", "C": "..........x....................."}},
        chords=SKETCH_CHORDS,
        voices=[
            {"inst": "pluck_bass", "mode": "riff", "gain": 0.7, "pat": SKETCH_RIFF},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.35, "echo": (3, 0.2), "dur": 2.5, "pat": SKETCH_CHIMES},
            {"inst": "epiano", "mode": "chord", "octave": 1, "gain": 0.45, "dur": 3.0, "pat": SKETCH_ANSWER},
            {"inst": "epiano", "mode": "stab", "gain": 0.3, "dur": 2.0,
             "pat": {"A": "..x...x...x...x.", "C": "..x.....x.x.....", "D": "x.......x......."}},
        ],
        pad={"inst": "strings", "gain": 0.08})


def sketch_rift():
    # The rift side: choir and strings under the groove, bells, orchestral hits at the
    # turns, a taiko for the kick, the crunch bass kept so the beat is still the game's.
    return groove(
        bpm=96, form=SKETCH_FORM,
        kit={"kick": (taiko(), 1.0), "snare": (snare_drum(True), 0.9), "hat": (hat(False, True), 0.5),
             "open": (hat(True, True), 0.4)},
        drums={"kick": {"A": "x.......x..x....x.....x.x.......", "C": "x..x....x.....x.x..x....x...x...", "D": "x...............x..............."},
               "snare": {"A": "....x.......x...", "C": "....x.......x..o", "D": "....x.......x..."},
               "hat": {"A": "..x...x...x...x.", "C": "x.x.x.x.x.x.x.x.", "D": "....x.......x..."},
               "open": {"C": "......x.......x."}},
        chords=SKETCH_CHORDS,
        voices=[
            {"inst": "bass", "mode": "riff", "gain": 0.55, "params": {"drive": 3.0, "cutoff": 800.0}, "pat": SKETCH_RIFF},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.3, "echo": (3, 0.2), "dur": 2.5, "pat": SKETCH_CHIMES},
            {"inst": "brass", "mode": "chord", "octave": 1, "gain": 0.3, "dur": 2.0, "pat": SKETCH_ANSWER},
            {"inst": "hit", "mode": "stab", "gain": 0.5, "dur": 3.0,
             "pat": {"A": "x...............................", "C": "x...............", "D": "x..............................."}},
        ],
        pad={"inst": "choir", "gain": 0.22, "vowel": "ah"})


def sketch_djent():
    # The progressive metal side: a chugged low string in a seven-step figure that walks
    # round the bar, the kick locked to it, the snare steady on two and four, bells over
    # it, the choir under the last section.
    return groove(
        bpm=96, form=SKETCH_FORM,
        kit={"kick": (kick_drum(True), 1.0), "snare": (snare_drum(), 1.1), "hat": (hat(False, True), 0.7),
             "open": (hat(True, True), 0.5), "clank": (clank(), 0.4)},
        drums={"kick": {"A": "x..x.x.", "C": "x..x.x.", "D": "x.......x......."},
               "snare": {"A": "....x.......x...", "C": "....x.......x...", "D": "........x......."},
               "hat": {"A": "x.x.x.x.x.x.x.x.", "C": "xxxxxxxxxxxxxxxx", "D": "x...x...x...x..."},
               "open": {"C": "......x.......x."},
               "clank": {"C": "..............x................."}},
        chords=SKETCH_CHORDS,
        voices=[
            {"inst": "chug", "mode": "riff", "gain": 0.8, "octave": -1,
             "pat": {"A": "0.0-3.0", "C": "8.8-a.8", "D": "a---------------8-------g-------"}},
            {"inst": "bass", "mode": "riff", "gain": 0.3, "params": {"drive": 4.0, "cutoff": 700.0}, "pat": SKETCH_RIFF},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.3, "echo": (3, 0.2), "dur": 2.5, "pat": SKETCH_CHIMES},
            {"inst": "brass", "mode": "stab", "gain": 0.25, "dur": 1.0,
             "pat": {"C": "..x...x...x...x."}},
        ],
        pad={"inst": "choir", "gain": 0.12, "vowel": "oh"})


SKETCHES = {"human": sketch_human, "rift": sketch_rift, "djent": sketch_djent,
            "map_86": lambda: music_map(86), "map_88": lambda: music_map(88), "map_92": lambda: music_map(92), "map_outro": sketch_map_outro}   # the map loop slightly slower, to compare (Ryan, 23 September)
OUT_SKETCH = os.path.join(os.path.dirname(__file__), "out")


# ---- the experiments (Ryan, 24 September): meters, and the far end of pseudo-realism

# -- realism: instruments built closer to the real thing, and hits that are never twice the same

def cabinet(x, peaks=((110.0, 1.0), (420.0, 0.9), (1150.0, 0.7), (2400.0, 0.5), (3600.0, 0.25))):
    """A guitar cabinet: the signal through a few resonant peaks, closed above 5 kHz."""
    y = np.zeros(len(x))
    for f, g in peaks:
        y += bp(x, f * 0.75, f * 1.3) * g
    return lp(y / 2.2 + x * 0.15, 5000.0)


def guitar_real(f, dur, mute=True, cutoff=None, clean=False):
    # A power chord on real-ish strings: root, fifth and octave as plucked strings a hair
    # apart, the pick's scrape, pre-emphasis into the gain, the cabinet, the palm.
    n = n_of(dur)
    x = np.zeros(n)
    for ratio, g in ((1.0, 1.0), (1.5, 0.7), (2.0, 0.5)):
        x += pluck(f * ratio * RNG.uniform(0.998, 1.002), dur, bright=RNG.uniform(0.4, 0.6), damp=0.993)[:n] * g
    scrape = bp(noise(n_of(0.012)), 2000.0, 7000.0) * env_ad(n_of(0.012), 0.0002, 0.003) * 0.6
    x = at(x, scrape, 0.0)[:n]
    if clean:
        # Less edge for a solo (Ryan): less gain, and a cabinet without its upper peaks.
        x = np.clip(sat(hp(x, 400.0) * 2.5 + x * 1.2, 2.0) * 1.2, -1.0, 1.0)
        x = cabinet(x, peaks=((110.0, 1.0), (420.0, 0.9), (1150.0, 0.6)))
    else:
        x = np.clip(sat(hp(x, 600.0) * 5.0 + x * 1.5, 3.0) * 1.3, -1.0, 1.0)
        x = cabinet(x)
    env = env_ad(n, 0.001, min(0.16, dur * 0.5), curve=3.0) if mute else env_ad(n, 0.001, dur * 0.7, curve=2.0)
    return mix(x * env, body(200.0, 90.0, 0.05, drive=2.0, click=0.2) * 0.3)


def lead_real(f, dur):
    # A lead guitar string: one string, sustain from the gain, vibrato arriving late, the
    # cabinet.
    n = n_of(dur)
    t = t_of(n)
    x = pluck(f, dur, bright=0.7, damp=0.9992)[:n]
    vib = 1.0 + 0.006 * np.sin(2.0 * math.pi * 5.4 * t) * np.clip((t - 0.12) / 0.2, 0.0, 1.0)
    idx = np.clip((np.cumsum(vib) - np.arange(n)).astype(int) + np.arange(n), 0, n - 1)
    x = x[idx]
    # The gain to carry a solo (Ryan: more distortion or the synth is better).
    x = np.clip(sat(hp(x, 400.0) * 14.0, 4.0) * 1.2, -1.0, 1.0)
    return cabinet(x) * env_pts(n, [(0.0, 0.0), (0.005, 1.0), (max(dur - 0.04, 0.02), 0.85), (dur, 0.0)]) * 0.9


def bass_real(f, dur, drive=2.6):
    # A bass guitar: two strings' worth of pluck, the finger's thump, the body's peak, the
    # amp's roll-off.
    n = n_of(dur)
    x = pluck(f, dur, bright=0.5, damp=0.998)[:n] + pluck(f * 1.001, dur, bright=0.3, damp=0.998)[:n] * 0.5
    x = x + bp(x, 80.0, 140.0) * 0.8
    thump = lp(noise(n_of(0.02)), 900.0) * env_ad(n_of(0.02), 0.0005, 0.006) * 0.5
    x = at(x, thump, 0.0)[:n]
    # More character than the first cut (Ryan: lame beside the guitar): driven harder, a
    # growl in the low mids, the amp open a little wider.
    x = np.clip(sat(x * drive, drive) * (1.0 + 0.15 * drive), -1.0, 1.0)   # the anger is the clip
    x = x + bp(x, 200.0, 500.0) * 0.5
    return hp(lp(x, 2200.0), 40.0) * 0.85


def strings_real(semis, n, gain=0.15, octave=1):
    # An ensemble: eight players a note, each with a vibrato of their own rate and depth
    # and their own late start, the bow's noise, the body's resonances, a hall.
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        for _ in range(8):
            d = RNG.uniform(0.994, 1.006)
            v = saws_vib(f * d, n, (1.0,), vib_hz=RNG.uniform(4.6, 6.4), vib_depth=RNG.uniform(0.003, 0.007))
            onset = n_of(RNG.uniform(0.0, 0.05))
            v = np.concatenate([np.zeros(onset), v])[:n]
            x += v
    x /= max(1, len(semis)) * 8.0
    bow = bp(noise(n), 2000.0, 5000.0) * 0.06
    x = lp(x, 3800.0) - lp(x, 220.0)
    x = x + bp(x, 260.0, 340.0) * 0.5 + bp(x, 550.0, 700.0) * 0.4 + bp(x, 1100.0, 1300.0) * 0.3
    return room(x + bow, decay=0.6, mix=0.3, cut=5000.0)[:n] * gain * 1.6


def violin_real(f, dur):
    n = n_of(dur)
    t = t_of(n)
    x = np.zeros(n)
    for _ in range(3):
        x += saws_vib(f * RNG.uniform(0.997, 1.003), n, (1.0,), vib_hz=RNG.uniform(5.0, 6.2), vib_depth=0.006 * np.clip((t - 0.1) / 0.15, 0.0, 1.0).mean())
    x /= 3.0
    bow = bp(noise(n), 2500.0, 6000.0) * env_pts(n, [(0.0, 0.5), (0.05, 0.15), (dur, 0.1)]) * 0.12
    x = lp(x, 4500.0) - lp(x, 260.0)
    x = x + bp(x, 280.0, 360.0) * 0.5 + bp(x, 1000.0, 1250.0) * 0.4
    return (x + bow) * env_pts(n, [(0.0, 0.0), (0.07, 1.0), (max(dur - 0.4, 0.08), 0.85), (max(dur - 0.15, 0.09), 0.3), (dur, 0.0)]) * 0.7


def cello_real(f, dur):
    n = n_of(dur)
    x = np.zeros(n)
    for _ in range(3):
        x += saws_vib(f * RNG.uniform(0.997, 1.003), n, (1.0,), vib_hz=RNG.uniform(4.2, 5.4), vib_depth=0.005)
    x /= 3.0
    bow = bp(noise(n), 1500.0, 4000.0) * env_pts(n, [(0.0, 0.4), (0.06, 0.12), (dur, 0.08)]) * 0.1
    x = lp(x, 2200.0)
    x = x + bp(x, 180.0, 240.0) * 0.6 + bp(x, 400.0, 520.0) * 0.4
    return (x + bow) * env_pts(n, [(0.0, 0.0), (0.06, 1.0), (max(dur - 0.4, 0.07), 0.9), (max(dur - 0.15, 0.08), 0.3), (dur, 0.0)]) * 0.8


def horn_real(f, dur):
    # A horn with the player in it: a scoop up to the pitch, lip noise on the front, the
    # bend of the tone growing with the breath, vibrato late.
    n = n_of(dur)
    t = t_of(n)
    scoop = 1.0 - 0.03 * np.exp(-t / 0.05)
    vib = 1.0 + 0.004 * np.sin(2.0 * math.pi * 5.0 * t) * np.clip((t - 0.15) / 0.2, 0.0, 1.0)
    fr = f * scoop * vib
    ph = 2.0 * math.pi * np.cumsum(fr) / SR
    idx = 1.4 * (1.0 - np.exp(-t / 0.15))
    x = np.sin(ph + idx * np.sin(ph)) + 0.3 * np.sin(2.0 * ph + idx * np.sin(ph))
    lip = bp(noise(n), 800.0, 2500.0) * env_ad(n, 0.002, 0.03) * 0.25
    x = lp(sat(x + lip, 1.5), 2600.0)
    return room(x, decay=0.3, mix=0.2, cut=4000.0)[:n] * env_pts(n, [(0.0, 0.0), (0.06, 1.0), (max(dur - 0.06, 0.08), 0.8), (dur, 0.0)]) * 0.8


def choir_real(semis, n, gain=0.2, vowel="ah", octave=1):
    # More singers, each with breath and a start of their own, the formants wider.
    x = np.zeros(n)
    for s in semis:
        f = E2 * 2.0 ** (s / 12.0) * (2 ** octave)
        for _ in range(7):
            v = saws_vib(f * RNG.uniform(0.992, 1.008), n, (1.0,), vib_hz=RNG.uniform(4.4, 6.0), vib_depth=RNG.uniform(0.004, 0.007))
            onset = n_of(RNG.uniform(0.0, 0.08))
            x += np.concatenate([np.zeros(onset), v])[:n]
    x /= max(1, len(semis)) * 7.0
    f1, f2, f3 = VOWELS[vowel]
    y = bp(x, f1 * 0.75, f1 * 1.3) * 1.0 + bp(x, f2 * 0.8, f2 * 1.22) * 0.5 + bp(x, f3 * 0.85, f3 * 1.16) * 0.2
    breath = bp(noise(n), 1500.0, 5000.0) * 0.04
    return room(y + breath, decay=0.7, mix=0.3, cut=4000.0)[:n] * gain * 2.2


def kick_real(pitch=1.0):
    # A real kick: the skin's pitch falling from 130 to 50, the beater's click, the shell's
    # tone, a little room.
    n = n_of(0.45)
    t = t_of(n)
    f = (50.0 + 80.0 * np.exp(-t / 0.05)) * pitch
    skin = np.sin(2.0 * math.pi * np.cumsum(f) / SR) * env_ad(n, 0.001, 0.14, curve=3.0)
    beater = bp(noise(n_of(0.006)), 2000.0, 6000.0) * env_ad(n_of(0.006), 0.0002, 0.0015) * 0.9
    shell = harmonics(180.0 * pitch, n, [0.5, 0.3, 0.15]) * env_ad(n, 0.001, 0.02) * 0.4
    return room(mix(sat(skin, 1.6), at(np.zeros(1), beater, 0.0), shell), decay=0.12, mix=0.12, cut=3000.0)


def snare_real(pitch=1.0):
    # A real snare: the top head's tone, the shell, the wires rattling under it, the
    # stick's crack, and the room.
    # Shorter than the first cut (Ryan: a little long, the echo cool): the wires die
    # quicker, the room stays but is brief.
    n = n_of(0.22)
    tone = harmonics(185.0 * pitch, n, [1.0, 0.6, 0.3]) * env_ad(n, 0.0005, 0.045) * 0.7
    shell = harmonics(330.0 * pitch, n, [0.6, 0.3]) * env_ad(n, 0.0005, 0.025) * 0.4
    wires = bp(noise(n), 1500.0, 9000.0) * env_ad(n, 0.001, 0.055, curve=2.5) * (0.7 + 0.3 * np.abs(tone / (np.max(np.abs(tone)) + 1e-9)))
    crack = bp(noise(n_of(0.008)), 3000.0, 10000.0) * env_ad(n_of(0.008), 0.0001, 0.002) * 0.9
    return room(mix(tone, shell, wires * 0.9, at(np.zeros(1), crack, 0.0)), decay=0.14, mix=0.24, cut=8000.0)


def hat_real(open_=False, pitch=1.0):
    n = n_of(0.5 if open_ else 0.07)
    partials = knock([3100.0 * pitch, 4700.0 * pitch, 6900.0 * pitch, 9300.0 * pitch, 11800.0 * pitch],
                     [0.18, 0.15, 0.12, 0.1, 0.08] if open_ else [0.02, 0.018, 0.015, 0.012, 0.01],
                     [0.5, 0.45, 0.4, 0.3, 0.2], noise_gain=0.0)
    wash = bp(noise(n), 4000.0, 14000.0) * env_ad(n, 0.001, 0.14 if open_ else 0.015)
    return mix(partials * 0.5, wash * 0.6) * 0.4


def ride_real():
    # A soft ride, not a bell hit (Ryan, 24 September, third time): the wash of the plate
    # and a soft tick, no partials to speak of, closed above 5 kHz.
    n = n_of(0.7)
    return lp(mix(bp(noise(n), 1500.0, 6000.0) * env_ad(n, 0.002, 0.16) * 0.35,
                  knock([1900.0, 2800.0], [0.25, 0.18], [0.3, 0.2], noise_gain=0.0) * 0.2,
                  bp(noise(n_of(0.012)), 2000.0, 5000.0) * env_ad(n_of(0.012), 0.0003, 0.003) * 0.4), 5000.0) * 0.5


def crash_real():
    # Shorter than a real one (Ryan: it lasted way too long).
    n = n_of(1.1)
    return mix(bp(noise(n), 2000.0, 15000.0) * env_ad(n, 0.002, 0.28, curve=2.0),
               knock([2900.0, 4300.0, 6400.0, 8100.0], [0.4, 0.3, 0.22, 0.18], [0.4, 0.3, 0.25, 0.2], noise_gain=0.0) * 0.4) * 0.35


def timpani_real():
    n = n_of(1.2)
    t = t_of(n)
    f = 62.0 * (1.0 + 0.06 * np.exp(-t / 0.08))
    skin = np.sin(2.0 * math.pi * np.cumsum(f) / SR) * env_ad(n, 0.002, 0.35) + harmonics(62.0, n, [0.0, 0.5, 0.3, 0.2]) * env_ad(n, 0.002, 0.2) * 0.5
    mallet = lp(noise(n_of(0.02)), 1500.0) * env_ad(n_of(0.02), 0.0003, 0.005) * 0.5
    return room(mix(skin, at(np.zeros(1), mallet, 0.0)), decay=0.6, mix=0.3, cut=2500.0)


def variants(fn, k=3):
    """Several renderings of a hit, each a hair different in pitch, so no two are the same."""
    return [fn(RNG.uniform(0.96, 1.04)) for _ in range(k)]


NOTE_INST["guitar_real"] = lambda f, d, p: guitar_real(f, d, p.get("mute", True), clean=p.get("clean", False))
NOTE_INST["lead_real"] = lambda f, d, p: lead_real(f, d)
NOTE_INST["bass_real"] = lambda f, d, p: bass_real(f, d, p.get("drive", 2.6))
NOTE_INST["violin_real"] = lambda f, d, p: violin_real(f, d)
NOTE_INST["cello_real"] = lambda f, d, p: cello_real(f, d)
NOTE_INST["horn_real"] = lambda f, d, p: horn_real(f, d)
PAD_INST["strings_real"] = lambda c, n, p: strings_real(c, n, p.get("gain", 0.15))
PAD_INST["choir_real"] = lambda c, n, p: choir_real(c, n, p.get("gain", 0.2), p.get("vowel", "ah"))
STAB_INST["hit_real"] = lambda semis, dur: room(mix(strings_real(semis, n_of(dur), 1.0)[: n_of(dur)] * env_ad(n_of(dur), 0.01, dur * 0.3),
                                                   mix(*[horn_real(E2 * 2.0 ** (s / 12.0) * 2.0, dur) for s in semis]) / len(semis) * 0.6,
                                                   timpani_real()[: n_of(dur)] * 0.6), decay=0.5, mix=0.3)


# -- the realism sketches: the first sixteen bars of each loop (the groove and the lift) on
# the real-ish palette, hits varied, timing and velocity humanised.

def sketch_real_map():
    return groove(
        bpm=92, form="AAAAAAAB CCCCCCCB",
        kit={"kick": (variants(lambda p: lp(timpani_real(), 900.0 * p)), 0.7), "snare": (variants(snare_real), 0.55),
             "hat": (variants(lambda p: hat_real(False, p)), 0.5), "open": ([hat_real(True)], 0.4),
             "timp": (variants(lambda p: timpani_real()), 0.8)},
        drums={"kick": {"A": "x.......x.......", "B": "x.......x.....x.", "C": "x.......x.....x."},
               "snare": {"A": "....x.......x...", "B": "....x.......x..o", "C": "....x.......x..o"},
               "hat": {"A": "..x...x...x...x.", "B": "..x...x...x...x.", "C": "x.x.x.x.x.x.x.x."},
               "open": {"C": "......x.......x."},
               "timp": {"B": "..............x."}},
        chords={"A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]], "B": [[0, 7, 15]],
                "C": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22]]},
        voices=[
            {"inst": "cello_real", "mode": "riff", "gain": 0.4, "legato": True,
             "pat": {"A": "0------.3------.0---....1-------g------.3------.5---....3-------", "B": "0------.3------.0-------5-------"}},
            {"inst": "bass_real", "mode": "riff", "gain": 0.5,
             "pat": {"C": "8--.a-.8-..a.5-.3--.5-.7-..5.7-."}},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.2, "echo": (3, 0.4, 3), "dur": 3.5,
             "pat": {"A": "0.2.1.3.0.2.1.2.", "C": "0.2.1.3.0.2.1.2.0.3.2.1.0.3.2.3."}},
            {"inst": "horn_real", "mode": "chord", "octave": 1, "gain": 0.3, "dur": 3.0,
             "pat": {"A": "........3...2.1.", "C": "....3.2.....1..."}},
            {"inst": "violin_real", "mode": "riff", "gain": 0.26, "octave": 2,
             "pat": {"C": "........7--.8-.7........5.3-.0--"}},
            {"inst": "hit_real", "mode": "stab", "gain": 0.35, "dur": 3.0, "pat": {"C": "x" + "." * 127}},
        ],
        pad=[{"inst": "choir_real", "gain": 0.24, "vowel": "oo", "pump": 0.15, "sections": "ABC"},
             {"inst": "strings_real", "gain": 0.18, "sections": "C"}],
        air=(0.35, 0.14), human=(0.007, 0.18))


def sketch_real_skirmish():
    return groove(
        bpm=100, form="AAAAAAAB CCCCCCCB",
        kit={"kick": (variants(kick_real), 1.1), "snare": (variants(snare_real), 1.0),
             "hat": (variants(lambda p: hat_real(False, p)), 0.5), "open": ([hat_real(True)], 0.4),
             "crash": ([crash_real()], 1.0), "ride": ([ride_real()], 0.7),
             "tom": (variants(lambda p: tom(150.0 * p)), 0.8), "tom2": (variants(lambda p: tom(110.0 * p)), 0.8)},
        drums={"kick": {"A": "x.xx.x.", "B": "x.xx.x.x.xx.x.x.x.xx.x.x.xxxxxxx", "C": "x..xx...x..xx.x."},
               "snare": {"A": "....x.......x...", "B": "....x.......x...", "C": "....x..o.x..x..o"},
               "hat": {"A": "x.x.x.x.x.x.x.x.", "B": "x.x.x.x.x.x.x.x."},
               "ride": {"C": "x.x.x.x.x.x.x.x."},
               "open": {"C": "......x.......x."},
               "crash": {"*": "x" + "." * 63},
               "tom": {"B": "........x.x.xx.x"}, "tom2": {"B": "..............x."}},
        chords={"A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]], "B": [[0, 7, 15]],
                "C": [[8, 15, 19], [5, 12, 19], [3, 10, 17], [7, 14, 22]]},
        voices=[
            {"inst": "guitar_real", "mode": "riff", "gain": 0.75, "octave": -1,
             "pat": {"A": "0.0-3.0", "B": "0.0-3.0.0.0-3.0.0.0-5.0.0.3-g.0.", "C": "8.8-a.8"}},
            {"inst": "bass_real", "mode": "riff", "gain": 0.55,
             "pat": {"A": "0--.3-.0-...1-..g--.3-.5-...3-..", "B": "0--.3-.0-...5-..3--.1-.0-...g-..", "C": "8-.c.8-a.8-.5-.38-.c.8-a.3-.5-.7"}},
            {"inst": "lead_real", "mode": "riff", "gain": 0.45, "octave": 2,
             "pat": {"C": "7--.8-.7-..5.3-.0---....3-.5-.7-8--.a-.8-..7.5-.3---....5-.3-.0-"}},
            {"inst": "epiano", "mode": "stab", "gain": 0.45, "dur": 1.5, "pat": {"C": "..x...x...x...x."}},
            {"inst": "chime_metal", "mode": "chord", "octave": 2, "gain": 0.2, "echo": (3, 0.25, 2), "dur": 1.6,
             "pat": {"A": "0...............2..............."}},
        ],
        pad=[{"inst": "choir_real", "gain": 0.16, "vowel": "oh", "sections": "C"}],
        tilt=3.0, low=(150.0, -6.0), air=(0.18, 0.08), human=(0.005, 0.15))


# -- the meter sketches: the loops' own palettes, the bars changing length. The skirmish
# alternates 4/4 and 3/4 (Ryan's four-three) then runs a 7/8 section; the map goes to 5/4
# for the strings and 6/8 for an interlude.

def sketch_meter_skirmish():
    return groove(
        bpm=100, form="AAAA FTFTFTFT VVVVVVVV AAAA",
        meter={"T": 12, "V": 14},
        kit={"kick": (kick_metal(), 1.15), "snare": (snare_metal(), 1.0), "hat": (hat(False, True), 0.45),
             "open": (hat(True, True), 0.4), "crash": (crash(), 1.0), "china": (china(), 0.9), "ride": (ride(), 0.8),
             "tom": (tom(150.0), 0.8)},
        drums={"kick": {"A": "x.xx.x.", "F": "x.xx..x.x.......", "T": "x.....x.x.x.", "V": "x..x..x.xx..x."},
               "snare": {"A": "....x.......x...", "F": "....x.......x...", "T": "....x...x..o", "V": "....x.....x..o"},
               "hat": {"A": "x.x.x.x.x.x.x.x.", "F": "x.x.x.x.x.x.x.x.", "T": "x.x.x.x.x.x.", "V": "x.x.x.x.x.x.x."},
               "open": {"T": "..........x.", "V": "............x."},
               "crash": {"*": "x" + "." * 63},
               "china": {"V": "......x......."},
               "tom": {"T": "..........xx"}},
        chords={"A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                "F": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22]], "T": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22]],
                "V": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17], [0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22]]},
        voices=[
            {"inst": "chug", "mode": "riff", "gain": 0.75, "octave": -1,
             "pat": {"A": "0.0-3.0", "F": "0.0-3.0.0.0-5.0.", "T": "0.0-3.0.0.0-", "V": "0.0-3.0.0.0-5.3"}},
            {"inst": "bass_guitar", "mode": "riff", "gain": 0.5,
             "pat": {"A": "0--.3-.0-...1-..g--.3-.5-...3-..", "F": "0--.3-.0-...5-..", "T": "3--.1-.0-.g.", "V": "0--.3-.5-.3.0-"}},
            {"inst": "lead", "mode": "riff", "gain": 0.45, "octave": 2,
             "pat": {"F": "7--.8-.7-..5.3-.", "T": "0---....3-.5", "V": "7-.8-.7.5-.3-."}},
            {"inst": "epiano", "mode": "stab", "gain": 0.45, "dur": 1.5, "pat": {"F": "..x...x...x...x.", "T": "..x...x...x."}},
            {"inst": "chime_metal", "mode": "chord", "octave": 2, "gain": 0.2, "echo": (3, 0.25, 2), "dur": 1.6,
             "pat": {"V": "0.....2......."}},
        ],
        pad=[{"inst": "choir", "gain": 0.16, "vowel": "oh", "sections": "V"}],
        tilt=3.0, low=(150.0, -6.0))


def sketch_meter_map():
    # The map's palette with the bars changing length (Ryan, 24 September: 5/4 did not
    # work by jamming the tune into it; an interlude that moves on unexpectedly to a bar of
    # 7/8 now and then could; 6/8 has merit, and its triplets riding the 4/4 bar too). The
    # groove, the interlude with a 7/8 bar at two of its phrase ends, a 6/8 section at the
    # 4/4 bar's length (the pulse a triplet of the groove's), the groove again.
    return groove(
        bpm=90, form="AAAA DDDDDDDZ DDDDDZDD XXXXXXXX AAAA",
        meter={"Z": 14, "X": (12, 4.0 / 3.0)},
        kit={"kick": (taiko_soft(), 0.8), "snare": (snare_drum(True), 0.7), "hat": (hat(False, True), 0.35),
             "open": (hat(True, True), 0.3), "timp": (timpani(), 0.8)},
        drums={"kick": {"A": "x.......x.......", "D": "x...............", "Z": "x.....x.......", "X": "x.....x....."},
               "snare": {"A": "....x.......x...", "D": "........x.......", "Z": "......x.....x.", "X": "......x....."},
               "hat": {"A": "..x...x...x...x.", "D": "....x.......x...", "Z": "..x...x...x...", "X": "x.x.x.x.x.x."},
               "timp": {"D": "x...............x...............x...............x.........x.x...", "Z": "x.........x...", "X": "x..........."}},
        chords={"A": [[0, 7, 15], [0, 7, 15], [-2, 5, 10], [3, 10, 17]],
                "D": [[10, 17, 22], [10, 16, 22], [8, 15, 19], [0, 6, 13], [7, 14, 22], [7, 13, 22], [0, 7, 15]],
                "Z": [[0, 6, 13]],
                "X": [[0, 7, 15], [8, 15, 19], [10, 17, 22], [7, 14, 22], [0, 7, 15], [5, 12, 19], [3, 10, 17], [-2, 5, 10]]},
        voices=[
            {"inst": "cello", "mode": "riff", "gain": 0.32, "legato": True,
             "pat": {"A": "0------.3------.0---....1-------g------.3------.5---....3-------"}},
            {"inst": "cello", "mode": "riff", "gain": 0.4, "legato": True, "late": 2,
             "pat": {"D": "a---------------8---------------g---------------0---------------", "Z": "0-------------"}},
            {"inst": "contrabass", "mode": "riff", "gain": 0.55, "hold": 1.25,
             "pat": {"X": "0..0..3..3..a..a..7..7..0..0..5..5..3..3..g..g.."}},
            {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.2, "echo": (3, 0.4, 3), "dur": 3.5,
             "pat": {"A": "0.2.1.3.0.2.1.2.", "D": "0...2...1...3...0...2...1.3.....0.2...1...3.....0...2...1.3.....",
                     "Z": "0...2...1.3...", "X": "0..2..1..3..0..2..3..1.."}},
            {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.36, "dur": 3.0,
             "pat": {"A": "........3...2.1.", "X": "......2.....1..........."}},
            {"inst": "violin", "mode": "riff", "gain": 0.26, "octave": 2,
             "pat": {"X": "7-.8-.7-.5-.3-.0-....3-.5-.7-.8-.a-.8-.7-.5-.3-....."}},
            {"inst": "harp", "mode": "chord", "octave": 2, "gain": 0.2, "dur": 1.2,
             "pat": {"X": "0.1.2.3.2.1."}},
        ],
        pad=[{"inst": "choir", "gain": 0.26, "vowel": "oo", "pump": 0.2, "sections": "A"},
             {"inst": "strings", "gain": 0.18, "sections": "DZ", "late": 4},
             {"inst": "strings", "gain": 0.16, "sections": "X"},
             {"inst": "choir", "gain": 0.18, "vowel": "ah", "sections": "DZX"}],
        air=(0.3, 0.12))


SKETCHES.update({"map_synth": lambda: music_map(palette="synth"), "skirmish_synth": lambda: music_skirmish(palette="synth"),
                 "bass_samples": sketch_bass_samples,
                 "meter_map": sketch_meter_map, "meter_skirmish": sketch_meter_skirmish})


SOUNDS = {
    "ui_tap": ui_tap, "ui_back": ui_back, "plot": plot,
    "codex_open": codex_open, "codex_close": codex_close, "menu_open": menu_open,
    "die_pick": die_pick, "die_drop": die_drop, "die_roll": die_roll, "die_lock": die_lock,
    "shield_up": shield_up, "vent": vent,
    "hit": hit, "hit_crit": hit_crit, "block": block, "shield_break": shield_break, "kill": kill,
    "arrival": arrival, "step": step, "resolve": resolve,
    "contact": contact, "engage": engage, "cut": cut, "gate_hit": gate_hit, "spawn": spawn,
    "victory": victory, "defeat": defeat, "withdraw": withdraw, "overheat": overheat,
    "laser": laser, "gunfire": gunfire, "cannon": cannon, "slash": slash, "slam": slam,
    "music_map": music_map, "music_skirmish": music_skirmish,
    "music_rift_calm": music_rift_calm, "music_human_calm": music_human_calm,
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
    "laser": -11, "gunfire": -11, "cannon": -8, "slash": -12, "slam": -9,
    "music_map": -24.9, "music_skirmish": -20.7,   # mean RMS dB, pinned where Ryan judged them
    "music_rift_calm": -26.9, "music_human_calm": -23.7,   # the calm siblings, a little under their themes
}


def read(name):
    with wave.open(os.path.join(OUT, name + ".wav"), "rb") as w:
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2") / 32767.0
        return x, w.getframerate()


def main(argv):
    if len(argv) < 1 or argv[0] not in ("build", "list", "measure", "sketch", "sections", "audition"):
        print(__doc__)
        return 2
    if argv[0] == "audition":
        # Every effect as built, one after another with a second between, into one file,
        # and where each one starts.
        os.makedirs(OUT_SKETCH, exist_ok=True)
        parts, when, t = [], [], 0.0
        for name in [n for n in SOUNDS if not n.startswith("music_")]:
            x, sr = read(name)
            when.append((t, name))
            parts.append(x)
            parts.append(np.zeros(sr))
            t += (len(x) + sr) / sr
        pcm = (np.clip(np.concatenate(parts), -1.0, 1.0) * 32767.0).astype("<i2")
        path = os.path.join(OUT_SKETCH, "audition_effects.wav")
        with wave.open(path, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm.tobytes())
        for t0, name in when:
            print("  %d:%04.1f  %s" % (int(t0 // 60), t0 % 60, name))
        print(os.path.relpath(path))
        return 0
    if argv[0] == "sections":
        for name in argv[1:] or list(MUSIC):
            runs, total = sections(name)
            print("%s  (%d bpm, %d bars, %d:%02d)" % (name, MUSIC[name]["bpm"], len(MUSIC[name]["form"].replace(" ", "")), int(total // 60), int(total % 60)))
            for sec, b0, b1, t, what in runs:
                m, sec_ = divmod(round(t, 1), 60)
                print("  %s  bars %2d-%2d  %d:%04.1f  %s" % (sec, b0, b1, int(m), sec_, what))
        return 0
    if argv[0] == "sketch":
        # Eight bars in a direction, into tools/soundforge/out, never into the game.
        os.makedirs(OUT_SKETCH, exist_ok=True)
        for name in argv[1:] or list(SKETCHES):
            seed("sketch_" + name)
            x = SKETCHES[name]()
            x = limit(x * 10.0 ** ((-16.0 - loudness(x)) / 20.0))
            pcm = (np.clip(x, -1.0, 1.0) * 32767.0).astype("<i2")
            path = os.path.join(OUT_SKETCH, "sketch_%s.wav" % name)
            with wave.open(path, "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(SR)
                w.writeframes(pcm.tobytes())
            print("%-16s %5.2f s  %s" % (name, len(x) / SR, os.path.relpath(path)))
        return 0
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
