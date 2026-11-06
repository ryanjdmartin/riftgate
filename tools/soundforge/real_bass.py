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
    "fresh": (1.0, 0.0032, 1.0e-6),   # new roundwounds: 2 kHz's about 0.6 s, the modern clank
    "gut": (2.6, 0.012, 1.2e-5),      # an upright's strings plucked: the fundamental's T60 about 2 s, 1 kHz's about 0.25 s
    "fretless": (1.0, 0.006, 3.0e-6), # stopped by a fingertip, no fret: the highs damped sooner, the fundamental singing on
}
# An acoustic double bass's body, which the bridge drives where no pickup reads the string: its air
# and wood modes, (Hz, gain, width), closing above 1.4 kHz.
BODY = ((62.0, 1.2, 14.0), (115.0, 0.9, 30.0), (240.0, 0.6, 70.0), (480.0, 0.25, 140.0))

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
    # A modern active bass played near the bridge (the Music Man and Dingwall kind The Omnific
    # play): new roundwounds, a firmer fingertip, a humbucker near the bridge whose active preamp
    # leaves the top flat and open.
    "active": dict(pluck=0.13, soft=2600.0, strings="fresh", stiff=1.2e-4, pickup=0.12, res=(5000.0, 0.8), glide=6.0, tone=None, click=0.0),
    # True bass instruments for The Far Bank's map half (Ryan, 4 November: "Map cellos replacement
    # needs to be a true bass-level instrument, not a dropped lead voice. Soft sub is ok, are there
    # others?"): an upright bass plucked, its body in place of a pickup (`pickup` None), the finger's
    # thump on the fingerboard; and a fretless electric, its notes blooming up into pitch.
    "upright": dict(pluck=0.30, soft=800.0, strings="gut", stiff=0.8e-4, pickup=None, res=None, glide=8.0, tone=None, click=0.0, thump=0.12),
    "fretless": dict(pluck=0.20, soft=1200.0, strings="fretless", stiff=1.0e-4, pickup=0.19, res=(2600.0, 2.0), glide=-8.0, tone=None, click=0.0),
}

# The amps: (the split under which the lows stay clean, the drive, the driven band's share, a push
# at 500 to 1300 Hz before the drive). "di" is a direct box.
AMPS = {
    "grit": (250.0, 2.2, 0.7, 0.0),     # a touch: an amp just breaking up in the mids
    "dirt": (250.0, 3.6, 0.85, 0.2),    # a little more (Ryan, 4 November: "What happens if we distort it a little?")
    "driven": (200.0, 6.0, 1.0, 0.6),   # driven hard with the mids pushed, as a rock bassist's drive
}
# A modern prog bass's drive, Darkglass's kind (the band works with them; Ryan, 4 November: "Can we
# achieve the 'omnific' sound?"): the lows clean under a lower split, the rest driven harder with
# its attack (2 to 5 kHz) raised into the drive, the low mids scooped and the upper mids lifted
# after it, a brighter cabinet, and a little of the clean top blended back for the clank.
MODERN = dict(split=160.0, drive=8.0, share=0.85, attack=0.6, scoop=0.35, lift=0.4, top=5500.0, clank=0.3)
# The modern drive a little dirtier (Ryan, 6 November, of Hold The Line's Omnific bass: "is there a way to try
# a slightly more distorted version of the Omnific voice? More distortion or gain or drive or whatever, just
# a bit dirtier"): the band over the split driven harder, all of it in the blend, half the clean clank.
DIRTY = dict(MODERN, drive=14.0, share=1.0, clank=0.15)
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
    t = np.arange(n) / SR
    warp = t + delta * GLIDE_TAU * (1.0 - np.exp(-t / GLIDE_TAU))   # time as the sharp start bends it
    out = np.zeros(n)
    k = 1
    while True:
        fk = k * f0 * math.sqrt(1.0 + p["stiff"] * k * k)
        if fk > TOP or fk > SR * 0.45:
            break
        if p["pickup"] is None:
            # An acoustic: the bridge's force, the string's slope there (k times its shape's 1/k^2),
            # through the body's modes.
            amp = math.sin(math.pi * k * beta) / k * body_gain(fk)
        else:
            amp = math.sin(math.pi * k * beta) * math.sin(math.pi * k * p["pickup"]) / k
        amp /= math.sqrt(1.0 + (fk / soft) ** 4)
        if p["res"]:
            fr, q = p["res"]
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
    if p.get("thump"):
        m = min(n, F.n_of(0.012))
        out[:m] += F.lp(F.noise(m), 500.0) * F.env_ad(m, 0.0005, 0.004) * p["thump"] * np.max(np.abs(out[:F.n_of(0.05)]))
    body = out[:F.n_of(0.1)]
    out = out / (np.sqrt(np.mean(body ** 2)) + 1e-9) * 0.25
    m = min(n, F.n_of(MUTE))
    out[n - m:] *= np.exp(-np.arange(m) / (0.25 * m)) * np.linspace(1.0, 0.0, m) ** 0.5   # the mute
    return out


