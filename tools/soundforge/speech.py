"""A formant voice for the console (sketched 2 October; Ryan's references: MechWarrior 2's
Bitching Betty, StarCraft's Adjutant, Doom's VEGA for a male-presenting one). The era's
speech was synthesised or processed to sound so, which is what a formant synthesiser gives:
a glottal pulse train through three formant resonators set per phoneme and glided between
them, noise for the fricatives, closures and bursts for the plosives, over a comm channel.
Crude by design; it is here to judge whether CARE's console should speak at all, and in
which voice. Words are spelt in phonemes by hand (`WORDS`), since the lines are few.

    from speech import say
    say("target locked", voice="betty")   # a numpy buffer at forge.SR
"""
import math
import os
import sys

import numpy as np
from scipy.signal import lfilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402

SR = F.SR

# formants (F1, F2, F3) for a male tract; a voice scales them
VOWELS = {
    "IY": (270, 2290, 3010), "IH": (390, 1990, 2550), "EH": (530, 1840, 2480), "AE": (660, 1720, 2410),
    "AA": (730, 1090, 2440), "AH": (640, 1190, 2390), "AO": (570, 840, 2410), "UH": (440, 1020, 2240),
    "UW": (300, 870, 2240), "ER": (490, 1350, 1690),
    # glides and liquids, vowel-like
    "W": (300, 650, 2300), "Y": (280, 2200, 3000), "L": (360, 1300, 2800), "R": (400, 1200, 1600),
    # nasals: a low first formant, quieter
    "M": (250, 1100, 2300), "N": (250, 1700, 2500), "NG": (250, 2000, 2700),
}
NASALS = ("M", "N", "NG")
LIQUIDS = ("W", "Y", "L", "R")
# diphthongs: a start and an end vowel
DIPHTHONGS = {"AY": ("AA", "IY"), "OW": ("AO", "UW"), "EY": ("EH", "IY"), "AW": ("AA", "UH")}
# fricatives: (band low, band high, voiced, gain)
FRICATIVES = {"S": (4000, 9000, False, 0.5), "Z": (4000, 9000, True, 0.35), "SH": (1800, 5000, False, 0.5), "ZH": (1800, 5000, True, 0.35),
              "F": (1500, 8000, False, 0.25), "V": (1500, 8000, True, 0.2), "TH": (1500, 8000, False, 0.22), "DH": (1500, 8000, True, 0.18),
              "H": (400, 4000, False, 0.3)}
# plosives: (burst band low, high, voiced, the locus the next vowel's F2 starts from)
PLOSIVES = {"P": (300, 2000, False, 900), "B": (300, 2000, True, 900), "T": (2500, 7000, False, 1800), "D": (2500, 7000, True, 1800),
            "K": (1200, 3500, False, 2000), "G": (1200, 3500, True, 2000)}

# the words the console says, in phonemes; a trailing ' marks the stressed vowel
WORDS = {
    "target": ["T", "AA'", "R", "G", "IH", "T"], "locked": ["L", "AA'", "K", "T"],
    "weapons": ["W", "EH'", "P", "AH", "N", "Z"], "online": ["AA'", "N", "L", "AY", "N"],
    "incoming": ["IH'", "N", "K", "AH", "M", "IH", "NG"], "shield": ["SH", "IY'", "L", "D"], "up": ["AH'", "P"],
    "machine": ["M", "AH", "SH", "IY'", "N"], "lost": ["L", "AO'", "S", "T"],
    "all": ["AO'", "L"], "systems": ["S", "IH'", "S", "T", "AH", "M", "Z"], "nominal": ["N", "AA'", "M", "IH", "N", "AH", "L"],
    "reactor": ["R", "IY", "AE'", "K", "T", "ER"], "contact": ["K", "AA'", "N", "T", "AE", "K", "T"],
    "gate": ["G", "EY'", "T"], "breached": ["B", "R", "IY'", "CH", "T"], "line": ["L", "AY'", "N"], "held": ["H", "EH'", "L", "D"],
    "die": ["D", "AY'"], "committed": ["K", "AH", "M", "IH'", "T", "IH", "D"],
}
PLOSIVES["CH"] = (1800, 5000, False, 1800)

VOICES = {
    # formant scale, f0, pace, breath, the channel's band, a description
    "betty": {"scale": 1.16, "f0": 215.0, "pace": 1.0, "breath": 0.12, "band": (300.0, 4200.0), "fall": 0.82},
    "vega": {"scale": 1.0, "f0": 102.0, "pace": 1.2, "breath": 0.08, "band": (180.0, 3800.0), "fall": 0.88},
}


