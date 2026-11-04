"""Real bass voices for the pairs' sketches (Ryan, 4 November: "Yes, build me some real bass options,
please"), built as a bass rather than as the forge's guitar string tuned down.

Why (the fourteenth round of Night Shift): the forge's basses, `bass_real` and Night Shift's finger
and slap voices, are its plucked string (`forge.pluck`, Karplus-Strong) an octave or two down. That
loop loses a little brightness once a pass round it, and a low note makes few passes a second, so on
E1 a 2 kHz overtone takes 2.3 s to fall to a third and the fundamental 12 s: on a held E1 their 800
to 2000 Hz sat 5 to 11 dB over the fundamental for the whole note, where the synth bass's sat 20 to
25 under. A second string a hair sharp, a burst as bright as a pick, a fast compressor and a
mid-heavy cabinet made each a guitar with gain on, as Ryan heard ("The others still sound like
dropped guitars with gain on").

So a note here is the string's own modes summed. Partial k sits at k f0, stretched by the string's
stiffness; its strength is the pluck's shape at its place along the string, softened by a fingertip
or sharp from a pick, as a magnetic pickup at its own place reads it (the pickup hears the string's
velocity, so it has a comb of its own, and its coil and the cable lift a resonance and roll off
above it); and it decays at a rate set in seconds by its frequency, so the overtones die in a
fraction of a second while the fundamental rings. The pitch starts a few cents sharp, settling as the
string's tension does; a fifth of the string's motion is in its other plane, a hair sharp and
decaying slower; the player mutes it at the note's end. Then a direct box, or a bass amp as a
bassist drives one: the lows kept clean under a split, the mids and highs pushed into an asymmetric
stage, through a bass cabinet.

    real_bass(f, dur, preset="finger", amp="di")
"""
import math

import numpy as np

import forge as F

SR = F.SR
TOP = 9000.0   # the highest partial built

# Each partial's decay rate (1/s) by its frequency, a + b f + c f^2.
STRINGS = {
    "round": (1.2, 0.0045, 1.6e-6),   # roundwounds: the fundamental's T60 about 5 s, 1 kHz's about 1 s, 2 kHz's about 0.4 s
    "flat": (1.6, 0.009, 6.0e-6),     # flatwounds: 1 kHz's about 0.4 s, 2 kHz's about 0.15 s
}

# Each player and bass: `pluck` where the string is plucked and `pickup` where it is read, as a
# share of its length from the bridge; `soft` the excitation's corner (a fingertip's about 1.5 kHz,
# a thumb's lower, a pick's 4 to 5 kHz); `stiff` the string's inharmonicity; `res` the pickup's
# resonance (Hz, Q); `glide` the pitch at the pluck (cents sharp); `tone` the tone control rolled
# back (Hz) or open; `click` a pick's contact on the string.
PRESETS = {
    "finger": dict(pluck=0.22, soft=1500.0, strings="round", stiff=1.2e-4, pickup=0.19, res=(2800.0, 1.3), glide=5.0, tone=None, click=0.0),
    "bridge": dict(pluck=0.11, soft=2000.0, strings="round", stiff=1.2e-4, pickup=0.11, res=(3500.0, 1.5), glide=5.0, tone=None, click=0.0),
    "pick": dict(pluck=0.15, soft=4500.0, strings="round", stiff=1.2e-4, pickup=0.19, res=(3000.0, 1.4), glide=9.0, tone=None, click=0.05),
    "flat": dict(pluck=0.30, soft=900.0, strings="flat", stiff=1.0e-4, pickup=0.19, res=(2500.0, 1.0), glide=3.0, tone=1800.0, click=0.0),
}

# The amps: (the split under which the lows stay clean, the drive, the driven band's share, a push
# at 500 to 1300 Hz before the drive). "di" is a direct box.
AMPS = {
    "grit": (250.0, 2.2, 0.7, 0.0),     # a touch: an amp just breaking up in the mids
    "driven": (200.0, 6.0, 1.0, 0.6),   # driven hard with the mids pushed, as a rock bassist's drive
}
GLIDE_TAU = 0.08   # how fast the pluck's sharp pitch settles (s)
MUTE = 0.03        # the player's mute over the note's last 30 ms
PAD = 0.06         # the silence each note's filters run into, so nothing wraps round to its front