def body_gain(f):
    """The double bass's body at a frequency (BODY)."""
    g = 0.35 + sum(gi / (1.0 + ((f - fi) / wi) ** 2) for fi, gi, wi in BODY)
    return g / math.sqrt(1.0 + (f / 1400.0) ** 4)


def cabinet(x):
    """A bass cabinet: the lows held from 45 Hz, a broad lift round 100 Hz, closed above 4 kHz."""
    y = x + F.bp(x, 70.0, 180.0) * 0.25
    return F.lp(F.hp(y, 45.0), 4200.0, order=3)


def modern(x, m=MODERN):
    """The modern drive (MODERN, or `m`), straight to the desk as such tones are, its cabinet in the drive's top."""
    low = _padded(x, lambda y: F.lp(y, m["split"]))
    high = x - low
    pre = high + _padded(high, lambda y: F.bp(y, 2000.0, 5000.0)) * m["attack"]
    h = (np.tanh(pre * m["drive"] + 0.15) - math.tanh(0.15)) / math.tanh(m["drive"])
    h = h - _padded(h, lambda y: F.bp(y, 380.0, 700.0)) * m["scoop"] + _padded(h, lambda y: F.bp(y, 1200.0, 2200.0)) * m["lift"]
    h = _padded(h, lambda y: F.lp(y, m["top"], order=4))
    return _padded(low + m["share"] * h + m["clank"] * high, lambda y: F.hp(y, 35.0))


def amplified(x, amp):
    """The string into a direct box, a bass amp with its lows clean under the split, or the modern drive."""
    if amp == "di":
        return _padded(x, lambda y: F.hp(y, 30.0))
    if amp == "modern":
        return modern(x)
    if amp == "dirty":
        return modern(x, DIRTY)
    split, drive, share, push = AMPS[amp]
    low = _padded(x, lambda y: F.lp(y, split))
    high = x - low
    if push:
        high = high + _padded(high, lambda y: F.bp(y, 500.0, 1300.0)) * push
    h = (np.tanh(high * drive + 0.2) - math.tanh(0.2)) / math.tanh(drive)
    h = _padded(h, lambda y: F.lp(y, 3500.0, order=4))
    return _padded(low + share * h, cabinet)


FIFTH_SHARE = 0.8   # a double-stop's fifth, on the next string up, plucked a little softer than its root


def real_bass(f, dur, preset="finger", amp="di", fifth=False):
    """A note, or with `fifth` a double-stop: the root and its fifth on two strings plucked together
    into one amp, so the drive grinds them into each other (their difference tones, the power
    chord's weight), where two basses each through its own amp stay apart."""
    x = string(f, dur, preset)
    if fifth:
        x = x + string(f * 2.0 ** (7.0 / 12.0), dur, preset) * FIFTH_SHARE
    return amplified(x, amp)


F.NOTE_INST["real_bass"] = lambda f, d, p: real_bass(f, d, p.get("preset", "finger"), p.get("amp", "di"), p.get("fifth", False))