def _formant(x, f, bw):
    """One formant: a two-pole resonator at f Hz with bandwidth bw, unity at the peak."""
    r = math.exp(-math.pi * bw / SR)
    th = 2.0 * math.pi * f / SR
    a = [1.0, -2.0 * r * math.cos(th), r * r]
    b = [1.0 - r]
    return lfilter(b, a, x)


def _tract(src, tracks, bws=(80.0, 110.0, 160.0), frame=0.005):
    """The vocal tract as three formants whose centres move frame by frame along `tracks`
    (three arrays of Hz, one per sample), with the filter state carried across frames."""
    n = len(src)
    hop = F.n_of(frame)
    out = np.zeros(n)
    states = []
    for k in range(3):
        states.append(None)
    for start in range(0, n, hop):
        seg = src[start:start + hop]
        y = seg
        for k in range(3):
            f = float(tracks[k][min(start + hop // 2, n - 1)])
            r = math.exp(-math.pi * bws[k] / SR)
            th = 2.0 * math.pi * f / SR
            a = np.array([1.0, -2.0 * r * math.cos(th), r * r])
            b = np.array([1.0 - r])
            if states[k] is None:
                states[k] = np.zeros(2)
            y, states[k] = lfilter(b, a, y, zi=states[k])
        out[start:start + hop] = y
    return out


def _segments(phones, voice):
    """Phonemes to a list of (kind, phone, duration, stressed, voiced)."""
    pace = voice["pace"]
    segs = []
    for ph in phones:
        stressed = ph.endswith("'")
        p = ph.rstrip("'")
        if p in DIPHTHONGS:
            segs.append(("vowel", p, (0.2 if stressed else 0.15) * pace, stressed, True))
        elif p in VOWELS and p not in NASALS and p not in LIQUIDS:
            segs.append(("vowel", p, (0.15 if stressed else 0.1) * pace, stressed, True))
        elif p in NASALS:
            segs.append(("nasal", p, 0.08 * pace, False, True))
        elif p in LIQUIDS:
            segs.append(("liquid", p, 0.07 * pace, False, True))
        elif p in FRICATIVES:
            segs.append(("fric", p, 0.11 * pace, False, FRICATIVES[p][2]))
        elif p in PLOSIVES:
            segs.append(("plosive", p, 0.075 * pace, False, PLOSIVES[p][2]))
        else:
            raise KeyError(p)
    return segs


def say_word(word, voice_name="betty", f0_mult=1.0):
    voice = VOICES[voice_name]
    segs = _segments(WORDS[word], voice)
    total = sum(d for _, _, d, _, _ in segs) + 0.04
    n = F.n_of(total)
    t = t_of = F.t_of(n)
    # formant tracks: targets per segment, glided between them over 30 ms
    f_tracks = [np.zeros(n) for _ in range(3)]
    voiced = np.zeros(n)
    amp = np.zeros(n)
    noise_src = np.zeros(n)
    pos = 0.0
    last_formants = None
    scale = voice["scale"]
    for i, (kind, p, d, stressed, isv) in enumerate(segs):
        a, b = F.n_of(pos), F.n_of(pos + d)
        nxt = segs[i + 1] if i + 1 < len(segs) else None
        if kind == "vowel":
            if p in DIPHTHONGS:
                v0, v1 = DIPHTHONGS[p]
                f_a = np.array(VOWELS[v0], dtype=float) * scale
                f_b = np.array(VOWELS[v1], dtype=float) * scale
                for k in range(3):
                    f_tracks[k][a:b] = np.linspace(f_a[k], f_b[k], b - a)
                last_formants = f_b
            else:
                f = np.array(VOWELS[p], dtype=float) * scale
                for k in range(3):
                    f_tracks[k][a:b] = f[k]
                last_formants = f
            voiced[a:b] = 1.0
            amp[a:b] = 1.0 if stressed else 0.85
        elif kind in ("nasal", "liquid"):
            f = np.array(VOWELS[p], dtype=float) * scale
            for k in range(3):
                f_tracks[k][a:b] = f[k]
            last_formants = f
            voiced[a:b] = 1.0
            amp[a:b] = 0.45 if kind == "nasal" else 0.75
        elif kind == "fric":
            lo, hi, isvoiced, g = FRICATIVES[p]
            m = b - a
            noise_src[a:b] = F.bp(F.noise(m), lo, hi) * g * F.env_pts(m, [(0.0, 0.3), (d * 0.3, 1.0), (d * 0.8, 1.0), (d, 0.4)])
            f = last_formants if last_formants is not None else np.array(VOWELS["AH"], dtype=float) * scale
            for k in range(3):
                f_tracks[k][a:b] = f[k]
            if isvoiced:
                voiced[a:b] = 1.0
                amp[a:b] = 0.4
        elif kind == "plosive":
            lo, hi, isvoiced, locus = PLOSIVES[p]
            closure = F.n_of(d * 0.6)
            m = b - a
            burst = np.zeros(m)
            bl = min(F.n_of(0.018), m - closure)
            if bl > 0:
                burst[closure:closure + bl] = F.bp(F.noise(bl), lo, hi) * F.env_ad(bl, 0.0005, 0.006) * 0.8
            noise_src[a:b] = burst
            f = last_formants if last_formants is not None else np.array(VOWELS["AH"], dtype=float) * scale
            for k in range(3):
                f_tracks[k][a:b] = f[k]
            f_tracks[1][a:b] = locus * scale
            if isvoiced:
                voiced[a + closure:b] = 1.0
                amp[a + closure:b] = 0.3
        pos += d
    # glide the formants: a 30 ms smoothing
    kern = F.n_of(0.03)
    for k in range(3):
        tr = f_tracks[k]
        tr[tr == 0] = (last_formants[k] if last_formants is not None else 500.0)
        f_tracks[k] = np.convolve(tr, np.ones(kern) / kern, mode="same")
    amp = np.convolve(amp, np.ones(F.n_of(0.012)) / F.n_of(0.012), mode="same")
    voiced = np.convolve(voiced, np.ones(F.n_of(0.01)) / F.n_of(0.01), mode="same")
    # the glottal source: pulses at f0 with a contour (a rise onto the stressed vowel, a fall
    # to the end), jitter, low-passed to a -12 dB slope
    f0 = voice["f0"] * f0_mult
    contour = f0 * np.interp(t, [0.0, total * 0.25, total], [0.95, 1.06, voice["fall"]])
    contour *= 1.0 + 0.006 * np.sin(2.0 * math.pi * 5.5 * t) + F.RNG.normal(0.0, 0.004, n)
    ph = np.cumsum(contour) / SR
    # The glottal pulse is a smooth flow pulse (a Rosenberg shape: a half-cosine opening over
    # 40% of the period, a quarter-cosine closing over 16%, closed for the rest), not an
    # impulse train: the impulses read as cracks and pops on the phone (Ryan, 2 October),
    # since every period was a click. Its slope falls on its own; the closing edge keeps the
    # formants bright.
    p = ph % 1.0
    opening = 0.5 * (1.0 - np.cos(math.pi * p / 0.4))
    closing = np.cos(0.5 * math.pi * (p - 0.4) / 0.16)
    pulse = np.where(p < 0.4, opening, np.where(p < 0.56, closing, 0.0))
    glottal = F.hp(np.diff(pulse, prepend=pulse[0]) * SR / 220.0, 60.0, order=1)   # the vowels had sat 10 to 17 dB under the consonants (measured 2 October): a faint voice under bursts
    breath = F.bp(F.noise(n), 500.0, 4000.0) * voice["breath"]
    src = (glottal + breath) * voiced * amp
    voice_part = _tract(src, f_tracks)
    # Even the voiced part out (the liquids' stacked formants had come out 10 dB over the
    # vowels): a slow levelling over 15 ms toward one level where the voice sounds, gain
    # capped, which is also how that era's speech sounded, vocoder-flat.
    win = F.n_of(0.015)
    env = np.sqrt(np.convolve(voice_part ** 2, np.ones(win) / win, mode="same")) + 1e-6
    gain = np.clip(0.12 / env, 0.0, 6.0) * voiced
    gain = np.convolve(gain, np.ones(win) / win, mode="same")
    voice_part = voice_part * np.where(voiced > 0.0, gain, 1.0)
    out = voice_part + noise_src * 0.8
    return out * F.env_pts(n, [(0.0, 0.0), (0.01, 1.0), (total - 0.03, 1.0), (total, 0.0)])


def say(line, voice_name="betty", gap=0.09):
    """A line of words through the console's channel."""
    voice = VOICES[voice_name]
    buf = np.zeros(1)
    pos = 0.0
    words = line.split()
    for i, w in enumerate(words):
        x = say_word(w, voice_name, f0_mult=(1.0 if i < len(words) - 1 else 0.96))
        buf = F.at(buf, x, pos)
        pos += len(x) / SR + gap * voice["pace"]
    lo, hi = voice["band"]
    x = F.bp(buf, lo, hi)
    x = F.sat(x / (np.max(np.abs(x)) + 1e-9) * 1.1, 1.3)   # a touch of the channel's compression, less than before (2 October: the crackle)
    return F.room(x, decay=0.1, mix=0.08, cut=4500.0)