def _padded(x, fn):
    """A zero-phase filter on a note with room after it, so the filter's smear never wraps round."""
    return fn(np.concatenate([x, np.zeros(F.n_of(PAD))]))[:len(x)]


def string(f0, dur, preset="finger"):
    """The string through its pickup, unamplified, its body at a quarter of full scale."""
    p = PRESETS[preset]
    n = F.n_of(dur)
    if n < 8:
        return np.zeros(max(n, 0))
    rng = F.RNG
    beta = p["pluck"] * rng.uniform(0.93, 1.07)    # where the finger lands moves a little, note to note
    soft = p["soft"] * rng.uniform(0.92, 1.08)
    delta = 2.0 ** (p["glide"] * rng.uniform(0.7, 1.3) / 1200.0) - 1.0
    a, b, c = STRINGS[p["strings"]]
    fr, q = p["res"]
    t = np.arange(n) / SR
    warp = t + delta * GLIDE_TAU * (1.0 - np.exp(-t / GLIDE_TAU))   # time as the sharp start bends it
    out = np.zeros(n)
    k = 1
    while True:
        fk = k * f0 * math.sqrt(1.0 + p["stiff"] * k * k)
        if fk > TOP or fk > SR * 0.45:
            break
        amp = math.sin(math.pi * k * beta) * math.sin(math.pi * k * p["pickup"]) / k
        amp /= math.sqrt(1.0 + (fk / soft) ** 4)
        r = fk / fr
        amp /= math.sqrt((1.0 - r * r) ** 2 + (r / q) ** 2)
        if p["tone"]:
            amp /= math.sqrt(1.0 + (fk / p["tone"]) ** 4)
        sigma = a + b * fk + c * fk * fk
        life = min(n, int(math.log(1e4) / (0.6 * sigma) * SR) + 1)   # until even the slower plane is 80 dB down
        if abs(amp) > 1e-7:
            tt = t[:life]
            ph = 2.0 * math.pi * fk * warp[:life]
            out[:life] += amp * (0.8 * np.exp(-sigma * tt) * np.sin(ph) + 0.2 * np.exp(-0.6 * sigma * tt) * np.sin(ph * 1.0003))
        k += 1
    if p["click"]:
        m = F.n_of(0.003)
        out[:m] += F.bp(F.noise(m), 1500.0, 6000.0) * F.env_ad(m, 0.0002, 0.0012) * p["click"] * np.max(np.abs(out[:F.n_of(0.05)]))
    body = out[:F.n_of(0.1)]
    out = out / (np.sqrt(np.mean(body ** 2)) + 1e-9) * 0.25
    m = min(n, F.n_of(MUTE))
    out[n - m:] *= np.exp(-np.arange(m) / (0.25 * m)) * np.linspace(1.0, 0.0, m) ** 0.5   # the mute
    return out


def cabinet(x):
    """A bass cabinet: the lows held from 45 Hz, a broad lift round 100 Hz, closed above 4 kHz."""
    y = x + F.bp(x, 70.0, 180.0) * 0.25
    return F.lp(F.hp(y, 45.0), 4200.0, order=3)


def amplified(x, amp):
    """The string into a direct box, or into a bass amp with its lows clean under the split."""
    if amp == "di":
        return _padded(x, lambda y: F.hp(y, 30.0))
    split, drive, share, push = AMPS[amp]
    low = _padded(x, lambda y: F.lp(y, split))
    high = x - low
    if push:
        high = high + _padded(high, lambda y: F.bp(y, 500.0, 1300.0)) * push
    h = (np.tanh(high * drive + 0.2) - math.tanh(0.2)) / math.tanh(drive)
    h = _padded(h, lambda y: F.lp(y, 3500.0, order=4))
    return _padded(low + share * h, cabinet)


def real_bass(f, dur, preset="finger", amp="di"):
    return amplified(string(f, dur, preset), amp)


F.NOTE_INST["real_bass"] = lambda f, d, p: real_bass(f, d, p.get("preset", "finger"), p.get("amp", "di"))
